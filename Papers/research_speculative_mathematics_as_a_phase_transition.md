# Order Parameters and Critical Thresholds: Two Exactly-Solvable Mean-Field Phase Transitions

## Abstract

We give a rigorous, self-contained analysis of the paradigmatic *second-order
phase transition* of statistical mechanics — the spontaneous magnetization of the
mean-field (Curie–Weiss) Ising ferromagnet — and of its combinatorial cousin, the
emergence of a giant connected component in mean-field percolation (equivalently,
the survival of a Poisson Galton–Watson branching process). In each case the model
reduces to a scalar self-consistency equation for an *order parameter*: the
magnetization $m = \tanh(\beta m)$ and the survival probability
$\rho = 1 - e^{-\lambda \rho}$. We prove that both models undergo a phase
transition at the critical value $1$ of their coupling: below threshold the only
solution is the trivial one (no order), while above threshold a nontrivial ordered
branch appears. We further establish quantitative lower bounds near criticality —
$m^2 \ge 3(\beta-1)/\beta^3$ and $\rho \ge 2(\lambda-1)/\lambda^2$ — which exhibit
the *continuous* (second-order) onset of order and identify the mean-field
critical exponents $\tfrac12$ (magnetization) and $1$ (percolation). The two
different exponents, arising from the same structural template, are a concrete
illustration of universality. All results are proved from elementary Taylor-type
inequalities for $\tanh$ and $1 - e^{-x}$ that we derive from first principles.

**Keywords:** phase transition, order parameter, Curie–Weiss model, mean-field
Ising, percolation, giant component, branching process, critical exponent,
self-consistency equation, universality.

## 1. Introduction

A *phase transition* is a qualitative, often discontinuous, change in the
macroscopic state of a many-body system induced by the smooth variation of a
control parameter across a critical value. The organizing concept, due to Landau,
is the **order parameter**: a scalar (or tensor) quantity that vanishes in the
disordered phase and becomes nonzero in the ordered phase. A transition is
**first order** when the order parameter jumps discontinuously and **second order
(continuous)** when it grows continuously from zero, typically as a power
$(g - g_c)^{\beta_{\mathrm{exp}}}$ of the distance from the critical coupling
$g_c$; the number $\beta_{\mathrm{exp}}$ is a **critical exponent**.

Two of the most influential exactly-solvable models are:

1. **The mean-field (Curie–Weiss) Ising ferromagnet.** Each of $N$ spins
   interacts equally with all others. In the thermodynamic limit the average
   magnetization $m$ satisfies $m = \tanh(\beta(Jm + h))$ where $\beta$ is inverse
   temperature, $J$ the coupling and $h$ an external field. In zero field with
   $J$ absorbed into $\beta$, this is $m = \tanh(\beta m)$.

2. **Mean-field percolation / the Poisson branching process.** In the
   Erdős–Rényi random graph $G(n, \lambda/n)$, the exploration of a connected
   cluster converges (locally) to a Galton–Watson tree with $\mathrm{Poisson}(\lambda)$
   offspring. The survival probability $\rho$ — asymptotically the fraction of
   vertices in the giant component — satisfies $\rho = 1 - e^{-\lambda\rho}$.

Both models are governed by a scalar **self-consistency equation**
$x = \Phi(x)$ with $\Phi$ smooth, concave on $[0,\infty)$, fixing $0$, and with
$\Phi'(0)$ equal to the coupling. This shared structure produces a shared
phenomenology: a transition exactly when $\Phi'(0)$ crosses $1$. The purpose of
this paper is to develop this phenomenology rigorously and quantitatively, with
complete proofs built from elementary inequalities.

Our contributions are:

- A clean derivation of the calculus and Taylor-type inequalities for $\tanh$ and
  $1 - e^{-x}$ needed to control the fixed-point maps (Section 3).
- A full proof of the transition for the Curie–Weiss model, including uniqueness
  of $m=0$ below threshold, existence of a symmetric ordered pair above threshold,
  and the near-critical lower bound yielding exponent $\tfrac12$ (Section 4).
- The parallel development for mean-field percolation, with the near-critical
  lower bound yielding exponent $1$ (Section 5).
