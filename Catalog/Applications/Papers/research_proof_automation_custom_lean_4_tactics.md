# A Combinatorics–Number-Theory Bridge: From the Central Binomial Coefficient to Chebyshev-Type Prime Bounds

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Bridges (Combinatorics ⟷ Analytic Number Theory)

## Abstract

We present a fully formalized account of the classical bridge, due in this
elementary form to Paul Erdős, that derives a Chebyshev-type upper bound on the
product of primes from the arithmetic of the central binomial coefficient
$\binom{2n}{n}$. The development is organized as a chain of theorems that crosses
from enumerative combinatorics into analytic number theory. Its load-bearing
results are: (i) Legendre's formula in digit-sum form,
$(p-1)\,v_p(n!) = n - s_p(n)$; (ii) the induced digit-sum formula for the
valuation of the central binomial coefficient,
$(p-1)\,v_p\!\binom{2n}{n} = 2\,s_p(n) - s_p(2n)$; (iii) the exactness theorem
that every prime $p$ with $n < p \le 2n$ satisfies $v_p\!\binom{2n}{n} = 1$, and
hence $\prod_{n<p\le 2n} p \mid \binom{2n}{n}$; (iv) matching size bounds
$4^n \le (2n+1)\binom{2n}{n}$ and $\binom{2n}{n} \le 4^n/\sqrt{2n}$; and (v) the
destination theorem $\prod_{p\le n} p < 4^n$ for $n \ge 1$. We additionally
document and correct a false upper bound, $\binom{2n}{n} \le 4^n/(2\sqrt n)$,
which appears in the informal brief but fails already at $n=2$. The corrected
bound $\binom{2n}{n} \le 4^n/\sqrt{2n}$ is the one we prove and use. All results
have been mechanically verified.

**Keywords:** central binomial coefficient, Legendre's formula, $p$-adic
valuation, primorial, Chebyshev bound, Erdős, digit sum, prime distribution.

---

## 1. Introduction

The distribution of prime numbers is the central object of analytic number
theory. The Prime Number Theorem, $\pi(x) \sim x/\ln x$, is its crown jewel, but
it required nineteenth-century complex analysis to prove. Decades earlier,
Chebyshev established the weaker but already profound statement that there exist
positive constants $c_1, c_2$ with

$$c_1 \frac{x}{\ln x} \le \pi(x) \le c_2 \frac{x}{\ln x}$$

for all large $x$. The engine behind the upper half of Chebyshev's bound is a
purely *combinatorial* inequality controlling the **primorial**

$$n\# := \prod_{p \le n} p,$$

namely $n\# < 4^n$. Remarkably, this inequality can be proved without any
analysis at all: it follows from elementary divisibility properties of the
**central binomial coefficient** $\binom{2n}{n}$. This route was popularized by
Erdős, who discovered a version of it as a young man, and it remains a textbook
showcase of how combinatorics and number theory inform one another.

This paper records a complete, machine-checked formalization of that bridge. Our
contribution is threefold. First, we give a self-contained chain of theorems with
proof sketches, so that the entire argument can be followed from a single
document. Second, we make the *digit-sum* structure explicit at every step:
Legendre's formula and its consequence for $\binom{2n}{n}$ are stated and proved
in terms of base-$p$ digit sums $s_p(\cdot)$, which is both the cleanest form for
mechanization and the most transparent for human readers. Third, we correct a
quantitative error in the informal source material: the upper bound
$\binom{2n}{n} \le 4^n/(2\sqrt n)$ is false, and we replace it with the correct
$\binom{2n}{n} \le 4^n/\sqrt{2n}$.

### 1.1 Notation

Throughout, $p$ denotes a prime and $n$ a natural number.

- $v_p(m)$ is the **$p$-adic valuation** of $m$: the exponent of $p$ in the prime
  factorization of $m$. Formally $v_p(m) = m.\mathrm{factorization}(p)$.
- $s_p(m)$ is the **base-$p$ digit sum** of $m$: the sum of the digits of $m$
  written in base $p$.
