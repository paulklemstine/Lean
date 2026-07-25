import Mathlib

/-!
# Intrinsically Typed Higher-Order Rewriting with βη-Completion

This file establishes a theory of **intrinsically typed higher-order rewriting modulo βη**
for simply typed λ-calculus, where all terms are well-scoped and well-typed by construction,
substitution is structurally functorial, and generated equations descend to βη-quotients.

## Main Results

* `subst_comp` — Typed substitution composition (Theorem 1)
* `eta_closed_under_subst` — η-stability under substitution (Theorem 2)
* `hoEqGen_respects_betaEta` — Quotient descent (Theorem 3)
* `compSub_assoc` — Substitution category associativity
* `betaEtaEq_closed_under_subst` — βη-equivalence substitution stability

## Catalog Connections

* `Pythagorean/ConcreteTermAlgebra.lean`: `FOTerm.subst_comp` is the first-order prototype.
* `Pythagorean/HigherOrderCompletion.lean`: Untyped `hoRewrite_beta_stable_under_closed_subst`.

application keywords: higher-order rewriting, simply typed λ-calculus, βη-equivalence,
intrinsic typing, de Bruijn indices, substitution calculus, extensional equality,
completion procedures, categorical semantics, compiler correctness, proof normalization,
rewriting modulo, abstract syntax with binding
-/

namespace IntrinsicBetaEta

-- ============================================================================
-- Section 1: Types, Contexts, Variables, Terms
-- ============================================================================

inductive Ty where
  | base : Nat → Ty
  | arr  : Ty → Ty → Ty
deriving DecidableEq, Repr

abbrev Ctx := List Ty

inductive Var : Ctx → Ty → Type where
  | vz : Var (A :: Γ) A
  | vs : Var Γ A → Var (B :: Γ) A

inductive Tm : Ctx → Ty → Type where
  | var : Var Γ A → Tm Γ A
  | app : Tm Γ (Ty.arr A B) → Tm Γ A → Tm Γ B
  | lam : Tm (A :: Γ) B → Tm Γ (Ty.arr A B)

-- ============================================================================
-- Section 2: Renamings
-- ============================================================================

abbrev Ren (Γ Δ : Ctx) := (A : Ty) → Var Γ A → Var Δ A

def liftRen {B : Ty} (ρ : Ren Γ Δ) : Ren (B :: Γ) (B :: Δ)
  | _, .vz => .vz
  | _, .vs v => .vs (ρ _ v)

def wk : @Ren Γ (B :: Γ) := fun _ v => .vs v

def rename (ρ : Ren Γ Δ) : Tm Γ A → Tm Δ A
  | .var v => .var (ρ _ v)
  | .app f t => .app (rename ρ f) (rename ρ t)
  | .lam body => .lam (rename (liftRen ρ) body)

-- ============================================================================
-- Section 3: Substitutions
-- ============================================================================

abbrev Sub (Γ Δ : Ctx) := (A : Ty) → Var Γ A → Tm Δ A

def liftSub {B : Ty} (σ : Sub Γ Δ) : Sub (B :: Γ) (B :: Δ)
  | _, .vz => .var .vz
  | _, .vs v => rename wk (σ _ v)

def subst (σ : Sub Γ Δ) : Tm Γ A → Tm Δ A
  | .var v => σ _ v
  | .app f t => .app (subst σ f) (subst σ t)
  | .lam body => .lam (subst (liftSub σ) body)

def compSub (τ : Sub Δ Ξ) (σ : Sub Γ Δ) : Sub Γ Ξ :=
  fun A v => subst τ (σ A v)

def idSub : Sub Γ Γ := fun _ v => .var v

def singleSub {A : Ty} (t : Tm Γ A) : Sub (A :: Γ) Γ
  | _, .vz => t
  | _, .vs v => .var v

-- ============================================================================
-- Section 4: Extensionality
-- ============================================================================

theorem rename_ext (ρ₁ ρ₂ : Ren Γ Δ)
    (h : ∀ A (v : Var Γ A), ρ₁ A v = ρ₂ A v)
    (t : Tm Γ A) :
    rename ρ₁ t = rename ρ₂ t := by
  induction t generalizing Δ with
  | var v => exact congrArg Tm.var (h _ v)
  | app f t ihf iht =>
    show Tm.app (rename ρ₁ f) (rename ρ₁ t) = Tm.app (rename ρ₂ f) (rename ρ₂ t)
    rw [ihf _ _ h, iht _ _ h]
  | lam body ih =>
    show Tm.lam (rename (liftRen ρ₁) body) = Tm.lam (rename (liftRen ρ₂) body)
    congr 1
    exact ih _ _ (fun A v => by
      cases v with | vz => rfl | vs v => exact congrArg Var.vs (h _ v))

