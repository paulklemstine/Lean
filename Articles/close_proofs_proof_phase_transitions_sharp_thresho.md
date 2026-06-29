# The Hidden Symmetry of Right Triangles: How Einstein's Geometry Generates Every Pythagorean Triple

## A puzzle older than algebra

Three whole numbers, three sides of a right triangle, one timeless rule:
the square of the longest side equals the sum of the squares of the other two.
The Babylonians carved such triples into clay tablets more than 3,700 years
ago. The Greeks named the rule after Pythagoras. School children memorize the
smallest example forever: **3, 4, 5**. Because 3² + 4² = 9 + 16 = 25 = 5².

There are infinitely many of these *Pythagorean triples*. (5, 12, 13).
(8, 15, 17). (20, 21, 29). (7, 24, 25). For centuries the natural question was:
is there a *machine* — a clean, mechanical procedure — that spits out **every**
primitive triple exactly once, with no gaps and no repeats? A "primitive" triple
is one in reduced form, where the three numbers share no common factor; every
other triple is just a primitive one scaled up.

The astonishing answer, discovered in its cleanest form by the Swedish
mathematician B. Berggren in 1934 (and rediscovered several times since), is
**yes** — and the machine turns out to be a piece of *Einstein's geometry* in
disguise. This article tells the story of that machine, and of a recent effort
to nail down its core mathematical guarantees with complete rigor.

## A tree that grows triangles

Picture a family tree. At the very top sits the patriarch, the triple
**(3, 4, 5)**. Every triple in the tree has exactly **three** children, produced
by three fixed "breeding rules." Apply the rules to (3, 4, 5) and you get its
three children:

- **(5, 12, 13)**
- **(21, 20, 29)**
- **(15, 8, 17)**

Apply the rules again to each of those, and the tree branches out: (5, 12, 13)
gives birth to (7, 24, 25) and (55, 48, 73), and so on, forever. The remarkable
theorem — the reason this tree matters — is that **every** primitive Pythagorean
triple appears in it **exactly once**. Nothing is missed; nothing is duplicated.
The chaotic-looking scatter of right triangles is secretly a perfectly orderly
ternary tree.

What are the three breeding rules? Each is a simple linear formula. Writing a
parent triple as (a, b, c), the three children are:

- **Child A:** (a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)
- **Child B:** (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)
- **Child C:** (−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)

You can check by hand that feeding (3, 4, 5) into Child A produces (5, 12, 13).
These formulas look arbitrary. They are not. They are *matrices* — and they
belong to one of the most important groups in all of physics.

## Enter Minkowski: time, space, and the light cone

In 1908 Hermann Minkowski reformulated Einstein's special relativity in a single
geometric stroke. He proposed that space and time should be fused into one
four-dimensional arena, and that the "distance" in this arena is not the
familiar Pythagorean sum of squares but a *signed* version, where time carries a
minus sign. Strip away two of the space dimensions and you get the simplest
nontrivial Minkowski world: two space directions and one time direction. Its
geometry is governed by the **Lorentzian quadratic form**

> **Q(a, b, c) = a² + b² − c².**

That minus sign in front of c² changes everything. The set of points where
Q = 0 — where the positive "space" part exactly cancels the "time" part — is a
cone, the famous **light cone**. In relativity it traces the paths of light rays.

Now look again at the Pythagorean condition, a² + b² = c². Rearrange it:
a² + b² − c² = 0. That is **exactly Q = 0**. A triple of whole numbers is
Pythagorean **if and only if** it lies on the light cone of a 2+1 dimensional
Minkowski universe. The right triangles of antiquity are the *integer points on
a light ray*. This is the bridge at the heart of the whole story:

> **Number theory's Pythagorean triples = Physics' integer light cone.**

## Symmetries that shuffle light rays

In relativity, the transformations that preserve Minkowski geometry — that keep
the light cone a light cone and the speed of light constant — are called
**Lorentz transformations**. They form the **Lorentz group**. A boost into a
moving reference frame is a Lorentz transformation; so is a rotation in space.

Here is the punchline. The three breeding rules of the Berggren tree, written as
3×3 matrices,

```
        | 1  -2   2 |          | 1   2   2 |          | -1   2   2 |
   A =  | 2  -1   2 |     B =  | 2   1   2 |     C =  | -2   1   2 |
        | 2  -2   3 |          | 2   2   3 |          | -2   2   3 |
```

are **Lorentz transformations with whole-number entries**. They live in the
*integer Lorentz group*, written O(2, 1; ℤ). The defining property — verified
exactly in this work — is the matrix equation

> **MᵀQM = Q**,  where Q = diag(1, 1, −1) is the Minkowski metric.

