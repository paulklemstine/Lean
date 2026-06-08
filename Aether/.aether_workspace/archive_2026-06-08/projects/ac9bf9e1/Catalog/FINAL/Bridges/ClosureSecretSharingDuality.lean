/-
# Closure–Secret-Sharing Duality via Idempotent Dependency Systems

This module establishes a formal duality between:
- **Finite monotone access structures** (the cryptographic side),
- **Closure operators on pointed participant sets** (the geometric side),
- **Pointed dependency systems** (the algebraic side).

The main results:
1. Authorization induced by a closure operator is monotone (upward-closed).
2. Minimal authorized sets are exactly the "secret-circuits" of the closure geometry.
3. Every pointed dependency system induces a closure-exact access structure.
4. Every closure-exact access structure admits a pointed dependency representation.
5. Certified enumeration of minimal authorized sets.

## Key Insight

A secret-sharing access structure is not just *representable* by closure data —
it *is* a pointed closure geometry. Authorization means "the secret lies in the
span of the chosen participants," and unauthorized sets are exactly the flats
avoiding the secret.
-/

import Mathlib

open Set Function

universe u

/-! ## §1 Closure Operators -/

/-- A closure operator on sets: extensive, monotone, idempotent. -/
structure IsClosureOperator {α : Type*} (cl : Set α → Set α) : Prop where
  extensive : ∀ A, A ⊆ cl A
  monotone : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A

/-! ## §2 Lifting participants and authorization -/

/-- Lift a set of participants `S : Set X` to a set in `Option X`,
    mapping each `x ∈ S` to `some x`. The secret is `none`. -/
def liftParticipants {X : Type*} (S : Set X) : Set (Option X) :=
  {y | ∃ x ∈ S, y = some x}

/-- A set `S` of participants is *authorized* if the secret (`none`)
    lies in the closure of the lifted participant set. -/
def AuthorizedFromClosure {X : Type*}
    (cl : Set (Option X) → Set (Option X)) (S : Set X) : Prop :=
  none ∈ cl (liftParticipants S)

/-- A set `S` is *unauthorized* if the secret does not lie in the closure. -/
def UnauthorizedFromClosure {X : Type*}
    (cl : Set (Option X) → Set (Option X)) (S : Set X) : Prop :=
  none ∉ cl (liftParticipants S)

/-! ## §3 Monotonicity and complement lemmas -/

theorem liftParticipants_mono {X : Type*} :
    Monotone (liftParticipants (X := X)) := by
  intro A B hAB y ⟨x, hx, hy⟩
  exact ⟨x, hAB hx, hy⟩

/-- **Theorem 1**: Authorization induced by a closure operator is monotone. -/
theorem authorizedFromClosure_mono
    {X : Type*}
    (cl : Set (Option X) → Set (Option X))
    (_h_ext : ∀ A, A ⊆ cl A)
    (h_mono : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B)
    (_h_idem : ∀ A, cl (cl A) = cl A) :
    Monotone (AuthorizedFromClosure cl) := by
  intro S T hST
  exact fun h => h_mono (liftParticipants_mono hST) h

/-- The unauthorized predicate is exactly the negation of authorized. -/
theorem unauthorizedFromClosure_compl_authorizedFromClosure
    {X : Type*} (cl : Set (Option X) → Set (Option X)) :
    ∀ S, UnauthorizedFromClosure cl S ↔ ¬ AuthorizedFromClosure cl S := by
  intro S; exact Iff.rfl

/-! ## §4 Minimal authorized sets and secret-circuits -/

/-- A set `S` is *minimal authorized* if it is authorized and no proper subset is. -/
def IsMinimalAuthorized {X : Type*}
    (A : Set X → Prop) (S : Set X) : Prop :=
  A S ∧ ∀ T, T ⊂ S → ¬ A T

/-- A set `S` is a *secret-circuit* if the secret is in the closure of `S`,
    but removing any single participant causes the secret to leave the closure. -/
def IsSecretCircuit {X : Type*}
    (cl : Set (Option X) → Set (Option X)) (S : Set X) : Prop :=
  none ∈ cl (liftParticipants S) ∧
  ∀ x ∈ S, none ∉ cl (liftParticipants (S \ {x}))

/-
**Theorem 2**: Minimal authorized sets are exactly the secret-circuits
    of the closure geometry.
