# The Information Cost of a Connectome: Tight Quadratic Bounds on Encoding a Mind

## Abstract

We study the minimum lossless description length of the *connectome* — the
wiring diagram of a network of $n$ neurons, modeled as a labeled simple
undirected graph. We prove that this description length is governed exactly
by the pairwise-channel count $\binom{n}{2} = \frac{n(n-1)}{2}$: (i) every
lossless code assigns some connectome a codeword of at least $\binom{n}{2}$
bits (a worst-case lower bound); (ii) the canonical adjacency listing meets
this bound with equality for every input (attainment); and (iii) no code
can assign short codewords to all connectomes, so at least one connectome is
strictly incompressible, and asymptotically almost every connectome is
incompressible. We connect these combinatorial facts to Kolmogorov
complexity, exhibiting connectomes of complexity at least $\binom{n}{2}$,
and to physics via the Bekenstein bound, obtaining a necessary condition
$\binom{n}{2} \le \frac{2\pi R E}{\hbar c \ln 2}$ that any physically
realized mind of $n$ neurons must satisfy. The unifying theme is that the
information content of a mind is quadratic in its neuron count because it is
carried by *relationships*, not by *units*, and that this quadratic cost is
both exact and robust to arbitrary compression. We close with four
conjectures extending the theory to weighted synapses, generic
incompressibility, sparse (bounded-degree) connectomes, and time-evolving
activity.

## 1. Introduction

The prospect of *mind uploading* — transferring the functional content of a
brain onto a computational substrate — raises a question that is prior to
any engineering concern: what is the minimum number of bits required to
represent a mind losslessly? Any answer to this question that depends only
on the combinatorial structure of neural connectivity, and not on the
representation technology, has the status of a physical or mathematical law.

We isolate the cleanest such structure, the connectome, and prove that its
minimum lossless description length is *exactly* the number of unordered
pairs of neurons, $\binom{n}{2}$. This number is quadratic in $n$, is
achieved by an explicit code, and cannot be universally beaten by any code.
We further show that incompressibility is generic and tie the combinatorial
bound to Kolmogorov complexity and to the Bekenstein bound of physics.

The mathematical content is elementary in its ingredients — counting, the
pigeonhole principle, geometric series — but the conclusions are strong
precisely because they assume nothing about the encoding mechanism. This
robustness is what turns an estimate into a bound.

### Contributions

1. A precise model of a connectome as a labeled simple graph, and of
   lossless encoding as injectivity into $\{0,1\}^*$ (Section 2).
2. A tight quadratic worst-case lower bound $\binom{n}{2}$ on description
   length, with matching upper bound achieved by the adjacency listing
   (Section 3).
3. An incompressibility theorem: no code shortens all connectomes, with a
   genericity strengthening (Section 4).
4. A Kolmogorov-complexity corollary and a Bekenstein-bound coupling to
   physical realizability (Section 5).
5. Algorithms and numerical demonstrations (Section 6), applications and
   discussion (Section 7), and four extending conjectures (Section 8).

## 2. Definitions

Throughout, $n \in \mathbb{N}$ denotes the number of neurons, and $[n] =
\{1, 2, \dots, n\}$ their labels.

**Definition 2.1 (Connectome).** A *connectome* on $n$ neurons is a simple
undirected graph $G = ([n], E)$ where $E \subseteq \binom{[n]}{2}$ is a set
of unordered pairs (synaptic connections). Equivalently, $G$ is a symmetric,
irreflexive adjacency relation on $[n]$. We write $\mathcal{G}_n$ for the
set of all connectomes on $n$ neurons.

**Definition 2.2 (Pair count).** The number of unordered pairs of distinct
neurons is
$$m(n) := \binom{n}{2} = \frac{n(n-1)}{2}.$$
Each pair is an independent binary degree of freedom (a *channel*): present
or absent.

**Lemma 2.3 (Cardinality of the connectome space).** $|\mathcal{G}_n| =
2^{m(n)} = 2^{\binom{n}{2}}$.

*Proof sketch.* A connectome is determined by choosing, independently for
each of the $m(n)$ pairs, whether the edge is present. This is a bijection
between $\mathcal{G}_n$ and the set of functions $\binom{[n]}{2} \to \{0,1\}$,
which has cardinality $2^{m(n)}$. $\square$

