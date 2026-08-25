# Binning-Independent Geometry of a Windowed Hump

### Invariance, certificates, and estimator pathologies under bin-width and grid-offset perturbation

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

A histogram has two free parameters — the bin width $w$ and the grid offset $o$ — and
any feature read off a histogram is, a priori, hostage to both. We give a complete
analytic account of which properties of a *windowed hump* survive perturbation of these
parameters and which do not, motivated by a concrete $6 \times 5$ probe (six bin counts
$\times$ five circular grid shifts, $30$ cells) of a ratio curve $R = T/M$ on the unit
window carrying a mid-window feature at $u^{*} \approx 0.65$.

Our organising result is a **sampling identity**: every bin value of every grid is a
sample of one and the same offset-free function, the box-kernel sliding average
$(S_w f)(x) = w^{-1}\int_{x-w/2}^{x+w/2} f$. The offset is therefore not a degree of
freedom of the statistic, only of the sampling points. From this we derive:

1. a **one-sided certificate** — a bin value $\ge c$ forces $\sup f \ge c$, so binning
   can flatten a hump but never manufacture one;
2. **amplitude stability** — for $L$-Lipschitz $f$ the raw histogram maximum is within
   $Lw$ of $\sup f$, so two grids of widths $w_1, w_2$ and unrelated offsets agree to
   $L(w_1+w_2)$; and, exactly, $(S_w)(c - k(x-x_s)^2) = c - k[(x-x_s)^2 + w^2/12]$, a
   pure amplitude deflation with no vertex displacement and no offset dependence;
3. **vertex transport** — under a cone condition the argmax bin centre lies within
   $w/2 + (L/\kappa)w$ of the true peak for every offset, and under symmetry plus
   concavity the argmax bin is *exactly* the bin nearest the peak, with no slack.

We then audit the two estimator components that failed in practice. The three-point
local quadratic fit satisfies $\hat y \ge y_0$ whenever the fit is concave — it never
lowers the amplitude, so an amplitude bar on the fitted apex is *anti*-conservative
relative to the same bar on raw values. And a fitted vertex further than $w/2$ from the
central bin centre is a *certificate of degeneracy*: it forces
$|y_- - y_+| > |y_- - 2y_0 + y_+|$, i.e. neighbour asymmetry exceeding curvature.
Finally, a bin-count-agnostic control threshold has family-wise error
$1 - (1-p)^n \to 1$, whereas the aware threshold with per-bin level $\alpha/n$ satisfies
$1 - (1-\alpha/n)^n \le \alpha$ for all $n$.

Applied to the data, these results reclassify the probe's outcome. The persistence of
the hump in $30/30$ cells and the pinning of its *absolute* vertex to $0.6482$–$0.6492$
across all shifts are consequences of the geometry, not coincidences; the single erratic
$33$-bin cell is a degenerate fit; the three breaches of a flat $1.02$ control bar at
$1.0215$–$1.0305$ (all at $n \in \{50,66,100\}$) are expected extremes inside the aware
$1.05$ ceiling. The failure of the pre-registered amplitude bar ($7/30$ fitted peaks
$\ge 1.10$ against $22/30$ raw maxima) is a property of the estimator, not of the curve.
Verdict: a stable geometric window feature at $u^{*} \approx 0.65$; one operationalisation
of significance refuted; the geometry channel open.

**Keywords:** box kernel, sliding average, histogram invariance, bin width, grid offset,
unimodality, Lipschitz bound, family-wise error rate, quadratic peak fit.

---

## 1. Introduction

### 1.1 The problem

Let $f : \mathbb{R} \to \mathbb{R}$ be a curve on a normalised window, in the motivating
case a ratio $R(u) = T(u)/M(u)$ of a measured quantity $T$ to a modelled baseline $M$,
so that $R \equiv 1$ under a perfect model. Empirically $R$ carries a mid-window hump:
a broad excursion to $\approx 1.2$ centred near $u^{*} \approx 0.65$.

The methodological question is old and sharp. A histogram of $f$ depends on two choices:

* the **bin width** $w > 0$ (equivalently the bin count $n_b = 1/w$ on a unit window), and
* the **grid offset** $o$ (equivalently a circular shift of the bin boundaries).

Both are conventions, not data. A feature that appears at one $(w, o)$ and disappears at
another is a property of the picture; a feature that is invariant is a property of the
curve. Practitioners resolve this by folklore ("vary $w$; if it survives, believe it").
Our aim is to replace the folklore with theorems that say exactly which functionals of a
histogram are invariant, in which sense, and with what error constants.

### 1.2 The probe

The empirical design was a full product grid:

* bin counts $n_b \in \{10, 20, 33, 50, 66, 100\}$;
* circular grid shifts $\mathrm{sh} \in \{-0.25, -0.125, 0, +0.125, +0.25\}$ (in units of one bin);
* $6 \times 5 = 30$ cells, each a complete re-histogramming of the same curve.

