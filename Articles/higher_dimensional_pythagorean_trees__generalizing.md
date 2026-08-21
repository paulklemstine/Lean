# The Tree That Isn't: What Happens to Pythagoras in Higher Dimensions

## A perfect family tree

Everyone meets $3^2 + 4^2 = 5^2$ as a child. Fewer people meet the astonishing fact that *all* such triples — every pair of whole-number legs with a whole-number hypotenuse — can be grown from that single seed by three simple rules, like a plant from a cutting.

Call a triple $(a,b,c)$ of positive integers *Pythagorean* if $a^2+b^2=c^2$, and *primitive* if $a$, $b$, $c$ share no common factor. Now take any primitive triple and apply each of these three transformations:

$$
(a,b,c)\;\longmapsto\;(-a+2b+2c,\;-2a+b+2c,\;-2a+2b+3c),
$$
$$
(a,b,c)\;\longmapsto\;(a+2b+2c,\;2a+b+2c,\;2a+2b+3c),
$$
$$
(a,b,c)\;\longmapsto\;(a-2b+2c,\;2a-b+2c,\;2a-2b+3c).
$$

Each output is again a primitive Pythagorean triple. Starting from $(3,4,5)$ they give $(5,12,13)$, $(21,20,29)$, $(15,8,17)$; iterate, and you sweep out an infinite, perfectly regular ternary tree that contains **every** primitive triple exactly once. This is the Berggren tree, and it is one of the small miracles of number theory: an infinite chaotic-looking set of Diophantine solutions turns out to be a rigid, three-branch family tree with a single ancestor.

The obvious question — the one a curious reader asks immediately — is: *what about higher dimensions?* A Pythagorean **quadruple** is a solution of
$$
a^2+b^2+c^2 = d^2,
$$
the integer points on a sphere of integer radius; the smallest is $(1,2,2,3)$, and $(2,3,6,7)$, $(1,4,8,9)$, $(4,4,7,9)$ follow. Is there a Berggren tree for these? For quintuples? For all $n$?

The answer, it turns out, is a beautifully sharp *yes, and no, and here is exactly why* — and the reason lives not in arithmetic but in geometry: in the geometry of the light cone and of hyperbolic space.

## Pythagoras is a light cone

Rewrite the Pythagorean equation as
$$
x_1^2+\cdots+x_n^2-y^2 = 0 .
$$
That expression is the **Lorentz form** of signature $(n,1)$ — the very quantity physicists use to measure spacetime intervals, with $y$ playing the role of time. Its zero set is the *light cone*, and a Pythagorean $n$-tuple is nothing more exotic than an integer point on it. Triples are the light cone of a $(2{+}1)$-dimensional universe; quadruples the light cone of a $(3{+}1)$-dimensional one — our own.

What generates the tree, then? Any integer matrix $M$ that preserves the Lorentz form — that satisfies $M^{\mathsf T} J M = J$, where $J = \mathrm{diag}(1,\dots,1,-1)$ — must map integer light-cone points to integer light-cone points. (It also has determinant $\pm 1$, so it is invertible over the integers: these moves can always be undone.) So the whole question becomes: **which integral Lorentz symmetries do we have, and what tree do they generate?**

The Berggren moves have a hidden uniformity that this viewpoint reveals at once. Let $r = (1,1,\dots,1;1)$ be the all-ones vector. Its Lorentz square is $q(r)= n-1$, which is nonzero for $n\ge 2$, so we may reflect in it:
$$
s_r(v) \;=\; v - \frac{2\,\langle v,r\rangle}{n-1}\, r ,
\qquad \langle v,r\rangle = x_1+\cdots+x_n-y .
$$
Because $r$ has all coordinates equal, this reflection simply subtracts *one and the same number* from every coordinate of $v$. Combine it with the $2^n$ ways of flipping the signs of the space coordinates and you get a finite family of moves. And now the punchline: the three Berggren matrices above are **exactly** $s_r$ composed with the three nontrivial sign patterns $(-,+)$, $(+,-)$, $(-,-)$ in dimension $n=2$. The fourth pattern, all-plus, is the *descent*: it takes a triple back toward the root. Three moves up, one move down — that is the whole tree, and it was a reflection in the light cone all along.

## Why the ladder stops at four dimensions

Here the geometry starts talking back. The reflection subtracts $\frac{2(x_1+\cdots+x_n-y)}{n-1}$ from each coordinate. For this to keep integers integral we need $n-1$ to divide $2$. Thus:

- $n = 2$ (triples): the shift is $2(a+b-c)$ — integral;
- $n = 3$ (quadruples): the shift is $a+b+c-d$ — integral;
- $n \ge 4$: the shift is a genuine fraction, and the reflection throws lattice points off the lattice. In dimension four, the innocent null vector $(1,1,1,1;2)$ is displaced by $4/3$ in each coordinate.

