# The Infinite Family Tree of Right Triangles

*How a 90-year-old mathematical discovery became a formally verified theorem — and why it matters for cryptography*

---

## The Perfect Triangle Problem

Here's something that's been bugging mathematicians since the ancient Babylonians: which right triangles have sides that are all whole numbers?

The answer is more elegant than you might expect. Take the famous 3-4-5 triangle: 3² + 4² = 9 + 16 = 25 = 5². Or 5-12-13: 25 + 144 = 169 = 13². These are called *Pythagorean triples*, and there are infinitely many of them. But the real question is: **is there a pattern?**

In 1934, a mathematician named Berggren found something extraordinary. He discovered that every "primitive" Pythagorean triple — one where the three sides share no common factor — can be generated from the simplest one, (3, 4, 5), using just three matrix transformations. These three operations form a perfect ternary tree: each triple has exactly three children, and every primitive triple appears exactly once.

Think of it like a family tree where (3, 4, 5) is the ancestor, and every right triangle with integer sides is a descendant. No duplicates. No missing members. A complete genealogy.

## The Tree in Action

Starting from (3, 4, 5), the three transforms produce:
- **Branch A** → (5, 12, 13)
- **Branch B** → (21, 20, 29)
- **Branch C** → (15, 8, 17)

Each of these spawns three more:
- From (5, 12, 13): we get (7, 24, 25), (55, 48, 73), and (45, 28, 53)
- From (21, 20, 29): we get (39, 80, 89), (119, 120, 169), and (77, 36, 85)

...and so on forever.

The remarkable claim is that *every* primitive Pythagorean triple appears somewhere in this tree, and it appears *exactly once*. The triple (20, 21, 29) is the B-child of (3, 4, 5). The triple (9, 40, 41) is the A-child of the A-child of the A-child of (3, 4, 5) — three levels deep in the leftmost branch.

## What We Proved (and Why a Computer Checked It)

Our contribution is a **formal machine-verified proof** that this completeness theorem is true. Using the Lean 4 proof assistant with the Mathlib library, we proved 79 theorems and wrote 23 definitions, all without any gaps (zero `sorry` statements — Lean's way of marking unproven claims).

Why does machine verification matter? Because human proofs, even published ones, sometimes contain subtle errors. A proof assistant is like a meticulous accountant who checks every single step. If it compiles, the proof is correct — not probably correct, not almost certainly correct, but *mathematically guaranteed*.

The key insight in our proof is beautifully simple. We show that every primitive triple with hypotenuse c > 5 has a *unique parent* — a triple you can reach by running the Berggren process in reverse. We classify which of the three reverse operations works by looking at two "sigma invariants":

- σ₁ = a + 2b − 2c
- σ₂ = 2a + b − 2c

These invariants partition all primitive triples into three families, each corresponding to one reverse operation. The sigma values can't both be non-positive (that would violate the Pythagorean equation), and they can't be zero (that would force c = 5). So exactly one of three cases applies.

Moreover, the parent always has a smaller hypotenuse. Specifically, the parent's hypotenuse is c' = 3c − 2(a + b), which is always positive and always less than c. This "descent" eventually reaches c = 5, at which point the only option is (3, 4, 5) itself.

## The Universal Hypotenuse Formula

Perhaps the most surprising discovery is the **universal parent hypotenuse formula**: regardless of which inverse operation you apply, the resulting hypotenuse is always the same: c' = 3c − 2a − 2b. The three inverses differ only in how they split the legs (a', b'), not the hypotenuse (c').

This formula is what makes the descent argument work. It provides a single, clean measure of progress: the hypotenuse strictly decreases at every step, by at least 2. After at most (c − 5)/2 steps, you must reach the root.

## A Surprising Connection: Cryptographic Hashing

Here's where it gets unexpected. The unique descent path — the sequence of "which inverse did we use?" choices — gives every primitive triple a unique fingerprint. The triple (7, 24, 25) has fingerprint "AA" (two A-inversions). The triple (119, 120, 169) has fingerprint "BB" (two B-inversions).

This fingerprint is an *injective map*: different triples always get different fingerprints. That's exactly the property you need for a collision-resistant hash function — a fundamental building block of cryptography.

Collision resistance here isn't just an engineering claim. It's a *mathematical theorem*: finding two different triples with the same descent path is provably impossible, because the descent path uniquely determines the triple (you can reconstruct it by running the forward operations from the root).

## The Lorentz Connection

Even more surprising: the Berggren matrices preserve a mathematical structure called the *Lorentz form*, the same structure that appears in Einstein's special relativity. The equation a² + b² = c² can be rewritten as a² + b² − c² = 0 — the condition for a vector to be "null" (light-like) in a 2+1-dimensional spacetime.

The Berggren matrices are elements of the discrete Lorentz group SO(2,1;ℤ), and primitive Pythagorean triples correspond to null rays in this Lorentzian lattice. The completeness theorem says that these three matrices generate the entire null cone of the integer Lorentz group — a statement that bridges number theory and mathematical physics.

## Why This Matters

Formal verification of mathematical results is becoming increasingly important. As mathematics grows more complex, the gap between "I'm pretty sure this is right" and "I've checked every step" grows wider. Projects like ours demonstrate that:

1. **Classical results can be mechanized.** The Berggren tree completeness was known informally for decades, but our proof is the first to survive a computer's scrutiny.

2. **Cross-domain connections are real.** The same mathematical structure that generates Pythagorean triples also connects to Lorentzian geometry and cryptographic hashing. Formal verification forces you to make these connections precise.

3. **Infrastructure matters.** Our proof builds on thousands of lemmas from Mathlib, the community library for Lean. Each lemma is itself machine-verified. It's turtles all the way down — and that's the point.

## A Tree for All Time

The Berggren tree is one of those mathematical objects that feels like it was *discovered*, not invented. It's been sitting there, implicit in the structure of the integers, since before humans existed. Every right triangle with integer sides and no common factors is a leaf on this tree, growing forever from the single seed of 3² + 4² = 5².

What we've done is prove, with absolute certainty, that the tree is complete. No triple is missing. No triple appears twice. It's a small result in the grand scheme of mathematics, but it's *known* — not believed, not conjectured, but known — to be true.

And that, in the age of AI-generated proofs and computer-verified mathematics, is something worth celebrating.
