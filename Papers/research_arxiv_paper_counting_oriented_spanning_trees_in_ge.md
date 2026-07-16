# Invariant Laplacian Splitting for Weighted Generalized Join Digraphs

**Aristotle**  
**July 16, 2026**

## Abstract

A generalized join digraph is obtained by replacing each vertex of a finite base digraph with a finite fiber digraph and replacing each weighted base arc by a complete directed bipartite coupling between the corresponding fibers. This paper develops the linear-algebraic decomposition underlying spectral and spanning-tree calculations for such networks. We define the generalized-join Laplacian over an arbitrary commutative ring and prove that its action separates into two natural regimes. On vectors whose coordinate sum vanishes in every fiber, all inter-fiber coupling terms disappear; consequently, an internal eigenvalue $\mu$ in fiber $i$ is shifted to $\mu+d_i$, where $d_i$ is the weighted external out-degree of that fiber. On vectors constant within every fiber, the full Laplacian intertwines with a weighted quotient Laplacian whose coefficients incorporate the destination fiber sizes. Quotient eigenvectors therefore lift to eigenvectors of the full operator, and the global constant vector lies in the kernel. If the internal Laplacians preserve zero mass, the fiberwise zero-mass subspace is invariant. Over a characteristic-zero field with nonempty fibers, every vector decomposes uniquely into a centered zero-mass component and a fiber-constant average component; under the standard Laplacian hypotheses, both summands are invariant. We give constructive algorithms, numerical examples, and the determinant-level interpretation that prepares the decomposition for directed matrix-tree formulas, while carefully separating these established operator identities from the additional work required for rooted arborescence counts.

## 1. Introduction

Many directed networks are assembled from modules. A base graph describes interactions among communities, while each community possesses its own internal directed structure. The generalized join construction models an especially symmetric form of this architecture: if the base contains an arc from community $i$ to community $j$, every vertex in the first community is connected to every vertex in the second. Weighted arcs permit the common coupling strength to vary from one ordered pair of communities to another.

The construction is combinatorially large but algebraically structured. If fiber $i$ has $n_i$ vertices, then a single base arc may expand into $n_in_j$ directed arcs. A direct computation on the full Laplacian can therefore obscure the smaller ingredients from which it was built. The purpose of this paper is to expose those ingredients through a canonical invariant splitting.

There are two natural kinds of signals on a network of fibers. A signal may fluctuate internally while having zero total in each fiber, or it may be constant inside each fiber and vary only at the level of the base. Complete bipartite coupling reacts only to fiber totals. It follows that zero-mass fluctuations are invisible to cross-fiber coupling, whereas fiber-constant signals reduce exactly to a weighted quotient action. These observations yield a complete two-scale decomposition.

This splitting is the spectral mechanism used in generalized-join spanning-tree calculations. The directed matrix-tree theorem converts rooted arborescence counts into reduced Laplacian determinants. Once a Laplacian has been separated into local fluctuation blocks and a global quotient block, determinant factors can in principle be assigned to internal spectra and quotient data. The results proved here establish the operator-theoretic foundation for that calculation. They do not, by themselves, assert a final rooted-tree formula; that step additionally requires a precise orientation convention and a reduced-determinant analysis.

The algebraic identities in Sections 2–4 hold over any commutative ring, so they are not tied to real or complex spectral theory. The direct-sum construction in Section 5 requires division by fiber cardinalities and is therefore stated over a characteristic-zero field with nonempty fibers. Section 6 gives matrix forms and algorithms, Section 7 presents examples and computational checks, and Sections 8–10 discuss applications, limitations, and further directions.

## 2. Generalized joins and their Laplacians

### 2.1. Fibered directed networks

Let $I$ be a finite index set. For each $i\in I$, let $H_i$ be a finite digraph with nonempty vertex set $V_i$ when averages are required, and write

$$
n_i=|V_i|.
$$

Let $A=(A_{ij})_{i,j\in I}$ be a matrix over a commutative ring $R$. The entry $A_{ij}$ is the weight assigned to every external arc from a vertex of $V_i$ to a vertex of $V_j$. Thus the generalized join replaces a weighted base arc $i\to j$ by a complete directed bipartite family of arcs $u\to v$ for $u\in V_i$ and $v\in V_j$.

