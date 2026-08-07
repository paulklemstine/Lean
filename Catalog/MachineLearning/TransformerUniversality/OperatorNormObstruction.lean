import Mathlib

/-!
# The spectral form of the low-rank obstruction: head width is a dimension-free resource

`Catalog/MachineLearning/TransformerUniversality/LowRankQuantitative.lean` proves that the
score matrix of a head of width `dk < d` has some *entry* at distance at least `β / d` from the
exact-selection pattern `β • 1`, and that the constant `1/d` is optimal for the entrywise
(sup-norm) distance.  The third next-cycle sub-conjecture of `FUTURE_DIRECTIONS.md` asked
whether that bound upgrades to the operator norm "with the same constant `β / d`".

This file settles it, and the answer is **stronger than conjectured**: in the operator norm the
obstruction is `β`, with *no* dimension factor at all, and this is again exactly optimal.  The
`1/d` of the entrywise statement was therefore an artifact of measuring a rank-one deviation in
the sup norm — spreading an error of spectral size `β` over `d²` entries makes each entry small,
but the error itself never shrinks.

Main results:

* `beta_le_of_opNormLe` — **lower bound**: if `S` is singular and every vector satisfies
  `‖(S − β•1)v‖ ≤ r‖v‖` (with `r ≥ 0`), then `β ≤ r`.  The proof takes a kernel vector `v`,
  on which the deviation acts as `−β·v` exactly, so the deviation has an eigenvalue of modulus
  `β`.
* `centeringScaled_opNormLe` — **matching construction**: the scaled centering matrix
  `β(1 − J/d)` is singular and satisfies `‖(β(1 − J/d) − β•1)v‖ ≤ β‖v‖`, by Cauchy–Schwarz.
* `spectral_distance_to_scaled_identity` — hence `IsLeast`: the spectral distance from `β • 1`
  to the singular matrices is **exactly `β`**.
* `qk_spectral_far_from_scaled_identity`, `headDim_lower_bound_of_spectral_approx` — the
  architectural corollaries: a head of width `dk < d` is at spectral distance at least `β` from
  the exact-selection pattern, uniformly in `d`, so a *relative* spectral accuracy better than
  `100 %` already forces full head width.

The contrast with `LowRankQuantitative.entrywise_distance_to_identity_eq` (`1/d`) is the point:
the two norms give genuinely different resource statements, and the operator-norm one is the
one that survives taking `d → ∞`.
-/

open scoped BigOperators
open Matrix

namespace OperatorNormObstruction

variable {n : ℕ}

/-! ## Squared Euclidean norm and the operator-norm predicate -/

/-- The squared Euclidean norm of a coordinate vector.  Using the *squared* norm keeps every
statement polynomial and avoids `Real.sqrt`. -/
def sqNorm (v : Fin n → ℝ) : ℝ := ∑ i, (v i) ^ 2

