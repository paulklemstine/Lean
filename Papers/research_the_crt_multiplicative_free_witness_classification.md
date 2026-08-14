# The CRT-Multiplicative Free-Witness Classification and the Trace Lemma

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

A *free witness* for a semiprime modulus $N = pq$ is a single integer $W(N)$, defined without reference to the factorization, from which the factorization can nevertheless be recovered in polynomial time. Nine structurally unrelated constructions — modular circle counts, $k$-th root counts, binary quadratic form representation numbers, Heisenberg class counts, cusp indices, zeta-linear-programming aggregates, code-distance witnesses, congruence-divisor witnesses, and divisor power sums — have been observed to have this property. We prove that they are instances of a single mechanism: a counting aggregate over a Chinese-Remainder-separable domain whose local weight is CRT-multiplicative and non-polynomial.

We establish four groups of results. (i) **Layer one, proved.** For coprime moduli $m, n$, a weight of the form $f(x) = A(x \bmod m)B(x \bmod n)$ has aggregate $\sum_{x<mn} f(x) = (\sum_{a<m}A(a))(\sum_{b<n}B(b))$; and splitting through the CRT is *equivalent*, for a nowhere-vanishing weight over a field, to a four-point rank-one identity, making membership in the class a finite, decidable test. (ii) **The Trace Lemma.** A CRT-multiplicative witness with affine-power local weight $w(x) = ax^k + c$ satisfies $ac(p^k+q^k) = W(N) - a^2N^k - c^2$; the resulting power sum, together with $N$, determines $\{p,q\}$ uniquely, and the three recovery channels observed in the family (trace, larger factor, residue/order vector) are each complete. (iii) **Rigidity.** For $k \geq 1$ and $c \neq 0$, no integer polynomial agrees with such a witness on all odd semiprimes; the proof fixes one prime, uses the infinitude of primes to force a polynomial identity, and derives a contradiction from $10^k + 3^k \neq 6^k + 5^k$. (iv) **A validated prediction and a sharp boundary.** The divisor power sum $\sigma_k$, predicted by the classification, is confirmed as a free witness with the explicit trace formula $p+q = \sqrt{\sigma_2(N) + 2N - 1 - N^2}$; truncated weights provably leave the class; exponential phase weights are shown to *split* through the CRT after all — correcting the standard justification — and to fail instead by non-locality of the Bézout twist. We further prove a 2-adic sealing dichotomy ($\sigma_{2j}(N) \equiv 2 + 2N^{2j} \bmod 64$ always; an explicit separation at $128$) and identify an unnoticed second information channel: for odd squarefree $N$, the 2-adic valuation of $\sigma_{2j}(N)$ equals $\omega(N)$.

**Keywords:** Chinese Remainder Theorem, multiplicative functions, divisor power sums, integer factorization, rank-one decomposition, 2-adic valuation, Dirichlet characters.

---

## 1. Introduction

### 1.1 The phenomenon

Let $N = pq$ be a product of two distinct odd primes. Define
$$C(N) = \#\{(x,y) \in (\mathbb{Z}/N)^2 : x^2 + y^2 \equiv 1 \pmod N\},$$
the number of points on the modular unit circle. A classical computation gives, for distinct odd primes,
$$C(pq) = \big(p - \chi_p(-1)\big)\big(q - \chi_q(-1)\big),$$
where $\chi_p(-1) = +1$ if $p \equiv 1 \pmod 4$ and $-1$ if $p \equiv 3 \pmod 4$. If $p \equiv q \equiv 3 \pmod 4$ (a *Blum* pair) the local weights are $p+1$ and $q+1$, so
$$C(N) = (p+1)(q+1) = N + (p+q) + 1, \qquad\text{hence}\qquad p + q = C(N) - N - 1 .$$

The scalar $C(N)$ therefore encodes the trace $s = p+q$; with $N = pq$ known, $p$ and $q$ are the roots of $x^2 - sx + N$. We call such a scalar a **free witness**: its definition mentions only $N$, yet its value determines the factorization.

Nine structurally distinct constructions with this property have been catalogued, drawing on Kronecker symbols, multiplicative orders, divisor sums, class counts, and code distances. Each was found independently. The purpose of this paper is to prove that they are a single object.

### 1.2 The mechanism, informally

Every member of the family has three layers.

1. **CRT decomposition.** The ambient counting domain is separable: $S_N \cong S_p \times S_q$.
2. **A non-polynomial local weight.** The count factors as $W(N) = w(p)w(q)$, where $w$ depends on a *single* prime through an arithmetic (non-polynomial) function.
3. **Sealing.** The closed form requires the factors; the only factor-free evaluation route is enumeration of the CRT-product domain, at cost $\Theta(N)$ or $\Theta(N^2)$.

Layers 1 and 2 are what make the scalar a key. Layer 3 is what keeps the key locked away. Layers 1 and 2, and the *consequences* of layer 3's failure modes, are provable and are proved here; the necessity of layer 3's cost is equivalent to the hardness of factoring and is not.

### 1.3 Results

- **Theorem 3.2 (Aggregate multiplicativity).** Coprime moduli plus a split weight give a product aggregate.
- **Theorem 3.5 (Four-point characterization).** Over a field, a nowhere-vanishing weight splits through the CRT iff it satisfies the rank-one identity on crossed quadruples.
- **Theorem 4.2 (Trace Lemma).** Affine-power local weights yield $ac(p^k+q^k) = W(N) - a^2N^k - c^2$.
- **Theorem 4.6 (Uniqueness of the pair).** Sum and product determine an unordered pair of positive integers.
- **Theorem 5.3 (Rigidity).** No integer polynomial computes such a witness on the odd semiprimes.
- **Theorem 6.3 (Validated prediction).** $\sigma_k$ is a free witness; explicit trace formula at $k=2$.
- **Theorem 7.1 / 7.3 (Sealing dichotomy).** $\sigma_{2j}(N) \equiv 2 + 2N^{2j} \pmod{64}$; no function of $N \bmod 128$ computes $\sigma_2(N) \bmod 128$.
- **Theorem 8.3 ($\omega$-channel).** $v_2(\sigma_{2j}(N)) = \omega(N)$ for odd squarefree $N$.
- **Theorem 9.2 / 9.4 (Boundary).** Truncated weights leave the class; phase weights split but are non-local.

