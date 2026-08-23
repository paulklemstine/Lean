# Draw-Regime Invariance of Weighted Covariance Dials

### A pairwise-functional analysis of sampling robustness, with an exact homotopy law, an $\ell^1$ stability bound, and a concordance-budget triage rule

**Author:** Aristotle

**Date:** 2026-08-23

---

## Abstract

A *dial* is a scalar summary, computed from a weighted sample of a finite population, that is intended to detect an association between two attributes of the population's elements. A recurring concern in applied work is **dilution**: the fear that an unbalanced sampling scheme systematically attenuates a real association until it becomes undetectable, so that a negative reading reflects the sampling scheme rather than the population.

We give a complete structural analysis of this concern for the canonical dial, the weighted covariance. The organising principle is the weighted Hoeffding–Chebyshev **pair identity**
$$2\operatorname{Cov}_p(x,y) = \sum_{i}\sum_{j} p_i p_j\,(x_i-x_j)(y_i-y_j),$$
which factors the dial into a *population part* — the concordance matrix $D_{ij}=(x_i-x_j)(y_i-y_j)$, entirely free of the sampling weights — and a *regime part* consisting of nonnegative pair masses $p_ip_j$. Because a draw regime can only supply nonnegative weights, it can attenuate but never invert the population's verdict.

From this we derive: (i) nonnegativity of the dial in **every** draw regime for comonotone populations, with strict positivity as soon as one strictly concordant pair is charged; (ii) stability of the guarantee under arbitrary monotone re-encodings of either coordinate, so that rank (Spearman-type) dials inherit it; (iii) a Lipschitz bound $|\operatorname{Cov}_p - \operatorname{Cov}_q| \le M_xM_y\|p-q\|_1$ in terms of the attribute ranges and the $\ell^1$ distance between regimes; (iv) an exact quadratic law for the dial along the linear homotopy between two regimes, together with a universal $\tfrac12\min$ floor on the whole segment; (v) a concordance/discordance budget $\varepsilon^2 C - M^2\Delta \le 2\operatorname{Cov}_p$ yielding an explicit triage rule $\kappa^2 < C/\Delta$ in terms of the regime's conditioning number $\kappa = M/\varepsilon$; and (vi) a variance-share layer establishing weighted Cauchy–Schwarz, the identity $\min\mathrm{MSE} = \operatorname{Var}_p(y)(1-R^2_p)$, an exact augmentation-gain formula $\langle r,z\rangle_p^2/\|z\|_p^2$, and draw-invariant dominance of an exact affine driver over all rival predictors.

We also delimit the result. The variance share $R^2$ is **not** regime-invariant: a worked four-key population exhibits a footprint predictor whose advantage over a count predictor falls from $0.2117$ under a balanced regime to $0.1337$ under a regime at $\ell^1$ distance $0.9$, while the ordering is preserved. What survives regime change is the sign, the ordering under an exact driver, and $\ell^1$-controlled deviations — not the numerical variance share.

**Keywords:** weighted covariance, Hoeffding identity, comonotonicity, concordance, total variation, importance sampling, Spearman correlation, variance share, Schur convexity.

---

## 1. Introduction

### 1.1 The dilution hypothesis

Consider a finite population of items — we call them **keys** — each carrying two real attributes: a **footprint** $x_i$ and a **yield rate** $y_i$. A practitioner wishes to know whether footprint predicts yield, and constructs a **dial**: a single scalar, computed from a weighted sample, that is positive when large footprints accompany large yields.

The dial must be computed under whatever sampling scheme is available. In practice that scheme is rarely uniform: some keys are over-represented because they are cheap to observe, others under-represented because they are rare. This raises the *dilution hypothesis*:

> **(H2, dilution)** Under a genuinely unbalanced draw, the measured association between footprint and yield is systematically attenuated relative to a balanced draw, potentially to the point of being undetectable.

If (H2) held, a dial would be unusable outside carefully designed experiments. Our results refute it in a precise and, as it turns out, structural sense — while simultaneously identifying the one component of the analysis that genuinely *is* regime-dependent.

### 1.2 Contributions

We work with an arbitrary finite index set and impose no probabilistic model whatsoever: no independence, no distributional assumptions, no asymptotics. Everything is an exact algebraic identity or a finite inequality. The contributions are:

1. **Structural (§3).** The pair identity, and its immediate consequence that the dial is a nonnegatively-weighted sum over pairs of a regime-free population quantity.
2. **Qualitative invariance (§4).** Sign invariance across all draw regimes for comonotone populations; strict positivity under full support; stability under monotone re-encoding, hence for rank dials.
3. **Quantitative stability (§5).** An $\ell^1$/total-variation Lipschitz bound with explicit constants.
4. **Homotopy law (§6).** The exact quadratic in the mixing parameter, the nonnegativity of the cross term, and the $\tfrac12\min$ floor.
5. **Budget and triage (§7).** Concordance and discordance masses as population invariants, the budget inequality, and the conditioning-number threshold.
6. **Variance-share layer (§8).** Weighted least squares, Cauchy–Schwarz, $R^2$, augmentation gain, and draw-invariant dominance.
7. **A worked population and the boundary of the claim (§9).**

### 1.3 Relation to classical material

The unweighted case of the pair identity is classical, appearing in the analysis of Chebyshev's sum inequality and in Hoeffding's covariance representation. The comonotonicity condition is the discrete shadow of the coupling notion used in dependence theory. What is new here is the *use* of these to answer a sampling-robustness question: treating balanced and unbalanced sampling as two points of the same simplex, and reading off invariance, stability, homotopy, and triage as consequences of a single factorisation.

---

## 2. Setting and definitions

Throughout, $\iota$ is a finite index set with $n = |\iota|$ elements, and $x, y : \iota \to \mathbb{R}$ are the footprint and yield attributes.