Three registered readouts per cell: presence of a hump (raw maximum above a noise
ceiling), its amplitude, and its location, the latter two estimated by a three-point
local quadratic fit through the argmax bar and its neighbours.

The anchor cell $(n_b = 50, \mathrm{sh} = 0)$ reproduced an independent prior computation
of the same curve: raw maximum $1.22636$ against $1.2227$ (difference $0.004$), with bins
$2$ through $49$ agreeing to $\le 0.005$; the two edge bins differ only through a
centre-value versus integrated-value convention for the baseline $M$.

The outcomes were mixed in a specific and instructive way.

| Observation | Value |
|---|---|
| Cells with a raw-max hump | $30/30$, amplitudes $1.0706$–$1.2960$ |
| Cells below the "vanish" precondition ($<1.03$) | $0/30$ |
| Absolute vertex $\mathrm{vx} + \mathrm{sh}$ at $n_b = 100$, all five shifts | $0.6482$–$0.6492$ |
| Erratic fits | $1/30$ (an $n_b = 33$ cell, fitted vertex off by $0.19$; its own argmax bin centre $0.01$ from the consensus) |
| Fitted amplitude $\ge 1.10$ | $7/30$ |
| Raw maximum $\ge 1.10$ | $22/30$ |
| Cells passing all three registered bars | $0/30$ (80% required) |
| Breaches of a flat $1.02$ control bar | $3$ cells at $1.0215$–$1.0305$, all with $n_b \in \{50,66,100\}$ |

A mechanically applied precedence chain, reading the third row of that table, emitted
the verdict "artefact-contaminated". The mathematics below shows why that reading is
wrong, why the vertex pinning is forced, and why the amplitude test failed for reasons
internal to the estimator.

### 1.3 Contributions

* **§3** The sampling identity, eliminating the offset from the statistic, and the two
  rigid-transport laws that follow.
* **§4** The one-sided certificate: binning cannot manufacture amplitude.
* **§5** Lipschitz amplitude stability and cross-width agreement; the exact $kw^2/12$
  deflation law for a parabolic hump.
* **§6** Vertex localisation: $O(w)$ under a cone condition, exact under symmetry plus
  concavity, via the fact that box averaging preserves symmetry, concavity and hence
  unimodality.
* **§7** The estimator audit: monotonicity and degeneracy theorems for the three-point
  quadratic fit.
* **§8** The control audit: divergence of the flat threshold's family-wise error and
  control of the bin-count-aware threshold.
* **§9** Reinterpretation of the $30$-cell probe; **§10** a parameter-free curvature-sign
  shape test; **§11** discussion and future directions.

---

## 2. Definitions

Throughout, $f : \mathbb{R} \to \mathbb{R}$ is continuous and $w > 0$.

**Definition 2.1 (Bin average).** For $a \in \mathbb{R}$,
$$\operatorname{avg}(f; a, w) \;=\; \frac{1}{w}\int_{a}^{a+w} f(x)\,dx .$$

**Definition 2.2 (Grid, bin values, bin centres).** A *grid* is a pair $(o, w)$ with
offset $o \in \mathbb{R}$ and width $w > 0$. Its $i$-th bin value and bin centre, for
$i \in \mathbb{Z}$, are
$$ B_i(o,w) \;=\; \operatorname{avg}\!\big(f;\, o + iw,\, w\big), \qquad
   c_i(o,w) \;=\; o + \Big(i + \tfrac{1}{2}\Big)w . $$

**Definition 2.3 (Sliding average).** The *box-kernel sliding average* of $f$ at scale
$w$ is the function
$$ (S_w f)(x) \;=\; \frac{1}{w}\int_{x - w/2}^{\,x + w/2} f(s)\,ds ,\qquad x \in \mathbb{R}. $$
Equivalently, centred, $(S_w f)(x) = w^{-1}\int_{-w/2}^{w/2} f(x+s)\,ds$.

**Definition 2.4 (Three-point quadratic fit).** Given values $y_-, y_0, y_+$ at abscissae
$x_0 - w,\, x_0,\, x_0 + w$, write the *discrete curvature* $D = y_- - 2y_0 + y_+$ and
the *neighbour asymmetry* $A = y_- - y_+$. When $D \neq 0$, the interpolating parabola
has vertex abscissa and vertex ordinate
$$ \hat{x}(x_0,w) \;=\; x_0 + \frac{w\,A}{2D}, \qquad
   \hat{y} \;=\; y_0 - \frac{(y_+ - y_-)^2}{8D} . $$

**Definition 2.5 (Cone condition).** $f$ has a *$\kappa$-cone peak* at $x_s$ if
$f(x) \le f(x_s) - \kappa|x - x_s|$ for all $x$, with $\kappa > 0$.

**Definition 2.6 (Midpoint-form concavity).** $f$ is concave if for all $x,y$ and all
$a,b \ge 0$ with $a + b = 1$, $a f(x) + b f(y) \le f(ax + by)$.

---

## 3. The sampling identity and rigid transport

