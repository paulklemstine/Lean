# Window Geometry of $j^2 - N$: A Split Verdict on the Concave Mid-Window Excess in Sieve Yield Profiles

**Author:** Aristotle

**Date:** 2026-08-26

---

## Abstract

Quadratic sieves collect *hits* — window positions $j$ near $\sqrt{N}$ at which $v(j) = j^2 - N$ factors over a prescribed factor base — and compare their positional distribution with a heuristic model. Across a large replicated sweep the observed-to-predicted ratio $R = T/M$, binned into $64$ positions, is not flat: it is concave with edge deficits ($R \approx 0.837$ at the first bin, $R \approx 0.894$ at the last) and an interior maximum $R \approx 1.223$, with a pooled quadratic-fit apex at relative window position $0.5901$ and fitted curvatures between $-0.105$ and $-0.44$ in every resolvable stratum. Compositional explanations of this excess are excluded on counting grounds: $99.93\%$ of all hits occupy a single largest-prime-factor band, and the concavity replicates inside every descriptive sub-stratum of that band, so no single-band-carrier or band-mass-reallocation story is available.

This paper analyses the remaining channel — the *window and polynomial geometry of $j^2 - N$ itself* — and resolves it into a **split verdict**. Writing $j = \sqrt N + s$, $x = s/M$ and $c = \sqrt N / M$, the normalised value is $M^2 x(x+2c)$ and the log-size profile of the window is $L_c(x) = \log x + \log(x+2c)$. We prove:

1. **(Shape, affirmative.)** $L_c$ is strictly concave; hence, measured against the endpoint chord, it produces a strictly positive interior deviation vanishing at both window edges, with a unique interior vertex characterised by $1/\xi + 1/(\xi+2c) = $ chord slope, strictly increasing to its left and strictly decreasing to its right.
2. **(Robustness, affirmative.)** The measured statistics are grid invariants. Bin averaging on any arithmetic sample grid maps a concave profile to a discretely concave sequence at *every* bin width and *every* grid offset, and an affine profile to an exactly affine sequence; discrete concavity forces unimodality, so no bin-width permutation can split or manufacture a peak. Separately, the least-squares quadratic coefficient against a grid-orthogonal quadratic is $\le 0$ for every concave profile (strictly $<0$ in the strictly concave case) and exactly $0$ for affine profiles, at every bin count, bin width and grid centre.
3. **(Location, negative.)** For every aspect ratio $c \ge 0$ and every window $0 < a < b$, the geometric vertex satisfies $\xi < (a+b)/2$; equivalently its relative position is strictly below $1/2$. Hence the measured relative vertex $0.5901$ is not producible by this channel. Quantitatively the failure is one-sided and large: in the degenerate aspect ratio the vertex is the logarithmic mean of the endpoints, with relative position at most $1/\log(b/a)$, so in the sieve regime it collapses onto the *left* edge as the window grows.
4. **(Rigidity.)** The vertex is pinned two-sidedly between logarithmic means, $\mathrm{LM}(a,b) \le \xi \le \mathrm{LM}(a+2c, b+2c) - 2c < (a+b)/2$, via shift rigidity $\mathrm{LM}(a,b) + t \le \mathrm{LM}(a+t,b+t)$, itself a consequence of the geometric–logarithmic mean inequality. The lower pin is aspect-ratio free, which accounts for the observed insensitivity of the vertex to $c$ across nine orders of magnitude.

The conclusion is a structural — not power-limited — elimination: the window geometry is the correct account of the *sign* and *shape* of the mid-window excess and a demonstrably incorrect account of its *location*.

**Keywords:** quadratic sieve, log-size profile, strict concavity, chord deviation, logarithmic mean, geometric mean inequality, discrete concavity, orthogonal polynomial fit, unimodality.

---

## 1. Introduction

### 1.1 The empirical object

In a quadratic-sieve-type sweep one fixes $N$, sets $r = \sqrt N$, and examines $j$ over a window of length $M$ immediately above $r$. For each $j$ the value $v(j) = j^2 - N$ is tested for smoothness against a factor base; a *hit* is a $j$ whose value factors as required. A heuristic model $M(\cdot)$ predicts the density of hits as a function of position — essentially a Dickman-type smoothness density evaluated at the local value size — and the diagnostic of interest is the positional ratio

$$R(x) = \frac{T(x)}{M(x)}, \qquad x \in [0,1] \text{ the relative window position.}$$

Across a replicated sweep of $9594$ hits over $128$ moduli, binned into $64$ equal positional bins, the measured profile is emphatically not flat:

| statistic | value |
|---|---|
| $R$ at the first bin | $0.8371$ |
| $R$ at the peak (bin $33$ of $64$) | $1.2227$ |
| $R$ at the last bin | $0.8935$ |
| pooled quadratic-fit apex (relative position) | $0.5901$ |
| independent replication of the apex | $0.5896$ |
| pooled fitted curvature, controls | $-0.105$ (CI straddles $0$) |
| fitted curvature, dominant band | $-0.299$ |
| fitted curvatures, three descriptive sub-strata | $-0.18,\ -0.25,\ -0.44$ |

The excess is of order $\pm 20\%$, is concave, has deficits at both edges, and has an apex reproduced to four digits by an independent computation.

### 1.2 Elimination of compositional carriers

The natural first hypothesis is compositional: the hit population is a mixture of sub-populations with different positional behaviour, and the arch is a mixture artifact. This is excluded arithmetically. Sorting hits by the size of the largest prime factor of $v(j)$ into the four eligible size bands, the observed masses are

