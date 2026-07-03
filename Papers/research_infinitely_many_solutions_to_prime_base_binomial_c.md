# Prime-Base Binomial Congruences: The Prime Fibre and the Composite Frontier

## Abstract

Fix an integer base $q \ge 2$. We study the set of natural numbers $n$ satisfying the *prime-base binomial congruence*
$$\binom{qn}{n} \equiv q^{n} \pmod{n}.$$
Our first main result is that this congruence holds for **every prime** $n = p$ and **every base** $q$: both sides reduce to $q$ modulo $p$, the left by Lucas' theorem and the right by Fermat's little theorem. Consequently the solution set is infinite for every base, unconditionally. Our second contribution concerns the composite family $n = q^{t} p$, whose existence is governed by the integer
$$A_t = \binom{q^{\,t+1}}{q^{\,t}} - q^{\,q^{t}}.$$
We prove that the central prime-power binomial coefficient $\binom{q^{t+1}}{q^{t}}$ carries exactly one factor of $q$ (one carry in base-$q$ addition, via Kummer/Legendre), and deduce that $q$ divides $A_t$ exactly once for all $t \ge 1$: $q \mid A_t$ but $q^2 \nmid A_t$. This isolates the base $q$ to a single factor of $A_t$, so that the base can never serve as the auxiliary prime $p$ in $n = q^t p$; the "$p \neq q$" condition of the composite conjecture is therefore automatic. We situate these results against the open conjecture that infinitely many composite solutions of shape $n = q^t p$ exist, and we describe the arithmetic of the residual $R_t = A_t / q$ as the remaining obstruction.

**Keywords:** binomial coefficients, Lucas' theorem, Kummer's theorem, Fermat's little theorem, $q$-adic valuation, digit sums, prime divisors, congruences.

---

## 1. Introduction

Binomial coefficients modulo integers have been a rich source of arithmetic phenomena since the classical work of Lucas and Kummer in the nineteenth century. A recurring theme is to compare a binomial coefficient with a simpler arithmetic quantity and to ask when they are congruent modulo a modulus that depends on the parameters.

In this paper we fix a base $q \ge 2$ and consider the two-sided comparison
$$\binom{qn}{n} \quad \text{versus} \quad q^{n} \pmod{n}. \tag{1}$$
The left-hand side generalizes the central binomial coefficient (recovered at $q = 2$): it counts the ways to choose $n$ items from $qn$. The right-hand side is the pure $n$-th power of the base. There is no a priori reason for these to agree modulo $n$, and for generic $n$ they do not. Nevertheless, we show the congruence holds along the full sequence of primes for every base, and we analyze the arithmetic that controls a sparser, genuinely deeper composite family.

### 1.1 Statement of the congruence

**Definition 1.1 (Prime-base binomial congruence).** For integers $q \ge 2$ and $n \ge 1$ we say $n$ is a *solution for base $q$* if
$$\binom{qn}{n} \equiv q^{n} \pmod{n}.$$

**Definition 1.2 (Base-$q$ digit sum).** For $q \ge 2$ and $n \ge 0$, let $s_q(n)$ denote the sum of the digits of $n$ written in base $q$. Equivalently, if $n = \sum_i d_i q^i$ with $0 \le d_i < q$, then $s_q(n) = \sum_i d_i$.

### 1.2 Overview of results

- **Theorem A (Prime fibre).** For every base $q$ and every prime $p$, $\binom{qp}{p} \equiv q \pmod p$, and hence $p$ is a solution for base $q$. In particular the solution set is infinite for every base.
- **Theorem B (Central valuation).** For every prime $q$ and every $t \ge 0$, the exponent of $q$ in $\binom{q^{t+1}}{q^{t}}$ equals $1$.
- **Theorem C (Exact valuation of $A_t$).** For every prime base $q$ and every $t \ge 1$, $q \mid A_t$ and $q^2 \nmid A_t$, where $A_t = \binom{q^{t+1}}{q^{t}} - q^{q^{t}}$.

