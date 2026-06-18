# Future Directions: Merkle–Damgård as a Monoid Action

New file this cycle: `Catalog/Algebra/MerkleDamgardAction.lean`
(module `Algebra.MerkleDamgardAction`), an Algebra ⇄ Cryptography bridge built on the
catalog file `Cryptography.MerkleDamgard` (`CryptoHash`).

## Synthesis

The catalog's linear Merkle–Damgård theory (`merkleDamgard`, `merkleDamgard_append`,
`foldl_joint_injective`, `compress_injective_md_injective`,
`md_collision_implies_compress_collision`, `md_strengthen_injective`) reasons about a
*fixed* initialization vector. The structural insight of this cycle is that those results
are shadows of a single algebraic object: a message is a **state transformation**
`a ↦ merkleDamgard f a m`, an element of `Function.End α`. Under this lens the catalog's
domain-extension lemma `merkleDamgard_append` is exactly the statement that concatenation
of messages composes transformations *in reverse order*, so the free monoid `FreeMonoid β`
of message blocks acts on the state space. We packaged this as a genuine monoid
homomorphism `mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ` (the opposite monoid is forced
by the reversed composition order — our first failed attempt targeted `Function.End α`
directly and the multiplication order in `map_mul'` was wrong).

With the algebra in place, two upgrades fell out almost for free. First, "collision
resistance" becomes "faithfulness of the action": `mdEnd_injOn_length` shows that for
injective `f` over a nonempty state space, equal-length messages inducing the *same*
transformation must be equal — an `iv`-independent strengthening of the catalog's
single-`iv` `compress_injective_md_injective`. Second, the Critic found that the converse is
**false**: `converse_faithful_not_imply_injective` exhibits a nonempty state space and a
non-injective compression whose action is nevertheless faithful on equal-length words
(over a one-block alphabet, equal-length words are automatically equal, so faithfulness is
vacuous). This pins down precisely why faithfulness is weaker than injectivity: the action
sees `f` only through *reachable* chaining values.

