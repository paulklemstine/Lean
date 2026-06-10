/-
  Merkle Tree Hashing: Collision Resistance of Binary Hash Trees

  This module extends the Merkle–Damgård theory of `Cryptography.MerkleDamgard`
  (definitions `CryptoHash.merkleDamgard`, theorems `foldl_joint_injective`,
  `compress_injective_md_injective`, `md_collision_implies_compress_collision`)
  from a *linear* chain of compressions to a *binary tree* of compressions —
  the structure underlying Merkle (hash) trees, used in Git, Bitcoin, certificate
  transparency, and authenticated data structures.

  Main results:

  1. `treeHash_inj_sameShape` — if the leaf map `g` and the two-to-one compression
     `h : α → α → α` are injective, the tree hash is injective on trees of the
     same shape. (The tree analogue of `compress_injective_md_injective`, whose
     "same length" hypothesis becomes "same shape".)

  2. `tree_collision_implies_compression_collision` — the security reduction:
     a collision between two distinct same-shape trees yields an explicit
     collision in the leaf map `g` OR in the compression `h`. (The tree analogue
     of `md_collision_implies_compress_collision`.)

  3. `treeHash_inj_domainSeparated` — *full* injectivity across all shapes once
     leaf-hashes and node-hashes are domain-separated. This is the standard fix
     for the Merkle second-preimage / multi-collision weakness.

  4. `treeHash_leftComb_eq_merkleDamgard` — the **bridge** theorem: the left-comb
     ("caterpillar") tree hash is exactly the Merkle–Damgård fold, exhibiting
     Merkle–Damgård as the degenerate linear case of Merkle-tree hashing.

  5. `tree_cross_shape_collision_exists` — a boundary counterexample showing that
     without domain separation, distinct trees of *different* shapes collide even
     for injective `g` and `h`, so hypotheses (1)-(2) genuinely require same shape.
-/

import Mathlib

namespace MerkleTree

/-- Local copy of the Merkle–Damgård hash of `Cryptography.MerkleDamgard`
    (`CryptoHash.merkleDamgard f iv msg = msg.foldl f iv`), reproduced here so
    that this file is self-contained; the bridge theorem
    `treeHash_leftComb_eq_merkleDamgard` below relates the Merkle-tree hash to it. -/
def merkleDamgard {α β : Type*} (f : α → β → α) (iv : α) (msg : List β) : α :=
  msg.foldl f iv

variable {α : Type*} {γ : Type*}

/-! ## Binary Merkle trees and their hash -/

/-- A binary tree with leaves labelled by `γ`. -/
inductive BTree (γ : Type*) where
  | leaf : γ → BTree γ
  | node : BTree γ → BTree γ → BTree γ

/-- The Merkle tree hash: leaves are mapped by `g : γ → α`, internal nodes
    combine their two children with the compression `h : α → α → α`. -/
def treeHash (g : γ → α) (h : α → α → α) : BTree γ → α
  | .leaf x => g x
  | .node l r => h (treeHash g h l) (treeHash g h r)

@[simp] theorem treeHash_leaf (g : γ → α) (h : α → α → α) (x : γ) :
    treeHash g h (.leaf x) = g x := rfl

@[simp] theorem treeHash_node (g : γ → α) (h : α → α → α) (l r : BTree γ) :
    treeHash g h (.node l r) = h (treeHash g h l) (treeHash g h r) := rfl

/-- Two trees have the **same shape** if they agree as binary trees, ignoring
    the leaf labels. This is the tree analogue of "equal length" for messages. -/
inductive SameShape : BTree γ → BTree γ → Prop
  | leaf (a b : γ) : SameShape (.leaf a) (.leaf b)
  | node {l₁ l₂ r₁ r₂ : BTree γ} :
      SameShape l₁ l₂ → SameShape r₁ r₂ → SameShape (.node l₁ r₁) (.node l₂ r₂)

/-! ## Core injectivity (same shape) -/

