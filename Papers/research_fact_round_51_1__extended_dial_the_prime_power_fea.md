# The Moment Geometry of an Absent Increment

### Why incremental explanatory power fails to replicate while every marginal diagnostic remains stable

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

We study the finite-population geometry of *incremental* explanatory power: the quantity
$\Delta R^2(z\mid x)$ by which a candidate feature $z$ raises the variance share of a
regression that already contains a baseline predictor $x$. The investigation is motivated by
a concrete empirical failure. A validated baseline dial — a footprint predictor of a yield
rate — was augmented by a prime-power indicator feature, and the augmentation was reported to
add $+0.089$ of explained variance on one population. On five fresh populations the increment
was indistinguishable from zero, with augmented readings $0.490$, $0.555$, $0.428$, $0.532$,
$0.508$ (mean $0.502$, one of five above a $0.55$ target), while every marginal diagnostic —
the baseline dial, the marginal feature dial, and a transfer slope of $0.898$ — replicated
normally.

We show that this pattern is not a statistical accident but a structural consequence of what
an increment is. Our results are: (i) an exact decomposition
$\Delta R^2 = (1 - R^2_{\text{base}})\,\rho_{\text{partial}}^2$ in the weighted
finite-population setting; (ii) a closed moment formula proving that
$\Delta R^2 \cdot \sigma_{yy}$ is a rational function of exactly five second moments, whence
two populations agreeing on those five moments — on different key sets, under different draw
regimes — report identical increments; (iii) an exact characterisation of the *absence locus*
as the quadric $\sigma_{zy}\sigma_{xx} = \sigma_{xy}\sigma_{xz}$, together with the fact that,
as a set of rate profiles, it is a hyperplane of codimension exactly one; (iv) a *sign-masking*
construction: two four-key populations agreeing on every marginal reading and differing only
in the sign of $\sigma_{zy}$, with increments $80/149 \approx 0.537$ and $0$; (v) a
*marginal-present, incremental-absent* population where the feature is comonotone with the
rate — hence has strictly positive marginal covariance under *every* full-support draw regime
— and yet contributes exactly zero over an unsaturated baseline; (vi) two quantitative
ceilings, a collinearity-defect bound and a sparsity bound $\mathcal{G} \le B^2\delta$ for
$0/1$ features; and (vii) exoneration of two candidate confounds, regime drift (a quadratic
stability bound) and slope decay (attenuation is forced, and $0.898$ lies in the predicted
band). Together these results replace the narrative "the effect was noise" with the sharper
statement: *absence is exact, codimension-one, second-moment-determined, and invisible to
every marginal diagnostic in the report.*

**Keywords:** incremental variance share, partial correlation, suppression, moment geometry,
prime-power indicator, replication, weighted least squares, codimension.

---

## 1. Introduction

### 1.1 The empirical problem

A predictive dial maps a structural *footprint* of a key to a predicted *yield rate*. Such a
dial had been validated across populations in its baseline form. An augmented form was then
proposed: add, as a second predictor, the indicator of whether the key index is a prime power
$p^k$. On the population where it was first tried, the augmentation raised the explained
variance share by $+0.089$.

Five fresh populations were then drawn. The augmented model's variance shares came in at
$$0.490,\quad 0.555,\quad 0.428,\quad 0.532,\quad 0.508,$$
with mean $0.502$ and exactly one reading above the $0.55$ target. The incremental
contribution of the prime-power feature was, in each case, approximately zero. Meanwhile the
baseline dial replicated, the marginal association between the feature and the rate
replicated, and the transfer slope measured $0.898$, within its expected band. A combined
model reached $R^2 = 0.634$ at a different operating point, but the prime-power ingredient
contributed nothing to it.

The methodological question this raises is general, and this paper answers it: *what kind of
object is an increment, such that it can vanish uniformly on fresh populations while every
other reported statistic is stable?*

### 1.2 Contributions and organisation

Section 2 fixes the finite-population framework. Section 3 develops the gain functional and
the optimality certificate that makes "the residual" well defined. Section 4 treats
partialling, its duality, and the exact increment identity. Section 5 is the heart: the closed
moment formula, moment sufficiency, and the absence quadric. Section 6 gives the codimension
count. Section 7 gives the two explicit populations — sign-masking and
marginal-present/incremental-absent. Section 8 gives the two ceilings, collinearity and
sparsity. Section 9 exonerates regime drift and explains the transfer slope. Section 10
returns to the data with a falsification bound. Sections 11–12 discuss consequences,
algorithms, and open directions.

---

## 2. The finite-population framework

Throughout, $\iota$ is a finite index set of *keys*, $|\iota| = n$.

> **Definition 2.1 (Draw regime).** A *draw regime* on $\iota$ is a vector
> $p = (p_i)_{i \in \iota}$ with $p_i \ge 0$ and $\sum_i p_i = 1$. It is *full-support* if
> $p_i > 0$ for all $i$. The *uniform regime* $p^{U}$ assigns $1/n$ to each key.

> **Definition 2.2 (Weighted moments).** For $f, g : \iota \to \mathbb{R}$ set
> $$\bar f = \sum_i p_i f_i, \qquad
> \langle f, g\rangle_p = \sum_i p_i f_i g_i, \qquad
> \sigma_{fg} = \sum_i p_i (f_i - \bar f)(g_i - \bar g),$$
> and $\sigma_{ff} = \operatorname{Var}_p f$. We drop the subscript $p$ on the inner product
> when the regime is clear, and write $\|f\|^2 = \langle f, f\rangle$.

