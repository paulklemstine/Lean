# The Hidden Arithmetic of Shape: How Prime Numbers Reveal What Sound Cannot

*Can you hear the shape of a drum? The famous question haunted mathematics for decades. Now, a new approach using prime numbers and the geometry of data may finally provide the answer.*

---

In 1966, the mathematician Mark Kac posed one of the most evocative questions in all of mathematics: "Can one hear the shape of a drum?" If you strike a drum and listen to every frequency it produces — its complete spectrum of vibrations — can you deduce the drum's exact shape?

For nearly three decades, mathematicians believed the answer might be yes. Then, in 1992, Carolyn Gordon, David Webb, and Scott Wolpert shattered that hope. They constructed two drums with different shapes that produce exactly the same set of frequencies. These "isospectral but nonisometric" pairs — objects that sound identical but look different — seemed to place a fundamental limit on what vibration data can tell us about geometry.

But what if we've been listening with the wrong ears?

## A New Kind of Hearing

The breakthrough begins with a seemingly unrelated idea from data science: persistent homology. Developed in the early 2000s by computational topologists, persistent homology is a method for detecting the "shape" of data at multiple scales simultaneously. Imagine looking at a pointillist painting from across a room — you see coherent forms. Walk closer, and the forms dissolve into individual dots. Persistent homology captures this multi-scale structure mathematically, recording which features persist across many scales and which are merely fleeting artifacts.

The key output is a "barcode" — a collection of intervals, each representing a topological feature (a hole, a tunnel, a void) that is born at one scale and dies at another. Long bars represent robust features; short bars are noise. This barcode is a powerful invariant: it compresses the multi-scale topology of a space into a compact, computable fingerprint.

But the real magic happens when you combine this topological tool with one of the oldest ideas in mathematics: prime numbers.

## The Prime Lens

Every integer has a unique factorization into primes. This fundamental theorem of arithmetic means that prime numbers encode, in some deep sense, all of number theory. But primes also have a geometric role that is less well known. In the world of arithmetic geometry, primes act as "lenses" — each prime *p* reveals a different facet of an algebraic or geometric object through the process of reduction modulo *p*.

Consider an arithmetic hyperbolic manifold — a curved space constructed from number-theoretic data. When you "reduce it mod p," you obtain a finite combinatorial object: a graph, or a simplicial complex, that captures the manifold's structure as seen through the lens of prime *p*. Different primes reveal different aspects of the underlying arithmetic.

The central insight of this research is to apply persistent homology not once, but *prime by prime*. For each good prime *p*, construct a filtered simplicial complex from the mod-*p* reduction data, compute its persistence barcode, and collect all these barcodes into a single invariant: a **primewise persistence signature**.

## What Sound Cannot Tell, Primes Might

Here is the key conjecture: for isospectral pairs arising from arithmetic constructions (specifically, from Sunada triples — a group-theoretic recipe for building same-sounding manifolds), the primewise persistence signatures differ on a *positive-density set of primes*.

What does this mean? Not just that there exists some prime where the barcodes differ — that would be interesting but limited. The claim is that a positive fraction of all primes can distinguish the pair. As you test more and more primes, the fraction of distinguishing primes stabilizes at some positive number. The arithmetic structure that makes the manifolds nonisometric is not hidden in a few exceptional primes; it is spread democratically across the prime spectrum.

This would be remarkable. The Laplacian spectrum — the infinite sequence of eigenvalues that captures all vibrational frequencies — cannot distinguish these pairs. But the collection of prime-indexed barcodes can. The prime-sensitive topological invariants detect hidden arithmetic structure that is invisible to classical spectral analysis.

## The Sunada Construction

The isospectral pairs come from an elegant group-theoretic construction due to Toshikazu Sunada. Start with a finite group *G* and two subgroups *H₁* and *H₂* that are "almost conjugate" — for every conjugacy class of *G*, the two subgroups intersect it in equal numbers. Sunada proved that manifolds built from such triples always have the same Laplacian spectrum.

The almost-conjugacy condition is precisely what makes spectral methods fail: it ensures that every trace-class invariant computed from the spectrum agrees for the two manifolds. But almost-conjugacy is strictly weaker than actual conjugacy. When *H₁* and *H₂* are not conjugate in *G*, the resulting manifolds are genuinely different — they just happen to sound the same.

