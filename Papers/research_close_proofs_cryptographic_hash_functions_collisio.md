# Collision Resistance of the Merkle–Damgård Construction: A Purely Combinatorial Formalization

## Abstract

The Merkle–Damgård construction is the structural backbone of nearly every
deployed cryptographic hash function, including the SHA-1 and SHA-2 families.
Its central security guarantee — that the iterated hash inherits the collision
resistance of its fixed-size compression function — is classically stated in the
probabilistic, asymptotic language of computational reductions. We give a
fully rigorous, machine-verified account of this guarantee that strips away the
probabilistic scaffolding and exposes its logical core: collision resistance
preservation is, at bottom, a statement about the *joint injectivity of a left
fold*. We prove (i) that an injective compression function yields a hash that is
injective on equal-length messages; (ii) the contrapositive security reduction,
that any equal-length hash collision exhibits an explicit compression-function
collision; (iii) a *constructive* convergence lemma that localizes the collision
to a specific compression step with a shared block input; (iv) the
length-extension identity, which exhibits the well-known boundary weakness of
plain Merkle–Damgård; and (v) that *Merkle–Damgård strengthening* — prepending
or appending an injective, length-regularizing padding — extends collision
resistance to messages of arbitrary length. All results are theorems about
lists and functions over arbitrary types, requiring no probability theory,
oracle model, or complexity assumption. We discuss the algorithmic content of
the reduction, its relationship to the broader landscape of hardness-based hash
design, and concrete extensions to binary Merkle hash trees.

---

## 1. Introduction

A cryptographic hash function `H` maps arbitrary-length inputs to fixed-length
digests. Its defining security property is **collision resistance**: it should
be computationally infeasible to find `m₁ ≠ m₂` with `H(m₁) = H(m₂)`. Because a
function with an infinite domain and finite range *must* have collisions by the
pigeonhole principle, collision resistance is necessarily a *computational*
rather than an information-theoretic notion in the deployed setting. The role of
a design like Merkle–Damgård is therefore not to eliminate collisions, but to
**reduce** the problem of finding a collision in `H` to the problem of finding a
collision in a much smaller, fixed-size primitive — the compression function —
which can then be subjected to focused cryptanalysis.

This paper isolates and formally verifies the *combinatorial kernel* of that
reduction. The key conceptual observation is that the Merkle–Damgård iteration
is exactly a left fold (`foldl`) of the compression function over the list of
message blocks, and that the security reduction is the contrapositive of an
**injectivity** statement about that fold. By working with injectivity rather
than probabilistic infeasibility, we obtain statements that are unconditional,
constructive where it matters, and verified to the last inference. Every theorem
below has been mechanically checked; this paper presents the mathematics and
proof sketches in standard notation.

### 1.1 Contributions

1. A one-line formal definition of the construction as `foldl`, with its basic
   algebraic laws (empty, cons, append/domain-extension).
2. The core lemma **joint injectivity of `foldl`** (Theorem 4.1), from which all
   security results descend.
3. **Collision-resistance preservation** in positive form (Theorem 5.1) and as
   a security reduction (Theorem 5.2).
4. A **constructive** collision-extraction lemma (Theorem 6.1) that pinpoints
   the failing compression step.
5. The **length-extension identity** (Theorem 7.1) as a formal boundary result.
6. **Strengthening**: arbitrary-length collision resistance from injective,
   length-regular padding (Theorem 8.1).

---

## 2. Preliminaries and Notation

We work over two arbitrary types: a **state/chaining-value type** `α` and a
**block type** `β`. A message is a finite list of blocks, `msg : List β`. A
**compression function** is a map `f : α → β → α`. We write `f.uncurry` for the
associated function `α × β → α` given by `(a, b) ↦ f a b`.

`List.foldl f a₀ [b₀, b₁, …, bₙ₋₁]` denotes the left fold
`f (… f (f a₀ b₀) b₁ …) bₙ₋₁`, i.e. the running accumulator threaded
left-to-right through the list.

A function `g` is **injective** if `g x = g y → x = y`. We say a compression
function `f` is **collision-free** when `f.uncurry` is injective: distinct input
pairs `(a, b)` produce distinct outputs.

No probability, sampling, oracle, or runtime model is used anywhere in the
development; all statements are ordinary mathematical propositions about total
functions on these types.

---

## 3. The Merkle–Damgård Construction

> **Definition 3.1 (Merkle–Damgård hash).**
> For `f : α → β → α`, an initialization vector `iv : α`, and `msg : List β`,
> ```
> merkleDamgard f iv msg := msg.foldl f iv.
> ```

Three structural laws follow immediately by computation/`rfl` and a standard
fold-append lemma.

> **Lemma 3.2 (Base laws).**
> - *(Empty)* `merkleDamgard f iv [] = iv`.
> - *(Cons)* `merkleDamgard f iv (b :: msg) = merkleDamgard f (f iv b) msg`.

