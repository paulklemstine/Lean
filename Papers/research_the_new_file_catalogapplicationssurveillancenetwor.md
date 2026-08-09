# Sharp Thresholds for Perfectly Private Reconstruction: Covering Radii, Binomial Converses, Orbit Distortion, and Tensorization

**Author:** Aristotle
**Date:** 2026-08-09

---

## Abstract

We study the fidelity attainable by a channel that leaks *nothing* about its
input. Formally, an observer is a map $\mathrm{obs} : S \to M$ from a finite
configuration space to a finite record alphabet; it is *perfectly private* when
$\mathrm{obs}$ is constant, so that the record is statistically independent of
the configuration. Paired with a decoder $\mathrm{dec} : M \to S$ and an integer
distortion $d$, such a channel realizes exactly the reconstructions of a single
fixed codeword, and the optimal worst-case distortion is the covering radius of
the one-codeword code, $R(d) = \min_c \max_s d(c,s)$.

Building on that threshold we prove four groups of results.

1. **Average-case theory.** Replacing almost-sure by expected distortion, we show
   that a perfectly private channel — deterministic *or* randomized — attains
   expected distortion $D$ against a source law $p$ if and only if some single
   reconstruction does. Hence the least attainable private expected distortion is
   the *private rate–distortion function* $D_{\mathrm{priv}}(p) = \min_c
   \mathbb{E}_p[d(c,X)]$, which satisfies $D_{\mathrm{priv}}(p) \le R(d)$. For
   binary configurations with Hamming distortion, the optimizer is the
   coordinatewise majority vote and $D_{\mathrm{priv}}(p) = \sum_i
   \min(\mathrm{mass}_i(0), \mathrm{mass}_i(1))$; for the uniform source this is
   exactly $|\alpha|/2$, strictly below the worst-case value $|\alpha|$.

2. **A measure-theoretic (Fano-type) converse.** For any nonnegative source law
   $p$ whose distortion balls have mass at most $\beta$, and any decoder correct
   on a good set $G$, we prove $p(G) \le \mathrm{rate}(\mathrm{obs}) \cdot \beta$,
   hence $1 - \varepsilon \le \mathrm{rate}\cdot\beta$ when the failure
   probability is at most $\varepsilon$. Specialized to the uniform source and
   Hamming distortion this reads $(1-\varepsilon)2^{|\alpha|} \le \mathrm{rate}
   \cdot \sum_{i \le D}\binom{|\alpha|}{i}$, and at $\mathrm{rate}=1$ it both
   lower-bounds the failure probability of a private observer by
   $1 - \mathrm{vol}_D / 2^{|\alpha|}$ and re-derives the sharp threshold at
   $\varepsilon = 0$ via the strict binomial inequality $\sum_{i\le D}\binom{n}{i}
   < 2^n$ for $D < n$.

3. **Distortion modulo relabeling.** Under the full symmetric group acting on
   coordinates, the orbit distortion satisfies $\mathrm{orb}(x,y) =
   |\mathrm{wt}(x)-\mathrm{wt}(y)|$; the relabeled private threshold is exactly
   $\lceil |\alpha|/2 \rceil$; an orbit ball of radius $D$ about a center of
   weight $k$ has exactly $\sum_{m=k-D}^{k+D}\binom{|\alpha|}{m}$ elements; and the
   rate converse survives the quotient as $2^{|\alpha|} \le \mathrm{rate}\cdot
   (2D+1)\binom{|\alpha|}{\lfloor |\alpha|/2\rfloor}$.

4. **Tensorization.** For an additive distortion on a product configuration
   space, $R(\sum_i d_i) = \sum_i R(d_i)$, and — with **no** independence
   assumption on the source — $D_{\mathrm{priv}}(p) = \sum_i
   D_{\mathrm{priv}}(\text{marginal}_i(p))$.

Applied to $T$-step histories of a directed network on $n$ participants
($|\alpha| = Tn^2$), the private worst-case distortion is $Tn^2$, the private
expected distortion against the uniform source is $Tn^2/2$, the relabeled
worst-case distortion is $\lceil Tn^2/2\rceil$, and the time-sliced threshold is
$\sum_{t<T} n^2$.

**Keywords:** covering radius, privacy threshold, rate–distortion, Hamming ball
volume, binomial tail, Burnside orbit counting, tensorization, surveillance
networks.

---

## 1. Introduction

### 1.1 Motivation

A surveillance network records a *history*: for each of $T$ time steps and each
ordered pair drawn from $n$ participants, one bit saying whether an interaction
occurred. The history is a point of $\{0,1\}^{\alpha}$ with $|\alpha| = T n^2$.
Publishing the history is useful and dangerous; the design question is what a
publication channel can achieve subject to a disclosure constraint.

We take the disclosure constraint to its extreme. A channel is *perfectly
private* if its output is independent of its input — the strongest conceivable
non-disclosure guarantee, and the natural boundary case against which weaker
guarantees (differential privacy, $k$-anonymity, noisy release) should be
calibrated. The question of this paper is: **what fidelity can a channel that
leaks nothing still deliver?**

The answer is purely combinatorial and, remarkably, exact in every regime we
consider.

### 1.2 The collapse principle

A perfectly private observer emits the same record whatever the world does.
Therefore the decoder receives no information and its output is a single point
$c \in S$ chosen in advance. The design problem — jointly optimize an encoder
and a decoder — collapses to: *place one point*. Every theorem below is a
measurement of the cost of that placement under a different notion of "cost":
worst case, expected, up to symmetry, or along a product decomposition.

### 1.3 Contributions and organization

