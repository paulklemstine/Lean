/-
# Multi-Invariant Theory Morphisms and Product Orders

This file develops the theory of **multi-invariant theory morphisms**: a framework
where a single morphism can transport multiple logically independent certificates
simultaneously, with full compositional clarity.

The key idea is that invariants live in product orders `Fin k → ℕ` (ordered pointwise),
so a single formal morphism carries, e.g., height + entropy + rank + robustness at once.

## Main Results

- `RichTheory` and `RichHom`: structures for k-invariant theories and their morphisms
- `RichHom.comp_mono_inv`: composition preserves the monotonicity property
- `scalar_to_rich_coordinate`: the scalar framework embeds as the k=1 special case
- `ScalarHom.toRich_faithful`: the embedding is faithful
- `scalar_hom_iff_rich_hom`: conservativity of enrichment
- `composite_dominates_source/intermediate/min`: dominance under composition
- `pairTheory` and `mk_pair_rich_hom`: bundling independent scalar certificates
- `mk_fin_rich_hom`: general finite-family bundling
- `CertTheory` and `CertHom`: preorder-valued generalization
-/

import Mathlib

/-! ## Core Definitions -/

/-- A `RichTheory k` is a type equipped with `k` natural-number-valued invariants. -/
structure RichTheory (k : ℕ) where
  Carrier : Type
  Inv : Carrier → Fin k → ℕ

/-- A `RichHom T₁ T₂` is a function between carriers that is coordinatewise non-increasing
    on invariants: for every element and every coordinate, the image's invariant is at most
    the source's invariant. This ensures upper bounds transfer forward. -/
structure RichHom {k : ℕ} (T₁ T₂ : RichTheory k) where
  toFun : T₁.Carrier → T₂.Carrier
  mono_inv : ∀ x i, T₂.Inv (toFun x) i ≤ T₁.Inv x i

/-! ## Identity and Composition -/

/-- The identity morphism on a rich theory. -/
@[simps]
def RichHom.id (T : RichTheory k) : RichHom T T where
  toFun := _root_.id
  mono_inv := fun _ _ => le_refl _

/-- Composition of rich morphisms. -/
@[simps]
def RichHom.comp {k : ℕ} {T₁ T₂ T₃ : RichTheory k}
    (g : RichHom T₂ T₃) (f : RichHom T₁ T₂) : RichHom T₁ T₃ where
  toFun := g.toFun ∘ f.toFun
  mono_inv := fun x i => le_trans (g.mono_inv (f.toFun x) i) (f.mono_inv x i)

/-! ## Simp Lemmas for Identity and Composition -/

@[simp]
theorem RichHom.id_apply {k : ℕ} (T : RichTheory k) (x : T.Carrier) :
    (RichHom.id T).toFun x = x := rfl

@[simp]
theorem RichHom.comp_apply {k : ℕ} {T₁ T₂ T₃ : RichTheory k}
    (g : RichHom T₂ T₃) (f : RichHom T₁ T₂) (x : T₁.Carrier) :
    (RichHom.comp g f).toFun x = g.toFun (f.toFun x) := rfl

/-! ## Composition Theorem -/

/-- **Composition theorem**: the composition of two rich morphisms satisfies the
    coordinatewise monotonicity property. This is the foundational result ensuring
    the product-order enrichment preserves the scalar transfer calculus. -/
theorem RichHom.comp_mono_inv
    {k : ℕ} {T₁ T₂ T₃ : RichTheory k}
    (g : RichHom T₂ T₃) (f : RichHom T₁ T₂) :
    ∀ x i, T₃.Inv (g.toFun (f.toFun x)) i ≤ T₁.Inv x i :=
  fun x i => le_trans (g.mono_inv (f.toFun x) i) (f.mono_inv x i)

/-- The invariant vector of an element. -/
def invVec {k : ℕ} (T : RichTheory k) (x : T.Carrier) : Fin k → ℕ := T.Inv x

/-- A rich morphism is monotone on invariant vectors: in every coordinate,
    the image's invariant is bounded by the source's. -/
theorem RichHom.monotone_vector
    {k : ℕ} {T₁ T₂ : RichTheory k} (f : RichHom T₁ T₂) :
    ∀ x, (∀ i, T₂.Inv (f.toFun x) i ≤ T₁.Inv x i) :=
  fun x i => f.mono_inv x i

/-! ## Scalar Theory and Embedding into k=1 -/

/-- A scalar theory: a type with a single ℕ-valued invariant. -/
structure ScalarTheory where
  Carrier : Type
  Inv : Carrier → ℕ

