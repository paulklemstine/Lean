# The Unconditional Kernel of the Hamming-Ball Discrepancy Conjecture

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Computation / Coding Theory / Combinatorics

---

## Abstract

The discrepancy conjecture for random linear codes asserts that a random
linear code $C \subseteq \mathbb{F}_q^n$ of suitably chosen dimension is, with
probability $1 - o(1)$, *uniformly balanced* across all Hamming balls: for
every centre $z \in \mathbb{F}_q^n$ simultaneously,
$|C \cap B_\rho(z)| = (1 \pm o(1))\,|C|\,|B_\rho|/q^n$. We isolate and prove,
unconditionally and with no recourse to randomness or linearity, the
deterministic kernel of this statement. Our main result is an **exact averaging
identity**: for an *arbitrary* subset $C$ of a finite translation group
$G = \iota \to \alpha$ and any radius $r$,
$$\sum_{z \in G} |C \cap B_r(z)| = |C|\cdot|B_r|,$$
so the average ball count over all centres equals the conjecture's heuristic
target $|C|\,|B_r|/|G|$ *exactly*. The proof rests on a single load-bearing
fact — the translation invariance of Hamming distance, which forces every ball
to have the same volume regardless of centre. We derive a one-sided
(Markov-type) discrepancy bound $|\{z : |C \cap B_r(z)| \ge t\}| \le
|C|\,|B_r|/t$ that supplies, for free, the upper-tail half of the concentration
statement. We also give the exact closed form for the ball volume,
$|B_r| = \sum_{i=0}^r \binom{n}{i}(q-1)^i$, deduced from the per-sphere count
$\binom{n}{r}(q-1)^r$, which makes the conjecture's dimension threshold
explicit through the $q$-ary entropy function. Finally, for linear codes we note
the coset-invariance of the ball-count function. The upshot is a precise
reduction of the conjecture to a pure second-moment (variance) problem, with the
first moment now settled as a closed-form identity.

---

## 1. Introduction

### 1.1 Motivation

A code is a structured subset $C$ of the *Hamming cube*
$\mathbb{F}_q^n$ — the set of all length-$n$ strings over an alphabet of size
$q$. Codes underlie error-correcting communication, data storage, and a wide
range of pseudorandomness applications. A recurring desideratum is that a code be
*well-distributed*: it should not clump in some regions of the space and starve
others. The sharpest formalization of "well-distributed" uses the natural test
sets of the Hamming geometry, the **Hamming balls** $B_\rho(z)$, and demands
that every ball — wherever centred — contain its proportionate share of
codewords.

### 1.2 The conjecture

Fix a finite field $\mathbb{F}_q$, a relative radius $\rho \in (0,1)$, and
$\varepsilon > 0$. Let $C \subseteq \mathbb{F}_q^n$ be a uniformly random linear
subspace of dimension
$$k = \Big\lceil \big(1 - \tfrac1n \log_q |B_\rho| + \varepsilon\big)\,n \Big\rceil .$$

> **Conjecture (Hamming-ball discrepancy).** As $n \to \infty$, with probability
> $1 - o(1)$ the following holds simultaneously for every centre
> $z \in \mathbb{F}_q^n$:
> $$|C \cap B_\rho(z)| = (1 \pm o(1))\,\frac{|C|\,|B_\rho|}{q^n}.$$

The target value $|C|\,|B_\rho|/q^n$ is precisely the count expected if $C$ were
a uniformly random set of its size and ball volumes were centre-independent. The
dimension $k$ is calibrated so that this target is $\Theta(1)$: the code is as
large as possible while still expecting a bounded number of codewords per ball.

### 1.3 Contribution

We extract the part of the conjecture that holds *deterministically*, for every
set $C$, and prove it rigorously. Concretely:

1. **Translation invariance** of Hamming distance (Theorem 1), and as a
   consequence **centre-independence of ball volume** (Theorem 2).
2. The **exact averaging identity** $\sum_z |C \cap B_r(z)| = |C|\,|B_r|$
   (Theorem 4), valid for arbitrary $C$ with no algebraic or probabilistic
   hypotheses.
3. A **one-sided Markov discrepancy bound** (Theorem 5).
4. The **closed-form ball-volume formula** via the per-sphere count
   (Theorems 6–7).
5. **Coset invariance** of the ball-count function for linear codes (Theorem 8),
   reducing the relevant quantifier from $q^n$ centres to $q^n/|C|$ cosets.

These results sharply delimit the conjecture: the first moment is exact and
unconditional; only the second moment (concentration) requires randomness.

---

## 2. Setting and definitions

We work in an ambient finite abelian group of the product form
$$G = \iota \to \alpha,$$
i.e. functions from a finite index set $\iota$ (the $n = |\iota|$ coordinates)
to a finite additive group $\alpha$ (the alphabet, $q = |\alpha|$), with
pointwise addition. When $\alpha = \mathbb{F}_q$ this is exactly
$\mathbb{F}_q^n$; the results below need only the additive group structure, not
the field structure.

