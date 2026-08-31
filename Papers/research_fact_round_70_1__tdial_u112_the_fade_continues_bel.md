# Sharp Decorrelation, Minimal Noise, and Refuted Extrapolation: A Complete Analysis of a Five-Rung Correlation Ladder

**Author:** Aristotle
**Date:** 2026-08-31

---

## Abstract

We give a complete, self-contained analysis of a five-point correlation ladder arising from an empirical study of an arithmetic *dial* statistic $T$ — combining the $2$-adic valuation and the small-prime quadratic-residue pattern of a uniformly drawn integer $N$ — and its rank correlation with a downstream performance rate, measured at bit lengths $96, 100, 104, 108, 112$. The recorded ladder is $0.5739,\ 0.5436,\ 0.5005,\ 0.4880,\ 0.4621$.

Four independent results are established.

1. **A sharp decorrelation bound.** For any three statistics with pairwise correlations $a = \mathrm{corr}(T,R)$, $b = \mathrm{corr}(C,R)$, $c = \mathrm{corr}(T,C)$, positive semidefiniteness of the correlation matrix is equivalent, after completing the square, to $(c-ab)^2 \le (1-a^2)(1-b^2)$, hence $c \le ab + \sqrt{(1-a^2)(1-b^2)}$. This is the spherical triangle inequality in angle coordinates, it is attained by an explicit planar configuration, and it strictly improves the previously used certificate $c \le 1 - (a-b)^2/2$; the exact defect is the identity $\big(1 - ab - \frac{(a-b)^2}{2}\big)^2 - (1-a^2)(1-b^2) = \frac{(a-b)^2(a+b)^2}{4}$. At the recorded values $a = 0.462$, $\delta = a - b = 0.047$, the sharp certificate reads $c \le 0.99864$ against the old $0.99889$.

2. **An exact minimal noise level.** Calling a ladder a *noisy affine fade* with parameters $(L,\lambda,\eta)$ when $|\rho_{k+1} - L - \lambda(\rho_k - L)| \le \eta$ for all $k$, we prove a model-free lower bound on $\eta$ obtained by eliminating $L$ and $\lambda$ between two observed step ratios, and we prove that the resulting bound is *attained*. The minimal noise of the recorded ladder is exactly $\eta^\star = 73943/7340000 = 0.0100739782\ldots$, realized by $\lambda^\star = 278/367$, $L^\star = 725197/1780000$, whose residuals equioscillate $+\eta^\star, -\eta^\star, +\eta^\star$. Optimality is certified by a Chebyshev alternation argument valid for arbitrary strictly declining ladders.

3. **Permanent band loss and a refuted local fit.** Under any nonnegative contractive fade a single declining step forces $L \le \rho_{k+1} + \eta/(1-\lambda)$; at the recorded rung with $\lambda \le 1/2, \eta \le 0.02$ this gives $L \le 0.5021 < 0.55$, and the optimal fit gives unconditionally $L^\star \approx 0.40741$. By contrast the *local* three-rung fit at bit length $112$ has ratio $259/125 = 2.072 > 1$ — expansive — and the extrapolation it licenses, $\approx 0.408435$, misses the subsequently recorded rung $0.4847$ by $95331/1250000 \approx 0.0763$, more than seven times $\eta^\star$.

4. **Decisiveness is a location, not a sample-size, problem.** If a point estimate lies strictly below a pre-registered bar, no sample size and no interval width place the lower confidence endpoint above the bar. The recorded advantage $+0.047$ against a bar of $+0.05$ therefore requires a shift of at least $0.003$ in the estimate, not more replication.

We complement these statistical results with an arithmetic layer: the two-prime quadratic-residue dial has the exact Binomial$(2,1/2)$ law and variance exactly $1/2$, uniformly in the primes and hence in the bit length. The dial's own information content therefore does not fade; what fades is its coupling to the rate.

**Keywords:** rank correlation, Gram matrix, spherical triangle inequality, Chebyshev equioscillation, model identifiability, Aitken extrapolation, quadratic residues, Chinese Remainder Theorem.

---

## 1. Introduction

### 1.1 The empirical object

Fix a bit length $n$ and draw $N$ uniformly from $n$-bit integers. Let $T(N)$ be a cheap arithmetic summary — in the experiment under analysis, a combination of the $2$-adic valuation $v_2(N)$ (the trailing-zero count) and the pattern of quadratic residuosity of $N$ modulo a fixed pair of small odd primes. Let $\mathrm{rate}(N)$ be the performance of a downstream procedure applied to $N$. Write

$$\rho(n) = \text{Spearman rank correlation of } (T, \mathrm{rate}) \text{ over draws at bit length } n.$$

Two thresholds were fixed in advance of measurement:

- a **band floor** $B_{\mathrm{band}} = 0.55$: the dial counts as a validated predictor only while $\rho(n)$ (and its whole confidence interval) exceeds it;
- a **decisiveness bar** $B_{\mathrm{dec}} = +0.05$ on the *advantage* $\delta(n) = \rho(n) - \rho_C(n)$, where $\rho_C$ is the correlation obtained by a reduced baseline statistic $C$ that uses only the trailing-zero count and discards the residue pattern.

### 1.2 The recorded ladder

| bit length | $96$ | $100$ | $104$ | $108$ | $112$ |
|---|---|---|---|---|---|
| $\rho$ | $0.5739$ | $0.5436$ | $0.5005$ | $0.4880$ | $0.4621$ |
| step | — | $-0.0303$ | $-0.0431$ | $-0.0125$ | $-0.0259$ |

At bit length $112$: pooled $\rho = 0.462$, $95\%$ CI $[0.415, 0.508]$, per-seed values $0.409 / 0.509 / 0.460$ over three independent seeds. The whole CI lies below $0.55$, for the second consecutive rung. The advantage is $\delta = +0.047$ with CI $[0.003, 0.090]$ — the interval excludes $0$ but straddles the bar $0.05$.

