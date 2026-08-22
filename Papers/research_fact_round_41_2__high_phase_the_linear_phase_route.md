# Degree Ceilings for Feature Encodings: An Exact Finite-Sample Theory of Why Singleton Phase Features Cannot Detect Alignment

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

We develop an exact, finite-sample algebraic theory of incremental $R^2$ for feature encodings on product sample spaces, and use it to prove that an entire family of encodings — those built from arbitrary functions of a single coordinate — is provably blind to *alignment targets*, while an explicitly exhibited degree-two encoding predicts the same targets perfectly.

The theory rests on a single exact identity, the bias/variance/alignment split of the mean squared error of an arbitrary predictor. From it we derive: (i) that a predictor with zero empirical covariance with the target can never beat the intercept-only baseline, and is strictly worse unless constant, with excess error equal *exactly* to its own variance plus its squared mean offset; (ii) that the optimal one-feature affine model attains $R^2$ equal *exactly* to the squared empirical correlation (with the Cauchy–Schwarz inequality for the empirical covariance obtained as a by-product of the regression identity rather than assumed in advance).

Applying this calculus on a product $A \times B$, we prove that the alignment indicator $g_\sigma(a,b) = \mathbf{1}[b = \sigma(a)]$ of a bijection $\sigma$ has covariance *identically zero* with every additive predictor $u(a) + v(b)$, for arbitrary $u$ and $v$; that this persists after adjoining arbitrarily many features from an independent nuisance block; and yet that $g_\sigma$ is exactly a sum of $|A|$ products of pairs of one-hot singleton features, hence attains $R^2 = 1$ under a degree-two encoding. The general mechanism is an exact orthogonal analysis-of-variance split $\operatorname{Var} f = \operatorname{Var} f_{\mathrm{add}} + \operatorname{Var} f_{\mathrm{int}}$ valid for every target on a product space, together with the identification of the supremum of $R^2$ over all singleton encodings as the computable ratio $\operatorname{Var} f_{\mathrm{add}} / \operatorname{Var} f$ — a *degree-one ceiling* available before any model is fit. For alignment targets the additive part is constant, so the ceiling is $0$ and the unreachable excess is $100\%$.

Two further structural results complete the picture. Relabelling invariance shows that every quantity of the calculus is preserved by bijections of the sample space, so an exact null is automatically window-stable with cross-window to same-window ratio $1$; observed departures from stability are therefore evidence about estimators, not about degree-one signal. And the degree hierarchy does not terminate at two: on $G^3$ for a finite abelian group $G$, the zero-sum target $\mathbf{1}[a+b+c=0]$ has covariance exactly zero with *every* predictor assembled from arbitrary functions of pairs of coordinates, while the degree-three encoding is perfect.

The concrete consequence for the motivating empirical programme — a search for predictive gain from residues of a landmark position modulo primes $3 \le p \le 97$ — is that the small measured same-window gain of $+0.0215$ (confidence interval $[-0.0025, +0.0429]$) cannot be a population-level degree-one effect at any modulus, and that any $k$-fold joint alignment structure must return *exactly* zero population gain to every encoding of degree below $k$.

**Keywords:** incremental $R^2$; empirical covariance; alignment indicator; interaction encoding; analysis-of-variance decomposition; degree ceiling; feature encoding; finite abelian groups.

---

## 1. Introduction

### 1.1 The empirical situation

A model is fit to a finite dataset. To an existing baseline one adds a family of cheap, interpretable *phase* features: for each observation, a distinguished landmark position is reduced modulo a prime $p$, and the resulting residue is encoded — as a one-hot dummy, as $\cos(2\pi k/p)$ and $\sin(2\pi k/p)$, or in any other per-observation way. The construction is repeated across a range of primes.

In the programme that motivated this work, that range was $3 \le p \le 97$, split into a low band and a high band. The low band produced *negative* transfer. The high band produced a same-window improvement in $R^2$ of $+0.0215$, with a confidence interval of $[-0.0025, +0.0429]$ — an interval that excludes the pre-registered threshold of $+0.05$ and includes $0$ — but, unlike the low band, this small gain was *window-stable*, with a cross-window to same-window ratio of $0.92$. A secondary pre-registered criterion also failed ($0.629$ against a threshold of $0.70$).

Such a result is genuinely ambiguous under purely statistical reading. It is small and not significant; but it is stable, and stability is normally interpreted as evidence of a real effect. The question we address is whether the ambiguity can be removed by structural reasoning rather than by more data.

It can. The answer is that the relevant class of encodings is *identically* uncorrelated with the relevant class of targets — not approximately, not on average, but exactly, for every modulus and every choice of per-coordinate function. There is therefore no population effect for the estimator to be estimating, and the observed value must be estimator behaviour.

### 1.2 What this paper contributes

1. **An exact finite-sample $R^2$ calculus** (Section 3). No asymptotics, no distributional assumptions, no probability space: only averages over a finite index set. Every result is an identity or a sharp inequality with the case of equality identified.

2. **A closure theorem for singleton encodings against alignment targets** (Section 4), together with its nuisance-block-invariant form, and an explicit degree-two encoding achieving $R^2 = 1$ on the same target — a clean $0$-versus-$1$ separation.

3. **A general decomposition theorem** (Section 5): an exact orthogonal split of any target on a product space into degree-one and pure-interaction parts, with the supremum of achievable degree-one $R^2$ identified as an explicitly computable ratio. This turns "is my feature family capable of this?" into a two-pass computation performed before fitting.

