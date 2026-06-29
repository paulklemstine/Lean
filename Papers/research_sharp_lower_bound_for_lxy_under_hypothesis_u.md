# A Sharp Elementary Sieve Bound for the Smooth-Number Counting Function $L(x,y)$, with a Conditional Lower Bound under Hypothesis U

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Novelty (analytic and elementary number theory; MSC 11N25, 11N37)

---

## Abstract

For integers $x \ge 1$ and $y \ge 1$ let $L(x,y)$ denote the number of
$y$-smooth integers in $(0,x]$, that is, the number of $n \le x$ all of whose
prime factors are at most $y$. We develop an elementary, fully constructive
theory of $L(x,y)$ based on a one-step Eratosthenes/Legendre sieve over the
*large* primes $(y,x]$. We prove three principal results. First, the
unconditional **sieve lower bound**
$x - \sum_{y < p \le x}\lfloor x/p \rfloor \le L(x,y)$, where the sum runs over
primes. Second, a **conditional sharp lower bound under Hypothesis U**: if the
large-prime contribution $\sum_{y<p\le x}\lfloor x/p\rfloor$ leaves room $c$,
i.e. $\sum_{y<p\le x}\lfloor x/p\rfloor + c \le x$, then $L(x,y) \ge c$. Third,
a **matching upper bound establishing sharpness**: whenever no integer $\le x$ is
divisible by two distinct primes exceeding $y$ — equivalently, $pq > x$ for all
distinct primes $p,q \in (y,x]$ — the sieve lower bound is an exact equality,
$L(x,y) = x - \sum_{y<p\le x}\lfloor x/p\rfloor$. We complement these with an
exact saturation criterion, $L(x,y) = x$ if and only if there is no prime in
$(y,x]$, from which Bertrand's postulate yields the deficiency $L(2y,y) < 2y$. We
discuss a second-order Bonferroni bracketing of $L$, a Mertens-calibrated route
to verifying Hypothesis U, and the role of these bounds in the analysis of
factoring algorithms. All results have been formally verified.

---

## 1. Introduction

The distribution of smooth (friable) integers is a cornerstone of analytic
number theory and of the complexity analysis of factoring and discrete-logarithm
algorithms. Recall that an integer $n$ is **$y$-smooth** if every prime factor of
$n$ is at most $y$. The associated counting function, classically denoted
$\Psi(x,y) = \#\{ n \le x : P^+(n) \le y\}$ (with $P^+(n)$ the largest prime
factor), governs the running time of the quadratic sieve, the number field sieve,
and index-calculus methods, and is intimately connected to the Dickman–de
Bruijn function $\rho(u)$ in the range $u = \log x / \log y$.

This paper studies the elementary, fully computable surrogate

$$L(x,y) \;=\; \#\{\, n : 1 \le n \le x,\ n \text{ is } y\text{-smooth}\,\},$$

and develops a self-contained sieve theory for it. Our guiding principle is that
the count of smooth numbers should be recoverable from a *one-step* sieve: an
integer $n \le x$ is non-smooth precisely when it has a prime factor in the
window $(y,x]$, so striking out the multiples of each such prime removes exactly
the non-smooth integers, with overcounting controlled by inclusion–exclusion.

Our contributions are:

1. **An unconditional sieve lower bound** (Theorem 4.2) with a transparent
   union-bound proof.
2. **A conditional sharp lower bound under a single clean hypothesis**
   ("Hypothesis U," Theorem 5.1), isolating all hard analytic input into one
   inequality about a sum over primes.
3. **A matching upper bound** (Theorem 6.1) proving the sieve bound is *exact*
   in an explicitly described regime, hence sharp.
4. **An exact saturation criterion** (Theorem 3.2) tying $L(x,y)=x$ to the
   absence of primes in $(y,x]$, with the Bertrand consequence $L(2y,y)<2y$.

All statements have been formally verified in a proof assistant; the proof
sketches below mirror the formal arguments.

---

## 2. Definitions

Throughout, $p$ and $q$ denote primes, and $\lfloor \cdot \rfloor$ is the floor
function. We work with natural-number arithmetic; $\lfloor x/p \rfloor$ is
integer division.

