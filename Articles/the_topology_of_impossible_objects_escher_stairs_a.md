# The Topology of Impossible Objects: Why Endless Stairs Refuse to Close

A staircase rises one step at a time. Follow it long enough and you should end higher than where you began. Yet in M. C. Escher’s *Ascending and Descending*, a procession climbs forever and returns to its starting point. The eye accepts each local step; the whole circuit is impossible.

That tension—local plausibility against global contradiction—is not merely a trick of perspective. It has a precise mathematical anatomy. On a periodic tiled world, every edge can carry a proposed change of height. The question is whether those local changes come from one consistent height assignment. Two different failures can prevent that. A single tile may already be contradictory, or every tile may fit while a journey around the world accumulates a nonzero rise.

The resulting theory gives a complete test for periodic impossible figures. It also explains why repainting heights, moving the visual baseline, or changing a local convention cannot repair a genuine Escher staircase. The obstruction is not in the labels. It lives in the circulation of the figure itself.

## A tiled universe of height changes

Imagine an $m\times n$ rectangular grid whose opposite sides have been glued together. Walking off the right edge returns you on the left; walking off the top returns you at the bottom. Topologically, this is a torus. It is the natural home for any pattern that repeats horizontally and vertically.

At every grid point $(i,j)$, record two increments:

- $a(i,j)$ is the proposed change in height when moving one step to the right;
- $b(i,j)$ is the proposed change in height when moving one step upward.

The increments may be ordinary real numbers, integers, vectors, or elements of any additive commutative group $A$. This generality matters: the argument uses only addition, subtraction, and finite sums.

A figure is **developable** if there is a height function $h(i,j)$ such that

$$
a(i,j)=h(i+1,j)-h(i,j),\qquad
b(i,j)=h(i,j+1)-h(i,j),
$$

with indices interpreted periodically. In plain language, all the arrows really are differences of a single-valued height.

How can development fail? First inspect one tile. Travel right, then up, then left, then down. A true height function must bring you back to the same height. The net proposed change, called the **curvature** of the tile, is

$$
C(i,j)=a(i,j)+b(i+1,j)-a(i,j+1)-b(i,j).
$$

If $C(i,j)\ne 0$, the four edges disagree before we have even considered the rest of the picture. This is a local impossibility certificate.

But zero curvature is not enough on a torus. One can walk all the way around the horizontal direction and return to the same grid point. The accumulated increment is the horizontal period

$$
P_x=\sum_{i=0}^{m-1}a(i,0).
$$

Likewise, the vertical period is

$$
P_y=\sum_{j=0}^{n-1}b(0,j).
$$

When curvature vanishes, these sums do not depend on the chosen row or column. A nonzero $P_x$ or $P_y$ says that a closed trip returns to the same location but demands a different height. That is the global contradiction at the heart of the endless staircase.

## The complete obstruction theorem

The central result is remarkably clean.

**Periodic Developability Theorem.** A periodic increment field on an $m\times n$ toroidal grid is developable if and only if every tile has zero curvature and both fundamental periods vanish:

$$
C(i,j)=0\text{ for all }(i,j),\qquad P_x=0,\qquad P_y=0.
$$

The necessity is immediate to visualize. If increments come from heights, the four differences around each tile telescope to zero. The sums around the two closed fundamental loops telescope too, because each loop ends where it began.

The converse is the deeper direction. Choose one grid point as a base and assign it height zero. To define the height at another point, add increments along any path from the base to that point. Zero curvature allows a path to slide across individual tiles without changing its sum. The two zero periods allow it to wrap around either direction of the torus without changing its sum. Any two paths can be related by tile slides and whole wraps, so they give the same height. The path sum therefore defines a consistent function $h$ whose differences are exactly $a$ and $b$.

This proof separates impossibility into two scales. Curvature detects what goes wrong inside contractible little loops. Periods detect what survives around noncontractible loops, the journeys that cannot be shrunk to a point on the torus.

## Why relabeling cannot cure an impossible staircase

Artists and modelers often have freedom to choose a local reference level. Suppose a function $g(i,j)$ changes that reference at every grid point. The displayed increments become

$$
a'(i,j)=a(i,j)+g(i+1,j)-g(i,j),
$$

and

$$
b'(i,j)=b(i,j)+g(i,j+1)-g(i,j).
$$

This operation is a **gauge transformation**. It can alter every individual arrow. A dramatic checkerboard choice of $g$, for example, can make neighboring labels look entirely different. But it adds only differences of local reference values.

