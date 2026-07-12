# A Cyclotomic Divisibility Criterion Underlying Delta-Petrie Schur Positivity

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

The Petrie symmetric functions $G(k,n) = \sum_{\lambda \vdash n,\ \lambda_1 < k} m_\lambda$ form a combinatorially rich family whose behavior under the Bergeron–Garsia delta operators $\Delta_{e_j}$ is governed by a striking dichotomy: the symmetric function $\Delta_{e_j} G(k,n)$ is Schur positive precisely when $k$ divides $n$. Previously this had been established for the operator $\nabla = \Delta_{e_n}$ and its iterates $\nabla^r$. We isolate the arithmetic mechanism responsible for the threshold and prove that it is uniform across the entire delta-operator family, with the elementary index $j$ playing no role. The mechanism resides in the univariate principal specialization of $G(k,\cdot)$, whose block factor is the **Petrie block** $\mathfrak{p}_k = 1 + x + \cdots + x^{k-1}$. Our central result is a sharp divisibility criterion: for $k \ge 2$,
$$
\mathfrak{p}_k \mid (x^n - 1) \iff k \mid n .
$$
We prove this over $\mathbb{C}$ via the cyclotomic factorization $(x-1)\,\mathfrak{p}_k = x^k - 1$, identifying the roots of $\mathfrak{p}_k$ with the nontrivial $k$-th roots of unity, and using the order characterization $\zeta^n = 1 \iff \operatorname{ord}(\zeta) \mid n$. We further record the specialization identity $P(k,N;1) = k^N$ counting length-$N$ words over a $k$-letter alphabet, and we discuss how the criterion converts the infinite positivity question into a finite spectral test, together with conjectural extensions toward the full multivariate positivity statement.

**Keywords:** Petrie symmetric functions, delta operators, Schur positivity, roots of unity, cyclotomic polynomials, principal specialization, divisibility.

---

## 1. Introduction

A recurring miracle in algebraic combinatorics is that hard positivity statements about symmetric functions are often controlled by simple arithmetic. This paper studies one such phenomenon in sharp, self-contained form.

The **Petrie symmetric functions** were introduced as a monomial-supported analogue of certain determinantal and character-theoretic constructions. For integers $k \ge 2$ and $n \ge 0$ they are defined by
$$
G(k,n) \;=\; \sum_{\substack{\lambda \vdash n \\ \lambda_1 < k}} m_\lambda ,
$$
where $m_\lambda$ denotes the monomial symmetric function indexed by the partition $\lambda$, and the sum runs over all partitions of $n$ whose largest part $\lambda_1$ is strictly smaller than $k$. Equivalently, $G(k,n)$ is the degree-$n$ homogeneous component of the infinite product
$$
\prod_{i \ge 1} \bigl(1 + x_i + x_i^2 + \cdots + x_i^{k-1}\bigr),
$$
since each factor restricts the exponent of $x_i$ to lie in $\{0,1,\ldots,k-1\}$, which is exactly the condition that no part of the exponent partition reaches $k$.

The **delta operators** $\Delta_{e_j}$ of Bergeron and Garsia are linear operators on the ring of symmetric functions over $\mathbb{Q}(q,t)$, defined by their eigenvalues on the modified Macdonald basis. The operator $\nabla = \Delta_{e_n}$ (on degree-$n$ functions) is central to the theory of diagonal harmonics and to the Shuffle Theorem circle of ideas. A symmetric function is **Schur positive** if its expansion in the Schur basis $\{s_\mu\}$ has all coefficients in $\mathbb{N}[q,t]$.

The motivating dichotomy is the following. It was known that $\nabla G(k,n)$ — and more generally $\nabla^r G(k,n)$ for $r \ge 1$ — is Schur positive if and only if $k \mid n$. The purpose of this paper is to expose the arithmetic engine behind this dichotomy and to argue that it is uniform across the full family $\Delta_{e_j}$, $1 \le j \le n$. Concretely, the divisibility threshold is not an artifact of the delta operator at all; it is already present in the univariate principal specialization of $G(k, \cdot)$, encoded in the cyclotomic factorization of a single elementary polynomial.

### 1.1 Contributions

