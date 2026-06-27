# Comparative Statics of the Exp-Log Fixed Point: Monotone Dependence of an EML Contraction Equilibrium on its Scaling Parameter

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (dynamical systems, fixed-point iteration, parametric monotonicity)

---

## Abstract

We study the single-operator *exp-log* (EML) map $f_a(x) = e^{a}\log(b x + c)$
as a one-dimensional discrete dynamical system. Under parameter constraints that
make $f_a$ a contraction on a closed invariant interval $[\ell, h]$ — namely
that $b x + c > 0$ on the interval, that $f_a$ maps the interval into itself, and
that the derivative magnitude $|f_a'(x)| = |e^{a} b/(b x + c)|$ is bounded by a
constant $\rho \in [0, 1)$ — the Banach fixed-point theorem yields a unique
equilibrium $x^\*(a)$ to which the iteration $x_{n+1} = f_a(x_n)$ converges
geometrically. We recall this convergence theory (existence, uniqueness, an a
priori $O(\rho^{n})$ error bound, and a two-sided certified enclosure), and we
establish the central new result: the **comparative-statics law** for the
equilibrium. We prove that increasing the scaling parameter $a$ weakly increases
the fixed point, that strictly increasing $a$ strictly increases it, and that the
contraction's uniqueness propagates this to *every* fixed point of the larger
operator. The proof avoids implicit-function-theorem machinery entirely; it uses
only monotonicity of $\exp$, $\log$, and the operator, together with a
sub-solution / monotone-iteration ("monotone sandwich") argument. The positivity
of the smaller-parameter equilibrium is shown to be load-bearing. Consequently
the scaling parameter of an EML scheme is a *monotone, injective* control of its
equilibrium, which, combined with the certified convergence rate, makes EML
iterations tunable with provable, overshoot-free response.

---

## 1. Introduction

### 1.1 Motivation

Discrete dynamical systems of the form $x_{n+1} = f(x_n)$ underlie compounding
processes, control loops, root-finding schemes, and the layer-to-layer signal
flow of recurrent and deep computational models. When $f$ is a contraction, the
system is maximally well-behaved: there is a unique equilibrium and the iteration
converges to it geometrically from any admissible start. But contraction alone is
silent about *parametric* behavior — how the equilibrium responds when one tunes
a parameter of $f$. For a map intended to be used as a tunable component, this is
the decisive practical question.

We answer it for the exp-log family
$$f_a(x) = e^{a}\,\log(b x + c),$$
a "compress-then-scale" operator combining a logarithmic compression with an
exponential gain $e^{a}$. Such maps are deliberately tame surrogates for the
nonlinear activations used in learning systems, where predictable dynamics are
prized. The free parameter $a$ is the natural control dial; our object of study
is the dependence $a \mapsto x^\*(a)$ of the equilibrium on that dial.

### 1.2 Contributions

1. We recall, with full statements and proof sketches, the contraction theory of
   $f_a$: the derivative formula, fixed-point characterization, uniqueness, the
   convergence of the iteration, the explicit $O(\rho^{n})$ a priori error bound,
   and a two-sided certified enclosure obtained from monotone bracketing.
2. We prove the **monotone comparative-statics law**: $a_1 \le a_2 \Rightarrow
   x^\*(a_1) \le x^\*(a_2)$, with the strict version $a_1 < a_2 \Rightarrow
   x^\*(a_1) < x^\*(a_2)$, and a uniqueness-strengthened form.
3. We isolate the *mechanism*: a fixed point of the smaller operator is a
   sub-solution of the larger one, and contraction converts sub-solutions into
   lower bounds for the limit. We highlight that positivity of the smaller
   equilibrium is essential and that the law fails for general non-monotone maps.

### 1.3 Notation

$\mathbb{R}$ is the real line; $\mathrm{Icc}\,\ell\,h = [\ell, h]$ the closed
interval; $\exp$ and $\log$ are the real exponential and natural logarithm
(with $\log t$ defined only meaningfully for $t > 0$ here). The $n$-fold
iteration of $f$ from $x_0$ is written $x_n$ or $f^{n}(x_0)$.

---

## 2. The EML operator and its contraction theory

### 2.1 Core definitions

