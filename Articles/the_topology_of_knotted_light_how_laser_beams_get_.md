# The Topology of Knotted Light: How Laser Beams Get Tangled

Shine a laser pointer at a wall and you get a bright dot. Send that same light
through a carefully sculpted piece of glass — a hologram — and something stranger
can happen: the beam develops a dark thread running through its heart, a line
along which the light simply vanishes. This thread is not a defect. It is a
*phase singularity*, a place where the wave has no well-defined phase because its
amplitude is exactly zero. And here is the surprise that has fascinated physicists
for two decades: that dark thread can be tied into a knot.

Beams whose dark cores form loops, links, and knots are called **knotted light**.
You can make the singularity trace a simple ring, or two interlocking rings, or —
with enough cleverness — a genuine trefoil, the same three-crossing knot you tie
by accident in a garden hose. The light itself is perfectly smooth everywhere it
is bright; the topology lives entirely in the darkness threading through it.

This article is about a beautiful bridge between two worlds that seem to have
nothing to do with each other: the *knottedness* of that dark thread, a purely
topological fact, and the *angular momentum* the beam carries, a physically
measurable quantity. The claim we will explore and make precise is startling in
its economy:

> **The knot hidden in a beam of light writes its own algebraic fingerprint —
> its Alexander polynomial — into the spectrum of angular momentum the beam
> carries.**

Measure the twist of the light, and you can read off an invariant of the knot.

## Light that spins

Ordinary light carries momentum in the direction it travels — that is how a solar
sail works. Less familiar is that a beam can also *spin*. A beam whose wavefronts
form a corkscrew, like the threads of a screw, carries **orbital angular momentum**
(OAM). The number of intertwined helical sheets is an integer, $\ell$, and each
photon in such a beam carries angular momentum $\ell\hbar$. These "twisted" beams
are routine in the laboratory; $\ell$ can be $0, \pm 1, \pm 2$, and far beyond.

A knotted beam is not a single pure twist. It is a superposition — a chord, not a
single note — and it has an **OAM spectrum**: the set of angular-momentum values
$\ell$ that appear in the mix. The central question is simple to state: *which
values of $\ell$ are allowed, and what decides them?*

## The algebra of a knot

To answer that, we need one idea from knot theory. Every knot $K$ has an algebraic
shadow called its **Alexander polynomial**, written $\Delta_K(t)$. It is a
polynomial in a variable $t$, with whole-number coefficients, and it does not
change when you wiggle, stretch, or rearrange the knot without cutting it. Two
knots with different Alexander polynomials are genuinely, unavoidably different.
For the smallest knots it takes a strikingly simple form:

- the **unknot** (a plain unknotted loop): $\Delta(t) = 1$;
- the **trefoil** $3_1$ (three crossings): $\Delta(t) = t^2 - t + 1$;
- the **figure-eight** $4_1$ (four crossings): $\Delta(t) = t^2 - 3t + 1$;
- the **cinquefoil** $5_1$ (five crossings, the five-pointed star knot):
  $\Delta(t) = t^4 - t^3 + t^2 - t + 1$.

The conjecture at the heart of knotted light is that the OAM spectrum of a beam
whose dark thread is the knot $K$ consists of exactly those twists $\ell$ for
which the Alexander polynomial *dies* on the corresponding root of unity:

$$\text{OAM spectrum} \;=\; \Big\{\, \ell \;:\; \Delta_K\!\big(e^{2\pi i \ell / N}\big) = 0 \,\Big\},$$

where $N$ is a period set by the knot (its crossing number). In words: the
allowed twists are the ones that land the beam's phase exactly on a zero of the
knot's polynomial. The knot picks out its own harmonics.

Everything now hinges on one question with a clean answer: **where are the roots
of these polynomials?**

## The trefoil sings in sixth roots of unity

Take the trefoil, $\Delta(t) = t^2 - t + 1$. There is a lovely factorization
lurking here:

$$t^3 + 1 = (t + 1)\,(t^2 - t + 1).$$

So any $t$ with $t^3 = -1$, other than $t = -1$ itself, must be a root of the
trefoil polynomial. The solutions of $t^3 = -1$ are the sixth roots of unity that
are *not* cube roots of unity — precisely $e^{i\pi/3}$ and $e^{-i\pi/3}$, sitting
at $60^\circ$ above and below the real axis on the unit circle. Written as
$e^{2\pi i \ell/6}$, these correspond to $\ell = 1$ and $\ell = 5$.

The conclusion is exact: **the trefoil beam is quantized at $\ell = 1$ and
$\ell = 5$ (mod 6), and nowhere else.** In particular it is *not* quantized at
$\ell = 0$, because $\Delta(1) = 1 \neq 0$. There is a small poetry here: the
trefoil polynomial $t^2 - t + 1$ is the *sixth cyclotomic polynomial*, the
polynomial whose roots are exactly the primitive sixth roots of unity. The knot's
algebra and the geometry of the circle are the same object seen from two sides.

## The cinquefoil sings in tenth roots of unity

The five-crossing knot repeats the miracle one octave up. Its polynomial,
$t^4 - t^3 + t^2 - t + 1$, satisfies

