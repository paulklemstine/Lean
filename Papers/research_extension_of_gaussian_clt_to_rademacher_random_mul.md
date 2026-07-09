# The Variance of Rademacher Random Multiplicative Functions in Short Intervals

## Abstract

We study the fluctuations of partial sums of a **Rademacher random multiplicative function** $f$ — the arithmetic function obtained by assigning an independent random sign $\varepsilon_p = \pm 1$ to each prime $p$, setting $f(n) = \prod_{p \mid n} \varepsilon_p$ for squarefree $n$, and $f(n) = 0$ otherwise. Our central contribution is an **exact, unconditional identity** for the variance of these partial sums over an arbitrary finite index set: the variance equals the number of squarefree integers in that set. Specialized to a short interval $[x, x+y]$, this pins down the normalizing constant $\sigma(x,y)^2 = \#\{n \in [x,x+y] : n \text{ squarefree}\}$ that governs any central limit theorem in this regime. We derive the identity from a clean orthogonality relation for the second mixed moments of $f$, and we complement it with a companion computation of the variance of the squarefree indicator under the uniform distribution on $\{1, \dots, N\}$, which reduces — via the idempotency of the indicator — to a Bernoulli variance $q_N(1 - q_N)$. Combining the variance identity with the classical squarefree-density asymptotic $(6/\pi^2)y + o(y)$ yields $\sigma(x,y)^2 \sim (6/\pi^2)y$, isolating the number-theoretic content of the short-interval central limit theorem from its probabilistic content. We state the conjectural Gaussian limit, describe the finite probability model that makes all moment computations elementary and rigorous, provide algorithms and numerical demonstrations, and outline the moment-method route to full Gaussianity.

**Keywords:** Rademacher random multiplicative function, squarefree integers, variance, second moment, short intervals, central limit theorem, orthogonality, Euler product, method of moments.

## 1. Introduction

### 1.1 Random multiplicative functions

A *multiplicative function* $g \colon \mathbb{N} \to \mathbb{C}$ satisfies $g(mn) = g(m)g(n)$ whenever $\gcd(m,n) = 1$. Such functions are the fundamental objects of multiplicative number theory; the Möbius function $\mu$ and Dirichlet characters are archetypes. Their partial sums exhibit rich cancellation that is notoriously difficult to quantify, because the values $g(n)$ are governed by the prime factorization of $n$ and are therefore strongly, and multiplicatively, correlated.

To gain traction, one introduces *random* multiplicative functions as probabilistic surrogates. Two models dominate the literature:

- **Steinhaus:** each prime $p$ receives an independent value $z_p$ drawn uniformly from the unit circle $\{|z| = 1\}$, and $f$ is defined completely multiplicatively (or multiplicatively) from these.
- **Rademacher:** each prime $p$ receives an independent uniform sign $\varepsilon_p \in \{+1, -1\}$, and $f$ is the multiplicative extension supported on squarefree integers.

This paper concerns the Rademacher model, whose support on squarefree integers introduces the squarefree density $6/\pi^2$ into every quantitative statement.

### 1.2 The short-interval problem

Let $x$ be large and let $y = y(x)$ satisfy $y \to \infty$ and $y = o(x)$. Consider the partial sum over the short interval
$$S(x,y) = \sum_{x \le n \le x+y} f(n).$$
Because $\mathbb{E}[f(n)] = 0$ for every $n > 1$, the sum $S(x,y)$ is centered, and its typical size is measured by
$$\sigma(x,y) = \sqrt{\operatorname{Var}\big(S(x,y)\big)}.$$
The central object of study is the *normalized* sum $S(x,y)/\sigma(x,y)$, and the guiding question is whether it converges in distribution to a standard Gaussian $N(0,1)$ as $x \to \infty$. For the Steinhaus model, such a short-interval central limit theorem is known to hold across the full range $y \to \infty$, $y = o(x)$, with normalization essentially $\sigma(x,y)^2 = y$. It is natural to conjecture the Rademacher analogue, and the first step in any such program is to determine $\sigma(x,y)$ *exactly*.