For each $i$, let $L_i$ be a linear operator on functions $V_i\to R$. In graph applications, $L_i$ is the internal out-Laplacian of $H_i$, but the basic identities below require only the stated algebraic properties.

A fibered vector is a collection $x=(x_i)_{i\in I}$ with $x_i:V_i\to R$. Define its mass in fiber $i$ by

$$
m_i(x)=\sum_{u\in V_i}x_i(u).
$$

The weighted external out-degree of a vertex in fiber $i$ is

$$
d_i=\sum_{j\in I}A_{ij}n_j.
$$

The factor $n_j$ records the number of destinations in fiber $j$ available to each source vertex in fiber $i$.

### 2.2. The generalized-join action

**Definition 2.1 (Generalized-join Laplacian action).** The operator $\mathcal L$ on fibered vectors is defined by

$$
(\mathcal Lx)_i(u)
=(L_ix_i)(u)+d_ix_i(u)-\sum_{j\in I}A_{ij}m_j(x).
$$

The three terms have distinct meanings: internal Laplacian action, external diagonal degree, and complete-bipartite coupling to fiber masses.

When $L_i$ is the out-Laplacian of the internal fiber and $A_{ij}$ describes external arc weights, this is the out-Laplacian action of the generalized join. The formulation remains meaningful over any commutative ring and for abstract internal operators.

**Definition 2.2 (Fiber-constant lift).** For a base vector $z:I\to R$, its fiber-constant lift $Cz$ is

$$
(Cz)_i(u)=z_i.
$$

**Definition 2.3 (Weighted quotient Laplacian).** The quotient operator $Q$ on base vectors is

$$
(Qz)_i=d_iz_i-\sum_{j\in I}A_{ij}n_jz_j.
$$

In matrix notation, with $N=\operatorname{diag}(n_i)$ and $D=\operatorname{diag}(d_i)$,

$$
Q=D-AN.
$$

This is generally not $D-A$: the destination sizes are part of the effective coarse coupling.

## 3. The zero-mass sector

Let

$$
Z=\{x:m_i(x)=0\text{ for every }i\in I\}
$$

be the fiberwise zero-mass subspace or, over a general ring, submodule.

**Theorem 3.1 (Zero-mass decoupling).** If $x\in Z$, then for every $i\in I$ and $u\in V_i$,

$$
(\mathcal Lx)_i(u)=(L_ix_i)(u)+d_ix_i(u).
$$

**Proof sketch.** In Definition 2.1, the inter-fiber term is $\sum_jA_{ij}m_j(x)$. Every mass $m_j(x)$ is zero, so the entire coupling term vanishes. No property of the internal operators is needed. $\square$

The theorem says that complete bipartite couplings communicate only aggregate mass. Balanced variations inside a fiber cannot be detected by other fibers.

**Theorem 3.2 (Assembled shifted eigenvector).** Let $\rho\in R$. Suppose $x$ has zero mass in every fiber and satisfies

$$
(L_ix_i)(u)=(\rho-d_i)x_i(u)
$$

for all $i\in I$ and $u\in V_i$. Then

$$
\mathcal Lx=\rho x.
$$

**Proof sketch.** Apply Theorem 3.1 and substitute the assumed internal relation:

$$
(\mathcal Lx)_i(u)=(\rho-d_i)x_i(u)+d_ix_i(u)=\rho x_i(u).
$$

The cancellation is purely ring-theoretic. $\square$

A particularly useful case isolates one fiber.

**Theorem 3.3 (Supported-fiber eigenvalue shift).** Fix $i_0\in I$. Suppose $x_j=0$ for $j\ne i_0$, the component $x_{i_0}$ has zero mass, every internal operator satisfies $L_j0=0$, and

$$
L_{i_0}x_{i_0}=\mu x_{i_0}.
$$

Then

$$
\mathcal Lx=(\mu+d_{i_0})x.
$$

**Proof sketch.** The support and mass assumptions imply that every fiber mass is zero. In the active fiber, Theorem 3.1 gives $L_{i_0}x_{i_0}+d_{i_0}x_{i_0}=(\mu+d_{i_0})x_{i_0}$. In every inactive fiber, both the vector and its internal image vanish, so both sides are zero. $\square$

Thus each zero-mass internal eigenvalue $\mu$ of $L_i$ contributes the shifted value $\mu+d_i$ to the full generalized-join operator. Algebraic multiplicities require additional hypotheses if one wishes to turn this eigenvector construction into a complete characteristic-polynomial statement, but the invariant decomposition below supplies the appropriate block structure over fields.

