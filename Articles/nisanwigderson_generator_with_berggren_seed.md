# The Ancient Triangle That Learned to Lie

## How Pythagorean triples — the oldest objects in mathematics — became a new source of randomness for the digital age

---

Three, four, five.

It is the oldest fact in mathematics: a triangle with sides of length 3, 4, and 5 always has a perfect right angle. Babylonian scribes carved it into clay tablets four thousand years ago. It is, in a sense, where mathematics began.

What nobody expected was that this ancient arithmetic — and its infinite family of relatives — could be weaponized to do something utterly modern: generate numbers that *look* random but aren't, with mathematical guarantees strong enough to fool any efficient polynomial test.

A new line of research shows that the tree of Pythagorean triples, explored through a semigroup of three simple matrix transformations discovered by Berggren in 1934, has the kind of deep structural mixing that makes it a viable source of pseudorandomness — the controlled form of "fake randomness" that underpins modern computing, from randomized algorithms to cryptographic protocols.

The result is a bridge between two seemingly unrelated worlds: the pure arithmetic geometry of integer triangles and the complexity-theoretic science of derandomization.

---

## The Problem with Randomness

Randomness is one of the most powerful tools in computing. When an algorithm doesn't know what to do, flipping a coin can help — dramatically. Randomized algorithms for primality testing, polynomial identity verification, and network routing are faster, simpler, and more elegant than their deterministic cousins.

But randomness has a dirty secret: we don't really have it.

True randomness — the quantum-mechanical kind — is expensive and slow to harvest. What computers actually use are *pseudorandom number generators* (PRGs): deterministic algorithms that stretch a short random seed into a long stream of numbers that, for all practical purposes, look random.

The mathematical challenge is profound: can you construct, *explicitly*, a function that takes a short seed and produces output that no efficient test can distinguish from genuine randomness? The seminal framework of Nisan and Wigderson from the 1990s showed this is possible *in principle*, but constructing concrete, provably good generators remains one of the deepest open problems in theoretical computer science.

Most known constructions rely on algebraic tricks over finite fields — carefully chosen polynomials, linear-algebraic operations, or combinatorial designs. They are beautiful, but they all draw from the same well.

What if there were a completely different source of pseudorandomness? Something that comes not from algebra, but from *dynamics* — the chaotic mixing behavior of arithmetic orbits?

---

## A Tree of Triangles

Every primitive Pythagorean triple — that is, every solution to *a² + b² = c²* where *a*, *b*, and *c* share no common factor — can be reached from (3, 4, 5) by applying sequences of three matrix transformations. These three matrices, discovered by the Danish mathematician Berggren, act on triples like branches of a tree: apply the first matrix to get one child, the second for another, the third for a third. Every primitive triple appears exactly once in this infinite ternary tree.

The matrices themselves are elegant 3×3 arrays of small integers. But their behavior, when composed in long chains, is anything but simple. Applying a random sequence of 30 Berggren matrices to (3, 4, 5) produces triples with coordinates in the billions — numbers that appear wildly unrelated to the small integers you started with.

Here is the key observation: if you reduce these enormous coordinates modulo a small number — say, divide by 7 and take the remainder — the results look *uniform*. Not approximately uniform in a vague sense, but precisely uniform in a way that can be quantified with exponential accuracy.

---

## The Spectral Engine

The mathematical engine behind this phenomenon is *spectral gap*.

Think of the Berggren walk as a random surfer on a network. The network's nodes are the possible residues of Pythagorean triples modulo some number *q*. Each step of the walk applies one of the three Berggren matrices at random, moving to a new node. The question is: how quickly does the surfer's location become unpredictable?

The answer depends on the eigenvalues of the network's transition matrix — specifically, on whether the second-largest eigenvalue, *ρ*, is strictly less than 1. If it is, then the gap *1 − ρ* controls the rate of mixing: after *ℓ* steps, the surfer's distribution is within *ρ^ℓ* of perfectly uniform. Since *ρ < 1*, this decays exponentially.

This is the *spectral gap to pseudorandomness transfer*: a gap in the spectrum of an operator translates directly into a guarantee that structured tests cannot distinguish the walk's output from true randomness.

