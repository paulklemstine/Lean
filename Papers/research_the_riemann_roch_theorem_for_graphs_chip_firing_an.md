# Canonical Divisors and Riemann–Roch on Complete Graphs

**Aristotle — July 19, 2026**

## Abstract

Divisor theory on finite graphs translates linear equivalence into chip-firing and gives a discrete Riemann–Roch theorem. This paper develops the canonical calculation for the complete graph $K_n$ from first principles, with particular attention to two normalization issues that can otherwise create an apparent contradiction. For a graph, the canonical divisor is $K_G(v)=\operatorname{val}(v)-2$, while the Baker–Norine rank $r(D)$ differs by one from the dimension convention $\ell(D)=r(D)+1$. We prove directly that the zero divisor on a nonempty graph has rank $0$. For $K_n$ we derive the vertex valency $n-1$, canonical coefficient $n-3$, genus $(n-1)(n-2)/2$, and canonical degree $n(n-3)=2g-2$. Assuming the graph Riemann–Roch identity, specialization to the canonical divisor yields $r(K_G)=g(G)-1$, and hence $r(K_{K_n})=(n-1)(n-2)/2-1$. The cases $n=3,4,5,6$ are evaluated explicitly. We also describe finite computational procedures for the numerical invariants, chip-firing, reduced divisors, and rank testing, and discuss connections with Laplacian lattices, parking functions, critical groups, spanning trees, and permutohedral geometry.

## 1. Introduction

The classical Riemann–Roch theorem relates divisors on an algebraic curve to its genus and canonical divisor. Baker–Norine divisor theory replaces the curve by a finite connected graph and rational functions by integer-valued firing scripts. A divisor is then an integer configuration on the vertices. Firing redistributes chips locally without changing their total, and linear equivalence records which configurations can be reached from one another.

This discrete setting preserves the characteristic form of Riemann–Roch:

$$
r(D)-r(K_G-D)=\deg(D)+1-g(G).
$$

The theorem is both structural and algorithmic. Its terms can be interpreted through the graph Laplacian, and equivalence to an effective divisor can be tested by reduction algorithms. Complete graphs provide the most symmetric examples and admit closed formulas for all elementary invariants.

A frequently encountered calculation proposes the coefficient $n-2$ for the canonical divisor of $K_n$ and then identifies a quantity called $\ell$ with rank while assigning it the value $0$ at the zero divisor. Both steps are inconsistent with the standard conventions. The canonical coefficient is valency minus $2$, hence $n-3$. Moreover, $r(0)=0$ whereas $\ell(0)=r(0)+1=1$. Correcting these points yields the expected canonical rank $g-1$.

Our purpose is to give a self-contained account of that correction and its consequences. The elementary complete-graph formulas are proved independently of Riemann–Roch. The canonical-rank statement is then derived transparently from the Riemann–Roch identity, avoiding any circular claim that the numerical computation proves the full theorem.

## 2. Graphs, divisors, and the Laplacian

Let $G=(V,E)$ be a finite connected loopless undirected graph. Parallel edges may be incorporated by multiplicity, although the complete graphs considered below are simple. The valency $\operatorname{val}(v)$ is the number of incident edge ends at $v$, counted with multiplicity.

**Definition 2.1 (Divisor).** A divisor on $G$ is an integer-valued function $D:V\to\mathbb Z$, customarily written

$$
D=\sum_{v\in V}D(v)\,v.
$$

Its degree is

$$
\deg(D)=\sum_{v\in V}D(v).
$$

The divisor is effective, written $D\ge 0$, if $D(v)\ge 0$ for every $v\in V$.

Negative coefficients represent debt. The degree is the net number of chips and may be negative.

**Definition 2.2 (Laplacian and firing).** For an integer-valued function $f:V\to\mathbb Z$, define

$$
(\Delta f)(v)=\operatorname{val}(v)f(v)-\sum_{w\sim v}f(w),
$$

where adjacency is counted with multiplicity. A principal divisor is a divisor of the form $\Delta f$. Two divisors $D$ and $D'$ are linearly equivalent, written $D\sim D'$, if $D-D'=\Delta f$ for some integer-valued $f$.

With the opposite sign convention, firing according to $f$ changes $D$ to $D-\Delta f$. Firing a single vertex once removes $\operatorname{val}(v)$ chips there and sends one chip along every incident edge. Since every edge contribution occurs once positively and once negatively,

$$
\sum_{v\in V}(\Delta f)(v)=0.
$$

**Lemma 2.3 (Degree invariance).** If $D\sim D'$, then $\deg(D)=\deg(D')$.