4. **Relabelling invariance and window stability** (Section 6): the observation that exact nulls are automatically stable across windows, which strips stability of its evidential force in the present setting.

5. **A degree hierarchy** (Section 7): three-way alignment on a finite abelian group is orthogonal to the entire pairwise layer, giving a sharp prediction for encodings of any degree.

### 1.3 Related notions

The additive/interaction split of Section 5 is the two-factor analysis-of-variance decomposition, here derived as an exact orthogonality statement about arbitrary real functions on a finite grid rather than as a model-fitting procedure. The orthogonality of alignment indicators to marginal functions is, in the language of harmonic analysis on finite abelian groups, the statement that a "diagonal" or "zero-sum" indicator has vanishing Fourier coefficients at every character that is trivial on some coordinate. The present treatment is deliberately elementary and self-contained: everything is proved from finite sums so that the statements apply verbatim to observed data, not to an idealised population.

---

## 2. Setting and notation

Throughout, $I$ denotes a finite nonempty index set — the sample. Predictors and targets are real-valued functions on $I$.

**Definition 2.1 (Empirical mean).** For $f : I \to \mathbb{R}$,
$$\operatorname{avg} f \;=\; \frac{1}{|I|}\sum_{i \in I} f(i).$$

**Definition 2.2 (Empirical covariance and variance).** For $f, g : I \to \mathbb{R}$,
$$\operatorname{Cov}(f,g) \;=\; \operatorname{avg}(fg) \;-\; (\operatorname{avg} f)(\operatorname{avg} g), \qquad \operatorname{Var} f \;=\; \operatorname{Cov}(f,f).$$

**Definition 2.3 (Mean squared error and $R^2$).** For a target $y$ and a predictor $h$,
$$\operatorname{MSE}(y,h) \;=\; \operatorname{avg}\big((y-h)^2\big), \qquad R^2(y,h) \;=\; 1 - \frac{\operatorname{MSE}(y,h)}{\operatorname{Var} y} \quad (\operatorname{Var} y \neq 0).$$

The baseline against which $R^2$ is measured is the intercept-only model. The following elementary facts are used repeatedly and are recorded for completeness.

**Lemma 2.4 (Elementary properties).** The map $\operatorname{avg}$ is linear and fixes constants; $\operatorname{Var} f \ge 0$; $\operatorname{Var} f = 0$ if and only if $f$ is constant (equal to $\operatorname{avg} f$ everywhere); $\operatorname{Cov}(y, c) = 0$ for constant $c$; and $\operatorname{Cov}$ is symmetric and additive in each argument.

*Proof sketch.* Linearity is a rearrangement of finite sums. Writing $\operatorname{Var} f = \operatorname{avg}\big((f - \operatorname{avg} f)^2\big)$ (expand and use linearity) gives nonnegativity, and shows that vanishing variance forces the nonnegative function $(f-\operatorname{avg} f)^2$ to have zero mean, hence to vanish pointwise, since a nonnegative finite average vanishes only if every term does. $\square$

**Lemma 2.5 (Baseline calibration).** $\operatorname{MSE}(y, \operatorname{avg} y) = \operatorname{Var} y$; hence if $\operatorname{Var} y \neq 0$ the constant predictor has $R^2 = 0$. Thus "gain" always means gain over the constant model.

---

## 3. The exact incremental-$R^2$ calculus

### 3.1 The decomposition identity

**Theorem 3.1 (Exact bias/variance/alignment split).** For every target $y$ and every predictor $h$ on $I$,
$$\operatorname{MSE}(y,h) \;=\; \operatorname{Var} y \;-\; 2\operatorname{Cov}(y,h) \;+\; \operatorname{Var} h \;+\; \big(\operatorname{avg} y - \operatorname{avg} h\big)^2 .$$

*Proof sketch.* Expand $(y-h)^2 = y^2 - 2yh + h^2$ and average, using linearity, to get $\operatorname{MSE}(y,h) = \operatorname{avg}(y^2) - 2\operatorname{avg}(yh) + \operatorname{avg}(h^2)$. Substituting $\operatorname{avg}(y^2) = \operatorname{Var} y + (\operatorname{avg} y)^2$, $\operatorname{avg}(h^2) = \operatorname{Var} h + (\operatorname{avg} h)^2$ and $\operatorname{avg}(yh) = \operatorname{Cov}(y,h) + (\operatorname{avg} y)(\operatorname{avg} h)$ and collecting the pure-mean terms into the square completes the identity. $\square$

Every subsequent negative result is a specialisation of Theorem 3.1: the only channel through which a predictor can reduce error is the covariance term, and every other term is a nonnegative penalty.

### 3.2 Uncorrelated predictors are useless and strictly harmful

**Theorem 3.2 (No gain).** If $\operatorname{Cov}(y,h) = 0$ then $\operatorname{Var} y \le \operatorname{MSE}(y,h)$.

**Theorem 3.3 (Exact excess).** If $\operatorname{Cov}(y,h) = 0$ then
$$\operatorname{MSE}(y,h) - \operatorname{Var} y \;=\; \operatorname{Var} h + \big(\operatorname{avg} y - \operatorname{avg} h\big)^2 .$$