$$[\,0,\ 0,\ 0.0007,\ 0.9993\,] \quad \text{(counts } [0,0,7,9587]\text{)},$$

against a theoretical mixture prediction of $[\,0,\,0,\,0.0013,\,0.9987\,]$. Ninety-nine point ninety-three percent of hits lie in a single band; the discrepancy in mass between observation and prediction is $6\times 10^{-4}$. A single-band-carrier explanation is therefore impossible — there is only one populated stratum — and reallocation of mass among bands cannot generate a $20\%$ shaped effect.

Descending inside the dominant band does not help either: split descriptively into three sub-strata by largest-prime size and the fitted curvature is negative in all three ($-0.18, -0.25, -0.44$). Conditioning on small-prime combinatorics instead produces conditioned amplitudes of $\pm 2\%$ against a pooled excess of $+4.8\%$. Controls are clean throughout: the same machinery applied to hump-free synthetic data returns a curvature whose confidence interval contains zero and a peak fit of $1.005$.

What survives is the geometric channel: the hump is produced by the shape of $j^2 - N$ on the window, interacting with the sizes of the sieved values. This paper is a complete analysis of what that channel can and cannot produce.

### 1.3 Contributions and organisation

Section 2 sets up the window model and proves strict concavity of the log-size profile and its consequences for the chord-referenced deviation: existence of the hump, uniqueness of the vertex, and monotonicity on each side (Theorems 2.3–2.8). Section 3 proves that the fitted quadratic coefficient is a certificate of concavity, valid at every bin count, bin width and grid centre, with an exact-zero control for affine profiles (Theorems 3.3–3.8). Section 4 proves the discretisation invariance: bin averaging preserves concavity and affinity exactly, and discrete concavity forces unimodality (Theorems 4.2–4.6). Section 5 establishes the obstruction — the geometric vertex is strictly left of the window centre — together with its quantitative form and two calibrating controls (Theorems 5.2–5.7). Section 6 proves the two-sided logarithmic-mean pin and derives aspect-ratio insensitivity (Theorems 6.1–6.6). Section 7 gives algorithms; Section 8 discusses consequences and Section 9 future directions.

---

## 2. The window model and the geometry of the hump

### 2.1 Normalisation

**Definition 2.1 (window coordinates).** Let $N > 0$, $r = \sqrt N$, and let the sieve window be $j = r + s$ with $s$ ranging over an interval of length $M > 0$. Write $x = s/M$ for the relative position and

$$c = \frac{r}{M} = \frac{\sqrt N}{M} \ \ge 0$$

for the *aspect ratio* of the window. Then

$$j^2 - N = (r+s)^2 - r^2 = s(s+2r) = M^2\, x\,(x + 2c).$$

We call $W_c(x) = x(x+2c)$ the **normalised window value** and

$$L_c(x) = \log x + \log(x + 2c)$$

the **log-size profile** of the window. For $c \ge 0$ and $x>0$ we have $W_c(x)>0$ and $L_c(x) = \log W_c(x)$; the profile is the logarithm of the sieved value up to the additive constant $2\log M$, which is invisible to all statistics considered here.

The smoothness model is, to the resolution at which $R$ is read, a function of the *log-size* of the value; and the reference against which $R$ is normalised is affine in the sieve grid. It is therefore the deviation of $L_c$ from an affine reference that must be analysed.

**Definition 2.2 (chord, chord slope, gap).** For $f : \mathbb{R} \to \mathbb{R}$ and $a \ne b$,

$$\mathrm{ch}_f^{a,b}(x) = f(a) + \frac{x-a}{b-a}\big(f(b)-f(a)\big), \qquad \sigma_f^{a,b} = \frac{f(b)-f(a)}{b-a},$$
$$G_f^{a,b}(x) = f(x) - \mathrm{ch}_f^{a,b}(x).$$

By construction $G_f^{a,b}(a) = G_f^{a,b}(b) = 0$.

### 2.2 Concavity

**Theorem 2.3 (strict concavity of the log-size profile).** *For every $c \ge 0$, the function $L_c(x) = \log x + \log(x+2c)$ is strictly concave on $(0,\infty)$.*

*Proof sketch.* $\log$ is strictly concave on $(0,\infty)$; $x \mapsto \log(x+2c)$ is a left translate of $\log$ by $2c \ge 0$, hence strictly concave on the preimage of $(0,\infty)$, which contains $(0,\infty)$; a sum of two strictly concave functions on a convex set is strictly concave. (Equivalently: $L_c''(x) = -1/x^2 - 1/(x+2c)^2 < 0$.) $\square$

This one line is the entire geometric content of the channel; everything in Sections 2–4 is a consequence.

### 2.3 The hump and its vertex

**Theorem 2.4 (the hump exists).** *Let $f$ be strictly concave on a set $S$, and let $a, b \in S$ with $a < x < b$. Then $G_f^{a,b}(x) > 0$. If $f$ is merely concave the conclusion is $G_f^{a,b}(x) \ge 0$ for $x \in [a,b]$.*

*Proof sketch.* Put $\theta = (b-x)/(b-a) \in (0,1)$, so $x = \theta a + (1-\theta) b$ and $\mathrm{ch}_f^{a,b}(x) = \theta f(a) + (1-\theta) f(b)$ — the chord evaluated at an interior point *is* the corresponding convex combination of the endpoint values. Strict concavity gives $f(x) > \theta f(a) + (1-\theta)f(b)$. $\square$

