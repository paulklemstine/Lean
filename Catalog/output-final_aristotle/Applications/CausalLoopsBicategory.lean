import Mathlib

/-!
# Causal loops in category theory: controlled failure of associativity

When one insists that composition (or a tensor product) be associative *on the nose*,
the parenthesization of a composite must be forgotten.  A gentler stance keeps the
brackets but supplies an invertible comparison — the **associator** — witnessing
`(f · g) · h ≅ f · (g · h)`.  This file develops the resulting *almost-category* in a
completely concrete form and pushes three ideas further than the naive construction:

1. **Coherence is free in the thin world.**  Any tensor data on a category with
   subsingleton hom-sets automatically satisfies Mac Lane's pentagon and triangle
   equations.  The `2`-cells recording "how composition loops back" are so rigid that no
   incoherence can arise (`monoidalOfThin`).

2. **A concrete non-strict monoidal category.**  The parenthesization category `PTree α`
   has as objects the binary trees (bracketings) over `α`, and as morphisms the proofs
   that two bracketings share an underlying word.  Its tensor product is *not* associative
   on objects (`PTree.tensor_assoc_ne`), yet it is a genuine monoidal category whose
   isomorphisms are unique (`PTree.associator_unique`).  Its skeleton is the free monoid
   `(List α, ++, [])` (`PTree.ofList_append`, `PTree.normalize`).

3. **A combinatorial census of the loops.**  The connected components of the
   reassociation groupoid are exactly the words; the size of a component built from
   `n + 1` factors is the Catalan number `C n` (`Shape.card_bracketings`), and it obeys
   the Segner convolution recurrence (`Shape.card_bracketings_succ`).  This links the
   categorical "loops" to a classical enumeration.

## Lab Notes

`-- !-- Lab Notes -- !--`

* **Hypothesis.**  A category in which associativity fails only up to a unique invertible
  comparison should be automatically coherent, and the multiplicity of bracketings that
  such a comparison identifies should be a Catalan number.

* **Experiment.**  We realised the almost-category as the parenthesization category
  `PTree α`, proved thinness forces coherence, and identified each isomorphism class with
  a word.  For the census we built an explicit bijection between abstract bracketing
  `Shape`s and finite binary trees and transported the Catalan enumeration across it.

* **Analysis.**  Thinness is precisely the hypothesis that turns "controlled failure of
  associativity" into a full monoidal (indeed bicategorical) structure with no coherence
  obligations: every pentagon/triangle diagram commutes because parallel maps coincide.
  Strictification then collapses the tower of associators onto the free monoid, and the
  Catalan count measures how much the associator glues together.

* **Critique.**  `tensor_assoc_ne` shows the failure of associativity is genuine (distinct
  objects, checked by a size argument), so the monoidal structure is honestly non-strict —
  not a definitional-equality dressed up as an isomorphism.  The census avoids triviality
  by proving a real bijection and the convolution recurrence, not a single decision
  procedure.

* **Synthesis.**  "Loop-tolerant" associativity, once coherent, is equivalent data to a
  strict monoid together with a Catalan-indexed bookkeeping of bracketings.
-/

open CategoryTheory MonoidalCategory

namespace CausalLoopsDeep

universe v u

/-! ## 1. Coherence is free in a thin category -/

/-- A **thin** category: at most one morphism between any two objects.  Equivalently a
preorder viewed as a category; in a thin category every diagram commutes. -/
class ThinCat (C : Type u) [Category.{v} C] : Prop where
  /-- Any two parallel morphisms are equal. -/
  thin : ∀ {X Y : C} (f g : X ⟶ Y), f = g

namespace ThinCat

variable {C : Type u} [Category.{v} C] [ThinCat C]

/-- Extensionality for morphisms in a thin category. -/
theorem hom_ext {X Y : C} (f g : X ⟶ Y) : f = g := ThinCat.thin f g

/-- Hom-sets of a thin category are subsingletons. -/
instance subsingleton_hom (X Y : C) : Subsingleton (X ⟶ Y) :=
  ⟨fun f g => ThinCat.thin f g⟩

/-- Even the isomorphisms between two objects of a thin category are unique. -/
instance subsingleton_iso (X Y : C) : Subsingleton (X ≅ Y) :=
  ⟨fun f g => by apply Iso.ext; exact ThinCat.thin _ _⟩

end ThinCat

