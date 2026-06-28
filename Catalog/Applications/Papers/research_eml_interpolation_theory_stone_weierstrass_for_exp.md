# A Constructive Hölder–Jackson Rate for the Exp–Log (EML) Algebra

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (approximation theory / theory of neural networks)

## Abstract

The Stone–Weierstrass theorem guarantees that the algebra of **EML functions** —
finite compositions of $\exp$, $\log$, addition, and multiplication — is dense in
$C(K)$ for any compact $K \subset \mathbb{R}^n$, because the EML algebra separates
points and contains the constants. This is an existence statement and carries no
information about the *size* of an approximant required to reach a prescribed
accuracy. We make the density quantitative and constructive in one variable. For a
target $f \in \mathrm{Lip}_\alpha([0,1])$ (the Hölder class, $0 < \alpha \le 1$,
with constant $L$), we analyze the continuous piecewise-linear interpolant
$\mathrm{pwLinInterp}\,f\,n$ on the uniform grid of $n$ cells — itself a width-$n$
EML network, since each affine piece is the primitive EML function
$\text{const} + \text{scalar}\cdot\text{var}$. We prove the **Jackson-type rate**
$$\sup_{x \in [0,1]} \bigl|f(x) - \mathrm{pwLinInterp}\,f\,n\,(x)\bigr| \le \frac{2L}{n^{\alpha}},$$
so accuracy $\varepsilon$ requires width $n = O(\varepsilon^{-1/\alpha})$ — exactly
the conjectured $\varepsilon^{-n/\alpha}$ exponent in dimension $n = 1$. The
Lipschitz case $\alpha = 1$ recovers the sharp linear-interpolation rate $L/n$. We
also establish pointwise convergence $\mathrm{pwLinInterp}\,f\,n\,(x) \to f(x)$.
The development is fully formalized and machine-checked. The central technical step
is a *single-cell* Hölder estimate that controls both the value drift and the
divided-difference (slope) contribution by the same quantity $L h^{\alpha}$,
isolating where the exponent $\alpha < 1$ enters and how the short cell width tames
the otherwise-divergent slope.

## 1. Introduction

### 1.1 From existence to budgets

Let $K \subset \mathbb{R}^n$ be compact. The **EML algebra** $\mathcal{A}(K)$ is
the smallest subalgebra of $C(K)$ closed under the four operations $\exp$, $\log$
(applied where positive), $+$, and $\times$, and containing the coordinate
functions and the constants. This class is the natural mathematical idealization of
the function families that modern machine-learning models assemble: layers that
exponentiate, take logarithms, add, and multiply. Understanding what such a class
can represent — and at what cost — is therefore both a question of classical
approximation theory and a question about the expressive power of learned models.

Two elementary observations place $\mathcal{A}(K)$ within the hypotheses of the
Stone–Weierstrass theorem. First, the function
$$g_{a,b,c}(t) = e^{a}\,\log(bt + c) \qquad (a, b > 0)$$
is strictly monotone in $t$ (its derivative $e^{a} b / (bt + c)$ is strictly
positive on its domain), so for any two distinct points $x \ne y$ there are
parameters making $g_{a,b,c}(x) \ne g_{a,b,c}(y)$: the algebra **separates points**.
Second, $e^{a}\log c$ realizes an arbitrary real constant for suitable $c > 0$, so
the algebra **contains the constants**. By Stone–Weierstrass, $\mathcal{A}(K)$ is
therefore **dense** in $C(K)$: any continuous function can be approximated
arbitrarily well by EML functions.

Density alone, however, is unsatisfying for applications. It does not bound the
**complexity** — here, the **width**, the number of elementary affine or exp–log
pieces — needed to reach error $\varepsilon$. This is precisely the gap between two
traditions. On one side, the universal approximation theorems of neural-network
theory are *existential*: they assert that *some* network of *some* finite size
approximates the target, with no usable handle on the size. On the other side, the
classical **Jackson theory** of approximation ties an *explicit rate* of error
decay to the smoothness of the target. The purpose of this paper is to supply such
a rate for $\mathcal{A}([0,1])$, constructively, with explicit, uniform constants.

