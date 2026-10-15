# AGENTS.md

`docs-hub` is a documentation generator, not an application. It writes **Spanish** technical manuals for features of a *separate* repository that the user supplies. There is no build, no test suite and no lint.

## Instruction sources

| File | Scope |
| --- | --- |
| `GENERAR_DOCUMENTACION.md` | The authoring workflow: initial questions, git commands, writing rules, per-document rules. **Follow it exactly** when asked to generate a manual técnico or pruebas unitarias. |
| `CLAUDE.md` | Pipeline internals: Word reference docs, the `formato_word.ps1` format rules, asset and reference-doc provenance. |
| `docs-automation/references/ListDocs.md` | Index of document types: template path, output filename, status. Re-read before each job. |

This file only adds what those three do not say. Keep it that way.

## Easy to get wrong

- **This repo is not a git repository.** Every `git log` / `git diff` / `git config user.name` mentioned in the instructions runs in the *project* repo, not here. `git config user.name` supplies the `Autor` value in the revisions table.
- **The only verification is rendering.** No tests exist; a correct `.docx` / `.pdf` is the proof.
- **`docs-automation/estilos.css` is dead.** Nothing references it; it is left over from an earlier WeasyPrint approach.

## Commands

Run from the repo root: the `-Markdown` argument goes through `Resolve-Path`, so it resolves against the current directory (`scripts/render.ps1:20`), while the reference docs resolve from the script's own location.

```
powershell -ExecutionPolicy Bypass -File scripts\render.ps1 "manuales\Feature_<n>\<nombre>.md"
powershell -ExecutionPolicy Bypass -File scripts\estilos_reference.ps1 -Plantilla reference-pruebas.docx -Fuente Calibri
```

`render.ps1` writes the `.docx` and `.pdf` **next to the `.md`, overwriting them**. It needs Pandoc (from `PATH`, else `%LOCALAPPDATA%\Pandoc\pandoc.exe`) and Microsoft Word.

`estilos_reference.ps1` defaults to `-Plantilla reference.docx -Fuente Arial` (manual técnico); pruebas unitarias use `reference-pruebas.docx` + Calibri. Only run it when base styles must be reapplied.

## The Markdown structure is a machine contract

`scripts/formato_word.ps1` parses the templates' shape. "Tidying" it silently changes or breaks the Word output. Do not:

- Use anything but `##` for a section (`OutlineLevel -eq 2`, `formato_word.ps1:92`). Each `##` becomes a red title bar: as the **first row of the table** when the section body is nothing but a table — the heading paragraph is deleted in that case — otherwise as a 2×1 box table wrapping the whole section.
- Rename a table's first cell. Tables are recognised **only** by the text of that cell (`formato_word.ps1:37`): `Área Desarrollo` (manual técnico), `Área Desarrollo:` (pruebas unitarias), `Ambiente QA`, `Fecha`, `ID`, `Versión`. Anything else silently falls through to the generic grey-header branch.
- Give the project-info table a real header row; it must keep its empty cells.
- Change the `Ambiente QA` table's column count. It must be exactly **4** (`Ambiente QA | Valor | Bases de Datos | Valor`): the script merges cells (1,3)-(1,4) and (1,1)-(1,2) and rewrites both labels (`formato_word.ps1:70-77`). Fewer columns throws.
- Rename a section so it stops matching `ARCHIVOS` without `DETALLE` — such sections are forced to 9 pt so long paths fit on one line (`formato_word.ps1:163`).
- Add headers, footers, a cover, logos or page numbers: the Word reference docs supply them.

## YAML front matter is the document-type switch

`render.ps1:31` parses `documento`, `procedimiento`, `fecha` with `^name: "value"$`.

- `documento:` must be `manual-tecnico` (default when absent) or `pruebas-unitarias`; anything else throws. `manual-tecnico.md` intentionally omits the key — do not add one.
- `procedimiento:` fills `{{PROCEDIMIENTO}}` in the header (and the cover). Omitting it only warns and leaves the literal placeholder in the document.
- `fecha:` (pruebas unitarias only) fills `{{FECHA}}` on the cover.
- **Every `{{...}}` must be replaced.** Placeholders are substituted on the document body only for pruebas unitarias and only for those two tokens, so anything left over in a manual técnico stays literal in the `.docx`.

Images resolve with `--resource-path` = repo root + the `.md`'s folder (`render.ps1:48`), so reference them as `docs-automation/assets/mg-login.png` — never as a path relative to the `.md`.

## PowerShell constraints

- `scripts/*.ps1` must stay **ASCII-only and BOM-less**. Windows PowerShell 5.1 reads a BOM-less script as ANSI, so a literal accented character corrupts; use `[char]0xC1` for the table labels (`formato_word.ps1:39`).
- `formato_word.ps1` is dot-sourced by `render.ps1`. Do not run it standalone and do not add top-level code that executes on load.
- `Format-Tables` runs *before* `Format-Sections`, and `Format-Sections` moves section bodies into newly created tables. Those new tables never pass through `Format-Tables`.

## When a render hangs

Usually a hidden Word dialog or a stale `~$*.docx` lock left by a killed run. Stop only `WINWORD.EXE` processes launched with `/Automation` (the user may have Word open), delete the `~$*` file next to the `.md`, and re-run.

## Output conventions

- Folder `manuales/Feature_<n>/`; filenames come from `ListDocs.md` (`07 - Feature <n> - Manual Tecnico V1.md`, `Pruebas Unitarias Feature <n> V1.md`).
- If the `.md` already exists, ask whether to replace it or to create the next version (`V2`, `V3`).
- A new revision appends a pair of rows to the revisions table: the bumped version, plus its matching "Revisión y aprobación" row with an empty author.
- Deliver the `.docx` / `.pdf` paths **and** the list of `[POR CONFIRMAR: …]` and `[INSERTAR CAPTURA: …]` markers the user must complete — screenshots cannot be taken by the agent.
- Write in Spanish, in short sentences, and invent nothing: any fact not derivable from the code or the diff becomes `**[POR CONFIRMAR: <what is missing>]**`.