**Definition 1 (EML operator).**
For parameters $a, b, c \in \mathbb{R}$, the *exp-log operator* is
$$f_{a,b,c}(x) \;=\; e^{a}\,\log(b x + c).$$
When $b, c$ are fixed we write $f_a$.

**Definition 2 (Iteration sequence).**
Given a start $x_0$, the iteration sequence is
$$x_0,\qquad x_{n+1} = f_{a,b,c}(x_n).$$

**Definition 3 (Contraction data).**
An *EML contraction datum* is a tuple $D = (a, b, c, \ell, h, \rho)$ with
$\ell < h$, $0 \le \rho < 1$, and the three structural hypotheses:
- **(arg-pos)** $b x + c > 0$ for all $x \in [\ell, h]$;
- **(maps-to)** $f_{a,b,c}(x) \in [\ell, h]$ for all $x \in [\ell, h]$;
- **(deriv-bound)** $\left|\dfrac{e^{a} b}{b x + c}\right| \le \rho$ for all
  $x \in [\ell, h]$.

These three conditions package exactly what is needed for $f_a$ to be a
self-map and a $\rho$-contraction on $[\ell, h]$.

### 2.2 Derivative and fixed-point characterization

**Lemma 1 (Derivative formula).**
If $b x + c > 0$ then $f_{a,b,c}$ is differentiable at $x$ with
$$f_{a,b,c}'(x) \;=\; \frac{e^{a} b}{b x + c}.$$
*Sketch.* Chain rule: $\frac{d}{dx}\log(bx+c) = b/(bx+c)$, multiplied by the
constant $e^{a}$. $\square$

**Lemma 2 (Fixed-point equation).**
If $f_{a,b,c}(x^\*) = x^\*$ then $x^\* = e^{a}\log(b x^\* + c)$.
*Sketch.* This is the definition of the operator read at a fixed point. $\square$

**Lemma 3 (Positive fixed points exceed the log threshold).**
If $f_{a,b,c}(x^\*) = x^\*$ with $x^\* > 0$ and $b x^\* + c > 0$, then
$b x^\* + c > 1$.
*Sketch.* If instead $b x^\* + c \le 1$ then $\log(b x^\* + c) \le 0$, so
$x^\* = e^{a}\log(b x^\* + c) \le 0$ (as $e^a > 0$), contradicting $x^\* > 0$.
$\square$

Lemma 3 is the hinge of the comparative-statics argument: at a *positive*
equilibrium the logarithm term is strictly positive, which is exactly the sign
condition that makes a larger gain $e^{a}$ push the value up.

### 2.3 Contraction, uniqueness, convergence

