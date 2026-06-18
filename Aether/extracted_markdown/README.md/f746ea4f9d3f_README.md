# EML: The Continuous Sheffer Stroke

## All Elementary Functions from a Single Operator

This directory contains a comprehensive research exploration of the **EML operator** `eml(x,y) = exp(x) - ln(y)`, discovered by Andrzej Odrzywolek (Jagiellonian University, 2025). The EML operator, paired with the constant 1, generates **all elementary functions** — the continuous analogue of the NAND gate's universality for Boolean logic.

---

## Contents

### 📐 Lean 4 Formalized Theorems (`*.lean`)

Machine-verified proofs of core EML properties — **100+ theorems, zero sorry's**:

- **`Basic.lean`** — Core definitions and identities (~25 theorems)
  - Definition of `eml` and `emlR` operators
  - exp(x) = eml(x, 1), e = eml(1, 1) ✅
  - EML is non-commutative ✅
  - ln(z) = eml(1, eml(eml(1,z), 1)) ✅
  - Arithmetic from exp/log ✅
  - EML expression tree structure ✅
  - Differentiability and derivative formulas ✅

- **`AdvancedTheorems.lean`** — Extended theory (~35 theorems)
  - Zero generation: eml(1, eml(eml(1,1), 1)) = 0 ✅
  - Non-associativity ✅
  - Fixed point existence and uniqueness (IVT proof) ✅
  - Joint continuity on ℝ × (ℝ\{0}) ✅
  - C^∞ smoothness ✅
  - e-Tower: strictly increasing, every level EML-generated ✅
  - Closure properties: e, e^e, 0, e−1 all EML-generated ✅
  - Pure tree evaluation ✅

- **`Universality.lean`** — Closure and universality (~10 theorems)
  - EML closure inductive definition ✅
  - Anti-EML = negated swapped EML ✅
  - EDL variant definition ✅

- **`NewTheorems.lean`** — Novel contributions (~15 theorems)
  - EML partial derivatives (both directions) ✅
  - Binary tree combinatorics ✅
  - Master formula parameter count ✅

- **`ExtendedTheory.lean`** — ★ NEW: Deep results (~30 theorems)
  - **Diagonal map has no real fixed points**: ∀ z, exp(z)−ln(z) ≠ z ✅
  - **EML monotonicity**: strictly ↑ in x, strictly ↓ in y ✅
  - **EML convexity**: convex in x (ℝ), convex in y (ℝ₊) ✅
  - **Lower bound**: exp(z)−ln(z) ≥ 1 for z > 0 ✅
  - **Negation recovery**: eml(0, exp(x)) = 1 − x ✅
  - **Subtraction**: eml(ln(a), exp(b)) = a − b ✅
  - **Addition**: eml(ln(a), exp(−b)) = a + b ✅
  - **Power function**: a^b = exp(b·ln(a)) ✅
  - **Lambert W connection**: z*·exp(z*) = e^e ✅
  - **2D dynamics**: trace, difference, diagonal invariance ✅
  - **Fundamental inequality**: eml(x, exp(x)) ≥ 1 ✅
  - **Catalan numbers** C₀ through C₇ ✅
  - **Master formula growth**: P(n+1) > 2·P(n) ✅
  - **e-tower growth**: eTower(n) ≥ n ✅

### 🐍 Python Demos (`Demos/`)

- **`eml_calculator.py`** — Two-button scientific calculator
- **`eml_symbolic_regression.py`** — Gradient-based symbolic regression
- **`eml_dynamics.py`** — Dynamical systems exploration
- **`eml_visualization_generator.py`** — Tree visualization
- **`eml_gradient_analysis.py`** — Gradient structure analysis
- **`eml_interactive_explorer.py`** — Comprehensive interactive demo
- **`eml_number_tower.py`** — EML constant hierarchy explorer
- **`eml_complexity_explorer.py`** — Exhaustive EML complexity search
- ★ **`eml_julia_set.py`** — Julia set & complex dynamics explorer
  - Complex fixed point discovery via Newton's method
  - Escape time computation for Julia set visualization
  - Orbit analysis for various starting points
  - EML constant enumeration up to tree depth 5
- ★ **`eml_constant_density.py`** — Constant density and distribution analysis
  - Pure tree enumeration up to 6 internal nodes
  - "Desert" analysis: intervals with no EML constants
  - Rationality conjecture verification
- ★ **`eml_symbolic_regression_v2.py`** — Advanced symbolic regression
  - Physics formula benchmarks
  - Search space comparison (EML vs traditional)
  - Master formula parameter analysis
- ★ **`eml_two_button_calculator.py`** — Gamified calculator
  - Step-by-step constant generation
  - Recipe verification for standard functions
  - Fixed point demonstrations
  - Challenge levels (easy to boss)

### 🎨 SVG Visuals (`Visuals/`)