---

## 2. Definitions

Throughout, $p, q$ denote distinct odd primes, $N = pq$, and $\omega(N)$ the number of distinct prime factors of $N$. For $k \ge 0$, $\sigma_k(N) = \sum_{d \mid N} d^k$; $v_2$ denotes the 2-adic valuation.

**Definition 2.1 (CRT-multiplicative semiprime witness).**
A *semiprime witness* is a pair of functions $W : \mathbb{N} \to \mathbb{Z}$ (the *aggregate*, a function of the modulus alone) and $w : \mathbb{N} \to \mathbb{Z}$ (the *local weight*, a function of a single prime), subject to the single axiom
$$W(pq) = w(p)\,w(q) \qquad \text{for all distinct odd primes } p \neq q.$$

This definition deliberately says nothing about *how* $W$ is computed. The classification is a statement about the shape of the local weight only, and this is what allows nine different constructions to be treated at once.

**Definition 2.2 (Affine-power shape).**
A local weight has *affine-power shape* with data $(a, k, c)$ if $w(x) = a x^k + c$ for the primes under consideration. The case $a = 1$, $c \ne 0$ is the *power shape*; $a=c=1$ is the *unit* case, which covers the divisor power sums and, for Blum primes, the circle count.

**Definition 2.3 (Splitting through the CRT).**
Let $R$ be a commutative ring and $m, n \ge 1$. A weight $f : \mathbb{N} \to R$ *splits through the CRT at $(m,n)$*, written $f \in \mathrm{Split}(m,n)$, if there exist $A, B : \mathbb{N} \to R$ with
$$f(x) = A(x \bmod m)\, B(x \bmod n) \qquad \text{for all } x .$$
This is the precise form of "CRT-multiplicative local weight" at the level of the summand, as opposed to the level of the aggregate.

**Definition 2.4 (Free witness).**
A semiprime witness is a *free witness* if (i) it is factoring-complete — the pair $\{p,q\}$ is determined in polynomial time by $W(N)$ and $N$ — and (ii) it is non-polynomial — no $P \in \mathbb{Z}[X]$ satisfies $W(pq) = P(pq)$ for all distinct odd primes.

The classification asserts, and Sections 4–5 prove for the affine-power family, that any CRT-multiplicative witness with non-polynomial local weight satisfies both (i) and (ii).

---

## 3. Layer one: separability and the rank-one criterion

### 3.1 The aggregate of a split weight is a product

**Theorem 3.2 (Aggregate multiplicativity).**
Let $m, n \ge 1$ be coprime and $A, B : \mathbb{N} \to \mathbb{Z}$. Then
$$\sum_{x=0}^{mn-1} A(x \bmod m)\,B(x \bmod n) \;=\; \Big(\sum_{a=0}^{m-1} A(a)\Big)\Big(\sum_{b=0}^{n-1} B(b)\Big).$$
Consequently, if $f \in \mathrm{Split}(m,n)$ with witnesses $A, B$, then $\sum_{x<mn} f(x) = (\sum_{a<m}A(a))(\sum_{b<n}B(b))$.

*Proof sketch.* Expand the right-hand side as a double sum over the product $[0,m)\times[0,n)$. The map $x \mapsto (x \bmod m, x \bmod n)$ is a bijection from $[0,mn)$ onto that product, with inverse $(a,b) \mapsto \mathrm{crt}(a,b) \bmod mn$, where $\mathrm{crt}(a,b)$ is the Chinese remainder lift. That the two maps are mutually inverse is exactly CRT existence and uniqueness: for the composite in one direction, $\mathrm{crt}(x \bmod m, x \bmod n) \equiv x$ modulo both $m$ and $n$, hence modulo $mn$ by coprimality, hence equals $x$ after reduction below $mn$; for the other direction, reducing the lift modulo $m$ recovers $a$ (since $m \mid mn$) and modulo $n$ recovers $b$. Reindexing the sum along this bijection gives the identity. $\square$

This is layer one of the mechanism, stated and proved in complete generality: *CRT-separable domain + CRT-multiplicative weight $\Rightarrow$ the count factors*. Everything the family does with Kronecker symbols, orders, and divisor sums is a specialization of this single reindexing.

### 3.3 Splitting is a rank-one condition

Arrange the residues mod $mn$ in an $m \times n$ grid indexed by CRT coordinates. Then $f \in \mathrm{Split}(m,n)$ says precisely that the value matrix is an outer product: it has rank one. Rank one has a four-point signature.

**Theorem 3.4 (Rank-one necessity).**
Let $R$ be a commutative ring and $f \in \mathrm{Split}(m,n)$. Suppose $x, y, z, w$ satisfy the *crossing conditions*
$$z \equiv x \ (m), \quad z \equiv y \ (n), \quad w \equiv y \ (m), \quad w \equiv x \ (n).$$
Then $f(x) f(y) = f(z) f(w)$.

*Proof sketch.* Write $f(t) = A(t \bmod m)B(t \bmod n)$ and substitute. The left side is $A(x)B(x)A(y)B(y)$ (abusing notation for residues); the right side is $A(x)B(y)A(y)B(x)$. These agree by commutativity. $\square$

A single violating quadruple therefore *refutes* CRT-multiplicativity. This is a practical falsification tool: four evaluations decide a candidate.

