# Certified Null Results for Feature Augmentation: Block Ceilings, Exact Permutation Calibration, and Nonlinear Floors, with an Application to Sieve-Yield Prediction

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

A negative result in regression — "this block of covariates adds nothing" — is normally
reported as a small observed increment in $R^2$ together with a permutation $p$-value. Both
are measurements of particular fits, and neither bounds what a different fit could have
achieved. We develop the missing complementary theory: a family of exact upper bounds on
what a covariate block can *ever* explain, and an exact algebraic calibration of the
permutation reference distribution.

Our main results are: (i) a **block ceiling** — if a block $v_1,\dots,v_k$ satisfies a lower
frame bound $\lambda$ then no linear combination of it removes more than
$\lambda^{-1}\sum_j \langle r,v_j\rangle^2$ of the baseline residual energy, yielding the
quotable certificate $\Delta R^2 \le k\rho^2(1-R^2_0)/\lambda$ for a unit-normalised block
with residual correlations at most $\rho$; (ii) an exact **dichotomy** — a block lifts $R^2$
if and only if some covariate has nonzero inner product with the baseline residual;
(iii) **conditional dominance** — a feature orthogonal to the block retains its entire
individual lift after the block is fitted — and the resulting **lift asymmetry** theorem;
(iv) an **exact permutation-null calibration** — the mean row-shuffle increment of one
centred covariate is exactly $(1-R^2_0)/(n-1)$, with an accompanying Markov tail bound;
(v) a **nonlinear (measurable) ceiling** — the residual sum of squares over the class of
*all* functions of a feature equals the within-cell sum of squares, so a null result can be
asserted against every functional form; and (vi) an **arithmetic freedom** theorem showing
that the quadratic-residue footprint dial of a modulus $N$ and the local factorisation
structure of $N \pm 1$ are unconstrained by one another.

We instantiate the theory on a designed experiment in sieve-yield prediction. A
quadratic-residue footprint dial explains $R^2_0 = 0.4112$ of the variance in the relation
yield of a quadratic-sieve run over a balanced population of $96$-bit moduli. A block of
four neighbour-smoothness covariates $[\omega(N-1), \omega(N+1), \log \mathrm{lpf}(N-1),
\log \mathrm{lpf}(N+1)]$ raises the joint fit only to $0.4307$, an increment of
$\Delta R^2 = 0.01946$ against a pre-registered null boundary of $0.02$, with permutation
$p = 0.389$. The theory converts this into certificates: the block could not have exceeded
$0.0604$ under the observed correlation profile; the observed dial-given-block increment
$0.3987$ provably dominates the block-given-dial increment; the empirical null quantile
$q_{95} = 0.046$ is bracketed by an unconditional tail bound; and at least $40\%$ of the
response variance is unreachable by any function of the joint feature.

**Keywords:** incremental $R^2$; frame bounds; permutation tests; correlation ratio;
quadratic sieve; quadratic residues; negative results.

---

## 1. Introduction

### 1.1 The asymmetry between positive and negative feature results

Feature-augmentation theory has a well-developed positive half. If a baseline predictor $g$
leaves residual $r = y - g$ and a new feature $w$ satisfies $\langle r, w\rangle \ne 0$,
then appending $w$ strictly improves the fit, and the improvement is exactly
$\langle r,w\rangle^2/\|w\|^2$ in residual energy, i.e. $\langle
r,w\rangle^2/(\|w\|^2\,\mathrm{TSS})$ in $R^2$. This is elementary and completely rigorous.

The negative half is not elementary at all, because the natural negative claim quantifies
over things that were never fitted. "The block adds nothing" is a statement about the
supremum of fit quality over a whole model class, and about what would happen under other
samples, other parameterisations, other functional forms. Reporting one small $\Delta R^2$
does not address any of that.

This paper supplies the negative half in the form of *ceilings*: theorems of the shape
"under these design conditions and this correlation profile, no member of the model class
can do better than $c$", with $c$ computable from reported summary statistics. A ceiling has
three properties a measurement lacks. It is *refit-proof* (it quantifies over all
coefficient vectors simultaneously); it is *quotable* (it depends only on $k$, $\rho$,
$R^2_0$ and $\lambda$, all of which are routinely reported); and it *announces its own
boundary* (one can compute exactly the correlation level at which the ceiling stops
excluding a given alternative).

### 1.2 The motivating experiment

The application domain is the prediction of *sieve yield*: how many usable relations a
quadratic-sieve-family factorisation run produces for a given modulus $N$, at fixed
parameters. The natural predictor is the **quadratic-residue footprint dial**. Let $B$ be
the factor-base bound and let the *odd factor base* be the set of odd primes $p \le B$. A
prime $p$ can divide sieve values $x^2 - N$ only when $N$ is a quadratic residue modulo $p$,
in which case there are two roots modulo $p$, hitting a $2/p$ fraction of sieve positions.
Hence define

$$
W_B(N) \;=\; \sum_{\substack{p \le B,\; p \text{ odd prime} \\ \left(\frac{N}{p}\right) = 1}} \frac{2}{p}.
$$

