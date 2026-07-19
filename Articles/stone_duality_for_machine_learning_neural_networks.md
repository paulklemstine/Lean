# The Hidden Boolean World Inside a Neural Network

A neural network is usually pictured as a river of numbers. Inputs enter, matrices multiply them, nonlinearities bend them, and a prediction emerges. Yet beneath that continuous flow lies a sharply discrete world: every rectified linear unit is either active or inactive. If a network has $k$ such gates, each input produces a binary string of length $k$.

That observation suggests a striking change of viewpoint. Instead of asking only what numerical value the network computes, we can ask which on–off pattern it occupies. The resulting collection of patterns is a finite semantic space for the network. It is a place where Boolean logic, geometry, and statistical learning meet.

The central lesson is both elegant and cautionary. A network with $k$ gates has at most $2^k$ feasible activation patterns, but it need not have all of them. Its activation-invariant decision regions form a Boolean algebra whose indivisible pieces are precisely the feasible patterns. Every classifier that depends only on those patterns factors uniquely through this finite space. And if one allows every possible labeling of the feasible patterns, the resulting concept family has VC dimension exactly equal to the number of feasible patterns.

These statements make a precise Stone-style duality for neural activations—without confusing possible bit strings with realizable ones, or a single classifier with an entire hypothesis class.

## From inputs to patterns

Let $X$ be an input space and suppose a system contains $k$ binary gates. Its activation map is a function

$$
a:X\longrightarrow\{0,1\}^k.
$$

For each input $x$, the vector $a(x)$ records which gates are on. The full cube $\{0,1\}^k$ contains $2^k$ formal patterns, but only some may actually occur. We therefore define the **feasible activation space**

$$
F_a=\{a(x):x\in X\}.
$$

This range, rather than the whole Boolean cube, is the correct finite model of the network’s realized behavior.

Why can patterns fail to occur? Two neurons may always switch together. One gate may duplicate another. Geometric constraints may make a combination of signs impossible. In a simple one-dimensional example, take two threshold gates

$$
a_1(x)=\mathbf 1[x>0],\qquad a_2(x)=\mathbf 1[x>1].
$$

As $x$ moves along the line, the realized patterns are $00$, $10$, and $11$. The pattern $01$ is impossible: one cannot have $x>1$ while also having $x\le 0$. Thus two gates produce three feasible states, not four.

This gives the first counting theorem.

**Feasible-Pattern Bound.** For any activation map with $k$ binary gates, the number of feasible patterns satisfies

$$
|F_a|\le 2^k.
$$

Moreover, equality holds exactly when the activation map is onto $\{0,1\}^k$, meaning that every formal pattern is realized by at least one input.

The equality condition matters. The familiar number $2^k$ is a capacity ceiling, not an automatic count.

## Compressing a classifier without losing information

Suppose a classifier $f:X\to Y$ gives the same label whenever two inputs have the same activation pattern. In symbols,

$$
a(x)=a(y)\quad\Longrightarrow\quad f(x)=f(y).
$$

Call such a classifier **activation-invariant**. It cannot distinguish inputs lying in the same activation fibre. Therefore it can be compressed to a function on the finite feasible space.

**Factorization Theorem.** If $f$ is activation-invariant, then there is a unique function $\bar f:F_a\to Y$ such that

$$
f=\bar f\circ a.
$$

The proof is conceptually simple. For a feasible pattern $p$, choose any input $x$ with $a(x)=p$ and define $\bar f(p)=f(x)$. Activation invariance guarantees that a different representative gives the same answer. Since every feasible pattern has an input witness, no alternative definition of $\bar f$ can satisfy the same factorization.

This theorem turns the activation pattern into a sufficient statistic for any activation-invariant output. Potentially enormous or continuous input spaces are compressed to a finite set without changing the classifier.

## A Boolean algebra of decision regions

Now label not just individual patterns but sets of patterns. For a subset $U\subseteq F_a$, define its realized input region by pulling it back:

$$
R_U=\{x\in X:a(x)\in U\}.
$$

This operation translates Boolean syntax on patterns into geometry on inputs. Complementing $U$ complements $R_U$, and intersecting two pattern sets intersects their realized regions:

$$
R_{F_a\setminus U}=X\setminus R_U,
\qquad
R_{U\cap V}=R_U\cap R_V.
$$

Unions follow from these operations. Distinct subsets of $F_a$ also give distinct input regions, because each feasible pattern has at least one witnessing input. Thus the entire powerset $\mathcal P(F_a)$ embeds faithfully into the collection of regions of $X$.

Which regions appear this way? Exactly those that do not split an activation fibre.

**Region Representation Theorem.** A region $R\subseteq X$ is constant on activation fibres—that is,

