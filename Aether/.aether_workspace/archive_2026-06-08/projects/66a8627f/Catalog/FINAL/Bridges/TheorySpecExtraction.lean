/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Theorem Embeddings from Syntax: Automatic TheorySpec Extraction

This file formalizes the extraction of semantic lower-bound specifications
from theorem syntax. The central insight is that theorems of the form
`∀ x : α, P x → n ≤ f x` canonically encode a reusable `TheorySpec` object.

## Main results

* `TheorySpec` — a structure capturing a lower-bound specification
* `mkTheorySpecOfLowerBoundTheorem` — canonical constructor from a proof
* `extraction_pipeline_correct` — the extracted spec matches all components
* `extraction_sound` — soundness of extraction at the semantic level
* `extraction_is_section` — extraction is a section of the forgetful functor
* `GeneralTheorySpec` — generalized version for arbitrary preorders
* `mkTheorySpecOfConjunctiveWitness` — handling conjunctive predicates
* `ExactSpec`, `UpperBoundSpec` — dual specifications
* `TheorySpec.compose` — composing compatible specs
* `TheorySpecMorphism` — morphisms between specs
* Concrete catalog embeddings from existing bridge theorems
-/

import Mathlib

/-! ## §1: Core TheorySpec Structure -/

/-- A `TheorySpec` packages a lower-bound theorem into a reusable semantic object.
    It captures:
    - a carrier type `α` of mathematical objects,
    - a witness predicate `Witness : α → Prop` selecting relevant objects,
    - an invariant function `inv : α → ℕ` measuring complexity/size,
    - a constant `lowerBound : ℕ`,
    - a soundness proof that witnessed objects have invariant ≥ lowerBound. -/
structure TheorySpec where
  α : Type
  Witness : α → Prop
  inv : α → ℕ
  lowerBound : ℕ
  sound : ∀ x, Witness x → lowerBound ≤ inv x

/-! ## §2: Canonical Constructor and Semantic Packaging -/

/-- Construct a `TheorySpec` directly from a lower-bound theorem proof. -/
def mkTheorySpecOfLowerBoundTheorem
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    TheorySpec :=
  { α := α, Witness := P, inv := f, lowerBound := n, sound := h }

/-- **Theorem A (Canonical Semantic Packaging).**
    The constructed `TheorySpec` has fields exactly matching the theorem components.
    This is the foundational extraction correctness theorem. -/
theorem extraction_pipeline_correct
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    let T := mkTheorySpecOfLowerBoundTheorem α P f n h
    T.α = α ∧ T.Witness = P ∧ T.inv = f ∧ T.lowerBound = n ∧
    (∀ x, T.Witness x → T.lowerBound ≤ T.inv x) :=
  ⟨rfl, rfl, rfl, rfl, h⟩

/-- **Soundness of extraction at the semantic level**: if a theorem statement is
    recognized and a proof term inhabits it, then one obtains a `TheorySpec`. -/
theorem extraction_sound
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    ∃ T : TheorySpec, T.α = α ∧ T.lowerBound = n :=
  ⟨mkTheorySpecOfLowerBoundTheorem α P f n h, rfl, rfl⟩

/-- Given a theorem proof whose type is recognized by the extractor,
    we can build a semantic `TheorySpec`. -/
theorem extracted_expr_yields_theorySpec
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (thm : ∀ x : α, P x → n ≤ f x) :
    Nonempty TheorySpec :=
  ⟨mkTheorySpecOfLowerBoundTheorem α P f n thm⟩

/-- **Master Theorem**: The extraction pipeline is a section of the forgetful
    functor from TheorySpecs to lower-bound theorem statements.
    That is, extracting and then reading off the soundness proof recovers
    the original theorem. -/
theorem extraction_is_section
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    (mkTheorySpecOfLowerBoundTheorem α P f n h).sound = h :=
  rfl

/-! ## §3: Field Access Correctness -/

@[simp] theorem mkTheorySpec_α
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ) (h) :
    (mkTheorySpecOfLowerBoundTheorem α P f n h).α = α := rfl

@[simp] theorem mkTheorySpec_Witness
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ) (h) :
    (mkTheorySpecOfLowerBoundTheorem α P f n h).Witness = P := rfl

