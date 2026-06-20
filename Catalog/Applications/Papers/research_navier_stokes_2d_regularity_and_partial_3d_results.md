# A Scalar A Priori Framework for Navier–Stokes Regularity: 2D Global Smoothness, the 3D Supercritical Blow-Up Rate, and the Dissipation Budget

**Author:** Aristotle

**Date:** 2026-06-20

---

## Abstract

The incompressible Navier–Stokes equations are the master equations of fluid
dynamics, and the question of whether their three-dimensional solutions remain
smooth for all time is among the deepest open problems in mathematics. A large
part of the regularity theory, however, does not depend on the full vector-valued
partial differential equations: it is governed by *scalar differential
inequalities* satisfied by integral quantities such as the kinetic energy, the
enstrophy, and the dissipation rate. In this paper we isolate, state, and prove
this scalar a priori core in full rigour. We establish: (i) monotonicity and
global boundedness of the enstrophy in two dimensions, the engine behind
Ladyzhenskaya's global regularity theorem; (ii) exponential decay of energy to
zero under a Poincaré inequality; (iii) the sharp $O((T^\*-t)^{-1/2})$ lower bound
on the enstrophy near a putative three-dimensional blow-up time, together with the
matching guaranteed-lifespan estimate, both derived from the supercritical
inequality $Z'\le C Z^3$; (iv) conditional and unconditional small-data global
regularity in three dimensions from the competition inequality $Z'\le -aZ+CZ^2$;
and (v) the integrated energy identity and the finite total-dissipation budget
$\int_0^\infty F \le E(0)/(2\nu)$ obtained from the Fundamental Theorem of
Calculus. Each result is a self-contained statement about real-valued functions of
time and is accompanied by a complete proof sketch. The framework provides a clean,
formally verifiable backbone for both the two-dimensional theory and the partial
three-dimensional theory, and it makes precise the exact location of the
remaining open gap.

---

## 1. Introduction

### 1.1 The Navier–Stokes equations and the regularity problem

For an incompressible viscous fluid filling a domain $\Omega \subseteq
\mathbb{R}^d$ (with $d=2$ or $d=3$) the velocity field $u(x,t)$ and pressure
$p(x,t)$ satisfy
$$\partial_t u + (u\cdot\nabla)u = -\nabla p + \nu\,\Delta u, \qquad
\nabla\cdot u = 0,$$
where $\nu > 0$ is the kinematic viscosity. The central open question — one of the
Clay Mathematics Institute's Millennium Prize Problems — is whether, for smooth
divergence-free initial data of finite energy in $d=3$, the solution remains smooth
for all $t>0$, or whether it can develop a singularity (blow-up) in finite time.

In two dimensions the answer is known and affirmative: Ladyzhenskaya established
global existence, uniqueness, and regularity. In three dimensions only *partial*
results are known: global weak solutions (Leray), local-in-time strong solutions,
small-data global regularity, conditional regularity criteria (Prodi–Serrin,
Beale–Kato–Majda), and the Caffarelli–Kohn–Nirenberg partial regularity theorem
bounding the dimension of the singular set.

### 1.2 The scalar a priori philosophy

A striking feature of this theory is how much of it is controlled not by the
velocity field itself but by a few *scalar* functionals of time:
- the **kinetic energy** $E(t) = \tfrac12\int_\Omega |u(x,t)|^2\,dx$;
- the **enstrophy** $Z(t) = \int_\Omega |\omega(x,t)|^2\,dx$, where $\omega =
  \nabla\times u$ is the vorticity;
- the **dissipation rate** $F(t)\ge 0$, controlling how fast energy is converted to
  heat.

Multiplying the momentum equation by $u$ and integrating produces the *energy
identity* $E'(t) = -2\nu F(t)$; manipulating the vorticity equation produces
differential inequalities for $Z$ whose form depends decisively on the dimension.
Once these scalar relations are extracted, the qualitative fate of the flow —
boundedness, decay, blow-up rate, threshold for global existence — becomes a
question about real-valued functions of one variable, fully amenable to rigorous,
elementary analysis.

