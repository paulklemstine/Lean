import Cryptography.TypeChannelMilestone.UnifiedLaw
import Cryptography.NonabelianTypeChannel.FieldCompleteness

/-!
# Paper 116 — field-by-field audit of the consolidated law

The general results of `UnifiedLaw.lean` are checked against the six fields of the law
table (`Cryptography.NonabelianTypeChannel.Fields`).

* `S3_channel_ne_coset_uncertainty` — **the critic's counterexample** to the literal
  milestone wording "`I = E[H(G^ab-class | T)]`": for `S₃` (`x³ + x + 1`) the channel is
  one bit while `H(coset | T) = 0`.
* `D4_sandwich_lower` — the sandwich lower bound `H(T) − log₂|G'|` is *non-vacuous*:
  for `D₄` (`x⁴ − 2`) it certifies `I ≥ 3/2 − (3/8)log₂3 > 3/4` bits from the type
  entropy and `|Z(D₄)| = 2` alone, without computing the joint law.
* `D4_conj_channel` — **universality in action**: relabelling the roots of `x⁴ − 2` by the
  transposition `(1 2)` moves `D₄` to a *different* subgroup of `S₄` (the stabiliser of
  the pairing `{{0,1},{2,3}}`), yet the channel is exactly `9/4 − (3/8)log₂3`.
* `S4_battery_saturated` — the `S₄` battery (type, root image) sits at exactly one bit:
  the type dial is already complete, so the second dial adds nothing.
-/

namespace TypeChannel

open Finset Real

set_option maxRecDepth 4000000

/-- In `S₃` the coset is determined by the type, so `H(coset | T) = 0`. -/
theorem S3_coset_uncertainty : condEntropy S3 signIdx splitType = 0 :=
  condEntropy_eq_zero_iff.mpr S3_type_determines_coset

/-- **Critic's counterexample.**  For `S₃` the channel (one bit) is not the conditional
coset entropy `H(G^ab-class | T)` (zero bits): the milestone's "exactly
`E[H(G^ab-class | T)]`" must be read as the *loss* `log₂[G:G'] − I`. -/
theorem S3_channel_ne_coset_uncertainty :
    mutualInfo S3 signIdx splitType ≠ condEntropy S3 signIdx splitType := by
  rw [S3_channel, S3_coset_uncertainty]
  norm_num

/-- **The sandwich lower bound is non-vacuous on `D₄`.** -/
theorem D4_sandwich_lower :
    3/2 - 3/8 * logb 2 3 ≤ mutualInfo D4 d4Idx splitType ∧
      (3:ℝ)/4 < 3/2 - 3/8 * logb 2 3 := by
  have hZ : Z4c.card = 2 := by decide
  have h := typeChannel_ge_entropy_sub_logb_derived D4_isSubgroup Z4c_isSubgroup
    (by decide) D4_coset splitType
  rw [D4_entropy_type, hZ] at h
  have h2 : logb 2 ((2:ℕ) : ℝ) = 1 := by simp
  rw [h2] at h
  refine ⟨by linarith, ?_⟩
  linarith [logb2_three_lt_two]

/-- The root relabelling `(1 2)` applied to `x⁴ − 2`. -/
def relabel12 : Equiv.Perm (Fin 4) := Equiv.swap 1 2

/-- `D₄` realised with the relabelled roots: a different subgroup of `S₄`. -/
def D4' : Finset (Equiv.Perm (Fin 4)) := D4.image (fun g => relabel12 * g * relabel12⁻¹)

/-- Its centre. -/
def Z4c' : Finset (Equiv.Perm (Fin 4)) := Z4c.image (fun g => relabel12 * g * relabel12⁻¹)

/-- The coset labels transported to the relabelled field. -/
def d4Idx' (g : Equiv.Perm (Fin 4)) : ℕ := d4Idx (relabel12⁻¹ * g * relabel12)

/-- The relabelled `D₄` is genuinely a different subgroup of `S₄`. -/
theorem D4'_ne_D4 : D4' ≠ D4 := by decide

lemma D4'_coset : IsCosetReadout D4' Z4c' d4Idx' := by
  unfold IsCosetReadout; decide

/-- **Universality in action.**  The relabelled `D₄` field has exactly the `D₄` channel. -/
theorem D4_conj_channel : mutualInfo D4' d4Idx' splitType = 9/4 - 3/8 * logb 2 3 := by
  rw [← D4_channel]
  exact typeChannel_conj_invariant relabel12 D4_isSubgroup (by decide) D4_coset D4'_coset

/-- **Battery saturation on `S₄`.**  The two-dial battery (splitting type, image of the
first root) carries exactly one bit, and the second dial is worth nothing given the
first. -/
theorem S4_battery_saturated :
    condMutualInfo S4 signIdx rootIdx splitType = 0 ∧
      mutualInfo S4 signIdx (pairObs splitType rootIdx) = 1 := by
  have h := battery_saturates S4_isSubgroup A4_isSubgroup (by decide) S4_coset
    S4_type_determines_coset rootIdx
  have himg : (S4.image signIdx).card = 2 := by decide
  rw [himg] at h
  refine ⟨h.1, ?_⟩
  rw [h.2]
  simp

end TypeChannel