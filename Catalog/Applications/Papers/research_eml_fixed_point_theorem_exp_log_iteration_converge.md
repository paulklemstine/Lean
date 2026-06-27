# Certified Fixed-Point Dynamics of the Exp-Log (EML) Operator

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty

## Abstract

We study the single-variable *EML* (Exp-Minus-Log) operator
$f(x) = e^{a}\log(bx+c)$ as a discrete dynamical system. Under parameter
ranges for which $f$ maps a closed interval $[\mathrm{lo},\mathrm{hi}]$ into
itself with derivative bounded in magnitude by some $\rho < 1$, we prove that
$f$ is a contraction and hence, by the Banach fixed-point theorem, possesses a
unique fixed point $x^{*}$ in the interval, to which the Picard iteration
$x_{n+1}=f(x_n)$ converges. We sharpen "converges" to a fully explicit *a
priori* geometric error estimate
$|x_n - x^{*}| \le |x_1-x_0|\,\rho^{n}/(1-\rho)$, and prove that this bound
vanishes, certifying genuine $O(\rho^{n})$ convergence. Adding the monotonicity
hypothesis $b>0$, we upgrade the one-sided rate to a *two-sided certified
enclosure*: iterating from the two endpoints produces an increasing lower orbit
and a decreasing upper orbit that bracket $x^{*}$ at every finite step with width
tending to zero. We exhibit a fully verified concrete instance,
$f(x)=e\,\log(x+100)$ on $[0,20]$ with $\rho = 1/30$, demonstrating that the
hypothesis class is non-vacuous. Finally, we identify a sharp closed-form
existence threshold $c_{\mathrm{crit}}(a)=e^{a}(1-a)$ for the $b=1$ family and
analyze the fold bifurcation that occurs there, raising several falsifiable
conjectures. All results are machine-checked.

## 1. Introduction

Iterative maps of the form $x_{n+1}=f(x_n)$ are the computational substrate of
numerical analysis, dynamical systems, and modern machine learning. Their
usefulness hinges on a single dichotomy: does the iteration converge, and if so,
to what, and how fast? For arbitrary nonlinear $f$ — including most neural-network
activation functions — these questions have no general answer.

The *EML* (Exp-Minus-Log) family proposes a more disciplined nonlinear primitive,
combining exponential amplification with logarithmic compression. This paper
analyzes the most basic EML iterate,
$$
f(x) = e^{a}\,\log(bx+c),
$$
and shows that it is exceptionally well behaved: on suitable invariant intervals
it is a contraction, with a unique fixed point reached at a certified geometric
rate, and — when monotone — equipped with a two-sided enclosure that makes it
directly usable inside verified-computing pipelines.

The paper is organized as follows. Section 2 fixes definitions and the data
structure encoding the contraction hypotheses. Section 3 derives the closed-form
derivative and the contraction (Lipschitz) estimate. Section 4 proves uniqueness
and convergence. Section 5 establishes the explicit a priori error bound.
Section 6 develops the monotone two-sided enclosure. Section 7 presents the fully
verified concrete instance. Section 8 analyzes the existence threshold and the
fold bifurcation. Section 9 discusses applications and future work.

## 2. Definitions

**Definition 2.1 (EML operator).** For parameters $a,b,c\in\mathbb{R}$, the EML
operator is
$$
f_{a,b,c}(x) = e^{a}\,\log(bx+c),
$$
defined wherever $bx+c>0$. In the formal development this is `EMLIterOp a b c x`.

**Definition 2.2 (Iteration sequence).** The Picard orbit from a seed
$x_0$ is
$$
\mathrm{iter}_0 = x_0,\qquad \mathrm{iter}_{n+1} = f_{a,b,c}(\mathrm{iter}_n),
$$
formalized as `EMLIterOp.iterSeq a b c x₀ n`.

**Definition 2.3 (Contraction data).** An `EMLContractionData` bundle packages a
self-consistent set of hypotheses witnessing that $f_{a,b,c}$ contracts on an
interval. It consists of:

- parameters $a,b,c\in\mathbb{R}$ and endpoints $\mathrm{lo}<\mathrm{hi}$;
- a contraction ratio $\rho$ with $0\le\rho<1$;
- *positivity of the log argument*: $bx+c>0$ for all $x\in[\mathrm{lo},\mathrm{hi}]$;
- *self-map*: $f_{a,b,c}(x)\in[\mathrm{lo},\mathrm{hi}]$ for all
  $x\in[\mathrm{lo},\mathrm{hi}]$;