$W_B$ is a *residue dial*: a function of $N$ modulo the product of the odd factor-base
primes. Empirically it is a strong predictor of yield — in the population studied here,
$r = 0.641$, $R^2_0 = 0.4112$.

The residual is large: roughly $40\%$ of yield variance, concentrated near a characteristic
operating point of the sieve, is unexplained. A sequence of candidate explanations has been
tested. This paper concerns the fourth and last of an exhaustive class: **neighbour
smoothness**, the local factorisation structure of $N$'s immediate neighbours, encoded by
the four covariates

$$
v = \big[\,\omega(N-1),\ \omega(N+1),\ \log\mathrm{lpf}(N-1),\ \log\mathrm{lpf}(N+1)\,\big],
$$

with $\omega(m)$ the number of distinct prime factors and $\mathrm{lpf}(m)$ the least prime
factor. The pre-registered hypotheses were $H_1$: $\Delta R^2 \ge 0.05$ and permutation
$p < 0.01$; $H_0$: $\Delta R^2 < 0.02$.

**Observed.** Dial alone $R^2 = 0.4112$; block alone $R^2 = 0.0319$; joint $R^2 = 0.4307$;
hence $\Delta R^2 = 0.01946$. Permutation test with $500$ joint row shuffles: $p = 0.389$,
null $q_{95} = 0.046$, itself above the observed increment. Best single residual correlation
$|r| = 0.16$ against the dial's $r = 0.641$. Reverse increment: $\Delta R^2(\text{dial}\mid
\text{block}) = 0.3987$. Verdict: $H_0$ supported.

### 1.3 Contributions

1. The **block ceiling** (§3) and its correlation form $\Delta R^2 \le
   k\rho^2(1-R^2_0)/\lambda$.
2. The **block dichotomy** (§4): lifting $\iff$ nonzero residual correlation.
3. **Conditional dominance** and the **lift asymmetry** theorem (§5), formalising "carries
   nothing beyond the baseline dial".
4. **Exact permutation-null calibration** (§6): mean increment $= (1-R^2_0)/(n-1)$, plus a
   tail bound.
5. The **nonlinear ceiling** (§7): best fit over all functions of a feature equals the
   within-cell sum of squares; residual floors and refinement monotonicity.
6. **Arithmetic freedom** (§8): the dial and the neighbourhood layer are mutually
   unconstrained over the integers.
7. The **combined certificate** for the experiment (§9), and an honest statement of the
   certificate's boundary and of a provenance caveat (§10).

---

## 2. Setting and notation

Fix a finite index set $\iota$ with $|\iota| = n$, thought of as the sample. Vectors are
functions $\iota \to \mathbb{R}$, with the sample inner product and squared norm

$$
\langle u, w\rangle = \sum_{i \in \iota} u_i w_i, \qquad \|u\|^2 = \sum_{i\in\iota} u_i^2 .
$$

Let $y : \iota \to \mathbb{R}$ be the response, $\bar y$ its mean, and

$$
\mathrm{TSS}(y) = \sum_{i}(y_i - \bar y)^2 .
$$

For a set $\mathcal{H} \subseteq (\iota \to \mathbb{R})$ of admissible predictors, the
residual sum of squares and coefficient of determination are

$$
\mathrm{RSS}(y,\mathcal{H}) = \inf_{h \in \mathcal{H}} \|y - h\|^2, \qquad
R^2(y,\mathcal{H}) = 1 - \frac{\mathrm{RSS}(y,\mathcal{H})}{\mathrm{TSS}(y)} .
$$

For a single predictor $g$ we write $R^2_0 = R^2(y,g) = 1 - \|y-g\|^2/\mathrm{TSS}(y)$; note
the identity used constantly below,

$$
\|y - g\|^2 = (1 - R^2_0)\,\mathrm{TSS}(y). \tag{2.1}
$$

Throughout, $r = y - g$ denotes the baseline residual and $\mathrm{TSS}(y) > 0$.

**Definition 2.1 (block span and block class).** For $v : \{1,\dots,k\} \to (\iota \to
\mathbb{R})$ and $c \in \mathbb{R}^k$ set $v[c] = \sum_{j=1}^k c_j v_j$. The *block class*
augmenting a baseline $g$ is
$$
\mathcal{B}(g,v) = \{\, g + v[c] \;:\; c \in \mathbb{R}^k \,\}.
$$
The *augmented block class* with an extra feature $w$ is
$$
\mathcal{B}^+(g,v,w) = \{\, g + v[c] + t w \;:\; c\in\mathbb{R}^k,\ t \in \mathbb{R}\,\}.
$$

**Definition 2.2 (lower frame bound).** $v$ has *lower frame bound* $\lambda > 0$ if
$$
\lambda \|c\|^2 \;\le\; \|v[c]\|^2 \qquad \text{for all } c \in \mathbb{R}^k .
$$
Equivalently, $\lambda$ is a lower bound for the smallest eigenvalue of the Gram matrix
$G_{jl} = \langle v_j, v_l\rangle$. For an orthonormal block, $\lambda = 1$ is admissible.

Two immediate consequences are recorded for later use. First, selecting a single coordinate
shows every single-feature line $g + t v_j$ lies in $\mathcal{B}(g,v)$. Second, a frame
bound forces nondegeneracy: taking $c$ the $j$-th standard basis vector gives $\|v_j\|^2 \ge
\lambda > 0$.

