# Window Saturation, the Matched Filter, and the Interior-Argmax Certificate

**Author:** Aristotle
**Date:** 2026-08-26

## Abstract

A widespread empirical practice scores a family of predictors by aggregating
them into a single *window statistic* $S_{w,B} = \sum_{i<B} w_i v_i$, regressing
a response $y$ on it, and reading off the cutoff $B^\star$ at which the
coefficient of determination $R^2$ is maximised — the "saturation location". We
develop the exact theory of this curve for pairwise orthogonal columns and show
that the standard interpretation of $B^\star$ is untenable.

We prove: (i) a residual decomposition identifying the window score with the
ordinary-least-squares $R^2$ and simultaneously yielding OLS optimality and
$0 \le R^2 \le 1$; (ii) an exact one-step law computing
$R^2(w,B{+}1) - R^2(w,B)$ in closed form, with an iff criterion for a cutoff step
to help, whose corollaries are that a response-orthogonal column with nonzero
weight strictly *dilutes* the score while a column at least as efficient as the
running slope strictly raises it; (iii) a saturation theorem — a matched signal
block followed by pure noise produces a strictly unimodal curve with a *unique
interior* argmax; (iv) matched-filter dominance: the weight $w_i = a_i/s_i$
maximises the score at every cutoff simultaneously, its curve is monotone in $B$,
and $E(m)/\|y\|^2$ with $E(B) = \sum_{i<B} a_i^2/s_i$ is a global cap on the
entire instrument, attained; (v) the *interior-argmax certificate*: a strict
interior maximum of a measured curve proves the weight in use is not the matched
filter, up to scale; (vi) a peak-margin identity showing the drop from an
interior peak to the far cutoff equals the peak score times the relative added
mass, together with a sharp $\delta/2$ stability threshold for the argmax under
perturbations; (vii) a realizability theorem — within *any* fixed orthogonal
column family, *every* interior location $1 \le t < m$ is the unique argmax for a
suitable response, so $B^\star$ carries no information about the columns; and
(viii) a refutation of unimodality: even for orthonormal columns with unit
weights and decreasing per-column efficiencies, the prefix curve can have a
strict interior local minimum and hence two local maxima.

Pairwise balanced $\pm1$ designs of strength two (Hadamard rows being the model
case) are shown to supply window models automatically, and the order-$4$ Hadamard
design furnishes an explicit instance with curve $0, \frac12, 1, \frac23,
\frac12$ and peak margin $\frac12$.

The practical upshot is a reversal of the usual reading: an interior saturation
peak is a *diagnostic of weight mismatch*, not a measurement of where information
in the predictor family runs out.

**Keywords:** window statistic, matched filter, coefficient of determination,
orthogonal design, Hadamard matrix, saturation, argmax stability, unimodality.

---

## 1. Introduction

### 1.1 The empirical instrument

Consider an experiment producing one observation per sampled modulus $N$: a
response $y \in \mathbb{R}^n$ recording, say, a log hit-rate. Explanatory
information is carried by per-prime indicator columns $v_\ell \in \mathbb{R}^n$,
one for each odd prime $\ell$. Rather than fitting a multiple regression on
hundreds of columns, the standard instrument compresses them into a single
weighted aggregate,

$$S_{w,B} \;=\; \sum_{\ell \le B} w(\ell)\, v_\ell ,$$

regresses $y$ on this one predictor, and records $R^2(w,B)$ as the cutoff $B$
runs along a factor-of-two grid. Two knobs exist: the weight $w$ and the cutoff
$B$.

A concrete instance, on $n = 128$ samples with odd primes $3 \le \ell \le 1600$
and the weight $w(\ell) = \ell^{-1/2}$, produced

| $B$ | $R^2$, $\ell^{-1/2}$ | $R^2$, $\ell^{-1}$ | $\Delta R^2$ |
|---|---|---|---|
| 100 | .5279 | .4388 | $+0.0891$ |
| 200 | .5976 | .4621 | $+0.1355$ |
| **400** | **.6242** | .4731 | $+0.1511$ |
| 800 | .5913 | .4748 | $+0.1165$ |
| 1600 | .6137 | .4795 | $+0.1342$ |

Three features invite interpretation. (a) The $\ell^{-1/2}$ curve has a unique
*interior* maximum at $B = 400$. (b) The $\ell^{-1/2}$ curve dominates the
$\ell^{-1}$ curve at *every* cutoff, with no apparent weight-by-cutoff
interaction. (c) The $\ell^{-1}$ curve, recomputed, is a flat plateau above
$B = 200$ whose nominal maximum sits at the *edge*, $B = 1600$, exceeding its
value at $400$ by $0.006$ — noise level. A bootstrap over $500$ resamples split
the argmax as $\{400: 276,\ 1600: 178,\ 200: 37,\ 800: 9\}$, the runner-up
trailing the peak by only $0.0105$.

