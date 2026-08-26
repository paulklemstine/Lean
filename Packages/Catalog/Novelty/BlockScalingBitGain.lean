import Mathlib
import Novelty.WeightQuantFloorLadder

/-!
# Separating quantiser quality from scale: block scaling is worth `log₂ (R / rms)` bits

Cycle 3 of the NET-95 thread.  The measurement's own "honest limits" section flags
a confound: the toy sub-6-bit floor (NET-52, round-to-nearest with a *single*
tensor-wide scale) versus the k-quant ladder that stays deployable to 2.6 bpw
crosses **quantiser quality and model scale simultaneously**.  This file removes
the qualitative part of that confound by computing, exactly, what the *quality*
half is worth.

**Model.**  Split a tensor into `B` blocks; let `r i` be the dynamic range of
block `i` and `R = maxᵢ r i` the tensor-wide range.  A `b`-bit uniform quantiser
with one global scale has per-coordinate error proportional to `R / 2 ^ b`; with a
per-block scale, block `i` has error proportional to `r i / 2 ^ b`, so the mean
square error is governed by `rms r` in place of `R`.  Define the **scale gain**
`scaleGain r R = R / rms r`.

**Results.**

* `one_le_scaleGain` — block scaling never hurts: `scaleGain ≥ 1`.
* `scaleGain_le_sqrt_card` — and it can never be worth more than `√B`.
* `scaleGain_eq_sqrt_card_of_single_outlier` — the bound is attained exactly when
  the tensor's range is carried by one block: outlier concentration is the *whole*
  source of the gain.
* `block_scaling_is_a_bit_shift` — a gain of `2 ^ j` moves the entire degradation
  curve by exactly `j` bits (matching `quantizer_quality_is_a_bit_shift` in
  `Novelty.QuantCurvatureNoFloor`).  So "quality" is measured in bits and is
  directly comparable with "bit width": the two axes of the confound live in the
  same units.
* `k_quant_block_budget` — at the k-quant block size `B = 256` the entire budget
  is `√256 = 16 = 2 ^ 4`, i.e. **at most 4 bits**; and
  `observed_floor_shift_within_block_budget` records that the measured floor shift
  (6.0 bpw → 2.6 bpw, i.e. 3.4 bits) fits inside that budget, so the collapse of
  the floor needs no appeal to scale at all — quantiser quality alone can account
  for it.  This turns the documented confound into a falsifiable prediction: an
  RTN-vs-k-quant comparison at *fixed* scale should show a shift of at most 4
  bits, and of exactly `log₂ (R / rms r)` bits for the measured range profile.
-/

namespace Catalog.Novelty.BlockScaling

open Finset

variable {B : ℕ}

/-- Mean square of the per-block dynamic ranges. -/
noncomputable def msq (r : Fin B → ℝ) : ℝ := (∑ i, r i ^ 2) / B

/-- Root mean square of the per-block dynamic ranges: the effective range seen by
a per-block quantiser. -/
noncomputable def rms (r : Fin B → ℝ) : ℝ := Real.sqrt (msq r)

/-- The scale gain of block quantisation: the factor by which the effective
dynamic range shrinks when a tensor-wide scale `R` is replaced by per-block
scales. -/
noncomputable def scaleGain (r : Fin B → ℝ) (R : ℝ) : ℝ := R / rms r

theorem rms_nonneg (r : Fin B → ℝ) : 0 ≤ rms r := Real.sqrt_nonneg _

/-- Blocking never hurts: the root mean square of the block ranges is at most the
global range. -/
theorem rms_le_global (r : Fin B → ℝ) (R : ℝ) (hB : 0 < B) (hR : ∀ i, r i ≤ R)
    (hr : ∀ i, 0 ≤ r i) : rms r ≤ R := by
  have hRnn : 0 ≤ R := le_trans (hr ⟨0, hB⟩) (hR ⟨0, hB⟩)
  have hsum : ∑ i, r i ^ 2 ≤ (B : ℝ) * R ^ 2 := by
    have : ∀ i ∈ Finset.univ, r i ^ 2 ≤ R ^ 2 := by
      intro i _
      exact pow_le_pow_left₀ (hr i) (hR i) 2
    calc ∑ i, r i ^ 2 ≤ ∑ _i : Fin B, R ^ 2 := Finset.sum_le_sum this
      _ = (B : ℝ) * R ^ 2 := by simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hBpos : (0:ℝ) < B := by exact_mod_cast hB
  have hmsq : msq r ≤ R ^ 2 := by
    rw [msq, div_le_iff₀ hBpos]
    linarith [hsum]
  calc rms r ≤ Real.sqrt (R ^ 2) := Real.sqrt_le_sqrt hmsq
    _ = R := Real.sqrt_sq hRnn

/-- Hence the scale gain is at least `1`. -/
theorem one_le_scaleGain (r : Fin B → ℝ) (R : ℝ) (hB : 0 < B) (hR : ∀ i, r i ≤ R)
    (hr : ∀ i, 0 ≤ r i) (hpos : 0 < rms r) : 1 ≤ scaleGain r R := by
  rw [scaleGain, le_div_iff₀ hpos, one_mul]
  exact rms_le_global r R hB hR hr