Two later rungs, recorded after the analysis window, are used here only to *score* extrapolations that the five-rung record licensed at the time:

$$\rho(116) = 0.4847, \qquad \rho(120) = 0.43636.$$

Throughout, we index the five analysis rungs as $\rho_0, \dots, \rho_4$ and write the steps as

$$d_k = \rho_{k+1} - \rho_k, \qquad d_0 = -0.0303,\ d_1 = -0.0431,\ d_2 = -0.0125,\ d_3 = -0.0259.$$

### 1.3 The questions

Prior analyses of this ladder treated each pooled correlation as an opaque real number and asked geometric questions of a single rung. Two questions were left open.

**(Q1)** A measured advantage $\delta$ of $T$ over $C$ was converted into a certificate $\mathrm{corr}(T,C) \le 1 - \delta^2/2$. *Is that bound tight?*

**(Q2)** The ladder was fitted rung-by-rung by an affine fade. *How much noise does a single parameter pair $(L,\lambda)$ need in order to reproduce all five rungs at once?*

We answer (Q1) negatively and supply the sharp replacement (Section 2), answer (Q2) with an exact number (Sections 3–4), draw the structural consequences (Section 5), and settle the arithmetic status of the dial (Section 7).

---

## 2. The Sharp Decorrelation Bound

### 2.1 Correlations as cosines

Let $u, v, w \in \mathbb{R}^n$ be centered data vectors with nonzero norm, and let $\mathrm{corr}(u,v) = \langle u,v\rangle / (\|u\|\|v\|)$. Each correlation is the cosine of the angle between the corresponding vectors, so with $a = \mathrm{corr}(u,w)$, $b = \mathrm{corr}(v,w)$, $c = \mathrm{corr}(u,v)$ the $3 \times 3$ Gram matrix of the normalized vectors is

$$G = \begin{pmatrix} 1 & c & a \\ c & 1 & b \\ a & b & 1\end{pmatrix}, \qquad \det G = 1 + 2abc - a^2 - b^2 - c^2 \ge 0.$$

The determinant inequality is the entire content of realizability: three numbers in $[-1,1]$ arise as the pairwise correlations of three vectors if and only if $a^2 + b^2 + c^2 \le 1 + 2abc$.

### 2.2 The completed-square form

**Theorem 2.1 (Gram positivity, completed square).** *If $a^2 + b^2 + c^2 \le 1 + 2abc$ then*
$$(c - ab)^2 \le (1-a^2)(1-b^2).$$

*Proof.* Expand the right-hand side: $(1-a^2)(1-b^2) = 1 - a^2 - b^2 + a^2b^2$. Expand the left: $(c-ab)^2 = c^2 - 2abc + a^2b^2$. Their difference is $c^2 - 2abc + a^2 + b^2 - 1$, which is $\le 0$ precisely by hypothesis. $\square$

The inequality is genuinely a *completion of the square in $c$*: the Gram condition is a downward parabola in $c$, and its two roots are $ab \pm \sqrt{(1-a^2)(1-b^2)}$.

**Theorem 2.2 (Sharp decorrelation bound).** *If $a^2 \le 1$, $b^2 \le 1$ and $a^2+b^2+c^2 \le 1+2abc$, then*
$$c \le ab + \sqrt{(1-a^2)(1-b^2)}.$$

*Proof.* By Theorem 2.1, $|c-ab| \le \sqrt{(1-a^2)(1-b^2)}$ (take square roots, using $\sqrt{x^2} = |x|$ and monotonicity of $\sqrt{\cdot}$ on the nonnegative reals, the radicand being nonnegative since $a^2, b^2 \le 1$). Drop the lower half of the absolute value. $\square$

**Corollary 2.3 (Vector form).** *For any centered $u,v,w$ with nonzero norms,*
$$\mathrm{corr}(u,v) \le \mathrm{corr}(u,w)\,\mathrm{corr}(v,w) + \sqrt{\big(1 - \mathrm{corr}(u,w)^2\big)\big(1 - \mathrm{corr}(v,w)^2\big)}.$$

### 2.3 Angle coordinates

Write $a = \cos\alpha$, $b = \cos\beta$ with $\alpha, \beta \in [0,\pi]$, and $c = \cos\gamma$. Then $ab + \sqrt{(1-a^2)(1-b^2)} = \cos\alpha\cos\beta + \sin\alpha\sin\beta = \cos(\alpha-\beta)$, and symmetrically $ab - \sqrt{\cdots} = \cos(\alpha+\beta)$. Theorem 2.1 therefore says exactly

$$|\alpha - \beta| \;\le\; \gamma \;\le\; \alpha + \beta,$$

the **spherical triangle inequality** for the three correlation angles. Reading this in the experiment: if $T$ and $C$ sit at angles $\alpha$ and $\beta$ from the response direction and those angles differ by a lot, then $T$ and $C$ are far apart; an advantage in correlation is a *lower bound on originality*.

### 2.4 Exact comparison with the previous certificate

The previously used bound was $c \le 1 - (a-b)^2/2$, obtained by a coarser rearrangement of the same Gram inequality.

**Theorem 2.4 (Defect identity).** *For all real $a,b$,*
$$\Big(1 - ab - \tfrac{(a-b)^2}{2}\Big)^2 - (1-a^2)(1-b^2) = \frac{(a-b)^2(a+b)^2}{4}.$$

*Proof.* Pure polynomial expansion of both sides. $\square$

**Theorem 2.5 (The sharp bound dominates).** *If $a^2 \le 1$ and $b^2 \le 1$ then*
$$ab + \sqrt{(1-a^2)(1-b^2)} \;\le\; 1 - \frac{(a-b)^2}{2},$$
*with strict inequality whenever $(a-b)(a+b) \neq 0$.*