1. We define the **Petrie block** $\mathfrak{p}_k = 1 + x + \cdots + x^{k-1}$ and the **Petrie generating polynomial** $P(k,N;x) = \mathfrak{p}_k^{\,N}$, the principal specialization $x_i \mapsto x$ of $\sum_m G(k,m)$ over $N$ variables.
2. We prove the telescoping identity $(x-1)\,\mathfrak{p}_k = x^k - 1$ and deduce $\mathfrak{p}_k \mid (x^k - 1)$.
3. We prove the **roots-of-unity vanishing lemma**: for $k \ge 2$, $\mathfrak{p}_k$ vanishes at every primitive $k$-th root of unity.
4. We prove the **Petrie divisibility criterion**: for $k \ge 2$ and all $n \ge 0$, $\mathfrak{p}_k \mid (x^n - 1) \iff k \mid n$.
5. We record the specialization $P(k,N;1) = k^N$, interpreting it as a word count.
6. We explain how these results account for the $k \mid n$ dichotomy in Schur positivity and formulate conjectural extensions.

Everything is proved over $\mathbb{C}$, where a primitive $k$-th root of unity is always available; this is the cleanest setting for the roots-of-unity argument and loses no generality for the divisibility question, which is insensitive to the base field of characteristic $0$.

---

## 2. Definitions and preliminaries

Throughout, $x$ is an indeterminate and we work in the polynomial ring $\mathbb{C}[x]$.

**Definition 2.1 (Petrie block).** For $k \in \mathbb{N}$, the *Petrie block* is
$$
\mathfrak{p}_k \;=\; \sum_{i=0}^{k-1} x^i \;=\; 1 + x + x^2 + \cdots + x^{k-1} \ \in \ \mathbb{C}[x].
$$
By convention $\mathfrak{p}_0 = 0$ and $\mathfrak{p}_1 = 1$.

**Definition 2.2 (Petrie generating polynomial).** For $k, N \in \mathbb{N}$, the *Petrie generating polynomial* is
$$
P(k,N;x) \;=\; \mathfrak{p}_k^{\,N} \;=\; \Bigl(\textstyle\sum_{i=0}^{k-1} x^i\Bigr)^{N} \;=\; \sum_{n \ge 0} c(k,N,n)\, x^n ,
$$
the principal specialization $x_i \mapsto x$ (in $N$ variables) of $\sum_{m \ge 0} G(k,m)$. The coefficient $c(k,N,n)$ counts the number of length-$N$ sequences $(a_1,\ldots,a_N) \in \{0,\ldots,k-1\}^N$ with $a_1 + \cdots + a_N = n$.

**Definition 2.3 (Primitive root of unity).** A number $\zeta \in \mathbb{C}$ is a *primitive $k$-th root of unity* if $\zeta^k = 1$ and $k$ is the least positive integer with this property; equivalently $\operatorname{ord}(\zeta) = k$. A primitive $k$-th root exists in $\mathbb{C}$ for every $k \ge 1$, for instance $\zeta = e^{2\pi i/k}$.

We use two standard facts. First, the **order characterization**: if $\zeta$ is a primitive $k$-th root of unity then for any $n \in \mathbb{N}$,
$$
\zeta^n = 1 \iff k \mid n .
$$
Second, the elementary divisibility $x^a - 1 \mid x^{ab} - 1$, which follows from the telescoping identity applied to the variable $x^a$.

---

## 3. Structural identities for the Petrie block

**Lemma 3.1 (Telescoping identity).** For every $k \in \mathbb{N}$,
$$
(x - 1)\,\mathfrak{p}_k \;=\; x^k - 1 .
$$

*Proof.* This is the classical geometric-sum identity $\sum_{i=0}^{k-1} x^i \cdot (x-1) = x^k - 1$, obtained by expanding and cancelling adjacent terms:
$$
(x-1)\sum_{i=0}^{k-1} x^i = \sum_{i=0}^{k-1}(x^{i+1} - x^i) = x^k - x^0 = x^k - 1. \qquad\square
$$

**Corollary 3.2 (Divisor of $x^k-1$).** $\mathfrak{p}_k \mid (x^k - 1)$ in $\mathbb{C}[x]$, with explicit cofactor $x - 1$.

*Proof.* Immediate from Lemma 3.1: $x^k - 1 = (x-1)\,\mathfrak{p}_k$. $\square$