**Lemma 4 (Lipschitz from a derivative bound).**
If $b x + c > 0$ on $[\ell, h]$ and $|e^{a} b/(b x + c)| \le \rho$ there, then
$$|f_{a,b,c}(x) - f_{a,b,c}(y)| \le \rho\,|x - y| \qquad \forall\, x, y \in [\ell, h].$$
*Sketch.* The interval is convex; apply the mean-value inequality
$\bigl|f(x)-f(y)\bigr| \le \bigl(\sup |f'|\bigr)|x-y|$ for a function whose
derivative within the interval is bounded by $\rho$. $\square$

**Theorem 1 (Uniqueness).**
With the data of Lemma 4 and $\rho < 1$, $f_{a,b,c}$ has at most one fixed point
in $[\ell, h]$.
*Sketch.* If $x_1, x_2$ are fixed points then
$|x_1 - x_2| = |f(x_1) - f(x_2)| \le \rho|x_1 - x_2|$, forcing
$(1-\rho)|x_1 - x_2| \le 0$, hence $x_1 = x_2$ since $\rho < 1$. $\square$

**Lemma 5 (Invariance of the orbit).**
If $x_0 \in [\ell, h]$ and **(maps-to)** holds, then $x_n \in [\ell, h]$ for all
$n$.
*Sketch.* Induction using **(maps-to)** at each step. $\square$

**Lemma 6 (Geometric decay of increments).**
For a contraction datum $D$ and $x_0 \in [\ell, h]$,
$$|x_{n+1} - x_n| \le \rho^{n}\,|x_1 - x_0|.$$
*Sketch.* Induction; each step applies Lemma 4 to consecutive (in-interval)
iterates, contributing one factor of $\rho$. $\square$

**Lemma 7 (Cauchy).**
The iteration is a Cauchy sequence.
*Sketch.* Lemma 6 gives a geometric majorant $\sum \rho^{n}|x_1-x_0| < \infty$
for the increments, so tails are arbitrarily small. $\square$

**Theorem 2 (Convergence to a fixed point).**
For a contraction datum $D$ and any $x_0 \in [\ell, h]$ there exists
$x^\* \in [\ell, h]$ with $x_n \to x^\*$ and $f_{a,b,c}(x^\*) = x^\*$.
*Sketch.* By Lemma 7 and completeness of $\mathbb{R}$ the limit $x^\*$ exists; it
lies in the closed interval $[\ell, h]$ by Lemma 5; continuity of $f_a$ on the
interval (Lemma 1) lets one pass to the limit in $x_{n+1} = f_a(x_n)$ to get
$x^\* = f_a(x^\*)$. $\square$

### 2.4 Certified rate and enclosure

**Theorem 3 (A priori error bound).**
If $x_n \to x^\*$ for a contraction datum then for all $n$,
$$|x_n - x^\*| \;\le\; |x_1 - x_0|\,\frac{\rho^{n}}{1 - \rho}.$$
*Sketch.* Sum the geometric tail of increments from Lemma 6 and pass to the
limit. $\square$

**Corollary 1 (Certified geometric convergence).**
The fixed point exists, the iteration converges to it, and the explicit bound of
Theorem 3 holds at every step. **Corollary 2.** That bound tends to $0$, so the
convergence is genuinely $O(\rho^{n})$.

When $b > 0$ the operator is additionally monotone (Lemma 8 below), which yields
a *two-sided* certificate.

**Lemma 8 (Monotonicity in the argument).**
If $b > 0$ and $b x + c > 0$ on $[\ell, h]$, then $f_{a,b,c}$ is monotone
increasing on $[\ell, h]$: $u \le v \Rightarrow f_a(u) \le f_a(v)$.
*Sketch.* $b u + c \le b v + c$, $\log$ is increasing, and $e^{a} > 0$. $\square$

**Lemma 9 / Lemma 10 (Bracketing orbits).**
Starting the iteration at $\ell$ gives an increasing lower orbit $\ell_n =
f^{n}(\ell)$; starting at $h$ gives a decreasing upper orbit $u_n = f^{n}(h)$.
*Sketch.* From **(maps-to)**, $\ell \le f(\ell)$ and $f(h) \le h$; propagate
through the monotone $f$ (Lemma 8) by induction. $\square$

**Theorem 4 (Certified two-sided enclosure).**
For a contraction datum with $b > 0$ there is a unique fixed point $x^\*$ with
$$\ell_n \le x^\* \le u_n \quad \forall n, \qquad \ell_n \uparrow x^\*, \quad u_n \downarrow x^\*, \qquad u_n - \ell_n \to 0.$$
*Sketch.* Both orbits converge (Theorem 2) to fixed points, which coincide by
uniqueness (Theorem 1); a monotone-induction squeeze gives $\ell_n \le x^\* \le
u_n$; the width $u_n - \ell_n \to x^\* - x^\* = 0$. $\square$

Thus at any finite step the pair $(\ell_n, u_n)$ is a rigorous interval
containing $x^\*$ — a self-validating certificate suitable for interval
arithmetic.

---

## 3. Comparative statics: monotone dependence on the scaling parameter

We now fix $b > 0$ and $c$, and view the scaling parameter $a$ as a control dial.
We compare two operators sharing $(b, c, \ell, h)$ at parameters $a_1 \le a_2$,
writing $f_{a_1}, f_{a_2}$. The contraction datum $D$ carries the larger
parameter $a_2 = D.a$.

### 3.1 Operator monotonicity in the parameter

**Lemma 11 (Weak parameter monotonicity of the operator).**
If $a_1 \le a_2$ and $\log(b x + c) \ge 0$, then
$f_{a_1}(x) \le f_{a_2}(x)$.
*Sketch.* $e^{a_1} \le e^{a_2}$ since $\exp$ is increasing; multiply the common
nonnegative factor $\log(b x + c) \ge 0$ on the right. $\square$

**Lemma 12 (Strict parameter monotonicity of the operator).**
If $a_1 < a_2$ and $\log(b x + c) > 0$, then $f_{a_1}(x) < f_{a_2}(x)$.
*Sketch.* $e^{a_1} < e^{a_2}$; multiply by the strictly positive factor
$\log(b x + c) > 0$. $\square$

The sign hypothesis $\log(bx+c) \ge 0$ (i.e. $bx + c \ge 1$) is precisely what
Lemma 3 supplies at a positive fixed point.

### 3.2 The monotone-iteration engine

**Lemma 13 (Sub-solutions launch increasing orbits).**
Let $D$ be a contraction datum with $b > 0$. If $p \in [\ell, h]$ is a
*sub-solution*, i.e. $p \le f_{D.a}(p)$, then the orbit $n \mapsto f_{D.a}^{n}(p)$
is monotone increasing.
*Sketch.* Show $x_n \le x_{n+1}$ by induction. The base case is the sub-solution
hypothesis $p \le f(p)$. For the step, apply operator monotonicity (Lemma 8) to
$x_{n} \le x_{n+1}$, using that iterates remain in $[\ell, h]$ (Lemma 5), to get
$f(x_n) \le f(x_{n+1})$, i.e. $x_{n+1} \le x_{n+2}$. $\square$

This is the discrete analogue of Tarski / monotone-iteration reasoning,
specialized to the EML contraction. It is the entire engine of what follows.

### 3.3 The comparative-statics law

**Theorem 5 (Weak comparative statics).**
Let $D$ be a contraction datum with $b > 0$ and $a_2 = D.a$. Suppose
$a_1 \le a_2$ and $x_1^\*$ is a fixed point of $f_{a_1}$ with $x_1^\* \in
[\ell, h]$ and $x_1^\* > 0$. Then $f_{a_2}$ has a fixed point $x_2^\* \in
[\ell, h]$ with
$$x_1^\* \;\le\; x_2^\*.$$
*Proof sketch.*
1. **Positivity activates the sign condition.** Since $x_1^\*$ is a positive
   fixed point of $f_{a_1}$ with $b x_1^\* + c > 0$ (arg-pos), Lemma 3 gives
   $b x_1^\* + c > 1$, hence $\log(b x_1^\* + c) > 0$, in particular $\ge 0$.
2. **$x_1^\*$ is a sub-solution of the larger operator.** By Lemma 11 with the
   sign condition,
   $$f_{a_2}(x_1^\*) \;\ge\; f_{a_1}(x_1^\*) \;=\; x_1^\*,$$
   the equality because $x_1^\*$ is a fixed point of $f_{a_1}$.
3. **The larger orbit climbs.** By Lemma 13 the orbit of $f_{a_2}$ from $x_1^\*$
   is increasing; by Theorem 2 it converges to a fixed point $x_2^\* \in
   [\ell, h]$ of $f_{a_2}$.
4. **The limit dominates the start.** A monotone-increasing sequence lies below
   its limit, so $x_1^\* = $ (term $0$) $\le x_2^\*$. $\square$

**Theorem 6 (Strict comparative statics).**
Under the hypotheses of Theorem 5 but with $a_1 < a_2$, the fixed point of
$f_{a_2}$ satisfies
$$x_1^\* \;<\; x_2^\*.$$
*Proof sketch.* By Theorem 1 the operator $f_{a_2}$ has a *unique* fixed point
$x_2^\*$ in $[\ell, h]$; Theorem 5 gives $x_1^\* \le x_2^\*$, so it remains to
exclude equality. If $x_1^\* = x_2^\*$ then $x_1^\*$ would be a fixed point of
both operators, giving simultaneously $x_1^\* = e^{a_1}\log(bx_1^\*+c)$ and
$x_1^\* = e^{a_2}\log(b x_1^\* + c)$ with $\log(b x_1^\* + c) > 0$ (step 1 of
Theorem 5) and $e^{a_1} < e^{a_2}$ — a contradiction, since the same positive
quantity cannot equal two different positive multiples of $\log(bx_1^\*+c)$.
Hence $x_1^\* < x_2^\*$. $\square$

**Theorem 7 (Uniqueness-strengthened comparative statics).**
Under contraction, the larger operator's fixed point is unique, so *every* fixed
point $x_2^\*$ of $f_{D.a}$ in $[\ell, h]$ dominates the smaller parameter's
positive fixed point: $x_1^\* \le x_2^\*$ (strictly if $a_1 < D.a$).
*Proof sketch.* Combine Theorem 5/6 with the uniqueness of Theorem 1: any fixed
point of $f_{D.a}$ in $[\ell, h]$ equals the one produced by the monotone
iteration, hence inherits the inequality. $\square$

### 3.4 Why the hypotheses are exactly right

- **Positivity of $x_1^\*$ is load-bearing.** Without it the log term
  $\log(b x_1^\* + c)$ could be negative, reversing Lemma 11 and hence the
  sub-solution inequality $f_{a_2}(x_1^\*) \ge x_1^\*$. The conclusion would fail.
- **$b > 0$ is essential.** It is what makes $f_a$ monotone (Lemma 8) and
  therefore makes Lemma 13 (sub-solutions launch increasing orbits) valid. The
  law genuinely uses monotonicity; it is false for general non-monotone maps.
- **Strictness is not vacuous.** It is witnessed by the strictly upward first
  step $f_{a_2}(x_1^\*) > x_1^\*$, made strict by Lemma 12.

### 3.5 Consequence: an injective control

Because $a \mapsto x^\*(a)$ is strictly increasing on the parameter range where a
positive equilibrium exists, it is **injective**: distinct admissible scaling
parameters produce distinct equilibria. Combined with the certified rate
(Theorem 3) and enclosure (Theorem 4), this means an EML iterative scheme can be
tuned with a provable, overshoot-free response — nudging $a$ upward continuously
and monotonically raises the converged output, never crossing into a different
basin.

---

## 4. A concrete instance

Take $b = 1$, $c = 2$, so $f_a(x) = e^{a}\log(x + 2)$.

**Proposition 1 (Existence of a positive equilibrium for small gain).**
For every $a$ with $0 < a < \tfrac12$ there is $x^\* > 0$ with
$e^{a}\log(x^\* + 2) = x^\*$.
*Proof sketch.* Consider $g(x) = e^{a}\log(x+2) - x$ on $[1, 3]$. At $x = 1$,
$g(1) = e^{a}\log 3 - 1 > 0$ because $\log 3 > 1$ and $e^{a} > 1$. At $x = 3$,
$g(3) = e^{a}\log 5 - 3 < 0$ because $e^{1/2}\log 5 < 3$ (using
$e^{1/2} < 1.7$ and $\log 5 < 1.7$, so the product is below $2.89 < 3$). By the
intermediate value theorem $g$ vanishes at some $x^\* \in (1, 3)$, which is the
required positive fixed point. $\square$

This instance has $b = 1 > 0$ and a derivative $f_a'(x) = e^{a}/(x+2)$ that, near
the equilibria of the table below, stays well under $1$, so all of §2–§3 apply.
The comparative-statics law predicts a strictly increasing column of equilibria
as $a$ rises, which the numerics confirm:

| $a$ | $x^\*(a)$ | $f_a'(x^\*)$ |
|---|---|---|
| $0.00$ | $1.1462$ | $0.318$ |
| $0.10$ | $1.3292$ | $0.332$ |
| $0.30$ | $1.8032$ | $0.355$ |
| $0.49$ | $2.4293$ | $0.369$ |

Each increase in $a$ strictly raises $x^\*$, and the contraction ratio remains
below one throughout, certifying convergence at every setting.

---

## 5. Algorithms

### 5.1 Banach iteration with certified a priori error

Given a contraction datum and a target tolerance $\varepsilon$, iterate
$x_{n+1} = f_a(x_n)$ until the a priori bound
$|x_1 - x_0|\,\rho^{n}/(1-\rho) \le \varepsilon$ (Theorem 3) guarantees
$|x_n - x^\*| \le \varepsilon$. The required step count is
$n \ge \log\!\bigl(\varepsilon (1-\rho)/|x_1 - x_0|\bigr)/\log \rho$.

### 5.2 Two-sided certified bracketing

When $b > 0$, run two orbits from $\ell$ and $h$ in parallel. After each step the
pair $(\ell_n, u_n)$ is a rigorous enclosure of $x^\*$ (Theorem 4); stop when
$u_n - \ell_n \le \varepsilon$. This needs no knowledge of $\rho$ to validate the
output: the bracket *is* the certificate.

### 5.3 Monotone-response parameter sweep

To map the control curve $a \mapsto x^\*(a)$, sweep $a$ upward and *warm-start*
each solve from the previous equilibrium. By Theorem 5, the previous (smaller-$a$)
equilibrium is a sub-solution for the next operator, so the warm-started orbit
increases monotonically to the new equilibrium — a provably correct and
efficient continuation method.

---

## 6. Applications

- **Tunable iterative components.** Any pipeline that places an output by solving
  $x = f_a(x)$ gets a monotone, injective tuning knob with a certified response.
- **Verified numerics.** The two-sided enclosure (Theorem 4) yields
  interval-arithmetic-ready certificates for the equilibrium.
- **Continuation / homotopy.** The warm-start sweep (§5.3) is justified rigorously
  by the sub-solution principle, avoiding wasted iterations as parameters vary.
- **Stability-aware design.** Knowing the equilibrium moves monotonically with
  $a$ lets a designer choose $a$ to hit a target output without risk of jumping
  basins, provided the contraction condition $|f_a'| \le \rho < 1$ is maintained.

---

## 7. Discussion

The comparative-statics law is striking for what it does *not* require. There is
no differentiation of the fixed point with respect to the parameter, no implicit
function theorem, no local linearization. The argument is purely order-theoretic:
a fixed point of the smaller operator is a sub-solution of the larger one
(because a larger gain multiplies a positive log term to a larger value), and in
a monotone contraction every sub-solution lies below the limit of its own
increasing orbit, which is the larger operator's unique fixed point. This is
robust, elementary, and exactly as strong as it should be — it is false without
monotonicity ($b > 0$) and false without positivity of the equilibrium, both of
which the proof genuinely consumes.

The result also clarifies the qualitative *type* of the EML control. It is not
merely that the equilibrium depends continuously on $a$; it depends
*monotonically* and *strictly*, hence *injectively*. For an engineered component
this is the difference between a usable dial and an unpredictable one.

---

## 8. Future directions

The qualitative monotonicity established here invites several quantitative and
structural refinements (stated in full in the package's future-directions
record):

1. **Joint strict monotonicity in $(a, c)$.** Increasing the shift $c$ also
   strictly raises the equilibrium by the same sub-solution principle, so the map
   $(a, c) \mapsto x^\*(a, c)$ should be jointly strictly monotone and the induced
   order embedding injective — the two effects never cancel.
2. **Lipschitz sensitivity.** On a compact admissible parameter box,
   $|x^\*(a_2, c_2) - x^\*(a_1, c_1)| \le L_a|a_2 - a_1| + L_c|c_2 - c_1|$ with
   explicit $L_a, L_c$ obtained from the geometric series $\sum \rho^{n}$ that the
   contraction already supplies; informally $L = (\partial f/\partial \text{param})/(1-\rho)$.
3. **Differentiability and a verified power series.** Since $1 - f'(x^\*) \ge
   1 - \rho > 0$, the linearization is uniformly invertible and $x^\*(a)$ should be
   real-analytic with $dx^\*/da = x^\*/(1 - e^{a} b/(b x^\* + c))$ and recursively
   computable Taylor coefficients.
4. **Failure past the contraction threshold.** Outside the regime
   $|f'(x^\*)| < 1$ the comparative-statics law can fail: a repelling fixed point
   may not move monotonically with $a$, because the sub-solution argument requires
   the contraction (and monotonicity) structure to convert sub-solutions into
   lower bounds for the limit.

---

## 9. Conclusion

The exp-log operator $f_a(x) = e^{a}\log(b x + c)$ is, under the standard
contraction conditions, a model dynamical citizen: it has a unique equilibrium,
its iteration converges geometrically with a certified a priori bound, and (for
$b > 0$) it admits a two-sided self-validating enclosure. To this we have added
the parametric law that makes it genuinely tunable — the equilibrium is a strictly
increasing, hence injective, function of the scaling parameter $a$, proved by an
elementary sub-solution / monotone-iteration argument whose hypotheses (monotone
$b > 0$, positive equilibrium) are exactly load-bearing. The scaling dial of an
EML scheme is therefore an honest control: turn it up and the equilibrium rises,
predictably and without basin-hopping.
