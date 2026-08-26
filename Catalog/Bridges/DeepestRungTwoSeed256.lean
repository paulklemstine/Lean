/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Attention profiles, top-`k` mass, and the knee (NET-43, cycle 1 core)

This module carries the basic objects that the later NET-43 cycles
(`Bridges.DeepestRungRandomControl`, `Bridges.DeepestRungSharpness`,
`Bridges.DeepestRungTailCeiling`, `Bridges.DeepestRungPowerTail`,
`Bridges.DeepestRungGapConcavity`, `Bridges.DeepestRungPeakAndTransfer`) are stated in
terms of.

An **attention distribution** on `n` keys is a probability vector `p : Fin n → ℝ`.  A
*width-`k` selection* is a set of at most `k` keys, and the mass it captures is the sum of
the corresponding weights.  The two derived quantities used throughout are

* `bestMass a k` — the largest mass captured by any width-`k` selection (top-`k` mass);
* `eff a = 1 / sumSq a` — the participation ratio, i.e. the effective number of keys.

The **knee** of a monotone pass predicate is the first width at which the predicate holds;
it is `Nat.find`, packaged so that it can be applied to the (classically decidable)
predicates `fun k => τ ≤ bestMass a k`.

## Main results

* `mass_le_bestMass`, `bestMass_le_one`, `bestMass_nonneg` — the defining inequality of the
  top-`k` mass, and its range;
* `bestMass_mono` — the top-`k` mass is monotone in the width;
* `knee_spec`, `knee_le` — the knee passes, and it is the least width that does;
* `sumSq_pos`, `eff_pos` — the participation ratio is well defined and positive.

The hypothesis `0 < n` is not needed for positivity of the collision mass: a probability
vector on the empty index set cannot exist, since its coordinates would sum to `0`.
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

variable {n : ℕ}

/-! ## A. Attention distributions -/

/-- An attention profile on `n` keys: a probability vector. -/
structure AttnDist (n : ℕ) where
  /-- The attention weight of each key. -/
  p : Fin n → ℝ
  /-- Weights are non-negative. -/
  nonneg : ∀ i, 0 ≤ p i
  /-- Weights sum to one. -/
  sum_one : ∑ i, p i = 1

/-! ## B. Width-`k` selections and the top-`k` mass -/

