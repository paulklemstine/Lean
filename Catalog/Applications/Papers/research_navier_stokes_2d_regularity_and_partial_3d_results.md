# Scalar A Priori Estimates for Navier–Stokes Regularity: 2D Global Bounds, 3D Blow-Up Rates, and the Logarithmic Borderline

## Abstract

The regularity theory of the incompressible Navier–Stokes equations reduces, via
the energy method, to a small family of *scalar differential inequalities* for
observables such as the energy $E(t)=\tfrac12\|u(t)\|_2^2$ and the enstrophy
$Z(t)=\tfrac12\|\omega(t)\|_2^2$. We isolate these inequalities and prove their
consequences rigorously and from first principles, sidestepping the (currently
intractable) formalization of the full partial differential equation while
capturing the exact analytic content that energy methods deliver. Our results
form a coherent ladder: (i) **two-dimensional global regularity**, in which the
vanishing of vortex stretching forces the enstrophy to be non-increasing; (ii)
**exponential energy decay** under a Poincaré-type dissipation bound, with
convergence to zero; (iii) the **three-dimensional supercritical a priori bound**
$Z(t)^2\le Z_0^2/(1-2CZ_0^2 t)$ with guaranteed lifetime $T^\*=1/(2CZ_0^2)$;
(iv) the dual **lower bound on the blow-up rate**, $Z(t)^2\ge 1/(2C(T^\*-t))$,
showing any finite-time singularity must diverge at least as fast as
$(T^\*-t)^{-1/2}$; (v) **small-data global regularity**, in which $CZ_0^2<a$ makes
the enstrophy invariant; (vi) the **logarithmic critical borderline**
$Z'\le CZ\log(e+Z)$, which we show is globally regular with explicit
double-exponential growth; and (vii) uniform **dissipation budgets**
$\int_0^T G\le Z_0/(2\nu)$ obtained by integrating the balance laws. A single
analytic engine — sign-definiteness, the integrating factor, and the reciprocal
substitution $w=1/Z^2$ — drives every proof. All results have been formally
verified.

**Keywords:** Navier–Stokes equations, enstrophy, vortex stretching, energy
method, a priori estimates, blow-up rate, Beale–Kato–Majda criterion, Poincaré
inequality, differential inequalities, global regularity.

---

## 1. Introduction

The incompressible Navier–Stokes system on a domain $\Omega\subseteq\mathbb R^d$,
$$\partial_t u + (u\cdot\nabla)u = -\nabla p + \nu\,\Delta u, \qquad
\nabla\cdot u = 0,$$
describes the velocity field $u$ and pressure $p$ of a viscous incompressible
fluid with kinematic viscosity $\nu>0$. Whether smooth initial data in three
dimensions always produce globally smooth solutions is one of the Clay
Millennium Problems and remains open. In two dimensions, by contrast, global
regularity has been known since the work of Leray, Ladyzhenskaya, and Hopf.

The dominant technique in the field is the **energy method**: one multiplies the
equations by a suitable quantity, integrates over space, and uses functional
inequalities (Poincaré, Sobolev, Ladyzhenskaya, Gagliardo–Nirenberg) to obtain a
closed differential inequality for a scalar observable. Regularity then hinges on
whether that scalar can remain finite. Two observables organize the theory:
$$E(t) = \tfrac12\int_\Omega |u(x,t)|^2\,dx \quad\text{(energy)}, \qquad
Z(t) = \tfrac12\int_\Omega |\omega(x,t)|^2\,dx \quad\text{(enstrophy)},$$
where $\omega=\nabla\times u$ is the vorticity. A standard continuation
principle states that a solution remains smooth precisely as long as its
enstrophy stays finite; finite-time blow-up is the divergence of $Z$.

This paper formalizes the differential-inequality layer of this theory. We treat
an abstract observable $Y:\mathbb R\to\mathbb R$ (or $E,Z$) whose time
derivative obeys the inequality produced by the relevant $L^2$ estimate, and we
prove the regularity, decay, lifetime, and blow-up-rate consequences with full
rigor. The point is that *all* of these consequences are pure one-dimensional
calculus once the inequality is granted; the deep PDE input is precisely the
inequality, and the deductions below are exactly what the energy method extracts
from it.

