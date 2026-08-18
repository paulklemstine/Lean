# Almost-Lossless Compression Beyond the Pigeonhole Bound: Exact Rates, Linear-Time Decoding, and Universal Error Detection

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

The pigeonhole principle forbids exact decoding of all source strings below the
counting bound: an encoder $E : \mathcal{A} \to [M]$ with a decoder exact on all
of $\mathcal{A}$ forces $M \ge |\mathcal{A}|$. Relaxing exactness to a failure
probability $\varepsilon$ — *almost-lossless* coding — relaxes the bound, and
Shannon's random-coding argument attains near-optimal rates. We give a complete,
finitary, measure-free development of this relaxation in which every probability
statement is an exact counting identity or inequality over the finite space of
all codebooks $H : \mathcal{A} \to [M]$, and we address the two questions that
the classical treatment leaves open: *decoder complexity* and *silent
corruption*.

Our contributions are: (1) an **exact** formula for the failure probability of
uniform random hashing, $1 - (1 - 1/M)^{|S|-1}$ on a typical set $S$, obtained
from an exact count of separating codebooks, which sharpens and explains both
the union bound and a matching Bonferroni lower bound; (2) a **converse** valid
for arbitrary encoder/decoder pairs, showing the set of exactly-decoded strings
has size at most $M$, hence $M \ge (1-\varepsilon)|S|$; (3) a **blocked
(product) random code** whose decoder costs exactly $b|T|$ hash comparisons
rather than $|T|^b$ — exponential to linear — at the cost of only a union-bound
factor $b$ in the failure probability, $\mathbb{P}[\text{failure}] \le
b(|T|-1)/M$; (4) a **universal error-detection theorem**: for an arbitrary,
possibly randomised inner decoder and *arbitrary* (typical or atypical) source
string, an independent random checksum of size $K$ bounds the probability of a
confident wrong output by $1/K$; and (5) a composite scheme with exact
complexity $b|T| + 1$, success probability $\ge 1-\varepsilon$ for $M \ge
b(|T|-1)/\varepsilon$, and silent-corruption probability $\le 1/K$ uniformly
over all source strings. We also show that the $\Theta(1/\varepsilon)$ overhead
of random hashing relative to the converse is intrinsic to uniform random
codebooks, and that derandomisation yields a fixed codebook with a small — but
provably never empty — bad set.

**Keywords:** almost-lossless compression, random coding, pigeonhole bound,
universal hashing, product codes, decoder complexity, error detection,
Bonferroni inequalities.

---

## 1. Introduction

### 1.1 The barrier

Let $\mathcal{A}$ be a finite source alphabet (think: the set of all $n$-symbol
strings) and let $[M] = \{0, 1, \dots, M-1\}$ be the set of codewords. The
foundational obstruction to compression is a counting statement.

> **Theorem 1 (Pigeonhole barrier).** Let $E : \mathcal{A} \to [M]$ and
> $D : [M] \to \mathcal{A}$ satisfy $D(E(x)) = x$ for all $x \in \mathcal{A}$.
> Then $|\mathcal{A}| \le M$.

*Proof.* $D \circ E = \mathrm{id}$ makes $E$ injective, and an injection into a
set of size $M$ forces $|\mathcal{A}| \le M$. $\square$

Equivalently, in contrapositive form: if $M < |\mathcal{A}|$ then every encoder
$E$ admits distinct $x \ne y$ with $E(x) = E(y)$, so no decoder can be exact
everywhere. The barrier is about counting, not computation; no algorithmic
ingenuity evades it.

### 1.2 The relaxation and the two open flanks

The classical escape is to demand exactness only with high probability. Fix a
**typical set** $S \subseteq \mathcal{A}$ — the strings the source actually
produces with non-negligible probability — and ask only that decoding succeed
with probability $\ge 1 - \varepsilon$. Shannon's random-coding argument then
achieves $\log_2 M \approx \log_2|S| + \log_2(1/\varepsilon)$ bits.

This is textbook. What is *not* settled by the textbook argument are two
practical flanks, which are the subject of this paper.

**(F1) Decoder complexity.** The random-coding decoder scans the whole typical
set: cost $|S|$, which is exponential in the block length. A scheme with
optimal rate and an unrunnable decoder is not a compression scheme.

**(F2) Silent corruption.** The classical soundness statement is conditional on
the transmitted string being typical. If the source emits an atypical string,
the decoder may confidently output a wrong string. We measure this loophole and
show it is real (probability $3/8$ in a small explicit instance), and then close
it.

### 1.3 Methodology: counting, not measure

Throughout, the probability space is the finite set of **all** functions
$H : \iota \to [M]$ on a finite index set $\iota$, with the uniform (counting)
measure; there are exactly $M^{|\iota|}$ of them. Every probabilistic assertion
below is therefore an identity or inequality between natural numbers, stated in
the multiplicative form $M \cdot |\mathcal{E}| \le c \cdot M^{|\iota|}$ rather
than $\mathbb{P}[\mathcal{E}] \le c/M$. This has two virtues: it is exact (no
rounding, no asymptotics), and it makes each step a finite combinatorial
identity. Real-valued corollaries are recorded where they aid interpretation.