The customary conclusion — "arithmetic information saturates at $B^\star = 400$"
— treats the peak location as a property of the prime columns. This paper shows
that reading is wrong in a strong and precise sense, and replaces it with correct
statements.

### 1.2 Contributions

We isolate the mathematics of window curves for an orthogonal-increment model,
proving the results listed in the abstract. The theory is elementary in its
ingredients (a residual identity and one algebraic step law) but the conclusions
are counterintuitive and directly actionable:

* the *shape* observed in the data (rise, interior peak, fall) is fully
  explained, by dilution rather than by exhaustion of information;
* the *dominance* observed in the data (one weight above another at every
  cutoff) is the shadow of a genuine extremal principle;
* the *location* of the peak is proved to be uninformative about the columns;
* the *bimodality* of the bootstrap tail is proved to be an expected feature,
  quantitatively predicted by the peak-margin identity and by a sharp stability
  threshold, and is compatible with genuinely non-unimodal curves.

### 1.3 Notation

Throughout, $\langle u, v\rangle = \sum_{j=1}^n u_j v_j$ is the Euclidean inner
product on $\mathbb{R}^n$ and $\|u\|^2 = \langle u,u\rangle$. Sums $\sum_{i<B}$
run over $i = 0,\dots,B-1$; empty sums are $0$.

---

## 2. The window model

**Definition 2.1 (Window model).** A *window model* of size $(n,m)$ consists of
columns $v_0, \dots, v_{m-1} \in \mathbb{R}^n$ and a response
$y \in \mathbb{R}^n$ such that

1. $\|v_i\|^2 > 0$ for all $i < m$,
2. $\langle v_i, v_j\rangle = 0$ for all $i \ne j$ with $i,j < m$,
3. $\|y\|^2 > 0$.

We write $s_i = \|v_i\|^2$ (the *mass* of column $i$) and
$a_i = \langle v_i, y\rangle$ (its *signal*).

Condition (2) is the mathematical idealisation of "distinct primes contribute
independent information". Section 7 discusses relaxing it; Section 6 shows a
combinatorial supply of models satisfying it exactly.

**Definition 2.2 (Window statistic and score).** For a weight $w : \mathbb{N} \to
\mathbb{R}$ and a cutoff $B \le m$, set

$$S_{w,B} = \sum_{i<B} w_i v_i, \qquad
A_B = \sum_{i<B} w_i a_i, \qquad
\Sigma_B = \sum_{i<B} w_i^2 s_i,$$

and define the *window score*

$$R^2(w,B) \;=\; \frac{A_B^2}{\Sigma_B \,\|y\|^2}$$

(with the convention $0/0 = 0$, so $R^2(w,0)=0$).

**Lemma 2.3 (The scalars are the right ones).** For every $B \le m$,
$\langle S_{w,B}, y\rangle = A_B$ and $\|S_{w,B}\|^2 = \Sigma_B$.

*Proof.* Expand and exchange the order of summation. For the second identity,
each cross term $w_i w_k \langle v_i, v_k\rangle$ with $i \ne k$ vanishes by
orthogonality, leaving the diagonal $\sum_{i<B} w_i^2 s_i$. $\square$

Thus $R^2(w,B) = \langle S,y\rangle^2 / (\|S\|^2\|y\|^2)$ with $S = S_{w,B}$: the
squared cosine between the window statistic and the response.

### 2.1 The residual decomposition

**Theorem 2.4 (Residual decomposition).** Let $x, y \in \mathbb{R}^n$ with
$\|x\|^2 > 0$, $\|y\|^2 > 0$, and write
$\mathrm{Rsq}(x,y) = \langle x,y\rangle^2/(\|x\|^2\|y\|^2)$. Then for every
$b \in \mathbb{R}$,

$$\|y - bx\|^2 \;=\; \|y\|^2\bigl(1 - \mathrm{Rsq}(x,y)\bigr)
\;+\; \|x\|^2\Bigl(b - \frac{\langle x,y\rangle}{\|x\|^2}\Bigr)^{\!2}.$$

*Proof sketch.* Expand $\|y-bx\|^2 = \|y\|^2 - 2b\langle x,y\rangle + b^2\|x\|^2$
and complete the square in $b$; the constant term is
$\|y\|^2 - \langle x,y\rangle^2/\|x\|^2$, which is
$\|y\|^2(1-\mathrm{Rsq}(x,y))$. $\square$

**Corollary 2.5 (OLS optimality and calibration).**
(i) For every $b$, $\|y-bx\|^2 \ge \|y\|^2(1-\mathrm{Rsq}(x,y))$, with equality
exactly at the OLS slope $b = \langle x,y\rangle/\|x\|^2$.
(ii) $0 \le \mathrm{Rsq}(x,y) \le 1$, and hence $0 \le R^2(w,B) \le 1$ for every
weight and every $B \le m$.

