# The Ancient Triangles Hiding Inside Your Encryption

*How a 4,000-year-old pattern in right triangles turned out to be the key to a new kind of mathematical compression*

---

There is a tree that mathematicians have been tending since 1934. Not a tree of wood and leaves, but a tree of numbers — an infinitely branching structure that contains, exactly once, every possible right triangle with whole-number sides and no common factors. It is called the Berggren tree, and until recently, it was considered a beautiful curiosity: a filing system for an ancient class of numbers that Babylonian scribes carved into clay tablets four millennia ago.

Now that tree has been revealed as something far more surprising. It is a *compression engine* — a machine for encoding and decoding a family of geometric objects called lattices, the same structures that underpin modern cryptography. The discovery creates a bridge between one of humanity's oldest mathematical obsessions and one of its most urgent technological challenges.

## The Triples That Never End

Every schoolchild learns about 3-4-5 triangles: three squared plus four squared equals five squared. Some discover 5-12-13, or 8-15-17. The natural question — how many such triples exist? — was answered long ago: infinitely many. But the deeper question — *is there a pattern?* — remained elusive for centuries.

In 1934, the Swedish mathematician Berggren found one. He showed that every primitive Pythagorean triple (one where the three numbers share no common factor) can be generated from the single "seed" triple (3, 4, 5) by applying three specific transformations. Think of it as a family tree: (3, 4, 5) is the ancestor, and each triple has exactly three children, produced by three different operations. The first child of (3, 4, 5) is (5, 12, 13). The second is (21, 20, 29). The third is (15, 8, 17). Each of those has three children of its own, and so on forever.

What makes this tree remarkable is that it is *complete* and *non-redundant*: every primitive Pythagorean triple appears exactly once. It is the perfect filing system.

But Berggren and his successors thought of this as a number-theoretic result — interesting, but self-contained. The tree was about triangles, and only about triangles.

They were wrong.

## The Gram Matrix Connection

To understand why, we need a concept from geometry called a Gram matrix. Suppose you have a collection of arrows (vectors) in space. The Gram matrix records the lengths and angles between them: the entry in row *i*, column *j* is the dot product of the *i*-th and *j*-th vectors. Gram matrices are the DNA of a lattice — the repeating grid pattern formed by integer combinations of those vectors.

Here is the key observation. Take any Pythagorean triple (a, b, c). The two legs, *a* and *b*, can be thought of as coordinates of a vector in the plane. The Gram matrix of that single vector is a tiny 2×2 matrix:

```
| a²   ab |
| ab   b² |
```

This matrix has a special property: its determinant is zero (it has "rank 1"), and its trace — the sum of the diagonal entries — equals a² + b² = c². In other words, the Gram matrix encodes exactly the Pythagorean relationship. The trace is the square of the hypotenuse.

When Berggren's three transformations act on a triple, they produce a new triple with a new Gram matrix. The Berggren tree is not just a tree of triangles — it is a tree of *Gram signatures*, each one encoding a tiny piece of lattice geometry.

## From Trees to Machines

The breakthrough came from asking a question that nobody had thought to ask: what if you treat the Berggren tree not as a static catalog, but as a *dynamic system* — a kind of machine?

Imagine a device with a finite number of internal states. At each state, the machine stores a Gram matrix. You can press one of three buttons — corresponding to the three Berggren transformations — and the machine transitions to a new state with a new Gram matrix. This device is called a *triple-tree Gram semimodule*.

The formal theory shows that these machines have a beautiful minimization property, analogous to a well-known result in computer science. In the 1950s, Anil Nerode proved that every pattern-recognizing machine (a finite automaton) has a unique smallest version: a minimal machine that recognizes the same patterns with the fewest possible states. Two states can be merged whenever they are "behaviorally indistinguishable" — when no future sequence of inputs could tell them apart.

The same principle applies to Gram semimodules. Two states are equivalent when no sequence of Berggren transformations can distinguish their Gram behavior. Merging equivalent states produces a *reduced* semimodule: the smallest machine with the same geometric content. And — crucially — this reduced machine is unique. Every lattice presentation with a Pythagorean Gram profile has exactly one canonical reduced representative.

## The Duality Theorem

The central result is a three-part theorem:

**Realization.** Every lattice whose geometry can be described by Pythagorean Gram data has a corresponding Gram semimodule — a finite-state machine that encodes it.

**Uniqueness.** Each such encoding has a canonical reduced form, unique up to relabeling of states. This is the Myhill–Nerode theorem transplanted from automata theory into lattice geometry.

**Reconstruction.** From the reduced semimodule, you can algorithmically recover a basis for the original lattice, together with a mathematical proof that the basis is optimal — its vectors are as short as possible.

The reconstruction is *certified*: it comes with a built-in guarantee, a mathematical receipt proving its own correctness. This is not "trust me, this answer is right." It is "here is the answer, and here is a machine-checkable proof that it is right."