---

## 2. The counting core of random coding

### 2.1 The codebook space

**Definition 1 (Codebook space).** For a finite index set $\iota$ and $M \ge 1$,
the codebook space is the set of all functions $H : \iota \to [M]$. Its
cardinality is $M^{|\iota|}$.

**Definition 2 (Collision event).** For $p, q \in \iota$, the *collision event*
is
$$\mathcal{C}(p,q) \;=\; \{H : \iota \to [M] \;:\; H(p) = H(q)\}.$$

The entire random-coding argument rests on one exact count.

> **Theorem 2 (Exact marginal count).** For $p \ne q$ in $\iota$,
> $$M \cdot |\mathcal{C}(p,q)| \;=\; M^{|\iota|},$$
> i.e. $\mathbb{P}[H(p) = H(q)] = 1/M$ exactly.

*Proof sketch.* Fibre the codebook space over the restriction to
$\iota \setminus \{q\}$. Each fibre is a free choice of $H(q)$ among $M$ values,
of which exactly one — namely $H(p)$ — lies in the event. Hence
$|\mathcal{C}(p,q)|$ is $M^{|\iota|-1}$, and multiplying by $M$ gives the claim.
Formally one exhibits a bijection between $\mathcal{C}(p,q)$ and the functions
on $\iota \setminus \{q\}$, using $p \ne q$ so that $H(p)$ is unaffected by the
deleted coordinate. $\square$

> **Theorem 3 (Union bound, counting form).** Let $P \subseteq \iota \times
> \iota$ be a finite set of pairs with $p_1 \ne p_2$ for every $p \in P$, and
> let $\mathcal{C}(P) = \bigcup_{p \in P} \mathcal{C}(p_1, p_2)$. Then
> $$M \cdot |\mathcal{C}(P)| \;\le\; |P| \cdot M^{|\iota|}.$$

*Proof sketch.* $|\mathcal{C}(P)| \le \sum_{p \in P} |\mathcal{C}(p_1,p_2)|$ by
subadditivity of cardinality over a union; apply Theorem 2 termwise. $\square$

---

## 3. The scanning decoder and its exact cost

Fix an enumeration $L$ of the typical set $S$: a duplicate-free list whose
members are exactly the elements of $S$.

**Definition 3 (Scan).** For a codebook $H$ and codeword $c$, the *scan*
traverses $L$ left to right, retaining the candidates $y$ with $H(y) = c$, and
counting one hash comparison per element inspected. Its outputs are the sublist
of matches and the count $|L|$.

**Definition 4 (Scanning decoder).** $\mathrm{Dec}(L, H, c)$ returns $y$ if the
scan's match list is exactly the singleton $[y]$, and *failure* otherwise
(zero matches or two or more). Its cost is the scan's count.

The singleton test is a built-in ambiguity detector: the decoder never
"chooses" between competing candidates.

> **Theorem 4 (Exact decoding complexity).** $\mathrm{Dec}(L, H, c)$ performs
> exactly $|L|$ hash comparisons, for every $H$ and every $c$.

*Proof sketch.* Induction on $L$: the scan increments its counter exactly once
per list element, irrespective of whether the element matches. $\square$

This is an equality, not a bound; there is no hidden constant.

> **Theorem 5 (Soundness — no silent corruption for typical inputs).** If
> $x \in L$ and $\mathrm{Dec}(L, H, H(x)) = y$ (an actual output, not failure),
> then $y = x$.

*Proof sketch.* Output occurs only when the match list is a singleton $[y]$.
Since $H(x) = H(x)$ and $x \in L$, the string $x$ is itself a match, so $x$
belongs to the match list; a singleton list containing $x$ must be $[x]$, whence
$y = x$. $\square$

Note the hypothesis $x \in L$. It is exactly this hypothesis that Section 7
removes, at the price of a checksum.

### 3.1 The failure event

**Definition 5 (Failure event).** For $x \in S$,
$$\mathcal{F}(S, x) \;=\; \{H : \exists\, y \in S \setminus \{x\},\ H(y) = H(x)\}.$$

> **Proposition 6.** If $H \notin \mathcal{F}(S,x)$ and $x \in S$, then
> $\mathrm{Dec}(L, H, H(x))$ outputs $x$ at a cost of exactly $|L| = |S|$
> comparisons.

*Proof sketch.* Off the failure event no other typical string shares $x$'s
codeword, so the match list is exactly $[x]$; the singleton test fires. Cost is
Theorem 4. $\square$

Since $\mathcal{F}(S,x) = \mathcal{C}(P)$ for
$P = \{(y,x) : y \in S \setminus \{x\}\}$, a set of $|S|-1$ pairs of distinct
elements, Theorem 3 yields immediately:

> **Theorem 7 (Random-coding bound).** For $x \in S$,
> $$M \cdot |\mathcal{F}(S,x)| \;\le\; (|S| - 1) \cdot M^{|\mathcal{A}|}.$$

> **Corollary 8 (Almost-lossless guarantee).** Let $\varepsilon > 0$ and
> $M \ge (|S| - 1)/\varepsilon$. Then for every fixed $x \in S$, a uniformly
> random codebook decodes $x$ correctly with probability at least
> $1 - \varepsilon$, at a decoding cost of exactly $|S|$ comparisons.

The rate is
$$\log_2 M \;\approx\; \log_2 |S| \;+\; \log_2 \tfrac{1}{\varepsilon},$$
against the pigeonhole requirement $\log_2 |\mathcal{A}|$ for exact decoding of
all strings. The reliability premium $\log_2(1/\varepsilon)$ is a constant,
independent of block length.

---

## 4. The exact failure probability

The union bound of Theorem 7 is not the truth. The truth is available in closed
form, and it comes from an exact count.

**Definition 6 (Separating codebooks).** For $x \in \mathcal{A}$ and a
competitor set $D \subseteq \mathcal{A}$ with $x \notin D$,
$$\mathrm{Sep}(D, x) \;=\; \{H : H(y) \ne H(x)\ \text{for all } y \in D\}.$$

> **Theorem 9 (Exact count of separating codebooks).** For $x \notin D$,
> $$M^{|D|} \cdot |\mathrm{Sep}(D,x)| \;=\; (M-1)^{|D|} \cdot M^{|\mathcal{A}|}.$$

*Proof sketch.* Induction on $D$. For $D = \emptyset$ both sides are
$M^{|\mathcal{A}|}$. For the inductive step, insert a new competitor
$a \notin D$ with $a \ne x$ and observe a bijection
$$\mathrm{Sep}(D \cup \{a\}, x) \times [M] \;\longleftrightarrow\;
  \mathrm{Sep}(D, x) \times [M-1]$$
obtained by fibring over the value $H(a)$: given the rest of the codebook — in
particular given $H(x)$, which does not involve the coordinate $a$ — the value
$H(a)$ ranges freely over $M$ symbols, of which exactly $M-1$ avoid $H(x)$.
Hence $|\mathrm{Sep}(D\cup\{a\},x)| \cdot M = |\mathrm{Sep}(D,x)| \cdot (M-1)$,
and multiplying the inductive hypothesis by $(M-1)$ closes the induction.
$\square$

Since a codebook fails at $x$ precisely when it fails to separate $x$ from
$S \setminus \{x\}$, the separating codebooks are the complement of the failure
event, which converts Theorem 9 into an exact failure count and thence:

> **Theorem 10 (Exact failure probability of uniform random hashing).** For
> $M \ge 1$ and $k = |S \setminus \{x\}|$,
> $$\frac{|\mathcal{F}(S,x)|}{M^{|\mathcal{A}|}} \;=\; 1 - \Bigl(1 - \frac{1}{M}\Bigr)^{k}.$$

This single identity subsumes the analysis:

- **Upper bound.** $1 - (1-1/M)^k \le k/M$ by Bernoulli's inequality, recovering
  Theorem 7.
- **Lower bound.** For $k \ll M$, $1 - (1-1/M)^k \approx k/M - \binom{k}{2}/M^2$,
  matching the Bonferroni bound of the next subsection.
- **Numerics.** It reproduces every measured value in Section 9 exactly.

### 4.1 A matching lower bound: the $1/\varepsilon$ overhead is real

The exact formula shows the union bound is tight to within a factor of two, but
it is instructive to derive the lower bound from a route that uses only
*pairwise* information — because that route is what generalises to other
codebook families.

> **Theorem 11 (Second Bonferroni inequality, counting form).** For a finite
> family $(A_i)_{i \in I}$ of finite sets,
> $$\sum_{i \in I} |A_i| \;\le\; \Bigl|\bigcup_{i \in I} A_i\Bigr| \;+\;
>   \sum_{(i,j) \in I^{\ne}} |A_i \cap A_j|,$$
> the second sum ranging over ordered pairs of distinct indices.

*Proof sketch.* Induction on $I$, using
$|A \cup B| = |A| + |B| - |A \cap B|$ at each insertion and bounding the
newly created intersections by the ordered-pair sum. $\square$

> **Lemma 12 (Double collisions).** For pairwise distinct $p, q, r \in \iota$,
> $$M^2 \cdot \bigl|\mathcal{C}(p,r) \cap \mathcal{C}(q,r)\bigr| \;\le\; M^{|\iota|}.$$

*Proof sketch.* The event forces $H(p) = H(q) = H(r)$: two independent
constraints, each cutting the codebook space by $M$. Fibring over the two
coordinates $p, q$ gives the count exactly. $\square$

