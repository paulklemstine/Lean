# Gravitational Factoring v9 — Research Artifacts

## Overview

Version 9 adds **73+ new formally verified theorems** (zero sorries) across 8 new Lean 4 source files, plus 3 Python demos, 3 SVG visualizations, and comprehensive documentation.

## Lean Source Files (all compile with zero sorry)

| File | Theorems | Key Results |
|------|----------|-------------|
| `PerfectNumberTheory.lean` | 10 | Euclid's construction, σ₁ multiplicativity, σ₁ bounds, no small odd perfect |
| `QuadraticReciprocity.lean` | 12 | Euler's criterion, Legendre multiplicativity, -1 QR ↔ mod 4, 2 QR ↔ mod 8, computational checks |
| `FibonacciAdvanced.lean` | 25 | Cassini's identity, sum formula, doubling, F(p) odd, Pisano period, WSS p≤97 |
| `CoppersmithMethod.lean` | 8 | Small root detection, Hensel lifting, modular cancellation, Fermat factoring |
| `HurwitzQuaternions.lean` | 10 | Four-square identity, Lagrange, sum of 2 squares, norm properties, examples |
| `WieferichTheory.lean` | 18 | Fermat quotient connection, 1093/3511 verified, 15 non-Wieferich checks |
| `EnergyLandscapeMorse.lean` | 12 | Sublevel sets, critical points, discrete derivatives, energy bounds |
| `SmoothNumberTheory.lean` | 12 | Complete B-smooth algebra, closure properties, monotonicity, existence |

## Python Demos

| File | Description |
|------|-------------|
| `demos/energy_landscape_3d.py` | Energy landscape visualization, smooth numbers, perfect numbers, Fibonacci, Wieferich, QR theory |
| `demos/fermat_coppersmith_demo.py` | Fermat factoring, Coppersmith small roots, Hensel lifting, energy-guided factoring |
| `demos/quaternion_factoring_demo.py` | Four-square representations, quaternion multiplication, norm multiplicativity |

## SVG Visualizations

| File | Description |
|------|-------------|
| `visuals/energy_landscape.svg` | Energy function E(60, x) with divisor markers |
| `visuals/theorem_dependency_graph.svg` | Dependency graph of 243+ theorems across all versions |
| `visuals/quadratic_residues.svg` | QR patterns mod 5, 7, 13 with verified theorem annotations |

## Documentation

| File | Description |
|------|-------------|
| `research_paper_v9.md` | Full research paper with all v9 results |
| `scientific_american_v9.md` | Popular science article for general audience |
| `answers_to_open_questions_v9.md` | 40 answered questions with proofs |
| `future_research_directions_v9.md` | 120 research directions with updated rankings |
| `applications_brainstorm_v9.md` | 15 application ideas across cryptography, education, and pure math |

## Quick Start

```bash
# Verify all Lean files compile
lake build FutureResearchDirections.OpenQuestions.v9.PerfectNumberTheory
lake build FutureResearchDirections.OpenQuestions.v9.QuadraticReciprocity
lake build FutureResearchDirections.OpenQuestions.v9.FibonacciAdvanced
lake build FutureResearchDirections.OpenQuestions.v9.CoppersmithMethod
lake build FutureResearchDirections.OpenQuestions.v9.HurwitzQuaternions
lake build FutureResearchDirections.OpenQuestions.v9.WieferichTheory
lake build FutureResearchDirections.OpenQuestions.v9.EnergyLandscapeMorse
lake build FutureResearchDirections.OpenQuestions.v9.SmoothNumberTheory

# Run Python demos
python3 demos/energy_landscape_3d.py
python3 demos/fermat_coppersmith_demo.py
python3 demos/quaternion_factoring_demo.py
```

## Cumulative Statistics

- **v1-v8**: 170+ verified theorems
- **v9**: 73+ new verified theorems  
- **Total**: 243+ verified theorems, 0 sorry, 14 Lean files, 12 Python demos, 6 SVG visualizations
