# EML Operator — Version 5

## The Continuous Sheffer Stroke: eml(x, y) = exp(x) − ln(y)

### 160+ Theorems · 0 Sorries · April 2026

---

## What is EML?

The **EML** (Exponential-Minus-Logarithm) operator is a single binary function:

```
eml(x, y) = exp(x) − ln(y)
```

Together with the constant 1, it generates **all elementary functions** — exponentials, logarithms, trigonometric functions, polynomials, and their compositions. This makes EML the continuous analogue of the NAND gate: the *continuous Sheffer stroke*.

---

## V5 Highlights

### New Formally Verified Theorems (Lean 4 + Mathlib)

| Theorem | Statement | File |
|---------|-----------|------|
| `eTowerV_growth` | e↑↑(n+1) ≥ e · e↑↑n | V5Theorems.lean |
| `eTowerV_ge_exp_n` | e↑↑n ≥ eⁿ for all n | V5Theorems.lean |
| `eTowerV_dominates_poly` | e-tower dominates all polynomials | V5Theorems.lean |
| `diagV_gt` | d(z) > z for all z ∈ ℝ | V5Theorems.lean |
| `diagV_convexOn` | d convex on (0, ∞) | V5Theorems.lean |
| `emlV_not_power_assoc` | EML not power-associative | V5Theorems.lean |
| `gIterV_fixedPoint_gt_one` | z* > 1 | V5Theorems.lean |
| `gIterV_uniqueness` | Fixed point unique on ℝ₊ | V5Theorems.lean |
| `emlV_double_neg` | Double negation = identity | V5Theorems.lean |
| `tropV_min` | −trop(−x, y) = min(x, y) | V5Theorems.lean |
| `tropV_abs` | trop(z, z) = \|z\| | V5Theorems.lean |
| `emlV_interval_lower/upper` | Interval arithmetic bounds | V5Theorems.lean |
| `emlV_small_constants` | Arbitrarily small positive constants | V5Theorems.lean |
| `PureTree.eval_ee_minus_e` | e^e − e from 3 nodes | V5Theorems.lean |

### New Computational Discoveries

- **8 complex fixed points** of d(z) = exp(z) − log(z) found (4 conjugate pairs, all repelling)
- **Constant density analysis**: μ₆ = 0.583 (118 distinct constants from ≤6-node trees)
- **Diagonal map minimum**: d_min ≈ 2.330 at z = W(1) ≈ 0.567
- **Fixed point convergence**: z* ≈ 2.01678, rate = 1/z* ≈ 0.496

---

## Project Structure

### Lean 4 Files
```
EML/
├── Basic.lean              — Core definitions, identities, tree structure
├── AdvancedTheorems.lean   — Fixed points, e-tower, closure
├── Universality.lean       — Closure properties, EDL/anti-EML
├── NewTheorems.lean        — Derivatives, tree bounds
├── ExtendedTheory.lean     — Diagonal map, convexity, 2D dynamics
├── FundamentalTheory.lean  — Magma, tropical, contraction
├── PolynomialGeneration.lean — Arithmetic via EML
└── V5Theorems.lean         — ★ NEW: All V5 results
```

### Python Demos
```
EML/Demos/
├── eml_v5_explorer.py      — ★ Comprehensive V5 explorer
├── eml_v5_julia_set.py     — ★ Julia set computation & SVG
├── eml_comprehensive_explorer.py
├── eml_symbolic_regression_v3.py
├── eml_two_button_calculator.py
└── ... (25 more demos)
```

### SVG Visuals
```
EML/Visuals/
├── eml_v5_overview.svg          — ★ V5 research overview
├── eml_v5_etower_and_diagonal.svg — ★ Growth & dynamics
├── eml_v5_julia_set.svg         — ★ Julia set visualization
├── eml_research_overview_v4.svg
└── ... (30+ more visuals)
```

### Papers
```
EML/Papers/
├── eml_research_paper_v5.md      — ★ Comprehensive research paper
├── sciam_v5_one_operation.md     — ★ Scientific American article
├── future_research_v5.md         — ★ 80+ open problems in 16 fields
├── important_questions_v5.md     — ★ 30 key questions answered
└── ... (30+ more papers)
```

---

## Quick Start

### Verify the Lean formalization:
```bash
lake build EML.V5Theorems
```

### Run the Python explorer:
```bash
python3 EML/Demos/eml_v5_explorer.py
```

### Generate the Julia set:
```bash
python3 EML/Demos/eml_v5_julia_set.py
```

---

## Key Results Summary

### Algebraic Structure
- Non-commutative, non-associative
- No identity elements (left or right)
- **Not power-associative** (V5)

### Dynamics
- Diagonal map d(z) > z always (no real fixed points)
- **d is convex on (0, ∞)** (V5)
- Fixed point z* ≈ 2.017, **unique on ℝ₊** (V5)
- 8 complex fixed points (all repelling)

### Growth
- e↑↑(n+1) ≥ e · e↑↑n (**V5**)
- **e-tower dominates all polynomials** (V5)
- EML generates arbitrarily small positive constants

### Tropical
- trop(x, y) = max(x, −y) recovers max, min, and |·|

---

## Citation

If you use this work, please cite:

```
@misc{eml2026,
  title={The EML Operator: A Continuous Sheffer Stroke},
  year={2026},
  note={160+ theorems formally verified in Lean 4 with Mathlib}
}
```
