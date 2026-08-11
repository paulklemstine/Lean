/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Lubell function, Erdős' `k`-Sperner theorem, and exact chain-poset extremal numbers

This file continues the study of weak/strong `P`-free families of
`Catalog/Bridges/B3FreeFamilies.lean`, `…Bounds.lean`, `…Levels.lean` and
`Catalog/Combinatorics/B3FreeAntichainMonotone.lean`.

The catalog already contains the *Mirsky/Sperner* bound
`La(n, B_d) ≤ (2^d − 1)·C(n, ⌊n/2⌋)` (`La_boolLat_le`) and the layer lower bound
`∑_{i ∈ window} C(n, i) ≤ La(n, B_d)`.  The two are off by the difference between
`k·C(n, ⌊n/2⌋)` and the sum of the `k` largest binomial coefficients.  Here we remove that
slack completely by formalizing the **Lubell function** and proving **Erdős' `k`-Sperner
theorem**: a family of height at most `k` has at most `∑` of the `k` largest binomial
coefficients members.

## Main results

* `lubellSum` — the Lubell function `∑_{A ∈ F} 1 / C(n, |A|)`.
* `lubellSum_le_of_not_hasChain` — **Mirsky + LYM**: a family with no chain of `k + 1` sets
  has Lubell function at most `k`.
* `card_le_window_of_lubellSum_le` — **the knapsack step**: a family whose Lubell function is
  at most `k` has at most `|layers α (centralStart n k) k|` members.  (The `k` central
  layers are the optimal "fractional knapsack" solution.)
* `card_le_central_layers_of_not_hasChain` — **Erdős' `k`-Sperner theorem**, the combination
  of the two previous items.
* `weakFree_fin_iff_not_hasChain`, `strongFree_fin_iff_not_hasChain` — weak (equivalently,
  strong) `Fin k`-freeness is exactly the absence of a chain of `k` sets.
* `La_fin_eq`, `LaStar_fin_eq` — **the exact extremal number for the chain poset**:
  `La(n, Fin (k+1)) = La*(n, Fin (k+1)) = ∑_{i ∈ central window} C(n, i)` for `k ≤ n + 1`.
  For `k = 1` this is Sperner's theorem (`La_fin_two_eq`).
* `La_boolLat_le_window` — the **sharpened upper bound**
  `La(n, B_d) ≤ ∑` of the `2^d − 1` largest binomial coefficients, which strictly improves
  `La_boolLat_le` whenever the binomial row is not flat.
* `La_boolLat_bracket` — the resulting two-sided bracket for `La(n, B_d)` by two exact
  `k`-Sperner values, and `La_boolLat3_window_bounds` for the poset `B_3` of the paper.
* `La_boolLat3_le_of_card_ten` — a concrete instance: `La(10, B_3) ≤ 1002`, versus the
  previous catalog bound `7·C(10,5) = 1764`.
-/

import Mathlib
import Bridges.B3FreeFamilies
import Bridges.B3FreeFamiliesBounds
import Bridges.B3FreeFamiliesLevels
import Combinatorics.B3FreeAntichainMonotone

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## The Lubell function -/

/-- The **Lubell function** of a family: `∑_{A ∈ F} 1 / C(n, |A|)`.  Equivalently, the
expected number of members of `F` met by a uniformly random maximal chain. -/
noncomputable def lubellSum (F : Finset (Finset α)) : ℝ :=
  ∑ A ∈ F, ((Fintype.card α).choose A.card : ℝ)⁻¹

omit [DecidableEq α] in
theorem lubellSum_nonneg (F : Finset (Finset α)) : 0 ≤ lubellSum F :=
  Finset.sum_nonneg fun _ _ => by positivity

omit [DecidableEq α] in
theorem lubellSum_empty : lubellSum (∅ : Finset (Finset α)) = 0 := by
  simp [lubellSum]

omit [DecidableEq α] in
theorem lubellSum_pos_of_mem {F : Finset (Finset α)} {A : Finset α} (hA : A ∈ F) :
    0 < lubellSum F := by
  refine Finset.sum_lt_sum_of_subset (f := fun A : Finset α =>
    ((Fintype.card α).choose A.card : ℝ)⁻¹) (Finset.empty_subset F) hA (by simp) ?_ ?_
  · have : 0 < (Fintype.card α).choose A.card :=
      Nat.choose_pos (by simpa using Finset.card_le_univ A)
    positivity
  · intro B _ _
    positivity

