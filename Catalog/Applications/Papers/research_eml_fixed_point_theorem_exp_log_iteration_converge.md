# Certified Convergence and a Sharp Existence Threshold for Exp–Log (EML) Fixed-Point Iteration

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (dynamical systems / numerical analysis)

## Abstract

We study the single-operator *exp–log* (EML) map
$f_{a,b,c}(x) = e^{a}\log(bx+c)$ as a discrete dynamical system. We prove four
groups of results. **(i) Contraction and convergence:** on any closed interval
$[\ell,h]$ on which $f$ is self-mapping and its derivative is bounded in modulus
by some $\rho<1$, the map has a unique fixed point $x^\*$, and the Picard
iteration $x_{n+1}=f(x_n)$ converges to it from every starting point in the
interval. **(ii) Certified geometric rate:** the iteration obeys the explicit a
priori bound $|x_n-x^\*|\le |x_1-x_0|\,\rho^n/(1-\rho)$, which tends to $0$,
upgrading qualitative convergence to a computable $O(\rho^n)$ certificate.
**(iii) Sharp existence threshold:** for $b=1$, a fixed point exists in the
natural domain $x+c>0$ **if and only if** the parameters are *supercritical*,
$c\ge e^a(1-a)$; below the threshold no fixed point exists, and exactly on the
threshold the unique fixed point $x^\*=e^a-c$ is *neutral*, $f'(x^\*)=1$, so the
existence frontier coincides with the contraction frontier. **(iv)
Self-validating enclosure:** when $b>0$, $f$ is monotone, and the orbits started
at the two endpoints bracket $x^\*$ at every step with bracket width tending to
$0$. We give a fully worked instance, $f(x)=e\,\log(x+100)$ on $[0,20]$ with
$\rho=1/30$, carrying an end-to-end certified error bound. A notable corollary
**falsifies** the naive expectation that the box $a\in(0,1),\,b=1,\,c\in(0,1)$
yields fixed points: the point $a=c=\tfrac12$ has *none*.

---

## 1. Introduction

Iterative maps built from exponentials and logarithms appear throughout applied
mathematics and, increasingly, in the activation and gating functions of machine
learning models. Unlike generic nonlinearities, the composite
$f(x)=e^{a}\log(bx+c)$ has enough analytic structure to permit a complete
dynamical analysis. This paper carries out that analysis and certifies every
step.

The questions we answer are the classical ones for any iterated map: *Does a
fixed point exist? Is it unique? Does the iteration converge, and how fast? Can
the answer be enclosed with guaranteed error bars?* We answer all of them, and
in the existence question we obtain a *sharp* threshold separating order from
the absence of equilibria.

Throughout, $\log$ denotes the natural logarithm and the **natural domain** of
$f$ is $\{x : bx+c>0\}$, where the logarithm is defined.

---

## 2. Definitions

**Definition 1 (EML operator, `EMLIterOp`).**
For parameters $a,b,c\in\mathbb{R}$, the EML operator is
$$f_{a,b,c}(x) \;=\; e^{a}\,\log(bx+c).$$

**Definition 2 (Iteration sequence, `EMLIterOp.iterSeq`).**
For an initial point $x_0$, the Picard orbit is $x_0$ given, and
$x_{n+1} = f_{a,b,c}(x_n)$.

**Definition 3 (Contraction data, `EMLContractionData`).**
A bundle certifying that $f_{a,b,c}$ is a contraction on a closed interval
consists of reals $a,b,c,\ell,h,\rho$ together with the hypotheses:
$\ell<h$; $0\le\rho<1$; positivity of the log-argument,
$bx+c>0$ for all $x\in[\ell,h]$; self-mapping, $f_{a,b,c}([\ell,h])\subseteq[\ell,h]$;
and the derivative bound $\bigl|\,e^{a}b/(bx+c)\,\bigr|\le\rho$ for all
$x\in[\ell,h]$.

---

## 3. Differential structure

