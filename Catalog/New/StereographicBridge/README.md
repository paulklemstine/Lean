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

### Lean 4 Formalizations (25+ Theorems, Zero Sorries)
| File | Contents | Status |
|------|----------|--------|
| `Basic.lean` | Core SPB definitions, group axioms, tangent connection, derivatives, expression trees | ✅ Verified |
| `CayleyTransform.lean` | Cayley unitarity, intertwining property, real/imaginary parts, differentiability | ✅ Verified |
| `Applications.lean` | Einstein velocity addition, Möbius transformations, cross-ratio invariance | ✅ Verified |
| `ChebyshevConnection.lean` | Multiple angle formulas, iterated SPB, Chebyshev recurrence | ✅ Verified |
| `FiniteFields.lean` | SPB over ZMod p, computational verification of periodicity | ✅ Verified |
| `WickRotation.lean` | Circular-hyperbolic duality, rapidity addition theorem | ✅ Verified |
| `SPBIteration.lean` | **NEW** Multiple angle theorem (spb^n(tan θ) = tan(nθ)), power law, Cauchy density | ✅ Verified |
| `AdvancedTheorems.lean` | **NEW** Sub-luminal closure, fixed points, arctangent addition, algebraic identities | ✅ Verified |
| `EMLSPBBridge.lean` | **NEW** EML-SPB dual operator system, tanh homomorphism, Weierstrass substitution | ✅ Verified |

### Python Demos (`Demos/`)
- `spb_demo.py` — Comprehensive demonstration suite (8 demos with visualizations)
- `spb_finite_field_explorer.py` — Detailed analysis of SPB groups over finite fields
- `spb_advanced_research.py` — **NEW** 10 advanced research demos:
  - SPB iteration = tan(nθ) verification
  - Finite field group structure (p±1 law)
  - Cauchy distribution invariance
  - SPB approximation theorem (density in C[-1,1])
  - Addition chain complexity
  - Rapidity addition
  - Wick rotation visualization
  - Fixed point analysis
  - EML-SPB duality
  - Stereographic projection & Cayley transform

### SVG Visuals (`Visuals/`)
- `spb_unified_framework.svg` — The SPB as a nexus connecting 7 mathematical domains
- `spb_wick_rotation.svg` — Circular ↔ Hyperbolic duality diagram
- `spb_chebyshev_tree.svg` — SPB expression trees and Chebyshev polynomials
- `spb_einstein_velocity.svg` — Einstein velocity addition visualization
- `spb_stereographic_geometry.svg` — Geometric stereographic projection
- `spb_research_roadmap.svg` — **NEW** Complete research roadmap with 30+ problems
- `spb_group_structure.svg` — **NEW** Finite field group structure classification

### Research Papers (`Papers/`)
- `SPB_Research_Paper.md` — **NEW** Comprehensive research paper (14 sections)
- `SPB_Future_Research_Directions.md` — **UPDATED** 40+ open problems, priority rankings
- `SPB_Scientific_American.md` — **UPDATED** Popular science article

## Key Results

### Formalized in Lean 4 (Machine-Verified)

**Core Algebra:**
1. SPB is commutative, associative, has identity 0, inverse -x
2. SPB expression tree leaf-node identity

**Cayley Transform:**
3. Cayley unitarity: |C'(x)| = 1 for all real x
4. Cayley intertwining: C'(spb(x,y)) = C'(x) · C'(y)
5. Real and imaginary parts of the Cayley transform

**Trigonometry:**
6. Tangent addition: tan(α+β) = spb(tan α, tan β)
7. **Multiple angle formula: spb^n(tan θ) = tan(nθ)** ← NEW
8. **SPB power law: spb^(m+n) = spb(spb^m, spb^n)** ← NEW
9. Double and triple angle formulas
10. **Arctangent addition: arctan(spb(x,y)) = arctan(x) + arctan(y)** ← NEW

**Special Relativity:**
11. Einstein velocity addition: commutative, associative
12. **Sub-luminal closure: |v₁|,|v₂| < 1 ⟹ |spbH(v₁,v₂)| < 1** ← NEW
13. Light speed invariance: spbH(1, v) = 1
14. Rapidity addition: tanh(a+b) = spbH(tanh a, tanh b)

**Analysis:**
15. Monotonicity: ∂spb/∂x = (1+y²)/(1-xy)² > 0
16. **No fixed points: spb(x, a) ≠ x when a ≠ 0** ← NEW
17. **Cauchy density positivity** ← NEW

**Algebraic Identities:** ← NEW
18. **Product rule: spb(x,y) · spb(x,-y) = (x²-y²)/(1-x²y²)**
19. **Difference rule: spb(x,y) - spb(x,-y) = 2y(1+x²)/(1-x²y²)**

**EML-SPB Bridge:** ← NEW
20. **tanh homomorphism from (ℝ,+) to ((-1,1), spbH)**
21. **Weierstrass substitution via hyperbolic SPB**
22. **EML-SPB associativity with cross-denominator conditions**

**Geometry:**
23. SPB as Möbius transformation
24. Cross-ratio invariance under Möbius transformations

**Finite Fields:**
25. SPB over ZMod p — computational verification of group orders

### Computationally Verified
- Finite field group orders for all primes p < 50
- SPB iteration accuracy to machine precision
- Cauchy distribution invariance under SPB dynamics

## How to Build

```bash
lake build EML.StereographicBridge.Basic
lake build EML.StereographicBridge.CayleyTransform
lake build EML.StereographicBridge.Applications
lake build EML.StereographicBridge.ChebyshevConnection
lake build EML.StereographicBridge.FiniteFields
lake build EML.StereographicBridge.WickRotation
lake build EML.StereographicBridge.SPBIteration
lake build EML.StereographicBridge.AdvancedTheorems
lake build EML.StereographicBridge.EMLSPBBridge
```

## Citation

If you use this work, please cite:
```
@software{spb_framework,
  title = {The Stereographic Projection Bridge: A Universal Algebraic Gate},
  year = {2025},
  description = {Machine-verified formalization of the SPB framework in Lean 4},
}
```
