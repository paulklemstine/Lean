import Pythagorean.IntrinsicBetaEta.Core

/-!
# Intrinsically Typed Higher-Order Rewriting with βη-Completion — Main Theorems

This file builds on the substitution algebra from `Core.lean` to formalize
β-reduction, η-contraction, βη-equivalence, and higher-order equational generation
for intrinsically typed simply typed λ-terms.

## Main Results

* `betaEtaStep_closed_under_subst` — βη-steps are preserved by substitution
  (contains **Theorem 2**: η-stability under substitution as a key case)
* `hoEqGen_respects_betaEta` — **Theorem 3**: Higher-order equational generation
  descends to βη-equivalence classes
* `betaEtaStableTheory_generates_quotient_compatible` — βη-stable theories
  have quotient-compatible equational generation
-/

open IntrinsicBetaEta Relation

namespace IntrinsicBetaEta

-- ============================================================================
-- Section 1: βη-Reduction Steps
-- ============================================================================

/-- One-step βη-reduction for intrinsically typed terms. -/
inductive BetaEtaStep : {Γ : Ctx} → {A : Ty} → Tm Γ A → Tm Γ A → Prop where
  | beta {Γ : Ctx} {A B : Ty} (body : Tm (A :: Γ) B) (arg : Tm Γ A) :
      BetaEtaStep (.app (.lam body) arg) (subst (singleSub arg) body)
  | eta {Γ : Ctx} {A B : Ty} (f : Tm Γ (Ty.arr A B)) :
      BetaEtaStep (.lam (.app (rename wk f) (.var .vz))) f
  | congApp₁ {Γ : Ctx} {A B : Ty} {f f' : Tm Γ (Ty.arr A B)} {t : Tm Γ A} :
      BetaEtaStep f f' → BetaEtaStep (.app f t) (.app f' t)
  | congApp₂ {Γ : Ctx} {A B : Ty} {f : Tm Γ (Ty.arr A B)} {t t' : Tm Γ A} :
      BetaEtaStep t t' → BetaEtaStep (.app f t) (.app f t')
  | congLam {Γ : Ctx} {A B : Ty} {t t' : Tm (A :: Γ) B} :
      BetaEtaStep t t' → BetaEtaStep (.lam t) (.lam t')

/-- βη-equivalence: the equivalence closure of one-step βη-reduction. -/
def BetaEtaEq {Γ : Ctx} {A : Ty} (t u : Tm Γ A) : Prop :=
  Relation.EqvGen BetaEtaStep t u

-- ============================================================================
-- Section 2: βη-Equivalence — basic properties and congruence
-- ============================================================================

/-- βη-equivalence is an equivalence relation. -/
theorem betaEtaEq_is_equivalence {Γ : Ctx} {A : Ty} :
    Equivalence (@BetaEtaEq Γ A) where
  refl x := Relation.EqvGen.refl x
  symm h := Relation.EqvGen.symm _ _ h
  trans h₁ h₂ := Relation.EqvGen.trans _ _ _ h₁ h₂

/-- A single step gives βη-equivalence. -/
theorem BetaEtaEq.step {Γ : Ctx} {A : Ty} {t u : Tm Γ A}
    (h : BetaEtaStep t u) : BetaEtaEq t u :=
  Relation.EqvGen.rel _ _ h