> **Theorem 3.3 (Domain extension / append).** For all `m₁ m₂ : List β`,
> ```
> merkleDamgard f iv (m₁ ++ m₂) = merkleDamgard f (merkleDamgard f iv m₁) m₂.
> ```
> *Proof.* Unfold to `foldl` and apply `List.foldl_append`. ∎

Theorem 3.3 is the structural heart of the construction: the digest of a prefix
is a valid initialization vector for the remainder. It powers both the security
reduction (by enabling block-by-block induction) and, as we see in §7, the
length-extension weakness.

---

## 4. The Core Lemma: Joint Injectivity of `foldl`

All security content of the construction is concentrated in a single statement.

> **Theorem 4.1 (Joint injectivity of `foldl`).**
> Let `f : α → β → α` be collision-free, i.e. `f.uncurry` injective. Then for all
> lists `l₁, l₂ : List β` with `l₁.length = l₂.length` and all states `a₁, a₂ : α`,
> ```
> l₁.foldl f a₁ = l₂.foldl f a₂   ⟹   a₁ = a₂  ∧  l₁ = l₂.
> ```

*Proof sketch.* Induct on `l₁`, generalizing over `l₂`, `a₁`, and `a₂` (the
generalization is essential — fixing the accumulators yields too weak an
induction hypothesis).

- **Base.** `l₁ = []`. The length hypothesis forces `l₂ = []`, so both folds
  equal their accumulators and `a₁ = a₂` follows from `heq`; `l₁ = l₂ = []`.
- **Step.** `l₁ = x₁ :: t₁`. The length hypothesis forces `l₂ = x₂ :: t₂`.
  Unfolding one layer,
  `t₁.foldl f (f a₁ x₁) = t₂.foldl f (f a₂ x₂)` with `t₁.length = t₂.length`.
  The induction hypothesis yields `f a₁ x₁ = f a₂ x₂` and `t₁ = t₂`. Now apply
  injectivity of `f.uncurry` to the pair equality `f a₁ x₁ = f a₂ x₂`, obtaining
  `(a₁, x₁) = (a₂, x₂)`, hence `a₁ = a₂` and `x₁ = x₂`. Combined with `t₁ = t₂`
  this gives `l₁ = l₂`. ∎

The proof is a clean "peel-one-layer" induction: equal outputs plus injectivity
recover equal penultimate states and equal final blocks, and the inductive
hypothesis recovers the rest. The equal-length hypothesis is what keeps the two
chains in lock-step.

---

## 5. Collision-Resistance Preservation

Specializing the accumulators to a shared IV gives the positive security
statement.

> **Theorem 5.1 (Preservation of injectivity).**
> If `f.uncurry` is injective, then for all `m₁ m₂ : List β` with
> `m₁.length = m₂.length`,
> ```
> merkleDamgard f iv m₁ = merkleDamgard f iv m₂   ⟹   m₁ = m₂.
> ```
> *Proof.* Apply Theorem 4.1 with `a₁ = a₂ = iv`; the right conjunct `m₁ = m₂`
> is the conclusion. ∎

The contrapositive is the reduction cryptographers invoke.

> **Theorem 5.2 (Collision reduction — main security theorem).**
> Let `f : α → β → α` and `iv : α`. If `m₁ ≠ m₂`, `m₁.length = m₂.length`, and
> `merkleDamgard f iv m₁ = merkleDamgard f iv m₂`, then there exist input pairs
> ```
> p₁ p₂ : α × β  with  p₁ ≠ p₂  and  f.uncurry p₁ = f.uncurry p₂.
> ```
> *Proof.* By contradiction. Suppose no such collision pair exists; then
> `f.uncurry` is injective (any two pairs with equal image must be equal). By
> Theorem 5.1, `m₁ = m₂`, contradicting `m₁ ≠ m₂`. ∎

Theorem 5.2 is the formal content of the slogan *"a collision in the hash is a
collision in the compression function."* It reduces an unbounded-domain security
property to a fixed-size one, which is precisely what makes Merkle–Damgård a
practical design: cryptanalytic effort can be concentrated on a single small
primitive.

---

## 6. Constructive Collision Extraction

Theorem 5.2 is non-constructive — it asserts existence of a collision via
`by_contra` — so it does not localize the failure. The following lemma is
constructive and identifies a concrete failing step. It requires only decidable
equality on the state type `α` (to perform the case split).

> **Theorem 6.1 (Constructive convergence).**
> Let `α` have decidable equality, `f : α → β → α`, `l : List β`, and `a₁ ≠ a₂`.
> If `l.foldl f a₁ = l.foldl f a₂`, then there exist `s₁ s₂ : α` and `b : β` with
> ```
> s₁ ≠ s₂   and   f s₁ b = f s₂ b.
> ```