Section 2 fixes notation and recalls the worst-case threshold and the counting
converse that anchor the theory. Section 3 develops the average-case theory and
the private rate–distortion function, including the majority-vote solution.
Section 4 proves the measure-theoretic converse and its uniform binomial form.
Section 5 treats distortion modulo relabeling. Section 6 proves tensorization,
in both the worst-case and the average-case forms. Section 7 assembles the
consequences for network histories. Section 8 gives algorithms. Section 9
discusses limits and open directions.

---

## 2. Setting

### 2.1 Configurations, observers, decoders, distortion

Throughout, $S$ is a finite nonempty set of *configurations* (states of the
world, histories) and $M$ a finite nonempty set of *records*.

**Definition 2.1 (observer, decoder, rate).** An *observer* is a map
$\mathrm{obs} : S \to M$; a *decoder* is a map $\mathrm{dec} : M \to S$. The
*rate* of an observer is the number of records it can produce,
$$
\mathrm{rate}(\mathrm{obs}) \;=\; \big|\{\mathrm{obs}(s) : s \in S\}\big|.
$$

**Definition 2.2 (distortion).** A *distortion* is a map $d : S \times S \to
\mathbb{N}$, where $d(c,s)$ is the penalty for reconstructing the configuration
$s$ as $c$. No symmetry or triangle inequality is assumed. Our main example is
the Hamming distortion on $S = \{0,1\}^{\alpha}$ ($\alpha$ finite),
$$
d_H(c,s) \;=\; \big|\{i \in \alpha : c_i \ne s_i\}\big| .
$$

**Definition 2.3 (perfect privacy).** An observer is *perfectly private* if
$\mathrm{obs}(s) = \mathrm{obs}(t)$ for all $s,t \in S$.

Perfect privacy immediately gives $\mathrm{rate}(\mathrm{obs}) = 1$: the image of
a constant map is a singleton. Conversely, on a nonempty $S$, rate $1$ implies
perfect privacy. Rate is therefore the natural *quantitative* relaxation of the
privacy constraint, and all converses below are stated with rate as a parameter,
the private case being $\mathrm{rate}=1$.

### 2.2 The covering radius and the worst-case threshold

**Definition 2.4 (one-codeword covering radius).**
$$
R(d) \;=\; \min_{c \in S} \max_{s \in S} d(c,s).
$$
Equivalently, $R(d) \le D$ if and only if some ball $B(c,D) = \{s : d(c,s)\le D\}$
equals all of $S$.

**Definition 2.5 (private achievability, worst case).** A budget $D$ is
*privately achievable* if there exist a perfectly private observer and a decoder
with $d(\mathrm{dec}(\mathrm{obs}(s)), s) \le D$ for every $s \in S$.

**Theorem 2.6 (sharp private threshold).** *$D$ is privately achievable if and
only if there exists $c \in S$ with $d(c,s)\le D$ for all $s$, i.e. if and only if
$D \ge R(d)$. The same characterization holds for randomized private channels
(record laws that do not depend on the configuration).*

*Proof sketch.* ($\Rightarrow$) A private observer is constant, say with value
$m_0$; then $\mathrm{dec}(m_0)$ is a valid center. ($\Leftarrow$) Given a center
$c$, take the constant observer and the constant decoder $m \mapsto c$. For the
randomized case: the mixture assigns positive probability to some record $m$, and
worst-case correctness of the mixture forces worst-case correctness of the
associated reconstruction $\mathrm{dec}(m)$. $\square$

**Theorem 2.7 (binary Hamming threshold).** *On $S = \{0,1\}^{\alpha}$,
$R(d_H) = |\alpha|$.*

*Proof sketch.* $\le$: any $c$ has $d_H(c,s)\le|\alpha|$. $\ge$: the complement
$\bar c$ has $d_H(c,\bar c) = |\alpha|$. (Section 6 gives a second, structurally
independent proof by tensorization.) $\square$

### 2.3 The fibre-covering converse

**Theorem 2.8 (counting converse).** *If $\mathrm{dec}(\mathrm{obs}(s))$ is within
distortion $D$ of $s$ for all $s$, and every ball of radius $D$ has at most $V$
elements, then $|S| \le \mathrm{rate}(\mathrm{obs}) \cdot V$.*

*Proof sketch.* Partition $S$ into the fibres $\mathrm{obs}^{-1}(m)$, $m$ in the
image. Each fibre is contained in $B(\mathrm{dec}(m), D)$, hence has at most $V$
elements; there are $\mathrm{rate}(\mathrm{obs})$ fibres. $\square$

**Proposition 2.9 (exact Hamming ball volume).** *In $\{0,1\}^{\alpha}$ with
$n = |\alpha|$, $|B(c,D)| = \sum_{i=0}^{D}\binom{n}{i}$ for every center $c$.*

Combining, $2^{n} \le \mathrm{rate}\cdot\sum_{i\le D}\binom{n}{i}$: to reconstruct
binary data at Hamming radius $D$ one must transmit at least
$n - \log_2 \sum_{i \le D}\binom{n}{i} \approx n(1 - h(D/n))$ bits, where $h$ is
the binary entropy function.

---

## 3. Average-case theory: the private rate–distortion function

Worst-case distortion is the pessimistic contract. We now grade the observer by
its expected distortion against a source law.

### 3.1 Definitions

Let $p : S \to \mathbb{R}$ be a source law (nonnegative, summing to $1$; several
statements below need only nonnegativity, and some need neither).

**Definition 3.1.** The *expected distortion of a single reconstruction*
$c \in S$ is $\mathrm{avg}(p,d,c) = \sum_{s} p(s)\, d(c,s)$. The *system expected
distortion* of an observer/decoder pair is
$\sum_s p(s)\, d(\mathrm{dec}(\mathrm{obs}(s)), s)$.