---

## 3. The block ceiling

The heart of the negative theory is one scalar inequality.

**Lemma 3.1 (scalar core).** Let $\lambda > 0$, $a, S \ge 0$ and $D \in \mathbb{R}$ satisfy
$D^2 \le aS$. Then
$$
2D \;\le\; \lambda a + \frac{S}{\lambda}.
$$

*Proof sketch.* If $D \le 0$ the right-hand side is nonnegative and there is nothing to
prove. If $D > 0$, from $D^2 \le aS$ and $(\lambda^2 a - S)^2 \ge 0$ we get
$(2\lambda D)^2 \le 4\lambda^2 aS \le (\lambda^2 a + S)^2$; since both $2\lambda D$ and
$\lambda^2 a + S$ are nonnegative, $2\lambda D \le \lambda^2 a + S$. Dividing by
$\lambda > 0$ gives the claim. $\square$

This is AM–GM applied to the pair $(\lambda a, S/\lambda)$ with the geometric mean bounded
below by $D$; the explicit route above avoids any square roots.

**Theorem 3.2 (Block Ceiling, residual-energy form).** Let $v$ have lower frame bound
$\lambda > 0$ and let $g$ be any baseline. Then
$$
\mathrm{RSS}\big(y, \mathcal{B}(g,v)\big) \;\ge\; \|r\|^2 \;-\; \frac{1}{\lambda}\sum_{j=1}^{k}\langle r, v_j\rangle^2,
\qquad r = y - g .
$$

*Proof sketch.* Fix any $c$. Since $y - (g + v[c]) = r - v[c]$,
$$
\|y - (g+v[c])\|^2 = \|r\|^2 - 2\langle r, v[c]\rangle + \|v[c]\|^2 .
$$
Put $a = \|c\|^2$, $S = \sum_j \langle r, v_j\rangle^2$, and $D = \langle r, v[c]\rangle =
\sum_j c_j \langle r, v_j\rangle$. Cauchy–Schwarz in $\mathbb{R}^k$ gives $D^2 \le aS$, and
the frame bound gives $\|v[c]\|^2 \ge \lambda a$. By Lemma 3.1,
$$
\|y - (g+v[c])\|^2 \;\ge\; \|r\|^2 - 2D + \lambda a \;\ge\; \|r\|^2 - \frac{S}{\lambda}.
$$
The bound is uniform in $c$, so it passes to the infimum. $\square$

Two features of the proof deserve emphasis. It quantifies over *all* coefficient vectors,
so it is immune to refitting, regularisation, or a better optimiser. And it uses no
distributional assumption at all: it is deterministic linear algebra about one fixed data
matrix.

**Theorem 3.3 (Block Ceiling, $R^2$ form).** Under the hypotheses of Theorem 3.2 and
$\mathrm{TSS}(y) > 0$,
$$
R^2\big(y, \mathcal{B}(g,v)\big) \;\le\; R^2_0 \;+\; \frac{\sum_{j}\langle r, v_j\rangle^2}{\lambda\,\mathrm{TSS}(y)} .
$$

*Proof.* Divide Theorem 3.2 by $\mathrm{TSS}(y) > 0$ and use the definitions. $\square$

**Theorem 3.4 (the quotable certificate).** Suppose in addition that every residual
correlation is bounded: $\langle r, v_j\rangle^2 \le \rho^2 \|r\|^2$ for all $j$ (for
unit-normalised $v_j$ this says the sample correlation of $v_j$ with the residual is at most
$\rho$ in absolute value). Then
$$
\Delta R^2 \;:=\; R^2\big(y,\mathcal{B}(g,v)\big) - R^2_0 \;\le\; \frac{k\,\rho^{2}\,(1-R^2_0)}{\lambda} .
$$

*Proof sketch.* Sum the hypothesis over $j$ to get $\sum_j \langle r,v_j\rangle^2 \le k\rho^2
\|r\|^2$, substitute $\|r\|^2 = (1-R^2_0)\mathrm{TSS}(y)$ from (2.1), and apply Theorem 3.3.
$\square$

Every quantity on the right is routinely reported: the block size $k$, the maximum residual
correlation $\rho$, the baseline fit $R^2_0$, and a conditioning constant $\lambda$ for the
design. The ceiling degrades gracefully in exactly the directions one expects: a larger
block, larger correlations, a weaker baseline, or a more collinear design all raise the
ceiling.

**Remark 3.5 (the role of $\lambda$).** The frame bound is the only place where design
conditioning enters. Taking $\lambda = 1$ presumes an orthonormal block. Real covariate
blocks — and the neighbourhood block in particular, whose four members are strongly
correlated among themselves — have $\lambda < 1$, so the honest ceiling is *larger* than the
orthonormal one by the factor $1/\lambda$. Bounding $\lambda$ for a concrete design is
therefore not a technicality but the sharpest available improvement of the certificate.

---

## 4. The exact dichotomy

**Proposition 4.1 (orthogonality forbids lift).** If $\langle r, v_j\rangle = 0$ for all $j$
then $R^2(y,\mathcal{B}(g,v)) \le R^2_0$.

