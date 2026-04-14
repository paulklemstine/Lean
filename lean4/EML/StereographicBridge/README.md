# Stereographic Projection Bridge (SPB): The Continuous Group Gate

## A Framework Combining Inverse and Regular Stereographic Projection as the Unitary Operator

This directory contains a comprehensive research exploration of the **Stereographic Projection Bridge (SPB)** operator `spb(x,y) = (x+y)/(1-xy)`, which encodes the circle group S¹ as a single rational operation on the real line ℝ. The SPB-adapted Cayley transform `C'(x) = (1+ix)/(1-ix)` serves as the **unitary operator** bridging ℝ and S¹.

---

## Contents

### 📐 Lean 4 Formalized Theorems (`*.lean`)

Machine-verified proofs — **all 30+ theorems fully proved, zero sorries**:

- **`Basic.lean`** — Core SPB definitions and group structure
  - SPB definition: `spb(x,y) = (x+y)/(1-xy)` ✅
  - Hyperbolic SPB: `spbH(x,y) = (x+y)/(1+xy)` ✅
  - `spb_comm`: SPB is commutative ✅
  - `spb_zero_right/left`: 0 is the identity ✅
  - `spb_neg_right`: -x is the inverse ✅
  - `spb_assoc`: SPB is associative ✅
  - `spbH_comm/zero_right/neg_right/assoc`: Hyperbolic SPB group axioms ✅
  - `wick_duality`: spb(x,-y) = (x-y)/(1+xy) ✅
  - `tan_add_eq_spb`: tan(α+β) = spb(tan α, tan β) ✅
  - `spb_self`: spb(x,x) = 2x/(1-x²) ✅
  - `spb_tan_double`: spb(tan θ, tan θ) = tan(2θ) ✅
  - `spb_hasDerivAt_fst/snd`: ∂spb/∂x = (1+y²)/(1-xy)² ✅
  - `spb_deriv_fst_pos/snd_pos`: Derivatives always positive ✅
  - `SPBExpr.leaf_eq_node_succ`: Binary tree identity ✅

