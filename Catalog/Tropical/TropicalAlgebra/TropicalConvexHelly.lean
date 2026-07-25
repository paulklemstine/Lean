import Mathlib

/-! # Tropical Convexity and Helly's Theorem

We develop the theory of tropical convexity in ℝⁿ (max-plus convention) and prove
a tropical analogue of Helly's theorem.

## Main Results

1. **Tropical convex sets** are closed under arbitrary intersections.
2. **Tropical halfspaces** `{z : z i ≤ z j + c}` are tropically convex.
3. **Helly's theorem for intervals**: a finite family of closed intervals has
   non-empty intersection iff every pair does — the 1D tropical Helly theorem.
4. **Difference constraint solvability**: a cyclic system `x₁-x₂ ≤ c₁₂, x₂-x₃ ≤ c₂₃,
   x₃-x₁ ≤ c₃₁` has a solution iff `c₁₂ + c₂₃ + c₃₁ ≥ 0`.
5. **Tropical convex hull**: defined as the intersection of all tropically convex
   supersets, with containment and idempotency properties.
-/

noncomputable section
open Set Finset

namespace TropicalConvexity

/-! ## Section 1: Core Definitions -/

/-- A set S ⊆ ℝⁿ is tropically convex if it is closed under tropical linear
    combinations: for all x, y ∈ S and all a, b ∈ ℝ, the coordinatewise
    maximum `max(a + x_i, b + y_i)` belongs to S. -/
def IsTropConvex {n : ℕ} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ a b : ℝ,
    (fun i => max (a + x i) (b + y i)) ∈ S

/-- The tropical segment between x and y. -/
def tropSegment {n : ℕ} (x y : Fin n → ℝ) : Set (Fin n → ℝ) :=
  { z | ∃ a b : ℝ, z = fun i => max (a + x i) (b + y i) }

/-- A tropical halfspace: `{z : z i ≤ z j + c}`. -/
def tropHalfspace {n : ℕ} (i j : Fin n) (c : ℝ) : Set (Fin n → ℝ) :=
  { z | z i ≤ z j + c }

