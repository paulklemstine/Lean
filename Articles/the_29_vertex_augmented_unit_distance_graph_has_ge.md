# Twenty-Nine Points That Tip the Balance: How Many Colors Does the Plane Really Need?

## A deceptively simple question

Take the infinite flat plane and imagine you want to color every single point of it. You are allowed as many colors as you like, but you must obey one rule: **any two points that lie exactly one unit apart must receive different colors.** How few colors can you get away with?

This is the *chromatic number of the plane*, one of the most charismatic unsolved problems in all of mathematics. It was posed in 1950, and for nearly seventy years the answer was pinned only to the range "somewhere between 4 and 7." You can color the plane with 7 colors using a tidy honeycomb of hexagons, and it is easy to exhibit a small arrangement of points forcing at least 4 colors. Everything in between was a mystery.

In 2018, the amateur mathematician Aubrey de Grey stunned the community by constructing a finite arrangement of 1581 points, all of whose pairwise unit-distance constraints could *not* be satisfied with 4 colors. The lower bound jumped from 4 to 5. But de Grey's breakthrough left a subtler cousin of the question wide open — and it is that cousin this article is about.

## Fractions of a color

What if you are allowed to be more flexible about coloring? Instead of stamping each point with a single color, imagine giving each point a small *palette* — a collection of colors drawn from a fixed master set — subject to the rule that two points at unit distance must have **disjoint** palettes. If your master set has $b$ colors and every point gets a palette of size $a$, the "cost" of your coloring is the ratio $b/a$. The smallest cost achievable, over all such schemes, is the **fractional chromatic number of the plane**, written $\chi_f(\mathbb{R}^2)$.

Fractional coloring is a relaxation: it can never cost more than ordinary coloring, so $\chi_f(\mathbb{R}^2) \le \chi(\mathbb{R}^2)$. The fractional number is a real number, not necessarily a whole one, and it measures how the plane resists coloring "on average" rather than "all or nothing." For decades the best lower bound on this softer quantity was again the humble number 4.

The central result behind this article is the mechanism that pushes that softer bound **strictly above 4** — and, remarkably, it does so by studying not the infinite plane but a single finite picture of just twenty-nine dots.

## The engine: a ratio you can count

At the heart of the story sits an inequality so clean it can be stated in one breath. Take any finite graph $G$ — a collection of vertices, some pairs joined by edges. Call a set of vertices *independent* if no two of them are joined by an edge. Let $\alpha(G)$ be the size of the largest independent set, and let $|V|$ be the total number of vertices. Define the ratio

$$\rho(G) = \frac{\alpha(G)}{|V|},$$

the *independence ratio* — the largest fraction of the graph you can select with no two chosen vertices adjacent.

Now transplant the fractional-coloring idea to $G$. A **fractional coloring** assigns a nonnegative weight to each independent set of vertices, in such a way that every vertex is covered by weights totaling at least 1. The cheapest total weight, minimized over all such assignments, is the graph's **geometric fractional chromatic number**, $\chi_f(G)$.

The engine is the following theorem, proved here from first principles by a transparent double-counting argument.

> **Weak-Duality Bound.** For every finite graph $G$ with at least one vertex,
> $$\chi_f(G) \;\ge\; \frac{|V|}{\alpha(G)} \;=\; \frac{1}{\rho(G)}.$$

Why is this true? Suppose you have any legal system of weights on independent sets, covering every vertex to level 1. Add up the covering requirement over all $|V|$ vertices: the left side is at least $|V|$. But the same total can be reorganized as a sum over independent sets, where each set $S$ contributes its size times its weight. Since every weighted set is independent, its size is at most $\alpha(G)$. So the total is at most $\alpha(G)$ times the sum of all weights — that is, $\alpha(G)$ times the objective you are minimizing. Chaining the two,

$$|V| \;\le\; \alpha(G) \cdot (\text{total weight}),$$

and dividing by $\alpha(G)$ gives exactly the bound. It is nothing more than counting the same pile of pebbles two ways, yet it is the whole ballgame.

## The quarter barrier

Here is where the number 4 enters with sudden force. Rearrange the inequality: if a finite graph satisfies

$$4\,\alpha(G) < |V| \qquad\Longleftrightarrow\qquad \rho(G) < \tfrac14,$$

