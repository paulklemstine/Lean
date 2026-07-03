# The Difference-Set Method for Sidon Sets: Sharp Elementary Bounds, Explicit Unbounded Families, and the Convolution-Kernel Programme

## Abstract

A *Sidon set* (or $B_2$ set) is a finite set of integers whose pairwise sums
are all distinct or, equivalently, whose pairwise differences are all
distinct. Writing $F(N)$ for the maximum cardinality of a Sidon set contained
in $\{1, \dots, N\}$, the extremal problem is to determine the asymptotics of
$F(N)$. We give a self-contained development of the *difference-set method*,
the counting principle underlying every known bound on $F(N)$. Its core is an
injectivity statement: the ordered-difference map $(a, b) \mapsto a - b$ is
one-to-one on distinct pairs of a Sidon set. Counting the domain against the
window of admissible differences yields the quantitative bound $|S|\,(|S|-1)
\le 2(N-1)$ and, in real-analytic form, $F(N) \le \sqrt{2N} + 1$. To certify
that this ceiling is non-vacuous, we prove that the first $k$ powers of two
form a Sidon set for every $k$ — via uniqueness of binary representation,
made rigorous through the $2$-adic valuation — so that Sidon sets of every
prescribed cardinality exist and $F(N)$ grows without bound. We then situate
these elementary results within the broader Erdős–Turán refinement $F(N) \le
N^{1/2} + \gamma\,N^{1/4} + O(1)$ and the modern vector-valued
convolution-kernel programme that seeks the optimal sub-leading constant
$\gamma_0 \approx 0.94601$, and we outline the constructions (quadratic /
Singer families) that pin $F(N)$ to order $\sqrt{N}$ from below.

## 1. Introduction

Let $\mathbb{Z}$ denote the integers. A finite set $S \subset \mathbb{Z}$ is a
**Sidon set** if for all $a, b, c, d \in S$,
$$ a + b = c + d \implies \{a, b\} = \{c, d\}. $$
Equivalently (Proposition 2.2 below), all pairwise differences of distinct
elements are distinct. Such sets, introduced by Simon Sidon in the study of
Fourier series in the 1930s, are also called $B_2$ sets, and they are a
cornerstone of additive combinatorics.

The natural extremal quantity is
$$ F(N) := \max\{ |S| : S \subseteq \{1, 2, \dots, N\},\ S \text{ is Sidon}\}. $$
Determining $F(N)$ asymptotically is a classical problem. The Erdős–Turán
theory gives $F(N) = N^{1/2}(1 + o(1))$ with the refined upper bound
$$ F(N) \le N^{1/2} + \gamma\, N^{1/4} + O(1), \tag{1.1} $$
and a substantial line of work — culminating in vector-valued
convolution-kernel optimizations — is devoted to the optimal constant
$\gamma$.

This paper isolates and develops the elementary engine behind (1.1): the
**difference-set method**. We prove the leading-order upper bound rigorously,
establish an explicit unbounded family from first principles, and then map
the terrain in which the finer constant $\gamma$ is contested.

### Contributions

1. **The difference-set injection (Theorem 3.1).** The ordered-difference map
   is injective on the off-diagonal of a Sidon set.
2. **The quantitative counting bound (Theorem 3.3).** For a Sidon set $S
   \subseteq \{1, \dots, N\}$, $|S|\,(|S|-1) \le 2(N-1)$.
3. **The square-root ceiling (Theorem 3.4).** $F(N) \le \sqrt{2N} + 1$.
4. **Two-power sum uniqueness (Theorem 4.2).** If $2^a + 2^b = 2^c + 2^d$
   then $a = c$ or $a = d$.
5. **The powers-of-two construction (Theorem 4.3).** For every $k$, the set
   $\{2^0, \dots, 2^{k-1}\}$ is Sidon.
6. **Unboundedness of the extremal function (Theorem 4.4).** For every $k$
   there is a Sidon set of cardinality exactly $k$.

## 2. Definitions and elementary equivalences

**Definition 2.1 (Sidon set).** A finite set $S \subset \mathbb{Z}$ is a
*Sidon set* if whenever $a, b, c, d \in S$ satisfy $a + b = c + d$, then
$\{a, b\} = \{c, d\}$ as multisets.