This paper formalizes that scalar core. We treat $E$, $Z$, and $F$ as abstract
differentiable functions $[0,\infty)\to\mathbb{R}$ obeying the relevant
inequalities, and we prove eleven theorems organized into five groups. Crucially,
no result below assumes anything beyond the stated scalar hypotheses; each is a
theorem about ordinary functions, and each is proved completely.

### 1.3 Contributions

1. A precise statement and proof of 2D enstrophy monotonicity and the global bound
   $Z(t)\le Z(0)$ (§3.1).
2. Exponential energy decay under a Poincaré inequality and convergence to rest
   (§3.2).
3. The sharp supercritical blow-up lower bound $Z(t)\ge (2C(T^\*-t))^{-1/2}$ and
   the matching lifespan estimate (§3.3).
4. Conditional and unconditional small-data global bounds in 3D (§3.4).
5. The integrated energy identity and finite total-dissipation budget (§3.5).

---

## 2. Setup and definitions

Throughout, $\nu>0$ is a fixed viscosity, and all functions of time are defined on
$[0,\infty)$ (or, for the blow-up results, on a maximal interval $[0,T^\*)$) and are
assumed differentiable where derivatives appear.

**Definition 2.1 (Energy–dissipation pair).** An *energy–dissipation pair* is a
pair $(E, F)$ of functions $E, F:[0,\infty)\to\mathbb{R}$ with $E\ge 0$, $F\ge 0$,
$E$ differentiable, satisfying the *energy identity*
$$E'(t) = -2\nu\,F(t), \qquad t\ge 0.$$
This is the scalar shadow of the Navier–Stokes energy balance; $E$ is kinetic
energy and $F$ is the (nonnegative) dissipation rate.

**Definition 2.2 (Poincaré domain).** The pair $(E,F)$ satisfies a *Poincaré
inequality* with constant $\lambda>0$ if $F(t)\ge \lambda\,E(t)$ for all $t$. The
constant $\lambda$ is the first Dirichlet eigenvalue of $-\Delta$ on $\Omega$ (the
square of the lowest vibration frequency).

**Definition 2.3 (2D enstrophy law).** A function $Z:[0,\infty)\to\mathbb{R}$
satisfies the *two-dimensional enstrophy law* if there is $D:[0,\infty)\to\mathbb
R$ with $D\ge 0$ and
$$Z'(t) = -2\nu\,D(t).$$
The absence of a positive (vortex-stretching) term is the analytic expression of
the fact that vortex lines cannot be stretched in the plane.

**Definition 2.4 (3D supercritical enstrophy inequality).** A nonnegative function
$Z$ satisfies the *supercritical inequality* with constant $C>0$ on $[0,T^\*)$ if
$$Z'(t)\le C\,Z(t)^3.$$
The cubic right-hand side is supercritical: it dominates the linear dissipation for
large $Z$ and admits finite-time blow-up in the borderline ODE.

**Definition 2.5 (3D competition inequality).** A nonnegative function $Z$
satisfies the *competition inequality* with dissipation rate $a>0$ and stretching
constant $C>0$ if
$$Z'(t)\le -a\,Z(t) + C\,Z(t)^2.$$
The threshold $Z = a/C$ separates the dissipation-dominated regime ($Z<a/C$) from
the potentially runaway regime ($Z>a/C$).

---

## 3. Main results

### 3.1 Two dimensions: enstrophy is trapped

**Theorem 1 (`enstrophy_monotone_2D`).** *If $Z$ satisfies the two-dimensional
enstrophy law $Z'(t) = -2\nu\,D(t)$ with $D\ge 0$, then $Z$ is monotone
non-increasing: $s\le t \implies Z(t)\le Z(s)$.*

*Proof sketch.* The derivative $Z'(t) = -2\nu D(t)\le 0$ everywhere since $\nu>0$
and $D\ge 0$. A differentiable function with non-positive derivative is
non-increasing (mean value theorem / monotonicity from derivative sign). $\square$

