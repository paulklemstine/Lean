# When Sameness Becomes Arithmetic: The Discovery of Tropical Identity

## A new mathematical framework turns one of the deepest questions in mathematics — "when are two things the same?" — into a problem a computer can solve in a blink

---

What does it mean for two things to be equal?

The question sounds almost absurd — the kind of thing a philosopher might mumble over wine at three in the morning. But for mathematicians, it is deadly serious. Over the past two decades, a revolution called *homotopy type theory* has shown that equality is far stranger and richer than anyone imagined. In this framework, saying "A equals B" is not a simple yes-or-no proposition. It's a *space* — a landscape of paths connecting A to B, paths between those paths, and so on, spiraling upward into infinite dimensions of sameness.

The theory is beautiful. It is also, for the most part, computationally intractable. You cannot, in general, write a program that decides whether two objects in this framework are "the same." The richness that makes it profound also makes it unwieldy.

Until now.

A new body of work has found a way to compress this infinite tower of identity into something flat, finite, and fully computable — by passing it through the lens of *tropical mathematics*, a strange and powerful branch of algebra where addition is replaced by "take the minimum" and multiplication is replaced by ordinary addition. The result is the first rigorously verified *tropical shadow of homotopy type theory*: a world where identity, equivalence, and even a version of the celebrated Univalence Axiom become questions that a machine can answer definitively.

## The Geography of Distance

To understand the breakthrough, forget abstract mathematics for a moment and think about cities.

Imagine you have a map of five cities, and you know the driving distance between every pair. Now imagine someone hands you a second map — same number of cities, same distances between them, but the cities have been renamed. Are these the same network, or different?

This is, at heart, a question about *identity*. Two networks are "the same" if you can relabel the cities in one to perfectly match the other — preserving every single distance. Mathematicians call such a relabeling an *isometry*, and the question of whether one exists is a version of the famous *graph isomorphism problem*, one of the great unsolved puzzles in computer science.

What makes the tropical approach special is that it rephrases this question in terms of *profiles*. Every city has a distance profile — the list of its distances to every other city. Two cities are *tropically indiscernible* if their profiles are identical. They interact with the rest of the network in exactly the same way; from the perspective of distance, they are clones.

This notion — indiscernibility through profiles — turns out to be the tropical shadow of the "paths" in homotopy type theory. And it has a beautiful property: it is an *equivalence relation*. It is reflexive (every city matches itself), symmetric (if A looks like B, then B looks like A), and transitive (if A matches B and B matches C, then A matches C). These are the three pillars that any notion of sameness must satisfy, and the tropical version delivers them perfectly.

## The Univalence Principle, Tropicalized

In 2006, the mathematician Vladimir Voevodsky proposed the *Univalence Axiom*, perhaps the most audacious idea in the foundations of mathematics since Gödel. In simplified terms, it says: *two types are equal if and only if they are equivalent* — if there's a structure-preserving correspondence between them, then they literally *are* the same thing.

This axiom transformed how mathematicians think about identity in abstract settings. But its full force operates in spaces of paths and higher paths — an infinitely layered topological soup that resists computation.

The tropical version collapses all of that into a single, crisp theorem:

> *Two finite weighted spaces have the same canonical code if and only if there exists a distance-preserving bijection between them.*

The "canonical code" is simply the collection of all matrices you can produce by relabeling the points. Two spaces share a code precisely when some relabeling transforms one into the other. This is univalence, stripped to its combinatorial skeleton — and it is *decidable*. For any pair of finite weighted spaces, a computer can check all possible relabelings and determine, with certainty, whether the spaces are the same.

This is not a metaphor or an analogy. It is a precise mathematical theorem, verified down to its logical atoms by a computer proof assistant — meaning no gap in reasoning, no hidden assumption, no hand-waving.

## The Algebra of Shortest Paths

The word "tropical" may seem whimsical, but it names a specific and increasingly important algebraic structure. In tropical mathematics, the operation `min` replaces addition, and ordinary addition replaces multiplication. This might seem like a mathematical party trick, but it turns out to describe the algebra of *shortest paths*.

When you navigate a road network, the cost of a route is the *sum* of edge weights (ordinary addition = tropical multiplication), and when you choose among routes, you pick the *cheapest* one (minimum = tropical addition). The entire theory of shortest-path algorithms — from GPS navigation to internet routing — is, secretly, tropical algebra.

A key identity in this world is the *tropical distribution law*:

> min(a + c, b + c) = min(a, b) + c

In plain language: if two routes both end with the same final leg, the cheapest total route is the one with the cheapest initial segment. This identity, seemingly obvious, is the engine that makes tropical canonical forms work. It governs how distances behave when you glue two networks together at a shared point — a construction that mirrors the "higher inductive types" of homotopy type theory, where new spaces are built by attaching cells.

