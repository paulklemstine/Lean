# The Geometry of Agreement: When Overlapping Pieces Share a Common Point

## A puzzle about agreement

Imagine a committee trying to schedule a meeting. Alice is free on Monday or Tuesday, Bob on Tuesday or Wednesday, Carol on Wednesday or Monday. Any *two* of them can find a common day — Alice and Bob agree on Tuesday, Bob and Carol on Wednesday, Carol and Alice on Monday — yet there is no single day when *all three* are free. Pairwise agreement did not add up to unanimous agreement.

This little failure is the whole story of a classical idea in geometry called the **Helly property**. A family of shapes has the Helly property when local agreement forces global agreement: whenever the shapes overlap two-at-a-time, they must all share at least one common point. On a flat plane, convex shapes like disks and triangles famously obey a version of this rule. But the world is full of spaces that are not flat planes — networks, grids, evolutionary trees, configuration spaces — and on those spaces the Helly property can succeed or fail in subtle, structural ways.

This article is about a clean and surprising answer to one such question. It concerns a family of discrete geometric spaces called **partial cubes**, a natural notion of "halfspace" inside them, and a precise condition — which we call being **harmonic-even** — that decides, once and for all, when pairwise agreement guarantees unanimous agreement. The punchline is a theorem about *combining* spaces:

> **A product of two partial cubes has the opposite-semicube Helly property if and only if each of the two factors is harmonic-even.**

To unpack that sentence, we need to meet the cast of characters.

## Cubes, and their imperfect cousins

Start with the humble cube. The three-dimensional cube has $8$ corners, and we can label each corner by a string of three bits — $000$, $001$, $\dots$, $111$ — where two corners are joined by an edge exactly when their labels differ in a single bit. This picture generalizes to any dimension $n$: the **hypercube** $Q_n$ has $2^n$ vertices, all binary strings of length $n$, with edges between strings that differ in one coordinate. The distance between two vertices — the fewest edges you must traverse to get from one to the other — is just the number of positions in which their labels disagree, the *Hamming distance*.

Hypercubes are perfectly symmetric and perfectly understood. The interesting spaces are their *subgraphs* that inherit the same distances. A **partial cube** is a graph that can be drawn inside some hypercube using only *some* of the corners, in such a way that the walking distance inside the smaller graph always equals the Hamming distance of the labels. Formally, a partial cube is a graph that embeds **isometrically** into a hypercube.

Partial cubes are everywhere once you know to look for them:

- **Trees** (networks with no loops) are partial cubes.
- **Grids** and their higher-dimensional analogues are partial cubes.
- **Even cycles** — rings with an even number of nodes — are partial cubes.
- The **flip graphs** of triangulations, the **linear-extension graphs** of partial orders, and the state spaces of many combinatorial reconfiguration puzzles are all partial cubes.

What makes a partial cube more than an arbitrary graph is a hidden coordinate system, discovered through a beautiful relation on its edges.

## Cutting a partial cube: theta-classes and semicubes

Because a partial cube sits inside a hypercube, every edge corresponds to flipping exactly one coordinate. Group together all the edges that flip *the same* coordinate: this grouping is called a **theta-class** (after the Djoković–Winkler relation $\Theta$ that detects it intrinsically, without reference to any particular embedding). A partial cube in dimension $n$ has at most $n$ theta-classes, one per coordinate that actually gets used.

Here is the key geometric fact. If you delete all the edges of a single theta-class, the partial cube falls apart into **exactly two** connected pieces. These two pieces are the **opposite semicubes** (or *halfspaces*) of that theta-class. Concretely, one semicube collects all vertices whose label has a $0$ in the chosen coordinate, and the other collects the vertices with a $1$. Every theta-class thus cuts the space cleanly into two complementary halves, like slicing a loaf of bread — and the two slices are what we call *opposite* semicubes.

Semicubes are the natural "halfspaces" of a partial cube, and they are **convex**: the shortest path between any two vertices of a semicube never leaves it. They are the discrete analogue of half-planes in the plane, and it is exactly for such convex halfspaces that a Helly question becomes meaningful.

## The opposite-semicube Helly property

Now we can state the property at the heart of this work. Choose, from various theta-classes, a collection of semicubes — but never take *both* opposite halves of the same class (that would be a contradiction, like insisting a coordinate is simultaneously $0$ and $1$). Such a collection is a family of *compatible* halfspaces, one side chosen per cut.

A partial cube has the **opposite-semicube Helly property** if the following always holds:

> Whenever every **pair** of chosen semicubes overlaps, **all** of them share a common vertex.

In the language of coordinates, a collection of semicubes is a partial specification "coordinate $i$ should be $b_i$" for some subset of coordinates. Pairwise overlap means every *two* of these demands can be met simultaneously by some vertex of the space; the Helly property demands that *all* of them can be met at once. It is exactly the committee-scheduling question, transplanted onto the geometry of a partial cube.

Not every partial cube passes this test. Consider the six-cycle $C_6$ — a ring of six vertices, which is a partial cube with three theta-classes (three "diameters" of the hexagon). Each semicube is an arc of three consecutive vertices. One can choose one arc from each of the three diameters so that the arcs overlap two-at-a-time but no single vertex lies in all three — the hexagon is the committee that cannot meet. So $C_6$ fails the opposite-semicube Helly property. By contrast, the square $C_4$ (which is just $Q_2$) passes it easily, and so does every tree and every full hypercube.

## Harmonic-even partial cubes

What separates the winners from the losers? The answer is a local balance condition on the cuts, which we name **harmonic-even**.

The condition can be phrased in a single, memorable line by looking at *triples*:

