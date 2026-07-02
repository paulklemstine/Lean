# Two Points That Tip the Balance: The Hidden Arithmetic of Coloring the Plane

## A century-old coloring puzzle

Imagine you must paint every point of an infinite sheet of paper so that no two points at *exactly* one unit apart share the same color. How many colors do you need? This deceptively simple question — the **chromatic number of the plane** — has resisted mathematicians since 1950. We know the answer is somewhere between $5$ and $7$, and narrowing that gap is one of the most charismatic open problems in combinatorial geometry.

A softer, more quantitative cousin of the problem replaces whole colors with *fractions* of colors. Instead of demanding that each point get a single color, we allow each point to receive a little "bundle" of color-weight, insisting only that points a unit apart never share weight. The smallest total amount of color needed is the **fractional chromatic number of the plane**. It is a real number, not necessarily an integer, and it slips into the cracks between the integer answers. Every improvement to its lower bound is hard-won, and every such improvement tightens the noose around the original problem.

This article is about a small, sharp, and slightly magical fact hiding inside that story: sometimes adding just **two points** to a finite configuration is enough to push its fractional coloring cost past a critical value of $4$ — and two is provably the *fewest* points that can do the job.

## Finite skeletons of an infinite problem

Nobody attacks the whole plane at once. Instead, one studies **unit-distance graphs**: finite sets of points in the plane, where two points are joined by an edge precisely when they lie exactly one unit apart. Any valid coloring of the plane restricts to a valid coloring of such a graph, so these finite skeletons transmit lower bounds up to the infinite problem. Find a finite unit-distance graph whose fractional chromatic number exceeds some value $c$, and you have shown the fractional chromatic number of the whole plane is at least $c$.

At the center of our story sits a particular configuration of $27$ points, which we will call $G_{27}$. It is a real planar unit-distance graph, carefully engineered so that its structure is as "colorful-hungry" as possible for its size. What makes it remarkable is what happens when you nudge it: adding a specific pair of points transforms it into a $29$-point configuration, $G_{29}$, whose fractional chromatic number is strictly greater than $4$. Such augmentations — small additions that produce a genuine jump in coloring cost — are exceedingly rare. Most ways of adding points change nothing at all.

Why should two points, out of infinitely many possible placements, matter so much? The surprising answer is that the phenomenon is not driven by some subtle continuous analysis. At its heart lies a crisp piece of counting.

## The independence ratio and the number one-quarter

The bridge between geometry and arithmetic is the **independence number**. A set of points in a graph is *independent* if no two of them are joined by an edge — in our setting, no two of them are a unit apart. The independence number $\alpha$ is the size of the largest such set. It measures how many points you can safely paint with a single color.

There is a clean, general principle relating independence to fractional coloring. If a graph has $m$ vertices and independence number $\alpha$, then its **independence ratio** is $\alpha / m$, and its fractional chromatic number is at least the reciprocal $m / \alpha$. Turning this around: the fractional chromatic number is forced to exceed $4$ precisely when

$$\frac{\alpha}{m} < \frac{1}{4}.$$

So the whole drama reduces to a race between a fixed numerator and a growing denominator. The configuration $G_{27}$ has independence number

$$\alpha = 7.$$

Watch what happens to the independence ratio as we add points while keeping the largest independent set pinned at seven:

$$\frac{7}{27} \approx 0.259 > \frac{1}{4}, \qquad \frac{7}{28} = 0.25 = \frac{1}{4}, \qquad \frac{7}{29} \approx 0.241 < \frac{1}{4}.$$

The base configuration sits *above* the threshold: not forced past $4$. Adding a single point lands us *exactly* on the boundary $1/4$ — tantalizingly close, but not strictly below, so still not forced. Only when we add a **second** point does the ratio cross strictly under $1/4$, and the fractional chromatic number is driven above $4$.

That single equality $\tfrac{7}{28} = \tfrac14$ is the linchpin. It is not an approximation; it is exact. The one-point augmentation genuinely balances on the knife's edge and never tips over. Two points is not merely *a* solution — it is the *least* number of points that can force the crossing.

## Why "exactly one-quarter" is the whole story

It is worth pausing on how much work that exact equality does. If the intermediate value had been, say, $7/28 = 0.2500001$, then a single point would already have crossed the threshold and the "two-point" phenomenon would evaporate. If it had been well above $1/4$, then two points might not have sufficed either. The magic of $G_{27}$ is that seven and twenty-seven are tuned so that the boundary is struck **precisely** after one addition and cleared **immediately** after the second.

