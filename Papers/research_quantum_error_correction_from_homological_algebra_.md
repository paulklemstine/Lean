# CSS Quantum Codes as Homology: Dimension Identities and the Hypercube Graph Counterexample

## Abstract

Calderbank–Shor–Steane quantum codes admit a natural description by a length-two chain complex. For finite-dimensional vector spaces over a field $F$, let

$$
A\xrightarrow{d_2}B\xrightarrow{d_1}C,
\qquad d_1d_2=0.
$$

The middle homology $H=\ker d_1/\operatorname{im}d_2$ is the logical space. We derive the additive CSS dimension identity

$$
\dim H+\operatorname{rank}d_1+\operatorname{rank}d_2=\dim B,
$$

an Euler-type identity involving zeroth homology, and the graph specialization $k=E-V+\beta_0$. Applying these results to the $n$-dimensional hypercube graph $Q_n$ gives

$$
k=2^{n-1}(n-2)+1.
$$

Hence the graph code encodes one logical qubit only for $n=2$; the values at $n=4,6,8$ are respectively $17$, $129$, and $769$. We also prove that the graph girth is exactly $4$ for every $n\ge2$, contradicting a proposed graph-systolic scaling $2^{n/2}$ for $n\ge5$. The analysis distinguishes graph girth from full CSS distance and distinguishes the hypercube graph from filled cubical, boundary, and periodic complexes. Algorithms for dimension, hypercube parameter generation, and girth certification are given together with complexity estimates.

## 1. Introduction

Quantum error correction protects information without copying an unknown quantum state. In a CSS code, two compatible families of binary linear checks detect complementary error types. Compatibility is often written as an orthogonality relation between check matrices. The same relation can be expressed as the defining equation of a chain complex: a boundary followed by a boundary is zero.

This reformulation is more than terminology. It identifies the encoded logical degrees of freedom with a quotient of cycles by boundaries, namely a homology group. It also separates two questions that are sometimes conflated:

1. **Dimension:** how many logical qubits are encoded?
2. **Distance:** what is the minimum weight of a nontrivial logical operator?

The first question reduces to ranks of linear maps. The second requires minimum-weight representatives in homology and cohomology. For graph complexes, the primal minimum is the girth, but a full CSS distance additionally requires dual data.

The hypercube provides a useful test. The phrase “hypercube complex” can denote the one-skeleton graph, the filled cubical ball, its boundary sphere, or a periodic cubical torus. These objects have different chain groups and different homology. We examine the literal graph model: vertices are binary strings and edges join strings differing in one coordinate. Its logical dimension is its circuit rank, which grows rapidly with dimension, while its girth remains four.

The main results are:

- the CSS dimension identity over an arbitrary field;
- an Euler dimension identity;
- the graph circuit-rank formula;
- the exact hypercube logical dimension $2^{n-1}(n-2)+1$;
- uniqueness of $Q_2$ among positive-dimensional hypercubes with one graph-homological logical qubit;
- exact values $17$, $129$, and $769$ for $Q_4$, $Q_6$, and $Q_8$;
- constant hypercube girth $4$ for every $n\ge2$;
- the strict gap $4<2^{n/2}$ for $n\ge5$.

## 2. Algebraic setting

### 2.1. Linear-algebraic preliminaries

For a linear map $f:U\to W$ between finite-dimensional vector spaces, its kernel is the subspace of vectors sent to zero and its image is the subspace of attained outputs. The rank–nullity theorem states

$$
\dim(\ker f)+\dim(\operatorname{im}f)=\dim U.
$$

The rank of $f$ is $\operatorname{rank}f=\dim(\operatorname{im}f)$. If $Y\subseteq X$ are finite-dimensional vector spaces, the quotient $X/Y$ identifies vectors of $X$ that differ by an element of $Y$, and

$$
\dim(X/Y)+\dim Y=\dim X.
$$

These two identities supply all dimension calculations below. The quotient is not merely a numerical subtraction: it records the equivalence relation that determines which physical configurations represent the same logical configuration.

Over $\mathbb F_2$, addition and subtraction coincide. A vector relative to a chosen basis can be viewed as a subset of basis elements, and its Hamming weight is the size of that subset. Linear maps are binary matrices, and their ranks can be computed by row reduction using exclusive-or operations.

### 2.2. Chain complexes

Let $F$ be a field, and let $A$, $B$, and $C$ be vector spaces over $F$. A length-two chain complex consists of linear maps

$$
A\xrightarrow{d_2}B\xrightarrow{d_1}C
$$

satisfying

$$
d_1\circ d_2=0.
$$