**Theorem 3.1 (Sampling identity).** For every $o \in \mathbb{R}$, $w > 0$ and
$i \in \mathbb{Z}$,
$$ B_i(o,w) \;=\; (S_w f)\big(c_i(o,w)\big). $$

*Proof.* Both sides are $w^{-1}$ times the integral of $f$ over an interval of length
$w$; the bin $[o + iw,\, o + iw + w]$ and the window
$[c_i - w/2,\, c_i + w/2]$ with $c_i = o + (i + \tfrac12)w$ coincide. $\square$

The identity is elementary and consequential: *the grid offset is not a parameter of the
statistic*. All $30$ cells of the probe are samples of six functions $S_{w}f$,
$w \in \{1/10,\ldots,1/100\}$, taken at five different sets of abscissae each. Any
question of the form "does the feature survive a change of offset?" is a question about
sampling points, never about the underlying object.

**Theorem 3.2 (Data shift $=$ grid shift).** For all $a, w, t$,
$$ \operatorname{avg}\big(f(\cdot + t); a, w\big) \;=\; \operatorname{avg}(f; a + t, w), $$
and consequently, for every $i$, the $i$-th bin value of the $t$-translated data on the
grid $(o,w)$ equals the $i$-th bin value of the original data on the grid $(o + t, w)$.

*Proof.* Translation invariance of Lebesgue measure: substituting $x \mapsto x + t$ maps
$\int_a^{a+w} f(x+t)\,dx$ to $\int_{a+t}^{a+w+t} f(x)\,dx$. $\square$

**Theorem 3.3 (Rigid transport of centres).** $c_i(o + t, w) = c_i(o,w) + t$.

*Proof.* Immediate from Definition 2.2. $\square$

**Corollary 3.4 (Label drift versus absolute invariance).** Under a grid shift by $t$,
the *index* of the argmax bin changes by construction (Theorem 3.2 identifies the shifted
problem with the unshifted one at a displaced offset), while the *absolute* argmax
location $c_i + $ (accumulated shift) transports rigidly (Theorem 3.3). Hence
$\mathrm{vx} + \mathrm{sh}$, and not $\mathrm{vx}$, is the candidate invariant.

This is precisely the empirical pattern: the reported vertex label drifted with the
shift, while the corrected quantity sat in $[0.6482, 0.6492]$ over all five shifts at
$n_b = 100$.

---

## 4. The one-sided certificate

**Lemma 4.1 (Averages respect pointwise bounds).** Let $w > 0$ and let $f$ be continuous
on $[a, a+w]$.
(i) If $f \le M$ on $[a, a+w]$ then $\operatorname{avg}(f;a,w) \le M$.
(ii) If $f \ge M$ on $[a, a+w]$ then $\operatorname{avg}(f;a,w) \ge M$.

*Proof.* Monotonicity of the integral against the constant $M$, then divide by $w > 0$;
$\int_a^{a+w} M = wM$. $\square$

**Lemma 4.2.** For $w > 0$ and $f$ continuous there exists $x \in [a, a+w]$ with
$\operatorname{avg}(f;a,w) \le f(x)$.

*Proof.* $[a, a+w]$ is compact and non-empty, so $f$ attains a maximum at some
$x^\ast$; apply Lemma 4.1(i) with $M = f(x^\ast)$. $\square$

**Theorem 4.3 (One-sided certificate).** Let $f$ be continuous, $w > 0$, $o \in \mathbb{R}$,
$i \in \mathbb{Z}$, and suppose $B_i(o,w) \ge c$. Then $f(x) \ge c$ for some $x$.

*Proof.* Combine Lemma 4.2 on the bin $[o+iw,\, o+iw+w]$ with the hypothesis. $\square$

**Interpretation.** Box averaging is a contraction toward the mean: it can only reduce
extremes. Therefore *no* choice of $(w,o)$ can create amplitude that the curve does not
possess, while any choice may destroy it. The asymmetry has a direct methodological
consequence: **the persistence of a raw-max hump across a bin-width $\times$ shift grid
is not an artefact hypothesis at all.** For the probe, $30/30$ cells recorded a raw
maximum in $[1.0706, 1.2960]$; hence the curve certifiably attains at least $1.0706$
within the window, and does so in the vicinity of every cell's argmax bin. What remains
open is only *calibration*: whether such an excursion is large relative to the null
fluctuation. That is a question about the noise model, addressed in §8, not about the
binning.

---

## 5. Amplitude is binning-independent

**Theorem 5.1 (Lipschitz lower bound).** Let $L \ge 0$ and suppose
$|f(x)-f(y)| \le L|x-y|$ for all $x,y$. If $c \in [a, a+w]$ then
$$ f(c) - L\,w \;\le\; \operatorname{avg}(f; a, w). $$

*Proof.* For $x \in [a, a+w]$ we have $|c - x| \le w$, hence
$f(c) - f(x) \le |f(c)-f(x)| \le L|c-x| \le Lw$, i.e. $f(x) \ge f(c) - Lw$ pointwise on
the bin. Apply Lemma 4.1(ii). $\square$

