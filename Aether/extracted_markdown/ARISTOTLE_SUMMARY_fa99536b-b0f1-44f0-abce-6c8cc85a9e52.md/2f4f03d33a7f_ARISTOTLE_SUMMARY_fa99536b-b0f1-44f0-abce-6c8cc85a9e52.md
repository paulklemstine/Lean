# Summary of changes
## Beautiful Colorful PDF Book Generated 🎨

I've assembled your markdown chapters into a stunning **99-page PDF book** with a dark-mode aesthetic and vibrant psychedelic visuals.

### Output File
- **`TheArchitectureOfComputation.pdf`** (749 KB) — the complete book

### What's Inside

**Cover Page** — A deep purple-to-magenta gradient background with a psychedelic mandala ornament centered around a golden λ symbol, with the book title in luminous violet.

**Table of Contents** — Styled with the book's preface and full chapter listing.

**Part Divider Pages** — Three color-coded part pages (blue for Foundations, pink for Decidability, gold for Complexity) plus an Appendices divider.

**18 Embedded SVG Diagrams** — Each hand-crafted with glowing neon colors, gradients, and rich detail:

| Chapter | Diagrams |
|---------|----------|
| Ch 2 (Finite Automata) | DFA state machine with glowing nodes, NFA→DFA subset construction, Pumping lemma string decomposition |
| Ch 3 (Context-Free) | Parse tree with gold/green nodes, Chomsky hierarchy nested ellipses |
| Ch 4 (Lambda Calculus) | β-reduction chain with Church numerals |
| Ch 5 (Turing Machines) | Full tape diagram with read/write head and state controller |
| Ch 6 (Church-Turing) | Three-road convergence diagram showing λ-calc, TMs, and μ-recursive functions |
| Ch 7 (Halting) | Cantor diagonalization grid with red diagonal highlighting |
| Ch 8 (Reducibility) | Web of many-one reductions between undecidable problems |
| Ch 9 (Rice's Theorem) | Property P vs ¬P with undecidable boundary |
| Ch 10 (Arithmetic Hierarchy) | Σ/Π tower diagram |
| Ch 11 (P and NP) | Nested complexity class ovals (P ⊂ NP ⊂ PSPACE ⊂ EXPTIME) |
| Ch 12 (Space) | Linear chain L ⊆ NL ⊆ P ⊆ PSPACE ⊆ EXP with theorem annotations |
| Ch 13 (Interactive Proofs) | Prover-Verifier interaction protocol diagram |
| Ch 14 (Quantum) | Bloch sphere + quantum teleportation circuit |
| Ch 15 (Outer Shores) | Hypercomputation spectrum |

**17 Psychedelic Rainbow Separators** — Gradient dividers between chapters in rotating color palettes.

**Rich Typography** — Purple headings, pink emphasis, gold bold text, cyan code blocks with violet borders, gradient-bordered tables with alternating dark rows.

### Build Script
- **`build_book.py`** — Self-contained Python script. Run `python3 build_book.py` to regenerate the PDF anytime. Requires `weasyprint` and `markdown` packages.
- **`book.html`** — Intermediate HTML file also saved for reference.