# Merkle–Damgård as a Monoid Action: An Algebra ⇄ Cryptography Bridge

## Abstract

The Merkle–Damgård construction is the structural backbone of widely deployed
cryptographic hash functions, including MD5 and the SHA-2 family. Its classical
security analysis proves a *reduction*: any collision in the full, unbounded-length
hash yields a collision in the underlying fixed-size compression function, so the
security of the whole rests on the security of a small, scrutinizable part. This
paper recasts that analysis in the language of abstract algebra. We observe that a
message is most naturally viewed not as data but as a **state transformation** — an
endomorphism of the chaining-state space — and that message concatenation
corresponds to composition of these transformations *in reverse order*. This makes
the classical domain-extension lemma an instance of a multiplication law, and
packages the entire construction as a single **monoid homomorphism**
`mdHom : FreeMonoid β →* (Function.End α)ᵐᵒᵖ` from the free monoid of message blocks
into the opposite of the endomorphism monoid of the state space. Under this lens,
collision resistance is exactly **faithfulness** of the induced action. We prove
that injectivity of the compression function, over a nonempty state space, yields a
strictly stronger, *initialization-vector-independent* collision-resistance theorem
than the classical fixed-IV statement: equal-length messages inducing the same
transformation must be equal. We show the converse fails — faithfulness does not
force injectivity of the compression function, because the action only sees
reachable chaining values — and we lift the entire framework one rung up the
structural ladder from chains (linear hashing) to trees (Merkle-tree hashing),
proving collision resistance for trees of a fixed shape as the free-magma analogue.
All results are fully formalized; this paper states each definition and theorem
inline with a self-contained proof sketch.

**Keywords:** Merkle–Damgård, collision resistance, monoid action, free monoid,
monoid homomorphism, faithful action, hash functions, Merkle trees, domain
separation.

---

## 1. Introduction

### 1.1 The bootstrapping problem

A cryptographic hash function maps inputs of arbitrary length to fixed-length
digests, and must be **collision resistant**: it should be computationally
infeasible to find distinct inputs `x ≠ y` with `H(x) = H(y)`. The central design
tension is that we can design and analyze only *fixed-size* primitives well, yet a
hash must accept arbitrarily long inputs. The Merkle–Damgård construction resolves
this by iterating a fixed-size **compression function** `f` over message blocks,
threading a running **chaining state** from a public **initialization vector (IV)**.

The classical security theorem is a *reduction*: a collision in the iterated hash
implies a collision in `f`. Consequently, the entire scheme inherits the collision
resistance of its compression function. This is the reasoning that underpins
MD5, SHA-1, and SHA-2.

### 1.2 Contribution

This paper makes the algebra latent in that reduction explicit. The contributions
are:

1. **An action-theoretic reformulation.** A message `m` is reinterpreted as the
   self-map `a ↦ merkleDamgard f a m` of the state space, an element of the
   endomorphism monoid `Function.End α`. Domain extension becomes an
   anti-homomorphism law (Section 4).

2. **A single algebraic object.** The whole construction is packaged as a monoid
   homomorphism `mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ` into the *opposite*
   endomorphism monoid (Section 5). The opposite is forced by the reversed
   composition order.

3. **An IV-independent strengthening.** Faithfulness of the action on equal-length
   words is shown equivalent to a collision-resistance statement holding for *all*
   IVs simultaneously, strictly stronger than the classical fixed-IV theorem
   (Section 6).

4. **A sharp converse.** We show faithfulness does *not* imply injectivity of the
   compression function, isolating the role of *reachable* chaining states
   (Section 7).

5. **A structural lift to trees.** The same recursion — *shape determines
   structure, injectivity peels one layer* — proves collision resistance for
   Merkle trees of a fixed shape, the free-magma analogue of the linear case
   (Section 8).

Throughout, `α` is the type of chaining states, `β` the type of message blocks,
and `f : α → β → α` the compression function.

---

## 2. The Merkle–Damgård construction

