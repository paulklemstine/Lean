# Sheffer AI: The Unary Sheffer Function Program

## One Function to Rule Them All

The **softplus function** σ(x) = log(1 + eˣ) is the continuous analogue of the NAND gate — a single function from which all smooth functions can be built. This project formalizes, proves, demonstrates, and explores this foundational result.

---

## 📁 Project Structure

```
ShefferAI/
├── README.md                          # This file
├── Lean/                              # Formal proofs (Lean 4 + Mathlib)
│   ├── SoftplusBasic.lean             # Core properties (20 theorems, 0 sorry)
│   ├── ShefferAlgebra.lean            # Algebraic structure (8 theorems, 0 sorry)
│   └── UniversalApproximation.lean    # Approximation theory (5 theorems, 0 sorry)
├── Python/                            # Computational demonstrations
│   ├── softplus_demo.py               # Interactive visualizations
│   ├── sheffer_symbolic_extraction.py # Symbolic extraction from trained networks
│   └── sheffer_approximation_rates.py # Convergence rate analysis
├── Visuals/                           # SVG diagrams
│   ├── softplus_curve.svg             # The softplus function with ReLU comparison
│   ├── sheffer_algebra_structure.svg  # How σ generates all functions
│   ├── sheffer_depth_hierarchy.svg    # Complexity hierarchy by depth
│   ├── sheffer_nand_analogy.svg       # NAND ↔ Softplus analogy
│   ├── applications_map.svg          # Applications overview
│   └── formal_group_connection.svg   # Formal group theory link
└── Papers/                            # Written research
    ├── research_paper.md              # Technical research paper
    ├── scientific_american_article.md # Popular science article
    └── future_research_directions.md  # Comprehensive research roadmap
```

---

## 🔬 Formally Verified Theorems (Lean 4)

All proofs are machine-checked with zero `sorry` statements:

### SoftplusBasic.lean — Core Analysis
| # | Theorem | Statement |
|---|---------|-----------|
| 1 | `softplus_pos` | σ(x) > 0 for all x |
| 2 | `softplus_strictMono` | σ is strictly increasing |
| 3 | `softplus_mono` | σ is monotone |
| 4 | `softplus_gt_id` | σ(x) > x for all x |
| 5 | `softplus_differentiable` | σ is differentiable everywhere |
| 6 | `softplus_deriv` | σ'(x) = eˣ/(1+eˣ) (sigmoid) |
| 7 | `softplus_convex` | σ is convex on ℝ |
| 8 | `softplus_exp_identity` | e^{σ(x)} = 1 + eˣ |
| 9 | `softplus_reflection` | σ(x) − x = σ(−x) |
| 10 | `softplus_zero` | σ(0) = log 2 |
| 11 | `logisticSigmoid_pos` | S(x) > 0 |
| 12 | `logisticSigmoid_lt_one` | S(x) < 1 |
| 13 | `logisticSigmoid_mem_Ioo` | S(x) ∈ (0, 1) |
| 14 | `logisticSigmoid_symmetry` | S(−x) = 1 − S(x) |
| 15 | `logisticSigmoid_zero` | S(0) = 1/2 |
| 16 | `one_plus_exp_pos` | 1 + eˣ > 0 |
| 17 | `one_plus_exp_gt_one` | 1 + eˣ > 1 |

### ShefferAlgebra.lean — Algebraic Structure
| # | Theorem | Statement |
|---|---------|-----------|
| 18 | `softplus_mem_sheffer` | σ ∈ Sheffer algebra |
| 19 | `sheffer_affine_pre_closed` | Closed under affine pre-composition |
| 20 | `sheffer_affine_comb_closed` | Closed under affine combination |
| 21 | `sheffer_comp_closed` | Closed under composition |
| 22 | `const_mem_sheffer` | Constants ∈ Sheffer algebra |
| 23 | `id_mem_sheffer` | Identity function ∈ Sheffer algebra |

### UniversalApproximation.lean — Universality
| # | Theorem | Statement |
|---|---------|-----------|
| 24 | `softplus_separates_points` | x₁ ≠ x₂ ⟹ ∃ a,b: σ(ax₁+b) ≠ σ(ax₂+b) |
| 25 | `softplus_nonvanishing` | ∀ x, ∃ a,b: σ(ax+b) ≠ 0 |
| 26 | `softplus_continuous` | σ is continuous |
| 27 | `softplus_family_continuous` | Each σ(ax+b) is continuous |

---

## 🐍 Python Demos

### `softplus_demo.py`
Six interactive demonstrations:
1. Softplus vs ReLU comparison
2. Building functions from softplus (identity, exp, sin, etc.)
3. Universal approximation convergence
4. The softplus temperature family
5. Numerical verification of all key identities
6. Sheffer algebra closure properties

### `sheffer_symbolic_extraction.py`
Trains softplus networks on known functions and extracts symbolic formulas. Demonstrates that training = symbolic regression.

### `sheffer_approximation_rates.py`
Computes convergence rates for depth-1 Sheffer approximations, providing evidence for the Sheffer-Jackson conjecture.

---

## 🎨 SVG Visualizations

Six publication-quality diagrams explaining the theory visually:
- The softplus curve with sigmoid derivative
- The Sheffer algebra's generative structure
- The depth hierarchy of mathematical functions
- The NAND ↔ Softplus grand analogy
- Applications map (10 fields)
- Formal group theory connection

---

## 📝 Papers

### Research Paper (`research_paper.md`)
Complete technical paper covering definitions, proofs, connections to formal groups and tropical geometry, and the formal verification infrastructure.

### Scientific American Article (`scientific_american_article.md`)
Accessible introduction explaining the significance of the Sheffer function theory for general audiences.

### Future Research Directions (`future_research_directions.md`)
Comprehensive 36-month research roadmap with 12+ concrete research directions, experimental proposals, and timeline.

---

## 🔑 Key Insights

1. **Every softplus neural network IS a formula** — training is symbolic regression in disguise
2. **Sheffer depth = mathematical complexity** — a new complexity measure for smooth functions
3. **One function generates all of analysis** — the continuous NAND
4. **Softplus bridges additive and multiplicative** — it's the logarithm of the multiplicative formal group
5. **The tropical limit gives ReLU** — connecting smooth and piecewise-linear worlds

---

## 🏗️ Building

```bash
# Lean proofs
lake build ShefferAI

# Python demos (requires numpy, scipy, matplotlib)
cd Python
python softplus_demo.py
python sheffer_symbolic_extraction.py
python sheffer_approximation_rates.py
```

---

*All formal proofs use Lean 4 v4.28.0 with Mathlib. Zero unverified assumptions.*
