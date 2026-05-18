import Mathlib

/-! # Guarded Trace Semantics for Temporal Feedback Circuits

This file develops a complete guarded fixed-point theory and traced feedback
semantics for reversible temporal circuits. The construction proceeds in layers:

1. **Guarded Order** — ω-chain complete partial orders with explicit ω-supremum
2. **Kleene Iteration** — the chain F^n(⊥) and its supremum as least fixed point
3. **Fixed-Point Theorems** — existence, leastness, and uniqueness under ω-continuity
4. **Traced Feedback** — the guarded trace operator for stateful processes
5. **Reversible Circuits** — bijective circuits with finite unrolling semantics
6. **Finite Unrolling Invariance** — trace equivalence via approximant agreement

## Main results

* `guardedLfp_fixed` — Kleene fixed-point theorem for ω-continuous monotone maps
* `guardedLfp_least_fixed` — the construction yields the least fixed point
* `guarded_fixedpoint_unique` — uniqueness among least fixed points
* `guardedTrace_unfold` — trace unfolding law
* `guardedTrace_unique` — uniqueness of the traced state solution
* `guardedTrace_eq_of_iterates_eq` — equal approximants imply equal traces
* `finite_unfoldings_imp_guardedTrace_eq` — finite unrolling invariance theorem
-/

universe u v

/-! ## 1. Guarded Order Structure -/

/-- An ω-chain complete partial order with bottom and explicit ω-supremum.
This provides the semantic domain for guarded fixed-point iteration. -/
class GuardedOrder (α : Type u) extends PartialOrder α, OrderBot α where
  /-- The supremum of an ω-chain. -/
  omegaSup : (ℕ → α) → α
  /-- Every element of the chain is below the supremum. -/
  le_omegaSup : ∀ (s : ℕ → α), ∀ n, s n ≤ omegaSup s
  /-- The supremum is the least upper bound. -/
  omegaSup_le : ∀ (s : ℕ → α) (a : α), (∀ n, s n ≤ a) → omegaSup s ≤ a

/-- A delay (guard) operator modeling the productive delay in temporal feedback. -/
class DelayOperator (α : Type u) [PartialOrder α] where
  /-- The delay map. -/
  delay : α → α
  /-- Delay is monotone. -/
  monotone_delay : Monotone delay

/-! ## 2. Kleene Iteration -/

/-- The Kleene iteration chain: `guardedIterate F n = F^n(⊥)`. -/
def guardedIterate {α : Type u} [PartialOrder α] [OrderBot α] (F : α → α) : ℕ → α
  | 0 => ⊥
  | n + 1 => F (guardedIterate F n)

/-- The candidate least fixed point: the ω-supremum of the iteration chain. -/
noncomputable def guardedLfp {α : Type u} [GuardedOrder α] (F : α → α) : α :=
  GuardedOrder.omegaSup (guardedIterate F)

/-- An endomorphism is ω-continuous if it preserves ω-suprema of monotone chains. -/
def OmegaContinuous {α : Type u} [GuardedOrder α] (F : α → α) : Prop :=
  ∀ s : ℕ → α, Monotone s →
    F (GuardedOrder.omegaSup s) ≤ GuardedOrder.omegaSup (fun n => F (s n))

/-! ## 3. Fixed-Point Theorems -/

/-
The iteration chain is monotone for monotone F.
-/
theorem guardedIterate_mono
    {α : Type u} [GuardedOrder α]
    {F : α → α} (hF : Monotone F) :
    Monotone (guardedIterate F) := by
  apply_rules [ monotone_nat_of_le_succ ];
  intro n
  induction' n with n ih;
  · exact ( ‹GuardedOrder α›.bot_le _ );
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
  rename_i a;
  cases a;
  rename_i h₁ h₂ h₃ h₄ h₅;
  refine' le_antisymm ( h₅ _ _ fun n => _ ) ( h₅ _ _ fun n => _ );
  · exact h₄ _ _;
  · induction' n with n ih;
    · exact bot_le;
    · exact le_of_le_of_eq'' (h₄ (fun n => guardedIterate F (n + 1)) n) rfl

/-
Every approximant is below any fixed point.
-/
theorem guardedIterate_le_fixed
    {α : Type u} [GuardedOrder α]
    {F : α → α} (hmono : Monotone F)
    {x : α} (hx : F x = x) :
    ∀ n, guardedIterate F n ≤ x := by
  intro n;
  induction' n with n ih;
  · exact ( ‹GuardedOrder α› ).bot_le x;
  · exact hx ▸ hmono ih

