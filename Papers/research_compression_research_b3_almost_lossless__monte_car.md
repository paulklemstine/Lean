# Almost-Lossless Compression Beyond the Pigeonhole Bound: Exact Converses, Certified Decoders, and Logarithmic Decoding Cost

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

The pigeonhole principle governs *exact* decoding: a compression scheme that
recovers every symbol of a source alphabet $\alpha$ requires at least
$|\alpha|$ codewords. We develop the *almost-lossless* relaxation, in which the
decoder is permitted to abstain or to err with total probability at most
$\varepsilon$, and we determine the exact price of that relaxation in three
currencies simultaneously: rate, reliability, and decoding time.

On the rate side we prove a localized pigeonhole bound — the encoder is
injective on the set of correctly decoded symbols — from which
$\Pr[\text{success}] \le |\mathcal{C}| \cdot p_{\max}$ and hence
$\log|\mathcal{C}| \ge H_\infty(\mu) + \log(1-\varepsilon)$; we then exhibit,
for every code size $M \le n$, a scheme on the uniform source over $n$ symbols
with success probability exactly $M/n$, so the relaxed bound is attained and no
converse above it can be improved.

On the achievability side we replace Shannon's unbounded random codebook by a
2-universal hash family keyed by a single element, and instrument the decoder so
that its cost is proved rather than estimated. A first-moment argument produces
an explicit key with failure probability at most $\delta + |l|/M$ on a codebook
$l$ whose complement carries mass $\delta$; a two-region threshold argument
sharpens the silent-corruption bound to $2\delta|l|/M$, and a one-parameter
version gives $(1+\eta)\delta|l|/M$ against failure $\delta +
(1+\eta^{-1})|l|/M$ for every $\eta > 0$. Pairing a checksum family multiplies
the collision parameter, driving silent corruption to $|l|/(MC)$ at $\log C$
extra bits. Explicit non-vacuity is supplied by the inner-product family
$h_k(x_1,x_2) = x_1 + kx_2$ over $\mathbb{F}_p$, which compresses $p^2$ symbols
to $p$ codewords.

The principal contribution is algorithmic. The naive unique-match decoder costs
exactly $|l|$ hash evaluations, which on a $b$-block product source with typical
set $T$ means $|T|^b$ — exponential in the block length. We remove this obstacle
twice. Coordinatewise decoding keeps failure at $b(\delta + |T|/m)$ while cutting
cost to $b|T|$. More decisively, sorting the codebook by hash value *after* the
key is chosen — a permutation, hence invisible to the collision analysis — turns
the unique-match scan into a binary search. We give a cost-instrumented binary
search with the exact bound $\log_2 n + 1$ key evaluations, add a two-neighbour
uniqueness test that forces abstention on a duplicate hash value, and prove that
the resulting decoder *never corrupts silently under any hypothesis on the hash
function*. Total cost: at most $\log_2 n + 3$. A decision-tree converse shows
that any adaptive Boolean-query decoder correct on $n$ symbols has worst-case
cost at least $\log_2 n$, so this decoder is optimal within an additive $3$.

Finally we settle the rate–list and randomness questions. List-$T$ decoding
relaxes the counting bound by exactly $\log T$; with 2-universality it improves
failure linearly to $\delta + |l|/(TM)$, and with $(T{+}1)$-wise independence a
factorial-moment double count improves it exponentially to $\delta +
\binom{|l|}{T}/M^T \le \delta + (|l|/M)^T$, realized by degree-$T$ polynomials
over $\mathbb{F}_p$ with only $p^{T+1}$ keys. For the key space itself,
integrality of a collision count yields the sharp bound $K \ge M$ for any
compressing 2-universal family — the encoder's advice must be at least as long as
the codeword — attained by the inner-product family with $K = M = p$.

**Keywords:** almost-lossless compression, universal hashing, min-entropy,
random coding, list decoding, decision-tree lower bounds, derandomization.

---

## 1. Introduction

### 1.1 The exact bound and its rigidity

Let $\alpha$ be a finite source alphabet and $\mathcal{C}$ a finite code space.
A compression scheme is a pair of maps
$$\mathrm{enc} : \alpha \to \mathcal{C}, \qquad
\mathrm{dec} : \mathcal{C} \to \alpha \cup \{\bot\},$$
the symbol $\bot$ denoting an explicit refusal to answer. If we demand
$\mathrm{dec}(\mathrm{enc}(x)) = x$ for every $x \in \alpha$, then $\mathrm{enc}$
is injective and $|\alpha| \le |\mathcal{C}|$. No compression is possible. This is
the pigeonhole bound, and it is completely insensitive to computational
resources, to the structure of the source, and to the ingenuity of the designer.

Practical compression escapes this by exploiting structure: real sources are far
from uniform. The information-theoretic idealization of that escape is to relax
the *universal quantifier*. Fix a probability distribution $\mu$ on $\alpha$ and
require only
$$\Pr_{x \sim \mu}\bigl[\mathrm{dec}(\mathrm{enc}(x)) = x\bigr] \ge 1 -
\varepsilon .$$
This is **almost-lossless** (or Monte-Carlo) compression. The folklore is that
random codebooks now achieve near-optimal rates, and the folklore is correct.
What the folklore does not supply is (i) an exact statement of how far the
counting bound moves, (ii) a guarantee that failures are never silent, and (iii)
an implementable decoder with a proved running time. Random coding as usually
presented is a proof technique: its decoder is an exhaustive search over an
astronomically large codebook.

### 1.2 Contributions

This paper supplies all three, with matching converses.

1. **Exact rate relaxation** (§3). The pigeonhole bound survives in localized
   form and yields $\log|\mathcal{C}| \ge H_\infty(\mu) + \log(1-\varepsilon)$,
   which is *attained*.
2. **Certified achievability** (§4–§6). A 2-universal family plus a unique-match
   decoder gives failure $\delta + |l|/M$, never lies on a codebook symbol, and
   admits sharpened and tunable silent-error bounds, plus checksum amplification.
3. **Logarithmic decoding** (§7–§8). Sorting the codebook after key selection
   yields a binary-search decoder of proved cost $\le \log_2 n + 3$ that never
   corrupts silently under *any* hypothesis, together with a decision-tree
   converse of $\log_2 n$ showing optimality within an additive constant.