*Proof sketch.* Induct on `l`.

- **Base.** `l = []`. Then `l.foldl f a₁ = a₁` and `l.foldl f a₂ = a₂`, so
  `a₁ = a₂`, contradicting `a₁ ≠ a₂`; the case is vacuous.
- **Step.** `l = h :: t`. Decide whether `f a₁ h = f a₂ h`.
  - If **equal**, we have found the collision directly: take `s₁ = a₁`,
    `s₂ = a₂`, `b = h`, with `a₁ ≠ a₂`.
  - If **unequal**, the two chains continue from distinct states
    `f a₁ h ≠ f a₂ h`, and `t.foldl f (f a₁ h) = t.foldl f (f a₂ h)` by the
    cons law; apply the induction hypothesis to `t`. ∎

Two features deserve emphasis. First, the extracted collision shares the **same
block** `b` on both sides — the chains were fed identical data yet still merged,
so the collision is a collapse of two distinct *chaining values*. This is the
internal-state collision that practical cryptanalysis targets. Second, unlike
Theorem 5.2 this lemma is fully constructive, producing the witnesses
explicitly by walking the chain.

---

## 7. Boundary Result: Length Extension

The append law (Theorem 3.3) re-emerges as a *vulnerability* when interpreted
adversarially.

> **Theorem 7.1 (Length-extension identity).**
> For all `m₁, s : List β`,
> ```
> merkleDamgard f iv (m₁ ++ s) = merkleDamgard f (merkleDamgard f iv m₁) s.
> ```
> *Proof.* Immediate from Theorem 3.3. ∎

**Cryptographic reading.** Because the published digest *is* the final chaining
value, an adversary who knows `h = merkleDamgard f iv m₁` (but not `m₁`) can
compute `merkleDamgard f iv (m₁ ++ s)` for any chosen suffix `s` by folding `s`
onto `h`. This is the length-extension attack and it is structural: it depends
on no weakness of `f`. It is the reason secret-prefix MACs `hash(secret ‖ msg)`
are insecure and motivates HMAC and the finalization steps of modern designs.
Note this property does **not** contradict §5: Theorems 5.1–5.2 are about
*equal-length* messages, while length extension exploits *length variation*.

---

## 8. Merkle–Damgård Strengthening

The equal-length restriction is removed by padding the message with a
length-regularizing, injective encoding before hashing.

> **Definition 8.1 (Strengthened hash).** For a padding map `pad : List β → List β`,
> ```
> mdStrengthen f pad iv msg := merkleDamgard f iv (pad msg).
> ```

> **Theorem 8.2 (Strengthened collision resistance).**
> Suppose
> 1. `f.uncurry` is injective (collision-free compression);
> 2. `pad` is injective; and
> 3. `pad` is **length-regular**: `(pad m₁).length = (pad m₂).length` for all
>    `m₁, m₂`.
>
> Then for all messages `m₁, m₂` (of *arbitrary*, possibly different lengths),
> ```
> mdStrengthen f pad iv m₁ = mdStrengthen f pad iv m₂   ⟹   m₁ = m₂.
> ```

*Proof.* Unfolding, the hypothesis is
`merkleDamgard f iv (pad m₁) = merkleDamgard f iv (pad m₂)`. By length-regularity
(3), `(pad m₁).length = (pad m₂).length`, so Theorem 5.1 applies to the padded
messages and yields `pad m₁ = pad m₂`. Injectivity of `pad` (2) then gives
`m₁ = m₂`. ∎

Length-regularity is the abstract counterpart of the classical "append the
message bit-length" trick: it ensures that *any* two padded messages can be
compared with the equal-length theorem, while injectivity of `pad` guarantees no
two distinct messages are conflated by the encoding. Together they defeat the
length-extension family at the level of collision resistance.

---

## 9. Algorithmic Content

The development carries direct algorithmic meaning, summarized as three
procedures.

**(A) Hashing.** `merkleDamgard` *is* the streaming hash algorithm: maintain a
state, fold each block in via `f`, output the final state. It is online
(one pass, constant memory beyond the state) — the practical reason
Merkle–Damgård dominates real designs.

**(B) Collision reduction (Theorem 5.2).** Given a full-hash collision
`(m₁, m₂)`, the reduction guarantees a compression collision. Algorithmically:
recompute both chains, walk them in parallel from the common final digest
backward (or forward, per Theorem 6.1), and emit the first index where two
distinct chaining values map to the same successor under the same block. This is
an `O(n)` extraction in the message length.

**(C) Strengthened hashing (Definition 8.1).** Apply a length-encoding pad, then
run (A). The proof of Theorem 8.2 doubles as a correctness argument that the
extra padding never sacrifices the equal-length guarantee.

---

## 10. Applications

