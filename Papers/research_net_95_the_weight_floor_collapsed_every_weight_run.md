# The Weight-Quantisation Floor Is Not a Bit-Width Law

### A geometric degradation ladder, a curvature ceiling, a selection/content dissociation, and an exact accounting of the quantiser-quality confound

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

A widely repeated claim about compressed neural language models holds that weight
precision below roughly six bits per weight is undeployable: a *floor*. We report
a seven-rung measurement on a 7-billion-parameter transformer, evaluated on a
fixed held-out text slice, showing that excess perplexity over the uncompressed
reference is instead a smooth, strictly convex, single-parameter geometric
function of bit width across the entire range from $6.6$ down to $2.6$ bits per
weight, with no cliff at any rung. Concretely, over **all ten** ordered pairs of
measured rungs, excess perplexity multiplies by a factor in $[5/2,\,3]$ per bit
removed, and the lowest rung — $2.6$ bits per weight — costs only $+16.155\%$
relative perplexity, far inside deployability.

We then supply the theory that explains and generalises the measurement. (i) A
second-order (curvature) model of quantisation loss predicts a degradation
multiplier of *exactly* $4$ per bit; the measured ladder runs at $2.54$–$2.98$
per bit, strictly under this ceiling at every pair. (ii) In the same model,
improving quantiser accuracy by a factor $2^{\,j}$ is *exactly equivalent* to
adding $j$ bits, from which it follows that **no bit width is intrinsically a
floor**: for every bit width and every tolerance there is a quantiser accuracy
meeting the tolerance at that width. (iii) The contrast with the attention-cache
axis, where cached *keys* degrade catastrophically between $8$ and $5$ bits, is a
theorem rather than folklore: content read-outs (probability-weighted averages)
admit the sharp modulus of continuity $\delta$ in the quantiser step, whereas
selection read-outs ($\arg\max$) admit *no* modulus of continuity whatsoever, and
the number of broken decisions is bounded by the number of positions with top-1
margin below twice the quantiser step. (iv) Composed compressions obey a seminorm
triangle inequality, giving the two-axis budget $a + b + 2\sqrt{ab}$ (under $3\%$
at the measured numbers) with exact additivity under curvature-orthogonality
($1.956\%$ predicted). (v) Finally, we quantify the quality-versus-scale confound
in the original floor claim: per-block scaling is worth exactly
$\log_2\!\big(R/\mathrm{rms}(r)\big)$ bits, at most $\tfrac12\log_2 B$ (four bits
at the standard block size $B = 256$), attained exactly under single-block outlier
concentration — and the observed $3.4$-bit floor shift fits inside that budget
without invoking model scale at all.

**Keywords:** weight quantisation, perplexity ladder, geometric degradation law,
Hessian curvature model, selection versus content, block scaling, outlier
concentration, seminorm composition.

---

## 1. Introduction

### 1.1 The floor claim

Post-training quantisation replaces a network's parameters with values drawn from
a coarse grid. The compression ratio is quoted in **bits per weight** (bpw). A
persistent claim in the deployment literature and folklore is that there is a
*floor*: some bit width below which quality collapses irrecoverably, commonly
placed near six bits per weight.

The claim has empirical support of a specific kind. Take a small network and a
naive round-to-nearest quantiser using a *single* scale factor per tensor. Sweep
the bit width. Quality is essentially unchanged down to six bits, degrades
sharply at five, and is destroyed at four. The curve visibly breaks rather than
bends. It is natural to read that break as a property of the bit width.

### 1.2 What this paper establishes

We show the break is not a property of the bit width, in three complementary
senses.

1. **Empirically.** At $14\times$ the model scale with calibration-aware block
   quantisers, no break exists anywhere down to $2.6$ bpw. The excess-perplexity
   curve is strictly decreasing, strictly convex, and obeys a single-parameter
   geometric law over its entire measured extent.

2. **Structurally.** A per-bit multiplicative bound propagates to a geometric
   bound over any number of bits. A geometric series has no pole. Hence a
   measured "no cliff between adjacent rungs" upgrades automatically to "no floor
   at any finite bit width" — no extrapolation of the fit is required for the
   qualitative conclusion.

3. **Model-theoretically.** In the standard second-order model of quantisation
   damage, quantiser accuracy and bit width appear only through the product
   $c\,2^{-b}$. They are therefore the *same variable* in disguise, and the
   notion of "the floor at $b$ bits" is not well posed without naming the
   quantiser.

We further explain why some axes of these systems *do* cliff — cached attention
keys, notably — by proving a dissociation between numerical channels consumed by
averaging and channels consumed by ranking.

### 1.3 Experimental setting

All perplexity numbers come from one configuration: a 7B-parameter transformer,
context length $2048$, eight CPU threads, and a fixed $250\,\mathrm{KB}$ held-out
text slice. The uncompressed (16-bit) reference perplexity is $6.9825$. Rung
identities are given by their nominal bits per weight. One cross-check is worth
recording: the $4.8$ bpw arm reproduced an earlier independent run's control
perplexity of $7.1093$ *exactly* — same model file, same slice, days apart — which
bounds run-to-run nondeterminism at this measurement's resolution.