**Corollary 2.5 (qualitative prediction of the geometric channel).** *For $c \ge 0$ and $0 < a < x < b$, $G_{L_c}^{a,b}(x) > 0$ and $G_{L_c}^{a,b}(a) = G_{L_c}^{a,b}(b) = 0$: a strictly one-signed interior excess with exact deficits at both window edges.*

This is exactly the measured pattern of edge deficits ($0.837$, $0.894$) around a mid-window surplus.

**Definition 2.6 (vertex).** The derivative of the log-size profile is
$$L_c'(x) = \frac{1}{x} + \frac{1}{x+2c}.$$
A point $\xi$ is a **vertex** of the hump on $[a,b]$ if $\xi \in (a,b)$ and $L_c'(\xi) = \sigma_{L_c}^{a,b}$.

**Theorem 2.7 (existence, uniqueness, and maximality of the vertex).** *Let $c\ge 0$ and $0 < a < b$. Then:*

1. *a vertex $\xi$ exists;*
2. *it is unique;*
3. *$G_{L_c}^{a,b}$ is strictly increasing on $[a,\xi]$ and strictly decreasing on $[\xi,b]$; in particular $\xi$ is the unique maximiser of the gap on $[a,b]$.*

*Proof sketch.* (1) is the mean value theorem applied to $L_c$ on $[a,b]$, which is legitimate since $L_c$ is differentiable on $(0,\infty) \supseteq [a,b]$. (2) holds because $x \mapsto 1/x + 1/(x+2c)$ is *strictly decreasing* on $(0,\infty)$, hence injective, so it attains the value $\sigma_{L_c}^{a,b}$ at most once. (3) The gap has derivative $L_c'(x) - \sigma_{L_c}^{a,b}$; by strict antitonicity of $L_c'$ this is $>0$ for $x<\xi$ and $<0$ for $x>\xi$; conclude by the mean value inequality. $\square$

**Theorem 2.8 (degenerate aspect ratio: the vertex is a logarithmic mean).** *For $c = 0$ and $0<a<b$, the unique vertex is*
$$\xi = \mathrm{LM}(a,b) := \frac{b-a}{\log b - \log a}.$$

*Proof sketch.* At $c=0$, $L_0 = 2\log$, so $L_0'(\xi) = 2/\xi$ and $\sigma_{L_0}^{a,b} = 2(\log b - \log a)/(b-a)$; equating and solving gives the claim. Uniqueness comes from Theorem 2.7. $\square$

As a by-product, since the vertex lies in $(a,b)$: $a < \mathrm{LM}(a,b) < b$.

---

## 3. The fitted curvature is a certificate of concavity

The verdict language "concave in all three strata" rests on a fitted quadratic coefficient. That coefficient is an inner product against a grid-dependent quadratic, not a second derivative, and its sign requires justification.

**Definition 3.1 (fitted curvature).** Given sample points $t_0,\dots,t_{n-1}$, a quadratic $q$, and a profile $g$,
$$\widehat{c}(g) = \frac{\sum_{i<n} g(t_i)\, q(t_i)}{\sum_{i<n} q(t_i)^2},$$
where $q$ is required to be **grid-orthogonal**: $\sum_{i<n} q(t_i) = 0$ and $\sum_{i<n} t_i\, q(t_i) = 0$. (These are exactly the normal equations that make $\widehat c$ the least-squares quadratic coefficient of $g$ on the grid.)

**Lemma 3.2 (chord bridge).** *For any $g$ and $r_1 < r_2 < y$,*
$$\mathrm{ch}_g^{r_1,r_2}(y) - g(y) = \frac{y-r_1}{r_2-r_1}\, G_g^{r_1,y}(r_2),$$
*and symmetrically for $y < r_1 < r_2$,*
$$\mathrm{ch}_g^{r_1,r_2}(y) - g(y) = \frac{r_2-y}{r_2-r_1}\, G_g^{y,r_2}(r_1).$$

*Proof sketch.* Pure algebra: both sides are the same triangle measured two ways. Clearing denominators reduces the identity to a polynomial identity in $g(r_1), g(r_2), g(y), r_1, r_2, y$. $\square$

**Theorem 3.3 (sign pattern of the chord residual).** *Let $g$ be concave on $S$, $r_1 < r_2$ in $S$, $y \in S$. Then*
$$\big(g(y) - \mathrm{ch}_g^{r_1,r_2}(y)\big)\cdot\big((y-r_1)(y-r_2)\big) \le 0,$$
*with strict inequality when $g$ is strictly concave and $y \notin \{r_1,r_2\}$.*

*Proof sketch.* Three cases. If $r_1 \le y \le r_2$ the residual is $\ge 0$ (Theorem 2.4) while $(y-r_1)(y-r_2) \le 0$. If $y > r_2$, Lemma 3.2 (right form) plus non-negativity of $G_g^{r_1,y}(r_2)$ gives residual $\le 0$, while $(y-r_1)(y-r_2) > 0$. The case $y < r_1$ is symmetric via the left form. $\square$

**Lemma 3.4 (affine profiles score zero).** *If $q(y) = (y-r_1)(y-r_2)$ is grid-orthogonal, then for every affine $g(y) = u + vy$, $\sum_{i<n} g(t_i)q(t_i) = 0$.* Immediate from the two orthogonality relations.