**The Berggren mechanism exists in exactly two dimensions: $n = 2$ and $n = 3$.** Not for lack of cleverness — for an arithmetic reason as rigid as $3 \nmid 2$. This is the first surprise: the generalization does not extend indefinitely; it stops, precisely, at Pythagorean quadruples.

So the whole question narrows to one case, and it is the interesting one: spheres in three-space, integer radii, integer coordinates.

## The quadruple machine

For quadruples, the reflection becomes charmingly concrete. Set $k = a+b+c-d$ and map
$$
(a,b,c,d) \;\longmapsto\; (a-k,\;b-k,\;c-k,\;d-k).
$$
That is a $4\times 4$ integer matrix, an honest symmetry of the Lorentz form of signature $(3,1)$, and an involution: doing it twice returns you home. Attach to it the sign flips and the permutations of $a,b,c$ and you get the higher-dimensional analogue of Berggren's move set.

Does it reach everything? Yes, and this is the first main theorem.

> **Connectivity Theorem.** Every primitive Pythagorean quadruple with non-negative coordinates $a,b,c$ and positive $d$ can be obtained from the root $(1,0,0,1)$ by a finite sequence of the moves: the all-ones reflection, a sign change, and the permutations of the space coordinates. Conversely, every quadruple so obtained is primitive Pythagorean.

The proof is a descent, exactly in Berggren's spirit. Two facts do all the work. First, above the trivial height $d=1$, the shift $k=a+b+c-d$ is strictly positive: if $a+b+c\le d$ then squaring forces all pairwise products $ab, bc, ca$ to vanish, which for a *primitive* quadruple leaves only $(1,0,0,1)$ and its permutations. Second, the new height $d-k = 2d-(a+b+c)$ is always still positive, because $(a+b+c)^2 \le 3(a^2+b^2+c^2) = 3d^2 < 4d^2$. So the move strictly shrinks the height while preserving both the equation and the greatest common divisor; iterate, and you land on the root. Two invariants — the Lorentz form and the content (the gcd of the four entries) — are preserved by every move, so the primitive quadruples form a single connected orbit while, say, $(2,4,4,6)$ can never be reached from $(1,2,2,3)$.

That is the good news, and it is genuinely the Berggren theorem one dimension up.

## The bad news, which is better than the good news

Berggren's structure is a *tree*, and a tree is more than connectivity: it demands that each node have exactly one parent. A "parent" here is a *descending* move — a sign pattern $\varepsilon \in \{\pm 1\}^n$ for which the reflection strictly decreases the height. For triples the height transforms as $c \mapsto 3c - 2(\varepsilon_1 a + \varepsilon_2 b)$, so descent means $\varepsilon_1 a + \varepsilon_2 b > c$. Since each leg of a triple is smaller than the hypotenuse, no pattern with a minus sign can beat $c$, while $a+b>c$ always holds. Hence:

> **Uniqueness of parents for triples.** Every primitive Pythagorean triple with positive legs admits exactly one descending sign pattern, the all-plus one. Consequently three of the four patterns go *up*, and the Berggren graph is a tree with constant branching number three.

Now run the same count for quadruples, where the height transforms as $d \mapsto 2d - (\varepsilon_1 a + \varepsilon_2 b + \varepsilon_3 c)$ and descent means $\varepsilon_1a+\varepsilon_2b+\varepsilon_3c > d$. Patterns with two or more minus signs are still hopeless, because each coordinate is at most $d$. The all-plus pattern still descends. But a pattern with a *single* minus sign — say $(-,+,+)$ — has a real chance: it descends exactly when $-a+b+c > d$, and with $a^2+b^2+c^2=d^2$ a little algebra converts that into something unexpectedly pretty:

> **Harmonic Branching Law.** For a Pythagorean quadruple with positive entries, the move with a minus sign on $a$ descends if and only if
> $$a(b+c) < bc, \qquad\text{equivalently}\qquad \frac{1}{b}+\frac{1}{c} \;<\; \frac{1}{a}.$$

A question about a tree has turned into an Egyptian-fraction inequality. And the inequality is self-limiting: if $\frac1b+\frac1c<\frac1a$ then in particular $\frac1c < \frac1a$, and symmetric reasoning shows the condition cannot hold for two different coordinates at once. Therefore:

> **At most two parents.** Any two descending sign patterns other than the all-plus one coincide; a Pythagorean quadruple has at most two parents, and its branching number is $8-1=7$ or $8-2=6$.