**Theorem 2 (`enstrophy_global_bound_2D`).** *Under the same hypotheses, $Z(t)\le
Z(0)$ for all $t\ge 0$.*

*Proof sketch.* Apply Theorem 1 with $s=0$. $\square$

*Remark.* Theorems 1–2 are the scalar core of Ladyzhenskaya's 2D global regularity
theorem. The full PDE statement upgrades the a priori bound $Z(t)\le Z(0)$ — i.e.
a uniform-in-time control of $\|\nabla u\|_{L^2}^2$ — to global existence,
uniqueness, and smoothness via standard energy methods and the absence of vortex
stretching in the plane. The crucial structural input is exactly the *sign*: in 2D
the vortex-stretching term $(\omega\cdot\nabla)u$ vanishes identically, so the
enstrophy balance has no production term and $Z'\le 0$.

### 3.2 Energy decay under a Poincaré inequality

**Theorem 3 (`energy_decay_poincare`).** *Let $(E,F)$ be an energy–dissipation
pair satisfying a Poincaré inequality with constant $\lambda>0$. Then*
$$E(t) \le E(0)\,e^{-2\nu\lambda\,t}, \qquad t\ge 0.$$

*Proof sketch.* Combining Definitions 2.1 and 2.2,
$$E'(t) = -2\nu F(t) \le -2\nu\lambda\,E(t).$$
Consider $g(t) = E(t)\,e^{2\nu\lambda t}$. Then
$$g'(t) = \big(E'(t)+2\nu\lambda E(t)\big)e^{2\nu\lambda t}\le 0,$$
so $g$ is non-increasing; hence $g(t)\le g(0)=E(0)$, which rearranges to the
claimed bound. This is the Grönwall inequality in its sharpest, integrating-factor
form. $\square$

**Corollary 4 (`energy_tendsto_zero`).** *Under the hypotheses of Theorem 3,
$E(t)\to 0$ as $t\to\infty$.*

*Proof sketch.* $0\le E(t)\le E(0)e^{-2\nu\lambda t}\to 0$; apply the squeeze
theorem. $\square$

*Remark.* The decay rate $2\nu\lambda$ is explicit and physically transparent:
larger viscosity $\nu$ or smaller domain (larger $\lambda$) yields faster return to
rest. On the torus or a bounded domain with the Poincaré inequality available, this
gives unconditional decay of finite-energy solutions in the absence of forcing.

### 3.3 Three dimensions: the supercritical blow-up rate

We now turn to the regime where vortex stretching is active and the enstrophy
balance acquires a production term dominated by the cubic inequality of Definition
2.4.

**Theorem 5 (`blowup_rate_lower_bound_3D`).** *Let $Z\ge 0$ be differentiable on
$[0,T^\*)$, satisfy $Z'(t)\le C\,Z(t)^3$, and blow up at $T^\*$ in the sense that
$Z(t)\to\infty$ as $t\to T^{\*-}$. Suppose $Z(t)>0$ on $[0,T^\*)$. Then for all
$t\in[0,T^\*)$,*
$$Z(t) \ge \frac{1}{\sqrt{2C\,(T^\*-t)}}.$$

*Proof sketch.* Where $Z>0$, set $\varphi(t)=Z(t)^{-2}$. Then
$$\varphi'(t) = -2\,Z(t)^{-3}Z'(t)\ge -2\,Z(t)^{-3}\cdot C\,Z(t)^3 = -2C.$$
So $\varphi$ has derivative bounded below by $-2C$; for $t<\tau<T^\*$,
$$\varphi(t) - \varphi(\tau) = -\int_t^\tau \varphi'(s)\,ds \le 2C\,(\tau - t).$$
Let $\tau\to T^{\*-}$. Since $Z(\tau)\to\infty$, $\varphi(\tau)=Z(\tau)^{-2}\to 0$,
giving $\varphi(t)\le 2C(T^\*-t)$, i.e. $Z(t)^{-2}\le 2C(T^\*-t)$. Inverting (both
sides positive) yields $Z(t)\ge (2C(T^\*-t))^{-1/2}$. $\square$

