/-
# A cross-domain bridge: plane (ordered) trees ↔ binary trees ↔ Dyck lattice paths

**Research mission (v27, Connector).** *Recursive decomposition of greedy Tamari
intervals via Dyck path structures.* The conjecture in the mission concerns a
bijective correspondence — established *via Dyck paths* — between families of
**planar trees** and objects counted through the Tamari lattice, generalizing the
planarity-based enumeration of Bousquet-Mélou–Chapoton to arbitrary `m`.

The combinatorial backbone that makes every such "via Dyck paths" statement
possible is a genuine cross-domain bridge:

* **Plane trees** (a.k.a. ordered / planar rooted trees): a purely
  *tree-combinatorial* object where each node carries an *ordered list* of
  subtrees of arbitrary arity.
* **Binary trees** (`Mathlib`'s `Tree Unit`): a *data-structure / algebraic*
  object with exactly two children per internal node.
* **Dyck words** (`Mathlib`'s `DyckWord`): a *lattice-path* object — a walk that
  stays weakly above the axis.

`Mathlib` already connects binary trees with Dyck words and with the Catalan
numbers, but it has **no notion of plane trees**.  This file introduces plane
trees and closes the triangle by proving the classical *left-child /
right-sibling* (a.k.a. Knuth rotation) correspondence entirely constructively,
as an honest `Equiv`.  Transporting `Mathlib`'s enumeration along the bridge
yields:

* `PlaneTree.card_forest_eq_catalan`   — plane forests with `n` nodes are
  counted by `catalan n`;
* `PlaneTree.card_planeTree_eq_catalan` — plane trees with `n + 1` nodes are
  counted by `catalan n`;
* `PlaneTree.card_planeTree_eq_card_dyck` — the headline *cross-domain*
  statement: plane trees with `n + 1` nodes are equinumerous with Dyck paths of
  semilength `n`, realized by the explicit bijection `planeTreeEquivDyck`.

The last statement is exactly the `m = 1` layer of the mission's "planar trees
↔ Tamari objects, via Dyck paths" programme, phrased and *proved* at the level
of ordered trees.  See `FUTURE_DIRECTIONS.md` for the route to arbitrary `m`.

Every proof below is complete and `sorry`-free; the file compiles standalone.
-/
import Mathlib

open Tree

namespace GreedyTamariBridge

/-- A **plane tree** (ordered / planar rooted tree): a root together with an
*ordered* list of its subtrees.  Arity is arbitrary, so this genuinely
generalizes binary trees. -/
inductive PlaneTree : Type
  | node : List PlaneTree → PlaneTree

namespace PlaneTree

/-- The ordered list of children (subtrees) of a plane tree. -/
def children : PlaneTree → List PlaneTree
  | node ts => ts

@[simp] lemma children_node (ts : List PlaneTree) : (node ts).children = ts := rfl

@[simp] lemma node_children (t : PlaneTree) : node t.children = t := by cases t; rfl

/-- Number of nodes of a plane tree (root included). -/
def numNodes : PlaneTree → ℕ
  | node ts => 1 + (ts.map numNodes).sum

/-- Total number of nodes across a plane *forest* (list of plane trees). -/
def forestNodes (f : List PlaneTree) : ℕ := (f.map numNodes).sum

@[simp] lemma numNodes_node (ts : List PlaneTree) :
    (node ts).numNodes = 1 + forestNodes ts := by
  simp only [numNodes, forestNodes]

@[simp] lemma forestNodes_nil : forestNodes [] = 0 := rfl

@[simp] lemma forestNodes_cons (t : PlaneTree) (f : List PlaneTree) :
    forestNodes (t :: f) = t.numNodes + forestNodes f := by
  simp [forestNodes]

/-!
## The left-child / right-sibling correspondence

We encode a plane forest as a binary tree: the first tree of the forest becomes
the *left* child (encoding its own children recursively), and the remaining
forest becomes the *right* child. This is the classical Knuth transform.
-/

/-- Encode a plane forest as a binary tree (left child = first tree's forest,
right child = the rest of the forest). -/
def forestToBin : List PlaneTree → Tree Unit
  | [] => Tree.nil
  | (node ts) :: rest => Tree.node () (forestToBin ts) (forestToBin rest)

/-- Decode a binary tree back into a plane forest. -/
def binToForest : Tree Unit → List PlaneTree
  | Tree.nil => []
  | Tree.node _ l r => node (binToForest l) :: binToForest r

lemma binToForest_forestToBin : ∀ f, binToForest (forestToBin f) = f
  | [] => by simp [forestToBin, binToForest]
  | (node ts) :: rest => by
      simp [forestToBin, binToForest, binToForest_forestToBin ts,
        binToForest_forestToBin rest]

lemma forestToBin_binToForest : ∀ t, forestToBin (binToForest t) = t
  | Tree.nil => by simp [forestToBin, binToForest]
  | Tree.node _ l r => by
      simp [binToForest, forestToBin, forestToBin_binToForest l,
        forestToBin_binToForest r]

/-- **Bridge 1.** Plane forests are in explicit bijection with binary trees. -/
def forestEquivBin : List PlaneTree ≃ Tree Unit where
  toFun := forestToBin
  invFun := binToForest
  left_inv := binToForest_forestToBin
  right_inv := forestToBin_binToForest

@[simp] lemma forestEquivBin_apply (f : List PlaneTree) :
    forestEquivBin f = forestToBin f := rfl

/-- The Knuth transform preserves the node count: a forest with `n` nodes maps to
a binary tree with `n` internal nodes. -/
lemma numNodes_forestToBin : ∀ f, (forestToBin f).numNodes = forestNodes f
  | [] => by simp [forestToBin, forestNodes]
  | (node ts) :: rest => by
      simp only [forestToBin, Tree.numNodes, numNodes_forestToBin ts,
        numNodes_forestToBin rest, forestNodes, numNodes, List.map_cons, List.sum_cons]
      ring

/-- Plane trees are in bijection with plane forests (a plane tree *is* its list of
children under one constructor). -/
def planeTreeEquivForest : PlaneTree ≃ List PlaneTree where
  toFun := children
  invFun := node
  left_inv := node_children
  right_inv := fun _ => rfl

/-- **Global bijection.** Every plane tree corresponds to a binary tree. -/
def planeTreeEquivBin : PlaneTree ≃ Tree Unit :=
  planeTreeEquivForest.trans forestEquivBin

/-!
## Transporting the enumeration

`Mathlib` provides `Tree.treesOfNumNodesEq` (binary trees with a fixed number of
internal nodes) together with `treesOfNumNodesEq_card_eq_catalan`.  We restrict
the bijection to fixed node counts and transport the count.
-/

/-- Plane forests with `n` nodes ≃ binary trees with `n` internal nodes. -/
def forestEquivTrees (n : ℕ) :
    { f : List PlaneTree // forestNodes f = n } ≃ treesOfNumNodesEq n :=
  forestEquivBin.subtypeEquiv (fun f => by
    rw [mem_treesOfNumNodesEq, forestEquivBin_apply, numNodes_forestToBin])

noncomputable instance instFintypeForest (n : ℕ) :
    Fintype { f : List PlaneTree // forestNodes f = n } :=
  Fintype.ofEquiv _ (forestEquivTrees n).symm

/-- Plane forests with `n` total nodes are counted by `catalan n`. -/
theorem card_forest_eq_catalan (n : ℕ) :
    Fintype.card { f : List PlaneTree // forestNodes f = n } = catalan n := by
  rw [Fintype.card_congr (forestEquivTrees n), ← treesOfNumNodesEq_card_eq_catalan]
  exact Fintype.card_coe _

/-- Plane trees with `n + 1` nodes ≃ plane forests with `n` nodes. -/
def planeTreeEquivForestNodes (n : ℕ) :
    { t : PlaneTree // t.numNodes = n + 1 } ≃ { f : List PlaneTree // forestNodes f = n } :=
  planeTreeEquivForest.subtypeEquiv (fun t => by
    cases t with
    | node ts => simp [planeTreeEquivForest, forestNodes, Nat.add_comm])

noncomputable instance instFintypePlaneTree (n : ℕ) :
    Fintype { t : PlaneTree // t.numNodes = n + 1 } :=
  Fintype.ofEquiv _ (planeTreeEquivForestNodes n).symm

/-- **Plane trees with `n + 1` nodes are counted by `catalan n`.** -/
theorem card_planeTree_eq_catalan (n : ℕ) :
    Fintype.card { t : PlaneTree // t.numNodes = n + 1 } = catalan n := by
  rw [Fintype.card_congr (planeTreeEquivForestNodes n), card_forest_eq_catalan]

/-!
## The headline cross-domain bridge: plane trees ↔ Dyck paths
-/

/-- Plane forests with `n` nodes ≃ Dyck lattice paths of semilength `n`. -/
def forestEquivDyck (n : ℕ) :
    { f : List PlaneTree // forestNodes f = n } ≃ { p : DyckWord // p.semilength = n } :=
  (forestEquivTrees n).trans (DyckWord.equivTreesOfNumNodesEq n).symm

/-- **Explicit bijection between planar trees and Dyck paths.**
Plane trees with `n + 1` nodes are in explicit bijection with Dyck lattice paths
of semilength `n` — the "via Dyck paths" correspondence at the base level. -/
def planeTreeEquivDyck (n : ℕ) :
    { t : PlaneTree // t.numNodes = n + 1 } ≃ { p : DyckWord // p.semilength = n } :=
  (planeTreeEquivForestNodes n).trans (forestEquivDyck n)

/-- **Cross-domain enumeration bridge.** The number of planar trees with `n + 1`
nodes equals the number of Dyck lattice paths of semilength `n`. This ties a
tree-combinatorial family to a lattice-path family; both equal `catalan n`. -/
theorem card_planeTree_eq_card_dyck (n : ℕ) :
    Fintype.card { t : PlaneTree // t.numNodes = n + 1 }
      = Fintype.card { p : DyckWord // p.semilength = n } := by
  rw [card_planeTree_eq_catalan, DyckWord.card_dyckWord_semilength_eq_catalan]

/-- Plane forests with `n` nodes are equinumerous with Dyck paths of semilength `n`. -/
theorem card_forest_eq_card_dyck (n : ℕ) :
    Fintype.card { f : List PlaneTree // forestNodes f = n }
      = Fintype.card { p : DyckWord // p.semilength = n } := by
  rw [card_forest_eq_catalan, DyckWord.card_dyckWord_semilength_eq_catalan]

end PlaneTree

end GreedyTamariBridge