import Physics.S3TypeChannelUniversal

/-!
# The one-bit law is a property of the *sign* readout, not of binary readouts

Adversarial companion to `Physics.S3TypeChannelUniversal`.  The universal law
`I(residue ; splitting type) = 1` could look like an artefact of "binary observable meets
three-letter alphabet".  It is not.  Here we compute, in closed form, two neighbouring
quantities for the very same Chebotarev model of an `S₃`-cubic:

* the **splitting-type entropy** `H(T) = 2/3 + (log₂ 3)/2 ≈ 1.4591` bits — strictly more
  than one bit, so the residue channel is *strictly lossy* about `T`;
* the **root-count channel** `I(residue ; "does f have a root mod p?")`
  `= (log₂ 3)/2 - 1/3 ≈ 0.4591` bits — strictly between `0` and `1`, and irrational-looking:
  the exact one-bit value is destroyed as soon as the binary readout is not the sign
  character.

Main results.

* `S3Lossy.HT_eq` : `H(T) = 2/3 + (log₂ 3)/2`.
* `S3Lossy.one_lt_HT` : `1 < H(T)` — the sign character is *not* all of the type.
* `S3Lossy.Imut_rootTable_eq` : `I(residue ; root-count) = (log₂ 3)/2 - 1/3` exactly.
* `S3Lossy.Imut_rootTable_lt_one`, `S3Lossy.Imut_rootTable_pos` : it is strictly inside
  `(0,1)`; in particular the one-bit law of `S3Universal` is sharp and non-vacuous.
-/

namespace S3Lossy

open scoped BigOperators
open Finset S3Channel S3Universal S3Universal.SplitType

/-! ## Surprisal values for the six-element Chebotarev model -/

lemma sur_one_half : sur (1 / 2 : ℝ) = 1 / 2 := by
  have h : Real.logb 2 (1 / 2 : ℝ) = -1 := by
    rw [one_div, Real.logb_inv]; simp
  rw [sur, h]; ring

lemma sur_one_third : sur (1 / 3 : ℝ) = Real.logb 2 3 / 3 := by
  have h : Real.logb 2 (1 / 3 : ℝ) = -Real.logb 2 3 := by
    rw [one_div, Real.logb_inv]
  rw [sur, h]; ring

lemma sur_one_sixth : sur (1 / 6 : ℝ) = (1 + Real.logb 2 3) / 6 := by
  have h : Real.logb 2 (1 / 6 : ℝ) = -(1 + Real.logb 2 3) := by
    rw [show (1 : ℝ) / 6 = 1 / (2 * 3) by norm_num, one_div, Real.logb_inv,
      Real.logb_mul (by norm_num) (by norm_num)]
    simp
  rw [sur, h]; ring

lemma sur_two_thirds : sur (2 / 3 : ℝ) = (2 / 3) * (Real.logb 2 3 - 1) := by
  have h : Real.logb 2 (2 / 3 : ℝ) = 1 - Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num)]; simp
  rw [sur, h]; ring

lemma one_lt_logb_two_three : (1 : ℝ) < Real.logb 2 3 := by
  have h : Real.logb 2 2 < Real.logb 2 3 :=
    Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)
  simpa using h

lemma logb_two_three_lt_two : Real.logb 2 3 < 2 := by
  have h : Real.logb 2 3 < Real.logb 2 4 :=
    Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)
  have h4 : Real.logb 2 (4 : ℝ) = 2 := by
    rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow]; simp
  linarith [h4 ▸ h]

/-- Sums over the three splitting types. -/
lemma sum_splitType (f : SplitType → ℝ) :
    ∑ t, f t = f totallySplit + f partiallySplit + f inert := by
  have h : (univ : Finset SplitType) = {totallySplit, partiallySplit, inert} := by decide
  rw [h]
  simp [Finset.sum_insert, Finset.mem_insert]
  ring

/-! ## The splitting-type entropy exceeds one bit -/

lemma total_residueTable_chi3 : total (residueTable chi3) = 6 := by
  have h := total_character (n := residueTable chi3) (chi := chi3) (g := signBit)
    (m := typeMult) (k := 1) (M2 := 3) (fun _ _ => rfl) chi3_balanced signBit_mass_balance
  simpa using h

lemma margB_residueTable_chi3 (t : SplitType) : margB (residueTable chi3) t = typeMult t := by
  have h := margB_character (n := residueTable chi3) (chi := chi3) (g := signBit)
    (m := typeMult) (k := 1) (fun _ _ => rfl) chi3_balanced t
  simpa using h

/-- **The Chebotarev entropy of the splitting type of an `S₃`-cubic.**
`H(T) = -(1/6)log₂(1/6) - (1/2)log₂(1/2) - (1/3)log₂(1/3) = 2/3 + (log₂ 3)/2`. -/
theorem HT_eq : HB (residueTable chi3) = 2 / 3 + Real.logb 2 3 / 2 := by
  obtain ⟨h1, h3, h2⟩ := typeMult_values
  have hval : ∀ t : SplitType,
      sur (((margB (residueTable chi3) t : ℕ) : ℝ) / ((total (residueTable chi3) : ℕ) : ℝ))
        = sur (((typeMult t : ℕ) : ℝ) / 6) := by
    intro t; rw [margB_residueTable_chi3 t, total_residueTable_chi3]; norm_num
  have : HB (residueTable chi3) = ∑ t : SplitType, sur (((typeMult t : ℕ) : ℝ) / 6) :=
    Finset.sum_congr rfl (fun t _ => hval t)
  rw [this, sum_splitType, h1, h2, h3]
  norm_num
  rw [sur_one_sixth, sur_one_half, sur_one_third]
  ring

