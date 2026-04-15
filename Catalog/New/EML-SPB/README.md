# SPB-EML Research Outputs

## Machine-Verified Theorems and Research Documents

This directory contains the research outputs from a comprehensive exploration of the
Stereographic Projection Bridge (SPB) and Exponential-Multiplicative-Logarithmic (EML)
framework. All mathematical results are machine-verified in Lean 4.28.0 with Mathlib.

---

## Lean 4 Formalization Files

### EML/SPBNewTheorems.lean — 28 Theorems, 0 Sorry
Key new results solving open problems:
- Cross-ratio invariance (SPB is a Möbius transformation)
- Elliptic classification (no real fixed points)
- Projective SPB (division-free formulation, norm multiplicativity)
- Infinitesimal generator V(x) = 1 + x²
- Brahmagupta–Fibonacci identity via SPB
- Cocycle geometric series and 2-cocycle property
- Division algebra obstruction (d=1 case, complex numbers)
- Hyperbolic SPB contraction (Einstein velocity closure)
- Cauchy pullback identity
- Wick rotation duality (circular ↔ hyperbolic)
- Pythagorean triple generation
- SPB matrix determinant multiplicativity (including products)

### EML/SPBAdvancedOpenProblems.lean — 30+ Theorems, 0 Sorry
Additional advanced results:
- Projective SPB associativity (division-free group law verified)
- Projective SPB inverse
- tanh addition = hyperbolic SPB (Einstein velocity addition from tanh)
- Hyperbolic SPB associativity
- SPB derivative theory (both arguments, ratio formula)
- arctan(spb(x,y)) = arctan(x) + arctan(y) (fundamental identity)
- arctan(1) = π/4
- Machin's formula: 4·arctan(1/5) − arctan(1/239) = π/4
- SPB functional equations (identity, inverse, associativity)
- spb(√3, √3) = −√3 (special value)
- SPB distance metric (self, symmetry, translation invariance)
- SPB double-angle leading term

---

## Research Documents

### 1. SPB_EML_ResearchPaper.md
Technical research paper presenting the 28+ new theorems with full mathematical
context, proofs sketches, and significance analysis. Organized by topic:
cross-ratio invariance, elliptic classification, projective SPB, infinitesimal
generator, Brahmagupta–Fibonacci, cocycle theory, division algebra obstruction.

### 2. SPB_ScientificAmerican.md
Popular science article explaining SPB to a general educated audience. Covers
the "three discoveries" of SPB (trigonometry, stereographic projection, relativity),
the Cauchy distribution connection, hardware applications, and the division
algebra mystery.

### 3. SPB_FutureDirections.md
Comprehensive updated research roadmap with:
- 4 tiers (A–D) of research directions ranked by feasibility and impact
- 6 Tier A (immediate) priorities
- 5 Tier B (next phase) directions
- 4 Tier C (strategic bets)
- 5 Tier D (long-term vision)
- Dependency graph
- Resource estimates
- Team structure recommendations

### 4. SPB_Applications_Brainstorm.md
50 application ideas across 10 domains (ML, hardware, crypto, signal processing,
controls, pure math, physics, graphics, communications, data science) with
feasibility and impact ratings.

---

## Theorem Count Summary

| File | Theorems | Sorries | Status |
|------|:---:|:---:|:---:|
| EML/SPBNewTheorems.lean | 28 | 0 | ✅ Complete |
| EML/SPBAdvancedOpenProblems.lean | 30+ | 0 | ✅ Complete |
| **Total new** | **58+** | **0** | ✅ |

All axioms are standard: propext, Classical.choice, Quot.sound.

---

*April 2026*