- *derivative bound*: $\bigl|e^{a}b/(bx+c)\bigr|\le\rho$ for all
  $x\in[\mathrm{lo},\mathrm{hi}]$.

This structure is the hypothesis under which all the abstract theorems below are
stated. Its non-vacuity is established constructively in Section 7.

## 3. Derivative and the Contraction Estimate

**Lemma 3.1 (Differentiability and derivative formula, `hasDerivAt`/`deriv_eq`).**
If $bx+c>0$, then $f_{a,b,c}$ is differentiable at $x$ with
$$
f_{a,b,c}'(x) = \frac{e^{a}\,b}{bx+c}.
$$

*Proof sketch.* Write $f = (e^a\cdot)\circ\log\circ g$ with $g(x)=bx+c$. The chain
and product rules give $f' = e^a\cdot \frac{1}{g(x)}\cdot g'(x) = e^a\cdot
\frac{b}{bx+c}$, valid because $g(x)>0$ ensures $\log$ is differentiable there. ∎

The derivative is the linchpin: it is positive when $b>0$ and strictly decreasing
in $x$, so bounding it above on the interval bounds the Lipschitz constant.

**Lemma 3.2 (Lipschitz bound, `lipschitz_of_deriv_bound`).** Suppose $bx+c>0$ and
$|e^{a}b/(bx+c)|\le\rho$ for all $x\in[\mathrm{lo},\mathrm{hi}]$. Then for all
$x,y\in[\mathrm{lo},\mathrm{hi}]$,
$$
|f_{a,b,c}(x)-f_{a,b,c}(y)| \le \rho\,|x-y|.
$$

*Proof sketch.* The interval is convex; on it $f$ has derivative bounded by $\rho$
in norm. The mean value inequality for functions with bounded derivative on a
convex set (`Convex.norm_image_sub_le_of_norm_hasDerivWithin_le`) yields the
Lipschitz estimate directly. ∎

## 4. Uniqueness and Convergence (Banach)

**Theorem 4.1 (Uniqueness, `fixedPoint_unique`).** If $f_{a,b,c}$ satisfies the
derivative bound with $\rho<1$ on $[\mathrm{lo},\mathrm{hi}]$, then it has at most
one fixed point in the interval.

*Proof sketch.* If $x_1,x_2$ are both fixed, Lemma 3.2 gives
$|x_1-x_2|=|f(x_1)-f(x_2)|\le\rho|x_1-x_2|$. With $\rho<1$ this forces
$|x_1-x_2|=0$. ∎

**Lemma 4.2 (Invariance of the orbit, `iterSeq_mem_Icc`).** If $x_0\in
[\mathrm{lo},\mathrm{hi}]$ and $f$ maps the interval into itself, then every
iterate $\mathrm{iter}_n\in[\mathrm{lo},\mathrm{hi}]$.

*Proof sketch.* Induction on $n$ using the self-map hypothesis. ∎

**Lemma 4.3 (Geometric decay of steps, `iterSeq_geometric_decay`).** For
$x_0\in[\mathrm{lo},\mathrm{hi}]$,
$$
|\mathrm{iter}_{n+1}-\mathrm{iter}_n| \le \rho^{n}\,|\mathrm{iter}_1-\mathrm{iter}_0|.
$$

*Proof sketch.* Induction: the base case is trivial; the inductive step applies the
Lipschitz bound (Lemma 3.2) to the consecutive pair, using Lemma 4.2 to keep both
arguments in the interval. ∎

**Theorem 4.4 (Convergence, `iterSeq_converges`).** For
$x_0\in[\mathrm{lo},\mathrm{hi}]$ there exists $x^{*}\in[\mathrm{lo},\mathrm{hi}]$
with $\mathrm{iter}_n\to x^{*}$ and $f_{a,b,c}(x^{*})=x^{*}$.

*Proof sketch.* Lemma 4.3 makes the orbit Cauchy (its steps are summable by the
geometric series, via `cauchySeq_of_le_geometric`), and $\mathbb{R}$ is complete,
so $\mathrm{iter}_n\to x^{*}$. The interval is closed, so $x^{*}$ lies in it. By
continuity of $f$ on the interval, passing to the limit in
$\mathrm{iter}_{n+1}=f(\mathrm{iter}_n)$ gives $f(x^{*})=x^{*}$. ∎

