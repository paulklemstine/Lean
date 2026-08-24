import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialParityCapacity
import Algebra.ZeroFitDialU64MedianCapacity
import Algebra.ZeroFitDialU64CapacityJump

/-!
# The minimal ambient dimension of a capacity extremiser

## Research context

Sixth cycle on the `U64B-DIAL-HOLDS-COUNT-PARITY` record (exp 543).  The extremisers of
the interpolating capacity law `k·ρ² ≤ 1 + (k-1)γ` are now classified: equidistant Gram
matrix (`capacity_extremal_forces_equidistant`), all readings equal
(`capacity_extremal_readings_exact`), response the normalised sum
(`capacity_extremal_response_parallel`).  The realiser used to prove sharpness
(`capacity_realizable_equidistant`) lives in ambient dimension `k + 1`, but the
classification says the response lies in the *span* of the family, so one coordinate ought
to be redundant.  Conjecture **N2** of the thread asks for the minimal dimension.  This
file settles it: the answer is exactly `k`.

## Main results

* `eqVec_dot` — the Gram matrix of the explicit family
  `uᵢ(x) = A·[i = x] + B` in `ℝ^k`, with `A = √(1-γ)` and `B = (√(1+(k-1)γ) - A)/k`.
* `equidistant_realizable_dimension_k` — **the construction.**  For `k ≥ 1` and
  `-1/(k-1) ≤ γ ≤ 1` (written as `0 ≤ 1 + (k-1)γ`), there is a family of `k` unit vectors
  in `ℝ^k` with all pairwise inner products equal to `γ`, together with a unit response
  reading exactly `ρ = √((1+(k-1)γ)/k)` against every member.  Ambient dimension `k+1` is
  therefore never needed.
* `equidistant_linearIndependent` — for `γ < 1` and `1 + (k-1)γ > 0` an equidistant family
  is linearly independent.  The proof evaluates the quadratic form
  `(1-γ)∑gᵢ² + γ(∑gᵢ)²` on a vanishing combination and splits on the sign of `γ`, using
  Cauchy–Schwarz in the negative range.
* `equidistant_dimension_lower_bound` — **minimality.**  In that range no equidistant
  family of size `k` fits in an ambient dimension below `k`.
* `capacity_extremiser_minimal_dimension` — the two halves combined: `k` is exactly the
  minimal ambient dimension of a capacity extremiser.
* `gram_equal_frame_unique`, `equidistant_frame_unique` — **uniqueness of the frame.**  In
  the minimal dimension the Gram matrix determines the configuration: two equidistant
  families of the same size and mutual correlation are related by an orthogonal matrix
  `O` with `O Oᵀ = 1`.  Together with the previous items the extremiser is classified
  completely, up to the choice of an orthonormal frame in `ℝ^k`.
* `u64b_triple_realizable_in_three_dimensions` — at the recorded cell, the three
  statistics with pairwise correlation `0.1163215` all reading `0.641` fit in `ℝ³`, and no
  fewer.

## Scientific payload

The capacity sheet has a canonical model: a `k`-dimensional one.  Combined with the
extremiser classification, an extremal dial family is now determined up to the choice of an
orthonormal frame in `ℝ^k`, so "saturating the capacity bound" is a complete structural
description rather than a numerical coincidence.  The dimension count also gives an
independent reading of the recorded cell: a triple of statistics at the bitlen-64 dial
level with the minimal admissible mutual correlation needs three degrees of freedom and no
more, so a dial family cannot be hidden inside a lower-dimensional summary of the sample.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU64ExtremalDimension

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialParityCapacity
open Catalog.Algebra.ZeroFitDialU64MedianCapacity
open Catalog.Algebra.ZeroFitDialU64CapacityJump

variable {k n : ℕ}

/-! ## 1. The `k`-dimensional realiser -/

/-- The diagonal scale of the explicit equidistant family. -/
noncomputable def eqA (gamma : ℝ) : ℝ := Real.sqrt (1 - gamma)

/-- The uniform shift of the explicit equidistant family. -/
noncomputable def eqB (k : ℕ) (gamma : ℝ) : ℝ :=
  (Real.sqrt (1 + ((k : ℝ) - 1) * gamma) - Real.sqrt (1 - gamma)) / (k : ℝ)