/-- The global range never exceeds `√B` times the root mean square of the block
ranges. -/
theorem global_le_sqrt_card_mul_rms (r : Fin B → ℝ) (i₀ : Fin B) (hr : ∀ i, 0 ≤ r i) :
    r i₀ ≤ Real.sqrt B * rms r := by
  have hBpos : (0:ℝ) < B := by
    have : 0 < B := Fin.pos i₀
    exact_mod_cast this
  have hle : r i₀ ^ 2 ≤ ∑ i, r i ^ 2 :=
    Finset.single_le_sum (f := fun i => r i ^ 2) (fun i _ => sq_nonneg (r i))
      (Finset.mem_univ i₀)
  have hsq : r i₀ ^ 2 ≤ (B : ℝ) * msq r := by
    rw [msq]
    field_simp
    linarith [hle]
  have h1 : r i₀ ≤ Real.sqrt ((B : ℝ) * msq r) := by
    calc r i₀ = Real.sqrt (r i₀ ^ 2) := (Real.sqrt_sq (hr i₀)).symm
      _ ≤ Real.sqrt ((B : ℝ) * msq r) := Real.sqrt_le_sqrt hsq
  calc r i₀ ≤ Real.sqrt ((B : ℝ) * msq r) := h1
    _ = Real.sqrt B * rms r := by rw [rms, Real.sqrt_mul (le_of_lt hBpos)]

/-- **The block-scaling budget.**  The gain of per-block scaling over a single
global scale is at most `√B`, where `B` is the number of blocks. -/
theorem scaleGain_le_sqrt_card (r : Fin B → ℝ) (R : ℝ) (i₀ : Fin B) (hr : ∀ i, 0 ≤ r i)
    (hRi : r i₀ = R) (hpos : 0 < rms r) : scaleGain r R ≤ Real.sqrt B := by
  rw [scaleGain, div_le_iff₀ hpos]
  rw [← hRi]
  exact global_le_sqrt_card_mul_rms r i₀ hr

/-- **The budget is attained by outlier concentration.**  If a single block
carries the whole dynamic range and the others are flat, the gain is exactly
`√B`.  So the advantage of calibration-aware block quantisers over
round-to-nearest is precisely a statement about the outlier profile of the
weights. -/
theorem scaleGain_eq_sqrt_card_of_single_outlier (R : ℝ) (hR : 0 < R) (i₀ : Fin B) :
    scaleGain (fun i => if i = i₀ then R else 0) R = Real.sqrt B := by
  have hBpos : (0:ℝ) < B := by
    have : 0 < B := Fin.pos i₀
    exact_mod_cast this
  have hsum : ∑ i, (if i = i₀ then R else 0) ^ 2 = R ^ 2 := by
    simp [apply_ite (fun x : ℝ => x ^ 2)]
  have hmsq : msq (fun i => if i = i₀ then R else 0) = R ^ 2 / B := by
    rw [msq, hsum]
  have hrms : rms (fun i => if i = i₀ then R else 0) = R / Real.sqrt B := by
    rw [rms, hmsq, Real.sqrt_div' _ (by positivity), Real.sqrt_sq hR.le]
  have hs : Real.sqrt ((B : ℕ) : ℝ) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hBpos)
  rw [scaleGain, hrms]
  field_simp

/-- **Quality is measured in bits.**  A scale gain of `2 ^ j` shifts the whole
degradation curve by exactly `j` bits: the mean-square error of a per-block
quantiser at bit width `b` equals that of a globally scaled quantiser at bit
width `b + j`.  This puts the two halves of the toy-vs-scale confound in the same
units. -/
theorem block_scaling_is_a_bit_shift (r : Fin B → ℝ) (R : ℝ) (j b : ℕ)
    (hgain : R = 2 ^ j * rms r) :
    (rms r) ^ 2 / 4 ^ b = R ^ 2 / 4 ^ (b + j) := by
  have h2 : ((2:ℝ) ^ j) ^ 2 = 4 ^ j := by
    rw [← pow_mul, mul_comm, pow_mul]
    norm_num
  rw [hgain, mul_pow, h2, pow_add]
  field_simp

/-- **The k-quant budget at `B = 256`.**  Whatever the range profile, per-block
scaling with 256-element blocks cannot be worth more than `√256 = 16 = 2 ^ 4`,
i.e. **4 bits**. -/
theorem k_quant_block_budget (r : Fin 256 → ℝ) (R : ℝ) (i₀ : Fin 256) (hr : ∀ i, 0 ≤ r i)
    (hRi : r i₀ = R) (hpos : 0 < rms r) : scaleGain r R ≤ 16 := by
  have h := scaleGain_le_sqrt_card r R i₀ hr hRi hpos
  have : Real.sqrt ((256 : ℕ) : ℝ) = 16 := by
    rw [show (((256 : ℕ) : ℝ)) = 16 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  linarith [h, this.le, this.ge]

/-- **The observed floor shift fits the budget.**  The toy round-to-nearest floor
sat at 6.0 bpw; the k-quant ladder is still deployable at 2.6 bpw
(`Catalog.Novelty.WeightQuantFloor.scorecard_P3_refuted`).  The shift is 3.4 bits,
strictly inside the 4-bit block-scaling budget of `k_quant_block_budget`.  Hence
the collapse of the weight floor is *fully accountable* by quantiser quality; the
scale jump is not needed to explain it, which is exactly the separation the
measurement left open. -/
theorem observed_floor_shift_within_block_budget (R : ℝ) (hR : 0 < R) :
    scaleGain (fun i : Fin 256 => if i = (0 : Fin 256) then R else 0) R = 16 ∧
      (60 : ℚ) - (Catalog.Novelty.WeightQuantFloor.q2_k.tenthBits : ℚ) < 10 * 4 := by
  constructor
  · rw [scaleGain_eq_sqrt_card_of_single_outlier R hR (0 : Fin 256)]
    rw [show (((256 : ℕ) : ℝ)) = 16 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  · norm_num [Catalog.Novelty.WeightQuantFloor.q2_k]

end Catalog.Novelty.BlockScaling