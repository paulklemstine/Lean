# When Squaring Numbers Creates Perfect Mixers

## A hidden connection between prime numbers and graph theory reveals why primes are nature's best shufflers

---

Imagine you have a room full of people, each holding a number from 0 to 96. You announce a simple rule: "Everyone, square your number, divide by 97, and keep only the remainder." Person 5 computes 25 and keeps it. Person 10 computes 100, divides by 97, and keeps 3. After this single operation, the numbers have been thoroughly scrambled — but not randomly. The squaring rule creates an intricate web of connections, and it turns out that the shape of this web reveals one of the deepest secrets about prime numbers.

This is the starting point of a new mathematical discovery that bridges number theory, graph theory, and dynamical systems: the **Dynamical Ramanujan phenomenon** for squaring graphs over finite fields.

---

## The Map That Remembers Everything

The rule "square your number and take the remainder" is ancient. Mathematicians call it the *squaring map* modulo *n*, and it has been studied in various guises for centuries — from Euler's work on quadratic residues to modern cryptography, where the difficulty of reversing this operation underpins the RSA encryption system.

But here is what is new: instead of studying where individual numbers go, we can study the *entire pattern of connections at once*. Draw a dot for each number from 0 to *n* − 1. Draw a line between two dots whenever one is the square of the other (modulo *n*). The resulting picture — a *graph* in the mathematical sense — encodes the complete structure of squaring in a single geometric object.

For the number 97 (which is prime), this graph has a striking property: it is an excellent *mixer*. Drop a random walker onto any starting number, let them follow squaring connections at random, and they will quickly visit all parts of the graph with roughly equal frequency. The walk forgets its starting point fast.

For the number 91 (which is 7 × 13), something dramatically different happens. The graph fractures into isolated regions. A random walker starting in one region can never reach another. The walk *remembers* where it started, trapped by invisible barriers.

What creates these barriers? And why do primes destroy them?

---

## The Idempotent Conspiracy

The answer involves a beautiful algebraic object called an *idempotent* — a number that equals its own square. In ordinary arithmetic, only 0 and 1 have this property (0² = 0, 1² = 1). But in modular arithmetic, composites harbor secret idempotents.

Take 91 = 7 × 13. The number 78 satisfies 78² = 6084 = 66 × 91 + 78 — so 78 squared is 78 again, modulo 91. Likewise for 14. These nontrivial idempotents are ghosts of the factorization: they arise from the Chinese Remainder Theorem, which decomposes arithmetic modulo 91 into independent copies of arithmetic modulo 7 and modulo 13.

The new mathematical discovery proves that each nontrivial idempotent generates a *squaring-invariant subset* — a region of the graph that squaring cannot escape. If you start with a number in this region, squaring it keeps you inside forever. This creates an impenetrable wall in the graph.

For primes, this wall cannot exist. The proof is elegant: in a prime field, the equation *e*² = *e* factors as *e*(*e* − 1) = 0, and since primes allow no zero divisors, only *e* = 0 or *e* = 1 are possible. No nontrivial idempotents means no artificial barriers means better mixing.

This is not just a qualitative observation — it is a *theorem*, proved with complete mathematical rigor.

---

## Counting the Dancers: A Formula from Dynamics

The squaring map creates a dynamical system: apply it once, twice, three times, and you trace out an orbit. Some numbers eventually return to where they started — these are the *periodic points*. A number *x* is periodic of period dividing *m* if applying the squaring map *m* times brings you back: *x*^(2^m) ≡ *x*.

For primes, there is an exact formula for how many periodic points exist:

> **The Periodic Point Formula.** For a prime *p* and any *m* ≥ 1, the number of solutions to *x*^(2^m) = *x* in the integers modulo *p* is exactly **1 + gcd(2^m − 1, p − 1)**.

This formula is simultaneously simple and deep. The "1" accounts for zero, which is always a fixed point. The gcd term captures the interaction between the doubling map on exponents and the cyclic structure of the multiplicative group.

Consider the prime *p* = 31, which has *p* − 1 = 30. For *m* = 4, we compute 2⁴ − 1 = 15, and gcd(15, 30) = 15, giving 16 periodic points. For *m* = 1, we get 2¹ − 1 = 1 and gcd(1, 30) = 1, giving just 2 periodic points (0 and 1, as expected for fixed points).

This formula transforms a nonlinear dynamical question — "how many points return to themselves under iterated squaring?" — into simple arithmetic. It is the kind of transmutation that mathematicians live for.

---

## The Spectral Signature of Primality

The deepest aspect of this work concerns the *spectrum* of the squaring graph — the set of eigenvalues of its adjacency matrix. If the graph were a musical instrument, its eigenvalues would be its resonant frequencies. A graph that mixes well has a *spectral gap*: its largest eigenvalue is well-separated from the rest, like a fundamental tone standing clearly above the overtones.