theorem sqNorm_nonneg (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem sqNorm_pos {v : Fin n → ℝ} (hv : v ≠ 0) : 0 < sqNorm v := by
  obtain ⟨i, hi⟩ := Function.ne_iff.mp hv
  have hi' : v i ≠ 0 := by simpa using hi
  have h1 : (0 : ℝ) < (v i) ^ 2 := by positivity
  exact lt_of_lt_of_le h1
    (Finset.single_le_sum (f := fun i => (v i) ^ 2) (fun j _ => sq_nonneg _) (Finset.mem_univ i))

/-- `OpNormLe M r` says that the matrix `M` has operator norm at most `r`, expressed with
squared Euclidean norms. -/
def OpNormLe (M : Matrix (Fin n) (Fin n) ℝ) (r : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, sqNorm (M.mulVec v) ≤ r ^ 2 * sqNorm v

/-! ## Singularity from a kernel vector -/

/-- A matrix with a nonzero kernel vector has rank `< n`. -/
theorem rank_lt_of_kernel {M : Matrix (Fin n) (Fin n) ℝ} {v : Fin n → ℝ} (hv : v ≠ 0)
    (hMv : M.mulVec v = 0) : M.rank < n := by
  have hker : v ∈ LinearMap.ker M.mulVecLin := by
    simpa [Matrix.mulVecLin] using hMv
  have hnt : Nontrivial (LinearMap.ker M.mulVecLin) :=
    ⟨⟨0, ⟨v, hker⟩, fun hc => hv (congrArg Subtype.val hc).symm⟩⟩
  have hpos : 0 < Module.finrank ℝ (LinearMap.ker M.mulVecLin) := Module.finrank_pos
  have hrk := LinearMap.finrank_range_add_finrank_ker M.mulVecLin
  simp only [Matrix.rank]
  simp only [Module.finrank_fin_fun] at hrk
  omega

/-- Conversely, a matrix of rank `< n` has a nonzero kernel vector. -/
theorem exists_kernel_of_rank_lt {M : Matrix (Fin n) (Fin n) ℝ} (hrank : M.rank < n) :
    ∃ v : Fin n → ℝ, v ≠ 0 ∧ M.mulVec v = 0 := by
  have hdet : M.det = 0 := by
    by_contra hd
    have hu : IsUnit M := (Matrix.isUnit_iff_isUnit_det M).mpr (isUnit_iff_ne_zero.mpr hd)
    have h := Matrix.rank_of_isUnit M hu
    simp at h
    omega
  exact (Matrix.exists_mulVec_eq_zero_iff).mpr hdet

/-! ## The spectral lower bound -/

/-- On a kernel vector the deviation `S − β•1` acts as multiplication by `−β`. -/
theorem deviation_mulVec_kernel {S : Matrix (Fin n) (Fin n) ℝ} {v : Fin n → ℝ} (beta : ℝ)
    (hv : S.mulVec v = 0) :
    (S - beta • (1 : Matrix (Fin n) (Fin n) ℝ)).mulVec v = -(beta • v) := by
  funext i
  have h1 : ((beta • (1 : Matrix (Fin n) (Fin n) ℝ)) *ᵥ v) i = beta * v i := by
    simp [Matrix.mulVec, dotProduct, Matrix.one_apply, ite_mul]
  simp [Matrix.sub_mulVec, hv, h1]

theorem sqNorm_neg_smul (beta : ℝ) (v : Fin n → ℝ) :
    sqNorm (-(beta • v)) = beta ^ 2 * sqNorm v := by
  simp only [sqNorm, Pi.neg_apply, Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **Spectral low-rank obstruction.**  A singular matrix is at operator-norm distance at least
`β` from `β` times the identity: the deviation has `−β` as an eigenvalue on the kernel. -/
theorem beta_le_of_opNormLe (S : Matrix (Fin n) (Fin n) ℝ) (hrank : S.rank < n)
    {beta r : ℝ} (hr : 0 ≤ r)
    (h : OpNormLe (S - beta • (1 : Matrix (Fin n) (Fin n) ℝ)) r) : beta ≤ r := by
  obtain ⟨v, hv0, hv⟩ := exists_kernel_of_rank_lt hrank
  have hspec := h v
  rw [deviation_mulVec_kernel beta hv, sqNorm_neg_smul] at hspec
  have hpos : 0 < sqNorm v := sqNorm_pos hv0
  have hsq2 : beta ^ 2 ≤ r ^ 2 := le_of_mul_le_mul_right hspec hpos
  nlinarith [hsq2, hr]

/-! ## Sharpness: the scaled centering matrix -/

/-- The scaled centering matrix `β(1 − J/n)`. -/
noncomputable def centeringScaled (n : ℕ) (beta : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => beta * ((if i = j then (1 : ℝ) else 0) - (n : ℝ)⁻¹)

/-- The scaled centering matrix kills the all-ones vector, hence is singular. -/
theorem centeringScaled_rank_lt (hn : 0 < n) (beta : ℝ) : (centeringScaled n beta).rank < n := by
  have hnR : (n : ℝ) ≠ 0 := by positivity
  set v : Fin n → ℝ := fun _ => 1 with hv
  have hv0 : v ≠ 0 := by
    intro hc
    have := congrFun hc ⟨0, hn⟩
    simp [hv] at this
  refine rank_lt_of_kernel hv0 ?_
  funext i
  simp only [Matrix.mulVec, dotProduct, centeringScaled, Matrix.of_apply, hv, mul_one,
    Pi.zero_apply]
  rw [← Finset.mul_sum, Finset.sum_sub_distrib]
  simp [hnR]

/-- The deviation of the scaled centering matrix from `β•1` is the rank-one matrix `−(β/n)J`. -/
theorem centeringScaled_deviation (beta : ℝ) (i j : Fin n) :
    (centeringScaled n beta - beta • (1 : Matrix (Fin n) (Fin n) ℝ)) i j = -(beta / n) := by
  simp only [Matrix.sub_apply, Matrix.smul_apply, Matrix.one_apply, centeringScaled,
    Matrix.of_apply, smul_eq_mul]
  by_cases h : i = j <;> simp [h] <;> ring

/-- **The constant `β` is attained.**  By Cauchy–Schwarz, the rank-one deviation `−(β/n)J` has
operator norm exactly `|β|`, so the scaled centering matrix is a singular matrix at spectral
distance `β` from `β•1`. -/
theorem centeringScaled_opNormLe (hn : 0 < n) (beta : ℝ) :
    OpNormLe (centeringScaled n beta - beta • (1 : Matrix (Fin n) (Fin n) ℝ)) beta := by
  intro v
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hmul : ∀ i, (centeringScaled n beta -
      beta • (1 : Matrix (Fin n) (Fin n) ℝ)).mulVec v i = -(beta / n) * ∑ j, v j := by
    intro i
    simp only [Matrix.mulVec, dotProduct, centeringScaled_deviation, Finset.mul_sum]
  have hsq : sqNorm ((centeringScaled n beta -
      beta • (1 : Matrix (Fin n) (Fin n) ℝ)).mulVec v)
      = n * ((beta / n) ^ 2 * (∑ j, v j) ^ 2) := by
    simp only [sqNorm, hmul]
    rw [Finset.sum_congr rfl (fun i _ => by ring :
      ∀ i ∈ (Finset.univ : Finset (Fin n)), (-(beta / n) * ∑ j, v j) ^ 2
        = (beta / n) ^ 2 * (∑ j, v j) ^ 2)]
    simp [Finset.sum_const, nsmul_eq_mul]
  have hcs : (∑ j, v j) ^ 2 ≤ n * sqNorm v := by
    have h := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin n))) (f := v)
    simpa [sqNorm] using h
  rw [hsq]
  have hb2 : (0 : ℝ) ≤ beta ^ 2 := sq_nonneg beta
  have key : n * ((beta / n) ^ 2 * (∑ j, v j) ^ 2) = (beta ^ 2 / n) * (∑ j, v j) ^ 2 := by
    field_simp
  rw [key]
  have hstep : (beta ^ 2 / n) * (∑ j, v j) ^ 2 ≤ (beta ^ 2 / n) * (n * sqNorm v) :=
    mul_le_mul_of_nonneg_left hcs (by positivity)
  calc (beta ^ 2 / n) * (∑ j, v j) ^ 2 ≤ (beta ^ 2 / n) * (n * sqNorm v) := hstep
    _ = beta ^ 2 * sqNorm v := by field_simp

/-- **The spectral distance from `β•1` to the singular matrices is exactly `β`.**  This is the
operator-norm counterpart of `LowRankQuantitative.entrywise_distance_to_identity_eq`, and the
dimension factor `1/n` of the entrywise statement disappears. -/
theorem spectral_distance_to_scaled_identity (hn : 0 < n) {beta : ℝ} (hbeta : 0 ≤ beta) :
    IsLeast {r : ℝ | 0 ≤ r ∧ ∃ S : Matrix (Fin n) (Fin n) ℝ, S.rank < n ∧
      OpNormLe (S - beta • (1 : Matrix (Fin n) (Fin n) ℝ)) r} beta := by
  constructor
  · exact ⟨hbeta, centeringScaled n beta, centeringScaled_rank_lt hn beta,
      centeringScaled_opNormLe hn beta⟩
  · rintro r ⟨hr, S, hS, hop⟩
    exact beta_le_of_opNormLe S hS hr hop

/-! ## Architectural corollaries for narrow attention heads -/

section Heads

variable {d dk : ℕ}

/-- The learned score matrix of a head of width `dk` (cf. `LowRankQuantitative.scoreMatrix`). -/
def scoreMatrix (WQ WK : Matrix (Fin dk) (Fin d) ℝ) : Matrix (Fin d) (Fin d) ℝ := WQᵀ * WK

theorem rank_scoreMatrix_le (WQ WK : Matrix (Fin dk) (Fin d) ℝ) :
    (scoreMatrix WQ WK).rank ≤ dk :=
  le_trans (Matrix.rank_mul_le_left _ _) (Matrix.rank_le_width WQᵀ)

/-- **Dimension-free head-width obstruction.**  A head of width `dk < d` is at operator-norm
distance at least `β` from the exact-selection score pattern `β•1`: unlike the entrywise bound
`β / d`, this does not degrade as the model width grows. -/
theorem qk_spectral_far_from_scaled_identity (hd : dk < d) (WQ WK : Matrix (Fin dk) (Fin d) ℝ)
    {beta r : ℝ} (hr : 0 ≤ r)
    (h : OpNormLe (scoreMatrix WQ WK - beta • (1 : Matrix (Fin d) (Fin d) ℝ)) r) :
    beta ≤ r :=
  beta_le_of_opNormLe _ (lt_of_le_of_lt (rank_scoreMatrix_le WQ WK) hd) hr h

/-- **Head-width lower bound in the spectral norm.**  Approximating the exact-selection pattern
at scale `β > 0` to spectral accuracy strictly better than `β` — i.e. to *any* nontrivial
relative accuracy — forces full head width `dk ≥ d`. -/
theorem headDim_lower_bound_of_spectral_approx (WQ WK : Matrix (Fin dk) (Fin d) ℝ)
    {beta r : ℝ} (hr : 0 ≤ r) (hlt : r < beta)
    (h : OpNormLe (scoreMatrix WQ WK - beta • (1 : Matrix (Fin d) (Fin d) ℝ)) r) :
    d ≤ dk := by
  by_contra hcon
  push_neg at hcon
  exact absurd (qk_spectral_far_from_scaled_identity hcon WQ WK hr h) (not_le.mpr hlt)

end Heads

end OperatorNormObstruction