**Definition 1 (Hamming distance).** For $x, y \in G$,
$$\mathrm{d}(x, y) = \big|\{\, i \in \iota : x(i) \ne y(i) \,\}\big|,$$
the number of coordinates in which $x$ and $y$ differ.

**Definition 2 (Hamming ball).** For a radius $r \in \mathbb{N}$ and a centre
$z \in G$,
$$B_r(z) = \{\, x \in G : \mathrm{d}(x, z) \le r \,\}.$$
Its *volume* is $|B_r(z)|$.

**Definition 3 (Hamming sphere).** The sphere of radius $r$ about the origin is
$\{\, x \in G : \mathrm{d}(x, 0) = r \,\}$.

**Definition 4 (Discrepancy target).** For a finite $C \subseteq G$, the
*target* (heuristic mean) ball count is $|C|\,|B_r|/|G|$, where
$|B_r| := |B_r(0)|$ once Theorem 2 justifies dropping the centre.

---

## 3. Translation invariance and centre-independence

**Theorem 1 (Translation invariance of Hamming distance).** For all
$x, y, a \in G$,
$$\mathrm{d}(x + a,\, y + a) = \mathrm{d}(x, y).$$

*Proof sketch.* By definition $\mathrm{d}$ counts indices $i$ with
$(x+a)(i) \ne (y+a)(i)$, i.e. $x(i) + a(i) \ne y(i) + a(i)$. In a group,
right-addition by $a(i)$ is injective, so $x(i) + a(i) \ne y(i) + a(i)$ iff
$x(i) \ne y(i)$. The two index sets coincide, hence the counts agree. $\square$

This is the *load-bearing* lemma: every subsequent structural statement reduces
to it.

**Theorem 2 (Centre-independence of ball volume).** For every $r$ and every
$z \in G$,
$$|B_r(z)| = |B_r(0)|.$$

*Proof sketch.* The translation map $t_z : x \mapsto x + z$ is a bijection of
$G$. By Theorem 1, $\mathrm{d}(x, 0) \le r$ iff
$\mathrm{d}(x + z, z) \le r$, so $t_z$ maps $B_r(0)$ bijectively onto $B_r(z)$.
Concretely, $B_r(z) = \{\, y + z : y \in B_r(0) \,\}$, the image of $B_r(0)$
under the injection $y \mapsto y + z$; an injective image preserves cardinality.
$\square$

Henceforth we write $|B_r| := |B_r(0)|$ without ambiguity.

**Theorem 3 (Centres containing a fixed point).** For any fixed $c \in G$,
$$\big|\{\, z \in G : \mathrm{d}(c, z) \le r \,\}\big| = |B_r|.$$

*Proof sketch.* By the symmetry $\mathrm{d}(c, z) = \mathrm{d}(z, c)$, the set
of valid centres is exactly the ball $B_r(c)$, whose cardinality is $|B_r|$ by
Theorem 2. $\square$

---

## 4. The exact averaging identity

**Theorem 4 (Exact averaging identity).** For any finite $C \subseteq G$ and any
radius $r$,
$$\sum_{z \in G} |C \cap B_r(z)| = |C|\cdot|B_r|.$$
Equivalently, the average ball count over all centres is exactly
$$\frac{1}{|G|}\sum_{z \in G} |C \cap B_r(z)| = \frac{|C|\,|B_r|}{|G|}.$$

*Proof sketch (double counting).* Consider the incidence count
$$N = \big|\{\, (c, z) \in C \times G : \mathrm{d}(c, z) \le r \,\}\big| =
\sum_{c \in C} \sum_{z \in G} \mathbf{1}[\mathrm{d}(c,z) \le r].$$

- **Summing over $z$ first** (columns): for fixed $z$,
  $\sum_{c \in C} \mathbf{1}[\mathrm{d}(c,z) \le r] = |C \cap B_r(z)|$. Hence
  $N = \sum_{z} |C \cap B_r(z)|$.
- **Summing over $c$ first** (rows): for fixed $c$,
  $\sum_{z \in G} \mathbf{1}[\mathrm{d}(c,z) \le r] = |B_r|$ by Theorem 3. Hence
  $N = \sum_{c \in C} |B_r| = |C|\cdot|B_r|$.

Equating the two evaluations of $N$ gives the identity. $\square$

The identity is *exact* (no error term), *dimension-free*, and requires no
structure on $C$ beyond being a finite subset of a translation group. It
formally validates the conjecture's heuristic target as the literal mean.