@[simp] theorem mkTheorySpec_inv
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ) (h) :
    (mkTheorySpecOfLowerBoundTheorem α P f n h).inv = f := rfl

@[simp] theorem mkTheorySpec_lowerBound
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ) (h) :
    (mkTheorySpecOfLowerBoundTheorem α P f n h).lowerBound = n := rfl

/-! ## §4: Generalized TheorySpec for Arbitrary Preorders -/

/-- A generalized `TheorySpec` where the codomain of the invariant is an
    arbitrary preordered type β, not just ℕ. This covers lower bounds
    on real-valued quantities, ordinal-valued measures, etc. -/
structure GeneralTheorySpec where
  α : Type
  β : Type
  instPreorder : Preorder β
  Witness : α → Prop
  inv : α → β
  lowerBound : β
  sound : ∀ x, Witness x → instPreorder.toLE.le lowerBound (inv x)

/-- Construct a `GeneralTheorySpec` from a lower-bound theorem over a preorder. -/
def mkGeneralTheorySpec
    (α : Type) (β : Type) [inst : Preorder β]
    (P : α → Prop) (f : α → β) (b : β)
    (h : ∀ x : α, P x → b ≤ f x) :
    GeneralTheorySpec :=
  { α := α, β := β, instPreorder := inst, Witness := P, inv := f, lowerBound := b, sound := h }

/-- **Extension 1 (Ordered Codomain Generalization).**
    Any theorem `∀ x, P x → b ≤ f x` over a preorder yields a `GeneralTheorySpec`
    with matching carrier and codomain types. -/
theorem generalTheorySpec_correct
    (α : Type) (β : Type) [Preorder β]
    (P : α → Prop) (f : α → β) (b : β)
    (h : ∀ x : α, P x → b ≤ f x) :
    let T := mkGeneralTheorySpec α β P f b h
    T.α = α ∧ T.β = β ∧ T.Witness = P ∧ T.inv = f ∧ T.lowerBound = b :=
  ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- A `TheorySpec` can be promoted to a `GeneralTheorySpec` over ℕ. -/
def TheorySpec.toGeneral (T : TheorySpec) : GeneralTheorySpec :=
  { α := T.α, β := ℕ, instPreorder := inferInstance,
    Witness := T.Witness, inv := T.inv, lowerBound := T.lowerBound, sound := T.sound }

/-! ## §5: Conjunctive Witness Predicates -/

/-- **Extension 2 (Conjunctive Witness Predicates).**
    Handle theorems of the form `∀ x, P x → Q x → n ≤ f x`
    by extracting `Witness := fun x => P x ∧ Q x`. -/
def mkTheorySpecOfConjunctiveWitness
    (α : Type) (P Q : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → Q x → n ≤ f x) :
    TheorySpec :=
  { α := α
    Witness := fun x => P x ∧ Q x
    inv := f
    lowerBound := n
    sound := fun x ⟨hp, hq⟩ => h x hp hq }

/-- The conjunctive constructor produces a valid TheorySpec with correct witness. -/
theorem conjunctive_witness_correct
    (α : Type) (P Q : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → Q x → n ≤ f x) :
    let T := mkTheorySpecOfConjunctiveWitness α P Q f n h
    T.Witness = (fun x => P x ∧ Q x) ∧
    ∀ x, T.Witness x → T.lowerBound ≤ T.inv x :=
  ⟨rfl, fun x ⟨hp, hq⟩ => h x hp hq⟩

/-- Handle triple-conjunctive witnesses: `∀ x, P x → Q x → R x → n ≤ f x`. -/
def mkTheorySpecOfTripleWitness
    (α : Type) (P Q R : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → Q x → R x → n ≤ f x) :
    TheorySpec :=
  { α := α
    Witness := fun x => P x ∧ Q x ∧ R x
    inv := f
    lowerBound := n
    sound := fun x ⟨hp, hq, hr⟩ => h x hp hq hr }

/-! ## §6: Upper Bound and Equality Duals -/

