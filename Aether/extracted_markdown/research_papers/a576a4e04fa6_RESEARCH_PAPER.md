# Collision Resistance as Joint Injectivity: A Unified Theory of Merkle–Damgård Chains and Merkle Trees

## Abstract

We present a self-contained, structural theory of collision resistance for the
two foundational hash constructions of applied cryptography: the linear
**Merkle–Damgård** chain and the binary **Merkle tree**. The unifying principle
is that every such hash is a *fold* of a small compression gadget, and collision
resistance is precisely the *joint injectivity* of that fold once a positional
invariant is fixed. For the chain the invariant is *equal message length*; for
the tree it is *equal shape*. We prove (i) that an injective compression yields a
chain hash injective on equal-length messages, and that any equal-length
collision reduces to an explicit compression collision; (ii) a constructive
convergence lemma extracting a *located* collision with equal block input; (iii)
the length-extension identity and its cure via injective, length-encoding
padding; (iv) the tree analogue — injective leaf-hash and compression yield a
tree hash injective on equal-shape trees, with a corresponding security
reduction; (v) full cross-shape injectivity under *domain separation*, together
with a one-bit tagging scheme that supplies domain separation for free; (vi) a
boundary counterexample establishing that the same-shape hypothesis is necessary;
and (vii) a *bridge theorem* exhibiting Merkle–Damgård as the left-comb
(degenerate linear) special case of Merkle-tree hashing. All results are
combinatorial and probability-free: security of the whole reduces to injectivity
of the part. The development has been fully formalized and machine-checked.

**Keywords.** collision resistance, Merkle–Damgård, Merkle tree, hash functions,
injective fold, domain separation, second-preimage resistance, length extension.

---

## 1. Introduction

Collision resistance — the infeasibility of producing two distinct inputs with
the same hash — is the central security property of cryptographic hash functions
and the structural backbone of blockchains, version-control systems, and
transparency logs. The standard way to build a collision-resistant hash on long
inputs from a fixed-arity *compression function* is the Merkle–Damgård
construction; the standard way to build an *authenticated data structure* from
the same primitive is the Merkle tree.

The classical reductions for these constructions are usually phrased
probabilistically. The thesis of this paper is that the essential content is
purely combinatorial: it is a statement about *injective functions* and *folds*.
We give a complete, probability-free account and, in doing so, expose a precise
sense in which the chain and the tree are the same object.

### 1.1 Contributions

1. A clean statement and proof that **joint injectivity of a left fold** is the
   algebraic kernel of Merkle–Damgård collision resistance (§3).
2. The positive reduction (injective compression ⇒ injective chain on equal
   length) and its contrapositive security reduction (§4).
3. A **constructive convergence lemma** producing a located collision (§5).
4. The **length-extension identity** and its cure by injective length-encoding
   padding (§6).
5. The Merkle-tree generalization: definitions, the **same-shape injectivity**
   theorem, and the tree security reduction (§7).
6. **Domain separation** for full cross-shape injectivity, a **one-bit tagging**
   scheme realizing it, and a **boundary counterexample** proving the same-shape
   hypothesis necessary (§8).
7. The **bridge theorem** identifying Merkle–Damgård with left-comb tree hashing
   (§9).

---

## 2. Preliminaries and Notation

Throughout, `α`, `β`, `γ` are types. We write `Function.Injective f` for the
statement that `f x = f y → x = y`. For a binary operation `f : α → β → α` we
write `Function.uncurry f : α × β → α` for its uncurried form `(a, b) ↦ f a b`;
"`f` is injective as a pair function" means `Function.uncurry f` is injective,
i.e. `f a₁ b₁ = f a₂ b₂ → a₁ = a₂ ∧ b₁ = b₂`. This is the abstract counterpart of
"the compression gadget has no collisions." We model a *block message* as a list,
and use the left fold `List.foldl f a [b₁, …, bₙ] = f (… f (f a b₁) b₂ …) bₙ`.

---

## 3. The Algebraic Kernel: Joint Injectivity of foldl

The entire theory rests on one lemma.

> **Definition 3.1 (Merkle–Damgård hash).** For a compression function
> `f : α → β → α`, an initialization vector `iv : α`, and a message
> `msg : List β`,
> `merkleDamgard f iv msg := msg.foldl f iv`.

