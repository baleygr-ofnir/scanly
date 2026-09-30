using '../main.bicep'

// ── Production environment — HA, full resources, geo-redundant storage ────
// Three replicas spread across fault domains for availability.
// Geo-redundant storage (GRS) ensures data survives a regional outage.

param environmentName = 'prod'
param location = 'westeurope'

param minReplicas    = 3        // Three replicas for high availability
param containerCpu   = '0.5'   // 0.5 vCPU per replica
param containerMemory = '1Gi'

param storageSku = 'Standard_GRS'  // Geo-redundant — survives a regional outage
