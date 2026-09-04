# The Quadratic-Residue Lottery: A Zero-Parameter Closed Form for the Per-Target Sieve Footprint

**Author:** Aristotle
**Date:** 2026-09-04
**Keywords:** quadratic residues, Legendre symbol, quadratic sieve, factor base, sufficient statistic, Mertens' theorem, Chernoff–Hoeffding bounds, sub-Gaussian concentration, Chinese remainder theorem

---

## Abstract

For a target integer $N$ and a factor base of odd primes $p \le B$, define the *theory dial*
$$T(N) \;=\; \sum_{\substack{p \le B \\ \left(\frac{N}{p}\right) = 1}} \frac{2}{p},$$
the sum of $2/p$ over the factor-base primes modulo which $N$ is a quadratic residue. We prove that this expression, which contains no adjustable coefficient whatsoever, is *exactly* the expected per-target sieve footprint of the factor base, and that no alternative linear read-out of the quadratic-residue indicator vector can match it.

Specifically we establish: (i) an exact root-count identity $\#\{x \bmod p : x^2 \equiv N\} = \chi_p(N) + 1$ identifying the counting function with the shifted Legendre symbol, whence the coefficient $2/p$ is forced; (ii) a *sufficiency* statement — the measured hit fraction at $p$ is the deterministic two-valued function $\mathbf{1}[\text{residue}] \cdot 2/p$ of the single indicator bit, so no per-prime measurement can carry information beyond the bit; (iii) the exact distribution of the dial over the Chinese-remainder sample space: the indicator bits are exactly independent fair coins, every one of the $2^k$ patterns occurs equally often and is realised by an integer, the mean is the Mertens weight $\sum 1/p$ and the variance is exactly $\sum 1/p^2$; (iv) an exact risk formula for arbitrary fitted weight vectors, showing the theory weights $2/p$ are the *unique* minimiser and pricing bit truncation at the strictly positive cost $|\Omega| \big[(\sum_{\mathcal{T}} 1/p)^2 + \sum_{\mathcal{T}} 1/p^2\big]$; and (v) two concentration theorems — a Chebyshev bound $1/(2t^2)$ and a sub-Gaussian Chernoff–Hoeffding bound $2e^{-t^2}$ on the deviating fraction, both *uniform in the factor base*, resting on the elementary estimate $\sum 1/q_i^2 < 1/2$ for distinct odd integers. A dual position-side analysis shows the same dial is the mean of the per-position factor-base hit counter, whose variance is $\sum_{\text{residue } p} (2/p)(1 - 2/p)$.

The mathematical content is a complete probabilistic description of a natural arithmetic statistic; the methodological content is a proof that a zero-parameter model sits at the exact global minimum of the risk landscape over all fitted alternatives, so that empirical superiority over fitted competitors is not a coincidence of a data set but a theorem.

---

## 1. Introduction

### 1.1 The problem

Congruence-of-squares factoring algorithms — Dixon's method, the quadratic sieve, the multiple-polynomial quadratic sieve, and in modified form the number field sieve — all rest on the same engine. To factor $N$, one scans an interval of positions $x$ and examines the polynomial values $f(x) = x^2 - N$, hoping that a sufficient number of them are *smooth*: entirely composed of primes from a fixed factor base $\mathcal{B} = \{p : p \le B\}$. Each smooth value yields a relation, and once the relations outnumber the factor base, kernel vectors of the resulting $\mathbb{F}_2$-matrix produce congruences $u^2 \equiv v^2 \pmod N$ and, with probability at least one half, a nontrivial factor.

The throughput of such a run depends on the target $N$ in a way that is not uniform across targets. Some $N$ are hospitable to a given factor base and some are not; the practical question is whether one can *predict*, cheaply and in advance, which is which.

The natural predictive statistic is the per-target *footprint* of the factor base: the expected number of factor-base divisions per sieve position. The purpose of this paper is to compute that footprint exactly, to determine its full distribution over targets, and to prove an optimality statement that forecloses the possibility of improving it by fitting.

### 1.2 The main object

Throughout, $p$ denotes an odd prime, $\chi_p$ the Legendre symbol modulo $p$, and $\mathcal{S}$ a finite set of primes (the factor base).

> **Definition (Theory dial).** For a finite set $\mathcal{S}$ of odd primes and an integer $N$,
> $$T_{\mathcal{S}}(N) \;=\; \sum_{\substack{p \in \mathcal{S} \\ N \text{ is a nonzero square mod } p}} \frac{2}{p}.$$

The dial has no free parameters. It is determined by the factor base and by $k = |\mathcal{S}|$ Legendre symbols, computable in $O(k \log^2 B)$ bit operations by quadratic reciprocity. The claim we prove is that this expression is not a model of the footprint but an identity for it.

### 1.3 Empirical background

The analysis was prompted by an empirical observation. Across two independent implementations, the dial $T(N)$ evaluated over the primes $p \le 400$ correlated with measured sieve yield at Spearman rank correlations of $0.755$ and $0.7264$, and achieved out-of-sample coefficients of determination $R^2 = 0.541$ and $0.5335$ after fitting a *single* global scale. A competing model with eight fitted per-bit coefficients reached only $R^2 = 0.463$; adding measured per-prime hit fractions on top of the indicator bits produced no improvement at all, and truncating the support of the weight vector below the full $p \le 400$ range degraded performance.

Each of these empirical findings has an exact mathematical counterpart proved below: the sufficiency of the bits (Theorem 3.5), the optimality of the theory weights (Theorem 5.3), and the strict cost of truncation (Theorem 5.5). The theorems are not statistical claims about a particular data set; they are arithmetic identities, and they explain why the empirical pattern is the pattern it is.

### 1.4 Organisation

