# The Hidden Fingerprints of Dynamical Systems

## How mathematicians are using prime numbers and topology to decode the secret identities of algebraic maps

---

In the early 1990s, a graduate student at Harvard noticed something peculiar while computing the orbits of a simple polynomial. Take *f(x) = x² + 1*, reduce it modulo a prime number like 7, and trace where each number goes: 0 → 1 → 2 → 5 → 5 → 5... The map eventually traps every starting point in a cycle. But the *pattern* of these cycles — how many there were, how long they lasted, how the non-cycling points funneled into them — seemed to carry a kind of signature. Change the polynomial slightly, and the signature changed. Conjugate the polynomial by a change of variables, and the signature stayed the same.

That student's observation languished as a curiosity for decades. Now, a new line of mathematical research is turning it into something far more powerful: a topological fingerprint that can distinguish algebraic dynamical systems with near-perfect accuracy, using nothing more than prime-by-prime arithmetic.

## The Problem of Disguise

Every polynomial or rational function *f(x)* defines a dynamical system — a rule for iterating: start with a number, apply the function, apply it again, and watch where the trajectory goes. Two such maps might look completely different on the surface but be secretly "the same" — related by a simple change of coordinates. Mathematicians call this being *conjugate*, and detecting it is surprisingly hard.

Why does it matter? Conjugacy is the fundamental equivalence relation in dynamics. Two conjugate maps have identical long-term behavior: the same periodic orbits, the same chaos, the same stability. In number theory, conjugacy classes of rational maps parametrize the moduli space of dynamical systems — the "landscape" of all possible dynamics. Understanding which maps are equivalent is central to arithmetic dynamics, a field that sits at the crossroads of number theory, algebraic geometry, and dynamical systems.

The classical approach to detecting conjugacy requires working over the algebraic closure of the rationals — an infinite, unwieldy extension field. You need to find an explicit change of variables witnessing the conjugacy, which amounts to solving polynomial systems of equations. For maps of high degree, this is computationally intractable.

## The Prime Lens

Here is the key insight: instead of trying to solve these equations directly, look at the map through the lens of prime numbers.

For any rational map *f(x)* and a prime *p*, you can reduce the map modulo *p*. The result is a function from the finite set {0, 1, ..., p} to itself — a map on the projective line over the field with *p* elements. This finite map creates a directed graph: each of the *p + 1* points has exactly one outgoing edge, pointing to its image.

This graph has a beautiful structure. Since the set is finite, every trajectory eventually enters a cycle. The non-cycling points form trees that "drain" into the cycles, like rivers flowing into lakes. The entire graph decomposes into connected components, each consisting of a cycle with trees hanging off it.

The crucial observation is that conjugate maps produce *isomorphic* graphs. If *f* and *g* are conjugate over the algebraic closure, then for all but finitely many primes, their mod-*p* graphs are the same up to relabeling. This means that any invariant extracted from the graph structure is automatically a conjugacy invariant.

## From Graphs to Topology

But which invariants should you extract? Counting fixed points and cycles gives you some information, but not enough to separate most non-conjugate maps. Counting preimage sizes — how many points map to each point — gives more, but still leaves ambiguities.

The new approach borrows a tool from an unexpected corner of mathematics: *persistent homology*, a technique from topological data analysis (TDA) that was originally developed to study the shape of data clouds in machine learning.

The idea is to build a *filtered complex* — a sequence of increasingly elaborate topological spaces — from the orbit-preimage structure of the graph. At the lowest level, you have just the points. At the next level, you connect points that share large preimage trees. At higher levels, you fill in triangles, tetrahedra, and higher-dimensional shapes based on the nesting of preimage structures.

As you move through the filtration, topological features — connected components, loops, voids — appear and disappear. The "birth" and "death" times of these features create a *persistence diagram*: a collection of intervals recording the lifespan of each topological feature.

This persistence diagram, computed prime by prime, is the *primewise persistence profile*. It encodes far richer information than simple orbit statistics, because topology captures global structural relationships that local counting misses.

## The Fundamental Counting Law

At the foundation of this theory lies an elegant counting identity. For any self-map of a finite set with *n* elements, the sum of all preimage sizes equals exactly *n*. This is almost tautological — every element has exactly one image, so summing "how many things map to *y*" over all *y* simply counts every element once.

But this simple identity has deep consequences. It means the preimage sizes form a *partition-like* structure: they are non-negative integers summing to a fixed value. The way this sum distributes across points — uniformly (for bijections) or concentrated (for maps with large fibers) — determines the topological complexity of the persistence profile.

