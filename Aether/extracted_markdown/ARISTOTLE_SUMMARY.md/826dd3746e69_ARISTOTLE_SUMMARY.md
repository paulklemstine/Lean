# Summary of changes for run 8102d73e-8733-4b82-9330-d552868c5d69
## Created: *The Eternal Braid: Pythagoras, Lorentz, and the Architecture of Proof*

A 126-page popular mathematics book in the style of Martin Gardner and Douglas Hofstadter's *Gödel, Escher, Bach*, authored by Paul Klemstine, dedicated *Soli Deo Gloria*.

### Book Structure

**LaTeX source:** `book/main.tex`  
**PDF output:** `book/main.pdf` (126 pages, ~1 MB)  
**Appendix generator:** `book/appendix_lean_files.tex`

### Contents

- **Prelude: The Margin and the Machine** — Sets the stage by connecting Fermat's margin note to machine-verified proof
- **Part I: The Tree of Triples** (Chapters 1–5)
  - Ch 1: The Berggren–Lorentz Correspondence — Null cones, Lorentz group, the tree of all Pythagorean triples
  - Ch 2: The Lattice–Tree Correspondence — Tree descent = Euclidean algorithm
  - Ch 3: Hyperbolic Shortcuts — Path composition, Poincaré disk, Chebyshev recurrences
  - Ch 4: Three Roads from Pythagoras — Euler's method, Gaussian composition, tree sieve
  - Ch 5: Publication-Quality Proofs — Eight main theorems with dependency graph
- **Part II: The Channels of Number** (Chapters 6–8)
  - Ch 6: Higher k-Tuple Factoring — Multi-channel factoring via Pythagorean k-tuples
  - Ch 7: Quantum Grover Acceleration — Grover's algorithm applied to tree search
  - Ch 8: Complexity Bounds, Proven — Machine-verified Θ(√N) complexity
- **Part III: The Algebraic Cosmos** (Chapters 9–11)
  - Ch 9: The Cayley–Dickson Hierarchy — ℝ → ℂ → ℍ → 𝕆 → Sedenions, what is lost at each step
  - Ch 10: Fermat's Last Theorem — Cases n=3,4 machine-verified; why no margin proof exists
  - Ch 11: Congruence of Squares — Foundation of all modern factoring algorithms
- **Part IV: The Frontiers** (Chapters 12–16)
  - Ch 12: Quadruple Factor Theory — Shared Factor Bridge theorem
  - Ch 13: GCD Cascades — Multi-representation factor extraction
  - Ch 14: Pythagorean Tree Factoring Core — The complete algorithm
  - Ch 15: Tropical Geometry Foundations — Min-plus algebra, Bellman equation, Newton polygons
  - Ch 16: The Lorentz Group Structure — Hyperbolic tiling, semiprime counting theorem
- **Coda: The Eternal Braid** — Synthesis and reflection
- **Appendix A:** Complete Lean 4 source code for all 16 files

### Illustrations (TikZ)

Every chapter includes scientific/illustrative TikZ figures:
- Null cone of the Lorentz form with lattice points
- Berggren ternary tree diagram
- Euclidean algorithm ↔ Berggren descent correspondence diagram
- Poincaré disk with tree tiling and hyperbolic shortcuts
- Two-representation factoring flowchart (Euler's method)
- Theorem dependency graph
- Multi-channel factoring star diagram
- Quantum Grover circuit diagram
- Complexity comparison plot (√N vs N^{1/4})
- Cayley–Dickson tower with gains/losses at each level
- FLT historical timeline (1637–2024)
- Congruence of squares → factoring pipeline
- GCD cascade network diagram
- Descent termination visualization
- Classical vs tropical arithmetic comparison + tropical line
- Hyperboloid with tree tiling
- The Eternal Braid (three braided strands)

### How to Rebuild

```bash
cd book
pdflatex -interaction=nonstopmode main.tex  # run 2-3 times for cross-refs
```

The original 16 Lean files are unchanged and included verbatim in the appendix.