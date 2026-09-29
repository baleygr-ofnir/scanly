using '../main.bicep'

param environmentName = 'prod'
param location = 'westeurope'
param azureDiEndpoint = readEnvironmentVariable('AZURE_DI_ENDPOINT')
param azureDiKey = readEnvironmentVariable('AZURE_DI_KEY')
