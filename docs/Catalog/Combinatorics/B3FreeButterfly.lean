/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The butterfly obstruction: the height lower bound for `La(n, P)` is not tight

`Catalog/Combinatorics/B3FreePosetBracket.lean` brackets `La(n, P)` between two exact
`k`-Sperner values: `k = h(P) − 1` layers from below (`window_le_La_of_chain`) and
`k = |P| − 1` layers from above (`La_le_window_of_card`).  This file shows that the *lower*
end of that bracket is genuinely lossy, by isolating a purely local obstruction.

Call `P` **butterfly-containing** if it has two distinct elements `p₁, p₂` lying strictly
below two distinct elements `q₁, q₂`.  The main theorem `layers_weakFree_of_hasButterfly`
says that **two consecutive layers of `2^[n]` are weak `P`-free for every
butterfly-containing `P`**, whatever the height of `P` is.  The reason is a rigidity
statement about the two-layer sublattice: inside two consecutive layers, an element covering
two others is *forced* to be their union, and two distinct elements cannot both be that
union.

Applied to the butterfly poset `Butterfly` itself (height `2`), this beats the height bound
by a whole layer: the height bound gives only one central layer, while two central layers
are butterfly-free.

## Main results

* `HasButterfly`, `layers_weakFree_of_hasButterfly` — the obstruction and the two-layer
  freeness theorem.
* `two_window_le_La_of_hasButterfly` — hence `La(n, P)` is at least the sum of the two
  largest binomial coefficients for every butterfly-containing `P`.
* `Butterfly` — the four-element butterfly poset, with `card_butterfly`,
  `hasButterfly_butterfly`, `butterfly_no_three_chain` (height `2`).
* `La_butterfly_bracket` — `C(n,⌊n/2⌋) + C(n, ·) ≤ La(n, Butterfly) ≤` sum of the three
  largest binomial coefficients.
* `height_bound_not_tight_butterfly` — the quantitative statement that the height lower
  bound is strictly weaker than the butterfly lower bound for every nonempty ground set.
-/

import Mathlib
import Bridges.B3FreeFamilies
import Bridges.B3FreeFamiliesBounds
import Bridges.B3FreeFamiliesLevels
import Combinatorics.B3FreeAntichainMonotone
import Combinatorics.B3FreeKSperner
import Combinatorics.B3FreePosetBracket

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## The butterfly obstruction -/

/-- `P` **contains a butterfly**: two distinct elements lie strictly below two distinct
elements.  (The four elements need not be pairwise incomparable.) -/
def HasButterfly (P : Type*) [Preorder P] : Prop :=
  ∃ p₁ p₂ q₁ q₂ : P, p₁ ≠ p₂ ∧ q₁ ≠ q₂ ∧ p₁ < q₁ ∧ p₁ < q₂ ∧ p₂ < q₁ ∧ p₂ < q₂

omit [Fintype α] in
/-- Two distinct sets of the same size have a strictly larger union. -/
theorem card_lt_card_union_of_ne {X Y : Finset α} (hne : X ≠ Y) (hcard : X.card = Y.card) :
    X.card < (X ∪ Y).card := by
  rcases lt_or_ge X.card (X ∪ Y).card with h | h
  · exact h
  · exfalso
    have hXU : X = X ∪ Y := Finset.eq_of_subset_of_card_le Finset.subset_union_left h
    have hYX : Y ⊆ X := by
      rw [hXU]
      exact Finset.subset_union_right
    exact hne (Finset.eq_of_subset_of_card_le hYX (by omega)).symm

