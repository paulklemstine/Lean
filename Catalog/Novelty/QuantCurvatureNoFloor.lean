import Mathlib
import Novelty.WeightQuantFloorLadder

/-!
# Curvature explains the weight ladder: a `4`-per-bit ceiling and no intrinsic floor

Companion to `Novelty.WeightQuantFloorLadder` (NET-95).  The measured k-quant
ladder obeys a geometric law with per-bit factor in `[5/2, 3]`.  This file gives
the structural model that *predicts* such a law, and proves the two statements
that dissolve the alleged "sub-6-bit floor".

**The model.**  Near a trained optimum the loss increase caused by a weight
perturbation `e` is, to second order, the quadratic form
`quadExcess lam e = ½ ∑ᵢ λᵢ eᵢ²` in the Hessian eigenbasis.  A `b`-bit quantiser
with dynamic-range constant `c` produces `|eᵢ| ≤ c / 2 ^ b`.  Hence

  `quadExcess ≤ (n Λ c² / 2) / 4 ^ b = curvatureBound K b`.

**Two consequences.**

* `curvatureBound_per_bit` — the model's degradation is multiplied by *exactly*
  `4` per bit removed.  So `4` is the theoretical ceiling of the per-bit rate,
  and `measured_ladder_beats_curvature_ceiling` records that the measured ladder
  stays strictly below it at every pair of rungs (observed rates `2.54`–`2.98`):
  calibration-aware k-quants beat the naive curvature prediction.
* `quantizer_quality_is_a_bit_shift` — a quantiser that is `2 ^ j` times more
  accurate is worth *exactly* `j` bits: the degradation bound at bit width `b`
  with constant `c / 2 ^ j` equals the bound at width `b + j` with constant `c`.
  Combined with `no_intrinsic_floor` (for any bit width and any tolerance there
  is a quantiser quality meeting the tolerance *at that width*) this is the NET-95
  law in formal form: **the floor is a property of (quantiser quality × scale),
  never of the bit width alone.**

Finally `curvatureBound_convexOn` shows the model curve is convex in the bit
width — the "gentle convex curve" of the measurement — and `no_bit_width_floor`
shows that in this model no finite bit width is undeployable.
-/

namespace Catalog.Novelty.QuantCurvature

open Finset Catalog.Novelty.WeightQuantFloor

/-! ## 1. The second-order model -/

/-- Second-order (Hessian) model of the loss increase caused by a weight
perturbation `e`, written in the Hessian eigenbasis with eigenvalues `lam`. -/
noncomputable def quadExcess {n : ℕ} (lam e : Fin n → ℝ) : ℝ :=
  (1 / 2) * ∑ i, lam i * e i ^ 2

/-- At a critical point of a convex-along-eigendirections loss the modelled
excess is nonnegative. -/
theorem quadExcess_nonneg {n : ℕ} (lam e : Fin n → ℝ) (hlam : ∀ i, 0 ≤ lam i) :
    0 ≤ quadExcess lam e := by
  have : 0 ≤ ∑ i, lam i * e i ^ 2 :=
    Finset.sum_nonneg fun i _ => mul_nonneg (hlam i) (sq_nonneg _)
  simpa [quadExcess] using by linarith

/-- The degradation bound predicted by curvature: `K / 4 ^ b` at `b` bits. -/
noncomputable def curvatureBound (K : ℝ) (b : ℕ) : ℝ := K / 4 ^ b

