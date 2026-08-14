# GCD Moments of a Semiprime: a Closed Trace-Witness Family

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

For a positive integer $n$ and an exponent $k \ge 1$ define the *$k$-th gcd moment*

$$M_k(n) \;=\; \sum_{x=0}^{n-1} \gcd(n,x)^k .$$

We give a complete analysis of this family on semiprime moduli $N = pq$ with $p \ne q$ prime, and then on general moduli. Three groups of results are established.

**(i) Exact structure.** $M_k$ is the Dirichlet convolution of $n \mapsto n^k$ with Euler's totient, giving the divisor form $M_k(n) = \sum_{d \mid n} d^k \varphi(n/d)$ and multiplicativity. On a semiprime, writing $s = p+q$ for the *trace* and $P_j = p^j + q^j$ for the Newton power sums (computable from $(N,s)$ by $P_{j+2} = sP_{j+1} - NP_j$), we prove the closed form

$$M_k(N) \;=\; N^k + N P_{k-1} - P_k + N - s + 1,$$

an integer polynomial in the public modulus and the trace alone. In particular $M_1 = 4N - 2s + 1$, so the first moment recovers $s$ exactly, and since a pair is determined by its sum and product (with discriminant $s^2 - 4N = (q-p)^2$ a perfect square), the trace splits $N$. Conversely every higher moment is an explicit function of $N$ and $M_1$: the family is *closed*, and carries exactly one hidden quantity.

**(ii) Cost.** The moment is an aggregate over all $N$ residues, and statistical shortcuts fail quantitatively. We prove the two-sided variance estimate

$$N^{2k-1} - 16N^{2k-2} \;\le\; \operatorname{Var}\big(\gcd(N,U)^k\big) \;\le\; 4N^{2k-1}$$

for uniform $U$, hence $\operatorname{Var} = \Theta(N^{2k-1})$, together with the separation $\tfrac{N^2}{8}\operatorname{Var}_1 \le \operatorname{Var}_2$ for $N \ge 32$. The first moment is therefore the unique cheap member of the family. We also compute the witness density exactly: $\#\{x < N : \gcd(N,x) \ne 1\} = p+q-1$.

**(iii) Inversion and the refinement lattice.** Regarding $M_k$ as an Euler product over local factors $L_k(a) = a^k + a - 1$, we study the number $E_k(a_1,\dots,a_r) = \prod_i L_k(a_i)$ predicted by an arbitrary factorisation into parts $\ge 2$. Splitting a part strictly raises the prediction, so $E_k$ is strictly monotone for the refinement order; the trivial factorisation is its unique minimiser and the prime factorisation its unique maximiser, giving the bracket $n^k + n - 1 \le M_k(n) \le \Pi_k(n)$ with left equality exactly at primes and right equality exactly at squarefree moduli. We classify all second-moment collisions of two-part factorisations — there are exactly two moduli, $28 = 2\cdot14 = 4\cdot7$ and $36 = 2\cdot18 = 3\cdot12$ — prove unconditional strict spread-monotonicity at every $k \ge 3$ (with a sharp exceptional set of seven quadruples), and deduce: *for every $k \ge 1$, the observed $k$-th gcd moment of a distinct-prime semiprime is matched by exactly one candidate factorisation.* Beyond semiprimes, the predicted moment separates all factorisations whenever $\Omega(n) \le 2$ (any $k \ge 1$), and whenever $\Omega(n) \le 3$ at $k = 1$ and at every $k \ge 3$; both bounds are sharp, witnessed by $28$ at $k=2$ and by $234 = 2\cdot9\cdot13 = 3\cdot3\cdot26$ at $k=1$.

The overall conclusion is negative for factoring, and sharply so: the gcd-moment family carries complete information about a semiprime, but the information it carries is exactly the trace, and no member can be evaluated in fewer than $\Theta(N)$ operations without already knowing the factorisation.

**Keywords:** gcd-sum function, Jordan totient, Dirichlet convolution, semiprime, trace witness, refinement order, integer factorisation, moment hierarchy.

---

## 1. Introduction

Let $N = pq$ be a product of two distinct primes. A recurring question in the analysis of factoring is whether some elementary, publicly computable statistic of $N$ encodes the hidden pair $(p,q)$. Many such statistics do — trivially, $\varphi(N) = N - p - q + 1$ does — and the interest lies not in whether a statistic is informative but in the interaction between *what it encodes* and *what it costs*.

This paper carries out that analysis in full for the family of gcd moments

$$M_k(N) \;=\; \sum_{x=0}^{N-1} \gcd(N,x)^k, \qquad k \ge 1 .$$

The case $k = 1$ is the classical gcd-sum function, sometimes called Pillai's arithmetical function. The higher moments are the natural re-weightings that an analyst would try next: they emphasise the rare large gcd values against the overwhelming majority of coprime residues.

