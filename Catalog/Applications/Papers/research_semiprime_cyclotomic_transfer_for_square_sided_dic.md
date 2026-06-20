# Semiprime Cyclotomic Transfer for Square-Sided Dice: The Verified Base Case $\Phi_6$

**Author:** Aristotle

**Date:** 2026-06-20

**Domain:** Number Theory (cyclotomic polynomials, generating functions, combinatorics of dice)

---

## Abstract

We study a family of *cyclotomic transfer* constructions that produce nonstandard
pairs of dice with identical sum distributions. Encoding an $N$-sided die with
faces $1,\dots,N$ as the generating polynomial $S_N = \sum_{i=1}^N x^i$, the joint
distribution of the sum of two dice is the polynomial product of their generators.
We formalize the *semiprime cyclotomic transfer conjecture*: for distinct primes
$p < q$ with $pq \mid m$ and $n^2 \ge (p-1)(q-1)+1$, the pair
$P = S_{m^2}/\Phi_{pq}$ and $Q = S_{n^2}\cdot\Phi_{pq}$ is a nonstandard
square-sided dice pair, meaning both polynomials have nonnegative integer
coefficients, $P(1) = m^2$, $Q(1) = n^2$, and $P\cdot Q = S_{m^2}\cdot S_{n^2}$.

We then establish, completely and explicitly, the base case $p = 2$, $q = 3$,
$m = 6$, $n = 2$, built on the sixth cyclotomic polynomial $\Phi_6 = x^2 - x + 1$.
Our two central results are the quotient identity
$\Phi_6 \cdot P_{36} = S_{36}$, where $P_{36} = \sum_{j=0}^{5}\mathrm{block}(j)$
is an explicit nonnegative block polynomial, and the product identity
$Q_4 = \Phi_6\cdot S_4 = x + x^3 + x^4 + x^6$. Together these certify that
$(P_{36}, Q_4)$ is a valid nonstandard pair of square-sided dice of sizes $36$ and
$4$ with $P_{36}\cdot Q_4 = S_{36}\cdot S_4$. We give proof sketches, an algorithm
for the block decomposition, numerical demonstrations, and a program of
generalizations.

---

## 1. Introduction

### 1.1 Sicherman dice and the algebra of chance

A classic recreational result, the *Sicherman dice*, exhibits two six-sided dice
with faces $\{1,2,2,3,3,4\}$ and $\{1,3,4,5,6,8\}$ whose pairwise sum distribution
is identical to that of two standard dice. The phenomenon is best understood
through generating functions. Identify a die with face multiset $A$ by the
polynomial $\sum_{a\in A} x^a$; then the distribution of the sum of two
independent dice is the coefficient sequence of the *product* of their
polynomials. Two pairs of dice are *sum-equivalent* exactly when their generating
products coincide. Constructing nonstandard equivalent dice is therefore a problem
of factoring a fixed polynomial into legitimate die polynomials — those with
nonnegative integer coefficients and correct face counts.

The standard $N$-sided die has the generating polynomial

$$S_N(x) = \sum_{i=1}^{N} x^i = x + x^2 + \dots + x^N,$$

which factors through the geometric series identity as

$$S_N(x) = x\cdot\frac{x^N - 1}{x - 1} = x\prod_{\substack{d \mid N \\ d > 1}}\Phi_d(x),$$

where $\Phi_d$ is the $d$-th cyclotomic polynomial. Every Sicherman-style
construction amounts to redistributing the cyclotomic factors $\Phi_d$ among the
factors while preserving nonnegativity.

### 1.2 The square-sided, semiprime variant

We focus on a particular, arithmetically rich slice of this landscape. We require:

1. the die sizes to be perfect squares, $m^2$ and $n^2$ (hence *square-sided*); and
2. the transferred cyclotomic factor to be $\Phi_{pq}$ for distinct primes $p < q$
   (hence *semiprime*).