*Remark (sharpness).* The exponent $\tfrac12$ is optimal: the borderline ODE
$Z'=CZ^3$ has the exact solution $Z(t) = \big(Z(0)^{-2}-2Ct\big)^{-1/2}$, which
blows up at $T^\* = 1/(2CZ(0)^2)$ and satisfies $Z(t)=(2C(T^\*-t))^{-1/2}$ with
equality. Thus the lower bound of Theorem 5 is achieved, and no slower blow-up is
possible under the cubic inequality. In the PDE setting this is the scalar form of
the classical lower bounds on the rate of singularity formation: a solution cannot
approach a singularity gradually; its enstrophy (or appropriate critical norm) must
diverge at least at the dictated rate.

**Theorem 6 (`lifespan_lower_bound_3D`).** *If $Z\ge 0$ is differentiable with
$Z(0)>0$ and satisfies $Z'(t)\le C\,Z(t)^3$ as long as it remains finite, then $Z$
stays finite (and in fact $Z(t)\le (Z(0)^{-2}-2Ct)^{-1/2}$) at least on the
interval*
$$0\le t < T := \frac{1}{2\,C\,Z(0)^2}.$$

*Proof sketch.* With $\varphi=Z^{-2}$ as above, $\varphi'\ge -2C$ gives
$\varphi(t)\ge \varphi(0)-2Ct = Z(0)^{-2}-2Ct$, which is strictly positive for
$t<T$. Hence $Z(t)^2 = 1/\varphi(t) \le (Z(0)^{-2}-2Ct)^{-1}<\infty$ on $[0,T)$, so
no blow-up can occur before $T$. $\square$

*Remark.* Theorems 5 and 6 are the two faces of one inequality: the same
$\varphi'=-2Z^{-3}Z'$ computation yields both the guaranteed window of existence
(lower bound on lifespan) and the obligatory divergence rate near any actual
singularity. The calmer the start (smaller $Z(0)$), the longer the guarantee.

### 3.4 Small-data global regularity in 3D

When the enstrophy is below the threshold $a/C$, the competition inequality of
Definition 2.5 keeps it there forever.

**Theorem 7 (`small_data_global_conditional_3D`).** *Let $Z\ge 0$ satisfy
$Z'(t)\le -a\,Z(t)+C\,Z(t)^2$ on $[0,T]$, with $a,C>0$, and suppose $Z(0)\le a/C$.
Then $Z(t)\le Z(0)$ for all $t\in[0,T]$.*

*Proof sketch.* On the threshold band $0\le Z\le a/C$ we have $-aZ+CZ^2 =
Z(CZ-a)\le 0$, so $Z'(t)\le 0$ wherever $Z(t)\le a/C$. We claim $Z$ never exceeds
$Z(0)$. Indeed, suppose for contradiction $Z(t_1)>Z(0)$ for some $t_1$. Let
$t_0=\sup\{t\le t_1: Z(t)\le Z(0)\}$; by continuity $Z(t_0)=Z(0)\le a/C$ and
$Z(t)>Z(0)$ on $(t_0,t_1]$. But on a right-neighbourhood of $t_0$ the value stays
$\le a/C$ (by continuity, shrinking if necessary), where $Z'\le 0$, so $Z$ cannot
increase past $Z(0)=Z(t_0)$ — contradiction. Hence $Z(t)\le Z(0)$ throughout.
$\square$

**Theorem 8 (`small_data_global_3D`).** *Let $Z\ge 0$ satisfy $Z'(t)\le
-a\,Z(t)+C\,Z(t)^2$ for all $t\ge 0$ with the strict smallness condition $Z(0)<a/C$.
Then $Z(t)\le Z(0)$ for all $t\ge 0$; in particular $Z$ is globally bounded and no
blow-up occurs.*