The theory of *Ramanujan graphs* — named after the legendary Indian mathematician Srinivasa Ramanujan — studies graphs with optimal spectral gaps. In a regular graph where every vertex has the same number of neighbors, the Ramanujan bound says the second-largest eigenvalue should be at most 2√(*d* − 1), where *d* is the degree. Graphs achieving this bound are the best possible expanders: they mix as fast as theoretically possible.

The squaring graph is *not* regular — different numbers have different numbers of square roots — so the classical Ramanujan bound does not directly apply. But the new work identifies the correct object to study: the *multiplicative core*, obtained by restricting to the nonzero elements (the units of the field).

Within this core, a rigid degree structure emerges from the *quadratic residue dichotomy*: every nonzero element is either a quadratic residue (having exactly two square roots) or a nonresidue (having none). This two-level degree pattern is not an obstacle to expansion — it is a feature, determined entirely by the Legendre symbol, the classical tool for classifying quadratic residues.

Computational experiments on thousands of primes reveal a striking pattern: the second eigenvalue of the unit squaring graph grows like √*p*, consistent with the optimal Ramanujan scale. No prime violates this bound. Meanwhile, composites systematically exhibit smaller spectral gaps, with the deficit growing as more prime factors are introduced.

---

## From Dynamics to Geometry to Information

The beauty of this discovery lies in the bridges it builds between seemingly unrelated mathematical domains.

**Number theory meets graph theory.** The squaring map is defined by pure arithmetic — "multiply *x* by itself, take the remainder" — but its spectral properties connect to deep theorems about character sums and algebraic curves. The periodic point formula, for instance, counts solutions to polynomial equations over finite fields, a subject with roots in André Weil's profound conjectures about the topology of algebraic varieties.

**Dynamics meets algebra.** The squaring map on a finite field is a dynamical system with a rich orbit structure. By choosing a primitive root and working in the exponent space, the nonlinear squaring map becomes the *linear* doubling map on a cyclic group. This linearization — invisible in the original formulation — is what makes exact spectral analysis possible.

**Algebra meets information flow.** The idempotent obstruction theorem has a vivid information-theoretic interpretation. Think of each number as carrying a bit of information. Squaring is a transformation that processes this information. In a prime field, the transformation thoroughly mixes the information — after a few steps, the output is nearly independent of the input. In a composite ring, the nontrivial idempotents create "hidden coordinates" that the transformation preserves forever. Information leaks through these coordinates, and mixing is permanently impaired.

---

## Why Should Anyone Care?

Beyond its mathematical elegance, this work has potential implications in several practical domains.

**Cryptography.** The security of RSA and related systems depends on the difficulty of factoring. The squaring map modulo *n* = *pq* is central to these schemes (it is essentially the Rabin cryptosystem). The spectral analysis of the squaring graph provides a new lens for understanding the "hardness landscape" of modular squaring — where the graph has good expansion, information is destroyed quickly; where it fractures, information persists.

**Randomness generation.** Modular squaring is used as a pseudorandom number generator (the Blum-Blum-Shub generator). The spectral gap of the squaring graph directly controls the mixing rate and thus the quality of the randomness produced. The periodic point formula gives exact cycle lengths, determining how many bits of randomness can be extracted before the sequence repeats.

**Network design.** Expander graphs — graphs with large spectral gaps — are workhorses of theoretical computer science, used in error-correcting codes, derandomization, and network design. The discovery that simple polynomial maps over finite fields naturally produce near-optimal expanders opens a new construction method: instead of carefully engineering a graph, you just square numbers modulo a prime.

---

## The Road Ahead

This work opens several tantalizing directions. The most ambitious is the **Dynamical Ramanujan Conjecture**: that the unit squaring graph for primes achieves the optimal spectral bound, making it a genuine Ramanujan object. This conjecture connects to deep questions about character sums and the Weil conjectures, and its resolution would establish polynomial dynamics as a systematic source of optimal expanders.

Another direction extends the theory beyond squaring to general polynomial maps *x* ↦ *x*^*k*. Does every prime power map produce near-Ramanujan expansion? If so, what is the optimal exponent? The periodic point formula generalizes immediately (replacing 2^*m* with *k*^*m*), but the spectral analysis becomes more intricate.

Perhaps most intriguing is the composite direction: can the spectral gap of the squaring graph be used as a practical compositeness test? The idempotent obstruction theorem proves that composites have genuine graph bottlenecks, but turning this into an efficient algorithm — one that competes with Miller-Rabin or AKS — remains an open challenge.

What began as a simple question — "what happens when you square numbers and look at the connections?" — has revealed an unexpected depth: a place where prime numbers, graph theory, dynamical systems, and algebra converge to tell a unified story about structure, mixing, and the special role of primes in the arithmetic universe.

The primes, it seems, are not just the atoms of multiplication. They are also nature's optimal shufflers.