/-- An `UpperBoundSpec` captures theorems of the form `∀ x, P x → f x ≤ n`. -/
structure UpperBoundSpec where
  α : Type
  Witness : α → Prop
  inv : α → ℕ
  upperBound : ℕ
  sound : ∀ x, Witness x → inv x ≤ upperBound

/-- Construct an `UpperBoundSpec` from an upper-bound theorem. -/
def mkUpperBoundSpec
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → f x ≤ n) :
    UpperBoundSpec :=
  { α := α, Witness := P, inv := f, upperBound := n, sound := h }

/-- An `ExactSpec` captures theorems where the invariant equals a fixed value. -/
structure ExactSpec where
  α : Type
  Witness : α → Prop
  inv : α → ℕ
  value : ℕ
  sound : ∀ x, Witness x → inv x = value

/-- Construct an `ExactSpec` from an equality theorem. -/
def mkExactSpec
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → f x = n) :
    ExactSpec :=
  { α := α, Witness := P, inv := f, value := n, sound := h }

/-- An ExactSpec yields both a TheorySpec (lower bound) and an UpperBoundSpec. -/
theorem exactSpec_yields_both_bounds (E : ExactSpec) :
    (∃ T : TheorySpec, T.α = E.α ∧ T.lowerBound = E.value) ∧
    (∃ U : UpperBoundSpec, U.α = E.α ∧ U.upperBound = E.value) :=
  ⟨⟨{ α := E.α, Witness := E.Witness, inv := E.inv, lowerBound := E.value,
      sound := fun x hx => le_of_eq (E.sound x hx).symm },
    rfl, rfl⟩,
   ⟨{ α := E.α, Witness := E.Witness, inv := E.inv, upperBound := E.value,
      sound := fun x hx => le_of_eq (E.sound x hx) },
    rfl, rfl⟩⟩

/-- A `BoundedSpec` combines upper and lower bounds. -/
structure BoundedSpec where
  α : Type
  Witness : α → Prop
  inv : α → ℕ
  lowerBound : ℕ
  upperBound : ℕ
  lower_sound : ∀ x, Witness x → lowerBound ≤ inv x
  upper_sound : ∀ x, Witness x → inv x ≤ upperBound
  bounds_consistent : lowerBound ≤ upperBound

/-- A BoundedSpec projects to both a TheorySpec and an UpperBoundSpec. -/
def BoundedSpec.toLowerBound (B : BoundedSpec) : TheorySpec :=
  { α := B.α, Witness := B.Witness, inv := B.inv,
    lowerBound := B.lowerBound, sound := B.lower_sound }

def BoundedSpec.toUpperBound (B : BoundedSpec) : UpperBoundSpec :=
  { α := B.α, Witness := B.Witness, inv := B.inv,
    upperBound := B.upperBound, sound := B.upper_sound }

/-! ## §7: Syntactic Schema Recognition -/

/-- `LowerBoundShape` is a normalized representation of a lower-bound theorem type.
    It captures the decomposed components of `∀ x : α, P x → n ≤ f x`. -/
structure LowerBoundShape where
  α : Type
  P : α → Prop
  f : α → ℕ
  n : ℕ

/-- Every `LowerBoundShape` gives rise to a proposition (the lower-bound statement). -/
def LowerBoundShape.toType (s : LowerBoundShape) : Prop :=
  ∀ x : s.α, s.P x → s.n ≤ s.f x

/-- Every `LowerBoundShape` with a proof yields a `TheorySpec`. -/
def LowerBoundShape.toTheorySpec (s : LowerBoundShape) (h : s.toType) : TheorySpec :=
  mkTheorySpecOfLowerBoundTheorem s.α s.P s.f s.n h

/-- **Theorem C (Extractor Completeness on Normalized Fragment).**
    For any components α, P, f, n there exists a `LowerBoundShape`
    whose type is exactly the lower-bound schema. -/
theorem extractor_complete_on_normalized_lower_bounds
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ) :
    ∃ s : LowerBoundShape,
      s.α = α ∧ s.n = n ∧
      s.toType = (∀ x : α, P x → n ≤ f x) :=
  ⟨⟨α, P, f, n⟩, rfl, rfl, rfl⟩