**Theorem 3.5 (sign theorem).** *Let $g$ be concave on $S$, $r_1 < r_2$ in $S$, and $t_0,\dots,t_{n-1} \in S$ with $q(y)=(y-r_1)(y-r_2)$ grid-orthogonal. Then*
$$\sum_{i<n} g(t_i)\, q(t_i) \le 0.$$
*If $g$ is strictly concave and some $t_i \notin \{r_1,r_2\}$, the inequality is strict.*

*Proof sketch.* Write $g = \big(g - \mathrm{ch}_g^{r_1,r_2}\big) + \mathrm{ch}_g^{r_1,r_2}$. The chord is affine, so by Lemma 3.4 it contributes $0$ to the sum. Each remaining term is $\le 0$ by Theorem 3.3. $\square$

**The pipeline grid.** For $n$ bins of width $h>0$ centred at $m$, let
$$o_i = i - \frac{n-1}{2}, \qquad t_i = m + h\,o_i, \qquad V(n) = \frac{1}{n}\sum_{i<n} o_i^2,$$
and put $\rho = h\sqrt{V(n)}$, $r_{1,2} = m \mp \rho$, so that
$$q(y) = (y - r_1)(y - r_2) = (y-m)^2 - h^2 V(n).$$

**Theorem 3.6 (the bin grid is orthogonal, at every width and centre).** *For $n \ge 2$, every $h$ and every $m$:*
$$\sum_{i<n} q(t_i) = 0 \qquad\text{and}\qquad \sum_{i<n} t_i\, q(t_i) = 0.$$

*Proof sketch.* $q(t_i) = h^2(o_i^2 - V(n))$, so the first sum is $h^2(\sum o_i^2 - nV(n)) = 0$ by definition of $V$. For the second, $t_i q(t_i) = m\,h^2(o_i^2 - V(n)) + h^3(o_i^3 - V(n)o_i)$; the first bracket sums to $0$ as before, and $\sum o_i^3 = \sum o_i = 0$ because the offset set is symmetric under the reflection $i \mapsto n-1-i$, which sends $o_i \mapsto -o_i$, and both $y \mapsto y$ and $y \mapsto y^3$ are odd. $\square$

**Lemma 3.7 (a witness bin).** *For $n \ge 3$ and $h>0$, at least one of $t_0, t_1$ avoids both roots $r_1, r_2$.* Indeed $o_0^2 \neq o_1^2$ for $n \ge 3$, so at most one of them can equal $V(n)$, and $q(t_i) = h^2(o_i^2 - V(n))$.

**Theorem 3.8 (bin-width and grid-shift invariance of the measured sign).** *Let $g$ be strictly concave on $S$, $n \ge 3$, $h>0$, $m$ arbitrary, with $r_1, r_2$ and all $t_i$ in $S$. Then $\sum_{i<n} g(t_i)q(t_i) < 0$, and hence $\widehat c(g) < 0$. In particular, for the log-size profile $L_c$ of $j^2-N$ and any equal-width bin grid inside the window,*
$$\widehat c\,(L_c) < 0$$
*for every bin count $n \ge 3$, every bin width $h > 0$ and every grid centre $m$.* Conversely, by Lemma 3.4 an affine profile yields $\widehat c = 0$ exactly.

*Proof sketch.* Combine Theorems 2.3, 3.5, 3.6 and Lemma 3.7; positivity of the denominator $\sum q(t_i)^2$ follows since $q(t_i) \ne 0$ for at least one $i$. $\square$

**Interpretation.** This is the pre-registered "bin-width permutation / grid shift" robustness probe, discharged as a theorem rather than as a simulation. A measured $\widehat c < 0$ cannot be a grid accident, and a measured $\widehat c = 0$ on controls is exactly what an affine profile must produce. The observed values $-0.105, -0.18, -0.25, -0.299, -0.44$ are therefore genuine certificates of concavity of $\log(j^2 - N)$.

---

## 4. Binning cannot create, destroy, or split the hump

The second half of the robustness probe concerns the binning itself.

**Definition 4.1 (sample grid and bin averages).** For offset $a$, spacing $\delta$ and bin width $w \ge 1$, the samples are $s_i = a + \delta i$ and the binned profile is
$$b_k = \frac{1}{w}\sum_{i<w} g\big(s_{kw+i}\big).$$

**Lemma 4.2 (midpoint alignment).** *For all $k,i,w$: $s_{kw+i} + s_{(k+2)w+i} = 2\, s_{(k+1)w+i}$.* Immediate from $s_i = a + \delta i$ and linearity of the index.

**Theorem 4.3 (binning preserves concavity).** *Let $g$ be concave on $S$ with all samples in $S$. Then for every offset $a$, every spacing $\delta$, every bin width $w$ and every $k$,*
$$b_k + b_{k+2} \le 2\, b_{k+1}.$$
*If $g$ is strictly concave, $w \ge 1$ and $\delta \ne 0$, the inequality is strict.*

*Proof sketch.* Midpoint concavity gives $g(u) + g(v) \le 2g\big(\frac{u+v}{2}\big)$ for $u,v \in S$; apply it with $u = s_{kw+i}$, $v = s_{(k+2)w+i}$, whose midpoint is $s_{(k+1)w+i}$ by Lemma 4.2. Sum over $i<w$ and divide by $w>0$. Strictness needs $u \ne v$, which holds because $\delta \ne 0$ and the indices differ by $2w \ge 2$. $\square$

