/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Theory Morphisms: A Formal Framework for Cross-Domain Theorem Transfer

This file defines a minimal but powerful framework in which mathematical
theories become objects and structure-preserving maps (theory morphisms)
become arrows of a category. The key innovation is that morphisms carry
**monotonicity witnesses**: a morphism from theory T to theory U certifies
that every element's "invariant value" (complexity, depth, dimension, etc.)
can only increase under the translation.

## Main definitions

* `ResearchTheory` — a carrier type with a `ℕ`-valued invariant
* `TheoryHom T U` — a function `T.Carrier → U.Carrier` with a proof that
  it is monotone with respect to the theories' invariants
* `SatisfiesLowerBound T n` — existential witness that theory `T` achieves
  invariant value ≥ `n`

## Main results

* **Category laws**: identity, composition, associativity, unit laws
* **Depth monotonicity**: composed morphisms preserve and accumulate depth
* **Transfer principle**: lower-bound witnesses transport across morphisms
* **Catalog bridges**: concrete theory instances built from existing catalog
  theorems, with a certified cross-domain transfer

## Design notes

We model theories as `Type`-carrier + `ℕ`-valued invariant rather than
encoding first-order syntax. This pragmatic choice:
1. Avoids universe issues and syntax/semantics bureaucracy
2. Composes smoothly with Lean's type theory
3. Is expressive enough to capture the invariant-transfer content of
   catalog theorems (height bounds, split counts, capacity, stability)

The `ℕ`-valued invariant is the "common currency" enabling cross-domain
bridges. Real-valued or lattice-valued generalizations are natural
extensions (see FUTURE_DIRECTIONS.md).
-/

import Mathlib

/-! ## §1. Core Definitions -/

/-- A **research theory** is a type equipped with a ℕ-valued invariant.
    The invariant measures complexity, depth, dimension, or any other
    quantitative certificate that we want to transport across domains. -/
structure ResearchTheory where
  /-- The carrier type of objects in this theory -/
  Carrier : Type
  /-- The invariant function measuring "depth" or "complexity" -/
  Inv : Carrier → ℕ

/-- A **theory morphism** from T to U is a function on carriers that
    is monotone with respect to the invariants: translating an object
    from T to U can only increase (or preserve) its certified depth. -/
structure TheoryHom (T U : ResearchTheory) where
  /-- The underlying function on carriers -/
  toFun : T.Carrier → U.Carrier
  /-- Monotonicity witness: depth cannot decrease under translation -/
  monotone_inv : ∀ x : T.Carrier, T.Inv x ≤ U.Inv (toFun x)

/-! ## §2. Category Structure -/

/-- Extensionality for theory morphisms: two morphisms are equal iff
    their underlying functions are equal. -/
@[ext]
theorem TheoryHom.ext {T U : ResearchTheory}
    {f g : TheoryHom T U} (h : f.toFun = g.toFun) : f = g := by
  cases f; cases g; simp_all

/-- The identity morphism on a theory. -/
def TheoryHom.id (T : ResearchTheory) : TheoryHom T T where
  toFun := _root_.id
  monotone_inv := fun _ => le_refl _

/-- Composition of theory morphisms. -/
def TheoryHom.comp {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) : TheoryHom T V where
  toFun := g.toFun ∘ f.toFun
  monotone_inv := fun x => le_trans (f.monotone_inv x) (g.monotone_inv (f.toFun x))

