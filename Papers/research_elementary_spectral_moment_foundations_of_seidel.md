# Triangle Holonomy and the Cubic Moment of Seidel Matrices

**Aristotle**  
**15 July 2026**

## Abstract

For a finite simple graph, the Seidel matrix assigns $-1$ to edges, $+1$ to nonedges, and $0$ to diagonal entries. We develop a self-contained combinatorial interpretation of its cubic spectral moment. The product of Seidel signs around an ordered triple is zero when a vertex repeats, $+1$ when three distinct vertices span an even number of edges, and $-1$ when they span an odd number. Consequently, $\operatorname{tr}(S^3)$ is exactly the signed parity imbalance over ordered triples, or equivalently six times the difference between the numbers of even-edge and odd-edge three-vertex subsets. We then interpret the cyclic sign product as a signed-graph holonomy and prove its invariance under arbitrary diagonal sign switching by local cancellation. This gives a direct combinatorial proof that switching preserves the cubic moment. We relate the identity to the universal first and second Seidel moments, derive the local cubic update caused by deleting one edge, and present algorithms for computing and experimentally exploring these quantities. The resulting bridge among spectral graph theory, induced-subgraph enumeration, and discrete gauge symmetry points toward closed-walk interpretations of all higher moments and refined analyses of edge perturbations.

## 1. Introduction

Spectral graph theory translates combinatorial structure into the eigenvalues of matrices. The translation is often useful precisely because it is nonlocal: a matrix spectrum packages information distributed across the entire graph. Yet a spectral statistic becomes especially informative when it also admits a transparent local interpretation.

The Seidel matrix is a signed encoding of a simple graph. Unlike the adjacency matrix, which distinguishes an edge from absence by $1$ versus $0$, the Seidel matrix treats edges and nonedges symmetrically as opposite signs. This makes it natural for switching theory, equiangular-line problems, signed graphs, and two-graphs. It also gives its spectral moments unusually clean forms.

The first moment vanishes because the diagonal is zero. The second moment equals $n(n-1)$ for every graph on $n$ vertices because every off-diagonal entry has square one. Hence these two moments contain no edge-sensitive information beyond the order of the graph. The cubic moment is the first place where products around nontrivial closed walks appear. This paper identifies it exactly with a parity statistic on triples.

The main result states that

$$
\operatorname{tr}(S^3)=\sum_{i,j,k}w(i,j,k),
$$

where $w(i,j,k)$ is zero for a repeated vertex and otherwise equals $+1$ or $-1$ according as the three cyclic pairs contain an even or odd number of graph edges. For an undirected loopless graph this becomes

$$
\operatorname{tr}(S^3)=6(N_{\mathrm{even}}-N_{\mathrm{odd}}).
$$

The same sign product has a gauge-theoretic meaning. Under diagonal switching, an edge sign $S_{ij}$ becomes $d_iS_{ij}d_j$ with $d_i^2=1$. Around a triangle every vertex factor occurs twice and cancels. The local triangular holonomy, and therefore the cubic trace, is invariant.

This viewpoint also clarifies edge perturbations. Deleting an edge reverses the parity of exactly the three-vertex sets containing that edge. The resulting change in the cubic trace agrees with a rank-two matrix update and is controlled by one off-diagonal entry of $S^2$. Such identities are relevant when the first two moments are blind to a perturbation, as happens in attempts to compare the Seidel energies of structured graphs before and after edge deletion.

## 2. Definitions and elementary spectral moments

### 2.1. Graphs and Seidel matrices

Let $G=(V,E)$ be a finite simple graph. Thus $V$ is finite, edges are unordered pairs of distinct vertices, and there are no loops or multiple edges. Write $n=|V|$.

**Definition 2.1 (Seidel matrix).** The Seidel matrix of $G$ is the real $V\times V$ matrix $S$ with entries

$$
S_{ij}=
\begin{cases}
0,&i=j,\\
-1,&i\ne j\text{ and }\{i,j\}\in E,\\
+1,&i\ne j\text{ and }\{i,j\}\notin E.
\end{cases}
$$

Because adjacency is symmetric, $S$ is real symmetric. It therefore has real eigenvalues $\lambda_1,\ldots,\lambda_n$, listed with algebraic multiplicity.

**Definition 2.2 (Seidel spectral moments and energy).** For an integer $m\geq 1$, the $m$th Seidel spectral moment is

$$
M_m(G)=\operatorname{tr}(S^m)=\sum_{r=1}^n\lambda_r^m.
$$

The Seidel energy is

$$
\mathcal E_S(G)=\sum_{r=1}^n|\lambda_r|.
$$

