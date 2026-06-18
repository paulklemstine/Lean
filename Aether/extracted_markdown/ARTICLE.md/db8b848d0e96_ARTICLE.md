# When Primes Whisper the Shape of Space

## How number theory might reveal the hidden geometry of the universe

---

Imagine you could tell whether a pretzel and a donut were fundamentally different shapes — not by looking at them, but by listening to the prime numbers embedded in their structure. That is, roughly, what a new line of mathematical research proposes: that the arithmetic of prime numbers, applied locally and systematically, can detect deep geometric properties of spaces that have resisted classification for decades.

The idea connects two seemingly unrelated worlds. On one side sits **algebraic topology**, the branch of mathematics that studies the shape of spaces by assigning algebraic structures — groups, rings, sequences — to them. On the other side sits **number theory**, the ancient study of prime numbers and their properties. A new conjecture proposes a bridge between these worlds, one that could turn an abstract geometric question into a concrete computational test.

## The Problem of Formality

In the 1970s, mathematicians Dennis Sullivan, Pierre Deligne, Phillip Griffiths, and John Morgan discovered something remarkable about a large class of geometric spaces called *Kähler manifolds*. These are the spaces that arise naturally in complex geometry — think of the surface of a sphere, or the more exotic shapes studied in string theory and algebraic geometry.

What they found was that these spaces are **formal**: their entire topological structure is determined by their cohomology ring, a relatively simple algebraic invariant. Formality is a powerful property. It means that complicated topological questions can be answered by simple algebraic calculations. It means that certain spectral sequences — elaborate bookkeeping devices that mathematicians use to compute topological invariants step by step — collapse early, at the second page. All the potential complexity disappears.

But most spaces are not formal. A generic manifold carries hidden algebraic structure — **Massey products**, **higher operations** — that cannot be read off from the cohomology ring alone. Detecting formality is notoriously difficult. You can prove a space is formal by exhibiting certain algebraic structures, but proving a space is *not* formal requires ruling out all possible such structures. It's an asymmetric battle.

## Enter the Primes

Here is where prime numbers enter the picture.

Every finite abelian group — a basic algebraic structure that appears throughout topology — decomposes uniquely into its *p-primary components*, one for each prime p. The 2-primary part captures all the "even" information; the 3-primary part captures the "threeness"; the 5-primary part captures the "fiveness"; and so on. This is the group-theoretic cousin of the fundamental theorem of arithmetic, which says every integer factors uniquely into primes.

Now consider a *filtered* sequence of such groups, like the ones that arise from successive approximations to a topological space. At each stage, you have a group, and as you move through the filtration, features are born and die. This birth-death pattern is recorded in a **barcode** — a collection of intervals, each representing a topological feature and its lifetime.

The key insight is to decompose this barcode by prime. For each prime p, you get a **p-primary barcode** that records only the p-torsion features. The length of each interval measures how long that p-torsion feature persists through the filtration.

## The Conjecture

The new conjecture makes a bold claim: **if all the p-primary barcodes are short — bounded by some universal function of the dimension — then the space must be formal.**

More precisely, there should exist a function B(d), depending only on the dimension d of the space, such that if every interval in every p-primary barcode has length at most B(d), then the Sullivan minimal model of the space is formal and the rational homotopy spectral sequence collapses at the second page.

This would mean that formality — a deep, global geometric property — is entirely controlled by *local* arithmetic data at each prime. The primes, acting independently, collectively determine the geometry.

## Why This Matters

If the conjecture is true, it would create something unprecedented: an **algorithmic detector for formality**. Instead of wrestling with abstract algebraic structures, you would compute persistence barcodes at each prime (a finite, mechanical process) and check whether all intervals are short. A "yes" answer would certify formality. A "no" answer — a single long interval at a single prime — would provide a concrete obstruction.

This connects to a deeper philosophical point about the relationship between local and global in mathematics. The conjecture says that local arithmetic data (what happens prime by prime) controls global geometric structure (formality of the entire space). This is reminiscent of the local-global principles that pervade number theory, from the Hasse-Minkowski theorem for quadratic forms to the Langlands program's vision of automorphic forms as local-global bridges.

## Testing the Conjecture

The conjecture makes specific, falsifiable predictions:

**For formal spaces** — compact Kähler manifolds, spheres, complex projective spaces — all p-primary barcode intervals should be short. The existing theory of formality for Kähler manifolds, combined with the Chinese Remainder Theorem decomposition of torsion, provides strong evidence for this direction.

**For non-formal spaces** — symplectic but non-Kähler manifolds, moment-angle complexes, certain wedge products with attached cells — at least one prime should exhibit a long barcode interval. The non-vanishing Massey products that obstruct formality should manifest as persistent p-torsion features.

A single non-formal space with uniformly short barcodes at every prime would refute the conjecture entirely. This makes it a genuinely scientific hypothesis, subject to computational falsification.

## The Mathematical Machinery

The rigorous foundation for this program involves several interacting pieces of mathematics.

First, there is the **prime decomposition** of torsion in filtered abelian groups. A key theorem establishes that if elements of a group are killed by coprime integers m and n, they must be zero — the torsion at different primes cannot interfere. This "orthogonality of primes" is what makes the primewise analysis possible.

Second, there is the **stabilization theorem**: any monotone decreasing sequence of natural numbers must eventually stabilize. Applied to spectral sequence ranks (which measure how much algebraic complexity survives at each page), this guarantees that spectral sequences always eventually collapse — the question is *when*.

Third, there is the **bridge theorem** connecting bounded torsion persistence to finiteness of the total barcode. If each prime's barcode has bounded intervals, the total amount of topological information across all primes is controlled. This quantitative control is what enables the leap from arithmetic data to geometric conclusions.

## A Candidate Bound

What might the universal bound function B(d) look like? One natural candidate is d! (d factorial), the product of all integers from 1 to d. This grows rapidly with dimension, which is geometrically reasonable — higher-dimensional spaces can support more complex topology. The factorial bound is monotone, positive, and grows at least linearly in d, all properties one would expect of a meaningful dimensional bound.

Whether d! is the right answer, or whether a tighter bound exists, is an open question that computational experiments could illuminate.

## Looking Forward

This research direction sits at a crossroads of several active areas of mathematics: persistent homology (which has found applications from data science to materials science), rational homotopy theory (which connects topology to algebra), and arithmetic geometry (which studies the interplay of number theory and geometry).

If the conjecture holds, it would suggest that the relationship between primes and geometry is even deeper than currently understood — that the arithmetic structure of space, decomposed prime by prime, contains a complete record of its geometric personality. The primes don't just factor numbers; they factor *shapes*.

And if it fails — if someone finds a non-formal space with universally short p-primary barcodes — that too would be revelatory, pointing to geometric phenomena that escape the reach of prime-local arithmetic. Either way, the mathematics wins.

The ancient Pythagoreans believed that "all is number." This conjecture suggests something more nuanced: all is number, but only if you listen to *every* prime.
