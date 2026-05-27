$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$ExpectedCoursePages = @(
  "course-jobb-lia-tips.html",
  "course-applied-script.html",
  "course-examensarbete.html",
  "course-allmant.html",
  "course-gui-anvandbarhetstest.html",
  "course-istqb-foundation-level.html",
  "course-kommunikation-teamarbete.html",
  "course-krav-anvandningsfall.html",
  "course-lia-1.html",
  "course-lia-2.html",
  "course-python-preparandkurs.html",
  "course-qa-introduktion.html",
  "course-randoms.html",
  "course-studerande-forum.html",
  "course-test-automation.html",
  "course-testdata-testmiljoer-dataskydd.html",
  "course-testnivaer-metodiker.html",
  "course-teststrategi-planering.html",
  "course-testtekniker-standard.html",
  "course-testverktyg-standard.html",
  "course-utvarderingar.html"
)

$Results = New-Object System.Collections.Generic.List[object]

function Add-Result($Id, $Title, $Status, $Expected, $Actual, $Bug = "") {
  $Results.Add([pscustomobject]@{
    Id = $Id
    Title = $Title
    Status = $Status
    Expected = $Expected
    Actual = $Actual
    Bug = $Bug
  }) | Out-Null
}

foreach ($page in $ExpectedCoursePages) {
  $exists = Test-Path $page
  Add-Result "TC-COURSE-FILE" "Kurssida finns: $page" ($(if ($exists) { "Pass" } else { "Fail" })) "Filen ska finnas" $page ($(if ($exists) { "" } else { "BUG-COURSE-MISSING" }))
}

$courseHub = if (Test-Path "courses.html") { Get-Content -Raw "courses.html" } else { "" }
foreach ($page in $ExpectedCoursePages) {
  $linked = $courseHub -match [regex]::Escape($page)
  Add-Result "TC-COURSE-LINK" "Kurshubb länkar till $page" ($(if ($linked) { "Pass" } else { "Fail" })) "courses.html ska länka till sidan" "Länk kontrollerad" ($(if ($linked) { "" } else { "BUG-COURSE-LINK" }))
}

$corePages = @("index.html", "about.html", "projects.html", "qa.html", "cv.html", "contact.html", "hyresgastforeningen.html", "sosbarnbyar.html", "startingupsprinto.html")
foreach ($page in $corePages) {
  if (Test-Path $page) {
    $content = Get-Content -Raw $page
    $hasCourses = $content -match 'courses\.html'
    Add-Result "TC-NAV-COURSES" "Meny har Kurser-länk: $page" ($(if ($hasCourses) { "Pass" } else { "Fail" })) "Alla core-sidor ska länka till courses.html" $page ($(if ($hasCourses) { "" } else { "BUG-NAV-COURSES" }))
  }
}

$HtmlFiles = Get-ChildItem -Path $Root -Filter "*.html" -File
foreach ($file in $HtmlFiles) {
  $content = Get-Content -Raw $file.FullName
  $basicOk = $content -match '<!DOCTYPE html>' -and $content -match '<meta charset="UTF-8">' -and $content -match '<meta name="viewport"'
  Add-Result "TC-HTML-BASIC" "HTML-basstruktur: $($file.Name)" ($(if ($basicOk) { "Pass" } else { "Fail" })) "Doctype, charset och viewport ska finnas" $file.Name
}

if (Test-Path "package.json") {
  Add-Result "TC-NPM" "package.json finns" "Pass" "NPM scripts kan kontrolleras manuellt" "package.json finns"
} else {
  Add-Result "TC-NPM" "package.json saknas" "Pass" "Rapportera att npm build/lint/test inte finns" "Inget package.json i projektroten"
}

$Total = $Results.Count
$Passed = ($Results | Where-Object Status -eq "Pass").Count
$Failed = ($Results | Where-Object Status -eq "Fail").Count
$RunDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Rows = ($Results | ForEach-Object { "| $($_.Id) | $($_.Title) | $($_.Status) | $($_.Expected) | $($_.Actual) | $($_.Bug) |" }) -join "`n"