## Why Cryptographers Should Care

Modern encryption — the kind that protects your bank account, your messages, your identity — increasingly relies on lattices. The security of lattice-based cryptography (the leading candidate for post-quantum encryption standards) depends on the difficulty of finding short vectors in high-dimensional lattices. Algorithms for lattice reduction — finding compact bases — are the beating heart of both attacks and defenses.

The Berggren duality theorem suggests a new approach to lattice problems for a specific family of instances: those whose Gram data factors through Pythagorean triples. For these cases, the lattice can be compressed into a Berggren certificate — a short string of symbols (sequences of 1s, 2s, and 3s) that encodes the lattice's essential geometry. Reduction becomes tree navigation. Shortest-basis reconstruction becomes path tracing.

This is not yet a general-purpose lattice reduction algorithm. But it opens a door. If the Pythagorean-Gram family can be handled this efficiently, what other families of lattices admit similar arithmetic compression? Can the Berggren framework be extended to higher dimensions, where encryption actually lives?

## The Compression Miracle

Consider a practical example. A lattice basis vector might be (3, 4) — a point in the integer plane. Its squared length is 25 = 5². In the Berggren tree, (3, 4, 5) is the root — it requires no address at all. The vector (5, 12) has squared length 169 = 13². The triple (5, 12, 13) is one step from the root: press button 1. The address is just "1".

For triples deep in the tree, the address is longer — "2-3-1-1" for some remote triple — but it grows only logarithmically with the size of the numbers involved. A vector with coordinates requiring hundreds of digits to write down can be specified by a short Berggren address. The reconstruction is exact: given the address, you recover the precise triple, hence the precise Gram data, hence the precise lattice vector.

This is not lossy compression. It is a lossless encoding of geometric structure into algebraic addresses, with mathematical guarantees attached.

## Ancient Meets Modern

There is something poetic about this discovery. The Pythagorean triples that Babylonian scribes enumerated on the tablet Plimpton 322, around 1800 BCE, turn out to encode information about lattice geometry — the mathematical framework that, four thousand years later, will protect digital communications from quantum computers. The Berggren tree, a twentieth-century refinement of an ancient catalog, becomes a twenty-first-century compression tool.

But the poetry runs deeper. The three Berggren matrices are not arbitrary. They preserve a mathematical structure called the Lorentz form — the same quadratic form that appears in Einstein's special relativity, governing the geometry of spacetime. The Pythagorean equation a² + b² = c² is the Euclidean shadow of the Lorentzian equation a² + b² − c² = 0. The Berggren tree is not just a catalog of triangles: it is a discrete arithmetic version of Lorentz symmetry, organizing right triangles the way spacetime symmetry organizes physical events.

The new duality theorem says this Lorentzian arithmetic structure is *functorially* connected to lattice geometry. The bridge is the Gram matrix — the geometric DNA that both sides share.

## Machines That Prove Themselves

Perhaps the most striking feature of this work is the reconstruction certificate. In most of mathematics — and certainly in most of engineering — when an algorithm outputs an answer, you have to trust the algorithm. If the code has a bug, or the floating-point arithmetic drifts, or the approximation is too coarse, the answer might be wrong and you would never know.

Certified reconstruction is different. The algorithm outputs not just a basis, but a *proof* that the basis has the claimed properties. A skeptical verifier can check the proof without understanding the algorithm, without trusting the implementation, without even knowing what a Berggren tree is. The proof is self-contained.

This matters for cryptography, where trust is the entire point. A certified lattice reduction algorithm would allow one party to prove to another that a cryptographic key was properly generated, without revealing the key itself — a kind of mathematical notarization.

## The Road Ahead

The current theory handles two-dimensional lattices with Pythagorean Gram profiles — a small but precisely understood family. The most exciting open questions concern generalization.

Can the framework extend to higher dimensions? Pythagorean triples generalize to *Pythagorean tuples* — solutions of a₁² + a₂² + ⋯ + aₙ² = c² — and there are tree structures for some of these. If the duality theorem extends, it could touch real-world lattice cryptography, which operates in hundreds or thousands of dimensions.

Can the Berggren dynamics be tropicalized? In tropical mathematics, addition becomes the minimum operation, and the resulting geometry has a piecewise-linear character that meshes beautifully with lattice problems. A tropical Berggren duality could connect shortest-vector problems to min-plus spectral theory, a largely unexplored territory.

And can the compression be made practical? The current certificates are proofs of concept — mathematically precise but not yet optimized for real-world use. Turning them into deployable tools for cryptographic preprocessing is an engineering challenge with deep mathematical substrates.

What began with clay tablets and right triangles has become a new interface between ancient arithmetic and modern security. The Berggren tree, lovingly cultivated by mathematicians for nearly a century, has borne unexpected fruit: not just a beautiful pattern in numbers, but a functional tool for the mathematics of privacy. The oldest theorem in the world still has surprises in store.
