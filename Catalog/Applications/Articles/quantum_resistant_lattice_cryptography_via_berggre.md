# The Ancient Triangles That Could Protect Your Secrets From Quantum Computers

*How a 2,500-year-old mathematical structure is being reimagined as a shield for the post-quantum age.*

---

In 570 BCE, give or take, members of the Pythagorean brotherhood discovered something that still reverberates through mathematics: certain right triangles have sides that are all whole numbers. The simplest is the 3-4-5 triangle. Then comes 5-12-13. Then 8-15-17. The list goes on forever, and for more than two millennia, mathematicians have been fascinated by these "Pythagorean triples" — integer solutions to the equation a² + b² = c².

What nobody expected is that these ancient triangles would turn out to have a hidden structure perfectly suited to one of the most urgent problems in modern technology: protecting digital information from quantum computers.

## A Tree That Grows Triangles

In 1934, a Swedish mathematician named Berggren made a remarkable discovery. He found three matrices — simple grids of numbers — that act like a kind of breeding rule for Pythagorean triples. Start with the 3-4-5 triangle and apply any of the three matrices, and you get a new Pythagorean triple. Apply any matrix to *that* triple, and you get another. Keep going, and you generate every primitive Pythagorean triple exactly once.

The result is an infinite ternary tree — a branching structure where each node has exactly three children — containing every possible primitive Pythagorean triple. It's as if the entire universe of right triangles with whole-number sides is encoded in a family tree, with (3,4,5) as the common ancestor of all.

For decades, this was considered a beautiful curiosity — an elegant way to enumerate a classical mathematical structure. Nobody thought to ask: what happens if you treat this tree as a cryptographic machine?

## The One-Way Street

Modern cryptography relies on mathematical one-way streets: operations that are easy to perform in one direction but nearly impossible to reverse. Multiplying two large prime numbers is easy; factoring the result back into those primes is (we believe) enormously hard. This asymmetry is the foundation of the encryption that protects everything from banking to national security.

But quantum computers threaten to demolish this foundation. Peter Shor showed in 1994 that a sufficiently powerful quantum computer could factor large numbers efficiently, breaking the most widely used encryption schemes. The race is on to find new one-way streets that resist quantum attack — a field called post-quantum cryptography.

The Berggren tree offers a candidate. Traveling *down* the tree — applying matrices to generate new triples — is trivially easy. But traveling *up* — given a Pythagorean triple somewhere deep in the tree, figuring out which sequence of matrices produced it — appears to be hard. Very hard. And unlike traditional factoring-based cryptography, this hardness connects to lattice problems, a class of mathematical puzzles that are believed to resist even quantum computers.

## Faithfulness: The Cryptographic Superpower

The key mathematical result that makes this work is what mathematicians call *faithfulness*: every distinct sequence of matrix applications produces a different Pythagorean triple. No two paths through the tree ever arrive at the same destination.

This has now been rigorously proved with complete mathematical certainty. The proof uses a beautiful algebraic trick. When you compute the "cross-product" of one Berggren matrix's inverse with another Berggren matrix, you get a remarkably simple object: a diagonal matrix that simply flips the sign of one or two coordinates. Since Pythagorean triples always have positive coordinates, this sign flip creates a contradiction — proving that two different matrices applied to *any* Pythagorean triple must produce different results.

Combined with the fact that each matrix strictly increases the hypotenuse (the longest side of the triangle), this means the tree is genuinely a tree, with no loops or collisions. Every word in the three-letter alphabet {A, B, C} maps to a unique triple. It's a perfect one-to-one correspondence between sequences and triangles.

## From Triangles to Lattices

Why does this matter for post-quantum security? The connection runs through lattice cryptography, currently the leading candidate for encryption that quantum computers can't crack. A lattice is a regular grid of points in space — think of an infinite, perfectly repeating crystal structure, but in arbitrary dimensions.

The hardest problems in lattice cryptography involve finding the shortest vector in a lattice — the closest pair of grid points. This is called the Shortest Vector Problem (SVP), and it appears to be intractable even for quantum computers.