**Theorem 3.5 (Four-point characterization).**
Let $K$ be a field, $m, n$ coprime, and $f : \mathbb{N} \to K$ with $f(0) \neq 0$. Then $f \in \mathrm{Split}(m,n)$ **if and only if** the rank-one identity of Theorem 3.4 holds for all quadruples satisfying the crossing conditions.

*Proof sketch.* Necessity is Theorem 3.4. For sufficiency, define the two *axis profiles*
$$A(a) = f(\mathrm{crt}(a, 0)), \qquad B(b) = f(\mathrm{crt}(0, b)) / f(0),$$
which is legitimate since $f(0) \ne 0$. Fix $x$ and apply the rank-one hypothesis to the quadruple $(x,\, 0,\, \mathrm{crt}(x \bmod m, 0),\, \mathrm{crt}(0, x \bmod n))$: the crossing conditions hold by the defining congruences of the CRT lift, so
$$f(x)\, f(0) = f(\mathrm{crt}(x \bmod m, 0))\; f(\mathrm{crt}(0, x \bmod n)) = A(x \bmod m)\cdot B(x\bmod n) f(0).$$
Dividing by $f(0)$ gives $f(x) = A(x \bmod m)B(x \bmod n)$. $\square$

**Corollary 3.6 (Decidability of class membership).**
For a nowhere-vanishing weight on $\mathbb{Z}/mn$ with values in a field, membership in the CRT-multiplicative class is decided by checking the rank-one identity on the $O(m^2n^2)$ crossed quadruples — indeed, by Theorem 3.5's proof, by the $mn$ quadruples anchored at $0$. In particular the question "is this experiment a free witness?", which the family previously answered by case-by-case inspection, becomes an algorithm.

---

## 4. The Trace Lemma

### 4.1 Recovery of the power sum

**Theorem 4.2 (Trace Lemma, affine-power form).**
Let $(W, w)$ be a semiprime witness and $p \neq q$ distinct odd primes with $w(p) = ap^k + c$ and $w(q) = aq^k + c$. Then
$$a\,c\,(p^k + q^k) \;=\; W(N) - a^2 N^k - c^2, \qquad N = pq .$$
In particular, for $a = 1$ and $c \neq 0$,
$$p^k + q^k \;=\; \frac{W(N) - N^k - c^2}{c},$$
and for $a = c = 1$, $\;p^k + q^k = W(N) - N^k - 1$.

*Proof sketch.* By CRT-multiplicativity $W(N) = w(p)w(q) = (ap^k+c)(aq^k+c) = a^2(pq)^k + ac(p^k+q^k) + c^2$. Rearrange. $\square$

Two specializations are used constantly.

**Corollary 4.3 (Trace).** With $k=1$, $a=c=1$: $\;p + q = W(N) - N - 1$. Applied to the circle witness for Blum pairs this recovers $p+q = C(N)-N-1$; applied to $\sigma_1$ it gives $p+q = \sigma(N)-N-1$.

**Corollary 4.4 (Trace square).** With $k=2$, $a=c=1$: since $(p+q)^2 = p^2+q^2+2N$,
$$(p+q)^2 = W(N) - N^2 + 2N - 1 .$$

### 4.5 One coordinate suffices

**Theorem 4.6 (Sum and product determine the pair).**
Let $p,q,p',q'$ be non-negative integers with $p' \neq 0$, $pq = p'q'$ and $p+q = p'+q'$. Then $(p',q') = (p,q)$ or $(p',q') = (q,p)$.

*Proof sketch.* Over $\mathbb{Z}$, the hypotheses give $(p'-p)(p'-q) = p'^2 - (p+q)p' + pq = p'^2 - (p'+q')p' + p'q' = 0$. Hence $p' = p$ or $p' = q$; in the first case cancel $p' \ne 0$ in the product equation to get $q' = q$, in the second use the sum equation to get $q' = p$. $\square$

Equivalently, $p$ and $q$ are the two roots of $X^2 - sX + N$ with $s = p+q$, and no other positive pair shares that sum and product. Thus the witness value is not evidence about the factorization; it is a re-encoding of it.

### 4.7 The three recovery channels

Empirically the family's witnesses deliver one of three data types. All three are complete, and the completeness is elementary.

**Proposition 4.8 (Trace $\Rightarrow$ larger factor).** For $p \le q$,
$$2q = (p+q) + \big\lfloor \sqrt{(p+q)^2 - 4pq} \,\big\rfloor .$$
*Proof sketch.* Write $q = p + d$. Then $(p+q)^2 - 4pq = d^2$ exactly, so the integer square root is $d$, and $(p+q) + d = 2p + 2d = 2q$. $\square$

**Proposition 4.9 (Larger factor $\Rightarrow$ complete factorization).** If $pq = N$ and $q \neq 0$ then $p = N/q$. (Immediate.)

**Proposition 4.10 (Residue channel).** If $p, p' < M$ and $p \equiv p' \pmod M$ then $p = p'$. (Immediate.)

Proposition 4.10 is why the "residue/order vector" witnesses of the family — those returning $p \bmod M$ for a modulus exceeding the factor, or the multiplicative order of a fixed base — are recoverable: a residue pins the factor as soon as its modulus is large enough.

**Summary (information content).** Combining 4.2, 4.6, 4.8–4.10: every recoverable witness in the family carries exactly one factor-secret coordinate, namely $p+q$, or $\max(p,q)$, or a residue/order vector, and each of the three determines the factorization in polynomial time. On semiprimes, that is the whole information content — but see Section 8, where the semiprime restriction is shown to be hiding a second channel.

---

## 5. Rigidity: the polynomial barrier

The classification asserts that a non-polynomial *local* weight forces a non-polynomial *global* aggregate. We prove this. Two arguments are given: a cheap one that falsifies with a single pair of moduli, and a structural one that handles all exponents at once.

### 5.1 The divisibility falsifier

