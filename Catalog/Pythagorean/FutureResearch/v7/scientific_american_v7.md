# The Hidden Tree Inside Every Right Triangle

*How a 90-year-old mathematical structure connects ancient geometry to modern computation — and how a computer just proved its most important property*

---

You learned the Pythagorean theorem in middle school: in a right triangle, the square of the hypotenuse equals the sum of the squares of the other two sides. The triple (3, 4, 5) is the most famous example: 3² + 4² = 5², or 9 + 16 = 25.

What you probably didn't learn is that there's a *tree* hiding inside the Pythagorean theorem — an infinite, perfectly ordered structure that contains every possible right triangle with whole-number sides, each appearing exactly once. And a computer has just verified the key property that makes it work.

## The Berggren Tree

In 1934, Swedish mathematician B. Berggren discovered something remarkable. Starting from the triple (3, 4, 5), you can generate *all* primitive Pythagorean triples — those where the three sides share no common factor — by applying just three matrix transformations, which we'll call A, B, and C.

Each transformation takes a Pythagorean triple and produces a new, larger one:

- **A** turns (3, 4, 5) into (5, 12, 13)
- **B** turns (3, 4, 5) into (21, 20, 29)
- **C** turns (3, 4, 5) into (15, 8, 17)

Apply A to (5, 12, 13) and you get (7, 24, 25). Apply B to (21, 20, 29) and you get (119, 120, 169). Every step produces a genuine Pythagorean triple, and no triple ever repeats. The result is a ternary tree — each node has exactly three children — that unfurls to infinity, capturing every primitive right triangle in existence.

```
                    (3, 4, 5)
                   /    |    \
            (5,12,13) (21,20,29) (15,8,17)
           /   |   \    /  |  \    /  |  \
      (7,24,25) ... ... ... ... ... ... (35,12,37)
```

## The Completeness Question

But does the tree *really* contain every primitive Pythagorean triple? Berggren claimed it did, and for 90 years mathematicians have believed it. The proof idea is elegant: given any triple, apply the *inverse* transformations to walk backwards toward the root (3, 4, 5). If you always end up at the root, then every triple must be in the tree.

The catch is proving that the backward walk always works — that at each step, at least one of the three inverse transformations produces a valid triple (one with all positive entries). This is the **Parent Existence Lemma**, and it had never been formally machine-verified.

Until now.

## A Computer Proves the Key Theorem

Using the Lean 4 proof assistant — a computer program that checks every logical step of a mathematical argument — researchers have formally verified the Parent Existence Theorem:

> **Theorem.** For every primitive Pythagorean triple (a, b, c) with a, b, c > 0, gcd(a, b) = 1, and c > 5, exactly one of the three inverse Berggren transforms produces a triple with all positive components.

The proof rests on a beautiful case analysis. The three inverse transforms share the same new hypotenuse, c' = 3c − 2(a + b), which is always positive and always less than c. But their first two components have a complementary sign structure:

- invB₁ and invB₂ have the same first component: a + 2b − 2c
- invB₂ and invB₃ have the same second component: 2a + b − 2c
- invB₁'s second component is the *negation* of invB₂'s
- invB₃'s first component is the *negation* of invB₁'s

This means that if a + 2b > 2c and 2a + b > 2c, then invB₂ works (both components positive). If a + 2b > 2c but 2a + b < 2c, then invB₁ works (the second component flips sign). And if a + 2b < 2c but 2a + b > 2c, then invB₃ works.

But can both quantities be *negative*? No! If a + 2b ≤ 2c and 2a + b ≤ 2c simultaneously, then adding gives 3(a + b) ≤ 4c, which combined with a² + b² = c² leads to 5(a − b)² + 2ab ≤ 0 — impossible when a, b > 0.

And can either quantity be *exactly zero*? Only if the triple is a multiple of (3, 4, 5) or (4, 3, 5). Primitivity rules that out for c > 5.

Every step of this argument has been checked by the Lean proof assistant. No human error, no hidden assumptions, no gaps. The computer says: **proven**.

## The Mirror Symmetry