- $\binom{2n}{n}$ is the **central binomial coefficient**, denoted in the
  formalization by `central_binom n`.
- $n\# = \prod_{p\le n} p$ is the **primorial**, denoted `prime_product_below n`.
- $\binom{a}{b}$ is the usual binomial coefficient $\frac{a!}{b!(a-b)!}$.

The two definitions agree with their Mathlib counterparts: `central_binom n`
equals `Nat.centralBinom n`, and `prime_product_below n` equals `primorial n`.

---

## 2. Definitions

**Definition 2.1 ($p$-adic valuation).** For natural numbers $n$ and a prime $p$,
$$v_p(n) := \text{(exponent of } p \text{ in the prime factorization of } n).$$
By convention $v_p(0) = 0$ in this representation. The valuation is completely
additive on nonzero arguments: $v_p(ab) = v_p(a) + v_p(b)$ for $a, b \ne 0$.

**Definition 2.2 (Central binomial coefficient).**
$$\binom{2n}{n} = \frac{(2n)!}{n!\,n!}.$$
Equivalently $\binom{2n}{n}$ is the largest entry in row $2n$ of Pascal's
triangle.

**Definition 2.3 (Base-$p$ digit sum).** Writing $n = \sum_{i\ge 0} d_i\,p^i$ with
$0 \le d_i < p$, the digit sum is $s_p(n) = \sum_i d_i$.

**Definition 2.4 (Primorial).**
$$n\# = \prod_{\substack{p \le n \\ p \text{ prime}}} p.$$

---

## 3. Main Results

We state the results in dependency order and give proof sketches. Full mechanical
proofs underlie each statement.

### 3.1 Legendre's formula (digit form)

**Theorem 3.1 (`legendre_factorial_digit`).** For a prime $p$ and any $n$,
$$(p-1)\,v_p(n!) = n - s_p(n).$$

*Proof sketch.* The exponent of $p$ in $n!$ is, by the classical counting
argument (de Polignac/Legendre),
$$v_p(n!) = \sum_{i\ge 1} \left\lfloor \frac{n}{p^i} \right\rfloor.$$
Writing $n = \sum_i d_i p^i$ and using
$\lfloor n/p^j \rfloor = \sum_{i\ge j} d_i p^{i-j}$, a telescoping computation
gives $\sum_{i\ge1}\lfloor n/p^i\rfloor = \frac{n - s_p(n)}{p-1}$, because each
digit $d_i$ contributes $d_i(p^{i-1}+\cdots+1) = d_i\frac{p^i-1}{p-1}$. Multiplying
by $p-1$ yields the stated identity. In the formalization this is obtained
directly from the library identity relating $v_p(n!)$ to the digit sum. $\square$

### 3.2 Valuation of the central binomial coefficient

**Theorem 3.2 (`legendre_central_binom_digit`).** For a prime $p$,
$$(p-1)\,v_p\!\left(\binom{2n}{n}\right) = s_p(n) + s_p(n) - s_p(2n).$$

*Proof sketch.* Start from the exact factorial identity
$$\binom{2n}{n}\cdot n!\cdot n! = (2n)!,$$
which holds because $\binom{2n}{n} = \frac{(2n)!}{n!(2n-n)!}$ and $2n-n=n$. Taking
$p$-adic valuations and using complete additivity,
$$v_p((2n)!) = v_p\!\binom{2n}{n} + 2\,v_p(n!).$$
Multiply through by $(p-1)$ and substitute Legendre's formula (Theorem 3.1) for
each factorial term:
$$(p-1)v_p\!\binom{2n}{n} = \bigl(2n - s_p(2n)\bigr) - 2\bigl(n - s_p(n)\bigr) = 2\,s_p(n) - s_p(2n).$$
Care is required with truncated natural-number subtraction; the formalization
manages this using $s_p(2n) \le 2n$ and $s_p(n) \le n$ to justify each step.
$\square$