4. **List decoding and higher independence** (§9). Exact $\log T$ rate
   relaxation; linear gain from 2-universality, exponential gain from
   $(T{+}1)$-wise independence, realized with short polynomial keys.
5. **The cost of randomness** (§10). Sharp lower bound $K \ge M$ on the key space
   of any compressing 2-universal family, attained.

### 1.3 A note on the cost model

Throughout, "cost" means the number of *key evaluations* — applications of the
hash function to a candidate symbol — performed by the decoder on one query.
Every cost statement in this paper is an exact arithmetic bound on an
instrumented algorithm, never an asymptotic estimate. The lower bounds of §8 are
stated in the same currency, for a strictly more general model (arbitrary
adaptive Boolean queries), so the two sides are directly comparable.

---

## 2. Schemes, success, and silence

**Definition 2.1 (Scheme).** A *scheme* on a finite alphabet $\alpha$ with code
space $\mathcal{C}$ is a pair $(\mathrm{enc}, \mathrm{dec})$ with
$\mathrm{enc} : \alpha \to \mathcal{C}$ and
$\mathrm{dec} : \mathcal{C} \to \alpha \cup \{\bot\}$.

**Definition 2.2.** The scheme *succeeds* at $x$ if
$\mathrm{dec}(\mathrm{enc}(x)) = x$. It *silently corrupts* $x$ if
$\mathrm{dec}(\mathrm{enc}(x)) = y$ for some $y \ne x$ (in particular $y \ne
\bot$). It is *never silent* if it silently corrupts no symbol.

**Lemma 2.3.** A scheme is never silent if and only if for every $x$,
$\mathrm{dec}(\mathrm{enc}(x)) \in \{x, \bot\}$.

*Proof.* Immediate from the definitions: a confident answer that is not $x$ is a
silent corruption, and conversely. $\square$

The distinction between abstention and silent corruption is the operational heart
of the paper. A scheme that abstains can be composed with retransmission,
fallback to a raw encoding, or an outer error-correcting layer. A scheme that
lies confidently cannot be repaired by any outer layer, because the outer layer
receives no signal.

**Definition 2.4 (Success set and success probability).** The *success set*
$\mathcal{S}$ is $\{x \in \alpha : \mathrm{dec}(\mathrm{enc}(x)) = x\}$. Given a
distribution $\mu$, the *success probability* is $\mu(\mathcal{S})$.

**Definition 2.5 (Min-entropy).** $p_{\max}(\mu) = \max_{x} \mu(x)$ and
$H_\infty(\mu) = -\log p_{\max}(\mu)$.

Min-entropy, rather than Shannon entropy, is the correct parameter here because
the arguments are pure counting arguments: a set of $m$ symbols carries at most
$m \cdot p_{\max}$ mass, and that inequality is what converts cardinality bounds
into probability bounds.

---

## 3. The relaxed pigeonhole bound and its tightness

**Theorem 3.1 (Localized pigeonhole).** For every scheme, the encoder is
injective on the success set. Consequently $|\mathcal{S}| \le |\mathcal{C}|$.

*Proof sketch.* Let $x, y \in \mathcal{S}$ with $\mathrm{enc}(x) =
\mathrm{enc}(y)$. Then $x = \mathrm{dec}(\mathrm{enc}(x)) =
\mathrm{dec}(\mathrm{enc}(y)) = y$. Injectivity on $\mathcal{S}$ gives
$|\mathcal{S}| \le |\mathcal{C}|$. $\square$

The content of Theorem 3.1 is that failure and abstention buy nothing
*combinatorially*: however wildly the decoder behaves off $\mathcal{S}$, the part
where it behaves has to fit inside the code space. All the gain must come from
$\mathcal{S}$ being small in *cardinality* while large in *measure*, which is
exactly a min-entropy statement.

**Corollary 3.2 (Exact pigeonhole).** If the scheme succeeds at every symbol then
$|\alpha| \le |\mathcal{C}|$.

**Theorem 3.3 (Counting bound, probabilistic form).** For every scheme,
$$\Pr[\text{success}] \;\le\; |\mathcal{C}| \cdot p_{\max}(\mu).$$

*Proof sketch.* $\mu(\mathcal{S}) = \sum_{x \in \mathcal{S}} \mu(x) \le
|\mathcal{S}| \cdot p_{\max} \le |\mathcal{C}| \cdot p_{\max}$ by Theorem 3.1.
$\square$

**Theorem 3.4 (Almost-lossless converse).** If $\Pr[\text{success}] \ge 1 -
\varepsilon$ then
$$|\mathcal{C}| \;\ge\; \frac{1-\varepsilon}{p_{\max}(\mu)}, \qquad\text{and, for
} \varepsilon < 1, \qquad
\log|\mathcal{C}| \;\ge\; H_\infty(\mu) + \log(1-\varepsilon).$$

*Proof sketch.* Rearrange Theorem 3.3 and take logarithms, using
$\log(1/p_{\max}) = H_\infty$. $\square$

**Corollary 3.5 (Uniform source).** For $\mu$ uniform on $n$ symbols, success
probability $1-\varepsilon$ forces $|\mathcal{C}| \ge (1-\varepsilon) n$.

So on a flat source the pigeonhole bound degrades by the factor $1-\varepsilon$
and by nothing more: tolerating a $1\%$ failure probability saves about $0.0145$
bits. The relaxation does *not* buy rate on flat sources. Its value lies
elsewhere, as §4 onwards will show.

**Theorem 3.6 (Tightness).** For every $n$ and every $M$ with $0 < M \le n$ there
is a scheme from the uniform source on $n$ symbols into a code space of size $M$
whose success probability is exactly $M/n$.

*Proof sketch.* Identify the source with $\{0,\dots,n-1\}$ and the code space
with $\{0,\dots,M-1\}$. Encode $x \mapsto x$ if $x < M$ and $x \mapsto 0$
otherwise; decode $i \mapsto i$. The success set is exactly $\{0,\dots,M-1\}$,
of mass $M/n$. $\square$

Combined with Theorem 3.3 (which gives $\le M/n$ in this setting), Theorem 3.6
shows that no converse in this section can be strengthened.

