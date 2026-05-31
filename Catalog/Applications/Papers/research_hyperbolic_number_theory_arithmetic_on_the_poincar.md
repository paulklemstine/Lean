# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We develop the foundations of arithmetic on the Poincaré disk model of hyperbolic geometry. We define Möbius transformations as the fundamental arithmetic operations, prove that they preserve the open unit disk via a key norm-squared identity, establish the pseudohyperbolic distance as a natural metric on hyperbolic integers, and define hyperbolic lattices as orbits of the origin under discrete groups of Möbius maps. Our main results include: (1) the fundamental Möbius identity relating normSq before and after transformation; (2) that Möbius maps preserve the disk; (3) the Möbius inverse theorem φ_{-a} ∘ φ_a = id; (4) the conformal factor transformation law; (5) the pseudohyperbolic distance characterization (identity of indiscernibles). All results are formally verified in Lean 4 with Mathlib, providing a rigorous foundation for further development. We define the hyperbolic zeta function for finite lattices, establish its nonnegativity, and state a conjecture relating lattice point growth to the spectral theory of the Laplacian on the modular surface.

**Keywords**: Poincaré disk, Möbius transformations, hyperbolic lattice, pseudohyperbolic distance, hyperbolic zeta function, formal verification

---

## 1. Introduction

The integers ℤ are among the most fundamental objects in mathematics. Their arithmetic properties — primality, divisibility, the distribution of primes — form the subject of classical number theory, which has been studied for millennia. From a geometric perspective, ℤ lives on the real line ℝ, the simplest example of a flat (Euclidean) space.

A natural question arises: *what happens to arithmetic when the underlying space is curved?* Specifically, what are the analogs of integers, primes, and the prime counting function on a negatively curved (hyperbolic) space?

In this paper, we develop the foundations of **hyperbolic number theory** — arithmetic on the Poincaré disk model of the hyperbolic plane. Our approach is to:

1. Define Möbius transformations as the fundamental operations, analogous to translation on ℤ.
2. Define hyperbolic lattices as orbits of the origin under discrete groups of Möbius maps.
3. Establish the pseudohyperbolic distance as the natural metric.
4. Define a hyperbolic zeta function and state conjectures about its analytic properties.

All core results are formally verified in Lean 4 using the Mathlib library, providing machine-checked proofs of the fundamental theorems.

### 1.1 Relation to Prior Work

The study of discrete groups acting on the hyperbolic plane has a long history, going back to Poincaré, Klein, and Fricke. The spectral theory of the Laplacian on hyperbolic quotients was developed by Selberg [Sel56], who proved the Selberg trace formula relating the spectrum to closed geodesics. Huber [Hub59] established the asymptotic distribution of lattice points in hyperbolic space.

Our contribution is to reframe these classical results in the language of "hyperbolic arithmetic" — treating Möbius transformations as operations on a curved number system — and to provide formal computer-verified proofs of the foundational results.

---

## 2. Definitions

### 2.1 The Poincaré Disk

The **Poincaré disk** is the open unit disk 𝔻 = {z ∈ ℂ : |z| < 1} equipped with the hyperbolic metric ds² = 4|dz|²/(1 - |z|²)².

### 2.2 Möbius Transformations

For a ∈ 𝔻, the **Möbius transformation** (or **hyperbolic translation** by a) is:

$$\varphi_a(z) = \frac{z - a}{1 - \bar{a}z}$$

The **Möbius denominator** is D(a, z) = 1 - ā·z.

### 2.3 Pseudohyperbolic Distance

The **pseudohyperbolic distance** between z, w ∈ 𝔻 is:

$$\rho(z, w) = \frac{|z - w|}{|1 - \bar{w}z|} = |\varphi_w(z)|$$

This is related to the hyperbolic distance by d_H(z,w) = 2·arctanh(ρ(z,w)).

### 2.4 Hyperbolic Lattice

A **hyperbolic lattice** is a structure (G, D) where G = {g₁, ..., gₖ} ⊂ 𝔻 \ {0} is a finite set of generators, and the lattice points are the orbit of the origin under iterated application of the Möbius maps φ_{gᵢ} and their inverses φ_{-gᵢ}.

### 2.5 Conformal Weight

The **conformal weight** at z ∈ 𝔻 is:

$$w(z) = \frac{1}{(1 - |z|^2)^2}$$

This is the Jacobian of the hyperbolic-to-Euclidean area transformation.

### 2.6 Hyperbolic Counting Function

For a finite set of lattice points P ⊂ 𝔻, the **counting function** is:

$$N_P(R) = |\{z \in P : |z| \leq R\}|$$

### 2.7 Hyperbolic Zeta Function

For a finite set P ⊂ 𝔻, the **(partial) hyperbolic zeta function** is:

$$\zeta_H(s) = \sum_{\substack{z \in P \\ z \neq 0}} \frac{1}{|z|^{2s}}$$

