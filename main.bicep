param location string = 'westeurope'
@secure()
param azureDiEndpoint string
@secure()
param azureDiKey string

// Generera unika namn baserat på resursgruppen för att undvika namnkrockar

var uniqueStr = uniqueString(resourceGroup().id)
var storageName = 'stscanly${uniqueStr}'
var acrName = 'acrscanly${uniqueStr}'
var envName = 'cae-scanly-${uniqueStr}'
var appName = 'ca-scanly-api'
var vaultName = 'kv-scanly-${uniqueStr}'

module storage 'modules/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    location: location
    storageAccountName: storageName
  }
}

module acr 'modules/containerregistry.bicep' = {
  name: 'acrDeploy'
  params: {
    location: location
    registryName: acrName
  }
}

module containerApp 'modules/containerapps.bicep' = {
  name: 'appDeploy'
  params: {
    location: location
    envName: envName
    appName: appName
    registryLoginServer: acr.outputs.registryLoginServer

  }
}
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVaultDeploy'
  params: {
    containerAppPrincipalId: containerApp.outputs.principalId 
    location: location
    vaultName: vaultName
    azureDiEndpoint: azureDiEndpoint
    azureDiKey: azureDiKey
    azureStorageUrl: storage.outputs.storageAccountUrl
  }
}

module containerAppSettings 'modules/containerapps.bicep' = {
  name: 'containerAppSettingsUpdate'
  dependsOn: [
    assignAcrPull
    assignBlobContributor
  ]
  params: {
    appName: appName
    envName: envName
    location: location
    registryLoginServer: acr.outputs.registryLoginServer
    keyVaultSecretUri: keyVault.outputs.keyVaultUri
  }
}

// -- Role Assignments --

// Definiera referenser till de nyskapade resurserna för att kunna sätta rättigheterna
resource acrRef 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}
resource storageRef 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageName
}

// Inbyggda Role Definition IDs i Azure
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var blobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

// 1. Ge Container Appen behörighet att hämta (pull) images från ACR
resource assignAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrRef.id, appName, acrPullRoleId)
  scope: acrRef
  dependsOn: [
    acr
  ]
  properties: {
    principalId: containerApp.outputs.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}

// 2. Ge Container Appen behörighet att läsa/skriva blobbar i Storage Account
resource assignBlobContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageRef.id, appName, blobDataContributorRoleId)
  scope: storageRef
  dependsOn: [
    storage
  ]
  properties: {
    principalId: containerApp.outputs.principalId
    roleDefinitionId: blobDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

output acrLoginServer string = acr.outputs.registryLoginServer
output containerAppUrl string = containerApp.outputs.appUrl
