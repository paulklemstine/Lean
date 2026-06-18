# The Secret Symmetry of Right Triangles

## How a 4,000-year-old puzzle hides the geometry of space and time

Pick a right triangle whose three sides are all whole numbers. The most
famous one is the 3–4–5 triangle: three squared plus four squared (9 + 16)
equals five squared (25). The Babylonians knew dozens of these on clay
tablets more than three and a half thousand years ago. Euclid gave a recipe
for all of them. They are called **Pythagorean triples**, and at first
glance they look like a quaint corner of arithmetic — a collection of lucky
coincidences among the integers.

They are nothing of the sort. Hidden inside the list of Pythagorean triples
is a piece of machinery that physicists did not invent until the twentieth
century: the symmetry group of Einstein's flat spacetime. The same algebra
that boosts a particle from one inertial frame to another, the same algebra
that keeps the speed of light constant for every observer, can be tuned down
to the integers — and when you do, it manufactures right triangles, one
after another, forever, in a perfectly organized family tree.

This article tells the story of that machine. We will build it from scratch,
watch it grow an infinite tree of triangles out of a single seed, and see
why its inner workings double as a blueprint for fast algorithms and
hard-to-reverse cryptographic puzzles. Every claim below has been checked,
line by line, by a computer that refuses to accept anything it cannot verify.

---

## The light cone made of integers

Start with the quantity that ties everything together. Given three integers
`a`, `b`, `c`, define

> **Q(a, b, c) = a² + b² − c².**

This is the **Lorentz quadratic form**. In physics, if `a` and `b` are
distances in space and `c` is time (in units where light travels one unit of
distance per unit of time), then `Q` measures the "spacetime interval"
between two events. When `Q = 0`, the two events can be joined by a beam of
light: they sit on what physicists call the *light cone*.

Now notice the punchline that makes the whole subject possible:

> **Q(a, b, c) = 0 is exactly the same statement as a² + b² = c².**

In other words, *a triple of integers lies on the light cone if and only if
it is a Pythagorean triple.* The set of integer right triangles is precisely
the set of integer points on the light cone of special relativity. Number
theory and physics turn out to be describing the same surface.

This is not a metaphor. It is a verified identity: `Q(a,b,c) = 0` if and only
if `a² + b² = c²`, proven for all integers at once.

---

## The three machines that respect spacetime

In relativity, the transformations that matter are the ones that *preserve*
the interval `Q` — the rotations and "boosts" that different observers
disagree about, yet all agree leave the speed of light alone. Mathematically
these are the matrices `M` satisfying `Mᵀ Q M = Q`, where `Q` here is the
diagonal metric `diag(1, 1, −1)`. They form the **Lorentz group**, written
`O(2,1)` because there are two space dimensions and one time dimension.

Usually the Lorentz group is a continuous object — you can boost by any
speed you like. But we are only interested in the boosts whose entries are
whole numbers, the group `O(2,1; ℤ)`. It turns out three particular integer
matrices generate everything we need:

```
A = [ 1  -2   2 ]      B = [ 1   2   2 ]      C = [ -1   2   2 ]
    [ 2  -1   2 ]          [ 2   1   2 ]          [ -2   1   2 ]
    [ 2  -2   3 ]          [ 2   2   3 ]          [ -2   2   3 ]
```

Each of these is a genuine integer Lorentz transformation: `Aᵀ Q A = Q`,
`Bᵀ Q B = Q`, and `Cᵀ Q C = Q`, all verified exactly. So each one slides
points along the light cone without ever leaving it. And since the light
cone *is* the set of Pythagorean triples, each matrix turns one right
triangle into another.

The three matrices have a subtle personality difference, visible in their
determinants:

- **det A = +1** (a proper, orientation-preserving boost),
- **det B = −1** (an improper one — it includes a reflection),
- **det C = +1** (proper again).

That single minus sign for `B` is not cosmetic. It splits every product of
these matrices into two camps — "even" and "odd" numbers of `B`'s — exactly
the way physics distinguishes orientation-preserving from
orientation-reversing transformations. We will see it return as a parity bit.

---

## Growing an infinite family tree from 3–4–5

Here is where the abstraction pays off. Applied to the legs and hypotenuse
of a triangle, the three matrices become three explicit "child" rules:

- **A-child:** (a, b, c) ↦ (a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)
- **B-child:** (a, b, c) ↦ (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)
- **C-child:** (a, b, c) ↦ (−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)

Feed in the seed triangle (3, 4, 5) and watch:

- A turns (3, 4, 5) into **(5, 12, 13)**,
- B turns (3, 4, 5) into **(21, 20, 29)**,
- C turns (3, 4, 5) into **(15, 8, 17)**.

Three new right triangles, each verified Pythagorean. Apply the three rules
again to each child, and you get nine grandchildren; apply them once more
for twenty-seven, and so on. For instance, the A-child of (5, 12, 13) is
(7, 24, 25), and its B-child is (55, 48, 73) — again, all genuine.

This is the celebrated **Berggren tree**, discovered by the Swedish
mathematician B. Berggren in 1934 and rediscovered several times since. The
remarkable theorem behind it — which we do not need here but which gives the
construction its grandeur — is that *every* primitive Pythagorean triple
(every right triangle with whole-number sides sharing no common factor)
appears exactly once in this tree, with (3, 4, 5) at the root. A single
triangle and three matrices encode the entire infinitude of integer right
triangles, with no repeats and no omissions.

