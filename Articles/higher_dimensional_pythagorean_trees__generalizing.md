# The Tree That Grew a Dimension

## How a 2000-year-old equation branches out into higher space

### A tree made of triangles

Every right triangle with whole-number sides hides inside a tree.

That sentence would have delighted the ancients, and it is literally true. Start with the smallest such triangle, $(3,4,5)$. Apply three simple recipes — three fixed $3\times 3$ matrices of integers — and out come $(5,12,13)$, $(21,20,29)$, and $(15,8,17)$. Apply the same three recipes to each of those, and you get nine more. Keep going forever, and you obtain **every** primitive Pythagorean triple exactly once: an infinite, perfectly regular ternary tree, discovered by Berggren in 1934 and rediscovered many times since.

It is one of the tidiest facts in elementary number theory. Every node has exactly three children and exactly one parent. Nothing is missed, nothing is repeated. The tree is a machine that manufactures right triangles.

But why *three*? Where does the ternary structure come from? And — the question that motivates everything below — what happens if we leave the plane?

### The equation that lives on a light cone

The secret of Berggren's tree is that $a^2 + b^2 = c^2$ is not really a statement about triangles. It is a statement about **light**.

Physicists write the geometry of spacetime with a quadratic form that has one minus sign:
$$Q(x_1,\dots,x_n,y) = x_1^2 + \cdots + x_n^2 - y^2 .$$
The set of vectors with $Q = 0$ is the *null cone* — in relativity, the set of directions light can travel. A Pythagorean triple $(a,b,c)$ is exactly an integer point on the null cone of the three-dimensional Lorentz form $x_1^2 + x_2^2 - y^2$. A Pythagorean *quadruple* $(a,b,c,d)$ with $a^2+b^2+c^2=d^2$ — the integer edge-lengths of a rectangular box with whole-number diagonal — is an integer point on the null cone one dimension up. And in general, a **primitive Pythagorean $n$-tuple** is a solution of
$$x_1^2 + x_2^2 + \cdots + x_n^2 = y^2$$
in positive integers with no common factor.

Once you see the cone, the three Berggren recipes stop being magic. They are **reflections**: symmetries of the Lorentz form that happen to have integer entries, so they map integer points on the cone to integer points on the cone. Concretely, fix a pattern of signs $\varepsilon = (\varepsilon_1,\dots,\varepsilon_n)$, each $\varepsilon_i = \pm 1$. There is a reflection $R_\varepsilon$ acting on a null vector $(x; y)$ by
$$k = \varepsilon\!\cdot\! x - y, \qquad R_\varepsilon(x;y) = (x_1 - \varepsilon_1 k,\ \dots,\ x_n - \varepsilon_n k;\ y - k).$$
Everything about the tree is encoded in one number: the new height is
$$y \longmapsto 2y - \varepsilon\!\cdot\! x .$$
If $\varepsilon\cdot x < y$, the move makes the tuple **bigger** — it is a *child move*. If $\varepsilon\cdot x > y$, it makes it **smaller** — a *descent*, a step toward the root. And if $\varepsilon\cdot x = y$ exactly, the move does nothing at all: the reflection **fixes** the node.

For $n = 2$ there are $2^2 = 4$ sign patterns. Since $a + b > c$ for any right triangle (the triangle inequality!), the all-plus pattern always descends, and one can show the other three always ascend. Three children, one parent. *That is Berggren's tree, and that is why it is ternary.* The number 3 was never about triangles; it was $2^2 - 1$.

So: what is $2^3 - {}$ something? What does the tree look like for boxes instead of rectangles?

### The descent complex

Here is the organizing idea. A sign pattern is the same thing as the set $S$ of coordinates carrying a minus sign. So the collection of *descending* patterns at a node is a **family of subsets** of $\{1,\dots,n\}$. Call it the **descent complex** of the node. Its size, minus a correction for the neutral patterns, is exactly the number of parents; $2^n$ minus its size (with neutrals) is exactly the number of children. Everything about branching becomes combinatorics of a set system.

Writing $\varepsilon\cdot x = \sum_i x_i - 2\sum_{i \in S} x_i$ makes two facts immediate.

**Downward Closure Theorem.** *If a sign pattern descends, so does every pattern obtained by turning some of its minus signs back into plus signs. Equivalently, the descent complex is downward closed: it is an abstract simplicial complex on the coordinate set.*

Adding a coordinate to $S$ only decreases $\varepsilon\cdot x$ (the coordinates are non-negative), so descending is hardest for large $S$ — hence the faces of the complex are the *small* sets. That already smells like geometry: we have a simplicial complex attached to every integer point of a light cone.