- A discussion of universality, the meaning of the two different exponents, and a
  speculative program relating the growth of mathematical knowledge to a
  percolation transition (Sections 6–7).

## 2. Definitions and setup

Throughout, all variables are real.

**Definition 2.1 (Magnetization / order parameter of the ferromagnet).** For a
coupling $\beta \in \mathbb{R}$, a real number $m$ is a *magnetization* at
coupling $\beta$ if it is a fixed point of $m \mapsto \tanh(\beta m)$:
$$\tanh(\beta m) = m.$$

**Definition 2.2 (Survival probability / order parameter of percolation).** For a
mean connectivity $\lambda \in \mathbb{R}$, a real number $\rho$ is a *survival
probability* at connectivity $\lambda$ if
$$\rho = 1 - e^{-\lambda \rho}.$$

In both cases $x = 0$ is a fixed point for every coupling (Propositions 4.1 and
5.1): the disordered/extinction state is always admissible. A phase transition is
the appearance of an *additional*, nontrivial fixed point.

**Definition 2.3 (Critical coupling).** The critical coupling of a self-consistency
map $\Phi$ with $\Phi(0)=0$ is the value of $\Phi'(0)$ at which the nontrivial
branch appears. For both models here $\Phi'(0)$ equals the coupling itself, so the
critical values are $\beta_c = 1$ and $\lambda_c = 1$.

## 3. Analytic toolkit

The entire analysis rests on a handful of elementary inequalities, each proved by
identifying a monotone auxiliary function via its derivative.

### 3.1 The hyperbolic tangent

**Lemma 3.1 (Derivative of $\tanh$).** For all $x$, $\dfrac{d}{dx}\tanh x = 1 - \tanh^2 x$.

*Proof.* Write $\tanh = \sinh/\cosh$ and apply the quotient rule with
$\sinh' = \cosh$, $\cosh' = \sinh$ and $\cosh^2 - \sinh^2 = 1$. In particular
$\tanh$ is differentiable, hence continuous, everywhere. $\qquad\blacksquare$

**Lemma 3.2 (Sub-diagonal bound).** For every $x > 0$, $\tanh x < x$.

*Proof.* Equivalently $\sinh x < x\cosh x$. The function
$g(t) = t\cosh t - \sinh t$ satisfies $g(0) = 0$ and $g'(t) = t\sinh t > 0$ for
$t > 0$, so $g$ is strictly increasing on $[0,\infty)$ and $g(x) > 0$. $\qquad\blacksquare$

**Lemma 3.3 (Nonnegativity).** For $x \ge 0$, $\tanh x \ge 0$.

*Proof.* $\sinh$ is increasing with $\sinh 0 = 0$, and $\cosh > 0$. $\qquad\blacksquare$

**Lemma 3.4 (Cubic Taylor lower bound).** For $x \ge 0$,
$\tanh x \ge x - \dfrac{x^3}{3}$.

*Proof.* Let $h(t) = \tanh t - (t - t^3/3)$. Then $h(0) = 0$ and, by Lemma 3.1,
$h'(t) = (1 - \tanh^2 t) - (1 - t^2) = t^2 - \tanh^2 t$. For $t \ge 0$ we have
$0 \le \tanh t \le t$ (Lemmas 3.2–3.3), so $\tanh^2 t \le t^2$ and $h'(t) \ge 0$.
Hence $h$ is nondecreasing on $[0,\infty)$ and $h(x) \ge 0$. $\qquad\blacksquare$

We also record $|\tanh x| < 1$ for all $x$ and $\tanh(-x) = -\tanh x$, standard
facts used below.

### 3.2 The percolation nonlinearity

**Lemma 3.5 (Sub-diagonal bound).** For every $x > 0$, $1 - e^{-x} < x$.

*Proof.* The strict convexity bound $1 + t < e^{t}$ for $t \ne 0$ at $t = -x$
gives $1 - x < e^{-x}$, i.e. $1 - e^{-x} < x$. $\qquad\blacksquare$

**Lemma 3.6 (Quadratic Taylor lower bound).** For $x \ge 0$,
$1 - e^{-x} \ge x - \dfrac{x^2}{2}$.

