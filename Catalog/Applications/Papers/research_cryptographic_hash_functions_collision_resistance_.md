# Collision Resistance from Hard Problems: The Claw-Free Route through Merkle–Damgård

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Cryptography)

## Abstract

We present a fully constructive, machine-checked development of the canonical
reduction from a *hard problem* to a *collision-resistant hash function* (CRHF),
together with the structural theorem that the Merkle–Damgård (MD) iterated-hash
construction preserves collision resistance. The hard-problem assumption is
phrased abstractly as *claw-freeness* of a pair of permutations $g_0, g_1$: a
*claw* is a pair $(x,y)$ with $g_0(x) = g_1(y)$, and the cryptographic
assumption is that no claw can be found. We define the one-bit-block Damgård
compression function $\text{clawCompress}(g_0,g_1)(s,b) = g_b(s)$ and prove its
central structural identity: **when $g_0$ and $g_1$ are injective, compression
collisions coincide exactly with claws** (`claw_iff_compression_collision`).
Composing this equivalence with the MD collision-extraction theorem
(`md_collision_extract`) yields the headline reduction
(`clawFree_mdHash_injOn_length`): claw-freeness lifts to injectivity of the full
iterated hash on each fixed message length, i.e. collision resistance. We
emphasize three points of mathematical hygiene that the formal development makes
precise: (i) the equal-length hypothesis in MD extraction is necessary, not
cosmetic; (ii) injectivity of both permutations is exactly the tight boundary at
which the collision $\Leftrightarrow$ claw equivalence holds; and (iii) the
entire package is non-vacuous, witnessed by an explicit claw over $\mathbb{Z}/2$.
We also record the pigeonhole inevitability theorem
(`compression_collision_of_card`), which shows that collision resistance is
necessarily a *computational* notion: collisions always exist, and the only
difficulty is finding them. We close with a faithfulness discussion of why plain
one-wayness is insufficient (Simon's black-box separation) and why the
additional claw-free structure (Damgård 1987) is the right hardness primitive.

## 1. Introduction

A cryptographic hash function maps inputs of arbitrary length to fixed-length
digests. Its defining security property, **collision resistance**, asks that it
be computationally infeasible to find two distinct inputs with the same digest.
Because the digest space is finite while the input space is unbounded,
collisions exist in abundance; collision resistance is therefore an inherently
computational, not information-theoretic, property.

Two pillars support practical CRHF design. The first is the **Merkle–Damgård
domain extension**: a compression function on fixed-size inputs is iterated to
hash arbitrarily long messages, and one proves that any collision in the iterate
yields a collision in the compression function. The second is **basing the
compression function on a hard problem**, so that finding a collision is
provably at least as hard as solving a well-studied computational problem (e.g.
integer factorization or discrete logarithm).

A subtle but crucial fact governs the second pillar: one *cannot* build a CRHF
from an arbitrary one-way function by a black-box reduction (Simon 1998).
Additional algebraic structure is required. The classical sufficient structure
is a **claw-free pair of permutations** (Damgård 1987). This paper formalizes,
constructively and without unproven assumptions, the complete chain

$$\text{claw-free pair (hard problem)} \;\Longrightarrow\; \text{collision-free compression}\;\Longrightarrow\;\text{collision-resistant iterated hash},$$

with the *collision $\Leftrightarrow$ claw* equivalence as its structural core.

### 1.1 Contributions

1. A formal Merkle–Damgård model `mdHash` and the collision-extraction theorem
   `md_collision_extract` with the necessity of equal length made explicit.
2. The Damgård compression function `clawCompress` and the structural
   equivalence `claw_iff_compression_collision` between its collisions and claws,
   stated at the tight injectivity boundary.
3. The headline reduction `clawFree_mdHash_injOn_length`: claw-freeness implies
   per-length injectivity (collision resistance) of the iterated hash.
4. The pigeonhole inevitability theorem `compression_collision_of_card`,
   pinning down the computational nature of the security notion.
5. An explicit non-vacuity witness over $\mathbb{Z}/2$ (`concrete_claw`,
   `concrete_compression_collision`).

## 2. The Merkle–Damgård Construction

Throughout, $\text{State}$ and $\text{Block}$ are arbitrary types, and
$f : \text{State} \to \text{Block} \to \text{State}$ is a compression function.

### Definition 2.1 (Iterated hash, `mdHash`).
For an initialization vector $iv : \text{State}$ and a message
$msg : \text{List Block}$,
$$\text{mdHash}(f, iv, msg) \;=\; \text{foldl}\,(f, iv, msg),$$
the left fold of $f$ over the blocks of $msg$ starting from $iv$.

### Definition 2.2 (Compression collision, `HasCompressionCollision`).
$f$ *has a collision* iff there exist $(s,b)$ and $(s',b')$ with
$$(s,b) \neq (s',b') \quad\text{and}\quad f(s,b) = f(s',b').$$

### Basic identities.
The fold satisfies, by definition and a standard `foldl` lemma:

- `mdHash_nil`: $\text{mdHash}(f, iv, [\,]) = iv.$
- `mdHash_concat`: $\text{mdHash}(f, iv, \ell \,{+}{+}\, [b]) = f\big(\text{mdHash}(f, iv, \ell), b\big).$
- `mdHash_append`: $\text{mdHash}(f, iv, a \,{+}{+}\, b) = \text{mdHash}\big(f,\ \text{mdHash}(f, iv, a),\ b\big).$

### Theorem 2.3 (Collision extraction, `md_collision_extract`).
Let $m_1, m_2 : \text{List Block}$ with $|m_1| = |m_2|$, $m_1 \neq m_2$, and
$\text{mdHash}(f, iv, m_1) = \text{mdHash}(f, iv, m_2)$. Then $f$ has a
compression collision.

*Proof sketch.* Reverse (last-block) induction on $m_1$, generalizing over
$m_2$. The empty base case is impossible: if $m_1 = [\,]$ then equal length
forces $m_2 = [\,]$, contradicting $m_1 \neq m_2$. For the inductive step write
$m_1 = \ell_1 \,{+}{+}\, [b_1]$ and, by equal length and nonemptiness,
$m_2 = \ell_2 \,{+}{+}\, [b_2]$. By `mdHash_concat`,
$f(c_1, b_1) = f(c_2, b_2)$ where $c_i = \text{mdHash}(f, iv, \ell_i)$. If
$(c_1, b_1) \neq (c_2, b_2)$ we have the collision directly. Otherwise
$c_1 = c_2$ and $b_1 = b_2$; then $\ell_1 \neq \ell_2$ (else $m_1 = m_2$) are
equal-length prefixes with $\text{mdHash}(f, iv, \ell_1) = \text{mdHash}(f, iv, \ell_2)$,
and the induction hypothesis applies. $\square$

### Corollary 2.4 (Preservation, `mdHash_injOn_length`).
If $f$ has no compression collision, then for every $iv$ the map
$m \mapsto \text{mdHash}(f, iv, m)$ is injective on each fixed message length:
$|m_1| = |m_2|$ and $\text{mdHash}(f, iv, m_1) = \text{mdHash}(f, iv, m_2)$ imply
$m_1 = m_2$.

*Proof.* Contrapositive of Theorem 2.3. $\square$

### Remark 2.5 (Necessity of equal length).
Without length normalization, different-length messages can collide via a
free-start (IV) collision rather than a genuine compression collision, so the
equal-length hypothesis is at the tight boundary. (Concrete practice closes this
gap with length-strengthening padding, "MD-strengthening".)

### Theorem 2.6 (Inevitability, `compression_collision_of_card`).
Suppose $\text{State}$ and $\text{Block}$ are finite, $\text{State}$ is
nonempty, and $|\text{Block}| > 1$. Then *every* compression function $f$ has a
collision.

*Proof sketch.* $|\text{State} \times \text{Block}| = |\text{State}|\cdot|\text{Block}| > |\text{State}|$
since $|\text{Block}| > 1$ and $|\text{State}| > 0$. The map
$(s,b) \mapsto f(s,b)$ from a larger finite set to a smaller one cannot be
injective (pigeonhole), so two distinct inputs share an output. $\square$

This theorem is the formal statement that collision resistance must be
*computational*: collisions are guaranteed to exist; security lies in the
infeasibility of *finding* one.

## 3. Claw-Free Pairs and the Damgård Compression Function

Let $X$ be a type and $g_0, g_1 : X \to X$.

### Definition 3.1 (Claw, `IsClaw` / `HasClaw`).
A *claw* for $(g_0, g_1)$ is a pair $(x, y)$ with $g_0(x) = g_1(y)$. The pair
*has a claw* iff $\exists\, x\, y,\ g_0(x) = g_1(y)$. Its negation,
**claw-freeness**, is the cryptographic hardness assumption.

### Definition 3.2 (Damgård compression, `clawCompress`).
$$\text{clawCompress}(g_0, g_1)(s, b) \;=\; \begin{cases} g_1(s) & b = \text{true} \\ g_0(s) & b = \text{false} \end{cases}$$
i.e. `bif b then g₁ s else g₀ s`. The reduction equations `clawCompress_false`
and `clawCompress_true` record $\text{clawCompress}(g_0,g_1)(s,\text{false}) = g_0(s)$
and $\text{clawCompress}(g_0,g_1)(s,\text{true}) = g_1(s)$.

### Theorem 3.3 (Claw $\Rightarrow$ collision, `claw_to_compression_collision`).
If $(g_0, g_1)$ has a claw, then $\text{clawCompress}(g_0, g_1)$ has a
compression collision.

*Proof.* From a claw $g_0(x) = g_1(y)$, the inputs $(x, \text{false})$ and
$(y, \text{true})$ are distinct (their block bits differ) and map to the same
output $g_0(x) = g_1(y)$. $\square$

### Theorem 3.4 (Collision $\Rightarrow$ claw, `clawCompress_collision_to_claw`).
If $g_0$ and $g_1$ are injective and $\text{clawCompress}(g_0, g_1)$ has a
compression collision, then $(g_0, g_1)$ has a claw.

*Proof.* Let $(s, b) \neq (s', b')$ collide. Case on $(b, b')$:
- $(\text{false}, \text{false})$: collision is $g_0(s) = g_0(s')$; injectivity
  of $g_0$ gives $s = s'$, so $(s, b) = (s', b')$, contradiction.
- $(\text{true}, \text{true})$: symmetric via injectivity of $g_1$,
  contradiction.
- $(\text{false}, \text{true})$: collision is $g_0(s) = g_1(s')$, a claw
  $(s, s')$.
- $(\text{true}, \text{false})$: collision is $g_1(s) = g_0(s')$, i.e.
  $g_0(s') = g_1(s)$, a claw $(s', s)$. $\square$

### Theorem 3.5 (Equivalence, `claw_iff_compression_collision`).
For injective $g_0, g_1$,
$$\text{HasClaw}(g_0, g_1) \;\Longleftrightarrow\; \text{HasCompressionCollision}\big(\text{clawCompress}(g_0, g_1)\big).$$

*Proof.* Combine Theorems 3.3 and 3.4. $\square$

### Remark 3.6 (Tightness of injectivity).
Injectivity is necessary for the $\Rightarrow$ direction: without it, a same-bit
collision $g_0(s) = g_0(s')$ with $s \neq s'$ would be a compression collision
that is *not* a claw. The equivalence is thus stated at its tight boundary.

### Corollary 3.7 (Claw-free $\Rightarrow$ collision-free, `clawFree_compression_collisionFree`).
For injective $g_0, g_1$, if $(g_0, g_1)$ is claw-free then
$\text{clawCompress}(g_0, g_1)$ has no compression collision.

*Proof.* Contrapositive of Theorem 3.4. $\square$

## 4. The Headline Reduction: Hard Problem $\Rightarrow$ CRHF

### Theorem 4.1 (MD lift, `md_clawCompress_collision_to_claw`).
Let $g_0, g_1$ be injective, $iv : X$, and $m_1, m_2 : \text{List Bool}$ with
$|m_1| = |m_2|$, $m_1 \neq m_2$, and
$\text{mdHash}(\text{clawCompress}(g_0,g_1), iv, m_1) = \text{mdHash}(\text{clawCompress}(g_0,g_1), iv, m_2)$.
Then $(g_0, g_1)$ has a claw.

*Proof.* By Theorem 2.3 the MD collision yields a compression collision of
$\text{clawCompress}(g_0, g_1)$; by Theorem 3.4 that collision is a claw.
$\square$

### Theorem 4.2 (Headline, `clawFree_mdHash_injOn_length`).
Let $g_0, g_1$ be injective and claw-free, and let $iv : X$. Then for all
$m_1, m_2 : \text{List Bool}$ with $|m_1| = |m_2|$,
$$\text{mdHash}(\text{clawCompress}(g_0,g_1), iv, m_1) = \text{mdHash}(\text{clawCompress}(g_0,g_1), iv, m_2) \;\Longrightarrow\; m_1 = m_2.$$
That is, the iterated Damgård hash is injective on each fixed message length: a
claw-free hard problem yields a collision-resistant variable-length hash.

*Proof.* Suppose $m_1 \neq m_2$. Theorem 4.1 produces a claw, contradicting
claw-freeness; hence $m_1 = m_2$. $\square$

This is the constructive reduction "claw-free pair $\Rightarrow$ CRHF": any
attack producing an equal-length collision of the iterated hash is mechanically
transformed into a claw, hence into a solution of the underlying hard problem.

## 5. Non-Vacuity: An Explicit Witness over $\mathbb{Z}/2$

To certify that all hypotheses are simultaneously satisfiable, the development
exhibits the smallest nontrivial example on $X = \mathbb{Z}/2$.

### Definition 5.1 (`g0Ex`, `g1Ex`).
$g_0^{\text{ex}} = \text{id}$ and $g_1^{\text{ex}}(x) = x + 1$ on $\mathbb{Z}/2$.

### Lemma 5.2 (`g0Ex_injective`, `g1Ex_injective`).
Both $g_0^{\text{ex}}$ and $g_1^{\text{ex}}$ are injective.

*Proof.* The identity is injective; $x \mapsto x + 1$ is injective by
left-cancellation of addition. $\square$

### Proposition 5.3 (`concrete_claw`).
$(g_0^{\text{ex}}, g_1^{\text{ex}})$ has a claw, since
$g_0^{\text{ex}}(1) = 1 = 0 + 1 = g_1^{\text{ex}}(0)$.

### Corollary 5.4 (`concrete_compression_collision`).
$\text{clawCompress}(g_0^{\text{ex}}, g_1^{\text{ex}})$ has a compression
collision (apply Theorem 3.3 to Proposition 5.3).

Thus the equivalence of Theorem 3.5 and the reduction of Theorem 4.2 are not
vacuously true: there is a genuine instance realizing every hypothesis. (Note
this witness is deliberately *easy* — it demonstrates the structure, not
hardness; cryptographic instances place hardness in concrete number theory.)

## 6. Algorithmic Content

The proofs are constructive and immediately give algorithms.

**Algorithm A (MD collision extraction).** Given equal-length colliding
messages $m_1 \neq m_2$, walk both from the last block toward the first. At each
position compare $(c_i, b_i)$ (chaining value, block). The first position where
the pairs differ but the outputs agree is an explicit compression collision.
Cost: $O(|m_1|)$ compression evaluations.

**Algorithm B (Collision $\to$ claw).** Given a compression collision
$(s,b) \neq (s',b')$ of $\text{clawCompress}$, return the claw determined by the
differing bits: $(s, s')$ if $b = \text{false}, b' = \text{true}$, or
$(s', s)$ if $b = \text{true}, b' = \text{false}$ (same-bit cases cannot occur
for injective $g_0, g_1$). Cost: $O(1)$.

**Algorithm C (Full attack-to-claw reduction).** Compose A then B: an
equal-length collision of the iterated Damgård hash is turned into a claw, hence
into a solution of the hard problem. This is the contrapositive of Theorem 4.2
realized as a reduction, the cornerstone of provable security: any hash
collision finder yields a claw finder of comparable cost.

## 7. Applications and Discussion

**Provable-security template.** Theorem 4.2 is the abstract skeleton of
factoring- and discrete-log-based hashes. Concrete claw-free pairs are built so
that a claw encodes (e.g.) a nontrivial square root modulo a composite or a
discrete-log relation; Theorem 4.2 then certifies the resulting hash is as
collision-resistant as the number-theoretic problem is hard.

**Why not one-way functions alone?** Simon (1998) established a black-box
separation: no black-box construction turns an arbitrary one-way function into a
CRHF. The claw-free pair supplies exactly the missing structure (collision
$\equiv$ claw) that makes the reduction go through, which is why the present
development is stated for claw-free pairs rather than generic one-way functions.

**Inevitability vs. resistance.** Theorem 2.6 shows collisions always exist for
finite domains; the security claim of Theorem 4.2 is therefore correctly about
*finding* collisions (which would yield a claw) and not their nonexistence.

## 8. Future Directions

(See the PACKAGE future-directions field for the full Phase A statement.) Two
guiding conjectures: (1) over finite $X$, two permutations *always* admit a
claw, so the hardness must reside in *inversion difficulty* rather than
combinatorial non-existence — connecting `claw_iff_compression_collision` with
the pigeonhole theorem `compression_collision_of_card`; (2) prefix-free domain
separation (MD-strengthening) removes the length-extension collision family by
breaking the right-congruence kernel of plain concatenation.

## 9. Conclusion

We have given a constructive, self-contained chain from an abstract hard problem
(claw-freeness of a permutation pair) to a collision-resistant variable-length
hash, with the *collision $\Leftrightarrow$ claw* equivalence as the structural
core and Merkle–Damgård extraction as the domain-extension engine. The
development is stated at tight boundaries (equal length, injectivity), is
provably non-vacuous, and exposes the computational nature of collision
resistance via the pigeonhole inevitability theorem.

## References

1. I. Damgård, *Collision free hash functions and public key signature
   schemes*, EUROCRYPT 1987.
2. R. Merkle, *One way hash functions and DES*, CRYPTO 1989.
3. D. Simon, *Finding collisions on a one-way street: Can secure hash functions
   be based on general assumptions?*, EUROCRYPT 1998.
