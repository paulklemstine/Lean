/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Countable saturation of the ultrapower

The deepest structural property of an ultrapower modulo a nonprincipal
ultrafilter on `ℕ` is **ℵ₁-saturation**: every countable family of internal
conditions that is *finitely satisfiable* is satisfiable outright.  This is the
model-theoretic reason why nonstandard arguments are so powerful — it is what
makes overspill, the existence of "infinitely large but internal" objects, and
compactness-style arguments work.

Here we prove countable saturation for internal subsets of `HyperNat`
(`countable_saturation`) by an explicit diagonal construction: at index `i`
one satisfies as many of the first conditions as the `i`-th coordinate allows,
using `Nat.findGreatest` to locate that depth.  We then deduce:

* `overspill_of_saturation` — overspill is a one-line consequence;
* `standard_not_internal_of_saturation` — the standard cut is not internal;
* `exists_mem_iInter_of_decreasing` — a strictly decreasing chain of nonempty
  internal sets has a common element, i.e. the internal sets have the
  countable intersection property, in sharp contrast to `ℕ` itself, where
  `{k | k ≥ n}` has empty intersection.
-/

import Novelty.NonstandardTransfer
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-- The pointwise intersection of the first `n + 1` conditions. -/
def partialInter (A : ℕ → ℕ → Set ℕ) (n i : ℕ) : Set ℕ := {x | ∀ k ∈ Set.Iic n, x ∈ A k i}

theorem partialInter_subset {A : ℕ → ℕ → Set ℕ} {n i k : ℕ} (hk : k ≤ n) :
    partialInter A n i ⊆ A k i := fun _ hx => hx k hk

theorem partialInter_antitone {A : ℕ → ℕ → Set ℕ} {i m n : ℕ} (h : m ≤ n) :
    partialInter A n i ⊆ partialInter A m i :=
  fun _ hx k hk => hx k (le_trans hk h)

/-- **Countable saturation (ℵ₁-saturation).**  A countable family of internal
sets all of whose finite subfamilies have a common element has a common
element. -/
theorem countable_saturation (A : ℕ → ℕ → Set ℕ)
    (hfip : ∀ n : ℕ, ∃ H : HyperNat, ∀ k ≤ n, H ∈* ((A k : ℕ → Set ℕ) : InternalSet)) :
    ∃ H : HyperNat, ∀ n : ℕ, H ∈* ((A n : ℕ → Set ℕ) : InternalSet) := by
  classical
  -- Step 1: almost all coordinates of every finite subfamily are nonempty
  have hnonempty : ∀ n : ℕ,
      ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), (partialInter A n i).Nonempty := by
    intro n
    obtain ⟨H, hH⟩ := hfip n
    refine Filter.Germ.inductionOn H (fun h hh => ?_) hH
    have hall : ∀ k ∈ Set.Iic n, ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), h i ∈ A k i := by
      intro k hk
      exact (internalMem_coe h (A k)).mp (hh k hk)
    have := (Filter.eventually_all_finite (Set.finite_Iic n)).mpr hall
    filter_upwards [this] with i hi
    exact ⟨h i, hi⟩
  -- Step 2: diagonalise, satisfying as many conditions as the coordinate allows
  set depth : ℕ → ℕ := fun i => Nat.findGreatest (fun n => (partialInter A n i).Nonempty) i
    with hdepth
  set f : ℕ → ℕ := fun i =>
    if hx : (partialInter A (depth i) i).Nonempty then hx.choose else 0 with hf
  refine ⟨(f : HyperNat), ?_⟩
  intro n
  rw [internalMem_coe]
  filter_upwards [hnonempty 0, hnonempty n, eventually_ge_hyperfilter n] with i h0 hn hi
  -- the diagonal depth is at least `n`
  have hdn : n ≤ depth i := Nat.le_findGreatest hi hn
  have hdne : (partialInter A (depth i) i).Nonempty := by
    simp only [hdepth]
    exact Nat.findGreatest_spec (P := fun n => (partialInter A n i).Nonempty)
      (Nat.zero_le i) h0
  have hfmem : f i ∈ partialInter A (depth i) i := by
    simp only [hf, dif_pos hdne]
    exact hdne.choose_spec
  exact partialInter_subset hdn hfmem