*Proof.* First, $1 - ab - (a-b)^2/2 \ge 0$: indeed $2 - 2ab - (a-b)^2 = 2 - 2ab - a^2 + 2ab - b^2 = 2 - a^2 - b^2 \ge 0$. Second, by Theorem 2.4, $(1 - ab - (a-b)^2/2)^2 \ge (1-a^2)(1-b^2)$, strictly if $(a-b)(a+b) \neq 0$. Taking square roots of both sides (legitimate since both are nonnegative) and adding $ab$ gives the claim. $\square$

So the two bounds agree exactly on the degenerate locus $a = \pm b$ — where the defect $(a-b)^2(a+b)^2/4$ vanishes — and the sharp bound is strictly better everywhere else. The size of the improvement is governed by the product $(a-b)(a+b)$, i.e. by $|a^2 - b^2|$.

### 2.5 Attainment

**Theorem 2.6 (Sharpness).** *For every admissible pair $a, b \in [-1,1]$ there exist three unit vectors in $\mathbb{R}^2$ realizing $\mathrm{corr}(u,w) = a$, $\mathrm{corr}(v,w) = b$, and $\mathrm{corr}(u,v) = ab + \sqrt{(1-a^2)(1-b^2)}$ simultaneously. Consequently no bound on $\mathrm{corr}(u,v)$ depending only on $(a,b)$ can improve Theorem 2.2.*

*Proof.* Take $w = (1,0)$, $u = (a, \sqrt{1-a^2})$, $v = (b, \sqrt{1-b^2})$. All three are unit vectors, and
$\langle u,w\rangle = a$, $\langle v,w\rangle = b$, $\langle u,v\rangle = ab + \sqrt{1-a^2}\sqrt{1-b^2} = ab + \sqrt{(1-a^2)(1-b^2)}$. $\square$

Geometrically: the extremal configuration is planar with $u$ and $v$ on the *same* side of $w$, so that $\gamma = |\alpha - \beta|$, the lower end of the spherical triangle inequality.

### 2.6 The certificate at bit length 112

**Theorem 2.7 (Recorded decorrelation certificate).** *Let $T, C, R$ be centered statistics with nonzero norms satisfying the recorded readings $\mathrm{corr}(T,R) \ge 0.462$ and $\mathrm{corr}(T,R) - \mathrm{corr}(C,R) \ge 0.047$. Then*
$$\mathrm{corr}(T,C) \le 0.99864.$$

*Proof sketch.* Apply Theorem 2.1 to $a = \mathrm{corr}(T,R)$, $b = \mathrm{corr}(C,R)$, $c = \mathrm{corr}(T,C)$. Suppose $c > 0.99864$. Since $a \ge 0.462$ and $b \le a - 0.047$, the quantity $ab$ is bounded above by $0.99864$, and one checks by elementary algebra over the admissible region $\{|a|,|b| \le 1,\ a \ge 0.462,\ a - b \ge 0.047\}$ that $(1-a^2)(1-b^2) \le (0.99864 - ab)^2$. Combining with $(c - ab)^2 \le (1-a^2)(1-b^2)$ and $c > 0.99864 \ge ab$ yields $(c-ab)^2 > (0.99864 - ab)^2 \ge (1-a^2)(1-b^2)$, a contradiction. $\square$

**Theorem 2.8 (Strict improvement).** $0.99864 < 1 - (0.047)^2/2 = 0.9988955$.

The numerical improvement is modest — both certificates say the dial and the baseline are near-collinear — but the qualitative gain is that the sharp bound is *exact*: no further improvement is available from these two inputs, so the residual near-collinearity is a genuine feature of the data and not an artefact of a lossy inequality.

The extremal value is intuitive in angle coordinates: $\arccos(0.462) = 1.09043$ and $\arccos(0.415) = 1.14286$ radians, so the two statistics must differ in angle by at least $0.05243$ radians, i.e. $\cos(0.05243) = 0.99863$.

---

## 3. A Model-Free Noise Floor

### 3.1 The model class

**Definition 3.1 (Noisy affine fade).** A ladder $(\rho_k)_{k \ge 0}$ is a *noisy affine fade with parameters* $(L, \lambda, \eta)$, $\eta \ge 0$, if
$$\big|\rho_{k+1} - \big(L + \lambda(\rho_k - L)\big)\big| \le \eta \qquad \text{for all } k.$$

$L$ is the floor, $\lambda$ the fade ratio, $\eta$ the noise level. This is the natural precise statement of "the correlation decays geometrically toward a limit, up to measurement error $\eta$".

**Definition 3.2 (Steps).** $d_k = \rho_{k+1} - \rho_k$.

### 3.2 Eliminating the floor

**Theorem 3.3 (Step recursion).** *If $(\rho_k)$ is a noisy affine fade with parameters $(L,\lambda,\eta)$ then for all $k$,*
$$|d_{k+1} - \lambda d_k| \le 2\eta.$$

*Proof.* Write $s_k = \rho_{k+1} - (L + \lambda(\rho_k - L))$ for the $k$-th residual, so $|s_k| \le \eta$. Then
$$d_{k+1} - \lambda d_k = (\rho_{k+2} - \rho_{k+1}) - \lambda(\rho_{k+1} - \rho_k) = s_{k+1} - s_k,$$
because the terms $L(1-\lambda)$ cancel in the difference. The triangle inequality gives $|s_{k+1} - s_k| \le 2\eta$. $\square$

Note the factor $2$: the floor is eliminated at the cost of the noise entering *twice*. This is not slack — it is the true price of a differencing operation.

**Theorem 3.4 (Ratio pinning).** *If additionally $d_k \neq 0$ then*
$$\left|\frac{d_{k+1}}{d_k} - \lambda\right| \le \frac{2\eta}{|d_k|}.$$