How big can its faces be? This is where the Pythagorean relation itself intervenes.

**Dimension Bound Theorem.** *Let $x_1^2+\cdots+x_n^2 = y^2$ with all $x_i \ge 0$ and $y \ge 0$. If the sign set $S$ descends, then its complement has at least two elements:*
$$\#S \le n-2 .$$

The proof is a one-liner once you see it. Descending means $\sum_{i \notin S} x_i - \sum_{i\in S} x_i > y$, so in particular $\sum_{i \notin S} x_i > y$. But no single coordinate can exceed the height — $x_j^2 \le \sum_i x_i^2 = y^2$ — and the empty sum is $0 \le y$. So a set of coordinates whose sum beats the height must contain at least **two** indices. That's it. The Pythagorean relation, through the utterly elementary fact that each leg is shorter than the hypotenuse, caps the dimension of the descent complex.

There is a sharper version, and it is the one that decides the shape of the quadruple tree:

**Disjoint Faces Theorem.** *If $S$ and $T$ are disjoint descending sets, then $\#(S \cup T)^c \ge 2$ as well.*

In dimension three this has a startling consequence. Two distinct singletons $\{i\}$ and $\{j\}$ are disjoint, and their union has complement of size $1$, contradicting the theorem. Hence:

**Unique Descent Theorem (dimension three).** *A Pythagorean quadruple admits at most one descending single sign flip.*

### Six or seven

Now count. In dimension three there are $2^3 = 8$ sign patterns. The all-plus pattern always fails to raise the height (because $a+b+c > d$ always, and $a+b+c \geq d$ suffices). By the Unique Descent Theorem, at most one further pattern — necessarily a single flip — can fail to raise the height. So a node has one or two non-children, and therefore:

**Exact Branching Theorem (dimension three).** *Every Pythagorean quadruple with positive coordinates has exactly $6$ or exactly $7$ children. It has $6$ precisely when one of the three single flips fails to raise the height, i.e. when*
$$d \le -a+b+c \quad\text{or}\quad d \le a-b+c \quad\text{or}\quad d \le a+b-c,$$
*and this condition is equivalent to the "harmonic" (Egyptian-fraction) inequality*
$$a(b+c) \le bc \quad\text{or}\quad b(a+c) \le ac \quad\text{or}\quad c(a+b) \le ab,$$
*that is,* $\tfrac1b + \tfrac1c \le \tfrac1a$ *or one of its permutations.*

That equivalence is the heart of the matter, and it is a genuinely surprising bridge: whether a node of the quadruple graph has six or seven children is decided not by its size, not by its congruence class, but by an inequality between the *reciprocals* of its space coordinates — the same kind of inequality that governs Egyptian fractions and Diophantine "unit fraction" problems.

And both cases really happen, infinitely often. The quadruples
$$(1,\; 2m,\; 2m^2,\; 2m^2+1) \qquad (m \ge 2)$$
satisfy $1\cdot(2m+2m^2) \le 2m\cdot 2m^2$, so they always have **six** children. The quadruples
$$(2m,\; 2m,\; 2m^2-1,\; 2m^2+1) \qquad (m \ge 2)$$
— which one checks are primitive, since a common divisor would divide the difference $2$ of the last two coordinates yet both are odd — have **seven**.

So here is the answer to our question, and it is not the one a naive analogy predicts. **The higher-dimensional Pythagorean graph is not a regular tree.** The beautiful ternary regularity of Berggren's tree does not survive the passage to boxes. What survives is something arguably better: an exact, arithmetic *rule* for the irregularity.

The mismatch is not chaos, though. Branching is bounded below in every dimension:

**Universal Branching Bound.** *For every $n \ge 2$, a node with positive coordinates has at least $n+1$ children.*

Proof: by the Dimension Bound, any pattern whose minus-set has $\ge n-1$ elements cannot descend or stay neutral, so it must be a child; there are exactly $n+1$ such patterns (the full set and the $n$ sets missing one coordinate). For $n=2$ this gives $3$ — and the true value *is* $3$. **Berggren's tree is the minimally branching member of the family**, and its regularity is exactly the statement that in dimension two the descent complex has room for nothing but the empty face.

### Dimension four: the complex acquires edges

If the descent complex can only be a point-plus-vertex in dimension three, can it get genuinely two-dimensional? The Dimension Bound allows faces of size $n-2$; is that sharp?

