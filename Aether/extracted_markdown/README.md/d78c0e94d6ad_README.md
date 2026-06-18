# The Triangle That Swallowed the Universe

**Author:** Paul Klemstine  
**ISBN:** 978-1-105-41110-6  
**Dedication:** *Soli Deo Gloria*

## Book Files

| File | Description |
|------|-------------|
| `main.tex` | Master LaTeX source (memoir class) |
| `main.pdf` | Compiled PDF (1292 pages) |
| `cover_casewrap.png` | Psychedelic casewrap cover image (4200×3600px, 300dpi) |
| `chapters/` | Converted LaTeX chapter files (Introduction + 16 Chapters + Conclusion) |
| `lean_sanitized/` | ASCII-sanitized Lean 4 source files for appendix inclusion |
| `convert_md_to_tex.py` | Markdown-to-LaTeX conversion script |

## Building

```bash
cd book
pdflatex -interaction=nonstopmode main.tex
makeindex main.idx
pdflatex -interaction=nonstopmode main.tex
pdflatex -interaction=nonstopmode main.tex
```

Three passes are needed for proper cross-references, table of contents, and index.

## Structure

- **Front Matter:** Half title, full title page, copyright page (with ISBN), dedication ("Soli Deo Gloria"), Table of Contents
- **Main Matter:** Introduction + 16 Chapters + Conclusion, with full-color illustrations
- **Back Matter:** Appendix (16 Lean 4 formalization files with syntax highlighting), Index, ISBN barcode page

## Design

- **Document class:** `memoir` (premium wide-margin aesthetic)
- **Font:** Palatino (via `mathpazo`)
- **Code listings:** `listings` package with custom Lean 4 syntax highlighting
- **Typography:** `microtype` for optical margin alignment, elegant chapter heads with gold accents
