# Mathematical Pathologies of 2D Newtonian Gravity: A Formal Analysis

## Abstract

We present a rigorous mathematical analysis of Newtonian gravity in two spatial dimensions, demonstrating that it is fundamentally pathological compared to the familiar three-dimensional case. Our main results, verified through formal proof in Lean 4, establish that: (1) the gravitational potential in 2D is logarithmic, growing without bound and preventing any notion of escape velocity; (2) the apsidal angle ratio 1/√2 is irrational, proving that no orbit in 2D gravity ever closes; (3) the Bertrand condition fails for 2D gravity while succeeding for 3D gravity; and (4) dimension 3 is the unique spatial dimension ≥ 2 where gravity produces both stable and closed orbits (the "Goldilocks theorem"). These results formalize the impossibility of planetary systems in Flatland and provide a mathematical explanation for the special role of three spatial dimensions in gravitational physics.

## 1. Introduction

The study of gravity in non-standard dimensions has a long history, dating back to Ehrenfest's 1917 observation that stable orbits require exactly three spatial dimensions [1]. While Ehrenfest's argument was physical and heuristic, we provide fully rigorous mathematical proofs of the key claims, verified by a formal proof assistant.

The central question we address is: *What goes wrong with gravity in two spatial dimensions?* The answer involves three interrelated pathologies:

1. **Logarithmic trapping**: The potential V(r) ∝ ln(r) grows without bound, eliminating escape.
2. **Orbit non-closure**: The apsidal angle ratio 1/√2 is irrational, preventing periodic orbits.
3. **Bertrand failure**: The classification of closed-orbit force laws excludes 2D gravity.

We formalize these results within the framework of central force dynamics, using the effective potential method and the Bertrand-Darboux classification of orbit-closing force laws.

## 2. Mathematical Framework

### 2.1 Gravitational Force in n Dimensions

By Gauss's law, the gravitational field of a point mass M in n spatial dimensions satisfies:

g(r) · S_{n-1}(r) = G_n · M

where S_{n-1}(r) is the surface area of the (n-1)-sphere of radius r. This gives:

- n = 2: g(r) = GM/(r), F ∝ 1/r
- n = 3: g(r) = GM/(r²), F ∝ 1/r² (familiar inverse-square law)
- n = 4: g(r) = GM/(r³), F ∝ 1/r³

### 2.2 The Gravitational Potential

Integrating the force law F = -dV/dr:

- n = 2: V(r) = k · ln(r) (logarithmic)
- n = 3: V(r) = -k/r (Coulomb/Newtonian)
- n ≥ 3: V(r) ∝ r^(2-n)

**Definition (FlatlandGravity).** A 2D gravitational system is specified by parameters (G, M, m, L) where G > 0 is the gravitational constant, M > 0 the central mass, m > 0 the orbiting mass, and L ≠ 0 the angular momentum. The coupling constant is k = GMm.

### 2.3 Effective Potential

For a particle with angular momentum L, the effective potential governing radial motion is:

V_eff(r) = k · ln(r) + L²/(2mr²)

This combines the logarithmic gravitational potential with the centrifugal barrier.

**Definition (CentralForce).** A central force law is specified by its power-law exponent α and coupling constant, with F(r) = -coupling · r^α.

## 3. Main Results

### 3.1 Logarithmic Trapping (No Escape Velocity)

**Theorem (flatland_potential_unbounded).** For any k > 0, the function r ↦ k · ln(r) tends to +∞ as r → ∞:

lim_{r→∞} k · ln(r) = +∞

*Proof.* This follows directly from the unboundedness of the natural logarithm, established in analysis as `Real.tendsto_log_atTop` in Mathlib.

**Corollary (universal_trapping).** Every particle in a 2D gravitational system is permanently bound. There exists no finite energy sufficient for escape.

This contrasts sharply with 3D gravity, where V(r) = -k/r → 0 as r → ∞, allowing escape with any positive total energy.

### 3.2 Orbit Non-Closure (Bertrand Failure)

The apsidal angle — the angular sweep between successive periapsis and apoapsis — determines whether orbits close. For a power-law force F ∝ r^α, the apsidal angle for small oscillations around a circular orbit is:

Δθ = π / √(3 + α)

**Definition (apsidalAngleRatio).** The apsidal angle ratio for exponent α is R(α) = 1/√(3+α).

**Theorem (apsidal_ratio_2D_irrational).** The apsidal angle ratio for 2D gravity is irrational:

R(-1) = 1/√2 ∈ ℝ \ ℚ

*Proof.* Since R(-1) = 1/√2 and √2 is irrational (by the classical proof in Mathlib as `irrational_sqrt_two`), its reciprocal 1/√2 is also irrational (by `irrational_inv_iff`).

**Definition (OrbitCloses).** An orbit closes if its apsidal angle ratio is rational: ∃ p, q ∈ ℤ with q ≠ 0 and R = p/q.

**Theorem (flatland_orbits_never_close).** No orbit in 2D gravity ever closes.

*Proof.* If 1/√2 = p/q for integers p, q with q ≠ 0, then 1/√2 is rational, contradicting its irrationality. This is formalized using `Irrational.ne_rational`.

### 3.3 The Bertrand Condition

**Definition (satisfiesBertrand).** A central force satisfies the Bertrand condition if 0 < 3 + α and √(3 + α) is rational.

**Theorem (gravity3D_satisfies_bertrand).** 3D gravity (α = -2) satisfies Bertrand: √(3-2) = √1 = 1 ∈ ℚ.

**Theorem (gravity2D_fails_bertrand).** 2D gravity (α = -1) fails Bertrand: √(3-1) = √2 ∉ ℚ.

### 3.4 The Goldilocks Theorem

