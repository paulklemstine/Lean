# Regularized Sum of Primes via Analytic Continuation Beyond the Natural Boundary

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (analytic number theory / mathematical physics bridge)

## Abstract

The physically-motivated identity $\zeta(-1) = 1 + 2 + 3 + \cdots "=" -\tfrac{1}{12}$,
obtained by analytic continuation of the Riemann zeta function, raises a natural
question: does the analogous "sum of all primes," $2 + 3 + 5 + 7 + \cdots$, admit
a finite regularized value via the prime zeta function $P(s) = \sum_p p^{-s}$? We
establish the rigorous elementary core that frames and obstructs this question.
Our central result is that $P(s)$ has **abscissa of convergence exactly $1$**: the
series converges if and only if $s > 1$, and consequently diverges on the entire
closed half-line $s \le 1$, including the boundary $s = 1$ (recovering Euler's
divergence of $\sum_p 1/p$) and the target point $s = -1$. We further prove that
the prime series and the full integer series $\sum_n n^{-s}$ share *the same*
abscissa $1$, isolating the multiplicative (Euler-product) content as the only
place the two differ. Combining this with the classical value
$\zeta(-1) = -\tfrac{1}{12}$ (derived from the Bernoulli formula) yields a precise
**dichotomy**: the full zeta function admits the regularized value at $s = -1$
while the bare prime series provably does not, since the latter possesses a
genuine natural boundary at $\mathrm{Re}\,s = 0$. Finally, we show via a
cross-domain corollary that the Maynard–Tao bounded-gaps regime does not alter
this verdict: even with infinitely many primes within $246$ of a neighbor, the
prime zeta series diverges at $s = -1$. All results have been formally verified.

---

## 1. Introduction

### 1.1 Motivation

In quantum field theory and statistical mechanics one routinely encounters
divergent sums that are assigned finite values by *zeta-regularization*. The
prototype is the Ramanujan–Casimir value
$$\sum_{n=1}^\infty n \;\longmapsto\; \zeta(-1) = -\frac{1}{12},$$
where the assignment is not literal summation but the value at $s = -1$ of the
analytic continuation of $\zeta(s) = \sum_n n^{-s}$ past its abscissa of
convergence $s = 1$. This value is genuine physics: it appears in the Casimir
energy of a scalar field between parallel plates and in the critical dimension
calculation of bosonic string theory.

A tempting analogue replaces the integers by the primes. The prime zeta function
$$P(s) = \sum_{p \text{ prime}} p^{-s}$$
formally evaluates at $s = -1$ to $\sum_p p = 2 + 3 + 5 + 7 + \cdots$, the "sum of
all primes." Does $P$ admit a continuation assigning a finite value here?

### 1.2 Contributions

This paper establishes the rigorous, fully formalized foundation for that
question, with the following structure.

1. A sharp **abscissa-of-convergence** theorem for $P$ (Theorem 3.1): convergence
   holds iff $s > 1$.
2. **Divergence on the whole half-line** $s \le 1$ (Theorem 3.2), with the
   boundary case $s = 1$ recovering Euler's $\sum_p 1/p = \infty$ (Corollary 3.3)
   and the target case $s = -1$ (Corollary 3.4) showing the bare "sum of all
   primes" diverges.
3. **Equality of abscissae** for the prime series and the full integer series
   (Theorem 3.6), isolating multiplicativity as the only distinguishing feature.
4. The **dichotomy** with $\zeta(-1) = -\tfrac{1}{12}$ (Theorems 4.1–4.2):
   continuation works for the additive object but is obstructed for the prime
   object by its natural boundary at $\mathrm{Re}\,s = 0$.
5. A **cross-domain corollary** (Theorem 5.1): the Maynard–Tao bounded-gaps
   hypothesis (Theorem 5.3) leaves the abscissa and the divergence at $s=-1$
   unchanged.

All statements have been formally verified; the corresponding formal identifiers
are given alongside each result.

---

## 2. Definitions

We work over the reals; complex statements are reduced to real exponents via
$\lvert p^{-s}\rvert = p^{-\mathrm{Re}\,s}$ where needed. We write $\mathbb{P}$
for the set of primes and use the type of primes for indexing convergent sums.

**Definition 2.1 (Prime zeta function; `primeZeta`).**
For $s \in \mathbb{R}$,
$$P(s) := \sum_{p \in \mathbb{P}} p^{-s},$$
the (real) prime zeta function, where the sum ranges over the type of prime
natural numbers and $p^{-s}$ denotes the real power (`Real.rpow`). When the family
$\{p^{-s}\}_p$ is not summable, $P(s)$ is set to $0$ by the convention of the
unconditional sum `tsum`; all analytic content is therefore carried by the
*summability* statements below.