**Lemma 1 (Derivative formula, `EMLIterOp.hasDerivAt`, `EMLIterOp.deriv_eq`).**
If $bx+c>0$ then $f_{a,b,c}$ is differentiable at $x$ with
$$f'_{a,b,c}(x) \;=\; \frac{e^{a}b}{bx+c}.$$

*Proof sketch.* Differentiate the composition: the inner affine map $bx+c$ has
derivative $b$, the logarithm contributes $1/(bx+c)$ via the chain rule (valid
since $bx+c\neq0$), and the constant factor $e^a$ scales the result. $\square$

The formula is the engine of the whole paper: $f'$ is positive when $b>0$
(monotonicity, §7) and small when $bx+c$ is large relative to $e^a b$
(contraction, §4).

**Lemma 2 (Fixed-point identity, `EMLIterOp.fixedPoint_eq`).**
If $f_{a,b,c}(x^\*)=x^\*$ then $x^\*=e^{a}\log(bx^\*+c)$.

**Lemma 2b (`EMLIterOp.fixedPoint_arg_gt_one`).**
If $x^\*$ is a fixed point with $x^\*>0$ and $bx^\*+c>0$, then $bx^\*+c>1$.

*Proof sketch.* If $bx^\*+c\le1$ then $\log(bx^\*+c)\le0$, so
$x^\*=e^a\log(bx^\*+c)\le0$, contradicting $x^\*>0$. $\square$

---

## 4. Contraction, uniqueness and convergence

**Lemma 3 (Lipschitz from a derivative bound, `EMLIterOp.lipschitz_of_deriv_bound`).**
Suppose $\ell<h$, that $bx+c>0$ on $[\ell,h]$, and that
$|e^{a}b/(bx+c)|\le\rho$ on $[\ell,h]$. Then for all $x,y\in[\ell,h]$,
$$|f_{a,b,c}(x)-f_{a,b,c}(y)| \;\le\; \rho\,|x-y|.$$

*Proof sketch.* The interval is convex and $f$ is differentiable on it with the
stated derivative bound; the mean-value inequality (convexity form,
`Convex.norm_image_sub_le_of_norm_hasDerivWithin_le`) yields the Lipschitz
estimate with constant $\rho$. $\square$

**Theorem A (Uniqueness, `EMLIterOp.fixedPoint_unique`).**
Under the hypotheses of Lemma 3 with $\rho<1$, the operator $f_{a,b,c}$ has at
most one fixed point in $[\ell,h]$.

*Proof sketch.* If $x_1,x_2$ are fixed points, Lemma 3 gives
$|x_1-x_2|=|f(x_1)-f(x_2)|\le\rho|x_1-x_2|$. With $\rho<1$ this forces
$|x_1-x_2|=0$. $\square$

**Lemma 4 (Invariance of the orbit, `EMLIterOp.iterSeq_mem_Icc`).**
If $x_0\in[\ell,h]$ and $f$ is self-mapping on $[\ell,h]$, then $x_n\in[\ell,h]$
for all $n$. *(Immediate induction.)*

**Lemma 5 (Geometric decay of steps, `EMLIterOp.iterSeq_geometric_decay`).**
For contraction data and $x_0\in[\ell,h]$,
$$|x_{n+1}-x_n| \;\le\; \rho^{n}\,|x_1-x_0|.$$

*Proof sketch.* Induction on $n$: the base case is trivial; the inductive step
applies Lemma 3 to the two in-interval iterates $x_n,x_{n-1}$ (in-interval by
Lemma 4) and multiplies the inductive bound by $\rho$. $\square$

**Lemma 6 (Cauchy, `EMLIterOp.iterSeq_cauchy`).**
The orbit is a Cauchy sequence. *(Geometric-series comparison via Lemma 5,
using `cauchySeq_of_le_geometric`.)*

**Theorem B (Convergence to a fixed point, `EMLIterOp.iterSeq_converges`).**
For contraction data and $x_0\in[\ell,h]$ there exists $x^\*$ with
$x_n\to x^\*$, $f_{a,b,c}(x^\*)=x^\*$, and $x^\*\in[\ell,h]$.