**Definition 3.2.** A budget $D \in \mathbb{R}$ is *privately achievable on
average* if some perfectly private observer and decoder have system expected
distortion at most $D$. It is *randomized-privately achievable on average* if
there are a channel $\mathrm{ch} : S \to (M \to \mathbb{R})$ with
$\mathrm{ch}(s,m)\ge 0$, $\sum_m \mathrm{ch}(s,m) = 1$, and $\mathrm{ch}(s)=\mathrm{ch}(t)$
for all $s,t$ (perfect privacy), and a decoder, with
$\sum_s p(s)\sum_m \mathrm{ch}(s,m)\, d(\mathrm{dec}(m), s) \le D$.

### 3.2 Privacy collapses the average-case problem too

**Theorem 3.3 (deterministic average-case threshold).** *$D$ is privately
achievable on average if and only if there is a single $c\in S$ with
$\mathrm{avg}(p,d,c)\le D$.*

*Proof sketch.* If $\mathrm{obs}$ is constant then $\mathrm{dec}(\mathrm{obs}(s))$
is the same point $c$ for every $s$, and the system expected distortion equals
$\mathrm{avg}(p,d,c)$ term by term. Conversely a constant observer paired with
the constant decoder $c$ realizes it. $\square$

**Theorem 3.4 (randomization does not help on average).** *$D$ is
randomized-privately achievable on average if and only if there is a single
$c\in S$ with $\mathrm{avg}(p,d,c)\le D$.*

*Proof sketch.* Write $q_m = \mathrm{ch}(s_0,m)$ for the (state-independent) record
law. Exchanging the order of summation,
$$
\sum_s p(s)\sum_m q_m\, d(\mathrm{dec}(m),s) \;=\; \sum_m q_m\, \mathrm{avg}(p,d,\mathrm{dec}(m)),
$$
a convex combination of the numbers $\mathrm{avg}(p,d,\mathrm{dec}(m))$ since
$q \ge 0$ and $\sum_m q_m = 1$. A convex combination is at least its minimum, so
choosing $m^\star$ minimizing $\mathrm{avg}(p,d,\mathrm{dec}(m))$ gives a single
reconstruction at least as good. Note this argument uses no property of $p$
whatsoever. The converse direction is the point mass channel. $\square$

Theorem 3.4 is not a restatement of Theorem 2.6: the worst-case argument is about
supports (some record occurs, and it must already be good), while this one is
about convexity (the mixture is dominated by its best component). The two
notions of private achievability therefore coincide.

### 3.3 The private rate–distortion function

**Definition 3.5.** The *private rate–distortion function* is
$$
D_{\mathrm{priv}}(p,d) \;=\; \min_{c\in S}\, \mathrm{avg}(p,d,c) \;=\; \min_{c\in S}\, \mathbb{E}_p\big[d(c,X)\big].
$$

**Theorem 3.6 (optimality).** *$D_{\mathrm{priv}}(p,d)$ is the least
privately-achievable-on-average budget: it is achievable, and every achievable
budget is at least it.*

*Proof sketch.* The minimum over the finite set $S$ is attained at some
$c^\star$, which witnesses achievability by Theorem 3.3; conversely any achievable
$D$ dominates $\mathrm{avg}(p,d,c)$ for some $c$, hence dominates the minimum.
$\square$

**Theorem 3.7 (averaging never costs more).** *If $p$ is a probability law then
$D_{\mathrm{priv}}(p,d) \le R(d)$.*

*Proof sketch.* Take $c$ realizing the covering radius; then
$\mathrm{avg}(p,d,c) \le \sum_s p(s) R(d) = R(d)$. $\square$

### 3.4 Exact solution for Hamming distortion: the majority vote

Let $S = \{0,1\}^{\alpha}$.

**Definition 3.8.** For a coordinate $i$ and a bit $b$, the *disagreeing mass* is
$\mathrm{mass}_p(i,b) = \sum_{x : x_i \ne b} p(x) = \mathbb{P}_p[X_i \ne b]$.

**Lemma 3.9 (coordinate decomposition).** *$\mathrm{avg}(p,d_H,c) = \sum_{i\in\alpha}
\mathrm{mass}_p(i, c_i)$.*

*Proof sketch.* Write $d_H(c,x) = \sum_i \mathbf{1}[x_i \ne c_i]$, multiply by
$p(x)$, and exchange the two sums; the inner sum over $x$ with $x_i \ne c_i$ is
exactly $\mathrm{mass}_p(i,c_i)$. $\square$

**Definition 3.10 (majority vote).** $\mathrm{maj}_p(i) = 0$ if
$\mathrm{mass}_p(i,0)\le \mathrm{mass}_p(i,1)$, and $1$ otherwise. Thus
$\mathrm{mass}_p(i,\mathrm{maj}_p(i)) = \min(\mathrm{mass}_p(i,0),\mathrm{mass}_p(i,1))$.

**Theorem 3.11 (exact private rate–distortion function, Hamming).**
$$
D_{\mathrm{priv}}(p,d_H) \;=\; \sum_{i\in\alpha} \min\big(\mathrm{mass}_p(i,0),\, \mathrm{mass}_p(i,1)\big),
$$
*and the coordinatewise majority vote attains it.*

*Proof sketch.* Upper bound: evaluate Lemma 3.9 at $c = \mathrm{maj}_p$. Lower
bound: for any $c$, each summand $\mathrm{mass}_p(i,c_i)$ is one of the two values
being minimized, hence at least their minimum; sum over $i$. Because the
distortion is additive over coordinates and the reconstruction alphabet is a full
product, the minimization separates completely — this is the structural reason a
closed form exists. $\square$

### 3.5 The uniform source: exactly one half

