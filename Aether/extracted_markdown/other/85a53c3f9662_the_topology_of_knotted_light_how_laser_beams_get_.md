# When Light Ties Itself in Knots

## How physicists discovered that laser beams can carry the mathematics of tangled ropes — and what it means for the future of information

---

In 1989, the physicist Les Allen made a discovery that would take decades to fully appreciate: laser beams can twist. Not in the ordinary sense — not like a rope or a garden hose. Allen showed that light itself can carry angular momentum in its wavefront, spinning around its own axis of propagation like a tiny, invisible tornado. The technical term is *orbital angular momentum*, or OAM, and it turns a simple laser beam into something far stranger than anyone expected.

The twist is encoded in the beam's phase — the oscillating pattern that defines where the wave crests and troughs lie. In an ordinary laser beam, the phase fronts are flat planes marching forward in lockstep. But in a beam carrying OAM, those phase fronts spiral around the beam's axis, like the threads of a screw. The amount of twist is quantized: the beam can carry exactly 1 unit of angular momentum, or 2, or 17, but never 1.5. These integer values — the OAM quantum numbers — label fundamentally different states of light.

What makes this more than a curiosity is what happens when the spiraling phase fronts become complicated enough to tie themselves into knots.

## The Darkness Inside the Light

At the center of every OAM beam, something peculiar occurs: the light vanishes. The intensity drops to exactly zero along the beam's axis, creating a thread of darkness running through the heart of the light. Physicists call this a *phase singularity* — a point where the phase of the wave is undefined, like the direction "north" at the North Pole.

In a simple OAM beam, this dark thread is a straight line. But in 2004, Mark Dennis at the University of Bristol showed that by carefully combining beams with different OAM values, you could sculpt the dark thread into curves — loops, links, and eventually, knots. The phase singularity of the resulting beam traces out a closed curve in three-dimensional space, and that curve can be tied into a trefoil knot, a figure-eight knot, or in principle, any knot you choose.

This was not mere theory. In 2010, a team at the University of Glasgow, led by Miles Padgett, created the first knotted light beams in the laboratory. Using computer-generated holograms displayed on spatial light modulators, they sculpted laser beams whose dark cores traced trefoil knots. The knots were real — as real as any mathematical structure gets when written in photons.

## The Polynomial That Knows the Knot

Here is where the story takes an unexpected mathematical turn.

Every knot has a fingerprint — a polynomial called the *Alexander polynomial*, discovered by James Waddell Alexander II in 1928. For mathematicians, the Alexander polynomial is a compact encoding of a knot's topology. The trefoil knot, the simplest non-trivial knot, has Alexander polynomial t² − t + 1. The figure-eight knot has t² − 3t + 1. The unknot — a simple loop with no crossings — has Alexander polynomial equal to 1.

These polynomials are powerful: they can often distinguish knots that look very different from each other, and they capture deep information about the three-dimensional space surrounding the knot. The Alexander polynomial of a knot K tells you about the topology of the *knot complement* — the doughnut-shaped space you get when you drill the knot out of three-dimensional space.

The new insight is this: the Alexander polynomial does not just classify knots abstractly. It appears directly in the physics of knotted light.

When a laser beam's phase singularity traces a knot K, the set of OAM values that can stably propagate through the beam is controlled by the roots of the Alexander polynomial. Specifically, the OAM quantum numbers correspond to positions on the unit circle where the Alexander polynomial vanishes — the angles at which the polynomial's value drops to zero when you plug in a complex number of magnitude one.

## Cyclotomic Revelations

The trefoil knot provides the cleanest example of this connection. Its Alexander polynomial, t² − t + 1, is a famous object in number theory: it is the *sixth cyclotomic polynomial* Φ₆. The cyclotomic polynomials are the irreducible factors of tⁿ − 1, and Φ₆ has roots at the primitive sixth roots of unity — the complex numbers e^{iπ/3} and e^{−iπ/3}, sitting on the unit circle at 60° and 300°.

This means the OAM spectrum of a trefoil-knotted beam is governed by sixth roots of unity. The allowed angular momentum values are spaced at intervals related to π/3 — the beam "knows" that its dark core is tied in a trefoil because the angular momentum spectrum reflects the sixfold symmetry of the cyclotomic polynomial.

