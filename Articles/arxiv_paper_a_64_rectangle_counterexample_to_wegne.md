# Sixty-Four Rectangles and the Power of Counting Certificates

## When geometry becomes bookkeeping

Draw a collection of axis-parallel rectangles on a table. Two questions immediately compete for attention. How many rectangles can we choose without any two touching? And how many points must we place so that every rectangle contains at least one point?

The first quantity is the **packing number**, denoted $\nu(\mathcal R)$: the largest size of a pairwise disjoint subfamily of a finite rectangle family $\mathcal R$. The second is the **piercing number**, denoted $\tau(\mathcal R)$: the smallest number of points whose union of incidences meets every rectangle.

These quantities look like opposites. Packing tries to spread rectangles apart; piercing tries to cover them economically. Every disjoint rectangle needs its own piercing point, so $\nu(\mathcal R)\leq \tau(\mathcal R)$. The difficult question is how far apart the two numbers can be.

A famous proposed answer asserted that every finite family of axis-parallel rectangles should satisfy

$$
\tau(\mathcal R)\leq 2\nu(\mathcal R)-1.
$$

At packing number $16$, the proposed ceiling is $31$. Thus a family of $64$ rectangles with $\nu=16$ and $\tau\geq 32$ crosses the boundary by the smallest possible integer margin. The central lesson is not merely the numbers. It is that the decisive reasoning can be organized into small, transparent counting certificates.

## No point may do the work of three

Call an indexed family **point-triangle-free** if no point lies in three distinct members. This is an incidence condition: whenever a point belongs to three indexed rectangles, at least two of those indices must coincide. For rectangles, it says that the depth of the arrangement is at most two.

Now imagine any piercing set $T$. Assign each rectangle to one point of $T$ that pierces it. Point-triangle-freeness guarantees that no point receives more than two rectangles. The rectangles have therefore been sorted into bins of capacity two. Counting the bins gives the **Triangle-Free Piercing Theorem**:

> If a finite indexed family $\mathcal R$ is point-triangle-free, then every piercing set $T$ satisfies $|\mathcal R|\leq 2|T|$. Consequently,
> $$
> \tau(\mathcal R)\geq \left\lceil\frac{|\mathcal R|}{2}\right\rceil.
> $$

The proof is almost visual. Draw one thread from each rectangle to a chosen piercing point. At most two threads end at any point, so $|\mathcal R|$ threads require at least $\lceil |\mathcal R|/2\rceil$ endpoints.

For $64$ rectangles this immediately yields

$$
\tau(\mathcal R)\geq 32.
$$

The coefficient two is sharp if triangle-freeness is the only assumption: a point may genuinely lie in two rectangles. Any stronger conclusion must use more geometry.

## Sixteen cells for a disjoint selection

The packing side uses the same counting idea in disguise. Suppose every rectangle selected for a disjoint subfamily is assigned to one of $m$ slots, and suppose each slot can receive at most $b$ selected rectangles. Then the **Slot-Capacity Principle** says

$$
|A|\leq mb
$$

for every such selection $A$. Indeed, partition $A$ by its slot labels and sum the capacities of the fibers.

The relevant gadget has four ordered slots of capacity one inside each of four blocks. Label a selected rectangle by a pair $(p,q)$, where $p$ is its block and $q$ its slot, with $p,q\in\{1,2,3,4\}$. If disjointness guarantees that each block-slot cell contains at most one selected rectangle, then there are only $4\cdot 4=16$ available cells. Hence every disjoint subfamily has size at most $16$.

This is the **Four-by-Four Packing Theorem**:

> If every member of a disjoint selection receives one of sixteen block-slot labels and no label is used twice, then the selection has at most $16$ members.

If a coordinate construction also displays $16$ pairwise disjoint rectangles, the upper bound is attained and $\nu=16$.

Notice the symmetry. A piercing argument maps rectangles to points and bounds the size of each fiber by two. A packing argument maps selected rectangles to slots and bounds each fiber by one. Both replace a picture with a finite map into a certificate space.

## The conditional counterexample certificate

The pieces fit into a concise theorem.

> **Sixty-Four-Rectangle Certificate Theorem.** Let $\mathcal R$ be a family of $64$ axis-parallel rectangles. Assume:
> 1. no point lies in three distinct rectangles;
> 2. there are $16$ explicitly distinguished pairwise disjoint rectangles; and
> 3. every pairwise disjoint subfamily admits a four-block, four-slot labeling in which each block-slot cell has capacity one.
>
> Then $\nu(\mathcal R)=16$ and $\tau(\mathcal R)\geq 32$. Therefore
> $$
> 2\nu(\mathcal R)-1=31<32\leq \tau(\mathcal R),
> $$
> so $\mathcal R$ violates the proposed inequality.

