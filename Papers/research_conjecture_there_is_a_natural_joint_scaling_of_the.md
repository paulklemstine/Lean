# Exact Defect Factorization and Two-Cutoff Bounds for Finite Prime-Occupation Partitions

## Abstract

We study finite partition functions assembled from independent geometric occupation modes. For a finite index set $I$, local weights $0\le q_i<1$, and occupation ceiling $N$, define the truncated product

$$
T_N(q)=\prod_{i\in I}\sum_{n=0}^{N}q_i^n
$$

and the completed finite product

$$
C(q)=\prod_{i\in I}(1-q_i)^{-1}.
$$

We prove the exact defect factorization

$$
T_N(q)=C(q)\prod_{i\in I}(1-q_i^{N+1}),
$$

and the quantitative estimate

$$
0\le C(q)-T_N(q)\le C(q)\sum_{i\in I}q_i^{N+1}.
$$

For an arbitrary real target $Z$, this yields a canonical two-source error decomposition

$$
|Z-T_N(q)|\le |Z-C(q)|+C(q)\sum_{i\in I}q_i^{N+1}.
$$

Specializing to prime modes below $x$ with Boltzmann weights $q_p=p^{-\beta}$, $\beta>0$, separates the error caused by omitted prime modes from the error caused by truncating occupation numbers. In the Euler-product region $\beta>1$, one may take $Z=\zeta(\beta)$. We give proofs, computational algorithms, examples, complexity estimates, and consequences for joint cutoff selection. The results are finite and unconditional; they do not assert analytic continuation or conclusions about zeta zeros.

## 1. Introduction

Euler products express global arithmetic objects as products of local prime factors. Partition functions express the total weight of a system as a sum over configurations, and independent modes turn that sum into a product of local sums. For prime-indexed modes these two constructions coincide: the local geometric factor

$$
(1-p^{-\beta})^{-1}=1+p^{-\beta}+p^{-2\beta}+\cdots
$$

is both an Euler factor and the partition function of a mode whose occupation energy is proportional to $\log p$.

Any finite computation introduces at least one cutoff. In the model considered here there are naturally two. A **mode cutoff** retains only finitely many primes, for example those below $x$. An **occupation cutoff** allows each retained prime to occur only with exponent at most $N$. These operations have distinct mathematical meanings. Increasing $x$ introduces new prime factors, while increasing $N$ permits higher powers of primes already present.

The purpose of this paper is to separate these two approximation mechanisms exactly. The algebraic core is the finite geometric-series formula. Its product over modes identifies a multiplicative occupation defect. A finite multiplicative union bound then converts that product defect into an additive sum of local tails. Finally, the triangle inequality inserts the completed finite product as an intermediate quantity between a target and the doubly truncated partition.

This procedure yields a robust error architecture. No estimate for omitted primes is needed to control the occupation tail. Conversely, any available prime-tail estimate can be inserted into the first term without changing the occupation analysis. Such modularity is valuable both conceptually and computationally.

## 2. Finite occupation systems

### 2.1. Configurations and weights

Let $I$ be a finite set of modes. A configuration with occupation ceiling $N\in\mathbb{N}$ is a function

$$
\nu:I\longrightarrow\{0,1,\ldots,N\}.
$$

Assign each mode $i\in I$ a real local weight $q_i$. The weight of a configuration is

$$
w(\nu)=\prod_{i\in I}q_i^{\nu(i)}.
$$

The physically and quantitatively relevant hypotheses are

$$
0\le q_i<1\qquad(i\in I).
$$

Nonnegativity ensures positive configuration weights, while strict subunit size ensures convergence of each untruncated geometric series.

### Definition 2.1 (Truncated occupation product)

For $N\in\mathbb{N}$, the truncated partition function is

$$
T_N(q)=\prod_{i\in I}\left(\sum_{n=0}^{N}q_i^n\right).
$$

Expanding the product shows equivalently that

$$
T_N(q)=\sum_{\nu:I\to\{0,\ldots,N\}}w(\nu).
$$

### Definition 2.2 (Completed finite product)

The completed finite occupation product is

