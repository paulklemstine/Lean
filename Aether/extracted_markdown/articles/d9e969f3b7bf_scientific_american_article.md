# The Secret Life of Light in a Universe Made of Whole Numbers

*What happens when you combine ancient Greek number theory with Einstein's spacetime? You discover arithmetic photons — and a hidden architecture connecting almost every branch of mathematics.*

---

You probably learned about Pythagorean triples in school: the numbers 3, 4, and 5 satisfy $3^2 + 4^2 = 5^2$. Ancient builders used this fact to construct right angles with a knotted rope. But this simple equation has a deeper identity that mathematicians are only now fully appreciating — one that connects the mathematics of whole numbers to the fabric of spacetime itself.

## A Hidden Equation of Light

In 1908, the mathematician Hermann Minkowski stood before a scientific audience and made a radical declaration: "Henceforth space by itself, and time by itself, are doomed to fade away into mere shadows, and only a kind of union of the two will preserve an independent reality."

Minkowski had discovered that Einstein's special relativity could be elegantly expressed using a single formula. In the merged spacetime he described, a flash of light spreading from a point traces out a *cone* — the **light cone** — defined by the equation:

$$x^2 + y^2 + z^2 = t^2$$

Here, $x$, $y$, and $z$ are spatial coordinates and $t$ is time (in units where the speed of light is 1). Any event satisfying this equation is connected to the origin by a beam of light.

Now look at that equation again. If you restrict $x$, $y$, $z$, and $t$ to be *whole numbers*, you get:

$$a^2 + b^2 + c^2 = d^2$$

These are **Pythagorean quadruples** — the three-dimensional version of Pythagorean triples. The smallest example: $1^2 + 2^2 + 2^2 = 3^2$.

Here's the punchline: *Pythagorean quadruples are integer light rays.* Each solution to this equation describes a photon traveling through a universe whose coordinates are limited to whole numbers — a *discrete spacetime*. We call them **arithmetic photons**.

## Assembling the Oracle Council

To explore this idea from every angle, we assembled a team of mathematical perspectives — an "Oracle Council" — each contributing a unique lens:

**Pythia**, the number theorist, asks: *How many arithmetic photons exist at each energy level?* The answer involves the function $r_3(d^2)$: how many ways can $d^2$ be written as a sum of three squares? The first few values tell the story: $r_3(1) = 6$ (just the six unit vectors), $r_3(9) = 30$ (including the triple $1^2 + 2^2 + 2^2$ and its permutations), and $r_3(49) = 54$. This function encodes deep information about the arithmetic of quadratic forms, a theory pioneered by Gauss in the early 1800s.

**Cassandra**, the geometer, asks: *What shape does the set of photon directions form?* If you divide each quadruple $(a, b, c, d)$ by its "time" component $d$, you get a point $(a/d, b/d, c/d)$ on a sphere — the **celestial sphere** of photon directions. Do these rational points fill the sphere evenly, or do they cluster? A remarkable theorem proved by William Duke in 1988 gives the answer: as the energy grows, photon directions spread uniformly over the sphere. Our computational experiments confirm this — at energy $d = 79$, the distribution deviates from perfect uniformity by less than half a percent.

**Sibyl**, the algebraist, asks: *Can you combine two arithmetic photons to get a third?* The answer involves **quaternions** — a four-dimensional number system discovered by William Rowan Hamilton in 1843. The Euler four-square identity, which says the product of two sums of four squares is again a sum of four squares, is really a statement about quaternion norms. This identity is the "composition law" for arithmetic photons: it tells you how to combine the quantum numbers of two photons to produce a third.

**Delphi**, the analyst, asks: *How rare are arithmetic photons?* The surprising answer: vanishingly rare. In a box of integer vectors up to size $N$, the fraction that are "photonic" decays like $1/N^2$. At box size $N = 8$, only 0.4% of integer 4-vectors lie on the null cone. The integer universe is almost entirely "dark matter" — timelike and spacelike vectors dominate overwhelmingly.

**Themis**, the physicist, asks: *Why does this particular dimension — 3 spatial + 1 temporal — seem special?* The answer lies in an extraordinary theorem by Adolf Hurwitz from 1898: the quaternions are the *last* associative normed division algebra. There are only four such algebras: the real numbers (1D), the complex numbers (2D), the quaternions (4D), and the octonions (8D) — and the octonions aren't associative. Since the quaternion algebra governs photon composition in $(3+1)$ dimensions, and there is no associative algebra available in dimensions 5, 6, or 7, the number $(3+1)$ is algebraically distinguished. Our universe's dimensionality may not be an accident — it may be a consequence of arithmetic.

