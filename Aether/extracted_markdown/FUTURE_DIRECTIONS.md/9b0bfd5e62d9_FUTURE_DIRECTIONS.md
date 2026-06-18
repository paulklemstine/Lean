# Future Directions: Merkle Authentication Paths and Domain Separation

## Synthesis

This cycle pushed the binary-tree collision-resistance theory of
`Cryptography.MerkleTreeHash` (built atop the linear Merkle–Damgård theory of
`Cryptography.MerkleDamgard`) in two directions that were left open as conjectures
by the previous cycle's notes: **authentication-path soundness** (their Direction 4)
and **domain separation by tagging** (their Direction 2).

The structural insight that organizes both files is that *every* Merkle-style hash
is a fold, and collision resistance is the *joint injectivity* of that fold once a
positional invariant is fixed. For whole trees the invariant is "same shape"
(`treeHash_inj_sameShape`); for a Merkle membership proof the invariant turns out to
be "same position" — i.e. the path's *side-bit sequence* is fixed while the siblings
vary. Concretely, `verifyAt h v p = p.foldl (authStep h) v`, and the new
`verifyAt_joint_injective` is the exact authentication-path transport of
`CryptoHash.foldl_joint_injective`. From it, authentication-path soundness
(`authPath_soundness`) and the security reduction (`authPath_collision_reduction`)
fall out as one-line corollaries, and the all-left path collapses verification back
onto `merkleDamgard` (`verifyAt_allLeft_eq_merkleDamgard`), mirroring the comb bridge.

A subtle failure clarified the boundary: a verification step is **not** injective if
the side bit is allowed to vary (`h s v = h v' s'` carries no contradiction across
sides), so the "same position" hypothesis is genuinely necessary — the path-level
analogue of why "same shape" is required for trees. On the domain-separation side we
turned the previous cycle's `hsep` *hypothesis* into a *theorem*: a one-bit parity
tag (leaves even, nodes odd) forces the ranges of the leaf and node maps disjoint, so
`taggedTreeHash_inj_crossShape` gives full cross-shape injectivity with no extra
assumption, and `taggedTreeHash_no_cross_shape_collision` shows it defeats the very
counterexample `tree_cross_shape_collision_exists` on the nose.

## Results Summary

- `verifyAt_joint_injective`: **proved** — path verification is jointly injective in
  the opened value and sibling list once the position (side-bit sequence) is fixed;
  the authentication-path analogue of `CryptoHash.foldl_joint_injective`.
- `authPath_soundness`: **proved** — with injective leaf map and compression, a
  Merkle proof cannot be opened to two different leaves at the same position.
- `authPath_collision_reduction`: **proved** — a forged opening (distinct leaf or
  distinct siblings verifying to the same root at the same position) yields an
  explicit `g`-collision or `h`-collision: soundness reduces to compression CR.
- `verifyAt_allLeft_eq_merkleDamgard`: **proved** — an all-left authentication path
  recomputes the root by exactly the Merkle–Damgård fold (the path-level bridge,
  counterpart of `treeHash_leftComb_eq_merkleDamgard`).
- `authStep_sib_inj`: **proved** — one verification step with fixed side bit is
  injective in the sibling (the layer-peeling lemma).
- `taggedNode_injective`, `taggedLeaf_injective`: **proved** — parity tagging
  preserves injectivity.
- `taggedLeaf_ne_taggedNode`: **proved** — even leaf hashes never equal odd node
  hashes, discharging `hsep` by parity.
- `taggedTreeHash_inj_crossShape`: **proved** — tagging realizes domain separation
  for free; full cross-shape injectivity with no `hsep` hypothesis.
- `taggedTreeHash_no_cross_shape_collision`: **proved** — the boundary
  counterexample of `tree_cross_shape_collision_exists` is concretely defeated by
  tagging.

## Research Directions

### Direction 1: Variable-position path verification needs a position-binding tag
**Hypothesis**: `verifyAt_joint_injective` is FALSE if the side-bit sequences may
differ (`hpos` dropped); but a "position-binding" tagged step — where each
`authStep` also absorbs its own side bit into a domain-separated residue class, à la
`taggedNode` — restores joint injectivity over arbitrary (possibly differing) paths,
yielding *position-binding* Merkle proofs (you cannot replay a sibling at a different
height/side).
**Test**: First disprove the unguarded statement by exhibiting two paths with
swapped sides and a shared root (a 1-node instance of the left/right ambiguity noted
in the `authStep_sib_inj` lab notebook). Then state and prove a `verifyTagged`
variant whose step writes `(b, h …)` into disjoint classes and show its joint
injectivity with `hpos` removed.
**Why now**: We already have the disproof mechanism (the side-ambiguity is explicit
in this cycle) and the tagging mechanism (`taggedNode`) in hand; combining them is
mechanical.
**If true**: Formalizes why real Merkle proofs encode index/height — a security
property usually argued only informally.
**If false**: Pinpoints a residual ambiguity that tagging alone cannot remove,
sharpening exactly what a position commitment must bind.