**Definition 2.1 (Draw regime).** A *draw regime* on $\iota$ is a function $p : \iota \to \mathbb{R}$ satisfying $p_i \ge 0$ for all $i$ and $\sum_{i} p_i = 1$. We write $\mathcal{P}(\iota)$ for the set of draw regimes — the standard simplex on $\iota$.

The **uniform** or **balanced** regime is $p_i = 1/n$. An **unbalanced** regime is any other. A regime has **full support** if $p_i > 0$ for all $i$. Crucially, no structural distinction is drawn between balanced and unbalanced regimes: they are points of the same convex set, and all our statements quantify over the whole simplex.

**Definition 2.2 (Weighted moments).** For $p \in \mathcal P(\iota)$,
$$\mu_p(x) = \sum_i p_i x_i, \qquad \operatorname{Cov}_p(x,y) = \sum_i p_i \bigl(x_i - \mu_p(x)\bigr)\bigl(y_i - \mu_p(y)\bigr), \qquad \operatorname{Var}_p(x) = \operatorname{Cov}_p(x,x).$$

We refer to $\operatorname{Cov}_p(x,y)$ as **the dial**.

**Lemma 2.3 (Symmetry).** $\operatorname{Cov}_p(x,y) = \operatorname{Cov}_p(y,x)$.

*Proof.* Termwise commutativity of multiplication. $\square$

**Lemma 2.4 (Raw-moment form).** For $p$ with $\sum_i p_i = 1$,
$$\operatorname{Cov}_p(x,y) = \sum_i p_i x_i y_i - \Bigl(\sum_i p_i x_i\Bigr)\Bigl(\sum_i p_i y_i\Bigr).$$

*Proof.* Expand each summand of the definition:
$$p_i\bigl(x_i - \mu_p(x)\bigr)\bigl(y_i - \mu_p(y)\bigr) = p_ix_iy_i - \mu_p(y)\,p_ix_i - \mu_p(x)\,p_iy_i + \mu_p(x)\mu_p(y)\,p_i.$$
Summing over $i$ and using $\sum_i p_i = 1$ turns the last term into $\mu_p(x)\mu_p(y)$ and the two middle terms into $-2\mu_p(x)\mu_p(y)$. $\square$

Note that Lemma 2.4 already uses normalisation; without $\sum_i p_i = 1$ the identity fails, and it is the only place normalisation is genuinely needed for the algebra.

---

## 3. The pair identity

**Definition 3.1 (Concordance matrix).** For a population $(x,y)$ define
$$D_{ij} = (x_i - x_j)(y_i - y_j), \qquad i,j \in \iota.$$
$D$ is symmetric and hollow ($D_{ii} = 0$). It is a **regime-free** object: it depends on the population alone.

**Theorem 3.2 (Weighted Hoeffding–Chebyshev pair identity).** For every draw regime $p$,
$$2\operatorname{Cov}_p(x,y) \;=\; \sum_{i}\sum_{j} p_i\,p_j\,D_{ij}.$$

*Proof sketch.* Expand $D_{ij} = x_iy_i - x_iy_j - y_ix_j + x_jy_j$ and distribute against $p_ip_j$, splitting the double sum into four double sums:
$$\sum_{i,j} p_ip_jD_{ij} = \sum_{i,j} \bigl(p_i x_iy_i\bigr)p_j - \sum_{i,j}(p_ix_i)(p_jy_j) - \sum_{i,j}(p_iy_i)(p_jx_j) + \sum_{i,j} p_i \bigl(p_j x_jy_j\bigr).$$
Each is a product of single sums. Using $\sum_j p_j = 1$, the first and fourth each equal $\sum_i p_ix_iy_i$; the second and third each equal $\mu_p(x)\mu_p(y)$. Hence the right side is $2\bigl(\sum_i p_ix_iy_i - \mu_p(x)\mu_p(y)\bigr)$, which is $2\operatorname{Cov}_p(x,y)$ by Lemma 2.4. $\square$

**Remark 3.3 (Why this is the whole story).** Theorem 3.2 exhibits the dial as
$$\operatorname{Cov}_p(x,y) = \tfrac12\, p^{\mathsf T} D\, p,$$
a quadratic form in the regime with a *fixed, population-determined* hollow symmetric matrix. Two consequences drive everything below:

- The regime enters only through the **nonnegative** pair masses $p_ip_j$. It reweights the population's pairwise verdicts but cannot alter their signs.
- The map $p \mapsto \operatorname{Cov}_p(x,y)$ is a polynomial of degree exactly $2$ on the simplex. All regime dependence of the dial is therefore governed by the behaviour of the quadratic form $D$ on $\mathcal P(\iota)$ — a question of linear algebra, not of sampling theory.

---

## 4. Qualitative invariance

**Definition 4.1 (Comonotone population).** The population $(x,y)$ is **comonotone** if $D_{ij} \ge 0$ for all $i,j$; equivalently, no pair of keys is discordant, i.e. a larger footprint is never paired with a strictly smaller yield.

Comonotonicity is a purely ordinal hypothesis: it asks that sorting by footprint also sorts by yield, with ties permitted. It requires no linearity, no smoothness, and no distributional structure.

**Theorem 4.2 (No dilution, qualitative form).** If $(x,y)$ is comonotone then $\operatorname{Cov}_p(x,y) \ge 0$ for **every** draw regime $p$.

*Proof.* Each term $p_ip_jD_{ij}$ in Theorem 3.2 is a product of nonnegative reals, hence nonnegative; a sum of nonnegative reals is nonnegative; divide by $2$. $\square$

**Theorem 4.3 (No dilution, strict form).** Let $(x,y)$ be comonotone and let $p$ be a draw regime. If there are keys $a, b$ with $p_a > 0$, $p_b > 0$ and $D_{ab} > 0$, then $\operatorname{Cov}_p(x,y) > 0$.

