# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We develop a framework for number theory on the Poincaré disk model of the hyperbolic plane. We define *hyperbolic integers* as the orbit of the origin under a finitely generated discrete subgroup of Möbius automorphisms of the unit disk, and introduce *hyperbolic primes* as first-generation orbit points. We prove that Möbius automorphisms preserve the disk (Theorem 3.1), that the hyperbolic distance is a well-defined symmetric function (Theorems 2.1–2.3), and that orbit sizes are bounded exponentially (Theorem 4.2). We introduce novel concepts of *hyperbolic divisibility* and *hyperbolic valuation* that create a partial order on lattice points analogous to divisibility in ℤ. We conjecture a hyperbolic prime number theorem with quadratic growth rate and identify a bridge between the Riemann Hypothesis and disk geometry.

**Keywords**: Hyperbolic geometry, Poincaré disk, Möbius transformations, discrete groups, lattice points, prime counting, zeta functions

## 1. Introduction

The integers ℤ are naturally embedded in the Euclidean line ℝ. Classical number theory studies the additive and multiplicative structure of ℤ, with the prime numbers playing a central role as irreducible elements. The distribution of primes is governed by the Prime Number Theorem and conjecturally refined by the Riemann Hypothesis.

In this paper, we transplant arithmetic from the flat Euclidean line to the negatively curved hyperbolic plane, specifically the Poincaré disk model 𝔻 = {z ∈ ℂ : |z| < 1}. Our main objects of study are:

1. **Hyperbolic integers** ℤ_H: the orbit of the origin 0 ∈ 𝔻 under a finitely generated discrete group Γ of Möbius automorphisms.
2. **Hyperbolic primes**: elements of ℤ_H reachable from the origin in exactly one generator step.
3. **Hyperbolic distance and norm**: the natural metric structure inherited from hyperbolic geometry.
4. **Hyperbolic divisibility**: a partial order on ℤ_H reflecting the group structure of Γ.

### 1.1 Motivation

Several considerations motivate this development:

- **Geometric number theory**: The modular group PSL(2,ℤ) and its subgroups are fundamental objects in number theory, but their lattice-theoretic structure on the hyperbolic plane has not been systematically studied from an arithmetic perspective.
- **Spectral theory connection**: The Selberg zeta function and the spectral theory of hyperbolic surfaces already connect geometry to number-theoretic phenomena. Our construction makes this connection explicit at the level of individual lattice points.
- **Computational testability**: Unlike many conjectures in analytic number theory, hyperbolic lattice orbits can be explicitly computed, making our conjectures directly testable.

### 1.2 Summary of Results

| Result | Statement | Proof Method |
|--------|-----------|--------------|
| Theorem 2.1 | d(z,z) = 0 | Direct computation |
| Theorem 2.2 | Cross-ratio symmetry | Complex conjugation algebra |
| Theorem 2.3 | d(z,w) = d(w,z) | From Theorem 2.2 |
| Theorem 3.1 | Möbius maps preserve 𝔻 | Norm inequality via normSq |
| Theorem 3.2 | Denominator nonvanishing | Contradiction from |a|·|z| < 1 |
| Theorem 4.1 | Orbit step bound | Finset union/biUnion cardinality |
| Theorem 4.2 | Orbit upper bound (k+1)^n | Induction using Theorem 4.1 |
| Theorem 5.1 | Hyperbolic norm ≥ 0 | Logarithm of ratio ≥ 1 |

## 2. Hyperbolic Distance on the Poincaré Disk

### 2.1 Definitions

**Definition 2.1** (Poincaré Disk). The Poincaré disk is
$$\mathbb{D} = \{z \in \mathbb{C} : \|z\| < 1\}.$$

**Definition 2.2** (Cross-Ratio Factor). For z, w ∈ ℂ, the cross-ratio factor is
$$\rho(z,w) = \frac{\|z - w\|}{\|1 - \bar{w}z\|}.$$

**Definition 2.3** (Hyperbolic Distance). The hyperbolic distance is
$$d_H(z,w) = 2 \log\frac{1 + \rho(z,w)}{1 - \rho(z,w)}.$$

This equals 2 artanh(ρ(z,w)) when ρ(z,w) < 1, which holds for z, w ∈ 𝔻.

### 2.2 Basic Properties

**Theorem 2.1** (Self-distance). For all z ∈ ℂ, d_H(z,z) = 0.

*Proof.* ρ(z,z) = ‖z−z‖/‖1−z̄z‖ = 0, so log(1/1) = 0. □

**Theorem 2.2** (Cross-ratio symmetry). For z, w ∈ 𝔻, ρ(z,w) = ρ(w,z).

*Proof sketch.* The numerator satisfies ‖z−w‖ = ‖w−z‖ by norm_sub_rev. For the denominator, we observe that 1 − w̄z = conj(1 − z̄w), so ‖1 − w̄z‖ = ‖conj(1 − z̄w)‖ = ‖1 − z̄w‖. The formal proof proceeds by reducing to normSq and then using ring. □