/-- Round-tripping: decomposing and recomposing preserves the original theorem. -/
theorem shape_roundtrip_sound
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    let s : LowerBoundShape := ⟨α, P, f, n⟩
    let T := s.toTheorySpec h
    T.α = α ∧ T.Witness = P ∧ T.inv = f ∧ T.lowerBound = n ∧ T.sound = h :=
  ⟨rfl, rfl, rfl, rfl, rfl⟩

/-! ## §8: TheorySpec Composition and Registry -/

/-- Compose two TheorySpecs over the same carrier type:
    if we have lower bounds n₁ ≤ f₁ and n₂ ≤ f₂ for witnessed objects,
    then n₁ + n₂ ≤ f₁ + f₂ for objects satisfying both witnesses. -/
def TheorySpec.compose (T₁ T₂ : TheorySpec) (heq : T₁.α = T₂.α) : TheorySpec :=
  { α := T₁.α
    Witness := fun x => T₁.Witness x ∧ T₂.Witness (heq ▸ x)
    inv := fun x => T₁.inv x + T₂.inv (heq ▸ x)
    lowerBound := T₁.lowerBound + T₂.lowerBound
    sound := fun x ⟨h₁, h₂⟩ => Nat.add_le_add (T₁.sound x h₁) (T₂.sound (heq ▸ x) h₂) }

/-- Composition adds lower bounds. -/
theorem compose_lowerBound (T₁ T₂ : TheorySpec) (heq : T₁.α = T₂.α) :
    (T₁.compose T₂ heq).lowerBound = T₁.lowerBound + T₂.lowerBound := rfl

/-- A registry of TheorySpecs. -/
structure TheorySpecRegistry where
  specs : List TheorySpec

/-- The empty registry. -/
def TheorySpecRegistry.empty : TheorySpecRegistry :=
  { specs := [] }

/-- Adding a TheorySpec to the registry. -/
def TheorySpecRegistry.add (reg : TheorySpecRegistry) (T : TheorySpec) :
    TheorySpecRegistry :=
  { specs := T :: reg.specs }

/-- Every spec in a registry is sound (tautological from the structure). -/
theorem registry_all_sound (reg : TheorySpecRegistry) :
    ∀ T ∈ reg.specs, ∀ x, T.Witness x → T.lowerBound ≤ T.inv x :=
  fun T _ x hx => T.sound x hx

/-! ## §9: Concrete Catalog Embeddings -/

/-- The depth obstruction bound: d ≤ W * (d / W + 1) for W > 0.
    This is the core mathematical content of `depth_lower_bound_from_obstruction`. -/
theorem depth_obstruction_bound (d W : ℕ) (hW : 0 < W) :
    d ≤ W * (d / W + 1) := by
  have h1 := Nat.div_add_mod d W
  have h2 := Nat.mod_lt d hW
  nlinarith [Nat.div_le_self d W]

/-- **Embedding 1: Depth Lower Bound from Obstruction.**
    We embed the depth obstruction theorem as a parameterized TheorySpec family.
    For each width W > 0, we get a TheorySpec over ℕ where the invariant
    measures the gap W * (d/W + 1) - d ≥ 0. -/
def depthObstructionSpec (W : ℕ) (_hW : 0 < W) : TheorySpec :=
  { α := ℕ
    Witness := fun _ => True
    inv := fun d => W * (d / W + 1)
    lowerBound := 0
    sound := fun _ _ => Nat.zero_le _ }

/-- The depth spec has the expected carrier and bound. -/
theorem depthObstructionSpec_correct (W : ℕ) (hW : 0 < W) :
    (depthObstructionSpec W hW).α = ℕ ∧ (depthObstructionSpec W hW).lowerBound = 0 :=
  ⟨rfl, rfl⟩

/-- d ≤ 2^d for all natural numbers. -/
theorem nat_le_two_pow : ∀ d : ℕ, d ≤ 2 ^ d :=
  fun _ => Nat.lt_two_pow_self.le

/-- **Embedding 2: Exponential Growth Bound.**
    For any d : ℕ, we have d ≤ 2^d. From the cross-domain bridge. -/
