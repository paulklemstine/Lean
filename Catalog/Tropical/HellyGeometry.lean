import Mathlib

/-!
# Tropical Convexity and Helly Geometry

## Overview

This file develops a formal theory of **tropical convexity** using the max-plus convention
and proves a **Helly-type theorem** for tropical box constraints, together with an
**optimization feasibility certificate**.

## Main Definitions

* `TropicalHelly.tropComb` — max-plus tropical combination with parameter `t`
* `TropicalHelly.tropSegment` — tropical segment between two points
* `TropicalHelly.IsTropConvex` — tropically convex sets (max-plus normalized)
* `TropicalHelly.tropConvHull` — tropical convex hull of a finite point family
* `TropicalHelly.TropBox` — tropical box (product of closed intervals)

## Main Results

* `TropicalHelly.isTropConvex_iInter` — intersection of tropically convex sets is convex
* `TropicalHelly.box_isTropConvex` — tropical boxes are tropically convex
* `TropicalHelly.tropConvHull_isTropConvex` — the tropical convex hull is tropically convex
* `TropicalHelly.helly_intervals` — Helly's theorem for intervals (Helly number 2)
* `TropicalHelly.helly_boxes` — Helly's theorem for boxes in `ℝ^d`
* `TropicalHelly.tropical_feasibility_certificate` — small infeasibility certificate

## Conventions

We use the **max-plus** tropical semiring:
- Tropical addition: `max`
- Tropical scalar action: real addition `(+)`
- Tropical combination: `fun i ↦ max (x i) (t + y i)` with `t ≤ 0`

## Applications

The feasibility certificate theorem directly applies to scheduling, resource allocation,
shortest-path consistency, and min-plus linear programming. It says that **infeasibility
of a coordinate-bound system can always be witnessed by a pair of constraints**.
-/

open Finset Set

namespace TropicalHelly

variable {d : ℕ}

/-! ## Part 1: Tropical Operations and Convexity -/

/-- Max-plus tropical combination of two points with parameter `t`:
    `z i = max (x i) (t + y i)`. When `t = 0`, this gives `max(x, y)`;
    as `t → -∞`, this approaches `x`. -/
def tropComb (t : ℝ) (x y : Fin d → ℝ) : Fin d → ℝ :=
  fun i => max (x i) (t + y i)

/-- The **tropical segment** between `x` and `y`:
    all normalized max-plus combinations. Combines both orderings
    (scaling `y` relative to `x`, and scaling `x` relative to `y`). -/
def tropSegment (x y : Fin d → ℝ) : Set (Fin d → ℝ) :=
  {z | ∃ t ≤ (0 : ℝ), z = tropComb t x y} ∪
  {z | ∃ s ≤ (0 : ℝ), z = tropComb s y x}

/-- A set is **tropically convex** if it is closed under normalized tropical
    combinations: for any `x, y ∈ S` and `t ≤ 0`, the max-plus combination
    `fun i ↦ max (x i) (t + y i)` lies in `S`. -/
