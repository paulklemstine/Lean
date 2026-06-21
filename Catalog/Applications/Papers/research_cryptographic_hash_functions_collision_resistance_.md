# Collision Resistance from Algebraic Hardness: A Constructive Merkle–Damgård Reduction

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Cryptography / Number Theory

---

## Abstract

We give a self-contained, fully constructive development of the classical
theorem that the Merkle–Damgård (MD) iterated-hash construction *preserves
collision resistance*, and we connect it to an explicit algebraic hardness
source. We define the MD hash as a left fold of a compression function
$f : \mathrm{State} \times \mathrm{Block} \to \mathrm{State}$ over a message,
starting from an initialization vector, and prove its basic algebraic laws
(empty message, last-block, and concatenation). Our central result,
**collision extraction**, shows that any collision of the iterated hash on two
distinct *equal-length* messages can be transformed, by an explicit
deterministic procedure, into a collision of the compression function $f$. The
reduction is purely combinatorial and uses no probability. We further show that
the equal-length hypothesis is tight: a length-extension example collides for
reasons unrelated to compression strength, motivating the standard
length-padding ("MD strengthening") fix. Independently, a pigeonhole argument
shows that compression *forces* collisions to exist, sharpening the meaning of
collision resistance to *finding*, not *existence*. Finally, we instantiate the
framework with the multiplicative compression function
$\mathrm{mulCompress}(s,b) = s\cdot b$, whose iterate is the list product, and
prove that an algebraic *product collision* (non-unique factorization) maps
verbatim onto a compression collision, hence onto a full MD hash collision. The
catalog witness $6 \cdot 35 = 10 \cdot 21 = 210$ exercises the entire pipeline
end to end. All results are formalized and machine-checked, free of unproven
assumptions.

---

## 1. Introduction

A *cryptographic hash function* maps arbitrary-length messages to fixed-length
digests. *Collision resistance* — the infeasibility of producing two distinct
messages with equal digest — underpins digital signatures, commitment schemes,
password storage, and distributed ledgers. Two structural questions dominate
the theory of collision resistance:

1. **Domain extension.** Cryptographic primitives are naturally fixed-input
   (a *compression function* $f$ taking a fixed-size chaining value and a
   fixed-size message block). How do we extend $f$ to arbitrary-length inputs
   *without sacrificing security*?

2. **Hardness anchoring.** Why should the underlying compression function be
   collision resistant at all? Ideally its security reduces to a well-studied
   computational problem believed to be hard.

The **Merkle–Damgård construction** answers the first question and is the
backbone of SHA-256, SHA-1, MD5, and most deployed hashes. Its security is
governed by a classical *preservation theorem*: a collision in the iterated
hash yields a collision in the compression function. This paper presents a
constructive, probability-free formalization of that theorem (Section 3),
identifies its exact validity boundary (Section 4), and connects it to a
concrete algebraic hardness source via the multiplicative hash (Section 5),
which links collision finding to non-unique factorization (Section 6).

Our contributions:

- A complete formal development of `mdHash` and its algebraic laws.
- A constructive proof of the **collision extraction** theorem by reverse
  (last-block) induction, with an explicitly handled base case ruling out
  vacuity.
- A precise statement of the **equal-length boundary**, with a length-extension
  counterexample.
- A **pigeonhole inevitability** result clarifying that collision resistance is
  about search, not existence.
- A **bridge** from product collisions (non-unique factorization) to MD hash
  collisions, with the explicit end-to-end witness $6 \cdot 35 = 10 \cdot 21$.

### 1.1 Background and context

The security paradigm we formalize is the *reductionist* (or *provable*)
approach to cryptography. Rather than asserting that a construction is secure,
one proves a *reduction*: an efficient procedure that converts any adversary
breaking the construction into an adversary breaking some clearly stated
assumption (a hardness assumption, or the security of a smaller primitive).
Contrapositively, if the assumption holds, so does the construction's security.
The Merkle–Damgård preservation theorem is the archetypal *structural*
reduction: it does not reference any number-theoretic assumption at all, only
the internal compression function, and it converts a collision in the whole
hash into a collision in that compression function.