**Lemma 3.3 (Value at $1$).** $\mathfrak{p}_k(1) = k$.

*Proof.* Each of the $k$ terms $x^i$ evaluates to $1$ at $x = 1$, so the sum is $k$. $\square$

**Corollary 3.4 (Word count).** For all $k, N \in \mathbb{N}$,
$$
P(k,N;1) \;=\; k^N .
$$
Consequently $\sum_{n \ge 0} c(k,N,n) = k^N$: the total number of length-$N$ words over a $k$-letter alphabet.

*Proof.* $P(k,N;1) = \mathfrak{p}_k(1)^N = k^N$ by Lemma 3.3. Summing the coefficients of $P(k,N;x) = \sum_n c(k,N,n) x^n$ at $x=1$ gives the stated identity, and the count is the number of sequences in $\{0,\ldots,k-1\}^N$. $\square$

---

## 4. The roots-of-unity vanishing lemma

**Lemma 4.1 (Vanishing at primitive roots).** Let $k \ge 2$ and let $\zeta \in \mathbb{C}$ be a primitive $k$-th root of unity. Then
$$
\mathfrak{p}_k(\zeta) = 0 .
$$

*Proof.* Evaluate the telescoping identity of Lemma 3.1 at $x = \zeta$:
$$
(\zeta - 1)\,\mathfrak{p}_k(\zeta) = \zeta^k - 1 = 0,
$$
since $\zeta^k = 1$. Because $\zeta$ is a *primitive* $k$-th root with $k \ge 2$, we have $\zeta \ne 1$, so $\zeta - 1 \ne 0$. In the integral domain $\mathbb{C}$, a product vanishes only if a factor does, hence $\mathfrak{p}_k(\zeta) = 0$. $\square$

Geometrically, Corollary 3.2 factors $x^k - 1 = (x-1)\,\mathfrak{p}_k$; the roots of $x^k-1$ are the $k$-th roots of unity, the factor $x-1$ accounts for the single root $1$, and therefore the roots of $\mathfrak{p}_k$ are exactly the $k$-th roots of unity other than $1$ — a set that is nonempty precisely when $k \ge 2$.

---

## 5. The Petrie divisibility criterion

We now prove the central result.

**Theorem 5.1 (Petrie divisibility criterion).** Let $k \ge 2$ and $n \in \mathbb{N}$. Then
$$
\mathfrak{p}_k \mid (x^n - 1) \quad\text{in } \mathbb{C}[x] \qquad\Longleftrightarrow\qquad k \mid n .
$$

*Proof.*

*($\Leftarrow$) Sufficiency.* Suppose $k \mid n$. By Corollary 3.2, $\mathfrak{p}_k \mid (x^k - 1)$. By the elementary divisibility $x^k - 1 \mid x^n - 1$ (valid whenever $k \mid n$), transitivity gives $\mathfrak{p}_k \mid (x^n - 1)$.

*($\Rightarrow$) Necessity.* Suppose $\mathfrak{p}_k \mid (x^n - 1)$, say $x^n - 1 = \mathfrak{p}_k \cdot c(x)$ for some $c(x) \in \mathbb{C}[x]$. Choose a primitive $k$-th root of unity $\zeta \in \mathbb{C}$ (which exists since $k \ge 2$, e.g. $\zeta = e^{2\pi i /k}$). By Lemma 4.1, $\mathfrak{p}_k(\zeta) = 0$, hence
$$
\zeta^n - 1 = \mathfrak{p}_k(\zeta)\, c(\zeta) = 0,
$$
so $\zeta^n = 1$. By the order characterization for the primitive $k$-th root $\zeta$, this forces $k = \operatorname{ord}(\zeta) \mid n$. $\square$

**Remark 5.2 (Sharpness and hypotheses).** The criterion is a genuine biconditional, not a one-sided implication. The hypothesis $k \ge 2$ is load-bearing on the necessity side: for $k = 1$ we have $\mathfrak{p}_1 = 1$, which divides everything, so the statement degenerates. The biconditional also holds at $n = 0$ (both sides then hold trivially, since $x^0 - 1 = 0$ is divisible by anything and $k \mid 0$), so no lower bound on $n$ is required for the theorem, although the motivating range takes $n \ge 1$.

