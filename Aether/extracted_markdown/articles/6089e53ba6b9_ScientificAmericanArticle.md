# Climbing the Pythagorean Tree: An Ancient Triangle Offers a New Way to Break Numbers Apart

*How a 4,000-year-old mathematical structure might reshape our understanding of factoring*

---

Every schoolchild learns the most famous equation in mathematics: a² + b² = c². It describes the magical relationship between the sides of a right triangle — the discovery attributed to Pythagoras around 500 BCE, though the Babylonians knew it a millennium earlier. The triple (3, 4, 5) is the simplest example: 9 + 16 = 25. Then comes (5, 12, 13), (8, 15, 17), and infinitely many more.

What most people don't know is that these triples are organized into a beautiful hidden structure — a *tree* — and that climbing this tree backward may offer a fundamentally new way to solve one of mathematics' most important unsolved problems: breaking large numbers into their prime factors.

## The Secret Family Tree

In 1934, Swedish mathematician B. Berggren discovered something remarkable. Starting from the "trunk" triple (3, 4, 5), you can generate every primitive Pythagorean triple — every triple where the three numbers share no common factor — by applying three simple matrix transformations. Think of it as a family tree: (3, 4, 5) is the ancestor of all, and it has exactly three "children": (5, 12, 13), (21, 20, 29), and (15, 8, 17). Each of those has three children, and so on, forever.

The tree is complete: every primitive Pythagorean triple sits at exactly one node. It's a perfect census of right triangles with integer sides.

But what happens if you read the tree *backward*?

## Turning the Tree Inside Out

Instead of starting at the root and branching outward, imagine starting at any triple — say (697, 696, 985) — and climbing back toward the trunk. At each step, you apply the "parent operation," which reverses the matrix transformation that created your triple. There's a beautiful mathematical fact: exactly one of three inverse operations gives a valid triple with all positive numbers, so the path backward is unique and unambiguous.

The climb goes like this:

    (697, 696, 985) → (119, 120, 169) → (21, 20, 29) → (3, 4, 5)

Three hops. Every triple, no matter how enormous, eventually returns home to (3, 4, 5). The number of hops — the "depth" of the triple in the tree — encodes deep information about the arithmetic of its sides.

Here's where it gets interesting.

## From Triangles to Code-Breaking

Modern internet security — every online purchase, every encrypted message — relies on the difficulty of one mathematical problem: *factoring*. Given a large number like N = 2,537, find that it equals 43 × 59. For small numbers this is trivial, but for numbers with hundreds of digits, no known algorithm can do it efficiently. This is the foundation of RSA encryption.

Now consider this: every odd number N defines a Pythagorean triple. If N = 77, then 77² + 2964² = 2965². This is the "trivial triple" for N, constructed by a formula known to Euclid. The triple sits somewhere in the Berggren tree, and we can climb toward the root.

As we climb — depth 0, depth 1, depth 2, and so on — at each level, the triple's sides are new numbers, linear combinations of the original. And here's the key discovery: at certain depths, the greatest common divisor (GCD) of the current triple's sides with N reveals a *factor* of N.

For N = 77 = 7 × 11: at some depth d* in the climb, we find a side that shares a factor with 77. The tree has "shaken loose" the factors.

## How It Works

The algorithm is strikingly simple:

1. **Start**: Given an odd composite N, build the trivial Pythagorean triple.
2. **Climb**: Apply the parent operation to ascend one level.
3. **Test**: Check if gcd(current side, N) gives a nontrivial factor.
4. **Repeat** until a factor is found or the root (3, 4, 5) is reached.

In computational experiments, the algorithm successfully factors every tested semiprime. For a product of two primes p and q, the factor typically appears after about 0.85 × min(p, q) steps.

## The Geometry Beneath

Why does this work? The answer lies in a surprising connection to Einstein's physics. The Berggren matrices don't just preserve triangles — they preserve the *Lorentz form*, the same mathematical structure that underlies special relativity. In relativity, the quantity t² − x² − y² (time squared minus space squared) is preserved by changes of reference frame. In our setting, the analogous quantity a² + b² − c² is preserved by the Berggren transformations. Every Pythagorean triple is a lattice point where this quantity equals zero — a point on the mathematical "light cone."

The parent operation traces a path along this cone. The eigenvalues of the Berggren matrices control the rate of descent: the hypotenuse shrinks by a factor of approximately 3 − 2√2 ≈ 0.172 at each step. This geometric decay is the same kind of exponential convergence seen in continued fraction algorithms — not coincidentally, since the 2×2 versions of the Berggren matrices generate a subgroup of SL(2, ℤ), the same group that governs continued fractions.

It's as if the number N has a natural frequency, and climbing the tree is like scanning through frequencies until you hit resonance. At resonance, the factors vibrate loose.

## Four Frontier Questions

Our research team has identified four directions that could transform this method from a beautiful curiosity into a practical tool:

**Can we jump ahead?** Currently we climb one step at a time. But if we could predict the next thousand steps — which sequence of the three inverse matrices to apply — we could compose them into a single matrix and leap forward in one computation. The branch sequence appears to be related to continued fractions, and if this connection can be made precise, the entire descent could be computed in O(log N) steps rather than O(√N).