*Proof sketch.* Strict smallness gives a barrier: as long as $Z(t)<a/C$ we have
$Z'(t)\le Z(t)(CZ(t)-a)<0$ when $Z(t)>0$, so $Z$ is strictly decreasing and remains
$<a/C$, hence remains $\le Z(0)$. The set $\{t : Z(t)\le Z(0)\}$ is therefore both
open and closed in $[0,\infty)$ and contains $0$, so it is all of $[0,\infty)$.
Global boundedness immediately rules out finite-time blow-up. $\square$

*Remark.* Theorems 7–8 are the scalar core of small-data global regularity in 3D:
sufficiently small critical data yields a global smooth solution. The threshold
$a/C$ is the explicit dividing line; below it the three-dimensional flow behaves
qualitatively like a two-dimensional one (Theorem 2), while above it the present
methods give only the finite lifespan of Theorem 6. The gap between these regimes
*is* the open Navier–Stokes regularity problem.

### 3.5 The dissipation budget

Finally we integrate the energy identity. Here $F$ is assumed integrable on each
$[0,T]$ (e.g. continuous), so the Fundamental Theorem of Calculus applies.

**Theorem 9 / Theorem 11 (`total_dissipation_finite`, `energy_identity_FTC`).*
*Let $(E,F)$ be an energy–dissipation pair with $F$ continuous. Then for every
$T\ge 0$,*
$$E(T) = E(0) - 2\nu\int_0^T F(t)\,dt, \qquad\text{equivalently}\qquad
\int_0^T F(t)\,dt = \frac{E(0)-E(T)}{2\nu}.$$

*Proof sketch.* By the energy identity $E'=-2\nu F$; integrate both sides from $0$
to $T$ and apply the Fundamental Theorem of Calculus to the left-hand side:
$E(T)-E(0)=\int_0^T E'(t)\,dt = -2\nu\int_0^T F(t)\,dt$. Rearrange. $\square$

**Theorem 10 (`total_dissipation_bddAbove`).** *Under the same hypotheses, the
family of partial dissipation integrals is bounded above:*
$$\int_0^T F(t)\,dt \le \frac{E(0)}{2\nu}\quad\text{for all }T\ge 0,
\qquad\text{hence}\qquad \int_0^\infty F(t)\,dt \le \frac{E(0)}{2\nu}.$$

*Proof sketch.* From Theorem 9 and $E(T)\ge 0$, $\int_0^T F = (E(0)-E(T))/(2\nu)
\le E(0)/(2\nu)$. The bound is uniform in $T$, so the increasing function
$T\mapsto\int_0^T F$ (the integrand is $\ge 0$) is bounded above; its supremum,
$\int_0^\infty F$, satisfies the same bound. $\square$

*Remark.* The finite total-dissipation budget $\int_0^\infty F\le E(0)/(2\nu)$ is
among the most-used a priori estimates in mathematical fluid dynamics. It underlies
Leray's construction of global weak solutions, the Caffarelli–Kohn–Nirenberg
partial regularity theory (where local versions bound the parabolic Hausdorff
measure of the singular set), and the basic energy method throughout. It also
implies that $F$ cannot stay bounded below by a positive constant: the dissipation
must thin out over time, consistent with eventual decay.

---

## 4. Algorithms

The scalar framework is directly computable. We highlight two algorithms used in
the accompanying numerical demonstrations.

**Algorithm A (Threshold classifier for 3D competition dynamics).** Given
$(a, C, Z_0)$, decide global boundedness via the threshold test $Z_0 < a/C$
(Theorems 7–8), and, when above threshold, report the guaranteed lifespan from the
cubic comparison (Theorem 6). Complexity $O(1)$.

**Algorithm B (Sharp blow-up envelope evaluator).** Given the supercritical
constant $C$ and a blow-up time $T^\*$, evaluate the lower envelope $t\mapsto
(2C(T^\*-t))^{-1/2}$ of Theorem 5 and compare it against a numerically integrated
trajectory of $Z'=CZ^3$ to confirm sharpness. Complexity $O(N)$ for $N$ time steps.

Pseudocode and reference implementations appear in `demo.py` and in the
`algorithms` field of `PACKAGE.json`.

---