The interest is that $\Phi_{pq}$ is the smallest family of cyclotomic polynomials
with genuinely nontrivial coefficient behavior: $\Phi_p$ and $\Phi_{p^k}$ have all
coefficients in $\{0,1\}$, but $\Phi_{pq}$ has a more delicate structure (and for
three or more primes, cyclotomic coefficients can even exceed $1$ in absolute
value, as in the famous $\Phi_{105}$). The semiprime case is the first nontrivial
testing ground for whether a cyclotomic transfer keeps quotient and product
coefficients nonnegative.

### 1.3 Why semiprime indices are the critical case

The coefficient behavior of cyclotomic polynomials is famously subtle, and the
semiprime indices $pq$ sit exactly at the boundary between trivial and intricate.
For a prime power $p^k$, the cyclotomic polynomial is *flat*: every coefficient of
$\Phi_{p^k}$ lies in $\{0, 1\}$ (indeed $\Phi_{p^k}(x) = \Phi_p(x^{p^{k-1}})$ and
$\Phi_p = 1 + x + \dots + x^{p-1}$). For two distinct primes the situation is
still controlled but no longer trivial: a classical theorem of Migotti and
Lam–Leung shows that every coefficient of $\Phi_{pq}$ is one of $-1$, $0$, or $1$,
with an explicit combinatorial rule for which is which. The presence of genuine
$-1$ coefficients is precisely what makes the transfer nonobvious — a single
misplaced negative coefficient in the quotient $S_{m^2}/\Phi_{pq}$ or the product
$S_{n^2}\cdot\Phi_{pq}$ would invalidate the die. (For three or more distinct
primes the coefficients can grow without bound, as the celebrated example
$\Phi_{105}$ first reveals with a coefficient of $-2$; we deliberately stay in the
semiprime regime where coefficients remain in $\{-1,0,1\}$.) The conjecture's
threshold $n^2 \ge (p-1)(q-1)+1 = \deg\Phi_{pq} + 1$ is the natural condition
under which the small die $S_{n^2}$ is long enough to absorb the $-1$ coefficients
of $\Phi_{pq}$ without leaving a net negative entry.

### 1.4 Contributions

- We state precisely the **semiprime cyclotomic transfer conjecture** (Section 3).
- We define the explicit **block polynomial** $P_{36}$ and prove the **quotient
  identity** $\Phi_6\cdot P_{36} = S_{36}$ (Section 4, Theorem 1).
- We compute the transferred small die $Q_4 = \Phi_6\cdot S_4 = x+x^3+x^4+x^6$ and
  prove the **product identity** $P_{36}\cdot Q_4 = S_{36}\cdot S_4$ (Section 4,
  Theorem 2 and Corollary 1).
- We verify the **face-count conditions** $P_{36}(1)=36$, $Q_4(1)=4$ and the
  **nonnegativity** of both polynomials (Section 4, Proposition 1).
- We supply a **block-decomposition algorithm** (Section 5), **numerical
  demonstrations** (Section 6), and a structured **program of generalizations**
  (Section 8).

---

## 2. Preliminaries and Definitions

Throughout, we work in the polynomial ring $\mathbb{Z}[x]$, with auxiliary
nonnegative-coefficient computations performed in $\mathbb{N}[x]$ and cast into
$\mathbb{Z}[x]$ to certify nonnegativity.

**Definition 1 (Die generating polynomial).** For $N \in \mathbb{N}$, the standard
$N$-sided die generating polynomial is
$$S_N(x) = \sum_{i=1}^{N} x^i = x + x^2 + \dots + x^N.$$
More generally, a *die polynomial* is any $D \in \mathbb{Z}[x]$ with nonnegative
integer coefficients and $D(0) = 0$; its *face count* is $D(1)$, the total number
of faces (with multiplicity).