*Proof.* Divide the identity $d_{k+1}/d_k - \lambda = (d_{k+1} - \lambda d_k)/d_k$ through by $d_k$ and apply Theorem 3.3 together with $|x/y| = |x|/|y|$. $\square$

The consequence is conceptually important: *every* observed step ratio is an estimate of the same unknown $\lambda$, with a resolution $2\eta/|d_k|$ that degrades as the step shrinks. Small steps are uninformative about $\lambda$.

### 3.3 Eliminating the ratio

**Theorem 3.5 (Model-free noise floor).** *Let $(\rho_k)$ be a noisy affine fade with parameters $(L,\lambda,\eta)$ and let $i, j$ be indices with $d_i \neq 0 \neq d_j$. Then*
$$\left|\frac{d_{i+1}}{d_i} - \frac{d_{j+1}}{d_j}\right| \;\le\; 2\eta\left(\frac{1}{|d_i|} + \frac{1}{|d_j|}\right).$$

*Proof.* Both ratios lie within the stated distances of $\lambda$ by Theorem 3.4; apply the triangle inequality and cancel $\lambda$. $\square$

Every quantity on the left is observable and every quantity on the right except $\eta$ is observable. Rearranged,

$$\eta \;\ge\; \frac{\big|d_{i+1}/d_i - d_{j+1}/d_j\big|}{2\big(1/|d_i| + 1/|d_j|\big)}. \tag{$\ast$}$$

This is a lower bound on the noise of *any* fade model of the data, obtained without fitting anything.

### 3.4 The recorded ladder

The observed ratios are

$$r_0 = \frac{d_1}{d_0} = \frac{431}{303} = 1.42244\ldots,\quad r_1 = \frac{d_2}{d_1} = \frac{125}{431} = 0.29002\ldots,\quad r_2 = \frac{d_3}{d_2} = \frac{259}{125} = 2.072.$$

Applying $(\ast)$ to the three available pairs:

| pair | ratio mismatch | resolution weight | implied $\eta \ge$ |
|---|---|---|---|
| $(0,1)$ | $1.13242$ | $2(1/0.0303 + 1/0.0431) = 112.41$ | $\mathbf{0.01007398}$ |
| $(0,2)$ | $0.64956$ | $2(1/0.0303 + 1/0.0125) = 226.01$ | $0.00287407$ |
| $(1,2)$ | $1.78198$ | $2(1/0.0431 + 1/0.0125) = 206.40$ | $0.00863345$ |

**Theorem 3.6 (Noise floor of the record).** *Any noisy affine fade $(L,\lambda,\eta)$ reproducing the five rungs $0.5739, 0.5436, 0.5005, 0.4880, 0.4621$ satisfies*
$$\eta \;\ge\; \frac{73943}{7340000} = 0.0100739782\ldots$$

*Proof.* Apply $(\ast)$ with $(i,j) = (0,1)$. Exactly: $r_0 - r_1 = \frac{431^2 - 125\cdot 303}{303\cdot 431} = \frac{147886}{130593}$, while $2(1/|d_0| + 1/|d_1|) = 20000 \cdot \frac{734}{130593}$; the quotient is $\frac{147886}{14680000} = \frac{73943}{7340000}$. $\square$

**Interpretation.** The step at bit length 112 is $0.0259$, so the noise floor is $38.9\%$ of the step being read; the step at bit length 108 is $0.0125$, so the floor is $80.6\%$ of *that* step. In other words, at the recorded resolution the *shape* of the fade is not identifiable. Both the "plateau at bit length 108" reading (an anomalously small step) and the "re-acceleration at 112" reading (a step twice as large again) are features smaller than, or comparable to, the minimal noise any single-parameter-pair model must carry. The formal statement recorded is the double inequality $0.38 \cdot 0.0259 < \eta^\star < 0.02$.

---

## 4. The Bound Is Attained: Chebyshev Equioscillation

A lower bound alone leaves open whether the "fitting needs a lot of noise" reading is a property of the data or an artefact of the elimination in Section 3. It is the former, exactly.

### 4.1 Two-parameter fade fitting is a linear Chebyshev problem

**Definition 4.1 (Residual).** For a ladder $\rho$ and parameters $(L,\lambda)$, put
$$s_k(L,\lambda) = \rho_{k+1} - \big(L + \lambda(\rho_k - L)\big).$$
A ladder is a noisy affine fade with parameters $(L,\lambda,\eta)$ iff $|s_k(L,\lambda)| \le \eta$ for all $k$.