The middle space $B$ is the physical space. In a binary quantum code, $F=\mathbb F_2$ and a chosen basis of $B$ indexes physical qubits.

**Definition 2.1 (Cycles).** The cycle space is

$$
Z=\ker d_1\subseteq B.
$$

**Definition 2.2 (Boundaries).** The boundary space is

$$
D=\operatorname{im}d_2\subseteq B.
$$

**Lemma 2.3 (Boundaries are cycles).** One has $D\subseteq Z$.

**Proof sketch.** If $b\in D$, then $b=d_2(a)$ for some $a\in A$. The chain condition gives $d_1(b)=d_1d_2(a)=0$, so $b\in\ker d_1=Z$. $\square$

**Definition 2.4 (Middle homology and logical dimension).** The middle homology is the quotient

$$
H=Z/D=\ker d_1/\operatorname{im}d_2.
$$

When the spaces are finite-dimensional, the logical dimension is

$$
k=\dim_F H.
$$

For $F=\mathbb F_2$, this is the number of encoded logical qubits.

This quotient gives the conceptual content of the CSS construction. A cycle satisfies the $d_1$ constraints. Two cycles differ by no logical information when their difference is generated by $d_2$. Thus a logical state is an equivalence class of cycles modulo boundaries.

### 2.3. Zeroth homology

**Definition 2.5 (Zeroth Betti number).** Define

$$
H_0=C/\operatorname{im}d_1,
\qquad
\beta_0=\dim_F H_0.
$$

For a graph incidence complex, $\beta_0$ is the number of connected components. In the abstract setting, it measures the codimension of the image of $d_1$ in $C$.

## 3. Structural dimension theorems

All spaces in this section are assumed finite-dimensional whenever their dimensions occur.

**Lemma 3.1 (Homology–boundary decomposition).** The logical dimension, boundary rank, and cycle dimension satisfy

$$
k+\operatorname{rank}d_2=\dim Z.
$$

**Proof sketch.** Since $D\subseteq Z$, the quotient dimension formula yields

$$
\dim(Z/D)+\dim D=\dim Z.
$$

Substitute $k=\dim(Z/D)$ and $\dim D=\operatorname{rank}d_2$. $\square$

**Lemma 3.2 (Cycle–check decomposition).** The cycle dimension and rank of $d_1$ satisfy

$$
\dim Z+\operatorname{rank}d_1=\dim B.
$$

**Proof sketch.** This is rank–nullity for $d_1:B\to C$, because $Z=\ker d_1$. $\square$

**Theorem 3.3 (CSS Dimension Theorem).** For every finite-dimensional length-two chain complex,

$$
k+\operatorname{rank}d_1+\operatorname{rank}d_2=\dim B.
$$

Equivalently,

$$
k=\dim B-\operatorname{rank}d_1-\operatorname{rank}d_2.
$$

**Proof sketch.** Add the identities of Lemmas 3.1 and 3.2 after eliminating $\dim Z$. Explicitly,

$$
k+\operatorname{rank}d_2=\dim Z
$$

and

$$
\dim Z=\dim B-\operatorname{rank}d_1.
$$

Substitution gives the result. The additive statement is primary because it avoids any ambiguity from truncated subtraction when dimensions are represented by nonnegative integers. $\square$

The formula is field-independent. Binary arithmetic is essential for the usual qubit interpretation, but the dimension theorem itself is ordinary finite-dimensional linear algebra over any field.

**Theorem 3.4 (Euler Dimension Identity).** One has

$$
\beta_0+\dim B=\dim Z+\dim C.
$$

**Proof sketch.** Applying the quotient dimension formula to $H_0=C/\operatorname{im}d_1$ gives

$$
\beta_0+\operatorname{rank}d_1=\dim C.
$$

Rank–nullity gives

$$
\dim Z+\operatorname{rank}d_1=\dim B.
$$

Eliminating $\operatorname{rank}d_1$ produces the claimed identity. $\square$

**Corollary 3.5 (Vanishing second boundary).** If $d_2=0$, then

$$
k=\dim Z.
$$

**Proof sketch.** The image of the zero map has dimension zero, so Lemma 3.1 reduces to $k=\dim Z$. Equivalently, the quotient by the zero boundary space is the cycle space itself. $\square$

## 4. Graph complexes

Let $G$ be a finite undirected graph with vertex set of size $V$ and edge set of size $E$. Over $\mathbb F_2$, define

$$
B=\mathbb F_2^E,
\qquad
C=\mathbb F_2^V.
$$