Together with Theorem 4.1, this is the Banach fixed-point theorem for the EML
operator: a *unique* fixed point, reached from every seed in the interval.

## 5. Certified Geometric Rate

Convergence alone does not bound the work required to reach a target accuracy. We
make the rate explicit.

**Lemma 5.1 (Consecutive contraction in distance, `iterSeq_dist_consecutive`).**
$\mathrm{dist}(\mathrm{iter}_n,\mathrm{iter}_{n+1})\le
|\mathrm{iter}_1-\mathrm{iter}_0|\,\rho^{n}$. This is Lemma 4.3 rephrased with the
metric `dist` so as to feed Mathlib's geometric-series API.

**Theorem 5.2 (A priori error bound, `iterSeq_error_bound`).** If
$\mathrm{iter}_n\to x^{*}$, then for every $n$,
$$
|\mathrm{iter}_n - x^{*}| \le \frac{|\mathrm{iter}_1-\mathrm{iter}_0|\,\rho^{n}}{1-\rho}.
$$

*Proof sketch.* Summing the geometric tail of per-step distances (Lemma 5.1)
against the limit, via `dist_le_of_le_geometric_of_tendsto`, yields the bound. ∎

**Theorem 5.3 (Packaged certified rate, `iterSeq_certified_rate`).** For every seed
$x_0\in[\mathrm{lo},\mathrm{hi}]$ there is a fixed point $x^{*}\in[\mathrm{lo},
\mathrm{hi}]$ such that $\mathrm{iter}_n\to x^{*}$ and the bound of Theorem 5.2
holds at every step.

*Proof sketch.* Combine Theorem 4.4 (existence + limit) with Theorem 5.2 (bound). ∎

**Proposition 5.4 (The bound is non-trivial, `iterSeq_error_tendsto_zero`).** The
right-hand side $|\mathrm{iter}_1-\mathrm{iter}_0|\,\rho^{n}/(1-\rho)\to 0$ as
$n\to\infty$.

*Proof sketch.* $\rho^{n}\to 0$ since $0\le\rho<1$
(`tendsto_pow_atTop_nhds_zero_of_lt_one`); multiply and divide by constants. ∎

This is the precise content of the $O(\rho^{n})$ rate: a computable constant
$|\mathrm{iter}_1-\mathrm{iter}_0|/(1-\rho)$ times a geometrically decaying factor.

## 6. Monotone Two-Sided Certified Enclosure

The estimates above are *one-sided*: they bound the distance to a limit not yet in
hand. With the extra hypothesis $b>0$ — natural and satisfied by the catalog's
concrete instance — the EML operator becomes monotone, and the iteration becomes
*self-validating*.

**Theorem 6.1 (Monotonicity, `op_monotoneOn`).** If $b>0$ and $bx+c>0$ on
$[\mathrm{lo},\mathrm{hi}]$, then $f_{a,b,c}$ is monotone increasing there:
$u\le v \Rightarrow f(u)\le f(v)$.

*Proof sketch.* $u\le v$ gives $bu+c\le bv+c$, both positive, so
$\log(bu+c)\le\log(bv+c)$ by monotonicity of $\log$; multiply by $e^{a}\ge 0$. ∎

Write $\ell_n = f^{n}(\mathrm{lo})$ and $u_n = f^{n}(\mathrm{hi})$ for the lower and
upper orbits.

**Theorem 6.2 (Lower orbit increases, `iterSeq_lo_mono`).** With $b>0$, the
sequence $\ell_n$ is monotone increasing.

*Proof sketch.* The self-map property gives $\mathrm{lo}\le f(\mathrm{lo})=\ell_1$.
Applying the monotone $f$ repeatedly (Theorem 6.1) propagates $\ell_n\le\ell_{n+1}$
by induction. ∎

**Theorem 6.3 (Upper orbit decreases, `iterSeq_hi_anti`).** With $b>0$, the
sequence $u_n$ is monotone decreasing.

*Proof sketch.* Symmetric to Theorem 6.2: $f(\mathrm{hi})\le\mathrm{hi}$ propagates
through monotone $f$. ∎