The *orbit entropy*, a real-valued invariant that measures how unevenly the preimages are distributed, is always non-negative. This follows from Jensen's inequality applied to the logarithm function: the entropy is the gap between the logarithm of the average preimage size and the average of the logarithms. For bijections, the entropy is zero; for maps with highly concentrated preimage structure, it can be as large as log(*p* + 1).

## A Topological Invariant of Arithmetic

The deepest result in this new framework is the *conjugacy invariance of the degree sequence*. If two maps *f* and *g* are related by a coordinate change *φ* — so that *g(φ(x)) = φ(f(x))* for all *x* — then the multiset of preimage sizes is the same for both maps. The bijection *φ* simply permutes the points without changing the preimage structure, because it maps the fiber over *y* for *f* bijectively onto the fiber over *φ(y)* for *g*.

This invariance extends to the full persistence profile. The degree sequence determines the tail counts (how many points have preimage size exceeding each threshold), and these tail counts form the "persistence bars" of the zeroth filtration level. If two maps have different degree sequences, the persistence profiles must differ — providing a certificate of non-conjugacy.

The converse direction is the frontier: can persistence profiles *detect* conjugacy, not just refute it? The conjecture is that for maps satisfying a mild genericity condition (excluding a special class called Lattès maps, which arise from elliptic curves and have exceptionally symmetric dynamics), the persistence profile determines the conjugacy class up to density-one agreement across primes.

## Testing the Conjecture

The beauty of this conjecture is its testability. Take any family of rational maps — say, all quadratic polynomials *x² + c* for rational values of *c*. For each pair of maps and each prime *p* up to some bound, compute the mod-*p* graph, extract the persistence profile, and check whether non-conjugate maps are separated.

Computational experiments reveal a striking pattern. For quadratic maps, the degree sequence alone separates most non-conjugate pairs, and the full persistence profile handles nearly all of the rest. The only "collisions" — pairs of non-conjugate maps with identical persistence profiles — occur at finitely many primes, exactly as the conjecture predicts.

For cubic and higher-degree maps, the situation is richer. The preimage structure becomes more complex (points can have preimage size up to the degree), and the persistence profiles carry more information. But the separation phenomenon persists: distinct conjugacy classes produce distinct profiles, with only finitely many exceptional primes.

## Connections Across Mathematics

What makes this research particularly exciting is how it bridges disparate fields.

The *dynamics-to-topology* connection is the heart of the matter: topological data analysis, which was developed for applications in biology, neuroscience, and materials science, turns out to be precisely the right tool for studying a fundamental question in number theory.

The *entropy connection* links this work to information theory. The orbit entropy quantifies the "information content" of the preimage structure, connecting Claude Shannon's theory of communication to Silverman's theory of arithmetic dynamics. Maps with high entropy have complex preimage trees; maps with low entropy are close to bijections.

The *moduli space connection* promises applications to algebraic geometry. The space of all rational maps of degree *d*, modulo conjugacy, is a classical object of study. If the persistence profile indeed classifies conjugacy classes, it provides a new set of coordinates on this moduli space — coordinates that are directly computable from arithmetic data.

## The Road Ahead

Several tantalizing questions remain. Can the persistence profiles detect not just conjugacy but *near-conjugacy* — maps that are close to being conjugate in some metric? Can the framework extend to maps defined over number fields, or to higher-dimensional dynamics? And can the topological invariants illuminate the mysterious Lattès maps, whose exceptional symmetry makes them invisible to many other invariants?

Perhaps most intriguingly, this work suggests that the primes themselves carry a kind of "topological memory" of algebraic structure. Each prime gives you a crude snapshot of a dynamical system — a finite graph, a handful of cycles and trees. But the *ensemble* of all these snapshots, organized by the persistence filtration, remembers everything. It is as if the primes, collectively, are performing an infinite-dimensional topological computation, and we are only now learning to read the output.

The idea that prime numbers can serve as a topological microscope — revealing the hidden shape of algebraic dynamics through their collective arithmetic — is the kind of insight that reshapes how mathematicians think about the deep structure of numbers. It connects the oldest objects in mathematics (primes) to the newest tools (persistent homology) in service of one of the most fundamental questions: when are two mathematical systems secretly the same?

---

*This research establishes new connections between arithmetic dynamics, topological data analysis, and information theory, proving foundational theorems about orbit-preimage invariants of dynamical systems modulo primes.*