theorem subst_ext (σ₁ σ₂ : Sub Γ Δ)
    (h : ∀ A (v : Var Γ A), σ₁ A v = σ₂ A v)
    (t : Tm Γ A) :
    subst σ₁ t = subst σ₂ t := by
  induction t generalizing Δ with
  | var v => exact h _ v
  | app f t ihf iht =>
    show Tm.app (subst σ₁ f) (subst σ₁ t) = Tm.app (subst σ₂ f) (subst σ₂ t)
    rw [ihf _ _ h, iht _ _ h]
  | lam body ih =>
    show Tm.lam (subst (liftSub σ₁) body) = Tm.lam (subst (liftSub σ₂) body)
    congr 1
    exact ih _ _ (fun A v => by
      cases v with | vz => rfl | vs v => exact congrArg (rename wk) (h _ v))

/-
============================================================================
Section 5: Renaming Lemmas
============================================================================
-/
theorem rename_id (t : Tm Γ A) :
    rename (fun _ v => v) t = t := by
  induction' t with A B f t ih;
  · rfl;
  · exact congr_arg₂ ( ·.app · ) ‹rename ( fun x v => v ) _ = _› ‹rename ( fun x v => v ) _ = _›;
  · -- By definition of rename, we have that rename (fun x v => v) (lam body) = lam (rename (fun x v => v) body).
    simp [rename];
    rename_i A Γ B t ih;
    convert ih using 1;
    congr! 1;
    funext x v; cases v <;> rfl;

theorem rename_comp (ρ₁ : Ren Γ Δ) (ρ₂ : Ren Δ Ξ) (t : Tm Γ A) :
    rename ρ₂ (rename ρ₁ t) = rename (fun A v => ρ₂ A (ρ₁ A v)) t := by
  induction' t with A B ih generalizing Δ Ξ;
  · rfl;
  · simp_all +decide [ rename ];
  · simp +decide [ *, rename ];
    congr! 2;
    ext ( _ | v ) <;> rfl

/-
============================================================================
Section 6: Renaming-Substitution Interaction
============================================================================
-/
theorem rename_subst (ρ : Ren Γ Δ) (σ : Sub Δ Ξ) (t : Tm Γ A) :
    subst σ (rename ρ t) = subst (fun A v => σ A (ρ A v)) t := by
  induction' t with A t ih generalizing Δ Ξ;
  · rfl;
  · simp_all!;
  · rename_i A B t ih;
    convert congr_arg Tm.lam ( ih ( liftRen ρ ) ( liftSub σ ) ) using 1;
    exact congr_arg _ ( subst_ext _ _ ( fun A v => by cases v <;> rfl ) _ )

theorem subst_rename (σ : Sub Γ Δ) (ρ : Ren Δ Ξ) (t : Tm Γ A) :
    rename ρ (subst σ t) = subst (fun A v => rename ρ (σ A v)) t := by
  have h_ind : ∀ (t : Tm Γ A), rename ρ (subst σ t) = subst (fun A v => rename ρ (σ A v)) t := by
    intro t
    induction' t with A B t1 t2 ih1 ih2 generalizing Δ Ξ;
    · rfl;
    · simp +decide [ *, rename, subst ];
      tauto;
    · rename_i A Γ B t ih;
      simp +decide [ subst, rename ];
      convert ih ( liftSub σ ) ( liftRen ρ ) _ using 1;
      · congr! 2;
        funext v; cases v <;> simp +decide [ liftSub, liftRen ] ;
        · rfl;
        · rw [ rename_comp ];
          exact?;
      · exact ‹Tm ( A :: Γ ) B›;
  exact h_ind t

/-
============================================================================
Section 7: Substitution Composition (Theorem 1)
============================================================================

Lifting distributes over composition—the heart of `subst_comp`.
-/
theorem liftSub_compSub (σ : Sub Γ Δ) (τ : Sub Δ Ξ) {B : Ty}
    (A : Ty) (v : Var (B :: Γ) A) :
    subst (liftSub τ) (liftSub σ A v) = liftSub (compSub τ σ) A v := by
  cases v <;> simp_all +decide [ compSub, liftSub ];
  · rfl;
  · rw [ rename_subst, subst_rename ];
    congr! 2

/-
**Theorem 1: Typed Substitution Composition.**
    Intrinsic analogue of `FOTerm.subst_comp` from `ConcreteTermAlgebra.lean`.