**Theorem 3.4 (Strict harm).** If $\operatorname{Cov}(y,h) = 0$ and $\operatorname{Var} h \neq 0$ then $\operatorname{Var} y < \operatorname{MSE}(y,h)$ strictly.

**Corollary 3.5.** If $\operatorname{Cov}(y,h) = 0$ and $\operatorname{Var} y > 0$ then $R^2(y,h) \le 0$.

*Proof sketches.* Set the covariance term to zero in Theorem 3.1; the remaining two terms are a variance and a square, both nonnegative, giving Theorems 3.2 and 3.3, and strict positivity of $\operatorname{Var} h$ gives Theorem 3.4. Corollary 3.5 follows by dividing by $\operatorname{Var} y > 0$. $\square$

The conceptual content is that in this exact calculus an uncorrelated feature is not neutral. Under an unregularised fit it injects its own variance into the prediction, and the injected variance is exactly the excess error. This matters for interpretation: a family of features proved uncorrelated with the target cannot generate a small positive gain by chance at the population level; it can only generate loss.

### 3.3 The single-feature ceiling and Cauchy–Schwarz

**Theorem 3.6 (Optimal affine fit).** Let $f$ be a feature with $\operatorname{Var} f > 0$. Then for all $a, b \in \mathbb{R}$,
$$\operatorname{MSE}\big(y,\; a f + b\big) \;\ge\; \operatorname{Var} y - \frac{\operatorname{Cov}(y,f)^2}{\operatorname{Var} f},$$
with equality for $a^\star = \operatorname{Cov}(y,f)/\operatorname{Var} f$ and $b^\star = \operatorname{avg} y - a^\star \operatorname{avg} f$.

*Proof sketch.* Apply Theorem 3.1 to $h = af+b$ using $\operatorname{Cov}(y, af+b) = a\operatorname{Cov}(y,f)$, $\operatorname{Var}(af+b) = a^2 \operatorname{Var} f$ and $\operatorname{avg}(af+b) = a\operatorname{avg} f + b$. The resulting expression is
$$\operatorname{Var} y - \frac{\operatorname{Cov}(y,f)^2}{\operatorname{Var} f} + \frac{\big(a \operatorname{Var} f - \operatorname{Cov}(y,f)\big)^2}{\operatorname{Var} f} + \big(\operatorname{avg} y - a \operatorname{avg} f - b\big)^2,$$
whose last two terms are nonnegative and vanish exactly at $(a^\star, b^\star)$. $\square$

**Corollary 3.7 (Cauchy–Schwarz for the empirical covariance).** For all $y, f$,
$$\operatorname{Cov}(y,f)^2 \;\le\; \operatorname{Var} y \cdot \operatorname{Var} f .$$

*Proof sketch.* If $\operatorname{Var} f = 0$ then $f$ is constant and $\operatorname{Cov}(y,f) = 0$. Otherwise the optimal error in Theorem 3.6 is a mean of squares and hence nonnegative, which is the claim after clearing the denominator. $\square$

**Theorem 3.8 (Best one-feature $R^2$ is the squared correlation).** If $\operatorname{Var} f > 0$ and $\operatorname{Var} y > 0$, then for all $a,b$
$$R^2\big(y,\, af+b\big) \;\le\; \frac{\operatorname{Cov}(y,f)^2}{\operatorname{Var} y \,\operatorname{Var} f},$$
with equality at $(a^\star, b^\star)$.

Thus the exact "dial" of a one-feature model is the squared correlation; and Theorem 3.9 below records the trivial upper endpoint.

**Theorem 3.9.** $R^2(y,y) = 1$: a predictor equal to the target has zero error.

---

## 4. Alignment targets and singleton encodings

### 4.1 The objects

Fix finite nonempty sets $A$ and $B$ and a bijection $\sigma : A \to B$; write $m = |A| = |B|$. The sample space is the product grid $A \times B$ with the uniform counting measure implicit in $\operatorname{avg}$.

**Definition 4.1 (Alignment indicator).** $g_\sigma : A \times B \to \mathbb{R}$, $\; g_\sigma(a,b) = \mathbf{1}[\, b = \sigma(a) \,]$.

**Definition 4.2 (Singleton / additive encoding).** For $u : A \to \mathbb{R}$ and $v : B \to \mathbb{R}$, the additive predictor is $(u \oplus v)(a,b) = u(a) + v(b)$.

Three remarks on the generality of Definition 4.2. First, $u$ and $v$ are *arbitrary* real functions: one-hot dummies, sinusoids of a residue, learned per-coordinate embeddings, and monotone transforms are all special cases. Second, the family is closed under sums and scalar multiples, so a linear model built on *any number* of per-coordinate features — with optimally fitted coefficients — is again a single member of the family. Third, the constant predictor is the member with $u, v$ constant, so the baseline is inside the family and the theorems below are statements about *incremental* gain.

**Lemma 4.3 (Statistics of the target).** $\operatorname{avg} g_\sigma = 1/m$ and
$$\operatorname{Var} g_\sigma = \frac{1}{m} - \frac{1}{m^2},$$
which is strictly positive whenever $m \ge 2$.

*Proof sketch.* Summing over the grid, $g_\sigma$ equals $1$ on exactly the $m$ cells of the graph of $\sigma$, out of $m^2$ cells, giving the mean. Since $g_\sigma$ is a $0/1$ indicator, $g_\sigma^2 = g_\sigma$, so $\operatorname{Var} g_\sigma = \operatorname{avg} g_\sigma - (\operatorname{avg} g_\sigma)^2$. Positivity for $m \ge 2$ is $1/m > 1/m^2$. $\square$