The boundary map $d_1:B\to C$ sends each edge to the sum of its two endpoints. A set of edges lies in $\ker d_1$ exactly when every vertex has even incidence in that edge set. Such edge sets are the binary cycles. Because a graph considered as a one-dimensional complex has no $2$-cells, set $A=0$ and $d_2=0$.

**Theorem 4.1 (Graph Circuit-Rank Formula).** For a finite graph with $E$ edges, $V$ vertices, and $\beta_0$ connected components, the logical dimension of its one-dimensional homological code is

$$
k=E-V+\beta_0.
$$

In additive form,

$$
k+V=E+\beta_0.
$$

**Proof sketch.** By Corollary 3.5, $k=\dim\ker d_1$. The Euler Dimension Identity gives

$$
\beta_0+E=k+V,
$$

because $\dim B=E$ and $\dim C=V$. Rearranging proves the result. $\square$

**Corollary 4.2 (Connected graph).** If $G$ is connected, then

$$
k=E-V+1.
$$

This is the circuit rank, also called the cyclomatic number or first Betti number. A spanning tree has $V-1$ edges. Each of the remaining $E-(V-1)$ edges creates one independent fundamental cycle, yielding the same count.

### 4.1. The role of higher-dimensional cells

The graph formula depends on $d_2=0$. If faces are attached, $d_2$ is generally nonzero. A cycle around the boundary of an attached face then belongs to $\operatorname{im}d_2$ and becomes trivial in homology. Therefore a wire-frame square has first Betti number one, whereas a filled square has first Betti number zero.

This distinction is essential in code design. The incidence graph alone does not determine the homology of a higher-dimensional complex; one must also specify which cycles are filled by faces and higher cells.

## 5. The hypercube graph

### 5.1. Definition and elementary counts

**Definition 5.1 (Hypercube graph).** The $n$-dimensional hypercube graph $Q_n$ has vertex set

$$
\{0,1\}^n.
$$

Two vertices are adjacent if and only if they differ in exactly one coordinate.

There are

$$
V_n=2^n
$$

vertices. Every vertex has degree $n$, so the sum of degrees is $n2^n$. Each edge contributes two to that sum, hence

$$
E_n=n2^{n-1}.
$$

The graph is connected: any binary string can be transformed into any other by flipping the coordinates in which they differ.

**Theorem 5.2 (Hypercube Logical-Dimension Formula).** For $n\ge1$, the one-dimensional homological code of $Q_n$ has

$$
k_n=n2^{n-1}-2^n+1
   =2^{n-1}(n-2)+1
$$

logical qubits.

**Proof sketch.** Apply Corollary 4.2 with $E=E_n=n2^{n-1}$ and $V=V_n=2^n$:

$$
k_n=E_n-V_n+1=n2^{n-1}-2^n+1.
$$

Factor $2^{n-1}$ using $2^n=2\cdot2^{n-1}$. $\square$

**Theorem 5.3 (Unique one-qubit hypercube graph).** For every $n\ge1$,

$$
k_n=1\quad\Longleftrightarrow\quad n=2.
$$

**Proof sketch.** The closed formula gives

$$
k_n-1=2^{n-1}(n-2).
$$

Since $2^{n-1}>0$, the product is zero exactly when $n-2=0$. Conversely, substitution of $n=2$ gives $k_2=1$. $\square$

**Corollary 5.4 (Uniform failure above dimension two).** If $n\ge3$, then

$$
k_n\ge5.
$$

**Proof sketch.** For $n\ge3$, one has $2^{n-1}\ge4$ and $n-2\ge1$. Therefore

$$
k_n=2^{n-1}(n-2)+1\ge4\cdot1+1=5.
$$

$\square$

### 5.2. Requested numerical instances

The parameter computations for the selected dimensions are:

| Graph | Vertices $V_n$ | Edges $E_n$ | Logical qubits $k_n$ |
|---|---:|---:|---:|
| $Q_4$ | $16$ | $32$ | $17$ |
| $Q_6$ | $64$ | $192$ | $129$ |
| $Q_8$ | $256$ | $1024$ | $769$ |

Each row follows from $V_n=2^n$, $E_n=n2^{n-1}$, and $k_n=E_n-V_n+1$. These values refute the one-logical-qubit prediction for the hypercube graph.

## 6. Girth and the proposed distance scale

### 6.1. Parity and bipartiteness

For a vertex $x=(x_1,\dots,x_n)\in\{0,1\}^n$, define its parity by

$$
p(x)=x_1+\cdots+x_n\pmod 2.
$$

**Lemma 6.1 (Edge parity flip).** Adjacent vertices of $Q_n$ have opposite parity.