### Notation and standing conventions

Throughout, $Y, Z, E, G, F, D : \mathbb R\to\mathbb R$ are real functions of
time, with $D$ denoting the (pointwise) derivative of the relevant observable in
the hypothesis `HasDerivAt`. Constants $C, a, \nu, c$ are real; positivity
hypotheses are stated where needed. We write $Z_0=Z(0)$, $E_0=E(0)$. The symbol
$\|\cdot\|_2$ is the $L^2(\Omega)$ norm.

---

## 2. Two-dimensional global regularity

In two dimensions the vortex-stretching term $\int_\Omega \omega\cdot(\nabla u)\omega$
vanishes identically, because vorticity is a scalar and cannot be tilted into new
directions. The enstrophy identity therefore reduces to pure dissipation,
$Z'(t) = -2\nu\,\|\nabla\omega(t)\|_2^2 \le 0$, and the enstrophy is monotone.

**Theorem 2.1 (2D enstrophy global bound).** *Let $Z$ be differentiable with
$Z'(t)=D(t)$ and suppose $D(t)\le 0$ for all $t$. Then $Z(t)\le Z(0)$ for every
$t\ge 0$.*

*Proof sketch.* A function whose derivative is everywhere non-positive is
non-increasing (`antitone_of_deriv_nonpos`): differentiability at every point
follows from the pointwise `HasDerivAt` hypotheses, and $\operatorname{deriv}Z(t)=D(t)\le 0$.
Monotonicity applied to $0\le t$ gives $Z(t)\le Z(0)$. $\qquad\blacksquare$

**Theorem 2.2 (physical form).** *Let $\nu\ge 0$, let $G(t)\ge 0$ be the
palinstrophy $\|\nabla\omega(t)\|_2^2$, and suppose $Z'(t)=-2\nu\,G(t)$. Then
$Z(t)\le Z(0)$ for all $t\ge 0$.*

*Proof sketch.* The product $-2\nu\,G(t)$ is non-positive because $\nu\ge0$ and
$G\ge0$; apply Theorem 2.1. $\qquad\blacksquare$

This is the scalar core of Ladyzhenskaya's 2D global regularity theorem: the
enstrophy is trapped below its initial value for all time, the continuation
criterion is never triggered, and the solution is global.

---

## 3. Energy decay via the Poincaré inequality

On a bounded domain the Poincaré inequality $\|\nabla u\|_2^2 \ge \lambda_1\|u\|_2^2$
upgrades the energy identity $E'(t)=-2\nu\|\nabla u\|_2^2$ to a closed linear
inequality $E'(t)\le -c\,E(t)$ with $c=2\nu\lambda_1>0$.

**Theorem 3.1 (exponential energy decay).** *Let $E$ be differentiable with
$E'(t)=D(t)$ and suppose $D(t)\le -c\,E(t)$ for all $t$ and some $c\in\mathbb R$.
Then $E(t)\le E(0)\,e^{-ct}$ for all $t\ge 0$.*

*Proof sketch.* Introduce the integrating factor and set $g(t)=E(t)e^{ct}$. By
the product rule, $g'(t)=(D(t)+cE(t))e^{ct}$. The hypothesis makes
$D(t)+cE(t)\le 0$, and $e^{ct}>0$, so $g'(t)\le 0$ and $g$ is non-increasing.
Hence $g(t)\le g(0)=E(0)$, i.e. $E(t)e^{ct}\le E(0)$, which rearranges to the
claim. No sign hypothesis on $E$ or $c$ is required. $\qquad\blacksquare$

**Theorem 3.2 (energy tends to zero).** *If in addition $c>0$ and $E(t)\ge 0$
for all $t$, then $E(t)\to 0$ as $t\to\infty$.*

*Proof sketch.* By Theorem 3.1, $0\le E(t)\le E(0)e^{-ct}$ eventually; the right
side tends to $0$ because $c>0$, so a squeeze (`squeeze_zero_norm'`) forces
$E(t)\to0$. $\qquad\blacksquare$