Our results say that the family is *closed* in a strong sense. Every moment is an explicit polynomial in the modulus $N$ and the trace $s = p+q$; the first moment already determines $s$; and every higher moment is therefore an explicit function of $N$ and $M_1$. No moment carries more than the trace, and the trace is exactly enough to factor. The hierarchy indexed by $k$ is not an information hierarchy at all — it is a *cost* hierarchy, and it runs in the wrong direction, with the sampling variance growing like $N^{2k-1}$.

We then analyse the structure that makes all of this work: $M_k$ is multiplicative, indeed an Euler product on squarefree moduli, and the whole discussion can be recast as the study of a strictly monotone function on the lattice of factorisations of $n$ ordered by refinement. This recasting yields sharp inversion theorems: a complete classification of second-moment collisions, unconditional identifiability at every $k \ge 3$, and separation results controlled by $\Omega(n)$, the number of prime factors counted with multiplicity.

Throughout, "moment" means the value $M_k$; "prediction" means the value $E_k$ that a hypothetical factorisation would produce. The two agree when the factorisation is the true one, and the inversion question is whether the prediction map is injective.

### 1.1 Conventions

$\varphi$ is Euler's totient; $\Omega(n)$ counts prime factors with multiplicity; $p^e \,\|\, n$ means $p^e \mid n$ and $p^{e+1} \nmid n$; a *factorisation* of $n$ is a finite multiset of integers $\ge 2$ with product $n$; a *semiprime* here always means a product of two **distinct** primes. Summation over $x$ runs over a full residue system $0 \le x < n$, so the term $x = 0$ contributes $\gcd(n,0)^k = n^k$; this is the same as the term $x = n$ in the more usual range $1 \le x \le n$.

---

## 2. The divisor form and multiplicativity

**Definition 2.1.** For $k, n \ge 1$, $\displaystyle M_k(n) = \sum_{x=0}^{n-1}\gcd(n,x)^k$.

**Theorem 2.2 (Divisor form).** For every $n \ge 1$ and every $k \ge 0$,
$$M_k(n) \;=\; \sum_{d \mid n} d^k\,\varphi(n/d).$$

*Proof sketch.* Partition the residues $x < n$ by the value $d = \gcd(n,x)$, which is always a divisor of $n$. The fibre over $d$ consists of the multiples $x = d y$ with $y < n/d$ and $\gcd(n/d, y) = 1$, so it has exactly $\varphi(n/d)$ elements, each contributing $d^k$. Summing the fibres gives the claim. $\square$

Thus $M_k = \mathrm{Id}_k * \varphi$ is a Dirichlet convolution of two multiplicative functions.

**Corollary 2.3 (Multiplicativity).** If $\gcd(m,n) = 1$ and $m, n \ge 1$ then $M_k(mn) = M_k(m)M_k(n)$.

**Proposition 2.4 (Local factors).** For $p$ prime and $e \ge 1$,
$$M_k(p) = p^k + p - 1, \qquad M_k(p^e) = \sum_{i=0}^{e} p^{ik}\varphi(p^{e-i}) = p^{ek} + (p-1)\sum_{i=0}^{e-1} p^{ik}p^{\,e-1-i},$$
and the local recursion $M_k(p^{e+1}) = p^k M_k(p^e) + \varphi(p^{e+1})$ holds.

*Proof sketch.* Specialise Theorem 2.2 to the divisors $1, p, \dots, p^e$ and use $\varphi(p^j) = p^{j-1}(p-1)$ for $j \ge 1$. The recursion follows by splitting off the top divisor. $\square$

**Corollary 2.5 (Euler product on squarefree moduli).** If $n$ is squarefree then
$$M_k(n) \;=\; \prod_{p \mid n}\big(p^k + p - 1\big).$$

This is the conceptual heart of the paper: on squarefree moduli the moment is *completely split*, with one local factor per prime. Everything that follows is an analysis of how those local factors combine.

---

## 3. The semiprime closed form

Fix distinct primes $p, q$, put $N = pq$ and $s = p + q$.

**Definition 3.1 (Newton power sums from public data).** Define $P_0 = 2$, $P_1 = s$ and $P_{j+2} = sP_{j+1} - NP_j$.

**Lemma 3.2.** $P_j = p^j + q^j$ for all $j \ge 0$.

*Proof sketch.* Both sides satisfy the same two-term linear recursion, since $p$ and $q$ are the roots of $t^2 - st + N$; check the two initial values. $\square$

**Theorem 3.3 (Four-term expansion).** For all $k \ge 0$,
$$M_k(pq) \;=\; (p-1)(q-1) \;+\; p^k(q-1) \;+\; q^k(p-1) \;+\; (pq)^k .$$