/-
**Kleene Fixed-Point Theorem.** Under monotonicity and ω-continuity,
the ω-supremum of the iteration chain is a fixed point of F.
-/
theorem guardedLfp_fixed
    {α : Type u} [GuardedOrder α]
    {F : α → α}
    (hmono : Monotone F)
    (hω : OmegaContinuous F) :
    F (guardedLfp F) = guardedLfp F := by
  unfold guardedLfp at *;
  rename_i h;
  obtain ⟨ _, _ ⟩ := h;
  have h_kleene : F (‹(ℕ → α) → α› (fun n => guardedIterate F n)) ≤ ‹(ℕ → α) → α› (fun n => guardedIterate F n) := by
    refine' le_trans ( hω _ _ ) _;
    · intro m n hmn;
      induction hmn <;> simp_all +decide [ guardedIterate ];
      refine' le_trans ‹_› _;
      rename_i k hk ih;
      exact Nat.recOn k ( by exact bot_le ) fun n ihn => by exact hmono ihn;
    · rename_i h₁ h₂ h₃ h₄ h₅;
      refine' h₅ _ _ _;
      intro n;
      convert h₄ _ ( n + 1 ) using 1;
      exact (congrArg F ∘ congrArg (guardedIterate F)) rfl;
  have h_kleene : ∀ n, guardedIterate F n ≤ F (‹(ℕ → α) → α› (fun n => guardedIterate F n)) := by
    intro n; induction' n with n ih <;> simp_all +decide [ guardedIterate ] ;
    exact hmono ( by solve_by_elim );
  exact le_antisymm ‹_› ( by solve_by_elim )

/-
The guarded least fixed point is below every fixed point.
-/
theorem guardedLfp_least_fixed
    {α : Type u} [GuardedOrder α]
    {F : α → α}
    (hmono : Monotone F)
    {x : α} (hx : F x = x) :
    guardedLfp F ≤ x := by
  convert ( ‹GuardedOrder α›.omegaSup_le _ _ _ );
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · exact ( ‹GuardedOrder α›.bot_le x );
  · exact hx ▸ hmono ih

/-
Uniqueness of least fixed points.
-/
theorem guarded_fixedpoint_unique
    {α : Type u} [GuardedOrder α]
    {F : α → α}
    {x y : α}
    (hx : F x = x) (hy : F y = y)
    (hleastx : ∀ z, F z = z → x ≤ z)
    (hleasty : ∀ z, F z = z → y ≤ z) :
    x = y := by
  -- Since $x \leq y$ and $y \leq x$, by the antisymmetry of the partial order, we have $x = y$.
  apply (‹GuardedOrder α›.le_antisymm x y (hleastx y hy) (hleasty x hx))

/-! ## Function Space Instance -/

/-- Pointwise `GuardedOrder` instance for function spaces. -/
noncomputable instance GuardedOrder.pi {ι : Type u} {β : Type v} [GuardedOrder β] :
    GuardedOrder (ι → β) where
  omegaSup s := fun i => GuardedOrder.omegaSup (fun n => s n i)
  le_omegaSup s n := fun i => GuardedOrder.le_omegaSup (fun n => s n i) n
  omegaSup_le _s _a h := fun i => GuardedOrder.omegaSup_le _ _ (fun n => h n i)

/-! ## 4. Traced Feedback -/

/-- The state-update functional for feedback. -/
def feedbackFunc
    {σ α β : Type u}
    (f : σ × α → σ × β) (u : α → σ) : α → σ :=
  fun a => (f (u a, a)).1

/-- The guarded trace operator: compute the least fixed point of the feedback
functional and return the output component. -/
noncomputable def guardedTrace
    {σ α β : Type u}
    [GuardedOrder (α → σ)]
    (f : σ × α → σ × β) : α → β :=
  fun a =>
    let u := guardedLfp (feedbackFunc f)
    (f (u a, a)).2

/-
The guarded trace equals applying f to the fixed-point state.
-/
theorem guardedTrace_unfold
    {σ α β : Type u}
    [GuardedOrder (α → σ)]
    {f : σ × α → σ × β}
    (_hmono : Monotone (feedbackFunc f))
    (_hω : OmegaContinuous (feedbackFunc f)) :
    guardedTrace f = fun a => (f (guardedLfp (feedbackFunc f) a, a)).2 := by
  rfl

/-- Uniqueness of the traced state solution. -/
theorem guardedTrace_unique
    {σ α β : Type u}
    [GuardedOrder (α → σ)]
    {f : σ × α → σ × β}
    (_hmono : Monotone (feedbackFunc f))
    (_hω : OmegaContinuous (feedbackFunc f))
    {u : α → σ}
    (hu : feedbackFunc f u = u)
    (hleast : ∀ v, feedbackFunc f v = v → u ≤ v) :
    u = guardedLfp (feedbackFunc f) := by
  exact le_antisymm (hleast _ (guardedLfp_fixed _hmono _hω)) (guardedLfp_least_fixed _hmono hu)

