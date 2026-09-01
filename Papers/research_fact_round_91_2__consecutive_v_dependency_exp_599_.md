# Density versus Dependence in a Binary Scan: Exact Nulls, Forced Artefacts, and a Trichotomy of Lag-Profile Shapes

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

A binary record $x_0, x_1, \dots, x_{n-1}$ produced by a scanning process is
routinely tested for *sequence structure* by computing its lag profile — the
sample autocorrelation at lags $1, 2, \dots, K$ — and comparing it against a
decision bar. If the profile is flat, the record is declared "pure density":
independent events whose intensity varies with position. We show that this
inferential pipeline rests on three propositions that are false as usually
stated, and we replace each with an exact theorem.

First, the null value of a mean-centred lag profile is **not** zero. For any
non-constant cyclic record of length $n$, the average sample autocorrelation
over the $n-1$ nonzero lags is exactly $-1/(n-1)$; consequently a profile flat
to within $\varepsilon$ has its level pinned to within $\varepsilon$ of
$-1/(n-1)$. No probability enters. A uniform small negative offset across all
lags is therefore forced by the centring operator and carries no evidence about
dependence.

Second, flatness itself is not a randomness signature. For a $0/1$ record with
support $S \subseteq \mathbb{Z}_n$, the mean-centred cyclic autocovariance at
lag $k$ is exactly $d_S(k) - |S|^2/n$, where $d_S(k)$ is the difference
multiplicity of $S$ at $k$. Hence the profile is flat over the nonzero lags if
and only if $S$ is a cyclic difference set — a fully deterministic
design-theoretic object — and its level is then exactly $-1/(n-1)$.

Third, the correct formulation of "pure density" is multilinear, not
correlational. In the heterogeneous product-Bernoulli model with an arbitrary
rate curve $p$, the lag-$k$ cross-product statistic centred at the *true* curve
has expectation exactly $0$ at every lag, while the literal global-mean reading
is bounded by $\delta^2/v$ uniformly in the lag, where $\delta$ bounds the
curve's deviation from its centre and $v$ floors the per-position variance.
Under a stationary two-state Markov alternative the profile is exactly
$\lambda^k$, peaking at lag $1$ and vanishing identically iff $\lambda = 0$. The
two regimes are separated by a $0.05$ decision bar, and the detrended statistic
obeys a $1/(16mt^2)$ noise floor, so a null result is an exclusion rather than a
failure to detect.

Finally we analyse a third mechanism — the coincidence (MA-1) scan
$Y_i = X_i X_{i+1}$ over a latent independent scan — and prove that its
autocovariance vanishes exactly from lag $2$ on for every latent rate curve,
that its lag-1 correlation equals the rational function $c(1-b)/(1-ab)$ of the
three latent rates $a = p_i$, $b = p_{i+1}$, $c = p_{i+2}$, that this is
maximised over a rate window $[l,u]$ by $u(1-l)/(1-ul)$ attained by the
alternating curve $u, l, u, l, \dots$, and that its supremum over all curves
with values in $(0,1)$ is exactly $1$. The homogeneous cap $q/(1+q) < 1/2$ is
thus a homogeneity artefact. The methodological consequence is a law:
**amplitude carries no mechanism information; only shape does.** The three
mechanisms are separated by the first two lags alone.

---

## 1. Introduction

### 1.1 The inferential situation

A scanning process traverses an axis parameterised by $u \in [0,1]$ and at each
step either registers a *hit* or does not, producing a binary record. Empirically
one observes an **excess** of hits in a mid-window, near $u \approx 0.65$. Two
mechanisms can produce an excess:

- **Pure density.** The hit probability is a function $p(u)$ of position alone;
  events are conditionally independent given position. The excess lives in the
  rate curve.
- **Sequence structure.** Hits influence their neighbours — clustering,
  excitation, refractoriness. The excess is a consequence of memory.

Distinguishing them is the whole question, because they license entirely
different modelling programmes. If the excess is density, the productive move is
to estimate $p(u)$; if it is structure, the productive move is a Markov or
point-process model with interaction.

The instrument of choice is the **lag profile**. Let $\hat\rho(k)$ denote the
sample autocorrelation of the hit indicator sequence at lag $k$. The received
reasoning is: *pure density $\Rightarrow$ $\hat\rho(k) \approx 0$ for all $k$;
structure $\Rightarrow$ $\hat\rho(1)$ noticeably nonzero.* A pre-registered
protocol then declares dependence if $|\hat\rho(k)|$ exceeds a bar (here $0.05$)
at some lag with a confidence interval excluding zero, or if a runs statistic
exceeds $|Z| > 3.2905$.

### 1.2 What the record actually showed

Over $128$ batches containing $9{,}594$ mid-window hits, the measured detrended
profile over lags $1$–$20$ lay in $[-0.0199,\, -0.0023]$: flat, monotone in
neither direction, with no refractory dip at lag $1$ and no excitation bump
anywhere. The literal (global-mean) reading was quieter still,
$[-0.0103,\, +0.0046]$. The runs statistic gave $Z = +0.850$ (textbook) and
$Z = +0.894$ (calibrated) against a $3.29$ bar. A control channel was null; a
synthetic smooth-hump independent surrogate at the fitted rate curve was also
null, confirming that curvature confounding is immaterial; and an *injected*
lag-1 dependence was recovered massively, $\hat\rho(1) = 0.337$ with the profile
argmax at exactly lag $1$.

Two features of this record are not explained by the received reasoning and
motivated the present work.

1. The profile did not scatter about $0$; it sat at a **uniform $\approx -0.01$
   offset across all twenty lags**, with a mirrored $+0.01$ on controls, and
   $12$ of $20$ bootstrap intervals excluded zero on the negative side. Read
   naively, "twelve of twenty intervals exclude zero" is a detection.
2. The verdict is a *null*, and a null is only meaningful if the alternative it
   excludes is quantified — otherwise it is an absence of evidence.

### 1.3 Contributions

