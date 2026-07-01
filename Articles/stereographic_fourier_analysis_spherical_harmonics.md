# Flattening the Sphere Without Losing Its Shape

Imagine you are a cartographer with an impossible assignment: draw a perfectly
flat map of the entire globe. You already suspect the catch. Every flat map of
the Earth lies a little. Greenland balloons to the size of Africa; Antarctica
smears across the bottom of the page like a white continent-sized rumor. There
is a deep reason for this — a sphere and a plane simply have different intrinsic
geometry, and no map can reconcile them perfectly.

But "perfectly" hides a subtlety. There is one classical map, known for
centuries, that gives up on preserving *areas* and *distances* but clings
fiercely to something else: **angles**. It is called **stereographic
projection**, and it is one of the most beautiful bridges in all of mathematics.
This article is about a precise, exact accounting of exactly how much that bridge
distorts distance — a single clean formula — and about the ambitious program of
analysis that this exact accounting unlocks: doing Fourier analysis on a curved
sphere by secretly doing ordinary Fourier analysis on flat space.

## The map that keeps its angles

Picture a sphere sitting on a flat plane, touching it at the south pole. Now
stand at the north pole and shine a light through the sphere. Every point on the
sphere casts a shadow somewhere on the plane, and every point on the plane
receives exactly one shadow. That correspondence — point on sphere, shadow on
plane — is stereographic projection.

It has a magical property: it is **conformal**. Wherever two curves cross on the
sphere at some angle, their shadows on the plane cross at exactly the same angle.
Circles map to circles (or straight lines). Tiny shapes keep their shape, even as
they change size. The map lies about scale but tells the truth about form.

Running the movie backwards gives the **inverse stereographic projection**: a
recipe that takes any point $x$ in flat space and lifts it up onto the sphere.
Written in coordinates, if $x$ is a point in $n$-dimensional flat space with
length $\|x\|$, its lift onto the unit sphere living in one dimension higher is

$$
\Phi(x) = \left( \frac{2x}{1+\|x\|^2},\ \frac{\|x\|^2-1}{1+\|x\|^2} \right).
$$

The first block of coordinates is the "horizontal" position; the last coordinate
is the "height" on the sphere, running from $-1$ at the south pole (when $x=0$)
up toward $+1$ as $x$ races off to infinity (approaching the north pole, the one
point with no shadow). You can check that this point really does sit on the unit
sphere: the squares of all its coordinates add up to exactly $1$.

## Exactly how much does it stretch?

Here is the central question. Take two points $x$ and $y$ in the flat plane. Lift
both up to the sphere. The straight-line distance between their lifts — the length
of the chord cutting through the ball from one point to the other — is called the
**chordal distance**. How does it compare to the flat distance $\|x-y\|$ we
started with?

The answer is astonishingly clean. This is the result at the heart of our work.

> **The Chordal Metric Identity.** For any two points $x$ and $y$ in flat space,
> the squared chordal distance between their lifts onto the sphere is
> $$
> \|\Phi(x)-\Phi(y)\|^2 = \frac{4\,\|x-y\|^2}{\left(1+\|x\|^2\right)\left(1+\|y\|^2\right)}.
> $$

Look at what this says. The numerator is just four times the original flat
squared distance. The denominator is a product of two weights, one attached to
each point: $1+\|x\|^2$ and $1+\|y\|^2$. Points near the origin get weights close
to $1$ and are barely distorted; points far out near infinity carry enormous
weights and get dramatically compressed — which is exactly why the infinite flat
plane can be squeezed onto a finite sphere in the first place.

The formula is not an approximation. It is not a first-order expansion valid only
for nearby points. It is a global, exact identity, true for *every* pair of points
no matter how far apart. That exactness is the whole point, and it is what makes
everything that follows possible.

## From two points to the fabric of space

Watch what happens when the two points drift together. Set $y$ very close to $x$.
Then both weights become nearly equal to $1+\|x\|^2$, and the identity collapses
to the infinitesimal statement

$$
ds^2_{\text{sphere}} = \frac{4}{\left(1+\|x\|^2\right)^2}\, ds^2_{\text{flat}}.
$$

In words: at the point $x$, distances on the sphere are those of flat space
scaled by the single factor $4/(1+\|x\|^2)^2$. This one number — the **conformal
factor** — is the complete summary of how the geometry is bent. It multiplies all
directions equally, which is precisely why angles survive: stretching everything
by the same amount at a point cannot change the angle between two directions.

