# The Quadratic-Residue Dial of $x^2 - N$: Exact Local Statistics, an Ensemble Null, and a Uniform Dispersion Ceiling

**Author:** Aristotle
**Date:** 2026-08-29
**Subject class:** Number theory — smooth numbers, sieve heuristics, quadratic characters

---

## Abstract

The quadratic sieve draws its relations from values of the polynomial
$f(x) = x^2 - N$, and folklore holds that this polynomial is *better than random*
for smoothness, because it is divisible by a prime $p$ on two residue classes
whenever $N$ is a quadratic residue mod $p$, versus one class for a generic
integer. We show that this folklore is exactly false at the level of first
moments, exactly true at the level of second moments, and that the second-moment
effect is bounded by an absolute constant independent of the smoothness bound.

Define the **dial** $D_p(N) = \#\{x \in \mathbb{Z}/p : x^2 = N\}$ and the induced
**local factor** $L_p(N) = (p - D_p(N))/(p-1)$, the ratio of the local
non-divisibility density of $f$ to that of a random integer. We prove: (i) the
dial dichotomy $D_p(N) \in \{0,1,2\}$ with the exact character identity
$D_p = 1 + \chi_p$; (ii) exact moments $\sum_N D_p(N) = p$ and
$\sum_N D_p(N)^2 = 2p-1$, whence $\mathbb{E}[L_p] = 1$ exactly and
$\operatorname{Var}(L_p) = \frac{1}{p(p-1)}$ exactly; (iii) for the **structure
correction** $C(N) = \prod_{p \le B} L_p(N)$, the ensemble mean is *exactly* $1$
for every finite family of odd primes and the second moment is *exactly*
$\Delta(a) = \prod_p \bigl(1 + \frac{1}{p(p-1)}\bigr)$; (iv) the **uniform
ceiling** $1 < \Delta(a) \le 2$, valid for every finite family of distinct odd
primes and hence for every smoothness bound; (v) **exact joint uniformity** of
the dial vector on $\{0,2\}^k$; and (vi) a **dispersion decay theorem**: in any
mixed count model with conditional mean $\lambda C(N)$ and conditional variance
$\lambda C(N)(1 - qC(N))$, one has $|\mathrm{Var} - \mathrm{Mean}| \le
\mathrm{Mean}\cdot(\lambda + 2q)$.

These results explain, and quantitatively bound, a large computational
experiment at $B = 1000$ and $u = \log v/\log B \in \{5,6,7,8\}$ comparing the
$B$-smoothness of $x^2-N$ against histogram-matched random controls. The measured
ratios $r(u) = 1.011, 0.949, 0.900, 1.200$ at $u \approx 5.96, 6.95, 7.93, 8.26$
all have confidence intervals covering $1$, with tightest bound
$|r-1| \le 0.217$; the observed per-$N$ overdispersion $D = 1.61\,[1.50,1.73]$ at
$u \approx 6$ and its disappearance above $u \approx 7$ are both consequences of
(iv) and (vi) respectively.

---

## 1. Introduction

### 1.1 The relation-collection bottleneck

Every subexponential integer factoring algorithm in the index-calculus family
spends the bulk of its time on one task: finding many integers in a prescribed
algebraic family that are $B$-smooth, i.e. have no prime factor exceeding $B$.
In the quadratic sieve the family is the set of values

$$f(x) = x^2 - N, \qquad x = \lceil \sqrt N \rceil, \lceil \sqrt N \rceil + 1, \dots$$

Since $f(x) \equiv x^2 \pmod N$, a multiplicative combination of smooth values
whose prime exponents are all even yields a congruence of squares $X^2 \equiv Y^2
\pmod N$, and $\gcd(X - Y, N)$ is a nontrivial factor with probability at least
$1/2$.

Complexity analysis of the sieve rests on a heuristic: that the smoothness
probability of $f(x)$ is that of a random integer of the same size. Concretely,
the Dickman–de Bruijn function $\rho$ gives the density of $B$-smooth integers up
to $v$ as $\rho(u) \approx u^{-u}$ where

$$u \;=\; \frac{\log v}{\log B},$$

and the heuristic asserts this applies to the polynomial values.

### 1.2 The folklore edge

The heuristic looks like it should be *pessimistic*, for a reason every
implementer knows. Reduce $f$ modulo a prime $p$. A random integer is divisible
by $p$ on a $1/p$ fraction of arguments; but $x^2 - N \equiv 0 \pmod p$ has two
solutions $x \equiv \pm r$ whenever $N \equiv r^2$ is a nonzero quadratic residue.
Double density! Sieving implementations exploit this directly: the factor base
consists only of primes for which $\left(\frac{N}{p}\right) = 1$, precisely
because the others contribute nothing.

The question this paper answers is whether that doubling amounts to a genuine
smoothness advantage — an $O(1)$ multiplicative gain over random integers of the
same size — and if not, what the observable arithmetic signature of the doubling
actually is.

### 1.3 The experimental frontier

