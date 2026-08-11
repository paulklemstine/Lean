import Applications.ZeroKnowledgeTheoremProving.EntropyAndBoundaries

/-!
# A Concrete Instance: the Affine Σ-Protocol over `ZMod 12`

The theorems of `AffineDuality`, `ProvabilityAmplification` and
`EntropyAndBoundaries` are stated for an arbitrary public homomorphism of
abelian groups. This file certifies that they are *not vacuous* by exhibiting a
fully computable instance and checking every hypothesis by decision procedure.

Take `G = H = ZMod 12` and the public homomorphism `x ↦ 4 * x`.

* `trueStatement` has target `8`, which lies in the image `{0, 4, 8}`.
  It has exactly four witnesses `{2, 5, 8, 11}`, matching the four kernel
  elements `{0, 3, 6, 9}` as predicted by `card_witnesses_eq_card_ker`.
* `falseStatement` has target `1`, which is not in the image, so it has no
  witness at all; `soundness_error_le` then bounds a committed prover's success
  over `n` rounds by `(1/2) ^ n` — for `n = 10` that is `1/1024`
  (`falseStatement_soundness_10`).
* Extraction really works on numbers (`example_extraction`), and the two
  distinct witnesses `2` and `5` generate literally the same transcript
  multiset (`example_witness_indistinguishable`), so the verifier cannot tell
  them apart even in this tiny group.
-/

namespace ZeroKnowledgeTheoremProving.AffineDuality.Examples

open ZeroKnowledgeTheoremProving.AffineDuality

/-- Multiplication by `4` on `ZMod 12`, as an additive homomorphism. -/
def mulFour : ZMod 12 →+ ZMod 12 :=
  AddMonoidHom.mk' (fun x => 4 * x) (by intro a b; ring)

/-- A true public statement: `4 * w = 8` is solvable. -/
def trueStatement : Statement (G := ZMod 12) (H := ZMod 12) :=
  ⟨mulFour, 8⟩

/-- A false public statement: `4 * w = 1` has no solution in `ZMod 12`. -/
def falseStatement : Statement (G := ZMod 12) (H := ZMod 12) :=
  ⟨mulFour, 1⟩

/-- `2` is a witness for the true statement. -/
theorem two_isWitness : IsWitness trueStatement 2 := by
  show mulFour 2 = 8
  decide

/-- So is `5`: the witness is far from unique. -/
theorem five_isWitness : IsWitness trueStatement 5 := by
  show mulFour 5 = 8
  decide

/-- The witness set of the true statement has exactly four elements. -/
theorem trueStatement_witness_count :
    ((Finset.univ : Finset (ZMod 12)).filter (fun w => (4 : ZMod 12) * w = 8)).card = 4 := by
  decide

/-- The kernel of the public homomorphism also has four elements, confirming
`card_witnesses_eq_card_ker` in this instance. -/
theorem mulFour_kernel_count :
    ((Finset.univ : Finset (ZMod 12)).filter (fun k => (4 : ZMod 12) * k = 0)).card = 4 := by
  decide

/-- The false statement has no witness: `4 * w = 1` is unsolvable mod `12`. -/
theorem falseStatement_no_witness : ∀ w : ZMod 12, ¬ IsWitness falseStatement w := by
  have key : ∀ w : ZMod 12, ¬ ((4 : ZMod 12) * w = 1) := by decide
  intro w hw
  exact key w hw

/-- **Concrete soundness.** Over ten parallel rounds, any prover committed in
advance answers at most a `1 / 1024` fraction of the challenge vectors for the
false statement. -/
theorem falseStatement_soundness_10 (P : ParallelProver (ZMod 12) (ZMod 12) 10) :
    ((cheatSet falseStatement 10 P).card : ℚ) /
        (Finset.univ : Finset (Fin 10 → Bool)).card ≤ 1 / 1024 := by
  have h := soundness_error_le falseStatement 10 falseStatement_no_witness P
  norm_num at h ⊢
  exact h

/-- **Concrete extraction.** From the two accepting responses `r` and `r + 2` at
the commitment `4 * r`, subtraction returns the witness `2`. -/
theorem example_extraction (r : ZMod 12) :
    IsWitness trueStatement (r + 2 - r) := by
  refine special_soundness trueStatement (mulFour r) r (r + 2) ?_ ?_
  · show mulFour r = mulFour r + challengeTerm false 8
    simp [challengeTerm]
  · show mulFour (r + 2) = mulFour r + challengeTerm true 8
    simp only [challengeTerm, if_true, map_add]
    rw [show mulFour 2 = (8 : ZMod 12) from by decide]

/-- **Concrete zero knowledge.** The two different witnesses `2` and `5`
generate exactly the same multiset of transcripts, for either challenge. -/
theorem example_witness_indistinguishable (c : Bool) :
    Finset.univ.val.map (realTranscript trueStatement 2 · c) =
      Finset.univ.val.map (realTranscript trueStatement 5 · c) :=
  witness_indistinguishable trueStatement two_isWitness five_isWitness c

/-- **Concrete view size.** For each challenge there are exactly `12` accepting
transcripts, matching `accepting_ncard_eq_card_group`. -/
theorem example_view_size (c : Bool) :
    {t : Transcript (ZMod 12) (ZMod 12) | t.challenge = c ∧ Accepts trueStatement t}.ncard
      = 12 := by
  rw [accepting_ncard_eq_card_group trueStatement c]
  simp

/-- The same count holds for the *false* statement: the size of the view carries
no information about whether the statement is true. -/
theorem example_view_size_false (c : Bool) :
    {t : Transcript (ZMod 12) (ZMod 12) | t.challenge = c ∧ Accepts falseStatement t}.ncard
      = 12 := by
  rw [accepting_ncard_eq_card_group falseStatement c]
  simp

end ZeroKnowledgeTheoremProving.AffineDuality.Examples