def IsTropConvex (S : Set (Fin d → ℝ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ t ≤ (0 : ℝ), tropComb t x y ∈ S

/-! ## Part 2: Tropical Convex Hull -/

/-- The **tropical convex hull** of a nonempty indexed family of points.
    `z` is in the hull iff there exist weights `w` such that
    `z i = max_k (w k + pts k i)` for every coordinate `i`. -/
def tropConvHull {n : ℕ} (pts : Fin (n + 1) → Fin d → ℝ) : Set (Fin d → ℝ) :=
  {z | ∃ w : Fin (n + 1) → ℝ, ∀ i : Fin d,
    z i = Finset.univ.sup' Finset.univ_nonempty (fun k => w k + pts k i)}

/-! ## Part 3: Tropical Box -/

/-- A **tropical box**: the product of closed intervals `[lo i, hi i]`. -/
def TropBox (lo hi : Fin d → ℝ) : Set (Fin d → ℝ) :=
  {x | ∀ i, lo i ≤ x i ∧ x i ≤ hi i}

/-! ## Part 4: Basic Structural Theorems -/

/-
Intersection of tropically convex sets is tropically convex.
-/
theorem isTropConvex_inter {S T : Set (Fin d → ℝ)}
    (hS : IsTropConvex S) (hT : IsTropConvex T) :
    IsTropConvex (S ∩ T) := by
  exact fun x hx y hy t ht => ⟨ hS x hx.1 y hy.1 t ht, hT x hx.2 y hy.2 t ht ⟩

/-
Arbitrary intersection of tropically convex sets is tropically convex.
-/
theorem isTropConvex_iInter {ι : Type*} {F : ι → Set (Fin d → ℝ)}
    (hF : ∀ i, IsTropConvex (F i)) :
    IsTropConvex (⋂ i, F i) := by
  intro x hx y hy t ht;
  aesop

/-
A tropical box is tropically convex. The key property:
    `max(x_i, t + y_i)` stays within `[lo_i, hi_i]` when `x, y` do and `t ≤ 0`.
-/
theorem box_isTropConvex (lo hi : Fin d → ℝ) :
    IsTropConvex (TropBox lo hi) := by
  intro x hx y hy t ht;
  exact fun i => ⟨ le_max_of_le_left ( hx i |>.1 ), max_le ( hx i |>.2 ) ( by linarith [ hy i |>.2 ] ) ⟩

/-! ## Part 5: Tropical Convex Hull is Tropically Convex -/

/-
**Theorem 1**: The tropical convex hull is tropically convex.

    Proof idea: if `z₁ = max_k(w₁_k + p_k)` and `z₂ = max_k(w₂_k + p_k)`,
    then `max(z₁, t + z₂) = max_k(max(w₁_k, t + w₂_k) + p_k)`,
    using the identity `max(max_k f(k), max_k g(k)) = max_k max(f(k), g(k))`.
-/
theorem tropConvHull_isTropConvex {n : ℕ} (pts : Fin (n + 1) → Fin d → ℝ) :
    IsTropConvex (tropConvHull pts) := by
  intro x;
  rintro ⟨ w₁, hw₁ ⟩ y ⟨ w₂, hw₂ ⟩ t ht;
  use fun k => Max.max ( w₁ k ) ( t + w₂ k ) ; simp +decide [ hw₁, hw₂, tropComb ] ;
  simp +decide [Finset.sup'_eq_csSup_image];
  intro i; rw [ eq_comm, csSup_eq_of_forall_le_of_forall_lt_exists_gt ] <;> norm_num;
  · exact range_nonempty fun x => max (w₁ x) (t + w₂ x) + pts x i;
  · intro k; cases max_cases ( w₁ k ) ( t + w₂ k ) <;> [ left; right ] <;> linarith [ le_csSup ( Set.finite_range ( fun k => w₁ k + pts k i ) |> Set.Finite.bddAbove ) ( Set.mem_range_self k ), le_csSup ( Set.finite_range ( fun k => w₂ k + pts k i ) |> Set.Finite.bddAbove ) ( Set.mem_range_self k ) ] ;
  · rintro w ( hw | hw );
    · rcases exists_lt_of_lt_csSup ( Set.range_nonempty _ ) hw with ⟨ a, ⟨ k, rfl ⟩, hk ⟩ ; exact ⟨ k, by cases max_cases ( w₁ k ) ( t + w₂ k ) <;> linarith ⟩;
    · contrapose! hw;
      rw [ add_comm, ← le_sub_iff_add_le ];
      exact csSup_le ( Set.nonempty_of_mem ( Set.mem_range_self 0 ) ) ( Set.forall_mem_range.mpr fun k => by linarith [ hw k, le_max_right ( w₁ k ) ( t + w₂ k ) ] )

/-! ## Part 6: Helly's Theorem for Intervals -/

/-
**Theorem 2 (Helly for intervals)**: If every pair of intervals has nonempty
    intersection (equivalently, `a i ≤ b j` for all `i, j`), then all intervals
    have a common point. The witness is `x = max_k (a k)`.

    This is the 1-dimensional Helly theorem with **Helly number 2**.
-/
theorem helly_intervals {n : ℕ} (a b : Fin n → ℝ)
    (hpair : ∀ i j, a i ≤ b j) :
    ∃ x : ℝ, ∀ k, a k ≤ x ∧ x ≤ b k := by
  by_cases hn : n = 0;
  · aesop;
  · exact ⟨ Finset.univ.sup' ⟨ ⟨ 0, Nat.pos_of_ne_zero hn ⟩, Finset.mem_univ _ ⟩ a, fun k => ⟨ Finset.le_sup' a ( Finset.mem_univ k ), Finset.sup'_le _ _ fun i _ => hpair i k ⟩ ⟩

/-! ## Part 7: Helly's Theorem for Tropical Boxes -/

/-
Auxiliary: pairwise box intersection implies coordinatewise bound compatibility.
-/
theorem pairwise_box_implies_coord {n : ℕ} (lo hi : Fin n → Fin d → ℝ)
    (hpair : ∀ p q : Fin n, ∃ x : Fin d → ℝ,
      (∀ i, lo p i ≤ x i ∧ x i ≤ hi p i) ∧
      (∀ i, lo q i ≤ x i ∧ x i ≤ hi q i))
    (i : Fin d) (p q : Fin n) : lo p i ≤ hi q i := by
  obtain ⟨ x, hx₁, hx₂ ⟩ := hpair p q; exact le_trans ( hx₁ i |>.1 ) ( hx₂ i |>.2 ) ;

/-
**Theorem 3 (Tropical Helly for boxes)**: For a finite family of boxes in `ℝ^d`,
    pairwise intersection implies global intersection.

    This is the tropical Helly theorem for the class of tropical boxes,
    with **Helly number 2**. The proof reduces to `helly_intervals` applied
    coordinatewise.
-/
theorem helly_boxes {n : ℕ} (lo hi : Fin n → Fin d → ℝ)
    (hpair : ∀ p q : Fin n, ∃ x : Fin d → ℝ,
      (∀ i, lo p i ≤ x i ∧ x i ≤ hi p i) ∧
      (∀ i, lo q i ≤ x i ∧ x i ≤ hi q i)) :
    ∃ x : Fin d → ℝ, ∀ k i, lo k i ≤ x i ∧ x i ≤ hi k i := by
  -- By induction on the number of coordinates, we can construct such a point.
  have h_ind : ∀ i : Fin d, ∃ x_i : ℝ, ∀ k : Fin n, lo k i ≤ x_i ∧ x_i ≤ hi k i := by
    intro i;
    convert helly_intervals ( fun k => lo k i ) ( fun k => hi k i ) _;
    exact fun p q => by obtain ⟨ x, hx₁, hx₂ ⟩ := hpair p q; linarith [ hx₁ i, hx₂ i ] ;
  exact ⟨ fun i => Classical.choose ( h_ind i ), fun k i => Classical.choose_spec ( h_ind i ) k ⟩

/-! ## Part 8: Feasibility Certificate Theorem -/

/-
**Theorem 4 (Tropical feasibility certificate)**: If a system of tropical box
    constraints is infeasible, then some **pair** of boxes is already infeasible.

    Equivalently: pairwise feasibility implies global feasibility.
    This is the **contrapositive** of `helly_boxes` and is the computational
    heart of the theory.

    *Optimization interpretation*: for coordinate-bound systems (scheduling,
    resource allocation), infeasibility can always be localized to two constraints.
    This gives an O(n²) certificate search for infeasibility.
-/
theorem tropical_feasibility_certificate {n : ℕ} (lo hi : Fin n → Fin d → ℝ)
    (hinfeas : ¬ ∃ x : Fin d → ℝ, ∀ k i, lo k i ≤ x i ∧ x i ≤ hi k i) :
    ∃ p q : Fin n, ¬ ∃ x : Fin d → ℝ,
      (∀ i, lo p i ≤ x i ∧ x i ≤ hi p i) ∧
      (∀ i, lo q i ≤ x i ∧ x i ≤ hi q i) := by
  contrapose! hinfeas;
  convert helly_boxes lo hi _;
  assumption

/-! ## Part 9: Conjecture and Computational Target -/

/-- **Conjecture**: For general tropically convex sets in `Fin d → ℝ`,
    the tropical Helly number is at most `2 * d`.
    Computationally tested in `demo.py` for `d ≤ 3`. -/
def tropicalHellyConjecture (d : ℕ) : Prop :=
  ∀ n : ℕ, ∀ F : Fin n → Set (Fin d → ℝ),
    (∀ i, IsTropConvex (F i)) →
    (∀ I : Finset (Fin n), I.card ≤ 2 * d →
      ∃ x : Fin d → ℝ, ∀ i ∈ I, x ∈ F i) →
    ∃ x : Fin d → ℝ, ∀ i, x ∈ F i

end TropicalHelly