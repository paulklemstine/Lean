/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Carathéodory Theorem

## Overview

This file proves the **tropical Carathéodory theorem** for max-plus convex combinations
in finite dimension: any point in the tropical convex hull of finitely many generators
in ℝⁿ can be represented using at most n+1 generators.

In tropical (max-plus) convexity, a tropical linear combination of generators
V₁, …, Vₘ ∈ ℝⁿ with coefficients c₁, …, cₘ ∈ ℝ produces the vector
  x_i = max_j (c_j + V_j(i))
The tropical Carathéodory theorem says that every such point can be realized
using at most n+1 of the generators.

## Main Results

* `tropLinComb` — tropical linear combination over all generators
* `tropLinCombOn` — tropical linear combination restricted to a subset
* `tropLinCombOn_eq_of_argmax_subset` — restriction to argmax-containing set is lossless
* `tropical_caratheodory` — **main theorem**: at most n+1 generators suffice
* `tropLinComb_add_const` — shift invariance of tropical combinations
* `tropLinComb_mono` — monotonicity in coefficients
* `tropHull_mem_iff` — characterization of tropical hull membership

## Proof Strategy

The proof uses coordinate-wise argmax extraction:
1. For each coordinate i ∈ Fin n, find a generator j(i) achieving the maximum.
2. The image of this argmax map has at most n elements.
3. Adding one extra generator for nonemptiness gives at most n+1.
4. The restricted combination equals the full one since every coordinate's
   maximum is achieved by some generator in the subset.

-/
import Mathlib

open Finset

namespace TropicalConvexity

/-! ## Definitions -/

/-- Tropical linear combination over all generators.
    For each coordinate i, take the maximum over generators j of (c j + V j i).
    Requires at least one generator (NeZero m). -/
noncomputable def tropLinComb {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => c j + V j i)

/-- Tropical linear combination restricted to a nonempty subset I of generators. -/
noncomputable def tropLinCombOn {n m : ℕ}
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ)
    (I : Finset (Fin m)) (hI : I.Nonempty) : Fin n → ℝ :=
  fun i => I.sup' hI (fun j => c j + V j i)

/-- The tropical convex hull: the set of all tropical linear combinations
    of a given set of generators. -/
def tropHull {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | ∃ c : Fin m → ℝ, tropLinComb V c = x}

/-- A tropical linear functional: x ↦ max_i (a_i + x_i). -/
noncomputable def tropFunctional {n : ℕ} [NeZero n]
    (a : Fin n → ℝ) (x : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => a i + x i)

/-- Tropical halfspace: {x | tropFunctional a x ≤ tropFunctional b x}. -/
def tropHalfspace {n : ℕ} [NeZero n]
    (a b : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | tropFunctional a x ≤ tropFunctional b x}

/-! ## Elementary Properties -/

/-- The tropical linear combination restricted to a subset is at most the full combination. -/
lemma tropLinCombOn_le_tropLinComb {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ)
    (I : Finset (Fin m)) (hI : I.Nonempty) (i : Fin n) :
    tropLinCombOn V c I hI i ≤ tropLinComb V c i := by
  simp only [tropLinCombOn, tropLinComb]
  exact Finset.sup'_mono _ (Finset.subset_univ I) hI