-/
theorem subst_comp (σ : Sub Γ Δ) (τ : Sub Δ Ξ) (t : Tm Γ A) :
    subst τ (subst σ t) = subst (compSub τ σ) t := by
  induction' t with A B f t ihf iht generalizing Δ Ξ;
  · rfl;
  · simp +decide [ *, subst ];
  · rename_i A Γ t ih; simp +decide [ *, subst ] ;
    congr! 1;
    ext A v; exact liftSub_compSub σ τ A v;

theorem subst_id (t : Tm Γ A) : subst idSub t = t := by
  -- We'll use induction on the term `t` to prove that `subst idSub t = t`.
  induction' t with A B t ih;
  · rfl;
  · exact congr_arg₂ Tm.app ‹_› ‹_›;
  · rename_i A B t ih;
    convert congr_arg Tm.lam ( ih ) using 1;
    exact congr_arg Tm.lam ( subst_ext _ _ ( fun A v => by
      cases v <;> aesop ) _ )

-- ============================================================================
-- Section 8: Category of Substitutions
-- ============================================================================

theorem compSub_idSub_right (σ : Sub Γ Δ) (A : Ty) (v : Var Γ A) :
    compSub σ idSub A v = σ A v := rfl

theorem compSub_idSub_left (σ : Sub Γ Δ) (A : Ty) (v : Var Γ A) :
    compSub idSub σ A v = σ A v := by
  convert subst_id _

/-
Associativity of substitution composition.
-/
theorem compSub_assoc (σ : Sub Γ Δ) (τ : Sub Δ Ξ) (υ : Sub Ξ Ω)
    (A : Ty) (v : Var Γ A) :
    compSub υ (compSub τ σ) A v = compSub (compSub υ τ) σ A v := by
  convert subst_comp _ _ _

-- ============================================================================
-- Section 9: β-Reduction and η-Contraction
-- ============================================================================

inductive BetaStep : Tm Γ A → Tm Γ A → Prop where
  | beta : (body : Tm (A :: Γ) B) → (arg : Tm Γ A) →
           BetaStep (.app (.lam body) arg) (subst (singleSub arg) body)

inductive EtaStep : Tm Γ A → Tm Γ A → Prop where
  | eta : (f : Tm Γ (Ty.arr A B)) →
          EtaStep (.lam (.app (rename wk f) (.var .vz))) f

-- ============================================================================
-- Section 10: βη-Equivalence
-- ============================================================================

inductive BetaEtaEq : Tm Γ A → Tm Γ A → Prop where
  | beta : BetaStep t u → BetaEtaEq t u
  | eta  : EtaStep t u → BetaEtaEq t u
  | refl : BetaEtaEq t t
  | symm : BetaEtaEq t u → BetaEtaEq u t
  | trans : BetaEtaEq t u → BetaEtaEq u v → BetaEtaEq t v
  | congApp : BetaEtaEq f g → BetaEtaEq t u →
              BetaEtaEq (.app f t) (.app g u)
  | congLam : BetaEtaEq t u → BetaEtaEq (.lam t) (.lam u)

theorem betaEtaEq_is_equivalence : Equivalence (@BetaEtaEq Γ A) where
  refl := fun _ => .refl
  symm := BetaEtaEq.symm
  trans := BetaEtaEq.trans

-- ============================================================================
-- Section 11: Higher-Order Equational Generation
-- ============================================================================

inductive HOEqGen (E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop) :
    Tm Γ A → Tm Γ A → Prop where
  | rule : E t u → HOEqGen E t u
  | refl : HOEqGen E t t
  | symm : HOEqGen E t u → HOEqGen E u t
  | trans : HOEqGen E t u → HOEqGen E u v → HOEqGen E t v
  | congApp : HOEqGen E f g → HOEqGen E t u →
              HOEqGen E (.app f t) (.app g u)
  | congLam : HOEqGen E t u → HOEqGen E (.lam t) (.lam u)

/-
============================================================================
Section 12: β-Stability Under Substitution
============================================================================
-/
theorem beta_closed_under_subst
    {t u : Tm Γ A} (h : BetaStep t u) (σ : Sub Γ Δ) :
    BetaStep (subst σ t) (subst σ u) := by
  cases h;
  rename_i A' t u;
  convert BetaStep.beta ( subst ( liftSub σ ) u ) ( subst σ t ) using 1;
  convert subst_comp ( singleSub t ) σ u using 1;
  rw [ subst_comp ];
  congr! 1;
  ext A v; cases v <;> simp +decide [ compSub, liftSub, singleSub ] ;
  · rfl;
  · convert subst_id _ using 1;
    convert rename_subst _ _ _ using 1