### 3.1. Invariance of zero mass

Eigenvectors are only one aspect of the structure. For dynamics and block decomposition, it is important that the whole zero-mass sector remain stable.

**Assumption 3.4 (Internal mass preservation).** For every $i$ and every $y:V_i\to R$,

$$
\sum_{u\in V_i}y(u)=0
\quad\Longrightarrow\quad
\sum_{u\in V_i}(L_iy)(u)=0.
$$

**Theorem 3.5 (Zero-mass invariance).** Under Assumption 3.4, if $x\in Z$, then $\mathcal Lx\in Z$.

**Proof sketch.** By Theorem 3.1,

$$
\sum_{u\in V_i}(\mathcal Lx)_i(u)
=\sum_{u\in V_i}(L_ix_i)(u)+d_i\sum_{u\in V_i}x_i(u).
$$

The first term vanishes by internal mass preservation and the second because $x_i$ has zero mass. Hence every output fiber also has zero mass. $\square$

For standard Laplacians, the condition follows from the appropriate row- or column-sum convention. It is stated explicitly here to keep orientation conventions transparent.

## 4. The fiber-constant sector and quotient dynamics

Let

$$
C=\{Cz:z\in R^I\}
$$

be the space of fiber-constant vectors.

**Assumption 4.1 (Constants in the internal kernel).** For every $i\in I$ and scalar $c\in R$,

$$
L_i(c\mathbf 1_{V_i})=0.
$$

This is the standard constant-kernel property of a graph Laplacian.

**Theorem 4.2 (Fiber-constant intertwining).** Under Assumption 4.1, every base vector $z$ satisfies

$$
\mathcal L(Cz)=C(Qz).
$$

In particular, the fiber-constant sector is invariant under $\mathcal L$.

**Proof sketch.** In fiber $j$, the lift has constant value $z_j$ and therefore mass $n_jz_j$. Its internal Laplacian vanishes. Substitution into Definition 2.1 gives

$$
(\mathcal L(Cz))_i(u)
=d_iz_i-\sum_jA_{ij}n_jz_j
=(Qz)_i,
$$

which is independent of $u$ and hence equals the lift of $Qz$. $\square$

**Corollary 4.3 (Lifting quotient eigenvectors).** If $Qz=\rho z$, then

$$
\mathcal L(Cz)=\rho Cz.
$$

**Proof sketch.** Combine Theorem 4.2 with linearity of the lift: $\mathcal L(Cz)=C(Qz)=C(\rho z)=\rho Cz$. $\square$

**Theorem 4.4 (Constant quotient mode).** The all-ones base vector lies in the kernel of $Q$:

$$
Q\mathbf 1=0.
$$

**Proof sketch.** For each $i$,

$$
(Q\mathbf 1)_i=d_i-\sum_jA_{ij}n_j=0
$$

by the definition of $d_i$. $\square$

**Corollary 4.5 (Constant full-network mode).** Under Assumption 4.1, the global all-ones vector lies in the kernel of $\mathcal L$.

**Proof sketch.** The global constant vector is the lift of the base all-ones vector. Apply Theorems 4.2 and 4.4. $\square$

These results identify the exact coarse operator. The quotient weights depend asymmetrically on destination sizes: the entry from $i$ to $j$ is effectively $A_{ij}n_j$. This asymmetry persists even when the base weight matrix is symmetric if the fiber sizes differ.

## 5. Canonical direct-sum decomposition

The preceding sections identify two invariant candidates. We now show that they exhaust all vectors and intersect trivially. Let $K$ be a characteristic-zero field, and suppose every $V_i$ is nonempty. Then each positive integer $n_i$ is nonzero as an element of $K$ and is therefore invertible.

**Definition 5.1 (Fiber average and centering).** For a fibered vector $x$, define

$$
\bar x_i=\frac{m_i(x)}{n_i}
$$

and

$$
x_i^{\circ}(u)=x_i(u)-\bar x_i.
$$

The vector $C\bar x$ is the fiber-constant average component, while $x^{\circ}$ is the centered fluctuation component.

**Lemma 5.2 (Centering has zero mass).** For every $i$,

$$
m_i(x^{\circ})=0.
$$

**Proof sketch.** Summing the definition over $V_i$ gives

