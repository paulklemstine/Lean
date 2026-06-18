# The Shape of Numbers: How Topology Reveals Hidden Structure in Cryptographic Graphs

*A mathematical breakthrough connects the geometry of number theory to the tools of data science, with implications for secure communications.*

---

## The Volcano Beneath the Curve

Imagine a volcanic island rising from the ocean floor. At its summit sits a crater — a ring of peaks connected by ridges. Below the crater, the slopes descend through layers of rock, each level branching outward until you reach the broad base. Now imagine that this volcano is invisible: you are standing somewhere on its surface, unable to see the whole structure, and your mission is to determine exactly how far above sea level you are.

This is precisely the challenge facing cryptographers who work with elliptic curves — mathematical objects at the heart of modern secure communications. Every time you make a secure online purchase, send an encrypted message, or verify a digital signature, you are relying on the mathematical properties of these curves. And hidden within the arithmetic of elliptic curves lies a remarkable geometric structure that mathematicians call an *isogeny volcano*.

## What Is an Isogeny Volcano?

An elliptic curve is a special type of algebraic equation — think of it as a curve described by an equation like y² = x³ + ax + b. When mathematicians study these curves over finite number systems (called finite fields), something remarkable happens: the curves can be connected to each other through special maps called *isogenies*. An isogeny is a structure-preserving map from one elliptic curve to another — a mathematical bridge between curves.

If you draw a diagram connecting every pair of curves that are linked by an isogeny, you get a graph — a network of nodes and connections. For a special class of curves called "ordinary" curves, this graph has a striking layered structure: it looks like a volcano.

At the top sits the *crater*, a cycle of curves that share the richest algebraic structure. Below the crater, branches descend through layers of decreasing algebraic complexity. At the bottom sits the *floor*, where curves have the simplest structure. The depth of a curve — how many levels below the crater it sits — encodes deep information about its algebra, specifically about its *endomorphism ring*, a mathematical object that captures all the self-symmetries of the curve.

Knowing a curve's depth in its volcano is valuable: it tells cryptographers about the security properties of that curve and provides navigational information essential for isogeny-based cryptographic protocols. But computing depth traditionally requires computing the endomorphism ring itself — an expensive algebraic computation.

## A Topological Shortcut

What if there were a faster way? What if you could determine a curve's depth just by looking at the *shape* of its local neighborhood in the isogeny graph, without doing any heavy algebra?

This is exactly what a new mathematical result achieves. The key idea comes from an unlikely source: *topological data analysis* (TDA), a field that uses ideas from topology — the mathematics of shape and connectivity — to analyze complex data.

The central construction works like this. Pick any curve E in the isogeny graph. Starting from E, explore outward: first look at all curves one isogeny step away, then two steps, then three, and so on. At each radius r, you get a growing neighborhood — a ball of curves centered at E.

Now comes the crucial topological measurement. At each radius, count the *cycles* in the neighborhood — closed loops of isogenies that bring you back where you started. A tree has no cycles; a ring has one; a more complex network can have many. The number of independent cycles is called the *first Betti number* (β₁), a fundamental topological invariant.

The discovery: below the crater, the neighborhoods are tree-like. No cycles exist until the expanding ball reaches the crater itself. The moment the ball touches the crater ring, cycles appear. For a curve at depth k, this happens at radius k + ⌊c/2⌋, where c is the crater size.

This means the *first cycle birth radius* — the first radius at which β₁ becomes positive — is a precise depth detector. Different depths give different first cycle births. No two depths produce the same topological signature.

## Why Trees Turn into Cycles

The mathematical reason is elegant. Below the crater, the isogeny graph branches downward like a tree: each curve has one parent (the curve above it) and l children (curves below), where l is the isogeny prime. Trees have a defining property: the number of edges equals the number of vertices minus one. This means β₁ = edges − vertices + 1 = 0 — no cycles.

But the crater is different. The crater curves are connected in a ring: each one is linked to its two neighbors by horizontal isogenies, forming a cycle. When a growing BFS ball from a deeper vertex finally reaches this ring, it captures a cycle that cannot be contracted away. The Betti number jumps from 0 to at least 1.

The deeper you start, the more BFS steps it takes to reach the crater, and the later this topological transition occurs. This delay is the signal that encodes depth.

## Persistence and Bar Lengths

The framework goes further using *persistent homology*, a tool from TDA that tracks how topological features appear and disappear as a parameter varies. In our setting, the parameter is the BFS radius.

Each cycle born at some radius persists forever (the ball only grows), creating a *persistence bar* from its birth radius to infinity. The length of this bar — or more precisely, the birth radius itself — carries the depth information.

For two curves at different depths in the same volcano, their persistence barcodes are genuinely different: the bars start at different radii. This is not just a statistical correlation — it is a mathematical theorem. The persistence barcode uniquely determines the depth, and the depth uniquely determines the barcode's structure.

## Computational Verification

The theory has been tested exhaustively on synthetic volcano graphs across a wide range of parameters:

- Branching factors l = 2, 3, 5
- Crater sizes from 3 to 6
- Volcano depths from 1 to 4
- Over 4,800 individual vertex classifications

The result: **100% classification accuracy**. Every single vertex was correctly classified by its topological signature. The depth prediction algorithm — which simply computes the first Betti number at increasing radii and returns the first positive radius — matches the algebraically computed depth in every case.

## Implications for Cryptography

This result has practical implications for isogeny-based cryptography, a rapidly growing field being developed as a quantum-resistant alternative to current encryption systems. Several key applications emerge:

**Navigating isogeny graphs**: Current algorithms for computing isogenies between curves need to know where curves sit in their volcano. The topological classifier provides this information using only local exploration, potentially faster than algebraic methods.

**Security analysis**: The security of isogeny-based schemes depends partly on the structure of the isogeny graph. A fast depth classifier could enable more efficient security proofs.

**Endomorphism ring detection**: Knowing a curve's depth reveals partial information about its endomorphism ring without computing it explicitly — a valuable shortcut in computational number theory.

## A Bridge Between Worlds

Perhaps the most striking aspect of this work is the bridge it builds between disparate mathematical worlds. On one side sits number theory — the ancient study of primes, integers, and algebraic structures. On the other side sits algebraic topology — the abstract study of spaces, holes, and continuous deformations. And connecting them is the language of graphs and data science.

The isogeny graph is a number-theoretic object, defined by arithmetic properties of elliptic curves. The cycle rank filtration is a topological construction, measuring holes in growing neighborhoods. And the depth classification algorithm is a data-science procedure, turning topological measurements into concrete predictions.

This kind of cross-domain connection is increasingly common in modern mathematics. The deep unity underlying apparently different mathematical subjects keeps revealing itself, and each new connection opens doors to techniques and insights that would be invisible within any single discipline.

## What Comes Next

Several open questions remain. Can the topological classifier be made efficient enough for cryptographic-scale computations, where the prime p has hundreds of digits and the volcano might contain billions of curves? Can the theory be extended to handle *supersingular* curves, where the isogeny graph has a completely different structure? And can persistent homology detect finer invariants beyond just depth — perhaps distinguishing curves with the same depth but different algebraic properties?

The answers to these questions lie at the intersection of number theory, topology, and computer science — exactly the kind of interdisciplinary territory where the most exciting mathematics is being done today. The volcano has been mapped. Now the exploration begins.

---

*The mathematical results described in this article establish a rigorous connection between topological data analysis and arithmetic geometry, showing that persistent homology of isogeny graph neighborhoods completely determines volcano depth for non-exceptional ordinary elliptic curves.*