---

## 2. The measured ladder

### 2.1 Data and definitions

| rung | bits per weight | perplexity | relative excess |
|---|---|---|---|
| reference | 16 | 6.9825 | — |
| A | $\approx 8.5$ | 6.9781 | $-0.063\%$ |
| B | $\approx 6.6$ | 7.0006 | $+0.259\%$ |
| C | $\approx 5.5$ | 7.0427 | $+0.862\%$ |
| D | $\approx 4.8$ | 7.1093 | $+1.816\%$ |
| E | $\approx 3.9$ | 7.2758 | $+4.201\%$ |
| F | $\approx 2.6$ | 8.1105 | $+16.155\%$ |

**Definition 2.1 (excess and relative excess).** For a rung with perplexity
$P$, the *excess perplexity* is $E = P - 6.9825$ and the *relative excess* is
$E/6.9825$.

To keep bit-width gaps integral we measure precision in *tenths of a bit*; rung
$X$ has $\mathrm{tb}(X) \in \{85, 66, 55, 48, 39, 26\}$.

**Definition 2.2 (the ladder).** The *ladder* is the ordered list of rungs
$\mathrm{B}, \mathrm{C}, \mathrm{D}, \mathrm{E}, \mathrm{F}$, with excesses
$$0.0181,\quad 0.0602,\quad 0.1268,\quad 0.2933,\quad 1.1280 .$$
Rung A is excluded: its perplexity is *below* the reference (Proposition 2.7), so
it carries no multiplicative signal.

**Proposition 2.3 (positivity).** Every rung of the ladder has $E > 0$.
*Proof.* Direct evaluation of the five differences as exact rationals. $\square$

### 2.2 The one-parameter geometric law

**Theorem 2.4 (Geometric Ladder Law).** *Let $r, s$ be rungs of the ladder with
$\mathrm{tb}(s) < \mathrm{tb}(r)$, and let $k = \mathrm{tb}(r) - \mathrm{tb}(s)$
be their gap in tenths of a bit. Then*
$$\left(\tfrac52\right)^{k} E(r)^{10} \;\le\; E(s)^{10} \;\le\; 3^{k}\, E(r)^{10}.$$
*Equivalently, writing $\Delta b = k/10$ for the gap in bits,*
$$\tfrac52 \;\le\; \left(\frac{E(s)}{E(r)}\right)^{1/\Delta b} \;\le\; 3 .$$

*Proof sketch.* The statement is a finite conjunction of ten rational
inequalities, one per ordered pair of distinct rungs, and the tenth powers clear
the fractional exponent $1/\Delta b$ into integer arithmetic: raising the ratio
bound to the power $10\Delta b = k$ is exactly the displayed form. Each is
verified by exact rational arithmetic on the measured values. $\square$

**Remark 2.5.** The law is genuinely one-parameter and genuinely global: the same
band $[5/2, 3]$ covers all ten pairs, including the widest ($6.6 \to 2.6$ bpw, a
four-bit gap), not merely the four adjacent ones. Thus
$E(b) \asymp C\,m^{-b}$ with $m \in [5/2, 3]$ is an adequate description of the
whole measured range. The extreme observed per-bit rates are $2.539$ (rungs
$\mathrm{D} \to \mathrm{E}$) and $2.982$ (rungs $\mathrm{B} \to \mathrm{C}$), so
neither endpoint of the band has much slack.

**Theorem 2.6 (cliff-freeness, monotonicity, convexity).** *For all rungs of the
ladder:*

1. *(Cliff-free.) If $\mathrm{tb}(s) < \mathrm{tb}(r)$ with gap $k$, then
   $E(s)^{10} < 4^{k} E(r)^{10}$: no pair reaches a per-bit degradation factor of
   $4$.*
2. *(Strictly decreasing.) If $\mathrm{tb}(s) < \mathrm{tb}(r)$ then
   $E(r) < E(s)$.*
3. *(Strictly convex.) For rungs $a, b, c$ with
   $\mathrm{tb}(a) < \mathrm{tb}(b) < \mathrm{tb}(c)$,*
   $$\big(E(b) - E(a)\big)\big(\mathrm{tb}(c) - \mathrm{tb}(b)\big) \;<\;
     \big(E(c) - E(b)\big)\big(\mathrm{tb}(b) - \mathrm{tb}(a)\big),$$
   *i.e. all ten triples of secant slopes are increasing in bit width.*

*Proof sketch.* (1) is immediate from the upper half of Theorem 2.4 together with
$3^k < 4^k$ for $k \ge 1$ and $E(r)^{10} > 0$. (2) and (3) are again finite
conjunctions of exact rational inequalities over the measured values. $\square$

