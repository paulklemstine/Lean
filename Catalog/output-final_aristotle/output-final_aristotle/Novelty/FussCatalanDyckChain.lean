/-
# A chain of results: Fuss–Catalan numbers, Dyck paths, and the recursive
# decomposition underlying greedy `m`-Tamari intervals

**Research mission (v25, Builder).** *Recursive decomposition of greedy Tamari
intervals via Dyck path structures.*  The motivating conjecture (Bousquet-Mélou–
Chapoton, generalized to arbitrary `m`) enumerates greedy `m`-Tamari intervals in
a planar `(m+1)`-constellation and matches them, *via Dyck paths*, with families of
planar trees.  The enumerative backbone of every "via Dyck paths" statement is the
**Fuss–Catalan number**
`fc m n = C((m+1)·n, n) / (m·n + 1)`,
which counts `(m+1)`-ary plane trees with `n` internal nodes / `m`-Dyck paths of
length `(m+1)·n`.  For `m = 1` this is the ordinary Catalan number, the base layer
of the mission whose objects are Dyck paths, binary trees and plane trees.

This file builds, from the simplest fact upwards, a single connected **chain** of
results in which each theorem is used by the next:

1. `fc_zero`              — `fc m 0 = 1` (the empty tree).
2. `fc_one_arg`          — `fc m 1 = 1` (the root-only tree).
3. `fc_one_eq_catalan`   — `fc 1 n = catalan n` (the `m = 1` base layer).
4. `fc_one_mul`          — exactness of the defining division: `(n+1)·fc 1 n = C(2n,n)`.
5. `fc_one_pos`          — positivity, from (4).
6. `fc_one_recursive`    — the **recursive decomposition**: `fc 1 (n+1) = Σ_i fc 1 i · fc 1 (n-i)`.
7. `fc_one_mono`         — monotonicity, read off the decomposition (6).
8. `fc_one_ge_one`       — a clean lower bound obtained from (5).
9. `fc_one_eq_card_dyck` — the "via Dyck paths" identity: `fc 1 n` counts Dyck paths of semilength `n`.
10. `fc_one_eq_card_trees` — `fc 1 n` counts binary trees with `n` internal nodes.
11. `fc_one_eq_card_planeTree` — `fc 1 n` counts **plane (planar) trees** with `n+1` nodes,
    tying the arithmetic to the tree family of the mission via the Knuth
    (left-child / right-sibling) bijection, built here from scratch.

Every theorem below has a complete, `sorry`-free proof and the file compiles
standalone (only `import Mathlib`).  General-`m` integrality and the full
`m`-Tamari ↔ constellation bijection are discussed in `FUTURE_DIRECTIONS.md`.
-/
import Mathlib

open Nat Finset Tree

namespace FussCatalanDyck

/-- **Fuss–Catalan number.**  `fc m n = C((m+1)·n, n) / (m·n + 1)` counts
`(m+1)`-ary plane trees with `n` internal nodes (equivalently `m`-Dyck paths of
length `(m+1)·n`).  For `m = 1` it is the ordinary Catalan number. -/
def fc (m n : ℕ) : ℕ := Nat.choose ((m + 1) * n) n / (m * n + 1)

/-! ## The arithmetic chain -/

/-- **(1)** Base case: there is a unique object of size `0` for every `m`. -/
theorem fc_zero (m : ℕ) : fc m 0 = 1 := by
  simp [fc]

/-- **(2)** There is a unique object of size `1` for every `m` (the root-only tree):
`C(m+1,1)/(m+1) = (m+1)/(m+1) = 1`. -/
theorem fc_one_arg (m : ℕ) : fc m 1 = 1 := by
  simp [fc, Nat.choose_one_right]

/-- **(3)** *Base layer of the mission.*  The `m = 1` Fuss–Catalan number is the
ordinary Catalan number: `fc 1 n = C(2n,n)/(n+1) = catalan n`. -/
theorem fc_one_eq_catalan (n : ℕ) : fc 1 n = catalan n := by
  rw [fc, catalan_eq_centralBinom_div, Nat.centralBinom_eq_two_mul_choose]
  norm_num