> **Theorem 13 (Bonferroni lower bound).** With $k = |S \setminus \{x\}|$ and
> $N = M^{|\mathcal{A}|}$,
> $$k \, M \, N \;\le\; M^2 \, |\mathcal{F}(S,x)| \;+\; k(k-1)\, N.$$

*Proof sketch.* The failure event is exactly the union of the $k$ collision
events $\mathcal{C}(y, x)$, $y \in S \setminus \{x\}$. Apply Theorem 11 to this
family, multiply through by $M^2$, evaluate the left side with Theorem 2
($M \cdot |\mathcal{C}(y,x)| = N$, so $M^2 \sum_y |\mathcal{C}(y,x)| = kMN$),
and bound the $k(k-1)$ pairwise-intersection terms with Lemma 12. $\square$

> **Corollary 14 (Random hashing pays the $1/\varepsilon$ factor).** If
> $2(k-1) \le M$ then
> $$\frac{|\mathcal{F}(S,x)|}{M^{|\mathcal{A}|}} \;\ge\; \frac{k}{2M}.$$
> Consequently, achieving $\mathbb{P}[\text{failure}] \le \varepsilon$ with a
> uniformly random codebook requires $M \ge k/(2\varepsilon)$.

*Proof sketch.* Divide Theorem 13 by $M^2 N$ and use $k(k-1) \le kM/2$, which is
exactly the hypothesis $2(k-1) \le M$. $\square$

---

## 5. The converse: how much the relaxation actually buys

Corollary 14 is a statement about random hashing. What does information theory
permit in principle?

> **Theorem 15 (Converse / relaxed counting bound).** For *any* encoder
> $E : \mathcal{A} \to [M]$ and *any* decoder $D : [M] \to \mathcal{A} \cup
> \{\bot\}$ — randomised, adaptive, equipped with arbitrary side information
> baked in — the set
> $$G \;=\; \{x \in \mathcal{A} : D(E(x)) = x\}$$
> of exactly-decoded strings satisfies $|G| \le M$.

*Proof sketch.* $E$ restricted to $G$ is injective: if $x, y \in G$ and
$E(x) = E(y)$ then $x = D(E(x)) = D(E(y)) = y$. An injection from $G$ into
$[M]$ gives $|G| \le M$. $\square$

> **Corollary 16 (Rate converse).** If $D(E(x)) = x$ for all $x$ in a set $G$
> with $|G| \ge (1-\varepsilon)|S|$, then $M \ge (1-\varepsilon)|S|$.

So the pigeonhole bound relaxes by *exactly* the fraction of strings one is
willing to lose, and by nothing more: $\log_2 M \ge \log_2 |S| +
\log_2(1-\varepsilon)$.

**The gap.** Corollary 16 permits $M \approx (1-\varepsilon)|S|$; Corollary 14
shows uniform random hashing needs $M \gtrsim |S|/(2\varepsilon)$. The
multiplicative overhead $\Theta(1/\varepsilon)$ is therefore a property of the
random construction, not of the analysis. Section 10 conjectures that this gap
is intrinsic to all *pairwise-independent* codebook families.

### 5.1 Derandomisation, and its limit

> **Theorem 17 (Existence of a good deterministic codebook).** For $M \ge 1$
> there exists a codebook $H : \mathcal{A} \to [M]$ whose set of *ambiguous*
> typical strings,
> $$\mathrm{Bad}(S, H) = \{x \in S : \exists\, y \in S\setminus\{x\},\ H(y)=H(x)\},$$
> satisfies $M \cdot |\mathrm{Bad}(S,H)| \le |S|\,(|S|-1)$.

*Proof sketch.* Double counting: summing $|\mathrm{Bad}(S,H)|$ over all
codebooks equals summing $|\mathcal{F}(S,x)|$ over $x \in S$, since both count
pairs $(H, x)$ with $x$ ambiguous under $H$. Bound each inner term by Theorem 7
and pick a codebook minimising $|\mathrm{Bad}(S,\cdot)|$; the minimum is at most
the average. $\square$

In particular $M \ge |S|/\varepsilon$ gives a *fixed* codebook losing at most an
$\varepsilon$ fraction of $S$, at code length $\log_2 M$ — randomness is a proof
device, not a runtime requirement.

What derandomisation cannot do is produce a codebook with an *empty* bad set
whenever $M < |S|$: that would contradict Theorem 15. The averaging argument
gives a small bad set, never an empty one, and this is precisely the converse
bound biting.

---

## 6. Blocking: exponential-to-linear decoding

We now address flank (F1).

### 6.1 The construction

Let the source string be a $b$-tuple $x = (x_1, \dots, x_b)$ of *blocks* drawn
from a block alphabet $\beta$, with each block constrained to a per-block
typical set $T \subseteq \beta$. The global typical set is the product $T^b$.

> **Proposition 18.** $|T^b| = |T|^b$.

This is the candidate list the *flat* scheme of Section 3 would have to scan.

