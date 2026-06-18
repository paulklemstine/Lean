# The Hidden Tree That Contains Every Right Triangle

## How a 90-year-old mathematical structure connects ancient geometry to modern computing — and was just verified by machine

---

*Imagine a tree — not of wood and leaves, but of numbers. Its root is the triple (3, 4, 5), the simplest right triangle with whole-number sides. From this seed, three branches grow: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Each of these sprouts three more. And three more. Forever.*

*This infinite tree, discovered by Swedish mathematician Berggren in 1934, contains every primitive Pythagorean triple — every right triangle with whole-number sides that can't be simplified — exactly once. It's one of the most beautiful structures in all of mathematics. And for the first time, a computer has verified that it really works.*

---

### The Oldest Equation in Mathematics

The Pythagorean theorem — a² + b² = c² — is arguably the most famous equation in mathematics. It was known to the Babylonians at least a thousand years before Pythagoras, carved into clay tablets alongside lists of integer solutions: 3² + 4² = 5², and 5² + 12² = 13², and 8² + 15² = 17².

But the Babylonians didn't know what Berggren discovered: that *all* such triples form a single, perfectly regular tree.

### Three Matrices, Infinite Triples

The trick is three special 3×3 matrices — call them A, B, and C. Given any Pythagorean triple (a, b, c), multiplying by any of these matrices produces a new triple. Starting from (3, 4, 5):

- Matrix A gives (5, 12, 13)
- Matrix B gives (21, 20, 29)
- Matrix C gives (15, 8, 17)

Apply the matrices again to each of these children, and you get nine grandchildren. Then 27 great-grandchildren. At depth *d*, there are exactly 3^d triples.

The remarkable fact is that **every primitive Pythagorean triple appears somewhere in this tree, and it appears exactly once**. The triple (20, 21, 29) is there. So is (12709, 13500, 18541). So is every other one, no matter how large.

### Einstein's Geometry in Disguise

The deepest surprise is *why* the tree works. The three Berggren matrices preserve a quantity called the *Lorentz form*: Q(a,b,c) = a² + b² - c². This is the same mathematical structure that underlies Einstein's special relativity, where spacetime distances are measured by x² + y² + z² - (ct)².

Pythagorean triples are the points where Q = 0 — the "null cone" in mathematical language, or the "light cone" in physics. The Berggren matrices shuffle points around on this cone without ever leaving it, like symmetries of spacetime that happen to have integer coordinates.

This means the Berggren tree isn't just a curiosity — it's a *discrete version of the Lorentz group*, the fundamental symmetry group of physics.

### Machine-Verified Mathematics

For decades, these facts were proven by hand, with the possibility of human error lurking in every step. Now, for the first time, a team has verified the core properties using Lean 4, a computer proof assistant that checks every logical step with absolute rigor.

The machine-verified results include:

- **All three matrices preserve a² + b² = c²** — verified by polynomial identity checking
- **Primitivity is preserved** — if gcd(a,b) = 1, then gcd(a',b') = 1 for every child
- **Hypotenuses strictly grow** — every child has a larger hypotenuse than its parent
- **Forward-inverse cancellation** — every matrix has an integer inverse, and they perfectly undo each other
- **The Pell recurrence** — down the "fast lane" (B-branch), hypotenuses follow c_{n+1} = 6c_n - c_{n-1}

In total, over 35 theorems have been machine-verified with zero gaps ("sorries" in the formal verification world).

### A New Discovery: The Mirror Symmetry

During the formalization process, the team discovered something that had been overlooked: **matrices A and C are secretly the same matrix, just viewed from a different angle.**

Formally, there exists an involution P — a simple matrix that swaps the two legs of a right triangle — such that C = P·A·P. This explains a mystery that had puzzled researchers: why do A and C have identical characteristic polynomials (x-1)³, despite being different matrices?