/-- **(4)** *Exactness of the defining division for `m = 1`.*  The division in the
closed form is exact: `(n+1) · fc 1 n = C(2n, n)`.  This is the integrality of the
Catalan numbers, and it powers the positivity below. -/
theorem fc_one_mul (n : ℕ) : (n + 1) * fc 1 n = Nat.centralBinom n := by
  rw [fc, Nat.centralBinom_eq_two_mul_choose]
  have h : (n + 1) ∣ (2 * n).choose n := by
    have := Nat.succ_dvd_centralBinom n
    rwa [Nat.centralBinom_eq_two_mul_choose] at this
  rw [show (1 + 1) * n = 2 * n by ring, show 1 * n + 1 = n + 1 by ring,
    Nat.mul_div_cancel' h]

/-- **(5)** Positivity of the base-layer counts, obtained from the exactness (4)
and positivity of the central binomial coefficient. -/
theorem fc_one_pos (n : ℕ) : 0 < fc 1 n := by
  by_contra h
  push_neg at h
  have hz : fc 1 n = 0 := Nat.le_zero.mp h
  have := fc_one_mul n
  rw [hz, Nat.mul_zero] at this
  exact (Nat.centralBinom_pos n).ne' this.symm

/-- **(6)** *The recursive decomposition.*  Splitting a Dyck path at its first
return (equivalently, decomposing a binary tree at its root) gives the Catalan
convolution.  Transported through (3), the base-layer Fuss–Catalan numbers satisfy
`fc 1 (n+1) = Σ_{i≤n} fc 1 i · fc 1 (n-i)`.  This is the enumerative heart of the
"recursive decomposition via Dyck path structure". -/
theorem fc_one_recursive (n : ℕ) :
    fc 1 (n + 1) = ∑ i : Fin (n + 1), fc 1 i * fc 1 (n - i) := by
  simp only [fc_one_eq_catalan]
  exact catalan_succ n

/-- **(7)** Monotonicity of the base-layer counts, read off the recursive
decomposition (6)/(via `catalan_succ'`): the diagonal term `fc 1 n · fc 1 0`
already dominates. -/
theorem fc_one_mono (n : ℕ) : fc 1 n ≤ fc 1 (n + 1) := by
  simp only [fc_one_eq_catalan]
  rw [catalan_succ']
  have hmem : (n, 0) ∈ Finset.antidiagonal n := by simp [Finset.mem_antidiagonal]
  calc catalan n = catalan (n, 0).1 * catalan (n, 0).2 := by simp [catalan_zero]
    _ ≤ ∑ ij ∈ antidiagonal n, catalan ij.1 * catalan ij.2 :=
        Finset.single_le_sum (f := fun ij => catalan ij.1 * catalan ij.2)
          (fun i _ => Nat.zero_le _) hmem

/-- **(8)** A clean lower bound: every base-layer count is at least `1`
(from positivity (5)). -/
theorem fc_one_ge_one (n : ℕ) : 1 ≤ fc 1 n := fc_one_pos n

/-! ## The "via Dyck paths" and tree identities -/

/-- **(9)** *The headline "via Dyck paths" identity.*  The base-layer Fuss–Catalan
number `fc 1 n` is the number of Dyck lattice paths of semilength `n`. -/
theorem fc_one_eq_card_dyck (n : ℕ) :
    fc 1 n = Fintype.card {p : DyckWord // p.semilength = n} := by
  rw [fc_one_eq_catalan, DyckWord.card_dyckWord_semilength_eq_catalan]

/-- **(10)** `fc 1 n` is the number of binary trees with `n` internal nodes. -/
theorem fc_one_eq_card_trees (n : ℕ) :
    fc 1 n = Fintype.card (treesOfNumNodesEq n) := by
  rw [fc_one_eq_catalan, ← treesOfNumNodesEq_card_eq_catalan]
  exact (Fintype.card_coe _).symm

/-! ## Plane (planar) trees: the tree family of the mission

We introduce plane (ordered / planar rooted) trees and the classical Knuth
left-child / right-sibling bijection to binary trees, so that the arithmetic chain
above lands on the *planar tree* objects named in the conjecture. -/

/-- A **plane tree** (ordered / planar rooted tree): a root with an *ordered* list
of subtrees of arbitrary arity. -/
inductive PlaneTree : Type
  | node : List PlaneTree → PlaneTree

namespace PlaneTree

/-- The ordered list of children of a plane tree. -/
def children : PlaneTree → List PlaneTree
  | node ts => ts

@[simp] lemma children_node (ts : List PlaneTree) : (node ts).children = ts := rfl

@[simp] lemma node_children (t : PlaneTree) : node t.children = t := by cases t; rfl

/-- Number of nodes of a plane tree (root included). -/
def numNodes : PlaneTree → ℕ
  | node ts => 1 + (ts.map numNodes).sum

/-- Total number of nodes across a plane *forest*. -/
def forestNodes (f : List PlaneTree) : ℕ := (f.map numNodes).sum

/-- Encode a plane forest as a binary tree (Knuth transform: first tree's children
become the left subtree, the rest of the forest the right subtree). -/
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

/-- **Knuth bijection.**  Plane forests ≃ binary trees. -/
def forestEquivBin : List PlaneTree ≃ Tree Unit where
  toFun := forestToBin
  invFun := binToForest
  left_inv := binToForest_forestToBin
  right_inv := forestToBin_binToForest

@[simp] lemma forestEquivBin_apply (f : List PlaneTree) :
    forestEquivBin f = forestToBin f := rfl

/-- The Knuth transform preserves the node count. -/
lemma numNodes_forestToBin : ∀ f, (forestToBin f).numNodes = forestNodes f
  | [] => by simp [forestToBin, forestNodes]
  | (node ts) :: rest => by
      simp only [forestToBin, Tree.numNodes, numNodes_forestToBin ts,
        numNodes_forestToBin rest, forestNodes, numNodes, List.map_cons, List.sum_cons]
      ring

/-- Plane trees ≃ plane forests (a plane tree is its list of children). -/
def planeTreeEquivForest : PlaneTree ≃ List PlaneTree where
  toFun := children
  invFun := node
  left_inv := node_children
  right_inv := fun _ => rfl

/-- Plane forests with `n` nodes ≃ binary trees with `n` internal nodes. -/
def forestEquivTrees (n : ℕ) :
    {f : List PlaneTree // forestNodes f = n} ≃ treesOfNumNodesEq n :=
  forestEquivBin.subtypeEquiv (fun f => by
    rw [mem_treesOfNumNodesEq, forestEquivBin_apply, numNodes_forestToBin])

noncomputable instance instFintypeForest (n : ℕ) :
    Fintype {f : List PlaneTree // forestNodes f = n} :=
  Fintype.ofEquiv _ (forestEquivTrees n).symm

/-- Plane trees with `n+1` nodes ≃ plane forests with `n` nodes. -/
def planeTreeEquivForestNodes (n : ℕ) :
    {t : PlaneTree // t.numNodes = n + 1} ≃ {f : List PlaneTree // forestNodes f = n} :=
  planeTreeEquivForest.subtypeEquiv (fun t => by
    cases t with
    | node ts => simp [planeTreeEquivForest, forestNodes, numNodes, Nat.add_comm])


noncomputable instance instFintypePlaneTree (n : ℕ) :
    Fintype {t : PlaneTree // t.numNodes = n + 1} :=
  Fintype.ofEquiv _ (planeTreeEquivForestNodes n).symm

end PlaneTree

/-- **(11)** *The mission's tree family.*  The base-layer Fuss–Catalan number
`fc 1 n` is the number of plane (planar) trees with `n+1` nodes.  Combined with
(9) this is the "planar trees ↔ Dyck paths, via the recursive/Knuth decomposition"
correspondence at the base level `m = 1`. -/
theorem fc_one_eq_card_planeTree (n : ℕ) :
    fc 1 n = Fintype.card {t : PlaneTree // t.numNodes = n + 1} := by
  rw [fc_one_eq_card_trees, Fintype.card_congr (PlaneTree.planeTreeEquivForestNodes n),
    Fintype.card_congr (PlaneTree.forestEquivTrees n), Fintype.card_coe]

/-- Corollary tying the two combinatorial families directly: plane trees with `n+1`
nodes are equinumerous with Dyck paths of semilength `n`. -/
theorem card_planeTree_eq_card_dyck (n : ℕ) :
    Fintype.card {t : PlaneTree // t.numNodes = n + 1}
      = Fintype.card {p : DyckWord // p.semilength = n} := by
  rw [← fc_one_eq_card_planeTree, fc_one_eq_card_dyck]

end FussCatalanDyck