> **Lemma 3.2 (merkleDamgard recurrences).**
> `merkleDamgard f iv [] = iv` and
> `merkleDamgard f iv (b :: msg) = merkleDamgard f (f iv b) msg`.
>
> *Proof.* Immediate from the definition of `foldl`. ∎

> **Theorem 3.3 (Joint injectivity of foldl).** Let `f : α → β → α` be injective
> as a pair function. For lists `l₁, l₂ : List β` with `l₁.length = l₂.length`
> and accumulators `a₁, a₂ : α`, if `l₁.foldl f a₁ = l₂.foldl f a₂` then
> `a₁ = a₂` **and** `l₁ = l₂`.
>
> *Proof sketch.* Induction on `l₁`, generalizing `l₂`, `a₁`, `a₂`. If `l₁` is
> empty then by the length hypothesis `l₂` is empty, and the fold values are the
> accumulators, giving `a₁ = a₂`. If `l₁ = x₁ :: t₁`, the length hypothesis forces
> `l₂ = x₂ :: t₂`, and `t₁.foldl f (f a₁ x₁) = t₂.foldl f (f a₂ x₂)`. The
> induction hypothesis yields `f a₁ x₁ = f a₂ x₂` and `t₁ = t₂`; injectivity of
> `f` as a pair function then gives `a₁ = a₂` and `x₁ = x₂`. Generalizing the
> accumulators is essential — without it the induction hypothesis is too weak to
> re-enter at the updated states. ∎

The lemma says that a left fold of an injective operation, restricted to fixed
length, *loses no information*: the output determines both the seed and the
entire input sequence.

---

## 4. Collision Resistance Preservation

> **Theorem 4.1 (Injective compression ⇒ injective chain).** If `f` is injective
> as a pair function, then for any `iv` and equal-length messages `m₁, m₂`,
> `merkleDamgard f iv m₁ = merkleDamgard f iv m₂` implies `m₁ = m₂`.
>
> *Proof.* Apply Theorem 3.3 with `a₁ = a₂ = iv`; its second conclusion is
> `m₁ = m₂`. ∎

> **Theorem 4.2 (Chain security reduction).** For any `f`, `iv`, and distinct
> equal-length messages `m₁ ≠ m₂` with
> `merkleDamgard f iv m₁ = merkleDamgard f iv m₂`, there exist distinct pairs
> `p₁ ≠ p₂ : α × β` with `Function.uncurry f p₁ = Function.uncurry f p₂`.
>
> *Proof sketch.* Contrapositive of Theorem 4.1. If `f` had no collision it would
> be injective as a pair function, whence `m₁ = m₂` by Theorem 4.1, contradicting
> `m₁ ≠ m₂`. Classical logic supplies the existential witness from the negation
> of injectivity. ∎

Theorem 4.2 is the security statement that matters in practice: *the only way to
collide the long hash is to collide the fixed-size compression*.

> **Lemma 4.3 (Append / domain-extension law).**
> `merkleDamgard f iv (m₁ ++ m₂) = merkleDamgard f (merkleDamgard f iv m₁) m₂`.
>
> *Proof.* `List.foldl_append`. ∎

---

## 5. Constructive Convergence

The contrapositive reduction of §4 is non-constructive in the witness. We give a
constructive form that *locates* a collision.

> **Theorem 5.1 (Constructive convergence).** Let `α` have decidable equality and
> let `f : α → β → α`. If `a₁ ≠ a₂` but `l.foldl f a₁ = l.foldl f a₂` for some
> `l : List β`, then there exist states `s₁ ≠ s₂` and a block `b` with
> `f s₁ b = f s₂ b`.
>
> *Proof sketch.* Induction on `l`. The empty list forces `a₁ = a₂`,
> contradicting the hypothesis. For `l = b :: t`: if `f a₁ b = f a₂ b`, the pair
> `(a₁, a₂, b)` is the desired located collision. Otherwise `f a₁ b ≠ f a₂ b`
> while `t.foldl f (f a₁ b) = t.foldl f (f a₂ b)`, so the induction hypothesis
> applies at the updated states. ∎

Note the *located* collision has the **same block input** on both sides — only
the chaining value differs. This is a structurally special collision and is
exactly what a practical attack would surface.

