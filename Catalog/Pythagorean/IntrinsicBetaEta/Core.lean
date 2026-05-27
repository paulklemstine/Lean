import Mathlib

/-!
# Intrinsically Typed Higher-Order Rewriting with βη-Completion — Core Definitions

This file formalizes the **intrinsically typed syntax** of simply typed λ-calculus using
de Bruijn indices, together with the complete substitution algebra (renamings and
substitutions as typed environment morphisms). All terms are well-scoped and well-typed
by construction.

## Main Definitions

* `Ty` — Simple types (base types and function types)
* `Ctx` — Typing contexts as lists of types
* `Var Γ A` — Well-typed de Bruijn variables (membership proofs)
* `Tm Γ A` — Intrinsically typed λ-terms
* `Ren Γ Δ` — Typed renamings (environment morphisms on variables)
* `Sub Γ Δ` — Typed substitutions (environment morphisms to terms)
* `liftRen`, `liftSub` — Lifting under binders
* `rename`, `subst` — Application of renamings/substitutions to terms
* `compSub` — Composition of substitutions

## Main Results (Substitution Algebra)

* `rename_ext` — Extensionality for renaming
* `subst_ext` — Extensionality for substitution
* `rename_id` — Identity renaming is identity on terms
* `rename_comp` — Renaming is functorial: `rename ρ₂ (rename ρ₁ t) = rename (ρ₂ ∘ ρ₁) t`
* `rename_subst` — Interaction: `subst σ (rename ρ t) = subst (σ ∘ ρ) t`
* `subst_rename` — Interaction: `rename ρ (subst σ t) = subst (rename ρ ∘ σ) t`
* `subst_id` — Identity substitution is identity on terms
* `liftSub_natural` — Key naturality: `subst (liftSub σ) (rename wk t) = rename wk (subst σ t)`
* `subst_comp` — **Theorem 1**: Substitution is functorial (composition law)

## Cross-Domain: Categorical Semantics

Typed substitutions form a category whose objects are contexts and whose morphisms
are substitutions. `subst_comp` and `compSub_assoc` establish the functoriality and
associativity laws, making `Tm` a presheaf over the category of contexts — the
Fiore–Plotkin–Turi substitutional structure for abstract syntax with binding.

## References

* Builds on patterns from `Pythagorean/ConcreteTermAlgebra.lean` (first-order `subst_comp`)
* Extends to intrinsically typed setting with de Bruijn indices
-/

namespace IntrinsicBetaEta

-- ============================================================================
-- Section 1: Types and Contexts
-- ============================================================================

/-- Simple types: base types indexed by natural numbers, and function (arrow) types. -/
inductive Ty where
  | base : Nat → Ty
  | arr  : Ty → Ty → Ty
deriving DecidableEq, Repr

/-- A typing context is a list of types. -/
abbrev Ctx := List Ty

-- ============================================================================
-- Section 2: Variables (intrinsically typed de Bruijn indices)
-- ============================================================================

/-- A variable `Var Γ A` is a proof that type `A` appears in context `Γ`. -/
inductive Var : Ctx → Ty → Type where
  | vz : Var (A :: Γ) A
  | vs : Var Γ A → Var (B :: Γ) A

-- ============================================================================
-- Section 3: Terms (intrinsically typed)
-- ============================================================================

/-- Intrinsically typed λ-terms with de Bruijn indices. -/
inductive Tm : Ctx → Ty → Type where
  | var : Var Γ A → Tm Γ A
  | app : Tm Γ (Ty.arr A B) → Tm Γ A → Tm Γ B
  | lam : Tm (A :: Γ) B → Tm Γ (Ty.arr A B)

-- ============================================================================
-- Section 4: Renamings
-- ============================================================================

/-- A renaming from `Γ` to `Δ` maps variables preserving types. -/
abbrev Ren (Γ Δ : Ctx) := ∀ {A : Ty}, Var Γ A → Var Δ A

/-- Lift a renaming under one binder. -/
def liftRen {Γ Δ : Ctx} {B : Ty} (ρ : Ren Γ Δ) {A : Ty} : Var (B :: Γ) A → Var (B :: Δ) A
  | Var.vz => Var.vz
  | Var.vs v => Var.vs (ρ v)