### 2.2. The universal first two moments

**Proposition 2.3 (Vanishing first moment).** Every finite simple graph satisfies

$$
M_1(G)=\operatorname{tr}(S)=0.
$$

**Proof sketch.** Every diagonal entry of $S$ is zero, and the trace is the sum of the diagonal entries. The eigenvalue identity follows from the spectral theorem. $\square$

**Proposition 2.4 (Graph-independent second moment).** Every simple graph on $n$ vertices satisfies

$$
M_2(G)=\operatorname{tr}(S^2)=n(n-1).
$$

**Proof sketch.** Since $S$ is symmetric,

$$
(S^2)_{ii}=\sum_{j\in V}S_{ij}S_{ji}=\sum_{j\in V}S_{ij}^2.
$$

The term with $j=i$ is zero, while each of the other $n-1$ terms is one. Summing over $i$ gives $n(n-1)$. $\square$

The eigenvalue vector consequently lies on the sphere

$$
\sum_{r=1}^n\lambda_r^2=n(n-1)
$$

inside the trace-zero hyperplane $\sum_r\lambda_r=0$. In particular,

$$
\mathcal E_S(G)=\|\lambda\|_1\geq\|\lambda\|_2=\sqrt{n(n-1)}.
$$

This universal floor is useful but coarse. Equality in $\|x\|_1\geq\|x\|_2$ occurs exactly when at most one coordinate of $x$ is nonzero. For a nontrivial Seidel matrix the simultaneous trace-zero condition rules out such equality. Thus the displayed floor is generally strict for $n>1$; equal-magnitude spectra concern a different extremal geometry and do not furnish equality in this particular inequality.

## 3. Triple parity and triangular holonomy

### 3.1. The parity weight

For an ordered triple $(i,j,k)\in V^3$, consider the cyclic pairs $(i,j)$, $(j,k)$, and $(k,i)$.

**Definition 3.1 (Parity weight).** Define $w_G:V^3\to\{-1,0,+1\}$ by

$$
w_G(i,j,k)=
\begin{cases}
0,&i=j\text{ or }j=k\text{ or }k=i,\\
-1,&i,j,k\text{ are distinct and span an odd number of edges},\\
+1,&i,j,k\text{ are distinct and span an even number of edges}.
\end{cases}
$$

For three distinct vertices, “odd” means one or three induced edges, while “even” means zero or two induced edges.

**Lemma 3.2 (Local product-parity identity).** For every ordered triple $(i,j,k)$,

$$
S_{ij}S_{jk}S_{ki}=w_G(i,j,k).
$$

**Proof sketch.** If a vertex repeats, one of the three matrix entries is diagonal and hence zero. Otherwise each edge among the three cyclic pairs contributes $-1$ and each nonedge contributes $+1$. If $e(i,j,k)$ denotes the number of induced edges, the product is $(-1)^{e(i,j,k)}$, which is precisely the parity weight. $\square$

### 3.2. The cubic moment identity

**Theorem 3.3 (Signed-Triangle Moment Theorem).** Let $G$ be a finite simple graph with Seidel matrix $S$. Then

$$
\operatorname{tr}(S^3)=\sum_{i\in V}\sum_{j\in V}\sum_{k\in V}w_G(i,j,k).
$$

Equivalently, the cubic Seidel moment is the number of even-edge ordered triples of distinct vertices minus the number of odd-edge ordered triples of distinct vertices.

**Proof sketch.** Matrix multiplication gives

$$
(S^3)_{ii}=\sum_{j,k\in V}S_{ij}S_{jk}S_{ki}.
$$

Summing over $i$ yields a sum over all ordered triples. Lemma 3.2 replaces each cyclic product by its parity weight. $\square$

**Corollary 3.4 (Unordered triple formula).** Let $N_{\mathrm{even}}$ be the number of three-element subsets of $V$ inducing zero or two edges, and let $N_{\mathrm{odd}}$ be the number inducing one or three edges. Then

$$
\operatorname{tr}(S^3)=6(N_{\mathrm{even}}-N_{\mathrm{odd}}).
$$

**Proof sketch.** Every three-element vertex set has exactly six orderings, and its parity weight is independent of the ordering. Repeated-vertex triples contribute zero. $\square$

**Corollary 3.5 (Characterization of a vanishing cubic moment).** The equality $\operatorname{tr}(S^3)=0$ holds if and only if $N_{\mathrm{even}}=N_{\mathrm{odd}}$.

This characterization turns spectral cancellation into exact enumerative balance.

### 3.3. Examples