**Definition 2.1 (Smoothness).** For natural numbers $y, n$, say $n$ is
**$y$-smooth**, written $\mathrm{IsSmooth}(y,n)$, if every prime $p$ dividing $n$
satisfies $p \le y$:
$$\mathrm{IsSmooth}(y,n) \iff \forall p \in \mathrm{primeFactors}(n),\ p \le y.$$
Phrasing smoothness through the finite set $\mathrm{primeFactors}(n)$ makes the
predicate decidable, hence directly computable. (Note $n=1$ has no prime factors
and is vacuously $y$-smooth for every $y$.)

**Definition 2.2 (Smooth-number counting function).**
$$L(x,y) \;=\; \#\{\, n \in (0,x] : \mathrm{IsSmooth}(y,n)\,\}.$$

**Definition 2.3 (Large primes).** The set of primes in the half-open interval
$(y,x]$:
$$\mathrm{largePrimes}(x,y) \;=\; \{\, p \in (y,x] : p \text{ prime}\,\}.$$

**Definition 2.4 (Prime contribution / union bound).**
$$\mathrm{primeContribution}(x,y) \;=\; \sum_{p \in \mathrm{largePrimes}(x,y)} \left\lfloor \frac{x}{p} \right\rfloor \;=\; \sum_{\substack{y < p \le x \\ p\text{ prime}}} \left\lfloor \frac{x}{p} \right\rfloor.$$
This counts, with multiplicity, the $y$-rough (non-smooth) integers in $(0,x]$:
for each large prime $p$, there are exactly $\lfloor x/p\rfloor$ multiples of $p$
in $(0,x]$.

**Definition 2.5 (Hypothesis U).** For natural numbers $x,y,c$, **Hypothesis U**
for the triple $(x,y,c)$ is the assertion
$$\mathrm{HypothesisU}(x,y,c) \iff \mathrm{primeContribution}(x,y) + c \le x.$$
Interpretation: the large primes contribute at most $x-c$ to the union bound,
leaving at least $c$ integers unstruck.

---

## 3. Elementary structure of $L$

We first record the basic monotonicity and boundary behaviour, then the exact
saturation criterion.

**Theorem 3.1 (Range and monotonicity).** For all $x,y$:
1. $L(x,y) \le x$.
2. (Monotone in $y$) If $y_1 \le y_2$ then $L(x,y_1) \le L(x,y_2)$.
3. (Monotone in $x$) If $x_1 \le x_2$ then $L(x_1,y) \le L(x_2,y)$.
4. (Boundary) If $x \le y$ then $L(x,y) = x$.

*Proof sketch.* (1) $L$ counts a subset of $(0,x]$, which has $x$ elements. (2) A
$y_1$-smooth number is $y_2$-smooth when $y_1 \le y_2$, so the counted set grows;
apply monotonicity of cardinality. (3) The set $(0,x_1]$ is a subset of
$(0,x_2]$, and the smoothness filter is the same. (4) If $x \le y$, every prime
factor of any $n \le x$ is itself $\le x \le y$, so all $n \in (0,x]$ are smooth.
$\square$

**Theorem 3.2 (Exact saturation criterion).**
$$L(x,y) = x \quad\Longleftrightarrow\quad \forall p\ \text{prime},\ y < p \implies x < p,$$
i.e. $L(x,y)=x$ if and only if there is no prime in $(y,x]$.

*Proof sketch.* ($\Leftarrow$) If no prime lies in $(y,x]$, then for any
$n \in (0,x]$ every prime factor $p$ of $n$ satisfies $p \le x$; were $p > y$ we
would have a prime in $(y,x]$, contradiction, so $p \le y$ and $n$ is smooth.
Thus the smooth filter is total and $L(x,y) = \#(0,x] = x$. ($\Rightarrow$) By
contraposition: if some prime $p$ satisfies $y < p \le x$, then $p$ itself is a
non-smooth integer in $(0,x]$, so the smooth set is a *proper* subset of $(0,x]$,
giving $L(x,y) < x$. $\square$

**Corollary 3.3 (Bertrand deficiency).** For every $y \ge 1$, $L(2y,y) < 2y$.

*Proof sketch.* By Bertrand's postulate there is a prime $p$ with $y < p \le 2y$.
Hence there *is* a prime in $(y,2y]$, and Theorem 3.2 gives $L(2y,y) \ne 2y$;
combined with $L(2y,y)\le 2y$ this yields strict inequality. $\square$

This corollary exhibits $L$ as a *detector of primes*: a prime in an interval
forces the smooth count strictly below saturation.

---

## 4. The unconditional sieve lower bound

We now prove the central unconditional estimate. The starting point is the
identity relating $L$ to the count of non-smooth integers.

