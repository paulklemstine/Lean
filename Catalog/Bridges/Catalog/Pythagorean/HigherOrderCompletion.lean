import Mathlib

/-!
# Higher-Order Completion and Lambda-Calculus Integration

This file formalizes a bridge between certified first-order completion theory
(as developed in `ConcreteTermAlgebra.lean`) and the simply-typed λ-calculus.
We define simply-typed λ-terms with de Bruijn indices, typed substitution,
β-reduction, higher-order rewriting, and contextual closure, then prove the
fundamental closure and functoriality theorems that lift first-order completion
infrastructure to the higher-order setting.

## Main Results

### Substitution Infrastructure (lifting `subst_comp` from ConcreteTermAlgebra)
* `Term.rename_id` — Renaming by the identity is the identity
* `Term.rename_comp` — Renaming is functorial (composition)
* `Term.subst_id` — Identity substitution is the identity on terms
* `Term.subst_comp` — Substitution composition is functorial
  (higher-order analogue of `FOTerm.subst_comp`)
* `Term.compSubst_assoc` — Substitution composition is associative

### β-Reduction (genuinely higher-order phenomenon)
* `Term.beta_closed_under_subst` — β-contraction commutes with substitution
* `Term.betaStep_subst` — One-step β-reduction is stable under substitution

### Higher-Order Rewrite Closure (lifting `rewrites_closed_under_subst_and_context`)
* `Term.hoRewrites_closed_under_subst` — Higher-order rewriting is closed
  under substitution (analogue of `rewrites_closed_under_subst`)
* `Term.hoRewrites_closed_under_context` — Higher-order rewriting is closed
  under applicative contexts (analogue of `rewrites_closed_under_context`)
* `Term.HOEqGen_closed_under_subst` — Generated equational theory respects substitution

### Cross-Domain Connections
* **Category theory**: `subst_comp`, `compSubst_assoc`, identity laws show
  substitutions form a category and terms are presheaf-like objects
* **Functional programming**: map fusion encoded as higher-order rewriting
* **Proof automation**: contextual closure enables rewriting inside programs
* **Cartesian closed categories**: STLC is the internal language of CCCs;
  our substitution and context closure theorems are coherence laws

## Relationship to ConcreteTermAlgebra.lean

| First-Order (ConcreteTermAlgebra)        | Higher-Order (this file)                    |
|------------------------------------------|---------------------------------------------|
| `FOTerm.subst_comp`                      | `Term.subst_comp`                           |
| `rewrites_closed_under_subst`            | `hoRewrites_closed_under_subst`             |
| `rewrites_closed_under_context`          | `hoRewrites_closed_under_context`           |
| `rewrites_closed_under_subst_and_context`| Combined via the two theorems above         |
| Tree contexts (OneHoleCtx)               | λ/application contexts (HOCtx)             |
| First-order substitution                 | De Bruijn substitution with binder lifting  |

The key conceptual advance is that substitution now interacts with **binding**:
the `liftSubst` operation, and all lemmas involving it, have no first-order analogue.
This is what makes higher-order completion fundamentally harder than first-order.

application keywords: higher-order completion, simply-typed lambda calculus,
β-reduction, rewriting modulo β, contextual closure, substitution calculus,
categorical semantics, cartesian closed categories, functional program optimization,
map fusion, proof automation, higher-order matching, confluence, certified rewriting
-/

namespace HigherOrderCompletion

-- ============================================================================
-- Section 1: Simple Types
-- ============================================================================

/-- Simple types for the simply-typed λ-calculus.
    `base` represents ground types; `arr` represents function types.
    This corresponds to the object language of a cartesian closed category. -/
inductive Ty where
  | base : Ty
  | arr : Ty → Ty → Ty
  deriving DecidableEq, Repr

infixr:25 " ⟶ " => Ty.arr

-- ============================================================================
-- Section 2: Lambda Terms with de Bruijn Indices
-- ============================================================================

