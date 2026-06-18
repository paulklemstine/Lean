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

Now consider this: every odd number N defines a Pythagorean triple. If N = 77, then 77² + 2964² = 2965². This is the "trivial triple" for N, constructed by the ancient formula of Euclid. The triple sits somewhere in the Berggren tree, and we can climb toward the root.

As we climb — depth 0, depth 1, depth 2, and so on — at each level, the triple's sides are new numbers, linear combinations of the original. And here's the key discovery: at certain depths, the greatest common divisor (GCD) of the current triple's sides with N reveals a *factor* of N.

For N = 77 = 7 × 11: at some depth d* in the climb, we find a side that shares a factor with 77. The tree has "shaken loose" the factors.

## How It Works

The algorithm is strikingly simple:

1. **Start**: Given an odd composite N, build the trivial Pythagorean triple.
2. **Climb**: Apply the parent operation to ascend one level.
3. **Test**: Check if gcd(current side, N) gives a nontrivial factor.
4. **Repeat** until a factor is found or the root (3, 4, 5) is reached.

In computational experiments, the algorithm successfully factors every tested semiprime. For a product of two primes p and q, the factor typically appears after about min(p, q) steps.

## The Geometry Beneath

Why does this work? The Berggren matrices don't just preserve triangles — they preserve the *Lorentz form*, the same mathematical structure that underlies Einstein's special relativity. Each Pythagorean triple is a lattice point on a "light cone" in integer spacetime. The parent operation traces a path along this cone, and the factoring information emerges at points where the lattice structure resonates with the divisors of N.

It's as if the number N has a natural frequency, and climbing the tree is like scanning through frequencies until you hit resonance. At resonance, the factors vibrate loose.

## Machine-Verified Certainty

Unlike many mathematical claims about factoring, these results come with an unusual guarantee: they have been *formally verified* in Lean 4, a computer proof assistant used by mathematicians worldwide. The proofs are not informal arguments that might contain subtle errors — they are machine-checked, line by line, against the axioms of mathematics.

The verified theorems include:
- The parent operation always produces a valid Pythagorean triple
- The hypotenuse strictly decreases at each step (guaranteeing termination)
- Every chain reaches (3, 4, 5) in finitely many steps
- The GCD extraction correctly identifies factors

## What It Means — And What It Doesn't

Let's be clear about what this does *not* do: it does not break RSA encryption. For balanced semiprimes where p ≈ q ≈ √N, the algorithm requires roughly √N steps — no better than trial division. The known hard instances of factoring remain hard.

But the algorithm offers something genuinely new: a *deterministic*, *unconditional* factoring method rooted in beautiful geometry, with formally verified correctness. For imbalanced products where one factor is much smaller than the other, it outperforms naive methods. And the mathematical structure it reveals — the connection between tree descent, Lorentz geometry, and divisor structure — opens new avenues for research.

Perhaps most intriguingly, the Berggren tree has been known since 1934, the Pythagorean theorem since antiquity, and the GCD algorithm since Euclid. All the ingredients have been sitting in plain sight for decades or millennia. It took the perspective of *inverting* the tree — climbing it backward — to see the factoring connection.

## The Road Ahead

Several open questions beckon:

- Can the algorithm be accelerated by jumping ahead in the descent rather than climbing one step at a time?
- Is there a quantum version that explores multiple branches simultaneously?
- What is the precise relationship between the descent path and the continued fraction expansion of the number being factored?
- Could deeper connections to the Lorentz group reveal algebraic shortcuts?

The Pythagorean theorem is humanity's oldest mathematical discovery. That it still has secrets to reveal — secrets connected to the hardest open problems in modern mathematics — is a testament to the inexhaustible depth of mathematics itself.

Sometimes the most powerful new ideas are ancient ones, turned inside out.

---

*The formal proofs described in this article are available in the accompanying Lean 4 project. Python implementations for computational verification are included in the supplementary materials.*