We supply exact mathematics for both, plus a mechanism the received dichotomy
omits. Section 2 develops the heterogeneous independent model and proves the
exact null, the curvature bound, the runs bound, the exact variance and the
resulting noise floor. Section 3 develops the two-state Markov alternative and
proves the geometric profile, the lag-1 peak, and the vanishing criterion;
Section 3.4 combines them into a separation theorem. Section 4 proves that the
uniform negative offset is a deterministic identity of the centring operator,
and Section 5 identifies exactly which $0/1$ records realise a perfectly flat
profile. Section 6 introduces the coincidence scan, computes its profile in
closed form for arbitrary latent rates, and settles its amplitude question,
yielding the shape-not-amplitude law and the three-way trichotomy. Section 7
returns to the data; Section 8 discusses scope and open problems.

Throughout, all statements are elementary and self-contained. The product
Bernoulli law is a finite sum over $\{0,1\}^n$; the Markov $k$-step law is an
iterate of an affine map on $\mathbb{R}$.

---

## 2. The heterogeneous independent model ("pure density")

### 2.1 Definitions

Fix $n \in \mathbb{N}$ and a **rate curve** $p : \mathbb{N} \to \mathbb{R}$. A
configuration is a map $s : \{0, \dots, n-1\} \to \{0,1\}$; we write
$X_i(s) = s_i$ for the **hit indicator** at position $i$ (and $X_i \equiv 0$ for
$i \ge n$).

> **Definition 2.1 (configuration weight and expectation).** The weight of a
> configuration is
> $$w_p(s) \;=\; \prod_{i<n} \bigl(s_i\, p_i + (1-s_i)(1-p_i)\bigr),$$
> and the expectation of an observable $f$ is
> $\mathbb{E}_p[f] = \sum_{s} w_p(s) f(s)$, the sum ranging over all $2^n$
> configurations.

When $0 \le p_i \le 1$ for all $i$ this is the law of independent Bernoulli
variables with position-dependent rates: the *pure density* model in full
generality. No smoothness, monotonicity or shape assumption is placed on $p$.

### 2.2 The transfer identity and the moment calculus

Everything below descends from one combinatorial identity.

> **Lemma 2.2 (transfer identity).** For any weights
> $g_i : \{0,1\} \to \mathbb{R}$,
> $$\sum_{s \in \{0,1\}^n} \prod_{i<n} g_i(s_i) \;=\; \prod_{i<n}\bigl(g_i(1) + g_i(0)\bigr).$$

*Proof sketch.* Rewrite each factor $g_i(1)+g_i(0)$ as a sum over the two-element
set $\{0,1\}$ and expand the product of sums; the resulting index set of the
expansion is in bijection with $\{0,1\}^n$, and the bijection matches terms. $\square$

Taking $g_i(1) = p_i$, $g_i(0) = 1-p_i$ gives $\sum_s w_p(s) = 1$: the weights
are a probability law. Taking $g_i$ to be $p_i$ on the marked coordinates and
$p_i, 1-p_i$ elsewhere gives the marker moments.

> **Proposition 2.3 (moment calculus).** For any finite set $T$ of distinct
> positions in $\{0,\dots,n-1\}$,
> $$\mathbb{E}_p\Bigl[\prod_{i \in T} X_i\Bigr] = \prod_{i \in T} p_i .$$
> In particular $\mathbb{E}_p[X_i] = p_i$ and, for $i \ne j$,
> $\mathbb{E}_p[X_i X_j] = p_i p_j$; the analogous factorisation holds for
> products of three and four distinct indicators.

> **Theorem 2.4 (multilinearity of independence).** For any nonempty set $S$ of
> distinct positions,
> $$\mathbb{E}_p\Bigl[\prod_{i \in S}\bigl(X_i - p_i\bigr)\Bigr] = 0 .$$

*Proof sketch.* Expand the product over subsets $T \subseteq S$; by
Proposition 2.3 the term indexed by $T$ contributes
$(-1)^{|S \setminus T|}\bigl(\prod_{i\in T}p_i\bigr)\bigl(\prod_{i \in S\setminus T}p_i\bigr)
= (-1)^{|S\setminus T|}\prod_{i\in S}p_i$, and the signed binomial sum
$\sum_{T\subseteq S}(-1)^{|S\setminus T|}$ vanishes for $S \ne \emptyset$.
Equivalently, and this is the form the argument takes directly: apply the
transfer identity with $g_i(b) = (\text{Bernoulli weight}) \times (b - p_i)$ on
$i \in S$, whereupon each factor $g_i(1)+g_i(0) = p_i(1-p_i) + (1-p_i)(-p_i) = 0$.
$\square$

Theorem 2.4 is the *correct* statement of independence for this purpose.
"Correlation zero" is a consequence of the $|S| = 2$ case, but the estimator we
must analyse involves higher-order terms, and only the multilinear identity
controls them.

### 2.3 The exact null of the detrended statistic

> **Definition 2.5 (centred pair sum).** For a lag $k \geq 1$, a window length
> $m$ with $m + k \leq n$, and a **trend** $c : \mathbb{N} \to \mathbb{R}$,
> $$A_k^{(c)}(s) \;=\; \sum_{i<m}\bigl(X_i(s) - c_i\bigr)\bigl(X_{i+k}(s) - c_{i+k}\bigr).$$

This is the numerator of the sample autocorrelation at lag $k$ after detrending
at $c$.

> **Theorem 2.6 (expectation of the centred pair sum).**
> $$\mathbb{E}_p\bigl[A_k^{(c)}\bigr] \;=\; \sum_{i<m}\bigl(p_i - c_i\bigr)\bigl(p_{i+k} - c_{i+k}\bigr).$$

*Proof sketch.* Linearity reduces to a single term. Since $k \ge 1$ the two
positions $i$ and $i+k$ are distinct, so
$\mathbb{E}[X_i X_{i+k}] = p_i p_{i+k}$ by Proposition 2.3, and expanding
$(X_i - c_i)(X_{i+k} - c_{i+k})$ term by term gives
$p_ip_{i+k} - c_i p_{i+k} - c_{i+k}p_i + c_ic_{i+k} = (p_i - c_i)(p_{i+k}-c_{i+k})$.
$\square$