Sections 2–4 prove Theorems A, B, C respectively. Section 5 discusses the composite family $n = q^t p$ and the role of $A_t$. Section 6 gives algorithms and numerical data. Section 7 discusses applications and Section 8 lists open problems and future directions.

---

## 2. The prime fibre: every prime solves the congruence

We prove Theorem A. The argument splits (1), evaluated at $n = p$, into two independent classical evaluations.

### 2.1 The binomial side via Lucas' theorem

**Theorem 2.1 (Lucas).** Let $p$ be prime and write $m = \sum_i m_i p^i$, $k = \sum_i k_i p^i$ in base $p$ with $0 \le m_i, k_i < p$. Then
$$\binom{m}{k} \equiv \prod_i \binom{m_i}{k_i} \pmod{p}.$$
Equivalently, in recursive form, $\binom{m}{k} \equiv \binom{m \bmod p}{k \bmod p}\binom{\lfloor m/p\rfloor}{\lfloor k/p\rfloor} \pmod p$.

**Lemma 2.2 (Lucas fibre).** For every base $q$ and every prime $p$,
$$\binom{qp}{p} \equiv q \pmod{p}.$$

*Proof.* Apply the recursive form of Lucas' theorem to $m = qp$ and $k = p$. The lowest base-$p$ digits are $m \bmod p = qp \bmod p = 0$ and $k \bmod p = p \bmod p = 0$, while the higher parts are $\lfloor m/p \rfloor = q$ and $\lfloor k/p \rfloor = 1$. Hence
$$\binom{qp}{p} \equiv \binom{0}{0}\binom{q}{1} = 1 \cdot q = q \pmod{p}.$$
Note that no bound relating $q$ and $p$ is required: the digit reduction $qp \mapsto (q, 0)$ and $p \mapsto (1,0)$ holds for every base. $\qquad\blacksquare$

### 2.2 The power side via Fermat's little theorem

**Theorem 2.3 (Fermat).** For every prime $p$ and every integer $a$, $a^{p} \equiv a \pmod{p}$.

**Lemma 2.4 (Fermat fibre).** For every base $q$ and every prime $p$, $q^{p} \equiv q \pmod{p}$.

*Proof.* Immediate from Theorem 2.3 with $a = q$. $\qquad\blacksquare$

### 2.3 Conclusion

**Theorem A (Prime fibre; every prime is a solution).** For every base $q$ and every prime $p$,
$$\binom{qp}{p} \equiv q^{p} \pmod{p}.$$
Consequently the set $\{\, n : \binom{qn}{n} \equiv q^{n} \pmod n \,\}$ is infinite for every base $q$.

*Proof.* By Lemma 2.2, $\binom{qp}{p} \equiv q \pmod p$; by Lemma 2.4, $q^{p} \equiv q \pmod p$. Transitivity of congruence gives $\binom{qp}{p} \equiv q^{p} \pmod p$, so $p$ is a solution. Since there are infinitely many primes, the solution set is infinite. $\qquad\blacksquare$

**Remark 2.5.** Theorem A makes the qualitative "infinitely many solutions" statement *unconditional* and *uniform in the base*. The nontrivial content of the subject therefore lies not in the mere existence of infinitely many solutions but in the structure of the solutions that are **not** prime — the composite family analyzed below.

---

## 3. The valuation of the central prime-power binomial coefficient

We now turn to the driver integer of the composite construction and prove Theorem B.

### 3.1 Kummer's theorem and its prime-power specialization

**Theorem 3.1 (Kummer).** Let $q$ be prime and $a, b \ge 0$. The exponent $v_q\!\big(\binom{a+b}{a}\big)$ of $q$ in $\binom{a+b}{a}$ equals the number of carries when adding $a$ and $b$ in base $q$.

