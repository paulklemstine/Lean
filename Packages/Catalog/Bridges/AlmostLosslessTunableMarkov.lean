/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XII: Tunable Markov Thresholds

## Bridge: universal hashing (algebra) ↔ a one-parameter Markov trade-off (probability)

`AlmostLosslessSharpSilent` derandomizes a 2-universal family by thresholding the
collision mass at **twice** its average on two regions at once, which costs a
factor `2` in *both* the failure bound and the silent-corruption bound.  The
threshold `2` is an artefact of splitting the key space evenly: any pair of
thresholds `c₁, c₂ > 0` with `1/c₁ + 1/c₂ ≤ 1` leaves a key outside both bad
sets.

This file proves the one-parameter version, settling Conjecture C /
sub-conjecture C1 of the previous cycle's `FUTURE_DIRECTIONS.md`:

* `card_badMassC_lt` — for **any** threshold `c`, strictly fewer than `K/c`
  keys exceed `c` times the average collision mass on a region `A`;
* `exists_tunable_good_key` — a single key good at threshold `c₁` on the
  codebook complement and at threshold `c₂` on the whole space, whenever
  `1/c₁ + 1/c₂ ≤ 1`;
* `exists_tunable_almost_lossless_scheme` — **the deliverable**: for every
  `η > 0` a key with silent-corruption probability `≤ (1+η)·δ·|l|/M` and failure
  probability `≤ δ + (1+1/η)·|l|/M`, cost still exactly `|l|`.  Taking `η → 0`
  drives the silent constant to `1`, the first-moment optimum; `η = 1` recovers
  `exists_sharp_almost_lossless_scheme`.

## Impact: tunable_silent_error_constant, one_parameter_derandomization
-/

import Mathlib
import Bridges.AlmostLosslessSharpSilent

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section TunableMarkov

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- The keys whose collision mass on the region `A` exceeds `c` times its
average value `|S|·μ(A)/M`. -/
noncomputable def badMassKeysC (μ : FinProbDist α) (H : Fin K → α → Fin M)
    (S A : Finset α) (c : ℝ) : Finset (Fin K) :=
  Finset.univ.filter (fun k =>
    c * ((S.card : ℝ) * setMass μ A)
      < (M : ℝ) * setMass μ (A.filter (fun x => Collides H k S x)))

/-- **Markov counting bound at an arbitrary threshold.**  Strictly fewer than
`K/c` keys make the collision mass inside `A` exceed `c` times its average.
For `c = 2` this is `card_badMass_lt`. -/
theorem card_badMassC_lt (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (c : ℝ) (S A : Finset α) :
    ((badMassKeysC μ H S A c).card : ℝ) * c < K := by
  classical
  set f : Fin K → ℝ :=
    fun k => (M : ℝ) * setMass μ (A.filter (fun x => Collides H k S x)) with hf
  have hfnonneg : ∀ k, 0 ≤ f k := fun k =>
    mul_nonneg (Nat.cast_nonneg M) (setMass_nonneg _ _)
  set a : ℝ := (S.card : ℝ) * setMass μ A with ha
  have hanonneg : 0 ≤ a := mul_nonneg (Nat.cast_nonneg _) (setMass_nonneg _ _)
  have hsum : ∑ k : Fin K, f k ≤ (K : ℝ) * a := by
    have hbase := sum_collision_mass_le μ hU S A
    rw [hf, ← Finset.mul_sum, ha]
    calc (M : ℝ) * ∑ k : Fin K, setMass μ (A.filter (fun x => Collides H k S x))
        ≤ (K : ℝ) * S.card * setMass μ A := hbase
      _ = (K : ℝ) * ((S.card : ℝ) * setMass μ A) := by ring
  have hKR : (0 : ℝ) < K := by exact_mod_cast hK
  rcases eq_or_lt_of_le hanonneg with ha0 | hapos
  · -- average zero: no key can be bad at all
    have hempty : badMassKeysC μ H S A c = ∅ := by
      rw [Finset.eq_empty_iff_forall_notMem]
      intro k hk
      simp only [badMassKeysC, Finset.mem_filter, Finset.mem_univ, true_and] at hk
      have hle : f k ≤ ∑ j : Fin K, f j :=
        Finset.single_le_sum (fun j _ => hfnonneg j) (Finset.mem_univ k)
      have hKa : (K : ℝ) * a = 0 := by rw [← ha0]; ring
      have hfk : f k ≤ 0 := by linarith
      have hck : c * a < f k := by rw [ha, hf]; exact hk
      have : c * a = 0 := by rw [← ha0]; ring
      linarith
    rw [hempty]
    simpa using hKR
  · set B := badMassKeysC μ H S A c with hB
    rcases Finset.eq_empty_or_nonempty B with hBe | hBne
    · rw [hBe]; simpa using hKR
    · have hlow : ∑ _k ∈ B, (c * a) < ∑ k ∈ B, f k := by
        refine Finset.sum_lt_sum_of_nonempty hBne ?_
        intro k hk
        rw [hB, badMassKeysC, Finset.mem_filter] at hk
        exact hk.2
      have hsub : ∑ k ∈ B, f k ≤ ∑ k : Fin K, f k :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B)
          (fun j _ _ => hfnonneg j)
      have hconst : ∑ _k ∈ B, (c * a) = (B.card : ℝ) * (c * a) := by
        simp [Finset.sum_const, nsmul_eq_mul]
      have hkey : (B.card : ℝ) * (c * a) < (K : ℝ) * a := by
        rw [← hconst]; linarith
      nlinarith [hkey, hapos]

