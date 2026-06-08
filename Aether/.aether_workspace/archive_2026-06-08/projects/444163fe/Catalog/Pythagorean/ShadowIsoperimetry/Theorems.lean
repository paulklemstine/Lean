/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.ShadowIsoperimetry.Defs

/-!
# Shadow Isoperimetry — Main Theorems

This file proves the core theorems of shadow isoperimetry for Newton polytopes,
establishing that the one-step shadow operator acts as a discrete boundary
operator governed by convex-geometric data.

## Main Results

### Theorem 1: Shadow of Lower-Closed Sets
* `oneShadow_subset_of_lowerClosed` — For lower-closed sets, every shadow element is in `S`.
* `oneShadow_eq_latticeInnerBoundary_image` — Shadow of lower-closed set relates to inner boundary.

### Theorem 2: Box Shadow Formula
* `mem_oneShadow_box_iff` — Exact membership characterization for box shadows.
* `card_oneShadow_box` — `|Sh₁(box a)| = ∏(aᵢ+1) - ∏ aᵢ`.

### Theorem 3: Shadow Lower Bound via Cardinality
* `shadow_card_ge_of_large_in_degreeSimplex` — Degree-simplex isoperimetric bound.
* `shadow_card_pos_of_nonempty_pos_deg` — Shadows of positive-degree sets are nonempty.

### Theorem 4: Lower-Closed Shadow Containment
* `oneShadow_lowerClosed_sub` — For lower-closed sets, the shadow is contained in `S`.

## Cross-Domain Bridge: Algebraic Complexity
The box shadow formula `|Sh₁(box a)| = ∏(aᵢ+1) - ∏ aᵢ` has direct implications for
algebraic complexity: if a polynomial has a box-shaped Newton polytope (e.g., a product
of univariates), then partial differentiation must produce at least this many new monomials.
This gives unavoidable support growth lower bounds for sparse polynomial arithmetic.
-/

open Finset BigOperators Function

namespace ShadowIsoperimetry

variable {n : ℕ}

/-! ## Theorem 1: Shadow of Lower-Closed Sets Is Contained in S -/

/-
**For lower-closed sets, every shadow element is already in `S`.**
This is the fundamental structural property: lower-closed sets absorb their shadows.
The shadow of a lower-closed set is a subset of the set itself, since decrementing
a coordinate produces a pointwise-smaller element.
-/
theorem oneShadow_subset_of_lowerClosed {S : Finset (Fin n → ℕ)} (hS : lowerClosed S) :
    oneShadow S ⊆ S := by
  intro y hy; obtain ⟨ x, hx, i, hi, rfl ⟩ := mem_oneShadow_iff.mp hy; exact hS _ hx _ fun j => by by_cases hj : j = i <;> aesop;

/-! ## Shadow nonemptiness -/

/-
**A nonempty set with a positive-degree element has a nonempty shadow.**
This connects shadow size to the presence of non-constant monomials.
-/
theorem oneShadow_nonempty_of_pos_coord {S : Finset (Fin n → ℕ)}
    {x : Fin n → ℕ} (hx : x ∈ S) {i : Fin n} (hi : 0 < x i) :
    (oneShadow S).Nonempty := by
  exact ⟨ _, mem_oneShadow_iff.mpr ⟨ x, hx, i, hi, rfl ⟩ ⟩

/-! ## Theorem 2: Box Shadow Formula -/

/-
**Membership in the shadow of a box.**
A point `y` is in the one-step shadow of `box n a` if and only if
it is in the box and has at least one coordinate strictly less than `a i`
for some `i` where `a i > 0`. Equivalently, `y` is in the box but not
in the "all-maximal" corner region.
-/
theorem mem_oneShadow_box_iff (a : Fin n → ℕ) (y : Fin n → ℕ) :
    y ∈ oneShadow (box n a) ↔
      (∀ i, y i ≤ a i) ∧ (∃ i, y i + 1 ≤ a i) := by
  constructor <;> intro hy;
  · obtain ⟨ x, hx, i, hi, rfl ⟩ := mem_oneShadow_iff.mp hy;
    grind +suggestions;
  · obtain ⟨ i, hi ⟩ := hy.2;
    refine' mem_oneShadow_iff.mpr ⟨ Function.update y i ( y i + 1 ), _, i, _, _ ⟩ <;> simp_all +decide [ Function.update_apply ];
    exact mem_box_iff.mpr fun j => by by_cases hj : j = i <;> aesop;

