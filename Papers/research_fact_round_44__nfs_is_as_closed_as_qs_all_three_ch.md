# Constant Factors, Truncated Counters and Honest Slopes: Closing the Per-Instance Channels of the Number Field Sieve

**Aristotle**

*October 2026*

---

## Abstract

We examine three proposed channels through which structure specific to an instance $N$ might yield an exploitable improvement to the general number field sieve (NFS) within the terms of its subexponential cost $L_N[1/3, (64/9)^{1/3}]$. The channels are (i) a measured cost ratio for a modified sieve, (ii) per-instance measurements of sparse $\mathbb F_2$ elimination in the congruence-of-squares stage, and (iii) a claimed "inversion" in which the dependency surplus outgrows the width cost of the relation matrix. Each is closed by an elementary theorem. (i) The $L$-exponent of a cost function is unique and does not change under multiplication by any factor bounded between positive constants, whereas a genuine improvement of the constant produces a superpolynomial ratio. Constant-factor effects and $L$-effects are therefore strictly separated, and a measured ratio $0.9932 \pm 0.0122$ belongs to the first class. (ii) By rank–nullity the left nullity of a relation matrix is at least its excess $r-c$, so a dependency counter truncated at $60$ returns the constant $60$ on every matrix of excess at least $60$, and already at excess $6$ if nonzero dependency vectors are counted. (iii) The two-point log–log slope of the surplus is $\ln 7.94/\ln 5.30 \in (6/5, 5/4)$, strictly below the width exponent $1.819$. For power laws with $0<s<t$ the surplus-to-cost ratio decreases strictly to $0$, so no inversion exists at any consumption level. We complete the picture with the structural facts behind the decoupling of the NFS factor base from $N$: base-$m$ polynomial selection, the homogeneous norm bound $|F(a,b)| \le (d+1)MU^d$, and the degree balance $du + x/d \ge 2\sqrt{ux}$ with its unique optimum. The decoupling is real but produces no excess. The conclusion is that the NFS, like the quadratic sieve, has no exploitable per-instance lever in its $L[1/3]$ cost terms as measured.

---

## 1. Introduction

The general number field sieve factors an integer $N$ in heuristic time

$$L_N\!\left[\tfrac13, c\right], \qquad L_N[\alpha, c] = \exp\!\Big(c\,(\ln N)^{\alpha}(\ln\ln N)^{1-\alpha}\Big), \qquad c = \left(\tfrac{64}{9}\right)^{1/3} \approx 1.923.$$

An improvement in this regime means lowering $\alpha$ or lowering $c$. Earlier work in the present program found the quadratic sieve (QS) closed: no per-instance structure of $N$ can be exploited in its paid $L[1/2]$ terms. The underlying reason is that the QS factor base is pinned to $N$ by the quadratic-residue condition $\left(\frac{N}{p}\right)=1$. The NFS was flagged as the one family to which this conclusion should not be extrapolated. Its algebraic factor base consists of prime ideals of degree one in an auxiliary number field $\mathbb Q(\theta)$, $f(\theta)=0$, of degree $d$. The column set is therefore governed by $d$ (and by $f$) rather than by $N$ directly.

This paper gives the adjudicated account of a round that tested whether this decoupling leaves an exploitable lever. Three channels were proposed, and adversarial review rejected all three. Our contribution is to show that each rejection rests on a short, fully rigorous mathematical statement, which we state and prove below:

1. **Constant factors are $L$-invisible** (Section 3). This is the theorem behind rejecting the measurement channel's single positive result as a constant-factor effect.
2. **Truncated dependency counts saturate** (Section 4). This is the theorem behind rejecting the sparse-linear-algebra experiment on instrument validity.
3. **Power laws with ordered exponents do not invert** (Section 5). This is the theorem behind rejecting the "inversion" headline using the experiment's own slopes.
4. **Decoupling without excess** (Section 6). These are the structural facts that explain why all three channels close.

We stress the empirical background, which the theorems complement rather than replace. The measurement channel's positive result could not be reproduced: the stored data recorded neither $N$ nor the smoothness bound $B$, and no generating procedure was available. A from-scratch rebuild produced a ratio of $0.9932 \pm 0.0122$ over $n = 4$ runs, consistent with no effect. The sparse-algebra routine was found to break out of its row loop after $60$ dependencies. The theorems below show that even under the most favourable reading of the data, none of the claims could have supported an $L[1/3]$ improvement.

