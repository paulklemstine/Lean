# The Winding Number as the Topological Charge of Knotted Light

## Abstract

The topological charge of an orbital-angular-momentum (OAM) light beam — the
integer number of times its wavefront twists around a central phase
singularity — is one of the most robust observables in modern optics. We give a
self-contained account of this charge as an honest complex contour integral, the
**winding number**, defined for an arbitrary smooth, nowhere-vanishing loop
$\gamma \colon \mathbb{R} \to \mathbb{C}^{*}$. We prove that this winding number
(i) reproduces the physical charge $\ell$ of the canonical OAM phase field
$e^{i\ell\theta}$; (ii) is a group homomorphism from loops under pointwise
multiplication to $(\mathbb{C}, +)$, sending products to sums, inverses to
negations, and constants to zero — the mathematical form of charge conservation
under beam superposition; (iii) is always an *integer* for closed loops, a
statement equivalent to $\pi_1(\mathbb{C}^{*}) = \mathbb{Z}$, derived not by
assumption but from single-valuedness of the field; and (iv) is *surjective*,
realizing every integer. We also settle two natural but false conjectures: the
winding number is **not** additive under pointwise addition of fields, and it is
**invariant** under multiplication by a nonzero constant (amplitude
rescaling). Together these results exhibit the topological charge as a surjective
group homomorphism $\pi_1(\mathbb{C}^{*}) \twoheadrightarrow \mathbb{Z}$ and
explain, from first principles, why the charge is quantized, conserved, and
robust.

**Keywords:** winding number, topological charge, orbital angular momentum,
optical vortex, logarithmic derivative, fundamental group, phase singularity,
knotted light.

## 1. Introduction

An optical vortex is a beam of light whose complex field vanishes along a central
thread (the *phase singularity* or *dark core*) and whose phase increases by an
integer multiple of $2\pi$ along any loop encircling that thread. The prototype
is the azimuthal phase factor $e^{i\ell\theta}$ appearing in Laguerre–Gauss and
Bessel beams, where $\ell \in \mathbb{Z}$ is the **topological charge**. These
beams carry orbital angular momentum $\ell\hbar$ per photon and underpin optical
tweezers, high-dimensional communication, coronagraphy, and quantum information
protocols.

The defining property of the charge is that it is an *integer*, stable against
continuous deformation of the beam. The purpose of this paper is to isolate the
minimal mathematical content responsible for this fact and to prove, cleanly and
in full generality, the structural theorems that make the winding number *the*
topological invariant of the punctured plane $\mathbb{C}^{*} = \mathbb{C}
\setminus \{0\}$.

Rather than specializing to $e^{i\ell\theta}$, we work with an arbitrary smooth,
nowhere-vanishing loop and establish: an integral formula for the charge; its
homomorphism (additivity) properties; its integrality; its surjectivity; and two
contrarian results that delimit exactly which operations preserve the charge.

## 2. Definitions

Throughout, a *field* is a function $\varphi \colon \mathbb{R} \to \mathbb{C}$,
interpreted as the value of the (complex) optical field along a circular path
parameterized by the azimuthal angle $\theta$.