An equivalent packaging, convenient here, records the additivity of the $q$-adic valuation across the prime-power identity: for $0 < k < q^{m}$,
$$v_q\!\left(\binom{q^{m}}{k}\right) + v_q(k) = m. \tag{2}$$
This follows from Legendre's formula $v_q(N!) = \frac{N - s_q(N)}{q-1}$ applied to $\binom{q^m}{k} = \frac{(q^m)!}{k!\,(q^m-k)!}$, together with $s_q(q^m) = 1$.

### 3.2 The central valuation

**Theorem B (Central prime-power binomial valuation).** For every prime $q$ and every $t \ge 0$,
$$v_q\!\left(\binom{q^{\,t+1}}{q^{\,t}}\right) = 1.$$

*Proof (via (2)).* Take $m = t+1$ and $k = q^{t}$, which satisfies $0 < q^{t} < q^{t+1}$. Then $v_q(k) = v_q(q^{t}) = t$, and (2) gives
$$v_q\!\left(\binom{q^{t+1}}{q^{t}}\right) = (t+1) - t = 1.$$

*Proof (via Kummer, carry count).* Write $\binom{q^{t+1}}{q^{t}} = \binom{a+b}{a}$ with $a = q^{t}$ and $b = q^{t+1} - q^{t} = (q-1)q^{t}$. In base $q$, $a$ is the single digit $1$ in position $t$ and $b$ is the single digit $q-1$ in position $t$. Adding them produces $1 + (q-1) = q$ in position $t$, which overflows to a carry into position $t+1$ and leaves digit $0$ in position $t$; all other positions are $0$ with no carry. Exactly one carry occurs, so by Theorem 3.1 the valuation is $1$. $\qquad\blacksquare$

**Corollary 3.2.** $q \mid \binom{q^{t+1}}{q^{t}}$ but $q^{2} \nmid \binom{q^{t+1}}{q^{t}}$, for every prime $q$ and every $t \ge 0$.

---

## 4. Exact $q$-adic valuation of $A_t$

**Definition 4.1.** For $q \ge 2$ and $t \ge 0$ set
$$A_t \;=\; \binom{q^{\,t+1}}{q^{\,t}} - q^{\,q^{t}} \in \mathbb{Z}.$$
(The subtraction is taken in $\mathbb{Z}$; it need not be positive a priori, though numerically it is.)

**Theorem C (Exact valuation of $A_t$).** For every prime base $q$ and every $t \ge 1$,
$$q \mid A_t \qquad\text{and}\qquad q^{2} \nmid A_t.$$
Equivalently, $v_q(A_t) = 1$: the base $q$ divides $A_t$ exactly once.

*Proof.* Write $A_t = C - P$ with $C = \binom{q^{t+1}}{q^{t}}$ and $P = q^{q^{t}}$.

*Divisibility by $q$.* By Corollary 3.2, $q \mid C$. Since $t \ge 1$, we have $q^{t} \ge 1$, so $q \mid P = q^{q^{t}}$. Hence $q \mid (C - P) = A_t$.

*Non-divisibility by $q^{2}$.* Because $t \ge 1$ and $q \ge 2$, the exponent satisfies $q^{t} \ge 2$, so $q^{2} \mid P$. By Corollary 3.2, $q^{2} \nmid C$. If we had $q^{2} \mid A_t = C - P$, then $C = A_t + P$ would be divisible by $q^{2}$ (as a sum of two multiples of $q^{2}$), contradicting $q^{2} \nmid C$. Hence $q^{2} \nmid A_t$. $\qquad\blacksquare$

**Numerical illustration.**

| $q$ | $t$ | $\binom{q^{t+1}}{q^{t}}$ | $q^{q^{t}}$ | $A_t$ | $A_t/q$ |
|----|----|----|----|----|----|
| $2$ | $1$ | $\binom{4}{2}=6$ | $2^{2}=4$ | $2$ | $1$ |
| $2$ | $2$ | $\binom{8}{4}=70$ | $2^{4}=16$ | $54$ | $27$ |
| $2$ | $3$ | $\binom{16}{8}=12870$ | $2^{8}=256$ | $12614$ | $6307$ |
| $3$ | $1$ | $\binom{9}{3}=84$ | $3^{3}=27$ | $57$ | $19$ |
| $3$ | $2$ | $\binom{27}{9}=4686825$ | $3^{9}=19683$ | $4667142$ | $1555714$ |