The formal verification effort also revealed a beautiful hidden symmetry in the Berggren tree. The A and C branches are *mirror images* of each other.

Mathematically, there's a "leg-swap" matrix S that exchanges the two legs of a triple: (a, b, c) becomes (b, a, c). And S conjugates the A-branch matrix into the C-branch matrix: B₃ = S · B₁ · S. Since conjugate matrices have identical eigenvalues, the A and C branches share every spectral property — same characteristic polynomial, same Lyapunov exponent, same growth rate.

The B branch, by contrast, is *self-conjugate*: S · B₂ · S = B₂. This means B₂ commutes with the leg-swap, and its triples tend to be "balanced" (the two legs are roughly equal). The triple (21, 20, 29) at depth 1 is nearly balanced; at depth 2, B₂ produces (119, 120, 169), even more so.

This ℤ/2ℤ symmetry — the simplest possible group — organizes the entire infinite tree.

## Nilpotent versus Hyperbolic

The three branches have fundamentally different dynamics, controlled by their eigenvalues:

- **A and C branches** (B₁ and B₃): These are *unipotent* — their only eigenvalue is 1, with algebraic multiplicity 3. The matrix B₁ − I is nilpotent: (B₁ − I)³ = 0 but (B₁ − I)² ≠ 0. This means B₁ⁿ grows *polynomially* in n (quadratically, in fact), and the triples along a pure A-path grow relatively slowly.

- **B branch** (B₂): This is *hyperbolic* — its eigenvalues are 3 + 2√2 ≈ 5.83, 3 − 2√2 ≈ 0.17, and −1. The dominant eigenvalue drives *exponential* growth: triples along a pure B-path explode in size, with hypotenuses satisfying the Pell recurrence c_{n+1} = 6c_n − c_{n-1}.

This spectral gap — the ratio ρ(B₂)/ρ(B₁) = 3 + 2√2 ≈ 5.83 — controls mixing times, convergence rates, and the geometry of random walks on the tree.

## The Big Picture

The Berggren tree sits at the intersection of several major areas of mathematics:

- **Number theory**: It parametrizes all primitive Pythagorean triples, connecting to sums of two squares, Gaussian integers, and the Fermat-Euler theorem.

- **Group theory**: The matrices B₁, B₂, B₃ generate a subgroup of O(2,1;ℤ), the integer Lorentz group. Understanding this group — is it free? what is its abelianization? — remains open.

- **Dynamical systems**: The descent algorithm defines a 3-to-1 expanding map on the set of Pythagorean angles. Its invariant measure gives the limiting angle distribution on the tree.

- **Hyperbolic geometry**: The Lorentz group O(2,1;ℝ) is the isometry group of the hyperbolic plane. Each Berggren matrix corresponds to a hyperbolic isometry, and the tree tiles the hyperbolic plane.

And now, with the Parent Existence Theorem formally verified, the path to a complete machine-verified proof of Berggren's 1934 conjecture is clear. The remaining step — showing that repeated descent always reaches (3, 4, 5) — follows by well-founded induction on the hypotenuse, since each step strictly decreases c.

## What's Next?

The research program has identified over a dozen open directions:

1. **Full completeness**: Combine parent existence with well-founded descent for a complete proof.

2. **Free group question**: Do the Berggren matrices satisfy any nontrivial relations, or do they generate a free group?

3. **Berggren zeta function**: Define ζ_B(s) = Σ c⁻ˢ over all PPTs and study its analytic properties.

4. **Quantum walks**: Can quantum walks on the Berggren tree solve computational problems faster than classical algorithms?

5. **Higher dimensions**: Extend the tree to Pythagorean quadruples a² + b² + c² = d² and beyond.

Each direction connects the ancient geometry of right triangles to cutting-edge mathematics and computer science. The Berggren tree, it turns out, is not just a curiosity — it's a window into some of the deepest structures in number theory.

And now, for the first time, a computer has confirmed that the window is well-built.

---

*The formal proofs described in this article are verified in Lean 4 with the Mathlib library. The complete code is available in the project repository.*