---

## 4. Random coding via universal hashing

### 4.1 The family

**Definition 4.1 (2-universality).** A family $H : \mathcal{K} \times \alpha \to
[M]$, with $|\mathcal{K}| = K$, is *2-universal* if for all $x \ne y$,
$$\bigl|\{k \in \mathcal{K} : H_k(x) = H_k(y)\}\bigr| \cdot M \;\le\; K .$$
(The multiplicative form avoids division and is the one used in all estimates
below.)

The single key $k$ is the entire source of randomness. This is the concrete
substitute for Shannon's random codebook: instead of $M^{|\alpha|}$ possible
codebooks, $K$ of them, and the collision statistics we need are the same.

**Definition 4.2 (Codebook and typicality parameter).** A *codebook* is a
duplicate-free list $l$ of source symbols. Its *typicality parameter* is a bound
$\delta$ with $\mu(\alpha \setminus l) \le \delta$: the probability that the
source produces a symbol outside the codebook.

### 4.2 The unique-match decoder

**Definition 4.3 (Unique-match decoder).** Given a key $k$ and a codebook $l$,
the encoder sends $H_k(x)$. On receiving $i \in [M]$, the decoder scans $l$ and
returns the unique $y \in l$ with $H_k(y) = i$ if exactly one such $y$ exists,
and $\bot$ otherwise. The scan is instrumented: it performs exactly $|l|$ key
evaluations.

**Lemma 4.4 (No silent corruption on the codebook).** If $x \in l$, the decoder
returns either $x$ or $\bot$. In particular, the scheme never silently corrupts a
codebook symbol, *for every key*.

*Proof sketch.* If $x \in l$ then $x$ is itself a match for $i = H_k(x)$. Either
it is the only one, and the decoder returns $x$; or there is another, and the
uniqueness test fails, returning $\bot$. $\square$

Lemma 4.4 is unconditional — no probabilistic hypothesis at all. Silent
corruption can therefore only occur at symbols *outside* the codebook that happen
to collide with a codebook entry.

### 4.3 The first-moment argument

**Definition 4.5 (Collision set).** For a key $k$ and $x \in \alpha$, let
$$\mathrm{Coll}_k(x) = \{y \in l : y \ne x, \; H_k(y) = H_k(x)\}.$$
The decoder fails at $x \in l$ precisely when $\mathrm{Coll}_k(x) \ne \emptyset$.

**Lemma 4.6 (Averaging identity).** For a 2-universal $H$ and any region $A
\subseteq \alpha$,
$$M \cdot \sum_{k \in \mathcal{K}} \mu\bigl(\{x \in A : \mathrm{Coll}_k(x) \ne
\emptyset\}\bigr) \;\le\; K \cdot |l| \cdot \mu(A).$$

*Proof sketch.* Exchange the order of summation. For fixed $x$ and fixed $y \in
l$ with $y \ne x$, the number of keys with $H_k(y) = H_k(x)$ is at most $K/M$ by
2-universality. Summing over the $\le |l|$ choices of $y$ and weighting by
$\mu(x)$ gives the claim. $\square$

**Theorem 4.7 (Derandomization).** There exists a key $k$ for which the
collision mass on $A$ is at most its average, i.e. at most $|l|\,\mu(A)/M$.

*Proof sketch.* A finite family of nonnegative reals contains an element at most
the mean; apply to Lemma 4.6. $\square$

**Theorem 4.8 (Achievability).** Let $H$ be 2-universal with $K \ge 1$ keys and
$M \ge 1$ codewords, and let $l$ be a codebook with typicality parameter
$\delta$. Then there exists a key $k$ such that the resulting scheme satisfies
$$\Pr[\text{failure}] \le \delta + \frac{|l|}{M}, \qquad
\Pr[\text{silent corruption}] \le \frac{|l|}{M},$$
and the decoder performs exactly $|l|$ key evaluations on every query.

*Proof sketch.* Apply Theorem 4.7 with $A = \alpha$. Failure at $x$ requires
either $x \notin l$ (mass $\le \delta$) or $x \in l$ with a collision (mass $\le
|l|/M$ by the choice of $k$). Silent corruption requires $x \notin l$ *and* a
collision, so its mass is at most the collision mass $|l|/M$. The cost statement
is the instrumentation of the scan. $\square$

**Theorem 4.9 (Rate sandwich).** Suppose $p_{\max}(\mu)\,|l| \le c$ (a flatness
hypothesis) and $|l|/M \le \varepsilon - \delta$. Then
(i) some key achieves success probability $\ge 1-\varepsilon$ with $M$ codewords,
and (ii) every scheme with success probability $\ge 1-\varepsilon$, whatever its
code space, needs at least $(1-\varepsilon)|l|/c$ codewords.

*Proof sketch.* (i) is Theorem 4.8; (ii) is Theorem 3.4 with $p_{\max} \le
c/|l|$. $\square$

The gap between the two sides depends only on $\varepsilon$, $\delta$ and the
flatness constant $c$ — not on $|\alpha|$. This is the precise sense in which
universal hashing achieves the almost-lossless rate.

---

## 5. An explicit family: non-vacuity

**Definition 5.1 (Inner-product family).** Let $p$ be prime. On the source
$\mathbb{F}_p^2$, with key space $\mathbb{F}_p$ and code space $\mathbb{F}_p$,
put
$$h_k(x_1, x_2) = x_1 + k\,x_2 \pmod p .$$

**Theorem 5.2.** The inner-product family is 2-universal. It compresses $p^2$
source symbols into $p$ codewords.

*Proof sketch.* Suppose $(x_1,x_2) \ne (y_1,y_2)$ collide: $x_1 + kx_2 = y_1 +
ky_2$, i.e. $k(x_2 - y_2) = y_1 - x_1$. If $x_2 \ne y_2$ this determines $k$
uniquely, so at most one of the $p$ keys collides, and $1 \cdot p \le p$. If $x_2
= y_2$ then $x_1 \ne y_1$ and no key collides. $\square$