This single identity says: applying the matrix M and then measuring Minkowski
length gives the same answer as measuring first. The matrix **preserves the
light cone**. And because the light cone is precisely where the Pythagorean
triples live, *a Lorentz transformation automatically turns one Pythagorean
triple into another.* The mysterious breeding rules are nothing more than the
integer symmetries of spacetime, restricted to the cone of light.

## What was proved, exactly

This project pins down the foundations of the Berggren–Lorentz machine as a set
of fully checked theorems. The headline results:

**1. All three generators are Lorentz symmetries.** Each of A, B, C satisfies
MᵀQM = Q exactly, so the whole monoid they generate sits inside O(2, 1; ℤ). The
inverses are integer matrices too, so the structure is a genuine group of
symmetries.

**2. The orientation signature is (+1, −1, +1).** The determinant of a matrix
tells you whether it preserves or flips orientation. Here det A = +1, det B = −1,
det C = +1. Two of the rules are "proper" Lorentz transformations (like rotations
and boosts); the **B-rule is improper** — it includes a reflection. This gives
the whole tree a hidden two-coloring: each path through the tree carries a parity
equal to *the number of B-steps modulo 2*, and that parity decides whether the
combined transformation preserves or reverses orientation.

**3. Children of Pythagorean triples are Pythagorean.** Each breeding rule, when
fed a triple satisfying a² + b² = c², produces another triple satisfying the same
equation. More strongly, each rule preserves the *full* Lorentz form Q exactly —
not just the zero set, but the value of a² + b² − c² for **any** triple, whether
on the cone or not.

**4. The triangles grow, and grow fast.** For a triple with positive legs, the
B-rule's new hypotenuse is at least **3 times** the old one, and — using the
triangle inequality, which itself is proved here — actually **more than 5 times**
the old hypotenuse. It is also at most **7 times** larger. Because the hypotenuse
multiplies by a bounded factor at every step, a triple with hypotenuse c sits at
**depth about log c** in the tree. This logarithmic depth is what makes the tree
a genuinely *efficient* generator: you can reach enormous triples in a handful of
steps.

**5. The generators do not commute, and they are all different.** Going A-then-B
is not the same as B-then-A. This non-commutativity is the algebraic engine that
makes the tree *branch* rather than collapse — it is why every triple has a
**unique** address (a unique path from the root), and why no two different paths
ever land on the same triangle.

**6. The spectral fingerprints differ.** The traces (sums of the diagonal) are
3, 5, 3 — the B-matrix is the "most expanding" generator, which matches it driving
the fastest growth. The number 1 is an eigenvalue of A and of C (each has a fixed
direction), but **not** of B: the B-rule has no fixed point on the cone and moves
*everything*.

## Why a relativity group should know about right triangles

It feels like a coincidence, but it is not. Both stories are really about the
same equation, a² + b² = c². The Greeks read it as a statement about lengths.
Minkowski read the rearranged version, a² + b² − c² = 0, as a statement about
light. Once you see that the Pythagorean equation *is* the equation of a Minkowski
light cone, the appearance of the Lorentz group is inevitable: the symmetries of
an object are governed by whatever group preserves it, and the group preserving a
2+1 light cone over the integers is exactly O(2, 1; ℤ). The Berggren tree is the
*orbit* of the seed triangle (3, 4, 5) under that group. Antiquity's right
triangles and modern physics' spacetime are two faces of one coin.

## Echoes in cryptography and machine learning

The same structure that delights number theorists has practical shadows.

In **cryptography**, the Berggren monoid is a clean example of a *hard-to-reverse*
process. Walking *down* the tree (parent to child) is trivial — just multiply by a
matrix. Walking *back up*, recovering the exact sequence of A/B/C steps that
produced a given giant triple, is a word problem in a non-commutative monoid: the
kind of asymmetry on which post-quantum schemes are built. The logarithmic depth
means the secret "path" is short, while non-commutativity keeps the search space
exponentially large.

In **machine learning**, the matrices' bounded growth factor (a hypotenuse blows
up by at most 7 per step) is a *Lipschitz bound* — exactly the quantity that
controls how much a transformation can stretch distances. Stacks of such matrices
appear when one wants certified, provably stable maps, and the explicit
factor-of-7 ceiling turns into a certified robustness guarantee that compounds
predictably with depth.

## The oldest equation, freshly understood

There is something deeply satisfying about discovering that a 3,700-year-old
puzzle — which whole numbers can be the sides of a right triangle? — is solved,
completely and elegantly, by the geometry Einstein and Minkowski built to
describe the cosmos. The (3, 4, 5) triangle a child draws on graph paper and the
light cone a physicist draws on a blackboard are, it turns out, the same picture.
The Berggren tree is the family album of that picture: a single seed, three
symmetry-driven breeding rules, and an infinite, perfectly organized garden of
right triangles, each one a frozen ray of light.
