# SPB–EML Bridge: The Arithmetic–Geometry Duality

## Overview

This directory contains a comprehensive research package establishing the connection between two universal algebraic operators:

| Operator | Formula | Domain |
|----------|---------|--------|
| **SPB** (Stereographic Projection Bridge) | spb(x,y) = (x+y)/(1−xy) | Geometry: angles, rotations, circles |
| **EML** (Exp-Minus-Log) | eml(x,y) = eˣ − ln(y) | Arithmetic: exp, log, all elementary functions |

### The Core Conversion

**SPB → EML**: `spb(x,y) = eml(eml(0, 1−xy) − eml(0, x+y), 1)` — three EML operations.

**The Bridge Identity**: `ln(1 + spb(x,y)²) = ln(1+x²) + ln(1+y²) − 2·ln|1−xy|`

---

## Contents

### Lean 4 Formalization (`SPBtoEML.lean`)
- **22 theorems, zero sorry** — all machine-verified
- Norm identity, logarithmic bridge, Cauchy entropy additivity
- exp∘arctan homomorphism, SPB group properties, derivative

### Python Demos (`Demos/`)
- `spb_eml_demo.py` — 10 interactive demos of key identities
- `spb_eml_visualizer.py` — matplotlib plots (surfaces, Cayley transform, spirals)
- `spb_eml_experiments.py` — 7 hypothesis-testing experiments

### SVG Visuals (`Visuals/`)
- `bridge_diamond.svg` — The four-structure homomorphism diamond
- `spb_circle.svg` — SPB as circle group multiplication via Cayley
- `eml_operator.svg` — EML as the arithmetic Sheffer stroke
- `spb_eml_conversion.svg` — Step-by-step SPB → EML conversion
- `spb3d_formula.svg` — The corrected 3D SPB formula

### Research Papers (`Papers/`)
- `SPB_EML_Bridge_Paper.md` — Full research paper
- `SciAm_Article.md` — Scientific American–style feature article
- `FutureResearchDirections.md` — 35+ research directions, ranked by impact
- `Discoveries.md` — Summary of key discoveries

---

## Key Discoveries

### 1. The Correct 3D SPB Formula
The conjectured formula `(u+v+u×v)/(1−u·v)` is **wrong**. The correct formula is:

**spb₃(u,v) = ((1−|v|²)u + (1−|u|²)v + 2u×v) / (1 + |u|²|v|² − 2u·v)**

### 2. Cauchy Entropy Additivity
H(spb(x,y)) = H(x) + H(y) − 2·ln|1−xy| where H(t) = ln(1+t²)

### 3. The p±1 Law
|SPB(F_p)| = p+1 if p≡3(mod 4), p−1 if p≡1(mod 4) — confirmed for all primes < 200

### 4. Random SPB → Cauchy
SPB iteration with random inputs converges to the Cauchy distribution (confirmed by simulation)

---

## Quick Start

```bash
# Run all Python demos (text output, no matplotlib needed)
python3 Demos/spb_eml_demo.py

# Run hypothesis-testing experiments
python3 Demos/spb_eml_experiments.py

# Generate plots (requires matplotlib)
pip install matplotlib
python3 Demos/spb_eml_visualizer.py
```

---

## Formal Verification Status

All 22 theorems in `SPBtoEML.lean` compile with zero sorry:

| Theorem | Status |
|---------|--------|
| `spb_norm_identity` | ✓ Verified |
| `spb_norm_ratio` | ✓ Verified |
| `log_spb_norm` | ✓ Verified |
| `eml_is_exp` | ✓ Verified |
| `eml_is_neg_log` | ✓ Verified |
| `eml_identity_val` | ✓ Verified |
| `eml_generates_e` | ✓ Verified |
| `spb_eml_decomposition` | ✓ Verified |
| `arctan_spb_add` | ✓ Verified |
| `exp_arctan_spb_mul` | ✓ Verified |
| `spb_comm` | ✓ Verified |
| `spb_zero` | ✓ Verified |
| `spb_neg` | ✓ Verified |
| `spb_assoc` | ✓ Verified |
| `spb_self` | ✓ Verified |
| `wick_rotation` | ✓ Verified |
| `cauchyEntropy_nonneg` | ✓ Verified |
| `cauchyEntropy_eq_zero_iff` | ✓ Verified |
| `cauchyEntropy_spb` | ✓ Verified |
| `spb_hasDerivAt_fst` | ✓ Verified |
| `spb_deriv_pos` | ✓ Verified |

Axioms used: only `propext`, `Classical.choice`, `Quot.sound` (standard).
