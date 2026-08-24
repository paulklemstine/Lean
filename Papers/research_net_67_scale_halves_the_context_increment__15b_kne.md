# The Attention-Budget Increment Law: Hinges, Identifiability, and a Context-Free Scale Threshold

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study the *attention-budget knee*: the smallest number $k$ of retained top-scoring keys at which a truncated attention computation still reproduces the behaviour of the full computation under a fixed drift criterion. For two autoregressive language models of different parameter scale, measured at contexts $512, 1024, 2048$, the knee follows the grid $16, 20, 24$ (small model) and $16, 16, 18$ (large model). We give a complete mathematical account of what these six numbers do and do not determine.

Three exact results correct the informal reading of the data. First, the large model's measured triple is *not* affine: its increments are $0$ then $2$, and no law of the form $k_0 + dj$ passes through the three points; the correct shape is a **hinge** $\max(16, 14 + 2j)$, a floor competing with an affine demand. Second, the advertised "halving" of the per-doubling increment, $4 \mapsto 2$, is a statement about the **terminal** increment only; the window-averaged increments are $4$ and $1$, a quartering, and the two readings provably disagree. Third, the deployment corollary "a 20-key budget covers both models to 2048" is false: the least uniform budget at 2048 is exactly $24$, and more generally the least budget safe to horizon $J$ is $16 + 4J$, dictated entirely by the small model. We further show that the two laws diverge — the key gap is $2j + 2$ past the hinge, hence unbounded — while the budget ratio tends to $2$.

We then ask where an additive per-doubling increment can come from. Working with retention curves $R_p(k) = \sum_{i<k} p_i$ of sorted attention profiles and knees $\kappa_p(\tau) = \min\{k : R_p(k) \ge \tau\}$, we prove a **no-go theorem**: for any *fixed* profile of finite total mass, renormalised to the context, the knee is bounded uniformly in context length, hence eventually constant along $n = 2^j$; consequently no fixed profile reproduces $16 + 4j$. The obstruction is summability, not the geometric ansatz. The correct object is a *family*: if the exponential decay rate degrades as $\lambda_j = \lambda_0/(j+1)$ — inverse proportionality to log-context — then the key requirement $\log(1/\delta)/\lambda_j$ is exactly affine in $j$ with increment $\log(1/\delta)/\lambda_0$, and doubling $\lambda_0$ halves the increment. A converse holds: affinity with slope $s$ forces $\lambda_j = (\log(1/\delta)/s)/(j+1)$. Calibrating at $\delta = e^{-4}$ realises the measured pair $(+4, +2)$ with $\lambda_0 = 1, 2$.

Finally we address identifiability and extrapolation. All hinges through the measured triple satisfy $b + 2s = 18$, $b + s \le 16$, which forces only $s \in [2,9]$: the advertised slope $2$ is a lower bound, and $(b,s) = (12,3)$ fits the same points, the two fits separating at context $4096$ ($20$ versus $21$ keys). A grid-resolution theorem, $\kappa \le \kappa_d < \kappa + d$ for the knee measured on multiples of $d$, explains exactly why a coarser sweep of the same model reported $20$ where the fine sweep reports $18$. Calibrating peakedness as $\lambda_0(N) = (2N)^\theta$ forces $\theta = \log 2/\log 3$ and yields the increment law $I(N) = 4(2N)^{-\theta}$, strictly decreasing, with the closed-form threshold $I(N) < 1 \iff N > 4.5$: above about $4.5$ billion parameters the attention budget is effectively context-free. The law makes the falsifiable prediction $1/2 < I(7) < 1$.

**Keywords:** attention sparsity, top-$k$ retention, knee of a retention curve, hinge regression, scaling law, identifiability, grid resolution, context length.

---

## 1. Introduction

### 1.1 The engineering question

An autoregressive transformer producing token $t$ attends to all $n$ preceding positions. The attention weights at a given head form a probability vector over those positions, typically highly non-uniform: a small number of keys carry most of the mass. Truncating the computation to the top $k$ keys — *top-$k$ attention* — reduces cost from $\Theta(n)$ to $\Theta(k)$ per head per step, at the risk of behavioural drift in the generated continuation.

The engineering quantity of interest is the smallest $k$ at which drift is not detected. We call it the **knee**. It is the memory budget one must actually provision, and its dependence on context length $n$ and model scale $N$ determines whether sparse attention is a fixed-cost optimisation or a losing race against context.

### 1.2 The measurement