**Definition 2 (Cyclotomic polynomial).** The $d$-th cyclotomic polynomial
$\Phi_d(x) \in \mathbb{Z}[x]$ is the minimal polynomial over $\mathbb{Q}$ of a
primitive $d$-th root of unity. They satisfy
$x^d - 1 = \prod_{e \mid d}\Phi_e(x)$. The first few relevant values are
$$\Phi_1 = x - 1,\quad \Phi_2 = x + 1,\quad \Phi_3 = x^2 + x + 1,\quad \Phi_4 = x^2 + 1,\quad \Phi_6 = x^2 - x + 1.$$

**Definition 3 (Sum-equivalence).** Two ordered pairs of die polynomials
$(D_1, D_2)$ and $(E_1, E_2)$ are *sum-equivalent* if $D_1 D_2 = E_1 E_2$ in
$\mathbb{Z}[x]$. They are *nonstandard relative to* $(S_a, S_b)$ if
$D_1 D_2 = S_a S_b$ but $(D_1, D_2) \neq (S_a, S_b)$ as ordered pairs.

**Lemma (Generating-function principle).** If dice $D_1$ and $D_2$ are rolled
independently, the number of ways their faces sum to $s$ equals the coefficient of
$x^s$ in $D_1(x)\,D_2(x)$. Consequently sum-equivalent pairs produce identical sum
distributions. *(Standard; the product of generating polynomials convolves the
face multisets.)*

**Definition 4 (Block polynomial).** For $j \in \mathbb{N}$, define the degree-$4$
*block* shifted by $6j$,
$$\mathrm{block}(j) = x^{6j+1} + 2x^{6j+2} + 2x^{6j+3} + x^{6j+4} \in \mathbb{N}[x],$$
and set, for the base case,
$$P_{36}(x) = \sum_{j=0}^{5}\mathrm{block}(j).$$

**Definition 5 (Base-case transferred die).**
$$Q_4(x) = \Phi_6(x)\cdot S_4(x).$$

---

## 3. The Semiprime Cyclotomic Transfer Conjecture

**Conjecture (Semiprime cyclotomic transfer).** Let $p < q$ be distinct primes and
let $m, n \in \mathbb{N}$ satisfy $pq \mid m$ and $n^2 \ge (p-1)(q-1) + 1$. Define
$$P(x) = \frac{S_{m^2}(x)}{\Phi_{pq}(x)}, \qquad Q(x) = S_{n^2}(x)\cdot\Phi_{pq}(x).$$
Then $(P, Q)$ is a *nonstandard square-sided dice pair of sizes $m^2$ and $n^2$*:
1. **Divisibility and nonnegativity of $P$:** $\Phi_{pq} \mid S_{m^2}$ in
   $\mathbb{Z}[x]$ and the quotient $P$ has nonnegative integer coefficients.
2. **Nonnegativity of $Q$:** $Q$ has nonnegative integer coefficients.
3. **Face counts:** $P(1) = m^2$ and $Q(1) = n^2$.
4. **Sum-preservation:** $P\cdot Q = S_{m^2}\cdot S_{n^2}$.

A *counterexample* is any admissible $(p, q, m, n)$ for which $P$ or $Q$ has a
negative coefficient (the other conditions being forced once divisibility holds).

**Remarks on the hypotheses.**

- $pq \mid m$ guarantees $pq \mid m^2$, hence $pq$ is a divisor of $m^2$, and since
  $\Phi_{pq}$ appears in the factorization $S_{m^2} = x\prod_{d\mid m^2,\,d>1}\Phi_d$
  precisely when $pq \mid m^2$, divisibility $\Phi_{pq}\mid S_{m^2}$ is automatic.
- The product identity (condition 4) is a formal consequence of conditions 1 and 2:
  $P\cdot Q = (S_{m^2}/\Phi_{pq})\cdot(S_{n^2}\Phi_{pq}) = S_{m^2}\cdot S_{n^2}$.
  The substantive content of the conjecture is therefore *nonnegativity* of the
  quotient $P$, since $Q = S_{n^2}\Phi_{pq}$ and the well-known nonnegativity
  behavior of $\Phi_{pq}\cdot S_{n^2}$ is governed by the threshold
  $n^2 \ge (p-1)(q-1)+1 = \deg\Phi_{pq} + 1$.
