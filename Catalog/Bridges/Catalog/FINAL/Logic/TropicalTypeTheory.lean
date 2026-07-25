/-
# Tropical Type Theory: Dependent Types in the Min-Plus Semiring

A formalization of the semantic kernel of tropical dependent type theory,
where types are tropical predicates (cost functions), terms are cost-respecting
maps, identity is min-plus equality, and inductive types arise as initial algebras.

## Overview

This file establishes:
1. Decidability of tropical type checking on finite contexts
2. Tropical identity as idempotent min-equality
3. Initial algebra semantics for tropical inductive types
4. Well-foundedness of a tropical universe hierarchy with idempotent normalization
5. Composition laws forming a semantic calculus
6. Tropical subtyping lattice structure
7. Tropical dependent products (Π-types)
8. Typing judgments with weakening and cut
-/

import Mathlib

/-! ## Core Definitions -/

/-- A tropical set over `α` is a cost/rank function `α → ℕ`. -/
def TropSet (α : Type) := α → ℕ

/-- A tropical term over `α` is a cost-valued function `α → ℕ`. -/
def TropTerm (α : Type) := α → ℕ

/-- A tropical homomorphism: `f` is a morphism from `A` to `B` when
    the cost of the image never exceeds the cost of the source.
    This is the typing judgment `A ⊢ f : B`. -/
def TropHom {α β : Type} (A : TropSet α) (B : TropSet β) (f : α → β) : Prop :=
  ∀ x, B (f x) ≤ A x

/-- Cost-bounded tropical homomorphism with slack `c`. -/
def TropHomC {α β : Type} (c : ℕ) (A : TropSet α) (B : TropSet β) (f : α → β) : Prop :=
  ∀ x, B (f x) ≤ A x + c

/-- Tropical identity: two maps are tropically indistinguishable under `B`
    when they produce equal costs on all inputs. -/
def TropId {α β : Type} (B : TropSet β) (f g : α → β) : Prop :=
  ∀ x, B (f x) = B (g x)

/-- Tropical equality of terms: pointwise equality of cost functions. -/
def TropEq {α : Type} (u v : TropTerm α) : Prop := ∀ x, u x = v x

/-! ## Section 1: Decidability of Tropical Type Checking -/

/-- On finite types, tropical type checking is decidable:
    we can verify `∀ x, B (f x) ≤ A x` by checking finitely many points. -/
instance tropical_typecheck_decidable
    {α β : Type} [Fintype α] [DecidableEq α]
    (A : TropSet α) (B : TropSet β) (f : α → β) :
    Decidable (TropHom A B f) := by
  unfold TropHom; infer_instance

/-- Tropical type checking reduces to checking all elements of a finite type. -/
theorem tropical_typecheck_iff_forall_finset
    {α β : Type} [Fintype α]
    (A : TropSet α) (B : TropSet β) (f : α → β) :
    TropHom A B f ↔
      ∀ x ∈ Finset.univ, B (f x) ≤ A x := by
  simp [TropHom]

/-- Cost-bounded type checking is also decidable on finite types. -/
instance tropical_typecheck_bounded_decidable
    {α β : Type} [Fintype α] [DecidableEq α]
    (c : ℕ) (A : TropSet α) (B : TropSet β) (f : α → β) :
    Decidable (TropHomC c A B f) := by
  unfold TropHomC; infer_instance

/-! ## Section 2: Tropical Identity and Min-Plus Equality -/

/-- Tropical identity is reflexive. -/
theorem TropId.refl {α β : Type} (B : TropSet β) (f : α → β) : TropId B f f :=
  fun _ => rfl

/-- Tropical identity is symmetric. -/
theorem TropId.symm {α β : Type} {B : TropSet β} {f g : α → β}
    (h : TropId B f g) : TropId B g f :=
  fun x => (h x).symm

/-- Tropical identity is transitive. -/
theorem TropId.trans {α β : Type} {B : TropSet β} {f g h : α → β}
    (hfg : TropId B f g) (hgh : TropId B g h) : TropId B f h :=
  fun x => (hfg x).trans (hgh x)

/-- If the cost function `B` is injective, tropical identity implies
    pointwise equality of functions. This is the tropical extensionality principle. -/
theorem tropId_implies_eq_of_cost_injective
    {α β : Type} {B : TropSet β} {f g : α → β}
    (hB : Function.Injective B)
    (h : TropId B f g) :
    f = g := by
  funext x; exact hB (h x)