**Theorem 5.3 (A fully numeric instance).** Take $p = 101$, so the source is
$\mathbb{F}_{101}^2$ with $10201$ symbols, and let $l$ be any duplicate-free
codebook of $10$ symbols carrying all but $1/100$ of the mass. Then there is a
key $k \in \mathbb{F}_{101}$ such that the scheme fails with probability at most
$1/100 + 10/101 \approx 0.109$, corrupts silently with probability at most
$10/101$, and decodes in exactly $10$ key evaluations.

Theorem 5.3 exists to rule out vacuity: every hypothesis of the general theory is
met by an object one can write down in a line.

---

## 6. Making silence rarer

### 6.1 A two-region threshold

Theorem 4.8's silent bound $|l|/M$ is wasteful. A silent error needs $x \notin l$
*and* $\mathrm{Coll}_k(x) \ne \emptyset$; the first event already has probability
$\le \delta$, so the first moment of the silent-error mass carries an extra
factor $\delta$. The obstruction is that we must choose *one* key that is
simultaneously good for two different regions.

**Lemma 6.1 (Markov counting).** For any region $A$ and any threshold $c > 0$,
strictly fewer than $K/c$ keys have collision mass on $A$ exceeding $c$ times its
average $|l|\mu(A)/M$.

**Theorem 6.2 (Doubly good key).** With thresholds $c_1 = c_2 = 2$, the two bad
key sets each have size $< K/2$ and so cannot cover $\mathcal{K}$. Hence there is
a single key that is simultaneously good at threshold $2$ for the region $\alpha
\setminus l$ and for the whole space.

**Theorem 6.3 (Sharp silent-error bound).** There is a single explicit key with
$$\Pr[\text{failure}] \le \delta + \frac{2|l|}{M}, \qquad
\Pr[\text{silent corruption}] \le \frac{2\delta|l|}{M},$$
and decoding cost still exactly $|l|$.

The silent bound has improved by a factor $\delta$ — typically several orders of
magnitude — at the cost of a factor $2$ in the failure bound.

### 6.2 The whole trade-off curve

The threshold $2$ is an artefact of splitting the key space evenly. Any pair
$c_1, c_2 > 0$ with $c_1^{-1} + c_2^{-1} \le 1$ leaves a key outside both bad
sets.

**Theorem 6.4 (Tunable derandomization).** For every $\eta > 0$ there is a key
with
$$\Pr[\text{silent corruption}] \le (1+\eta)\,\frac{\delta|l|}{M}, \qquad
\Pr[\text{failure}] \le \delta + \Bigl(1 + \frac{1}{\eta}\Bigr)\frac{|l|}{M},$$
and decoding cost exactly $|l|$.

*Proof sketch.* Take $c_1 = 1 + \eta$ and $c_2 = 1 + \eta^{-1}$; then $c_1^{-1} +
c_2^{-1} = 1$, so Lemma 6.1 leaves a key outside both bad sets. $\square$

Setting $\eta = 1$ recovers Theorem 6.3. Letting $\eta \to 0$ drives the silent
constant to $1$, the first-moment optimum, at the price of a diverging failure
constant: the trade-off is continuous and its two endpoints are exactly the two
first-moment bounds one would naively hope for separately.

### 6.3 Checksums

**Definition 6.5 (Paired family).** Given $H : \mathcal{K} \times \alpha \to [M]$
and $G : \mathcal{K}' \times \alpha \to [C]$, define $H \otimes G$ on key space
$\mathcal{K} \times \mathcal{K}'$ and code space $[M] \times [C]$ by $(H \otimes
G)_{(k,k')}(x) = (H_k(x), G_{k'}(x))$.

**Theorem 6.6 (Universality is multiplicative).** If $H$ and $G$ are 2-universal
then so is $H \otimes G$, with $KK'$ keys and $MC$ codewords.

*Proof sketch.* Two symbols collide under the pair only if they collide under
both coordinates; count key pairs and multiply the two universality bounds.
$\square$

**Corollary 6.7 (Guaranteed detection).** Appending a $\log_2 C$-bit checksum
from an independent universal family drives the silent-corruption probability to
at most $|l|/(MC)$. For any target $\eta > 0$, choosing $C > |l|/(M\eta)$
suffices.

This is the promised "no silent corruption" gate: failures can always be made
detectable at logarithmic additive cost, on top of the unconditional Lemma 4.4.

---

## 7. Decoding cost, and how to destroy it

### 7.1 The exponential obstruction

The decoder of §4 costs exactly $|l|$ key evaluations. On a $b$-fold i.i.d.
product source $\mu^{\otimes b}$ over an alphabet $\beta$, the natural codebook is
the $b$-fold product $T^b$ of a per-block typical set $T$, with $|T|^b$ entries.
The naive decoder is therefore exponential in the block length. This — not the
rate — is the real content of the "random coding is not an algorithm" complaint.

### 7.2 Coordinatewise decoding

**Theorem 7.1 (Product marginals and a union bound).** For the $b$-fold product
source, the marginal on each coordinate is $\mu$, and for a set of block
configurations defined by a per-coordinate condition, the total mass is at most
the sum of the $b$ per-coordinate masses.

**Theorem 7.2 (Coordinatewise decoder).** Decode each of the $b$ blocks
independently with its own unique-match scan against the size-$|T|$ codebook and
assemble the answers. The resulting block decoder returns a full block exactly
when every coordinate decoder returns a symbol; hence it never corrupts silently
on the product codebook, its failure probability is at most $b \cdot (\delta +
|T|/m)$, and its cost is exactly $b|T|$ key evaluations.

**Theorem 7.3 (Exponential speedup).** For $|T| \ge 2$ and $b \ge 3$,
$$b\,|T| \;<\; |T|^b ,$$
so the coordinatewise cost $b|T|$ is strictly below the naive codebook size
$|T|^b$, and the gap grows exponentially in $b$.

### 7.3 Sorting the codebook

The residual $|T|$ per block is still linear. One might expect a logarithmic
decoder to require a hash family that is simultaneously 2-universal and
*monotone* on every codebook — an unnatural and probably unachievable
requirement. It is unnecessary.

**Key observation.** The encoder chooses the key $k$ *first*, and only then
stores the codebook **sorted by hash value**. Sorting is a permutation of the
codebook. The collision analysis of §4 depends only on the multiset $\{H_k(y) : y
\in l\}$, which a permutation does not change. Hence every probabilistic bound
proved so far survives verbatim, while the stored array now has monotone keys —
and a unique-match query on a monotone array is a binary search.

