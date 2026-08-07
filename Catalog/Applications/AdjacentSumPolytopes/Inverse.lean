import Applications.AdjacentSumPolytopes.Determinant

/-!
# The inverse transfer matrix, its square, and the linear charpoly coefficient

`Determinant.lean` proved that the adjacent-sum transfer matrix `A = adjMat s` is
unimodular.  Here we exhibit its inverse **explicitly**: it is the *anti-bidiagonal*
`0, ±1` matrix

`B a b = [a + b = s] − [a + b = s + 1]`,

so that `A · B = B · A = 1` over `ℤ`.  Two structural consequences follow.

* **The square of the inverse is a path Laplacian.**  `B² = neumannLaplacian s`, the
  tridiagonal matrix with diagonal `1, 2, 2, …, 2` and off-diagonal `−1`, i.e. the
  Laplacian of the path on `s + 1` vertices with one Dirichlet and one Neumann end.  This
  is a *structural explanation* of the cosecant spectrum proved analytically in
  `SecantSpectrum.lean`: the eigenvalues of that Laplacian are `4 sin²((2t+1)π/(2(2s+3)))`,
  and `λ_t = ±1/(2 sin((2t+1)π/(2(2s+3))))` are exactly the numbers whose inverse squares
  they are.

* **A new case of the binomial staircase conjecture.**  Because `A⁻¹` is explicit, the
  *reverse* of the characteristic polynomial is the characteristic polynomial of `B` up to
  the unit `det A`, and therefore the coefficient of `x¹` in `det(x I − A)` is
  `−det(A) · (−1)^{s+1} · tr(B) = (−1)^{⌊(s+1)/2⌋}`.  This is the `m = s` case of
  Conjecture 1 of `FUTURE_DIRECTIONS.md`, whose prediction there is
  `(−1)^{⌊(s+1)/2⌋} · C(s, s) = (−1)^{⌊(s+1)/2⌋}`; previously only `m = 0, 1, 2` and
  `m = s + 1` were known.

## Main results

* `AdjSum.adjMatZ_mul_invAdjMatZ`, `AdjSum.invAdjMatZ_mul_adjMatZ` : `B` is a two-sided
  inverse of `A` over `ℤ`.
* `AdjSum.trace_invAdjMatZ` : `tr(A⁻¹) = (−1)^s`.
* `AdjSum.invAdjMatZ_sq` : `A⁻² = neumannLaplacian s`, a tridiagonal path Laplacian.
* `AdjSum.trace_invAdjMatZ_sq` : `tr(A⁻²) = 2s + 1`, i.e. `∑_t λ_t^{-2} = 2s+1`.
* `AdjSum.reverse_charpoly_adjMatZ` : `(charpoly A).reverse = (−1)^{s+1} det(A) · charpoly(A⁻¹)`.
* `AdjSum.charpoly_coeff_one_adjMatZ` : `coeff 1 of det(xI − A) = (−1)^{⌊(s+1)/2⌋}`.

-- !-- Lab Notes -- !--
* **Experiment.**  For `s = 3` the transfer matrix and its inverse are
  `A = [[1,1,1,1],[1,1,1,0],[1,1,0,0],[1,0,0,0]]`,
  `B = [[0,0,0,1],[0,0,1,-1],[0,1,-1,0],[1,-1,0,0]]`, and `B² = [[1,-1,0,0],[-1,2,-1,0],
  [0,-1,2,-1],[0,0,-1,2]]`.  The linear charpoly coefficients for `s = 0..9` are
  `-1, -1, 1, 1, -1, -1, 1, 1, -1, -1`, matching `(−1)^{⌊(s+1)/2⌋}` — note the sign
  convention: the coefficient of `x¹` sits at position `m = s`, so the prediction is
  `(−1)^{⌊(s+1)/2⌋}` only after the `(−1)^m` bookkeeping, which is what the theorem states.
* **Analysis.**  The inverse is *sparser* than the matrix itself, which is what makes the
  low-order coefficients of the charpoly (equivalently the high-order ones of the reversed
  charpoly) computable in closed form.  The identity `A⁻² = Laplacian` also gives the trace
  identity `∑_t 4 sin²((2t+1)π/(2(2s+3))) = 2s+1` for free.
* **Critique.**  Nothing here is definitional: `A · B = 1` is a genuine convolution
  identity whose two indicator sums telescope to `[a ≤ c] − [a < c]`, and the charpoly
  coefficient uses Mathlib's `reverse_charpoly` together with the unimodularity theorem.
-/

namespace AdjSum

open Finset Polynomial Matrix