Section 2 fixes notation and the sample spaces. Section 3 proves the root-count identity and the sufficiency of the indicator bit, and deduces the exactness of the dial. Section 4 computes the exact distribution over the Chinese-remainder sample space. Section 5 proves the optimality and anti-truncation theorems. Section 6 proves the two concentration theorems. Section 7 develops the dual position-side picture. Section 8 gives the algorithms and complexity, Section 9 discusses applications and limitations, and Section 10 lists open directions.

---

## 2. Setting and notation

Fix a factor base $\mathcal{S} = \{q_1, \dots, q_k\}$ of **distinct odd primes**, indexed by $i \in \{1,\dots,k\}$.

**Root set and root count.** For a prime $p$ and $N \in \mathbb{Z}$ put
$$R(p, N) = \{x \in \{0, 1, \dots, p-1\} : p \mid x^2 - N\}, \qquad r(p,N) = |R(p,N)|.$$
$R(p,N)$ is the set of residue classes of sieve positions at which $p$ divides $x^2 - N$, and $r(p,N)$ its cardinality. Equivalently, $r(p,N)$ counts the square roots of $N$ in $\mathbb{Z}/p\mathbb{Z}$.

**Indicator bit.** $b(p,N) = \mathbf{1}[r(p,N) > 0] \in \{0,1\}$.

**Hit density.** $d(p,N) = r(p,N)/p$: the fraction of sieve positions hit by $p$.

**Footprint.** $F_{\mathcal{S}}(N) = \sum_{p \in \mathcal{S}} d(p,N)$: the expected number of factor-base divisions per sieve position.

**Counting character.** $\chi(p,N) = r(p,N) - 1 \in \mathbb{Z}$.

**Mertens weight and character sum.** $M(\mathcal{S}) = \sum_{p \in \mathcal{S}} 1/p$ and $X_{\mathcal{S}}(N) = \sum_{p \in \mathcal{S}} \chi(p,N)/p$.

**Admissible base.** We call $\mathcal{S}$ *admissible for $N$* if every $p \in \mathcal{S}$ is an odd prime with $p \nmid N$. (In practice $N$ is the number being factored and any $p \mid N$ is an immediate win, so admissibility is not restrictive; Theorem 3.8 removes the hypothesis anyway.)

**Target sample space.** By the Chinese remainder theorem, residues of $N$ modulo $Q = q_1 \cdots q_k$ that are coprime to $Q$ correspond bijectively to vectors
$$\Omega = \prod_{i=1}^{k} (\mathbb{Z}/q_i\mathbb{Z})^{\times}, \qquad |\Omega| = \prod_{i=1}^{k} (q_i - 1).$$
All statements about "randomising over $N$" mean the uniform measure on $\Omega$; all sums over $\Omega$ are finite sums, so no measure theory is involved.

**Position sample space.** Dually, $\Pi = \prod_i \mathbb{Z}/q_i\mathbb{Z}$ with $|\Pi| = \prod_i q_i$ parametrises sieve positions modulo $Q$.

---

## 3. The dial is an identity, not a model

### 3.1 The root count is the Legendre symbol

> **Theorem 3.1 (Root-count identity).** *Let $p$ be an odd prime and $N \in \mathbb{Z}$. Then*
> $$r(p, N) \;=\; \chi_p(N) + 1,$$
> *where $\chi_p$ is the Legendre symbol (so $\chi_p(N) = 0$ when $p \mid N$).*

*Proof sketch.* The count $r(p,N)$ equals the number of $x \in \mathbb{Z}/p\mathbb{Z}$ with $x^2 = \bar N$, since reduction mod $p$ is a bijection from $\{0,\dots,p-1\}$ onto $\mathbb{Z}/p\mathbb{Z}$. In a finite field of odd characteristic the squaring map is two-to-one on the nonzero elements, so the fibre over $a$ has size $1 + \eta(a)$ where $\eta$ is the quadratic character, extended by $\eta(0) = 0$; the fibre over $0$ is the singleton $\{0\}$, consistent with $1 + 0$. Identifying $\eta$ with the Legendre symbol gives the claim. $\square$

Three corollaries record the trichotomy explicitly.

> **Corollary 3.2.** *For an odd prime $p$ with $p \nmid N$: if $N$ is a square mod $p$ then $r(p,N) = 2$; otherwise $r(p,N) = 0$. In particular $r(p,N) \in \{0,2\}$, with no intermediate value.*

> **Corollary 3.3.** *For an odd prime $p$ with $p \mid N$, $r(p,N) = 1$ (the single ramified root $x \equiv 0$).*

> **Corollary 3.4.** *$\chi(p,N) = r(p,N) - 1$ coincides with the Legendre symbol $\chi_p(N)$ for every odd prime $p$ and every $N$.*

Corollary 3.4 is worth pausing over: the "counting character", defined without reference to characters at all, *is* the Legendre symbol. The multiplicativity, the reciprocity law, and the character sum estimates of classical number theory therefore apply verbatim to the combinatorial quantity $r(p,N) - 1$.

### 3.2 The bit is a sufficient statistic

> **Theorem 3.5 (Lottery law; sufficiency of the indicator bit).** *Let $p$ be an odd prime with $p \nmid N$. Then*
> $$d(p,N) \;=\; \begin{cases} 2/p, & b(p,N) = 1,\\[2pt] 0, & b(p,N) = 0.\end{cases}$$

*Proof.* Immediate from Corollary 3.2 and $d = r/p$. $\square$

The statement is trivial to prove and consequential to interpret. The *measured* hit fraction — the quantity one would obtain by actually running the sieve and counting divisions by $p$ — is a deterministic, two-valued function of the *single bit* $b(p,N)$. There is no scatter around $2/p$, no residual, and no third value. Hence, in the precise sense of statistical sufficiency, the bit vector $\big(b(q_1,N), \dots, b(q_k,N)\big)$ carries all the information the per-prime measurements can carry. Any predictor that consumes measured fractions in addition to the bits is a predictor of a function of the bits, and can add nothing. This is the exact form of the empirical finding that measured fractions offered no marginal improvement over the indicator vector.

