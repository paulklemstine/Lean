# Future Directions: Merkle Hashing as Joint Injectivity of a Fold

## Synthesis

This cycle builds, from the ground up, the *fold* theory of Merkle-style hashing
in three new files inside the `CryptoHash` namespace:

* `Cryptography.MerkleDamgard` — the linear Merkle–Damgård chain as a left fold.
* `Cryptography.MerkleTreeHash` — binary Merkle trees as a structural fold.
* `Cryptography.MerkleAuthPath` — authentication paths as a left fold over
  `(side, sibling)` steps.

The single organizing principle is: *every Merkle-style hash is a fold, and its
collision resistance is exactly the **joint injectivity** of that fold once a
positional invariant is fixed.* "Jointly injective" (`CryptoHash.JointlyInjective`)
means the compression `h` is injective in the **pair** of its arguments:
`h a b = h c d → a = c ∧ b = d`.

Three different positional invariants make the same theorem reappear in three
guises:

1. **Equal length** (linear MD). `foldl_joint_injective` shows a left fold of a
   jointly-injective `h` is jointly injective in the seed and the equal-length
   list; reverse recursion peels the *last* compression call. From it,
   `merkleDamgard_joint_injective` and `merkleDamgard_collision_reduction` are
   immediate: with a fixed IV and equal-length blocks, the iterated hash has no
   collisions unless `h` already collides.

2. **Equal shape** (trees). `treeHash_inj_sameShape` is the structural-induction
   analogue: same-shape trees with equal hash are equal. The shape hypothesis is
   *necessary* — `tree_cross_shape_collision_exists` exhibits a concrete
   leaf/node collision under the (jointly injective) `Nat.pair`, namely
   `leaf (Nat.pair 0 0)` versus `node (leaf 0) (leaf 0)`. We then turn what a
   naive account leaves as an *assumption* (range disjointness of the leaf and
   node maps) into a *theorem*: a one-bit **parity tag** (even leaves, odd nodes)
   gives `taggedLeaf_ne_taggedNode` by parity, hence `taggedTreeHash_injective`
   — full, unconditional, cross-shape injectivity from injectivity of the leaf
   map alone — and `taggedTreeHash_no_cross_shape_collision` defeats the explicit
   counterexample on the nose.

3. **Equal position** (authentication paths). `verifyAt h v p = p.foldl (authStep h) v`,
   and `verifyAt_joint_injective` is the path-level transport of
   `foldl_joint_injective`: once the side-bit sequence (the position) is fixed,
   verification is jointly injective in the opened value and the sibling list.
   `authPath_soundness` and `authPath_collision_reduction` then fall out as
   corollaries, and `verifyAt_allLeft_eq_merkleDamgard` collapses an all-left
   path back onto the Merkle–Damgård fold (the path-level bridge). The boundary
   is sharp: `authStep` is *not* injective if the side bit may vary, because
   `h s v = h v' s'` carries no contradiction across sides — the path-level
   analogue of why "same shape" is required for trees.

## Results Summary (all proved, `sorry = 0`, only standard axioms)

* `foldl_joint_injective` — fold of a jointly-injective op is jointly injective
  in seed + equal-length list.
* `merkleDamgard_joint_injective`, `merkleDamgard_collision_reduction` — MD
  collision resistance reduces to compression collision resistance.
* `treeHash_inj_sameShape` — same-shape tree collision resistance.
* `tree_cross_shape_collision_exists` — concrete cross-shape leaf/node collision
  (the same-shape hypothesis is necessary).
* `taggedLeaf_ne_taggedNode`, `taggedTreeHash_injective`,
  `taggedTreeHash_no_cross_shape_collision` — parity tagging realizes domain
  separation "for free" and gives unconditional cross-shape injectivity.
* `authStep_joint_injective`, `verifyAt_joint_injective`, `authPath_soundness`,
  `authPath_collision_reduction`, `verifyAt_allLeft_eq_merkleDamgard` — the
  authentication-path layer and its bridge to MD.

## Research Directions

### Direction 1: Position-binding tags restore joint injectivity over *varying* positions
`verifyAt_joint_injective` requires `hpos` (equal side-bit sequences). Drop it
and the statement becomes **false**: a single sibling can be replayed on the
other side. Conjecture a `verifyTagged` step that absorbs the side bit `b` into a
domain-separated residue class exactly as `taggedNode` does for nodes — e.g.
`stepTag b v s = 2 * Nat.pair (cond b s v) (cond b v s) + (if b then 1 else 0)`
— and prove its fold is jointly injective with `hpos` removed.
**Test**: First disprove the unguarded statement with a one-step instance where
the two paths swap sides; then state `verifyTagged` and reprove
`verifyAt_joint_injective` without `hpos`.
**The key insight is** that the side bit must itself be *committed* into the hash
input, not merely consulted to choose argument order — replay security is a
domain-separation statement about positions, identical in form to the leaf/node
parity tag of this cycle.
**Why now?** Both ingredients already exist and verified: the side-ambiguity is
explicit in `authStep_joint_injective`, and the tagging mechanism is exactly
`taggedNode`. Combining them is mechanical.
**If true**: formalizes why real Merkle proofs encode index/height — a property
usually argued only informally. **If false**: pinpoints a residual ambiguity that
tagging alone cannot remove.