**Lemma 4.4 (Product structure).** If $\phi$ depends only on the first coordinate and $\psi$ only on the second, then $\operatorname{avg}(\phi) $ computed on $A\times B$ equals $\operatorname{avg}$ of $\phi$ on $A$, similarly for $\psi$, and $\operatorname{Cov}(\phi, \psi) = 0$: distinct coordinates of a product grid are empirically independent.

*Proof sketch.* The double sum factorises: $\sum_{a,b}\phi(a)\psi(b) = \big(\sum_a \phi(a)\big)\big(\sum_b \psi(b)\big)$, and dividing by $|A||B|$ gives $\operatorname{avg}(\phi\psi) = \operatorname{avg}\phi \cdot \operatorname{avg}\psi$. $\square$

### 4.2 The closure theorem

**Theorem 4.5 (The singleton route is closed, identically).** For every bijection $\sigma : A \to B$ and all functions $u : A \to \mathbb{R}$, $v : B \to \mathbb{R}$,
$$\operatorname{Cov}\big(g_\sigma,\; u \oplus v\big) \;=\; 0 .$$

*Proof sketch.* Because $g_\sigma$ is supported exactly on the graph of $\sigma$,
$$\sum_{(a,b) \in A \times B} g_\sigma(a,b)\big(u(a)+v(b)\big) = \sum_{a \in A}\big(u(a) + v(\sigma a)\big) = \sum_{a} u(a) + \sum_{b} v(b),$$
the last step because $\sigma$ is a bijection. Dividing by $|A \times B| = m^2$ gives
$$\operatorname{avg}\big(g_\sigma \cdot (u \oplus v)\big) = \frac{\sum_a u(a) + \sum_b v(b)}{m^2}.$$
On the other hand $\operatorname{avg} g_\sigma \cdot \operatorname{avg}(u \oplus v) = \frac{1}{m}\Big(\frac{\sum_a u(a)}{m} + \frac{\sum_b v(b)}{m}\Big)$, which is the same number. The covariance is their difference, hence $0$. $\square$

The proof exposes the mechanism: the graph of a bijection meets each row exactly once and each column exactly once, so restricting a marginal function to the graph and averaging returns precisely its unrestricted average. An alignment target is, from the point of view of any single coordinate, indistinguishable from a constant.

**Corollary 4.6 (No gain, strict loss, nonpositive $R^2$).** For every $\sigma, u, v$:
$$\operatorname{Var} g_\sigma \le \operatorname{MSE}\big(g_\sigma, u \oplus v\big),$$
with strict inequality whenever $u \oplus v$ is nonconstant; the excess is exactly $\operatorname{Var}(u\oplus v) + (\operatorname{avg} g_\sigma - \operatorname{avg}(u\oplus v))^2$; and if $m \ge 2$,
$$R^2\big(g_\sigma,\, u \oplus v\big) \;\le\; 0 .$$

*Proof sketch.* Combine Theorem 4.5 with Theorems 3.2–3.4, Corollary 3.5 and Lemma 4.3. $\square$

In particular the attainable gain is never the pre-registered $+0.05$, and never even $+0.0215$; the population value of the incremental $R^2$ of the entire singleton family is bounded above by zero.

**Corollary 4.7 (Individual phase features).** Taking $v \equiv 0$ (or $u \equiv 0$) shows that any single-coordinate feature $\,(a,b) \mapsto u(a)$, and likewise $(a,b)\mapsto v(b)$, has zero covariance with $g_\sigma$; by Theorem 3.8 its best affine model has $R^2 = 0$ exactly.

### 4.3 Nuisance blocks: other primes, other windows

Real feature pipelines do not add one feature; they add hundreds, drawn from many blocks. The closure survives.

**Theorem 4.8 (Nuisance-block invariance).** Let $C$ be a further finite nonempty set and consider the enlarged sample space $(A \times B) \times C$, with the target $\tilde g(x,c) = g_\sigma(x)$ depending only on the aligned block. Then for all $u, v$ and every $w : C \to \mathbb{R}$,
$$\operatorname{Cov}\Big(\tilde g,\; (x,c) \mapsto (u\oplus v)(x) + w(c)\Big) = 0,$$
and consequently $\operatorname{Var} \tilde g \le \operatorname{MSE}\big(\tilde g, (u\oplus v) + w\big)$.

*Proof sketch.* Covariance is additive in the second argument. The first part reduces to Theorem 4.5 by Lemma 4.4 (covariances of functions of the aligned block are computed inside that block), and the second part vanishes because the aligned block and the nuisance block are distinct coordinates of a product, again by Lemma 4.4. $\square$

Since $w$ is arbitrary, this covers *any* collection of features drawn from other primes, other windows, or other measurement channels, used simultaneously and fitted jointly, provided they do not couple to the aligned pair. Zero plus zero is zero.

### 4.4 The interaction layer is perfect

**Definition 4.9 (One-hot singleton features).** For $c \in A$ and $d \in B$, let $e_c(a,b) = \mathbf{1}[a=c]$ and $\varepsilon_d(a,b) = \mathbf{1}[b=d]$. These are members of the singleton family, hence individually useless by Corollary 4.7.

