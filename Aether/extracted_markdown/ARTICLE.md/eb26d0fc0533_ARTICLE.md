# The Ancient Triangle That Could Break Modern Encryption

*How a 4,000-year-old geometric curiosity connects to the deepest unsolved problem in computer science*

---

In 1934, a Swedish mathematician named Berggren noticed something remarkable about the most famous equation in all of mathematics. The Pythagorean theorem—that elegant relationship between the sides of a right triangle, known to every schoolchild—hides within it a secret structure so precise and so unexpected that it reads like a conspiracy. Every right triangle with whole-number sides, from the humble 3-4-5 to the enormous 20-21-29, can be generated from a single seed using exactly three matrix operations. Like a crystalline tree growing from a single root, the entire infinite family of Pythagorean triples fans out in a ternary structure where every branch is a valid triangle, and every valid triangle appears on exactly one branch.

For decades, this was a beautiful curiosity—a piece of pure number theory as ornamental as a cathedral window. Then cryptographers started paying attention.

## The Trillion-Dollar Equation

The security of internet commerce, military communications, cryptocurrency, and virtually every digital secret on Earth rests on a single mathematical assumption: that multiplying two large prime numbers is easy, but recovering those primes from the product is impossibly hard.

When you buy something online, your credit card number is protected by RSA encryption, which works roughly like this: take two prime numbers, each hundreds of digits long, and multiply them together. The product is your public key—anyone can see it. But only someone who knows the original primes can decrypt messages encoded with that key. And finding those original primes? The best known algorithms would take longer than the age of the universe for numbers large enough.

This asymmetry between multiplication and factoring is the foundation of modern digital security. It is also, in a precise mathematical sense, an open problem. Nobody has *proved* that factoring is fundamentally hard. We simply haven't found a fast way to do it—yet.

## Squares That Collide

Here is a fact that sounds innocuous but is actually explosive: if you can find two different numbers whose squares give the same remainder when divided by some composite number *n*, you can probably factor *n*.

Consider *n* = 91. Notice that 27² = 729 and 1² = 1, and 729 − 1 = 728 = 91 × 8. So 27² and 1² leave the same remainder when divided by 91. Now compute the greatest common divisor of 27 − 1 = 26 and 91. It's 13. And indeed, 91 = 7 × 13.

This is not a coincidence. It is a theorem, proved with complete mathematical rigor: whenever *x*² ≡ *y*² (mod *n*) and *x* is not congruent to ±*y*, the greatest common divisor of *x* − *y* and *n* is a nontrivial factor. This is the engine inside every modern factoring algorithm—the quadratic sieve, the number field sieve, and even Shor's quantum algorithm all reduce, at their core, to finding these "square-root collisions."

## Enter the Triangle

Now here is where Pythagoras re-enters the story.

Every Pythagorean triple *a*² + *b*² = *c*² automatically encodes a square-root collision. Rearranging gives *c*² − *a*² = *b*², which factors as (*c* − *a*)(*c* + *a*) = *b*². If you choose your triple so that *b*² is divisible by some target number *n*, then *c*² ≡ *a*² (mod *n*), and you have exactly the kind of collision that cracks open a factorization.

But which triple should you choose? The space of Pythagorean triples is infinite. Searching randomly would be like looking for a specific grain of sand on a beach that stretches to infinity.

This is where Berggren's ternary tree becomes crucial.

## A Tree of All Right Triangles

Euclid knew, around 300 BCE, that every primitive Pythagorean triple (one where the three sides share no common factor) can be written as (*m*² − *k*², 2*mk*, *m*² + *k*²) for suitable integers *m* and *k*. But Berggren discovered something more structural: three specific 3×3 integer matrices, applied to the "root" triple (3, 4, 5), generate every primitive Pythagorean triple exactly once.

The three Berggren generators—call them U, A, and D—act like the three branches at each node of a tree. Apply U to (3, 4, 5) and you get (5, 12, 13). Apply A and you get (21, 20, 29). Apply D and you get (15, 8, 17). Apply UU (U twice) and you get (7, 24, 25). The tree grows forever, and every primitive Pythagorean triple lives at exactly one node.

This means that every primitive Pythagorean triple can be described by a *word*—a sequence of letters from the alphabet {U, A, D}. The triple (7, 24, 25) is "UU." The triple (55, 48, 73) is "UA." Finding a triple with specific arithmetic properties—like producing a square-root collision modulo a target number—becomes equivalent to finding the right word.

## From Words to Lattices

The key insight connecting Berggren's tree to modern lattice cryptography is dimensional. Each Berggren word of length *L* describes a path through a tree with 3^*L* nodes. The matrix product along this path lives in a space of 3×3 integer matrices—a 9-dimensional lattice. Short words correspond to small matrices, which correspond to short vectors in this lattice.

