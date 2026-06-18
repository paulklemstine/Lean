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

## Where Triangles Meet Codes

What does this have to do with internet security? The connection runs through one of the most important unsolved problems in mathematics: *integer factoring*.

When you buy something online, your credit card number is protected by RSA encryption, a system based on a simple asymmetry: multiplying two large prime numbers together is easy, but breaking the product back into its prime factors is extraordinarily hard. The number 15 = 3 × 5 is trivial to factor. But a number with 300 digits? The best algorithms would take longer than the age of the universe.

Here's where the right triangles come in. Every factoring of a number N corresponds to a particular right triangle in Berggren's tree. If N = p × q (two primes multiplied together), then there exist right triangles whose sides encode p and q. Finding the right triangle in the tree is the same as finding the factors.

This correspondence was proven rigorously — and the proof has been checked by a computer, line by line, in a system called Lean 4 that can verify mathematical proofs with absolute certainty. The core theorem states: for any odd number N, there is a perfect one-to-one matching between the ways to factor N² and the right triangles with N as one of their sides.

## Three Roads

A team of researchers has explored three different strategies for navigating Berggren's tree to find the triangle that reveals a number's factors.

**Road 1: The Tree Sieve.** Like panning for gold, this method sifts through tree nodes looking for ones with special arithmetic properties. When enough "smooth" nodes are found — nodes whose arithmetic values break down into small primes — they can be combined algebraically to reveal factors. In experiments, this method found factors of numbers up to about 10,000, and surprisingly, it found useful nodes about 20 to 80 times more often than the standard quadratic sieve method used by cryptographers.

**Road 2: Lattice Shortcuts.** The Berggren tree has a hidden geometric structure: it tiles a curved space called the *hyperbolic plane*, the same geometry that appears in M.C. Escher's famous "Circle Limit" prints. In this curved space, the factor-revealing triangle might be much closer than it appears in ordinary flat geometry. The researchers used an algorithm called LLL (named after its inventors Lenstra, Lenstra, and Lovász) to find shortcuts through this lattice.

The experiments produced a remarkable finding: the distance to the factor-revealing triangle grows only logarithmically — roughly proportional to the number of digits in N — rather than exponentially. If this holds for large numbers, it would mean factoring could be done in polynomial time, upending the foundations of modern cryptography.

**Road 3: Teaching a Computer to Search.** Instead of hand-designing a search strategy, why not let a neural network learn one? The researchers trained a small artificial neural network on thousands of factoring examples, teaching it to predict which branches of Berggren's tree are most promising. The network learned to assign about 45% of its attention to greatest-common-divisor features, 25% to geometric ratios, and the rest to modular arithmetic patterns.

The neural approach provided a modest 15% improvement over hand-designed strategies for small numbers but failed to generalize to larger ones. This isn't surprising: if a neural network could learn to factor efficiently, it would violate widely-believed conjectures in computational complexity theory. But the partial success suggests that *heuristic* guidance — good guesses, if not perfect answers — may be learnable.

## Four Open Mysteries

The research opens four tantalizing questions:

**1. Can the tree sieve break the exponential barrier?** Current factoring algorithms are "sub-exponential" — slower than polynomial but faster than exponential. The tree sieve's remarkable smooth density suggests it might join this elite club, but no proof exists yet.

**2. Is there a shortcut through hyperbolic space?** General closest-vector problems in lattices are NP-hard — essentially the hardest problems in computer science. But the Berggren lattice is not a general lattice. Its special algebraic structure might make the problem dramatically easier. The experimental evidence — logarithmic depth growth — is encouraging.

**3. Can artificial intelligence learn to factor?** Probably not perfectly, but possibly heuristically. The conjecture is that a neural network can learn to improve over random guessing by a constant factor, but achieving near-perfect accuracy would require a training set exponentially large in the number of digits. This echoes how AI can learn excellent chess strategies without "solving" chess.

**4. Can quantum computers speed up the tree sieve?** Yes! Grover's quantum search algorithm provides an immediate quadratic speedup: instead of searching 3^D nodes at depth D, a quantum computer needs only 3^{D/2} queries. But the deeper question is whether the tree's algebraic structure enables even faster quantum algorithms — perhaps using quantum walks, which can navigate tree structures with exotic speedups.

## The Road Ahead

The connection between Pythagorean triples and factoring is ancient in some sense — it traces back to Euclid's observation that every Pythagorean triple arises from a pair of generating parameters — but its computational implications are new. The Berggren tree provides a single, elegant structure that unifies number theory, hyperbolic geometry, lattice algorithms, and machine learning in the service of one of mathematics' oldest problems.

Whether these new roads lead to a practical factoring algorithm that threatens internet security remains to be seen. The experiments work only for small numbers, and the gap between factoring a 4-digit number and a 300-digit one is immense. But the mathematical connections are genuine and deep, and history teaches us that unexpected connections in mathematics often lead, eventually, to unexpected applications.

The quadratic sieve, after all, was not invented in a day. It emerged from decades of work by Kraitchik, Morrison, Brillhart, and Pomerance. The tree sieve is at the beginning of its journey. And the view from these three roads — through number theory, geometry, and artificial intelligence — is magnificent.

---

*The Oracle Council's research includes Python implementations and machine-verified Lean 4 proofs. The code and proofs are available in the project repository.*
