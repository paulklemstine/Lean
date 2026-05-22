import Mathlib

/-!
# Verified Compiler Synthesis via Free-Forgetful Adjunctions

This file formalizes the principle that **adjunctions synthesize certified interpreters**.
The key insight is that the categorical universal property (adjunction transpose / homEquiv)
is not merely a specification device but a **compiler construction mechanism** yielding
executable semantics with proof-carrying correctness.

## Main Results

- `InterpreterSpec`: A structure packaging the idea that a free construction induces
  executable semantics via the adjunction transpose.
- `SemanticComplete`: A property asserting that an interpreter is characterized uniquely
  by extension from generators.
- `adjoint_semantics_principle`: Any adjunction is `SemanticComplete`.
- `freeMonoid_eval_eq_adj_transpose`: `FreeMonoid.lift` = adjunction transpose of `MonCat.adj`.
- `freeGroup_eval_eq_adj_transpose`: `FreeGroup.lift` = adjunction transpose of `GrpCat.adj`.
- `freeAbelianGroup_eval_eq_adj_transpose`: `FreeAbelianGroup.lift` = adjunction transpose.
- `freeMonoid_eval_natural`: Naturality of the monoid evaluator (backend-independence).
- `freeGroup_eval_natural`: Naturality of the group evaluator.
- `endomorphism_preserves_semantics`: General optimizer soundness.
- `synthesized_eval_natural_generic`: Abstract backend-independence from adjunction naturality.
-/

open CategoryTheory

noncomputable section

/-! ## Section 1: Generic Definitions -/

/-- A structure packaging the idea that a free construction induces executable semantics
via the adjunction transpose. Given a forgetful functor `U : Sem ⥤ Syn`, an
`InterpreterSpec` consists of a left adjoint `F` together with the adjunction, and
records that the evaluation map is exactly the adjunction transpose. -/
structure InterpreterSpec
    (Syn : Type u₁) (Sem : Type u₂)
    [Category.{v₁} Syn] [Category.{v₂} Sem]
    (U : Sem ⥤ Syn) where
  /-- The free functor (left adjoint to `U`). -/
  F : Syn ⥤ Sem
  /-- The adjunction `F ⊣ U`. -/
  adj : F ⊣ U
  /-- The evaluation map: given a variable assignment `X ⟶ U.obj A`, produce
      a morphism `F.obj X ⟶ A` in the semantic category. -/
  eval : ∀ {X : Syn} {A : Sem}, (X ⟶ U.obj A) → (F.obj X ⟶ A)
  /-- The evaluation map agrees with the adjunction transpose. -/
  eval_eq_transpose :
    ∀ {X : Syn} {A : Sem} (ρ : X ⟶ U.obj A),
      eval ρ = (adj.homEquiv X A).symm ρ

/-- A property asserting that an interpreter is characterized uniquely by extension
from generators. For every variable assignment `ρ : X ⟶ U.obj A`, there exists a
*unique* morphism `g : F.obj X ⟶ A` such that `ρ` is the transpose of `g`. -/
def SemanticComplete
    {C : Type u₁} {D : Type u₂}
    [Category.{v₁} C] [Category.{v₂} D]
    (U : D ⥤ C) (F : C ⥤ D) (h : F ⊣ U) : Prop :=
  ∀ {X : C} {A : D} (ρ : X ⟶ U.obj A),
    ∃! g : F.obj X ⟶ A,
      ρ = (h.homEquiv X A) g

/-! ## Section 2: The Adjoint Semantics Principle -/

/-
**The Adjoint Semantics Principle.** Any adjunction `F ⊣ U` is `SemanticComplete`:
for every variable assignment `ρ : X ⟶ U.obj A`, there exists a unique morphism
`g : F.obj X ⟶ A` whose adjunction transpose equals `ρ`.

This is the core theorem: a compiler can be *derived* from the universal mapping
property of an adjunction.
-/
theorem adjoint_semantics_principle
    {C : Type u₁} {D : Type u₂}
    [Category.{v₁} C] [Category.{v₂} D]
    (U : D ⥤ C) (F : C ⥤ D) (adj : F ⊣ U) :
    SemanticComplete U F adj := by
  intro X A ρ
  use (adj.homEquiv X A).symm ρ
  constructor
  · simp
  · intro g hg
    aesop

