import Mathlib

/-! # Guarded Order-Theoretic Fixed-Point Theory

This file develops the order-theoretic core for guarded fixed-point semantics.
We define a `GuardedOrder` class capturing ω-chain complete partial orders with
bottom, prove that monotone ω-continuous endomorphisms have least fixed points
via Kleene iteration, and establish uniqueness of such fixed points.

## Main definitions

* `GuardedOrder` — an ω-chain complete partial order with bottom element and
  explicit ω-supremum operation
* `DelayOperator` — a monotone "delay" / "guard" endomorphism modeling the
  productive guard in temporal feedback
* `guardedIterate` — the Kleene iteration chain F^n(⊥)
* `guardedLfp` — the least fixed point as the ω-supremum of the iteration chain
* `OmegaContinuous` — ω-continuity of an endomorphism

## Main results

* `guardedIterate_mono` — the iteration chain is monotone
* `guardedLfp_fixed` — the ω-sup is a fixed point under monotonicity + ω-continuity
* `guardedLfp_least_fixed` — it is the least fixed point
* `guarded_fixedpoint_unique` — uniqueness among least fixed points
* `omegaSup_iterate_succ` — shifted-supremum invariance
-/

universe u v

/-! ## Guarded Order Structure -/

/-- An ω-chain complete partial order with bottom and explicit ω-supremum.
This provides the semantic domain for guarded fixed-point iteration. -/
class GuardedOrder (α : Type u) extends PartialOrder α, OrderBot α where
  /-- The supremum of an ω-chain (monotone sequence indexed by ℕ). -/
  omegaSup : (ℕ → α) → α
  /-- Every element of the chain is below the supremum. -/
  le_omegaSup : ∀ (s : ℕ → α), ∀ n, s n ≤ omegaSup s
  /-- The supremum is the least upper bound. -/
  omegaSup_le : ∀ (s : ℕ → α) (a : α), (∀ n, s n ≤ a) → omegaSup s ≤ a

/-- A delay (guard) operator modeling the productive delay in temporal feedback loops. -/
class DelayOperator (α : Type u) [PartialOrder α] where
  /-- The delay map. -/
  delay : α → α
  /-- Delay is monotone. -/
  monotone_delay : Monotone delay

/-! ## Guarded Iteration -/

/-- The Kleene iteration chain: `guardedIterate F n = F^n(⊥)`. -/
def guardedIterate {α : Type u} [PartialOrder α] [OrderBot α] (F : α → α) : ℕ → α
  | 0 => ⊥
  | n + 1 => F (guardedIterate F n)

/-- The candidate least fixed point: the ω-supremum of the iteration chain. -/
noncomputable def guardedLfp {α : Type u} [GuardedOrder α] (F : α → α) : α :=
  GuardedOrder.omegaSup (guardedIterate F)

/-! ## ω-Continuity -/

/-- An endomorphism is ω-continuous if it preserves ω-suprema of monotone chains,
in the sense that `F(sup s) ≤ sup (F ∘ s)`. Combined with monotonicity this
gives equality. -/
def OmegaContinuous {α : Type u} [GuardedOrder α] (F : α → α) : Prop :=
  ∀ s : ℕ → α, Monotone s →
    F (GuardedOrder.omegaSup s) ≤ GuardedOrder.omegaSup (fun n => F (s n))

/-! ## Core Lemmas -/

/-
The iteration chain is monotone for monotone F.
-/
theorem guardedIterate_mono
    {α : Type u} [GuardedOrder α]
    {F : α → α} (hF : Monotone F) :
    Monotone (guardedIterate F) := by
  apply_rules [ monotone_nat_of_le_succ ];
  intro n;
  induction' n with n ih;
  · convert bot_le;
  · exact hF ih

/-- Each iterate is below the ω-supremum. -/
theorem guardedIterate_le_omegaSup
    {α : Type u} [GuardedOrder α]
    {F : α → α} (n : ℕ) :
    guardedIterate F n ≤ guardedLfp F :=
  GuardedOrder.le_omegaSup _ n