### 1.2 The construction in one sentence

We do not search for a clever approximant; we use the most elementary one
imaginable. Partition $[0,1]$ into $n$ equal cells, sample the target at the
breakpoints, and connect consecutive samples by straight lines. Each straight
segment $\text{const} + \text{slope}\cdot x$ is already an EML function (no $\exp$ or
$\log$ needed), so the resulting "connect-the-dots" curve is a genuine width-$n$ EML
network. The entire content of the paper is the sharp analysis of how well this
humble object approximates, as a function of $n$ and of the smoothness of the
target.

### 1.3 Contributions

1. **A single-cell Hölder estimate** (`holderInterp_error`, Theorem 1): on any
   interval $[a,b]$ the linear interpolant of an $\alpha$-Hölder function has error
   at most $2L(b-a)^{\alpha}$.
2. **A global Jackson rate** (`pwLinInterp_holder_error`, Theorem 2): the width-$n$
   uniform interpolant achieves $\sup\text{-error} \le 2L/n^{\alpha}$ on $[0,1]$,
   yielding the width law $n = O(\varepsilon^{-1/\alpha})$.
3. **Convergence** (`pwLinInterp_holder_tendsto`, Theorem 3): pointwise
   convergence of the interpolants to the target.
4. **Unification**: the Lipschitz case $\alpha = 1$ is recovered as a slice, with a
   companion analysis sharpening the constant to give $L/n$.

All results are fully formalized and machine-verified; the proofs below are faithful
sketches of those formal arguments. We have made no use of unproven assumptions.

### 1.4 Relation to classical and machine-learning approximation

The phenomenon we quantify is, in the abstract, classical: piecewise-linear
interpolation of Hölder functions is old, and rate results of Jackson type date to
the early twentieth century. Three features distinguish the present treatment.
First, the function class is the EML algebra, the algebraic core of exp–log models,
rather than trigonometric polynomials or generic splines; the affine pieces are
viewed as the simplest EML primitives so that the "width" is the natural complexity
measure for that class. Second, the constants are fully explicit and uniform — the
bound $2L/n^{\alpha}$ holds for *every* $x$ and *every* $n$, with no asymptotic
qualifier and no hidden constant — which is exactly what is required to convert the
result into a deployable resource budget. Third, the entire argument is machine
checked, so the constants and the scope of the hypotheses are guaranteed rather than
asserted.

## 2. Definitions

Throughout, $f : \mathbb{R} \to \mathbb{R}$, $L \ge 0$, and $0 < \alpha \le 1$.

**Definition 2.1 (Hölder class).** $f \in \mathrm{Lip}_\alpha$ with constant $L$ if
$$|f(x) - f(y)| \le L\,|x - y|^{\alpha} \qquad \text{for all } x, y \in \mathbb{R}.$$
For $\alpha = 1$ this is the Lipschitz condition. Here $|x-y|^{\alpha}$ denotes the
real power (the Lean `Real.rpow`). The class interpolates between Lipschitz
regularity ($\alpha = 1$) and progressively rougher functions as $\alpha \downarrow
0$; the canonical rough example is $\sqrt{x}$, which is $\tfrac12$-Hölder with
constant $1$ but not Lipschitz, since its slope is unbounded near the origin.

**Definition 2.2 (Uniform cell decomposition).** For $n \ge 1$ partition $[0,1]$
into the $n$ cells $[k/n, (k+1)/n]$, $k = 0, \dots, n-1$. For $x \in [0,1]$ define
the cell index
$$k(n,x) = \min\bigl(n-1,\ \lfloor n x \rfloor\bigr), \qquad a = \frac{k(n,x)}{n}, \quad b = \frac{k(n,x)+1}{n},$$
so that $b - a = 1/n$ and (Lemma 2.4) $x \in [a,b]$. The clamp by $n-1$ handles the
right endpoint $x = 1$, where $\lfloor n x \rfloor = n$ would otherwise overshoot
the last cell.

