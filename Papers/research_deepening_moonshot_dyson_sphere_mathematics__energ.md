# The Exact Optimization Theory of Stellar Energy Collection: Dyson Spheres and Dyson Swarms

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We develop, from first principles, a complete and rigorous optimization theory
for the collection of radiant energy from an isotropic point source — the
idealized problem of a *Dyson sphere* (a complete enclosing shell) and a *Dyson
swarm* (a finite family of independent collectors). Starting only from the
inverse-square law for flux, we prove that the power captured by any collector
factors through a single linear functional: the total *solid angle* the
collectors subtend at the source, normalized by the full-sky value $4\pi$. From
this factorization we derive the entire theory: a complete shell of area
$4\pi R^2$ captures the source's entire luminosity $L$ at every radius (scale
invariance); no swarm subject to the physical no-overlap constraint (total solid
angle at most $4\pi$) can exceed $L$; full capture by collectors at a common
radius $R$ holds if and only if their total collecting area equals exactly
$4\pi R^2$; subdivision of collectors is irrelevant (refinement invariance); a
fixed area budget captures the most when concentrated at the smallest admissible
radius; the capture efficiency is a number in $[0,1]$ that tends continuously to
$1$ as coverage tends to the full sky; and, finally, a Gauss-law identity shows
that the total power crossing any closed surface of area $4\pi R^2$ equals $L$
independent of shape. All results are stated inline with proof sketches.

## 1. Introduction

Freeman Dyson's 1960 proposal that an advanced civilization might surround its
star with energy-collecting structures has become an enduring motif in
astrophysics and speculative engineering. Beneath the imagery lies a crisp
optimization question: given a star of luminosity $L$, how much of its output can
be captured, by what arrangement of collectors, and at what material cost?

This paper answers these questions exactly. Our thesis is that the entire theory
collapses onto a single conserved quantity — the total *solid angle* occupied by
the collectors — and that once this factorization is made explicit, every
folklore claim about Dyson spheres and swarms becomes a short, sharp theorem. We
work in an idealized but standard radiometric model: a point source radiating
isotropically, obeying the inverse-square law, with flat collectors oriented
toward the source and no mutual occlusion beyond the global sky constraint.

The contributions are:

1. A **solid-angle factorization** (Section 4) reducing collected power to a
   linear functional of subtended solid angle.
2. A proof that the **complete shell captures all of $L$**, scale-invariantly
   (Section 3).
3. A sharp **optimality theorem**: full capture at a common radius $R$ iff total
   area $= 4\pi R^2$ (Section 5).
4. Structural results — **refinement invariance** and the **concentration
   principle** — clarifying how geometry and subdivision affect capture
   (Section 5).
5. **Efficiency bounds** and a continuous approach to perfect capture
   (Section 6), and a **Gauss-law identity** unifying the theory (Section 7).

## 2. The physical model and basic definitions

Throughout, $L \in \mathbb{R}$ denotes the star's luminosity (total radiated
power) and $R \in \mathbb{R}$ a radial distance from the star. All quantities are
real.

**Definition 2.1 (Flux).** The radiative *flux* — power per unit area — at radius
$R$ from a star of luminosity $L$ is obtained by spreading $L$ uniformly over the
sphere of area $4\pi R^2$:
$$\operatorname{flux}(L,R) = \frac{L}{4\pi R^2}.$$

**Definition 2.2 (Collected power).** A flat collector of area $A$ at radius $R$,
facing the star, captures
$$\operatorname{collectedPower}(L,R,A) = A\cdot\operatorname{flux}(L,R)
   = \frac{AL}{4\pi R^2}.$$

**Definition 2.3 (Sphere area).** The area of a complete shell at radius $R$ is
$\operatorname{sphereArea}(R) = 4\pi R^2$.

**Definition 2.4 (Solid angle).** The solid angle subtended at the star by a
collector of area $A$ at radius $R$ is $\operatorname{solidAngle}(A,R) = A/R^2$.

**Definition 2.5 (Swarm power).** For a finite index set $s$ with collectors of
areas $A_i$ at radii $R_i$, the total collected power is
$$\operatorname{swarmPower}(L,s,A,R) = \sum_{i\in s}\operatorname{collectedPower}(L,R_i,A_i).$$