**Theorem 5.2 (Peak bound).** Under the hypotheses of Theorem 5.1, if additionally
$f(x) \le f(x_s)$ for all $x$ and $x_s \in [a, a+w]$, then
$$ \big|\operatorname{avg}(f;a,w) - f(x_s)\big| \;\le\; L\,w. $$

*Proof.* Upper bound by Lemma 4.1(i) with $M = f(x_s)$; lower bound by Theorem 5.1 with
$c = x_s$. $\square$

**Lemma 5.3 (Every point is binned).** For any $o$, $w > 0$, $x_s$ there is
$i = \lfloor (x_s - o)/w \rfloor \in \mathbb{Z}$ with $x_s \in [o + iw,\, o + iw + w]$.

*Proof.* Floor bounds $\lfloor t \rfloor \le t < \lfloor t\rfloor + 1$ with
$t = (x_s - o)/w$, multiplied by $w > 0$. $\square$

**Theorem 5.4 (Width independence of the raw maximum).** Let $f$ be continuous,
$L$-Lipschitz with global maximiser $x_s$. For any two grids $(o_1,w_1)$, $(o_2,w_2)$ with
$w_1, w_2 > 0$ and *arbitrary, unrelated* offsets there exist indices $i, j$ with
$$ \big|B_i(o_1,w_1) - B_j(o_2,w_2)\big| \;\le\; L\,(w_1 + w_2). $$

*Proof.* Take $i, j$ from Lemma 5.3 so that $x_s$ lies in bin $i$ of the first grid and
bin $j$ of the second. Theorem 5.2 gives $|B_i - f(x_s)| \le Lw_1$ and
$|B_j - f(x_s)| \le Lw_2$; the triangle inequality finishes. $\square$

Since the raw maximum of a grid is at least the value of the bin containing $x_s$, and at
most $f(x_s)$ by Lemma 4.1(i), Theorem 5.4 says that the *measured* hump amplitude is a
curve property up to a first-order-in-$w$ error controlled by the curve's own steepness.

### 5.1 Exact deflation for a parabolic hump

The Lipschitz bound is worst-case. For the canonical smooth hump the effect of binning
can be computed in closed form, and it is startlingly clean.

**Theorem 5.5 (Sliding average of a parabola).** For $c, k, x_s \in \mathbb{R}$ and
$w > 0$, with $f(s) = c - k(s - x_s)^2$,
$$ (S_w f)(x) \;=\; c - k\Big[(x - x_s)^2 + \frac{w^2}{12}\Big]. $$

*Proof sketch.* Split the integral. The constant part contributes $c$. For the quadratic
part, $\int_a^b (s-d)^2\,ds = \frac{(b-d)^3 - (a-d)^3}{3}$; with $a = x - w/2$,
$b = x + w/2$, $d = x_s$ and $\delta = x - x_s$ this is
$\frac{(\delta + w/2)^3 - (\delta - w/2)^3}{3} = w\delta^2 + w^3/12$. Dividing by $w$
gives $\delta^2 + w^2/12$. $\square$

Three corollaries, all offset-free:

* **Exact vertex preservation.** $S_w f$ is again a parabola with the same curvature $k$
  and the same vertex abscissa $x_s$, for every $w$. Box averaging of a parabolic hump
  does not move the peak at all.
* **Exact amplitude deflation.** $(S_w f)(x_s) = c - k w^2/12$.
* **Exact cross-width gap.** $(S_{w_1}f)(x_s) - (S_{w_2}f)(x_s) = k\,(w_2^2 - w_1^2)/12$.

The measured amplitude therefore differs from the true amplitude by a *deterministic,
computable* quantity $kw^2/12$ that shrinks quadratically in the bin width and is
identical for every offset. This is the analytic content of the informal complaint that
"the estimator is stricter than the phenomenon": a fixed amplitude bar applied to a
binned curve is testing $c - kw^2/12$, not $c$, and the deficit is known.

---

## 6. Vertex localisation and transport

### 6.1 General case: an $O(w)$ bound with no offset dependence

**Theorem 6.1 (Argmax bin near the peak).** Let $f$ be continuous and $L$-Lipschitz with
a $\kappa$-cone peak at $x_s$ ($\kappa > 0$). Fix any grid $(o, w)$, $w > 0$; let $j$ be
the index with $x_s$ in bin $j$, and let $i$ be any index with
$B_j(o,w) \le B_i(o,w)$. Then
$$ \big|c_i(o,w) - x_s\big| \;\le\; \frac{w}{2} + \frac{L}{\kappa}\,w . $$

*Proof.* Write $d = |c_i - x_s|$. Every $x$ in bin $i$ satisfies $|x - c_i| \le w/2$, so
by the reverse triangle inequality $|x - x_s| \ge d - w/2$; the cone condition then gives
$f(x) \le f(x_s) - \kappa(d - w/2)$ on that bin, and averaging (Lemma 4.1(i)) yields
$B_i \le f(x_s) - \kappa(d - w/2)$. On the other side, $x_s$ lies in bin $j$, so
Theorem 5.1 gives $B_j \ge f(x_s) - Lw$. Chaining with $B_j \le B_i$:
$f(x_s) - Lw \le f(x_s) - \kappa(d - w/2)$, i.e. $\kappa(d - w/2) \le Lw$, i.e.
$d \le w/2 + (L/\kappa)w$. $\square$