**Definition 7.4 (Sorted codebook).** Given $k$ and $l$, let $\sigma$ be a
permutation with $H_k(l_{\sigma(0)}) \le H_k(l_{\sigma(1)}) \le \cdots$. Write
$\mathrm{key}(i) = H_k(l_{\sigma(i)})$ and $a(i) = l_{\sigma(i)}$.

**Lemma 7.5 (Monotonicity).** $\mathrm{key}$ is monotone non-decreasing on
$\{0,\dots,|l|-1\}$.

---

## 8. A logarithmic decoder and a matching converse

### 8.1 Cost-instrumented binary search

**Definition 8.1.** For a key function $\mathrm{key} : \mathbb{N} \to \mathbb{N}$,
a target $t$, and a range $[lo, lo+\mathrm{len})$, define $\mathrm{bsearch}$
recursively: if $\mathrm{len} = 0$, return $(\bot, 0)$; otherwise let $h =
\lfloor \mathrm{len}/2 \rfloor$ and $m = lo + h$, and
- if $\mathrm{key}(m) = t$, return $(m, 1)$;
- if $\mathrm{key}(m) < t$, recurse on $[m+1, m+1+(\mathrm{len}-h-1))$ and add $1$
  to the cost;
- otherwise recurse on $[lo, lo+h)$ and add $1$ to the cost.

The second component counts key evaluations exactly.

**Theorem 8.2 (Exact complexity).** For all $lo$ and $\mathrm{len}$,
$$\mathrm{cost}\bigl(\mathrm{bsearch}(\mathrm{key}, t, lo, \mathrm{len})\bigr)
\;\le\; \log_2 \mathrm{len} + 1 .$$

*Proof sketch.* Strong induction on $\mathrm{len}$. For $\mathrm{len} \le 1$ the
search stops after at most one evaluation. For $\mathrm{len} \ge 2$ both
recursive ranges have size at most $\lfloor \mathrm{len}/2 \rfloor$, and
$\log_2\lfloor \mathrm{len}/2\rfloor + 1 = \log_2 \mathrm{len}$ in integer
logarithms; adding the single evaluation at the midpoint closes the induction.
$\square$

Note this is an exact arithmetic bound with explicit constants, not an
asymptotic statement.

**Theorem 8.3 (Soundness).** If $\mathrm{bsearch}$ returns an index $m$, then
$\mathrm{key}(m) = t$ and $lo \le m < lo + \mathrm{len}$. No monotonicity
hypothesis is required.

*Proof sketch.* Induction; the only place an index is produced is the midpoint
test, which checks $\mathrm{key}(m) = t$ directly, and the recursive ranges are
contained in the original. $\square$

**Theorem 8.4 (Completeness).** If $\mathrm{key}$ is monotone non-decreasing on
$[lo, lo+\mathrm{len})$ and some $j$ in that range has $\mathrm{key}(j) = t$,
then $\mathrm{bsearch}$ returns some index.

*Proof sketch.* Induction. If the midpoint value is $< t$, monotonicity forces $j
> m$, so $j$ lies in the right subrange; symmetrically on the other side. The
subrange hypotheses are restrictions of the original monotonicity. $\square$

The split of soundness from completeness is deliberate and load-bearing:
soundness holds for an *arbitrary* key function, so a decoder built on it cannot
be induced to lie by a badly behaved hash. Only the *usefulness* of the decoder
depends on sortedness.

### 8.2 The decoder

**Definition 8.5 (Binary-search decoder).** Given $\mathrm{key}$, the symbol
array $a$, the length $n$, and a received value $t$: run
$\mathrm{bsearch}(\mathrm{key}, t, 0, n)$. If it returns $\bot$, abstain. If it
returns $m$, evaluate $\mathrm{key}(m-1)$ and $\mathrm{key}(m+1)$ (where they
exist); if either equals $t$, abstain; otherwise return $a(m)$.

**Theorem 8.6 (Uniqueness from neighbours).** On a range whose key function is
monotone, an index $m$ whose key differs from those of both neighbours is the
unique index in $[0,n)$ with that key value.

*Proof sketch.* Monotone key values are constant on blocks of consecutive
indices, so a value repeated anywhere in the range is repeated at a neighbour of
any of its occurrences. $\square$

**Theorem 8.7 (No silent corruption, unconditionally).** The binary-search
decoder never returns a wrong codebook symbol, whatever the key function and
whatever the array — the only hypothesis used is Theorem 8.3.

**Theorem 8.8 (Total cost).** The binary-search decoder performs at most
$$\log_2 n + 3$$
key evaluations: at most $\log_2 n + 1$ in the search, plus at most two neighbour
evaluations.

**Theorem 8.9 (Sub-linear Monte-Carlo compression).** Let $H$ be 2-universal with
$K \ge 1$, $M \ge 1$, and let $l$ be a codebook with typicality parameter
$\delta$. Then there is a key $k$ such that the scheme with sorted codebook and
binary-search decoder satisfies
$$\Pr[\text{failure}] \le \delta + \frac{2|l|}{M}, \qquad
\Pr[\text{silent corruption}] \le \frac{2\delta|l|}{M},$$
and decodes in at most $\log_2|l| + 3$ key evaluations.

*Proof sketch.* Choose $k$ by Theorem 6.3. On a codebook symbol without
collisions, Lemma 7.5 and Theorem 8.4 give a hit and Theorem 8.6 passes the
neighbour test, so the decoder is correct; on a colliding codebook symbol the
neighbour test fails and it abstains. Theorem 8.7 gives the silent bound and
Theorem 8.8 the cost. $\square$

**Proposition 8.10 (Speedup is genuine).** $\log_2 n + 3 < n$ for every $n \ge
6$.

### 8.3 The decision-tree converse

Is $\log_2 n + 3$ optimal? We answer in a model far more general than binary
search.

**Definition 8.11 (Decision tree).** A decision tree over a query set $Q$ and an
output set $\iota$ is a finite binary tree whose internal nodes are labelled by
queries $q \in Q$ and whose leaves are labelled by outputs. An *input* is an
oracle $Q \to \mathrm{Bool}$; running the tree follows the branch given by the
oracle's answers. $\mathrm{runCost}$ is the number of queries actually asked.