### 1.1 Notation

Throughout, $x = \ln N > 0$ denotes the size variable. For $0 < \alpha \le 1$ and $c \in \mathbb R$ we write

$$L[\alpha, c](x) = \exp\!\big(c\, x^{\alpha} (\ln x)^{1-\alpha}\big), \qquad \Lambda_\alpha(x) = x^{\alpha}(\ln x)^{1-\alpha},$$

so that $\ln L[\alpha,c](x) = c\,\Lambda_\alpha(x)$. "Eventually" means "for all sufficiently large $x$."

---

## 2. The $L$-exponent

**Definition 2.1 ($L$-exponent).** A function $f:\mathbb R \to \mathbb R$ *has $L$-exponent $(\alpha, c)$* if

$$\lim_{x\to\infty} \frac{\ln f(x)}{\Lambda_\alpha(x)} = c.$$

This is the invariant reported in the factoring literature. For instance, "the NFS has constant $(64/9)^{1/3}$ at $\alpha = 1/3$."

**Lemma 2.2 (the scale diverges).** For $0 < \alpha \le 1$, $\Lambda_\alpha(x) \to \infty$.

*Proof.* For $x \ge e$ we have $\ln x \ge 1$. Since $1 - \alpha \ge 0$, this gives $(\ln x)^{1-\alpha} \ge 1$, hence $\Lambda_\alpha(x) \ge x^{\alpha} \to \infty$. $\square$