/-- The splitting type carries strictly more than the one bit that the residue class can
see: the residue → type channel is exact on the sign character but strictly lossy on `T`. -/
theorem one_lt_HT : 1 < HB (residueTable chi3) := by
  rw [HT_eq]; linarith [one_lt_logb_two_three]

/-- Quantitative form: the residue class misses `H(T) - 1 = (log₂ 3)/2 - 1/3 > 0` bits of
the splitting type. -/
theorem HT_sub_Imut_eq :
    HB (residueTable chi3) - Imut (residueTable chi3) = Real.logb 2 3 / 2 - 1 / 3 := by
  rw [HT_eq, Ires_xcubed_sub_three]; ring

/-! ## The root-count readout: the same alphabet size, a different answer -/

/-- Does the cubic have a root mod `p`?  Yes for the split and `1+2` types, no for inert. -/
def hasRootBit : SplitType → Bool
  | totallySplit => true
  | partiallySplit => true
  | inert => false

/-- The Chebotarev joint table of (sign bit of the residue, root-count bit). -/
def rootTable : Bool → Bool → ℕ := fun s r =>
  ((univ : Finset (Equiv.Perm (Fin 3))).filter
    (fun σ => decide (Equiv.Perm.sign σ = 1) = s ∧ hasRootBit (frobType σ) = r)).card

/-- The four Chebotarev occupation numbers of the root-count table. -/
theorem rootTable_values :
    rootTable true true = 1 ∧ rootTable true false = 2 ∧
      rootTable false true = 3 ∧ rootTable false false = 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide

theorem rootTable_total : total rootTable = 6 := by decide

theorem rootTable_margA (s : Bool) : margA rootTable s = 3 := by revert s; decide

theorem rootTable_margB_true : margB rootTable true = 4 := by decide

theorem rootTable_margB_false : margB rootTable false = 2 := by decide

/-- The residue side is still a balanced bit. -/
theorem HA_rootTable : HA rootTable = 1 :=
  HA_eq_one_of_balanced_two rootTable Fintype.card_bool
    (fun s => by rw [rootTable_margA s, rootTable_total]; norm_num)

theorem HB_rootTable : HB rootTable = (2 / 3) * (Real.logb 2 3 - 1) + Real.logb 2 3 / 3 := by
  have h : HB rootTable = sur (2 / 3 : ℝ) + sur (1 / 3 : ℝ) := by
    rw [HB]
    rw [Fintype.sum_bool]
    rw [rootTable_margB_true, rootTable_margB_false, rootTable_total]
    norm_num
  rw [h, sur_two_thirds, sur_one_third]

theorem Hjoint_rootTable :
    Hjoint rootTable = (1 + Real.logb 2 3) / 6 + Real.logb 2 3 / 3 + 1 / 2 := by
  obtain ⟨h11, h10, h01, h00⟩ := rootTable_values
  have h : Hjoint rootTable
      = sur (1 / 6 : ℝ) + sur (1 / 3 : ℝ) + (sur (1 / 2 : ℝ) + sur (0 : ℝ)) := by
    rw [Hjoint]
    rw [Fintype.sum_bool]
    rw [Fintype.sum_bool, Fintype.sum_bool]
    rw [h11, h10, h01, h00, rootTable_total]
    norm_num
  rw [h, sur_one_sixth, sur_one_third, sur_one_half, sur_zero]
  ring

/-- **The root-count channel is not one bit.**  For the same `S₃` Chebotarev model, the
binary readout "does `f` have a root mod `p`?" shares exactly
`(log₂ 3)/2 - 1/3 ≈ 0.45915` bits with the residue class. -/
theorem Imut_rootTable_eq : Imut rootTable = Real.logb 2 3 / 2 - 1 / 3 := by
  rw [Imut, HA_rootTable, HB_rootTable, Hjoint_rootTable]; ring

/-- The root-count channel is strictly below the sign-character channel. -/
theorem Imut_rootTable_lt_one : Imut rootTable < 1 := by
  rw [Imut_rootTable_eq]; linarith [logb_two_three_lt_two]

/-- ... but it is not empty either. -/
theorem Imut_rootTable_pos : 0 < Imut rootTable := by
  rw [Imut_rootTable_eq]; linarith [one_lt_logb_two_three]

/-- **Sharpness of the universal law.**  Two binary readouts of the same `S₃` splitting
type give different channel values: the sign character gives exactly `1`, the root count
gives strictly less.  The one-bit law therefore detects the sign character specifically. -/
theorem sign_readout_strictly_beats_root_readout :
    Imut rootTable < Imut (residueTable chi3) := by
  rw [Ires_xcubed_sub_three]; exact Imut_rootTable_lt_one

end S3Lossy