### Direction 2: Abstract domain separation via `Sum`, removing the `ℕ`/parity coincidence
The parity tag is `ℕ`-specific (it leans on `omega`). Conjecture that the same
result holds over an *arbitrary* carrier: for injective `g : γ → β` and jointly
injective `h : β → β → β`, the maps `Sum.inl ∘ g : γ → β ⊕ β` (leaves) and a node
map landing in `Sum.inr` are automatically range-disjoint, so a `Sum`-valued
`treeHash` is injective across all shapes with **no** separation hypothesis.
**Test**: define `treeHash` over `β ⊕ β` (or generalize the codomain), prove the
`Sum.inl ≠ Sum.inr` separation, and recover `taggedTreeHash_injective` as the
`β = ℕ` specialization (with `2·` and `2·+1` as the concrete `inl`/`inr`).
**The key insight is** that domain separation is a pure *type-level* tagging
phenomenon; the parity `omega` step is only a numerical encoding of the
constructor-disjointness `Sum.inl_ne_inr`.
**Why now?** This cycle proved the `ℕ` instance end to end; the only `ℕ`-specific
step is the parity argument, which `Sum.inl_ne_inr` replaces verbatim.
**If true**: makes domain separation carrier-independent. **If false**: reveals a
hidden use of `ℕ` (e.g. an implicit pairing back into a single type).

### Direction 3: Authentication paths are exactly tree spines (the localization bridge)
Conjecture that `verifyAt` is just `treeHash` restricted to one root-to-leaf
spine: for any tree `t` and leaf position there is a canonical path `p` with
`verifyAt h (g leaf) p = treeHash g h t`. Then `authPath_collision_reduction`
becomes a literal restriction of a whole-tree collision reduction.
**Test**: define an extractor `authPathOf : BTree γ → Position → List (Bool × β)`
(siblings = the *hashes* of the off-path subtrees) and prove the recomputation
identity by structural induction on `t`; conclude
`authPath_soundness` from `treeHash_inj_sameShape` along the spine.
**The key insight is** that the membership proof carries sibling *hashes* while
the tree carries sibling *subtrees*; the extractor is precisely the natural
transformation that forgets everything off the spine but keeps its hash.
**Why now?** Both folds (`treeHash` node recursion and `verifyAt` foldl) now live
in the same namespace; only the extractor and its correctness lemma are missing.
**If true**: unifies whole-tree and membership-proof security under one
joint-injectivity umbrella. **If false**: exposes a genuine mismatch between
subtree-collisions and hash-collisions that distinguishes the two notions.

### Direction 4: Quantitative multi-collision counting (the `c > 0` regime)
The same-shape theorem is the `c = 0` (perfectly jointly injective) base case.
Conjecture: if `h` has at most `c` uncurried collision pairs, then for a fixed
shape `S` the number of distinct trees of shape `S` sharing a root hash is at most
a polynomial in `c` of degree `internalNodes S`.
**Test**: define `internalNodes : BTree γ → ℕ`, prove the depth-1, `c = 1` case as
a counting lemma, then induct on shape peeling one `h`-layer exactly as
`treeHash_inj_sameShape` does.
**The key insight is** that multiplicities should compose *multiplicatively* down
the two subtrees of each node, mirroring the "peel and recurse on both subtrees"
skeleton already verified here.
**Why now?** The same-shape induction is in hand; multiplicity counting reuses its
exact recursion structure with a `Finset.card` bound replacing the equality.
**If true**: a tree analogue of Joux multicollisions with a verified,
shape-indexed bound. **If false**: shows multiplicities interact
non-multiplicatively across siblings.

### Direction 5: Second-preimage vs. collision resistance are formally separated on trees
Conjecture a clean separation: there is a compression `h` that is collision
resistant on *same-shape* inputs, yet the untagged `treeHash` admits an efficient
same-root **second preimage** via shape manipulation. Formally: the same-shape
reduction (`treeHash_inj_sameShape`) holds while a cross-shape second-preimage
*finder* exists for an arbitrary target leaf.
**Test**: phrase two adversary predicates (collision-finder vs.
second-preimage-finder); prove the same-shape direction from
`treeHash_inj_sameShape`; and, generalizing `tree_cross_shape_collision_exists`,
exhibit for any leaf `a` a distinct tree with the same `Nat.pair`-root (use the
`Nat.pair` unfolding of `g a`).
**The key insight is** that the *shape* degree of freedom is exactly the resource
a second-preimage adversary exploits, and it is invisible to a same-shape
collision adversary — so the two security notions, often conflated in practice,
genuinely come apart.
**Why now?** Both the positive same-shape reduction and the explicit cross-shape
counterexample live in `Cryptography.MerkleTreeHash`; the separation only needs
the two adversary classes stated and the existing theorems quoted.
**If true**: a verified separation of two standard security notions. **If false**:
suggests shape attacks collisions and second preimages symmetrically.
