# Capture Ceilings for Covariate Dials: Exact Finite-Sample Limits on Explaining Overdispersion, with an Application to Small-Prime Quadratic-Residue Statistics

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We develop an exact, finite-sample theory of how much of the dispersion of a nonnegative count sample can be explained by a *covariate dial* — an auxiliary statistic computed for each sample unit — and apply it to a concrete empirical situation: a sevenfold Poisson overdispersion in per-integer hit counts for a randomized arithmetic search over $128$ balanced bit-length-$96$ semiprimes.

Three structural results form the core. First, the *dispersion-reduction identity*: the relative reduction in the variance-to-mean ratio obtained by conditioning on a dial's level sets equals exactly the dial's explained-variance fraction $\eta^2$, so that two apparently independent acceptance criteria — a regression $R^2$ and a dispersion reduction — measure a single scalar. Second, a pair of optimality theorems — the *linear capture bound* (no affine recalibration beats the squared correlation $r^2$, with equality at least squares) and *conditional-mean optimality* (no dial-measurable predictor beats the cell means) — which together yield $r^2 \le \eta^2$ and convert a poor fit into a ceiling over all recalibrations. Third, a *family capture ceiling*: for pairwise uncorrelated dials the explained shares add, giving a residual floor $\bigl(1 - \sum_j r_j^2\bigr)\operatorname{Var}(y)$, attained at coordinatewise least squares, together with a Bessel inequality $\sum_j r_j^2 \le 1$ and the fact that collapsing a family into a single sum statistic can only lose explanatory power.

Instantiated at the recorded measurements — raw dispersion index $D_{\mathrm{raw}} = 7.27$ and best-dial explained fraction $\eta^2 \le 0.1422$ — these give a residual dispersion index of at least $6.23$ and an unexplained fraction of the Poisson excess of at least $83\%$, against a pre-registered acceptance bar of a $30\%$ dispersion reduction. We further prove that the two dials actually deployed are *exactly* uncorrelated under an independent-character model, by a parity identity on the four sign patterns at a single prime propagated across primes; the measured correlation $-0.01$ is thus a sampling artifact around an exact zero, and the two shares add rather than overlap.

Finally we convert the natural follow-up — extending the dial family from primes $\ell \le 400$ to all $\ell \le 10^6$ — into a proved decision rule: the extension window must supply at least $0.1578$ of aggregate squared correlation, forcing at least one individual symbol to reach $r^2 \ge 2\times 10^{-6}$; and any orthogonal decomposition of the carrier whose components are capped at the strongest recorded strength requires at least four components.

A separate but methodologically parallel section addresses *resolution-limited inversion*: when a booked quantity was never stored raw but recovered by inverting a law from a stored anchor, the set of compatible values is an interval of diameter at most $2\delta/m$ (and at least $2\delta/L$) rather than a point, and a forward Lipschitz estimate quantifies the induced overstatement in the printed anchor. All feasibility margins are shown to be stable under the resulting rebooking.

---

## 1. Introduction

### 1.1 The empirical situation

Consider a randomized arithmetic search run independently for each of $n = 128$ target integers $N$, each a *balanced semiprime* of bit length $96$ — a product of two primes of roughly equal size, so that the factor pool spans approximately $2^{49}$ to $2^{51}$. For each target, $150{,}000$ samples are drawn (about $19.2$ million in total) and the number of "hits" recorded, under a fixed tester and a fixed cut-off.

If the hit process were Poisson with a rate depending only on the coarse parameters (bit length, sample budget, cut-off), the count $X_N$ would satisfy $\operatorname{Var}(X) = \mathbb{E}[X]$, and the *dispersion index*
$$D \;=\; \frac{\operatorname{Var}(X)}{\mathbb{E}[X]}$$
would equal $1$. The observation is:

- mean $76.7$ hits per target;
- dispersion index $D_{\mathrm{raw}} = 7.27$;
- range $29$ to $172$, with a top cluster $172 / 151 / 130$.

The phenomenon replicates under a fresh master seed with an asserted and recorded stream-distinct, pairwise-disjoint set of targets, and the top cluster reproduces an earlier recorded envelope after rescaling. The overdispersion is therefore a property of the individual arithmetic targets, not of the randomization.

### 1.2 The candidate mechanism

There is a mechanistically motivated candidate. In searches of this shape the relevant divisibility event at a small prime $\ell$ is governed by a quadratic-residue condition: $\ell$ can divide a quantity of the form $x^2 - N$ precisely when $N$ is a quadratic residue modulo $\ell$, equivalently when the Jacobi symbol $\left(\tfrac{N}{\ell}\right) = +1$. A target with an unusually large supply of such primes should be an unusually productive target.

Three dials were regressed against the per-target log rates:

1. **Individual-symbol dial** $S_{\mathrm{indiv}}$: the number of favourable Legendre conditions among the two secret factors separately, over $\ell \le 100$.
2. **Product-symbol dial** $S_{\mathrm{prod}} = \#\{\ell \le 100 : N \text{ is a QR mod } \ell\}$: the mechanistically correct carrier.
3. **A wider recorded form** using the window $\ell \le 400$.

The pre-registered acceptance bar (H1) required **both** $R^2 \ge 0.25$ and a dispersion reduction of at least $30\%$. The measurements were:

| Dial | $R^2_{\log}$ | slope $z$ | dispersion reduction |
|---|---|---|---|
| $S_{\mathrm{indiv}}$, $\ell \le 100$ | $0.0127$ | $-2.82$ | $0.88\%$ |
| $S_{\mathrm{prod}}$, $\ell \le 100$ | $0.0781$ | $+10.9$ | $14.22\%$ |
| wider form, $\ell \le 400$ | $0.0565$ | $+8.7$ | $9.07\%$ |

Every dial misses both legs. The natural but unsatisfying conclusion — "the fit was poor" — is not a scientific statement. The purpose of this paper is to replace it with theorems.

### 1.3 What we prove

Three questions have to be answered before a negative fit becomes a bound.

**(Q1) Are the two acceptance legs comparable?** We show they are the *same* quantity: the dispersion reduction equals the explained-variance fraction $\eta^2$ (Theorem 3.4). The bar is one-dimensional.