The bound is uniform in $o$: it contains no offset. Hence the argmax bin's *absolute*
centre lies in a fixed neighbourhood of $x_s$ of radius $(\tfrac12 + L/\kappa)w$, for
every shift of the grid, and this radius shrinks linearly under refinement. This is the
general mechanism behind the observed shift-invariance of $\mathrm{vx} + \mathrm{sh}$.

### 6.2 Sharp case: exact rigidity under symmetry and concavity

The $O(w)$ slack in Theorem 6.1 can be removed entirely under shape hypotheses, because
box averaging is *shape-preserving*.

**Theorem 6.2 (Symmetry preservation).** If $f(2x_s - x) = f(x)$ for all $x$, then
$(S_w f)(2x_s - x) = (S_w f)(x)$ for all $x$ and all $w$.

*Proof.* Rewrite the integrand over the reflected window using the symmetry, then
substitute $s \mapsto 2x_s - s$; the window maps onto the original one. $\square$

**Theorem 6.3 (Concavity preservation).** If $f$ is continuous and concave, then $S_w f$
is concave for every $w > 0$.

*Proof.* Using the centred form, for $a,b \ge 0$, $a + b = 1$ and any $x,y$,
concavity applied pointwise gives
$a f(x+s) + b f(y+s) \le f(a x + b y + s)$ for each $s$ (using $as + bs = s$).
Integrate over $s \in [-w/2, w/2]$ and divide by $w > 0$. $\square$

**Lemma 6.4 (Symmetric $+$ concave $\Rightarrow$ radially monotone).** Let $g$ be
symmetric about $x_s$ and concave. If $|u - x_s| \le |v - x_s|$ then $g(v) \le g(u)$.

*Proof sketch.* Set $t = v - x_s$, $r = u - x_s$. If $t = 0$ then $r = 0$ and the claim is
trivial. Otherwise $|r/t| \le 1$; put $\lambda = \tfrac12 + \tfrac{r}{2t} \in [0,1]$, so
that $\lambda(x_s + t) + (1-\lambda)(x_s - t) = u$. Concavity gives
$\lambda g(x_s+t) + (1-\lambda)g(x_s-t) \le g(u)$, and symmetry gives
$g(x_s - t) = g(x_s + t) = g(v)$; hence $g(v) \le g(u)$. $\square$

**Theorem 6.5 (Exact vertex preservation).** If $f$ is continuous, symmetric about $x_s$
and concave, then for every $w > 0$ and every $x$, $(S_w f)(x) \le (S_w f)(x_s)$: the
sliding average is maximised *exactly* at $x_s$, with no dependence on $w$.

*Proof.* Theorems 6.2 and 6.3 make $S_w f$ symmetric and concave; apply Lemma 6.4 with
$u = x_s$. $\square$

**Corollary 6.6 (A single number caps every cell).** Under the same hypotheses,
$B_i(o,w) \le (S_w f)(x_s)$ for every offset $o$ and every index $i$.

*Proof.* Theorem 3.1 then Theorem 6.5. $\square$

**Theorem 6.7 (Exact rigid transport: the nearest bin wins).** Under the same hypotheses,
for every offset $o$ and indices $i, j$,
$$ |c_i(o,w) - x_s| \le |c_j(o,w) - x_s| \;\Longrightarrow\; B_j(o,w) \le B_i(o,w). $$
Hence for every offset, the argmax bin is exactly the bin whose centre is nearest $x_s$.

*Proof.* Theorem 3.1 converts both bin values to samples of $S_w f$ at the bin centres;
Lemma 6.4 applied to $g = S_w f$ finishes. $\square$

Theorem 6.7 is the sharp form of the empirical claim. The argmax bin is not a noisy
selection at all: it is determined by pure geometry (nearest centre), so the *absolute*
argmax location is the bin centre nearest to $x_s$, which for any shift lies within
$w/2$ of $x_s$ and moves rigidly with the grid. Residual spread across shifts — the
$0.001$ range observed at $n_b = 100$ — measures the curve's departure from exact
symmetry, not instrument instability.

---

## 7. Auditing the estimator: the three-point quadratic fit

The probe's amplitude and vertex readouts were not raw bin values but the apex of the
parabola through the argmax bar and its neighbours (Definition 2.4). Two theorems
characterise its behaviour.

**Theorem 7.1 (The fit never lowers the amplitude).** If $D = y_- - 2y_0 + y_+ < 0$
(strictly concave fit), then $\hat{y} \ge y_0$.

*Proof.* $\hat y - y_0 = -\dfrac{(y_+-y_-)^2}{8D}$; the numerator is a square, $8D < 0$,
so the quotient is $\le 0$ and its negation is $\ge 0$. $\square$