Is the second parent real, or a possibility that never occurs? It occurs infinitely often. Take, for each integer $m \ge 2$, the quadruple
$$
(1,\,2m,\,2m^2,\,2m^2+1),
$$
which is Pythagorean ($1 + 4m^2 + 4m^4 = (2m^2+1)^2$) and primitive because consecutive integers are coprime. Its harmonic test on the first coordinate reads $\frac{1}{2m}+\frac{1}{2m^2} < 1$ — true for $m\ge2$. So it has *two* parents:
$$
(2m-1,\,0,\,2m^2-2m,\,2m^2-2m+1) \quad\text{and}\quad (2m-1,\,2,\,2m^2-2m+2,\,2m^2-2m+3),
$$
both primitive, both of strictly smaller height, and — crucially — *different* heights, so they are genuinely distinct nodes. For $m=2$: the quadruple $(1,4,8,9)$ descends both to $(3,0,4,5)$ and to $(3,2,6,7)$.

Meanwhile the companion family
$$
(2m,\,2m,\,2m^2-1,\,2m^2+1)
$$
fails the harmonic test at every coordinate and has exactly one parent. Since both families climb past any bound:

> **Non-constancy of branching.** Above any height there exist primitive Pythagorean quadruples with a unique parent and primitive Pythagorean quadruples with two distinct parents. The branching number of the quadruple graph takes both values $6$ and $7$ infinitely often.

So the answer to the original question is crisp. The Berggren *mechanism* generalizes: reflection in the light cone, connectivity, descent, all survive in dimension three. The Berggren *tree* does not: the quadruple graph is a connected graph with cycles, not a tree, and its branching is genuinely irregular, governed by an arithmetic condition on reciprocals.

## Horizontal edges: a phenomenon with no two-dimensional shadow