In dimension four the answer is yes, and the proof runs through Pell's equation. Consider the quintuples
$$(1,\,1,\,t,\,t\,;\,d), \qquad 1+1+t^2+t^2 = d^2, \text{ i.e. } d^2 - 2t^2 = 2 .$$
Solutions are generated from $(t,d) = (1,2)$ by the automorphism $(t,d) \mapsto (3t+2d,\, 4t+3d)$ of the form $d^2 - 2t^2$, giving $(1,2), (7,10), (41,58), (239,338), \dots$ — a Pell ladder marching to infinity. For $t \ge 4$ the two-element sign set $S = \{1,2\}$ *descends*:
$$-1-1+t+t = 2t-2 > d \iff (2t-2)^2 > 2t^2+2 \iff t^2-4t+1 > 0 .$$
These quintuples are obviously primitive (they contain a $1$). So:

**Sharpness in Dimension Four.** *There are arbitrarily large primitive Pythagorean quintuples whose descent complex contains a two-element face — a parent reached by flipping two signs at once. The bound $\#S \le n-2$ is attained for $n=4$.*

Two-element faces are *impossible* in dimension three. So the geometry genuinely thickens with the dimension: the higher trees have parents of higher and higher "codimension", and the descent complex, trivial for triangles and zero-dimensional for boxes, starts to have edges at $n=4$.

### How fast does the tree grow?

The light cone is not just an algebraic object. Its projectivization is **hyperbolic space**: the null cone of the $(n+1)$-dimensional Lorentz form, projectivized, is the boundary sphere of the $(n+1)$-dimensional hyperbolic ball, and the integral Lorentz group acts by hyperbolic isometries. The height $y$ of a null vector is (up to normalization) an exponentiated Busemann function — a hyperbolic "distance from the centre". So each reflection move translates a node by a definite hyperbolic distance, and asking how fast the tree grows becomes a question about a *discrete group acting on hyperbolic space*.

One move multiplies the height by at most
$$\rho_n = \frac{\sqrt{n}+1}{\sqrt{n}-1},$$
a bound that is sharp on the real cone, attained at the symmetric point $x_1 = \cdots = x_n = y/\sqrt n$. Two of these numbers are old friends:
$$\rho_2 = 3 + 2\sqrt2 = (1+\sqrt2)^2, \qquad \rho_3 = 2+\sqrt3 .$$
The first is the square of the **silver ratio** — the classical growth constant of the Berggren tree. The second is its dimension-three replacement, and it is not an arbitrary algebraic number:

**Fundamental Unit Theorem.** *Both constants are units of norm one in real quadratic orders: $(2+\sqrt3)(2-\sqrt3) = 1$ and $(3+2\sqrt2)(3-2\sqrt2)=1$. Moreover $2+\sqrt3$ is the smallest unit greater than $1$ with positive coordinates in $\mathbb{Z}[\sqrt3]$ — it is the fundamental unit. So $\log(2+\sqrt3)$ is the exact analogue for boxes of the silver-ratio exponent $\log(1+\sqrt2)$ for triangles.*

Two further facts complete the picture, and they pull in opposite directions.

First, **higher dimensions move slower**: $\rho_n$ is strictly decreasing in $n$ and tends to $1$ as $n \to \infty$, since $\rho_n = 1 + 2/(\sqrt n - 1)$. Each reflection displaces a node by less and less hyperbolic distance.

Second, **higher dimensions branch more**: from $3$ children to at least $6$.

Which effect wins? The natural referee is the **critical exponent**, the number $\delta$ with $k = \rho^\delta$, i.e.
$$\delta = \frac{\log k}{\log \rho},$$
measuring how many nodes appear per unit of hyperbolic displacement — the discrete-group invariant that controls the Hausdorff dimension of the limit set and the convergence of the Poincaré series.

**Growth Exponent Theorem.** *The Berggren tree has critical exponent $\log 3/\log(3+2\sqrt2) \approx 0.623 < 1$, while the quadruple graph has critical exponent at least $\log 6/\log(2+\sqrt3) \approx 1.361 > 1$. In particular the exponent crosses the value $1$ between dimension two and dimension three: the quadruple graph grows strictly faster than the Berggren tree.*

The extra branching more than compensates for the shorter steps. Boxes are richer than rectangles, and by a computable margin.

There is a delicate footnote. The constant $2+\sqrt3$ is sharp only over the *reals*. On the integer tree it is never attained:

**Strict Integral Growth.** *For every integral Pythagorean quadruple with non-negative coordinates and positive height, $a+b+c < \sqrt3\,d$ strictly, and hence every reflection move satisfies $d' < (2+\sqrt3)\,d$.*

The obstruction is pure irrationality: equality would force $a=b=c$ and $3a^2 = d^2$, impossible for $a \ne 0$ because $\sqrt3$ is irrational. So the growth constant is an unattained supremum — the integer tree presses against a wall built out of an irrational number, forever approaching, never touching.