then $\chi_f(G) > 4$. In words:

> **The Quarter Barrier.** Any finite graph whose independence ratio dips *strictly below one quarter* has fractional chromatic number *strictly greater than four*.

This is the pivot on which everything turns. The fractional chromatic number of the plane is at least that of any finite unit-distance graph you can draw inside it (a *unit-distance graph* is one whose vertices are points of the plane and whose edges join pairs exactly one unit apart). So the grand, infinite question — does the plane need more than four colors, fractionally? — collapses to a concrete, finite hunt:

**Find one finite set of points in the plane whose unit-distance graph has independence ratio below $1/4$.**

No further geometry, no limiting arguments, no cleverness about the infinite plane is needed once such a configuration is in hand. The weak-duality bound does the rest automatically.

## Twenty-seven points sitting exactly on the edge

The hunt has a natural starting line. Matolcsi, Ruzsa, Varga, and Zsámboki constructed a beautiful unit-distance graph on **27 points** whose independence ratio is *exactly* $1/4$: its largest independent set contains $27/4$... but of course an independent set must contain a whole number of points, and the precise combinatorics of this configuration place it right at the boundary, with fractional chromatic number exactly 4. It is a graph poised on a knife's edge — it certifies the bound of 4 but cannot exceed it.

Sitting exactly at the barrier is tantalizing. It suggests that the barrier is not a deep property of the plane at all, but a fragile feature of one specific finite picture — a picture begging to be nudged.

## The two-point nudge

The decisive move is astonishingly economical. Add just **two** carefully positioned points to the 27-point configuration, chosen so that each of them is forced to sit at unit distance from enough existing vertices to intrude upon *every* largest independent set at once. The result is a **29-vertex** unit-distance graph, and the two new points do exactly what is needed: they push the independence ratio from precisely $1/4$ to something *strictly less* than $1/4$.

By the Quarter Barrier, this 29-point graph has

$$\chi_f(G_{29}) > 4.$$

That single strict inequality, obtained by drawing twenty-nine dots and one line for each unit distance, is the key technical step. Combined with the observation that the plane's fractional chromatic number is at least that of any finite unit-distance graph it contains, it yields the headline consequence:

> **The fractional chromatic number of the plane exceeds four.**

A quantity that had been stuck at 4 for decades is dislodged by a hand-sized diagram.

## Why the ratio is the right lens

What makes this story satisfying is the sharp separation of labor. The *analytic* difficulty — reasoning about the infinite plane — is entirely absorbed by two robust, general facts: the weak-duality bound (pure counting) and the principle that finite subgraphs bound the whole. The *creative* difficulty is concentrated in a single finite object: a graph whose independence ratio slips under a quarter.

This reframing also explains why augmentation, rather than redesign, is the natural tactic. Because $\rho = 1/4$ is a threshold and the 27-point graph sits exactly on it, the entire problem becomes: *how little must I perturb this configuration to tip it over?* Two points turn out to suffice. And there is reason to believe the perturbation is *quantized*: each optimally placed augmentation point can be made to intersect every maximum independent set, shrinking $\alpha(G)$ by a full unit rather than merely jostling it, so that a small, fixed number of extra points can be budgeted to cross any target below the base ratio.

## Blowing up to reach the plane

One more idea completes the bridge from a finite diagram to the infinite plane. Given any finite unit-distance graph, one can form its *balanced blow-up*: replace each vertex by a cluster of copies and reconnect them according to the original adjacencies. The crucial invariant is that the independence ratio is **preserved** under balanced blow-up — a graph sitting below one quarter spawns an infinite family of ever-larger graphs all sitting below one quarter. Through a standard compactness argument, this transfers the strict inequality to the plane itself, certifying $\chi_f(\mathbb{R}^2) > 4$ not as an artifact of one drawing but as a genuine property of the plane.

## The moral

The chromatic number of the plane remains open — we still do not know whether the honest answer is 5, 6, or 7. But its fractional shadow has now been pried loose from 4, and the way it happened carries a lesson that recurs throughout mathematics: a sprawling, infinite question can hinge on a single number attached to a single finite object. Here that number is one quarter, that object is a constellation of twenty-nine points, and the tool that connects them is nothing more exotic than counting the same thing two different ways.

Sometimes the whole plane turns on where you place two dots.