*Proof sketch.* The divisors of $pq$ are $1, p, q, pq$; apply Theorem 2.2 with $\varphi(pq) = (p-1)(q-1)$, $\varphi(q) = q-1$, $\varphi(p) = p-1$, $\varphi(1)=1$. $\square$

**Theorem 3.4 (Closed form; the symmetry barrier).** For every $k \ge 1$,
$$M_k(N) \;=\; N^k \;+\; N P_{k-1} \;-\; P_k \;+\; N \;-\; s \;+\; 1 \;=:\; F_k(N,s).$$

*Proof sketch.* Expand Theorem 3.3: $p^k(q-1) + q^k(p-1) = pq(p^{k-1}+q^{k-1}) - (p^k+q^k) = N P_{k-1} - P_k$, while $(p-1)(q-1) = N - s + 1$ and $(pq)^k = N^k$. $\square$

**Corollary 3.5 (Explicit low moments).**

| $k$ | $M_k$ as a polynomial in $(N,s)$ |
|---|---|
| $1$ | $4N - 2s + 1$ |
| $2$ | $N^2 + 3N + 1 + (N-1)s - s^2$ |
| $3$ | $N^3 - 2N^2 + Ns^2 + 3Ns + N - s^3 - s + 1$ |
| $4$ | $N^4 - 3N^2s - 2N^2 + Ns^3 + 4Ns^2 + N - s^4 - s + 1$ |

For example at $N = 6$ ($p=2$, $q=3$, $s=5$) one gets $M_1 = 15$ and $M_2 = 55$, matching a direct scan; at $N = 15$ ($s=8$) one gets $M_1 = 4\cdot15 - 16 + 1 = 45$.

Theorem 3.4 is the *symmetry barrier* in its exact form. The hidden primes enter every moment only through the elementary symmetric functions $N = pq$ and $s = p+q$; no moment can distinguish between hidden data with the same product and sum.

**Corollary 3.6 (Trace recovery).** $2s = 4N + 1 - M_1(N)$.

**Theorem 3.7 (Closure of the family).** Let $s$ be defined by $2s = 4N + 1 - M_1(N)$. Then for every $k \ge 1$, $M_k(N) = F_k(N,s)$. Consequently every gcd moment is an explicit polynomial function of the modulus and the *first* moment.

*Proof sketch.* By Corollary 3.6 the quantity so defined is the true trace; substitute into Theorem 3.4. $\square$

The family therefore carries exactly one hidden number. Anything computable from $\{M_k\}_{k\ge1}$ is computable from $M_1$.

**Theorem 3.8 (The trace splits $N$).** Let $a \le b$ be positive integers with $ab = N$ and $a + b = s$. Then $a = p$ and $b = q$ (assuming $p \le q$). Moreover $s^2 - 4N = (q-p)^2$ is a perfect square.

*Proof sketch.* From $ab = cd$ and $a+b = c+d$ one gets $(a-c)(a-d) = 0$ by eliminating $b$ and $d$; either factor forces the ordered pairs to agree. The discriminant identity is the algebraic identity $(p+q)^2 - 4pq = (q-p)^2$. $\square$

**Corollary 3.9 (Completeness of the witness).** An exhaustive gcd scan of the $N$ residues yields $M_1(N)$, hence $s$, hence $(p,q)$ by solving $t^2 - st + N = 0$ in integers. The gcd-sum witness is complete; its cost is $\Theta(N)$ gcd evaluations.

---

## 4. Cost: variance and witness density

The witness is complete, so the interesting question is entirely about cost. Two exact facts control it.

**Theorem 4.1 (Elementary bounds).** For $n \ge 1$, $n^k \le M_k(n)$, since the residue $x = 0$ alone contributes $n^k$. For a semiprime and $k \ge 1$, $M_k(N) \le 4N^k$.

*Proof sketch.* The lower bound is a single-term estimate. For the upper bound, each of the four terms of Theorem 3.3 is at most $N^k$: $(p-1)(q-1) \le N \le N^k$, and $p^k(q-1) \le p^{k-1}\cdot pq \le (pq)^k$ using $p \le N$, similarly for $q$. $\square$

**Definition 4.2.** For $U$ uniform on $\{0,\dots,N-1\}$ put
$$V_k(N) \;=\; \operatorname{Var}\big(\gcd(N,U)^k\big) \;=\; \frac{M_{2k}(N)}{N} - \left(\frac{M_k(N)}{N}\right)^2 .$$

**Theorem 4.3 (Variance is $\Theta(N^{2k-1})$).** For a semiprime $N$ and $k \ge 1$,
$$N^{2k-1} - 16N^{2k-2} \;\le\; V_k(N) \;\le\; 4N^{2k-1}.$$

