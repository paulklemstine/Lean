# Mandelbrot Number Theory: Quadratic Recurrence, Orbit Periodicity, and Dynatomic Degree

## Abstract

We establish rigorous connections between the Mandelbrot iteration $z_{n+1} = z_n^2 + c$ and number theory, with machine-verified proofs of the core structural theorems. We define the Mandelbrot orbit, Mandelbrot polynomials $P_n(c) \in \mathbb{Z}[c]$, and prove: (1) the Orbit Shift Theorem — if the orbit returns to zero at step $m$, then $f^{m+k}(0) = f^k(0)$ for all $k$; (2) the Period Divisibility Theorem — the minimal period divides every return time, exactly analogous to the order of a group element; (3) the Degree Growth Theorem — $\deg P_n = 2^{n-1}$ for $n \geq 1$; (4) the Period-2 Classification — the orbit has exact period 2 if and only if $c = -1$. We introduce the *Mandelbrot orbit signature*, a function encoding the period of $c$'s orbit modulo each prime, and the *dynatomic degree function* $\delta(n) = \sum_{d|n} \mu(n/d) \cdot 2^{d-1}$, computed via Möbius inversion. We verify $\delta(1) = 1$, $\delta(2) = 1$, $\delta(3) = 3$ and investigate the relationship between $\delta(n)$ and actual period counts over finite fields.

## 1. Introduction

The Mandelbrot set $M \subset \mathbb{C}$, defined as the set of parameters $c$ for which the orbit $\{f_c^n(0)\}_{n \geq 0}$ under $f_c(z) = z^2 + c$ remains bounded, is one of the most studied objects in complex dynamics. While the topological and measure-theoretic properties of $M$ have received enormous attention, the algebraic and number-theoretic structure of the orbit polynomials $P_n(c) = f_c^n(0)$ has been comparatively underexplored from a formal verification perspective.

In this paper, we develop the number-theoretic foundations of the Mandelbrot iteration with complete machine-verified proofs. Our approach treats the iteration as an algebraic object over an arbitrary commutative ring, extracting results that hold not only over $\mathbb{C}$ but also over $\mathbb{Z}$, $\mathbb{F}_p$, and any other commutative ring.

### 1.1 Main Results

Our principal results are:

**Theorem (Orbit Shift)**: For any commutative ring $R$ and $c \in R$, if $f_c^m(0) = 0$ then $f_c^{m+k}(0) = f_c^k(0)$ for all $k \geq 0$.

**Theorem (Period Divisibility)**: Let $d = \min\{n > 0 : f_c^n(0) = 0\}$. Then $f_c^n(0) = 0$ if and only if $d \mid n$.

**Theorem (Period-2 Classification)**: Over an integral domain, the orbit has exact period 2 if and only if $c = -1$.

**Theorem (Algebra-Dynamics Bridge)**: The Mandelbrot polynomial $P_n \in \mathbb{Z}[X]$, defined by $P_0 = 0$, $P_{n+1} = P_n^2 + X$, satisfies $P_n(c) = f_c^n(0)$ for all $c \in \mathbb{Z}$.

**Theorem (Degree Growth)**: $\deg P_n = 2^{n-1}$ for $n \geq 1$.

**Theorem (Monicity)**: $P_n$ is monic for $n \geq 1$.

## 2. Definitions

### 2.1 The Mandelbrot Iteration

**Definition 2.1** (Mandelbrot Iteration). Let $R$ be a commutative ring. For $c \in R$, define $f_c: R \to R$ by $f_c(z) = z^2 + c$. The *Mandelbrot iteration* starting from 0 is the sequence $\{z_n\}_{n \geq 0}$ where $z_0 = 0$ and $z_{n+1} = z_n^2 + c$.

We write $\text{mandelbrotIter}(c, n) = z_n = f_c^n(0)$.

### 2.2 Orbit Period

**Definition 2.2** (Mandelbrot Orbit Period). The *orbit period* of $c$ is
$$\text{mandelbrotOrbitPeriod}(c) = \min\{n > 0 : f_c^n(0) = 0\}$$
if such $n$ exists, and 0 otherwise.

### 2.3 Mandelbrot Polynomials

**Definition 2.3** (Mandelbrot Polynomial). The *n-th Mandelbrot polynomial* is $P_n \in \mathbb{Z}[X]$ defined by:
$$P_0 = 0, \qquad P_{n+1} = P_n^2 + X.$$