/-- **Tropical identity equals min-plus equality**: two cost functions are
    equal iff their pointwise min is equal to both. This is the fundamental
    characterization of identity through idempotent algebra. -/
theorem tropical_identity_eq_minplus_equality
    {α : Type} (u v : TropTerm α) :
    TropEq u v ↔ ∀ x, min (u x) (v x) = u x ∧ min (u x) (v x) = v x := by
  constructor
  · intro h x; constructor <;> simp [h x]
  · intro h x; have ⟨hu, hv⟩ := h x; omega

/-- Min is idempotent: the foundational law of tropical algebra. -/
theorem min_idempotent_nat (a : ℕ) : min a a = a := Nat.min_self a

/-! ## Section 3: Composition and the Semantic Calculus -/

/-- Composition of tropical homomorphisms preserves typing. -/
theorem TropHom.comp
    {α β γ : Type} {A : TropSet α} {B : TropSet β} {C : TropSet γ}
    {f : α → β} {g : β → γ}
    (hf : TropHom A B f) (hg : TropHom B C g) :
    TropHom A C (g ∘ f) :=
  fun x => le_trans (hg (f x)) (hf x)

/-- **Composition of cost-bounded morphisms**: costs add under composition.
    This is a substitution theorem: composing two bounded maps yields a
    map bounded by the sum of costs. -/
theorem TropHomC.comp
    {α β γ : Type} {A : TropSet α} {B : TropSet β} {C : TropSet γ}
    {c₁ c₂ : ℕ} {f : α → β} {g : β → γ}
    (hf : TropHomC c₁ A B f) (hg : TropHomC c₂ B C g) :
    TropHomC (c₁ + c₂) A C (g ∘ f) := by
  intro x; have h1 := hg (f x); have h2 := hf x
  simp only [Function.comp]; omega

/-- The identity function is a zero-cost tropical homomorphism. -/
theorem TropHom.id {α : Type} (A : TropSet α) : TropHom A A id :=
  fun _ => le_refl _

/-- Tropical equality is a congruence under composition with min. -/
theorem TropEq.congr_min
    {α : Type} {u v w : TropTerm α}
    (h : TropEq u v) :
    TropEq (fun x => min (u x) (w x)) (fun x => min (v x) (w x)) := by
  intro x; simp only [h x]

/-- Tropical identity is a congruence under precomposition. -/
theorem TropId.congr_comp {α β γ : Type} {B : TropSet β}
    {f g : α → β} (h : TropId B f g) (k : γ → α) :
    TropId B (f ∘ k) (g ∘ k) :=
  fun x => h (k x)

/-- **Distributivity of addition over min** — the fundamental law
    connecting cost composition with tropical meet. -/
theorem tropical_plus_distributes_over_min (a b c : ℕ) :
    a + min b c = min (a + b) (a + c) := by omega

/-! ## Section 4: Initial Algebra Semantics for Tropical Inductive Types -/

/-- A tropical algebra for the polynomial functor `F X = 1 ⊕ X` (i.e. `Option X`). -/
structure TropAlg where
  A : Type
  str : Option A → A

/-- The natural numbers form a tropical algebra under `Option`. -/
def NatTropAlg : TropAlg where
  A := ℕ
  str := fun
    | none => 0
    | some n => n.succ

/-- An algebra homomorphism between tropical algebras. -/
def IsAlgHom (X Y : TropAlg) (f : X.A → Y.A) : Prop :=
  ∀ z, f (X.str z) = Y.str (Option.map f z)

/-
**Initiality of ℕ**: The natural numbers are the initial algebra for
    the Option functor. For any tropical algebra `X`, there exists a unique
    algebra homomorphism from `ℕ` to `X`. This is the tropical analogue
    of the recursion principle for inductive types.
-/
theorem nat_initial_tropAlg (X : TropAlg) :
    ∃! f : ℕ → X.A, IsAlgHom NatTropAlg X f := by
  refine' ⟨ fun n => Nat.recOn n ( X.str none ) fun n ih => X.str ( some ih ), _, _ ⟩ <;> simp_all +decide [ IsAlgHom ];
  · rintro ( _ | n ) <;> rfl;
  · intro y hy; funext n; induction' n with n ih <;> simp_all +decide [ NatTropAlg ] ;
    · simpa using hy none;
    · simpa [ ih ] using hy ( some n )