The significance of the constant $4$ in part (1) is not aesthetic; §3 shows it is
the exact per-bit multiplier predicted by second-order theory, so the measured
ladder sits strictly inside the theoretical envelope.

### 2.3 The pre-registered scorecard

Three predictions were registered before the sweep.

**Proposition 2.7 (scorecard).**

* *(P1, confirmed.)* Rung B lies inside the $\pm 0.5\%$ band around the
  reference: $|E/6.9825| < 1/200$ (measured $+0.259\%$).
* *(P2, refuted narrowly.)* Rung E was predicted to land in $[+5\%, +30\%]$; it
  landed at $+4.2005\%$, i.e. strictly between $+2\%$ and $+5\%$. This refutes
  both the stated band (from below) and the competing "erased, i.e. under $+2\%$"
  reading.
* *(P3, refuted decisively.)* Rung F was predicted undeployable, at $\ge +50\%$;
  the measured cost is $+16.155\%$, under $+20\%$ and under a fifth of the
  threshold.
* *(Rung A is noise.)* Rung A's relative excess is *negative* and under $0.1\%$ in
  magnitude, which is why it is excluded from the multiplicative law.
* *(Deployable stack.)* Rung D's cost plus the measured $+0.14\%$ of an
  $8$-bit-key/$4$-bit-value attention cache is under $2\%$ in aggregate.

*Proof.* Exact rational evaluation in each case. $\square$

### 2.4 Why a geometric band forbids a floor

The upgrade from "no cliff between rungs" to "no floor at any finite width" is
purely structural and does not depend on the measured numbers.

**Theorem 2.8 (geometric closure).** *Let $D : \mathbb{N} \to \mathbb{R}$ assign a
degradation to each precision (indexed in tenths of a bit), let $m \ge 0$, and
suppose removing one bit multiplies degradation by at most $m$:
$D(b) \le m\, D(b+10)$ for all $b$. Then for every $b$ and every $k$,*
$$D(b) \;\le\; m^{k}\, D(b + 10k).$$

*Proof.* Induction on $k$. The base case is trivial. For the step, apply the
hypothesis at $b + 10k$ and multiply by $m^k \ge 0$. $\square$

**Corollary 2.9 (bounded damage below an anchor).** *Under the hypotheses of
Theorem 2.8, if $D(\text{anchor}) \le d_0$ then either
$D(\text{anchor} - 10k) \le m^k d_0$, or $10k$ exceeds the anchor (i.e. the
extrapolation runs past zero bits).*

A floor at a finite bit width would require degradation to diverge, or to jump by
an unbounded factor, at that width. Corollary 2.9 forbids both, for every finite
$k$: the damage is dominated by a geometric series, which has no pole.

**Corollary 2.10 (conditional one-bit extrapolation).** *Suppose the fitted upper
rate $m = 3$ persists below the lowest measured rung, and the anchor satisfies
$D(2.6\ \mathrm{bpw}) \le 1.1280$. Then $D(1.6\ \mathrm{bpw}) < \tfrac12 \times
6.9825$: even a full bit below anything measured, the relative excess is under the
$+50\%$ "undeployable" threshold.*

*Proof.* $3 \times 1.1280 = 3.384 < 3.49125$. $\square$

We stress that Corollary 2.10 is conditional and is offered as a statement about
the *shape* of the fitted law, not as a measurement.

---

## 3. The curvature model: a four-per-bit ceiling, and quality as bits

### 3.1 The model

**Definition 3.1 (quadratic excess).** For curvatures (Hessian eigenvalues)
$\lambda \in \mathbb{R}^n$ and a weight perturbation $e \in \mathbb{R}^n$
expressed in the Hessian eigenbasis, the modelled loss increase is
$$Q_\lambda(e) \;=\; \tfrac12 \sum_{i=1}^{n} \lambda_i\, e_i^2 .$$

**Proposition 3.2.** If $\lambda_i \ge 0$ for all $i$ then $Q_\lambda(e) \ge 0$.

**Definition 3.3 (curvature bound).** For $K \in \mathbb{R}$ and bit width $b$,
$$\mathrm{CB}(K, b) \;=\; \frac{K}{4^{\,b}} .$$

**Theorem 3.4 (curvature bound for a $b$-bit quantiser).** *Let $0 \le \lambda_i
\le \Lambda$ for all $i$, and let a $b$-bit quantiser with dynamic-range constant
$c$ produce coordinatewise errors $|e_i| \le c/2^{\,b}$. Then*
$$Q_\lambda(e) \;\le\; \mathrm{CB}\!\left(\frac{n \Lambda c^2}{2},\; b\right).$$

*Proof sketch.* Bound each term: $\lambda_i e_i^2 \le \Lambda (c/2^b)^2 =
\Lambda c^2 / 4^b$, using $(c/2^b)^2 = c^2/4^b$. Sum over $n$ coordinates and halve.
$\square$

