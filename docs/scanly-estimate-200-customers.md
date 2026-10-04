# Scanly - Azure Infrastruktur Kostnadskalkyl

**Valuta:** Svenska Kronor (SEK)
**Datum för kalkyl:** 2026-09-30

## Tjänstespecifikation och Kostnader

| Kategori | Tjänst | Region | Konfiguration / Beskrivning | Estimerad månadskostnad (SEK) |
| :--- | :--- | :--- | :--- | :--- |
| **Containers** | Azure Container Apps | West Europe | Consumption Plan Type, 0.4 miljoner anrop per månad, 20 samtidiga anrop per app, 1000 ms exekveringstid per anrop, 1 GiB minne, 3 min-replikor. | 450.30 kr |
| **Containers** | Azure Container Registry | West Europe | Basic Tier, 1 register x 30 dagar, 10 GB Extra Storage, Bygge: 1 CPU x 1 s. Utgående trafik: 20 GB internt Microsoft Global Network. | 57.10 kr |
| **Storage** | Storage Accounts | West Europe | Block Blob Storage, General Purpose V2, Flat Namespace, ZRS (Zone-Redundant), Hot Access Tier, 25 GB kapacitet. Operationer: 100k Write, 0 List/Create, 500k Read, 10k Other. 10 GB hämtning, 1000 GB skrivning. SFTP & Object Replication inaktiverat. | 14.22 kr |
| **Security** | Key Vault | West Europe | Vault: 100 000 operationer, 0 avancerade operationer/förnyelser/skyddade nycklar. Managed HSM Pools: 0 Standard B1 HSM Pooler. | 2.86 kr |
| **AI + Machine Learning**| Azure Document Intelligence | West Europe | S0-instans: 100 000 Pre-built sidor. (0 Read, 0 Custom Classification, 0 Custom Extraction, 0 Add-on, 0 Query, 0 Paid Training). | 9 519.20 kr |
| **Support** | Support | N/A | Ingen betald supportplan vald. | 0.00 kr |

## Summering
**Licensprogram:** Microsoft Customer Agreement (MCA)
**Total uppskattad månadskostnad:** 10 043.67 kr
**Estimerad förskottskostnad (Upfront):** 0.00 kr