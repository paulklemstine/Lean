# EML: The Continuous Sheffer Stroke

## All Elementary Functions from a Single Operator

This directory contains a comprehensive research exploration of the **EML operator** `eml(x,y) = exp(x) - ln(y)`, discovered by Andrzej Odrzywolek (Jagiellonian University, 2025). The EML operator, paired with the constant 1, generates **all elementary functions** — the continuous analogue of the NAND gate's universality for Boolean logic.

---

## Contents

### 📐 Lean 4 Formalized Theorems (`*.lean`)

Machine-verified proofs with **zero sorries** across all files:

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
  - Master formula parameter scaling ✅

- **`ComplexityTheory.lean`** — 🆕 EML complexity theory formalization
  - Structural bounds: leaves = nodes + 1, size = 2·leaves − 1 ✅
  - Depth-leaf bound: leaves ≤ 2^depth ✅
  - Catalan number computation and verification (C₀–C₅) ✅
  - Master formula parameter monotonicity ✅
  - Depth-zero characterization ✅
  - Substitution operation defined ✅

- **`ShefferClassification.lean`** — 🆕 Sheffer operator classification
  - Definitions: EML, anti-EML, Swap, Negate, SwapNeg ✅
  - Klein 4-group structure: SwapNeg(EML) = anti-EML ✅
  - Sheffer closure inductive definition ✅
  - exp(1) and exp(exp(1)) in EML closure ✅
  - Real EML: non-commutative, no right identity ✅
  - Involution theorems for Swap and Negate ✅

- **`MagmaStructure.lean`** — 🆕 Free magma algebraic theory
  - EML term algebra over arbitrary variable sets ✅
  - Non-associativity of the free EML magma ✅
  - Non-commutativity of the free EML magma ✅
  - No left/right identity elements ✅
  - Leaves = variables + constants identity ✅
  - Evaluation, substitution, and functional equivalence ✅
  - Quotient magma definition (EMLMagma) ✅

**All 35+ theorems are fully proved — zero sorries remaining.**

### 🐍 Python Demos (`Demos/`)

- **`eml_calculator.py`** — Two-button scientific calculator demo
- **`eml_symbolic_regression.py`** — Gradient-based symbolic regression
- **`eml_dynamics.py`** — Dynamical systems exploration
- **`eml_visualization_generator.py`** — Tree visualization and analysis
- **`eml_gradient_analysis.py`** — Gradient structure analysis
- **`eml_complexity_explorer.py`** — 🆕 Exhaustive complexity search
  - Enumerates EML trees, identifies constants
  - Catalan number verification
  - Information-theoretic analysis
  - 7 complexity conjectures
- **`eml_neural_network.py`** — 🆕 EML neural network architecture
  - Binary tree networks with EML neurons
  - Gradient-based training
  - Architecture comparison (depth 1-3)
  - Parameter scaling analysis
- **`eml_sheffer_explorer.py`** — 🆕 Sheffer operator family explorer
  - Klein 4-group demonstration
  - Systematic search for new Sheffer operators
  - Fixed point analysis
  - Theoretical analysis of necessary conditions
- **`eml_two_button_calculator.py`** — 🆕 Interactive two-button calculator
  - Stack-based computation with [1] and [EML]
  - Constant generation chains
  - Function computation demonstrations
  - NAND vs EML comparison

### 🎨 SVG Visuals (`Visuals/`)

- **`eml_tree_exp.svg`** — EML tree for exp(x) (depth 1)
- **`eml_tree_ln.svg`** — EML tree for ln(z) (depth 3)
- **`eml_nand_comparison.svg`** — NAND vs EML side-by-side comparison
- **`eml_reduction_tower.svg`** — The 36 → 3 primitive reduction tower
- **`eml_circuit_symbol.svg`** — EML circuit symbol design
- **`eml_applications_map.svg`** — Applications and research map
- **`eml_bootstrapping_chain.svg`** — 🆕 Full bootstrapping chain visualization
  - From 1 through e, 0, −1, iπ, π, i to sin/cos
  - Color-coded by function type
- **`eml_complexity_landscape.svg`** — 🆕 Complexity bar chart
  - K_EML for constants and functions
  - Upper bounds and exact values
- **`eml_sheffer_family.svg`** — 🆕 Klein 4-group diagram
  - EML, LEA, anti-EML, −EML relationships
  - Swap and Negate transformations
  - EDL as independent operator
- **`eml_master_formula.svg`** — 🆕 Master formula tree structure
  - Depth-2 tree with parameter annotations
  - Parameter scaling table