## Four Open Questions — Answered

Our Oracle Council set out to resolve four specific questions about arithmetic photons. Here is what we found.

### Question 1: Is the Photon Graph Connected?

Imagine placing a chess piece on the origin of a three-dimensional integer grid. You're allowed to move it in any "photon direction" — that is, by any displacement $(a, b, c)$ whose norm $\sqrt{a^2 + b^2 + c^2}$ is a whole number. Can you reach every grid point?

**Answer: Yes, trivially.** Since $1^2 + 0^2 + 0^2 = 1^2$, the single-step moves $(1,0,0)$, $(0,1,0)$, and $(0,0,1)$ are all valid photon directions. You can reach any point by a sequence of unit steps.

But there's a twist. In the full *spacetime* lattice $\mathbb{Z}^4$, the photon graph is **not** connected. It splits into exactly two pieces, separated by a beautiful parity constraint: for any Pythagorean quadruple $(a, b, c, d)$, the sum $a + b + c + d$ is always even. This means you can never reach an "odd-sum" point from an "even-sum" point via photon steps. The proof is elegantly simple: since $x^2$ and $x$ always have the same parity, $a + b + c \equiv a^2 + b^2 + c^2 = d^2 \equiv d \pmod{2}$.

We verified this parity theorem using a computer proof assistant — a program that checks every logical step with mathematical certainty.

### Question 2: Do Photon Directions Equidistribute?

As you look at photons of higher and higher energy, do their directions on the celestial sphere fill out uniformly, or do they cluster in preferred directions?

**Answer: They equidistribute.** This is a consequence of a deep theorem proved by William Duke in 1988, building on decades of work by Linnik, Iwaniec, and others. Duke showed that integer points on spheres of growing radius become uniformly distributed — one of the jewels of analytic number theory.

We confirmed this computationally by measuring the "hemisphere discrepancy" — how far the fraction of photons in the upper half-sphere deviates from 50%. At energy $d = 79$, the discrepancy is just 0.4%. The arithmetic universe, like the physical one, has no preferred direction for light at high energies.

### Question 3: What Is the Quantum Version?

Can you do quantum mechanics with arithmetic photons? Can they be superposed, entangled, and error-corrected?

**Answer: Yes — and the structure is surprisingly rich.** At each energy level $d$, the set of photon states $\{|a,b,c\rangle : a^2 + b^2 + c^2 = d^2\}$ spans a Hilbert space $\mathcal{H}_d$ of dimension $r_3(d^2)$. For example, $\mathcal{H}_3$ has 30 dimensions and $\mathcal{H}_7$ has 54 dimensions.

The octahedral symmetry group — the 48 rotations and reflections that preserve a cube — acts on each $\mathcal{H}_d$, providing a natural set of "quantum gates." The orbits of this group partition the photon states into error-correcting blocks: if a single coordinate is corrupted, the error moves the state to a different orbit and can be detected.

Entanglement between photons at different energies is well-defined via tensor products. A maximally entangled pair of energy-3 photons carries about 4.9 bits of entanglement entropy — rivaling the best quantum information systems.

Whether this arithmetic quantum structure offers computational advantages over conventional quantum computing remains an open question — but the algebraic richness of the framework is tantalizing.

### Question 4: Can We Hear the Shape of Discrete Spacetime?

The photon spectrum — the sequence $r_3(1), r_3(4), r_3(9), \ldots$ — is like a fingerprint for the integer lattice. Different lattice geometries would produce different spectra. Can you uniquely identify the geometry from its spectrum?

**Answer: Generally, no.** In 1964, John Milnor showed that there exist non-isometric lattices with identical theta functions — the generating functions that encode the spectrum. His famous construction uses two distinct 16-dimensional lattices ($E_8 \oplus E_8$ and $D_{16}^+$) that are audibly identical but geometrically distinct.

This is the discrete analogue of Mark Kac's celebrated question, "Can one hear the shape of a drum?" — to which the answer is also "not always."

However, the spectrum is far from useless. In three dimensions, the photon spectrum determines the lattice in most cases. And the spectrum encodes profound arithmetic information: the "dark" energy levels where $r_3(n) = 0$ are precisely the numbers of the form $4^a(8b + 7)$, a result known to Legendre. Each nonzero value of $r_3$ is proportional to a *class number* — one of the most important invariants in algebraic number theory.

## A Universe of Almost Pure Darkness

One of the most vivid findings from our computational experiments is the **dark matter ratio** of integer spacetime. We classified every integer 4-vector in boxes of increasing size as null (photonic), timelike (massive), or spacelike (tachyonic):