/-- The explicit equidistant family in `ℝ^k`: a scaled standard basis vector plus a
uniform shift. -/
noncomputable def eqVec (k : ℕ) (gamma : ℝ) (i : Fin k) : Fin k → ℝ :=
  fun x => (if i = x then eqA gamma else 0) + eqB k gamma

/-- The Gram matrix of the explicit family, before substituting the values of `A` and
`B`. -/
lemma eqVec_dot (k : ℕ) (gamma : ℝ) (i j : Fin k) :
    dot (eqVec k gamma i) (eqVec k gamma j)
      = (if i = j then eqA gamma ^ 2 else 0) + 2 * eqA gamma * eqB k gamma
        + (k : ℝ) * eqB k gamma ^ 2 := by
  simp only [dot, eqVec, add_mul, mul_add]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib]
  by_cases hij : i = j
  · subst hij
    simp [Finset.sum_ite_eq]
    ring
  · simp [hij, Finset.sum_ite_eq]
    ring

/-- The uniform unit response in `ℝ^k`. -/
noncomputable def eqResp (k : ℕ) : Fin k → ℝ := fun _ => 1 / Real.sqrt (k : ℝ)

/-- **The `k`-dimensional realiser.**  For every admissible `(k, gamma)` there is an
equidistant family of `k` unit vectors in `ℝ^k`, with a unit response read at exactly
`√((1+(k-1)γ)/k)` by every member. -/
theorem equidistant_realizable_dimension_k {gamma : ℝ} (hk : 1 ≤ k) (hg1 : gamma ≤ 1)
    (hgk : 0 ≤ 1 + ((k : ℝ) - 1) * gamma) :
    ∃ (u : Fin k → (Fin k → ℝ)) (w : Fin k → ℝ),
      (∀ i, dot (u i) (u i) = 1) ∧ (∀ i j, i ≠ j → dot (u i) (u j) = gamma) ∧
        dot w w = 1 ∧
        ∀ i, dot (u i) w = Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / (k : ℝ)) := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hkne : (k : ℝ) ≠ 0 := ne_of_gt hkR
  set A : ℝ := eqA gamma with hAdef
  set B : ℝ := eqB k gamma with hBdef
  set C : ℝ := Real.sqrt (1 + ((k : ℝ) - 1) * gamma) with hCdef
  have hA2 : A ^ 2 = 1 - gamma := Real.sq_sqrt (by linarith)
  have hC2 : C ^ 2 = 1 + ((k : ℝ) - 1) * gamma := Real.sq_sqrt hgk
  have hkB : (k : ℝ) * B = C - A := by
    rw [hBdef, eqB, hAdef, eqA, hCdef]
    field_simp
  -- the off-diagonal value
  have hoff : 2 * A * B + (k : ℝ) * B ^ 2 = gamma := by
    have h1 : (k : ℝ) * (2 * A * B + (k : ℝ) * B ^ 2)
        = ((k : ℝ) * B) * (2 * A + (k : ℝ) * B) := by ring
    rw [hkB] at h1
    have h2 : (C - A) * (2 * A + (C - A)) = C ^ 2 - A ^ 2 := by ring
    rw [h2, hC2, hA2] at h1
    have h3 : (k : ℝ) * (2 * A * B + (k : ℝ) * B ^ 2) = (k : ℝ) * gamma := by
      rw [h1]; ring
    exact mul_left_cancel₀ hkne h3
  have hdiag : ∀ i, dot (eqVec k gamma i) (eqVec k gamma i) = 1 := by
    intro i
    rw [eqVec_dot, if_pos rfl, ← hAdef, ← hBdef]
    rw [show A ^ 2 + 2 * A * B + (k : ℝ) * B ^ 2 = A ^ 2 + (2 * A * B + (k : ℝ) * B ^ 2) by ring,
      hoff, hA2]
    ring
  have hoffd : ∀ i j : Fin k, i ≠ j → dot (eqVec k gamma i) (eqVec k gamma j) = gamma := by
    intro i j hij
    rw [eqVec_dot, if_neg hij, ← hAdef, ← hBdef, zero_add, hoff]
  -- the response
  have hsqk : Real.sqrt (k : ℝ) ^ 2 = (k : ℝ) := Real.sq_sqrt (le_of_lt hkR)
  have hsqkpos : (0 : ℝ) < Real.sqrt (k : ℝ) := Real.sqrt_pos.mpr hkR
  have hprod : (1 / Real.sqrt (k : ℝ)) * (1 / Real.sqrt (k : ℝ)) = 1 / (k : ℝ) := by
    rw [div_mul_div_comm, one_mul, ← sq, hsqk]
  have hww : dot (eqResp k) (eqResp k) = 1 := by
    simp only [dot, eqResp]
    rw [Finset.sum_congr rfl fun x _ => hprod, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    field_simp
  have hread : ∀ i, dot (eqVec k gamma i) (eqResp k) = C / Real.sqrt (k : ℝ) := by
    intro i
    simp only [dot, eqVec, eqResp, add_mul]
    rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
    have hone : ∑ x, (if i = x then A else 0) * (1 / Real.sqrt (k : ℝ))
        = A * (1 / Real.sqrt (k : ℝ)) := by
      simp [Finset.sum_ite_eq]
    rw [hone]
    have : A * (1 / Real.sqrt (k : ℝ)) + (k : ℝ) * (B * (1 / Real.sqrt (k : ℝ)))
        = (A + (k : ℝ) * B) / Real.sqrt (k : ℝ) := by field_simp
    rw [this, hkB]
    ring_nf
  refine ⟨eqVec k gamma, eqResp k, hdiag, hoffd, hww, fun i => ?_⟩
  rw [hread i, hCdef, Real.sqrt_div' _ (le_of_lt hkR)]

/-! ## 2. Minimality of the dimension -/

/-- An equidistant family with `gamma < 1` and `1 + (k-1)γ > 0` is linearly independent. -/
theorem equidistant_linearIndependent {gamma : ℝ} {u : Fin k → (Fin n → ℝ)}
    (hdiag : ∀ i, dot (u i) (u i) = 1) (hoff : ∀ i j, i ≠ j → dot (u i) (u j) = gamma)
    (hg1 : gamma < 1) (hgk : 0 < 1 + ((k : ℝ) - 1) * gamma) :
    LinearIndependent ℝ u := by
  classical
  rw [Fintype.linearIndependent_iff]
  intro g hg
  -- the quadratic form of the Gram matrix evaluated at `g`
  have hgram : ∀ i, ∑ j, g j * dot (u i) (u j)
      = gamma * (∑ j, g j) + (1 - gamma) * g i := by
    intro i
    have hsplit : ∑ j, g j * dot (u i) (u j)
        = ∑ j, (gamma * g j + (if j = i then (1 - gamma) * g i else 0)) := by
      refine Finset.sum_congr rfl fun j _ => ?_
      by_cases hji : j = i
      · subst hji; rw [hdiag j, if_pos rfl]; ring
      · rw [hoff i j (Ne.symm hji), if_neg hji]; ring
    rw [hsplit, Finset.sum_add_distrib, ← Finset.mul_sum,
      Finset.sum_ite_eq' univ i fun _ => (1 - gamma) * g i]
    simp
  set S : Fin n → ℝ := fun x => ∑ i, g i * u i x with hS
  have hS0 : ∀ x, S x = 0 := by
    intro x
    have := congrFun hg x
    simpa [hS, Finset.sum_apply] using this
  have hSS : dot S S = 0 := by
    simp [dot, hS0]
  have hexpand : dot S S = gamma * (∑ i, g i) ^ 2 + (1 - gamma) * ∑ i, g i ^ 2 := by
    have h1 : dot S S = ∑ i, g i * dot (u i) S := by
      rw [hS, dot_sum_left]
    have h2 : ∀ i, dot (u i) S = ∑ j, g j * dot (u i) (u j) := by
      intro i
      rw [dot_comm, hS, dot_sum_left]
      exact Finset.sum_congr rfl fun j _ => by rw [dot_comm]
    have hterm : ∀ i ∈ (univ : Finset (Fin k)),
        g i * (gamma * (∑ j, g j) + (1 - gamma) * g i)
          = gamma * (∑ j, g j) * g i + (1 - gamma) * g i ^ 2 := fun i _ => by ring
    rw [h1, Finset.sum_congr rfl fun i _ => by rw [h2 i, hgram i],
      Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
    ring
  have hsq : ∑ i, g i ^ 2 = 0 := by
    have hnn : (0 : ℝ) ≤ ∑ i, g i ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
    rcases le_or_gt 0 gamma with hpos | hneg
    · nlinarith [sq_nonneg (∑ i, g i), hexpand, hSS, hnn]
    · have hCS : (∑ i, g i) ^ 2 ≤ ((univ : Finset (Fin k)).card : ℝ) * ∑ i, g i ^ 2 :=
        sq_sum_le_card_mul_sum_sq
      rw [Finset.card_univ, Fintype.card_fin] at hCS
      nlinarith [hexpand, hSS, hnn, hCS]
  intro i
  have := (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => sq_nonneg (g j))).mp hsq i
    (Finset.mem_univ i)
  exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this

/-- **Minimality.**  In the nondegenerate range no equidistant family of size `k` fits into
an ambient dimension smaller than `k`. -/
theorem equidistant_dimension_lower_bound {gamma : ℝ} {u : Fin k → (Fin n → ℝ)}
    (hdiag : ∀ i, dot (u i) (u i) = 1) (hoff : ∀ i j, i ≠ j → dot (u i) (u j) = gamma)
    (hg1 : gamma < 1) (hgk : 0 < 1 + ((k : ℝ) - 1) * gamma) :
    k ≤ n := by
  have hli := equidistant_linearIndependent hdiag hoff hg1 hgk
  have := hli.fintype_card_le_finrank
  rwa [Fintype.card_fin, Module.finrank_fin_fun ℝ] at this

/-- **The minimal ambient dimension of a capacity extremiser is exactly `k`.**  The
equidistant configuration forced by `capacity_extremal_forces_equidistant` is realisable in
`ℝ^k` and in no smaller space. -/
theorem capacity_extremiser_minimal_dimension {gamma : ℝ} (hk : 1 ≤ k) (hg1 : gamma < 1)
    (hgk : 0 < 1 + ((k : ℝ) - 1) * gamma) :
    (∃ (u : Fin k → (Fin k → ℝ)) (w : Fin k → ℝ),
        (∀ i, dot (u i) (u i) = 1) ∧ (∀ i j, i ≠ j → dot (u i) (u j) = gamma) ∧
          dot w w = 1 ∧
          ∀ i, dot (u i) w = Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / (k : ℝ))) ∧
      ∀ m : ℕ, m < k → ¬ ∃ u : Fin k → (Fin m → ℝ),
        (∀ i, dot (u i) (u i) = 1) ∧ ∀ i j, i ≠ j → dot (u i) (u j) = gamma := by
  refine ⟨equidistant_realizable_dimension_k hk (le_of_lt hg1) (le_of_lt hgk), ?_⟩
  rintro m hm ⟨u, hdiag, hoff⟩
  exact absurd (equidistant_dimension_lower_bound hdiag hoff hg1 hgk) (not_le.mpr hm)

/-! ## 3. Uniqueness of the frame -/

open Matrix in
/-- **Two families with the same Gram matrix differ by an orthogonal change of frame.**
For `k` linearly independent vectors in `ℝ^k` the Gram matrix determines the configuration
up to an orthogonal matrix acting on the ambient coordinates. -/
theorem gram_equal_frame_unique (u v : Fin k → (Fin k → ℝ))
    (hu : LinearIndependent ℝ u)
    (hG : ∀ i j, dot (u i) (u j) = dot (v i) (v j)) :
    ∃ O : Matrix (Fin k) (Fin k) ℝ, O * Oᵀ = 1 ∧ ∀ i x, v i x = ∑ y, u i y * O y x := by
  classical
  set U : Matrix (Fin k) (Fin k) ℝ := Matrix.of (fun i x => u i x) with hU
  set V : Matrix (Fin k) (Fin k) ℝ := Matrix.of (fun i x => v i x) with hV
  have hUrow : U.row = u := rfl
  have hUunit : IsUnit U := Matrix.linearIndependent_rows_iff_isUnit.mp (by rw [hUrow]; exact hu)
  have hUdet : IsUnit U.det := (Matrix.isUnit_iff_isUnit_det U).mp hUunit
  have hUT : IsUnit (Uᵀ).det := by rw [Matrix.det_transpose]; exact hUdet
  have hgram : U * Uᵀ = V * Vᵀ := by
    ext i j
    simp only [Matrix.mul_apply, Matrix.transpose_apply, hU, hV, Matrix.of_apply]
    exact hG i j
  refine ⟨U⁻¹ * V, ?_, ?_⟩
  · rw [Matrix.transpose_mul, Matrix.transpose_nonsing_inv]
    calc U⁻¹ * V * (Vᵀ * (Uᵀ)⁻¹) = U⁻¹ * (V * Vᵀ) * (Uᵀ)⁻¹ := by
          simp [Matrix.mul_assoc]
      _ = U⁻¹ * (U * Uᵀ) * (Uᵀ)⁻¹ := by rw [hgram]
      _ = (U⁻¹ * U) * (Uᵀ * (Uᵀ)⁻¹) := by simp [Matrix.mul_assoc]
      _ = 1 := by
          rw [Matrix.nonsing_inv_mul U hUdet, Matrix.mul_nonsing_inv _ hUT, Matrix.one_mul]
  · intro i x
    have hUV : U * (U⁻¹ * V) = V := by
      rw [← Matrix.mul_assoc, Matrix.mul_nonsing_inv U hUdet, Matrix.one_mul]
    have h2 := congrFun (congrFun hUV i) x
    rw [Matrix.mul_apply] at h2
    simpa [hU, hV] using h2.symm

open Matrix in
/-- **Extremal dial families are unique up to an orthogonal frame.**  Any two equidistant
families with the same size `k` and the same mutual correlation `gamma`, living in the
minimal ambient dimension `k`, are related by an orthogonal transformation. -/
theorem equidistant_frame_unique {gamma : ℝ} (u v : Fin k → (Fin k → ℝ))
    (hud : ∀ i, dot (u i) (u i) = 1) (huo : ∀ i j, i ≠ j → dot (u i) (u j) = gamma)
    (hvd : ∀ i, dot (v i) (v i) = 1) (hvo : ∀ i j, i ≠ j → dot (v i) (v j) = gamma)
    (hg1 : gamma < 1) (hgk : 0 < 1 + ((k : ℝ) - 1) * gamma) :
    ∃ O : Matrix (Fin k) (Fin k) ℝ, O * Oᵀ = 1 ∧ ∀ i x, v i x = ∑ y, u i y * O y x := by
  refine gram_equal_frame_unique u v (equidistant_linearIndependent hud huo hg1 hgk)
    fun i j => ?_
  by_cases hij : i = j
  · subst hij; rw [hud i, hvd i]
  · rw [huo i j hij, hvo i j hij]

/-! ## 4. The recorded cell -/

/-- At the recorded cell, the three statistics with pairwise correlation `0.1163215` all
reading `0.641` fit in `ℝ³`, and in no smaller space. -/
theorem u64b_triple_realizable_in_three_dimensions :
    (∃ (u : Fin 3 → (Fin 3 → ℝ)) (w : Fin 3 → ℝ),
        (∀ i, dot (u i) (u i) = 1) ∧
          (∀ i j, i ≠ j → dot (u i) (u j) = 232643 / 2000000) ∧
          dot w w = 1 ∧ ∀ i, dot (u i) w = (641 : ℝ) / 1000) ∧
      ∀ m : ℕ, m < 3 → ¬ ∃ u : Fin 3 → (Fin m → ℝ),
        (∀ i, dot (u i) (u i) = 1) ∧
          ∀ i j, i ≠ j → dot (u i) (u j) = 232643 / 2000000 := by
  obtain ⟨hex, hmin⟩ := capacity_extremiser_minimal_dimension (k := 3)
    (gamma := 232643 / 2000000) (by norm_num) (by norm_num) (by norm_num)
  refine ⟨?_, hmin⟩
  obtain ⟨u, w, h1, h2, h3, h4⟩ := hex
  refine ⟨u, w, h1, h2, h3, fun i => ?_⟩
  have h := h4 i
  rw [show (1 + (((3 : ℕ) : ℝ) - 1) * (232643 / 2000000)) / ((3 : ℕ) : ℝ)
      = ((641 : ℝ) / 1000) ^ 2 by norm_num, Real.sqrt_sq (by norm_num)] at h
  exact h

end Catalog.Algebra.ZeroFitDialU64ExtremalDimension