Meanwhile, the factoring problem also has a lattice formulation. Given a composite number *n*, one can define a "divisibility lattice"—the set of integer pairs (*a*, *b*) satisfying *n* | *a*·*b*. Every nontrivial factor *d* of *n* produces a specific short vector in this lattice: namely (*d*, *n*/*d*). Conversely, every sufficiently short vector in this lattice reveals a factor.

This bidirectional correspondence—factors produce short vectors, and short vectors reveal factors—is the certified reduction at the heart of this research. It has been proved with complete mathematical rigor: no gaps, no hand-waving, no "it should work." The forward direction (short vectors yield factors) and the reverse direction (factors yield short vectors with controlled norm) are both exact theorems with explicit bounds.

## What the Theorems Actually Say

The core results establish a clean three-layer architecture:

**Layer 1: Arithmetic extraction.** Given integers *x* and *y* with *x*² ≡ *y*² (mod *n*) and *x* ≢ ±*y* (mod *n*), the greatest common divisor gcd(*x* − *y*, *n*) is a nontrivial factor of *n*. This is an *if-then* theorem: whenever such a collision is found, a factor is guaranteed.

**Layer 2: Pythagorean encoding.** Pythagorean triples provide a structured source of square congruences. The identity *c*² − *a*² = *b*² means that any triple where *n* | *b*² automatically satisfies *c*² ≡ *a*² (mod *n*). The Euclid parametrization further decomposes *c* − *a* = 2*k*² and *c* + *a* = 2*m*², giving direct access to the sum-difference structure needed for factor extraction.

**Layer 3: Lattice geometry.** The divisibility lattice of *n* has the property that every nontrivial factor *d* | *n* corresponds to a vector (*d*, *n*/*d*) with squared norm *d*² + (*n*/*d*)² ≤ *n*². Conversely, short vectors encoding nontrivial square congruences yield factors via the gcd extraction of Layer 1.

## The Honest Assessment

It is important to say clearly what this research does *not* establish. It does not prove that the shortest vector in any particular lattice always encodes a factor—that claim is likely false in the naive form. It does not give a polynomial-time factoring algorithm. And it does not immediately break RSA.

What it does establish is more subtle and, in some ways, more interesting: a **certified interface** between the Diophantine world of Pythagorean triples and the geometric world of lattice vectors, with factoring as the connecting problem. Each direction of this interface is proved with exact bounds and explicit witness constructions.

The significance is structural rather than algorithmic. By showing that factoring data can be *encoded* in Pythagorean-lattice data and *decoded* back, this work opens a new attack surface—not for breaking encryption today, but for understanding *why* factoring is hard (or whether it truly is).

## Why Ancient Geometry Meets Modern Cryptography

There is something almost poetic about the connection. The Babylonians, on clay tablets dating to 1800 BCE, recorded Pythagorean triples including (4961, 6480, 8161)—a triple so large that it must have been computed systematically, not discovered by accident. Four millennia later, we discover that the systematic structure they were exploiting is intimately connected to the problem of breaking codes that protect global commerce.

The Berggren tree, Euclid's parametrization, and the quadratic sieve all tap into the same deep vein of arithmetic: the factorization of differences of squares. The identity *a*² − *b*² = (*a* − *b*)(*a* + *b*) is perhaps the most consequential equation in number theory. It is the reason that factoring reduces to finding square roots modulo composites. It is the reason that Shor's quantum algorithm works. And it is the reason that right triangles with integer sides encode, in their very geometry, information about divisibility.

## Looking Forward

The most tantalizing open question is whether the Berggren tree structure can be exploited algorithmically. Finding a short Berggren word that produces a triple with specific congruence properties is a combinatorial search problem. If this search has hidden mathematical structure—periodicity, symmetry, or algebraic shortcuts—then there may exist algorithms, classical or quantum, that can find factoring-relevant triples faster than brute force.

This possibility connects to some of the deepest questions in computational complexity. Is there a "hidden subgroup" structure in the Berggren monoid that a quantum computer could exploit? Can lattice reduction algorithms like LLL find short enough vectors in Pythagorean-derived lattices to extract factors? Does the ternary tree structure of Berggren words admit efficient traversal algorithms guided by modular arithmetic?

These are not rhetorical questions. They are precise mathematical problems, now formulated with enough rigor to admit definitive answers. The reduction from factoring to lattice geometry through Pythagorean arithmetic has been certified. What remains is to determine the computational complexity of navigating that geometry—and whether the ancient triangle truly holds the key to breaking modern encryption, or whether its beautiful structure is, in the end, a mirage that can teach us exactly why factoring is hard.

Either answer would be a breakthrough.
