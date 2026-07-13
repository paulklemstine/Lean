/-
# Factorization of the Cyclotomic Gauss-Sum Matrix

This file formalizes the linear-algebraic core of the *cyclotomic Gauss-sum
matrix factorization*.  In the number-theoretic setting one studies, over a
cyclotomic field, the `n × n` matrix

  `A_k(χ) = [ G_N(χ^{k(i+j)}) ]`,

where `G_N` is a Gauss sum over `ℤ/Nℤ` (with `N = p^m`, `n = φ(N)/k`).  The
classical statement is that this matrix decomposes as

  `A = W D Wᵀ`,

where `W` is the `n × n` discrete Fourier transform matrix `W i a = ω^{a i}`
(`ω` a primitive `n`-th root of unity) and `D = diag(η_0, …, η_{n-1})` collects
the `n` **Gauss periods** attached to the `k`-th power residue cyclotomic
cosets.  The decomposition is a *purely formal* consequence of the fact that a
Gauss sum is the finite Fourier transform of the corresponding Gauss periods:

  `G_N(χ^{ks}) = ∑_a η_a · ω^{a s}`.

Rather than reconstruct the full cyclotomic Gauss-sum machinery, we isolate and
prove this structural content over an arbitrary commutative ring `R`, taking the
generating identity as the *definition* of the entries of `A`.  This yields a
faithful, self-contained account of the factorization together with several
consequences that were absent from the informal description.

## Main results

* `A_factor` : the factorization `A = W · D · Wᵀ` (the central claim).
* `Wmat_symm`, `Amat_symm` : both `W` and `A` are symmetric.
* `Wmat_eq_vandermonde`, `Wmat_det` : `W` is a Vandermonde matrix, with the
  explicit product determinant `∏_{i<j} (ω^j - ω^i)`.
* `Amat_det` : `det A = (det W)² · ∏_a η_a`.
* `Amat_det_ne_zero_iff` : over a field, `A` is invertible iff the nodes `ω^i`
  are distinct and every Gauss period `η_a` is nonzero.
* `Wmat_orthogonality` : the discrete Fourier orthogonality
  `(Wᵀ W)_{a,b} = n` if `n ∣ a+b`, else `0` (DFT unitarity, up to reversal).
* `dft_inversion` / `eta_from_matrix` : Fourier inversion recovering the Gauss
  periods `η_c` from the matrix by the inverse DFT.

## A contrarian conjecture, refuted

A tempting "bold conjecture" is that, since the Fourier matrix `W` is (up to
scaling) orthogonal, one should have `Wᵀ W = n · I`.  This is **false**:
`Wmat_orthogonality` shows that `Wᵀ W = n · P` where `P` is the *reversal
permutation* `a ↦ (n - a) mod n`, which is not the identity once `n ≥ 3`.  We
formalize the refutation as `WtW_ne_scalar`.
-/
import Mathlib

open scoped BigOperators
open Matrix

namespace CyclotomicGaussMatrix

variable {R : Type*} [CommRing R]

/-- The discrete Fourier transform ("Vandermonde") matrix `W i a = ω^(a·i)`. -/
def Wmat (n : ℕ) (ω : R) : Matrix (Fin n) (Fin n) R :=
  fun i a => ω ^ ((a : ℕ) * (i : ℕ))

/-- The diagonal matrix `D = diag(η_0, …, η_{n-1})` of Gauss periods. -/
def Dmat (n : ℕ) (η : Fin n → R) : Matrix (Fin n) (Fin n) R :=
  Matrix.diagonal η

/-- The cyclotomic Gauss-sum matrix, with entries given by the finite Fourier
transform of the Gauss periods: `A i j = ∑ a, η a · ω^(a·(i+j))`.  In the
number-theoretic model `A i j = G_N(χ^{k(i+j)})`. -/
def Amat (n : ℕ) (ω : R) (η : Fin n → R) : Matrix (Fin n) (Fin n) R :=
  fun i j => ∑ a : Fin n, η a * ω ^ ((a : ℕ) * ((i : ℕ) + (j : ℕ)))

/-- The Fourier matrix `W` is symmetric. -/
theorem Wmat_symm (n : ℕ) (ω : R) : (Wmat n ω)ᵀ = Wmat n ω := by
  ext i a; simp [Wmat, Matrix.transpose_apply, Nat.mul_comm]