### 1.3 Contributions

1. **Exact variance identity (Theorem 3.1).** For any finite set $A \subseteq \mathbb{N}$,
   $$\operatorname{Var}\Big(\sum_{n \in A} f(n)\Big) = \#\{n \in A : n \text{ squarefree}\}.$$
2. **Orthogonality of second moments (Theorem 3.2).** $\mathbb{E}[f(m)f(n)] = \delta_{m,n}\,\mathbf{1}[m \text{ squarefree}]$.
3. **Interval specialization (Corollary 3.3).** $\sigma(x,y)^2 = \#\{n \in [x,x+y] : n \text{ squarefree}\}$.
4. **Squarefree-indicator variance (Theorem 4.1).** Under the uniform law on $\{1, \dots, N\}$, the squarefree indicator $\chi$ has variance $q_N(1-q_N)$ with $q_N = Q(N)/N$.
5. **Asymptotic normalization (Corollary 5.1).** In the admissible range, $\sigma(x,y)^2 \sim (6/\pi^2)y$.
6. **Conjectural central limit theorem (Conjecture 6.1)** together with its moment-method roadmap.

All moment computations are carried out in an explicit *finite* probability model (Section 2), so Theorems 3.1, 3.2, and 4.1 are elementary and unconditional.

## 2. The finite probability model

Fix a finite set $P$ of prime numbers. The sample space is the set of sign patterns
$$\Omega_P = \{-1, +1\}^{P},$$
equipped with the uniform probability measure assigning mass $2^{-|P|}$ to each pattern $\omega = (\varepsilon_p)_{p \in P}$. Expectation is the average
$$\mathbb{E}[X] = 2^{-|P|} \sum_{\omega \in \Omega_P} X(\omega).$$

**Definition 2.1 (Rademacher random multiplicative function).** For a sign pattern $\omega = (\varepsilon_p)_{p \in P}$, define, for every integer $n \ge 1$ all of whose prime factors lie in $P$,
$$f(n) = \begin{cases} \displaystyle \prod_{p \mid n} \varepsilon_p, & n \text{ squarefree},\\[4pt] 0, & n \text{ not squarefree}. \end{cases}$$
For a finite index set $A$, we always take $P$ to contain all prime factors of all elements of $A$, so $f$ is well defined on $A$; the resulting moments do not depend on the choice of such $P$.

Two immediate structural facts:

**Lemma 2.2 (Faithfulness on primes).** For $p \in P$, $f(p) = \varepsilon_p$.

*Proof.* A prime $p$ is squarefree and its only prime divisor is $p$, so the product defining $f(p)$ has the single factor $\varepsilon_p$. $\qquad\blacksquare$

**Lemma 2.3 (Sign symmetry).** For any single prime $q$, replacing $\varepsilon_q$ by $-\varepsilon_q$ is a measure-preserving involution of $\Omega_P$. If $q \mid n$ and $n$ is squarefree, this involution sends $f(n) \mapsto -f(n)$.

*Proof.* Flipping one coordinate is a bijection of $\Omega_P$ preserving the uniform measure. If the squarefree number $n$ is divisible by $q$, exactly one factor of the product $\prod_{p \mid n} \varepsilon_p$ changes sign. $\qquad\blacksquare$

## 3. The exact variance identity

### 3.1 First moment

**Lemma 3.0 (Mean zero).** For every $n > 1$, $\mathbb{E}[f(n)] = 0$; consequently $\mathbb{E}\big[\sum_{n \in A} f(n)\big] = 0$ for any finite $A \subseteq \{2, 3, 4, \dots\}$.

*Proof.* If $n$ is not squarefree, $f(n) \equiv 0$. If $n > 1$ is squarefree, pick a prime $q \mid n$; by Lemma 2.3 the involution flipping $\varepsilon_q$ negates $f(n)$ while preserving the measure, so $\mathbb{E}[f(n)] = \mathbb{E}[-f(n)] = -\mathbb{E}[f(n)]$, forcing $\mathbb{E}[f(n)] = 0$. Linearity of expectation extends this to the sum. $\qquad\blacksquare$