The integrating-factor argument is the prototype reused throughout: a linear
differential inequality always linearizes to a monotone auxiliary function.

---

## 4. The three-dimensional supercritical bound

In three dimensions vortex stretching survives, and the best Sobolev/interpolation
control of $\int\omega\cdot(\nabla u)\omega$ is *cubic* in the enstrophy:
$Z'(t)\le C\,Z(t)^3$. This inequality is **supercritical** — it permits
finite-time blow-up — and the resulting a priori bound is only local in time.

**Theorem 4.1 (3D a priori / blow-up-rate bound).** *Let $C>0$, $Z(t)>0$,
$Z'(t)=D(t)$ with $D(t)\le C\,Z(t)^3$. Then for every $t$ with
$0\le t < T^\*:=\dfrac{1}{2C\,Z(0)^2}$,*
$$Z(t)^2 \;\le\; \frac{Z(0)^2}{1 - 2C\,Z(0)^2\,t}.$$

*Proof sketch.* Set $w(t)=1/Z(t)^2$. Differentiating and using $Z'\le CZ^3$ with
$Z>0$ gives the *linear* lower bound $w'(t)\ge -2C$ (the cubic cancels exactly
against the chain-rule factor $-2/Z^3$). By the mean value theorem on $[0,t]$
(`exists_deriv_eq_slope`), $w(t)-w(0)\ge -2Ct$, i.e. $w(t)\ge w(0)-2Ct$.
Equivalently $1/Z(t)^2 \ge 1/Z(0)^2 - 2Ct$; on $t<T^\*$ the right side is
positive, and taking reciprocals yields the stated bound. The denominator
vanishes exactly at $T^\*$, encoding the guaranteed lifetime. $\qquad\blacksquare$

The substitution $w=1/Z^2$ is decisive: it converts a runaway cubic inequality,
inaccessible to Grönwall (whose comparison solution itself blows up), into a tame
linear one, turning blow-up into the positivity threshold $w(t)>0 \iff t<T^\*$.

---

## 5. The lower bound on the blow-up rate

The reciprocal substitution, read in the forward direction toward a putative
singularity, yields the dual statement: a singularity cannot form gradually.

**Lemma 5.1 (lower Lipschitz bound for $w=1/Z^2$).** *Under the hypotheses of
Theorem 4.1, for all $t\le s$,*
$$\frac{1}{Z(s)^2} \;\ge\; \frac{1}{Z(t)^2} - 2C\,(s-t).$$

*Proof sketch.* Identical to the MVT step in Theorem 4.1 but on the interval
$[t,s]$: $w'\ge -2C$ everywhere, so the slope of $w$ over $[t,s]$ is $\ge -2C$.
$\qquad\blacksquare$

**Lemma 5.2 (reciprocal square vanishes at blow-up).** *If $Z(s)\to+\infty$ as
$s\to T^{\*-}$ (i.e. along the left neighborhood filter $\mathcal N_{<}(T^\*)$),
then $1/Z(s)^2\to 0$ along the same filter.*

*Proof sketch.* $Z\to+\infty$ gives $Z^2\to+\infty$, hence $1/Z^2\to0$ by
composition with $x\mapsto 1/x$ at $+\infty$. $\qquad\blacksquare$

**Theorem 5.3 (lower blow-up rate).** *Let $C>0$, $Z(t)>0$, $Z'(t)=D(t)\le
C\,Z(t)^3$, and suppose the enstrophy blows up at the finite time $T^\*$:
$Z(s)\to+\infty$ as $s\to T^{\*-}$. Then for every $t<T^\*$,*
$$Z(t)^2 \;\ge\; \frac{1}{2C\,(T^\*-t)}, \qquad\text{equivalently}\qquad
\|\omega(t)\|_2 \;\gtrsim\; (T^\*-t)^{-1/2}.$$