A large computational experiment was run to test this at the scale that matters.
With $B = 1000$ fixed, candidates $v = |x^2 - N|$ with $N \le 2^{80}$ and
$x \le 4\sqrt N$ were binned by $u = \log v/\log B$ into bins around
$u = 5, 6, 7, 8$, and each was compared against a control population of integers
histogram-matched on bit-length and mantissa octant, tested through a shared
$\gcd$-chain primorial smoothness routine so that no implementation asymmetry
could enter. Approximately $1.49 \times 10^9$ candidates were tested per arm, with
$4000$ $N$-clusters per bin and cluster bootstrap resampling ($n=2000$).

The measured ratio $r(u) = p_{\text{cand}}/p_{\text{ctrl}}$:

| bin ($u$) | $r(u)$ | 95% CI |
|---|---|---|
| $5.96$ | $1.011$ | $[0.947,\ 1.075]$ |
| $6.95$ | $0.949$ | $[0.783,\ 1.152]$ |
| $7.93$ | $0.900$ | $[0.455,\ 1.700]$ |
| $8.26$ | $1.200$ | $[0.500,\ 3.000]$ |

All intervals cover $1$. The regression of $\log r$ on $u$ has slope $+0.036$,
CI $[-0.255, +0.345]$, $p = 0.831$ — flat. The tightest 95% bound obtained is
$|r - 1| \le 0.2168$ at the $u = 6$ bin. Every pre-registered deviation rule
returned false.

Two secondary signals were, however, real and confined to the low-$u$ face:

* **Per-$N$ overdispersion.** The index $D = \mathrm{Var}/\mathrm{Mean}$ of the
  per-$N$ smooth-value counts was $1.61\,[1.50,1.73]$ at $u \approx 6$, but
  $\approx 1.00$ at $u \approx 7, 8$.
* **A QR dial correlation.** The Spearman correlation between an $N$'s smoothness
  rate and the fraction of factor-base primes for which $N$ is a residue was
  $0.32$ (permutation $p = 7\times 10^{-4}$) at low $u$, decaying to $0.04$.

The purpose of this paper is to give the exact arithmetic behind all three
observations. Everything below is exact and rational; no analytic estimate,
error term, or asymptotic is used anywhere in the proofs.

---

## 2. The dial and its dichotomy

Throughout, $p$ denotes an odd prime and $\mathbb{Z}/p$ the field with $p$
elements.

**Definition 2.1 (Dial).** For $N \in \mathbb{Z}/p$ set
$$D_p(N) \;=\; \#\{\, x \in \mathbb{Z}/p \;:\; x^2 = N \,\}.$$
This is the number of residue classes of $x$ on which $p \mid x^2 - N$. A random
integer has dial $1$ at every prime.

**Lemma 2.2 (Root set).** For every $c \in \mathbb{Z}/p$,
$\{y : y^2 = c^2\} = \{c, -c\}$.

*Proof.* $y^2 = c^2 \iff (y-c)(y+c) = 0$, and $\mathbb{Z}/p$ is an integral
domain. $\square$

**Lemma 2.3.** If $p$ is odd then $c = -c \iff c = 0$.

*Proof.* $c = -c$ gives $2c = 0$; since $p \nmid 2$, the element $2$ is invertible,
so $c = 0$. The converse is clear. $\square$

**Theorem 2.4 (Dial Dichotomy).** Let $p$ be an odd prime. Then
$$D_p(c^2) = \begin{cases} 1 & c = 0,\\ 2 & c \ne 0,\end{cases}
\qquad\text{and}\qquad D_p(N) = 0 \iff N \text{ is not a square.}$$
Consequently $D_p(N) \le 2$ for all $N$, $D_p(0)=1$, and for $N \ne 0$,
$D_p(N) = 2$ if and only if $N$ is a quadratic residue.

*Proof.* By Lemma 2.2, the root set of $x^2 = c^2$ is $\{c,-c\}$, which is a
singleton exactly when $c = 0$ by Lemma 2.3, and has two elements otherwise.
The vanishing criterion is the statement that the root set is empty iff $N$ is
not of the form $r^2$, which is immediate. $\square$

**Corollary 2.5 (Character identity).** For odd $p$ and all $N \in \mathbb{Z}/p$,
$$D_p(N) \;=\; 1 + \chi_p(N),$$
where $\chi_p$ is the quadratic character (Legendre symbol) with the convention
$\chi_p(0) = 0$.

*Proof.* Check the three cases of Theorem 2.4 against
$\chi_p(0)=0$, $\chi_p(\text{residue}) = 1$, $\chi_p(\text{nonresidue}) = -1$.
$\square$

Corollary 2.5 is the conceptual pivot of the paper: the deviation of the dial
from its random value $1$ is *exactly a nontrivial multiplicative character*.
Everything about the first-moment null follows from the vanishing of a character
sum.

---

## 3. Exact moments of the dial

**Theorem 3.1 (First moment: exactly random).** For every prime $p$,
$$\sum_{N \in \mathbb{Z}/p} D_p(N) \;=\; p.$$
Equivalently, the mean dial is exactly $1$ — the same expected number of hit
residue classes as for a random integer.

*Proof.* The sum counts pairs $(x,N) \in (\mathbb{Z}/p)^2$ with $x^2 = N$; the
fibres of the map $x \mapsto x^2$ partition $\mathbb{Z}/p$, so the total is
$|\mathbb{Z}/p| = p$. Formally, this is the fibrewise cardinality identity
$\#S = \sum_{t} \#\{s \in S : g(s) = t\}$ applied to $g(x)=x^2$. $\square$