**Definition 7 (Blocked encoder).** Draw a single random codebook indexed by
position-value pairs, $H : \{1,\dots,b\} \times \beta \to [M]$, and set
$$\mathrm{Enc}(x) \;=\; \bigl(H(1, x_1),\, H(2, x_2),\, \dots,\, H(b, x_b)\bigr)
  \in [M]^b.$$

**Definition 8 (Blocked decoder).** Given $c = (c_1, \dots, c_b)$, run the
scanning decoder of Section 3 on each block independently, using the $i$-th
slice $y \mapsto H(i, y)$ of the codebook and the enumeration $L_T$ of $T$.
Output the tuple of block decodings if **every** block decodes unambiguously;
otherwise declare failure. The cost is the sum of the per-block costs.

### 6.2 Complexity

> **Theorem 19 (Exact complexity of the blocked decoder).** The blocked decoder
> performs exactly $b \cdot |T|$ hash comparisons, for every codebook and every
> received word.

*Proof sketch.* Each of the $b$ per-block calls costs exactly $|T|$ by
Theorem 4; the total is the constant sum $\sum_{i=1}^{b} |T| = b|T|$. $\square$

> **Theorem 20 (Exponential-to-linear separation).** For $t \ge 2$ and
> $b \ge 3$, $\;b\,t < t^{\,b}$. Consequently, for $|T| \ge 2$ and $b \ge 3$, the
> blocked decoder's cost $b|T|$ is strictly less than the flat decoder's cost
> $|T|^b$, and the gap grows exponentially in $b$.

*Proof sketch.* Induction on $b$. Base case $b = 3$: $t^3 \ge 4t > 3t$ for
$t \ge 2$. Inductive step: $(b+1)t = bt + t < t^b + t \le 2t^b \le t \cdot t^b =
t^{b+1}$, using $t \le t^b$ and $t \ge 2$. $\square$

### 6.3 Reliability

**Definition 9 (Blocked failure event).**
$$\mathcal{F}_{\mathrm{blk}}(T, x) = \bigl\{H : \exists\, i \le b,\ \exists\,
  y \in T \setminus \{x_i\},\ H(i,y) = H(i,x_i)\bigr\}.$$

> **Proposition 21.** If $x_i \in T$ for all $i$ and
> $H \notin \mathcal{F}_{\mathrm{blk}}(T,x)$, then the blocked decoder on
> $\mathrm{Enc}(x)$ outputs exactly $x$, at a cost of exactly $b|T|$.

*Proof sketch.* Off the blocked failure event, each slice $y \mapsto H(i,y)$
avoids the per-block failure event of Definition 5, so Proposition 6 applies to
each block; all $b$ blocks decode, so the conjunction test fires. $\square$

> **Theorem 22 (Blocked random-coding bound).** If $x_i \in T$ for all $i$, then
> $$M \cdot |\mathcal{F}_{\mathrm{blk}}(T,x)| \;\le\; b\,(|T| - 1) \cdot
>   M^{\,b\,|\beta|},$$
> i.e. $\mathbb{P}[\text{failure}] \le b(|T|-1)/M$.

*Proof sketch.* $\mathcal{F}_{\mathrm{blk}}(T,x)$ is contained in the multi-pair
collision event over
$$P = \bigcup_{i=1}^{b} \bigl\{\bigl((i,y),\,(i,x_i)\bigr) : y \in T \setminus
\{x_i\}\bigr\},$$
whose members are pairs of distinct indices (they differ in the second
coordinate) and whose cardinality is at most $\sum_{i} (|T|-1) = b(|T|-1)$ by
subadditivity of cardinality over a union of images. Apply Theorem 3 with index
set $\iota = \{1,\dots,b\} \times \beta$, of size $b|\beta|$. $\square$

> **Corollary 23 (Almost-lossless guarantee, blocked).** If $M \ge
> b(|T|-1)/\varepsilon$ then a uniformly random codebook recovers any fixed
> typical $x \in T^b$ with probability at least $1 - \varepsilon$, using
> exactly $b|T|$ hash comparisons.

**Interpretation.** Comparing Corollary 8 (flat) with Corollary 23 (blocked) at
equal reliability: the flat scheme needs $M_{\mathrm{flat}} \ge (|T|^b -
1)/\varepsilon$ and scans $|T|^b$ candidates; the blocked scheme needs
$M_{\mathrm{blk}} \ge b(|T|-1)/\varepsilon$ *per block* — total rate
$b\log_2 M_{\mathrm{blk}} \approx b\log_2|T| + b\log_2(b/\varepsilon)$ against
$\log_2|T^b| + \log_2(1/\varepsilon)$ — and scans $b|T|$ candidates. The
overhead is $b \log_2 b$ bits, i.e. $\log_2 b$ bits per block, in exchange for
an exponential-to-linear reduction in search.

### 6.4 Soundness survives the product