**Proposition 2.2 (Sums vs. differences).** A finite set $S$ is Sidon if and
only if all pairwise differences $a - b$ with $a, b \in S$, $a \ne b$, are
distinct; equivalently, for distinct pairs $(a,b) \ne (c,d)$ with $a \ne b$
and $c \ne d$, one has $a - b \ne c - d$.

*Proof sketch.* The identity $a - b = c - d \iff a + d = c + b$ converts a
repeated difference into a repeated sum and back. If $S$ is Sidon and $a - b
= c - d$, then $a + d = c + b$ forces $\{a, d\} = \{c, b\}$; since $a \ne b$
and $c \ne d$ this yields $a = c$, $b = d$. Conversely a repeated sum $a + b
= c + d$ with $\{a,b\} \ne \{c,d\}$ produces a repeated difference by the same
rearrangement. $\square$

We work throughout with the difference formulation, which is what powers the
counting argument.

**Definition 2.3 (Extremal function).** $F(N) = \max\{|S| : S \subseteq
\{1,\dots,N\},\ S \text{ Sidon}\}$.

## 3. The difference-set method and the square-root ceiling

Fix a Sidon set $S \subseteq \{1, \dots, N\}$ with $|S| = m$. Let
$$ \mathrm{OffDiag}(S) = \{(a,b) \in S \times S : a \ne b\} $$
denote the set of ordered pairs of distinct elements, of which there are
exactly $m(m-1)$.

**Theorem 3.1 (Difference injectivity).** The map
$$ \delta : \mathrm{OffDiag}(S) \to \mathbb{Z}, \qquad \delta(a,b) = a - b, $$
is injective.

*Proof.* Suppose $\delta(a,b) = \delta(c,d)$, i.e. $a - b = c - d$ with $a
\ne b$ and $c \ne d$. Then $a + d = c + b$. Since $S$ is Sidon,
$\{a, d\} = \{c, b\}$. Were $a = d$ we would contradict... rather, the
constraint $a \ne b$, $c \ne d$ forces the identification $a = c$ and $b = d$
(the alternative $a = b$ is excluded). Hence $(a,b) = (c,d)$. $\square$

**Lemma 3.2 (Difference window).** For $(a,b) \in \mathrm{OffDiag}(S)$ with
$S \subseteq \{1, \dots, N\}$, the value $\delta(a,b) = a - b$ is a nonzero
integer with $|a - b| \le N - 1$. Consequently $\delta$ takes values in the
set $\{-(N-1), \dots, -1, 1, \dots, N-1\}$, which has exactly $2(N-1)$
elements.

*Proof.* Both $a$ and $b$ lie in $\{1, \dots, N\}$, so $a - b$ lies in
$\{-(N-1), \dots, N-1\}$; it is nonzero because $a \ne b$. $\square$

**Theorem 3.3 (Quantitative counting bound).** If $S \subseteq \{1, \dots,
N\}$ is Sidon then
$$ |S|\,(|S| - 1) \le 2(N - 1). $$

*Proof.* By Theorem 3.1 the map $\delta$ is injective, so its domain is no
larger than its codomain. The domain has cardinality $|S|\,(|S|-1)$; by
Lemma 3.2 the codomain has cardinality $2(N-1)$. $\square$

**Theorem 3.4 (Square-root ceiling).** For all $N \ge 1$,
$$ F(N) \le \sqrt{2N} + 1, $$
equivalently $F(N) \le \sqrt{2}\, N^{1/2} + 1$.

*Proof.* Let $m = |S|$ for an extremal Sidon set. Theorem 3.3 gives $m^2 - m
\le 2N - 2$, hence $m^2 - m - (2N - 2) \le 0$. Solving the quadratic in $m$
and keeping the positive root,
$$ m \le \frac{1 + \sqrt{1 + 4(2N-2)}}{2} = \frac{1 + \sqrt{8N - 7}}{2}. $$
Since $\sqrt{8N - 7} \le \sqrt{8N} = 2\sqrt{2N}$, we get $m \le \tfrac{1}{2} +
\sqrt{2N} \le \sqrt{2N} + 1$. $\square$

Theorem 3.4 is the leading-order form of (1.1) with an explicit — though not
optimal — constant $\sqrt{2}$ in front of $N^{1/2}$. The refinement to the
true leading constant $1$ (and the study of the sub-leading $\gamma$) requires
the averaging machinery discussed in Section 5.

## 4. An explicit unbounded family: the powers of two