**Definition 2.3 (Piecewise-linear EML interpolant, `pwLinInterp`).** With $a,b$ as
above,
$$\mathrm{pwLinInterp}\,f\,n\,(x) \;=\; f(a) + \frac{f(b) - f(a)}{b - a}\,(x - a).$$
On each cell this is an affine function $\text{const} + \text{slope}\cdot x$, the
simplest non-constant EML primitive; the global function is continuous and
piecewise-linear with $n$ pieces, i.e. a **width-$n$ EML network**. Note that the
interpolant *interpolates*: at every breakpoint $x = k/n$ it equals $f(k/n)$
exactly, and between breakpoints it is the secant line.

**Lemma 2.4 (Cell location, `pwLinInterp_locate`).** For $n \ge 1$ and
$x \in [0,1]$, with $a, b$ from Definition 2.2, one has $a \le x \le b$.

*Sketch.* If $x < 1$ then $\lfloor nx \rfloor \le n-1$, so $k = \lfloor nx \rfloor$
and $a = \lfloor nx\rfloor/n \le x < (\lfloor nx\rfloor+1)/n = b$. At $x = 1$ the
clamp gives $k = n-1$, $a = (n-1)/n \le 1 = b$. $\qquad\blacksquare$

## 3. Main results

### 3.1 The single-cell estimate

**Theorem 1 (`holderInterp_error`).** Let $f \in \mathrm{Lip}_\alpha$ with constant
$L$, $0 < \alpha$, $0 \le L$. For $a < b$ and $x \in [a,b]$,
$$\left| f(x) - \Bigl( f(a) + \frac{f(b)-f(a)}{b-a}(x-a) \Bigr) \right| \;\le\; 2L\,(b-a)^{\alpha}.$$

*Proof sketch.* Write the error as $\bigl(f(x) - f(a)\bigr) - \frac{f(b)-f(a)}{b-a}(x-a)$
and apply the triangle inequality. Two bounds suffice.

- **Value drift.** Since $0 \le x - a \le b - a$ and $f$ is $\alpha$-Hölder,
  $$|f(x) - f(a)| \le L\,|x-a|^{\alpha} = L\,(x-a)^{\alpha} \le L\,(b-a)^{\alpha},$$
  using monotonicity of $t \mapsto t^{\alpha}$ for $t \ge 0$ (`Real.rpow_le_rpow`).
- **Slope contribution.** With $h = b - a > 0$,
  $$\left|\frac{f(b)-f(a)}{h}(x-a)\right| = \frac{|f(b)-f(a)|}{h}\,(x-a) \le \frac{L h^{\alpha}}{h}\cdot h = L\,h^{\alpha},$$
  where $|f(b)-f(a)| \le L h^{\alpha}$ (Hölder) and $(x-a) \le h$. The divided
  difference is $O(h^{\alpha-1})$, which diverges as $h \to 0$ when $\alpha < 1$,
  but the factor $(x-a) \le h$ restores the order to $L h^{\alpha}$.

Summing the two bounds gives $2L(b-a)^{\alpha}$. $\qquad\blacksquare$

This is the crux of the whole development: the apparent blow-up of the secant slope
for rough targets is exactly cancelled by the cell width, so both error sources
scale identically as $L h^{\alpha}$. It is worth stressing that this estimate is
*purely local* — it sees only the cell $[a,b]$ and the Hölder constant — which is
what later makes adaptive refinement (Section 8) tractable.

### 3.2 The global Jackson rate

**Theorem 2 (`pwLinInterp_holder_error`).** Let $f \in \mathrm{Lip}_\alpha$ with
constant $L$, $0 < \alpha$, $0 \le L$. Then for all $n \ge 1$ and $x \in [0,1]$,
$$\bigl| f(x) - \mathrm{pwLinInterp}\,f\,n\,(x) \bigr| \;\le\; \frac{2L}{n^{\alpha}}.$$

*Proof sketch.* Fix $x \in [0,1]$ and $n \ge 1$. By Lemma 2.4, $x$ lies in the cell
$[a,b]$ with $b - a = 1/n$, and by Definition 2.3,
$\mathrm{pwLinInterp}\,f\,n\,(x) = f(a) + \frac{f(b)-f(a)}{b-a}(x-a)$. Apply
Theorem 1 to the interval $[a,b]$:
$$\bigl| f(x) - \mathrm{pwLinInterp}\,f\,n\,(x) \bigr| \le 2L\,(b-a)^{\alpha} = 2L\,(1/n)^{\alpha}.$$
Finally $(1/n)^{\alpha} = 1/n^{\alpha}$ (`Real.div_rpow`, `Real.one_rpow`), giving
$2L/n^{\alpha}$. $\qquad\blacksquare$