/-- A scalar morphism: a function that is non-increasing on the scalar invariant. -/
structure ScalarHom (T₁ T₂ : ScalarTheory) where
  toFun : T₁.Carrier → T₂.Carrier
  mono_inv : ∀ x, T₂.Inv (toFun x) ≤ T₁.Inv x

/-- Embed a scalar theory into a 1-invariant rich theory. -/
def ScalarTheory.toRich (T : ScalarTheory) : RichTheory 1 where
  Carrier := T.Carrier
  Inv := fun x _ => T.Inv x

/-- Embed a scalar morphism into a rich morphism. -/
def ScalarHom.toRich {T₁ T₂ : ScalarTheory} (f : ScalarHom T₁ T₂) :
    RichHom T₁.toRich T₂.toRich where
  toFun := f.toFun
  mono_inv := fun x _ => f.mono_inv x

/-- The coordinate-collapse theorem: the single coordinate of the enriched theory
    agrees with the original scalar invariant. -/
@[simp]
theorem scalar_to_rich_coordinate
    (T : ScalarTheory) (x : T.Carrier) :
    T.toRich.Inv x ⟨0, by decide⟩ = T.Inv x := rfl

/-- The scalar-to-rich embedding is faithful: if the underlying functions agree,
    the scalar morphisms agree. -/
theorem ScalarHom.toRich_faithful
    {T₁ T₂ : ScalarTheory} (f g : ScalarHom T₁ T₂)
    (h : f.toRich.toFun = g.toRich.toFun) :
    f.toFun = g.toFun := h

/-- **Conservativity theorem**: a function admits a scalar morphism structure
    if and only if it admits a rich morphism structure on the embedded theories.
    This certifies that the enriched framework is a true extension. -/
theorem scalar_hom_iff_rich_hom
    {T₁ T₂ : ScalarTheory} (f : T₁.Carrier → T₂.Carrier) :
    (∃ h : ScalarHom T₁ T₂, h.toFun = f) ↔
    (∃ h : RichHom T₁.toRich T₂.toRich, h.toFun = f) := by
  constructor
  · rintro ⟨h, rfl⟩
    exact ⟨h.toRich, rfl⟩
  · rintro ⟨h, rfl⟩
    refine ⟨⟨h.toFun, fun x => h.mono_inv x ⟨0, by decide⟩⟩, rfl⟩

/-! ## Dominance Theorems -/

/-- **Source dominance**: the composite transfer dominates the source certificate
    in every coordinate. -/
theorem composite_dominates_source
    {k : ℕ} {T₁ T₂ T₃ : RichTheory k}
    (f : RichHom T₁ T₂) (g : RichHom T₂ T₃) :
    ∀ x i, T₃.Inv (g.toFun (f.toFun x)) i ≤ T₁.Inv x i :=
  fun x i => le_trans (g.mono_inv (f.toFun x) i) (f.mono_inv x i)

/-- **Intermediate dominance**: the composite transfer dominates the intermediate
    certificate in every coordinate. -/
theorem composite_dominates_intermediate
    {k : ℕ} {T₁ T₂ T₃ : RichTheory k}
    (f : RichHom T₁ T₂) (g : RichHom T₂ T₃) :
    ∀ x i, T₃.Inv (g.toFun (f.toFun x)) i ≤ T₂.Inv (f.toFun x) i :=
  fun x i => g.mono_inv (f.toFun x) i

/-- **Minimum dominance**: the composite transfer is bounded by the minimum of the
    intermediate and source certificates in every coordinate. This formalizes
    "a composite bridge preserves all tracked certificates at once." -/
theorem composite_dominates_min
    {k : ℕ} {T₁ T₂ T₃ : RichTheory k}
    (f : RichHom T₁ T₂) (g : RichHom T₂ T₃) :
    ∀ x i, T₃.Inv (g.toFun (f.toFun x)) i ≤ min (T₂.Inv (f.toFun x) i) (T₁.Inv x i) := by
  intro x i
  exact le_min (g.mono_inv (f.toFun x) i) (le_trans (g.mono_inv (f.toFun x) i) (f.mono_inv x i))

/-! ## Pair Theory: Bundling Two Scalar Certificates -/

/-- Construct a 2-invariant theory from two scalar invariants on the same carrier. -/
def pairTheory (α : Type) (I₁ I₂ : α → ℕ) : RichTheory 2 where
  Carrier := α
  Inv := fun x i => match i with
    | ⟨0, _⟩ => I₁ x
    | ⟨1, _⟩ => I₂ x

