/-! # CatalogBuild.Logic.FixedPointFoundations

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 11
-/

import Mathlib

noncomputable section

/-- The pre-fixed points of a monotone function: the set of x with f(x) ≤ x.
The least fixed point will bootstrap itself into existence as the infimum
of this set. -/
def preFixedPoints {α : Type*} [Preorder α] (f : α → α) : Set α :=
  {x | f x ≤ x}

/-- The post-fixed points: x ≤ f(x). Dual to pre-fixed points. -/

def postFixedPoints {α : Type*} [Preorder α] (f : α → α) : Set α :=
  {x | x ≤ f x}

/-- **The Bootstrap Lemma**: In a complete lattice, the infimum of pre-fixed points
    of a monotone function is itself a pre-fixed point. This is the key self-referential
    step — the constructed object validates its own defining property. -/

theorem bootstrap_lemma {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : f (sInf (preFixedPoints f)) ≤ sInf (preFixedPoints f) := by
  refine le_sInf ?_
  exact fun x hx => le_trans (hf (sInf_le hx)) hx

/-- **Knaster-Tarski Fixed Point Theorem**: Every monotone function on a complete
    lattice has a least fixed point, equal to ⊓ {x | f(x) ≤ x}.
    The fixed point bootstraps itself into existence. -/

theorem knaster_tarski_lfp {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : f (sInf (preFixedPoints f)) = sInf (preFixedPoints f) := by
  refine le_antisymm (bootstrap_lemma hf) ?_
  exact sInf_le (hf (bootstrap_lemma hf))

/-- The greatest fixed point bootstraps dually: ⊔ {x | x ≤ f(x)} -/

theorem knaster_tarski_gfp {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : f (sSup (postFixedPoints f)) = sSup (postFixedPoints f) := by
  have h_sSup_le : sSup (postFixedPoints f) ≤ f (sSup (postFixedPoints f)) :=
    sSup_le fun x hx => hx.trans (hf (le_sSup hx))
  exact le_antisymm (le_sSup <| by aesop) h_sSup_le

/-- The least fixed point is indeed the least among all fixed points -/

theorem lfp_is_least {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) (x : α) (hx : f x = x) :
    sInf (preFixedPoints f) ≤ x :=
  sInf_le (by simp [preFixedPoints, hx])


/-- Each iteration is below the next for a monotone function: the chain ascends -/
theorem iterateBot_le_succ {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : ∀ n : ℕ, f^[n] ⊥ ≤ f^[n + 1] ⊥ := by
  intro n
  induction n <;> simp_all [Function.iterate_succ_apply']
  exact hf ‹_›


/-- A contraction on a metric space: d(f(x), f(y)) ≤ c · d(x, y) for c < 1 -/
def IsContraction {α : Type*} [PseudoMetricSpace α] (f : α → α) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ x y : α, dist (f x) (f y) ≤ c * dist x y

/-- A contraction has at most one fixed point — the bootstrap is unique -/

theorem contraction_unique_fixed_point {α : Type*} [MetricSpace α]
    {f : α → α} {c : ℝ} (hf : IsContraction f c)
    {x y : α} (hx : f x = x) (hy : f y = y) : x = y := by
  have h1 := hf.2.2 x y
  have h_zero : dist x y ≤ c * dist x y → dist x y = 0 :=
    fun h => le_antisymm (le_of_not_gt fun h' => by nlinarith [hf.1, hf.2.1]) dist_nonneg
  aesop


/-- Curry's fixed-point combinator, typed in Lean: for any f, we can find x with f x = x
in a complete lattice. This wraps Knaster-Tarski as a function. -/
noncomputable def fixedPointCombinator {α : Type*} [CompleteLattice α]
    (f : α → α) (_hf : Monotone f) : α :=
  sInf (preFixedPoints f)

/-- The combinator indeed produces a fixed point -/

theorem fixedPointCombinator_is_fixed {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) :
    f (fixedPointCombinator f hf) = fixedPointCombinator f hf :=
  knaster_tarski_lfp hf


end