**Gauge-Invariance Theorem.** Under every gauge transformation, the curvature of every tile, the horizontal period, and the vertical period remain unchanged. Consequently, the transformed field is developable if and only if the original field is developable.

Around a tile, all added $g$-terms cancel in opposite pairs. Around a complete periodic row or column, they telescope and cancel because the final point is the initial point. Thus

$$
(C',P_x',P_y')=(C,P_x,P_y).
$$

This triple is a complete fingerprint of obstruction. A gauge transformation may change the description of a picture, but it cannot change whether the picture can be unfolded into consistent heights.

Consider a $3\times3$ periodic grid with a proposed drop of one unit on every rightward edge and no vertical change:

$$
a(i,j)=-1,\qquad b(i,j)=0.
$$

Every tile has zero curvature: locally, adjacent steps fit perfectly. Yet

$$
P_x=-3,
$$

so one horizontal circuit returns to its starting point three units lower. Now choose the visibly nonconstant reference

$$
g(i,j)=i-j.
$$

The transformed arrows vary, but the period remains $-3$. No checkerboard relabeling can make this waterfall developable. The contradiction is global.

## From Escher to electromagnetism and data analysis

The same structure appears far beyond optical illusion. In vector calculus, a gradient field has zero circulation around closed curves. In electromagnetism, gauge transformations alter potentials without changing observable fields. In phase-unwrapping algorithms, local phase differences must be integrated into a globally consistent signal. In computer vision, relative depth estimates may agree on small patches while contradicting one another around a large loop. In robotics, a network of relative position measurements may have small local residuals but nonzero loop closure error.

The periodic grid is a compact laboratory for all these situations. Curvature measures local inconsistency. Holonomy—the accumulated change around a closed loop—measures global inconsistency. Gauge freedom expresses the fact that only relative values matter. The theorem says exactly which measurements survive all choices of local reference.

There is also an algorithmic lesson. To reject a field quickly, one needs only find one tile with $C(i,j)\ne0$, or one fundamental period with nonzero sum. To construct heights when all tests pass, choose a spanning set of paths from a base point and integrate. On an $m\times n$ grid, both checking and reconstruction require only $O(mn)$ arithmetic operations.

## Two kinds of endless descent

Not every mathematical “staircase” is periodic geometry. A useful contrast comes from the ideals

$$
\mathbb Z\supset 2\mathbb Z\supset 4\mathbb Z\supset 8\mathbb Z\supset\cdots.
$$

The sequence $I_k=2^k\mathbb Z$ is strictly descending: each new ideal contains fewer integers. Its intersection is

$$
\bigcap_{k=0}^{\infty}2^k\mathbb Z=\{0\}.
$$

Indeed, a nonzero integer is divisible by only finitely many powers of two. This filtration descends forever, but it never loops back. It is therefore not an Escher staircase. The distinction is structural: an algebraic filtration is indexed by an open-ended line, while a periodic staircase lives on a closed cycle and is governed by additive holonomy.

Confusing the two can create a false analogy. Infinite descent is perfectly possible when there is no demand to return to the starting level. Periodic ascent or descent is impossible precisely because closure forces the net change to vanish.

## What topology does—and does not—say

The phrase “topology of impossible objects” invites a tempting leap: perhaps every non-orientable three-dimensional space must literally contain a Penrose triangle. But such a claim is not mathematically meaningful until “Penrose triangle” is defined with projection, depth ordering, beam geometry, and a precise distinction between embedded and immersed surfaces.

Non-orientability alone concerns what happens to orientation when transported around loops. A Penrose triangle is an optical contradiction created by projection-dependent depth relations. These ideas may eventually meet through twisted coefficients or orientation covers, but one does not automatically imply the other.

The rigorous lesson is subtler and more useful. Impossible figures are not classified by evocative names or by topology alone. They are classified only after specifying the data that observers compare. For periodic height increments, the correct data are local curvature and global periods. For a projected beam figure, one would need depth inequalities and their cyclic accumulation. The mathematics begins when the visual rules are made explicit.

## The hidden loop in every impossible object

An impossible figure succeeds artistically because our visual system reasons locally. Each joint, landing, or beam looks plausible in isolation. Mathematics asks what happens when those local judgments are carried around a loop.

On a periodic grid, the answer is complete. Zero tile curvature guarantees local agreement. Zero horizontal and vertical periods guarantee global agreement. Together they are exactly equivalent to the existence of a consistent height function. Add any local change of reference, however elaborate, and all three obstructions remain fixed.

So the secret of the endless staircase is not that every step lies. Each step may tell the truth. The impossibility appears only when the truths are added together—and the path comes home with a height that does not.