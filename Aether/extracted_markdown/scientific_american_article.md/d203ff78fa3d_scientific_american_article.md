# The Secret Life of Light in a Universe Made of Whole Numbers

*What happens when you combine ancient Greek number theory with Einstein's spacetime? You discover arithmetic photons — and a hidden architecture connecting almost every branch of mathematics.*

---

You probably learned about Pythagorean triples in school: the number 3, 4, and 5 satisfy $3^2 + 4^2 = 5^2$. Ancient builders used this fact to construct right angles with a knotted rope. But this simple equation has a deeper identity that mathematicians are only now fully appreciating — one that connects the mathematics of whole numbers to the fabric of spacetime itself.

## A Hidden Equation of Light

In 1908, the mathematician Hermann Minkowski stood before a scientific audience and made a radical declaration: "Henceforth space by itself, and time by itself, are doomed to fade away into mere shadows, and only a kind of union of the two will preserve an independent reality."

Minkowski had discovered that Einstein's special relativity could be elegantly expressed using a single formula. In the merged spacetime he described, a flash of light spreading from a point traces out a *cone* — the **light cone** — defined by the equation:

$$x^2 + y^2 + z^2 = t^2$$

Here, $x$, $y$, and $z$ are spatial coordinates and $t$ is time (in units where the speed of light is 1). Any event satisfying this equation is connected to the origin by a beam of light.

Now look at that equation again. If you restrict $x$, $y$, $z$, and $t$ to be *whole numbers*, you get:

$$a^2 + b^2 + c^2 = d^2$$

These are **Pythagorean quadruples** — the three-dimensional version of Pythagorean triples. The smallest example: $1^2 + 2^2 + 2^2 = 3^2$.

Here's the punchline: *Pythagorean quadruples are integer light rays.* Each solution to this equation describes a photon traveling through a universe whose coordinates are limited to whole numbers — a *discrete spacetime*. We call them **arithmetic photons**.

## The Oracle Council

To explore this idea, we assembled a team of mathematical "oracles" — research perspectives drawn from different fields — each contributing a unique insight:

**Pythia**, the number theorist, asks: *How many arithmetic photons exist at each energy level?* The answer involves representation numbers $r_3(d^2)$ — how many ways can $d^2$ be written as a sum of three squares? This question plunges us into the deep waters of quadratic forms, a theory pioneered by Gauss in the early 1800s.

**Cassandra**, the geometer, asks: *What shape does the set of photon directions form?* If you divide each quadruple $(a, b, c, d)$ by its "time" component $d$, you get a point $(a/d, b/d, c/d)$ on a sphere — the **celestial sphere** of photon directions. These rational points on the sphere connect to some of the most important structures in modern mathematics.

**Sibyl**, the algebraist, asks: *Can you combine two arithmetic photons to get a third?* The answer involves **quaternions** — a number system discovered by William Rowan Hamilton in 1843, where multiplication works in four dimensions. The Euler four-square identity, which says the product of two sums of four squares is again a sum of four squares, is really a statement about quaternion norms.

**Delphi**, the analyst, asks: *How rare are arithmetic photons?* The surprising answer: vanishingly rare. In a box of integer vectors up to size $N$, the fraction that are "photonic" (null) decays like $1/N^2$. The integer universe is almost entirely "dark matter."

**Themis**, the physicist, asks: *Why does this particular dimension — 3 spatial + 1 temporal — seem special?* The answer may lie in an extraordinary theorem by Adolf Hurwitz: quaternions are the *last* associative division algebra, and quaternions are intrinsically four-dimensional. The rich structure of arithmetic photons depends critically on this algebraic fact.

## Five Bridges Between Worlds

The most striking discovery of the arithmetic photon program is the web of connections — *bridges* — it reveals between seemingly unrelated areas of mathematics:

### Bridge 1: Gauss Meets Einstein

The number of arithmetic photons at energy $d$ — that is, the number of integer points $(a, b, c)$ with $a^2 + b^2 + c^2 = d^2$ — is controlled by the same mathematics that Gauss developed to study the shapes of quadratic forms. The symmetries of this counting problem are exactly the symmetries of the Lorentz group from special relativity, restricted to integer matrices. Number theory and physics share the same symmetry group.

### Bridge 2: The Hopf Map

The parametrization of Pythagorean quadruples turns out to be one of the most important maps in topology: the **Hopf fibration**, discovered by Heinz Hopf in 1931. This map from the 3-sphere to the 2-sphere reveals that the topology of spheres is far more complex than it appears — in particular, $\pi_3(S^2) = \mathbb{Z}$, meaning there are infinitely many essentially different ways to wrap a 3-sphere around a 2-sphere. This same map also appears in quantum mechanics (Berry phase), condensed matter physics (magnetic monopoles), and fluid dynamics (vortex knots).

### Bridge 3: Modular Forms

