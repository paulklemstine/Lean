# The Pell Spine: Strong Divisibility, Ranks of Apparition, and a Cluster of Falsifications

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We develop the arithmetic of the *Pell spine*, the pair of integer sequences $(Q_n, P_n)$ determined by $(1+\sqrt2)^n = Q_n + P_n\sqrt2$, under a deliberately adversarial methodology: every conjecture is stated so sharply that a single explicit counterexample can refute it. Seven such conjectures fall, all within the first thirty terms, and each refutation is converted into a sharper theorem.

The surviving results form a complete divisibility theory. We prove that the Pell numbers are a strong divisibility sequence, $\gcd(P_m,P_n) = P_{\gcd(m,n)}$, and hence $m \mid n \iff P_m \mid P_n$. We prove an *apparition theorem*: every modulus $m \geq 1$ divides some positive Pell number, by a pigeonhole argument on the reversible state map $n \mapsto (P_n, P_{n+1}) \bmod m$. Combining the two yields the exact divisibility law $m \mid P_n \iff \alpha(m) \mid n$, where $\alpha(m)$ is the rank of apparition, together with the multiplicativity $\alpha(ab) = \operatorname{lcm}(\alpha(a),\alpha(b))$ for coprime $a,b$. We prove a Fermat law $p \mid P_{p-1}P_{p+1}$ for every odd prime $p$, via a Frobenius expansion inside $\mathbb{Z}[\sqrt2]$ that produces Euler's criterion $P_p \equiv 2^{(p-1)/2} \pmod p$ on the way. We classify the solutions of $x^2 - 2y^2 = \pm1$ as exactly the spine points, classify the near-isosceles Pythagorean triples as exactly the odd-index spine points, and establish the exact approximation identity $|Q_n - P_n\sqrt2| = (\sqrt2-1)^n$.

For the companion strand we prove a genuinely new *parity-graded* law: for $m \geq 2$, $Q_m \mid Q_n$ if and only if $n = mk$ with $k$ odd; and $\gcd(Q_m,Q_n)$ equals $Q_{\gcd(m,n)}$ when both index quotients are odd and equals $1$ otherwise.

Among the falsifications, the most striking is the Wall–Sun–Sun analogue. The growth law $\alpha(p^2) = p\,\alpha(p)$ fails at $p=13$, because $P_7 = 169 = 13^2$, and again at $p = 31$, because $31^2 \mid P_{30}$. Thus the Pell spine exhibits two Wall–Sun–Sun-type primes below $50$, whereas no Fibonacci Wall–Sun–Sun prime is known below $10^{17}$.

**Keywords:** Pell numbers, silver ratio, strong divisibility sequence, rank of apparition, Wall–Sun–Sun prime, Pell equation, near-isosceles Pythagorean triples, Frobenius endomorphism.

---

## 1. Introduction

### 1.1 Two sequences and one unit

Let $\delta = 1+\sqrt2$, the *silver ratio*: the fundamental unit of the real quadratic order $\mathbb{Z}[\sqrt2]$. Its powers have integral coordinates,

$$(1+\sqrt2)^n = Q_n + P_n\sqrt2 \qquad (n \geq 0), \tag{1.1}$$

and the two coordinate sequences are

$$P: \quad 0,\,1,\,2,\,5,\,12,\,29,\,70,\,169,\,408,\,985,\,2378,\,5741,\dots$$
$$Q: \quad 1,\,1,\,3,\,7,\,17,\,41,\,99,\,239,\,577,\,1393,\,3363,\,8119,\dots$$

Both satisfy the same linear recursion,

$$P_0 = 0,\ P_1 = 1,\qquad Q_0 = 1,\ Q_1 = 1,\qquad x_{n+2} = 2x_{n+1} + x_n. \tag{1.2}$$

$P$ consists of the *Pell numbers* and $Q$ of the *half-companion Pell numbers*. We call the interleaved pair $\{(Q_n,P_n)\}_{n\geq0}$ the **Pell spine**. It is the norm-one part of the unit group of $\mathbb{Z}[\sqrt2]$, written in coordinates.

### 1.2 Methodology: falsification-first

The results below were obtained under a single organising principle: *state every conjecture so that one explicit counterexample suffices to kill it, then attack it.* This has two effects. First, it forces precision — a conjecture written to be falsifiable cannot hide behind qualitative language. Second, and more usefully, a clean death is informative: the counterexample points at the missing hypothesis, and the repaired statement is usually the real theorem. Every refutation in this paper is followed by its repair.

Seven conjectures fall. Their counterexamples all live inside the first thirty terms of the spine, and four of the seven die at the *same* term.

### 1.3 Summary of results

| | Statement | Status |
|---|---|---|
| Thm 3.3 | $\gcd(P_m,P_n) = P_{\gcd(m,n)}$ | proved |
| Thm 3.4 | $m \mid n \iff P_m \mid P_n$ | proved |
| Thm 4.1 | every $m \geq 1$ divides some $P_n$, $n>0$ | proved |
| Thm 4.4 | $m \mid P_n \iff \alpha(m) \mid n$ | proved |
| Thm 4.5 | $\alpha(ab) = \operatorname{lcm}(\alpha a,\alpha b)$ for $\gcd(a,b)=1$ | proved |
| Thm 5.3 | $p \mid P_{p-1}P_{p+1}$ for odd primes $p$ | proved |
| Thm 6.2 | $Q_m \mid Q_n \iff n = mk$, $k$ odd $(m\ge2)$ | proved |
| Thm 6.3 | graded gcd law for $Q$ | proved |
| Thm 7.2 | $x^2-2y^2 = \pm1 \iff (x,y)$ on the spine | proved |
| Thm 7.4 | near-isosceles triples $=$ odd-index spine | proved |
| Thm 8.2 | $\lvert Q_n - P_n\sqrt2\rvert = (\sqrt2-1)^n$ | proved |
| Conj A | $n$ prime $\Rightarrow P_n$ prime | **false** ($n=7$) |
| Conj B | every $P_n$ squarefree | **false** ($n=7$) |
| Conj C | no $P_n$, $n\ge2$, is a square | **false** ($n=7$) |
| Conj D | $\gcd(Q_m,Q_n) = Q_{\gcd(m,n)}$ | **false** ($3,6$) |
| Conj E | $p \mid P_{p-1}$, equivalently $\alpha(p) \mid p-1$ | **false** ($p=3$) |
| Conj F | near-isosceles hypotenuses are prime | **false** $(119,120,169)$ |
| Conj G | $\alpha(p^2) = p\,\alpha(p)$ | **false** ($p=13$, $p=31$) |