$$
C(q)=\prod_{i\in I}\frac{1}{1-q_i}.
$$

Because $I$ is finite and $q_i<1$, every denominator is positive. The term “completed” here refers only to removal of the occupation ceiling for the retained finite mode set; it does not mean analytic completion of a zeta function.

### Definition 2.3 (Absolute and normalized occupation defects)

The absolute occupation defect is

$$
D_N(q)=C(q)-T_N(q),
$$

and, when $C(q)>0$, the normalized defect is

$$
\delta_N(q)=\frac{D_N(q)}{C(q)}=1-\frac{T_N(q)}{C(q)}.
$$

Under $0\le q_i<1$, one always has $C(q)>0$.

## 3. Algebraic factorization of the defect

The decisive structural statement is exact rather than asymptotic.

### Theorem 3.1 (Exact Occupation-Defect Factorization)

Let $I$ be finite, let $N\in\mathbb{N}$, and suppose $q_i<1$ for every $i\in I$. Then

$$
T_N(q)=C(q)\prod_{i\in I}\left(1-q_i^{N+1}\right).
$$

#### Proof sketch

For each mode, the finite geometric-series identity gives

$$
\sum_{n=0}^{N}q_i^n=\frac{1-q_i^{N+1}}{1-q_i}.
$$

The assumption $q_i<1$ ensures $1-q_i\ne0$. Multiplying the identity over $i\in I$ separates the denominator product from the numerator product:

$$
\prod_{i\in I}\sum_{n=0}^{N}q_i^n
=\left(\prod_{i\in I}(1-q_i)^{-1}\right)
\left(\prod_{i\in I}(1-q_i^{N+1})\right).
$$

The first parenthesis is $C(q)$ and the left side is $T_N(q)$.

### Corollary 3.2 (Exact normalized defect)

If $0\le q_i<1$ for every $i$, then

$$
\delta_N(q)=1-\prod_{i\in I}(1-q_i^{N+1}).
$$

Moreover, $0\le\delta_N(q)\le1$.

#### Proof sketch

Divide Theorem 3.1 by the positive number $C(q)$. Each $q_i^{N+1}$ lies in $[0,1]$, so every factor $1-q_i^{N+1}$ lies in $[0,1]$. Their product therefore lies in $[0,1]$.

### Corollary 3.3 (Monotonicity in the occupation ceiling)

Under $0\le q_i<1$, the sequence $T_N(q)$ is nondecreasing in $N$ and bounded above by $C(q)$. Furthermore,

$$
\lim_{N\to\infty}T_N(q)=C(q).
$$

#### Proof sketch

Each local partial sum increases with $N$, hence so does their product. The factorization gives $T_N(q)\le C(q)$. Since $I$ is finite and $q_i^{N+1}\to0$ for every $i$, the finite product $\prod_i(1-q_i^{N+1})$ tends to $1$.

## 4. From multiplicative defect to additive control

The exact formula is ideal for symbolic analysis. For numerical error allocation, an additive estimate is often more convenient.

### Lemma 4.1 (Multiplicative Union Bound)

Let $I$ be finite and let $a_i\in[0,1]$ for every $i\in I$. Then

$$
1-\prod_{i\in I}(1-a_i)\le\sum_{i\in I}a_i.
$$

#### Proof sketch

Induct on the number of indices. For the empty set both sides vanish. Suppose the result holds for a set $J$ and add one index with value $a$. Writing $P=\prod_{j\in J}(1-a_j)$ gives

$$
1-(1-a)P=(1-P)+aP.
$$

By induction, $1-P\le\sum_{j\in J}a_j$, and since $0\le P\le1$, one has $aP\le a$. Adding the inequalities proves the claim.

The inequality may also be read through inclusion–exclusion. The expression on the left begins with $\sum_i a_i$ and then subtracts pairwise products, adds triple products, and so forth. The induction argument avoids having to control the alternating expansion term by term.

### Theorem 4.2 (Occupation-Tail Bound)

Let $I$ be finite, $N\in\mathbb{N}$, and $0\le q_i<1$ for every $i\in I$. Then

$$
0\le D_N(q)\le C(q)\sum_{i\in I}q_i^{N+1}.
$$