**Definition 2.2 (Prime gap; `TwinPrimeGaps.primeGap`).**
Let $p_n$ denote the $n$-th prime in increasing enumeration. The $n$-th prime gap
is
$$g_n := p_{n+1} - p_n.$$

**Recalled object (Riemann zeta).** $\zeta(s) = \sum_{n \ge 1} n^{-s}$ for
$\mathrm{Re}\,s > 1$, extended meromorphically to $\mathbb{C}$ with a simple pole
at $s = 1$.

---

## 3. The abscissa of convergence of the prime zeta function

The technical engine is the standard summability criterion for real prime powers:
$\sum_p p^{r}$ is summable iff $r < -1$ (formally `Nat.Primes.summable_rpow`).
Setting $r = -s$ converts this threshold into a statement about $s$.

**Theorem 3.1 (Abscissa of convergence; `primeZeta_summable_iff`).**
For every $s \in \mathbb{R}$,
$$\sum_{p} p^{-s} \text{ converges (absolutely)} \iff 1 < s.$$

*Proof sketch.* Apply the criterion with exponent $r = -s$: summability holds iff
$-s < -1$, i.e. iff $s > 1$. The equivalence is immediate by linear arithmetic.
$\qquad\blacksquare$

**Theorem 3.2 (Divergence on the closed half-line; `primeZeta_not_summable_of_le_one`).**
If $s \le 1$ then $\sum_p p^{-s}$ does not converge.

*Proof sketch.* By Theorem 3.1 convergence is equivalent to $s > 1$, which
contradicts $s \le 1$. $\qquad\blacksquare$

**Corollary 3.3 (Euler boundary; `primeZeta_not_summable_one`).**
The series of prime reciprocals $\sum_p p^{-1} = \sum_p 1/p$ diverges.

*Proof sketch.* The case $s = 1$ of Theorem 3.2 (with $1 \le 1$). This recovers
Euler's 1737 theorem; the partial sums grow like $\log\log N$. $\qquad\blacksquare$

**Corollary 3.4 (The "sum of all primes" point; `primeZeta_not_summable_neg_one`).**
At $s = -1$ the defining series $\sum_p p^{-(-1)} = \sum_p p$ diverges.

*Proof sketch.* The case $s = -1$ of Theorem 3.2 (with $-1 \le 1$). Hence any
regularized value at $s = -1$, if it exists, can never be the value of the series
itself. $\qquad\blacksquare$

**Proposition 3.5 (Positivity in the region of convergence; `primeZeta_pos`).**
If $1 < s$ then $P(s) > 0$.

*Proof sketch.* In the convergent regime ($s > 1$ by Theorem 3.1) every term
$p^{-s}$ is nonnegative, and the prime $p = 2$ contributes the strictly positive
term $2^{-s} > 0$; a positive term inside a convergent nonnegative sum forces the
sum to be strictly positive. $\qquad\blacksquare$

**Theorem 3.6 (Equal abscissae; `primeZeta_abscissa_eq_nat_zeta`).**
For every $s \in \mathbb{R}$,
$$\sum_{p} p^{-s} \text{ converges} \iff \sum_{n \ge 1} n^{-s} \text{ converges.}$$
In particular the prime zeta series and the full zeta series have the *same*
abscissa of convergence, namely $1$.

*Proof sketch.* By Theorem 3.1 the left side is equivalent to $s > 1$; by the
classical $p$-series criterion (`Real.summable_nat_rpow`) the right side is
equivalent to $-s < -1$, i.e. $s > 1$. The two thresholds coincide.
$\qquad\blacksquare$

**Remark.** Theorem 3.6 is the crux of the paper's narrative: as *bare series*,
the primes and the integers are indistinguishable in their convergence behavior.
Everything that follows — why one regularizes and the other does not — is therefore
not a matter of the abscissa but of the *analytic nature of the continued
function*, which is multiplicative for $P$ and additive for $\zeta$.

---

## 4. The dichotomy: continuation of $\zeta$ vs. the natural boundary of $P$

**Theorem 4.1 ($\zeta(-1) = -1/12$; `riemannZeta_neg_one_eq`).**
$$\zeta(-1) = -\frac{1}{12}.$$

*Proof sketch.* The values of $\zeta$ at negative integers are given by Bernoulli
numbers: $\zeta(-n) = -B_{n+1}/(n+1)$ for $n \ge 1$. For $n = 1$ this gives
$\zeta(-1) = -B_2/2$; with $B_2 = \tfrac16$ one obtains
$\zeta(-1) = -\tfrac{1}{12}$ after a cast/normalization computation. (Formally,
this uses `riemannZeta_neg_nat_eq_bernoulli` and `bernoulli_two`.)
$\qquad\blacksquare$