Finally we ran the generalization loop one level up the structural ladder: linear MD is the
path-graph special case of binary **Merkle tree** hashing. `treeHash_injOn_shape` proves
collision resistance for trees of a fixed shape, the free-*magma* analogue of
`foldl_joint_injective` (the same "shape/length determines structure, injectivity peels one
layer" induction recurs). The same-shape hypothesis is essential — dropping it makes the
statement false (a leaf can collide with a node) — which seeds the open domain-separation
conjecture below.

## Results Summary

- `mdEnd` / `mdEnd_apply` / `mdEnd_nil`: proved — define the message-as-state-transformation
  viewpoint and its identity law.
- `mdEnd_append`: proved — message concatenation composes transformations in reverse order
  (the algebraic form of `merkleDamgard_append`).
- `mdHom`: proved (`MonoidHom`) — packages the whole MD construction as one homomorphism
  `FreeMonoid β →* (Function.End α)ᵐᵒᵖ`; domain extension *is* `map_mul`.
- `mdHom_apply`: proved — evaluating the hom recovers `merkleDamgard`.
- `mdEnd_injOn_length`: proved — **main result**; injective compression ⇒ faithful action on
  equal-length messages (an `iv`-free upgrade of `compress_injective_md_injective`).
- `mdHom_injOn_length`: proved — the homomorphism is injective on fixed-length words.
- `md_collision_closed_under_suffix`: proved — every MD collision survives appending a common
  suffix ("collision once, collision forever").
- `mdEnd_injective_of_padding`: proved — Merkle–Damgård strengthening makes the action
  faithful on *all* messages (action-language form of `md_strengthen_injective`).
- `converse_faithful_not_imply_injective`: disproved (counterexample) — faithfulness is
  strictly weaker than uncurry-injectivity of `f`.
- `treeHash` / `BTree` / `BTree.shape`: proved (definitions) — binary Merkle tree hashing.
- `treeHash_injOn_shape`: proved — collision resistance for same-shape Merkle trees
  (free-magma generalization of the linear theory).
- `treeHash_injective_with_domain_separation_conjecture`: conjecture (sorry) — shape-free tree
  collision resistance via domain separation.

## Research Directions

### Direction 1: Domain separation removes the shape hypothesis
**Hypothesis**: There is a tagging scheme `tag : Bool → α → α` (distinguishing leaf inputs
from internal-node inputs) such that the tagged tree hash is injective on *all* binary trees,
with no same-shape assumption — i.e. `treeHash_injOn_shape` holds unconditionally for the
tagged construction.
**Test**: Formalize a tagged `treeHash'` and prove the shape is recoverable from the hash
(so leaf/node cross-collisions are impossible), then redo the structural induction without
`hshape`. Disproof would be a tagged collision between a leaf and a node.
**Why now**: `treeHash_injOn_shape` already isolates the *only* place the shape hypothesis is
used (the two cross constructor cases); domain separation is precisely the device that
discharges them. The key insight is that the shape hypothesis is load-bearing in exactly two
inductive cases, so making shape recoverable from the hash is both necessary and sufficient.
**If true**: We obtain real-world Merkle tree security (the reason production trees tag leaves
vs. nodes) as a theorem, and `treeHash_injective_with_domain_separation_conjecture` is closed.
**If false**: It would reveal that tagging alone is insufficient and that length/shape
encoding is fundamentally required, sharpening the boundary between MD strengthening and tree
domain separation.

### Direction 2: Faithfulness characterization on reachable orbits
**Hypothesis**: `mdEnd f` is faithful on equal-length words **iff** `f` is injective when
restricted to the set of chaining values reachable from the considered start states — a
precise converse to `mdEnd_injOn_length`.
**Test**: Define the reachable-state set `Reach f S = { merkleDamgard f a m | a ∈ S }` and
prove the biconditional; the counterexample `converse_faithful_not_imply_injective` must
become the degenerate `Reach` case.
**Why now**: This cycle proved one direction and *disproved* the naive converse, so the gap is
exactly the reachability condition. The key insight is that the action only ever tests `f` on
reachable states, so faithfulness can only ever certify injectivity there.
**If true**: We get a tight algebraic characterization of MD collision resistance, turning a
one-way implication into an iff.
**If false**: The failure would expose an additional obstruction (e.g. multiplicity of
reachability) beyond the orbit, worth isolating.

### Direction 3: Faithful ⇒ free, and a group action when `f` is a bijection
**Hypothesis**: If each block map `b ↦ f · b` is a bijection of `α`, then `mdHom f` factors
through a homomorphism into the symmetric group `Equiv.Perm α`, giving a genuine
(left/right) free monoid action by permutations; faithfulness then upgrades to a free action.
**Test**: Build `mdPermHom f : FreeMonoid β →* (Equiv.Perm α)ᵐᵒᵖ` under the bijectivity
hypothesis and relate its injectivity to `mdHom_injOn_length`.
**Why now**: `mdHom` is already a `MonoidHom` into `(Function.End α)ᵐᵒᵖ`; restricting the
target to units is the standard next step. The key insight is that invertible compression
turns the endomorphism action into a permutation action, where free-group/monoid machinery
applies directly.
**If true**: Connects hash chaining to permutation-group dynamics, opening cycle-structure and
mixing-time questions for invertible compression functions.
**If false**: Pinpoints that non-invertibility is essential to MD security, contrasting with
block-cipher (invertible) constructions.

### Direction 4: Quantitative second-preimage stability
**Hypothesis**: Define the "collision suffix monoid" of a pair `(m₁, m₂)` as
`{ s | merkleDamgard f iv (m₁ ++ s) = merkleDamgard f iv (m₂ ++ s) }`; this set is always a
**submonoid** of `FreeMonoid β` containing `FreeMonoid β` whenever `m₁, m₂` already collide,
and is `{1}`-trivial-modulo-prefix otherwise.
**Test**: Prove the submonoid closure property (extends `md_collision_closed_under_suffix`)
and characterize when it is all of `FreeMonoid β`.
**Why now**: `md_collision_closed_under_suffix` already shows closure under right
multiplication by arbitrary suffixes; promoting "closed under suffix" to "is a submonoid" is
the natural algebraic completion. The key insight is that collisions are not isolated events
but an algebraically closed set, so submonoid structure is the right invariant.
**If true**: Gives an algebraic invariant measuring how "deep" a collision is, useful for
reasoning about iterated/streamed hashing.
**If false**: Would indicate suffix closure does not interact with prefixes as cleanly as
the monoid picture suggests, refining the action model.

### Direction 5: Wide-pipe / truncated MD and loss of faithfulness
**Hypothesis**: Composing MD with a non-injective finalization `τ : α → γ` (truncation, as in
SHA-512/256) destroys faithfulness in a controlled way: `τ ∘ merkleDamgard f iv` is faithful
on length-`n` messages iff `τ` is injective on the reachable length-`n` image.
**Test**: State `τ`-truncated collision resistance and relate it to injectivity of `τ` on the
reachable set; produce a counterexample when `τ` collapses two reachable hashes.
**Why now**: The action/orbit language developed here (Direction 2) makes "reachable image"
a first-class object, so truncation analysis reduces to injectivity of `τ` on that image.
The key insight is that truncation acts *after* the action, so its damage is exactly its
non-injectivity on the orbit — nothing more.
**If true**: Explains the wide-pipe design principle (make the internal state larger than the
output) as a faithfulness-preservation theorem.
**If false**: Would reveal interaction between truncation and chaining beyond the orbit image,
an unexpected coupling worth formalizing.