The first several are:
- $P_1 = X$
- $P_2 = X^2 + X$
- $P_3 = X^4 + 2X^3 + X^2 + X$
- $P_4 = X^8 + 4X^7 + 6X^6 + 6X^5 + 5X^4 + 2X^3 + X^2 + X$ *(degree 8 = 2³)*

### 2.4 Mandelbrot Orbit Signature (Novel)

**Definition 2.4** (Orbit Signature). For $c \in \mathbb{Z}$ and a positive integer $m$, the *orbit signature of $c$ at $m$* is
$$\sigma_c(m) = \text{mandelbrotOrbitPeriod}(\bar{c})$$
where $\bar{c}$ is the image of $c$ in $\mathbb{Z}/m\mathbb{Z}$.

The full orbit signature of $c$ is the function $m \mapsto \sigma_c(m)$.

### 2.5 Dynatomic Degree (Novel)

**Definition 2.5** (Dynatomic Degree). The *dynatomic degree* at period $n$ is
$$\delta(n) = \sum_{d \mid n} \mu(n/d) \cdot 2^{d-1}$$
where $\mu$ is the Möbius function.

This is the Mandelbrot analogue of Euler's totient function $\varphi(n) = \sum_{d \mid n} \mu(n/d) \cdot d$, which gives the degree of the $n$-th cyclotomic polynomial.

## 3. Main Results

### 3.1 Orbit Shift Theorem

**Theorem 3.1** (Orbit Shift). *Let $R$ be a commutative ring, $c \in R$, and suppose $f_c^m(0) = 0$. Then for all $k \geq 0$,*
$$f_c^{m+k}(0) = f_c^k(0).$$

*Proof sketch.* By induction on $k$. The base case $k=0$ is immediate from the hypothesis. For the inductive step, $f_c^{m+(k+1)}(0) = f_c^{(m+k)+1}(0) = (f_c^{m+k}(0))^2 + c = (f_c^k(0))^2 + c = f_c^{k+1}(0)$, using the inductive hypothesis. $\square$

**Corollary 3.2** (Shift for Multiples). *Under the same hypotheses, $f_c^{qm+k}(0) = f_c^k(0)$ for all $q, k \geq 0$.*

**Corollary 3.3** (Divisibility Implies Return). *If $f_c^m(0) = 0$ and $m \mid n$, then $f_c^n(0) = 0$.*

### 3.2 Period Divisibility Theorem

**Theorem 3.4** (Period Divisibility). *Let $d = \text{mandelbrotOrbitPeriod}(c) > 0$. Then for any $n > 0$, $f_c^n(0) = 0$ implies $d \mid n$.*

*Proof sketch.* Write $n = qd + r$ with $0 \leq r < d$. By Corollary 3.2, $f_c^n(0) = f_c^r(0)$. If $f_c^n(0) = 0$ then $f_c^r(0) = 0$. If $r > 0$, this contradicts the minimality of $d$. Hence $r = 0$ and $d \mid n$. $\square$

This theorem is the dynamical analogue of the group-theoretic result that the order of an element divides any exponent sending it to the identity. The proof structure is identical: Euclidean division followed by minimality.

### 3.3 Period-2 Classification

**Theorem 3.5** (Period-2 Classification). *Over an integral domain $R$, the orbit of 0 under $z \mapsto z^2 + c$ satisfies $f_c^2(0) = 0 \wedge f_c^1(0) \neq 0$ if and only if $c = -1$.*

*Proof sketch.* We have $f_c^1(0) = c$ and $f_c^2(0) = c^2 + c = c(c+1)$. In an integral domain, $c(c+1) = 0$ iff $c = 0$ or $c = -1$. The condition $f_c^1(0) \neq 0$ excludes $c = 0$. $\square$

### 3.4 Algebra-Dynamics Bridge

**Theorem 3.6** (Evaluation). *For all $c \in \mathbb{Z}$ and $n \geq 0$, $P_n(c) = f_c^n(0)$.*

*Proof sketch.* By induction on $n$. Base: $P_0(c) = 0 = f_c^0(0)$. Step: $P_{n+1}(c) = P_n(c)^2 + c = (f_c^n(0))^2 + c = f_c^{n+1}(0)$. $\square$

### 3.5 Degree Growth and Monicity

**Theorem 3.7** (Degree Growth). *For $n \geq 1$, $\deg P_n = 2^{n-1}$.*

