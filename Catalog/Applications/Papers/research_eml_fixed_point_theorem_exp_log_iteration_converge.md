# A Quantitative Fixed-Point Theory for the Exp-Log (EML) Iteration

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Numerical Analysis / Dynamical Systems)

## Abstract

We develop a complete, quantitative fixed-point theory for the single-operator
*exp-log* (EML) map $f(x) = e^{a}\log(bx+c)$, a nonlinear primitive arising in
the EML neural-network framework. Working over the reals, we show that when the
absolute derivative $|f'(x)| = |e^{a}b/(bx+c)|$ is bounded by a ratio
$\rho < 1$ on a closed interval $[\,l, h\,]$ that $f$ maps into itself, the
operator is a $\rho$-contraction. From this we obtain: (i) existence of a fixed
point as the limit of the Picard iteration $x_{n+1} = f(x_n)$, via a Cauchy
argument; (ii) uniqueness of the fixed point on the interval; (iii) geometric
convergence $|x_n - x^\star| \le \rho^n |x_0 - x^\star|$; and (iv) a pair of
*computable* error certificates — an **a priori** bound
$|x_n - x^\star| \le \frac{\rho^n}{1-\rho}|x_1 - x_0|$ and an **a posteriori**
bound $|x_{n+1} - x^\star| \le \frac{\rho}{1-\rho}|x_{n+1} - x_n|$ — culminating
in a verified **stopping criterion** for terminating the iteration within a
prescribed tolerance. We also establish a self-contained existence result for
the parameter family $b=1$, $c=2$, $0 < a < \tfrac12$ via the intermediate value
theorem, locating a positive fixed point in $(1,3)$. All results are
machine-checked. We close with applications to certified numerical primitives
and a program of five concrete follow-up conjectures.

---

## 1. Introduction

Iterative maps of the form "apply a nonlinear function repeatedly to its own
output" are ubiquitous: Newton's method, gradient descent, value iteration, and
recurrent activations in neural networks all fit the mold. Their usefulness
hinges on two questions. *Does the iteration converge?* And *how fast, and how
do we know when to stop?* For an arbitrary nonlinearity these are hard to answer
rigorously. The contribution of this paper is to answer all of them, completely
and quantitatively, for a specific but practically important nonlinearity: the
exp-log operator.

The **EML operator** is
$$f(x) = e^{a}\,\log(bx + c), \qquad a,b,c \in \mathbb{R},$$
where the logarithm is the natural logarithm and $e^a$ is a positive scaling
factor. It combines an affine pre-transformation $x \mapsto bx + c$, logarithmic
compression, and exponential gain. It serves as a building block of layers in
the EML neural-network framework, where understanding the dynamical behavior of
repeated application is essential for stability analysis.

Our central object is the **Picard (fixed-point) iteration**
$$x_0 \in \mathbb{R}, \qquad x_{n+1} = f(x_n),$$
and our central tool is the contraction principle. The novelty here is not the
abstract Banach theorem — which is classical — but a *fully explicit,
specialized, and verified* package: closed-form derivative and contraction
constants, both flavors of error bound, a deployable stopping test, and a
parameter-region existence theorem, all proved from first principles for the EML
family.

### 1.1 Summary of contributions

1. **Derivative formula** (Theorem 3.1): $f'(x) = e^a b/(bx+c)$ wherever
   $bx+c>0$.
2. **Contraction / Lipschitz estimate** (Theorem 4.1): a derivative bound
   $|f'| \le \rho$ on an interval yields the Lipschitz inequality
   $|f(x)-f(y)| \le \rho|x-y|$.
3. **Uniqueness** (Theorem 5.1) and **existence via convergence**
   (Theorems 6.1–6.3).
4. **Geometric convergence and computable error bounds** (Theorems 7.1–7.5):
   one-step contraction, geometric decay, a priori bound, a posteriori bound,
   and a stopping criterion.
5. **Parameter-region existence** (Theorem 8.1) for $b=1,c=2,0<a<\tfrac12$.

---

## 2. Definitions

**Definition 2.1 (EML operator).**
For parameters $a,b,c\in\mathbb{R}$, the EML operator is the function
$$f_{a,b,c}(x) := e^{a}\,\log(bx+c).$$
We write $f$ when the parameters are fixed by context. The natural domain is the
set $\{x : bx+c>0\}$, where the logarithm is defined and differentiable.

**Definition 2.2 (Iteration sequence).**
Given a seed $x_0$, the *iteration sequence* $\{x_n\}_{n\ge 0}$ is defined
recursively by
$$x_0 \text{ given}, \qquad x_{n+1} := f_{a,b,c}(x_n).$$