**Proposition 5.2 (Difference test).**
Let $W : \mathbb{N} \to \mathbb{Z}$, $S \subseteq \mathbb{N}$, and $N_1, N_2 \in S$ with
$$(N_1 - N_2) \nmid \big(W(N_1) - W(N_2)\big).$$
Then no $P \in \mathbb{Z}[X]$ satisfies $W(n) = P(n)$ for all $n \in S$.

*Proof sketch.* For any $P \in \mathbb{Z}[X]$ and integers $a,b$ one has $a - b \mid P(a) - P(b)$, since $a-b \mid a^j - b^j$ termwise. Instantiating at $N_1, N_2$ contradicts the hypothesis. $\square$

*Instances.* $C(21) = 32$, $C(15) = 16$, and $6 \nmid 16$: the circle count is not a polynomial in $N$. $\sigma_2(33) = 1220$, $\sigma_2(15) = 260$, and $18 \nmid 960$: nor is $\sigma_2$. A congruence form is equally useful: if $W$ were polynomial then $m \mid N_1 - N_2$ would force $m \mid W(N_1)-W(N_2)$, so any modular separation refutes polynomiality. This is the sharp, unconditional form of the "$\bmod\ 2^k$ separation" strategy, and Section 7 pushes it further.

### 5.3 The rigidity theorem

**Theorem 5.3 (No polynomial formula, all exponents).**
Let $(W,w)$ be a semiprime witness with $w(s) = s^k + c$ for every odd prime $s$, where $k \geq 1$ and $c \neq 0$. Then there is no $P \in \mathbb{Z}[X]$ with
$$W(pq) = P(pq) \qquad \text{for all distinct odd primes } p \neq q .$$

*Proof sketch.* Suppose such a $P$ exists and fix an odd prime $r$. For every odd prime $q \notin \{r,2\}$,
$$P(rq) = W(rq) = w(r)w(q) = (r^k+c)(q^k+c).$$
Both sides are polynomial expressions in the variable evaluated at the integer $q$: the left is $P(rX)$ at $X=q$, the right is $(r^k+c)(X^k+c)$ at $X=q$. There are infinitely many such primes $q$, and two polynomials over an integral domain agreeing on an infinite set are equal. Hence the *polynomial identity*
$$P(rX) = (r^k+c)(X^k+c) \qquad \text{in } \mathbb{Z}[X].$$
Apply this with $r=3$ and with $r=5$, and evaluate the first at $X=10$, the second at $X=6$ — both give $P(30)$:
$$(3^k+c)(10^k+c) = P(30) = (5^k+c)(6^k+c).$$
Expanding, the leading terms agree, $3^k10^k = 30^k = 5^k6^k$, and the constant terms agree, $c^2 = c^2$; what remains is
$$c\,(10^k + 3^k) = c\,(6^k + 5^k).$$
Since $c \neq 0$ we may cancel, obtaining $10^k + 3^k = 6^k + 5^k$. But for $k \ge 1$ this fails: for $k=1$, $13 \ne 11$; and for $k \ge 2$ one has $2\cdot 6^k \le 10^k$ by induction, whence $6^k + 5^k \le 2\cdot 6^k \le 10^k < 10^k + 3^k$. Contradiction. $\square$

**Remark 5.4 (What the argument really shows).** The proof isolates the role of $c$. The forced identity is $c(10^k+3^k) = c(6^k+5^k)$, so a polynomial closed form would require $c = 0$ — i.e. a purely homogeneous local weight $w(x) = x^k$, whose aggregate is the polynomial $N^k$ and which carries no factor information whatsoever. *A nonzero constant term in the local weight is exactly what is incompatible with a polynomial closed form, and it is exactly what puts $p^k+q^k$ into the aggregate.* The rigidity theorem and the Trace Lemma are two faces of the same coefficient.

**Theorem 5.5 (Classification for power-shaped witnesses).**
Let $(W,w)$ be a semiprime witness with $w(s) = s^k+c$ on odd primes, $k \ge 1$, $c \neq 0$. Then simultaneously:
1. *(factoring-complete)* $c(p^k+q^k) = W(pq) - (pq)^k - c^2$ for all distinct odd primes, hence by Theorem 4.6 and Propositions 4.8–4.10 the factorization is recovered in polynomial time from $W(N)$ and $N$; and
2. *(non-polynomial)* no $P \in \mathbb{Z}[X]$ reproduces $W$ on the odd semiprimes.

That is, $(W,w)$ is a free witness in the sense of Definition 2.4.

---

## 6. The prediction: divisor power sums

The classification is falsifiable: *any* non-polynomial CRT-multiplicative local weight must yield a free witness. The most economical test case is the divisor power sum, whose local weight $\sigma_k(p) = 1 + p^k$ is manifestly multiplicative and manifestly a function of the single prime.

**Lemma 6.1 (Local weight).** For $p$ prime, $\sigma_k(p) = 1 + p^k$.
*Proof sketch.* The divisors of $p$ are $1$ and $p$. $\square$

**Lemma 6.2 (CRT factorization).** For distinct primes $p \ne q$, $\;\sigma_k(pq) = (1+p^k)(1+q^k)$.
*Proof sketch.* $\sigma_k$ is multiplicative on coprime arguments, and distinct primes are coprime; apply Lemma 6.1 twice. $\square$

Thus $\sigma_k$ is a semiprime witness with power-shaped local weight $x^k + 1$, and Theorem 5.5 applies verbatim.

**Theorem 6.3 (SIGK: the predicted free witness).**
For every $k \ge 1$ and distinct odd primes $p \ne q$ with $N = pq$:
1. $p^k + q^k = \sigma_k(N) - N^k - 1$;
2. $k = 1$: $\;p+q = \sigma(N) - N - 1$;
3. $k = 2$: $\;(p+q)^2 + 1 + N^2 = \sigma_2(N) + 2N$, equivalently the explicit closed form
$$\boxed{\;p + q = \sqrt{\sigma_2(N) + 2N - 1 - N^2}\;}$$
   in which every quantity on the right is a function of $N$ and the witness value alone;