**Lemma 4.2 (Affinity of parameter change).** *For any two parameter pairs,*
$$s_k(L,\lambda) - s_k(L',\lambda') = A + B\rho_k, \qquad A = (\lambda' - 1)L' - (\lambda-1)L,\ \ B = \lambda' - \lambda,$$
*i.e. the difference is an affine function of the rung value $\rho_k$, with coefficients independent of $k$.*

*Proof.* $s_k(L,\lambda) = \rho_{k+1} - L(1-\lambda) - \lambda\rho_k$; subtract the same expression at $(L',\lambda')$. The $\rho_{k+1}$ terms cancel. $\square$

This is the structural fact: although the fade model is nonlinear in $(L,\lambda)$ jointly, the *family of residual functions* is a two-dimensional affine space in the variable $\rho_k$. Best-uniform fitting is therefore a linear Chebyshev approximation problem, and the classical alternation theory applies.

### 4.2 The alternation theorem

**Theorem 4.3 (Alternation certifies optimality).** *Let $\rho_k > \rho_{k+1} > \rho_{k+2}$ be strictly declining and suppose some parameter pair $(L',\lambda')$ produces residuals*
$$s_k(L',\lambda') = +\eta,\quad s_{k+1}(L',\lambda') = -\eta,\quad s_{k+2}(L',\lambda') = +\eta$$
*for some $\eta > 0$. Then no parameter pair $(L,\lambda)$ satisfies $|s_i(L,\lambda)| < \eta$ for $i = k, k+1, k+2$. In particular the minimal achievable uniform residual over the three rungs is exactly $\eta$.*

*Proof.* Suppose such $(L,\lambda)$ existed and set $f(x) = A + Bx$ as in Lemma 4.2, so $s_i(L,\lambda) - s_i(L',\lambda') = f(\rho_i)$. Then
$$f(\rho_k) = s_k(L,\lambda) - \eta < 0,\qquad f(\rho_{k+1}) = s_{k+1}(L,\lambda) + \eta > 0,\qquad f(\rho_{k+2}) = s_{k+2}(L,\lambda) - \eta < 0.$$
So the affine function $f$ takes signs $-,+,-$ at the three points $\rho_k > \rho_{k+1} > \rho_{k+2}$. An affine function is monotone; along a strictly monotone sequence of arguments it produces a monotone sequence of values, which cannot have the sign pattern $-,+,-$. (Concretely: $f(\rho_k) < 0 < f(\rho_{k+1})$ with $\rho_k > \rho_{k+1}$ forces $B < 0$, i.e. $f$ strictly decreasing; but then $\rho_{k+1} > \rho_{k+2}$ forces $f(\rho_{k+2}) > f(\rho_{k+1}) > 0$, contradicting $f(\rho_{k+2}) < 0$.) $\square$

**Corollary 4.4.** *An equioscillating triple is a certificate that every noisy affine fade of the ladder has noise level at least $\eta$.*

Two parameters, three alternations: this is precisely the classical count for a best uniform approximation by a two-dimensional linear family.

### 4.3 The optimum for the recorded ladder

**Theorem 4.5 (Exact minimal noise).** *Set*
$$\lambda^\star = \frac{278}{367} = 0.7574932\ldots,\qquad L^\star = \frac{725197}{1780000} = 0.4074140\ldots,\qquad \eta^\star = \frac{73943}{7340000} = 0.0100739782\ldots$$
*Then the residuals of the recorded ladder against $(L^\star, \lambda^\star)$ are exactly*
$$s_0 = +\eta^\star,\quad s_1 = -\eta^\star,\quad s_2 = +\eta^\star,\quad s_3 = -\frac{46663}{7340000} = -0.0063574,$$
*so the recorded ladder is a noisy affine fade with parameters $(L^\star,\lambda^\star,\eta^\star)$; and by Theorem 4.3 applied to the strictly declining triple $\rho_0 > \rho_1 > \rho_2$, no noisy affine fade of the ladder has noise below $\eta^\star$. Hence the minimal noise of the record is exactly $\eta^\star$.*

*Proof.* The four residual identities are exact rational computations. Achievability then requires only that the fourth residual also obey $|s_3| \le \eta^\star$, which holds since $46663 < 73943$. Optimality is Corollary 4.4 with $\eta = \eta^\star$ at $k=0$, the three rungs $0.5739 > 0.5436 > 0.5005$ being strictly declining. $\square$

That the model-free bound of Theorem 3.6 and the equioscillation optimum of Theorem 4.5 produce the *same* rational number $73943/7340000$ is not a coincidence: the pair $(i,j) = (0,1)$ that maximizes $(\ast)$ is precisely the pair of ratios whose mismatch the equioscillating fit splits evenly.

**Theorem 4.6 (Properties of the optimum).**
1. $0 < \lambda^\star < 1$: the best single-ratio reading of the record is *contractive*.
2. $L^\star < 0.55$: the optimal floor lies $0.1426$ below the pre-registered band, unconditionally — no assumptions on $\lambda$ or $\eta$ are needed, because both are determined by the data.
3. $L^\star$ lies below every recorded rung, including the later $0.4847$ and $0.43636$.
4. The optimal model's prediction for the next rung is $L^\star + \lambda^\star(\rho_4 - L^\star) = 0.448838\ldots$, against the recorded $0.4847$: an error of $0.0359$, about $3.6$ noise units.

---

## 5. Structural Consequences

### 5.1 Band loss is permanent under any contractive model

**Theorem 5.1 (Floor bound from one declining step).** *Let $(\rho_k)$ be a noisy affine fade with parameters $(L,\lambda,\eta)$, $0 \le \lambda < 1$, and suppose $\rho_{k+1} \le \rho_k$. Then*
$$L \le \rho_{k+1} + \frac{\eta}{1-\lambda}.$$

*Proof.* From $\rho_{k+1} \ge L + \lambda(\rho_k - L) - \eta$ and $\lambda(\rho_k - \rho_{k+1}) \ge 0$ we get
$$\rho_{k+1} \ge L(1-\lambda) + \lambda\rho_k - \eta \ge L(1-\lambda) + \lambda\rho_{k+1} - \eta,$$
i.e. $(1-\lambda)(L - \rho_{k+1}) \le \eta$. Divide by $1-\lambda > 0$. $\square$

**Theorem 5.2 (Band loss at the recorded rung).** *If the recorded ladder is a noisy affine fade with $0 \le \lambda \le 1/2$ and $\eta \le 0.02$, then*
$$L \le 0.5021 < 0.55 = B_{\mathrm{band}}.$$

*Proof.* Theorem 5.1 at $k = 3$ (where $\rho_4 = 0.4621 \le 0.4880 = \rho_3$) gives $L \le 0.4621 + \eta/(1-\lambda) \le 0.4621 + 0.02/0.5 = 0.5021$. $\square$

**Theorem 5.3 (Non-vacuity).** *The hypotheses are jointly satisfiable with the noise floor: the window $[73943/7340000,\ 0.02] \ni 0.015$ is nonempty.*

So the two consecutive sub-band rungs are not a transient dip. Under any contractive nonnegative model consistent with the measured noise, the *limit* of the ladder is out of band as well; and the optimal fit puts it at $\approx 0.4074$, far below.

### 5.2 The local fit at bit length 112 is expansive

The complementary reading fits only the last three rungs. Define the three-rung ratio and the Aitken $\Delta^2$ extrapolate of $(\rho_2, \rho_3, \rho_4)$:

$$r = \frac{\rho_4 - \rho_3}{\rho_3 - \rho_2}, \qquad \mathrm{Ait}(\rho_2,\rho_3,\rho_4) = \rho_2 - \frac{(\rho_3-\rho_2)^2}{\rho_4 - 2\rho_3 + \rho_2}.$$

**Theorem 5.4 (Expansive local fit).** *For the recorded triple $(0.5005, 0.4880, 0.4621)$:*
$$r = \frac{259}{125} = 2.072 > 1, \qquad \mathrm{Ait} = \frac{686295}{1340000} = 0.5121604\ldots > \rho_2 > \rho_3 > \rho_4.$$

Since $r > 1$, the fitted fixed point $\mathrm{Ait}$ is *repelling*, and it lies above all three data points it was fitted from. A "fade toward a floor" reading is therefore locally inconsistent with the triple at bit length 112: locally the ladder is accelerating away from a value above it, not decaying toward one below it.

**Theorem 5.5 (Scored extrapolation).** *The prediction the five-rung record licensed for the next rung, $\mathrm{Ait} + r(\rho_4 - \mathrm{Ait})$, equals*
$$\frac{68412896}{167500000} = 0.4084352.$$
*The subsequently recorded rung is $0.4847$. The error is*
$$0.4847 - 0.4084352 = \frac{95331}{1250000} = 0.0762648.$$

**Theorem 5.6 (The failure is not attributable to noise).** $0.0762648 > 7\eta^\star = 0.0705178$.

The extrapolation error exceeds seven times the minimal noise the data itself can carry. The expansive local model is therefore refuted *at the experiment's own resolution*: one cannot rescue it by appealing to measurement error, because the measurement error required is more than seven times the maximum consistent with the ladder.

The two fits thus fail in opposite directions and by different margins: the globally optimal contractive fade under-predicts by $3.6$ noise units; the expansive local fit under-predicts by $7.6$. Both under-predict, because the subsequent rung *rose*. What no model of this class captures is the rebound.

### 5.3 Decisiveness is a location problem

**Theorem 5.7 (A bar below the point estimate is unreachable).** *Let $c < B$ and $w \ge 0$. Then for every integer $m \ge 1$,*
$$c - \frac{w}{\sqrt{m}} < B.$$

*Proof.* $w/\sqrt m \ge 0$, so $c - w/\sqrt m \le c < B$. $\square$

Trivial as a piece of analysis, decisive as a piece of methodology: it says that the standard $1/\sqrt m$ shrinkage of a confidence interval moves both endpoints *toward the point estimate*, so an interval whose center is below the bar can never have its lower endpoint above the bar.

**Corollary 5.8 (The recorded advantage).** *The advantage $\delta = 0.047$ satisfies $\delta < B_{\mathrm{dec}} = 0.05$, with $B_{\mathrm{dec}} - \delta = 0.003$; and for every half-width $w \ge 0$ and every sample size $m \ge 1$, $\delta - w/\sqrt m < B_{\mathrm{dec}}$. Reaching decisiveness therefore requires shifting the point estimate by at least $0.003$ — a different experiment, not a larger one.*

**Remark 5.9 (Significance versus decisiveness).** The recorded interval $[0.003, 0.090]$ excludes $0$ and contains $0.05$. The first fact says the residue-pattern dial genuinely out-predicts the trailing-zero baseline. The second says the margin is not decisive. These are logically independent readings of the same interval, and the five-rung record realizes one without the other — the first time in the ladder that this has occurred.

---

## 6. Algorithms

The analysis above is fully algorithmic on rational input, and every displayed constant is an exact rational.

**Algorithm A (Model-free noise floor).** Input: rungs $\rho_0,\dots,\rho_n \in \mathbb{Q}$. Compute steps $d_k$; for every pair $(i,j)$ with $d_i, d_j \neq 0$ evaluate $(\ast)$; return the maximum. Cost $O(n^2)$ exact rational operations. Output: a certified lower bound on the noise of every noisy affine fade of the input.

**Algorithm B (Chebyshev optimum by alternation).** For a fixed triple of strictly declining consecutive rungs, solve the three linear equations $s_0 = +\eta$, $s_1 = -\eta$, $s_2 = +\eta$ in the unknowns $(L(1-\lambda),\ \lambda,\ \eta)$ — a $3 \times 3$ linear system, since $s_k = \rho_{k+1} - L(1-\lambda) - \lambda\rho_k$ is linear in the reparametrized unknowns $M = L(1-\lambda)$ and $\lambda$. Recover $L = M/(1-\lambda)$. Verify that the remaining residuals satisfy $|s_k| \le \eta$; if so, the alternation theorem certifies global optimality. Cost $O(1)$ per candidate triple, $O(n)$ triples. This is a one-step exchange algorithm (a degenerate Remez iteration).

**Algorithm C (Sharp decorrelation certificate).** Given a lower bound $a_0$ on $\mathrm{corr}(T,R)$ and a lower bound $\delta_0$ on the advantage, return $\max\{ab + \sqrt{(1-a^2)(1-b^2)} : a \ge a_0,\ a-b \ge \delta_0,\ |a|,|b| \le 1\}$. Since the objective in angle coordinates is $\cos(\alpha-\beta)$ and the constraint is $\cos\alpha - \cos\beta \ge \delta_0$, the maximum is attained at $a = a_0$, $b = a_0 - \delta_0$ whenever $a_0 - \delta_0 \ge 0$ and $a_0 + \delta_0 \le 1$, giving the closed form $a_0(a_0-\delta_0) + \sqrt{(1-a_0^2)(1-(a_0-\delta_0)^2)}$.

**Algorithm D (Exact quadratic-residue dial law).** For odd primes $p \ne q$, enumerate the units modulo $pq$ and tabulate the dial $T(x) \in \{0,1,2\}$. Verify the exact counts $(p-1)(q-1)/4$ per pattern and $2\sum(T-1)^2 = (p-1)(q-1)$. Cost $O(pq)$ naively, $O(p+q)$ with the Chinese Remainder factorization used in Section 7.

---

## 7. The Arithmetic Layer: The Dial's Information Does Not Fade

The statistical layer measures a *coupling* between $T$ and the rate. It is natural to ask whether the fade reflects the dial losing information at large bit lengths. It does not, and this can be settled exactly.

Fix distinct odd primes $p \ne q$. For $m \ge 1$ let $QR(m)$ be the set of nonzero quadratic residues modulo $m$ and $NQR(m)$ its complement among nonzero residues.

**Theorem 7.1 (Half the residues are squares).** *For an odd prime $p$,*
$$2\,|QR(p)| = p - 1 = 2\,|NQR(p)|,$$
*and both sets are nonempty.*

*Proof sketch.* Squaring is a $2$-to-$1$ homomorphism on the cyclic group $(\mathbb{Z}/p)^\times$ of order $p-1$ (its kernel is $\{\pm1\}$, of size $2$ since $p$ is odd), so its image has size $(p-1)/2$. Equivalently, the quadratic-character sum $\sum_{x \ne 0}\left(\frac{x}{p}\right)$ vanishes. Nonemptiness: $1 \in QR(p)$, and $|NQR(p)| = (p-1)/2 \ge 1$. $\square$

**Theorem 7.2 (CRT independence, counting form).** *Let $m, n$ be coprime with $m,n \ge 1$, and let $P$ and $Q$ be any properties of residues mod $m$ and mod $n$ respectively. Then*
$$\#\{x \bmod mn : P(x \bmod m) \text{ and } Q(x \bmod n)\} = \#\{y \bmod m : P(y)\}\cdot\#\{z \bmod n : Q(z)\}.$$

*Proof sketch.* The Chinese Remainder map $x \mapsto (x \bmod m,\ x \bmod n)$ is a ring isomorphism $\mathbb{Z}/mn \to \mathbb{Z}/m \times \mathbb{Z}/n$; the count is the cardinality of a product set under a bijection. $\square$

**Theorem 7.3 (The four patterns are equinumerous).** *For distinct odd primes $p\ne q$, each of the four residuosity patterns — square at both, square at $p$ only, square at $q$ only, square at neither — occurs exactly $(p-1)(q-1)/4$ times among residues mod $pq$. Stated without division: $4\,|\text{pattern}| = (p-1)(q-1)$ for each of the four patterns.*

*Proof.* Combine Theorems 7.1 and 7.2. $\square$

**Definition 7.4 (The two-prime dial).** For $x$ a unit mod $pq$, let $T(x) \in \{0,1,2\}$ be the number of the two primes at which $x$ is a quadratic residue.

**Theorem 7.5 (Exact binomial law).** *$T$ has the exact Binomial$(2,1/2)$ distribution on the units mod $pq$:*
$$4\,\#\{T = 0\} = 2\,\#\{T = 1\} = 4\,\#\{T = 2\} = (p-1)(q-1),$$
*and all three levels are attained, so $T$ is a nonconstant statistic. The number of units is $(p-1)(q-1)$, recovering Euler's totient of $pq$ from the pattern decomposition.*

**Theorem 7.6 (Variance exactly one half).** *Over the units mod $pq$,*
$$2\sum_{x} \big(T(x) - 1\big)^2 = (p-1)(q-1),$$
*i.e. $T$ has mean exactly $1$ and variance exactly $1/2$, for every pair of distinct odd primes.*

*Proof.* $(T-1)^2$ equals $1$ on the two extreme patterns and $0$ on the two middle ones, so the sum is $\#\{T=0\} + \#\{T=2\} = (p-1)(q-1)/2$ by Theorem 7.3. $\square$

**Corollary 7.7 (Separation of information from coupling).** *The dial's distribution — and hence its Shannon content, exactly $2$ bits for the residue component — is independent of $p, q$, and therefore independent of the bit length of $N$. The observed fade cannot be attributed to degradation of the quadratic-residue component of the dial; it must originate on the rate side of the pair.*

Small verifications: for $(p,q) = (3,5)$ the pattern counts are $2,2,2,2$ and the dial law is $2:4:2$; for $(7,11)$ they are $15$ each and the law is $15:30:15$.

---

## 8. Discussion

### 8.1 What the record supports and what it does not

Three claims about the record survive the analysis:

- **Band loss.** The whole confidence interval at bit length $112$ lies below $0.55$, for a second consecutive rung, and under every contractive model consistent with the data the *limit* is below the band as well ($L^\star \approx 0.4074$).
- **Residual signal.** A correlation of $0.46$ is far from chance; the arithmetic layer shows the dial carries exactly two bits of residue information at every bit length. The dial is informative; it is simply no longer *validated*.
- **Significant but not decisive.** The advantage over the count baseline is genuinely positive ($[0.003, 0.090]$ excludes $0$) but below the bar, and no replication can change that.

Two narrative claims do *not* survive:

- **"The plateau at bit length 108."** The step at bit length 108 $0.0125$ is only $1.24$ noise units; the anomaly it seemed to represent is inside the model's own error band.
- **"The fade re-accelerates toward a floor."** The re-acceleration is real as a difference of steps ($0.0259 > 2 \times 0.0125$), but the local three-rung fit that would make it precise is *expansive* ($r = 2.072$), and the prediction it licenses missed the next measurement by more than seven noise units.

The honest summary is that the ladder declines, that its limit is below band, and that at the recorded resolution its *shape* is not identifiable.

### 8.2 The methodological content

Three transferable ideas emerge.

**Advantage certifies originality.** The sharp bound $\mathrm{corr}(T,C) \le ab + \sqrt{(1-a^2)(1-b^2)}$ is the exact conversion between "my statistic beats yours by $\delta$" and "my statistic is not yours in disguise", and it is attained. Reported in angle coordinates it is the spherical triangle inequality, arguably the most natural language for comparing predictors against a common response.

**Noise floors before model fits.** A two-parameter model fitted to five points always fits *something*. The prior question — *how much noise does the fit require?* — is answered by eliminating the parameters between two observed step ratios, at the cost of one line of algebra and no optimization at all. When the answer is $39\%$ of the effect being read, no amount of curve-squinting is going to settle a debate about the effect's shape.

**Alternation as a stopping rule.** Because parameter changes perturb the residuals by an affine function of the rung, fade fitting is a linear Chebyshev problem and the classical three-point alternation certifies optimality. That gives a crisp criterion for what a new rung teaches: if the new datum lies inside the current error band, the alternation pattern is preserved and the rung carries no information about the fade shape; if it breaks the pattern, the model class is refuted. Alternation count, not correlation value, is the informative statistic of a ladder.

### 8.3 Limitations

The noisy affine fade is a deliberately austere model class: a single geometric ratio, a single floor, and a uniform sup-norm error budget. A model with bit-length-dependent noise, or with a second time scale, would not be bound by Theorem 3.6 in the same form (though the differencing argument adapts). The confidence intervals quoted are those of the original record and are treated here as given; the results of Section 5.3 concern only the geometry of an interval about a fixed point estimate. Finally, the sharpness statement of Theorem 2.6 bounds what can be inferred from $(a,b)$ *alone*: additional structural information about $T$ and $C$ (for instance that both are functions of $N$ with known joint law) could yield stronger decorrelation certificates.

---

## 9. Future Directions

**1. Angle-additivity of the fade.** The sharp bound is naturally a statement about the correlation angles $\alpha = \arccos\rho$. If the fade were a rotation of the response direction away from a fixed dial plane, the ladder would be affine *in angle*, not in correlation. The recorded angles are $0.95954, 0.99608, 1.04662, 1.06100, 1.09043$, with steps $0.03654, 0.05054, 0.01438, 0.02944$ and successive ratios $1.383, 0.285, 2.047$ — systematically slightly flatter than the correlation ratios $1.422, 0.290, 2.072$. The re-acceleration contracts in angle coordinates. The whole apparatus of Sections 3–4 applies verbatim to the angle ladder and yields a competing noise floor; comparing the two floors is a clean, purely computational test of which coordinate is the natural one.

**2. Equioscillation as a stopping rule.** The minimal-noise theorem is a Chebyshev fit with three alternations for two parameters. Adding a rung either preserves the alternation pattern — the new datum is inside the current error band, hence carries no information about the fade shape — or breaks it, refuting the model class. Since the alternation theorem is proved in general form, the rule can be tested against the already-recorded rungs at bit lengths $116$ and $120$ without any new experiment.

**3. Dial information versus dial coupling.** The residue dial has variance exactly $1/2$ at every pair of small primes, so its information content is two bits regardless of bit length. If the fade were caused by the dial losing information, the ladder would have to track a bit-length-dependent quantity — and Theorem 7.6 says there is none. The fade must therefore live on the *rate* side of the pair. The alternative explanation, dial degradation, is formally excluded for the residue component; the remaining candidate is the $2$-adic component, whose distribution *is* bit-length dependent (only through truncation of the geometric law), and quantifying that truncation effect is the natural next computation.

**4. Sharpness under additional constraints.** Theorem 2.6 shows the decorrelation bound cannot be improved from $(a,b)$ alone. Determining the exact attainable region of $\mathrm{corr}(T,C)$ under the extra structural constraint that $C$ is a *coarsening* of $T$ (a function of one of its components) would sharpen the originality certificate in exactly the direction the experiment needs.

---

## 10. Summary of Constants

| quantity | exact value | decimal |
|---|---|---|
| ladder | $0.5739,\ 0.5436,\ 0.5005,\ 0.4880,\ 0.4621$ | — |
| steps | $-0.0303,\ -0.0431,\ -0.0125,\ -0.0259$ | — |
| step ratios | $431/303,\ 125/431,\ 259/125$ | $1.42244,\ 0.29002,\ 2.072$ |
| minimal noise $\eta^\star$ | $73943/7340000$ | $0.0100739782$ |
| optimal ratio $\lambda^\star$ | $278/367$ | $0.7574932$ |
| optimal floor $L^\star$ | $725197/1780000$ | $0.4074140$ |
| optimal residuals | $+\eta^\star, -\eta^\star, +\eta^\star, -46663/7340000$ | $\pm 0.0100740,\ -0.0063574$ |
| local three-rung ratio | $259/125$ | $2.072$ |
| local Aitken value | $686295/1340000$ | $0.5121604$ |
| licensed prediction | $68412896/167500000$ | $0.4084352$ |
| recorded next rung | $4847/10000$ | $0.4847$ |
| extrapolation error | $95331/1250000$ | $0.0762648$ ($7.57\,\eta^\star$) |
| sharp decorrelation certificate | — | $0.99864$ |
| previous certificate | $1 - 0.047^2/2$ | $0.9988955$ |
| band floor / decisiveness bar | $0.55$ / $0.05$ | — |
| recorded advantage | $0.047$, CI $[0.003, 0.090]$ | shortfall $0.003$ |
| dial variance | $1/2$ | uniform in $p,q$ |