Two models were measured — nominal parameter counts $0.5\text{B}$ and $1.5\text{B}$ — at contexts $512, 1024, 2048$, under a fixed deterministic drift criterion (a retention statistic on the continuation, thresholded at a pre-registered level). Indexing contexts by the number $j$ of doublings above the base, so $j = 0, 1, 2$:

$$
\begin{array}{c|ccc}
 & j = 0 & j = 1 & j = 2\\\hline
\text{small } (0.5\text{B}) & 16 & 20 & 24\\
\text{large } (1.5\text{B}) & 16 & 16 & 18
\end{array}
$$

The final entry, $18$, corrects an earlier coarse-grid reading of $20$; the two-point addendum that produced it recorded a failure at $k = 14$ (retention $0.9757$, roughly two standard errors below the bar) and a pass at $k = 18$ (retention $0.9811$).

The informal verdict extracted from the table was *scale halves the context increment*: both curves start at $16$; the small model gains $+4$ keys per context doubling, the large model $+2$. A deployment corollary was appended: a $20$-key budget covers both models to $2048$.

### 1.3 Contributions

This paper is an audit and a theory. We (i) fix exact closed forms for both curves and prove they reproduce the data; (ii) prove three corrections to the informal reading (non-affinity, terminal-versus-average, and the failure of the $20$-key corollary, with the corrected constants); (iii) prove divergence of the two laws with asymptotic ratio $2$; (iv) prove a structural no-go theorem showing no fixed attention profile can generate an additive increment, and identify the family that can, together with a converse; (v) analyse identifiability of hinge slopes from a grid and prove a grid-resolution theorem explaining the historical discrepancy; and (vi) derive a closed-form context-free scale threshold at $4.5$ billion parameters with a bracketed, falsifiable prediction at $7$ billion.

---

## 2. The two measured laws

**Definition 2.1 (Budget laws).** For $j \in \mathbb{N}$ counting context doublings above the base context,
$$K_S(j) := 16 + 4j, \qquad K_L(j) := \max\bigl(16,\; 14 + 2j\bigr).$$
We call $K_S$ the small-model law (affine) and $K_L$ the large-model law (a *hinge*: a floor $16$ competing with the affine demand $14 + 2j$).

**Proposition 2.2 (Data fit).** $\bigl(K_S(0), K_S(1), K_S(2)\bigr) = (16, 20, 24)$ and $\bigl(K_L(0), K_L(1), K_L(2)\bigr) = (16, 16, 18)$.

*Proof.* Direct evaluation. For $K_L$: $14 + 2\cdot 0 = 14 < 16$ and $14 + 2 \cdot 1 = 16 \le 16$, so the floor is attained at $j = 0, 1$; $14 + 2 \cdot 2 = 18 > 16$. $\square$

**Proposition 2.3 (Increments).**
1. $K_S(j+1) = K_S(j) + 4$ for all $j$.
2. $K_L(j+1) = K_L(j) + 2$ for all $j \ge 1$.
3. $K_L(1) = K_L(0)$: the first measured increment is $0$.

*Proof.* (1) is arithmetic. For (2), $j \ge 1$ gives $14 + 2(j+1) \ge 18 > 16$ and $14 + 2j \ge 16$, so both maxima are attained by the affine branch. (3) is Proposition 2.2. $\square$

**Lemma 2.4 (Affine rigidity).** If $f : \mathbb{N} \to \mathbb{N}$ satisfies $f(j+1) = f(j) + d$ for all $j$ and a fixed $d$, then $f(j) = f(0) + dj$.

*Proof.* Induction on $j$; the base case is trivial and the step substitutes the hypothesis. $\square$

Consequently $K_S(j) = K_S(0) + 4j$, i.e. the small-model law is genuinely affine and determined by its base value and one increment.

**Theorem 2.5 (Non-affinity of the large-model law).** There are no $k_0, d \in \mathbb{N}$ with $K_L(j) = k_0 + dj$ for all $j \le 2$.

*Proof.* Such a fit would give $k_0 = 16$ from $j = 0$; then $j = 1$ gives $16 + d = 16$, so $d = 0$; then $j = 2$ gives $16 = 18$, a contradiction. $\square$

Theorem 2.5 is the structural content of the audit. The phrase "the large model has slope $2$" cannot refer to a global slope on the measured window; it can only refer to the *terminal* increment, or to the slope of the affine branch of a hinge.

**Proposition 2.6 (Discrete convexity).** For all $j$, $2K_L(j+1) \le K_L(j) + K_L(j+2)$; that is, the increments of $K_L$ are non-decreasing.