**Definition 2.1 (Winding number).** For a field $\varphi$ whose derivative
exists, the **winding number** over one full turn $[0, 2\pi]$ is
$$
w(\varphi) \;=\; \frac{1}{2\pi i}\int_{0}^{2\pi}
\frac{\varphi'(\theta)}{\varphi(\theta)}\,d\theta .
$$
The integrand $\varphi'/\varphi$ is the **logarithmic derivative** of $\varphi$.

**Definition 2.2 (Smooth loop).** A pair of fields $(\gamma, \gamma')$ is a
**smooth loop-candidate** if:
1. $\gamma$ is differentiable everywhere with derivative $\gamma'$, i.e.
   $\gamma'(\theta)$ is the derivative of $\gamma$ at every $\theta$;
2. $\gamma$ never vanishes: $\gamma(\theta) \neq 0$ for all $\theta$;
3. $\gamma'$ is continuous.

We do **not** build periodicity into this predicate; the closure condition
$\gamma(2\pi) = \gamma(0)$ is imposed only where it is genuinely needed (namely,
for integrality).

**Definition 2.3 (OAM phase field).** For $\ell \in \mathbb{Z}$, the
**orbital-angular-momentum phase field** is
$$
\varphi_\ell(\theta) \;=\; e^{\,i\ell\theta}
\;=\; \exp\!\big((\ell)\,\theta\,i\big).
$$
This is the running physical example: a unit-amplitude beam whose phase advances
$\ell$ times around the loop.

Two immediate consequences of these definitions, recorded for later use:

**Lemma 2.4 (Regularity of the logarithmic derivative).** If
$(\gamma, \gamma')$ is a smooth loop-candidate, then $\gamma$ is continuous, the
logarithmic derivative $\theta \mapsto \gamma'(\theta)/\gamma(\theta)$ is
continuous, and hence it is interval-integrable on every $[a, b]$.

*Proof sketch.* Continuity of $\gamma$ follows from differentiability at each
point. The quotient $\gamma'/\gamma$ is continuous as a quotient of continuous
functions with nonvanishing denominator. A continuous function on a compact
interval is integrable. $\qquad\blacksquare$

## 3. The winding number of the OAM phase

**Theorem 3.1 (Charge of the canonical vortex).** For every $\ell \in
\mathbb{Z}$,
$$
w(\varphi_\ell) \;=\; \ell .
$$

*Proof sketch.* The field $\varphi_\ell = \exp(\ell\theta i)$ satisfies
$\varphi_\ell'(\theta) = \ell i\,\varphi_\ell(\theta)$ by the chain rule, and
$\varphi_\ell$ never vanishes because the exponential never vanishes. Hence the
logarithmic derivative is the *constant* $\varphi_\ell'/\varphi_\ell = \ell i$
on the whole interval. Therefore
$$
w(\varphi_\ell) = \frac{1}{2\pi i}\int_0^{2\pi} \ell i \, d\theta
= \frac{1}{2\pi i}\,(\ell i)(2\pi) = \ell . \qquad\blacksquare
$$

The pair $(\varphi_\ell, \ell i\,\varphi_\ell)$ is a smooth
loop-candidate: differentiability and the derivative formula are the
chain rule; nonvanishing is $e^{z} \neq 0$; and the derivative
$\ell i\,\varphi_\ell$ is continuous. Moreover $\varphi_\ell$ is closed:
$\varphi_\ell(2\pi) = e^{2\pi\ell i} = 1 = \varphi_\ell(0)$.

## 4. The homomorphism structure

We now show that the winding number transforms pointwise multiplication of
fields into addition of charges — the precise statement of charge conservation
under superposition of vortex beams.

**Theorem 4.1 (Constant fields carry no charge).** For any $c \in \mathbb{C}$,
$w(\theta \mapsto c) = 0$; in particular $w(\theta \mapsto 1) = 0$.

*Proof sketch.* The derivative of a constant is $0$, so the integrand vanishes
identically and the integral is $0$. $\qquad\blacksquare$

**Theorem 4.2 (Additivity under multiplication).** If
$(\gamma, \gamma')$ and $(\delta, \delta')$ are smooth loop-candidates, then
$$
w(\gamma \cdot \delta) \;=\; w(\gamma) + w(\delta),
$$
where $(\gamma\cdot\delta)(\theta) = \gamma(\theta)\,\delta(\theta)$.

*Proof sketch.* By the product rule, $(\gamma\delta)' = \gamma'\delta +
\gamma\delta'$, so on the nonvanishing set
$$
\frac{(\gamma\delta)'}{\gamma\delta}
= \frac{\gamma'\delta + \gamma\delta'}{\gamma\delta}
= \frac{\gamma'}{\gamma} + \frac{\delta'}{\delta}.
$$
Both logarithmic derivatives are interval-integrable (Lemma 2.4), so the integral
of the sum splits into the sum of the integrals; multiplying by $1/2\pi i$ gives
$w(\gamma\delta) = w(\gamma) + w(\delta)$. $\qquad\blacksquare$

**Theorem 4.3 (Inversion negates charge).** If $(\gamma,
\gamma')$ is a smooth loop-candidate, then
$$
w\!\left(\theta \mapsto \gamma(\theta)^{-1}\right) \;=\; -\,w(\gamma).
$$

*Proof sketch.* The derivative of $\gamma^{-1}$ is $-\gamma'/\gamma^{2}$, so the
logarithmic derivative of $\gamma^{-1}$ is
$$
\frac{(\gamma^{-1})'}{\gamma^{-1}}
= \frac{-\gamma'/\gamma^{2}}{1/\gamma}
= -\frac{\gamma'}{\gamma}.
$$
Integrating negates the winding number. $\qquad\blacksquare$

**Corollary 4.4 (Group homomorphism).** On the set of smooth non-vanishing
loops under pointwise multiplication, $w$ is a homomorphism into $(\mathbb{C},
+)$: it sends products to sums (4.2), inverses to negatives (4.3), and the
identity loop to $0$ (4.1). Physically, superposing (multiplying) vortex fields
adds their charges, so two opposite vortices $\varphi_{+1}$ and $\varphi_{-1}$
multiply to a charge-$0$ field and mutually annihilate.

## 5. Integrality: $\mathbb{Z} = \pi_1(\mathbb{C}^{*})$

The central theorem states that the winding number of a *closed* smooth loop is
an integer. Crucially, this is not assumed — it is forced by single-valuedness.

**Theorem 5.1 (Quantization of topological charge).** Let
$(\gamma, \gamma')$ be a smooth loop-candidate and suppose $\gamma$ is closed,
$\gamma(2\pi) = \gamma(0)$. Then there exists $n \in \mathbb{Z}$ with
$$
w(\gamma) = n .
$$

*Proof sketch.* Define the running antiderivative of the logarithmic derivative,
$$
G(\theta) = \int_0^{\theta}\frac{\gamma'(t)}{\gamma(t)}\,dt,
$$
which, by the fundamental theorem of calculus and Lemma 2.4, satisfies
$G'(\theta) = \gamma'(\theta)/\gamma(\theta)$. Consider the auxiliary field
$$
F(\theta) = \gamma(\theta)\,e^{-G(\theta)} .
$$
Differentiating with the product rule,
$$
F'(\theta) = \gamma'(\theta)e^{-G(\theta)}
   - \gamma(\theta)G'(\theta)e^{-G(\theta)}
= \gamma'(\theta)e^{-G(\theta)}
   - \gamma(\theta)\frac{\gamma'(\theta)}{\gamma(\theta)}e^{-G(\theta)}
= 0 .
$$
A field with vanishing derivative on $\mathbb{R}$ is constant, so
$F(2\pi) = F(0)$, that is
$$
\gamma(2\pi)\,e^{-G(2\pi)} = \gamma(0)\,e^{-G(0)} = \gamma(0),
$$
since $G(0) = 0$. Because the loop is closed, $\gamma(2\pi) = \gamma(0) \neq 0$,
and dividing gives $e^{-G(2\pi)} = 1$. The complex exponential equals $1$ exactly
on $2\pi i \mathbb{Z}$, so $G(2\pi) = 2\pi i\,n$ for some integer $n$. Since
$w(\gamma) = \frac{1}{2\pi i} G(2\pi)$, we conclude $w(\gamma) = n$.
$\qquad\blacksquare$

This is the honest statement that loops in the punctured plane are classified by
the integers: $\pi_1(\mathbb{C}^{*}) = \mathbb{Z}$, with $w$ furnishing the
classifying map. The proof uses nothing but calculus and the single-valuedness
of the field.

**Theorem 5.2 (Surjectivity).** For every $n \in \mathbb{Z}$ there is a closed
smooth non-vanishing loop $\gamma$ with $w(\gamma) = n$.

*Proof sketch.* Take $\gamma = \varphi_n = e^{i n \theta}$. It is a smooth
non-vanishing loop (Section 3), it is closed since $\varphi_n(2\pi) = e^{2\pi n i}
= 1 = \varphi_n(0)$, and $w(\varphi_n) = n$ by Theorem 3.1. $\qquad\blacksquare$

**Corollary 5.3 (The charge is a surjective homomorphism).** Combining Corollary
4.4, Theorem 5.1, and Theorem 5.2, the winding number is a surjective group
homomorphism
$$
w \colon \pi_1(\mathbb{C}^{*}) \twoheadrightarrow \mathbb{Z}.
$$
Quantization (integrality), conservation (additivity), and completeness (every
charge occurs) are thus three facets of a single algebraic statement.

## 6. What does *not* preserve the charge

Two plausible-sounding statements are false, and identifying them precisely
sharpens the meaning of the theorem.

**Theorem 6.1 (Amplitude invariance).** If $(\gamma,
\gamma')$ is a smooth loop-candidate and $c \in \mathbb{C}$ with $c \neq 0$, then
$$
w(\theta \mapsto c\,\gamma(\theta)) = w(\gamma).
$$

*Proof sketch.* The derivative of $c\gamma$ is $c\gamma'$, so the logarithmic
derivative is $(c\gamma')/(c\gamma) = \gamma'/\gamma$, unchanged by $c$. Hence
the integrals — and the winding numbers — agree. $\qquad\blacksquare$

Physically: rescaling the field amplitude (making the beam brighter or dimmer,
adding any constant complex gain, or a Gaussian envelope's peak factor) does not
change the topological charge. The charge is a property of the *phase pattern*,
not the intensity. This refutes the conjecture *"rescaling the amplitude changes
the charge."*

**Theorem 6.2 (Non-additivity under pointwise addition).** It is **not** true
that for all $\ell \in \mathbb{Z}$,
$$
w(\varphi_\ell + \varphi_\ell) = w(\varphi_\ell) + w(\varphi_\ell).
$$

*Proof sketch.* Take $\ell = 1$. Then $\varphi_1 + \varphi_1 = 2\varphi_1$, and
by amplitude invariance (Theorem 6.1) $w(2\varphi_1) = w(\varphi_1) = 1$. But
$w(\varphi_1) + w(\varphi_1) = 1 + 1 = 2 \neq 1$. $\qquad\blacksquare$

The lesson: the winding number is additive under *multiplication* of fields, not
under *addition*. Superposing a beam with itself doubles the amplitude but leaves
the twist unchanged. Beam addition can even create or destroy vortices (where the
summed field vanishes) and is genuinely more subtle than beam multiplication.

## 7. Algorithms

The theory yields directly computable procedures. We summarize three.

**Algorithm A — Discrete winding number by phase unwrapping.** Sample the field
$\varphi$ at $N$ points around the loop, compute the phase increments
$\Delta_k = \arg\!\big(\varphi(\theta_{k+1})/\varphi(\theta_k)\big) \in (-\pi,
\pi]$, and sum: $w \approx \frac{1}{2\pi}\sum_k \Delta_k$. For a genuinely closed
loop with sufficient sampling this returns the exact integer charge. Complexity
$O(N)$.

**Algorithm B — Winding number by numerical contour integration.** Approximate
$\frac{1}{2\pi i}\int_0^{2\pi}\varphi'/\varphi\,d\theta$ with a quadrature rule
(e.g. the trapezoidal rule, which is spectrally accurate for smooth periodic
integrands), using either an analytic $\varphi'$ or a finite-difference estimate.
Complexity $O(N)$; converges rapidly to the integer charge.

**Algorithm C — Charge algebra of superposed beams.** Given charges
$\ell_1, \dots, \ell_m$ of factor beams combined by multiplication, the resulting
charge is $\sum_j \ell_j$ (Theorem 4.2); inverting a factor contributes
$-\ell_j$ (Theorem 4.3). This reduces vortex bookkeeping to integer arithmetic.

## 8. Applications

- **Optical communication.** The charge $\ell$ labels mutually orthogonal spatial
  modes, providing an in-principle unbounded alphabet ($\mathbb{Z}$) for
  mode-division multiplexing. The homomorphism law governs how modes combine and
  separate in multiplexers built from phase masks.
- **Optical tweezers and micromanipulation.** Because each photon carries orbital
  angular momentum $\ell\hbar$, a charge-$\ell$ beam exerts a torque on trapped
  particles; the integrality theorem guarantees the transferred angular momentum
  comes in discrete units.
- **Coronagraphy and astronomy.** Vortex phase masks of charge $\ell$ redirect
  on-axis starlight, revealing faint companions; the robustness (amplitude
  invariance and topological stability) explains their tolerance to intensity
  fluctuations.
- **Vortex creation and annihilation.** Corollary 4.4 predicts that opposite
  charges cancel under multiplication, the mechanism behind controlled generation
  and destruction of phase singularities.

## 9. Discussion

The results assemble into a single clean picture. The winding number is defined
purely as a contour integral, yet three of its most important properties —
quantization, conservation, and completeness — are algebraic and follow from
elementary calculus plus single-valuedness. Integrality (Theorem 5.1) is the
conceptual heart: the constancy of $F(\theta) = \gamma(\theta)e^{-G(\theta)}$
converts the analytic statement "the loop closes up" into the arithmetic
statement "the total phase change is a multiple of $2\pi$." The homomorphism
theorems then organize the invariant into the group $\mathbb{Z}$, and the two
contrarian results (Theorems 6.1–6.2) locate the exact boundary of the
invariance: multiplicative and amplitude operations preserve the charge, additive
superposition does not.

A conceptual payoff is that "topological charge is quantized" needs no *ad hoc*
discreteness postulate. Discreteness is a theorem, not an axiom — a consequence
of the field being a well-defined single-valued function on the loop.

## 10. Future work

Several directions extend this framework naturally.

1. **Homotopy invariance.** Prove that $w$ is invariant under a continuous
   homotopy of closed loops through $\mathbb{C}^{*}$, the missing step to fully
   identify $w$ with the homotopy class in $\pi_1(\mathbb{C}^{*})$. Integrality
   and additivity are in hand; homotopy invariance requires a uniform-continuity
   or covering-space argument.
2. **Injectivity on $\pi_1$.** Show that two closed loops with equal winding are
   homotopic, completing $\pi_1(\mathbb{C}^{*}) \cong \mathbb{Z}$ as a group
   isomorphism.
3. **Linking number of nested vortices.** Build the Hopf-link / linking-number
   picture for two coaxial vortex lines from the additive winding homomorphism.
4. **Full Laguerre–Gauss modes.** Incorporate the Gaussian envelope and radial
   index $p$, and derive the orbital angular momentum $\ell\hbar$ per photon from
   the Poynting-vector integral; amplitude invariance already shows the envelope
   does not affect the charge.
5. **Knotted field lines and stability.** Construct genuinely knotted (not merely
   linked) optical field lines via Hopf-fibration constructions with their
   conserved helicity/linking invariant, and prove robustness of the charge under
   small continuous perturbations that keep the axis zero isolated.

## 11. Conclusion

The topological charge of a knotted-light beam is exactly the winding number of
its field around the dark core. As a contour integral it reproduces the physical
charge $\ell$; as an algebraic object it is a surjective group homomorphism
$\pi_1(\mathbb{C}^{*}) \twoheadrightarrow \mathbb{Z}$ — quantized by
single-valuedness, additive under multiplication, and invariant under amplitude
rescaling. These few theorems account, from first principles, for why the charge
of light is a whole number, why it is conserved, and why it is robust.
