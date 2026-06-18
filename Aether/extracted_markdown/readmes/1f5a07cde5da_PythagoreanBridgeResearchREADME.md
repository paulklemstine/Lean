# EML–Pythagorean Bridge Research Package

## Overview

This research package explores the deep connection between the EML (Exp-Minus-Log) universal operator and the Berggren tree of Pythagorean triples. All mathematical results are formally verified in Lean 4 with Mathlib.

## Contents

### Lean 4 Formalizations (Machine-Verified Proofs)

| File | Theorems | Description |
|------|----------|-------------|
| `PythagoreanBridgeResearch.lean` | 40+ | **NEW** Main research file: Lorentz form, parity invariant, Gaussian connection, inverses, growth bounds, log-variety, N-tuples |
| `PythagoreanBridge.lean` | 25+ | Original bridge: Berggren path evaluation, EML trees, depth bounds |
| `Basic.lean` | 15+ | Core EML identities and algebraic properties |
| `NewTheorems.lean` | 10+ | EML derivatives, tree combinatorics, master formula |

### Key Verified Theorems

1. **Lorentz Preservation** — All Berggren matrices preserve Q(a,b,c) = a²+b²−c²
2. **Parity Invariant** — Every Berggren tree triple has pattern (odd, even, odd)
3. **Brahmagupta–Fibonacci** — Product of sums-of-squares is a sum-of-squares
4. **Hypotenuse Product** — Product of Pythagorean hypotenuses is a hypotenuse
5. **EML Fixed Point** — exp(x) > x for all real x (no EML fixed point)
6. **Log-Variety Embedding** — Positive triples embed into the EML log-variety
7. **Berggren Inverse** — M₁⁻¹ exists and is verified
8. **Hypotenuse Growth** — Hypotenuse strictly increases under M₂
9. **Scaling Law** — Pythagorean scaling = log-space translation
10. **Tree Combinatorics** — leaves = nodes + 1, size = 2·nodes + 1

### Python Demos

| File | Description |
|------|-------------|
| `Demos/pythagorean_bridge_explorer.py` | Interactive Berggren tree exploration, EML verification, angle distribution |
| `Demos/eml_quadruple_explorer.py` | Pythagorean quadruples and N-tuples |
| `Demos/eml_gaussian_bridge.py` | Gaussian integer connection |
| `Demos/eml_research_discoveries.py` | Key discoveries: eigenvalues, modular patterns, growth rates |

### SVG Visuals

| File | Description |
|------|-------------|
| `Visuals/berggren_eml_bridge_overview.svg` | Complete bridge diagram: Berggren tree ↔ EML framework |
| `Visuals/gaussian_eml_connection.svg` | Three-way connection: Gaussian integers, Pythagorean triples, EML |
| `Visuals/lorentz_invariance.svg` | Lorentz form preservation across the Berggren tree |
| `Visuals/research_directions_map.svg` | 35+ research directions organized by theme |

### Research Papers

| File | Description |
|------|-------------|
| `Papers/eml_pythagorean_bridge_research_v3.md` | Full research paper with all verified results |
| `Papers/sciam_one_operator_to_rule_them_all.md` | Scientific American style article |
| `Papers/future_research_v3.md` | 35+ future research directions |
| `Papers/important_questions_answered_v2.md` | 17 questions answered with references to proofs |

## Running the Demos

```bash
cd EML/Demos
python3 pythagorean_bridge_explorer.py
python3 eml_research_discoveries.py
python3 eml_quadruple_explorer.py
python3 eml_gaussian_bridge.py
```

## Building the Lean Proofs

```bash
lake build EML.PythagoreanBridgeResearch
```

## Key Discoveries

1. **Parity Invariant**: Every triple in the Berggren tree has pattern (odd, even, odd) — the first leg is always odd, the second is always even, the hypotenuse is always odd. This is a new formally verified theorem.

2. **Lorentz Group Structure**: The Berggren matrices lie in O(2,1; ℤ) and the Berggren tree is a tessellation of hyperbolic 2-space. The EML bridge maps this to an exponential sum variety.

3. **Growth Rate Analysis**: The B-path growth ratio converges to 3 + 2√2 (the dominant eigenvalue of M₂), while A and C paths show decreasing growth ratios.

4. **Gaussian Multiplicativity**: Pythagorean triple products via the Brahmagupta–Fibonacci identity correspond to Gaussian integer multiplication, naturally expressed through EML log-space addition.

5. **Angle Distribution**: Berggren tree angles converge to mean 45° with σ ≈ 17.5°, but are NOT uniformly distributed — they concentrate around the midpoint.
