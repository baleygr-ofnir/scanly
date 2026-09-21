# Teamlab — Full cloudlösning

> Presentation: Fredag 3 oktober (online) | Scenario-val: Senast fredag 26 september

## Grund­info

- [x] Välj scenario från `exercises/scenarios.md`
- [x] Meddela Marcus: gruppstorlek + scenario
- [x] Budget: 500 SEK per person för Azure-resurser
- [ ] **Stäng ner resurser** efter labben för att spara budget

---

## G-krav — Måste vara klart

### API (minst 4 endpoints)

- [x] Minst 4 endpoints implementerade och fungerande
- [x] `GET /health` returnerar 200 OK
- [x] Scalar UI
- [x] Alla endpoints dokumenterade (`.WithTags()` + `.Produces<T>()`)

### Azure-tjänst i fokus

- [x] Primär Azure-tjänst anropas korrekt (Document Intelligence / Computer Vision / AI Language, eller Blob Storage för scenario D)
- [x] Svar returneras strukturerat från API
- [x] **Managed Identity** för autentisering (ingen hårdkodad nyckel)
- [x] Resultat sparas i **Azure Blob Storage**

### Infrastruktur (Bicep)

- [ ] Alla resurser i Bicep (deployas in i befintlig resource group)
- [ ] Minst: ACR + Container Apps Environment + Container App + Storage Account
- [ ] `az deployment group what-if` fungerar utan fel

### Containerisering

- [x] Appen körs i Docker
- [x] Multi-stage Dockerfile (builder + runtime)
- [ ] Image pushad till Azure Container Registry (ACR)

### Driftsättning

- [ ] Container App deployad från ACR-imagen
- [ ] Minst 2 replicas (min-replicas i Bicep)
- [ ] Appen svarar på publik URL

### CI/CD (Azure DevOps)

- [ ] YAML-pipeline triggas automatiskt vid push till `main`
- [ ] Pipeline-steg: build → test → push till ACR → deploy till Container Apps
- [ ] Grön pipeline = live app

### Säkerhet

- [ ] Inga hårdkodade credentials i koden
- [ ] Pipeline-secrets + environment variables
- [ ] Managed Identity för all Azure-åtkomst
- [ ] Inga hemliga nycklar i git-historiken

### Dokumentation (ARCHITECTURE.md)

- [ ] Svar på alla 5 arkitekturfrågor:
  - [ ] Varför Container Apps (inte AKS)?
  - [ ] CI/CD-flöde steg för steg
  - [ ] Varför Bicep (IaC)?
  - [ ] Hur hanteras hemligheter?
  - [ ] Ekonomi med faktiska siffror

---

## VG-krav — Minst 3 av dessa

- [ ] **Autoskalning**: HTTP-baserade scaling rules (t.ex. >10 simultana requests)
- [ ] **Monitoring**: Application Insights + minst ett custom alert (t.ex. alert vid fel > 5%)
- [ ] **Parametriserad Bicep**: parameter-fil för dev/prod (replicas, SKU osv.)
- [ ] **Felhantering**: Tydliga API-svar + HTTP-statuskoder + loggning när Azure-tjänsten misslyckas
- [ ] **Rollback**: Dokumenterad och demonstrerad (re-deploy av tidigare Container App revision)
- [ ] **Välgrundade designval**: Presentationen diskuterar alternativ (varför Container Apps för just denna workload?)

---

## Leverabler

- [ ] **Git-repo** (Azure DevOps eller GitHub) — länk till Marcus senast torsdag 2 okt kl. 23:59
- [ ] **Presentation** (10/12/15 min) — fredag 3 okt online
- [ ] **Commit-historik** — visar arbete, alla teammedlemmar har commits
- [ ] **RAPPORT.md** — kundrapport baserad på mallen
- [ ] **REFLEKTION_[namn].md** — individuell reflektion per person

---

## Presentationen

**Längd**: 10 min (ensam) | 12 min (par) | 15 min (grupp 3–4)

- [ ] Vad ni byggde och varför (1–2 min)
- [ ] Arkitekturöversikt med diagram (2–3 min)
- [ ] **Live-demo**: push → pipeline → live API-anrop (3–4 min)
- [ ] Ekonomi och skalning (1–2 min)
- [ ] Vad gick fel och hur ni löste det (1–2 min)
- [ ] Frågor från Marcus (2 min)

**Obligatoriskt**: Live-demo + **backup-video** (max 3 min) om tekniken strular.

---

## Tips

- **Börja med infrastrukturen** — Container Apps-miljön tar tid
- **Testa Azure-tjänsten isolerat först** — innan du integrerar den i API:et
- **Dela upp horisontellt** — alla ska ha commits och kunna förklara allt
- **Ekonomin är inte bonus** — ha faktiska siffror från Azures priskalkylator
- **Kör ensam?** Prioritera: Bicep → Container App → API → Pipeline → Swagger

---

## Gruppinfo

**Gruppstorlek**: [ ] Ensam | [ ] Par | [ ] Grupp (_____ personer)

**Scenario**: [ ] A | [ ] B | [ ] C | [ ] D (Certify)

**Teammedlemmar**:
- [ ] ...
- [ ] ...
- [ ] ...

**Repo-länk**: 

**Presentation - tid**: 

---

## Status

**G-krav**: ___/10 ✓
**VG-krav**: ___/6 ✓
**Leverabler**: ___/5 ✓