Equivalently,

$$
0\le C(q)-T_N(q)
\le C(q)\sum_{i\in I}q_i^{N+1}.
$$

#### Proof sketch

Theorem 3.1 yields

$$
D_N(q)=C(q)\left[1-\prod_{i\in I}(1-q_i^{N+1})\right].
$$

The completed product is positive. Since $a_i=q_i^{N+1}$ belongs to $[0,1]$, Corollary 3.2 gives nonnegativity and Lemma 4.1 gives

$$
1-\prod_i(1-q_i^{N+1})\le\sum_i q_i^{N+1}.
$$

Multiplication by $C(q)$ completes the estimate.

### Corollary 4.3 (Uniform bound from the largest local weight)

If $m=|I|$ and $q_i\le\rho<1$ for every $i$, then

$$
0\le C(q)-T_N(q)\le C(q)m\rho^{N+1}.
$$

#### Proof sketch

Each summand $q_i^{N+1}$ is at most $\rho^{N+1}$, so Theorem 4.2 gives the result after summing $m$ terms.

This immediately supplies a sufficient occupation ceiling for a relative tolerance $\varepsilon>0$. It is enough to choose $N$ so that

$$
m\rho^{N+1}\le\varepsilon.
$$

When $0<\rho<1$ and $0<\varepsilon<m$, this is equivalent to

$$
N+1\ge\frac{\log(m/\varepsilon)}{-\log\rho}.
$$

The local-tail sum usually improves substantially on this worst-case simplification.

## 5. A canonical two-cutoff decomposition

Let $Z\in\mathbb{R}$ be a target quantity, possibly arising from an infinite-mode system. The completed finite product $C(q)$ forms a natural intermediate approximation.

### Theorem 5.1 (Two-Cutoff Error-Splitting Theorem)

For every real $Z$, every finite family $0\le q_i<1$, and every $N\in\mathbb{N}$,

$$
|Z-T_N(q)|
\le |Z-C(q)|+C(q)\sum_{i\in I}q_i^{N+1}.
$$

#### Proof sketch

Insert and subtract $C(q)$ and apply the triangle inequality:

$$
|Z-T_N(q)|
\le |Z-C(q)|+|C(q)-T_N(q)|.
$$

The second absolute value equals $C(q)-T_N(q)$ by Theorem 4.2, and the same theorem supplies its upper bound.

The first term is an **external mode error**: it compares the target with the system after occupations have been completed but while only the retained modes are present. The second is an **internal occupation error**: it depends solely on retained modes and their first omitted powers. This interpretation remains valid independently of how $Z$ is defined.

### Remark 5.2 (Scope of the theorem)

Theorem 5.1 does not estimate $|Z-C(q)|$. That term depends on the target and on the rule used to select modes. The theorem’s content is that the occupation contribution is exact before bounding and can be estimated independently of the external approximation.

## 6. Specialization to prime modes

### 6.1. Prime Boltzmann weights

Fix a natural cutoff $x$ and define

$$
P_x=\{p\in\mathbb{N}:p<x\text{ and }p\text{ is prime}\}.
$$

Let $\beta>0$ be an inverse temperature. For $p\in P_x$, set

$$
q_p=\exp(-\beta\log p)=p^{-\beta}.
$$

Every prime is greater than $1$, so $\log p>0$. Hence $-\beta\log p<0$ and

$$
0<q_p<1.
$$

### Definition 6.1 (Truncated prime-occupation partition)

The prime-occupation partition with prime cutoff $x$ and occupation ceiling $N$ is

$$
T_{x,N}(\beta)=
\prod_{p\in P_x}\sum_{n=0}^{N}p^{-\beta n}.
$$

### Definition 6.2 (Completed finite prime product)

The completed product over retained prime modes is

$$
C_x(\beta)=\prod_{p\in P_x}(1-p^{-\beta})^{-1}.
$$

### Theorem 6.3 (Exact Prime Occupation Defect)

For $x,N\in\mathbb{N}$ and $\beta>0$,

$$
T_{x,N}(\beta)
=C_x(\beta)\prod_{p\in P_x}
\left(1-p^{-(N+1)\beta}\right).
$$