/-- A ranked tropical algebra: an algebra equipped with a rank function
    that mirrors the natural number structure. -/
structure RankedTropAlg where
  A : Type
  rank : A → ℕ
  str : Option A → A
  rank_zero : rank (str none) = 0
  rank_succ : ∀ a, rank (str (some a)) = rank a + 1

/-
**Rank-preserving initiality**: The unique homomorphism from ℕ to any
    ranked tropical algebra preserves rank.
-/
theorem nat_initial_rank_preserving
    (X : RankedTropAlg) :
    ∃! f : ℕ → X.A,
      IsAlgHom
        { A := ℕ, str := fun | none => 0 | some n => n + 1 }
        { A := X.A, str := X.str } f
      ∧ ∀ n, X.rank (f n) = n := by
  refine' ⟨ fun n => Nat.recOn n ( X.str none ) fun n ih => X.str ( some ih ), _, _ ⟩;
  · refine' ⟨ _, _ ⟩;
    · intro x; cases x <;> rfl;
    · intro n; induction n <;> simp_all +decide [ RankedTropAlg.rank_zero, RankedTropAlg.rank_succ ] ;
  · rintro f ⟨ hf₁, hf₂ ⟩;
    funext n;
    induction n <;> simp_all +decide [ IsAlgHom ];
    · simpa using hf₁ none;
    · specialize hf₁ ( some ‹_› ) ; aesop;

/-! ## Section 5: Well-Founded Tropical Universe Hierarchy -/

/-- Tropical universe codes are natural numbers representing complexity levels. -/
def TropCode := ℕ

/-- The rank of a tropical code. -/
def codeRank : TropCode → ℕ := id

/-- Strict ordering on tropical codes by rank. -/
def TropCodeLT (u v : TropCode) : Prop := codeRank u < codeRank v

/-- **Well-foundedness of the tropical universe hierarchy**:
    the strict rank ordering on codes is well-founded. -/
theorem tropUniverse_wellFounded : WellFounded TropCodeLT :=
  InvImage.wf id Nat.lt_wfRel.wf

/-- Normalization of tropical codes: maps each code to a canonical representative.
    Defined as `min n K` for a fixed complexity bound `K`, modeling
    the idea that codes above a certain rank collapse to a normal form. -/
def normalizeCode (K : ℕ) (u : TropCode) : TropCode := Nat.min u K

/-- **Idempotence of code normalization**: normalizing twice is the same as
    normalizing once. This is the tropical analogue of universe normalization. -/
theorem normalizeCode_idempotent (K : ℕ) :
    ∀ u, normalizeCode K (normalizeCode K u) = normalizeCode K u := by
  intro u; unfold normalizeCode; simp [Nat.min_def]; split_ifs <;> omega

/-- Normalization is rank-nonincreasing. -/
theorem normalizeCode_rank_le (K : ℕ) (u : TropCode) :
    codeRank (normalizeCode K u) ≤ codeRank u := by
  unfold codeRank normalizeCode id; exact Nat.min_le_left u K

/-
**Well-foundedness of the normalized universe**: the rank ordering restricted
    to normalized codes is well-founded.
