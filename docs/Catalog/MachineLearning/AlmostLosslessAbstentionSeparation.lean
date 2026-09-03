/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XVI: Abstention is Necessary — a Separation

## Bridge: min-entropy counting (probability) ↔ decoder design (coding)
##         ↔ selective prediction / reject option (machine learning)

Every result of this thread rests on a decoder that may *abstain*: the
unique-match scan `decodeList` answers `none` whenever the received codeword has
zero or several codebook preimages.  Abstention is what makes silent corruption
a second-order event, `O(√δ·|l|/M)` for the balanced key of
`MachineLearning.AlmostLosslessBalancedSilent`.

This file proves that abstention is not a convenience but a *necessity*, by an
exact counting converse and a separation:

* `silentMass_add_abstainMass_ge` — the trade-off `silent + abstain ≥ 1 -
  |Code|·p_max`, valid for every scheme: below the min-entropy of the source a
  decoder can only suppress silent errors by abstaining;
* `silentMass_ge_of_never_abstains` — a decoder that always commits (never
  answers `none`) has silent-corruption probability at least
  `1 - |Code|·p_max`.  This holds for **every** encoder/decoder pair whatsoever,
  not just hash-based ones: it is the pigeonhole bound of
  `Bridges.AlmostLosslessCompression` read on the complement of the success set;
* `silentMass_ge_half_of_never_abstains` — in the interesting regime
  `|Code|·p_max ≤ 1/2` (fewer codewords than half the effective support), a
  committing decoder is wrong, silently, at least half of the time;
* `abstention_separation` — **the deliverable**: in that same regime, the
  √δ-balanced hash scheme with the *same* code size has silent-corruption
  probability `≤ ε` for any target `ε` reachable by `(√δ+δ)|l|/M`.  The gap
  between the two decoders is therefore `1/2 - ε`: an unbounded ratio,
  produced solely by the reject option.

## Impact: abstention_necessity, selective_prediction_separation
-/

import Mathlib
import MachineLearning.AlmostLosslessBalancedSilent

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section Abstention

variable {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α] {Code : Type*} [Fintype Code]

/-- A decoder that never abstains: every received codeword produces a committed
answer. -/
def Scheme.NeverAbstains (sch : Scheme α Code) : Prop :=
  ∀ x : α, sch.dec (sch.enc x) ≠ none

omit [Fintype α] [Nonempty α] [DecidableEq α] [Fintype Code] in
/-- Every source symbol is either decoded correctly or silently corrupted, once
the decoder is forbidden to abstain. -/
theorem succeeds_or_silentError_of_neverAbstains {sch : Scheme α Code}
    (h : sch.NeverAbstains) (x : α) : sch.Succeeds x ∨ sch.SilentError x := by
  rcases hx : sch.dec (sch.enc x) with _ | y
  · exact absurd hx (h x)
  · by_cases hy : y = x
    · exact Or.inl (show sch.dec (sch.enc x) = some x by rw [hx, hy])
    · exact Or.inr ⟨y, hx, hy⟩

/-- The probability that the decoder abstains. -/
noncomputable def abstainMass (μ : FinProbDist α) (sch : Scheme α Code) : ℝ :=
  setMass μ (Finset.univ.filter (fun x => sch.dec (sch.enc x) = none))

/-- **The abstention / silent-corruption trade-off.**  For *every* scheme, the
abstention probability and the silent-corruption probability together account
for all the mass that the code is too small to carry:

`silent + abstain ≥ 1 - |Code|·p_max`.

A decoder can push its silent-error rate down only by abstaining more; below
the min-entropy of the source, one of the two must be large.  The proof is the
pigeonhole bound of `successProb_le` applied to the trichotomy
*succeed / abstain / lie*. -/
theorem silentMass_add_abstainMass_ge (μ : FinProbDist α) (sch : Scheme α Code) :
    1 - (Fintype.card Code : ℝ) * maxMass μ
      ≤ setMass μ (Finset.univ.filter (fun x => sch.SilentError x))
          + abstainMass μ sch := by
  classical
  set S : Finset α := successSet sch with hS
  set T : Finset α := Finset.univ.filter (fun x => sch.SilentError x) with hT
  set N : Finset α := Finset.univ.filter (fun x => sch.dec (sch.enc x) = none) with hN
  have hcover : (Finset.univ : Finset α) ⊆ S ∪ (T ∪ N) := by
    intro x _
    rw [Finset.mem_union, Finset.mem_union]
    rcases hx : sch.dec (sch.enc x) with _ | y
    · exact Or.inr (Or.inr (by rw [hN, Finset.mem_filter]; exact ⟨Finset.mem_univ _, hx⟩))
    · by_cases hy : y = x
      · exact Or.inl (mem_successSet.mpr
          (show sch.dec (sch.enc x) = some x by rw [hx, hy]))
      · exact Or.inr (Or.inl (by
          rw [hT, Finset.mem_filter]; exact ⟨Finset.mem_univ _, ⟨y, hx, hy⟩⟩))
  have hone : (1 : ℝ) ≤ setMass μ S + (setMass μ T + setMass μ N) := by
    have h1 : setMass μ (Finset.univ : Finset α) ≤ setMass μ (S ∪ (T ∪ N)) :=
      setMass_mono μ hcover
    have h2 : setMass μ (S ∪ (T ∪ N)) ≤ setMass μ S + setMass μ (T ∪ N) :=
      setMass_union_le μ S (T ∪ N)
    have h3 : setMass μ (T ∪ N) ≤ setMass μ T + setMass μ N := setMass_union_le μ T N
    rw [setMass_univ] at h1
    linarith
  have hsucc : setMass μ S ≤ (Fintype.card Code : ℝ) * maxMass μ := successProb_le μ sch
  unfold abstainMass
  linarith