**Definition 2.1 (Merkle–Damgård hash).**
For a compression function `f : α → β → α`, an IV `iv : α`, and a message
`msg : List β`, define
```
merkleDamgard f iv msg := msg.foldl f iv,
```
the left fold of the blocks of `msg` into `iv` using `f`.

The fold processes blocks left to right: starting from `iv`, each block `b`
updates the state via `a ↦ f a b`.

**Proposition 2.2 (boundary laws).**
1. `merkleDamgard f iv [] = iv` (empty message returns the IV).
2. `merkleDamgard f iv (b :: msg) = merkleDamgard f (f iv b) msg` (one step).

*Proof.* Both are definitional unfoldings of `List.foldl`. ∎

**Theorem 2.3 (Domain extension).**
For all messages `m₁, m₂`,
```
merkleDamgard f iv (m₁ ++ m₂) = merkleDamgard f (merkleDamgard f iv m₁) m₂.
```

*Proof sketch.* `List.foldl` over a concatenation splits: folding `m₁ ++ m₂` from
`iv` equals folding `m₂` from the result of folding `m₁` from `iv`. This is the
standard `List.foldl_append` identity. ∎

Theorem 2.3 is the structural heart of the construction: the only information that
crosses the boundary between `m₁` and `m₂` is the single intermediate chaining
state. It is also the seed of the algebraic reformulation (Section 4) and the cause
of the length-extension vulnerability (Section 3.4).

---

## 3. Classical collision-resistance theory

### 3.1 Joint injectivity of the fold

The technical engine of the whole theory is a statement about left folds. We say
`f` is injective *as a pair function* when `Function.uncurry f : α × β → α`,
`(a, b) ↦ f a b`, is injective.

**Theorem 3.1 (Joint injectivity of foldl).**
If `Function.uncurry f` is injective, and `l₁, l₂ : List β` satisfy
`l₁.length = l₂.length` and `l₁.foldl f a₁ = l₂.foldl f a₂`, then
```
a₁ = a₂  and  l₁ = l₂.
```

*Proof sketch.* Induct on `l₁`, generalizing `l₂`, `a₁`, `a₂`.
- **Base.** `l₁ = []`; by the length hypothesis `l₂ = []`, and the fold equation
  reduces to `a₁ = a₂`.
- **Step.** `l₁ = h₁ :: t₁`, `l₂ = h₂ :: t₂`. The fold equation becomes
  `t₁.foldl f (f a₁ h₁) = t₂.foldl f (f a₂ h₂)`. The inductive hypothesis (with
  the new accumulators `f a₁ h₁` and `f a₂ h₂`) yields `f a₁ h₁ = f a₂ h₂` and
  `t₁ = t₂`. Injectivity of `Function.uncurry f` applied to `f a₁ h₁ = f a₂ h₂`
  gives `(a₁, h₁) = (a₂, h₂)`, i.e. `a₁ = a₂` and `h₁ = h₂`. Hence `l₁ = l₂`. ∎

The generalization over `a₁, a₂` is essential: without it the inductive hypothesis
is too weak to peel off the chaining state.

### 3.2 Preservation of collision resistance

**Theorem 3.2 (MD preserves injectivity).**
If `Function.uncurry f` is injective then, for any fixed `iv`, the map
`merkleDamgard f iv` is injective on equal-length messages: if
`m₁.length = m₂.length` and `merkleDamgard f iv m₁ = merkleDamgard f iv m₂`, then
`m₁ = m₂`.

*Proof.* Apply Theorem 3.1 with `a₁ = a₂ = iv`; its conclusion gives `m₁ = m₂`
directly. ∎

### 3.3 The collision reduction

**Theorem 3.3 (Collision reduction — main security theorem).**
For any `f` and `iv`, if `m₁ ≠ m₂` have equal length and
`merkleDamgard f iv m₁ = merkleDamgard f iv m₂`, then there exist pairs
`p₁ ≠ p₂ : α × β` with `Function.uncurry f p₁ = Function.uncurry f p₂`.