> **Theorem 24 (No silent corruption for the product code, typical inputs).** If
> every block $x_i$ of the transmitted string lies in $T$, and the blocked
> decoder outputs a string $z$, then $z = x$.

*Proof sketch.* An output of the blocked decoder means every block decoded
successfully, and the $i$-th block output is the $i$-th component of $z$. Apply
Theorem 5 to each block separately: since $x_i \in T$, the $i$-th block output
equals $x_i$. Hence $z = x$ componentwise. $\square$

---

## 7. Universal error detection: closing the atypical loophole

Theorems 5 and 24 both carry the hypothesis "the transmitted string is
typical". This hypothesis is not cosmetic. If $x \notin T^b$, the decoder may
find exactly one typical candidate sharing $x$'s codeword and output it with
full confidence. Section 9 measures this at probability $3/8$ in an explicit
tiny instance. Typicality-based reasoning therefore does **not** deliver a
no-silent-corruption guarantee.

**Definition 10 (Silent corruption).** A decoding outcome $o \in \mathcal{A}
\cup \{\bot\}$ is a *silent corruption* for the transmitted $x$ if $o \ne \bot$
and $o \ne x$: the decoder confidently outputs a wrong string. (An explicit
failure $\bot$ is not a silent corruption; it triggers retransmission.)

**Definition 11 (Checksummed scheme).** Draw an independent random function
$C : \mathcal{A} \to [K]$ and transmit $(H(x), C(x))$. On receipt of $(c, s)$,
run the inner decoder on $c$; if it proposes $y$, output $y$ only if
$C(y) = s$, and output $\bot$ otherwise.

> **Theorem 25 (Exact complexity with checksum).** The checksummed scanning
> decoder performs exactly $|L| + 1$ comparisons.

The main result of this section makes no assumption whatsoever on the inner
decoder.

> **Theorem 26 (Universal error-detection theorem).** Let $\Omega$ be any finite
> set of "inner randomness" values and let
> $$\mathrm{propose} : \Omega \times \mathcal{A} \to \mathcal{A} \cup \{\bot\}$$
> be an *arbitrary* function: any inner decoder, deterministic or randomised,
> honest or adversarial. Draw $w \in \Omega$ and $C : \mathcal{A} \to [K]$
> independently and uniformly. Then for **every** source string
> $x \in \mathcal{A}$ — typical or atypical, with no assumption on $x$ —
> $$K \cdot \bigl|\{(w, C) : \text{the checksummed output is a silent
>   corruption for } x\}\bigr| \;\le\; |\Omega| \cdot K^{|\mathcal{A}|},$$
> equivalently
> $$\mathbb{P}[\text{silent corruption}] \;\le\; \frac{1}{K}.$$

*Proof sketch.* The argument is **fibrewise**, i.e. conditional on the inner
randomness. Fix $w \in \Omega$ and consider the slice of bad checksums above it.
Two cases.

1. $\mathrm{propose}(w, x) = \bot$: the composite decoder outputs $\bot$
   regardless of $C$, so the slice is empty and the slice bound is trivial.
2. $\mathrm{propose}(w, x) = y_0$ for a *determined* string $y_0$. If
   $y_0 = x$ the composite output is either $x$ or $\bot$, never a silent
   corruption, and the slice is again empty. If $y_0 \ne x$, then a silent
   corruption requires the checksum test to pass, i.e. $C(y_0) = C(x)$; the
   slice is therefore contained in the collision event $\mathcal{C}(y_0, x)$ in
   the checksum codebook space, and Theorem 2 gives
   $K \cdot |\text{slice}| \le K^{|\mathcal{A}|}$.

In all cases $K \cdot |\text{slice}(w)| \le K^{|\mathcal{A}|}$. Summing over the
$|\Omega|$ fibres, and using that the silent set is contained in the disjoint
union of $\{w\} \times \text{slice}(w)$, yields the stated bound. $\square$

Three features deserve emphasis.

- **No hypothesis on $x$.** The bound is uniform over all source strings. This
  is exactly what the typicality-conditional soundness theorems fail to give.
- **No hypothesis on the inner decoder.** Its cleverness is quantified over
  *before* the checksum is drawn; conditioning on $w$ collapses the inner
  decoder to a single determined candidate $y_0$, after which only the
  independent checksum matters. This is why the result is universal.
- **The cost is $\log_2 K$ bits and one comparison.** $K = 2^{32}$ gives silent
  corruption below $2.4 \times 10^{-10}$; $K = 2^{64}$ gives $5.4 \times
  10^{-20}$.

---

## 8. The composite scheme

Assembling Sections 6 and 7:

**Definition 12 (Composite encoder/decoder).** Encode
$x \in \beta^{b}$ as $\bigl((H(1,x_1),\dots,H(b,x_b)),\, C(x)\bigr)$ with
$H$ a random block codebook into $[M]$ and $C$ an independent random checksum
into $[K]$. Decode by running the blocked decoder, then applying the checksum
test to its proposal.

