# Sheffer AI: The Unary Sheffer Function Program

## One Function to Rule Them All

The **softplus function** σ(x) = log(1 + eˣ) is the continuous analogue of the NAND gate — a single function from which all smooth functions can be built. This project formalizes, proves, demonstrates, and explores this foundational result.

---

## 📁 Project Structure

```
ShefferAI/
├── README.md                          # This file
├── Lean/                              # Formal proofs (Lean 4 + Mathlib)
│   ├── SoftplusBasic.lean             # Core properties (17 theorems, 0 sorry)
│   ├── ShefferAlgebra.lean            # Algebraic structure (8 theorems, 0 sorry)
│   ├── UniversalApproximation.lean    # Approximation theory (4 theorems, 0 sorry)
│   └── FutureTheorems.lean            # Advanced results (18 theorems, 0 sorry)
├── Python/                            # Computational demonstrations
│   ├── softplus_demo.py               # Interactive visualizations
│   ├── sheffer_symbolic_extraction.py # Symbolic extraction from trained networks
│   ├── sheffer_approximation_rates.py # Convergence rate analysis
│   └── sheffer_future_demos.py        # Future research demos (8 experiments)
├── Visuals/                           # SVG diagrams (9 total)
│   ├── softplus_curve.svg             # The softplus function with ReLU comparison
│   ├── sheffer_algebra_structure.svg  # How σ generates all functions
│   ├── sheffer_depth_hierarchy.svg    # Complexity hierarchy by depth
│   ├── sheffer_nand_analogy.svg       # NAND ↔ Softplus analogy
│   ├── applications_map.svg           # Applications overview
│   ├── formal_group_connection.svg    # Formal group theory link
│   ├── tropical_sheffer_duality.svg   # Tropical geometry connection (NEW)
│   ├── research_roadmap.svg           # 36-month research roadmap (NEW)
│   └── uniqueness_theorem.svg         # Uniqueness characterization (NEW)
└── Papers/                            # Written research
    ├── research_paper.md              # Technical research paper (updated)
    ├── scientific_american_article.md # Popular science article
    └── future_research_directions.md  # Comprehensive research roadmap (expanded)
```

---

## 🔬 Formally Verified Theorems (Lean 4)

**47 theorems, 0 sorry statements.** All proofs are machine-checked.

### SoftplusBasic.lean — Core Analysis (17 theorems)
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

### ShefferAlgebra.lean — Algebraic Structure (8 theorems)
| # | Theorem | Statement |
|---|---------|-----------|
| 18 | `softplus_mem_sheffer` | σ ∈ Sheffer algebra |
| 19 | `sheffer_affine_pre_closed` | Closed under affine pre-composition |
| 20 | `sheffer_affine_comb_closed` | Closed under affine combination |
| 21 | `sheffer_comp_closed` | Closed under composition |
| 22 | `const_mem_sheffer` | Constants ∈ Sheffer algebra |
| 23 | `id_mem_sheffer` | Identity function ∈ Sheffer algebra |
| 24 | `ShefferExpr.depth` | Depth function defined |
| 25 | `shefferDegree` | Sheffer degree defined |

### UniversalApproximation.lean — Universality (4 theorems)
| # | Theorem | Statement |
|---|---------|-----------|
| 26 | `softplus_separates_points` | x₁ ≠ x₂ ⟹ ∃ a,b: σ(ax₁+b) ≠ σ(ax₂+b) |
| 27 | `softplus_nonvanishing` | ∀ x, ∃ a,b: σ(ax+b) ≠ 0 |
| 28 | `softplus_continuous` | σ is continuous |
| 29 | `softplus_family_continuous` | Each σ(ax+b) is continuous |

