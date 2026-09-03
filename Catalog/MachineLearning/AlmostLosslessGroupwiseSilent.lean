/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XIV: Group-wise (Fair) Silent-Error Control

## Bridge: universal hashing (algebra) ↔ fractional covering (combinatorics)
##         ↔ per-group risk control (machine learning)

`Bridges.AlmostLosslessTunableMarkov` derandomizes over **two** regions at once,
using the fractional-covering condition `1/c₁ + 1/c₂ ≤ 1`.  The proof is a
counting argument over the key space, and counting arguments are not limited to
two sets: any family of bad-key sets whose *densities* `1/cᵢ` sum to at most `1`
fails to cover `Fin K`.

This file proves the `r`-region form and uses it for a statement of independent
interest in machine learning: **fairness of silent corruption across protected
groups**.  A compressed model must not silently mislabel one subpopulation much
more often than the population average; a bound on the *aggregate* silent-error
rate says nothing about any individual group.  Here a single derandomized key
controls every group simultaneously.

* `exists_multi_good_key` — for any finite family of regions `Aᵢ` and thresholds
  `cᵢ > 0` with `∑ᵢ 1/cᵢ ≤ 1`, one key is `cᵢ`-good on `Aᵢ` for **every** `i`;
* `exists_groupwise_silent_scheme` — **the deliverable**: for any `r` protected
  groups `G₁,…,G_r` a single key with global failure `≤ δ + (r+1)|l|/M` and,
  for each group `g`, silent corruption *inside* `g` at most
  `(r+1)·μ(g ∖ codebook)·|l|/M`.  A group that the codebook covers well is
  protected proportionally better — the bound is *local*, not amortised;
* `groupwise_silent_le_global` — each group's bound is at most
  `(r+1)·δ·|l|/M`, recovering (up to the covering constant) the global bound of
  the previous cycle;
* `exists_groupwise_silent_scheme_local` — the group-wise bound in the
  per-group coverage form, with an individual defect bound `δ_g` for each group.

## Impact: groupwise_silent_error_control, fractional_covering_derandomization
-/

import Mathlib
import Bridges.AlmostLosslessTunableMarkov

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section MultiRegion

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- **`r`-region derandomization by fractional covering.**  Given a finite
family of regions `A i` (`i ∈ t`) and thresholds `c i > 0` whose reciprocals sum
to at most `1`, a *single* key is simultaneously `c i`-good on every region: its
collision mass inside `A i` is at most `c i · |S| · μ(A i)/M`.