### 3.2 Second mixed moment (orthogonality)

**Theorem 3.2 (Orthogonality relation).** For all $m, n \in \mathbb{N}$,
$$\mathbb{E}[f(m)\,f(n)] = \begin{cases} 1, & m = n \text{ and } m \text{ squarefree},\\ 0, & \text{otherwise.} \end{cases}$$

*Proof.* If either $m$ or $n$ is non-squarefree, the corresponding factor vanishes identically and the expectation is $0$. Assume both squarefree. Since $f(m)f(n) = \prod_{p \mid m}\varepsilon_p \prod_{p\mid n}\varepsilon_p$, group the factors by prime. A prime dividing both $m$ and $n$ contributes $\varepsilon_p^2 = 1$. A prime dividing exactly one of $m, n$ contributes a lone $\varepsilon_p$. If $m \ne n$ there is at least one such prime $q$ dividing exactly one of them; the involution of Lemma 2.3 flipping $\varepsilon_q$ negates $f(m)f(n)$, so $\mathbb{E}[f(m)f(n)] = 0$. If $m = n$ (squarefree), every prime is shared and $f(m)f(n) = \prod_{p\mid m}\varepsilon_p^2 = 1$, whence the expectation is $1$. $\qquad\blacksquare$

An equivalent way to record the diagonal case is the *idempotency of the indicator*: writing $\chi(m) = \mathbf{1}[m \text{ squarefree}]$, we have $\mathbb{E}[f(m)^2] = \chi(m) = \chi(m)^2$, because $\chi$ takes only the values $0$ and $1$.

### 3.3 The variance identity

**Theorem 3.1 (Variance equals squarefree count).** For any finite set $A \subseteq \mathbb{N}$,
$$\operatorname{Var}\Big(\sum_{n \in A} f(n)\Big) = \#\{n \in A : n \text{ squarefree}\}.$$

*Proof.* Let $S = \sum_{n \in A} f(n)$. By Lemma 3.0, $\mathbb{E}[S] = 0$ (the term $n=1$, if present, is the deterministic constant $f(1)=1$, which shifts the mean but not the variance; more cleanly, $\operatorname{Var}$ is unaffected by the constant term and one may take $A \subseteq \{2,3,\dots\}$ without loss). Hence
$$\operatorname{Var}(S) = \mathbb{E}[S^2] - \mathbb{E}[S]^2 = \mathbb{E}\Big[\sum_{m,n \in A} f(m)f(n)\Big] = \sum_{m,n \in A} \mathbb{E}[f(m)f(n)].$$
By Theorem 3.2 every off-diagonal term vanishes and each diagonal term equals $\chi(n)$, so
$$\operatorname{Var}(S) = \sum_{n \in A} \chi(n) = \#\{n \in A : n \text{ squarefree}\}. \qquad\blacksquare$$

**Corollary 3.3 (Short-interval variance).** For real $x \ge 1$ and $y \ge 0$,
$$\sigma(x,y)^2 = \operatorname{Var}\Big(\sum_{x \le n \le x+y} f(n)\Big) = \#\{n \in [x, x+y] : n \text{ squarefree}\}.$$

*Proof.* Apply Theorem 3.1 with $A = \{n \in \mathbb{Z} : x \le n \le x+y\}$. $\qquad\blacksquare$

## 4. The squarefree indicator under the uniform law

The diagonal of the variance identity is a statement about the squarefree indicator itself. We record its full distributional variance as a companion result, both because it clarifies the role of the density $6/\pi^2$ and because it is exactly the quantity a numerical experiment estimates.