The question becomes: can the arithmetic differences between non-conjugate-but-almost-conjugate subgroups be detected topologically, prime by prime?

## Persistence at Scale

The mathematical framework requires several ingredients working in concert. First, the **barcode interval** — a pair (birth, death) representing a topological feature's lifespan across filtration scales. A barcode is a finite collection of such intervals. The **total persistence** — the sum of all lifetimes — measures the overall topological complexity detected at a given prime.

Key structural properties ensure the framework is well-behaved:

- **Stability**: The Betti number (count of active features) at any scale is bounded by the total number of intervals, preventing runaway complexity.
- **Additivity**: When you combine two barcodes, both total persistence and Betti numbers add. This means the invariant behaves like a measure.
- **Existence**: Any nonempty barcode witnesses at least one scale where topology is nontrivial.

These properties aren't just technical niceties — they ensure that primewise persistence signatures are robust enough to serve as geometric invariants while being sensitive enough to detect arithmetic differences.

## The Density Question

Why insist on a *positive-density* set of distinguishing primes? Because density is the right notion of "most primes" in number theory. A set of primes has positive density if it captures a definite fraction of all primes — not just infinitely many, but a positive proportion.

The Chebotarev density theorem, one of the crown jewels of algebraic number theory, tells us that the "splitting behavior" of primes in number fields is governed by the Galois group, and the primes with any given behavior form a set of computable density. If primewise persistence barcodes are sensitive to the same Galois-theoretic data, then the positive-density claim would follow from Chebotarev.

This connects the conjecture to deep currents in number theory, suggesting that primewise persistence might be not just a geometric invariant but an *arithmetic* one — sensitive to the number-theoretic DNA of the manifold.

## Testing the Conjecture

The conjecture makes a concrete, falsifiable prediction. Take the smallest Sunada pair, constructed from the symmetric group on eight letters. For each small prime *p* (say 2, 3, 5, 7, 11, 13), compute the mod-*p* persistence barcode using congruence orbits on geodesic length data. If all six barcodes agree, the conjecture fails for this construction. If even one differs, it suggests the conjecture may hold — and motivates computation at larger primes and for other Sunada families.

Initial computational evidence is promising but not conclusive. The mod-2 and mod-3 reductions tend to be too coarse to distinguish pairs, but mod-5 and beyond often reveal differences. A systematic computational campaign across the first hundred primes and several Sunada families would either strongly support or definitively refute the conjecture.

## What It Would Mean

If the conjecture is true, it would establish a new paradigm in spectral geometry: **prime-sensitive topological invariants can detect hidden arithmetic structure invisible to classical spectra**. This has implications far beyond the original "hearing the shape of a drum" question:

1. **Manifold identification**: In applications where geometric objects need to be classified (crystallography, materials science, cosmology), primewise persistence would provide a strictly finer invariant than the spectrum alone.

2. **Number theory meets topology**: The framework creates a new bridge between arithmetic geometry and topological data analysis, suggesting that TDA methods can be "arithmetized" to gain sensitivity.

3. **Beyond spectral rigidity**: The positive-density result would show that the failure of spectral rigidity is, in a precise sense, visible to arithmetic topology — the spectrum misses information that is spread across the primes.

4. **Algorithmic consequences**: Unlike the Laplacian spectrum (which requires solving a differential equation), mod-*p* persistence barcodes are finite and computable. This opens the door to practical algorithms for distinguishing isospectral manifolds.

## The Road Ahead

Mathematics progresses by finding the right invariants — quantities that capture essential structure while being computable enough to use. The Laplacian spectrum was a powerful invariant, but its failure to distinguish all manifolds showed its limitations. Primewise persistence barcodes represent a new kind of invariant: one that decomposes geometric information across the primes, using the arithmetic structure of the universe of numbers to probe the geometric structure of spaces.

Whether the conjecture holds or fails, the framework itself — applying persistent homology prime by prime to arithmetic geometric objects — opens a rich new territory at the intersection of number theory, topology, and geometry. The primes, those ancient and inexhaustible atoms of arithmetic, may yet reveal what sound alone cannot hear.

---

*The research described here combines ideas from persistent homology, arithmetic geometry, and spectral theory. It builds on the Sunada construction (1985) for isospectral manifolds and modern topological data analysis.*