The generating function that counts arithmetic photons — $\sum r_3(n) q^n = \theta_3(q)^3$ — is a **modular form**, an object of central importance in modern number theory. Modular forms are connected to elliptic curves, the Langlands program, and Andrew Wiles's proof of Fermat's Last Theorem. The simple question "how many ways can I write $n$ as a sum of three squares?" opens a door to some of the deepest mathematics of the past century.

### Bridge 4: Rational Points on the Sphere

Finding all Pythagorean quadruples is equivalent to finding all rational points on the unit sphere $S^2$. This is a special case of one of the great questions of algebraic geometry: which algebraic varieties have rational points, and how are they distributed? The inverse stereographic projection — a map from the rational plane to the rational sphere — provides a complete answer for $S^2$, but similar questions for more complex varieties remain wide open.

### Bridge 5: Discrete Spacetime

If spacetime is fundamentally discrete at the Planck scale — as suggested by some approaches to quantum gravity — then light propagation becomes a number theory problem. The causal structure of discrete spacetime is determined by Pythagorean quadruples: two events in an integer lattice are causally connected by a light signal if and only if their displacement is a Pythagorean quadruple.

## A Universe of Almost Pure Darkness

One of the most vivid findings from our computational experiments is the **dark matter ratio** of integer spacetime. Imagine labeling every integer vector in a large box as either "photonic" (null), "massive" (timelike), or "tachyonic" (spacelike). As the box grows, the fraction of photonic vectors shrinks toward zero — like $1/N^2$ in our $(3+1)$-dimensional spacetime.

In a universe of integers, light is incredibly rare. The vast majority of integer vectors describe massive particles, not photons. Yet these rare null vectors — the arithmetic photons — carry the richest mathematical structure. They are the seams where number theory, geometry, algebra, and physics are stitched together.

## Proof by Machine

To ensure that these mathematical bridges are not merely suggestive analogies but rigorous facts, we have verified the key theorems using **Lean 4**, a computer proof assistant. The computer checks every logical step, eliminating the possibility of error.

Among the formally verified results:
- The Pythagorean quadruple equation is exactly the null cone condition of Minkowski spacetime
- The standard parametrization always produces valid quadruples
- The Euler four-square identity holds (quaternion norm multiplicativity)
- The Hopf map lands on the unit sphere
- Every integer is the hypotenuse of some Pythagorean quadruple
- Two null vectors sum to a null vector if and only if they are "Minkowski-orthogonal"

Machine-verified mathematics is especially valuable when, as here, the results span multiple fields. Each bridge connects communities that use different conventions, notations, and standards of proof. The formal verification ensures that the translations are faithful.

## Why (3+1) Dimensions?

Perhaps the most tantalizing question raised by the arithmetic photon paradigm is *dimensional*: why does our physical universe have three dimensions of space and one of time?

The arithmetic answer is surprisingly clean. In 1+1 dimensions, the null cone equation $a^2 = d^2$ has only trivial solutions ($a = \pm d$). In 2+1 dimensions, $a^2 + b^2 = d^2$ gives Pythagorean triples, parametrized by two integers. In 3+1 dimensions, $a^2 + b^2 + c^2 = d^2$ gives Pythagorean quadruples, parametrized by four integers — quaternions.

And here the pattern stops. The quaternions are the last *associative* normed division algebra, by Hurwitz's theorem. The next algebra — the octonions — is non-associative, breaking the composition law that makes the theory work. In a precise algebraic sense, $(3+1)$-dimensional spacetime is the highest dimension where arithmetic photons compose nicely.

This doesn't prove that physics *had* to choose $3+1$ dimensions. But it suggests that the integer arithmetic of spacetime has a natural home in exactly the dimensionality we observe — and that this is not a coincidence but a reflection of deep algebraic constraints.

## The Road Ahead

The arithmetic photon paradigm is still young, and many questions remain open:

- **Is the photon graph connected?** If you stand at any point in the integer lattice and are allowed to take steps along arithmetic photon directions, can you reach every other point?

- **Do photon directions equidistribute?** As the energy $d$ grows, do the directions of primitive arithmetic photons spread evenly over the celestial sphere?

- **What is the "quantum" version?** Can arithmetic photon states be superposed, entangled, or error-corrected, and does this connect to the theory of quantum computing?

- **Can we hear the shape of discrete spacetime?** The spectrum of photon energies — the sequence $r_3(1), r_3(4), r_3(9), r_3(16), \ldots$ — is an arithmetic invariant of the lattice. Can it distinguish different discrete spacetime geometries?

What began with Pythagoras's rope and Minkowski's spacetime has opened a window onto a mathematical landscape where light, numbers, and the structure of space are one and the same. The arithmetic universe is vast, mostly dark — but its photons illuminate connections that span millennia of mathematical thought.

---

*The formal verification and computational experiments described in this article are available as open-source Lean 4 and Python code.*