For the empty graph on three vertices, $S$ has $+1$ in every off-diagonal position. The unique three-element subset induces zero edges and contributes six positive orderings. Hence

$$
\operatorname{tr}(S^3)=6.
$$

For the complete graph on three vertices, every off-diagonal entry is $-1$. The unique three-element subset induces three edges and contributes six negative orderings. Hence

$$
\operatorname{tr}(S^3)=-6.
$$

Both graphs have second moment $3\cdot2=6$, illustrating that the cubic moment supplies edge-sensitive information absent from the first two moments.

For a path on three vertices, the sole three-element subset spans two edges, so the cubic moment is $6$. For a graph containing exactly one edge on three vertices, it is $-6$. Thus on three vertices the sign of the cubic moment records edge-count parity exactly.

## 4. Switching and local gauge invariance

### 4.1. Diagonal sign switching

Choose a function $d:V\to\{-1,+1\}$ and let $D$ be the diagonal matrix with $D_{ii}=d_i$. Define

$$
S'=DSD.
$$

Then $S'_{ij}=d_iS_{ij}d_j$. In graph terms, if $U=\{i:d_i=-1\}$, this operation toggles every pair with one endpoint in $U$ and the other in $V\setminus U$, while leaving all pairs inside either part unchanged. It is called Seidel switching.

Since $D^2=I$, one has $S'=DSD^{-1}$, so $S'$ is similar to $S$. This proves invariance of the whole spectrum. The cubic case, however, admits a local proof that does not require the global similarity argument.

**Theorem 4.1 (Triangle-Holonomy Invariance).** For every ordered triple $(i,j,k)$,

$$
S'_{ij}S'_{jk}S'_{ki}=S_{ij}S_{jk}S_{ki}.
$$

**Proof sketch.** Expanding the left side gives

$$
(d_iS_{ij}d_j)(d_jS_{jk}d_k)(d_kS_{ki}d_i).
$$

By commutativity of real multiplication, the vertex factors combine as $d_i^2d_j^2d_k^2=1$. The remaining product is the original cyclic product. $\square$

The cyclic product may be viewed as the holonomy of the signed complete graph around the triangle. Switching is a vertex gauge transformation. Individual edge signs depend on the gauge, but the product around a closed cycle does not.

**Corollary 4.2 (Switching invariance of the cubic moment).** If $S'=DSD$ with every $d_i\in\{-1,+1\}$, then