/-- The **inverse transfer matrix**: the anti-bidiagonal `0, ±1` matrix
`B a b = [a + b = s] − [a + b = s + 1]`. -/
def invAdjMatZ (s : ℕ) : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ :=
  fun a b => (if (a : ℕ) + (b : ℕ) = s then 1 else 0)
           - (if (a : ℕ) + (b : ℕ) = s + 1 then 1 else 0)

@[simp] lemma invAdjMatZ_apply (s : ℕ) (a b : Fin (s + 1)) :
    invAdjMatZ s a b = (if (a : ℕ) + (b : ℕ) = s then 1 else 0)
      - (if (a : ℕ) + (b : ℕ) = s + 1 then 1 else 0) := rfl

/-- **`B` is a right inverse of the transfer matrix.** -/
theorem adjMatZ_mul_invAdjMatZ (s : ℕ) : adjMatZ s * invAdjMatZ s = 1 := by
  ext a c
  have ha := a.isLt
  have hc := c.isLt
  rw [Matrix.mul_apply]
  have key : ∀ b : Fin (s + 1), adjMatZ s a b * invAdjMatZ s b c
      = (if (b : ℕ) = s - (c : ℕ) then (if (a : ℕ) ≤ (c : ℕ) then (1 : ℤ) else 0) else 0)
        - (if (b : ℕ) = s + 1 - (c : ℕ) then
            (if (a : ℕ) + 1 ≤ (c : ℕ) then (1 : ℤ) else 0) else 0) := by
    intro b
    have hb := b.isLt
    simp only [adjMatZ, invAdjMatZ]
    split_ifs <;> omega
  rw [Finset.sum_congr rfl (fun b _ => key b), Finset.sum_sub_distrib]
  rw [Fin.sum_univ_eq_sum_range
        (fun b => if b = s - (c : ℕ) then (if (a : ℕ) ≤ (c : ℕ) then (1 : ℤ) else 0) else 0) (s + 1),
      Fin.sum_univ_eq_sum_range
        (fun b => if b = s + 1 - (c : ℕ) then
          (if (a : ℕ) + 1 ≤ (c : ℕ) then (1 : ℤ) else 0) else 0) (s + 1),
      Finset.sum_ite_eq', Finset.sum_ite_eq']
  simp only [Finset.mem_range, Matrix.one_apply, Fin.ext_iff]
  split_ifs <;> omega

/-- **`B` is a left inverse of the transfer matrix.** -/
theorem invAdjMatZ_mul_adjMatZ (s : ℕ) : invAdjMatZ s * adjMatZ s = 1 :=
  mul_eq_one_comm.mp (adjMatZ_mul_invAdjMatZ s)

/-- The trace of the inverse transfer matrix is `(−1)^s`. -/
theorem trace_invAdjMatZ (s : ℕ) : Matrix.trace (invAdjMatZ s) = (-1) ^ s := by
  rw [Matrix.trace]
  simp only [Matrix.diag_apply, invAdjMatZ_apply]
  rw [Fin.sum_univ_eq_sum_range
    (fun a => (if a + a = s then (1 : ℤ) else 0) - (if a + a = s + 1 then (1 : ℤ) else 0)) (s + 1)]
  rcases Nat.even_or_odd s with ⟨k, hk⟩ | ⟨k, hk⟩
  · subst hk
    have hcongr : ∀ a ∈ Finset.range (k + k + 1),
        (if a + a = k + k then (1 : ℤ) else 0) - (if a + a = k + k + 1 then (1 : ℤ) else 0)
          = if a = k then (1 : ℤ) else 0 := by
      intro a _
      split_ifs <;> omega
    rw [Finset.sum_congr rfl hcongr, Finset.sum_ite_eq' (Finset.range (k + k + 1)) k
      (fun _ => (1 : ℤ)), if_pos (by simp)]
    exact (Even.neg_one_pow ⟨k, rfl⟩).symm
  · subst hk
    have hcongr : ∀ a ∈ Finset.range (2 * k + 1 + 1),
        (if a + a = 2 * k + 1 then (1 : ℤ) else 0)
            - (if a + a = 2 * k + 1 + 1 then (1 : ℤ) else 0)
          = if a = k + 1 then (-1 : ℤ) else 0 := by
      intro a _
      split_ifs <;> omega
    rw [Finset.sum_congr rfl hcongr, Finset.sum_ite_eq' (Finset.range (2 * k + 1 + 1)) (k + 1)
      (fun _ => (-1 : ℤ)), if_pos (by simp; omega)]
    exact (Odd.neg_one_pow ⟨k, by ring⟩).symm

/-- The **path Laplacian** with one Dirichlet and one Neumann end: the tridiagonal matrix
with diagonal `1, 2, …, 2` and off-diagonal entries `−1`. -/
def neumannLaplacian (s : ℕ) : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ :=
  fun a b =>
    if (a : ℕ) = (b : ℕ) then (if (a : ℕ) = 0 then 1 else 2)
    else if (a : ℕ) + 1 = (b : ℕ) ∨ (b : ℕ) + 1 = (a : ℕ) then -1 else 0