/-- **The two-layer rigidity theorem.**  Two consecutive layers of the cube are weak
`P`-free for every butterfly-containing poset `P`: an element of the upper layer that lies
above two distinct sets of the lower layer must be their union, and two distinct elements
cannot both equal that union. -/
theorem layers_weakFree_of_hasButterfly {P : Type*} [Preorder P] (hP : HasButterfly P)
    (a : ℕ) : WeakFree (layers α a 2) P := by
  classical
  obtain ⟨p₁, p₂, q₁, q₂, hp, hq, h11, h12, h21, h22⟩ := hP
  rintro ⟨ι, ⟨hinj, hmono⟩, hmem⟩
  -- the four sets, with their sizes pinned down by the two-layer condition
  have hsize : ∀ x : P, a ≤ (ι x).card ∧ (ι x).card < a + 2 := fun x => mem_layers.1 (hmem x)
  have hstrict : ∀ x y : P, x < y → (ι x).card < (ι y).card := fun x y hxy =>
    Finset.card_lt_card (hmono x y hxy)
  have hpa : ∀ i : P, (i < q₁) → (ι i).card = a := by
    intro i hi
    have h1 := hsize i
    have h2 := hsize q₁
    have h3 := hstrict i q₁ hi
    omega
  have hqa : ∀ j : P, (p₁ < j) → (ι j).card = a + 1 := by
    intro j hj
    have h1 := hsize j
    have h2 := hsize p₁
    have h3 := hstrict p₁ j hj
    have h4 : (ι p₁).card = a := hpa p₁ h11
    omega
  have hp₁ : (ι p₁).card = a := hpa p₁ h11
  have hp₂ : (ι p₂).card = a := hpa p₂ h21
  have hq₁ : (ι q₁).card = a + 1 := hqa q₁ h11
  have hq₂ : (ι q₂).card = a + 1 := hqa q₂ h12
  -- the union of the two lower sets has size exactly `a + 1`
  have hne : ι p₁ ≠ ι p₂ := fun hEq => hp (hinj hEq)
  have hunion_lt : a < (ι p₁ ∪ ι p₂).card := by
    have := card_lt_card_union_of_ne (α := α) hne (by omega)
    omega
  -- each upper set contains that union, hence *equals* it
  have hforced : ∀ j : P, p₁ < j → p₂ < j → ι j = ι p₁ ∪ ι p₂ := by
    intro j hj1 hj2
    have hsub : ι p₁ ∪ ι p₂ ⊆ ι j :=
      Finset.union_subset (hmono p₁ j hj1).subset (hmono p₂ j hj2).subset
    have hjcard : (ι j).card = a + 1 := hqa j hj1
    exact (Finset.eq_of_subset_of_card_le hsub (by omega)).symm
  exact hq (hinj ((hforced q₁ h11 h21).trans (hforced q₂ h12 h22).symm))

/-- **The butterfly lower bound.**  For every butterfly-containing poset `P`, `La(n, P)` is
at least the sum of the two largest binomial coefficients — independently of the height
of `P`. -/
theorem two_window_le_La_of_hasButterfly {P : Type*} [Preorder P] (hP : HasButterfly P) :
    (layers α (centralStart (Fintype.card α) 2) 2).card ≤ La α P :=
  card_le_La (layers_weakFree_of_hasButterfly hP _)

/-! ## The butterfly poset -/

/-- The **butterfly poset**: two minimal elements `a₁, a₂` below two maximal elements
`b₁, b₂`. -/
inductive Butterfly : Type
  | a₁ : Butterfly
  | a₂ : Butterfly
  | b₁ : Butterfly
  | b₂ : Butterfly
  deriving DecidableEq, Fintype

namespace Butterfly

/-- The order relation of the butterfly, as a Boolean-valued function. -/
def leb : Butterfly → Butterfly → Bool
  | a₁, a₁ => true
  | a₁, b₁ => true
  | a₁, b₂ => true
  | a₂, a₂ => true
  | a₂, b₁ => true
  | a₂, b₂ => true
  | b₁, b₁ => true
  | b₂, b₂ => true
  | _, _ => false

instance instPartialOrder : PartialOrder Butterfly where
  le x y := leb x y = true
  le_refl := by decide
  le_trans := by decide
  le_antisymm := by decide

instance : Inhabited Butterfly := ⟨a₁⟩

instance : DecidableRel (· ≤ · : Butterfly → Butterfly → Prop) := fun x y =>
  inferInstanceAs (Decidable (leb x y = true))

instance : DecidableRel (· < · : Butterfly → Butterfly → Prop) := fun x y =>
  decidable_of_iff (x ≤ y ∧ ¬ y ≤ x) lt_iff_le_not_ge.symm

end Butterfly

theorem card_butterfly : Fintype.card Butterfly = 4 := by decide

/-- The butterfly poset contains a butterfly. -/
theorem hasButterfly_butterfly : HasButterfly Butterfly :=
  ⟨Butterfly.a₁, Butterfly.a₂, Butterfly.b₁, Butterfly.b₂, by decide, by decide,
    by decide, by decide, by decide, by decide⟩