/-- Construct an `InterpreterSpec` from any adjunction. -/
def InterpreterSpec.ofAdjunction
    {Syn : Type u₁} {Sem : Type u₂}
    [Category.{v₁} Syn] [Category.{v₂} Sem]
    (U : Sem ⥤ Syn) (F : Syn ⥤ Sem) (adj : F ⊣ U) :
    InterpreterSpec Syn Sem U where
  F := F
  adj := adj
  eval ρ := (adj.homEquiv _ _).symm ρ
  eval_eq_transpose _ := rfl

/-- An `InterpreterSpec` built from an adjunction is always `SemanticComplete`. -/
theorem InterpreterSpec.semanticComplete
    {Syn : Type u₁} {Sem : Type u₂}
    [Category.{v₁} Syn] [Category.{v₂} Sem]
    (U : Sem ⥤ Syn) (F : Syn ⥤ Sem) (adj : F ⊣ U) :
    SemanticComplete U F adj :=
  adjoint_semantics_principle U F adj

/-! ## Section 3: Concrete Evaluators -/

/-- The verified evaluator for free monoids. -/
def evalFreeMonoid {X : Type*} {M : Type*} [Monoid M] :
    (X → M) → (FreeMonoid X →* M) :=
  FreeMonoid.lift

/-- The verified evaluator for free groups. -/
def evalFreeGroup {X : Type*} {G : Type*} [Group G] :
    (X → G) → (FreeGroup X →* G) :=
  FreeGroup.lift

/-- The verified evaluator for free abelian groups. -/
def evalFreeAbelianGroup {X : Type*} {A : Type*} [AddCommGroup A] :
    (X → A) → (FreeAbelianGroup X →+ A) :=
  FreeAbelianGroup.lift

/-! ## Section 4: Adjunction-Synthesized Evaluators Match Concrete Ones -/

/-
The adjunction transpose of `MonCat.adj` agrees with `FreeMonoid.lift`.
This identifies the abstractly synthesized interpreter with the concrete evaluator.
-/
theorem freeMonoid_eval_eq_adj_transpose
    {X : Type u} {M : Type u} [Monoid M]
    (ρ : X → M) :
    (MonCat.adj.homEquiv X (MonCat.of M)).symm ρ =
      MonCat.ofHom (evalFreeMonoid ρ) := by
  simp +decide [ MonCat.adj, evalFreeMonoid ];
  simp +decide [ConcreteCategory.homEquiv]
  grind +splitImp

/-
The adjunction transpose of `GrpCat.adj` agrees with `FreeGroup.lift`.
-/
theorem freeGroup_eval_eq_adj_transpose
    {X : Type u} {G : Type u} [Group G]
    (ρ : X → G) :
    (GrpCat.adj.homEquiv X (GrpCat.of G)).symm ρ =
      GrpCat.ofHom (evalFreeGroup ρ) := by
  -- By definition of the adjunction, the homEquiv is the inverse of the lift function.
  apply GrpCat.Hom.ext;
  ext x.ext_hom;
  induction x.ext_hom using FreeGroup.induction_on ; aesop;
  · simp +decide [ GrpCat.adj, GrpCat.ofHom, evalFreeGroup ];
    simp +decide [ ConcreteCategory.homEquiv, ConcreteCategory.ofHom ];
    grind;
  · simp_all +decide [ GrpCat.ofHom ];
  · grind

/-
The adjunction transpose of `AddCommGrpCat.adj` agrees with
`FreeAbelianGroup.lift`.
-/
theorem freeAbelianGroup_eval_eq_adj_transpose
    {X : Type u} {A : Type u} [AddCommGroup A]
    (ρ : X → A) :
    (AddCommGrpCat.adj.homEquiv X (AddCommGrpCat.of A)).symm ρ =
      AddCommGrpCat.ofHom (evalFreeAbelianGroup ρ) := by
  ext x; simp [AddCommGrpCat.adj]
  exact AddMonoidHom.mem_eqLocusM.mp rfl

/-! ## Section 5: Naturality — Compiler Backend Independence -/

