# Future Directions: Machine-Verified Finite Hilbert–Pólya Architecture

## Overview

This document identifies five falsifiable scientific hypotheses arising from the formally verified theorems in this project. Each hypothesis is precise enough to be proved, disproved, or computationally tested, and each connects to specific formal infrastructure that would certify or refute it.

---

## Hypothesis 1: Nondegenerate Arithmetic Kernel Existence

**Conjecture.** There exists an explicit prime-indexed Hermitian kernel K_N : π(N) × π(N) → ℂ, constructed from multiplicative characters or Hecke-type operators, such that:
1. rank(K_N) ≥ c · π(N) for some absolute constant c > 0,
2. K_N is Hermitian,
3. the Cayley-transformed eigenvalues of K_N approximate the Möbius-transported zeros of the symmetrized truncation Z_N on the unit circle, in the sense that the Hausdorff distance between the two point sets is o(1) as N → ∞.

**Finite computational test.** For N = 50, 100, 200:
- Construct K_N using the kernel K(p,q) = χ(p)χ̄(q)/√(pq) for a primitive Dirichlet character χ mod q.
- Compute rank(K_N) and compare to π(N).
- Compute eigenvalues, apply Cayley transform, and measure Hausdorff distance to Z_N zeros.

**Expected obstruction/failure mode.** The kernel may have full rank but spectral distribution may not match zeta zeros — the eigenvalue density may follow a Marchenko–Pastur law (random matrix) rather than the GUE distribution predicted by Montgomery's pair correlation conjecture.

**Certifying theorem.** A formal proof that rank(K_N) ≥ c·π(N) for the chosen kernel family, extending the rank analysis framework of Theorem 7.1. This would require formalizing the linear independence of character-weighted vectors over primes.

---

## Hypothesis 2: Transport Exactness for Symmetrized Truncations

**Conjecture.** For each N, there exists an explicit normalization factor γ_N(s) such that the Möbius-transported symmetrized truncation
$$Q_N(z) = \gamma_N(\varphi^{-1}(z)) \cdot Z_N(\varphi^{-1}(z))$$
is exactly a self-inversive rational function of z: that is, Q_N(z) = ω_N · z^{d_N} · \overline{Q_N(1/\bar{z})} for some |ω_N| = 1 and d_N ∈ ℤ.

**Finite computational test.** For N = 3, 5, 10:
- Compute Z_N(φ⁻¹(z)) at 1000 points on the unit circle.
- Numerically solve for γ_N minimizing the self-inversive residual ‖Q_N(z) − ω·z^d·conj(Q_N(1/z̄))‖.
- If the residual is < 10⁻¹⁰, the conjecture is confirmed for that N.

**Expected obstruction/failure mode.** The transported object Z_N(φ⁻¹(z)) is a sum of terms n^{−φ⁻¹(z)}, which are not polynomials in z. Exact self-inversiveness may require restricting to a polynomial approximation, introducing controllable error terms. The conjecture may need to be weakened to "approximately self-inversive" with quantified error bounds.

**Certifying theorem.** A formal proof that Q_N satisfies the self-inversive identity pointwise, or a formal bound on the self-inversive defect ‖Q_N(z) − ω·z^d·conj(Q_N(1/z̄))‖ ≤ ε(N) with ε(N) → 0.

---

## Hypothesis 3: Failure of All Symmetric Outer-Product Kernels

**Conjecture.** For any choice of vectors u, v : Primes(N) → ℝ, the symmetric kernel K(p,q) = u(p)v(q) + v(p)u(q) has rank ≤ 2. Therefore, no single-layer symmetric outer-product kernel can match more than O(1) independent spectral parameters of a zeta truncation model.

More precisely: if the symmetrized truncation Z_N has M(N) zeros in the critical strip (with M(N) → ∞), then the characteristic polynomial of any rank-2 Hermitian matrix can match at most 2 of these zeros after Cayley transport.

**Finite computational test.** For N = 10, 20, 50:
- Count zeros M(N) of Z_N in the critical strip 0 < Re(s) < 1, 0 < Im(s) < T for T = 100.
- Verify that no rank-2 matrix can simultaneously place eigenvalues at the Cayley pre-images of all M(N) zeros.

**Expected obstruction/failure mode.** None — this hypothesis should be provably true. The failure mode is mathematical: one cannot match ≥ 3 independent zero locations with a rank-2 matrix.