In every row exactly one factor of $q$ appears in $A_t$, and the residual $A_t / q$ is coprime to $q$ (e.g. $1, 27, 6307, 19, 1555714$; note $27 = 3^3$ is coprime to base $2$).

**Definition 4.2 (Residual).** For $t \ge 1$ let $R_t = A_t / q \in \mathbb{Z}$, which by Theorem C is an integer coprime to $q$. Algebraically,
$$R_t = \frac{1}{q}\binom{q^{t+1}}{q^{t}} - q^{\,q^{t}-1} = \binom{q^{t+1}-1}{q^{t}-1} - q^{\,q^{t}-1},$$
using the absorption identity $\frac{1}{q^t}\binom{q^{t+1}}{q^t}\cdot q^t = \binom{q^{t+1}}{q^t}$ together with $\frac{q^t}{q^{t+1}}\binom{q^{t+1}}{q^t} = \binom{q^{t+1}-1}{q^t-1}$.

---

## 5. The composite family $n = q^{t} p$

The prime fibre (Theorem A) already forces the solution set to be infinite, but its solutions are prime. The structurally richer question concerns *composite* solutions, and the most tractable family has the shape
$$n = q^{t} p, \qquad t \ge 1, \quad p \text{ prime}, \quad p \neq q. \tag{3}$$

For such $n$, an analysis of the congruence (1) — combining the multiplicative structure of $\binom{qn}{n}$ with the base-$q$ digit sum $s_q$ — leads to two gates that a pair $(t, p)$ must clear:

1. **Divisibility gate:** $p \mid A_t$.
2. **Digit-sum gate:** $s_q\big((q-1)p\big) \ge (q-1)t$.

**Proposition 5.1 (Role of the valuation).** For every prime base $q$ and $t \ge 1$, the base $q$ itself never satisfies the divisibility gate to first order in the sense required by (3): since $v_q(A_t) = 1$ (Theorem C), the only prime power of $q$ dividing $A_t$ is $q^1$, so $q$ cannot supply the auxiliary prime factor $p \neq q$ needed in $n = q^t p$. All candidate primes $p$ dividing $A_t$ are found among the divisors of the residual $R_t = A_t/q$, which is coprime to $q$.

*Proof.* Immediate from Theorem C: $A_t = q\,R_t$ with $\gcd(R_t, q) = 1$, so the set of prime divisors of $A_t$ is $\{q\} \cup \{\text{prime divisors of } R_t\}$, and $q$ is excluded once we demand $p \neq q$. $\qquad\blacksquare$

Thus Theorem C performs a clean reduction: the composite search space is exactly the set of prime factors of the residuals $R_t$, and the automatic exclusion of the base means the hypothesis $p \neq q$ in the composite conjecture is not an extra genericity assumption but a consequence of arithmetic.

**Conjecture 5.2 (Infinitely many composite solutions).** For every prime base $q$ there exist infinitely many pairs $(t, p)$ with $p$ prime, $p \neq q$, $p \mid A_t$, and $s_q((q-1)p) \ge (q-1)t$; each such pair yields a composite solution $n = q^{t} p$ of the congruence (1).

The heuristic supporting Conjecture 5.2 is a primitive-prime-divisor phenomenon: the residuals $R_t$ grow super-exponentially and, in the spirit of Zsygmondy's and Carmichael's theorems, should acquire a *new* large prime factor for infinitely many $t$. A large prime factor $p$ automatically clears the linear digit-sum gate, because $s_q((q-1)p)$ grows like $\log p$ while the threshold $(q-1)t$ is fixed once $t$ is fixed.

---

## 6. Algorithms and numerical data

We describe the elementary algorithms used to generate and verify the data above; full type-hinted implementations accompany this paper.

### 6.1 Solution enumeration

