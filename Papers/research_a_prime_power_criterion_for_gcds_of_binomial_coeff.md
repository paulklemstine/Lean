# A Prime-Power Criterion for the GCD of the Interior of a Pascal Row

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty / Number Theory

## Abstract

For an integer $k \ge 1$ let

$$
F(k) \;=\; \gcd_{1 \le i \le k} \binom{k+1}{i}
$$

be the greatest common divisor of the *interior* entries of row $k+1$ of Pascal's triangle (the entries strictly between the two bounding $1$'s). We give a complete and self-contained account of the classical fact that $F(k)$ is a perfect detector of prime powers:

$$
F(k) = 1 \quad\Longleftrightarrow\quad k+1 \text{ is not a prime power.}
$$

Moreover, when $k+1 = p^a$ is a prime power, $F(k) = p$. The proof splits into two independent halves. The forward (prime-power) half shows that if $k+1=p^a$ then $p$ divides every interior binomial coefficient, using the divisibility lemma $p \mid \binom{p^a}{i}$ for $0 < i < p^a$. The backward half is the substantive arithmetic content: if $k+1$ is not a prime power, then for each prime $p \mid k+1$ we exhibit an explicit interior index $i = p^{v_p(k+1)}$ at which $\binom{k+1}{i}$ is coprime to $p$, via a carry-free base-$p$ addition (Kummer's theorem). Hence no prime divides the whole interior and the gcd is $1$. We present the definitions, the four supporting lemmas, full proof sketches, algorithmic realizations, numerical demonstrations, and a discussion of generalizations to stretched binomial families $\binom{qk}{k}$ where the criterion sharpens to $P(k+1)^2 < k+1$.

## 1. Introduction

Pascal's triangle assigns to each row $n \ge 0$ the binomial coefficients $\binom{n}{0}, \binom{n}{1}, \dots, \binom{n}{n}$. The two end entries are always $1$. The *interior* of row $n$ is the multiset $\{\binom{n}{i} : 1 \le i \le n-1\}$.

A classical observation, going back at least to Balak Ram (1909), states that the gcd of the interior of row $n$ is the prime $p$ when $n = p^a$ is a prime power and is $1$ otherwise. This single integer therefore acts as an exact indicator of the property "is a prime power," one of the most fundamental structural properties an integer can possess.

We adopt the shift $n = k+1$ so that the interior index ranges over the clean set $\{1, 2, \dots, k\}$, and define $F(k) = \gcd_{1 \le i \le k}\binom{k+1}{i}$. The main theorem is then:

> **Theorem (Main).** For all $k \ge 1$, $\;F(k) = 1 \iff k+1$ is not a prime power.

The purpose of this paper is to give a fully self-contained, modern, and computationally illustrated treatment. The argument is elementary in its tools (one algebraic identity and Kummer's carry theorem) but is a model of how divisibility questions about binomial coefficients reduce to digit-level arithmetic in a prime base. Every theorem statement below has been formally verified.

### 1.1 Notation and conventions

- $\mathbb{N} = \{0, 1, 2, \dots\}$.
- $\binom{n}{i}$ denotes the binomial coefficient, with $\binom{n}{i} = 0$ for $i > n$.
- A positive integer $N$ is a **prime power** if $N = p^a$ for a prime $p$ and an integer $a \ge 1$. We write $\mathrm{IsPrimePow}(N)$ for this predicate. Note $1$ is **not** a prime power (no valid $a \ge 1$), and neither is any $N$ with two or more distinct prime divisors.
- $v_p(N)$ is the $p$-adic valuation of $N$: the largest $e$ with $p^e \mid N$. We also write this as $N.\mathrm{factorization}\,p$.
- $\mathrm{ordProj}_p(N) = p^{v_p(N)}$ is the $p$-part of $N$, and $\mathrm{ordCompl}_p(N) = N / p^{v_p(N)}$ is the prime-to-$p$ part, so $N = \mathrm{ordProj}_p(N) \cdot \mathrm{ordCompl}_p(N)$ with $p \nmid \mathrm{ordCompl}_p(N)$.

## 2. Definitions

**Definition 2.1 (Interior Pascal-row gcd).** For $k \in \mathbb{N}$,

$$
F(k) \;=\; \gcd_{1 \le i \le k} \binom{k+1}{i} \;=\; \gcd \Bigl( \{\, \binom{k+1}{i} : i \in \{1, \dots, k\} \,\} \Bigr).
$$

For $k \ge 1$ the index set $\{1, \dots, k\}$ is nonempty and corresponds exactly to the interior of row $n = k+1$, since the interior indices of row $n$ are $1, \dots, n-1 = 1, \dots, k$.

**Remark.** $F(0) = \gcd \emptyset = 0$ in the usual convention, which is why the theorem is stated for $k \ge 1$. For $k \ge 1$, $F(k) \ge 1$.

## 3. Supporting Lemmas

We isolate four lemmas. Throughout, $p$ is a prime.

**Lemma 3.1 (Divisor of every term).** For $1 \le i \le k$,

$$
F(k) \mid \binom{k+1}{i}.
$$

*Proof.* Immediate from the definition of gcd over a finite family: the gcd divides each member. $\blacksquare$

**Lemma 3.2 (Prime-power rows are uniformly stamped).** If $p$ is prime and $k+1 = p^a$ with $a \ge 1$, then

$$
p \mid F(k).
$$

*Proof sketch.* It suffices to show $p \mid \binom{p^a}{i}$ for every $1 \le i \le p^a - 1$, because then $p$ divides every term of the family and hence the gcd (gcd of multiples of $p$ is a multiple of $p$). The divisibility $p \mid \binom{p^a}{i}$ for $0 < i < p^a$ is standard: from the absorption identity $i\binom{p^a}{i} = p^a \binom{p^a - 1}{i-1}$, the prime $p$ divides the right side to order $a \ge 1$; since $0 < i < p^a$ implies $v_p(i) < a$, comparing $p$-adic valuations forces $v_p\!\bigl(\binom{p^a}{i}\bigr) \ge 1$. (In the formalization this is the library lemma `Nat.Prime.dvd_choose_pow`.) Applying this for each interior $i$ and taking the gcd gives $p \mid F(k)$. $\blacksquare$

**Lemma 3.3 (Prime-power rows have $F \ne 1$).** If $k+1$ is a prime power then $F(k) \ne 1$.

*Proof sketch.* Write $k + 1 = p^a$ with $p$ prime and $a \ge 1$ (this is exactly the content of $\mathrm{IsPrimePow}(k+1)$). By Lemma 3.2, $p \mid F(k)$. If $F(k)$ were $1$ then $p \mid 1$, impossible for a prime. $\blacksquare$

**Lemma 3.4 (Carry-free central split; the key arithmetic lemma).** Let $p$ be prime, $a \in \mathbb{N}$, and $m \in \mathbb{N}$ with $p \nmid m$. Then

$$
p \nmid \binom{p^a \cdot m}{\,p^a\,}.
$$

*Proof sketch.* We argue by induction on $a$ using Lucas' theorem in the form

$$
\binom{N}{K} \equiv \binom{N \bmod p}{K \bmod p}\binom{\lfloor N/p\rfloor}{\lfloor K/p\rfloor} \pmod p .
$$

- **Base case $a = 0$.** Here $\binom{m}{1} = m$, and $p \nmid m$ by hypothesis.
- **Inductive step.** Suppose the claim holds for $a$ and all $m$ coprime to $p$. For $a+1$, set $N = p^{a+1}m = p\cdot(p^a m)$ and $K = p^{a+1} = p \cdot p^a$. Then $N \bmod p = 0$ and $K \bmod p = 0$, so the low-digit factor is $\binom{0}{0} = 1$, while $\lfloor N/p\rfloor = p^a m$ and $\lfloor K/p\rfloor = p^a$. Lucas gives

$$
\binom{p^{a+1} m}{p^{a+1}} \equiv \binom{p^a m}{p^a} \pmod p .
$$

By the induction hypothesis the right-hand side is $\not\equiv 0 \pmod p$, hence so is the left. $\blacksquare$

Equivalently, in carry language: adding $p^a$ and $p^a(m-1)$ in base $p$ produces no carries, because the digit of $m$ at position $0$ (namely $m \bmod p$) is nonzero; by Kummer's theorem the number of carries equals $v_p\!\bigl(\binom{p^a m}{p^a}\bigr)$, which is therefore $0$.

## 4. Main Theorem and Proof

**Theorem 4.1 (Backward direction).** If $k \ge 1$ and $k+1$ is not a prime power, then $F(k) = 1$.

*Proof sketch.* Suppose for contradiction that $F(k) \ne 1$. Since $F(k) \ge 1$, there is a prime $p \mid F(k)$. By Lemma 3.1 (with $i = 1$, valid since $k \ge 1$), $F(k) \mid \binom{k+1}{1} = k+1$, so $p \mid k+1$.

Let $a = v_p(k+1) \ge 1$ and $q = (k+1)/p^a$, so that $k + 1 = p^a \cdot q$ with $p \nmid q$ and $q \ge 1$. We record three facts:

1. $a \ge 1$ because $p \mid k+1$.
2. $p \nmid q$ by definition of the $p$-part.
3. $p^a < k+1$: indeed $p^a \le k+1$ since $p^a \mid k+1$; equality $p^a = k+1$ would make $k+1$ a prime power, contradicting the hypothesis. Hence $p^a \le k$, so $i := p^a$ lies in the interior index set $\{1, \dots, k\}$.

By Lemma 3.1 applied at $i = p^a$, $\;F(k) \mid \binom{k+1}{p^a}$, and therefore $p \mid \binom{k+1}{p^a} = \binom{p^a q}{p^a}$.

But $q \ge 2$ (since $q \ge 1$ and $q = 1$ would give $k+1 = p^a$, a prime power) and $p \nmid q$, so Lemma 3.4 with $m = q$ yields $p \nmid \binom{p^a q}{p^a}$. This contradicts the previous line. Hence no prime divides $F(k)$, forcing $F(k) = 1$. $\blacksquare$

**Theorem 4.2 (Main Theorem).** For all $k \ge 1$,

$$
F(k) = 1 \quad\Longleftrightarrow\quad k+1 \text{ is not a prime power.}
$$

*Proof.* ($\Rightarrow$) Contrapositive of Lemma 3.3: if $k+1$ is a prime power then $F(k) \ne 1$. ($\Leftarrow$) Theorem 4.1. $\blacksquare$

**Corollary 4.3 (Exact value on the prime fibre).** If $k+1 = p^a$ is a prime power, then $F(k) = p$.

*Proof sketch.* By Lemma 3.2, $p \mid F(k)$. Conversely $F(k) \mid \binom{p^a}{1} = p^a$, so $F(k)$ is a power of $p$, say $p^b$ with $b \ge 1$. Taking $i = p^{a-1}$ (an interior index since $1 \le p^{a-1} < p^a$), Kummer's count shows $v_p\!\bigl(\binom{p^a}{p^{a-1}}\bigr) = 1$ exactly (a single carry), so $F(k) \mid \binom{p^a}{p^{a-1}}$ forces $b \le 1$. Hence $F(k) = p$. $\blacksquare$

## 5. Algorithms

We describe three procedures: a direct gcd computation, a fast primality-of-prime-power test built from the criterion, and a Kummer-carry computation of $p$-adic valuations that exposes *why* the theorem holds.

### 5.1 Direct interior gcd

Compute the binomial coefficients of row $k+1$ for $i = 1, \dots, k$ and fold them with $\gcd$. Using the recurrence $\binom{n}{i} = \binom{n}{i-1}\cdot \frac{n-i+1}{i}$ keeps all intermediate quantities exact and avoids factorials. Complexity: $O(k)$ big-integer multiplications/divisions, plus $O(k)$ gcd operations on numbers of $O(k)$ bits each.

### 5.2 Prime-power detection via the criterion

By Theorem 4.2, $F(k) = 1$ iff $k+1$ is not a prime power. So $F$ provides an arithmetic primality-power oracle. Conversely, to predict $F(k)$ without summing the row: factor $k+1$; if it has exactly one distinct prime $p$, return $p$; otherwise return $1$. Complexity dominated by factoring $k+1$.

### 5.3 Kummer-carry valuation

To compute $v_p\!\bigl(\binom{a+b}{a}\bigr)$, add $a$ and $b$ in base $p$ and count carries (Kummer). This both computes valuations and *demonstrates the proof*: for non-prime-power $n = p^a q$, the split $i = p^a$ yields zero carries, certifying $p \nmid \binom{n}{i}$.

## 6. Numerical Demonstrations

The following table (computed directly) confirms Theorem 4.2 for $k = 1, \dots, 20$:

| $k$ | $n=k+1$ | factorization of $n$ | $F(k)$ | prime power? |
|---|---|---|---|---|
| 1 | 2 | $2$ | 2 | yes |
| 2 | 3 | $3$ | 3 | yes |
| 3 | 4 | $2^2$ | 2 | yes |
| 4 | 5 | $5$ | 5 | yes |
| 5 | 6 | $2\cdot 3$ | 1 | no |
| 6 | 7 | $7$ | 7 | yes |
| 7 | 8 | $2^3$ | 2 | yes |
| 8 | 9 | $3^2$ | 3 | yes |
| 9 | 10 | $2\cdot 5$ | 1 | no |
| 10 | 11 | $11$ | 11 | yes |
| 11 | 12 | $2^2\cdot 3$ | 1 | no |
| 12 | 13 | $13$ | 13 | yes |
| 13 | 14 | $2\cdot 7$ | 1 | no |
| 14 | 15 | $3\cdot 5$ | 1 | no |
| 15 | 16 | $2^4$ | 2 | yes |
| 16 | 17 | $17$ | 17 | yes |
| 17 | 18 | $2\cdot 3^2$ | 1 | no |
| 18 | 19 | $19$ | 19 | yes |
| 19 | 20 | $2^2\cdot 5$ | 1 | no |
| 20 | 21 | $3\cdot 7$ | 1 | no |

In every row $F(k) \in \{1\} \cup \{\text{primes}\}$, and $F(k) > 1$ precisely on the prime-power rows, with $F(k)$ equal to the underlying prime (Corollary 4.3).

The carry-free witness can be inspected directly. Take $n = 12 = 2^2 \cdot 3$ and $p = 2$, so $a = 2$, $i = 2^2 = 4$. Then $\binom{12}{4} = 495 = 3^2 \cdot 5 \cdot 11$ is odd, certifying $2 \nmid F(11)$. Taking $p = 3$, $a = 1$, $i = 3$: $\binom{12}{3} = 220 = 2^2\cdot 5\cdot 11$ is not divisible by $3$. No prime survives, so $F(11) = 1$.

## 7. Applications and Connections

**Primality and prime-power characterizations.** A well-known criterion states $n$ is prime iff $n \mid \binom{n}{i}$ for all interior $i$. The present theorem is the complete refinement: it identifies exactly which prime (if any) divides the *whole* interior, and shows it survives precisely on prime powers. The gcd of a Pascal row is thus a clean integer-valued detector of the prime-power property.

**Kummer's theorem as a unifying engine.** The hard half is entirely a Kummer-carry computation. The same machinery governs Lucas' theorem, $p$-adic properties of factorials, and the fractal Sierpiński structure of Pascal's triangle modulo $p$. The interior-gcd theorem is a particularly crisp showcase: divisibility of an entire row collapses to whether a single base-$p$ addition carries.

**Combinatorial coherence.** Lemma 3.2 expresses a structural "coherence" of prime-power rows: every interior cell shares the arithmetic factor $p$. This is the mechanism behind several congruence patterns for $\binom{p^a}{i}$ used in combinatorial identities and generating-function manipulations.

## 8. Discussion

The theorem is sharp: the equivalence in Theorem 4.2 fails for neither direction, and Corollary 4.3 pins the exact value. The proof structure — an easy uniform-stamp half and a hard carry-hunting half — is robust and reappears in generalizations.

A subtle but essential indexing point deserves emphasis. The divisibility behavior of the interior is governed by the base-$p$ representation of $n = k+1$, **not** of $k$. This is why the criterion is phrased in terms of $k+1$ being a prime power. The same off-by-one phenomenon resurfaces dramatically in the stretched-binomial generalizations below, where a naive "$k$ is a prime power" guess is incorrect.

## 9. Future Directions

The interior-row gcd is the cleanest member of a family of "restricted-index binomial gcds." Replacing the interior of one row by the stretched central family $\binom{qk}{k}$, $q = 2, \dots, k$, yields

$$
F^{\star}(k) = \gcd_{2 \le q \le k} \binom{qk}{k},
$$

closely related to the OEIS sequence A080170, $D(k) = \gcd_{2 \le q \le k+1}\binom{qk}{k}$. Conjecturally:

1. **Shift equality.** $F^{\star}(k) = D(k)$ for all $k \ge 3$, differing only at $k = 2$; the dropped term $q = k+1$ is never the strict $p$-adic minimizer for $k \ge 3$.
2. **Corrected criterion.** $F^{\star}(k) = 1$ iff the largest exact prime-power component $P$ of $k+1$ satisfies $P^2 < k+1$ (equivalently $(k+1)/P > P$). Again the controlling object is $k+1$, because the carries of $\binom{qk}{k}$ are driven by $qk = q(k+1) - q$.
3. **Exact valuation off the prime fibre.** For $k+1 = p^a m$ with $p \nmid m$ and $a \ge 1$, the exponent of $p$ in $F^{\star}(k)$ is conjecturally $\max(0,\, a - \lfloor \log_p m \rfloor)$: the minimizing $q$ aligns the top nonzero base-$p$ digit of $m$ with a borrow, costing exactly $\lfloor \log_p m \rfloor$ carries out of the available $a$.
4. **Two-sided counterexample families.** Via Dirichlet's theorem on primes in arithmetic progressions there should be infinitely many $k$ with $F^\star(k) \ne 1$ yet $k$ not a prime power, and infinitely many with $F^\star(k) = 1$ yet $k$ a prime power — confirming that the correct predicate is about $k+1$, not $k$.
5. **Stability under deeper truncation.** Defining $F^\star_t(k) = \gcd_{2 \le q \le k - t}\binom{qk}{k}$, the criterion $F^\star_t(k) = 1 \iff P(k+1)^2 < k+1$ is conjectured to persist for each fixed $t$ once $k$ is large enough.

The simple interior-row case proved here supplies the base mechanisms — the absorption identity for the easy half and the carry-free split (Lemma 3.4) for the hard half — on which all of these generalizations build.

## 10. Conclusion

The greatest common divisor of the interior of row $n = k+1$ of Pascal's triangle is a perfect prime-power detector: it equals $1$ exactly when $n$ is not a prime power, and equals the underlying prime $p$ when $n = p^a$. The result rests on two short arguments — a uniform divisibility stamp for prime-power rows and a carry-free base-$p$ split for the rest — and exemplifies how Kummer's translation of binomial divisibility into the counting of carries renders an opaque gcd transparent.

## References to standard results used (stated inline above)

- The absorption identity $i\binom{n}{i} = n\binom{n-1}{i-1}$ and the consequence $p \mid \binom{p^a}{i}$ for $0 < i < p^a$.
- Lucas' theorem: $\binom{N}{K} \equiv \prod_j \binom{N_j}{K_j} \pmod p$ over base-$p$ digits.
- Kummer's theorem: $v_p\!\bigl(\binom{a+b}{a}\bigr)$ equals the number of carries when adding $a$ and $b$ in base $p$.
