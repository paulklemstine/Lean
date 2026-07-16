# Two Scales of Motion in Generalized Join Digraphs

## How a vast directed network separates into local fluctuations and global flow

A city is not a point. It is a tangle of streets, intersections, and one-way routes. Yet on a national transport map, an entire city may be represented by a single dot. This change of scale is useful, but it raises a mathematical question: when can the fine street-level dynamics and the coarse city-to-city dynamics be separated without losing information?

Generalized join digraphs provide a precise setting for answering that question. They are directed networks built from networks. Start with a base digraph whose vertices label communities. Replace each base vertex $i$ by a finite directed graph $H_i$, called a fiber. Whenever the base has an arc from $i$ to $j$, connect every vertex of $H_i$ to every vertex of $H_j$. Weighted base arcs are allowed: a number $A_{ij}$ gives the common weight of all links from fiber $i$ to fiber $j$.

This construction appears whenever a system has dense, uniform connections between groups: clustered communication networks, compartmental models, multi-scale Markov systems, and block-structured graph models used in data analysis. It also lies behind formulas for counting directed spanning trees, the rooted backbones that organize flow through a network.

The central discovery is a clean spectral split. Every signal on the large network decomposes uniquely into two kinds of motion:

1. **internal fluctuations**, whose values sum to zero inside every fiber; and
2. **fiber averages**, which are constant inside each fiber and vary only from fiber to fiber.

The generalized-join Laplacian respects both parts. Local fluctuations retain the eigenstructure of their home fiber, with a simple shift caused by outgoing external links. Global averages evolve according to a smaller weighted quotient Laplacian on the base. A potentially huge matrix therefore breaks into local pieces and one compact coarse-scale problem.

## The network and its Laplacian

Let $I$ be the finite set of fibers. The fiber $H_i$ has vertex set $V_i$ and size $n_i=|V_i|$. A network signal assigns a scalar $x_i(u)$ to every $u\in V_i$. Its total mass in fiber $i$ is

$$
m_i(x)=\sum_{u\in V_i}x_i(u).
$$

Let $L_i$ denote the internal Laplacian action of $H_i$. The weighted external out-degree seen by every vertex in fiber $i$ is

$$
d_i=\sum_{j\in I}A_{ij}n_j.
$$

Why does $n_j$ appear? A single base arc $i\to j$ expands into an arc from a chosen vertex of $V_i$ to every one of the $n_j$ vertices in $V_j$.

The Laplacian $\mathcal L$ of the generalized join acts by

$$
(\mathcal Lx)_i(u)
=(L_i x_i)(u)+d_i x_i(u)-\sum_{j\in I}A_{ij}m_j(x).
$$

The first term records motion within the fiber. The second is the diagonal contribution from all outgoing external arcs. The final term couples fiber $i$ to the total masses of its neighbors. This formula is the engine behind every result that follows.

## Why zero-sum fluctuations decouple

Suppose $x$ has zero mass in every fiber:

$$
m_i(x)=0\qquad\text{for all }i\in I.
$$

Then every cross-fiber coupling term disappears, because it depends only on the masses $m_j(x)$. Consequently,

$$
(\mathcal Lx)_i(u)=(L_i x_i)(u)+d_i x_i(u).
$$

This is the **zero-mass decoupling theorem**: on fiberwise balanced signals, the large network behaves as independent internal Laplacians plus scalar shifts.

The spectral consequence is immediate and powerful. Suppose a signal is supported only on fiber $i$, has zero sum there, and satisfies

$$
L_i x_i=\mu x_i.
$$

Then the same signal, extended by zero to every other fiber, satisfies

$$
\mathcal Lx=(\mu+d_i)x.
$$

Thus every zero-sum internal eigenmode survives in the full network, and its eigenvalue is shifted from $\mu$ to $\mu+d_i$. The shape of the mode does not change. Only its spectral cost changes, exactly by the external degree of its fiber.

There is also a simultaneous version. If each component obeys

$$
L_i x_i=(\rho-d_i)x_i
$$

and every fiber mass vanishes, then $\mathcal Lx=\rho x$. This permits a full generalized-join eigenvector to be assembled from compatible local pieces.

Picture people inside several rooms. A zero-sum mode means that every room has as much positive deviation as negative deviation. Since the doors between rooms react only to each room's total, they see nothing. The internal pattern remains local, while the mere availability of outward doors adds the shift $d_i$.

## The quotient that governs collective motion

Now consider the opposite kind of signal: one that is constant within each fiber. Write

$$
x_i(u)=z_i
$$

for all $u\in V_i$. Assume, as standard graph Laplacians do, that each internal Laplacian kills constants:

$$
L_i(c\mathbf 1)=0.
$$

The mass of fiber $j$ is then $n_jz_j$. Substitution into the generalized-join formula gives

$$
(\mathcal Lx)_i(u)
=d_i z_i-\sum_{j\in I}A_{ij}n_jz_j.
$$

The right-hand side no longer depends on $u$. Define the weighted quotient operator $Q$ on base signals $z=(z_i)$ by

$$
(Qz)_i=d_i z_i-\sum_{j\in I}A_{ij}n_jz_j.
$$