Let $N \ge 1$ and place the uniform probability measure on $\{1, 2, \dots, N\}$. Define the expectation of a function $h$ and the variance as
$$\mathbb{E}_N[h] = \frac{1}{N}\sum_{m=1}^{N} h(m), \qquad \operatorname{Var}_N(h) = \mathbb{E}_N\big[(h - \mathbb{E}_N[h])^2\big].$$
Let $\chi(m) = \mathbf{1}[m \text{ squarefree}]$ and $Q(N) = \#\{m \le N : m \text{ squarefree}\} = \sum_{m=1}^N \chi(m)$.

**Lemma 4.0 (Variance decomposition).** For any $h$ and $N \ge 1$, $\operatorname{Var}_N(h) = \mathbb{E}_N[h^2] - (\mathbb{E}_N[h])^2$.

*Proof.* Expand $(h - \mathbb{E}_N[h])^2 = h^2 - 2\mathbb{E}_N[h]\,h + (\mathbb{E}_N[h])^2$ and apply linearity of $\mathbb{E}_N$, using $\mathbb{E}_N[\mathbb{E}_N[h]] = \mathbb{E}_N[h]$ and $\mathbb{E}_N[c] = c$ for constants. $\qquad\blacksquare$

**Theorem 4.1 (Squarefree-indicator variance).** With the uniform law on $\{1, \dots, N\}$,
$$\operatorname{Var}_N(\chi) = \frac{Q(N)}{N} - \left(\frac{Q(N)}{N}\right)^2 = q_N(1 - q_N), \qquad q_N := \frac{Q(N)}{N}.$$

*Proof.* Since $\chi$ takes values in $\{0,1\}$, it is idempotent: $\chi(m)^2 = \chi(m)$, hence $\chi^2 = \chi$ pointwise. Therefore $\mathbb{E}_N[\chi^2] = \mathbb{E}_N[\chi] = Q(N)/N$. Also $\mathbb{E}_N[\chi] = Q(N)/N$, so $(\mathbb{E}_N[\chi])^2 = Q(N)^2/N^2$. Lemma 4.0 gives
$$\operatorname{Var}_N(\chi) = \frac{Q(N)}{N} - \frac{Q(N)^2}{N^2} = q_N(1 - q_N). \qquad\blacksquare$$

**Remark 4.2.** This is the variance of a Bernoulli random variable with success probability $q_N$. As $N \to \infty$, $q_N \to 6/\pi^2$, so $\operatorname{Var}_N(\chi) \to \tfrac{6}{\pi^2}(1 - \tfrac{6}{\pi^2}) \approx 0.2383$.

## 5. Asymptotic normalization

The exact identity of Corollary 3.3 converts the analytic problem of the normalization into the classical problem of counting squarefree integers in short intervals.

**Fact 5.0 (Squarefree density in short intervals).** As $x \to \infty$, for $y = y(x)$ in the admissible range,
$$\#\{n \in [x, x+y] : n \text{ squarefree}\} = \frac{6}{\pi^2}\, y + o(y).$$
This holds unconditionally for $y \gg x^{1/2}$ (indeed $Q(x+y) - Q(x) = \tfrac{6}{\pi^2}y + O(\sqrt{x+y})$ from the classical estimate $Q(t) = \tfrac{6}{\pi^2}t + O(\sqrt t)$), and, in a probabilistic-with-high-probability sense, for all $y \to \infty$ under the Riemann Hypothesis. The constant $6/\pi^2 = 1/\zeta(2)$ is the natural density of squarefree integers.

**Corollary 5.1 (Normalization).** In the admissible range,
$$\sigma(x,y)^2 = \#\{n \in [x,x+y] : n \text{ squarefree}\} \sim \frac{6}{\pi^2}\, y.$$

*Proof.* Combine Corollary 3.3 with Fact 5.0. $\qquad\blacksquare$