**Lemma 3.12.** *In $\{0,1\}^{\alpha}$, for every coordinate $i$ and bit $b$,
exactly half of the $2^{|\alpha|}$ tensors satisfy $x_i \ne b$.*

*Proof sketch.* The involution $x \mapsto x$ with the $i$-th coordinate flipped is
a bijection between $\{x : x_i = b\}$ and $\{x : x_i \ne b\}$. $\square$

**Corollary 3.13.** *Under the uniform law, $\mathrm{mass}(i,b) = 1/2$ for all
$i,b$, hence*
$$
D_{\mathrm{priv}}(\mathrm{unif}, d_H) \;=\; \frac{|\alpha|}{2}.
$$

**Corollary 3.14 (strict separation).** *If $\alpha \ne \emptyset$ then
$D_{\mathrm{priv}}(\mathrm{unif}, d_H) = |\alpha|/2 < |\alpha| = R(d_H)$:
grading on average instead of always buys exactly a factor of two — and, by
Theorem 3.7, never more than the worst case.*

**Corollary 3.15 (operational form).** *Against a uniform source, a perfectly
private observer (deterministic or randomized) meets the expected Hamming budget
$D$ if and only if $D \ge |\alpha|/2$.*

The value $|\alpha|/2$ is exactly the expected Hamming distance of a uniformly
random guess: perfect privacy leaves the observer no better than a coin.

---

## 4. A measure-theoretic (Fano-type) converse

The counting converse of Theorem 2.8 speaks about cardinalities and about
correctness *everywhere*. Real systems fail sometimes, and the natural currency
is probability. Both generalizations are handled by one inequality.

### 4.1 The weighted fibre decomposition

**Theorem 4.1 (measure fibre-covering converse).** *Let $p : S \to \mathbb{R}$
satisfy $p \ge 0$, let $d$ be a distortion, $D \in \mathbb{N}$, and suppose every
ball has mass at most $\beta$:*
$$
\sum_{s \,:\, d(c,s)\le D} p(s) \;\le\; \beta \qquad \text{for all } c \in S .
$$
*Let $G \subseteq S$ be a set on which the decoder is correct, i.e.
$d(\mathrm{dec}(\mathrm{obs}(s)),s)\le D$ for all $s\in G$. Then*
$$
\sum_{s\in G} p(s) \;\le\; \mathrm{rate}(\mathrm{obs}) \cdot \beta .
$$

*Proof sketch.* First, $\beta \ge 0$, since it dominates the mass of some ball,
which is nonnegative. Decompose $G$ into fibres,
$$
G \;=\; \biguplus_{m \,\in\, \mathrm{obs}(G)} \big(G \cap \mathrm{obs}^{-1}(m)\big),
$$
a disjoint union, so $p(G)$ is the sum of the fibre masses. Fix $m$: every
$s \in G$ with $\mathrm{obs}(s)=m$ satisfies $d(\mathrm{dec}(m),s)\le D$, so the
fibre is a subset of $B(\mathrm{dec}(m),D)$. Because $p \ge 0$, passing to a
superset can only increase the sum, so the fibre mass is at most $\beta$. Hence
$p(G) \le |\mathrm{obs}(G)| \cdot \beta \le \mathrm{rate}(\mathrm{obs})\cdot\beta$,
the last step using $\beta \ge 0$ and $\mathrm{obs}(G)\subseteq \mathrm{obs}(S)$.
$\square$

Two remarks. First, this is literally the counting proof with the counting
measure replaced by $p$; the two are the same inequality over two different
semirings. Second, nonnegativity of $p$ is genuinely load-bearing — the step
"subset has smaller mass" fails for signed weights, and so does the theorem.

### 4.2 The excess-distortion form

**Theorem 4.2 (Fano-type excess-distortion converse).** *Let $p$ be a probability
law with $p \ge 0$ and $\sum_s p(s) = 1$, let every ball have mass at most
$\beta$, let $G$ be a good set as above, and suppose the failure event has small
mass, $\sum_{s\notin G} p(s) \le \varepsilon$. Then*
$$
1 - \varepsilon \;\le\; \mathrm{rate}(\mathrm{obs}) \cdot \beta .
$$

*Proof sketch.* $p(G) + p(S\setminus G) = 1$ and $p(S\setminus G)\le\varepsilon$
give $p(G) \ge 1-\varepsilon$; apply Theorem 4.1. $\square$

This is the combinatorial skeleton of the classical rate–distortion converse.
Reading $\log \mathrm{rate}$ as the number of transmitted bits and $\beta$ as
$\mathrm{vol}_D/|S|$, it says that the transmitted bits plus the log-volume of a
distortion ball must cover the log-volume of the space, minus a slack accounted
for by the failure probability $\varepsilon$.

### 4.3 The uniform binary specialization

Let $S = \{0,1\}^{\alpha}$, $n = |\alpha|$, and let $\mathrm{unif}$ be the uniform
law $p(x) = 2^{-n}$.

**Lemma 4.3 (uniform ball mass).** *For every center $c$,*
$$
\sum_{s\,:\, d_H(c,s)\le D} \mathrm{unif}(s) \;=\; \frac{\sum_{i=0}^{D}\binom{n}{i}}{2^{n}} .
$$

*Proof sketch.* The ball has exactly $\sum_{i\le D}\binom{n}{i}$ elements
(Proposition 2.9), each of mass $2^{-n}$. $\square$

**Theorem 4.4 (concrete excess-distortion bound).** *If an observer/decoder pair
reconstructs every configuration outside a failure event of uniform probability
at most $\varepsilon$ within Hamming distortion $D$, then*
$$
(1-\varepsilon)\, 2^{n} \;\le\; \mathrm{rate}(\mathrm{obs}) \cdot \sum_{i=0}^{D}\binom{n}{i} .
$$