/-- Apply a renaming to a term. -/
def rename {Γ Δ : Ctx} (ρ : Ren Γ Δ) {A : Ty} : Tm Γ A → Tm Δ A
  | .var v => .var (ρ v)
  | .app f t => .app (rename ρ f) (rename ρ t)
  | .lam body => .lam (rename (liftRen ρ) body)

/-- The weakening renaming: shifts all variables up by one. -/
abbrev wk {Γ : Ctx} {B : Ty} {A : Ty} : Var Γ A → Var (B :: Γ) A := Var.vs

-- ============================================================================
-- Section 5: Substitutions
-- ============================================================================

/-- A substitution from `Γ` to `Δ` maps variables to terms. -/
abbrev Sub (Γ Δ : Ctx) := ∀ {A : Ty}, Var Γ A → Tm Δ A

/-- Lift a substitution under one binder. -/
def liftSub {Γ Δ : Ctx} {B : Ty} (σ : Sub Γ Δ) {A : Ty} : Var (B :: Γ) A → Tm (B :: Δ) A
  | Var.vz => Tm.var Var.vz
  | Var.vs v => rename wk (σ v)

/-- Apply a substitution to a term. -/
def subst {Γ Δ : Ctx} (σ : Sub Γ Δ) {A : Ty} : Tm Γ A → Tm Δ A
  | .var v => σ v
  | .app f t => .app (subst σ f) (subst σ t)
  | .lam body => .lam (subst (liftSub σ) body)

/-- The identity substitution maps each variable to itself. -/
def idSub {Γ : Ctx} : Sub Γ Γ := @Tm.var Γ

/-- Single substitution: substitute the top variable with `s`. -/
def singleSub {Γ : Ctx} {A : Ty} (s : Tm Γ A) {B : Ty} : Var (A :: Γ) B → Tm Γ B
  | Var.vz => s
  | Var.vs v => Tm.var v

/-- Composition of substitutions. -/
def compSub {Γ Δ Ξ : Ctx} (τ : Sub Δ Ξ) (σ : Sub Γ Δ) : Sub Γ Ξ :=
  fun v => subst τ (σ v)

-- ============================================================================
-- Section 6: Simp lemmas for definitional unfolding
-- ============================================================================

@[simp] theorem liftRen_vz {Γ Δ : Ctx} {B : Ty} {ρ : Ren Γ Δ} :
    @liftRen Γ Δ B ρ B Var.vz = Var.vz := rfl

@[simp] theorem liftRen_vs {Γ Δ : Ctx} {A B : Ty} {ρ : Ren Γ Δ} {v : Var Γ A} :
    @liftRen Γ Δ B ρ A (Var.vs v) = Var.vs (ρ v) := rfl

@[simp] theorem rename_var {Γ Δ : Ctx} {A : Ty} {ρ : Ren Γ Δ} {v : Var Γ A} :
    rename ρ (Tm.var v) = Tm.var (ρ v) := rfl

@[simp] theorem rename_app {Γ Δ : Ctx} {A B : Ty} {ρ : Ren Γ Δ}
    {f : Tm Γ (Ty.arr A B)} {t : Tm Γ A} :
    rename ρ (Tm.app f t) = Tm.app (rename ρ f) (rename ρ t) := rfl

@[simp] theorem rename_lam {Γ Δ : Ctx} {A B : Ty} {ρ : Ren Γ Δ}
    {body : Tm (A :: Γ) B} :
    rename ρ (Tm.lam body) = Tm.lam (rename (liftRen ρ) body) := rfl

@[simp] theorem liftSub_vz {Γ Δ : Ctx} {B : Ty} {σ : Sub Γ Δ} :
    @liftSub Γ Δ B σ B Var.vz = Tm.var Var.vz := rfl

@[simp] theorem liftSub_vs {Γ Δ : Ctx} {A B : Ty} {σ : Sub Γ Δ} {v : Var Γ A} :
    @liftSub Γ Δ B σ A (Var.vs v) = rename wk (σ v) := rfl

@[simp] theorem subst_var {Γ Δ : Ctx} {A : Ty} {σ : Sub Γ Δ} {v : Var Γ A} :
    subst σ (Tm.var v) = σ v := rfl

@[simp] theorem subst_app {Γ Δ : Ctx} {A B : Ty} {σ : Sub Γ Δ}
    {f : Tm Γ (Ty.arr A B)} {t : Tm Γ A} :
    subst σ (Tm.app f t) = Tm.app (subst σ f) (subst σ t) := rfl