| Box size $N$ | Null (photonic) | Timelike | Spacelike | Photon fraction |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 13 | 2 | 66 | 16.0% |
| 3 | 85 | 242 | 2,074 | 3.5% |
| 5 | 157 | 1,714 | 12,770 | 1.1% |
| 8 | 337 | 10,440 | 72,744 | 0.4% |

In a universe of integers, light is incredibly rare. The vast majority of integer vectors describe massive particles, not photons. Yet these rare null vectors carry the richest mathematical structure. They are the seams where number theory, geometry, algebra, and physics are stitched together.

## Proof by Machine

To ensure that these mathematical bridges are not merely suggestive analogies but rigorous facts, we verified key theorems using **Lean 4**, a computer proof assistant. The computer checks every logical step, eliminating the possibility of error. Among the formally verified results:

- The Pythagorean quadruple equation is exactly the null cone condition of Minkowski spacetime
- The standard parametrization always produces valid quadruples
- The Euler four-square identity holds (quaternion norm multiplicativity)
- The Hopf map lands on the unit sphere
- Every integer is the hypotenuse of some Pythagorean quadruple
- Two null vectors sum to a null vector if and only if they are "Minkowski-orthogonal"
- The parity invariant $a + b + c + d \equiv 0 \pmod{2}$ holds for all Pythagorean quadruples

Machine-verified mathematics is especially valuable when, as here, the results span multiple fields. Each bridge connects communities that use different conventions, notations, and standards of proof. The formal verification ensures that the translations are faithful.

## Why (3+1) Dimensions?

Perhaps the most tantalizing question raised by the arithmetic photon paradigm is *dimensional*: why does our physical universe have three dimensions of space and one of time?

The arithmetic answer is surprisingly clean. In 1+1 dimensions, the null cone equation $a^2 = d^2$ has only trivial solutions ($a = \pm d$). In 2+1 dimensions, $a^2 + b^2 = d^2$ gives Pythagorean triples, parameterized by two integers via Euclid's formula. In 3+1 dimensions, $a^2 + b^2 + c^2 = d^2$ gives Pythagorean quadruples, parameterized by four integers — the components of a quaternion.

And here the pattern stops. The quaternions are the last associative normed division algebra, by Hurwitz's theorem of 1898. The next algebra — the octonions — is non-associative, breaking the composition law that makes the theory work. In a precise algebraic sense, $(3+1)$-dimensional spacetime is the highest dimension where arithmetic photons compose associatively.

This doesn't prove that physics *had* to choose $3+1$ dimensions. But it suggests that the integer arithmetic of spacetime has a natural home in exactly the dimensionality we observe — and that this is not a coincidence but a reflection of deep algebraic constraints.

## The Road Ahead

What began with Pythagoras's rope and Minkowski's spacetime has opened a window onto a mathematical landscape where light, numbers, and the structure of space are one and the same. The answers to our four questions — yes, the photon graph is connected; yes, directions equidistribute; yes, quantum photon theory is rich and well-defined; no, you cannot always hear the shape of discrete spacetime — each reveal new facets of this landscape.

The arithmetic universe is vast and mostly dark — but its photons illuminate connections that span millennia of mathematical thought. And with computer-verified proofs standing guard over the foundations, we can explore this terrain with a confidence that Pythagoras himself might have envied.

---

*The formal verification and computational experiments described in this article are available as open-source Lean 4 and Python code.*

---

**Box: The Oracle Council**

| Oracle | Domain | Key Contribution |
|--------|--------|-----------------|
| Pythia | Number Theory | Counting photons via $r_3(d^2)$ and modular forms |
| Cassandra | Geometry | Equidistribution on the celestial sphere |
| Sibyl | Algebra | Quaternion composition and Hurwitz's theorem |
| Delphi | Analysis | Dark matter ratio and asymptotic rarity |
| Themis | Physics | Dimensional selection and Lorentz symmetry |

**Box: Key Numbers**

| Quantity | Value |
|----------|-------|
| Smallest nontrivial quadruple | $(1, 2, 2, 3)$ |
| Photon directions at $d = 3$ | 30 |
| Photon fraction at $N = 8$ | 0.4% |
| Parity components in $\mathbb{Z}^4$ | 2 |
| Hemisphere discrepancy at $d = 79$ | 0.004 |
| Entanglement entropy of Bell photon pair | 4.9 bits |
| Division algebras (Hurwitz) | 4 ($\mathbb{R}, \mathbb{C}, \mathbb{H}, \mathbb{O}$) |