The inner product is symmetric, bilinear, and positive semidefinite; in particular the
weighted Cauchy–Schwarz inequality
$$\langle f, g\rangle^2 \le \|f\|^2\,\|g\|^2$$
holds for every draw regime, and follows from the pointwise identity
$(p_i f_i g_i)^2 = (p_i f_i^2)(p_i g_i^2)$ together with the discrete Cauchy–Schwarz
inequality.

> **Definition 2.3 (Variance share).** For a predictor $x$ and a rate $y$ with
> $\sigma_{xx}, \sigma_{yy} > 0$,
> $$R^2(x, y) = \frac{\sigma_{xy}^2}{\sigma_{xx}\,\sigma_{yy}}.$$

> **Definition 2.4 (Weighted error).** For $a, b \in \mathbb{R}$,
> $\mathrm{MSE}(a,b) = \sum_i p_i (y_i - a - b x_i)^2$.

Two features are named once and for all: the **footprint** $x$ (the validated baseline
predictor, written $w$ in the numerical examples) and the candidate **feature** $z$ (the
prime-power indicator, written $\mathrm{pp}$).

---

## 3. The gain functional and its exact algebra

### 3.1 Residuals as certified optima

> **Definition 3.1 (Residual).** A function $r : \iota \to \mathbb{R}$ is a *residual for $x$
> under $p$* if it satisfies the normal equations
> $$\sum_i p_i r_i = 0 \qquad\text{and}\qquad \langle r, x\rangle = 0 .$$

> **Theorem 3.2 (Optimality certificate).** Suppose $y_i = a + b x_i + r_i$ for all $i$, where
> $r$ is a residual for $x$ under $p$. Then $(a,b)$ is a *global* least-squares optimum: for
> all $a', b'$, $\mathrm{MSE}(a,b) \le \mathrm{MSE}(a',b')$.

*Proof sketch.* Expand $\mathrm{MSE}(a',b')$ around the decomposition. Writing
$\delta_i = (a - a') + (b - b')x_i$, one gets
$$\mathrm{MSE}(a',b') = \|r\|^2 + 2(a-a')\textstyle\sum_i p_i r_i + 2(b-b')\langle r,x\rangle
+ \sum_i p_i \delta_i^2 .$$
The two cross terms vanish by the normal equations, and the last term is a nonnegative
weighted sum of squares. $\square$

Theorem 3.2 is what makes the phrase "the residual" unambiguous: any decomposition satisfying
the normal equations certifies its own optimality, in every draw regime simultaneously.

### 3.2 The gain

> **Definition 3.3 (Augmentation gain).** For a residual $r$ and a feature $z$ with
> $\|z\|^2 > 0$,
> $$\mathcal{G}(r, z) = \frac{\langle r, z\rangle^2}{\|z\|^2}.$$

> **Theorem 3.4 (Gain is the residual drop).** With $c = \langle r,z\rangle/\|z\|^2$,
> $$\sum_i p_i (r_i - c z_i)^2 = \|r\|^2 - \mathcal{G}(r, z).$$
> In particular $0 \le \mathcal{G}(r,z) \le \|r\|^2$.

*Proof sketch.* Expand the square and substitute the optimal coefficient $c$; the cross term
is $-2c\langle r,z\rangle$ and the quadratic term is $c^2\|z\|^2$, and the two combine to
$-\langle r,z\rangle^2/\|z\|^2$. $\square$

> **Proposition 3.5 (Exact vanishing).** If $\|z\|^2 > 0$ then
> $\mathcal{G}(r,z) = 0 \iff \langle r, z\rangle = 0$.

Absence of contribution is therefore *residual orthogonality*, an equation, not an
approximation.

### 3.3 Collinearity annihilates the gain

> **Lemma 3.6 (Residual blindness).** If $r$ is a residual for $x$, then for all
> $a, b \in \mathbb{R}$ and every $v : \iota \to \mathbb{R}$,
> $$\langle r, \; a + b x + v\rangle = \langle r, v\rangle .$$

*Proof sketch.* Expand by bilinearity into $a\sum_i p_i r_i + b\langle r,x\rangle +
\langle r,v\rangle$ and kill the first two terms with the normal equations. $\square$

> **Corollary 3.7 (Perfect collinearity).** If $z_i = a + b x_i$ for all $i$, then
> $\mathcal{G}(r, z) = 0$.

> **Theorem 3.8 (Collinearity-defect ceiling).** Let $r$ be a residual for $x$, let
> $\|z\|^2 > 0$, and let $a, b$ be arbitrary. Writing $d_i = z_i - (a + b x_i)$,
> $$\mathcal{G}(r,z) \;\le\; \|r\|^2 \cdot \frac{\|d\|^2}{\|z\|^2}.$$

*Proof sketch.* By Lemma 3.6, $\langle r, z\rangle = \langle r, d\rangle$; apply Cauchy–Schwarz
to $\langle r, d\rangle$ and divide by $\|z\|^2$. $\square$

The ratio $\|d\|^2/\|z\|^2$, minimised over $(a,b)$, is the *relative collinearity defect* of
$z$ against the footprint. A feature that is nearly an affine function of the footprint is
provably nearly useless in every population: no noise story is needed to explain a small
increment.

### 3.4 Gains are sequential, not additive

> **Theorem 3.9 (Sequential decomposition).** Let $z, w$ be features with $\|z\|^2, \|w\|^2 >
> 0$. Put $c = \langle r,z\rangle/\|z\|^2$, $r' = r - cz$, $d = \langle r',w\rangle/\|w\|^2$.
> Then
> $$\sum_i p_i (r'_i - d w_i)^2 = \|r\|^2 - \mathcal{G}(r, z) - \mathcal{G}(r', w).$$