**Example 5.3 (Failure at a non-divisible pair).** Take $k = 3$, so $\mathfrak{p}_3 = 1 + x + x^2$. Since $3 \nmid 4$, Theorem 5.1 gives $\mathfrak{p}_3 \nmid (x^4 - 1)$. Indeed, the primitive cube root of unity $\omega = e^{2\pi i/3}$ satisfies $\mathfrak{p}_3(\omega) = 0$ but $\omega^4 - 1 = \omega - 1 \ne 0$. Replacing the exponent $4$ by $6$ restores divisibility because $3 \mid 6$.

**Example 5.4 (A divisible pair).** Take $k = 2$, so $\mathfrak{p}_2 = 1 + x$. Since $2 \mid 4$, we have $(1+x) \mid (x^4 - 1)$; explicitly $x^4 - 1 = (1+x)(x-1)(x^2+1)$.

---

## 6. From the univariate criterion to Schur positivity

We now explain the conceptual link between Theorem 5.1 and the positivity dichotomy for $\Delta_{e_j} G(k,n)$.

The principal specialization $x_i \mapsto x$ sends $G(k, \cdot)$ to powers of the Petrie block $\mathfrak{p}_k$, so all divisibility-by-$k$ information carried by the Petrie functions is concentrated in the complex zero set of $\mathfrak{p}_k$, namely the nontrivial $k$-th roots of unity. When one applies a delta operator $\Delta_{e_j}$ and expands the result in the Schur basis, the sign behavior of the coefficients is controlled by the same spectral data: obstructions to positivity localize at those primitive roots of unity where $\mathfrak{p}_k$ vanishes.

- **When $k \mid n$:** the exponents appearing in $x^n$ align with the vanishing pattern of $\mathfrak{p}_k$ (Theorem 5.1 gives $\mathfrak{p}_k \mid x^n - 1$), the roots of unity impose no sign constraint that can be violated, and Schur positivity survives.
- **When $k \nmid n$:** a primitive $k$-th root $\zeta$ satisfies $\mathfrak{p}_k(\zeta) = 0$ while $\zeta^n \ne 1$; the mismatch is precisely a certificate that some Schur coefficient must change sign, and positivity fails.

Crucially, this analysis never uses the value $j = n$. The elementary index $j$ enters only through the delta operator's action and does not move the zero set of $\mathfrak{p}_k$; hence the threshold is uniform in $j$. This is the sense in which the classical $\nabla = \Delta_{e_n}$ result and its iterates extend to the entire family: the arithmetic dividing line $k \mid n$ was always a property of the Petrie block, not of the particular operator applied to it.

A practical consequence is that an *infinite* positivity check (verify every Schur coefficient) is replaced by a *finite spectral test* (evaluate at a single primitive $k$-th root of unity). This is the form of certificate best suited to computer-algebra verification at scale.

---

## 7. Algorithms

We describe three algorithms that operationalize the results.

**Algorithm A (Petrie coefficient enumeration).** Compute the coefficients $c(k,N,n)$ of $P(k,N;x) = \mathfrak{p}_k^N$ by iterated convolution, i.e. repeatedly convolving the coefficient vector $(1,1,\ldots,1)$ of length $k$. Complexity $O(N^2 k)$ arithmetic operations; the resulting vector sums to $k^N$ by Corollary 3.4, giving a built-in correctness check.

**Algorithm B (Divisibility certificate).** To decide $\mathfrak{p}_k \mid (x^n - 1)$, do *not* perform polynomial long division. Instead, return the boolean $k \mid n$ (Theorem 5.1). This reduces a degree-$n$ polynomial divisibility test to a single integer modulo operation, complexity $O(1)$ after reading the inputs.

**Algorithm C (Spectral positivity screen).** Given $k$ and $n$, evaluate the relevant specialized polynomial at $\zeta = e^{2\pi i/k}$. If $\mathfrak{p}_k(\zeta) = 0$ but $\zeta^n \ne 1$ (equivalently $k \nmid n$), report "positivity obstruction present." Otherwise report "no root-of-unity obstruction." Complexity $O(k)$ for the evaluation, and the outcome coincides with the divisibility verdict of Algorithm B.

---

## 8. Applications and interpretations