**Theorem 4.10 (Exact degree-two structure of the alignment target).** For all $(a,b) \in A \times B$,
$$g_\sigma(a,b) \;=\; \sum_{c \in A} e_c(a,b)\, \varepsilon_{\sigma(c)}(a,b).$$

*Proof sketch.* The $c$-th summand equals $1$ exactly when $a = c$ and $b = \sigma(c)$, and $0$ otherwise; so at most one summand is nonzero, and one is nonzero exactly when $b = \sigma(a)$. $\square$

**Theorem 4.11 (Perfect degree-two prediction).** The predictor $h_\star = \sum_{c \in A} e_c \varepsilon_{\sigma(c)}$ satisfies $\operatorname{MSE}(g_\sigma, h_\star) = 0$ and $R^2(g_\sigma, h_\star) = 1$.

**Theorem 4.12 (Separation).** Let $m \ge 2$. Then
$$\sup_{u,v} R^2\big(g_\sigma, u \oplus v\big) \le 0 \qquad \text{while} \qquad R^2\big(g_\sigma, h_\star\big) = 1 .$$

The gap is maximal. The obstruction faced by singleton encodings is not one of statistical power, sample size, or optimisation; the signal is entirely present, entirely accessible at degree two, and entirely invisible at degree one.

### 4.5 The prime windows, concretely

Specialise to $A = B = \mathbb{Z}/p\mathbb{Z}$ and $\sigma = \operatorname{id}$, giving the *diagonal alignment target* $d_p(a,b) = \mathbf{1}[a=b]$, the natural formalisation of "the two residue readouts agree at modulus $p$".

**Corollary 4.13.** For every $p \ge 2$: $\operatorname{Var} d_p = 1/p - 1/p^2 > 0$, and for all $u, v : \mathbb{Z}/p\mathbb{Z} \to \mathbb{R}$,
$$R^2\big(d_p,\; u \oplus v\big) \le 0 ,$$
while the degree-two one-hot interaction encoding attains $R^2 = 1$. In particular this holds at $p = 3$ (bottom of the low band) and $p = 97$ (top of the high band), and uniformly across the whole scanned range $3 \le p \le 97$.

This is the formal counterpart of the empirical null: a measured same-window bump of $+0.0215$ cannot be a population-level degree-one effect at any modulus in the range, because that population effect is exactly zero at every modulus in the range.

---

## 5. Where the excess lives: exact degree-one/degree-two accounting

Section 4 is a statement about one family of targets. This section explains the mechanism for *every* target on a product grid, and converts it into a computable diagnostic.

Let $A, B$ be finite nonempty sets and $f : A \times B \to \mathbb{R}$ arbitrary.

**Definition 5.1 (Marginal means).** $r_f(a) = \operatorname{avg}_{b \in B} f(a,b)$ (row mean), $\; c_f(b) = \operatorname{avg}_{a \in A} f(a,b)$ (column mean), $\; \mu_f = \operatorname{avg} f$.

**Definition 5.2 (Additive and interaction parts).**
$$f_{\mathrm{add}}(a,b) = r_f(a) + c_f(b) - \mu_f, \qquad f_{\mathrm{int}} = f - f_{\mathrm{add}} .$$
By construction $f = f_{\mathrm{add}} + f_{\mathrm{int}}$ and $f_{\mathrm{add}}$ is additive in the sense of Definition 4.2 (take $u = r_f$ and $v = c_f - \mu_f$).

**Lemma 5.3 (Zero marginals).** $\operatorname{avg} f_{\mathrm{add}} = \mu_f$, $\operatorname{avg} f_{\mathrm{int}} = 0$, and for every $a \in A$ and every $b \in B$,
$$\sum_{b' \in B} f_{\mathrm{int}}(a,b') = 0, \qquad \sum_{a' \in A} f_{\mathrm{int}}(a',b) = 0 .$$

*Proof sketch.* Averaging $f_{\mathrm{add}}$ over the grid gives $\operatorname{avg} r_f + \operatorname{avg} c_f - \mu_f = \mu_f$, since both marginal means average to the grand mean. Fixing $a$ and averaging over $b$: $\operatorname{avg}_b f(a,b) = r_f(a)$ while $\operatorname{avg}_b f_{\mathrm{add}}(a,b) = r_f(a) + \mu_f - \mu_f = r_f(a)$; the difference vanishes. Symmetrically for columns. $\square$

**Theorem 5.4 (Orthogonality of the interaction part).** For all $u : A \to \mathbb{R}$, $v : B \to \mathbb{R}$,
$$\operatorname{Cov}\big(f_{\mathrm{int}},\, u \oplus v\big) = 0 .$$
In particular $\operatorname{Cov}(f_{\mathrm{add}}, f_{\mathrm{int}}) = 0$.

*Proof sketch.* Since $\operatorname{avg} f_{\mathrm{int}} = 0$ the covariance is $\operatorname{avg}(f_{\mathrm{int}} \cdot (u\oplus v))$. Splitting the grid sum, $\sum_{a,b} f_{\mathrm{int}}(a,b) u(a) = \sum_a u(a) \sum_b f_{\mathrm{int}}(a,b) = 0$ by the row identity, and symmetrically the $v$-term vanishes by the column identity. The special case follows because $f_{\mathrm{add}}$ is additive. $\square$

