# Funciones de formato que render.ps1 aplica al .docx generado por Pandoc (via Word COM),
# para replicar el aspecto de los manuales hechos a mano. Se carga con: . "$PSScriptRoot\formato_word.ps1"

# Colores Word (BGR): R + G*256 + B*65536
$rojo = 192            # C00000
$gris = 14277081       # D9D9D9
$azulClaro = 15986394  # DAEEF3
$azul = 10191921       # 31849B
$blanco = 16777215
$azulObs = 13929812    # 548DD4 (observaciones en pruebas unitarias)
$wdStyleNormal = -1

function Set-CellHeader($cell, $color, $fontColor) {
  $cell.Shading.BackgroundPatternColor = $color
  $cell.Range.Font.Bold = $true
  $cell.Range.Font.Color = $fontColor
  $cell.Range.ParagraphFormat.Alignment = 1
}

function Set-TitleCell($cell, $title) {
  $cell.Range.Text = $title
  $cell.Range.Style = $wdStyleNormal
  Set-CellHeader $cell $rojo $blanco
  $cell.Range.Font.Size = 10
  $cell.Range.Font.AllCaps = $true
  $cell.Range.ParagraphFormat.SpaceBefore = 2
  $cell.Range.ParagraphFormat.SpaceAfter = 2
}

# Formato propio de cada tabla, segun el texto de su primera celda.
function Format-Tables($doc) {
  foreach ($t in $doc.Tables) {
    $t.Rows.Alignment = 1
    $t.PreferredWidthType = 2; $t.PreferredWidth = 100
    $t.Borders.Enable = $true
    $t.Range.ParagraphFormat.SpaceAfter = 0
    $first = $t.Cell(1, 1).Range.Text.Trim([char]13, [char]7, ' ')

    if ($t.Columns.Count -eq 2 -and $first -eq [string]::Concat([char]0xC1, 'rea Desarrollo')) {
      # Informacion del proyecto: etiquetas en gris, negrita, alineadas a la derecha
      $t.Columns.Item(1).PreferredWidthType = 2; $t.Columns.Item(1).PreferredWidth = 25
      foreach ($r in 1..$t.Rows.Count) {
        $c = $t.Cell($r, 1); $c.Shading.BackgroundPatternColor = $gris
        $c.Range.Font.Bold = $true; $c.Range.ParagraphFormat.Alignment = 2
      }
    }
    elseif ($t.Columns.Count -eq 2 -and $first -eq [string]::Concat([char]0xC1, 'rea Desarrollo:')) {
      # Pruebas unitarias - informacion del proyecto: etiquetas en negrita, sin fondo
      $t.Columns.Item(1).PreferredWidthType = 2; $t.Columns.Item(1).PreferredWidth = 30
      foreach ($r in 1..$t.Rows.Count) { $t.Cell($r, 1).Range.Font.Bold = $true }
    }
    elseif ($first -eq 'ID') {
      # Pruebas unitarias - casos y escenarios: encabezado en negrita, ID centrado, observaciones en azul
      foreach ($c in 1..$t.Columns.Count) { $t.Cell(1, $c).Range.Font.Bold = $true }
      if ($t.Columns.Count -eq 4) {
        # Anchos como en la guia: ID angosto, escenario mas ancho
        $anchos = @(6, 38, 28, 28)
        foreach ($c in 1..4) { $t.Columns.Item($c).PreferredWidthType = 2; $t.Columns.Item($c).PreferredWidth = $anchos[$c - 1] }
      }
      foreach ($r in 1..$t.Rows.Count) {
        $t.Cell($r, 1).Range.ParagraphFormat.Alignment = 1
        if ($r -gt 1) { $t.Cell($r, $t.Columns.Count).Range.Font.Color = $azulObs }
      }
    }
    elseif ($first -eq [string]::Concat('Versi', [char]0xF3, 'n')) {
      # Pruebas unitarias - revisiones y aprobaciones: encabezado en negrita y todo centrado
      foreach ($c in 1..$t.Columns.Count) { $t.Cell(1, $c).Range.Font.Bold = $true }
      $t.Range.ParagraphFormat.Alignment = 1
    }
    elseif ($first -eq 'Ambiente QA') {
      # Ambientes: encabezado combinado por bloque (QA / Bases de Datos) en azul
      $t.Cell(1, 3).Merge($t.Cell(1, 4))
      $t.Cell(1, 1).Merge($t.Cell(1, 2))
      $t.Cell(1, 1).Range.Text = 'Ambiente QA'
      $t.Cell(1, 2).Range.Text = 'Bases de Datos'
      foreach ($c in 1..2) { Set-CellHeader $t.Cell(1, $c) $azulClaro $azul }
    }
    else {
      # Tablas con encabezado (ej. Revisiones y aprobaciones): encabezado gris
      foreach ($c in 1..$t.Columns.Count) { Set-CellHeader $t.Cell(1, $c) $gris 0 }
      if ($first -eq 'Fecha') { $t.Range.ParagraphFormat.Alignment = 1 }
    }
    if ($first -ne 'ID' -and ($first -eq 'Ambiente QA' -or $t.Columns.Count -gt 2)) {
      # Columnas segun su contenido y luego al ancho de pagina: evita cortes como "Versi-on" o la IP
      $t.AutoFitBehavior(1); $t.AutoFitBehavior(2)
    }
  }
}