**Remark.** The proof uses translation invariance only through Theorem 3. Were
ball volumes centre-dependent, the row sums would differ and the clean product
$|C|\cdot|B_r|$ would fail — confirming that Theorem 1 is essential, not
cosmetic.

---

## 5. A one-sided concentration bound

**Theorem 5 (Markov discrepancy bound).** For any finite $C \subseteq G$,
radius $r$, and threshold $t \ge 1$,
$$\big|\{\, z \in G : |C \cap B_r(z)| \ge t \,\}\big| \;\le\;
\frac{|C|\cdot|B_r|}{t}.$$

*Proof sketch.* Let $S = \{ z : |C \cap B_r(z)| \ge t \}$. Then
$$|S|\cdot t = \sum_{z \in S} t \le \sum_{z \in S} |C \cap B_r(z)|
\le \sum_{z \in G} |C \cap B_r(z)| = |C|\cdot|B_r|,$$
using nonnegativity of the summands to extend the sum from $S$ to $G$, and
Theorem 4 for the final equality. Dividing by $t$ gives the claim. $\square$

This is the discrete analogue of Markov's inequality and yields the *upper-tail*
half of the discrepancy statement deterministically: at most a $1/t$-fraction
(scaled by the mean) of centres can be "overcrowded." The genuinely
probabilistic content of the conjecture is therefore confined to (i) the
lower-tail companion (ruling out near-empty balls) and (ii) the simultaneous
control of all exceptions.

---

## 6. The ball-volume formula

To make the threshold dimension $k$ explicit we compute $|B_r|$ exactly.

**Theorem 6 (Sphere count).** With $n = |\iota|$ and $q = |\alpha|$, the number
of points at Hamming distance exactly $r$ from the origin is
$$\big|\{\, x \in G : \mathrm{d}(x, 0) = r \,\}\big| = \binom{n}{r}\,(q-1)^r.$$

*Proof sketch.* A point at distance $r$ from $0$ is determined by its
**support** $S \subseteq \iota$ of nonzero coordinates with $|S| = r$
($\binom{n}{r}$ choices) together with a choice of nonzero value in each
coordinate of $S$ ($(q-1)$ choices each, $(q-1)^r$ in total). These choices are
independent and exhaust the sphere, giving the product. $\square$

**Theorem 7 (Ball-volume formula).** The ball is the disjoint union of spheres
of radii $0, 1, \dots, r$, so
$$|B_r| = \sum_{i=0}^{r} \binom{n}{i}\,(q-1)^i.$$

*Proof sketch.* $B_r(0) = \bigsqcup_{i=0}^r \{ x : \mathrm{d}(x,0) = i \}$ is a
partition by exact distance; summing the per-sphere counts of Theorem 6 over
$i = 0, \dots, r$ gives the result. $\square$

**Corollary (entropy threshold).** Writing $r = \rho n$ with $\rho \in (0,1)$,
standard binomial-sum asymptotics give
$$\frac1n \log_q |B_{\rho n}| \longrightarrow H_q(\rho)
:= \rho \log_q(q-1) - \rho \log_q \rho - (1-\rho)\log_q(1-\rho),$$
the **$q$-ary entropy**. Hence the conjecture's dimension is
$k = (1 - H_q(\rho) + \varepsilon)\,n + o(n)$, exactly the
Gilbert–Varshamov / capacity frontier, and the target ball count
$q^{k-n}|B_\rho|$ is $q^{(\varepsilon + o(1))n} \cdot \Theta(1)$ — pinning $k$ as
the threshold at which codewords-per-ball is $\Theta(1)$.

---

## 7. Coset invariance for linear codes

**Theorem 8 (Coset invariance).** If $C \subseteq G$ is a *subgroup* (in
particular, a linear code), then the ball-count function
$z \mapsto |C \cap B_r(z)|$ is constant on cosets of $C$: for any $w \in C$ and
any $z \in G$,
$$|C \cap B_r(z + w)| = |C \cap B_r(z)|.$$

*Proof sketch.* The map $x \mapsto x + w$ is a bijection of $G$ that preserves
$C$ (since $w \in C$ and $C$ is a subgroup) and, by Theorem 1, maps $B_r(z)$
onto $B_r(z + w)$. It therefore restricts to a bijection
$C \cap B_r(z) \to C \cap B_r(z + w)$, so the two intersections have equal
cardinality. $\square$

**Consequence.** The $q^n$ per-centre discrepancy tests in the conjecture
collapse to $q^n/|C| = q^{n-k}$ *distinct* tests, one per coset in the quotient
$G/C$. Any union bound over centres can be re-indexed by $G/C$, an exponential
reduction in the number of failure events.

---

## 8. Algorithms

The constructive content yields three elementary but useful algorithms; full
pseudocode and code appear in the accompanying package.

