# Universal Divisibility of Power-Difference Polynomials: The Case $a^5 - a$ and Its Sharpening to Modulus $30$

## Abstract

We give a complete, self-contained treatment of the classical fact that $a^5 - a$ is divisible by $5$ for every integer $a$, together with the sharpening that $a^5 - a$ is in fact divisible by $30$. The result for the prime $5$ is the case $p = 5$ of Fermat's Little Theorem, which we prove from first principles via modular arithmetic and the structure of the multiplicative group of a finite field. The strengthening to $30 = 2 \cdot 3 \cdot 5$ is obtained by proving divisibility by each of the primes $2$, $3$, and $5$ independently and combining them through coprimality. We then place the result inside a general theory of *power-difference polynomials* $a^n - a$: for each exponent $n$ there is a maximal universal divisor $D(n)$, which is squarefree and equal to the product of all primes $p$ satisfying $(p-1) \mid (n-1)$. For $n = 5$ this yields $D(5) = 30$, matching our strengthened result exactly. We discuss the failure of the identity-map phenomenon modulo prime powers, the palindromic factorization structure of $a^n - a$ for odd $n$, and a probabilistic interpretation of the universal divisor. Numerical algorithms and worked examples accompany the exposition.

## 1. Introduction

The statement that $a^5 - a$ is an integer multiple of $5$ for every integer $a$ is among the most familiar exercises in elementary number theory. It is a special case of a foundational result:

> **Fermat's Little Theorem.** Let $p$ be a prime. Then $a^p \equiv a \pmod p$ for every integer $a$; equivalently, $p \mid (a^p - a)$.

Despite its elementary appearance, the case $p = 5$ is a gateway to a rich circle of ideas: modular arithmetic, the multiplicative structure of finite fields, the Chinese Remainder Theorem, and the classification of "universal divisors" of the polynomial family $a^n - a$. The purpose of this paper is threefold:

1. To give a rigorous, motivated proof that $5 \mid (a^5 - a)$ for all integers $a$.
2. To prove the sharper statement $30 \mid (a^5 - a)$ and explain structurally why $30$, and not merely $5$, is the correct modulus.
3. To situate both results within a general framework for the universal divisibility of $a^n - a$.

Throughout, $a, b, n$ denote integers and $p$ a prime. We write $a \equiv b \pmod m$ to mean $m \mid (a - b)$.

## 2. Preliminaries: Modular Arithmetic

**Definition 2.1 (Congruence).** For a positive integer $m$, integers $a$ and $b$ are *congruent modulo $m$*, written $a \equiv b \pmod m$, if $m$ divides $b - a$. This is an equivalence relation, and it is compatible with addition and multiplication: if $a \equiv a'$ and $b \equiv b' \pmod m$, then $a + b \equiv a' + b'$ and $ab \equiv a'b' \pmod m$.

**Definition 2.2 (The ring $\mathbb{Z}/m\mathbb{Z}$).** The congruence classes modulo $m$ form a commutative ring with $m$ elements, denoted $\mathbb{Z}/m\mathbb{Z}$, with representatives $\{0, 1, \dots, m-1\}$. Divisibility statements about integers translate to identities in this ring: $m \mid (a^n - a)$ holds for all integers $a$ if and only if $x^n = x$ holds for all $x \in \mathbb{Z}/m\mathbb{Z}$.

**Lemma 2.3 (Finite verification).** Let $P(a)$ be an integer polynomial. Then $m \mid P(a)$ for all integers $a$ if and only if $m \mid P(r)$ for each $r \in \{0, 1, \dots, m-1\}$.

*Proof.* Every integer $a$ is congruent modulo $m$ to exactly one $r$ in the given range, and by compatibility of congruence with the ring operations, $P(a) \equiv P(r) \pmod m$. Hence $m \mid P(a) \iff m \mid P(r)$. $\square$

Lemma 2.3 reduces any universal divisibility claim about a polynomial to a *finite* check — the conceptual engine behind everything that follows.

## 3. The Prime Case: $5 \mid (a^5 - a)$

We present two proofs: a direct finite verification, and a structural proof revealing the mechanism.

### 3.1 Direct proof by finite verification

**Theorem 3.1.** For every integer $a$, $\;5 \mid (a^5 - a)$; equivalently $a^5 \equiv a \pmod 5$.