*Proof.* (i) is immediate from Theorem 2.4 since the second term is a
nonnegative square vanishing precisely at the OLS slope. For (ii), nonnegativity
is clear; the upper bound follows by evaluating Theorem 2.4 at the OLS slope and
using that the left-hand side is a sum of squares, so
$\|y\|^2(1-\mathrm{Rsq}) \ge 0$. Degenerate cases ($x=0$ or $y=0$) are handled by
the convention. $\square$

Corollary 2.5(ii) is what licences calling the curve an $R^2$ curve at all: the
score is the genuine fraction of response variance explained by the single
predictor $S_{w,B}$ under least squares.

---

## 3. The step calculus

Write, for a fixed weight $w$ and cutoff $B < m$,

$$p = w_B a_B \quad (\text{signal added}), \qquad c = w_B^2 s_B \quad
(\text{mass added}),$$

so that $A_{B+1} = A_B + p$ and $\Sigma_{B+1} = \Sigma_B + c$.

**Theorem 3.1 (Exact step law).** If $\Sigma_B > 0$ then

$$R^2(w,B{+}1) - R^2(w,B) \;=\;
\frac{\Sigma_B\, p\,(2A_B + p) \;-\; A_B^2\, c}
{\Sigma_B\,(\Sigma_B + c)\,\|y\|^2}.$$

*Proof sketch.* Both sides are rational in $(A_B,\Sigma_B,p,c,\|y\|^2)$; clearing
denominators reduces the claim to the polynomial identity
$(A+p)^2\Sigma - A^2(\Sigma+c) = \Sigma p(2A+p) - A^2 c$. $\square$

**Corollary 3.2 (Step criterion).** If $\Sigma_B > 0$, then
$R^2(w,B) < R^2(w,B{+}1)$ if and only if

$$A_B^2\,c \;<\; \Sigma_B\, p\,(2A_B + p).$$

This is the exact answer to "does the next factor-two cutoff step help?". Two
specialisations carry the empirical content.

**Theorem 3.3 (Noise dilutes).** Let $B < m$ with $\Sigma_B > 0$ and
$A_B \ne 0$. If $a_B = 0$ (the new column is orthogonal to the response) and
$w_B \ne 0$, then

$$R^2(w,B{+}1) \;<\; R^2(w,B),$$

strictly.

*Proof.* Then $p = 0$ and $c = w_B^2 s_B > 0$, so the numerator in Theorem 3.1 is
$-A_B^2 c < 0$ while the denominator is positive. $\square$

This is the mechanism of the descending branch, and its interpretation deserves
emphasis: *saturation is not asymptotic flattening but strict dilution*. Under a
fixed weight, admitting a column with no signal actively destroys score, because
it inflates $\|S_{w,B}\|$ without moving $\langle S_{w,B}, y\rangle$.

**Theorem 3.4 (Signal helps).** Let $B < m$ with $\Sigma_B > 0$ and $A_B > 0$.
If $p > 0$ and $p\,\Sigma_B \ge A_B\, c$, then
$R^2(w,B) < R^2(w,B{+}1)$.

*Proof sketch.* The hypothesis $p\Sigma_B \ge A_B c$ multiplied by $A_B > 0$
gives $A_B p \Sigma_B \ge A_B^2 c$; adding the strictly positive quantity
$\Sigma_B p (A_B + p) > 0$ yields
$\Sigma_B p (2A_B + p) > A_B^2 c$, which is Corollary 3.2. $\square$

The hypothesis $p\Sigma_B \ge A_B c$ says the new column's *efficiency*,
$p/c$, is at least the running slope $A_B/\Sigma_B$ of the window built so far.

---

## 4. The saturation theorem

**Definition 4.1 (Matched signal block).** A weight $w$ is *matched on the block*
$[0,t)$ with slope $\rho$ if $w_i a_i = \rho\, w_i^2 s_i$ for all $i < t$, i.e.
all columns in the block have the same weighted efficiency $\rho$.

**Lemma 4.2.** If $w$ is matched on $[0,t)$ with slope $\rho$, then
$A_B = \rho\,\Sigma_B$ for every $B \le t$.

*Proof.* Induction on $B$: the base case is $0 = \rho\cdot 0$, and the step adds
$w_B a_B = \rho\, w_B^2 s_B$ to both sides. $\square$

**Theorem 4.3 (Saturation: unique interior argmax).** Let $M$ be a window model,
$1 \le t \le m$, and $w$ a weight such that

* (matched signal) $w_i a_i = \rho\, w_i^2 s_i$ and $w_i a_i > 0$ for all $i<t$;
* (pure noise afterwards) $a_i = 0$ for all $t \le i < m$;
* (nonzero tail weights) $w_i \ne 0$ for all $t \le i < m$.

Then $B \mapsto R^2(w,B)$ is strictly increasing on $\{0,1,\dots,t\}$ and
strictly decreasing on $\{t,\dots,m\}$. Consequently