**Theorem 5.5 (Exact variance budget).** $\;\operatorname{Var} f = \operatorname{Var} f_{\mathrm{add}} + \operatorname{Var} f_{\mathrm{int}}$, with no cross term.

*Proof sketch.* $\operatorname{Var}(g+h) = \operatorname{Var} g + 2\operatorname{Cov}(g,h) + \operatorname{Var} h$ by bilinearity, and the cross term vanishes by Theorem 5.4. $\square$

**Theorem 5.6 (Best additive predictor).** For all $u, v$,
$$\operatorname{MSE}\big(f,\, u \oplus v\big) \;\ge\; \operatorname{Var} f_{\mathrm{int}},$$
and equality holds for $u \oplus v = f_{\mathrm{add}}$: $\;\operatorname{MSE}(f, f_{\mathrm{add}}) = \operatorname{Var} f_{\mathrm{int}}$.

*Proof sketch.* Write $f - (u\oplus v) = f_{\mathrm{int}} + \big(f_{\mathrm{add}} - (u \oplus v)\big)$, where the bracket is additive. Expanding the mean square gives $\operatorname{avg}(f_{\mathrm{int}}^2)$ plus twice a term of the form $\operatorname{avg}\big(f_{\mathrm{int}} \cdot \text{additive}\big)$, which vanishes by the zero-marginal identities of Lemma 5.3, plus the nonnegative mean square of the additive discrepancy. Since $\operatorname{avg} f_{\mathrm{int}} = 0$, $\operatorname{avg}(f_{\mathrm{int}}^2) = \operatorname{Var} f_{\mathrm{int}}$. Equality is attained when the additive discrepancy vanishes. $\square$

**Theorem 5.7 (The degree-one ceiling).** Suppose $\operatorname{Var} f > 0$. Then for all $u, v$,
$$R^2\big(f,\, u \oplus v\big) \;\le\; \frac{\operatorname{Var} f_{\mathrm{add}}}{\operatorname{Var} f},$$
and the bound is attained by $u \oplus v = f_{\mathrm{add}}$. Equivalently,
$$\sup_{u,v} R^2\big(f, u\oplus v\big) \;=\; \frac{\operatorname{Var} f_{\mathrm{add}}}{\operatorname{Var} f}, \qquad \text{unreachable excess} \;=\; \frac{\operatorname{Var} f_{\mathrm{int}}}{\operatorname{Var} f}.$$

*Proof sketch.* Divide Theorem 5.6 by $\operatorname{Var} f$ and use the budget of Theorem 5.5:
$R^2 = 1 - \operatorname{MSE}/\operatorname{Var} f \le 1 - \operatorname{Var} f_{\mathrm{int}}/\operatorname{Var} f = \operatorname{Var} f_{\mathrm{add}}/\operatorname{Var} f$. $\square$

Theorem 5.7 is the practical heart of the paper. The ceiling depends on the target and on the grid only — not on which singleton features one has thought of, nor on the estimator, nor on regularisation. It is computed in two passes over the data (row means and column means), and it caps *every* member of the degree-one family simultaneously.

**Theorem 5.8 (Alignment targets have ceiling zero).** For the alignment indicator $g_\sigma$ on $A \times B$ with $m = |A| = |B| \ge 2$: every row mean and every column mean equals $1/m$, hence
$$(g_\sigma)_{\mathrm{add}} \equiv \frac{1}{m} \;\text{ is constant}, \qquad \operatorname{Var} (g_\sigma)_{\mathrm{add}} = 0, \qquad \frac{\operatorname{Var} (g_\sigma)_{\mathrm{add}}}{\operatorname{Var} g_\sigma} = 0, \qquad \operatorname{Var}(g_\sigma)_{\mathrm{int}} = \operatorname{Var} g_\sigma .$$

*Proof sketch.* Each row of the grid contains exactly one aligned cell, so $r_{g_\sigma}(a) = 1/m$ for all $a$; symmetrically for columns since $\sigma$ is a bijection. Then $f_{\mathrm{add}} = 1/m + 1/m - 1/m = 1/m$. Apply Theorem 5.5 for the last claim. $\square$

Thus Theorem 4.5 is not an accident of alignment indicators but the extreme case of a general accounting identity: alignment targets are $100\%$ interaction. The results of Section 4 are corollaries of Section 5, and the ceiling gives a *quantitative* version applicable to targets that are only partly relational.

---

## 6. Relabelling invariance: exact nulls are automatically window-stable

**Theorem 6.1 (Invariance under relabelling).** Let $e : J \to I$ be a bijection of finite nonempty index sets. Then for all $y, h : I \to \mathbb{R}$,
$$\operatorname{avg}(y \circ e) = \operatorname{avg} y, \quad \operatorname{Cov}(y\circ e, h \circ e) = \operatorname{Cov}(y,h), \quad \operatorname{Var}(y \circ e) = \operatorname{Var} y,$$
$$\operatorname{MSE}(y\circ e, h \circ e) = \operatorname{MSE}(y,h), \qquad R^2(y \circ e, h\circ e) = R^2(y,h).$$

*Proof sketch.* Reindexing a finite sum along a bijection preserves it, and $|J| = |I|$. Each identity is that observation applied to the relevant summand. $\square$

**Corollary 6.2 (Stability of a null).** If a family of encodings has population $R^2$ equal to $0$ on one window, and a second window is a relabelling of the first with the same target law, then the population $R^2$ on the second window is also $0$, so the cross-window to same-window ratio of the *population* quantity is exactly $1$ — as it is for a genuine nonzero effect.

