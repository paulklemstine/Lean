# Can You Hear the Factors of a Number?

## How mathematicians are using the geometry of shortest paths to decode hidden arithmetic

---

In 1966, the Polish-American mathematician Mark Kac posed a question so simple and beautiful that it has haunted mathematicians ever since: "Can one hear the shape of a drum?" If you strike a drum and listen to the frequencies it produces, can you deduce the drum's exact shape? The answer, it turned out, was no—but the question launched an entire field of *spectral geometry*, the art of recovering hidden structure from observable signals.

Now, a new line of research is asking an even more provocative question: **Can you hear the factors of a number?**

The idea sounds absurd at first. Factoring a number—breaking 15 into 3 × 5, or 91 into 7 × 13—seems like a purely arithmetic problem, having nothing to do with geometry or signals. And yet a growing body of mathematical work is revealing deep, surprising connections between the geometry of shortest paths on networks, the arithmetic of ancient number patterns, and the problem of reconstructing hidden information from limited observations.

---

## The Shortest-Path Universe

To understand this connection, imagine a network of cities connected by roads of various lengths. A traveler at one city wants to reach another. Naturally, she takes the shortest route. This minimum-cost path problem is one of the oldest and most fundamental in all of mathematics and computer science.

Now imagine something stranger: instead of a single traveler, imagine that every city simultaneously emits a signal. Each signal travels outward along all available paths, but only the *earliest arrival*—the signal that took the shortest path—is recorded at each observation point. This is exactly how gravitational lensing works in astrophysics: light from a distant galaxy bends around a massive object, taking multiple paths to reach us, and what we observe is determined by the fastest arrivals.

Mathematicians call this a **min-plus** or **tropical** system. The word "tropical" is a playful tribute to the Brazilian mathematician Imre Simon, who pioneered this kind of algebra in the 1960s. In tropical mathematics, you replace ordinary addition with taking the minimum, and ordinary multiplication with addition. It sounds like a bizarre parlor trick, but it turns out to be extraordinarily powerful.

The key property of tropical systems is that they compress information. A network might have millions of paths between two points, but the observer only sees the shortest one. The question becomes: **from these compressed observations, can you reconstruct what's hidden inside the network?**

---

## Ancient Triangles, Modern Trees

Enter the Pythagorean triple—one of the oldest objects in mathematics. The Babylonians knew that 3² + 4² = 5², and schoolchildren still learn that certain right triangles have whole-number sides. What's less well known is that *every* primitive Pythagorean triple (one where the three numbers share no common factor) can be generated from the triple (3, 4, 5) by repeatedly applying three specific transformations.

These transformations, discovered by the Danish mathematician Berggren in 1934, create an infinite tree. Starting from (3, 4, 5), each triple branches into exactly three children:

- (3, 4, 5) → (5, 12, 13), (21, 20, 29), (15, 8, 17)

Each of those branches into three more, and so on forever. Every primitive Pythagorean triple appears exactly once in this tree. It's a complete catalog of right-triangle arithmetic, organized into a perfect ternary branching structure.

The new insight is to treat this tree as a **network for signal propagation**. Assign each triple a "weight" based on its arithmetic properties—say, the length of one of its legs. Define the "cost" of traveling between two triples as a function of how far apart they sit in the tree. Then let signals propagate through this network according to tropical (shortest-path) rules.

What emerges is a tropical lens system: arithmetic data encoded as signal weights, geometric structure encoded as propagation costs, and a set of observers recording the earliest arrivals.

---

## The Reconstruction Miracle

Here is where things get remarkable. The central mathematical result is a **reconstruction theorem**: under certain conditions, the observations at the boundary of the network *uniquely determine* the hidden arithmetic data inside it.

More precisely, suppose you have a finite piece of the Berggren tree, equipped with tropical signal propagation. You place observers at certain nodes. Each observer records a single number: the minimum arrival time of all signals passing through it. The theorem states that if the observers are placed well enough—a condition called "delay separation"—then the observed arrival times completely determine the source weights, up to a natural equivalence.

