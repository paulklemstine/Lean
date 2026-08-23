import Cryptography.Transreal.Topology

/-!
# The guarded transfer principle

This file makes the informal conjecture

> *every theorem built from continuous real functions using finite composition,
> addition, multiplication and division by a nowhere-zero denominator transfers
> through the finite transreal fragment, while any unguarded extension fails to
> preserve continuity into a natural Hausdorff topology on the four-constructor
> carrier*

into a theorem, by internalising "built from ... " as an inductive syntax.

## The syntax

`TExpr X` is the free algebra on atoms `X → ℝ` and real constants under unary
composition with a real function and the three binary operations `+`, `*`, `/`.
It has two semantics:

* `realEval e : X → ℝ`, using ordinary real arithmetic (with Lean's junk value
  `y / 0 = 0`);
* `transEval e : X → Transreal`, using *total* transreal arithmetic, where
  `1/0 = ∞`, `(-1)/0 = -∞` and `0/0 = Φ`.

`Defined e x` is the pointwise guard (every denominator subexpression is nonzero
at `x`) and `Guarded e` is the uniform guard (all atoms and compositions are
continuous, and every denominator subexpression is nowhere zero).

## Main results

* `TExpr.transEval_eq_fin`: **exact conservativity.**  Wherever the guard holds,
  the transreal semantics is the real semantics read inside the finite fragment.
* `TExpr.continuous_transEval`: **the transfer principle.**  Guarded expressions
  evaluate to continuous maps into the compact Hausdorff carrier.
* `TExpr.guarded_transfer_iff`: **faithfulness.**  Two guarded expressions have
  the same transreal semantics iff they have the same real semantics; so an
  equational theorem holds downstairs iff it holds upstairs.  Transfer is exact,
  not merely sound.
* `TExpr.unguarded_fails` / `TExpr.unguarded_fails_of_t1`: **sharpness.**
  Dropping only the nowhere-vanishing clause from `Guarded` destroys the
  conclusion, and it does so for *every* T₁ topology on the carrier, not only
  for the natural one.
-/

/-- Arithmetic expressions over atoms `X → ℝ`: constants, unary composition with
a real function, addition, multiplication and division. -/
inductive TExpr (X : Type*) : Type _
  | atom (f : X → ℝ) : TExpr X
  | const (c : ℝ) : TExpr X
  | comp (f : ℝ → ℝ) (e : TExpr X) : TExpr X
  | add (e₁ e₂ : TExpr X) : TExpr X
  | mul (e₁ e₂ : TExpr X) : TExpr X
  | div (e₁ e₂ : TExpr X) : TExpr X

namespace TExpr

variable {X : Type*}

/-- Real semantics.  Division uses Lean's total real division, whose value at a
vanishing denominator is the junk value `0`. -/
noncomputable def realEval : TExpr X → X → ℝ
  | atom f, x => f x
  | const c, _ => c
  | comp f e, x => f (realEval e x)
  | add e₁ e₂, x => realEval e₁ x + realEval e₂ x
  | mul e₁ e₂, x => realEval e₁ x * realEval e₂ x
  | div e₁ e₂, x => realEval e₁ x / realEval e₂ x

/-- Transreal semantics, using the total four-constructor arithmetic. -/
noncomputable def transEval : TExpr X → X → Transreal
  | atom f, x => Transreal.fin (f x)
  | const c, _ => Transreal.fin c
  | comp f e, x => Transreal.lift f (transEval e x)
  | add e₁ e₂, x => transEval e₁ x + transEval e₂ x
  | mul e₁ e₂, x => transEval e₁ x * transEval e₂ x
  | div e₁ e₂, x => transEval e₁ x / transEval e₂ x

/-- The pointwise guard: no denominator subexpression vanishes at `x`. -/
def Defined : TExpr X → X → Prop
  | atom _, _ => True
  | const _, _ => True
  | comp _ e, x => Defined e x
  | add e₁ e₂, x => Defined e₁ x ∧ Defined e₂ x
  | mul e₁ e₂, x => Defined e₁ x ∧ Defined e₂ x
  | div e₁ e₂, x => Defined e₁ x ∧ Defined e₂ x ∧ realEval e₂ x ≠ 0