$$R^2(w,B) < R^2(w,t) \qquad \text{for every } B \le m,\ B \ne t,$$

so the argmax set over the cutoff grid is exactly $\{t\}$.

*Proof sketch.* Positivity of $w_ia_i$ on the block gives $A_B > 0$ and
$\Sigma_B > 0$ for $1 \le B \le t$. By Lemma 4.2 the running slope is constantly
$\rho$, so each new block column satisfies $p\Sigma_B = A_B c$ with $p>0$ and
Theorem 3.4 applies: strict increase at every step below $t$. From the empty
window the score jumps from $0$ to a positive value. For $B \ge t$ the numerator
is frozen ($A_B = A_t$ for all $B \ge t$, since $a_i = 0$ beyond $t$) while each
step adds positive mass, so Theorem 3.3 gives strict decrease. Chaining strict
one-step inequalities gives the two monotone branches, and the displayed
conclusion follows. $\square$

Theorem 4.3 reproduces the qualitative shape of the motivating data exactly: a
strict rise to an interior location, a strict fall thereafter. Note what it does
*not* say: nothing here identifies $t$ with a property of the columns. The
hypotheses are joint conditions on the weight *and* the response.

**Example 4.4 (Explicit realisation).** Take $n = m = 4$, columns the standard
basis $e_0,\dots,e_3$ of $\mathbb{R}^4$, and response $y = (1,1,0,0)$. Then
$s_i = 1$ for all $i$, $a = (1,1,0,0)$, and $\|y\|^2 = 2$. With unit weights the
hypotheses hold with $\rho = 1$, $t=2$, and the curve is

$$R^2(0),\dots,R^2(4) \;=\; 0,\ \tfrac12,\ 1,\ \tfrac23,\ \tfrac12 .$$

The maximum is a perfect fit at the interior cutoff $t = 2$, after which each
noise column strictly dilutes.

---

## 5. The matched filter and the interior-argmax certificate

**Definition 5.1 (Matched filter; explained signal).** The *matched filter* of a
window model is the weight $w^{\mathrm{mf}}_i = a_i/s_i$ — the per-column
single-predictor regression slope. The *explained signal* is

$$E(B) \;=\; \sum_{i<B} \frac{a_i^2}{s_i}, \qquad B \le m.$$

**Lemma 5.2.** For $B \le m$: the matched filter has
$A_B = \Sigma_B = E(B)$, hence

$$R^2(w^{\mathrm{mf}},B) \;=\; \frac{E(B)}{\|y\|^2}.$$

*Proof.* $w^{\mathrm{mf}}_i a_i = a_i^2/s_i$ and
$(w^{\mathrm{mf}}_i)^2 s_i = a_i^2/s_i$. Substituting into Definition 2.2 and
cancelling gives the score. $\square$

**Theorem 5.3 (No interior maximum for the matched filter).** $E$ is
nondecreasing, hence $B \mapsto R^2(w^{\mathrm{mf}},B)$ is nondecreasing on
$\{0,\dots,m\}$: widening the window never hurts the matched filter.

*Proof.* $E$ is a sum of nonnegative terms $a_i^2/s_i$; divide by $\|y\|^2>0$.
$\square$

**Theorem 5.4 (Matched-filter dominance).** For every weight $w$ and every
cutoff $B \le m$,

$$R^2(w,B) \;\le\; R^2(w^{\mathrm{mf}},B).$$

*Proof sketch.* If $\Sigma_B = 0$ then every weight used in the window
annihilates its column's mass, so $A_B = 0$ and the left side is $0$. Otherwise,
write $u_i = w_i \sqrt{s_i}$ and $g_i = a_i/\sqrt{s_i}$ for $i < B$. Then
$A_B = \sum_{i<B} u_i g_i$, $\Sigma_B = \sum_{i<B} u_i^2$ and
$E(B) = \sum_{i<B} g_i^2$. Cauchy–Schwarz gives
$A_B^2 \le \Sigma_B \, E(B)$, i.e. $A_B^2/\Sigma_B \le E(B)$; dividing by
$\|y\|^2$ finishes. $\square$

This is the exact form of the empirically observed "plateau raised everywhere":
dominance holds at *every* cutoff simultaneously, so a better weight shifts the
whole curve up rather than trading one region for another. Observing
$\Delta R^2 > 0$ at all five cutoffs with no weight-by-cutoff interaction, as in
the motivating table, is the signature of moving toward the matched direction.

**Theorem 5.5 (Global cap, attained).** For every weight $w$ and every $B \le m$,

$$R^2(w,B) \;\le\; \frac{E(m)}{\|y\|^2},$$

and the bound is attained by the matched filter at the full window:
$R^2(w^{\mathrm{mf}},m) = E(m)/\|y\|^2$.

*Proof.* Combine Theorem 5.4 with the monotonicity of $E$; attainment is
Lemma 5.2 at $B=m$. $\square$