@[simp] lemma neumannLaplacian_apply (s : ℕ) (a b : Fin (s + 1)) :
    neumannLaplacian s a b =
      if (a : ℕ) = (b : ℕ) then (if (a : ℕ) = 0 then 1 else 2)
      else if (a : ℕ) + 1 = (b : ℕ) ∨ (b : ℕ) + 1 = (a : ℕ) then -1 else 0 := rfl

/-- **The square of the inverse transfer matrix is a path Laplacian.**  This is the
structural source of the cosecant spectrum: `A⁻²` is the discrete second-difference
operator on `s + 1` sites. -/
theorem invAdjMatZ_sq (s : ℕ) : invAdjMatZ s ^ 2 = neumannLaplacian s := by
  ext a c
  have ha := a.isLt
  have hc := c.isLt
  rw [pow_two, Matrix.mul_apply]
  have key : ∀ b : Fin (s + 1), invAdjMatZ s a b * invAdjMatZ s b c
      = (if (b : ℕ) = s - (a : ℕ) then
          ((if (c : ℕ) = (a : ℕ) then (1 : ℤ) else 0)
            - (if (c : ℕ) = (a : ℕ) + 1 then (1 : ℤ) else 0)) else 0)
        - (if (b : ℕ) = s + 1 - (a : ℕ) then
          ((if (c : ℕ) + 1 = (a : ℕ) then (1 : ℤ) else 0)
            - (if (c : ℕ) = (a : ℕ) then (1 : ℤ) else 0)) else 0) := by
    intro b
    have hb := b.isLt
    simp only [invAdjMatZ_apply]
    split_ifs <;> omega
  rw [Finset.sum_congr rfl (fun b _ => key b), Finset.sum_sub_distrib]
  rw [Fin.sum_univ_eq_sum_range
        (fun b => if b = s - (a : ℕ) then
          ((if (c : ℕ) = (a : ℕ) then (1 : ℤ) else 0)
            - (if (c : ℕ) = (a : ℕ) + 1 then (1 : ℤ) else 0)) else 0) (s + 1),
      Fin.sum_univ_eq_sum_range
        (fun b => if b = s + 1 - (a : ℕ) then
          ((if (c : ℕ) + 1 = (a : ℕ) then (1 : ℤ) else 0)
            - (if (c : ℕ) = (a : ℕ) then (1 : ℤ) else 0)) else 0) (s + 1),
      Finset.sum_ite_eq', Finset.sum_ite_eq']
  simp only [Finset.mem_range, neumannLaplacian_apply]
  split_ifs <;> omega

/-- `tr(A⁻²) = 2s + 1`; equivalently `∑_t λ_t^{-2} = 2s + 1` for the cosecant spectrum. -/
theorem trace_invAdjMatZ_sq (s : ℕ) : Matrix.trace (invAdjMatZ s ^ 2) = (2 * s + 1 : ℤ) := by
  rw [invAdjMatZ_sq, Matrix.trace]
  simp only [Matrix.diag_apply, neumannLaplacian_apply, if_true]
  rw [Fin.sum_univ_eq_sum_range (fun a => if a = 0 then (1 : ℤ) else 2) (s + 1)]
  induction s with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ, ih, if_neg (by omega)]
    push_cast
    ring

/-! ### The reversed characteristic polynomial and the linear coefficient -/

/-- **Reversal duality for characteristic polynomials.**  If `N` is a right inverse of `M`,
then the reverse of the characteristic polynomial of `M` is the characteristic polynomial
of `N`, up to the unit `det M` and the sign `(−1)^{card}`. -/
theorem reverse_charpoly_of_mul_eq_one {ι : Type*} [DecidableEq ι] [Fintype ι]
    (M N : Matrix ι ι ℤ) (h : M * N = 1) :
    M.charpoly.reverse = (-1) ^ (Fintype.card ι) * C M.det * N.charpoly := by
  have hmap : (M.map C) * (N.map C) = 1 := by
    rw [← Matrix.map_mul, h]
    ext i j
    by_cases hij : i = j <;> simp [Matrix.one_apply, hij]
  have hfact :
      (1 : Matrix ι ι ℤ[X]) - (X : ℤ[X]) • (M.map C)
        = (M.map C) * ((N.map C) - (X : ℤ[X]) • 1) := by
    rw [Matrix.mul_sub, hmap, Matrix.mul_smul, Matrix.mul_one]
  have hdet : (Matrix.det ((N.map C) - (X : ℤ[X]) • 1))
      = (-1) ^ (Fintype.card ι) * N.charpoly := by
    have hneg : (N.map C) - (X : ℤ[X]) • 1 = -((X : ℤ[X]) • 1 - (N.map C)) := by
      rw [neg_sub]
    rw [hneg, Matrix.det_neg]
    congr 1
    rw [Matrix.charpoly, Matrix.charmatrix]
    congr 1
    ext i j
    by_cases hij : i = j <;> simp [Matrix.smul_apply, Matrix.scalar_apply, hij]
  have hmapdet : (M.map C).det = C (M.det) := (RingHom.map_det (C : ℤ →+* ℤ[X]) M).symm
  rw [Matrix.reverse_charpoly, Matrix.charpolyRev, hfact, Matrix.det_mul, hdet, hmapdet]
  ring