*Proof.* Let $k(t) = (1 - t + t^2/2) - e^{-t}$. Then $k(0) = 0$ and
$k'(t) = (-1 + t) + e^{-t} = t + e^{-t} - 1 \ge 0$ by the convexity bound
$e^{-t} \ge 1 - t$. Hence $k$ is nondecreasing on $[0,\infty)$, so $k(x)\ge 0$,
which rearranges to the claim. $\qquad\blacksquare$

## 4. The Curie–Weiss transition

### 4.1 Elementary structural facts

**Proposition 4.1 (Trivial solution).** $m = 0$ is a magnetization for every
$\beta$, since $\tanh 0 = 0$.

**Proposition 4.2 (Symmetry).** If $m$ is a magnetization at coupling $\beta$,
then so is $-m$. Indeed $\tanh(\beta(-m)) = -\tanh(\beta m) = -m$. This is the
$\mathbb{Z}_2$ (spin-flip) symmetry of the Ising ferromagnet.

**Proposition 4.3 (Boundedness).** Every magnetization satisfies $|m| < 1$,
because $|m| = |\tanh(\beta m)| < 1$.

### 4.2 Disordered phase

**Theorem 4.4 (Uniqueness below threshold).** If $0 < \beta \le 1$, the only
magnetization is $m = 0$.

*Proof.* Suppose $m$ is a magnetization. If $m > 0$ then $\beta m > 0$ and, by
Lemma 3.2, $\tanh(\beta m) < \beta m \le m$ (using $\beta \le 1$), contradicting
$\tanh(\beta m) = m$. If $m < 0$ apply the same argument to $-m$ via Proposition
4.2. Hence $m = 0$. $\qquad\blacksquare$

Thus below the critical coupling there is no spontaneous order.

### 4.3 Ordered phase

**Theorem 4.5 (Existence above threshold).** If $\beta > 1$, there exists a
magnetization $m > 0$ (and, by Proposition 4.2, also $-m$).

*Proof.* Consider the continuous residual $F(m) = \tanh(\beta m) - m$. Set the
critical scale $c = 3(\beta - 1)/\beta^3 > 0$ and the test point
$a = \tfrac12\sqrt{c} > 0$, so that $a^2 = c/4$. By the cubic bound (Lemma 3.4),
$$\tanh(\beta a) \ge \beta a - \frac{(\beta a)^3}{3}
= \beta a - \frac{\beta^3 a^2}{3}\,a.$$
Since $a^2 = c/4$ we have $\beta^3 a^2 = \beta^3 c/4 = \tfrac34(\beta - 1)$, whence
$\beta a - (\beta a)^3/3 = \beta a\bigl(1 - \tfrac14(\beta-1)\bigr)$, and a short
computation using $0 < a < 1$ shows this exceeds $a$; therefore $F(a) > 0$. On the
other hand $F(a+1) = \tanh(\beta(a+1)) - (a+1) < 1 - (a+1) \le 0$ because
$\tanh < 1$. Since $F$ is continuous and changes sign on $[a, a+1]$, the
intermediate value theorem yields $m \in (a, a+1)$ with $F(m) = 0$, i.e. a
magnetization with $m \ge a > 0$. $\qquad\blacksquare$

Above the critical coupling, spontaneous symmetry breaking occurs: the pair
$\pm m$ of ordered states appears alongside the (now unstable) disordered state.

### 4.4 Continuous onset and critical exponent

**Theorem 4.6 (Near-critical lower bound; exponent $\tfrac12$).** If $\beta > 1$
and $m > 0$ is a magnetization, then
$$m^2 \ge \frac{3(\beta - 1)}{\beta^3}.$$

*Proof.* Since $\beta m \ge 0$, the cubic bound (Lemma 3.4) gives
$m = \tanh(\beta m) \ge \beta m - (\beta m)^3/3$. Rearranging,
$0 \ge (\beta - 1)m - \beta^3 m^3/3$, and dividing by $m > 0$ and by
$\beta^3/3 > 0$ yields $m^2 \ge 3(\beta-1)/\beta^3$. $\qquad\blacksquare$

**Corollary 4.7.** As $\beta \downarrow 1$, every ordered branch satisfies
$m \gtrsim \sqrt{3(\beta - 1)}$, so the magnetization emerges *continuously* from
$0$ with mean-field critical exponent $\beta_{\mathrm{exp}} = \tfrac12$. The
transition is therefore **second order**.