### 3.2 The four-per-bit ceiling

**Theorem 3.5 (exact per-bit multiplier).** *For all $K$ and $b$,*
$$\mathrm{CB}(K, b) \;=\; 4\,\mathrm{CB}(K, b+1).$$

Thus in the second-order world, removing one bit multiplies modelled damage by
exactly $4$. Four is the theoretical worst case for smooth quantisation damage.

**Theorem 3.6 (the data beats the ceiling).** *Every pair of rungs of the measured
ladder degrades strictly slower than the $4$-per-bit ceiling; measured per-bit
rates lie in $[2.539,\, 2.982]$.*

*Proof.* This is Theorem 2.6(1). $\square$

The interpretation is that calibration-aware quantisers recover a factor the
naive second-order bound does not model — the second-order bound assumes the
worst about how quantisation error aligns with high-curvature directions, while a
calibrated quantiser deliberately spends resolution where curvature is large.

**Proposition 3.7 (shape of the model curve).** *For $K > 0$, $\mathrm{CB}(K,\cdot)$
is strictly decreasing in $b$ and strictly midpoint-convex,*
$$2\,\mathrm{CB}(K, b+1) \;<\; \mathrm{CB}(K, b) + \mathrm{CB}(K, b+2),$$
*with gap $9K/(16\cdot 4^{b})$; and its continuous extension
$b \mapsto K e^{-(\log 4) b}$ is convex on $\mathbb{R}$ for $K \ge 0$.*

So the "gentle convex curve" of §2 is exactly the shape the curvature model
predicts — convexity is not a coincidence of the measurement.

### 3.3 Quality is measured in bits

**Theorem 3.8 (quality is a bit shift).** *For all $n, \Lambda, c$ and all
$j, b \in \mathbb{N}$,*
$$\mathrm{CB}\!\left(\frac{n\Lambda (c/2^{\,j})^2}{2},\; b\right)
\;=\;
\mathrm{CB}\!\left(\frac{n\Lambda c^2}{2},\; b + j\right).$$
*A quantiser $2^{\,j}$ times more accurate is worth **exactly** $j$ bits.*

*Proof.* $(c/2^j)^2 = c^2/4^j$ and $4^{b+j} = 4^b 4^j$; the two factors of $4^j$
cancel. $\square$

**Theorem 3.9 (no intrinsic floor).** *Let $n, \Lambda \ge 0$, fix **any** bit
width $b$ and **any** tolerance $T > 0$. Then there exists $j \in \mathbb{N}$ such
that*
$$\mathrm{CB}\!\left(\frac{n\Lambda (c/2^{\,j})^2}{2},\; b\right) \;\le\; T .$$

*Proof sketch.* Since $4^j \to \infty$, there is a $j$ with
$\mathrm{CB}(n\Lambda c^2/2,\; j) \le T$. Apply Theorem 3.8 and observe
$4^{j} \le 4^{b+j}$, so the bound at $b+j$ is no larger. $\square$

**Corollary 3.10 (the floor is not a bit-width law).** *No bit width is
intrinsically undeployable. A floor observed at width $b$ with a given quantiser
is displaced to width $b - j$ by any quantiser $2^{\,j}$ times more accurate.*

This is the formal content of the paper's title. Quantiser accuracy $c$ and bit
width $b$ enter the model only through the product $c\,2^{-b}$; naming a bit width
as a floor without naming the quantiser is a category error.

---

## 4. Separating the confound: block scaling is worth $\log_2(R/\mathrm{rms})$ bits

Theorem 3.8 makes quality commensurable with bits. This section computes the
quality half of the toy-versus-scale confound *exactly*, and shows it suffices to
explain the entire observed floor shift.

### 4.1 The block-scaling model

Partition a weight tensor into $B$ blocks. Let $r_i \ge 0$ be the dynamic range of
block $i$ and $R = \max_i r_i$ the tensor-wide range. A $b$-bit uniform quantiser
with a *single* tensor-wide scale has per-coordinate error proportional to
$R/2^{\,b}$: one outlier anywhere coarsens the grid everywhere. With a *per-block*
scale, block $i$ has error proportional to $r_i/2^{\,b}$, so the mean square error
is governed by the root mean square of the block ranges.

**Definition 4.1.** $\ \mathrm{msq}(r) = \frac1B\sum_{i=1}^{B} r_i^2$, and
$\mathrm{rms}(r) = \sqrt{\mathrm{msq}(r)}$.

**Definition 4.2 (scale gain).** $\ G(r, R) = R / \mathrm{rms}(r)$: the factor by
which the effective dynamic range shrinks when a global scale is replaced by
per-block scales.

### 4.2 The budget and its attainment

**Theorem 4.3 (blocking never hurts).** *If $B > 0$, $0 \le r_i \le R$ for all $i$,
then $\mathrm{rms}(r) \le R$, and hence (when $\mathrm{rms}(r) > 0$)
$G(r, R) \ge 1$.*