/-- The Gauss-sum matrix `A` is symmetric (its entries depend only on `i + j`). -/
theorem Amat_symm (n : ℕ) (ω : R) (η : Fin n → R) : (Amat n ω η)ᵀ = Amat n ω η := by
  ext i j
  simp only [Amat, Matrix.transpose_apply]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [Nat.add_comm]

/-- **The factorization `A = W · D · Wᵀ`.**  This is the central structural claim:
the cyclotomic Gauss-sum matrix is the `W D Wᵀ` conjugate of the diagonal matrix
of Gauss periods by the discrete Fourier transform matrix. -/
theorem A_factor (n : ℕ) (ω : R) (η : Fin n → R) :
    Amat n ω η = Wmat n ω * Dmat n η * (Wmat n ω)ᵀ := by
  ext i j
  simp only [Amat, Matrix.mul_apply, Dmat, Matrix.transpose_apply, Wmat]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [show ((a:ℕ) * ((i:ℕ)+(j:ℕ))) = (a:ℕ)*(i:ℕ) + (a:ℕ)*(j:ℕ) by ring, pow_add]
  rw [Finset.sum_eq_single a]
  · simp [Matrix.diagonal_apply_eq]; ring
  · intro b _ hb; simp [Matrix.diagonal_apply_ne _ hb]
  · intro h; simp at h

/-- `W` is literally a Vandermonde matrix in the nodes `ω^i`. -/
theorem Wmat_eq_vandermonde (n : ℕ) (ω : R) :
    Wmat n ω = Matrix.vandermonde (fun i => ω ^ (i : ℕ)) := by
  ext i a; simp [Wmat, Matrix.vandermonde, ← pow_mul, Nat.mul_comm]

/-- The determinant of `W` is the Vandermonde product in the nodes `ω^i`. -/
theorem Wmat_det (n : ℕ) (ω : R) :
    (Wmat n ω).det = ∏ i : Fin n, ∏ j ∈ Finset.Ioi i, (ω ^ (j : ℕ) - ω ^ (i : ℕ)) := by
  rw [Wmat_eq_vandermonde, Matrix.det_vandermonde]

/-- The determinant of the Gauss-sum matrix factors as `(det W)² · ∏ η_a`. -/
theorem Amat_det (n : ℕ) (ω : R) (η : Fin n → R) :
    (Amat n ω η).det = (Wmat n ω).det ^ 2 * ∏ a : Fin n, η a := by
  rw [A_factor, Matrix.det_mul, Matrix.det_mul, Matrix.det_transpose, Dmat,
    Matrix.det_diagonal]; ring

/-- Over a field, the Gauss-sum matrix is invertible exactly when the Fourier
nodes `ω^i` are distinct (`det W ≠ 0`) and all Gauss periods are nonzero. -/
theorem Amat_det_ne_zero_iff {K : Type*} [Field K] (n : ℕ) (ω : K) (η : Fin n → K) :
    (Amat n ω η).det ≠ 0 ↔ (Wmat n ω).det ≠ 0 ∧ ∀ a, η a ≠ 0 := by
  rw [Amat_det, mul_ne_zero_iff, pow_ne_zero_iff (by norm_num), Finset.prod_ne_zero_iff]
  simp

open Classical in
/-- Geometric sum of an `n`-th root of unity over `Fin n`: it is `n` if the
element is `1`, and `0` otherwise. -/
theorem geom_fin_sum {K : Type*} [Field K] {n : ℕ} {r : K} (hr : r ^ n = 1) :
    ∑ i : Fin n, r ^ (i : ℕ) = if r = 1 then (n : K) else 0 := by
  classical
  rw [Fin.sum_univ_eq_sum_range (fun i => r ^ i) n]
  by_cases h : r = 1
  · rw [if_pos h, h]; simp
  · rw [if_neg h, geom_sum_eq h, hr]; simp