> **Theorem 27 (Exact complexity).** The composite decoder performs exactly
> $b\,|T| + 1$ comparisons.

> **Theorem 28 (Reliability).** If every block of $x$ is typical, $M \ge
> b(|T|-1)/\varepsilon$, and $K \ge 1$, then the composite scheme recovers $x$
> with probability at least $1 - \varepsilon$.

*Proof sketch.* The good set of the composite scheme contains the full product
slab $(\text{good blocked codebooks}) \times (\text{all checksums})$: whenever
the blocked decoder outputs the correct $x$, the checksum test on $x$ passes
automatically since $C(x) = C(x)$. Hence
$|\mathrm{Good}_{\mathrm{comp}}| \ge |\mathrm{Good}_{\mathrm{blk}}| \cdot
K^{|\beta^{b}|}$, and dividing by the composite space size
$M^{b|\beta|} K^{|\beta^b|}$ reduces the claim to Corollary 23. The checksum
costs nothing in success probability. $\square$

> **Theorem 29 (Safety).** For **every** $x \in \beta^b$, typical or atypical,
> the composite scheme's probability of a confident wrong output is at most
> $1/K$.

*Proof sketch.* The composite decoder is literally "blocked inner decoder, then
checksum test", so Theorem 26 applies verbatim with
$\Omega = \{$block codebooks$\}$ and
$\mathrm{propose}(H, z) = $ blocked decoding of $\mathrm{Enc}_H(z)$. $\square$

**Summary of the scheme.**

| Quantity | Value |
|---|---|
| Rate | $b \log_2 M + \log_2 K$ bits, $\log_2 M \approx \log_2|T| + \log_2(b/\varepsilon)$ |
| Failure probability (typical input) | $\le \varepsilon$ for $M \ge b(|T|-1)/\varepsilon$ |
| Decoding complexity | exactly $b|T| + 1$ comparisons |
| Silent-corruption probability (any input) | $\le 1/K$ |
| Flat-scheme decoding complexity for comparison | $|T|^b$ |

Every entry is an exact statement, not an asymptotic one.

---

## 9. Numerical validation

All quantities below were obtained by exhaustive enumeration of the codebook
space on a small instance: source alphabet $\mathcal{A}$ of size $6$, typical
set $S = \{0,1,2\}$ so $|S| = 3$ and $k = 2$, codebook space of size $M^6$.

**Failure probability of uniform random hashing at $x = 0$:**

| $M$ | measured | exact formula $1-(1-1/M)^2$ | union bound $k/M$ | Bonferroni $k/(2M)$ |
|-----|----------|------------------------------|-------------------|---------------------|
| 2   | $3/4 = 0.750$    | $3/4$    | $1$                 | $1/2$    |
| 3   | $5/9 \approx 0.556$ | $5/9$ | $2/3 \approx 0.667$ | $1/3$    |
| 4   | $7/16 = 0.438$   | $7/16$   | $1/2$               | $1/4$    |
| 8   | $15/64 \approx 0.234$ | $15/64$ | $1/4$          | $1/8$    |
| 16  | $31/256 \approx 0.121$ | $31/256$ | $1/8$        | $1/16$   |

The measured column equals $(2M-1)/M^2$ in every row, confirming Theorem 10, and
lies between the two proved bounds, both tight to within a factor of two. (The
Bonferroni bound is stated for $2(k-1) \le M$, i.e. $M \ge 2$ here.)

**Good/bad partition.** For $M = 3$ the codebook space has $3^6 = 729$
elements; the good set has $324$ and the failure set $405$, and $324 + 405 =
729$ — the inequality $|\mathrm{Good}| + |\mathcal{F}| \ge M^{|\mathcal{A}|}$
underlying Corollary 8 is tight here.

**Decoder cost.** Decoding with the enumeration $[0,1,2]$ returns the correct
string at cost exactly $3$ comparisons, confirming Theorem 4.

**The atypical loophole.** With typical list $[1,2]$ and transmitted string
$x = 0$ (atypical), the fraction of codebooks under which the decoder produces a
confident output — necessarily wrong — is $3/8$ for $M = 4$. Adding an
independent checksum divides this: $3/16$ for $K = 2$, $3/32$ for $K = 4$,
exactly the $1/K$ scaling of Theorem 26.

**Blocked versus flat.** With $b = 3$ blocks over a binary block alphabet
($|T| = 2$), the blocked decoder costs $b|T| = 6$ comparisons while the product
typical set the flat decoder must scan has $|T|^b = 8$ elements — the separation
of Theorem 20 at its smallest nontrivial parameters. At realistic parameters
($|T| = 2^{20}$, $b = 50$) the comparison is $5.2 \times 10^7$ against
$2^{1000}$.

---

## 10. Discussion and open problems

### 10.1 What the results say

Three things are established that the classical presentation leaves implicit.