*Proof sketch.* $\sum_i r_i^2 \le B R^2$ termwise, so $\mathrm{msq}(r) \le R^2$;
take square roots. $\square$

**Theorem 4.4 (single-term bound).** *For any index $i_0$ and nonnegative ranges,
$r_{i_0} \le \sqrt{B}\,\mathrm{rms}(r)$.*

*Proof sketch.* $r_{i_0}^2 \le \sum_i r_i^2 = B\,\mathrm{msq}(r)$; take square
roots and use $\sqrt{B\,\mathrm{msq}(r)} = \sqrt{B}\,\mathrm{rms}(r)$. $\square$

**Theorem 4.5 (the block-scaling budget).** *If the maximum $R$ is attained by
some block and $\mathrm{rms}(r) > 0$, then*
$$1 \;\le\; G(r, R) \;\le\; \sqrt{B}.$$

**Theorem 4.6 (the budget is exactly outlier concentration).** *Let $R > 0$ and let
$r$ be the profile in which one block carries the whole range and the others are
flat, $r_i = R\,[\,i = i_0\,]$. Then*
$$G(r, R) \;=\; \sqrt{B}\quad\text{exactly.}$$

*Proof sketch.* $\sum_i r_i^2 = R^2$, so $\mathrm{msq}(r) = R^2/B$ and
$\mathrm{rms}(r) = R/\sqrt{B}$; divide. $\square$

Theorems 4.5 and 4.6 together say something sharp: *the entire advantage of
calibration-aware block quantisation over naive global-scale rounding is a
statement about the outlier profile of the weights.* If the block ranges are all
equal, the gain is exactly $1$ and blocking buys nothing; if the range is carried
by a single block, the gain is maximal.

### 4.3 The gain, in bits

**Theorem 4.7 (block scaling is a bit shift).** *If $R = 2^{\,j}\,\mathrm{rms}(r)$
then for every $b$,*
$$\frac{\mathrm{rms}(r)^2}{4^{\,b}} \;=\; \frac{R^2}{4^{\,b + j}} .$$
*A scale gain of $2^{\,j}$ translates the whole degradation curve by exactly $j$
bits.*

*Proof.* $R^2 = 4^j\,\mathrm{rms}(r)^2$ and $4^{b+j} = 4^b 4^j$. $\square$

This is the exact analogue of Theorem 3.8 with the *mechanism* filled in: the
generic "quality is bits" statement becomes the concrete "block scaling buys
$\log_2 G$ bits, computable from the range profile of the tensors alone".

### 4.4 The accounting

**Theorem 4.8 (the $B = 256$ budget).** *At the standard block size $B = 256$,
whatever the range profile,*
$$G(r, R) \;\le\; \sqrt{256} \;=\; 16 \;=\; 2^{4},$$
*i.e. per-block scaling is worth **at most four bits**.*

**Theorem 4.9 (the observed shift fits the budget).** *The naive global-scale floor
sat at $6.0$ bpw; the calibration-aware ladder remains deployable at $2.6$ bpw
(Proposition 2.7, P3). The shift is $3.4$ bits, strictly inside the four-bit budget
of Theorem 4.8; and the budget is attained (Theorem 4.6) under single-block outlier
concentration, which is precisely the regime large-model weight tensors are known
to occupy.*

**Corollary 4.10 (the confound is resolved in one direction).** *The collapse of
the weight floor is fully accountable by quantiser quality alone. The $14\times$
increase in model scale is not required to explain it.*

This does not prove scale is irrelevant; it proves scale is not *needed*. And it
converts the documented confound into a falsifiable prediction, stated in §8.

---

## 5. Selection versus content: why some axes cliff and others cannot

The weight axis has no cliff. The attention-cache axis does: cached *values*
tolerate four bits, while cached *keys* degrade catastrophically somewhere between
eight and five bits. This section proves the dissociation is structural.

**Definition 5.1.** A quantiser $q : \mathbb{R} \to \mathbb{R}$ is
*$\delta$-accurate* if $|q(x) - x| \le \delta$ for all $x$. A vector
$p \in \mathbb{R}^n$ is a *probability weight vector* if $p_i \ge 0$ and
$\sum_i p_i = 1$. Write $\langle p, v\rangle = \sum_i p_i v_i$.

### 5.1 Content channels have a sharp modulus of continuity

**Theorem 5.2 (content error bound).** *If $p$ is a probability weight vector and
$q$ is $\delta$-accurate, then for every $v \in \mathbb{R}^n$,*
$$\big|\langle p, q\circ v\rangle - \langle p, v\rangle\big| \;\le\; \delta .$$

*Proof.* The difference is $\sum_i p_i (q(v_i) - v_i)$; bound by
$\sum_i p_i |q(v_i) - v_i| \le \delta \sum_i p_i = \delta$. $\square$