/-- **Exact conservativity.**  Where the guard holds, transreal evaluation is
real evaluation carried into the finite fragment.  The proof is a structural
induction whose only nontrivial step is the division step, discharged by
`Transreal.fin_div_fin_of_ne`. -/
theorem transEval_eq_fin (e : TExpr X) (x : X) (h : Defined e x) :
    transEval e x = Transreal.fin (realEval e x) := by
  induction e with
  | atom f => rfl
  | const c => rfl
  | comp f e ih =>
      rw [transEval, ih h, Transreal.lift_fin]
      rfl
  | add e₁ e₂ ih₁ ih₂ =>
      obtain ⟨h₁, h₂⟩ := h
      rw [transEval, ih₁ h₁, ih₂ h₂, Transreal.fin_add_fin]
      rfl
  | mul e₁ e₂ ih₁ ih₂ =>
      obtain ⟨h₁, h₂⟩ := h
      rw [transEval, ih₁ h₁, ih₂ h₂, Transreal.fin_mul_fin]
      rfl
  | div e₁ e₂ ih₁ ih₂ =>
      obtain ⟨h₁, h₂, hne⟩ := h
      rw [transEval, ih₁ h₁, ih₂ h₂, Transreal.fin_div_fin_of_ne hne]
      rfl

/-- Where the guard holds, transreal evaluation stays inside the finite
fragment: the exceptional constructors are unreachable. -/
theorem finite_transEval (e : TExpr X) (x : X) (h : Defined e x) :
    Transreal.Finite (transEval e x) :=
  ⟨realEval e x, transEval_eq_fin e x h⟩

section Topology

variable [TopologicalSpace X]

/-- The uniform guard: continuity of all the ingredients, and nowhere-vanishing
denominators. -/
def Guarded : TExpr X → Prop
  | atom f => Continuous f
  | const _ => True
  | comp f e => Continuous f ∧ Guarded e
  | add e₁ e₂ => Guarded e₁ ∧ Guarded e₂
  | mul e₁ e₂ => Guarded e₁ ∧ Guarded e₂
  | div e₁ e₂ => Guarded e₁ ∧ Guarded e₂ ∧ ∀ x, realEval e₂ x ≠ 0

/-- The uniform guard implies the pointwise guard everywhere. -/
theorem defined_of_guarded {e : TExpr X} (h : Guarded e) (x : X) : Defined e x := by
  induction e with
  | atom f => trivial
  | const c => trivial
  | comp f e ih => exact ih h.2
  | add e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2⟩
  | mul e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2⟩
  | div e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2.1, h.2.2 x⟩

/-- Guarded expressions evaluate to continuous real functions. -/
theorem continuous_realEval {e : TExpr X} (h : Guarded e) : Continuous (realEval e) := by
  induction e with
  | atom f => exact h
  | const c => exact continuous_const
  | comp f e ih => exact h.1.comp (ih h.2)
  | add e₁ e₂ ih₁ ih₂ => exact (ih₁ h.1).add (ih₂ h.2)
  | mul e₁ e₂ ih₁ ih₂ => exact (ih₁ h.1).mul (ih₂ h.2)
  | div e₁ e₂ ih₁ ih₂ => exact (ih₁ h.1).div (ih₂ h.2.1) h.2.2

/-- On guarded expressions the two semantics agree via `fin`. -/
theorem transEval_eq_fin_comp {e : TExpr X} (h : Guarded e) :
    transEval e = fun x => Transreal.fin (realEval e x) :=
  funext fun x => transEval_eq_fin e x (defined_of_guarded h x)

/-- **The guarded transfer principle.**  Every expression built from continuous
functions by composition, addition, multiplication and division by a nowhere
vanishing denominator evaluates to a continuous map into the compact Hausdorff
four-constructor carrier. -/
theorem continuous_transEval {e : TExpr X} (h : Guarded e) : Continuous (transEval e) := by
  rw [transEval_eq_fin_comp h]
  exact Transreal.continuous_fin.comp (continuous_realEval h)

