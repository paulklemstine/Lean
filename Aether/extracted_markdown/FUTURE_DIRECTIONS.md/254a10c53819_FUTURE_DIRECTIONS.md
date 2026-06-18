# Future Directions: Symmetric Power Euler Factors via Invariant Theory

This document identifies five falsifiable conjectures that extend the formally verified
symmetric-cube identity to a general theory of symmetric-power Euler factors for GL₂.

---

## 1. Sym⁴ and Sym⁵ trace-determinant factorization

**Conjecture:** For every n ∈ {4, 5}, the symmetric-power local Euler denominator

  ∏_{k=0}^{n} (1 − α^{n−k} β^k X)

has all coefficients expressible as integer polynomials in t = α+β and d = αβ.

**Test:** Write the analogous `ring`-based Lean proofs for n = 4 (5 factors, degree-5 polynomial in X)
and n = 5 (6 factors, degree-6 polynomial). Compute the explicit coefficient polynomials in t, d
and verify each identity by `ring`. If `ring` times out for n = 5, that identifies a performance
boundary worth reporting.

**Impact:** Confirms the invariant-ring principle computationally up to the regime where
functorial lifts (Kim–Shahidi for Sym⁴, planned for Sym⁵) are known.

---

## 2. Chebyshev recurrence for e₁ coefficients

**Conjecture:** The coefficient of X in the Sym^n Euler denominator satisfies the recurrence

  e₁(n+1) = t · e₁(n) − d · e₁(n−1)

with e₁(0) = 1, e₁(1) = t. Equivalently, e₁(n) = U_n(t / (2√d)) · (√d)^n
where U_n is the Chebyshev polynomial of the second kind.

**Test:** Define e₁(n) := ∑_{k=0}^{n} α^{n−k} β^k in Lean and prove the recurrence
for all n by induction. Verify numerically for n ≤ 10 via `#eval` over ℚ.

**Impact:** Establishes the character-theoretic recursion at the heart of the
Hecke eigenvalue theory. Once proven, the full Sym^n Euler factor can be built
iteratively from this single recurrence.

---

## 3. Functorial determination by characteristic polynomial

**Conjecture:** For any n : ℕ and any two pairs (α, β) and (α', β') in ℂ²,
if α + β = α' + β' and αβ = α'β', then

  ∏_{k=0}^{n} (1 − α^{n−k} β^k X) = ∏_{k=0}^{n} (1 − α'^{n−k} β'^k X).

That is, the Sym^n Euler denominator is determined by the characteristic polynomial
T² − tT + d of the semisimple conjugacy class.

**Test:** Prove this in Lean for general n by showing each elementary symmetric polynomial
of the weights {α^{n−k} β^k} is a polynomial in t and d. The key step is a Newton-identity
or generating-function argument reducing to the Chebyshev recurrence of Conjecture 2.

**Impact:** This is the full invariant-ring theorem. It means Sym^n local factors
can be computed from Hecke eigenvalues without solving quadratics — the foundation
for efficient certified L-function computation.

---

## 4. Matrix-level conjugacy invariance

**Conjecture:** For a 2×2 complex matrix M with eigenvalues α, β, define the
symmetric-cube Euler factor as symmCubeEulerDen(α, β, X). This quantity depends
only on tr(M) and det(M), not on the choice of eigenbasis.

More precisely, for any invertible P, if M' = P M P⁻¹ has eigenvalues α', β', then
symmCubeEulerDen(α, β, X) = symmCubeEulerDen(α', β', X).

**Test:** Formalize this for diagonalizable matrices using Mathlib's `Matrix.charpoly`
and `Matrix.trace`/`Matrix.det` API. The proof reduces to our conjugacy invariance
theorem plus the fact that similar matrices share eigenvalues (hence trace and determinant).

**Impact:** Bridges the algebraic identity to the representation-theoretic setting
where Satake parameters naturally live as conjugacy classes in GL₂(ℂ).

---

## 5. Plethystic connection to Schur polynomials

**Conjecture:** The coefficient of X^k in the Sym^n Euler denominator equals
(−1)^k times the k-th elementary symmetric polynomial of the Sym^n weights,
and this elementary symmetric polynomial coincides with the plethysm
e_k ∘ s_{(n)} evaluated at the rank-2 alphabet {α, β}.

**Test:** For n = 3, k = 1,2,3,4, verify that our computed coefficients match
the Schur polynomial evaluation. Check whether Mathlib's `Polynomial.symmetric`
or `MvPolynomial` infrastructure provides the Schur polynomial machinery needed
to state this formally.

**Impact:** Connects the Euler factor formalization to the broader λ-ring and
representation-theoretic framework. This would allow future work on plethystic
exponentials and Adams operations to directly produce Euler factor formulas,
opening a pipeline from representation theory to certified number theory.
