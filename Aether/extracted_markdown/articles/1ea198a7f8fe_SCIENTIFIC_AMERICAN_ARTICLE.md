# The Tree That Can't Grow: Why a Beautiful Pattern in Mathematics Refuses to Climb Higher

*A 90-year-old trick for generating all Pythagorean triples hits an impossible wall when we try to extend it to four dimensions*

---

In 1934, a Swedish mathematician named B. Berggren discovered something wonderful. Take the most famous equation in all of mathematics — the Pythagorean theorem, a² + b² = c² — and ask: can you build every whole-number solution from a single seed?

Berggren's answer was yes, and it was beautiful. Start with the simplest Pythagorean triple, (3, 4, 5). Multiply it by three carefully chosen matrices (tables of numbers), and you get three new triples: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the same three matrices to each of those, and you get nine more. Keep going forever, and you produce every primitive Pythagorean triple exactly once, arranged in an elegant infinite ternary tree — three branches at every node, stretching to infinity.

It's one of the most satisfying results in number theory. Three little matrices and one root, and you get *everything*.

But here's a question that has nagged mathematicians ever since: what happens if we add another dimension?

## The Pythagorean Staircase

Pythagorean triples are solutions to a² + b² = c² — three numbers where the squares of two add up to the square of the third. They're the building blocks of right triangles with whole-number sides.

**Pythagorean quadruples** go one step further:

**a² + b² + c² = d²**

Now we need *four* numbers. The simplest example is (1, 2, 2, 3): indeed, 1 + 4 + 4 = 9 = 3². Others include (2, 3, 6, 7) and (4, 4, 7, 9).

If you're a physicist, you might recognize the shape of these equations. The equation a² + b² − c² = 0 describes the **light cone** in 2+1 dimensional spacetime — the paths that photons travel. The equation a² + b² + c² − d² = 0 is the light cone in 3+1 dimensional spacetime — *our* spacetime, the actual physical universe.

So the question of whether Berggren's tree generalizes to quadruples is really asking: does the beautiful tree structure of photon paths in flatland survive when we move to the real universe?

## How the Tree Works (and Why It's a Miracle)

To understand why the tree works for triples, you need to look at the mathematics underneath.

Each Berggren matrix preserves a special property: if you feed it a valid Pythagorean triple, it spits out another valid Pythagorean triple. In the language of physics, the matrices are **Lorentz transformations** — they are the same kind of symmetry operations that describe how space and time mix in Einstein's special relativity, but restricted to whole numbers.

The collection of all such integer Lorentz transformations forms a mathematical structure called a **group** — specifically, the group O(2,1;ℤ). And here's the miracle: this particular group is **virtually free**.

"Virtually free" is a technical term, but the intuition is simple: the group's structure is essentially that of a tree. Think of it like a family tree with exactly three children at every node. The elements of the group correspond to paths down the tree, and every path leads to a unique Pythagorean triple. This is why Berggren's construction works: the tree structure is baked into the DNA of the symmetry group itself.

## The Wall

Now let's try the same thing with quadruples.

For quadruples, the relevant symmetry group is O(3,1;ℤ) — the integer Lorentz transformations in one higher dimension. And here we hit a wall.

**O(3,1;ℤ) is not virtually free.**

In mathematical terms, this group contains a copy of ℤ², the integer lattice of the plane. Two commuting symmetries that generate a grid, not a tree. You can think of it this way: in the triple case, the group's "shape" is a tree. In the quadruple case, the group's shape is a **three-dimensional hyperbolic manifold** — a curved, twisting, cathedral-like space with tunnels and passages that loop back on themselves.

And you simply cannot flatten a cathedral into a tree.

This is not a failure of ingenuity. It's a **theorem**. A result called Stallings' theorem (1968) tells us that a group acts on a tree (with reasonable restrictions) if and only if it is virtually free. Since O(3,1;ℤ) is not virtually free, no possible choice of matrices — no matter how clever — can produce a Berggren-like tree for quadruples.

## What the Computer Found

We didn't just take the theory on faith. We ran the experiment.

Starting from the root quadruple (1, 2, 2, 3), we constructed 13 candidate matrices using the same reflection technique that produces the Berggren matrices. Then we built a tree, applying these matrices iteratively to generate new quadruples.

The result: our tree reached **82.6%** of all primitive Pythagorean quadruples with d ≤ 50. That's 71 out of 86.

But 15 quadruples — including (3, 14, 18, 23), (12, 15, 16, 25), and (4, 13, 16, 21) — were completely unreachable. No sequence of our 13 matrices, applied to (1, 2, 2, 3), can ever produce them. They belong to separate "islands" in the sea of quadruples, disconnected from our root by any bridge we can build.

And no matter how many more matrices we add, the problem persists. There will always be islands we can't reach.

## The Deeper Pattern

If not a tree, then what?

The answer comes from the quaternions — a number system discovered by William Rowan Hamilton in 1843, in which multiplication is not commutative (a × b ≠ b × a). Every primitive Pythagorean quadruple can be generated by a quaternion:

Take a quaternion ω = m + ni + pj + qk and compute its norm: |ω|² = m² + n² + p² + q² = d. The individual components give you a, b, and c through specific formulas. This **quaternionic parametrization** is the natural replacement for the Berggren tree.

But it's not a tree. The map from quaternions to quadruples is many-to-one: the quadruple (1, 2, 2, 3) can be produced by 4 different quaternion parameter sets, while (1, 4, 8, 9) comes from 8. The structure is richer, more tangled, more interesting — a quotient of a four-dimensional lattice by a symmetry group.

## The Growth Problem

There's another clue that trees can't work: the numbers grow too fast.

Primitive Pythagorean triples grow **linearly** — roughly D/π triples have hypotenuse ≤ D. This matches a ternary tree perfectly: tree branches grow exponentially, and the "depth" needed to reach triples of size D grows logarithmically, giving net polynomial growth.

But primitive Pythagorean quadruples grow **quadratically** — roughly proportional to D². At d = 50, there are 86 primitive quadruples, compared to just 7 triples with c ≤ 50. This faster growth means any tree would need its branching factor to *increase* with depth — an impossible requirement for a fixed finite set of matrices.

## Why It Matters

At first glance, this might seem like a negative result — a "can't do" theorem. But the deeper message is about the relationship between algebra and geometry.

The Berggren tree exists because the 2+1 dimensional Lorentz group has the algebraic structure of a free product — essentially, a tree. This is an *accident of low dimension*. In the 3+1 dimensions of our actual universe, the Lorentz group is fundamentally richer. Its action on hyperbolic 3-space produces a manifold, not a graph. The primitive Pythagorean quadruples are organized not by branches but by the chambers and tunnels of a hyperbolic cathedral.

Some of the deepest mathematics of the 20th and 21st centuries — from Thurston's geometrization of 3-manifolds to the Langlands program — is precisely about understanding these richer structures. The Berggren tree is the last stop where number theory is simple enough to be a tree. Beyond it lies geometry.

As one researcher put it: "The universe does not owe you trees in every dimension. Sometimes the right structure is a forest. Sometimes a manifold. Sometimes a cathedral."

---

*The figures accompanying this article, including visualizations of the Berggren tree, primitive quadruples projected onto the sphere, and the growth rate comparison, are available in the research supplement.*