**Proof sketch.** Their difference is $\Delta f$. Summing the Laplacian over all vertices cancels every edge contribution, so $\deg(\Delta f)=0$. Hence the degrees agree. $\square$

This elementary conservation law is decisive whenever a proposed effective representative would have negative degree.

## 3. Rank and the zero divisor

**Definition 3.1 (Baker–Norine rank).** If $D$ is not linearly equivalent to an effective divisor, define $r(D)=-1$. Otherwise, $r(D)$ is the largest integer $q\ge 0$ such that, for every effective divisor $E$ of degree $q$, the divisor $D-E$ is linearly equivalent to an effective divisor.

Thus $r(D)\ge q$ means that any placement of $q$ removed chips can be repaired by firing. The definition quantifies over effective divisors, not merely over subsets of vertices: repeated removal from one vertex is allowed.

Some literature uses the dimension

$$
\ell(D)=r(D)+1.
$$

Under this convention, a divisor with no effective representative has dimension $0$, and an effective divisor of rank $0$ has dimension $1$. Rank and dimension encode the same information but must not be interchanged inside a calculation.

**Theorem 3.2 (Rank of the zero divisor).** On every nonempty finite connected graph,

$$
r(0)=0.
$$

**Proof.** The zero divisor is effective, so $r(0)\ge 0$. Choose a vertex $v$ and let $E=v$ be the effective divisor consisting of one chip at $v$. Then $\deg(0-E)=-1$. By degree invariance, every divisor equivalent to $-E$ also has degree $-1$, whereas every effective divisor has nonnegative degree. Thus $-E$ has no effective representative, so $r(0)\not\ge 1$. Therefore $r(0)=0$. $\square$

**Corollary 3.3.** With the dimension normalization, $\ell(0)=1$.

This corollary identifies one source of the apparent canonical-rank paradox: assigning $\ell(0)=0$ silently treats $\ell$ as rank rather than dimension.

## 4. Genus and the canonical divisor

**Definition 4.1 (Graph genus).** For a finite connected graph,

$$
g(G)=|E|-|V|+1.
$$

This is the first Betti number or cyclomatic number: the number of independent cycles. Starting with a spanning tree, which has $|V|-1$ edges, each remaining edge contributes one independent cycle.

**Definition 4.2 (Canonical divisor).** The canonical divisor of $G$ is

$$
K_G=\sum_{v\in V}\bigl(\operatorname{val}(v)-2\bigr)v.
$$

The subtraction by $2$ is part of the standard graph-theoretic convention.

**Proposition 4.3 (Canonical degree formula).** For every finite connected graph,

$$
\deg(K_G)=2g(G)-2.
$$

**Proof.** By the handshaking identity, $\sum_v\operatorname{val}(v)=2|E|$. Therefore

$$
\deg(K_G)=\sum_v(\operatorname{val}(v)-2)
=2|E|-2|V|
=2(|E|-|V|+1)-2
=2g(G)-2.
$$

$\square$

The formula explains why replacing valency minus $2$ by valency minus $1$ cannot be harmless: it increases the canonical degree by $|V|$ and breaks the fundamental relation with genus.

## 5. Complete-graph calculations

Let $K_n$ denote the loopless simple graph on $n\ge 1$ labelled vertices in which every pair of distinct vertices is joined by one edge.

**Lemma 5.1 (Valency).** Every vertex of $K_n$ has valency $n-1$.

**Proof.** A fixed vertex is adjacent to each of the other $n-1$ vertices and not to itself. $\square$

**Theorem 5.2 (Canonical divisor of a complete graph).** For every vertex $v$ of $K_n$,

$$
K_{K_n}(v)=n-3.
$$

Equivalently,

$$
K_{K_n}=(n-3)\sum_{v\in V(K_n)}v.
$$

**Proof.** Substitute $\operatorname{val}(v)=n-1$ into $K_G(v)=\operatorname{val}(v)-2$. $\square$

**Lemma 5.3 (Edge and valency counts).** The number of edges of $K_n$ is $n(n-1)/2$, and the sum of all valencies is $n(n-1)$.

**Proof.** An edge is an unordered pair of distinct vertices, giving $\binom n2=n(n-1)/2$ choices. The valency sum is twice the edge count, or directly $n$ vertices times valency $n-1$. $\square$

**Theorem 5.4 (Genus of a complete graph).** For $n\ge 1$,

$$
g(K_n)=\frac{(n-1)(n-2)}2.
$$

**Proof.** Apply the definition of genus:

$$
g(K_n)=\frac{n(n-1)}2-n+1
=\frac{n^2-3n+2}{2}
=\frac{(n-1)(n-2)}2.
$$