$$
m_i(x^{\circ})=m_i(x)-n_i\bar x_i
=m_i(x)-n_i\frac{m_i(x)}{n_i}=0.
$$

Nonemptiness and characteristic zero justify division by $n_i$. $\square$

**Lemma 5.3 (Reconstruction).** Every vector satisfies

$$
x=x^{\circ}+C\bar x.
$$

**Proof sketch.** At every coordinate $(i,u)$, the right-hand side is $x_i(u)-\bar x_i+\bar x_i=x_i(u)$. $\square$

**Lemma 5.4 (Trivial intersection).** If a fiber-constant vector $Cz$ has zero mass in every fiber, then $Cz=0$.

**Proof sketch.** The mass in fiber $i$ is $n_iz_i$. If it is zero, then $z_i=0$ because $n_i\ne0$ in $K$. This holds for every $i$. $\square$

**Theorem 5.5 (Canonical direct-sum decomposition).** Over a characteristic-zero field with nonempty fibers,

$$
K^{\bigsqcup_iV_i}=Z\oplus C.
$$

The unique decomposition of $x$ is

$$
x=x^{\circ}+C\bar x.
$$

**Proof sketch.** Lemmas 5.2 and 5.3 show existence: the centered part lies in $Z$ and the average part lies in $C$. Lemma 5.4 shows uniqueness because $Z\cap C=\{0\}$. $\square$

**Theorem 5.6 (Invariant two-scale splitting).** Suppose the internal operators preserve zero mass as in Assumption 3.4 and kill constants as in Assumption 4.1. Then both summands in Theorem 5.5 are invariant under $\mathcal L$. More explicitly,

$$
\mathcal Lx^{\circ}\in Z
$$

and

$$
\mathcal L(C\bar x)=C(Q\bar x).
$$

**Proof sketch.** The first statement is Theorem 3.5 applied to Lemma 5.2. The second is Theorem 4.2. $\square$

In a basis adapted to this direct sum, $\mathcal L$ is block diagonal:

$$
\mathcal L\sim
\left(\bigoplus_{i\in I}(L_i+d_iI)\big|_{Z_i}\right)\oplus Q,
$$

where

$$
Z_i=\left\{y:V_i\to K:\sum_{u\in V_i}y(u)=0\right\}.
$$

This display is an interpretation of the invariant actions: on each zero-mass fiber block the action is $L_i+d_iI$, while on fiber constants it is represented by $Q$. It immediately explains the local eigenvalue shifts and quotient eigenvector lifts.

## 6. Algorithms

### 6.1. Applying the generalized-join Laplacian without forming it

A dense full matrix is unnecessary. Given fiber vectors $x_i$, first compute all masses $m_j(x)$ and degrees $d_i$. Then apply each internal operator and add the scalar corrections.

**Algorithm 6.1 (Implicit generalized-join action).** For each fiber $j$, compute $m_j=\sum_{v\in V_j}x_j(v)$. For each fiber $i$, compute $d_i=\sum_jA_{ij}n_j$ and $c_i=\sum_jA_{ij}m_j$. For every $u\in V_i$, return

$$
(L_ix_i)(u)+d_ix_i(u)-c_i.
$$

If internal actions cost $T_i$, this requires $O(\sum_iT_i+|I|^2+\sum_in_i)$ arithmetic operations for dense $A$. Sparse base weights replace $|I|^2$ by the number of nonzero base arcs. Forming the full generalized-join matrix could require quadratic storage in $\sum_in_i$; the implicit method stores only the fibers, internal operators, and base matrix.

### 6.2. Centering and coarse projection

**Algorithm 6.2 (Two-scale decomposition).** For each $i$, compute $\bar x_i=n_i^{-1}\sum_ux_i(u)$. Set $x_i^{\circ}(u)=x_i(u)-\bar x_i$. Return $x^{\circ}$ and $\bar x$.

The cost is $O(\sum_in_i)$ arithmetic operations. Reconstruction is coordinatewise addition. The algorithm is exact over fields where each $n_i$ is invertible.

### 6.3. Spectral assembly

When each internal Laplacian has a basis consisting of the constant vector and zero-mass eigenvectors, the full spectrum may be assembled as follows.