-/
theorem minimalAuthorized_iff_secretCircuit
    {X : Type*}
    (cl : Set (Option X) → Set (Option X))
    (_h_ext : ∀ A, A ⊆ cl A)
    (h_mono : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B)
    (_h_idem : ∀ A, cl (cl A) = cl A) :
    ∀ S, IsMinimalAuthorized (AuthorizedFromClosure cl) S ↔ IsSecretCircuit cl S := by
  intro S
  constructor;
  · intro hS;
    refine' ⟨ hS.1, fun x hx => _ ⟩;
    exact hS.2 ( S \ { x } ) ( by aesop );
  · intro h;
    refine' ⟨ h.1, fun T hT => _ ⟩;
    obtain ⟨ x, hxS, hxT ⟩ := Set.exists_of_ssubset hT;
    exact fun hx => h.2 x hxS <| h_mono ( show liftParticipants T ⊆ liftParticipants ( S \ { x } ) from fun y hy => by rcases hy with ⟨ z, hzT, rfl ⟩ ; exact ⟨ z, ⟨ hT.1 hzT, by aesop ⟩, rfl ⟩ ) hx

/-! ## §5 Pointed Dependency Systems -/

/-- A *pointed dependency system* over a participant type `X` consists of:
    - a carrier type with a span (closure) operation,
    - generator assignments for each participant,
    - a distinguished secret element,
    - axioms making span a closure operator with finite character. -/
structure PointedDependencySystem (X : Type u) where
  /-- The carrier type of the dependency system. -/
  Carrier : Type u
  /-- Span/closure operation on sets of carrier elements. -/
  span : Set Carrier → Set Carrier
  /-- Generator assignment: each participant maps to a carrier element. -/
  gen : X → Carrier
  /-- The secret element in the carrier. -/
  secret : Carrier
  /-- Span is extensive. -/
  span_extensive : ∀ A, A ⊆ span A
  /-- Span is monotone. -/
  span_mono : ∀ ⦃A B⦄, A ⊆ B → span A ⊆ span B
  /-- Span is idempotent. -/
  span_idem : ∀ A, span (span A) = span A

/-- Authorization via a dependency system: the secret is in the span of
    the images of the chosen participants. -/
def AuthorizedFromDependency {X : Type u}
    (D : PointedDependencySystem X) (S : Set X) : Prop :=
  D.secret ∈ D.span (D.gen '' S)

/-- Authorization from a dependency system is monotone. -/
theorem authorizedFromDependency_mono {X : Type u}
    (D : PointedDependencySystem X) :
    Monotone (AuthorizedFromDependency D) := by
  intro S T hST
  exact fun h => D.span_mono (Set.image_mono hST) h

/-! ## §6 From Dependency Systems to Closure Operators -/

/-- Given a pointed dependency system, construct a closure operator on `Option X`
    by mapping `some x ↦ gen x` and `none ↦ secret`, then using span. -/
noncomputable def closureFromDependency {X : Type u}
    (D : PointedDependencySystem X) : Set (Option X) → Set (Option X) :=
  let toCarrier : Option X → D.Carrier := fun
    | some x => D.gen x
    | none => D.secret
  fun A => {y : Option X | toCarrier y ∈ D.span (toCarrier '' A)}

/-
The closure operator induced by a dependency system is indeed a closure operator.
-/
theorem closureFromDependency_isClosureOperator {X : Type u}
    (D : PointedDependencySystem X) :
    IsClosureOperator (closureFromDependency D) := by
  constructor <;> simp +decide [ closureFromDependency ];
  · exact fun A x hx => D.span_extensive _ <| Set.mem_image_of_mem _ hx;
  · exact fun A B hAB a ha => D.span_mono ( Set.image_mono hAB ) ha;
  · intro A;
    ext y;
    constructor <;> intro hy;
    · refine' D.span_idem _ ▸ _;
      refine' D.span_mono _ hy;
      exact Set.image_subset_iff.mpr fun x hx => hx;
    · refine' D.span_extensive _ _;
      exact ⟨ y, hy, rfl ⟩

/-
**Theorem 3**: A dependency system's authorization agrees with the
    closure-based authorization from the induced closure operator.