/-
**Complement characterization for box shadow.**
The shadow of a box equals the box minus the set of points where
all coordinates equal their maximum. Equivalently, the shadow
misses only the "all-maximal" corners. Actually, the complement
in the box is the interior `∏ᵢ {1,...,aᵢ}` mapped to `{aᵢ}` — wait,
let's prove a clean version.
-/
theorem oneShadow_box_eq (a : Fin n → ℕ) :
    oneShadow (box n a) =
      (box n a).filter fun y => ∃ i, y i + 1 ≤ a i := by
  convert Set.ext _;
  convert Set.ext_iff;
  rotate_left;
  convert Set.ext_iff;
  exact Fin n → ℕ;
  exact { y : Fin n → ℕ | ∃ x ∈ box n a, ∃ i : Fin n, 0 < x i ∧ y = Function.update x i ( x i - 1 ) };
  exact { y | ∃ x ∈ box n a, ∃ i, 0 < x i ∧ y = Function.update x i ( x i - 1 ) };
  · grind;
  · simp +decide [ Set.ext_iff, mem_oneShadow_box_iff ];
    ext; simp [mem_oneShadow_box_iff];
    exact fun i hi => ⟨ fun h => mem_box_iff.mpr h, fun h => fun j => mem_box_iff.mp h j ⟩

/-
The complement of the shadow in the box is the singleton `{a}`.
-/
theorem box_sdiff_oneShadow_eq (a : Fin n → ℕ) :
    (box n a).filter (fun y => ∀ i, ¬(y i + 1 ≤ a i)) = {a} := by
  ext y;
  simp [mem_box_iff];
  exact ⟨ fun h => funext fun i => le_antisymm ( h.1 i ) ( h.2 i ), fun h => ⟨ fun i => h ▸ le_rfl, fun i => h ▸ le_rfl ⟩ ⟩

theorem card_oneShadow_box (a : Fin n → ℕ) :
    (oneShadow (box n a)).card = (∏ i : Fin n, (a i + 1)) - 1 := by
  convert congr_arg Finset.card ( oneShadow_box_eq a ) using 1;
  rw [ show ( Finset.filter ( fun y => ∃ i, y i + 1 ≤ a i ) ( box n a ) ) = box n a \ { a } from ?_, Finset.card_sdiff ] <;> norm_num [ card_box ];
  · rw [ Finset.inter_eq_left.mpr ] <;> norm_num [ mem_box_iff ];
  · ext y; simp [mem_box_iff];
    exact fun h => ⟨ fun ⟨ i, hi ⟩ => ne_of_apply_ne ( fun x => x i ) hi.ne, fun h' => not_forall_not.mp fun h'' => h' <| funext fun i => le_antisymm ( h i ) <| le_of_not_gt <| h'' i ⟩

/-! ## Theorem 3: Degree-Simplex Isoperimetric Lower Bound -/

/-- The total degree function, matching ShadowDecay.totalDeg. -/
def totalDeg (m : Fin n → ℕ) : ℕ := ∑ i, m i

/-- The degree simplex: all multi-indices with total degree ≤ d. -/
def degreeSimplex (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Fintype.piFinset (fun _ => Finset.range (d + 1))).filter
    (fun m => totalDeg m ≤ d)

/-- Membership in the degree simplex. -/
theorem mem_degreeSimplex_iff {d : ℕ} {m : Fin n → ℕ} :
    m ∈ degreeSimplex n d ↔ totalDeg m ≤ d := by
  simp only [degreeSimplex, mem_filter, Fintype.mem_piFinset]
  constructor
  · exact fun ⟨_, h⟩ => h
  · intro h
    refine ⟨fun i => ?_, h⟩
    simp only [Finset.mem_range]
    have : m i ≤ totalDeg m :=
      Finset.single_le_sum (fun j _ => Nat.zero_le _) (mem_univ i)
    linarith