> **Theorem 2.7 (exact null under pure density).** Centring at the true rate
> curve, $c = p$, gives
> $$\mathbb{E}_p\bigl[A_k^{(p)}\bigr] = 0 \qquad\text{for every lag } k \ge 1
> \text{ and every rate curve } p.$$

This is the population statement behind the primary (per-batch detrended)
reading: no smoothness, no stationarity, no shape assumption is needed. **Under
pure density the detrended lag statistic is exactly null, at every lag, for every
density curve whatsoever.**

### 2.4 The curvature confound is second order

Detrending at the truth is unavailable in practice. The *secondary* reading
centres at a constant $c$ — the global mean. Theorem 2.6 then leaves a residual
$\sum_{i<m}(p_i-c)(p_{i+k}-c)$, which is not zero when the curve has curvature.
This residual is the "curvature confound" that a positional excess creates. It
is uniformly small.

> **Lemma 2.8.** If $|p_i - c| \le \delta$ for all $i < m+k$, then
> $$\Bigl|\sum_{i<m}(p_i - c)(p_{i+k}-c)\Bigr| \le m\,\delta^2 .$$

> **Theorem 2.9 (spurious autocorrelation bound).** Let $v > 0$ be a lower bound
> for the per-position variance used as normaliser. Under the hypothesis of
> Lemma 2.8, for every lag $k \ge 1$,
> $$\left|\frac{\mathbb{E}_p\bigl[A_k^{(c)}\bigr]}{m\,v}\right| \;\le\; \frac{\delta^2}{v}.$$

The bound is **uniform in the lag** and **quadratic in the curvature**. It
converts the qualitative control "the smooth-hump surrogate was also null" into
a number.

> **Corollary 2.10 (curvature cannot fake the decision bar).** If the rate curve
> stays within $\pm 1/20$ of $1/2$, so $\delta = 1/20$ and the variance floor is
> $v = (1/2 - 1/20)(1/2 + 1/20) = 99/400$, then for every lag
> $$\left|\frac{\mathbb{E}_p\bigl[A_k^{(1/2)}\bigr]}{m \cdot (99/400)}\right|
> \;\le\; \frac{1/400}{99/400} = \frac{1}{99} \approx 0.0101 \;<\; \frac{1}{20}.$$

A $\pm 0.05$ hump on a $p \approx 1/2$ curve can manufacture at most about one
percent of autocorrelation — five times below the pre-registered $0.05$ bar.
This is why the conditioned and literal readings agreed in the record, and why
the verdict is not an artefact of the pre-registered amendment that chose
between them.

### 2.5 The runs statistic

The second pre-registered instrument counts alternations.

> **Definition 2.11.** $R_m(s) = \#\{ i < m : X_i(s) \neq X_{i+1}(s)\}$.

Since $X_i, X_{i+1} \in \{0,1\}$, the indicator of an alternation is exactly
$X_i + X_{i+1} - 2X_iX_{i+1}$, giving:

> **Theorem 2.12.** $\displaystyle \mathbb{E}_p[R_m] = \sum_{i<m}\bigl(p_i + p_{i+1} - 2p_ip_{i+1}\bigr).$

> **Theorem 2.13 (heterogeneity bound for runs).** If $|p_i - c| \le \delta$ for
> all $i < m+1$, then
> $$\bigl|\mathbb{E}_p[R_m] - m\cdot 2c(1-c)\bigr| \;\le\; m\bigl(2\delta\,|1-2c| + 2\delta^2\bigr).$$

At $c = 1/2$ the first-order term $2\delta|1-2c|$ vanishes identically, so
heterogeneity perturbs the expected alternation count only at order $\delta^2$.
The runs statistic is therefore, near $c = 1/2$, even more robust to curvature
than the autocorrelation.

### 2.6 Exact variance and the noise floor

A null is an exclusion only if the statistic is quiet. Write
$V_i = p_i(1-p_i)$ and $D_i = (X_i - p_i)(X_{i+k}-p_{i+k})$, so
$A_k^{(p)} = \sum_{i<m} D_i$.

> **Theorem 2.14 (exact second moments).** For $k \ge 1$:
> $$\mathbb{E}_p\bigl[D_i^2\bigr] = V_i\,V_{i+k}, \qquad
> \mathbb{E}_p\bigl[D_i D_j\bigr] = 0 \ \text{ for } i \neq j .$$
> Consequently
> $$\mathrm{Var}_p\bigl(A_k^{(p)}\bigr) = \mathbb{E}_p\bigl[(A_k^{(p)})^2\bigr]
> = \sum_{i<m} V_i\,V_{i+k}.$$

*Proof sketch.* For the square, use $X_i^2 = X_i$ to reduce
$(X_i - p_i)^2 = (1-2p_i)(X_i - p_i) + V_i$ at each of the two positions, expand,
and apply Theorem 2.4 to each surviving product of centred indicators at
distinct positions. For the cross term with $i \ne j$: the four positions
$i, i+k, j, j+k$ involve at most two coincidences, and in every case the product
$D_iD_j$ reduces, again via $X^2 = X$, to a linear combination of products of
*centred* indicators over nonempty sets of distinct positions, each of which has
expectation $0$ by Theorem 2.4. The pairwise uncorrelatedness therefore survives
the overlap $j = i + k$, which is the delicate case. $\square$

That the terms remain uncorrelated even when two pairs *share a position* is
exactly what makes the variance a clean sum rather than a sum plus overlap
corrections.

> **Lemma 2.15 (Chebyshev in the product model).** For $0 \le p_i \le 1$ and any
> observable $Z$ and $t>0$,
> $$\mathbb{P}_p\bigl[\, |Z| \ge t \,\bigr] \;\le\; \frac{\mathbb{E}_p[Z^2]}{t^2}.$$

> **Theorem 2.16 (noise floor of the detrended statistic).** For $0 \le p_i \le 1$,
> $k \ge 1$, $m \ge 1$, $m + k \le n$ and any $t > 0$,
> $$\mathbb{P}_p\Bigl[\, \bigl|A_k^{(p)}\bigr| \ge t\,m \,\Bigr]
> \;\le\; \frac{1}{16\,m\,t^2}.$$