It is worth distinguishing three layers that are frequently conflated in
informal treatments. The *logical* layer is a deterministic map from one
collision to another; this is what we formalize and it requires no probability.
The *complexity* layer asks how much work the map costs (here, linear in the
message length); this controls whether the reduction is *efficient*. The
*adversarial* layer quantifies over resource-bounded attackers and success
probabilities; probabilities live only here. By making the logical layer
explicit and constructive, we expose precisely which parts of the classical
argument are combinatorial identities and which are quantitative.

The second half of the paper concerns the *source* of compression-function
hardness. We use the oldest hardness assumption in number theory — the
difficulty of integer factorization — through a deliberately transparent
multiplicative compression function. While multiplication is cryptographically
trivial (small products factor instantly), it makes the equivalence between
*finding a hash collision* and *finding a second factorization* completely
literal, and the same skeleton, with multiplication replaced by modular
exponentiation, underlies number-theoretic hashes whose collision resistance
rests on genuinely hard problems.

---

## 2. Definitions

Throughout, $\mathrm{State}$ and $\mathrm{Block}$ are arbitrary types, and
messages are finite lists of blocks. We write $|m|$ for the length of a list
$m$, $m_1 \mathbin{+\!\!+} m_2$ for concatenation, and $[\,]$ for the empty list.

**Definition 2.1 (Merkle–Damgård hash).**
Given a compression function $f : \mathrm{State} \to \mathrm{Block} \to \mathrm{State}$
and an initialization vector $iv : \mathrm{State}$, the *Merkle–Damgård hash* of a
message $m$ is the left fold of $f$ over $m$:
$$\mathrm{mdHash}(f, iv, m) = \mathrm{foldl}\,f\,iv\,m.$$
Explicitly, $\mathrm{mdHash}(f, iv, [b_0, \dots, b_{n-1}]) = f(\cdots f(f(iv, b_0), b_1)\cdots, b_{n-1})$.

**Definition 2.2 (Compression collision).**
A compression function $f$ *has a collision* if there exist inputs
$(s, b)$ and $(s', b')$ with
$$(s, b) \neq (s', b') \quad\text{and}\quad f(s, b) = f(s', b').$$
We write this predicate $\mathrm{HasCompressionCollision}(f)$.

**Definition 2.3 (Multiplicative compression function).**
On $\mathbb{N}$, define
$$\mathrm{mulCompress}(s, b) = s \cdot b.$$

**Definition 2.4 (Product collision).**
A set $S \subseteq \mathbb{N}$ *has a product collision* if there exist
$a, b, c, d \in S$, all $\geq 2$, with
$$a \cdot b = c \cdot d \quad\text{and}\quad \{a, b\} \neq \{c, d\} \text{ as multisets}.$$
We write this predicate $\mathrm{HasProductCollision}(S)$. It is the precise
obstruction to unique factorization: two distinct unordered factor pairs with
equal product.

---

## 3. Algebraic Laws and the Collision Extraction Theorem

### 3.1 Foundational laws

The following identities follow directly from the definition of the left fold.

**Lemma 3.1 (Empty message).** $\mathrm{mdHash}(f, iv, [\,]) = iv.$
*Proof.* Folding over the empty list returns the seed. $\qquad\blacksquare$

**Lemma 3.2 (Last block).**
$$\mathrm{mdHash}(f, iv, \ell \mathbin{+\!\!+} [b]) = f\big(\mathrm{mdHash}(f, iv, \ell),\ b\big).$$
*Proof.* `foldl` over $\ell \mathbin{+\!\!+} [b]$ is `foldl` over $\ell$ followed
by one application of $f$ to the final block. $\qquad\blacksquare$

**Lemma 3.3 (Concatenation / composition).**
$$\mathrm{mdHash}(f, iv, a \mathbin{+\!\!+} b) = \mathrm{mdHash}\big(f,\ \mathrm{mdHash}(f, iv, a),\ b\big).$$
*Proof.* `foldl` distributes over append: folding $a \mathbin{+\!\!+} b$ from
$iv$ equals folding $b$ from the result of folding $a$. $\qquad\blacksquare$

Lemma 3.3 is the structural engine of MD security: the construction is
*memoryless* beyond its current chaining value, so any divergence between two
runs is localized.

### 3.2 The extraction theorem