### Direction 2: Abstract (non-`ℕ`) domain separation via `Sum`
**Hypothesis**: The parity tag over `ℕ` generalizes: for injective `g : γ → β` and
injective `h : β → β → β`, the tagged maps `Sum.inl ∘ g : γ → β ⊕ β` and a node map
landing in `Sum.inr` satisfy `treeHash_inj_domainSeparated`'s `hsep` automatically,
giving cross-shape injectivity over *any* carrier, not just `ℕ`.
**Test**: Define `treeHash` over the sum type (or generalize the existing one),
prove the `Sum.inl ≠ Sum.inr` separation, and recover
`taggedTreeHash_inj_crossShape` as the `β = ℕ` specialization.
**Why now**: This cycle proved the `ℕ` instance end-to-end; the only `ℕ`-specific
step is the parity `omega`, which `Sum` injectivity replaces verbatim.
**If true**: Removes the arithmetic coincidence and makes domain separation a pure
type-level encoding result.
**If false**: Reveals a hidden use of `ℕ` structure (e.g. needing a pairing into the
same type) that the abstract framing cannot supply.

### Direction 3: Quantitative multi-collision counting (the `c > 0` case)
**Hypothesis**: For a compression with at most `c` uncurried-collision pairs, the
number of distinct trees of a *fixed* shape `S` sharing a root hash is at most a
polynomial in `c` whose degree equals `S`'s internal-node count, with the `c = 0`
base case being `treeHash_inj_sameShape`.
**Test**: Define `internalNodes : BTree γ → ℕ`, and prove the `c = 1`, depth-1 case
(a single node) as a counting lemma, then induct on shape peeling one `h`-layer
exactly as `treeHash_inj_sameShape` does.
**Why now**: The same-shape induction skeleton is already verified; multiplicity
counting reuses its "peel and recurse on both subtrees" structure.
**If true**: A tree analogue of Joux multicollisions with a verified, shape-indexed
bound.
**If false**: Shows multiplicities interact non-multiplicatively across siblings,
identifying where the layered-composition picture breaks.

### Direction 4: Authentication paths are exactly tree spines (the localization bridge)
**Hypothesis**: For any tree `t` and leaf position, there is a canonical path `p`
with `verifyAt h (g leaf) p = treeHash g h t`; i.e. `verifyAt` is `treeHash`
restricted to one root-to-leaf spine, so `authPath_collision_reduction` is a literal
restriction of `tree_collision_implies_compression_collision`.
**Test**: Define an `authPathOf : BTree γ → position → List (Bool × α)` extractor and
prove the recomputation identity by structural induction on `t`.
**Why now**: Both folds (`treeHash` node recursion and `verifyAt` foldl) are now
formalized in the same namespace; the missing piece is only the extractor and its
correctness lemma.
**If true**: Unifies the whole-tree and membership-proof security theorems under one
joint-injectivity umbrella.
**If false**: Exposes a mismatch (e.g. sibling subtrees vs. sibling *hashes*) that
distinguishes proof soundness from full-tree collision resistance.

### Direction 5: Second-preimage vs. collision resistance separation on trees
**Hypothesis**: There is a compression `h` collision-resistant on same-shape inputs
yet for which untagged `treeHash` admits an efficient same-root *second preimage* via
shape manipulation — formalized as: the same-shape reduction holds while a cross-shape
second-preimage finder exists, generalizing `tree_cross_shape_collision_exists` to a
family parameterized by target tree.
**Test**: Phrase two adversary predicates (collision-finder vs. second-preimage
finder), prove the same-shape direction from `treeHash_inj_sameShape`, and exhibit a
cross-shape second preimage for an arbitrary given leaf using the `Nat.pair` trick.
**Why now**: Both the positive same-shape reduction and the explicit cross-shape
counterexample live in one file; the separation only needs the two adversary classes
stated and the existing theorems quoted.
**If true**: A clean formal separation of two security notions that are often
conflated in practice.
**If false**: Suggests the shape degree of freedom attacks collisions and second
preimages symmetrically, collapsing the intended separation.