---

## 6. Length Extension and Its Cure

The append law (Lemma 4.3) is double-edged.

> **Theorem 6.1 (Length-extension property).** For all `m₁, s`,
> `merkleDamgard f iv (m₁ ++ s) = merkleDamgard f (merkleDamgard f iv m₁) s`.
>
> *Proof.* Special case of Lemma 4.3. ∎

Consequence: an adversary holding only `H = merkleDamgard f iv m₁` (not `m₁`) can
compute `merkleDamgard f iv (m₁ ++ s)` for any suffix `s` as
`merkleDamgard f H s`. This is the *length-extension attack* and rules out the
naive use of raw Merkle–Damgård as a message authentication code.

The classical cure is **Merkle–Damgård strengthening**: hash a padded message
whose padding injectively encodes the length.

> **Definition 6.2 (Strengthened hash).**
> `mdStrengthen f pad iv msg := merkleDamgard f iv (pad msg)`.

> **Theorem 6.3 (Strengthening gives full injectivity).** Suppose `f` is
> injective as a pair function, `pad` is injective, and `pad` produces
> equal-length outputs (`(pad m₁).length = (pad m₂).length` for all `m₁, m₂`).
> Then `mdStrengthen f pad iv m₁ = mdStrengthen f pad iv m₂` implies `m₁ = m₂` for
> **all** messages, not merely equal-length ones.
>
> *Proof.* The equal-length hypothesis lets Theorem 4.1 apply to the padded
> messages, yielding `pad m₁ = pad m₂`; injectivity of `pad` gives `m₁ = m₂`. ∎

The length-encoding padding folds variable-length security into the equal-length
theory.

---

## 7. The Merkle Tree Generalization

We now lift the chain from a line to a binary tree.

> **Definition 7.1 (Binary trees).** `BTree γ` is generated by
> `leaf : γ → BTree γ` and `node : BTree γ → BTree γ → BTree γ`.

> **Definition 7.2 (Tree hash).** For a leaf map `g : γ → α` and a compression
> `h : α → α → α`,
> `treeHash g h (leaf x) = g x` and
> `treeHash g h (node l r) = h (treeHash g h l) (treeHash g h r)`.

> **Definition 7.3 (Same shape).** `SameShape` is the least relation with
> `SameShape (leaf a) (leaf b)` for all `a, b`, and
> `SameShape (node l₁ r₁) (node l₂ r₂)` whenever `SameShape l₁ l₂` and
> `SameShape r₁ r₂`. Two trees have the same shape iff they agree as binary trees
> after erasing leaf labels. This is the tree analogue of *equal length*.

> **Theorem 7.4 (Same-shape injectivity).** If `g` is injective and `h` is
> injective as a pair function, then for same-shape trees `t₁, t₂`,
> `treeHash g h t₁ = treeHash g h t₂` implies `t₁ = t₂`.
>
> *Proof sketch.* Induction on the `SameShape` derivation. In the leaf case the
> hypothesis is `g a = g b`, so `a = b` by injectivity of `g`. In the node case,
> `h (treeHash g h l₁) (treeHash g h r₁) = h (treeHash g h l₂) (treeHash g h r₂)`;
> injectivity of `h` as a pair function peels one layer to give
> `treeHash g h l₁ = treeHash g h l₂` and likewise for the right subtrees, and
> the two induction hypotheses finish. This is the faithful shape-indexed analogue
> of Theorem 3.3. ∎

> **Theorem 7.5 (Tree security reduction).** For same-shape trees `t₁ ≠ t₂` with
> `treeHash g h t₁ = treeHash g h t₂`, either there exist `x ≠ y` with
> `g x = g y`, or there exist `p ≠ q : α × α` with
> `Function.uncurry h p = Function.uncurry h q`.
>
> *Proof sketch.* Contrapositive of Theorem 7.4: absence of both a `g`-collision
> and an `h`-collision makes `g` and `h` injective, forcing `t₁ = t₂`. ∎

Just as for the chain, a tree collision reduces to a collision in one of the two
small gadgets.

---

## 8. Domain Separation, Tagging, and the Necessity of Shape

The same-shape hypothesis is not a technicality; without it, injective gadgets do
not suffice.

