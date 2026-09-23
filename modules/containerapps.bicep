param location string = 'westeurope'
param envName string
param appName string
param registryLoginServer string
param storageUrl string
param diEndpoint string
@secure()
param diKey string

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
      secrets: [
        {
          name: 'di-key'
          value: diKey
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
          env: [
            {
              name: 'AzureDI__Endpoint'
              value: diEndpoint
            }
            {
              name: 'AzureDI__Key'
              secretRef: 'di-key'
            }
            {
              name: 'AzureStorage__Url'
              value: storageUrl
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

