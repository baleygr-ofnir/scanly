using '../main.bicep'

// ── Dev environment — cheap, minimal, scale-to-zero ──────────────────────
// Cost-optimised: single replica that scales down to 0 when idle.
// Consumption-tier resources, locally-redundant storage.

param environmentName = 'dev'
param location = 'westeurope'

param minReplicas    = 0        // Scale to zero when idle (saves cost)
param containerCpu   = '0.25'  // 0.25 vCPU
param containerMemory = '0.5Gi'

param storageSku = 'Standard_LRS'  // Locally-redundant — sufficient for dev