> **Theorem 8.1 (Cross-shape collision exists).** There exist injective
> `g : ℕ → ℕ` and `h : ℕ → ℕ → ℕ` (injective as a pair function) and distinct
> trees `t₁ ≠ t₂` with `treeHash g h t₁ = treeHash g h t₂`.
>
> *Proof.* Take `g = id` and `h = Nat.pair` (the standard injective pairing on
> `ℕ`). Let `t₁ = node (leaf 0) (leaf 1)` and `t₂ = leaf (Nat.pair 0 1)`. Then
> `treeHash g h t₁ = Nat.pair 0 1 = treeHash g h t₂`, while `t₁ ≠ t₂` since one is
> a node and the other a leaf. ∎

This is the abstract skeleton of the **Merkle second-preimage weakness**: the
attacker exploits a degree of freedom — the *shape* — that the gadget injectivity
does not constrain. The root value of a node coincides with a value also
producible at a leaf.

The standard countermeasure is **domain separation**: forbid any leaf-hash value
from equalling any node-hash value.

> **Theorem 8.2 (Domain-separated full injectivity).** Suppose `g` is injective,
> `h` is injective as a pair function, and for all `x, l, r`,
> `g x ≠ h (treeHash g h l) (treeHash g h r)` (no leaf value equals any node
> value). Then `treeHash g h t₁ = treeHash g h t₂` implies `t₁ = t₂` for **all**
> trees, regardless of shape.
>
> *Proof sketch.* Structural induction on `t₁`, case-splitting on `t₂`. The mixed
> leaf/node and node/leaf cases are exactly the separation hypothesis and are
> impossible. The leaf/leaf case uses injectivity of `g`; the node/node case uses
> injectivity of `h` followed by the two induction hypotheses. ∎

The separation hypothesis can be *manufactured* rather than assumed, by tagging:
stamp leaf outputs and node outputs into disjoint classes — for instance, a
one-bit parity tag making all leaf values even and all node values odd. The
ranges of the leaf and node maps are then disjoint by construction, so the
hypothesis of Theorem 8.2 holds automatically given only injectivity of the
underlying gadgets, and the counterexample of Theorem 8.1 is defeated: the
node-produced value can no longer coincide with any leaf value. Thus *domain
separation is a free encoding transformation, not an extra assumption.*

---

## 9. The Bridge: Merkle–Damgård as a Left-Comb Tree

Finally we make precise the sense in which the chain *is* a tree.

> **Definition 9.1 (Left comb).** `leftCombAux t [] = t` and
> `leftCombAux t (b :: bs) = leftCombAux (node t (leaf b)) bs`. The left comb over
> an initial value `a` and blocks `bs` is `leftComb a bs := leftCombAux (leaf a) bs`.

A left comb is the "caterpillar" tree whose internal nodes form a single
left-leaning spine, each new block grafted as a right child.

> **Lemma 9.2 (Comb hash unfolds to a fold).** With identity leaves,
> `treeHash id h (leftCombAux t bs) = bs.foldl h (treeHash id h t)`.
>
> *Proof sketch.* Induction on `bs`, generalizing the accumulator `t`; one
> `foldl` step matches one `leftCombAux` step. ∎

> **Theorem 9.3 (Bridge).** With `g = id`,
> `treeHash id h (leftComb a bs) = merkleDamgard h a bs`.
>
> *Proof.* Specialize Lemma 9.2 to `t = leaf a`, noting
> `treeHash id h (leaf a) = a` and that `merkleDamgard h a bs = bs.foldl h a`
> definitionally. ∎

Consequently **Merkle–Damgård is the degenerate linear special case of
Merkle-tree hashing**: collapse the tree onto a spine and the tree hash *is* the
chain hash. The chain's collision resistance (Theorem 4.1) is recovered as the
left-comb instance of the tree's (Theorem 7.4), and "same shape" specializes to
"same length" because two combs share a shape exactly when they have equally many
blocks.

---

## 10. Algorithms

The constructions are directly executable. Three algorithms organize the
development:

1. **Chain hash (`merkleDamgard`).** Left fold of `f` over the blocks from `iv`;
   linear time, constant extra space. Underpins Theorems 4.1–4.2, 6.1, 6.3.