> A partial cube is **harmonic-even** when any three of its semicubes that overlap pairwise already share a common vertex.

At first this looks like it only controls families of size three, not families of every size. The magic — and the first main result — is that size three is *enough*.

> **Reduction Theorem (Helly number two).** In a partial cube, if every three pairwise-overlapping semicubes have a common vertex, then every finite family of pairwise-overlapping semicubes has a common vertex.

The proof is a clean induction that leans on the convexity of semicubes: convex sets in a partial cube behave enough like convex sets in Euclidean space that once you can always "patch three together," you can patch any number together, two at a time. Consequently, *harmonic-even* and *satisfies the opposite-semicube Helly property* are one and the same condition for a single partial cube. The name **harmonic-even** captures the flavor of the balance involved: across each pair of cuts, the way one cut distributes across the two sides of another is symmetric ("harmonic," equal-ratio) and consistent in parity ("even").

Trees are harmonic-even. Hypercubes are harmonic-even. The square is harmonic-even. The hexagon is not. Harmonic-evenness is precisely the geometric fingerprint of spaces where pairwise agreement is as good as unanimous agreement.

## Building bigger spaces: the product

Mathematics loves to build large objects out of small ones, and the natural way to combine two partial cubes $G$ and $H$ is the **Cartesian product** $G \,\square\, H$. Its vertices are all pairs $(g, h)$ with $g$ a vertex of $G$ and $h$ a vertex of $H$; you may take one step in the $G$-coordinate *or* one step in the $H$-coordinate, but not both at once. If $G$ is a length-$3$ path and $H$ is a length-$2$ path, then $G \,\square\, H$ is a $3 \times 2$ grid. The product of two partial cubes is again a partial cube, and — crucially — its coordinate system is simply the two coordinate systems laid side by side.

This is the structural lemma that makes everything work:

> **Product structure of cuts.** The theta-classes of $G \,\square\, H$ are the disjoint union of the theta-classes of $G$ and those of $H$. Each semicube of the product is a *cylinder*: either a semicube of $G$ paired with **all** of $H$, or all of $G$ paired with a semicube of $H$.

Because the cuts of the two factors never mix, the geometry of the product decomposes cleanly. A semicube coming from $G$ and a semicube coming from $H$ *always* overlap — their intersection is a full product of two nonempty pieces. So the only way for a family of the product's semicubes to fail the Helly test is for the $G$-part of the family to fail *inside $G$*, or the $H$-part to fail *inside $H$*. This is the geometric engine behind the main theorem.

## The main theorem

Everything now clicks into place.

> **Main Theorem.** Let $G$ and $H$ be partial cubes. Their Cartesian product $G \,\square\, H$ has the opposite-semicube Helly property **if and only if** both $G$ and $H$ are harmonic-even.

Why is it true? Take any family of the product's semicubes that overlaps pairwise. Split it into the cylinders coming from $G$ and those coming from $H$. Cross-pairs (one from each factor) automatically overlap, so pairwise overlap of the whole family means exactly that the $G$-cylinders overlap pairwise *within $G$* and the $H$-cylinders overlap pairwise *within $H$*. If both factors are harmonic-even, each group has a common vertex — say $g^\star$ in $G$ and $h^\star$ in $H$ — and then $(g^\star, h^\star)$ lies in every member of the family. So the product has the Helly property. Conversely, if one factor, say $G$, fails to be harmonic-even, it already hosts a bad family of pairwise-overlapping semicubes with no common vertex; lifting each to its cylinder in the product produces a bad family there. Hence the product's Helly property forces both factors to be harmonic-even.

The theorem is an *exact characterization*: no slack, no side conditions. It says the good behavior of a product is inherited from — and only from — the good behavior of its parts. Harmonic-evenness is a property that "multiplies."

## Why it matters

Beneath the combinatorial packaging lies a genuinely useful principle. Partial cubes model an enormous variety of real structures — evolutionary trees in biology, voting profiles and preference orders in social choice, the state spaces of puzzles and reconfiguration problems in computer science. In each of these, a semicube is a natural yes/no split of the world, and the Helly property is the promise that *consistency checked in pairs is consistency overall* — a promise that makes many algorithms fast and many arguments possible.

The main theorem tells engineers of such spaces something practical: if you assemble a complex configuration space as a product of simpler independent components, then the whole inherits this "pairwise-implies-global" consistency exactly when each component has it. You never have to re-examine the assembled giant; you certify the pieces. And certifying a piece reduces, thanks to the Reduction Theorem, to checking a condition on *triples* of halfspaces — a small, local, finite test.

There is also a pleasing aesthetic lesson. The failure of the hexagon and the success of the square are not accidents of size but of *balance*. Harmonic-evenness names that balance and shows it to be the whole story. And because the cuts of a product line up so cleanly, the balance survives combination — a rare and satisfying kind of stability.

## Looking outward

The two-factor theorem is the doorway to a wider landscape. If harmonic-evenness multiplies across two factors, does it multiply across any number of them — so that a $d$-fold product of partial cubes is Helly exactly when every factor is harmonic-even, with a "Helly number" that does not grow with $d$? The disjoint-union structure of the cuts strongly suggests yes. One can also ask which *operations* on partial cubes preserve harmonic-evenness — isometric gluing, expansion, contraction — and whether every harmonic-even space can be built up from the simplest ones by such moves. These questions turn a single clean characterization into a program: to chart the entire universe of spaces in which local agreement is as good as global agreement.

For now, the moral is a compact and beautiful one. Pairwise agreement becomes unanimous agreement exactly when the space is *balanced* — and balance, unlike so many delicate properties, is faithfully passed on from parts to whole.
