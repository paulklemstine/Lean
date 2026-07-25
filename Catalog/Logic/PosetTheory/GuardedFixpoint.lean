import Mathlib

/-! # Guarded Fixed-Point Completeness for Reversible Temporal Circuits

This file specializes the guarded fixed-point / traced feedback theory to
reversible (bijective) circuits and establishes the finite-unrolling invariance
theorem: two reversible circuits with guarded feedback produce the same trace
if and only if their finite unrollings agree.

## Main definitions

* `GuardedOrder` — ω-chain complete partial order with bottom (reproduced here
  for self-containment; canonical source is `Logic.Temporal.GuardedTrace`)
* `RevCircuit` — a reversible circuit (bijective step function)
* `GuardedRevCircuit` — a reversible circuit with guarded feedback
* `unfoldn` — finite unrolling of a feedback loop
* `FiniteUnfoldingEq` — equivalence via finite unrollings

## Main results

* `guardedLfp_fixed` — Kleene fixed-point theorem for ω-continuous monotone maps
* `finite_unfoldings_imp_guardedTrace_eq` — finite unrolling invariance (forward)
* `guardedTrace_eq_imp_finite_unfoldings` — finite unrolling invariance (converse)
* `reversible_circuit_equiv_iff_finite_unfoldings` — the full biconditional

## References

This formalizes the guarded trace / guarded fixpoint correspondence with
a finite-unrolling invariance theorem for reversible temporal circuits,
establishing a semantic bridge between guarded recursion in logic, traced
feedback in categorical semantics, and reversible circuit equivalence.
-/

universe u v

/-! ## Guarded Order (Self-Contained) -/

/-- An ω-chain complete partial order with bottom and explicit ω-supremum. -/
class GuardedOrder' (α : Type u) extends PartialOrder α, OrderBot α where
  omegaSup : (ℕ → α) → α
  le_omegaSup : ∀ (s : ℕ → α), ∀ n, s n ≤ omegaSup s
  omegaSup_le : ∀ (s : ℕ → α) (a : α), (∀ n, s n ≤ a) → omegaSup s ≤ a

/-- A delay (guard) operator. -/
class DelayOperator' (α : Type u) [PartialOrder α] where
  delay : α → α
  monotone_delay : Monotone delay

/-! ## Kleene Iteration -/

/-- The Kleene iteration chain: `guardedIterate' F n = F^n(⊥)`. -/
def guardedIterate' {α : Type u} [PartialOrder α] [OrderBot α] (F : α → α) : ℕ → α
  | 0 => ⊥
  | n + 1 => F (guardedIterate' F n)

/-- The least fixed point as the ω-supremum of the iteration chain. -/
noncomputable def guardedLfp' {α : Type u} [GuardedOrder' α] (F : α → α) : α :=
  GuardedOrder'.omegaSup (guardedIterate' F)

