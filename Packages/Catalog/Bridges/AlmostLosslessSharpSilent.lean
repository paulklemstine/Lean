/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression VII: Silent Corruption is Rarer than Failure

## Bridge: Universal hashing (algebra) ↔ two-sided Markov counting (probability)

`exists_almost_lossless_scheme` produces a key whose *failure* probability is at
most `δ + |S|/M` and whose *silent corruption* probability is at most `|S|/M`.
That silent bound is wasteful: a silent error requires a symbol to be **outside**
the codebook (inside the codebook the decoder provably abstains rather than
lying) *and* to collide with the codebook.  The first event has probability at
most `δ`, so the first moment of the silent-error mass carries an extra factor
`δ`.

This file proves that the two guarantees can be obtained **simultaneously for a
single key**:

* `card_badMass_lt` — a Markov/counting bound: fewer than half of the keys are
  twice as bad as the average, for any region `A`;
* `exists_doubly_good_key` — a key that is good for the region `Sᶜ` *and* for
  the whole space at once (both bad sets have size `< K/2`, so they cannot
  cover the key space);
* `exists_sharp_almost_lossless_scheme` — **the deliverable**: a single explicit
  key with failure probability `≤ δ + 2|S|/M`, silent-corruption probability
  `≤ 2δ|S|/M` (a factor `δ` better), and decoding cost still exactly `|S|`.

This settles Conjecture 2 of the previous cycle's `FUTURE_DIRECTIONS.md`.

## Impact: sharp_silent_error_bound, two_sided_derandomization
-/

import Mathlib
import Bridges.AlmostLosslessRandomCoding

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section SharpSilent

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- The keys that are more than twice as bad as the average on the region `A`. -/
noncomputable def badMassKeys (μ : FinProbDist α) (H : Fin K → α → Fin M) (S A : Finset α) :
    Finset (Fin K) :=
  Finset.univ.filter (fun k =>
    2 * ((S.card : ℝ) * setMass μ A)
      < (M : ℝ) * setMass μ (A.filter (fun x => Collides H k S x)))

/-- **Markov counting bound.**  Strictly fewer than half of the keys make the
collision mass inside `A` exceed twice its average value `|S|·μ(A)/M`.  The
degenerate case (average `0`) is covered as well: then *no* key is bad, because
all the summands of a vanishing sum of non-negative terms vanish. -/
theorem card_badMass_lt (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (S A : Finset α) :
    ((badMassKeys μ H S A).card : ℝ) * 2 < K := by
  classical
  set f : Fin K → ℝ :=
    fun k => (M : ℝ) * setMass μ (A.filter (fun x => Collides H k S x)) with hf
  have hfnonneg : ∀ k, 0 ≤ f k := fun k =>
    mul_nonneg (Nat.cast_nonneg M) (setMass_nonneg _ _)
  set c : ℝ := (S.card : ℝ) * setMass μ A with hc
  have hcnonneg : 0 ≤ c := mul_nonneg (Nat.cast_nonneg _) (setMass_nonneg _ _)
  have hsum : ∑ k : Fin K, f k ≤ (K : ℝ) * c := by
    have := sum_collision_mass_le μ hU S A
    rw [hf, ← Finset.mul_sum]
    rw [hc]
    calc (M : ℝ) * ∑ k : Fin K, setMass μ (A.filter (fun x => Collides H k S x))
        ≤ (K : ℝ) * S.card * setMass μ A := this
      _ = (K : ℝ) * ((S.card : ℝ) * setMass μ A) := by ring
  have hKR : (0 : ℝ) < K := by exact_mod_cast hK
  rcases eq_or_lt_of_le hcnonneg with hc0 | hcpos
  · -- average zero: no bad keys at all
    have hempty : badMassKeys μ H S A = ∅ := by
      rw [Finset.eq_empty_iff_forall_notMem]
      intro k hk
      simp only [badMassKeys, Finset.mem_filter, Finset.mem_univ, true_and] at hk
      have hle : f k ≤ ∑ j : Fin K, f j :=
        Finset.single_le_sum (fun j _ => hfnonneg j) (Finset.mem_univ k)
      have hKc : (K : ℝ) * c = 0 := by rw [← hc0]; ring
      have hfk : f k ≤ 0 := by linarith [hle, hsum, hKc]
      have hck : 2 * c < f k := by rw [hc, hf]; exact hk
      linarith
    rw [hempty]
    simpa using hKR
  · -- genuine Markov argument
    set B := badMassKeys μ H S A with hB
    rcases Finset.eq_empty_or_nonempty B with hBe | hBne
    · rw [hBe]; simpa using hKR
    · have hlow : ∑ k ∈ B, (2 * c) < ∑ k ∈ B, f k := by
        refine Finset.sum_lt_sum_of_nonempty hBne ?_
        intro k hk
        rw [hB, badMassKeys, Finset.mem_filter] at hk
        exact hk.2
      have hsub : ∑ k ∈ B, f k ≤ ∑ k : Fin K, f k :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B)
          (fun j _ _ => hfnonneg j)
      have hconst : ∑ _k ∈ B, (2 * c) = (B.card : ℝ) * (2 * c) := by
        simp [Finset.sum_const, nsmul_eq_mul]
      have : (B.card : ℝ) * (2 * c) < (K : ℝ) * c := by
        rw [← hconst]; linarith
      nlinarith [this, hcpos]