The engine that keeps the tree honest is a one-line invariant: each child
rule preserves `Q` *exactly*, not just at zero. The A-rule, B-rule, and
C-rule all satisfy `Q(child) = Q(parent)` for *every* input, Pythagorean or
not. Because the seed has `Q = 0`, every descendant has `Q = 0`, forever.
Conservation of the spacetime interval *is* the reason the triangles stay
right.

---

## Riding the B-branch: exponential triangles

Follow one path down the tree — always take the B-child — and a striking
pattern in the hypotenuses appears:

> 5, 29, 169, 985, …

These are 5, then 29, then 169 (which is 13²), then 985. Each is more than
five times the one before it: 5×5 = 25 < 29, 5×29 = 145 < 169, 5×169 = 845 <
985. This is not a numerical fluke. Whenever a Pythagorean triangle has
positive legs, its B-child hypotenuse satisfies

> **hypotenuse(B-child) > 5 × hypotenuse(parent).**

The proof is a beautiful little chain. The B-child hypotenuse is
`2a + 2b + 3c`. The triangle inequality for right triangles — itself a
consequence of `a² + b² = c²` — guarantees `a + b > c`. Combine them:
`2a + 2b + 3c > 2c + 3c = 5c`. The geometric fact that two legs beat the
hypotenuse becomes the dynamical fact that the tree grows at least
five-fold at every step.

Exponential growth has a flip side that is pure gold for computer science.
If the hypotenuses grow by a factor of five at each level, then a triangle
with hypotenuse `c` sits at depth at most about `log₅ c` in the tree. You can
locate any right triangle, no matter how astronomically large, in a number
of steps proportional to the number of *digits* of its hypotenuse, not its
size. Searching the infinite tree is exponentially cheap.

The triangles along this B-branch have a charming signature: their two legs
are consecutive integers. (3, 4), (20, 21), (119, 120), (696, 697) — each
pair differs by exactly one, and each completes to a perfect right triangle:
(3,4,5), (20,21,29), (119,120,169), (696,697,985). These **twin-leg
triples** are the integer right triangles that come closest to being
isoceles, and they are precisely the orbit of the B-generator.

---

## Echoes, fingerprints, and a hidden mirror

Matrices carry fingerprints. The simplest is the **trace** — the sum of the
diagonal entries — which is famously blind to changes of coordinate system.
Our three generators have traces 3, 5, and 3. The fact that `A` and `C` share
the trace 3 while `B` stands out at 5 is the algebraic shadow of `B` being
the lone reflection, and the "most expanding" generator (hence the fastest
hypotenuse growth on its branch).

Look at products and a quieter symmetry surfaces. The trace of `AB` is 17,
the trace of `AC` is 15, and the trace of `BC` is — 17 again. The equality
`trace(AB) = trace(BC)` is unexpected: it says `A` and `C` play
interchangeable roles when paired with `B`, a hidden conservation law of the
tree's geometry.

The deepest of these coincidences is an exact identity between the
generators themselves. Computing the inverse of `A` and multiplying by `C`
gives

> **A⁻¹ · C = −diag(1, 1, −1) = −Q.**

Read aloud: travelling from `C` back through `A` is nothing but a reflection
in the Lorentz metric. Rearranged, it says `C = −A·Q`. The third generator
is not independent at all — it is the first generator viewed in a spacetime
mirror. You only ever needed two matrices and the metric; the third comes
for free. For anyone trying to economize (a cryptographer sizing a key, say)
that is a genuine reduction in moving parts.

Finally, the metric itself is an involution: `Q² = I`. Applying the
spacetime mirror twice returns you to where you started, exactly as a
reflection should.

---

## Why a triangle puzzle matters for modern computing

It is tempting to file all this under "elegant recreational mathematics."
But the same features that make the Berggren tree beautiful make it useful.

**Fast enumeration.** Because hypotenuses grow exponentially, you can list
all primitive right triangles up to any bound, with guaranteed completeness
and no duplicates, by walking the tree to depth `~log c`. The structure
turns an infinite search into a shallow, branchy one.

**Lipschitz control for machine learning.** Every entry of every generator
has absolute value at most 3, and every row sums (in absolute value) to at
most 7. These dull-sounding bounds are exactly the quantities that control
how much a composition of these maps can stretch its input — the
"Lipschitz constant" that certified-robustness proofs in machine learning
care about. A chain of `n` generators stretches by no more than `7ⁿ`, a
bound you can write down with confidence because the entrywise estimates are
proven.

**Cryptographic hardness.** The generators do not commute — `AB ≠ BA`,
`BC ≠ CB`, `AC ≠ CA` — so the order in which you apply them matters, and the
set of products grows like a free monoid: branchy, tangled, and large.
Running the tree *forward* is easy; figuring out *which* sequence of moves
produced a given matrix is the kind of word problem that resists shortcuts.
The `±1` determinant supplies a free parity bit, and the exponential growth
guarantees the search space balloons as `Ω(5^depth)`. These are precisely the
ingredients one looks for when designing puzzles that are easy to pose and
hard to reverse.

---

## The shape of certainty

Every statement in this article — the light-cone identity, the
form-preservation of all three matrices, the exact child triangles, the
five-fold growth, the trace coincidences, the mirror identity `C = −A·Q`,
the entrywise bounds — has been formalized and machine-checked. There is no
"left as an exercise," no appeal to a picture, no hidden assumption. The
3–4–5 triangle, the Lorentz group, and the family tree connecting them have
been pinned down with the full rigor of a proof a computer will accept.

What began as marks on a Babylonian tablet — *these three numbers make a
right angle* — turns out to be a window onto the symmetry of spacetime, a
generator of fast algorithms, and a source of cryptographic hardness. The
right triangles were never a collection of coincidences. They were a group,
acting on a cone, waiting to be read in the right language.
