# When Light Ties Itself in Knots

## A hidden connection between tangled laser beams and century-old mathematics

---

In a dimly lit optics lab in Glasgow, a team of physicists performed an experiment that would have baffled both Newton and Euler. They fired a laser beam through a carefully designed holographic plate and watched as the beam's dark core—the line where its intensity drops to zero—twisted itself into a pretzel shape. Not just any pretzel: a trefoil knot, the simplest knot that cannot be untangled without cutting.

The beam of light had literally tied itself in a knot.

This was not a parlor trick. The knotted structure was stable, self-sustaining, and encoded in the fundamental physics of the beam. And buried inside it was a mathematical fingerprint that connects to one of the most beautiful ideas in twentieth-century mathematics: the Alexander polynomial.

## The Twist That Changes Everything

To understand knotted light, you first need to understand a peculiar property of laser beams that wasn't appreciated until the 1990s. Light doesn't just carry energy and momentum in the usual sense—it can also carry *orbital angular momentum*, or OAM. Think of it this way: a normal laser beam is like a river flowing straight downstream. A beam with OAM is like a river that spirals as it flows, its wavefront twisting around the beam's axis like threads on a screw.

The amount of twist is quantized. A beam can carry one unit of OAM, or two, or seventeen, but never one and a half. These discrete twist levels—called OAM modes—give each beam a spectral fingerprint, a set of allowed angular momentum values that characterize its structure.

Now here's where things get interesting. When a beam carries multiple OAM modes simultaneously, its dark core—the singular line where all those twisting wavefronts cancel out—can trace out a curve in three-dimensional space. And that curve can be knotted.

The simplest knotted beam has a singularity that traces a trefoil knot, the same three-crossing knot you'd tie in a piece of rope if you made a basic overhand knot and joined the ends. More complex beams create figure-eight knots, cinquefoil knots, and in principle, any knot at all.

## A Polynomial That Knows Your Knot

Here is where a century of pure mathematics comes crashing into the optics lab.

In 1928, the American mathematician James Waddell Alexander published a paper that would transform knot theory from a qualitative enterprise into a computational one. He discovered that every knot has an associated polynomial—a simple algebraic expression—that remains unchanged no matter how you deform the knot, as long as you don't cut it. For the trefoil, this polynomial is:

$$\Delta(t) = t^2 - t + 1$$

For the figure-eight knot:

$$\Delta(t) = -t^2 + 3t - 1$$

For the unknot (a simple circle, not knotted at all):

$$\Delta(t) = 1$$

These Alexander polynomials are *invariants*: two knots with different polynomials are guaranteed to be topologically distinct. The trefoil and the figure-eight are fundamentally different objects, and their polynomials prove it.

Alexander never imagined that his polynomials would appear in the physics of light. But they do, and the connection is both surprising and deep.

## The Spectral Fingerprint

The key insight is this: the Alexander polynomial of a knot determines the OAM spectrum of the corresponding knotted light beam.

To see how, evaluate the Alexander polynomial not at ordinary numbers, but at points on the unit circle in the complex plane—numbers of the form $e^{2\pi i\theta}$, which live on a circle of radius one. The values of $\theta$ where the polynomial vanishes correspond to the OAM modes of the beam.

For the trefoil, $\Delta(t) = t^2 - t + 1$ vanishes at $t = e^{\pm i\pi/3}$, giving $\theta = 1/6$ and $5/6$. These correspond to OAM modes $l = 1$ and $l = 5$ (modulo 6). The trefoil beam has exactly two OAM modes on the unit circle, and they sit at the vertices of a regular hexagon.

For the figure-eight knot, $\Delta(t) = -t^2 + 3t - 1$ has roots at $(3 \pm \sqrt{5})/2$—the golden ratio and its conjugate. These are real numbers, not on the unit circle, which means the figure-eight knot's OAM spectrum on the unit circle is empty. Its spectral fingerprint is fundamentally different from the trefoil's.

For the unknot, $\Delta(t) = 1$ has no roots at all. An unknotted beam carries only the trivial OAM mode: no twist, no spectral structure.

## Connected Sums: Knots That Add

One of the most elegant results in this framework concerns what happens when you tie two knots together—an operation mathematicians call the *connected sum*.

If you splice a trefoil and a figure-eight knot together, the resulting knot has an Alexander polynomial that is simply the product of the two individual polynomials. The OAM spectrum of the combined knot is the union of the individual spectra. This is not just a convenient mathematical fact; it's a theorem with a rigorous proof.

This means that knotted light beams compose cleanly. The spectral signature of a compound knot contains the spectral signatures of its components, like a chord containing its individual notes. You can look at the OAM spectrum of a complex knotted beam and decompose it into simpler knots—a kind of spectral knot analysis.

## The Cyclotomic Connection