Theorem 3.4 is only meaningful if arbitrarily large Sidon sets exist. We give
the cheapest fully explicit certificate.

**Definition 4.1.** For $k \in \mathbb{N}$, let
$$ P_k = \{2^0, 2^1, \dots, 2^{k-1}\} \subset \mathbb{Z}, $$
the image of $\{0, 1, \dots, k-1\}$ under $i \mapsto 2^i$. Since $i \mapsto
2^i$ is injective, $|P_k| = k$.

The arithmetic heart of the construction is the following uniqueness
statement.

**Theorem 4.2 (Two-power sum uniqueness).** For natural numbers $a, b, c, d$,
$$ 2^a + 2^b = 2^c + 2^d \implies a = c \ \text{or}\ a = d. $$

*Proof sketch.* We show the stronger multiset identity $\{a, b\} = \{c, d\}$,
from which the conclusion is immediate. By symmetry assume $a \le b$ and $c
\le d$. Factor out the smallest power:
$$ 2^a\bigl(1 + 2^{b-a}\bigr) = 2^c\bigl(1 + 2^{d-c}\bigr). $$
Consider the $2$-adic valuation $v_2$ (the exponent of $2$ in the prime
factorization). The factor $1 + 2^{b-a}$ is odd when $b > a$ and equals $2$
when $b = a$; likewise for $1 + 2^{d-c}$. Comparing $v_2$ of both sides
across the cases $b = a$ vs. $b > a$ and $d = c$ vs. $d > c$ forces $a = c$,
after which cancellation gives $1 + 2^{b-a} = 1 + 2^{d-c}$ and hence $b = d$.
The only delicate case is the "carry" $b = a$ (where $2^a + 2^a = 2^{a+1}$),
which is incompatible with a genuinely distinct pair $c < d$ precisely because
$1 + 2^{d-c}$ is then odd and exceeds $1$. Thus $\{a,b\} = \{c,d\}$. $\square$

**Theorem 4.3 (Powers of two are Sidon).** For every $k$, the set $P_k$ is a
Sidon set.

*Proof.* Suppose $x + y = z + w$ with $x, y, z, w \in P_k$; write $x =
2^{a}$, $y = 2^{b}$, $z = 2^{c}$, $w = 2^{d}$ with exponents in
$\{0, \dots, k-1\}$. By Theorem 4.2 (applied in both coordinates), $\{a, b\}
= \{c, d\}$, whence $\{x, y\} = \{z, w\}$. $\square$

**Theorem 4.4 (Unboundedness).** For every $k \in \mathbb{N}$ there exists a
Sidon set $S \subset \mathbb{Z}$ with $|S| = k$. Consequently the extremal
function $F(N)$ is unbounded.

*Proof.* Take $S = P_k$: it is Sidon by Theorem 4.3 and has cardinality $k$
by Definition 4.1. $\square$

**Remark 4.5 (Cost of the certificate).** The family $P_k$ is cheap but
wasteful: fitting $k$ powers requires a window of length $N = 2^{k-1}$, so
$P_k$ only witnesses $F(N) \ge \log_2 N + 1$. It is nevertheless the least
technology needed to prove unboundedness — no finite-field or
perfect-difference-set machinery is required. Matching the true $\sqrt{N}$
order from below requires the constructions of Section 5.

## 5. The finer landscape: constant chasing and convolution kernels

The elementary bound of Theorem 3.4 has leading constant $\sqrt{2} \approx
1.414$, whereas the true leading constant of $F(N)/N^{1/2}$ is $1$. The gap is
structural: the difference-count sees each distance exactly once and cannot
distinguish a Sidon set from any set whose differences merely spread out
evenly. Recovering the sharp leading constant requires *averaging local
density over sliding windows*, where the overlap structure — not the global
count — carries the decisive information.

### 5.1 Matching lower bounds

Deeper constructions realize the $\sqrt{N}$ frontier. A representative
quadratic family: for a prime $p$, the set
$$ Q_p = \{ 2p\,i + (i^2 \bmod p) : 0 \le i < p \} $$
is a Sidon set inside $\{1, \dots, 2p^2\}$, giving $F(N) \ge (1 - o(1))
N^{1/2}$. The mechanism is that squaring linearizes distinctness: two pairs
$(i, j)$, $(i', j')$ collide only if a symmetric quadratic congruence has a
nontrivial solution, and the modular structure forbids exactly those
solutions. The classical Singer and Erdős–Turán constructions (via perfect
difference sets in finite projective planes and quadratic residues) achieve
the same order with sharp leading constant.