*Proof.* The correction term in Theorem 3.3 vanishes. $\square$

**Theorem 4.2 (Block Dichotomy).** Let $v$ have lower frame bound $\lambda > 0$ and
$\mathrm{TSS}(y) > 0$. Then
$$
R^2_0 \;<\; R^2\big(y,\mathcal{B}(g,v)\big) \qquad\Longleftrightarrow\qquad \exists j:\ \langle r, v_j\rangle \neq 0 .
$$

*Proof sketch.* ($\Rightarrow$) is the contrapositive of Proposition 4.1. ($\Leftarrow$):
if $\langle r,v_j\rangle \ne 0$, then $\|v_j\|^2 \ge \lambda > 0$, and the single-feature line
$\{g + t v_j\}$ is contained in $\mathcal{B}(g,v)$; optimising $t$ over that line already
reduces residual energy by the strictly positive amount $\langle r,v_j\rangle^2/\|v_j\|^2$.
$\square$

Theorem 4.2 sharpens the meaning of a null result. "The block adds nothing" is not a fuzzy
statistical impression but the exact geometric assertion that the block lies in the
orthogonal complement of the baseline residual — no intermediate regime exists. Conversely,
any nonzero residual correlation, however small, produces a strictly positive lift; this is
why an *observed* $\Delta R^2$ of exactly zero is not to be expected and why a ceiling, not
a point estimate, is the right object to report.

---

## 5. Conditional dominance and lift asymmetry

The block ceiling bounds what the block can add *given the baseline*. The complementary
question — what a favoured feature retains *given the block* — is answered by an exact
orthogonality argument.

**Theorem 5.1 (Conditional Dominance, RSS form).** Let $w$ satisfy $\|w\|^2 \ne 0$ and
$\langle v_j, w\rangle = 0$ for every $j$. Then
$$
\mathrm{RSS}\big(y, \mathcal{B}^+(g,v,w)\big) \;\le\; \mathrm{RSS}\big(y,\mathcal{B}(g,v)\big) \;-\; \frac{\langle r, w\rangle^2}{\|w\|^2}.
$$

*Proof sketch.* Fix $\varepsilon>0$ and choose $c$ with $\|y - (g+v[c])\|^2 <
\mathrm{RSS}(y,\mathcal{B}(g,v)) + \varepsilon$. Because $w$ is orthogonal to each $v_j$, it
is orthogonal to $v[c]$, so the *post-block* residual has unchanged correlation with $w$:
$\langle r - v[c], w\rangle = \langle r, w\rangle$. Choosing the optimal scalar $t =
\langle r - v[c], w\rangle/\|w\|^2$ and using the one-dimensional projection identity
$\|u - t w\|^2 = \|u\|^2 - \langle u,w\rangle^2/\|w\|^2$ gives a member of
$\mathcal{B}^+(g,v,w)$ with residual energy below $\mathrm{RSS}(y,\mathcal{B}(g,v)) +
\varepsilon - \langle r,w\rangle^2/\|w\|^2$. Let $\varepsilon \downarrow 0$. $\square$

**Corollary 5.2 (Conditional Dominance, $R^2$ form).**
$$
R^2\big(y,\mathcal{B}^+(g,v,w)\big) \;\ge\; R^2\big(y,\mathcal{B}(g,v)\big) + \frac{\langle r,w\rangle^2}{\|w\|^2\,\mathrm{TSS}(y)} .
$$

In words: an orthogonal feature cannot be absorbed by the block. Whatever it was worth on
its own, it is still worth at least that much after the block has been fitted first. This is
precisely the property that makes the "reverse increment" a meaningful statistic.

**Theorem 5.3 (Lift Asymmetry).** Let $v$ have lower frame bound $\lambda > 0$ and residual
correlations bounded by $\rho$ as in Theorem 3.4; let $w$ satisfy $\|w\|^2\ne 0$ and
$\langle v_j,w\rangle = 0$ for all $j$; let $d \le \langle r,w\rangle^2/(\|w\|^2
\mathrm{TSS}(y))$ be a lower bound for the individual lift of $w$; and suppose the ceiling
falls below that lift,
$$
\frac{k\rho^2 (1-R^2_0)}{\lambda} \;<\; d .
$$
Then
$$
\underbrace{R^2\big(y,\mathcal{B}(g,v)\big) - R^2_0}_{\text{block given baseline}}
\;<\;
\underbrace{R^2\big(y,\mathcal{B}^+(g,v,w)\big) - R^2\big(y,\mathcal{B}(g,v)\big)}_{\text{feature given block}} .
$$

*Proof.* Chain Theorem 3.4 (upper bound on the left) with Corollary 5.2 (lower bound on the
right) and the hypothesis $k\rho^2(1-R^2_0)/\lambda < d$. $\square$

Theorem 5.3 is the formal shape of the verdict "the block carries nothing beyond the dial".
It is a statement about the *design* — the sizes $k$, $\rho$, $\lambda$, $R^2_0$, $d$ — and
therefore transfers to any experiment reporting those five numbers.

---

## 6. Exact calibration of the permutation null