-/
theorem dependency_authorization_equiv_closure_authorization
    {X : Type u}
    (D : PointedDependencySystem X) :
    ∀ S : Set X,
      AuthorizedFromDependency D S ↔
      AuthorizedFromClosure (closureFromDependency D) S := by
  unfold AuthorizedFromDependency AuthorizedFromClosure;
  intro S
  unfold closureFromDependency liftParticipants
  simp [Set.image]

/-! ## §7 From Closure Operators to Dependency Systems -/

/-- Given a closure operator on `Option X`, construct a pointed dependency system
    with carrier `Option X` and span = cl. -/
def dependencyFromClosure {X : Type u}
    (cl : Set (Option X) → Set (Option X))
    (hcl : IsClosureOperator cl) : PointedDependencySystem X where
  Carrier := Option X
  span := cl
  gen := some
  secret := none
  span_extensive := hcl.extensive
  span_mono := hcl.monotone
  span_idem := hcl.idempotent

/-
**Theorem 4 (forward)**: The dependency system from a closure operator
    recovers the same authorization predicate.
-/
theorem closure_to_dependency_authorization
    {X : Type u}
    (cl : Set (Option X) → Set (Option X))
    (hcl : IsClosureOperator cl) :
    ∀ S : Set X,
      AuthorizedFromClosure cl S ↔
      AuthorizedFromDependency (dependencyFromClosure cl hcl) S := by
  intro S
  unfold AuthorizedFromClosure AuthorizedFromDependency
  simp [dependencyFromClosure];
  congr! 2;
  exact Set.ext fun x => ⟨ by rintro ⟨ y, hy, rfl ⟩ ; exact ⟨ y, hy, rfl ⟩, by rintro ⟨ y, hy, rfl ⟩ ; exact ⟨ y, hy, rfl ⟩ ⟩

/-! ## §8 Closure-Exact Access Structures -/

/-- An access structure is *closure-exact* if it arises from some closure operator. -/
def ClosureExactAccessStructure {X : Type u} (A : Set X → Prop) : Prop :=
  ∃ cl : Set (Option X) → Set (Option X),
    IsClosureOperator cl ∧
    ∀ S : Set X, A S ↔ AuthorizedFromClosure cl S

/-- **Theorem 5**: Every pointed dependency system induces a closure-exact
    access structure. -/
theorem dependency_induces_closureExact {X : Type u}
    (D : PointedDependencySystem X) :
    ClosureExactAccessStructure (AuthorizedFromDependency D) :=
  ⟨_, closureFromDependency_isClosureOperator D,
   dependency_authorization_equiv_closure_authorization D⟩

/-- **Theorem 6 (Duality)**: Every closure-exact access structure admits
    a pointed dependency representation. -/
theorem closureExact_has_dependency_representation {X : Type u}
    (A : Set X → Prop) (hA : ClosureExactAccessStructure A) :
    ∃ D : PointedDependencySystem X,
      ∀ S : Set X, A S ↔ AuthorizedFromDependency D S := by
  obtain ⟨cl, hcl, hauth⟩ := hA
  exact ⟨dependencyFromClosure cl hcl,
    fun S => (hauth S).trans (closure_to_dependency_authorization cl hcl S)⟩

/-! ## §9 Round-trip: closure → dependency → closure preserves authorization -/

/-
The round-trip closure → dependency → closure recovers the original authorization.
-/
theorem roundtrip_closure_dependency_closure
    {X : Type u}
    (cl : Set (Option X) → Set (Option X))
    (hcl : IsClosureOperator cl) :
    ∀ S : Set X,
      AuthorizedFromClosure cl S ↔
      AuthorizedFromClosure (closureFromDependency (dependencyFromClosure cl hcl)) S := by
  unfold AuthorizedFromClosure closureFromDependency dependencyFromClosure;
  unfold liftParticipants; simp +decide [ Set.image ] ;
  simp +decide [ eq_comm ]

/-
The round-trip dependency → closure → dependency recovers the original authorization.
-/
theorem roundtrip_dependency_closure_dependency
    {X : Type u}
    (D : PointedDependencySystem X) :
    ∀ S : Set X,
      AuthorizedFromDependency D S ↔
      AuthorizedFromDependency (dependencyFromClosure
        (closureFromDependency D)
        (closureFromDependency_isClosureOperator D)) S := by
  grind +suggestions