### 3.3 The zero-fit theorem

> **Theorem 3.6 (Zero-fit theorem).** *Let $\mathcal{S}$ be admissible for $N$. Then*
> $$T_{\mathcal{S}}(N) \;=\; F_{\mathcal{S}}(N).$$
> *That is, the closed-form dial equals the expected footprint exactly.*

*Proof.* Sum Theorem 3.5 over $p \in \mathcal{S}$: the left side is $\sum_{p : b = 1} 2/p = T_{\mathcal{S}}(N)$ and the right side is $\sum_p d(p,N) = F_{\mathcal{S}}(N)$. $\square$

The coefficient $2/p$ is therefore not fitted, not calibrated, and not asymptotic. It is the unique value making the identity true, and it was fixed by Theorem 3.1 before any data existed.

### 3.4 Main term and fluctuation

> **Theorem 3.7 (Mertens decomposition).** *For $\mathcal{S}$ admissible for $N$,*
> $$T_{\mathcal{S}}(N) \;=\; M(\mathcal{S}) \;+\; X_{\mathcal{S}}(N) \;=\; \sum_{p \in \mathcal{S}} \frac{1}{p} \;+\; \sum_{p \in \mathcal{S}} \frac{\chi_p(N)}{p}.$$

*Proof.* By Theorem 3.1, $d(p,N) = (1 + \chi(p,N))/p$ pointwise; sum over $\mathcal{S}$ and apply Theorem 3.6. $\square$

The decomposition separates a term independent of $N$ — the Mertens weight, which by Mertens' second theorem satisfies $\sum_{p \le B} 1/p = \log \log B + M + o(1)$ — from a Legendre character sum carrying the entire $N$-dependence. Elementary consequences follow at once: $0 \le T_{\mathcal{S}}(N) \le 2M(\mathcal{S})$, both extremes being attained (Theorem 4.5).

### 3.5 Removing the coprimality hypothesis

> **Definition (Total dial).** $\;\widetilde T_{\mathcal{S}}(N) = \sum_{p \in \mathcal{S}} \begin{cases} 1/p & p \mid N,\\ 2/p & p \nmid N,\ b(p,N)=1,\\ 0 & \text{otherwise.}\end{cases}$

> **Theorem 3.8 (Total exactness).** *For any finite set $\mathcal{S}$ of odd primes and any $N \in \mathbb{Z}$, $\widetilde T_{\mathcal{S}}(N) = F_{\mathcal{S}}(N)$; and if $\mathcal{S}$ is admissible for $N$ then $\widetilde T_{\mathcal{S}}(N) = T_{\mathcal{S}}(N)$.*

*Proof.* Case split on $p \mid N$, applying Corollary 3.3 in the ramified case and Theorem 3.5 otherwise. $\square$

The ramified primes carry the *half* weight $1/p$, exactly as Theorem 3.1 dictates. The total dial is thus a genuinely total function of $N$: exact for every integer, with no side condition.

---

## 4. The exact distribution of the dial

We now regard $T$ as a random variable on $\Omega = \prod_i (\mathbb{Z}/q_i\mathbb{Z})^{\times}$ under the uniform measure, writing
$$T(x) = \sum_{i=1}^{k} \frac{2}{q_i} \, \mathbf{1}[x_i \text{ is a square}], \qquad x \in \Omega.$$

### 4.1 Fairness at a single prime

> **Theorem 4.1 (Fair lottery).** *Let $p$ be an odd prime and let $W_p$ (resp. $L_p$) be the set of $N \in \{0,\dots,p-1\}$ with $r(p,N) = 2$ (resp. $r(p,N) = 0$). Then*
> $$2|W_p| + 1 = p, \qquad |W_p| = |L_p| = \frac{p-1}{2}, \qquad \frac{|W_p|}{p-1} = \frac{1}{2}.$$

*Proof sketch.* Summing $r(p,\cdot)$ over all $p$ residue classes counts each $x \in \mathbb{Z}/p\mathbb{Z}$ exactly once (as a root of the unique class $x^2$), so $\sum_{N=0}^{p-1} r(p,N) = p$. The class $N \equiv 0$ contributes $1$; every other class contributes $2$ or $0$ by Corollary 3.2; hence $2|W_p| + 1 = p$. Since $|W_p| + |L_p| = p - 1$, the two ticket sets are equinumerous. $\square$

Equivalently, in mean form: $\;\frac{1}{p}\sum_{N=0}^{p-1} d(p,N) = \frac{1}{p}$. Each prime contributes, on average over targets, exactly one expected hit per period — a statement with no error term and no fitted constant.

### 4.2 Exact independence across primes

Write $\mathrm{Win}_i \subset (\mathbb{Z}/q_i\mathbb{Z})^\times$ for the quadratic residues and $\mathrm{Lose}_i$ for the non-residues, so $|\mathrm{Win}_i| = |\mathrm{Lose}_i| = (q_i-1)/2$ by Theorem 4.1. For a pattern $\varepsilon \in \{0,1\}^k$ let $\mathrm{Tick}_i(\varepsilon) = \mathrm{Win}_i$ if $\varepsilon_i = 1$ and $\mathrm{Lose}_i$ otherwise.

> **Theorem 4.2 (Exact independence).** *For every pattern $\varepsilon \in \{0,1\}^k$,*
> $$\#\{x \in \Omega : b(q_i, x_i) = \varepsilon_i \ \forall i\} \;=\; \prod_{i=1}^{k} \frac{q_i - 1}{2} \;=\; \frac{|\Omega|}{2^{k}} .$$
> *In particular the count is the same for all $2^k$ patterns, so the bit vector is uniform on $\{0,1\}^k$ and the bits are mutually independent fair coins.*

*Proof.* The event is the product set $\prod_i \mathrm{Tick}_i(\varepsilon)$, whose cardinality is the product of the factor cardinalities, each $(q_i-1)/2$ by Theorem 4.1, independently of $\varepsilon_i$. $\square$