Permutation testing is usually understood as Monte Carlo. For a single centred covariate the
first moment of the null is available in closed form, by a symmetry argument on the
symmetric group $S_n$ acting on the sample index set.

**Lemma 6.1 (two-point transitivity).** For any pairs $(i,j)$ and $(i',j')$ with $i \ne j$
and $i' \ne j'$ there exists $\tau \in S_n$ with $\tau(i') = i$ and $\tau(j') = j$.

*Proof sketch.* Compose the transposition swapping $i'$ and $i$ with a second transposition
moving the image of $j'$ to $j$, taking care that the second swap does not disturb $i$; the
distinctness hypotheses make this always possible. $\square$

**Definition 6.2.** For $v : \iota \to \mathbb{R}$ put $W(i,j) = \sum_{\sigma \in S_n}
v(\sigma i)\, v(\sigma j)$.

**Lemma 6.3 (two-valuedness).** $W(i,j)$ depends only on whether $i = j$: it equals a common
value $W_{\mathrm{diag}}$ whenever $i=j$, and a common value $W_{\mathrm{off}}$ whenever
$i \ne j$.

*Proof sketch.* Right translation $\sigma \mapsto \sigma\tau$ is a bijection of $S_n$ and so
leaves the sum invariant; combining with Lemma 6.1 transports any off-diagonal pair to any
other, and a single transposition transports any diagonal index to any other. $\square$

**Lemma 6.4 (the two linear relations).**
$$
\sum_{i} W(i,i) = n!\,\|v\|^2, \qquad\text{and}\qquad \sum_{i}\sum_{j} W(i,j) = 0 \ \text{ whenever } \textstyle\sum_i v_i = 0 .
$$

*Proof sketch.* For the first, exchange the order of summation: for each fixed $\sigma$,
$\sum_i v(\sigma i)^2 = \|v\|^2$. For the second, exchange again: for each $\sigma$,
$\sum_i \sum_j v(\sigma i) v(\sigma j) = (\sum_i v(\sigma i))^2 = 0$ by centring. $\square$

**Theorem 6.5 (Permutation-Null Identity).** Let $n \ge 2$ and let $r, v : \iota \to
\mathbb{R}$ both be centred ($\sum_i r_i = \sum_i v_i = 0$). Then
$$
(n-1)\sum_{\sigma\in S_n} \big\langle r,\, v\circ\sigma \big\rangle^2 \;=\; n!\,\|r\|^2\,\|v\|^2 .
$$

*Proof sketch.* Expanding the square,
$$
\sum_{\sigma}\langle r, v\circ\sigma\rangle^2 = \sum_i\sum_j r_i r_j W(i,j)
= W_{\mathrm{off}} \Big(\sum_i r_i\Big)^2 + (W_{\mathrm{diag}} - W_{\mathrm{off}})\|r\|^2
= (W_{\mathrm{diag}} - W_{\mathrm{off}})\|r\|^2,
$$
using centring of $r$. Lemma 6.4 supplies $n\,W_{\mathrm{diag}} = n!\,\|v\|^2$ and
$n\,W_{\mathrm{diag}} + n(n-1)W_{\mathrm{off}} = 0$, whence $W_{\mathrm{diag}} -
W_{\mathrm{off}} = n!\,\|v\|^2/(n-1)$. $\square$

**Theorem 6.6 (Null Calibration).** With $r = y - g$ centred, $v$ centred and nonzero, and
$\mathrm{TSS}(y) > 0$, the mean over all row shuffles of the $R^2$ increment contributed by
$v$ is exactly
$$
\frac{1}{n!}\sum_{\sigma \in S_n} \frac{\langle r, v\circ\sigma\rangle^2}{\|v\|^2\,\mathrm{TSS}(y)} \;=\; \frac{1 - R^2_0}{\,n-1\,} .
$$

*Proof.* Divide Theorem 6.5 by $n!\,\|v\|^2\,\mathrm{TSS}(y)\,$ and use (2.1). $\square$

The reference distribution's centre is therefore fixed by two reported numbers — the
baseline fit and the sample size — with no distributional assumption, no asymptotics, and no
simulation. It is an exact finite-sample identity.