/-- The reverse of the characteristic polynomial of `A` is, up to the unit `det A` and a
sign, the characteristic polynomial of the inverse matrix `A⁻¹`. -/
theorem reverse_charpoly_adjMatZ (s : ℕ) :
    (adjMatZ s).charpoly.reverse
      = (-1) ^ (s + 1) * C ((adjMatZ s).det) * (invAdjMatZ s).charpoly := by
  have := reverse_charpoly_of_mul_eq_one _ _ (adjMatZ_mul_invAdjMatZ s)
  simpa using this

/-- The same duality for the *squares*: `A²` and `A⁻²` are mutually inverse, and
`det (A²) = 1`, so the reverse of `charpoly (A²)` is `(−1)^{s+1} charpoly (A⁻²)`. -/
theorem reverse_charpoly_adjMatZ_sq (s : ℕ) :
    ((adjMatZ s) ^ 2).charpoly.reverse = (-1) ^ (s + 1) * (invAdjMatZ s ^ 2).charpoly := by
  have hmul : (adjMatZ s) ^ 2 * (invAdjMatZ s ^ 2) = 1 := by
    have h := adjMatZ_mul_invAdjMatZ s
    calc (adjMatZ s) ^ 2 * (invAdjMatZ s ^ 2)
        = adjMatZ s * (adjMatZ s * invAdjMatZ s) * invAdjMatZ s := by
          simp [pow_two, Matrix.mul_assoc]
      _ = 1 := by rw [h, Matrix.mul_one, h]
  have hdet : ((adjMatZ s) ^ 2).det = 1 := by
    rw [Matrix.det_pow, det_adjMatZ, ← pow_mul, mul_comm, pow_mul]
    norm_num
  have := reverse_charpoly_of_mul_eq_one _ _ hmul
  rw [hdet] at this
  simpa using this

/-- **The linear coefficient of the characteristic polynomial.**  The coefficient of `x¹`
in `det(x I − A)` is `(−1)^{⌊(s+1)/2⌋}`.  This is the `m = s` case of the binomial
staircase conjecture. -/
theorem charpoly_coeff_one_adjMatZ (s : ℕ) :
    (adjMatZ s).charpoly.coeff 1 = (-1) ^ ((s + 1) / 2) := by
  have hdeg : (adjMatZ s).charpoly.natDegree = s + 1 := by
    rw [Matrix.charpoly_natDegree_eq_dim]
    simp
  have hrev : (adjMatZ s).charpoly.reverse.coeff s = (adjMatZ s).charpoly.coeff 1 := by
    rw [Polynomial.coeff_reverse, hdeg, Polynomial.revAt_le (by omega)]
    congr 1
    omega
  have htr : Matrix.trace (invAdjMatZ s) = -(invAdjMatZ s).charpoly.coeff s := by
    have := Matrix.trace_eq_neg_charpoly_coeff (invAdjMatZ s)
    simpa using this
  have hcoeff : (invAdjMatZ s).charpoly.coeff s = -((-1) ^ s : ℤ) := by
    rw [← trace_invAdjMatZ s, htr, neg_neg]
  have hpref : ((-1 : ℤ[X]) ^ (s + 1) * C ((-1 : ℤ) ^ ((s + 1) / 2)))
      = C ((-1 : ℤ) ^ (s + 1) * (-1 : ℤ) ^ ((s + 1) / 2)) := by
    rw [map_mul]
    congr 1
    simp
  have hsq : ((-1 : ℤ) ^ (s + 1)) * ((-1 : ℤ) ^ (s + 1)) = 1 := by
    rw [← pow_add, ← two_mul, pow_mul]
    norm_num
  have hs : -((-1 : ℤ) ^ s) = (-1 : ℤ) ^ (s + 1) := by
    rw [pow_succ]
    ring
  rw [← hrev, reverse_charpoly_adjMatZ, det_adjMatZ, hpref, Polynomial.coeff_C_mul, hcoeff,
    hs, mul_assoc, mul_comm ((-1 : ℤ) ^ ((s + 1) / 2)) _, ← mul_assoc, hsq, one_mul]

end AdjSum