omit [DecidableEq α] in
/-- **LYM inequality** in this notation: an antichain has Lubell function at most `1`. -/
theorem lubellSum_le_one_of_isAntichain {F : Finset (Finset α)}
    (h : IsAntichain (· ⊆ ·) (F : Set (Finset α))) : lubellSum F ≤ 1 :=
  Finset.lubell_yamamoto_meshalkin_inequality_sum_inv_choose (𝕜 := ℝ) h

/-- Splitting off the maximal sets of a family splits its Lubell function. -/
theorem lubellSum_sdiff_maxSets_add (F : Finset (Finset α)) :
    lubellSum (F \ maxSets F) + lubellSum (maxSets F) = lubellSum F := by
  classical
  rw [lubellSum, lubellSum, lubellSum, Finset.sum_sdiff (maxSets_subset F)]

/-- **Mirsky + LYM.**  A family with no chain of `k + 1` sets has Lubell function at
most `k`: peel off the maximal sets (an antichain, of Lubell weight at most `1`) `k`
times. -/
theorem lubellSum_le_of_not_hasChain {k : ℕ} :
    ∀ {F : Finset (Finset α)}, ¬ HasChain F (k + 1) → lubellSum F ≤ k := by
  classical
  induction k with
  | zero =>
    intro F h
    have hempty : F = ∅ := by
      by_contra hne
      obtain ⟨A, hA⟩ : ∃ A, A ∈ F := Finset.nonempty_iff_ne_empty.2 hne
      exact h ⟨fun _ => A, fun i j hij => absurd hij (by omega), fun _ => hA⟩
    simp [hempty, lubellSum]
  | succ k ih =>
    intro F h
    have hsub : ¬ HasChain (F \ maxSets F) (k + 1) := fun hc =>
      h (hasChain_succ_of_hasChain_sdiff_maxSets hc)
    have h1 := ih hsub
    have h2 := lubellSum_le_one_of_isAntichain (isAntichain_maxSets F)
    have h3 := lubellSum_sdiff_maxSets_add F
    push_cast
    linarith

/-! ## The knapsack step: the `k` central layers are the optimal levels -/

/-- Every binomial coefficient outside the central window of `k` levels is dominated by
every binomial coefficient inside it. -/
theorem choose_le_choose_of_notMem_window {n k i w : ℕ} (hk : k ≤ n + 1)
    (hi : i ∉ Finset.Ico (centralStart n k) (centralStart n k + k))
    (hw : w ∈ Finset.Ico (centralStart n k) (centralStart n k + k)) :
    n.choose i ≤ n.choose w := by
  have ha1 : n ≤ 2 * centralStart n k + k := by simp only [centralStart]; omega
  have ha2 : 2 * centralStart n k + k ≤ n + 1 := by simp only [centralStart]; omega
  rw [Finset.mem_Ico] at hw
  have hi' : ¬ (centralStart n k ≤ i ∧ i < centralStart n k + k) := fun hcon =>
    hi (Finset.mem_Ico.2 hcon)
  rcases Nat.lt_or_ge i (centralStart n k) with hlt | hge
  · exact choose_le_choose_of_add_le (by omega) (by omega)
  · exact choose_le_choose_of_le_add (by omega) (by omega)

omit [DecidableEq α] in
/-- The number of members of a family on a given level is at most the size of that level. -/
theorem card_filter_card_le (F : Finset (Finset α)) (i : ℕ) :
    (F.filter (fun A => A.card = i)).card ≤ (Fintype.card α).choose i := by
  classical
  have hsub : F.filter (fun A => A.card = i) ⊆ Finset.powersetCard i Finset.univ := by
    intro A hA
    rw [Finset.mem_filter] at hA
    exact Finset.mem_powersetCard.2 ⟨Finset.subset_univ _, hA.2⟩
  calc (F.filter (fun A => A.card = i)).card
      ≤ (Finset.powersetCard i (Finset.univ : Finset α)).card := Finset.card_le_card hsub
    _ = (Fintype.card α).choose i := by rw [Finset.card_powersetCard, Finset.card_univ]

