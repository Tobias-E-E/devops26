# Spår C — DevSecOps & kvalitet: slutbevis

Testkörning av labben 2026-10-12 i repot Tobias-E-E/devops26 (solo). Skärmdumparna
är platshållare: filerna läggs i `inlamning/` med namnen nedan.

## 1. Steg 1 — grinden lokalt

![vulnerable-skanningen: CVE-2020-14343 och ">>> vulnerable gav exitkod 1"](spar-c-01-trivy-vulnerable.png)

Trivy 0.58.1 med `--ignore-unfixed --severity HIGH,CRITICAL --exit-code 1` gav exitkod 1 på
`template-app-backend:vulnerable` (PyYAML 5.3.1, CVE-2020-14343, CRITICAL, Fixed 5.4). Den rena
imagen föll samma dag på två HIGH i httpx2/httpcore2 — patchade i steg 2.

## 2. Steg 2 — triage (tre beslut) och patch-PR

- **Patcha:** httpx2 2.9.1 → 2.12.0 (CVE-2026-84381, CVE-2026-84382; drar in httpcore2 ≥ 2.10.0). Fix fanns, alltså togs den.
- **Ignorera med utgångsdatum:** pip 25.0.1 (fem MEDIUM, fix 25.3–26.2.0). pip används bara under `docker build`, aldrig i
  runtime-kodvägen; skulle skrivas i `.trivyignore.yaml` med `expired_at` om grinden någonsin höjs till MEDIUM.
- **Acceptera (eskaleras):** pytest 8.3.4 (CVE-2025-71176, MEDIUM, fix 9.0.3). Testberoende utan prod-kodväg, men
  permanent accept är inte vårt beslut — flaggas till kursansvarig.

Patch-PR: https://github.com/Tobias-E-E/devops26/pull/1

## 3. Steg 3 — rulesetet

![regeln för main med fem obligatoriska checkar och Enforcement status: Active](spar-c-03-ruleset.png)

`Lint and test backend`, `Trivy image scan (backend|frontend)`, `Analyze (python|javascript-typescript)` plus
Require code scanning results → CodeQL. Kontroll-PR:en var BLOCKED tills alla var gröna.

## 4. Steg 4 — precondition-fällan

![Error: Resource precondition failed — Workspace "dev" does not match environment "prod"](spar-c-04-precondition.png)

`terraform plan -var-file=envs/prod.tfvars` i dev-workspacet stoppas innan något rörs.

## 5. Steg 5 — prod-miljön

![prod: Required reviewers och Deployment branches and tags = main](spar-c-05-prod-environment.png)

## 6. Steg 6 — kedjan väntar

![Deploy to VM: Trivy ×2, Deploy to dev, Integration test against dev gröna, Deploy to prod Waiting](spar-c-06-waiting.png)

## 7. Steg 7 — sårbar PR blockerad

![PR #5: röd Trivy image scan (backend) med CVE-2020-14343, Merge blockerad](spar-c-07-blocked-pr.png)

## Adresser och envs-diffen

- dev: http://86.50.168.61:8080
- prod: http://195.148.30.48:8080

`diff envs/dev.tfvars envs/prod.tfvars` skiljer sig i exakt ett värde, `environment`, därför att flavor och
nätverk är identiska med flit — dev är bara ett test av prod i den mån den är formad som prod.
