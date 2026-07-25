/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The cross-intersecting product bound over an arbitrary finite ground set

The companion file `Novelty.CrossIntersectingProductBound` proves the multilateral
cross-intersecting product skeleton for families of subsets of `Fin n`.  Here we
lift the same argument to subsets of an **arbitrary finite type** `α`, with the
elementary count `g(|α|, k) = C(|α|,k) - C(|α|-k,k)`.  This is the natural, label-free
home for the result: the only role of the ground set is its cardinality.

This file is deliberately self-contained (it imports only Mathlib) so that the core
mechanism — a single member of one family pins the size of every cross-intersecting
partner — is available for any finite vertex set.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The `Fin n` proof never uses the order on `Fin n`; only
  `Fintype.card` matters, so the whole development should generalise verbatim.
Experiment (Experimenter): Re-stated `IsUniform`, `CrossIntersecting`, `gcard` and
  the per-family count over `[Fintype α] [DecidableEq α]`, replacing `n` by
  `Fintype.card α` and `Finset.card_univ` doing the bookkeeping.
Analysis (Analyst): Confirmed the argument is purely about cardinalities: the
  counting set `powersetCard k univ \ powersetCard k A₀ᶜ` and `card_compl` are all
  type-agnostic.  The generalisation costs nothing and clarifies what the theorem
  "is about".
Critique (Critic): To avoid a vacuous statement on empty `α`, the bound is an honest
  `Finset.card` inequality that holds for all `α`; when no `k`-set exists both sides
  are governed by the same `choose` arithmetic.
Synthesis (PI): A ground-set-agnostic multilateral cross-intersecting product bound.
-/
import Mathlib

open Finset

namespace CrossIntersectingProductGeneral

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- `𝓕` is `k`-uniform: every member has exactly `k` elements. -/
def IsUniform (k : ℕ) (𝓕 : Finset (Finset α)) : Prop := ∀ A ∈ 𝓕, A.card = k

/-- Two families are *cross-intersecting* if every member of one meets every
member of the other. -/
def CrossIntersecting (𝓕 𝓖 : Finset (Finset α)) : Prop :=
  ∀ A ∈ 𝓕, ∀ B ∈ 𝓖, (A ∩ B).Nonempty

/-- The "fixed-set meeting count" over a ground set of size `Fintype.card α`. -/
def gcard (α : Type*) [Fintype α] (k : ℕ) : ℕ :=
  Nat.choose (Fintype.card α) k - Nat.choose (Fintype.card α - k) k

/-
**Per-family bound (general ground set).** If `𝓖` is `k`-uniform and every
member meets a fixed `k`-set `A₀`, then `|𝓖| ≤ gcard α k`.
-/
lemma card_le_of_cross {k : ℕ} {𝓖 : Finset (Finset α)}
    (h𝓖 : IsUniform k 𝓖) {A₀ : Finset α} (hA₀ : A₀.card = k)
    (hcross : ∀ B ∈ 𝓖, (A₀ ∩ B).Nonempty) :
    𝓖.card ≤ gcard α k := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.powersetCard k ( Finset.univ : Finset α ) \ Finset.powersetCard k ( Finset.univ \ A₀ );
  · grind +locals;
  · rw [ Finset.card_sdiff ];
    rw [ Finset.inter_eq_left.mpr ( Finset.powersetCard_mono <| Finset.sdiff_subset ) ] ; simp +decide [ *, gcard ];
    grind +splitIndPred

/-
**Multilateral cross-intersecting product bound (general ground set).** For
`r ≥ 2` non-empty, `k`-uniform, pairwise cross-intersecting families of subsets of
a finite type `α`, the product of their sizes is at most `gcard α k ^ r`.
-/
theorem multilateral_cross_product_bound {k r : ℕ} (hr : 2 ≤ r)
    (F : Fin r → Finset (Finset α))
    (hunif : ∀ i, IsUniform k (F i))
    (hne : ∀ i, (F i).Nonempty)
    (hcross : ∀ i j, i ≠ j → CrossIntersecting (F i) (F j)) :
    ∏ i, (F i).card ≤ (gcard α k) ^ r := by
  -- It suffices to show ∀ i, (F i).card ≤ gcard α k.
  have h_card_le : ∀ i, (F i).card ≤ gcard α k := by
    intro i
    obtain ⟨j, hj⟩ : ∃ j, j ≠ i := by
      exact ⟨ if i = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩;
    exact card_le_of_cross ( hunif i ) ( hunif j _ ( Classical.choose_spec ( hne j ) ) ) ( hcross j i hj _ ( Classical.choose_spec ( hne j ) ) )
  exact le_trans (Finset.prod_le_prod' (fun _ _ => h_card_le _)) (by simp)

end CrossIntersectingProductGeneral