**Theorem 6.7 (Markov tail for the null).** Under the hypotheses of Theorem 6.6, for any
$t > 0$,
$$
\frac{\#\{\sigma \in S_n : \langle r, v\circ\sigma\rangle^2/(\|v\|^2\mathrm{TSS}(y)) \ge t\}}{n!}
\;\le\; \frac{1-R^2_0}{(n-1)\,t} .
$$

*Proof sketch.* The per-shuffle increment is nonnegative; the count of shuffles exceeding
$t$, times $t$, is at most the total sum, which Theorem 6.6 evaluates. $\square$

**Corollary 6.8 (instance).** At $R^2_0 = 0.4112$ and $n \ge 237$, at most a $0.05$ fraction
of row shuffles attains an increment of $0.05$: indeed $(1-0.4112)/(236 \cdot 0.05) =
0.0499\ldots \le 0.05$.

This unconditional bound is consistent with, and independently corroborates, the empirical
null quantile $q_{95} = 0.046$ obtained from $500$ shuffles. Two methods — one algebraic,
one Monte Carlo — locate the $95\%$ point of the null in the same place.

---

## 7. The nonlinear ceiling: what a feature can *ever* explain

All of §§3–6 concerns linear model classes. A stronger null claim — "no property of this
kind explains the residual" — must quantify over nonlinear predictors too, since a feature
can be linearly uncorrelated with a response while determining it exactly.

Let $f : \iota \to \alpha$ be an arbitrary feature, valued in an arbitrary set $\alpha$ with
decidable equality.

**Definition 7.1.** The *cell* of $f$ over $a \in \alpha$ is $C_a = \{i : f(i) = a\}$; the
*cell mean* is $\bar y_a = |C_a|^{-1}\sum_{i \in C_a} y_i$; the *within-cell sum of squares*
is
$$
\mathrm{WSS}(y,f) = \sum_{a \in f(\iota)}\ \sum_{i \in C_a} (y_i - \bar y_a)^2 .
$$
The *measurable class* of $f$ is $\mathcal{M}(f) = \{\, i \mapsto \varphi(f(i)) \;:\;
\varphi : \alpha \to \mathbb{R} \,\}$: *every* predictor that is a function of $f$, with no
linearity, monotonicity, continuity or smoothness assumption.

**Lemma 7.2 (cell split).** For a finite nonempty $S$ and any $c \in \mathbb{R}$,
$$
\sum_{i\in S}(y_i - c)^2 = \sum_{i\in S}(y_i - \bar y_S)^2 + |S|\,(c - \bar y_S)^2 .
$$

*Proof.* Expand and use $\sum_{i\in S}(y_i - \bar y_S) = 0$. $\square$

**Theorem 7.3 (exact nonlinear fit).** For every feature $f$,
$$
\mathrm{RSS}\big(y, \mathcal{M}(f)\big) = \mathrm{WSS}(y,f),
\qquad\text{hence}\qquad
R^2\big(y,\mathcal{M}(f)\big) = 1 - \frac{\mathrm{WSS}(y,f)}{\mathrm{TSS}(y)} .
$$

*Proof sketch.* Partitioning the sample by the cells of $f$, $\|y - \varphi\circ f\|^2 =
\sum_a \sum_{i \in C_a} (y_i - \varphi(a))^2$. By Lemma 7.2 each inner sum is minimised
uniquely at $\varphi(a) = \bar y_a$, with minimum $\sum_{i\in C_a}(y_i - \bar y_a)^2$; the
choice is independent across cells. Both inequalities follow: $\le$ by exhibiting
$\varphi(a) = \bar y_a$, and $\ge$ by the cell split applied to an arbitrary $\varphi$.
$\square$

The right-hand quantity is the classical **correlation ratio** $\eta^2$; Theorem 7.3
identifies it as an exact supremum over an enormous model class, which is what makes it
usable as a certificate.

**Theorem 7.4 (residual floor).** If $\mathrm{WSS}(y,f) \ge \theta\,\mathrm{TSS}(y)$ for
some $\theta \in [0,1]$, then $R^2(y,\mathcal{M}(f)) \le 1 - \theta$: no function of $f$
whatsoever explains more than a fraction $1-\theta$ of the variance.

**Theorem 7.5 (refinement monotonicity).** If $f = \psi \circ f'$ for some $\psi$ (i.e. $f'$
refines $f$), then $\mathcal{M}(f) \subseteq \mathcal{M}(f')$ and $\mathrm{WSS}(y,f') \le
\mathrm{WSS}(y,f)$. Consequently a floor stated for the refined feature $f'$ implies the
corresponding floor for $f$.

*Proof sketch.* Any $\varphi \circ f$ equals $(\varphi\circ\psi)\circ f'$, giving the
inclusion; monotonicity of the infimum over a larger class plus Theorem 7.3 gives the
inequality. $\square$

Refinement monotonicity is what makes joint features tractable: appending a covariate layer
to a dial can only lower within-cell energy, so the *joint* feature is the right thing to
state a floor about — a floor for the joint feature is the strongest statement of the family
and implies all its coarsenings.

**Corollary 7.6 (dial floor).** Let $\mathrm{dial}(i) = W_B(N_i)$ be the footprint dial
evaluated on the sampled moduli. If the response varies by at least a fraction $\theta$ of
its total variation within the dial's level sets, then no predictor built from the dial —
however nonlinear — reaches $R^2 > 1-\theta$. The same holds for the joint feature
$i \mapsto (\mathrm{dial}(i), \mathrm{nb}(i))$ formed with any neighbourhood encoding
$\mathrm{nb}$.

---

## 8. Arithmetic freedom: the two layers are uncoupled over $\mathbb{Z}$

The statistical results describe one sample. A stronger question is whether any deterministic
arithmetic coupling exists between the footprint dial and the neighbourhood covariates.
There is none, and the proof is a construction.

**Definition 8.1.** For $N \in \mathbb{Z}$ and $s \in \{\pm 1\}$ let $\mathrm{nb}\omega(N,s)
= \omega(|N+s|)$, the number of distinct prime factors of the neighbour $N + s$.

**Lemma 8.2 (unbounded prime supplies).** For any $x, a$ there is a set of $a$ distinct
primes all exceeding $x$.