Theorem 5.5 is a statement about the entire two-parameter design space
(weight $\times$ cutoff): a single number bounds everything the instrument can
ever report, and it is computable directly from the column-wise statistics.

**Lemma 5.6 (Scale invariance).** For $c \ne 0$, $R^2(c\,w, B) = R^2(w,B)$.

*Proof.* Numerator and denominator scale by $c^2$. $\square$

**Theorem 5.7 (Interior-argmax certificate).** Suppose the measured curve of a
weight $w$ satisfies $R^2(w,m) < R^2(w,t)$ for some $t < m$ — an interior cutoff
strictly beating the far cutoff. Then there is **no** constant $c \ne 0$ with
$w_i = c\,w^{\mathrm{mf}}_i$ for all $i < m$: the weight in use is provably not
the matched filter, not even up to global rescaling.

*Proof.* If $w = c\,w^{\mathrm{mf}}$ on $[0,m)$, then by Lemma 5.6 and the fact
that the score at cutoff $B$ depends only on the weight's values below $B$, we get
$R^2(w,B) = R^2(w^{\mathrm{mf}},B)$ for all $B \le m$. Theorem 5.3 then gives
$R^2(w,t) \le R^2(w,m)$, contradicting the hypothesis. $\square$

This inverts the standard interpretation. An interior maximum is not evidence
that predictor information ceases beyond $B^\star$; it is a *certificate of
weight mismatch*, and it guarantees, by Theorem 5.4, the existence of an
alternative weight strictly better at the far cutoff and no worse anywhere.

---

## 6. Peak margins, stability, and $\pm 1$ designs

### 6.1 How far the peak sits above the edge

**Theorem 6.1 (Peak-margin identity).** Suppose $a_i = 0$ for all $t \le i < m$
and $\Sigma_t > 0$. Then

$$R^2(w,t) - R^2(w,m) \;=\; R^2(w,t)\cdot \frac{\Sigma_m - \Sigma_t}{\Sigma_m},$$

where $(\Sigma_m - \Sigma_t)/\Sigma_m$ is the *relative added mass* of the
columns admitted after $t$.

*Proof.* The numerator is frozen beyond $t$, so
$R^2(w,m) = A_t^2/(\Sigma_m\|y\|^2)$ and
$R^2(w,t) - R^2(w,m) = \frac{A_t^2}{\|y\|^2}\bigl(\frac{1}{\Sigma_t} -
\frac{1}{\Sigma_m}\bigr) = R^2(w,t)\frac{\Sigma_m-\Sigma_t}{\Sigma_m}$. $\square$

**Corollary 6.2.** If the relative added mass is at most $\varepsilon$, the peak
margin is at most $R^2(w,t)\,\varepsilon$.

Hence a near-tie between an interior peak and the far cutoff is *equivalent* to
the tail columns carrying little weighted mass — precisely the situation for a
decaying weight such as $\ell^{-1/2}$ over the tail $400 < \ell \le 1600$. The
observed margin of $0.0105$ in the motivating experiment is therefore not
anomalous but predicted by the geometry of the weight.

**Theorem 6.3 (Matched plateau).** If $a_i = 0$ for all $t \le i < m$, then
$R^2(w^{\mathrm{mf}},B) = R^2(w^{\mathrm{mf}},t)$ for all $t \le B \le m$.

*Proof.* $E(B) = E(t)$, since every added term $a_i^2/s_i$ vanishes; apply
Lemma 5.2. $\square$

So the matched filter's argmax set is the whole tail $[t,m]$ and always contains
the *edge*. A matched (or near-matched) weight structurally cannot exhibit a
unique interior maximum. This explains the ledger catch in the motivating
experiment: the harmonic-weight curve, recomputed, is a flat plateau with a
noise-level edge maximum. The interior-peak phenomenon is weight-specific by
theorem, not by accident.

### 6.2 Sharp stability of the measured argmax

**Theorem 6.4 (Stability under small perturbations).** Let $G$ be a finite grid
of cutoffs, $f$ the true curve, $t \in G$, and $\delta > 0$ with
$f(u) + \delta \le f(t)$ for all $u \in G \setminus \{t\}$. If $g$ satisfies
$|g(u)-f(u)| < \delta/2$ for all $u \in G$, then $g(u) < g(t)$ for all
$u \in G\setminus\{t\}$: the argmax is unchanged.

*Proof.* $g(t) > f(t) - \delta/2 \ge f(u) + \delta/2 > g(u)$. $\square$

**Theorem 6.5 (Sharpness).** Let $f$ be a curve, $t \ne u_0$, $\delta > 0$ with
$f(t) - f(u_0) = \delta$. For every $\varepsilon > 0$ there is a perturbation $g$
with $\sup_u |g(u)-f(u)| \le \delta/2 + \varepsilon$ and $g(t) < g(u_0)$.