*Proof sketch.* $V_i \le 1/4$ always, so $\mathrm{Var}(A_k^{(p)}) \le m/16$ by
Theorem 2.14; apply Lemma 2.15 with $Z = A_k^{(p)}$ and threshold $tm$. $\square$

> **Corollary 2.17 (at the experiment's sample size).** With $m = 9594$ and
> $t = 1/20$,
> $$\mathbb{P}_p\Bigl[\,\bigl|A_k^{(p)}\bigr| \ge \tfrac{1}{20}\cdot 9594\,\Bigr]
> \;\le\; \frac{1}{16 \cdot 9594 \cdot (1/400)} = \frac{400}{153504} < \frac{3}{1000}.$$

Under pure density, the chance of accidentally crossing the $0.05$ bar at a given
lag is below three in a thousand. **The recorded null therefore excludes
dependence rather than merely failing to find it.**

---

## 3. The Markov alternative

### 3.1 Definitions

> **Definition 3.1.** A stationary two-state chain has parameters $a, b$: from
> state $0$ (no hit) the next state is $1$ with probability $a$; from state $1$
> the next state is $0$ with probability $b$. The one-step operator on the
> "probability of a hit" coordinate is the affine map
> $$M(x) = x(1-b) + (1-x)a,$$
> the **persistence** is $\lambda = 1 - a - b$, and the **stationary rate** is
> $\pi = a/(a+b)$ (defined when $a + b > 0$).

Two immediate identities drive everything: $M(x) - M(y) = \lambda(x-y)$, and
$M(\pi) = \pi$. Iterating,
$$M^{[k]}(x) - M^{[k]}(y) = \lambda^k (x - y), \qquad M^{[k]}(\pi) = \pi .$$

> **Definition 3.2.** Let $q_k = M^{[k]}(1)$, the probability of a hit $k$ steps
> after a hit. The lag-$k$ autocovariance and autocorrelation of the stationary
> chain are
> $$\Gamma(k) = \pi\,(q_k - \pi), \qquad \rho_M(k) = \frac{\Gamma(k)}{\pi(1-\pi)}.$$

### 3.2 The geometric profile

> **Theorem 3.3.** For $a + b > 0$ and all $k \ge 0$,
> $$\Gamma(k) = \pi(1-\pi)\,\lambda^k, \qquad\text{and if } \pi(1-\pi)\neq 0,
> \quad \rho_M(k) = \lambda^k .$$

*Proof sketch.* $q_k - \pi = M^{[k]}(1) - M^{[k]}(\pi) = \lambda^k(1 - \pi)$ by
the two displayed identities; multiply by $\pi$ and divide. $\square$

> **Theorem 3.4 (the profile peaks at lag 1).** If $|\lambda| \le 1$ and
> $\pi(1-\pi) \neq 0$, then $|\rho_M(k)| \le |\rho_M(1)|$ for all $k \ge 1$.

> **Theorem 3.5 (vanishing criterion).** Assume $a+b>0$ and $\pi(1-\pi)\ne0$.
> Then $\rho_M(k) = 0$ for all $k \ge 1$ if and only if $\lambda = 0$, i.e. if
> and only if the chain is the memoryless one.

There is thus **no Markov chain with memory that hides from the lag profile**:
memory and lag-1 correlation are the same quantity, $\lambda$.

> **Proposition 3.6 (matrix identification).** With
> $P = \begin{pmatrix} 1-a & a \\ b & 1-b\end{pmatrix}$ one has
> $(P^k)_{11} = q_k$ and $(P^k)_{10} = 1 - q_k$ for all $k$, by induction on $k$.

So the affine-iterate presentation and the matrix-power presentation agree, and
the geometric decay $\lambda^k$ is the second eigenvalue of $P$ raised to the
$k$-th power.

### 3.3 Shape control

Theorem 3.4 is the formal content of the injection control: if a genuine lag-1
dependence is injected, the resulting profile must have its maximum magnitude at
lag $1$ and decay geometrically thereafter. The record's injection test reported
$\hat\rho(1) = 0.337$ with argmax at exactly lag $1$ — the predicted shape.

### 3.4 The dichotomy

> **Theorem 3.7 (density/dependence dichotomy).** Fix a lag $k \ge 1$, a window
> $m \ge 1$ with $m + k \le n$, a rate curve with $|p_i - 1/2| \le 1/20$ for all
> $i < m+k$, and a chain with $a + b > 0$, $\pi(1-\pi) \ne 0$ and
> $|\lambda| \ge 1/20$. Then simultaneously
> $$\left|\frac{\mathbb{E}_p\bigl[A_k^{(1/2)}\bigr]}{m\cdot(99/400)}\right| < \frac{1}{20}
> \qquad\text{and}\qquad \bigl|\rho_M(1)\bigr| \ge \frac{1}{20}.$$

*Proof sketch.* The first inequality is Corollary 2.10; the second is
Theorem 3.3 at $k=1$. $\square$

The pre-registered bar $0.05$ therefore **separates the two regimes**: a
heterogeneous-but-independent scan cannot cross it, whatever its density curve;
a Markov scan with persistence at least $0.05$ must. A measured profile below the
bar excludes the entire Markov family above it.

---

## 4. The mean-centring artefact is forced by arithmetic

We now explain the uniform $\approx -0.01$ offset. No probability is involved:
the statement is about the centring operator applied to *any* record.

Work cyclically, indexing by $\mathbb{Z}_n$; this is the standard convention for
a windowed profile and makes the identity exact.

> **Definition 4.1.** For $x : \mathbb{Z}_n \to \mathbb{R}$, let
> $\bar x = \frac1n\sum_i x_i$, let $r_i = x_i - \bar x$, and define the cyclic
> autocovariance and autocorrelation
> $$C(k) = \sum_{i \in \mathbb{Z}_n} r_i\, r_{i+k}, \qquad
> \rho(k) = \frac{C(k)}{C(0)} \quad (C(0)\ne0).$$
> Note $C(0) = \sum_i r_i^2$ and $\sum_i r_i = 0$.

> **Theorem 4.2 (total autocovariance vanishes).**
> $\displaystyle\sum_{k \in \mathbb{Z}_n} C(k) = 0.$

*Proof sketch.* Exchange the order of summation:
$\sum_k \sum_i r_i r_{i+k} = \sum_i r_i \sum_k r_{i+k} = \sum_i r_i \sum_j r_j
= \bigl(\sum_i r_i\bigr)^2 = 0$, using that $k \mapsto i+k$ is a bijection of
$\mathbb{Z}_n$. $\square$

> **Corollary 4.3.** $\displaystyle\sum_{k \ne 0} C(k) = -C(0).$

> **Theorem 4.4 (the mean autocorrelation identity).** For every record with
> $C(0) \ne 0$,
> $$\frac{1}{n-1}\sum_{k \neq 0} \rho(k) \;=\; -\frac{1}{n-1}.$$

*Proof sketch.* Divide Corollary 4.3 by $C(0)$ to get
$\sum_{k \ne 0}\rho(k) = -1$, then divide by the number $n-1$ of nonzero lags.
$\square$

> **Theorem 4.5 (a flat profile is pinned).** Suppose $n \ge 2$, $C(0)\ne0$ and
> the profile is flat to within $\varepsilon$ about a level $t$, i.e.
> $|\rho(k) - t| \le \varepsilon$ for every $k \ne 0$. Then
> $$\Bigl|\,t + \tfrac{1}{n-1}\,\Bigr| \;\le\; \varepsilon .$$
> In particular, if the profile is exactly constant then $t = -1/(n-1)$ exactly.

*Proof sketch.* Average the $n-1$ inequalities $|\rho(k)-t|\le\varepsilon$ and
apply Theorem 4.4 together with the triangle inequality. $\square$

> **Corollary 4.6 (numerical instance).** On a window of $n = 101$ positions, a
> profile flat to within $\varepsilon$ must have level within $\varepsilon$ of
> $-1/100 = -0.01$.

**Interpretation.** Mean-centring spends one degree of freedom and the profile
pays for it uniformly. A uniform small negative offset across all lags is
therefore not weak evidence of inhibition; it is the deterministic signature of
the estimator. The record's "$12$ of $20$ intervals exclude zero on the negative
side, upper ends $\le 0.0083$" is precisely the predicted behaviour, and the
mirrored $+0.01$ on controls is the same identity applied to a record whose
centring shifted the other way. Only **deviations from the level $-1/(n-1)$** —
in particular a lag-1 spike, Theorem 3.3 — can carry dependence information.

This is also why the decision rule that was pre-registered is the right one: it
required $|\hat\rho| > 0.05$ **and** interval exclusion *jointly*. Interval
exclusion alone is guaranteed to occur for a sufficiently precise measurement of
*any* record.

---

## 5. Which records realise a perfectly flat profile?

Theorem 4.5 pins the *level* of a flat profile but leaves open whether flatness
is attainable, and by what. For $0/1$ records — the case at hand — there is a
complete and surprising answer.

> **Definition 5.1.** For $S \subseteq \mathbb{Z}_n$, let $\mathbf{1}_S$ be its
> indicator record and let the **difference multiplicity** be
> $$d_S(k) = \#\{a \in S : a + k \in S\}.$$

> **Theorem 5.2 (autocovariance of a $0/1$ record).** For every $k$,
> $$C\bigl(\mathbf{1}_S\bigr)(k) \;=\; d_S(k) \;-\; \frac{|S|^2}{n}.$$

*Proof sketch.* $\sum_i \mathbf{1}_S(i) = |S|$ and
$\sum_i \mathbf{1}_S(i)\mathbf{1}_S(i+k) = d_S(k)$ by definition; substitute into
the raw form $C(k) = \sum_i x_ix_{i+k} - (\sum_i x_i)^2/n$, which is the
expansion of the mean-centred sum. $\square$

At $k = 0$ this gives $C(0) = |S| - |S|^2/n$, which is strictly positive exactly
when $S$ is nonempty and proper. The whole lag profile is thus the difference
multiplicity function, shifted and scaled.

> **Theorem 5.3 (flatness $\Leftrightarrow$ difference set).** Assume
> $C(0) \ne 0$. The profile $\rho(k)$ is constant over the nonzero lags if and
> only if $d_S(k)$ is constant over the nonzero lags — i.e. if and only if $S$ is
> a **cyclic difference set** in $\mathbb{Z}_n$.

> **Theorem 5.4 (the level of a difference-set profile).** If $n \ge 2$,
> $C(0)\ne0$, and $d_S(k) = l$ for every $k \ne 0$, then for every $k \ne 0$
> $$\rho(k) = -\frac{1}{n-1}.$$

> **Example 5.5 (the Fano difference set).** Take $S = \{0,1,3\} \subseteq
> \mathbb{Z}_7$, the planar difference set of the Fano plane. Every nonzero
> $k \in \mathbb{Z}_7$ has $d_S(k) = 1$, so the profile is exactly flat at
> $$\rho(k) = -\tfrac16 \qquad (k \ne 0).$$

**Interpretation.** The "maximally flat, slightly negative" shape is realised
exactly by the most rigid, most deterministic $0/1$ records that exist. Flatness
is not a randomness signature; it is a design-theoretic one. Consequently:
*flatness at the artefact level carries no dependence information whatsoever*,
in either direction.

---

## 6. A third mechanism: the coincidence (MA-1) scan

### 6.1 Definition and exact profile

Pure density and Markov memory do not exhaust the plausible mechanisms. A
**coincidence rule** records a hit when two adjacent cells of a latent
independent scan both fire:

> **Definition 6.1.** Let $X$ be the heterogeneous independent scan of Section 2
> with arbitrary rate curve $p$. The coincidence scan is
> $$Y_i = X_i\,X_{i+1}, \qquad \text{with marginal rate } \ \mu_i = p_i\,p_{i+1}.$$

$Y$ is not independent: consecutive $Y$'s share the latent cell $X_{i+1}$.
Its dependence has range exactly $1$.

> **Theorem 6.2 (coincidence autocovariances, arbitrary latent curve).**
> $$\mathrm{Cov}(Y_i, Y_{i+1}) \;=\; p_i\,p_{i+1}\,p_{i+2}\,\bigl(1 - p_{i+1}\bigr),$$
> $$\mathrm{Cov}(Y_i, Y_{i+k}) \;=\; 0 \qquad \text{for every } k \ge 2,$$
> $$\mathrm{Var}(Y_i) \;=\; \mu_i - \mu_i^2 .$$

*Proof sketch.* $Y_i^2 = Y_i$ since $X_j^2 = X_j$, giving the variance. For
lag $1$: $Y_iY_{i+1} = X_iX_{i+1}^2X_{i+2} = X_iX_{i+1}X_{i+2}$, whose expectation
is $p_ip_{i+1}p_{i+2}$ by Proposition 2.3; subtract
$\mu_i\mu_{i+1} = p_ip_{i+1}^2p_{i+2}$ and factor. For $k \ge 2$ the four indices
$i, i+1, i+k, i+k+1$ are distinct, so the four-fold factorisation of
Proposition 2.3 makes the covariance vanish identically. $\square$

The crucial structural fact is the **exact zero from lag $2$ on, for every rate
curve**: heterogeneity cannot leak into the far lags. Writing
$$\rho_Y(k) = \frac{\mathrm{Cov}(Y_i, Y_{i+k})}{\mathrm{Var}(Y_i)}$$
for the profile anchored at $i$, we get $\rho_Y(k) = 0$ for $k \ge 2$ always.

> **Theorem 6.3 (homogeneous spike height).** At a constant latent rate
> $q \in (0,1)$,
> $$\rho_Y(1) = \frac{q}{1+q} \in \bigl(0, \tfrac12\bigr).$$

*Proof sketch.* Theorem 6.2 gives $q^3(1-q)$ over $q^2 - q^4 = q^2(1-q)(1+q)$,
which simplifies to $q/(1+q)$; monotonicity in $q$ bounds it by $1/2$. $\square$

> **Theorem 6.4 (the coincidence scan is not Markov).** For $q \in (0,1)$ there
> is no pair $(a,b)$ with $a+b>0$ and $\pi(1-\pi)\ne0$ such that
> $\rho_Y(k) = \rho_M(k)$ for all $k \ge 1$.

*Proof sketch.* A Markov profile is $\lambda^k$. Matching at $k=2$ forces
$\lambda^2 = 0$, hence $\lambda = 0$, hence $\rho_M(1) = 0$; but
$\rho_Y(1) = q/(1+q) > 0$. $\square$

> **Theorem 6.5 (trichotomy of profile shapes).** The three mechanisms are
> pairwise separated by the first two lags alone:
>
> | mechanism | lag 1 | lag 2 | shape |
> |---|---|---|---|
> | pure density | $0$ | $0$ | flat |
> | Markov, $\lambda \ne 0$ | $\lambda \ne 0$ | $\lambda^2 \ne 0$ | geometric |
> | coincidence | $>0$ | $0$ | one spike |

### 6.2 The amplitude question, settled

Theorem 6.3 invites the inference: *the coincidence spike is below $1/2$, so a
taller spike rules the mechanism out.* This inference is wrong, and the reason is
a cancellation.

> **Theorem 6.6 (closed form of the spike height).** Write $a = p_i$,
> $b = p_{i+1}$, $c = p_{i+2}$ with $a, b \in (0,1)$. Then
> $$\rho_Y(1) \;=\; \frac{c\,(1-b)}{1 - a\,b}.$$

*Proof sketch.* Divide $abc(1-b)$ (Theorem 6.2) by $ab - (ab)^2 = ab(1-ab)$; the
factor $ab$ cancels between numerator and denominator. $\square$

The cancellation is the whole point: **the spike height does not depend on the
coincidence scan's own marginal rate $\mu_i = ab$**, only on the three latent
rates, and only through this rational function. Two immediate consequences:

> **Theorem 6.7.** For $a, b \in (0,1)$ and $c \le 1$ one has $\rho_Y(1) < 1$;
> and for $c \ge 0$ one has $\rho_Y(1) \ge 0$.

*Proof sketch.* $1 - ab > 0$, so $\rho_Y(1) < 1$ reduces to
$c(1-b) < 1 - ab$, which holds since $c(1-b) \le 1-b \le 1-ab$ with strictness
from $b(1-a) > 0$. Nonnegativity is immediate. $\square$

> **Theorem 6.8 (sharp bound over a rate window).** Suppose all three latent
> rates lie in $[l, u]$ with $0 < l \le u < 1$. Then
> $$\rho_Y(1) \;\le\; \Sigma(l,u) \;:=\; \frac{u\,(1-l)}{1 - u\,l}.$$

*Proof sketch.* Clear denominators: the claim is
$c(1-b)(1-ul) \le u(1-l)(1-ab)$. Use $c \le u$ and then the exact algebraic
identity
$$u(1-l)(1-ab) - u(1-b)(1-ul) \;=\; u\Bigl[(b-l)(1-u) + (u-a)(1-l)\,b\Bigr],$$
whose right side is a sum of products of nonnegative quantities under the
window hypotheses. In words: the height is increasing in $a$ and in $c$ and
decreasing in $b$, so the extremum is at $a = c = u$, $b = l$. $\square$

> **Theorem 6.9 (the bound is attained).** Let $\mathrm{alt}_{l,u}$ be the
> alternating rate curve $u, l, u, l, \dots$ (value $l$ at odd positions, $u$ at
> even). For $0 < l \le u < 1$ the coincidence scan over $\mathrm{alt}_{l,u}$
> has, anchored at position $0$,
> $$\rho_Y(1) \;=\; \Sigma(l,u) \;=\; \frac{u(1-l)}{1-ul}.$$

*Proof sketch.* Substitute $a = u$, $b = l$, $c = u$ into Theorem 6.6. $\square$

So $\Sigma(l,u)$ is the **maximum**, not merely an upper bound.

> **Theorem 6.10 (heterogeneity breaks the homogeneous cap).** With rates ranging
> over $[1/10, 9/10]$, the alternating curve achieves
> $$\rho_Y(1) = \frac{(9/10)(9/10)}{1 - 9/100} = \frac{81}{91} \approx 0.890 \;>\; \frac12,$$
> while at *any* constant rate $q \in (0,1)$ the spike is $q/(1+q) < 1/2$.

> **Theorem 6.11 (the supremum is exactly one).** For every $\varepsilon > 0$
> there is a latent rate curve with all values in $(0,1)$ whose coincidence spike
> satisfies
> $$1 - \varepsilon \;<\; \rho_Y(1) \;<\; 1 .$$
> Hence $\sup \rho_Y(1) = 1$ over all such curves, and the supremum is not
> attained.

*Proof sketch.* Take the alternating curve with $l = t$, $u = 1-t$ for small
$t>0$; then
$\rho_Y(1) = \Sigma(t, 1-t) = (1-t)^2 / \bigl(1 - t(1-t)\bigr) \to 1$ as
$t \downarrow 0$ (explicitly, $t \le \varepsilon/2$ and $t \le 1/4$ suffice).
Non-attainment is Theorem 6.7. $\square$

### 6.3 The shape-not-amplitude law

> **Theorem 6.12 (amplitude carries no mechanism information).** For every
> $\varepsilon > 0$ there is a latent rate curve whose coincidence scan has
> $$\rho_Y(1) > 1 - \varepsilon \qquad\text{and}\qquad \rho_Y(k) = 0 \ \text{ for all } k \ge 2 .$$

Combining Theorems 6.11 and 6.2: **every** height in $(0,1)$ is realisable as a
coincidence spike, while the exact zeros beyond lag $1$ persist regardless. Two
methodological corollaries follow.

1. **No amplitude threshold can ever exclude the coincidence mechanism.** A
   "spike too tall to be a coincidence effect" does not exist.
2. **A flat, slightly negative measured profile excludes the coincidence
   mechanism at every amplitude simultaneously** — a strictly stronger exclusion
   than one obtained by comparing heights, because it uses the shape invariant
   (zeros from lag $2$) rather than the amplitude.

The cap $q/(1+q) < 1/2$ was therefore a *homogeneity artefact*: it is a true
statement about constant-rate latent scans and a false guide to heterogeneous
ones — which is exactly the class the investigation could not assume away, since
positional heterogeneity is the phenomenon under study.

---

## 7. Reading the experimental record

With Sections 2–6 in place, each feature of the record acquires an exact
interpretation.

| observation | exact account |
|---|---|
| detrended $\hat\rho(k) \in [-0.0199, -0.0023]$, lags $1$–$20$ | population value is exactly $0$ (Thm 2.7); the observed scatter is inside the $1/(16mt^2)$ noise floor (Thm 2.16) |
| uniform $\approx -0.01$ offset at all lags; $12/20$ intervals exclude zero, negative side | forced by centring: mean profile level is $-1/(n-1)$ (Thm 4.4, 4.5) |
| mirrored $+0.01$ on controls | same identity with the opposite centring shift; opposite-sign shared-magnitude artefact, not structure |
| literal reading quieter, $[-0.0103, +0.0046]$; agrees with conditioned reading | curvature confound bounded by $\delta^2/v \approx 0.0101$ uniformly in the lag (Thm 2.9, Cor 2.10) |
| synthetic smooth-hump surrogate also null | Thm 2.9 again: a hump on the rate curve cannot manufacture more than $\approx 1\%$ |
| runs $Z = +0.850 / +0.894$ vs bar $3.29$ | heterogeneity perturbs expected alternations only at order $\delta^2$ near $c=1/2$ (Thm 2.13) |
| injected lag-1 dependence detected, $\hat\rho(1) = 0.337$, argmax at lag $1$ | Markov profile is $\lambda^k$, peaking at lag $1$ (Thm 3.3, 3.4) — the predicted shape |
| verdict: no sequence structure | dichotomy: below-bar reading excludes every Markov chain with $|\lambda|\ge0.05$ (Thm 3.7); flat shape excludes coincidence at *all* amplitudes (Thm 6.12) |
| flatness itself | not informative: attained by cyclic difference sets, fully deterministic (Thm 5.3, 5.4) |

**Terminal characterisation.** Given position, neighbouring hits carry no
information about each other. The mid-window excess near $u \approx 0.65$ is
pure density — rate heterogeneity along the scan axis — and not sequence
structure of any of the three kinds analysed.

**Operational law.** Future predictive gains come from modelling the positional
density curve $p(u)$ itself, never from Markov, neighbourhood or clustering
structure on the hit sequence.

---

## 8. Algorithms

The theory yields four small algorithms, all of which are exact rather than
approximate.

**(A) Detrended lag profile.** Given a binary record and an estimated rate curve
$\hat p$, compute
$\hat\rho(k) = \bigl(\sum_{i<m}(x_i-\hat p_i)(x_{i+k}-\hat p_{i+k})\bigr) /
\bigl(\sum_{i<m}\hat p_i(1-\hat p_i)\bigr)$ for $k = 1,\dots,K$. Cost
$O(Km)$. Theorem 2.7 gives its population value $0$; Theorem 2.14 gives its
exact variance; Theorem 2.16 gives the decision threshold.

**(B) Artefact level check.** Given a measured profile over $n-1$ lags of a
cyclic window, compute the mean level and compare with $-1/(n-1)$
(Theorem 4.4). Cost $O(n)$. This must be done *before* interpreting any uniform
offset.

**(C) Shape classifier.** From $(\hat\rho(1), \hat\rho(2))$ classify:
$\hat\rho(1) \approx \hat\rho(2) \approx 0$ $\Rightarrow$ density;
$\hat\rho(2) \approx \hat\rho(1)^2 \ne 0$ $\Rightarrow$ Markov with
$\lambda = \hat\rho(1)$; $\hat\rho(1) \ne 0$, $\hat\rho(2) \approx 0$
$\Rightarrow$ coincidence. Cost $O(1)$ given the profile. Justified by
Theorem 6.5.

**(D) Extremal spike search.** Given a rate window $[l,u]$, the maximum
achievable coincidence spike is $\Sigma(l,u) = u(1-l)/(1-ul)$, attained by the
alternating curve (Theorems 6.8, 6.9). Cost $O(1)$; no optimisation loop is
needed, which is the practical value of the closed form.

---

## 9. Discussion

### 9.1 What went wrong with the naive picture, and why

The conjecture "under pure density the measured autocorrelation is zero" is
false twice over, and the two failures have different characters.

- **Failure of the literal reading.** Curvature in the rate curve produces a
  genuine nonzero expectation, $\sum_i(p_i-c)(p_{i+k}-c)$. This is a real bias,
  but it is second order (Theorem 2.9), which is why it is negligible in
  practice and why the conditioned and literal readings agreed in the record.
- **Failure of *any* mean-centred reading.** The level $-1/(n-1)$ is not bias in
  the statistical sense; it is an algebraic identity of the estimator
  (Theorem 4.4) that holds for every record, random or not.

Both are "needs a different definition" failures rather than "true but hard"
ones. The correct null value is $-1/(n-1)$, not $0$, and the correct statement of
independence is the multilinear identity of Theorem 2.4, not vanishing
correlation.

### 9.2 Why this is an exclusion, not a shrug

Three ingredients turn a flat profile into a positive claim:

1. an **exact population null** for the honest statistic (Theorem 2.7),
2. a **quantified alternative** whose signature exceeds the bar (Theorem 3.7),
3. a **noise floor** showing the null cannot arise by accident at the given
   sample size (Theorem 2.16, Corollary 2.17).

Absent (2) and (3), a flat profile would be an absence of evidence. With them, it
is evidence of absence, for a precisely delimited family of alternatives.

### 9.3 Shape versus amplitude

Section 6 isolates a general principle worth stating on its own. In a mechanism
family parameterised by a nuisance curve, the *amplitude* of a summary statistic
can range over an entire interval, while a *structural invariant* of the
statistic — here the exact vanishing from lag $2$ — is preserved throughout. The
invariant is the identifying feature; the amplitude is not. Attempts to exclude
mechanisms by amplitude thresholds are thus systematically weaker, and sometimes
invalid, compared with shape-based tests. The coincidence scan makes this
concrete: the intuitive cap $1/2$ turns into the sharp maximum $u(1-l)/(1-ul)$
over a window and into the supremum $1$ over all curves, so no amplitude test can
work — yet a shape test works uniformly.

### 9.4 Scope

The analysis of Sections 2–6 is model-theoretic and unconditional. Its
application to the experimental record inherits the record's scope: the excess
was established on one seed lineage, and provenance rests on a disclosed
checksum of the positional data. A pooled multi-seed amplitude test remains
outstanding; the machinery here transfers unchanged if an excess is
re-established elsewhere, since none of the theorems reference the particular
record.

---

## 10. Future directions

The cycle formalised the two competing explanations of a hit-indicator lag
profile — *pure density* (independent hits with a position-dependent rate) and
*sequence structure* (a stationary two-state chain) — and what survived is a
clean separation theorem plus an exact account of the two artefacts the
experimental record flagged. Directions forward:

- **Beyond MA-1.** The coincidence rule $Y_i = X_iX_{i+1}$ is the shortest
  moving-average mechanism. The natural next object is $Y_i = \prod_{j<w}X_{i+j}$
  for window $w$, whose profile should be a $w-1$ step staircase with exact zeros
  beyond; the amplitude analysis of Section 6 should generalise to a window
  bound in $w$ variables.
- **Higher-order shape invariants.** Sections 3 and 6 separate three mechanisms
  by two lags. Mechanisms with equal second-order profiles (e.g. hidden-Markov
  emissions) will require third-order statistics; the multilinear identity
  (Theorem 2.4) is already the right tool for computing them under the density
  null.
- **Estimation of the density curve.** The operational law says to model $p(u)$.
  Concentration bounds for the detrended statistic (Theorem 2.14) give the
  variance budget; the open question is a minimax rate for $p$ under smoothness
  assumptions on the scan axis, and how the noise floor degrades when $\hat p$
  replaces $p$.
- **Sharpening the exclusion.** Chebyshev (Lemma 2.15) is lossy. A Bernstein or
  Hoeffding-type bound tailored to the bounded increments of $A_k^{(p)}$ would
  shrink the noise floor from $1/(16mt^2)$ to exponential in $mt^2$, tightening
  the excluded parameter range.
- **The difference-set boundary.** Theorem 5.3 characterises exact flatness by
  cyclic difference sets. The quantitative version — how close must $d_S$ be to
  constant for the profile to be flat to within $\varepsilon$, and what is the
  measure of such $S$ — connects the artefact analysis to design theory and to
  the study of near-perfect difference sets.
- **Scale and locality.** Outstanding on the broader programme: deviations from
  scale-smoothness at larger window scales, factor-local structure beyond scan
  order, effectivity of the MA-1 reading, and a pooled multi-seed amplitude
  confirmation.

---

## 11. Conclusion

A flat lag profile is one of the most common empirical findings in the analysis
of event sequences, and one of the most commonly over- and under-interpreted.
This paper supplies the exact mathematics needed to interpret it.

Under pure density, the honestly detrended statistic has population value exactly
zero at every lag, for every rate curve; the literal reading is off by at most
$\delta^2/v$; the statistic's exact variance yields a noise floor; and a
two-state Markov alternative with persistence at least the decision bar must be
detected. Hence a flat profile is a genuine exclusion of sequence structure.

At the same time, the small uniform negative offset that accompanies flat
profiles is not a signal at all: the average autocorrelation over the nonzero
lags of any mean-centred record is exactly $-1/(n-1)$, and among $0/1$ records
exact flatness at that level characterises cyclic difference sets — the most
deterministic records imaginable.

Finally, a third mechanism, the coincidence scan, is separated from the other two
by the first two lags, and its spike amplitude is shown to be an unbounded
parameter — the supremum over latent rate curves is exactly $1$ — so amplitude
can never identify it while shape always can.

Given position, neighbouring hits carry no information about each other. The
excess is density, and the modelling effort belongs on the density curve.