-- ============================================================================
-- Section 13: η-Stability Under Substitution (Theorem 2)
-- ============================================================================

/-- Substituting under a lift commutes with weakening. -/
theorem subst_liftSub_rename_wk {B : Ty} (σ : Sub Γ Δ) (t : Tm Γ A) :
    subst (liftSub (B := B) σ) (rename (wk (B := B)) t) =
    rename (wk (B := B)) (subst σ t) := by
  rw [rename_subst, subst_rename]
  exact subst_ext _ _ (fun _ _ => rfl) _

/-- **Theorem 2: η-contraction is stable under substitution.** -/
theorem eta_closed_under_subst
    {t u : Tm Γ A} (h : EtaStep t u) (σ : Sub Γ Δ) :
    EtaStep (subst σ t) (subst σ u) := by
  cases h with
  | eta f =>
    show EtaStep (.lam (subst (liftSub σ) (.app (rename wk f) (.var .vz)))) (subst σ f)
    show EtaStep (.lam (.app (subst (liftSub σ) (rename wk f)) (liftSub σ _ .vz))) (subst σ f)
    simp only [liftSub]
    rw [subst_liftSub_rename_wk]
    exact EtaStep.eta (subst σ f)

-- ============================================================================
-- Section 14: HOEqGen Theorems
-- ============================================================================

theorem betaEtaEq_to_hoEqGen
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop}
    (hβ : ∀ {Γ A} {t u : Tm Γ A}, BetaStep t u → E t u)
    (hη : ∀ {Γ A} {t u : Tm Γ A}, EtaStep t u → E t u)
    {t u : Tm Γ A} (h : BetaEtaEq t u) : HOEqGen E t u := by
  induction h with
  | beta h => exact .rule (hβ h)
  | eta h => exact .rule (hη h)
  | refl => exact .refl
  | symm _ ih => exact .symm ih
  | trans _ _ ih₁ ih₂ => exact .trans ih₁ ih₂
  | congApp _ _ ihf iht => exact .congApp ihf iht
  | congLam _ ih => exact .congLam ih

