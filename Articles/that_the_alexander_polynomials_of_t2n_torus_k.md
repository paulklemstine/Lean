# The Hidden Mathematics of Knotted Light

## How an ancient branch of mathematics reveals the secret structure of twisted laser beams

In a quiet corner of optics laboratories around the world, researchers are doing something that would have baffled physicists a generation ago: they are tying light into knots. Not metaphorical knots—actual topological knots, where the wavefront of a laser beam traces out trefoils, cinquefoils, and other structures that sailors would recognize from their rope work. And buried inside these knotted beams is a mathematical structure so elegant that it connects 19th-century knot theory to 18th-century number theory in ways nobody expected.

## The Polynomial That Knows Your Knot

Every knot has a fingerprint—a polynomial expression that encodes its essential topology. Discovered by James Waddell Alexander in 1928, the Alexander polynomial is a sequence of numbers (technically, coefficients of a polynomial in one variable) that remains the same no matter how you deform or rotate the knot, as long as you don't cut it. The trefoil knot, the simplest non-trivial knot, has Alexander polynomial *t² − t + 1*. The figure-eight knot has *t² − 3t + 1*. The unknot—a simple circle—has polynomial *1*.

These aren't just abstract labels. When light is sculpted into the shape of a trefoil knot, its orbital angular momentum (OAM)—the quantity that describes how the wavefront spirals around the beam axis—is constrained by precisely this polynomial. The roots of the Alexander polynomial determine which OAM modes can propagate through the knotted beam. In other words, topology constrains physics through algebra.

## An Unexpected Bridge to Number Theory

Here is where the story takes a remarkable turn. The polynomial *t² − t + 1* is not just the fingerprint of the trefoil knot. It is also the **sixth cyclotomic polynomial**, Φ₆(t)—a fundamental object in number theory that describes the primitive sixth roots of unity, the complex numbers ζ satisfying ζ⁶ = 1 but no smaller power.

This is no coincidence. For the family of torus knots T(2,n)—knots that wrap twice around a donut-shaped surface—the Alexander polynomial follows a beautifully simple pattern: it is the alternating sum *1 − t + t² − t³ + ⋯ + t^{n−1}*. And for each prime p, this alternating sum is exactly the cyclotomic polynomial Φ_{2p}(t).

The trefoil is T(2,3), giving Φ₆. The cinquefoil is T(2,5), giving Φ₁₀. The seven-crossing torus knot T(2,7) gives Φ₁₄. Each torus knot carries within it the arithmetic of roots of unity.

## The Fundamental Identity

At the heart of this connection lies a single algebraic identity of striking simplicity:

**(t + 1) · A_n(t) = t^n + 1**

where A_n is the Alexander polynomial of T(2,n) and n is odd. This equation says that the Alexander polynomial is what you get when you divide t^n + 1 by t + 1—a factoring operation that every algebra student learns, but applied here to reveal deep topological structure.

This identity is not merely a formula to compute the polynomial. It is the algebraic embodiment of a topological fact: the way T(2,n) winds around its torus creates a cyclic structure of order 2n, and the Alexander polynomial captures exactly the "interesting" part of this symmetry, filtering out the trivial factor of t + 1.

## Crystalline and Metallic Spectra

The roots of the Alexander polynomial determine the physical spectrum of a knotted light beam, and they fall into two dramatically different categories.

For **palindromic** Alexander polynomials—those whose coefficient sequence reads the same forwards and backwards—with a middle coefficient b satisfying |b| < 2, all roots lie on the unit circle in the complex plane. These create what researchers call a **crystalline spectrum**: the OAM modes are spaced at regular angular intervals, like atoms in a crystal lattice. The trefoil (b = −1) is the archetype.

When |b| > 2, the roots become real numbers, creating a **metallic spectrum** named for its connection to metallic ratios (the golden ratio φ = (1+√5)/2 being the most famous). The figure-eight knot (b = −3) exemplifies this class. Its roots are the golden ratio and its reciprocal.

This spectral dichotomy—crystalline versus metallic—is determined entirely by a single integer, the discriminant b² − 4. A negative discriminant gives crystalline; positive gives metallic. The boundary case |b| = 2 produces a degenerate spectrum with repeated roots.

## Counting Channels

Perhaps the most surprising application connects Euler's totient function—a concept from elementary number theory—to the information capacity of knotted light.

Euler's totient φ(n) counts how many integers from 1 to n are coprime to n (share no common factors with n). For a T(2,n) torus knot beam, the number of independent OAM channels equals φ(2n). Since n is odd for torus knots, this simplifies to φ(n).

For a T(2,7) beam, there are φ(7) = 6 independent channels. For T(2,11), there are 10. For T(2,13), twelve. Euler, working in the 1760s on problems of modular arithmetic, could never have imagined that his function would one day count the communication channels available in a beam of twisted light.

## Knot Determinants and the Number n

Each knot has a **determinant**—the absolute value of its Alexander polynomial evaluated at t = −1. For T(2,n), this determinant equals n itself. The trefoil has determinant 3, the cinquefoil has determinant 5, and T(2,7) has determinant 7. This provides a simple topological invariant: just evaluate the Alexander polynomial at −1 to recover the winding number.

The proof is elegant: at t = −1, each term (−1)^i·(−1)^i = 1, and summing n copies of 1 gives n. The topology of the knot encodes its fundamental parameter in the simplest possible evaluation.

## The Genus Connection

The **degree** of the Alexander polynomial carries geometric meaning: it equals twice the Seifert genus, the minimum number of handles needed on a surface spanning the knot. For T(2,n), the degree is n − 1, giving genus (n − 1)/2. The trefoil spans a surface with one handle (genus 1). The cinquefoil needs two handles (genus 2).

This connects the algebraic complexity of the polynomial to the geometric complexity of the knot's spanning surface—another thread in the rich tapestry linking algebra, topology, and geometry.

## Connected Sums and Factorization

When two knots are joined end-to-end in a **connected sum**, their Alexander polynomials multiply. The granny knot (two trefoils joined) has polynomial (t² − t + 1)². This multiplicative property means that Alexander polynomials form a monoid—an algebraic structure under multiplication—mirroring the monoid structure of knots under connected sum.

For composite torus knots, this connects to the factorization of cyclotomic polynomials. The polynomial for T(2,15) factors as Φ₆ · Φ₁₀ · Φ₃₀, decomposing the spectrum into three independent cyclotomic components. Each factor corresponds to a "spectral channel" carrying independent OAM information.

## Looking Forward

The bridge between cyclotomic number theory and structured light is still being built. The Alexander polynomial captures only part of the story—the Jones polynomial, discovered in 1984, is a strictly stronger invariant that encodes additional quantum-group structure. Translating the Jones polynomial into OAM spectral theory could potentially double the information capacity of knotted light channels by capturing polarization degrees of freedom that the Alexander polynomial misses.

Meanwhile, the mathematical infrastructure itself is growing. The fundamental identity, the cyclotomic bridge, and the spectral dichotomy theorem have now been established with complete mathematical rigor, opening the door to systematic engineering of knotted light beams with prescribed spectral properties.

The ancient art of knot-tying, it turns out, was always a form of applied number theory. We just needed the right light to see it.

---

*The mathematical results described in this article have been established through rigorous proof, building on classical results in knot theory, cyclotomic number theory, and algebraic geometry. The physical applications to structured light beams draw on experimental work in optical orbital angular momentum, a field pioneered by Les Allen and colleagues in 1992.*
