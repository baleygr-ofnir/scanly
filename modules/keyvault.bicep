param location string = 'westeurope'
param vaultName string
param containerAppPrincipalId string
@secure()
param azureDiEndpoint string
@secure()
param azureDiKey string
@secure()
param azureStorageUrl string
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: containerAppPrincipalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}
resource azureDiEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'AzureDiEndpoint'
  properties: {
    value: azureDiEndpoint
  }
}

resource azureKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'AzureDiKey'
  properties: {
    value: azureDiKey
  }
}

resource azureStorageUrlSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'AzureStorageUrl'
  properties: {
    value: azureStorageUrl
  }
}
output keyVaultUri string = keyVault.properties.vaultUri