- **`eml_catalan_trees.svg`** — 🆕 Catalan number tree enumeration
  - All tree shapes for n = 0, 1, 2, 3
  - Full Catalan number table with interpretations

### 📄 Research Papers (`Papers/`)

- **`research_paper.md`** — Original research paper with theorems and conjectures
- **`scientific_american_article.md`** — Accessible popular science article
- **`future_research_directions.md`** — Original 30+ research directions
- **`applications_brainstorm.md`** — Original application ideas
- **`important_questions_answered.md`** — 20 deep questions answered
- **`extended_research_paper.md`** — 🆕 Comprehensive research paper
  - Free magma structure and quotient theory
  - Full complexity theory with Lean-verified bounds
  - Klein 4-group classification of Sheffer operators
  - Constant-free and real-only impossibility conjectures
  - 10 major open problems
  - Program of "Continuous Universal Algebra"
- **`scientific_american_extended.md`** — 🆕 Extended popular science article
  - "Mathematics' Best-Kept Secret" narrative
  - The bootstrap chain explained for general audiences
  - The four siblings (Klein 4-group for non-specialists)
  - The missing button (constant-free problem)
  - The complex detour
  - Applications horizon
- **`future_research_extended.md`** — 🆕 50+ research directions
  - 15 milestone problems with difficulty ratings
  - 10 research areas: algebra, complexity, ML, hardware, physics, etc.
  - Detailed timeline: immediate to 5+ years
  - Specific attack strategies for each problem
- **`deep_questions_explored.md`** — 🆕 30 important questions answered
  - Foundational (why EML works, novelty, comparison to NAND)
  - Mathematical structure (magma, Church-Rosser, automorphisms)
  - Applications (symbolic regression, cryptography, tensor networks)
  - Connections (differential Galois theory, periods, Langlands)
  - Philosophical (nature of mathematics, universality)
  - Technical (branch cuts, evaluation, divergence)
- **`applications_extended.md`** — 🆕 50 concrete applications
  - Organized by domain (scientific computing, ML, hardware, education, physics, IT)
  - Feasibility and impact ratings
  - Recommended priorities and timeline

---

## Key Results

### Proven in Lean 4 (35+ theorems, zero sorries):
1. exp(x) = eml(x, 1) — exponential as depth-1 EML
2. e = eml(1, 1) — Euler's number from EML
3. ln(z) = eml(1, eml(eml(1,z), 1)) — logarithm as depth-3 EML
4. EML is non-commutative
5. leaves = nodes + 1 for all binary EML trees
6. leaves ≤ 2^depth
7. size = 2·leaves − 1 = 2·nodes + 1
8. ∂eml/∂x = exp(x), ∂eml/∂y = -1/y
9. EML is differentiable in x
10. Master formula has 5·2ⁿ - 6 parameters (monotonically increasing)
11. Catalan numbers C₀ through C₅ verified
12. Free EML magma: non-associative, non-commutative, no identity
13. Klein 4-group: SwapNeg(EML) = anti-EML
14. Sheffer closure: e and exp(e) constructible from 1
15. Real EML: non-commutative, no right identity

### 15 Milestone Open Problems:
1. Classify all continuous Sheffer operators
2. Constant-free binary Sheffer existence
3. Real-only impossibility for trig functions
4. Decidability of EML term equivalence
5. Exact K_EML(x·y) (conjectured 17)
6. Exponential complexity gap existence
7. EML symbolic regression at depth 6+
8. Unary Sheffer activation function
9. Minimal extension of EML for Gamma function
10. Complete Lean formalization of EML completeness
11. K_EML(π²/6) determination
12. EML-based scientific discovery
13. Physical EML chip prototype
14. Quantum EML universality
15. EML Weierstrass approximation theorem

---

## Quick Start

```bash
# Run the two-button calculator demo
python3 EML/Demos/eml_two_button_calculator.py

# Explore EML complexity
python3 EML/Demos/eml_complexity_explorer.py

# Explore Sheffer operator family
python3 EML/Demos/eml_sheffer_explorer.py

# Build the Lean proofs
lake build EML
```

---

## References

- Odrzywolek, A. "All elementary functions from a single operator." Preprint (2025).
- Sheffer, H.M. "A set of five independent postulates for Boolean algebras." Trans. AMS 14 (1913).
- Ritt, J.F. "Integration in Finite Terms." Columbia University Press (1948).
- Richardson, D. "Some undecidable problems involving elementary functions." J. Symbolic Logic 33 (1968).
