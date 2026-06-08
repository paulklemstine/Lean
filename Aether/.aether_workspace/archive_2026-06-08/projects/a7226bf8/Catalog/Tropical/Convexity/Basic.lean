import Mathlib

/-!
# Tropical Convexity: Basic Definitions and Algebra

This file establishes the foundational definitions and algebraic properties
for tropical convexity over the max-plus semiring on `ℝ`.

## Main definitions

* `tscale` — tropical scalar multiplication: `(a •ₜ x) i = a + x i`
* `tadd` — tropical addition (pointwise max): `(x ⊕ₜ y) i = max (x i) (y i)`
* `IsTropConvex` — predicate for tropically convex sets
* `TropConvHull` — tropical convex hull of a finite family of generators

## Main results

* `tadd_comm`, `tadd_assoc`, `tadd_idem` — tropical addition is a commutative,
  associative, idempotent operation
* `tscale_tscale` — tropical scalar multiplication composes additively
* `tscale_tadd_distrib` — tropical scaling distributes over tropical addition
* `tropConvHull_isTropConvex` — the tropical convex hull is tropically convex

## References

* Develin, M. and Sturmfels, B., "Tropical Convexity", 2004
* Gaubert, S. and Katz, R., "The Minkowski Theorem for Max-Plus Convex Sets", 2007
-/

open Finset

noncomputable section

/-! ### Basic tropical operations on vectors -/

/-- Tropical scalar multiplication: adds a constant to every coordinate. -/
def tscale {n : ℕ} (a : ℝ) (x : Fin n → ℝ) : Fin n → ℝ := fun i => a + x i

/-- Tropical addition: pointwise maximum. -/
def tadd {n : ℕ} (x y : Fin n → ℝ) : Fin n → ℝ := fun i => max (x i) (y i)

/-! ### Algebraic properties of tropical operations -/

@[simp]
theorem tadd_comm {n : ℕ} (x y : Fin n → ℝ) : tadd x y = tadd y x := by
  funext i; simp [tadd, max_comm]

@[simp]
theorem tadd_assoc {n : ℕ} (x y z : Fin n → ℝ) :
    tadd (tadd x y) z = tadd x (tadd y z) := by
  funext i; simp [tadd, max_assoc]

/-- Tropical addition is idempotent: `max(x, x) = x`. -/
@[simp]
theorem tadd_idem {n : ℕ} (x : Fin n → ℝ) : tadd x x = x := by
  funext i; simp [tadd]

/-- Tropical scalar multiplication composes additively. -/
theorem tscale_tscale {n : ℕ} (a b : ℝ) (x : Fin n → ℝ) :
    tscale a (tscale b x) = tscale (a + b) x := by
  funext i; simp [tscale, add_assoc]

/-- Tropical scaling distributes over tropical addition. -/
theorem tscale_tadd_distrib {n : ℕ} (a : ℝ) (x y : Fin n → ℝ) :
    tscale a (tadd x y) = tadd (tscale a x) (tscale a y) := by
  funext i; simp [tscale, tadd]; exact (max_add_add_left a (x i) (y i)).symm

/-- Scaling by zero is the identity. -/
@[simp]
theorem tscale_zero {n : ℕ} (x : Fin n → ℝ) : tscale 0 x = x := by
  funext i; simp [tscale]

/-! ### Tropical convexity -/

/-- A set `C` of tropical vectors is tropically convex if for any two points in `C`,
    every normalized tropical convex combination lies in `C`. -/
