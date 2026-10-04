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
En uppskattad budgetkalkyl baserad på Azure Pricing Calculator (räknat per månad i regionen West Europe). Budgetkravet är max 500 SEK per person:

| Tjänst | Detaljer | Uppskattad Kostnad (SEK/månad) |
| :--- | :--- | :--- |
| **Azure Container Apps** | Consumption Plan. Min-replicas: 2 (0.5 vCPU, 1 GB RAM). Antar låg-till-medel aktiv användning. | ~120 - 150 SEK |
| **Azure Container Registry** | Basic SKU (innehåller 10 GB lagring). | ~55 SEK |
| **Azure Storage Account** | Standard LRS (General Purpose v2). Extremt låg lagringsvolym och få transaktioner. | ~5 SEK |
| **Azure Key Vault** | Standard Tier. Få operationer per månad (några ören per 10 000 operationer). | < 2 SEK |
| **Azure Document Intelligence** | Pay-as-you-go (S0 Tier). ~1000 sidor per månad. (*Gratisnivån F0 är tillgänglig vid behov*). | ~100 SEK |
| **Log Analytics (App Insights)** | Pay-as-you-go. Några hundra MB injest. | ~20 SEK |
| **Total Månadskostnad** | | **~302 - 332 SEK** |

Den totala kostnaden ryms med god marginal inom budgeten på 500 SEK per person för labbens genomförande. Eftersom det är en Consumption-baserad modell kan kostnaderna hållas ännu lägre om Container App konfigureras att skala ner till noll (min-replicas: 0) när den inte används, eller genom att tjänsterna stängs ner ("Stäng ner resurser") efter labben.