/-- **Discrete Fourier orthogonality (DFT unitarity).**  With `ω` a primitive
`n`-th root of unity, `(Wᵀ W)_{a,b} = n` when `n ∣ a + b` and `0` otherwise.
The nonzero pattern is that of the *reversal* permutation `a ↦ n - a`, not the
identity. -/
theorem Wmat_orthogonality {K : Type*} [Field K] {n : ℕ} {ω : K}
    (hω : IsPrimitiveRoot ω n) (a b : Fin n) :
    ((Wmat n ω)ᵀ * Wmat n ω) a b = if n ∣ ((a : ℕ) + (b : ℕ)) then (n : K) else 0 := by
  classical
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Wmat]
  have hsum : ∑ i : Fin n, ω ^ ((a:ℕ)*(i:ℕ)) * ω ^ ((b:ℕ)*(i:ℕ))
      = ∑ i : Fin n, (ω ^ ((a:ℕ)+(b:ℕ))) ^ (i:ℕ) := by
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [← pow_add, ← pow_mul]; ring_nf
  rw [hsum, Fin.sum_univ_eq_sum_range (fun i => (ω ^ ((a:ℕ)+(b:ℕ))) ^ i) n]
  by_cases h : n ∣ ((a:ℕ)+(b:ℕ))
  · rw [if_pos h]
    have : ω ^ ((a:ℕ)+(b:ℕ)) = 1 := (hω.pow_eq_one_iff_dvd _).2 h
    rw [this]; simp
  · rw [if_neg h]
    have hne : ω ^ ((a:ℕ)+(b:ℕ)) ≠ 1 := by
      rw [Ne, hω.pow_eq_one_iff_dvd _]; exact h
    rw [geom_sum_eq hne]
    have : (ω ^ ((a:ℕ)+(b:ℕ))) ^ n = 1 := by
      rw [← pow_mul, Nat.mul_comm, pow_mul, hω.pow_eq_one, one_pow]
    rw [this]; simp

