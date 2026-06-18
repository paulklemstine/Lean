# EML: The Continuous Sheffer Stroke

## All Elementary Functions from a Single Operator

This directory contains a comprehensive research exploration of the **EML operator** `eml(x,y) = exp(x) - ln(y)`, discovered by Andrzej Odrzywolek (Jagiellonian University, 2025). The EML operator, paired with the constant 1, generates **all elementary functions** — the continuous analogue of the NAND gate's universality for Boolean logic.

---

## Contents

### 📐 Lean 4 Formalized Theorems (`*.lean`)

Machine-verified proofs of core EML properties:

- **`Basic.lean`** — Core definitions and identities
  - Definition of `eml` and `emlR` operators
  - `eml_exp`: exp(x) = eml(x, 1) ✅
  - `eml_e`: e = eml(1, 1) ✅
  - `eml_noncommutative`: EML is non-commutative ✅
  - `emlR_log`: ln(z) = eml(1, eml(eml(1,z), 1)) ✅
  - `sub_via_exp_log`, `add_via_exp_log`, `mul_via_exp_log`: arithmetic from exp/log ✅
  - `EMLExpr.leaf_eq_node_succ`: leaves = nodes + 1 in any EML tree ✅
  - `eml_differentiable_fst`: EML is differentiable in x ✅
  - `eml_hasDerivAt_fst`: ∂eml/∂x = exp(x) ✅
  - Master formula parameter counts verified ✅

- **`Universality.lean`** — Closure and universality results
  - EML closure inductive definition ✅
  - exp(1) is in the EML closure ✅
  - Anti-EML = negated swapped EML ✅

- **`NewTheorems.lean`** — Novel mathematical contributions
  - EML partial derivatives (both x and y directions) ✅
  - Binary tree combinatorics: leaves = nodes + 1 ✅
  - Depth bound: leaves ≤ 2^depth ✅
  - Anti-EML identity ✅
  - Catalan number verification ✅
  - Master formula parameter scaling ✅

**All 19 theorems are fully proved — zero sorry's remaining.**

### 🐍 Python Demos (`Demos/`)

- **`eml_calculator.py`** — Two-button scientific calculator demo
  - Generates constants (e, 0, i, π) from EML + 1
  - Computes elementary functions via EML
  - Displays Catalan numbers and master formula parameters
  - NAND vs EML comparison

- **`eml_symbolic_regression.py`** — Gradient-based symbolic regression
  - EML master formula implementation
  - Soft parameter selection via softmax
  - Training with numerical gradient descent
  - Exact formula recovery demonstration

- **`eml_dynamics.py`** — Dynamical systems exploration
  - Fixed points of diagonal EML map
  - Orbit analysis (exponential, logarithmic, diagonal modes)
  - 2D symmetric map analysis
  - EML number tower (constants from small trees)

- **`eml_visualization_generator.py`** — Tree visualization and analysis
  - ASCII art EML trees
  - Evaluation tables
  - Pure constant enumeration
  - Complexity statistics

- **`eml_gradient_analysis.py`** — Gradient structure analysis
  - Gradient magnitude across input space
  - Chain gradient propagation (explosion/vanishing)
  - Master formula gradient landscape
  - Training recommendations

### 🎨 SVG Visuals (`Visuals/`)

- **`eml_tree_exp.svg`** — EML tree for exp(x) (depth 1)
- **`eml_tree_ln.svg`** — EML tree for ln(z) (depth 3)
- **`eml_nand_comparison.svg`** — NAND vs EML side-by-side comparison
- **`eml_reduction_tower.svg`** — The 36 → 3 primitive reduction tower
- **`eml_circuit_symbol.svg`** — EML circuit symbol design
- **`eml_applications_map.svg`** — Applications and research map

### 📄 Research Papers (`Papers/`)

- **`research_paper.md`** — Full research paper with new theorems, conjectures, and formal results
- **`scientific_american_article.md`** — Accessible popular science article
- **`future_research_directions.md`** — Comprehensive roadmap of 30+ research directions
- **`applications_brainstorm.md`** — 50 application ideas across 10 categories
- **`important_questions_answered.md`** — 20 deep questions about EML, answered

---

## Key Results

### Proven in Lean 4:
1. exp(x) = eml(x, 1) — exponential as depth-1 EML
2. e = eml(1, 1) — Euler's number from EML
3. ln(z) = eml(1, eml(eml(1,z), 1)) — logarithm as depth-3 EML
4. EML is non-commutative
5. leaves = nodes + 1 for all binary EML trees
6. leaves ≤ 2^depth
7. ∂eml/∂x = exp(x), ∂eml/∂y = -1/y
8. EML is differentiable in x
9. Master formula has 5·2ⁿ - 6 parameters

### Discovered computationally:
1. Diagonal EML map has complex fixed points near z ≈ 0.817 ± 1.059i
2. Log iteration eml(1, z) converges to ≈ 2.0 from many starting points
3. The EML number tower generates e, e-1, 0, exp(e), exp(e)-1, ... at depths 0-3
4. Catalan numbers count EML tree shapes (verified C₀=1 through C₄=14)

### 10 New Conjectures:
1. No constant-free binary Sheffer exists
2. No real-only Sheffer exists
3. K_EML(π) ≤ 40
4. Depth-complexity gap exists
5. K_EML(x·y) = 17
6. EML irrationality measure decreases exponentially
7. Training threshold at depth d* ≈ 5
8. Sheffer family is countably infinite
9. A unary Sheffer extension exists
10. Complexity is monotonic under composition

---

## Quick Start

```bash
# Run the two-button calculator demo
python3 EML/Demos/eml_calculator.py

# Explore EML dynamics
python3 EML/Demos/eml_dynamics.py

# Build the Lean proofs
lake build EML
```

---

## References

- Odrzywolek, A. "All elementary functions from a single operator." Preprint (2025).
- Sheffer, H.M. "A set of five independent postulates for Boolean algebras." Trans. AMS 14 (1913).
- Ritt, J.F. "Integration in Finite Terms." Columbia University Press (1948).