For `t = {1,2}` and `c₁ = c₂ = 2` this is `exists_doubly_good_key`; for general
pairs it is `exists_tunable_good_key`.  The proof is the union bound over the
bad-key sets `badMassKeysC`, each of density `< 1/c i`. -/
theorem exists_multi_good_key {ι : Type*} [DecidableEq ι] (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (S : Finset α)
    (t : Finset ι) (A : ι → Finset α) (c : ι → ℝ) (hc : ∀ i ∈ t, 0 < c i)
    (hsum : ∑ i ∈ t, 1 / c i ≤ 1) :
    ∃ k : Fin K, ∀ i ∈ t,
      (M : ℝ) * setMass μ ((A i).filter (fun x => Collides H k S x))
        ≤ c i * (S.card : ℝ) * setMass μ (A i) := by
  classical
  have hKR : (0 : ℝ) < K := by exact_mod_cast hK
  set B : ι → Finset (Fin K) := fun i => badMassKeysC μ H S (A i) (c i) with hB
  -- each bad set has density `< 1/c i`
  have hdens : ∀ i ∈ t, ((B i).card : ℝ) < (K : ℝ) / c i := by
    intro i hi
    rw [lt_div_iff₀ (hc i hi)]
    exact card_badMassC_lt μ hU hK (c i) S (A i)
  -- the union of the bad sets cannot exhaust the key space
  have hunion : ((t.biUnion B).card : ℝ) < K := by
    rcases Finset.eq_empty_or_nonempty t with rfl | hne
    · simpa using hKR
    · have h1 : ((t.biUnion B).card : ℝ) ≤ ∑ i ∈ t, ((B i).card : ℝ) := by
        exact_mod_cast Finset.card_biUnion_le
      have h2 : ∑ i ∈ t, ((B i).card : ℝ) < ∑ i ∈ t, (K : ℝ) / c i :=
        Finset.sum_lt_sum_of_nonempty hne hdens
      have h3 : ∑ i ∈ t, (K : ℝ) / c i ≤ (K : ℝ) := by
        have hrw : ∑ i ∈ t, (K : ℝ) / c i = (K : ℝ) * ∑ i ∈ t, 1 / c i := by
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun i _ => by ring
        rw [hrw]
        calc (K : ℝ) * ∑ i ∈ t, 1 / c i ≤ (K : ℝ) * 1 :=
              mul_le_mul_of_nonneg_left hsum (le_of_lt hKR)
          _ = (K : ℝ) := by ring
      linarith
  have hex : ∃ k : Fin K, k ∉ t.biUnion B := by
    by_contra hcon
    push_neg at hcon
    have hsubset : (Finset.univ : Finset (Fin K)) ⊆ t.biUnion B := fun k _ => hcon k
    have : (K : ℝ) ≤ ((t.biUnion B).card : ℝ) := by
      have hc' := Finset.card_le_card hsubset
      rw [Finset.card_univ, Fintype.card_fin] at hc'
      exact_mod_cast hc'
    linarith
  obtain ⟨k, hk⟩ := hex
  refine ⟨k, fun i hi => ?_⟩
  have hki : k ∉ B i := fun hmem => hk (Finset.mem_biUnion.mpr ⟨i, hi, hmem⟩)
  simp only [hB, badMassKeysC, Finset.mem_filter, Finset.mem_univ, true_and,
    not_lt] at hki
  linarith [hki]

/-! ### Group-wise silent-error control -/

/-- **Fair silent-error control across protected groups.**

Let `G : Fin r → Finset α` be any family of `r` (not necessarily disjoint)
subpopulations.  A single explicit key of the 2-universal family achieves at
once:

1. global failure probability `≤ δ + (r+1)·|l|/M`;
2. for **every** group `g`, silent corruption inside `g` at most
   `(r+1)·μ(g ∖ codebook)·|l|/M`;
3. decoding cost exactly `|l|`.

The per-group bound is *local*: it is driven by the mass of the part of the
group that the codebook misses, so a well-covered subpopulation is protected
proportionally better than the global bound would suggest.  The price of
controlling `r` groups plus the global failure event with one key is the single
covering factor `r+1`, coming from `∑ 1/(r+1) = 1` over the `r+1` regions. -/
theorem exists_groupwise_silent_scheme (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ)
    {r : ℕ} (G : Fin r → Finset α) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + ((r : ℝ) + 1) * (l.length : ℝ) / M
      ∧ (∀ g : Fin r,
          setMass μ ((Finset.univ.filter
              (fun x => (hashScheme l (H k)).SilentError x)) ∩ G g)
            ≤ ((r : ℝ) + 1) * setMass μ ((l.toFinset)ᶜ ∩ G g) * (l.length : ℝ) / M)
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hcard : (l.toFinset.card : ℝ) = (l.length : ℝ) := by
    rw [List.toFinset_card_of_nodup hnd]
  have hrpos : (0 : ℝ) < (r : ℝ) + 1 := by positivity
  -- the `r+1` regions: the whole space (failure) and the missed part of each group
  set A : Option (Fin r) → Finset α :=
    fun o => o.elim Finset.univ (fun g => (l.toFinset)ᶜ ∩ G g) with hA
  set t : Finset (Option (Fin r)) := Finset.univ with ht
  have hcardt : (t.card : ℝ) = (r : ℝ) + 1 := by
    rw [ht, Finset.card_univ]
    simp
  have hsum : ∑ _o ∈ t, 1 / ((r : ℝ) + 1) ≤ 1 := by
    rw [Finset.sum_const, nsmul_eq_mul, hcardt]
    rw [mul_one_div, div_self (ne_of_gt hrpos)]
  obtain ⟨k, hk⟩ := exists_multi_good_key μ hU hK l.toFinset t A
    (fun _ => (r : ℝ) + 1) (fun _ _ => hrpos) hsum
  refine ⟨k, ?_, ?_, fun i => scanCost_snd _ _ _⟩
  · -- global failure: use the region `A none = univ`
    have hnone := hk none (by simp [ht])
    simp only [hA, Option.elim] at hnone
    rw [setMass_univ, mul_one, hcard] at hnone
    set C : Finset α := Finset.univ.filter (fun x => Collides H k l.toFinset x) with hC
    have hCbound : setMass μ C ≤ ((r : ℝ) + 1) * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR]
      linarith [hnone]
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
      _ ≤ δ + ((r : ℝ) + 1) * (l.length : ℝ) / M := add_le_add hδ hCbound
  · -- per-group silent error: use the region `A (some g)`
    intro g
    have hg := hk (some g) (by simp [ht])
    simp only [hA, Option.elim] at hg
    rw [hcard] at hg
    set D : Finset α := ((l.toFinset)ᶜ ∩ G g).filter
      (fun x => Collides H k l.toFinset x) with hD
    have hsub : (Finset.univ.filter
        (fun x => (hashScheme l (H k)).SilentError x)) ∩ G g ⊆ D := by
      intro x hx
      rw [Finset.mem_inter] at hx
      obtain ⟨hx1, hx2⟩ := hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx1
      rw [hD, Finset.mem_filter, Finset.mem_inter]
      refine ⟨⟨Finset.mem_compl.mpr ?_, hx2⟩,
        collides_iff.mpr (silentError_imp_collides hx1)⟩
      intro hxl
      exact hashScheme_neverSilent_on_codebook (List.mem_toFinset.mp hxl) hx1
    have hDb : setMass μ D
        ≤ ((r : ℝ) + 1) * setMass μ ((l.toFinset)ᶜ ∩ G g) * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR]
      nlinarith [hg]
    exact le_trans (setMass_mono μ hsub) hDb