/-- **Curvature bound.**  A `b`-bit quantiser with dynamic-range constant `c`
(coordinatewise error at most `c / 2 ^ b`) increases a quadratic loss with
eigenvalues bounded by `Λ` by at most `curvatureBound (n Λ c² / 2) b`. -/
theorem quadExcess_le_curvatureBound {n : ℕ} (lam e : Fin n → ℝ) (Λ c : ℝ) (b : ℕ)
    (hlam : ∀ i, 0 ≤ lam i) (hΛ : ∀ i, lam i ≤ Λ)
    (he : ∀ i, |e i| ≤ c / 2 ^ b) :
    quadExcess lam e ≤ curvatureBound (n * Λ * c ^ 2 / 2) b := by
  have hterm : ∀ i ∈ Finset.univ, lam i * e i ^ 2 ≤ Λ * (c ^ 2 / 4 ^ b) := by
    intro i _
    have h1 : e i ^ 2 ≤ (c / 2 ^ b) ^ 2 := by
      have := abs_nonneg (e i)
      nlinarith [he i, abs_nonneg (e i), sq_abs (e i)]
    have h2 : (c / 2 ^ b : ℝ) ^ 2 = c ^ 2 / 4 ^ b := by
      rw [div_pow]
      congr 1
      rw [← pow_mul, mul_comm, pow_mul]
      norm_num
    calc lam i * e i ^ 2 ≤ lam i * (c ^ 2 / 4 ^ b) := by
          rw [h2] at h1
          exact mul_le_mul_of_nonneg_left h1 (hlam i)
      _ ≤ Λ * (c ^ 2 / 4 ^ b) := by
          have : (0:ℝ) ≤ c ^ 2 / 4 ^ b := by positivity
          exact mul_le_mul_of_nonneg_right (hΛ i) this
  have hsum : ∑ i, lam i * e i ^ 2 ≤ (n : ℝ) * (Λ * (c ^ 2 / 4 ^ b)) := by
    have := Finset.sum_le_sum hterm
    simpa [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using this
  have h4 : (0:ℝ) < 4 ^ b := by positivity
  have hgoal : (n : ℝ) * (Λ * (c ^ 2 / 4 ^ b)) = 2 * ((n * Λ * c ^ 2 / 2) / 4 ^ b) := by
    field_simp
  rw [quadExcess, curvatureBound]
  linarith [hsum, hgoal]

/-! ## 2. The `4`-per-bit ceiling -/

/-- **The theoretical ceiling.**  In the curvature model the degradation is
multiplied by exactly `4` for each bit of precision removed. -/
theorem curvatureBound_per_bit (K : ℝ) (b : ℕ) :
    curvatureBound K b = 4 * curvatureBound K (b + 1) := by
  simp [curvatureBound, pow_succ]
  ring

/-- The model curve is strictly decreasing in the bit width when `K > 0`. -/
theorem curvatureBound_strictAnti {K : ℝ} (hK : 0 < K) {b b' : ℕ} (h : b < b') :
    curvatureBound K b' < curvatureBound K b := by
  have h1 : (0:ℝ) < 4 ^ b := by positivity
  have h2 : (4:ℝ) ^ b < 4 ^ b' := by
    exact pow_lt_pow_right₀ (by norm_num) h
  exact div_lt_div_of_pos_left hK h1 h2

/-- Discrete convexity of the model curve: a strict midpoint inequality. -/
theorem curvatureBound_convex_discrete {K : ℝ} (hK : 0 < K) (b : ℕ) :
    2 * curvatureBound K (b + 1) < curvatureBound K b + curvatureBound K (b + 2) := by
  have h4 : (0:ℝ) < 4 ^ b := by positivity
  have e0 : curvatureBound K b = K / 4 ^ b := rfl
  have e1 : curvatureBound K (b + 1) = K / (4 ^ b * 4) := by
    simp [curvatureBound, pow_succ]
  have e2 : curvatureBound K (b + 2) = K / (4 ^ b * 16) := by
    simp [curvatureBound, pow_succ]
    ring_nf
  rw [e0, e1, e2]
  have key : K / 4 ^ b + K / (4 ^ b * 16) - 2 * (K / (4 ^ b * 4)) = 9 * K / (16 * 4 ^ b) := by
    field_simp
    ring
  have hpos : 0 < 9 * K / (16 * 4 ^ b) := by positivity
  linarith [key, hpos]

/-- The continuous version of the model curve, `b ↦ K · 4 ^ (-b)`, is convex on
`ℝ` for `K ≥ 0`: the measured "gentle convex curve" is exactly the shape the
curvature model predicts. -/
theorem curvatureBound_convexOn {K : ℝ} (hK : 0 ≤ K) :
    ConvexOn ℝ Set.univ (fun b : ℝ => K * Real.exp (-(Real.log 4) * b)) := by
  have hcomp : ConvexOn ℝ Set.univ (fun b : ℝ => Real.exp (-(Real.log 4) * b)) := by
    have h := convexOn_exp.comp_affineMap
      (((-(Real.log 4)) • (LinearMap.id : ℝ →ₗ[ℝ] ℝ)).toAffineMap)
    simpa [Function.comp, smul_eq_mul] using h
  simpa using hcomp.smul hK

/-- **No bit-width floor in the model.**  For any tolerance `T > 0` there is a
finite bit width whose modelled degradation is under `T`: nothing in the model
makes some bit width intrinsically undeployable. -/
theorem no_bit_width_floor (K T : ℝ) (hT : 0 < T) : ∃ b : ℕ, curvatureBound K b ≤ T := by
  obtain ⟨b, hb⟩ := pow_unbounded_of_one_lt (max K 0 / T) (by norm_num : (1:ℝ) < 4)
  refine ⟨b, ?_⟩
  have h4 : (0:ℝ) < 4 ^ b := by positivity
  have hKle : K ≤ max K 0 := le_max_left _ _
  have : max K 0 / T < 4 ^ b := hb
  have h2 : max K 0 < T * 4 ^ b := by
    rw [div_lt_iff₀ hT] at this
    linarith [this]
  rw [curvatureBound, div_le_iff₀ h4]
  linarith

/-! ## 3. Quantiser quality is a bit shift -/

/-- **Quality ↔ bits.**  A quantiser `2 ^ j` times more accurate is worth exactly
`j` bits: the curvature bound at width `b` with constant `c / 2 ^ j` is the bound
at width `b + j` with constant `c`.  Hence no bit width is intrinsically a
"floor" — a floor observed with one quantiser is displaced by `j` bits by a
quantiser `2 ^ j` times better. -/
theorem quantizer_quality_is_a_bit_shift (n Λ c : ℝ) (j b : ℕ) :
    curvatureBound (n * Λ * (c / 2 ^ j) ^ 2 / 2) b
      = curvatureBound (n * Λ * c ^ 2 / 2) (b + j) := by
  have h2 : ((2:ℝ) ^ j) ^ 2 = 4 ^ j := by
    rw [← pow_mul, mul_comm, pow_mul]
    norm_num
  have hne : ((2:ℝ) ^ j) ≠ 0 := by positivity
  simp only [curvatureBound, div_pow, pow_add, h2]
  field_simp

/-- **No intrinsic floor.**  Fix *any* bit width `b` and any tolerance `T > 0`:
there is a quantiser quality `j` (accuracy improved by `2 ^ j`) for which the
curvature bound at that very bit width is within tolerance.  The alleged
"sub-6-bit floor" is therefore a statement about the quantiser, not about `b`. -/
theorem no_intrinsic_floor (n Λ c T : ℝ) (hn : 0 ≤ n) (hΛ : 0 ≤ Λ) (b : ℕ) (hT : 0 < T) :
    ∃ j : ℕ, curvatureBound (n * Λ * (c / 2 ^ j) ^ 2 / 2) b ≤ T := by
  obtain ⟨j, hj⟩ := no_bit_width_floor (n * Λ * c ^ 2 / 2) T hT
  refine ⟨j, ?_⟩
  rw [quantizer_quality_is_a_bit_shift]
  refine le_trans ?_ hj
  have hK : (0:ℝ) ≤ n * Λ * c ^ 2 / 2 := by positivity
  have hle : (4:ℝ) ^ j ≤ 4 ^ (b + j) := pow_le_pow_right₀ (by norm_num) (by omega)
  simp only [curvatureBound]
  gcongr

/-! ## 4. The measurement versus the ceiling -/

/-- **The data beats the ceiling.**  Every pair of rungs of the measured k-quant
ladder degrades strictly slower than the curvature model's `4`-per-bit ceiling
(`curvatureBound_per_bit`).  Measured per-bit rates run `2.54`–`2.98`: calibration
recovers a factor the second-order model does not know about. -/
theorem measured_ladder_beats_curvature_ceiling {r s : Rung} (hr : r ∈ ladder)
    (hs : s ∈ ladder) (h : s.tenthBits < r.tenthBits) :
    excess s ^ 10 < 4 ^ (r.tenthBits - s.tenthBits) * excess r ^ 10 :=
  weight_ladder_cliff_free hr hs h

end Catalog.Novelty.QuantCurvature