**Consequence.** A bar of the form "fitted amplitude $\ge 1.10$" is *weaker* than "raw
central value $\ge 1.10$", not stronger. Hence the marginals of the probe — $22/30$ raw
maxima at or above $1.10$ but only $7/30$ fitted amplitudes — cannot be explained by the
fit shaving the peak. The gap must arise upstream, from *which* bar the pipeline supplied
as $y_0$ (in particular from a fit centred on a bar other than the raw argmax, or from a
fit whose curvature was not strictly negative). The correct diagnosis is a bar-selection
defect in the pipeline, misrecorded as a failure of the phenomenon.

**Theorem 7.2 (Non-degenerate fits localise the vertex).** If $y_- \le y_0$,
$y_+ \le y_0$ and $D < 0$, then $|\hat{x}(x_0,w) - x_0| \le w/2$.

*Proof.* $\hat x - x_0 = \dfrac{wA}{2D}$ with $A = y_- - y_+$ and $-D = 2y_0 - y_- - y_+ > 0$.
Then $-D - A = 2(y_0 - y_-) \ge 0$ and $-D + A = 2(y_0 - y_+) \ge 0$, so $|A| \le -D$.
Hence $|wA/(2D)| = w|A|/(2|D|) \le w/2$. $\square$

**Theorem 7.3 (A far vertex certifies a degenerate fit).** If $D < 0$ and
$|\hat{x}(x_0,w) - x_0| > w/2$, then $|y_- - y_+| > -D = |D|$.

*Proof.* Contrapositive of Theorem 7.2: if $|A| \le -D$ then $-D - A = 2(y_0 - y_-) \ge 0$
and $-D + A = 2(y_0 - y_+) \ge 0$, i.e. $y_- \le y_0$ and $y_+ \le y_0$, so Theorem 7.2
applies and gives $|\hat x - x_0| \le w/2$. $\square$

**Consequence.** The single erratic cell — $n_b = 33$, fitted vertex $0.19$ away, while
its own argmax bin centre was $0.01$ from the consensus $u^{*}$ — is *certified* by
Theorem 7.3 to have had neighbour asymmetry exceeding curvature. That is the numerical
signature of an ill-conditioned three-point fit: a nearly flat cluster in which the
denominator $D$ is small and the apex flies far outside the sampled range. It is
evidence about the estimator's conditioning, not about the feature's stability. In
particular, a pipeline that filters on $|A| \le |D|$ would have excluded this cell a
priori.

---

## 8. Auditing the controls: thresholds must know the bin count

The probe's contamination check applied a *flat* amplitude bar of $1.02$ to control
cells, independently of the bin count. Three cells breached it, at $1.0215$–$1.0305$,
and all three had $n_b \in \{50, 66, 100\}$ — the three finest binnings. The mechanical
precedence chain read this as "artefact-contaminated". The following two elementary
results show the bar was mis-specified.

**Theorem 8.1 (A flat threshold loses control under refinement).** Suppose each of $n$
bins independently exceeds a fixed level with probability $p \in (0,1]$. Then the
probability that at least one exceeds it is $1 - (1-p)^n$, and
$$ \lim_{n \to \infty} \big(1 - (1-p)^n\big) \;=\; 1. $$

*Proof.* $|1 - p| < 1$, so $(1-p)^n \to 0$. $\square$

**Theorem 8.2 (The bin-count-aware threshold controls the family-wise error).** For any
$\alpha \in [0,1]$ and any $n \in \mathbb{N}$,
$$ 1 - \Big(1 - \frac{\alpha}{n}\Big)^{n} \;\le\; \alpha. $$

*Proof.* For $n = 0$ the left side is $0 \le \alpha$. For $n \ge 1$, $\alpha/n \le 1$, so
$-\alpha/n \ge -2$ and Bernoulli's inequality gives
$(1 - \alpha/n)^n \ge 1 + n\cdot(-\alpha/n) = 1 - \alpha$; rearrange. $\square$

**Consequence.** A bin-count-agnostic bar is *guaranteed* to be breached once the grid is
fine enough, purely by extreme-value behaviour of $n$ bin counts, whatever the data. The
correct construction uses the per-bin level $\alpha/n$; with $\alpha = 0.05$ and
$n = 100$ this is the "$nb$-aware" ceiling at $1.05$. The observed breaches at
$1.0215$–$1.0305$ correspond to two-sided multinomial extremes at $z \approx +3.05$ and
$z \approx -3.45$, exactly the measured extreme-value ceiling for $n \in \{50,66,100\}$,
and they sit strictly inside $1.05$. They are the expected behaviour of the null, not
contamination.

The mechanical verdict string is therefore retained as an audit record — it is the honest
output of the rule as pre-registered — but its *leak semantics* are falsified: the same
cells that breach the flat bar exhibit both hump persistence (Theorem 4.3) and rigid
vertex transport (Theorems 6.1, 6.7), which contamination by a binning artefact cannot
produce.

---

