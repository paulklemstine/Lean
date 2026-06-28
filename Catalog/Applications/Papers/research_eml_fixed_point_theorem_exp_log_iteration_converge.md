# The Sharp Asymptotic Convergence Rate of the EML exp-log Iteration

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (dynamical systems, fixed-point iteration)

## Abstract

We study the *EML single operator* $f(x) = e^{a}\log(b x + c)$, a squeeze-and-stretch
building block combining logarithmic compression with exponential scaling, and the
dynamics of its Picard iteration $x_{n+1} = f(x_n)$. On a closed interval that $f$ maps
into itself and on which $|f'| \le \rho < 1$, the iteration is a contraction and converges
to a unique fixed point $x^\*$ with an *a priori* geometric error bound
$|x_n - x^\*| \le |x_1 - x_0|\,\rho^n/(1-\rho)$. The interval constant $\rho$, however,
is only a worst-case bound. Our central contribution is the *sharp local rate*: for $b>0$
and any non-degenerate start $x_0 \ne x^\*$, the ratio of consecutive errors converges
exactly to the derivative magnitude at the fixed point,
$$\frac{|x_{n+1} - x^\*|}{|x_n - x^\*|} \longrightarrow |f'(x^\*)| = \left|\frac{e^{a}b}{b x^\* + c}\right| \le \rho < 1.$$
This pins the iteration's Q-linear asymptotic ratio to the local derivative, strictly
sharpening the interval-wide a priori rate. The argument is a composition of three
ingredients: (i) soft metric convergence of the Picard sequence; (ii) the analytic
derivative of $f$ at $x^\*$ via the equivalence between differentiability and convergence
of difference quotients; and (iii) injectivity of $f$ on the invariant interval (a
consequence of strict monotonicity for $b>0$), which guarantees the iterates never land on
$x^\*$ and so keep the error ratio well-defined. We give numerical demonstrations and
discuss consequences: rate monotonicity in the shift parameter $c$, smooth dependence of
$x^\*$ on the scaling parameter $a$, and acceleration prospects.

## 1. Introduction

Fixed-point iteration is the workhorse of constructive mathematics: to solve $x = f(x)$,
start somewhere and iterate. The Banach contraction principle guarantees that if $f$
shrinks distances by a uniform factor $\rho < 1$ on a complete invariant set, then the
iteration converges geometrically to a unique fixed point. The associated *a priori* error
bound $|x_n - x^\*| \le |x_1 - x_0|\,\rho^n/(1-\rho)$ is one of the most quoted estimates in
numerical analysis.

Yet that bound uses a *single* constant $\rho$ valid over the whole invariant set. In
practice the iterates eventually concentrate near $x^\*$, where the relevant contraction
factor is not the global worst case but the *local* derivative magnitude $|f'(x^\*)|$. For
a smooth contraction the latter is generically strictly smaller than the interval constant,
so the a priori bound systematically overstates the asymptotic effort. The honest,
sharp description of the long-run dynamics is *Q-linear convergence with asymptotic ratio
$|f'(x^\*)|$*.

We carry out this sharpening for the EML operator
$$f(x) = e^{a}\log(b x + c),$$
a "exp-minus-log" unit of interest as an analytically tame alternative to generic
activation functions: where most nonlinear units have ill-behaved feedback dynamics, the
EML map has a *certified* convergent iteration. Our results upgrade the certificate from
"converges at rate at most $\rho$" to "converges at asymptotic rate exactly $|f'(x^\*)|$."

The distinction between the two statements is not merely cosmetic. The interval constant
$\rho$ is the supremum of $|f'|$ over the whole invariant set; it governs the *transient*
phase, when the iterate may still be far from $x^\*$ and the map's steepness is largest. The
local rate $|f'(x^\*)|$ governs the *asymptotic* phase, which is the regime that determines
how many iterations are ultimately needed to reach a prescribed accuracy. For the EML
operator the derivative $f'(x) = e^a b/(bx+c)$ is monotonically decreasing in $x$ (for
$b>0$), so its supremum over the interval is attained at the left endpoint and is strictly
larger than its value at the interior fixed point. Consequently the asymptotic effort is
strictly less than the a priori bound predicts, and quantifying the gap requires the local
argument developed here.

### 1.1 Method overview