**(Q2) Could a cleverer function of the dial succeed?** No: the cell-mean predictor is optimal among all dial-measurable predictors (Theorem 3.2), so $\eta^2$ is a ceiling over *all* recalibrations, and $r^2 \le \eta^2$ (Theorem 3.3).

**(Q3) Could enlarging the dial family succeed?** Only under a quantified budget: for orthogonal families the shares add and are capped at $1$ (Theorems 5.1, 5.4), collapsing a family into a count statistic can only lose (Theorem 5.6), and the untested window must supply an explicit amount (Theorems 6.1, 6.2).

We also prove that the two deployed dials are exactly uncorrelated in the natural probabilistic model (Theorem 4.4), which is what licenses the additive treatment in (Q3).

Throughout, the empirical numbers enter only as *hypotheses* of the numeric corollaries; the structural theorems are unconditional finite-sample algebra with no asymptotics and no distributional assumption other than an explicitly stated Poisson-calibration hypothesis where indicated.

---

## 2. Setup and notation

Fix a finite nonempty index set $I$ with $|I| = n$ (the targets). All statistics are *uniform sample* statistics over $I$.

**Definition 2.1 (Sample functionals).** For $x, y : I \to \mathbb{R}$,
$$\operatorname{avg}(x) = \frac{1}{n}\sum_{i \in I} x_i, \qquad
\operatorname{Cov}(x,y) = \operatorname{avg}\bigl((x - \operatorname{avg} x)(y - \operatorname{avg} y)\bigr), \qquad
\operatorname{Var}(x) = \operatorname{Cov}(x,x).$$
When $\operatorname{avg}(x) \ne 0$ the *dispersion index* is $D(x) = \operatorname{Var}(x)/\operatorname{avg}(x)$.

Two elementary facts are used constantly. The *product form* $\operatorname{Cov}(x,y) = \operatorname{avg}(xy) - \operatorname{avg}(x)\operatorname{avg}(y)$ follows by expanding and using linearity of $\operatorname{avg}$. The *Cauchy–Schwarz inequality* $\operatorname{Cov}(x,y)^2 \le \operatorname{Var}(x)\operatorname{Var}(y)$ follows from the inner-product Cauchy–Schwarz applied to the centred vectors.

**Definition 2.2 (Squared correlation).** For $\operatorname{Var}(x), \operatorname{Var}(s) > 0$,
$$r^2(y, s) \;=\; \frac{\operatorname{Cov}(y,s)^2}{\operatorname{Var}(y)\operatorname{Var}(s)} \;\in\; [0,1].$$

**Definition 2.3 (Dial, cells, cell means).** A *dial* is a map $s : I \to \mathbb{R}$. A *cell structure* is a map $g : I \to K$ into a finite label set; the cell with label $k$ is $C_k = \{i : g(i) = k\}$ and the cell mean of $x$ is
$$\bar x_k \;=\; \frac{1}{|C_k|}\sum_{i \in C_k} x_i \qquad (\bar x_k := 0 \text{ if } C_k = \varnothing).$$
A dial $s$ is *$g$-measurable* if $s = \varphi \circ g$ for some $\varphi : K \to \mathbb{R}$; the canonical choice is to let $g$ record the value of $s$ itself.

**Definition 2.4 (Within/between variance, explained fraction).**
$$\operatorname{Var}_{\mathrm{within}}(x \mid g) = \operatorname{avg}\bigl((x_i - \bar x_{g(i)})^2\bigr), \qquad
\operatorname{Var}_{\mathrm{between}}(x \mid g) = \operatorname{avg}\bigl((\bar x_{g(i)} - \operatorname{avg} x)^2\bigr),$$
$$\eta^2(x \mid g) = \frac{\operatorname{Var}_{\mathrm{between}}(x \mid g)}{\operatorname{Var}(x)}, \qquad
D_{\mathrm{within}}(x \mid g) = \frac{\operatorname{Var}_{\mathrm{within}}(x \mid g)}{\operatorname{avg}(x)}.$$

---

## 3. The single-dial theory

### 3.1 Affine recalibration

**Definition 3.0.** The recalibration error of the affine model $y \approx a + b\,s$ is
$\operatorname{MSE}(y, s; a, b) = \operatorname{avg}\bigl((y_i - a - b\,s_i)^2\bigr)$.

**Lemma 3.0 (Exact expansion).**
$$\operatorname{MSE}(y,s;a,b) = \operatorname{Var}(y) - 2b\operatorname{Cov}(y,s) + b^2\operatorname{Var}(s) + \bigl(\operatorname{avg} y - a - b\operatorname{avg} s\bigr)^2 .$$

*Proof sketch.* Expand $(y_i - a - b s_i)^2$ into the monomials $y_i^2$, $y_i s_i$, $s_i^2$, $y_i$, $s_i$, $1$, average termwise using linearity, and rewrite the second moments via the product form of covariance. Every step is an identity; no inequality is used. $\square$

**Theorem 3.1 (Linear capture bound).** Let $\operatorname{Var}(s) > 0$. For all $a, b \in \mathbb{R}$,
$$\operatorname{MSE}(y,s;a,b) \;\ge\; \operatorname{Var}(y) - \frac{\operatorname{Cov}(y,s)^2}{\operatorname{Var}(s)},$$
with equality at the least-squares coefficients $b^\star = \operatorname{Cov}(y,s)/\operatorname{Var}(s)$, $a^\star = \operatorname{avg}(y) - b^\star \operatorname{avg}(s)$. Equivalently, if $\operatorname{Var}(y) > 0$,
$$\operatorname{MSE}(y,s;a,b) \;\ge\; \bigl(1 - r^2(y,s)\bigr)\operatorname{Var}(y).$$

*Proof sketch.* In Lemma 3.0 complete the square in $b$: the quantity $-2b\operatorname{Cov}(y,s) + b^2\operatorname{Var}(s)$ equals $\dfrac{(\operatorname{Cov}(y,s) - b\operatorname{Var}(s))^2}{\operatorname{Var}(s)} - \dfrac{\operatorname{Cov}(y,s)^2}{\operatorname{Var}(s)}$, and both the completed square and the intercept term $(\operatorname{avg} y - a - b \operatorname{avg} s)^2$ are nonnegative. Setting $b = b^\star$ and $a = a^\star$ annihilates both. $\square$