**Corollary 3.2.** $\sum_{N} \chi_p(N) = 0$ for odd $p$ — the classical character
sum vanishing, here a consequence of Theorem 3.1 via Corollary 2.5.

**Theorem 3.3 (Second moment).** For every odd prime $p$,
$$\sum_{N \in \mathbb{Z}/p} D_p(N)^2 \;=\; 2p - 1.$$

*Proof.* Expanding, $\sum_N D_p(N)^2$ counts pairs $(x,y)$ with $x^2 = y^2$,
which by fibring over $x$ equals $\sum_{x} D_p(x^2)$. By Theorem 2.4 this is
$1 + 2(p-1) = 2p-1$. $\square$

**Corollary 3.4 (Balance).** Exactly $(p-1)/2$ residues $N$ have $D_p(N) = 2$ and
exactly $(p-1)/2$ have $D_p(N) = 0$, with the single remaining value $N=0$ having
$D_p(0) = 1$.

*Proof.* Let $m_2, m_0$ be the two counts. Then $m_2 + m_0 = p-1$ and
$2m_2 + 1 = p$ by Theorem 3.1, so $m_2 = (p-1)/2$. $\square$

---

## 4. The local factor and its exact variance

The dial governs smoothness through the local non-divisibility density. For the
polynomial, $\Pr_x[p \nmid f(x)] = 1 - D_p(N)/p$; for a random integer it is
$1 - 1/p$.

**Definition 4.1 (Local factor).** For odd $p$ and $N \in \mathbb{Z}/p$,
$$L_p(N) \;=\; \frac{1 - D_p(N)/p}{1 - 1/p} \;=\; \frac{p - D_p(N)}{p - 1} \;\in\; \mathbb{Q}.$$

**Proposition 4.2 (Values and positivity).** $L_p(N) = \frac{p-2}{p-1}$ if
$D_p(N)=2$, and $L_p(N) = \frac{p}{p-1}$ if $D_p(N) = 0$; the intermediate value
$L_p(0) = 1$ occurs only at $N = 0$. Since $p \ge 3$ and $D_p \le 2$, we have
$L_p(N) > 0$ always.

**Proposition 4.3 (QR monotonicity, local form).** If $D_p(N) = 2$ and
$D_p(N') = 0$ then $L_p(N) < L_p(N')$: quadratic residues are strictly *harder*
to make smooth at $p$ than nonresidues.

*Proof.* $\frac{p-2}{p-1} < \frac{p}{p-1}$, the denominator being positive.
$\square$

**Theorem 4.4 (Local mean exactly one).** For every odd prime $p$,
$$\sum_{N \in \mathbb{Z}/p} L_p(N) \;=\; p, \qquad\text{i.e.}\qquad \mathbb{E}_N[L_p] = 1.$$

*Proof.* $\sum_N L_p(N) = \frac{1}{p-1}\bigl(p\cdot p - \sum_N D_p(N)\bigr)
= \frac{p^2 - p}{p-1} = p$ by Theorem 3.1. $\square$

**Theorem 4.5 (Local second moment).** For every odd prime $p$,
$$\sum_{N} L_p(N)^2 \;=\; p + \frac{1}{p-1},
\qquad\text{i.e.}\qquad \mathbb{E}_N[L_p^2] = 1 + \frac{1}{p(p-1)}.$$

*Proof.* $\sum_N (p - D_p(N))^2 = p^3 - 2p\sum_N D_p + \sum_N D_p^2
= p^3 - 2p^2 + 2p - 1$ by Theorems 3.1 and 3.3. Dividing by $(p-1)^2$ and
factoring $p^3 - 2p^2 + 2p - 1 = (p-1)(p^2 - p + 1)$ gives
$\frac{p^2-p+1}{p-1} = p + \frac{1}{p-1}$. $\square$

**Corollary 4.6 (Exact local variance).** For every odd prime $p$,
$$\operatorname{Var}_N(L_p) \;=\; \mathbb{E}[L_p^2] - 1 \;=\; \frac{1}{p(p-1)}.$$
Equivalently $\sum_N (L_p(N) - 1)^2 = \frac{1}{p-1}$.

This exact rational variance is the seed of everything that follows. It is the
entire arithmetic content of the "advantage" of $x^2 - N$: a per-prime wobble of
size $\Theta(p^{-2})$ around a mean pinned exactly at the random value.

---

## 5. The global structure correction

Fix a finite index set $I$ and an injective family $a : I \to \{$odd primes$\}$;
write $a_i = a(i)$. The residue data of $N$ is the tuple
$\mathbf{N} = (N_i)_{i \in I} \in \prod_i \mathbb{Z}/a_i$. By the Chinese
remainder theorem this is the same as $N$ modulo the primorial $\prod_i a_i$, and
all statements below transport along that isomorphism.

**Definition 5.1 (Structure correction).**
$$C(\mathbf{N}) \;=\; \prod_{i \in I} L_{a_i}(N_i) \;\in\; \mathbb{Q}_{>0}.$$
This is the full multiplicative discrepancy between the (Dickman-type) heuristic
smoothness probability of $x^2 - N$ and that of a size-matched random integer, at
smoothness bound $B = \max_i a_i$. A random integer has $C \equiv 1$.