/-- **The fractional knapsack inequality.**  Levels `0, …, N − 1` have capacities `C i > 0`;
a family uses `m i ≤ C i` of level `i` and pays `m i / C i` of Lubell weight.  If the total
weight is at most `k` and `W` is a set of `k` levels whose capacities all dominate the
capacities outside `W`, then filling `W` completely is optimal. -/
theorem knapsack_bound {N k : ℕ} {W : Finset ℕ} {C m : ℕ → ℝ} {c : ℝ}
    (hWsub : W ⊆ Finset.range N) (hWcard : W.card = k)
    (hCpos : ∀ i ∈ Finset.range N, 0 < C i)
    (hm0 : ∀ i ∈ Finset.range N, 0 ≤ m i) (hmC : ∀ i ∈ Finset.range N, m i ≤ C i)
    (hcpos : 0 < c) (hcin : ∀ i ∈ W, c ≤ C i) (hcout : ∀ i ∈ Finset.range N, i ∉ W → C i ≤ c)
    (hlub : ∑ i ∈ Finset.range N, m i * (C i)⁻¹ ≤ k) :
    ∑ i ∈ Finset.range N, m i ≤ ∑ i ∈ W, C i := by
  classical
  have key : ∀ i ∈ Finset.range N,
      m i - c * (m i * (C i)⁻¹) ≤ (if i ∈ W then C i - c else 0) := by
    intro i hi
    have hCi := hCpos i hi
    have hfactor : m i - c * (m i * (C i)⁻¹) = m i * (1 - c * (C i)⁻¹) := by ring
    by_cases hiW : i ∈ W
    · have hcle : c ≤ C i := hcin i hiW
      have hnonneg : 0 ≤ 1 - c * (C i)⁻¹ := by
        rw [sub_nonneg, mul_inv_le_iff₀ hCi]; linarith
      rw [if_pos hiW, hfactor]
      refine (mul_le_mul_of_nonneg_right (hmC i hi) hnonneg).trans ?_
      have : C i * (1 - c * (C i)⁻¹) = C i - c := by field_simp
      rw [this]
    · have hcge : C i ≤ c := hcout i hi hiW
      have hnonpos : 1 - c * (C i)⁻¹ ≤ 0 := by
        rw [sub_nonpos, le_mul_inv_iff₀ hCi]; linarith
      rw [if_neg hiW, hfactor]
      exact mul_nonpos_of_nonneg_of_nonpos (hm0 i hi) hnonpos
  have hsum := Finset.sum_le_sum key
  have hleft : ∑ i ∈ Finset.range N, (m i - c * (m i * (C i)⁻¹))
      = (∑ i ∈ Finset.range N, m i) - c * ∑ i ∈ Finset.range N, m i * (C i)⁻¹ := by
    rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  have hright : ∑ i ∈ Finset.range N, (if i ∈ W then C i - c else 0)
      = (∑ i ∈ W, C i) - c * k := by
    rw [Finset.sum_ite_mem, Finset.inter_eq_right.2 hWsub, Finset.sum_sub_distrib]
    simp [hWcard, mul_comm]
  rw [hleft, hright] at hsum
  nlinarith [mul_le_mul_of_nonneg_left hlub (le_of_lt hcpos)]