**Algorithm 6.3 (Spectrum from local and quotient modes).** Compute $d_i$ and $Q=D-AN$. For each zero-mass internal eigenpair $(\mu,y)$ of $L_i$, extend $y$ by zero outside fiber $i$ and assign eigenvalue $\mu+d_i$. Compute eigenpairs $(\rho,z)$ of $Q$ and lift each $z$ to a fiber-constant vector. The union gives an eigenbasis whenever the local and quotient eigenvectors together have the required completeness.

For numerical dense eigensolvers, the cost is approximately $O(\sum_in_i^3+|I|^3)$ rather than $O((\sum_in_i)^3)$. The reduction can be substantial when many moderate fibers replace one large matrix. The completeness clause matters: over non-algebraically closed fields or for defective operators, one should use invariant blocks or generalized eigenvectors rather than claim an eigenbasis.

## 7. Numerical examples

### 7.1. Two bidirectionally joined fibers

Let $I=\{1,2\}$, $n_1=2$, $n_2=3$, and

$$
A=\begin{pmatrix}0&1\\1&0\end{pmatrix}.
$$

Then

$$
d_1=3,\qquad d_2=2,
$$

and

$$
Q=D-AN
=\begin{pmatrix}3&-3\\-2&2\end{pmatrix}.
$$

The quotient eigenvalues are $0$ and $5$. The eigenvalue $0$ has eigenvector $(1,1)$, which lifts to the global constant vector. An eigenvector for $5$ may be chosen as $(3,-2)$, producing values $3$ throughout the first fiber and $-2$ throughout the second.

Choose internal undirected-edge Laplacians

$$
L_1=\begin{pmatrix}1&-1\\-1&1\end{pmatrix},
$$

and

$$
L_2=\begin{pmatrix}2&-1&-1\\-1&2&-1\\-1&-1&2\end{pmatrix}.
$$

The first has zero-mass eigenvalue $2$, shifted to $2+d_1=5$. The second has two zero-mass eigenvalues equal to $3$, each shifted to $3+d_2=5$. Thus the full five-vertex operator has eigenvalues

$$
0,5,5,5,5.
$$

This degeneracy has a transparent origin: one coarse mode, one local mode from the first fiber, and two local modes from the second all meet at $5$.

### 7.2. A weighted asymmetric base

Let the fiber sizes be $(2,1,3)$ and

$$
A=\begin{pmatrix}
0&2&0\\
1&0&1\\
3&0&0
\end{pmatrix}.
$$

The external degrees are

$$
d_1=2,\qquad d_2=5,\qquad d_3=6.
$$

The quotient is

$$
Q=
\begin{pmatrix}
2&-2&0\\
-2&5&-3\\
-6&0&6
\end{pmatrix}.
$$

Every row sums to zero, despite unequal fiber sizes and asymmetric couplings. A fiber-constant signal evolves exactly under this $3\times3$ matrix, while all centered components evolve independently under their shifted internal operators. This remains true even though $Q$ is nonsymmetric.

### 7.3. Direct numerical verification

A practical check constructs the full block matrix. The diagonal block for fiber $i$ is $L_i+d_iI$, and the off-diagonal block from source coordinates in $j$ to output coordinates in $i$ is the constant matrix

$$
-A_{ij}\mathbf 1_{n_i}\mathbf 1_{n_j}^{\mathsf T}.
$$

One then compares its eigenvalues with the union of shifted zero-mass internal eigenvalues and quotient eigenvalues. The accompanying numerical program performs this comparison, verifies the intertwining identity on a sample vector, and checks that centering yields zero fiber sums.

## 8. Relation to directed spanning trees

A rooted directed spanning tree, or arborescence, is a spanning subgraph with a designated root and a unique directed connectivity pattern relative to that root. Two conventions are common: arcs may point toward the root or away from it. The corresponding matrix-tree theorem uses a reduced determinant of a Laplacian whose row-versus-column convention must match the chosen orientation.

The invariant splitting contributes to this theory at the determinant level. On the zero-mass sector, the blocks are shifted internal operators. On the fiber-constant sector, the block is the weighted quotient $Q$. In a decomposition-compatible basis, determinants of suitable restrictions factor into products of local shifted factors and quotient factors.

However, a reduced Laplacian deletes a root row and column and is not simply the unrestricted operator. To derive a total arborescence formula or a formula with the root constrained to one fiber, one must establish how the root deletion interacts with the direct sum, or use an equivalent determinant transformation. A biclique-directed-star transformation is one possible route: replace a complete directed bipartite coupling by an auxiliary star in a way that preserves the relevant reduced determinant. Such a result is not assumed here.

