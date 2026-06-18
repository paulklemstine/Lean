# The Ancient Triangle That Could Protect Your Secrets from Quantum Computers

Every schoolchild learns the 3-4-5 triangle. Three squared plus four squared equals five squared — it's the simplest example of a Pythagorean triple, a fact known to Babylonian mathematicians four thousand years ago. But hidden inside this humble triangle is a mathematical structure so rich that researchers are now using it to build a new kind of digital lock, one that might resist the full power of quantum computers.

## A Tree of Triangles

In 1934, a Danish mathematician named Berggren discovered something remarkable. Starting from the 3-4-5 triangle, he found three simple multiplication rules that generate every primitive Pythagorean triple — every right triangle with whole-number sides sharing no common factor. Apply the first rule to (3, 4, 5) and you get (5, 12, 13). Apply the second and you get (21, 20, 29). The third gives (15, 8, 17). Apply the same three rules to each of these new triangles, and you get nine more. Then twenty-seven. Then eighty-one. The process never stops, and it never repeats: every primitive Pythagorean triple appears exactly once in this infinite ternary tree.

What makes Berggren's tree special is not just that it catalogues triangles — it's *how* it catalogues them. Each triangle's position in the tree encodes a unique "word" in a three-letter alphabet: left, middle, right. The triangle (5, 12, 13) is "left." The triangle (697, 696, 985) might be "left-right-left-middle." Every triangle has its own address, like a ZIP code for the world of right triangles.

## When Triangles Become Lattices

Now imagine laying a grid of dots over a sheet of paper — not the usual square grid, but a skewed, tilted one. Mathematicians call these arrangements *lattices*, and they turn up everywhere: in the atomic structure of crystals, in the geometry of error-correcting codes, and, most recently, in the foundations of cryptography.

It turns out that each Pythagorean triple naturally defines a lattice. Given a triple (a, b, c), the classical Euclid parametrization writes a = m² − n², b = 2mn, c = m² + n² for some pair of integers m > n > 0. Those same m and n define a two-dimensional lattice basis — a pair of vectors that tile the plane. The triangle's hypotenuse c controls the "size" of the lattice, while the coprimality of m and n ensures the lattice has no redundant structure.

This correspondence is not just a curiosity. When Berggren's three generators act on a triangle, they also act on its lattice. Each step in the tree transforms the lattice by multiplying its basis by a specific matrix — a transformation that changes the grid's shape while preserving its fundamental volume. In the language of lattice theory, these are *unimodular* transformations, the gold standard of structure-preserving maps.

## The Trapdoor Inside

Here is where the story takes a cryptographic turn. Modern encryption relies on *trapdoor functions*: mathematical operations that are easy to perform in one direction but nearly impossible to reverse without a secret key. When you send a credit card number over the internet, a trapdoor function protects it. When a government agency secures classified communications, trapdoor functions are at work.

The most widely deployed trapdoors today — RSA, Diffie-Hellman, elliptic curve cryptography — all share a dangerous vulnerability: they can be broken by a sufficiently powerful quantum computer running Shor's algorithm. This looming threat has launched a global search for *post-quantum* alternatives, mathematical problems that remain hard even for quantum machines.

Lattice problems are the leading candidates. The core idea: given a random-looking lattice, find the shortest vector in it, or find the closest lattice point to a given target. These problems appear to be hard for both classical and quantum computers, and three of the four algorithms recently standardized by NIST for post-quantum encryption are based on lattices.

The Berggren-lattice correspondence offers a fresh angle on these problems. Walking *forward* in the Berggren tree is easy — just multiply matrices. Walking *backward* — finding which sequence of generators produced a given triangle — is the trapdoor. The height of the triple (essentially the size of the hypotenuse c) controls the difficulty: the deeper you go into the tree, the harder it is to trace your way back.

## Certified Robustness

What sets this new work apart is not just the connection between triangles and lattices, but the *guarantees* that come with it. Every step of the construction has been proved correct with mathematical certainty.

The Berggren generators preserve primitivity: if you start with a triple where gcd(a, b) = 1, every triple in the tree shares that property. They preserve the Pythagorean equation: a² + b² = c² holds at every node. They preserve the parity structure: the odd leg stays odd, the even leg stays even. And crucially, they increase the hypotenuse: every child triple has a strictly larger c than its parent. This monotonicity is the heartbeat of the system — it ensures that the decoding process terminates and that the height provides a genuine complexity measure.

The security margin, measured by the "trapdoor gap" c − a, is provably positive for every triple in the tree. The decoding cost — the number of steps to recover the Berggren word — is bounded linearly by the height. These are not conjectures or heuristic estimates; they are mathematical theorems with rigorous proofs.

## From Babylon to the Quantum Age

The story of Pythagorean triples is one of the longest threads in the history of mathematics, stretching from the clay tablets of Mesopotamia through the number theory of Fermat and Euler to the lattice cryptography of the twenty-first century. What Berggren's tree adds is a discrete, tree-shaped geometry — a kind of arithmetic filing system — that turns abstract number theory into concrete algorithms.

The mapping from triples to lattice bases is a bridge between two worlds that rarely speak to each other. On one side, the number theorists study the arithmetic of primitive triples using tools like the Euclid parametrization, coprimality arguments, and modular arithmetic. On the other side, the cryptographers analyze lattice problems using reduction algorithms, approximation factors, and worst-case to average-case reductions. The Berggren-lattice correspondence lets ideas flow both ways.

Could this lead to practical cryptographic systems? It is too early to say. The lattices involved are two-dimensional, far smaller than the thousands of dimensions used in deployed lattice cryptography. But the *principles* — certified trapdoor inversion, explicit height-complexity bounds, involutive symmetries — are exactly what real-world systems need. And the theory is extensible: the same ideas should generalize to higher-dimensional analogues of Pythagorean equations, opening lattice-cryptographic territory that has never been explored.

## The Bigger Picture

Perhaps the deepest lesson is about the unity of mathematics itself. A geometric fact known to ancient builders — that a 3-4-5 rope makes a right angle — encodes, through four millennia of mathematical development, the beginnings of a defense against technologies that don't yet exist. The Berggren tree, a beautiful object in its own right, becomes a certified decoding algorithm. The Euclid parametrization, a staple of undergraduate number theory, becomes a trapdoor generation primitive. The humble integer lattice, a grid of dots on a plane, becomes a shield against quantum attack.

This is what mathematics does at its best: it finds the hidden connections, the unexpected bridges between ideas that seemed to have nothing in common. And in doing so, it turns ancient knowledge into future technology.

The 3-4-5 triangle is not just a relic of the past. It is a seed — and the tree it grows is still branching.
