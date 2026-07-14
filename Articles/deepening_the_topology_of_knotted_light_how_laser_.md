# The Topology of Knotted Light: How Laser Beams Get Tangled

## A twist you cannot untwist

Shine an ordinary laser at a wall and you get a bright dot. But light can be
sculpted. With the right optics, a beam can be given a *twist* — its wavefronts
spiral around the propagation axis like the threads of a screw. Such a beam
carries **orbital angular momentum** (OAM): as it travels, it corkscrews through
space. Down the very center of that corkscrew runs a thread of perfect
darkness, a line where the light's amplitude vanishes exactly. This dark thread
is the beam's **phase singularity**, and it is the object at the heart of this
story.

The amount of twist is not a matter of degree. It is an *integer*. A beam can
carry one unit of twist, or two, or seventeen, or negative three (a corkscrew of
the opposite handedness) — but never one-and-a-half. This integer is called the
**topological charge** of the beam. It is one of the cleanest examples in all of
physics of a quantity that nature refuses to let vary continuously: it can only
jump.

Why can't it vary smoothly? Because it is a *topological* quantity — a property
of shape that survives bending, stretching, and squeezing. You can dim the beam,
widen it, pass it through a lens, or dress it up with any smooth envelope you
like, and the integer stays put. To change it you would have to tear something —
to create or destroy a thread of darkness. That robustness is exactly why knotted
light is being explored for high-capacity optical communication, for trapping and
spinning microscopic particles, and for encoding information in a way that resists
noise.

This article explains what that integer *is*, mathematically, and proves that it
behaves the way physicists have long assumed — that twists add up, that they are
conserved, that the dark envelope of a real beam cannot hide them, and, in a
surprising final twist, that for the special beams whose dark threads are tied
into knots, the topological charge is secretly an *arithmetic* fact about the
knot.

## Counting the twist: the winding number

To pin down the twist as a number, look at a single ring around the beam axis and
follow the light's phase as you walk once around the circle. The phase of a wave
is the position in its cycle — crest, trough, and everything between — and we can
represent the complex amplitude of the beam at azimuthal angle $\theta$ as a
point moving in the plane. As $\theta$ runs from $0$ to $2\pi$, that point traces
a closed loop. The **winding number** counts how many times the loop encircles
the origin, and with what handedness.

There is a beautiful formula for this count, borrowed from complex analysis. If
$\varphi(\theta)$ is the complex amplitude around the loop, its winding number is

