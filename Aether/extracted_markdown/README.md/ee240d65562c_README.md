# 🌀 The Oracle's Compendium of Mathematical Truth

**A Psychedelic Journey Through the Foundations of Mathematics**

---

## 📖 Overview

A complete mathematics textbook created by the **Harmonic Collective** — a team of six mathematical personas, each contributing their domain expertise:

| Team Member | Chapters | Domain |
|---|---|---|
| **The Algebraist** | 1–2 | Linear Algebra, Abstract Algebra |
| **The Analyst** | 3–4 | Real Analysis, Complex Analysis |
| **The Geometer** | 5 | Euclidean & Differential Geometry |
| **The Probabilist** | 6 | Probability Theory |
| **The Topologist** | 7 | Point-Set & Algebraic Topology |
| **The Oracle** | All | Interstitial wisdom, verification, iteration |

## 📚 Chapters & Key Theorems

### Chapter 1: Linear Algebra
- Vector Spaces, Linear Independence, Bases
- **Rank–Nullity Theorem** (with diagram)
- **Spectral Theorem** for real symmetric matrices
- **Cayley–Hamilton Theorem**
- **Jordan Normal Form**

### Chapter 2: Abstract Algebra
- Groups, Rings, Fields
- **Lagrange's Theorem** (with Cayley graph of S₃)
- **First Isomorphism Theorem** (with diagram)
- **Fundamental Theorem of Algebra**
- **Eisenstein's Criterion**
- **Fundamental Theorem of Galois Theory** (with lattice diagram)
- **Abel–Ruffini Theorem**

### Chapter 3: Real Analysis
- Sequences, Limits, Continuity
- **Bolzano–Weierstrass Theorem**
- **Intermediate Value Theorem** (with graph)
- **Extreme Value Theorem**
- **Mean Value Theorem** (with tangent/secant diagram)
- **Taylor's Theorem**
- **Fundamental Theorem of Calculus** (with area diagram)

### Chapter 4: Complex Analysis
- Holomorphic Functions, Cauchy–Riemann Equations
- **Cauchy's Integral Theorem**
- **Cauchy's Integral Formula** (with contour diagram)
- **Residue Theorem**
- **Liouville's Theorem**
- **Maximum Modulus Principle** (with 3D surface plot)

### Chapter 5: Geometry
- **Pythagorean Theorem** (with squares-on-sides diagram)
- **Euler's Formula** V − E + F = 2 (with Platonic solids)
- **Gauss–Bonnet Theorem** (with curvature visualization)
- **Isoperimetric Inequality**

### Chapter 6: Probability Theory
- Probability Spaces, Random Variables
- **Bayes' Theorem** (with Venn diagram)
- **Law of Large Numbers** (Strong)
- **Central Limit Theorem** (with convergence plot)
- **Chebyshev's Inequality**
- **Jensen's Inequality**

### Chapter 7: Topology
- Topological Spaces, Homeomorphisms
- **Heine–Borel Theorem**
- **Tychonoff's Theorem**
- π₁(S¹) ≅ ℤ (with winding number diagram)
- **Brouwer Fixed-Point Theorem** (with disk diagram)
- **Borsuk–Ulam Theorem**
- **Classification of Compact Surfaces** (genus diagram)

## 🎨 Visual Features

- **Psychedelic color palette**: Cosmic Purple, Electric Pink, Acid Green, Neon Cyan, Solar Orange, Radiant Gold, and more
- **30+ TikZ diagrams and graphs** embedded throughout
- **Colorful theorem boxes** with drop shadows and gradient accents
- **Oracle interludes** — cosmic-themed commentary boxes with gold borders on black backgrounds
- **3D surface plots** (pgfplots) for complex analysis
- **Cayley graphs**, **lattice diagrams**, **Venn diagrams**, and **geometric constructions**
- **Psychedelic title page** with spirograph, fractal dots, and concentric rings
- **Closing mandala** decoration

## 🔨 Building the PDF

Requires a LaTeX distribution with TikZ, pgfplots, and tcolorbox:

```bash
cd textbook
./build.sh
# or manually:
pdflatex main.tex && pdflatex main.tex
```

The second pass resolves cross-references for the theorem index.

### Prerequisites
- TeX Live, MiKTeX, or MacTeX
- Packages: `tikz`, `pgfplots`, `tcolorbox`, `fancyhdr`, `titlesec`, `hyperref`
  (all standard in modern TeX distributions)

## 🔮 The Oracle's Process

The Oracle was consulted at each iteration:
1. **Iteration 1**: Structure and theorem selection across all seven chapters
2. **Iteration 2**: Diagram design and psychedelic color palette
3. **Iteration 3**: Cross-referencing, theorem index, and consistency verification
4. **Final verification**: All 30+ theorems checked, all diagrams rendered, all Oracle interludes placed

*"Mathematics, rightly viewed, possesses not only truth, but supreme beauty." — Bertrand Russell*