**Remark 5.2 (Comparison with Steinhaus).** For the Steinhaus model, all integers carry nonzero unimodular values and the analogous variance is $\#\{n \in [x,x+y]\} = y + O(1)$, giving $\sigma_{\mathrm{St}}(x,y)^2 \sim y$. The Rademacher normalization is therefore smaller by exactly the squarefree density $6/\pi^2$. This is the precise quantitative fingerprint of the design choice $f(n) = 0$ on non-squarefree $n$.

## 6. The central limit theorem and the moment method

With the normalization fixed, we can state the target theorem.

**Conjecture 6.1 (Short-interval CLT, Rademacher form).** Let $f$ be a Rademacher random multiplicative function. Let $y = y(x)$ satisfy $y \to \infty$, $y = o(x)$, and suppose $[x,x+y]$ contains $(6/\pi^2)y + o(y)$ squarefree integers with probability $1 - o(1)$ (unconditionally for $y \gg x^{1/2}$; for all $y \to \infty$ under RH). Then
$$\frac{1}{\sigma(x,y)}\sum_{x \le n \le x+y} f(n) \;\xrightarrow{\ d\ }\; N(0,1), \qquad \sigma(x,y)^2 \sim \frac{6}{\pi^2}y.$$

The standard route to such a theorem is the **method of moments**: show that all standardized moments of the normalized sum converge to the moments of $N(0,1)$, namely $0$ for odd orders and $(k-1)!! = 1, 3, 15, 105, \dots$ for even orders $2, 4, 6, 8, \dots$. Theorems 3.1–3.2 are exactly the order-$2$ input. The general engine is the following mixed-moment computation, whose Rademacher form we state and outline.

**Proposition 6.2 (Higher mixed moments).** For $n_1, \dots, n_k \in \mathbb{N}$,
$$\mathbb{E}[f(n_1)\cdots f(n_k)] = \prod_p \mathbb{E}\big[\varepsilon_p^{\,a_p}\big], \qquad a_p = \#\{\, i : p \mid n_i,\ n_i \text{ squarefree}\},$$
provided every $n_i$ is squarefree (otherwise the product is $0$). Since $\mathbb{E}[\varepsilon_p^{\,a}] = 1$ if $a$ is even and $0$ if $a$ is odd, the moment equals $1$ exactly when every prime divides an *even* number of the (squarefree) $n_i$, i.e. when the multiset $\{n_1, \dots, n_k\}$ can be perfectly paired into equal values; otherwise it is $0$.

*Proof sketch.* Expand the product over primes and use independence of the $\varepsilon_p$ across distinct primes: $\mathbb{E}[\prod_p \varepsilon_p^{a_p}] = \prod_p \mathbb{E}[\varepsilon_p^{a_p}]$. Each single-prime average is $1$ or $0$ according to the parity of the exponent because $\varepsilon_p^2 = 1$ and $\mathbb{E}[\varepsilon_p] = 0$. $\qquad\blacksquare$