*Proof.* Raise $f$ at $u_0$ by $\delta/2+\varepsilon$ and lower it at $t$ by the
same amount; the gap $\delta$ is overturned by $2\varepsilon$. $\square$

Together, Theorems 6.4 and 6.5 identify $\delta/2$ — half the top-two gap — as
the exact noise budget of an argmax report. A bootstrap argmax distribution with
a substantial second mode is therefore *expected* whenever resampling noise is
comparable to half the top-two gap, and carries no implication that the estimator
is defective. The honest report in that regime is a saturation *region*
("saturation reached by $400$, no further gain through $1600$"), not a point.

### 6.3 $\pm 1$ designs as window models

**Definition 6.6 (Sign design).** A *sign design* of size $(n,m)$ is a family
$c_0, \dots, c_{m-1} \in \{\pm1\}^n$ that is *pairwise balanced*: any two
distinct columns agree on exactly half the samples, equivalently
$\sum_{j} c_i(j)c_k(j) = 0$ for $i \ne k$; together with a response
$y$ with $\|y\|^2>0$. Equivalently, the columns form an orthogonal array of
strength two; the rows of a Hadamard matrix are the canonical example.

**Proposition 6.7.** Every sign design with $n > 0$ is a window model, with all
column masses equal to $n$.

*Proof.* $\|c_i\|^2 = \sum_j c_i(j)^2 = n$ since entries are $\pm 1$; pairwise
orthogonality is the balance condition. $\square$

**Example 6.8 (Order-4 Hadamard window).** Take the four rows of the order-$4$
Hadamard matrix,
$h_0=(1,1,1,1)$, $h_1=(1,-1,1,-1)$, $h_2=(1,1,-1,-1)$, $h_3=(1,-1,-1,1)$, as
columns, with response $y = h_0 + h_1 = (2,0,2,0)$. Then $s_i = 4$ for all $i$,
$a = (4,4,0,0)$, $\|y\|^2 = 8$. Unit weights are matched on the signal block
with $\rho = 1$ and $t = 2$, so Theorem 4.3 applies: the curve is

$$0,\ \tfrac12,\ 1,\ \tfrac23,\ \tfrac12 ,$$

with unique interior argmax at $t=2$. Its peak margin is
$R^2(2) - R^2(4) = \tfrac12$, matching Theorem 6.1 exactly:
$1 \cdot \frac{16-8}{16} = \frac12$.

---

## 7. What the peak location does *not* tell you

### 7.1 Every interior location is realisable

**Theorem 7.1 (Realizability).** Let $v_0,\dots,v_{m-1} \in \mathbb{R}^n$ be
pairwise orthogonal and nonzero, and let $1 \le t < m$ be arbitrary. Put
$y = v_0 + \cdots + v_{t-1}$. Then $(v, y)$ is a window model and the unit-weight
curve satisfies

$$R^2(\mathbf{1},B) < R^2(\mathbf{1},t) \qquad \text{for all } B \le m,\ B\ne t,$$

so its argmax set is exactly $\{t\}$.

*Proof sketch.* By orthogonality, $\langle v_k, y\rangle = s_k$ if $k < t$ and
$0$ otherwise, and $\|y\|^2 = \sum_{i<t}s_i > 0$. Hence with unit weights the
first $t$ columns satisfy $a_i = s_i$, i.e. the matched condition of
Theorem 4.3 with $\rho = 1$ and $a_i = s_i > 0$, while every later column is pure
noise with nonzero (unit) weight. Theorem 4.3 gives the conclusion. $\square$

**Corollary 7.2 ($\pm1$ specialisation).** Inside a fixed sign design of strength
two — a fixed Hadamard-type family — every interior location $1 \le t < m$ occurs
as the unique argmax for a suitable response.

The consequence is decisive for interpretation. Within a *fixed* column family,
the peak location $B^\star$ can be moved anywhere by changing the response alone.
A measured $B^\star$ therefore constrains the response-weight pair; it is not a
measurement of any structural property of the columns. Statements of the form
"prime information saturates at $400$" do not follow from an observed peak at
$400$.

### 7.2 Window curves need not be unimodal

The saturation theorem yields a strictly unimodal curve, which suggests that any
observed second mode must be estimation noise. It is not so.

**Theorem 7.3 (Failure of unimodality).** Call $f$ *unimodal on* $\{0,\dots,m\}$
if there is $t \le m$ with $f$ nondecreasing on $[0,t]$ and nonincreasing on
$[t,m]$. Take $n=m=3$, columns the standard orthonormal basis $e_0,e_1,e_2$ of
$\mathbb{R}^3$, unit weights, and response $y = (3,1,1)$, so that
$a = (3,1,1)$, $s = (1,1,1)$ and $\|y\|^2 = 11$. Then

$$R^2(1) = \frac{27}{33}, \qquad R^2(2) = \frac{24}{33}, \qquad
R^2(3) = \frac{25}{33},$$