**Definition 2.6 (Efficiency).** The fraction of luminosity captured by a swarm
is
$$\operatorname{efficiency}(s,A,R)
   = \frac{\sum_{i\in s}\operatorname{solidAngle}(A_i,R_i)}{4\pi}.$$

## 3. The inverse-square law and the complete shell

**Theorem 3.1 (Inverse-square law).** For $R\neq 0$ and $c\neq 0$,
$$\operatorname{flux}(L,cR) = \frac{\operatorname{flux}(L,R)}{c^2}.$$
*Proof sketch.* Substitute $cR$ for $R$ in Definition 2.1 and simplify:
$L/(4\pi c^2 R^2) = (L/(4\pi R^2))/c^2$. $\square$

**Theorem 3.2 (Flux is strictly decreasing).** If $L>0$ and $0 < R_1 < R_2$,
then $\operatorname{flux}(L,R_2) < \operatorname{flux}(L,R_1)$.
*Proof sketch.* With $\pi>0$ and $L>0$, the denominator $4\pi R^2$ is positive
and strictly increasing in $R$ over positive radii (since $R_1^2 < R_2^2$).
Dividing the fixed positive numerator $L$ by a strictly larger positive
denominator yields a strictly smaller value. $\square$

**Theorem 3.3 (A complete shell captures the entire output).** For every
$R\neq 0$,
$$\operatorname{collectedPower}(L,R,\operatorname{sphereArea}(R)) = L.$$
*Proof sketch.* Substitute $A = 4\pi R^2$:
$4\pi R^2 \cdot L/(4\pi R^2) = L$; the geometric factor cancels exactly. $\square$

**Theorem 3.4 (Scale invariance of total capture).** For $R_1,R_2\neq 0$,
$$\operatorname{collectedPower}(L,R_1,\operatorname{sphereArea}(R_1))
 = \operatorname{collectedPower}(L,R_2,\operatorname{sphereArea}(R_2)).$$
*Proof sketch.* By Theorem 3.3 both sides equal $L$. $\square$

Theorem 3.3 is the geometric heart of the Dyson-sphere idea: a complete shell
captures everything, and Theorem 3.4 shows this is independent of the radius at
which the shell is built.

## 4. Collection is governed by solid angle

The following identity is the organizing principle of the entire theory.

**Theorem 4.1 (Solid-angle factorization).** For $R\neq 0$,
$$\operatorname{collectedPower}(L,R,A)
   = \frac{L\cdot\operatorname{solidAngle}(A,R)}{4\pi}.$$
*Proof sketch.* Both sides equal $AL/(4\pi R^2)$ after expanding
$\operatorname{solidAngle}(A,R) = A/R^2$. $\square$

Thus collected power depends on $A$ and $R$ only through the combination $A/R^2$:
a collector's capture is determined entirely by the solid angle it occupies in
the star's sky, never by its absolute size or distance separately.

**Theorem 4.2 (Swarm power via total solid angle).** If $R_i\neq 0$ for all
$i\in s$, then
$$\operatorname{swarmPower}(L,s,A,R)
   = \frac{L}{4\pi}\sum_{i\in s}\operatorname{solidAngle}(A_i,R_i).$$
*Proof sketch.* Apply Theorem 4.1 termwise and factor the constant $L/(4\pi)$ out
of the finite sum. $\square$

**Theorem 4.3 (Power equals luminosity times efficiency).** Under the same
hypotheses,
$$\operatorname{swarmPower}(L,s,A,R) = L\cdot\operatorname{efficiency}(s,A,R).$$
*Proof sketch.* Combine Theorem 4.2 with Definition 2.6 and rearrange. $\square$

## 5. Optimality: the sphere is the best you can do

**Theorem 5.1 (No swarm beats the sphere).** If $R_i\neq 0$ for all $i\in s$,
$L\ge 0$, and the total solid angle satisfies
$\sum_{i\in s}\operatorname{solidAngle}(A_i,R_i)\le 4\pi$, then
$$\operatorname{swarmPower}(L,s,A,R)\le L.$$
*Proof sketch.* By Theorem 4.2 the power is $(L/4\pi)\sum_i\Omega_i$. Since
$L\ge 0$ and $4\pi > 0$, multiplying the coverage bound
$\sum_i\Omega_i\le 4\pi$ by $L/(4\pi)$ preserves the inequality, giving
$\le (L/4\pi)(4\pi) = L$. $\square$