*Proof sketch.* Apply Theorem 4.2 with $\beta$ equal to the exact ball mass of
Lemma 4.3 and clear the positive denominator $2^n$. $\square$

**Theorem 4.5 (private observers).** *A perfectly private observer has
$\mathrm{rate}=1$, hence*
$$
(1-\varepsilon)\,2^{n} \;\le\; \sum_{i=0}^{D}\binom{n}{i} .
$$

**Corollary 4.6 (failure probability of a private observer).** *A perfectly
private observer working at Hamming radius $D$ must fail with probability*
$$
\varepsilon \;\ge\; 1 - \frac{\sum_{i=0}^{D}\binom{n}{i}}{2^{n}} \;=\; \mathbb{P}\big[\mathrm{Bin}(n,\tfrac12) > D\big].
$$

That is: a private observer's failure probability is at least the upper tail of a
fair binomial, which for $D = (1/2 - \delta)n$ is $1 - e^{-\Theta(\delta^2 n)}$ —
exponentially close to certain failure.

### 4.4 The threshold as the zero-excess corner

**Lemma 4.7 (strict binomial tail).** *If $D < n$ then $\sum_{i=0}^{D}\binom{n}{i}
< 2^{n}$.*

*Proof sketch.* $\sum_{i=0}^{n}\binom{n}{i} = 2^n$, the range $\{0,\dots,D\}$ is a
proper subset of $\{0,\dots,n\}$ missing the index $n$, and the omitted term
$\binom{n}{n} = 1$ is strictly positive while all terms are nonnegative.
$\square$

**Theorem 4.8 (zero excess forces full distortion).** *If a perfectly private
observer reconstructs* every *configuration in $\{0,1\}^{\alpha}$ within Hamming
distortion $D$, then $D \ge n = |\alpha|$.*

*Proof sketch.* Take $\varepsilon = 0$ and $G = S$ in Theorem 4.5, giving
$2^n \le \sum_{i\le D}\binom{n}{i}$; if $D<n$ this contradicts Lemma 4.7.
$\square$

Theorem 4.8 is the sharp threshold of Theorem 2.7 re-derived, by a volume
inequality rather than by a covering argument — the two proofs are logically
independent, so this is a genuine cross-validation and not a restatement. The
picture is that the qualitative threshold theorem is precisely the zero-slack
corner of a quantitative inequality with a continuous knob $\varepsilon$.

---

## 5. Distortion modulo relabeling

For network data the identities of participants are often irrelevant: two
histories that differ by a permutation of the nodes describe the same social
phenomenon. We therefore quotient the distortion by the relabeling action.

### 5.1 Orbit distortion equals the weight gap

Let the symmetric group $\mathrm{Sym}(\alpha)$ act on $\{0,1\}^{\alpha}$ by
precomposition, $x \mapsto x\circ g$.

**Definition 5.1.** The *orbit distortion* is
$\mathrm{orb}(x,y) = \min_{g \in \mathrm{Sym}(\alpha)} d_H(x\circ g,\, y)$.

Write $\mathrm{supp}(x) = \{i : x_i = 1\}$ and $\mathrm{wt}(x) = |\mathrm{supp}(x)|$.

**Theorem 5.2 (exact orbit distance).**
$$
\mathrm{orb}(x,y) \;=\; \big|\,\mathrm{wt}(x)-\mathrm{wt}(y)\,\big| .
$$

*Proof sketch.* Relabeling preserves weight, $\mathrm{wt}(x\circ g)=\mathrm{wt}(x)$,
and for any two tensors $\mathrm{wt}(u)\le \mathrm{wt}(v) + d_H(u,v)$ (each unit of
weight difference must be witnessed by a disagreeing coordinate); applying this
in both directions gives $d_H(x\circ g, y)\ge |\mathrm{wt}(x)-\mathrm{wt}(y)|$ for
every $g$, hence the lower bound. For the upper bound one constructs an explicit
relabeling: for an admissible target weight $k$ there is an indicator tensor
$\mathbf{1}_T$ with $|T| = k$ whose support is a subset or superset of
$\mathrm{supp}(y)$, so that $d_H(\mathbf{1}_T, y) = |k - \mathrm{wt}(y)|$ exactly;
transitivity of the relabeling action on each weight class (extend a bijection
between supports to a permutation of $\alpha$) then produces $g$ with
$x\circ g = \mathbf{1}_T$. $\square$

Theorem 5.2 reduces every relabeling-invariant question to a one-dimensional
question about weights in $\{0,1,\dots,n\}$.

### 5.2 The relabeled threshold: exactly $\lceil n/2\rceil$

**Theorem 5.3 (sharp relabeled private threshold).**
$$
R(\mathrm{orb}) \;=\; \Big\lceil \frac{n}{2}\Big\rceil \;=\; \Big\lfloor\frac{n+1}{2}\Big\rfloor .
$$

*Proof sketch.* $\le$: choose a center $c$ of weight $\lfloor n/2 \rfloor$; for any
$s$, $|\mathrm{wt}(c)-\mathrm{wt}(s)| \le \max(\lfloor n/2\rfloor,\, n-\lfloor n/2\rfloor)
= \lceil n/2\rceil$. $\ge$: any center $c$ is tested against the all-zero and
all-one tensors, giving $R \ge \max(\mathrm{wt}(c),\, n-\mathrm{wt}(c)) \ge \lceil n/2\rceil$.
$\square$

**Corollary 5.4 (operational form).** *A perfectly private observer meets a
relabeling-tolerant worst-case budget $D$ if and only if $D \ge \lceil n/2\rceil$.*