**Theorem 3.4 (Merkle–Damgård collision extraction).**
Let $f : \mathrm{State} \to \mathrm{Block} \to \mathrm{State}$, let
$iv : \mathrm{State}$, and let $m_1, m_2$ be messages with
$$|m_1| = |m_2|, \qquad m_1 \neq m_2, \qquad \mathrm{mdHash}(f, iv, m_1) = \mathrm{mdHash}(f, iv, m_2).$$
Then $\mathrm{HasCompressionCollision}(f)$ holds; moreover, the witnessing
collision is produced explicitly by the proof.

*Proof sketch (reverse induction on $m_1$).* We induct on $m_1$ using the
*reverse* recursor (peeling the last block), generalizing over $m_2$.

- **Base case ($m_1 = [\,]$).** Since $|m_1| = |m_2|$, also $m_2 = [\,]$, so
  $m_1 = m_2$, contradicting $m_1 \neq m_2$. The base case is therefore
  *vacuously discharged by contradiction* — crucially, it never produces a
  spurious collision, which guards against vacuity.

- **Inductive step ($m_1 = p_1 \mathbin{+\!\!+} [b_1]$).** Equal lengths force
  $m_2 = p_2 \mathbin{+\!\!+} [b_2]$ for some prefix $p_2$ and block $b_2$ with
  $|p_1| = |p_2|$. By Lemma 3.2,
  $$f\big(\mathrm{mdHash}(f, iv, p_1),\ b_1\big) = f\big(\mathrm{mdHash}(f, iv, p_2),\ b_2\big).$$
  Let $s_1 = \mathrm{mdHash}(f, iv, p_1)$ and $s_2 = \mathrm{mdHash}(f, iv, p_2)$.
  Two cases:
  - If $(s_1, b_1) \neq (s_2, b_2)$, then $(s_1, b_1)$ and $(s_2, b_2)$ form a
    compression collision of $f$ directly. **Done.**
  - If $(s_1, b_1) = (s_2, b_2)$, then $b_1 = b_2$ and $s_1 = s_2$, i.e.
    $\mathrm{mdHash}(f, iv, p_1) = \mathrm{mdHash}(f, iv, p_2)$. Since
    $m_1 \neq m_2$ but the last blocks agree, $p_1 \neq p_2$; and
    $|p_1| = |p_2|$. The induction hypothesis applied to $p_1, p_2$ yields a
    compression collision.

Each recursive step strictly shrinks the message length, so termination is
guaranteed; the recursion must halt in the first sub-case with an explicit
$f$-collision. $\qquad\blacksquare$

**Corollary 3.5 (Injectivity on fixed length).** If $f$ is collision-free, then
for every $n$, $m \mapsto \mathrm{mdHash}(f, iv, m)$ is injective on messages of
length $n$. *Proof.* Contrapositive of Theorem 3.4. $\qquad\blacksquare$

---

## 4. The Equal-Length Boundary

The equal-length hypothesis in Theorem 3.4 is necessary, not cosmetic.

**Observation 4.1 (Length-extension collision).** Consider
$f = \mathrm{mulCompress}$, $iv = 1$. The messages $[6]$ and $[2, 3]$ satisfy
$$\mathrm{mdHash}(\mathrm{mulCompress}, 1, [6]) = 6 = 2 \cdot 3 = \mathrm{mdHash}(\mathrm{mulCompress}, 1, [2, 3]),$$
with $[6] \neq [2, 3]$, yet they have *different lengths* ($1$ vs $2$). This
collision does not arise from any failure of $f$ to distinguish equal-position
inputs; it is a *free-start / length-extension* artifact of mixing message
sizes. Theorem 3.4 correctly excludes it.

**Remark 4.2 (MD strengthening).** Deployed hashes append an injective encoding
of the message length as a final block (*Merkle–Damgård strengthening*). This
forces colliding messages to agree on length and converts cross-length
artifacts back into genuine compression collisions, generalizing Theorem 3.4 to
arbitrary lengths. The present formalization isolates the result at its tight
boundary, making the role of padding precise.

---

## 5. Pigeonhole Inevitability

Collision resistance cannot mean "no collisions exist."