$\square$

**Theorem 5.5 (Canonical degree of a complete graph).** For $n\ge 1$,

$$
\deg(K_{K_n})=n(n-3)=2g(K_n)-2.
$$

**Proof.** There are $n$ vertices, each with canonical coefficient $n-3$, so the degree is $n(n-3)$. Using Theorem 5.4,

$$
2g(K_n)-2=(n-1)(n-2)-2=n^2-3n=n(n-3).
$$

$\square$

For $n=1$ and $n=2$, the canonical divisor has negative coefficients and the genus is $0$. The formulas remain arithmetically valid. The cases central to the requested comparison begin at $n=3$.

## 6. Riemann–Roch and canonical rank

**Theorem 6.1 (Baker–Norine Riemann–Roch).** Let $G$ be a finite connected graph and $D$ a divisor on $G$. Then

$$
r(D)-r(K_G-D)=\deg(D)+1-g(G).
$$

This theorem is the graph analogue of the classical Riemann–Roch formula. Its deep content lies in the symmetry between $D$ and the canonical complement $K_G-D$. The present paper uses the theorem to derive the canonical rank; the elementary formulas in Sections 3–5 do not depend on it.

**Theorem 6.2 (Canonical rank).** On every nonempty finite connected graph satisfying the Riemann–Roch identity,

$$
r(K_G)=g(G)-1.
$$

**Proof.** Substitute $D=K_G$ in Theorem 6.1. Since $K_G-K_G=0$,

$$
r(K_G)-r(0)=\deg(K_G)+1-g(G).
$$

Theorem 3.2 gives $r(0)=0$, and Proposition 4.3 gives $\deg(K_G)=2g(G)-2$. Consequently

$$
r(K_G)=2g(G)-2+1-g(G)=g(G)-1.
$$

$\square$

**Corollary 6.3 (Canonical rank on $K_n$).** For every $n\ge 1$ for which the connected complete graph is nonempty,

$$
r(K_{K_n})=\frac{(n-1)(n-2)}2-1.
$$

**Proof.** Combine Theorem 6.2 with Theorem 5.4. $\square$

For $n=1$ and $n=2$, this gives rank $-1$, consistent with the negative canonical divisor on a genus-zero graph. For $n\ge 3$, the canonical rank is nonnegative.

Under the dimension convention $\ell(D)=r(D)+1$, the same result is

$$
\ell(K_G)=g(G).
$$

Indeed, the dimension form of Riemann–Roch is

$$
\ell(D)-\ell(K_G-D)=\deg(D)+1-g(G),
$$

because adding $1$ to both rank terms cancels. At $D=K_G$, one must use $\ell(0)=1$. This yields $\ell(K_G)=g(G)$ and therefore $r(K_G)=g(G)-1$. There is no contradiction; there are only two shifted normalizations.

## 7. Explicit cases

The complete-graph formulas yield the following data:

$$
\begin{array}{c|c|c|c|c|c}
n & \operatorname{val}(v) & K(v) & g & \deg K & r(K)\\ \hline
3&2&0&1&0&0\\
4&3&1&3&4&2\\
5&4&2&6&10&5\\
6&5&3&10&18&9
\end{array}
$$

**Proposition 7.1 (The triangle).** On $K_3$, the canonical divisor is zero, the genus is $1$, the canonical degree is $0$, and the canonical rank is $0$.

**Proof sketch.** Every vertex has valency $2$, hence canonical coefficient $0$. The graph has three edges and three vertices, so $g=3-3+1=1$. The degree and rank conclusions follow from $K=0$ and Theorem 3.2. $\square$

**Proposition 7.2 (The tetrahedral graph).** On $K_4$, the canonical divisor has coefficient $1$ at every vertex, genus $3$, degree $4$, and rank $2$.

**Proof sketch.** Substitute $n=4$ into Theorems 5.2, 5.4, 5.5, and Corollary 6.3. $\square$

**Proposition 7.3.** On $K_5$, the canonical divisor has coefficient $2$ at every vertex, genus $6$, degree $10$, and rank $5$.

**Proof sketch.** Substitute $n=5$ into the same formulas. $\square$

**Proposition 7.4.** On $K_6$, the canonical divisor has coefficient $3$ at every vertex, genus $10$, degree $18$, and rank $9$.

**Proof sketch.** Substitute $n=6$ into the same formulas. $\square$

The coefficient, genus, and degree computations are elementary and unconditional. The rank values are consequences of the Riemann–Roch theorem, except that the $K_3$ value also follows directly because its canonical divisor is zero.

## 8. Algorithms