**Certifying theorem.** A formal proof that rank-k Hermitian matrices have at most k nonzero eigenvalues, combined with the existing rank ≤ 2 theorem (Theorem 7.1). This is straightforward using the spectral theorem for finite-dimensional Hermitian matrices.

---

## Hypothesis 4: Critical-Line Certification via Hermitian Witnesses

**Conjecture.** For every self-inversive polynomial P ∈ ℂ[z] of degree d ≤ 20 with all roots on the unit circle, there exists a Hermitian matrix H ∈ M_d(ℂ) such that the Cayley-transformed characteristic polynomial of H equals P (up to normalization).

Conversely, if P is self-inversive of degree d ≤ 20 and has a root strictly inside the unit disk, then no such Hermitian witness H exists.

**Finite computational test.** For each degree d = 2, 4, 6, ..., 20:
- Generate 1000 random self-inversive polynomials.
- For those with all unit-circle roots, attempt to construct H by solving the inverse eigenvalue problem (compute the d roots, apply inverse Cayley to get real eigenvalues, construct any Hermitian matrix with that spectrum).
- For those with off-circle roots, verify that the inverse Cayley of any non-unit-circle root is non-real, precluding a Hermitian realization.

**Expected obstruction/failure mode.** The forward direction should succeed: given unit-circle roots, the inverse Cayley produces real eigenvalues, and a diagonal Hermitian matrix trivially realizes them. The converse direction is the nontrivial content: it should follow from the fact that non-real eigenvalues are incompatible with Hermiticity.

**Certifying theorem.** A formal proof combining:
- Hermitian matrices have real eigenvalues (Mathlib),
- The Cayley transform maps reals to the unit circle (Theorem 6.1),
- A root off the unit circle would require a non-real eigenvalue.

---

## Hypothesis 5: Approximate Functional Equation Rigidity

**Conjecture.** Let F : ℂ → ℂ be a finite trigonometric sum satisfying:
1. Exact reflection symmetry: F(1−s) = χ(1−s)·F(s) for χ with χ(s)χ(1−s) = 1,
2. Coefficient proximity: the Möbius-transported coefficients of F differ from those of a Hermitian-induced self-inversive polynomial by at most ε in ℓ∞ norm.

Then every zero of F in the critical strip 0 < Re(s) < 1 lies within distance C·ε of the critical line Re(s) = 1/2, where C depends only on the degree.

**Finite computational test.** For N = 5, 10, 15:
- Compute Z_N zeros in the critical strip.
- Measure the maximum distance from Re(s) = 1/2.
- Compute the self-inversive defect ε_N of the Möbius-transported polynomial.
- Check whether max_distance ≤ C · ε_N for some moderate constant C.

**Expected obstruction/failure mode.** The constant C may grow with degree, potentially making the bound vacuous for large N. The hypothesis may need to be refined to specify the growth rate of C(d). If C(d) grows polynomially, the result is useful; if exponentially, it is vacuous.

**Certifying theorem.** This would require formalizing perturbation theory for polynomial roots (Rouché's theorem or coefficient perturbation bounds from numerical analysis). Rouché's theorem is partially available in Mathlib; the coefficient perturbation direction would need new formalization.

---

## Priority Ordering

1. **Hypothesis 3** (easiest to certify, extends existing infrastructure)
2. **Hypothesis 4** (testable, uses existing Cayley + self-inversive theorems)
3. **Hypothesis 1** (requires new arithmetic kernel constructions)
4. **Hypothesis 2** (requires analysis of transported sums)
5. **Hypothesis 5** (requires perturbation theory, most ambitious)

## Impact Assessment

If Hypotheses 1–4 are confirmed:
- We would have a complete certified pipeline: arithmetic data → Hermitian matrix → real spectrum → unit-circle roots → critical-line zeros.
- The low-rank obstruction would precisely characterize which arithmetic kernels are viable.
- The Hermitian witness certificate would provide a constructive test for critical-line confinement.

If Hypothesis 5 is confirmed:
- It would establish *approximate* critical-line confinement for objects satisfying approximate functional equations — a quantitative analogue of the full Riemann Hypothesis for finite truncations.
- This would be, to our knowledge, the first rigidity result of this type for symmetrized Dirichlet truncations.