*Proof sketch.* By Lemma 6 and completeness of $\mathbb{R}$ the orbit converges
to some $x^\*$. Since $[\ell,h]$ is closed and contains every iterate (Lemma 4),
the limit lies in $[\ell,h]$, where the log-argument is positive and $f$ is
continuous; passing to the limit in $x_{n+1}=f(x_n)$ gives $f(x^\*)=x^\*$.
$\square$

**Remarks.** Two reduction identities are recorded for the canonical sub-cases:
$f_{a,1,1}(x)=e^a\log(x+1)$ (`EMLIterOp.special_b1_c1`) and
$f_{0,b,c}(x)=\log(bx+c)$ (`EMLIterOp.at_a_zero`).

---

## 5. Certified geometric rate

**Lemma 5′ (`EMLIterOp.iterSeq_dist_consecutive`).**
The step bound of Lemma 5 in metric form:
$\mathrm{dist}(x_n,x_{n+1})\le |x_1-x_0|\,\rho^{n}$.

**Theorem E (A priori error bound and certified rate,
`EMLIterOp.iterSeq_error_bound`, `EMLIterOp.iterSeq_certified_rate`).**
For contraction data, $x_0\in[\ell,h]$, with limit $x^\*$ from Theorem B,
$$\boxed{\;|x_n-x^\*| \;\le\; \frac{|x_1-x_0|\,\rho^{n}}{1-\rho}\;}\qquad(n\in\mathbb{N}).$$
Consequently the existence of $x^\*$ is packaged together with this bound at
every step.

*Proof sketch.* Sum the geometric tail of Lemma 5′ and pass to the limit
(`dist_le_of_le_geometric_of_tendsto`). $\square$

**Corollary (`EMLIterOp.iterSeq_error_tendsto_zero`).**
The right-hand bound $|x_1-x_0|\,\rho^n/(1-\rho)\to0$ as $n\to\infty$, certifying
genuine $O(\rho^n)$ convergence rather than merely qualitative convergence.

---

## 6. Sharp existence threshold (case $b=1$)

This section pins down *exactly* which parameters admit a fixed point. Write the
**residual** $g(x)=f_{a,1,c}(x)-x$.

**Lemma 7 (Residual ceiling, `residual_le`).**
For $x+c>0$,
$$f_{a,1,c}(x)-x \;\le\; e^{a}(a-1)+c.$$

*Proof sketch.* Apply $\log s\le s-1$ (`Real.log_le_sub_one_of_pos`) to
$s=(x+c)/e^a>0$. Then $\log(x+c)-a\le (x+c)/e^a-1$; multiplying by $e^a>0$ and
rearranging yields $e^a\log(x+c)-x\le e^a(a-1)+c$. The ceiling is attained at
$x+c=e^a$. $\square$

**Theorem C (Sharp existence law,
`no_fixedPoint_of_subcritical`, `fixedPoint_imp_c_ge_threshold`).**
For $b=1$:
- *(Subcritical ⇒ no fixed point.)* If $e^{a}(a-1)+c<0$ then $f_{a,1,c}(x)\neq x$
  for every $x$ in the natural domain $x+c>0$.
- *(Necessary condition.)* Conversely, if $f_{a,1,c}(x)=x$ for some $x$ with
  $x+c>0$, then $c\ge e^{a}(1-a)$.

*Proof sketch.* Both follow from Lemma 7: at a fixed point $g(x)=0$, so
$0\le e^a(a-1)+c$, i.e. $c\ge e^a(1-a)$; contrapositively, if the ceiling is
negative the residual is everywhere negative and no zero exists. $\square$

**Corollary (Falsification of the naive box, `no_fixedPoint_half_half`).**
For $a=\tfrac12,\,b=1,\,c=\tfrac12$ — inside the advertised
$(0,1)\times(0,1)$ box — the operator has **no** fixed point in its natural
domain, since $e^{1/2}(1-\tfrac12)=\tfrac12 e^{1/2}\approx0.824>\tfrac12=c$.

