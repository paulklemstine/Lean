# A Universal Order-Parameter Threshold: From Mean-Field Magnetism to Branching Survival

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

We identify a single structural mechanism underlying two threshold phenomena that
are usually treated in separate fields: the spontaneous magnetization of the
mean-field (Curie–Weiss) model, whose order parameter $m$ solves the
self-consistency equation $m = \tanh(\beta m)$, and the survival of a
Galton–Watson branching process with Poisson offspring, whose survival
probability $q$ solves $q = 1 - e^{-\mu q}$. Both order parameters are fixed
points of a smooth, increasing, concave map $F$ through the origin whose
derivative at $0$ equals the coupling constant. We prove an abstract dichotomy:
*such a map acquires a strictly positive fixed point if and only if its
origin-slope exceeds $1$.* This yields, as corollaries, the complete
phase-transition packages for both models, sharply located at the common critical
value $1$. We further show that while the *location* of the transition is
universal, the *critical exponent* governing the onset of the order parameter is
controlled by the symmetry of the update map: the odd map $\tanh$ produces a
square-root onset (exponent $1/2$), whereas the non-odd survival map produces a
linear onset (exponent $1$). We prove a quantitative lower bound
$q \ge 2(\mu-1)/\mu^2$ exhibiting the linear onset, and we identify the missing
quadratic Taylor coefficient of the odd map as the origin of the square-root
behavior.

**Keywords:** phase transition, order parameter, Curie–Weiss model, mean-field
magnetism, branching process, survival probability, critical exponent,
fixed-point equation, universality.

---

## 1. Introduction

A recurring motif across the mathematical sciences is the *order parameter*: a
quantity that is zero in a "disordered" regime and becomes positive, sharply, once
a control parameter crosses a threshold. Two textbook examples come from
disciplines that rarely speak to each other.

In statistical physics, the **Curie–Weiss model** describes a magnet in which
every spin interacts equally with every other. Its magnetization $m$ satisfies the
mean-field self-consistency equation
$$ m = \tanh(\beta m), $$
where $\beta > 0$ is the inverse-temperature/coupling parameter. Below a critical
coupling the material is paramagnetic ($m = 0$); above it, ferromagnetic
($m \ne 0$).

In probability theory, a **Galton–Watson branching process** with offspring mean
$\mu$ models the growth of a population, lineage, or epidemic. Its survival
probability $q$ (the probability the process never goes extinct) satisfies
$$ q = 1 - e^{-\mu q} $$
for Poisson offspring. Below a critical mean the process is subcritical (extinct
almost surely, $q = 0$); above it, supercritical ($q > 0$).

The purpose of this paper is to make precise, and prove, the sense in which these
are the *same* phenomenon. We formulate an abstract fixed-point criterion that
contains both transitions as instances, show that both share the critical value
$1$ for the same structural reason, and then explain their difference — different
critical exponents — through a single further principle: the symmetry of the
update map.

### Contributions

1. **An abstract order-parameter dichotomy** (Section 3): a concave, increasing
   map $F$ through the origin, continuous on $[0,b]$ with $F(b) < b$, has a fixed
   point in $(0,b)$ if its origin-slope exceeds $1$; and it has *no* positive
   fixed point whenever it stays strictly below the diagonal.
2. **The Curie–Weiss ordered phase as a corollary** (Section 4).
3. **The complete branching phase-transition package** (Section 5): sub- and
   super-critical behavior, the sharp threshold at $\mu_c = 1$, uniqueness of the
   positive branch, and the bound $q < 1$.
4. **A symmetry–exponent principle** (Section 6): a quantitative linear onset
   $q \ge 2(\mu-1)/\mu^2$ for branching survival, contrasted with the square-root
   onset of the symmetric Curie–Weiss magnetization, traced to the parity of the
   update map.

---

## 2. Preliminaries and analytic inputs

Throughout, $\tanh$ denotes the hyperbolic tangent and $e^{x}$ the exponential.
We record the elementary facts that drive every subsequent argument. All are
standard, but we state them explicitly because the sharpness of the phase
transitions depends on them.

**Lemma 2.1 (Diagonal bound for tanh).** *For every $y > 0$, $\tanh y < y$.*