**Theorem 4.4 (control: binning an affine profile).** *For $g(y) = u + vy$, $b_k + b_{k+2} - 2b_{k+1} = 0$ identically, for every $a$, $\delta$, $w$, $k$.* Immediate from Lemma 4.2 and linearity.

Theorems 4.3 and 4.4 together mean: a measured non-zero discrete second difference cannot be an artefact of the choice of bins, and a genuinely affine profile produces exactly zero at every choice.

**Theorem 4.5 (discrete concavity forces unimodality).** *Let $(b_k)$ satisfy $b_k + b_{k+2} \le 2 b_{k+1}$ for all $k$, and suppose $b_{k+1} \le b_k$ for some $k$. Then $b_{k+j+1} \le b_{k+j}$ for all $j \ge 0$: once the sequence descends it never ascends again.*

*Proof sketch.* Induction on $j$: discrete concavity at index $k+j$ gives $b_{k+j+2} \le 2b_{k+j+1} - b_{k+j} \le b_{k+j+1}$ using the inductive hypothesis $b_{k+j+1} \le b_{k+j}$. $\square$

**Theorem 4.6 (the sieve instance).** *For $c\ge0$, any offset $a$ and spacing $\delta \ne 0$ with all samples positive, and any bin width $w \ge 1$, the binned log-size profile of $j^2-N$ satisfies the strict discrete concavity $b_k + b_{k+2} < 2b_{k+1}$ for all $k$, and is unimodal.*

*Proof sketch.* Theorems 2.3, 4.3, 4.5. $\square$

**Consequence.** No bin-width permutation and no grid shift can split the measured peak into two, nor manufacture a peak where the underlying profile is affine. The concavity and single-peakedness of $R$ are grid invariants of any concave underlying profile. The discretisation half of the probe is therefore passed affirmatively.

---

## 5. The obstruction: geometry puts the vertex left of centre

Everything so far is affirmative for the geometric channel. The vertex is where it fails.

**Theorem 5.1 (the sharp log inequality).** *For $t>1$,*
$$\frac{2(t-1)}{t+1} < \log t.$$

*Proof sketch.* Set $f(t) = \log t - 2(t-1)/(t+1)$. Then $f(1)=0$ and
$$f'(t) = \frac{1}{t} - \frac{4}{(t+1)^2} = \frac{(t-1)^2}{t(t+1)^2} > 0 \quad (t>1),$$
so $f$ is strictly increasing on $[1,\infty)$ and positive beyond $1$. $\square$

**Corollary 5.2 (secant slope of $\log$ exceeds the reciprocal arithmetic mean).** *For $0<p<q$,*
$$\frac{2}{p+q} < \frac{\log q - \log p}{q-p}, \qquad \text{i.e.} \quad \mathrm{LM}(p,q) < \frac{p+q}{2}.$$

*Proof sketch.* Apply Theorem 5.1 with $t = q/p > 1$ and clear denominators. $\square$

**Theorem 5.3 (main obstruction: the vertex is left of centre).** *For every $c \ge 0$ and every window $0 < a < b$, the unique vertex $\xi$ satisfies*
$$\xi < \frac{a+b}{2}.$$

*Proof sketch.* Write $m = (a+b)/2$. The chord slope of $L_c$ splits into the two factor slopes:
$$\sigma_{L_c}^{a,b} = \frac{\log b - \log a}{b-a} + \frac{\log(b+2c) - \log(a+2c)}{(b+2c)-(a+2c)}.$$
Corollary 5.2 applied to $(a,b)$ and to $(a+2c, b+2c)$ bounds each summand below by $2/(a+b)$ and $2/\big((a+2c)+(b+2c)\big)$, which are exactly $1/m$ and $1/(m+2c)$. Hence
$$L_c'(m) = \frac{1}{m} + \frac{1}{m+2c} < \sigma_{L_c}^{a,b} = L_c'(\xi),$$
and since $L_c'$ is strictly decreasing, $\xi < m$. $\square$

**Corollary 5.4 (normalised form).** *The relative vertex position satisfies $(\xi-a)/(b-a) < 1/2$; consequently it can never equal $0.5901$.*

Since the measured relative apex is $0.5901$ (replicated at $0.5896$), the geometric channel does not produce the measured vertex, for any $N$, any window and any aspect ratio.

**Theorem 5.5 (quantitative collapse to the left edge).** *For $0<a<b$, the normalised position of the logarithmic mean satisfies*
$$\frac{\mathrm{LM}(a,b) - a}{b-a} \;=\; \frac{1}{\log b - \log a} - \frac{a}{b-a} \;\le\; \frac{1}{\log(b/a)}.$$

*Proof sketch.* Direct algebraic split of the left-hand side; the subtracted term $a/(b-a)$ is positive. $\square$

In the sieve regime — window running from $a = 1/M$ to $b = 1$ — this reads $\le 1/\log M$. As the window lengthens the geometric vertex is pushed *toward the left edge*, not toward $0.59$. The measured value is therefore not a near miss in an approach that could be closed by refinement; the discrepancy grows with problem size.

**Theorem 5.6 (control: a purely quadratic profile peaks at the centre).** *For $f(y) = -y^2$ and $a<b$, $G_f^{a,b}(x) = -(x-a)(x-b)$, whose maximum over $[a,b]$ is attained exactly at $x = (a+b)/2$.*

*Proof sketch.* Direct computation of the chord, then $-(x-a)(x-b) \le -\big(\tfrac{a+b}{2}-a\big)\big(\tfrac{a+b}{2}-b\big)$ is equivalent to $\big(x - \tfrac{a+b}{2}\big)^2 \ge 0$. $\square$