### Mirrors, and a divisor law

The last surprise concerns the patterns that do nothing at all. In dimension two, no reflection ever fixes a node: $\varepsilon\cdot x = y$ has no solutions among triples, and the group acts freely. In dimension three it does happen. The quadruple $(1,2,2,3)$ satisfies $-1+2+2 = 3$, so the reflection with a minus on the first coordinate leaves it exactly where it is.

**Mirror Node Theorem.** *A reflection $R_\varepsilon$ fixes a node precisely when its sign pattern is height-neutral, $\varepsilon \cdot x = y$. Such nodes are exactly the lattice points lying on the mirror hyperplanes of the reflection group, and no node with positive coordinates lies on two different mirrors: apart from the all-plus generator, at most one generator can fix it. Stabilizers are therefore cyclic of order two.*

These mirror nodes are the dimension-three replacement for the "star lines" of the planar theory, and there are infinitely many. The family
$$\bigl(m,\; m+1,\; m(m+1),\; m^2+m+1\bigr)$$
consists of primitive Pythagorean quadruples — primitive because any common divisor divides both $m$ and $m+1$ — each fixed by the reflection that flips the first coordinate, and each having exactly six children. (The example $(1,2,2,3)$ is the case $m=1$.) So mirror nodes are always of the *deficient*, six-fold type: sitting on a mirror costs you a child.

And they obey an exact counting law. Suppose $-a+b+c = d$ and $a^2+b^2+c^2=d^2$. Put $p = b-a$, $q = c-a$. A two-line computation collapses the quadratic relation to
$$pq = a^2, \qquad (a,b,c,d) = (a,\ a+p,\ a+q,\ a+p+q),$$
and conversely every factorization $pq = a^2$ produces a mirror node. Hence:

**Divisor Law for Mirror Nodes.** *The number of mirror nodes with first coordinate $a$ is exactly $\tau(a^2)$, the number of divisors of $a^2$.*

For $a=2$ there are $\tau(4)=3$ of them: $(2,3,6,7)$, $(2,4,4,6)$, $(2,6,3,7)$. For $a=6$ there are $\tau(36)=9$. Since $\tau(a^2)$ is always odd — divisors of a square pair up except for $a$ itself — every $a$ has an odd number of mirror nodes, the unpaired one being the symmetric $(a, 2a, 2a, 3a)$. This is the higher-dimensional analogue of the arithmetic counting ("totient") laws of the classical planar theory, with the divisor function replacing the totient.

### What it all means

Step back and the shape of the generalization is clear, and it is neither the naive success nor the failure one might have expected.

The Berggren tree does *not* generalize to a regular tree. What generalizes is a whole apparatus:

- a **simplicial complex** — the descent complex — attached to every solution, downward closed and of dimension at most $n-3$;
- a **branching count**, exactly $6$ or $7$ for boxes, decided by an Egyptian-fraction inequality, and bounded below by $n+1$ in general, with the Berggren case realizing the minimum;
- a **hyperbolic embedding** in which each move is a bounded translation, with a sharp constant $\rho_n = (\sqrt n +1)/(\sqrt n -1)$ that is a quadratic unit, the fundamental unit $2+\sqrt3$ of $\mathbb{Z}[\sqrt3]$ when $n=3$;
- a **growth exponent** that increases from dimension two to three, crossing $1$;
- a **mirror geometry** of fixed nodes obeying a divisor law.

Pythagorean quadruples are the integer edge-lengths of boxes with integer diagonals, and they are the same thing as integer points on a light cone in four-dimensional spacetime; they parametrize configurations in sphere-packing and kissing-number problems, appear in the arithmetic of quaternions, and index certain lattice directions used in crystallography and computer graphics. Any algorithm that needs to enumerate them can now do so with a guarantee: start at $(1,2,2,3)$, apply the eight signed reflections, discard the one or two that go down or stand still, and you will fan out through the solution set at a hyperbolic rate whose exponent is $\log 6/\log(2+\sqrt3)$ or better.

Finally, the loveliest part of the story may be how *cheap* the key inequality is. Everything above — the dimension bound, the six-or-seven dichotomy, the uniqueness of the descending flip — rests on a single observation that a schoolchild can verify: **no leg of a right triangle is longer than the hypotenuse**. Push that trivial fact through $n$ dimensions and it becomes a bound on the dimension of a simplicial complex, which becomes a branching law, which becomes a growth exponent for a group acting on hyperbolic space. That is what a good generalization looks like: not a copy of the old theorem, but a reason for it.
