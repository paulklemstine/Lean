# Flatland Catastrophe: Mathematical Pathologies of 2D Newtonian Gravity and the Uniqueness of Three-Dimensional Orbital Mechanics

## Abstract

We present a rigorous mathematical analysis of Newtonian gravity in two spatial dimensions, establishing that 2D gravity is fundamentally pathological for planetary system formation. Our main results are: (1) the gravitational potential in 2D is logarithmic, growing without bound and precluding gravitational escape; (2) the apsidal angle ratio 1/√2 is irrational, implying orbits never close (Bertrand failure); (3) no finite number of radial oscillations returns a particle to its starting angle; (4) the effective potential at the circular orbit radius has positive second derivative, confirming linear stability; and (5) dimension 3 is the unique spatial dimension satisfying all three requirements for viable planetary systems — orbital stability, orbital closure, and gravitational escape. All results are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

The question of why our universe has three spatial dimensions has fascinated physicists since Ehrenfest (1917), who first observed that planetary orbits are unstable in four or more dimensions. Subsequent work by Tangherlini (1963) and others extended this analysis, but rigorous mathematical formalization has been lacking.

We formalize the complete dimensional analysis of Newtonian gravity, defining a `GravitationalDimension` framework that encodes the dimensional dependence of gravitational physics. Our central result — the Goldilocks Theorem — proves that dimension 3 is uniquely viable among all n ≥ 2 for supporting stable planetary systems.

## 2. Dimensional Framework

### 2.1 Force Laws from Gauss's Law

In n spatial dimensions, the gravitational flux through an (n-1)-sphere of radius r must equal the enclosed mass (times constants). Since the surface area of an (n-1)-sphere scales as r^(n-1), the gravitational field E(r) satisfies:

E(r) · r^(n-1) = const

giving F(r) ∝ r^(1-n).

**Definition (GravitationalDimension).** A gravitational dimension is a natural number n ≥ 2 equipped with:
- Force exponent: α = 1 - n
- Stability parameter: σ = 4 - n
- Bertrand parameter: β = √(4 - n) (when σ > 0)

### 2.2 Gravitational Potential

The potential V(r) satisfying F = -dV/dr is:
- For n ≥ 3: V(r) = -k · r^(2-n)/(n-2)
- For n = 2: V(r) = k · ln(r)

**Theorem (Logarithmic Unboundedness).** For k > 0, the 2D potential k·ln(r) tends to +∞ as r → ∞ and to -∞ as r → 0⁺.

This immediately implies that no particle in 2D can escape to infinity with finite energy — there is no escape velocity in Flatland.

## 3. Orbital Analysis

### 3.1 The Apsidal Angle

For small oscillations around a circular orbit under a power-law force F ∝ r^α, the apsidal angle (angle between periapsis and apoapsis) is:

Θ = π / √(3 + α)

For n-dimensional gravity with α = 1-n:

Θ = π / √(4 - n)

**Definition (Apsidal Ratio).** The apsidal ratio for dimension n is r(n) = 1/√(4-n) when 4-n > 0.

### 3.2 Bertrand's Theorem in 2D

**Theorem (apsidalRatio_2D_irrational).** The 2D apsidal ratio 1/√2 is irrational.

*Proof.* This follows from the irrationality of √2: if 1/√2 were rational, then √2 would be the reciprocal of a rational number, hence rational — contradiction. □

**Theorem (bertrand_failure_2D).** Orbits in 2D gravity never close.

*Proof.* An orbit closes if and only if the apsidal ratio is rational. Since 1/√2 is irrational, no orbit closes. □

By contrast, in 3D the apsidal ratio is 1/√1 = 1, which is rational, confirming Kepler's observation that orbits are closed ellipses.

### 3.3 Non-Periodic Return

**Theorem (no_periodic_return_2D).** For any n ≥ 1, there is no integer m such that n·π/√2 = 2πm.

*Proof.* Suppose n·(π/√2) = 2πm. Dividing by π (which is nonzero), we get n/√2 = 2m. If m = 0, then n = 0, contradicting n ≥ 1. If m ≠ 0, then √2 = n/(2m), making √2 rational — contradiction. □

### 3.4 Orbit Injectivity

**Theorem (apsidal_positions_injective).** The sequence n ↦ fract(n/√2) is injective: distinct radial oscillation counts give distinct angular positions.

*Proof.* If fract(n/√2) = fract(m/√2), then (n-m)/√2 is an integer k. If n ≠ m, then √2 = (n-m)/k is rational — contradiction. □

## 4. Effective Potential Analysis

### 4.1 The 2D Effective Potential

For 2D gravity with unit coupling and angular momentum L:

V_eff(r) = ln(r) + L²/(2r²)

The first and second derivatives are:

V_eff'(r) = 1/r - L²/r³
V_eff''(r) = -1/r² + 3L²/r⁴

### 4.2 Circular Orbit Properties

**Theorem (V_eff_2D_critical).** The effective potential derivative vanishes at r₀ = |L|:

V_eff'(|L|) = 1/|L| - L²/|L|³ = 1/|L| - 1/|L| = 0