*Proof sketch.* Contrapositive of Theorem 3.2. Suppose `f` had no pair collision,
i.e. `Function.uncurry f` is injective. Then Theorem 3.2 forces `m₁ = m₂`,
contradicting `m₁ ≠ m₂`. Hence a pair collision exists. ∎

This is the reduction in its cryptographically meaningful form: *breaking the full
hash requires breaking the compression function.*

**Theorem 3.4 (Constructive convergence).**
Assume `α` has decidable equality. If `a₁ ≠ a₂` but `l.foldl f a₁ = l.foldl f a₂`,
then there exist states `s₁ ≠ s₂` and a block `b` with `f s₁ b = f s₂ b`.

*Proof sketch.* Induct on `l`. If `l = []`, the hypothesis gives `a₁ = a₂`,
contradicting `a₁ ≠ a₂`. If `l = h :: t`, split on whether `f a₁ h = f a₂ h`: if
so, take `s₁ = a₁`, `s₂ = a₂`, `b = h`. Otherwise the new states `f a₁ h ≠ f a₂ h`
still fold over `t` to a common value, and the inductive hypothesis applies. ∎

Unlike Theorem 3.3, this extraction is constructive and locates the collision at a
specific step; moreover the collision it produces always uses the *same block* on
both sides, isolating the disagreement in the chaining state.

### 3.4 Length extension and strengthening

**Theorem 3.5 (Length extension).**
For any suffix `s`,
```
merkleDamgard f iv (m₁ ++ s) = merkleDamgard f (merkleDamgard f iv m₁) s.
```

*Proof.* Immediate from Theorem 2.3. ∎

This is a vulnerability without padding: knowing only `merkleDamgard f iv m₁`
suffices to compute the hash of `m₁ ++ s` for attacker-chosen `s`, without knowing
`m₁`. Real constructions defeat this by padding inputs with an encoding of their
length (**Merkle–Damgård strengthening**).

**Definition 3.6 (strengthened MD).**
For a padding function `pad : List β → List β`, set
```
mdStrengthen f pad iv msg := merkleDamgard f iv (pad msg).
```

**Theorem 3.7 (Strengthened collision resistance).**
If `Function.uncurry f` is injective, `pad` is injective, and `pad` is
length-regular (`(pad m₁).length = (pad m₂).length` for all `m₁, m₂`), then
`mdStrengthen f pad iv` is injective on *all* messages: if
`mdStrengthen f pad iv m₁ = mdStrengthen f pad iv m₂` then `m₁ = m₂`.

*Proof sketch.* Length-regularity makes `pad m₁`, `pad m₂` equal-length, so
Theorem 3.2 gives `pad m₁ = pad m₂`; injectivity of `pad` then gives `m₁ = m₂`. ∎

Padding upgrades same-length security to all-length security, eliminating the
length-extension attack at the cost of an injective, length-regular pad.

---

## 4. Messages as state transformations

We now change viewpoint: fix `f` and treat a message as a function of the IV.

**Definition 4.1 (state transformation of a message).**
```
mdEnd f m := fun a => merkleDamgard f a m  : Function.End α,
```
the self-map of the state space sending each chaining value `a` to the hash of `m`
started from `a`. Here `Function.End α` is the monoid of self-maps under
composition, with identity the do-nothing map and multiplication `g * h = g ∘ h`.

**Proposition 4.2.** `mdEnd f m a = merkleDamgard f a m` (definitional), and
`mdEnd f [] = 1` (the empty message is the identity transformation, since
`merkleDamgard f a [] = a`).

**Theorem 4.3 (Action / anti-homomorphism law).**
```
mdEnd f (m₁ ++ m₂) = mdEnd f m₂ * mdEnd f m₁     (in Function.End α),
```
i.e. `mdEnd f (m₁ ++ m₂) = mdEnd f m₂ ∘ mdEnd f m₁`.

