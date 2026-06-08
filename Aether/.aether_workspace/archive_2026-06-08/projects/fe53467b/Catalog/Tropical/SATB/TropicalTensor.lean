import Mathlib

/-!
# Tropical Tensor Products and Finite Minimization

This module formalizes the core tropical (min-plus) algebra theorems for finite
product-space optimization:

1. **Product-space minimization** (`tropMin_prod`): The minimum of a function
   over a product `α × β` equals the iterated minimum `min_a min_b f(a,b)`.

2. **Tropical tensor additive theorem** (`tropMin_tropTensor`): For independent
   cost functions `f : α → ℝ` and `g : β → ℝ`, the minimum of their tropical
   tensor product `(a,b) ↦ f(a) + g(b)` equals `min f + min g`.

These are the finite exactness theorems behind Bellman elimination and
factorized energy minimization in tropical algebra.
-/

open Finset BigOperators

noncomputable section

/-- The tropical minimum of a real-valued function over a finite nonempty type.
    This is `inf` in the min-plus semiring. -/
def tropMin {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty f

/-- The tropical tensor product of two cost functions: pointwise addition. -/
def tropTensor {α β : Type*} (f : α → ℝ) (g : β → ℝ) : α × β → ℝ
  | (a, b) => f a + g b

variable {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]

/-- `tropMin` is a lower bound: it is at most `f a` for every `a`. -/
theorem tropMin_le (f : α → ℝ) (a : α) : tropMin f ≤ f a :=
  Finset.inf'_le _ (Finset.mem_univ a)

/-- `tropMin` is the greatest lower bound. -/
theorem le_tropMin (f : α → ℝ) (c : ℝ) (h : ∀ a, c ≤ f a) : c ≤ tropMin f :=
  Finset.le_inf' _ _ (fun a _ => h a)

/-
The minimum is attained: there exists `a` with `f a = tropMin f`.
-/
theorem tropMin_exists (f : α → ℝ) : ∃ a, f a = tropMin f := by
  have h_inf : Finset.inf' Finset.univ Finset.univ_nonempty f ∈ Finset.image f Finset.univ := by
    convert Finset.min'_mem ( Finset.image f Finset.univ ) _;
    all_goals norm_num [ Finset.min' ];
  aesop

/-
**Theorem A: Product-space minimization.**
    The minimum over a product type equals the iterated minimum.
    This is the formal core of variable elimination in dynamic programming.
-/
theorem tropMin_prod (f : α × β → ℝ) :
    tropMin f = tropMin (fun a => tropMin (fun b => f (a, b))) := by
  refine' le_antisymm ( _ : _ ≤ _ ) ( _ : _ ≥ _ );
  · -- By definition of tropMin, we know that for any a, tropMin (fun b => f (a, b)) ≥ tropMin f.
    have h_le : ∀ a, tropMin (fun b => f (a, b)) ≥ tropMin f := by
      exact fun a => le_tropMin _ _ fun b => tropMin_le _ _;
    exact le_tropMin _ _ h_le;
  · refine' le_tropMin _ _ _;
    exact fun ⟨ a, b ⟩ => le_trans ( tropMin_le _ _ ) ( tropMin_le _ _ )

/-
**Theorem B: Tropical tensor additive theorem.**
    For independent costs, `min_{a,b} (f(a) + g(b)) = min_a f(a) + min_b g(b)`.
-/
theorem tropMin_tropTensor (f : α → ℝ) (g : β → ℝ) :
    tropMin (tropTensor f g) = tropMin f + tropMin g := by
  convert tropMin_prod ( fun p : α × β => f p.1 + g p.2 );
  refine' le_antisymm _ _;
  · refine' le_tropMin _ _ fun a => _;
    exact Finset.le_inf' _ _ fun b _ => add_le_add ( tropMin_le _ _ ) ( tropMin_le _ _ );
  · obtain ⟨ a, ha ⟩ := tropMin_exists f;
    refine' le_trans ( Finset.inf'_le _ ( Finset.mem_univ a ) ) _;
    exact le_trans ( tropMin_le _ ( Classical.choose ( tropMin_exists g ) ) ) ( by simp +decide [ ha, Classical.choose_spec ( tropMin_exists g ) ] )

/-
There exists an optimal pair for any function on a product space.
-/
theorem exists_argmin_prod (f : α × β → ℝ) :
    ∃ a b, ∀ x : α × β, f (a, b) ≤ f x := by
  exact Exists.elim ( Finset.exists_min_image Finset.univ ( fun x => f x ) ( Finset.univ_nonempty ) ) fun x hx => ⟨ x.1, x.2, fun y => hx.2 y ( Finset.mem_univ y ) ⟩

/-
There exists an optimal pair for a tropical tensor product.
-/
theorem exists_argmin_tropTensor (f : α → ℝ) (g : β → ℝ) :
    ∃ a b, ∀ x : α × β, tropTensor f g (a, b) ≤ tropTensor f g x := by
  -- Use the fact that there exists an optimal pair for the tropical tensor product.
  apply exists_argmin_prod

end