$$
\operatorname{tr}((S')^3)=\operatorname{tr}(S^3).
$$

**Proof sketch.** Expand both traces as sums of cyclic products over ordered triples and apply Theorem 4.1 term by term. $\square$

**Corollary 4.3 (Switching invariance of parity imbalance).** Seidel switching preserves $N_{\mathrm{even}}-N_{\mathrm{odd}}$, although it need not preserve either count separately.

This corollary follows by combining the unordered triple formula with cubic-moment invariance.

### 4.2. Extension to closed walks

The cancellation mechanism does not depend on length three. Let $v_0,v_1,\ldots,v_m=v_0$ be a closed walk and form

$$
H(v_0,\ldots,v_m)=\prod_{t=0}^{m-1}S_{v_tv_{t+1}}.
$$

Under switching, every factor acquires $d_{v_t}d_{v_{t+1}}$. Across the closed walk, every occurrence of a vertex as an endpoint is paired, and all switching signs cancel. Therefore every closed-walk sign product is switching invariant. Since $\operatorname{tr}(S^m)$ is the sum of these products over length-$m$ closed walks, this provides a combinatorial route to switching invariance of every spectral moment.

The triangle theorem is the first nontrivial instance because diagonal zeros eliminate shorter closed walks except the backtracking contributions responsible for the universal second moment.

## 5. Edge deletion and rank-two perturbations

### 5.1. Local parity effect

Suppose $\{a,b\}$ is an edge of $G$, and let $G^-=G-\{a,b\}$. In the Seidel matrix, deletion changes $S_{ab}=S_{ba}=-1$ to $+1$ and leaves all other entries unchanged. Thus

$$
S^-=S+2(e_ae_b^{\mathsf T}+e_be_a^{\mathsf T}).
$$

Every three-vertex subset not containing both $a$ and $b$ keeps the same number of edges. Every subset $\{a,b,c\}$ with $c\notin\{a,b\}$ loses exactly one edge, so its parity reverses. Therefore the change in the cubic moment is completely localized to triangles through the modified pair.

**Proposition 5.1 (Combinatorial edge-deletion update).** If $\{a,b\}$ is deleted, then

$$
\operatorname{tr}((S^-)^3)-\operatorname{tr}(S^3)
=-12\sum_{c\notin\{a,b\}}S_{ab}S_{bc}S_{ca}.
$$

Since $S_{ab}=-1$ before deletion, this is equivalently

$$
\operatorname{tr}((S^-)^3)-\operatorname{tr}(S^3)
=12\sum_{c\in V}S_{ac}S_{cb}.
$$

**Proof sketch.** For each third vertex $c$, the unordered triple $\{a,b,c\}$ has six orderings. Flipping $S_{ab}$ reverses each ordering’s weight from $q$ to $-q$, a change of $-2q$. Thus that triple contributes $-12q$ to the total change. Summing over $c$ gives the first formula. With $S_{ab}=-1$ and zero diagonal terms, the expression becomes $12\sum_cS_{ac}S_{cb}$. $\square$

**Corollary 5.2 (Matrix form of the cubic update).** Under the same assumptions,

$$
\operatorname{tr}((S^-)^3)-\operatorname{tr}(S^3)=12(S^2)_{ab}.
$$

The identity exhibits a precise bridge. The off-diagonal entry $(S^2)_{ab}$ is the signed imbalance of third vertices according to the two-step product $S_{ac}S_{cb}$; the same imbalance controls how triangle parities change when $\{a,b\}$ is removed.

### 5.2. Why the cubic update matters

Neither $\operatorname{tr}(S)$ nor $\operatorname{tr}(S^2)$ changes when an edge is deleted: the diagonal remains zero and all off-diagonal entries still have magnitude one. Any spectral distinction must therefore occur in the third or higher moments, or in finer information such as how eigenvalues cross zero.

This is relevant to the Seidel energy of Turán graphs. For the complete $r$-partite graph $T(n,r)$, a proposed strict inequality asks whether deleting any edge increases Seidel energy when $r\geq4$ and $n\geq4r$. The first two moments cannot decide the question. The cubic update identifies the first local statistic that can respond, but energy depends on absolute eigenvalues and is not determined by finitely many low moments alone. A complete treatment likely requires quotient-matrix reductions together with rank-two spectral perturbation analysis.

## 6. Algorithms

### 6.1. Direct matrix computation

Given an $n\times n$ adjacency matrix, constructing $S$ requires $O(n^2)$ time and storage. Dense matrix multiplication or eigendecomposition costs $O(n^3)$ time. The trace values can then be evaluated from $S^2$ and $S^3$, while the Seidel energy is the sum of absolute eigenvalues.

This method is straightforward and numerically convenient, particularly when several spectral quantities are wanted simultaneously.

### 6.2. Triple-parity enumeration

The unordered formula gives an exact integer algorithm without matrix multiplication. Iterate over all $\binom n3$ vertex triples, count the three induced edges, and add $+1$ for even parity or $-1$ for odd parity. Multiply the final balance by six. This takes $O(n^3)$ time but only $O(1)$ auxiliary space beyond the graph representation.

The method is robust because it uses integer arithmetic and makes the combinatorial content visible. It also yields $N_{\mathrm{even}}$ and $N_{\mathrm{odd}}$ separately.

### 6.3. Switching and local verification

To switch by a sign vector $d$, compute $S'=DSD$, or entrywise $S'_{ij}=d_iS_{ij}d_j$. This costs $O(n^2)$. One can then verify that each triangle product and the total cubic trace remain fixed.

For a single edge deletion, recomputing the entire cubic moment is unnecessary. Once $(S^2)_{ab}$ is available, the update is $12(S^2)_{ab}$. Computing this entry directly costs $O(n)$ time. Thus a local perturbation admits a local update even though the quantity being updated is spectral.

## 7. Applications and interpretation

### 7.1. Signed subgraph statistics

The cubic trace is an induced-subgraph statistic with signs. It distinguishes graphs that share the universal first two moments and compresses the distribution of the four possible three-vertex edge counts into a parity balance. Although this compression loses information, it is exactly the information compatible with Seidel sign multiplication.

### 7.2. Switching classes and two-graphs

A switching class consists of all graphs obtainable from one another by Seidel switching. Triangle products are natural invariants of this class. Indeed, the parity assigned to every three-element vertex set survives switching. This collection of triple signs is the basic data of a two-graph. The cubic moment is the aggregate imbalance of that data.

Because switching preserves the entire spectrum, every spectral statistic, including Seidel energy, is constant on a switching class. It therefore cannot serve as a strict monotone among representatives of one class. It can, however, compare distinct classes or graphs related by operations other than switching.

### 7.3. Discrete gauge theory

The transformation $S_{ij}\mapsto d_iS_{ij}d_j$ is the finite signed analogue of changing a gauge at vertices. Open-path products depend on endpoint conventions, while closed-path products are invariant. The triangle theorem is therefore a small but exact instance of a general physical principle: locally chosen signs disappear from observable loop quantities.

### 7.4. Perturbative spectral graph theory

Deleting one edge is a rank-two update of the Seidel matrix. Rank-two determinant formulas can express the new characteristic polynomial in terms of a small resolvent block. The triangle formula supplies the first moment-level shadow of that general perturbation theory. For highly symmetric graphs, the resolvent data may collapse to a low-dimensional quotient, making exact energy comparisons accessible.

## 8. Discussion and limitations

The identity developed here is exact, but its scope should be stated carefully. The cubic moment determines only the difference $N_{\mathrm{even}}-N_{\mathrm{odd}}$, not the individual counts unless their sum $\binom n3$ is also used. Even then it distinguishes only parity, not the separate numbers of zero-, one-, two-, and three-edge triples.

Likewise, equality of a few moments does not imply equality of spectra. The first two Seidel moments are universal, and the third can agree for many nonisomorphic graphs. Higher moments progressively add closed-walk information. For an $n\times n$ matrix, sufficiently many power sums determine the characteristic polynomial through Newton identities, but low-order moments alone generally do not.

The second-moment sphere must also be interpreted correctly. A fixed $\ell^2$ norm constrains but does not order $\ell^1$ norms without further structural conditions. In particular, Seidel energy is invariant—not monotone—under switching because switching preserves the entire spectrum. Claims about extremizers require hypotheses beyond membership in a switching class or possession of a fixed second moment.

Finally, the cubic edge-deletion update does not by itself determine the sign of the Seidel-energy change. Energy responds to the absolute values of all eigenvalues, especially to movement across zero. The cubic moment can diagnose asymmetry in redistribution, but a complete energy inequality needs finer perturbation control.

## 9. Future research

The first immediate refinement is to use the unordered formula systematically in families of structured graphs. For edge deletion, classifying third vertices by their adjacency to the deleted edge gives an elementary count for $(S^2)_{ab}$ and the cubic update.

A second direction is a general closed-walk holonomy theorem. Summing switching-invariant products over all closed walks of length $m$ gives a combinatorial proof that $\operatorname{tr}(S^m)$ is switching invariant for every $m$. Newton identities then connect these moments to the characteristic polynomial.

A third direction concerns rank-two perturbations. For

$$
S'=S+2(e_ae_b^{\mathsf T}+e_be_a^{\mathsf T}),
$$

the matrix determinant lemma reduces $\det(xI-S')$ to a $2\times2$ determinant involving entries of $(xI-S)^{-1}$. Combining that formula with interlacing and zero-crossing analysis may yield tractable criteria for the sign of an energy change.

The motivating application is the conjecture that for every Turán graph $T(n,r)$ with $r\geq4$ and $n\geq4r$, deleting any edge strictly increases Seidel energy. The graph-independent second moment explains why elementary norm bounds cannot settle this. Triangle parity, quotient spectra, and rank-two updates provide complementary tools for attacking the higher-order redistribution of eigenvalue mass.

A fourth direction is extremal. One may ask which realizable Seidel spectra minimize or maximize energy under trace and second-moment constraints. Such a question must incorporate realizability and switching invariance. The bare norm inequality has equality when at most one eigenvalue is nonzero, so conference-type equal-magnitude spectra are not equality cases for the elementary lower bound $\|\lambda\|_1\geq\|\lambda\|_2$.

## 10. Conclusion

The cubic moment of a Seidel matrix has a complete local interpretation. Each ordered triple contributes the product of three signs; this product is zero for repetition, positive for even edge parity, and negative for odd edge parity. Summation yields the signed-triangle moment theorem and, for simple graphs, the formula

$$
\operatorname{tr}(S^3)=6(N_{\mathrm{even}}-N_{\mathrm{odd}}).
$$

Diagonal switching changes each edge sign by endpoint factors, but every endpoint factor occurs twice around a triangle. The cancellation preserves each triangular holonomy and therefore the cubic trace. When one edge is deleted, only triangles through that edge change parity, producing the local update

$$
\Delta\operatorname{tr}(S^3)=12(S^2)_{ab}.
$$

These results connect matrix traces, induced-subgraph parity, and gauge symmetry without obscuring any of the three viewpoints. They also identify the cubic moment as the first edge-sensitive statistic beyond the universal Seidel sphere, making it a natural starting point for higher-moment and edge-perturbation investigations.