/-
**Naturality of the monoid evaluator (backend-independence).**
Postcomposition with a monoid homomorphism `φ : M →* N` commutes with
the evaluator: compiling into `M` and then applying `φ` is the same as
compiling directly into `N` with `φ ∘ ρ`.
-/
theorem freeMonoid_eval_natural
    {X : Type*} {M N : Type*} [Monoid M] [Monoid N]
    (ρ : X → M) (φ : M →* N) :
    φ.comp (evalFreeMonoid ρ) = evalFreeMonoid (φ ∘ ρ) := by
  aesop

/-
**Naturality of the group evaluator (backend-independence).**
-/
theorem freeGroup_eval_natural
    {X : Type*} {G H : Type*} [Group G] [Group H]
    (ρ : X → G) (φ : G →* H) :
    φ.comp (evalFreeGroup ρ) = evalFreeGroup (φ ∘ ρ) := by
  -- By definition of `evalFreeGroup`, we know that `evalFreeGroup ρ` is the unique group homomorphism from the free group on `X` to `G` that extends `ρ`.
  ext x
  simp [evalFreeGroup]

/-
**Naturality of the abelian group evaluator.**
-/
theorem freeAbelianGroup_eval_natural
    {X : Type*} {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (ρ : X → A) (φ : A →+ B) :
    φ.comp (evalFreeAbelianGroup ρ) = evalFreeAbelianGroup (φ ∘ ρ) := by
  unfold evalFreeAbelianGroup;
  ext x;
  simp +decide

/-! ## Section 6: Optimizer Soundness -/

/-- A canonical endomorphism of the free monoid: maps each generator to itself.
By the universal property, this is the identity. The proof structure generalizes
to nontrivial optimizers. -/
def optimizeFreeMonoid {X : Type*} : FreeMonoid X →* FreeMonoid X :=
  FreeMonoid.lift FreeMonoid.of

/-
The canonical optimizer is the identity.
-/
theorem optimizeFreeMonoid_eq_id {X : Type*} :
    (optimizeFreeMonoid : FreeMonoid X →* FreeMonoid X) = MonoidHom.id _ := by
  refine' MonoidHom.ext fun x => _;
  induction x using FreeMonoid.inductionOn <;> aesop

/-
**Optimizer soundness.** Evaluating after optimizing gives the same result
as evaluating directly.
-/
theorem optimizer_semantics_preserved
    {X M : Type*} [Monoid M]
    (ρ : X → M) :
    (evalFreeMonoid ρ).comp optimizeFreeMonoid = evalFreeMonoid ρ := by
  exact FreeMonoid.hom_eq_iff.mpr (congrFun rfl)

/-
**General optimizer soundness.** Any endomorphism of the free monoid
that preserves generators preserves semantics. This follows from the
universal property: two homomorphisms out of a free monoid agreeing on
generators must be equal.
-/
theorem endomorphism_preserves_semantics
    {X M : Type*} [Monoid M]
    (opt : FreeMonoid X →* FreeMonoid X)
    (h_gen : ∀ x : X, opt (FreeMonoid.of x) = FreeMonoid.of x)
    (ρ : X → M) :
    (evalFreeMonoid ρ).comp opt = evalFreeMonoid ρ := by
  aesop

/-! ## Section 7: Compositionality via Adjunction Naturality -/

/-
**Abstract backend-independence.** For any adjunction `F ⊣ U`,
the inverse transpose is natural in the target: composing with `φ : A ⟶ B`
after transposing `ρ` is the same as transposing `ρ ≫ U.map φ`.
-/
theorem synthesized_eval_natural_generic
    {C : Type u₁} {D : Type u₂}
    [Category.{v₁} C] [Category.{v₂} D]
    {F : C ⥤ D} {U : D ⥤ C} (adj : F ⊣ U)
    {X : C} {A B : D}
    (ρ : X ⟶ U.obj A) (φ : A ⟶ B) :
    (adj.homEquiv X A).symm ρ ≫ φ =
      (adj.homEquiv X B).symm (ρ ≫ U.map φ) := by
  convert adj.homEquiv_naturality_right_symm ρ φ |> Eq.symm using 1

end