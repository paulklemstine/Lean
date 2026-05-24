# When Numbers Resist Mixing: How Factorization Creates Hidden Bottlenecks

## The Locked Room Problem

Imagine a crowded ballroom where dancers move according to a single rule: at each beat, every dancer squares their position number, takes the remainder when divided by the room's capacity, and moves to that new spot. In a room with a prime number of seats — say, 7 — the dancers swirl and intermix with surprising freedom. But when the room has a composite number of seats — say, 15 — something strange happens. Invisible walls appear. Certain groups of dancers become trapped in separated regions, unable to reach each other no matter how many beats pass.

This is not just a party trick. It is a deep mathematical phenomenon that connects three seemingly unrelated fields: number theory, the science of dynamical systems, and the theory of networks. And a new theorem now explains exactly *why* those invisible walls appear, and how strong they are.

## Squaring Your Way Through a Number System

The mathematical operation at the heart of this discovery is deceptively simple. Take any number, square it, and keep only the remainder after division by some fixed modulus *n*. Start with 3 in arithmetic modulo 7: you get 3² = 9, and 9 mod 7 = 2. Then 2² = 4. Then 4² = 16 mod 7 = 2. You've entered a loop: 2 → 4 → 2 → 4 → ...

This "squaring map" creates a complete dynamical system — a rule that tells you exactly where every number goes, step after step. Mathematicians have studied these systems for decades, partly because they underpin crucial applications in cryptography (the RSA and Rabin encryption schemes rely on squaring modulo large composite numbers) and partly because they exhibit beautiful internal structure.

The key structural feature: every number, when you square it repeatedly, eventually reaches a "fixed point" — a number that squares to itself. These self-squaring numbers are called *idempotents*. In a prime modulus, there are only two: 0 and 1. But in a composite modulus like 15 (which equals 3 × 5), there are four: 0, 1, 6, and 10. The extra idempotents are signatures of compositeness — they exist precisely because the modulus can be factored.

## The Geography of Attraction

Each idempotent acts like a gravitational attractor, drawing nearby numbers toward it through repeated squaring. The set of all numbers that eventually reach a given idempotent is called its *basin of attraction*. And here is the crucial fact: **basins of distinct idempotents never overlap**. Every number belongs to exactly one basin, and once it enters that basin's territory, it can never escape.

This creates a partition of the number system into disconnected islands. In modulus 15, the numbers 0 through 14 split into four basins — four separate continents in a world of 15 locations. Each continent is dynamically isolated from the others.

But isolation alone isn't the full story. The real question is quantitative: *How hard is it for the dynamics to move material across basin boundaries?* This is where the concept of *conductance* enters — a measure borrowed from the physics of heat flow and electrical circuits, adapted to the discrete world of modular arithmetic.

## Measuring the Resistance

The conductance of a subset in a dynamical system measures how much of the subset's contents "leak out" in a single step. Imagine coloring all the numbers in a subset red. After one application of the squaring map, some red numbers may land outside the subset — they've crossed the boundary. The conductance is the fraction that escapes: boundary size divided by total size.

A subset with zero conductance is completely closed — nothing escapes. A subset with conductance 1 has everything escaping. The *basin conductance* of the entire system is the minimum conductance over all possible nontrivial subsets. It captures the worst bottleneck: the narrowest passage through which the dynamics must flow.

In graph theory and probability, this quantity is known as the *Cheeger constant* or *isoperimetric number*. It governs how quickly a random walk mixes, how fast information spreads, and how robustly a network stays connected. A high Cheeger constant means good mixing; a low one means the system has hidden barriers.

## The Product Bottleneck Theorem

The new result — the CRT Product Bottleneck Theorem — reveals a precise law governing how these barriers behave under factorization.

The Chinese Remainder Theorem (CRT) is one of the oldest results in number theory, dating to the third century. It states that when two moduli *a* and *b* share no common factor, the arithmetic of the product *ab* is equivalent to doing arithmetic in *a* and *b* simultaneously. It's like having two independent dials: knowing the remainder mod *a* and the remainder mod *b* tells you everything about the remainder mod *ab*.

The Product Bottleneck Theorem adds a dynamic dimension to this algebraic fact. It proves:

> **When *n* = *a* × *b* with *a* and *b* coprime, the basin conductance of the squaring system modulo *n* is at most the smaller of the basin conductances modulo *a* and modulo *b*.**

In symbols: *h(ab) ≤ min(h(a), h(b))*.

This means factorization can only make things worse. The product system inherits the worst bottleneck from either factor. If squaring mod 5 has a narrow passage, then squaring mod 15 (= 3 × 5) has a passage at least that narrow. And if squaring mod 3 has an even narrower one, the product inherits *that* constraint instead.

## How the Proof Works

The proof mechanism is elegant. Given a sparse cut in the factor system — say, a subset *S* of numbers modulo *a* with small conductance — the theorem constructs a corresponding cut in the product system by "lifting" it through the CRT decomposition.

The lift works like this: take every number modulo *ab* whose first CRT coordinate falls in *S*. Algebraically, this means taking the full preimage of *S* under the natural projection from integers mod *ab* to integers mod *a*. If *S* has 2 elements out of 5 (in mod 5), the lifted set has 2 × 3 = 6 elements out of 15 (in mod 15). Each element of *S* spawns a "fiber" of *b* copies.

The key insight is that squaring commutes with CRT decomposition. When you square a number mod *ab* and look at its CRT coordinates, you see the squares of the individual coordinates. This means a boundary element in the factor (one whose square lands outside *S*) lifts to boundary elements in the product, and an interior element lifts to interior elements. The boundary-to-volume ratio — the conductance — is preserved exactly.

Since the product system contains this lifted cut with the same conductance as the original, its minimum conductance (over all possible cuts) can be no larger.

## Why This Matters

### For Cryptography

RSA encryption relies on the difficulty of factoring large semi-primes *n* = *pq*. The squaring map modulo *n* is the engine of the Rabin cryptosystem and closely related to RSA decryption. The bottleneck theorem quantifies a long-suspected structural weakness: the dynamics of squaring in the composite system are fundamentally constrained by the factor systems. This doesn't break RSA — the bottleneck is a feature of the mathematical structure, not an attack vector — but it deepens our understanding of *why* composite moduli behave differently from prime ones.

### For Dynamical Systems

The theorem establishes that a product of deterministic systems inherits the slowest mixing component. This is analogous to a principle well-known in statistical mechanics: a composite physical system equilibrates at the rate of its slowest subsystem. But here the principle is proved rigorously for a purely arithmetic dynamical system, without any randomness or thermodynamic assumptions.

### For Graph Theory

The squaring map defines a functional graph on a finite set of vertices. The bottleneck theorem is a Cheeger-type inequality for the product of such graphs via CRT. This opens a new family of structured graphs — arithmetic dynamical graphs — for study with spectral and combinatorial methods.

## An Unexpected Unity

Perhaps the most striking aspect of this result is the bridge it builds between disciplines that rarely speak to each other. Number theorists think about factorization, divisibility, and the Chinese Remainder Theorem. Dynamicists think about orbits, attractors, and basins. Graph theorists think about cuts, expansion, and spectral gaps.

The bottleneck theorem shows these are all faces of the same phenomenon. Factoring a number doesn't just decompose a ring algebraically — it imposes geometric constraints on dynamical landscapes. It creates walls. It blocks mixing. It forces the system into isolated chambers that mirror the arithmetic structure of the modulus.

When Sunzi wrote about the Chinese Remainder Theorem seventeen centuries ago, he could not have imagined that his result about simultaneous remainders would one day explain why certain dynamical systems refuse to mix. Mathematics has a way of revealing connections across centuries and across fields, and the arithmetic product bottleneck theorem is a vivid example of that enduring power.

## Looking Forward

The theorem as proved gives an inequality: *h(ab) ≤ min(h(a), h(b))*. Computational experiments suggest something stronger might be true — that equality holds exactly in many cases, making the conductance of the product precisely the minimum of the factors. Proving (or disproving) this exact equality is an open question.

Beyond squaring, one can ask: does the same bottleneck principle apply to other polynomial maps, like cubing or higher powers? What about non-polynomial dynamical systems on modular arithmetic? Each of these questions opens a new chapter in what might be called *arithmetic expansion theory* — the study of how number-theoretic structure constrains dynamical mixing in finite systems.

The tools are now in place. The next discoveries await.
