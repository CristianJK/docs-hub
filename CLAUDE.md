# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

`docs-hub` generates technical documentation (in **Spanish**) for features of other repositories. It contains no application code: the source being documented lives in a separate repo whose path the user provides.

**When the user asks to generate documentation (manual técnico, pruebas unitarias, etc.), follow `GENERAR_DOCUMENTACION.md` exactly** — it defines the questions to ask first, the git commands, writing rules and output location.

## Pipeline

1. `docs-automation/references/ListDocs.md` — index of document types: template path, output file name, status.
2. `docs-automation/templates/*.md` — Markdown templates with `{{placeholders}}` and YAML front matter: `documento:` (`manual-tecnico` | `pruebas-unitarias`) selects the Word template, `procedimiento:` fills `{{PROCEDIMIENTO}}` in the header (and cover), `fecha:` fills `{{FECHA}}` on the cover.
3. The agent writes the `.md` into `manuales/Feature_<n>/`.
4. `scripts/render.ps1 "<md>"` → Pandoc converts to `.docx` with the type's reference doc (`--resource-path` = repo root + md folder, so images use paths like `docs-automation/assets/mg-login.png`; `breezedark` code highlighting). Then Word (COM) inserts the cover (pruebas unitarias only), replaces placeholders, applies `scripts/formato_word.ps1` and exports the `.pdf`. Outputs land next to the `.md`.

| Type | Reference doc | Cover | Font | Hand-made source |
| --- | --- | --- | --- | --- |
| manual-tecnico | `reference.docx` | — | Arial | `07 - Feature *.docx` |
| pruebas-unitarias | `reference-pruebas.docx` | `portada-pruebas.docx` | Calibri | `Pruebas Unitarias Feature 430803.docx` |

Hand-made sources live in `E:\Drive\DeepBrain\Work\Area\Documentation\`. Reference/cover docs were derived from them (body removed, feature text/date replaced by placeholders — don't delete those).

`formato_word.ps1` reproduces the hand-made look: every `##` becomes a red (`C00000`) title bar — as the first row of the table when the section is only a table, otherwise as a 2×1 "box" table wrapping the whole section (rows may break across pages). Tables are recognized by their first cell: `Área Desarrollo` / `Área Desarrollo:` (info), `Ambiente QA`, `Fecha` (técnico revisions), `ID` (test cases), `Versión` (pruebas revisions). Template/prompt structure and these rules must stay in sync.

`scripts/estilos_reference.ps1 [-Plantilla <docx>] [-Fuente <font>]` (re)applies base styles (10 pt, Heading 2/3, `Source Code`, `Verbatim Char`, `Table`) to a reference doc.

`docs-automation/assets/mg-login.png` and `mg-inicio.png` are fixed screenshots (login + home of Módulo de Gestión) reused in every pruebas-unitarias document; feature-specific screenshots are left as `[INSERTAR CAPTURA: …]` markers for the user.

Requirements: Pandoc (falls back to `%LOCALAPPDATA%\Pandoc\pandoc.exe` if not on PATH) and Microsoft Word. Keep the `.ps1` files ASCII-only — Windows PowerShell 5.1 reads BOM-less scripts as ANSI (use `[char]0xC1` etc. for accented literals). If a render hangs, it's usually a hidden Word dialog or a stale `~$*.docx` lock file left by a killed run; stop only `WINWORD.EXE` processes started with `/Automation` (the user may have Word open).

`docs-automation/estilos.css` is from an earlier WeasyPrint-based approach and is not used by the current pipeline.