**Proof sketch.** Adjacent vertices differ in exactly one bit. Flipping one bit changes the coordinate sum by one modulo two. $\square$

**Lemma 6.2 (Walk parity law).** If a walk of length $\ell$ begins at $x$ and ends at $y$, then

$$
p(y)=p(x)+\ell\pmod 2.
$$

**Proof sketch.** Apply Lemma 6.1 once per edge and induct on the walk length. $\square$

**Corollary 6.3 (Even closed walks).** Every closed walk in $Q_n$ has even length. In particular, $Q_n$ contains no triangle.

**Proof sketch.** Set $y=x$ in Lemma 6.2. Then $\ell=0$ modulo two. $\square$

### 6.2. Exact girth

**Lemma 6.4 (Existence of a square).** If $n\ge2$, then $Q_n$ contains a cycle of length four.

**Proof sketch.** Choose distinct coordinates $i$ and $j$. Starting from any vertex, flip $i$, then $j$, then $i$, then $j$. The resulting four edges return to the initial vertex, and the intermediate vertices are distinct. $\square$

**Theorem 6.5 (Hypercube Girth Theorem).** For every $n\ge2$,

$$
\operatorname{girth}(Q_n)=4.
$$

**Proof sketch.** The graph is simple, so cycles of length one or two do not occur. Corollary 6.3 excludes length three. Thus every cycle has length at least four. Lemma 6.4 supplies a four-cycle. $\square$

**Theorem 6.6 (Exponential-scale gap).** For every integer $n\ge5$,

$$
4<2^{n/2}.
$$

**Proof sketch.** Since $n/2>2$ and the function $x\mapsto2^x$ is strictly increasing,

$$
2^{n/2}>2^2=4.
$$

$\square$

Combining Theorems 6.5 and 6.6 shows that the graph systole is strictly smaller than the proposed value $2^{n/2}$ for $n\ge5$.

### 6.3. Why girth is not automatically CSS distance

For a finite binary chain complex, define the Hamming weight of a chain as the number of nonzero coordinates in a chosen cell basis. A primal logical operator corresponds to a nonzero class in homology, and its minimum possible weight is a systolic quantity. A dual logical operator corresponds to a nonzero cohomology class, with a minimum cosystolic weight. Under the standard nondegeneracy assumptions, the CSS distance is expected to be

$$
d=\min(d_{\mathrm{primal}},d_{\mathrm{dual}}).
$$

For a graph, the minimum weight of a nonzero cycle is its girth, so $d_{\mathrm{primal}}=4$ for $Q_n$ with $n\ge2$. This alone does not determine $d_{\mathrm{dual}}$. Accordingly, the proven statement is that the primal graph systole is four and cannot scale as $2^{n/2}$; identifying a complete CSS distance requires a fully specified dual check structure.

## 7. Algorithms

### 7.1. Logical dimension from boundary matrices

Suppose $D_2$ and $D_1$ are matrices over $\mathbb F_2$ representing $d_2$ and $d_1$. The input must satisfy

$$
D_1D_2=0.
$$

The logical dimension algorithm is:

1. Verify the matrix dimensions are compatible.
2. Multiply $D_1D_2$ over $\mathbb F_2$ and confirm it is zero.
3. Compute $r_1=\operatorname{rank}D_1$ by binary Gaussian elimination.
4. Compute $r_2=\operatorname{rank}D_2$ similarly.
5. If $N$ is the number of columns of $D_1$, return

$$
k=N-r_1-r_2.
$$

For dense matrices of dimensions at most $N$, ordinary elimination takes $O(N^3)$ bit operations in a simple implementation, while packed-bit methods improve practical performance. The chain-condition check is also polynomial. Sparse topological matrices admit specialized methods.

### 7.2. Hypercube parameter generation

The graph need not be explicitly constructed to obtain its dimensions. Given $n\ge1$, compute

$$
V=2^n,
\qquad
E=n2^{n-1},
\qquad
k=E-V+1.
$$

Integer exponentiation by squaring requires $O(\log n)$ multiplications, though the output itself has $O(n)$ bits. The formulas provide an exact parameter generator without enumerating $2^n$ vertices.

### 7.3. Girth certification

For the hypercube family, a symbolic certificate is more efficient than generic breadth-first search:

1. Use vertex parity to establish bipartiteness and exclude odd cycles.
2. Use simplicity to exclude cycles shorter than three.
3. Exhibit the square generated by two coordinate flips.
4. Conclude girth four.

A generic graph algorithm could find girth using breadth-first searches, typically in $O(VE)$ time. The family-specific certificate is constant in conceptual size once $n\ge2$ is known.

## 8. Applications and interpretation