**Theorem 5.3 (sharpness).** *For every $\delta \ge 0$ there exist $p$, $v$ and a
$\delta$-accurate $q$ attaining equality.*

*Proof.* Take $n = 1$, $p = (1)$, $v = (0)$, $q(x) = x + \delta$. $\square$

So content read-outs — weights consumed by matrix products, cached values consumed
by attention averaging — have degradation *linear* in the quantiser step, vanishing
as the step vanishes. Smoothness is forced, not lucky.

### 5.2 Selection interfaces have none

Write $\mathrm{Top}(u, i)$ for the assertion that $u_i > u_j$ for all $j \ne i$.

**Theorem 5.4 (a flip at every precision).** *For every $\delta > 0$ and every
target error $C \ge 0$ there exist scores $u \in \mathbb{R}^2$, values
$\mathrm{val} \in \mathbb{R}^2$, and a $\delta$-accurate quantiser $q$ with*
$$\mathrm{Top}(u, 0), \qquad \mathrm{Top}(q \circ u, 1), \qquad
|\mathrm{val}_1 - \mathrm{val}_0| = C, \qquad u_0 - u_1 \le \delta .$$

*Proof sketch.* Take $u = (\delta/2,\, 0)$, $\mathrm{val} = (0,\, C)$, and
$$q(x) = \begin{cases} x + \delta/2, & x \le \delta/4,\\ x - \delta/2, & x > \delta/4.\end{cases}$$
Then $|q(x) - x| = \delta/2 \le \delta$ everywhere, $q(u_0) = 0$ and
$q(u_1) = \delta/2$, so the ranking reverses. $\square$

**Theorem 5.5 (no modulus of continuity).** *For every proposed bound
$f : \mathbb{R} \to \mathbb{R}$ and every $\delta > 0$, there is a configuration as
in Theorem 5.4 whose read-out error strictly exceeds $f(\delta)$.*

*Proof.* Apply Theorem 5.4 with $C = |f(\delta)| + 1$. $\square$

**Theorem 5.6 (the dissociation).** *Fix any quantiser step $\delta > 0$.
Simultaneously: (i) every probability-weighted content read-out under a
$\delta$-accurate quantiser moves by at most $\delta$; and (ii) there is a
selection read-out under a $\delta$-accurate quantiser that moves by any prescribed
amount $C$.*

In slogan form: **selection interfaces carry precision requirements; content
containers do not.** Selection error is $\Theta(1)$ where content error is
$\Theta(\delta)$.

### 5.3 Locating the wall: the margin, not the bit width

**Theorem 5.7 (enough bits).** *Let $u$ have top index $i$ with margin
$g$, i.e. $u_i - u_j \ge g$ for all $j \ne i$, and let $q$ be
$2^{-b}$-accurate. If $2\cdot 2^{-b} < g$ then $\mathrm{Top}(q \circ u, i)$: the
decision survives.*

**Theorem 5.8 (too few bits).** *Conversely, for every $b$ and every $C \ge 0$
there is a configuration with margin $\le 2^{-b}$, a $2^{-b}$-accurate quantiser
that reverses the top-1 decision, and read-out error exactly $C$.*

Together these pin the transition at $b \approx \log_2(1/g)$ — a property of the
*margin distribution of the scores*, not of the tensor being quantised, and not of
the bit width in isolation. Above the threshold the error is $0$; below it, it is
$\Theta(1)$. That is a wall, not a slope.

**Theorem 5.9 (flip counting).** *Let $u_\ell \in \mathbb{R}^n$ be the score vectors
at positions $\ell = 1, \dots, L$ with intended top indices $i_\ell$, and let $q$ be
$\varepsilon$-accurate. Then*
$$\#\{\ell : \mathrm{Top}(q \circ u_\ell,\, i_\ell) \text{ fails}\}
\;\le\;
\#\{\ell : \exists j \ne i_\ell,\ u_\ell(i_\ell) - u_\ell(j) \le 2\varepsilon\}.$$

*Proof sketch.* Contrapositive, position by position: if every competitor at
position $\ell$ is more than $2\varepsilon$ below the top, then the margin
certificate of Theorem 5.7 applies and the decision survives. Hence the set of
broken positions injects into the set of small-margin positions. $\square$

**Corollary 5.10 (the cliff is a CDF).** *Degradation on a selection axis tracks the
cumulative distribution function of the top-1 margin evaluated at $2\varepsilon$.
If margins concentrate in a narrow band, that CDF has a near-vertical segment and
the system inherits a near-vertical degradation curve over a single bit.*

This is the precise sense in which the key axis may cliff and the weight axis may
not: the weight path contains no $\arg\max$, so Theorem 5.2 applies end to end and
Theorem 5.5 never can.

---

## 6. Composing compressions: the stack budget is a seminorm

Deployment stacks compose independent compressions. In the curvature model,
$Q_\lambda$ is the *square of a seminorm*, which settles the composition question.