$$t^5 + 1 = (t + 1)\,(t^4 - t^3 + t^2 - t + 1),$$

so its roots are the fifth roots of $-1$ other than $-1$ — the primitive
*tenth* roots of unity. The cinquefoil polynomial is exactly the tenth cyclotomic
polynomial, and the cinquefoil beam is quantized at $\ell = 1, 3, 7, 9$ (mod 10).
The trefoil and cinquefoil are the first two members of an infinite family (the
$(2, 2k+1)$ torus knots), and each one tunes light to a different set of roots of
unity.

## The figure-eight breaks the spell — and the golden ratio appears

Now something wonderful goes wrong. The figure-eight knot has polynomial
$\Delta(t) = t^2 - 3t + 1$. Its roots are not on the unit circle at all. Solving
the quadratic gives

$$t = \frac{3 \pm \sqrt{5}}{2}.$$

These are real numbers — one bigger than $1$, one smaller — and they are old
friends in disguise. The larger root, $(3+\sqrt5)/2 \approx 2.618$, is exactly
$\varphi^2$, the *square of the golden ratio* $\varphi = (1+\sqrt5)/2$. The
smaller root, $(3-\sqrt5)/2 \approx 0.382$, is $\psi^2$, the square of the golden
ratio's conjugate. Their product is exactly $1$: the roots are mirror images
across the unit circle, one just inside, one just outside, but *neither on it.*

This is not a technicality; it is the punch line. Because a genuine, measurable
twist $\ell$ corresponds to a point $e^{2\pi i \ell/N}$ that lives *on* the unit
circle, a knot can imprint clean root-of-unity OAM quantization only if its
Alexander roots sit on that circle. The trefoil and cinquefoil pass this test
gloriously. The figure-eight — the smallest knot to fail it — does not. Its
golden-ratio roots hover just off the circle, and the tidy "twist = zero of the
polynomial" dictionary breaks. The figure-eight is the boundary case that tells
us the phenomenon is real and delicate, not a coincidence of small numbers.

## Fingerprints you can double-check

A good theory leaves fingerprints, and these polynomials carry several that we can
verify independently of the OAM story.

**Reciprocity.** Alexander polynomials are *palindromic*: reading the coefficients
backward gives the same list. Precisely, $t^{\deg}\,\Delta(1/t) = \Delta(t)$. For
the trefoil, $t^2\,\Delta(1/t) = t^2(t^{-2} - t^{-1} + 1) = 1 - t + t^2 = \Delta(t)$.
The cinquefoil obeys the same law. This symmetry is why the figure-eight's two
roots came in a reciprocal pair $\varphi^2$ and $\varphi^{-2}$: reciprocity forces
roots to appear in mirror pairs across the unit circle.

**The knot determinant.** Evaluate $\Delta$ at $t = -1$ and take the absolute
value, and you get a classical invariant called the *knot determinant*. Here the
numbers come out clean: the trefoil gives $\lvert\Delta(-1)\rvert = 3$, the
figure-eight gives $5$, and the cinquefoil gives $5$. All three are odd — as the
determinant of any knot must be — and the trefoil's determinant of $3$ is exactly
why the trefoil is three-colorable, a fact schoolchildren can check with three
crayons and a drawing of the knot.

**Normalization.** Every knot satisfies $\Delta(1) = \pm 1$. The trefoil and
cinquefoil give $+1$; the figure-eight gives $-1$. This is the reason $\ell = 0$
is never in the spectrum: the polynomial is guaranteed *not* to vanish at $t = 1$.

## Why this matters

Strip away the equations and a genuinely new idea remains: **a topological
property of a beam of light — the knottedness of its dark core — can be read out
as a physical measurement of angular momentum.** Topology is famously robust.
You cannot untie a knot by nudging it; you have to cut. So information encoded
topologically is information protected against noise, jitter, and imperfection. A
laser beam whose darkness is knotted carries a number — an algebraic invariant of
the knot — that no gentle perturbation can erase.

The practical vision writes itself. Shine a beam through a hologram shaped like a
particular knot, and the emerging light carries that knot's Alexander polynomial
stamped into its measurable quantum numbers. Different knots produce different,
distinguishable OAM spectra: sixth roots of unity for the trefoil, tenth roots for
the cinquefoil, and the tell-tale golden-ratio signature — off the circle — for
the figure-eight. One could imagine encoding data in the *choice of knot*, with
the topology guarding it, and reading it back by measuring how the light spins.

There is also a lesson in the failure. The figure-eight reminds us that not every
knot cooperates: whether a knot can imprint clean OAM quantization is itself a
subtle knot-theoretic question — *which knots have all their Alexander roots on
the unit circle?* The trefoil and cinquefoil say yes; the golden figure-eight
says no. Somewhere between the crayon-and-paper world of knots and the humming
optics bench of a laser lab, the same numbers keep appearing. That recurrence —
sixth roots of unity, tenth roots of unity, the golden ratio — is the quiet
signal that the bridge between knots and light is not a metaphor. It is
mathematics.