The **fiber-constant intertwining theorem** says that lifting $z$ to a constant signal on each fiber and then applying $\mathcal L$ is the same as applying $Q$ first and lifting afterward. In symbols, if $Cz$ denotes the fiber-constant lift, then

$$
\mathcal L(Cz)=C(Qz).
$$

Therefore every quotient eigenvector lifts: if $Qz=\rho z$, then

$$
\mathcal L(Cz)=\rho Cz.
$$

The quotient is not merely the original base Laplacian. Fiber sizes matter. A destination fiber of size $n_j$ supplies $n_j$ outgoing choices from each source vertex, so the coupling coefficient is $A_{ij}n_j$. This weighting is essential.

Both $Q$ and $\mathcal L$ kill the all-ones signal. Indeed, for $z_i=1$,

$$
(Q\mathbf 1)_i=d_i-\sum_jA_{ij}n_j=0.
$$

This familiar zero mode expresses the fact that a Laplacian detects differences, not a uniform level.

## Every signal has exactly these two faces

The split is not a convenient guess; over a characteristic-zero field it is an exact and unique decomposition, provided every fiber is nonempty.

Define the average in fiber $i$ by

$$
\bar x_i=\frac{1}{n_i}\sum_{u\in V_i}x_i(u),
$$

and define the centered fluctuation by

$$
x_i^{\circ}(u)=x_i(u)-\bar x_i.
$$

Then

$$
\sum_{u\in V_i}x_i^{\circ}(u)=0,
$$

and every signal satisfies

$$
x=x^{\circ}+C\bar x.
$$

Moreover, a signal that is both fiber-constant and zero-sum in each fiber must be zero. If its value on fiber $i$ is $c_i$, zero mass says $n_ic_i=0$. Because $n_i$ is nonzero in a characteristic-zero field, $c_i=0$. Hence the zero-mass and fiber-constant spaces meet only at the origin.

This proves the **direct-sum decomposition theorem**:

$$
\text{all signals}
=	ext{fiberwise zero-mass signals}
\oplus
\text{fiber-constant signals}.
$$

If each $L_i$ preserves zero mass and kills constants, then both summands are invariant under $\mathcal L$. The first condition means that whenever $\sum_u y(u)=0$, one also has $\sum_u(L_iy)(u)=0$. Under these hypotheses, the decomposition is dynamically stable: local fluctuations never leak into global averages, and global averages never create within-fiber variation.

## A small example

Take two fibers of sizes $2$ and $3$, with one unit-weight base arc in each direction. Then

$$
d_1=3,\qquad d_2=2,
$$

and the quotient matrix is

$$
Q=\begin{pmatrix}3&-3\\-2&2\end{pmatrix}.
$$

Its eigenvalues are $0$ and $5$. The zero eigenvalue belongs to the global constant signal. The other quotient mode contrasts the two communities.

If the first fiber has an internal zero-sum eigenmode with eigenvalue $2$, that mode appears in the full network with eigenvalue $2+3=5$. If the second has an internal zero-sum eigenmode with eigenvalue $3$, it appears with eigenvalue $3+2=5$. Three phenomena that look unrelated—one coarse contrast and two local oscillations—can therefore meet at the same full-network eigenvalue.

## From spectrum to spanning trees

Directed spanning trees connect spectral algebra with combinatorics. A rooted directed spanning tree, or arborescence, selects enough arcs to connect every vertex to a designated root under a fixed orientation convention. The directed matrix-tree theorem counts such objects using determinants of reduced Laplacians.

The decomposition above explains why generalized joins are unusually tractable. In a basis adapted to zero-mass fluctuations and fiber constants, the Laplacian separates into shifted internal blocks and the quotient block. Determinants—and therefore tree counts once the appropriate reduced determinant theorem is invoked—can be organized into local spectral factors and a global quotient factor.

The present results establish that structural mechanism, but they should not be mistaken for a completed arborescence-count formula. Obtaining the final count requires choosing an in- or out-arborescence convention, identifying the corresponding reduced Laplacian, and factoring its determinant while handling the root. The same distinction matters for formulas in which the root is constrained to a particular fiber.

## Why the split matters

A generalized join with thousands of vertices may have only a handful of fibers. Direct spectral work on the full matrix can be expensive and opaque. The two-scale theorem replaces it with internal analyses of the $H_i$ and one quotient problem of size $|I|$. If the internal spectra are already known, the full nontrivial modes can often be read off with almost no additional work.

The idea also has a machine-learning interpretation. Block-structured graph data naturally carry two types of features: deviations within communities and aggregate differences between communities. The invariant split says that, for this idealized coupling pattern, Laplacian-based diffusion and spectral filtering process those feature types independently. It gives an exact benchmark for understanding approximate community models, graph coarsening, and hierarchical message passing.

Most importantly, the result turns scale into algebra. The network's microscopic detail is not discarded, and its macroscopic organization is not buried. Each occupies its own invariant space. Local shape contributes shifted internal modes; global architecture contributes quotient modes. Together they reconstruct every possible signal—and reveal how a network made of networks can be understood one scale at a time.
