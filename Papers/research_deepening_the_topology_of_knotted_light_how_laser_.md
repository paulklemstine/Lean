# The Topology of Knotted Light: A Contour-Integral Product Rule for Optical Charge

## Abstract

A laser beam carrying orbital angular momentum (OAM) — "knotted light" — is
characterized by an azimuthal phase factor $e^{i\ell\theta}$ whose integer $\ell$
is the *topological charge* of the phase singularity threading the beam axis. The
charge is captured classically by the logarithmic-derivative contour integral
$w(\varphi) = \tfrac{1}{2\pi i}\oint \varphi'/\varphi\, d\theta$. Prior treatments
compute this only for the closed-form phase $e^{i\ell\theta}$ by unfolding the
exponential. We go deeper. We prove a **general product rule for the winding
number**, $w(\varphi\cdot\psi) = w(\varphi) + w(\psi)$, directly from the contour
integral, for arbitrary differentiable, non-vanishing loops with continuous
logarithmic derivative. From this single structural law, additivity and
conservation of optical charge follow as genuine contour-integral corollaries
rather than as artifacts of the exponential ansatz. We further show the winding
number is invariant under multiplication by any nonzero constant envelope, so the
full physical Laguerre–Gauss amplitude — not merely its phase — carries the same
integer charge. Finally we establish a bridge to number theory: for a coprime
$(p,q)$-torus-knot beam, the meridional charge $p\cdot q$ coincides with
$\operatorname{lcm}(p,q)$; the trefoil is the coprime pair $(2,3)$ with charge
$6 = \operatorname{lcm}(2,3)$. A purely topological invariant of knotted light
thereby equals an arithmetic invariant of its knot type.

**Keywords:** orbital angular momentum, topological charge, winding number,
logarithmic derivative, Laguerre–Gauss beam, torus knot, trefoil, coprimality,
least common multiple.

## 1. Introduction

Light can be structured so that its wavefronts spiral about the propagation axis,
endowing the beam with orbital angular momentum. Along the axis of such a beam the
amplitude vanishes identically, producing a line of darkness — a **phase
singularity**. The phase circulates about this singularity, and the net
circulation over one turn is quantized to an integer $\ell$, the **topological
charge**. This integrality is the source of the practical appeal of "knotted
light": the charge is a discrete, robust label suitable for multiplexing optical
communication channels, for optical trapping and micromanipulation, and for noise-
resistant information encoding.

The standard tool for extracting the charge from a beam is the winding-number
contour integral of complex analysis. It is folklore that optical charges add
under superposition and are conserved, and that the physical radial envelope does
not affect the charge. Our aim is to establish these facts as theorems flowing
from a single structural principle — the product rule for the winding number —
proved directly at the level of the contour integral, and then to exhibit an
unexpected identity connecting the charge of a torus-knot beam to the arithmetic
of its knot parameters.

The contributions are:

1. A general **product rule** $w(\varphi\psi) = w(\varphi) + w(\psi)$ for winding
   numbers of arbitrary admissible loops (Section 4).
2. **Envelope invariance**: $w(c\,\varphi) = w(\varphi)$ for any nonzero constant
   $c$, whence the full Laguerre–Gauss amplitude carries the phase's charge
   (Section 5).
3. **Additivity and conservation** of optical charge as corollaries of the product
   rule (Section 6).
4. A **topology/number-theory bridge**: for coprime $(p,q)$ the torus-knot beam
   charge $p\cdot q$ equals $\operatorname{lcm}(p,q)$ (Section 7).

## 2. Definitions

Throughout, a *loop* is a function $\varphi : \mathbb{R} \to \mathbb{C}$
considered over one full azimuthal turn $\theta \in [0, 2\pi]$; we write
$\varphi'$ for its derivative.

**Definition 1 (OAM phase field).** For an integer charge $\ell$, the azimuthal
phase field of an OAM beam is
$$\operatorname{oam}_\ell(\theta) \;=\; e^{\,i\,\ell\,\theta\,} \;=\; \exp\!\big((\ell)\,\theta\, i\big), \qquad \theta \in \mathbb{R}.$$