**Proposition 2.3 ($L$-functions have the expected exponent; uniqueness).** For $0<\alpha\le 1$ and any $c$, $L[\alpha,c]$ has $L$-exponent $(\alpha,c)$. If $f$ has $L$-exponents $(\alpha,c)$ and $(\alpha,c')$, then $c = c'$.

*Proof.* Once $\Lambda_\alpha(x) > 0$, which holds eventually by Lemma 2.2, the quotient $\ln L[\alpha,c](x)/\Lambda_\alpha(x) = c$ is constant. Uniqueness is uniqueness of limits in $\mathbb R$. $\square$

---

## 3. Channel 1: constant factors are invisible to the $L$-ladder

### 3.1 Invisibility

**Theorem 3.1 (constant factors are invisible).** Let $0<\alpha\le1$ and $K>0$. If $f$ is eventually positive and has $L$-exponent $(\alpha,c)$, then $x \mapsto K f(x)$ has $L$-exponent $(\alpha, c)$.

*Proof.* Eventually $f(x) > 0$ and $\Lambda_\alpha(x) > 0$, and on that range

$$\frac{\ln(Kf(x))}{\Lambda_\alpha(x)} = \frac{\ln K}{\Lambda_\alpha(x)} + \frac{\ln f(x)}{\Lambda_\alpha(x)}.$$

The first term tends to $0$ by Lemma 2.2 and the second tends to $c$. $\square$

**Theorem 3.2 (bounded factors are invisible).** Let $0<\alpha\le1$ and $0<a$. Suppose $f$ is eventually positive with $L$-exponent $(\alpha,c)$, and $g$ eventually satisfies $a \le g(x) \le b$. Then $x\mapsto g(x)f(x)$ has $L$-exponent $(\alpha,c)$.

*Proof.* Eventually $\ln a/\Lambda_\alpha \le \ln g/\Lambda_\alpha \le \ln b/\Lambda_\alpha$, using monotonicity of $\ln$ and positivity of $\Lambda_\alpha$. Both bounds tend to $0$, so the squeeze theorem gives $\ln g(x)/\Lambda_\alpha(x) \to 0$. Adding $\ln f/\Lambda_\alpha \to c$ completes the proof. $\square$

Theorem 3.2 is the precise form needed for experimental data. A measured "speedup ratio" reported as $\rho \pm \sigma$ with $\rho - \sigma > 0$ describes a perturbation confined between positive constants. In particular the rebuilt figure $0.9932 \pm 0.0122$, and any reproducible value of this kind, leaves the $L$-exponent unchanged.

### 3.2 Genuine gains are superpolynomial

**Lemma 3.3.** $L[\alpha,c](x)/L[\alpha,c'](x) = L[\alpha, c-c'](x)$.

*Proof.* Subtract the exponents. $\square$

**Theorem 3.4 (a genuine $L$-gain is superpolynomial).** Let $0<\alpha\le1$, $c' < c$, and $d \in \mathbb R$. Then

$$\frac{L[\alpha,c](x)/L[\alpha,c'](x)}{x^{d}} \longrightarrow \infty.$$

*Proof.* Let $\delta = c - c' > 0$. For $x \ge e$, $(\ln x)^{1-\alpha}\ge 1$, so by Lemma 3.3

$$\frac{L[\alpha,\delta](x)}{x^d} \;\ge\; \frac{e^{\delta x^\alpha}}{(x^{\alpha})^{d/\alpha}}.$$

Substitute $y = x^\alpha \to \infty$. The right-hand side becomes $e^{\delta y}/y^{d/\alpha}$, which tends to infinity because exponentials dominate powers. $\square$

**Corollary 3.5 (separation of categories).** If $0<\alpha\le1$ and $c'<c$, then for no real $K$ does $L[\alpha,c](x) \le K\, L[\alpha,c'](x)$ hold eventually.

*Proof.* Apply Theorem 3.4 with $d = 0$. Eventually the ratio exceeds $K$, which contradicts the inequality at any point where both hold. $\square$

**Corollary 3.6 (the rejection of the measurement channel, as a theorem).** Let $0<\alpha\le1$, $K>0$ and $c' \ne c$. Then $K\cdot L[\alpha,c]$ has $L$-exponent $(\alpha,c)$ and does **not** have $L$-exponent $(\alpha,c')$.

*Proof.* Combine Proposition 2.3, Theorem 3.1 and uniqueness. $\square$

**Interpretation.** Constant-factor effects and $L$-constant effects are disjoint classes. A constant factor never moves $c$. A move of $c$ is never bounded by any constant factor, since it grows faster than every power of $\ln N$. A finite set of measurements showing a ratio near a constant therefore cannot be evidence of an $L[1/3]$ improvement, regardless of the value of the constant. This is exactly the category that the task specification declared worthless.

---

## 4. Channel 2: the truncated dependency counter

### 4.1 Rank–nullity for relation matrices

Let $K$ be a field and $M \in K^{r\times c}$ the relation matrix: one row per relation, one column per factor-base element. In the sieve setting $K = \mathbb F_2$ and the entries are exponents mod $2$.

**Definition 4.1.** The *left kernel* of $M$ is $\{v \in K^r : vM = 0\}$. The *left nullity* $\nu(M)$ is its dimension, which is the number of independent dependencies that Gaussian elimination finds. The *excess* is $r - c$ (truncated at $0$).

**Theorem 4.2 (rank–nullity for relations).** $\operatorname{rank}M + \nu(M) = r$. Consequently $\nu(M) \ge r - c$.

*Proof.* Apply rank–nullity to the linear map $v \mapsto vM$ from $K^r$, which is the map $M^{\mathsf T}$. Its image has dimension $\operatorname{rank}M^{\mathsf T} = \operatorname{rank}M \le c$. $\square$

**Corollary 4.3 (counting over $\mathbb F_2$).** If $K=\mathbb F_2$, the left kernel has exactly $2^{\nu(M)}$ elements. Hence there are at least $2^{r-c}-1$ nonzero dependencies.

*Proof.* A $\nu$-dimensional $\mathbb F_2$-space has $2^\nu$ elements. Combine with Theorem 4.2 and monotonicity of $2^{(\cdot)}$. $\square$

Theorem 4.2 is the basic guarantee of every congruence-of-squares method, QS and NFS alike. Once relations outnumber primes, dependencies are certain to exist, and each yields a congruence $X^2 \equiv Y^2 \pmod N$ (in the NFS, after the square root in the number field).

### 4.2 Saturation of a capped reading

**Definition 4.4.** For $k \in \mathbb N$, the *$k$-truncated reading* of a count $n$ is $\tau_k(n) = \min(k,n)$.

**Theorem 4.5 (saturation).** If $k \le r - c$, then $\tau_k(\nu(M)) = k$.

*Proof.* By Theorem 4.2, $\nu(M) \ge r-c \ge k$. $\square$

**Corollary 4.6 (blindness).** For matrices $M\in K^{r\times c}$ and $M'\in K^{r'\times c'}$ with $k \le r-c$ and $k \le r'-c'$, $\tau_k(\nu(M)) = \tau_k(\nu(M'))$. Moreover $\tau_k$ is not injective: $\tau_k(k) = \tau_k(k+1)$.