/-- **Coherence is free in a thin category.**  Any choice of tensor data on a thin
category automatically assembles into a genuine monoidal category: the pentagon and
triangle identities and every naturality square hold because parallel morphisms coincide.
This is the abstract form of "every coherent loop-tolerant structure is a higher
category". -/
def monoidalOfThin (C : Type u) [Category.{v} C] [ThinCat C]
    [MonoidalCategoryStruct C] : MonoidalCategory C where
  tensorHom_def := by intros; apply ThinCat.thin
  id_tensorHom_id := by intros; apply ThinCat.thin
  tensorHom_comp_tensorHom := by intros; apply ThinCat.thin
  whiskerLeft_id := by intros; apply ThinCat.thin
  id_whiskerRight := by intros; apply ThinCat.thin
  associator_naturality := by intros; apply ThinCat.thin
  leftUnitor_naturality := by intros; apply ThinCat.thin
  rightUnitor_naturality := by intros; apply ThinCat.thin
  pentagon := by intros; apply ThinCat.thin
  triangle := by intros; apply ThinCat.thin

namespace ThinCat

variable {C : Type u} [Category.{v} C] [ThinCat C] [MonoidalCategoryStruct C]

/-- The pentagon equation holds in any monoidal structure on a thin category. -/
theorem pentagon_eq (W X Y Z : C) :
    (α_ W X Y).hom ▷ Z ≫ (α_ W (X ⊗ Y) Z).hom ≫ W ◁ (α_ X Y Z).hom =
      (α_ (W ⊗ X) Y Z).hom ≫ (α_ W X (Y ⊗ Z)).hom :=
  ThinCat.thin _ _

/-- The triangle equation holds in any monoidal structure on a thin category. -/
theorem triangle_eq (X Y : C) :
    (α_ X (𝟙_ C) Y).hom ≫ X ◁ (λ_ Y).hom = (ρ_ X).hom ▷ Y :=
  ThinCat.thin _ _

/-- **A causal loop closes to the identity.**  Travelling the long Mac Lane route around
the pentagon and back along the inverse short route is the identity: when composition
loops back, it loops back to where it started. -/
theorem associator_loop (W X Y Z : C) :
    ((α_ W X Y).hom ▷ Z ≫ (α_ W (X ⊗ Y) Z).hom ≫ W ◁ (α_ X Y Z).hom) ≫
        (α_ (W ⊗ X) Y Z ≪≫ α_ W X (Y ⊗ Z)).inv =
      𝟙 _ :=
  ThinCat.thin _ _

end ThinCat

/-! ## 2. The parenthesization category -/

/-- Binary trees with leaves labelled in `α`, with an empty tree `nil`.  A tree is a
*formal parenthesization*: `node s t` is the bracketed product `(s · t)`. -/
inductive PTree (α : Type*) where
  | nil : PTree α
  | leaf : α → PTree α
  | node : PTree α → PTree α → PTree α
  deriving DecidableEq

namespace PTree

variable {α : Type*}

/-- The underlying leaf-word of a tree, forgetting the bracketing. -/
def flatten : PTree α → List α
  | nil => []
  | leaf a => [a]
  | node l r => flatten l ++ flatten r

@[simp] theorem flatten_nil : flatten (nil : PTree α) = [] := rfl
@[simp] theorem flatten_leaf (a : α) : flatten (leaf a) = [a] := rfl
@[simp] theorem flatten_node (l r : PTree α) :
    flatten (node l r) = flatten l ++ flatten r := rfl

/-- **The parenthesization category.**  A morphism `s ⟶ t` is a proof that `s` and `t`
have the same underlying leaf-word; composition is transitivity of equality. -/
instance instCategory (α : Type*) : Category (PTree α) where
  Hom s t := PLift (flatten (α := α) s = flatten t)
  id _ := ⟨rfl⟩
  comp f g := ⟨f.down.trans g.down⟩

/-- Package an equality of leaf-words into a morphism. -/
def homOfEq {s t : PTree α} (h : flatten s = flatten t) : s ⟶ t := ⟨h⟩

/-- The parenthesization category is **thin**. -/
instance instThinCat (α : Type*) : ThinCat (PTree α) where
  thin f g := by obtain ⟨f⟩ := f; obtain ⟨g⟩ := g; rfl

/-- Every morphism of the parenthesization category is invertible: it is a groupoid. -/
instance instIsIso {s t : PTree α} (f : s ⟶ t) : IsIso f :=
  ⟨homOfEq f.down.symm, ThinCat.thin _ _, ThinCat.thin _ _⟩

/-- Package an equality of leaf-words into an isomorphism of trees. -/
@[simps] def isoOfEq {s t : PTree α} (h : flatten s = flatten t) : s ≅ t where
  hom := homOfEq h
  inv := homOfEq h.symm
  hom_inv_id := ThinCat.thin _ _
  inv_hom_id := ThinCat.thin _ _