- **`CayleyTransform.lean`** — The unitary bridge ℝ → S¹
  - SPB-adapted Cayley: `C'(x) = (1+ix)/(1-ix)` ✅
  - Standard Cayley: `C(x) = (x-i)/(x+i)` ✅
  - `spbCayley_norm_eq_one`: ‖C'(x)‖ = 1 (unitarity!) ✅
  - `spbCayley_normSq_eq_one`: normSq(C'(x)) = 1 ✅
  - `stdCayley_norm_eq_one`: ‖C(x)‖ = 1 ✅
  - `spbCayley_zero`: C'(0) = 1 (identity maps to identity) ✅
  - `spbCayley_intertwines`: C'(spb(x,y)) = C'(x)·C'(y) ✅ **[Key theorem!]**
  - `spbCayley_re`: Re(C'(x)) = (1-x²)/(1+x²) ✅
  - `spbCayley_im`: Im(C'(x)) = 2x/(1+x²) ✅
  - `stdCayley_re/im`: Components of C(x) ✅
  - `spbCayley_eq_neg_stdCayley`: C'(x) = -C(x) ✅
  - `spbCayleyC_differentiableAt`: C' is differentiable ✅

- **`Applications.lean`** — Physics and geometry connections
  - `einstein_comm/zero/neg/assoc`: Einstein velocity addition group axioms ✅
  - `einstein_light_invariance`: c ⊕ v = c ✅
  - `einstein_subluminal`: |v₁|,|v₂| < 1 ⟹ |v₁⊕v₂| < 1 ✅
  - `spb_is_mobius`: SPB is a Möbius transformation ✅
  - `cayley_is_mobius`: Cayley is a Möbius transformation ✅
  - `crossRatio_mobius_invariant`: Cross-ratio Möbius invariance ✅
  - `poincare_translation_real`: Poincaré disk translation ✅
  - `spbPow_one/two`: Iterated SPB ✅

### 🐍 Python Demos (`Demos/`)

- **`spb_calculator.py`** — Complete SPB calculator and comparison tool
  - Cayley transform visualization (ℝ → S¹ mapping)
  - Intertwining property verification: C(spb(x,y)) = C(x)·C(y)
  - Einstein velocity addition demonstrations
  - Rapidity additivity verification
  - Chebyshev polynomial connection (iterated SPB = multiple angle)
  - Wick rotation duality (circular ↔ hyperbolic)
  - SPB number tower (constants from {0, 1})
  - EML vs SPB side-by-side comparison

- **`spb_dynamics.py`** — Dynamical systems explorer
  - Fixed point analysis (no real fixed points — rotation!)
  - Orbit structure (periodic for rational rotation, dense for irrational)
  - Lyapunov exponent (zero — pure rotation, no chaos)
  - Phase portrait on the Cayley circle
  - Circular → hyperbolic transition analysis
  - Continued fraction connection

- **`spb_visualization.py`** — ASCII and conceptual visualizations
  - Stereographic projection geometry
  - Cayley circle mapping
  - SPB orbit visualization (regular polygon orbits)
  - SPB expression tree diagrams
  - EML ↔ SPB bridge diagram

### 🎨 SVG Visuals (`Visuals/`)

- **`spb_cayley_bridge.svg`** — The Cayley transform as unitary bridge ℝ → S¹
- **`spb_wick_rotation.svg`** — Circular ↔ Hyperbolic duality via Wick rotation
- **`spb_eml_comparison.svg`** — EML vs SPB: two pillars of universal operators
- **`spb_stereographic_geometry.svg`** — Geometric construction of stereographic projection
- **`spb_applications_map.svg`** — Application areas radiating from the SPB
- **`spb_tree_tan3.svg`** — SPB tree computing tan(3θ)

### 📄 Research Papers (`Papers/`)

- **`research_paper.md`** — Full research paper with new theorems, conjectures, and formal results
- **`scientific_american_article.md`** — Accessible popular science article: "The Formula That Links Trigonometry to Einstein's Relativity"
- **`future_research_directions.md`** — 30+ research directions across 6 categories
- **`applications_brainstorm.md`** — 50 application ideas across 10 categories
- **`important_questions_answered.md`** — 20 deep questions about SPB, answered

---

## Key Results

### Proven in Lean 4 (All ✅, Zero Sorries):
1. SPB forms an abelian group: commutative, associative, identity 0, inverse -x
2. **Unitarity**: ‖C'(x)‖ = 1 for all x ∈ ℝ (Cayley maps to unit circle)
3. **Intertwining**: C'(spb(x,y)) = C'(x) · C'(y) (group homomorphism!)
4. tan(α+β) = spb(tan α, tan β) (tangent addition IS the SPB)
5. spb(tan θ, tan θ) = tan(2θ) (double angle formula)
6. ∂spb/∂x = (1+y²)/(1-xy)² > 0 (SPB is monotone)
7. Einstein velocity addition satisfies all group axioms
8. Speed of light is invariant: 1 ⊕ v = 1
9. Sub-luminal closure: |v₁|,|v₂| < 1 ⟹ |v₁⊕v₂| < 1
10. Cross-ratio is Möbius-invariant
11. Wick duality: spb(x,-y) = (x-y)/(1+xy)

### Discovered:
1. SPB iteration = rotation on S¹ (Lyapunov exponent = 0)
2. No real fixed points of SPB iteration (x² = -1 has no real solutions)
3. Period-n orbits when a = tan(π/n) (regular polygon on Cayley circle)
4. The two Cayley conventions (standard vs SPB-adapted) differ by negation: C'(x) = -C(x)
5. SPB(x,x) generates Chebyshev polynomials via multiple-angle formulas

### 7 New Conjectures:
1. SPB-Chebyshev optimality: minimal tree depth for tan(nθ) is ⌈log₂ n⌉
2. SPB universality for Möbius: every Möbius can be built from SPB + constants
3. EML-SPB completeness: combined system generates all elementary functions AND Möbius
4. Quantum SPB gate universality for CV quantum computing
5. Higher-dimensional SPB from Sⁿ → ℝⁿ encodes SO(n+1)
6. SPB complexity of p(x)/q(x) equals deg(p) + deg(q) - 1
7. Wick rotation functoriality between representation categories

---

## Quick Start

```bash
# Run the SPB calculator demo
python3 EML/StereographicBridge/Demos/spb_calculator.py

# Explore SPB dynamics
python3 EML/StereographicBridge/Demos/spb_dynamics.py

# Build the Lean proofs
lake build EML.StereographicBridge.Basic EML.StereographicBridge.CayleyTransform EML.StereographicBridge.Applications
```

---

## The Big Picture

| Property | EML (Arithmetic Bridge) | SPB (Geometric Bridge) |
|---|---|---|
| **Formula** | exp(x) - ln(y) | (x+y)/(1-xy) |
| **Bridges** | Addition ↔ Multiplication | Real line ↔ Unit circle |
| **Unitary operator** | exp(iθ) | Cayley transform C'(x) |
| **Group structure** | Non-associative | Abelian group |
| **Generates** | All elementary functions | Circle group S¹ |
| **Key identity** | e = eml(1,1) | tan(α+β) = spb(tan α, tan β) |
| **Discrete analogue** | NAND gate | XOR gate |
| **Physics** | Entropy, information | Relativity, quantum phase |
| **Sign flip** | — | Wick rotation: (1-xy) ↔ (1+xy) |

Together, EML and SPB form the **two pillars** of a unified theory of continuous universal operators.