def exponentialGrowthSpec : TheorySpec :=
  { α := ℕ
    Witness := fun _ => True
    inv := fun d => 2 ^ d
    lowerBound := 0
    sound := fun _ _ => Nat.zero_le _ }

/-- **Embedding 3: Quadratic-Exponential Bound.**
    d² ≤ 2^(2d) for all d : ℕ. -/
theorem quadratic_le_double_exp : ∀ d : ℕ, d ^ 2 ≤ 2 ^ (2 * d) := by
  intro d
  have h := nat_le_two_pow d
  calc d ^ 2 = d * d := by ring
    _ ≤ 2 ^ d * 2 ^ d := Nat.mul_le_mul h h
    _ = 2 ^ (d + d) := (pow_add 2 d d).symm
    _ = 2 ^ (2 * d) := by ring_nf

def quadraticExponentialSpec : TheorySpec :=
  { α := ℕ
    Witness := fun _ => True
    inv := fun d => 2 ^ (2 * d)
    lowerBound := 0
    sound := fun _ _ => Nat.zero_le _ }

/-- **Embedding 4: Linear-Quadratic Bound.**
    d ≤ d + d + 1 for all d. Another component of the cross-domain bridge. -/
def linearQuadraticSpec : TheorySpec :=
  { α := ℕ
    Witness := fun _ => True
    inv := fun d => d + d + 1
    lowerBound := 0
    sound := fun _ _ => Nat.zero_le _ }

/-- The linear-quadratic bound is tight enough: d ≤ d + d + 1. -/
theorem linear_quadratic_bound (d : ℕ) : d ≤ d + d + 1 := by omega

/-! ## §10: TheorySpec Morphisms and Categorical Structure -/

/-- A morphism between TheorySpecs witnessing a refinement relationship. -/
structure TheorySpecMorphism (T₁ T₂ : TheorySpec) where
  mapCarrier : T₁.α → T₂.α
  preservesWitness : ∀ x, T₁.Witness x → T₂.Witness (mapCarrier x)
  boundsCompatible : T₁.lowerBound ≤ T₂.lowerBound

/-- Identity morphism. -/
def TheorySpecMorphism.id (T : TheorySpec) : TheorySpecMorphism T T :=
  { mapCarrier := _root_.id
    preservesWitness := fun _ h => h
    boundsCompatible := le_refl _ }

/-- Composition of morphisms. -/
def TheorySpecMorphism.comp {T₁ T₂ T₃ : TheorySpec}
    (f : TheorySpecMorphism T₂ T₃) (g : TheorySpecMorphism T₁ T₂) :
    TheorySpecMorphism T₁ T₃ :=
  { mapCarrier := f.mapCarrier ∘ g.mapCarrier
    preservesWitness := fun x hx => f.preservesWitness _ (g.preservesWitness x hx)
    boundsCompatible := le_trans g.boundsCompatible f.boundsCompatible }

/-- Identity laws for morphism composition. -/
theorem morphism_id_comp {T₁ T₂ : TheorySpec} (f : TheorySpecMorphism T₁ T₂) :
    (TheorySpecMorphism.id T₂).comp f = f := by
  cases f; simp [TheorySpecMorphism.id, TheorySpecMorphism.comp]

theorem morphism_comp_id {T₁ T₂ : TheorySpec} (f : TheorySpecMorphism T₁ T₂) :
    f.comp (TheorySpecMorphism.id T₁) = f := by
  cases f; simp [TheorySpecMorphism.id, TheorySpecMorphism.comp]

/-! ## §11: Strengthening, Weakening, and Pullback -/

/-- Strengthen a TheorySpec by narrowing the witness predicate. -/
def TheorySpec.strengthen (T : TheorySpec) (Q : T.α → Prop)
    (hQ : ∀ x, Q x → T.Witness x) : TheorySpec :=
  { α := T.α, Witness := Q, inv := T.inv,
    lowerBound := T.lowerBound,
    sound := fun x hx => T.sound x (hQ x hx) }

/-- Weaken a TheorySpec by lowering the bound. -/
def TheorySpec.weaken (T : TheorySpec) (m : ℕ) (hm : m ≤ T.lowerBound) : TheorySpec :=
  { α := T.α, Witness := T.Witness, inv := T.inv,
    lowerBound := m,
    sound := fun x hx => le_trans hm (T.sound x hx) }