/-- **Faithfulness of the transfer.**  For guarded expressions, an equational
theorem holds in the transreals if and only if it holds in the reals.  Transfer
is therefore exactly conservative: nothing is lost and nothing new is proved. -/
theorem guarded_transfer_iff {e₁ e₂ : TExpr X} (h₁ : Guarded e₁) (h₂ : Guarded e₂) :
    (∀ x, transEval e₁ x = transEval e₂ x) ↔ ∀ x, realEval e₁ x = realEval e₂ x := by
  constructor
  · intro h x
    have := h x
    rw [transEval_eq_fin e₁ x (defined_of_guarded h₁ x),
      transEval_eq_fin e₂ x (defined_of_guarded h₂ x)] at this
    exact Transreal.fin_injective this
  · intro h x
    rw [transEval_eq_fin e₁ x (defined_of_guarded h₁ x),
      transEval_eq_fin e₂ x (defined_of_guarded h₂ x), h x]

/-- The weak guard: everything of `Guarded` **except** the requirement that
denominators are nowhere zero.  This is the "unguarded extension" of the
conjecture. -/
def WeaklyGuarded : TExpr X → Prop
  | atom f => Continuous f
  | const _ => True
  | comp f e => Continuous f ∧ WeaklyGuarded e
  | add e₁ e₂ => WeaklyGuarded e₁ ∧ WeaklyGuarded e₂
  | mul e₁ e₂ => WeaklyGuarded e₁ ∧ WeaklyGuarded e₂
  | div e₁ e₂ => WeaklyGuarded e₁ ∧ WeaklyGuarded e₂

theorem weaklyGuarded_of_guarded {e : TExpr X} (h : Guarded e) : WeaklyGuarded e := by
  induction e with
  | atom f => exact h
  | const c => trivial
  | comp f e ih => exact ⟨h.1, ih h.2⟩
  | add e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2⟩
  | mul e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2⟩
  | div e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2.1⟩

end Topology

/-! ### Functoriality: the guarded fragment is stable under continuous pullback -/

section Pull

variable {Y : Type*}

/-- Pull an expression back along a map of parameter spaces, by precomposing
every atom. -/
def pull (g : Y → X) : TExpr X → TExpr Y
  | atom f => atom (f ∘ g)
  | const c => const c
  | comp f e => comp f (pull g e)
  | add e₁ e₂ => add (pull g e₁) (pull g e₂)
  | mul e₁ e₂ => mul (pull g e₁) (pull g e₂)
  | div e₁ e₂ => div (pull g e₁) (pull g e₂)

@[simp] theorem realEval_pull (g : Y → X) (e : TExpr X) (y : Y) :
    realEval (pull g e) y = realEval e (g y) := by
  induction e with
  | atom f => rfl
  | const c => rfl
  | comp f e ih => rw [pull, realEval, ih]; rfl
  | add e₁ e₂ ih₁ ih₂ => rw [pull, realEval, ih₁, ih₂]; rfl
  | mul e₁ e₂ ih₁ ih₂ => rw [pull, realEval, ih₁, ih₂]; rfl
  | div e₁ e₂ ih₁ ih₂ => rw [pull, realEval, ih₁, ih₂]; rfl

@[simp] theorem transEval_pull (g : Y → X) (e : TExpr X) (y : Y) :
    transEval (pull g e) y = transEval e (g y) := by
  induction e with
  | atom f => rfl
  | const c => rfl
  | comp f e ih => rw [pull, transEval, ih]; rfl
  | add e₁ e₂ ih₁ ih₂ => rw [pull, transEval, ih₁, ih₂]; rfl
  | mul e₁ e₂ ih₁ ih₂ => rw [pull, transEval, ih₁, ih₂]; rfl
  | div e₁ e₂ ih₁ ih₂ => rw [pull, transEval, ih₁, ih₂]; rfl

variable [TopologicalSpace X] [TopologicalSpace Y]

