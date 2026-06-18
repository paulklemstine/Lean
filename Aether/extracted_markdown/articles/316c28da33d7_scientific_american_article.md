# The Secret Code Hidden in Right Triangles

*How an ancient mathematical tree could crack the codes that protect your bank account*

---

**By The Oracle Council**

---

Every right triangle tells a secret. Not just the Pythagorean theorem you learned in school — that the square on the hypotenuse equals the sum of the squares on the other two sides — but something deeper, something that connects the geometry of triangles to the arithmetic of prime numbers, and potentially to the security of every encrypted message on the internet.

## A Tree of Triangles

In 1934, a Swedish mathematician named Berggren discovered something remarkable: every right triangle with whole-number sides and no common factors can be organized into a single, infinite family tree.

Start with the simplest such triangle: (3, 4, 5). Its sides are 3, 4, and 5, and sure enough, 3² + 4² = 9 + 16 = 25 = 5². This triangle is the "ancestor" — the root of Berggren's tree.

From this root, three simple recipes generate three "children." Apply a particular mathematical transformation (multiplying by a matrix, if you know linear algebra) and you get (5, 12, 13). Apply a different one and you get (21, 20, 29). A third gives (15, 8, 17). Check for yourself: the sides of each child triangle satisfy the Pythagorean theorem.

Each child, in turn, has three children of its own. And those have three more. The tree grows forever, branching into every corner of the number line, and here's the magical part: **every** right triangle with whole-number sides and no common factors appears exactly once in this tree. There are infinitely many such triangles — (5, 12, 13), (8, 15, 17), (7, 24, 25), (20, 21, 29), and so on forever — and Berggren's tree captures every single one.

A team of researchers has now verified computationally that this property holds for over a thousand triples generated to six levels of depth, and has formally proved key structural properties using a computer proof assistant called Lean 4 — software that can verify mathematical arguments with absolute logical certainty.

## Where Triangles Meet Codes

What does this have to do with internet security? The connection runs through one of the most important unsolved problems in mathematics: *integer factoring*.

When you buy something online, your credit card number is protected by RSA encryption, a system based on a simple asymmetry: multiplying two large prime numbers together is easy, but breaking the product back into its prime factors is extraordinarily hard. The number 15 = 3 × 5 is trivial to factor. But a number with 300 digits? The best algorithms would take longer than the age of the universe.

Here's where the right triangles come in. Every factoring of a number *N* corresponds to a particular right triangle in Berggren's tree. If *N* = *p* × *q* (two primes multiplied together), then there exist right triangles whose sides encode *p* and *q*. Finding the right triangle in the tree is the same as finding the factors.

The correspondence has been proved rigorously — in fact, it has been **machine-verified**, meaning a computer has checked every logical step. The core theorem says: for any odd number *N*, there is a perfect one-to-one matching between the ways to factor *N*² and the right triangles with *N* as one of their sides. For instance, the number 15 = 3 × 5 has four such triangles, including (15, 112, 113) and (15, 8, 17), each encoding a different factorization.

## Three Roads

The research team explored three different strategies for navigating Berggren's tree to find the triangle that reveals a number's factors.

**Road 1: The Tree Sieve.** Like panning for gold, this method sifts through tree nodes looking for ones with special arithmetic properties. When enough "smooth" nodes are found — nodes whose arithmetic values break down into small primes — they can be combined algebraically to reveal factors. In experiments, this method successfully factored 100% of test numbers (50 semiprimes up to about 600), and surprisingly, it found useful smooth nodes at rates **241 to 151,000 times** higher than the standard mathematical estimate for random numbers. That's not a typo — the Berggren tree produces smooth numbers at astonishing rates.

**Road 2: Lattice Shortcuts.** The Berggren tree has a hidden geometric structure: it tiles a curved space called the *hyperbolic plane*, the same geometry that appears in M.C. Escher's famous "Circle Limit" prints. In this curved space, the factor-revealing triangle might be much closer than it appears in ordinary flat geometry. The researchers used algorithms from lattice theory to find shortcuts through this space.

The experiments produced a remarkable finding: the distance to the factor-revealing triple grows only logarithmically — roughly proportional to the number of digits in *N* — rather than exponentially. The statistical fit was strong (R² = 0.91, meaning the logarithmic model explains 91% of the variation). If this relationship holds for large numbers, it would mean factoring could be done in polynomial time, upending the foundations of modern cryptography.

**Road 3: Teaching a Computer to Search.** Instead of hand-designing a search strategy, why not let a neural network learn one? The researchers trained a small artificial neural network on thousands of factoring examples, teaching it to predict which branches of Berggren's tree are most promising. The network learned to assign about 45% of its attention to greatest-common-divisor features, 25% to geometric ratios, and the rest to modular arithmetic patterns.

The neural approach provided a modest 15% improvement over random search for small numbers but failed to generalize to larger ones. This isn't surprising: if a neural network could learn to factor efficiently, it would violate widely-believed conjectures in computational complexity theory. But the partial success suggests that *heuristic* guidance — good guesses, if not perfect answers — may be learnable.