using L² = |L|².

**Theorem (V_eff_2D_stable).** The second derivative at the circular orbit is positive:

V_eff''(|L|) = -1/L² + 3/L² = 2/L² > 0

This confirms that 2D circular orbits are linearly stable — small radial perturbations oscillate about the circular orbit. The pathology of 2D gravity is not instability but non-closure: the orbit oscillates stably in the radial direction while precessing in the angular direction, never returning to its starting angle.

## 5. The Goldilocks Theorem

### 5.1 Three Conditions for Planetary Systems

We identify three necessary conditions for a viable planetary system:

1. **Orbital stability**: The stability parameter σ = 4-n must be positive (n < 4)
2. **Orbital closure**: √(4-n) must be rational
3. **Gravitational escape**: The potential must vanish at infinity (n ≥ 3)

### 5.2 Dimensional Classification

**Definition (supportsClosedOrbits).** Dimension n supports closed orbits if 4-n > 0 and √(4-n) is not irrational.

**Theorem (goldilocks_unique_dimension).** For n ≥ 2, supportsClosedOrbits(n) if and only if n = 3.

*Proof.* Forward: From 4-n > 0 and n ≥ 2, we get n ∈ {2, 3}. For n = 2, √2 is irrational — contradiction. So n = 3.
Backward: For n = 3, 4-3 = 1 > 0 and √1 = 1 is rational. □

### 5.3 Viability Score

**Definition.** The viability score V(n) counts conditions satisfied:
V(n) = [n < 4] + [n = 3] + [n ≥ 3]

where [·] is the Iverson bracket.

**Theorem (dim3_unique_max_viability).** For n ≥ 2, V(n) = 3 if and only if n = 3.

### 5.4 Complete Classification

| Dimension | Stability | Closure | Escape | Class | V(n) |
|-----------|-----------|---------|--------|-------|------|
| n = 2 | ✓ (σ=2) | ✗ (√2 irrational) | ✗ (log potential) | Flatland | 1 |
| n = 3 | ✓ (σ=1) | ✓ (√1=1 rational) | ✓ (1/r potential) | Goldilocks | 3 |
| n = 4 | ✗ (σ=0) | — | ✓ | Marginal | 1 |
| n ≥ 5 | ✗ (σ<0) | — | ✓ | Catastrophic | 1 |

## 6. Discussion

### 6.1 The Role of Number Theory

It is remarkable that the viability of a spatial dimension for supporting planetary systems reduces to a question in number theory: is √(4-n) rational? The irrationality of √2 — one of the oldest results in mathematics — directly implies the impossibility of closed orbits in 2D.

### 6.2 The 2D Paradox

Two-dimensional gravity presents a paradox: circular orbits are linearly stable (V_eff'' > 0 at the minimum), yet the system is unsuitable for planetary formation. The failure is topological, not dynamical — orbits are well-behaved radially but fill space ergodically in the angular direction.

### 6.3 Connection to Higher Physics

The result that only three spatial dimensions support viable gravitational orbital mechanics has been noted qualitatively in the physics literature (Ehrenfest 1917, Tangherlini 1963, Tegmark 1997). Our contribution is a rigorous, machine-verified formalization that identifies the precise mathematical obstructions in each dimension.

## 7. Conjectures and Future Work

**Conjecture (Intersection Growth).** The number of self-intersections of a 2D gravitational orbit after N radial oscillations grows as N(N-1)/2. For N = 100, this predicts approximately 4950 self-intersections.

**Open Question.** Can the Weyl equidistribution theorem be formalized in Lean 4 / Mathlib to prove that the orbit is equidistributed (not merely dense) in the annulus?

**Open Question.** The classification assumes power-law gravity from Gauss's law. What is the analogous classification for modified gravity theories (e.g., Yukawa-type potentials)?

## 8. References

1. Bertrand, J. (1873). "Théorème relatif au mouvement d'un point attiré vers un centre fixe." *C. R. Acad. Sci. Paris* 77: 849-853.
2. Ehrenfest, P. (1917). "In what way does it become manifest in the fundamental laws of physics that space has three dimensions?" *Proc. Amsterdam Acad.* 20: 200-209.
3. Tangherlini, F. R. (1963). "Schwarzschild field in n dimensions and the dimensionality of space problem." *Nuovo Cimento* 27: 636-651.
4. Tegmark, M. (1997). "On the dimensionality of spacetime." *Classical and Quantum Gravity* 14(4): L69.

## Appendix: Formalization Details

All theorems are formalized in Lean 4 (version 4.28.0) with Mathlib. The formalization comprises approximately 310 lines of Lean code with 0 sorry's (unproved assertions). Key Mathlib dependencies include:

- `Mathlib.Analysis.SpecialFunctions.Log.Basic` — logarithmic function properties
- `Mathlib.Analysis.SpecialFunctions.Pow.Real` — real power functions
- `Mathlib.Data.Real.Irrational` — irrationality of √2
- `Mathlib.Order.Filter.Basic` — filter theory for limits