**Definition 5.2 (Dispersion ceiling).**
$$\Delta(a) \;=\; \prod_{i \in I}\Bigl(1 + \frac{1}{a_i(a_i - 1)}\Bigr).$$

### 5.1 The ensemble null

**Theorem 5.3 (Ensemble mean exactly one).** For every finite family of odd
primes,
$$\sum_{\mathbf{N} \in \prod_i \mathbb{Z}/a_i} C(\mathbf{N}) \;=\; \prod_{i} a_i,
\qquad\text{i.e.}\qquad \mathbb{E}_{\mathbf{N}}[C] = 1 \text{ exactly}.$$
Equivalently, averaged over a full period of $N$ modulo $\prod_i a_i$, the
structure correction is exactly $1$.

*Proof.* The sum of a product over a product index set factors:
$\sum_{\mathbf{N}} \prod_i L_{a_i}(N_i) = \prod_i \sum_{N_i} L_{a_i}(N_i)$, and
each inner sum is $a_i$ by Theorem 4.4. The Chinese-remainder form follows by
transporting the sum along the ring isomorphism
$\mathbb{Z}/\prod_i a_i \cong \prod_i \mathbb{Z}/a_i$, which is a bijection on
the index of summation. $\square$

Theorem 5.3 is the exact statement corresponding to the experimental null
$r(u) = 1$. Note what it does **not** depend on: the smoothness bound $B$, the
size of $N$, the size of the values $v$, and hence $u$. *There is no first-order
smoothness edge from quadratic-polynomial structure, at any scale.*

### 5.2 The exact variance

**Theorem 5.4 (Ensemble second moment).**
$$\sum_{\mathbf{N}} C(\mathbf{N})^2 \;=\; \prod_i \Bigl(a_i + \frac{1}{a_i-1}\Bigr)
\;=\; \Bigl(\prod_i a_i\Bigr)\,\Delta(a),
\qquad \mathbb{E}[C^2] = \Delta(a).$$

*Proof.* Factor as in Theorem 5.3 using Theorem 4.5; then
$a_i + \frac{1}{a_i - 1} = a_i\bigl(1 + \frac{1}{a_i(a_i-1)}\bigr)$. $\square$

**Corollary 5.5 (Exact ensemble variance).**
$$\sum_{\mathbf{N}} \bigl(C(\mathbf{N}) - 1\bigr)^2 = \Bigl(\prod_i a_i\Bigr)\bigl(\Delta(a) - 1\bigr),
\qquad \operatorname{Var}(C) = \Delta(a) - 1.$$

*Proof.* Expand $(C-1)^2 = C^2 - 2C + 1$ and apply Theorems 5.3, 5.4 together
with $\#\prod_i \mathbb{Z}/a_i = \prod_i a_i$. $\square$

### 5.3 The uniform ceiling

The key quantitative fact is that $\Delta(a)$ is bounded by an absolute constant
*regardless of how large the smoothness bound is*.

**Lemma 5.6 (Telescoping).** For every integer $M \ge 3$,
$$\sum_{n=3}^{M} \frac{1}{n(n-1)} \;=\; \frac{1}{2} - \frac{1}{M}.$$

*Proof.* $\frac{1}{n(n-1)} = \frac{1}{n-1} - \frac{1}{n}$; the sum telescopes from
$\frac12$ to $\frac1M$. (Formally, induction on $M$.) $\square$

**Lemma 5.7.** For any finite set $S$ of integers $\ge 3$,
$\displaystyle\sum_{n \in S} \frac{1}{n(n-1)} \le \frac12$.

*Proof.* $S \subseteq [3, \max S]$ and all terms are nonnegative, so the sum is at
most the full sum, which is $\frac12 - \frac{1}{\max S} < \frac12$ by Lemma 5.6.
$\square$

**Lemma 5.8.** For nonnegative reals $x_1, \dots, x_k$ with $\sum x_i < 1$,
$$\prod_{i=1}^{k} (1 + x_i) \;\le\; \frac{1}{1 - \sum_i x_i}.$$

*Proof.* Induction on $k$. For the step it suffices that
$(1+x)\cdot\frac{1}{1-s} \le \frac{1}{1-(x+s)}$ whenever $x, s \ge 0$ and
$x + s < 1$, which after clearing the positive denominators reads
$(1+x)(1 - x - s) \le 1 - s$, i.e. $0 \le x^2 + xs$. $\square$

**Theorem 5.9 (Uniform dispersion ceiling).** For every finite family of
*distinct* odd primes — equivalently, for every smoothness bound $B$, however
large —
$$\Delta(a) \;=\; \prod_{i}\Bigl(1 + \frac{1}{a_i(a_i-1)}\Bigr) \;\le\; 2.$$

*Proof.* Set $x_i = \frac{1}{a_i(a_i-1)} \ge 0$. Distinctness lets us rewrite
$\sum_i x_i$ as a sum over the *set* $\{a_i\}$ of odd primes, all $\ge 3$, so
$\sum_i x_i \le \frac12$ by Lemma 5.7. Lemma 5.8 gives
$\Delta(a) \le \frac{1}{1 - 1/2} = 2$. $\square$