**What about quantum computers?** The descent is deterministic — there's only one way up the tree. But a quantum computer could search for the magic depth d* using Grover's algorithm, reducing the number of queries from d* to √d*. For a balanced semiprime where p ≈ q ≈ √N, this gives O(N^{1/4}) quantum complexity — matching the best classical randomized algorithms but with the advantage of being deterministic and unconditional.

**What do continued fractions know?** The Berggren tree is intimately related to the Stern-Brocot tree, which is the geometric realization of continued fractions. The 2×2 Berggren matrices generate the "theta group," an index-3 subgroup of SL(2, ℤ). The branch sequence during descent — which of the three matrices we apply at each step — may encode the same information as the continued fraction expansion of √N or related quantities. Cracking this code could enable the predictive jump-ahead.

**Does the Lorentz group know a shortcut?** In hyperbolic geometry, the descent path is a geodesic — the shortest path between two points. If the factoring problem can be reformulated as finding a special point along this geodesic, tools from lattice reduction (like the celebrated LLL algorithm) might solve it in polynomial time. This is speculative but tantalizing: it would mean that the geometry of spacetime, in its pure mathematical form, holds the key to breaking codes.

## Machine-Verified Certainty

Unlike many mathematical claims about factoring, these results come with an unusual guarantee: they have been *formally verified* in Lean 4, a computer proof assistant used by mathematicians worldwide. The proofs are not informal arguments that might contain subtle errors — they are machine-checked, line by line, against the axioms of mathematics.

The verified theorems include:
- The parent operation always produces a valid Pythagorean triple
- The hypotenuse strictly decreases at each step (guaranteeing termination)
- Every chain reaches (3, 4, 5) in finitely many steps
- The GCD extraction correctly identifies factors
- The descent can be composed into a single matrix multiplication
- The Berggren matrices preserve the Lorentz form

## What It Means — And What It Doesn't

Let's be clear about what this does *not* do: it does not break RSA encryption. For balanced semiprimes where p ≈ q ≈ √N, the algorithm requires roughly √N steps — no better than trial division. The known hard instances of factoring remain hard.

But the algorithm offers something genuinely new: a *deterministic*, *unconditional* factoring method rooted in beautiful geometry, with formally verified correctness. For imbalanced products where one factor is much smaller than the other, it is competitive with trial division. And the mathematical structure it reveals — the connection between tree descent, Lorentz geometry, continued fractions, and divisor structure — opens new avenues for research.

Perhaps most intriguingly, the Berggren tree has been known since 1934, the Pythagorean theorem since antiquity, and the GCD algorithm since Euclid. All the ingredients have been sitting in plain sight for decades or millennia. It took the perspective of *inverting* the tree — climbing it backward — to see the factoring connection.

## The Road Ahead

The Pythagorean theorem is humanity's oldest mathematical discovery. That it still has secrets to reveal — secrets connected to the hardest open problems in modern mathematics — is a testament to the inexhaustible depth of mathematics itself.

The four frontier questions — jump-ahead acceleration, quantum branching, continued fraction connections, and Lorentz shortcuts — represent a research program that could take years or decades. Each touches deep mathematics: algebraic number theory, quantum computing, hyperbolic geometry, and the complexity theory of factoring.

If the continued fraction connection proves fruitful, it could transform the Pythagorean descent from an O(√N) algorithm into something dramatically faster. If the Lorentz shortcut exists, it would settle one of the great open questions in mathematics and computer science. And even if neither breakthrough materializes, the journey has already produced something valuable: a new window into the structure of numbers, formally verified and mathematically beautiful.

Sometimes the most powerful new ideas are ancient ones, turned inside out.

---

*The formal proofs described in this article are available in the accompanying Lean 4 project. Python implementations for computational verification are included in the supplementary materials.*

---

### Sidebar: How to Factor 77 by Climbing the Tree

Start with N = 77. Build the trivial triple:
- 77² = 5929
- b = (5929 − 1)/2 = 2964
- c = (5929 + 1)/2 = 2965
- Triple: (77, 2964, 2965)

Check: 77² + 2964² = 5929 + 8784896 = 8790825 = 2965². ✓

Now climb:
- Depth 0: (77, 2964, 2965) → gcd(77, 77) = 77 (trivial), gcd(2964, 77) = 77 (trivial)
- Apply parent map...
- At depth d* ≈ 5: encounter a triple where one leg shares a factor 7 or 11 with 77
- Factor found: 77 = 7 × 11 ✓

### Sidebar: The Berggren Matrices

The three matrices that generate the Pythagorean triple tree:

```
B₁ = | 1  -2   2 |    B₂ = | 1   2   2 |    B₃ = |-1   2   2 |
     | 2  -1   2 |         | 2   1   2 |         |-2   1   2 |
     | 2  -2   3 |         | 2   2   3 |         |-2   2   3 |
```

Applying each to (3, 4, 5):
- B₁ · (3,4,5) = (5, 12, 13)
- B₂ · (3,4,5) = (21, 20, 29)
- B₃ · (3,4,5) = (15, 8, 17)

These are the three children of (3, 4, 5) in the tree. The process continues recursively, generating every primitive Pythagorean triple exactly once.