The answer is beautiful. A generates triangles leaning one way (with b > a), and C generates their mirror images (with a > b). They're reflections across the 45° line. Matrix B, on the other hand, generates triangles close to the diagonal (a ≈ b), and it has a fundamentally different structure with eigenvalue 3 + 2√2 ≈ 5.83, the golden ratio's cousin from the Pell equation world.

### The Fast Lane: Pell Numbers and √2

The B-branch of the tree is where the action is. Starting from (3, 4, 5), the pure B-path produces:

- (3, 4, 5) → (21, 20, 29) → (119, 120, 169) → (697, 696, 985) → ...

Notice anything? The two legs are nearly equal: 21 and 20, 119 and 120, 697 and 696. These triples are approaching the 45° line — the right triangle that would have a = b, which would require c = a√2, impossible for integers.

The hypotenuses grow exponentially: 5, 29, 169, 985, 5741, ... Each is roughly 5.83 times the previous. That factor is exactly 3 + 2√2, the fundamental solution to the Pell equation x² - 2y² = 1. The Berggren tree encodes deep algebraic number theory in its branching structure.

### The Crown Jewel: Completeness

The biggest remaining goal is to formally verify the **completeness theorem**: that *every* primitive triple appears in the tree. The prerequisites are now all in place. The proof idea is elegant:

1. Given any primitive triple (a, b, c) with c > 5, compute three "parent candidates" using inverse matrices.
2. Show that exactly one of these candidates has all positive entries.
3. That candidate is a valid triple with strictly smaller hypotenuse.
4. Repeat. Since the hypotenuse decreases at each step but remains positive, the descent must terminate — and it can only terminate at the root (3, 4, 5).

This is a *well-founded recursion* argument, the same technique used to prove that algorithms terminate. The formal verification team is on the verge of completing it.

### Applications: From Ancient to Modern

The EML–Pythagorean bridge connects this ancient mathematical structure to modern applications:

**Signal Processing.** Integer-valued direction-of-arrival estimation for radar and sonar. Instead of computing arctan with floating-point errors, look up the nearest Pythagorean triple in the tree — exact integer arithmetic, no rounding.

**Quantum Computing.** The ternary tree is a natural substrate for quantum walks, achieving quadratic speedups over classical search for finding specific triples.

**Neural Networks.** The EML operator eml(x, y) = eˣ − ln(y) combines exponential and logarithmic sensitivity in a single function. It has a natural phase transition at y = e that could serve as a learnable activation threshold.

**Cryptography.** The tree descent algorithm is essentially a "factoring" operation — breaking a large triple into its unique sequence of A, B, C steps. While probably not hard enough for real cryptography (the inverse matrices are public), it illustrates how tree structures can encode one-way-ish functions.

### The Bigger Picture

The Berggren tree sits at a crossroads of mathematics. It connects:

- **Number theory** (Pythagorean triples, Pell equations, Gaussian integers)
- **Algebra** (the Lorentz group, free groups, representation theory)
- **Geometry** (hyperbolic tilings, fundamental domains, geodesic flows)
- **Dynamics** (symbolic dynamics, Lyapunov exponents, transfer operators)
- **Analysis** (zeta functions, modular forms, spectral theory)

Even the *Markov tree* — an entirely different structure from number theory, where triples (a,b,c) satisfy a² + b² + c² = 3abc — shares the same ternary tree architecture, hinting at deep connections yet to be discovered.

And now, with 35+ machine-verified theorems and a clear path to completeness, we're closer than ever to understanding this infinite tree in its full glory. The ancient Babylonians who carved those first Pythagorean triples into clay would be astonished to learn that their numbers form a perfect tree — and that a machine has confirmed it.

---

*The research described here builds on work by B. Berggren (1934), F.J.M. Barning (1963), and A. Hall (1970), who independently discovered the ternary tree structure. The machine verification uses Lean 4 with the Mathlib library. For technical details, see the accompanying research paper.*