**Theorem 5.1 (Pigeonhole collision existence).** If the compression function
$f : \mathrm{State} \times \mathrm{Block} \to \mathrm{State}$ has a domain
strictly larger than its codomain (as is forced whenever $|\mathrm{Block}| \geq 2$
and the state space is finite of matching size, i.e. genuine *compression*),
then $f$ has a collision.
*Proof sketch.* A function from a finite set to a strictly smaller finite set
cannot be injective (pigeonhole). Two distinct inputs share an image, which is a
compression collision. $\qquad\blacksquare$

**Interpretation.** Theorem 5.1 shows collisions *always exist*. Theorem 3.4 is
therefore not an existence statement; it is an *extraction* (reduction)
statement: it converts the *act of finding* a hash collision into the *act of
finding* a compression collision. Security is computational — about the
infeasibility of search — not information-theoretic.

---

## 6. From Algebraic Hardness to Hash Collisions

We now instantiate the framework to anchor collision finding in a number-theoretic
hard problem.

**Lemma 6.1 (Multiplicative iterate is the product).**
$$\mathrm{mdHash}(\mathrm{mulCompress}, 1, \ell) = \textstyle\prod_{x \in \ell} x.$$
*Proof.* Unfolding `mdHash` and `mulCompress`, the left fold of multiplication
from $1$ is exactly the list product (`List.prod_eq_foldl`). $\qquad\blacksquare$

**Theorem 6.2 (Product collision is a compression collision).**
If $S \subseteq \mathbb{N}$ has a product collision, then
$\mathrm{HasCompressionCollision}(\mathrm{mulCompress})$.
*Proof.* From $\mathrm{HasProductCollision}(S)$ obtain $a,b,c,d$ with
$a\cdot b = c\cdot d$ and $\{a,b\} \neq \{c,d\}$ as multisets. We claim
$(a,b)\neq(c,d)$: if $(a,b) = (c,d)$ then $a=c$ and $b=d$, whence the multisets
$\{a,b\}$ and $\{c,d\}$ coincide, contradicting the hypothesis. Therefore
$(a,b) \neq (c,d)$ while $\mathrm{mulCompress}(a,b) = a\cdot b = c\cdot d = \mathrm{mulCompress}(c,d)$,
a compression collision. $\qquad\blacksquare$

**Theorem 6.3 (Equal-product messages collide).**
If $m_1, m_2$ are messages over $\mathbb{N}$ with $|m_1| = |m_2|$,
$m_1 \neq m_2$, and $\prod m_1 = \prod m_2$, then
$\mathrm{HasCompressionCollision}(\mathrm{mulCompress})$.
*Proof.* By Lemma 6.1 the two iterated hashes equal the equal products, so
$\mathrm{mdHash}(\mathrm{mulCompress}, 1, m_1) = \mathrm{mdHash}(\mathrm{mulCompress}, 1, m_2)$.
Apply Theorem 3.4 (collision extraction) to the equal-length, distinct,
colliding messages. $\qquad\blacksquare$

**Theorem 6.4 (Concrete end-to-end collision).** The set $\{6, 10, 21, 35\}$
yields an explicit MD collision: with $m_1 = [6, 35]$ and $m_2 = [10, 21]$,
$$|m_1| = |m_2| = 2, \quad m_1 \neq m_2, \quad \textstyle\prod m_1 = 210 = \prod m_2,$$
so $\mathrm{HasCompressionCollision}(\mathrm{mulCompress})$ holds.
*Proof.* Immediate from Theorem 6.3 with the data above (all premises decidable
and verified by computation). $\qquad\blacksquare$

### 6.1 The factorization connection

The set $\{6, 10, 21, 35\}$ is *product-free* (no product of two members lies in
the set) yet has the product collision $6\cdot 35 = 10\cdot 21 = 210$ with
$\{6,35\} \neq \{10,21\}$. This separates the naive "product-free" condition from
genuine collision-freeness, and it is exactly the non-unique factorization of
$210$ over this generator set. In the factorization hierarchy
$$\text{unique factorization} \;\Rightarrow\; \text{collision-free} \;\Rightarrow\; \text{product-free},$$
both implications are strict, and primes are collision-free precisely by the
fundamental theorem of arithmetic. Collision finding for $\mathrm{mulCompress}$
is therefore *finding a second factorization*; scaling block sizes upward, this
is the integer factoring problem.