*Proof.* In the nonnegative double sum of Theorem 3.2 the single term $p_ap_bD_{ab}$ is strictly positive, so the whole sum is strictly positive. $\square$

**Corollary 4.4 (Draw-regime invariance of the dial's sign; two-regime form).** Let $(x,y)$ be comonotone with at least one strictly concordant pair $D_{ab} > 0$. Then for **any** two full-support draw regimes $p$ and $q$ — for instance a balanced one and a genuinely unbalanced one —
$$\operatorname{Cov}_p(x,y) > 0 \quad\text{and}\quad \operatorname{Cov}_q(x,y) > 0.$$

*Proof.* Apply Theorem 4.3 to each regime, using full support for the hypotheses $p_a, p_b > 0$. $\square$

This is the formal content of the dilution refutation. To make a comonotone population's dial vanish, a regime must remove *all* strictly concordant pairs from its support; merely underweighting them cannot do it. Attenuation of magnitude is possible; loss of the signal is not.

### 4.1 Monotone re-encoding and rank dials

**Lemma 4.5 (Comonotonicity is ordinal).** Let $(x,y)$ be comonotone and let $g, h : \mathbb{R} \to \mathbb{R}$ be nondecreasing. Then $(g\circ x, h\circ y)$ is comonotone.

*Proof.* Fix $i,j$ and trichotomise on $x_i$ versus $x_j$.

- If $x_i < x_j$: we claim $y_i \le y_j$. Otherwise $y_i > y_j$, so $(x_i - x_j)(y_i-y_j) < 0$, contradicting comonotonicity. Monotonicity of $g$ and $h$ then gives $g(x_i) \le g(x_j)$ and $h(y_i)\le h(y_j)$, so the product $(g(x_i)-g(x_j))(h(y_i)-h(y_j))$ is a product of two nonpositive numbers, hence $\ge 0$.
- If $x_i = x_j$: the first factor vanishes.
- If $x_i > x_j$: symmetric to the first case. $\square$

**Theorem 4.6 (Rank / Spearman-type invariance).** Let $(x,y)$ be comonotone and $g,h$ nondecreasing. Then for every draw regime $p$,
$$\operatorname{Cov}_p(g\circ x,\, h\circ y) \;\ge\; 0.$$

*Proof.* Lemma 4.5 followed by Theorem 4.2. $\square$

Since replacing an attribute by its rank within the population is a nondecreasing re-encoding, Theorem 4.6 covers rank-based dials, which are exactly what Spearman-type statistics measure. The invariance guarantee is therefore simultaneously robust to the sampling scheme and to the measurement scale.

---

## 5. Quantitative stability in $\ell^1$

Sign invariance says nothing about how far the numerical reading may drift. We now bound the drift exactly.

**Definition 5.1 ($\ell^1$ distance).** For regimes $p, q$, set $\|p-q\|_1 = \sum_i |p_i - q_i|$. This is twice the total-variation distance between the corresponding distributions.

**Lemma 5.2 (Pair-mass estimate).** For draw regimes $p, q$,
$$\sum_{i}\sum_j \bigl|p_ip_j - q_iq_j\bigr| \;\le\; 2\,\|p-q\|_1.$$

*Proof.* Write $p_ip_j - q_iq_j = p_i(p_j - q_j) + (p_i - q_i)q_j$ and apply the triangle inequality termwise:
$$\sum_{i,j}|p_ip_j - q_iq_j| \le \sum_{i,j} p_i|p_j - q_j| + \sum_{i,j}|p_i-q_i|q_j = \Bigl(\sum_i p_i\Bigr)\|p-q\|_1 + \|p-q\|_1\Bigl(\sum_j q_j\Bigr),$$
which is $2\|p-q\|_1$ by normalisation. $\square$

**Theorem 5.3 (Regime stability of the dial).** Suppose the attributes have bounded ranges: $|x_i - x_j| \le M_x$ and $|y_i - y_j| \le M_y$ for all $i,j$. Then for any two draw regimes $p,q$,
$$\bigl|\operatorname{Cov}_p(x,y) - \operatorname{Cov}_q(x,y)\bigr| \;\le\; M_x M_y \,\|p-q\|_1.$$

*Proof sketch.* If $\iota$ is empty both sides vanish; otherwise the range hypotheses force $M_x, M_y \ge 0$. Subtract the two instances of Theorem 3.2:
$$2\bigl(\operatorname{Cov}_p(x,y) - \operatorname{Cov}_q(x,y)\bigr) = \sum_{i,j}\bigl(p_ip_j - q_iq_j\bigr)D_{ij}.$$
Take absolute values, use $|D_{ij}| = |x_i-x_j|\,|y_i-y_j| \le M_xM_y$ inside the triangle inequality, and then apply Lemma 5.2:
$$2\bigl|\operatorname{Cov}_p - \operatorname{Cov}_q\bigr| \le M_xM_y\sum_{i,j}|p_ip_j - q_iq_j| \le M_xM_y\cdot 2\|p-q\|_1. \qquad\square$$

**Remark 5.4 ("Identical within noise", quantified).** Theorem 5.3 converts an informal experimental phrase into a theorem. Two regimes at small $\ell^1$ distance *must* report nearly equal dials — the discrepancy is Lipschitz in the sampling perturbation with the explicit constant $M_xM_y$. Conversely, the bound is the worst that can happen at a given $\ell^1$ separation, so no adversarial reweighting can produce an unbounded change without moving far in $\ell^1$.

---

## 6. The regime homotopy: an exact quadratic law

Regimes form a convex set, so any two can be joined by a segment. We compute the dial along it exactly.

**Definition 6.1 (Regime mixture).** For $p, q : \iota\to\mathbb R$ and $t\in\mathbb R$, set $p^t_i = (1-t)p_i + t q_i$.

**Lemma 6.2.** If $\sum_i p_i = \sum_i q_i = 1$ then $\sum_i p^t_i = 1$ for every $t$; and if $p,q \ge 0$ and $t\in[0,1]$ then $p^t \ge 0$. Hence for $t\in[0,1]$ the mixture of two draw regimes is a draw regime.

*Proof.* Linearity of the sum for the first claim; convex combination of nonnegatives for the second. $\square$

**Definition 6.3 (Cross term).** For weightings $p, q$,
$$K(p,q) \;=\; \tfrac12 \sum_i\sum_j p_i\,q_j\,D_{ij}.$$

**Lemma 6.4.** $K(p,q) = K(q,p)$, and if $p,q \ge 0$ and the population is comonotone then $K(p,q)\ge 0$.

*Proof.* Symmetry: exchange the summation order and use $D_{ji} = D_{ij}$. Nonnegativity: every summand is a product of nonnegatives. $\square$

**Theorem 6.5 (Exact quadratic law along a regime homotopy).** For weightings $p, q$ with $\sum_i p_i = \sum_i q_i = 1$ and any $t\in\mathbb R$,
$$\operatorname{Cov}_{p^t}(x,y) \;=\; (1-t)^2\operatorname{Cov}_p(x,y) \;+\; 2t(1-t)\,K(p,q) \;+\; t^2\operatorname{Cov}_q(x,y).$$

*Proof sketch.* Apply Theorem 3.2 to $p^t$, which is legitimate by Lemma 6.2. Expand the product $p^t_i p^t_j$ into its four bilinear pieces:
$$p^t_ip^t_j = (1-t)^2 p_ip_j + (1-t)t\, p_iq_j + t(1-t)\, q_ip_j + t^2 q_iq_j,$$
and distribute the double sum accordingly. The first and last blocks are $2\operatorname{Cov}_p$ and $2\operatorname{Cov}_q$ by Theorem 3.2; the two middle blocks are equal to each other (relabel and use symmetry of $D$), each contributing $2K(p,q)$. Divide by $2$. $\square$

**Corollary 6.6 (Lower quadratic envelope).** If $p, q$ are draw regimes and the population is comonotone, then for $t\in[0,1]$,
$$\operatorname{Cov}_{p^t}(x,y) \;\ge\; (1-t)^2\operatorname{Cov}_p(x,y) + t^2 \operatorname{Cov}_q(x,y).$$

*Proof.* Drop the middle term of Theorem 6.5, which is nonnegative since $2t(1-t)\ge 0$ on $[0,1]$ and $K(p,q)\ge 0$ by Lemma 6.4. $\square$

**Theorem 6.7 (No dilution anywhere on the segment: the $\tfrac12\min$ floor).** For a comonotone population and draw regimes $p, q$, every $t\in[0,1]$ satisfies
$$\operatorname{Cov}_{p^t}(x,y) \;\ge\; \tfrac12 \min\bigl(\operatorname{Cov}_p(x,y),\, \operatorname{Cov}_q(x,y)\bigr).$$

*Proof.* Write $m = \min(\operatorname{Cov}_p, \operatorname{Cov}_q)$, which is $\ge 0$ by Theorem 4.2. By Corollary 6.6,
$$\operatorname{Cov}_{p^t} \ge (1-t)^2\operatorname{Cov}_p + t^2\operatorname{Cov}_q \ge \bigl((1-t)^2 + t^2\bigr)m \ge \tfrac12 m,$$
the last step because $(1-t)^2 + t^2 - \tfrac12 = \tfrac12(2t-1)^2 \ge 0$. $\square$

**Remark 6.8.** Theorem 6.7 rules out an *interior collapse*: the dial cannot vanish, or even lose more than a factor of two, at any intermediate mixing of two regimes that each read positively. The extremal case $t=\tfrac12$ with $K=0$ shows the constant $\tfrac12$ is the right order; with $K$ genuinely positive the floor is comfortably beaten.

---

## 7. The concordance budget and a triage rule

Real populations are rarely exactly comonotone. We therefore split the pairwise evidence into two population invariants.

**Definition 7.1 (Concordance and discordance mass).**
$$C(x,y) = \sum_i\sum_j \max(D_{ij},\, 0), \qquad \Delta(x,y) = \sum_i\sum_j \max(-D_{ij},\, 0).$$
Both are nonnegative, and both depend on the population alone.

**Proposition 7.2 (Signed budget identity).** $C(x,y) - \Delta(x,y) = \sum_{i,j} D_{ij}$.

*Proof.* For each real $d$, $\max(d,0) - \max(-d,0) = d$ (check the two cases $d\ge0$, $d\le0$). Sum over pairs. $\square$

**Proposition 7.3 (Discordance characterises comonotonicity).** $\Delta(x,y) = 0$ if and only if $(x,y)$ is comonotone.

*Proof.* ($\Leftarrow$) If all $D_{ij}\ge 0$ then $\max(-D_{ij},0) = 0$ for every pair. ($\Rightarrow$) $\Delta$ is a sum of nonnegative terms, so $\Delta = 0$ forces $\max(-D_{ij},0)=0$, i.e. $D_{ij}\ge0$, for every pair. $\square$

**Theorem 7.4 (Concordance budget).** Let $p$ be a weighting with $\sum_i p_i = 1$ and suppose $0 \le \varepsilon \le p_i \le M$ for every $i$. Then
$$\varepsilon^2\, C(x,y) \;-\; M^2\, \Delta(x,y) \;\le\; 2\operatorname{Cov}_p(x,y).$$

*Proof sketch.* Rewrite the left-hand side pairwise as $\sum_{i,j}\bigl(\varepsilon^2\max(D_{ij},0) - M^2\max(-D_{ij},0)\bigr)$. It suffices to prove the inequality one pair at a time, i.e. that
$$\varepsilon^2\max(D_{ij},0) - M^2\max(-D_{ij},0) \;\le\; p_ip_j D_{ij}.$$
The hypotheses give $\varepsilon^2 \le p_ip_j \le M^2$. Since $\max(D_{ij},0)\ge0$ and $\max(-D_{ij},0)\ge0$,
$$\varepsilon^2\max(D_{ij},0) \le p_ip_j\max(D_{ij},0) \quad\text{and}\quad p_ip_j\max(-D_{ij},0) \le M^2\max(-D_{ij},0),$$
so the left side is at most $p_ip_j\bigl(\max(D_{ij},0) - \max(-D_{ij},0)\bigr) = p_ip_jD_{ij}$. Summing and invoking Theorem 3.2 completes the proof. $\square$

**Definition 7.5 (Conditioning number of a regime).** If $0 < \varepsilon\le p_i \le M$ for all $i$, the *conditioning number* of $p$ (relative to these bounds) is $\kappa = M/\varepsilon \ge 1$. It equals $1$ exactly for the balanced regime and measures how lopsided the draw is allowed to be.

**Theorem 7.6 (Triage rule).** Let $p$ satisfy $\sum_i p_i = 1$ and $0 < \varepsilon \le p_i \le M$. If
$$M^2\,\Delta(x,y) \;<\; \varepsilon^2\, C(x,y), \qquad\text{equivalently}\qquad \kappa^2 \;<\; \frac{C(x,y)}{\Delta(x,y)} \quad (\Delta > 0),$$
then $\operatorname{Cov}_p(x,y) > 0$.

*Proof.* Immediate from Theorem 7.4: the left-hand side of the budget is strictly positive, so $2\operatorname{Cov}_p > 0$. $\square$

**Remark 7.7 (Operational reading).** The threshold separates two independently available quantities:

- $C/\Delta$ is computed **once, from the population**, before any sampling. It is a shape statistic: how much of the pairwise evidence points the right way.
- $\kappa^2$ is a fact about the **sampling apparatus**: the square of the worst-case imbalance you are willing to tolerate.

If $\kappa^2 < C/\Delta$, positivity is guaranteed for *every* regime respecting those bounds — a certificate, not an estimate. Taking $\Delta = 0$ (comonotone populations, Proposition 7.3) makes the ratio infinite and recovers Theorem 4.3 for any full-support regime with $C > 0$.

**Remark 7.8 (Sharpness in the balanced case).** For the uniform regime $\varepsilon = M = 1/n$ the budget reads $C - \Delta \le 2n^2\operatorname{Cov}_{\text{unif}}$, and Proposition 7.2 shows the left-hand side is exactly $\sum_{i,j}D_{ij} = 2n^2\operatorname{Cov}_{\text{unif}}$. The budget is therefore an equality when $\kappa = 1$: the bound's dependence on the conditioning number is sharp at the balanced end, and the entire loss in Theorem 7.4 is the price of imbalance.

---

## 8. The variance-share layer

The sign of the dial is one thing; the fraction of yield variation it explains is another. We now develop the regression layer on top of the same weighted moments.

**Definition 8.1 (Weighted MSE).** For a regime $p$ and reals $a,b$,
$$\mathrm{MSE}_p(a,b) = \sum_i p_i \bigl(y_i - a - b\,x_i\bigr)^2.$$

**Lemma 8.2.** $\mathrm{MSE}_p(a,b) \ge 0$ whenever $p\ge0$; and $\operatorname{Var}_p(x) \ge 0$ whenever $p \ge 0$.

*Proof.* Both are sums of $p_i$ times a square. $\square$

**Lemma 8.3 (Centred sums vanish).** If $\sum_i p_i = 1$ then $\sum_i p_i (x_i - \mu_p(x)) = 0$.

*Proof.* Expand and use normalisation. $\square$

**Theorem 8.4 (Exact MSE decomposition).** For $\sum_i p_i = 1$,
$$\mathrm{MSE}_p(a,b) \;=\; \operatorname{Var}_p(y) \;-\; 2b\operatorname{Cov}_p(x,y) \;+\; b^2\operatorname{Var}_p(x) \;+\; \bigl(\mu_p(y) - a - b\,\mu_p(x)\bigr)^2.$$

*Proof sketch.* Write $y_i - a - bx_i = \bigl(y_i - \mu_p(y)\bigr) - b\bigl(x_i - \mu_p(x)\bigr) + \bigl(\mu_p(y) - a - b\mu_p(x)\bigr)$, square, and sum against $p_i$. The three squared terms give $\operatorname{Var}_p(y)$, $b^2\operatorname{Var}_p(x)$ and the constant square respectively; of the three cross terms, the one pairing the two centred factors gives $-2b\operatorname{Cov}_p(x,y)$, and the two involving the constant vanish by Lemma 8.3. $\square$

**Theorem 8.5 (Ordinary least squares optimum).** If $\sum_i p_i = 1$ and $\operatorname{Var}_p(x) > 0$, then with
$$b^\star = \frac{\operatorname{Cov}_p(x,y)}{\operatorname{Var}_p(x)}, \qquad a^\star = \mu_p(y) - b^\star \mu_p(x),$$
one has
$$\mathrm{MSE}_p(a^\star, b^\star) = \operatorname{Var}_p(y) - \frac{\operatorname{Cov}_p(x,y)^2}{\operatorname{Var}_p(x)},$$
and $\mathrm{MSE}_p(a,b) \ge \mathrm{MSE}_p(a^\star,b^\star)$ for all $a,b$.

*Proof sketch.* Substituting $a^\star, b^\star$ into Theorem 8.4 kills the constant square and leaves the stated value after simplification. Optimality: by Theorem 8.4,
$$\mathrm{MSE}_p(a,b) - \mathrm{MSE}_p(a^\star,b^\star) = \frac{\bigl(b\operatorname{Var}_p(x) - \operatorname{Cov}_p(x,y)\bigr)^2}{\operatorname{Var}_p(x)} + \bigl(\mu_p(y)-a-b\mu_p(x)\bigr)^2 \ \ge\ 0. \qquad\square$$

**Theorem 8.6 (Weighted Cauchy–Schwarz).** If $p\ge0$, $\sum_i p_i = 1$ and $\operatorname{Var}_p(x)>0$, then
$$\operatorname{Cov}_p(x,y)^2 \;\le\; \operatorname{Var}_p(x)\operatorname{Var}_p(y).$$

*Proof.* By Lemma 8.2 the optimal MSE of Theorem 8.5 is nonnegative, giving $\operatorname{Cov}_p^2/\operatorname{Var}_p(x)\le\operatorname{Var}_p(y)$; multiply by $\operatorname{Var}_p(x)>0$. $\square$

**Definition 8.7 (Variance share).**
$$R^2_p(x,y) = \frac{\operatorname{Cov}_p(x,y)^2}{\operatorname{Var}_p(x)\,\operatorname{Var}_p(y)}.$$

**Theorem 8.8.** For $p\ge0$ we have $R^2_p \ge 0$; and if in addition $\sum_i p_i=1$, $\operatorname{Var}_p(x)>0$, $\operatorname{Var}_p(y)>0$, then $R^2_p \le 1$.

*Proof.* Nonnegativity is clear; the upper bound is Theorem 8.6 divided by $\operatorname{Var}_p(x)\operatorname{Var}_p(y)>0$. $\square$

**Theorem 8.9 ($R^2$ is the explained fraction).** Under the hypotheses of Theorem 8.8,
$$\mathrm{MSE}_p(a^\star,b^\star) = \operatorname{Var}_p(y)\bigl(1 - R^2_p(x,y)\bigr).$$

*Proof.* Substitute Definition 8.7 into Theorem 8.5. $\square$

### 8.1 Augmentation

Comparing a dial against a baseline is best done through *augmented* fits: how much does adding the footprint improve a model that already contains something else? The gain has a closed form.

**Theorem 8.10 (Augmentation gain identity).** Let $r, z:\iota\to\mathbb R$ and let $p$ be a weighting with $\sum_i p_i z_i^2 > 0$. Set $c^\star = \bigl(\sum_j p_j r_j z_j\bigr)\big/\bigl(\sum_j p_j z_j^2\bigr)$. Then
$$\sum_i p_i\bigl(r_i - c^\star z_i\bigr)^2 \;=\; \sum_i p_i r_i^2 \;-\; \frac{\bigl(\sum_i p_i r_i z_i\bigr)^2}{\sum_i p_i z_i^2}.$$

*Proof sketch.* Expand $p_i(r_i - cz_i)^2 = p_ir_i^2 - 2c\,p_ir_iz_i + c^2 p_iz_i^2$, sum, and substitute $c = c^\star$; the cross term contributes $-2\langle r,z\rangle_p^2/\|z\|_p^2$ and the quadratic term $+\langle r,z\rangle_p^2/\|z\|_p^2$, netting $-\langle r,z\rangle_p^2/\|z\|_p^2$. $\square$

Here $\langle r,z\rangle_p = \sum_i p_i r_iz_i$ and $\|z\|_p^2 = \sum_i p_i z_i^2$ are the inner product and norm the regime induces; Theorem 8.10 is exactly the Pythagorean identity for orthogonal projection in that geometry.

**Corollary 8.11 (Strict augmentation gain).** If $\|z\|_p^2 > 0$ and $\langle r,z\rangle_p \ne 0$, then
$$\sum_i p_i(r_i - c^\star z_i)^2 \;<\; \sum_i p_i r_i^2.$$

*Proof.* The subtracted quantity in Theorem 8.10 is strictly positive. $\square$

Non-orthogonality of residual and new regressor is a *regime-computable* condition: you can check it from the sample you have. This makes Corollary 8.11 the operational justification for augmented-$R^2$ comparison.

### 8.2 Exact drivers and draw-invariant dominance

**Lemma 8.12 (Affine transport).** If $\sum_i p_i = 1$ and $\tilde y_i = a + bx_i$, then
$$\mu_p(\tilde y) = a + b\mu_p(x), \qquad \operatorname{Cov}_p(x, \tilde y) = b\operatorname{Var}_p(x), \qquad \operatorname{Var}_p(\tilde y) = b^2\operatorname{Var}_p(x).$$

*Proof.* Direct computation; each follows by substituting $\mu_p(\tilde y)$ and simplifying termwise. $\square$

**Theorem 8.13 (An exact affine driver reads full variance share in every regime).** If $\sum_i p_i = 1$, $\operatorname{Var}_p(x)>0$ and $\tilde y_i = a + bx_i$ with $b \ne 0$, then $R^2_p(x, \tilde y) = 1$.

*Proof.* By Lemma 8.12, $R^2_p = (b\operatorname{Var}_p(x))^2/(\operatorname{Var}_p(x)\cdot b^2\operatorname{Var}_p(x)) = 1$. $\square$

**Theorem 8.14 (Draw-invariant dominance).** Suppose $\tilde y_i = a + b x_i$ with $b\ne0$, $p\ge0$, $\sum_ip_i=1$, $\operatorname{Var}_p(x)>0$, $\operatorname{Var}_p(\tilde y)>0$. Then for **any** rival predictor $z$ with $\operatorname{Var}_p(z)>0$,
$$R^2_p(z, \tilde y) \;\le\; R^2_p(x, \tilde y) \;=\; 1.$$

*Proof.* Theorem 8.13 for the equality, Theorem 8.8 for the inequality. $\square$

Theorem 8.14 is the structural ceiling behind the empirical observation that a footprint-weighted dial outperforms a plain count in both balanced and unbalanced regimes: when footprint is the actual mechanism, no reweighting of the sample can promote a rival above it.

---

## 9. A worked population, and the boundary of the claim

Take four keys with

$$x = (1,\,2,\,4,\,8) \quad\text{(footprint)}, \qquad z = (1,\,1,\,2,\,2) \quad\text{(plain count)}, \qquad y = (1,\,2,\,5,\,9) \quad\text{(yield rate)},$$

and two draw regimes:
$$p = \bigl(\tfrac14,\tfrac14,\tfrac14,\tfrac14\bigr) \quad\text{(balanced)}, \qquad q = \bigl(\tfrac{7}{10},\tfrac1{10},\tfrac1{10},\tfrac1{10}\bigr) \quad\text{(genuinely unbalanced)}.$$

**Separation.** $\|p - q\|_1 = \tfrac{9}{10}$; the regimes are at total-variation distance $0.45$, about as far apart as four-point regimes with full support get in practice.

**Comonotonicity.** $x$ and $y$ are both strictly increasing along the key order, so $D_{ij}\ge0$ for all pairs; indeed $C(x,y) = 266$ and $\Delta(x,y) = 0$. By Proposition 7.3 the population is comonotone, and by Corollary 4.4 both regimes must report a strictly positive dial. They do: $\operatorname{Cov}_p(x,y) = 8.3125$ and $\operatorname{Cov}_q(x,y) = 5.47$.

**Stability check.** The ranges are $M_x = 7$ and $M_y = 8$, so Theorem 5.3 permits a drift of at most $7\cdot8\cdot0.9 = 50.4$. The actual drift is $2.8425$ — comfortably inside, as expected for a bound that must also cover adversarial populations.

**Homotopy check.** The cross term is $K(p,q) = 8.5$, and Theorem 6.5 predicts $\operatorname{Cov}_{p^t}(x,y) = (1-t)^2(8.3125) + 2t(1-t)(8.5) + t^2(5.47)$. At $t = \tfrac12$ this gives $7.695625$, which matches the direct computation to machine precision. The $\tfrac12\min$ floor of Theorem 6.7 is $2.735$; the actual minimum along the segment is $5.47$, attained at the endpoint.

**Variance shares.**

| quantity | balanced $p$ | unbalanced $q$ |
|---|---|---|
| $R^2$ of footprint dial $x$ | $0.992370$ | $0.995277$ |
| $R^2$ of plain count $z$ | $0.780645$ | $0.861544$ |
| advantage $R^2(x) - R^2(z)$ | $+0.211725$ | $+0.133732$ |

**Reading the table.** Two things happen at once, and separating them is the point of this section.

- The **ordering is stable**: the footprint dial beats the plain count in both regimes, by a wide margin in each. This is what draw-regime invariance delivers, and it is consistent with Theorem 8.14 (here $y$ is not exactly affine in $x$, but it is close, and the footprint's $R^2$ sits just below the theoretical ceiling of $1$).
- The **margin is not stable**: it drops from $0.2117$ to $0.1337$. The variance share is a *ratio* of regime-dependent quantities, and nothing in our framework makes it invariant. Claiming otherwise would be false.

This is the honest boundary of the phrase "identical within noise". What is invariant is the sign of the dial (Theorems 4.2, 4.3, Corollary 4.4), the ordering under an exact driver (Theorem 8.14), and $\ell^1$-controlled deviation of the covariance (Theorem 5.3). What is *not* invariant is the numerical variance share.

---

## 10. Algorithms

The theory yields three directly implementable procedures. Let $n = |\iota|$.

### 10.1 Pairwise dial evaluation

Given $x, y, p$, compute $\operatorname{Cov}_p(x,y)$ by either the moment form ($\Theta(n)$ time, $\Theta(1)$ extra space) or the pair form ($\Theta(n^2)$). The pair form is slower but exposes the per-pair contributions $p_ip_jD_{ij}$, which is what one needs for diagnostics: it identifies which pairs of keys carry the signal and which fight it.

### 10.2 Concordance-budget triage

**Input:** attributes $x,y$; imbalance bounds $\varepsilon \le M$.
**Output:** a certificate that $\operatorname{Cov}_p(x,y) > 0$ for every regime with $\varepsilon\le p_i\le M$, or `INCONCLUSIVE`.

Compute $D_{ij}$ for all pairs, accumulate $C = \sum\max(D_{ij},0)$ and $\Delta = \sum\max(-D_{ij},0)$ in $\Theta(n^2)$ time and $\Theta(1)$ space, then test $M^2\Delta < \varepsilon^2 C$. By Theorem 7.6 a positive test is a proof, valid for *all* admissible regimes simultaneously — no sampling is required and no regime need be specified.

### 10.3 Homotopy audit

**Input:** two regimes $p, q$, attributes $x,y$, a grid resolution $m$.
**Output:** the exact dial curve $t\mapsto\operatorname{Cov}_{p^t}(x,y)$ and its certified floor.

Compute $\operatorname{Cov}_p$, $\operatorname{Cov}_q$ and $K(p,q)$ once ($\Theta(n^2)$), then evaluate the quadratic of Theorem 6.5 at each grid point in $\Theta(1)$ apiece. Total cost $\Theta(n^2 + m)$, versus $\Theta(mn)$ for naive re-evaluation — and, more importantly, the quadratic is *exact*, so the minimum over $[0,1]$ can be obtained in closed form rather than by search: an upward parabola's vertex is at $t^\star = (\operatorname{Cov}_p - K)/(\operatorname{Cov}_p - 2K + \operatorname{Cov}_q)$ when the denominator is positive, clipped to $[0,1]$.

---

## 11. Applications

**Sampling design.** The triage rule inverts naturally into a design constraint. Given a population's $C/\Delta$, the largest tolerable conditioning number is $\kappa_{\max} = \sqrt{C/\Delta}$; any sampling scheme whose per-key inclusion masses stay within a factor $\kappa_{\max}$ of each other is guaranteed to see the signal. This is a *pre-registration-friendly* criterion: it is checkable before data collection.

**Importance sampling and reweighting.** Off-policy estimation reweights a sample to a target distribution. Theorem 5.3 bounds how much the covariance estimate can move under such a reweighting purely in terms of the $\ell^1$ shift, with no variance assumptions and no effective-sample-size heuristic.

**Robustness auditing.** Given an observed regime $q$ and a hypothetical reference $p$, the homotopy audit produces the entire family of intermediate readings exactly, exhibiting the worst case in closed form. This replaces the common practice of re-running an analysis under a handful of ad hoc reweightings.

**Rank-based analyses.** Theorem 4.6 says that the entire guarantee survives passage to ranks. In settings where absolute scales are untrustworthy — subjective ratings, censored measurements, heavy tails — one may therefore work with rank dials at no loss of the invariance.

**Diagnostics for non-monotone structure.** A large $\Delta$ relative to $C$ is a signal that the population is genuinely non-monotone, and the offending pairs are directly identifiable from the pair-form evaluation. This turns a failed triage into a localisation of the exception rather than a dead end.

---

## 12. Discussion

### 12.1 What the pair identity buys

The recurring pattern is that every result above is obtained by choosing a different way to bound the *same* nonnegative pair weights $p_ip_j$:

| bound applied to $p_ip_j$ | resulting theorem |
|---|---|
| $p_ip_j \ge 0$ | sign invariance (Thm 4.2) |
| $p_ap_b > 0$ for one pair | strict positivity (Thm 4.3) |
| $\varepsilon^2 \le p_ip_j \le M^2$ | concordance budget (Thm 7.4) |
| $\sum_{i,j}|p_ip_j - q_iq_j| \le 2\|p-q\|_1$ | $\ell^1$ stability (Thm 5.3) |
| bilinear expansion of $p^t_ip^t_j$ | exact quadratic law (Thm 6.5) |

This is the sense in which draw-regime invariance is *structural* rather than incidental: it does not depend on any property of the sampling scheme beyond nonnegativity and normalisation.

### 12.2 Scope and limitations

- **Finite populations only.** Everything is a finite sum. Extension to general probability spaces should be routine via the Hoeffding representation of covariance, but is not carried out here.
- **Comonotonicity is a real hypothesis.** It is ordinal and weak, but it is not vacuous: populations with genuine exceptions require the budget of §7, and the triage rule can return `INCONCLUSIVE`.
- **$R^2$ is not invariant.** §9 documents this explicitly. Any claim of regime invariance for a variance share needs an additional hypothesis, such as the exact-driver condition of Theorem 8.14.
- **The stability constant is conservative.** $M_xM_y$ is a worst-case range product; for populations concentrated away from their extremes it will overstate the achievable drift, as §9 illustrates.

### 12.3 Interpreting the empirical picture

The framework accounts for the qualitative observations that motivated it. Augmented variance shares that agree closely between a uniform and a balanced regime are exactly what Theorem 5.3 forces when the two regimes are close in $\ell^1$. Rank-correlation readings that stay comfortably positive in both regimes are Theorem 4.6. A footprint-weighted dial that beats a plain count in *both* regimes is the observable shadow of Theorem 8.14. And the residual regime dependence — the margin shrinking while the ordering holds — is precisely the boundary drawn in §9, not an anomaly.

---

## 13. Future directions

Three sub-conjectures suggest themselves, each sharpening one layer of the present analysis.

**1. Discordance spectrum of the pair form.** The dial is the quadratic form $p\mapsto\tfrac12 p^{\mathsf T}Dp$ with $D$ hollow symmetric. All regime dependence is carried by the behaviour of $D$ on the simplex, so dilution is an eigenvalue question rather than a sampling question. *Conjecture:* $D$ has exactly one positive eigenvalue when the population is comonotone with distinct footprints, and the ratio of the largest negative to the largest positive eigenvalue is exactly the flip threshold $C/\Delta$ up to a factor $n$. The budget theorem already isolates $C$ and $\Delta$; the missing piece is spectral.

**2. Majorization order on draw regimes.** "Unbalancedness" is arguably better measured by majorization than by $\ell^1$. *Conjecture:* for comonotone populations with $D$ entrywise monotone in the key order, $p \prec q$ implies $\operatorname{Cov}_q \le \operatorname{Cov}_p$, with equality iff $p$ and $q$ agree on the support of the concordant pairs. The pair identity makes the dial an explicit symmetric quadratic — exactly the setting where Schur-convexity criteria apply.

**3. Augmentation saturation.** Corollary 8.11 shows each new regressor strictly improves the fit by $\langle r,z\rangle_p^2/\|z\|_p^2$. *Conjecture:* the total achievable gain over an arbitrary family of footprint-derived regressors is bounded by the population's discordance mass, so that the augmented-$R^2$ plateau is a population invariant rather than an artefact of the regressor list; specifically, the supremum over finite regressor families of the augmented $R^2$ equals $1 - \Delta/(C+\Delta)$ for rank-encoded dials. Both sides are now definable in the same framework, and the inequality $\le$ should follow from the budget.

---

## 14. Conclusion

The dilution hypothesis conflates two distinct phenomena. An unbalanced draw does see a *smaller* covariance — concentration reduces spread, hence reduces the absolute magnitude of any second moment. It does not see a *weaker relationship*. The direction of association is determined by the population's pairwise concordance structure, and a draw regime contributes only nonnegative pair weights to that structure. Volume, yes; tune, no.

The pair identity $2\operatorname{Cov}_p(x,y) = \sum_{i,j}p_ip_jD_{ij}$ is the whole mechanism. It separates population from sample so cleanly that four distinct robustness questions — sign, magnitude drift, interpolation, and the effect of exceptions — each reduce to a different elementary bound on the same nonnegative weights. Any statistic admitting such a representation inherits the same inventory of guarantees.

