# The Goldilocks Theorem: Uniqueness of Three Spatial Dimensions for Viable Gravitational Systems

## Abstract

We establish a rigorous mathematical framework for analyzing the viability of gravitational orbits across spatial dimensions. Our central result, the **Goldilocks Theorem**, proves that dimension 3 is the unique spatial dimension satisfying three necessary conditions for a viable planetary system: (1) stability of circular orbits, (2) closure of nearly-circular orbits, and (3) finite escape velocity. The proof connects classical results in number theory — specifically, the irrationality of √2 and √3 — to dimensional physics through the apsidal angle analysis of Bertrand's theorem. We also prove a discrete version of Bertrand's theorem classifying integer force-law exponents admitting closed orbits, and establish a "number theory governs orbits" bridge theorem making precise the reduction from physics to arithmetic.

**Keywords**: Bertrand's theorem, dimensional analysis, gravitational orbits, apsidal angle, irrationality, Goldilocks theorem

---

## 1. Introduction

The observation that we inhabit a universe with exactly three spatial dimensions has long provoked mathematical curiosity. Ehrenfest (1917) noted that the stability of planetary orbits constrains the number of spatial dimensions, and subsequent work by Tangherlini (1963) and others has extended this analysis to general relativity.

In this paper we formalize and prove a comprehensive characterization: three is the *unique* spatial dimension supporting all three desirable properties of a gravitational system:

1. **Stability**: circular orbits are stable under perturbation.
2. **Closure**: nearly-circular orbits are periodic (closed).
3. **Escape**: finite escape velocity exists.

Our framework introduces the `GravitationalDimension` structure, which packages a dimension together with verified proofs of stability and closure. The Goldilocks Theorem then shows this structure is uniquely inhabited at dimension 3.

The mathematical novelty lies in the precise connection between number theory and dimensional physics: the closure condition for dimension *n* reduces to the rationality of √(4−n), creating a bridge between the arithmetic of quadratic surds and the topology of orbital trajectories.

## 2. Mathematical Framework

### 2.1 Gravitational Force in n Dimensions

In *n* spatial dimensions, Gauss's law for the gravitational field gives a force that falls off with distance as:

$$F(r) = -\frac{k}{r^{n-1}}$$

for a point mass source, where *k* > 0 is a coupling constant.

### 2.2 Effective Potential

For a particle of unit mass with angular momentum *L* in *n* dimensions, the effective potential for radial motion is:

$$V_{\text{eff}}(r) = \frac{L^2}{2r^2} - \frac{k}{(n-2)r^{n-2}}$$

for *n* ≥ 3, with logarithmic and linear forms for *n* = 2 and *n* = 1 respectively.

### 2.3 The Apsidal Angle Ratio

**Definition** (Apsidal Angle Ratio). For spatial dimension *n* with *n* < 4, the *apsidal angle ratio* is:

$$\rho(n) = \sqrt{4 - n}$$

This quantity determines the apsidal angle Ψ = π/ρ(n) for nearly-circular orbits. The orbit closes if and only if Ψ is a rational multiple of π, equivalently, if and only if ρ(n) ∈ ℚ.

**Convention**: We use √x = 0 for x ≤ 0, so ρ(n) = 0 for n ≥ 4.

### 2.4 The GravitationalDimension Structure

**Definition**. A *gravitational dimension* is a natural number *n* ≥ 1 satisfying:
- (Stability) *n* < 4
- (Closure) There exist integers *p*, *q* with *q* ≠ 0 such that √(4−n) = p/q

This bundles the necessary conditions for viable nearly-circular orbits.

## 3. Main Results

### 3.1 Stability Analysis

**Theorem** (Stability Bound). *For n ≥ 4, the apsidal angle ratio vanishes: ρ(n) = 0.*

*Proof.* When *n* ≥ 4, we have 4 − n ≤ 0, so √(4−n) = 0 by the convention that the square root of a non-positive number is zero. ∎

This reflects the physical fact that in four or more dimensions, the centrifugal barrier is insufficient to prevent gravitational collapse.

### 3.2 Irrationality Results

The closure condition requires √(4−n) to be rational. For *n* = 1 and *n* = 2, this fails:

**Theorem** (Dimension 1 Exclusion). *√3 is irrational, so dimension 1 admits no closed nearly-circular orbits.*

*Proof.* Since 3 is prime, √3 is irrational by the classical theorem on square roots of primes. ∎

**Theorem** (Dimension 2 Exclusion). *√2 is irrational, so dimension 2 admits no closed nearly-circular orbits.*

*Proof.* This is the classical result, known since antiquity. ∎

### 3.3 Dimension 3 Viability

**Theorem** (Dimension 3 Admission). *√(4−3) = √1 = 1, which is rational. Dimension 3 admits closed nearly-circular orbits.*

*Proof.* We have √1 = 1 = 1/1, exhibiting the required rational representation. ∎

### 3.4 The Goldilocks Theorem

**Theorem** (Goldilocks). *If G is a gravitational dimension (n ≥ 1, n < 4, and √(4−n) ∈ ℚ), then n = 3.*

*Proof.* The constraints n ≥ 1 and n < 4 restrict n to {1, 2, 3}. For n = 1: √3 is irrational (Theorem 3.2), contradicting the closure condition. For n = 2: √2 is irrational (Theorem 3.2), contradicting the closure condition. Therefore n = 3. ∎

**Corollary** (Uniqueness). *Any two gravitational dimensions have the same underlying natural number.*

### 3.5 The Full Characterization

**Theorem** (Goldilocks, Full Version). *For any natural number n, the following are equivalent:*
1. *n < 4, √(4−n) ∈ ℚ, and n ≥ 3 (finite escape velocity)*
2. *n = 3*