This model subsumes every adaptive algorithm that learns about its input only
through Boolean tests — comparisons, key evaluations followed by a test,
arbitrary predicates.

**Lemma 8.12.** The set of outputs a tree can produce using at most $c$ queries
has at most $2^c$ elements.

*Proof sketch.* Induction on $c$: the outputs reachable within $c$ queries are the
union of those reachable within $c-1$ queries in the two subtrees. $\square$

**Theorem 8.13 (Cost converse).** Let $t$ be a decision tree, $S$ a set of $n$
distinct symbols, and $\mathrm{input}$ an assignment of oracles to symbols. If $t$
outputs $x$ correctly on $\mathrm{input}(x)$ for every $x \in S$, and
$\mathrm{runCost}(\mathrm{input}(x)) \le c$ for every $x \in S$, then $n \le 2^c$.

*Proof sketch.* Correctness embeds $S$ into the set of outputs reachable within
$c$ queries; apply Lemma 8.12. $\square$

**Corollary 8.14 (No sub-logarithmic decoder).** For any correct decoder and any
nonempty $S$, some input costs at least $\log_2 |S|$ queries.

**Theorem 8.15 (Optimality within an additive $3$).** For every correct
decision-tree decoder $t$ on a nonempty symbol set $S$, some $x \in S$ satisfies
$$\mathrm{cost}(\text{binary-search decoder on } |S| \text{ symbols}) \;\le\;
\mathrm{runCost}_t(\mathrm{input}(x)) + 3 .$$

**Corollary 8.16 (Block converse).** Any scheme decoding $b$ blocks by $b$
independent coordinatewise decoders, each correct on $n$ symbols, costs at least
$b \log_2 n$ queries in total; the coordinatewise binary-search scheme achieves
$b(\log_2 n + 3)$.

The worst-case cost of the sorted-codebook decoder is therefore within an additive
constant of the information-theoretic minimum, for *every* adaptive Boolean-query
algorithm — not merely within the class of comparison-based searches.

---

## 9. List decoding: the rate–list trade-off

### 9.1 Converse

**Definition 9.1 (List scheme).** A list scheme has $\mathrm{dec} : \mathcal{C}
\to \mathrm{List}(\alpha)$ with $|\mathrm{dec}(c)| \le T$ for all $c$; it
*succeeds* at $x$ if $x \in \mathrm{dec}(\mathrm{enc}(x))$.

**Theorem 9.2 (List converse).** For a list scheme with lists of length at most
$T$,
$$\Pr[\text{success}] \le T \cdot |\mathcal{C}| \cdot p_{\max}(\mu),$$
hence $\log|\mathcal{C}| + \log T \ge H_\infty(\mu) + \log(1-\varepsilon)$.

*Proof sketch.* Each codeword can "cover" at most $T$ symbols of the success set,
so $|\mathcal{S}| \le T|\mathcal{C}|$; then argue as in Theorem 3.3. $\square$

At $T = 1$ this is Theorem 3.4. So a list of length $T$ relaxes the counting
bound by exactly $\log T$ bits, and no more.

### 9.2 Linear gain from 2-universality

**Theorem 9.3 (Markov step).** For a 2-universal family, at most a $|l|/(TM)$
fraction of keys give a fixed symbol $x$ more than $T$ collision partners in the
codebook.

**Theorem 9.4 (List achievability).** There is a key with
$$\Pr[\text{failure}] \le \delta + \frac{|l|}{TM},$$
lists of length at most $T$, decoding cost exactly $|l|$, and the guarantee that
a non-empty answer *always contains the true symbol* when that symbol is in the
codebook.

The two sides match: list size $T$ costs $\log T$ bits in the converse and buys a
factor $T$ in the failure probability.

### 9.3 Exponential gain from higher independence

The factor-$T$ gain is exactly what a first moment yields. Higher independence
does better, and the correct statistic is the $T$-th *factorial* moment.

**Definition 9.5 ($T$-wise independence, counting form).** $H$ satisfies
$\mathrm{Indep}_T$ if for every set of $T$ symbols and every distinct symbol $x$,
the fraction of keys making all $T$ of them collide with $x$ is at most $M^{-T}$.

**Proposition 9.6 (Coherence).** $\mathrm{Indep}_1$ is exactly 2-universality.

**Theorem 9.7 (Factorial-moment identity).** Let $c_k = |\mathrm{Coll}_k(x)|$.
Then
$$M^T \sum_{k \in \mathcal{K}} \binom{c_k}{T} \;\le\; K \binom{|l|}{T}.$$

*Proof sketch.* Double count pairs (key, $T$-subset of the codebook all of whose
members collide with $x$ under that key). For each of the $\binom{|l|}{T}$
subsets, $\mathrm{Indep}_T$ bounds the number of keys by $K/M^T$. $\square$

**Theorem 9.8 (Exponential list gain).** Under $\mathrm{Indep}_T$ there is a key
with
$$\Pr[\text{failure}] \;\le\; \delta + \binom{|l|}{T}\Big/M^T \;\le\; \delta +
\Bigl(\frac{|l|}{M}\Bigr)^{T},$$
lists of length at most $T$, and decoding cost exactly $|l|$.

### 9.4 Short keys from Vandermonde

The obvious $\mathrm{Indep}_T$ family is the family of *all* functions $\alpha \to
[M]$, with $M^{|\alpha|}$ keys: exponentially long advice, useless in practice.

**Definition 9.9 (Polynomial family).** Over a prime field $\mathbb{F}_p$, with
key $c = (c_0,\dots,c_T) \in \mathbb{F}_p^{T+1}$, put
$$h_c(x) = c_0 + c_1 x + \cdots + c_T x^T \pmod p .$$

**Lemma 9.10 (Interpolation, counting form).** Two coefficient vectors in
$\mathbb{F}_p^{T+1}$ that agree at $T{+}1$ distinct points of $\mathbb{F}_p$ are
equal.

*Proof sketch.* The evaluation map at $T{+}1$ distinct points is given by a
Vandermonde matrix, whose determinant is nonzero precisely when the points are
distinct; hence the map is injective. $\square$