There is a remarkable pattern hiding in the Alexander polynomials of certain knots. The trefoil's polynomial, $t^2 - t + 1$, is the sixth *cyclotomic polynomial*—the minimal polynomial whose roots are the primitive sixth roots of unity. The cinquefoil's Alexander polynomial, $t^4 - t^3 + t^2 - t + 1$, is the tenth cyclotomic polynomial.

These are called *fibered knots*, and their Alexander polynomials are products of cyclotomic polynomials. For these special knots, every root of the Alexander polynomial lies on the unit circle, and the number of OAM modes equals the degree of the polynomial. The trefoil has degree 2 and exactly 2 OAM modes. The cinquefoil has degree 4 and exactly 4 OAM modes.

For non-cyclotomic knots like the figure-eight, the roots wander off the unit circle into the real number line, and the spectral structure is qualitatively different. This creates a clean dichotomy: cyclotomic knots have rich OAM spectra on the unit circle, while non-cyclotomic knots have their spectral weight elsewhere.

## A Bridge Between Worlds

What makes this connection profound is that it links three seemingly unrelated domains of mathematics and physics.

*Topology* provides the knot—the shape of the singularity in space. *Algebra* provides the Alexander polynomial—a computable invariant that encodes the knot's complexity. *Physics* provides the OAM spectrum—a measurable quantity that can be extracted from a real laser beam using standard optical equipment.

The Alexander polynomial serves as a Rosetta Stone, translating between the language of knots and the language of light. Shine a laser through a hologram shaped like a knot, measure the OAM spectrum of the emerging beam, and you have computed a topological invariant using photons.

This is not just a theoretical curiosity. It suggests practical applications in optical communications, where different knot types could encode different channels of information. Each knot produces a distinct OAM spectrum, and these spectra are orthogonal—they don't interfere with each other. A trefoil beam and a figure-eight beam could carry independent data streams through the same optical fiber, distinguished by their topological fingerprints.

## The Fourier Interpretation

There is yet another way to see the connection, one that brings in the mathematics of signal processing.

The coefficients of the Alexander polynomial are, in a precise sense, the Fourier coefficients of the OAM spectral density. For the trefoil, the polynomial $t^2 - t + 1$ has coefficients $(1, -1, 1)$, meaning the zeroth Fourier mode has amplitude 1, the first has amplitude $-1$, and the second has amplitude 1. The total spectral weight—the sum of all coefficients—equals 1, a normalization condition that holds for every knot.

This means the Alexander polynomial isn't just an abstract algebraic invariant. It's a complete description of the frequency content of the OAM beam, with each coefficient telling you how much energy sits in each angular mode. The knot's topology is literally encoded in the beam's frequency spectrum.

## What We Don't Yet Know

The OAM-Alexander correspondence opens as many questions as it answers. The most tantalizing is the *spectral conjecture*: for knots whose Alexander polynomial is cyclotomic, does the number of OAM modes on the unit circle always equal the polynomial's degree? We have verified this for the trefoil and cinquefoil, but a general proof remains elusive.

There is also the question of *realizability*: given an arbitrary polynomial satisfying the Alexander polynomial constraints (evaluating to 1 at $t = 1$, with degree bounded by the crossing number), can one always construct a physical light beam whose singularity traces a knot with that polynomial? The mathematics says yes; the engineering is another matter.

And then there is the deepest question of all: does this connection extend beyond the Alexander polynomial to more powerful knot invariants? The Jones polynomial, discovered in 1984, is strictly stronger than the Alexander polynomial. The HOMFLY polynomial is stronger still. If these invariants also appear in the OAM spectra of suitably constructed beams, the implications for both mathematics and physics would be extraordinary.

## Light as a Calculator

Perhaps the most provocative way to think about knotted light is as a calculator—a physical device that computes topological invariants.

When you send a laser beam through a knot-shaped hologram, the beam's wavefront tangles itself according to the hologram's topology. The OAM spectrum of the emerging beam is a physical measurement that encodes the Alexander polynomial. In effect, the photons are performing a computation that would otherwise require algebraic machinery.

This is computation by physics: instead of programming a computer to calculate a polynomial, you let the light do it for you. The knot's topology is the input, the OAM spectrum is the output, and the propagation of light through space is the algorithm.

In an era when quantum computing promises to harness the weirdness of physics for computational advantage, knotted light offers a different flavor of the same idea. The topology of space itself becomes a computational resource, and the most fundamental object in physics—a beam of light—becomes a topological computer.

The knot theorists of the early twentieth century could never have imagined that their polynomial invariants would one day be measured by photon detectors. The laser physicists of the late twentieth century could never have predicted that their structured beams would carry the DNA of mathematical knots. In the marriage of these two traditions lies a new science—one where topology is not just an abstract mathematical playground, but a physical force that shapes the behavior of light itself.

The beams are tangled. The math is beautiful. And the light knows things about knots that we are only beginning to understand.