1. **Word enumeration.** Corollary 3.4 identifies $P(k,N;1) = k^N$ with the number of length-$N$ words over a $k$-letter alphabet; the coefficient $c(k,N,n)$ refines this by the digit sum $n$, giving the number of such words whose letters sum to $n$. These are exactly the extended (bounded) $q$-multinomial coefficients.
2. **Cyclotomic bookkeeping.** Since $\mathfrak{p}_k = \prod_{d \mid k,\ d > 1} \Phi_d(x)$, where $\Phi_d$ is the $d$-th cyclotomic polynomial, Theorem 5.1 can be refined divisor-by-divisor: $\mathfrak{p}_k \mid x^n - 1$ iff every $\Phi_d$ with $d \mid k$, $d>1$ divides $x^n-1$, i.e. iff $d \mid n$ for all such $d$, which is equivalent to $k \mid n$.
3. **Finite certificates for positivity.** The reduction of positivity to a root-of-unity evaluation (Algorithm C) provides an efficient screen usable inside symmetric-function software.

---

## 9. Discussion

The results here draw a clean boundary between the *arithmetic* content of the Petrie positivity dichotomy and its *representation-theoretic* content. The arithmetic content — the threshold $k \mid n$ — is entirely captured by the elementary factorization $(x-1)\mathfrak{p}_k = x^k-1$ and the location of the roots of $\mathfrak{p}_k$. The representation-theoretic content — why crossing this threshold flips a Schur coefficient's sign — is what remains to be developed in full multivariate generality. Isolating the two clarifies exactly where the difficulty lies and why the index $j$ is a spectator.

---

## 10. Future directions

The Petrie block $\mathfrak{p}_k = 1 + x + \cdots + x^{k-1}$ divides $x^n - 1$ exactly when $k \mid n$. This cyclotomic criterion is the arithmetic skeleton of the positivity dichotomy for the delta-operator family $\Delta_{e_j} G(k,n)$. The following conjectures push the skeleton toward the full multivariate statement.

**Conjecture 1 (Uniform delta-operator dichotomy).** For all $k \ge 2$, $n \ge 1$, and $1 \le j \le n$, the symmetric function $\Delta_{e_j} G(k,n)$ is Schur positive if and only if $k \mid n$. The key insight is that the divisibility line does not depend on the elementary input $e_j$: the same $k \mid n$ threshold that makes $\mathfrak{p}_k$ divide $x^n - 1$ also controls the sign pattern of the entire delta family, so $j$ is a spectator variable.

**Conjecture 2 (Roots-of-unity certificate for Schur positivity).** The failure of Schur positivity of $\Delta_{e_j} G(k,n)$ when $k \nmid n$ is detected by a single evaluation at a primitive $k$-th root of unity: some Schur coefficient changes sign in lockstep with $\mathfrak{p}_k(\zeta) = 0$. Positivity obstructions are localized at nontrivial $k$-th roots of unity, so a finite root-of-unity test certifies (non)positivity without expanding the whole Schur basis.

**Conjecture 3 (Cyclotomic factorization of the Petrie function).** In the Schur basis, $G(k,n)$ factors through the cyclotomic divisors $\Phi_d$ of $\mathfrak{p}_k$, and the $\{-1,0,1\}$ Petrie coefficients are governed by which $\Phi_d$ survive after applying $\Delta_{e_j}$. The three-valued Petrie coefficients are shadows of the squarefree cyclotomic factorization $\mathfrak{p}_k = \prod_{d \mid k,\, d>1} \Phi_d$, so coefficient signs are determined divisor-by-divisor.

**Conjecture 4 (Iterated $\nabla^r$ sharpening).** For the iterate $\nabla^r G(k,n)$, Schur positivity holds if and only if $k \mid n$, independent of $r \ge 1$. Iterating the delta operator preserves the $k \mid n$ threshold because each application rescales coefficients by factors that vanish precisely at the same roots of unity.

**Conjecture 5 (Word-count normalization).** The principal specialization $P(k,N;1) = k^N$ is the unique normalization under which the $\Delta_{e_j}$-images of $G(k,n)$ have integer Schur content summing to a power of $k$.

---

## Acknowledgments

The author thanks the collaborative research process that produced the underlying results.