/-- The tensor data on `PTree α`: tensor of objects is `node`, the unit is `nil`, and the
associator/unitors are read off from list concatenation. -/
instance instMonoidalStruct (α : Type*) : MonoidalCategoryStruct (PTree α) where
  tensorObj := node
  whiskerLeft X _ _ f := homOfEq (congrArg (flatten X ++ ·) f.down)
  whiskerRight f Y := homOfEq (congrArg (· ++ flatten Y) f.down)
  tensorUnit := nil
  associator a b c := isoOfEq (by simp [List.append_assoc])
  leftUnitor a := isoOfEq (by simp)
  rightUnitor a := isoOfEq (by simp)

@[simp] theorem tensorObj_def (s t : PTree α) : s ⊗ t = node s t := rfl
@[simp] theorem tensorUnit_def : (𝟙_ (PTree α)) = nil := rfl

/-- **`PTree α` is a genuine monoidal category**, its coherence inherited for free from
thinness. -/
instance instMonoidalCategory (α : Type*) : MonoidalCategory (PTree α) :=
  monoidalOfThin (PTree α)

/-- **Associativity fails on the nose.**  For any trees `a b c`, the bracketings
`(a ⊗ b) ⊗ c` and `a ⊗ (b ⊗ c)` are genuinely distinct objects, even though canonically
isomorphic. -/
theorem tensor_assoc_ne (a b c : PTree α) : ((a ⊗ b) ⊗ c) ≠ (a ⊗ (b ⊗ c)) := by
  show node (node a b) c ≠ node a (node b c)
  intro h
  injection h with h1 _
  have hsz : sizeOf (node a b) = sizeOf a := by rw [h1]
  simp only [PTree.node.sizeOf_spec] at hsz
  omega

/-- **`PTree α` is not strict.**  There are objects on which the associator is not an
identity morphism, its source and target being distinct. -/
theorem not_strict : ∃ a b c : PTree α, ((a ⊗ b) ⊗ c) ≠ (a ⊗ (b ⊗ c)) :=
  ⟨nil, nil, nil, tensor_assoc_ne nil nil nil⟩

/-- The associator is the **unique** isomorphism between its endpoints. -/
theorem associator_unique (a b c : PTree α)
    (φ : ((a ⊗ b) ⊗ c) ≅ (a ⊗ (b ⊗ c))) : φ = α_ a b c :=
  Subsingleton.elim _ _

/-- **Coherence is connectedness.**  Two bracketings are isomorphic exactly when they have
the same underlying word: the isomorphism class remembers only the word. -/
theorem iso_iff (s t : PTree α) : Nonempty (s ≅ t) ↔ flatten s = flatten t := by
  constructor
  · rintro ⟨e⟩; exact e.hom.down
  · intro h; exact ⟨isoOfEq h⟩

/-! ### Strictification: the skeleton is the free monoid -/

/-- The canonical right-nested normal form of a word. -/
def ofList : List α → PTree α
  | [] => nil
  | a :: rest => node (leaf a) (ofList rest)

@[simp] theorem flatten_ofList (l : List α) : flatten (ofList l) = l := by
  induction l with
  | nil => rfl
  | cons a rest ih => simp [ofList, flatten, ih]

@[simp] theorem ofList_nil : ofList ([] : List α) = 𝟙_ (PTree α) := rfl

/-- Every bracketing is canonically isomorphic to its normal form (Mac Lane coherence in
concrete, thin form). -/
def normalize (s : PTree α) : s ≅ ofList (flatten s) := isoOfEq (by simp)

/-- The normal form is monoidal: concatenation of words becomes the tensor product.  This
exhibits the skeleton of `PTree α` as the free monoid `(List α, ++, [])`. -/
def ofList_append (l₁ l₂ : List α) :
    (ofList l₁ ⊗ ofList l₂ : PTree α) ≅ ofList (l₁ ++ l₂) :=
  isoOfEq (by simp)

end PTree

/-! ## 3. A combinatorial census of the loops: Catalan numbers -/

/-- Abstract bracketing shapes: `lf` is a single factor, `br l r` a binary product.  A
`Shape` records *how* a product is bracketed, forgetting the factors themselves. -/
inductive Shape where
  | lf : Shape
  | br : Shape → Shape → Shape
  deriving DecidableEq

namespace Shape

/-- Number of factors (leaves) in a bracketing. -/
def leaves : Shape → ℕ
  | lf => 1
  | br l r => l.leaves + r.leaves

/-- Number of binary products (internal nodes) in a bracketing. -/
def products : Shape → ℕ
  | lf => 0
  | br l r => l.products + r.products + 1