The methodological consequence is important and easily overlooked. In the motivating programme, the small high-band gain was distinguished from the low band by being *window-stable* (ratio $0.92$), and stability was read as weak evidence of reality. Corollary 6.2 shows that stability does not discriminate: an exact null is perfectly stable too. What discriminates is the *level*, and Corollary 4.13 fixes the level at $\le 0$. A stable $+0.02$ against a provable population ceiling of $0$ is a description of estimator behaviour — finite-sample fitting of noise reproducing itself across windows drawn from the same distribution — and not a description of signal.

---

## 7. The degree hierarchy does not stop at two

Section 4 exhibits a target invisible at degree one and perfectly visible at degree two. The same mechanism generates targets invisible at degree two.

Let $G$ be a finite abelian group with $N = |G| \ge 2$ (canonically $G = \mathbb{Z}/p\mathbb{Z}$), and work on the grid $G \times G \times G$.

**Definition 7.1 (Three-way alignment).** $\;t(a,b,c) = \mathbf{1}[\,a + b + c = 0\,]$.

**Definition 7.2 (Pairwise, i.e. degree-$\le 2$, encodings).** For arbitrary $F, H, K : G \times G \to \mathbb{R}$,
$$P_{F,H,K}(a,b,c) = F(a,b) + H(b,c) + K(a,c).$$
This family contains all degree-one encodings (take $F(a,b) = u(a) + v(b)$, etc.) and the entire interaction layer that solved the two-coordinate problem.

**Lemma 7.3 (Statistics of $t$).** $\operatorname{avg} t = 1/N$ and $\operatorname{Var} t = 1/N - 1/N^2 > 0$.

*Proof sketch.* For each of the $N^2$ choices of $(a,b)$ there is exactly one $c = -(a+b)$ with $t = 1$; so $t$ has $N^2$ ones out of $N^3$ cells. Idempotence of the indicator gives the variance as in Lemma 4.3. $\square$

**Theorem 7.4 (The whole pairwise layer is blind).** For all $F, H, K$,
$$\operatorname{Cov}\big(t,\; P_{F,H,K}\big) = 0 .$$

*Proof sketch.* Treat the three terms separately. For the $F$-term, summing $t(a,b,c)F(a,b)$ over the grid: for each pair $(a,b)$ exactly one $c$ contributes, so the sum is $\sum_{a,b} F(a,b)$; dividing by $N^3$ gives $\operatorname{avg}(tF) = \frac{1}{N}\operatorname{avg} F = \operatorname{avg} t \cdot \operatorname{avg} F$, so this term contributes zero covariance. The $H$-term and $K$-term are handled identically, using that for each fixed pair of coordinates the remaining coordinate is uniquely determined. Summing the three zero contributions gives the claim. $\square$

Conceptually: conditioning on *any* two of the three coordinates leaves the conditional mean of $t$ equal to the constant $1/N$. A function that omits at least one coordinate cannot detect a target whose conditional mean is flat in exactly that direction.

**Theorem 7.5 (Degree-three separation).** For $N \ge 2$: every pairwise encoding has $R^2(t, P_{F,H,K}) \le 0$, while the degree-three encoding — the joint indicator $t$ itself — has $R^2(t,t) = 1$. In particular this holds at $N = 97$.

**Conjecture / prediction 7.6 (Degree-$k$ blindness).** On $G^k$, the zero-sum indicator $\mathbf{1}[a_1 + \cdots + a_k = 0]$ has covariance exactly $0$ with every function that omits at least one coordinate; hence every encoding of degree $< k$ attains population $R^2 \le 0$, while the degree-$k$ encoding attains $R^2 = 1$. The cases $k = 2$ and $k = 3$ are Theorems 4.5 and 7.4, whose proofs share a single template: conditioning on $k-1$ coordinates leaves the target's conditional mean constant at $1/N$.

This is the sharp, falsifiable prediction the theory offers to an experimental programme. If the unexplained excess in a dataset is a $k$-fold joint alignment, then increasing the number of primes, the number of windows, or the sample size will not help; only *raising the degree past $k-1$* will, and when it does, the improvement will be abrupt rather than gradual.

---

## 8. Algorithms

The theory is constructive and cheap. We record the three computations it licenses.

### 8.1 The degree-one ceiling

**Input:** a target $f$ tabulated on an $|A| \times |B|$ grid (or an empirical table of $(a,b,y)$ triples aggregated to cell means).
**Output:** the exact supremum of $R^2$ over all singleton encodings.

1. Compute the grand mean $\mu$, the row means $r(a)$, the column means $c(b)$. Cost $O(|A||B|)$ time, $O(|A|+|B|)$ extra space.
2. Form $f_{\mathrm{add}}(a,b) = r(a) + c(b) - \mu$ implicitly, and accumulate $\operatorname{Var} f$ and $\operatorname{Var} f_{\mathrm{add}}$ in a second pass. Cost $O(|A||B|)$.
3. Return $\operatorname{Var} f_{\mathrm{add}} / \operatorname{Var} f$, and the excess $1$ minus that.

Two linear passes replace an unbounded search over feature engineering. The output is exact, and by Theorem 5.7 it is attained.

### 8.2 Certified futility check for a proposed encoding

