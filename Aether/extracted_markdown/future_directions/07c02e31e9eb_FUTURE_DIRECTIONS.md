# Future Directions: Merkle Tree Hashing and Collision Resistance

This cycle extended the linear Merkle–Damgård collision-resistance theory
(`Cryptography.MerkleDamgard`: `merkleDamgard`, `foldl_joint_injective`,
`compress_injective_md_injective`, `md_collision_implies_compress_collision`)
to *binary hash trees* in `Cryptography.MerkleTreeHash`. The new file proves:

- `treeHash_inj_sameShape` — injectivity of the tree hash on same-shape trees;
- `tree_collision_implies_compression_collision` — the security reduction
  (a tree collision yields a leaf-map or compression collision);
- `treeHash_inj_domainSeparated` — full cross-shape injectivity once leaf- and
  node-hashes are domain-separated;
- `treeHash_leftComb_eq_merkleDamgard` — the bridge identifying Merkle–Damgård
  as the left-comb (linear) special case of tree hashing;
- `tree_cross_shape_collision_exists` — a boundary counterexample showing the
  same-shape / domain-separation hypotheses are necessary.

The directions below are concrete, falsifiable next steps.

## Direction 1: Quantitative multi-collision bounds for shaped trees

Conjecture: For a compression `h : α → α → α` with at most `c` collision pairs,
the number of distinct trees of a *fixed* shape `S` with `n` leaves that share a
common root hash is bounded by a polynomial `P_S(c, n)` whose degree equals the
number of internal nodes of `S`, and this bound is tight for "balanced" shapes.

The key insight is that a fixed shape turns the hash into a *layered* composition
of `h`, so multi-collisions factor through per-node collision multiplicities; the
shape's internal-node count controls how these multiplicities multiply. This
upgrades the qualitative reduction `tree_collision_implies_compression_collision`
to a counting statement, the tree analogue of Joux multicollisions for
Merkle–Damgård.

Why now? We already have `treeHash_inj_sameShape`, which is exactly the `c = 0`
base case; the inductive skeleton of its proof (peel one `h`-layer, recurse on
both subtrees) is the natural carrier for a multiplicity-counting induction.

## Direction 2: Length/shape-tagging realizes domain separation generically

Conjecture: For any injective `g` and injective `h`, the *tagged* tree hash
`treeHash (Sum.inl ∘ g) h'` — where `h'` writes node outputs into a disjoint tag
class — automatically satisfies the `hsep` hypothesis of
`treeHash_inj_domainSeparated`, hence is fully (cross-shape) collision resistant
with *no* extra assumption beyond injectivity of `g` and `h`.

The key insight is that the abstract obstruction in
`tree_cross_shape_collision_exists` is precisely the *overlap* between the range
of `g` and the range of `h`; a one-bit tag forces these ranges disjoint, so
domain separation is not an extra hypothesis but a free encoding transformation.

Why now? `treeHash_inj_domainSeparated` isolates `hsep` as the single missing
ingredient, and `tree_cross_shape_collision_exists` pinpoints range-overlap as
the only failure mode — so the conjecture is a constructive closing of exactly
that gap.

## Direction 3: Sponge / unbalanced-tree hashing unifies with the comb bridge

Conjecture: The bridge `treeHash_leftComb_eq_merkleDamgard` generalizes to an
equivalence between *any* binary-tree hashing schedule and an iterated
"absorb/squeeze" sponge over a 2-to-1 permutation, with collision resistance of
one transferring to the other up to the shape's depth.

The key insight is that `leftCombAux` is literally a `foldl`, i.e. a degenerate
sponge with capacity zero; replacing the comb's right spine of leaves by an
arbitrary tree schedule is the same as choosing a non-trivial absorption order,
and the hash value is invariant under associativity-respecting re-schedulings.

Why now? The comb bridge gives a verified equality between a structural recursion
(`treeHash`) and a tail recursion (`foldl`/`merkleDamgard`); generalizing the
accumulator from a single value to a (rate, capacity) state is a small,
mechanizable step from the existing `treeHash_leftCombAux` induction.

## Direction 4: Authentication-path soundness (Merkle proofs)

Conjecture: Define a Merkle membership proof as the list of sibling hashes along
a root-to-leaf path. Then, assuming `h` is collision resistant, a verifier that
recomputes the root accepts a forged leaf at a fixed position only if it can
exhibit an explicit `h`-collision — i.e. authentication-path soundness reduces to
compression collision resistance exactly as `treeHash_inj_sameShape` does for the
whole tree.

The key insight is that an authentication path is a `foldr` of `h` over the
sibling list, so path verification is *the same recursion* as `treeHash`
restricted to a spine; soundness is therefore a localized instance of the joint
injectivity already proven, not a new hardness assumption.

Why now? Git, Bitcoin, and Certificate Transparency all rely on this exact
property informally; the `leftCombAux`/`foldl` correspondence we proved is the
missing formal scaffold to state and discharge it as a corollary.

## Direction 5: Second-preimage resistance separates from collision resistance on trees

Conjecture: There is a compression `h` that is collision resistant on same-shape
inputs yet for which `treeHash` (without domain separation) admits an efficient
*second-preimage* finder via shape manipulation — formally, the predicate "every
adversary outputting a same-shape second preimage yields an `h`-collision" holds,
while the cross-shape version provably fails, witnessed by a generalization of
`tree_cross_shape_collision_exists`.

The key insight is that collision resistance is a statement about *two unknown*
inputs whereas second-preimage resistance fixes one; the shape degree of freedom
exploited in `tree_cross_shape_collision_exists` attacks only the latter, giving
a clean formal separation between the two security notions on tree hashes.

Why now? We already have both the positive same-shape reduction and the explicit
cross-shape counterexample in the same file; making the separation precise only
requires phrasing the two adversary classes and quoting the existing theorems.