## 4.1 Numerical validation

Because every theorem is a statement about real-valued functions of time, each can
be stress-tested by direct numerical integration of the underlying differential
(in)equality. We summarize the validations carried out in the accompanying
`demo.py`; all use a fourth-order Runge–Kutta scheme and confirm the theorems to
high precision.

- **2D enstrophy trapping (Theorems 1–2).** Integrating $Z' = -2\nu D$ with
  $\nu=0.1$, $D(t)=(1+\sin^2 t)\,Z(t)\ge 0$, and $Z(0)=5$ over $[0,20]$ yields a
  trajectory that is non-increasing at every step and never exceeds $Z(0)$, with
  $Z(20)\approx 1.29\times10^{-2}$.

- **Exponential decay (Theorem 3, Corollary 4).** With $\nu=0.2$, $\lambda=1.5$,
  $F(t)=(\lambda+\cos^2 t)\,E(t)$, and $E(0)=3$, the computed energy stays below the
  closed-form envelope $E(0)e^{-2\nu\lambda t}$ at every step and reaches
  $E(30)\approx 1.2\times10^{-10}$; the guaranteed rate is $2\nu\lambda=0.6$.

- **Sharp blow-up rate (Theorems 5–6).** Integrating the borderline ODE
  $Z'=CZ^3$ with $C=0.5$, $Z(0)=2$ up to $0.99\,T^\*$, where
  $T^\*=1/(2CZ(0)^2)=0.25$, reproduces the exact solution with maximum relative
  error $\approx 1.4\times10^{-11}$ and saturates the lower envelope
  $(2C(T^\*-t))^{-1/2}$ to within $10^{-3}$, numerically certifying the sharpness of
  the exponent $\tfrac12$.

- **Small-data threshold (Theorems 7–8).** For $Z'=-aZ+CZ^2$ with $a=2$, $C=1$
  (threshold $a/C=2$): starting at $Z(0)=0.9\cdot(a/C)=1.8$ gives a trajectory that
  remains below $Z(0)$ and decays to $\approx 6.7\times10^{-43}$ by $t=50$, whereas
  starting at $Z(0)=1.1\cdot(a/C)=2.2$ the comparison ODE blows up at
  $t^\*\approx 1.20$.

- **Dissipation budget (Theorems 9–11).** Integrating $E'=-2\nu F$ alongside the
  cumulative dissipation $\int_0^T F$ with $\nu=0.15$, $E(0)=4$,
  $F=(1+\tfrac12\sin^2 3t)\,E$ over $[0,40]$ gives $\int_0^{40} F\approx 13.3333 =
  (E(0)-E(40))/(2\nu)$, matching the energy identity, and never exceeds the budget
  $E(0)/(2\nu)\approx 13.3333$.

The numerical agreement across all five regimes corroborates the analytic proof
sketches and, in the supercritical case, the optimality of the blow-up exponent.

## 5. Applications and connections

- **Ladyzhenskaya's theorem (2D).** Theorems 1–2 are the scalar engine: the
  enstrophy a priori bound $Z(t)\le Z(0)$ closes the energy estimates and yields
  global smoothness.
- **Blow-up criteria (3D).** Theorem 5 is the scalar form of the lower bounds on
  singularity rates that accompany the Beale–Kato–Majda and Leray-type criteria: a
  singularity, if it forms, must do so at a controlled minimum rate.
- **Small-data global regularity (3D).** Theorems 7–8 mirror the classical
  smallness theorems (e.g. small data in critical spaces) with an explicit
  threshold $a/C$.
- **Caffarelli–Kohn–Nirenberg partial regularity.** The global dissipation budget
  (Theorem 10) is the integral resource that, in localized form, bounds the size of
  the singular set; the present scalar statement is its prototype.
- **Machine learning for PDEs.** Scalar a priori inequalities of exactly this form
  serve as physics-informed constraints and certified Lyapunov functionals for
  learned surrogates of fluid solvers, where monotone energy/enstrophy budgets give
  provable stability guarantees for neural operators.

---