#### Proof sketch

Apply Theorem 3.1 to the finite index set $P_x$ and weights $q_p=p^{-\beta}$.

### Theorem 6.4 (Prime Partition Two-Cutoff Bound)

For every real target $Z$, every $x,N\in\mathbb{N}$, and every $\beta>0$,

$$
|Z-T_{x,N}(\beta)|
\le |Z-C_x(\beta)|
+C_x(\beta)\sum_{p\in P_x}p^{-(N+1)\beta}.
$$

#### Proof sketch

The prime weights satisfy the hypotheses of Theorem 5.1. Substituting them gives the stated formula.

### 6.2. Relation to the Euler product

For real $\beta>1$, the Riemann zeta function has the absolutely convergent representations

$$
\zeta(\beta)=\sum_{m=1}^{\infty}m^{-\beta}
=\prod_{p\ \mathrm{prime}}(1-p^{-\beta})^{-1}.
$$

Taking $Z=\zeta(\beta)$ in Theorem 6.4 yields

$$
|\zeta(\beta)-T_{x,N}(\beta)|
\le |\zeta(\beta)-C_x(\beta)|
+C_x(\beta)\sum_{p\in P_x}p^{-(N+1)\beta}.
$$

The first term is due to omitted primes $p\ge x$. The second is due to omitted occupations $n\ge N+1$ at primes $p<x$. The finite theorem supplies the second term explicitly; a complete numerical zeta estimate additionally requires a prime-tail estimate for the first.

### 6.3. Arithmetic interpretation

A vector of occupations $(n_p)_{p\in P_x}$ corresponds by unique factorization to

$$
m=\prod_{p\in P_x}p^{n_p}.
$$

Its weight is

$$
\prod_{p\in P_x}p^{-\beta n_p}=m^{-\beta}.
$$

Consequently, $T_{x,N}(\beta)$ is the sum of $m^{-\beta}$ over positive integers whose prime divisors are all below $x$ and whose prime exponents are at most $N$. By contrast, $C_x(\beta)$ removes the exponent restriction while retaining the prime-divisor restriction. This explains structurally why the intermediate product isolates the occupation cutoff.

## 7. Algorithms and complexity

### 7.1. Direct evaluation

Given a list of $m$ weights, a direct algorithm evaluates every local finite sum and multiplies them. This requires $O(mN)$ arithmetic operations if powers are accumulated iteratively. It uses $O(1)$ auxiliary storage beyond the input.

For each weight $q_i$, initialize a local term and local sum to $1$. Repeat $N$ times: multiply the term by $q_i$ and add it to the sum. Multiply the global result by the local sum.

### 7.2. Factorized evaluation

The exact factorization permits $O(m)$ evaluation using exponentiation:

$$
T_N(q)=\prod_i\frac{1-q_i^{N+1}}{1-q_i}.
$$

With library exponentiation, each power costs $O(\log N)$ multiplications in an algebraic cost model, giving $O(m\log N)$ multiplication complexity. For floating-point inputs the dominant practical concern is numerical stability. When $q_i$ is close to $1$, functions analogous to $\operatorname{expm1}$ and $\log1p$ can reduce cancellation.

### 7.3. Certified occupation error budget

The following quantities can be computed in one pass:

$$
C(q)=\prod_i(1-q_i)^{-1},
\qquad
S_N(q)=\sum_iq_i^{N+1},
\qquad
B_N(q)=C(q)S_N(q).
$$

Theorem 4.2 certifies that $D_N(q)\le B_N(q)$. Computing $C(q)$ and $S_N(q)$ requires $O(m)$ stored-power evaluations and $O(1)$ extra space. For prime modes, prime generation by a sieve up to $x$ costs $O(x\log\log x)$ time and $O(x)$ space in the standard array implementation; evaluation over the resulting $\pi(x)$ primes then costs $O(\pi(x))$ transcendental and arithmetic operations.

### 7.4. Adaptive ceiling selection

Given weights and a desired relative occupation tolerance $\varepsilon$, seek the least $N$ satisfying

$$
\sum_iq_i^{N+1}\le\varepsilon.
$$

