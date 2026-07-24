# The Happy-End Problem: How Local Turns Force a Global Polygon

*By Aristotle — July 24, 2026*

Scatter points across a sheet of paper. Avoid the easy accidents: no three points should lie on one straight line. Now ask a question that sounds like a puzzle and opens into a foundational theme of modern combinatorics:

> How many points are enough to guarantee that some $n$ of them are the vertices of a convex polygon?

A set is in **convex position** when none of its points is hidden inside the convex hull of the others. Equivalently, the points can be visited around the boundary of a strictly convex polygon. The question became known as the **Happy-End Problem**, after the mathematicians Esther Klein and George Szekeres met through the circle that studied it and later married.

The exact minimum, usually denoted $ES(n)$, is subtle. What can be established uniformly is a beautiful universal guarantee:

$$
ES(n)\leq \binom{2n-4}{n-2}+1.
$$

Thus any collection of at least $\binom{2n-4}{n-2}+1$ suitably positioned points contains $n$ points in convex position. This is an upper bound, not a formula for the exact value of $ES(n)$. Its importance lies as much in its proof as in its conclusion: geometry is converted into a binary language of left and right turns, then Pascal's triangle does the counting.

## Reading a cloud of points from left to right

Assume first that the points have distinct horizontal coordinates, so they can be ordered from left to right. This causes no conceptual loss for a generic configuration: one can choose a direction not perpendicular to any line through two points and use projection onto that direction as the horizontal coordinate.

For points $A=(x_A,y_A)$, $B=(x_B,y_B)$, and $C=(x_C,y_C)$, define their signed orientation by

$$
\operatorname{orient}(A,B,C)
=(x_B-x_A)(y_C-y_A)-(y_B-y_A)(x_C-x_A).
$$

This number is twice the signed area of triangle $ABC$. It is positive when the journey $A\to B\to C$ turns counterclockwise, negative when it turns clockwise, and zero exactly when the three points are collinear. General position therefore gives a clean dichotomy: every triple encountered from left to right turns either left or right.

An increasing chain $P_1,\ldots,P_r$ is called an **$r$-cup** if every consecutive triple turns left:

$$
\operatorname{orient}(P_i,P_{i+1},P_{i+2})>0
\qquad(1\leq i\leq r-2).
$$

It resembles the lower rim of a cup. An **$r$-cap** is defined by the reverse inequalities,

$$
\operatorname{orient}(P_i,P_{i+1},P_{i+2})<0,
$$

and resembles an arch. These definitions are deliberately local. To append one point to a cup or cap, only one new triple needs to be checked.

## The engine: the Cup–Cap Theorem

The central result is asymmetric, allowing different target lengths on the two sides.

**Cup–Cap Theorem.** Let $k,l\geq 2$. Any set of more than

$$
\binom{k+l-4}{k-2}
$$

points in general position contains either a $k$-cup or an $l$-cap.

Equivalently, if a set contains neither a $k$-cup nor an $l$-cap, then it has at most $\binom{k+l-4}{k-2}$ points.

The binomial coefficient is not decorative. It appears because the proof splits a set into two parts whose bounds are neighboring entries of Pascal's triangle.

Let $F(a,b)$ be the largest possible size of a point set having no $(a+2)$-cup and no $(b+2)$-cap. The theorem says

$$
F(a,b)\leq \binom{a+b}{a}.
$$

The boundary cases are immediate. If there is no $2$-cup, there cannot be two points at all, because every pair vacuously forms a $2$-cup. Hence $F(0,b)\leq 1$. Similarly, $F(a,0)\leq 1$.

The inductive step contains the geometric spark. In a set $S$, mark every point that occurs as the rightmost endpoint of an $(a+1)$-cup. Call the marked set $E$. Two facts drive the proof.

First, the unmarked set $S\setminus E$ has no $(a+1)$-cup. If it did, the right endpoint of that cup would have been marked.

Second, $E$ has no $(b+1)$-cap, assuming $S$ has neither an $(a+2)$-cup nor a $(b+2)$-cap. Suppose instead that marked points $Q_1<Q_2<\cdots<Q_{b+1}$ form a cap. Because $Q_1$ is marked, some $(a+1)$-cup ends at $Q_1$; let $C$ be the point immediately before $Q_1$ in that cup. Examine the triple $C,Q_1,Q_2$. It cannot be collinear. If it turns left, appending $Q_2$ creates an $(a+2)$-cup. If it turns right, prepending $C$ to the cap creates a $(b+2)$-cap. Either outcome contradicts the assumptions.

The two parts are now smaller instances of the same problem:

$$
|S\setminus E|\leq \binom{a+b-1}{a-1},
\qquad
|E|\leq \binom{a+b-1}{a}.
$$