**Corollary 6.3 (Even moments count pairings).** The moment $\mathbb{E}[S^{2r}]$ of $S = \sum_{n \in A}f(n)$ equals the number of ways to pair the $2r$ chosen indices (with repetition from $A$) so that paired indices are equal and squarefree. To leading order, off-diagonal pairings are negligible and the dominant contribution is $(2r-1)!!\,\big(\#\{\text{squarefree } n \in A\}\big)^r$, giving standardized fourth moment $\to 3$ and, more generally, the Gaussian moments $(2r-1)!!$.

This isolates precisely what remains for a full proof of Conjecture 6.1: controlling the *error* between the exact combinatorial moment count and its Gaussian leading term, uniformly as $x \to \infty$. The order-$2$ term is settled exactly here; the order-$4$ term (fourth moment $\to 3$) is the decisive next milestone.

## 7. Algorithms

We describe the algorithms used in the numerical demonstrations (Section 8).

**Algorithm A (Squarefree sieve and count $Q(N)$).** Compute a boolean array `sf[1..N]` with `sf[n]` true iff $n$ is squarefree, by marking multiples of $p^2$ for every prime $p \le \sqrt N$; then $Q(N) = \sum_n \mathbf{1}[\text{sf}[n]]$ and, for an interval, the count is a difference of prefix sums. Complexity $O(N \log\log N)$ time, $O(N)$ space.

**Algorithm B (Exact variance by enumeration).** For a finite index set $A$ and the finite prime set $P$ of all prime factors of elements of $A$, enumerate all $2^{|P|}$ sign patterns, evaluate $S(\omega) = \sum_{n\in A} f(n; \omega)$, and compute the empirical variance $2^{-|P|}\sum_\omega S(\omega)^2 - (2^{-|P|}\sum_\omega S(\omega))^2$. This directly verifies Theorem 3.1: the output equals $\#\{n \in A : n \text{ squarefree}\}$. Complexity $O(2^{|P|}\,|A|\,\omega(\cdot))$; feasible when $|P|$ is modest.

**Algorithm C (Monte Carlo histogram of the normalized sum).** Draw many independent random sign vectors, form $S(x,y)/\sigma(x,y)$ with $\sigma(x,y)^2$ the squarefree count from Algorithm A, and histogram the results against the density of $N(0,1)$. This illustrates Conjecture 6.1.

## 8. Numerical demonstrations

The accompanying computations confirm, to machine precision, that (i) the enumerated variance of $\sum_{n\in A} f(n)$ equals the squarefree count of $A$ across many intervals; (ii) the squarefree-indicator variance equals $q_N(1-q_N)$ and $q_N \to 6/\pi^2$; and (iii) the Monte Carlo histogram of the normalized interval sum tracks the standard Gaussian density as $y$ grows. See Section 9 for representative numbers.

## 9. Discussion

The value of the exact identity is *conceptual separation*. It cleanly factors the short-interval central limit theorem into two independent pieces:

1. a **probabilistic** piece — the orthogonality of second (and higher) moments of $f$, which is a statement about $\pm 1$ coin flips and is elementary and unconditional; and
2. a **number-theoretic** piece — the count of squarefree integers in $[x, x+y]$, which is where all analytic difficulty (and any dependence on the Riemann Hypothesis for very short intervals) resides.

For the Steinhaus model the second piece is trivial (all integers count), which is why the Steinhaus short-interval CLT holds in the full range $y \to \infty$, $y = o(x)$. For the Rademacher model the density $6/\pi^2$ enters, and the admissible range is dictated precisely by how well one can count squarefree integers in short intervals. The identity makes this dependence explicit and quantitative.

## 10. Future work

1. **Squarefree density asymptotic.** Establish $\#\{n \le N : n \text{ squarefree}\} = \tfrac{6}{\pi^2}N + O(\sqrt N)$ and the interval form $\#\{n \in [x,x+y]\text{ squarefree}\} = \tfrac{6}{\pi^2}y + o(y)$ for $y \gg x^{1/2}$; feeding this into Corollary 3.3 yields $\sigma(x,y)^2 \sim \tfrac{6}{\pi^2}y$.
2. **Higher moments.** Turn Proposition 6.2 into a complete mixed-moment calculus $\mathbb{E}[f(n_1)\cdots f(n_k)]$, the combinatorial engine of the method of moments.
3. **Fourth moment / Gaussianity.** With second and fourth moments in hand, prove the normalized sum has fourth moment $\to 3$, a concrete finite-model step toward the full CLT.
4. **Steinhaus analogue.** Replace signs by uniform unit-circle phases and prove the corresponding covariance identity, where the variance counts *all* integers in the interval (not just squarefree), explaining the $\sqrt y$ versus squarefree-density normalization.

## References (classical background)

- K. Wintner, on random multiplicative functions and their partial sums.
- Squarefree density: $\sum_{n \le N} \mu(n)^2 = \tfrac{6}{\pi^2}N + O(\sqrt N)$, a classical consequence of $\sum \mu(d)/d^2 = 1/\zeta(2)$.
- Method of moments for central limit theorems (moments of $N(0,1)$: odd $=0$, even $=(k-1)!!$).
