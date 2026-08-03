# When Max Replaces Plus: Tropical Convexity, Boxes, and a Two-Constraint Helly Principle

## A geometry built for bottlenecks

A train cannot leave before its last passenger connection arrives. A construction phase cannot begin before every prerequisite is complete. A server handling parallel jobs reports the time of the slowest job, not their average. In all three situations, the governing operation is not ordinary addition but a maximum.

That simple change leads to **tropical mathematics**. In the max-plus convention, tropical addition is

$$
a\oplus b=\max(a,b),
$$

while tropical multiplication is ordinary addition,

$$
a\odot b=a+b.
$$

These rules are not a decorative relabeling. They capture systems controlled by synchronization, deadlines, precedence, and bottlenecks. They also create a geometry whose “straight lines” bend into piecewise-linear paths and whose convex combinations are assembled from maxima.

This article develops that geometry in $\mathbb R^d$, then focuses on a particularly useful class of regions: coordinate boxes. The central result is strikingly economical. For any finite collection of such boxes, if every pair overlaps, then all the boxes overlap at one common point. Equivalently, whenever the entire system is impossible, two constraints already expose the failure. The relevant Helly number is therefore $2$, independent of the ambient dimension.

## Tropical combinations and segments

A point in $\mathbb R^d$ is written $x=(x_1,\ldots,x_d)$. Given two points $x,y$ and a real parameter $t\le 0$, define their normalized max-plus combination by

$$
C_t(x,y)_i=\max\{x_i,t+y_i\},\qquad i=1,\ldots,d.
$$

The restriction $t\le 0$ means that $y$ may be shifted downward before competing coordinate by coordinate with $x$. At $t=0$, the result is the coordinatewise maximum of $x$ and $y$. As $t$ becomes very negative, the shifted copy of $y$ eventually becomes irrelevant and the combination approaches $x$.

To treat the endpoints symmetrically, the **tropical segment** joining $x$ and $y$ consists of all $C_t(x,y)$ with $t\le 0$, together with all $C_s(y,x)$ with $s\le 0$. Unlike a Euclidean line segment, this path generally has corners. Each corner marks a parameter value at which a different coordinate wins a maximum.

A set $S\subseteq\mathbb R^d$ is **tropically convex** if, whenever $x,y\in S$ and $t\le 0$, the point $C_t(x,y)$ also belongs to $S$. This definition immediately gives an important closure rule: the intersection of any family of tropically convex sets is tropically convex. Indeed, a combination of two points lying in every member of the family remains in every member.

## Hulls made from upper envelopes

Suppose $p^{(1)},\ldots,p^{(m)}$ are points of $\mathbb R^d$. Their max-plus tropical convex hull is the set of points $z$ for which there are real weights $w_1,\ldots,w_m$ satisfying

$$
z_i=\max_{1\le k\le m}\bigl(w_k+p^{(k)}_i\bigr)
$$

for every coordinate $i$. Each weighted generator is shifted by its scalar weight; the hull takes the upper envelope of all these shifted points.

**Tropical Hull Convexity Theorem.** The tropical convex hull of every nonempty finite family of points is tropically convex.

The proof is encoded in one max identity. Let $z^{(1)}$ arise from weights $u_k$ and $z^{(2)}$ from weights $v_k$. For $t\le 0$, set

$$
r_k=\max\{u_k,t+v_k\}.
$$

Then, coordinate by coordinate,

$$
\begin{aligned}
\max\{z^{(1)}_i,t+z^{(2)}_i\}
&=\max\left\{\max_k(u_k+p^{(k)}_i),\max_k(t+v_k+p^{(k)}_i)\right\}\\
&=\max_k\left(r_k+p^{(k)}_i\right).
\end{aligned}
$$

Thus the combination is represented by a new set of weights and remains in the hull. This upper-envelope calculation is the tropical counterpart of combining ordinary convex coefficients.

## Boxes survive tropical mixing

For lower and upper vectors $\ell,u\in\mathbb R^d$, define the box

$$
B(\ell,u)=\{x\in\mathbb R^d:\ell_i\le x_i\le u_i\text{ for every }i\}.
$$

The box may be empty if some $\ell_i>u_i$. When it is nonempty, it is an axis-aligned product of closed intervals.

**Tropical Box Convexity Theorem.** Every box $B(\ell,u)$ is tropically convex.

To see why, take $x,y\in B(\ell,u)$ and $t\le 0$. The combination $z_i=\max(x_i,t+y_i)$ cannot fall below $\ell_i$, because $z_i\ge x_i\ge\ell_i$. It cannot rise above $u_i$, because $x_i\le u_i$ and $t+y_i\le y_i\le u_i$. Hence $z$ remains in the box.

This elementary argument reveals why boxes fit max-plus geometry so naturally. A lower bound is protected by retaining $x$ as one candidate in the maximum; an upper bound is protected because a nonpositive shift cannot enlarge $y$.

## The one-dimensional engine

The multidimensional theorem rests on a one-dimensional fact. Consider finitely many closed intervals

$$
I_k=[a_k,b_k].
$$

Assume every lower endpoint lies below every upper endpoint:

$$
a_i\le b_j\qquad\text{for all }i,j.
$$

Let

$$
x^*=\max_k a_k.
$$

Then every $a_k\le x^*$ by definition, while $x^*\le b_j$ for every $j$ because each lower endpoint is at most $b_j$. Therefore $x^*$ belongs to every interval.

**Interval Helly Theorem.** A finite family of closed real intervals has a common point whenever every pair has a common point. A canonical common point is the largest lower endpoint.