**Lemma 9.11.** At most $p$ keys make the polynomial take the same value at $x$
as at all $T$ points of a given $T$-set: the $T{+}1$ constraints pin the key down
up to the single common value.

**Theorem 9.12 (Short-key higher independence).** The degree-$T$ polynomial
family satisfies $\mathrm{Indep}_T$ with only $K = p^{T+1}$ keys, i.e.
$(T{+}1)\log_2 p$ bits of advice.

**Theorem 9.13 (Numeric instance).** Over $\mathbb{F}_{101}$, with a $10$-element
codebook carrying all but $1/100$ of the mass and $T = 3$: there is a key in
$\mathbb{F}_{101}^4$ (about $10^8$ keys, i.e. $27$ bits of advice, versus
$101^{101}$ for the full family) giving failure probability at most
$$\tfrac{1}{100} + \tfrac{1}{1000}$$
with lists of length at most $3$.

**Proposition 9.14 (Exponential key separation).** For $T + 1 < p$ the polynomial
key space $p^{T+1}$ is strictly smaller than the full family's $p^p$, and the gap
is exponential in $p$.

---

## 10. How much randomness does the encoder need?

Every achievability theorem above asserts the existence of a good key, so the
encoder stores $\log_2 K$ bits of advice. How small can $K$ be? Pigeonhole
answers once more, now aimed at the key space.

**Theorem 10.1 (Logarithmic lower bound).** A 2-universal family with $M \ge 2$,
at least one key, on a domain of size $n$, satisfies $n \le M^K$; equivalently $K
\ge \log_M n$.

*Proof sketch.* The map $x \mapsto (H_k(x))_{k \in \mathcal{K}}$ must be
injective, since two symbols agreeing on all keys would collide for all $K$ keys,
violating $K \cdot M \le K$ when $M \ge 2$. Hence $n \le M^K$. $\square$

So no constant-size family is universal on an unbounded source. But integrality
gives much more.

**Theorem 10.2 (Sharp bound).** A nonempty 2-universal family that compresses at
all — i.e. $M < n$ — has $K \ge M$.

*Proof sketch.* For $x \ne y$, the number of colliding keys is a natural number
$\le K/M$. If $K < M$ this number is $0$, so every $H_k$ is injective on a domain
of size $n > M$: impossible. $\square$

**Corollary 10.3.** $K \ge \max(M, \log_M n)$.

**Theorem 10.4 (Polynomial key space).** If the code space is a $c$-th root of
the source, $n \le M^c$, then $n \le K^c$. Hence the key space is polynomially
large in the source, and no 2-universal family in that regime has
$\mathrm{poly}(\log n)$ keys.

**Theorem 10.5 (The bound is attained).** The inner-product family of Definition
5.1 has exactly $K = M = p$ on a source of $n = p^2$ symbols.

The hierarchy is therefore settled in the compressing regime: the encoder's
advice must be at least as long as the codeword it produces, and one codeword's
worth of advice is enough. Randomness cannot be eliminated, but it can be reduced
to the minimum the counting bound permits.

---

## 11. Algorithms

We record the three procedures whose costs are proved above.

**Algorithm A (Encode).** Input: key $k$, codebook $l$, symbol $x$.
Output: $H_k(x)$. Cost: one key evaluation.

**Algorithm B (Linear unique-match decode).** Input: $k$, $l$, received $i$.
Scan $l$, evaluating $H_k$ on each entry, counting matches and remembering the
last one. Return the match if the count is exactly $1$, else $\bot$. Cost:
exactly $|l|$ key evaluations. Guarantee: never returns a wrong codebook symbol.

**Algorithm C (Sorted binary-search decode).** Preprocessing (once per key): sort
$l$ by $H_k$, obtaining arrays $\mathrm{key}$ and $a$. Query: binary search for
the received value; if found at index $m$, compare with the keys at $m-1$ and
$m+1$; return $a(m)$ if both differ, else $\bot$. Cost: at most $\log_2|l| + 3$
key evaluations. Guarantee: never returns a wrong symbol, under no hypothesis at
all on $H_k$.

Sorting is a one-time cost amortized over all queries with the same key, and it
does not appear in the per-query bound. Because sorting is a permutation of the
codebook, it changes no probability in the analysis.

---

## 12. Discussion

### 12.1 What the relaxation does and does not buy

The pairing of Theorem 3.4 with Theorem 3.6 is the cleanest statement of the
first message: relaxing exact decoding to $(1-\varepsilon)$-decoding moves the
counting bound by exactly $\log(1-\varepsilon)$ bits, and the relaxed bound is
achieved. On a uniform source that is a negligible gain. *Randomness does not buy
rate.*

What it buys is *implementability*. Under the exact requirement, the encoder must
be injective, so the code is essentially an enumeration of the alphabet. Under the
relaxed requirement, the code may be a hash — an object with a one-line
description, a one-field-element key, and a decoder that is a binary search. The
gain is entirely in description length and running time. This inverts the usual
framing of random coding, in which the rate is the headline and the algorithm an
afterthought.

### 12.2 The two-sidedness of every claim

Each of the four axes has a converse, and in each case the achievability is
within a constant of it:

| Axis | Achievability | Converse | Gap |
|---|---|---|---|
| Rate | $\log M$ with failure $\delta + \lvert l\rvert/M$ | $\log\lvert\mathcal{C}\rvert \ge H_\infty + \log(1-\varepsilon)$ | constant in $\varepsilon,\delta$, flatness |
| Rate with lists | failure $\delta + (\lvert l\rvert/M)^T$ | $\log\lvert\mathcal{C}\rvert + \log T \ge H_\infty + \log(1-\varepsilon)$ | exactly $\log T$ |
| Time | $\log_2 n + 3$ | $\ge \log_2 n$ for any adaptive Boolean-query decoder | additive $3$ |
| Randomness | $K = M = p$ realized | $K \ge \max(M, \log_M n)$ | exact |

### 12.3 No silent corruption