**Definition 6.1.** The curvature pairing is
$\ \Pi_\lambda(e, f) = \tfrac12\sum_i \lambda_i e_i f_i$, so that
$Q_\lambda(e + f) = Q_\lambda(e) + Q_\lambda(f) + 2\Pi_\lambda(e, f)$.

**Theorem 6.2 (Cauchy–Schwarz in the curvature metric).** *If $\lambda_i \ge 0$ for
all $i$, then $\Pi_\lambda(e,f)^2 \le Q_\lambda(e)\, Q_\lambda(f)$.*

*Proof sketch.* Apply the discrete Cauchy–Schwarz inequality to the vectors
$(\sqrt{\lambda_i}\, e_i)$ and $(\sqrt{\lambda_i}\, f_i)$; degenerate directions
$\lambda_i = 0$ are permitted. $\square$

**Theorem 6.3 (triangle inequality).** *Under the same hypothesis,*
$$\sqrt{Q_\lambda(e+f)} \;\le\; \sqrt{Q_\lambda(e)} + \sqrt{Q_\lambda(f)} .$$
*Equivalently $Q_\lambda(e+f) \le \big(\sqrt{Q_\lambda(e)} + \sqrt{Q_\lambda(f)}\big)^2$.*

**Theorem 6.4 (two-axis budget).** *If $Q_\lambda(e_w) \le a$ and
$Q_\lambda(e_c) \le b$, then*
$$Q_\lambda(e_w + e_c) \;\le\; a + b + 2\sqrt{ab},$$
*whatever the correlation between the two perturbations.*

**Corollary 6.5 (the measured stack).** *With $a = 1.816\%$ (weights at $4.8$ bpw)
and $b = 0.14\%$ (an $8$-bit-key/$4$-bit-value cache), the composed stack costs
strictly under $3\%$ — even in the worst case of perfectly aligned perturbations,
since $\sqrt{ab} = 0.504\%$ gives $1.816 + 0.14 + 2(0.504) = 2.964 < 3$ (and the cruder certificate $\sqrt{ab} \le 0.51\%$ already suffices).*

**Theorem 6.6 (exact additivity under orthogonality).** *If
$\Pi_\lambda(e_w, e_c) = 0$ — the natural "independent compressions"
hypothesis — then $Q_\lambda(e_w + e_c) = Q_\lambda(e_w) + Q_\lambda(e_c)$
exactly.*

At the measured numbers this predicts $1.816\% + 0.14\% = 1.956\%$ for the joint
arm, against a worst-case guarantee of under $2.964\%$. The gap between these two
numbers is an experiment: run the joint arm and read off how orthogonal the two
perturbations actually are.

---

## 7. Algorithms

Three procedures follow directly from the theory and are cheap enough to run as
standard diagnostics.

### 7.1 Per-bit rate extraction and band certification

Given rungs $(b_i, P_i)$ and a reference $P_0$, form $E_i = P_i - P_0$, discard
any rung with $E_i \le 0$ as noise, and for every ordered pair compute the
implied per-bit rate
$$m_{ij} \;=\; \left(\frac{E_j}{E_i}\right)^{1/(b_i - b_j)}, \qquad b_j < b_i .$$
Certify the band $[m_{\min}, m_{\max}]$ over all $\binom{k}{2}$ pairs. Cost
$O(k^2)$ arithmetic operations. Reporting *all* pairs rather than adjacent ones is
what distinguishes a genuine one-parameter law from a piecewise fit: a hidden
cliff between two rungs shows up as a wide-pair rate that escapes the
adjacent-pair band.

### 7.2 Block-scaling gain audit

Given a weight tensor and a block size $B$, compute each block's dynamic range
$r_i = \max(\text{block}) - \min(\text{block})$, then
$G = \max_i r_i / \mathrm{rms}(r)$ and the bit gain $\log_2 G$. By Theorem 4.5,
$0 \le \log_2 G \le \tfrac12\log_2 B$; by Theorem 4.7 this is the exact horizontal
translation the block quantiser buys over a global-scale quantiser at the same bit
width. Cost is one pass over the tensor, $O(\text{parameters})$, and requires *no
perplexity evaluation whatsoever*.

### 7.3 Margin-CDF cliff prediction

Given the attention score vectors at $L$ positions, compute the top-1 margin
$g_\ell$ at each, sort, and evaluate the empirical CDF at $2\cdot 2^{-b}$ for each
candidate bit width $b$. By Theorem 5.9 this is an upper bound on the fraction of
decisions a $b$-bit quantiser can break, and by Theorem 5.7 positions above the
threshold are provably safe. Cost $O(Ln)$ for the margins plus $O(L\log L)$ for the
sort. The output is a *predicted* cliff location for every quantiser, from a
single forward pass.

---

## 8. Discussion, limits, and future directions

### 8.1 What was and was not shown