*Proof sketch.* Apply Theorem 3.4 twice, first to $(r, z)$ and then to $(r', w)$. $\square$

The second summand is the gain of $w$ against the *adjusted* residual, not against $r$. This
is the formal reason why a feature validated in isolation may evaporate inside a combined
model: its marginal gain and its sequential gain are different numbers.

---

## 4. Partialling and the exact increment identity

The statistic an experiment reports is the increment of the *multiple* variance share. That
is the gain not of $z$ but of the part of $z$ the footprint cannot express.

> **Definition 4.1 (Partialled feature).** $\tilde z$ is a *partialling of $z$ against $x$
> under $p$* if $\tilde z$ is a residual for $x$ and there exist $a, b$ with
> $z_i = a + b x_i + \tilde z_i$ for all $i$.

> **Theorem 4.2 (Weighted Pythagoras).** If $\tilde z$ partials $z$, then
> $\|\tilde z\|^2 \le \|z\|^2$.

*Proof sketch.* The explainable part $a + bx$ and $\tilde z$ are orthogonal by the normal
equations, so $\|z\|^2 = \|a + bx\|^2 + \|\tilde z\|^2$. $\square$

> **Theorem 4.3 (Duality of partialling).** Let $r$ be a residual for $x$ and $\tilde z$ a
> partialling of $z$. Then
> $$\langle r, z\rangle = \langle r, \tilde z\rangle,$$
> and if moreover $y = a' + b'x + r$ then also $\langle r, z\rangle = \langle y, \tilde z\rangle$.

*Proof sketch.* Both statements are Lemma 3.6 applied on the appropriate side: $r$ ignores the
affine-in-$x$ part of $z$, and $\tilde z$ ignores the affine-in-$x$ part of $y$. $\square$

Duality says the partial covariance can be computed by residualising *either* side, and that
it is a linear functional of the raw rate profile $y$ — a fact used decisively in Section 6.

> **Definition 4.4 (Partialled gain).**
> $\widetilde{\mathcal{G}}(r, \tilde z) = \langle r, \tilde z\rangle^2 / \|\tilde z\|^2$. This equals
> $\Delta R^2(z \mid x) \cdot \sigma_{yy}$.

> **Proposition 4.5.** If $\|\tilde z\|^2 > 0$ then $\mathcal{G}(r,z) \le
> \widetilde{\mathcal{G}}(r,\tilde z)$; and if additionally $\|z\|^2 > 0$, the two vanish
> simultaneously.

*Proof sketch.* The numerators coincide by Theorem 4.3, and the denominator only shrinks by
Theorem 4.2. Vanishing of either is equivalent to $\langle r, \tilde z\rangle = 0$. $\square$

So the crude and honest statistics agree on the qualitative claim "the feature contributes
nothing", and the crude statistic is always a valid lower bound.

> **Theorem 4.6 (Unexplained share).** If $y = a + bx + r$ with $r$ a residual for $x$, and
> $\sigma_{xx}, \sigma_{yy} > 0$, then
> $$1 - R^2(x,y) = \frac{\|r\|^2}{\sigma_{yy}}.$$

*Proof sketch.* From the decomposition, $\sigma_{xy} = b\,\sigma_{xx}$ and
$\sigma_{yy} = b^2\sigma_{xx} + \|r\|^2$ (the cross term vanishes because $\sigma_{xr} = 0$).
Substituting into $R^2 = \sigma_{xy}^2/(\sigma_{xx}\sigma_{yy})$ gives
$R^2 = b^2\sigma_{xx}/\sigma_{yy}$, and the claim follows. $\square$

> **Theorem 4.7 (Exact increment identity).** Under the hypotheses of Theorem 4.6, with
> $\|r\|^2 > 0$ and $\|\tilde z\|^2 > 0$,
> $$\Delta R^2(z\mid x) \;=\; \bigl(1 - R^2(x,y)\bigr)\cdot
> \frac{\langle r,\tilde z\rangle^2}{\|r\|^2\,\|\tilde z\|^2}
> \;=\; \bigl(1 - R^2_{\text{base}}\bigr)\cdot\rho_{\text{partial}}^2 .$$

*Proof sketch.* Divide Definition 4.4 by $\sigma_{yy}$ and substitute Theorem 4.6. $\square$

**Interpretation.** The increment is the product of *headroom* and *partial correlation*.
Both are population statistics, and each can move independently between populations. In
particular a perfectly replicated baseline dial pins down only the first factor and says
nothing at all about the second.

---

## 5. Moment geometry: what the increment sees

### 5.1 Closed forms

> **Theorem 5.1 (Partial covariance in moment form).** Let $\sum_i p_i = 1$, let
> $y = a + bx + r$ with $r$ a residual for $x$, and let $\sigma_{xx} > 0$. Then for any feature
> $z$,
> $$\langle r, z\rangle = \sigma_{zy} - \frac{\sigma_{xy}\,\sigma_{xz}}{\sigma_{xx}}.$$

*Proof sketch.* Since $r$ is centred, $\langle r,z\rangle = \sigma_{rz}$. Covarying the
decomposition $y = (a + bx) + r$ with $z$ gives $\sigma_{zy} = b\,\sigma_{xz} + \sigma_{rz}$,
while $\sigma_{xy} = b\,\sigma_{xx}$ gives $b = \sigma_{xy}/\sigma_{xx}$. Eliminate $b$.
$\square$

> **Theorem 5.2 (Partialled energy in moment form).** If $\tilde z$ partials $z$ against $x$
> and $\sigma_{xx} > 0$, then
> $$\|\tilde z\|^2 = \sigma_{zz} - \frac{\sigma_{xz}^2}{\sigma_{xx}}.$$

*Proof sketch.* Write $z = (a + bx) + \tilde z$. Then $\sigma_{xz} = b\,\sigma_{xx}$ and
$\sigma_{zz} = b^2\sigma_{xx} + \|\tilde z\|^2$, using $\sigma_{x\tilde z} = 0$ and the fact
that $\tilde z$ is centred. Eliminate $b$. $\square$

> **Theorem 5.3 (Moment formula for the increment).** Under the hypotheses above,
> $$\widetilde{\mathcal{G}}(r,\tilde z)
> = \frac{\left(\sigma_{zy} - \dfrac{\sigma_{xy}\sigma_{xz}}{\sigma_{xx}}\right)^{2}}
> {\sigma_{zz} - \dfrac{\sigma_{xz}^{2}}{\sigma_{xx}}},
> \qquad
> \Delta R^2(z\mid x) = \frac{1}{\sigma_{yy}}\cdot
> \frac{\bigl(\sigma_{zy}\sigma_{xx} - \sigma_{xy}\sigma_{xz}\bigr)^{2}}
> {\sigma_{xx}\bigl(\sigma_{zz}\sigma_{xx} - \sigma_{xz}^{2}\bigr)} .$$

*Proof sketch.* Combine Theorems 4.3, 5.1 and 5.2 in Definition 4.4. $\square$

### 5.2 Moment sufficiency

> **Theorem 5.4 (Moment sufficiency).** Let $(\iota, p, x, y, z)$ and $(\kappa, q, x', y', z')$
> be two populations, on possibly different finite key sets and with possibly different draw
> regimes, each satisfying the hypotheses of Theorem 5.3. If
> $$\sigma_{xx} = \sigma'_{x'x'},\quad \sigma_{xy} = \sigma'_{x'y'},\quad
> \sigma_{xz} = \sigma'_{x'z'},\quad \sigma_{zy} = \sigma'_{z'y'},\quad
> \sigma_{zz} = \sigma'_{z'z'},$$
> then the two populations report the same increment:
> $\widetilde{\mathcal{G}}(r,\tilde z) = \widetilde{\mathcal{G}}(r',\tilde z')$.

*Proof sketch.* Both sides equal the same rational expression in the five matched moments, by
Theorem 5.3. $\square$

This is a strong *sufficiency* statement: the increment is blind to everything about a
population except five second moments. Two immediate corollaries deserve emphasis.

1. **Higher-order effects are exonerated.** Nothing about the third or higher moments, the
   support size, the sampling seed, or the tail behaviour of a population can change the
   increment while the five moments are held fixed. A non-replication *must* be visible as a
   change in $(\sigma_{xx}, \sigma_{xy}, \sigma_{xz}, \sigma_{zy}, \sigma_{zz})$.
2. **The diagnostic burden is finite.** To predict whether an increment will replicate on a
   fresh population, one needs five numbers — and crucially two of them, $\sigma_{xz}$ and
   $\sigma_{zy}$, are typically *not* reported alongside the marginal dials.

### 5.3 The absence quadric

> **Theorem 5.5 (Absence locus).** Under the hypotheses of Theorem 5.3, with
> $\|\tilde z\|^2 > 0$,
> $$\Delta R^2(z\mid x) = 0 \iff \sigma_{zy}\,\sigma_{xx} = \sigma_{xy}\,\sigma_{xz}.$$

*Proof sketch.* By Proposition 3.5 and Theorem 4.3, the increment vanishes iff
$\langle r,\tilde z\rangle = 0$; by Theorem 5.1 that is
$\sigma_{zy} - \sigma_{xy}\sigma_{xz}/\sigma_{xx} = 0$; clear the positive denominator.
$\square$

The absence locus is thus a genuine algebraic hypersurface — a quadric — in the space of
second moments, and lying on it has an exact interpretation: *the feature's covariance with
the rate is precisely what the footprint predicts it to be from the footprint–feature
overlap.* The feature may be strongly associated with the rate ($\sigma_{zy}$ large) and still
be absent, provided the overlap $\sigma_{xz}$ is correspondingly large.

---

## 6. Absence is a codimension-one coincidence

Fix a population $(\iota, p)$, a footprint $x$ and a nondegenerate partialled feature
$\tilde z$ ($\|\tilde z\|^2 \ne 0$), and let the rate profile $y$ range over $\mathbb{R}^{n}$.

> **Definition 6.1 (Zero-gain functional).** $\Lambda : \mathbb{R}^{\iota}\to\mathbb{R}$,
> $\Lambda(y) = \langle y, \tilde z\rangle$. This is linear in $y$.

> **Theorem 6.2 (Kernel characterisation).** For $y = a' + b'x + r$ with $r$ a residual for
> $x$ and $\|\tilde z\|^2 > 0$,
> $$y \in \ker \Lambda \iff \Delta R^2(z\mid x) = 0 .$$

*Proof sketch.* By Theorem 4.3, $\langle y,\tilde z\rangle = \langle r,\tilde z\rangle$; the
increment vanishes iff that number does. $\square$

> **Theorem 6.3 (Codimension one).** If $\|\tilde z\|^2 \ne 0$ then $\Lambda$ is surjective and
> $$\dim \ker \Lambda + 1 = n .$$

*Proof sketch.* Surjectivity: for any $t$, $\Lambda\bigl((t/\|\tilde z\|^2)\tilde z\bigr) = t$.
Rank–nullity in the $n$-dimensional space $\mathbb{R}^{\iota}$ finishes the argument.
$\square$

**Interpretation.** In a single population, the set of rate profiles on which the feature is
exactly absent is a hyperplane: a set of Lebesgue measure zero. Absence is a knife edge.
Consequently, observing exact-to-measurement absence once is surprising; observing it on five
independently drawn fresh populations is not a run of bad luck but evidence of a mechanism
pushing those populations onto (or near) the absence locus. Sections 7 and 8 supply two such
mechanisms.

---

## 7. Two explicit populations

Both examples use four keys under the uniform regime $p^{U} = (1/4,1/4,1/4,1/4)$, with the
prime-power indicator $\mathrm{pp} = (1,1,0,0)$.

### 7.1 The non-replication pair

Take the footprint $w = (1,2,3,4)$ and the two rate profiles
$$y^{A} = \left(\tfrac{12}{7}, \tfrac{3}{7}, 4, \tfrac{27}{7}\right),
\qquad y^{B} = (2,1,2,5).$$
Their least-squares decompositions against $w$ are $y = 0 + 1\cdot w + r$ with
$$r^{A} = \left(\tfrac{5}{7}, -\tfrac{11}{7}, 1, -\tfrac{1}{7}\right),
\qquad r^{B} = (1,-1,-1,1),$$
both of which satisfy the normal equations, hence are certified optima by Theorem 3.2. The
partialling of $\mathrm{pp}$ against $w$ is
$\mathrm{pp} = \tfrac{3}{2} - \tfrac{2}{5}w + \widetilde{\mathrm{pp}}$ with
$$\widetilde{\mathrm{pp}} = \left(-\tfrac{1}{10}, \tfrac{3}{10}, -\tfrac{3}{10},
\tfrac{1}{10}\right), \qquad \|\widetilde{\mathrm{pp}}\|^2 = \tfrac{1}{20} > 0 .$$

> **Theorem 7.1 (Non-replication).** The two populations satisfy
> $$R^2(w, y^{A}) = R^2(w, y^{B}) = \tfrac59, \qquad
> \sigma_{y^{A}y^{A}} = \sigma_{y^{B}y^{B}} = \tfrac94, \qquad \|r^A\|^2 = \|r^B\|^2 = 1,$$
> and yet
> $$\Delta R^2(\mathrm{pp}) = \tfrac{20}{49} \approx 0.408 \text{ on } A,
> \qquad \Delta R^2(\mathrm{pp}) = 0 \text{ on } B .$$
> (For the cruder raw gain the readings are $2/49 \approx 0.041$ and $0$.)

*Proof sketch.* Direct evaluation of the four-term sums:
$\langle r^{A}, \widetilde{\mathrm{pp}}\rangle = -3/14$, so
$\widetilde{\mathcal{G}} = (3/14)^2/(1/20) = 45/49$ and $\Delta R^2 = (45/49)/(9/4) = 20/49$; while
$\langle r^{B}, \widetilde{\mathrm{pp}}\rangle = 0$ exactly. $\square$

Same footprint, same feature, same regime, same base dial, same headroom — and incompatible
increments. Non-replication is not a power problem; it is a population-level degree of
freedom.

### 7.2 Sign masking: every marginal reading identical

Keep $w$ and $\mathrm{pp}$, and take
$$y^{\mathrm{sup}} = \left(\tfrac{7}{10}, -\tfrac{2}{5}, -\tfrac{3}{10}, 1\right),
\qquad y^{\mathrm{act}} = \left(\tfrac{3}{10}, \tfrac{2}{5}, -\tfrac{7}{10}, 1\right),$$
with least-squares decompositions $y = 0 + \tfrac{1}{10}w + r$ and residuals
$$r^{\mathrm{sup}} = \left(\tfrac35, -\tfrac35, -\tfrac35, \tfrac35\right),
\qquad r^{\mathrm{act}} = \left(\tfrac15, \tfrac15, -1, \tfrac35\right).$$

> **Theorem 7.2 (Sign-masking non-replication).** The two populations satisfy
> $$R^2(w, y) = \tfrac{5}{149} \text{ for both},\qquad
> R^2(\mathrm{pp}, y) = \tfrac{4}{149} \text{ for both},\qquad
> \sigma_{yy} = \tfrac{149}{400} \text{ for both},$$
> and share the footprint–feature overlap $\sigma_{xz}$ (a property of the features alone).
> They differ only in the sign of the feature–rate covariance,
> $$\sigma_{zy}^{\mathrm{sup}} = -\tfrac{1}{20} = -\,\sigma_{zy}^{\mathrm{act}} .$$
> Their increments are
> $$\Delta R^2(\mathrm{pp}) = 0 \text{ on the suppressed population},
> \qquad \Delta R^2(\mathrm{pp}) = \tfrac{80}{149} \approx 0.537 \text{ on the active one}.$$
> Moreover the suppressed population lies exactly on the absence quadric
> $\sigma_{zy}\sigma_{xx} = \sigma_{xy}\sigma_{xz}$, and the active one does not.

*Proof sketch.* All quantities are four-term rational sums; the two rate profiles are
constructed so that the centred vectors have equal norms and equal projections onto $w$ and
onto $\mathrm{pp}$ up to sign. For the increments, $\langle r^{\mathrm{sup}},
\widetilde{\mathrm{pp}}\rangle = 0$ while
$\langle r^{\mathrm{act}}, \widetilde{\mathrm{pp}}\rangle^2/\|\widetilde{\mathrm{pp}}\|^2 =
1/5$, and $(1/5)/(149/400) = 80/149$. Verifying the quadric is direct substitution. $\square$

**This is the paper's sharpest methodological statement.** Every marginal diagnostic that an
augmented-dial experiment records — base dial, marginal feature dial, rate variance,
feature–footprint overlap — is *numerically identical* on a population where the feature
contributes more than half the variance and on a population where it contributes exactly
nothing. The mechanism is **suppression**: the footprint's own association with the rate
cancels the feature's, and only the signed quantity $\sigma_{zy}\sigma_{xx} -
\sigma_{xy}\sigma_{xz}$ detects the difference. A stable set of marginal readings is not weak
evidence for a replicable increment; it is no evidence.

### 7.3 Marginal signal without incremental signal

> **Definition 7.3 (Comonotone).** $z$ and $y$ are *comonotone* if
> $(z_i - z_j)(y_i - y_j) \ge 0$ for all $i,j$.

Comonotone pairs have strictly positive covariance under every full-support draw regime,
provided they are not both constant: this is the strongest regime-invariant marginal signal
available.

Take the footprint $w' = \left(\tfrac72, \tfrac72, 1, 0\right)$ and rate $y' = (4,3,1,0)$,
with least-squares decomposition $y' = 0 + 1\cdot w' + r'$, $r' = \left(\tfrac12, -\tfrac12,
0, 0\right)$.

> **Theorem 7.4 (Marginal present, incremental absent).** For this population:
> 1. $\mathrm{pp}$ and $y'$ are comonotone, hence $\sigma_{\mathrm{pp}\,y'} > 0$ in *every*
>    full-support draw regime;
> 2. the baseline is not saturated: $R^2(w', y') = \tfrac{19}{20}$ and $\|r'\|^2 = \tfrac18 >
>    0$;
> 3. nevertheless $\Delta R^2(\mathrm{pp} \mid w') = 0$ exactly.

*Proof sketch.* (1) is a finite check over the $16$ ordered pairs together with the positivity
of covariance for comonotone pairs. (2) is direct evaluation. For (3), the partialling of
$\mathrm{pp}$ against $w'$ is $\widetilde{\mathrm{pp}}' = \tfrac{1}{38}(1, 1, -7, 5)$ and
$\langle r', \widetilde{\mathrm{pp}}'\rangle = 0$ because $r'$ is supported on the first two
keys with opposite signs while $\widetilde{\mathrm{pp}}'$ is constant there. $\square$

So a feature can be genuinely and robustly associated with the outcome, over a model with
genuine headroom, and contribute nothing incrementally. Reporting an absent increment is fully
consistent with the underlying structural association being real.

---

## 8. Two ceilings: collinearity and sparsity

Theorem 3.8 already gives one structural ceiling. The second needs no cancellation at all.

> **Theorem 8.1 (Sparse-indicator ceiling).** Let $z$ be a $0/1$ feature with draw-regime
> density $\delta = \sum_i p_i z_i > 0$, and let the residual be bounded, $|r_i| \le B$ for
> all $i$. Then
> $$\mathcal{G}(r, z) \;\le\; B^2\,\delta .$$

*Proof sketch.* For a $0/1$ feature, $\|z\|^2 = \delta$. Bounding
$|\langle r,z\rangle| \le \sum_i p_i |r_i| z_i \le B\delta$ and dividing by $\|z\|^2 = \delta$
gives $\mathcal{G} \le B^2\delta^2/\delta$. $\square$

> **Corollary 8.2 (Vanishing density forces a vanishing dial).** If $B > 0$ and
> $\delta < \varepsilon/B^2$, then $\mathcal{G}(r,z) < \varepsilon$, uniformly over all
> residuals bounded by $B$ and all correlation structures.

**Application to prime powers.** On the key range $\{1,\dots,N\}$, the prime-power indicator
is sparse. Every prime power exceeding $3$ is congruent to $\pm 1 \pmod 6$, which already caps
the density near $1/3$, and the true density $\delta_N$ of $\{n \le N : n = p^k\}$ tends to
$0$ as $N \to \infty$. Consequently, under any draw regime whose mass on prime powers is
$\delta_N$ and any residual bounded by $B$, the raw prime-power gain is at most $B^2\delta_N
\to 0$. Whatever produced $+0.089$ on one small key range cannot survive to large key ranges
under bounded residuals. This is a mechanism for absence requiring no coincidence and no
suppression — only counting.

---

## 9. Exonerating the usual suspects

### 9.1 Regime drift

> **Theorem 9.1 (Total-variation stability).** If $|r_i z_i| \le M$ for all $i$, then for any
> two draw regimes $p, q$,
> $$\bigl|\langle r,z\rangle_p - \langle r,z\rangle_q\bigr| \le M \sum_i |p_i - q_i| .$$

*Proof sketch.* The difference is $\sum_i (p_i - q_i) r_i z_i$; apply the triangle inequality
termwise. $\square$

> **Corollary 9.2 (Drift cannot resurrect an absent feature).** If $\langle r,z\rangle_q = 0$
> for some regime $q$, then for every regime $p$ with $\|z\|_p^2 > 0$,
> $$\mathcal{G}_p(r,z) \le \frac{\bigl(M \sum_i |p_i - q_i|\bigr)^{2}}{\|z\|_p^2}.$$

The gain at a nearby regime is *quadratically* small in the regime distance. Re-weighting a
population cannot manufacture an increment; only changing the population can. This removes
draw-regime drift from the list of explanations for the observed non-replication.

### 9.2 Attenuation of the transfer slope

> **Theorem 9.3 (Slope attenuation).** Suppose the measured footprint is $x + u$, where the
> noise $u$ satisfies $\sigma_{xu} = 0$ and $\sigma_{uy} = 0$, and the rate is calibrated on
> the true footprint, $\sigma_{xy} = \sigma_{xx}$. Then the fitted transfer slope is
> $$\frac{\sigma_{x+u,\,y}}{\sigma_{x+u,\,x+u}} = \frac{\sigma_{xx}}{\sigma_{xx} + \sigma_{uu}} .$$

*Proof sketch.* Bilinearity gives $\sigma_{x+u,y} = \sigma_{xy} + \sigma_{uy} = \sigma_{xx}$
and $\sigma_{x+u,x+u} = \sigma_{xx} + 2\sigma_{xu} + \sigma_{uu} = \sigma_{xx} + \sigma_{uu}$.
$\square$

> **Corollary 9.4 (Slope band).** If $0 < \sigma_{uu} \le \sigma_{xx}/5$ then the slope lies in
> $[5/6, 1)$.

A transfer slope strictly below one is therefore *forced* by measurement noise, and the
observed value $0.898$ sits inside the band predicted by a noise-to-signal ratio of at most
$1/5$. The slope is not evidence of signal decay, and it is not evidence about the increment
either.

---

## 10. Back to the data

The five recorded augmented-dial readings are
$$\left(\tfrac{49}{100},\; \tfrac{111}{200},\; \tfrac{107}{250},\; \tfrac{133}{250},\;
\tfrac{127}{250}\right) = (0.490, 0.555, 0.428, 0.532, 0.508),$$
with mean $2513/5000 = 0.5026 < 0.55$, and exactly one reading at or above the target.

> **Theorem 10.1 (Falsification bound).** If each fresh population independently clears the
> target with probability $q \ge 4/5$, then
> $$\Pr[\text{at most one success in five}] = (1-q)^5 + 5q(1-q)^4 \le \frac{21}{3125} < 0.007 .$$

*Proof sketch.* Write the left side as $5(1-q)^4 - 4(1-q)^5$ and note it is increasing in
$(1-q)$ on $[0, 1/5]$; evaluate at $1-q = 1/5$. $\square$

Observing exactly one success therefore rejects the $80\%$-replication hypothesis at that
level. Combined with the structural results, the correct reading of the experiment is: the
augmented dial's target is not met, the failure is attributable to the prime-power
ingredient, and the mechanism lies in the second moments — not in sampling variability.

**What survives.** The transfer slope $0.898$ lies in band (Corollary 9.4). The combined model
reaching $R^2 = 0.634$ at its operating point is unaffected by these results, since the
prime-power ingredient contributes nothing to it. The best validated per-key dial remains the
baseline footprint form.

---

## 11. Discussion

### 11.1 Increments are a different species of statistic

The results assemble into a clean taxonomy.

| statistic | stability | geometry |
|---|---|---|
| marginal covariance $\sigma_{zy}$ | robust; sign invariant under all full-support regimes if comonotone | open half-space |
| base variance share $R^2(x,y)$ | robust | smooth function of moments |
| transfer slope | forced into a band by noise | monotone in noise-to-signal |
| **increment $\Delta R^2(z\mid x)$** | **knife-edge** | **vanishes on a quadric; zero set is a hyperplane of codimension one** |

Marginal statistics are open conditions; increments vanish on closed measure-zero sets. There
is no general implication from the stability of the former to the stability of the latter, and
Theorem 7.2 shows that the implication fails in the strongest possible way: the entire vector
of marginal readings can be held fixed while the increment sweeps from $0$ to $0.537$.

### 11.2 What should be reported

Theorem 5.4 turns this into actionable practice. An augmented-dial report should carry the
five sufficient moments $(\sigma_{xx}, \sigma_{xy}, \sigma_{xz}, \sigma_{zy}, \sigma_{zz})$,
or equivalently the two quantities that the marginals omit:

* the **overlap** $\sigma_{xz}$ between footprint and candidate feature, and
* the **signed absence discriminant** $D = \sigma_{zy}\sigma_{xx} - \sigma_{xy}\sigma_{xz}$.

The increment is $D^2 / \bigl[\sigma_{xx}(\sigma_{zz}\sigma_{xx} - \sigma_{xz}^2)\sigma_{yy}\bigr]$,
and $D$ is the only quantity whose sign and magnitude distinguish suppression from
contribution. Reporting $D$ with its uncertainty converts a knife-edge statistic into a
readable one: a population near the absence quadric announces itself as $D \approx 0$, and the
prediction that a fresh population will report an absent increment becomes falsifiable in
advance.

### 11.3 Relation to the classical picture

Theorem 4.7 is the finite-population, arbitrary-draw-regime form of the classical identity
relating the increment of a multiple correlation to a squared partial correlation. Theorems
5.1–5.3 are the corresponding closed forms in the two-predictor case, and Theorem 5.5 is the
familiar suppression condition. What is new here is the *use* to which they are put: an exact
codimension count (Theorem 6.3), a sufficiency theorem across heterogeneous populations
(Theorem 5.4), a construction in which the full vector of marginal diagnostics is invariant
while the increment is not (Theorem 7.2), and a sparsity ceiling (Theorem 8.1) that converts a
number-theoretic density statement directly into a bound on explanatory power.

---

## 12. Algorithms

Three procedures are used throughout, all with cost linear or quadratic in the number of keys.

**A. Certified augmentation audit.** Given $(p, x, z, y)$: compute the weighted moments in
$O(n)$; form the least-squares coefficients $b = \sigma_{xy}/\sigma_{xx}$,
$a = \bar y - b\bar x$; form $r$ and verify the normal equations to certify optimality;
partial $z$ against $x$ to obtain $\tilde z$; report
$\widetilde{\mathcal{G}} = \langle r,\tilde z\rangle^2/\|\tilde z\|^2$ and
$\Delta R^2 = \widetilde{\mathcal{G}}/\sigma_{yy}$. Total cost $O(n)$.

**B. Absence discriminant and quadric distance.** Given the five moments, compute
$D = \sigma_{zy}\sigma_{xx} - \sigma_{xy}\sigma_{xz}$ and
$\Delta R^2 = D^2 / [\sigma_{xx}(\sigma_{zz}\sigma_{xx} - \sigma_{xz}^2)\sigma_{yy}]$; the
population is on the absence locus exactly when $D = 0$. Cost $O(1)$ after the $O(n)$ moment
pass. This is the recommended reporting statistic.

**C. Sequential augmentation with ceilings.** Given a family of candidate features
$z_1,\dots,z_m$: greedily partial each against the current model, compute each partialled
gain, take the largest, update the residual, and repeat. At each step the collinearity-defect
ceiling $\|r\|^2\|d\|^2/\|z\|^2$ and, for $0/1$ features, the sparsity ceiling $B^2\delta$
provide an *a priori* upper bound that can prune candidates before their gains are computed.
Cost $O(mn)$ per round, $O(m^2 n)$ overall.

---

## 13. Future directions

Three research cycles were run on the negative result "the prime-power feature's contribution
does not replicate". What survived scrutiny:

1. **Absence is exact, not noisy.** The increment $\Delta R^2(z\mid x)$ vanishes precisely at
   residual orthogonality, i.e. on the quadric $\sigma_{zy}\sigma_{xx} = \sigma_{xy}\sigma_{xz}$.
2. **Absence is a codimension-one condition** on rate profiles: seeing it once is a knife
   edge, seeing it five times is structure.
3. **Marginal stability implies nothing about increments.** A feature can be comonotone with
   the rate — the strongest regime-invariant marginal signal available — and still contribute
   exactly zero, and two populations can match *every* marginal dial reading while their
   increments are $0.537$ and $0$.
4. **Regime drift is exonerated; moment differences are indicted.**
5. **Sparsity is a sufficient mechanism:** a $0/1$ feature of density $\delta$ cannot buy more
   than $B^2\delta$.

The following conjectures are the next cycle.

### 13.1 Prime-power density ceiling for integer key populations

The prime-power indicator on the key range $\{1,\dots,N\}$ is a sparse $0/1$ feature, and the
sparsity ceiling converts sparsity directly into a ceiling on the dial: no cancellation
argument, no seed dependence, just density. **Conjecture.** For every $N$ and every residual
bounded by $B$, the raw prime-power gain on $\{1,\dots,N\}$ under any draw regime whose mass on
prime powers is $\delta_N$ satisfies $\mathcal{G} \le B^2\delta_N$, with $\delta_N \to 0$;
hence the reported $+0.089$ cannot survive to large key ranges under bounded residuals. *Why
now?* The general ceiling is already proved; what remains is the purely number-theoretic input
$\#\{n \le N : n \text{ a prime power}\} = o(N)$, reachable by an elementary sieve — all prime
powers above $3$ are $\equiv \pm 1 \pmod 6$, giving $\delta_N \le 1/3 + o(1)$ immediately, with
the full $o(1)$ following from a Mertens-type product.

### 13.2 Suppression geometry of feature families

The absence locus is the quadric $\sigma_{zy}\sigma_{xx} = \sigma_{xy}\sigma_{xz}$, so a
*family* of candidate features $z_1,\dots,z_m$ has an absence set that is an intersection of
$m$ quadrics in moment space. **Conjecture.** For a generic footprint, the set of populations
on which *all* features of a fixed family are simultaneously absent has codimension exactly
$m$ in moment space, and the sequential-gain decomposition makes the codimension count
additive. *Why now?* The case $m = 1$ is complete; extending it needs the Gram matrix of the
partialled family and its rank, all of which is expressible with the existing machinery.

### 13.3 Further questions

* **A pre-registration statistic.** Can the absence discriminant $D$, estimated on a pilot
  population with an explicit error bar, be turned into a calibrated prediction interval for
  the increment on a fresh population? Theorems 5.4 and 9.1 suggest yes, via a
  moment-perturbation bound.
* **Optimal suppression-resistant features.** Among all $0/1$ features of a given density,
  which maximise the worst-case increment over populations with prescribed base dial? This is
  a constrained maximisation of $D^2$ over a discrete feasible set.
* **Higher-order footprints.** The entire theory is stated for an affine baseline. Replacing
  "affine in $x$" by "in the span of a fixed subspace $V$" should leave every statement intact
  with $\sigma_{xz}/\sigma_{xx}$ replaced by a projection, and the absence locus becoming a
  determinantal variety.

---

## 14. Conclusion

An increment is not a measurement of the same kind as a marginal association. It is a
difference of fits, and differences live on knife edges. We proved that the increment of a
variance share is a rational function of five second moments, that it vanishes exactly on a
quadric in those moments, that its zero set in rate-profile space is a hyperplane of
codimension one, and that it can be moved from $0$ to more than half the variance while every
marginal diagnostic in a standard report stays numerically fixed. Two independent mechanisms —
suppression and sparsity — suffice to produce absence with no appeal to noise, and two popular
alternative explanations, regime drift and slope decay, are ruled out quantitatively.

The prime-power feature's contribution did not replicate because, on the fresh populations, the
footprint had already accounted for everything the feature had to say. That is a statement
about second moments, it is exactly checkable, and it is the statistic that such experiments
should report.