- The face counts follow by evaluation at $x=1$ using $S_N(1) = N$ and
  $\Phi_{pq}(1) = 1$ (a standard fact for cyclotomic polynomials of non-prime-power
  index): $P(1) = S_{m^2}(1)/\Phi_{pq}(1) = m^2$ and
  $Q(1) = S_{n^2}(1)\,\Phi_{pq}(1) = n^2$.

The conjecture asserts that the threshold $n^2 \ge (p-1)(q-1)+1$ is exactly what is
needed for the cancellations in $\Phi_{pq}\cdot S_{n^2}$ and the division
$S_{m^2}/\Phi_{pq}$ to leave no negative residue.

---

## 4. The Verified Base Case: $p=2,\ q=3,\ m=6,\ n=2$

Here $pq = 6 = m$ (so trivially $6 \mid 6$), $m^2 = 36$, $n = 2$, $n^2 = 4$, and
$(p-1)(q-1)+1 = 1\cdot 2 + 1 = 3 \le 4 = n^2$, so the instance is admissible. The
transferred atom is $\Phi_6 = x^2 - x + 1$.

### 4.1 The quotient identity

**Theorem 1 (Quotient identity, `phi6_mul_P36`).**
$$\Phi_6(x)\cdot P_{36}(x) = S_{36}(x),$$
where $P_{36} = \sum_{j=0}^{5}\mathrm{block}(j)$ and
$\mathrm{block}(j) = x^{6j+1} + 2x^{6j+2} + 2x^{6j+3} + x^{6j+4}$.

*Proof sketch.* The proof reduces to a single *local telescoping identity* for the
fixed degree-$4$ pattern $w(x) = x + 2x^2 + 2x^3 + x^4$:
$$\Phi_6(x)\cdot w(x) = (x^2 - x + 1)(x + 2x^2 + 2x^3 + x^4) = x + x^2 + x^3 + x^4 + x^5 + x^6. \tag{$\star$}$$
Expanding $(\star)$ termwise, the contributions of $x^2\cdot w$, $-x\cdot w$, and
$+1\cdot w$ overlap so that each coefficient of $x^1,\dots,x^6$ collapses to exactly
$1$; the weights $1,2,2,1$ are precisely the inverse image of a flat run of six
under multiplication by $\Phi_6$. Since $\mathrm{block}(j) = x^{6j}\cdot w(x)$, the
identity $(\star)$ shifts to
$$\Phi_6\cdot\mathrm{block}(j) = x^{6j+1} + x^{6j+2} + \dots + x^{6j+6}.$$
Summing over $j = 0,1,\dots,5$ and using linearity,
$$\Phi_6\cdot P_{36} = \sum_{j=0}^{5}\big(x^{6j+1} + \dots + x^{6j+6}\big) = \sum_{i=1}^{36} x^i = S_{36},$$
because the six shifted runs of six tile the exponents $1,\dots,36$ with no gaps or
overlaps. Formally the computation is a finite polynomial expansion verified by
the ring axioms. $\qquad\blacksquare$

**Corollary (Divisibility and nonnegativity of $P_{36}$).** $\Phi_6 \mid S_{36}$
with quotient $P_{36}$, and $P_{36}$ has nonnegative integer coefficients (each
coefficient is $0$, $1$, or $2$ by construction in $\mathbb{N}[x]$).

### 4.2 The product (transfer) identity

**Theorem 2 (Transferred small die, `Q4_eq_phi6_mul_S4`).**
$$Q_4(x) = \Phi_6(x)\cdot S_4(x) = x + x^3 + x^4 + x^6.$$