function Get-SectionStarts($doc) {
  $starts = @()
  foreach ($p in $doc.Paragraphs) { if ($p.OutlineLevel -eq 2) { $starts += $p.Range.Start } }
  return , $starts
}

# Cada titulo ## queda como barra roja: si la seccion es solo una tabla, el titulo pasa a ser
# su primera fila; si no, la seccion completa se encierra en un recuadro con el titulo arriba.
function Format-Sections($doc) {
  # Parrafo vacio antes de cada titulo (excepto el primero): separa los recuadros y evita que Word los una
  $heads = Get-SectionStarts $doc
  for ($k = $heads.Count - 1; $k -ge 1; $k--) {
    $doc.Range($heads[$k], $heads[$k]).InsertParagraphBefore()
    $doc.Range($heads[$k], $heads[$k]).Paragraphs.Item(1).Range.Style = $wdStyleNormal
  }

  $heads = Get-SectionStarts $doc
  for ($k = $heads.Count - 1; $k -ge 0; $k--) {
    $head = $doc.Range($heads[$k], $heads[$k]).Paragraphs.Item(1).Range
    $title = $head.Text.Trim()
    Write-Verbose "Seccion '$title'"
    $bodyStart = $head.End
    # El cuerpo excluye el ultimo parrafo (separador o final del documento)
    $bodyEnd = if ($k + 1 -lt $heads.Count) { $heads[$k + 1] - 1 } else { $doc.Content.End - 1 }
    if ($bodyEnd -le $bodyStart) { continue }
    $body = $doc.Range($bodyStart, $bodyEnd)
    if (([string]$body.Text).Trim().Length -eq 0) { continue }

    $onlyTable = $false
    if ($body.Tables.Count -eq 1) {
      $tbl = $body.Tables.Item(1).Range
      $outside = [string]$doc.Range($bodyStart, $tbl.Start).Text + [string]$doc.Range($tbl.End, $bodyEnd).Text
      $onlyTable = ($outside.Trim().Length -eq 0)
    }

    if ($onlyTable) {
      $t = $body.Tables.Item(1)
      $null = $t.Rows.Add($t.Rows.Item(1))
      $row = $t.Rows.Item(1)
      if ($row.Cells.Count -gt 1) { $row.Cells.Merge() }
      Set-TitleCell $t.Cell(1, 1) $title
      $null = $head.Delete()
      continue
    }

    # Recuadro: el parrafo del titulo se reemplaza por una tabla 2x1 y el cuerpo se mueve a la segunda fila
    $bodyLength = $bodyEnd - $bodyStart
    Write-Verbose "  recuadro, cuerpo $bodyStart-$bodyEnd"
    $head.Style = $wdStyleNormal
    $titleRange = $doc.Range($head.Start, $head.End - 1)
    $titleRange.Text = ''
    $box = $doc.Tables.Add($doc.Range($heads[$k], $heads[$k]), 2, 1)
    $box.Borders.Enable = $true
    $box.Rows.Alignment = 1
    $box.PreferredWidthType = 2; $box.PreferredWidth = 100
    Set-TitleCell $box.Cell(1, 1) $title

    Write-Verbose "  tabla creada $($box.Range.Start)-$($box.Range.End)"
    # $body es un Range vivo: Word ajusta su posicion al insertar la tabla antes de el
    $target = $box.Cell(2, 1).Range
    $target.End = $target.End - 1
    $target.FormattedText = $body.FormattedText
    # Word no borra rangos que cortan tablas: primero las tablas del original, luego el texto
    for ($i = $body.Tables.Count; $i -ge 1; $i--) { $body.Tables.Item($i).Delete() }
    $null = $body.Delete()

    # El contenido puede partirse entre paginas (si no, Word deja la barra sola y pasa todo a la siguiente
    # pagina); la barra de titulo se mantiene unida a la primera linea del contenido
    $box.Rows.AllowBreakAcrossPages = $true
    $box.Range.ParagraphFormat.KeepWithNext = $false
    $box.Cell(1, 1).Range.ParagraphFormat.KeepWithNext = $true

    # Listado de archivos en 9 pt para que las rutas largas quepan en una linea
    if ($title -match 'ARCHIVOS' -and $title -notmatch 'DETALLE') { $box.Cell(2, 1).Range.Font.Size = 9 }
  }

  # Los parrafos de titulo que Word no deja borrar (antes de una tabla) quedan vacios: se pasan a Normal
  $normal = $doc.Styles.Item($wdStyleNormal)
  foreach ($p in $doc.Paragraphs) {
    if ($p.OutlineLevel -eq 2 -and -not $p.Range.Information(12)) { $p.Style = $normal }  # 12 = wdWithInTable
  }
}