so $R^2(2) < R^2(1)$ and $R^2(2) < R^2(3)$. The curve has a strict interior local
*minimum* at $B=2$, hence two distinct strict local maxima at $B=1$ and $B=3$,
and is not unimodal.

*Proof.* Direct computation: $A_1 = 3, \Sigma_1 = 1$ gives $9/11 = 27/33$;
$A_2 = 4, \Sigma_2 = 2$ gives $16/(2\cdot 11) = 8/11 = 24/33$;
$A_3 = 5, \Sigma_3 = 3$ gives $25/(3\cdot 11) = 25/33$. Unimodality would force
either a nondecreasing step at $B=1$ or a nonincreasing step at $B=2$; both
fail. $\square$

Two features of this counterexample block the standard escape routes. The columns
are perfectly *orthonormal* — all masses equal, so no mass heterogeneity is
responsible. And the per-column efficiencies $a_i/s_i = 3,1,1$ are already sorted
in nonincreasing order, so the bimodality is not an artefact of scanning columns
in an unfortunate order.

The mechanism is that dilution is self-limiting. The second column has efficiency
$1$ against a running slope of $3$, so it dilutes badly; but it drags the running
slope down to $2$, and the third column — of the same efficiency $1$ — is then
much less out of step, so accumulation of numerator wins.

**Proposition 7.4 (Same data, matched weight).** For the model of Theorem 7.3,
the matched filter is $w^{\mathrm{mf}} = (3,1,1)$ and its curve is

$$\frac{9}{11}, \qquad \frac{10}{11}, \qquad 1,$$

strictly increasing to a perfect fit.

*Proof.* $E(B) = 9, 10, 11$ for $B = 1,2,3$; apply Lemma 5.2 with $\|y\|^2=11$.
$\square$

So bimodality, like the interior peak of Section 4 and like the location result
of Section 7.1, is a property of the *weight*, not of the columns. Every
pathology of the window curve documented here disappears under the matched
filter.

---

## 8. Algorithms

The theory is directly computational. Three procedures suffice to replace the
usual dial-turning protocol with a defensible one.

**Algorithm A (Window curve evaluation).** Given masses $s_i$, signals $a_i$,
$\|y\|^2$, a weight $w$ and a grid $G$ of cutoffs, compute prefix sums $A_B$ and
$\Sigma_B$ in one left-to-right pass and emit $A_B^2/(\Sigma_B\|y\|^2)$ for
$B \in G$. Cost: $O(m)$ time, $O(1)$ extra space. Correctness is
Definition 2.2 with Lemma 2.3.

**Algorithm B (Matched-filter audit).** Given the same inputs, (1) compute
$E(B) = \sum_{i<B} a_i^2/s_i$ by prefix sum, (2) report the matched curve
$E(B)/\|y\|^2$, which is nondecreasing by Theorem 5.3, (3) report the global cap
$E(m)/\|y\|^2$ of Theorem 5.5, and (4) if the user's weight has
$R^2(w,t) > R^2(w,m)$ for some $t<m$, emit the mismatch certificate of
Theorem 5.7. Cost: $O(m)$.

**Algorithm C (Argmax margin and stability budget).** Compute the curve on the
grid, sort its values, let $\delta$ be the gap between the best and second-best
grid values, and report the pair $(\arg\max, \delta/2)$. By Theorem 6.4 the
argmax is invariant under any perturbation of sup-norm below $\delta/2$; by
Theorem 6.5 there exist perturbations barely exceeding $\delta/2$ that flip it.
When the estimated resampling noise exceeds $\delta/2$, the correct report is a
saturation *region* rather than a location. Cost: $O(|G|\log|G|)$.

Applied to the motivating data with a top-two gap of $0.0105$, Algorithm C
returns a stability budget of $0.00525$ — far below plausible resampling noise on
$n=128$ samples, which is exactly why the bootstrap argmax is bimodal, with mass
$276/500$ at $400$ and $178/500$ at $1600$.

---

## 9. Discussion

### 9.1 Reinterpreting the motivating experiment

The theory permits three precise statements in place of one imprecise one.

1. *Dominance is real and is the right claim.* The $\ell^{-1/2}$ weight beating
   $\ell^{-1}$ at all five cutoffs, with gains $+0.089$ to $+0.151$ and no
   weight-by-cutoff interaction, is the empirical shadow of Theorem 5.4: moving
   toward the matched direction raises the whole curve at once. This is a
   statement about the *instrument* and it is supported.

2. *The interior peak is a diagnosis.* By Theorem 5.7, the very existence of an
   interior maximum at $400$ certifies that $\ell^{-1/2}$ is not the matched
   filter for these data. Something strictly better exists. The correct follow-up
   is not to adopt $B^\star = 400$ as a standard but to estimate $a_i/s_i$ per
   column and audit the resulting matched curve against the cap
   $E(m)/\|y\|^2$.