**Definition 2.4 (Lossless code).** A *lossless code* on $\mathcal{G}_n$ is
an injective map $c : \mathcal{G}_n \to \{0,1\}^*$, where $\{0,1\}^*$ is the
set of all finite binary strings. The *length* of $c$ on $G$ is
$\ell(c, G) := |c(G)|$, the number of bits in $c(G)$. Injectivity is the
formal statement of losslessness: distinct connectomes receive distinct
codewords, so decoding is unambiguous.

**Definition 2.5 (Worst-case and best-case length).** For a code $c$,
$$L_{\max}(c) := \max_{G \in \mathcal{G}_n} \ell(c, G), \qquad
  L_{\min}(c) := \min_{G \in \mathcal{G}_n} \ell(c, G).$$

**Definition 2.6 (Adjacency listing code).** Fix a linear order
$p_1, \dots, p_{m(n)}$ of the pairs in $\binom{[n]}{2}$. The *adjacency
listing code* $c_{\mathrm{adj}}$ maps $G$ to the string $b_1 b_2 \cdots
b_{m(n)}$ where $b_i = 1$ if $p_i \in E(G)$ and $b_i = 0$ otherwise.

## 3. The tight quadratic bound

We first record the counting fact that drives everything.

**Lemma 3.1 (Short-string count).** The number of binary strings of length
strictly less than $k$ is
$$\sum_{j=0}^{k-1} 2^j = 2^{k} - 1.$$

*Proof sketch.* There are exactly $2^j$ strings of each length $j$; summing
the geometric series from $j = 0$ to $k-1$ gives $2^k - 1$. $\square$

**Theorem 3.2 (Quadratic worst-case lower bound).** For every lossless code
$c$ on $\mathcal{G}_n$,
$$L_{\max}(c) \ge \binom{n}{2}.$$
Equivalently, some connectome on $n$ neurons requires at least $\binom{n}{2}$
bits under $c$.

*Proof sketch.* Suppose for contradiction that $L_{\max}(c) < m(n) =
\binom{n}{2}$; then every codeword has length at most $m(n) - 1$, i.e. length
strictly less than $m(n)$. By Lemma 3.1 there are only $2^{m(n)} - 1$ such
strings. But $|\mathcal{G}_n| = 2^{m(n)}$ by Lemma 2.3, so $c$ maps
$2^{m(n)}$ distinct connectomes into a set of $2^{m(n)} - 1$ strings. By the
pigeonhole principle two distinct connectomes share a codeword,
contradicting injectivity. Hence $L_{\max}(c) \ge m(n)$. $\square$

**Theorem 3.3 (Exact attainment).** The adjacency listing code
$c_{\mathrm{adj}}$ is lossless and satisfies $\ell(c_{\mathrm{adj}}, G) =
\binom{n}{2}$ for every $G \in \mathcal{G}_n$; in particular
$L_{\max}(c_{\mathrm{adj}}) = \binom{n}{2}$.

*Proof sketch.* The map is injective because the bit-string records the full
edge-indicator function, from which $E(G)$ is recovered coordinatewise; two
distinct connectomes differ in at least one pair and hence in at least one
bit. Every codeword has exactly $m(n)$ bits by construction. $\square$

**Corollary 3.4 (Minimax description length).** The minimum over all
lossless codes of the worst-case length is exactly $\binom{n}{2}$:
$$\min_{c} L_{\max}(c) = \binom{n}{2}.$$

*Proof sketch.* Theorem 3.2 gives $L_{\max}(c) \ge \binom{n}{2}$ for all
$c$, and Theorem 3.3 exhibits a $c$ achieving equality. $\square$

This is the central result: the worst-case information cost of a connectome
is *exactly* quadratic in the neuron count, with an explicit optimal code.

## 4. Incompressibility

Theorem 3.2 identifies a single expensive connectome. We now show that
expensive connectomes are not exceptional but generic.

**Theorem 4.1 (Existence of an incompressible connectome).** For every
lossless code $c$ there is at least one connectome $G$ with $\ell(c, G) \ge
\binom{n}{2}$; this $G$ is *incompressible* under $c$ in the sense that it
cannot be represented in fewer than $\binom{n}{2}$ bits.

*Proof sketch.* This is Theorem 3.2 restated: the pigeonhole overflow
element is such a $G$. $\square$