### 8.1 Closed-form invariant evaluation

For complete graphs, no adjacency matrix is needed. Given $n$, compute

$$
\operatorname{val}=n-1,
\quad K(v)=n-3,
\quad g=\frac{(n-1)(n-2)}2,
\quad \deg K=n(n-3),
\quad r(K)=g-1.
$$

Each requires constant many integer operations, so the arithmetic-operation complexity is $O(1)$. In bit complexity, multiplication of $O(\log n)$-bit integers determines the cost.

A robust implementation should verify the consistency identity $\deg K=2g-2$. This catches the valency-minus-$1$ convention error immediately.

### 8.2 Simulating chip-firing on $K_n$

Represent a divisor by an integer vector $(d_1,\ldots,d_n)$. Firing vertex $i$ once performs

$$
d_i\leftarrow d_i-(n-1),
\qquad
d_j\leftarrow d_j+1\quad(j\ne i).
$$

A direct update takes $O(n)$ time and preserves $\sum_j d_j$. If a firing script $f=(f_1,\ldots,f_n)$ is given, the complete-graph Laplacian satisfies

$$
(\Delta f)_i=n f_i-\sum_{j=1}^n f_j.
$$

Thus the entire scripted update can be computed in $O(n)$ time after one sum, rather than applying individual firings one by one.

### 8.3 Reduced representatives and Dhar’s algorithm

Choose a sink $q$. A divisor is $q$-reduced when it is nonnegative away from $q$ and every nonempty set of nonsink vertices contains a vertex whose chip count is smaller than its number of edges leaving that set. Dhar’s burning algorithm tests this condition. Begin with the sink burned; repeatedly burn any unburned vertex that has fewer chips than edges to burned vertices. If all vertices burn, the divisor is reduced. If some remain, firing the unburned set advances the reduction process.

For a dense graph represented by an adjacency matrix, a straightforward burning pass costs $O(n^2)$. On $K_n$, symmetry and sorted coordinates permit faster bookkeeping. Reduction is fundamental because each divisor class has a unique $q$-reduced representative, turning equivalence questions into finite inequalities.

### 8.4 Finite rank testing

To test whether $r(D)\ge q$, enumerate effective divisors $E$ of degree $q$ and test whether $D-E$ is equivalent to an effective divisor, for example via sink reduction. There are

$$
\binom{n+q-1}{q}
$$

weak compositions of $q$ into $n$ vertex counts. The naive algorithm is therefore combinatorial in $q$ and $n$. It is useful for small examples but not the preferred method for large instances. Parking-function descriptions and rank algorithms exploit structure to avoid exhaustive enumeration.

## 9. Structural connections and applications

### 9.1 The critical group

Degree-zero divisors form the lattice

$$
A_{n-1}=\left\{x\in\mathbb Z^n:\sum_i x_i=0\right\}.
$$

Principal divisors form the image of the graph Laplacian inside this lattice. Their quotient is the critical group, also called the Jacobian or sandpile group. For $K_n$, the Laplacian matrix is $nI-J$, where $J$ is the all-ones matrix. On the real zero-sum hyperplane, $J$ vanishes, so the Laplacian acts as multiplication by $n$. Integrality leaves a nontrivial quotient whose structure is $(\mathbb Z/n\mathbb Z)^{n-2}$ and whose order is $n^{n-2}$.

The order agrees with the number of spanning trees of $K_n$. This is a manifestation of the matrix-tree theorem and Cayley’s formula. Thus chip-firing classes and labelled trees are enumerated by the same number for structural reasons.

### 9.2 Parking functions and reduced divisors

After choosing a sink and sorting nonsink coordinates, reducedness becomes a family of inequalities closely related to parking functions. A classical parking function is a sequence whose sorted form $(a_1,\ldots,a_{n-1})$ satisfies $a_i<i$ under a standard zero-based convention. Burning explains this condition: each successive car, or vertex, must find enough previously available capacity, or burned neighbors.

This correspondence supplies finite normal forms for divisor classes. It is also the natural route toward a complete-graph proof of Riemann–Roch: canonical complementation should reverse the relevant defect statistic on reduced configurations.

### 9.3 Permutohedral geometry

Real divisors modulo constants live in an $(n-1)$-dimensional quotient. Hyperplanes where coordinates coincide divide this space into Weyl chambers of type $A$. Sorting a divisor chooses a chamber, and firing vectors lie in the type-$A$ root lattice. The resulting fan is related to the normal fan of the permutohedron. Since $K_{K_n}$ is the symmetric vector with every coordinate $n-3$, the map $D\mapsto K-D$ acts as an affine reflection. The rank correction in Riemann–Roch can therefore be sought as an integer-point shadow of an order-reversing chamber duality.