Pairwise overlap implies the cross inequalities $a_i\le b_j$: any point in $I_i\cap I_j$ lies above $a_i$ and below $b_j$. The largest lower endpoint then supplies the global witness.

## Pairwise overlap controls every dimension

Now take finitely many boxes

$$
B_k=\prod_{i=1}^d[\ell_{k,i},u_{k,i}],\qquad k=1,\ldots,n.
$$

Suppose every pair $B_p,B_q$ intersects. Pick a point from that pairwise intersection. In coordinate $i$, it lies above $\ell_{p,i}$ and below $u_{q,i}$, so

$$
\ell_{p,i}\le u_{q,i}
$$

for all boxes $p,q$ and all coordinates $i$. Fixing a coordinate turns these inequalities into the hypotheses of the Interval Helly Theorem. Therefore all coordinate intervals share a value. Choosing one shared value in each coordinate produces a point lying in every box.

**Tropical Box Helly Theorem.** For every finite family of boxes in $\mathbb R^d$, the total intersection is nonempty if and only if every pairwise intersection is nonempty.

The forward implication is immediate: a common point works for every pair. The reverse implication is the coordinatewise argument above. The result is dimension-free: although general convexity usually pays a price for higher dimension, the product structure of boxes keeps the Helly number at $2$.

The word “tropical” matters here because these boxes are tropically convex, so the theorem supplies a Helly principle inside tropical convex geometry. Yet the proof also identifies the deeper source of the unusually small number: each coordinate can be solved independently.

## The canonical feasible point

For a nonempty family of boxes, define

$$
x_i^*=\max_{1\le k\le n}\ell_{k,i}.
$$

This vector collects the strongest lower demand in every coordinate. It is not merely one possible witness.

**Exact Feasibility Criterion.** A nonempty finite family of boxes has a common point if and only if

$$
\ell_{p,i}\le u_{q,i}
$$

for every pair of boxes $p,q$ and every coordinate $i$.

Necessity follows from any common point. For sufficiency, use $x^*$. It dominates every lower bound. For a fixed box $q$, every lower bound $\ell_{p,i}$ is at most $u_{q,i}$, so their maximum $x_i^*$ is also at most $u_{q,i}$. Thus $x^*$ belongs to every box.

**Least-Point Theorem.** Among all vectors satisfying every lower-bound constraint, $x^*$ is coordinatewise least: if $x_i\ge\ell_{k,i}$ for all $k,i$, then $x_i^*\le x_i$ for every $i$.

This makes $x^*$ a canonical optimizer. Every coordinatewise nondecreasing objective $F$ satisfies $F(x^*)\le F(x)$ for every feasible $x$. For instance, $x^*$ minimizes the sum of coordinates, the largest coordinate, and any positive weighted sum, provided the family is feasible. Strict monotonicity can yield uniqueness under suitable objective assumptions.

## Small certificates of failure

The Helly theorem has a computational contrapositive.

**Two-Constraint Infeasibility Certificate.** If a finite family of boxes has empty total intersection, then some pair of boxes already has empty intersection.

More concretely, infeasibility means that for some coordinate $i$,

$$
\max_k\ell_{k,i}>\min_k u_{k,i}.
$$

Choose a box $p$ attaining the maximum lower bound and a box $q$ attaining the minimum upper bound. Then

$$
\ell_{p,i}>u_{q,i},
$$

so no point can satisfy both boxes. The failed coordinate and the two box indices form a short, transparent certificate.

A direct feasibility algorithm follows. Scan every coordinate, compute the greatest lower bound and least upper bound, and compare them. With $n$ boxes in $d$ dimensions, this takes $O(nd)$ time. If all comparisons pass, return $x^*$; if one fails, return the two responsible boxes and coordinate. A naive pairwise search would cost $O(n^2d)$, but the extremal scan extracts the same certificate faster.

## Why this matters

Imagine each box as a bundle of permitted windows. In scheduling, coordinate $i$ might be the start time of task $i$; each stakeholder contributes acceptable lower and upper bounds. In resource allocation, coordinates might measure storage, energy, labor, or bandwidth. In robust parameter selection, each box records a scenario’s admissible range.

The theory gives three levels of explanation:

1. **Structure:** the admissible regions are stable under normalized max-plus mixing.
2. **Existence:** pairwise compatibility guarantees global compatibility.
3. **Computation:** the strongest lower bounds produce a canonical solution, while any failure is exposed by two boxes in one coordinate.

The contrast with arbitrary systems is important. Complex constraints can create global contradictions invisible in every small subfamily. Box constraints cannot hide conflict that way. Their only possible obstruction is a lower demand crossing an upper allowance, and two constraints suffice to display that crossing.

## The horizon beyond boxes

Boxes are a tractable island inside a larger tropical world. One concrete conjecture proposes the following dimension-dependent principle: for a finite family of normalized max-plus tropically convex subsets of $\mathbb R^d$, if every subfamily containing at most $2d$ sets has a common point, then the entire family has a common point. This statement is not established here; the sharper target $d+1$ is a natural subject for future investigation. Another question asks whether tropical Carathéodory-type support bounds can be converted into small separation and intersection certificates. Adding difference constraints such as

$$
x_i-x_j\le c
$$

would connect the theory more directly to precedence networks and shortest-path consistency, but would also couple coordinates and destroy the simple product argument.

What remains constant is the guiding theme: maxima turn geometry into a language of competing constraints. Tropical convex hulls are upper envelopes; tropical segments record changes of the winning coordinate; box feasibility is decided by extremal bounds. In this geometry, a large system can fail for a very small reason—and when it succeeds, the point assembled from its strongest lower requirements is the natural place to stand.