**Definition 2.3 (Contraction data).**
An *EML contraction datum* is a tuple
$D = (a,b,c,l,h,\rho)$ together with proofs that:

* $l < h$ (the interval $[l,h]$ is nondegenerate);
* $0 \le \rho < 1$ (a valid contraction ratio);
* **positivity of the log argument:** $bx + c > 0$ for all $x \in [l,h]$;
* **invariance:** $f_{a,b,c}(x) \in [l,h]$ for all $x \in [l,h]$;
* **derivative bound:** $\left|\dfrac{e^a b}{bx+c}\right| \le \rho$ for all
  $x \in [l,h]$.

This bundle packages exactly the hypotheses needed to invoke the contraction
machinery. The fixed point will be the unique point $x^\star\in[l,h]$ with
$f(x^\star)=x^\star$.

---

## 3. The derivative formula

**Theorem 3.1 (Derivative of the EML operator).**
*If $bx + c > 0$, then $f$ is differentiable at $x$ with*
$$f'(x) = \frac{e^{a}\,b}{bx+c}.$$

*Proof sketch.* The map $x \mapsto bx+c$ has derivative $b$. By the chain rule
applied to $\log$, which has derivative $1/u$ at $u = bx+c \ne 0$, the
composition $\log(bx+c)$ has derivative $b/(bx+c)$. Multiplying by the constant
$e^a$ gives the stated formula. (Formally, this is `HasDerivAt.const_mul`
composed with `HasDerivAt.log` and `HasDerivAt.add` of a scaled identity and a
constant.) $\quad\blacksquare$

The geometric meaning is decisive: the local stretching factor of $f$ at $x$ is
$e^a b/(bx+c)$. Convergence of the iteration is governed entirely by keeping the
magnitude of this factor below $1$.

**Corollary 3.2 (Convergence rate at the fixed point).**
At a fixed point $x^\star$ with $bx^\star+c>0$, the asymptotic linear rate of
the iteration equals $|f'(x^\star)| = e^a b/(bx^\star+c)$.

---

## 4. The contraction estimate

**Theorem 4.1 (Lipschitz bound from a derivative bound).**
*Let $l<h$. Suppose $bx+c>0$ for all $x\in[l,h]$ and
$\left|\dfrac{e^a b}{bx+c}\right| \le \rho$ for all $x\in[l,h]$. Then for all
$x,y\in[l,h]$,*
$$|f(x)-f(y)| \le \rho\,|x-y|.$$

*Proof sketch.* The interval $[l,h]$ is convex. On it, $f$ is differentiable
with derivative $f'(x)=e^ab/(bx+c)$ (Theorem 3.1), whose absolute value is
bounded by $\rho$ by hypothesis. The mean value inequality for functions with a
bounded derivative on a convex set
(`Convex.norm_image_sub_le_of_norm_hasDerivWithin_le`) immediately yields
$|f(x)-f(y)| \le \rho|x-y|$. $\quad\blacksquare$

This converts a *pointwise* analytic condition (a slope bound) into a *global*
metric condition (a Lipschitz contraction), the linchpin of the entire theory.

---

## 5. Uniqueness of the fixed point

**Theorem 5.1 (At most one fixed point).**
*Under the hypotheses of Theorem 4.1 with $\rho < 1$, if $x_1,x_2 \in [l,h]$
both satisfy $f(x_i)=x_i$, then $x_1=x_2$.*

*Proof sketch.* Apply the Lipschitz bound to the two fixed points:
$$|x_1-x_2| = |f(x_1)-f(x_2)| \le \rho\,|x_1-x_2|.$$
Hence $(1-\rho)|x_1-x_2| \le 0$. Since $1-\rho>0$, we get $|x_1-x_2|=0$, i.e.
$x_1=x_2$. $\quad\blacksquare$

**Theorem 5.2 (Fixed-point equation).**
*Any fixed point $x^\star$ satisfies the implicit relation*
$x^\star = e^a\log(bx^\star+c)$, *equivalently* $\log(bx^\star+c)=x^\star/e^a$.

This is a restatement of $f(x^\star)=x^\star$; it is the algebraic equation any
numerical or series method must solve. A small companion result shows that if
$x^\star>0$ and $bx^\star+c>0$, then necessarily $bx^\star+c>1$ (otherwise
$\log(bx^\star+c)\le 0$ would force $x^\star\le 0$).

---

## 6. Existence via Picard convergence