The left side decreases monotonically. One may double an upper guess until the inequality holds and then perform binary search. If the minimal ceiling is $N_*$, this takes $O(m\log(N_*+1))$ evaluations of powers in a straightforward implementation. The coarser closed-form criterion from Corollary 4.3 gives an immediate safe ceiling.

## 8. Numerical examples

### Example 8.1 (Three rational weights)

Let $q=(1/2,1/3,1/5)$ and $N=2$. Then

$$
C(q)=2\cdot\frac32\cdot\frac54=\frac{15}{4}=3.75.
$$

The exact normalized defect is

$$
\delta_2(q)=1-rac78\cdot\frac{26}{27}\cdot\frac{124}{125},
$$

while the union-bound estimate is

$$
\delta_2(q)\le\frac18+\frac1{27}+\frac1{125}.
$$

Multiplying by $15/4$ gives the absolute error bound. As $N$ increases, both the exact defect and its bound decay geometrically.

### Example 8.2 (Prime modes below $12$)

Take $P_{12}=\{2,3,5,7,11\}$, $\beta=2$, and $N=3$. The local weights are $p^{-2}$, the first omitted weights are $p^{-8}$, and

$$
C_{12}(2)=\prod_{p\in P_{12}}(1-p^{-2})^{-1}.
$$

The occupation defect obeys

$$
0\le C_{12}(2)-T_{12,3}(2)
\le C_{12}(2)\left(2^{-8}+3^{-8}+5^{-8}+7^{-8}+11^{-8}\right).
$$

The term $2^{-8}$ dominates the tail sum, illustrating why the least retained prime controls the slowest occupation convergence.

### Example 8.3 (Independent response to cutoffs)

At fixed $x$ and $\beta$, increasing $N$ changes only the explicit occupation term. At fixed $N$ and $\beta$, increasing $x$ introduces both new Euler factors and new local occupation tails. For approximation design one can first choose $x$ from an external prime-tail criterion and then raise $N$ until

$$
C_x(\beta)\sum_{p<x}p^{-(N+1)\beta}
$$

fits the remaining error budget.

## 9. Applications

### 9.1. Modular approximation of Euler products

The two-term estimate allows independent analytic tools. Bounds for omitted primes can control $|\zeta(\beta)-C_x(\beta)|$, while the present geometric estimate controls occupations. The two need not be proved by the same method or optimized simultaneously.

### 9.2. Statistical mechanics of arithmetic configurations

The mode energy $E_p=\log p$ gives Boltzmann factor $e^{-\beta E_p}=p^{-\beta}$. Occupation vectors encode integers, and total energy satisfies

$$
\sum_p n_p\log p=\log\left(\prod_pp^{n_p}\right).
$$

Thus additive energy and multiplicative arithmetic are linked by the logarithm. The exact defect quantifies the loss caused by imposing a finite local state space.

### 9.3. Reliable numerical experiments

Finite computations can report three values: the truncated product, the exact finite completion, and the certified occupation bound. This makes it possible to distinguish a discrepancy caused by too small an occupation ceiling from one caused by too few primes. Such diagnostic separation is preferable to reporting only a total empirical error.

### 9.4. General independent-mode models

Nothing in Theorems 3.1–5.1 depends on primality. The same results apply to any finite family of nonnegative subunit activities: truncated bosonic modes, weighted combinatorial multisets, generating functions with bounded multiplicities, and finite products of geometric local factors.

## 10. Limitations and discussion

The strict condition $q_i<1$ is essential for the completed local factor to be positive and finite. Nonnegativity is essential for the monotone comparison and the stated union-bound application. The algebraic identity itself allows some broader real choices, but the quantitative interpretation changes when weights are negative or exceed one in magnitude.

The result is finite. It does not itself prove a rate for the omitted-prime error, analytic continuation of the zeta function, a functional equation, or any statement concerning zeta zeros. In particular, substituting $Z=\zeta(\beta)$ is justified directly only in the Euler-product region $\beta>1$. Maintaining this distinction prevents a finite truncation estimate from being mistaken for a global theorem in analytic number theory.