*Proof.* Write $a = 14 + 2j$. The three values are $\max(16,a)$, $\max(16, a+2)$, $\max(16, a+4)$, and convexity of $x \mapsto \max(16, x)$ composed with an arithmetic progression gives the inequality (checked directly by cases on the position of $a$ relative to $16$, $14$, $12$). $\square$

Convexity is what makes a hinge — rather than a straight line or a saturating curve — the right shape: the data show an increment that *rises* from $0$ to $2$, never falls.

---

## 3. Terminal versus average increments

**Theorem 3.1 (The halving is terminal, not average).** With $K_S, K_L$ as above:
1. *(Terminal.)* $K_S(2) - K_S(1) = 4$ and $K_L(2) - K_L(1) = 2$: exactly a halving.
2. *(Window average.)* $K_S(2) - K_S(0) = 2 \cdot 4$ and $K_L(2) - K_L(0) = 2 \cdot 1$: average increments $4$ and $1$, a quartering.
3. *(Disagreement.)* $2\bigl(K_L(2) - K_L(1)\bigr) \ne K_L(2) - K_L(0)$, i.e. $4 \ne 2$.

*Proof.* All four quantities are evaluations of Definition 2.1: $24 - 20 = 4$, $18 - 16 = 2$, $24 - 16 = 8$, $18 - 16 = 2$. Part (3) is $4 \ne 2$. $\square$

The interpretation matters for deployment. Part (3) states that the large-model curve fails the consistency test that an affine curve passes automatically (for an affine curve, twice the terminal increment equals the two-step rise). The failure is a direct measurement of the hinge: averaging across the kink mixes the flat regime with the sloped one and *understates* the asymptotic slope by a factor of two here. Any planning rule that extrapolates from the window average will under-provision.

---

## 4. Uniform key budgets: the corrected deployment constants

**Definition 4.1 (Safety).** A budget $B \in \mathbb{N}$ is *safe at horizon $j$* if $K_S(j) \le B$ and $K_L(j) \le B$.

**Proposition 4.2.** $K_L(2) + 2 \le 20$: the $20$-key budget covers the large model at context $2048$ with margin $2$.

**Theorem 4.3 (Failure of the $20$-key corollary).** $20$ is not safe at horizon $2$.

*Proof.* Safety at horizon $2$ requires $K_S(2) = 24 \le 20$, false. $\square$

**Theorem 4.4 (Least budget at $2048$).** $24$ is the least element of $\{B : B \text{ safe at horizon } 2\}$.

*Proof.* $24$ is safe: $K_S(2) = 24 \le 24$ and $K_L(2) = 18 \le 24$. Any safe $B$ satisfies $B \ge K_S(2) = 24$. $\square$

**Theorem 4.5 (Least budget to horizon $J$).** For every $J \in \mathbb{N}$, the least $B$ that is safe at every horizon $j \le J$ is exactly $16 + 4J$.

*Proof.* Membership: for $j \le J$, $K_S(j) = 16 + 4j \le 16 + 4J$, and $K_L(j) = \max(16, 14+2j) \le \max(16, 14+2J) \le 16 + 4J$. Minimality: safety at $j = J$ forces $B \ge K_S(J) = 16 + 4J$. $\square$

Thus the uniform budget is dictated entirely by the *small* model — the more sparsity-hostile one — and grows linearly in the number of doublings. The corrected deployment statement is: *at $2048$ provision $24$ keys; at $4096$ provision $28$; there is no context-free shared budget.*

**Theorem 4.6 (Gap and divergence).** For $j \ge 1$, $K_L(j) = 14 + 2j$ and hence $K_S(j) - K_L(j) = 2j + 2$. Consequently, for every $B$ there exists $j$ with $K_S(j) - K_L(j) > B$; the key gap is unbounded.

*Proof.* The first claim is Proposition 2.3(2) with the base case $K_L(1) = 16 = 14 + 2$. Then $(16 + 4j) - (14+2j) = 2j + 2$. Taking $j = B + 2$ gives gap $2B + 6 > B$. $\square$

**Theorem 4.7 (Asymptotic budget ratio).** $\displaystyle\lim_{j \to \infty} \frac{K_S(j)}{K_L(j)} = 2.$

*Proof sketch.* For $j \ge 1$ the ratio equals $\dfrac{16+4j}{14+2j} = 2 - \dfrac{12}{14+2j}$, since $2(14+2j) - (16+4j) = 12$. The subtracted term tends to $0$ because its denominator tends to $\infty$. $\square$

Note the timescale: the asymptotic factor $2$ is invisible at the measured horizon, where the ratio is only $24/18 = 4/3$. The halving of the *increment* becomes a doubling of the *level* only in the limit.