**Theorem 4.2 (No code compresses a majority strictly).** Under any lossless
code $c$, the number of connectomes with $\ell(c, G) < \binom{n}{2}$ is at
most $2^{\binom{n}{2}} - 1$; hence at least one connectome, and in general a
positive fraction as bounded below by budget, is not compressed. More
generally, for any target budget $b$, at most $2^{b+1} - 1$ connectomes can
receive a codeword of length $\le b$.

*Proof sketch.* By Lemma 3.1 there are $2^{b+1}-1$ strings of length $\le b$.
Injectivity of $c$ forbids assigning any string to two connectomes, so at
most $2^{b+1}-1$ connectomes can have length $\le b$. Taking $b = m(n) - 1$
gives the first claim. $\square$

**Theorem 4.3 (Generic incompressibility).** Fix a code $c$. For a budget
$b(n) = \binom{n}{2} - g(n)$ with $g(n) \to \infty$, the fraction of
connectomes admitting a codeword of length $\le b(n)$ is at most
$$\frac{2^{b(n)+1} - 1}{2^{\binom{n}{2}}} \le 2^{\,1 - g(n)} \to 0.$$
Thus asymptotically almost every connectome requires at least $\binom{n}{2}
- g(n)$ bits.

*Proof sketch.* Divide the count from Theorem 4.2 by
$|\mathcal{G}_n| = 2^{\binom{n}{2}}$ and simplify; the ratio is at most
$2^{1 - g(n)}$, which vanishes as $g(n) \to \infty$. $\square$

The interpretation is that "redundant, easily-stored" minds form a
vanishing minority: shaving even a growing number of bits below the
quadratic threshold leaves all but an exponentially small fraction of
connectomes still incompressible.

## 5. Kolmogorov complexity and the Bekenstein bound

**Definition 5.1 (Kolmogorov complexity).** For a fixed universal prefix
machine $U$, the Kolmogorov complexity $K(x)$ of a string $x$ is the length
of the shortest program $p$ with $U(p) = x$. We identify a connectome with
its adjacency string of length $\binom{n}{2}$.

**Theorem 5.2 (Incompressible connectome, Kolmogorov form).** For every $n$
there exists a connectome $G \in \mathcal{G}_n$ with
$$K(G) \ge \binom{n}{2}.$$

*Proof sketch.* The map $p \mapsto U(p)$ is a lossless (injective on its
domain of shortest programs) description scheme. The set of programs of
length $< m(n)$ has size at most $2^{m(n)} - 1 < 2^{m(n)} = |\mathcal{G}_n|$
by Lemma 3.1 and Lemma 2.3. Hence some connectome is not the output of any
program shorter than $m(n)$ bits, i.e. $K(G) \ge m(n) = \binom{n}{2}$.
$\square$

Thus for at least one mind, the shortest program in any language that
reproduces its wiring is essentially the wiring itself: there is no shorter
description of any kind. Because this holds for every $n$, the Kolmogorov
complexity of connectomes is at least quadratic in the neuron count.

**Theorem 5.3 (Bekenstein realizability constraint).** Suppose a connectome
on $n$ neurons is physically instantiated within a spherical region of
radius $R$ containing total energy $E$. The Bekenstein bound
$$I \le \frac{2\pi R E}{\hbar c \ln 2}$$
on the information content $I$ of the region, combined with the lower bound
$K(G) \ge \binom{n}{2}$ for an incompressible connectome, forces
$$\binom{n}{2} \le \frac{2\pi R E}{\hbar c \ln 2}.$$

*Proof sketch.* A physical instantiation that faithfully stores the
connectome must hold at least $K(G)$ bits of information for an
incompressible $G$; the region's information capacity is at most the
Bekenstein bound. Chaining the two inequalities and using Theorem 5.2 gives
the stated necessary condition. $\square$

**Corollary 5.4 (Square-root scaling of neuron budget).** For fixed physical
resources $R, E$, the largest number of neurons whose *worst-case*
connectome is physically storable scales as
$$n = O\!\left(\sqrt{\tfrac{2\pi R E}{\hbar c \ln 2}}\right),$$
i.e. only as the square root of the physical information budget, because the
wiring cost grows quadratically in $n$.

*Proof sketch.* Solve $\binom{n}{2} = \frac{n(n-1)}{2} \le B$ for $n$ with
$B = \frac{2\pi R E}{\hbar c \ln 2}$; the leading behavior is
$n \le \tfrac{1}{2} + \sqrt{2B + \tfrac14} = O(\sqrt{B})$. $\square$