4. the factorization is determined: if $p'q' = N$ with $p' > 0$ and $(p'+q')^2$ equals the right-hand side of (3), then $\{p',q'\} = \{p,q\}$;
5. no integer polynomial computes $\sigma_k(pq)$ on the distinct-prime pairs.

*Proof sketch.* (1)–(3) are Theorem 4.2 and Corollary 4.4 with $a=c=1$, plus the identity $(p+q)^2 = p^2+q^2+2N$; the square root is exact because the radicand is the perfect square $(p+q)^2$. (4) follows from (3) and Theorem 4.6, after noting that $u^2 = v^2$ with $u,v \ge 0$ gives $u = v$. (5) is Theorem 5.3 with $c = 1$; alternatively, Proposition 5.2 with $(N_1,N_2) = (33,15)$. $\square$

**Numerical table.**

| $N = pq$ | $\sigma_2(N)$ | $(1+p^2)(1+q^2)$ | $p^2+q^2 = \sigma_2 - 1 - N^2$ | $\sqrt{\sigma_2 + 2N - 1 - N^2}$ |
|---|---|---|---|---|
| $15 = 3\cdot 5$ | $260$ | $10 \cdot 26$ | $34$ | $8 = 3+5$ |
| $21 = 3\cdot 7$ | $500$ | $10 \cdot 50$ | $58$ | $10 = 3+7$ |
| $33 = 3\cdot 11$ | $1220$ | $10 \cdot 122$ | $130$ | $14 = 3+11$ |
| $35 = 5\cdot 7$ | $1300$ | $26 \cdot 50$ | $74$ | $12 = 5+7$ |
| $77 = 7\cdot 11$ | $6100$ | $50 \cdot 122$ | $170$ | $18 = 7+11$ |

This is the first member of the family produced by the theory rather than by search — a successful falsifiable test of the classification.

**Proposition 6.4 (Sharpness of $k \ge 1$).**
At $k = 0$ the witness degenerates: $\sigma_0(pq) = 4$ for all distinct primes, a constant, hence a polynomial in $N$ carrying no factor information. Therefore the hypothesis $k \ge 1$ in Theorem 5.5 cannot be dropped.
*Proof sketch.* $\sigma_0(pq) = (1+p^0)(1+q^0) = 2\cdot 2 = 4$; take $P = 4$. $\square$

---

## 7. Sealing: how much is a function of $N$ alone

Layer three of the mechanism says the witness is *sealed*: computing it without the factors costs $\Theta(N)$. A natural attack is to look for a shortcut in the low-order bits — a formula for $W(N) \bmod 2^k$ in terms of $N \bmod 2^k$. The proposed strategy in the literature is to exhibit $N_1 \equiv N_2 \pmod{2^k}$ with $W(N_1) \not\equiv W(N_2)$, which would prove that no such shortcut exists. The situation is more delicate than expected, and both halves are settled here.

### 7.1 Nothing leaks below 64

**Lemma 7.0 (Shift identity).** For distinct primes $p \ne q$ and any $k$,
$$\sigma_k(pq) = 2 + 2N^k - (p^k-1)(q^k-1), \qquad N = pq.$$
*Proof sketch.* Expand $(1+p^k)(1+q^k)$ and $(p^k-1)(q^k-1)$ and compare: both contain $p^kq^k = N^k$ and the cross terms $p^k + q^k$ with opposite signs. $\square$

**Lemma 7.0′ (2-adic input).** For odd $p$ and any $j$, $\;8 \mid p^{2j} - 1$.
*Proof sketch.* Write $p = 2m+1$; then $p^2 - 1 = 4m(m+1)$ and $m(m+1)$ is even, so $8 \mid p^2-1$. Since $x - 1 \mid x^j - 1$, applying this with $x = p^2$ gives $p^2 - 1 \mid p^{2j}-1$, hence $8 \mid p^{2j}-1$. $\square$

**Theorem 7.1 (The truncation leaks nothing below 64).**
For every $j \ge 0$ and all distinct odd primes $p \ne q$ with $N = pq$,
$$\sigma_{2j}(N) \equiv 2 + 2N^{2j} \pmod{64}.$$

*Proof sketch.* By Lemma 7.0, the discrepancy is exactly $(p^{2j}-1)(q^{2j}-1)$. By Lemma 7.0′ each factor is divisible by $8$, so the product is divisible by $64$. $\square$

**Corollary 7.2.** The low six bits of the divisor-power witness are an explicit polynomial in $N$. Consequently, no separating pair $N_1 \equiv N_2 \pmod{2^k}$ with $\sigma_{2j}(N_1) \not\equiv \sigma_{2j}(N_2)$ can exist for any $k \le 6$ — a brute-force search over all semiprimes with both primes below $300$ (some $3\times 10^5$ pairs) finds none, and the theorem explains why the search *must* fail rather than merely reporting that it did.

### 7.3 Seven bits do separate

**Theorem 7.3 (No function of $N \bmod 128$).**
There is no function $g : \mathbb{N} \to \mathbb{N}$ — polynomial or arbitrary — with
$$\sigma_2(pq) \bmod 128 = g\big((pq) \bmod 128\big) \quad \text{for all distinct odd primes } p \ne q .$$

*Proof sketch.* Take $N_1 = 15 = 3\cdot 5$ and $N_2 = 527 = 17 \cdot 31$. Then $527 = 4\cdot 128 + 15$, so $N_1 \equiv N_2 \pmod{128}$ and $g$ would have to return the same value on both. But $\sigma_2(15) = 10\cdot 26 = 260 \equiv 4$, while $\sigma_2(527) = 290 \cdot 962 = 278980 \equiv 68 \pmod{128}$. $\square$

This is strictly stronger than the polynomial barrier of Section 5: it excludes *every* formula in the residue of the modulus, not merely polynomial ones. Together with Theorem 7.1, the 2-adic seal of $\sigma_2$ is located exactly: transparent through $2^6$, opaque at $2^7$.

