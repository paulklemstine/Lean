/-
  Domain Separation by Tagging Defeats Cross-Shape Merkle Collisions

  This module closes the gap exposed by `tree_cross_shape_collision_exists` in
  `Cryptography.MerkleTreeHash`. That counterexample shows that without domain
  separation, injective `g` and `h` still admit collisions between trees of
  *different shapes* (a leaf can equal an internal node). The fix theorem
  `treeHash_inj_domainSeparated` assumes leaf-hashes never equal node-hashes
  (`hsep`) as a hypothesis.

  Here we show that hypothesis is *not* an extra assumption but a free encoding:
  a one-bit parity tag (leaves even, nodes odd) makes the ranges of the leaf map
  and the node compression disjoint, so `hsep` is *discharged automatically*.

  Main results:

  1. `taggedNode_injective` / `taggedLeaf_injective` — the tagged maps remain
     injective (parity tagging preserves the injectivity of `g` and `Nat.pair`).

  2. `taggedTreeHash_inj_crossShape` — the tagged tree hash is injective on
     *all* trees of every shape, with **no** `hsep` hypothesis: domain separation
     is realized constructively. This is the constructive converse of
     `tree_cross_shape_collision_exists`.

  3. `taggedTreeHash_no_cross_shape_collision` — concretely, the very pair of
     distinct cross-shape trees that collide for the untagged `Nat.pair` hash
     are *separated* by the tagged hash, witnessing direction (2) on the
     boundary counterexample itself.
-/

import Cryptography.MerkleTreeHash

namespace MerkleTree

open Function

variable {γ : Type*}

/-! ## Parity-tagged leaf and node maps over `ℕ` -/

/-- Tagged leaf hash: write the leaf hash into the *even* residue class. -/
def taggedLeaf (g : γ → ℕ) : γ → ℕ := fun x => 2 * g x

/-- Tagged node compression: write every node hash into the *odd* residue class,
    so node outputs can never coincide with (even) leaf outputs. -/
def taggedNode : ℕ → ℕ → ℕ := fun a b => 2 * Nat.pair a b + 1

@[simp] theorem taggedLeaf_apply (g : γ → ℕ) (x : γ) :
    taggedLeaf g x = 2 * g x := rfl

@[simp] theorem taggedNode_apply (a b : ℕ) :
    taggedNode a b = 2 * Nat.pair a b + 1 := rfl

/-! ## Tagged maps are injective -/

/-
!-- Lab Notebook: tagged injectivity -- !--
!-- Hypothesis: Multiplying by 2 (resp. 2·pair+1) preserves injectivity. -- !--
!-- Result: Proved; doubling is injective, Nat.pair is injective. -- !--
!-- Insight: The tag is an affine reparametrization, so injectivity is free. -- !--
!-- End Lab Notebook -- !--

The tagged node compression is injective as a pair function.
-/
theorem taggedNode_injective : Injective (uncurry taggedNode) := by
  intro a b h;
  simp_all +decide [ Function.uncurry, taggedNode ];
  grind

/-
The tagged leaf map is injective whenever `g` is.
-/
theorem taggedLeaf_injective {g : γ → ℕ} (hg : Injective g) :
    Injective (taggedLeaf g) := by
      exact fun x y hxy => hg <| mul_left_cancel₀ two_ne_zero hxy

/-
!-- Lab Notebook: tagged domain separation -- !--
!-- Hypothesis: Even leaf outputs and odd node outputs are always distinct. -- !--
!-- Result: Proved by parity (omega): 2k ≠ 2m+1. -- !--
!-- Insight: The abstract obstruction in tree_cross_shape_collision_exists is
range overlap between g and h; the one-bit tag forces ranges disjoint. -- !--
!-- End Lab Notebook -- !--

Parity separation: a tagged leaf hash (even) never equals a tagged node
    hash (odd), discharging the `hsep` hypothesis of
    `treeHash_inj_domainSeparated` for free.
-/
theorem taggedLeaf_ne_taggedNode {g : γ → ℕ} (x : γ) (l r : BTree γ) :
    taggedLeaf g x
      ≠ taggedNode (treeHash (taggedLeaf g) taggedNode l)
                   (treeHash (taggedLeaf g) taggedNode r) := by
                     unfold taggedLeaf taggedNode; omega;

/-! ## Cross-shape collision resistance, with no extra hypothesis -/

/-
!-- Lab Notebook: taggedTreeHash_inj_crossShape -- !--
!-- Hypothesis: Tagging realizes hsep, so the tagged tree hash is fully
(cross-shape) injective with no separation assumption. -- !--
!-- Result: Proved by feeding the three tagged lemmas to
treeHash_inj_domainSeparated. -- !--
!-- Insight: Domain separation is an encoding transformation, not a hypothesis;
this constructively closes the gap of tree_cross_shape_collision_exists. -- !--
!-- Failure analysis: A naive node tag dropping child tags is NOT injective;
keeping the full Nat.pair payload (only adding the parity bit) is required. -- !--
!-- End Lab Notebook -- !--

!-- Proof sketch: apply `treeHash_inj_domainSeparated` with `taggedLeaf_injective`,
`taggedNode_injective`, and `taggedLeaf_ne_taggedNode` (the discharged `hsep`).
This is the constructive converse of `tree_cross_shape_collision_exists`. -- !--

**Tagging gives cross-shape collision resistance for free.** For any injective
    leaf map `g : γ → ℕ`, the parity-tagged tree hash is injective on *all*
    trees, of every shape — with no domain-separation hypothesis, because the
    parity tag discharges it.
-/
theorem taggedTreeHash_inj_crossShape {g : γ → ℕ} (hg : Injective g)
    {t₁ t₂ : BTree γ}
    (heq : treeHash (taggedLeaf g) taggedNode t₁
         = treeHash (taggedLeaf g) taggedNode t₂) :
    t₁ = t₂ := by
      convert treeHash_inj_domainSeparated ( taggedLeaf_injective hg ) ( taggedNode_injective ) ( fun x l r => taggedLeaf_ne_taggedNode x l r ) heq using 1

/-
!-- Proof sketch: the two specific cross-shape trees from
`tree_cross_shape_collision_exists` are distinct, so `taggedTreeHash_inj_crossShape`
(with `g = id`) forces their tagged hashes to differ. -- !--

**The boundary counterexample is defeated.** The very pair of distinct
    different-shape trees that collide under the untagged `Nat.pair` hash
    (`tree_cross_shape_collision_exists`) have *distinct* tagged hashes. Tagging
    removes the cross-shape collision exhibited there.
-/
theorem taggedTreeHash_no_cross_shape_collision :
    treeHash (taggedLeaf (id : ℕ → ℕ)) taggedNode
        (BTree.node (BTree.leaf 0) (BTree.leaf 1))
      ≠ treeHash (taggedLeaf (id : ℕ → ℕ)) taggedNode
        (BTree.leaf (Nat.pair 0 1)) := by
          decide +revert

end MerkleTree