*Proof sketch.* For the lower bound, $M_{2k}(N) \ge N^{2k}$ gives $M_{2k}/N \ge N^{2k-1}$, while $M_k \le 4N^k$ gives $(M_k/N)^2 \le 16N^{2k-2}$. For the upper bound, $M_{2k} \le 4N^{2k}$ gives $M_{2k}/N \le 4N^{2k-1}$, and the subtracted square is nonnegative. $\square$

The mechanism is transparent: the random variable $\gcd(N,U)^k$ equals $1$ with probability $1 - (p+q-1)/N$, equals $p^k$ or $q^k$ with probability about $1/q$ and $1/p$, and equals $N^k$ with probability exactly $1/N$. The last event contributes $N^{2k}/N = N^{2k-1}$ to the second moment and dominates everything else.

**Theorem 4.4 (First moment is the cheap end).** $V_1(N) \le 4N$, and for $N \ge 32$,
$$\frac{N^2}{8}\,V_1(N) \;\le\; V_2(N).$$

*Proof sketch.* $V_1 \le M_2/N \le 4N$ by Theorem 4.1. Combining with the lower bound $V_2 \ge N^3 - 16N^2$ of Theorem 4.3 and $N \ge 32$ gives $N^3 - 16N^2 \ge \tfrac{N^2}{8}\cdot 4N$, i.e. $N^3 - 16N^2 \ge \tfrac{N^3}{2}$, which holds for $N \ge 32$. $\square$

Interpreted through Chebyshev's inequality, an estimator of $\mathbb{E}[\gcd(N,U)^k]$ to a fixed absolute accuracy requires $\Omega(V_k) = \Omega(N^{2k-1})$ samples. Higher moments are therefore strictly and dramatically worse; the exhaustive $\Theta(N)$ scan at $k = 1$ is the optimal member of the family. Numerically, at $N = 943$ the ratio of Chebyshev sample counts between $k=2$ and $k=1$ is about $8.5 \times 10^5$, and between $k=3$ and $k=1$ about $7.5 \times 10^{11}$.

**Theorem 4.5 (Witness density).** For a semiprime $N = pq$,
$$\#\{\,x < N \;:\; \gcd(N,x) \ne 1\,\} \;=\; p + q - 1 .$$

*Proof sketch.* The complementary set has $\varphi(N) = (p-1)(q-1)$ elements and $N - (p-1)(q-1) = p+q-1$. $\square$

So a single uniform probe meets a nontrivial gcd with probability exactly $(p+q-1)/N$ — the $\Theta(p+q)$ query threshold. For balanced $1024$-bit primes this probability is of order $2^{-1023}$.

---

## 5. Primality, squarefreeness and the two-sided bracket

We now leave semiprimes and analyse $M_k$ on an arbitrary modulus, through its local factors.

**Definition 5.1.** The *local factor* of a part $a \ge 1$ is $L_k(a) = a^k + a - 1$, so $M_k(p) = L_k(p)$ for prime $p$. Put
$$\Pi_k(n) \;=\; \prod_{p^e \| n} L_k(p)^e \;=\; \prod_{p \in \mathrm{pf}(n)} \big(p^k + p - 1\big),$$
the product over the primes of $n$ *with multiplicity*.

**Theorem 5.2 (Gauss-type lower bound; primality detection).** For $n \ge 2$ and $k \ge 1$,
$$M_k(n) \;\ge\; n^k + n - 1 = L_k(n),$$
with equality **if and only if $n$ is prime**.

*Proof sketch.* The divisor form contains the terms $d = n$ (contributing $n^k$) and $d = 1$ (contributing $\varphi(n)$), whence $M_k(n) \ge n^k + \varphi(n)$; and $\varphi(n) \ge n - 1$ fails for composite $n$, so instead one argues that composites contribute an extra divisor term $d$ with $1 < d < n$ whose weight $d^k\varphi(n/d) \ge d$ more than compensates the totient deficiency $n - 1 - \varphi(n)$. For $n$ prime the divisor sum has exactly the two terms $n^k + (n-1)$. $\square$

**Theorem 5.3 (Prime-power strictness and exact deficiency).** For $p$ prime, $k \ge 1$ and $e \ge 2$,
$$M_k(p^e) \;<\; L_k(p)^e ,$$
and the deficiency is explicit. At $e = 2$,
$$L_k(p)^2 - M_k(p^2) \;=\; (p-1)(p^k - 1),$$
and in general, writing $L = L_k(p)$,
$$L^e - M_k(p^e) \;=\; (p-1)\sum_{i=0}^{e-1} p^{ik}\big(L^{\,e-1-i} - p^{\,e-1-i}\big).$$