*Proof sketch.* Direct expansion:
$$(x^2 - x + 1)(x + x^2 + x^3 + x^4).$$
Grouping by the three summands of $\Phi_6$ gives
$$\underbrace{(x^3+x^4+x^5+x^6)}_{x^2\cdot S_4} - \underbrace{(x^2+x^3+x^4+x^5)}_{x\cdot S_4} + \underbrace{(x+x^2+x^3+x^4)}_{1\cdot S_4}.$$
Collecting coefficients: $x^1\colon 1$; $x^2\colon -1+1 = 0$; $x^3\colon 1-1+1 = 1$;
$x^4\colon 1-1+1 = 1$; $x^5\colon 1-1 = 0$; $x^6\colon 1$. Hence
$Q_4 = x + x^3 + x^4 + x^6$, with all coefficients in $\{0,1\}$. $\qquad\blacksquare$

In die language, $Q_4$ is the $4$-sided die with faces $\{1, 3, 4, 6\}$.

### 4.3 Validity of the nonstandard pair

**Proposition 1 (Face counts and nonnegativity).**
$$P_{36}(1) = 36, \qquad Q_4(1) = 4,$$
and both $P_{36}$ and $Q_4$ have nonnegative integer coefficients.

*Proof sketch.* Each block satisfies $\mathrm{block}(j)|_{x=1} = 1+2+2+1 = 6$, and
there are six blocks, so $P_{36}(1) = 6\cdot 6 = 36$. For $Q_4$,
$Q_4(1) = 1+0+1+1+0+1 = 4$ from the explicit expansion in Theorem 2. Nonnegativity
of $P_{36}$ is immediate from its $\mathbb{N}[x]$ construction (coefficients $1$ or
$2$); nonnegativity of $Q_4$ is read off Theorem 2 (coefficients $0$ or $1$).
$\qquad\blacksquare$

**Corollary 1 (Sum-preservation, the transfer).**
$$P_{36}(x)\cdot Q_4(x) = S_{36}(x)\cdot S_4(x).$$

*Proof sketch.* Combine the two theorems:
$$P_{36}\cdot Q_4 = P_{36}\cdot(\Phi_6\cdot S_4) = (\Phi_6\cdot P_{36})\cdot S_4 = S_{36}\cdot S_4,$$
using commutativity of multiplication and Theorem 1. $\qquad\blacksquare$

**Theorem 3 (Verified base case of the conjecture).** The quadruple
$(p,q,m,n) = (2,3,6,2)$ is admissible, and the pair $(P_{36}, Q_4)$ satisfies all
four conditions of the semiprime cyclotomic transfer conjecture. Moreover the pair
is genuinely nonstandard: $(P_{36}, Q_4) \neq (S_{36}, S_4)$, witnessed for instance
by the coefficient comparison $[x^5]\,P_{36} = 0$ while $[x^5]\,S_{36} = 1$ (and
$[x^2]\,Q_4 = 0$ while $[x^2]\,S_4 = 1$).

*Proof sketch.* Admissibility was checked above. Conditions 1–3 are Corollary to
Theorem 1, Theorem 2, and Proposition 1; condition 4 is Corollary 1.
Nonstandardness follows from any single distinguishing coefficient: $P_{36}$ omits
the exponent $5$ (its block pattern covers exponents $\equiv 1,2,3,4 \pmod 6$),
whereas $S_{36}$ has every exponent $1,\dots,36$. $\qquad\blacksquare$

---

## 5. Algorithm: Block Decomposition of $S_{6r}/\Phi_6$

The proof of Theorem 1 is constructive and yields an algorithm to express
$S_{6r}/\Phi_6$ for any $r$ (with the base case $r = 6$ giving $S_{36}$). The key
is the local telescoping identity $(\star)$: $\Phi_6$ sends the weight pattern
$1,2,2,1$ to a flat run of six.

**Algorithm (Cyclotomic block quotient).**

```
Input:  positive integer r
Output: coefficient list of P = S_{6r} / Phi_6  (length 6r - 1)

1. Initialize P as the zero polynomial of degree 6r - 2.
2. for j = 0, 1, ..., r - 1:
3.     P[6j + 1] += 1
4.     P[6j + 2] += 2
5.     P[6j + 3] += 2
6.     P[6j + 4] += 1
7. return P
```