### 9.4 Network interpretations

The Laplacian also governs electrical potentials, diffusion, and consensus. Chip-firing differs from continuous flow because firing scripts are integral and effectiveness imposes inequalities, but the conservation law is shared. Critical groups measure an arithmetic obstruction invisible over the real numbers. This makes divisor theory relevant to discrete network dynamics: local redistribution may be easy over continuous quantities yet retain finite torsion when resources are indivisible.

## 10. Discussion

The complete-graph calculation separates three logical layers. First, graph counting gives valency, edge count, genus, and canonical degree. Second, the definition of rank and degree invariance give $r(0)=0$. Third, the Riemann–Roch identity supplies canonical duality and therefore $r(K)=g-1$. Keeping these layers distinct prevents the elementary numerical checks from being mistaken for a proof of the full Riemann–Roch theorem.

The correction to the proposed canonical divisor is forced in several independent ways. Local definition gives $n-3$. Global degree gives $n(n-3)$. Topology gives $2g-2=n(n-3)$. A proposed coefficient $n-2$ fails both local convention and global consistency. Likewise, the rank/dimension shift can be detected by the zero divisor: $r(0)=0$ but $\ell(0)=1$.

The examples $K_3$ through $K_6$ illustrate increasingly positive canonical divisors. The triangle is genus one and has trivial canonical divisor, paralleling the degree-zero canonical class of a genus-one curve. For $n\ge 4$, the canonical divisor is effective and its rank grows quadratically with $n$, tracking the cycle-space dimension rather than merely the local valency.

## 11. Future work

A direct parking-function proof of Riemann–Roch for $K_n$ would complete the structural narrative. The main task is to express rank as a minimum defect over reduced representatives and show that canonical complementation reverses that defect.

A second direction is an explicit integral derivation of the critical group as $(\mathbb Z/n\mathbb Z)^{n-2}$ using the type-$A$ root lattice and Smith normal form. This would clarify the one global relation that distinguishes the quotient from naive coordinatewise reduction modulo $n$.

A third direction is to construct mutually inverse bijections among rooted spanning trees, recurrent chip configurations, and sink-reduced divisor classes. The burning algorithm should provide the maps and explain the common count $n^{n-2}$ without relying only on determinant evaluation.

Finally, the canonical involution should be studied on the permutohedral fan. Sorting selects Weyl chambers, while $D\mapsto K-D$ reverses inequalities around a symmetric lattice point. A polyhedral account could turn the rank correction into a visible lattice-point duality and suggest algorithms extending beyond complete graphs.

## 12. A reproducible numerical protocol

The principal formulas can be checked without constructing firing classes. For each integer $n\ge 1$, first count $n-1$ neighbors at a fixed vertex. Subtract $2$ to obtain the canonical coefficient $n-3$. Multiply by $n$ for the canonical degree. Independently count unordered vertex pairs to obtain $n(n-1)/2$ edges, then subtract $n-1$ to obtain the genus. Finally compare the canonical degree with $2g-2$. For canonical rank, invoke Riemann–Roch only after these independent quantities have been established. This order prevents the desired rank from being fed back into an earlier definition.

The protocol also distinguishes theorem testing from theorem proving. Agreement for $n=3,4,5,6$ illustrates the formulas and catches convention errors, but finite examples alone cannot establish an identity for every $n$. The general elementary formulas follow from symbolic counting, while the rank formula follows from the general Riemann–Roch theorem. Numerical software should preserve this distinction in its output: it may label valency, genus, and degree as direct computations and canonical rank as a Riemann–Roch consequence.

## 13. Conclusion

For the complete graph $K_n$, the standard canonical divisor is constant with coefficient $n-3$, not $n-2$. Its genus and degree are

$$
g(K_n)=\frac{(n-1)(n-2)}2,
\qquad
\deg(K_{K_n})=n(n-3)=2g(K_n)-2.
$$

The zero divisor on every nonempty graph has rank $0$. Consequently, the Riemann–Roch theorem evaluated at the canonical divisor gives

$$
r(K_{K_n})=g(K_n)-1
=\frac{(n-1)(n-2)}2-1.
$$

The values for $n=3,4,5,6$ are respectively $0,2,5,9$. The apparent contradictory value disappears once rank is distinguished from the shifted dimension $\ell=r+1$ and the canonical coefficient is defined using valency minus $2$. These corrections reveal the intended synthesis: local chip-firing, global cycle topology, and canonical duality are different facets of one discrete Riemann–Roch theory.