*Proof sketch.* Induct with the local recursion $M_k(p^{e+1}) = p^kM_k(p^e) + \varphi(p^{e+1})$ against the identity $L^{e+1} = p^kL^e + L^e(p-1)$; the difference of the two recursions telescopes into the displayed sum. Each summand is nonnegative and the $i = 0$ term is positive for $e \ge 2$ since $L > p$. $\square$

**Theorem 5.4 (The two-sided bracket).** For $n \ge 2$ and $k \ge 1$,
$$n^k + n - 1 \;\le\; M_k(n) \;\le\; \Pi_k(n),$$
where the left equality holds exactly when $n$ is prime and the right equality exactly when $n$ is squarefree. The bracket collapses to a single point precisely at the primes.

*Proof sketch.* The left half is Theorem 5.2. For the right half, multiplicativity reduces to prime powers, where Theorem 5.3 gives $M_k(p^e) \le L_k(p)^e$ with equality iff $e \le 1$. $\square$

Numerically at $k = 2$: $M_2(4) = 22 < 25$, $M_2(8) = 92 < 125$, $M_2(9) = 105 < 121$, while $M_2(6) = 55 = \Pi_2(6)$ and $M_2(15) = 319 = \Pi_2(15)$.

---

## 6. The refinement lattice of a modulus

The bracket of Theorem 5.4 is the shadow of a monotonicity statement on the set of all factorisations.

**Definition 6.1.** For a finite list $\ell = (a_1,\dots,a_r)$ of integers $\ge 2$ put
$$E_k(\ell) \;=\; \prod_{i=1}^{r} \big(a_i^k + a_i - 1\big),$$
the moment *predicted* by the factorisation $n = a_1\cdots a_r$. For $r = 2$ we also write $E_k(a,b) = (a^k+a-1)(b^k+b-1)$, which expands to
$$E_k(a,b) \;=\; a^k(b-1) + b^k(a-1) + (a-1)(b-1) + (ab)^k,$$
so that $E_k(p,q) = M_k(pq)$ for a genuine prime pair, by Theorem 3.3.

The factorisations of a fixed $n$ form a poset under refinement: $\ell'$ refines $\ell$ if $\ell'$ is obtained by repeatedly splitting parts. The minimum is the trivial factorisation $[\,n\,]$ and the maximum is the prime factorisation.

**Lemma 6.2 (Refinement law).** For $u, v \ge 2$ and $k \ge 1$,
$$(uv)^k + uv - 1 \;<\; (u^k+u-1)(v^k+v-1).$$

*Proof sketch.* Expand the right-hand side: $(uv)^k + u^kv + uv^k - u^k - v^k + uv - u - v + 1$. Subtracting the left side leaves $u^k(v-1) + v^k(u-1) - (u - 1) - (v-1) = (v-1)(u^k - 1) + (u-1)(v^k-1) > 0$ for $u,v\ge 2$, $k \ge 1$. $\square$

Thus **splitting a part strictly raises the prediction**, and $E_k$ is strictly increasing for the refinement order. Two uniqueness statements at the ends follow.

**Theorem 6.3 (Unique minimiser).** For any factorisation $\ell$ of $n$ into parts $\ge 2$, $E_k(\ell) \ge n^k + n - 1$, with equality if and only if $\ell = [\,n\,]$. Equivalently, as soon as $\ell$ has two parts the inequality is strict.

*Proof sketch.* Induct on the length using Lemma 6.2 with $u$ the first part and $v$ the product of the rest (which is $\ge 2$ when the tail is nonempty), and the inductive lower bound for the tail. $\square$

**Theorem 6.4 (Unique maximiser).** For any factorisation $\ell$ of $n$ into parts $\ge 2$, $E_k(\ell) \le \Pi_k(n)$, with equality if and only if every part of $\ell$ is prime.

*Proof sketch.* $\Pi_k$ is completely multiplicative, so $\Pi_k(n) = \prod_i \Pi_k(a_i)$; and for each part, $L_k(a) \le \Pi_k(a)$ with equality iff $a$ is prime — the case $a$ composite being a strict instance of Lemma 6.2 applied to a nontrivial splitting of $a$. Multiplying the local comparisons, one strict factor makes the product strict. $\square$

**Corollary 6.5 (No collision involves an extremal factorisation).** If two factorisations of the same modulus have equal predicted moments and one of them is the prime factorisation, then the other is a permutation of it; likewise if one of them is the trivial factorisation $[\,n\,]$.

The combinatorial complement is elementary but essential:

**Lemma 6.6.** A factorisation of $n$ into parts $\ge 2$ has at most $\Omega(n)$ parts, with equality if and only if every part is prime.

*Proof sketch.* $\Omega$ is additive over products and $\Omega(a) \ge 1$ for $a \ge 2$, with $\Omega(a) = 1$ iff $a$ is prime. $\square$