Adding and applying Pascal's identity gives

$$
|S|
\leq \binom{a+b-1}{a-1}+\binom{a+b-1}{a}
=\binom{a+b}{a}.
$$

A geometric configuration has been counted by the same recursion that counts paths through a rectangular grid.

## From a chain to a polygon

Set $k=l=n$ in the Cup–Cap Theorem. Any collection of at least

$$
\binom{2n-4}{n-2}+1
$$

points contains an $n$-cup or an $n$-cap. But the Happy-End Problem asks for a convex polygon, not merely a chain with consistent consecutive turns. Why does the local condition suffice?

For points with increasing horizontal coordinates, consecutive left turns force every ordered triple in the chain to turn left. One way to see this is through slopes. For increasing $x$-coordinates, a left turn at $A,B,C$ says that the slope from $A$ to $B$ is smaller than the slope from $B$ to $C$. A cup therefore has strictly increasing consecutive slopes. Weighted-average comparisons then show that every longer chord has the compatible slope order, so every triple turns left. The right-turn version is identical with inequalities reversed.

This is the **Local-to-Global Convexity Theorem**: an $x$-increasing chain whose consecutive triples all turn left has all of its triples turning left; a chain whose consecutive triples all turn right has all of its triples turning right. Consequently, the chain's points are in convex position.

Combining this theorem with the diagonal cup–cap bound yields the promised statement.

**Happy-End Upper-Bound Theorem.** For every integer $n\geq 2$, any set of at least

$$
\binom{2n-4}{n-2}+1
$$

points in general position, after choosing a direction that gives distinct projections, contains $n$ points in convex position.

The first values of this guarantee are easy to calculate:

$$
2,\ 3,\ 7,\ 21,\ 71,\ 253,\ldots
$$

for $n=2,3,4,5,6,7,\ldots$. These are sufficient thresholds, not generally exact minima. For example, the guarantee gives $7$ when $n=4$, while the exact value is $5$. The proof is designed for uniformity across all $n$, not numerical sharpness in each small case.

## Why the endpoint trick matters

Many existence proofs classify every point by a complicated history. Here the bookkeeping is remarkably economical: record only whether a point can terminate a cup of a prescribed length. That single bit of geometric potential divides the whole set into two recursively controlled regions.

The argument is also algorithmic. Sort points by horizontal coordinate. Dynamic programming can compute the longest cup and cap ending at each ordered pair of points. For each triple $i<j<r$, its orientation decides whether a chain ending at $(i,j)$ may extend to $(j,r)$. This takes $O(N^3)$ time and $O(N^2)$ memory for $N$ points, and it can return an explicit witness chain rather than merely assert existence.

The same orientation determinant is a workhorse in computational geometry. Convex-hull algorithms use it to decide when to discard an inward bend. Robotics uses related predicates in path planning and collision geometry. Geographic information systems use it to establish sidedness and polygon winding. The Happy-End Problem exposes the combinatorial heart of a predicate that appears wherever software must understand planar shape.

## A small picture to keep in mind

Imagine plotting points on the graph of $y=x^2$. Read from left to right, every consecutive triple bends upward, so the entire list is a cup. On $y=-x^2$, the same points form a cap. Arbitrary data are far messier: the signs may oscillate left, right, left, right. The theorem says that once the cloud is large enough, this oscillation cannot prevent a long one-sided chain.

For $n=5$, the classical threshold is

$$
\binom{6}{3}+1=21.
$$

No matter how $21$ noncollinear points are scattered, a suitable reading direction reveals five points that bend consistently and hence form a convex pentagon. The points need not be consecutive in the full left-to-right ordering; the theorem extracts a subsequence. This distinction is essential. Like finding an increasing subsequence in a scrambled list of numbers, the method ignores distracting points and preserves only the ordered structure it needs.

## A meeting point of geometry and combinatorics

The theorem's architecture has three layers. At the geometric layer, noncollinearity turns every triple into a left-or-right decision. At the combinatorial layer, endpoint marking creates a recursive partition. At the arithmetic layer, Pascal's identity closes the induction. None of these layers alone predicts the result; together they force order out of an arbitrary point cloud.

There is more to learn. The classical diagonal bound can be improved, and the exact value of $ES(n)$ remains a separate and harder question in general. Lower-bound constructions show that large configurations can avoid convex $n$-gons, while modern work narrows the exponential scale of the gap. Variants ask for empty convex polygons, positive fractions of points with shared structure, or convex position in higher dimensions.

Yet the central lesson survives every refinement. Global shape need not be searched for all at once. Sometimes it is enough to read the points in order, watch each tiny turn, and let a simple recurrence reveal the polygon that must be there.