---

## 5. Structural theory: what can generate an additive increment?

We now leave the fitted curves and ask a mechanistic question: which attention profiles produce a knee that grows by a fixed number of keys per context doubling?

### 5.1 Retention curves and knees

**Definition 5.1.** For a sorted attention profile $p : \mathbb{N} \to \mathbb{R}$ (with $p_i$ the $i$-th largest weight), the *retained mass* is $R_p(k) := \sum_{i<k} p_i$, and for a threshold $\tau$ the *knee* is
$$\kappa_p(\tau) := \inf\{k \in \mathbb{N} : \tau \le R_p(k)\}.$$

Elementary properties, all immediate from the definition: $R_p(0) = 0$; $R_p(k+1) = R_p(k) + p_k$; $R_p$ is monotone when $p \ge 0$; $\tau \le R_p(k)$ implies $\kappa_p(\tau) \le k$; if the set is non-empty then $\tau \le R_p(\kappa_p(\tau))$; $k < \kappa_p(\tau)$ implies $R_p(k) < \tau$; $\kappa_p$ is monotone in $\tau$; and if $R_p \le R_q$ pointwise then $\kappa_q(\tau) \le \kappa_p(\tau)$ (a uniformly heavier head needs fewer keys).

### 5.2 The truncated geometric profile

**Definition 5.2.** On a context of $n$ keys, the *truncated geometric profile* with ratio $r \in (0,1)$ is
$$g_{r,n}(i) := \frac{(1-r)\,r^i}{1 - r^n}.$$

**Proposition 5.3.** For $r \ne 1$, $R_{g_{r,n}}(k) = \dfrac{1 - r^k}{1 - r^n}$. In particular $R_{g_{r,n}}(n) = 1$: the profile is a probability vector on $\{0,\dots,n-1\}$, and it is non-negative for $0 < r < 1$.

*Proof.* Sum the geometric series $\sum_{i<k} r^i = (r^k - 1)/(r-1)$ and simplify against the normaliser. $\square$

**Lemma 5.4 (Uniform retention bound).** Let $0 < r < 1$, $n \ge 1$, and suppose $r^k \le 1 - \tau$. Then $\tau \le R_{g_{r,n}}(k)$ — *whatever the context length $n$*.

*Proof sketch.* By Proposition 5.3 the claim is $\tau(1 - r^n) \le 1 - r^k$. Since $r^n \in (0,1)$, the left side is at most $\tau$ when $\tau \ge 0$ (and is negative otherwise), while $1 - r^k \ge \tau$ is the hypothesis. $\square$

**Lemma 5.5 (Explicit budget).** For $0 < r < 1$ and $\tau < 1$, taking $K := \bigl\lceil \log(1-\tau)/\log r \bigr\rceil$ gives $r^K \le 1 - \tau$.

*Proof sketch.* $\log r < 0$, so multiplying the ceiling inequality $\log(1-\tau)/\log r \le K$ by $\log r$ reverses it: $K \log r \le \log(1-\tau)$, i.e. $\log(r^K) \le \log(1-\tau)$, and $\log$ is increasing on the positives. $\square$

**Theorem 5.6 (Context-uniform bound).** For fixed $0 < r < 1$ and $\tau < 1$ there is $K \in \mathbb{N}$ with $\kappa_{g_{r,n}}(\tau) \le K$ for all $n \ge 1$; explicitly $K = \lceil \log(1-\tau)/\log r\rceil$.

**Proposition 5.7 (Monotonicity in context).** For $0 < r < 1$ and $1 \le m \le n$, $R_{g_{r,n}}(k) \le R_{g_{r,m}}(k)$ for all $k$, and hence $\kappa_{g_{r,m}}(\tau) \le \kappa_{g_{r,n}}(\tau)$.

*Proof sketch.* Lengthening the context enlarges the normaliser $1 - r^n$ while leaving the numerator $1 - r^k$ unchanged, so retention at fixed $k$ decreases; a uniformly lighter head needs at least as many keys. $\square$

**Lemma 5.8.** A monotone, bounded sequence $K : \mathbb{N} \to \mathbb{N}$ is eventually constant.

*Proof.* The range is a non-empty bounded set of naturals, so it has a maximum, attained at some $j_0$; monotonicity forces $K(j) = K(j_0)$ for $j \ge j_0$. $\square$

**Theorem 5.9 (Increments of a fixed geometric profile die).** For fixed $0 < r < 1$, $\tau < 1$, the sequence $j \mapsto \kappa_{g_{r,2^j}}(\tau)$ is eventually constant.

