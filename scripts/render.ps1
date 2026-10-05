<#
.SYNOPSIS
  Convierte un documento .md en .docx (con la plantilla de estilos de su tipo) y exporta el PDF con Word.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\render.ps1 "manuales\Feature_430803\07 - Feature 430803 - Manual Tecnico V1.md"
.NOTES
  Requiere Pandoc y Microsoft Word instalados. El .docx y el .pdf quedan junto al .md.
  Bloque YAML del .md:
    documento:     manual-tecnico (por defecto) | pruebas-unitarias
    procedimiento: reemplaza {{PROCEDIMIENTO}} en el encabezado (y en la portada)
    fecha:         reemplaza {{FECHA}} en la portada (solo pruebas-unitarias)
  Las rutas de imagenes se resuelven desde la raiz de docs-hub (ej. docs-automation/assets/mg-login.png).
#>
param(
  [Parameter(Mandatory = $true)][string]$Markdown
)
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$md = (Resolve-Path $Markdown).Path
$base = [IO.Path]::ChangeExtension($md, $null).TrimEnd('.')
$docx = "$base.docx"
$pdf = "$base.pdf"

$pandoc = (Get-Command pandoc -ErrorAction SilentlyContinue).Source
if (-not $pandoc) { $pandoc = Join-Path $env:LOCALAPPDATA 'Pandoc\pandoc.exe' }
if (-not (Test-Path $pandoc)) { throw 'Pandoc no esta instalado (winget install JohnMacFarlane.Pandoc).' }

$content = Get-Content -Path $md -Encoding UTF8 -Raw
function Get-YamlValue($name) {
  if ($content -match "(?m)^${name}:\s*`"?(.*?)`"?\s*$") { return $Matches[1] }
  return ''
}
$documento = Get-YamlValue 'documento'
if (-not $documento) { $documento = 'manual-tecnico' }
$procedimiento = Get-YamlValue 'procedimiento'
$fecha = Get-YamlValue 'fecha'
if (-not $procedimiento) { Write-Warning "No se encontro 'procedimiento' en el YAML; el encabezado quedara con {{PROCEDIMIENTO}}." }

switch ($documento) {
  'manual-tecnico'    { $reference = 'reference.docx'; $portada = $null }
  'pruebas-unitarias' { $reference = 'reference-pruebas.docx'; $portada = 'portada-pruebas.docx' }
  default { throw "Tipo de documento no soportado: '$documento'" }
}
$reference = Join-Path $root "docs-automation\$reference"
if ($portada) { $portada = Join-Path $root "docs-automation\$portada" }

$resourcePath = "$root;$(Split-Path -Parent $md)"
& $pandoc $md -f markdown -t docx --reference-doc "$reference" --resource-path "$resourcePath" --syntax-highlighting=breezedark -o "$docx"
if ($LASTEXITCODE -ne 0) { throw "Pandoc fallo con codigo $LASTEXITCODE" }

. (Join-Path $PSScriptRoot 'formato_word.ps1')

function Set-Placeholder($range, $placeholder, $value) {
  $null = $range.Find.Execute($placeholder, $false, $false, $false, $false, $false, $true, 0, $false, $value, 2)
}

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0  # sin dialogos: evita que el script quede colgado
try {
  $doc = $word.Documents.Open($docx)

  if ($portada) {
    # Portada + salto de pagina antes del contenido
    $doc.Range(0, 0).InsertParagraphBefore()
    $doc.Range(0, 0).Paragraphs.Item(1).Range.Style = $doc.Styles.Item(-1)
    $doc.Range(0, 0).InsertBreak(7)  # 7 = wdPageBreak
    $doc.Range(0, 0).InsertFile($portada)
    if ($procedimiento) { Set-Placeholder $doc.Content '{{PROCEDIMIENTO}}' $procedimiento }
    if ($fecha) { Set-Placeholder $doc.Content '{{FECHA}}' $fecha }
  }

  if ($procedimiento) {
    foreach ($section in $doc.Sections) {
      foreach ($i in 1..3) {
        $header = $section.Headers.Item($i)
        if (-not $header.Exists) { continue }
        Set-Placeholder $header.Range '{{PROCEDIMIENTO}}' $procedimiento
        foreach ($shape in $header.Shapes) {
          if ($shape.TextFrame.HasText) { Set-Placeholder $shape.TextFrame.TextRange '{{PROCEDIMIENTO}}' $procedimiento }
        }
      }
    }
  }

  Format-Tables $doc
  Format-Sections $doc
  $doc.Save()
  $doc.ExportAsFixedFormat($pdf, 17)  # 17 = wdExportFormatPDF
  $doc.Close($false)
}
finally {
  $word.Quit()
  [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word)
}

Write-Output "DOCX: $docx"
Write-Output "PDF:  $pdf"