---

## 7. Inversion: which moments determine the factorisation?

We now answer the inversion question: given the modulus and the value of a moment, how many candidate factorisations reproduce it?

### 7.1 $k = 2$: an exact collision law and a complete census

**Theorem 7.1 (Collision law at $k=2$).** If $ab = cd$ then
$$E_2(a,b) = E_2(c,d) \iff \big(a+b = c+d\big) \ \text{ or } \ \big(a+b+c+d = ab - 1\big).$$

*Proof sketch.* With $N = ab = cd$ one has $E_2(a,b) = N^2 + 3N + 1 + (N-1)(a+b) - (a+b)^2$. Setting $\sigma = a+b$, $\tau = c+d$, the difference of the two predictions factors as $(\sigma - \tau)\,(N - 1 - \sigma - \tau)$, whose vanishing is exactly the stated disjunction. $\square$

The second alternative is the involution $\sigma \mapsto N - 1 - \sigma$, under which the second moment polynomial is invariant.

**Theorem 7.2 (Complete classification of two-part second-moment collisions).** Suppose $2 \le a \le b$, $c \le d$, $a < c$, $ab = cd$ and $E_2(a,b) = E_2(c,d)$. Then
$$(a,b,c,d) = (2,14,4,7) \quad\text{or}\quad (a,b,c,d) = (2,18,3,12).$$
That is, $N = 28$ and $N = 36$ are the only moduli in the whole number line carrying a genuine second-moment collision between two-part factorisations.

*Proof sketch.* By Theorem 7.1 and $a < c$ the first alternative is impossible (equal sum and product force equal pairs), so $a+b+c+d+1 = N$. Since $a \ge 2$ and $c \ge 3$, one has $2(a+b) \le 4 + N$ and $3(c+d) \le 9 + N$; adding these to the collision equation forces $N \le 36$, then $a \le 6$ and $c \le 6$, and a finite case check over the surviving quadruples yields exactly the two solutions. $\square$

Both collisions involve a composite part on each side; in particular no distinct-prime semiprime is affected.

### 7.2 $k \ge 3$: strict monotonicity in the spread

**Theorem 7.3 (Spread monotonicity, unconditional).** Let $2 \le a < c \le d < b$ with $ab = cd$, and let $k \ge 3$. Then
$$E_k(c,d) \;<\; E_k(a,b).$$
In words: among the factorisations of a fixed modulus into two parts, the prediction increases strictly with the spread $b - a$.

*Proof sketch.* Write $E_k(a,b) - E_k(c,d)$ using the common value $N^k = (ab)^k = (cd)^k$, so that only the "tail" $T_k(a,b) = a^k(b-1) + b^k(a-1) + (a-1)(b-1)$ matters. Since $b > d \ge c > a$, the term $b^k(a-1)$ dominates. A first argument establishes the inequality under the mild side condition $a+b+c+d < ab$, by factoring the difference through a cubic bracket that is positive on the admissible range $2 \le a < c \le d$. The side condition holds automatically once $ab \ge 31$; below that the possible quadruples are enumerable and reduce to exactly seven exceptions,
$$(2,6;3,4),\ (2,8;4,4),\ (2,9;3,6),\ (2,10;4,5),\ (2,12;3,8),\ (2,12;4,6),\ (2,15;3,10),$$
each of the shape $a = 2$. For these a separate, sharper estimate applies: with $a = 2$ one has $T_k(2,b) = 2^k(b-1) + b^k + (b-1)$, and the base inequality $T_3(c,d) < b^3$ propagates upward in $k$, giving $E_k(c,d) < E_k(2,b)$ for every $k \ge 3$. $\square$

**Corollary 7.4 (Identifiability at $k \ge 3$).** For $k \ge 3$, any two factorisations $ab = cd$ of the same modulus with $2 \le a \le b$, $2 \le c \le d$ and $E_k(a,b) = E_k(c,d)$ satisfy $a = c$ and $b = d$.

*Proof sketch.* Trichotomy on $a$ versus $c$; the two nonequal cases contradict Theorem 7.3, and $a = c$ forces $b = d$ by cancelling in $ab = cd$. $\square$

### 7.3 The capstone for semiprimes

**Theorem 7.5 (Every moment factors a semiprime).** Let $N = pq$ with $p < q$ prime, let $k \ge 1$, and let $2 \le a \le b$ with $ab = N$ and $E_k(a,b) = M_k(N)$. Then $a = p$ and $b = q$.

*Proof sketch.* Three regimes. At $k = 1$, matching predictions forces $a + b = p + q$ (the $k=1$ prediction is affine in the trace), and Theorem 3.8 concludes. At $k = 2$, a mismatch would be a two-part second-moment collision, which by Theorem 7.2 must be $28$ or $36$; in both, a part is composite, contradicting that one side of the collision is the prime pair $(p,q)$. At $k \ge 3$, apply Corollary 7.4 directly. $\square$