1. **The relaxation is exactly quantified.** The converse (Theorem 15) shows the
   pigeonhole bound relaxes by exactly the fraction of strings sacrificed;
   Theorem 10 says exactly how often uniform random hashing fails; Corollary 14
   says the $\Theta(1/\varepsilon)$ overhead of random hashing over the converse
   is intrinsic to the construction.
2. **The decoder-search obstacle is defeated, not merely deferred.** The product
   construction reduces the search from $|T|^b$ to exactly $b|T|$, paying
   $\log_2 b$ bits per block. Both endpoints of the trade-off are exact
   theorems.
3. **Silent corruption is a real loophole, and it is universally closable.**
   Typicality-conditional soundness is not a safety guarantee; the measured
   $3/8$ makes that concrete. One independent checksum closes it for *any*
   inner decoder, for *every* source string, at $1/K$.

### 10.2 What broke along the way

Two failed attempts are worth recording, because they shape the final
statements.

- The first version of the soundness theorem was stated only for typical inputs
  and was therefore useless as a "no silent corruption" guarantee. The honest
  fix was the fibrewise (conditional-independence) counting theorem of
  Section 7, which quantifies over all inner decoders and all inputs.
- An early attempt to bound the failure probability of a *fixed* codebook by
  the average failed. Derandomisation only yields a codebook whose bad set is
  small, never empty — which is exactly the converse bound (Theorem 15) biting.

### 10.3 Open problems

**Conjecture 1 (Rate–complexity is a genuine Pareto frontier).** Among all
schemes whose decoder inspects at most $C$ candidates, the minimal codebook size
for $(1-\varepsilon)$-reliability on a product typical set $T^b$ satisfies
$$\log M \;\ge\; \log|T^b| \;+\; \Omega\Bigl(\log\tfrac{1}{\varepsilon} \cdot
  \frac{\log |T^b|}{\log C}\Bigr).$$
Equivalently, every factor-of-two saving in decoder cost costs a fixed number of
extra bits of rate. The key insight is that blocking is not just one
construction but a *coordinate system*: the exponent $b$ in the union bound and
the exponent $1/b$ in the search cost are conjugate, so the achievable region
should be governed by a Legendre-type duality between the two exponents. Both
endpoints are now theorems (Theorem 4 with Theorem 7 at one end, Theorem 19 with
Theorem 22 at the other); only the interpolation and its converse are missing.

**Conjecture 2 (The $1/\varepsilon$ penalty is intrinsic to pairwise-independent
codebooks).** Corollary 14 shows uniform random hashing needs $M \gtrsim
|S|/\varepsilon$, while the converse (Corollary 16) shows $M \ge
(1-\varepsilon)|S|$ suffices information-theoretically. We conjecture the
$\Theta(1/\varepsilon)$ gap persists for *every* pairwise-independent codebook
family, and disappears only for families with $\Omega(\log(1/\varepsilon))$-wise
independence. The key insight is that Bonferroni's second inequality — the only
ingredient in the lower bound (Theorem 13) — depends solely on pairwise
marginals, so any family matching those marginals inherits the same lower bound;
escaping it requires controlling higher-order correlations, which is precisely
what higher-wise independence provides.

**Further directions.**

- *Non-uniform block typical sets.* Allowing $T_i$ to vary with $i$ replaces
  $b(|T|-1)$ by $\sum_i (|T_i| - 1)$ throughout; the exact analogue of
  Theorem 10 for the product code, $1 - \prod_i (1-1/M)^{|T_i|-1}$, should
  follow from the same separating-codebook induction.
- *Hierarchical blocking.* Iterating the product construction over a tree of
  depth $d$ should interpolate the Pareto frontier of Conjecture 1, with
  decoder cost $\Theta(d \cdot |T|^{b^{1/d}})$.
- *List decoding.* Replacing the singleton test by "at most $\ell$ matches"
  should reduce the failure probability from $\Theta(k/M)$ to
  $\Theta((k/M)^{\ell})$ while multiplying the output size by $\ell$; the
  separating-codebook count of Theorem 9 is the natural tool.
- *Checksums with structure.* Theorem 26 uses a fully random checksum. A
  pairwise-independent family (e.g. affine maps over a finite field) satisfies
  the same one-pair collision bound $1/K$ and would reduce the checksum's
  description length from $|\mathcal{A}|\log_2 K$ to $O(\log|\mathcal{A}| +
  \log K)$ bits, at no loss in the guarantee.

### 10.4 Conclusion

The pigeonhole barrier is a statement about exactness for all inputs. Relaxing
it to $\varepsilon$-reliability relaxes the counting bound by exactly the
fraction of inputs discarded. Shannon's random codebook attains near-optimal
rate but with an exponential decoder and a soundness guarantee that silently
assumes typicality. A product construction converts the exponential search into
a linear one for a logarithmic price in rate, and an independent checksum closes
the soundness loophole universally. The resulting scheme has an exact rate, an
exact failure bound, an exact operation count, and an exact bound on the one
quantity that actually matters in deployment: how often it lies.