3. *The location is not a measurement of arithmetic.* By Theorem 7.1, within any
   fixed orthogonal column family every interior location is realisable, so
   $B^\star$ cannot be read as "where prime information stops". By Theorems 6.1
   and 6.4–6.5, the observed $0.0105$ margin makes the location statistically
   soft in a way that is quantitatively predicted rather than surprising.

The harmonic-weight recomputation — a flat plateau with a $+0.006$ edge maximum —
is likewise explained rather than embarrassing: Theorem 6.3 says a weight closer
to matched has its argmax at the edge, and a plateau is precisely what the
matched filter produces once signal columns are exhausted.

### 9.2 Limitations

The results assume exact pairwise orthogonality of the columns. Real per-prime
indicator columns are only approximately orthogonal; Section 10 states the
natural stability conjecture. The model also treats the column statistics
$(s_i,a_i)$ as known, whereas in practice they are estimated, so the curve is
observed with noise — which is exactly why the stability budget of Theorems
6.4–6.5 is part of the recommended report. Finally, the analysis is about a
single aggregated predictor: the multiple-regression alternative (fit all columns
jointly) has a different and in general higher ceiling; the matched filter is the
best *one-dimensional* compression, and Theorem 5.5 caps only what this
instrument can do.

### 9.3 Relation to classical ideas

Theorem 5.4 is a Cauchy–Schwarz statement, and the weight $a_i/s_i$ is the
familiar matched filter of detection theory, here recovered as the pointwise
maximiser over the entire cutoff grid at once rather than at a single fixed
cutoff. What appears to be new in the present treatment is the *inversion*: the
use of the monotonicity of the matched curve as a certificate — an observed
interior peak becomes a proof of mismatch — and the accompanying realizability
and non-unimodality results, which strip the peak location of the structural
meaning experimenters routinely assign to it.

---

## 10. Future directions

**1. Correlated-column window calculus.** All results here assume pairwise
orthogonal columns; real prime-indicator columns are only approximately
orthogonal. Conjecture: if the Gram matrix $G$ of the window columns satisfies
$\|G - D\| \le \varepsilon\,\lambda_{\min}(D)$ for its diagonal part $D$, then
dilution, matched dominance and the peak-margin identity all hold up to a
multiplicative $1 + O(\varepsilon)$. The key insight is that every proof passes
through the two scalars $A = \langle S,y\rangle$ and $\Sigma = \|S\|^2$, and a
Gram perturbation perturbs only $\Sigma$, in a controlled one-sided way.

**2. Interior-argmax certificates as a weight-selection procedure.** Theorem 5.7
is qualitative: an interior peak proves mismatch. Conjecture (quantitative
converse): if the peak at $t$ exceeds the edge value by $\delta$, then the weight
lies at angular distance at least $c\,\delta$ from the matched direction in the
$s$-weighted inner product, with an explicit constant $c$ depending only on
$R^2(t)$. The peak-margin identity turns the observed drop into a relative mass,
and Cauchy–Schwarz turns that mass into an angle; the missing step is the
equality case of Cauchy–Schwarz in the weighted inner product.

**3. How many local maxima can a window curve have?** Section 7.2 shows the curve
need not be unimodal. Conjecture: with $m$ columns of equal mass and
nonincreasing signals $a_1 \ge \cdots \ge a_m \ge 0$, the number of strict local
maxima of $k \mapsto A_k^2/k$ is at most $\lfloor \log_2 m\rfloor + 1$, and this
is sharp for a geometric signal profile. The heuristic is that a new local
maximum requires the running mean to be overtaken by a fresh block of signal,
which costs a constant factor of the accumulated numerator each time.

**4. Prescribed local-maximum sets.** The realizability question for a *single*
interior location is settled by Theorem 7.1 (and by Corollary 7.2 for $\pm1$
designs). The natural next question is which *sets* of local maxima are
realisable inside a fixed orthogonal family, with the non-unimodal example of
Theorem 7.3 as the base case of a general construction.

---

## 11. Conclusion

Window curves are among the most common diagnostic plots in applied quantitative
work, and the location of their maximum is routinely reported as a substantive
finding. The results above show this reading is unsupported for orthogonal
predictor families. The rise-then-fall shape is real, but the fall is dilution by
mass, not exhaustion of information; the peak location is realisable at any
interior cutoff within any fixed column family, so it measures the response and
the weight, not the columns; the curve need not even be unimodal; and, most
sharply, an interior peak is a *certificate* that the weight in use is not
matched, so a strictly better weight exists that dominates it at every cutoff
simultaneously.

What survives, and is worth reporting, is the pair (matched-filter curve, global
cap $E(m)/\|y\|^2$) together with a stability budget equal to half the top-two
gap. That triple is computable in a single linear pass and answers the questions
the dial was being asked to answer — how much of the response is explainable,
whether widening the window still helps, and whether a reported location is a
measurement or a coin flip.