This is the tropical version of a profound principle from physics and engineering: **inverse problems can be solved from boundary data**. Just as seismologists reconstruct the Earth's interior from earthquake arrival times, and medical imaging reconstructs tissue density from X-ray attenuation, the tropical lens theorem reconstructs arithmetic structure from shortest-path observations.

What makes this more than a curiosity is the *minimality* result that accompanies it. Not only can you reconstruct the source, but you can do so with a *minimal* model—one using the fewest possible internal states. This is the tropical analogue of the Myhill–Nerode theorem from automata theory, which characterizes the smallest machine that can recognize a given pattern. The result shows that the Berggren tree admits a finite-state compression under tropical observation: hidden number-theoretic structure is recoverable from a finite observer algebra.

---

## Factoring Through Geometry

The most surprising application connects this framework to **integer factoring**—the problem at the heart of modern cryptography.

Consider a semiprime: a number that is the product of exactly two primes, like 15 = 3 × 5 or 8633 = 89 × 97. Factoring large semiprimes is believed to be extraordinarily difficult, and this difficulty is what secures internet communications worldwide.

The new framework shows that semiprime factoring can be *reinterpreted* as a tropical inverse problem. Encode the two factors as source weights at two nodes of a tropical lens system. The delay profile—the pattern of shortest-path arrival times observed at boundary nodes—carries a fingerprint of the factor data. Under the right separation conditions, this fingerprint is unique: different factor pairs produce different delay profiles.

This doesn't break cryptography—the separation conditions are themselves hard to verify for large numbers. But it provides a fundamentally new *conceptual framework* for factoring: not as an algebraic or number-theoretic problem, but as a geometric inverse problem. The factors are hidden inside a network, and the challenge is to design observations that reveal them.

---

## The Bigger Picture

What's truly exciting about this work is the *bridge* it builds between seemingly unrelated mathematical worlds.

**Tropical geometry** studies the mathematics of minimum and addition—the algebra of shortest paths, optimization, and resource allocation. **Inverse problems** ask how to reconstruct hidden causes from observed effects—the mathematics of medical imaging, seismology, and remote sensing. **Arithmetic dynamics** studies how number-theoretic structures evolve under iteration—the mathematics of the Berggren tree and its cousins.

Each of these fields is mature and powerful on its own. But the tropical lens framework reveals that they are, in a precise mathematical sense, *the same thing looked at from different angles*. A reconstruction theorem in tropical geometry *is* an inverse problem for shortest-path networks *is* a compression theorem for arithmetic state spaces.

This kind of unification is rare and valuable. When seemingly different mathematical theories turn out to be shadows of the same underlying structure, the results from each field become available to all the others. Techniques from seismic imaging might illuminate number theory. Ideas from automata theory might solve optimization problems. The bridge, once built, carries traffic in all directions.

---

## What Comes Next

Several tantalizing directions emerge from this work.

**Tropical tomography** asks: if you can reconstruct a single source from boundary data, can you reconstruct *multiple* sources simultaneously? This is the mathematical analogue of multi-earthquake seismology, where dozens of earthquakes illuminate the Earth's interior from different angles.

**Arithmetic sensing** asks: what is the minimum number of observations needed to reconstruct factor data of a given size? This connects tropical geometry to information theory and computational complexity.

**Cosheaf cohomology** asks: can the obstruction to reconstruction—the reasons why some inverse problems fail—be captured by a topological invariant? This would bring the full power of algebraic topology to bear on arithmetic inverse problems.

And perhaps most intriguingly, **tropical Myhill–Nerode theory** asks: what is the smallest tropical automaton that captures the delay behavior of an arithmetic tree? This would extend the classical theory of minimal automata from finite-state machines to tropical (min-plus) state spaces, creating a new bridge between formal language theory and arithmetic geometry.

The question "Can you hear the factors of a number?" may not yet have a complete answer. But for the first time, mathematicians have the tools to ask it precisely—and the early results suggest that the answer, in the right geometric setting, is yes.