/-
Shifted-supremum invariance: `sup_{n} F^{n+1}(⊥) = sup_{n} F^n(⊥)`.
-/
theorem omegaSup_iterate_succ
    {α : Type u} [GuardedOrder α]
    {F : α → α} (hmono : Monotone F) :
    GuardedOrder.omegaSup (fun n => guardedIterate F (n + 1)) =
    GuardedOrder.omegaSup (guardedIterate F) := by
  cases' ‹GuardedOrder α› with _ _ omegaSup le_omegaSup omegaSup_le;
  refine' le_antisymm ( omegaSup_le _ _ fun n => _ ) ( omegaSup_le _ _ fun n => _ );
  · exact le_omegaSup _ _;
  · induction' n with n ih;
    · exact bot_le;
    · exact le_of_le_of_eq'' (le_omegaSup (fun n => guardedIterate F (n + 1)) n) rfl

/-
Every approximant is below any fixed point.
-/
theorem guardedIterate_le_fixed
    {α : Type u} [GuardedOrder α]
    {F : α → α} (hmono : Monotone F)
    {x : α} (hx : F x = x) :
    ∀ n, guardedIterate F n ≤ x := by
  -- By induction on n, we can show that guardedIterate F n ≤ x for all n.
  intro n
  induction' n with n ih;
  · exact ( ‹GuardedOrder α› ).bot_le x;
  · exact hx ▸ hmono ih

/-! ## Main Fixed-Point Theorems -/

/-
**Kleene Fixed-Point Theorem (Guarded).** Under monotonicity and ω-continuity,
the ω-supremum of the iteration chain is a fixed point of F.
-/
theorem guardedLfp_fixed
    {α : Type u} [GuardedOrder α]
    {F : α → α}
    (hmono : Monotone F)
    (hω : OmegaContinuous F) :
    F (guardedLfp F) = guardedLfp F := by
  rename_i h;
  obtain ⟨ _, _, _ ⟩ := h;
  rename_i h₁ h₂ h₃;
  refine' le_antisymm _ _;
  · refine' le_trans ( hω _ _ ) _;
    · intro m n hmn;
      induction hmn <;> simp_all +decide [ guardedIterate ];
      refine' le_trans ‹_› _;
      rename_i k hk ih;
      exact Nat.recOn k ( by exact bot_le ) fun n ihn => by exact hmono ihn;
    · convert h₃ _ _ _;
      intro n;
      refine' le_trans _ ( h₂ _ _ );
      swap;
      exacts [ n + 1, rfl.le ];
  · refine' h₃ _ _ _;
    intro n;
    induction' n with n ih;
    · exact bot_le;
    · exact le_of_eq_of_le rfl (hmono (h₂ (guardedIterate F) n))

/-
The guarded least fixed point is below every fixed point.
-/
theorem guardedLfp_least_fixed
    {α : Type u} [GuardedOrder α]
    {F : α → α}
    (hmono : Monotone F)
    {x : α} (hx : F x = x) :
    guardedLfp F ≤ x := by
  rename_i h;
  cases h;
  rename_i h₁ h₂ h₃ h₄;
  have h_le : ∀ n, guardedIterate F n ≤ x := by
    intro n
    induction' n with n ih;
    · exact bot_le;
    · exact hx ▸ hmono ih;
  exact h₄ _ _ h_le

/-
Uniqueness of least fixed points: any two fixed points that are each
least among all fixed points must be equal.
-/
theorem guarded_fixedpoint_unique
    {α : Type u} [GuardedOrder α]
    {F : α → α}
    {x y : α}
    (hx : F x = x) (hy : F y = y)
    (hleastx : ∀ z, F z = z → x ≤ z)
    (hleasty : ∀ z, F z = z → y ≤ z) :
    x = y := by
  -- Since x ≤ y and y ≤ x, we have x = y by the antisymmetry of the partial order.
  apply (‹GuardedOrder α›.le_antisymm x y (hleastx y hy) (hleasty x hx))

/-! ## Instances for Function Spaces -/

/-- Pointwise `GuardedOrder` instance for function spaces `ι → β`.
When `β` has a `GuardedOrder`, functions into `β` inherit it pointwise. -/
noncomputable instance GuardedOrder.pi {ι : Type u} {β : Type v} [GuardedOrder β] :
    GuardedOrder (ι → β) where
  omegaSup s := fun i => GuardedOrder.omegaSup (fun n => s n i)
  le_omegaSup s n := fun i => GuardedOrder.le_omegaSup (fun n => s n i) n
  omegaSup_le _s _a h := fun i => GuardedOrder.omegaSup_le _ _ (fun n => h n i)