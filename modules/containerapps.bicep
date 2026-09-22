param location string = 'westeurope'
param envName string
param appName string
param registryLoginServer string
param keyVaultSecretUri string = ''

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource env 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: envName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource app 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
      registries: [
        {
          server: registryLoginServer
          identity: 'system'
        }
      ]
      secrets: empty(keyVaultSecretUri) ? [] : [
        {
          name: 'azure-di-endpoint'
          keyVaultUrl: '${keyVaultSecretUri}secrets/AzureDiEndpoint'
          identity: 'System'
        }
        {
          name: 'azure-di-key'
          keyVaultUrl: '${keyVaultSecretUri}secrets/AzureDiKey'
          identity: 'System'
        }
        {
          name: 'azure-storage-url'
          keyVaultUrl: '${keyVaultSecretUri}secrets/AzureStorageUrl'
          identity: 'System'
        }
      ]
    }
    template: {
      scale: {
        minReplicas: 2
      }
      containers: [
        {
          name: 'api'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          env: empty(keyVaultSecretUri) ? [] : [
            {
              name: 'AzureDi__Endpoint'
              secretRef: 'azure-di-endpoint'
            }
            {
              name: 'AzureDi__Key'
              secretRef: 'azure-di-key'
            }
            
            {
              name: 'AzureStorage__Url'
              secretRef: 'azure-storage-url'
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}

output principalId string = app.identity.principalId
output appUrl string = app.properties.configuration.ingress.fqdn