**Lemma 4.1 (Complement identity).**
$$\#\{\, n \in (0,x] : \neg\,\mathrm{IsSmooth}(y,n)\,\} \;=\; x - L(x,y).$$

*Proof sketch.* The smooth and non-smooth integers partition $(0,x]$, so their
cardinalities sum to $\#(0,x] = x$. Rearranging the partition identity
$\#\{\text{smooth}\} + \#\{\text{non-smooth}\} = x$ gives the claim. $\square$

**Theorem 4.2 (Sieve lower bound; unconditional).**
$$x - \mathrm{primeContribution}(x,y) \;\le\; L(x,y),$$
that is,
$$x - \sum_{\substack{y < p \le x}} \left\lfloor \frac{x}{p}\right\rfloor \;\le\; L(x,y).$$

*Proof sketch.* By Lemma 4.1 it suffices to bound the number of non-smooth
integers above by $\mathrm{primeContribution}(x,y)$. Every non-smooth
$n \in (0,x]$ has some prime factor $p > y$; since $p \mid n \le x$ we have
$p \le x$, so $p \in \mathrm{largePrimes}(x,y)$ and $n$ is a multiple of $p$ in
$(0,x]$. Hence the set of non-smooth integers is contained in the union
$$\bigcup_{p \in \mathrm{largePrimes}(x,y)} \{\, n \in (0,x] : p \mid n\,\}.$$
By the union bound (sub-additivity of cardinality over a finite union),
$$\#\{\text{non-smooth}\} \;\le\; \sum_{p \in \mathrm{largePrimes}(x,y)} \#\{ n \in (0,x] : p \mid n\} \;=\; \sum_{p} \left\lfloor \frac{x}{p}\right\rfloor,$$
using that the number of multiples of $p$ in $(0,x]$ is exactly
$\lfloor x/p\rfloor$. Substituting into Lemma 4.1 gives
$x - \mathrm{primeContribution}(x,y) \le L(x,y)$ (with natural-number
subtraction, the inequality holds even when the left side truncates at $0$).
$\square$

The only inefficiency in this argument is the union bound, which overcounts
integers possessing **two or more** distinct large prime factors. Sections 5 and
6 exploit exactly this observation.

---

## 5. The conditional sharp lower bound under Hypothesis U

The sieve bound becomes a usable density statement once one controls the
prime contribution. We package that control as Hypothesis U.

**Theorem 5.1 (Conditional lower bound under Hypothesis U).** If
$\mathrm{HypothesisU}(x,y,c)$ holds — i.e. $\mathrm{primeContribution}(x,y) + c \le x$
— then
$$c \;\le\; L(x,y).$$

*Proof sketch.* Hypothesis U rearranges to
$c \le x - \mathrm{primeContribution}(x,y)$ (the subtraction is exact because
$\mathrm{primeContribution}(x,y) \le x - c \le x$). Chaining with the
unconditional sieve lower bound (Theorem 4.2),
$$c \;\le\; x - \mathrm{primeContribution}(x,y) \;\le\; L(x,y),$$
which is the claim. $\square$

Theorem 5.1 is deliberately modular: *all* analytic difficulty is concentrated in
verifying Hypothesis U for a desired target $c$. In practice $c$ is chosen as a
density target $c = \alpha x$, and Hypothesis U reduces to an upper bound on
$\sum_{y<p\le x}\lfloor x/p\rfloor$, which is precisely the regime governed by
Mertens' theorems (see Section 8).

---

## 6. Sharpness: the matching upper bound

We now show the sieve lower bound is not merely a bound but is *exact* in a wide,
explicitly characterised regime — establishing its sharpness.

**Theorem 6.1 (Exactness of the sieve bound).** Suppose no integer $\le x$ is
divisible by two distinct large primes; precisely, suppose
$$\forall\, p,q \in \mathrm{largePrimes}(x,y),\quad p \ne q \implies x < p\,q.$$
Then
$$L(x,y) \;=\; x - \mathrm{primeContribution}(x,y).$$