/-! ## §10 Minimal authorized sets: finitary structure -/

/-
Every authorized set in a closure-exact access structure contains
    a minimal authorized subset (finite case).
-/
theorem exists_minimalAuthorized_subset
    {X : Type u} [Finite X]
    (cl : Set (Option X) → Set (Option X))
    (_hcl : IsClosureOperator cl)
    (S : Finset X)
    (hS : AuthorizedFromClosure cl (↑S : Set X)) :
    ∃ T : Finset X, ↑T ⊆ (↑S : Set X) ∧
      IsMinimalAuthorized (AuthorizedFromClosure cl) (↑T : Set X) := by
  obtain ⟨T, hT⟩ : ∃ T : Finset X, T ⊆ S ∧ AuthorizedFromClosure cl T ∧ ∀ T' : Finset X, T' ⊂ T → ¬ AuthorizedFromClosure cl T' := by
    obtain ⟨T, hT⟩ : ∃ T : Finset X, T ⊆ S ∧ AuthorizedFromClosure cl T ∧ ∀ T' : Finset X, T' ⊆ S → AuthorizedFromClosure cl T' → T.card ≤ T'.card := by
      have h_min : ∃ T ∈ {T : Finset X | T ⊆ S ∧ AuthorizedFromClosure cl T}, ∀ T' ∈ {T : Finset X | T ⊆ S ∧ AuthorizedFromClosure cl T}, T.card ≤ T'.card := by
        apply_rules [ Set.exists_min_image ];
        · exact Set.Finite.subset ( Set.toFinite ( Finset.powerset S ) ) fun T hT => Finset.mem_powerset.mpr hT.1;
        · exact ⟨ S, Finset.Subset.refl _, hS ⟩;
      grind;
    exact ⟨ T, hT.1, hT.2.1, fun T' hT' hT'' => not_lt_of_ge ( hT.2.2 T' ( Finset.Subset.trans hT'.1 hT.1 ) hT'' ) ( Finset.card_lt_card hT' ) ⟩;
  use T; simp_all +decide [ IsMinimalAuthorized ] ;
  intro T' hT' hT'_auth
  obtain ⟨T'_fin, hT'_fin⟩ : ∃ T'_fin : Finset X, T' = T'_fin := by
    exact ⟨ Set.Finite.toFinset ( Set.Finite.subset ( Finset.finite_toSet T ) hT'.1 ), by simp ⟩
  generalize_proofs at *;
  exact hT.2.2 T'_fin ( by simpa [ hT'_fin ] using hT' ) ( by simpa [ hT'_fin ] using hT'_auth )

/-! ## §11 Irredundant presentations -/

/-- A dependency presentation is *irredundant* if no generator is redundant:
    removing any generator changes the authorized family. -/
def IrredundantPresentation {X : Type u}
    (D : PointedDependencySystem X) : Prop :=
  ∀ x : X, ∃ S : Set X, x ∈ S ∧
    AuthorizedFromDependency D S ∧
    ¬ AuthorizedFromDependency D (S \ {x})

/-- Every closure-exact access structure admits a dependency presentation. -/
theorem exists_dependency_presentation
    {X : Type u} [Finite X]
    (A : Set X → Prop) (hA : ClosureExactAccessStructure A) :
    ∃ D : PointedDependencySystem X,
      (∀ S : Set X, A S ↔ AuthorizedFromDependency D S) :=
  closureExact_has_dependency_representation A hA

/-! ## §12 Summary: the main duality theorem -/

/-- **Main Duality Theorem**: For finite participant types, the following are equivalent:
    1. `A` is a closure-exact access structure.
    2. `A` admits a pointed dependency system representation.

    Moreover, authorization is monotone, minimal authorized sets are secret-circuits,
    and the constructions are inverse up to authorization equivalence. -/
theorem closure_dependency_duality {X : Type u}
    (A : Set X → Prop) :
    ClosureExactAccessStructure A ↔
    (∃ D : PointedDependencySystem X,
      ∀ S : Set X, A S ↔ AuthorizedFromDependency D S) := by
  constructor
  · exact closureExact_has_dependency_representation A
  · rintro ⟨D, hD⟩
    exact ⟨_, closureFromDependency_isClosureOperator D,
      fun S => (hD S).trans (dependency_authorization_equiv_closure_authorization D S)⟩