*Proof sketch.* Fix $t<T^\*$. By Lemma 5.1, the inequality
$1/Z(s)^2 \ge 1/Z(t)^2 - 2C(s-t)$ holds for all $s$ in a left neighborhood of
$T^\*$. Let $s\to T^{\*-}$: the left side tends to $0$ by Lemma 5.2, while the
right side tends to $1/Z(t)^2 - 2C(T^\*-t)$. Passing to the limit
(`le_of_tendsto_of_tendsto`, using that $T^\*\in\overline{(-\infty,T^\*)}$ so the
filter is `NeBot`) gives $1/Z(t)^2 - 2C(T^\*-t)\le 0$, i.e.
$1/Z(t)^2 \le 2C(T^\*-t)$, which rearranges to the claim. $\qquad\blacksquare$

This is the scalar analogue of the Leray and Beale–Kato–Majda lower bounds: a
singularity must announce itself by the universal rate $(T^\*-t)^{-1/2}$, and
conversely no blow-up can occur while the enstrophy stays $o((T^\*-t)^{-1/2})$.

---

## 6. Small-data global regularity in 3D

When dissipation competes with stretching, the closed inequality becomes
$Z'(t)\le -a\,Z(t) + C\,Z(t)^3$. In the small-data regime the linear draining
term wins permanently.

**Theorem 6.1 (conditional exponential decay).** *Let $C\ge0$ and suppose a
uniform a priori bound $Z(t)\le M$ and $Z(t)\ge0$ hold, with $Z'(t)=D(t)\le
-a\,Z(t)+C\,Z(t)^3$. Then for all $t\ge0$,*
$$Z(t)\le Z(0)\,e^{-(a-CM^2)\,t}.$$

*Proof sketch.* On $0\le Z\le M$ one has $CZ^3=CZ^2\cdot Z\le CM^2 Z$, so
$D(t)\le -a Z + CM^2 Z = -(a-CM^2)Z(t)$. Apply Theorem 3.1 with rate $c=a-CM^2$.
The decay is genuine precisely when $CM^2\le a$. $\qquad\blacksquare$

**Theorem 6.2 (unconditional small-data invariance).** *Let $Z(0)>0$,
$Z'(t)=D(t)\le -a\,Z(t)+C\,Z(t)^3$, and suppose $C\,Z(0)^2 < a$. Then
$Z(t)\le Z(0)$ for all $t\ge0$.*

*Proof sketch.* Suppose not; then $Z$ exceeds $Z(0)$ somewhere on $[0,t]$. Let
$s$ be the last time on $[0,t]$ at which $Z(s)=Z(0)$ (it exists by compactness
and continuity, since the level set $\{u\in[0,t]:Z(u)\le Z(0)\}$ is compact and
contains $0$, and a supremum/closure argument upgrades $\le$ to $=$). At that
point $C\,Z(s)^2=C\,Z(0)^2<a$, so $D(s)\le -aZ(s)+CZ(s)^3 = Z(s)(CZ(0)^2-a)<0$.
A strictly negative derivative at $s$ forces $Z$ to *decrease* just to the right
of $s$ (via the slope characterization `HasDerivAt.tendsto_slope`), contradicting
that $Z>Z(0)$ for all $u>s$ in $[0,t]$. Hence the assumption fails and
$Z(t)\le Z(0)$. $\qquad\blacksquare$

Theorem 6.2 is the scalar shadow of small-data global regularity: when the
initial enstrophy is small relative to viscosity, the a priori bound is
self-sustaining and no blow-up can occur.

---

## 7. The logarithmic critical borderline

Between the safe linear regime $Z'\le -aZ$ and the dangerous supercritical regime
$Z'\le CZ^3$ lies the critical borderline carrying a logarithmic correction,
$$Z'(t)\le C\,Z(t)\,\log\!\big(e+Z(t)\big),$$
the scalar shadow of the logarithmically improved Beale–Kato–Majda continuation
criterion. We show this borderline is globally regular.

**Theorem 7.1 (logarithmic borderline is globally regular).** *Let $C>0$,
$Z(t)\ge0$, $Z'(t)=D(t)\le C\,Z(t)\log(e+Z(t))$. Then $Z$ exists for all time and
obeys the explicit double-exponential bound*
$$Z(t)\le \exp\!\big(\log(e+Z(0))\cdot e^{Ct}\big) - e.$$