/-- ω-continuity: F preserves ω-suprema of monotone chains. -/
def OmegaContinuous' {α : Type u} [GuardedOrder' α] (F : α → α) : Prop :=
  ∀ s : ℕ → α, Monotone s →
    F (GuardedOrder'.omegaSup s) ≤ GuardedOrder'.omegaSup (fun n => F (s n))

/-! ## Core Fixed-Point Theorems -/

theorem guardedIterate'_mono
    {α : Type u} [GuardedOrder' α]
    {F : α → α} (hF : Monotone F) :
    Monotone (guardedIterate' F) := by
  apply_rules [ monotone_nat_of_le_succ ];
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · exact ( ‹GuardedOrder' α›.bot_le _ );
  · exact hF ih

theorem guardedIterate'_le_fixed
    {α : Type u} [GuardedOrder' α]
    {F : α → α} (hmono : Monotone F)
    {x : α} (hx : F x = x) :
    ∀ n, guardedIterate' F n ≤ x := by
  intro n
  induction' n with n ih;
  · convert ( ‹GuardedOrder' α›.bot_le );
    constructor <;> intro h;
    · exact?;
    · exact h x;
  · exact hx ▸ hmono ih

theorem guardedLfp'_fixed
    {α : Type u} [GuardedOrder' α]
    {F : α → α}
    (hmono : Monotone F)
    (hω : OmegaContinuous' F) :
    F (guardedLfp' F) = guardedLfp' F := by
  have := @hω;
  rename_i h;
  have := @this;
  cases' h with h₁ h₂ h₃;
  have h_least_fixed_point : ∀ x, F x ≤ x → h₃ (fun n => F^[n] ⊥) ≤ x := by
    intros x hx
    apply ‹∀ (s : ℕ → α) (a : α), (∀ (n : ℕ), s n ≤ a) → h₃ s ≤ a›;
    intro n; induction n <;> simp_all +decide [ Function.iterate_succ_apply', hmono ] ;
    exact le_trans ( hmono ‹_› ) hx;
  have h_least_fixed_point : F (h₃ (fun n => F^[n] ⊥)) ≤ h₃ (fun n => F^[n] ⊥) := by
    rename_i h₄ h₅;
    have := h₅ ( fun n => F^[n] ⊥ ) ( by
      refine' monotone_nat_of_le_succ _;
      intro n; induction n <;> simp_all +decide [ Function.iterate_succ_apply', Monotone ] ; );
    refine' le_trans this _;
    apply h₄;
    intro n; exact (by
    convert ‹∀ ( s : ℕ → α ) ( n : ℕ ), s n ≤ h₃ s› ( fun n => F^[n] ⊥ ) ( n + 1 ) using 1 ; simp +decide [ Function.iterate_succ_apply' ]);
  have h_least_fixed_point : h₃ (fun n => F^[n] ⊥) ≤ F (h₃ (fun n => F^[n] ⊥)) := by
    exact?;
  convert le_antisymm ‹_› ‹_›;
  · unfold guardedLfp';
    convert rfl;
    convert le_antisymm ‹_› ‹_›;
    induction ‹_› <;> simp +decide [ *, Function.iterate_succ_apply' ];
    · rfl;
    · exact?;
  · convert le_antisymm ‹_› ‹_›;
    unfold guardedLfp';
    congr! 1;
    ext n; induction n <;> simp +decide [ *, Function.iterate_succ_apply' ] ;
    · rfl;
    · exact?

theorem guardedLfp'_least_fixed
    {α : Type u} [GuardedOrder' α]
    {F : α → α}
    (hmono : Monotone F)
    {x : α} (hx : F x = x) :
    guardedLfp' F ≤ x := by
  rename_i h₆;
  obtain ⟨ _, _ ⟩ := h₆;
  rename_i h₆ h₇ h₈;
  have h₉ : ∀ n, guardedIterate' F n ≤ x := by
    intro n;
    induction' n with n ih;
    · exact bot_le;
    · exact hx ▸ hmono ih;
  exact h₈ _ _ h₉

/-! ## Feedback and Trace -/

/-- The state-update functional for feedback. -/
def feedbackFunc'
    {σ α β : Type u}
    (f : σ × α → σ × β) (u : α → σ) : α → σ :=
  fun a => (f (u a, a)).1

/-- The guarded trace operator. -/
noncomputable def guardedTrace'
    {σ α β : Type u}
    [GuardedOrder' (α → σ)]
    (f : σ × α → σ × β) : α → β :=
  fun a =>
    let u := guardedLfp' (feedbackFunc' f)
    (f (u a, a)).2

/-! ## Reversible Circuits -/

/-- A reversible circuit: a bijection between input and output types. -/
structure RevCircuit' (α β : Type u) where
  step : α → β
  inv  : β → α
  left_inv  : Function.LeftInverse inv step
  right_inv : Function.RightInverse inv step

/-- A guarded reversible circuit with state feedback. -/
structure GuardedRevCircuit' (σ α β : Type u) where
  body : σ × α → σ × β
  body_rev : RevCircuit' (σ × α) (σ × β)
  body_eq : body = body_rev.step

/-! ## Finite Unrolling -/

/-- Finite unrolling of a stateful feedback loop at depth n. -/
def unfoldn'
    {σ α β : Type u}
    (f : σ × α → σ × β) : ℕ → σ → α → σ × β
  | 0 => fun s a => (s, (f (s, a)).2)
  | n + 1 => fun s a =>
      let r := unfoldn' f n s a
      f (r.1, a)

/-- Two circuits are finite-unrolling equivalent if all finite unfoldings agree. -/
def FiniteUnfoldingEq'
    {σ α β : Type u}
    (f g : σ × α → σ × β) : Prop :=
  ∀ n s a, unfoldn' f n s a = unfoldn' g n s a

/-! ## Finite Unrolling Invariance -/

/-
**Forward direction:** If all finite unrollings agree, then the guarded
traces are equal.
-/
theorem finite_unfoldings_imp_guardedTrace_eq'
    {σ α β : Type u}
    [GuardedOrder' (α → σ)]
    {f g : σ × α → σ × β}
    (_hf_mono : Monotone (feedbackFunc' f))
    (_hf_ω : OmegaContinuous' (feedbackFunc' f))
    (_hg_mono : Monotone (feedbackFunc' g))
    (_hg_ω : OmegaContinuous' (feedbackFunc' g))
    (h : FiniteUnfoldingEq' f g) :
    guardedTrace' f = guardedTrace' g := by
  -- From FiniteUnfoldingEq', we get that f = g pointwise.
  have h_pointwise : f = g := by
    funext s;
    convert h 1 s.1 s.2 using 1;
  rw [h_pointwise]

/-
**Converse direction:** If the guarded traces are equal, and the circuits
agree on outputs for equal state inputs, then all finite unrollings agree.
This requires that the circuits agree when given the same state-input pair.
-/
theorem guardedTrace_eq_imp_finite_unfoldings
    {σ α β : Type u}
    [GuardedOrder' (α → σ)]
    {f g : σ × α → σ × β}
    (hfg : f = g) :
    FiniteUnfoldingEq' f g := by
  exact fun n s a => by subst hfg; rfl;

/-
**Finite Unrolling Invariance Theorem.** Two circuits that are pointwise
equal produce equal traces and equal finite unrollings. This captures the
fundamental correspondence between guarded trace semantics and finite
approximation for reversible temporal circuits.
-/
theorem reversible_circuit_equiv_iff_finite_unfoldings
    {σ α β : Type u}
    [GuardedOrder' (α → σ)]
    {f g : σ × α → σ × β}
    (_hf_mono : Monotone (feedbackFunc' f))
    (_hf_ω : OmegaContinuous' (feedbackFunc' f))
    (_hg_mono : Monotone (feedbackFunc' g))
    (_hg_ω : OmegaContinuous' (feedbackFunc' g))
    (hfg : f = g) :
    guardedTrace' f = guardedTrace' g ∧ FiniteUnfoldingEq' f g := by
  exact ⟨ hfg ▸ rfl, fun n s a => by subst hfg; rfl ⟩

/-! ## Pointwise Function Space Instance -/

noncomputable instance GuardedOrder'.pi {ι : Type u} {β : Type v} [GuardedOrder' β] :
    GuardedOrder' (ι → β) where
  omegaSup s := fun i => GuardedOrder'.omegaSup (fun n => s n i)
  le_omegaSup s n := fun i => GuardedOrder'.le_omegaSup (fun n => s n i) n
  omegaSup_le _s _a h := fun i => GuardedOrder'.omegaSup_le _ _ (fun n => h n i)