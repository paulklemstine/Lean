# Research Notes — Oracle II (Prometheus): Hypothesis Development

## The Central Hypothesis

### Version 0.1 — First Sketch

**Naive idea:** Gravity is "just" the Poincaré algebra.
**Problem:** The Poincaré algebra only describes flat spacetime. Curvature requires more.

### Version 0.2 — Adding Curvature

**Better idea:** Extend the Poincaré algebra to include curvature as an algebraic element.

The Riemann tensor R^a_{b c d} has the symmetries of a Young tableau ⊞⊞.
In the Lorentz algebra representation, it decomposes as:
- Weyl tensor (traceless, 10 components) — gravitational radiation
- Ricci tensor (trace, 10 components) — matter coupling
- Ricci scalar (double trace, 1 component) — total curvature

These should live in a specific grade of our algebra.

### Version 0.3 — The Five-Graded Structure

**Insight from MacDowell-Mansouri:** The key is that [P, P] ≠ 0 in de Sitter.
The "failure of translations to commute" IS curvature.

This suggests a natural grading:

```
𝔊 = 𝔊₋₂ ⊕ 𝔊₋₁ ⊕ 𝔊₀ ⊕ 𝔊₁ ⊕ 𝔊₂

Grade  | Content              | Dimension | Physical meaning
-------|----------------------|-----------|------------------
  -2   | Curvature elements   | 20        | Riemann tensor components
  -1   | Translation elements | 4         | Vierbein / position
   0   | Lorentz elements     | 6         | Rotations and boosts
  +1   | Momentum elements    | 4         | Energy-momentum
  +2   | Matter elements      | 20        | Stress-energy components
```

Total dimension: 20 + 4 + 6 + 4 + 20 = **54**

### Version 0.4 — Bracket Structure (Detailed)

Let {M_ab} be the Lorentz generators (a,b = 0,1,2,3), {P_a} be translations,
{Q^a} be momentum generators, {R_abcd} be curvature generators, {T^abcd} be
matter generators.

**Grade-preserving brackets (well-established):**
```
[M_ab, M_cd] = η_ac M_bd - η_ad M_bc - η_bc M_ad + η_bd M_ac    (𝔰𝔬(3,1))
[M_ab, P_c]  = η_ac P_b - η_bc P_a                                (vector rep)
[M_ab, Q^c]  = δ^c_a Q_b - δ^c_b Q_a                              (covector rep)
```

**The critical new brackets:**
```
[P_a, P_b] = λ R_ab        where R_ab ∈ 𝔊₋₂ (curvature from non-commuting translations)
[Q^a, Q^b] = μ T^ab        where T^ab ∈ 𝔊₂ (stress-energy from non-commuting momenta)
[P_a, Q^b] = δ^b_a Λ·I + M_a^b   (translation-momentum gives Lorentz + cosmological term)
```

**The Einstein bracket:**
```
[R_ab, T^cd] = δ^c_[a δ^d_b] · κ · (some element of 𝔊₀)
```
This vanishes iff the Einstein equation holds! The field equation is an
**algebraic closure condition**: the bracket of curvature with matter must
close back into the Lorentz sector in a specific way.

### Version 0.5 — Jacobi Identity Check

For the algebra to be consistent, the Jacobi identity must hold:

[[X, Y], Z] + [[Y, Z], X] + [[Z, X], Y] = 0

Critical cases to check:
1. [P, P, P]: [[P_a, P_b], P_c] + cyclic = 0
   → λ[R_ab, P_c] + cyclic = 0
   → This constrains [R, P] — it must be the Bianchi identity!

2. [P, P, Q]: [[P_a, P_b], Q^c] + cyclic = 0
   → This gives the contracted Bianchi identity ∇_μ G^μν = 0
   → Which is the conservation law ∇_μ T^μν = 0

3. [Q, Q, Q]: [[Q^a, Q^b], Q^c] + cyclic = 0
   → Conservation of stress-energy

**REMARKABLE:** The Jacobi identity of 𝔊 automatically encodes:
- The Bianchi identity (from [P,P,P])
- Energy-momentum conservation (from [P,P,Q] and [Q,Q,Q])
- The Einstein equation as a consistency condition

### Version 0.6 — Connection to Known Physics

**Flat spacetime limit (Λ → 0):**
Set λ = 0. Then [P_a, P_b] = 0, and 𝔊 contracts to the Poincaré algebra
plus decoupled curvature and matter sectors. This is the Inönü-Wigner
contraction, recovering special relativity.

**Newtonian limit (c → ∞):**
Further contract the Lorentz sector: boosts become Galilean boosts.
The algebra contracts to the Bargmann algebra (central extension of Galilei)
plus a Newtonian curvature sector. The Poisson equation ∇²Φ = 4πGρ
emerges from the contracted Einstein bracket.

**de Sitter limit (no matter):**
Set T = 0. Then 𝔊 reduces to the de Sitter algebra 𝔰𝔬(4,1) extended by
the Weyl curvature sector. This is exactly MacDowell-Mansouri gravity.

**Quantization pathway:**
The universal enveloping algebra U(𝔊) provides a natural quantization.
The Casimir operators of 𝔊 classify irreducible representations, which
correspond to quantum states of the gravitational field. The mass and
spin Casimirs of the Poincaré subalgebra are retained.

## Summary of Hypothesis

**The Gravitational Algebra 𝔊 is a 54-dimensional ℤ-graded Lie algebra
whose structure encodes the complete dynamics of classical gravity.
The Einstein equation, Bianchi identity, and energy-momentum conservation
are all consequences of the Jacobi identity of 𝔊.**