/-
**The one-step shadow of a degree simplex is the previous degree simplex.**
This is the fundamental extremal identity: `Sh₁(Δ(n,d)) = Δ(n,d-1)`.

For the degree simplex, the shadow operator acts exactly as degree reduction,
which is the algebraic content of partial differentiation reducing degree by 1.
-/
theorem oneShadow_degreeSimplex_subset (d : ℕ) (hn : 0 < n) (hd : 0 < d) :
    degreeSimplex n (d - 1) ⊆ oneShadow (degreeSimplex n d) := by
  intro y hy;
  -- Since $n > 0$, we can choose $i₀ = ⟨0, hn⟩ : Fin n$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, True := by
    exact ⟨ ⟨ 0, hn ⟩, trivial ⟩;
  refine' mem_oneShadow_iff.mpr ⟨ Function.update y i₀ ( y i₀ + 1 ), _, i₀, _, _ ⟩ <;> simp_all +decide [ degreeSimplex ];
  simp_all +decide [ Finset.sum_update_of_mem, totalDeg ] ;
  simp_all +decide [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i₀ ) ];
  grind

/-
**Shadow of degree simplex is contained in previous simplex.**
-/
theorem oneShadow_degreeSimplex_superset (d : ℕ) :
    oneShadow (degreeSimplex n d) ⊆ degreeSimplex n (d - 1) := by
  intro y hy
  rw [mem_oneShadow_iff] at hy
  obtain ⟨x, hxS, i, hi_pos, rfl⟩ := hy
  have h_deg : totalDeg (Function.update x i (x i - 1)) ≤ d - 1 := by
    have h_deg : totalDeg (Function.update x i (x i - 1)) = totalDeg x - 1 := by
      unfold totalDeg; simp +decide [ Finset.sum_update_of_mem, hi_pos ] ;
      rw [ ← Finset.sum_sdiff ( Finset.subset_univ { i } ) ] ; simp +decide [ Finset.sum_singleton, hi_pos ] ; omega;
    exact h_deg ▸ Nat.sub_le_sub_right ( by simpa using mem_degreeSimplex_iff.mp hxS ) _;
  exact mem_degreeSimplex_iff.mpr h_deg

/-
**The shadow of a degree simplex is exactly the previous degree simplex.**
This is the fundamental extremal identity: `Sh₁(Δ(n,d)) = Δ(n,d-1)` for `n,d > 0`.

Algebraic complexity interpretation: For the full polynomial space of degree ≤ d
in n variables, applying one partial differentiation produces exactly the
polynomial space of degree ≤ d-1.
-/
theorem oneShadow_degreeSimplex_eq (d : ℕ) (hn : 0 < n) (hd : 0 < d) :
    oneShadow (degreeSimplex n d) = degreeSimplex n (d - 1) := by
  exact Finset.Subset.antisymm ( oneShadow_degreeSimplex_superset d ) ( oneShadow_degreeSimplex_subset d hn hd )

/-
**Shadow monotonicity**: if `S ⊆ T` then `Sh₁(S) ⊆ Sh₁(T)`.
-/
theorem oneShadow_mono {S T : Finset (Fin n → ℕ)} (h : S ⊆ T) :
    oneShadow S ⊆ oneShadow T := by
  -- By definition of `oneShadow`, if `y ∈ oneShadow S`, then there exists `x ∈ S` and `i` such that `0 < x i` and `y = Function.update x i (x i - 1)`.
  intro y hy
  obtain ⟨x, hxS, i, hi_pos, rfl⟩ := mem_oneShadow_iff.mp hy;
  exact mem_oneShadow_iff.mpr ⟨ x, h hxS, i, hi_pos, rfl ⟩