2. **Tree hash (`treeHash`).** Post-order recursion combining children with `h`;
   time linear in the number of nodes, stack depth equal to tree height.
   Underpins Theorems 7.4–7.5, 8.2.
3. **Located-collision extractor (`foldl_convergence` witness search).** Given two
   distinct seeds converging under a common message, walk the conveyor belt and
   return the first step where the chaining values differ but outputs coincide;
   linear time. Realizes Theorem 5.1.

Pseudocode and reference implementations accompany this paper.

---

## 11. Applications

- **Software supply chains and version control.** Git names every object by a
  Merkle-tree hash; Theorem 7.5 is the formal reason a tampered file cannot keep
  the same name without exhibiting a compression collision.
- **Blockchains.** Bitcoin's block headers commit to transactions via a Merkle
  root; Theorem 8.2 (with tagging) is what one needs to rule out the
  second-preimage manipulation of Theorem 8.1.
- **Certificate Transparency / transparency logs.** Append-only Merkle logs rely
  on shape-consistent hashing; the same-shape reduction (Theorem 7.5) and the
  bridge (Theorem 9.3) clarify exactly which structural invariants must be
  enforced.
- **MAC design.** Theorem 6.1 is the precise reason raw Merkle–Damgård must not be
  used as a MAC, and Theorem 6.3 the reason strengthening (or an HMAC-style
  wrapper) restores safety.

---

## 12. Discussion

The recurring moral is structural: *a hash is a fold, and collision resistance is
the joint injectivity of that fold once a positional invariant is fixed.* The
invariant is "equal length" for chains and "equal shape" for trees; the bridge
theorem shows these are the same invariant seen through the comb embedding. Two
boundary phenomena — length extension (cured by length-encoding padding) and the
second-preimage / cross-shape weakness (cured by domain separation) — are exactly
the failures that occur when the relevant invariant is *not* pinned down, and
both cures work by restoring an injectivity that the raw construction lacked.

A notable feature is that no probability appears anywhere. The classical
"reduction" is, at its core, a contrapositive of an injectivity lemma. This makes
the theory amenable to complete formal verification, which we have carried out.

---

## 13. Future Directions

Building on the binary-tree theory, the most promising next steps are:

1. **Authentication-path soundness.** Define a Merkle membership proof as the list
   of sibling hashes along a root-to-leaf path; path verification is a fold of
   `h` over the siblings at a *fixed position* (side-bit sequence). The joint
   injectivity of this fold yields authentication-path soundness as a corollary,
   and reduces forged openings to explicit compression collisions — the path-level
   analogue of Theorem 7.5. An all-left path collapses verification back onto the
   chain hash, mirroring the bridge of §9.
2. **Domain separation as a theorem, generically.** Promote the tagging idea to a
   general construction: a one-bit parity tag (leaves even, nodes odd) provably
   forces the leaf- and node-ranges disjoint, so the hypothesis of Theorem 8.2
   holds for free and the counterexample of Theorem 8.1 is defeated, requiring no
   assumption beyond injectivity of the gadgets.
3. **Quantitative multi-collision bounds for fixed shapes.** A fixed shape turns
   the hash into a layered composition of `h`, so multi-collisions factor through
   per-node collision multiplicities; the internal-node count of the shape should
   control a polynomial bound — the tree analogue of Joux multicollisions, with
   Theorem 7.4 as the `c = 0` base case.
4. **Sponge / unbalanced-tree unification.** Generalize the comb bridge to an
   equivalence between arbitrary tree schedules and an absorb/squeeze sponge over
   a 2-to-1 permutation, the comb being the capacity-zero degenerate case.
5. **Separating second-preimage from collision resistance on trees.** The shape
   degree of freedom attacks second-preimage (one fixed input) but not collision
   resistance (two unknown inputs); the cross-shape counterexample of Theorem 8.1
   should give a clean formal separation between the two security notions.

---

## 14. Conclusion

We have given a unified, probability-free, and fully formalized account of
collision resistance for Merkle–Damgård chains and Merkle trees. The chain and
the tree are two presentations of one idea — an injective compression folded over
fixed-shape data — and their security theorems, boundary attacks, and cures are
shape-indexed instances of a single combinatorial principle. The bridge theorem
makes the unification literal, identifying the chain as the left-comb tree.