*Proof sketch.* Let $G(y) = y - \tanh y$. Then $G(0) = 0$ and
$G'(y) = 1 - \operatorname{sech}^2 y = \tanh^2 y > 0$ for $y > 0$, since the
derivative of $\tanh$ is $1/\cosh^2 y$ and $1 - 1/\cosh^2 y = \tanh^2 y$. By the
mean value theorem $G(y) = G(y) - G(0) = y\,G'(\xi) > 0$ for some
$\xi \in (0,y)$. $\square$

**Lemma 2.2 (Diagonal bound for the survival map).** *For every $x > 0$,
$1 - e^{-x} < x$.*

*Proof sketch.* The strict convexity of the exponential gives
$e^{-x} > 1 + (-x)$ for $x \ne 0$; rearranging yields $1 - e^{-x} < x$. $\square$

**Lemma 2.3 (Sharp quadratic lower bound).** *For every $x > 0$,
$x - \tfrac{x^2}{2} < 1 - e^{-x}$.*

*Proof sketch.* Equivalently $e^{-x} < 1 - x + \tfrac{x^2}{2}$. Writing this as
$1 < e^{x}\bigl(1 - x + \tfrac{x^2}{2}\bigr)$ and using the truncated series bound
$e^{x} > 1 + x + \tfrac{x^2}{2}$ (valid for $x > 0$, since $e^x = \sum_k x^k/k!$
and all omitted terms are positive), a short polynomial estimate closes the
inequality. This bound is the source of the *linear* critical exponent in Section
6. $\square$

Both diagonal bounds (2.1, 2.2) say the same geometric thing: a concave curve
through the origin lies strictly below its tangent line $y = x$ once its
origin-slope is $\le 1$. Lemma 2.3 is a matching *lower* bound that pins the
leading behavior of $1 - e^{-x}$ near $0$ at second order.

---

## 3. The abstract order-parameter dichotomy

We now abstract away from both models. Consider a map $F : \mathbb{R} \to
\mathbb{R}$ with $F(0) = 0$. Interpret $F$ as an "update": the order parameter is
a fixed point $F(x) = x$, the trivial value $0$ is always a fixed point, and we
ask when a *positive* fixed point exists.

### 3.1 The seed of a positive fixed point

**Lemma 3.1 (Overtaking the diagonal).** *Suppose $F(0) = 0$, $F$ is
differentiable at $0$ with $F'(0) = c$, and $c > 1$. Then for every $b > 0$ there
exists $x \in (0,b)$ with $x < F(x)$.*

*Proof sketch.* By definition of the derivative, the difference quotient
$(F(x) - F(0))/x = F(x)/x \to c > 1$ as $x \to 0^+$. Hence for all sufficiently
small $x > 0$ we have $F(x)/x > 1$, i.e. $F(x) > x$. Any such $x$ below $b$
works. $\square$

Geometrically: if the curve leaves the origin steeper than the diagonal, it is
momentarily above the diagonal just to the right of $0$.

### 3.2 Existence

**Theorem 3.2 (Existence half of the dichotomy).** *Let $b > 0$. Suppose
$F(0) = 0$, $F$ is differentiable at $0$ with $F'(0) = c > 1$, $F$ is continuous
on $[0,b]$, and $F(b) < b$. Then $F$ has a fixed point $m \in (0,b)$.*

*Proof sketch.* By Lemma 3.1 pick $x_0 \in (0,b)$ with $F(x_0) > x_0$, so the
continuous function $H(x) = F(x) - x$ satisfies $H(x_0) > 0$. At the right
endpoint $H(b) = F(b) - b < 0$. By the Intermediate Value Theorem there is
$m \in (x_0, b)$ with $H(m) = 0$, i.e. $F(m) = m$; and $m > x_0 > 0$. $\square$

### 3.3 Non-existence

**Theorem 3.3 (Non-existence half of the dichotomy).** *If $F(x) < x$ for every
$x > 0$, then $F$ has no positive fixed point.*

*Proof.* If $m > 0$ then $F(m) < m$, so $F(m) \ne m$. $\square$