/-- **Committing decoders must lie.**  A scheme whose decoder never abstains
corrupts silently with probability at least `1 - |Code|·p_max`.

The bound is pure pigeonhole: correct decoding is injective on the success set,
so the success set carries at most `|Code|·p_max` of the mass, and *all* the
remaining mass is silent corruption because abstention is forbidden.  It applies
to arbitrary encoders and decoders — in particular no clever code design can
evade it. -/
theorem silentMass_ge_of_never_abstains (μ : FinProbDist α) (sch : Scheme α Code)
    (h : sch.NeverAbstains) :
    1 - (Fintype.card Code : ℝ) * maxMass μ
      ≤ setMass μ (Finset.univ.filter (fun x => sch.SilentError x)) := by
  classical
  have hzero : abstainMass μ sch = 0 := by
    have hempty : (Finset.univ.filter (fun x => sch.dec (sch.enc x) = none))
        = (∅ : Finset α) := by
      rw [Finset.eq_empty_iff_forall_notMem]
      intro x hx
      rw [Finset.mem_filter] at hx
      exact h x hx.2
    unfold abstainMass
    rw [hempty]
    simp [setMass]
  have := silentMass_add_abstainMass_ge μ sch
  rw [hzero, add_zero] at this
  exact this

/-- **Half the mass is silently corrupted.**  If the code has fewer than half
the "effective support" of the source (`|Code|·p_max ≤ 1/2` — exactly the
regime where compression is actually happening), then a committing decoder is
silently wrong with probability at least `1/2`. -/
theorem silentMass_ge_half_of_never_abstains (μ : FinProbDist α) (sch : Scheme α Code)
    (h : sch.NeverAbstains) (hsmall : (Fintype.card Code : ℝ) * maxMass μ ≤ 1 / 2) :
    (1 : ℝ) / 2 ≤ setMass μ (Finset.univ.filter (fun x => sch.SilentError x)) := by
  have := silentMass_ge_of_never_abstains μ sch h
  linarith

end Abstention

section Separation

variable {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α] {K M : ℕ}

/-- **Separation: the reject option is worth an unbounded factor.**

Fix a source with atypical mass `≤ δ`, a code size `M` small enough to be a
genuine compression (`M·p_max ≤ 1/2`), and a target silent-error level `ε`
reachable by the balanced bound (`(√δ+δ)·|l|/M ≤ ε`).  Then

* **(achievability, with abstention)** some key of the 2-universal family gives
  a scheme whose silent-corruption probability is at most `ε` — while still
  failing with probability at most `δ + (1+√δ)|l|/M` and costing exactly `|l|`
  hash evaluations;
* **(converse, without abstention)** *every* scheme over the same code space
  whose decoder always commits corrupts silently with probability at least
  `1/2`.

Silent corruption is therefore not an intrinsic cost of compressing below the
min-entropy: it is entirely an artefact of forcing the decoder to answer. -/
theorem abstention_separation (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M) (l : List α) (hnd : l.Nodup)
    (δ ε : ℝ) (hδpos : 0 < δ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ)
    (hsmall : (M : ℝ) * maxMass μ ≤ 1 / 2)
    (hε : (Real.sqrt δ + δ) * (l.length : ℝ) / M ≤ ε) :
    (∃ k : Fin K,
        setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x)) ≤ ε
        ∧ setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
            ≤ δ + (1 + Real.sqrt δ) * (l.length : ℝ) / M
        ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length)
    ∧ (∀ sch : Scheme α (Fin M), sch.NeverAbstains →
        (1 : ℝ) / 2 ≤ setMass μ (Finset.univ.filter (fun x => sch.SilentError x))) := by
  constructor
  · obtain ⟨k, hfail, hsilent, _, hcost⟩ :=
      exists_balanced_almost_lossless_scheme μ hU hK hM l hnd δ hδpos hδ
    exact ⟨k, le_trans hsilent hε, hfail, hcost⟩
  · intro sch hsch
    refine silentMass_ge_half_of_never_abstains μ sch hsch ?_
    rwa [Fintype.card_fin]

end Separation

end AlmostLossless