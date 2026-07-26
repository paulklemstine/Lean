import Mathlib

/-!
# Causal loops in category theory: strictification of the reassociation groupoid

This file *deepens* the study of "causal loops" — structures where composition (or a
tensor product) fails to be associative on the nose but is repaired by a canonical
invertible `2`-cell.

The prior development realised the almost-category concretely as the **parenthesization
category** `PTree α`: objects are binary trees (bracketings) over `α`, and a morphism
`s ⟶ t` is a proof that `s` and `t` flatten to the same underlying word.  Associativity
fails on objects, `(a ⊗ b) ⊗ c ≠ a ⊗ (b ⊗ c)`, yet every bracketing of a fixed word is
*uniquely* isomorphic to every other one.

The main new result here is a genuine **strictification theorem**, phrased as an
equivalence of categories:

* `strictify : PTree α ≌ Discrete (List α)`

i.e. the reassociation groupoid `PTree α` is categorically equivalent to the *discrete*
category on words.  This is the precise sense in which "when composition loops back, its
skeleton is the free monoid `(List α, ++, [])`": all the invertible `2`-cells recording how
associativity loops back are collapsed, and what remains is exactly the underlying word.

We prove:

* `PTree.isoOfEq`, `PTree.iso_iff` — two bracketings are isomorphic iff they share a word;
* `PTree.instIsIso` — `PTree α` is a groupoid (every morphism is invertible);
* `strictify` — the strictification equivalence `PTree α ≌ Discrete (List α)`;
* `F_full`, `F_faithful`, `F_essSurj` — the flattening functor is fully faithful and
  essentially surjective, an independent proof of the equivalence;
* `strictify_functor_obj`, `flatten_tensor` — the equivalence sends the (non-strict)
  tensor `node` to concatenation of words, exhibiting the free monoid as the skeleton;

and, tying the "loops" to a classical enumeration,

* `Shape.card_bracketings` — the number of bracketings of `n + 1` factors is `catalan n`;
* `Shape.card_bracketings_succ` — the census obeys the Segner convolution recurrence;
* `Shape.iso_of_leaves_eq` — bracketings with equally many factors are isomorphic objects.

The file is self-contained: it redevelops the parenthesization category from scratch.
-/

open CategoryTheory

namespace CausalLoopsStrict

universe u

/-! ## 1. The parenthesization category -/

/-- Binary trees with leaves labelled in `α`, together with an empty tree `nil`.  A tree is
a *formal parenthesization*: `node s t` is the bracketed product `(s · t)`. -/
inductive PTree (α : Type u) where
  | nil : PTree α
  | leaf : α → PTree α
  | node : PTree α → PTree α → PTree α
  deriving DecidableEq

namespace PTree

variable {α : Type u}

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
instance instCategory (α : Type u) : Category (PTree α) where
  Hom s t := PLift (flatten (α := α) s = flatten t)
  id _ := ⟨rfl⟩
  comp f g := ⟨f.down.trans g.down⟩

/-- Package an equality of leaf-words into a morphism. -/
def homOfEq {s t : PTree α} (h : flatten s = flatten t) : s ⟶ t := ⟨h⟩

/-- Extract the underlying equality of leaf-words from a morphism. -/
theorem eq_of_hom {s t : PTree α} (f : s ⟶ t) : flatten s = flatten t := f.down

/-- The parenthesization category is **thin**: any two parallel morphisms are equal. -/
instance instSubsingletonHom (s t : PTree α) : Subsingleton (s ⟶ t) :=
  ⟨fun f g => by obtain ⟨f⟩ := f; obtain ⟨g⟩ := g; rfl⟩

/-- Every morphism of the parenthesization category is invertible: it is a groupoid. -/
instance instIsIso {s t : PTree α} (f : s ⟶ t) : IsIso f :=
  ⟨homOfEq f.down.symm, Subsingleton.elim _ _, Subsingleton.elim _ _⟩

/-- Package an equality of leaf-words into an isomorphism of trees. -/
def isoOfEq {s t : PTree α} (h : flatten s = flatten t) : s ≅ t where
  hom := homOfEq h
  inv := homOfEq h.symm
  hom_inv_id := Subsingleton.elim _ _
  inv_hom_id := Subsingleton.elim _ _

/-- **Coherence is connectedness.**  Two bracketings are isomorphic exactly when they have
the same underlying word: the isomorphism class remembers only the word. -/
theorem iso_iff (s t : PTree α) : Nonempty (s ≅ t) ↔ flatten s = flatten t := by
  constructor
  · rintro ⟨e⟩; exact e.hom.down
  · intro h; exact ⟨isoOfEq h⟩

/-- The canonical right-nested normal form of a word. -/
def ofList : List α → PTree α
  | [] => nil
  | a :: rest => node (leaf a) (ofList rest)

@[simp] theorem flatten_ofList (l : List α) : flatten (ofList l) = l := by
  induction l with
  | nil => rfl
  | cons a rest ih => simp [ofList, flatten, ih]

/-- Every bracketing is canonically isomorphic to its normal form (concrete, thin form of
Mac Lane coherence). -/
def normalize (s : PTree α) : s ≅ ofList (flatten s) := isoOfEq (by simp)

/-- Associativity fails on the nose: the bracketings `(a ⊗ b) ⊗ c` and `a ⊗ (b ⊗ c)` are
genuinely distinct objects. -/
theorem node_assoc_ne (a b c : PTree α) :
    node (node a b) c ≠ node a (node b c) := by
  intro h
  injection h with h1 _
  have hsz : sizeOf (node a b) = sizeOf a := by rw [h1]
  simp only [PTree.node.sizeOf_spec] at hsz
  omega

