import Mathlib

/-!
# Monoidal strictification of the parenthesization category

This file is the next step of the mission *"Causal Loops in Category Theory: when
composition loops back"*.  Previous cycles built the parenthesization category
`PTree α` — binary trees viewed as formal bracketings, whose tensor `⊗ = node` is
**not associative on the nose** but is repaired by a canonical invertible associator,
with all coherence holding for free because the category is *thin* — and exhibited a
plain categorical equivalence `PTree α ≌ Discrete (List α)` collapsing the loops.

Here we **upgrade that equivalence to a monoidal one**, which is the full content of
Mac Lane's strictification theorem for this family:

* the strict skeleton is `Discrete (FreeMonoid α)` with tensor given by concatenation
  (Mathlib's `Discrete.monoidal`);
* the flattening functor `PTree α ⥤ Discrete (FreeMonoid α)` is a **strong monoidal
  functor** (`flattenFunctor.Monoidal`);
* it underlies an equivalence `strictify` whose functor *and inverse* are monoidal and
  which is a **monoidal equivalence** (`strictify.IsMonoidal`).

The whole development is self-contained: it re-establishes the thin-category engine and
the parenthesization category, then carries out the monoidal upgrade.  As always, every
coherence obligation is discharged *for free* because both categories in play are thin
(hom-sets are subsingletons).

## Chain of results

1. `ThinCategory`, `monoidalOfThin` — coherence is free on a thin category.
2. `PTree`, `flatten`, `instMonoidalCategory` — the non-strict parenthesization category.
3. `flatten_tensor`, `flatten_unit` — flattening is a monoid morphism up to the loops.
4. `flattenFunctor`, `instFlattenMonoidal` — flattening is a **strong monoidal functor**.
5. `strictify` — the underlying categorical equivalence with `Discrete (FreeMonoid α)`.
6. `strictify_functor_monoidal`, `strictify_inverse_monoidal`, `strictify_isMonoidal`
   — **the monoidal strictification theorem**: `PTree α` is monoidally equivalent to its
   strict skeleton.
7. `flatten_associator_to_id` — under strictification the associator loop becomes an
   identity.
-/

open CategoryTheory MonoidalCategory

namespace MacLaneStrict

universe u

/-! ### The thin-category engine -/

/-- A **thin** category: at most one morphism between any two objects.  In a thin
category every diagram commutes, so any monoidal data is automatically coherent. -/
class ThinCategory (C : Type*) [Category C] : Prop where
  /-- Any two parallel morphisms are equal. -/
  thin : ∀ {X Y : C} (f g : X ⟶ Y), f = g

namespace ThinCategory

variable {C : Type*} [Category C] [ThinCategory C]

/-- Hom-sets of a thin category are subsingletons. -/
instance subsingleton_hom (X Y : C) : Subsingleton (X ⟶ Y) :=
  ⟨fun f g => ThinCategory.thin f g⟩

end ThinCategory

/-- **Coherence is free on a thin category.**  Any `MonoidalCategoryStruct` on a thin
category assembles into a genuine `MonoidalCategory`. -/
def monoidalOfThin (C : Type*) [Category C] [ThinCategory C]
    [MonoidalCategoryStruct C] : MonoidalCategory C where
  tensorHom_def := by intros; apply ThinCategory.thin
  id_tensorHom_id := by intros; apply ThinCategory.thin
  tensorHom_comp_tensorHom := by intros; apply ThinCategory.thin
  whiskerLeft_id := by intros; apply ThinCategory.thin
  id_whiskerRight := by intros; apply ThinCategory.thin
  associator_naturality := by intros; apply ThinCategory.thin
  leftUnitor_naturality := by intros; apply ThinCategory.thin
  rightUnitor_naturality := by intros; apply ThinCategory.thin
  pentagon := by intros; apply ThinCategory.thin
  triangle := by intros; apply ThinCategory.thin

/-! ### The parenthesization category -/

/-- Binary trees with leaves labelled in `α`, with an empty tree `nil`.  A tree is a
*formal parenthesization*: `node s t` is the bracketed product `(s · t)`. -/
inductive PTree (α : Type u) where
  | nil : PTree α
  | leaf : α → PTree α
  | node : PTree α → PTree α → PTree α

namespace PTree

variable {α : Type u}

/-- The underlying leaf-word of a tree, valued in the free monoid, forgetting the
bracketing. -/
def flatten : PTree α → FreeMonoid α
  | nil => 1
  | leaf a => FreeMonoid.of a
  | node l r => flatten l * flatten r

@[simp] theorem flatten_nil : flatten (nil : PTree α) = 1 := rfl
@[simp] theorem flatten_leaf (a : α) : flatten (leaf a) = FreeMonoid.of a := rfl
@[simp] theorem flatten_node (l r : PTree α) :
    flatten (node l r) = flatten l * flatten r := rfl

/-- **The parenthesization category.**  A morphism `s ⟶ t` is a proof that `s` and `t`
have the same underlying leaf-word.  This is the thin reassociation groupoid. -/
instance instCategory : Category (PTree α) where
  Hom s t := PLift (flatten (α := α) s = flatten t)
  id _ := ⟨rfl⟩
  comp f g := ⟨f.down.trans g.down⟩

/-- Package an equality of leaf-words into a morphism. -/
def homOfEq {s t : PTree α} (h : flatten s = flatten t) : s ⟶ t := ⟨h⟩

@[simp] theorem homOfEq_down {s t : PTree α} (h : flatten s = flatten t) :
    (homOfEq h).down = h := rfl

/-- The parenthesization category is **thin**. -/
instance instThinCategory : ThinCategory (PTree α) where
  thin f g := by obtain ⟨f⟩ := f; obtain ⟨g⟩ := g; rfl

/-- Package an equality of leaf-words into an isomorphism of trees. -/
@[simps] def isoOfEq {s t : PTree α} (h : flatten s = flatten t) : s ≅ t where
  hom := homOfEq h
  inv := homOfEq h.symm
  hom_inv_id := ThinCategory.thin _ _
  inv_hom_id := ThinCategory.thin _ _

/-- The tensor data on `PTree α`: `⊗ = node`, unit `nil`, associator/unitors read off
from the monoid structure of the free monoid of leaf-words. -/
instance instMonoidalStruct : MonoidalCategoryStruct (PTree α) where
  tensorObj := node
  whiskerLeft X _ _ f := homOfEq (congrArg (flatten X * ·) f.down)
  whiskerRight f Y := homOfEq (congrArg (· * flatten Y) f.down)
  tensorUnit := nil
  associator _ _ _ := isoOfEq (mul_assoc _ _ _)
  leftUnitor _ := isoOfEq (one_mul _)
  rightUnitor _ := isoOfEq (mul_one _)

@[simp] theorem tensorObj_def (s t : PTree α) : s ⊗ t = node s t := rfl
@[simp] theorem tensorUnit_def : (𝟙_ (PTree α)) = nil := rfl

/-- **`PTree α` is a genuine monoidal category**, coherence inherited for free from
thinness. -/
instance instMonoidalCategory : MonoidalCategory (PTree α) :=
  monoidalOfThin (PTree α)

/-- Flattening turns the tensor product into the product of the free monoid. -/
theorem flatten_tensor (s t : PTree α) : flatten (s ⊗ t) = flatten s * flatten t := rfl

/-- Flattening sends the tensor unit to the monoid unit. -/
theorem flatten_unit : flatten (𝟙_ (PTree α)) = 1 := rfl

/-! ### Flattening as a strong monoidal functor -/

/-- **The flattening functor** to the strict skeleton `Discrete (FreeMonoid α)`. -/
def flattenFunctor : PTree α ⥤ Discrete (FreeMonoid α) where
  obj s := ⟨flatten s⟩
  map f := Discrete.eqToHom f.down
  map_id := by intros; apply Subsingleton.elim
  map_comp := by intros; apply Subsingleton.elim

@[simp] theorem flattenFunctor_obj (s : PTree α) :
    (flattenFunctor.obj s : Discrete (FreeMonoid α)).as = flatten s := rfl

/-- The `CoreMonoidal` structure making `flattenFunctor` strong monoidal.  The unit and
tensorator isomorphisms are identities (flattening strictly respects tensor and unit);
every coherence square holds because `Discrete (FreeMonoid α)` is thin. -/
def flattenCore : (flattenFunctor (α := α)).CoreMonoidal where
  εIso := Iso.refl _
  μIso _ _ := Iso.refl _
  μIso_hom_natural_left := by intros; apply Subsingleton.elim
  μIso_hom_natural_right := by intros; apply Subsingleton.elim
  associativity := by intros; apply Subsingleton.elim
  left_unitality := by intros; apply Subsingleton.elim
  right_unitality := by intros; apply Subsingleton.elim

/-- **Flattening is a strong monoidal functor.** -/
instance instFlattenMonoidal : (flattenFunctor (α := α)).Monoidal :=
  flattenCore.toMonoidal

/-! ### The strictification equivalence -/

/-- The canonical **right-nested** tree of a leaf-word: a chosen normal form for the
reassociation classes of bracketings. -/
def ofList : List α → PTree α
  | [] => nil
  | a :: rest => node (leaf a) (ofList rest)

@[simp] theorem flatten_ofList (l : List α) : flatten (ofList l) = FreeMonoid.ofList l := by
  induction l with
  | nil => rfl
  | cons a rest ih =>
      simp only [ofList, flatten_node, ih]
      rfl

/-- The inverse to strictification: realise a word as its normal-form bracketing. -/
def unnormalize : Discrete (FreeMonoid α) ⥤ PTree α :=
  Discrete.functor (fun l => ofList (FreeMonoid.toList l))

/-- **The parenthesization category is equivalent to its strict skeleton**
`Discrete (FreeMonoid α)`. -/
def strictify : PTree α ≌ Discrete (FreeMonoid α) where
  functor := flattenFunctor
  inverse := unnormalize
  unitIso := NatIso.ofComponents
    (fun _ => isoOfEq (by
      simp [flattenFunctor, unnormalize, Discrete.functor]))
    (by intros; apply Subsingleton.elim)
  counitIso := NatIso.ofComponents
    (fun d => Discrete.eqToIso (by
      obtain ⟨l⟩ := d
      simp [flattenFunctor, unnormalize, Discrete.functor]))
    (by intros; apply Subsingleton.elim)
  functor_unitIso_comp := by intros; apply Subsingleton.elim

/-- `strictify`'s functor is exactly the flattening functor. -/
theorem strictify_functor : (strictify (α := α)).functor = flattenFunctor := rfl

/-- The functor of `strictify` is monoidal. -/
instance strictify_functor_monoidal : (strictify (α := α)).functor.Monoidal :=
  instFlattenMonoidal

/-- The inverse of `strictify` is also monoidal (Mac Lane: the strictification is a
*monoidal* equivalence, so its inverse carries a canonical monoidal structure). -/
noncomputable instance strictify_inverse_monoidal : (strictify (α := α)).inverse.Monoidal :=
  (strictify (α := α)).inverseMonoidal

/-- **Monoidal strictification theorem (this family).**  The equivalence
`PTree α ≌ Discrete (FreeMonoid α)` is a *monoidal* equivalence: the non-strict
parenthesization category is monoidally equivalent to its strict skeleton. -/
instance strictify_isMonoidal : (strictify (α := α)).IsMonoidal :=
  inferInstance

/-! ### Collapsing the loop -/

/-- **The loop is contracted.**  Under strictification the associator — the invertible
`2`-cell repairing the on-the-nose failure of associativity — becomes an identity-type
morphism in the discrete strict skeleton. -/
theorem flatten_associator_to_id (a b c : PTree α) :
    (flattenFunctor (α := α)).map (α_ a b c).hom =
      eqToHom (by apply Discrete.ext; simp [flattenFunctor, mul_assoc]) :=
  Subsingleton.elim _ _

end PTree

end MacLaneStrict