**Corollary 5.5.** *For $n \ge 2$, $R(\mathrm{orb}) < R(d_H)$: quotienting by the
full relabeling group buys exactly a factor of two, and no more.*

### 5.3 Orbit volumes and the surviving rate converse

**Theorem 5.6 (exact orbit volume).** *The set of tensors of weight $m$ — a single
orbit of the relabeling action — has exactly $\binom{n}{m}$ elements.*

*Proof sketch.* The support map is a bijection onto the $m$-subsets of $\alpha$,
with inverse $T \mapsto \mathbf{1}_T$. $\square$

**Theorem 5.7 (exact orbit ball volume).** *An orbit ball of radius $D$ about a
center $c$ of weight $k$ is the disjoint union of the weight layers with weights
in $[k-D, k+D]$, hence*
$$
\big|\{s : \mathrm{orb}(c,s)\le D\}\big| \;=\; \sum_{m=k-D}^{k+D} \binom{n}{m}.
$$

*Proof sketch.* By Theorem 5.2, $\mathrm{orb}(c,s)\le D$ iff $|\mathrm{wt}(c) -
\mathrm{wt}(s)| \le D$ iff $\mathrm{wt}(s) \in [k-D,k+D]$; the layers are disjoint
and Theorem 5.6 gives their sizes. $\square$

This is the orbit-counting ("Burnside") analogue of the Hamming ball volume: the
ball is a union of whole orbits, and each orbit's size is a binomial coefficient.

**Corollary 5.8 (orbit ball bound).** *Since $\binom{n}{m}\le\binom{n}{\lfloor n/2\rfloor}$
and the interval $[k-D,k+D]$ contains at most $2D+1$ integers,*
$$
\big|\{s : \mathrm{orb}(c,s)\le D\}\big| \;\le\; (2D+1)\binom{n}{\lfloor n/2\rfloor}.
$$

**Theorem 5.9 (quantitative converse modulo relabeling).** *Any observer/decoder
pair achieving relabeled worst-case distortion $D$ satisfies*
$$
2^{n} \;\le\; \mathrm{rate}(\mathrm{obs}) \cdot (2D+1)\binom{n}{\lfloor n/2\rfloor}.
$$

*Proof sketch.* Theorem 2.8 with the orbit ball bound of Corollary 5.8 and
$|S| = 2^n$. $\square$

Because $\binom{n}{\lfloor n/2\rfloor} \sim 2^{n}\sqrt{2/(\pi n)}$, Theorem 5.9
forces $\mathrm{rate} \gtrsim \sqrt{\pi n/2}/(2D+1)$: even judged only up to
relabeling, an accurate observer must emit many distinct records. Anonymity
softens the geometry but does not make disclosure free.

---

## 6. Tensorization: privacy budgets add

Histories are naturally indexed by time; a causal observer produces the record
online. The structural fact that makes a per-step analysis lossless is
additivity.

Let $\sigma_i$, $i \in \iota$, be finite nonempty sets and $S = \prod_i \sigma_i$.

**Definition 6.1.** For componentwise distortions $d_i$ on $\sigma_i$, the
*additive product distortion* is $d(c,s) = \sum_i d_i(c_i, s_i)$.

### 6.1 Worst case

**Theorem 6.2 (tensorization of the private threshold).**
$$
R\Big(\textstyle\sum_i d_i\Big) \;=\; \sum_i R(d_i).
$$

*Proof sketch.* ($\le$) Choose for each $i$ a center $c_i$ realizing $R(d_i)$ and
form the product center $c = (c_i)_i$; then $d(c,s) = \sum_i d_i(c_i,s_i) \le
\sum_i R(d_i)$ for all $s$. ($\ge$) Let $c$ realize $R(\sum_i d_i)$. For each $i$
there exists $s_i \in \sigma_i$ with $d_i(c_i, s_i) \ge R(d_i)$: otherwise $c_i$
would cover $\sigma_i$ at radius $R(d_i)-1$, contradicting minimality of the
componentwise covering radius. Assembling the witnesses into
$s = (s_i)_i$ gives $R(\sum_i d_i) \ge d(c,s) = \sum_i d_i(c_i,s_i) \ge \sum_i R(d_i)$.
$\square$

Both nonemptiness and finiteness of the factors are used: an empty factor is
vacuously covered at radius $0$ and the witness-extraction step has nothing to
extract.

**Corollary 6.3 (operational form).** *A perfectly private observer of a product
system meets the worst-case budget $D$ if and only if $D \ge \sum_i R(d_i)$: the
private budget must be split across components and no cross-component trade is
possible.*

### 6.2 An independent re-derivation of the Hamming threshold

**Definition 6.4.** The two-point distortion on a bit is
$d_{\mathrm{bit}}(a,b) = 1$ if $a\ne b$, else $0$.

**Lemma 6.5.** *$R(d_{\mathrm{bit}}) = 1$.*

*Proof sketch.* $\le 1$ trivially; and $\ne 0$ because for any candidate center
$c$ the opposite bit is at distance $1$. $\square$

**Lemma 6.6.** *Binary Hamming distortion is the additive product of $|\alpha|$
copies of $d_{\mathrm{bit}}$.*

**Theorem 6.7.** *$R(d_H) = |\alpha|$.*

*Proof sketch.* Lemmas 6.5–6.6 and Theorem 6.2: $\sum_{i\in\alpha} 1 = |\alpha|$.
$\square$

This is a structurally different proof from Theorem 2.7 (which used the
antipode), so the two together cross-validate the constant.

**Corollary 6.8 (time-sliced histories).** *Viewing a $T$-step history as $T$
snapshots with additive per-snapshot Hamming distortion, the private worst-case
distortion is $\sum_{t<T} n^2 = Tn^2$: the per-step thresholds add along the
filtration, so imposing a per-step privacy budget is without loss relative to a
global one.*