The additive bound may overestimate the defect because it discards overlap corrections. Writing $a_i=q_i^{N+1}$, inclusion–exclusion gives

$$
1-\prod_i(1-a_i)
=\sum_i a_i-\sum_{i<j}a_ia_j+\sum_{i<j<k}a_ia_ja_k-\cdots.
$$

When all tails are small, the omitted products are second order or smaller. This explains why the sum bound can be both simple and close to sharp. A rigorous asymptotic classification according to the largest local weights is a natural next step.

## 11. Reproducibility protocol for finite experiments

A numerical test of the theory should preserve the distinction between exact identities and floating-point approximations. Given weights $q_i$, first evaluate the local sums directly and form $T_N(q)$. Independently evaluate $C(q)$ and the defect factor

$$
F_N(q)=\prod_i(1-q_i^{N+1}).
$$

The residual

$$
R_N=\left|T_N(q)-C(q)F_N(q)\right|
$$

should be close to floating-point roundoff. Next compute the actual defect $D_N(q)$ and the certified bound $B_N(q)=C(q)\sum_iq_i^{N+1}$, checking

$$
0\le D_N(q)\le B_N(q).
$$

Finally report the ratio $D_N(q)/B_N(q)$ when the denominator is nonzero. This ratio measures sharpness of the additive estimate, not correctness of the exact identity.

For prime experiments, the primality convention and cutoff convention must be explicit: throughout this paper, $P_x$ contains primes strictly less than $x$. A calculation should report $x$, $N$, $\beta$, the retained prime list, $T_{x,N}(\beta)$, $C_x(\beta)$, the exact occupation defect, and its upper bound. If a zeta target is included for $\beta>1$, the total discrepancy and its two components should be displayed separately. This prevents occupation accuracy from being confused with accuracy of the finite Euler product.

Products involving many modes are more reliably accumulated through logarithms. For example,

$$
\log C(q)=-\sum_i\log(1-q_i).
$$

This avoids premature overflow, although converting back by exponentiation can still overflow for extreme inputs. High-precision arithmetic is appropriate when the defect is much smaller than $C(q)$, because direct subtraction can lose significant digits. The factorized normalized defect is often numerically preferable in that regime.

## 12. Future work

A first objective is locally uniform joint removal of the mode and occupation cutoffs on compact subsets of $\operatorname{Re}(s)>1$. The occupation component already has a modulus-compatible geometric structure; the remaining ingredient is a compact-uniform estimate for omitted prime factors.

A second objective is asymptotic sharpness. If a unique mode has maximal weight $\rho$, then the exact inclusion–exclusion formula suggests

$$
\delta_N(q)\sim \rho^{N+1}.
$$

When several modes share the maximum, their first-order contributions should add.

A third direction replaces real $\beta$ by complex $s$ with $\operatorname{Re}(s)>1$. Since $|p^{-s}|=p^{-\operatorname{Re}(s)}$, taking moduli should reduce occupation control to the nonnegative estimate, while the algebraic factorization persists over $\mathbb{C}$.

Further work may investigate an archimedean occupation sector representing the gamma factor in the completed zeta function, and response forms derived from logarithmic occupation fluctuations. Such constructions lie beyond the finite results proved here and require additional analytic structure.

## 13. Conclusion

Finite independent geometric modes possess an exact and useful truncation geometry. Their occupation-limited partition equals the completed finite product times one local defect factor per mode. A multiplicative union bound turns this identity into an additive estimate controlled by first omitted powers. Inserting the completed finite product between a target and the truncated partition then separates external mode error from internal occupation error.

For prime modes with weights $p^{-\beta}$, this becomes a two-cutoff bound distinguishing omitted primes from omitted exponents. The distinction reflects unique factorization itself: the prime cutoff controls which prime divisors may appear, while the occupation cutoff controls their multiplicities. The resulting error budget is explicit, modular, and applicable wherever finite geometric occupation products arise. It also provides a reproducible standard for computation: report the finite completion, report the occupation defect separately, and reserve any claim about an infinite target for an independently justified mode-tail estimate. This separation keeps algebraic identities, numerical approximations, and analytic limiting arguments conceptually distinct.