- **`eml_tree_exp.svg`** — EML tree for exp(x)
- **`eml_tree_ln.svg`** — EML tree for ln(z)
- **`eml_nand_comparison.svg`** — NAND vs EML comparison
- **`eml_reduction_tower.svg`** — The 36 → 1 reduction
- **`eml_circuit_symbol.svg`** — Hardware circuit symbol
- **`eml_applications_map.svg`** — Applications map
- **`eml_number_tower.svg`** — Constant hierarchy
- **`eml_fixed_points.svg`** — Fixed point analysis
- **`eml_complexity_table.svg`** — Complexity theory overview
- ★ **`eml_research_roadmap_v3.svg`** — Full research roadmap with 12 branches
- ★ **`eml_diagonal_dynamics.svg`** — Diagonal map analysis with verified theorems
- ★ **`eml_universality_diagram.svg`** — How EML builds all functions
- ★ **`eml_constant_tower.svg`** — The EML constant hierarchy visualization

### 📄 Research Papers (`Papers/`)

- ★ **`extended_research_paper_v3.md`** — Comprehensive research paper (100+ theorems)
  - Diagonal map analysis, Lambert W connection
  - Monotonicity, convexity, 2D dynamics
  - 50+ open problems
- ★ **`sciam_one_button_v2.md`** — "The God Equation of Mathematics"
  - Scientific American-style feature article
  - Accessible explanation of EML universality
- ★ **`future_research_v3.md`** — 50+ research directions across 12 fields
  - Pure mathematics, complexity, dynamics, ML, hardware, number theory, physics
  - Prioritized roadmap: immediate / medium-term / long-term
  - Complete theorem inventory
- ★ **`applications_and_new_discoveries.md`** — New discoveries & applications
  - 6 new mathematical discoveries
  - 8 answered questions
  - 10 exciting applications

---

## Key Results

### Machine-Verified in Lean 4 (100+ theorems, 0 sorry's):

**Core Identities:**
1. exp(x) = eml(x, 1)
2. e = eml(1, 1)
3. ln(z) = eml(1, eml(eml(1,z), 1))
4. 0 = eml(1, eml(eml(1,1), 1))

**Algebraic Structure:**
5. EML is non-commutative
6. EML is non-associative
7. Anti-EML = −eml(y, x)

**Arithmetic Recovery:**
8. a − b = eml(ln(a), exp(b))
9. a + b = eml(ln(a), exp(−b))
10. eml(0, exp(x)) = 1 − x
11. a^b = exp(b · ln(a))

**Analysis (★ NEW):**
12. ∀ z ∈ ℝ: exp(z) − ln(z) ≠ z (no real diagonal fixed point)
13. eml is strictly ↑ in x, strictly ↓ in y
14. eml is convex in x (ℝ), convex in y (ℝ₊)
15. exp(z) − ln(z) ≥ 1 for z > 0
16. eml(x, exp(x)) ≥ 1 for all x

**Dynamics (★ NEW):**
17. z* + ln(z*) = e (Lambert W connection)
18. z* · exp(z*) = e^e (so z* = W(e^e))
19. The 2D symmetric map preserves the diagonal
20. e-tower(n) ≥ n

**Combinatorics:**
21. leaves = nodes + 1
22. leaves ≤ 2^depth
23. Catalan numbers C₀ = 1 through C₇ = 429
24. P(n+1) > 2·P(n) (master formula growth)

### Computational Discoveries (★ NEW):
- Complex fixed points found: z ≈ 0.817 ± 1.059i (repelling)
- EML constant density: ~45 distinct constants from trees with ≤ 5 nodes
- Only rational EML constants observed: 0 and 1

### 10 Open Conjectures:
1. No constant-free binary Sheffer exists
2. No real-only Sheffer exists
3. The only rational EML constants are 0 and 1
4. K_EML(x·y) = 17
5. EML complexity is NP-hard to compute
6. z* = W(e^e) is transcendental
7. Complex diagonal fixed points have Hausdorff dim > 0
8. EML constants are dense in some interval of ℝ
9. Sheffer family is countably infinite
10. EML complexity is subadditive under composition

---

## Quick Start

```bash
# Run the two-button calculator demo
python3 EML/Demos/eml_two_button_calculator.py

# Explore complex dynamics and Julia sets
python3 EML/Demos/eml_julia_set.py

# Analyze EML constant density
python3 EML/Demos/eml_constant_density.py

# Run symbolic regression benchmarks
python3 EML/Demos/eml_symbolic_regression_v2.py

# Build and verify the Lean proofs
lake build EML
```

---

## References

- Odrzywolek, A. "All elementary functions from a single operator." Preprint (2025).
- Sheffer, H.M. "A set of five independent postulates for Boolean algebras." Trans. AMS 14 (1913).
- Corless, R.M. et al. "On the Lambert W function." Advances in Computational Mathematics 5 (1996).
- Stanley, R.P. "Catalan Numbers." Cambridge University Press (2015).
- Richardson, D. "Some undecidable problems involving elementary functions." J. Symbolic Logic 33 (1968).