*Proof sketch.* Set $v(t)=\log(e+Z(t))\ge1$. By the chain rule
$v'(t)=Z'(t)/(e+Z(t))$. Using $Z'\le CZ\log(e+Z)$ together with
$Z/(e+Z)\le 1$ and $\log(e+Z)\ge0$ yields the *linear* inequality
$v'(t)\le C\,v(t)$. The integrating-factor comparison of Theorem 3.1 (with rate
$-C$) gives $v(t)\le v(0)\,e^{Ct}$, i.e. $\log(e+Z(t))\le \log(e+Z(0))\,e^{Ct}$.
Exponentiating and subtracting $e$ gives the stated double-exponential bound,
which is finite at every finite $t$; hence no finite-time blow-up.
$\qquad\blacksquare$

Double-exponential growth is the fastest growth still compatible with global
existence; the logarithmic correction sits exactly on the knife's edge and falls
on the regular side.

---

## 8. Dissipation budgets

A complementary, integrated viewpoint records the *total* dissipation by the
fundamental theorem of calculus rather than pointwise bounds.

**Theorem 8.1 (enstrophy balance).** *Let $G$ be continuous and
$Z'(t)=-2\nu\,G(t)$. Then for every $T$,*
$$Z(T)-Z(0) = -2\nu\int_0^T G(t)\,dt.$$

*Proof sketch.* Apply the FTC (`intervalIntegral.integral_eq_sub_of_hasDerivAt`):
$Z(T)-Z(0)=\int_0^T Z'(t)\,dt=\int_0^T -2\nu\,G(t)\,dt$, and pull the constant
out; interval-integrability of the continuous integrand is automatic.
$\qquad\blacksquare$

**Theorem 8.2 (2D dissipation budget).** *Let $\nu>0$, $Z(t)\ge0$, $G$
continuous, $Z'(t)=-2\nu\,G(t)$. Then for all $T\ge0$,*
$$\int_0^T G(t)\,dt \;\le\; \frac{Z(0)}{2\nu}, \qquad\text{uniformly in }T.$$

*Proof sketch.* From Theorem 8.1, $2\nu\int_0^T G = Z(0)-Z(T)\le Z(0)$ since
$Z(T)\ge0$; divide by $2\nu>0$. $\qquad\blacksquare$

**Theorem 8.3 (energy budget).** *Under the analogous hypotheses for $E'=-2\nu F$
with $E\ge0$ and $F$ continuous, $\int_0^T F\,dt\le E(0)/(2\nu)$ for all
$T\ge0$.*

*Proof sketch.* Identical bookkeeping with $E,F$ in place of $Z,G$.
$\qquad\blacksquare$

**Theorem 8.4 (budgets are bounded above).** *The family of partial dissipation
integrals $\{\int_0^T G : T\ge0\}$ is bounded above by $Z(0)/(2\nu)$.*

*Proof sketch.* Theorem 8.2 exhibits $Z(0)/(2\nu)$ as a uniform upper bound,
which is exactly `BddAbove` of the range. $\qquad\blacksquare$

These uniform-in-$T$ bounds are the convergence-enabling estimates behind
$\int_0^\infty G<\infty$ in 2D and the Leray–Hopf weak-solution theory in general.

---

## 9. Algorithms

The estimates above are not only qualitative; each yields a concrete numerical
recipe. We highlight three.

**Algorithm A (guaranteed lifetime / blow-up envelope).** Given $C$ and $Z_0$,
return $T^\*=1/(2CZ_0^2)$ and the envelope $t\mapsto Z_0^2/(1-2CZ_0^2 t)$ on
$[0,T^\*)$. Complexity $O(1)$ per evaluation. This certifies the time horizon over
which a 3D flow is provably smooth.

**Algorithm B (blow-up-rate certificate).** Given an observed (or simulated)
enstrophy trace and a candidate singular time $T^\*$, test the lower envelope
$Z(t)^2\ge 1/(2C(T^\*-t))$. A trace that violates it for $t\to T^\*$ *cannot* be
blowing up at $T^\*$ — a falsifiable, computable regularity certificate.

**Algorithm C (double-exponential majorant for the log-borderline).** Given $C$
and $Z_0$, return $t\mapsto \exp(\log(e+Z_0)e^{Ct})-e$, a rigorous upper majorant
for any solution of the logarithmic borderline inequality.