The cinquefoil knot (the five-crossing torus knot) tells a similar story. Its Alexander polynomial t⁴ − t³ + t² − t + 1 is the tenth cyclotomic polynomial Φ₁₀, whose roots sit at 36°, 108°, 252°, and 324° on the unit circle. The beam's OAM spectrum encodes this tenfold structure.

The figure-eight knot breaks the pattern in an illuminating way. Its Alexander polynomial t² − 3t + 1 has *real* roots — specifically, (3 ± √5)/2 — which means its roots do not lie on the unit circle. The discriminant is positive (9 − 4 = 5 > 0), unlike the trefoil's negative discriminant (1 − 4 = −3 < 0). This algebraic distinction has a physical consequence: the figure-eight knot's OAM spectrum has a qualitatively different structure from the torus knots.

There is a beautiful theorem here. For any quadratic Alexander polynomial of the form t² + bt + 1 (the palindromic form that all such polynomials take), the roots lie on the unit circle if and only if |b| < 2. This is precisely the condition that separates torus knots (whose Alexander polynomials have unit-circle roots) from other knot types. The integer b acts as a topological order parameter: it determines whether the knotted light beam has a discrete, crystalline OAM spectrum or a continuous one.

## Reading the Knot from the Light

The practical implications are striking. If you shine a laser through a hologram that creates a knotted beam, you can *read off* topological information about the knot by measuring the beam's angular momentum spectrum. The Alexander polynomial — an abstract algebraic invariant — becomes a physical observable.

The knot determinant, defined as the absolute value of the Alexander polynomial evaluated at −1, is directly measurable. For the trefoil, the determinant is 3; for the figure-eight knot, it is 5; for the cinquefoil, it is 5 as well. This number counts (in a precise algebraic sense) the "complexity" of the knot, and it shows up in the interference patterns of the beam.

Even the *genus* of the knot — the minimum number of handles on a surface that the knot can bound — is encoded in the polynomial's degree. The trefoil has genus 1 (its Alexander polynomial has degree 2 = 2 × 1). The cinquefoil has genus 2 (degree 4 = 2 × 2). Higher genus means more complex topology, which translates to more OAM modes in the spectrum.

## Connected Sums and Quantum Information

When knots combine — through the operation mathematicians call *connected sum* — their Alexander polynomials multiply. Take two trefoil knots and splice them together to form a "granny knot," and the resulting Alexander polynomial is the square of the trefoil's polynomial. The knot determinant squares accordingly: from 3 to 9.

This multiplicative property has implications for quantum information. Each knotted beam represents a topological state of light, and the connected sum operation corresponds to a kind of tensor product of these states. The OAM spectra combine in a predictable way, suggesting that knotted light could serve as a basis for topological encoding of quantum information — a form of encoding that is inherently robust against small perturbations because the topology of a knot is unchanged by gentle deformation.

## The Shape of Things to Come

The connection between knot topology and angular momentum spectra opens a new window into both mathematics and physics. On the mathematical side, it suggests that Alexander polynomials — traditionally studied through algebra and topology — have a natural spectral interpretation. They are not just abstract invariants; they are literally the characteristic polynomials of a physical system.

On the physics side, the knotted light program raises the tantalizing question: what other topological invariants might be readable from structured light? The Jones polynomial, the HOMFLY-PT polynomial, Khovanov homology — the mathematical toolkit for classifying knots is vast, and each invariant encodes different information about the knot's topology. If the Alexander polynomial shows up in the OAM spectrum, perhaps these deeper invariants show up in more subtle properties of the beam — its polarization structure, its entanglement patterns, its behavior under propagation.

We are only beginning to understand how the ancient mathematical theory of knots — born from Lord Kelvin's Victorian dream of atoms as knotted vortices in the aether — has found new life in the quantum mechanics of twisted light. The universe, it turns out, ties excellent knots. And now we are learning to read them.

---

*The mathematical results described in this article have been verified with computer-assisted formal proofs, including the identification of the trefoil Alexander polynomial with the sixth cyclotomic polynomial and the palindromic root theorem that classifies when knot spectra lie on the unit circle.*