To list solutions for base $q$ up to a bound $N$, evaluate both sides of (1) modulo $n$ for each $n \le N$. Working modulo $n$ throughout keeps the integers small: compute $\binom{qn}{n} \bmod n$ by a modular product and $q^{n} \bmod n$ by fast exponentiation.

### 6.2 Valuation checker

To verify Theorem C empirically, compute $A_t$ exactly (Python big integers) and extract $v_q(A_t)$ by repeated division. The output is uniformly $1$ for $t \ge 1$.

### 6.3 Residual factorization

To seed the composite search, factor $R_t = A_t / q$ and record its prime divisors $p \neq q$; for each such $p$, test the digit-sum gate $s_q((q-1)p) \ge (q-1)t$. Pairs clearing both gates produce composite solutions $n = q^t p$, which can be independently re-verified against (1).

---

## 7. Applications and context

The prime fibre theorem (Theorem A) provides a clean, uniform family of congruences valid for every base — useful as a source of test cases for computational number theory and as an accessible illustration of how Lucas' and Fermat's theorems combine. The valuation theorem (Theorem C) is a small but sharp structural fact: it demonstrates how carry-counting (Kummer) and the additivity of valuations (Legendre) localize the arithmetic of a difference of a binomial coefficient and a prime power. Such exact-valuation results are the backbone of lifting-the-exponent arguments and of primitive-prime-divisor theorems, which is precisely why they are the natural first step toward the composite conjecture.

---

## 8. Discussion and future directions

The prime fibre is now completely understood, cleanly isolating the composite family as the true frontier, and the exact one-carry valuation of $A_t$ removes the base $q$ itself from the candidate pool, sharpening the search to primes $p \neq q$. We record the principal open directions.

**8.1 Infinitely many composite solutions of shape $n = q^t p$.** *(Conjecture 5.2.)* For every prime $q$ there are infinitely many pairs $(t, p)$ with $p$ a prime distinct from $q$, $p \mid A_t$, and $s_q((q-1)p) \ge (q-1)t$; each gives a composite solution. The key insight is that the residuals $R_t = A_t/q$ form a rapidly growing sequence, and a primitive-prime-divisor phenomenon (Zsygmondy/Carmichael) should force a new large prime factor infinitely often; a large prime factor automatically clears the linear digit-sum threshold.

**8.2 Arithmetic of the residual $R_t = A_t/q$.** Writing $R_t = \binom{q^{t+1}-1}{q^{t}-1} - q^{q^{t}-1}$, we conjecture $R_t$ is squarefree for infinitely many $t$, and that for every fixed bound $B$ all but finitely many $R_t$ possess a prime factor exceeding $B$. Since $R_t$ is a difference of a Lucas-type binomial and a pure prime power, lifting-the-exponent and cyclotomic divisibility should control its factor structure far more tightly than the raw size estimate suggests. Because $q \parallel A_t$ exactly, the entire number-theoretic content of $A_t$ is concentrated in $R_t$.

**8.3 The digit-sum gate as a near-automatic condition.** For fixed $q$ and $t$, we conjecture the proportion of primes $p \le X$ with $s_q((q-1)p) \ge (q-1)t$ tends to $1$ as $X \to \infty$; hence the digit-sum gate is satisfied by asymptotically every admissible prime and only the divisibility $p \mid A_t$ is truly restrictive. Base-$q$ digit sums of multiples $(q-1)p$ concentrate around a value proportional to $\log p$, so a fixed linear threshold is eventually cleared by all but a vanishing set of primes. Equidistribution results for digit sums along primes should make this precise.

**8.4 A local-to-global law.** Finally, one seeks a local-to-global principle unifying the two gates: a description, for each prime $p$, of the set of exponents $t$ for which $(t, p)$ solves both gates, and a global count of the resulting composite solutions below $X$.

---

## Acknowledgements

The author thanks the many classical foundations — Euclid, Fermat, Lucas, Kummer, Legendre — on whose theorems this work rests.