-/
theorem tropUniverse_normalized_wellFounded (K : ℕ) :
    WellFounded (fun u v : {u : TropCode // normalizeCode K u = u} =>
      codeRank u.1 < codeRank v.1) := by
  refine' ⟨ fun f => _ ⟩;
  refine' Acc.intro _ fun g hg => _;
  induction' n : codeRank g.val using Nat.strong_induction_on with n ih generalizing g;
  refine' ⟨ _, fun h hh => _ ⟩;
  grind

/-! ## Section 6: Tropical Subtyping and Lattice Structure -/

/-- Tropical subtyping: `A` is a subtype of `B` when `B` assigns lower
    cost everywhere (less restrictive). -/
def TropSub {α : Type} (A B : TropSet α) : Prop := ∀ x, B x ≤ A x

/-- Tropical subtyping is reflexive. -/
theorem TropSub.refl {α : Type} (A : TropSet α) : TropSub A A :=
  fun _ => le_refl _

/-- Tropical subtyping is transitive. -/
theorem TropSub.trans {α : Type} {A B C : TropSet α}
    (hab : TropSub A B) (hbc : TropSub B C) : TropSub A C :=
  fun x => le_trans (hbc x) (hab x)

/-- The meet (min) of two tropical sets is their tropical intersection. -/
def TropMeet {α : Type} (A B : TropSet α) : TropSet α :=
  fun x => min (A x) (B x)

/-- The tropical meet is below both components. -/
theorem TropMeet.sub_left {α : Type} (A B : TropSet α) :
    TropSub A (TropMeet A B) := by
  intro x; exact Nat.min_le_left (A x) (B x)

/-- The tropical meet is below both components. -/
theorem TropMeet.sub_right {α : Type} (A B : TropSet α) :
    TropSub B (TropMeet A B) := by
  intro x; exact Nat.min_le_right (A x) (B x)

/-- The tropical meet is the greatest lower bound. -/
theorem TropMeet.greatest {α : Type} {A B C : TropSet α}
    (hA : TropSub A C) (hB : TropSub B C) :
    TropSub (TropMeet A B) C := by
  intro x; exact Nat.le_min.mpr ⟨hA x, hB x⟩

/-! ## Section 7: Tropical Dependent Products (Π-types) -/

/-- A tropical dependent product: given a family of tropical sets `B x` indexed
    by a base type with cost function `A`, a section `f` is well-typed if for
    each `x`, the cost of `f x` in `B x` is bounded by the cost of `x` in `A`. -/
def TropPi {α : Type} (A : TropSet α) (β : α → Type) (B : ∀ x, TropSet (β x))
    (f : ∀ x, β x) : Prop :=
  ∀ x, B x (f x) ≤ A x

/-- Decidability of tropical Π-type checking on finite base types. -/
instance tropPi_decidable {α : Type} [Fintype α] [DecidableEq α]
    (A : TropSet α) (β : α → Type) (B : ∀ x, TropSet (β x))
    (f : ∀ x, β x) : Decidable (TropPi A β B f) := by
  unfold TropPi; infer_instance

/-! ## Section 8: Typing Judgments -/

/-- A typing judgment in context: given context costs `Γ`, a term `t`
    has type `A` if the cost of `t` is bounded by the context cost. -/
def TropJudgment {α β : Type} (Γ : TropSet α) (A : TropSet β) (t : α → β) : Prop :=
  TropHom Γ A t

/-- Weakening: if `Γ'` assigns higher costs than `Γ`, then any term
    well-typed under `Γ` is also well-typed under `Γ'`. -/
theorem TropJudgment.weaken {α β : Type} {Γ Γ' : TropSet α} {A : TropSet β} {t : α → β}
    (hΓ : TropSub Γ' Γ) (ht : TropJudgment Γ A t) : TropJudgment Γ' A t :=
  fun x => le_trans (ht x) (hΓ x)

/-- Cut/substitution: composing two well-typed terms yields a well-typed term. -/
theorem TropJudgment.cut {α β γ : Type}
    {Γ : TropSet α} {A : TropSet β} {B : TropSet γ}
    {s : α → β} {t : β → γ}
    (hs : TropJudgment Γ A s) (ht : TropJudgment A B t) :
    TropJudgment Γ B (t ∘ s) :=
  TropHom.comp hs ht

/-! ## Section 9: Universe Encoding is Idempotent -/

/-- Idempotence of the universe encoding: applying the encoding twice
    yields the same result as applying it once. This connects to
    `normalizeCode_idempotent` and generalizes it. -/
theorem universe_encoding_idempotent (K : ℕ) :
    ∀ u, normalizeCode K (normalizeCode K u) = normalizeCode K u :=
  normalizeCode_idempotent K

/-! ## Axiom checks -/
#print axioms tropical_typecheck_decidable
#print axioms tropical_typecheck_iff_forall_finset
#print axioms tropical_identity_eq_minplus_equality
#print axioms tropId_implies_eq_of_cost_injective
#print axioms TropHom.comp
#print axioms TropHomC.comp
#print axioms TropHom.id
#print axioms TropEq.congr_min
#print axioms TropId.congr_comp
#print axioms tropical_plus_distributes_over_min
#print axioms tropUniverse_wellFounded
#print axioms normalizeCode_idempotent
#print axioms normalizeCode_rank_le
#print axioms TropSub.refl
#print axioms TropSub.trans
#print axioms TropMeet.sub_left
#print axioms TropMeet.sub_right
#print axioms TropMeet.greatest
#print axioms TropJudgment.weaken
#print axioms TropJudgment.cut
#print axioms universe_encoding_idempotent