/-- **Two-sided derandomization with tunable thresholds.**  If
`1/c₁ + 1/c₂ ≤ 1`, the two bad-key sets cannot cover the key space, so some key
is simultaneously `c₁`-good on `Sᶜ` and `c₂`-good on the whole space. -/
theorem exists_tunable_good_key (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (S : Finset α) {c₁ c₂ : ℝ}
    (hc₁ : 0 < c₁) (hc₂ : 0 < c₂) (hsum : 1 / c₁ + 1 / c₂ ≤ 1) :
    ∃ k : Fin K,
      (M : ℝ) * setMass μ ((Sᶜ).filter (fun x => Collides H k S x))
          ≤ c₁ * (S.card : ℝ) * setMass μ Sᶜ
      ∧ (M : ℝ) * setMass μ (Finset.univ.filter (fun x => Collides H k S x))
          ≤ c₂ * (S.card : ℝ) := by
  classical
  have h1 := card_badMassC_lt μ hU hK c₁ S Sᶜ
  have h2 := card_badMassC_lt μ hU hK c₂ S Finset.univ
  set B₁ := badMassKeysC μ H S Sᶜ c₁ with hB₁
  set B₂ := badMassKeysC μ H S Finset.univ c₂ with hB₂
  have hKR : (0 : ℝ) < K := by exact_mod_cast hK
  -- turn the two threshold bounds into fractions of `K`
  have e1 : (B₁.card : ℝ) < (K : ℝ) / c₁ := by
    rw [lt_div_iff₀ hc₁]; exact h1
  have e2 : (B₂.card : ℝ) < (K : ℝ) / c₂ := by
    rw [lt_div_iff₀ hc₂]; exact h2
  have hfrac : (K : ℝ) / c₁ + (K : ℝ) / c₂ ≤ (K : ℝ) := by
    have : (K : ℝ) * (1 / c₁ + 1 / c₂) ≤ (K : ℝ) * 1 :=
      mul_le_mul_of_nonneg_left hsum (le_of_lt hKR)
    calc (K : ℝ) / c₁ + (K : ℝ) / c₂ = (K : ℝ) * (1 / c₁ + 1 / c₂) := by ring
      _ ≤ (K : ℝ) * 1 := this
      _ = (K : ℝ) := by ring
  have hcards : ((B₁ ∪ B₂).card : ℝ) < K := by
    have hle : ((B₁ ∪ B₂).card : ℝ) ≤ (B₁.card : ℝ) + (B₂.card : ℝ) := by
      exact_mod_cast Finset.card_union_le B₁ B₂
    linarith
  have hne : ∃ k : Fin K, k ∉ B₁ ∪ B₂ := by
    by_contra hcon
    push_neg at hcon
    have hsubset : (Finset.univ : Finset (Fin K)) ⊆ B₁ ∪ B₂ := fun k _ => hcon k
    have : (K : ℝ) ≤ ((B₁ ∪ B₂).card : ℝ) := by
      have hc := Finset.card_le_card hsubset
      rw [Finset.card_univ, Fintype.card_fin] at hc
      exact_mod_cast hc
    linarith
  obtain ⟨k, hk⟩ := hne
  rw [Finset.mem_union] at hk
  push_neg at hk
  obtain ⟨hk1, hk2⟩ := hk
  simp only [hB₁, badMassKeysC, Finset.mem_filter, Finset.mem_univ, true_and,
    not_lt] at hk1
  simp only [hB₂, badMassKeysC, Finset.mem_filter, Finset.mem_univ, true_and,
    not_lt] at hk2
  refine ⟨k, by linarith [hk1], ?_⟩
  rw [setMass_univ, mul_one] at hk2
  linarith [hk2]

/-- **Tunable sharp scheme (settles Conjecture C).**

For every `η > 0` a single explicit key achieves, simultaneously:

1. failure probability `≤ δ + (1 + 1/η)·|l|/M`;
2. **silent** corruption probability `≤ (1 + η)·δ·|l|/M`;
3. decoding cost exactly `|l|` hash evaluations.

The constant in front of the silent-error term can therefore be pushed to `1`
(the first-moment optimum) at the price of a larger — but still `O(1)` for fixed
`η` — constant in the failure term.  At `η = 1` both constants are `2` and this
is `exists_sharp_almost_lossless_scheme`. -/
theorem exists_tunable_almost_lossless_scheme (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ)
    {η : ℝ} (hη : 0 < η) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + (1 + 1 / η) * (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
          ≤ (1 + η) * δ * (l.length : ℝ) / M
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  have hc₁ : (0 : ℝ) < 1 + η := by linarith
  have hc₂ : (0 : ℝ) < 1 + 1 / η := by
    have : (0 : ℝ) < 1 / η := by positivity
    linarith
  -- `1/(1+η) + 1/(1+1/η) = 1`
  have hsum : 1 / (1 + η) + 1 / (1 + 1 / η) ≤ 1 := by
    have hηne : η ≠ 0 := ne_of_gt hη
    have h2 : (1 : ℝ) + 1 / η = (η + 1) / η := by field_simp
    rw [h2, one_div_div]
    rw [div_add_div _ _ (ne_of_gt hc₁) (by positivity : (η + 1) ≠ 0)]
    rw [div_le_one (by positivity)]
    ring_nf
    nlinarith [hη]
  obtain ⟨k, hsilent, hall⟩ :=
    exists_tunable_good_key μ hU hK l.toFinset hc₁ hc₂ hsum
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hcard : (l.toFinset.card : ℝ) = (l.length : ℝ) := by
    rw [List.toFinset_card_of_nodup hnd]
  refine ⟨k, ?_, ?_, fun i => scanCost_snd _ _ _⟩
  · set C : Finset α := Finset.univ.filter (fun x => Collides H k l.toFinset x) with hC
    have hCbound : setMass μ C ≤ (1 + 1 / η) * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR]
      have := hall
      rw [hcard] at this
      linarith
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
      _ ≤ δ + (1 + 1 / η) * (l.length : ℝ) / M := add_le_add hδ hCbound
  · set D : Finset α := (l.toFinset)ᶜ.filter (fun x => Collides H k l.toFinset x)
      with hD
    have hsub : Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x) ⊆ D := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      rw [hD, Finset.mem_filter]
      refine ⟨Finset.mem_compl.mpr ?_, collides_iff.mpr (silentError_imp_collides hx)⟩
      intro hxl
      exact hashScheme_neverSilent_on_codebook (List.mem_toFinset.mp hxl) hx
    have hcardnn : (0 : ℝ) ≤ (l.length : ℝ) := Nat.cast_nonneg _
    have hDb : (M : ℝ) * setMass μ D ≤ (1 + η) * (l.length : ℝ) * δ := by
      have h1 : (M : ℝ) * setMass μ D
          ≤ (1 + η) * (l.toFinset.card : ℝ) * setMass μ (l.toFinset)ᶜ := hsilent
      have h2 : (1 + η) * (l.toFinset.card : ℝ) * setMass μ (l.toFinset)ᶜ
          ≤ (1 + η) * (l.length : ℝ) * δ := by
        rw [hcard]
        have hfac : (0 : ℝ) ≤ (1 + η) * (l.length : ℝ) :=
          mul_nonneg (le_of_lt hc₁) hcardnn
        nlinarith [mul_le_mul_of_nonneg_left hδ hfac]
      linarith
    have hfin : setMass μ D ≤ (1 + η) * δ * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR]
      nlinarith [hDb]
    exact le_trans (setMass_mono μ hsub) hfin

end TunableMarkov

end AlmostLossless