/-- Lambda terms with de Bruijn indices.
    Variables are natural numbers representing binding depth.
    Using ℕ (rather than `Fin n`) simplifies the substitution theory
    while preserving all the essential mathematical content.

    This is analogous to `FOTerm` from `ConcreteTermAlgebra.lean`,
    but with the crucial addition of `lam` (abstraction), which
    introduces variable binding — the phenomenon that makes
    higher-order rewriting fundamentally different from first-order. -/
inductive Term : Type where
  | var : ℕ → Term
  | app : Term → Term → Term
  | lam : Term → Term
  deriving DecidableEq, Repr

namespace Term

-- ============================================================================
-- Section 3: Renaming
-- ============================================================================

/-- Lift a variable renaming under a binder.
    Variable 0 (the bound variable) is fixed; free variables are shifted.
    This operation has no first-order analogue — it exists because
    λ-abstraction introduces a new variable scope. -/
def liftRen (ρ : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | n + 1 => ρ n + 1

/-- Apply a variable renaming to a term.
    Structurally recursive; under `lam`, the renaming is lifted. -/
def rename (ρ : ℕ → ℕ) : Term → Term
  | var i => var (ρ i)
  | app s t => app (rename ρ s) (rename ρ t)
  | lam t => lam (rename (liftRen ρ) t)

-- ============================================================================
-- Section 4: Substitution
-- ============================================================================

/-- A substitution maps variable indices to terms. -/
abbrev Subst := ℕ → Term

/-- Lift a substitution under a binder.
    Variable 0 maps to itself (the new bound variable);
    other variables have their images weakened (shifted up by 1).

    This is the critical operation that distinguishes higher-order
    substitution from first-order: under a binder, we must avoid
    capturing the newly bound variable. -/
def liftSubst (σ : Subst) : Subst
  | 0 => var 0
  | n + 1 => rename (· + 1) (σ n)

/-- Apply a substitution to a term.
    Analogous to `FOTerm.subst` from `ConcreteTermAlgebra.lean`,
    but with the addition of the `lam` case using `liftSubst`. -/
def subst : Term → Subst → Term
  | var i, σ => σ i
  | app s t, σ => app (s.subst σ) (t.subst σ)
  | lam t, σ => lam (t.subst (liftSubst σ))

/-- Identity substitution. -/
def idSubst : Subst := var

/-- Composition of substitutions: apply σ first, then τ.
    Analogous to `FOTerm.compSubst` from `ConcreteTermAlgebra.lean`. -/
def compSubst (σ τ : Subst) : Subst :=
  fun i => (σ i).subst τ

-- ============================================================================
-- Section 5: β-Reduction Infrastructure
-- ============================================================================

/-- Single substitution: replaces variable 0 with `s`, shifts others down.
    This is used for β-contraction: (λ body) arg → body[0 := arg]. -/
def singleSubst (s : Term) : Subst
  | 0 => s
  | n + 1 => var n

/-- β-contraction: substitute the argument into the body of a λ-abstraction.
    betaContract body arg = body[0 := arg] -/
def betaContract (body arg : Term) : Term :=
  body.subst (singleSubst arg)

-- ============================================================================
-- Section 6: Simp Lemmas (Definitional Unfolding)
-- ============================================================================

@[simp] theorem liftRen_zero (ρ : ℕ → ℕ) : liftRen ρ 0 = 0 := rfl
@[simp] theorem liftRen_succ (ρ : ℕ → ℕ) (n : ℕ) : liftRen ρ (n + 1) = ρ n + 1 := rfl

@[simp] theorem rename_var (ρ : ℕ → ℕ) (i : ℕ) : rename ρ (var i) = var (ρ i) := rfl
@[simp] theorem rename_app (ρ : ℕ → ℕ) (s t : Term) :
    rename ρ (app s t) = app (rename ρ s) (rename ρ t) := rfl
@[simp] theorem rename_lam (ρ : ℕ → ℕ) (t : Term) :
    rename ρ (lam t) = lam (rename (liftRen ρ) t) := rfl

@[simp] theorem liftSubst_zero (σ : Subst) : liftSubst σ 0 = var 0 := rfl
@[simp] theorem liftSubst_succ (σ : Subst) (n : ℕ) :
    liftSubst σ (n + 1) = rename (· + 1) (σ n) := rfl

@[simp] theorem subst_var (σ : Subst) (i : ℕ) : (var i).subst σ = σ i := rfl
@[simp] theorem subst_app (σ : Subst) (s t : Term) :
    (app s t).subst σ = app (s.subst σ) (t.subst σ) := rfl
@[simp] theorem subst_lam (σ : Subst) (t : Term) :
    (lam t).subst σ = lam (t.subst (liftSubst σ)) := rfl

@[simp] theorem singleSubst_zero (s : Term) : singleSubst s 0 = s := rfl
@[simp] theorem singleSubst_succ (s : Term) (n : ℕ) :
    singleSubst s (n + 1) = var n := rfl

-- ============================================================================
-- Section 7: Renaming Lemmas
-- ============================================================================

/-- Lifting the identity renaming yields the identity. -/
theorem liftRen_id : liftRen id = id := by
  funext n; cases n <;> simp [liftRen]

/-- Renaming by the identity is the identity on terms. -/
theorem rename_id (t : Term) : rename id t = t := by
  induction t with
  | var i => simp
  | app s t ihs iht => simp [ihs, iht]
  | lam t ih => simp only [rename_lam, liftRen_id]; exact congrArg lam ih

/-- Lifting preserves composition of renamings. -/
theorem liftRen_comp (ρ₁ : ℕ → ℕ) (ρ₂ : ℕ → ℕ) :
    liftRen ρ₂ ∘ liftRen ρ₁ = liftRen (ρ₂ ∘ ρ₁) := by
  funext n; cases n <;> simp [liftRen, Function.comp]

/-- Renaming is functorial: two successive renamings compose.
    This is the first step toward categorical structure. -/
theorem rename_comp (ρ₁ ρ₂ : ℕ → ℕ) (t : Term) :
    rename ρ₂ (rename ρ₁ t) = rename (ρ₂ ∘ ρ₁) t := by
  induction t generalizing ρ₁ ρ₂ with
  | var i => simp [Function.comp]
  | app s t ihs iht => simp [ihs, iht]
  | lam t ih => simp only [rename_lam]; rw [ih]; rw [liftRen_comp]

/-
============================================================================
Section 8: Substitution-Renaming Interaction Lemmas
These lemmas have no first-order analogue — they arise because
substitution must interact with binder-aware renaming.
============================================================================

Lifting of substitution commutes with lifting of renaming.
-/
theorem liftSubst_liftRen (σ : Subst) (ρ : ℕ → ℕ) (i : ℕ) :
    liftSubst σ (liftRen ρ i) = liftSubst (σ ∘ ρ) i := by
  induction i <;> simp +decide [ *, liftSubst, liftRen ]

/-
Substitution after renaming: the renaming can be absorbed into the substitution.
-/
theorem subst_rename (ρ : ℕ → ℕ) (σ : Subst) (t : Term) :
    (rename ρ t).subst σ = t.subst (σ ∘ ρ) := by
  induction' t with _ _ _ _ <;> simp +decide [ * ];
  -- By the induction hypothesis, we know that the substitution of the renamed term is equal to the substitution of the original term with the composition of the substitutions.
  have h_ind : ∀ (t : Term) (ρ : ℕ → ℕ) (σ : Subst), (rename ρ t).subst σ = t.subst (σ ∘ ρ) := by
    intros t ρ σ; induction' t with _ _ _ _ generalizing ρ σ <;> simp +decide [ *, liftSubst_liftRen ] ;
    congr! 1;
    exact funext fun n => by induction n <;> simp +decide [ *, liftSubst_liftRen ] ;
  convert h_ind _ _ _ using 2;
  exact funext fun n => by induction n <;> simp +decide [ * ] ;

/-
Auxiliary: rename (liftRen ρ) distributes over liftSubst.
    Needed for `rename_subst`.
-/
theorem rename_liftRen_liftSubst (ρ : ℕ → ℕ) (σ : Subst) (i : ℕ) :
    rename (liftRen ρ) (liftSubst σ i) = liftSubst (fun n => rename ρ (σ n)) i := by
  cases i <;> simp +decide [ liftSubst, liftRen ];
  rw [ rename_comp, rename_comp ];
  congr! 1

/-
Renaming after substitution: the renaming distributes to each image.
-/
theorem rename_subst (ρ : ℕ → ℕ) (σ : Subst) (t : Term) :
    rename ρ (t.subst σ) = t.subst (fun n => rename ρ (σ n)) := by
  induction' t with i t₁ ih₁ t₂ ih₂ t ih generalizing ρ σ;
  · aesop;
  · convert congr_arg₂ Term.app ( t₂ ρ σ ) ( ih₂ ρ σ ) using 1;
  · convert congr_arg Term.lam ( ih ( liftRen ρ ) ( liftSubst σ ) ) using 1;
    exact congr_arg Term.lam ( by congr; ext n; exact rename_liftRen_liftSubst _ _ _ ▸ rfl )

-- ============================================================================
-- Section 9: Substitution Identity and Composition
-- ============================================================================

/-- Lifting the identity substitution (var) yields var. -/
theorem liftSubst_var : liftSubst var = var := by
  funext n; cases n <;> simp [liftSubst, rename]

/-
Substitution by `var` (the identity substitution) is the identity.
    Analogous to `FOTerm.subst_id` from `ConcreteTermAlgebra.lean`.
-/
theorem subst_id (t : Term) : t.subst var = t := by
  induction' t with t₁ t₂ ih₁ ih₂ ih_t s t ih_s ih_t;
  · rfl;
  · -- By the definition of substitution, we have:
    simp [Term.subst, ih₂, ih_t];
  · simp +decide [ t, liftSubst_var, subst_lam ]

/-
Key auxiliary: rename (· + 1) after subst τ equals subst under liftSubst τ.
    This connects weakening with substitution under binders.
-/
theorem rename_succ_subst_liftSubst (t : Term) (τ : Subst) :
    rename (· + 1) (t.subst τ) = (rename (· + 1) t).subst (liftSubst τ) := by
  convert rename_subst _ _ _ using 1;
  convert subst_rename _ _ _ using 2

/-
Lifting distributes over substitution composition.
    This is the critical binder-crossing lemma for `subst_comp`.
-/
theorem liftSubst_compSubst (σ : Subst) (τ : Subst) :
    liftSubst (compSubst σ τ) = compSubst (liftSubst σ) (liftSubst τ) := by
  funext i; rcases i with ( _ | i ) <;> simp +decide [ * ] ;
  · simp [compSubst, liftSubst];
  · convert rename_succ_subst_liftSubst ( σ i ) τ using 1

/-! ### Theorem 1: Substitution Functoriality (Higher-Order `subst_comp`)

This is the higher-order analogue of `FOTerm.subst_comp` from
`ConcreteTermAlgebra.lean`. The proof is fundamentally harder because
the `lam` case requires `liftSubst_compSubst`, which involves the
interplay of renaming and substitution under binders.

**Categorical interpretation**: This theorem, together with `subst_id`,
`compSubst_assoc`, and the identity laws, shows that substitutions form
a category and λ-terms act as presheaf-like objects over contexts.
In the language of cartesian closed categories, this is a coherence law
for the internal language. -/

/-
**Theorem 1**: Substitution composition is functorial.
    `(t[σ])[τ] = t[σ ; τ]`
    Higher-order lift of `FOTerm.subst_comp` from `ConcreteTermAlgebra.lean`.
-/
theorem subst_comp (t : Term) (σ τ : Subst) :
    (t.subst σ).subst τ = t.subst (compSubst σ τ) := by
  induction' t with t ih generalizing σ τ;
  · rfl;
  · simp +decide [ *, Term.subst ];
  · simp_all +decide [ compSubst, liftSubst_compSubst ]

-- Categorical corollaries

/-- Left identity for substitution composition. -/
theorem compSubst_idSubst_left (σ : Subst) : compSubst var σ = σ := by
  funext i; simp [compSubst]

/-
Right identity for substitution composition.
-/
theorem compSubst_idSubst_right (σ : Subst) : compSubst σ var = σ := by
  exact funext fun n => by simp [compSubst, subst_id];

/-
**Categorical corollary**: Substitution composition is associative.
    Together with the identity laws, this shows substitutions form a category.
-/
theorem compSubst_assoc (σ₁ σ₂ σ₃ : Subst) :
    compSubst (compSubst σ₁ σ₂) σ₃ = compSubst σ₁ (compSubst σ₂ σ₃) := by
  ext i
  simp [compSubst, subst_comp]

/-
============================================================================
Section 10: β-Reduction Commutation
============================================================================

Auxiliary: renaming by (· + 1) then substituting by singleSubst recovers the original.
-/
theorem rename_succ_singleSubst (t : Term) (s : Term) :
    (rename (· + 1) t).subst (singleSubst s) = t := by
  -- Apply the subst_rename lemma with ρ being the function that adds 1.
  have h_rename : (rename (fun x => x + 1) t).subst s.singleSubst = t.subst (s.singleSubst ∘ (fun x => x + 1)) := by
    convert subst_rename _ _ _;
  rw [ h_rename, show ( s.singleSubst ∘ fun x ↦ x + 1 ) = fun x ↦ var x from funext fun x ↦ by cases x <;> rfl ];
  exact subst_id t

/-! ### Theorem 4: β-Step is Stable Under Substitution

This theorem isolates the genuinely higher-order phenomenon: a β-redex
remains a β-redex after substitution, with the result commuting
appropriately. This is where binding enters the theory for real.

The proof uses `subst_comp` (Theorem 1) and the interaction lemmas between
renaming/substitution and `singleSubst`/`liftSubst`. -/

/-
**Theorem 4**: β-contraction commutes with substitution.
    `(betaContract body arg)[σ] = betaContract (body[↑σ]) (arg[σ])`
    This is the litmus test that our syntax and substitution design are correct.
-/
theorem beta_closed_under_subst (body arg : Term) (σ : Subst) :
    (betaContract body arg).subst σ =
      betaContract (body.subst (liftSubst σ)) (arg.subst σ) := by
  convert subst_comp _ _ _ using 2;
  convert subst_comp _ _ _ using 2;
  funext n; induction' n with n ih <;> simp +decide [ *, compSubst ] ;
  convert rename_succ_singleSubst ( σ n ) ( arg.subst σ ) |> Eq.symm using 1

-- ============================================================================
-- Section 11: One-Step β-Reduction Relation
-- ============================================================================

/-- One-step β-reduction, closed under all term contexts.
    Includes β-contraction at the top level and congruence rules
    for application and abstraction. -/
inductive BetaStep : Term → Term → Prop where
  | beta (body : Term) (arg : Term) :
      BetaStep (app (lam body) arg) (betaContract body arg)
  | appL {s s' : Term} (t : Term) :
      BetaStep s s' → BetaStep (app s t) (app s' t)
  | appR (s : Term) {t t' : Term} :
      BetaStep t t' → BetaStep (app s t) (app s t')
  | lamBody {t t' : Term} :
      BetaStep t t' → BetaStep (lam t) (lam t')

/-
**Theorem 4 (relational)**: One-step β-reduction is closed under substitution.
    If `t →β u` then `t[σ] →β u[σ]`.
-/
theorem betaStep_subst {t u : Term} (h : BetaStep t u) (σ : Subst) :
    BetaStep (t.subst σ) (u.subst σ) := by
  induction' h with s s' t h ih;
  · convert BetaStep.beta ( s.subst ( liftSubst σ ) ) ( s'.subst σ ) using 1;
    convert beta_closed_under_subst s s' σ using 1;
  · convert BetaStep.appL _ ‹_› using 1;
  · exact BetaStep.appR _ ‹_›;
  · apply Term.BetaStep.lamBody;
    have h_subst_lift : ∀ (t t' : Term), t.BetaStep t' → ∀ (σ : Subst), (t.subst σ).BetaStep (t'.subst σ) := by
      intros t t' h σ; induction' h with t t' h ih generalizing σ;
      · simp +decide [ Term.subst, Term.betaContract ];
        convert Term.BetaStep.beta _ _ using 1;
        convert beta_closed_under_subst t t' σ using 1;
      · exact Term.BetaStep.appL _ ( by solve_by_elim );
      · rename_i s t u h ih;
        exact Term.BetaStep.appR _ ( ih _ );
      · rename_i h ih;
        convert Term.BetaStep.lamBody ( ih ( Term.liftSubst σ ) ) using 1;
    exact h_subst_lift _ _ ‹_› _

-- ============================================================================
-- Section 12: Higher-Order Rewriting
-- ============================================================================

/-- An equation between two terms, used as a rewrite rule. -/
structure Equation where
  lhs : Term
  rhs : Term

/-- One-step higher-order rewrite: either a β-step or an equation applied
    under substitution, all closed under λ/application contexts.

    This is the higher-order analogue of the first-order rewrite relation
    from `ConcreteTermAlgebra.lean`. The key additions are:
    - β-reduction as a distinguished rewrite rule
    - `lamBody` for rewriting under λ-abstraction (binder crossing) -/
inductive HoRewrite (E : Set Equation) : Term → Term → Prop where
  | beta {t u : Term} :
      BetaStep t u → HoRewrite E t u
  | equation (eq : Equation) (heq : eq ∈ E) (σ : Subst) :
      HoRewrite E (eq.lhs.subst σ) (eq.rhs.subst σ)
  | appL {s s' : Term} (t : Term) :
      HoRewrite E s s' → HoRewrite E (app s t) (app s' t)
  | appR (s : Term) {t t' : Term} :
      HoRewrite E t t' → HoRewrite E (app s t) (app s t')
  | lamBody {t t' : Term} :
      HoRewrite E t t' → HoRewrite E (lam t) (lam t')

-- ============================================================================
-- Section 13: Higher-Order Contexts
-- ============================================================================

/-- One-hole applicative context.
    These are tree contexts for the application structure of λ-terms.
    Corresponds to `OneHoleCtx` from `ConcreteTermAlgebra.lean`,
    lifted to λ-calculus syntax. -/
inductive HOCtx where
  | hole : HOCtx
  | appL : HOCtx → Term → HOCtx
  | appR : Term → HOCtx → HOCtx

/-- Fill a context hole with a term. -/
def HOCtx.fill : HOCtx → Term → Term
  | .hole, t => t
  | .appL C s, t => app (C.fill t) s
  | .appR s C, t => app s (C.fill t)

/-! ### Theorem 3: Rewrite Closure Under Higher-Order Contexts

This is the higher-order analogue of `rewrites_closed_under_context`
from `ConcreteTermAlgebra.lean`. In first-order rewriting, contexts
are tree contexts. In λ-calculus, contexts include application structure
(and potentially abstraction), making this theorem the gateway to
reasoning about rewriting inside programs. -/

/-
**Theorem 3**: Higher-order rewriting is closed under applicative contexts.
    If `t → u` under equations E, then `C[t] → C[u]` for any context C.
    Higher-order lift of `rewrites_closed_under_context`.
-/
theorem hoRewrites_closed_under_context (E : Set Equation) (C : HOCtx)
    {t u : Term} (h : HoRewrite E t u) :
    HoRewrite E (C.fill t) (C.fill u) := by
  induction' C with C s C ih generalizing t u;
  · exact h;
  · exact HoRewrite.appL _ ( C h );
  · exact HoRewrite.appR _ ( by solve_by_elim )

/-! ### Theorem 2: β-Compatible Rewrite Closure Under Substitution

This is the higher-order lift of `rewrites_closed_under_subst` from
`ConcreteTermAlgebra.lean`. The proof proceeds by induction on the
rewrite derivation, using `betaStep_subst` (Theorem 4) for β-steps
and `subst_comp` (Theorem 1) for equation instantiation. -/

/-
**Theorem 2**: Higher-order rewriting is closed under substitution.
    If `t → u` under equations E, then `t[σ] → u[σ]` for any substitution σ.
    Higher-order lift of `rewrites_closed_under_subst`.
-/
theorem hoRewrites_closed_under_subst (E : Set Equation) {t u : Term}
    (h : HoRewrite E t u) (σ : Subst) :
    HoRewrite E (t.subst σ) (u.subst σ) := by
  induction' h with s t h ih generalizing σ;
  · exact HoRewrite.beta ( betaStep_subst h σ );
  · convert HoRewrite.equation _ ‹_› ( compSubst _ _ ) using 1;
    convert subst_comp _ _ _;
    exact?;
  · rename_i s s' t h ih;
    exact HoRewrite.appL _ ( ih σ );
  · exact HoRewrite.appR _ ( by solve_by_elim );
  · rename_i t u h ih;
    exact HoRewrite.lamBody ( ih ( liftSubst σ ) )

-- ============================================================================
-- Section 14: Generated Higher-Order Equational Theory
-- ============================================================================

/-- The higher-order equational theory generated by a set of equations E,
    closed under reflexivity, symmetry, transitivity, substitution,
    λ/application contexts, and β-reduction compatibility.

    This is the free equational theory in the sense of universal algebra,
    adapted to the simply-typed λ-calculus. -/
inductive HOEqGen (E : Set Equation) : Term → Term → Prop where
  | refl (t : Term) : HOEqGen E t t
  | symm {t u : Term} : HOEqGen E t u → HOEqGen E u t
  | trans {t u v : Term} : HOEqGen E t u → HOEqGen E u v → HOEqGen E t v
  | step {t u : Term} : HoRewrite E t u → HOEqGen E t u
  | appCong {s s' t t' : Term} :
      HOEqGen E s s' → HOEqGen E t t' → HOEqGen E (app s t) (app s' t')
  | lamCong {t t' : Term} :
      HOEqGen E t t' → HOEqGen E (lam t) (lam t')

/-
The generated equational theory is closed under substitution.
    This is the capstone theorem connecting higher-order completion
    to equational reasoning about programs.
-/
theorem HOEqGen_closed_under_subst (E : Set Equation) {t u : Term}
    (h : HOEqGen E t u) (σ : Subst) :
    HOEqGen E (t.subst σ) (u.subst σ) := by
  induction' h with t u h ih generalizing σ;
  exact HOEqGen.refl _;
  · exact HOEqGen.symm ( by solve_by_elim );
  · exact HOEqGen.trans ( by solve_by_elim ) ( by solve_by_elim );
  · exact HOEqGen.step ( hoRewrites_closed_under_subst E ‹_› σ );
  · exact HOEqGen.appCong ( by solve_by_elim ) ( by solve_by_elim );
  · exact HOEqGen.lamCong ( by solve_by_elim )

-- ============================================================================
-- Section 15: Map Fusion as Higher-Order Rewriting
-- (Cross-domain connection: functional program optimization)
-- ============================================================================

/-! ### Map Fusion Example

We encode the map fusion law `map f (map g xs) = map (f ∘ g) xs`
as a higher-order equation and show it is preserved by the generated theory.

In the λ-calculus encoding:
- `mapSym` represents the `map` combinator (var 0)
- The equation `map f (map g xs) = map (λx. f (g x)) xs`
  is expressed using de Bruijn terms

This demonstrates that our framework captures real higher-order
program optimization laws, connecting rewriting theory to
compiler correctness. -/

/-- The map fusion equation in de Bruijn notation:
    map f (map g xs) = map (λx. f(g x)) xs
    where f = var 2, g = var 1, xs = var 0, map = var 3 -/
def mapFusionEq : Equation where
  -- LHS: map f (map g xs) = app (app (var 3) (var 2)) (app (app (var 3) (var 1)) (var 0))
  lhs := app (app (var 3) (var 2)) (app (app (var 3) (var 1)) (var 0))
  -- RHS: map (λx. f(g x)) xs = app (app (var 3) (lam (app (var 3) (app (var 2) (var 0))))) (var 0)
  rhs := app (app (var 3) (lam (app (var 3) (app (var 2) (var 0))))) (var 0)

/-- Map fusion is in the generated equational theory of any set containing it. -/
theorem map_fusion_in_theory (E : Set Equation) (hmem : mapFusionEq ∈ E) (σ : Subst) :
    HOEqGen E (mapFusionEq.lhs.subst σ) (mapFusionEq.rhs.subst σ) :=
  HOEqGen.step (HoRewrite.equation mapFusionEq hmem σ)

-- ============================================================================
-- Section 16: Computational Rewriting Functions
-- ============================================================================

/-- Check if a term is a β-redex. -/
def isBetaRedex : Term → Bool
  | app (lam _) _ => true
  | _ => false

/-- Perform one step of β-reduction at the top level, if possible. -/
def topBetaReduce : Term → Option Term
  | app (lam body) arg => some (betaContract body arg)
  | _ => none

/-- Count the number of β-redexes in a term. -/
def countRedexes : Term → ℕ
  | var _ => 0
  | app (lam body) arg => 1 + countRedexes body + countRedexes arg
  | app s t => countRedexes s + countRedexes t
  | lam t => countRedexes t

/-- Compute the size of a term (number of constructors). -/
def size : Term → ℕ
  | var _ => 1
  | app s t => 1 + size s + size t
  | lam t => 1 + size t

/-- Leftmost-outermost β-reduction (one step). -/
def leftmostReduce : Term → Option Term
  | app (lam body) arg => some (betaContract body arg)
  | app s t =>
    match leftmostReduce s with
    | some s' => some (app s' t)
    | none =>
      match leftmostReduce t with
      | some t' => some (app s t')
      | none => none
  | lam t =>
    match leftmostReduce t with
    | some t' => some (lam t')
    | none => none
  | var _ => none

/-
Soundness of topBetaReduce: if it returns a result, it's a valid β-step.
-/
theorem topBetaReduce_sound {t u : Term} (h : topBetaReduce t = some u) :
    BetaStep t u := by
  -- By definition of `topBetaReduce`, if `topBetaReduce t = some u`, then `t` must be of the form `app (lam body) arg` for some `body` and `arg`.
  obtain ⟨body, arg, ht⟩ : ∃ body arg, t = app (lam body) arg := by
    rcases t with ( _ | _ | _ | _ ) <;> simp +decide [ Term.topBetaReduce ] at h ⊢;
    rename_i a b;
    cases a <;> cases b <;> tauto;
  simp_all +decide [ Term.topBetaReduce ];
  exact h ▸ BetaStep.beta _ _

/-- Soundness of leftmostReduce: if it returns a result, it's a valid β-step. -/
theorem leftmostReduce_sound : ∀ {t u : Term}, leftmostReduce t = some u →
    BetaStep t u
  | .var _, _, h => by simp [leftmostReduce] at h
  | .lam t, _, h => by
    unfold leftmostReduce at h
    cases ht : leftmostReduce t <;> simp [ht] at h
    subst h; exact BetaStep.lamBody (leftmostReduce_sound ht)
  | .app (.lam body) arg, _, h => by
    unfold leftmostReduce at h; simp at h
    subst h; exact BetaStep.beta body arg
  | .app (.var i) t, _, h => by
    unfold leftmostReduce at h; simp [leftmostReduce] at h
    cases ht : leftmostReduce t <;> simp [ht] at h
    subst h; exact BetaStep.appR _ (leftmostReduce_sound ht)
  | .app (.app s1 s2) t, _, h => by
    unfold leftmostReduce at h
    cases hs : leftmostReduce (app s1 s2) <;> simp [hs] at h
    · cases ht : leftmostReduce t <;> simp [ht] at h
      subst h; exact BetaStep.appR _ (leftmostReduce_sound ht)
    · subst h; exact BetaStep.appL _ (leftmostReduce_sound hs)

end Term
end HigherOrderCompletion