*Proof.* Monotone by Proposition 5.7, bounded by Theorem 5.6, then Lemma 5.8. $\square$

**Corollary 5.10 (No fixed geometric profile fits).** There are no $r \in (0,1)$ and $\tau < 1$ with $\kappa_{g_{r,2^j}}(\tau) = 16 + 4j$ for all $j$.

*Proof.* Let $K$ bound the knee uniformly. Then at $j = K$ we would need $16 + 4K \le K$, impossible. $\square$

### 5.3 The obstruction is summability, not geometry

**Definition 5.11.** For a fixed profile $p$ and context $n$, the *renormalised profile* is $\tilde p_n(i) := p_i / R_p(n)$. This is the general form of the geometric construction: the only way a context length can enter a *fixed* profile is through the normaliser.

**Theorem 5.12 (General no-go).** Let $p \ge 0$ with $R_p(n) \to S$ as $n \to \infty$ for some $S > 0$, and let $\tau < 1$. Then there is $K$ with $\kappa_{\tilde p_n}(\tau) \le K$ for every $n$ with $R_p(n) > 0$.

*Proof sketch.* $R_p$ is monotone with limit $S$, so $R_p(n) \le S$ for all $n$. Since $\tau < 1$ and $S > 0$ we have $\tau S < S$, so by convergence there is $K$ with $\tau S < R_p(K)$. Then for any $n$, $\tau R_p(n) \le \tau S < R_p(K)$ when $\tau \ge 0$ (and trivially when $\tau < 0$), i.e. $\tau \le R_p(K)/R_p(n) = R_{\tilde p_n}(K)$, giving $\kappa_{\tilde p_n}(\tau) \le K$. $\square$

**Corollary 5.13.** Under the hypotheses of Theorem 5.12 (with $R_p(1) > 0$), it is impossible that $\kappa_{\tilde p_{2^j}}(\tau) = 16 + 4j$ for all $j$.

The message is sharp: **a persistent additive key increment is not a property of any distribution.** It is a property of a *family* of distributions indexed by context, whose concentration degrades as the context grows. Any mechanistic explanation of the measurement must supply such a family.

### 5.4 The family that works

**Definition 5.14.** For an exponential attention tail with decay rate $\lambda > 0$ and tail budget $\delta \in (0,1)$, the *continuous key requirement* is
$$\kappa_c(\lambda, \delta) := \frac{\log(1/\delta)}{\lambda}.$$

**Proposition 5.15 (Exactness).** For $\lambda > 0$, $\delta > 0$ and real $k$: $e^{-\lambda k} \le \delta \iff \kappa_c(\lambda,\delta) \le k$.

*Proof.* Take logarithms: $-\lambda k \le \log \delta \iff k \ge -\log\delta/\lambda = \log(1/\delta)/\lambda$. $\square$

This is an equivalence, so $\kappa_c$ is the knee of the exponential model, not an approximation to it. Immediately, $\kappa_c(\lambda/2, \delta) = 2\kappa_c(\lambda,\delta)$: halving the decay rate doubles the key requirement.

**Definition 5.16 (Degrading rate).** After $j$ context doublings, $\lambda_j := \dfrac{\lambda_0}{j+1}$.

Since $j$ counts doublings, $j + 1$ is proportional to $\log(\text{context})$; the hypothesis is that attention peakedness is *inversely proportional to log-context*.

**Theorem 5.17 (The additive law, derived).** For $\lambda_0 \ne 0$,
$$\kappa_c(\lambda_j, \delta) = (j+1)\,\frac{\log(1/\delta)}{\lambda_0},$$
which is exactly affine in $j$, with per-doubling increment
$$\kappa_c(\lambda_{j+1},\delta) - \kappa_c(\lambda_j, \delta) = \frac{\log(1/\delta)}{\lambda_0}.$$

*Proof.* Substitute Definition 5.16 into Definition 5.14 and simplify; the difference telescopes. $\square$

**Theorem 5.18 (Scale halves the increment).** Replacing $\lambda_0$ by $2\lambda_0$ halves the per-doubling increment:
$$\kappa_c(\tfrac{2\lambda_0}{j+2},\delta) - \kappa_c(\tfrac{2\lambda_0}{j+1},\delta) = \tfrac12\Bigl(\kappa_c(\tfrac{\lambda_0}{j+2},\delta) - \kappa_c(\tfrac{\lambda_0}{j+1},\delta)\Bigr).$$

*Proof.* Both sides are constants by Theorem 5.17: $\log(1/\delta)/(2\lambda_0)$ and $\tfrac12 \log(1/\delta)/\lambda_0$. $\square$

