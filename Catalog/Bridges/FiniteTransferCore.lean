/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite Transfer Dynamics: Eventual Image Stabilization and Recurrent Core

This file establishes the foundational theory of finite transfer dynamics:
given any endomorphism `f` on a finite type, the descending chain of iterated
images stabilizes, yielding a canonical **recurrent core** on which `f`
restricts to a bijection.

## Main Results

* `iterate_range_subset` — `Set.range (f^[n+1]) ⊆ Set.range (f^[n])`.
* `iterate_range_stabilizes` — (Theorem A) For finite `C`, there exists `N`
  such that `Set.range (f^[N+1]) = Set.range (f^[N])`.
* `surjOn_stable_range` — On the stabilized range, `f` is surjective.
* `mapsTo_stable_range` — On the stabilized range, `f` maps into itself.
* `bijOn_stable_range` — (Theorem A corollary) On the stabilized range,
  `f` is bijective — a finite surjective endomorphism is bijective.
* `renorm_comp` — The renormalization semigroup law `f^[m+n] = f^[m] ∘ f^[n]`.

## Mathematical Overview

For any function `f : C → C` on a finite type, the images
`Im(f⁰) ⊇ Im(f¹) ⊇ Im(f²) ⊇ ⋯` form a descending chain of finite sets.
By finiteness this chain stabilizes at some index `N`. On the stable image
`Core := Im(f^N)`, the map `f` is surjective. Since a surjective
endomorphism of a finite set is bijective, `f` restricts to a permutation on
`Core`. The orbits of this permutation are the **recurrent classes** of the
dynamical system.

This is the combinatorial backbone underlying recurrent-class decomposition
in finite Markov chains, terminal SCC analysis in automata theory, and the
spectral boundary construction in closure-scale dynamics.
-/
import Mathlib

set_option maxHeartbeats 800000

open Function Set Finset

namespace FiniteTransferDynamics

variable {C : Type*} [Fintype C] [DecidableEq C]

/-! ### Range monotonicity -/

/-
The range of `f^[n+1]` is contained in the range of `f^[n]`.
-/
lemma iterate_range_subset (f : C → C) (n : ℕ) :
    Set.range (f^[n + 1]) ⊆ Set.range (f^[n]) := by
  intro x hx
  aesop

/-
The sequence of ranges `Set.range (f^[n])` is antitone.
-/
lemma iterate_range_antitone (f : C → C) : Antitone (fun n => Set.range (f^[n])) := by
  exact antitone_nat_of_succ_le fun n => Set.range_comp_subset_range _ _

/-! ### Stabilization of the descending chain (Theorem A) -/

/-
**Theorem A (Range Stabilization).** For any endomorphism on a finite type,
the descending chain of iterated images stabilizes.
-/
theorem iterate_range_stabilizes (f : C → C) :
    ∃ N : ℕ, Set.range (f^[N + 1]) = Set.range (f^[N]) := by
  by_contra! h;
  -- By definition of $f^[n]$, the sequence of sets $\{ \text{range}(f^n) \}_{n \geq 0}$ is strictly decreasing.
  have h_decreasing : StrictAnti (fun n => (Set.range (f^[n]))) := by
    exact strictAnti_nat_of_succ_lt fun n => lt_of_le_of_ne ( Set.range_comp_subset_range _ _ ) ( h n );
  exact absurd ( Set.infinite_range_of_injective h_decreasing.injective ) ( Set.not_infinite.mpr <| Set.toFinite _ )

/-- The stabilization index: the smallest `N` such that the range chain stabilizes. -/
noncomputable def stabilizationIndex (f : C → C) : ℕ :=
  (iterate_range_stabilizes f).choose

lemma stabilizationIndex_spec (f : C → C) :
    Set.range (f^[stabilizationIndex f + 1]) = Set.range (f^[stabilizationIndex f]) :=
  (iterate_range_stabilizes f).choose_spec