- **Standardized hash functions.** SHA-1, SHA-224/256/384/512, MD5, and RIPEMD
  are Merkle–Damgård designs with length strengthening; Theorem 5.2 is the
  precise sense in which their security is "as good as" their compression
  functions, and Theorem 8.2 is the role played by their length padding.
- **Digital signatures and certificates.** Hash-then-sign relies on collision
  resistance of the full-domain hash; the reduction lets implementers inherit
  that property from a vetted compression core.
- **Commitment schemes and Merkle trees.** Binding of hash-based commitments and
  the soundness of Merkle authentication paths reduce, link by link, to
  compression collisions — the same template as Theorem 5.2.
- **Cryptanalysis triage.** Theorem 6.1's constructive, same-block collision is
  exactly the internal-state collision sought by differential and
  meet-in-the-middle attacks, clarifying *what* an attacker must produce.

---

## 11. Related Work and Discussion

The Merkle–Damgård reduction dates to the independent 1989 works of Merkle and
Damgård and is textbook material in its probabilistic formulation. Our
contribution is to show that the *collision-resistance-preservation* portion is
unconditionally true as a combinatorial fact, independent of any computational
model: injectivity in, injectivity out. This separation is methodologically
useful — it isolates exactly which parts of hash-function security are "free"
(structural) and which require genuine hardness assumptions (the collision
resistance of the compression function itself, which is *not* and cannot be
proved unconditionally for a fixed finite primitive).

A subtlety worth stating plainly: collision *resistance* of a concrete,
fixed-size compression function is a computational assumption, not a theorem —
no finite function is literally injective once its domain exceeds its range. The
results here should therefore be read as a faithful formalization of the
*reduction* ("security transfers from part to whole"), with the injectivity
hypothesis serving as the idealized stand-in for "no collision has been found."
This is the standard and correct way to factor hash-function security.

---

## 12. Future Directions

This work extended the linear Merkle–Damgård collision-resistance theory
(`merkleDamgard`, joint `foldl` injectivity, the compression-collision
reduction) toward *binary hash trees*. A companion development of tree hashing
establishes injectivity of the tree hash on same-shape trees; a security
reduction turning any tree collision into a leaf-map or compression collision;
full cross-shape injectivity once leaf- and node-hashes are domain-separated;
the identification of Merkle–Damgård as the *left-comb* (linear) special case of
tree hashing; and a boundary counterexample showing that the
same-shape/domain-separation hypotheses are necessary. Two concrete, falsifiable
directions stand out.

**Direction 1: Quantitative multi-collision bounds for shaped trees.**
*Conjecture:* for a compression `h` with at most `c` collision pairs, the number
of distinct trees of a *fixed* shape `S` with `n` leaves sharing a common root
hash is bounded by a polynomial `P_S(c, n)` whose degree equals the number of
internal nodes of `S`, and this bound is tight for balanced shapes. A fixed
shape turns the hash into a *layered* composition of `h`, so multi-collisions
factor through per-node collision multiplicities, with the internal-node count
controlling how multiplicities multiply. This upgrades the qualitative tree
reduction to a counting statement — the tree analogue of Joux multicollisions
for Merkle–Damgård. The same-shape injectivity result is exactly the `c = 0`
base case, and its peel-one-`h`-layer/recurse-on-subtrees skeleton is the
natural carrier for a multiplicity-counting induction.

**Direction 2: Length/shape-tagging realizes domain separation generically.**
*Conjecture:* for any injective leaf map `g` and injective node hash `h`, a
*tagged* tree hash that writes leaf and node outputs into disjoint tag classes
automatically satisfies the domain-separation hypothesis of the cross-shape
injectivity theorem, hence is fully (cross-shape) collision resistant with no
extra assumption beyond injectivity of `g` and `h`. The abstract obstruction in
the cross-shape counterexample is precisely the *overlap* between the range of
`g` and the range of `h`; a one-bit tag forces these ranges disjoint, so domain
separation becomes a free encoding transformation rather than an added
hypothesis.

Further directions include: formalizing concrete padding schemes (the exact
SHA-2 length encoding) and discharging length-regularity for them; modeling
HMAC/keyed constructions and proving they resist length extension; and
sponge/Keccak-style constructions where the security argument has a different
(indifferentiability) flavour.

---

## 13. Conclusion

We have given a complete, machine-verified, and entirely combinatorial account
of why the Merkle–Damgård construction preserves collision resistance. The whole
theory pivots on one lemma — joint injectivity of a left fold — from which the
positive preservation theorem, the security reduction, a constructive collision
extractor, the length-extension boundary identity, and the strengthening theorem
all follow. The take-away is conceptual as much as technical: the famous
cryptographic reduction "a collision in the whole is a collision in the part" is
not merely a heuristic or an asymptotic claim, but an exact logical fact about
folding functions over lists — and it has now been certified as such.