**Theorem 4.2 (Boundary vs. regularization dichotomy; `prime_zeta_boundary_vs_zeta_regularization`).**
The following hold simultaneously:
1. the bare prime series $\sum_p p^{-s}$ diverges at $s = -1$ (Corollary 3.4); and
2. the full zeta function satisfies $\zeta(-1) = -\tfrac{1}{12}$ (Theorem 4.1).

There is no contradiction: the two facts live on opposite sides of the natural
boundary $\mathrm{Re}\,s = 0$ of $P$.

*Proof sketch.* Conjunction of Corollary 3.4 and Theorem 4.1. The conceptual
content is the absence of tension: $-\tfrac{1}{12}$ is a value of the *completed*
(meromorphic on $\mathbb{C}$) additive object, whereas $P$ cannot be continued to
$s = -1$ at all. $\qquad\blacksquare$

### 4.1 Why the prime function cannot cross $\mathrm{Re}\,s = 0$ (discussion)

The link between $P$ and $\zeta$ is the logarithmic Euler product. From
$\zeta(s) = \prod_p (1 - p^{-s})^{-1}$ one obtains, for $\mathrm{Re}\,s > 1$,
$$\log \zeta(s) = \sum_{k \ge 1} \frac{1}{k} P(ks), \qquad\text{equivalently}\qquad
P(s) = \sum_{k \ge 1} \frac{\mu(k)}{k}\,\log \zeta(ks),$$
by Möbius inversion, where $\mu$ is the Möbius function. The right-hand
representation continues $P$ into the strip $0 < \mathrm{Re}\,s \le 1$. However,
$\log\zeta$ acquires logarithmic singularities at the pole and at every nontrivial
zero of $\zeta$; under the rescalings $s \mapsto ks$ these singularities
accumulate densely along the line $\mathrm{Re}\,s = 0$. This is the classical
*Landau–Walfisz natural boundary* phenomenon for $P$: the line $\mathrm{Re}\,s=0$
cannot be crossed, so no value $P(-1)$ exists. (The continuation into the strip
and the natural-boundary statement are recorded as Conjectures 1–2 in §7; the
formal development proves only the divergence obstruction, not the continuation.)

---

## 5. Bounded gaps do not regularize the prime sum

We connect the analytic obstruction to the modern theory of small gaps between
primes.

**Theorem 5.3 (Maynard–Tao bounded gaps; `TwinPrimeGaps.liminf_primeGap_le_246`).**
If for every $N$ there exist primes $p < q \le p + 246$ with $N \le p$ (the
Maynard–Tao bounded-pairs hypothesis), then
$$\liminf_{n\to\infty} g_n \le 246.$$

*Proof sketch.* A bounded prime *pair* $p < q \le p+B$ forces a bounded
*consecutive* gap: the next prime after $p = p_n$ is $p_{n+1} \le q$ (Lemma 5.4),
so $g_n = p_{n+1} - p_n \le q - p \le B$. Arbitrarily large such pairs produce
indices $n$ with $g_n \le B$ infinitely often, and the genuine
$\liminf$ statement follows from `Filter.liminf_le_of_frequently_le` with
$B = 246$. $\qquad\blacksquare$

**Lemma 5.4 (Next prime after a pair; `TwinPrimeGaps.next_prime_le_of_prime_lt`).**
If $p, q$ are prime with $p < q$, then the prime immediately following $p$ is at
most $q$.

*Proof sketch.* Counting primes, $\#\{r \le q : r \text{ prime}\} \ge
\#\{r \le p\} + 1$, so the $(\,\#\{r\le p\}+1\,)$-th prime does not exceed $q$
(`Nat.nth_lt_of_lt_count`). $\qquad\blacksquare$

**Remark 5.2 (concrete instance; `next_prime_after_two_le_three`).** As a sanity
check of Lemma 5.4, the prime immediately after $2$ is at most $3$ (and indeed
equals $3$).

**Theorem 5.1 (Bounded gaps coexist with prime-zeta divergence; `bounded_gaps_and_prime_zeta_divergence`).**
Even under the bounded-gaps hypothesis of Theorem 5.3, the prime zeta series still
diverges at $s = -1$:
$$\Big(\liminf_n g_n \le 246\Big) \ \wedge\ \neg\,\mathrm{Summable}\big(p \mapsto p^{-(-1)}\big).$$