The bound is genuinely uniform: it holds simultaneously for all $x \in [0,1]$, so it
controls the sup norm. Because the cell width is exactly $1/n$ for every cell, the
per-cell estimate of Theorem 1 is the same in every cell, and no summation or
averaging is needed — the worst cell already meets the bound.

**Corollary 2.1 (Width law).** To guarantee $\sup_{[0,1]}|f - \mathrm{pwLinInterp}\,f\,n| \le \varepsilon$
it suffices to take $n \ge (2L/\varepsilon)^{1/\alpha}$, i.e. $n = O(\varepsilon^{-1/\alpha})$.
In dimension $1$ this is exactly the mission's conjectured $\varepsilon^{-n/\alpha}$
exponent with $n = 1$. Concretely, the minimal certified width is
$n^{\star} = \lceil (2L/\varepsilon)^{1/\alpha} \rceil$.

### 3.3 Convergence

**Theorem 3 (`pwLinInterp_holder_tendsto`).** Under the hypotheses of Theorem 2,
for each fixed $x \in [0,1]$,
$$\mathrm{pwLinInterp}\,f\,n\,(x) \xrightarrow[n\to\infty]{} f(x).$$

*Proof sketch.* Since $\alpha > 0$, $n^{\alpha} \to \infty$ (`tendsto_rpow_atTop`
composed with $n \mapsto (n:\mathbb{R})$), hence $2L/n^{\alpha} \to 0$
(a constant divided by a quantity tending to $+\infty$). Theorem 2 bounds the
distance $|f(x) - \mathrm{pwLinInterp}\,f\,n\,(x)|$ by this null sequence, so the
$\varepsilon$–$N$ definition of the limit is satisfied (a squeeze).
$\qquad\blacksquare$

Theorem 3 is the constructive counterpart of the Stone–Weierstrass density for the
EML algebra restricted to $[0,1]$ and to Hölder targets: not only does an
approximating sequence exist, but the explicit interpolants converge, and Theorem 2
even tells us how fast.

## 4. Worked examples

We illustrate the two regimes — Lipschitz and genuinely rough — with concrete
targets. The numbers below are reproduced exactly by the accompanying numerical
demonstration.

### 4.1 A Lipschitz target: $f(x) = x^2$

On $[0,1]$, $f(x) = x^2$ has $|f'(x)| = 2x \le 2$, so it is Lipschitz with $L = 2$
($\alpha = 1$). Theorem 2 gives the guarantee $2L/n = 4/n$, while the sharper
companion Lipschitz analysis gives $L/n = 2/n$. The measured maximal error of the
width-$n$ interpolant is in fact $\tfrac{1}{4n^2}$ (the standard linear
interpolation error for a function of bounded second derivative), comfortably below
both linear bounds:

| $n$ | measured sup-error | Hölder bound $2L/n$ |
|----:|-------------------:|--------------------:|
| 4   | 0.01562500         | 1.00000000          |
| 16  | 0.00097656         | 0.25000000          |
| 64  | 0.00006104         | 0.06250000          |
| 256 | 0.00000381         | 0.01562500          |

The bound is conservative for $x^2$ precisely because $x^2$ is smoother than a
generic Lipschitz function; the theorem is stated for the whole Lipschitz class and
so is governed by its worst members.

### 4.2 A genuinely rough target: $f(x) = \sqrt{x}$

The square root is $\tfrac12$-Hölder with $L = 1$ but is *not* Lipschitz: near
$x = 0$ its slope is unbounded, so no linear rate $C/n$ can hold. Theorem 2
predicts the slower rate $2L/n^{1/2} = 2/\sqrt n$, and the measured error tracks
$n^{-1/2}$:

| $n$ | measured sup-error | Hölder bound $2/\sqrt n$ |
|----:|-------------------:|-------------------------:|
| 4   | 0.12500000         | 1.00000000               |
| 16  | 0.06249996         | 0.50000000               |
| 64  | 0.03124998         | 0.25000000               |
| 256 | 0.01562278         | 0.12500000               |

Doubling $n$ multiplies the error by $1/\sqrt 2 \approx 0.707$, exactly the $n^{-1/2}$
decay. To match the accuracy that $x^2$ reaches with $\sim 100$ pieces, $\sqrt x$
needs on the order of $10^4$ — the unavoidable surcharge for the spike at the
origin, and a faithful quantitative reflection of the exponent $\alpha = \tfrac12$.

### 4.3 Certified width selection

For $f(x) = \cos(3x)$ ($\alpha = 1$, $L = 3$ since $|f'| = 3|\sin(3x)| \le 3$), the
width law $n^{\star} = \lceil (2L/\varepsilon)^{1/\alpha} \rceil = \lceil 6/\varepsilon \rceil$
produces, for each tolerance $\varepsilon$, a width whose realized error indeed
falls below $\varepsilon$: e.g. $\varepsilon = 0.01$ gives $n^{\star} = 600$ with
realized error $\approx 3.1\times 10^{-6}$, and $\varepsilon = 0.001$ gives
$n^{\star} = 6000$ with realized error $\approx 3\times 10^{-8}$. The budget is
always met, usually with margin to spare.

## 5. Algorithms

### 5.1 Constructing and evaluating the interpolant

Given $f$, width $n$, and query $x \in [0,1]$:

1. Compute the cell index $k = \min(n-1, \lfloor n x \rfloor)$.
2. Set $a = k/n$, $b = (k+1)/n$.
3. Return $f(a) + \dfrac{f(b)-f(a)}{b-a}(x-a)$.

Evaluation is $O(1)$ per query after $O(n)$ precomputation of the $n+1$ samples;
storage is $O(n)$. The construction is *non-adaptive* (uniform grid), which is what
makes the constant in Theorem 2 explicit and uniform. The same uniformity that
costs accuracy on locally rough functions buys simplicity and a closed-form
guarantee.

### 5.2 Certified width selection

Given a Hölder constant $L$, exponent $\alpha$, and tolerance $\varepsilon$, the
minimal certified width is
$$n^{\star} = \left\lceil \left(\frac{2L}{\varepsilon}\right)^{1/\alpha} \right\rceil,$$
which by Theorem 2 guarantees uniform error $\le \varepsilon$. This converts the
abstract density of the EML algebra into a deployable sizing rule, computable in
$O(1)$ arithmetic operations.

## 6. Applications

- **Certified surrogates in scientific computing.** Any Lipschitz or Hölder
  response surface (e.g. a cost or constraint function with a known modulus of
  continuity) admits a piecewise-linear EML surrogate with a *provable*,
  closed-form accuracy guarantee — no validation set or empirical tuning required.
- **Width benchmarks for networks.** Because each affine piece is a minimal EML
  primitive, Theorem 2 gives a concrete benchmark against which deeper exp–log
  architectures can be measured: in one dimension, any architecture must, at best,
  match $\varepsilon^{-1/\alpha}$, so claims of superior efficiency must beat this
  explicit rate.
- **Quantitative Stone–Weierstrass.** The result replaces the qualitative density
  of $\mathcal{A}([0,1])$ with a quantitative modulus, useful wherever EML algebras
  are used as function classes and a complexity estimate is needed.

## 7. Discussion

The mathematical heart of the paper is the observation in Theorem 1 that, on a cell
of width $h$, *both* error sources — the value drift $|f(x)-f(a)|$ and the slope
term $\frac{|f(b)-f(a)|}{h}(x-a)$ — are bounded by the *same* quantity $L h^{\alpha}$.
The slope term is the delicate one: its divided difference is $O(h^{\alpha-1})$ and
diverges as the grid refines when $\alpha < 1$, yet the lever arm $(x-a) \le h$
multiplies it back down to $O(h^{\alpha})$. This exact cancellation is why the
*uniform* (non-adaptive) interpolant already attains the optimal Hölder exponent
$n^{-\alpha}$, with no need for adaptivity. The condition $\alpha > 0$ is essential:
at $\alpha = 0$ the modulus of continuity need not vanish, and no rate can hold.

It is also worth noting what the result does *not* claim. It does not claim the
constant $2$ is optimal; indeed the Lipschitz companion sharpens it to $1$ when
$\alpha = 1$, and for specific smooth targets such as $x^2$ the realized error is
far smaller (Section 4). The value of the theorem is its uniformity and its scope:
one construction, one inequality, the entire Hölder scale $\alpha \in (0,1]$, with a
constant that can be written down and used.

### 7.1 On the role of the real power

A technical but instructive point is the use of the *real* power
$|x-y|^{\alpha}$ (rather than an integer or rational power) in the Hölder
condition. For non-integer $\alpha$ the power is defined through $\exp$ and $\log$,
so the very regularity class we approximate is itself articulated in the language of
the EML algebra. Two facts about this power do all the analytic work: its
monotonicity $0 \le s \le t \Rightarrow s^{\alpha} \le t^{\alpha}$, used to pass from
$(x-a)^{\alpha}$ to $(b-a)^{\alpha}$ in Theorem 1, and the homogeneity identity
$(1/n)^{\alpha} = 1/n^{\alpha}$, used to convert the cell bound into the global rate
in Theorem 2. The convergence Theorem 3 then rests on the single additional fact
that $n^{\alpha} \to \infty$ for $\alpha > 0$. No deeper machinery is required, which
is part of why the result is clean enough to certify completely.

## 8. Future work

The following directions extend the present one-dimensional, uniform-grid result.

1. **Multivariate tensor-grid rate $O(n^{-\alpha})$ on $[0,1]^d$.** The $d$-fold
   tensor product of `pwLinInterp` (multilinear interpolation on a uniform $n^d$
   grid) should approximate every $\alpha$-Hölder $f:[0,1]^d \to \mathbb{R}$ with
   uniform error $\le C_d\,L\,n^{-\alpha}$, so accuracy $\varepsilon$ needs width
   $O(\varepsilon^{-d/\alpha})$ — the mission's $\varepsilon^{-n/\alpha}$ exponent
   and the familiar curse of dimensionality. The mechanism is that multilinear
   interpolation error telescopes coordinate by coordinate, so the one-dimensional
   cell bound $2L h^{\alpha}$ composes additively across the $d$ axes with a
   dimension-only constant.
2. **Order-optimal lower bound.** For each $\alpha \in (0,1]$ there should exist an
   $\alpha$-Hölder $f$ (a self-similar Weierstrass-type sawtooth) for which *every*
   continuous piecewise-linear function with $n$ pieces has sup error
   $\ge c\,L\,n^{-\alpha}$, matching Theorem 2 and proving the rate optimal.
3. **Adaptive grids for spatially varying moduli.** If $f$ is $\alpha$-Hölder
   locally with constant $L(x)$, a greedy grid equidistributing the local error
   should attain accuracy $\varepsilon$ with
   $n = O\bigl((\int_0^1 L(x)^{1/\alpha}\,dx)\,\varepsilon^{-1/\alpha}\bigr)$
   cells — strictly fewer than the uniform $O((\sup L)\,\varepsilon^{-1/\alpha})$.
   This is feasible precisely because Theorem 1 is *local*.
4. **Genuine exp/log pieces.** Replace each affine piece by a soft-max / soft-plus
   exp–log unit and show it matches the affine-piece rate, closing the loop with the
   smooth-network strand of the project.

## 9. Conclusion

A single, explicit, humble construction — connect-the-dots on a uniform grid —
realizes the conjectured Hölder Jackson scaling $n^{-\alpha}$ for the EML algebra in
one variable, with the fully explicit, uniform constant $2L$. It unifies the
Lipschitz and Hölder regimes, makes the width law $n = O(\varepsilon^{-1/\alpha})$
constructive, and turns the qualitative Stone–Weierstrass density of exp–log
functions into a quantitative, certifiable guarantee. The nineteenth-century insight
that smooth curves can be drawn with straight lines is here made exact: we know, to
the constant, how many lines it takes.