/-- The width-`k` selections: the sets of at most `k` keys. -/
def Kset (n k : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powerset.filter (fun S => S.card ≤ k)

@[simp] lemma mem_Kset {k : ℕ} {S : Finset (Fin n)} : S ∈ Kset n k ↔ S.card ≤ k := by
  simp [Kset]

/-- There is always a width-`k` selection, namely the empty one. -/
lemma Kset_nonempty (n k : ℕ) : (Kset n k).Nonempty :=
  ⟨∅, by simp⟩

/-- The mass captured by the best width-`k` selection. -/
noncomputable def bestMass (a : AttnDist n) (k : ℕ) : ℝ :=
  (Kset n k).sup' (Kset_nonempty n k) (fun S => ∑ i ∈ S, a.p i)

/-- **The defining inequality of the top-`k` mass**: no width-`k` selection captures more. -/
theorem mass_le_bestMass (a : AttnDist n) {S : Finset (Fin n)} {k : ℕ} (hS : S.card ≤ k) :
    ∑ i ∈ S, a.p i ≤ bestMass a k :=
  Finset.le_sup' (f := fun S => ∑ i ∈ S, a.p i) (mem_Kset.2 hS)

/-- The top-`k` mass is non-negative (the empty selection captures `0`). -/
theorem bestMass_nonneg (a : AttnDist n) {k : ℕ} : 0 ≤ bestMass a k := by
  have := mass_le_bestMass a (S := (∅ : Finset (Fin n))) (k := k) (by simp)
  simpa using this

/-- The top-`k` mass never exceeds the total mass `1`. -/
theorem bestMass_le_one (a : AttnDist n) {k : ℕ} : bestMass a k ≤ 1 := by
  refine Finset.sup'_le _ _ (fun S _ => ?_)
  calc ∑ i ∈ S, a.p i ≤ ∑ i : Fin n, a.p i :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
          (fun i _ _ => a.nonneg i)
    _ = 1 := a.sum_one

/-- Widening a selection can only capture more mass. -/
theorem bestMass_mono (a : AttnDist n) {k l : ℕ} (hkl : k ≤ l) :
    bestMass a k ≤ bestMass a l := by
  refine Finset.sup'_le _ _ (fun S hS => ?_)
  exact mass_le_bestMass a (le_trans (mem_Kset.1 hS) hkl)

/-! ## C. The knee of a pass predicate -/

open Classical in
/-- The **knee**: the first width at which the pass predicate `P` holds. -/
noncomputable def knee (P : ℕ → Prop) (h : ∃ k, P k) : ℕ :=
  Nat.find (p := P) h

/-- The knee passes. -/
theorem knee_spec (P : ℕ → Prop) (h : ∃ k, P k) : P (knee P h) := by
  classical
  exact Nat.find_spec (p := P) h

/-- The knee is the least passing width. -/
theorem knee_le (P : ℕ → Prop) {h : ∃ k, P k} {k : ℕ} (hk : P k) : knee P h ≤ k := by
  classical
  exact Nat.find_le (p := P) hk

/-- Below the knee the predicate fails. -/
theorem not_of_lt_knee (P : ℕ → Prop) {h : ∃ k, P k} {k : ℕ} (hk : k < knee P h) : ¬ P k := by
  classical
  exact Nat.find_min (p := P) h hk

/-! ## D. The participation ratio -/

/-- The collision mass `∑ p_i²` of an attention profile. -/
noncomputable def sumSq (a : AttnDist n) : ℝ := ∑ i, (a.p i) ^ 2

/-- The **effective support** (participation ratio) `1 / ∑ p_i²`. -/
noncomputable def eff (a : AttnDist n) : ℝ := 1 / sumSq a

/-- A profile on at least one key has positive collision mass. -/
theorem sumSq_pos (a : AttnDist n) : 0 < sumSq a := by
  rcases Finset.exists_ne_zero_of_sum_ne_zero
    (show ∑ i, a.p i ≠ 0 by rw [a.sum_one]; norm_num) with ⟨i, _, hi⟩
  have hlt : 0 < (a.p i) ^ 2 := by positivity
  refine lt_of_lt_of_le hlt (Finset.single_le_sum (f := fun j => (a.p j) ^ 2)
    (fun j _ => by positivity) (Finset.mem_univ i))

/-- The effective support is positive. -/
theorem eff_pos (a : AttnDist n) : 0 < eff a := by
  rw [eff]
  exact div_pos one_pos (sumSq_pos a)

/-- **The concentration floor.**  A width-`k` selection cannot capture mass `τ` unless the
width is at least `τ² · eff`: by Cauchy–Schwarz the mass of any `k` keys is at most
`√(k · ∑ p_i²)`. -/
theorem card_ge_of_bestMass_ge (a : AttnDist n) {k : ℕ} {τ : ℝ} (hτ0 : 0 ≤ τ)
    (hpass : τ ≤ bestMass a k) : τ ^ 2 * eff a ≤ (k : ℝ) := by
  obtain ⟨S, hS, hSval⟩ :=
    Finset.exists_mem_eq_sup' (Kset_nonempty n k) (fun S => ∑ i ∈ S, a.p i)
  have hmass : τ ≤ ∑ i ∈ S, a.p i := by rw [← hSval]; exact hpass
  have hcard : (S.card : ℝ) ≤ (k : ℝ) := by exact_mod_cast mem_Kset.1 hS
  have hcs : (∑ i ∈ S, a.p i) ^ 2 ≤ (S.card : ℝ) * ∑ i ∈ S, (a.p i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hsub : ∑ i ∈ S, (a.p i) ^ 2 ≤ sumSq a :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
      (fun i _ _ => by positivity)
  have hX : (0 : ℝ) ≤ ∑ i ∈ S, (a.p i) ^ 2 := by positivity
  have hk0 : (0 : ℝ) ≤ (k : ℝ) := by positivity
  have hsq : τ ^ 2 ≤ (k : ℝ) * sumSq a := by
    have h1 : τ ^ 2 ≤ (∑ i ∈ S, a.p i) ^ 2 := by nlinarith
    have h2 : (S.card : ℝ) * ∑ i ∈ S, (a.p i) ^ 2 ≤ (k : ℝ) * sumSq a := by
      calc (S.card : ℝ) * ∑ i ∈ S, (a.p i) ^ 2 ≤ (k : ℝ) * ∑ i ∈ S, (a.p i) ^ 2 := by
            nlinarith
        _ ≤ (k : ℝ) * sumSq a := by nlinarith
    linarith
  rw [eff, mul_one_div, div_le_iff₀ (sumSq_pos a)]
  linarith

end Bridges.DeepestRungTwoSeed256