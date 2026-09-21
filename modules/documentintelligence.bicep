param location string = 'westeurope'
param accountName string

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  sku: {
    name: 'F0'
  }
  kind: 'FormRecognizer'
  properties: {
    publicNetworkAccess: 'Enabled'
    customSubDomainName: accountName
  }
}

output cognitiveServicesId string = cognitiveServices.id
output cognitiveServicesEndpoint string = cognitiveServices.properties.endpoint