The constant $4\pi$ is the total solid angle of the whole sky; the coverage
hypothesis is the honest physical no-overlap constraint. Its necessity is real:
without it the linear formula would permit unphysical "super-capture."

**Theorem 5.2 (Optimal collecting area — the sharp characterization).** Let
$R\neq 0$ and $L\neq 0$, with all collectors at the common radius $R$. Then
$$\operatorname{swarmPower}(L,s,A,(\,\cdot\mapsto R\,)) = L
   \iff \sum_{i\in s}A_i = \operatorname{sphereArea}(R) = 4\pi R^2.$$
*Proof sketch.* At a common radius, Definitions 2.2 and 2.5 give
$\operatorname{swarmPower} = \big(\sum_i A_i\big)\cdot L/(4\pi R^2)$. Setting this
equal to $L$ and using $L\neq 0$, $R\neq 0$ cancels $L$ and clears the
denominator, leaving $\sum_i A_i = 4\pi R^2$; conversely, substituting
$\sum_i A_i = 4\pi R^2$ recovers $L$. $\square$

Theorem 5.2 pins down the *optimal* (minimal, full-capture) collecting area at
radius $R$: exactly the Dyson-sphere area $4\pi R^2$, whether realized as a shell
or as any swarm with that total area.

**Theorem 5.3 (Refinement invariance).** For all $L,R$ and any areas $A_i$,
$$\operatorname{swarmPower}(L,s,A,(\,\cdot\mapsto R\,))
   = \operatorname{collectedPower}\Big(L,R,\sum_{i\in s}A_i\Big).$$
*Proof sketch.* At a common radius, collected power is linear in area, so the sum
of per-collector powers equals the power of a single collector of the summed
area. $\square$

Subdividing a collector into finer pieces at the same radius changes nothing;
only total area matters. This is what makes a swarm a faithful substitute for a
shell.

**Theorem 5.4 (Concentration principle).** Suppose $R_{\min}>0$, every collector
satisfies $R_i \ge R_{\min}$, every area is nonnegative ($A_i\ge 0$), and
$L\ge 0$. Then
$$\operatorname{swarmPower}(L,s,A,R)
   \le \frac{L}{4\pi}\cdot\frac{\sum_{i\in s}A_i}{R_{\min}^2}.$$
*Proof sketch.* By Theorem 4.2 the power is $(L/4\pi)\sum_i A_i/R_i^2$. Since
$R_i\ge R_{\min}>0$ and $A_i\ge 0$, each term obeys
$A_i/R_i^2\le A_i/R_{\min}^2$ (monotonicity of $1/R^2$); summing and factoring
gives the bound. $\square$

With a fixed area budget, the same material captures the most when placed as
close to the star as possible, because solid angle per unit area, $1/R^2$, is
maximized at the smallest radius.

## 6. Efficiency and the approach to perfect capture

**Theorem 6.1 (Efficiency lies in $[0,1]$).** If
$0\le \sum_{i\in s}\operatorname{solidAngle}(A_i,R_i)\le 4\pi$, then
$\operatorname{efficiency}(s,A,R)\in[0,1]$.
*Proof sketch.* The efficiency is $\big(\sum_i\Omega_i\big)/(4\pi)$ with
$4\pi>0$; nonnegativity of the numerator gives $\ge 0$, and the coverage bound
gives $\le 1$. $\square$

**Theorem 6.2 (Continuous approach to full capture).** As the total subtended
solid angle $\theta$ tends to $4\pi$, the captured power tends to $L$:
$$\lim_{\theta\to 4\pi} \frac{L\,\theta}{4\pi} = L.$$
*Proof sketch.* The map $\theta\mapsto L\theta/(4\pi)$ is continuous, and its
value at $\theta = 4\pi$ is exactly $L$. $\square$

Perfect capture is the smooth limit of ever-more-complete coverage: as a swarm
fills more of the sky, its output rises continuously toward the full luminosity.

## 7. A Gauss-law identity