**Theorem 6.4 (Squeeze, `iterSeq_lo_le_fixedPoint`/`iterSeq_fixedPoint_le_hi`).**
If $x^{*}$ is a fixed point in the interval, then for all $n$,
$$
\ell_n \le x^{*} \le u_n.
$$

*Proof sketch.* Induction. Base: $\mathrm{lo}\le x^{*}\le\mathrm{hi}$. Step: apply
monotone $f$ to $\ell_n\le x^{*}$ and use $f(x^{*})=x^{*}$ to get
$\ell_{n+1}=f(\ell_n)\le f(x^{*})=x^{*}$; symmetrically for the upper side. ∎

**Theorem 6.5 (Certified two-sided enclosure, `certified_enclosure`).** For a
$b>0$ EML contraction there is a unique fixed point $x^{*}$ such that, with
$\ell_n=f^{n}(\mathrm{lo})$ and $u_n=f^{n}(\mathrm{hi})$:

1. $\ell_n$ is increasing and $u_n$ is decreasing;
2. $\ell_n\le x^{*}\le u_n$ for every $n$;
3. both orbits converge to $x^{*}$, so the bracket width $u_n-\ell_n\to 0$.

*Proof sketch.* Existence and uniqueness of $x^{*}$ come from Theorems 4.1 and 4.4.
Monotonicity of the orbits is Theorems 6.2–6.3; the squeeze is Theorem 6.4. Both
orbits converge (each is a Picard orbit from a seed in the interval, Theorem 4.4)
and, by uniqueness, to the *same* $x^{*}$; hence $u_n-\ell_n\to x^{*}-x^{*}=0$. ∎

Operationally: at any step $n$ the computed pair $(\ell_n,u_n)$ is a rigorous
interval containing $x^{*}$, and combining with Theorem 5.2 tells the analyst how
many steps a target enclosure width requires.

## 7. A Fully Verified Concrete Instance

To certify non-vacuity of `EMLContractionData`, we construct an explicit witness.

**Definition 7.1 (`concreteEML`).** Take $a=1$, $b=1$, $c=100$, interval
$[0,20]$, and $\rho=1/30$, i.e. $f(x)=e\,\log(x+100)$.

**Theorem 7.2 (All hypotheses hold).** The bundle of Definition 7.1 satisfies every
field of `EMLContractionData`:

- *log argument positive*: $x+100\ge 100>0$ on $[0,20]$;
- *derivative bound*: $f'(x)=e/(x+100)\le e/100<3/100<1/30=\rho$, using $e<3$;
- *self-map*: $\log(x+100)\ge 0$ (since $x+100\ge 1$) gives the lower bound, and
  $e\,\log(x+100)\le e\,\log 120 < 3\cdot 5 = 15 < 20$ gives the upper bound, using
  $e<3$ and $\log 120 < 5$ (the latter from $e^{5}=(e)^{5}>2.7^{5}>120$).

*Proof sketch.* Each inequality is discharged by elementary real-analytic estimates
together with the numeric facts $e<3$, $e>2.7$, $\log 120<5$. ∎

**Theorem 7.3 (End-to-end certified convergence, `concreteEML_certified`).** From
any $x_0\in[0,20]$ the iteration $x_{n+1}=e\,\log(x_n+100)$ converges to a fixed
point $x^{*}\in[0,20]$ with
$$
|x_n-x^{*}| \le \frac{|x_1-x_0|\,(1/30)^{n}}{1-1/30}.
$$

*Proof sketch.* Instantiate Theorem 5.3 at the bundle of Definition 7.1. ∎

Numerically the fixed point is $x^{*}\approx 12.85$ (solving $x=e\log(x+100)$).
Because $\rho=1/30$, each step gains more than $1.4$ decimal digits; the enclosure
of Section 6 applies verbatim since $b=1>0$.

## 8. Existence Threshold and the Fold Bifurcation

For the canonical family $b=1$, $f(x)=e^{a}\log(x+c)$, fixed points solve
$g(x):=e^{a}\log(x+c)-x=0$. The residual $g$ has derivative
$g'(x)=e^{a}/(x+c)-1$, which vanishes uniquely at $x=e^{a}-c$ (the residual's
maximizer), where $g$ attains its maximum. Evaluating $g$ there yields the sharp
**existence threshold**
$$
c_{\mathrm{crit}}(a) = e^{a}(1-a).
$$
For $c>c_{\mathrm{crit}}(a)$ the maximum of $g$ is positive and $g$ has two roots
$x_-<x_+$; at $c=c_{\mathrm{crit}}(a)$ they coincide at $x^{*}=e^{a}a$ with
$f'(x^{*})=1$ (the neutral, non-hyperbolic case); for $c<c_{\mathrm{crit}}(a)$ there
are none. (An explicit existence witness for $a\in(0,\tfrac12)$, $c=2$ is provided
by `fixedPoint_powerSeries_conjecture`, proved via the intermediate value theorem
on $[1,3]$.)