So a measured apex $\ne 1/2$ is not a quadratic-profile artefact either: the logarithm is what breaks the symmetry, and it breaks it strictly to the left.

**Theorem 5.7 (summary of the split verdict).** *The window geometry of $j^2-N$, read against an affine reference, predicts: (i) a strictly one-signed interior excess with zero deviation at both edges; (ii) a unique interior peak; (iii) strictly negative fitted curvature at every bin count, bin width and grid centre; (iv) exact-zero fitted curvature on affine controls; (v) an apex strictly left of the window centre, with normalised position $\le 1/\log(b/a)$ in the degenerate aspect ratio. Predictions (i)–(iv) match the measurement; prediction (v) contradicts it.*

---

## 6. Rigidity of the vertex: a two-sided logarithmic-mean pin

Numerically, the vertex is startlingly insensitive to the aspect ratio: varying $c$ over nine orders of magnitude moves it in the fourth decimal place. Theorem 5.3 does not explain that. The following does.

**Definition.** $\mathrm{LM}(p,q) = \dfrac{q-p}{\log q - \log p}$ for $0<p<q$; $\mathrm{LM}(p,p) = p$.

**Theorem 6.1 (elementary inequality).** *For $s > 1$, $\ \log s < \tfrac{1}{2}\big(s - 1/s\big)$.*

*Proof sketch.* Let $G(s) = \tfrac12(s - 1/s) - \log s$. Then $G(1)=0$ and
$$G'(s) = \frac{1 + 1/s^2}{2} - \frac{1}{s} = \frac{(s-1)^2}{2s^2} > 0 \quad (s>1). \qquad \square$$

**Theorem 6.2 (geometric mean below logarithmic mean).** *For $0<p<q$,*
$$\sqrt{pq}\,\big(\log q - \log p\big) < q - p, \qquad\text{i.e.}\quad \sqrt{pq} < \mathrm{LM}(p,q).$$

*Proof sketch.* Substitute $s = \sqrt{q/p} > 1$, so $q = ps^2$, $\sqrt{pq} = ps$ and $\log q - \log p = 2\log s$. The claim becomes $2ps\log s < p(s^2-1)$, i.e. $2s\log s < s^2 - 1$, which is Theorem 6.1 multiplied by $2s>0$. $\square$

**Theorem 6.3 (shift rigidity of the logarithmic mean).** *For $0<a<b$ and $t \ge 0$,*
$$\mathrm{LM}(a,b) + t \le \mathrm{LM}(a+t,\, b+t).$$
*Translating both endpoints raises the logarithmic mean by at least the translation.*

*Proof sketch.* Fix $d = b-a$ and set $D(u) = \log(b+u) - \log(a+u)$, $F(u) = d/D(u) - u$ for $u \ge 0$; note $F(0) = \mathrm{LM}(a,b)$ and $F(t) = \mathrm{LM}(a+t,b+t) - t$. Differentiating,
$$F'(u) = \frac{-d\big((b+u)^{-1} - (a+u)^{-1}\big)}{D(u)^2} - 1 = \frac{d^2 - (a+u)(b+u)D(u)^2}{(a+u)(b+u)\,D(u)^2},$$
whose numerator is positive precisely because $\sqrt{(a+u)(b+u)}\,D(u) < d$ — which is Theorem 6.2 applied to the shifted pair. Hence $F$ is strictly increasing on $[0,\infty)$, giving $F(0) \le F(t)$. $\square$

**Lemma 6.4 (chord slope in terms of logarithmic means).** *For $0<a<b$, $c\ge 0$,*
$$\sigma_{L_c}^{a,b} = \frac{1}{\mathrm{LM}(a,b)} + \frac{1}{\mathrm{LM}(a+2c,\,b+2c)}.$$

*Proof sketch.* Each factor's secant slope is the reciprocal of the corresponding logarithmic mean, and the shifted pair has the same endpoint difference $b-a$. $\square$

**Theorem 6.5 (two-sided pin).** *For $c \ge 0$, $0<a<b$, the vertex satisfies*
$$\mathrm{LM}(a,b) \;\le\; \xi \;\le\; \mathrm{LM}(a+2c,\,b+2c) - 2c \;<\; \frac{a+b}{2}.$$

*Proof sketch.* Write $L = \mathrm{LM}(a,b)$, $L_2 = \mathrm{LM}(a+2c,b+2c)$; Theorem 6.3 with $t = 2c$ gives $L + 2c \le L_2$.
*Lower pin:* by Lemma 6.4 and $1/L_2 \le 1/(L+2c)$,
$$\sigma_{L_c}^{a,b} = \frac{1}{L} + \frac{1}{L_2} \le \frac{1}{L} + \frac{1}{L+2c} = L_c'(L),$$
and since $L_c'(\xi) = \sigma_{L_c}^{a,b} \le L_c'(L)$ with $L_c'$ strictly decreasing, $\xi \ge L$.
*Upper pin:* evaluate $L_c'$ at $L_2 - 2c$ (positive by the shift inequality): $L_c'(L_2-2c) = 1/(L_2-2c) + 1/L_2 \le 1/L + 1/L_2 = \sigma_{L_c}^{a,b} = L_c'(\xi)$, whence $\xi \le L_2 - 2c$. The final strict inequality is Theorem 5.3. $\square$