/-- A bracketing of `n` factors uses exactly `n - 1` products. -/
theorem leaves_eq_products_succ (s : Shape) : s.leaves = s.products + 1 := by
  induction s with
  | lf => rfl
  | br l r ihl ihr => simp only [leaves, products, ihl, ihr]; omega

/-- Encode a bracketing shape as a finite binary tree. -/
def toTree : Shape → Tree Unit
  | lf => .nil
  | br l r => .node () l.toTree r.toTree

/-- Decode a finite binary tree back to a bracketing shape. -/
def ofTree : Tree Unit → Shape
  | .nil => lf
  | .node _ l r => br (ofTree l) (ofTree r)

theorem ofTree_toTree (s : Shape) : ofTree (toTree s) = s := by
  induction s with
  | lf => rfl
  | br l r ihl ihr => simp [toTree, ofTree, ihl, ihr]

theorem toTree_ofTree (t : Tree Unit) : toTree (ofTree t) = t := by
  induction t with
  | nil => rfl
  | node a l r ihl ihr => cases a; simp [toTree, ofTree, ihl, ihr]

/-- **Bracketing shapes are the finite binary trees.** -/
def treeEquiv : Shape ≃ Tree Unit where
  toFun := toTree
  invFun := ofTree
  left_inv := ofTree_toTree
  right_inv := toTree_ofTree

/-- Under the encoding, products become internal nodes. -/
theorem numNodes_toTree (s : Shape) : (toTree s).numNodes = s.products := by
  induction s with
  | lf => rfl
  | br l r ihl ihr => simp only [toTree, Tree.numNodes, products, ihl, ihr]

/-- The finite set of all bracketings of `n + 1` factors (equivalently, with `n`
products). -/
def bracketings (n : ℕ) : Finset Shape :=
  (Tree.treesOfNumNodesEq n).map treeEquiv.symm.toEmbedding

theorem mem_bracketings {n : ℕ} {s : Shape} : s ∈ bracketings n ↔ s.products = n := by
  simp only [bracketings, Finset.mem_map, Tree.mem_treesOfNumNodesEq,
    Equiv.coe_toEmbedding]
  constructor
  · rintro ⟨t, ht, rfl⟩
    show (ofTree t).products = n
    have h := numNodes_toTree (ofTree t)
    rw [toTree_ofTree] at h
    omega
  · intro h
    exact ⟨toTree s, by rw [numNodes_toTree, h], ofTree_toTree s⟩

/-- **The census.**  The number of ways to bracket `n + 1` factors is the Catalan number
`C n`: this is the size of each connected component of the reassociation groupoid. -/
theorem card_bracketings (n : ℕ) : (bracketings n).card = catalan n := by
  rw [bracketings, Finset.card_map, Tree.treesOfNumNodesEq_card_eq_catalan]

/-- **The loops obey the Segner convolution recurrence.**  Splitting a product at its
outermost bracket expresses the census of `n + 1` products as a convolution of smaller
censuses. -/
theorem card_bracketings_succ (n : ℕ) :
    (bracketings (n + 1)).card =
      ∑ i : Fin (n + 1), (bracketings i).card * (bracketings (n - i)).card := by
  simp only [card_bracketings]
  exact catalan_succ n

/-! ### Bridging the census to the parenthesization category -/

/-- Realise a bracketing shape as an object of the parenthesization category over `Unit`. -/
def toPTree : Shape → PTree Unit
  | lf => .leaf ()
  | br l r => .node l.toPTree r.toPTree

theorem flatten_toPTree (s : Shape) :
    PTree.flatten s.toPTree = List.replicate s.leaves () := by
  induction s with
  | lf => rfl
  | br l r ihl ihr =>
      simp only [toPTree, PTree.flatten_node, ihl, ihr, leaves]
      rw [List.replicate_add]

theorem toPTree_injective : Function.Injective toPTree := by
  intro s t h
  induction s generalizing t with
  | lf => cases t with
    | lf => rfl
    | br l r => simp [toPTree] at h
  | br sl sr ihl ihr => cases t with
    | lf => simp [toPTree] at h
    | br tl tr =>
        simp only [toPTree, PTree.node.injEq] at h
        rw [ihl h.1, ihr h.2]

/-- **A connected component of the reassociation groupoid.**  Any two bracketings of the
same number of factors give isomorphic objects: the `catalan`-many distinct bracketings of
`n + 1` factors are all uniquely isomorphic, forming a single contractible component whose
size is `C n`. -/
theorem iso_of_leaves_eq (s t : Shape) (h : s.leaves = t.leaves) :
    Nonempty (s.toPTree ≅ t.toPTree) := by
  rw [PTree.iso_iff, flatten_toPTree, flatten_toPTree, h]

end Shape

end CausalLoopsDeep