---

## 10. Applications and discussion

The scalar a priori layer formalized here is exactly the bridge between the
abstract PDE and the numbers a practitioner can compute:

- **Certified time horizons.** Theorem 4.1 gives an explicit lower bound on the
  existence time of a 3D flow from a single norm of the initial data — directly
  usable as a safety margin in simulation.
- **Singularity exclusion.** Theorem 5.3 turns the absence of fast enstrophy
  growth into a rigorous *no-blow-up* certificate, and Theorem 6.2 does the same
  for small data.
- **Relaxation rates.** Theorems 3.1–3.2 quantify how fast a forced flow returns
  to rest, the scalar content of long-time attractor theory.
- **Budget accounting.** The uniform budgets of Section 8 are the finite
  resources that make weak-solution theory work.

We emphasize what is and is not done. We do *not* formalize the Navier–Stokes PDE
itself, nor the function-analytic derivation of the inequalities (Poincaré,
Sobolev, Ladyzhenskaya), which require infrastructure beyond current libraries.
We *do* formalize, with full rigor, the deductive layer: given the inequality the
energy method produces, the regularity, decay, lifetime, blow-up-rate, and budget
conclusions follow exactly as stated. In this sense the results are faithful
scalar shadows of Ladyzhenskaya's 2D theorem, Leray's structure theory, the
Beale–Kato–Majda criterion, and small-data global regularity.

A unifying observation: every proof runs on the same engine. Sign-definiteness
gives 2D monotonicity; the integrating factor $e^{ct}$ gives linear decay and the
logarithmic borderline; the reciprocal substitution $w=1/Z^2$ gives both the 3D
upper a priori bound and its dual lower blow-up rate. The nonlinearity is always
removed by a single well-chosen change of variable.

---

## 11. Future directions

The same engine extends in several directions, each formalizable as a scalar
differential-inequality theorem over an abstract observable.

- **General power-law dichotomy.** For $Z'\le CZ^p$ with $p>1$ and
  $\alpha=1/(p-1)$, the substitution $w=Z^{-(p-1)}$ obeys $w'\ge -(p-1)C$ and
  should yield simultaneously the upper lifetime bound
  $Z(t)^{p-1}\le Z_0^{p-1}/(1-(p-1)CZ_0^{p-1}t)$ and the lower blow-up rate
  $Z(t)\gtrsim (T^\*-t)^{-\alpha}$. The present results are the case $p=3$,
  $\alpha=1/2$.
- **Time-dependent forcing and a moving absorbing ball.** For
  $Y'\le -aY+b(t)$ with $\beta=\limsup_{t\to\infty}b(t)<\infty$, conjecturally
  $\limsup_{t\to\infty}Y(t)\le\beta/a$ and the ball $\{Y\le\beta/a+\varepsilon\}$
  is absorbing, via the integrating factor $Y(t)e^{at}$.
- **Two-mode energy/enstrophy coupling (2D Ladyzhenskaya shadow).** Coupling
  $E'\le -2\nu\lambda_1 E$ and $Z'\le -2\nu Z+\kappa EZ$ with $E$ decaying
  exponentially gives $\int_0^\infty E<\infty$ and hence
  $Z(t)\le Z_0\exp(\kappa\int_0^\infty E)<\infty$ — a two-variable closure of the
  2D global bound.

Each conjecture is falsifiable and pitched at the same abstraction level as the
theorems above, making it a direct target for formalization.

---

## 12. Conclusion

We have given rigorous, formally verified proofs of the scalar a priori estimates
at the heart of Navier–Stokes regularity theory: 2D global enstrophy bounds,
exponential energy decay and convergence, the 3D supercritical lifetime bound and
its dual lower blow-up rate, small-data invariance, the global regularity of the
logarithmic critical borderline, and uniform dissipation budgets. The results are
organized by a single principle — linearize the nonlinear scalar inequality by a
sign, an integrating factor, or a reciprocal substitution — and together they map
the precise boundary between the regimes where viscous flow is guaranteed smooth
and the regime where, in the worst case, it need not be.