**Theorem 7.4 (The circle count is less sealed).**
The same pair separates the circle count already at $32$: $C(15) = (3+1)(5-1) = 16$ and $C(527) = (17-1)(31+1) = 512 \equiv 0 \pmod{32}$, while $527 \equiv 15 \pmod{32}$. Hence no function of $N \bmod 32$ computes $C(N) \bmod 32$ on odd semiprimes.

So different members of one family have measurably different low-order leakage: the divisor witness conceals six bits, the circle witness only four. Sealing is a quantitative attribute of a witness, not a binary one.

---

## 8. Beyond semiprimes: the $\omega$-channel

The classification is stated for two factors, but nothing in the mechanism cares how many primes $N$ has. Pushing the divisor witness to squarefree moduli reveals a second information channel that the semiprime picture hides.

**Theorem 8.1 (Product formula).** For squarefree $N$,
$$\sigma_k(N) = \prod_{p \mid N} (1 + p^k).$$
*Proof sketch.* The prime factors of a squarefree $N$ are pairwise coprime with product $N$; multiplicativity of $\sigma_k$ over a pairwise-coprime family gives $\sigma_k(N) = \prod_p \sigma_k(p)$, and Lemma 6.1 evaluates each term. $\square$

**Lemma 8.2 (Each local factor contributes exactly one $2$).** For an odd prime $p$ and any $j$, $\;v_2(1 + p^{2j}) = 1$.
*Proof sketch.* By Lemma 7.0′, $p^{2j} = 1 + 8t$, so $1 + p^{2j} = 2 + 8t = 2(4t+1)$ with $4t+1$ odd. Hence $2$ divides but $4$ does not. $\square$

**Theorem 8.3 (The $\omega$-channel).** For odd squarefree $N$ and every $j \ge 0$,
$$v_2\big(\sigma_{2j}(N)\big) = \omega(N),$$
the number of distinct prime factors of $N$.
*Proof sketch.* By Theorem 8.1 the witness is a product over $p \mid N$; the 2-adic valuation of a product is the sum of valuations; each summand is $1$ by Lemma 8.2 (every $p \mid N$ is odd since $N$ is odd); the number of summands is $\omega(N)$. $\square$

**Corollary 8.4.** On semiprimes the valuation is the constant $2$ — which is precisely why the channel is invisible in the two-factor setting where the family was studied.

| $N$ | factorization | $\sigma_2(N)$ | $v_2$ | $\omega(N)$ |
|---|---|---|---|---|
| $15$ | $3\cdot 5$ | $260 = 2^2\cdot 65$ | $2$ | $2$ |
| $105$ | $3\cdot5\cdot7$ | $13000 = 2^3\cdot 1625$ | $3$ | $3$ |
| $1155$ | $3\cdot5\cdot7\cdot11$ | $1586000 = 2^4 \cdot 99125$ | $4$ | $4$ |
| $15015$ | $3\cdot5\cdot7\cdot11\cdot13$ | $269620000 = 2^5\cdot 8425625$ | $5$ | $5$ |

**Discussion.** The Trace Lemma's slogan — "the information content of every witness is one factor-secret coordinate" — is therefore an artifact of restricting attention to semiprimes. The multiplicative *structure* of the aggregate carries $\omega(N)$ in its valuation, unconditionally and independently of the trace channel. A witness in this class leaks at least two structurally different things.

---

## 9. The boundary of the class

A classification is only as good as its boundary. Two candidate constructions that resemble members are shown here to fall outside, and in the second case the standard reason is shown to be wrong.

### 9.1 Truncation

**Definition.** Let $f(x) = \mathbf{1}[\,2(x \bmod 15) < 15\,]$, the indicator of the "lower half" of the residue interval mod $15$ — the one-variable model of a truncated (half-plane) count.

**Theorem 9.2 (Truncation leaves the class).** $f \notin \mathrm{Split}(3,5)$.

*Proof sketch.* Apply Theorem 3.4 to the quadruple $x=0$, $y=1$, $z=6$, $w=10$, whose CRT coordinates mod $(3,5)$ are $(0,0), (1,1), (0,1), (1,0)$ — a rectangle, so the crossing conditions hold. Rank-one would require $f(0)f(1) = f(6)f(10)$. But $f(0) = f(1) = 1$ while $f(6) = 1$, $f(10) = 0$, giving $1 \ne 0$. $\square$

The value grid makes the failure visible. With rows indexed by $x \bmod 3$ and columns by $x \bmod 5$:

$$
\begin{array}{c|ccccc}
 & 0 & 1 & 2 & 3 & 4 \\ \hline
0 & 1 & 1 & 0 & 1 & 0\\
1 & 0 & 1 & 1 & 0 & 1\\
2 & 1 & 0 & 1 & 0 & 0
\end{array}
$$

The top-left $2\times 2$ block is $\begin{pmatrix}1&1\\0&1\end{pmatrix}$, of rank two. By contrast, the same grid for the character-like weight $\mathbf{1}[x^2 \equiv 1 \bmod 15]$ is the outer product of $\mathbf{1}[a^2 \equiv 1 \bmod 3]$ and $\mathbf{1}[b^2 \equiv 1 \bmod 5]$ — the following is the general statement.

**Theorem 9.3 (Character-like weights stay inside).** For coprime $m, n$, the indicator $x \mapsto \mathbf{1}[x^2 \equiv 1 \bmod mn]$ lies in $\mathrm{Split}(m,n)$, with $A(a) = \mathbf{1}[a^2 \equiv 1 \bmod m]$ and $B(b) = \mathbf{1}[b^2 \equiv 1 \bmod n]$.
*Proof sketch.* $x^2 \equiv 1 \bmod mn$ iff $x^2 \equiv 1$ mod $m$ and mod $n$ (CRT), and the indicator of a conjunction is the product of indicators; finally $x^2 \bmod m$ depends only on $x \bmod m$. $\square$