/-- The tropical convex hull of a set S. -/
def tropConvHull {n : ℕ} (S : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  ⋂₀ { T | IsTropConvex T ∧ S ⊆ T }

/-- A tropical polytope: the tropical convex hull of a finite set. -/
def TropicalPolytope {n : ℕ} (generators : Finset (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  tropConvHull (↑generators : Set (Fin n → ℝ))

/-! ## Section 2: Structural Theorems -/

/-
The intersection of any family of tropically convex sets is tropically convex.
-/
theorem isTropConvex_sInter {n : ℕ} {F : Set (Set (Fin n → ℝ))}
    (hF : ∀ S ∈ F, IsTropConvex S) :
    IsTropConvex (⋂₀ F) := by
  intro x hx y hy a b;
  exact fun S hS => hF S hS _ ( hx S hS ) _ ( hy S hS ) a b

/-- The whole space is tropically convex. -/
theorem isTropConvex_univ {n : ℕ} : IsTropConvex (Set.univ : Set (Fin n → ℝ)) :=
  fun _ _ _ _ _ _ => Set.mem_univ _

/-
Tropical halfspaces are tropically convex.

    Proof idea: if `z₁ i ≤ z₁ j + c` and `z₂ i ≤ z₂ j + c`, then for any `a, b`:
    `max(a + z₁ i, b + z₂ i) ≤ max(a + z₁ j, b + z₂ j) + c`
    because `a + z₁ i ≤ a + z₁ j + c ≤ max(...) + c` and similarly for `b`.
-/
theorem tropHalfspace_isTropConvex {n : ℕ} (i j : Fin n) (c : ℝ) :
    IsTropConvex (tropHalfspace i j c) := by
  grind +locals

/-
The left endpoint belongs to the tropical segment.
-/
theorem left_mem_tropSegment {n : ℕ} (x y : Fin n → ℝ) :
    x ∈ tropSegment x y := by
  by_contra! h_contra;
  obtain ⟨a, b, h⟩ : ∃ a b : ℝ, ∀ i, max (a + x i) (b + y i) = x i := by
    exact ⟨ 0, -1 + ( InfSet.sInf ( Set.range fun i => x i - y i ) ) - 1, fun i => by cases max_cases ( 0 + x i ) ( -1 + ( InfSet.sInf ( Set.range fun i => x i - y i ) ) - 1 + y i ) <;> linarith [ show InfSet.sInf ( Set.range fun i => x i - y i ) ≤ x i - y i from csInf_le ( by exact Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self _ ) ] ⟩;
  exact h_contra ⟨ a, b, funext fun i => by simp +decide [ h ] ⟩

/-
The right endpoint belongs to the tropical segment.
-/
theorem right_mem_tropSegment {n : ℕ} (x y : Fin n → ℝ) :
    y ∈ tropSegment x y := by
  -- To show that $y$ is in the tropical segment between $x$ and $y$, we can choose $a$ such that $a + x_i \leq y_i$ for all $i$ and $b = 0$.
  obtain ⟨a, ha⟩ : ∃ a : ℝ, ∀ i, a + x i ≤ y i := by
    exact ⟨ - ( ∑ i : Fin n, |x i| + ∑ i : Fin n, |y i| ), fun i => by cases abs_cases ( x i ) <;> cases abs_cases ( y i ) <;> linarith [ Finset.single_le_sum ( fun a _ => abs_nonneg ( x a ) ) ( Finset.mem_univ i ), Finset.single_le_sum ( fun a _ => abs_nonneg ( y a ) ) ( Finset.mem_univ i ) ] ⟩
  use a, 0
  simp [ha]

/-
A tropically convex set containing both endpoints contains the tropical segment.
-/
theorem tropSegment_subset_of_mem {n : ℕ} {S : Set (Fin n → ℝ)}
    (hS : IsTropConvex S) {x y : Fin n → ℝ} (hx : x ∈ S) (hy : y ∈ S) :
    tropSegment x y ⊆ S := by
  exact fun z => by rintro ⟨ a, b, rfl ⟩ ; exact hS x hx y hy a b;

/-
The tropical convex hull contains the original set.
-/
theorem subset_tropConvHull {n : ℕ} (S : Set (Fin n → ℝ)) :
    S ⊆ tropConvHull S := by
  exact Set.subset_sInter fun T hT => hT.2

/-
The tropical convex hull is tropically convex.
-/
theorem isTropConvex_tropConvHull {n : ℕ} (S : Set (Fin n → ℝ)) :
    IsTropConvex (tropConvHull S) := by
  exact isTropConvex_sInter fun T hT => hT.1

/-
The tropical convex hull is the smallest tropically convex superset.
-/
theorem tropConvHull_min {n : ℕ} {S T : Set (Fin n → ℝ)}
    (hT : IsTropConvex T) (hST : S ⊆ T) :
    tropConvHull S ⊆ T := by
  exact Set.sInter_subset_of_mem ⟨ hT, hST ⟩

/-
The tropical convex hull is idempotent.
-/
theorem tropConvHull_idempotent {n : ℕ} (S : Set (Fin n → ℝ)) :
    tropConvHull (tropConvHull S) = tropConvHull S := by
  apply le_antisymm;
  · exact tropConvHull_min ( isTropConvex_tropConvHull S ) ( by tauto );
  · exact subset_tropConvHull _

/-! ## Section 3: Helly's Theorem for Intervals -/

/-
**Helly's Theorem for Intervals**: A finite family of closed intervals
    `[a i, b i]` has non-empty intersection if every pair intersects.

    Proof: take `x = sup_i a_i`. For each `j`, we need `x ≤ b j`.
    Since `∀ i, a i ≤ b j` (pairwise condition), the supremum
    `sup_i a_i ≤ b j`. Also `a j ≤ x` since `x` is the supremum.
-/
theorem helly_intervals {ι : Type*} [Fintype ι] [Nonempty ι]
    (a b : ι → ℝ)
    (hpair : ∀ i j, a i ≤ b j) :
    ∃ x : ℝ, ∀ i, a i ≤ x ∧ x ≤ b i := by
  exact ⟨Finset.univ.sup' Finset.univ_nonempty a, fun i =>
    ⟨Finset.le_sup' _ (Finset.mem_univ _),
     Finset.sup'_le _ _ fun j _ => hpair j i⟩⟩

/-
Converse direction: a common point implies pairwise intersection.
-/
theorem helly_intervals_converse {ι : Type*}
    (a b : ι → ℝ)
    (hcommon : ∃ x : ℝ, ∀ i, a i ≤ x ∧ x ≤ b i) :
    ∀ i j, a i ≤ b j := by
  exact fun i j => le_trans ( hcommon.choose_spec i |>.1 ) ( hcommon.choose_spec j |>.2 )

/-
Full Helly characterization for intervals.
-/
theorem helly_intervals_iff {ι : Type*} [Fintype ι] [Nonempty ι]
    (a b : ι → ℝ) :
    (∃ x : ℝ, ∀ i, a i ≤ x ∧ x ≤ b i) ↔ (∀ i j, a i ≤ b j) := by
  refine ⟨fun ⟨x, hx⟩ i j => le_trans (hx i |>.1) (hx j |>.2),
         fun h => helly_intervals a b h⟩

/-! ## Section 4: Difference Constraints and Optimization -/

/-
**Two-variable difference constraint**: `x₁ - x₂ ≤ a ∧ x₂ - x₁ ≤ b`
    has a solution iff `a + b ≥ 0`.
-/
theorem two_var_diff_constraint (a b : ℝ) :
    (∃ x₁ x₂ : ℝ, x₁ - x₂ ≤ a ∧ x₂ - x₁ ≤ b) ↔ 0 ≤ a + b := by
  exact ⟨ fun ⟨ x₁, x₂, h₁, h₂ ⟩ => by linarith, fun h => ⟨ 0, -a, by linarith, by linarith ⟩ ⟩

/-
**Three-variable cycle condition**: the cyclic system
    `x₁ - x₂ ≤ c₁₂, x₂ - x₃ ≤ c₂₃, x₃ - x₁ ≤ c₃₁` has a solution
    iff the cycle weight `c₁₂ + c₂₃ + c₃₁ ≥ 0`.

    Forward: adding the three inequalities telescopes to `0 ≤ c₁₂ + c₂₃ + c₃₁`.
    Backward: set `x₁ = 0, x₂ = -c₁₂, x₃ = -(c₁₂ + c₂₃)` and verify.
-/
theorem three_var_cycle_condition (c₁₂ c₂₃ c₃₁ : ℝ) :
    (∃ x₁ x₂ x₃ : ℝ, x₁ - x₂ ≤ c₁₂ ∧ x₂ - x₃ ≤ c₂₃ ∧ x₃ - x₁ ≤ c₃₁) ↔
    0 ≤ c₁₂ + c₂₃ + c₃₁ := by
  exact ⟨ fun ⟨ x₁, x₂, x₃, h₁, h₂, h₃ ⟩ => by linarith, fun h => ⟨ 0, -c₁₂, - ( c₁₂ + c₂₃ ), by linarith, by linarith, by linarith ⟩ ⟩

/-
**Shortest-path solution**: If the cycle condition holds, then
    `x₁ = 0, x₂ = -c₁₂, x₃ = -(c₁₂ + c₂₃)` is a feasible solution.
-/
theorem shortest_path_solution (c₁₂ c₂₃ c₃₁ : ℝ) (h : 0 ≤ c₁₂ + c₂₃ + c₃₁) :
    (0 : ℝ) - (-c₁₂) ≤ c₁₂ ∧
    (-c₁₂) - (-(c₁₂ + c₂₃)) ≤ c₂₃ ∧
    (-(c₁₂ + c₂₃)) - 0 ≤ c₃₁ := by
  exact ⟨ by linarith, by linarith, by linarith ⟩

/-
Tropical halfspace intersection is nonempty iff the sum of bounds is non-negative.
-/
theorem tropHalfspace_inter_nonempty {n : ℕ} (i j : Fin n) (hij : i ≠ j) (a b : ℝ) :
    (tropHalfspace i j a ∩ tropHalfspace j i b).Nonempty ↔ 0 ≤ a + b := by
  constructor;
  · rintro ⟨ z, hz₁, hz₂ ⟩;
    linarith [ hz₁.out, hz₂.out ];
  · intro h
    use fun k => if k = i then 0 else if k = j then -a else 0
    simp [tropHalfspace];
    grind

/-! ## Section 5: Segment Characterization -/

/-
A set is tropically convex iff it contains the tropical segment between
    any two of its members.
-/
theorem isTropConvex_iff_segments {n : ℕ} (S : Set (Fin n → ℝ)) :
    IsTropConvex S ↔ ∀ x ∈ S, ∀ y ∈ S, tropSegment x y ⊆ S := by
  refine' ⟨ fun h x hx y hy z hz => _, fun h x hx y hy a b => _ ⟩;
  · obtain ⟨ a, b, rfl ⟩ := hz; exact h x hx y hy a b;
  · exact h x hx y hy ⟨ a, b, rfl ⟩

/-! ## Section 6: Conjecture -/

/-- **Conjecture (Tropical Helly, n=2)**: For tropically convex subsets of ℝ³
    the Helly number (modulo tropical scalar action) is 4. -/
def tropicalHellyConjecture_n2 : Prop :=
  ∀ (m : ℕ) (S : Fin m → Set (Fin 3 → ℝ)),
    (∀ i, IsTropConvex (S i)) →
    (∀ (I : Finset (Fin m)), I.card ≤ 4 → (⋂ i ∈ I, S i).Nonempty) →
    (⋂ i, S i).Nonempty

end TropicalConvexity