The sharp rate is obtained by feeding the Picard sequence into the analytic
characterization of the derivative. Differentiability of $f$ at $x^\*$ is *equivalent* to
convergence of the difference quotient (slope) $\frac{f(y)-f(x^\*)}{y-x^\*}$ to $f'(x^\*)$ as
$y \to x^\*$ through values $\ne x^\*$. The Picard iterates supply exactly such a sequence of
test points $y = x_n$: they converge to $x^\*$ (catalog convergence) and stay distinct from
it (injectivity). The slope evaluated along this sequence is literally the consecutive-error
ratio, because $f(x_n) = x_{n+1}$ and $f(x^\*) = x^\*$. The limit is therefore $f'(x^\*)$, and
taking absolute values gives the magnitude. The three inputs — convergence, injectivity, and
the analytic derivative — are individually standard; their composition is what yields the
conjecture's literal rate, absent from the interval-constant a priori bound.

### 1.2 Contributions

1. **Strict monotonicity and injectivity** of $f$ on the invariant interval for $b > 0$.
2. **Persistence of non-degeneracy**: a start $x_0 \ne x^\*$ produces iterates $x_n \ne x^\*$
   for all $n$.
3. **The sharp asymptotic rate**: the consecutive-error ratio tends to $|f'(x^\*)|$.
4. **Comparison and contraction**: $|f'(x^\*)| \le \rho < 1$, so the local rate is a genuine
   contraction ratio never worse than the catalog's interval bound.

All statements have been formally verified; this paper presents the mathematics and proof
sketches.

## 2. Definitions and standing data

**Definition 2.1 (EML operator).** For parameters $a, b, c \in \mathbb{R}$ define
$$f = f_{a,b,c} : x \mapsto e^{a}\log(b x + c),$$
defined wherever $b x + c > 0$.

**Definition 2.2 (Picard iteration).** For an initial point $x_0$, the *iteration sequence*
is
$$x_0,\quad x_{n+1} = f(x_n)\ (n \ge 0).$$

**Definition 2.3 (EML contraction data).** A tuple $D = (a, b, c, \mathrm{lo}, \mathrm{hi}, \rho)$
is *contraction data* for $f$ if it satisfies:
- $\mathrm{lo} < \mathrm{hi}$ (a nondegenerate interval $I = [\mathrm{lo}, \mathrm{hi}]$);
- $0 \le \rho < 1$ (a contraction ratio);
- *positivity of the log argument*: $b x + c > 0$ for all $x \in I$;
- *invariance*: $f(I) \subseteq I$;
- *derivative bound*: $\left|\dfrac{e^{a} b}{b x + c}\right| \le \rho$ for all $x \in I$.

Such data is inhabited (concrete instances exist, e.g. $a$ small, $b = 1$, $c = 2$, on a
bracket around the fixed point).

**Lemma 2.4 (Derivative formula).** Wherever $b x + c > 0$,
$$f'(x) = \frac{e^{a} b}{b x + c}.$$
*Proof.* The map $x \mapsto bx + c$ is affine with derivative $b$; composing with $\log$
(whose derivative is the reciprocal) gives, by the chain rule,
$\frac{d}{dx}\log(bx+c) = \frac{b}{bx+c}$; the constant factor $e^a$ scales through. The
positivity hypothesis $bx+c>0$ is precisely what places the argument in the domain of
$\log$ where this derivative is valid. $\square$