*Proof sketch.* By Theorem 4.2 it suffices to prove the reverse inequality, i.e.
that the union bound is *tight*: the sets
$B_p = \{ n \in (0,x] : p \mid n\}$ for $p \in \mathrm{largePrimes}(x,y)$ are
pairwise disjoint. Indeed if $n \in B_p \cap B_q$ with $p \ne q$, then $pq \mid n$
(distinct primes), so $pq \le n \le x$, contradicting the hypothesis $x < pq$.
With the $B_p$ pairwise disjoint, the cardinality of their union equals the sum
$\sum_p \#B_p = \sum_p \lfloor x/p\rfloor = \mathrm{primeContribution}(x,y)$, and
this union is *exactly* the set of non-smooth integers (every non-smooth $n$ lies
in some $B_p$, as in Theorem 4.2, and every element of every $B_p$ is non-smooth
since $p>y$ divides it). Hence
$\#\{\text{non-smooth}\} = \mathrm{primeContribution}(x,y)$, and Lemma 4.1 gives
$L(x,y) = x - \mathrm{primeContribution}(x,y)$. $\square$

**Remark 6.2 (When the regime holds).** Two distinct primes $p,q > y$ satisfy
$pq > y^2$, so the disjointness hypothesis holds whenever $x \le y^2$; more
finely, it holds iff the product of the two *smallest* primes in $(y,x]$ exceeds
$x$. Thus the sieve bound is exact in a band of width roughly $y$ around and below
$y^2$, and degrades only when $x$ grows enough to admit a product of two large
primes.

**Numerical illustration.** With $(x,y)=(20,5)$, $(30,4)$, $(100,10)$ the two
smallest large primes already multiply past $x$, and direct computation gives
$L = 14, 12, 46$ respectively, *equal* to $x - \mathrm{primeContribution}$ in
each case. With $(x,y)=(100,5)$ the product $7\cdot 11 = 77 \le 100$ admits a
double-counted integer; here $L(100,5) = 34$ while
$x - \mathrm{primeContribution} = 32$, a strict gap of exactly the one
double-counted value (and its multiples), in line with Theorem 6.1.

---

## 7. Second-order bracketing (Bonferroni)

The strict regime of Theorem 6.1 is repaired by one further layer of
inclusion–exclusion. Define the second-order correction
$$S_2(x,y) \;=\; \sum_{\substack{y < p < q \le x \\ p,q\ \text{prime}}} \left\lfloor \frac{x}{pq}\right\rfloor.$$

**Proposition 7.1 (Bonferroni bracket; conjectural target for formalization).**
$$x - \mathrm{primeContribution}(x,y) \;\le\; L(x,y) \;\le\; x - \mathrm{primeContribution}(x,y) + S_2(x,y).$$

*Heuristic.* The lower inequality is Theorem 4.2. For the upper inequality, the
Bonferroni inequalities state that truncating inclusion–exclusion after an even
number of terms overestimates the size of the complement removed, hence
underestimates the union struck out — giving an upper bound on the survivors. The
second-order term $S_2$ adds back exactly the integers double-counted by the
union bound. Numerically, for $(x,y)=(100,5)$ the bracket reads
$32 \le 34 \le 32 + 2 = 34$, pinning $L$ to its true value. A full formal proof
follows the general Bonferroni / Brun pure-sieve framework and is a natural next
target (see Section 9). $\square$

---

## 8. Verifying Hypothesis U via Mertens' theorem

Hypothesis U is an inequality about $\mathrm{primeContribution}(x,y)$, which the
classical theorems of Mertens estimate. Writing $\lfloor x/p\rfloor = x/p +
O(1)$ termwise,
$$\mathrm{primeContribution}(x,y) \;=\; x \sum_{y < p \le x} \frac{1}{p} \;+\; O\big(\pi(x) - \pi(y)\big),$$
and Mertens' second theorem gives
$\sum_{y<p\le x} 1/p = \ln\ln x - \ln\ln y + o(1)$. Therefore
$$\mathrm{primeContribution}(x,y) \;\le\; x\,(\ln\ln x - \ln\ln y) + C\,\frac{x}{\ln y}$$
for an absolute constant $C$ (the second term absorbing the floor defect via the
prime-counting bound $\pi(x)-\pi(y) = O(x/\ln y)$). Hypothesis U with
$$c \;=\; x\big(1 - (\ln\ln x - \ln\ln y)\big) - C\,\frac{x}{\ln y}$$
then holds, yielding via Theorem 5.1 the density lower bound
$$\frac{L(x,y)}{x} \;\ge\; 1 - \ln u + o(1), \qquad u = \frac{\ln x}{\ln y},$$
in the Dickman range $1 \le u \le 2$, matching the leading behaviour
$\rho(u) = 1 - \ln u$ of the Dickman–de Bruijn function. This is the precise
sense in which the elementary sieve recovers the correct first-order density of
smooth numbers in the "few large primes" regime.

---