**Theorem 3.3 (`vp_central_binom_div`, divided form).** For a prime $p$,
$$v_p\!\left(\binom{2n}{n}\right) = \frac{2\,s_p(n) - s_p(2n)}{p-1}.$$

*Proof sketch.* Divide Theorem 3.2 by $p-1 > 0$ (valid since $p \ge 2$). The
division is exact in $\mathbb{N}$ because the left side is $(p-1)$ times an
integer. $\square$

### 3.3 The exactness theorem

**Theorem 3.4 (`vp_central_binom_eq_one`).** Let $p$ be prime with $n < p \le 2n$.
Then
$$v_p\!\left(\binom{2n}{n}\right) = 1.$$

*Proof sketch.* Since $0 < n < p$, the number $n$ is a single base-$p$ digit, so
$s_p(n) = n$ (the digit list of $n$ in base $p$ is $[n]$; this is the auxiliary
lemma `digits_of_pos_lt`). Since $p \le 2n < 2p$, the number $2n$ has exactly two
base-$p$ digits: a leading $1$ (because $\lfloor 2n/p\rfloor = 1$) and remainder
$2n - p$ (because $2n \bmod p = 2n - p$). Hence $s_p(2n) = 1 + (2n - p)$.
Substituting into Theorem 3.3,
$$v_p\!\binom{2n}{n} = \frac{2n - \bigl(1 + 2n - p\bigr)}{p-1} = \frac{p-1}{p-1} = 1.$$
$\square$

**Corollary 3.5 (`prime_dvd_central_binom`).** If $p$ is prime and
$n < p \le 2n$, then $p \mid \binom{2n}{n}$.

*Proof sketch.* By Theorem 3.4 the factorization exponent of $p$ in
$\binom{2n}{n}$ is $1 \ge 1$, and a positive valuation is equivalent to
divisibility (the coefficient is nonzero since $n \le 2n$). $\square$

**Corollary 3.6 (`prod_primes_Ioc_dvd_central_binom`).**
$$\left(\prod_{\substack{n < p \le 2n \\ p\text{ prime}}} p\right)\ \Big|\ \binom{2n}{n}.$$

*Proof sketch.* The primes in $(n, 2n]$ are distinct, hence pairwise coprime, and
each divides $\binom{2n}{n}$ by Corollary 3.5. A product of pairwise-coprime
divisors of $m$ divides $m$. $\square$

### 3.4 Size of the central binomial coefficient

**Theorem 3.7 (`central_binom_lower`).**
$$4^n \le (2n+1)\binom{2n}{n}.$$

*Proof sketch.* Row $2n$ of Pascal's triangle has $2n+1$ entries summing to
$2^{2n} = 4^n$. The central entry $\binom{2n}{n}$ is the maximum of these, so the
sum is at most $(2n+1)\binom{2n}{n}$. $\square$

**Theorem 3.8 (`central_binom_sq_le`).**
$$(3n+1)\binom{2n}{n}^2 \le 16^n.$$

*Proof sketch.* This is a clean integer inequality that strengthens the naive
$\binom{2n}{n}^2 \le 16^n$ by the factor $3n+1$. It follows from a Vandermonde /
convexity estimate on the squared central coefficient and is the integer kernel
from which the real-analytic upper bound is extracted. $\square$

**Theorem 3.9 (`central_binom_upper`, corrected bound).**
$$\binom{2n}{n} \le \frac{4^n}{\sqrt{2n}}.$$

*Proof sketch.* From Theorem 3.8, $\binom{2n}{n}^2 \le 16^n/(3n+1) \le 16^n/(2n)$
for $n \ge 1$ (since $3n + 1 \ge 2n$). Taking real square roots,
$\binom{2n}{n} \le 4^n/\sqrt{2n}$. $\square$