The content is that *no re-tuning of the dial's slope or offset* can lower the residual below $(1-r^2)\operatorname{Var}(y)$. The measured $R^2$ is not an artifact of a fitting procedure; it is the exact linear ceiling.

### 3.2 Nonlinear recalibration: conditional means are optimal

**Lemma 3.1 (Within-cell centring).** For any finite set $F \subseteq I$, any $x$, and any centre $m$,
$$\sum_{i \in F} (x_i - m)^2 \;=\; \sum_{i \in F}(x_i - \bar x_F)^2 \;+\; |F|\,(\bar x_F - m)^2, \qquad \bar x_F = \tfrac{1}{|F|}\textstyle\sum_{j\in F} x_j,$$
with both sides zero when $F = \varnothing$.

*Proof sketch.* Expand both sides into $\sum x_i^2$, $\sum x_i$, and $|F|$ and use $\sum_{j\in F} x_j = |F|\bar x_F$. $\square$

**Theorem 3.2 (Conditional-mean optimality).** For any cell structure $g$ and any predictor $h : K \to \mathbb{R}$,
$$\sum_{i \in I} \bigl(x_i - \bar x_{g(i)}\bigr)^2 \;\le\; \sum_{i \in I}\bigl(x_i - h(g(i))\bigr)^2 .$$

*Proof sketch.* Partition the sum over $I$ into sums over the cells $C_k$ (a rearrangement, since the cells are the fibres of $g$). Within each cell apply Lemma 3.1 with $m = h(k)$: the difference between the two sides is the nonnegative term $|C_k|(\bar x_k - h(k))^2$. Summing over $k$ gives the claim. $\square$

Thus among **all** predictors that see the sample only through $g$ — linear, polynomial, monotone, arbitrary — the cell-mean predictor is optimal, and its residual is $n \cdot \operatorname{Var}_{\mathrm{within}}(x \mid g)$.

**Theorem 3.3 (Variance decomposition and $r^2 \le \eta^2$).** For any $x$ and any $g$,
$$\operatorname{Var}(x) \;=\; \operatorname{Var}_{\mathrm{within}}(x \mid g) + \operatorname{Var}_{\mathrm{between}}(x \mid g).$$
Moreover if $s = \varphi \circ g$ is $g$-measurable with $\operatorname{Var}(s) > 0$ and $\operatorname{Var}(y) > 0$, then
$$r^2(y, s) \;\le\; \eta^2(y \mid g).$$

*Proof sketch.* For the decomposition, apply Lemma 3.1 in each cell with $m = \operatorname{avg}(x)$ and sum over cells; the cross terms assemble exactly into $\sum_i (\bar x_{g(i)} - \operatorname{avg} x)^2$. For the inequality: since $s$ is $g$-measurable, the affine predictor $a^\star + b^\star s$ is a particular $g$-measurable predictor, so Theorem 3.2 gives $\operatorname{Var}_{\mathrm{within}}(y \mid g) \le \operatorname{MSE}(y, s; a^\star, b^\star) = \operatorname{Var}(y) - \operatorname{Cov}(y,s)^2/\operatorname{Var}(s)$ by Theorem 3.1. Combining with the decomposition yields $\operatorname{Cov}(y,s)^2/\operatorname{Var}(s) \le \operatorname{Var}_{\mathrm{between}}(y \mid g)$; dividing by $\operatorname{Var}(y)$ gives the claim. $\square$

This resolves an apparent tension in the data: the measured dispersion reduction ($14.22\%$) *exceeds* the linear $R^2$ ($7.81\%$) for the same dial. That is exactly the gap $\eta^2 - r^2 \ge 0$, and it is the theorem being tight, not an inconsistency.

### 3.3 Dispersion: the identification of the two legs

**Theorem 3.4 (Dispersion-reduction identity).** Let $\operatorname{avg}(x) > 0$ and $\operatorname{Var}(x) > 0$. Then
$$\frac{D(x) - D_{\mathrm{within}}(x\mid g)}{D(x)} \;=\; \eta^2(x \mid g).$$

*Proof sketch.* Both $D$ and $D_{\mathrm{within}}$ have the same denominator $\operatorname{avg}(x)$, which therefore cancels in the ratio, leaving $(\operatorname{Var} - \operatorname{Var}_{\mathrm{within}})/\operatorname{Var}$; by Theorem 3.3 the numerator is $\operatorname{Var}_{\mathrm{between}}$. $\square$

This is the identification that makes the pre-registered bar coherent: both legs are the single scalar $\eta^2$, and the bar reads $\eta^2 \ge 0.30$ (with the $R^2$ leg the weaker requirement $r^2 \ge 0.25$, itself dominated by $\eta^2$).

**Theorem 3.5 (Poisson mixture).** If $\operatorname{avg}(x) > 0$ and the within-cell calibration is Poisson, i.e. $\operatorname{Var}_{\mathrm{within}}(x \mid g) = \operatorname{avg}(x)$, then
$$D(x) \;=\; 1 + \frac{\operatorname{Var}_{\mathrm{between}}(x\mid g)}{\operatorname{avg}(x)} .$$

*Proof sketch.* Substitute the variance decomposition into $D = \operatorname{Var}/\operatorname{avg}$ and use the calibration hypothesis on the within term. $\square$

Interpretation: under exact within-cell Poisson behaviour, *all* overdispersion is between-cell heterogeneity, so a dial that captures the heterogeneity would drive $D$ to $1$. The measured failure to do so is therefore a direct statement about the dial.

**Theorem 3.6 (Residual dispersion floor).** If $\operatorname{avg}(x) > 0$, $\operatorname{Var}(x) > 0$ and $\eta^2(x\mid g) \le e$, then
$$D_{\mathrm{within}}(x \mid g) \;\ge\; (1-e)\,D(x).$$

*Proof sketch.* $\eta^2 \le e$ gives $\operatorname{Var}_{\mathrm{between}} \le e\operatorname{Var}$, so by decomposition $\operatorname{Var}_{\mathrm{within}} \ge (1-e)\operatorname{Var}$; divide by the positive mean. $\square$