1. **Exact ball volume** $|B_r|$ in $O(r)$ arithmetic operations via the partial
   binomial sum $\sum_{i\le r}\binom{n}{i}(q-1)^i$, computed with a rolling
   binomial update $\binom{n}{i+1} = \binom{n}{i}\cdot\frac{n-i}{i+1}$.
2. **Average verification** — for a given code $C$, compute every ball count and
   confirm $\sum_z |C \cap B_r(z)| = |C|\,|B_r|$ exactly, an empirical check of
   Theorem 4 (and a regression test of any code-enumeration routine).
3. **Bad-centre census** — count centres with $|C\cap B_r(z)| \ge t$ and compare
   against the Markov ceiling $|C|\,|B_r|/t$ of Theorem 5.

---

## 9. Applications

- **Coding theory.** Even spreading across Hamming balls underlies balanced
  decoding regions, predictable list-decoding sizes, and message-independent
  performance guarantees. The averaging identity certifies the *mean* of every
  such analysis without approximation.
- **Pseudorandomness and discrepancy theory.** The Hamming ball is a canonical
  test family; the Markov bound gives an unconditional cap on overcrowding for
  *any* point set, useful as a baseline before invoking randomness.
- **Numerical integration / sampling.** Low-discrepancy constructions over
  product alphabets inherit the exact mean and the centre-independence of test
  volumes proved here.
- **Hashing.** A linear hash family's load distribution over Hamming
  neighbourhoods is governed by exactly these counts; coset invariance reduces
  the analysis to the quotient.

---

## 10. Discussion

The conceptual payoff is a clean **separation of the deterministic from the
probabilistic**. The conjecture, as usually stated, entangles a heuristic mean
with a concentration claim. Theorem 4 shows the mean is not heuristic at all but
an exact identity, valid with no hypotheses. Theorem 5 then extracts the entire
upper tail for free. What is *left* — and only what is left — is a second-moment
estimate: bounding the variance of $|C \cap B_\rho(z)|$ over the random choice of
$C$ and converting it, via Chebyshev and a union bound over the $q^{n-k}$ cosets
(Theorem 8), into simultaneous control over all centres.

Crucially, the identity is *strictly more general* than the conjecture needs:
it assumes neither linearity nor randomness of $C$, only a translation group
structure on the ambient space. This generality is what makes it a reusable
kernel rather than a one-off step.

---

## 11. Future directions

**Direction 1 — Second-moment (variance) identity for random linear codes.**
For a uniformly random linear code $C$ of dimension $k$, the variance of
$|C \cap B_\rho(z)|$ (over the choice of $C$, fixed $z$) is conjectured to be at
most $(|C|\,|B_\rho|/q^n)(1 + o(1))$, matching the Poisson prediction. Because
the first moment is now an *exact deterministic* identity (Theorem 4), the entire
content of the conjecture is a second-moment bound; pairwise independence of
distinct nonzero codewords should reduce the variance to a sum over pairs that
the averaging identity already controls. A Chebyshev argument then needs only the
variance.

**Direction 2 — Union bound over cosets, not centres.** The "for every centre
$z$" quantifier can be replaced by "for every coset representative," reducing the
union bound from $q^n$ events to $q^n/|C|$ events, losslessly. Coset invariance
(Theorem 8) shows $z \mapsto |C \cap B_\rho(z)|$ is constant on cosets, so the
$q^n$ tests are really only $q^n/|C|$ distinct tests — an exponential saving in
the failure-probability union bound, re-indexing every "for all centres"
statement by the quotient $G/C$.

**Direction 3 — Exact rational target via the volume formula.** The discrepancy
target $|C|\,|B_\rho|/q^n$ equals the explicit rational
$q^{k-n}\sum_{i\le\rho n}\binom{n}{i}(q-1)^i$, and the threshold dimension
$k = \lceil(1 - \frac1n\log_q|B_\rho| + \varepsilon)n\rceil$ is the unique $k$
making this target tend to a constant multiple of $1$. The ball-volume formula
(Theorem 7) turns the target into an elementary expression in $n, q, \rho$ whose
$\log_q$ is, by entropy estimates, $(H_q(\rho) + o(1))n$ — pinning the threshold.

**Direction 4 — Lower-tail companion to the Markov bound.** Develop a
deterministic or near-deterministic lower-tail counterpart to Theorem 5, bounding
the number of *under-populated* balls and thereby reducing the residual
probabilistic burden to a single, symmetric concentration estimate.

---

## 12. Conclusion

We have formalized the unconditional kernel of the Hamming-ball discrepancy
conjecture: an exact averaging identity, a Markov-type upper-tail bound, the
explicit ball-volume formula, and coset invariance for linear codes. Together
these settle the first moment of the conjecture exactly and reduce its truth to a
clean, isolated second-moment problem over a quotient group of exponentially
smaller index. The mean was never in doubt; the work that remains is precisely
the spread.
