# SPB Research: New Theorems and Future Directions

## Overview

This directory contains **new formally verified research** extending the Stereographic Projection Bridge (SPB) framework with theorems about Chebyshev polynomials, finite fields, Wick rotation, and approximation theory.

**All 18+ theorems are fully verified in Lean 4 with zero `sorry` statements.**

## Lean 4 Files

### `ChebyshevConnection.lean` — Multiple Angle Theorem
- **`spbPow'_tan`**: The core multiple angle formula: spbPow(tan θ, n) = tan(nθ)
- **`tan_progression`**: tan(mθ) ⊕ tan(nθ) = tan((m+n)θ) via tangent addition
- **`spb_double_angle`**: spb(tan θ, tan θ) = tan(2θ)
- **`spb_triple_angle`**: spb(tan 2θ, tan θ) = tan(3θ)
- **`spbPow'_two_eq_double`**: spbPow(x, 2) = spb(x, x) — the doubling map

### `FiniteFields.lean` — SPB Over General Fields
- **`spbField_assoc`**: SPB is associative over any field
- **`spbField_denom_product`**: The cocycle identity for denominator products
- **`spbField_fixed_point`**: Fixed points of SPB are exactly √(−1), connecting to quadratic residues
- **`spbField_self`**: Self-application formula 2x/(1−x²)

### `WickRotation.lean` — Circular ↔ Hyperbolic Duality
- **`spbHyp_subluminal`**: Sub-luminal closure |v₁|,|v₂| < 1 ⟹ |v₁⊕v₂| < 1
- **`spbHyp_tanh_add`**: Rapidity linearization tanh(α) ⊕_H tanh(β) = tanh(α+β)
- **`tan_add_is_spbCirc`**: tan(α+β) = spbCirc(tan α, tan β)
- **`wick_sign_flip`**: The sign-flip relation connecting circular and hyperbolic SPB

### `Approximation.lean` — Function Approximation
- **`spb_generates_double_angle`**: SPB trees generate 2x/(1−x²)
- **`spbFunctions_closed_spb`**: SPB function algebra is closed under composition
- **`id_in_spbFunctions`**, **`const_in_spbFunctions`**: Identity and constants are in the algebra

## Python Demos (in `../Demos/`)
- `spb_explorer.py` — Comprehensive interactive demo (8 demonstrations)
- `spb_chebyshev_demo.py` — Multiple angle theorem and binary exponentiation
- `spb_finite_field_explorer.py` — SPB groups over F_p with Cayley tables
- `spb_relativistic_demo.py` — Einstein velocity addition and Wick rotation

## SVG Visuals (in `../Visuals/`)
- `spb_framework_overview.svg` — Grand overview of the SPB framework
- `spb_wick_rotation.svg` — Circular ↔ Hyperbolic duality diagram
- `spb_finite_field.svg` — Fixed points and quadratic residues
- `spb_chebyshev_connection.svg` — SPB → Chebyshev → Approximation chain

## Papers (in `../Papers/`)
- `spb_future_research.md` — Comprehensive research paper with 30+ directions
- `spb_scientific_american.md` — Accessible feature article

## Axiom Verification
All theorems depend only on standard axioms: `propext`, `Classical.choice`, `Quot.sound`.