**Theorem 3.7 (Structural miss of the bar).** If $\eta^2(x \mid g) < 3/10$ then $D_{\mathrm{within}}(x\mid g) > \tfrac{7}{10} D(x)$: no recalibration of the dial — affine or cell-wise — attains a $30\%$ dispersion reduction.

### 3.4 Certified numeric readings

**Corollary 3.8 (Residual dispersion).** With $D(x) = 7.27$ and $\eta^2(x \mid g) \le 0.1422$ (the best of the three measured dials, the mechanistic product form),
$$D_{\mathrm{within}}(x \mid g) \;\ge\; 6.23 .$$

**Corollary 3.9 (Unexplained Poisson excess).** Under the same hypotheses,
$$D_{\mathrm{within}}(x\mid g) - 1 \;\ge\; 0.83\,\bigl(D(x) - 1\bigr),$$
i.e. at least $83\%$ of the Poisson excess $D - 1 = 6.27$ survives every dial-based recalibration.

Both follow from Theorem 3.6 by arithmetic: $(1 - 0.1422)\times 7.27 = 6.2363\ldots \ge 6.23$, and $6.2363 - 1 = 5.2363 \ge 0.83 \times 6.27 = 5.2041$.

The verdict is therefore not a statement about a fitting procedure but about the mechanism: **at least $83\%$ of the excess dispersion is target-arithmetic structure invisible to every recorded quadratic-residue dial.** The small-scale calibration (at bit lengths $40$–$48$) does not extend to bit length $96$.

---

## 4. Exact orthogonality of the two deployed dials

### 4.1 The character model

The robustness question is whether the primary dial failed merely because it is nearly collinear with, or a degenerate transform of, the mechanistic dial. The answer is the opposite extreme: they are exactly orthogonal.

Model the pair of Legendre symbols at a prime $\ell$ as an independent uniform pair of signs
$$u = (u_1, u_2) \in \{\pm 1\}^2, \qquad u_1 = \Bigl(\tfrac{p}{\ell}\Bigr) = +1?, \quad u_2 = \Bigl(\tfrac{q}{\ell}\Bigr) = +1?,$$
with the four patterns equally likely and independence across primes.

**Definition 4.1 (Per-prime statistics).**
$$\iota(u) = \mathbf{1}[u_1] + \mathbf{1}[u_2] \in \{0,1,2\}, \qquad \pi(u) = \mathbf{1}[u_1 = u_2] \in \{0,1\}.$$
Here $\iota$ is the individual-symbol contribution and $\pi$ the product-symbol indicator, which fires precisely when $\left(\tfrac{N}{\ell}\right) = \left(\tfrac{p}{\ell}\right)\left(\tfrac{q}{\ell}\right) = +1$ — i.e. exactly the divisibility carrier condition $\ell \mid x^2 - N$.

Over the four patterns, $\operatorname{avg}(\iota) = 1$ and $\operatorname{avg}(\pi) = 1/2$. Write $\tilde\iota = \iota - 1$ and $\tilde\pi = \pi - \tfrac12$.

**Theorem 4.2 (One-prime orthogonality).** $\displaystyle\sum_{u \in \{\pm1\}^2} \tilde\iota(u)\,\tilde\pi(u) = 0$, and also $\sum_u \tilde\iota(u) = \sum_u \tilde\pi(u) = 0$.

*Proof.* Tabulate over $(u_1,u_2) = (+,+), (+,-), (-,+), (-,-)$:
$$\tilde\iota = 1,\ 0,\ 0,\ -1; \qquad \tilde\pi = \tfrac12,\ -\tfrac12,\ -\tfrac12,\ \tfrac12; \qquad \tilde\iota\,\tilde\pi = \tfrac12,\ 0,\ 0,\ -\tfrac12 .$$
The sums are $0$, $0$, $0$. Structurally: under the global sign flip $u \mapsto -u$ the centred individual count is **odd** and the centred product indicator is **even**, so the pairing cancels in pairs. $\square$

### 4.2 Propagation across primes

Let $\Sigma$ be a finite pattern alphabet (here $\Sigma = \{\pm 1\}^2$, $|\Sigma| = 4$) and consider the pattern space $\Sigma^k$ over $k$ primes, with the uniform measure — this is exactly independence across primes.

**Lemma 4.3 (Additive propagation).** Let $a, b : \Sigma \to \mathbb{R}$ satisfy $\sum_\sigma a(\sigma) = \sum_\sigma b(\sigma) = 0$ and $\sum_\sigma a(\sigma) b(\sigma) = 0$. Then for every $k \ge 0$,
$$\sum_{w \in \Sigma^k} \Bigl(\sum_{i<k} a(w_i)\Bigr) = 0
\qquad\text{and}\qquad
\sum_{w \in \Sigma^k} \Bigl(\sum_{i<k} a(w_i)\Bigr)\Bigl(\sum_{i<k} b(w_i)\Bigr) = 0 .$$

*Proof sketch.* Induction on $k$, splitting off the first coordinate via the bijection $\Sigma \times \Sigma^{k-1} \cong \Sigma^{k}$. The first identity is immediate: the total splits into $|\Sigma^{k-1}|\sum_\sigma a(\sigma)$ plus $|\Sigma|$ copies of the inductive total. For the second, expand
$$(a(\sigma) + A(w))(b(\sigma) + B(w)) = a(\sigma)b(\sigma) + a(\sigma)B(w) + b(\sigma)A(w) + A(w)B(w)$$
where $A, B$ are the tail sums. Summing over $w \in \Sigma^{k-1}$ and then over $\sigma$: the first term gives $|\Sigma^{k-1}|\sum_\sigma a b = 0$; the second and third vanish by the first identity applied to $b$ and $a$; the fourth vanishes by the inductive hypothesis. $\square$

**Definition 4.3'.** The two dials over $k$ primes are $S_{\mathrm{indiv}}(w) = \sum_i \iota(w_i)$ and $S_{\mathrm{prod}}(w) = \sum_i \pi(w_i)$, with means $k$ and $k/2$ respectively (immediate from the first identity of Lemma 4.3).

