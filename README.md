# Portfolio 2026

Statisk portfolio med core-sidor, trend-sidor och kurs-sidor för TS25 IT-testspecialist.

## Kör lokalt

Öppna `index.html` direkt i browsern eller kör från projektmappen:

```powershell
Set-Location D:\Website\portfolio
Start-Process .\index.html
```

## Kurser

Alla kurser finns i `courses.html`. Där finns en modulvy med sökfält, filter och länkar till varje kurssida.

```powershell
Set-Location D:\Website\portfolio
Start-Process .\courses.html
```

## QA och test

QA-körningen finns i `qa/run-tests.ps1`. Den kontrollerar att kurssidor finns, att hubben länkar rätt, att huvudmenyn har Kurser-länk och att HTML-basstruktur finns.

```powershell
Set-Location D:\Website\portfolio
.\qa\run-tests.ps1
```

Efter varje testkörning uppdateras:

- `qa/index.html` - visuell testrapport
- `qa/testresultat.md` - detaljerade testresultat
- `qa/testrapport.md` - sammanfattad testrapport

Det finns inget `package.json` i projektet just nu. Därför finns inga `npm run build`, `npm run lint` eller `npm test` att köra.

## Git-flöde

Ta in senaste kod innan nytt arbete:

```powershell
Set-Location D:\Website\portfolio
git pull
```

Se lokala ändringar:

```powershell
git status
```

Staga relevanta ändringar:

```powershell
git add .
```

Committa med tydlig kommentar:

```powershell
git commit -m "Lägg till kurssektion och QA-rapport"
```

Pusha:

```powershell
git push
```