@[simp]
theorem pairTheory_coord0 (α : Type) (I₁ I₂ : α → ℕ) (x : α) :
    (pairTheory α I₁ I₂).Inv x ⟨0, by omega⟩ = I₁ x := rfl

@[simp]
theorem pairTheory_coord1 (α : Type) (I₁ I₂ : α → ℕ) (x : α) :
    (pairTheory α I₁ I₂).Inv x ⟨1, by omega⟩ = I₂ x := rfl

/-- **Bundling theorem**: given two independent scalar certificate-transfer lemmas,
    assemble them into a single rich morphism on the paired theory. -/
def mk_pair_rich_hom
    {α β : Type} {I₁ I₂ : α → ℕ} {J₁ J₂ : β → ℕ}
    (f : α → β)
    (h₁ : ∀ x, J₁ (f x) ≤ I₁ x)
    (h₂ : ∀ x, J₂ (f x) ≤ I₂ x) :
    RichHom (pairTheory α I₁ I₂) (pairTheory β J₁ J₂) where
  toFun := f
  mono_inv := fun x i => by
    match i with
    | ⟨0, _⟩ => exact h₁ x
    | ⟨1, _⟩ => exact h₂ x

/-- The bundled morphism preserves coordinate 0. -/
theorem mk_pair_rich_hom_coord0
    {α β : Type} {I₁ I₂ : α → ℕ} {J₁ J₂ : β → ℕ}
    (f : α → β) (h₁ : ∀ x, J₁ (f x) ≤ I₁ x) (h₂ : ∀ x, J₂ (f x) ≤ I₂ x) (x : α) :
    (pairTheory β J₁ J₂).Inv ((mk_pair_rich_hom f h₁ h₂).toFun x) ⟨0, by omega⟩ ≤
    (pairTheory α I₁ I₂).Inv x ⟨0, by omega⟩ := h₁ x

/-- The bundled morphism preserves coordinate 1. -/
theorem mk_pair_rich_hom_coord1
    {α β : Type} {I₁ I₂ : α → ℕ} {J₁ J₂ : β → ℕ}
    (f : α → β) (h₁ : ∀ x, J₁ (f x) ≤ I₁ x) (h₂ : ∀ x, J₂ (f x) ≤ I₂ x) (x : α) :
    (pairTheory β J₁ J₂).Inv ((mk_pair_rich_hom f h₁ h₂).toFun x) ⟨1, by omega⟩ ≤
    (pairTheory α I₁ I₂).Inv x ⟨1, by omega⟩ := h₂ x

/-! ## Stretch: General Finite-Family Bundling -/

/-- **Finite-family bundling theorem**: given `k` independent scalar certificate-transfer
    lemmas, assemble them into a single rich morphism. This upgrades the pair construction
    to arbitrary finite collections and turns the framework into a theorem factory. -/
def mk_fin_rich_hom
    {k : ℕ} {α β : Type}
    {I : Fin k → α → ℕ} {J : Fin k → β → ℕ}
    (f : α → β)
    (h : ∀ i x, J i (f x) ≤ I i x) :
    RichHom
      { Carrier := α, Inv := fun x i => I i x }
      { Carrier := β, Inv := fun y i => J i y } where
  toFun := f
  mono_inv := fun x i => h i x

/-! ## Associativity and Unit Laws -/

/-- Left identity law for composition. -/
theorem RichHom.id_comp {k : ℕ} {T₁ T₂ : RichTheory k} (f : RichHom T₁ T₂) :
    (RichHom.comp (RichHom.id T₂) f).toFun = f.toFun := rfl

/-- Right identity law for composition. -/
theorem RichHom.comp_id {k : ℕ} {T₁ T₂ : RichTheory k} (f : RichHom T₁ T₂) :
    (RichHom.comp f (RichHom.id T₁)).toFun = f.toFun := rfl

/-- Associativity of composition. -/
theorem RichHom.comp_assoc {k : ℕ} {T₁ T₂ T₃ T₄ : RichTheory k}
    (h : RichHom T₃ T₄) (g : RichHom T₂ T₃) (f : RichHom T₁ T₂) :
    (RichHom.comp (RichHom.comp h g) f).toFun =
    (RichHom.comp h (RichHom.comp g f)).toFun := rfl

/-! ## Preorder-Valued Generalization -/

/-- A certificate theory over a preorder: a type equipped with an invariant
    taking values in a preorder `L`. This generalizes `RichTheory` to
    arbitrary value lattices. -/
structure CertTheory (L : Type) [Preorder L] where
  Carrier : Type
  Inv : Carrier → L

/-- A certificate morphism: a function that is non-increasing on the invariant
    in a preorder-valued theory. -/