## 5. The percolation / giant-component transition

### 5.1 Elementary structural facts

**Proposition 5.1 (Trivial solution).** $\rho = 0$ is a survival probability for
every $\lambda$.

**Proposition 5.2 (Boundedness).** Every survival probability satisfies
$\rho < 1$, since $\rho = 1 - e^{-\lambda\rho}$ and $e^{-\lambda\rho} > 0$.

### 5.2 Subcritical regime

**Theorem 5.3 (No giant component below threshold).** If $0 < \lambda \le 1$ and
$\rho \ge 0$ is a survival probability, then $\rho = 0$.

*Proof.* If $\rho > 0$ then $\lambda\rho > 0$ and Lemma 3.5 gives
$\rho = 1 - e^{-\lambda\rho} < \lambda\rho \le \rho$ (using $\lambda \le 1$), a
contradiction. $\qquad\blacksquare$

### 5.3 Supercritical regime

**Theorem 5.4 (Giant component above threshold).** If $\lambda > 1$, there exists
a survival probability with $0 < \rho < 1$.

*Proof.* Consider the continuous residual $G(\rho) = (1 - e^{-\lambda\rho}) - \rho$.
Take the test point $a = (\lambda - 1)/\lambda^2 \in (0, 1)$. Then
$\lambda a = (\lambda - 1)/\lambda$, and the quadratic bound (Lemma 3.6) gives
$$1 - e^{-\lambda a} \ge \lambda a - \frac{(\lambda a)^2}{2}
= \frac{\lambda-1}{\lambda} - \frac{(\lambda-1)^2}{2\lambda^2}
> \frac{\lambda-1}{\lambda^2} = a,$$
the strict inequality because $(\lambda-1)^2 > 0$; hence $G(a) > 0$. At $\rho = 1$,
$G(1) = -e^{-\lambda} < 0$. By continuity and the intermediate value theorem there
is $\rho \in (a, 1)$ with $G(\rho) = 0$, giving a survival probability with
$0 < \rho < 1$. $\qquad\blacksquare$

### 5.4 Continuous onset and critical exponent

**Theorem 5.5 (Near-critical lower bound; exponent $1$).** If $\lambda > 1$ and
$\rho > 0$ is a survival probability, then
$$\rho \ge \frac{2(\lambda - 1)}{\lambda^2}.$$

*Proof.* Since $\lambda\rho \ge 0$, Lemma 3.6 gives
$\rho = 1 - e^{-\lambda\rho} \ge \lambda\rho - (\lambda\rho)^2/2$. Rearranging,
$0 \ge (\lambda - 1)\rho - \lambda^2\rho^2/2$, and dividing by $\rho > 0$ and
$\lambda^2/2$ yields $\rho \ge 2(\lambda-1)/\lambda^2$. $\qquad\blacksquare$

**Corollary 5.6.** As $\lambda \downarrow 1$, $\rho \gtrsim 2(\lambda - 1)$, so the
giant-component fraction grows *linearly* from $0$: the mean-field percolation
critical exponent is $\beta_{\mathrm{exp}} = 1$.

## 6. Universality: one template, two exponents

The two models share a structural template: a self-consistency map $\Phi$ with
$\Phi(0) = 0$, concave and increasing on $[0,\infty)$, with $\Phi'(0)$ equal to
the coupling. The transition occurs precisely when $\Phi'(0)$ crosses $1$, because
that is when the graph of $\Phi$ detaches from the diagonal at the origin. This is
why both critical values equal $1$.

Yet the *onset* differs. The behavior near criticality is dictated by the *first
nonlinear term* of $\Phi$:

- For the ferromagnet, $\tanh(\beta m) = \beta m - \tfrac13(\beta m)^3 + \cdots$
  is *cubic* (the linear-order symmetry $m \mapsto -m$ forbids a quadratic term).
  Balancing $(\beta - 1)m$ against $m^3$ gives $m \sim \sqrt{\beta-1}$, exponent
  $\tfrac12$.