**Theorem 4.4 (Exact dial orthogonality).** For every $k \ge 0$,
$$\operatorname{Cov}\bigl(S_{\mathrm{indiv}}, S_{\mathrm{prod}}\bigr) = 0$$
as a uniform sample covariance over the pattern space $\Sigma^k$.

*Proof.* Centre: $S_{\mathrm{indiv}}(w) - k = \sum_i \tilde\iota(w_i)$ and $S_{\mathrm{prod}}(w) - k/2 = \sum_i \tilde\pi(w_i)$. Apply Lemma 4.3 with $a = \tilde\iota$, $b = \tilde\pi$, whose hypotheses are Theorem 4.2. $\square$

The measured $r = -0.01$ is thus a sampling fluctuation around an exact zero, for every prime window. Note the epistemic direction: this does **not** weaken the verdict. It means the two dials are complementary rather than redundant, so their explanatory shares add — and even summed they miss the bar.

### 4.3 The joint bound for two orthogonal dials

**Theorem 4.5 (Joint capture bound).** Let $\operatorname{Var}(s), \operatorname{Var}(t) > 0$ and $\operatorname{Cov}(s,t) = 0$. Then for all $a,b,c$,
$$\operatorname{avg}\bigl((y_i - a - b s_i - c t_i)^2\bigr) \;\ge\; \operatorname{Var}(y) - \frac{\operatorname{Cov}(y,s)^2}{\operatorname{Var}(s)} - \frac{\operatorname{Cov}(y,t)^2}{\operatorname{Var}(t)} = \bigl(1 - r^2(y,s) - r^2(y,t)\bigr)\operatorname{Var}(y).$$

*Proof sketch.* Expand exactly as in Lemma 3.0, now with a cross term $2bc\operatorname{Cov}(s,t)$ which vanishes by hypothesis. Complete the square separately in $b$ and in $c$; both completed squares and the intercept square are nonnegative. $\square$

**Corollary 4.6 (Joint reading).** With $r^2(y, S_{\mathrm{indiv}}) \le 0.0127$ and $r^2(y, S_{\mathrm{prod}}) \le 0.0781$ and orthogonality, every joint affine recalibration leaves at least $0.9092\operatorname{Var}(y)$ in the residual: over $90\%$ of the log-rate variance is unexplained.

---

## 5. Families of dials: ceilings, budgets, and aggregation

### 5.1 The family capture ceiling

Let $s = (s_j)_{j \in J}$ be a finite family of dials, each of positive variance, and consider
$$\operatorname{MSE}_J(y, s; a, b) = \operatorname{avg}\Bigl(\bigl(y_i - a - \textstyle\sum_j b_j s_{j,i}\bigr)^2\Bigr).$$

**Lemma 5.0 (Family expansion).**
$$\operatorname{MSE}_J = \operatorname{Var}(y) - 2\sum_j b_j \operatorname{Cov}(y, s_j) + \sum_j \sum_l b_j b_l \operatorname{Cov}(s_j, s_l) + \Bigl(\operatorname{avg} y - a - \sum_j b_j \operatorname{avg} s_j\Bigr)^2 .$$

*Proof sketch.* Write $S_i = \sum_j b_j s_{j,i}$. Then $\operatorname{MSE}_J = \operatorname{avg}\bigl(((y-S) - a)^2\bigr) = \operatorname{Var}(y - S) + (\operatorname{avg}(y-S) - a)^2$. Expand $\operatorname{Var}(y-S) = \operatorname{Var}(y) - 2\operatorname{Cov}(y,S) + \operatorname{Var}(S)$ and use bilinearity of the sample covariance over finite sums (proved by induction on the index set from additivity in each argument). $\square$

**Theorem 5.1 (Family capture ceiling).** If $\operatorname{Cov}(s_j, s_l) = 0$ for all $j \ne l$, then for all $a$ and all $b$,
$$\operatorname{MSE}_J(y,s;a,b) \;\ge\; \operatorname{Var}(y) - \sum_j \frac{\operatorname{Cov}(y,s_j)^2}{\operatorname{Var}(s_j)} \;=\; \Bigl(1 - \sum_j r^2(y,s_j)\Bigr)\operatorname{Var}(y),$$
and equality holds at the coordinatewise least-squares coefficients $b_j = \operatorname{Cov}(y,s_j)/\operatorname{Var}(s_j)$ with the matching intercept.

*Proof sketch.* Orthogonality collapses the double sum in Lemma 5.0 to $\sum_j b_j^2 \operatorname{Var}(s_j)$. Complete the square in each $b_j$ independently: for each $j$,
$$-2b_j\operatorname{Cov}(y,s_j) + b_j^2\operatorname{Var}(s_j) \;\ge\; -\frac{\operatorname{Cov}(y,s_j)^2}{\operatorname{Var}(s_j)},$$
with equality at the stated coefficient. Sum over $j$ and drop the nonnegative intercept square; for tightness, verify the diagonal and linear sums coincide at the optimum. $\square$

**Theorem 5.2 (Family bar).** If $\sum_j r^2(y, s_j) < 3/10$ for an orthogonal family, then every joint affine recalibration leaves more than $\tfrac{7}{10}\operatorname{Var}(y)$ in the residual. No enlargement of the family rescues the hypothesis unless the enlargement supplies, in aggregate, more than $0.30$ of squared correlation.

**Corollary 5.3 (Family reading of the experiment).** The two recorded dials are orthogonal with squared correlations $0.0127$ and $0.0781$; as a family they explain at most $9.08\%$, leaving at least $90.92\%$ of the variance.

### 5.2 A Bessel inequality: the budget is finite

**Theorem 5.4 (Bessel inequality for dials).** For any orthogonal family of dials with $\operatorname{Var}(y) > 0$,
$$\sum_{j \in J} r^2(y, s_j) \;\le\; 1 .$$

*Proof sketch.* The mean squared error is an average of squares, hence nonnegative. Evaluate Theorem 5.1 at the optimum, where the residual equals $\bigl(1 - \sum_j r_j^2\bigr)\operatorname{Var}(y)$; nonnegativity plus $\operatorname{Var}(y) > 0$ gives the claim. $\square$