/-
!-- Proof sketch: induction on the `SameShape` derivation. Leaf case is
injectivity of `g`; node case: `h` injective (as a pair function) peels
off one layer, then two IH calls give equality of both subtrees. -- !--

**Merkle tree preserves injectivity.** If the leaf map `g` and the
    compression `h` (viewed as `α × α → α`) are injective, then `treeHash` is
    injective on trees of the same shape. Tree analogue of
    `CryptoHash.compress_injective_md_injective`.
-/
theorem treeHash_inj_sameShape {g : γ → α} {h : α → α → α}
    (hg : Function.Injective g)
    (hh : Function.Injective (Function.uncurry h))
    {t₁ t₂ : BTree γ} (hs : SameShape t₁ t₂)
    (heq : treeHash g h t₁ = treeHash g h t₂) :
    t₁ = t₂ := by
  revert hs heq;
  intros hs heq
  induction' hs with a b l₁ l₂ r₁ r₂ hs_l hs_r ih_l ih_r;
  · exact congr_arg _ ( hg heq );
  · have := @hh ( treeHash g h l₁, treeHash g h r₁ ) ( treeHash g h l₂, treeHash g h r₂ ) ; aesop;

/-
!-- Proof sketch: contrapositive of `treeHash_inj_sameShape`. If neither `g`
nor `h` had a collision they would be injective, forcing `t₁ = t₂`. -- !--

**Merkle tree collision reduction** (main security theorem). A collision
    between two distinct trees of the same shape yields an explicit collision in
    the leaf map `g` or in the compression `h`. Tree analogue of
    `CryptoHash.md_collision_implies_compress_collision`.
-/
theorem tree_collision_implies_compression_collision (g : γ → α) (h : α → α → α)
    {t₁ t₂ : BTree γ} (hs : SameShape t₁ t₂) (hne : t₁ ≠ t₂)
    (heq : treeHash g h t₁ = treeHash g h t₂) :
    (∃ x y : γ, x ≠ y ∧ g x = g y) ∨
      (∃ p q : α × α, p ≠ q ∧ Function.uncurry h p = Function.uncurry h q) := by
  contrapose! hne;
  apply treeHash_inj_sameShape;
  exacts [ fun x y hxy => Classical.not_not.1 fun h => hne.1 x y h hxy, fun p q hpq => Classical.not_not.1 fun h => hne.2 p q h hpq, hs, heq ]

/-! ## Full injectivity via domain separation -/

/-
!-- Proof sketch: structural induction on `t₁`, casing on `t₂`. The
leaf/node and node/leaf mixed cases are killed by `hsep`; leaf/leaf uses
`hg`; node/node uses `hh` then the two induction hypotheses. -- !--

**Domain-separated Merkle trees are fully collision resistant.** If, in
    addition to injectivity of `g` and `h`, every leaf-hash differs from every
    node-hash (`hsep`), then `treeHash` is injective on *all* trees, regardless of
    shape. This is the standard countermeasure to the Merkle second-preimage
    weakness exhibited by `tree_cross_shape_collision_exists`.
-/
theorem treeHash_inj_domainSeparated {g : γ → α} {h : α → α → α}
    (hg : Function.Injective g)
    (hh : Function.Injective (Function.uncurry h))
    (hsep : ∀ (x : γ) (l r : BTree γ),
      g x ≠ h (treeHash g h l) (treeHash g h r))
    {t₁ t₂ : BTree γ} (heq : treeHash g h t₁ = treeHash g h t₂) :
    t₁ = t₂ := by
  induction' t₁ with x l₁ r₁ ih₁ l₂ r₂ ih₂ generalizing t₂;
  · cases t₂ <;> tauto;
  · rcases t₂ with ( _ | ⟨ l₂, r₂ ⟩ );
    · exact False.elim ( hsep _ _ _ heq.symm );
    · have := @hh ( treeHash g h l₁, treeHash g h r₁ ) ( treeHash g h l₂, treeHash g h r₂ ) ; aesop;

/-! ## Bridge to Merkle–Damgård -/