/-- **The knapsack step.**  If the Lubell function of `F` is at most `k`, then `F` has at
most as many members as the `k` central layers.  The proof is the fractional-knapsack
argument: filling the `k` largest levels completely is optimal, because every level
outside the central window is cheaper per unit of Lubell weight. -/
theorem card_le_window_of_lubellSum_le {k : ℕ} (hk : k ≤ Fintype.card α + 1)
    {F : Finset (Finset α)} (h : lubellSum F ≤ k) :
    F.card ≤ (layers α (centralStart (Fintype.card α) k) k).card := by
  classical
  rcases Nat.eq_zero_or_pos k with rfl | hkpos
  · -- `k = 0`: the family must be empty
    have hFempty : F = ∅ := by
      by_contra hne
      obtain ⟨A, hA⟩ := Finset.nonempty_iff_ne_empty.2 hne
      have := lubellSum_pos_of_mem hA
      simp only [Nat.cast_zero] at h
      linarith
    simp [hFempty]
  -- arithmetic facts about the central window
  have ha1 : Fintype.card α ≤ 2 * centralStart (Fintype.card α) k + k := by
    simp only [centralStart]; omega
  have ha2 : 2 * centralStart (Fintype.card α) k + k ≤ Fintype.card α + 1 := by
    simp only [centralStart]; omega
  have hWsub : Finset.Ico (centralStart (Fintype.card α) k) (centralStart (Fintype.card α) k + k)
      ⊆ Finset.range (Fintype.card α + 1) := by
    intro i hi
    rw [Finset.mem_Ico] at hi
    exact Finset.mem_range.2 (by omega)
  have hWcard : (Finset.Ico (centralStart (Fintype.card α) k)
      (centralStart (Fintype.card α) k + k)).card = k := by simp
  have hWne : (Finset.Ico (centralStart (Fintype.card α) k)
      (centralStart (Fintype.card α) k + k)).Nonempty := Finset.card_pos.1 (by omega)
  -- the cheapest level inside the window
  obtain ⟨w₀, hw₀W, hw₀min⟩ := Finset.exists_min_image _ (fun i => (Fintype.card α).choose i) hWne
  have hw₀pos : 0 < (Fintype.card α).choose w₀ := by
    rw [Finset.mem_Ico] at hw₀W
    exact Nat.choose_pos (by omega)
  have hmaps : ∀ A ∈ F, A.card ∈ Finset.range (Fintype.card α + 1) := by
    intro A _
    exact Finset.mem_range.2 (by have := Finset.card_le_univ A; omega)
  -- the family splits into levels
  have hcardF : (F.card : ℝ)
      = ∑ i ∈ Finset.range (Fintype.card α + 1),
          ((F.filter (fun A => A.card = i)).card : ℝ) := by
    rw [← Nat.cast_sum]
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ)
      (Finset.card_eq_sum_card_fiberwise (f := Finset.card)
        (t := Finset.range (Fintype.card α + 1)) hmaps)
  have hlubEq : lubellSum F
      = ∑ i ∈ Finset.range (Fintype.card α + 1),
          ((F.filter (fun A => A.card = i)).card : ℝ) * ((Fintype.card α).choose i : ℝ)⁻¹ := by
    rw [lubellSum, ← Finset.sum_fiberwise_of_maps_to hmaps
      (fun A : Finset α => ((Fintype.card α).choose A.card : ℝ)⁻¹)]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_congr rfl (fun A (hA : A ∈ F.filter (fun A => A.card = i)) =>
      show ((Fintype.card α).choose A.card : ℝ)⁻¹ = ((Fintype.card α).choose i : ℝ)⁻¹ by
        rw [(Finset.mem_filter.1 hA).2])]
    simp [mul_comm]
  have hknap := knapsack_bound (N := Fintype.card α + 1) (k := k)
    (W := Finset.Ico (centralStart (Fintype.card α) k) (centralStart (Fintype.card α) k + k))
    (C := fun i => ((Fintype.card α).choose i : ℝ))
    (m := fun i => ((F.filter (fun A => A.card = i)).card : ℝ))
    (c := ((Fintype.card α).choose w₀ : ℝ)) hWsub hWcard
    (fun i hi => by
      have hle : i ≤ Fintype.card α := by simpa [Nat.lt_succ_iff] using Finset.mem_range.1 hi
      dsimp only
      exact_mod_cast Nat.choose_pos hle)
    (fun i _ => by positivity)
    (fun i _ => by dsimp only; exact_mod_cast card_filter_card_le F i)
    (by exact_mod_cast hw₀pos)
    (fun i hi => by dsimp only; exact_mod_cast hw₀min i hi)
    (fun i hi hiW => by
      dsimp only
      exact_mod_cast choose_le_choose_of_notMem_window (n := Fintype.card α) (k := k)
        (i := i) (w := w₀) hk hiW hw₀W)
    (by rw [← hlubEq]; exact h)
  rw [← hcardF] at hknap
  have hWsum : ((layers α (centralStart (Fintype.card α) k) k).card : ℝ)
      = ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) k) (centralStart (Fintype.card α) k + k),
          ((Fintype.card α).choose i : ℝ) := by
    rw [card_layers]
    push_cast
    rfl
  rw [← hWsum] at hknap
  exact_mod_cast hknap

/-- **Erdős' `k`-Sperner theorem.**  A family of subsets of an `n`-set containing no chain
of `k + 1` sets has at most `∑` of the `k` largest binomial coefficients `C(n, i)` members,
i.e. at most as many members as the `k` central layers.  For `k = 1` this is Sperner's
theorem; the catalog bound `card_le_of_not_hasChain` only gave `k·C(n, ⌊n/2⌋)`. -/
theorem card_le_central_layers_of_not_hasChain {k : ℕ} (hk : k ≤ Fintype.card α + 1)
    {F : Finset (Finset α)} (h : ¬ HasChain F (k + 1)) :
    F.card ≤ (layers α (centralStart (Fintype.card α) k) k).card :=
  card_le_window_of_lubellSum_le hk (lubellSum_le_of_not_hasChain h)

