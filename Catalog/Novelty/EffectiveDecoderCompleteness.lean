/-
# A complete quantity for effective decoding, and the four-way equivalence

In `Catalog/Novelty/EffectiveDecoderSelection.lean` the existence of a *total*
computable decoder was shown to follow from a uniform effective representative
selection on the range, and to fail in general; in
`Catalog/Novelty/EffectiveDecoderHierarchy.lean` effective selection was
identified with decidability of the range.  Both left open a converse: could a
channel decode *every* computable fibre-constant quantity without admitting a
selector?  For injective channels the answer was no, but the general case
required a quantity that is hard for the whole decoding problem.

This file constructs one.  The **canonical representative**
`leastRep obs n = the least m with obs m = obs n` is
computable whenever `obs` is (bounded search is unnecessary: the search always
succeeds at `n` itself, so unbounded search terminates), and it is fibre constant
by construction.  Moreover any decoder for it *is* a selector.  Hence
`leastRep obs` is **complete** for effective decoding on the channel `obs`, and we
obtain a four-way equivalence (`effective_decoding_tfae`):

1. the range of `obs` is a computable set;
2. `obs` admits a computable uniform representative selection on its range;
3. *every* computable fibre-constant quantity has a total computable decoder;
4. the single quantity `leastRep obs` has a total computable decoder.

The injectivity hypothesis of
`selector_iff_universal_decoding_of_injective` is thereby removed.  Applied to the
diagonal trace channel this exhibits a canonical hard instance: the canonical
representative of a self-halting index cannot be computed from the index
(`no_computable_decoder_leastRep_diag`), which is precisely the failure of
uniform effective representative selection isolated by the research question.
-/
import Novelty.EffectiveFanoBound

open Nat.Partrec Nat.Partrec.Code Denumerable

namespace EffectiveDecoder

variable {obs : ℕ → ℕ}

/-! ## 1. The canonical representative -/

/-- The **canonical representative** of the fibre of `n`: the least state
producing the same record as `n`. -/
noncomputable def leastRep (obs : ℕ → ℕ) (n : ℕ) : ℕ :=
  Nat.find (p := fun m => obs m = obs n) ⟨n, rfl⟩

/-- The canonical representative lies in the same fibre. -/
theorem leastRep_spec (obs : ℕ → ℕ) (n : ℕ) : obs (leastRep obs n) = obs n :=
  Nat.find_spec (p := fun m => obs m = obs n) ⟨n, rfl⟩

/-- The canonical representative is fibre constant: states with equal records get
the same representative. -/
theorem fibreConstant_leastRep (obs : ℕ → ℕ) : FibreConstant obs (leastRep obs) := by
  intro x y h
  refine le_antisymm (Nat.find_le ?_) (Nat.find_le ?_)
  · exact (leastRep_spec obs y).trans h.symm
  · exact (leastRep_spec obs x).trans h

/-- **The canonical representative is computable.**  Unbounded search for a
preimage of the received record always terminates when started from a state that
produces it, so the least preimage is computable, uniformly in the state. -/
theorem computable_leastRep (hobs : Computable obs) : Computable (leastRep obs) := by
  classical
  have he : Computable fun q : ℕ × ℕ => decide (q.1 = q.2) := (Primrec.eq (α := ℕ)).decide.to_comp
  have h1 : Computable fun x : ℕ × ℕ => decide (obs x.2 = obs x.1) :=
    he.comp (Computable.pair (hobs.comp Computable.snd) (hobs.comp Computable.fst) :
      Computable fun x : ℕ × ℕ => ((obs x.2, obs x.1) : ℕ × ℕ))
  have hr : Partrec fun n => Nat.rfind fun m => ((decide (obs m = obs n) : Bool) : Part Bool) :=
    Partrec.rfind (Computable₂.partrec₂ h1)
  refine Partrec.of_eq hr fun n => Part.eq_some_iff.2 (Nat.mem_rfind.2 ⟨?_, ?_⟩)
  · simp [leastRep, Nat.find_spec (p := fun m => obs m = obs n) ⟨n, rfl⟩]
  · intro m hm
    simp [Nat.find_min (p := fun m => obs m = obs n) ⟨n, rfl⟩ hm]

/-- **Any decoder for the canonical representative is a selector.**  This is what
makes `leastRep` complete for the decoding problem on a channel. -/
theorem selector_of_decodes_leastRep {dec : ℕ → ℕ} (hdec : Decodes obs (leastRep obs) dec) :
    Selector obs dec := by
  intro x
  rw [hdec x]
  exact leastRep_spec obs x

/-! ## 2. The four-way equivalence -/

/-- **Effective decoding, effective selection and range decidability coincide.**
For a computable channel the following are equivalent:

1. the set of emitted records is computable;
2. there is a computable uniform representative selection on the range;
3. every computable fibre-constant quantity admits a total computable decoder;
4. the canonical representative `leastRep obs` admits a total computable decoder.

The implication `3 → 2` (and hence `3 → 1`) is the converse left open by
`Catalog/Novelty/EffectiveDecoderSelection.lean`; it holds because the canonical
representative is a computable, fibre-constant quantity whose decoders are
exactly the selectors. -/
theorem effective_decoding_tfae (hobs : Computable obs) :
    [ComputablePred fun y => ∃ n, obs n = y,
      ∃ sel : ℕ → ℕ, Computable sel ∧ Selector obs sel,
      ∀ g : ℕ → ℕ, Computable g → FibreConstant obs g →
        ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obs g dec,
      ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obs (leastRep obs) dec].TFAE := by
  tfae_have 1 → 2 := fun hr => exists_computable_selector_of_computable_range hobs hr
  tfae_have 2 → 3 := by
    rintro ⟨sel, hselc, hsel⟩ g hgc hgfc
    exact computable_decoder_of_selector hsel hselc hgc hgfc
  tfae_have 3 → 4 := fun H =>
    H (leastRep obs) (computable_leastRep hobs) (fibreConstant_leastRep obs)
  tfae_have 4 → 2 := by
    rintro ⟨dec, hdecc, hdec⟩
    exact ⟨dec, hdecc, selector_of_decodes_leastRep hdec⟩
  tfae_have 2 → 1 := by
    rintro ⟨sel, hselc, hsel⟩
    exact computableRange_of_computable_selector hobs hselc hsel
  tfae_finish

/-! ## 3. A canonical hard instance -/

/-- **The canonical representative of the diagonal trace channel is undecodable.**
No algorithm, given the index of a machine known to halt on itself, can produce a
trace witnessing that halting: the least such trace is a computable,
fibre-constant quantity of the channel with no computable decoder. -/
theorem no_computable_decoder_leastRep_diag :
    ¬ ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obsDiag (leastRep obsDiag) dec := by
  rintro ⟨dec, hdecc, hdec⟩
  exact no_computable_selector_diag ⟨dec, hdecc, selector_of_decodes_leastRep hdec⟩

/-- The hard instance is also quantitatively hard: every computable attempt to
compute the canonical representative from the record is wrong on infinitely many
states. -/
theorem leastRep_diag_errors_infinite {dec : ℕ → ℕ} (hdec : Computable dec) :
    {n | dec (obsDiag n) ≠ leastRep obsDiag n}.Infinite :=
  error_set_infinite_of_no_computable_decoder hdec (fibreConstant_leastRep obsDiag)
    no_computable_decoder_leastRep_diag

end EffectiveDecoder