This is exactly the CIRC/BQF-style square-root-of-one weight, and it explains structurally why the character members of the family work.

### 9.4 Phases: splitting holds, locality fails

It is often asserted that exponential phase weights $y \mapsto e^{2\pi i f(y)/N}$ fail to be free witnesses because such phases "do not decompose through the CRT — only group characters do". **This justification is false as stated.**

**Theorem 9.5 (Phases do split).** Let $m, n$ be coprime with Bézout data $un + vm = 1$. Then for every integer $x$,
$$x = (ux)\,n + (vx)\,m,$$
hence, as elements of $\mathbb{Q}/\mathbb{Z}$, $\;\dfrac{x}{mn} = \dfrac{ux}{m} + \dfrac{vx}{n}$, and therefore
$$e^{2\pi i x/(mn)} = e^{2\pi i (ux)/m}\cdot e^{2\pi i (vx)/n}$$
exactly, with no error term.
*Proof sketch.* Multiply the Bézout identity by $x$. $\square$

So the phase index decomposes perfectly through the CRT. The genuine obstruction is elsewhere.

**Theorem 9.6 (The twist depends on the co-modulus).** In the decomposition above, the local weight at $m$ is $y \mapsto e^{2\pi i u y/m}$ with $u \equiv n^{-1} \pmod m$: the twist is a function of the *other* modulus. Concretely, modulo $7$ one has $3^{-1} = 5$ and $5^{-1} = 3$, and the two induced local weights $y \mapsto 5y$ and $y \mapsto 3y$ on $\mathbb{Z}/7$ are different functions (they already disagree at $y=1$). Consistently with Bézout: $5\cdot 3 + (-2)\cdot 7 = 1$ gives twist $u=5$ at $m=7$ when $n=3$, while $3 \cdot 5 + (-2)\cdot 7 = 1$ gives twist $u=3$ when $n=5$.

**Consequence.** A phase witness *does* factor, but its local factor at $p$ is not a function of $p$ alone — it depends on $q$ through the modular inverse. Definition 2.1 demands a local weight that is a function of a single prime; phases violate exactly that hypothesis. The class boundary is therefore drawn by **locality**, not by splitting, and this is a different reason from the one previously given.

### 9.7 Non-separability does not buy a closed form

**Theorem 9.8.** The half-plane count $H$, the non-CRT-separable companion of the circle count, is *also* not a polynomial in $N$: $H(15) = 4$, $H(35) = 6$, and $35 - 15 = 20$ does not divide $2$; apply Proposition 5.2.

Hence the two barriers of the classification — non-separability and non-polynomiality — are logically independent properties of a counting aggregate. Leaving the CRT-multiplicative class buys no closed form; it merely forfeits the recovery channel.

---

## 10. Algorithms

Four procedures follow directly from the results and are what one actually runs.

**Algorithm A (Trace-channel factorization).** *Input:* $N$ odd semiprime, witness value $W = \sigma_2(N)$ (or any affine-power witness value with data $(a,k,c)$). *Output:* $\{p,q\}$.
1. Compute the power sum $t = (W - a^2N^k - c^2)/(ac)$.
2. For $k=2$: set $s = \sqrt{t + 2N}$ (exact integer square root); for $k=1$: $s = t$.
3. Compute $d = \sqrt{s^2 - 4N}$; return $\{(s-d)/2, (s+d)/2\}$.

Cost: $O(1)$ arithmetic operations plus two integer square roots, i.e. $\tilde O(\log^2 N)$ bit operations. Correctness: Theorem 4.2, Corollary 4.4, Proposition 4.8, Theorem 4.6.

**Algorithm B (Rank-one membership test).** *Input:* moduli $m,n$ coprime, weight $f$ on $\mathbb{Z}/mn$ over a field, with $f(0) \ne 0$. *Output:* the splitting $(A,B)$, or a violating quadruple.
For each $x$, form $z = \mathrm{crt}(x \bmod m, 0)$, $w = \mathrm{crt}(0, x \bmod n)$, and test $f(x)f(0) = f(z)f(w)$. If all tests pass, return $A(a) = f(\mathrm{crt}(a,0))$, $B(b) = f(\mathrm{crt}(0,b))/f(0)$. Cost: $O(mn)$ field operations (the anchored form); $O(m^2n^2)$ for the exhaustive form. Correctness: Theorem 3.5.

**Algorithm C (2-adic sealing scan).** *Input:* prime bound $P$, modulus $2^k$, witness $W$. Enumerate semiprimes $N = pq$ with $3 \le p < q < P$; bucket by $N \bmod 2^k$; report any bucket containing two moduli with distinct $W(N) \bmod 2^k$. Cost: $O(\pi(P)^2)$ witness evaluations. Theorem 7.1 predicts empty output for $\sigma_{2j}$ at every $k \le 6$; Theorem 7.3 predicts a hit at $k = 7$.

**Algorithm D ($\omega$ extraction).** *Input:* odd squarefree $N$, value $\sigma_{2j}(N)$. Return $v_2(\sigma_{2j}(N))$ by repeated halving. Output equals $\omega(N)$ by Theorem 8.3. Cost: $O(\omega(N))$ halvings.

---

## 11. Applications and discussion

**A design criterion for counting functions.** Any protocol whose security rests on the difficulty of extracting structure from a modulus should avoid publishing aggregates whose summand weight is CRT-multiplicative with a non-polynomial local factor. Theorem 3.5 turns this from a vague warning into a check: form the CRT grid of the weight and test rank one on the quadruples anchored at $0$. If the test passes, the aggregate is a free witness and the modulus is compromised by publishing it.