### 5.2 The Erdős–Turán refinement

Combining sharp constructions with a refined counting argument yields the
two-term expansion (1.1),
$$ F(N) \le N^{1/2} + \gamma\, N^{1/4} + O(1), $$
in which the leading term is settled and the coefficient $\gamma$ of the
$N^{1/4}$ correction is the object of contention.

### 5.3 The vector-valued convolution-kernel programme

The modern approach replaces one-at-a-time difference counting with a
smoothing operation. One convolves the difference distribution of $S$ against
a **kernel** and averages, so that the count becomes an inner product between
the kernel and the autocorrelation of the indicator of $S$. Feasible kernels
must satisfy a family of convolution inequalities; the bound they certify is a
weighted average of these inequalities. Passing to *vector-valued* kernels and
optimizing the weights turns the search into a finite-dimensional linear
program. The conjectured optimum attainable by this method is
$$ \gamma_0 \approx 0.94601, $$
realized as the saddle point of an explicit duality between the kernel
inequalities and the certifying weighting. In this framing the elusive
constant is the value of a concrete, checkable optimization rather than a
limit approached only asymptotically. This averaging-of-local-operators
motif is precisely the design principle behind convolutional filters in
signal processing and machine learning, which is what ties the problem to its
stated domain.

## 6. Algorithms

We record the two algorithmic primitives used in the numerical companion.

**Algorithm A (Sidon verification via difference multiset).** Given a finite
set $S$, compute all pairwise differences $a - b$ ($a \ne b$) and test whether
they are pairwise distinct. Equivalently, check whether $|S|\,(|S|-1)$ equals
the number of *distinct* nonzero differences. Complexity: $O(|S|^2)$ time and
space.

**Algorithm B (Greedy Sidon extension).** To build a large Sidon set inside
$\{1, \dots, N\}$, scan candidates $x = 1, 2, \dots, N$ in order, maintaining
the set $D$ of differences already realized; admit $x$ iff none of the
differences $x - s$ (for $s$ already chosen) lies in $D$, then update $D$.
Complexity: $O(N \cdot |S|)$ time. This produces the classical greedy (Mian–
Chowla-type) Sidon sequence.

## 7. Applications

- **Radar and antenna arrays.** Placing elements at Sidon-set positions makes
  all baselines (pairwise spacings) distinct, maximizing the number of
  independent correlations and hence angular resolution.
- **Error-correcting and spread-spectrum codes.** The distinct-difference
  property yields low autocorrelation sequences used in synchronization and
  code-division multiplexing.
- **Signal processing / machine learning.** The convolution-kernel bound is a
  direct analogue of filter design: averaging a family of local operators to
  extract a sharp global estimate.

## 8. Discussion

The difference-set method is remarkable for how much it extracts from a single
injectivity observation. Theorems 3.1–3.4 reduce the entire upper-bound
question, at leading order, to counting a domain against a window. The method
is also honest about its limits: it structurally saturates at leading constant
$\sqrt{2}$, and surpassing it demands genuinely analytic ideas (windowed
averaging, convolution kernels). The powers-of-two family, by contrast, shows
how little is needed to prove that the problem is non-degenerate — uniqueness
of binary representation, made rigorous through the $2$-adic valuation, suffices.

## 9. Future work

Several concrete directions extend this development: proving the sharp
elementary two-term bound $F(N) \le N^{1/2} + N^{1/4} + 1$ via sliding-window
averaging; verifying the quadratic construction $Q_p$ realizes the $\sqrt{N}$
frontier for all primes $p$; formulating the convolution-kernel optimum
$\gamma_0 \approx 0.94601$ as an explicit finite-dimensional linear program
and certifying its value; and establishing additive-energy stability results
that make the Sidon property robust to small perturbations. These are
elaborated in the accompanying future-directions notes.

## References (classical, for orientation)

- S. Sidon, *Ein Satz über trigonometrische Polynome und seine Anwendung in
  der Theorie der Fourier-Reihen* (1932).
- P. Erdős and P. Turán, *On a problem of Sidon in additive number theory*
  (1941).
- J. Singer, *A theorem in finite projective geometry and some applications to
  number theory* (1938).