$$
a(x)=a(y)\quad\Longrightarrow\quad(x\in R\Longleftrightarrow y\in R)
$$

—if and only if there is a unique subset $U\subseteq F_a$ for which $R=R_U$.

So the finite Boolean algebra $\mathcal P(F_a)$ is neither an arbitrary abstraction nor merely an approximation. It is exactly the algebra of all activation-invariant regions in input space.

This is the Stone-style heart of the picture. In finite Stone duality, a Boolean algebra can be understood through its points, while clopen sets encode Boolean propositions. Here the points are feasible activation patterns. Because $F_a$ is finite and discrete, every subset is clopen. A subset says which patterns receive a positive label; its pullback is the corresponding decision region in the original input geometry.

## The atoms: indivisible semantic states

Every finite Boolean algebra has atoms: nonempty elements containing no smaller nonempty element. In a powerset algebra, these are exactly the singleton sets.

**Atom Theorem.** The atoms of $\mathcal P(F_a)$ are precisely the sets $\{p\}$ with $p\in F_a$. Consequently,

$$
\#\text{atoms}=|F_a|\le 2^k.
$$

It is important not to confuse atoms with all Boolean elements. If there are $r=|F_a|$ feasible patterns, then the algebra has $r$ atoms but $2^r$ elements. The atoms are elementary activation states; arbitrary decision regions are unions of those states.

For the two-threshold example, the three feasible states $00$, $10$, and $11$ are the three atoms. There are $2^3=8$ activation-invariant regions, ranging from the empty region to the whole line.

## What VC dimension really counts

VC dimension belongs to a family of concepts, not to a single fixed decision region. A concept family shatters a finite set $S$ if every subset of $S$ can be obtained by intersecting $S$ with some concept in the family.

Take the richest possible family on $F_a$: all subsets $\mathcal P(F_a)$. It can realize every labeling of every set of feasible patterns.

**Exact VC-Dimension Theorem.** If $F_a$ is finite, then the full powerset concept family has VC dimension

$$
\operatorname{VCdim}(\mathcal P(F_a))=|F_a|.
$$

Indeed, the whole feasible space is shattered: for any desired labeling, choose exactly the positively labeled patterns. No subset larger than $F_a$ exists, so the bound is sharp.

By contrast, a family containing only one fixed region cannot shatter any nonempty set. Pick a point in such a set. Shattering would require both labeling it positive and labeling it negative, but a single region supplies only one trace. This resolves a common category error: one may study the VC dimension of a parameterized family of networks or of all activation-invariant regions, but not meaningfully assign a positive VC dimension to one frozen classifier viewed alone.

Combining the results yields

$$
\operatorname{VCdim}(\mathcal P(F_a))
=\#\text{atoms}
=|F_a|
\le 2^k.
$$

This equality is exact for the full Boolean family on feasible patterns. It is not automatically an equality with the number of linear regions of an arbitrary neural network.

## Geometry still matters

Activation patterns and geometric linear regions often travel together, especially in ReLU networks, but they are not interchangeable without assumptions. Degenerate weights can make different patterns describe the same affine behavior. Conversely, subtleties at gate boundaries can make region conventions differ. In deep networks, later preactivations are generally piecewise affine functions of the original input, not a single global arrangement of one hyperplane per neuron.

The finite semantic model therefore clarifies what is universal and what requires extra geometry. Universally, patterns form a finite quotient; invariant classifiers factor through it; invariant regions form a powerset algebra; and its atoms and full-family VC dimension are counted exactly. Relating those atoms to connected polyhedral cells or maximal affine regions requires nondegeneracy and feasibility hypotheses.

That distinction is productive rather than disappointing. It separates combinatorial capacity from geometric realizability. The number $2^k$ describes the size of the formal Boolean cube. The smaller number $|F_a|$ records what the network can actually experience. Hyperplane-arrangement theory, optimization, and data geometry can then be used to estimate or compute the gap.

## A new map of network behavior

The Stone-style viewpoint offers a clean three-level story. Inputs live in a potentially continuous geometric world. The activation map sends them to a finite space of feasible patterns. Boolean subsets of that space encode all activation-invariant decisions, and pulling them back restores regions in the original input space.

This perspective has practical echoes. Feasible patterns can support compressed explanations: two inputs with the same pattern are indistinguishable to every activation-invariant classifier. They can organize test coverage, because unreachable bit strings should not be counted as observed behaviors. They can expose redundancy, since correlated gates shrink the feasible space. And they suggest capacity bounds based on realized semantic states rather than raw neuron count.

The deepest message is a disciplined version of duality. Syntax consists of Boolean combinations of feasible activation states. Semantics consists of the input regions those combinations describe. The bridge between them is exact, faithful, and finite. A neural network does have a Stone-like shadow—but its points are the patterns the network can realize, not every pattern we can write down.