**Input:** a target $f$ and a candidate predictor $h$ on the same grid.
**Output:** either the exact achievable improvement, or a certificate of harm.

1. Compute $\operatorname{Cov}(f,h)$, $\operatorname{Var} h$, $\operatorname{avg} f$, $\operatorname{avg} h$. Cost $O(|I|)$.
2. If $\operatorname{Cov}(f,h) = 0$, report by Theorem 3.3 the exact excess error $\operatorname{Var} h + (\operatorname{avg} f - \operatorname{avg} h)^2$, i.e. certified nonpositive $R^2$, strictly negative when $\operatorname{Var} h > 0$.
3. Otherwise report the optimal single-feature $R^2$, $\operatorname{Cov}(f,h)^2 / (\operatorname{Var} f \operatorname{Var} h)$, exact by Theorem 3.8.

### 8.3 Degree ladder scan

**Input:** a target on a $k$-coordinate grid and a maximum degree $D$.
**Output:** for each degree $d \le D$, the achievable $R^2$ of the best encoding of that degree.

Project the target orthogonally onto the span of functions depending on at most $d$ coordinates (for $d = 1$ this is $f_{\mathrm{add}}$; in general it is the truncated functional analysis-of-variance expansion), and report the ratio of the projected variance to the total. The ladder is monotone in $d$, and by Theorem 7.5 it can be flat at $0$ up to $d = k-1$ and jump to $1$ at $d = k$: the profile of the jump identifies the interaction order of the underlying structure.

---

## 9. Discussion

### 9.1 What the theory settles

The motivating question — whether a stable $+0.0215$ is signal — is settled in the negative *for the stated class of encodings*, and settled by an identity rather than by a test. There is no population effect of degree one against an alignment target at any modulus. Three logically distinct escape routes were closed:

* more per-coordinate features, or richer functions of a residue: closed by the arbitrariness of $u$ and $v$ in Theorem 4.5 and by closure of the additive family under sums;
* features drawn from other primes or windows, added alongside: closed by Theorem 4.8;
* the appeal to window stability as corroboration: defused by Corollary 6.2.

### 9.2 What the theory does not settle

The theorems concern alignment-type targets. If the true target is not purely relational, the correct statement is quantitative rather than binary, and Theorem 5.7 supplies the exact number: the achievable degree-one $R^2$ equals the variance fraction carried by the marginal means. A target could perfectly well have a ceiling of, say, $0.05$; the theory then predicts that a good degree-one encoding reaches it and no more.

Nor does the theory assert that the residual excess in the motivating dataset *is* a joint alignment. It narrows the candidates: either an interaction or joint-alignment encoding of degree at least two, or a property intrinsic to the family of objects rather than to any positional readout.

### 9.3 Estimation versus population

There is an instructive tension worth spelling out. At the population level an uncorrelated feature has $R^2 \le 0$ (Corollary 3.5). Yet finite-sample *training* $R^2$ for such a feature is typically positive: the fitted coefficient absorbs sampling covariance. Out of sample it reverts. The results here apply to the exact quantities computed on whatever finite grid one declares the sample space to be — so the correct reading of a small measured out-of-sample gain against a proven zero ceiling is that the estimator has not fully reverted, for instance because the evaluation windows share structure with the fitting window. This is precisely why relabelling invariance (Section 6) matters: it removes stability from the evidence column.

### 9.4 Practical guidance

Compute the ceiling before engineering the features. The diagnostic of Section 8.1 costs two passes and answers, exactly, a question that is otherwise attacked by an unbounded sequence of experiments. When the ceiling is zero, the honest conclusion is that the feature family is structurally incapable, and the productive response is to raise the degree, not the sample size.

---

## 10. Future directions

**Degree-$k$ blindness for $k$-fold alignment.** Prove Conjecture 7.6 in general: the zero-sum indicator on $G^k$ is orthogonal to every function omitting a coordinate, because conditioning on any $k-1$ coordinates leaves the conditional mean at the constant $1/N$. The cases $k=2,3$ are established here by the same proof template; the general statement is the sharp prediction to test against the next encoding round before committing compute.

**Ceiling arithmetic for composite moduli.** The isomorphism $\mathbb{Z}/pq\mathbb{Z} \cong \mathbb{Z}/p\mathbb{Z} \times \mathbb{Z}/q\mathbb{Z}$ converts a single-modulus alignment into a two-block alignment; the resulting ceiling arithmetic should predict how gains compose (or fail to compose) across coprime moduli, and whether composite-modulus encodings can imitate a degree-two encoding at degree one.

**Partial alignment and noisy graphs.** Replace the graph of a bijection with a relation of controlled density, or with a bijection observed through noise, and track how the ceiling $\operatorname{Var} f_{\mathrm{add}} / \operatorname{Var} f$ grows away from zero. This yields a continuous interpolation between the fully relational and the fully marginal regimes, and a calibration curve for interpreting small measured gains.

**Estimator-side theory.** Quantify the finite-sample distribution of measured incremental $R^2$ under a proven zero ceiling, so that observed values such as $+0.0215$ with cross/same ratio $0.92$ can be predicted rather than merely explained away.

**Beyond squared error.** Extend the exact accounting from the mean squared error to other proper losses; the orthogonality arguments used here are Hilbert-space arguments on the finite grid, and their analogues for Bregman divergences would broaden the reach of the ceiling diagnostic.