/-- **Guardedness is stable under continuous reparametrisation.**  Hence the
transfer principle is functorial: it applies to every continuous family of
instances of a guarded identity at once. -/
theorem guarded_pull {g : Y → X} (hg : Continuous g) {e : TExpr X} (h : Guarded e) :
    Guarded (pull g e) := by
  induction e with
  | atom f => exact (h : Continuous f).comp hg
  | const c => trivial
  | comp f e ih => exact ⟨h.1, ih h.2⟩
  | add e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2⟩
  | mul e₁ e₂ ih₁ ih₂ => exact ⟨ih₁ h.1, ih₂ h.2⟩
  | div e₁ e₂ ih₁ ih₂ =>
      refine ⟨ih₁ h.1, ih₂ h.2.1, ?_⟩
      intro y
      rw [realEval_pull]
      exact h.2.2 (g y)

end Pull

/-! ### Sharpness of the guard -/

/-- The self-division expression `x ↦ x / x` over the real line. -/
def selfDiv : TExpr ℝ := div (atom id) (atom id)

@[simp] theorem realEval_selfDiv (x : ℝ) : realEval selfDiv x = x / x := rfl

theorem transEval_selfDiv (x : ℝ) :
    transEval selfDiv x = if x = 0 then Transreal.null else Transreal.fin 1 :=
  Transreal.fin_div_self x

theorem weaklyGuarded_selfDiv : WeaklyGuarded selfDiv :=
  ⟨continuous_id, continuous_id⟩

/-- `selfDiv` is *not* guarded: its denominator vanishes at the origin. -/
theorem not_guarded_selfDiv : ¬ Guarded selfDiv := by
  rintro ⟨-, -, h⟩
  exact h 0 rfl

/-- **Sharpness of the guard, natural topology.**  There is a weakly guarded
expression whose transreal evaluation is discontinuous.  Hence the
nowhere-vanishing hypothesis in `Guarded` cannot be deleted from
`continuous_transEval`. -/
theorem unguarded_fails :
    ∃ e : TExpr ℝ, WeaklyGuarded e ∧ ¬ Continuous (transEval e) := by
  refine ⟨selfDiv, weaklyGuarded_selfDiv, ?_⟩
  have h : transEval selfDiv = fun x : ℝ => Transreal.fin x / Transreal.fin x := rfl
  rw [h]
  exact Transreal.selfDiv_not_continuous

/-- **Sharpness of the guard, topology-independently.**  For *every* T₁ topology
on the four-constructor carrier there is a weakly guarded expression with
discontinuous transreal evaluation.  So the failure is not an artefact of the
chosen Hausdorff topology: no T₁ topology whatsoever supports an unguarded
transfer principle. -/
theorem unguarded_fails_of_t1 (t : TopologicalSpace Transreal) (h1 : @T1Space Transreal t) :
    ∃ e : TExpr ℝ, WeaklyGuarded e ∧ ¬ @Continuous ℝ Transreal _ t (transEval e) := by
  refine ⟨selfDiv, weaklyGuarded_selfDiv, ?_⟩
  have h : transEval selfDiv = fun x : ℝ => Transreal.fin x / Transreal.fin x := rfl
  rw [h]
  exact Transreal.selfDiv_not_continuous_of_t1 t h1

/-- The guarded principle really does apply to nontrivial analytic input: the
expression `exp x / (1 + exp x)` — the logistic function — is guarded, hence
transfers continuously to the four-constructor carrier. -/
noncomputable def logisticExpr : TExpr ℝ :=
  div (comp Real.exp (atom id)) (add (const 1) (comp Real.exp (atom id)))

theorem guarded_logisticExpr : Guarded logisticExpr := by
  refine ⟨⟨Real.continuous_exp, continuous_id⟩, ⟨trivial, Real.continuous_exp, continuous_id⟩, ?_⟩
  intro x
  have : (0 : ℝ) < 1 + Real.exp x := by positivity
  exact ne_of_gt this

theorem continuous_transEval_logistic : Continuous (transEval logisticExpr) :=
  continuous_transEval guarded_logisticExpr

theorem transEval_logistic_eq (x : ℝ) :
    transEval logisticExpr x = Transreal.fin (Real.exp x / (1 + Real.exp x)) :=
  transEval_eq_fin _ x (defined_of_guarded guarded_logisticExpr x)

end TExpr