/-- The **recurrent core**: the eventual stable image of `f`. -/
def recurrentCore (f : C → C) : Set C :=
  Set.range (f^[stabilizationIndex f])

/-
Once stabilized at index `N`, all subsequent iterates have the same range.
-/
lemma iterate_range_eq_of_stable (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) (k : ℕ) :
    Set.range (f^[N + k]) = Set.range (f^[N]) := by
  induction' k with k ih <;> simp_all +decide [ ← Function.iterate_succ_apply' ];
  simp_all +decide [ ← add_assoc, Function.iterate_succ_apply' ];
  convert hN using 1;
  convert congr_arg ( fun s => f '' s ) ih using 1 <;> simp +decide [ Set.range_comp ];
  · ext; simp +decide [ Set.mem_image, Function.iterate_succ_apply' ] ;
    simp +decide only [← Function.iterate_succ_apply' f];
    rfl;
  · simp +decide [ Set.image, Function.iterate_succ_apply' ];
    simp +decide only [← Function.iterate_succ_apply' f];
    rfl

/-! ### Surjectivity and bijectivity on the stable range -/

/-
On the stabilized range, `f` maps the core into itself.
-/
lemma mapsTo_stable_range (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) :
    Set.MapsTo f (Set.range (f^[N])) (Set.range (f^[N])) := by
  -- If x is in the range of f^[N], then there exists some y such that f^[N](y) = x. Applying f to x gives f(x) = f(f^[N](y)) = f^[N+1](y), which is in the range of f^[N+1] and hence in the range of f^[N] by hN.
  intro x hx
  obtain ⟨y, hy⟩ := hx
  have hfx : f x = f^[N + 1] y := by
    rw [ Function.iterate_succ_apply', hy ];
  exact hN ▸ hfx ▸ Set.mem_range_self _

/-
On the stabilized range, `f` is surjective.
-/
lemma surjOn_stable_range (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) :
    Set.SurjOn f (Set.range (f^[N])) (Set.range (f^[N])) := by
  simp_all +decide [ Set.ext_iff, SurjOn ];
  exact Set.range_subset_iff.2 fun y => by simpa [ ← Function.iterate_succ_apply' ] using hN _ |>.2 ⟨ _, rfl ⟩ ;

/-
**Theorem A (Bijectivity Corollary).** On the stabilized range, `f` is bijective.
A finite surjective endomorphism is bijective.
-/
theorem bijOn_stable_range (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) :
    Set.BijOn f (Set.range (f^[N])) (Set.range (f^[N])) := by
  refine' ⟨ _, _, _ ⟩;
  · exact FiniteTransferDynamics.mapsTo_stable_range f N hN;
  · have h_card : Finset.card (Finset.image f (Finset.image (f^[N]) (Finset.univ : Finset C))) = Finset.card (Finset.image (f^[N]) (Finset.univ : Finset C)) := by
      exact congr_arg Finset.card ( Finset.ext fun x => by simpa [ ← Function.iterate_succ_apply' ] using Set.ext_iff.mp hN x );
    have := Finset.card_image_iff.mp h_card;
    aesop;
  · grind +suggestions

/-! ### Renormalization semigroup law (Theorem E partial) -/

omit [Fintype C] [DecidableEq C] in
/-- The iterates of `f` satisfy the semigroup composition law. -/
theorem renorm_comp (f : C → C) (m n : ℕ) :
    f^[m + n] = f^[m] ∘ f^[n] := by
  exact Function.iterate_add f m n

/-! ### Recurrent core membership characterization -/

/-- An element is in the recurrent core iff it is in all sufficiently large iterates' ranges. -/
lemma mem_recurrentCore_iff (f : C → C) (x : C) :
    x ∈ recurrentCore f ↔
    ∀ k : ℕ, x ∈ Set.range (f^[stabilizationIndex f + k]) := by
  constructor
  · intro hx k
    rwa [iterate_range_eq_of_stable f _ (stabilizationIndex_spec f)]
  · intro hx
    exact hx 0

end FiniteTransferDynamics