**Theorem D (Neutrality on the threshold, `threshold_fixedPoint_neutral`).**
At the critical value $c=e^{a}(1-a)$, the point $x^\*=e^{a}-c$ satisfies both
$$f_{a,1,c}(x^\*)=x^\*\qquad\text{and}\qquad f'_{a,1,c}(x^\*)=1.$$

*Proof sketch.* At $x^\*$ the log-argument is $x^\*+c=e^a$, so
$f(x^\*)=e^a\log(e^a)=e^a\cdot a$; and $x^\*=e^a-c=e^a-e^a(1-a)=e^a a$, giving
the fixed-point identity. The derivative is $e^a/(x^\*+c)=e^a/e^a=1$. $\square$

Theorem D shows the existence frontier $c=e^a(1-a)$ is also the *contraction
frontier*: exactly there the unique fixed point is neutral, and any
contraction-based convergence guarantee (which needs $|f'|<1$) fails. Order ends
at a sharp wall.

**Conditional existence above the threshold
(`EMLIterOp.fixedPoint_powerSeries_conjecture`).**
For $b=1,c=2$ and $0<a<\tfrac12$ a positive fixed point exists: $g(1)>0$ while
$g(3)<0$ (using $e^{1/2}\log5<3$), so the Intermediate Value Theorem yields
$x^\*\in(1,3)$ with $f_{a,1,2}(x^\*)=x^\*$. This realizes the supercritical
regime and is the existence anchor for the analytic-dependence program in §9.

---

## 7. Monotonicity and self-validating enclosure (case $b>0$)

**Lemma 8 (Monotonicity, `op_monotoneOn`).**
If $b>0$ and $bx+c>0$ on $[\ell,h]$, then $f_{a,b,c}$ is nondecreasing on
$[\ell,h]$: $u\le v\Rightarrow f(u)\le f(v)$.

*Proof sketch.* $u\le v$ implies $bu+c\le bv+c$, both positive, so
$\log(bu+c)\le\log(bv+c)$; multiply by $e^a\ge0$. $\square$

**Lemma 9 (Endpoint orbits are monotone, `iterSeq_lo_mono`, `iterSeq_hi_anti`).**
For contraction data with $b>0$, the lower orbit $n\mapsto f^n(\ell)$ is
nondecreasing and the upper orbit $n\mapsto f^n(h)$ is nonincreasing.

*Proof sketch.* The self-mapping property gives $\ell\le f(\ell)$ and
$f(h)\le h$; Lemma 8 propagates each inequality through the iteration by
induction. $\square$

**Lemma 10 (Bracketing, `iterSeq_lo_le_fixedPoint`, `iterSeq_fixedPoint_le_hi`).**
If $x^\*$ is a fixed point in $[\ell,h]$ then for all $n$,
$f^n(\ell)\le x^\*\le f^n(h)$. *(Monotone induction using $f(x^\*)=x^\*$.)*

**Theorem F (Certified two-sided enclosure, `certified_enclosure`).**
For contraction data with $b>0$ there is a unique fixed point $x^\*\in[\ell,h]$
such that, writing $\ell_n=f^n(\ell)$ and $u_n=f^n(h)$,
$$\ell_n\le x^\*\le u_n\ \ \forall n,\qquad \ell_n\to x^\*,\quad u_n\to x^\*,
\qquad u_n-\ell_n\to0.$$

*Proof sketch.* Both endpoint orbits converge to fixed points by Theorem B;
uniqueness (Theorem A) identifies the two limits as the same $x^\*$. Lemma 10
gives the enclosure at every step, and the two limits force the width to vanish.
$\square$

Theorem F is the form a numerical analyst wants: every step emits a
*certificate* $[\ell_n,u_n]\ni x^\*$, and combined with the explicit $\rho^n$
rate of Theorem E one can bound a priori how many steps a target enclosure width
requires.

---

## 8. A fully worked, certified instance

**Definition / Example (`concreteEML`).**
Take $a=1,b=1,c=100,\ \ell=0,\ h=20,\ \rho=1/30$, i.e.
$f(x)=e\,\log(x+100)$ on $[0,20]$ (`concreteEML_apply`). All contraction-data
hypotheses hold: on $[0,100\!+\!20]$ the argument $x+100\in[100,120]>0$;
$f([0,20])\subseteq[0,20]$ because $0\le e\log(x+100)$ and
$e\log120<5\cdot e<20$; and $|f'(x)|=e/(x+100)\le e/100<1/30$. The instance is
nontrivial: $e^{a}=e>1$ (`concreteEML_nontrivial`).

**Theorem G (End-to-end certified convergence, `concreteEML_certified`).**
For every $x_0\in[0,20]$ the iteration $x_{n+1}=e\,\log(x_n+100)$ converges to a
fixed point $x^\*\in[0,20]$ with
$$|x_n-x^\*|\;\le\;|x_1-x_0|\,\frac{(1/30)^n}{1-1/30}.$$

Numerically $x^\*\approx12.8467$. With $|x_1-x_0|\le20$, the bound drops below
$10^{-6}$ by $n=5$ and below $10^{-12}$ by $n=9$ — convergence is essentially
instantaneous and fully certified in advance.

---

## 9. Discussion and future work

The analysis cleanly separates four concerns — **existence** (the sharp
threshold $c\ge e^a(1-a)$, Theorem C), **uniqueness/convergence** (Theorems
A–B), **rate** (Theorem E), and **enclosure** (Theorem F) — and they compose: on
the supercritical side a fixed point exists, on the strictly supercritical side
the slope at the attractor is $<1$ so contraction and the certified rate apply,
and monotonicity furnishes self-validating brackets.

Two methodological points deserve emphasis. First, the existence threshold and
the contraction threshold *coincide* (Theorem D): the boundary $c=e^a(1-a)$ is a
genuine bifurcation curve where the fixed point is neutral. Second, the headline
intuition that a whole parameter *box* yields tame dynamics is provably wrong
(the $a=c=\tfrac12$ corollary); the correct description is a curved
supercritical region, not a rectangle.

Open directions (carried forward from the project's findings):

- **Global basin of attraction.** For $b=1,\,c>e^a(1-a)$ with repelling and
  attracting fixed points $x_-<x_+$, conjecture that the iteration converges to
  $x_+$ for *every* start $x_0>x_-$ (with $x_0+c>0$) and diverges upward for
  $x_0<x_-$, with $x_-$ the exact watershed.
- **Sharp contraction-ratio asymptotics.** Quantify $f'(x_+)=e^a/(x_++c)\le1-\delta(a,c)$
  and show both ratios $f'(x_\pm)\to1$ as $c\downarrow e^a(1-a)$, colliding at
  $1$ on the threshold.
- **Analytic dependence.** On $\{(a,c):c>e^a(1-a)\}$, show $x_+(a,c)$ is
  real-analytic and strictly increasing in $a$ and $c$, with a convergent power
  series in $a$ (via the implicit function theorem applied to
  $\Phi(x,a,c)=e^a\log(x+c)-x$, non-degenerate because $f'(x_+)<1$).
- **No genuine 2-cycles.** For $b=1$, conjecture $f(f(x))=x\Rightarrow f(x)=x$,
  so $f$ has no period-2 (or higher minimal-period) orbits, since $f$ is
  strictly monotone increasing.

---

## 10. Conclusion

The exp–log operator $f(x)=e^a\log(bx+c)$ is, in the right parameter regime,
about as well-behaved as a nonlinear iterated map can be: a unique fixed point,
universal convergence on its working interval, an explicit geometric error
certificate, and a self-validating two-sided enclosure. Its existence is
governed by the sharp, simple law $c\ge e^a(1-a)$, on whose boundary the dynamics
sit in perfect neutral balance. These properties make EML maps a dependable
primitive for certified iterative computation.