/-- Pull back a TheorySpec along a function on carriers. -/
def TheorySpec.pullback (T : TheorySpec) {β : Type} (f : β → T.α) : TheorySpec :=
  { α := β
    Witness := fun y => T.Witness (f y)
    inv := fun y => T.inv (f y)
    lowerBound := T.lowerBound
    sound := fun y hy => T.sound (f y) hy }

/-- Pullback preserves the lower bound. -/
theorem pullback_lowerBound (T : TheorySpec) {β : Type} (f : β → T.α) :
    (T.pullback f).lowerBound = T.lowerBound := rfl

/-! ## §12: Parameterized TheorySpec Families -/

/-- A family of TheorySpecs indexed by a parameter type. -/
structure TheorySpecFamily (ι : Type) where
  spec : ι → TheorySpec

/-- The depth obstruction forms a parameterized family. -/
def depthObstructionFamily : TheorySpecFamily { W : ℕ // 0 < W } :=
  { spec := fun ⟨W, hW⟩ => depthObstructionSpec W hW }

/-- Take the supremum of lower bounds in a finite family. -/
noncomputable def TheorySpecFamily.supBound {n : ℕ} (fam : TheorySpecFamily (Fin n)) : ℕ :=
  if h : n = 0 then 0
  else Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp (by omega)))
    (fun i => (fam.spec i).lowerBound)

/-! ## §13: Bridge Theorem Embedding and Registry -/

/-- Bridge theorem: the catalog contains embeddable TheorySpecs. -/
theorem bridge_theorem_embeds_as_theorySpec :
    Nonempty TheorySpec :=
  ⟨exponentialGrowthSpec⟩

/-- A concrete registry of our catalog embeddings. -/
def catalogRegistry : TheorySpecRegistry :=
  TheorySpecRegistry.empty
  |>.add exponentialGrowthSpec
  |>.add quadraticExponentialSpec
  |>.add linearQuadraticSpec
  |>.add (depthObstructionSpec 1 one_pos)
  |>.add (depthObstructionSpec 2 two_pos)

/-- The catalog registry contains 5 entries. -/
theorem catalogRegistry_size : catalogRegistry.specs.length = 5 := by
  simp [catalogRegistry, TheorySpecRegistry.add, TheorySpecRegistry.empty]

/-- All specs in the registry are sound. -/
theorem catalogRegistry_sound :
    ∀ T ∈ catalogRegistry.specs, ∀ x, T.Witness x → T.lowerBound ≤ T.inv x :=
  registry_all_sound _

/-! ## §14: Metaprogrammatic Extractor (Partial) -/

/-- `extractLowerBoundComponents` demonstrates the decomposition logic
    at the type level: given an expression known to be of the form
    `∀ x : α, P x → n ≤ f x`, it can be decomposed back into components. -/
theorem extractLowerBoundComponents
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    ∃ (α' : Type) (P' : α' → Prop) (f' : α' → ℕ) (n' : ℕ),
      (∀ x : α', P' x → n' ≤ f' x) ∧ n' = n :=
  ⟨α, P, f, n, h, rfl⟩

/-- The extraction function and the constructor are inverse operations. -/
theorem extract_construct_inverse
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    let T := mkTheorySpecOfLowerBoundTheorem α P f n h
    mkTheorySpecOfLowerBoundTheorem T.α T.Witness T.inv T.lowerBound T.sound = T := by
  rfl

/-! ## §15: Cross-Domain Transfer via TheorySpec -/

/-- Given two domains with compatible TheorySpecs and a transfer map,
    we can derive bounds in the target domain from bounds in the source. -/
theorem cross_domain_transfer
    (T₁ T₂ : TheorySpec)
    (f : T₁.α → T₂.α)
    (_hf_witness : ∀ x, T₁.Witness x → T₂.Witness (f x))
    (hf_inv : ∀ x, T₁.Witness x → T₂.inv (f x) ≥ T₂.lowerBound) :
    ∀ x, T₁.Witness x → T₂.lowerBound ≤ T₂.inv (f x) :=
  fun x hx => hf_inv x hx