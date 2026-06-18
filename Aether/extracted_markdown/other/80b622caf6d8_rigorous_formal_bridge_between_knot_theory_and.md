# When Light Ties Itself in Knots: How Number Theory Illuminates Photonics

## The Discovery That Laser Beams Can Be Knotted

In 2010, physicists at the University of Bristol accomplished something that sounds impossible: they created beams of light whose dark cores — the threads of zero intensity — traced out knots in three-dimensional space. Not simple loops, but genuine topological knots: trefoils, cinquefoils, and more complex structures that cannot be untied without breaking the beam.

These "knotted light" beams carry orbital angular momentum (OAM) — a rotational property where photons spiral around the beam axis like water around a drain. The number of spiral arms, and their angular spacing, determines the OAM spectrum: a fingerprint that encodes both the beam's topology and its information-carrying capacity.

But here's the mystery: not all OAM combinations can produce knots. Nature imposes strict selection rules, permitting only certain angular momentum values. Where do these rules come from?

The answer, it turns out, lives in one of the oldest and most beautiful branches of mathematics: the theory of cyclotomic polynomials, which has governed the arithmetic of roots of unity since Gauss's work on regular polygons in the 1790s.

## Polynomials That Encode Knots

Every knot has an associated polynomial — its Alexander polynomial — discovered by James Alexander in 1928. This polynomial encodes topological information about the knot complement, the pretzel-shaped space surrounding the knotted curve. For the trefoil knot (the simplest nontrivial knot, resembling a cloverleaf), the Alexander polynomial is:

> Δ(t) = t² − t + 1

This unassuming quadratic hides a profound identity. The polynomial t² − t + 1 is also the sixth cyclotomic polynomial Φ₆(t), whose roots are the primitive sixth roots of unity: the complex numbers e^{±iπ/3}, which sit at angles of ±60° on the unit circle.

This is not a coincidence. For every torus knot T(2,n) — knots that can be drawn on the surface of a donut — the Alexander polynomial equals a cyclotomic polynomial. The trefoil (the T(2,3) torus knot) corresponds to Φ₆. The cinquefoil (T(2,5)) corresponds to Φ₁₀. The pattern extends to T(2,7), which gives Φ₁₄, and beyond.

## The Spectral Dichotomy: Crystals and Metals

The cyclotomic connection creates a sharp physical dichotomy in the OAM spectra of knotted beams. The key parameter is the coefficient b in the palindromic quadratic t² + bt + 1 that describes many Alexander polynomials. The discriminant b² − 4 determines everything:

- **When |b| < 2** (e.g., the trefoil with b = −1): The discriminant is negative. All roots lie on the unit circle. The OAM spectrum is *crystalline* — a discrete set of angular momentum values at perfectly regular angular intervals. The trefoil's OAM modes sit at multiples of π/3, like the vertices of a hexagon.

- **When |b| > 2** (e.g., the figure-eight knot with b = −3): The discriminant is positive. Roots escape to the real line. The OAM spectrum becomes *metallic* — and the golden ratio φ = (1 + √5)/2 emerges as a root of the figure-eight's Alexander polynomial. This is the same number that governs phyllotaxis in sunflowers and the proportions of the Parthenon.

- **When |b| = 2**: The boundary case. A double root at ±1. The spectrum is degenerate.

This trichotomy — crystalline, metallic, degenerate — is mathematically complete. Every palindromic quadratic Alexander polynomial falls into exactly one category, with the boundary sharp and absolute.

## The Alternating Sum Identity: A Key to Periodicity

Underlying these results is a beautiful algebraic identity. Define the alternating polynomial:

> A_n(X) = 1 − X + X² − X³ + ⋯ + (−X)^{n−1}

For odd n, this polynomial satisfies:

> (X + 1) · A_n(X) = X^n + 1

This is the polynomial version of the geometric series formula, and it has a startling physical interpretation. The left side factors through (X + 1), which means the roots of A_n divide those of X^n + 1 — the (2n)-th roots of unity that equal −1. The OAM spectrum is therefore *periodic* with period 2n.

For the trefoil (n = 3), the spectral period is 6. For the cinquefoil (n = 5), it's 10. The angular spacing between consecutive OAM modes is exactly π/n. This periodicity is not approximate — it's an exact algebraic consequence of the cyclotomic structure.

## Composite Knots and Spectral Factorization

What happens when knots are combined? In knot theory, the "connected sum" operation joins two knots into a more complex one, and their Alexander polynomials multiply. The T(2,15) torus knot — whose parameter 15 = 3 × 5 is composite — provides a striking example.

Its Alexander polynomial factors into three cyclotomic polynomials:

> Δ_{T(2,15)} = Φ₆ · Φ₁₀ · Φ₃₀

Each factor contributes its own set of OAM modes: 2 modes from Φ₆ (the "trefoil modes"), 4 from Φ₁₀ (the "cinquefoil modes"), and 8 from Φ₃₀ (modes unique to the composite structure). The total — 14 modes — equals the degree of the Alexander polynomial, which in turn equals 2 × (Seifert genus), connecting polynomial algebra to the topology of spanning surfaces.

## Irreducibility and Prime Knots

The trefoil's Alexander polynomial t² − t + 1 is irreducible over the integers — it cannot be factored into simpler polynomial pieces. This algebraic primality mirrors topological primality: the trefoil is a prime knot, meaning it cannot be decomposed as a connected sum of simpler knots.

This parallel between algebraic and topological primality is not coincidental. It reflects a deep structural correspondence: the same cyclotomic polynomial Φ₆ that is irreducible in the ring of integers is also the Alexander polynomial of a topologically prime knot. Number-theoretic primality and knot-theoretic primality speak the same language.

## The Number Theory Connection

Cyclotomic polynomials occupy a central position in algebraic number theory. The nth cyclotomic polynomial Φₙ(t) generates the cyclotomic field ℚ(ζₙ), and its properties govern how prime numbers split in this field. The same polynomial that determines whether the prime 7 splits or remains inert in ℚ(ζ₆) also determines the OAM mode structure of a trefoil-knotted laser beam.

This suggests that arithmetic phenomena in number fields might have direct photonic analogs. The Frobenius element at a prime p, which describes splitting behavior, could correspond to a symmetry operation on the OAM spectrum. Ramification of primes might correspond to degeneracies in the spectrum. These connections remain speculative but tantalizing.

## Looking Forward

The bridge between knot theory and photonics, mediated by cyclotomic polynomials, opens several avenues:

**Quantum information.** Each OAM mode can encode a qubit. The cyclotomic structure constrains which qubits are available, potentially providing topological protection against noise — a connection to the topological quantum computing program.

**Materials science.** The crystalline/metallic spectral dichotomy mirrors the distinction between metals and insulators in condensed matter physics. Could knotted light beams probe or manipulate this transition?

**Pure mathematics.** The Jones polynomial, a more powerful knot invariant than the Alexander polynomial, might encode additional spectral information — perhaps in the polarization rather than the phase of the beam.

The story of knotted light is ultimately a story about how topology, number theory, and physics conspire. The same mathematical objects — cyclotomic polynomials, roots of unity, Euler's totient function — appear in contexts as different as the splitting of prime ideals and the angular momentum of photons. Whether this reflects a deep structural unity or a fortunate coincidence remains one of the most intriguing questions at the frontier of mathematical physics.