end PTree

/-! ## 2. The strictification equivalence -/

variable {α : Type u}

/-- The **flattening functor** `PTree α ⥤ Discrete (List α)`: an object is sent to its
underlying word, and a morphism (a proof that two bracketings share a word) to the
corresponding identification in the discrete category. -/
def F : PTree α ⥤ Discrete (List α) where
  obj s := Discrete.mk s.flatten
  map {_ _} f := Discrete.eqToHom f.down
  map_id := by intro s; apply Subsingleton.elim
  map_comp := by intros; apply Subsingleton.elim

/-- The **normalising functor** `Discrete (List α) ⥤ PTree α`, taking a word to its
right-nested bracketing. -/
def G : Discrete (List α) ⥤ PTree α where
  obj l := PTree.ofList l.as
  map {_ _} f := PTree.homOfEq (by have := Discrete.eq_of_hom f; simp [this])
  map_id := by intro s; apply Subsingleton.elim
  map_comp := by intros; apply Subsingleton.elim

@[simp] theorem F_obj (s : PTree α) : (F.obj s).as = s.flatten := rfl
@[simp] theorem G_obj (l : Discrete (List α)) : G.obj l = PTree.ofList l.as := rfl

/-- **Strictification.**  The reassociation groupoid `PTree α` is equivalent, as a
category, to the *discrete* category on words.  Concretely: forgetting the bracketing is an
equivalence of categories whose inverse is right-nested normalisation.  This is the precise
sense in which the skeleton of the loop-tolerant tensor is the free monoid on `α`. -/
def strictify (α : Type u) : PTree α ≌ Discrete (List α) where
  functor := F
  inverse := G
  unitIso := NatIso.ofComponents
    (fun s => PTree.isoOfEq (by simp [F, G]))
    (by intros; apply Subsingleton.elim)
  counitIso := NatIso.ofComponents
    (fun l => Discrete.eqToIso (by simp [F, G]))
    (by intros; apply Subsingleton.elim)
  functor_unitIso_comp := by intros; apply Subsingleton.elim

@[simp] theorem strictify_functor : (strictify α).functor = F := rfl
@[simp] theorem strictify_inverse : (strictify α).inverse = G := rfl

/-- Under the strictification, an object of `PTree α` is sent to its underlying word. -/
theorem strictify_functor_obj (s : PTree α) :
    ((strictify α).functor.obj s).as = s.flatten := rfl

/-! ### The flattening functor is fully faithful and essentially surjective -/

/-- The flattening functor is **faithful** (automatic, since `PTree α` is thin). -/
instance F_faithful : F.Faithful (C := PTree α) where
  map_injective := fun _ => Subsingleton.elim _ _

/-- The flattening functor is **full**: any identification of the underlying words of two
bracketings comes from a (unique) morphism of bracketings. -/
instance F_full : F.Full (C := PTree α) where
  map_surjective {_ _} f := ⟨PTree.homOfEq (Discrete.eq_of_hom f), Subsingleton.elim _ _⟩

/-- The flattening functor is **essentially surjective**: every word is the flattening of a
bracketing (its right-nested normal form). -/
instance F_essSurj : F.EssSurj (C := PTree α) where
  mem_essImage l := ⟨PTree.ofList l.as, ⟨Discrete.eqToIso (by simp [F])⟩⟩

/-- The flattening functor is an equivalence — an independent proof of `strictify` via the
fully-faithful/essentially-surjective criterion. -/
instance F_isEquivalence : F.IsEquivalence (C := PTree α) :=
  Functor.IsEquivalence.mk

/-! ### The equivalence exhibits the free monoid as the skeleton -/

/-- The flattening functor sends the (non-strict) tensor `node` to concatenation of words:
`flatten (s ⊗ t) = flatten s ++ flatten t`.  Thus the strictification identifies the tensor
product with the free-monoid multiplication. -/
theorem flatten_tensor (s t : PTree α) :
    (F.obj (PTree.node s t)).as = (F.obj s).as ++ (F.obj t).as := rfl

/-- Normalisation is monoidal on the skeleton: the right-nested bracketing of a
concatenation is isomorphic to the tensor of the two right-nested bracketings.  This is the
free-monoid multiplication realised inside `PTree α`. -/
def ofList_append (l₁ l₂ : List α) :
    PTree.node (PTree.ofList l₁) (PTree.ofList l₂) ≅ PTree.ofList (l₁ ++ l₂) :=
  PTree.isoOfEq (by simp)

/-! ## 3. A combinatorial census of the loops: Catalan numbers -/

/-- Abstract bracketing shapes: `lf` is a single factor, `br l r` a binary product.  A
`Shape` records *how* a product is bracketed, forgetting the factors. -/
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
`C n`: the size of each connected component of the reassociation groupoid. -/
theorem card_bracketings (n : ℕ) : (bracketings n).card = catalan n := by
  rw [bracketings, Finset.card_map, Tree.treesOfNumNodesEq_card_eq_catalan]

/-- **The loops obey the Segner convolution recurrence.** -/
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

/-- **A connected component of the reassociation groupoid.**  Any two bracketings of the
same number of factors give isomorphic objects: the `catalan`-many distinct bracketings of
`n + 1` factors form a single component whose size is `C n`. -/
theorem iso_of_leaves_eq (s t : Shape) (h : s.leaves = t.leaves) :
    Nonempty (s.toPTree ≅ t.toPTree) := by
  rw [PTree.iso_iff, flatten_toPTree, flatten_toPTree, h]

end Shape

end CausalLoopsStrict