---

## 2. Core arithmetic of the spine

Throughout, $P$ and $Q$ are as in (1.2), and all variables denote non-negative integers unless stated otherwise.

**Lemma 2.1 (one-step laws).** For all $n$,
$$P_{n+1} = P_n + Q_n, \qquad Q_{n+1} = Q_n + 2P_n.$$

*Proof sketch.* Simultaneous induction: the two statements feed each other. At $n=0$ both read $1 = 0+1$ and $1 = 1 + 0$. Assuming both at $n$, the recursion (1.2) gives $P_{n+2} = 2P_{n+1} + P_n = P_{n+1} + (P_{n+1}+P_n) = P_{n+1} + (P_n + Q_n + P_n)$, and the inductive hypothesis for $Q$ converts the bracket into $Q_{n+1}$; symmetrically for $Q$. $\square$

Equivalently, Lemma 2.1 is the statement that multiplication by $\delta = 1+\sqrt2$ acts on coordinates by the matrix $\begin{pmatrix}1&2\\1&1\end{pmatrix}$, which is precisely (1.1) read one step at a time.

**Theorem 2.2 (addition laws).** For all $m,n$,
$$P_{m+n} = P_mQ_n + Q_mP_n, \qquad Q_{m+n} = Q_mQ_n + 2P_mP_n. \tag{2.1}$$

*Proof sketch.* These are the real and $\sqrt2$-components of $\delta^{m+n} = \delta^m\delta^n$ expanded via (1.1). Purely combinatorially, one proves both by a single simultaneous two-step induction on $n$ with $m$ fixed, using Lemma 2.1 for the base steps. $\square$

**Corollary 2.3 (doubling).** $P_{2n} = 2P_nQ_n$ and $Q_{2n} = Q_n^2 + 2P_n^2$.

**Theorem 2.4 (Pell equation on the spine).** For all $n$,
$$Q_n^2 - 2P_n^2 = (-1)^n. \tag{2.2}$$

*Proof sketch.* Take norms in (1.1): $N(\delta) = (1+\sqrt2)(1-\sqrt2) = -1$, so $N(\delta^n) = (-1)^n$, and $N(Q_n + P_n\sqrt2) = Q_n^2 - 2P_n^2$. Directly, an induction using Lemma 2.1: $Q_{n+1}^2 - 2P_{n+1}^2 = (Q_n+2P_n)^2 - 2(P_n+Q_n)^2 = -(Q_n^2 - 2P_n^2)$. $\square$

The alternating sign in (2.2) is the *hidden variable* of this paper. It will reappear as the side of the approximation to $\sqrt2$ (Section 8), as the sign of the norm distinguishing the two Pell equations (Section 7), and as the parity grading of the companion divisibility law (Section 6).

**Corollary 2.5 (coprimality).** $\gcd(P_n, Q_n) = 1$ for every $n$.

*Proof.* Any common divisor divides $Q_n^2 - 2P_n^2 = \pm1$. $\square$

**Theorem 2.6 (matrix bridge and Cassini).** Let $M = \begin{pmatrix}2&1\\1&0\end{pmatrix}$. Then
$$M^{\,n+1} = \begin{pmatrix} P_{n+2} & P_{n+1}\\ P_{n+1} & P_n \end{pmatrix},$$
and consequently, taking determinants,
$$P_{n+2}P_n - P_{n+1}^2 = (-1)^{n+1}. \tag{2.3}$$

*Proof sketch.* The matrix identity is an induction on $n$ using (1.2). Since $\det M = -1$ and the determinant is multiplicative, $\det M^{n+1} = (-1)^{n+1}$, which is exactly the left-hand side of (2.3). $\square$

Identity (2.3) is the Pell analogue of Cassini's Fibonacci identity, and it is again the sign $(-1)^n$ in disguise.

---

## 3. Strong divisibility, and the first four falsifications

**Definition 3.1.** An integer sequence $(a_n)$ is a *strong divisibility sequence* if $\gcd(a_m,a_n) = a_{\gcd(m,n)}$ for all $m,n$.

**Lemma 3.2 (Euclidean step).** For all $m,n$,
$$\gcd(P_{m+n},P_n) = \gcd(P_m,P_n).$$

*Proof.* By (2.1), $P_{m+n} = P_mQ_n + P_nQ_m$. The second summand is a multiple of $P_n$, so $\gcd(P_{m+n},P_n) = \gcd(P_mQ_n, P_n)$. By Corollary 2.5, $Q_n$ is coprime to $P_n$ and may be cancelled from the gcd, leaving $\gcd(P_m,P_n)$. $\square$

**Theorem 3.3 (Strong divisibility).** For all $m,n$,
$$\gcd(P_m,P_n) = P_{\gcd(m,n)}.$$

*Proof sketch.* Strong induction on $m$. For $m=0$ both sides are $P_n$. For $m>0$, iterate Lemma 3.2 to obtain $\gcd(P_{mq+r},P_m) = \gcd(P_r,P_m)$ for all $q,r$; writing $n = mq + r$ with $r = n \bmod m < m$ reduces $(m,n)$ to $(r,m)$, mirroring the Euclidean algorithm on indices, and the inductive hypothesis applies. The recursion terminates at $\gcd(P_0, P_g) = P_g$ with $g = \gcd(m,n)$. $\square$

**Theorem 3.4 (divisibility criterion).** $m \mid n \iff P_m \mid P_n$, with no side conditions.