There is a second, deeper way to see that this factor is exactly right. Write the
conformal factor as $e^{2u}$ for a function $u$. The statement that the resulting
geometry is a genuine round sphere of constant curvature $+1$ — not some lumpy
approximation — is equivalent to $u$ satisfying a famous nonlinear equation, the
**Liouville equation** from the theory of constant-curvature surfaces. The
conformal factor $4/(1+\|x\|^2)^2$ solves it on the nose. The sphere's roundness
is encoded, exactly, in that single scalar.

## Why an exact formula changes the game

So we have a clean, exact dictionary between the flat plane and the round sphere,
and we know the precise "exchange rate" at every point. Why is that worth getting
excited about?

Because of Fourier analysis — the mathematics of decomposing a signal into pure
frequencies. On flat space, Fourier analysis is the crown jewel of applied
mathematics: it powers signal processing, image compression, the numerical
solution of differential equations, and quantum mechanics. Its engine is the fact
that plane waves $e^{2\pi i\, x\cdot k}$ are the natural vibrational modes of flat
space; the Fourier transform simply expresses any signal as a blend of them.

On a sphere, the analogous vibrational modes are the **spherical harmonics** — the
patterns you see in the vibrations of a soap bubble, the shapes of atomic
orbitals, the temperature fluctuations mapped across the cosmic microwave
background. They are indispensable but computationally awkward, tied to the
curved geometry.

Here is the dream, made plausible by the exact conformal dictionary. Define a
**stereographic Fourier transform** that takes a function $f$ living on the
sphere, pulls it down to the flat plane through the projection, corrects for the
distortion with exactly the right power of the conformal factor, and then hits it
with an ordinary flat-space plane wave:

$$
F[f](k) = \int_{\text{sphere}} f(x)\,\bigl(1+\|\Phi^{-1}(x)\|^2\bigr)^{-n/2}\, e^{-2\pi i\, \Phi^{-1}(x)\cdot k}\, d\sigma(x).
$$

The mysterious weight $\bigl(1+\|\cdot\|^2\bigr)^{-n/2}$ is not pulled from a hat.
It is precisely the *square root* of the change-of-variables Jacobian that the
chordal identity hands us. It is engineered to cancel the metric distortion
pointwise — to undo the stretching before the flat Fourier kernel ever gets to
work. And because the cancellation is exact rather than approximate, one expects
the transform to conserve total energy perfectly: an **isometry** from
square-integrable functions on the sphere to square-integrable functions on the
plane, complete with a Plancherel identity.

## The rewards of the dictionary

If this program goes through — and the exact conformal accounting is what makes it
tractable — three concrete payoffs follow.

**Spherical harmonics become Hermite functions.** The simplest nonconstant
vibrational modes of the sphere, the degree-one harmonics, are just the ambient
coordinate functions restricted to the sphere. Pulled down to the plane, each
becomes a simple rational function: a linear numerator over a power of
$1+\|x\|^2$. Convolving such a function against a plane wave is exactly the
integral that manufactures the classical **Hermite functions** — the rational
times Gaussian profiles that describe the quantum harmonic oscillator. Curved
analysis turns into the best-understood objects in flat analysis.

**Eigenvalues transfer with a universal shift.** A spherical harmonic of degree
$\ell$ is an eigenfunction of the sphere's natural Laplace operator with
eigenvalue $-\ell(\ell+n-1)$. Under the transform, it becomes a function on which
the flat Laplacian acts with leading eigenvalue $-\ell(\ell+n-1) + n^2/4$. That
extra $n^2/4$ is a universal correction, the fingerprint of the conformal
factor's curvature — the same $n^2/4$ that appears throughout conformal geometry
and the study of the so-called conformal Laplacian.

**Quantum mechanics on curved space becomes computable.** Physical problems set on
spheres — a particle confined to a spherical shell, fields on a curved cosmos —
can be transported to flat space, solved with the mature and fast machinery of
ordinary Fourier analysis, and transported back, with the exact conformal factor
keeping the books honest at every step.

## The moral

Stereographic projection has been drawn on maps and globes for two thousand
years, admired for keeping its angles. What the chordal metric identity supplies
is the missing exact ledger of how it treats distance: a single clean formula,
$4\|x-y\|^2 / \bigl((1+\|x\|^2)(1+\|y\|^2)\bigr)$, from which the entire conformal
geometry of the sphere flows. The infinitesimal factor $4/(1+\|x\|^2)^2$ is the
whole story of the curvature; it even solves the Liouville equation that certifies
constant curvature $+1$.

The lesson is an old one in mathematics but never stops being surprising: an exact
formula is worth far more than its literal statement. Because we know *precisely*
how the sphere and the plane trade distances, we can hope to move all of harmonic
analysis back and forth across the bridge — turning the hard problem of vibrations
on a curved world into the well-worn problem of vibrations on a flat one. The map
that keeps its angles turns out to keep, in exactly measurable form, far more than
we ever asked of it.