*Proof.* By Lemma 2.3 with $m = 5$, it suffices to verify $r^5 \equiv r \pmod 5$ for $r \in \{0,1,2,3,4\}$:
$$0^5 = 0 \equiv 0,\quad 1^5 = 1 \equiv 1,\quad 2^5 = 32 \equiv 2,\quad 3^5 = 243 \equiv 3,\quad 4^5 = 1024 \equiv 4 \pmod 5.$$
All five cases hold, so $r^5 \equiv r \pmod 5$ for all residues, and therefore $a^5 \equiv a \pmod 5$ for all integers $a$. $\square$

### 3.2 Structural proof via the multiplicative group

The finite check is complete but opaque. The following proof explains *why* the fifth power is the identity map modulo $5$, and generalizes to arbitrary primes.

**Lemma 3.2 ($\mathbb{Z}/p\mathbb{Z}$ is a field).** If $p$ is prime, then every nonzero element of $\mathbb{Z}/p\mathbb{Z}$ has a multiplicative inverse, and $\mathbb{Z}/p\mathbb{Z}$ has no zero divisors.

*Proof.* If $1 \le a \le p-1$, then $\gcd(a, p) = 1$, so by Bézout's identity there exist integers $u, v$ with $ua + vp = 1$, giving $ua \equiv 1 \pmod p$. Absence of zero divisors follows: if $ab \equiv 0$ with $a \not\equiv 0$, multiply by $a^{-1}$ to get $b \equiv 0$. $\square$

**Lemma 3.3 (Order divides group size).** Let $G$ be a finite abelian group of order $N$ (written multiplicatively). Then $g^N = 1$ for every $g \in G$.

*Proof.* Consider the map $x \mapsto gx$ on $G$; it is a bijection, so the product of all elements $\prod_{x \in G} x$ equals $\prod_{x \in G} (gx) = g^N \prod_{x \in G} x$. Cancelling the common product (valid in a group) gives $g^N = 1$. $\square$