/-- Each group-wise bound is dominated by the global one: since
`μ(g ∖ codebook) ≤ μ(codebookᶜ) ≤ δ`, the per-group silent-error bound is at
most `(r+1)·δ·|l|/M`.  The group-wise statement is therefore a strict refinement
of the aggregate bound of the previous cycle, never weaker. -/
theorem groupwise_silent_le_global (μ : FinProbDist α) (l : List α)
    (Gg : Finset α) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) (r L : ℝ)
    (hr : 0 ≤ r + 1) (hL : 0 ≤ L) :
    (r + 1) * setMass μ ((l.toFinset)ᶜ ∩ Gg) * L ≤ (r + 1) * δ * L := by
  have hmono : setMass μ ((l.toFinset)ᶜ ∩ Gg) ≤ setMass μ (l.toFinset)ᶜ :=
    setMass_mono μ Finset.inter_subset_left
  have h1 : setMass μ ((l.toFinset)ᶜ ∩ Gg) ≤ δ := le_trans hmono hδ
  gcongr

/-- **Group-wise control with individual coverage defects.**  If every group is covered by
the codebook to accuracy `δ_g` — i.e. `μ(g ∖ codebook) ≤ δ_g` — then the key of
`exists_groupwise_silent_scheme` corrupts group `g` silently with probability at
most `(r+1)·δ_g·|l|/M`, so the silent-error rate of each subpopulation is
governed by *its own* coverage defect and not by the worst group. -/
theorem exists_groupwise_silent_scheme_local (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ)
    {r : ℕ} (G : Fin r → Finset α) (d : Fin r → ℝ)
    (hd : ∀ g, setMass μ ((l.toFinset)ᶜ ∩ G g) ≤ d g) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + ((r : ℝ) + 1) * (l.length : ℝ) / M
      ∧ ∀ g : Fin r,
          setMass μ ((Finset.univ.filter
              (fun x => (hashScheme l (H k)).SilentError x)) ∩ G g)
            ≤ ((r : ℝ) + 1) * d g * (l.length : ℝ) / M := by
  classical
  obtain ⟨k, hfail, hgroup, _⟩ :=
    exists_groupwise_silent_scheme μ hU hK hM l hnd δ hδ G
  refine ⟨k, hfail, fun g => ?_⟩
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hrpos : (0 : ℝ) ≤ (r : ℝ) + 1 := by positivity
  have hLnn : (0 : ℝ) ≤ (l.length : ℝ) := Nat.cast_nonneg _
  refine le_trans (hgroup g) ?_
  rw [div_le_div_iff_of_pos_right hMR]
  gcongr
  exact hd g

end MultiRegion

end AlmostLossless