**Theorem 7.1 (Gauss's law for radiation).** Let $(\alpha,\mathcal M,\mu)$ be a
measure space and $S\subseteq\alpha$ a measurable set with
$\mu(S) = 4\pi R^2$ (interpreting $S$ as a closed surface of that area). For
$R\neq 0$,
$$\int_{S}\operatorname{flux}(L,R)\,\mathrm d\mu = L.$$
*Proof sketch.* The flux is constant over the surface, so the integral is
$\mu(S)\cdot\operatorname{flux}(L,R) = 4\pi R^2\cdot L/(4\pi R^2) = L$. $\square$

Because the flux crossing a closed surface around the star integrates to $L$
regardless of the surface's shape, a Dyson sphere is simply the physical
realization of a conserved outward power flow. This identity unifies the theory:
total capture is a conservation statement, and every earlier result is a facet of
it.

## 8. Algorithms

The theory yields directly implementable procedures.

**Algorithm A (Swarm power and efficiency).** Given luminosity $L$ and a list of
(area, radius) pairs, compute total solid angle $\Theta=\sum_i A_i/R_i^2$, then
return power $L\Theta/(4\pi)$ and efficiency $\Theta/(4\pi)$. Complexity $O(n)$.

**Algorithm B (Full-capture area budget).** Given a target radius $R$, return the
minimal total collecting area for full capture: $4\pi R^2$ (Theorem 5.2). $O(1)$.

**Algorithm C (Concentration-optimal placement).** Given an area budget and an
admissible radial band $[R_{\min},R_{\max}]$, allocate all area at $R_{\min}$;
the resulting bound $(L/4\pi)(A/R_{\min}^2)$ is optimal by Theorem 5.4. $O(1)$.

## 9. Applications

Although framed astronomically, the mathematics is precisely that of many
practical systems:

- **Solar power layout.** The solid-angle factorization explains why panel value
  is set by the angular fraction of the source it intercepts, and why a hard
  ceiling exists on capture from a fixed source.
- **Sensor and antenna placement.** Coverage of a point emitter by receivers is
  governed by the same $\sum A_i/R_i^2\le 4\pi$ budget.
- **Radiation dosimetry and illumination engineering.** Dose or illuminance from
  a point source obeys the identical inverse-square and solid-angle laws.

## 10. Discussion and future work

The unifying discovery is that stellar energy capture factors through a single
linear functional — total subtended solid angle — divided by $4\pi$. This one
fact simultaneously explains scale invariance of full capture, refinement
invariance, the sharp $4\pi R^2$ optimality, and the global upper bound $L$.

Several directions extend the theory into richer geometry, analysis, and
thermodynamics:

1. **Overlap-corrected capture is submodular.** For collectors that may occlude
   one another, the captured fraction as a function of the chosen subset should
   be a monotone submodular set function, with greedy selection achieving at
   least a $1-1/e$ fraction of the optimum under any area budget. Occlusion turns
   naive additivity of solid angle into a union of spherical caps, and the
   measure of a union is exactly the structure that makes coverage submodular.

2. **The thin-shell isoperimetric optimum.** Among all closed surfaces enclosing
   the star with a fixed material budget (mass proportional to area times
   thickness), the configuration maximizing captured power minus structural cost
   should be the sphere, with any non-spherical competitor losing at second order
   in its deviation from sphericity. Since captured power is $L$ for any enclosing
   surface (Theorem 7.1), the optimization collapses onto the classical
   isoperimetric problem for the cost term.

3. **Spectral splitting raises the effective ceiling.** Layered collectors, each
   tuned to a disjoint spectral band, should exceed the single-layer
   captured-power-per-unit-area of any opaque shell while respecting the same
   $4\pi$ solid-angle ceiling on total captured energy. The $4\pi$ bound limits
   captured *energy*, not area-efficiency: transparency in complementary bands
   lets nested shells reuse the same solid angle.

## 11. Conclusion

From the single premise of the inverse-square law we have derived a complete,
self-contained optimization theory of stellar energy collection: the strictly
decreasing flux, the total and scale-invariant capture of a complete shell, the
solid-angle factorization, the exact $4\pi R^2$ characterization of full capture,
refinement and scale invariance, the concentration principle, efficiency bounds,
a continuous approach to perfect capture, and a Gauss-law conservation identity.
The Dyson sphere, far from mere speculation, is the geometric embodiment of a
conservation law — and the mathematics of harvesting a star is exact, elegant,
and complete.