/-
Helper: lift a function on EqvGen through congApp₁.
-/
theorem betaEtaEq_congr_app_left {Γ : Ctx} {A B : Ty}
    {f f' : Tm Γ (Ty.arr A B)} {t : Tm Γ A}
    (hf : BetaEtaEq f f') :
    BetaEtaEq (.app f t) (.app f' t) := by
  induction hf;
  · exact Relation.EqvGen.rel _ _ ( BetaEtaStep.congApp₁ ‹_› );
  · exact Relation.EqvGen.refl _;
  · apply Relation.EqvGen.symm; assumption;
  · exact EqvGen.trans _ _ _ ‹_› ‹_›

/-
Helper: lift a function on EqvGen through congApp₂.
-/
theorem betaEtaEq_congr_app_right {Γ : Ctx} {A B : Ty}
    {f : Tm Γ (Ty.arr A B)} {t t' : Tm Γ A}
    (ht : BetaEtaEq t t') :
    BetaEtaEq (.app f t) (.app f t') := by
  induction' ht with t t' ht ih;
  · exact Relation.EqvGen.rel _ _ ( BetaEtaStep.congApp₂ ht );
  · exact Relation.EqvGen.refl _;
  · apply EqvGen.symm; assumption;
  · exact Relation.EqvGen.trans _ _ _ ‹_› ‹_›

/-- Congruence of βη-equivalence under application. -/
theorem betaEtaEq_congr_app {Γ : Ctx} {A B : Ty}
    {f f' : Tm Γ (Ty.arr A B)} {t t' : Tm Γ A}
    (hf : BetaEtaEq f f') (ht : BetaEtaEq t t') :
    BetaEtaEq (.app f t) (.app f' t') :=
  (betaEtaEq_is_equivalence.trans
    (betaEtaEq_congr_app_left hf)
    (betaEtaEq_congr_app_right ht))

/-
Congruence of βη-equivalence under λ-abstraction.
-/
theorem betaEtaEq_congr_lam {Γ : Ctx} {A B : Ty}
    {t u : Tm (A :: Γ) B}
    (h : BetaEtaEq t u) :
    BetaEtaEq (.lam t) (.lam u) := by
  induction h;
  · exact Relation.EqvGen.rel _ _ ( BetaEtaStep.congLam ‹_› );
  · exact Relation.EqvGen.refl _;
  · exact betaEtaEq_is_equivalence.symm ‹_›;
  · exact EqvGen.trans _ _ _ ‹_› ‹_›

/-
============================================================================
Section 3: Key Substitution Lemma for β-Reduction
============================================================================

The substitution lemma for β-reduction.
-/
theorem beta_subst_lemma {Γ Δ : Ctx} {A B : Ty}
    (body : Tm (A :: Γ) B) (arg : Tm Γ A) (σ : Sub Γ Δ) :
    subst σ (subst (singleSub arg) body) =
    subst (singleSub (subst σ arg)) (subst (liftSub σ) body) := by
  rw [ subst_comp, subst_comp ];
  congr! 2;
  ext v; cases v <;> simp +decide [ compSub ] ;
  convert subst_id ( σ ‹_› ) using 1;
  · exact (subst_id (σ ‹_›)).symm;
  · convert subst_id ( σ ‹_› ) using 1;
    convert rename_subst _ _ _ using 2

/-
============================================================================
Section 4: βη-Steps Closed Under Substitution (Theorem 2)
============================================================================

**Theorem 2**: βη-steps are preserved by substitution.
    The η case uses `liftSub_natural`.
-/
theorem betaEtaStep_closed_under_subst {Γ Δ : Ctx} {A : Ty}
    {t u : Tm Γ A} (h : BetaEtaStep t u) (σ : Sub Γ Δ) :
    BetaEtaEq (subst σ t) (subst σ u) := by
  revert h σ;
  intro h;
  induction' h with t u h ih generalizing Δ;
  · intro σ;
    convert BetaEtaEq.step ( BetaEtaStep.beta ( subst ( liftSub σ ) ih ) ( subst σ ‹_› ) ) using 1;
    convert beta_subst_lemma ih ‹_› σ using 1;
  · intro σ;
    apply Relation.EqvGen.rel;
    convert BetaEtaStep.eta ( subst σ ‹_› ) using 1;
    simp +decide [ subst, liftSub_natural ];
  · rename_i f f' t h ih;
    exact fun σ => betaEtaEq_congr_app_left ( ih σ );
  · rename_i h ih;
    exact fun σ => betaEtaEq_congr_app_right ( ih σ );
  · rename_i k B t t' h ih;
    intro σ;
    convert betaEtaEq_congr_lam ( ih ( liftSub σ ) ) using 1

/-
βη-equivalence is closed under substitution.
-/
theorem betaEtaEq_closed_under_subst {Γ Δ : Ctx} {A : Ty}
    {t u : Tm Γ A} (h : BetaEtaEq t u) (σ : Sub Γ Δ) :
    BetaEtaEq (subst σ t) (subst σ u) := by
  convert subst_comp _ _ _;
  convert Iff.rfl;
  rotate_left;
  exact Γ;
  exact Δ;
  exact Δ;
  exact A;
  exact σ;
  exact fun v => Tm.var v;
  exact t;
  constructor <;> intro h <;> simp_all +decide [ subst_comp ] ; simp_all +decide [ BetaEtaEq ];
  induction h;
  · rename_i x y hxy;
    convert betaEtaStep_closed_under_subst hxy σ using 1;
  · exact EqvGen.refl _;
  · exact EqvGen.symm _ _ ‹_›;
  · exact EqvGen.trans _ _ _ ‹_› ‹_›

-- ============================================================================
-- Section 5: Higher-Order Equational Generation
-- ============================================================================

/-- The higher-order equational theory generated by `E`. -/
inductive HOEqGen (E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop) :
    {Γ : Ctx} → {A : Ty} → Tm Γ A → Tm Γ A → Prop where
  | base {Γ : Ctx} {A : Ty} {t u : Tm Γ A} :
      E t u → HOEqGen E t u
  | refl {Γ : Ctx} {A : Ty} {t : Tm Γ A} :
      HOEqGen E t t
  | symm {Γ : Ctx} {A : Ty} {t u : Tm Γ A} :
      HOEqGen E t u → HOEqGen E u t
  | trans {Γ : Ctx} {A : Ty} {t u v : Tm Γ A} :
      HOEqGen E t u → HOEqGen E u v → HOEqGen E t v
  | congApp {Γ : Ctx} {A B : Ty} {f g : Tm Γ (Ty.arr A B)} {t u : Tm Γ A} :
      HOEqGen E f g → HOEqGen E t u → HOEqGen E (.app f t) (.app g u)
  | congLam {Γ : Ctx} {A B : Ty} {t u : Tm (A :: Γ) B} :
      HOEqGen E t u → HOEqGen E (.lam t) (.lam u)
  | substClose {Γ Δ : Ctx} {A : Ty} {t u : Tm Γ A} :
      E t u → (σ : Sub Γ Δ) → HOEqGen E (subst σ t) (subst σ u)

/-
============================================================================
Section 6: Embedding βη into HOEqGen
============================================================================

A single βη-step embeds into HOEqGen of any rule set containing β and η.
-/
theorem betaEtaStep_in_HOEqGen
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop}
    (hβ : ∀ {Γ : Ctx} {A B : Ty} (body : Tm (A :: Γ) B) (arg : Tm Γ A),
      E (.app (.lam body) arg) (subst (singleSub arg) body))
    (hη : ∀ {Γ : Ctx} {A B : Ty} (f : Tm Γ (Ty.arr A B)),
      E (.lam (.app (rename wk f) (.var .vz))) f)
    {Γ : Ctx} {A : Ty} {t u : Tm Γ A}
    (h : BetaEtaStep t u) : HOEqGen E t u := by
  induction h;
  · exact HOEqGen.base ( hβ _ _ );
  · exact HOEqGen.base ( hη _ );
  · exact HOEqGen.congApp ‹_› ( HOEqGen.refl );
  · exact HOEqGen.congApp ( HOEqGen.refl ) ‹_›;
  · exact HOEqGen.congLam ‹_›

/-
βη-equivalence embeds into HOEqGen of any rule set containing β and η.
-/
theorem betaEtaEq_in_HOEqGen
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop}
    (hβ : ∀ {Γ : Ctx} {A B : Ty} (body : Tm (A :: Γ) B) (arg : Tm Γ A),
      E (.app (.lam body) arg) (subst (singleSub arg) body))
    (hη : ∀ {Γ : Ctx} {A B : Ty} (f : Tm Γ (Ty.arr A B)),
      E (.lam (.app (rename wk f) (.var .vz))) f)
    {Γ : Ctx} {A : Ty} {t u : Tm Γ A}
    (h : BetaEtaEq t u) : HOEqGen E t u := by
  -- We'll use induction on the definition of `BetaEtaEq`.
  induction' h with t u h ih;
  · exact betaEtaStep_in_HOEqGen hβ hη h;
  · exact HOEqGen.refl;
  · exact HOEqGen.symm ‹_›;
  · exact HOEqGen.trans ‹_› ‹_›

/-
============================================================================
Section 7: Flagship Theorem — HOEqGen Respects βη-Equivalence
============================================================================

**Theorem 3**: The generated equational theory descends to βη-equivalence classes.
-/
theorem hoEqGen_respects_betaEta
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop}
    (hβ : ∀ {Γ : Ctx} {A B : Ty} (body : Tm (A :: Γ) B) (arg : Tm Γ A),
      E (.app (.lam body) arg) (subst (singleSub arg) body))
    (hη : ∀ {Γ : Ctx} {A B : Ty} (f : Tm Γ (Ty.arr A B)),
      E (.lam (.app (rename wk f) (.var .vz))) f)
    {Γ : Ctx} {A : Ty} {t t' u u' : Tm Γ A}
    (htu : HOEqGen E t u)
    (htt' : BetaEtaEq t t')
    (huu' : BetaEtaEq u u') :
    HOEqGen E t' u' := by
  -- Use betaEtaEq_in_HOEqGen to embed BetaEtaEq into HOEqGen E.
  have h_betaEtaEq_in_HOEqGen : BetaEtaEq t t' → HOEqGen E t t' :=
    fun a => betaEtaEq_in_HOEqGen hβ hη a
  have h_betaEtaEq_in_HOEqGen_u : BetaEtaEq u u' → HOEqGen E u u' :=
    fun a => betaEtaEq_in_HOEqGen hβ hη a
  exact HOEqGen.trans ( HOEqGen.symm ( h_betaEtaEq_in_HOEqGen htt' ) ) ( HOEqGen.trans htu ( h_betaEtaEq_in_HOEqGen_u huu' ) )

-- ============================================================================
-- Section 8: βη-Stable Rewrite Theory and Quotient Compatibility
-- ============================================================================

/-- A βη-stable higher-order rewrite theory. -/
structure BetaEtaStableTheory where
  Rule : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop
  subst_closed :
    ∀ {Γ Δ : Ctx} {A : Ty} {t u : Tm Γ A},
      Rule t u → ∀ (σ : Sub Γ Δ), HOEqGen Rule (subst σ t) (subst σ u)
  beta_included :
    ∀ {Γ : Ctx} {A B : Ty} (body : Tm (A :: Γ) B) (arg : Tm Γ A),
      Rule (.app (.lam body) arg) (subst (singleSub arg) body)
  eta_included :
    ∀ {Γ : Ctx} {A B : Ty} (f : Tm Γ (Ty.arr A B)),
      Rule (.lam (.app (rename wk f) (.var .vz))) f

/-- A βη-stable theory has quotient-compatible equational generation. -/
theorem betaEtaStableTheory_generates_quotient_compatible
    (T : BetaEtaStableTheory)
    {Γ : Ctx} {A : Ty} {t t' u u' : Tm Γ A}
    (htu : HOEqGen T.Rule t u)
    (htt' : BetaEtaEq t t')
    (huu' : BetaEtaEq u u') :
    HOEqGen T.Rule t' u' :=
  hoEqGen_respects_betaEta T.beta_included T.eta_included htu htt' huu'

/-
============================================================================
Section 9: HOEqGen Closed Under Substitution
============================================================================

The generated equational theory is closed under substitution.
-/
theorem hoEqGen_closed_under_subst
    {E : ∀ {Γ : Ctx} {A : Ty}, Tm Γ A → Tm Γ A → Prop}
    (hsub : ∀ {Γ Δ : Ctx} {A : Ty} {t u : Tm Γ A},
      E t u → ∀ (σ : Sub Γ Δ), HOEqGen E (subst σ t) (subst σ u))
    {Γ Δ : Ctx} {A : Ty} {t u : Tm Γ A}
    (h : HOEqGen E t u) (σ : Sub Γ Δ) :
    HOEqGen E (subst σ t) (subst σ u) := by
  induction h generalizing Δ;
  exact hsub ‹_› σ;
  exact HOEqGen.refl;
  · exact HOEqGen.symm ( by solve_by_elim );
  · exact HOEqGen.trans ( by solve_by_elim ) ( by solve_by_elim );
  · exact HOEqGen.congApp ( by solve_by_elim ) ( by solve_by_elim );
  · exact HOEqGen.congLam ( by solve_by_elim );
  · rename_i Γ' Δ' _ t₁ u₁ h_base σ'
    rw [subst_comp σ' σ t₁, subst_comp σ' σ u₁]
    exact hsub h_base (compSub σ σ')

end IntrinsicBetaEta