**Corollary 5.5 (Dilution ceiling).** If all $m = |J|$ dials of an orthogonal family satisfy $r^2(y,s_j) \ge \rho$, then $\rho \le 1/m$.

This is a genuine structural constraint on "the phenomenon is carried by many weak symbols": the weaker each symbol, the more you need, but the budget never grows.

### 5.3 Collapsing a window loses information

A product-form count such as $\#\{\ell \le L : N \text{ is a QR mod }\ell\}$ is literally a *sum of per-prime indicators*. What does the collapsed statistic cost?

**Lemma 5.5' (Variance of an orthogonal sum).** For a pairwise-uncorrelated family, $\operatorname{Var}\bigl(\sum_j s_j\bigr) = \sum_j \operatorname{Var}(s_j)$.

**Theorem 5.6 (Aggregation can only lose).** For an orthogonal family with $\operatorname{Var}(y) > 0$ and each $\operatorname{Var}(s_j) > 0$,
$$r^2\Bigl(y, \sum_j s_j\Bigr) \;\le\; \sum_j r^2(y, s_j).$$

*Proof sketch.* By bilinearity $\operatorname{Cov}(y, \sum_j s_j) = \sum_j \operatorname{Cov}(y,s_j)$ and by Lemma 5.5' the denominator is $\sum_j \operatorname{Var}(s_j)$. The claim is then the Cauchy–Schwarz inequality in Engel (Sedrakyan) form,
$$\frac{\bigl(\sum_j c_j\bigr)^2}{\sum_j v_j} \;\le\; \sum_j \frac{c_j^2}{v_j} \qquad (v_j > 0),$$
applied with $c_j = \operatorname{Cov}(y,s_j)$, $v_j = \operatorname{Var}(s_j)$, then divided by $\operatorname{Var}(y)$. $\square$

Two consequences. (i) The recorded product-form reading $0.1422$ is a *lower* bound on the capture of the window it summarises; the family ceiling, not the collapsed count, is the correct object to test the bar against. (ii) A follow-up experiment that only ever regresses aggregate counts is systematically underpowered relative to the per-symbol family it aggregates.

---

## 6. A decision rule for the prime-window extension

The natural hypothesis for the failure is a *scale shift*: at bit length $96$ the informative prime window may lie beyond $400$, in $400 < \ell \le 10^6$, whereas the earlier successful calibrations were performed at bit lengths $40$–$48$. The follow-up is cheap — roughly $78{,}498$ Legendre symbols per target. The theory above turns "run it and see" into a pre-registered rule.

**Theorem 6.1 (Window transfer).** Let $T \subseteq J$ be the already-tested sub-window. If $\sum_{j \in T} r^2(y,s_j) \le 0.1422$ and the full family meets the bar $\sum_{j\in J} r^2(y,s_j) \ge 0.30$, then the untested complement satisfies
$$\sum_{j \in T^c} r^2(y, s_j) \;\ge\; 0.1578 .$$

*Proof.* The squared correlations sum over the partition $J = T \sqcup T^c$; subtract. $\square$

**Lemma 6.1' (Pigeonhole for budgets).** If $U$ is a nonempty finite index set and $b \le \sum_{j\in U} r^2(y,s_j)$, then some $j \in U$ has $r^2(y,s_j) \ge b/|U|$.

*Proof.* Otherwise every term is strictly below $b/|U|$ and the sum is strictly below $b$. $\square$

**Theorem 6.2 (Per-symbol target).** Under the hypotheses of Theorem 6.1, if the extension window is nonempty and contains at most $78{,}498$ primes, then at least one *individual* Legendre-symbol dial in $400 < \ell \le 10^6$ satisfies
$$r^2(y, s_j) \;\ge\; 2\times 10^{-6}.$$

*Proof.* Combine Theorem 6.1 and Lemma 6.1': the forced per-symbol floor is $0.1578/78498 = 2.010\ldots \times 10^{-6} \ge 2\times 10^{-6}$. $\square$

This is a sharply falsifiable prediction. **If every symbol in the extension window measures below $2\times10^{-6}$, the scale-shift hypothesis is refuted**, and the residual clustering is carried by structure outside the quadratic-residue dial family altogether.

**Theorem 6.3 (Carrier-dimension lower bound).** If no single dial of an orthogonal family carries more than $c > 0$ of squared correlation, then meeting the bar requires $|J| \ge 0.3/c$.

*Proof.* $0.30 \le \sum_j r_j^2 \le |J|\,c$. $\square$

**Corollary 6.4.** At the strongest recorded dial strength $c = 0.0781$, at least **four** mutually uncorrelated mechanisms are required. (Indeed $0.3/0.0781 = 3.84\ldots$, so three do not suffice.)

Taken together with the Bessel inequality, Theorems 6.2–6.3 bracket the carrier from both sides: it cannot be a haze of arbitrarily many arbitrarily weak orthogonal causes (the budget is capped at $1$ and each symbol must clear $2\times10^{-6}$), and it cannot be three weak ones.

---

## 7. Resolution-limited inversion of a booked anchor

This section is logically independent of §§3–6 but methodologically of a piece with them: it replaces an informal bookkeeping worry with an exact two-sided theorem.

### 7.1 The situation

Four amplification anchors had been booked together with an underlying hit probability $\hat P$. An archival examination established that **no raw $\hat P$ was ever stored** in the relevant artifacts: one source stored mean costs only, with no hit indicator and no committed window; the other's apparent $\hat P$ was a designed oracle value of exactly $1$ at the relevant cell. All four booked values are therefore *drafted-law inversions*, recovered from the stored anchor to a precision of about $2\times10^{-4}$.

The full-precision stored anchors are $5.193592154916$, $6.914724537168$, $4.353075657862$, and $29.125436718134$ (the last an exact enumeration). Inverting the certified law gives implied probabilities $0.841617$, $0.894868$, $0.800308$, and $0.985068$. The booked value at the fourth locus, $0.9853$, overstates the certified reading by $2.32\times10^{-4}$.

The question is what such a number *means*, and whether the discrepancy matters downstream.

### 7.2 Two-sided resolution

