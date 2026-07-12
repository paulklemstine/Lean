# When Light Ties Itself in Knots — and Cyclotomic Numbers Answer

## A beam that carries angular momentum

Shine an ordinary laser at a wall and you get a bright dot. But light can be
sculpted. With the right optics you can twist a beam so that its wavefront
spirals like a corkscrew, and the darkness at the very center of that spiral —
a *phase singularity*, a thread of pure shadow running along the beam — is not
just an absence of light. It is a structure. Along that dark thread the phase of
the wave is undefined, and the beam as a whole carries **orbital angular
momentum (OAM)**: it can spin tiny particles, encode information in a new
alphabet, and store more data in a single photon than the old on/off bit ever
could.

Now push the idea further. What if the dark thread does not run straight down
the middle of the beam, but loops back on itself, weaves over and under, and
closes into a **knot**? This is *knotted light*, and it is not science fiction:
laboratories have created optical fields whose zero-intensity filaments trace
trefoils and other knots in mid-air. The question this article is about is
deceptively simple to state and surprisingly deep to answer:

> *If the dark heart of a light beam is tied into a particular knot, what
> discrete values of angular momentum can the beam carry?*

The astonishing answer is that the allowed values are governed by a single
polynomial attached to the knot — its **Alexander polynomial** — and that for the
most natural family of knots these polynomials turn out to be the **cyclotomic
polynomials**, the objects number theorists use to describe the *roots of
unity*: the perfectly symmetric points spaced evenly around a circle. The
quantized angular-momentum channels of a knotted beam are, quite literally, the
corners of a regular polygon inscribed in the unit circle.

## The knots that come first: the $T(2,n)$ family

The simplest nontrivial knots form a tidy family called **torus knots**. A
torus knot $T(2,n)$ is what you get by taking two strands and twisting them
around each other $n$ times before joining the ends into a closed loop (here $n$
is odd, so the ends actually match up). The first two members are famous:

- $T(2,3)$ is the **trefoil**, the classic three-lobed pretzel knot;
- $T(2,5)$ is the **cinquefoil** (or Solomon's seal knot), with five lobes.

Every knot has an *Alexander polynomial*, a fingerprint that does not change no
matter how you wiggle or stretch the knot without cutting it. For the $T(2,n)$
family this fingerprint has a beautifully simple form — the **alternating
geometric sum**

$$A_n(X) = 1 - X + X^2 - X^3 + \cdots + X^{n-1}.$$

For the trefoil this is $A_3(X) = X^2 - X + 1$, and for the cinquefoil it is
$A_5(X) = X^4 - X^3 + X^2 - X + 1$. The predicted OAM channels of the knotted
beam are the **roots** of this polynomial — the values of $X$ that make it
vanish.

## The one identity that unlocks everything

There is a single algebraic fact from which the entire story flows. Multiply the
alternating sum by $(X+1)$ and watch the middle collapse in a telescoping
cascade:

$$(X+1)\,A_n(X) = X^n + 1.$$

Every term cancels against its neighbor except the two ends. This tiny identity
is the master key. It says the roots of $A_n$ are hidden among the solutions of
$X^n + 1 = 0$ — the $n$ points where a number raised to the $n$-th power equals
$-1$ — with the single point $X = -1$ (the root of $X+1$) removed.

The solutions of $X^n = -1$ are equally spaced around the unit circle in the
complex plane; they are, precisely, certain **roots of unity**. So the OAM
spectrum of a $T(2,n)$ knotted beam is forced to live on the unit circle, at
angles that are exact rational fractions of a full turn. Angular momentum, tied
to a knot, comes out **quantized by pure symmetry**.

## Cyclotomic polynomials: naming the symmetry

Mathematicians have a name for the polynomial whose roots are exactly the
*primitive* $m$-th roots of unity — the rotations by $k/m$ of a full turn where
$k$ shares no common factor with $m$. It is the **$m$-th cyclotomic polynomial**,
written $\Phi_m$. These are the atoms of symmetry on the circle: $X^m - 1$
factors perfectly into a product of $\Phi_d$ over all divisors $d$ of $m$, with
no leftovers and no repeats.

The central discovery of this work is that the knot polynomials *are* these
atoms. For every odd prime $p$,

$$A_p(X) = \Phi_{2p}(X).$$

This is not a coincidence of shared roots or a numerical approximation — it is a
**literal equality of polynomials**. The trefoil's fingerprint is the sixth
cyclotomic polynomial,

$$X^2 - X + 1 = \Phi_6(X),$$

and the cinquefoil's is the tenth,

$$X^4 - X^3 + X^2 - X + 1 = \Phi_{10}(X).$$

Once you know this, a whole cascade of sharp consequences follows for free,
because cyclotomic polynomials are among the most thoroughly understood objects
in all of mathematics.

## No spurious channels

The first payoff is a **converse**. It is one thing to check that each primitive
$2p$-th root of unity is a root of $A_p$; it is a stronger and more useful thing
to know that there are *no other roots at all*. Because $A_p$ is exactly
$\Phi_{2p}$, its complex roots are **precisely** the primitive $2p$-th roots of
unity — nothing more, nothing less. The knotted beam has exactly the channels the
symmetry predicts, with no stray, spurious quantization levels sneaking in. For
the trefoil these are the six-fold-symmetric points (the primitive sixth roots),
and for the cinquefoil the ten-fold-symmetric ones.

## Counting the channels

How many distinct OAM channels does a $T(2,p)$ beam support? Exactly the degree
of its Alexander polynomial, which is the number of primitive $2p$-th roots of
unity. Euler's totient function $\varphi$ counts these, and a short computation
gives

$$\deg A_p = \varphi(2p) = \varphi(p) = p - 1.$$

So a trefoil beam has $3 - 1 = 2$ channels, a cinquefoil beam has $5 - 1 = 4$,
and in general the count is one less than the twist number. Clean, discrete,
predictable.

## One indivisible orbit

The next payoff concerns *structure*. The cyclotomic polynomial $\Phi_{2p}$ is
**irreducible over the rational numbers** — it cannot be factored into smaller
polynomials with rational coefficients. Translated back to physics, this says the
OAM spectrum forms a **single Galois-conjugate orbit**: the quantized levels are
so tightly bound together by symmetry that no proper subset of them is
algebraically self-contained. You cannot peel off some of the channels and
describe them without invoking all the others. The spectrum is one indivisible
whole.

## An old invariant, recovered from above

Every knot has a classical integer invariant called its **determinant**, the
absolute value of its Alexander polynomial evaluated at $-1$. For the torus knots
the alternating sum makes this evaluation trivial: substituting $X = -1$ turns
every term into $+1$, so

$$A_n(-1) = 1 + 1 + \cdots + 1 = n.$$

The determinant of $T(2,n)$ is therefore simply $n$. This recovers the textbook
values — the trefoil's determinant is $3$, the cinquefoil's is $5$ — uniformly
from a single family formula, rather than case by case.

The determinant is not idle bookkeeping. A knot is **$3$-colorable** — meaning you
can paint the arcs of its diagram with three colors, obeying a simple rule at
each crossing, in a genuinely nontrivial way — exactly when $3$ divides its
determinant. Among all the $T(2,p)$ knots this happens for one and only one
member:

$$3 \mid A_p(-1) \iff 3 \mid p \iff p = 3.$$

The trefoil is the unique $3$-colorable torus knot in the family, and the
cyclotomic picture explains precisely why.

## The knot that breaks the spell: the figure-eight

Is *every* knot's spectrum this crystalline? No — and the smallest exception is
instructive. The **figure-eight knot** is the simplest knot that is not a torus
knot, and its Alexander polynomial is

$$X^2 - 3X + 1.$$

This looks superficially like the trefoil's $X^2 - X + 1$, but the coefficient
$3$ changes everything. Its roots are not on the unit circle; they are the real
numbers $\varphi^{2}$ and $\varphi^{-2}$, where $\varphi = \tfrac{1+\sqrt5}{2}$ is
the **golden ratio**. The discriminant $3^2 - 4 = 5$ is positive, so the roots are
real and stray off the circle entirely.

The dividing line is sharp. For a quadratic $X^2 - bX + 1$, the roots sit on the
unit circle exactly when $b^2 < 4$; the figure-eight's $b = 3$ fails this test,
while the trefoil's $b = 1$ passes. A deep theorem of Kronecker makes this
precise in general: an integer polynomial with all its roots on the unit circle
must be a product of cyclotomic polynomials. The torus knots are crystalline —
their spectra are pure roots of unity — while the figure-eight is *metallic*, its
spectrum built from the golden ratio. If genuine root-of-unity OAM quantization
is what you want, the figure-eight is the smallest knot that refuses to provide
it.

## Why this is beautiful

The chain of reasoning runs from optics to topology to number theory and back,
and each link snaps satisfyingly into place. A twist of light creates a dark
thread; the thread is tied into a knot; the knot has a polynomial fingerprint;
the fingerprint is a cyclotomic polynomial; and cyclotomic polynomials encode the
most perfect discrete symmetry on the circle. The upshot is that the angular
momentum a knotted beam can carry is quantized not by an arbitrary rule imposed
from outside, but by the intrinsic arithmetic of the knot itself — the corners of
a regular polygon, written in light.

That a laboratory beam and a $19$th-century number theorist's polynomials should
speak the same language is the kind of unity that makes mathematics worth doing.
The knot ties the light; the cyclotomic numbers count what the knot allows.