/-- The `k`-Sperner theorem in binomial form. -/
theorem card_le_sum_choose_of_not_hasChain {k : ℕ} (hk : k ≤ Fintype.card α + 1)
    {F : Finset (Finset α)} (h : ¬ HasChain F (k + 1)) :
    F.card ≤ ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) k)
      (centralStart (Fintype.card α) k + k), (Fintype.card α).choose i := by
  have := card_le_central_layers_of_not_hasChain hk h
  rwa [card_layers] at this

/-! ## The chain poset `Fin k` -/

omit [DecidableEq α] [Fintype α] in
/-- Weak `Fin k`-freeness is exactly the absence of a chain of `k` sets. -/
theorem weakFree_fin_iff_not_hasChain {k : ℕ} {F : Finset (Finset α)} :
    WeakFree F (Fin k) ↔ ¬ HasChain F k := by
  constructor
  · rintro hfree ⟨c, hc, hmem⟩
    exact hfree ⟨c, ⟨hc.injective, fun p q hpq => Finset.lt_iff_ssubset.1 (hc hpq)⟩, hmem⟩
  · rintro hchain ⟨ι, ⟨-, hmono⟩, hmem⟩
    exact hchain ⟨ι, fun p q hpq => Finset.lt_iff_ssubset.2 (hmono p q hpq), hmem⟩

omit [DecidableEq α] [Fintype α] in
/-- Strong `Fin k`-freeness is also exactly the absence of a chain of `k` sets: a chain is
automatically an induced copy of a chain. -/
theorem strongFree_fin_iff_not_hasChain {k : ℕ} {F : Finset (Finset α)} :
    StrongFree F (Fin k) ↔ ¬ HasChain F k := by
  constructor
  · rintro hfree ⟨c, hc, hmem⟩
    refine hfree ⟨c, ⟨hc.injective, fun p q => ⟨fun hlt => ?_, fun hpq =>
      Finset.lt_iff_ssubset.1 (hc hpq)⟩⟩, hmem⟩
    rcases lt_trichotomy p q with h1 | h1 | h1
    · exact h1
    · exfalso
      rw [h1] at hlt
      exact (Finset.ssubset_iff_subset_ne.1 hlt).2 rfl
    · exact absurd hlt (asymm (Finset.lt_iff_ssubset.1 (hc h1)))
  · intro hchain
    exact (weakFree_fin_iff_not_hasChain.2 hchain).strongFree