The proof is a three-line assembly of the earlier principles. The displayed disjoint family gives $\nu\geq16$. The slot certificate gives $\nu\leq16$. Triangle-freeness gives $\tau\geq32$. The arithmetic comparison finishes the argument.

This theorem deliberately separates logic from coordinates. It does not, by itself, list the endpoints of the $64$ rectangles or provide a $32$-point piercing set. Rather, it says exactly what a complete coordinate realization must certify. Endpoint comparisons establish triangle-freeness and slot capacities; a list of sixteen disjoint members establishes the matching packing lower bound. If exact equality $\tau=32$ is desired, one must additionally exhibit $32$ points piercing all rectangles.

That separation is valuable. Dense geometric drawings are hard to audit because many local intersections compete for attention. A certificate converts the global claim into bounded fibers, finite labels, and endpoint-order checks.

## Horizontal–vertical recursion

The same design has a recursive life. Let $a_r$ be the packing number at level $r$. Begin with $a_0=4$, and suppose each horizontal–vertical composition step squares the previous packing number:

$$
a_{r+1}=a_r^2.
$$

The **Squaring Recurrence Theorem** gives the closed form

$$
a_r=4^{2^r}.
$$

The proof is induction. It is true at $r=0$. If $a_r=4^{2^r}$, then

$$
a_{r+1}=a_r^2=\left(4^{2^r}\right)^2=4^{2^{r+1}}.
$$

The first four values are

$$
4,\quad 16,\quad 256,\quad 65{,}536.
$$

Double exponential growth arrives from a simple operation: repeatedly square. This is a familiar phenomenon in hierarchical systems. A modest local gadget, composed with itself in two independent directions, produces enormous global complexity.

## Linear relaxations and an exact numerical comparison

Packing rectangles is an integer optimization problem: each rectangle is either chosen or not. A standard relaxation replaces these binary choices by fractional weights, constrained so that all rectangles through any common point carry total weight at most one. For axis-parallel rectangles, pairwise-intersecting finite subfamilies share a point, so clique constraints can be read as point constraints.

At the finite level associated with the value $73/32$, the numerical ratio is

$$
\frac{73}{32}=2.28125.
$$

It strictly exceeds

$$
\frac{17891}{8064}\approx 2.2186.
$$

Indeed, cross-multiplication gives $73\cdot8064=588{,}672$ and $32\cdot17891=572{,}512$, leaving a positive difference of $16{,}160$. This arithmetic verifies the improvement once the corresponding primal and dual optimization certificates have established the ratio $73/32$ for the rectangle family. The counting framework alone does not derive that optimum; it isolates the separate combinatorial ingredients needed for packing and piercing.

## Why the method travels

The method reaches beyond rectangles. Whenever objects are assigned to resources with bounded capacity, global bounds follow by summing fiber sizes. In wireless scheduling, objects might be transmissions and slots might be interference-free channels. In database geometry, objects might be spatial records and piercing points might be query locations. In sensor placement, triangle-freeness means no location monitors three distinct regions, forcing a minimum number of sensors.

The reusable principle is simple:

$$
\text{number of objects}\leq
\text{number of certificate cells}\times
\text{capacity per cell}.
$$

What makes the rectangle problem subtle is discovering labels for which geometry enforces the capacities. Once those labels are found, the proof becomes ordinary arithmetic.

## The next picture to draw

A complete compact construction should pair the abstract certificate with integer coordinates. Every required claim could then be checked through endpoint order: whether two rectangles overlap, whether three share a point, whether the sixteen witnesses are disjoint, and whether the proposed piercing points lie inside the required rectangles.

A deeper possibility is that the slot and piercing arguments are two views of a single incidence matrix. Rows could encode block-slot capacities, columns point capacities, and duality could explain why the two counts fit together so cleanly. Recursively, equality in the slot bound may force every cell to be occupied, revealing the structure and number of all maximum packings.

There is also a lesson here about mathematical explanation. A coordinate drawing may be the object of study, yet the most illuminating proof need not imitate the drawing. It can identify the scarce resources that every solution must consume. On one side those resources are piercing points, each serving at most two rectangles. On the other they are ordered cells, each serving at most one chosen rectangle. This resource view makes assumptions visible, exposes exactly where sharpness occurs, and allows the same argument to be reused when the picture changes.

The enduring idea is that geometry can hide a finite ledger. For sixty-four rectangles, that ledger has fibers of size two on the piercing side and sixteen capacity-one cells on the packing side. Once the ledger is exposed, the critical inequality is unavoidable:

$$
31<32.
$$

A conjectured universal law can fail by one point, and the clearest explanation may be not a complicated drawing but a careful act of counting.