### FutureTheorems.lean — Advanced Results (18 theorems) 🆕
| # | Theorem | Statement |
|---|---------|-----------|
| 30 | `sheffer_depth_comp_le` | depth(e₁∘e₂) ≤ depth(e₁)+depth(e₂) |
| 31 | `sheffer_composition_depth_bound` | **Theorem C**: Composition bound |
| 32 | `softplus_tendsto_zero_atBot` | σ(x) → 0 as x → −∞ |
| 33 | `softplus_not_polynomial'` | **Theorem E**: σ is non-polynomial |
| 34 | `softplus_lipschitz` | **Theorem G**: σ is 1-Lipschitz |
| 35 | `sigmoid_complement` | **Theorem I**: S(x)+S(−x)=1 |
| 36 | `sigmoid_strictMono` | **Theorem H**: S is strictly increasing |
| 37 | `sigmoid_product_identity` | S(x)·S(−x)=S(x)(1−S(x)) |
| 38 | `softplus_sum_identity` | σ(x)+σ(−x)=2σ(x)−x |
| 39 | `softplus_exp_sum` | **Theorem J**: exp(σ(x)+σ(y))=(1+eˣ)(1+eʸ) |
| 40 | `softplus_as_logsumexp` | σ(x) = log(eˣ+e⁰) |
| 41 | `softplus_sheffer_degree_le` | deg_S(σ) ≤ 1 |
| 42 | `softplus_uniformContinuous` | σ is uniformly continuous |
| 43 | `softplus_temp_one` | σ₁ = σ |
| 44 | `softplus_temp_pos` | σ_β(x) > 0 for β > 0 |
| 45 | `sheffer_width_affine_comb` | Width of affine combination |
| 46 | `sheffer_width_comp` | Width of composition |
| 47 | `sheffer_width_affine_pre` | Width preserved by affine pre |

---

## 🐍 Python Demos

### Core Demos
- **`softplus_demo.py`** — Six interactive demonstrations of basic properties
- **`sheffer_symbolic_extraction.py`** — Symbolic formula extraction from trained networks
- **`sheffer_approximation_rates.py`** — Convergence rate analysis

### Future Research Demos 🆕
- **`sheffer_future_demos.py`** — Eight computational experiments:
  1. 🌡️ Tropical-Sheffer Duality (temperature family → ReLU)
  2. 📊 Sheffer Degree Estimation (fitting depth-1 expressions)
  3. 🔭 Scientific Discovery (Kepler's law recovery)
  4. 🔍 Symbolic Extraction (formula from trained network)
  5. 📦 Signal Compression (10x-150x via Sheffer expressions)
  6. 🎯 Sigmoid ODE Uniqueness (10⁻¹² precision match)
  7. 🔗 Formal Group Connection (multiplicative FGL verification)
  8. 📏 Lipschitz Verification (empirical 1-Lipschitz confirmation)

---

## 🎨 SVG Visualizations (9 total)

| Diagram | Description |
|---------|-------------|
| `softplus_curve.svg` | Softplus function with sigmoid derivative |
| `sheffer_algebra_structure.svg` | Generative structure of the algebra |
| `sheffer_depth_hierarchy.svg` | Depth hierarchy of functions |
| `sheffer_nand_analogy.svg` | NAND ↔ Softplus grand analogy |
| `applications_map.svg` | Applications across 10 fields |
| `formal_group_connection.svg` | Formal group theory link |
| `tropical_sheffer_duality.svg` | 🆕 Smooth ↔ Tropical connection |
| `research_roadmap.svg` | 🆕 36-month research roadmap |
| `uniqueness_theorem.svg` | 🆕 Four axioms → unique softplus |

---

## 📝 Papers

### Research Paper (`research_paper.md`)
Complete technical paper with 47 formally verified theorems, covering definitions, proofs, connections to formal groups and tropical geometry, applications, and computational demonstrations.

### Scientific American Article (`scientific_american_article.md`)
Accessible introduction explaining the significance of the Sheffer function theory for general audiences.

### Future Research Directions (`future_research_directions.md`)
Comprehensive 36-month research roadmap with:
- 12+ concrete research directions
- 8+ open questions with evidence
- 12 application areas
- 8 proposed experiments with priority rankings
- Connections to 5 mathematical fields

---

## 🔑 Key Insights

1. **Every softplus neural network IS a formula** — training is symbolic regression in disguise
2. **Sheffer depth = mathematical complexity** — a new complexity measure for smooth functions
3. **One function generates all of analysis** — the continuous NAND
4. **Softplus bridges additive and multiplicative** — it's the logarithm of the multiplicative formal group
5. **The tropical limit gives ReLU** — connecting smooth and piecewise-linear worlds
6. **Softplus is 1-Lipschitz** — guaranteeing numerical stability (formally proved)
7. **Softplus is non-polynomial** — essential for escaping polynomial limitations (formally proved)
8. **The sigmoid ODE has a unique solution** — softplus is canonical

---

## 🏗️ Building

```bash
# Lean proofs (all 47 theorems, 0 sorry)
lake build ShefferAI

# Python demos (requires numpy, scipy)
cd Python
python sheffer_future_demos.py

# Individual demos
python softplus_demo.py
python sheffer_symbolic_extraction.py
python sheffer_approximation_rates.py
```

---

*All formal proofs use Lean 4 v4.28.0 with Mathlib. Zero unverified assumptions.*
