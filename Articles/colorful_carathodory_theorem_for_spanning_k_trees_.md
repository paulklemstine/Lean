# The Rainbow in the Haystack: Finding a Point-Capturing Simplex Without Searching Everything

## A colorful promise

Imagine you are handed several bags of colored marbles scattered across a
tabletop. The red marbles are strewn about, the blue marbles too, the green
marbles as well. You are told one thing: within *each single color*, the marbles
surround a particular spot on the table — say, a small coin lying at the origin.
More precisely, the coin sits inside the convex hull of the red marbles, inside
the convex hull of the blue marbles, and inside the convex hull of the green
marbles.

Now comes the surprising promise. You can pick out just *one* marble of each
color — one red, one blue, one green — so that the triangle they form still
contains the coin. A single "rainbow" triangle, one vertex per color, captures
the target.

This is the **colorful Carathéodory theorem**, discovered by Imre Bárány in
1982. In its general form it lives in $d$-dimensional space: given $d+1$ color
classes $V_1, \dots, V_{d+1}$ in $\mathbb{R}^d$, each of whose convex hull
contains a common point $p$, there is always a *rainbow simplex* — one point
chosen from each color — whose convex hull still contains $p$. It is one of the
gems of combinatorial geometry, a colorful strengthening of the classical
theorem of Carathéodory, and it underlies deep results such as Tverberg's
theorem and the First Selection Lemma.

## The catch: an exponential haystack

The theorem *promises* a rainbow simplex exists. But how would you *find* one?

The naive strategy is to try every combination: one red marble times one blue
marble times one green marble. If each color class has $m$ marbles, that is
$m^3$ triangles to check — and in $d$ dimensions, $m^{d+1}$ simplices. This is
the combinatorial object mathematicians call the **join** of the color classes,
written $V_1 * V_2 * \cdots * V_{d+1}$. It has $\prod_i |V_i|$ top-dimensional
faces. The search space is *exponential* in the number of colors.

So we have a beautiful existence guarantee sitting on top of a forbiddingly
large search space. This tension is the heart of our story. The qualitative
theorem says "a needle is in the haystack." The quantitative question — the one
this work answers — is: **how small a haystack do you actually need to keep,
while still guaranteeing the needle is inside it?**

We call the answer the *witness complexity* of the theorem: the size of the
smallest sub-collection of faces you can point to and honestly say, "the
capturing face is somewhere in here."

## Width is what matters

Here is the first key idea. A collection of faces can be enormous in principle,
but if every face is *small* — if it uses only a bounded number of vertices —
then the whole collection cannot be too large.

Suppose all your candidate faces live on a shared ground set of $n$ vertices,
and each face uses at most $m$ of them. We call $m$ the **width** of the
complex. How many such faces can there be? Exactly the number of subsets of an
$n$-element set with at most $m$ elements:

$$
\sum_{i=0}^{m} \binom{n}{i}.
$$

This is a clean, exact count. And crucially, it is a **polynomial in $n$ of
degree $m$** — not exponential. To make the polynomial nature completely
transparent, one can bound it by an explicit expression:

$$
\sum_{i=0}^{m} \binom{n}{i} \;\le\; (m+1)\,(n+1)^{m}.
$$

The proof is a two-line calculation: each binomial coefficient $\binom{n}{i}$
with $i \le m$ is at most $(n+1)^m$, and there are $m+1$ terms in the sum.

Why does this matter for colorful Carathéodory? Because the capturing simplex we
seek has at most $d+1$ vertices — one per color. Its *dimension* is $d$, its
*width* is $d+1$. So any collection of candidate faces that certifies the
theorem needs faces of width only $d+1$. If we can pre-commit to a modestly
sized family of such small faces, the exponential join evaporates and we are
left with a polynomial-size witness.

## Spanning $k$-trees: the shape of a good witness

The right structures for these witnesses are called **spanning $k$-trees**.
A spanning $k$-tree is a $d$-dimensional simplicial complex that touches every
vertex of the ground set (it *spans*), whose faces have at most $k+1$ vertices,
and which is assembled without redundant cycles. The parameter $k$ is exactly
the *width minus one*: a spanning $1$-tree is an ordinary spanning tree of a
graph, a spanning $2$-tree involves triangles, and so on.

Plugging $m = k+1$ into the count above gives the headline result:

> **Polynomial witness theorem.** A spanning $k$-tree on $n$ vertices has at
> most
> $$ (k+2)\,(n+1)^{k+1} $$
> faces — a polynomial in $n$ of degree $k+1$.

So the size of the certificate you must keep is controlled entirely by the
width parameter $k$. Low width means low polynomial degree means a small
witness. The exponential join is never needed; a polynomial slice of it
suffices.

## The magic of $k = 1$: trees collapse to linear size

Now for the most striking twist. When $k = 1$ — when the witnessing structure is
an ordinary **spanning tree** — something better than the generic bound happens.

A width-$2$ complex in general could have on the order of $n^2$ faces, because
there are $\binom{n}{2} \approx n^2/2$ possible edges. But a spanning tree is not
just any width-$2$ complex: it is *acyclic*. And acyclicity is a powerful
constraint. A spanning tree on $n$ vertices has exactly $n-1$ edges — never more,
no matter how the vertices are arranged.

Count the faces of a tree's clique complex: there is the empty face ($1$), the
$n$ vertices themselves ($n$), and the $n-1$ edges. Total:

$$
1 + n + (n-1) = 2n.
$$

Exactly $2n$ faces. **Linear**, not quadratic. The quadratic edge term collapses
because a tree simply cannot afford $\binom{n}{2}$ edges — it is forced down to
$n-1$ by the ban on cycles.

This reveals a beautiful principle: *witness size is governed by two
independent levers*. The first is **width** ($k$), which sets the degree of the
polynomial. The second is **global acyclicity**, a structural property that, at
$k=1$, actively collapses the polynomial down to linear. Structure, not merely
width, buys the improvement.

## Catching the point on the line

Bounds on witness size are only interesting if there is genuinely a captured
face to witness. To see the convex geometry in its purest form, consider the
one-dimensional case, $d = 1$: two color classes $V_1, V_2$ of points on a
number line, each of whose convex hull contains the origin.

What does "the convex hull contains $0$" mean for a finite set of real numbers?
It means $0$ lies between the smallest and largest points of the set. So if $0$
is captured by $V_1$, then $V_1$ must contain at least one number $\le 0$ and at
least one number $\ge 0$ — you cannot straddle the origin using only positive
numbers, or only negative ones. This is the **sign-extraction** principle, and
it is the honest convex-geometric heart of the matter.

Now the rainbow edge falls out immediately. From $V_1$, extract a nonpositive
point $x \le 0$. From $V_2$, extract a nonnegative point $y \ge 0$. The segment
from $x$ to $y$ passes straight through the origin. In fact, the origin is the
explicit convex combination

$$
0 = \frac{y}{y-x}\,x + \frac{-x}{y-x}\,y
$$

(when $x < 0 < y$; the degenerate cases where $x$ or $y$ is itself $0$ are even
simpler). So $\{x, y\}$ is a rainbow edge — one vertex from each color — whose
convex hull contains the target. The abstract promise becomes a concrete
segment you can draw.

## Putting it together

The two halves lock together into a single satisfying statement. On the line,
colorful Carathéodory always produces a rainbow edge through the origin — a
single edge of the join $V_1 * V_2$. And *any* width-$2$ family of candidate
edges on $n$ vertices contains at most $3(n+1)^2$ faces, dropping to a mere $2n$
when that family is organized as a spanning tree. The needle is guaranteed to
sit inside a haystack you can carry in one hand.

More broadly, for the $d$-dimensional theorem the capturing simplex has width
$d+1$, so a spanning $(d)$-tree witness has polynomial size of degree $d+1$ —
never the exponential $\prod_i |V_i|$ of the full join.

## Why it resonates

The lesson here reaches beyond one theorem. Combinatorial geometry is full of
*existence* results — Helly, Radon, Tverberg, the ham-sandwich theorem — that
guarantee some configuration exists without telling you how to find it
efficiently. The gap between "it exists" and "here it is, cheaply" is where
algorithms are born. Colorful Carathéodory is a linchpin in the fastest known
algorithms for computing *centerpoints* and *Tverberg partitions*, tools that
matter in robust statistics, data depth, and computational geometry.

By identifying width and acyclicity as the two knobs that control witness size,
this work turns a qualitative promise into a quantitative budget. You do not
need to examine every rainbow combination; you need only keep a spanning-tree's
worth of them. In the sparsest and most useful case, that is a *linear* number.

The rainbow is real, and you no longer have to sift the entire haystack to find
it.