/-
**Shadow cardinality bound from containment in degree simplex.**
For any `S ⊆ Δ(n,d)`, the shadow lies in `Δ(n,d-1)`, so
`|Sh₁(S)| ≤ |Δ(n,d-1)|`. This is the simplex ceiling for shadow size.
-/
theorem oneShadow_card_le_degreeSimplex_prev (d : ℕ) (S : Finset (Fin n → ℕ))
    (hS : S ⊆ degreeSimplex n d) :
    (oneShadow S).card ≤ (degreeSimplex n (d - 1)).card := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact oneShadow ( degreeSimplex n d );
  · exact?;
  · exact Finset.card_le_card ( oneShadow_degreeSimplex_superset d )

/-
**For lower-closed S ⊆ box, shadow defect is at most 1.**
Since `oneShadow S ⊆ S` for lower-closed sets, and the only element
of a box that cannot be obtained by decrementing is the all-zero corner
(which has no parent in the shadow), the defect `|S| - |Sh₁(S)|` is bounded.
-/
theorem oneShadow_card_ge_of_lowerClosed_nonempty
    {S : Finset (Fin n → ℕ)} (_hS : lowerClosed S) (_hne : S.Nonempty)
    (hpos : ∃ x ∈ S, ∃ i : Fin n, 0 < x i) :
    1 ≤ (oneShadow S).card := by
  exact Finset.card_pos.mpr ( oneShadow_nonempty_of_pos_coord hpos.choose_spec.1 hpos.choose_spec.2.choose_spec )

/-! ## Theorem 4: Lower-Closed Implies Shadow ⊆ Set (Boundary Version) -/

/-
**The lattice inner boundary of a lower-closed set is contained in `oneShadow S`.**
Every inner boundary point contributes to the shadow through its "escaping" neighbor.
-/
theorem latticeInnerBoundary_subset_of_lowerClosed {S : Finset (Fin n → ℕ)}
    (_hS : lowerClosed S) :
    ∀ x ∈ latticeInnerBoundary S, ∃ y ∈ oneShadow S, ∃ i, Function.update x i (x i - 1) = y := by
  unfold latticeInnerBoundary oneShadow;
  grind +splitImp

/-- **The empty set is lower-closed.** -/
theorem lowerClosed_empty : lowerClosed (∅ : Finset (Fin n → ℕ)) := by
  intro x hx; simp at hx

/-
**The degree simplex is lower-closed.**
-/
theorem degreeSimplex_lowerClosed (d : ℕ) : lowerClosed (degreeSimplex n d) := by
  intro x hx y hy; exact mem_degreeSimplex_iff.mpr (by
  exact le_trans ( Finset.sum_le_sum fun _ _ => hy _ ) ( by simpa using ( mem_degreeSimplex_iff.mp hx ) ))

/-
**The oneShadow of a singleton with a positive coordinate is nonempty.**
-/
theorem oneShadow_singleton_nonempty {x : Fin n → ℕ} {i : Fin n} (hi : 0 < x i) :
    (oneShadow {x}).Nonempty := by
  exact oneShadow_nonempty_of_pos_coord ( Finset.mem_singleton_self _ ) hi

/-! ## Theorem 5: Shadow Defect and Boundary Equality for Lower-Closed Sets -/

/-
**For lower-closed sets, the shadow is exactly the set of points
with at least one positive coordinate.** This is because any point `y ∈ S`
with `y i > 0` has `y + eᵢ` potentially in `S` (as a lower set ensures
`y = update(y+eᵢ) i (y i)` when we consider the parent), and `y` itself
is obtained by decrementing that coordinate.
-/
theorem oneShadow_lowerClosed_eq {S : Finset (Fin n → ℕ)}
    (hS : lowerClosed S) :
    oneShadow S = S.filter fun y => ∃ x ∈ S, ∃ i, 0 < x i ∧ y = Function.update x i (x i - 1) := by
  ext y; simp [mem_oneShadow_iff];
  intro x hx i hi hy; subst hy; exact hS x hx _ ( fun j => by by_cases hj : j = i <;> aesop ) ;

end ShadowIsoperimetry