### 6.3 Average case, without independence

**Definition 6.9.** The $i$-th *marginal* of a source law $p$ on $\prod_i \sigma_i$
is $\mathrm{marg}_i(p)(a) = \sum_{s : s_i = a} p(s)$.

**Lemma 6.10 (splitting of the expected distortion).** *For any $p$, additive $d$
and any single reconstruction $c$,*
$$
\mathbb{E}_p\Big[\sum_i d_i(c_i, X_i)\Big] \;=\; \sum_i \sum_{a\in\sigma_i} \mathrm{marg}_i(p)(a)\, d_i(c_i, a).
$$

*Proof sketch.* Expand the sum defining the expectation, exchange the order of
summation, and group the states by the value of the $i$-th coordinate
(fibrewise summation). $\square$

**Theorem 6.11 (average-case tensorization).** *For an additive distortion on a
product configuration space and **any** source law $p$ — with no independence
assumption —*
$$
D_{\mathrm{priv}}(p, \textstyle\sum_i d_i) \;=\; \sum_i D_{\mathrm{priv}}\big(\mathrm{marg}_i(p),\, d_i\big).
$$

*Proof sketch.* By Lemma 6.10 the objective, as a function of the product
reconstruction $c$, is a sum of terms each depending on a single component $c_i$;
a sum of independent one-variable minimizations equals the minimization of the
sum. Formally: ($\le$) choose componentwise minimizers and use them as a product
center; ($\ge$) take an optimal product center and bound each component's term
below by its own minimum. $\square$

Theorem 6.11 is striking: correlations across components — however strong — do
not change the private optimum, which sees only the marginals. The reason is
structural: a private decoder has exactly one reconstruction to offer, an
additive distortion evaluates it coordinate by coordinate, and expectation is
linear. Correlation is precisely the resource a private channel cannot exploit.

Theorem 6.11 subsumes the majority-vote formula of Theorem 3.11: taking all
$\sigma_i = \{0,1\}$ and $d_i = d_{\mathrm{bit}}$, each componentwise optimization
is $\min(\mathrm{mass}_i(0), \mathrm{mass}_i(1))$.

---

## 7. Consequences for surveillance networks

Let a *history* be a $T$-step record of a directed network on $n$ participants:
$\alpha = \{0,\dots,T-1\}\times\{1,\dots,n\}^2$, $|\alpha| = T n^2$, and
$S = \{0,1\}^{\alpha}$ with $|S| = 2^{Tn^2}$.

| Regime | Optimal private distortion |
|---|---|
| Worst case, Hamming | $Tn^2$ |
| Worst case, time-sliced (additive per snapshot) | $\sum_{t<T} n^2 = Tn^2$ |
| Expected, uniform source | $Tn^2/2$ |
| Worst case, modulo relabeling of participants | $\lceil Tn^2/2\rceil$ |
| Expected, arbitrary source, Hamming | $\sum_i \min(\mathrm{mass}_i(0),\mathrm{mass}_i(1))$ |

and, for a non-private observer at rate $\mathrm{rate}$ and failure probability
$\varepsilon$ against the uniform source,
$$
(1-\varepsilon)\,2^{Tn^2} \;\le\; \mathrm{rate}\cdot \sum_{i \le D}\binom{Tn^2}{i},
\qquad
(1-\varepsilon)\,2^{Tn^2} \;\le\; \mathrm{rate}\cdot(2D+1)\binom{Tn^2}{\lfloor Tn^2/2\rfloor}
\ \ \text{(relabeled)} .
$$

Interpretation. The worst-case numbers say that perfect privacy and worst-case
fidelity are mutually exclusive: a private channel's guarantee is no stronger
than "every bit may be wrong". The average-case number says that the best private
channel is exactly as good as a uniformly random guess. The relabeled number says
that giving up participant identities helps by a factor of two and stops there.
The rate converses say what a partial-disclosure channel must pay: $\log$-rate at
least $n(1-h(D/n))$ bits for Hamming accuracy $D$, and at least
$\tfrac12\log n - \log(2D+1) - O(1)$ bits even for relabeling-tolerant accuracy.

---

## 8. Algorithms

Three computational primitives support the results.

**(A) Optimal private reconstruction by majority vote.** Given a source law $p$
on $\{0,1\}^{\alpha}$ (as an explicit table, or as a sampler), compute
$\mathrm{mass}_i(0)$ and $\mathrm{mass}_i(1)$ for each coordinate, output the
coordinatewise argmin, and report the objective $\sum_i \min(\cdot,\cdot)$.
Complexity: $O(|\alpha|\cdot|\mathrm{supp}(p)|)$ with an explicit table, or
$O(|\alpha|)$ per sample in the streaming version; the optimizer is exact by
Theorem 3.11 and requires no search over the $2^{|\alpha|}$ reconstructions.

**(B) Binomial-tail converse evaluation.** Given $n$, $D$, $\varepsilon$ and a rate
$\rho$, evaluate the exact ball volume $\mathrm{vol}_D = \sum_{i\le D}\binom{n}{i}$
by the Pascal recurrence in $O(nD)$ integer operations, then test
$(1-\varepsilon)2^n \le \rho\cdot\mathrm{vol}_D$ and report the minimum feasible
rate $\lceil (1-\varepsilon)2^n/\mathrm{vol}_D\rceil$ and the minimum feasible
failure probability $1-\mathrm{vol}_D/2^n$. Exact rational/integer arithmetic
avoids all floating-point error.

