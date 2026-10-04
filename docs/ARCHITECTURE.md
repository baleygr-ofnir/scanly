# Arkitekturdokumentation (ARCHITECTURE.md)

Detta dokument besvarar de fem obligatoriska arkitekturfrågorna för Scanly API:et enligt projektkraven.

## 1. Varför Container Apps (inte AKS)?
Vi valde Azure Container Apps istället för Azure Kubernetes Service (AKS) av flera anledningar:
- **Resurstillgång och komplexitet**: Vi har inte tillgång till, eller ett genuint behov av, ett fullskaligt AKS-kluster för det här projektet. AKS innebär en stor operationell overhead som kräver mycket underhåll.
- **Serverless-modell**: Container Apps bygger på en serverless-modell (PaaS) som abstraherar bort infrastrukturen. Det ger oss fördelarna från Kubernetes (som KEDA för autoskalning) utan att vi behöver hantera själva klustret.
- **Skalbarhet**: Det ger inbyggt stöd för autoskalning (även ner till noll om så önskas) vilket är mycket kostnadseffektivt och passar vårt .NET-API perfekt.

## 2. CI/CD-flöde steg för steg
Vår CI/CD-pipeline i GitHub Actions är konfigurerad för att automatiskt bygga och driftsätta vår applikation. Flödet ser ut på följande sätt:
1. **Checkout code**: Koden hämtas från `main`-branchen.
2. **Azure Login**: Autentisering mot Azure genomförs säkert via OpenID Connect (OIDC).
3. **ACR Login**: Säker inloggning upprättas mot vårt Azure Container Registry.
4. **Build Docker**: Koden byggs i en multi-stage Dockerfile där .NET-projektet kompileras, testas (enhetstester körs) och paketeras.
5. **Push Docker to ACR**: Den färdiga Docker-imagen laddas upp till Azure Container Registry och taggas med commit-SHA.
6. **Update Container App**: Azure Container App uppdateras för att peka på den nyskapade Docker-imagen, varpå appen startas om och görs tillgänglig (driftsättning).

## 3. Varför Bicep (IaC)?
Infrastructure as Code (IaC) via Bicep används av följande skäl:
- **Reproducerbarhet**: Vi har en färdig infrastruktur som kan sättas upp från grunden på några minuter. 
- **Enkelhet**: Det gör det mycket enklare att hantera uppskalning eller rulla ut miljön till nya prenumerationer/miljöer (till exempel att separera `dev` och `prod` med `.bicepparam`-filer).
- **Spårbarhet**: Ändringar i infrastrukturen versionshanteras i Git, vilket gör att vi kan spåra vem som ändrade vad och när, samt undvika manuella felkällor från Azure Portal.

## 4. Hur hanteras hemligheter?
Lösningen bygger på "Zero-Trust" och minimerar hanteringen av hemligheter:
- **Inga hårdkodade lösenord**: Inga hemligheter (som API-nycklar eller connection strings) existerar i källkoden.
- **GitHub Actions Secrets**: Miljövariabler och inloggningsuppgifter som krävs under CI/CD-flödet lagras säkert i GitHub Secrets.
- **Azure Key Vault & Managed Identity**: Applikationen hämtar känslig information från Azure Key Vault under runtime. Åtkomsten hanteras via **System-Assigned Managed Identity**, vilket innebär att tjänsterna (Container Apps, Storage, Key Vault, ACR) litar på varandra internt via Azure Entra ID, helt utan att vi behöver skapa och skicka runt lösenord.

## 5. Ekonomi med faktiska siffror
Enligt vår uppskattade budgetkalkyl baserad på Azure Pricing Calculator (se `scanly-estimate.md` för detaljer) är den förväntade månadskostnaden för en fullskalig produktionsmiljö följande (räknat per månad i regionen West Europe):

| Tjänst | Detaljer | Estimerad Kostnad (SEK/månad) |
| :--- | :--- | :--- |
| **Azure Container Apps** | Consumption Plan, 0.4 milj anrop, 3 min-replikor | 450.30 kr |
| **Azure Container Registry** | Basic Tier | 57.10 kr |
| **Storage Accounts** | Block Blob Storage, ZRS, 25 GB lagring | 14.22 kr |
| **Key Vault** | 100 000 operationer | 2.86 kr |
| **Azure Document Intelligence**| S0-instans: 100 000 Pre-built sidor | 9 519.20 kr |
| **Total Månadskostnad** | | **10 043.67 kr** |

*Notera gällande labb-budgeten på 500 SEK:* 
Denna kalkyl baseras på **100 000 bearbetade sidor i Document Intelligence**. För att hålla oss inom vår faktiska labb-budget på 500 SEK per person kommer vi under labben att hantera en extremt liten bråkdel av denna volym. Dessutom stänger vi ner tjänsterna ("Stäng ner resurser") efter labben, varför vi inte kommer att överstiga de tillåtna 500 kronorna.