/-
If I contains an argmax for each coordinate, then the restriction equals the full combination.
-/
lemma tropLinCombOn_eq_of_argmax_subset {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ)
    (I : Finset (Fin m)) (hI : I.Nonempty)
    (hactive : ∀ i : Fin n, ∃ j ∈ I,
      Finset.univ.sup' Finset.univ_nonempty (fun k => c k + V k i) = c j + V j i) :
    tropLinCombOn V c I hI = tropLinComb V c := by
  -- By definition of $tropLinCombOn$, we know that for each $i$, $tropLinCombOn V c I hI i = \max_{j \in I} (c j + V j i)$.
  have h_eq : ∀ i, tropLinCombOn V c I hI i = (Finset.univ.sup' Finset.univ_nonempty (fun k => c k + V k i)) := by
    intro i
    apply le_antisymm
    generalize_proofs at *; (
    exact Finset.sup'_le _ _ fun x hx => Finset.le_sup' ( fun k => c k + V k i ) ( Finset.mem_univ x ));
    obtain ⟨ j, hj₁, hj₂ ⟩ := hactive i; exact hj₂ ▸ Finset.le_sup' ( fun k => c k + V k i ) hj₁;
  generalize_proofs at *; (
  exact funext h_eq)

/-
Shift invariance: adding a constant to all coefficients shifts the result by that constant.
-/
lemma tropLinComb_add_const {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ) (d : ℝ) :
    tropLinComb V (fun j => c j + d) = fun i => tropLinComb V c i + d := by
  unfold tropLinComb;
  simp +decide [ add_assoc, Finset.sup'_add ];
  ac_rfl

/-
Monotonicity: increasing coefficients increases the combination.
-/
lemma tropLinComb_mono {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (c₁ c₂ : Fin m → ℝ)
    (h : ∀ j, c₁ j ≤ c₂ j) (i : Fin n) :
    tropLinComb V c₁ i ≤ tropLinComb V c₂ i := by
  -- Since for all $j$, $c₁ j + V j i ≤ c₂ j + V j i$, the supremum of $c₁ j + V j i$ over all $j$ is less than or equal to the supremum of $c₂ j + V j i$ over all $j$.
  have h_le : ∀ j, c₁ j + V j i ≤ c₂ j + V j i := by
    grind;
  exact Finset.sup'_le _ _ fun j _ => le_trans ( h_le j ) ( Finset.le_sup' ( fun j => c₂ j + V j i ) ( Finset.mem_univ j ) )

/-
Characterization of tropical hull membership.
-/
lemma tropHull_mem_iff {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    x ∈ tropHull V ↔ ∃ c : Fin m → ℝ, ∀ i, x i = Finset.univ.sup' Finset.univ_nonempty (fun j => c j + V j i) := by
  constructor;
  · exact fun h => by obtain ⟨ c, rfl ⟩ := h; exact ⟨ c, fun i => rfl ⟩ ;
  · exact fun ⟨ c, hc ⟩ => ⟨ c, funext fun i => hc i ▸ rfl ⟩

/-! ## Tropical Carathéodory Theorem -/

/-
**Tropical Carathéodory Theorem.**
    Any tropical linear combination of m generators in ℝⁿ can be represented
    using at most n+1 generators.

    This is the tropical analogue of the classical Carathéodory theorem:
    in tropical (max-plus) convexity, support compression to n+1 generators
    always suffices. The proof extracts coordinate-wise argmaxes, whose image
    has at most n elements, plus one element for nonemptiness.
-/
theorem tropical_caratheodory {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ) :
    ∃ (I : Finset (Fin m)) (hI : I.Nonempty),
      I.card ≤ n + 1 ∧
      tropLinCombOn V c I hI = tropLinComb V c := by
  -- By definition of $tropLinComb$, for each coordinate $i$, there exists a $j$ such that $c j + V j i$ is the maximum.
  have h_max_exists : ∀ i : Fin n, ∃ j : Fin m, (Finset.univ.sup' Finset.univ_nonempty (fun k => c k + V k i)) = c j + V j i := by
    exact fun i => by simpa [ eq_comm ] using Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun k => c k + V k i ) ;
  choose f hf using h_max_exists;
  use Finset.image f Finset.univ ∪ { ⟨ 0, NeZero.pos m ⟩ };
  refine' ⟨ _, _, _ ⟩;
  exact ⟨ _, Finset.mem_union_right _ ( Finset.mem_singleton_self _ ) ⟩;
  · exact le_trans ( Finset.card_union_le _ _ ) ( add_le_add ( Finset.card_image_le.trans ( by simp ) ) ( Finset.card_singleton _ |> le_of_eq ) );
  · exact tropLinCombOn_eq_of_argmax_subset V c _ _ fun i => ⟨ f i, Finset.mem_union_left _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ), hf i ⟩

/-! ## Tropical Idempotency -/

/-- **Tropical mirror theorem (idempotent law).**
    The max operation is idempotent: max(a, a) = a.
    This is the fundamental algebraic identity of tropical semirings. -/
theorem tropical_mirror_theorem (a : ℝ) : max a a = a := by
  exact max_self a

/-
**Idempotent collapse for tropical combinations.**
    Adding a duplicate generator does not change the tropical hull.
-/
lemma tropLinComb_duplicate_generator {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ) (j₀ : Fin m)
    (c' : Fin (m + 1) → ℝ) (V' : Fin (m + 1) → Fin n → ℝ)
    (hV' : ∀ j : Fin m, V' j.castSucc = V j)
    (hV'last : V' (Fin.last m) = V j₀)
    (hc' : ∀ j : Fin m, c' j.castSucc = c j)
    (hc'last : c' (Fin.last m) ≤ c j₀) :
    ∀ i, tropLinComb V' c' i = tropLinComb V c i := by
  -- By definition of tropLinComb, we need to show that the supremum over Fin (m + 1) equals the supremum over Fin m.
  intro i
  apply le_antisymm;
  · refine' Finset.sup'_le _ _ _;
    intro j hj;
    refine' Finset.le_sup' ( fun j => c j + V j i ) ( Finset.mem_univ ( if h : j.val < m then ⟨ j.val, h ⟩ else j₀ ) ) |> le_trans _;
    grind +suggestions;
  · unfold tropLinComb;
    grind +suggestions

end TropicalConvexity