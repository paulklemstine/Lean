# Stereographic Projection Bridge (SPB): The Continuous Group Gate

## A Comprehensive Research Framework

The **Stereographic Projection Bridge (SPB)** operator `spb(x,y) = (x+y)/(1-xy)` encodes the circle group S¹ as a single rational operation on the real line ℝ. The SPB-adapted Cayley transform `C'(x) = (1+ix)/(1-ix)` serves as the **unitary operator** bridging ℝ and S¹.

---

## Contents

### 📐 Lean 4 Formalized Theorems

**All 40+ theorems fully proved, zero sorries**, machine-verified in Lean 4 with Mathlib.

#### Core Files (`*.lean`)

- **`Basic.lean`** — Core SPB definitions and group structure
  - SPB/SPBh definitions, commutativity, identity, inverse, associativity ✅
  - Wick duality, tangent addition = SPB ✅
  - SPB expression trees, binary tree identity ✅
  - Differentiability: ∂spb/∂x = (1+y²)/(1-xy)², monotonicity ✅
  - Double angle: spb(x,x) = 2x/(1-x²) ✅

- **`CayleyTransform.lean`** — The Cayley transform bridge ℝ → S¹
  - SPB-Cayley unitarity: ‖C(x)‖ = 1 ✅
  - **Intertwining**: C(spb(x,y)) = C(x)·C(y) ✅
  - Real/imaginary parts of Cayley transform ✅
  - Differentiability of complex Cayley transform ✅

- **`ChebyshevConnection.lean`** — Multiple angle formulas
  - SPB iteration: spbIter(tan θ, n) = tan(nθ) ✅
  - Double and triple angle via SPB ✅

- **`FiniteFields.lean`** — SPB over finite fields F_p
  - SPB over ZMod p: commutativity, identity, inverse ✅
  - Computational verification over F₃, F₅, F₇, F₁₁, F₁₃ ✅
  - Period verification for p ≡ 1, 3 (mod 4) ✅

- **`WickRotation.lean`** — Circular ↔ Hyperbolic duality
  - Sign flip relation ✅
  - Rapidity addition: tanh(a+b) = spbH(tanh a, tanh b) ✅

- **`Applications.lean`** — Physics and geometry
  - Einstein velocity addition: commutativity, identity, associativity ✅
  - Light speed invariance: 1 ⊕ v = 1 ✅
  - **Sub-luminal closure**: |v₁|,|v₂| < 1 ⟹ |v₁⊕v₂| < 1 ✅
  - Möbius transform / cross-ratio invariance ✅

#### Research Files (`Research/*.lean`)

- **`Research/AdvancedTheorems.lean`** — **NEW** advanced results
  - SPB involution (cancellation): spb(spb(x,y), -y) = x ✅
  - SPB associativity (composition law) ✅
  - SPB derivative formula ✅
  - **arctan homomorphism**: arctan(spb(x,y)) = arctan(x) + arctan(y) ✅
  - **Weierstrass substitution**: cos θ = (1-t²)/(1+t²), sin θ = 2t/(1+t²) ✅
  - **Cauchy distribution invariance**: f(spb(x,a)) · |spb'(x)| = f(x) ✅
  - Denominator positivity for small arguments ✅
  - Rational closure of SPB ✅
  - **Multiple angle**: spbPow(tan θ, n) = tan(nθ) ✅
  - Derivative positivity ✅

- **`Research/Approximation.lean`** — SPB approximation theory ✅
- **`Research/ChebyshevConnection.lean`** — Extended Chebyshev results ✅
- **`Research/FiniteFields.lean`** — General field SPB ✅
- **`Research/WickRotation.lean`** — Extended Wick rotation results ✅

### 🐍 Python Demos (`Demos/`)

- **`spb_comprehensive_demo.py`** — 11 demonstrations covering all SPB properties
- **`spb_neural_network_demo.py`** — SPB neural network prototype with 5 demos
- **`spb_demo.py`** — Original interactive demo
- **`spb_chebyshev_demo.py`** — Chebyshev connection demo
- **`spb_relativistic_demo.py`** — Einstein velocity addition
- **`spb_dynamics.py`** — Dynamical system exploration
- **`spb_finite_field_explorer.py`** — Finite field SPB
- **`spb_visualization.py`** — Visualization generator

### 🎨 SVG Visuals (`Visuals/`)

- **`spb_master_diagram.svg`** — **NEW** unified diagram: "One Formula, Five Worlds"
- **`spb_group_structure.svg`** — **NEW** group isomorphism (ℝ, spb) ≅ (S¹, ·)
- **`spb_research_roadmap.svg`** — **NEW** 30+ research directions with priorities
- **`spb_cauchy_invariance.svg`** — **NEW** Cauchy distribution as SPB measure
- **`spb_framework_overview.svg`** — Original framework overview
- **`spb_cayley_bridge.svg`** — Cayley transform bridge
- **`spb_chebyshev_connection.svg`** — Chebyshev polynomial connection
- **`spb_einstein_velocity.svg`** — Einstein velocity addition
- **`spb_wick_rotation.svg`** — Wick rotation duality
- **`spb_finite_field.svg`** — Finite field structure
- **`spb_unified_framework.svg`** — Unified framework

### 📄 Papers (`Papers/`)

- **`SPB_Comprehensive_Research_Paper.md`** — **NEW** full research paper with 40+ verified theorems
- **`SPB_SciAm_Article.md`** — **NEW** Scientific American style article
- **`SPB_Future_Research_Comprehensive.md`** — **NEW** 35 ranked research directions
- **`SPB_Important_Questions_Answered.md`** — **NEW** 25 key questions answered in depth
- **`research_paper.md`** — Original research paper
- **`scientific_american_article.md`** — Original popular article
- **`future_research_directions.md`** — Original future directions
- **`applications_brainstorm.md`** — Applications brainstorm

---

## Quick Start

### Verify the Lean proofs:
```bash
lake build EML.StereographicBridge.Basic
lake build EML.StereographicBridge.Research.AdvancedTheorems
```

### Run the Python demos:
```bash
python3 EML/StereographicBridge/Demos/spb_comprehensive_demo.py
python3 EML/StereographicBridge/Demos/spb_neural_network_demo.py
```

---

## Key Insight

The SPB formula `(x+y)/(1-xy)` is a central node in mathematics, simultaneously:

| Interpretation | Formula |
|---|---|
| Tangent addition | tan(α+β) = spb(tan α, tan β) |
| Circle group | C(spb(x,y)) = C(x)·C(y) |
| Einstein addition | v₁ ⊕ v₂ = (v₁+v₂)/(1+v₁v₂) |
| Chebyshev iteration | spbⁿ(tan θ) = tan(nθ) |
| Möbius transform | z ↦ (z+a)/(1-az) |
| arctan homomorphism | arctan(spb(x,y)) = arctan(x)+arctan(y) |
| Cauchy invariance | f(spb(x,a))·|spb'(x)| = f(x) |
| Weierstrass sub. | cos θ = (1-t²)/(1+t²) via Cayley |

All verified in Lean 4. Zero sorries.