The formulas above have two levels of use. At the structural level, they explain why a CSS dimension count is a topological quotient. At the computational level, they reduce the count to ranks and elementary combinatorics. The same language therefore connects quantum codes to familiar cycle-space calculations in several applied fields.

### 8.1. Network cycle spaces

The formula $E-V+\beta_0$ counts independent loops in any finite graph. In electrical networks it counts independent mesh currents; in transportation networks it measures route redundancy; in chemical graphs it measures independent rings. The homological code adopts the same invariant as its logical dimension when edges carry physical variables and no faces are imposed.

### 8.2. Topological code design

Adding a $2$-cell changes $d_2$ and can remove a logical degree of freedom by turning a cycle into a boundary. Thus code design can be viewed as controlled topology: edges create possible cycles, checks restrict them, and faces impose equivalences. The CSS Dimension Theorem quantifies the resulting balance.

### 8.3. Model selection

The hypercube example demonstrates the importance of selecting the intended cell structure.

- The **hypercube graph** contains only vertices and edges and has many independent cycles.
- The **filled cubical hypercube** is contractible and has no positive-dimensional homology.
- The **boundary complex** is topologically a sphere and has sphere-like homology.
- A **periodic cubical lattice** has toroidal global cycles.

These models can share local adjacency while having different logical spaces. A statement about “the hypercube code” is incomplete until the cells, boundary maps, and qubit placement are specified.

### 8.4. Correct block length in coding bounds

If qubits are placed on graph edges, the physical block length is

$$
N=E=n2^{n-1},
$$

not the ambient dimension $n$. Any comparison with a quantum Singleton-type bound must use $N$. Substituting $n$ as though it were the number of physical qubits mixes geometric dimension with code length and produces an invalid comparison.

## 9. Discussion

The chain-complex formulation validates the broad principle that homological data organize CSS code dimensions. It also corrects two specific hypercube expectations in the graph setting.

First, the logical dimension is not one except at $n=2$. The graph $Q_n$ becomes increasingly cycle-rich: each dimension adds many edges relative to the number needed for a spanning tree. The exact excess is

$$
E-(V-1)=2^{n-1}(n-2)+1.
$$

Second, local square faces appear as graph cycles even when they are not filled as $2$-cells. Their existence fixes the girth at four. If those squares were attached as faces, they would contribute to $\operatorname{im}d_2$ and alter the homology. This is why graph and cubical-complex statements cannot be interchanged.

The representability question also deserves care. Every binary CSS check pair satisfying the compatibility relation determines an abstract length-two chain complex. It does not follow automatically that every such pair is the standard incidence complex of a simplicial complex. Simplicial boundary matrices have additional combinatorial structure. Abstract algebraic realization and geometric simplicial realization are distinct claims.

## 10. Future work

Several developments would complete the coding-theoretic picture.

1. Give a precise equivalence between the conventional two-classical-code CSS presentation, orthogonal-complement conditions, parity-check matrices, chain complexes, and stabilizer groups.
2. Characterize which binary chain complexes arise from standard simplicial or cellular incidence maps, and identify minimal obstructions to realization.
3. Define finite-chain Hamming weight and prove a complete distance theorem involving both minimum nonzero homology and cohomology representatives.
4. Construct explicit hypercube incidence matrices and derive their rank $2^n-1$ directly from connectedness or elimination.
5. Compare the graph, filled cube, boundary sphere, and periodic cubical torus in a common framework.
6. Evaluate coding bounds using the edge-qubit block length $N=n2^{n-1}$.

## 11. Conclusion

A finite length-two chain complex provides an exact algebraic skeleton for CSS dimension counting. Its logical space is

$$
H=\ker d_1/\operatorname{im}d_2,
$$

and its logical dimension obeys

$$
k+\operatorname{rank}d_1+\operatorname{rank}d_2=\dim B.
$$

For a graph, the absence of $2$-cells reduces this to the circuit-rank formula $k=E-V+\beta_0$. Applied to the connected hypercube graph, it yields

$$
k=2^{n-1}(n-2)+1,
$$

with values $17$, $129$, and $769$ for dimensions $4$, $6$, and $8$. The value is one only for $Q_2$. Independently, parity excludes triangles and two coordinate directions exhibit a square, proving that every $Q_n$ with $n\ge2$ has girth four. Hence the graph systole does not grow as $2^{n/2}$.

The outcome sharpens rather than weakens the topological perspective: quantum-code parameters depend on the exact chain complex, not merely on the name or drawing of a geometric object. Homology counts what remains after boundaries are specified, and that specification is the mathematical content of the code.