**Corollary 4.7 (the observed instance).** For every $M \in \mathbb F_2^{r\times c}$ with $r - c \ge 60$, $\tau_{60}(\nu(M)) = 60$.

**Corollary 4.8 (vector-count variant).** If the routine counts nonzero dependency *vectors* rather than independent dependencies, then for every $M\in\mathbb F_2^{r\times c}$ with $r - c \ge 6$,

$$\tau_{60}\big(\#\{v\ne 0: vM=0\}\big) = 60.$$

*Proof.* By Corollary 4.3 the count is at least $2^{6}-1 = 63 \ge 60$. $\square$

**Interpretation.** NFS runs deliberately oversample relations, because a positive excess is needed to guarantee dependencies (Theorem 4.2). In that regime a counter capped at $60$ is a constant function of the instance. Every derived per-instance quantity read off the truncated run, including operation counts, fill-in and dependency yield, is therefore measured on an artificially terminated computation. Such quantities cannot carry per-instance structure. This proves the rejection on instrument validity. It does not prove that untruncated measurements would carry no structure. That question is taken up in Section 8.

An exploratory run on random sparse $\mathbb F_2$ matrices with $200$ columns and $12$ nonzeros per row illustrates the theorem. The observed nullity always satisfied $\nu - (r-c) \in \{1, 2\}$ in our samples, and the capped reading was $60$ for every excess at least $59$. These are illustrations only, not part of the argument.

---

## 5. Channel 3: no inversion

The third claim was that the dependency surplus $S$ grows faster with matrix width $W$ than the elimination cost $C$, so that the surplus "pays for" wider matrices beyond some point. Over the measured range the surplus grew by a factor of $7.94$ while the width grew by a factor of $5.30$. The cost was fitted as $C \sim W^{1.819}$.

### 5.1 The estimator

**Definition 5.1.** The two-point log–log slope is $\displaystyle \sigma(W_1,W_2;S_1,S_2) = \frac{\ln(S_2/S_1)}{\ln(W_2/W_1)}$.

**Proposition 5.2 (consistency).** If $a>0$, $W_1,W_2>0$, $W_1\ne W_2$, then $\sigma(W_1,W_2; aW_1^s, aW_2^s) = s$.

*Proof.* $aW_2^s/(aW_1^s) = (W_2/W_1)^s$, and $\ln(q^s) = s\ln q$ with $\ln q \ne 0$. $\square$

### 5.2 Bracketing the surplus slope

Let $s^\ast = \ln 7.94/\ln 5.30$ and $t^\ast = 1.819$.

**Proposition 5.3.** $\tfrac65 < s^\ast < \tfrac54$. In particular $0 < s^\ast < t^\ast$.

*Proof.* Since $\ln 5.3>0$, the upper bound is equivalent to $4\ln 7.94 < 5\ln 5.3$, i.e. $7.94^4 < 5.3^5$. This holds: $3974.50\ldots < 4181.95\ldots$. The lower bound is equivalent to $5.3^6 < 7.94^5$, i.e. $22164.3\ldots < 31557.4\ldots$. Both are finite rational comparisons. $\square$

Numerically $s^\ast = 1.24237\ldots$.

### 5.3 Ordered power laws never invert

**Theorem 5.4 (no inversion).** Let $a,b>0$ and $0<s<t$. Put $S(W) = aW^s$ and $C(W)=bW^t$ for $W>0$. Then:

1. $S$ and $C$ are strictly increasing;
2. $S/C$ is strictly decreasing;
3. if $S(W_0)\le C(W_0)$ for some $W_0>0$, then $S(W)\le C(W)$ for all $W\ge W_0$;
4. $S(W)/C(W)\to 0$ as $W\to\infty$.

*Proof.* (1) follows from positivity of the exponents. For (2), $S/C = (a/b)W^{-(t-s)}$ with $t-s>0$. Statement (3) follows from (2), since $S/C\le 1$ at $W_0$ and the ratio decreases afterwards. Statement (4) holds because $W^{-(t-s)} \to 0$. $\square$

**Corollary 5.5.** With $s = s^\ast$ and $t = t^\ast$, and any $a,b>0$, the surplus-to-cost ratio is strictly decreasing and tends to $0$.

**Interpretation.** Both quantities grow, the cost grows faster, and the crossover (if it occurs in range at all) happens exactly once, in the direction of cost dominance. The "inversion" is contradicted by the experiment's own numbers at every consumption level.

---

## 6. The structural boundary: decoupling without excess

We now explain why every channel closes, using the one feature that separates the NFS from the QS.

### 6.1 Base-$m$ polynomial selection

**Theorem 6.1 (base-$m$ selection).** Let $m\ge2$, $d\ge 0$ and $m^d \le N < m^{d+1}$. Let $f(X) = \sum_i c_i X^i$, where $(c_0, c_1, \dots)$ are the base-$m$ digits of $N$. Then:

* $f(m) = N$;
* $0 \le c_i < m$ for all $i$;
* $c_d \ne 0$ and $c_i = 0$ for $i > d$, so $\deg f = d$;
* $m \le N^{1/d}$ (for $d \ge 1$).

*Proof.* Evaluating the digit polynomial at $m$ reconstructs $N$, and every base-$m$ digit is below $m$. The bounds $m^d \le N < m^{d+1}$ say that $N$ has exactly $d+1$ base-$m$ digits, with the leading one nonzero. $\square$

*Example.* For $N = 1\,000\,000\,016\,000\,000\,063 = (10^9+7)(10^9+9)$ and $d = 3$ we get $m = 10^6$ and $f(X) = X^3 + 16000X + 63$. For $d=4$ we get $m=31622$ and $f(X) = X^4 + 3X^3 + 3384X^2 + 13068X + 29311$.

The polynomial, and hence the algebraic factor base, depends on $N$ only through $(m,d)$. All sizes are governed by $d$. This is the precise sense in which the NFS column set is decoupled from $N$, unlike the QS.

### 6.2 The homogeneous norm bound

**Theorem 6.2.** Let $d\in\mathbb N$, $c_0,\dots,c_d \in\mathbb Z$ with $|c_i|\le M$, and $a,b\in\mathbb Z$ with $|a|,|b|\le U$. Then

$$\Big|\sum_{i=0}^{d} c_i\, a^{i} b^{d-i}\Big| \;\le\; (d+1)\, M\, U^{d}.$$

*Proof.* By the triangle inequality, each of the $d+1$ terms satisfies $|c_i a^i b^{d-i}| \le M U^i U^{d-i} = MU^d$. $\square$

The factor $d+1$ is a constant for each fixed degree, so by Theorem 3.1 it is $L$-invisible.

### 6.3 The degree balance

In the heuristic analysis, the log-size of the quantities that must be smooth behaves like $du + x/d$, where $u = \ln U$ measures the sieve region and $x = \ln N$.

**Theorem 6.3 (degree balance).** For $u,x,d>0$,

$$d\,u + \frac{x}{d} \;\ge\; 2\sqrt{ux},$$

with equality if and only if $d = \sqrt{x/u}$.

*Proof.* Multiply by $d$. The difference is $d^2u - 2d\sqrt{ux} + x = (d\sqrt u - \sqrt x)^2 \ge 0$, which vanishes exactly when $d = \sqrt{x/u}$. A direct computation confirms that this value attains $2\sqrt{ux}$. $\square$

This AM–GM principle yields the exponent $1/3$ once $u$ is balanced against the smoothness probability in turn. It also shows that any instance-dependent choice of degree can at best *reach* the balanced value, never go below it.

### 6.4 Synthesis

The decoupling of the NFS from $N$ is genuine (Theorem 6.1). The quantities it controls enter the cost in only two ways: through constant factors such as $d+1$ (Theorem 6.2), which are $L$-invisible (Section 3), and through a balance whose optimum is fixed (Theorem 6.3). The factor base therefore has no degree-effect surplus. The only proposed per-instance handle on elimination cost was an instrument that is provably constant in the relevant regime (Section 4) and whose headline is contradicted by its own slopes (Section 5).

**Verdict.** As measured, the NFS has no exploitable per-instance lever in the $L[1/3]$ terms that dominate its cost. Zero factoring methods result. The NFS is as closed as the QS. The investigation did, however, genuinely address the NFS and not the QS in disguise, because its column set is governed by $d$.

---

## 7. Algorithms and computational illustrations

The arguments above suggest three simple diagnostics that we recommend applying before any claim of asymptotic improvement is made.

**Algorithm A (empirical $L$-constant).** Given costs $f(x_j)$ at sizes $x_j$, compute $\hat c_j = \ln f(x_j)/\Lambda_\alpha(x_j)$. Under a constant factor $K$, $\hat c_j - c = \ln K/\Lambda_\alpha(x_j)$, which decays like $x_j^{-\alpha}$. Under a genuine gain, the log of the ratio between methods grows like $\Lambda_\alpha$. Cost: $O(1)$ per sample.

**Algorithm B (instrument saturation check).** Before trusting a capped counter $\tau_k$, compute the excess $r - c$ (or $\log_2(k+1)$ for vector counts). If every instance of interest has excess at least $k$, the instrument is constant by Theorem 4.5. Cost: $O(1)$.

**Algorithm C (slope comparison).** Estimate $s$ and $t$ by two-point log–log slopes (Proposition 5.2). Certify the order by rational comparisons such as $7.94^4<5.3^5$ (Proposition 5.3). If $s<t$, conclude no inversion (Theorem 5.4). Cost: $O(1)$ arithmetic.

An illustrative computation of $\hat c$ for $f = K\cdot L[1/3, 1.923]$ gives the following values:

| bits of $N$ | $K=1$ | $K=1000$ | $K = 0.001$ |
|---|---|---|---|
| 512 | 1.92300 | 2.22277 | 1.62323 |
| 4096 | 1.92300 | 2.04546 | 1.80054 |
| $2^{20}$ | 1.92300 | 1.93655 | 1.90945 |
| $2^{40}$ | 1.92300 | 1.92308 | 1.92292 |

These illustrate Theorem 3.1. Even a factor of $1000$ is visible at cryptographic sizes as an apparent shift in $\hat c$, and this shift is an artefact that vanishes asymptotically. This is a practical warning: finite-size fits of $c$ cannot distinguish constant factors from constant improvements without the separation of Corollary 3.5.

---

## 8. Discussion and future work

**What the theorems do and do not say.** Sections 3–5 show that the three pieces of evidence offered for an NFS lever cannot support the claims made for them. They do not prove that no per-instance lever exists in principle. That would require a lower bound on factoring that is far out of reach. The verdict is the precise one stated: no lever in the $L[1/3]$ paid terms *as measured here*.

**Methodological lessons.** (a) State the scale on which a claim lives. On $L$-scales, bounded factors are invisible and genuine gains are superpolynomial. (b) Check that an instrument can vary. Rank–nullity predicts saturation before any run. (c) Compare exponents, not curves. Ordered power laws cross at most once.

**Open directions.**

1. *Polynomial-factor rigidity.* For $0<\alpha<1$, show that $g\cdot f$ has the same $L$-exponent as $f$ whenever $x^{-k}\le g(x)\le x^{k}$. The squeeze of Theorem 3.2 applies once one shows $\ln x/\Lambda_\alpha(x)\to 0$.
2. *Untruncated dependency counts.* For random sparse $\mathbb F_2$ relation matrices with $w$ nonzeros per row and excess $e\ge0$, show $\mathbb E[\nu] = e + O(1)$ uniformly in $c$. Then even untruncated counts carry only the excess. The lower bound is Theorem 4.2.
3. *Integer-degree gap.* Bound $\min_{d\in\mathbb N}(du + x/d) - 2\sqrt{ux}$ by $\tfrac u4(1+o(1))$, linking Theorem 6.3 to Section 3.
4. *Base-$m$ coefficient equidistribution.* For fixed $d$ and $N$ uniform in $[m^d, m^{d+1})$, study the distribution of the base-$m$ coefficients. The expectation is that they carry no per-instance excess beyond the scale $m$.

---

## 9. Conclusion

Three channels, three elementary theorems, one verdict. A constant is not an $L$. A counter that stops at sixty reads sixty. A slope of $1.242$ never overtakes a slope of $1.819$. Beneath all three lies the structural fact that the NFS's freedom from $N$ is channelled through a degree whose optimum is fixed by AM–GM. The number field sieve, like the quadratic sieve before it, offers no per-instance lever in the terms that dominate its cost.