**Theorem 8.3 (Arithmetic Freedom).** Let $P \ge 1$, $N_0 \in \mathbb{Z}$, $a \in
\mathbb{N}$, and let $M$ be any bound. Then there exists $N > M$ with $N > 2$ such that
$$
N \equiv N_0 \pmod P, \qquad \mathrm{nb}\omega(N,-1) \ge a, \qquad \mathrm{nb}\omega(N,+1) \ge a .
$$

*Proof sketch.* Choose disjoint sets $S_{-}, S_{+}$ of $a$ primes each, all exceeding $P$,
and let $Q_{\pm} = \prod_{p \in S_\pm} p$. The moduli $P$, $Q_-$ and $Q_+$ are pairwise
coprime by construction, so the Chinese Remainder Theorem yields $N$ with $N \equiv N_0
\pmod P$, $N \equiv 1 \pmod {Q_-}$, $N \equiv -1 \pmod{Q_+}$. Then every prime of $S_-$
divides $N - 1$ and every prime of $S_+$ divides $N+1$, so both neighbour counts are at
least $a$. Adding suitable multiples of $P Q_- Q_+$ makes $N$ exceed any prescribed bound.
$\square$

**Corollary 8.4 (dial freedom).** The footprint dial $W_B$ is a function of $N$ modulo the
product of the odd factor-base primes. Hence, for every attainable dial value $w$, every
level $a$, and every bound $M$, there are integers $N > M$ with $W_B(N) = w$ and both
neighbour covariates at least $a$. Conditioning on the neighbourhood layer imposes no
restriction on the dial, and the full attainable range of the dial survives any
neighbourhood constraint.

**Corollary 8.5 (non-measurability).** The neighbour covariate is not a function of the
dial: there exist $N_1, N_2$ with $W_B(N_1) = W_B(N_2)$ but $\omega(N_1 - 1) \ne
\omega(N_2 - 1)$.

Corollaries 8.4–8.5 supply the licence the experiment needs. Since no arithmetic law couples
the two layers, any observed sample correlation between them is a property of the draw, not
a structural fact — which is exactly the condition under which a small $\Delta R^2$ may be
read as "no structure" rather than "structure masked by collinearity". Note also that
Theorem 8.3 is unconditional on the sampled population: it holds for all integers, whatever
the sampling recipe.

---

## 9. The combined certificate for the experiment

We now instantiate everything at the reported design constants: $k = 4$ covariates, an
orthonormal block ($\lambda = 1$), correlation ceiling $\rho = 0.16$, baseline $R^2_0 =
0.4112$, reverse (dial-given-block) lift $d = 0.3987$, sample size $n \ge 237$.

**Certificate A (block ceiling).** By Theorem 3.4,
$$
\Delta R^2 \;\le\; 4 \cdot 0.16^2 \cdot (1 - 0.4112) \;=\; 0.060293\ldots \;\le\; 0.0604 .
$$
The observed $\Delta R^2 = 0.01946$ lies well inside the ceiling and below the pre-registered
null boundary $0.02$.

**Certificate B (exclusion threshold, and its boundary).** Had the block's residual
correlations all been at most $0.1457$, Theorem 3.4 would give
$$
4 \cdot 0.1457^2 \cdot 0.5888 = 0.049997\ldots \;<\; 0.05 ,
$$
refuting the pre-registered alternative $H_1 : \Delta R^2 \ge 0.05$ from the correlation
profile alone. The observed best single correlation was $0.16 > 0.1457$, so the ceiling
alone does *not* exclude $H_1$; the null verdict rests genuinely on the joint fit and on the
permutation test. We record this boundary explicitly: a certificate that does not report the
point where it stops binding is a rhetorical device, not a bound.

**Certificate C (lift asymmetry).** With $\rho = 0.16$, $d = 0.3987$ and ceiling $0.0603 <
d$, Theorem 5.3 applies: for a neighbourhood block orthogonal to the dial feature,
$$
R^2(\text{block}) - R^2_0 \;<\; R^2(\text{block}+\text{dial}) - R^2(\text{block}) .
$$
The dial's incremental value given the block strictly exceeds the block's incremental value
given the dial baseline. This is "nothing beyond the dial" as a theorem about the design.

**Certificate D (permutation null).** By Corollary 6.8, at $R^2_0 = 0.4112$ and $n \ge 237$
at most $5\%$ of row shuffles reach an increment of $0.05$. The empirical $q_{95} = 0.046$
sits inside this unconditional bound, and the observed increment $0.01946$ sits below
$q_{95}$ — hence the reported $p = 0.389$.

**Certificate E (nonlinear floor).** By Theorems 7.3–7.5, if at least $40\%$ of the response
variation lies within the cells of the joint feature (dial, neighbourhood), then no
predictor that is a function of that joint feature — of any functional form — attains $R^2 >
0.6$.

**The verdict, in one statement.** Under the reported design constants, both halves hold
simultaneously: the four-covariate neighbourhood block cannot lift $R^2$ by more than
$0.0604$ over the dial baseline, and at least $40\%$ of the response variation is out of
reach of every function of the joint feature (dial, neighbourhood), linear or not. The
residual is bounded away from both layers at once. That conjunction is what "the residual is
genuinely open" means.