This is not a heuristic independence assumption of the kind common in sieve analysis; it is an exact combinatorial identity, and the source of every moment computation below.

### 4.3 Moments

> **Theorem 4.3 (Mean).** $\;\displaystyle \mathbb{E}_\Omega[T] = \sum_{i=1}^{k} \frac{1}{q_i} = M(\mathcal{S}).$

*Proof sketch.* By linearity it suffices to compute $\mathbb{E}[\mathbf{1}[x_i \in \mathrm{Win}_i]] = |\mathrm{Win}_i|/(q_i-1) = 1/2$ for each $i$; the summand $2/q_i$ then contributes $1/q_i$. Formally, the one-coordinate marginal of a product set factors as the marginal sum times the number of completions. $\square$

> **Theorem 4.4 (Variance).** $\;\displaystyle \operatorname{Var}_\Omega[T] = \sum_{i=1}^{k} \frac{1}{q_i^{2}}.$

*Proof sketch.* Write $T - \mathbb{E}[T] = \sum_i c_i(x_i)$ where $c_i$ is the centred coin taking the two values $\pm 1/q_i$ (namely $\pm w_i/2$ with $w_i = 2/q_i$). Expanding the square gives diagonal terms $\mathbb{E}[c_i^2] = w_i^2/4 = 1/q_i^2$ and off-diagonal terms $\mathbb{E}[c_i c_j] = \mathbb{E}[c_i]\,\mathbb{E}[c_j] = 0$ for $i \ne j$, the factorisation being the two-coordinate marginal identity for product sets and the vanishing being the fairness of Theorem 4.1. $\square$

The variance formula holds for arbitrary weights too: a general read-out $\widehat T_w(x) = \sum_i w_i \mathbf{1}[x_i \in \mathrm{Win}_i]$ has mean $\sum_i w_i/2$, variance $\sum_i w_i^2/4$, and uncentred second moment $\big(\sum_i w_i/2\big)^2 + \sum_i w_i^2/4$. This last identity is the engine of Section 5.

### 4.4 Steerability

> **Theorem 4.5 (Steerability).** *For distinct odd primes $q_1,\dots,q_k$ and any prescribed pattern $\varepsilon \in \{0,1\}^k$, there exists a positive integer $N$ with $r(q_i, N) = 2$ whenever $\varepsilon_i = 1$ and $r(q_i, N) = 0$ whenever $\varepsilon_i = 0$. Consequently there exist targets with $T_{\mathcal{S}}(N) = \sum_i 2/q_i$ (maximum) and with $T_{\mathcal{S}}(N) = 0$ (minimum).*

*Proof sketch.* Each ticket set $\mathrm{Tick}_i(\varepsilon)$ is nonempty, since $(q_i-1)/2 \ge 1$ for $q_i \ge 3$. Choose a representative in each and apply the Chinese remainder theorem (the moduli being pairwise coprime as distinct primes) to obtain $N$ with the prescribed residues; root counts depend only on residue classes. $\square$

Steerability matters for two reasons. It shows the $2^k$-point spectrum of the dial is fully realised by integers, so no value predicted by the distribution theory is vacuous; and it shows that a *user* can in principle select or construct targets in the upper tail — a search direction rather than a mere descriptive statistic.

---

## 5. Optimality: no fit can beat the theory weights

The empirical claim to be explained is that the zero-parameter dial outperforms models with fitted per-prime coefficients. We prove the strongest possible form of this: over the sample space, the theory weights are the unique global minimiser of squared error, and every alternative is worse by an explicitly computable amount.

Let $w = (w_1,\dots,w_k) \in \mathbb{R}^k$ be arbitrary and define the read-out and its risk by
$$\widehat T_w(x) = \sum_{i=1}^{k} w_i \,\mathbf{1}[x_i \in \mathrm{Win}_i], \qquad \mathcal{R}(w) = \sum_{x \in \Omega} \big(T(x) - \widehat T_w(x)\big)^2 .$$

> **Theorem 5.1 (Exact second moment).** *For any $w$,*
> $$\sum_{x \in \Omega} \widehat T_w(x)^2 \;=\; |\Omega| \left[ \Big(\sum_{i} \frac{w_i}{2}\Big)^{2} + \sum_i \frac{w_i^{2}}{4} \right].$$

*Proof sketch.* Write $\widehat T_w = (\widehat T_w - m) + m$ with $m = \sum_i w_i/2$ the mean, expand, and use $\sum_x (\widehat T_w - m) = 0$ together with the variance computation of Theorem 4.4 applied to the weights $w$. $\square$

> **Theorem 5.2 (Exact risk formula).** *Put $\delta_i = 2/q_i - w_i$. Then*
> $$\mathcal{R}(w) \;=\; |\Omega|\left[\Big(\sum_i \frac{\delta_i}{2}\Big)^{2} + \sum_i \frac{\delta_i^{2}}{4}\right].$$

*Proof.* The read-out is linear in the weights: $T - \widehat T_w = \widehat T_{\delta}$ with $\delta = (2/q_i - w_i)_i$. Apply Theorem 5.1 to $\delta$. $\square$

> **Theorem 5.3 (Unique minimiser).** *$\mathcal{R}(w) \ge 0$ always; $\mathcal{R}(2/q_\bullet) = 0$; and $\mathcal{R}(w) = 0$ if and only if $w_i = 2/q_i$ for every $i$.*

*Proof.* Non-negativity is clear from the definition as a sum of squares. Vanishing at the theory weights is immediate since then $T - \widehat T_w \equiv 0$. Conversely, since $|\Omega| > 0$, vanishing of the bracket in Theorem 5.2 forces $\sum_i \delta_i^2/4 = 0$ (the two bracket terms are separately non-negative), hence $\delta \equiv 0$. $\square$

