# One Matrix Word, Three Views of a Network

## How a short algebraic expression counts neighborhoods and measures degree inequality

A network can be read in many languages. A graph theorist sees vertices joined by edges. A linear algebraist sees a square array of zeros and ones. A statistician sees a distribution of local connection counts. These descriptions can feel unrelated, yet a remarkably short matrix expression translates perfectly among all three.

Let $G$ be a finite simple undirected graph. Its vertices might represent people, atoms, web pages, transit stations, or interacting components. Write $A$ for its adjacency matrix: the entry $A_{uv}$ is $1$ when vertices $u$ and $v$ are connected, and $0$ otherwise. Let $d(v)$ be the degree of vertex $v$, the number of its neighbors, and let $D$ be the diagonal matrix whose $v$th diagonal entry is $d(v)$. Finally, let $\mathbf 1$ be the column vector consisting entirely of ones.

The central identity is

$$
\mathbf 1^{T}ADA\mathbf 1=\sum_{v\in V(G)}d(v)^3.
$$

This is the Adjacency–Degree Moment Theorem. It says that the scalar obtained from the matrix word $ADA$ is exactly the third raw moment of the graph’s degree sequence. The same number also counts all homomorphisms from a three-leaf star into $G$. Thus one quantity is simultaneously a matrix observable, a statistic of connectivity, and a count of a small network pattern.

## Following the flow of ones

The identity becomes intuitive when the matrices are treated as operations rather than static tables. Multiplication by $A$ sends a value at each vertex to the sum of the values at its neighbors. Starting with $\mathbf 1$, every vertex initially carries the value $1$. After one multiplication by $A$, vertex $v$ carries

$$
(A\mathbf 1)_v=d(v),
$$

because the operation adds one for each neighbor.

Multiplication by $D$ then scales the value at $v$ by its degree. The value becomes $d(v)^2$. A second multiplication by $A$ sends these squared degree values across the edges. The final multiplication by $\mathbf 1^T$ adds all resulting coordinates.

At first sight, this seems to produce a complicated sum involving the degrees of neighboring vertices. Symmetry is the key simplification. Because the graph is undirected, $A$ is symmetric, so $\mathbf 1^TA=(A\mathbf 1)^T$. Consequently,

$$
\mathbf 1^TADA\mathbf 1
=(A\mathbf 1)^TD(A\mathbf 1)
=d^TDd
=\sum_v d(v)^3,
$$

where $d=A\mathbf 1$ is the degree vector. The calculation is short, but its interpretation is rich.

In fact, the graph is only one instance of a broader matrix principle. Suppose $A$ is any finite real symmetric matrix, define its row sum by $r(i)=\sum_j A_{ij}$, and place these row sums on the diagonal of $D_r$. Then

$$
\mathbf 1^TAD_rA\mathbf 1=\sum_i r(i)^3.
$$

The entries of $A$ need not be only zeros and ones. They may be weighted, positive or negative, provided symmetry is retained. The theorem therefore applies to weighted interaction networks and symmetric coupling matrices as well as ordinary graphs.

## The three-armed star hidden in the formula

There is another way to count the right-hand side. Consider the star $K_{1,3}$: one central vertex connected to three leaves, with no edges among the leaves. A graph homomorphism from this star to $G$ assigns every star vertex to a vertex of $G$ while sending each star edge to an edge of $G$.

Choose the image $v$ of the center. Each leaf may then be sent independently to any neighbor of $v$. The images of different leaves are allowed to coincide, because a homomorphism is not required to be injective. There are therefore $d(v)^3$ choices once the center has been placed at $v$. Summing over all possible centers gives

$$
\operatorname{hom}(K_{1,3},G)=\sum_v d(v)^3.
$$

Combining this count with the matrix identity yields the Matrix–Star Correspondence:

$$
\mathbf 1^TADA\mathbf 1
=\operatorname{hom}(K_{1,3},G).
$$

This equality emphasizes that a global-looking matrix product is exactly a local motif count. No search through all four-tuples of vertices is conceptually necessary. One can either multiply matrices, sum degree cubes, or count ordered triples of neighbors around every possible center. All three routes reach the same integer.

This distinction between ordered triples and sets of three distinct neighbors matters. If a vertex has neighbors $x$ and $y$, the choices $(x,x,y)$, $(x,y,x)$, and $(y,x,x)$ are different homomorphisms. Repetition is permitted. The count is therefore $d(v)^3$, not $\binom{d(v)}{3}$. The theorem concerns star homomorphisms, not necessarily embedded star subgraphs.

## A detector of hubs

Why should the third degree moment be interesting? Cubing magnifies large values. A vertex of degree $10$ contributes $1000$, while ten vertices of degree $1$ contribute only $10$ altogether. The observable is therefore strongly sensitive to hubs.

Compare two graphs with the same number of edges. In a graph where connections are distributed evenly, the degrees cluster near their average and the sum of cubes remains moderate. In a hub-and-spoke graph, a small number of vertices carry many edges, and their cubic contributions dominate. The quantity $\sum_v d(v)^3$ is not merely a measure of network size: it records how unevenly connectivity is concentrated.