**Definition 2 (Physical beam amplitude).** The Laguerre–Gauss-like amplitude of
radial order $|\ell|$ is
$$A_\ell(r,\theta) \;=\; r^{\,|\ell|}\, \operatorname{oam}_\ell(\theta), \qquad r \ge 0.$$
The factor $r^{|\ell|}$ forces $A_\ell(0,\theta) = 0$ when $\ell \ne 0$: this is
the on-axis phase singularity of knotted light.

**Definition 3 (Winding number).** The winding number of a loop $\varphi$ is the
logarithmic-derivative contour integral over one turn,
$$w(\varphi) \;=\; \frac{1}{2\pi i}\int_{0}^{2\pi} \frac{\varphi'(\theta)}{\varphi(\theta)}\, d\theta.$$

**Definition 4 (Torus-knot beam).** For integers $p, q$, the $(p,q)$-torus-knot
beam is the OAM field of charge $p\cdot q$,
$$T_{p,q}(\theta) \;=\; \operatorname{oam}_{pq}(\theta).$$
Its meridional charge is the winding number $w(T_{p,q})$. The trefoil is
$T_{2,3}$.

An *admissible* loop is one that is everywhere differentiable, nowhere zero, and
whose logarithmic derivative $\varphi'/\varphi$ is continuous on $[0,2\pi]$;
admissibility guarantees the integrand is integrable.

## 3. The winding number of a pure OAM phase

We first record the elementary properties of the OAM phase field and evaluate its
winding number, anchoring the identification *winding number = topological
charge*.

**Lemma 1 (Differentiability of the phase).** For every $\ell \in \mathbb{Z}$ and
$\theta \in \mathbb{R}$,
$$\operatorname{oam}_\ell'(\theta) = i\,\ell\, \operatorname{oam}_\ell(\theta).$$

*Proof sketch.* The inner map $\theta \mapsto \ell\,\theta\, i$ is real-linear
with derivative $\ell\, i$; composing with the entire exponential (whose
derivative is itself) and applying the chain rule yields the factor
$i\,\ell\,\operatorname{oam}_\ell(\theta)$. $\square$

**Lemma 2 (Non-vanishing).** $\operatorname{oam}_\ell(\theta) \ne 0$ for all
$\theta$, since the complex exponential never vanishes.

**Theorem 1 (Topological charge = winding number).** For every integer $\ell$,
$$w(\operatorname{oam}_\ell) = \ell.$$

*Proof sketch.* By Lemmas 1–2 the integrand simplifies pointwise:
$$\frac{\operatorname{oam}_\ell'(\theta)}{\operatorname{oam}_\ell(\theta)} = \frac{i\,\ell\,\operatorname{oam}_\ell(\theta)}{\operatorname{oam}_\ell(\theta)} = i\,\ell,$$
a constant. Hence
$$w(\operatorname{oam}_\ell) = \frac{1}{2\pi i}\int_0^{2\pi} i\,\ell\, d\theta = \frac{1}{2\pi i}\,(2\pi)\,(i\,\ell) = \ell. \qquad \square$$

## 4. The contour-integral product rule

The central structural result is that the winding number is additive under
pointwise multiplication of loops. Crucially, the proof works at the level of the
integral and does not use the special form $e^{i\ell\theta}$.

**Theorem 2 (Product rule).** Let $\varphi, \psi$ be admissible loops — each
everywhere differentiable, nowhere zero, with continuous logarithmic derivative.
Then
$$w(\varphi\cdot\psi) = w(\varphi) + w(\psi).$$

*Proof sketch.* By the Leibniz rule, $(\varphi\psi)' = \varphi'\psi + \varphi\psi'$.
Dividing by $\varphi\psi$ (legitimate since both are nowhere zero) yields the
pointwise identity
$$\frac{(\varphi\psi)'}{\varphi\psi} = \frac{\varphi'}{\varphi} + \frac{\psi'}{\psi}.$$
Continuity of $\varphi'/\varphi$ and $\psi'/\psi$ makes each a Riemann-integrable
function on $[0,2\pi]$, so the interval integral distributes over the sum:
$$\int_0^{2\pi}\frac{(\varphi\psi)'}{\varphi\psi}\,d\theta = \int_0^{2\pi}\frac{\varphi'}{\varphi}\,d\theta + \int_0^{2\pi}\frac{\psi'}{\psi}\,d\theta.$$
Multiplying by $\tfrac{1}{2\pi i}$ gives $w(\varphi\psi) = w(\varphi) + w(\psi)$.
$\square$

The hypotheses are load-bearing: continuity of the logarithmic derivatives feeds
integrability, and non-vanishing feeds the algebraic splitting.

## 5. Envelope invariance and the physical amplitude

**Theorem 3 (Constant-envelope invariance).** For any nonzero constant
$c \in \mathbb{C}$ and any loop $\varphi$,
$$w(c\,\varphi) = w(\varphi).$$

*Proof sketch.* Under the convention that division by zero returns zero, the
integrands agree pointwise: $(c\varphi)'/(c\varphi) = c\varphi'/(c\varphi) =
\varphi'/\varphi$, the constant $c$ cancelling in numerator and denominator. Hence
the integrals — and the winding numbers — coincide. Notably this requires
*neither* differentiability *nor* non-vanishing of $\varphi$; only $c \ne 0$ is
needed. $\square$

**Theorem 4 (Charge of the full amplitude).** For every integer $\ell$ and every
radius $r > 0$, the physical amplitude carries the phase's charge:
$$w\big(\theta \mapsto A_\ell(r,\theta)\big) = \ell.$$

*Proof sketch.* Fix $r > 0$. Then $A_\ell(r,\theta) = r^{|\ell|}\,
\operatorname{oam}_\ell(\theta)$ with the *constant* prefactor
$c = r^{|\ell|} > 0$, in particular $c \ne 0$. Theorem 3 gives
$w(A_\ell(r,\cdot)) = w(\operatorname{oam}_\ell)$, and Theorem 1 evaluates the
latter as $\ell$. $\square$

Thus the real, positive radial envelope contributes nothing to the winding
number: the integer charge is a robust label of the beam, independent of the
amplitude dressing imposed by any physical optical system.

## 6. Additivity and conservation of optical charge

**Theorem 5 (Additivity via the product rule).** For integers $\ell, m$,
$$w\big(\theta \mapsto \operatorname{oam}_\ell(\theta)\,\operatorname{oam}_m(\theta)\big) = w(\operatorname{oam}_\ell) + w(\operatorname{oam}_m) = \ell + m.$$

*Proof sketch.* Each OAM phase is admissible: differentiable (Lemma 1), nowhere
zero (Lemma 2), with logarithmic derivative identically $i\ell$ (resp. $i m$),
which is continuous. Theorem 2 applies, giving the first equality; Theorem 1
evaluates each summand. The result is obtained *without* unfolding the
exponential — additivity is a consequence of the product rule, not of
$e^{i\ell\theta}e^{im\theta} = e^{i(\ell+m)\theta}$. $\square$

**Theorem 6 (Conservation over a family).** For a finite family of beams indexed
by $s$ with charges $f(i)$, the superposition (product) has total charge
$$w\left(\theta \mapsto \prod_{i \in s} \operatorname{oam}_{f(i)}(\theta)\right) = \sum_{i \in s} f(i).$$

*Proof sketch.* The product of OAM phases is again an OAM phase:
$\prod_{i} \operatorname{oam}_{f(i)}(\theta) = \operatorname{oam}_{\sum_i f(i)}(\theta)$,
by additivity of exponents. Applying Theorem 1 to the aggregate charge
$\sum_i f(i)$ gives the total. Equivalently, iterate the product rule (Theorem 2)
over the family. Total optical charge is conserved under superposition. $\square$

## 7. A bridge to number theory: torus-knot beams

**Theorem 7 (Torus-knot charge).** For integers $p, q$,
$$w(T_{p,q}) = p \cdot q.$$

*Proof sketch.* By definition $T_{p,q} = \operatorname{oam}_{pq}$; apply
Theorem 1 with charge $pq$. $\square$

**Theorem 8 (Topology ↔ number theory).** For natural numbers $p, q \ge 1$ that
are coprime,
$$w(T_{p,q}) = \operatorname{lcm}(p, q).$$

*Proof sketch.* When $\gcd(p,q) = 1$ we have the arithmetic identity
$\operatorname{lcm}(p,q) = p\cdot q$. Combined with Theorem 7, the meridional
charge $p \cdot q$ equals $\operatorname{lcm}(p,q)$. $\square$

**Corollary (Trefoil).** The trefoil beam is $T_{2,3}$, the coprime pair $(2,3)$,
and its topological charge is
$$w(T_{2,3}) = 2 \cdot 3 = 6 = \operatorname{lcm}(2,3).$$

The identity is sharp: coprimality is exactly the condition under which the torus
$(p,q)$ is a genuine (non-split, single-component) knot, and it is exactly the
condition under which $\operatorname{lcm}(p,q) = p\cdot q$. The left-hand side is a
topological invariant (a winding number computed by a contour integral); the
right-hand side is an arithmetic invariant of the knot type. Their coincidence
under coprimality unifies the optics, analysis, and number-theory views of a
single integer.

## 8. Algorithms

We summarize the computational content in three procedures. Complexity is stated
in terms of $N$, the number of quadrature nodes, and the size of the beam family.

**Algorithm A (Numerical winding number).** Discretize $[0,2\pi]$ into $N$ nodes,
form the logarithmic-derivative integrand from finite differences (or the
analytic derivative when available), integrate by the trapezoidal rule, and divide
by $2\pi i$. Rounding the (nearly real integer) result recovers the charge.
Complexity $O(N)$.

**Algorithm B (Charge of a superposition).** Given a family of charges
$\{\ell_i\}$, either (i) sum them directly by the additivity theorem in $O(k)$ for
$k$ beams, or (ii) form the product loop numerically and apply Algorithm A as a
verification, in $O(kN)$. The two must agree by Theorem 6.

**Algorithm C (Torus-knot charge and knot test).** Given $(p,q)$, compute the
charge $p\cdot q$, the $\gcd$ by the Euclidean algorithm in $O(\log\min(p,q))$,
and $\operatorname{lcm}(p,q) = pq/\gcd(p,q)$. The beam's singularity is a single
knot iff $\gcd(p,q) = 1$, in which case charge $= \operatorname{lcm}$.

## 9. Applications

- **Optical communication.** The integrality and robustness of the charge make
  distinct $\ell$-values orthogonal, independently addressable channels. The
  product rule guarantees predictable behavior when channels are combined.
- **Optical trapping and micromanipulation.** OAM beams exert torque on trapped
  particles proportional to $\ell$; envelope invariance (Theorem 4) certifies that
  focusing and apodization do not alter the delivered charge.
- **Robust encoding.** Because the charge is topological, it is immune to smooth
  perturbations of amplitude — a discrete, error-resilient degree of freedom.
- **Knot-theoretic beam design.** The torus-knot bridge (Theorem 8) offers a
  design dictionary: choose a knot type $(p,q)$, read off the charge, and use
  coprimality to guarantee a single connected singularity.

## 10. Discussion

The central conceptual point is that additivity and conservation of optical charge
are *not* properties of the exponential ansatz but of the logarithmic derivative.
The winding number is a homomorphism-like functional: it converts pointwise
multiplication of loops into addition of integers. This is why every admissible
beam — however engineered — obeys the same conservation law, and why the physical
envelope is invisible to the charge. The number-theoretic bridge is a reminder
that a topological invariant can encode arithmetic: the very condition
(coprimality) that makes a torus curve a genuine knot is the condition that makes
its charge equal to the least common multiple of its parameters.

## 11. Future work

Several directions extend these results (stated in full in the accompanying
future-directions notes): characterizing the winding number as a surjective group
homomorphism onto $(\mathbb{Z},+)$ with kernel the loops admitting a single-valued
logarithm; promoting the coprimality/lcm identity to a count of connected
components of the singularity ($\gcd(p,q)$ components, knot vs. split link);
upgrading conservation over families to a homotopy-invariance statement in
$\mathbb{C}\setminus\{0\}$; and proving charge quantization survives arbitrary
nowhere-zero, single-valued radial and polarization dressings.

## 12. Conclusion

We have established the topological charge of knotted light as an additive
invariant governed by a contour-integral product rule
$w(\varphi\psi) = w(\varphi) + w(\psi)$, shown the charge is carried by the full
physical amplitude and not merely its phase, derived additivity and conservation
as corollaries, and bridged the charge of a torus-knot beam to the arithmetic
$\operatorname{lcm}$ of its knot parameters. The trefoil $(2,3)$ realizes the
smallest nontrivial instance, with charge $6 = \operatorname{lcm}(2,3)$. Optics,
complex analysis, and number theory thereby meet in a single integer.