---

### 6.2 A fully traced execution

It is instructive to trace the entire pipeline on the witness, since every step
is decidable and concrete. Start from the generator set $S = \{6, 10, 21, 35\}$.

1. **Algebraic source.** Enumerate pairwise products: $6\cdot 10 = 60$,
   $6\cdot 21 = 126$, $6\cdot 35 = 210$, $10\cdot 21 = 210$, $10\cdot 35 = 350$,
   $21\cdot 35 = 735$. The value $210$ repeats, witnessed by the distinct pairs
   $\{6, 35\}$ and $\{10, 21\}$. This is a product collision (Definition 2.4).
2. **Compression collision (Theorem 6.2).** Since $\{6,35\}\neq\{10,21\}$ we
   have $(6,35)\neq(10,21)$, while $\mathrm{mulCompress}(6,35) = 210 =
   \mathrm{mulCompress}(10,21)$. This is a compression collision of
   multiplication.
3. **Iterated hash (Lemma 6.1).** With $iv = 1$,
   $\mathrm{mdHash}(\mathrm{mulCompress}, 1, [6,35]) = (1\cdot 6)\cdot 35 = 210$
   and likewise $\mathrm{mdHash}(\mathrm{mulCompress}, 1, [10,21]) = 210$.
4. **MD collision (Theorem 6.3).** The messages $[6,35]$ and $[10,21]$ are
   distinct, of equal length $2$, and hash to the same digest $210$.
5. **Extraction (Theorem 3.4).** Peeling the last block compares the inputs to
   the final $\mathrm{mulCompress}$ step: chaining value $6$ with block $35$
   versus chaining value $10$ with block $21$. These differ as pairs but agree
   in output ($210$), so the extracted compression collision is
   $((6, 35), (10, 21))$.

Every premise above (membership, products, lengths, distinctness) is finite and
machine-checkable, which is why the concrete theorem closes by computation.

## 7. Algorithms

### 7.1 Iterated hash evaluation

$\mathrm{mdHash}$ is computed by a single left fold (Lemma 3.1–3.3), in
$\Theta(n)$ compression-function applications for a message of $n$ blocks and
$O(1)$ auxiliary state. This is the standard streaming evaluation used by all
MD-based hashes.

### 7.2 Collision extraction

Theorem 3.4 is constructive and yields an algorithm: given two equal-length
colliding messages, compare them block by block from the *end*, recomputing
chaining values for the shrinking prefixes, and emit the first position where
the inputs to $f$ differ but the outputs agree. The procedure performs $O(n)$
chaining recomputations (each $O(n)$ folds), hence $O(n^2)$ compression calls in
a naive implementation, or $O(n)$ with cached prefix chaining values.

### 7.3 Product-collision search (algebraic source)

To find a collision of $\mathrm{mulCompress}$ over a generator set $S$, search
for $a, b, c, d \in S$ with $a\cdot b = c\cdot d$ and $\{a,b\} \neq \{c,d\}$ —
equivalently, a number with two distinct factorizations over $S$. By Theorem 6.2
the result is a compression collision, and by Theorem 6.3 an MD hash collision.

---

## 8. Applications

- **Domain extension with security transfer.** Theorem 3.4 justifies building a
  variable-length collision-resistant hash from a fixed-input collision-resistant
  compression function, the design principle behind SHA-2.
- **Hardness-based hashing.** Section 6 instantiates "collision resistance from
  a hard problem": collision finding for the multiplicative hash *is* second
  factorization, illustrating the reduction template used by VSH and other
  number-theoretic hashes.
- **Pedagogy and verification.** The fully constructive, probability-free
  treatment makes the MD security argument suitable for formal verification and
  teaching, with an explicit, runnable witness.

---

## 9. Discussion