*Proof sketch.* Evaluate both sides at an arbitrary `a`. The right side is
`mdEnd f m₂ (mdEnd f m₁ a) = merkleDamgard f (merkleDamgard f a m₁) m₂`, which by
domain extension (Theorem 2.3) equals `merkleDamgard f a (m₁ ++ m₂) =
mdEnd f (m₁ ++ m₂) a`. ∎

Theorem 4.3 is Theorem 2.3 in algebraic clothing. The composition order is
*reversed*: to apply the transformation of `m₁ ++ m₂`, one must run `m₁` first and
`m₂` second, so `mdEnd f m₁` is applied *innermost*. This reversal is the reason
the natural codomain is the opposite monoid (Section 5).

---

## 5. The Merkle–Damgård homomorphism

Let `FreeMonoid β` denote the free monoid on `β`: finite sequences of blocks under
concatenation, with the empty sequence as identity. It is definitionally `List β`,
with `FreeMonoid.toList` the underlying list and multiplication given by
concatenation (`(x * y).toList = x.toList ++ y.toList`). For a monoid `M`, the
**opposite monoid** `Mᵐᵒᵖ` has the same underlying set with multiplication
reversed; `MulOpposite.op : M → Mᵐᵒᵖ` and `MulOpposite.unop : Mᵐᵒᵖ → M` are the
mutually inverse coercions.

**Definition 5.1 (Merkle–Damgård homomorphism).**
```
mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ,
   mdHom f m := MulOpposite.op (mdEnd f m.toList).
```

**Theorem 5.2.** `mdHom f` is a monoid homomorphism:
`mdHom f 1 = 1` and `mdHom f (x * y) = mdHom f x * mdHom f y`.

*Proof sketch.*
- *Unit.* `(1 : FreeMonoid β).toList = []`, so `mdEnd f [] = 1` (Proposition 4.2)
  and `op 1 = 1`.
- *Multiplication.* `(x * y).toList = x.toList ++ y.toList`, so by Theorem 4.3
  `mdEnd f (x*y).toList = mdEnd f y.toList * mdEnd f x.toList`. Applying `op`,
  which *reverses* multiplication (`op (g * h) = op h * op g` in `Mᵐᵒᵖ` becomes
  the desired order), gives `mdHom f x * mdHom f y`. The opposite monoid exactly
  absorbs the reversal from Theorem 4.3. ∎

Targeting `Function.End α` directly fails here: the reversed order in Theorem 4.3
would make `map_mul` ill-typed. The opposite monoid is forced by the mathematics,
not chosen for convenience.

**Proposition 5.3 (evaluation recovers the hash).**
```
(mdHom f m).unop iv = merkleDamgard f iv m.toList.
```

*Proof.* Unfolding: `(op (mdEnd f m.toList)).unop iv = mdEnd f m.toList iv =
merkleDamgard f iv m.toList`. ∎

Thus the entire construction — the IV, the fold, domain extension — is repackaged
as one structure-preserving map, and ordinary hashing is its evaluation at a
chosen IV.

---

## 6. Faithfulness = collision resistance (IV-free)

An action of a monoid on a set is **faithful** when distinct elements act as
distinct maps. For `mdEnd`, faithfulness on equal-length words says: equal-length
messages inducing the same transformation are equal. This is exactly collision
resistance, now stated independently of any IV.

**Theorem 6.1 (Faithful action ⇒ collision resistance, IV-free).**
Suppose `α` is nonempty and `Function.uncurry f` is injective. If
`m₁.length = m₂.length` and `mdEnd f m₁ = mdEnd f m₂`, then `m₁ = m₂`.

*Proof sketch.* Since `α` is nonempty, choose `a : α`. Function equality
`mdEnd f m₁ = mdEnd f m₂` gives, in particular, `mdEnd f m₁ a = mdEnd f m₂ a`,
i.e. `m₁.foldl f a = m₂.foldl f a`. Now apply joint injectivity (Theorem 3.1) with
`a₁ = a₂ = a`; its second conclusion is `m₁ = m₂`. ∎