## 9. Reinterpreting the probe

Assembling §§3–8 against the table of §1.2:

1. **Hump persistence, $30/30$, amplitudes $1.0706$–$1.2960$.** Not an artefact candidate:
   by Theorem 4.3 each reading certifies that the curve attains that value. The
   "vanish" precondition (some cell falling below $1.03$) was unmet in $0/30$ cells,
   which is what the certificate plus the deflation law of §5.1 predict for a genuine
   feature at the observed widths.
2. **Absolute vertex $0.6482$–$0.6492$ across all five shifts at $n_b = 100$.** Predicted
   by Corollary 3.4 plus Theorem 6.1 (general) and Theorem 6.7 (sharp). With
   $w = 0.01$, Theorem 6.7 alone bounds the argmax-centre displacement by $w/2 = 0.005$;
   the observed spread of $0.001$ is well inside this.
3. **Anchor reproduction.** $1.22636$ against $1.2227$, difference $0.004$, with interior
   bins agreeing to $\le 0.005$; the edge discrepancy is a centre-value versus
   integrated-value convention for the baseline. Theorem 5.4 with $w_1 = w_2 = 0.02$
   bounds the expected cross-implementation discrepancy by $L(w_1+w_2)$, of the observed
   order for a curve of moderate slope.
4. **The single erratic fit at $n_b = 33$.** Certified degenerate by Theorem 7.3.
5. **Amplitude bar $7/30$ against raw $22/30$.** By Theorem 7.1 the fit cannot be the
   cause; the defect is in the bar's construction.
6. **Three breaches of the flat $1.02$ bar.** Expected by Theorem 8.1; inside the aware
   $1.05$ ceiling of Theorem 8.2.

**Verdict.** A *stable geometric window feature* at $u^{*} \approx 0.65$. What was refuted
is a specific operationalisation of significance — a fitted-apex amplitude bar at $1.10$
required to hold in $80\%$ of cells, achieved in $0/30$ when conjoined with the vertex
and shape bars. The geometry channel remains open, and no breakthrough is claimed.

Two pre-grid amendments were made and are recorded here for completeness: the treatment
baseline $M$ was replaced by a mixture-Dickman model after a spurious edge peak of
$R = 1.49$ appeared in bin $0$ under the previous convention, and the control denominator
was replaced by a uniform-sampling null after the previous control produced a
manufactured shape of amplitude $1.3611$. Both amendments preceded the grid run; no
registered bar was altered. Uncertainty quantification used a cluster bootstrap with
$2000$ replicates at a single seed. The analysis is pure reanalysis of stored curves; no
new sampling was performed.

---

## 10. A parameter-free shape test

Theorems 7.1–7.3 show that the trouble with the fitted-apex pipeline is intrinsic: it has
a free parameter (the fitted curvature) that can become degenerate. The sampling identity
suggests replacing it with a statistic that has none.

**Theorem 10.1 (Discrete curvature sign certificate).** Let $f$ be continuous and
concave, $w > 0$. Then for every $x$,
$$ (S_w f)(x + w) - 2 (S_w f)(x) + (S_w f)(x - w) \;\le\; 0, $$
and consequently, for every offset $o$ and every index $i$,
$$ B_{i+1}(o,w) - 2 B_i(o,w) + B_{i-1}(o,w) \;\le\; 0. $$

*Proof.* Concavity of $S_w f$ (Theorem 6.3) at the midpoint:
$\tfrac12 (S_wf)(x+w) + \tfrac12 (S_wf)(x-w) \le (S_wf)(x)$. For the histogram form, note
$c_{i\pm1}(o,w) = c_i(o,w) \pm w$ and apply Theorem 3.1. $\square$

This is a shape test with *no fitted parameter*: the sign of the second difference of
consecutive bar heights is a faithful readout of local concavity, valid for every bin
width and every offset simultaneously, and it cannot suffer the degeneracy of the
$n_b = 33$ cell because there is no denominator. It is the cheap end of the named
follow-up — a binning-independent shape test — and it can be applied cell by cell across
the whole $6 \times 5$ grid without recalibration.

---

## 11. Discussion

### 11.1 What is invariant, and in what sense

| Quantity | Offset dependence | Width dependence |
|---|---|---|
| Existence of a bar $\ge c$ | none needed (certificate, Thm 4.3) | none needed |
| Amplitude | none beyond sampling (Thm 3.1) | $O(Lw)$; exactly $kw^2/12$ for a parabola |
| Argmax bin *label* | drifts by construction (Thm 3.2) | changes with $w$ |
| Argmax bin *centre* | transports rigidly (Thm 3.3, 6.7) | within $w/2 + (L/\kappa)w$ of $x_s$ |
| Second difference sign | none (Thm 10.1) | none for concave $f$ |
| Fitted apex height | inherits sampling; $\ge y_0$ (Thm 7.1) | as above, plus fit bias |
| Fitted apex position | degenerate if $\vert A\vert > \vert D\vert$ (Thm 7.3) | as above |