## 6. Algorithms and numerics

The theory yields directly implementable procedures.

**Algorithm A (Adjacency encode/decode).** Given a connectome as an
adjacency structure, enumerate the $\binom{n}{2}$ pairs in a fixed order and
emit the edge-indicator bit for each; decoding reverses the enumeration.
This is the optimal worst-case code of Theorem 3.3, running in
$O(n^2)$ time and producing exactly $\binom{n}{2}$ bits.

**Algorithm B (Bound evaluator).** Given $n$, compute $\binom{n}{2}$ and,
given physical parameters $R, E$, compute the Bekenstein capacity and report
whether the realizability constraint of Theorem 5.3 holds.

**Algorithm C (Incompressibility auditor).** Given a candidate code
presented as a table on all $2^{\binom{n}{2}}$ connectomes for small $n$,
verify Theorem 4.2 by counting codewords of each length and confirming that
no more than $2^{b+1}-1$ inputs receive length $\le b$.

Numerical illustration: for $n = 2, \dots, 8$ the exact bit costs
$\binom{n}{2}$ are $1, 3, 6, 10, 15, 21, 28$. The quadratic growth is
already visible: doubling $n$ from $4$ to $8$ raises the cost from $6$ to
$28$, close to the factor of four predicted by the leading $n^2/2$ term.

## 7. Applications and discussion

**Storage budgeting for connectomics.** The result tells experimentalists
that lossless storage of dense wiring diagrams cannot be reduced below the
pairwise-channel count by any compression scheme; investment in compression
software is provably capped, and the only lever on cost is the neuron count
or the sparsity of the wiring.

**A limit on "mind uploading" optimism.** Popular arguments that a brain is
"mostly redundant" and hence cheaply storable are constrained by Theorem
4.3: below the quadratic threshold, all but a vanishing fraction of wiring
diagrams remain incompressible. Redundancy exploitable for compression is
the exception.

**Physical realizability.** Corollary 5.4 injects a conservation law into
the discussion: the neuron count of any physically realized mind is bounded
by the square root of its Bekenstein information budget, tying an abstract
combinatorial cost to spatial extent and energy.

**Why quadratic, not linear.** The decisive structural fact is that a
connectome encodes *relationships* among neurons, which number $\binom{n}{2}$,
not the neurons themselves, which number $n$. The same combinatorics governs
handshakes among $n$ people and links among $n$ network nodes.

## 8. Future directions

**Conjecture 8.1 (Weighted connectomes: logarithmic overhead).** If each
synapse carries a weight from an alphabet of $q$ levels rather than a single
present/absent bit, the minimum lossless description length is exactly
$\binom{n}{2}\log_2 q$ bits, sharp in the worst case. The quadratic factor
counts independent channels; weight resolution contributes only a
per-channel logarithmic factor, so increasing biological fidelity is
exponentially cheaper than adding neurons.

**Conjecture 8.2 (Compressible minds are measure-zero).** For each budget
$b < \binom{n}{2}$, the fraction of connectomes admitting a lossless
description of length $\le b$ tends to $0$ as $n \to \infty$; all but a
vanishing fraction are incompressible below $\binom{n}{2} - o(\binom{n}{2})$
bits. Incompressibility is generic.

**Conjecture 8.3 (Bounded-degree connectomes escape the floor).** If every
neuron has at most $d$ synapses, the minimum lossless description length
drops to $\Theta(n\, d \log n)$ bits — linear in $n$ for fixed $d$ — and this
is sharp. Sparsity converts the quadratic pairwise-channel count into a
near-linear cost dominated by *addressing* which few partners each neuron
connects to.

**Conjecture 8.4 (Dynamic Bekenstein bound).** Faithfully encoding a mind's
trajectory over time $T$ — its evolving activation state atop a fixed
connectome — requires at least $\binom{n}{2} + n\,T$ bits, coupling the
static wiring cost to the dynamic activity cost.

## 9. Conclusion

The minimum lossless description length of a connectome on $n$ neurons is
exactly $\binom{n}{2}$ bits: this cost is forced by counting, achieved by an
explicit code, robust against all compression, generic across connectomes,
reflected in Kolmogorov complexity, and constrained by the Bekenstein bound
of physics. The information cost of a mind is quadratic because it is the
cost of relationships, not of units — and that quadratic wall is exact and
unclimbable for dense wiring, while sparsity offers the one principled route
beneath it.