/-- Overspill as a consequence of saturation: if an internal set contains every
standard natural, the countable family "belongs to `A` and exceeds `n`" is
finitely satisfiable, hence satisfiable. -/
theorem overspill_of_saturation (A : ℕ → Set ℕ) (h : ∀ n : ℕ, standard n ∈* (A : InternalSet)) :
    ∃ H : HyperNat, IsUnlimited H ∧ H ∈* (A : InternalSet) := by
  classical
  -- the `n`-th condition: lie in `A` and be `> n`
  set B : ℕ → ℕ → Set ℕ := fun n i => {x | x ∈ A i ∧ n < x} with hB
  have hfip : ∀ n : ℕ, ∃ H : HyperNat, ∀ k ≤ n, H ∈* ((B k : ℕ → Set ℕ) : InternalSet) := by
    intro n
    refine ⟨((fun _ : ℕ => n + 1 : ℕ → ℕ) : HyperNat), fun k hk => ?_⟩
    rw [internalMem_coe]
    have := h (n + 1)
    rw [standard_eq_coe, internalMem_coe] at this
    filter_upwards [this] with i hi
    exact ⟨hi, by omega⟩
  obtain ⟨H, hH⟩ := countable_saturation B hfip
  refine Filter.Germ.inductionOn H (fun g hg => ?_) hH
  refine ⟨(g : HyperNat), ?_, ?_⟩
  · rw [isUnlimited_coe]
    intro n
    have := (internalMem_coe g (B n)).mp (hg n)
    filter_upwards [this] with i hi
    exact hi.2
  · rw [internalMem_coe]
    have := (internalMem_coe g (B 0)).mp (hg 0)
    filter_upwards [this] with i hi
    exact hi.1

/-- Saturation re-proves that the standard cut is external. -/
theorem standard_not_internal_of_saturation :
    ¬ ∃ A : ℕ → Set ℕ, ∀ H : HyperNat, (H ∈* (A : InternalSet) ↔ IsStandard H) := by
  rintro ⟨A, hA⟩
  obtain ⟨H, hU, hmem⟩ := overspill_of_saturation A (fun n => (hA _).mpr (isStandard_standard n))
  exact not_isStandard_of_isUnlimited hU ((hA H).mp hmem)

/-- **The internal sets have the countable intersection property.**  A
decreasing chain of nonempty internal sets has a common element — the exact
opposite of the situation in `ℕ`, where `⋂ n, {k | n < k} = ∅`. -/
theorem exists_mem_iInter_of_decreasing (A : ℕ → ℕ → Set ℕ)
    (hdec : ∀ (n i : ℕ), A (n + 1) i ⊆ A n i)
    (hne : ∀ n : ℕ, ∃ H : HyperNat, H ∈* ((A n : ℕ → Set ℕ) : InternalSet)) :
    ∃ H : HyperNat, ∀ n : ℕ, H ∈* ((A n : ℕ → Set ℕ) : InternalSet) := by
  refine countable_saturation A (fun n => ?_)
  obtain ⟨H, hH⟩ := hne n
  refine ⟨H, fun k hk => ?_⟩
  refine Filter.Germ.inductionOn H (fun g hg => ?_) hH
  rw [internalMem_coe] at hg ⊢
  filter_upwards [hg] with i hi
  -- descend from level `n` to level `k` using the decreasing hypothesis
  have hanti : ∀ d m : ℕ, A (m + d) i ⊆ A m i := by
    intro d
    induction d with
    | zero => intro m; simp
    | succ p ih => exact fun m x hx => ih m (hdec (m + p) i hx)
  have hmem : g i ∈ A (k + (n - k)) i := by
    rw [Nat.add_sub_cancel' hk]
    exact hi
  exact hanti (n - k) k hmem

end NonstandardArithmetic