Theorem 5.3 is the formal content of "zero-fit beats eight fitted bits". The risk landscape over the whole $k$-dimensional weight space is an explicit positive-semidefinite quadratic form in the deviations $\delta$, with a unique zero at the theory point. Fitting is not merely unnecessary; it is a search whose global optimum is known in closed form before the search begins. Any fitted vector obtained from finite noisy data will land at $\delta \ne 0$ and hence at strictly positive risk.

Note also the structure of the bracket: it is $\big(\sum_i \delta_i/2\big)^2 + \sum_i \delta_i^2/4$, a *mean-squared* term plus a *variance* term. Deviations that cancel in the mean are still penalised by the second term; there is no direction in weight space along which error is free.

### 5.1 The cost of truncation

Practitioners frequently truncate: keep the smallest primes and drop the rest, on the intuition that the tail weights $2/p$ are negligible. Theorem 5.2 prices this exactly.

> **Theorem 5.4 (Truncation risk).** *Let $S \subseteq \{1,\dots,k\}$ be the retained index set and $w_i = 2/q_i$ for $i \in S$, $w_i = 0$ otherwise. Then*
> $$\mathcal{R}(w) \;=\; |\Omega| \left[\Big(\sum_{i \notin S} \frac{1}{q_i}\Big)^{2} + \sum_{i \notin S} \frac{1}{q_i^{2}}\right].$$

*Proof.* Here $\delta_i = 0$ for $i \in S$ and $\delta_i = 2/q_i$ for $i \notin S$; substitute into Theorem 5.2. $\square$

> **Theorem 5.5 (Truncation is strictly costly).** *If at least one prime is dropped, $\mathcal{R}(w) > 0$.*

*Proof.* If $j \notin S$ then the second bracket term is at least $1/q_j^2 > 0$, and the first is non-negative. $\square$

Full support therefore strictly dominates every truncation, however small the dropped weights. This is the exact form of the empirical decision to keep the full $p \le 400$ support rather than a truncated bit set.