What makes this result clean and surprising is how universal the mechanism is. The abstract theorem requires only three ingredients:

1. A finite state space with a transition operator.
2. The operator preserves a natural notion of "average."
3. The operator contracts functions that have zero average.

From these, exponential decay of correlations follows by mathematical necessity — not by clever construction, but by the spectral geometry of the operator itself.

---

## Fooling Polynomials

The practical punch comes from a corollary: the Berggren walk doesn't just converge to uniform in a statistical sense — it *fools* polynomial tests.

A polynomial test of degree *d* is a function that takes the walk's output modulo *q* and evaluates a polynomial of total degree at most *d*. In complexity theory, fooling such tests is a fundamental benchmark: if your pseudorandom generator can do it, it can substitute for true randomness in a wide class of algorithms.

The theorem establishes that any finite family of mean-zero polynomial phase tests has bias at most *ρ^ℓ* against the Berggren walk of length *ℓ*. This means: for any polynomial test of any degree, you can make the fooling error as small as you like by walking long enough. And "long enough" means only *O(log(1/ε))* steps to achieve error *ε*, because the decay is exponential.

---

## Computed Spectral Gaps

Numerical experiments reveal something remarkable: the spectral gap of the Berggren action is not just nonzero — it appears to be *universal* across moduli.

For every modulus tested between 3 and 29, the second eigenvalue of the Berggren transition matrix is approximately 0.577 — that is, *1/√3*. The spectral gap is a rock-solid 0.423, independent of the modulus.

This constancy is itself a deep phenomenon. It suggests that the Berggren semigroup may form a *uniform expander family* — a family of graphs with expansion bounded away from zero as the size grows. Uniform expander families are prized objects in both mathematics and computer science. Proving that the Berggren congruence graphs form one would be a major theorem in its own right, connecting to deep results in automorphic forms and thin-group theory.

---

## Why This Matters

The significance extends far beyond Pythagorean triples.

**A new paradigm for derandomization.** Existing pseudorandom generators come from finite-field algebra. This work shows that *arithmetic dynamics* — the iteration of integer matrices — can serve the same purpose. It opens a new design space for PRGs based on the chaotic behavior of semigroup orbits.

**From ancient number theory to modern complexity.** The connection between Pythagorean triples and computational pseudorandomness is genuinely surprising. It suggests that the number-theoretic structure encoded in the Berggren tree has depth that was not previously recognized.

**Expander graphs for free.** The Berggren action on congruence quotients naturally produces families of expander graphs — objects with applications to error-correcting codes, network design, and randomness extraction. Getting expanders from an arithmetic source is unusual and valuable.

**A template for other arithmetic systems.** The framework is not specific to Berggren. Any finitely generated semigroup acting on an arithmetic quotient with a spectral gap produces the same type of pseudorandomness. This includes the Apollonian group acting on circle packings, and potentially other thin subgroups of arithmetic lattices.

---

## The Bigger Picture

There is a grand vision in complexity theory known as the *hardness-versus-randomness* paradigm: the idea that pseudorandomness is a consequence of computational hardness. If certain problems are hard, then efficient randomness doesn't add power to computation — the celebrated conjecture P = BPP.

This work approaches the same territory from a different direction. Instead of deriving pseudorandomness from hardness, it derives pseudorandomness from *dynamics* — the mixing properties of arithmetic orbits. If the Berggren congruence quotients expand uniformly (as the numerical evidence strongly suggests), then there exists an explicit pseudorandom generator with logarithmic seed length that fools all bounded-degree polynomial tests.

That would be a contribution to the long march toward P = BPP, but from a wholly unexpected direction: not through circuit lower bounds or derandomization tricks, but through the arithmetic geometry of right triangles.

---

## From Clay Tablets to Algorithms

There is something deeply satisfying about this circle of ideas. The Babylonians who carved Pythagorean triples into their tablets could not have imagined that four millennia later, those same numbers would find application in the theory of randomized computation.

Yet mathematics has always been like this: patient, accumulating, occasionally revealing connections between ideas separated by centuries and continents. The spectral gap of the Berggren semigroup is a bridge between the oldest theorem in geometry and the newest frontier of algorithmic science.

The right triangle still has secrets to tell.