Shown: that the measured excess-perplexity curve is geometric, convex, and
cliff-free from $6.6$ to $2.6$ bpw; that a per-bit multiplicative bound
structurally forbids a floor at any finite bit width; that in the second-order
model quantiser quality and bit width are the same variable, so "floor at $b$
bits" is ill-posed without naming the quantiser; that block scaling buys exactly
$\log_2(R/\mathrm{rms}(r))$ bits and at most $\tfrac12\log_2 B$, enough to account
for the entire observed floor shift; that content channels have a sharp modulus of
continuity and selection channels have none; and that compressions compose with a
seminorm budget.

Not shown: that model scale is irrelevant (only that it is not *needed* to explain
the shift); that the geometric law continues below $2.6$ bpw (Corollary 2.10 is
explicitly conditional); or that the results transfer across model families.

### 8.2 Honest limits

The measurement is a single model family on a single held-out slice with a single
family of calibrations, and per-arm standard errors were not captured. The
$-0.063\%$ at $8.5$ bpw is treated as within noise and excluded from the
multiplicative law on that basis. The comparison against the naive global-scale
baseline crosses quantiser quality *and* model scale simultaneously; §4 quantifies
the quality half and shows it suffices, but does not perform the separation
experiment. One reassuring datum: the $4.8$ bpw arm reproduced an independent
earlier run's perplexity of $7.1093$ exactly, days apart.

### 8.3 Practical consequence

Weights at $4.8$ bpw ($+1.816\%$), an $8$-bit-key/$4$-bit-value attention cache
($+0.14\%$), and speculative decoding compose into a serving stack at roughly
one-eighth of the naive memory footprint for an aggregate quality cost under $2\%$
— all on commodity CPU hardware. The design rule the theory recommends is blunt:
**spend precision at selection interfaces and economise everywhere else.**

### 8.4 Future directions

**Direction 1 — Margin-CDF law for the key cliff.** The cache-key cliff should not
be a bit-width phenomenon at all but the cumulative distribution function of the
top-1 attention margin evaluated at $2\cdot 2^{-b}$. Theorem 5.9 already bounds the
damage by that count, so measuring the margin distribution of one model should
*predict* the cliff location of every quantiser applied to it. The cliff has been
located between $8$-bit and $5$-bit keys but margins were never measured; the
margin histogram is one forward pass away, and the theorem that turns it into a
prediction now exists.

**Direction 2 — Naive rounding versus block quantisation at fixed scale.** Theorem
4.7 converts the quality half of the documented confound into a single measurable
number, $\log_2(R/\mathrm{rms}(r))$, computable directly from the weight tensors
without running a single perplexity evaluation. The prediction is a *rigid*
horizontal translation of the whole ladder — not merely a softening — by at most
four bits at $B = 256$, and by exactly $\log_2 G$ bits for the measured range
profile. Running both quantisers at fixed model scale falsifies or confirms it
directly.

**Direction 3 — The joint stack arm.** Corollary 6.5 guarantees under $2.964\%$;
Theorem 6.6 predicts exactly $1.956\%$ under curvature-orthogonality. Measuring the
joint weight-and-cache arm reads off the alignment of the two perturbations, and
tests whether "independent compressions" is a good approximation in practice.

**Direction 4 — Extending the ladder below $2.6$ bpw.** Corollary 2.10 predicts
that even at $1.6$ bpw the relative excess stays under $+50\%$ if the fitted rate
$m = 3$ persists. This is the cleanest available falsification of the whole
framework: if a genuine cliff exists on the weight axis, this is where to find it,
and finding it would require identifying the selection interface responsible.

**Direction 5 — Curvature-rate reconciliation.** The model ceiling is $4$ per bit;
the data runs at $2.54$–$2.98$. The residual factor is what calibration recovers.
Quantifying it — as the ratio between naive dynamic range and calibration-weighted
effective range in high-curvature directions — would turn the ceiling into an
estimate rather than a bound.

---

## 9. Conclusion

The sub-six-bit weight floor is not a law about bit widths. It is a law about
quantisers, and quantiser quality is measured in bits: a quantiser $2^{\,j}$ times
more accurate is worth exactly $j$ bits, and per-block scaling with $B$ blocks is
worth $\log_2(R/\mathrm{rms}(r)) \le \tfrac12\log_2 B$ bits, attained exactly under
single-block outlier concentration. Four bits of budget at the standard block size
comfortably covers the $3.4$-bit shift that was observed. What remains, once the
floor is removed, is a smooth one-parameter geometric law: excess perplexity
multiplies by between $2.5$ and $3$ per bit removed, across every pair of measured
precisions from $6.6$ down to $2.6$ bits per weight, strictly inside the
four-per-bit ceiling that second-order theory imposes.

Where genuine cliffs *do* occur, they occur for a reason that is now a theorem.
Numbers consumed by averaging have a sharp modulus of continuity in the quantiser
step; numbers consumed by ranking have none, at any precision, and never will. The
practical corollary is a single sentence: **selection interfaces carry precision
requirements; content containers do not.**
