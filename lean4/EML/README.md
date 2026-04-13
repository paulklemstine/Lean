# EML: The Continuous Sheffer Stroke

## All Elementary Functions from a Single Operator

This directory contains a comprehensive research exploration of the **EML operator** `eml(x,y) = exp(x) - ln(y)`, discovered by Andrzej Odrzywolek (Jagiellonian University, 2025). The EML operator, paired with the constant 1, generates **all elementary functions** — the continuous analogue of the NAND gate's universality for Boolean logic.

---

## Contents

### 📐 Lean 4 Formalized Theorems (`*.lean`)

Machine-verified proofs of core EML properties — **68+ theorems, zero sorry's**:

- **`Basic.lean`** — Core definitions and identities
  - Definition of `eml` and `emlR` operators
  - `eml_exp`: exp(x) = eml(x, 1) ✅
  - `eml_e`: e = eml(1, 1) ✅
  - `eml_noncommutative`: EML is non-commutative ✅
  - `emlR_log`: ln(z) = eml(1, eml(eml(1,z), 1)) ✅
  - Arithmetic from exp/log ✅
  - `EMLExpr.leaf_eq_node_succ`: leaves = nodes + 1 ✅
  - Differentiability and derivative formulas ✅

- **`Universality.lean`** — Closure and universality results
  - EML closure inductive definition ✅
  - exp(1) is in the EML closure ✅
  - Anti-EML = negated swapped EML ✅

- **`NewTheorems.lean`** — Novel mathematical contributions
  - EML partial derivatives (both x and y directions) ✅
  - Binary tree combinatorics ✅
  - Depth bound: leaves ≤ 2^depth ✅

- **`AdvancedTheorems.lean`** — ★ NEW: Extended theory (35+ theorems)
  - **Zero generation**: eml(1, eml(eml(1,1), 1)) = 0 ✅
  - **Non-associativity**: eml(eml(1,1), 1) ≠ eml(1, eml(1,1)) ✅
  - **Fixed point existence** (IVT proof): ∃ z* ∈ (1, e) ✅
  - **Fixed point uniqueness**: unique on ℝ₊ ✅
  - **Joint continuity**: EML continuous on ℝ × (ℝ\{0}) ✅
  - **C^∞ smoothness**: eml(·, y) is infinitely differentiable ✅
  - **e-Tower**: strictly increasing, every level EML-generated ✅
  - **Closure properties**: e, e^e, 0, e-1 all EML-generated ✅
  - **Pure tree evaluation**: specific trees evaluate to e, e^e, 0, e-1 ✅
  - **Catalan numbers**: verified C₀=1 through C₄=14 ✅
  - **12+ algebraic identities** verified ✅

### 🐍 Python Demos (`Demos/`)

- **`eml_calculator.py`** — Two-button scientific calculator demo
- **`eml_symbolic_regression.py`** — Gradient-based symbolic regression
- **`eml_dynamics.py`** — Dynamical systems exploration
- **`eml_visualization_generator.py`** — Tree visualization and analysis
- **`eml_gradient_analysis.py`** — Gradient structure analysis
- **`eml_interactive_explorer.py`** — ★ NEW: Comprehensive interactive demo
  - 8 self-contained demonstrations
  - Two-button calculator, fixed points, number tower, Catalan numbers
  - Gradient explosion analysis, algebraic properties, EML vs NAND
- **`eml_number_tower.py`** — ★ NEW: EML constant hierarchy explorer
- **`eml_complexity_explorer.py`** — ★ NEW: Exhaustive EML complexity search

### 🎨 SVG Visuals (`Visuals/`)

- **`eml_tree_exp.svg`** — EML tree for exp(x) (depth 1)
- **`eml_tree_ln.svg`** — EML tree for ln(z) (depth 3)
- **`eml_nand_comparison.svg`** — NAND vs EML side-by-side comparison
- **`eml_reduction_tower.svg`** — The 36 → 3 primitive reduction tower
- **`eml_circuit_symbol.svg`** — EML circuit symbol design
- **`eml_applications_map.svg`** — Applications and research map
- **`eml_number_tower.svg`** — ★ NEW: Visual EML constant hierarchy
- **`eml_fixed_points.svg`** — ★ NEW: Fixed point analysis visualization
- **`eml_complexity_table.svg`** — ★ NEW: EML complexity theory overview

### 📄 Research Papers (`Papers/`)

- **`research_paper.md`** — Original research paper
- **`extended_research_paper.md`** — ★ NEW: Extended paper with machine-verified results
- **`scientific_american_article.md`** — Popular science article
- **`sciam_the_god_equation_of_math.md`** — ★ NEW: Extended feature article
- **`future_research_directions.md`** — Original research roadmap
- **`future_research_v2.md`** — ★ NEW: 40+ research directions across 12 fields
- **`applications_brainstorm.md`** — Application ideas
- **`applications_and_discoveries.md`** — ★ NEW: Key discoveries + 10 applications + 10 Q&As
- **`important_questions_answered.md`** — Deep questions about EML

---

## Key Results

### Machine-Verified in Lean 4 (68+ theorems, 0 sorry's):
1. exp(x) = eml(x, 1) — exponential as depth-1 EML
2. e = eml(1, 1) — Euler's number from EML
3. ln(z) = eml(1, eml(eml(1,z), 1)) — logarithm as depth-3 EML
4. **0 = eml(1, eml(eml(1,1), 1))** — zero at depth 3
5. EML is non-commutative
6. **EML is non-associative**
7. leaves = nodes + 1 for all EML trees
8. leaves ≤ 2^depth
9. ∂eml/∂x = exp(x), ∂eml/∂y = -1/y
10. EML is C^∞ in x, jointly continuous
11. **The logarithmic fixed point z* ≈ 1.763 exists and is unique**
12. **The e-tower is strictly increasing and EML-generated**
13. **e, e^e, 0, e-1 are all EML-generated from 1**
14. Catalan numbers C₀...C₄ verified

### 10 Open Conjectures:
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
# Run the comprehensive interactive explorer
python3 EML/Demos/eml_interactive_explorer.py

# Explore the EML number tower
python3 EML/Demos/eml_number_tower.py

# Search for minimal EML representations
python3 EML/Demos/eml_complexity_explorer.py

# Build and verify the Lean proofs
lake build EML
```

---

## References

- Odrzywolek, A. "All elementary functions from a single operator." Preprint (2025).
- Sheffer, H.M. "A set of five independent postulates for Boolean algebras." Trans. AMS 14 (1913).
- Ritt, J.F. "Integration in Finite Terms." Columbia University Press (1948).
- Stanley, R.P. "Catalan Numbers." Cambridge University Press (2015).