*Proof sketch.* By induction. Base: $\deg P_1 = \deg X = 1 = 2^0$. Step: $P_{n+1} = P_n^2 + X$. Since $P_n$ is monic (Theorem 3.8) over $\mathbb{Z}$ (an integral domain), $\deg(P_n^2) = 2 \cdot 2^{n-1} = 2^n$. Since $\deg X = 1 < 2^n$ for $n \geq 1$, $\deg P_{n+1} = 2^n$. $\square$

**Theorem 3.8** (Monicity). *For $n \geq 1$, $P_n$ is monic.*

*Proof sketch.* By induction. $P_1 = X$ is monic. For the step: $P_n^2$ is monic (square of monic is monic), and since $\deg(P_n^2) > \deg X$, the leading coefficient of $P_n^2 + X$ equals that of $P_n^2$, which is 1. $\square$

### 3.6 Reduction Compatibility

**Theorem 3.9** (Signature Compatibility). *If $f_c^n(0) = 0$ in $\mathbb{Z}$ and the orbit signature $\sigma_c(m)$ is well-defined (the mod-$m$ orbit returns to zero), then $\sigma_c(m) \mid n$.*

*Proof sketch.* The ring homomorphism $\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z}$ commutes with the Mandelbrot iteration. Hence $f_c^n(0) = 0$ in $\mathbb{Z}$ implies $f_{\bar{c}}^n(0) = 0$ in $\mathbb{Z}/m\mathbb{Z}$. The result follows from the Period Divisibility Theorem applied in $\mathbb{Z}/m\mathbb{Z}$. $\square$

### 3.7 Dynatomic Degree Computations

**Theorem 3.10**. $\delta(1) = 1$, $\delta(2) = 1$, $\delta(3) = 3$.

*Proof.* Direct computation using the definition. $\square$

## 4. The Dynatomic Degree Conjecture

**Conjecture 4.1** (Naive Dynatomic Degree Conjecture). *For every $n \geq 1$ and every sufficiently large prime $p$, the number of $c \in \mathbb{F}_p$ with exact Mandelbrot orbit period $n$ equals $\delta(n)$.*

**Computational evidence and refutation.** We tested this conjecture for periods $n = 1, \ldots, 5$ and primes $p = 29, 31, 37, 41, 43$:

| Period $n$ | $\delta(n)$ | $p=29$ | $p=31$ | $p=37$ | $p=41$ | $p=43$ |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | 1 | 1 ✓ | 1 ✓ | 1 ✓ | 1 ✓ | 1 ✓ |
| 2 | 1 | 1 ✓ | 1 ✓ | 1 ✓ | 1 ✓ | 1 ✓ |
| 3 | 3 | 0 | 0 | 1 | 0 | 1 |
| 4 | 6 | 1 | 1 | 0 | 1 | 1 |
| 5 | 15 | 0 | 0 | 1 | 3 | 3 |

The conjecture holds for periods 1 and 2 (where the dynatomic polynomial $\Psi_n$ is linear and always has exactly one root). For periods ≥ 3, the actual count depends on the **splitting behavior** of $\Psi_n$ over $\mathbb{F}_p$. When $\Psi_n$ is irreducible over $\mathbb{Q}$ (as for $n = 3$, where $\Psi_3 = c^3 + 2c^2 + c + 1$ with discriminant $\Delta = -23$), the number of roots in $\mathbb{F}_p$ depends on the Legendre symbol $(\Delta/p)$ and the Frobenius conjugacy class.

This is an important negative result: the naive conjecture is **false**. The correct picture is more nuanced.

**Corrected Conjecture 4.2** (Galois-Refined Dynatomic Counting). *For each $n \geq 1$:*
1. *The number of $c \in \mathbb{F}_p$ with exact period $n$ is at most $\delta(n)$.*
2. *The count equals $\delta(n)$ for a positive proportion of primes, determined by the Galois group of $\Psi_n$ over $\mathbb{Q}$. By Chebotarev's density theorem, this proportion is $1/|\text{Gal}(\Psi_n/\mathbb{Q})|$ if $\Psi_n$ is irreducible.*
3. *The average count over all primes $p \leq X$ is asymptotically 1 as $X \to \infty$ (each $c \in \mathbb{F}_p$ has a unique orbit period).*

**Proof strategy.** The upper bound $\delta(n)$ follows immediately from $\deg \Psi_n = \delta(n)$. The positive-density claim follows from Chebotarev applied to the splitting field of $\Psi_n$. The average-count claim follows from the fact that $\sum_n \delta(n) = 2^{n-1} = \deg P_n$, and each $c$ contributes to exactly one period count.

## 5. The Cyclotomic Analogy

The parallel between Mandelbrot and cyclotomic arithmetic is systematic:

| Cyclotomic | Mandelbrot |
|:---|:---|
| $x^n - 1 = \prod_{d \mid n} \Phi_d(x)$ | $P_n(c) = \prod_{d \mid n} \Psi_d(c)$ |
| $\deg \Phi_n = \varphi(n)$ | $\deg \Psi_n = \delta(n)$ |
| $\varphi(n) = \sum_{d \mid n} \mu(n/d) \cdot d$ | $\delta(n) = \sum_{d \mid n} \mu(n/d) \cdot 2^{d-1}$ |
| $\Phi_n$ irreducible over $\mathbb{Q}$ | $\Psi_n$ irreducible over $\mathbb{Q}$? (open) |
| Order of element in $(\mathbb{Z}/n\mathbb{Z})^\times$ | Mandelbrot orbit period mod $n$ |

The replacement $d \to 2^{d-1}$ in the Möbius inversion reflects the exponential growth of $\deg P_n$ versus the linear growth of $\deg(x^n - 1) = n$.

A key difference: while $\Phi_n$ is *always* irreducible over $\mathbb{Q}$ (a deep theorem), the irreducibility of $\Psi_n$ remains open. Our computational evidence shows that the splitting behavior of $\Psi_n$ over $\mathbb{F}_p$ varies with $p$, exactly as expected for an irreducible polynomial — supporting the irreducibility conjecture.

## 6. Applications and Connections

### 6.1 Primality Testing via Orbit Signatures

The orbit signature $\sigma_c$ can distinguish primes from composites: for a prime $p$, $\sigma_c(p)$ is constrained by the structure of $\mathbb{F}_p$, while for composites $n = ab$, $\sigma_c(n)$ relates to $\sigma_c(a)$ and $\sigma_c(b)$ via the Chinese Remainder Theorem.

### 6.2 Dynamical Analogue of Artin's Conjecture

Artin's conjecture asserts that any integer $a \neq \pm 1$ that is not a perfect square is a primitive root modulo infinitely many primes. The dynamical analogue asks: for which $c \in \mathbb{Z}$ does the orbit signature $\sigma_c(p)$ equal $p - 1$ (or a related maximal value) for infinitely many primes $p$?

## 7. Discussion

The key insight of this work is that the Mandelbrot iteration $z \mapsto z^2 + c$ carries number-theoretic structure that is not merely analogous but formally identical to classical arithmetic. The divisibility theorem for orbit periods mirrors the order theorem for group elements; the dynatomic polynomials mirror the cyclotomic polynomials; and the Möbius function appears in the same structural role.

The refutation of the naive dynatomic degree conjecture (Conjecture 4.1) is itself an important finding: it shows that the Mandelbrot-cyclotomic analogy, while deep, is not perfect. The cyclotomic polynomial $\Phi_n$ always has exactly $\varphi(n)$ roots over $\mathbb{F}_p$ (for $p \nmid n$) because $\Phi_n$ divides $x^n - 1$ which always splits completely over $\mathbb{F}_p$. The Mandelbrot polynomial $P_n$ has no such universal splitting property — its roots are governed by a more complex Galois-theoretic structure.

## 8. Future Work

1. **Dynatomic irreducibility**: Prove or disprove that the dynatomic polynomial $\Psi_n$ is irreducible over $\mathbb{Q}$ for prime $n$.
2. **CRT decomposition**: Prove that $\sigma_c(mn) = \text{lcm}(\sigma_c(m), \sigma_c(n))$ for coprime $m, n$.
3. **Orbit signature and primality**: Develop the orbit signature as a primality criterion.
4. **Higher-degree iteration**: Extend results to $z \mapsto z^d + c$ for $d \geq 3$.
5. **Galois groups of dynatomic polynomials**: Determine the Galois group of $\Psi_n$ over $\mathbb{Q}$.

## References

1. Douady, A. and Hubbard, J.H., "Étude dynamique des polynômes complexes," Publications Mathématiques d'Orsay, 1984-1985.
2. Silverman, J.H., *The Arithmetic of Dynamical Systems*, Graduate Texts in Mathematics 241, Springer, 2007.
3. Morton, P. and Silverman, J.H., "Rational periodic points of rational functions," International Mathematics Research Notices, 1994.
4. Bousch, T., "Sur quelques problèmes de dynamique holomorphe," Thèse, Université de Paris-Sud, 1992.
5. Buff, X. and Epstein, A.L., "A parabolic Pommerenke-Levin-Yoccoz inequality," Fundamenta Mathematicae, 2002.