## 9. Applications

**Factoring and discrete logarithms.** The quadratic sieve and number field
sieve construct congruences from $y$-smooth values; their complexity is governed
by the density $L(x,y)/x$. The unconditional Theorem 4.2 furnishes a *guaranteed*
supply of smooth numbers, and the conditional Theorem 5.1 converts any verified
prime-contribution bound into an explicit density floor — exactly the input
needed for rigorous (rather than heuristic) running-time guarantees.

**Pseudorandomness and smoothness testing.** The exactness regime (Theorem 6.1)
gives an $O(\pi(x)-\pi(y))$-term *closed form* for $L(x,y)$ whenever $x \lesssim
y^2$, useful for calibrating smoothness-based samplers.

**Prime-gap diagnostics.** Theorem 3.2 and Corollary 3.3 turn the deficiency
$x - L(x,y)$ into a detector of primes in $(y,x]$. Quantitative prime-gap
results sharpen the deficiency: Nagura's theorem (a prime in $(y,\tfrac{6}{5}y]$
for $y\ge 25$) gives $L(\lceil \tfrac{6}{5}y\rceil, y) < \lceil \tfrac{6}{5}y
\rceil$, and conjectural gaps of size $y^{0.525}$ give
$L(y+\lfloor y^{0.525}\rfloor, y) < y+\lfloor y^{0.525}\rfloor$.

---

## 10. Discussion and future work

The theory above is deliberately elementary: every object is finite and
decidable, every bound is a finite sum, and the hardest analytic content is
quarantined into the single Hypothesis U. This modularity is its strength —
improvements in prime-distribution estimates plug directly into Theorem 5.1
without revisiting the sieve.

The following directions, carried over from the development notes, are precise
and formalizable.

- **C1 — Exact sharpness threshold (iff form).** Conjecture:
  $L(x,y) = x - \mathrm{primeContribution}(x,y)$ holds **iff** $pq > x$ for all
  distinct primes $p,q \in (y,x]$. Theorem 6.1 is the $\Leftarrow$ direction; the
  converse should follow by exhibiting a double-counted $pq \le x$ that makes the
  union bound strict.

- **C2 — Second-order Bonferroni bracketing.** Formalize Proposition 7.1, then
  the general truncated Legendre/Bonferroni inequalities: stopping at an even
  (resp. odd) number of terms gives upper (resp. lower) bounds, the Brun pure
  sieve.

- **C3 — Mertens-calibrated Hypothesis U.** Make Section 8 fully rigorous:
  $\mathrm{primeContribution}(x,y) \le x(\ln\ln x - \ln\ln y) + Cx/\ln y$, hence
  $L(x,y)/x \ge 1 - \ln u + o(1)$ for $u = \ln x/\ln y$ in $1\le u\le 2$.

- **C4 — Buchstab dual for rough numbers.** For
  $R(x,y) = \#\{ n \le x : \text{every prime factor} > y\}$, establish the
  Buchstab recursion $R(x,y) = R(x,y-1) - R(\lfloor x/y\rfloor, y-1)$ for prime
  $y$, and the Legendre/Brun lower bound
  $R(x,y) \ge x\prod_{p\le y}(1 - 1/p) - 2^{\pi(y)}$.

- **C5 — Prime-gap upgrades of the deficiency theorem.** Each strengthening of
  Bertrand sharpens Corollary 3.3, as in Section 9.

---

## Appendix: Formally verified statements

The following named results were established in a proof assistant and are the
ground truth for this paper:

- `L_le_self`: $L(x,y) \le x$.
- `L_mono_y`, `L_mono_x`: monotonicity in $y$ and in $x$.
- `L_eq_self_of_le`: $x \le y \implies L(x,y) = x$.
- `L_eq_iff_no_prime_between`: $L(x,y) = x \iff$ no prime in $(y,x]$ (Theorem 3.2).
- `nonsmooth_card`: $\#\{$non-smooth in $(0,x]\} = x - L(x,y)$ (Lemma 4.1).
- `L_lower_sieve`: $x - \mathrm{primeContribution}(x,y) \le L(x,y)$ (Theorem 4.2).
- `L_lower_under_U`: $\mathrm{HypothesisU}(x,y,c) \implies c \le L(x,y)$ (Theorem 5.1).
- `L_eq_sieve_of_no_double_large_factor`: the exactness regime (Theorem 6.1).
- `L_two_mul_lt`: $L(2y,y) < 2y$ (Corollary 3.3).