**Remark 3.10 (a corrected error).** The informal brief states the upper bound
$\binom{2n}{n} \le 4^n/(2\sqrt n)$. This is **false**: at $n = 2$ it reads
$6 \le 16/(2\sqrt 2) = 5.657\ldots$, a contradiction. In fact $4^n/(2\sqrt n)$ is a
*lower* bound for $\binom{2n}{n}$. The correct and provable upper bound is
$\binom{2n}{n} \le 4^n/\sqrt{2n}$, which we adopt as Theorem 3.9. Note
$\sqrt{2n} = \sqrt 2 \cdot \sqrt n$, so the corrected bound is larger than the
erroneous one by exactly the factor $\sqrt 2$ — precisely the gap that makes the
true statement hold.

### 3.5 The destination: a Chebyshev-type primorial bound

**Theorem 3.11 (`chebyshev_primorial`).** For all $n \ge 1$,
$$\prod_{p \le n} p < 4^n, \qquad \text{i.e. } n\# < 4^n.$$

*Proof sketch.* Strong induction on $n$, following Erdős.

- **Base cases.** $1\# = 1 < 4$ and $2\# = 2 < 16$.
- **Even step ($n = 2m$, $m\ge 2$).** The number $2m$ is not prime, so
  $(2m)\# = (2m-1)\#$. By the induction hypothesis
  $(2m-1)\# < 4^{2m-1} < 4^{2m}$.
- **Odd step ($n = 2m+1$).** Partition the primes $p \le 2m+1$ into those with
  $p \le m+1$ and those with $m+1 < p \le 2m+1$:
  $$(2m+1)\# = (m+1)\# \cdot \!\!\prod_{m+1 < p \le 2m+1}\!\! p.$$
  By the induction hypothesis $(m+1)\# < 4^{m+1}$. For the second factor, each
  prime in $(m+1, 2m+1]$ divides $\binom{2m+1}{m}$ (the same exactness mechanism
  as Corollary 3.5, with the roles played by $m$ and $2m+1$), so their product
  divides and is therefore at most $\binom{2m+1}{m} \le 4^m$ (one of the two equal
  central entries of the odd row $2m+1$, whose total row sum is $4^{m}\cdot 2$, so
  each is $\le 4^m$). Multiplying,
  $$(2m+1)\# < 4^{m+1}\cdot 4^m = 4^{2m+1}.$$

The induction closes. $\square$

---

## 4. The Bridge, Conceptually

The logical skeleton of the development is a directed chain that begins in
combinatorics and ends in number theory:

$$\underbrace{\text{Legendre's formula}}_{\text{3.1}}
\;\Rightarrow\;
\underbrace{v_p\!\binom{2n}{n}\text{ digit formula}}_{\text{3.2--3.3}}
\;\Rightarrow\;
\underbrace{v_p = 1 \text{ on } (n,2n]}_{\text{3.4--3.6}}
\;\Rightarrow\;
\underbrace{\text{size bounds}}_{\text{3.7--3.9}}
\;\Rightarrow\;
\underbrace{n\# < 4^n}_{\text{3.11}}.$$

Two ideas do the heavy lifting. The first is *arithmetization via digit sums*:
Legendre's formula converts the analytic-looking quantity $v_p$ into a finite,
combinatorial digit computation. The second is *the container principle*: because
each prime in the upper half-interval appears to the first power, the central
coefficient acts as a multiplicative container whose size bounds the prime
product. The interplay — combinatorial size estimate on one side, number-theoretic
divisibility on the other — is what turns a fact about Pascal's triangle into a
fact about primes.

---

## 5. Algorithms

The formalization is constructive enough to yield concrete algorithms.

### 5.1 Valuation of $\binom{2n}{n}$ via digit sums

Given a prime $p$ and an index $n$, Theorem 3.3 computes the valuation without
ever factoring the enormous coefficient:

1. Compute $s_p(n)$ and $s_p(2n)$ by repeated division by $p$.
2. Return $(2\,s_p(n) - s_p(2n)) / (p-1)$.

This runs in $O(\log_p n)$ arithmetic operations, exponentially faster than
factoring $\binom{2n}{n}$ directly.

### 5.2 Primes dividing $\binom{2n}{n}$ exactly once

By Theorem 3.4 these are exactly the primes in $(n, 2n]$, which can be enumerated
by a sieve in $O(n \log\log n)$ time. Their product is a divisor of
$\binom{2n}{n}$ and a lower bound certificate for it.

### 5.3 Verifying the primorial bound

For any target $N$, one verifies $n\# < 4^n$ for all $n \le N$ by a single linear
sweep, accumulating the primorial and comparing against $4^n$ at each step.

---

## 6. Applications

- **Chebyshev's theorem.** Combining $n\# < 4^n$ with a lower bound from the same
  central-coefficient analysis yields $\pi(x) = \Theta(x/\ln x)$, the qualitative
  shape of the Prime Number Theorem, by entirely elementary means.
- **Bertrand's postulate.** The same valuation analysis of $\binom{2n}{n}$,
  pushed slightly further, gives Erdős's proof that there is always a prime
  between $n$ and $2n$. The exactness theorem (3.4) is the shared kernel.
- **Effective bounds.** Because every constant in the chain is explicit, the
  development produces fully effective (non-asymptotic) bounds suitable for
  certified computation.
- **Pedagogy of bridges.** The development is a compact case study of how a single
  classical formula (Legendre's) can serve as a translation device between two
  subjects, a template reusable across the catalog of cross-domain bridges.

---

## 7. Discussion

The most instructive episode in the formalization was Remark 3.10. The informal
brief confidently asserted $\binom{2n}{n}\le 4^n/(2\sqrt n)$, a bound that *looks*
right — it has the correct shape and the famous $4^n$ — yet is off by a factor of
$\sqrt2$ and fails at the very first nontrivial value $n=2$. A mechanized
development cannot proceed past such a falsehood; it forced the correct bound
$\binom{2n}{n}\le 4^n/\sqrt{2n}$ to the surface. This is the quiet, daily value of
formalization: not the proof of deep new theorems, but the relentless auditing of
the "obvious."

A second point worth emphasizing is the role of natural-number subtraction. The
digit-sum identities (Theorems 3.1–3.3) involve differences like $n - s_p(n)$ and
$2 s_p(n) - s_p(2n)$ that are only meaningful because the subtrahends are provably
no larger than the minuends ($s_p(n) \le n$, and $s_p(2n) \le 2\,s_p(n)$ on the
relevant range). In informal mathematics these inequalities are invisible; in a
formal setting they are load-bearing side conditions that must be discharged.

---

## 8. Future Directions

The broader research cycle that produced this development also explored custom
proof-automation tactics for the catalog (min-plus simplification, finite
residue-class decision procedures, and spectral-bound estimators). The forward
program includes:

1. **A confluent, terminating normal form for min-plus ("tropical")
   simplification**, turning the distributive backbone already proved into a
   genuine decision procedure for min-plus equality.
2. **Residue-class reflection for number-theoretic facts**, reducing each
   statement of the form "$\forall n,\, P(n \bmod m)$" to a finite check over
   $r < m$, generalizing the parity arguments used for quadratic residues.
3. **Two-sided spectral interval localization** for Hermitian matrices,
   strengthening modulus-based Gershgorin bounds to genuine eigenvalue intervals.
4. **A tropical (max-plus) eigenvalue bridge**, localizing the minimum cycle mean
   of a matrix via its diagonal entries, in analogy with Gershgorin's theorem.

Within the present binomial–prime bridge specifically, natural extensions are: a
formal proof of Bertrand's postulate reusing Theorem 3.4; the matching lower
primorial bound to close the loop to full Chebyshev; and an effective bound on
$\pi(x)$ with explicit constants extracted from the chain.

---

## 9. Conclusion

We have formalized, with proof sketches presented inline, the elementary bridge
from the central binomial coefficient to a Chebyshev-type prime bound. The path
runs through Legendre's digit-sum formula, the exact valuation of
$\binom{2n}{n}$, the "divides exactly once" theorem for primes in $(n,2n]$, and
matching size bounds, culminating in $\prod_{p\le n} p < 4^n$. Along the way we
corrected a stated but false upper bound. The development illustrates, in
miniature, how counting and primality are two readings of one underlying
arithmetic.
