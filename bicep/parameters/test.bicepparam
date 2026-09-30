using '../main.bicep'

// ── Test environment — mirrors prod sizing at reduced scale ───────────────
// One always-on replica for stable integration/QA runs.
// Same CPU/memory as prod so behaviour is consistent; LRS storage is fine.

param environmentName = 'test'
param location = 'westeurope'

param minReplicas    = 1        // One always-on replica for stable test runs
param containerCpu   = '0.5'   // 0.5 vCPU — matches prod, avoids OOM surprises
param containerMemory = '1Gi'

param storageSku = 'Standard_LRS'  // No geo-redundancy needed in test