def IsTropConvex {n : ℕ} (C : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ C → y ∈ C →
    ∀ a b : ℝ, max a b = 0 →
      tadd (tscale a x) (tscale b y) ∈ C

/-- The tropical convex hull of a finite family `V` of generators. A point `x` is in
    the hull if it can be written as `x i = max_j (λ j + V j i)` with `max_j λ j = 0`.

    We require `m ≥ 1` (at least one generator) for the sup to be well-defined. -/
def TropConvHull {n m : ℕ} [NeZero m] (V : Fin m → Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | ∃ lam : Fin m → ℝ,
      (∀ i, x i = Finset.univ.sup' univ_nonempty (fun j : Fin m => lam j + V j i)) ∧
      Finset.univ.sup' univ_nonempty lam = 0}

/-! ### The tropical convex hull is tropically convex -/

/-
**Main theorem**: The tropical convex hull of any finite family of generators
    is a tropically convex set.
-/
theorem tropConvHull_isTropConvex {n m : ℕ} [NeZero m] (V : Fin m → Fin n → ℝ) :
    IsTropConvex (TropConvHull V) := by
  -- Let's choose any two points $x$ and $y$ in the tropical convex hull of $V$.
  intro x y hx hy a b hab;
  obtain ⟨lam_x, hx_lam, hx_sup⟩ := hx;
  obtain ⟨lam_y, hy_lam, hy_sup⟩ := hy;
  use fun j => max (a + lam_x j) (b + lam_y j); (
  unfold tadd tscale; simp_all +decide [ max_add_add_right ] ;
  constructor;
  · intro i; simp +decide [ Finset.sup'_eq_csSup_image, add_assoc ] ;
    rw [ eq_comm, csSup_eq_of_forall_le_of_forall_lt_exists_gt ];
    · exact ⟨ _, ⟨ ⟨ 0, NeZero.pos m ⟩, rfl ⟩ ⟩;
    · simp +zetaDelta at *;
      intro j; cases max_cases ( a + lam_x j ) ( b + lam_y j ) <;> [ left; right ] <;> linarith [ le_csSup ( Set.finite_range ( fun j => lam_x j + V j i ) |> Set.Finite.bddAbove ) ( Set.mem_range_self j ), le_csSup ( Set.finite_range ( fun j => lam_y j + V j i ) |> Set.Finite.bddAbove ) ( Set.mem_range_self j ) ] ;
    · intro w hw; contrapose! hw; simp_all +decide [ Finset.sup'_eq_csSup_image ] ;
      constructor <;> rw [ add_comm, ← le_sub_iff_add_le ];
      · exact csSup_le ( Set.nonempty_of_mem ( Set.mem_range_self ⟨ 0, NeZero.pos m ⟩ ) ) ( Set.forall_mem_range.mpr fun j => by linarith [ hw j, le_max_left ( a + lam_x j ) ( b + lam_y j ), le_max_right ( a + lam_x j ) ( b + lam_y j ) ] );
      · exact csSup_le ( Set.nonempty_of_mem ( Set.mem_range_self ⟨ 0, NeZero.pos m ⟩ ) ) ( Set.forall_mem_range.mpr fun j => by linarith [ hw j, le_max_right ( a + lam_x j ) ( b + lam_y j ) ] );
  · refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
    · exact fun i => ⟨ by cases max_cases a b <;> linarith [ show lam_x i ≤ 0 from hx_sup ▸ Finset.le_sup' ( fun j => lam_x j ) ( Finset.mem_univ i ) ], by cases max_cases a b <;> linarith [ show lam_y i ≤ 0 from hy_sup ▸ Finset.le_sup' ( fun j => lam_y j ) ( Finset.mem_univ i ) ] ⟩;
    · simp_all +decide [ Finset.sup'_eq_csSup_image ];
      cases max_cases a b <;> simp_all +decide [ add_eq_zero_iff_eq_neg ];
      · contrapose! hx_sup;
        -- Since $lam_x j < 0$ for all $j$, the supremum of the range of $lam_x$ is also negative.
        have h_sup_neg : sSup (Set.range lam_x) < 0 := by
          have h_sup_neg : ∃ j, lam_x j = sSup (Set.range lam_x) := by
            exact ( IsCompact.sSup_mem ( Set.finite_range lam_x |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| ⟨ 0, NeZero.pos m ⟩ );
          exact h_sup_neg.choose_spec ▸ hx_sup _ |>.1;
        linarith;
      · exact by rcases ( show ∃ j, lam_y j = 0 from by simpa [ hy_sup ] using ( IsCompact.sSup_mem ( Set.finite_range lam_y |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| ⟨ 0, NeZero.pos m ⟩ ) ) with ⟨ j, hj ⟩ ; exact ⟨ j, Or.inr <| by linarith ⟩ ;)

end