/-- The butterfly poset has height `2`: it has no chain of three elements. -/
theorem butterfly_no_three_chain : ¬ ∃ c : Fin 3 → Butterfly, StrictMono c := by
  rintro ⟨c, hc⟩
  have hno : ∀ x y z : Butterfly, ¬ (x < y ∧ y < z) := by decide
  exact hno (c 0) (c 1) (c 2) ⟨hc (by decide), hc (by decide)⟩

/-- The butterfly poset does have a chain of two elements, so its height is exactly `2`. -/
theorem butterfly_two_chain : ∃ c : Fin 2 → Butterfly, StrictMono c := by
  refine ⟨fun i => if (i : ℕ) = 0 then Butterfly.a₁ else Butterfly.b₁, ?_⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all (config := { decide := true })

/-- **The boundary of the method.**  The diamond `B_2` does *not* contain a butterfly: in
`B_2` two distinct elements never have two distinct common strict upper bounds.  So the
two-layer freeness of `B_2` (a special case of `layers_weakFree`) cannot be obtained from
the butterfly obstruction, and the diamond problem genuinely needs a different argument. -/
theorem not_hasButterfly_boolLat2 : ¬ HasButterfly (BoolLat 2) := by
  unfold HasButterfly
  decide

/-- By contrast, `B_3` does contain a butterfly, so two central layers are `B_3`-free by
the butterfly obstruction alone. -/
theorem hasButterfly_boolLat3 : HasButterfly (BoolLat 3) :=
  ⟨∅, {0}, {0, 1}, {0, 1, 2}, by decide, by decide, by decide, by decide, by decide, by decide⟩

/-! ## The consequences for the butterfly poset -/

/-- **The bracket for the butterfly poset.**  Two central layers from below (the butterfly
obstruction) and three central layers from above (the `k`-Sperner bound, since
`|Butterfly| = 4`). -/
theorem La_butterfly_bracket (h : 3 ≤ Fintype.card α + 1) :
    (layers α (centralStart (Fintype.card α) 2) 2).card ≤ La α Butterfly ∧
      La α Butterfly ≤ (layers α (centralStart (Fintype.card α) 3) 3).card := by
  refine ⟨two_window_le_La_of_hasButterfly hasButterfly_butterfly, ?_⟩
  have := La_le_window_of_card (α := α) (P := Butterfly) (by rw [card_butterfly]; omega)
  rwa [card_butterfly] at this

/-- **The height lower bound is not tight.**  For the butterfly poset the height bound
only produces one central layer (its height is `2`), while two central layers are already
butterfly-free; and one central layer is strictly smaller than two. -/
theorem height_bound_not_tight_butterfly (h : 1 ≤ Fintype.card α) :
    (layers α (centralStart (Fintype.card α) 1) 1).card
      < (layers α (centralStart (Fintype.card α) 2) 2).card ∧
    (layers α (centralStart (Fintype.card α) 2) 2).card ≤ La α Butterfly := by
  refine ⟨?_, two_window_le_La_of_hasButterfly hasButterfly_butterfly⟩
  rw [card_layers, card_layers]
  set n := Fintype.card α with hn
  have h1 : centralStart n 1 = n / 2 := by simp [centralStart]
  have hmid : n / 2 = centralStart n 2 ∨ n / 2 = centralStart n 2 + 1 := by
    simp only [centralStart]; omega
  have hsum1 : ∑ i ∈ Finset.Ico (centralStart n 1) (centralStart n 1 + 1), n.choose i
      = n.choose (n / 2) := by
    rw [h1]; simp
  have hsum2 : ∑ i ∈ Finset.Ico (centralStart n 2) (centralStart n 2 + 2), n.choose i
      = n.choose (centralStart n 2) + n.choose (centralStart n 2 + 1) := by
    rw [show centralStart n 2 + 2 = (centralStart n 2 + 1) + 1 by ring,
      Finset.sum_Ico_succ_top (by omega), Finset.sum_Ico_succ_top (by omega)]
    simp
  rw [hsum1, hsum2]
  have hmid' : n.choose (n / 2) = n.choose (centralStart n 2)
      ∨ n.choose (n / 2) = n.choose (centralStart n 2 + 1) := by
    rcases hmid with h | h
    · left; rw [h]
    · right; rw [h]
  have hpos1 : 0 < n.choose (centralStart n 2) := Nat.choose_pos (by simp [centralStart]; omega)
  have hpos2 : 0 < n.choose (centralStart n 2 + 1) :=
    Nat.choose_pos (by simp [centralStart]; omega)
  omega

end B3Free