**Theorem 3.4 (Fermat's Little Theorem).** Let $p$ be prime. Then $a^p \equiv a \pmod p$ for every integer $a$.

*Proof.* If $a \equiv 0 \pmod p$, then $a^p \equiv 0 \equiv a$. Otherwise $a$ represents a nonzero element of the field $\mathbb{Z}/p\mathbb{Z}$, which by Lemma 3.2 lies in the multiplicative group $(\mathbb{Z}/p\mathbb{Z})^\times$ of order $p-1$. By Lemma 3.3, $a^{p-1} \equiv 1 \pmod p$, and multiplying by $a$ gives $a^p \equiv a \pmod p$. $\square$

Setting $p = 5$ recovers Theorem 3.1 with a reason attached: the nonzero residues $\{1,2,3,4\}$ form a group of order $4$, so $a^4 \equiv 1$ and hence $a^5 \equiv a$. Primeness is essential: it is exactly what makes $\mathbb{Z}/p\mathbb{Z}$ a field with a well-behaved multiplicative group.

## 4. The Sharpening: $30 \mid (a^5 - a)$

### 4.1 Coprime combination

**Lemma 4.1 (Coprime divisibility combination).** If $m_1, \dots, m_k$ are pairwise coprime and each $m_i \mid P$, then $\bigl(\prod_i m_i\bigr) \mid P$.

*Proof.* By induction on $k$ using the fact that if $\gcd(m, m') = 1$, $m \mid P$, and $m' \mid P$, then $mm' \mid P$ (a consequence of unique factorization, or of Bézout). $\square$

### 4.2 The three prime factors

**Theorem 4.2.** For every integer $a$, $\;30 \mid (a^5 - a)$.

*Proof.* We show $2 \mid (a^5 - a)$, $3 \mid (a^5 - a)$, and $5 \mid (a^5 - a)$ separately; since $2, 3, 5$ are pairwise coprime with product $30$, Lemma 4.1 concludes.

- **Divisibility by $5$:** Theorem 3.1 (or 3.4 with $p = 5$).
- **Divisibility by $3$:** Theorem 3.4 with $p = 3$ gives $a^3 \equiv a \pmod 3$. Then $a^5 = a^2 \cdot a^3 \equiv a^2 \cdot a = a^3 \equiv a \pmod 3$. Alternatively, factor $a^5 - a = (a-1)a(a+1)(a^2+1)$; among the three consecutive integers $a-1, a, a+1$ one is divisible by $3$.
- **Divisibility by $2$:** Theorem 3.4 with $p = 2$ gives $a^2 \equiv a \pmod 2$, whence $a^5 = (a^2)^2 a \equiv a^2 \cdot a = a^3 \equiv a \pmod 2$. Alternatively, in the factorization $(a-1)a(a+1)(a^2+1)$ the factor $a(a-1)$ is a product of consecutive integers, hence even.

By Lemma 4.1, $30 = 2\cdot 3 \cdot 5$ divides $a^5 - a$. $\square$

### 4.3 Factorization structure

The polynomial $a^5 - a$ admits several factorizations, each illuminating a different divisibility:
$$a^5 - a = a(a^4 - 1) = a(a^2-1)(a^2+1) = (a-1)\,a\,(a+1)\,(a^2+1),$$
$$a^5 - a = (a^2 + 1)(a^3 - a), \qquad a^5 - a = (a^2 - a)(a^3 + a^2 + a + 1).$$
The first exposes the three consecutive integers governing the factors $2$ and $3$. The last two are the "palindromic" factorizations (note $a^3 + a^2 + a + 1$ is palindromic in its coefficients) that recur in the general theory of Section 6.

### 4.4 Maximality of $30$

**Proposition 4.3.** No integer larger than $30$ divides $a^5 - a$ for all integers $a$.

*Proof.* Let $D$ be a universal divisor. Evaluating at $a = 2$ gives $D \mid 30$. Since $30$ is itself universal by Theorem 4.2, the maximal universal divisor is exactly $30$. $\square$

## 5. General Theory: The Universal Divisor $D(n)$

**Definition 5.1 (Universal divisor).** For $n \ge 1$, let $D(n)$ be the largest positive integer dividing $a^n - a$ for every integer $a$: $D(n) = \gcd_{a \in \mathbb{Z}} (a^n - a)$.

**Theorem 5.2 (Structure of $D(n)$).** For $n \ge 2$, $D(n)$ is squarefree and equals
$$D(n) = \prod_{\substack{p \text{ prime} \\ (p-1)\,\mid\,(n-1)}} p.$$

*Proof sketch.* We determine, for each prime $p$ and each power $p^k$, whether $p^k \mid (a^n - a)$ for all $a$.

*(A prime $p$ divides $D(n)$ iff $(p-1)\mid(n-1)$.)* Working modulo $p$: for $a \equiv 0$ the divisibility is automatic. For $a \not\equiv 0$, $a$ lies in the cyclic group $(\mathbb{Z}/p\mathbb{Z})^\times$ of order $p-1$; the condition $a^n \equiv a$, i.e. $a^{n-1} \equiv 1$, holds for *all* such $a$ iff the exponent $n-1$ is a multiple of the group's exponent $p-1$, i.e. iff $(p-1)\mid(n-1)$. (Necessity uses the existence of a generator of order $p-1$.)

*(No prime square divides $D(n)$ for $n \ge 2$.)* Take $a = p$. Then $a^n - a = p^n - p = p(p^{n-1}-1)$, and since $p \nmid (p^{n-1}-1)$, we have $p^2 \nmid (a^n - a)$. Hence each prime appears to the first power at most, so $D(n)$ is squarefree.

Combining, $D(n)$ is the product of exactly those primes $p$ with $(p-1)\mid(n-1)$. $\square$

**Corollary 5.3.** $D(5) = 30$.

*Proof.* The primes $p$ with $(p-1)\mid 4$ satisfy $p-1 \in \{1,2,4\}$, i.e. $p \in \{2,3,5\}$; their product is $30$. $\square$

**Examples.**
- $D(2) = 2$ (primes with $(p-1)\mid 1$: only $p=2$).
- $D(3) = 6 = 2\cdot 3$ (primes with $(p-1)\mid 2$: $p \in \{2,3\}$).
- $D(5) = 30$; $D(7) = 42 = 2\cdot3\cdot7$; $D(9) = 30$; $D(13) = 2730 = 2\cdot3\cdot5\cdot7\cdot13$.

Note $D(n)$ depends only on the divisors of $n-1$, so e.g. $D(5) = D(9) = D(13\text{'s divisor pattern})$ whenever the sets $\{p : (p-1)\mid(n-1)\}$ coincide; in particular $D(5)=D(9)=30$ because $\{d : d \mid 4\} \supseteq$ the relevant $p-1$ values match.

## 6. Palindromic Factorizations for Odd Exponents

For odd $n$, the polynomial $a^n - a = a(a^{n-1} - 1)$ factors through cyclotomic-type symmetric factors. The observation that
$$a^5 - a = (a^2 - a)(a^3 + a^2 + a + 1) = (a^2+1)(a^3 - a)$$
displays two faces of one palindromic structure. The palindromic factor $a^3 + a^2 + a + 1 = (a+1)(a^2+1)$ synchronizes the small-prime divisibilities: its value at consecutive integers shares common factors that assemble into $D(n)$. Formalizing this — expressing $D(n)$ as a greatest common divisor of values of a palindromic factor at consecutive integers — is a natural direction for turning the ad-hoc two-factorization trick into a systematic tool.

## 7. Failure Modulo Prime Powers

The identity-map phenomenon $a^n \equiv a$ is intimately tied to the *field* structure of $\mathbb{Z}/p\mathbb{Z}$. It degenerates modulo $p^2$.

**Proposition 7.1.** Let $p$ be an odd prime. There is no exponent $n > 1$ with $a^n \equiv a \pmod{p^2}$ for all integers $a$.

*Proof sketch.* The group $(\mathbb{Z}/p^2\mathbb{Z})^\times$ is cyclic of order $p(p-1)$. A universal identity $a^{n-1}\equiv 1$ on units would require $p(p-1) \mid (n-1)$; but then $a = p$ gives $a^n - a = p^n - p$, and one checks $p^2 \mid p^n - p$ fails for the residue structure required, so no single $n$ makes the fixed-point property hold on all of $\mathbb{Z}/p^2\mathbb{Z}$. $\square$

This pinpoints where the method's central hypothesis — that we work over a field — is indispensable.

## 8. Probabilistic Interpretation

**Proposition 8.1.** Fix a prime $p$ and exponent $n$. If $a$ is drawn uniformly from $\{1, \dots, N\}$, then as $N \to \infty$ the proportion of $a$ with $p \mid (a^n - a)$ tends to $\dfrac{\gcd(n-1,\,p-1) + 1}{p}$. This equals $1$ exactly when $(p-1)\mid(n-1)$, and reduces to $1/p$ in the extreme case where no nontrivial unit qualifies.

*Proof sketch.* The solutions of $a^n \equiv a \pmod p$ are $a \equiv 0$ together with the solutions of $a^{n-1}\equiv 1$ among the units; the latter number exactly $\gcd(n-1, p-1)$ in the cyclic group $(\mathbb{Z}/p\mathbb{Z})^\times$. Hence there are $\gcd(n-1,p-1)+1$ qualifying residues out of $p$, and equidistribution of residues among $\{1,\dots,N\}$ gives the limiting density. When $(p-1)\mid(n-1)$ all $p-1$ units qualify and the density is $1$. $\square$

The universal divisor $D(n)$ is thus exactly the set of primes for which the "probability" of divisibility is not a probability at all, but a certainty.

## 9. Algorithms

We summarize the computational content (full implementations accompany this paper):

1. **Verify universal divisibility.** To confirm $m \mid (a^n - a)$ for all $a$, check residues $r \in \{0,\dots,m-1\}$ (Lemma 2.3). Complexity $O(m \log n)$ using fast modular exponentiation.
2. **Compute $D(n)$.** Enumerate primes $p$ up to $n$ (only $p \le n$ can satisfy $(p-1)\mid(n-1)$ nontrivially, plus $p=2$), test $(p-1)\mid(n-1)$, and multiply. Complexity dominated by primality testing up to $n$.
3. **Empirical GCD.** Compute $\gcd$ of $a^n - a$ over a range of $a$ to conjecture $D(n)$; converges rapidly.

## 10. Applications and Discussion

The divisibility $5 \mid (a^5-a)$ and its generalizations underpin primality testing (the Fermat test and its refinements), the design of check digits and error-detecting codes, and structural results in the theory of finite fields. The squarefree structure of $D(n)$ (Theorem 5.2) is the arithmetic backbone of Carmichael numbers and the Korselt criterion. The polynomial identity $a^p \equiv a$ over $\mathbb{Z}/p\mathbb{Z}$ is precisely the statement that the Frobenius endomorphism $x \mapsto x^p$ is the identity on the prime field — a cornerstone of algebraic number theory and arithmetic geometry.

## 11. Future Work

Natural next steps include: (i) proving the general squarefree-denominator theorem (Theorem 5.2) in full generality with sharp necessity arguments; (ii) making precise the palindromic-factor characterization of $D(n)$ for odd $n$; (iii) a complete classification of the failure of $a^n \equiv a$ modulo prime powers; and (iv) refined equidistribution estimates for the probabilistic interpretation, including error terms.

## 12. Conclusion

The elementary fact that $a^5 - a$ is divisible by $5$ — indeed by $30$ — is a window onto the structure of finite fields and the arithmetic of power-difference polynomials. Reducing an infinite family of integer statements to a finite modular check, and then explaining that check through the multiplicative group of a field, transforms a computational curiosity into a theorem with a transparent cause and a sweeping generalization: for every exponent $n$, the maximal universal divisor $D(n)$ is the squarefree product of the primes $p$ with $(p-1)\mid(n-1)$.
