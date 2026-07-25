import Mathlib
import CausalLoops.ThinMonoidal

/-!
# A concrete non-strict monoidal category: parenthesization trees

This file constructs an explicit *almost-category* realising the mission's central
example: a tensor product whose associativity **fails on the nose** yet is repaired by a
canonical, invertible `2`-cell (the associator), all coherence holding automatically.

## The construction

`PTree α` is the type of binary trees with leaves labelled by `α` (plus an empty tree
`nil`).  Think of a tree as a *parenthesization*: `node s t` is the formal product
`(s · t)`.  Two trees with the same underlying leaf-word differ only by *how the product
is bracketed* — how "composition loops back on itself".

* The tensor product `⊗ := node` is **not associative on the nose**:
  `(a ⊗ b) ⊗ c` and `a ⊗ (b ⊗ c)` are *distinct objects*
  (`PTree.tensor_assoc_ne`).

* Yet there is a canonical **associator isomorphism** between them
  (`PTree.associator`), coming from associativity of list concatenation after
  `flatten`ing the tree to its leaf-word.

* The morphisms `s ⟶ t` are precisely proofs `flatten s = flatten t`, so the category is
  **thin**.  By `CausalLoops.monoidalOfThin`, the resulting `MonoidalCategoryStruct`
  automatically satisfies the pentagon, triangle and all naturality axioms.  Coherence is
  *free*, exactly because the reassociation groupoid is contractible.

## Main results

* `PTree.instThinCategory` — the parenthesization category is thin.
* `PTree.instMonoidalCategory` — `PTree α` is a genuine monoidal category.
* `PTree.tensor_assoc_ne` — associativity fails on the nose (distinct objects).
* `PTree.not_strict` — hence `PTree α` is a *non-strict* monoidal category.
* `PTree.instIsIso` — every morphism is invertible: `PTree α` is a groupoid.
* `PTree.associator_hom_down` / `PTree.subsingleton_iso` — the associator exists and is
  the *unique* isomorphism between its endpoints.
-/

open CategoryTheory MonoidalCategory CausalLoops

namespace CausalLoops

/-- Binary trees with leaves labelled in `α`, with an empty tree `nil`.
A tree is a *formal parenthesization*: `node s t` is the bracketed product `(s · t)`. -/
inductive PTree (α : Type*) where
  | nil : PTree α
  | leaf : α → PTree α
  | node : PTree α → PTree α → PTree α
  deriving DecidableEq

namespace PTree

variable {α : Type*}

/-- The underlying leaf-word of a tree, forgetting the bracketing.
`flatten` is the "loop back" map: it sends every parenthesization of a word to the word
itself. -/
def flatten : PTree α → List α
  | nil => []
  | leaf a => [a]
  | node l r => flatten l ++ flatten r

@[simp] theorem flatten_nil : flatten (nil : PTree α) = [] := rfl
@[simp] theorem flatten_leaf (a : α) : flatten (leaf a) = [a] := rfl
@[simp] theorem flatten_node (l r : PTree α) :
    flatten (node l r) = flatten l ++ flatten r := rfl

/-- **The parenthesization category.**  Objects are trees; a morphism `s ⟶ t` is a proof
that `s` and `t` have the same underlying leaf-word.  Composition is transitivity of
equality; the identity is reflexivity.  This is the reassociation groupoid: it connects
any two bracketings of the same word by a unique isomorphism. -/
instance instCategory (α : Type*) : Category (PTree α) where
  Hom s t := PLift (flatten (α := α) s = flatten t)
  id _ := ⟨rfl⟩
  comp f g := ⟨f.down.trans g.down⟩

/-- Package an equality of leaf-words into a morphism. -/
def homOfEq {s t : PTree α} (h : flatten s = flatten t) : s ⟶ t := ⟨h⟩

@[simp] theorem homOfEq_down {s t : PTree α} (h : flatten s = flatten t) :
    (homOfEq h).down = h := rfl

/-- The parenthesization category is **thin**: there is at most one morphism between any
two trees. -/
instance instThinCategory (α : Type*) : ThinCategory (PTree α) where
  thin f g := by obtain ⟨f⟩ := f; obtain ⟨g⟩ := g; rfl

/-- Every morphism of the parenthesization category is invertible: it is a **groupoid**.
Reassociation is always reversible. -/
instance instIsIso {s t : PTree α} (f : s ⟶ t) : IsIso f :=
  ⟨homOfEq f.down.symm, ThinCategory.thin _ _, ThinCategory.thin _ _⟩

/-- Package an equality of leaf-words into an isomorphism of trees. -/
@[simps] def isoOfEq {s t : PTree α} (h : flatten s = flatten t) : s ≅ t where
  hom := homOfEq h
  inv := homOfEq h.symm
  hom_inv_id := ThinCategory.thin _ _
  inv_hom_id := ThinCategory.thin _ _

/-- The tensor data on `PTree α`: tensor of objects is `node`, the unit is `nil`, and the
associator/unitors are read off from associativity/unitality of list concatenation. -/
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

/-- **`PTree α` is a genuine monoidal category.**  Its coherence (pentagon, triangle,
naturality) is inherited *for free* from thinness via `monoidalOfThin`: because the
reassociation groupoid is contractible, there is nothing left to check. -/
instance instMonoidalCategory (α : Type*) : MonoidalCategory (PTree α) :=
  monoidalOfThin (PTree α)

/-- The associator sends `(a ⊗ b) ⊗ c` to `a ⊗ (b ⊗ c)`, witnessed by associativity of
concatenation of leaf-words. -/
theorem associator_hom_down (a b c : PTree α) :
    (α_ a b c).hom.down =
      (by simp [List.append_assoc] :
        flatten (node (node a b) c) = flatten (node a (node b c))) :=
  rfl

/-- **Associativity fails on the nose.**  For any trees `a b c`, the two bracketings
`(a ⊗ b) ⊗ c` and `a ⊗ (b ⊗ c)` are *genuinely distinct objects* of `PTree α`, even
though they are canonically isomorphic.  This is the "controlled failure of
associativity" at the heart of the mission. -/
theorem tensor_assoc_ne (a b c : PTree α) : ((a ⊗ b) ⊗ c) ≠ (a ⊗ (b ⊗ c)) := by
  show node (node a b) c ≠ node a (node b c)
  intro h
  injection h with h1 _
  have hsz : sizeOf (node a b) = sizeOf a := by rw [h1]
  simp only [PTree.node.sizeOf_spec] at hsz
  omega

/-- **`PTree α` is not a strict monoidal category.**  There exist objects on which the
associator is not the identity morphism, because its source and target differ.  (We use
`nil` for all three factors; the underlying objects `(nil ⊗ nil) ⊗ nil` and
`nil ⊗ (nil ⊗ nil)` are distinct.) -/
theorem not_strict :
    ∃ a b c : PTree α, ((a ⊗ b) ⊗ c) ≠ (a ⊗ (b ⊗ c)) :=
  ⟨nil, nil, nil, tensor_assoc_ne nil nil nil⟩

/-- The associator is the **unique** isomorphism between its endpoints: reassociation
carries no data beyond the fact that it can be done. -/
theorem associator_unique (a b c : PTree α)
    (φ : ((a ⊗ b) ⊗ c) ≅ (a ⊗ (b ⊗ c))) : φ = α_ a b c :=
  Subsingleton.elim _ _

end PTree

end CausalLoops