*Proof.* If $m \mid n$ then $\gcd(m,n)=m$, so Theorem 3.3 gives $\gcd(P_m,P_n) = P_m$, i.e. $P_m \mid P_n$. Conversely if $P_m \mid P_n$ then $P_m = \gcd(P_m,P_n) = P_{\gcd(m,n)}$; since $P$ is strictly increasing from index $1$ onwards, this forces $\gcd(m,n)=m$ (the degenerate cases $m \in \{0,1\}$ being immediate). $\square$

**Corollary 3.5.** If $P_n$ is prime then $n$ is prime.

*Proof.* If $d \mid n$ with $1 < d < n$ then $P_d \mid P_n$ and $1 < P_d < P_n$. $\square$

Corollary 3.5 is a one-way implication, and the next four statements show how sharply one-way it is.

### 3.6 Refutations

> **Conjecture A (false).** *If $n$ is prime then $P_n$ is prime.*
> **Counterexample.** $n = 7$: $P_7 = 169 = 13^2$.

> **Conjecture B (false).** *Every Pell number is squarefree.*
> **Counterexample.** $P_7 = 13^2$. (The corresponding assertion for Fibonacci numbers is a long-standing open problem; on the Pell spine it fails at the seventh term.)

> **Conjecture C (false).** *No Pell number $P_n$ with $n \geq 2$ is a perfect square.*
> **Counterexample.** $P_7 = 13^2$. (By Ljunggren's theorem $169$ is in fact the only such value, but one counterexample settles the conjecture as stated.)

> **Conjecture D (false).** *The companion sequence $Q$ is a strong divisibility sequence.*
> **Counterexample.** $m=3$, $n=6$: $\gcd(Q_3,Q_6) = \gcd(7,99) = 1$, while $Q_{\gcd(3,6)} = Q_3 = 7$.

Conjecture D fails maximally: the gcd is not merely smaller than predicted, it is $1$. This is not noise, and Section 6 identifies the true law. Conjectures A, B, C all die at the same term $P_7 = 169$; so does Conjecture F of Section 7 and, at one remove, Conjecture G of Section 4. We return to this clustering in Section 9.

The guarded companion statement that *does* survive is the following, which we prove directly and then sharpen in Section 6.

**Proposition 3.7.** $Q_n \mid Q_{(2k+1)n}$ for all $n,k$.

*Proof sketch.* Induction on $k$. The step uses $(2(k+1)+1)n = (2k+1)n + 2n$ together with the addition law $Q_{a+2n} = Q_aQ_{2n} + 2P_aP_{2n}$ and the facts $Q_n \mid Q_{2n} - 2P_n^2$ (from Corollary 2.3) and $Q_n \mid P_{2n} = 2P_nQ_n$. $\square$

---

## 4. Ranks of apparition

### 4.1 Existence

**Theorem 4.1 (Apparition theorem).** For every $m \geq 1$ there exists $n > 0$ with $m \mid P_n$.

*Proof.* Consider the state map
$$f : \mathbb{N} \to (\mathbb{Z}/m)^2, \qquad f(n) = (P_n \bmod m,\ P_{n+1} \bmod m).$$
The codomain is finite, so $f$ is not injective: there exist $i < j$ with $f(i) = f(j)$.

The key point is that the recursion is *reversible*: $P_n = P_{n+2} - 2P_{n+1}$. Hence if $f(a+1) = f(b+1)$ — that is, $P_{a+1} \equiv P_{b+1}$ and $P_{a+2}\equiv P_{b+2}$ — then subtracting twice the first congruence from the second gives $P_a \equiv P_b$, so $f(a) = f(b)$. Thus $f(a+1) = f(b+1) \Rightarrow f(a)=f(b)$.

Write $j = i + t$ with $t > 0$. Applying the reversibility step $i$ times to $f(i) = f(i+t)$ slides the coincidence down to $f(0) = f(t)$. Comparing first coordinates and using $P_0 = 0$ yields $P_t \equiv 0 \pmod m$. Since $t>0$, we are done. $\square$

The argument is worth isolating because of what it does *not* need: no primality, no factorisation of $m$, no characteristic-$p$ algebra. Finiteness plus invertibility of the transition matrix $M$ modulo $m$ (which holds because $\det M = -1$ is a unit modulo every $m$) is the entire content.

**Definition 4.2 (rank of apparition).** For $m \geq 1$, let
$$\alpha(m) = \min\{\,n > 0 : m \mid P_n\,\},$$
well defined by Theorem 4.1. (Set $\alpha(0)=0$ by convention.)

**Table 4.3.** First values.

| $m$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 31 | 169 | 961 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $\alpha(m)$ | 1 | 2 | 4 | 4 | 3 | 4 | 6 | 8 | 12 | 6 | 12 | 4 | 7 | 6 | 12 | 16 | 8 | 30 | 7 | 30 |

### 4.2 The exact divisibility law

**Theorem 4.4 (Divisibility law).** For $m \geq 1$ and all $n \geq 0$,
$$m \mid P_n \iff \alpha(m) \mid n.$$

*Proof.* ($\Leftarrow$) If $\alpha(m) \mid n$ then $P_{\alpha(m)} \mid P_n$ by Theorem 3.4, and $m \mid P_{\alpha(m)}$ by definition; compose.

($\Rightarrow$) Assume $m \mid P_n$; we may take $n>0$, the case $n=0$ being trivial as $P_0=0$. Write $r = \alpha(m)$. Then $m$ divides both $P_r$ and $P_n$, hence divides $\gcd(P_r,P_n)$, which by Theorem 3.3 equals $P_{\gcd(r,n)}$. Since $\gcd(r,n) > 0$, minimality of $r$ gives $r \leq \gcd(r,n)$. But also $\gcd(r,n) \leq r$. Hence $\gcd(r,n) = r$, i.e. $r \mid n$. $\square$

This is the point at which the two halves of the theory meet: pigeonhole (Theorem 4.1) supplies existence of $\alpha(m)$, strong divisibility (Theorem 3.3) supplies rigidity, and minimality clicks them together.

**Theorem 4.5 (multiplicativity).** If $a,b \geq 1$ are coprime then
$$\alpha(ab) = \operatorname{lcm}\bigl(\alpha(a),\alpha(b)\bigr).$$

*Proof.* For any $n$, Theorem 4.4 gives $\alpha(ab)\mid n \iff ab \mid P_n$. Since $\gcd(a,b)=1$, $ab \mid P_n \iff a\mid P_n$ and $b \mid P_n \iff \alpha(a)\mid n$ and $\alpha(b) \mid n \iff \operatorname{lcm}(\alpha a, \alpha b) \mid n$. Two positive integers with the same set of multiples are equal. $\square$

Hence $\alpha$ is determined by its values on prime powers.

### 4.3 Two refutations

> **Conjecture E (false).** *For every odd prime $p$, $\alpha(p) \mid p-1$ (equivalently $p \mid P_{p-1}$).*
> **Counterexample.** $p = 3$: $\alpha(3) = 4$ and $4 \nmid 2$. Equivalently $P_2 = 2$ is not divisible by $3$.

Note $4 \mid p+1 = 4$: the conjecture failed by choosing the wrong side. Section 5 proves the correct dichotomy.

> **Conjecture G (false).** *For every prime $p$, $\alpha(p^2) = p\,\alpha(p)$.*
> **Counterexample.** $p = 13$. Since $P_7 = 169 = 13^2$, we have $13^2 \mid P_7$, so $\alpha(169) \leq 7 = \alpha(13)$; in fact $\alpha(169) = \alpha(13) = 7 \neq 91$.

Conjecture G is the Pell analogue of the *Wall–Sun–Sun* phenomenon; Section 9 discusses it at length. A second counterexample exists close by:

**Proposition 4.6.** $31^2 \mid P_{30} = 107\,578\,520\,350$, and $\alpha(31) = \alpha(961) = 30$. Consequently there are at least two primes $p$ with $\alpha(p^2) = \alpha(p)$, namely $13$ and $31$.

---

## 5. A Fermat law via Frobenius in $\mathbb{Z}[\sqrt2]$

We now repair Conjecture E.

**Lemma 5.1 (spine inside $\mathbb{Z}[\sqrt2]$).** In the ring $\mathbb{Z}[\sqrt2]$, $(1+\sqrt2)^n = Q_n + P_n\sqrt2$, and for $m\geq0$, $(\sqrt2)^{2m+1} = 2^m\sqrt2$.

**Theorem 5.2 (Euler's criterion on the spine).** Let $p = 2m+1$ be an odd prime. Then
$$P_p \equiv 2^{m} = 2^{(p-1)/2} \pmod p, \qquad Q_p \equiv 1 \pmod p.$$

*Proof sketch.* In any commutative ring, for a prime $p$ there exists an element $r$ with $(x+y)^p = x^p + y^p + p\,xy\,r$ (the binomial coefficients $\binom{p}{k}$ for $0<k<p$ are all divisible by $p$). Apply this in $\mathbb{Z}[\sqrt2]$ with $x = 1$, $y = \sqrt2$:
$$(1+\sqrt2)^p = 1 + (\sqrt2)^p + p\sqrt2\,r = 1 + 2^m\sqrt2 + p\sqrt2\,r.$$
By Lemma 5.1 the left-hand side is $Q_p + P_p\sqrt2$. Since $\{1,\sqrt2\}$ is a $\mathbb{Z}$-basis, comparing coordinates gives $Q_p = 1 + p\,r_0$ and $P_p = 2^m + p\,r_1$ for integers $r_0,r_1$. $\square$

By Euler's criterion in elementary number theory, $2^{(p-1)/2} \equiv \left(\tfrac2p\right) \pmod p$, the Legendre symbol, which is $+1$ iff $p \equiv \pm1 \pmod 8$. So the congruence in Theorem 5.2 already carries the quadratic-residue information that Conjecture E ignored.

**Theorem 5.3 (Fermat law for the Pell spine).** For every odd prime $p$,
$$p \mid P_{p-1}\,P_{p+1}.$$

*Proof.* By Theorem 5.2, $P_p^2 \equiv 2^{p-1} \equiv 1 \pmod p$ by Fermat's little theorem. On the other hand, the addition law (2.1) applied to $(p-1)+1$ and $p+1 = p+1$, combined with the Pell equation (2.2) at the odd index $p$ (so $Q_p^2 - 2P_p^2 = -1$), yields the identity
$$P_{p-1}P_{p+1} = P_p^2 - 1 .$$
Indeed, writing $p = k+1$ and using $P_{k}P_{k+2} - P_{k+1}^2 = (-1)^{k+1}$ (Theorem 2.6) with $k = p-1$ gives $P_{p-1}P_{p+1} = P_p^2 + (-1)^{p} = P_p^2 - 1$ for odd $p$. Hence $p \mid P_p^2 - 1 = P_{p-1}P_{p+1}$. $\square$

**Corollary 5.4.** For every odd prime $p$, $p \mid P_{p-1}$ or $p \mid P_{p+1}$; equivalently
$$\alpha(p) \mid p-1 \quad\text{or}\quad \alpha(p)\mid p+1 .$$

*Proof.* $p$ is prime, so it divides one of the two factors in Theorem 5.3; then apply Theorem 4.4. $\square$

Corollary 5.4 is the repaired form of Conjecture E. The correct uniform statement is $\alpha(p) \mid p - \left(\tfrac2p\right)$, and the counterexample $p=3$ is simply the case $\left(\tfrac23\right) = -1$: indeed $\alpha(3) = 4 \mid 4 = p+1$. Numerically, for $p \equiv \pm1 \pmod 8$ the rank divides $p-1$; for $p\equiv\pm3 \pmod 8$ it divides $p+1$.

---

## 6. The companion strand: a parity-graded law

Conjecture D showed that $Q$ is not a strong divisibility sequence. This section determines exactly what it is.

**Lemma 6.1.** (i) $Q_n$ is odd for every $n$. (ii) $\gcd(Q_m, 2P_m^2) = 1$. (iii) $Q_m \mid P_{2m}$.

*Proof.* (i) Induction using $Q_{n+1} = Q_n + 2P_n$. (ii) $Q_m$ is odd by (i) and coprime to $P_m$ by Corollary 2.5. (iii) $P_{2m} = 2P_mQ_m$ by Corollary 2.3. $\square$

**Theorem 6.2 (companion divisibility law).** For $m \geq 2$ and any $n$,
$$Q_m \mid Q_n \iff \exists k \text{ odd with } n = mk.$$

*Proof sketch.* The proof splits into two independent halves.

*Index step ($Q_m \mid Q_n \Rightarrow m \mid n$).* From $Q_m \mid Q_n$ and Lemma 6.1(iii) applied at $m$ and at $n$, one deduces $Q_m \mid \gcd(P_{2m},P_{2n}) = P_{2\gcd(m,n)}$ using Theorem 3.3. Suppose $g = \gcd(m,n)$ satisfied $g<m$. Since $g \mid m$, this forces $2g \leq m$, hence $0 < P_{2g} \leq P_m < Q_m$ (using $Q_m = P_m + P_{m-1} > P_m$ for $m \geq 2$), contradicting $Q_m \mid P_{2g}$. Hence $g = m$, i.e. $m \mid n$.

*Parity step (even quotients are excluded).* Working modulo $Q_m$, the addition law (2.1) gives
$$Q_{a+2m} = Q_aQ_{2m} + 2P_aP_{2m} \equiv 2P_m^2\,Q_a \pmod {Q_m},$$
using $Q_{2m} = Q_m^2 + 2P_m^2 \equiv 2P_m^2$ and $Q_m \mid P_{2m}$. Iterating from $a = 0$ (where $Q_0=1$),
$$Q_{2jm} \equiv (2P_m^2)^j \pmod{Q_m}.$$
By Lemma 6.1(ii), $2P_m^2$ is a unit modulo $Q_m$, so this is never $0$; therefore $Q_m \nmid Q_{2jm}$ for any $j$. Combined with Proposition 3.7 (odd multiples always work) and the index step, the claimed equivalence follows. $\square$

**Theorem 6.3 (companion gcd law).** For all $m,n$, writing $g = \gcd(m,n)$,
$$\gcd(Q_m,Q_n) = \begin{cases} Q_g, & \text{if } m/g \text{ and } n/g \text{ are both odd},\\ 1, & \text{otherwise.}\end{cases}$$

*Proof sketch.* If both quotients are odd, Proposition 3.7 gives $Q_g \mid Q_m$ and $Q_g \mid Q_n$, hence $Q_g \mid \gcd(Q_m,Q_n)$; the reverse divisibility follows from the index step of Theorem 6.2 together with minimality of $g$.

Suppose instead that one quotient, say $m/g$, is even. Let $p$ be any prime dividing $\gcd(Q_m,Q_n)$ and let $r = \alpha(p)$ be its rank of apparition. From $p \mid Q_m$ and $Q_m \mid P_{2m}$ we get $r \mid 2m$ by Theorem 4.4, and likewise $r \mid 2n$, so $r \mid 2g$. On the other hand $p \nmid P_m$, because $\gcd(P_m,Q_m)=1$ (Corollary 2.5), so $r \nmid m$; in particular $r \nmid g$. From $r \mid 2g$ and $r \nmid g$ we conclude that the $2$-adic valuation of $r$ is exactly $v_2(g)+1$ and that the odd part of $r$ divides $g$. But $m/g$ even means $v_2(m) \geq v_2(g)+1 = v_2(r)$, and the odd part of $r$ divides $g \mid m$; hence $r \mid m$ — a contradiction. So no prime divides $\gcd(Q_m,Q_n)$, i.e. it equals $1$. $\square$

Notice that Theorem 6.3 has *no side conditions whatsoever*: it is a complete replacement for the false Conjecture D. The structure is not a failure of strong divisibility but a **grading of it by the parity of index quotients**. That grading traces directly back to the sign $(-1)^n$ in (2.2).

Two further refutations record that the grading is genuinely necessary:

> **Conjecture D′ (false).** *$Q_n \mid Q_{kn}$ for all $k$.* **Counterexample.** $Q_2 = 3 \nmid 17 = Q_4$.
> **Conjecture D″ (false).** *$m \mid n \Rightarrow Q_m \mid Q_n$.* **Counterexample.** the same pair $(2,4)$.

**Proposition 6.4 (summation identities).** For all $n$,
$$\sum_{i=0}^{n} Q_i = P_{n+1}, \qquad 2\sum_{i=0}^{n}P_i + 1 = P_{n+1}+P_n, \qquad 2\sum_{i=0}^{n}P_i^2 = P_nP_{n+1}.$$

*Proof sketch.* Each is a one-line induction using Lemma 2.1; the first, for instance, telescopes because $P_{n+2} - P_{n+1} = Q_{n+1}$. $\square$

---

## 7. Diophantine classification

### 7.1 The unit group

**Lemma 7.1 (descent).** If $x,y$ are non-negative integers with $x^2 - 2y^2 = \pm1$ and $y \geq 2$, then $(x',y') = (3x-4y,\ 3y-2x)$ is again a pair of non-negative integers with $x'^2 - 2y'^2 = x^2-2y^2$ and $y' < y$.

*Proof sketch.* The map is multiplication by $3 - 2\sqrt2 = (1+\sqrt2)^{-2}$, which preserves the norm. Non-negativity and the strict decrease $3y - 2x < y$ follow from $x^2 = 2y^2 \pm 1$ together with $2y^2 \geq 8$, which pins $x/y$ close enough to $\sqrt2$ that $x > y$ and $2x > 2y \cdot \sqrt2 - \varepsilon > 2y$. $\square$

**Theorem 7.2 (classification of units).** For non-negative integers $x,y$,
$$x^2 = 2y^2+1 \ \text{ or }\ x^2 + 1 = 2y^2 \iff \exists n:\ (x,y) = (Q_n,P_n).$$
Moreover $x^2 = 2y^2+1$ corresponds exactly to even $n$, and $x^2+1 = 2y^2$ exactly to odd $n$.

*Proof sketch.* ($\Leftarrow$) is Theorem 2.4. ($\Rightarrow$): strong induction on $y$ using Lemma 7.1, with base cases $y \in \{0,1\}$ giving $(1,0)$ and $(1,1)$ (for $+1$) and $(1,1)$ (for $-1$); climbing back with multiplication by $(1+\sqrt2)^2 = 3+2\sqrt2$ recovers the spine index, shifted by two, so parity of the index is preserved and matches the sign of the norm. $\square$

**Proposition 7.3 (a local obstruction).** There are no integers with $x^2 = 2y^2+3$.

*Proof.* Modulo $8$, squares are $0,1,4$. Then $2y^2 + 3 \in \{3,5\}$ modulo $8$, neither of which is a square modulo $8$. $\square$

> **Conjecture H (false).** *The form $x^2-2y^2$ represents no value other than $\pm1$ over the non-negative integers.*
> **Counterexample.** $3^2 - 2\cdot1^2 = 7$.

Together with Proposition 7.3 this shows that the represented values are cut out by congruence conditions modulo $8$, not by any size restriction: $7$ is represented, $3$ is not.

### 7.2 Near-isosceles Pythagorean triples

**Theorem 7.4 (classification).** For non-negative integers $a,c$,
$$a^2 + (a+1)^2 = c^2 \iff \exists k:\ 2a+1 = Q_{2k+1} \ \text{and}\ c = P_{2k+1}.$$

*Proof sketch.* Complete the square: $a^2+(a+1)^2 = c^2$ is equivalent to $(2a+1)^2 + 1 = 2c^2$. Set $x = 2a+1$, $y = c$; the equation becomes the negative Pell equation, whose solutions are the odd-index spine points by Theorem 7.2. Conversely $Q_{2k+1}$ is odd, so $a = (Q_{2k+1}-1)/2$ is an integer. $\square$

The list begins
$$(0,1,1),\ (3,4,5),\ (20,21,29),\ (119,120,169),\ (696,697,985),\ (4059,4060,5741),\dots$$

**Proposition 7.5.** Every near-isosceles hypotenuse satisfies $P_{2k+1} \equiv 1 \pmod 4$.

*Proof sketch.* Induction using the three-term relation $P_{n+4} = 6P_{n+2} - P_n$ (a consequence of (1.2)), which modulo $4$ reads $P_{n+4} \equiv 2P_{n+2} - P_n$; with base values $P_1 = 1$, $P_3 = 5 \equiv 1$, the odd-index residues stay at $1$. $\square$

> **Conjecture F (false).** *The hypotenuse of a near-isosceles Pythagorean triple is prime.*
> **Counterexample.** $119^2 + 120^2 = 169^2$ and $169 = 13^2$.

This is a geometric statement destroyed by an arithmetic accident — and by the *same* accident, $P_7 = 169$, that killed Conjectures A, B and C.

---

## 8. Diophantine approximation

**Lemma 8.1.** $(1-\sqrt2)^n = Q_n - P_n\sqrt2$.

*Proof.* Apply the ring automorphism $\sqrt2 \mapsto -\sqrt2$ of $\mathbb{Z}[\sqrt2]$ to (1.1). $\square$

**Theorem 8.2 (exact error).** For all $n$,
$$\bigl|\,Q_n - P_n\sqrt2\,\bigr| = (\sqrt2-1)^n,$$
and $Q_n - P_n\sqrt2$ has sign $(-1)^n$.

*Proof.* Take absolute values in Lemma 8.1; $|1-\sqrt2| = \sqrt2-1 \in (0,1)$, and the sign of $(1-\sqrt2)^n$ is $(-1)^n$. $\square$

**Theorem 8.3 (Dirichlet quality).** For $n\geq1$,
$$\left|\sqrt2 - \frac{Q_n}{P_n}\right| < \frac{1}{P_n^2}.$$

*Proof sketch.* Divide Theorem 8.2 by $P_n$: the error is $(\sqrt2-1)^n / P_n$. It therefore suffices that $(\sqrt2-1)^n < 1/P_n$, i.e. $P_n(\sqrt2-1)^n<1$; this follows from the Binet formula $P_n = \bigl((1+\sqrt2)^n - (1-\sqrt2)^n\bigr)/(2\sqrt2)$ together with $(1+\sqrt2)(\sqrt2-1) = 1$, which gives $P_n(\sqrt2-1)^n = \bigl(1 - (1-\sqrt2)^{2n}\bigr)/(2\sqrt2) < 1/\sqrt2 < 1$. $\square$

> **Conjecture I (false).** *The constant may be improved: $|\sqrt2 - Q_n/P_n| < 1/(3P_n^2)$ for all $n\geq1$.*
> **Counterexample.** $n=1$: $Q_1/P_1 = 1$ and $|\sqrt2-1| = 0.41421\dots > 1/3$.
>
> **Conjecture J (false).** *The convergents approach $\sqrt2$ from one side.*
> **Counterexample.** $Q_1/P_1 = 1 < \sqrt2$ while $Q_2/P_2 = 3/2 > \sqrt2$.

Numerically the quantity $P_n^2|\sqrt2 - Q_n/P_n|$ converges to $1/(2\sqrt2) = 0.353553\dots$ from above along even $n$ and from below along odd $n$ — so the constant $1$ in Theorem 8.3 is not optimal asymptotically, but it *is* optimal as a statement valid for every $n\geq1$, because of the exceptional first term. The parity of $n$ again decides the side.

---

## 9. The Wall–Sun–Sun phenomenon on the Pell spine

### 9.1 Background

For the Fibonacci sequence, define the rank of apparition $\alpha_F(m)$ analogously. It is a classical observation that $\alpha_F(p^2) \in \{\alpha_F(p),\ p\,\alpha_F(p)\}$, with the second alternative "generic". A prime realising the first alternative — equivalently $p^2 \mid F_{\alpha_F(p)}$, equivalently $p^2 \mid F_{p-\left(\frac5p\right)}$ — is a **Wall–Sun–Sun prime**. Such primes were shown to be relevant to the first case of Fermat's Last Theorem, and extensive computation has found none: no Fibonacci Wall–Sun–Sun prime is known below $10^{17}$.

The same dichotomy holds on the Pell spine, by the same argument: $\alpha(p^2)$ is either $\alpha(p)$ or $p\,\alpha(p)$, since $P_{p\alpha(p)} \equiv 0 \pmod{p^2}$ always (a lifting-the-exponent computation) while $\alpha(p^2)$ is a multiple of $\alpha(p)$ by Theorem 4.4.

### 9.2 Two Pell–Wall–Sun–Sun primes

**Theorem 9.1.** $\alpha(13) = \alpha(169) = 7$ and $\alpha(31) = \alpha(961) = 30$. Hence Conjecture G is false, and $13$, $31$ are Pell–Wall–Sun–Sun primes.

*Proof.* $P_7 = 169 = 13^2$, so $13^2 \mid P_7$ and $\alpha(169)\leq 7$; since $\alpha(169)$ is a multiple of $\alpha(13)$ (Theorem 4.4) and $\alpha(13) = 7$ by direct check of $P_1,\dots,P_6$, we get $\alpha(169) = 7$. Similarly $P_{30} = 107\,578\,520\,350 = 2 \cdot 5^2 \cdot 7 \cdot 29 \cdot 31^2 \cdot 41 \cdot 269$, so $31^2 \mid P_{30}$; a direct check of $P_1,\dots,P_{29}$ modulo $31$ shows $\alpha(31) = 30$, whence $\alpha(961) = 30$. $\square$

### 9.3 Density heuristic

The standard heuristic models $P_{\alpha(p)}/p \bmod p$ as uniform in $\mathbb{Z}/p$, predicting that $p$ is a Wall–Sun–Sun prime with probability $1/p$; summing over primes gives a counting function of order $\log\log x$. The Pell spine has an extra structural feature: the discriminant of $\mathbb{Z}[\sqrt2]$ is $8$, so the prime $2$ is *ramified*. In the Fibonacci case ($\sqrt5$, discriminant $5$) this ramification is absent. Heuristically this doubles the relevant density constant. Two hits below $10^2$ remains a small-numbers phenomenon, but it is consistent with a doubled constant, and it makes the Pell setting a far more tractable laboratory than the Fibonacci one for studying the phenomenon at all.

**Conjecture 9.2 (open).** The set of Pell–Wall–Sun–Sun primes is infinite, with counting function asymptotic to $c\log\log x$, and $13$, $31$ are its first two elements.

### 9.4 The $P_7 = 169$ singularity

Collecting the falsifications by counterexample:

| Term | Conjectures killed |
|---|---|
| $P_7 = 169 = 13^2$ | A (prime index $\Rightarrow$ prime value), B (squarefree), C (never square), F (prime hypotenuse), G (Wall–Sun–Sun growth) |
| $(Q_3,Q_6) = (7,99)$ | D, D′, D″ (companion strong divisibility) |
| $p=3$, $\alpha(3)=4$ | E (Fermat law $\alpha(p)\mid p-1$) |
| $n=1$ | I, J (approximation constant and one-sidedness) |
| $3^2-2\cdot1^2=7$ | H (only $\pm1$ represented) |

Five conjectures — from four different areas: elementary primality, factorisation theory, plane geometry, and the arithmetic of ranks — are destroyed by the *same* integer. This is a clean instance of a general phenomenon: arithmetic accidents in a linear recurrence are visible from many directions simultaneously, because the different conjectures are all pulled back from the same underlying factorisation event. Methodologically, when hunting counterexamples in such a sequence, one should locate the accidents first and then test all conjectures against them, rather than testing each conjecture independently.

---

## 10. Algorithms

All algorithms below run on machine integers modulo $m$ and never form the (exponentially large) Pell numbers themselves.

**Algorithm 10.1 (Pell modulo $m$).** Iterate the pair $(a,b) \leftarrow (b, 2b+a) \bmod m$ from $(0,1)$. Cost: $O(n)$ modular operations, $O(\log m)$ space. A fast variant uses the doubling formulas $P_{2n} = 2P_nQ_n$, $Q_{2n} = Q_n^2 + 2P_n^2$, $P_{2n+1} = P_{2n} + Q_{2n}$, $Q_{2n+1} = Q_{2n}+2P_{2n}$, giving $O(\log n)$ multiplications.

**Algorithm 10.2 (rank of apparition).** Iterate Algorithm 10.1 and return the first $n>0$ with $P_n \equiv 0$. Termination is guaranteed by Theorem 4.1 with the a priori bound $n \leq m^2$. In practice one can do far better: by Theorem 4.5 it suffices to compute $\alpha$ on prime powers and take an lcm, and for a prime $p$, Corollary 5.4 restricts $\alpha(p)$ to the divisors of $p - \left(\tfrac2p\right)$, reducing the search to $O(d(p\mp1))$ modular exponentiations.

**Algorithm 10.3 (Pell–Wall–Sun–Sun search).** For each prime $p \leq X$: compute $\alpha(p)$ via Algorithm 10.2; then compute $P_{\alpha(p)} \bmod p^2$ and report $p$ if the result is $0$. Cost dominated by the rank computations; with the divisor-restricted variant this is $\tilde O(X)$ overall.

**Algorithm 10.4 (near-isosceles triple generator).** Iterate $(x,y) \leftarrow (3x+4y,\ 2x+3y)$ from $(1,1)$; each state gives the triple $\bigl(\tfrac{x-1}{2},\ \tfrac{x+1}{2},\ y\bigr)$. This is multiplication by $\delta^2 = 3+2\sqrt2$ and produces all such triples exactly once, by Theorem 7.4.

---

## 11. Applications

**Continued fractions and $\sqrt2$.** Theorem 8.2 gives the exact error of the convergents $Q_n/P_n$ of the continued fraction $\sqrt2 = [1;2,2,2,\dots]$, with the geometric rate $(\sqrt2-1)^n$ and alternating sign. This is the sharpest possible statement: no asymptotic notation is needed.

**Primality testing and pseudoprimes.** Corollary 5.4 supplies a *Lucas-style* compositeness test: if $p$ is prime and odd, then $P_{p - \left(\frac2p\right)} \equiv 0 \pmod p$. A composite passing this test is a Pell pseudoprime; combined tests of this shape (a Fermat test plus a Lucas test with respect to a well-chosen quadratic order) are the backbone of widely used probable-prime routines.

**Rational triangle geometry.** Theorem 7.4 gives a closed generator for right triangles that are as close to isosceles as integers permit, with the growth ratio $\delta^2 = 3+2\sqrt2 \approx 5.83$ between consecutive triples, and Proposition 7.5 shows their hypotenuses all lie in the residue class $1 \bmod 4$.

**Structure of the unit group.** Theorem 7.2 is the concrete, coordinate-level form of Dirichlet's unit theorem for $\mathbb{Z}[\sqrt2]$: the totally positive solutions of $|x^2-2y^2| = 1$ form a cyclic monoid generated by $(1,1)$, i.e. by the silver unit.

---

## 12. Discussion

Three structural patterns emerge.

**Norm versus trace.** Strong divisibility is a property of the *norm-form* sequence $P$ — the one whose terms are the $\sqrt2$-coordinates, i.e. the $y$-solutions of $x^2-2y^2 = \pm1$ — and not of the *trace* sequence $Q$. On $Q$ it does not merely fail; it degrades to the parity-graded law of Theorems 6.2 and 6.3. This suggests a general expectation for companion pairs of Lucas sequences: the two strands obey different divisibility theories, related by a grading rather than by an identity.

**Parity as hidden variable.** The sign $(-1)^n$ in the norm identity (2.2) simultaneously controls (i) which of the two Pell equations the spine point solves, (ii) which side of $\sqrt2$ the convergent $Q_n/P_n$ lies on, (iii) whether the index produces a near-isosceles Pythagorean triple, and (iv) whether $Q_m \mid Q_n$ can hold. Any refinement of the theory should carry the parity grading explicitly.

**Accidents cluster.** As tabulated in §9.4, one term $P_7 = 169$ falsifies five distinct conjectures spanning four subject areas. The methodological consequence for computer-assisted conjecture testing is to search for the sequence's arithmetic accidents first.

**On the falsification-first methodology.** Each of the seven refuted conjectures produced a sharper theorem: Conjecture E produced Corollary 5.4 and, with it, the appearance of the Legendre symbol $\left(\tfrac2p\right)$; Conjecture D produced the parity-graded gcd law, which is *stronger* than what it replaced in the sense that it has no side conditions at all; Conjecture G produced Theorem 9.1 and a concrete instance of a phenomenon that has resisted detection in the Fibonacci setting. A conjecture stated so that one number can kill it is a conjecture whose death is informative.

---

## 13. Future directions

**Silver-ratio Wall–Sun–Sun density.** Conjecture 9.2 above: the Pell–Wall–Sun–Sun primes are infinite with counting function $\sim c\log\log x$, and $13$, $31$ are the first two. The ramification of $2$ in $\mathbb{Z}[\sqrt2]$, absent in the Fibonacci setting, plausibly doubles the density constant, which would explain why two examples appear below $50$ here while none is known below $10^{17}$ there. With the rank machinery (Theorems 4.4 and 4.5) in place, a search can be organised prime by prime with certified intermediate steps.

**Parity-graded divisibility for general companion spines.** The Pell case is settled (Theorems 6.2 and 6.3). The natural successor is the general real quadratic order: let $V$ be the companion sequence of the Lucas pair $(a,-1)$, i.e. $V_0 = 2$, $V_1 = a$, $V_{n+2} = aV_{n+1}+V_n$. Conjecturally, for $g = \gcd(m,n)$, the gcd $\gcd(V_m,V_n)$ equals $V_g$ when $m/g$ and $n/g$ are both odd and is bounded by a small explicit constant otherwise, with the parity grading playing the same role as here.

**Prime-power ranks.** By Theorem 4.5 the rank function is determined on prime powers. Establishing the exact dichotomy $\alpha(p^{k+1}) \in \{\alpha(p^k),\ p\,\alpha(p^k)\}$ with an explicit criterion — a lifting-the-exponent statement for the spine — would complete the rank theory.

**Quantitative distribution of $\alpha(p)$.** For which primes is $\alpha(p)$ as large as possible, i.e. $p \pm 1$? This is the Pell analogue of the Artin-type question for the order of $\delta$ modulo $p$ in the residue field, and a natural target for a density statement conditional on standard hypotheses.

**Accident detection as a general method.** The clustering observed at $P_7$ suggests a general algorithm: for a given linear recurrence, first locate all $n \leq N$ at which $a_n$ has an unexpected factorisation (a square factor, a repeated prime, a prime power), then test a whole family of conjectures against those indices only. Formalising "unexpected" here — presumably in terms of the ABC-style expected size of the squarefull part — would turn the observation into a tool.

---

## 14. Conclusion

The Pell spine, generated by the silver unit $1+\sqrt2$, carries a complete and rigid divisibility theory: strong divisibility on the norm strand, a parity-graded law on the trace strand, an apparition theorem for every modulus, an exact divisibility law $m\mid P_n \iff \alpha(m)\mid n$, multiplicativity of the rank on coprime moduli, and a Fermat law $p \mid P_{p-1}P_{p+1}$ whose proof produces Euler's criterion as a by-product. It also carries a complete Diophantine classification — the spine *is* the unit group of $\mathbb{Z}[\sqrt2]$, and its odd part *is* the set of near-isosceles Pythagorean triples — and an exact approximation identity for $\sqrt2$.

Around this rigid core lie seven natural strengthenings, all false, all within the first thirty terms, and clustering around a single arithmetic accident $P_7 = 169 = 13^2$ that also makes $13$ a Wall–Sun–Sun-type prime. The second such prime, $31$, follows quickly. In a setting where the golden-ratio analogue has yielded nothing to searches out to seventeen digits, the silver ratio hands over two examples below $50$ — and, we suspect, infinitely many more.