The MD preservation theorem is often stated probabilistically ("a collision
finder for the hash yields a collision finder for the compression function with
the same success probability"). Our development shows that the underlying
*reduction* is entirely deterministic and combinatorial: probabilities enter
only when one quantifies the *resources* of an adversary, not the logical core.
Separating these layers clarifies what MD actually guarantees — and, via the
equal-length boundary and pigeonhole inevitability, what it does *not*.

The multiplicative instantiation is deliberately weak (small products factor
trivially) but exact: it makes the equivalence "collision $\Leftrightarrow$
second factorization" literal and exhibits a single witness, $210$, traversing
the whole pipeline. Replacing multiplication with exponentiation modulo a hard
modulus turns the same skeleton into a candidate cryptographic hash.

Three further points deserve emphasis. First, the choice of the *reverse*
recursor in Theorem 3.4 is not incidental: a forward induction would have to
guess where the two messages first diverge, whereas peeling from the end aligns
perfectly with the last-block structure of the MD recurrence (Lemma 3.2), so the
case split is between "the final compression inputs already differ" and "recurse
on strictly shorter prefixes." This is what makes the extraction *local* and
linear. Second, the equal-length hypothesis and the pigeonhole result together
delimit the theorem from both sides: the former excludes cross-length artifacts
that are not compression failures, and the latter forbids reading the theorem as
an existence claim, since collisions always exist under genuine compression.
Third, the bridge to factorization is asymmetric in an illuminating way: the
forward direction (a second factorization yields a collision) is a one-line
consequence of injectivity of pairing, whereas the converse (a collision yields
a nontrivial factor) is the cryptographically substantive direction and is
flagged as future work. The gap between these two directions is exactly the gap
between "this map is a hash" and "this hash is as hard as factoring."

A final methodological remark: because the development is constructive and
probability-free, it is amenable to formal verification and yields executable
witnesses (as in the companion numerical demonstrations). This contrasts with
textbook presentations that fold the reduction into asymptotic, probabilistic
language from the outset, where the underlying combinatorial identity can be
hard to see.

---

## 10. Future Directions

1. **Length-strengthened MD removes the equal-length hypothesis.** Define
   padding $\mathrm{pad}(m) = m \mathbin{+\!\!+} [\mathrm{encodeLength}(|m|)]$ with
   an injective length encoder. Then a collision of $\mathrm{mdHash}(f, iv, \cdot)$
   on $\mathrm{pad}(m_1), \mathrm{pad}(m_2)$ with $m_1 \neq m_2$ (arbitrary
   lengths) yields a compression collision — no equal-length assumption. The
   appended length block forces the final compression to compare encoded
   lengths, converting cross-length artifacts into genuine last-block collisions.
   This is a thin wrapper over the existing last-block case analysis.

2. **Prefix-free domains are equivalent to length-padding for CR preservation.**
   On a prefix-free message set, collision resistance is preserved *without*
   padding, and prefix-freeness is the minimal combinatorial hypothesis making
   the unequal-length recursion terminate in a compression collision. The only
   failure mode in the unequal-length case is one message being a processed
   prefix of the other; prefix-freeness deletes exactly that case.

3. **The multiplicative hash's collision-finding is exactly integer factoring.**
   Finding a collision of $\mathrm{mulCompress}$ on $b$-bit blocks is
   polynomial-time equivalent to factoring a $2b$-bit integer; hence the
   multiplicative MD hash is collision resistant iff factoring is hard.
   Theorem 6.2 supplies the forward map (a non-unique factorization is a
   compression collision); the converse reduction (collision $\Rightarrow$
   nontrivial factor) completes the equivalence and can be tested on small
   composites immediately.

4. **Pigeonhole gap quantifies unavoidable collision density.** For
   $f : \mathrm{State}\times\mathrm{Block} \to \mathrm{State}$ with
   $|\mathrm{Block}| = k$, the number of colliding input pairs is bounded below
   by a counting (fiber-size) estimate: compression by factor $k$ forces a
   quantitatively dense collision set, not merely a single collision,
   strengthening Theorem 5.1 from one collision to many.

---

## 11. Conclusion

We have presented a constructive, machine-checked account of Merkle–Damgård
collision-resistance preservation, pinned its validity boundary, contextualized
it against pigeonhole inevitability, and bridged it to an explicit algebraic
hardness source. The chain *hard arithmetic $\Rightarrow$ compression collision
$\Rightarrow$ hash collision* is realized end to end, with the number $210$ as a
fully worked witness. The development demonstrates that the security heart of
iterated hashing is a transparent piece of discrete mathematics, anchored — in
the multiplicative case — to the venerable hardness of factoring.