Because $g''(x)=-e^{a}/(x+c)^{2}<0$ is nonzero at the collision, the degeneracy is a
generic **fold (saddle-node) bifurcation**, predicting the universal square-root
opening
$$
x_+(c)-x_-(c) = \kappa(a)\sqrt{c-c_{\mathrm{crit}}(a)} + o\!\left(\sqrt{\cdot}\right),
\qquad \kappa(a)=2\sqrt{2}\,e^{a/2}.
$$
Since $f'(x)=e^{a}/(x+c)$ is strictly decreasing and crosses $1$ exactly at the
maximizer $x=e^{a}-c$, the two roots straddle it: the larger $x_+$ has
$0\le f'(x_+)<1$ (attracting), the smaller $x_-$ has $f'(x_-)>1$ (repelling). These
sign statements, the universal $\sqrt{\cdot}$ scaling, and the monotonicity of
$c_{\mathrm{crit}}$ (from $c_{\mathrm{crit}}(0)=1$ down to $c_{\mathrm{crit}}(1)=0$)
are the open conjectures developed below.

## 9. Discussion, Applications, and Future Work

**Significance.** The EML operator is a microcosm of certified computation: it
converges, has a unique fixed point, converges at a computable geometric rate, and
— when monotone — emits a verified enclosure at every step. This is exactly the
package a numerical analyst or verified-computing system needs, and it composes:
the explicit $\rho^{n}$ rate bounds the number of steps to a target enclosure
width.

**Applications.** (i) *Verified iterative algorithms*: any pipeline built on EML
units inherits certified convergence and interval enclosures. (ii) *Disciplined
activations*: unlike arbitrary neural activations, EML units have provable
dynamical behavior, making EML-based recurrences analyzable. (iii) *Root-finding
with certificates*: the bracket $[\ell_n,u_n]$ is directly usable where guaranteed
error bounds are mandatory.

**Future work.** The following falsifiable conjectures arise directly from this
cycle's findings.

- *Fold scaling (C1).* As $c\downarrow c_{\mathrm{crit}}(a)$ the two fixed points
  collide at $x^{*}=e^{a}a$ with universal square-root separation
  $x_+-x_-=\kappa(a)\sqrt{c-c_{\mathrm{crit}}(a)}$, $\kappa(a)=2\sqrt2\,e^{a/2}$,
  forced by the nondegenerate quadratic maximum of the residual.
- *Two fixed points, one attracting (C2).* For $c>c_{\mathrm{crit}}(a)$ there are
  exactly two domain fixed points $x_-<e^{a}-c<x_+$, with $x_+$ attracting
  ($0\le f'(x_+)<1$) and $x_-$ repelling ($f'(x_-)>1$).
- *Sharp bracket rate (C3).* For a $b>0$ EML contraction with attracting fixed
  point $x^{*}$, the bracket width satisfies $w_{n+1}/w_n\to f'(x^{*})=e^{a}b/(bx^{*}
  +c)$ — the enclosure shrinks at the exact asymptotic linear rate, not merely
  $\le\rho$.
- *Threshold monotonicity (C4).* $c_{\mathrm{crit}}(a)=e^{a}(1-a)$ is strictly
  decreasing on $(0,\infty)$ with $c_{\mathrm{crit}}(0)=1$ and
  $c_{\mathrm{crit}}(1)=0$.

These build on machinery already in place — the closed-form derivative, the
intermediate-value existence argument, and the nested brackets — and require only
the standard Taylor/mean-value refinements to settle.

## 10. Conclusion

We have given a complete, machine-checked account of the fixed-point dynamics of
the exp-log EML operator: contraction, unique fixed point, certified geometric
convergence, and — under monotonicity — a self-validating two-sided enclosure,
all instantiated by an explicit verified example. The exp-log map thus stands as a
model of a nonlinear primitive whose dynamical behavior is not assumed but proved.