This adds the escape velocity condition: in dimensions 1 and 2, the gravitational potential grows without bound (logarithmically or linearly), making escape velocity infinite. Dimension 3 is the unique dimension satisfying all three constraints simultaneously.

### 3.6 Bertrand's Theorem for Integer Exponents

**Definition** (Bertrand Apsidal Ratio). For a central force F(r) = −k·r^α, the Bertrand apsidal ratio is β(α) = √(3+α).

**Theorem** (Bertrand Integer Classification). *For integer force-law exponents α with −2 ≤ α ≤ 2:*

$$(\exists p, q \in \mathbb{Z},\; q \neq 0,\; \beta(\alpha) = p/q) \iff (\alpha = -2 \text{ or } \alpha = 1)$$

*Proof.* Case analysis on α ∈ {−2, −1, 0, 1, 2}:*
- *α = −2: β = √1 = 1 ∈ ℚ.* ✓
- *α = −1: β = √2 ∉ ℚ.* ✗
- *α = 0: β = √3 ∉ ℚ (3 prime).* ✗
- *α = 1: β = √4 = 2 ∈ ℚ.* ✓
- *α = 2: β = √5 ∉ ℚ (5 prime).* ✗ ∎

This recovers Bertrand's classical result (for nearly-circular orbits): only the inverse-square law (α = −2, corresponding to 3-dimensional gravity) and the linear restoring force (α = 1, the harmonic oscillator) support closed orbits.

### 3.7 The Number Theory Bridge

**Theorem** (Number Theory Governs Orbits). *For 1 ≤ n ≤ 3:*

$$(\exists p, q \in \mathbb{Z},\; q \neq 0,\; \sqrt{4-n} = p/q) \iff n = 3$$

This theorem makes precise the slogan that "number theory governs the structure of space": the viability of a planetary system in dimension *n* reduces to a question in elementary number theory about the rationality of √(4−n).

## 4. The Apsidal Angle Derivation

The key physical input is the formula for the apsidal angle. For a circular orbit of radius *r₀* under a central force F(r) = −k/r^{n-1}, small radial perturbations satisfy:

$$\ddot{u} + \left(4 - n\right) u = 0$$

where *u* = r − r₀ (in appropriate units). This is a simple harmonic oscillator with frequency √(4−n), giving the apsidal angle:

$$\Psi = \frac{\pi}{\sqrt{4-n}}$$

The orbit closes iff Ψ/π is rational, i.e., iff √(4−n) is rational. The derivation requires *n* < 4 for the frequency to be real (stability), and the irrationality results for √2 and √3 then eliminate all dimensions except 3.

## 5. Connections and Applications

### 5.1 Cross-Domain Bridge: Number Theory ↔ Physics

The most striking aspect of the Goldilocks Theorem is the role of classical number theory. The impossibility results for dimensions 1 and 2 rely on:
- The irrationality of √2 (known since ~500 BCE)
- The irrationality of √3 (a corollary of the general theorem on square roots of primes)

These ancient results, proved without any physical motivation, turn out to control the viable dimensionality of the universe.

### 5.2 Bertrand's Theorem and Dimensional Analysis

The Bertrand integer classification provides a complementary perspective: instead of fixing the force law and varying the dimension, we fix the dimension (n = 3) and vary the force law exponent. The two theorems share the same mathematical core — rationality of a square root — but address different physical questions.

### 5.3 Relationship to Existing Work

Our framework extends Ehrenfest's 1917 observation by providing a complete, rigorous proof covering all three viability conditions simultaneously. The formalization in the GravitationalDimension structure makes the logical dependencies explicit and verifiable.

## 6. Discussion

### 6.1 Limitations

Our analysis addresses *nearly-circular* orbits. The full Bertrand theorem (1873) is stronger: it asserts that for the inverse-square and linear forces, *all* bounded orbits are closed, not just nearly-circular ones. The full theorem requires a more delicate global analysis that goes beyond the apsidal angle computation.

### 6.2 Beyond Power-Law Forces

The natural extension is to forces that are not pure power laws — Yukawa potentials, screened gravity, quantum-corrected potentials. For such forces, the apsidal angle generally depends on the energy and angular momentum of the orbit, not just on the force law parameters. This suggests a richer classification problem.

### 6.3 Higher-Dimensional Generalizations

In dimensions n ≥ 4, while stable circular orbits do not exist for inverse-power-law gravity, they may exist for other force laws. The analysis of which force laws support stable orbits in each dimension leads to a two-parameter classification problem in (n, α) space.

## 7. Conclusion

The Goldilocks Theorem provides a clean, rigorous answer to the question "in how many dimensions can gravity support a working solar system?" The answer — uniquely three — connects number theory (irrationality of √2 and √3) to physics (orbital stability and closure) through the apsidal angle analysis. The formalization reveals the precise logical structure of the argument and makes the cross-domain connections explicit.

## References

1. Bertrand, J. (1873). "Théorème relatif au mouvement d'un point attiré vers un centre fixe." *C. R. Acad. Sci. Paris* 77, 849–853.

2. Ehrenfest, P. (1917). "In what way does it become manifest in the fundamental laws of physics that space has three dimensions?" *Proc. Amsterdam Acad.* 20, 200–209.

3. Tangherlini, F.R. (1963). "Schwarzschild field in n dimensions and the dimensionality of space problem." *Nuovo Cimento* 27, 636–651.

4. Barrow, J.D. (1983). "Dimensionality." *Phil. Trans. R. Soc. Lond. A* 310, 337–346.

5. Tegmark, M. (1997). "On the dimensionality of spacetime." *Class. Quantum Grav.* 14, L69–L75.