This can be stated as a completely general law. Suppose a base configuration has $n$ points and independence number $a$, and suppose it sits at or above the threshold, meaning $n \le 4a$. Then the least number of points $k$ that must be added — *without* enlarging the largest independent set — to force the independence ratio $a/(n+k)$ strictly below $1/4$ is exactly

$$k = 4a - n + 1.$$

For $G_{27}$, with $a = 7$ and $n = 27$, this gives $4\cdot 7 - 27 + 1 = 28 - 27 + 1 = 2$. The celebrated "two" is simply this affine formula evaluated at one particular pair of numbers. The threshold inequality $a/m < 1/4$ is equivalent to the tidy integer statement $4a < m$, and from there the minimality is pure arithmetic bookkeeping.

## The one catch: you must hold the numerator still

There is a crucial subtlety, and it is where geometry re-enters. The clean counting law assumes the independence number stays fixed at $7$. But adding points to a graph can only ever *increase* the independence number, never decrease it. Intuitively: any independent set you already had survives when you add more points; new points can only give you more room, not less.

Formally, if one configuration is obtained from another by adding vertices (passing to a larger unit-distance graph in which the original sits as an induced sub-configuration), the independence number of the smaller one is at most that of the larger. So when we add two points and the independence number happens to *remain* $7$, that is a special, delicate event. We call such an augmentation **critical**: it adds points without handing the enemy a larger independent set to exploit.

This reframes the entire mystery. The reason fractional-chromatic-raising augmentations are so rare is not that the arithmetic is fussy — the arithmetic is sharp and simple. It is that **holding the independence number fixed while inserting new unit-distance constraints is an enormously over-determined geometric condition.** Each new point must be placed so that it forms the right unit distances to lock into the structure, yet without opening up any new set of seven-or-more mutually non-adjacent points, and without accidentally creating a set of eight. Points that thread this needle are the exception, not the rule.

## What is proved, and what remains

We can now cleanly separate the parts of this phenomenon that are settled from the part that is still a frontier.

**Settled — the combinatorial skeleton.** The threshold inequality $\alpha/m < 1/4 \iff 4\alpha < m$; the exact values $7/27 > 1/4$, $7/28 = 1/4$, $7/29 < 1/4$; the general minimal-augmentation formula $4a - n + 1$ and its specialization to $2$ for $G_{27}$; the monotonicity of the independence number under augmentation; and the resulting dichotomy — that a critical two-point augmentation leaves the $27$-point base strictly above the threshold while pushing the $29$-point result strictly below it. All of this is airtight. Any planar realization of the phenomenon *must* obey this arithmetic; there is no wiggle room.

**Open — the geometric realizability.** What the counting cannot see is *existence*: can two real points genuinely be added to $G_{27}$ in the Euclidean plane, forming the necessary unit distances, while keeping the maximum independent set at exactly seven? And if so, is that placement **unique up to rigid motions of the plane** (rotations, reflections, translations)? The conjecture at the heart of this program asserts exactly that: up to Euclidean isometry, there is a *single* critical two-point augmentation of $G_{27}$.

The value of the arithmetic core is that it *localizes* the difficulty. The open problem is no longer a vague question about coloring the plane; it is a sharply posed rigidity question: *how many ways can two points be added to a specific $27$-point configuration without enlarging its largest independent set?* This is the kind of question that configuration spaces and algebraic geometry are built to answer.

## Why this matters

Progress on the chromatic number of the plane comes in two flavors: dramatic constructions of ever-more-tangled graphs, and quiet structural insights that explain *why* the constructions work. This story is firmly of the second kind. It takes a phenomenon that looked like a lucky accident — "add these two magic points and the coloring cost jumps" — and reveals it as the inevitable consequence of a single affine threshold law, gated by one exact rational equality.

More broadly, the pattern generalizes. For any base configuration of $n$ points with independence number $a$ satisfying $n \le 4a$, the minimal crossing number $4a - n + 1$ is one formula, and the "two" of $G_{27}$ is just one of its infinitely many values. Somewhere out there are configurations for which the magic number is three, or four, or seventeen — each a doorway to a different corner of this beautiful, stubborn problem. The arithmetic tells us exactly where to look; the geometry, as always, keeps its secrets a little longer.