/-- **Two-sided derandomization.**  There is a single key that is simultaneously
good on the complement of the codebook (the only region where a silent error can
occur) and on the whole space: the two bad-key sets each have size `< K/2`, so
together they cannot exhaust the key space. -/
theorem exists_doubly_good_key (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (S : Finset α) :
    ∃ k : Fin K,
      (M : ℝ) * setMass μ ((Sᶜ).filter (fun x => Collides H k S x))
          ≤ 2 * (S.card : ℝ) * setMass μ Sᶜ
      ∧ (M : ℝ) * setMass μ (Finset.univ.filter (fun x => Collides H k S x))
          ≤ 2 * (S.card : ℝ) := by
  classical
  have h1 := card_badMass_lt μ hU hK S Sᶜ
  have h2 := card_badMass_lt μ hU hK S Finset.univ
  set B1 := badMassKeys μ H S Sᶜ with hB1
  set B2 := badMassKeys μ H S Finset.univ with hB2
  have hcards : ((B1 ∪ B2).card : ℝ) < K := by
    have hle : ((B1 ∪ B2).card : ℝ) ≤ (B1.card : ℝ) + (B2.card : ℝ) := by
      exact_mod_cast Finset.card_union_le B1 B2
    linarith
  have hne : ∃ k : Fin K, k ∉ B1 ∪ B2 := by
    by_contra hcon
    push_neg at hcon
    have hsubset : (Finset.univ : Finset (Fin K)) ⊆ B1 ∪ B2 := fun k _ => hcon k
    have : (K : ℝ) ≤ ((B1 ∪ B2).card : ℝ) := by
      have := Finset.card_le_card hsubset
      rw [Finset.card_univ, Fintype.card_fin] at this
      exact_mod_cast this
    linarith
  obtain ⟨k, hk⟩ := hne
  rw [Finset.mem_union] at hk
  push_neg at hk
  obtain ⟨hk1, hk2⟩ := hk
  simp only [hB1, badMassKeys, Finset.mem_filter, Finset.mem_univ, true_and,
    not_lt] at hk1
  simp only [hB2, badMassKeys, Finset.mem_filter, Finset.mem_univ, true_and,
    not_lt] at hk2
  refine ⟨k, by linarith [hk1], ?_⟩
  rw [setMass_univ, mul_one] at hk2
  linarith [hk2]

/-- **Sharp almost-lossless scheme (settles Conjecture 2).**

One explicit key gives, simultaneously:

1. failure probability `≤ δ + 2|l|/M`;
2. **silent** corruption probability `≤ 2δ·|l|/M` — a factor `δ` better than the
   failure bound, because a silent error needs both an atypical symbol and a
   collision;
3. decoding cost exactly `|l|` hash evaluations.

Together with `hashScheme_neverSilent_on_codebook` (no silent error is ever
possible on a codebook symbol) this makes silent corruption a second-order
event: it is quadratically small in the accuracy parameters. -/
theorem exists_sharp_almost_lossless_scheme (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + 2 * (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
          ≤ 2 * δ * (l.length : ℝ) / M
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  obtain ⟨k, hsilent, hall⟩ := exists_doubly_good_key μ hU hK l.toFinset
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hcard : (l.toFinset.card : ℝ) = (l.length : ℝ) := by
    rw [List.toFinset_card_of_nodup hnd]
  refine ⟨k, ?_, ?_, fun i => scanCost_snd _ _ _⟩
  · -- failure ⊆ atypical ∪ collisions
    set C : Finset α := Finset.univ.filter (fun x => Collides H k l.toFinset x) with hC
    have hCbound : setMass μ C ≤ 2 * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR, hcard] at *
      nlinarith [hall, hcard]
    have hsub : Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x)
        ⊆ (l.toFinset)ᶜ ∪ C := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      rw [Finset.mem_union]
      by_cases hxl : x ∈ l.toFinset
      · right
        rw [hC, Finset.mem_filter]
        refine ⟨Finset.mem_univ _, ?_⟩
        rw [collides_iff]
        by_contra hnc
        exact hx (hashScheme_succeeds hnd (List.mem_toFinset.mp hxl) hnc)
      · left; exact Finset.mem_compl.mpr hxl
    calc setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
        ≤ setMass μ ((l.toFinset)ᶜ ∪ C) := setMass_mono μ hsub
      _ ≤ setMass μ (l.toFinset)ᶜ + setMass μ C := setMass_union_le μ _ _
      _ ≤ δ + 2 * (l.length : ℝ) / M := add_le_add hδ hCbound
  · -- silent errors live outside the codebook *and* need a collision
    set D : Finset α := (l.toFinset)ᶜ.filter (fun x => Collides H k l.toFinset x)
      with hD
    have hsub : Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x) ⊆ D := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      rw [hD, Finset.mem_filter]
      refine ⟨Finset.mem_compl.mpr ?_, collides_iff.mpr (silentError_imp_collides hx)⟩
      intro hxl
      exact hashScheme_neverSilent_on_codebook (List.mem_toFinset.mp hxl) hx
    have hmass : setMass μ (l.toFinset)ᶜ ≤ δ := hδ
    have hcardnn : (0 : ℝ) ≤ (l.length : ℝ) := Nat.cast_nonneg _
    have hDb : (M : ℝ) * setMass μ D ≤ 2 * (l.length : ℝ) * δ := by
      have h1 : (M : ℝ) * setMass μ D ≤ 2 * (l.toFinset.card : ℝ) * setMass μ (l.toFinset)ᶜ :=
        hsilent
      have h2 : 2 * (l.toFinset.card : ℝ) * setMass μ (l.toFinset)ᶜ
          ≤ 2 * (l.length : ℝ) * δ := by
        rw [hcard]
        nlinarith [hmass, hcardnn]
      linarith
    have : setMass μ D ≤ 2 * δ * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR]
      nlinarith [hDb]
    exact le_trans (setMass_mono μ hsub) this

end SharpSilent

end AlmostLossless