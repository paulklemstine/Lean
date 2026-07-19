# The Topology Hidden Inside a ReLU Network

## How ranks, cycles, and activation patterns turn a jagged decision surface into computable mathematics

A neural network can draw a boundary without ever being told what a boundary is. Feed it points from two classes—a benign scan and a suspicious scan, a safe transaction and a fraudulent one—and its output changes sign somewhere between them. The set where the output is exactly zero is the network’s **decision surface**. Crossing that surface changes the prediction.

For a network built from rectified linear units, or ReLUs, this boundary is not smoothly curved. A ReLU replaces a number $t$ by $\max(0,t)$, so the network is affine on every region where the pattern of active and inactive units is fixed. Its zero set is therefore assembled from flat polyhedral pieces. In two input dimensions it resembles a polygonal collection of curves; in three dimensions it resembles a surface made from planar patches; in higher dimensions it is a polyhedral hypersurface.

That geometry invites an ambitious analogy. Classical algebraic geometry studies the relation between holes and geometric cycles on smooth complex projective varieties. Could a neural decision surface have a similarly rich “Hodge theory”? The analogy is evocative, but it must be handled carefully. A general ReLU zero set is real, often unbounded, and piecewise linear. It is not automatically a smooth complex projective variety, so classical Hodge numbers are not naturally attached to it. Nor does lying inside a hyperplane make a bounded polyhedral face an algebraic subvariety.

What survives is both more modest and more concrete: **cellular homology**. Once a finite portion of the decision surface is represented as a finite polyhedral cell complex, its holes can be computed by linear algebra. In a three-term portion of that complex, every question is organized by two boundary maps

$$
C_2 \xrightarrow{d_2} C_1 \xrightarrow{d_1} C_0,
$$

with the essential condition

$$
d_1d_2=0.
$$

Here $C_0$, $C_1$, and $C_2$ are vector spaces spanned by vertices, edges, and two-dimensional faces. The equation says that the boundary of a boundary vanishes: the oriented edges surrounding a face have endpoints that cancel in pairs.

This simple equation leads to exact formulas for the topology of the complex—and to a principled way to connect network architecture with topological complexity.

## Holes as what remains after two kinds of cancellation

Focus on the middle space $C_1$. An element of $C_1$ is a linear combination of edges. It is a **cycle** if it has no boundary, meaning that $d_1x=0$. All cycles form the kernel $\ker d_1$. But some cycles are already boundaries of faces: they have the form $d_2y$ for some $y\in C_2$. These form the image $\operatorname{im}d_2$. Because $d_1d_2=0$, every boundary is a cycle.

The first homology space is the quotient

$$
H_1=\ker d_1/\operatorname{im}d_2.
$$

It records closed edge combinations after discarding those filled by faces. Its dimension $\beta_1=\dim H_1$ is the first Betti number, the number of independent one-dimensional holes over the chosen field.

The central rank identity is strikingly clean.

**Middle Betti Rank Formula.** For any finite-dimensional three-term chain complex over a field satisfying $d_1d_2=0$,

$$
\beta_1+\operatorname{rank}(d_1)+\operatorname{rank}(d_2)=\dim C_1.
$$

Why? Rank–nullity first divides $C_1$ into directions detected by $d_1$ and directions in $\ker d_1$:

$$
\dim\ker d_1=\dim C_1-\operatorname{rank}(d_1).
$$

Quotienting cycles by boundaries removes another $\operatorname{rank}(d_2)$ dimensions. Thus

$$
\beta_1=\dim C_1-\operatorname{rank}(d_1)-\operatorname{rank}(d_2).
$$

This interpretation is useful. The middle cell space provides a budget of $\dim C_1$ directions. The outgoing map spends some of that budget by exposing nonzero boundaries. The incoming map spends more by filling cycles. What remains is homology.

Several consequences follow immediately.

**Nonvanishing Criterion.** The space $H_1$ is nonzero exactly when

$$
\operatorname{rank}(d_1)+\operatorname{rank}(d_2)<\dim C_1.
$$

**Vanishing Criterion.** The space $H_1$ vanishes exactly when

$$
\operatorname{rank}(d_1)+\operatorname{rank}(d_2)=\dim C_1.
$$

**Maximality Criterion.** The equality $\beta_1=\dim C_1$ holds exactly when both boundary maps are zero.

These are not merely bounds. They identify the precise obstruction to a middle-dimensional hole: the adjacent boundary maps fail to consume all available dimensions.

## Every class has a cellular representative

A homology class is an equivalence class of cycles, so every class comes from some element of $\ker d_1$. This gives the **Cellular Representation Theorem**: every element of $H_1$ is represented by a cellular cycle, hence by a linear combination of the chosen one-dimensional cells.

Over $\mathbb{Q}$, the coefficients may be rational. For a rational polyhedral model, every rational homology class therefore has a rational cellular representative.

This statement captures the sound part of the proposed “Hodge conjecture for neural networks.” It does **not** say that every class is represented by an algebraic cycle in the classical sense. A polyhedral face may lie in an affine hyperplane while failing to be a complete algebraic subvariety or global hyperplane section. To make a genuine Hodge-type claim, one would need to define a geometric cohomology theory and an explicit cycle-class map, then prove that map surjective. Cellular representability alone cannot supply those missing structures.