@[simp] theorem subst_lam {Γ Δ : Ctx} {A B : Ty} {σ : Sub Γ Δ}
    {body : Tm (A :: Γ) B} :
    subst σ (Tm.lam body) = Tm.lam (subst (liftSub σ) body) := rfl

@[simp] theorem singleSub_vz {Γ : Ctx} {A : Ty} {s : Tm Γ A} :
    @singleSub Γ A s A Var.vz = s := rfl

@[simp] theorem singleSub_vs {Γ : Ctx} {A B : Ty} {s : Tm Γ A} {v : Var Γ B} :
    @singleSub Γ A s B (Var.vs v) = Tm.var v := rfl

-- ============================================================================
-- Section 7: Extensionality Principles
-- ============================================================================

/-- Renaming extensionality: if two renamings agree on all variables,
    they produce the same result on any term. -/
theorem rename_ext {Γ Δ : Ctx} {A : Ty} {ρ₁ ρ₂ : Ren Γ Δ}
    (h : ∀ {B : Ty} (v : Var Γ B), ρ₁ v = ρ₂ v)
    (t : Tm Γ A) : rename ρ₁ t = rename ρ₂ t := by
  induction t generalizing Δ with
  | var v => simp [rename, h]
  | app f t ihf iht => simp [rename]; exact ⟨ihf h, iht h⟩
  | lam body ih =>
    simp [rename]
    exact ih (fun v => by cases v <;> simp [liftRen, h])

/-- Substitution extensionality: if two substitutions agree on all variables,
    they produce the same result on any term. -/
theorem subst_ext {Γ Δ : Ctx} {A : Ty} {σ₁ σ₂ : Sub Γ Δ}
    (h : ∀ {B : Ty} (v : Var Γ B), σ₁ v = σ₂ v)
    (t : Tm Γ A) : subst σ₁ t = subst σ₂ t := by
  induction t generalizing Δ with
  | var v => simp [subst, h]
  | app f t ihf iht => simp [subst]; exact ⟨ihf h, iht h⟩
  | lam body ih =>
    simp [subst]
    exact ih (fun v => by cases v <;> simp [liftSub, h])

-- ============================================================================
-- Section 8: Renaming Algebra
-- ============================================================================

/-- Identity renaming is the identity on terms. -/
theorem rename_id {Γ : Ctx} {A : Ty} (t : Tm Γ A) :
    rename (fun v => v) t = t := by
  induction t with
  | var v => rfl
  | app f t ihf iht => simp [rename, ihf, iht]
  | lam body ih =>
    simp [rename]
    conv_rhs => rw [← ih]
    exact rename_ext (fun v => by cases v <;> rfl) body

/-- Renaming is functorial: composing two renamings gives the same result
    as applying them sequentially. -/
theorem rename_comp {Γ Δ Ξ : Ctx} {A : Ty}
    (ρ₁ : Ren Γ Δ) (ρ₂ : Ren Δ Ξ) (t : Tm Γ A) :
    rename ρ₂ (rename ρ₁ t) = rename (fun v => ρ₂ (ρ₁ v)) t := by
  induction t generalizing Δ Ξ with
  | var v => simp [rename]
  | app f t ihf iht => simp [rename]; exact ⟨ihf ρ₁ ρ₂, iht ρ₁ ρ₂⟩
  | lam body ih =>
    simp [rename, ih (liftRen ρ₁) (liftRen ρ₂)]
    exact rename_ext (fun v => by cases v <;> simp [liftRen]) body

/-
============================================================================
Section 9: Renaming–Substitution Interaction
============================================================================

Substituting after renaming: `subst σ (rename ρ t) = subst (σ ∘ ρ) t`.
-/
theorem rename_subst {Γ Δ Ξ : Ctx} {A : Ty}
    (ρ : Ren Γ Δ) (σ : Sub Δ Ξ) (t : Tm Γ A) :
    subst σ (rename ρ t) = subst (fun v => σ (ρ v)) t := by
  induction t generalizing Δ Ξ;
  · rfl;
  · aesop;
  · rename_i k B t ih;
    convert congr_arg Tm.lam ( ih ( liftRen ρ ) ( liftSub σ ) ) using 1;
    convert subst_lam using 2;
    congr! 1;
    ext A v; cases v <;> simp +decide [ liftSub, liftRen ] ;

