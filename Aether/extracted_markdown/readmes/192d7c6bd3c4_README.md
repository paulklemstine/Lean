# Stereographic Projection Bridge (SPB)

## The Formula That Connects Everything

```
spb(x, y) = (x + y) / (1 - xy)
```

This single formula simultaneously **is**:
- The **tangent addition** law: `tan(α+β) = spb(tan α, tan β)`
- The **circle group** transferred to ℝ via stereographic projection
- A **Möbius transformation**: `z ↦ (z + a)/(-az + 1)`
- (With sign flip) **Einstein's velocity addition**: `spbH(v₁,v₂) = (v₁+v₂)/(1+v₁v₂)`

## Directory Structure

### Lean 4 Formalizations
| File | Contents | Status |
|------|----------|--------|
| `Basic.lean` | Core SPB definitions, group axioms, tangent connection, derivatives | ✅ Verified |
| `CayleyTransform.lean` | Cayley unitarity, intertwining property, real/imaginary parts | ✅ Verified |
| `Applications.lean` | Einstein velocity, Möbius transformations, cross-ratio invariance | ✅ Verified |
| `ChebyshevConnection.lean` | Multiple angle formulas, iterated SPB, Chebyshev recurrence | ✅ Verified |
| `FiniteFields.lean` | SPB over ZMod p, computational verification of periodicity | ✅ Verified |
| `WickRotation.lean` | Circular-hyperbolic duality, rapidity addition theorem | ✅ Verified |

### Python Demos (`Demos/`)
- `spb_demo.py` — Comprehensive demonstration suite (8 demos with visualizations)
- `spb_finite_field_explorer.py` — Detailed analysis of SPB groups over finite fields

### SVG Visuals (`Visuals/`)
- `spb_unified_framework.svg` — The SPB as a nexus connecting 7 mathematical domains
- `spb_wick_rotation.svg` — Circular ↔ Hyperbolic duality diagram
- `spb_chebyshev_tree.svg` — SPB expression trees and Chebyshev polynomials
- `spb_einstein_velocity.svg` — Einstein velocity addition visualization
- `spb_stereographic_geometry.svg` — Geometric stereographic projection

### Research Papers (`Papers/`)
- `SPB_Future_Research_Directions.md` — Comprehensive research roadmap (30+ open problems)
- `SPB_Scientific_American.md` — Popular science article

## Key Results

### Formalized (Machine-Verified)
1. **Group Structure**: SPB is commutative, associative, has identity 0, inverse -x
2. **Cayley Intertwining**: C'(spb(x,y)) = C'(x) · C'(y) (group homomorphism)
3. **Unitarity**: |C'(x)| = 1 for all real x
4. **Tangent Addition**: tan(α+β) = spb(tan α, tan β)
5. **Einstein Addition**: Commutative, associative, sub-luminal closure, light invariance
6. **Rapidity**: tanh(a+b) = spbH(tanh a, tanh b) — rapidity is additive
7. **Monotonicity**: ∂spb/∂x = (1+y²)/(1-xy)² > 0 always
8. **Cross-Ratio**: Invariant under Möbius transformations
9. **Multiple Angle**: spb(tan θ, tan θ) = tan(2θ), extends to triple angle
10. **Finite Fields**: SPB iteration periods verify the p±1 group order law

### New Theoretical Results
1. **SPB over 𝔽_p**: Group order is p+1 (p≡3 mod 4) or p-1 (p≡1 mod 4)
2. **Chebyshev Connection**: spb^n(tan θ) = tan(nθ); generates Chebyshev evaluations
3. **SPB Complexity**: K_SPB(tan nθ) = addition chain length for n ≈ ⌈log₂ n⌉
4. **Wick Functoriality**: Identity map is a "Wick homomorphism" between spb and spbH
5. **SPB Approximation**: SPB trees are dense in C[-1,1] (via Chebyshev + Weierstrass)

## Connection to EML

| Property | EML: eˣ - ln y | SPB: (x+y)/(1-xy) |
|----------|----------------|--------------------|
| Domain | Arithmetic | Geometry |
| Bridges | Addition ↔ Multiplication | Euclidean ↔ Spherical |
| Group | Non-commutative | Commutative (abelian) |
| Transform | exp / log | Cayley / stereographic |
| Generates | All elementary functions | All Möbius/Chebyshev |