structure CertHom (L : Type) [Preorder L]
    (T₁ T₂ : CertTheory L) where
  toFun : T₁.Carrier → T₂.Carrier
  mono_inv : ∀ x, T₂.Inv (toFun x) ≤ T₁.Inv x

/-- Identity certificate morphism. -/
def CertHom.id {L : Type} [Preorder L] (T : CertTheory L) :
    CertHom L T T where
  toFun := _root_.id
  mono_inv := fun _ => le_refl _

/-- Composition of certificate morphisms. -/
def CertHom.comp {L : Type} [Preorder L] {T₁ T₂ T₃ : CertTheory L}
    (g : CertHom L T₂ T₃) (f : CertHom L T₁ T₂) : CertHom L T₁ T₃ where
  toFun := g.toFun ∘ f.toFun
  mono_inv := fun x => le_trans (g.mono_inv (f.toFun x)) (f.mono_inv x)

/-- Composition of certificate morphisms preserves monotonicity. -/
theorem CertHom.comp_mono_inv {L : Type} [Preorder L]
    {T₁ T₂ T₃ : CertTheory L}
    (g : CertHom L T₂ T₃) (f : CertHom L T₁ T₂) :
    ∀ x, T₃.Inv (g.toFun (f.toFun x)) ≤ T₁.Inv x :=
  fun x => le_trans (g.mono_inv (f.toFun x)) (f.mono_inv x)

/-- A `RichTheory k` can be viewed as a `CertTheory` over the pointwise order. -/
def RichTheory.toCertTheory {k : ℕ} (T : RichTheory k) :
    CertTheory (Fin k → ℕ) where
  Carrier := T.Carrier
  Inv := T.Inv

/-- A `RichHom` induces a `CertHom` on the pointwise order. -/
def RichHom.toCertHom {k : ℕ} {T₁ T₂ : RichTheory k}
    (f : RichHom T₁ T₂) :
    CertHom (Fin k → ℕ) T₁.toCertTheory T₂.toCertTheory where
  toFun := f.toFun
  mono_inv := fun x => Pi.le_def.mpr (f.mono_inv x)

/-! ## Application Examples -/

/-- Example: combining a "height" bound and a "rank" bound into a single rich morphism.
    This demonstrates the practical use case where two independently proven scalar
    bounds are bundled into one compositional certificate. -/
example : RichHom
    (pairTheory ℕ (fun n => n) (fun n => 2 * n))
    (pairTheory ℕ (fun n => n) (fun n => 2 * n)) :=
  mk_pair_rich_hom _root_.id (fun _ => le_refl _) (fun _ => le_refl _)

/-- A nontrivial example: a function that halves both invariants. -/
example : RichHom
    (pairTheory ℕ (fun n => n) (fun n => n))
    (pairTheory ℕ (fun n => n / 2) (fun n => n / 2)) :=
  mk_pair_rich_hom _root_.id (fun x => Nat.div_le_self x 2) (fun x => Nat.div_le_self x 2)

/-- Composing two bundled morphisms demonstrates the compositional structure. -/
example : RichHom
    (pairTheory ℕ (fun n => 4 * n) (fun n => 4 * n))
    (pairTheory ℕ (fun n => n) (fun n => n)) :=
  let f : RichHom
      (pairTheory ℕ (fun n => 4 * n) (fun n => 4 * n))
      (pairTheory ℕ (fun n => 2 * n) (fun n => 2 * n)) :=
    mk_pair_rich_hom _root_.id (fun _ => by simp [_root_.id]; omega) (fun _ => by simp [_root_.id]; omega)
  let g : RichHom
      (pairTheory ℕ (fun n => 2 * n) (fun n => 2 * n))
      (pairTheory ℕ (fun n => n) (fun n => n)) :=
    mk_pair_rich_hom _root_.id (fun _ => by simp [_root_.id]; omega) (fun _ => by simp [_root_.id]; omega)
  RichHom.comp g f

/-- Example using `mk_fin_rich_hom` to bundle 3 invariants at once. -/
example : let I : Fin 3 → ℕ → ℕ := ![_root_.id, (· * 2), (· * 3)]
    let J : Fin 3 → ℕ → ℕ := ![(· / 2), _root_.id, _root_.id]
    RichHom
      { Carrier := ℕ, Inv := fun n i => I i n }
      { Carrier := ℕ, Inv := fun n i => J i n } :=
  mk_fin_rich_hom _root_.id (fun i x => by
    fin_cases i <;> simp [_root_.id, Matrix.cons_val_zero, Matrix.cons_val_one] <;> omega)