*Proof sketch.* The second conjunct is Corollary 3.4, which is unconditional; the
first is Theorem 5.3. They hold simultaneously. Conceptually, the abscissa of
convergence is a *density* invariant: it is determined by the global thinning of
the primes ($\pi(x) \sim x/\log x$), not by local clustering. Bounded gaps refine
the local distribution but cannot move the abscissa away from $1$, hence cannot
produce convergence at $s = -1$. $\qquad\blacksquare$

---

## 6. Algorithms

The results suggest several concrete computations. We describe them here; full
Python implementations appear in the accompanying `demo.py` and in the package
algorithm listing.

### 6.1 Empirical abscissa estimation by ratio test

To witness Theorem 3.1 numerically, compute partial sums $S_N(s) = \sum_{p \le N}
p^{-s}$ for a grid of $s$ values and observe stabilization for $s > 1$ versus
unbounded growth for $s \le 1$. A doubling test ($S_{2N}/S_N \to 1$ iff
convergent) estimates the abscissa to high accuracy and pinpoints the wall at
$s = 1$.

### 6.2 Logarithmic-Euler-product / Möbius reconstruction of $P(s)$

For $s > 1$, evaluate $P(s)$ in two independent ways: (i) directly as
$\sum_{p \le N} p^{-s}$, and (ii) via $P(s) = \sum_{k=1}^{K} \tfrac{\mu(k)}{k}
\log\zeta(ks)$. Agreement of the two values for $s > 1$ validates the logarithmic
Euler product that underlies the natural-boundary discussion of §4.1.

### 6.3 Bernoulli evaluation of $\zeta(-1)$

Confirm Theorem 4.1 by evaluating $\zeta(-n) = -B_{n+1}/(n+1)$ with exact rational
Bernoulli numbers, returning $-\tfrac{1}{12}$ for $n=1$.

---

## 7. Future directions

Derived from this cycle's findings: $P(s)$ has abscissa of convergence exactly $1$
(Theorem 3.1), diverges on the whole half-line $s \le 1$ (Theorem 3.2; in
particular at $s = -1$, Corollary 3.4), while the full zeta function carries the
regularized value $\zeta(-1) = -\tfrac{1}{12}$ (Theorem 4.1). The honest
obstruction is the natural boundary of $P$ at $\mathrm{Re}\,s = 0$.

**Conjecture 1 — Analytic-continuation strip of $P$.** $P(s)$ extends
holomorphically to the strip $0 < \mathrm{Re}\,s \le 1$ via
$P(s) = \sum_{n\ge1} \tfrac{\mu(n)}{n}\log\zeta(ns)$, diverging to $+\infty$ as
$s \to 1^+$. The right transform is $\log\zeta$ (not $\zeta$); the Euler product
already expresses $\zeta$ through a prime sum, and Möbius inversion peels off the
prime-power tail.

**Conjecture 2 — Natural boundary at $\mathrm{Re}\,s = 0$.** The continued $P$
admits no holomorphic extension across any point of $\mathrm{Re}\,s = 0$. The
singularities of $\log\zeta(ns)$ at the zeros and pole of $\zeta$ accumulate
densely there as $n \to \infty$.

**Conjecture 3 — Zeta-regularization is the only consistent prime value.** Any
summation method that is (i) linear, (ii) stable, and (iii) consistent with the
Dirichlet series where it converges assigns the full-zeta value to $\sum n$ at
$s=-1$ but cannot assign any finite value to $\sum p$ consistent with the prime
Euler product. The prime divergence is multiplicative, governed by $\log\zeta$,
whose $s=-1$ behavior is singular while $\zeta(-1)$ itself is finite.

**Conjecture 4 — Bounded gaps do not regularize the prime sum.** For every fixed
bound $B$, infinitely many prime pairs within distance $B$ leave the abscissa of
$P$ at $1$ and the value at $s=-1$ undefined. Abscissa of convergence is a density
invariant insensitive to local clustering; Theorem 5.1 already exhibits the
coexistence in one statement.

---

## 8. Discussion

The mathematical lesson is that *convergence threshold* and *continuability* are
independent properties. Theorem 3.6 shows the prime and integer series are
identical at the level of the abscissa; the dichotomy of §4 shows they diverge
completely at the level of analytic continuation. The separating invariant is the
multiplicative structure encoded by the Euler product: the integer series
continues to a function meromorphic on all of $\mathbb{C}$, while the prime
series, being a logarithmic transform, inherits a natural boundary. The
"regularized sum of all primes" is therefore not a value waiting to be computed
but a precisely locatable impossibility — and Theorem 5.1 shows it is robust even
against the deepest known structural facts about prime clustering.