$$w(\varphi) \;=\; \frac{1}{2\pi i} \oint \frac{\varphi'(\theta)}{\varphi(\theta)}\, d\theta.$$

The integrand $\varphi'/\varphi$ is the *logarithmic derivative* — the rate at
which the logarithm of $\varphi$ changes. Its real part tracks how the amplitude
grows or shrinks (which returns to where it started, contributing nothing over a
full loop), while its imaginary part tracks the accumulating phase. Integrate,
divide by $2\pi i$, and the amplitude bookkeeping cancels, leaving precisely the
net number of turns.

For the archetypal twisted beam, the phase around the ring is
$\varphi(\theta) = e^{i\ell\theta}$, where $\ell$ is an integer. Walking once
around, the phase advances by $2\pi\ell$; the loop encircles the origin exactly
$\ell$ times. The formula confirms it cleanly:

$$w\!\left(e^{i\ell\theta}\right) = \ell.$$

**The winding number equals the topological charge.** This is our first
theorem, and it is the anchor for everything that follows.

## The product rule: why twists add

Here is where the story deepens. Suppose you overlap two twisted beams so that
their amplitudes multiply — one carrying charge $\ell$, the other charge $m$.
Physicists expect the combined beam to carry charge $\ell + m$: twists add. But
*why*? The easy answer leans on the special form $e^{i\ell\theta}$: multiply two
exponentials and their exponents add. That argument, though, only works for that
one convenient ansatz.

The deeper truth is that additivity has nothing to do with exponentials at all.
It is a structural law of the winding-number integral itself. The key is the
logarithmic derivative's response to a product. By the ordinary Leibniz rule,
$(\varphi\psi)' = \varphi'\psi + \varphi\psi'$, and dividing through by
$\varphi\psi$ gives the clean splitting

$$\frac{(\varphi\psi)'}{\varphi\psi} = \frac{\varphi'}{\varphi} + \frac{\psi'}{\psi}.$$

The logarithmic derivative of a product is the *sum* of the logarithmic
derivatives. Integrate both sides around the loop and divide by $2\pi i$, and you
obtain the **contour-integral product rule**:

$$w(\varphi \cdot \psi) = w(\varphi) + w(\psi),$$

valid for *any* two loops that are differentiable, nowhere zero, and have
continuous logarithmic derivatives — no exponential ansatz required. This is the
structural heart of charge conservation in knotted light. Additivity of optical
charge, and the fact that superposing many beams sums their charges, both fall
out as genuine corollaries of this single law rather than as accidents of a
formula. Overlap a whole family of beams with charges $\ell_1, \ell_2, \ldots$
and the total charge is $\sum_i \ell_i$ — total optical charge is conserved.

## The dark envelope hides nothing

A real laser beam is not pure phase. The workhorse of the laboratory is the
**Laguerre–Gauss beam**, whose amplitude near the axis looks like

$$A(r,\theta) = r^{|\ell|}\, e^{i\ell\theta}.$$

The factor $r^{|\ell|}$ is the *radial envelope*: it forces the amplitude to
vanish on the axis $r = 0$ (that is the dark thread, the phase singularity) and
grows as you move outward. A skeptic might worry that this real, position-
dependent envelope muddies the clean integer charge. It does not.

The reason is that the winding number is blind to any nowhere-zero, single-valued
envelope. Rescaling a loop by a nonzero constant $c$ leaves its winding number
untouched — $w(c\,\varphi) = w(\varphi)$ — because the constant contributes zero
to the logarithmic derivative. Along any ring of fixed radius $r > 0$, the
envelope $r^{|\ell|}$ *is* just such a constant. So the full physical amplitude
carries exactly the same charge as its bare phase:

$$w\big(A(r,\cdot)\big) = \ell \qquad \text{for every } r > 0.$$

The integer twist is a robust label of the beam, immune to the amplitude
dressing that any real optical system imposes. That is precisely what makes it
useful as a carrier of information.

## Knots, and a bridge to number theory

Now for the most surprising turn. So far the dark thread has been a straight line
down the beam axis. But with cleverly engineered beams the phase singularity can
be bent into a closed loop in three-dimensional space — and not just any loop, but
a genuine **knot**. The simplest nontrivial example is the **trefoil**, the
familiar three-crossing pretzel knot.

These knotted singularities belong to a family called **torus knots**, each
labeled by a pair of integers $(p, q)$: the singularity winds $p$ times one way
and $q$ times the other around an invisible doughnut. The trefoil is the
$(2, 3)$ torus knot. For such a beam, the twist measured on a meridional ring —
the *meridional charge* — is the product $p \cdot q$. The trefoil therefore
carries charge $2 \cdot 3 = 6$.

And here is the bridge. A torus $(p, q)$ is a genuine, single-strand knot — as
opposed to several separate loops tangled together — exactly when $p$ and $q$
share no common factor, that is, when they are **coprime**. And coprimality is
*precisely* the condition under which the product $p \cdot q$ equals the **least
common multiple** $\operatorname{lcm}(p, q)$. So for any coprime torus-knot beam:

$$w = p \cdot q = \operatorname{lcm}(p, q).$$

For the trefoil, $\operatorname{lcm}(2, 3) = 6$, matching its charge exactly.

Read that again. On the left is a *topological* invariant — a winding number,
computed by an integral around a loop of light. On the right is an *arithmetic*
invariant — the least common multiple, a fact about the divisibility of two whole
numbers. The condition that the singularity be a single connected knot rather
than a split collection of links is the very same condition that makes these two
numbers agree. A property of tangled light turns out to be a property of the
numbers that name the tangle.

## Why it matters

There is a recurring lesson in physics: the quantities that survive are the ones
that cannot change by a little. Electric charge, quantum spin, the number of
times a vortex loops — these are integers, and their integrality is what makes
them dependable. The topological charge of knotted light joins that company. We
have seen that it is a winding number; that it obeys an exact product rule and so
adds and is conserved under superposition; that the physical envelope of a real
beam cannot alter it; and that, for knotted beams, it is quietly an arithmetic
fact about the knot.

Practically, the robustness of this integer is what lets engineers pack many
independent channels of information into a single beam of light, each channel
riding a different value of $\ell$, all of them stable against the smudging that
plagues ordinary optical signals. Conceptually, the appearance of the least
common multiple where one expected only geometry is a reminder that the deepest
structures in mathematics do not respect our departmental boundaries. Twisted
light, contour integrals, and elementary number theory turn out to be three views
of a single integer — the one you cannot untwist.