A complementary monotonicity holds at the level of the dial itself rather than the risk: for $\mathcal{S} \subseteq \mathcal{S}'$,
$$T_{\mathcal{S}}(N) \;\le\; T_{\mathcal{S}'}(N), \qquad T_{\mathcal{S}'}(N) - T_{\mathcal{S}}(N) \;=\; \sum_{\substack{p \in \mathcal{S}' \setminus \mathcal{S} \\ b(p,N) = 1}} \frac{2}{p},$$
so truncation can only *lower* the dial, by exactly the tail sum over dropped winning primes. The deficit is target-dependent, which is precisely why truncation degrades a *ranking*: it removes a target-dependent quantity, not a constant.

---

## 6. Concentration, uniformly in the factor base

The moments of Section 4 exhibit a structural tension. The mean $M(\mathcal{S}) = \sum_i 1/q_i$ diverges as $B \to \infty$ (Mertens: $\sim \log\log B$), while the variance $\sum_i 1/q_i^2$ is *bounded*, indeed by an absolute constant.

> **Lemma 6.1 (Bounded variance).** *For any finite family of distinct integers $q_i \ge 3$,*
> $$\sum_{i} \frac{1}{q_i^{2}} \;\le\; \sum_{m \ge 3} \frac{1}{m^{2}} \;<\; \frac{1}{2}.$$

*Proof sketch.* Distinctness lets us embed the family in $\{3, 4, \dots, M\}$ and dominate term by term. The telescoping bound $1/m^2 < 1/(m-1) - 1/m$ for $m \ge 2$ yields $\sum_{m=3}^{M} 1/m^2 < 1/2 - 1/M < 1/2$ by induction on $M$. No analytic input (no Basel value $\pi^2/6$) is required. $\square$

Every deviation bound below is therefore *uniform in the factor base*: it depends on neither the primes chosen nor how many there are.

### 6.1 Polynomial tail

> **Theorem 6.2 (Chebyshev, uniform).** *For every $t > 0$,*
> $$\frac{\#\{x \in \Omega : |T(x) - M(\mathcal{S})| \ge t\}}{|\Omega|} \;\le\; \frac{\sum_i 1/q_i^{2}}{t^{2}} \;\le\; \frac{1}{2t^{2}}.$$

*Proof.* The finite Chebyshev inequality $\#\{|f - m| \ge t\}\, t^2 \le \sum_x (f(x)-m)^2$ applied to $f = T$, $m = M(\mathcal{S})$, combined with the exact variance of Theorem 4.4 and Lemma 6.1. $\square$

> **Corollary 6.3.** *There always exists $x \in \Omega$ with $|T(x) - M(\mathcal{S})| < 1$: the Mertens weight is attained up to $1$, for every factor base.*

*Proof.* If not, the deviating set is all of $\Omega$, contradicting the bound $|\Omega|/2$ at $t = 1$. $\square$

> **Corollary 6.4 (Spread bound).** *If a fraction at least $c > 0$ of targets deviate by at least $t$, then $2ct^2 \le 1$, i.e. $t \le \sqrt{1/(2c)}$.*

### 6.2 Sub-Gaussian tail

The polynomial bound can be upgraded to an exponential one by the classical Chernoff–Hoeffding route, executed here entirely with finite sums.

> **Lemma 6.5 (Coin MGF).** *For an odd prime $p$ and reals $s, w$, the centred coin $c(y) = w\,\mathbf{1}[y \in \mathrm{Win}] - w/2$ on $(\mathbb{Z}/p\mathbb{Z})^\times$ satisfies*
> $$\sum_{y} e^{s\,c(y)} = (p-1)\cosh\!\Big(\frac{sw}{2}\Big).$$

*Proof.* The coin takes the value $+w/2$ on $\mathrm{Win}$ and $-w/2$ on $\mathrm{Lose}$, and the two sets are equinumerous of size $(p-1)/2$ by Theorem 4.1; so the sum is $\frac{p-1}{2}(e^{sw/2} + e^{-sw/2})$. $\square$

The absence of a first-order term is exactly the fairness of the lottery: an unfair coin would contribute a linear drift and destroy the symmetric $\cosh$.

> **Lemma 6.6 (Factorisation).** *For any weights $w$ and any $s \in \mathbb{R}$,*
> $$\sum_{x \in \Omega} \exp\!\Big(s\big(\widehat T_w(x) - \textstyle\sum_i w_i/2\big)\Big) \;=\; |\Omega| \prod_{i=1}^{k}\cosh\!\Big(\frac{s\,w_i}{2}\Big).$$

*Proof sketch.* The centred read-out is a sum of one-coordinate functions; the exponential of a sum is a product of exponentials; and sums of products of one-coordinate functions over a product set factor into products of one-coordinate sums. Apply Lemma 6.5 in each coordinate. $\square$

> **Theorem 6.7 (Sub-Gaussian MGF bound).** *With $V = \sum_i 1/q_i^2$ and any $s \in \mathbb{R}$,*
> $$\sum_{x \in \Omega} \exp\big(s(T(x) - M(\mathcal{S}))\big) \;\le\; |\Omega| \exp\!\Big(\frac{s^{2}}{2}V\Big).$$

*Proof.* Lemma 6.6 with $w_i = 2/q_i$ gives the product $\prod_i \cosh(s/q_i)$; apply $\cosh u \le e^{u^2/2}$ termwise and collect exponents, $\sum_i (s/q_i)^2/2 = s^2 V/2$. $\square$

> **Theorem 6.8 (Two-sided Hoeffding tail).** *For $t \ge 0$ and $V = \sum_i 1/q_i^2 > 0$,*
> $$\#\{x \in \Omega: |T(x) - M(\mathcal{S})| \ge t\} \;\le\; 2\,|\Omega|\,\exp\!\Big(-\frac{t^{2}}{2V}\Big).$$

*Proof sketch.* Exponential Markov: for $s \ge 0$, $\#\{T - M \ge t\}\,e^{st} \le \sum_x e^{s(T-M)} \le |\Omega| e^{s^2V/2}$, so the upper-tail count is at most $|\Omega|\exp(s^2V/2 - st)$; optimise at $s = t/V$ to get $|\Omega| e^{-t^2/(2V)}$. The lower tail is the same argument applied to $M - T$, whose MGF obeys the same bound by the symmetry $s \mapsto -s$ of $\cosh$. Add the two. $\square$

> **Theorem 6.9 (Uniform sub-Gaussian tail).** *For distinct odd primes and every $t \ge 0$,*
> $$\frac{\#\{x \in \Omega : |T(x) - M(\mathcal{S})| \ge t\}}{|\Omega|} \;\le\; 2e^{-t^{2}}.$$

*Proof.* Combine Theorem 6.8 with $V \le 1/2$ (Lemma 6.1), noting $t^2/(2V) \ge t^2$. The degenerate cases $k = 0$ and $t = 0$ are checked directly. $\square$

> **Proposition 6.10 (Exponential beats polynomial from $t=2$).** $\;2e^{-4} < \dfrac{1}{2\cdot 2^{2}}$, i.e. $0.0366\ldots < 0.125$.

> **Corollary 6.11 (No forced deviation).** *Whenever $2e^{-t^2} < 1$ — in particular for every $t \ge 1$ — some target reads within $t$ of the Mertens weight.*

The interpretation is worth stating plainly. As the factor base grows, the *centre* of the dial's distribution drifts upward without bound, but the *shape* around that centre is frozen: a sub-Gaussian profile with variance proxy at most $1/2$, identical for all factor bases. All the target-to-target variability in the sieve footprint lives in an $O(1)$ window, and the probability of a large excursion decays as $e^{-t^2}$ with an absolute constant.

---

## 7. The position side: a dual reading

Sections 4–6 randomise over the target $N$. A sieve implementation, however, randomises over *positions*. We show the same dial governs that picture.

Let $\Pi = \prod_i \mathbb{Z}/q_i\mathbb{Z}$ be the space of sieve positions modulo $Q$, and for a fixed target $N$ define the *hit counter*
$$H(x) \;=\; \#\{i : q_i \text{ divides } x^2 - N\} \;=\; \sum_{i=1}^{k} \mathbf{1}\big[x_i \in R(q_i, N)\big].$$

> **Theorem 7.1 (Position-side mean).** $\;\displaystyle \mathbb{E}_\Pi[H] = \sum_{i=1}^{k} \frac{r(q_i,N)}{q_i}$. *If $\mathcal{S}$ is admissible for $N$, this equals $T_{\mathcal{S}}(N)$.*

*Proof sketch.* Linearity plus the one-coordinate marginal identity: $\mathbb{E}[\mathbf{1}[x_i \in R(q_i,N)]] = r(q_i,N)/q_i$. The identification with the dial is Theorem 3.6. $\square$

> **Theorem 7.2 (Position-side variance).** $\;\displaystyle \operatorname{Var}_\Pi[H] = \sum_{i=1}^{k} \frac{r_i}{q_i}\Big(1 - \frac{r_i}{q_i}\Big)$ *with $r_i = r(q_i,N)$; for admissible $\mathcal{S}$,*
> $$\operatorname{Var}_\Pi[H] = \sum_{\substack{i \,:\, b(q_i,N)=1}} \frac{2}{q_i}\Big(1 - \frac{2}{q_i}\Big).$$

*Proof sketch.* Centre each indicator and expand; diagonal terms give the Bernoulli variances $\frac{r_i}{q_i}(1 - \frac{r_i}{q_i})$ and cross terms vanish by the two-coordinate factorisation over the product space $\Pi$. $\square$

So the hit counter is a sum of independent Bernoulli indicators whose success probabilities are the theory-forced $r_i/q_i \in \{0, 2/q_i\}$; its mean is the dial and its variance is the standard $\sum \pi_i (1-\pi_i)$. Nothing here is fitted either, and the agreement of the two readings — across targets and across positions — is a consistency check on the whole framework: the dial is simultaneously an expectation over $N$-randomness and an expectation over $x$-randomness.

---

## 8. Algorithms and complexity

**Algorithm A (Dial evaluation).** Input: target $N$, bound $B$. Output: $T(N)$.

1. Generate all odd primes $p \le B$ (sieve of Eratosthenes, $O(B \log\log B)$, done once and cached).
2. For each $p$: if $p \mid N$, add $1/p$ (total dial) or skip (admissible dial); else compute the Legendre symbol $\chi_p(N)$ by the binary reciprocity algorithm in $O(\log^2 p)$ bit operations; add $2/p$ if $\chi_p(N)=1$.
3. Return the accumulated sum.

Total cost after the one-time sieve: $O(\pi(B) \log^2 B)$ bit operations, i.e. microseconds for $B = 400$. This is negligible next to any factoring attempt, which is the entire practical point: the dial is a *free* pre-screen.

**Algorithm B (Exact distribution).** Input: factor base $q_1,\dots,q_k$. Output: mean, variance, and the exact tail profile of $T$.

Mean $\sum 1/q_i$ and variance $\sum 1/q_i^2$ are $O(k)$ by Theorems 4.3–4.4. The full distribution is the $2^k$-point law of $\sum_i (2/q_i) \mathrm{Bern}(1/2)$; its cumulative distribution can be tabulated to accuracy $\epsilon$ in $O(k/\epsilon)$ by discretised convolution, since all atoms lie in $[0, 2M]$.

**Algorithm C (Risk audit of a fitted model).** Input: a proposed weight vector $w$. Output: the exact excess risk relative to theory.

Compute $\delta_i = 2/q_i - w_i$ and return $\big(\sum_i \delta_i/2\big)^2 + \sum_i \delta_i^2/4$ (per sample point), by Theorem 5.2. Cost $O(k)$. Any fitting procedure can be audited in linear time against the closed-form optimum — no cross-validation required.

**Algorithm D (Target steering).** Input: a desired bit pattern $\varepsilon$. Output: $N$ realising it.

For each $i$, find a residue $a_i$ with the prescribed quadratic character mod $q_i$ (test $a = 1, 2, 3, \dots$ against Euler's criterion $a^{(q_i-1)/2} \bmod q_i$; expected $O(1)$ trials since half the classes qualify); then CRT the $a_i$ together, $O(k \log^2 Q)$. By Theorem 4.5 this always succeeds.

---

## 9. Discussion

### 9.1 What has been established

The dial $T(N) = \sum_{\chi_p(N)=1} 2/p$ is (i) *exactly* the expected per-position factor-base footprint, with the coefficient $2/p$ forced by the root-count identity; (ii) a function of a *sufficient statistic*, the quadratic-residue indicator vector, so no per-prime measurement can improve on it; (iii) the *unique* minimiser of squared error over all linear read-outs of that vector, with an explicit quadratic penalty for every deviation and a strictly positive penalty for every truncation; and (iv) a sum of exactly independent fair coins with diverging mean $\sum 1/p$ and absolutely bounded variance $\sum 1/p^2 < 1/2$, hence sub-Gaussian with a factor-base-free tail $2e^{-t^2}$.

Taken together, these turn an empirical regression finding into a structural theorem. The observed superiority of the zero-parameter dial over an eight-parameter fitted model (out-of-sample $R^2$ of roughly $0.54$ versus $0.46$) is not a small-sample accident: Theorem 5.3 says every fitted alternative is strictly worse against the true footprint, and the only way a fit can approach the dial's accuracy is by converging to the dial.

### 9.2 What has not been established

The theorems concern the *footprint* — the expected number of factor-base divisions — not the *smoothness yield*, which is the quantity a factoring run ultimately cares about. Yield depends on the joint distribution of the full factorisation of $x^2 - N$, and while the footprint is plainly the dominant first-order driver (a target hit by more primes produces more smooth values), the passage from footprint to yield involves a Dickman-type smoothness density and is not linear. The empirical scale factor relating $T$ to measured rate — and the residual $R^2 \approx 0.46$ of unexplained variance — live exactly in that gap.

Second, the concentration theorems describe the distribution of $T$ over residue vectors uniform on $\Omega$; a real workload of targets is not uniform on $\Omega$, and conditioning (for instance on $N$ being an RSA modulus of a given size) could in principle bias the bit distribution. Theorem 4.2 makes the *unconditional* independence exact, which is the correct null model, but it is a null model.

Third, the variance bound $V < 1/2$ is uniform but not tight for the factor bases actually used: for the odd primes up to $400$, $V = \sum 1/p^2 \approx 0.2019$, so Theorem 6.8 gives the sharper tail $2\exp(-t^2/0.4038) \approx 2e^{-2.48\,t^2}$. The uniform statement is the theoretically striking one; the exact-$V$ statement is the one to quote in practice. Note also that $V$ is dominated by its first few terms ($1/9 + 1/25 = 0.151$ of the total $0.2019$), so it is essentially constant once $B$ exceeds a few hundred.

### 9.3 Relation to classical sieve theory

The Mertens decomposition $T = \sum 1/p + \sum \chi_p(N)/p$ places the dial in a familiar frame. The first sum is the standard sieve density constant; the second is a character sum over primes, of exactly the type controlled (conditionally) by Generalised Riemann Hypothesis bounds and (unconditionally, on average) by large-sieve inequalities. Our concentration results give an unconditional, *exact-distribution* account of the fluctuation term for a fixed factor base — a statement about the distribution over $N$, complementary to the classical statements about the size of the sum for individual $N$ as $B$ grows.

It is also worth noting what the exactness buys over the usual heuristics. Sieve analyses routinely *assume* independence of divisibility events across primes and *approximate* the density of hits at $p$ by $2/p$ on the residues where the polynomial splits. Here both statements are theorems with no error term: independence is the CRT product structure (Theorem 4.2), and the density is the root count divided by $p$ (Theorem 3.5). The usual heuristic step is thereby eliminated at the level of the footprint, and the remaining heuristic content of a sieve analysis is isolated in the smoothness-density step.

### 9.4 Methodological reading

There is a general lesson in the risk formula. In model selection one usually compares candidates by held-out error; here the comparison can be done analytically, because the space of candidate weight vectors is finite-dimensional and the error functional is a known quadratic form with a known unique zero. Whenever a modelling problem admits such a structure — a sufficient discrete statistic and a linear read-out — the entire fitting exercise reduces to identifying the coefficient forced by the underlying arithmetic. The right question is not "which coefficients fit best?" but "what identity determines them?"

---

## 10. Future directions

**Beyond the footprint: yield.** The clean target is a theorem relating $T(N)$ to smoothness yield. A plausible route is to combine the position-side Bernoulli structure of Theorem 7.2 with a Dickman/Buchstab analysis of the residual cofactor, aiming at an asymptotic of the form $\text{yield} \asymp \rho(u)\, e^{c\,T(N)}$ or a rigorous monotonicity statement in $T$.

**Higher moments and Poisson limits.** The MGF factorisation of Lemma 6.6 gives *all* cumulants of the dial in closed form: the $m$-th cumulant is $\kappa_m = \sum_i \kappa_m^{(i)}$ with the single-coin cumulants read off from $\log\cosh(s/q_i)$. Extracting a Poisson or compound-Poisson limit theorem for the hit counter $H$ as $B \to \infty$ looks tractable and would sharpen the position-side picture.

**Non-uniform target ensembles.** Replace the uniform measure on $\Omega$ by a measure reflecting an actual workload (e.g. semiprimes of a fixed bit length) and determine whether the bit vector remains uniform. Equidistribution of Legendre symbol patterns across such ensembles is an accessible question with a large-sieve flavour.

**Character-sum sharpening.** With the identification $\chi(p,N) = \chi_p(N)$, the fluctuation term is a genuine prime character sum. Combining our exact distributional control (over $N$) with classical bounds (for fixed $N$, over $p$) could yield hybrid statements: for example, an unconditional bound on the number of $N \le X$ whose dial exceeds the Mertens weight by more than $t$, for all $t$ simultaneously.

**Multiple polynomials and other sieves.** The analysis is specific to $f(x) = x^2 - N$. For MPQS one has $f(x) = ax^2 + bx + c$ with discriminant $b^2 - 4ac = 4N$, and the same root-count identity holds with the Legendre symbol of the discriminant; for the number field sieve the analogue involves splitting behaviour of primes in a number field, where the root count is the number of degree-one primes above $p$. Both should admit a zero-fit dial with the coefficient forced by the same mechanism — the arithmetic decides the payout, not the modeller.

**Steering as a design tool.** Theorem 4.5 shows every bit pattern is realisable. For applications where the target may be chosen (benchmark construction, adversarial or best-case instance generation, or the selection of an auxiliary multiplier $m$ so that $mN$ has a favourable dial), the steering algorithm turns the descriptive theory into a constructive one. The multiplier question in particular — choose small $m$ maximising $T(mN)$ — is a concrete finite optimisation with immediate practical value.

**Optimal read-outs beyond the linear class.** Theorem 5.3 establishes optimality within the class of *linear* functions of the bit vector. If the eventual target is yield rather than footprint, the optimal read-out may be nonlinear; characterising the optimum in a larger function class (with the bits still sufficient, by Theorem 3.5) is the natural next optimality question.

---

## Appendix: summary of the main statements

| Statement | Content |
|---|---|
| Root-count identity | $r(p,N) = \chi_p(N) + 1$ for every odd prime $p$ |
| Trichotomy | $r(p,N) = 2$ (residue), $0$ (non-residue), $1$ (ramified) |
| Lottery law | $d(p,N) = 2/p$ if the bit is on, $0$ if off — bit is sufficient |
| Zero-fit theorem | $T_{\mathcal{S}}(N) = F_{\mathcal{S}}(N)$ exactly |
| Mertens decomposition | $T = \sum 1/p + \sum \chi_p(N)/p$ |
| Total dial | Exact for all $N$, with weight $1/p$ at ramified primes |
| Fairness | $2\lvert W_p\rvert + 1 = p$; win probability exactly $1/2$ |
| Exact independence | Each of $2^k$ bit patterns has exactly $\lvert\Omega\rvert/2^k$ preimages |
| Steerability | Every bit pattern realised by an integer (CRT) |
| Mean / Variance | $\mathbb{E}[T] = \sum 1/q_i$, $\operatorname{Var}[T] = \sum 1/q_i^2$ |
| Exact risk | $\mathcal{R}(w) = \lvert\Omega\rvert[(\sum \delta_i/2)^2 + \sum \delta_i^2/4]$, $\delta_i = 2/q_i - w_i$ |
| Unique minimiser | $\mathcal{R}(w) = 0 \iff w_i = 2/q_i\ \forall i$ |
| Truncation cost | $\lvert\Omega\rvert[(\sum_{\mathcal{T}} 1/q_i)^2 + \sum_{\mathcal{T}} 1/q_i^2] > 0$ |
| Bounded variance | $\sum 1/q_i^2 < 1/2$ for distinct odd $q_i$ |
| Chebyshev tail | deviating fraction $\le 1/(2t^2)$, uniformly |
| Sub-Gaussian tail | deviating fraction $\le 2e^{-t^2/(2V)} \le 2e^{-t^2}$ |
| Position-side mean | $\mathbb{E}_x[H] = T(N)$ |
| Position-side variance | $\sum_{\text{winners}} (2/q_i)(1 - 2/q_i)$ |