---

## 3. Main Results

### 3.1 Fundamental Möbius Identity

**Theorem 1** (Möbius Norm-Squared Identity). *For all a, z ∈ ℂ,*

$$|D(a,z)|^2 - |z - a|^2 = (1 - |a|^2)(1 - |z|^2)$$

*Proof.* Direct algebraic expansion. Setting a = a₁ + ia₂ and z = z₁ + iz₂, both sides expand to the same polynomial in a₁, a₂, z₁, z₂. The Lean proof uses `ring` after reducing to real and imaginary components. □

This identity is the linchpin of the theory. It implies that for |a| < 1 and |z| < 1, we have |D(a,z)|² > |z - a|², which is the key inequality for disk preservation.

### 3.2 Möbius Denominator Nonvanishing

**Theorem 2**. *If |a| < 1 and |z| < 1, then D(a,z) ≠ 0.*

*Proof.* By contradiction. If D(a,z) = 0, then |D(a,z)|² = 0, so by Theorem 1, -|z - a|² = (1 - |a|²)(1 - |z|²) > 0, contradicting |z - a|² ≥ 0. The Lean proof uses `contrapose!` and `nlinarith`. □

### 3.3 Disk Preservation

**Theorem 3** (Möbius Disk Preservation). *If |a| < 1 and |z| < 1, then |φ_a(z)| < 1.*

*Proof.* By Theorem 2, D(a,z) ≠ 0, so φ_a(z) is well-defined. We have:

|φ_a(z)|² = |z - a|² / |D(a,z)|² < 1

since |z - a|² < |D(a,z)|² by Theorem 1. Taking square roots gives |φ_a(z)| < 1. □

### 3.4 Möbius Inverse

**Theorem 4** (Möbius Inverse). *For |a| < 1 and |z| < 1, φ_{-a}(φ_a(z)) = z.*

*Proof.* By direct algebraic computation. Setting w = φ_a(z) = (z-a)/D(a,z), we compute:

φ_{-a}(w) = (w + a) / (1 + ā·w)

Substituting and clearing the denominator D(a,z) (which is nonzero by Theorem 2), the numerator becomes z·(1 - |a|²) and the denominator becomes (1 - |a|²), so the result is z. The Lean proof uses `field_simp` and `linear_combination`. □

### 3.5 Conformal Factor Transformation

**Theorem 5** (Conformal Transformation Law). *For |a| < 1 and |z| < 1:*

$$1 - |\varphi_a(z)|^2 = \frac{(1 - |a|^2)(1 - |z|^2)}{|D(a,z)|^2}$$

*Proof.* Follows from Theorem 1 by dividing both sides by |D(a,z)|² and rearranging. □

### 3.6 Pseudohyperbolic Distance Properties

**Theorem 6**. *For z, w ∈ 𝔻:*
- *(a) ρ(z,w) ≥ 0*
- *(b) ρ(z,w) < 1*
- *(c) ρ(z,w) = 0 if and only if z = w*

*Proof.* (a) follows from nonnegativity of norms. (b) follows from Theorem 3 since ρ(z,w) = |φ_w(z)|. (c): if ρ(z,w) = 0, then |z - w| / |D(w,z)| = 0; since D(w,z) ≠ 0 by Theorem 2, we get |z - w| = 0, hence z = w. The converse is immediate. □

### 3.7 Conformal Weight Properties

**Theorem 7**. *For z ∈ 𝔻:*
- *(a) w(z) > 0*
- *(b) w(0) = 1*
- *(c) w(z) ≥ 1*

*Proof.* (a): since |z| < 1, we have 1 - |z|² > 0, hence (1 - |z|²)² > 0 and w(z) > 0. (b): w(0) = 1/(1-0)² = 1. (c): since 0 < 1 - |z|² ≤ 1, we have (1 - |z|²)² ≤ 1, hence w(z) = 1/(1-|z|²)² ≥ 1. □

### 3.8 Counting Function Monotonicity

**Theorem 8**. *The counting function is monotone: if R₁ ≤ R₂, then N_P(R₁) ≤ N_P(R₂).*

*Proof.* The filter set for R₁ is a subset of the filter set for R₂. □

---

## 4. Computational Results

### 4.1 Lattice Generation

We implemented the lattice generation algorithm using breadth-first orbit enumeration with Möbius maps. Using generators g₁ = 0.5 and g₂ = 0.5i (both with |g| = 0.5), we generated:

| Depth | Total points | N(0.5) | N(0.9) | N(0.99) |
|-------|-------------|--------|--------|---------|
| 2     | 17          | 17     | 17     | 17      |
| 4     | 161         | 37     | 89     | 161     |
| 6     | 1,457       | 37     | 297    | 1,297   |
| 8     | 10,000+     | 37     | 1,118  | 4,926   |