**Definition 7.1.** Let $f : \mathbb{R} \to \mathbb{R}$ and $W \subseteq \mathbb{R}$ a window.
- $f$ is **$m$-expansive on $W$** if $f(y) - f(x) \ge m(y-x)$ whenever $x \le y$ in $W$.
- $f$ is **$L$-Lipschitz-above on $W$** if $f(y) - f(x) \le L(y-x)$ whenever $x \le y$ in $W$.
- Given a stored anchor $R$ and precision $\delta$, the **resolution cell** is
$$\mathcal{C}(R,\delta) = \{P \in W : |f(P) - R| \le \delta\}.$$

**Theorem 7.2 (Resolution limit, upper half).** If $m > 0$ and $f$ is $m$-expansive on $W$, then any $P, Q \in \mathcal{C}(R,\delta)$ satisfy $|P - Q| \le 2\delta/m$.

*Proof sketch.* WLOG $P \le Q$. Expansiveness gives $m(Q-P) \le f(Q) - f(P)$, and both values lie within $\delta$ of $R$, so $f(Q) - f(P) \le 2\delta$. Divide by $m > 0$. $\square$

**Theorem 7.3 (Resolution limit, lower half).** If $f$ is $m$-expansive ($m \ge 0$) and $L$-Lipschitz-above on $W$ with $L > 0$, and $f(P_0) = R$ with $P_0, P \in W$ and $|P - P_0| \le \delta/L$, then $P \in \mathcal{C}(R,\delta)$.

*Proof sketch.* Say $P \le P_0$ (the other case is symmetric). Then $0 \le f(P_0) - f(P) \le L(P_0 - P) \le L\cdot(\delta/L) = \delta$, using monotonicity for the lower and the Lipschitz bound for the upper estimate; hence $|f(P) - R| \le \delta$. $\square$

Together: the cell is a genuine interval of width between $2\delta/L$ and $2\delta/m$, never a point. **An inversion cannot report more than the cell.** That is the precise content of "book at resolution limit."

**Theorem 7.4 (Forward amplification).** If $f$ is monotone ($0$-expansive) and $L$-Lipschitz-above on $W$, then $|f(P) - f(Q)| \le L\,|P-Q|$ for $P, Q \in W$.

**Corollary 7.5 (Printed-anchor overstatement).** With local sensitivity $L = 826$ at the relevant locus, booking $\hat P = 0.9853$ instead of the certified $0.985068$ overstates the printed anchor by at most
$$826 \times 2.32\times 10^{-4} \;=\; 0.1916\ldots \;\le\; 0.192,$$
matching the reported $\approx 0.19$: the printed $29.3152$ overstates the certified reading $29.1254$.

### 7.3 A non-degenerate instance

The hypotheses are not vacuous, and the two constants genuinely differ. Take the amplification law $f(P) = 1/(1-P)$ on $W = [0.98, 0.99]$. Since $f(y) - f(x) = (y-x)/\bigl((1-y)(1-x)\bigr)$ and $1-x, 1-y \in [0.01, 0.02]$ on $W$, we get
$$2500 \;\le\; \frac{1}{(1-y)(1-x)} \;\le\; 10000 ,$$
so $f$ is $2500$-expansive and $10000$-Lipschitz-above on $W$. Consequently the resolution cell has width at most $\delta/1250$ (Theorem 7.2) while containing an interval of half-width $\delta/10000$ (Theorem 7.3) — a genuine window, bracketed by a factor of $8$.

### 7.4 Feasibility is unaffected

**Theorem 7.6 (Margin stability).** If a feasibility reading is recorded with slack, $S_{\mathrm{raw}} + \mu \le S_A$, and the booked quantity is perturbed by at most $\varepsilon \le \mu$, i.e. $|S_A' - S_A| \le \varepsilon$, then $S_{\mathrm{raw}} \le S_A'$.

*Proof.* $S_A' \ge S_A - \varepsilon \ge S_{\mathrm{raw}} + \mu - \varepsilon \ge S_{\mathrm{raw}}$. $\square$

**Corollary 7.7 (All four loci hold).** The recorded margins are $0.212$, $0.242$, $0.183$, $0.190$, each exceeding the rebooking perturbation of $0.18$; hence all four feasibility readings $S_{\mathrm{raw}} \le S_A$ continue to hold after rebooking at the resolution limit.

The corrected-table arithmetic is exact at all four loci and the feasibility margins hold fourfold. The recommendation therefore stands as a bookkeeping rule: **book at resolution limit, not at stored $\hat P$**, because the raw-$\hat P$-stored admissibility clause was never met.

---

## 8. Algorithms

The theory yields three procedures, all cheap.

**A. Explained-fraction (capture) estimator.** Given counts $x_i$ and a dial $s_i$: form the level sets of $s$; compute cell means, within and between variances; report $\eta^2$, $D$, $D_{\mathrm{within}}$, and check the identity $(D - D_{\mathrm{within}})/D = \eta^2$ numerically. Complexity $O(n \log n)$ (dominated by grouping), or $O(n)$ with hashing.

**B. Orthogonal family capture budget.** Given a target $y$ and $m$ per-symbol dials $s_j$: compute $r_j^2$ for each, sum, and compare to the bar $0.30$. Complexity $O(nm)$ in time and $O(n)$ in memory when streaming the dials. For the $\ell \le 10^6$ follow-up, $n = 128$ and $m \approx 78{,}498$, i.e. about $10^7$ elementary operations — negligible. Crucially, this replaces a generalized linear model fit (which in the first smoke run *diverged*, requiring Fisher scoring with deviance step-halving) by a sum of scalars with a proved stopping rule.

**C. Per-symbol threshold audit.** Given the budget from B and the tested-window cap, compute the transfer requirement $0.30 - (\text{tested cap})$ and divide by the extension window size to obtain the forced per-symbol floor; then report the maximum observed per-symbol $r^2$ in the extension window and adjudicate. Complexity $O(m)$ after B.

---

## 9. Discussion

### 9.1 What the verdict is, and is not

The verdict is a **new-structure map entry**, not a breakthrough. The pre-registered null fires; the alternative is rejected. Concretely:

- The phenomenon replicates on a fresh seed with provably disjoint targets: $D_{\mathrm{raw}} = 7.27$, mean $76.7$.
- Every recorded quadratic-residue dial explains at most $14.22\%$ of the variance, hence — by Theorems 3.2, 3.4, 3.6 — at most $14.22\%$ of the dispersion under *any* recalibration.
- At least $83\%$ of the Poisson excess is target-arithmetic structure that no recorded mechanism sees.
- The two deployed dials are orthogonal, so this is not redundancy: it is a genuine joint ceiling of about $9\%$.

### 9.2 The slope-sign anomaly

One recorded caveat deserves emphasis in the interpretation. The primary individual-symbol dial exhibits a *negative* slope at the full sample size ($z = -2.82$) after a *positive* slope in a $16$-target smoke run, with a pseudo-$R^2$ of about $-0.001$. Both legs of the null fire for this dial regardless of sign, so the verdict does not depend on the direction. But a sign reversal at this effect size and sample size is not a citable finding without replication, and it should not be read as a reversal of the earlier small-scale calibration. The honest statement is: the primary dial is, to within measurement error, orthogonal to the target — which is exactly what Theorem 4.4 predicts, since it is orthogonal by construction to the divisibility carrier.

### 9.3 Why exactness matters here

Every theorem above is finite-sample and exact. Nothing is asymptotic; the only distributional hypothesis anywhere is the explicitly-flagged within-cell Poisson calibration of Theorem 3.5, and even that is used only for interpretation, not for the bounds. The measured quantities appear solely as hypotheses of numeric corollaries. Consequently:

- if the measurements are revised, the conclusions move continuously and can be re-derived by arithmetic;
- there is no model-selection freedom to exploit — the ceilings hold over *all* recalibrations;
- the follow-up decision rule is genuinely pre-registerable, because both the aggregate threshold ($0.1578$) and the per-symbol threshold ($2\times10^{-6}$) are consequences of the recorded numbers, not of a fit.

### 9.4 Relation to the earlier calibrations

Earlier work calibrated a related product-form dial successfully at bit lengths $40$–$48$. The present result shows that line does **not** extend to bit length $96$ within the window $\ell \le 400$. The most economical hypothesis is that the informative prime window scales with the factor pool (here spanning roughly $2^{49}$ to $2^{51}$) and has moved past $400$. Theorems 6.1 and 6.2 make this a testable claim rather than a hedge. If the extension window captures, the earlier lines unify with the present one under a *scale-dependent dial bound*. If it misses, the residual clustering is genuinely new structure.

### 9.5 Methodological ledger

Three procedural catches are recorded for completeness, none affecting the data: a first-smoke divergence in the fitting routine, repaired before the full run by Fisher scoring with deviance step-halving; the smoke-versus-full slope-sign instability discussed above, flagged as non-citable; and a monitor double-fire, verified directly against the stored records with no data impact. It is worth noting that Algorithm B above is immune to the first of these by construction: adding squared correlations cannot diverge.

---

## 10. Future directions

### 10.1 Prime-window capture spectrum

The key insight is that the family capture ceiling $\sum_{\ell \le X} r_\ell^2$ is a *monotone function of the prime cut* $X$. The question "did the informative window move past $400$?" therefore becomes "does the capture spectrum $X \mapsto \sum_{\ell \le X} r_\ell^2$ cross $0.30$?" — a single scalar curve, measurable and provably bounded. Theorem 5.1 already establishes that for orthogonal per-prime dials the ceiling is the sum of individual shares, and independent characters make distinct primes orthogonal, so the whole $\ell \le 10^6$ follow-up reduces to computing $78$k scalars and adding them, with a proved stopping rule instead of a fitted generalized linear model.

### 10.2 Carrier-dimension lower bound

A variance-to-mean ratio of $7.27$ forces *any* explanatory family, orthogonal or not, to contain at least one direction of appreciable strength if it is to explain the excess with a bounded number of regressors: with $m$ regressors capped at $c$, the bar needs $mc \ge 0.30$. Overdispersion of this size cannot be produced by many individually weak, mutually orthogonal causes, since the Bessel budget caps the total at $1$ and the dilution ceiling caps each of $m$ equal dials at $1/m$. Sharpening this into a *dimension* statement for non-orthogonal families — a lower bound on the rank of any explanatory design matrix achieving a given dispersion reduction — is the natural next theorem.

### 10.3 Beyond quadratic residues

If the extension window misses the per-symbol threshold, the search must move outside the character family altogether. Candidate carriers include multiplicative structure of $p \pm 1$ and $q \pm 1$, class-group data of the associated quadratic order, and short-interval statistics of the smoothness profile — each of which admits the same treatment: define a dial, compute $r^2$, and adjudicate against a family ceiling instead of a fit.

### 10.4 Resolution-limit bookkeeping as a general rule

The resolution-cell formalism of §7 is not specific to one erratum. Any pipeline that stores derived anchors and later re-infers inputs from them incurs a resolution cell of width $2\delta/m$; booking practice should record the cell, not a point, whenever the raw-input-stored clause is unmet. Codifying the admissibility rule — *book at resolution limit unless the raw quantity is stored* — as a checkable condition on an artifact schema is a small but high-leverage piece of infrastructure.

---

## 11. Conclusion

A negative empirical result becomes scientific capital exactly when it is upgraded from "this fit failed" to "no procedure of this class can succeed." We have carried out that upgrade in a specific case: a sevenfold Poisson overdispersion in per-target hit counts, and a family of small-prime quadratic-residue dials proposed to explain it.

The instruments are elementary — the variance decomposition, completion of the square, Cauchy–Schwarz, and a parity identity on four sign patterns — but their combination is sharp. The dispersion-reduction identity collapses a two-legged acceptance bar to a single scalar. Conditional-mean optimality closes off nonlinear rescues. The family ceiling and the Bessel inequality bound whole windows at once and convert an open-ended follow-up into a pre-registered per-symbol threshold of $2\times10^{-6}$. And the resolution-cell theorems make "at resolution limit" a definite, two-sided notion, with all four downstream feasibility margins proved stable.

What remains is the interesting part: at least $83\%$ of the excess dispersion is carried by something no recorded mechanism sees. We now know precisely how strong that something has to be, how many independent pieces it may consist of, and exactly which measurement will tell us whether it lives in the primes up to a million or somewhere else entirely.