**Correctness.** By the shift of $(\star)$, $\Phi_6\cdot\mathrm{block}(j)$ equals
the consecutive run $x^{6j+1}+\dots+x^{6j+6}$. Summing over $0 \le j < r$ tiles the
exponents $1,\dots,6r$, so $\Phi_6\cdot P = S_{6r}$, i.e. $P = S_{6r}/\Phi_6$.

**Complexity.** The algorithm performs $4r$ coefficient updates and allocates a
length-$(6r-1)$ array, so it runs in $O(r)$ time and $O(r)$ space — linear in the
size of the output. By contrast, generic polynomial division of $S_{6r}$ by
$\Phi_6$ costs $O(r)$ as well but with larger constants and intermediate sign
bookkeeping; the closed-form block formula avoids all cancellation.

---

## 6. Numerical Demonstrations

We summarize the concrete data verifying the base case (all checked by direct
polynomial arithmetic):

- $\Phi_6 = x^2 - x + 1$.
- $P_{36}$ has the repeating coefficient pattern $1,2,2,1,0,0$ over each block of
  six exponents: coefficients $[x^1..x^{36}] = (1,2,2,1,0,0,\ 1,2,2,1,0,0,\ \dots)$.
- $\Phi_6\cdot P_{36} = x + x^2 + \dots + x^{36} = S_{36}$. ✓ (Theorem 1)
- $Q_4 = \Phi_6\cdot S_4 = x + x^3 + x^4 + x^6$, faces $\{1,3,4,6\}$. ✓ (Theorem 2)
- $P_{36}(1) = 36$, $Q_4(1) = 4$. ✓ (Proposition 1)
- $P_{36}\cdot Q_4 = S_{36}\cdot S_4$ as degree-$40$ polynomials. ✓ (Corollary 1)

### 6.1 The explicit coefficient tables

For completeness we record the two dice as coefficient sequences. The big die
$P_{36}$, listing the coefficient of $x^k$ for $k = 1, \dots, 36$, is

$$(1,2,2,1,0,0,\ 1,2,2,1,0,0,\ 1,2,2,1,0,0,\ 1,2,2,1,0,0,\ 1,2,2,1,0,0,\ 1,2,2,1,0,0),$$

i.e. faces $\{1,2,2,3,3,4\}$ shifted by $0, 6, 12, 18, 24, 30$, so the realized
face multiset is

$$\{1,2,2,3,3,4,\ 7,8,8,9,9,10,\ 13,14,14,15,15,16,\ \dots,\ 31,32,32,33,33,34\}.$$

The small die $Q_4$ has coefficient sequence $(1,0,1,1,0,1)$ for $k = 1,\dots,6$,
i.e. faces $\{1,3,4,6\}$. Multiplying the two generating polynomials and reading
the coefficient of $x^s$ gives the number of ordered outcomes summing to $s$; this
sequence is symmetric about $s = 21$ and rises to a plateau of $4$ between
$s = 5$ and $s = 37$, exactly matching the convolution of a uniform $\{1,\dots,36\}$
with a uniform $\{1,2,3,4\}$.

### 6.2 Distributional sanity check

As a probabilistic sanity check, the sum distribution of the standard pair
$(S_{36}, S_4)$ and the nonstandard pair $(P_{36}, Q_4)$ agree coefficient-by-
coefficient on $x^2,\dots,x^{40}$; the total number of equally-likely outcomes is
$36\times 4 = 144$ in both cases. The companion program `demo.py` reproduces every
one of these checks from scratch in exact integer arithmetic.

---

## 7. Applications

- **Recreational and educational mathematics.** The construction gives an explicit,
  hand-checkable family of "Sicherman-like" dice in the square-sided regime,
  suitable for teaching generating functions and cyclotomic factorization.
- **Combinatorial design.** Sum-equivalent multisets underlie problems in
  tiling, partition identities, and the design of fair randomization devices with
  unusual face labels.