/-
Equal iteration chains imply equal traces.
-/
theorem guardedTrace_eq_of_iterates_eq
    {σ α β : Type u}
    [GuardedOrder (α → σ)]
    {f g : σ × α → σ × β}
    (_hmono_f : Monotone (feedbackFunc f))
    (_hω_f : OmegaContinuous (feedbackFunc f))
    (_hmono_g : Monotone (feedbackFunc g))
    (_hω_g : OmegaContinuous (feedbackFunc g))
    (hfg : ∀ n, guardedIterate (feedbackFunc f) n = guardedIterate (feedbackFunc g) n)
    (hout : ∀ (s : σ) (a : α), (f (s, a)).2 = (g (s, a)).2) :
    guardedTrace f = guardedTrace g := by
  unfold guardedTrace;
  simp +decide only [hout];
  unfold guardedLfp;
  congr! 3;
  congr! 2;
  exact funext hfg

/-! ## 5. Reversible Circuits -/

/-- A reversible circuit: a bijection between input and output types. -/
structure RevCircuit (α β : Type u) where
  /-- The forward map. -/
  step : α → β
  /-- The inverse map. -/
  inv  : β → α
  /-- Left inverse property. -/
  left_inv  : Function.LeftInverse inv step
  /-- Right inverse property. -/
  right_inv : Function.RightInverse inv step

/-- A guarded reversible circuit with state feedback. -/
structure GuardedRevCircuit (σ α β : Type u) where
  /-- The circuit body. -/
  body : σ × α → σ × β
  /-- Proof of reversibility. -/
  body_rev : RevCircuit (σ × α) (σ × β)
  /-- The body matches the reversible circuit step function. -/
  body_eq : body = body_rev.step

/-! ## 6. Finite Unrolling and Invariance -/

/-- Finite unrolling of a stateful feedback loop. -/
def unfoldn
    {σ α β : Type u}
    (f : σ × α → σ × β) : ℕ → σ → α → σ × β
  | 0 => fun s a => (s, (f (s, a)).2)
  | n + 1 => fun s a =>
      let r := unfoldn f n s a
      f (r.1, a)

/-- Two stateful maps are finite-unrolling equivalent if all finite
unfoldings agree. -/
def FiniteUnfoldingEq
    {σ α β : Type u}
    (f g : σ × α → σ × β) : Prop :=
  ∀ n s a, unfoldn f n s a = unfoldn g n s a

/-
**Finite Unrolling Invariance.** If all finite unrollings of two
circuits agree, then their guarded traces are equal.
This is the computationally meaningful half of the correspondence.
-/
theorem finite_unfoldings_imp_guardedTrace_eq
    {σ α β : Type u}
    [GuardedOrder (α → σ)]
    {f g : σ × α → σ × β}
    (_hf_mono : Monotone (feedbackFunc f))
    (_hf_ω : OmegaContinuous (feedbackFunc f))
    (_hg_mono : Monotone (feedbackFunc g))
    (_hg_ω : OmegaContinuous (feedbackFunc g))
    (h : FiniteUnfoldingEq f g) :
    guardedTrace f = guardedTrace g := by
  -- Since the unfoldn functions are equal for all n, the feedback functions must be equal.
  have h_feedback_eq : feedbackFunc f = feedbackFunc g := by
    ext u a;
    convert congr_arg Prod.fst ( h 1 ( u a ) a ) using 1;
  unfold guardedTrace;
  simp +decide [ h_feedback_eq ];
  exact funext fun a => congr_arg Prod.snd ( h 1 _ _ )

/-! ## Bekič Decomposition -/

/-- Product-level feedback functional. -/
def feedbackFunc₂
    {x y a : Type u}
    (f : (x × y) × a → (x × y)) :
    (a → x × y) → (a → x × y) :=
  fun u a => f (u a, a)

/-
Bekič decomposition existence: the least fixed point of a product-valued
feedback functional decomposes as a pair of component functions.
-/
theorem guardedTrace_bekic
    {x y a : Type u}
    [GuardedOrder (a → x × y)]
    {f : (x × y) × a → x × y}
    (_hmono : Monotone (feedbackFunc₂ f))
    (_hω : OmegaContinuous (feedbackFunc₂ f)) :
    ∃ ux : a → x, ∃ uy : a → y,
      guardedLfp (feedbackFunc₂ f) = fun a => (ux a, uy a) := by
  grind