/-- Cross orthogonality of the Fourier characters, phrased with inverse powers:
`∑_i (ω^{c i})⁻¹ · ω^{a i} = n · [a = c]`. -/
theorem inner_orth {K : Type*} [Field K] {n : ℕ} {ω : K}
    (hω : IsPrimitiveRoot ω n) (a c : Fin n) :
    ∑ i : Fin n, (ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ * ω ^ ((a:ℕ)*(i:ℕ))
      = if a = c then (n : K) else 0 := by
  classical
  have hn : 0 < n := c.pos
  have hω0 : ω ≠ 0 := hω.ne_zero (by omega)
  have hstep : ∀ i : Fin n, (ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ * ω ^ ((a:ℕ)*(i:ℕ))
      = (ω ^ (a:ℕ) * (ω ^ (c:ℕ))⁻¹) ^ (i:ℕ) := by
    intro i
    have : (ω ^ (a:ℕ) * (ω ^ (c:ℕ))⁻¹) ^ (i:ℕ)
        = ω ^ ((a:ℕ)*(i:ℕ)) * (ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ := by
      rw [mul_pow, ← pow_mul, inv_pow, ← pow_mul]
    rw [this, mul_comm]
  rw [Finset.sum_congr rfl (fun i _ => hstep i)]
  have h1 : ω ^ ((a:ℕ)*n) = 1 := by rw [Nat.mul_comm, pow_mul, hω.pow_eq_one, one_pow]
  have h2 : ω ^ ((c:ℕ)*n) = 1 := by rw [Nat.mul_comm, pow_mul, hω.pow_eq_one, one_pow]
  have hrn : (ω ^ (a:ℕ) * (ω ^ (c:ℕ))⁻¹) ^ n = 1 := by
    rw [mul_pow, ← pow_mul, inv_pow, ← pow_mul, h1, h2, inv_one, mul_one]
  rw [geom_fin_sum hrn]
  by_cases hac : a = c
  · rw [if_pos hac, if_pos (by rw [hac]; exact mul_inv_cancel₀ (pow_ne_zero _ hω0))]
  · rw [if_neg hac, if_neg]
    intro hcontra
    have hpow : ω ^ (a:ℕ) = ω ^ (c:ℕ) := by
      field_simp at hcontra; linear_combination hcontra
    exact hac (Fin.ext (hω.pow_inj a.2 c.2 hpow))

/-- **Fourier inversion / Gauss-period recovery.**  The Gauss periods are
recovered from their finite Fourier transform by the inverse DFT:
`∑_i (ω^{c i})⁻¹ · (∑_a η_a ω^{a i}) = n · η_c`. -/
theorem dft_inversion {K : Type*} [Field K] {n : ℕ} {ω : K}
    (hω : IsPrimitiveRoot ω n) (η : Fin n → K) (c : Fin n) :
    ∑ i : Fin n, (ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ * (∑ a : Fin n, η a * ω ^ ((a:ℕ)*(i:ℕ)))
      = (n : K) * η c := by
  classical
  have hdistrib : ∀ i : Fin n,
      (ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ * (∑ a : Fin n, η a * ω ^ ((a:ℕ)*(i:ℕ)))
      = ∑ a : Fin n, η a * ((ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ * ω ^ ((a:ℕ)*(i:ℕ))) := by
    intro i; rw [Finset.mul_sum]; refine Finset.sum_congr rfl (fun a _ => ?_); ring
  rw [Finset.sum_congr rfl (fun i _ => hdistrib i), Finset.sum_comm]
  have hcollect : ∀ a : Fin n,
      ∑ i : Fin n, η a * ((ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ * ω ^ ((a:ℕ)*(i:ℕ)))
      = η a * (if a = c then (n:K) else 0) := by
    intro a; rw [← Finset.mul_sum, inner_orth hω a c]
  rw [Finset.sum_congr rfl (fun a _ => hcollect a), Finset.sum_eq_single c]
  · rw [if_pos rfl]; ring
  · intro b _ hb; rw [if_neg hb]; ring
  · intro h; exact absurd (Finset.mem_univ c) h

/-- The Gauss periods are recovered directly from the `0`-th column of the
Gauss-sum matrix `A` by the inverse DFT. -/
theorem eta_from_matrix {K : Type*} [Field K] {n : ℕ} {ω : K}
    (hω : IsPrimitiveRoot ω n) (η : Fin n → K) (c : Fin n) :
    ∑ i : Fin n, (ω ^ ((c:ℕ)*(i:ℕ)))⁻¹ * (Amat n ω η) i ⟨0, c.pos⟩ = (n : K) * η c := by
  rw [← dft_inversion hω η c]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  simp only [Amat, Nat.add_zero]

/-- **Contrarian result (a refuted conjecture).**  Although `W` is a discrete
Fourier transform matrix, the naïve expectation `Wᵀ W = n · I` is *false* for
`n ≥ 3`: by `Wmat_orthogonality`, `Wᵀ W` is `n` times the reversal permutation,
whose off-diagonal entry at `(1, n-1)` equals `n ≠ 0`. -/
theorem WtW_ne_scalar {K : Type*} [Field K] {n : ℕ} {ω : K}
    (hω : IsPrimitiveRoot ω n) (hn : 3 ≤ n) (hchar : (n : K) ≠ 0) :
    (Wmat n ω)ᵀ * Wmat n ω ≠ (n : K) • (1 : Matrix (Fin n) (Fin n) K) := by
  have horth : ∀ a b : Fin n, ((Wmat n ω)ᵀ * Wmat n ω) a b
      = ∑ i : Fin n, (ω ^ ((a:ℕ)*(i:ℕ))) * ω ^ ((b:ℕ)*(i:ℕ)) := by
    intro a b; simp only [Matrix.mul_apply, Matrix.transpose_apply, Wmat]
  intro heq
  set a : Fin n := ⟨1, by omega⟩ with ha
  set b : Fin n := ⟨n-1, by omega⟩ with hb
  have hab : (a:ℕ) + (b:ℕ) = n := by simp only [ha, hb]; omega
  have hne : a ≠ b := by simp only [ha, hb, ne_eq, Fin.mk.injEq]; omega
  have hlhs : ((Wmat n ω)ᵀ * Wmat n ω) a b = (n : K) := by
    rw [horth]
    have hone : ∀ i : Fin n, (ω ^ ((a:ℕ)*(i:ℕ))) * ω ^ ((b:ℕ)*(i:ℕ)) = 1 := by
      intro i
      rw [← pow_add, ← Nat.add_mul, hab, pow_mul, hω.pow_eq_one, one_pow]
    rw [Finset.sum_congr rfl (fun i _ => hone i)]; simp
  have hrhs : ((n : K) • (1 : Matrix (Fin n) (Fin n) K)) a b = 0 := by
    simp [hne]
  rw [heq, hrhs] at hlhs
  exact hchar hlhs.symm

end CyclotomicGaussMatrix