So the "root ambiguity" that one might fear at higher $k$ never materialises: the family carries *complete* information at every order. What distinguishes the orders is only the cost of obtaining the value, as quantified in Section 4.

### 7.4 Beyond semiprimes: separation controlled by $\Omega$

**Theorem 7.6 (No collision below three prime factors).** Let $k \ge 1$ and let $n \ge 2$ with $\Omega(n) \le 2$. If two factorisations $\ell, m$ of $n$ into parts $\ge 2$ satisfy $E_k(\ell) = E_k(m)$, then $\ell$ and $m$ agree up to order.

*Proof sketch.* By Lemma 6.6 both lists have length at most $2$. If either has length $1$, it is the trivial factorisation and Corollary 6.5 applies. Otherwise both have length exactly $2$, so by Lemma 6.6 again all their parts are prime, and Corollary 6.5 applies at the other end. $\square$

**Corollary 7.7 (Semiprime case).** For $n = pq$ a product of two primes and any $k \ge 1$, the predicted moment is injective on factorisations up to order — including at $k = 2$, where it is not injective in general.

**Theorem 7.8 (Three prime factors).** Let $n \ge 2$ with $\Omega(n) \le 3$. If $k = 1$, or if $k \ge 3$, then equal predicted moments imply equal factorisations up to order.

*Proof sketch.* Theorem 7.6 leaves only the two-part factorisations unconstrained at $\Omega(n)=3$. On two-part lists $E_k$ *is* the pair prediction, so the required separation is exactly Corollary 7.4 for $k \ge 3$, and for $k=1$ the elementary sum-and-product argument of Theorem 3.8. Sorted separation upgrades to separation up to order by symmetry of $E_k$. $\square$

**Sharpness.** Both hypotheses are sharp in the smallest possible way.
* At $k = 2$ the modulus $28$ has $\Omega = 3$ and collides ($2\cdot14$ versus $4\cdot7$, both predicting $1045$), so the $k \ge 3$ hypothesis in Theorem 7.8 cannot be dropped. The third moment separates the same pair.
* At $k = 1$ the smallest collision is $234 = 2\cdot9\cdot13 = 3\cdot3\cdot26$ (both predicting the same first moment), and $\Omega(234) = 4$, so the $\Omega \le 3$ hypothesis cannot be dropped either.

An exhaustive census over all moduli $n \le 400$ confirms the picture: at $k=3$ and $k=4$ there are no collisions at all in that range; at $k=1$ the only ones are $234$, $288$ and $400$, all with $\Omega \ge 4$; and at $k=2$ every collision is a multiple of the two base collisions $28$ and $36$, always with $\Omega \ge 3$ and a composite part on both sides.

---

## 8. Algorithms

Three algorithms summarise the computational content.

**Algorithm A (Trace-witness factoring; exact, $\Theta(N)$).**
Compute $M_1(N) = \sum_{x<N}\gcd(N,x)$ by an exhaustive scan; set $s = (4N + 1 - M_1)/2$; compute $D = s^2 - 4N$ and $r = \sqrt{D}$; return $\big((s-r)/2, (s+r)/2\big)$. Correct by Corollary 3.6 and Theorem 3.8. Cost: $N$ gcd evaluations, i.e. $O(N\log N)$ bit operations — exponential in $\log N$ and worse than trial division by a constant-free comparison of exponents.

**Algorithm B (Moment evaluation from a known factorisation; $O(\sqrt{n})$ or better).**
Given the factorisation $n = \prod p_i^{e_i}$, return $\prod_i M_k(p_i^{e_i})$ using Proposition 2.4. This is the fast route, and it is *circular* from the adversary's viewpoint: it consumes the very factorisation the moment was supposed to reveal.

**Algorithm C (Moment inversion / candidate scan).**
Given $n$, an exponent $k$ and an observed value $V$, enumerate the divisors $a \le \sqrt n$ and return every pair $(a, n/a)$ with $E_k(a, n/a) = V$. By Theorem 7.5 the output is a single pair whenever $n$ is a distinct-prime semiprime and $k \ge 1$; by Theorem 7.2 the only exceptional moduli for two-part factorisations at $k = 2$ are $28$ and $36$. Cost: $O(\sqrt n)$ divisor trials — again exponential in $\log n$, and it presumes an oracle for $V$.

The three together delimit the situation exactly. Getting the value is $\Theta(N)$ unless you already have the factorisation; given the value, inverting is trivial and unambiguous.

---

## 9. Discussion: four independent obstructions

It is worth isolating the four distinct reasons the family fails to yield a factoring algorithm, because they are logically independent and each would suffice.