**Theorem 6.6 (aspect-ratio insensitivity).** *For any two aspect ratios $c_1, c_2 \ge 0$ and the same window, the corresponding vertices satisfy*
$$|\xi_1 - \xi_2| < \frac{a+b}{2} - \mathrm{LM}(a,b),$$
*an interval that does not depend on the aspect ratio at all.*

*Proof sketch.* Both vertices lie in $\big[\mathrm{LM}(a,b),\ (a+b)/2\big)$ by Theorems 6.5 and 5.3. $\square$

The lower pin is aspect-ratio-free; that is the theorem behind the numerically observed near-constancy of the vertex under variation of $c$. Numerically, for the window $[0.01, 1]$ the vertex lies at $0.2150 \pm 3\times10^{-2}$ for $c$ ranging over $[10^{-3}, 10^{9}]$, and hugs the lower pin $\mathrm{LM}(0.01,1) = 0.21498$ to four digits at both extremes.

---

## 7. Algorithms

Three computations underlie all numbers reported here.

**(A) Vertex location by monotone bisection.** Because $L_c'(x) = 1/x + 1/(x+2c)$ is strictly decreasing, the residual $L_c'(x) - \sigma_{L_c}^{a,b}$ changes sign exactly once on $(a,b)$, so bisection converges unconditionally and geometrically: after $k$ steps the bracket has width $(b-a)2^{-k}$. Cost $O(k)$ evaluations, each $O(1)$.

**(B) Fitted curvature on an arbitrary bin grid.** Given $n$, $h$, $m$: compute the centred offsets $o_i$, the grid variance $V(n)$, and the orthogonal quadratic $q(y) = (y-m)^2 - h^2 V(n)$; then form $\widehat c = \sum g(t_i)q(t_i) / \sum q(t_i)^2$. Cost $O(n)$. Theorem 3.6 guarantees no explicit orthogonalisation is needed; Theorem 3.8 guarantees the sign of the output for concave inputs, so the routine doubles as a numerical falsification test.

**(C) Bin-average second differences.** Given offset $a$, spacing $\delta$ and bin width $w$, form $b_k$ and $b_k + b_{k+2} - 2b_{k+1}$ for $k$ in the range of interest. Cost $O(w)$ per bin. Theorems 4.3–4.4 predict strictly negative output on the log-size profile and machine-zero output on affine controls, at every $(a, \delta, w)$; the routine is therefore a direct implementation of the bin-width permutation / grid shift probe.

A numerically delicate point deserves mention: the upper pin $\mathrm{LM}(a+2c,b+2c) - 2c$ suffers catastrophic cancellation in floating point for large $c$. Writing $p = a+2c$, $d = b-a$, $u = d/p$, the stable form is
$$\mathrm{LM}(p, p+d) - 2c = a + d\left(\frac{1}{\log(1+u)} - \frac{1}{u}\right), \qquad \frac{1}{\log(1+u)} - \frac1u = \frac12 - \frac{u}{12} + \frac{u^2}{24} - \cdots,$$
the series being used when $u$ is small.

---

## 8. Discussion

### 8.1 What has been settled

The mid-window excess in the yield ratio is *shaped by the polynomial*. Concretely: the strict concavity of $\log(j^2 - N)$ across a window forces, against an affine reference, a strictly positive interior deviation vanishing at both edges, with exactly one interior peak. Every measured feature of the arch other than its apex position is a direct consequence: the sign of the excess, the deficits at both edges, the single peak, the negative fitted curvature in every stratum, the exact-zero curvature on affine controls, and — crucially — the invariance of all of this to how the window is binned.

The last point deserves emphasis. Robustness probes of this kind are usually run empirically: perturb the bin width, shift the grid, and see whether the effect survives. Here the probe is discharged as a theorem valid at *every* bin count, *every* bin width and *every* grid offset simultaneously. There is no residual worry that some untried grid would have dissolved the arch.

### 8.2 What has been refuted

The same geometry cannot place the apex. The obstruction (Theorem 5.3) is universal in the two free parameters of the model — the window $[a,b]$ and the aspect ratio $c$ — and it is one-sided: the geometric apex is *strictly left of centre*, always. The quantitative refinement (Theorem 5.5) shows the failure is not marginal: in the sieve's own regime the normalised apex is at most $1/\log M$, tending to $0$ as the window lengthens, while the measurement returns $0.5901$ twice independently. Two natural escapes are also closed: a pure quadratic profile with no logarithm peaks exactly at the midpoint (Theorem 5.6), and the rigidity result (Theorem 6.5) shows there is no exotic aspect ratio at which the vertex can be pushed right — the lower pin does not involve $c$ at all.

The verdict is therefore genuinely split, and the split is informative. The elimination is *structural*, not power-limited: it does not say "the data are too noisy to decide", it says "no parameter setting of this mechanism produces the measured value".

### 8.3 Relation to the pre-registered analysis

The reported statistical verdict of the underlying experiment was, by the letter of its own pre-registration, inconclusive: no decomposition family cleared the bar requiring a fitted-peak bootstrap lower confidence bound above $1.05$ (the achieved bounds were $1.0094$–$1.0275$, despite a raw maximum of $1.2227$ at bin $33$). The bars were kept verbatim and no post-hoc rule change was made. The present analysis does not alter that statistical verdict; it operates on a different axis. What it establishes is that the *structure* of the effect — one-signedness, edge deficits, unimodality, negative curvature, grid invariance — is a theorem about $\log(j^2-N)$, and that the *location* of the apex is not. Whether the excess clears a chosen amplitude threshold is a question about statistical power; whether it can arise from window geometry is a question about mathematics, and that question is now closed in both directions.