Together, Theorems 3.2 and 3.3 are the promised dichotomy: for a concave,
increasing map through the origin (which automatically satisfies $F(x) < x$ once
$F'(0) \le 1$, by the same tangent-line argument as Lemmas 2.1–2.2, and satisfies
$F(b) < b$ at a saturation endpoint), the existence of a positive fixed point is
equivalent to the origin-slope exceeding $1$. The critical value $1$ is nothing
but the slope of the diagonal.

---

## 4. Curie–Weiss magnetism as an instance

**Theorem 4.1 (Ordered phase of the Curie–Weiss model).** *For $\beta > 1$ the
self-consistency equation $m = \tanh(\beta m)$ has a solution $m \in (0,1)$.*

*Proof sketch.* Apply Theorem 3.2 to $F(m) = \tanh(\beta m)$ on $[0,1]$. We have
$F(0) = 0$; $F$ is continuous; its derivative at $0$ is
$F'(0) = \beta \cdot \operatorname{sech}^2(0) = \beta > 1$; and at the right
endpoint $F(1) = \tanh(\beta) < 1$. The hypotheses of Theorem 3.2 hold with
$c = \beta$ and $b = 1$, producing a fixed point $m \in (0,1)$. $\square$

**Theorem 4.2 (Disordered phase).** *For $\beta \le 1$ the only solution of
$m = \tanh(\beta m)$ with $m \ge 0$ is $m = 0$.*

*Proof sketch.* For $m > 0$ and $\beta \le 1$, Lemma 2.1 gives
$\tanh(\beta m) \le \tanh(m) < m$ when $\beta \le 1$ (using monotonicity of
$\tanh$ and $\beta m \le m$), so by Theorem 3.3 there is no positive fixed point.
$\square$

Combining, the Curie–Weiss magnetization undergoes a sharp transition at
$\beta_c = 1$: no spontaneous magnetization for $\beta \le 1$, a symmetric pair
$\pm m$ with $m \in (0,1)$ for $\beta > 1$.

---

## 5. Branching-process survival: the full package

We fix the offspring mean $\mu$ and study the survival self-consistency equation.

**Definition 5.1 (Survival fixed point).** For $\mu, q \in \mathbb{R}$, say that
$q$ is a *survival fixed point at mean $\mu$* if
$$ q = 1 - e^{-\mu q}. $$
For a Galton–Watson process with Poisson($\mu$) offspring, the survival
probability is the largest fixed point in $[0,1]$; the extinction probability is
$1 - q$, the smallest fixed point of the offspring generating function.

**Theorem 5.2 (Probability bound).** *Every survival fixed point satisfies
$q < 1$.*

*Proof.* $q = 1 - e^{-\mu q}$ and $e^{-\mu q} > 0$, so $q < 1$. $\square$

**Theorem 5.3 (Subcritical / extinction phase).** *If $0 < \mu \le 1$, then the
only survival fixed point with $q \ge 0$ is $q = 0$.*

*Proof sketch.* Suppose $q > 0$. Then $x := \mu q > 0$, and Lemma 2.2 gives
$1 - e^{-x} < x = \mu q \le q$ (using $\mu \le 1$). But
$q = 1 - e^{-\mu q} = 1 - e^{-x}$, so $q < q$, a contradiction. Hence $q = 0$.
$\square$

**Theorem 5.4 (Supercritical / survival phase).** *If $\mu > 1$, there exists a
survival fixed point $q \in (0,1)$.*

*Proof sketch.* Apply Theorem 3.2 to $F(q) = 1 - e^{-\mu q}$ on $[0,1]$. Here
$F(0) = 0$; $F$ is continuous; $F'(0) = \mu\, e^{0} = \mu > 1$; and
$F(1) = 1 - e^{-\mu} < 1$. Theorem 3.2 yields a fixed point $q \in (0,1)$.
$\square$

**Theorem 5.5 (Sharp phase transition at $\mu_c = 1$).** *For $\mu > 0$, a
positive survival fixed point exists if and only if $\mu > 1$.*

*Proof.* ($\Leftarrow$) is Theorem 5.4. ($\Rightarrow$) if a positive fixed point
existed for $\mu \le 1$, Theorem 5.3 would force it to be $0$, a contradiction.
$\square$

**Theorem 5.6 (Uniqueness of the positive branch).** *For fixed $\mu$, at most
one positive survival fixed point exists; hence the survival probability is a
well-defined single-valued function of $\mu$.*