1. **Symmetry.** By Theorem 3.4, $M_k = F_k(N,s)$: the hidden primes appear only through their elementary symmetric functions. Consequently the trace is a *ceiling*, not a stepping stone: no member of the family, and no combination of members, can reveal anything about $(p,q)$ beyond $s$. That this ceiling happens to be sufficient for factoring is a feature of two-prime moduli, not of the statistic.

2. **Aggregation cost.** The value is a sum over all $N$ residues. Statistical shortcuts are ruled out quantitatively by Theorem 4.3: the variance $\Theta(N^{2k-1})$ is dominated by the single jackpot residue $x=0$, and Theorem 4.4 shows the hierarchy is strictly increasing in cost. A uniform probe meets a nontrivial gcd with probability only $(p+q-1)/N$ (Theorem 4.5).

3. **Circularity.** The polynomial-time route to the value, the divisor form of Theorem 2.2, needs the factorisation of $n$; the closed form of Theorem 3.4 needs $s$; and the only factorisation-free route is enumeration.

4. **Known method.** $M_1(n) = \sum_{d\mid n} d\,\varphi(n/d)$ is the classical gcd-sum function, and the entire family is the Dirichlet convolution $\mathrm{Id}_k * \varphi$ — a standard specialisation of arithmetic-function machinery. Nothing in the family is new as an object; what is new here is the exact accounting of what it can and cannot deliver.

What is genuinely positive in the analysis is the structure theory of Sections 5–7. The bracket $n^k + n - 1 \le M_k(n) \le \Pi_k(n)$ with its two exact equality characterisations (prime; squarefree), the exact prime-power deficiency formula, the strict refinement law, the uniqueness of both extremes of the refinement order, the complete census of second-moment collisions, and the unconditional identifiability at every $k \ge 3$ are statements about the arithmetic of $\mathrm{Id}_k * \varphi$ that stand on their own, independent of any cryptographic motivation.

---

## 10. Future directions

Several concrete questions remain.

* **The general $r$-factor conjecture.** Theorems 7.6 and 7.8 separate all factorisations of moduli with $\Omega(n) \le 2$ (all $k$) and $\Omega(n) \le 3$ ($k=1$ and $k\ge3$). Is it true that for $k \ge 3$ the predicted moment separates all factorisations of *every* modulus? The census up to $400$ finds no counterexample. The obstruction to a proof is that the pair-separation input handles only two-part factorisations, and the extremal uniqueness of Section 6 constrains only the ends of the lattice; the interior of the refinement order at $\Omega(n) \ge 4$ needs a new inequality.

* **The $k = 1$ collision structure.** The smallest first-moment collision is $234 = 2\cdot9\cdot13 = 3\cdot3\cdot26$. Is there a classification analogous to Theorem 7.2 — for instance, a parametric family generating all first-moment collisions?

* **Sharp constants in the variance.** Theorem 4.3 pins $V_k$ to $[N^{2k-1} - 16N^{2k-2},\, 4N^{2k-1}]$. The true leading constant should be $1 + o(1)$ for balanced semiprimes; establishing an asymptotic $V_k \sim N^{2k-1}$ with an explicit error term would sharpen the sampling lower bound.

* **Deficiency at general moduli.** Theorem 5.3 gives $\Pi_k(n) - M_k(n)$ exactly at prime powers. A clean closed form for a general modulus — as a sum over the non-squarefree part — would give a quantitative version of the squarefreeness characterisation in Theorem 5.4.

* **Other symmetric aggregates.** The trace is the ceiling *for this family*. Which other elementary aggregates of a semiprime have the same ceiling, and is there a natural class of statistics for which the trace can be proved to be the maximum extractable symmetric datum?

---

## 11. Conclusion

The gcd moments $M_k(N) = \sum_{x<N}\gcd(N,x)^k$ of a semiprime form a closed family: each is an explicit polynomial in the public modulus and the trace $s = p+q$; the first moment determines the trace; the trace determines the factorisation; and every higher moment is a function of the modulus and the first moment. Inversion is unambiguous at every order — the observed moment of a distinct-prime semiprime is matched by exactly one candidate factorisation — and the residual ambiguity in the general problem is completely mapped: only $28$ and $36$ collide at $k=2$ among two-part factorisations, collisions require $\Omega \ge 3$, and at $k=1$ or $k \ge 3$ they require $\Omega \ge 4$.

What the family does not do is factor efficiently, and the reasons are exact rather than heuristic: symmetry caps the information at the trace, the variance $\Theta(N^{2k-1})$ caps sampling, the fast evaluation route is circular, and the object itself is classical. The gcd moment is a perfect example of a secret that is fully written down and still perfectly safe — because the only way to read it is to do the work you were trying to avoid.