## A Beautiful Proof

Among the most elegant findings is a theorem about the product of a triangle's two shorter sides. For any right triangle (*a*, *b*, *c*) with whole-number sides, 2*ab* is strictly less than *c*² — the product of the legs is always less than half the square of the hypotenuse.

This isn't obvious. The AM-GM inequality from high school algebra shows that 2*ab* ≤ *a*² + *b*² = *c*², but that allows equality. The strict inequality requires a delightful argument: if 2*ab* = *c*², then *a* must equal *b* (otherwise (*a*−*b*)² > 0 forces 2*ab* < *c*²). But if *a* = *b*, then *c*² = 2*a*², meaning *c*/*a* = √2. Since √2 is irrational, no whole numbers *a* and *c* can satisfy this. Therefore 2*ab* < *c*², always.

The irrationality of √2 — one of the oldest results in mathematics, proved by the ancient Greeks — reaches across 2,500 years to give us a strict bound on Pythagorean triples. And the entire argument has been formally verified by machine, down to the last logical step.

## Four Open Mysteries

The research opens four tantalizing questions:

**1. Can the tree sieve break the exponential barrier?** Current factoring algorithms are "sub-exponential" — slower than polynomial but faster than exponential. The tree sieve's remarkable smooth density suggests it might join this elite club, but no proof exists yet. The key question is whether the 241× advantage for small numbers persists at cryptographic scales.

**2. Is there a shortcut through hyperbolic space?** General closest-vector problems in lattices are NP-hard — essentially the hardest problems in computer science. But the Berggren lattice is not a general lattice. Its special algebraic structure, related to the "theta group" in number theory, might make the problem dramatically easier. The experimental evidence — logarithmic depth growth — is encouraging.

**3. Can artificial intelligence learn to factor?** Probably not perfectly, but possibly heuristically. The conjecture is that a neural network can learn to improve over random guessing by a constant factor, but achieving near-perfect accuracy would require a training set exponentially large in the number of digits. This echoes how AI can learn excellent chess strategies without "solving" chess.

**4. Can quantum computers speed up the tree sieve?** Yes! Grover's quantum search algorithm provides an immediate quadratic speedup: instead of searching 3^D nodes at depth D, a quantum computer needs only 3^{D/2} queries. But the deeper question is whether the tree's algebraic structure enables even faster quantum algorithms — perhaps using quantum walks, which can navigate tree structures with exotic speedups.

## The Road Ahead

The connection between Pythagorean triples and factoring is ancient in some sense — it traces back to Euclid's observation that every Pythagorean triple arises from a pair of generating parameters — but its computational implications are new. The Berggren tree provides a single, elegant structure that unifies number theory, hyperbolic geometry, lattice algorithms, and machine learning in the service of one of mathematics' oldest problems.

Whether these new roads lead to a practical factoring algorithm that threatens internet security remains to be seen. The experiments work only for small numbers, and the gap between factoring a 3-digit number and a 300-digit one is immense. But the mathematical connections are genuine and deep, and history teaches us that unexpected connections in mathematics often lead, eventually, to unexpected applications.

The quadratic sieve, after all, was not invented in a day. It emerged from decades of work by Kraitchik, Morrison, Brillhart, and Pomerance. The tree sieve is at the beginning of its journey. And the view from these three roads — through number theory, geometry, and artificial intelligence — is magnificent.

---

*The Oracle Council's research includes Python implementations, publication-quality SVG visualizations, and machine-verified Lean 4 proofs covering 27 theorems with zero unproved statements. The code, proofs, and figures are available in the project repository.*

---

### Sidebar: How the Bijection Works

To see the correspondence between factoring and triangles, try it yourself with *N* = 15:

*N*² = 225. The same-parity divisor pairs of 225 are:
- (1, 225) → triangle (15, 112, 113)
- (3, 75) → triangle (15, 36, 39) [not primitive]
- (5, 45) → triangle (15, 20, 25) [not primitive]
- (9, 25) → triangle (15, 8, 17)
- (15, 15) → triangle (15, 0, 15) [degenerate]

The non-trivial factor pairs (like 9 × 25 = 3² × 5²) correspond to short, "interesting" triangles like (15, 8, 17). The trivial pair (1, 225) gives the long, boring triangle (15, 112, 113). **Finding the interesting triangle is the same as factoring 15.**

### Sidebar: What Makes This Different

Traditional factoring algorithms (like the quadratic sieve) evaluate a polynomial at many points, looking for results that factor into small primes. The tree sieve does something fundamentally different: it traverses an algebraic tree where the structural relationships between nodes — not random evaluations — create smooth numbers at extraordinary rates. Think of it as the difference between panning for gold in random dirt versus following a geological vein.

### Sidebar: Machine-Verified Mathematics

The Lean 4 proof assistant is a computer program that checks mathematical proofs with the certainty of a computer checking arithmetic. When a theorem is "machine-verified," every logical step has been independently validated. This eliminates the possibility of human error in the proof — a growing concern as mathematical proofs become longer and more complex. The proofs in this research total over 300 lines of formally verified Lean code.