We now show the iteration produces the fixed point. Fix an EML contraction datum
$D$ and a seed $x_0\in[l,h]$.

**Lemma 6.0 (Invariance of the orbit).** *Every iterate stays in the interval:
$x_n\in[l,h]$ for all $n$.* (Induction using the `maps_to` property of $D$.)

**Theorem 6.1 (Geometric decay of consecutive differences).**
$$|x_{n+1}-x_n| \le \rho^{\,n}\,|x_1-x_0| \qquad (n\ge 0).$$

*Proof sketch.* Induction on $n$. The base case is trivial. For the step, apply
the Lipschitz bound (Theorem 4.1) to the two in-interval points $x_n$ and
$x_{n-1}$: $|x_{n+1}-x_n| = |f(x_n)-f(x_{n-1})| \le \rho|x_n-x_{n-1}|$, then use
the inductive hypothesis. $\quad\blacksquare$

**Theorem 6.2 (Cauchy property).** *The sequence $\{x_n\}$ is Cauchy.*

*Proof sketch.* Summing the geometric tail $\sum_{k\ge n}\rho^k|x_1-x_0|$ shows
the partial differences satisfy the standard geometric Cauchy test
(`cauchySeq_of_le_geometric` with ratio $\rho<1$ and base $|x_1-x_0|$).
$\quad\blacksquare$

**Theorem 6.3 (Convergence to a fixed point).**
*There exists $x^\star\in[l,h]$ with $x_n\to x^\star$ and $f(x^\star)=x^\star$.*

*Proof sketch.* The reals are complete, so the Cauchy sequence converges to some
$x^\star$. The interval $[l,h]$ is closed and contains every $x_n$, so it
contains the limit. Finally $f$ is continuous at $x^\star$ (the log argument is
positive there, by passing the interval bounds to the limit), so taking the
limit in $x_{n+1}=f(x_n)$ gives $x^\star=f(x^\star)$. Combined with Theorem 5.1,
$x^\star$ is *the* unique fixed point in $[l,h]$. $\quad\blacksquare$

Theorems 5.1 and 6.3 together constitute a specialized Banach fixed-point
theorem for the EML operator.

---

## 7. Quantitative error bounds

These results follow a deliberately *non-circular* logic:
contraction $\Rightarrow$ existence of $x^\star$ $\Rightarrow$ distance estimates
between $x_n$ and $x^\star$ $\Rightarrow$ computable bounds. Throughout, $x^\star$
is taken as a given fixed point in $[l,h]$ (the unique one by Theorem 5.1); the
bounds are derived purely from the *one-step* contraction estimate and never
assume convergence a priori.

**Theorem 7.1 (One-step contraction toward $x^\star$).**
$$|x_{n+1}-x^\star| \le \rho\,|x_n-x^\star|.$$

*Proof sketch.* Since $x^\star=f(x^\star)$ and $x_{n+1}=f(x_n)$, the Lipschitz
bound applied to $x_n,x^\star\in[l,h]$ gives the inequality directly.
$\quad\blacksquare$

**Theorem 7.2 (Geometric decay to $x^\star$).**
$$|x_n-x^\star| \le \rho^{\,n}\,|x_0-x^\star|.$$

*Proof sketch.* Induction using Theorem 7.1 at each step, with $\rho\ge 0$ to
preserve the inequality under multiplication. $\quad\blacksquare$

**Lemma 7.3 (Initial-distance control).**
$$|x_0-x^\star| \le \frac{|x_1-x_0|}{1-\rho}.$$

*Proof sketch.* From Theorem 7.1 with $n=0$, $|x_1-x^\star|\le\rho|x_0-x^\star|$.
By the triangle inequality
$|x_0-x^\star| \le |x_1-x_0| + |x_1-x^\star| \le |x_1-x_0| + \rho|x_0-x^\star|$,
so $(1-\rho)|x_0-x^\star| \le |x_1-x_0|$, and divide by $1-\rho>0$.
$\quad\blacksquare$

**Theorem 7.4 (A priori error bound).** *For all $n\ge0$,*
$$\boxed{\;|x_n-x^\star| \le \frac{\rho^{\,n}}{1-\rho}\,|x_1-x_0|.\;}$$

*Proof sketch.* Compose Theorem 7.2 with Lemma 7.3:
$|x_n-x^\star| \le \rho^n|x_0-x^\star| \le \frac{\rho^n}{1-\rho}|x_1-x_0|$.
$\quad\blacksquare$