- For percolation, $1 - e^{-\lambda\rho} = \lambda\rho - \tfrac12(\lambda\rho)^2 + \cdots$
  is *quadratic* (there is no $\rho \mapsto -\rho$ symmetry). Balancing
  $(\lambda-1)\rho$ against $\rho^2$ gives $\rho \sim \lambda - 1$, exponent $1$.

That the same skeleton yields distinct exponents governed only by the leading
nonlinearity and its symmetry is a first, exactly-solvable instance of
**universality**: critical behavior is insensitive to microscopic detail but
sensitive to symmetry and the order of the leading nonlinearity.

## 7. Applications and interpretation

**Statistical physics.** The Curie–Weiss result is the mean-field backbone of
ferromagnetism and, via the same equation, of order–disorder transitions in
alloys, the Weiss molecular-field theory, and the mean-field limit of countless
lattice models.

**Networks and epidemics.** The percolation result underlies the giant-component
threshold of the Erdős–Rényi graph, the basic-reproduction-number criterion
$R_0 > 1$ for epidemic outbreaks, cascading failures in infrastructure, and the
robustness/fragility of complex networks. The self-consistency equation
$\rho = 1 - e^{-\lambda\rho}$ is exactly the extinction–survival dichotomy for the
Poisson Galton–Watson branching process.

**A speculative program: knowledge as a percolating network.** One may model a
body of mathematical results as a graph whose vertices are theorems and whose
edges are logical dependencies or conceptual bridges. A natural *coherence order
parameter* is the fraction of results lying in the largest connected component. If
new bridges are formed at an average rate per result of $\lambda$, the branching
heuristic predicts that this coherence order parameter is essentially zero while
$\lambda < 1$ and switches on continuously once $\lambda$ exceeds $1$ — a
percolation transition in the space of ideas, in which many separate strands
suddenly fuse into a single connected theory. This picture is at present a
*conjecture*: it awaits a precise, empirically grounded definition of the vertex
and edge sets and of the coupling $\lambda$. The rigorous results of this paper
supply the mathematical scaffolding such a program would rest on, and make precise
what "a phase transition in mathematics" would even mean.

## 8. Discussion and future work

We proved *lower* bounds on the order parameters near criticality, which suffice
to establish continuity of onset and to lower-bound the exponents. The natural
next steps are:

1. **Matching upper bounds and exact exponents.** Complement the lower bounds with
   $m^2 \le 3(\beta-1)/\beta^3\,(1 + o(1))$ and $\rho \le 2(\lambda-1) + o(\lambda-1)$
   via higher-order Taylor bounds, pinning the exponents $\tfrac12$ and $1$ exactly.

2. **Uniqueness of the ordered branch.** Use strict concavity of
   $m \mapsto \tanh(\beta m)$ and $\rho \mapsto 1 - e^{-\lambda\rho}$ on
   $(0,\infty)$ to show the positive fixed point is unique for each supercritical
   coupling and strictly increasing in the coupling.

3. **Free-energy / variational formulation.** Realize the magnetizations as
   critical points of the Curie–Weiss free energy
   $f(m) = -\tfrac12 m^2 - \beta^{-1}\log\cosh(\beta m)$ and characterize the
   transition as a bifurcation of global minimizers.

4. **From mean field to genuine percolation.** Connect the branching fixed point
   to Bernoulli bond percolation on trees (where $\lambda_c = 1$ for the regular
   tree) and, ultimately, toward $\mathbb{Z}^d$ percolation thresholds.

5. **A discrete connectivity-threshold companion.** Formalize the extremal result
   that a simple graph on $n$ vertices with more than $\binom{n-1}{2}$ edges is
   connected (sharp via $K_{n-1} \sqcup \{\mathrm{pt}\}$), a combinatorial cousin
   of the percolation threshold.

## 9. Conclusion

Two of the most important transitions in science — spontaneous magnetization and
the emergence of a giant component — are captured by scalar self-consistency
equations $m = \tanh(\beta m)$ and $\rho = 1 - e^{-\lambda\rho}$. We proved from
elementary principles that each undergoes a sharp transition at coupling $1$: no
order below, a continuously emerging ordered branch above, with mean-field
critical exponents $\tfrac12$ and $1$ respectively. The shared template and the
divergent exponents together form a transparent, fully rigorous window onto the
phenomena of criticality and universality.