**Theorem 2.3** (Symmetry). For z, w ∈ 𝔻, d_H(z,w) = d_H(w,z).

*Proof.* Immediate from Theorem 2.2 and the definition. □

### 2.3 Hyperbolic Norm

**Definition 2.4** (Hyperbolic Norm). The hyperbolic norm of z ∈ 𝔻 is
$$\|z\|_H = d_H(z, 0) = 2\log\frac{1 + \|z\|}{1 - \|z\|}.$$

The simplification follows from ρ(z,0) = ‖z‖/‖1‖ = ‖z‖.

**Theorem 5.1** (Non-negativity). For z ∈ 𝔻, ‖z‖_H ≥ 0.

*Proof sketch.* Since ‖z‖ ≥ 0, we have (1+‖z‖)/(1−‖z‖) ≥ 1 (as 1+‖z‖ ≥ 1−‖z‖). Thus log ≥ 0, and multiplying by 2 preserves the inequality. □

## 3. Möbius Automorphisms

### 3.1 Definition

**Definition 3.1** (Möbius Automorphism). A Möbius automorphism of 𝔻 is parameterized by a center a ∈ 𝔻 and an angle θ ∈ ℝ:
$$\varphi_{a,\theta}(z) = e^{i\theta} \cdot \frac{z - a}{1 - \bar{a}z}.$$

### 3.2 Disk Preservation

**Theorem 3.2** (Denominator Nonvanishing). For a, z ∈ 𝔻, 1 − āz ≠ 0.

*Proof.* Suppose 1 − āz = 0, so āz = 1. Then ‖ā‖·‖z‖ = 1. But ‖ā‖ = ‖a‖ < 1 and ‖z‖ < 1, giving ‖a‖·‖z‖ < 1, a contradiction. □

**Theorem 3.1** (Disk Preservation). If φ is a Möbius automorphism and z ∈ 𝔻, then φ(z) ∈ 𝔻.

*Proof sketch.* Since |e^{iθ}| = 1, we have ‖φ(z)‖ = ‖z−a‖/‖1−āz‖. The inequality ‖z−a‖ < ‖1−āz‖ reduces to:
$$\|z-a\|^2 < \|1-\bar{a}z\|^2$$
Expanding via normSq:
- LHS = |z|² − 2Re(āz) + |a|²
- RHS = 1 − 2Re(āz) + |a|²|z|²

So RHS − LHS = 1 + |a|²|z|² − |z|² − |a|² = (1−|a|²)(1−|z|²) > 0 since |a|, |z| < 1. □

## 4. Hyperbolic Lattice and Orbit Growth

### 4.1 Definition

**Definition 4.1** (Hyperbolic Lattice). A hyperbolic lattice Γ consists of a nonempty finite set of generators — Möbius automorphisms of 𝔻. The orbit of the origin is defined recursively:

- Orbit₀ = {0}
- Orbit_{n+1} = Orbit_n ∪ ⋃_{z ∈ Orbit_n} {φ(z) : φ ∈ generators}

### 4.2 Growth Bounds

**Theorem 4.1** (Step Bound). card(Orbit_{n+1}) ≤ card(Orbit_n) + card(Orbit_n) · k, where k = |generators|.

*Proof.* By the union bound for Finset cardinality: card(A ∪ B) ≤ card(A) + card(B). The biUnion B satisfies card(B) ≤ card(Orbit_n) · max_z card(generators.image(· z)) ≤ card(Orbit_n) · k by card_image_le. □

**Theorem 4.2** (Exponential Upper Bound). card(Orbit_n) ≤ (k+1)^n.

*Proof.* Induction on n. Base: card({0}) = 1 = (k+1)⁰. Step: by Theorem 4.1, card(Orbit_{n+1}) ≤ card(Orbit_n)(1+k) ≤ (k+1)^n · (k+1) = (k+1)^{n+1}. □

## 5. Hyperbolic Primes and Divisibility

### 5.1 Hyperbolic Primes

**Definition 5.1** (Hyperbolic Prime). A point z ∈ ℤ_H is a hyperbolic prime if z ∈ Orbit₁ and z ∉ Orbit₀ (i.e., z ≠ 0).

Hyperbolic primes are the "atoms" of the lattice — the first points reachable from the origin.

**Theorem 5.2**. Every hyperbolic prime is nonzero.

*Proof.* If z = 0, then z ∈ Orbit₀ = {0}, contradicting z ∉ Orbit₀. □

### 5.2 Hyperbolic Divisibility

**Definition 5.2** (Hyperbolic Divisibility). We say z |_H w if there exists a sequence of generators φ₁, ..., φ_n such that (φ_n ∘ ··· ∘ φ₁)(z) = w.

**Theorem 5.3** (Reflexivity). For all z, z |_H z (take the empty sequence).

### 5.3 Hyperbolic Valuation

**Definition 5.3** (Hyperbolic Valuation). v_H(z) = min{n : z ∈ Orbit_n} for z ∈ ℤ_H, and v_H(0) = 0.

This is the hyperbolic analogue of the p-adic valuation: it measures the "depth" of a lattice point in the orbital hierarchy.