## Why This Matters Beyond Pure Mathematics

The fusion of tropical algebra with identity theory opens doors in multiple directions.

**Network science.** In any system modeled as a weighted graph — transportation networks, social networks, neural circuits — the question "are these two networks structurally the same?" is fundamental. Tropical canonical codes provide a complete fingerprint for answering it.

**Evolutionary biology.** Phylogenetic trees, which represent the evolutionary relationships among species, are naturally tropical objects. The distances between species in a phylogenetic tree satisfy tropical inequalities. The tropical identity framework can determine when two trees represent the same evolutionary history, even when the species have been differently labeled. It can also identify *redundant taxa* — species that are tropically indiscernible, meaning they occupy identical positions in the evolutionary metric.

**Software verification.** When two software modules should behave identically — producing the same outputs with the same costs — tropical equivalence provides a decidable criterion for checking this. Each module's state space becomes a weighted graph, and tropical univalence determines whether the modules are interchangeable.

**Data science.** Distance matrices are the starting point for clustering, dimensionality reduction, and topological data analysis. Understanding when two distance matrices are "essentially the same" (up to relabeling) is crucial for robust analysis. The canonical code provides an invariant that is both complete and computable.

## Building the Framework

Constructing this theory required solving several interlocking problems.

First, the researchers had to prove that tropical indiscernibility — the condition that two points have identical distance profiles — genuinely behaves like an identity relation. This meant establishing reflexivity, symmetry, and transitivity rigorously, and showing that when a space satisfies a *separation axiom* (no two distinct points are indiscernible), tropical identity coincides with actual equality.

Second, they needed the permutation algebra of distance matrices: that applying the identity permutation leaves a matrix unchanged, that composing permutations works correctly, and that permutations preserve the structural properties of distance matrices (symmetry, zero diagonal).

Third, and most substantially, they proved the orbit-code classification theorem — the tropical univalence principle. This required showing that the set of matrices reachable by permutation (the "orbit") is the same for two matrices if and only if they are related by a distance-preserving permutation. The forward direction (isometry implies same orbit) follows from the group structure of permutations. The reverse direction (same orbit implies isometry) requires extracting a witnessing permutation from the orbit membership, using inverse permutations and the algebraic properties established earlier.

Finally, they established decidability: because the permutation group of a finite set is finite, the existence of a distance-preserving permutation can be checked by exhaustive search. This makes tropical univalence not just a theoretical principle but a *computational* one.

## The Tropical Distribution Law: A Small Identity with Large Consequences

One theorem deserves special mention for its simplicity and power:

> min(a + c, b + c) = min(a, b) + c

This identity governs the *gluing* construction — how distances behave when two weighted spaces are joined at a shared point. In the glued space, the distance between a point in the first space and a point in the second passes through the attachment point. The distribution law ensures that choosing the cheapest route through the junction decomposes neatly into choosing the cheapest initial leg.

This is the tropical shadow of a *higher inductive type* — a central concept in homotopy type theory where new topological spaces are built by attaching cells. The distribution law ensures that the tropical canonical code of a glued space depends only on the codes of the constituent spaces and the attachment points, just as the homotopy type of a pushout depends only on the homotopy types of its components.

## What Comes Next

This work opens a new field: *tropical synthetic homotopy*. Several directions beckon:

- **Tropical truncation levels.** In homotopy type theory, spaces are classified by how complicated their path structure is: sets (no nontrivial paths), groupoids (paths but no paths between paths), and so on. Tropical analogues of these truncation levels would classify weighted spaces by the complexity of their automorphism groups.

- **Tropical fundamental groupoids.** The symmetry group of a weighted space — its automorphisms — is the tropical shadow of the fundamental groupoid in topology. Developing this parallel could connect combinatorial optimization with algebraic topology.

- **Tropical sheaves.** If identity data can be defined locally (on subspaces) and then assembled globally, the result would be a tropical sheaf theory — connecting type theory with the geometry of networks and data.

- **Computational complexity.** The naive decision procedure checks all n! permutations, which is exponentially slow. Can tropical canonical codes be computed efficiently? This question connects directly to the graph isomorphism problem, one of the deepest questions in computational complexity.

## A New Lens on Sameness

For centuries, mathematicians treated equality as the simplest concept in their toolkit. Homotopy type theory revealed it to be shockingly deep. The tropical shadow shows that much of that depth can be captured by the humblest of operations — minimum and addition — applied to finite tables of numbers.

The result is a framework where the most profound question in the foundations of mathematics — *when are two things the same?* — becomes a question that a computer can answer with certainty, for a rich and practically important class of structures. It is a bridge between the philosophical heights of type theory and the computational bedrock of optimization, built from the simplest possible materials.

Sometimes the deepest insights come not from climbing higher, but from finding the right shadow on the ground.