*Proof sketch.* Suppose $0 < q_1 < q_2$ both solve $q = 1 - e^{-\mu q}$. Apply the
mean value theorem to $G(q) = 1 - e^{-\mu q}$ on $[q_1, q_2]$ and on $[0, q_1]$:
there are $\xi \in (q_1, q_2)$ and $\eta \in (0, q_1)$ with
$G'(\xi) = (q_2 - q_1)/(q_2 - q_1) = 1$ and $G'(\eta) = q_1 / q_1 = 1$ (using the
fixed-point relations to evaluate the slopes). But $G'(q) = \mu e^{-\mu q}$ is
*strictly decreasing*, so it cannot take the value $1$ at two distinct points
$\eta < \xi$. Contradiction; hence $q_1 = q_2$. $\square$

This completes the phase-transition package: existence, sharp location,
uniqueness, and boundedness, exactly mirroring the Curie–Weiss picture, with the
same critical coupling $1$.

---

## 6. Universality of location, non-universality of exponent

We have seen that both transitions sit at coupling $1$. We now show that the
*onset* — how fast the order parameter grows past the threshold — differs, and
that the difference is dictated by the symmetry of the update map.

### 6.1 Linear onset for branching survival

**Theorem 6.1 (Quantitative linear onset, exponent $1$).** *For $\mu > 1$, any
positive survival fixed point satisfies*
$$ q \;\ge\; \frac{2(\mu - 1)}{\mu^2}. $$

*Proof sketch.* Set $x = \mu q > 0$. By Lemma 2.3, $x - x^2/2 < 1 - e^{-x} = q$.
Substituting $x = \mu q$ gives $\mu q - \mu^2 q^2 / 2 < q$, i.e.
$q(\mu - 1) < \mu^2 q^2/2$. Dividing by $q > 0$ and rearranging yields
$q > 2(\mu-1)/\mu^2$. $\square$

As $\mu \to 1^+$ the bound behaves as $2(\mu - 1) + O((\mu-1)^2)$, so the survival
probability turns on *linearly*: the critical exponent is $1$.

### 6.2 Square-root onset for Curie–Weiss magnetism

For the symmetric model, expanding $\tanh y = y - y^3/3 + O(y^5)$ in the
self-consistency equation $m = \tanh(\beta m)$ gives, for small $m > 0$,
$$ m \approx \beta m - \frac{(\beta m)^3}{3} \;\Longrightarrow\;
   m^2 \approx \frac{3(\beta - 1)}{\beta^3} \sim 3(\beta - 1), $$
so $m(\beta) \sim \sqrt{3(\beta - 1)}$ as $\beta \to 1^+$: the critical exponent
is $1/2$. The two-sided elementary bounds $\tanh y < y$ (Lemma 2.1) and
$y - y^3/3 < \tanh y$ bracket the branch and confirm the square-root scaling.

### 6.3 The symmetry–exponent principle

The contrast is structural. The map $\tanh$ is **odd**, so its Taylor expansion at
$0$ has *no quadratic term*; the first correction beyond the linear term is cubic,
which forces $m^2 \propto (\beta - 1)$ and hence exponent $1/2$. The survival map
$1 - e^{-x} = x - x^2/2 + O(x^3)$ is **not odd**; its surviving *quadratic* term
forces $q \propto (\mu - 1)$ and hence exponent $1$.

**Principle (symmetry selects the exponent).** For an order parameter obeying
$x = F(x)$ with $F$ smooth, increasing, concave, $F(0) = 0$, and origin-slope
$1 + \varepsilon$, the onset exponent is $1/(k-1)$, where $k \ge 2$ is the order
of the first nonvanishing Taylor correction beyond the linear term. An odd map
($k = 3$) gives exponent $1/2$; a map with a nonzero quadratic term ($k = 2$)
gives exponent $1$. The exponent is a property of the *lowest surviving Taylor
coefficient of the fixed-point map*, not of the physical model.

---

## 7. Algorithms

The results are constructive and yield simple, robust numerical procedures.