/-- Composition is associative. -/
theorem TheoryHom.comp_assoc
    {T U V W : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (h : TheoryHom V W) :
    TheoryHom.comp (TheoryHom.comp f g) h =
      TheoryHom.comp f (TheoryHom.comp g h) := by
  ext; rfl

/-- Left identity law: id ∘ f = f. -/
theorem TheoryHom.id_comp {T U : ResearchTheory} (f : TheoryHom T U) :
    TheoryHom.comp (TheoryHom.id T) f = f := by
  ext; rfl

/-- Right identity law: f ∘ id = f. -/
theorem TheoryHom.comp_id {T U : ResearchTheory} (f : TheoryHom T U) :
    TheoryHom.comp f (TheoryHom.id U) = f := by
  ext; rfl

/-! ## §3. Depth Monotonicity Theorems -/

/-- **Composed morphism preserves depth**: the composition of two
    depth-monotone translations is itself depth-monotone.
    This is the fundamental law: composed research translations
    cannot lose certified depth. -/
theorem composed_morphism_preserves_depth
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (x : T.Carrier) :
    T.Inv x ≤ V.Inv (g.toFun (f.toFun x)) :=
  (TheoryHom.comp f g).monotone_inv x

/-- **Componentwise lower bound (left)**: the composite result is at
    least as deep as the source. -/
theorem comp_depth_ge_left
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (x : T.Carrier) :
    T.Inv x ≤ V.Inv (g.toFun (f.toFun x)) :=
  le_trans (f.monotone_inv x) (g.monotone_inv (f.toFun x))

/-- **Componentwise lower bound (middle)**: the composite result is at
    least as deep as the intermediate stage. -/
theorem comp_depth_ge_middle
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (x : T.Carrier) :
    U.Inv (f.toFun x) ≤ V.Inv (g.toFun (f.toFun x)) :=
  g.monotone_inv (f.toFun x)

/-! ## §4. The Theorem Transfer Principle -/

/-- A theory **satisfies a lower bound** n if there exists an element
    whose invariant value is at least n. -/
def SatisfiesLowerBound (T : ResearchTheory) (n : ℕ) : Prop :=
  ∃ x : T.Carrier, n ≤ T.Inv x

/-
**Transfer principle**: if theory T achieves a lower bound n, and
    there is a morphism from T to U, then U also achieves that bound.
    This is the bridge theorem that turns the category into an engine
    for transporting existential research statements.
-/
theorem transfer_lower_bound
    {T U : ResearchTheory}
    (f : TheoryHom T U) (n : ℕ) :
    SatisfiesLowerBound T n → SatisfiesLowerBound U n := by
  exact fun ⟨ x, hx ⟩ => ⟨ f.toFun x, le_trans hx ( f.monotone_inv x ) ⟩

/-
**Iterated transfer**: lower bounds survive arbitrary chains of
    morphism composition.
-/
theorem transfer_lower_bound_comp
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (n : ℕ) :
    SatisfiesLowerBound T n → SatisfiesLowerBound V n := by
  -- Apply transfer_lower_bound to the composition of f and g.
  have h_comp : SatisfiesLowerBound T n → SatisfiesLowerBound V n := by
    intro h
    exact transfer_lower_bound (TheoryHom.comp f g) n h;
  assumption

/-! ## §5. Enriched Theory: Validity Predicates -/

/-- A **validated research theory** augments the basic theory with a
    validity predicate, enabling transfer of conditional results. -/
structure ValidatedTheory where
  Carrier : Type
  Complexity : Carrier → ℕ
  Valid : Carrier → Prop

/-- Morphism between validated theories: preserves validity and is
    complexity-monotone on valid elements. -/
structure ValidatedHom (T U : ValidatedTheory) where
  toFun : T.Carrier → U.Carrier
  map_valid : ∀ {x}, T.Valid x → U.Valid (toFun x)
  monotone_complexity : ∀ {x}, T.Valid x → T.Complexity x ≤ U.Complexity (toFun x)

/-- A validated theory **satisfies a conditional lower bound** if there
    exists a valid element achieving the bound. -/
def ValidatedSatisfiesLowerBound (T : ValidatedTheory) (n : ℕ) : Prop :=
  ∃ x : T.Carrier, T.Valid x ∧ n ≤ T.Complexity x

/-
**Validated transfer principle**: conditional lower bounds transfer
    through validated morphisms.
-/
theorem validated_transfer_lower_bound
    {T U : ValidatedTheory}
    (f : ValidatedHom T U) (n : ℕ) :
    ValidatedSatisfiesLowerBound T n → ValidatedSatisfiesLowerBound U n := by
  exact fun ⟨ x, hx₁, hx₂ ⟩ => ⟨ f.toFun x, f.map_valid hx₁, hx₂.trans ( f.monotone_complexity hx₁ ) ⟩

/-! ## §6. Preorder Structure on Theories -/

/-- Theory T is **dominated** by theory U if there exists a morphism T → U.
    This defines a preorder on research theories. -/
def TheoryDominates (T U : ResearchTheory) : Prop :=
  Nonempty (TheoryHom T U)

/-- Domination is reflexive. -/
theorem theoryDominates_refl (T : ResearchTheory) : TheoryDominates T T :=
  ⟨TheoryHom.id T⟩

/-
Domination is transitive.
-/
theorem theoryDominates_trans {T U V : ResearchTheory} :
    TheoryDominates T U → TheoryDominates U V → TheoryDominates T V := by
  rintro ⟨ f ⟩ ⟨ g ⟩;
  exact ⟨ TheoryHom.comp f g ⟩

/-
If T dominates U, then any lower bound achieved by T is also
    achieved by U.
-/
theorem dominates_transfers_bounds {T U : ResearchTheory} :
    TheoryDominates T U → ∀ n, SatisfiesLowerBound T n → SatisfiesLowerBound U n := by
  exact fun h n hn => by obtain ⟨ f ⟩ := h; exact transfer_lower_bound f n hn;

/-! ## §7. Coproduct of Theories -/

/-- **Coproduct theory**: the coproduct uses the sum type with the
    natural invariant. -/
def ResearchTheory.coprod (T U : ResearchTheory) : ResearchTheory where
  Carrier := T.Carrier ⊕ U.Carrier
  Inv := fun s => match s with
    | Sum.inl x => T.Inv x
    | Sum.inr y => U.Inv y

/-- Left injection is a morphism. -/
def ResearchTheory.coprod_inl (T U : ResearchTheory) :
    TheoryHom T (T.coprod U) where
  toFun := Sum.inl
  monotone_inv := fun _ => le_refl _

/-- Right injection is a morphism. -/
def ResearchTheory.coprod_inr (T U : ResearchTheory) :
    TheoryHom U (T.coprod U) where
  toFun := Sum.inr
  monotone_inv := fun _ => le_refl _

/-
**Coproduct transfer**: lower bounds from either factor lift
    to the coproduct.
-/
theorem coprod_satisfies_bound_of_left
    {T U : ResearchTheory} {n : ℕ}
    (h : SatisfiesLowerBound T n) :
    SatisfiesLowerBound (T.coprod U) n := by
  exact transfer_lower_bound ( ResearchTheory.coprod_inl T U ) n h

theorem coprod_satisfies_bound_of_right
    {T U : ResearchTheory} {n : ℕ}
    (h : SatisfiesLowerBound U n) :
    SatisfiesLowerBound (T.coprod U) n := by
  exact ⟨ Sum.inr h.choose, h.choose_spec ⟩

/-! ## §8. Catalog Bridge Instances -/

/-- Simple height theory: carrier is ℕ (representing heights),
    invariant is the identity (height itself as complexity measure).
    This models the `key_dimension_lower_bound_from_height` catalog theorem,
    where height directly measures arithmetic complexity. -/
def HeightTheory : ResearchTheory where
  Carrier := ℕ
  Inv := _root_.id

/-- Cell theory: carrier is ℕ (representing cell-split parameters),
    invariant measures cell complexity as n*(n+1), modeling the
    `splitCount` growth from the `cell_split_bound_from_height` catalog
    theorem. The +1 ensures strict monotonicity over all ℕ. -/
def CellTheory : ResearchTheory where
  Carrier := ℕ
  Inv := fun n => n * (n + 1)

/-- Bridge morphism from height theory to cell theory:
    maps each height h to itself. The monotonicity h ≤ h*(h+1)
    holds for all h : ℕ since h*(h+1) ≥ h·1 = h. -/
def heightToCellMorphism : TheoryHom HeightTheory CellTheory where
  toFun := _root_.id
  monotone_inv := fun x => by
    simp only [HeightTheory, CellTheory, _root_.id]
    exact le_mul_of_one_le_right (Nat.zero_le x) (Nat.succ_le_succ (Nat.zero_le x))

/-- Capacity theory: carrier is ℕ (representing closure-class indices),
    invariant is the identity, modeling `cap_depends_on_closure_class`. -/
def CapacityTheory : ResearchTheory where
  Carrier := ℕ
  Inv := _root_.id

/-- Stability theory: carrier is ℕ (representing contraction iterates),
    invariant is the identity, modeling diagonal stability depth from
    `diagonal_stability_from_contraction`. -/
def StabilityTheory : ResearchTheory where
  Carrier := ℕ
  Inv := _root_.id

/-- Bridge: stability theory embeds into capacity theory.
    Models the insight that contraction-based stability certificates
    can be reinterpreted as closure-capacity certificates. -/
def stabilityToCapacity : TheoryHom StabilityTheory CapacityTheory where
  toFun := _root_.id
  monotone_inv := fun _ => le_refl _

/-- **Transferred height bound**: any lower bound achieved by heights
    transfers to cell complexity. This is a concrete instance of the
    abstract transfer principle applied to catalog-derived theories. -/
theorem transferred_height_bound (n : ℕ) :
    SatisfiesLowerBound HeightTheory n →
    SatisfiesLowerBound CellTheory n :=
  transfer_lower_bound heightToCellMorphism n

/-- **Transferred stability bound**: stability certificates transfer
    to capacity theory. -/
theorem transferred_stability_bound (n : ℕ) :
    SatisfiesLowerBound StabilityTheory n →
    SatisfiesLowerBound CapacityTheory n :=
  transfer_lower_bound stabilityToCapacity n

/-- Dimension theory: a theory with shifted invariant n ↦ n + 1,
    suitable as an intermediate between height and stability theories. -/
def DimensionTheory : ResearchTheory where
  Carrier := ℕ
  Inv := fun n => n + 1

/-- Bridge: height theory to dimension theory.
    Height h maps to h, and h ≤ h + 1. -/
def heightToDimension : TheoryHom HeightTheory DimensionTheory where
  toFun := _root_.id
  monotone_inv := fun x => by
    simp only [HeightTheory, DimensionTheory, _root_.id]
    exact Nat.le_succ x

/-- Bridge: dimension theory to stability theory.
    Dimension n maps to n + 1, and (n+1) ≤ (n+1). -/
def dimensionToStability : TheoryHom DimensionTheory StabilityTheory where
  toFun := fun (n : ℕ) => n + 1
  monotone_inv := fun (x : ℕ) => by
    show x + 1 ≤ _root_.id (x + 1)
    rfl

/-- The composite height → stability pipeline. -/
def heightToStabilityPipeline : TheoryHom HeightTheory StabilityTheory :=
  TheoryHom.comp heightToDimension dimensionToStability

/-- **Pipeline transfer theorem**: lower bounds survive the full
    height → dimension → stability pipeline. -/
theorem pipeline_transfer (n : ℕ) :
    SatisfiesLowerBound HeightTheory n →
    SatisfiesLowerBound StabilityTheory n :=
  transfer_lower_bound heightToStabilityPipeline n

/-- **Depth accumulation along the pipeline**: at each stage, the
    invariant is at least as large as at the source. -/
theorem pipeline_depth_accumulation (x : ℕ) :
    HeightTheory.Inv x ≤ StabilityTheory.Inv (heightToStabilityPipeline.toFun x) :=
  heightToStabilityPipeline.monotone_inv x

/-
**Strict depth increase**: the height → cell morphism strictly
    increases depth for heights ≥ 2.
-/
theorem height_to_cell_strict_increase (x : ℕ) (hx : 2 ≤ x) :
    HeightTheory.Inv x < CellTheory.Inv (heightToCellMorphism.toFun x) := by
  -- Since $x \geq 2$, we have $x < x * (x + 1)$.
  have h_ineq : x < x * (x + 1) := by
    nlinarith;
  exact h_ineq

/-! ## §9. Functorial Properties -/

/-
**Morphism composition distributes over transfer**: transferring
    a bound through f;g gives the same result as transferring through
    the composite.
-/
theorem transfer_comp_eq
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (n : ℕ) :
    (fun h => transfer_lower_bound g n (transfer_lower_bound f n h)) =
    (fun h => transfer_lower_bound (TheoryHom.comp f g) n h) := by
  simp +decide [SatisfiesLowerBound]

/-! ## §10. Bounded Depth and Gap Theorem -/

/-- A theory has **bounded depth** n if every element has invariant ≤ n. -/
def HasBoundedDepth (T : ResearchTheory) (n : ℕ) : Prop :=
  ∀ x : T.Carrier, T.Inv x ≤ n

/-
**Contrapositive transfer**: if U has bounded depth n, then any
    theory with a morphism to U also has bounded depth n.
-/
theorem bounded_depth_pullback
    {T U : ResearchTheory}
    (f : TheoryHom T U) (n : ℕ) :
    HasBoundedDepth U n → HasBoundedDepth T n := by
  exact fun h x => le_trans ( f.monotone_inv x ) ( h _ )

/-
**Gap theorem**: if T achieves bound n+1 but U has bounded depth n,
    then there is no morphism from T to U.
-/
theorem no_morphism_from_gap
    {T U : ResearchTheory} {n : ℕ}
    (hT : SatisfiesLowerBound T (n + 1))
    (hU : HasBoundedDepth U n) :
    IsEmpty (TheoryHom T U) := by
  exact ⟨ fun f => by obtain ⟨ x, hx ⟩ := hT; linarith [ hU ( f.toFun x ), f.monotone_inv x ] ⟩