The design discipline followed throughout is that a failure must be *announced*.
Three independent mechanisms enforce this. (i) The unique-match rule makes silent
corruption impossible on codebook symbols, unconditionally. (ii) The
neighbour-uniqueness test does the same for the binary-search decoder, again with
no hypothesis on the hash. (iii) A checksum from a second universal family
reduces off-codebook silent corruption below any target at $\log C$ extra bits,
and the tunable threshold argument reduces it to $(1+\eta)\delta|l|/M$ for free.
Together these give a compressor whose worst realistic behaviour is "please
resend," not "here is a plausible wrong file."

### 12.4 Why min-entropy

Every converse here is a counting statement in disguise, and counting statements
convert to probability statements through $\mu(S) \le |S| p_{\max}$. That is why
$H_\infty$ and not $H$ appears. For sources that are far from flat this is
conservative — Shannon entropy is the right parameter for asymptotic block coding
— but for one-shot statements about a decoder that either does or does not get a
particular symbol right, min-entropy is the honest parameter, and the tightness
result of Theorem 3.6 shows it cannot be replaced by anything smaller in this
setting.

---

## 13. Future directions

Derived from the results above, each of the following is falsifiable: it admits
either an explicit counterexample or a proof.

**On the achieved bounds.** The exact pigeonhole bound says an everywhere-correct
code needs $|\alpha|$ codewords. Allowing failure probability $\varepsilon$
replaces this by $|\mathcal{C}| \ge (1-\varepsilon)/p_{\max}$, i.e.
$\log|\mathcal{C}| \ge H_\infty + \log(1-\varepsilon)$, and the bound is attained.
A 2-universal family gives an explicit key with failure $\le \delta + |l|/M$,
silent corruption $\le |l|/M$, no silent corruption at all on the codebook, and a
decoder costing exactly $|l|$ steps; the two sides differ by a factor depending
only on $\varepsilon$, $\delta$ and flatness. The inner-product family exhibits an
explicit compressor from $p^2$ symbols to $p$ codewords. Coordinatewise decoding
of a $b$-block product source keeps failure at $b(\delta + |T|/m)$ while cutting
cost from $|T|^b$ to $b|T|$. 2-universality is multiplicative under pairing, so a
checksum drives silent corruption to $|l|/(MC)$ at $\log C$ extra bits. Returning
$T$ candidates relaxes the counting bound by exactly $\log T$ and improves failure
by the factor $T$.

**Sub-linear decoding — resolved, in corrected form.** The natural conjecture
asked for a family that is 2-universal *and* monotone on every codebook. That
extra requirement turned out to be unnecessary and is the wrong way to look at the
problem: the encoder chooses its key first and then stores the codebook sorted by
hash value, which is a permutation of the codebook and therefore invisible to the
collision analysis. A cost-instrumented binary search with the exact bound
$\log_2 \mathrm{len} + 1$, plus a two-neighbour uniqueness test that forces
abstention on a duplicate hash, gives a decoder with no silent corruption and no
hypothesis on the hash at all, and a full scheme with failure $\le \delta +
2|l|/M$, silent corruption $\le 2\delta|l|/M$, and cost $\le \log_2|l| + 3$.

**Remaining questions.**

1. *Beyond worst case in the decision-tree converse.* The converse bounds the
   worst-case cost by $\log_2 n$. Is there a matching *average-case* converse,
   $\mathbb{E}[\mathrm{runCost}] \ge H(\mu)$, and does a codebook sorted by hash
   value but searched with a Huffman-shaped (rather than balanced) split achieve
   it?
2. *Closing the additive $3$.* Is the additive gap between $\log_2 n$ and
   $\log_2 n + 3$ removable, e.g. by folding the neighbour test into the search
   (a search for the boundary of the equal-key block rather than for any member of
   it)?
3. *Optimal thresholds beyond two regions.* The tunable derandomization uses two
   regions and the constraint $c_1^{-1} + c_2^{-1} \le 1$. For $r$ regions the
   analogous constraint is $\sum_i c_i^{-1} \le 1$. Which multi-region splits give
   the best simultaneous failure/silent/list guarantees, and is the resulting
   region of achievable triples exactly the one cut out by that constraint?
4. *Sharp key-length hierarchy for higher independence.* The bound $K \ge M$ is
   sharp for 2-universality. What is the sharp lower bound on $K$ for
   $\mathrm{Indep}_T$? The polynomial family gives $K = p^{T+1}$ with $M = p$; is
   $K \ge M^{T}$ or $K \ge M^{T+1}$ forced?
5. *Interaction of sorting with block decoding.* Coordinatewise decoding with
   sorted per-block codebooks costs $b(\log_2|T| + 3)$ against the converse
   $b\log_2|T|$. Is there a joint decoder over the product codebook beating $b
   \log_2 |T|$ by exploiting correlations between coordinates when the source is
   not i.i.d.?
6. *Checksums versus lists.* Both $\log C$ checksum bits and $\log T$ list bits
   buy reliability. Is there a single quantity — a "detection–ambiguity" budget —
   of which both are special cases, with a common converse?
7. *Non-uniform codebooks.* All bounds here treat the codebook as a set with a
   uniform collision budget. Weighting the codebook by $\mu$ and thresholding the
   *weighted* collision mass should give bounds in terms of Rényi entropies
   interpolating between $H_\infty$ and $H$; the first-moment machinery appears to
   carry over verbatim.

---

## 14. Conclusion

Almost-lossless compression is usually presented as a story about rate: random
codebooks approach entropy. The results assembled here suggest a different
emphasis. On the rate axis the relaxation is worth exactly $\log(1-\varepsilon)$
bits, and the bound it relaxes to is attained — so as a rate technique,
Monte-Carlo compression is nearly a no-op. Its real content is algorithmic. The
relaxation is what permits the code to be a keyed hash function instead of an
enumeration; the observation that the codebook may be sorted *after* the key is
fixed is what turns the resulting decoder from an exhaustive scan into a binary
search; and a decision-tree counting argument shows that the resulting cost,
$\log_2 n + 3$ key evaluations, is within an additive constant of the best any
adaptive algorithm can do. Along the way, three independent mechanisms guarantee
that the scheme's failures announce themselves rather than corrupting data
silently, and a pigeonhole argument applied to the key space shows that the
encoder's randomness must be at least one codeword long — and that one codeword's
worth suffices.
