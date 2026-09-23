param appServiceName string
param appServicePlanName string
param keyVaultSecretUri string

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: 'westeurope'
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  properties: {
    reserved: false
  }
}

resource appService 'Microsoft.Web/sites@2025-03-01' = {
  name: appServiceName
  location: 'westeurope'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      netFrameworkVersion: 'v10.0'
      appSettings: [
        {
          name: 'ConnectionStrings__DefaultConnection'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultSecretUri})'
        }
      ]
    }
  }
}

output principalId string = appService.identity.principalId
output appServiceHostName string = appService.properties.defaultHostName
output outboundIpAddresses string = appService.properties.outboundIpAddresses