Accordingly, the established conclusions are precise but bounded:

1. the full generalized-join action has the stated formula;
2. local zero-mass modes acquire external-degree shifts;
3. fiber-constant modes are governed by $Q$;
4. the two sectors form an invariant direct sum under the stated hypotheses.

These statements explain the spectral factorization mechanism needed before applying a directed matrix-tree theorem. The final enumeration of rooted arborescences requires the additional combinatorial and reduced-determinant steps just described.

## 9. Applications and interpretation

### 9.1. Community-structured network analysis

The direct sum separates within-community contrasts from between-community averages. Spectral filters that are functions of $\mathcal L$ preserve this separation whenever defined algebraically or analytically. Local filtering acts through shifted internal spectra; coarse filtering acts through $Q$.

### 9.2. Graph coarsening and hierarchical learning

In block-structured graph learning, one often pools node features to community summaries. Here the average projection is not merely heuristic: for exact generalized-join coupling, the fiber-constant subspace is invariant and its dynamics are exactly represented by the quotient. The centered residual is also invariant under the mass-preservation hypothesis. This provides a solvable model for studying hierarchical message passing, pooling, and deviations from equitable block structure.

### 9.3. Diffusion and consensus

For continuous-time dynamics $\dot x=-\mathcal Lx$, the centered and coarse components evolve independently. Local relaxation rates are shifted by $d_i$, while inter-community consensus is controlled by $Q$. The global constant mode remains stationary. In nonsymmetric directed settings, stability still depends on the relevant spectrum and Jordan structure, but the invariant separation remains valid.

### 9.4. Computational savings

The decomposition avoids constructing a potentially dense matrix on all vertices. If there are many fibers with known internal spectra, only the small quotient requires new global analysis. Implicit multiplication similarly reduces storage and makes iterative methods practical.

## 10. Discussion, limitations, and future work

The results are universal algebraic identities, but several hypotheses deserve emphasis. The basic action, zero-mass decoupling, eigenvalue shift, and quotient intertwining hold over a commutative ring. The canonical averaging decomposition requires nonempty fibers and invertibility of their cardinalities; a characteristic-zero field guarantees this. In positive characteristic, a fiber size may vanish as a scalar, causing fiber constants to intersect the zero-mass sector nontrivially. The direct-sum theorem can then fail even though the operator identities remain true.

The internal assumptions are also logically separate. Killing constants guarantees quotient invariance. Preserving zero mass guarantees fluctuation invariance. Depending on whether one uses an out-Laplacian, an in-Laplacian, row vectors, or column vectors, these properties correspond to different matrix sum conventions. Stating them explicitly prevents orientation ambiguity.

Several extensions follow naturally. First, one can define finite weighted digraphs and identify the abstract action with their out-Laplacian matrix. Second, rooted in- and out-arborescences and the directed matrix-tree theorem can be developed with an explicit orientation convention. Third, the invariant splitting can be used to factor reduced determinants into shifted internal factors and a quotient factor. Fourth, this should yield total oriented-spanning-tree formulas and formulas in which roots are restricted to a selected fiber. Fifth, a biclique-directed-star transformation can be proved first as a reduced-determinant identity and then as a root-preserving counting identity. Finally, the weighted setting can be extended to parallel arcs and specialized to unweighted simple digraphs.

From an applied perspective, exact complete bipartite coupling is an idealization. A further direction is perturbation theory: if inter-fiber blocks are nearly constant rather than exactly constant, the present invariant spaces become approximate. Bounds on leakage between centered and coarse sectors could quantify the reliability of graph coarsening and community-level learning.

## 11. Conclusion

The Laplacian of a weighted generalized join has a canonical two-scale organization. Complete bipartite coupling sees only fiber masses. Therefore fiberwise zero-mass modes decouple and acquire external-degree shifts, while fiber-constant modes evolve through the weighted quotient $Q=D-AN$. Over a characteristic-zero field with nonempty fibers, centering and averaging produce a unique direct-sum decomposition of every signal. Under standard Laplacian hypotheses, both summands are invariant.

This structure simultaneously clarifies spectrum, supports efficient computation, and prepares determinant factorizations for directed spanning-tree enumeration. It reveals the generalized join not as one monolithic network, but as an exact superposition of local fluctuations and global flow.