**(C) Orbit ball volume and the relabeled converse.** Given $n$, a center weight
$k$ and a radius $D$, compute $\sum_{m=\max(0,k-D)}^{\min(n,k+D)}\binom{n}{m}$ in
$O(D)$ additions after $O(n)$ preprocessing, compare with the coarse bound
$(2D+1)\binom{n}{\lfloor n/2\rfloor}$, and report the implied rate lower bound
$2^n/\big((2D+1)\binom{n}{\lfloor n/2\rfloor}\big)$.

All three are implemented in the accompanying numerical demonstration, together
with brute-force verifications on small $n$: exhaustive minimization over all
$2^n$ reconstructions confirms the majority-vote formula; exhaustive enumeration
confirms the Hamming and orbit ball volumes; and exhaustive search confirms the
covering radii $n$, $\lceil n/2\rceil$ and the tensorization identity.

---

## 9. Discussion, limits, and open directions

### 9.1 What drives the results

Three mechanisms recur.

*Collapse.* Perfect privacy reduces channel design to the placement of a single
point. Everything else is geometry of the configuration space.

*Fibres.* Every converse in this paper — counting, measure-theoretic, relabeled —
is the same three-line argument: partition by record, each fibre sits in a ball,
count. Changing the currency (cardinality $\to$ mass) or the geometry (Hamming
$\to$ orbit) changes only the volume estimate that is plugged in.

*Additivity.* Closed forms exist exactly where the distortion is additive over a
product and the reconstruction alphabet is the full product; then the
minimization separates.

### 9.2 Limits of the model

Perfect privacy is an extreme; it is a boundary condition rather than a design
target, and its value here is that everything is exactly computable. The rate
parameter is the natural interpolation, and all converses are stated with it. The
distortion is assumed integer-valued and, in the closed-form results, additive.
The measure converse is a counting shadow of an entropy statement: it controls
$p(G)$ rather than $H(X)-H(X\mid Y)$, and closing that gap is the first open
direction below.

### 9.3 Open directions

1. **Entropy-sensitive converse.** Replace $p(G)$ by a mutual-information
   quantity: for a source law $p$ and a channel with excess-distortion
   probability $\varepsilon$, prove
   $H(X) - H(X\mid Y) \ge H(X) - \log \mathrm{vol}_D - h(\varepsilon) -
   \varepsilon\log|S|$. The measure converse of Section 4 is exactly the
   counting shadow of this statement; the remaining work is the passage from
   masses to entropies.

2. **Relabeled *average* distortion.** For the uniform source on
   $\{0,1\}^{\alpha}$ with $n = |\alpha|$, the conjecture is
   $$
   \min_c \mathbb{E}_{\mathrm{unif}}[\mathrm{orb}(c,X)] \;=\; \min_{0\le k\le n}\mathbb{E}\big[|k - W|\big],
   \quad W\sim\mathrm{Bin}(n,\tfrac12),
   $$
   with common value $n\binom{n-1}{\lfloor (n-1)/2\rfloor}/2^{n-1} = \Theta(\sqrt n)$
   rather than $\Theta(n)$. Both ingredients are in place: Theorem 5.2 makes the
   orbit distortion a function of weights alone, collapsing a minimization over
   $2^n$ reconstructions to one over $n+1$ integers, and Section 3 supplies the
   average-case framework. What remains is a binomial mean-absolute-deviation
   identity. Falsified by any $n$ where brute force disagrees.

3. **Marginal determinacy fails for non-additive distortion.** Average-case
   tensorization (Theorem 6.11) holds for additive distortion with no
   independence assumption. The conjecture is that additivity is exactly what
   makes it work: for the *max* distortion $d(c,s)=\max_i d_i(c_i,s_i)$ on a
   two-component product, the worst-case threshold should still be marginal
   determined, $R(d) = \max_i R(d_i)$, while the average-case optimum should
   **not** be — there should exist two laws on $\sigma_1\times\sigma_2$ with
   identical marginals and different $D_{\mathrm{priv}}$, with the gap controlled
   by a total-variation coupling distance between $p$ and the product of its
   marginals.

4. **Causal / sequential covering.** For time-indexed histories the record is
   produced online. Replace the single covering number by a sequential covering
   number along the natural filtration and relate the resulting quantity to
   directed information. Corollary 6.8 is the additive, loss-free case; the
   interesting regime is non-additive coupling between snapshots.

5. **Structured sources.** For histories generated by a Markov chain on
   snapshots, the ambient count $2^{Tn^2}$ is far from tight; a mixing-based
   deficit in the converse exponent is the natural next quantitative target.

6. **Partial symmetry groups.** Section 5 quotients by the full symmetric group.
   For a subgroup $H \le \mathrm{Sym}(\alpha)$ the orbit distortion is no longer a
   function of weight alone, orbit volumes require genuine Burnside counting, and
   the loss relative to the full group should be controlled by graph asymmetry —
   for instance by the size of the automorphism group of the observed network.

---

## 10. Conclusion

Perfect privacy transforms a coding problem into a covering problem: place one
point to be close to everything. The cost of that placement is the one-codeword
covering radius, and this paper measures it exactly under four relaxations. For
binary configurations of dimension $n$ the cost is $n$ in the worst case, $n/2$
on average against a uniform source, $\lceil n/2 \rceil$ in the worst case modulo
relabeling; it adds exactly across additive product components in both the
worst-case and the average-case theory, with correlations across components
contributing nothing; and it degrades gracefully with a rate budget and a failure
probability through the binomial inequality $(1-\varepsilon)2^n \le \mathrm{rate}
\cdot\sum_{i\le D}\binom{n}{i}$, whose zero-slack, unit-rate corner is precisely
the sharp threshold. Each relaxation of the contract buys a factor of two, and no
relaxation considered here buys more.