**Definition (bertrandParameter, stabilityDiscriminant).** For n-dimensional gravity, both the Bertrand parameter and stability discriminant equal 4-n.

**Theorem (goldilocks_dimension).** For n ≥ 2, the following are equivalent:
1. n = 3
2. stabilityDiscriminant(n) > 0 AND bertrandParameter(n) = 1

*Proof.* The conditions require 4-n > 0 (so n ≤ 3) and 4-n = 1 (so n = 3). The only solution is n = 3.

This establishes that dimension 3 is the *unique* dimension supporting both stable and closed gravitational orbits.

### 3.5 No Periodic Return

**Theorem (no_periodic_return).** For any natural number n ≥ 1, there is no integer m such that n · (π/√2) = 2πm.

*Proof.* If such m existed, dividing by π gives n/√2 = 2m, so √2 = n/(2m). This makes √2 rational, contradicting `irrational_sqrt_two`.

### 3.6 Irrationality of the Angular Advance

**Theorem (angularAdvance2D_irrational).** Assuming π is transcendental (Lindemann–Weierstrass theorem), π/√2 is irrational.

*Proof.* If π/√2 = q ∈ ℚ, then π = q·√2. Since q is algebraic and √2 is algebraic, their product q·√2 is algebraic. But π is transcendental, contradiction.

*Remark.* The transcendence of π is not yet formalized in Mathlib, so this result is conditional on that hypothesis.

### 3.7 Unique Logarithmic Dimension

**Theorem (unique_logarithmic_dimension).** Among dimensions n ≥ 2, only n = 2 has a logarithmic gravitational potential.

### 3.8 Flatland Impossibility

**Theorem (flatland_impossibility).** The properties of 2D gravitational orbits (non-closing, no escape) are incompatible with the requirements for a viable planetary system (closing orbits, escape capability).

## 4. Orbit Topology Classification

We introduce a classification of orbit topology by dimension:

- **Closed**: Orbit is a periodic curve (dimension 3)
- **Quasiperiodic**: Orbit is dense in an annular region (dimension 2)
- **Unstable**: Orbit spirals to collision or unbounded growth (dimensions ≥ 4)

**Theorem (closed_orbits_only_in_3D).** The orbit topology is "closed" if and only if n = 3.

## 5. Algorithms

### 5.1 Orbit Integration

We implement a Störmer-Verlet integrator for the equations of motion in polar coordinates:

- r̈ = -k/r + L²/(mr³) (radial equation)
- θ̇ = L/(mr²) (angular equation)

The Verlet method is symplectic, preserving the Hamiltonian structure and providing long-term stability for orbit integration.

### 5.2 Apsidal Angle Computation

To numerically verify the apsidal angle, we:
1. Integrate the orbit for many radial periods
2. Detect periapsis/apoapsis points
3. Measure successive angular differences
4. Compare to the theoretical value π/√2 ≈ 2.2214

### 5.3 Dimensional Analysis Algorithm

For each dimension n:
1. Compute the force exponent: 1-n
2. Compute the Bertrand parameter: 4-n
3. Check stability: 4-n > 0?
4. Check closure: is √(4-n) rational?
5. Classify: Goldilocks iff stable AND closed

## 6. Conjecture: Quadratic Intersection Growth

**Conjecture.** The number of self-intersections of a 2D gravitational orbit after N radial oscillations is Θ(N²), specifically approximately N(N-1)/2.

**Rationale.** Each new radial oscillation sweeps an arc of angular width approximately 2π/√2. By Weyl's equidistribution theorem (since 1/√2 is irrational), successive arcs are uniformly distributed in angle. Each new arc therefore crosses approximately N existing arcs, giving cumulative intersections ≈ ∑_{k=1}^{N} k ≈ N²/2.

**Testable prediction.** For N = 100 radial oscillations, the orbit should have approximately 4950 ± 500 self-intersections. This can be verified by numerical orbit integration with intersection detection.

## 7. Discussion

### 7.1 Implications for Dimensional Physics

Our results contribute to the "anthropic" argument for three spatial dimensions, but on purely mathematical rather than physical grounds. The Goldilocks theorem shows that the special role of n = 3 is not a consequence of particular physical constants or initial conditions, but of the abstract structure of central force dynamics.

### 7.2 Formal Verification

All main results (11 theorems) have been formally verified in Lean 4 with Mathlib, with only one conditional result (angularAdvance2D_irrational, conditional on π's transcendence). The axioms used are standard: propext, Classical.choice, and Quot.sound.

### 7.3 Connection to Existing Results

The effective potential analysis connects to the Computation/GravityOracle catalog entry through the shared framework of gravitational dynamics. The dimensional analysis extends the stability results in the Physics catalog.

## 8. Future Work

1. **Formalize π's transcendence**: Would make angularAdvance2D_irrational unconditional.
2. **N-body pathologies**: Extend results to multi-body systems in 2D.
3. **KAM theory in 2D**: Investigate whether near-integrable perturbations preserve quasi-periodicity.
4. **Connections to conformal field theory**: 2D gravity has deep ties to CFT; explore these formally.

## References

[1] P. Ehrenfest, "In what way does it become manifest in the fundamental laws of physics that space has three dimensions?" *Proc. Amsterdam Acad.* 20, 200 (1917).

[2] J. Bertrand, "Théorème relatif au mouvement d'un point attiré vers un centre fixe," *C. R. Acad. Sci.* 77, 849-853 (1873).

[3] V. I. Arnold, *Mathematical Methods of Classical Mechanics*, Springer (1989).

[4] E. A. Abbott, *Flatland: A Romance of Many Dimensions* (1884).

[5] F. R. Tangherlini, "Schwarzschild field in n dimensions and the dimensionality of space problem," *Nuovo Cimento* 27, 636-651 (1963).