/-- Append a list of leaves to a running tree accumulator, leaning left. -/
def leftCombAux (t : BTree α) : List α → BTree α
  | [] => t
  | b :: bs => leftCombAux (.node t (.leaf b)) bs

/-- The left-comb ("caterpillar") tree over an initial value `a` and a list of
    blocks `bs`. Its internal nodes form a left-leaning chain. -/
def leftComb (a : α) (bs : List α) : BTree α := leftCombAux (.leaf a) bs

/-
!-- Proof sketch: induction on `bs` generalizing the accumulator `t`; one
`foldl` step matches one `leftCombAux` step. -- !--

The tree hash of a left-comb accumulator unfolds to a `foldl`.
-/
theorem treeHash_leftCombAux (h : α → α → α) (t : BTree α) (bs : List α) :
    treeHash id h (leftCombAux t bs) = bs.foldl h (treeHash id h t) := by
  induction' bs with b bs ih generalizing t <;> simp_all +decide [ leftCombAux ]

/-
!-- Proof sketch: specialize `treeHash_leftCombAux` to `t = leaf a` and note
`merkleDamgard h a bs = bs.foldl h a` definitionally. -- !--

**Bridge theorem.** With `g = id`, the left-comb tree hash is *exactly* the
    Merkle–Damgård hash of `Cryptography.MerkleDamgard`. Thus Merkle–Damgård is
    the degenerate linear case of Merkle-tree hashing, and its collision
    resistance (`CryptoHash.compress_injective_md_injective`) is recovered from
    `treeHash_inj_sameShape` applied to combs.
-/
theorem treeHash_leftComb_eq_merkleDamgard (h : α → α → α) (a : α) (bs : List α) :
    treeHash id h (leftComb a bs) = merkleDamgard h a bs := by
  convert treeHash_leftCombAux h (.leaf a) bs using 1

/-! ## Boundary counterexample: cross-shape collisions without separation -/

/-
!-- Proof sketch: with `g = id` and `h = Nat.pair`, the tree `node (leaf 0)
(leaf 1)` and the leaf `Nat.pair 0 1` both hash to `Nat.pair 0 1`, yet
differ in shape. `Nat.pair` is injective, so `g` and `h` are injective. -- !--

**Boundary case.** Without domain separation, the same-shape hypothesis in
    `treeHash_inj_sameShape` / `tree_collision_implies_compression_collision` is
    essential: there are injective `g`, `h` and distinct trees of different shape
    with equal hash. This is the abstract form of the Merkle second-preimage
    weakness.
-/
theorem tree_cross_shape_collision_exists :
    ∃ (g : ℕ → ℕ) (h : ℕ → ℕ → ℕ) (t₁ t₂ : BTree ℕ),
      Function.Injective g ∧
      Function.Injective (Function.uncurry h) ∧
      t₁ ≠ t₂ ∧
      treeHash g h t₁ = treeHash g h t₂ := by
  fconstructor;
  exact id;
  refine' ⟨ fun a b => Nat.pair a b, BTree.node ( BTree.leaf 0 ) ( BTree.leaf 1 ), BTree.leaf ( Nat.pair 0 1 ), _, _, _, _ ⟩;
  · exact Function.injective_id;
  · intro x y; aesop;
  · grind;
  · rfl

/-! ## Worked example -/

/-- A toy injective compression on `ℕ` via `Nat.pair`, with `id` leaves. The
    Merkle tree hash is then injective on same-shape trees. -/
example {t₁ t₂ : BTree ℕ} (hs : SameShape t₁ t₂)
    (heq : treeHash id (fun a b => Nat.pair a b) t₁
         = treeHash id (fun a b => Nat.pair a b) t₂) :
    t₁ = t₂ := by
  refine treeHash_inj_sameShape Function.injective_id ?_ hs heq
  intro p q hpq
  have : Nat.pair p.1 p.2 = Nat.pair q.1 q.2 := hpq
  have h12 := (Nat.pair_eq_pair).1 this
  exact Prod.ext h12.1 h12.2

end MerkleTree