- **Cyclotomic coefficient theory.** The semiprime transfer threshold
  $n^2 \ge (p-1)(q-1)+1 = \deg\Phi_{pq}+1$ ties the validity of the construction to
  the *nonnegativity* and coefficient bounds of $\Phi_{pq}\cdot S_N$, connecting
  recreational dice to the active study of cyclotomic and "flat" cyclotomic
  coefficients.

---

## 8. Discussion and Future Directions

The base case is deliberately minimal but structurally complete: it isolates the
one-block telescoping computation that any generalization reuses. The natural next
steps, in increasing order of ambition, are:

1. **Generalize the quotient identity from $36$ to any multiple $6r$.** The same
   block formula should give $\Phi_6\cdot(\sum_{j<r}\mathrm{block}(j)) = S_{6r}$ for
   every $r$, since each block is the shift by $6j$ of the fixed degree-$4$ pattern
   $1,2,2,1$ and $\Phi_6$ telescopes that pattern to six consecutive monomials. The
   base case already isolates the one-block computation, so the generalization is a
   clean `range`-induction with no new algebraic content.

2. **Prove the transfer is genuinely new (Sicherman-style inequivalence).** The
   product identity $P_{36}\cdot Q_4 = S_{36}\cdot S_4$ does not by itself record
   that $(P_{36}, Q_4)$ differs from the trivial factorization $(S_{36}, S_4)$. The
   two are distinguished by their cyclotomic-factor multiset: $P_{36}$ carries the
   factor $\Phi_6$ that $S_{36}$ keeps and $S_4$ lacks, so a single coefficient
   comparison (e.g. $[x^5]P_{36} = 0$ while $[x^5]S_{36} = 1$) certifies
   inequivalence and upgrades the artifact from "a valid factorization" to "a
   nontrivial transfer".

3. **Catalogue the admissible $(p,q)$ substitutions beyond $(2,3)$.** Replace
   $\Phi_6 = \Phi_{2\cdot3}$ by other $\Phi_{pq}$ for small distinct primes — e.g.
   $\Phi_{10}, \Phi_{15}, \Phi_{21}$ — and seek the analogous block decomposition.
   Because $\Phi_{pq}$ divides $S_{pq\cdot k}$ for suitable $k$ (as $S_N$ collects
   exactly the cyclotomic factors $\Phi_d$ with $d \mid (N+1)$, $d > 1$), the block
   pattern is governed by the explicit coefficient sequence of $\Phi_{pq}$ rather
   than by anything special to $6$. The present template ports almost verbatim to
   each new $(p, q)$, turning a research question into a finite enumeration of
   mechanical cases.

4. **Replace the hand-built blocks by a reusable $S$-divisibility API.** The
   recurring fact is purely structural: $\Phi_d$ divides $S_N$ whenever
   $d \mid (N+1)$ and $d \neq 1$, with an explicit nonnegative quotient. Capturing
   this divisibility and nonnegativity once, as a general result, would replace the
   per-case `ring` expansions and supply the load-bearing lemma for the full
   semiprime conjecture.

---

## 9. Conclusion

We have stated the semiprime cyclotomic transfer conjecture and completely
established its cornerstone case. The transfer of the atom $\Phi_6 = x^2 - x + 1$
from a $36$-sided die to a $4$-sided die yields the nonstandard pair
$P_{36} = S_{36}/\Phi_6$ (block pattern $1,2,2,1$ repeated) and
$Q_4 = \Phi_6\cdot S_4 = x + x^3 + x^4 + x^6$ (faces $\{1,3,4,6\}$), with
$P_{36}\cdot Q_4 = S_{36}\cdot S_4$, correct face counts, and nonnegative
coefficients throughout. The decisive ingredient is the local telescoping identity
$\Phi_6\cdot(x+2x^2+2x^3+x^4) = x+x^2+\dots+x^6$, which both proves the quotient
identity and supplies a linear-time algorithm for the block decomposition. The base
case is the first verified instance of a broad family connecting the arithmetic of
cyclotomic atoms to the combinatorics of fair chance.