The correction strengthens the mathematics by clarifying exactly what has been established: decision-surface classes are represented by the cells used to build the surface, and their number is governed by ranks.

## The alternating sum that refuses to change

The same three-term complex has homology in all three degrees. At the bottom,

$$
H_0=C_0/\operatorname{im}d_1,
$$

which measures connected components. In the middle,

$$
H_1=\ker d_1/\operatorname{im}d_2.
$$

At the top,

$$
H_2=\ker d_2,
$$

because no higher boundary map is present. Write $\beta_i=\dim H_i$ and $c_i=\dim C_i$. Rank–nullity gives

$$
\beta_0=c_0-\operatorname{rank}(d_1),
$$

$$
\beta_1=c_1-\operatorname{rank}(d_1)-\operatorname{rank}(d_2),
$$

and

$$
\beta_2=c_2-\operatorname{rank}(d_2).
$$

Now take the alternating sum. Both ranks cancel:

$$
\beta_0-\beta_1+\beta_2=c_0-c_1+c_2.
$$

This is the **Euler–Poincaré Theorem for a Three-Term Complex**. The common integer is the Euler characteristic $\chi$.

The theorem reveals a robust form of rigidity. Individual Betti numbers can change when boundary maps change, but their alternating sum depends only on the numbers of cells. Any two three-term complexes with the same dimensions $c_0,c_1,c_2$ have the same Euler characteristic, provided each is genuinely a chain complex.

There is also an immediate estimate:

$$
|\chi|\le c_0+c_1+c_2.
$$

The alternating sum can never exceed the total cellular dimension in absolute value. For a triangulated loop, for example, $c_0=c_1$ and $c_2=0$, so $\chi=0$. For a filled triangle, $c_0=3$, $c_1=3$, and $c_2=1$, so $\chi=1$. The boundary map distinguishes their homology: the loop has $\beta_1=1$, while the filled triangle has $\beta_1=0$. Yet in each case the cell count correctly predicts the alternating sum.

## From neurons to a coarse topological ceiling

How does network architecture enter? A hidden ReLU unit has two states: active or inactive. If the hidden-layer widths are $w_1,\ldots,w_L$, then the total number of Boolean activation patterns is

$$
P=\prod_{i=1}^{L}2^{w_i}=2^{\sum_{i=1}^{L}w_i}.
$$

Not every pattern need occur in input space, and one activation region may contribute several cells after further subdivision. Consequently, $P$ is best treated as a coarse combinatorial ceiling under an explicit cell-count hypothesis, not as an automatic exact count of decision-surface cells.

Suppose a finite cellular model satisfies

$$
c_0\le P,\qquad c_1\le P,\qquad c_2\le P.
$$

Combining these inequalities with the total-dimension estimate yields the **Architecture-Driven Euler Bound**:

$$
|\chi|\le 3P=3\prod_{i=1}^{L}2^{w_i}.
$$

This bound is deliberately broad. It does not establish the proposed binomial inequality for quantities $h^{p,q}$, because no canonical bigrading $H^{p,q}$ has yet been defined for a general ReLU zero set. What it does provide is a valid quantitative shadow: if activation patterns control cell counts, then they also control the Euler characteristic.

## A practical computation

For an actual finite polyhedral complex, the calculation is straightforward.

1. Choose a field, commonly $\mathbb{Q}$ for rational cellular chains.
2. List the vertices, edges, and faces, fixing orientations.
3. Build matrices $D_1$ and $D_2$ for the boundary maps.
4. Check $D_1D_2=0$.
5. Compute $r_1=\operatorname{rank}(D_1)$ and $r_2=\operatorname{rank}(D_2)$.
6. Evaluate

$$
\beta_0=c_0-r_1,
\qquad
\beta_1=c_1-r_1-r_2,
\qquad
\beta_2=c_2-r_2.
$$

7. Confirm

$$
\beta_0-\beta_1+\beta_2=c_0-c_1+c_2.
$$

The expensive part is not the final topology calculation; ordinary exact matrix reduction handles that. The difficult geometric step is producing a correct finite complex from the network’s zero set, especially when the surface is unbounded.

## What the result says—and what comes next

The topology of a piecewise-linear decision surface is accessible because its cells turn topology into linear algebra. Every cellular homology class has a cellular-cycle representative. The middle Betti number obeys an exact rank formula. Its vanishing, nonvanishing, and maximality are characterized precisely. The Euler characteristic is determined by cell counts and, under a common activation-pattern ceiling, is bounded by $3P$.

But the classical Hodge conjecture has not become trivial. Its ingredients—complex projective geometry, a Hodge decomposition, and algebraic cycle classes—are absent from a generic real ReLU zero set. The responsible bridge is therefore not an identification but a research program.

That program has clear next steps: build finite rational polyhedral complexes from compact truncations of network zero sets; prove their boundary maps compose to zero; extend the theory to locally finite or compactly supported homology for unbounded surfaces; define an honest realization map from rational polyhedral cycles into a chosen cohomology theory; and derive sharper architecture-sensitive cell bounds.

The enduring idea is simple. A network’s jagged boundary may look geometrically complicated, but its topology is governed by what two matrices fail to cancel. Between activation patterns and homology lies a chain complex—and in that narrow space, holes become ranks, alternating sums become rigid, and a speculative analogy becomes a precise mathematical theory.