For example, the star with $m$ leaves has one vertex of degree $m$ and $m$ vertices of degree $1$. Its moment is

$$
m^3+m.
$$

A cycle on $n$ vertices has every degree equal to $2$, so its moment is

$$
8n.
$$

These formulas reveal sharply different scaling. The cycle grows linearly with its number of vertices, while the star’s central hub creates cubic growth in the number of leaves.

The path on $n\ge 2$ vertices provides an intermediate example. Its two endpoints have degree $1$, while its $n-2$ interior vertices have degree $2$. Hence

$$
\sum_v d(v)^3=2+8(n-2)=8n-14.
$$

The same number is obtained by evaluating $\mathbf 1^TADA\mathbf 1$ or by counting maps of the three-leaf star into the path.

## Why the matrix language matters

If the answer is just a sum of cubes, why write matrices at all? Because $ADA$ belongs to a much larger vocabulary of noncommutative words built from $A$ and $D$. The order of the letters matters: in general $AD\ne DA$. Each word describes a sequence of neighbor aggregation and degree-dependent weighting. Testing such a word between $\mathbf 1^T$ and $\mathbf 1$ turns it into a scalar network observable.

The simplest examples already recover familiar quantities. Since $A\mathbf 1=d$,

$$
\mathbf 1^TA\mathbf 1=\sum_v d(v)=2|E(G)|.
$$

The word $ADA$ reaches the third moment. More generally, inserting powers of $D$ points toward a prospective family relating $\mathbf 1^TAD^kA\mathbf 1$ to higher degree moments and stars with more leaves. Establishing that family uniformly, and connecting still longer words with richer patterns, is a natural next step.

Longer words may describe richer patterns. Alternating adjacency steps with degree decorations points naturally toward caterpillar-shaped graphs: a central path with leaves attached along it. The matrix word would record movement along the spine, while powers of $D$ would record independent leaf choices. Developing this prospective dictionary between algebraic expressions and decorated pattern counts is a natural research direction.

## What the observable knows—and what it forgets

The moment $\sum_v d(v)^3$ depends only on the multiset of degrees. Two nonisomorphic graphs with the same degree sequence necessarily have the same value. It cannot, by itself, reconstruct a general network. A six-vertex cycle and two disjoint triangles, for instance, both have six vertices of degree $2$, so both yield $48$, although their connectivity is entirely different.

That limitation is instructive. A single observable compresses a large graph into one number, and compression discards information. The right question is not whether one moment knows everything, but how a family of moments accumulates structural information. A prospective family of star moments would reveal the degree multiset: for an $n$-vertex graph, enough power sums of the degrees determine the elementary symmetric polynomials through Newton’s identities, and therefore determine the multiset of degrees. Decorated caterpillar counts may then probe how those degrees are arranged along walks.

This viewpoint connects network statistics with spectral graph theory. Spectral methods seek information from matrices associated with a graph. Ordinary adjacency eigenvalues provide powerful but incomplete fingerprints: distinct graphs can share a spectrum. Adjacency–degree words enrich the available observations by mixing connections with local degree data. The theorem here isolates a particularly transparent member of that family and explains exactly what it measures.

## A practical three-way check

The correspondence gives a useful computational consistency test. Given any finite undirected graph, one may calculate:

1. the matrix scalar $\mathbf 1^TADA\mathbf 1$;
2. the degree statistic $\sum_v d(v)^3$;
3. the number of ordered choices $(v,x,y,z)$ with $x$, $y$, and $z$ all neighbors of $v$.

The theorem guarantees that the three outputs agree. If they do not, the graph data, matrix construction, or counting routine contains an error. This makes the identity valuable not only as theory but also as a diagnostic in network software.

The matrix method is convenient when linear-algebra infrastructure is already present. The degree method is usually fastest for sparse graphs: after degrees are known, it needs only one cubic evaluation per vertex. Explicit star enumeration is slower, but it exposes the combinatorial objects being counted and can be adapted when individual homomorphisms must be inspected.

## A small bridge with a wide span

The expression $\mathbf 1^TADA\mathbf 1$ is only a few symbols long. Yet it joins three scales of description. At the microscopic level are ordered selections of neighbors around a center. At the statistical level is the third moment of the degree distribution. At the algebraic level is a scalar extracted from a noncommutative matrix word.

That bridge offers a model for a broader research program: translate matrix words into pattern counts, determine which families of words distinguish which families of graphs, and understand precisely where different networks become indistinguishable. The immediate theorem does not claim that one number reconstructs a graph. Its achievement is cleaner and more fundamental: it reveals that three apparently different measurements are exactly the same measurement.

In network science, such equivalences are especially valuable. They let intuition travel. A statistician’s sensitivity to hubs becomes a graph theorist’s star count and a physicist’s matrix observable. Once those languages are recognized as translations of one another, methods developed in one setting can illuminate the others.