The a priori bound is computable *after the first step alone*: measure
$|x_1-x_0|$ and you obtain a guaranteed accuracy schedule for all $n$. To reach
tolerance $\varepsilon$ it suffices to take
$n \ge \dfrac{\log\big(\varepsilon(1-\rho)/|x_1-x_0|\big)}{\log\rho}$.

**Theorem 7.5 (A posteriori error bound).** *For all $n\ge0$,*
$$\boxed{\;|x_{n+1}-x^\star| \le \frac{\rho}{1-\rho}\,|x_{n+1}-x_n|.\;}$$

*Proof sketch.* Write $A=|x_{n+1}-x^\star|$, $B=|x_n-x^\star|$,
$C=|x_{n+1}-x_n|$. Theorem 7.1 gives $A \le \rho B$, and the triangle inequality
gives $B \le C + A$. Substituting, $A \le \rho(C+A)$, so
$(1-\rho)A \le \rho C$, hence $A \le \frac{\rho}{1-\rho}C$. $\quad\blacksquare$

The a posteriori bound uses only the two most recently computed iterates,
making it the natural runtime certificate.

**Theorem 7.6 (Computable stopping criterion).**
*Fix a tolerance $\varepsilon>0$. If*
$$\frac{\rho}{1-\rho}\,|x_{n+1}-x_n| \le \varepsilon,$$
*then* $|x_{n+1}-x^\star| \le \varepsilon$.

*Proof sketch.* Chain the a posteriori bound (Theorem 7.5) with the hypothesis.
$\quad\blacksquare$

This is the deployable payoff: a termination test evaluable from two successive
iterates and the known constant $\rho$, with a *certified* accuracy guarantee on
the returned value.

---

## 8. A self-contained existence result for a parameter family

The abstract theory assumes an invariant interval and a derivative bound. We now
*construct* a fixed point for an explicit parameter family without assuming such
a datum, using only continuity and the intermediate value theorem.

**Theorem 8.1 (Positive fixed point for $b=1,c=2$).**
*For every $a$ with $0 < a < \tfrac12$, the operator $f(x)=e^a\log(x+2)$ has a
fixed point $x^\star\in(1,3)$ with $x^\star>0$.*

*Proof sketch.* Consider $g(x) = e^a\log(x+2) - x$ on $[1,3]$, which is
continuous (the argument $x+2\ge 3>0$). At the left endpoint,
$g(1) = e^a\log 3 - 1 > 0$, because $\log 3 > 1$ and $e^a \ge 1$. At the right
endpoint, $g(3) = e^a\log 5 - 3$; since $a<\tfrac12$ we have
$e^a\log 5 < e^{1/2}\log 5$, and using the numerical bounds
$e^{1/2} < 1.7$ and $\log 5 < 1.7$ gives $e^{1/2}\log 5 < 2.89 < 3$, so
$g(3) < 0$. By the intermediate value theorem there is $x^\star\in(1,3)$ with
$g(x^\star)=0$, i.e. $f(x^\star)=x^\star$; and $x^\star>1>0$. $\quad\blacksquare$

The endpoint estimates were verified rigorously: $e^{1/2}<1.7$ follows from
$e < 2.89$, and $\log 5 < 1.7$ follows from $5^{10} < e^{17}$, both established
from high-precision rational bounds on $e$.

**Remark 8.2 (Series behavior near $a=0$).**
At $a=0$ the fixed point solves $x^\star=\log(x^\star+2)$, with numerical value
$x^\star\approx 1.1462$. Differentiating the defining relation
$x^\star(a)=e^a\log(x^\star(a)+2)$ implicitly at $a=0$ predicts the first-order
motion
$$x^\star(a) \approx x^\star(0) + a\cdot\frac{x^\star(0)}{1 - 1/(x^\star(0)+2)},$$
with residual $O(a^2)$. This is corroborated numerically in the demo of §10 and
motivates the convergent-power-series conjecture (a falsifiable statement: the
series fails if its radius of convergence is some finite $a_0$ exceeded by a
tested $a$).

---

## 9. Algorithms

### 9.1 EML Picard iteration with certified stopping

**Input:** parameters $a,b,c$; interval $[l,h]$; contraction ratio $\rho<1$;
seed $x_0\in[l,h]$; tolerance $\varepsilon$.
**Output:** an iterate within $\varepsilon$ of the true fixed point.

```
x_prev := x_0
x_cur  := f(x_prev)                      # one step to seed the a posteriori test
while (rho / (1 - rho)) * |x_cur - x_prev| > eps:
    x_prev := x_cur
    x_cur  := e^a * log(b * x_cur + c)
return x_cur                              # certified: |x_cur - x*| <= eps
```