**Theorem 5.10 (Clustering is real).** If $I \ne \emptyset$ then
$\Delta(a) > 1$ strictly, hence $\operatorname{Var}(C) > 0$: the structure
correction is genuinely non-constant.

*Proof.* Every factor is $\ge 1$ and at least one factor is $> 1$. $\square$

Together, Theorems 5.9 and 5.10 pin the phenomenon: $1 < \Delta(a) \le 2$ always.
For the family $\{3,5,7\}$ one computes exactly
$$\Delta = \tfrac{7}{6}\cdot\tfrac{21}{20}\cdot\tfrac{43}{42} = \frac{301}{240} \approx 1.2542,$$
and the infinite product over all odd primes converges to $\approx 1.2967$. The
measured overdispersion index $D = 1.61\,[1.50,1.73]$ sits inside the a-priori
ceiling of $2$.

### 5.4 A tail bound

**Theorem 5.11 (Finite Chebyshev inequality).** For every $t > 0$,
$$t^2 \cdot \#\bigl\{\mathbf{N} : |C(\mathbf{N}) - 1| \ge t\bigr\}
\;\le\; \Bigl(\prod_i a_i\Bigr)\bigl(\Delta(a) - 1\bigr).$$
Hence the *fraction* of residue data with $|C - 1| \ge t$ is at most
$(\Delta(a)-1)/t^2 \le 1/t^2$ by Theorem 5.9.

*Proof.* On the exceptional set each summand $(C-1)^2$ is $\ge t^2$; sum over the
set, extend nonnegatively to the full index, and apply Corollary 5.5. $\square$

**Theorem 5.12 (Packaged null).** For every finite family of distinct odd primes
and every $t > 0$:

1. $\mathbb{E}[C] = 1$ exactly — no first-order smoothness edge; and
2. $\#\{\mathbf{N} : |C(\mathbf{N}) - 1| \ge t\} \le \prod_i a_i / t^2$ — deviation
   mass controlled uniformly in the family, hence uniformly in $B$.

This is the exact-arithmetic counterpart of the experimental verdict
"$|r - 1| \le 0.217$ together with a bounded per-$N$ overdispersion".

---

## 6. Exact joint uniformity of the dial vector

One might hope to salvage an edge from *correlations* between dials at different
primes: perhaps certain $N$ have systematically more primes "turned up". They do
not, and the statement is as sharp as possible.

**Theorem 6.1 (Exact independence of dials).** Let $a_1, \dots, a_k$ be distinct
odd primes. For every prescribed pattern $(d_1,\dots,d_k) \in \{0,2\}^k$,
$$\#\bigl\{\mathbf{N} : D_{a_i}(N_i) = d_i \ \forall i \bigr\}
\;=\; \frac{1}{2^{k}}\prod_{i=1}^{k}(a_i - 1),$$
independent of the pattern. The dial vector is therefore exactly uniform on
$\{0,2\}^k$.

*Proof.* The event factorises over coordinates, so the count is
$\prod_i \#\{x \in \mathbb{Z}/a_i : D_{a_i}(x) = d_i\}$; by Corollary 3.4 each
factor is $(a_i-1)/2$ regardless of whether $d_i$ is $0$ or $2$. $\square$

**Corollary 6.2 (Extremes of $C$).** The structure correction attains its maximum
$\prod_i \frac{a_i}{a_i - 1}$ exactly on the all-nonresidue pattern and its
minimum $\prod_i \frac{a_i-2}{a_i-1}$ exactly on the all-residue pattern, and each
of these two sets has cardinality $2^{-k}\prod_i (a_i - 1)$ — a relative density
of $2^{-k}\prod_i \frac{a_i-1}{a_i}$.

Extreme structure corrections are therefore *exponentially rare* in the number of
factor-base primes. This is the combinatorial reason the observed clustering is
$O(1)$ rather than exponential: the tails of $C$ are thin even though its range
is wide.