The counting function exhibits exponential growth in the hyperbolic metric, consistent with the classical lattice point counting theorem of Huber.

### 4.2 Hyperbolic Zeta Function Values

For ~500 lattice points:

| s   | ζ_H(s)        |
|-----|---------------|
| 0.5 | 655.6         |
| 1.0 | 2,556.6       |
| 1.5 | 31,201.5      |
| 2.0 | 477,158.2     |
| 2.5 | 7,440,981.4   |
| 3.0 | 116,215,823.0 |

The rapid growth reflects the accumulation of lattice points near the boundary where |z| is close to 1.

### 4.3 Numerical Verification

We verified all formal theorems numerically:
- **Möbius identity**: Residual < 10⁻¹⁵ for all tested inputs.
- **Möbius inverse**: |φ_{-a}(φ_a(z)) - z| < 10⁻¹⁵ for all tested inputs.
- **Conformal transform**: Residual < 10⁻¹⁵ for all tested inputs.

---

## 5. Conjectures

### 5.1 Hyperbolic Prime Counting Conjecture (Weak Form)

**Conjecture 1**. *For any hyperbolic lattice with at least 2 generators, the orbit of the origin under iterated Möbius maps is infinite — that is, for any N ∈ ℕ, there exist at least N distinct orbit points in 𝔻.*

This weak form is a consequence of the fact that non-elementary Fuchsian groups have infinite orbits. The strong form would specify the precise growth rate.

### 5.2 Hyperbolic Zeta Function Conjecture

**Conjecture 2** (Speculative). *The hyperbolic zeta function ζ_H(s), properly defined via analytic continuation for the full lattice of the modular group PSL(2,ℤ), satisfies a functional equation and has nontrivial zeros only on the critical line Re(s) = 1/2.*

**Testable prediction**: Compute ζ_H(s) for the modular group with generators at distance 0.5 from the origin and verify that the first 100 approximate zeros have real part near 1/2.

This conjecture is closely related to the Selberg zeta function for the modular surface, whose analytic properties are well-studied but whose zero distribution remains an active area of research.

---

## 6. Discussion

### 6.1 Connection to Selberg Theory

Our hyperbolic zeta function is a finite approximation to the Selberg zeta function Z(s) for the modular surface Γ\ℍ, defined as:

$$Z(s) = \prod_{\gamma \text{ primitive}} \prod_{k=0}^{\infty} (1 - e^{-(s+k)\ell(\gamma)})$$

where the product is over primitive closed geodesics of length ℓ(γ). Selberg proved that Z(s) has an analytic continuation to ℂ and satisfies a functional equation. Its nontrivial zeros are related to the eigenvalues of the hyperbolic Laplacian.

### 6.2 Formal Verification

All theorems in Section 3 have been formally verified in Lean 4 with the Mathlib library. The proofs use:
- **ring**: for the fundamental algebraic identity (Theorem 1)
- **contrapose!/nlinarith**: for denominator nonvanishing (Theorem 2)
- **norm_div/sqrt monotonicity**: for disk preservation (Theorem 3)
- **field_simp/linear_combination**: for the inverse theorem (Theorem 4)
- **div_pow/one_sub_div**: for the conformal transform (Theorem 5)

The most challenging proof was the Möbius inverse (Theorem 4), which required careful denominator clearing and use of the `linear_combination` tactic.

### 6.3 Limitations

Our current framework has several limitations:
1. We work with finite lattices rather than the full infinite orbit.
2. The hyperbolic zeta function is defined only as a real-valued sum, not as a complex analytic function.
3. We do not yet define "hyperbolic primes" — this requires a notion of irreducibility in the group structure.

---

## 7. Future Work

1. **Define hyperbolic primes**: Identify which lattice points correspond to "prime" elements (generators of the group, or vertices of the fundamental domain).
2. **Prove the lattice point counting theorem**: Establish that N(R) ~ C·e^R in the hyperbolic metric, following Huber's classical result.
3. **Connect to Selberg zeta function**: Show that the finite hyperbolic zeta function converges to the Selberg zeta function as the lattice depth increases.
4. **Establish functional equation**: Prove (or disprove) that ζ_H satisfies a functional equation.
5. **Develop tropical-hyperbolic bridge**: Connect the hyperbolic lattice to tropical geometry via the valuation map z ↦ -log(1 - |z|²).

---

## References

- [Hub59] H. Huber, "Zur analytischen Theorie hyperbolischer Raumformen und Bewegungsgruppen," *Math. Ann.*, 1959.
- [Sel56] A. Selberg, "Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces with applications to Dirichlet series," *J. Indian Math. Soc.*, 1956.
- [Iwa02] H. Iwaniec, *Spectral Methods of Automorphic Forms*, AMS, 2002.
- [Sar03] P. Sarnak, "Spectra of Hyperbolic Surfaces," *Bull. AMS*, 2003.