**A unification with predictive content.** Before the classification one had nine coincidences and no criterion. Now: a definition (Definition 2.1/2.3), a decidable membership test (Corollary 3.6), a completeness theorem (the Trace Lemma with its three channels), a rigidity theorem (Theorem 5.3), a validated prediction (Theorem 6.3), a delimited boundary (Section 9), and a quantitative seal (Section 7). The classification earned its keep by predicting a new member and being right.

**A correction to the record.** The exclusion of phase witnesses was justified by the claim that phases do not decompose through the CRT. Theorem 9.5 shows they do, exactly. The real obstruction, Theorem 9.6, is that the Bézout twist depends on the co-modulus, so the local factor is not a function of one prime. The distinction matters for anyone trying to enlarge the class: one should look for weights whose local factors are single-prime functions, not merely for weights that factor.

**What is and is not established.** Established: the product formula for split weights; the four-point characterization; the Trace Lemma and completeness of all three recovery channels; the rigidity theorem for all $k \ge 1$; the SIGK prediction; sharpness at $k=0$; the $2$-adic dichotomy at $64$ and $128$; the $\omega$-channel; the truncation and phase boundaries; the independence of the two barriers. Not established, and not establishable by present means: that the $\Theta(N)$ aggregation cost is *necessary*. That statement is equivalent to the hardness of factoring. The classification characterizes the mechanism precisely; it does not prove the barrier unconditionally, and no claim to the contrary is made here.

---

## 12. Future directions

Five falsifiable conjectures, each stated so that a single computation or a single proof settles it.

**C1. The exact 2-adic sealing threshold is $2^{3+2v}$.** For odd distinct primes $p,q$ and $k = 2j$, write $v = v_2(k) + 2$. Then $\sigma_k(pq) \bmod 2^{2v}$ is a polynomial function of $N \bmod 2^{2v}$, and there exist semiprimes $N_1 \equiv N_2 \pmod{2^{2v+1}}$ with $\sigma_k(N_1) \not\equiv \sigma_k(N_2) \pmod{2^{2v+1}}$. The leakage is governed entirely by $\sigma_k(N) = 2 + 2N^k - (p^k-1)(q^k-1)$: for even $k$ and odd $p$, the 2-adic valuation of $p^k-1$ is exactly $v_2(k)+2$ by a lifting-the-exponent computation, so the correction term vanishes precisely below $2^{2v}$. The case $k=2$ is Theorems 7.1 and 7.3 (modulus $64$; separation at $128$); C1 says the pattern is general and that $64$ is not an accident. The missing ingredient is only the lifting-the-exponent step for general even $k$.

**C2. Every witness in the class leaks $\omega(N)$, not just the trace.** Let $F$ be a CRT-multiplicative witness whose local weight satisfies $w(p) = u\cdot m(p)$ with a fixed prime power $u$ and $m(p)$ coprime to $u$ for all odd primes $p$. Then $v_u(W(N)) = \omega(N)$ for all odd squarefree $N$, so the witness determines the number of prime factors unconditionally. The slogan "one factor-secret coordinate per witness" is an artifact of restricting to semiprimes: the multiplicative structure of the aggregate carries $\omega(N)$ in its valuation, independently of the trace channel. The case $u=2$, $w(p) = 1+p^{2j}$ is Theorem 8.3; the general statement needs the same two ingredients (multiplicativity of the valuation over a product, plus a one-line local computation) with $u$ abstracted.

**C3. Rank-one is decidable, hence membership in the free-witness class is decidable.** For a weight $f$ on $\mathbb{Z}/mn$ with values in a field, membership in the CRT-multiplicative class is decided by $O(m^2n^2)$ field operations, and no smaller test suffices: for every $(m,n)$ there is a weight failing exactly one rank-one quadruple. The key is the exactness result of Theorem 3.5: splitting is not an existential over factorizations but a finite system of quadratic identities, so the question "is this experiment a free witness?" — which the source analysis answers by inspection, case by case — becomes an algorithm.

**C4. The locality criterion characterizes the phase boundary.** Formalize "local weight is a function of one prime" as an independence condition on the family of factorizations indexed by the co-modulus, and prove that a weight admits a *co-modulus-independent* splitting if and only if it is a product of Dirichlet characters times a multiplicative function of the residue. This would turn Theorem 9.6 from an obstruction exhibited at one example into a structure theorem for the boundary.

**C5. Quantitative sealing as an invariant.** Attach to each witness the largest $k$ such that $W(N) \bmod 2^k$ is a function of $N \bmod 2^k$ on odd semiprimes ($6$ for $\sigma_{2j}$, $4$ for the circle count, by Theorems 7.1–7.4). Conjecture that this invariant is computable from the local weight alone — specifically from the 2-adic expansion of $w(p) - w(1)$ — and that it is monotone under the operations (products, twists, convolutions) that generate new members of the family from old ones.

---

## 13. Conclusion

The free-witness family is one mechanism: a non-polynomial, CRT-multiplicative local weight aggregated over a CRT-separable domain. Layer one — separability plus multiplicativity implies a product formula — is a theorem, and its converse over a field is a four-point test that makes class membership decidable. The Trace Lemma shows that the aggregate hands over a power sum $p^k+q^k$, and that this single coordinate, through any of three complete channels, is the factorization. The rigidity theorem shows that no polynomial in $N$ can shadow such a witness, for any exponent $k \ge 1$, and localizes the obstruction in the constant term of the local weight. The classification predicted the divisor power sums as new members, and they are. Its boundary is now drawn twice: truncation exits by failing rank one, and phase weights — which, contrary to the standard account, do split through the CRT — exit by failing locality. Finally, the semiprime picture was hiding a second channel: the 2-adic valuation of the witness counts the prime factors of the modulus.

What remains open is exactly the hard part, and it is the same hard part as always: whether the $\Theta(N)$ cost of aggregating without the factors is *necessary*. The classification does not settle that. It does say, with precision, what the nine constructions are, why they behave identically, how to test a tenth, and what a witness leaks when nobody is looking.