The pattern is unambiguous. The functionals with no free parameters (existence,
amplitude, centre, curvature sign) are invariant or invariant-up-to-computable-bias. The
functionals introduced by the estimator (fitted apex, flat threshold) are the ones that
fail, and they fail in characterisable ways.

### 11.2 Methodological reading

The folk rule "vary the bin width" is vindicated with a precise justification: the
one-sided certificate makes *survival* meaningful (nothing can be conjured), and rigid
transport makes *positional agreement in absolute coordinates* meaningful. The rule's
usual failure mode is also identified: the analyst compares bin *labels* instead of
absolute positions, and then reports the drift that Theorem 3.2 guarantees as
instability.

More generally, the episode illustrates a failure mode of mechanically registered
analysis chains. Every individual rule was defensible; the composition emitted
"artefact-contaminated" because one rule (the flat control bar) had the wrong asymptotic
form in $n$. Pre-registration protects against post hoc bar-shifting; it does not protect
against a bar that is mathematically incapable of controlling what it claims to control.
The remedy is not to abandon registration but to require that each registered threshold
carry a proof of its own validity at the resolutions it will be applied to — precisely
Theorem 8.2 rather than a flat constant.

### 11.3 Limitations

The sharp results of §6.2 assume exact symmetry and concavity of the curve near the peak;
the observed feature is only approximately symmetric, which is why the general $O(w)$
bound of Theorem 6.1 is the honest one for the data. The Lipschitz constant $L$ and cone
constant $\kappa$ are not estimated here; converting Theorems 5.4 and 6.1 into numerical
error bars requires them. The extreme-value calibration of §8 uses an independence
approximation across bins, which is exact only asymptotically for multinomial counts. And
the bootstrap uncertainty in the source experiment used a single seed.

---

## 12. Future directions

### Direction 1 — Curvature-sign certificates for box-averaged windows

**Conjecture.** For $f \in C^2$, the second difference of consecutive bin averages of
width $w$ equals $w \cdot (f'' \star \Lambda_w)(x)$ for the triangular (Bartlett) kernel
$\Lambda_w$, so the *sign pattern* of the histogram's discrete curvature is a faithful,
unbiased readout of the sign pattern of $f''$ smoothed at scale $w$ — with no fitted
parameters and hence no fit degeneracy of the $n_b = 33$ kind.

The key insight is that the box average is a convolution, so second-differencing the
histogram commutes with differentiating the curve, turning a fitted-vertex test into a
kernel-smoothing statement with an analytic error term. The sampling identity already
reduces the whole $30$-cell grid to a single offset-free function; the only missing
ingredient is a $C^2$ transfer lemma. Theorem 10.1 is the sign-only special case for
globally concave $f$; the conjecture upgrades it to a quantitative local statement.

### Direction 2 — Exact vertex rigidity beyond symmetry

**Conjecture.** The symmetry hypothesis in Theorem 6.7 can be weakened to *log-concavity
plus a one-sided skew bound*: if $f$ is log-concave and
$|f(x_s + t) - f(x_s - t)| \le \varepsilon t^2$ for all $t$, then the sliding-average
vertex lies within $C\varepsilon w^2$ of $x_s$ — a *second-order*, not first-order,
transport error.

The key insight is that the first-order term in the vertex displacement of a box average
is exactly the local skewness, so any curve whose skewness vanishes to second order
inherits quadratic rather than linear vertex rigidity. This would explain the observed
$0.001$ spread at $w = 0.01$, which is an order of magnitude tighter than the
first-order prediction $w/2 = 0.005$.

### Direction 3 — Calibrated, binning-free significance

Combine Theorem 10.1 with an analytic standard error for the second difference under the
null. Because the statistic is linear in the data with an explicit kernel, its variance
under a uniform-sampling null is computable in closed form, giving a significance test
with no bootstrap, no seed dependence, and no fitted curvature — the direct replacement
for the operationalisation that failed.

---

## 13. Conclusion

Every histogram bar is a sample of one offset-free function, the box-kernel sliding
average. From that single identity the entire invariance structure of a windowed hump
follows: existence of amplitude is certified one-sidedly and can never be manufactured;
amplitude is binning-independent to $O(Lw)$, and exactly $kw^2/12$-deflated for a
parabolic peak; vertex position transports rigidly with the grid, to $O(w)$ in general
and exactly under symmetry and concavity. What is *not* invariant is anything the analyst
adds: the apex of a three-point fit, which can only inflate the amplitude and which
diverges precisely when neighbour asymmetry exceeds curvature; and a control threshold
that ignores the bin count, whose family-wise error tends to one under refinement.

For the motivating data the conclusion is a clean separation of phenomenon from
instrument. The mid-window feature at $u^{*} \approx 0.65$ is a stable geometric property
of the curve, present in every one of thirty independent binnings, with an absolute
location pinned to a thousandth. The pre-registered significance test failed, and it
failed for reasons that are now theorems about the test rather than facts about the
curve. The geometry channel stays open; the next test should have no free parameters at
all.