/-- **The exact extremal number of the chain poset** (Erdős' theorem):
`La(n, Fin (k+1))` is the total size of the `k` central layers, for every `k ≤ n + 1`. -/
theorem La_fin_eq {k : ℕ} (hk : k ≤ Fintype.card α + 1) :
    La α (Fin (k + 1)) = (layers α (centralStart (Fintype.card α) k) k).card := by
  classical
  refine le_antisymm (Finset.sup_le fun F hF => ?_) ?_
  · rw [Finset.mem_filter] at hF
    exact card_le_central_layers_of_not_hasChain hk (weakFree_fin_iff_not_hasChain.1 hF.2)
  · exact card_le_La (weakFree_fin_iff_not_hasChain.2 (not_hasChain_layers _ _))

/-- The strong extremal number of the chain poset agrees with the weak one. -/
theorem LaStar_fin_eq {k : ℕ} (hk : k ≤ Fintype.card α + 1) :
    LaStar α (Fin (k + 1)) = (layers α (centralStart (Fintype.card α) k) k).card := by
  classical
  refine le_antisymm (Finset.sup_le fun F hF => ?_) ?_
  · rw [Finset.mem_filter] at hF
    exact card_le_central_layers_of_not_hasChain hk (strongFree_fin_iff_not_hasChain.1 hF.2)
  · exact card_le_LaStar
      ((weakFree_fin_iff_not_hasChain.2 (not_hasChain_layers _ _)).strongFree)

theorem La_fin_eq_LaStar_fin {k : ℕ} (hk : k ≤ Fintype.card α + 1) :
    La α (Fin (k + 1)) = LaStar α (Fin (k + 1)) := by
  rw [La_fin_eq hk, LaStar_fin_eq hk]

/-- **Sperner's theorem** as the case `k = 1` of the chain-poset formula. -/
theorem La_fin_two_eq : La α (Fin 2) = (Fintype.card α).choose (Fintype.card α / 2) := by
  have h : (1 : ℕ) ≤ Fintype.card α + 1 := by omega
  rw [La_fin_eq (k := 1) h, card_layers]
  simp [centralStart]

/-! ## Sharpened bounds for `La(n, B_d)` -/

/-- A weak `B_d`-free family contains no chain of `2^d` sets, so the `k`-Sperner theorem
applies with `k = 2^d − 1`: **`La(n, B_d) ≤ ∑` of the `2^d − 1` largest binomial
coefficients.**  This strictly sharpens `La_boolLat_le`, which bounded `La(n, B_d)` by
`(2^d − 1)·C(n, ⌊n/2⌋)`. -/
theorem La_boolLat_le_window {d : ℕ} (hd : 2 ^ d - 1 ≤ Fintype.card α + 1) :
    La α (BoolLat d) ≤
      (layers α (centralStart (Fintype.card α) (2 ^ d - 1)) (2 ^ d - 1)).card := by
  classical
  refine Finset.sup_le fun F hF => ?_
  rw [Finset.mem_filter] at hF
  have hpow : 1 ≤ 2 ^ d := Nat.one_le_two_pow
  refine card_le_central_layers_of_not_hasChain (k := 2 ^ d - 1) hd ?_
  have hEq : 2 ^ d - 1 + 1 = 2 ^ d := by omega
  rw [hEq]
  exact not_hasChain_of_weakFree hF.2

/-- **Two exact `k`-Sperner values bracket `La(n, B_d)`**: the `d` central layers from
below, the `2^d − 1` central layers from above. -/
theorem La_boolLat_bracket {d : ℕ} (hd : 2 ^ d - 1 ≤ Fintype.card α + 1) :
    (layers α (centralStart (Fintype.card α) d) d).card ≤ La α (BoolLat d) ∧
      La α (BoolLat d) ≤
        (layers α (centralStart (Fintype.card α) (2 ^ d - 1)) (2 ^ d - 1)).card :=
  ⟨card_central_layers_le_La d, La_boolLat_le_window hd⟩

/-- The bracket for the poset `B_3` of the paper, in binomial form. -/
theorem La_boolLat3_window_bounds (h : 7 ≤ Fintype.card α + 1) :
    ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) 3) (centralStart (Fintype.card α) 3 + 3),
        (Fintype.card α).choose i ≤ La α (BoolLat 3) ∧
      La α (BoolLat 3) ≤
        ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) 7) (centralStart (Fintype.card α) 7 + 7),
          (Fintype.card α).choose i := by
  have hd : 2 ^ 3 - 1 ≤ Fintype.card α + 1 := by norm_num; omega
  obtain ⟨h1, h2⟩ := La_boolLat_bracket (α := α) (d := 3) hd
  rw [card_layers] at h1
  rw [card_layers] at h2
  refine ⟨h1, ?_⟩
  norm_num at h2 ⊢
  exact h2

omit [DecidableEq α] in
/-- The new upper bound never exceeds the old one: the sum of the `k` largest binomial
coefficients is at most `k · C(n, ⌊n/2⌋)`. -/
theorem sum_window_le_mul (k : ℕ) :
    ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) k) (centralStart (Fintype.card α) k + k),
        (Fintype.card α).choose i ≤ k * (Fintype.card α).choose (Fintype.card α / 2) := by
  calc ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) k) (centralStart (Fintype.card α) k + k),
        (Fintype.card α).choose i
      ≤ ∑ _i ∈ Finset.Ico (centralStart (Fintype.card α) k)
          (centralStart (Fintype.card α) k + k), (Fintype.card α).choose (Fintype.card α / 2) :=
        Finset.sum_le_sum fun i _ => Nat.choose_le_middle i (Fintype.card α)
    _ = k * (Fintype.card α).choose (Fintype.card α / 2) := by
        simp [Nat.card_Ico]

/-- A concrete instance of the sharpening: on a ground set of size `10`,
`La(10, B_3) ≤ 1002`, whereas the catalog bound `La_boolLat3_le` only gives
`7 · C(10, 5) = 1764`. -/
theorem La_boolLat3_le_of_card_ten (hcard : Fintype.card α = 10) :
    La α (BoolLat 3) ≤ 1002 := by
  have h := (La_boolLat3_window_bounds (α := α) (by omega)).2
  rw [hcard] at h
  norm_num [centralStart] at h
  exact h

end B3Free