Here's the bridge: the Berggren orbit naturally generates lattice vectors. Take two different Pythagorean triples produced by different words, and their difference is an integer vector — a point in a three-dimensional integer lattice. If you could efficiently recover the word from a triple (breaking the one-way function), you would automatically obtain short vectors in this lattice. Conversely, the hardness of finding short lattice vectors provides evidence that recovering the word is hard.

This creates a formal reduction: breaking Berggren orbit cryptography implies solving a lattice problem. And lattice problems are believed to be quantum-resistant.

## The Lorentzian Connection

There's a deeper mathematical layer that makes this more than a clever trick. The equation a² + b² = c² can be rewritten as a² + b² - c² = 0 — the vanishing of a "Lorentzian" quadratic form. This is the same mathematics that governs spacetime in Einstein's special relativity, where the metric distinguishes between space and time with a crucial minus sign.

The Berggren matrices preserve this Lorentzian form. Mathematically, they belong to an integral Lorentz group — the same algebraic structure that governs how observers in different reference frames relate to each other in relativistic physics. The Pythagorean triples sit on the "light cone" of this quadratic form — the boundary between spacelike and timelike.

This isn't just an analogy. It's a structural identity that connects number theory, hyperbolic geometry, and the algebraic foundations of modern physics. The Berggren tree is, in a precise sense, a discretization of motion through a Lorentzian spacetime, projected onto the light cone.

## Building the Machine

The practical blueprint for a Berggren-based cryptographic system works like this:

**Key generation**: Choose a random word of length *d* over the alphabet {A, B, C}. This is your secret key. The key space is 3^d — for d = 323, this gives 256-bit post-quantum security under Grover's bound.

**Public key derivation**: Apply the corresponding sequence of Berggren matrices to the root triple (3, 4, 5). The resulting Pythagorean triple is your public key. By faithfulness, your public key uniquely determines your secret key — but finding that secret key from the public triple appears to require exhaustive search.

**Security guarantee**: Any attack that recovers the secret word from the public triple would yield a method for finding short vectors in the orbit-generated lattice. By the believed hardness of lattice problems against quantum adversaries, such an attack does not exist.

The concrete numbers are compelling. Each Berggren matrix multiplication involves only small integer arithmetic — no modular exponentiation, no elliptic curve operations, no expensive field arithmetic. A depth-323 word produces a public key (a Pythagorean triple) that can be computed in microseconds on a smartphone. The triple itself serves as a compact, verifiable public key with built-in structure: anyone can check that a² + b² = c² and that the components are coprime.

## A New Frontier

What makes this development particularly exciting is not any single theorem, but the bridge it constructs between previously unrelated fields. Number theory and cryptography have long been intertwined, but the specific connection through arithmetic dynamics — the study of iterated matrix actions on structured mathematical objects — opens entirely new territory.

The Berggren tree is just the beginning. The same principles apply to other "arithmetic trees" generated by matrix actions on quadratic forms. Markov triples, which satisfy x² + y² + z² = 3xyz, have their own tree structure with similar properties. Higher-dimensional generalizations — integral orthogonal groups acting on quadratic forms in four, five, or more variables — could provide even richer cryptographic structures.

There are also connections to expander graphs, algebraic complexity theory, and information-theoretic entropy extraction. The min-entropy of a uniformly random Berggren word is exactly log₂(3) per character — about 1.585 bits per step — which is sufficient for cryptographic key derivation via standard leftover hash lemma arguments.

## The Oldest New Idea

Mathematics has a peculiar habit of this. Structures discovered for their pure beauty — investigated for centuries as intellectual curiosities — turn out to have precisely the properties needed for applications that couldn't have been imagined when they were first studied.

The Pythagorean theorem is arguably the oldest result in all of mathematics. That its integer solutions would one day be proposed as a foundation for quantum-resistant cryptography says something profound about the unity of mathematical knowledge. The same equation carved into Babylonian clay tablets 4,000 years ago may soon be protecting your medical records, financial transactions, and private communications from attacks by machines that manipulate the quantum fabric of reality itself.

Somewhere, the ghost of Pythagoras must be smiling.