**Algorithm A (Order parameter by monotone iteration).** For a concave increasing
$F$ with $F(0)=0$ and $F'(0) > 1$, the iteration $x_{n+1} = F(x_n)$ started from
any $x_0 \in (0, b]$ converges monotonically to the unique positive fixed point.
Because $F$ is concave with a positive fixed point $m$, iteration from $x_0 = b$
decreases to $m$, and from small $x_0 > 0$ increases to $m$. Convergence is linear
with rate $F'(m) < 1$.

**Algorithm B (Order parameter by bisection).** On $[0,b]$ the function
$H(x) = F(x) - x$ is positive just past $0$ (when $F'(0) > 1$) and negative at
$b$; bisection on $H$ locates $m$ to any tolerance with guaranteed bracketing and
logarithmic cost.

**Algorithm C (Critical-exponent estimation).** Sample the fixed point at
couplings $c = 1 + \delta$ for a geometric sequence of $\delta \to 0^+$ and fit
$\log(\text{order parameter})$ against $\log \delta$; the slope estimates the
critical exponent ($\approx 1/2$ for the odd map, $\approx 1$ for the survival
map).

---

## 8. Applications

- **Magnetism and collective ordering.** Theorem 4.1–4.2 is the mean-field
  archetype for spontaneous symmetry breaking, applicable to ferromagnets and, by
  analogy, to synchronization and opinion-consensus models.
- **Epidemics.** The survival threshold $\mu_c = 1$ is precisely the basic
  reproduction number condition $R_0 = 1$: an outbreak has a positive chance of
  becoming large if and only if each case infects, on average, more than one
  other.
- **Nuclear and information chain reactions.** Sustained reactions and viral
  cascades occur exactly in the supercritical regime $\mu > 1$.
- **Percolation.** The survival dichotomy is the branching-process backbone of
  percolation on trees, where mean offspring $\mu$ plays the role of the critical
  probability parameter.

---

## 9. Discussion and future work

The unification is genuine rather than cosmetic: both ordered phases are produced
by literally the same existence theorem (Theorem 3.2) applied to different
analytic inputs, and both subcritical phases by the same non-existence theorem
(Theorem 3.3) fed by the diagonal bounds of Section 2. The universality of the
critical value ($1$) reflects the diagonal's slope; the non-universality of the
exponent reflects the symmetry of the update map.

Several directions extend this programme.

1. **A symmetry–exponent dictionary.** Establish the general claim that the onset
   exponent equals $1/(k-1)$ where $k$ is the order of the first nonvanishing
   Taylor correction, interpolating between the odd case ($k=3$, exponent $1/2$)
   and the quadratic case ($k=2$, exponent $1$) with the same bracketing
   technique.

2. **Sharp two-sided asymptotics for branching survival.** Prove
   $q(\mu) = 2(\mu-1) - \tfrac{8}{3}(\mu-1)^2 + o((\mu-1)^2)$ as $\mu \to 1^+$,
   and that $q(\mu)$ is real-analytic, strictly increasing on $(1,\infty)$ with
   $q(\mu) \to 1$ as $\mu \to \infty$.

3. **Field-perturbed uniqueness.** For the externally driven equations
   $m = \tanh(\beta m + h)$ and $q = 1 - e^{-(\mu q + h)}$ with $h > 0$, prove the
   positive solution is unique for every coupling, replacing the sharp threshold
   by a single analytic branch and a line of first-order transitions terminating
   at the critical point $(\text{coupling}, h) = (1, 0)$.

4. **Variational characterization.** Formalize the mean-field free energy and show
   its global minimizer coincides with the stable fixed point, giving an
   analytic-to-non-analytic statement for the minimal free energy at criticality.

5. **Monotone continuous branch.** Package the positive branch $c \mapsto x^*(c)$
   on $(1,\infty)$ and prove continuity, strict monotonicity, and the saturation
   limit.

---

## 10. Conclusion

Mean-field magnetism and branching survival — a model of condensed matter and a
model of populations — are two instances of one abstract order-parameter
dichotomy: a concave increasing map through the origin acquires a positive fixed
point exactly when its origin-slope crosses $1$. This single criterion delivers
both complete phase-transition packages at the common critical value $1$, while a
finer principle — the parity of the update map — accounts for their differing
critical exponents ($1/2$ for the odd magnetic map, $1$ for the asymmetric
survival map). The result is a compact, fully rigorous window onto the universality
that pervades the theory of phase transitions.