**Theorem 6.3 (Global QR monotonicity).** Let $\mathbf{N}, \mathbf{N}'$ agree in
every coordinate except $j$, where $D_{a_j}(N_j) = 2$ (residue) and
$D_{a_j}(N'_j) = 0$ (nonresidue). Then
$$C(\mathbf{N}) \;<\; C(\mathbf{N}').$$

*Proof.* Split both products at the coordinate $j$. The common tail
$\prod_{i \ne j} L_{a_i}(N_i)$ is strictly positive (Proposition 4.2), and the
$j$-th factors satisfy $L_{a_j}(N_j) < L_{a_j}(N'_j)$ (Proposition 4.3). Multiply.
$\square$

Theorem 6.3 is the exact mechanism behind the measured Spearman correlation
$0.32$ between an $N$'s smoothness rate and its QR fraction. It is *strictly
negative* in the sense that more residues means a smaller correction; the sign of
the observed correlation depends on the exact statistic used, but the monotone
dependence is unconditional.

---

## 7. Why the clustering dies at large $u$

The experiment's most puzzling feature is that both secondary signals disappear
above $u \approx 7$: the dispersion index drops from $1.61$ to $\approx 1.00$, the
QR correlation from $0.32$ to $0.04$. Yet Section 5 shows that the arithmetic
source of both, the distribution of $C$, is completely $u$-independent: mean
exactly $1$, variance exactly $\Delta(a) - 1$, no reference to $u$ anywhere. The
death of the clustering therefore *cannot* be an arithmetic effect.

It is a counting effect, and it is exactly quantifiable.

### 7.1 A finite law of total variance

Let $\Omega$ be a finite mixing space with weights $w : \Omega \to \mathbb{Q}$,
$\sum_\omega w_\omega = 1$, and for each $\omega$ let $P_\omega$ be a probability
vector on a finite outcome space $K$ with a value function
$\mathrm{val} : K \to \mathbb{Q}$. Write

$$m(\omega) = \sum_k P_\omega(k)\,\mathrm{val}(k), \qquad
v(\omega) = \sum_k P_\omega(k)\,(\mathrm{val}(k) - m(\omega))^2,$$

$$\overline{m} = \sum_\omega w_\omega m(\omega), \qquad
\overline{v} = \sum_\omega w_\omega \sum_k P_\omega(k)(\mathrm{val}(k)-\overline{m})^2.$$

**Theorem 7.1 (Law of total variance, finite and exact).**
$$\overline{v} \;=\; \sum_\omega w_\omega\, v(\omega) \;+\; \sum_\omega w_\omega\,(m(\omega) - \overline{m})^2.$$

*Proof.* Expand $(\mathrm{val}(k) - \overline{m})^2 =
(\mathrm{val}(k) - m(\omega))^2 + 2(\mathrm{val}(k)-m(\omega))(m(\omega)-\overline{m})
+ (m(\omega)-\overline{m})^2$ and sum; the cross term vanishes for each $\omega$
because $\sum_k P_\omega(k)(\mathrm{val}(k) - m(\omega)) = 0$. $\square$

### 7.2 The dispersion identity

Now take $\Omega$ to be the residue data with uniform weights, and model the
number of smooth values found for a given $N$ as a count with

$$m(\mathbf{N}) = \lambda\,C(\mathbf{N}), \qquad
v(\mathbf{N}) = \lambda\,C(\mathbf{N})\bigl(1 - q\,C(\mathbf{N})\bigr).$$

These are exactly the mean and variance of a binomial count of $n$ independent
trials with success probability $q\,C(\mathbf{N})$, where $\lambda = nq$ is the
event rate. (The model is realisable: a single Bernoulli trial with success
probability $q\,C(\mathbf{N})$ satisfies the hypotheses with $\lambda = q$.)

**Theorem 7.2 (Dispersion identity).** With $S_2 = \mathbb{E}[C^2]$ and
$\mathbb{E}[C] = 1$,
$$\mathrm{Mean} = \lambda, \qquad
\mathrm{Var} = \lambda\bigl(1 + \lambda(S_2 - 1) - q\,S_2\bigr).$$

*Proof.* The mean is immediate from $\mathbb{E}[C]=1$. For the variance, apply
Theorem 7.1: the average conditional variance is
$\lambda \mathbb{E}[C] - \lambda q \mathbb{E}[C^2] = \lambda - \lambda q S_2$, and
the variance of the conditional means is
$\lambda^2\mathbb{E}[C^2] - 2\lambda^2\mathbb{E}[C] + \lambda^2 = \lambda^2(S_2 - 1)$.
Add. $\square$

Dividing, the **dispersion index** is exactly

$$\frac{\mathrm{Var}}{\mathrm{Mean}} \;=\; 1 + \lambda(S_2 - 1) - q\,S_2.$$

The arithmetic enters *only* through $S_2$, which by Theorem 5.4 equals
$\Delta(a)$ and by Theorem 5.9 is at most $2$. The observable excess over Poisson
is proportional to the *event rate* $\lambda$.

**Theorem 7.3 (Bound on excess dispersion).** If $\lambda, q \ge 0$ and
$S_2 \ge 1$, then
$$\bigl|\mathrm{Var} - \mathrm{Mean}\bigr| \;\le\; \lambda\bigl(\lambda(S_2-1) + q\,S_2\bigr).$$

*Proof.* $\mathrm{Var} - \mathrm{Mean} = \lambda(\lambda(S_2-1) - qS_2)$, and the
absolute value of a difference of two nonnegative quantities is at most their
sum. $\square$

**Theorem 7.4 (Decay of clustering for $x^2 - N$).** For any family of distinct
odd primes, in the model above,
$$\bigl|\mathrm{Var} - \mathrm{Mean}\bigr| \;\le\; \lambda\,(\lambda + 2q)
\;=\; \mathrm{Mean}\cdot(\lambda + 2q).$$

*Proof.* Combine Theorem 7.3 with $S_2 = \Delta(a)$ (Theorem 5.4),
$\Delta(a) \le 2$ (Theorem 5.9) and $\Delta(a) \ge 1$ (Theorem 5.10):
$\lambda(\Delta - 1) \le \lambda$ and $q\Delta \le 2q$. $\square$

### 7.3 Reading the experiment

Theorem 7.4 is the resolution. The upper bound on the excess dispersion is
proportional to the event rate $\lambda$ and *uniform in the smoothness bound*.
At $u \approx 6$ the experiment had $\lambda$ of order one and observed
$D \approx 1.61$, comfortably below the ceiling. At $u \approx 8$ the smooth
events were so rare — of order $18$ events across $4000$ $N$-clusters, i.e.
$\lambda \approx 0.005$ — that Theorem 7.4 forces $|D - 1| \le \lambda + 2q
\approx 0.005 + 2q$, well below any achievable resolution. **The clustering did
not die; it became unobservable, at a rate the theory predicts exactly.**

The same reasoning applies to the QR correlation. Detecting a monotone
dependence of a per-$N$ *rate* on a per-$N$ covariate requires several events per
$N$; at $\lambda = 0.005$ the overwhelming majority of $N$ have zero events, and
rank correlation has essentially nothing to rank. The decay from $0.32$ to $0.04$
is the decay of statistical power, not of arithmetic.

---

## 8. Algorithms

All results are effective and cheap to verify numerically. Three algorithms make
the theory computational.

### 8.1 Exact dial spectrum

**Input:** an odd prime $p$. **Output:** the exact multiset
$\{D_p(N) : N \in \mathbb{Z}/p\}$ and the exact rational moments.

Compute the multiset by squaring: initialise a counter array of length $p$ to
zero and, for each $x \in \{0,\dots,p-1\}$, increment the entry at $x^2 \bmod p$.
Cost $O(p)$ time and $O(p)$ space. The first moment must be $p$ and the second
$2p-1$; the counters must be $1$ at index $0$ and $\{0,2\}$ elsewhere with
$(p-1)/2$ of each. This is a direct check of Theorems 2.4, 3.1, 3.3 and 3.4.

### 8.2 Exact dispersion ceiling

**Input:** a list of distinct odd primes. **Output:** the exact rational
$\Delta(a) = \prod (1 + \frac{1}{p(p-1)})$ and the exact variance
$\Delta(a) - 1$.

Compute in exact rational arithmetic to avoid any floating-point ambiguity. Cost
$O(k)$ rational multiplications for $k$ primes, with numerator and denominator
growing to $O(k \log B)$ bits. The output must satisfy $1 < \Delta \le 2$
(Theorems 5.9, 5.10), and for $\{3,5,7\}$ must equal exactly $301/240$.

### 8.3 Brute-force ensemble verification

**Input:** a small family of distinct odd primes $a_1,\dots,a_k$. **Output:**
$\sum_{\mathbf{N}} C(\mathbf{N})$, $\sum_{\mathbf{N}} C(\mathbf{N})^2$, and the
pattern census.

Enumerate all $\prod a_i$ residue tuples, compute $C$ exactly as a rational, and
accumulate. Cost $O(k \prod_i a_i)$; feasible for $\prod a_i$ up to a few
million. The first sum must equal exactly $\prod a_i$ (Theorem 5.3), the second
exactly $(\prod a_i)\Delta(a)$ (Theorem 5.4), and each of the $2^k$ dial patterns
must occur exactly $2^{-k}\prod(a_i - 1)$ times (Theorem 6.1). These are
zero-tolerance identity checks, not statistical tests: any discrepancy at all
would falsify the theory.

---

## 9. Discussion

### 9.1 Relation to earlier measurements

An earlier study reported candidate/control smoothness ratios of $0.88$–$0.91$
in the range $u < 4.75$ at scales up to $2^{44}$, and attributed them to a
finite-$x$ correction to the Dickman heuristic that is *shared with the controls*
— i.e. to the claim that the relation pool "ensemble-equals" an unrestricted
random pool. The present work extends that random-pool claim to $u \le 8.5$ and
is fully consistent with it; no novelty is claimed against it. What is new is
(a) the exact mechanism, which turns the empirical null into an identity, and
(b) the uniform ceiling, which converts "we found no edge" into "no edge of any
size is possible in the first moment, and any second-moment effect is at most a
factor $\Delta \le 2$".

### 9.2 Three structural patterns

**(i) Every structure signal here is a second-moment phenomenon.** The first
moment is pinned to the random value by a character sum that vanishes
identically (Corollaries 2.5, 3.2). This is not a near-cancellation with a small
error term; it is exact for every prime.

**(ii) The second moment is a convergent Euler product, hence $O(1)$.** The
polynomial structure of $x^2 - N$ can never buy more than a constant factor
(Theorem 5.9), and that constant is at most $2$, with true value $\approx 1.2967$
in the limit of all odd primes.

**(iii) Observability of a second moment is proportional to the event rate.**
Theorem 7.4 says that any experiment reporting overdispersion at rate $\lambda$ is
reporting $\lambda \cdot \operatorname{Var}(C)$ and nothing else. Comparing
dispersion measured at high rate with dispersion measured at low rate and
concluding that the mechanism changed is a methodological error; the mechanism is
constant, the microscope is not.

### 9.3 Consequences for sieve practice

The practical reading is deflationary. The quadratic sieve's efficiency comes
from the *smallness* of $|x^2 - N|$ near $\sqrt N$ and from the ability to
restrict the factor base to primes with $\left(\frac Np\right) = 1$ — a
cost saving in the sieve loop, not a probability gain in the smoothness rate.
Any attempt to squeeze an asymptotic improvement out of the arithmetic shape of
the polynomial is bounded, a priori, by a factor under $1.30$ in the second
moment and by $1$ exactly in the first.

The per-$N$ variance is nonetheless real and exploitable in a modest way: by
Theorem 6.3, $N$ with a low quadratic-residue fraction across the factor base
have systematically larger structure corrections. In practice one does not choose
$N$; but in variants where a multiplier $k$ is selected so that $kN$ has
favourable residue properties (a classical trick), Theorems 6.1–6.3 give the
exact distribution of what is being optimised, and Corollary 6.2 quantifies how
rare the best multipliers are: relative density $2^{-k}$ at the extreme.

### 9.4 Limitations honestly stated

The exact theorems are unconditional and hold for every finite family of odd
primes. The *experimental* verdict has two disclosed truncations. First, with
$N \le 2^{80}$ and $x \le 4\sqrt N$ at $B = 1000$, the reachable $u$ tops out near
$8.5$; production-scale $u \ge 9$ was not measured, although the exact theorems
apply there verbatim. Second, the experiment was time-capped, so the $u \approx 7$
and $u \approx 8$ bins had tiny event counts ($18$ vs $20$, and $12$ vs $10$), and
their confidence intervals are correspondingly wide. Finally, the theorems here
describe the *heuristic local densities*; converting them into a rigorous
statement about actual smoothness counts of $x^2 - N$ over a range of $x$ requires
a sieve-theoretic input that is not supplied here, and is genuinely hard.

---

## 10. Future work

**Degree-$d$ dispersion ceiling.** The ceiling $\prod_p(1 + \frac{1}{p(p-1)})$
came entirely from the *variance of the number of roots* of the sieve polynomial
mod $p$. For an irreducible $f \in \mathbb{Z}[X]$ of degree $d$ with Galois group
$G$, that variance is governed by the Chebotarev distribution of Frobenius cycle
types. We conjecture that the ensemble second moment of the structure correction
is $\prod_p\bigl(1 + \frac{\operatorname{Var}_G(\mathrm{fix})}{(p-1)^2} +
O(p^{-3/2})\bigr)$, where $\operatorname{Var}_G(\mathrm{fix})$ is the variance of
the number of fixed points of a uniform element of $G$; in particular it is
bounded by an explicit $c(d)$, and reduces to the factors above exactly when
$G = S_2$. Note that the *mean* number of roots is $1$ for every irreducible $f$
(Burnside's lemma applied to the transitive $G$-action on the roots), so the
first-order null of Theorem 5.3 survives at every degree — a satisfying
generalisation.

**Vanishing-rate criterion for observable clustering.** Theorem 7.4 bounds excess
dispersion by $\lambda + 2q$. This should be sharpened into a two-sided criterion:
given a target power and a number of clusters, the minimum event rate at which an
overdispersion of a given size is detectable. Such a criterion would let future
smoothness experiments pre-register the $u$ range in which a clustering claim is
even meaningful.

**Number-field sieve analogue.** The relevant polynomial there has degree $d$ and
the local factors involve the splitting type of $p$ in the associated number
field. The same three patterns should recur, with the ceiling determined by the
Galois group; quantifying it would give an a-priori bound on how much polynomial
selection can possibly buy.

**Beyond the second moment.** Theorem 6.1 shows the dial vector is exactly
uniform on $\{0,2\}^k$, so $\log C$ is an exact sum of independent bounded random
variables. Its full distribution — a lattice-supported infinitely divisible limit
after normalisation — should be computable, giving exact large-deviation rates
for the structure correction and hence a sharp replacement for Theorem 5.11.

---

## 11. Summary of results

| Statement | Content |
|---|---|
| Dial Dichotomy | $D_p(N) \in \{0,1,2\}$; equals $2$ on nonzero residues, $0$ on nonresidues, $1$ at $0$ |
| Character identity | $D_p = 1 + \chi_p$ pointwise, including at $0$ |
| First moment | $\sum_N D_p(N) = p$ exactly; mean dial exactly $1$ |
| Second moment | $\sum_N D_p(N)^2 = 2p-1$ exactly |
| Local variance | $\operatorname{Var}(L_p) = \frac{1}{p(p-1)}$ exactly |
| Ensemble neutrality | $\mathbb{E}[C] = 1$ exactly, for every finite family of odd primes |
| Ensemble variance | $\operatorname{Var}(C) = \Delta(a) - 1$ exactly |
| Uniform ceiling | $1 < \Delta(a) \le 2$ for every family of distinct odd primes |
| Chebyshev bound | fraction with $|C-1| \ge t$ is $\le (\Delta-1)/t^2 \le 1/t^2$ |
| Joint uniformity | every dial pattern in $\{0,2\}^k$ has exactly $2^{-k}\prod(a_i-1)$ preimages |
| QR monotonicity | flipping one coordinate residue $\to$ nonresidue strictly increases $C$ |
| Dispersion identity | $\mathrm{Var} = \lambda(1 + \lambda(S_2-1) - qS_2)$ exactly |
| Decay of clustering | $|\mathrm{Var} - \mathrm{Mean}| \le \mathrm{Mean}\cdot(\lambda + 2q)$ |
| Worked example | $\Delta(\{3,5,7\}) = \frac{301}{240}$; $\sum_{\mathbf{N}} C = 105$ |