This is the verdict *derived* rather than fitted: a model whose attention is uniformly twice as peaked pays exactly half the per-doubling key price.

**Theorem 5.19 (Converse: an additive law forces the $1/(j+1)$ rate).** Let $s > 0$ and let $(\lambda_j)$ be non-zero rates with $\kappa_c(\lambda_j, \delta) = s(j+1)$ for all $j$. Then
$$\lambda_j = \frac{\log(1/\delta)/s}{j+1}.$$

*Proof.* $\log(1/\delta)/\lambda_j = s(j+1)$ rearranges directly. $\square$

Theorems 5.17 and 5.19 together say: *"additive keys per context doubling" and "decay rate inversely proportional to log-context" are the same hypothesis.*

**Theorem 5.20 (Calibration).** Fix $\delta = e^{-4}$, so $\log(1/\delta) = 4$. Then:
1. with $\lambda_0 = 1$, the derived increment equals $K_S(j+1) - K_S(j) = 4$ for all $j$;
2. with $\lambda_0 = 2$, the derived increment equals $K_L(j+1) - K_L(j) = 2$ for all $j \ge 1$;
3. the two base rates stand in ratio $2 : 1$.

*Proof.* By Theorem 5.17 the increments are $4/\lambda_0$; substitute and compare with Proposition 2.3. $\square$

The calibration converts the empirical verdict into a statement about the models: *the larger model's attention is exactly twice as peaked per unit of log-context.*

---

## 6. Identifiability of the hinge

Theorem 2.5 forces a hinge; but which hinge?

**Definition 6.1.** $H_{f,b,s}(j) := \max(f,\; b + s j)$, with floor $f$, base $b$, slope $s$, all in $\mathbb{N}$. The large-model law is $K_L = H_{16,14,2}$.

**Proposition 6.2 (Convexity).** Every hinge is discretely convex: $2H_{f,b,s}(j+1) \le H_{f,b,s}(j) + H_{f,b,s}(j+2)$.

**Definition 6.3.** Say $(b,s)$ *fits* if $H_{16,b,s}$ passes through $16, 16, 18$ at $j = 0,1,2$.

**Theorem 6.4 (Characterisation of fits).** $(b,s)$ fits $\iff$ $b + 2s = 18$ and $b + s \le 16$.

*Proof.* $H(0) = \max(16, b) = 16 \iff b \le 16$; $H(1) = \max(16, b+s) = 16 \iff b + s \le 16$ (which implies $b \le 16$); $H(2) = \max(16, b + 2s) = 18 \iff b + 2s = 18$. $\square$

**Corollary 6.5 (The slope is only bounded).** Every fit has $2 \le s \le 9$, and the base is determined by the slope. In particular $(14,2)$ fits — the parsimonious reading — and so does $(12,3)$.