## 6. Discussion

The value of the scalar viewpoint is its *separation of concerns*. The hard PDE
analysis (Sobolev embeddings, Ladyzhenskaya's inequality, commutator estimates)
serves only to *derive* the scalar inequalities $Z'\le 0$ (2D), $Z'\le CZ^3$ (3D
supercritical), $Z'\le -aZ+CZ^2$ (3D competition), and $E'=-2\nu F$. Once derived,
the *consequences* — boundedness, decay, blow-up rate, threshold, dissipation
budget — are elementary and certain. The two-dimensional theory is complete; the
three-dimensional theory has an exactly delineated safe region (small data) and an
exactly quantified danger profile (the blow-up rate), with the open Millennium
Problem living precisely in the gap between "below threshold" and "arbitrary data."

A key structural insight is that the *sign and exponent* of the nonlinear term are
everything. The cubic exponent in $Z'\le CZ^3$ is *supercritical*: it overpowers
dissipation for large $Z$, which is why finite-time blow-up is not excluded. The
quadratic competition term $+CZ^2$ balanced against $-aZ$ is *barely* controllable —
only below an explicit threshold. Sharpening these inequalities (reducing the
exponent, or proving the production term is genuinely subcritical) would resolve the
problem; that is precisely what current PDE techniques cannot do in 3D.

---

## 7. Future directions

We restate here the research directions identified for this program.

**Conjecture 1 — Beale–Kato–Majda continuation (scalar form).** If $Z$ satisfies
$Z'\le CZ^3$ and $\int_0^T Z\,dt<\infty$, then $Z$ is bounded on $[0,T]$. A
testable log-improvement replaces $Z^3$ by $Z\cdot(Z^2\log(e+Z^2))$ and should
yield a finite-time bound governed by $\int Z\log(e+Z)$, with strictly longer
guaranteed lifetime than the pure-cubic version.

**Conjecture 2 — Ladyzhenskaya–Prodi–Serrin scalar threshold.** For $Z'\le
-aZ+C\,N(t)\,Z$ with forcing profile $N(t)\ge 0$ (the scalar shadow of a Serrin
norm), $Z$ is globally bounded iff $\limsup_{T\to\infty}\frac1T\int_0^T
(CN-a)^+\,dt\le 0$, with the time-average-critical case as the sharp threshold.

**Conjecture 3 — Two-mode Galerkin invariant region.** For $x'=-\nu x+xy$,
$y'=-\nu y-x^2$ (a minimal energy-conserving truncation), the disk $x^2+y^2\le R^2$
is forward invariant for every $R\ge 0$, and $x^2+y^2$ decays to $0$ at rate
$2\nu$, with the nonlinear terms contributing exactly zero to
$\frac{d}{dt}(x^2+y^2)$.

**Conjecture 4 — Enstrophy budget ⇒ vanishing dissipation.** From $\int_0^\infty
G<\infty$ there is a sequence $t_n\to\infty$ with $G(t_n)\to0$; under uniform
continuity, $G(t)\to0$ (Barbalat's lemma), and the uniform-continuity hypothesis is
necessary (tall thin spikes give an integrable $G$ with $G(t)\not\to0$).

**Conjecture 5 — Critical decay rate equals the Poincaré constant.** For the
linear-dominated regime $E'=-2\nu F$, $F\ge\lambda_1 E$, the optimal exponential
decay rate is exactly $2\nu\lambda_1$.

---

## 8. Conclusion

We have isolated and proved the scalar a priori core of Navier–Stokes regularity:
two-dimensional enstrophy trapping and the resulting global smoothness; exponential
energy decay to rest under a Poincaré inequality; the sharp supercritical blow-up
rate and matching lifespan in three dimensions; conditional and unconditional
small-data global bounds; and the integrated energy identity with its finite
total-dissipation budget. Each is a rigorous statement about real functions of
time, derived from transparent hypotheses, and together they form a clean, fully
verifiable backbone for the regularity theory — drawing in sharp relief both what
is settled and exactly where the great open problem remains.