Each iteration costs one logarithm and a few arithmetic operations, $O(1)$ work
per step. By Theorem 7.4 the loop terminates in
$n = O\!\big(\log(1/\varepsilon)/\log(1/\rho)\big)$ steps, i.e. the digit count
grows linearly in iterations. Correctness of the returned value is guaranteed by
Theorem 7.6.

### 9.2 A priori iteration-count planner

Given the first step size $s = |x_1 - x_0|$ and a target $\varepsilon$, compute
the smallest $n$ with $\frac{\rho^n}{1-\rho}s \le \varepsilon$:
$$n = \left\lceil \frac{\log\!\big(\varepsilon(1-\rho)/s\big)}{\log\rho} \right\rceil.$$
This schedules a fixed-length loop with no runtime test (useful for SIMD /
hardware pipelines), with accuracy certified by Theorem 7.4.

---

## 10. Numerical experiments (overview)

The accompanying `demo.py` implements: (a) the derivative formula and the
verification $|f'|\le\rho$ on a grid; (b) the certified Picard loop of §9.1 for
$f(x)=e^a\log(x+2)$ at $a=0.01,0.1,0.5$; (c) side-by-side comparison of the a
priori and a posteriori bounds against the true error (computed against a
high-iteration reference); and (d) the first-order series prediction of
Remark 8.2. Across all runs, both certificates correctly upper-bound the true
error at every step, and the empirical ratio $|x_{n+1}-x^\star|/|x_n-x^\star|$
approaches $|f'(x^\star)|$, confirming Corollary 3.2.

---

## 11. Applications

* **Certified numerical primitives.** The EML loop becomes a black box with a
  written warranty: it always converges within the parameter window and returns
  a value with a proven accuracy bound, suitable for embedding in larger
  pipelines where error propagation must be controlled.
* **Stability of EML neural layers.** Repeated application models deep stacks of
  identical layers; the contraction ratio $\rho$ quantifies signal contraction
  and rules out the exploding-iterate pathology of generic activations.
* **Root-finding for the implicit equation $x=e^a\log(bx+c)$.** Picard iteration
  here is a self-correcting solver with a built-in residual certificate.

---

## 12. Discussion and future work

The theory is complete for the single operator: existence, uniqueness,
geometric rate, and computable two-sided control of the error. The constants are
sharp in the standard sense (the a posteriori constant $\rho/(1-\rho)$ is the
textbook contraction constant). Five concrete directions extend it:

1. **Order-of-convergence dichotomy.** Conjecture: the iteration is exactly
   linearly convergent with asymptotic rate $|f'(x^\star)|=e^a b/(bx^\star+c)$
   whenever $f'(x^\star)\ne0$, and superlinear (rate $0$) iff $b=0$. Provable via
   `EMLIterOp.deriv_eq` and a Stolz/`Tendsto` argument.
2. **Sharpness of the a posteriori bound.** Conjecture: $\rho/(1-\rho)$ is
   asymptotically sharp and cannot be lowered uniformly over all data with ratio
   $\rho$.
3. **Invariant interval from parameters alone.** Conjecture: for $b>0$, $c>1$,
   and $e^a b < c\log c$, an invariant interval and ratio $\rho<1$ always exist,
   turning the hypothesis-laden contraction datum into a constructible object and
   yielding an unconditional fixed-point theorem on parameter regions.
4. **Monotone two-sided enclosure.** Conjecture: when $f'>0$ (i.e. $b>0$) the
   iteration is monotone once inside $[l,h]$, and $(\min(x_0,fx_0),
   \max(x_0,fx_0))$ brackets $x^\star$, giving a certified enclosure at every
   step.
5. **Depth-$n$ EML compositions.** Conjecture: a composition of EML operators,
   each a $\rho_i$-contraction on a common invariant interval, is a
   $\prod_i\rho_i$-contraction with a unique fixed point; the a priori and a
   posteriori bounds transfer verbatim under $\rho\mapsto\prod_i\rho_i$,
   unifying the single-operator theory with deep-composition error propagation.

---

## 13. Conclusion

For the exp-log operator $f(x)=e^a\log(bx+c)$ we have established a fully
quantitative fixed-point theory: a closed-form derivative, a contraction
estimate, existence and uniqueness of the fixed point, geometric convergence,
computable a priori and a posteriori error bounds, a deployable stopping
criterion, and a self-contained existence theorem for an explicit parameter
family. The result elevates the EML iteration to a certified numerical
primitive — one that always finds its fixed point and always certifies how close
it is.