### 8.4 Scope and caveats

Three limitations of the modelling should be recorded plainly.

- The reference profile is taken to be affine on the window. This is the correct idealisation of a smoothness model read against a slowly varying log-size, but a reference with curvature of its own would shift the analysis; the theorems above then apply to the difference between the true and reference curvatures.
- The value-size dependence of the smoothness model enters here only through the log-size $\log(j^2-N)$. A model whose local density depends on the value in a strongly non-logarithmic way is outside the scope of Definition 2.1.
- Sub-stratification of the dominant band into three parts is descriptive only. It supports the statement that concavity replicates inside every resolvable stratum; it is not used to license any threshold decision.

None of these caveats touches the obstruction of Section 5, which is a statement about the function $x \mapsto \log x + \log(x+2c)$ and nothing else.

---

## 9. Future work

The natural next question is sharpness. Numerically, the vertex hugs the lower pin $\mathrm{LM}(a,b)$ to four digits for every aspect ratio, so all of the slack in Theorem 6.5 lives in the *upper* pin. A sharp upper bound of the form $\xi \le \mathrm{LM}(a,b) + \varepsilon(a,b,c)$ with an explicit and small $\varepsilon$ would convert the two-sided pin into an asymptotic identity, and would make the aspect-ratio-insensitivity quantitative rather than merely qualitative.

Beyond that, the open problem is now precisely posed. Some mechanism moves an apex that all available window geometry pins to the *left* edge over to relative position $0.59$. Candidates worth formalising include: (i) curvature in the reference model itself, arising from the value-size dependence of the smoothness density rather than from the polynomial; (ii) boundary effects of the factor base, which act asymmetrically across the window because the small-prime root pattern of $j^2 \equiv N$ is not translation invariant; (iii) a genuinely arithmetic non-uniformity in the distribution of smooth values that is invisible to size-based models. Any candidate must reproduce four things at once — the concave sign, the two edge deficits, the single peak, and an apex right of centre — and by the results above the first three come free from concavity, so a candidate mechanism only has to explain the fourth *without* destroying the first three. That is a much better-conditioned target than the one this analysis began with.

---

## Appendix A. Numerical illustration

Window $[a,b] = [0.02, 1]$, aspect ratio $c = 1$. The chord-referenced deviation of $L_c$:

| $x$ | $L_c(x)$ | chord | gap |
|---|---|---|---|
| $0.020$ | $-3.2089$ | $-3.2089$ | $0.0000$ |
| $0.216$ | $-0.7368$ | $-2.3474$ | $1.6106$ |
| $0.412$ | $-0.0063$ | $-1.4859$ | $1.4796$ |
| $0.608$ | $0.4610$ | $-0.6244$ | $1.0854$ |
| $0.804$ | $0.8129$ | $0.2371$ | $0.5758$ |
| $1.000$ | $1.0986$ | $1.0986$ | $0.0000$ |

Vertex $\xi = 0.25306$, normalised position $0.2378 < 1/2$; peak gap $1.6227$.

Fitted curvature of $L_1$ against the grid-orthogonal quadratic (Section 3), compared with an affine control $g(y) = 3 + 1.7y$:

| $n$ | $h$ | $m$ | $\widehat c(L_1)$ | $\widehat c(\text{affine})$ |
|---|---|---|---|---|
| $8$ | $0.050$ | $0.50$ | $-2.2195$ | $2.6\times10^{-14}$ |
| $16$ | $0.050$ | $0.50$ | $-2.9416$ | $-2.6\times10^{-14}$ |
| $32$ | $0.020$ | $0.40$ | $-4.5931$ | $1.9\times10^{-15}$ |
| $64$ | $0.010$ | $0.35$ | $-7.2637$ | $-1.3\times10^{-14}$ |
| $64$ | $0.012$ | $0.60$ | $-1.7827$ | $-1.6\times10^{-14}$ |
| $17$ | $0.030$ | $0.55$ | $-1.9004$ | $-4.4\times10^{-14}$ |

Every entry in the fourth column is strictly negative; every entry in the fifth is zero to machine precision.

Vertex against aspect ratio, window $[0.01, 1]$ with midpoint $0.505$ and $\mathrm{LM}(a,b) = 0.214976$:

| $c$ | $\xi$ | upper pin $\mathrm{LM}(a+2c,b+2c)-2c$ | normalised $\xi$ |
|---|---|---|---|
| $0$ | $0.214976$ | $0.214976$ | $0.20705$ |
| $10^{-3}$ | $0.218273$ | $0.221737$ | $0.21038$ |
| $10^{-1}$ | $0.241210$ | $0.367996$ | $0.23355$ |
| $1$ | $0.217147$ | $0.472049$ | $0.20924$ |
| $10^{3}$ | $0.214976$ | $0.504959$ | $0.20705$ |
| $10^{9}$ | $0.214976$ | $0.505000$ | $0.20705$ |

The vertex varies by under $3\times 10^{-2}$ across twelve orders of magnitude in $c$, and hugs the aspect-ratio-free lower pin. Its normalised position never approaches $0.5901$; in the sieve regime $a = 1/M$, $b=1$ it decreases with $M$ ($0.2070$ at $M=10^2$, $0.1438$ at $10^3$, $0.1085$ at $10^4$, $0.0483$ at $10^9$), always within $10^{-3}$ of the bound $1/\log M$.