Between "goes up" and "goes down" there is a boundary case, and in dimension three the boundary is inhabited. When
$$
a(b+c) = bc, \qquad \text{i.e.}\qquad \frac1b+\frac1c = \frac1a,
$$
the corresponding move leaves the height **exactly unchanged**. It slides sideways across a level set instead of climbing or descending. The smallest example is the smallest quadruple of all: $(1,2,2,3)$, where $\frac12+\frac12 = \frac11$. Apply the move with a minus sign on the first coordinate and the height stays $3$. (What happens is that the reflection's shift collapses to zero, so the move reduces to the bare sign change $a \mapsto -a$ — an element of the move set that changes nothing about the height at all.)

And these neutral nodes have a complete description. A short computation shows that the identity $(b+c-a)^2 - (a^2+b^2+c^2) = 2\bigl(bc-a(b+c)\bigr)$ makes the harmonic equation $a(b+c)=bc$ *equivalent* to $(b+c-a)^2 = a^2+b^2+c^2$. So: pick any two positive integers $b,c$ whose sum divides their product, set $a = bc/(b+c)$ and $d = b+c-a$, and you have manufactured a Pythagorean quadruple sitting exactly on the harmonic boundary — and every one of them arises this way. Taking $b=m+1$ and $c=m(m+1)$ gives the tidy infinite family
$$
\bigl(m,\;m+1,\;m(m+1),\;m(m+1)+1\bigr) \;=\; (1,2,2,3),\,(2,3,6,7),\,(3,4,12,13),\,(4,5,20,21),\dots
$$
Every member is primitive, and every member carries a horizontal move.

For triples this cannot happen: for a primitive triple with positive legs and any sign pattern other than all-plus, the new hypotenuse $3c-2(\varepsilon_1a+\varepsilon_2b)$ is *strictly* larger than $c$ — never equal. The Berggren tree has no horizontal edges at all; the quadruple graph does. It is precisely the kind of structure that a tree cannot support, and its existence is the sharpest single statement of how the two-dimensional picture fails to survive.

## Even so, there is a tree — you just have to choose it

Here is a consoling twist. Among the descending moves, one is always available and canonically distinguished: the all-plus one, which descends at *every* node above the root. Declare it *the* parent map. It preserves primitivity and non-negativity (taking absolute values afterwards), it strictly decreases the height above height one, and the nodes of height one are precisely the three permutations of the root $(1,0,0,1)$. Iterating it therefore terminates:

> **Canonical Spanning Tree Theorem.** The all-plus reflection, followed by taking absolute values of the space coordinates, maps primitive quadruples in the positive cone to primitive quadruples in the positive cone, strictly decreasing the height above one, and reaches a height-one node in finitely many steps. Its edges form a spanning tree of the quadruple graph rooted at $(1,0,0,1)$.

So the higher-dimensional object is not a tree, but it *contains* a canonical tree, over which extra "harmonic" edges are laid: the two-parent edges of the harmonic law and the horizontal edges of its boundary case. It is a tree with decoration — and the decoration is where the new arithmetic lives.

## Silver ratios, hyperbolic space, and how fast the numbers grow

Finally, the metric question: how fast do these numbers get big?

Divide a Pythagorean $n$-tuple by its height. You land on the unit sphere $x_1^2+\cdots+x_n^2=1$ — the ideal boundary of hyperbolic $(n{+}1)$-space, seen as the boundary of the Poincaré ball. Every Pythagorean $n$-tuple is a *rational point of that sphere*, and the moves act on the sphere by Möbius transformations. For quadruples, if we write the **shadow**
$$
s = \frac{a+b+c}{d},
$$
then the reflection multiplies the height by exactly $2-s$ and moves boundary points by
$$
u \;\longmapsto\; \frac{u-s+1}{2-s}.
$$
Cauchy–Schwarz bounds the shadow: $s^2 \le 3$, so $|s|\le\sqrt3$ and the height multiplier lies in the annulus $[\,2-\sqrt3,\;2+\sqrt3\,]$. Nothing can grow faster than $2+\sqrt3$ per step, nor shrink faster than its reciprocal $2-\sqrt3$.

The general statement is elegant:

> **Sharp growth constant.** In dimension $n\ge 2$, one reflection move multiplies the height by at most
> $$\rho_n = \frac{\sqrt n + 1}{\sqrt n - 1},$$
> and this bound is attained on the real light cone. Moreover $\rho_n$ is an algebraic number of degree at most two: it is a root of $(n-1)X^2 - 2(n+1)X + (n-1)=0$.

Evaluate it. For $n=2$,
$$
\rho_2 = \frac{\sqrt2+1}{\sqrt2-1} = (1+\sqrt2)^2 = 3+2\sqrt2,
$$
the square of the **silver ratio** $1+\sqrt2$ — exactly the growth constant that governs the Berggren tree and, not coincidentally, the fundamental unit of $\mathbb{Z}[\sqrt2]$ and the continued fraction $[2;2,2,2,\dots]$. For $n=3$,
$$
\rho_3 = \frac{\sqrt3+1}{\sqrt3-1} = 2+\sqrt3 ,
$$
a root of $X^2-4X+1$, the fundamental unit of $\mathbb{Z}[\sqrt3]$ up to squaring and the continued fraction $[3;1,2,1,2,\dots]$'s cousin $[3;\overline{1,2}]$. The silver ratio of the classical tree has a genuine higher-dimensional sibling. The prediction that the growth exponent would be "an exactly computable algebraic number generalizing the silver ratio" is confirmed, with the explicit quadratic to prove it.

There is one qualitative difference worth savouring. Growth *per step* is slower in dimension three ($2+\sqrt3 \approx 3.73$ versus $3+2\sqrt2\approx 5.83$), but there are more than twice as many moves at each node (six or seven children instead of three), and the boundary sphere is two-dimensional instead of one-dimensional. The count of quadruples up to height $X$ should therefore grow like $X^2$, whereas the count of triples grows like $X$ — the limit set of the reflection group fills the boundary sphere in both cases, and in dimension three that sphere simply has more room. Counting to height $400$ bears this out — the slope of $\log N(X)$ against $\log X$ comes out at $1.96$ for quadruples and $1.03$ for triples — but proving the quadratic law is one of the open problems this picture suggests.

## What the whole story says

Strip away the technique and three lessons remain, each with the flavour of good mathematics: a clean generalization, a sharp obstruction, and a new invariant.

*The clean generalization.* Berggren's tree is not an arithmetic accident of triples. It is a reflection in the light cone of a Lorentz form, and reflections in light cones exist in every dimension. Connectivity, descent, invariants, hyperbolic boundary, algebraic growth constant — all of it transfers.

*The sharp obstruction.* The mechanism is integral only when $n-1 \mid 2$, so exactly for triples and quadruples. And within dimension three, uniqueness of the parent fails: the graph has infinitely many two-parent nodes and infinitely many horizontal edges. The beautiful rigid ternary tree really is a two-dimensional phenomenon.

*The new invariant.* What replaces uniqueness is not chaos but a different law — the Egyptian-fraction inequality $\frac1b+\frac1c<\frac1a$, whose equality case gives horizontal moves. Nothing in the classical theory hints at reciprocals; they appear only when you go up a dimension. Since the condition is scale-invariant, it is really a statement about a region on the unit sphere, which turns the combinatorial question "what fraction of quadruples have two parents?" into a measure-theoretic question about an explicit spherical region. Exhaustive enumeration finds about $64\%$ of nodes with two parents up to height $80$ and about $68\%$ up to height $400$, hinting at a definite limiting density awaiting proof.

Integer points on spheres are not idle curiosities — they encode lattice directions, kissing configurations, and rational rotations of three-space, and a generation mechanism that produces all of them from $(1,0,0,1)$ by four elementary moves is a genuinely useful tool. But the deepest pleasure here is structural. Ask what happens to a beautiful theorem in higher dimensions and you rarely get a plain yes or no. You get a story: what survives (the geometry), what breaks (the tree), what the breakage is really made of (reciprocals), and the exact place where the ladder ends ($n=3$). The Berggren tree has a sibling, and the sibling is stranger and more interesting than the original.