/-
Renaming after substituting: `rename ρ (subst σ t) = subst (rename ρ ∘ σ) t`.
-/
theorem subst_rename {Γ Δ Ξ : Ctx} {A : Ty}
    (σ : Sub Γ Δ) (ρ : Ren Δ Ξ) (t : Tm Γ A) :
    rename ρ (subst σ t) = subst (fun v => rename ρ (σ v)) t := by
  induction' t with t ih generalizing Δ Ξ;
  · rfl;
  · aesop;
  · rename_i k B a ih;
    -- Apply the induction hypothesis to the inner term `a`.
    apply congr_arg Tm.lam;
    convert ih ( fun { A } v => liftSub σ v ) ( fun { A } v => liftRen ρ v ) using 1;
    congr! 2;
    ext v; cases v <;> simp +decide [ * ] ;
    iterate 2 convert rename_comp _ _ _ using 1

/-
============================================================================
Section 10: Substitution Algebra
============================================================================

Identity substitution is the identity on terms.
-/
theorem subst_id {Γ : Ctx} {A : Ty} (t : Tm Γ A) :
    subst idSub t = t := by
  convert subst_ext _;
  rotate_left;
  exact Γ;
  exact Γ;
  exact A;
  exact fun v => Tm.var v;
  exact fun v => Tm.var v;
  · grind;
  · constructor <;> intro hop;
    · exact fun _ => rfl;
    · convert subst_ext _;
      rotate_left;
      exact A :: Γ;
      exact A :: Γ;
      exact A;
      exact fun v => Tm.var v;
      exact fun v => Tm.var v;
      · exact fun { B } v => rfl;
      · constructor <;> intro h;
        · exact fun t => rfl;
        · induction t <;> simp +decide [ * ];
          · rfl;
          · rename_i k hk ih;
            convert ih ( fun _ => rfl ) ( fun _ => rfl ) using 1;
            congr! 1;
            ext; simp [liftSub, idSub];
            rename_i A v; cases v <;> rfl;

/-
**Key naturality lemma**: lifting a substitution and applying it to a weakened
    term equals weakening the substituted term.

    `subst (liftSub σ) (rename wk t) = rename wk (subst σ t)`
-/
theorem liftSub_natural {Γ Δ : Ctx} {A B : Ty} (σ : Sub Γ Δ)
    (t : Tm Γ A) :
    subst (@liftSub Γ Δ B σ) (rename wk t) = rename wk (subst σ t) := by
  rw [ rename_subst, subst_rename ];
  congr! 2

/-
**Theorem 1 (Typed Substitution Composition)**: Substitution is functorial.
    `subst τ (subst σ t) = subst (compSub τ σ) t`

    This is the intrinsically typed analogue of `FOTerm.subst_comp` from
    `Pythagorean/ConcreteTermAlgebra.lean`. The `lam` case requires genuine
    interaction between lifted substitutions, handled via `liftSub_natural`.
-/
theorem subst_comp {Γ Δ Ξ : Ctx} {A : Ty}
    (σ : Sub Γ Δ) (τ : Sub Δ Ξ) (t : Tm Γ A) :
    subst τ (subst σ t) = subst (compSub τ σ) t := by
  induction' t with A t B f t ih generalizing Δ Ξ;
  · aesop;
  · aesop;
  · rename_i A Γ B t ih;
    convert congr_arg Tm.lam ( ih ( liftSub σ ) ( liftSub τ ) ) using 1;
    simp +decide [ compSub ];
    congr! 2;
    funext v; cases v <;> simp +decide [ liftSub, compSub ] ;
    convert liftSub_natural τ ( σ ‹_› ) |> Eq.symm using 1

/-
============================================================================
Section 11: Categorical Law — Associativity of Substitution Composition
============================================================================

**Cross-domain theorem (Category Theory)**: Substitution composition is associative.
    Together with `subst_comp` and `subst_id`, this establishes that contexts
    and substitutions form a category.
-/
theorem compSub_assoc {Γ Δ Ξ Ω : Ctx}
    (σ : Sub Γ Δ) (τ : Sub Δ Ξ) (υ : Sub Ξ Ω) :
    ∀ {A : Ty} (v : Var Γ A),
    compSub υ (compSub τ σ) v = compSub (compSub υ τ) σ v := by
  intros A v; exact (by
  convert subst_comp _ _ _);

end IntrinsicBetaEta