/-- **Theorem 3: HOEqGen descends to βη-equivalence classes.** -/
theorem hoEqGen_respects_betaEta
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop}
    (hβ : ∀ {Γ A} {t u : Tm Γ A}, BetaStep t u → E t u)
    (hη : ∀ {Γ A} {t u : Tm Γ A}, EtaStep t u → E t u)
    {t t' u u' : Tm Γ A}
    (heq : HOEqGen E t u)
    (htt' : BetaEtaEq t t')
    (huu' : BetaEtaEq u u') :
    HOEqGen E t' u' :=
  .trans (.trans (.symm (betaEtaEq_to_hoEqGen hβ hη htt')) heq)
    (betaEtaEq_to_hoEqGen hβ hη huu')

/-
HOEqGen is closed under substitution when the base rules are.
-/
theorem hoEqGen_closed_under_subst
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop}
    (hsub : ∀ {Γ Δ A} {t u : Tm Γ A}, E t u →
      ∀ (σ : Sub Γ Δ), HOEqGen E (subst σ t) (subst σ u))
    {t u : Tm Γ A} (h : HOEqGen E t u) (σ : Sub Γ Δ) :
    HOEqGen E (subst σ t) (subst σ u) := by
  induction h generalizing Δ;
  grind;
  · exact HOEqGen.refl;
  · exact HOEqGen.symm ( by solve_by_elim );
  · exact HOEqGen.trans ( by solve_by_elim ) ( by solve_by_elim );
  · exact HOEqGen.congApp ( by solve_by_elim ) ( by solve_by_elim );
  · exact HOEqGen.congLam ( by solve_by_elim )

-- ============================================================================
-- Section 15: βη-Stable Rewrite Theory
-- ============================================================================

structure BetaEtaStableTheory where
  Rule : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop
  subst_closed :
    ∀ {Γ Δ A} {t u : Tm Γ A}, Rule t u →
      ∀ (σ : Sub Γ Δ), HOEqGen Rule (subst σ t) (subst σ u)
  beta_included :
    ∀ {Γ A} {t u : Tm Γ A}, BetaStep t u → Rule t u
  eta_included :
    ∀ {Γ A} {t u : Tm Γ A}, EtaStep t u → Rule t u

theorem betaEtaStable_quotient_descent (T : BetaEtaStableTheory)
    {t t' u u' : Tm Γ A}
    (heq : HOEqGen T.Rule t u)
    (htt' : BetaEtaEq t t')
    (huu' : BetaEtaEq u u') :
    HOEqGen T.Rule t' u' :=
  hoEqGen_respects_betaEta T.beta_included T.eta_included heq htt' huu'

-- ============================================================================
-- Section 16: Congruence and Equivalence
-- ============================================================================

theorem betaEtaEq_congr_app {f f' : Tm Γ (Ty.arr A B)} {t t' : Tm Γ A}
    (hf : BetaEtaEq f f') (ht : BetaEtaEq t t') :
    BetaEtaEq (.app f t) (.app f' t') := .congApp hf ht

theorem betaEtaEq_congr_lam {t u : Tm (A :: Γ) B}
    (h : BetaEtaEq t u) : BetaEtaEq (.lam t) (.lam u) := .congLam h

theorem hoEqGen_is_equivalence
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop} :
    Equivalence (fun (t u : Tm Γ A) => HOEqGen E t u) where
  refl := fun _ => .refl
  symm := HOEqGen.symm
  trans := HOEqGen.trans

/-
============================================================================
Section 17: βη-Equivalence Stability Under Substitution
============================================================================
-/
theorem betaEtaEq_closed_under_subst
    {t u : Tm Γ A} (h : BetaEtaEq t u) (σ : Sub Γ Δ) :
    BetaEtaEq (subst σ t) (subst σ u) := by
  induction h generalizing Δ with | beta hb => exact .beta (beta_closed_under_subst hb σ) | eta he => exact .eta (eta_closed_under_subst he σ) | refl => exact .refl | symm _ ih => exact .symm (ih σ) | trans _ _ ih₁ ih₂ => exact .trans (ih₁ σ) (ih₂ σ) | congApp _ _ ihf iht => exact .congApp (ihf σ) (iht σ) | congLam _ ih => exact .congLam (ih (liftSub σ))

-- ============================================================================
-- Section 18: Minimal βη-Stable Theory
-- ============================================================================

inductive MinBetaEtaRule : Tm Γ A → Tm Γ A → Prop where
  | beta : BetaStep t u → MinBetaEtaRule t u
  | eta  : EtaStep t u → MinBetaEtaRule t u

theorem minBetaEtaRule_subst_closed
    {t u : Tm Γ A} (h : MinBetaEtaRule t u) (σ : Sub Γ Δ) :
    HOEqGen MinBetaEtaRule (subst σ t) (subst σ u) := by
  cases h with
  | beta hb => exact .rule (.beta (beta_closed_under_subst hb σ))
  | eta he => exact .rule (.eta (eta_closed_under_subst he σ))

def minBetaEtaTheory : BetaEtaStableTheory where
  Rule := MinBetaEtaRule
  subst_closed := fun h σ => minBetaEtaRule_subst_closed h σ
  beta_included := MinBetaEtaRule.beta
  eta_included := MinBetaEtaRule.eta

theorem minBetaEta_hoEqGen_iff_betaEtaEq {t u : Tm Γ A} :
    HOEqGen MinBetaEtaRule t u ↔ BetaEtaEq t u := by
  constructor
  · intro h
    induction h with
    | rule hr =>
      cases hr with
      | beta hb => exact .beta hb
      | eta he => exact .eta he
    | refl => exact .refl
    | symm _ ih => exact .symm ih
    | trans _ _ ih₁ ih₂ => exact .trans ih₁ ih₂
    | congApp _ _ ihf iht => exact .congApp ihf iht
    | congLam _ ih => exact .congLam ih
  · intro h
    exact betaEtaEq_to_hoEqGen MinBetaEtaRule.beta MinBetaEtaRule.eta h

/-
============================================================================
Section 19: Renaming as Substitution
============================================================================
-/
theorem rename_is_subst (ρ : Ren Γ Δ) (t : Tm Γ A) :
    rename ρ t = subst (fun A v => .var (ρ A v)) t := by
  -- Apply the rename_ext theorem to the rename� t and subst (fun A v => Tm.var (ρ A v)) t functions.
  have h_rename_subst : rename ρ t = subst (fun A v => Tm.var (ρ A v)) t := by
    have h_eq : ∀ A (v : Var Γ A), (fun A v => Tm.var (ρ A v)) A v = Tm.var (ρ A v) := by
      exact fun _ _ => rfl
    convert subst_ext _ _ _ _ using 1;
    convert rename_subst ρ _ t using 1;
    rotate_left;
    exact?; all_goals exact?;
  exact h_rename_subst

end IntrinsicBetaEta