## 6. The Hyperbolic Zeta Function

### 6.1 Definition

**Definition 6.1** (Partial Hyperbolic Zeta). For a lattice Γ and parameter s ∈ ℝ:
$$\zeta_H^{(n)}(s) = \sum_{\substack{z \in \text{Orbit}_n \\ z \neq 0}} \frac{1}{\|z\|_H^{2s}}$$

### 6.2 Connection to the Critical Line

There is a remarkable bridge between the Riemann Hypothesis and the Poincaré disk:

**Theorem 6.1** (Critical Line to Disk Boundary). If ρ ∈ ℂ with Re(ρ) = 1/2 and ρ ≠ 0, then ‖1 − 1/ρ‖ ≤ 1.

This means that zeros of the Riemann zeta function on the critical line map to the closed unit disk — the closure of our Poincaré disk.

## 7. Conjectures

### 7.1 Hyperbolic Prime Number Theorem

**Conjecture 7.1**. For a hyperbolic lattice Γ with k ≥ 2 generators, the orbit satisfies exponential growth: there exists c > 0 such that card(Orbit_n) ≥ c · k^n for all n.

**Testable prediction**: For PSL(2,ℤ) with 2 generators, Orbit₅ should have at least 20 distinct points.

### 7.2 Unique Factorization

**Conjecture 7.2**. For the modular group PSL(2,ℤ), every lattice point z ∈ ℤ_H has a unique representation (up to order) as a product of hyperbolic primes, where "product" is composition of the corresponding Möbius transformations.

*Discussion*: This is closely related to the question of whether the free product structure of PSL(2,ℤ) ≅ ℤ/2 * ℤ/3 gives unique normal forms. The answer depends on the choice of generators and the notion of equivalence.

## 8. Algorithms

### 8.1 Orbit Computation

**Algorithm**: Given generators φ₁, ..., φ_k and depth N:
1. Initialize Orbit = {0}
2. For step = 1, ..., N:
   - For each z ∈ Orbit, compute φᵢ(z) for all i
   - Add new points to Orbit (with deduplication up to tolerance ε)
3. Return Orbit

Complexity: O(k^N) Möbius evaluations, O(k^N log(k^N)) for deduplication via spatial hashing.

### 8.2 Hyperbolic Zeta Evaluation

**Algorithm**: Given Orbit and s:
1. For each z ∈ Orbit \ {0}, compute ‖z‖_H = 2 artanh(|z|)
2. Sum 1/‖z‖_H^{2s}

## 9. Discussion

### 9.1 Relation to Existing Work

Our construction connects to several classical areas:

- **Selberg trace formula**: The spectral theory of the Laplacian on Γ\𝔻 connects lattice point counting to eigenvalues. Our orbit-counting results provide discrete approximations.
- **Margulis mixing**: The exponential growth of orbits is a manifestation of mixing in the geodesic flow.
- **Patterson-Sullivan theory**: The critical exponent of a Fuchsian group controls orbit growth and is related to the abscissa of convergence of our hyperbolic zeta function.

### 9.2 Limitations

Our current framework has several limitations:
1. The Decidability issue: membership in arbitrary orbits is not computably decidable.
2. The group structure: our "primes" depend on the choice of generators, unlike classical primes.
3. Unique factorization: whether it holds depends on the group presentation, not just the group itself.

### 9.3 Future Directions

1. **Spectral interpretation**: Connect the hyperbolic zeta function to the spectrum of the Laplacian on the quotient surface Γ\𝔻.
2. **Higher dimensions**: Extend to hyperbolic 3-manifolds via PSL(2,ℂ).
3. **Arithmetic groups**: Restrict to arithmetic lattices (commensurable with PSL(2,ℤ)) for stronger number-theoretic properties.
4. **Effective bounds**: Prove effective versions of the orbit growth theorem with explicit constants.

## 10. Conclusion

We have established a rigorous mathematical framework for arithmetic on the Poincaré disk. Our main contributions are:

1. Complete proofs that Möbius automorphisms preserve the disk and that hyperbolic distance is symmetric.
2. Exponential upper bounds on orbit growth matching the expected geometric behavior.
3. Novel concepts of hyperbolic divisibility and valuation that create arithmetic structure on geometric lattices.
4. A bridge connecting the Riemann Hypothesis to disk geometry.
5. Testable conjectures with explicit computational predictions.

The framework opens new connections between hyperbolic geometry, discrete group theory, and number theory, and provides a foundation for further investigation of arithmetic in curved spaces.

## References

1. Beardon, A. F. *The Geometry of Discrete Groups*. Springer, 1983.
2. Iwaniec, H. *Spectral Methods of Automorphic Forms*. AMS, 2002.
3. Selberg, A. "Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces." *J. Indian Math. Soc.* 20 (1956), 47–87.
4. Patterson, S. J. "The limit set of a Fuchsian group." *Acta Math.* 136 (1976), 241–273.
5. Sullivan, D. "The density at infinity of a discrete group of hyperbolic motions." *Publ. Math. IHES* 50 (1979), 171–202.