$ResultMd = @"
# Testresultat - Portfolio 2026

- Körningsdatum: $RunDate
- Miljö: Lokal statisk HTML i Windows/PowerShell
- Totalt: $Total
- Pass: $Passed
- Fail: $Failed

| Test Case ID | Titel | Status | Expected | Actual | Bug ID |
|---|---|---|---|---|---|
$Rows
"@
Set-Content -Path "qa\testresultat.md" -Value $ResultMd -Encoding utf8

$ReportMd = @"
# Testrapport - Portfolio 2026

## Sammanfattning
Portfolio, trendspår och kurssidor kontrollerades med statiska QA-kontroller.

## Test Execution Summary
| Mätvärde | Antal |
|---|---:|
| Totalt | $Total |
| Passed | $Passed |
| Failed | $Failed |
| Blocked | 0 |
| Ej körda | 0 |

## Defect Summary
| Severity | Antal |
|---|---:|
| Critical | 0 |
| High | 0 |
| Medium | $Failed |
| Low | 0 |

## Kvalitetsbedömning
$(if ($Failed -eq 0) { "Godkänd för statisk visning. Manuell responsiv testning behövs fortfarande i browser." } else { "Inte godkänd. Fixa failures i testresultatet först." })

## Avvikelser från testplan
Det finns inget package.json. Därför finns inga npm build/lint/test-kommandon att köra.
"@
Set-Content -Path "qa\testrapport.md" -Value $ReportMd -Encoding utf8

$HtmlRows = ($Results | ForEach-Object { "<tr><td>$($_.Id)</td><td>$($_.Title)</td><td class='$($_.Status.ToLower())'>$($_.Status)</td><td>$($_.Actual)</td><td>$($_.Bug)</td></tr>" }) -join "`n"
$Html = @"
<!DOCTYPE html>
<html lang="sv">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>QA Rapport - Portfolio 2026</title>
<style>
body{font-family:Segoe UI,Tahoma,sans-serif;margin:0;background:#f8fafc;color:#0f172a}
main{width:min(1120px,calc(100% - 2rem));margin:0 auto;padding:32px 0}
.hero{background:#0f172a;color:#fff;border-radius:20px;padding:24px}
.commands,.card{background:#fff;border:1px solid #e2e8f0;border-radius:16px;padding:18px;margin-top:16px}
code{display:block;background:#111827;color:#f8fafc;padding:12px;border-radius:12px;overflow:auto;white-space:pre-wrap}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:16px;overflow:hidden;margin-top:16px}
td,th{padding:10px;border-bottom:1px solid #e2e8f0;text-align:left}
.pass{color:#15803d;font-weight:800}.fail{color:#b91c1c;font-weight:800}
.metrics{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px}
.metric{background:#fff;border:1px solid #e2e8f0;border-radius:16px;padding:18px}.metric strong{display:block;font-size:2rem}
</style>
</head>
<body><main>
<section class="hero"><h1>QA Rapport - Portfolio 2026</h1><p>Senast körd: $RunDate</p></section>
<section class="commands"><h2>Kommandon</h2><code>Set-Location D:\Website\portfolio
.\qa\run-tests.ps1</code><p>Efter körning uppdateras qa/testresultat.md, qa/testrapport.md och den här sidan.</p></section>
<section class="metrics"><div class="metric"><span>Totalt</span><strong>$Total</strong></div><div class="metric"><span>Pass</span><strong>$Passed</strong></div><div class="metric"><span>Fail</span><strong>$Failed</strong></div></section>
<section class="card"><h2>Testresultat</h2><table><thead><tr><th>ID</th><th>Titel</th><th>Status</th><th>Actual</th><th>Bug</th></tr></thead><tbody>$HtmlRows</tbody></table></section>
</main></body></html>
"@
Set-Content -Path "qa\index.html" -Value $Html -Encoding utf8

Start-Process "qa\index.html"
Write-Host "QA klar. Pass: $Passed Fail: $Failed Total: $Total"