**Remark 2.4a (Qualitative shape of $f'$).** For $b > 0$ the derivative
$f'(x) = e^a b/(bx+c)$ is positive and strictly decreasing in $x$ on $I$. Positivity makes
$f$ increasing (Section 4); monotone decrease makes the supremum of $|f'|$ over $I$ occur at
the left endpoint $\mathrm{lo}$, so the interval constant $\rho$ can be taken as
$f'(\mathrm{lo}) = e^a b/(b\,\mathrm{lo}+c)$, which strictly exceeds the interior value
$f'(x^\*)$. This is the structural source of the gap between the a priori and sharp rates.

**Lemma 2.5 (Fixed-point equation).** If $f(x^\*) = x^\*$ then $x^\* = e^{a}\log(b x^\* + c)$.
*Proof.* Unfold the definition of $f$. $\square$

## 3. The catalog baseline: contraction and a priori rate

We recall the established results on which the sharp rate builds.

**Theorem 3.1 (Lipschitz/contraction bound).** If $|f'| \le \rho$ on the convex interval
$I$ (with the log argument positive there), then for all $x, y \in I$,
$$|f(x) - f(y)| \le \rho\,|x - y|.$$
*Proof sketch.* The mean value inequality on a convex set: a $C^1$ map whose derivative is
bounded in norm by $\rho$ throughout $I$ is $\rho$-Lipschitz on $I$. Formally this is the
standard `norm_image_sub_le_of_norm_hasDerivWithin_le` estimate. $\square$

**Theorem 3.2 (Uniqueness).** Under Definition 2.3, $f$ has at most one fixed point in $I$.
*Proof sketch.* If $x_1, x_2$ are fixed points, Theorem 3.1 gives
$|x_1 - x_2| = |f(x_1) - f(x_2)| \le \rho |x_1 - x_2|$ with $\rho < 1$, forcing
$|x_1 - x_2| = 0$. $\square$

**Theorem 3.3 (Convergence).** For $x_0 \in I$ the iteration $(x_n)$ stays in $I$, is
Cauchy, and converges to a limit $x^\* \in I$ with $f(x^\*) = x^\*$.
*Proof sketch.* Invariance keeps the iterates in $I$. The per-step bound
$|x_{n+1} - x_n| \le \rho^n |x_1 - x_0|$ (induction via Theorem 3.1) makes the sequence
Cauchy by comparison with a geometric series; completeness of $\mathbb{R}$ gives a limit,
and continuity of $f$ promotes the limit to a fixed point; closedness of $I$ keeps it in
$I$. $\square$

**Theorem 3.4 (A priori geometric error bound).** If $(x_n) \to x^\*$ then for all $n$,
$$|x_n - x^\*| \le |x_1 - x_0|\,\frac{\rho^n}{1 - \rho}.$$
*Proof sketch.* The per-step contraction $\mathrm{dist}(x_n, x_{n+1}) \le |x_1 - x_0|\rho^n$
feeds the standard geometric-tail estimate `dist_le_of_le_geometric_of_tendsto`. $\square$

The constant in Theorem 3.4 is the *interval-wide* $\rho$. The remainder of the paper shows
the true asymptotic rate is smaller and pinpoints it.

### 3.1 Existence of contraction data

The hypotheses bundled in Definition 2.3 are not vacuous, and it is worth recording how one
constructs them for a given EML operator, since the whole theory is empty if no contraction
data exists. The recipe is a standard bracketing argument.

Fix $a > 0$, $b = 1$, $c > 0$. Consider $g(x) = f(x) - x = e^a\log(x+c) - x$. One seeks an
interval $I = [\mathrm{lo}, \mathrm{hi}]$ with $x + c > 0$, $f(I) \subseteq I$, and a
bound $\rho < 1$ on $|f'|$ over $I$. Three observations make this routine:

1. *Positivity.* Choosing $\mathrm{lo} > -c$ keeps $x + c > 0$, so $\log$ and $f'$ are
   defined throughout $I$.
2. *Invariance.* Since $f$ is increasing (Theorem 4.1), $f(I) \subseteq I$ reduces to the
   two endpoint conditions $f(\mathrm{lo}) \ge \mathrm{lo}$ and $f(\mathrm{hi}) \le
   \mathrm{hi}$, i.e. a sign change of $g$ bracketing a fixed point. The intermediate value
   theorem then locates $x^\* \in I$.
3. *Contraction.* The derivative bound $\rho = f'(\mathrm{lo}) = e^a/(\mathrm{lo}+c) < 1$
   holds as soon as $\mathrm{lo} + c > e^a$, which is arrangeable once $c$ is not too small
   relative to $e^a$. The admissible-parameter dichotomy (roughly $c \ge e^a(1-a)$) records
   exactly when such an interval exists.

A concrete instance is $a = 0.2$, $b = 1$, $c = 2$, $I = [1, 3]$: there $f(1) = e^{0.2}\log 3
\approx 1.34 \in [1,3]$, $f(3) = e^{0.2}\log 5 \approx 1.97 \in [1,3]$, and
$\rho = e^{0.2}/3 \approx 0.407 < 1$. This is the running example of Section 8.

## 4. Strict monotonicity and injectivity

**Theorem 4.1 (Strict monotonicity for $b>0$).** If $b > 0$ and $b x + c > 0$ on
$I = [\mathrm{lo}, \mathrm{hi}]$, then $f$ is strictly increasing on $I$.

*Proof sketch.* For $x < y$ in $I$ we have $0 < b x + c < b y + c$, so
$\log(bx+c) < \log(by+c)$ by strict monotonicity of $\log$ on $(0,\infty)$; multiplying by
the positive constant $e^a$ preserves the strict inequality. (Equivalently, the derivative
$f'(x) = e^a b/(bx+c)$ is strictly positive on $I$.) $\square$
*(Lean: `EMLIterOp.strictMonoOn_of_b_pos`.)*

**Corollary 4.2 (Injectivity).** Under the hypotheses of Theorem 4.1, $f$ is injective on
$I$.
*Proof.* A strictly monotone function is injective. $\square$
*(Lean: `EMLIterOp.injOn_of_b_pos`.)*

The sign condition $b > 0$ is exactly what makes the asymptotic-rate argument work: it
guarantees both that the local rate $|f'(x^\*)|$ is positive (a non-vacuous limit) and that
the iterates never collide with $x^\*$ (Section 5).

## 5. Persistence of non-degeneracy

**Theorem 5.1 (Iterates avoid the fixed point).** Let $D$ be contraction data with $b > 0$.
Let $x_0 \in I$, let $x^\* \in I$ be the fixed point, and suppose $x_0 \ne x^\*$. Then for
all $n$,
$$x_n \ne x^\*.$$

*Proof sketch.* Induction on $n$. The base case is the hypothesis $x_0 \ne x^\*$. For the
step, suppose $x_n \ne x^\*$ but, for contradiction, $x_{n+1} = x^\*$. Since $x^\*$ is a
fixed point, $f(x^\*) = x^\* = x_{n+1} = f(x_n)$. Both $x_n$ and $x^\*$ lie in $I$ (the
iterates by invariance), so injectivity (Corollary 4.2) gives $x_n = x^\*$, contradicting
the inductive hypothesis. $\square$
*(Lean: `EMLIterOp.iterSeq_ne_fixedPoint`.)*

This is the only "non-soft" input the sharp rate needs beyond the catalog convergence and
the analytic derivative: it keeps every difference quotient $\frac{x_{n+1} - x^\*}{x_n - x^\*}$
genuinely defined (nonzero denominator).

## 6. The sharp asymptotic convergence rate

**Theorem 6.1 (Sharp local rate).** Let $D$ be contraction data with $b > 0$. Let
$x_0 \in I$ with $x_0 \ne x^\*$, let $x^\* \in I$ be the fixed point, and suppose
$(x_n) \to x^\*$. Then
$$\frac{|x_{n+1} - x^\*|}{|x_n - x^\*|} \;\xrightarrow[n\to\infty]{}\; |f'(x^\*)| = \left|\frac{e^{a} b}{b x^\* + c}\right|.$$

*Proof sketch.* The decisive tool is the equivalence
$$\mathrm{HasDerivAt}\,f\,L\,x^\* \iff \text{slope}_{x^\*} f \to L \ \text{along}\ \mathcal{N}^{\times}(x^\*),$$
where $\text{slope}_{x^\*} f(y) = \dfrac{f(y) - f(x^\*)}{y - x^\*}$ and
$\mathcal{N}^{\times}(x^\*)$ is the *punctured* neighborhood filter at $x^\*$ (the
"`hasDerivAt_iff_tendsto_slope`" characterization). We assemble three facts.

1. *Analytic derivative.* By Lemma 2.4, $f$ has derivative $L = e^a b/(bx^\*+c)$ at $x^\*$
   (the log argument is positive there). Hence $\text{slope}_{x^\*} f \to L$ along
   $\mathcal{N}^{\times}(x^\*)$.

2. *The sequence enters the punctured neighborhood.* The Picard sequence converges to
   $x^\*$ (hypothesis), so $x_n - x^\* \to 0$; and by Theorem 5.1 each $x_n \ne x^\*$, i.e.
   $x_n - x^\* \ne 0$. Therefore the map $n \mapsto x_n - x^\*$ tends to $0$ *within*
   $\{0\}^{c}$, i.e. along $\mathcal{N}^{\times}(0)$, which is precisely the condition needed
   to compose with the slope limit at $x^\*$.

3. *Compose and identify the quotient.* Composing the slope limit (1) with the sequence (2)
   yields
   $$\text{slope}_{x^\*} f(x_n) = \frac{f(x_n) - f(x^\*)}{x_n - x^\*} = \frac{x_{n+1} - x^\*}{x_n - x^\*} \longrightarrow L,$$
   using $f(x_n) = x_{n+1}$ and $f(x^\*) = x^\*$. Taking absolute values
   (continuity of $|\cdot|$) gives the stated ratio limit with $|L| = |f'(x^\*)|$. $\square$
*(Lean: `EMLIterOp.iterSeq_sharp_rate`.)*

The proof is a clean composition of soft metric convergence, the analytic value of $f'$ at
$x^\*$, and injectivity — none individually new, but together yielding the conjecture's
literal rate, which the interval-constant a priori bound does not capture.

**Remark 6.2 (Why $x_0 \ne x^\*$ is required).** If $x_0 = x^\*$ the sequence is constant,
every error is $0$, and the ratio is the degenerate $0/0$; the limit $|f'(x^\*)|$ need not
hold. Non-degeneracy is a genuine, natural hypothesis, not a technical cheat.

## 7. The local rate is a genuine contraction ratio

**Theorem 7.1 (Comparison with the interval rate).** For every $x^\* \in I$,
$$|f'(x^\*)| = \left|\frac{e^{a} b}{b x^\* + c}\right| \le \rho.$$
*Proof.* This is exactly the derivative bound in Definition 2.3 applied at $x^\*$. $\square$
*(Lean: `EMLIterOp.sharp_rate_le_interval_rate`.)*

**Corollary 7.2 (Strict contraction at the fixed point).** $|f'(x^\*)| < 1$.
*Proof.* Combine Theorem 7.1 with $\rho < 1$. $\square$
*(Lean: `EMLIterOp.sharp_rate_lt_one`.)*

Thus the asymptotic ratio is positive (for $b>0$), bounded above by the catalog's interval
constant, and strictly below $1$: the iteration is genuinely contractive *at the rate we
computed*, and that rate is at least as good as the a priori promise.

**Proposition 7.3 (Eventual per-step contraction at the local rate).** For every
$r > |f'(x^\*)|$ there is an index $N$ such that for all $n \ge N$,
$$|x_{n+1} - x^\*| \le r\,|x_n - x^\*|.$$
*Proof sketch.* Since the consecutive-error ratio tends to $|f'(x^\*)| < r$ (Theorem 6.1),
the ratio is eventually below $r$; rearranging gives the per-step bound. This is the precise
$O(r^n)$ content for every $r > |f'(x^\*)|$: no rate below the local derivative works
asymptotically, and every rate above it does. $\square$
*(Lean: `EMLIterOp.iterSeq_eventually_step_contraction`.)*

## 8. Numerical demonstration

Take $a = 0.2$, $b = 1$, $c = 2$, so $f(x) = e^{0.2}\log(x+2)$, with invariant interval
$I = [1,3]$. The fixed point is $x^\* = 1.546116\ldots$; the interval constant (the max of
$|f'|$ on $I$, attained at the left endpoint) is $\rho = 0.407134\ldots$; the local rate is
$|f'(x^\*)| = 0.344434\ldots$.

**A priori bound (Theorem 3.4).** Starting at $x_0 = 3$, every measured error stays under
the predicted envelope $|x_1 - x_0|\rho^n/(1-\rho)$, e.g. at $n=6$ the error is
$1.87\times 10^{-3}$ against a bound $7.95\times 10^{-3}$.

**Sharp rate (Theorem 6.1).** The consecutive-error ratios climb monotonically toward the
local derivative:
$$0.2886,\ 0.3255,\ 0.3380,\ 0.3422,\ 0.34367,\ 0.34437,\ \dots \to 0.344434 = |f'(x^\*)|,$$
visibly distinct from and below the interval constant $\rho = 0.407$.

**Uniqueness (Theorem 3.2).** Starts $x_0 \in \{1, 1.5, 2, 2.5, 3\}$ all converge to the
same $x^\* = 1.546116378228\ldots$

**Rate monotonicity in $c$ (Section 9).** Increasing the shift strictly decreases the local
rate: $c = 1.5, 2, 3, 5, 10$ give rates $0.448, 0.344, 0.247, 0.164, 0.093$.

## 9. Consequences and discussion

**Rate monotonicity in the shift $c$.** Increasing $c$ raises both the fixed point $x^\*$
and the denominator $b x^\* + c$, shrinking $|f'(x^\*)| = e^a b/(bx^\*+c)$. The local rate —
now the *certified* asymptotic speed, not merely a derivative bound — is therefore strictly
decreasing in $c$: larger shift, faster convergence. The numerics in Section 8 confirm this.

**Smooth dependence of $x^\*$ on $a$.** Writing $g(a, x) = f(x) - x$, the partial derivative
$\partial_x g = f'(x) - 1$ is nonzero at the fixed point because $|f'(x^\*)| < 1$
(Corollary 7.2). The implicit function theorem then gives $x^\*(a)$ as a $C^1$ function with
$$\frac{dx^\*}{da} = \frac{x^\*}{1 - f'(x^\*)},$$
the first Taylor coefficient of the "power series in $a$." At $a=0$ ($b=1$, $c=2$):
$x^\*(0) = 1.146193\ldots$ and $dx^\*/da = 1.6803\ldots$, matching the numerical fit.

**Acceleration.** Because the error has a clean leading term $x_n - x^\* = A\rho^n(1+o(1))$
with $\rho = f'(x^\*)$ — a refinement of the ratio limit — Aitken $\Delta^2$ / Steffensen
extrapolation should annihilate the leading geometric term and converge with ratio
$o(|f'(x^\*)|^n)$ whenever $f''(x^\*) \ne 0$. This makes the folklore acceleration gain a
provable statement.

**Why EML iteration is well-behaved.** Unlike generic activation functions, the EML map's
feedback dynamics are tame: a unique attracting fixed point, a certified geometric a priori
bound, and an *exact* asymptotic rate equal to the local slope. This is what makes
EML-based iterative algorithms candidates for certified convergence.

**On the two-phase picture of convergence.** The combination of Theorems 3.4 and 6.1 gives
a complete two-phase description of the dynamics. In the *transient* phase the iterate may
be anywhere in $I$ and the only guarantee is the worst-case geometric envelope
$|x_1-x_0|\rho^n/(1-\rho)$ governed by the interval constant. As the iterate enters a small
neighborhood of $x^\*$, the *asymptotic* phase takes over and the per-step contraction
factor relaxes to the local value $|f'(x^\*)| < \rho$. Practically, this means an iteration
tuned by its a priori bound is conservative: it overestimates the iteration count, and the
excess is precisely the ratio $\log\rho / \log|f'(x^\*)|$ of the two rates in the limit. For
the running example $\rho = 0.407$ and $|f'(x^\*)| = 0.344$ differ enough that the true
asymptotic digit-gain per step ($-\log_{10} 0.344 \approx 0.463$) exceeds the a priori
guarantee ($-\log_{10} 0.407 \approx 0.390$) by about $19\%$.

**Relation to the Banach principle.** The catalog results (Theorems 3.1–3.4) are the EML
specialization of the Banach fixed-point theorem and its standard error estimate. The novel
content of this paper, Theorems 6.1 and 7.1, is *local* in nature and lies outside the
classical Banach package, which only ever speaks of the uniform Lipschitz constant. The
sharp rate is the bridge between the global Lipschitz viewpoint and the linearized
(derivative-at-fixed-point) viewpoint familiar from the theory of one-dimensional discrete
dynamical systems, where $|f'(x^\*)|$ is the multiplier classifying $x^\*$ as attracting
($<1$), repelling ($>1$), or neutral ($=1$).

## 10. Future directions

1. **Sharp lower bound.** Conjecture: for $x_0 \ne x^\*$ there is no rate $r < |f'(x^\*)|$
   and constant $C$ with $|x_n - x^\*| \le C r^n$ for all $n$; equivalently
   $\liminf |x_n - x^\*|^{1/n} = |f'(x^\*)|$. Paired with Proposition 7.3 this upgrades
   "$O(\rho^n)$" to "$\Theta(\rho^n)$."
2. **Aitken/Steffensen acceleration** provably beating the linear rate when $f''(x^\*) \ne 0$.
3. **First-order series of $x^\*$ in $a$** on the admissible region, via the implicit
   function theorem using the nonvanishing Jacobian $1 - f'(x^\*) > 0$.
4. **Rate monotonicity in $c$** as a theorem about certified dynamics.
5. **Basin of attraction** equal to the entire natural domain.

## 11. Conclusion

The EML iteration $x_{n+1} = e^a\log(b x_n + c)$ converges Q-linearly with asymptotic ratio
*exactly* the local derivative magnitude $|f'(x^\*)| = |e^a b/(b x^\* + c)|$, a value
strictly below the interval-wide contraction constant used in the classical a priori bound.
The result follows by composing soft metric convergence, the analytic derivative at the
fixed point, and injectivity (from $b>0$). It sharpens "the EML iteration converges at rate
$O(\rho^n)$" into the precise dynamical statement that its per-step error contraction tends
to the local slope at its own center — turning a qualitative convergence guarantee into a
quantitative, tunable rate.