*Proof.* From $b + 2s = 18$ and $b + s \le 16$ we get $s \ge 2$; from $b \ge 0$ we get $s \le 9$. If $(b,s)$ and $(b',s)$ both fit then $b = 18 - 2s = b'$. $\square$

So the advertised slope $2$ is **a lower bound implied by the data, not a measurement**. Structurally: a hinge has three parameters, but a grid whose early points lie below the kink contributes only *inequalities* there, and inequalities bound a slope from below without pinning it.

**Theorem 6.6 (The discriminating experiment).** At $j = 3$ (context $4096$), $H_{16,14,2}(3) = 20$ while $H_{16,12,3}(3) = 21$; the two admissible fits disagree.

Thus a single measurement one octave beyond the current grid upgrades the lower bound $s \ge 2$ into an identification — the cheapest decisive experiment available.

---

## 7. Grid resolution: why a coarse sweep over-reads

**Definition 7.1.** The knee *measured on the grid of multiples of $d$* is
$$\kappa^{(d)}_p(\tau) := \inf\{k : d \mid k,\ \tau \le R_p(k)\}.$$

**Lemma 7.2.** For $d \ge 1$ and any $n$, there is a multiple $k$ of $d$ with $n \le k < n + d$.

**Theorem 7.3 (Resolution bound).** For $p \ge 0$, $d \ge 1$, and $\tau$ attainable,
$$\kappa_p(\tau) \;\le\; \kappa^{(d)}_p(\tau) \;<\; \kappa_p(\tau) + d.$$

*Proof.* The lower bound holds because any grid witness is a witness. For the upper bound, apply Lemma 7.2 with $n = \kappa_p(\tau)$ to obtain a multiple $k$ of $d$ with $\kappa_p(\tau) \le k < \kappa_p(\tau) + d$; monotonicity of $R_p$ gives $\tau \le R_p(k)$, so $k$ is admissible and $\kappa^{(d)}_p(\tau) \le k$. $\square$

**Theorem 7.4 (The historical discrepancy, exactly).** For the flat profile $p \equiv 1$ (so $R_p(k) = k$) and $\tau = 18$, the true knee is $18$ while the knee measured on the spacing-$4$ grid $\{16,20,24,\dots\}$ is $20$.

*Proof.* $\{k : 18 \le k\}$ has infimum $18$; $\{k : 4 \mid k,\ 18 \le k\}$ has infimum $20$. $\square$

The over-read is $2 < 4$, inside the guaranteed resolution. This reproduces exactly the earlier coarse reading of $20$ for the large model at context $2048$, corrected to $18$ by the finer sweep: the two experiments do not conflict, they differ in resolution, and the discrepancy is bounded a priori by the grid spacing.

---

## 8. The scale exponent and a context-free threshold

Theorem 5.20 attaches a peakedness $\lambda_0$ to each model: $\lambda_0 = 1$ at $N = 0.5$ and $\lambda_0 = 2$ at $N = 1.5$ (parameter counts in billions). The simplest interpolation is a power law.

**Definition 8.1.** $\theta := \dfrac{\log 2}{\log 3}$, $\quad \lambda_0(N) := (2N)^{\theta}$, $\quad I(N) := 4\,(2N)^{-\theta}.$

The normalisation $2N$ makes $\lambda_0(0.5) = 1$; the requirement $\lambda_0(1.5) = 2$ forces $3^\theta = 2$, hence the stated $\theta \approx 0.63093$. The increment law $I$ is exactly the cycle-1 increment $\log(1/\delta)/\lambda_0$ at $\delta = e^{-4}$.

**Proposition 8.2 (Calibration).** $I(0.5) = 4$ and $I(1.5) = 2$.

*Proof.* $I(0.5) = 4 \cdot 1^{-\theta} = 4$; $I(1.5) = 4 \cdot 3^{-\theta} = 4/2 = 2$ by $3^\theta = 2$. $\square$

**Proposition 8.3 (Monotonicity).** $I$ is strictly decreasing on $(0,\infty)$.

*Proof.* $x \mapsto x^{-\theta}$ is strictly decreasing on the positives since $\theta > 0$. $\square$

**Theorem 8.4 (Closed-form threshold).** $I(4.5) = 1$, and for $N > 0$,
$$I(N) < 1 \iff N > 4.5 .$$

*Proof.* $2 \cdot 4.5 = 9 = 3^2$, and $(3^2)^\theta = (3^\theta)^2 = 4$, so $I(4.5) = 4 \cdot 4^{-1} = 1$. The equivalence follows from strict monotonicity (Proposition 8.3). $\square$

**Proposition 8.5.** $I(13.5) = 1/2$, since $2 \cdot 13.5 = 27 = 3^3$ and $(3^3)^\theta = 8$.

**Theorem 8.6 (Bracketed $7$B prediction).** $\tfrac12 < I(7) < 1$, and $I(7) < I(1.5)$.

*Proof.* $1.5 < 7 < 13.5$ with $I$ strictly decreasing, plus Theorem 8.4 and Proposition 8.5. $\square$

**Interpretation.** Above roughly $4.5$ billion parameters the predicted key increment falls below one key per context doubling: on an integer key grid, the attention budget becomes *effectively context-free*. For a $7$B model the prediction is sharp and falsifiable: **the knee should move by $0$ or $1$ key between contexts $2048$ and $4096$.** A measured move of $\ge 2$ keys refutes the power-law calibration outright.

---

## 9. Algorithms

Three procedures make the theory operational.

**(A) Knee extraction by bisection.** Retention $R_p$ is monotone in $k$, so the knee is found by binary search over $[0, n]$: $O(\log n)$ evaluations of the drift criterion, versus $O(n/d)$ for a linear grid sweep of spacing $d$. Theorem 7.3 quantifies the cost of the sweep: it over-reads by up to $d-1$ keys.

**(B) Hinge fitting with certified slope bounds.** Given measured pairs $(j, k_j)$ and a floor $f$, enumerate admissible $(b, s)$ by solving the linear system implied by the points above the kink and the inequalities implied by the points at the floor. The output is an interval of slopes, not a point estimate; Corollary 6.5 is the instance $[2,9]$. The procedure runs in $O(m \cdot S)$ for $m$ points and a slope search range $S$, or in closed form for $m = 3$.

**(C) Budget planning.** Given the two laws, the least uniform budget to horizon $J$ is $\max_{j \le J}\max(K_S(j), K_L(j)) = 16 + 4J$ by Theorem 4.5 — a constant-time formula, obtained by observing that the maximum is attained at $j = J$ by the dominating affine law.

---

## 10. Discussion

**What survived.** The additive-per-doubling picture survives, in a precise form: the small-model curve is genuinely affine; the large-model curve is a hinge; and the halving $4 \to 2$ is a correct statement about the *terminal* increment. The mechanism is identified and is not a fit: an exponential tail whose rate degrades inversely with log-context produces an exactly affine key requirement, and doubling peakedness exactly halves the increment (Theorems 5.17–5.19). The measured pair $(+4,+2)$ then says the larger model's attention is exactly twice as peaked.

**What failed.** Two informal claims did not survive. The deployment corollary "a 20-key budget covers both models to 2048" is false (Theorem 4.3); the correct constant is $24$ (Theorem 4.4), and asymptotically no shared budget exists at all (Theorem 4.6). And "the large model's slope is 2" over-claims: the data force only $s \ge 2$ (Corollary 6.5), with $(b,s) = (12,3)$ an equally admissible fit.

**What needed a different definition.** The empirical law cannot be a property of a single attention profile at all: for any fixed profile of finite mass, renormalised to the context, the knee is bounded uniformly in context and hence eventually flat (Theorems 5.6, 5.9, 5.12). The right object is a *family* whose decay degrades like $1/\log(\text{context})$ — and that hypothesis is equivalent to the additive law, in both directions.

**Threats to validity.** The knee is defined relative to a drift criterion and a threshold; different criteria shift the level and, through $\log(1/\delta)$, the increment, though not the *ratio* of increments between models, which is the quantity the halving law concerns. The three-point grid is short: Corollary 6.5 shows how short. The power-law interpolation of $\lambda_0$ in $N$ is the weakest link — two cells determine one exponent with zero degrees of freedom, so the $4.5$B threshold is a *prediction*, not a measurement, and Theorem 8.6 is stated precisely so that it can be killed by one experiment.

---

## 11. Future directions

**1. The $4.5$B context-free attention threshold.** Calibrating peakedness as $\lambda_0(N) = (2N)^\theta$ is forced by the two measured cells to have $\theta = \log 2/\log 3$, and this exponent converts the empirical halving into an exact closed-form crossing at $N = 4.5$B, where the predicted increment is exactly one key per doubling. The $7$B cell is the natural next measurement, and the prediction $1/2 < I(7) < 1$ is falsified by a single observation of a $\ge 2$-key move from $2048$ to $4096$.

**2. Slope identifiability of hinge budget laws.** A hinge has three parameters, but a flat measured prefix supplies only inequalities, so a grid that starts below the kink cannot identify the slope — only bound it below. The two admissible fits of the current large-model data separate at exactly one point ($20$ versus $21$ keys at context $4096$), so one extra octave upgrades a bound into an identification. Conjecture to settle: for a hinge with floor $f$, the slope is identifiable from a grid if and only if the grid contains at least two points strictly above the kink.

**3. Increments at $4096$ and beyond.** Extending both models one octave tests affinity of the small law, lift-off of the large law, and the divergence prediction $K_S - K_L = 2j+2$ simultaneously.

**4. Domain-jump corpora.** The knee is measured on a fixed text distribution. A corpus shift changes the effective $\lambda_0$; whether it changes the *ratio* between model scales is the question that separates a property of the models from a property of the data.

**5. Direct measurement of the decay family.** Theorem 5.19 makes the additive law equivalent to $\lambda_j \propto 1/(j+1)$. Measuring attention-tail decay rates directly across contexts is therefore an independent test of the same law, at much lower cost than a full knee sweep.

---

## 12. Conclusion

Six numbers support one durable slogan and three corrections. The durable part: attention key budgets grow additively with log-context, and scale halves the terminal increment — because peakedness scales up and increments scale inversely with peakedness. The corrections: the larger model's curve is a hinge, not a line, so averaged and terminal readings of "the increment" differ by a factor of two; the shared $20$-key budget does not exist, the correct figure at $2048$ being $24$ and growing as $16 + 4J$; and the "slope $2$" is a lower bound that one measurement at context $4096$ would turn into a fact. Underneath sits a clean structural dichotomy: no fixed attention distribution can ever produce a persistent additive increment, so any such measurement is evidence about a *family* of distributions degrading with context — precisely the family whose decay rate is inversely proportional to the logarithm of the context.