**Theorem 6.2 (Homomorphism form).**
Under the same hypotheses, if `m₁.toList.length = m₂.toList.length` and
`mdHom f m₁ = mdHom f m₂` (as elements of `(Function.End α)ᵐᵒᵖ`), then
`m₁ = m₂`. That is, `mdHom f` is injective on words of any fixed length.

*Proof sketch.* `MulOpposite.op` is injective, so `mdHom f m₁ = mdHom f m₂` gives
`mdEnd f m₁.toList = mdEnd f m₂.toList`. Theorem 6.1 yields
`m₁.toList = m₂.toList`, and `FreeMonoid.toList` is injective, so `m₁ = m₂`. ∎

**Comparison with the classical theorem.** Theorem 3.2 fixes a single IV: "for
this `iv`, the hash separates equal-length messages." Theorem 6.1 demands equality
*as functions of all IVs at once*. The action statement is strictly stronger: it is
the whole family of fixed-IV statements, bundled, plus the assertion that they hold
*uniformly*. The proof, by contrast, is a one-line evaluation rather than a fresh
induction — the structural work was already done by Theorem 3.1, and the action
language makes the upgrade transparent. The only new hypothesis, nonemptiness of
`α`, is genuinely necessary: over the empty state space every self-map is vacuously
equal, so no action could be faithful regardless of `f`.

---

## 7. The converse fails

It is tempting to conjecture that faithfulness is *equivalent* to injectivity of
`f`. It is not.

**Theorem 7.1 (Faithfulness does not imply injectivity).**
There exists a nonempty state space `α` and a *non-injective* compression function
`f : α → β → α` whose action is nevertheless faithful on equal-length words.

*Proof sketch (construction).* Take a single-block alphabet, `β` a one-element
type. Then for any fixed length `n` there is exactly one block sequence of length
`n`, so equal-length messages are *automatically* identical. Faithfulness on
equal-length words is therefore vacuously true — for *any* `f`, including
non-injective ones (choose `α` with at least two elements and `f` constant in its
state argument so that `Function.uncurry f` is not injective). ∎

**Interpretation.** The action observes `f` only through the chaining values that
messages actually *reach*. Collisions of `f` that occur only among *unreachable*
states are invisible to the action. Faithfulness is thus a statement about
reachable behavior, strictly weaker than global injectivity of `f`. This is the
precise sense in which collision resistance of the iterated hash can hold even when
the compression function is, in isolation, not injective — provided its collisions
never materialize on reachable states.

---

## 8. From chains to trees

Linear Merkle–Damgård is the *path-graph* special case of **Merkle-tree hashing**,
in which data sits at leaves and each internal node hashes its children's digests.
We record the tree generalization.

**Definition 8.1 (binary hash tree and tree hash).**
Let a binary tree be either a leaf carrying a block, or a node with two subtrees.
Given a leaf map and an injective node combiner `g` (combining two child digests
into a parent digest), `treeHash` folds the tree bottom-up: leaves map to digests,
and each node maps to `g` of its children's digests. The **shape** of a tree is its
underlying unlabeled tree structure (which leaves/nodes occur where, forgetting the
data).

**Theorem 8.2 (Tree collision resistance, fixed shape).**
If the node combiner is injective (as a pair function) and the leaf map is
injective, then `treeHash` is injective on trees of a fixed shape: two trees of the
*same shape* with the same root digest are identical.

*Proof sketch.* Structural induction on the shared shape — the free-*magma*
analogue of Theorem 3.1.
- **Leaf.** Equal root digests of two leaves force equal leaf data by injectivity
  of the leaf map.
- **Node.** Two nodes of the same shape have equal root digests `g(L₁, R₁) =
  g(L₂, R₂)`. Injectivity of `g` gives `L₁ = L₂` and `R₁ = R₂` (equal left and
  right child digests). The subtrees have equal shapes by hypothesis, so the
  inductive hypothesis applies to each side, yielding equal subtrees and hence
  equal trees. ∎