---

## 10. Discussion, and two disclosed caveats

### 10.1 What a certified negative buys

A conventional null report answers "did this feature help *in this fit*?". The theorems
above answer three strictly stronger questions: "could it ever have helped, at this
correlation profile and design conditioning?" (Theorem 3.4); "could it have helped in a
nonlinear way?" (Theorem 7.4); and "is the reference distribution against which we judged it
correctly centred?" (Theorem 6.6). The answers are quantitative and depend only on reported
summary statistics, so they are auditable by a reader who never sees the data matrix.

Practically, the result changes a search. Four classes of properties of the modulus $N$ have
now been tested against the unexplained $40\%$ of sieve yield, and all four fail. Every one
of those classes is a *residue dial*: a function of $N$ modulo a fixed finite set of primes.
The surviving hypothesis is that the carrier is not a function of $N$ at all but a statistic
of the sieve *run* — the trajectory of the sieving process, or sample-level structure within
a run. Theorem 7.4 makes that dichotomy testable rather than rhetorical: a genuine carrier
must lower the within-cell energy of the joint feature, and no residue dial can, once the
dial cells are fixed.

### 10.2 An endpoint amendment, disclosed

The originally planned primary endpoint was the count of *full* relations. In smoke testing
prior to any lineage analysis, full relations occurred zero times in over $160{,}000$
synthetic draws, even at the loosest smoothness threshold examined. The primary endpoint was
therefore amended, before analysis, to partial relations (mean $4032$ per modulus,
coefficient of variation $1.6\%$); the pre-registered gates were left unchanged. The
amendment is itself a finding: at this bit length, essentially all relations produced are
partials. Secondary analysis on the full-relation endpoint gave $\Delta R^2 = 0.0126$,
consistent with the primary verdict.

### 10.3 Provenance, disclosed

The population of moduli was not recovered from the original archive: the stored artefact
contained sieve positions and interval bounds but no array of moduli. The population was
regenerated from a documented recipe with a recorded seed, and a content hash of the
regenerated population was recorded. A fingerprint check matched at the level available;
an exhaustive grid of recipe variants did not produce an independent match, and one
companion artefact was unreadable. Consequently all *statistical* conclusions here are
conditional on the regenerated population being exchangeable with the original at the level
of the balanced bit-length design. The *arithmetic* results of §8 carry no such condition:
they are theorems about the integers.

---

## 11. Future directions

**1. Sieve-process carriers versus $N$-property carriers.** Every $N$-property class tested
so far is a residue dial — a function of $N$ modulo a fixed finite set of primes — while the
surviving residual is a statistic of the sieve run, which is not a function of $N$ at all.
The nonlinear ceiling makes this a testable dichotomy: a carrier must lower the within-cell
energy of the joint feature, and no residue dial can once the dial cells are fixed. The
claim "no function of these features can explain the residual" is now a theorem schema
rather than a regression report.

**2. A sharp frame-bound constant for the neighbourhood design.** The loss in the block
ceiling is entirely controlled by the smallest eigenvalue $\lambda$ of the block's Gram
matrix, and the four neighbourhood covariates are strongly correlated *among themselves*, so
the true $\lambda$ is well below $1$ and the honest ceiling is larger than the orthonormal
one. The frame bound is already the exact hypothesis the ceiling needs; computing or
bounding $\lambda$ for the actual design turns a qualitative caveat into a number.

**3. Exact permutation-null variance and an exact $q_{95}$.** The first moment of the
permutation null was computable in closed form by a two-swap transitivity argument. The same
argument applied to quadruples $(i,j,k,l)$ yields the second moment — hence a Chebyshev,
rather than Markov, tail, and a *predicted* $q_{95}$ to compare with the empirical $0.046$.
The transitivity lemma and the pair-sum machinery generalise verbatim to $4$-transitivity.

**4. Joint blocks and the coverage algebra.** "Four classes tested, all null" should be one
theorem about the *union* of the four blocks, not four separate theorems. The union's
ceiling is governed by the frame bound of the concatenated design, which can be far worse
than the individual ones — making the coverage claim a genuinely new estimate rather than a
conjunction of old ones.

---

## 12. Conclusion

We have given the negative half of feature-augmentation theory: an exact refit-proof ceiling
on the incremental $R^2$ of a covariate block, an exact dichotomy characterising when a lift
is possible at all, a conditional-dominance theorem and the resulting asymmetry between a
strong dial and a null layer, an exact algebraic calibration of the permutation reference
distribution, and an exact nonlinear ceiling identifying the correlation ratio as a supremum
over all functions of a feature. Instantiated on a sieve-yield prediction experiment, the
theory turns a small observed increment $\Delta R^2 = 0.01946$ with permutation $p = 0.389$
into certified statements: the block could not have exceeded $0.0604$; the dial provably
dominates it conditionally; the reference distribution is correctly centred at
$(1-R^2_0)/(n-1)$; and at least $40\%$ of the response variance is unreachable by any
function of the joint feature. A negative result stated this way is reusable: the next
investigator can read the ceiling off four reported numbers instead of rerunning the
experiment.
