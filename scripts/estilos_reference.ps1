<#
.SYNOPSIS
  Aplica a una plantilla de docs-automation los estilos de los documentos hechos a mano
  (letra 10 pt, titulos de seccion blancos sobre rojo, codigo con fondo oscuro).
  Se ejecuta una sola vez o cada vez que se quiera cambiar el aspecto base.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\estilos_reference.ps1
  powershell -ExecutionPolicy Bypass -File scripts\estilos_reference.ps1 -Plantilla reference-pruebas.docx -Fuente Calibri
#>
param(
  [string]$Plantilla = 'reference.docx',  # Manual tecnico: Arial; Pruebas unitarias: Calibri
  [string]$Fuente = 'Arial'
)
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$reference = Join-Path $root "docs-automation\$Plantilla"

# Colores Word (BGR): R + G*256 + B*65536
$rojo   = 192        # C00000
$blanco = 16777215   # FFFFFF
$negro  = 0
$fondoCodigo = 1973790   # 1E1E1E
$textoCodigo = 13948116  # D4D4D4

function Get-OrAddStyle($doc, $name, $type) {
  try { return $doc.Styles.Item($name) } catch { return $doc.Styles.Add($name, $type) }
}

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0  # sin dialogos: evita que el script quede colgado
try {
  $doc = $word.Documents.Open($reference)

  foreach ($id in @(-1, -67)) {  # Normal, Body Text
    $s = $doc.Styles.Item($id)
    $s.Font.Name = $Fuente; $s.Font.Size = 10; $s.Font.Color = $negro
    $s.ParagraphFormat.SpaceBefore = 0; $s.ParagraphFormat.SpaceAfter = 6
  }

  $h2 = $doc.Styles.Item(-3)  # Heading 2: titulo de seccion
  $h2.Font.Name = $Fuente; $h2.Font.Size = 10; $h2.Font.Bold = $true; $h2.Font.Italic = $false
  $h2.Font.AllCaps = $true; $h2.Font.Color = $blanco
  $h2.ParagraphFormat.Alignment = 1
  $h2.ParagraphFormat.SpaceBefore = 3; $h2.ParagraphFormat.SpaceAfter = 3
  $h2.ParagraphFormat.Shading.BackgroundPatternColor = $rojo

  $h3 = $doc.Styles.Item(-4)  # Heading 3: nombre de archivo
  $h3.Font.Name = $Fuente; $h3.Font.Size = 11; $h3.Font.Bold = $true; $h3.Font.Italic = $false
  $h3.Font.Color = $negro
  $h3.ParagraphFormat.SpaceBefore = 10; $h3.ParagraphFormat.SpaceAfter = 4

  $code = Get-OrAddStyle $doc 'Source Code' 1
  $code.Font.Name = 'Consolas'; $code.Font.Size = 9; $code.Font.Color = $textoCodigo
  $code.ParagraphFormat.SpaceBefore = 0; $code.ParagraphFormat.SpaceAfter = 0
  $code.ParagraphFormat.LeftIndent = 6; $code.ParagraphFormat.RightIndent = 6
  $code.ParagraphFormat.Shading.BackgroundPatternColor = $fondoCodigo

  $verb = Get-OrAddStyle $doc 'Verbatim Char' 2
  $verb.Font.Name = 'Consolas'; $verb.Font.Size = 9

  $table = Get-OrAddStyle $doc 'Table' 3
  $table.Font.Name = $Fuente; $table.Font.Size = 9
  $table.ParagraphFormat.SpaceAfter = 0
  $table.Table.Borders.Enable = $true

  $doc.Save(); $doc.Close()
}
finally {
  $word.Quit()
  [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word)
}
Write-Output "Estilos aplicados a $reference"