The recursion is identical in spirit to the linear case — *shape determines
structure, injectivity peels one layer* — but branches rather than marching
linearly: a free monoid (lists) is replaced by a free magma (binary trees).

**Necessity of the shape hypothesis.** Dropping "same shape" makes Theorem 8.2
false: a leaf can collide with an internal node whose combined digest happens to
equal the leaf's digest. This motivates **domain separation** (Section 9): tagging
inputs by kind so that, e.g., leaves and nodes inhabit disjoint digest ranges.

---

## 9. Discussion and applications

**Conceptual payoff.** The reformulation identifies three classical facts with
three algebraic ones:

| Cryptographic statement | Algebraic statement |
|---|---|
| Domain extension (Thm 2.3) | Anti-homomorphism law (Thm 4.3) |
| The whole MD construction | A monoid homomorphism `mdHom` (Thm 5.2) |
| Collision resistance | Faithfulness of the action (Thm 6.1) |

The dictionary is not merely cosmetic: it produces the strictly stronger IV-free
theorem (Thm 6.1) for free, and it locates the exact boundary where the analogy
stops (Thm 7.1).

**Why the opposite monoid.** The reversed composition order in Theorem 4.3 is a
genuine feature of left-to-right processing. The opposite monoid `(Function.End α)ᵐᵒᵖ`
is the canonical device for turning an anti-homomorphism into a homomorphism, and
its appearance is forced, not stylistic.

**Engineering relevance.** The IV-independence of Theorem 6.1 matters when a system
uses many IVs (keyed hashing, tree modes, parallel hashing with distinct
initialization). It guarantees collision resistance uniformly across IVs from a
single injectivity assumption on `f`. The tree result (Theorem 8.2) models the
integrity guarantees of Merkle trees used in blockchains, certificate transparency
logs, and content-addressed storage.

**Limits.** Theorem 7.1 cautions that injectivity of `f` is sufficient but not
necessary for faithfulness; reasoning about *reachable* states can certify security
for compression functions that are not globally injective. Conversely, the
same-shape and same-length hypotheses are not removable without padding/domain
separation, which is precisely how deployed hashes are hardened.

---

## 10. Future directions

- **Domain separation conjecture.** Theorem 8.2 needs the same-shape hypothesis.
  Formalize tagging schemes (leaf vs. node tags, length tags) under which the
  hypothesis can be dropped, recovering shape-free tree collision resistance — the
  tree analogue of Merkle–Damgård strengthening (Theorem 3.7).

- **Reachability-aware security.** Theorem 7.1 shows faithfulness depends only on
  reachable chaining states. Develop a quantitative theory of the reachable
  sub-monoid generated by `mdEnd`, characterizing exactly which compression
  functions yield faithful actions.

- **Sponge and other modes.** Reinterpret alternative iterated constructions
  (sponge/Keccak, HAIFA, tree modes) as actions of suitable algebraic structures,
  seeking analogous homomorphism packagings and faithfulness criteria.

- **Quantitative collision resistance.** The present theory is exact (zero
  collisions from injective primitives). Bridge to the probabilistic setting by
  measuring deviation from faithfulness for near-injective compression functions.

---

## 11. Conclusion

By viewing a message as a state transformation rather than as inert data, the
Merkle–Damgård construction reveals itself as a monoid homomorphism from the free
monoid of blocks into the opposite endomorphism monoid of the state space. In this
language, domain extension is a multiplication law and collision resistance is
faithfulness — and the dictionary pays off concretely, yielding an
initialization-vector-independent strengthening of the classical security theorem,
a precise account of where faithfulness diverges from injectivity, and a clean lift
from linear hashing to Merkle trees. The mathematics that secures digital
signatures, software updates, and blockchains is, at bottom, the algebra of words
acting on states.
