# The Triangle That Remembers a Graph

## How a three-step walk turns local parity into a spectral fingerprint

A network can be described in two very different languages. One language is local and concrete: vertices are joined by edges, and we can count small patterns such as triangles. The other is global and algebraic: the network becomes a matrix, and the eigenvalues of that matrix summarize its large-scale structure. Much of spectral graph theory is the art of discovering exact translations between these languages.

For the Seidel matrix, one such translation is especially clean. Its third spectral moment is nothing more—and nothing less—than a signed census of triples of vertices. Every triple votes according to whether it contains an even or odd number of edges. The resulting balance is unchanged by a broad family of transformations called switching. That invariance has a vivid local explanation: signs attached to vertices cancel as one travels around a closed triangle.

This triangle identity is elementary enough to verify by hand, but it opens a route toward higher spectral moments, perturbation formulas, and the study of how deleting a single edge changes a graph’s spectrum.

## Turning adjacency into signs

Let $G$ be a finite simple graph with vertex set $V$, where $|V|=n$. Its **Seidel matrix** $S$ is the $n\times n$ real matrix defined by

$$
S_{ij}=
\begin{cases}
0, & i=j,\\
-1, & i\ne j\text{ and }\{i,j\}\text{ is an edge},\\
+1, & i\ne j\text{ and }\{i,j\}\text{ is not an edge}.
\end{cases}
$$

Thus edges receive negative signs, nonedges receive positive signs, and the diagonal is zero. Because the graph is undirected, $S$ is symmetric, so all of its eigenvalues $\lambda_1,\ldots,\lambda_n$ are real.

The first two spectral moments have immediate forms. Since the diagonal vanishes,

$$
\operatorname{tr}(S)=\sum_{r=1}^n\lambda_r=0.
$$

Every off-diagonal entry has square $1$, so

$$
\operatorname{tr}(S^2)=\sum_{r=1}^n\lambda_r^2=n(n-1).
$$

The second identity is strikingly universal: it does not depend on which edges the graph has. Every graph on $n$ vertices places its Seidel spectrum on the same Euclidean sphere. This explains both the power and the limitation of the second moment. It gives a common scale, but it cannot distinguish an empty graph from a complete graph, or detect that one edge has been deleted.

The third moment is where local structure first enters.

## A vote from every ordered triple

Take an ordered triple $(i,j,k)$ of vertices and inspect the three cyclic pairs $\{i,j\}$, $\{j,k\}$, and $\{k,i\}$. Define its **parity weight** $w(i,j,k)$ as follows:

* if any two of $i,j,k$ coincide, set $w(i,j,k)=0$;
* if the three vertices are distinct and span an even number of edges, set $w(i,j,k)=+1$;
* if they span an odd number of edges, set $w(i,j,k)=-1$.

Why this rule? Each edge contributes a factor of $-1$ to the cyclic Seidel product, while each nonedge contributes $+1$. Therefore, for every ordered triple,

$$
S_{ij}S_{jk}S_{ki}=w(i,j,k).
$$

If a vertex repeats, one factor lies on the zero diagonal. If all vertices are distinct and the triple contains $m$ edges, the product is $(-1)^m$. The parity rule is therefore not an analogy; it is an exact identity.

Now expand the trace of the cube:

$$
\operatorname{tr}(S^3)
=\sum_{i\in V}(S^3)_{ii}
=\sum_{i,j,k\in V}S_{ij}S_{jk}S_{ki}.
$$

Substituting the local product identity gives the central result.

**Signed-Triangle Moment Theorem.** For every finite simple graph,

$$
\operatorname{tr}(S^3)=\sum_{i,j,k\in V}w(i,j,k).
$$

In words, the third Seidel moment equals the number of ordered triples spanning an even number of edges minus the number spanning an odd number of edges; repeated-vertex triples contribute nothing.

Because each set of three distinct vertices has six orderings, the same theorem can be written in an unordered form. Let $N_{\mathrm{even}}$ count three-vertex subsets spanning either zero or two edges, and let $N_{\mathrm{odd}}$ count those spanning either one or three edges. Then

$$
\operatorname{tr}(S^3)=6\bigl(N_{\mathrm{even}}-N_{\mathrm{odd}}\bigr).
$$

This formulation makes the combinatorics transparent. The cubic moment measures a parity imbalance among all three-vertex induced subgraphs.

## Two graphs at opposite extremes

Consider the empty graph on three vertices. Every pair is a nonedge, so every ordering of the three vertices has weight $+1$. There are $3!=6$ such orderings, hence

$$
\operatorname{tr}(S^3)=6.
$$

For the complete graph on three vertices, each ordering encounters three edges. Its weight is $(-1)^3=-1$, so

$$
\operatorname{tr}(S^3)=-6.
$$

These tiny examples reveal what the universal second moment conceals. Both graphs have $\operatorname{tr}(S^2)=6$, but their third moments point in opposite directions.

For a larger graph, the cubic moment can vanish even when neither parity class is absent. The condition

$$
\operatorname{tr}(S^3)=0
$$

means precisely that even-edge and odd-edge three-vertex subsets occur equally often. Spectral cancellation becomes an exact counting statement.

## Switching as a change of viewpoint

Seidel matrices admit a transformation known as **switching**. Choose a sign $d_i\in\{-1,+1\}$ for every vertex and form the diagonal matrix $D=\operatorname{diag}(d_i)$. The switched matrix is

$$
S'=DSD,
$$

so its entries satisfy $S'_{ij}=d_iS_{ij}d_j$. In graph language, choosing the vertices with sign $-1$ and switching toggles adjacency across the cut between that set and its complement, while leaving pairs on the same side unchanged.

Globally, switching preserves the spectrum because $D^2=I$, making $S'$ similar to $S$. But the cubic moment has an even more revealing local proof. Around a triangle,

$$
S'_{ij}S'_{jk}S'_{ki}
=(d_iS_{ij}d_j)(d_jS_{jk}d_k)(d_kS_{ki}d_i).
$$

Every vertex sign appears exactly twice. Since $d_i^2=d_j^2=d_k^2=1$, all six signs cancel, leaving

$$
S'_{ij}S'_{jk}S'_{ki}=S_{ij}S_{jk}S_{ki}.
$$

This product is a discrete **holonomy**: it records the net sign accumulated around a closed loop. Vertex signs behave like a gauge choice. They alter individual edge signs, but a closed cycle forgets the choice because every arrival at a vertex is paired with a departure.

**Triangle-Holonomy Invariance Theorem.** Diagonal sign switching preserves the cyclic product on every ordered triple and consequently preserves $\operatorname{tr}(S^3)$.

This is a local explanation for a global spectral invariant. The matrix argument says “similar matrices have the same eigenvalues.” The triangle argument says “the signs cancel around every closed three-step journey.” Both are correct, but the second exposes the mechanism.

## What happens when one edge disappears?

The identity also clarifies why edge deletion is subtler than the first two moments suggest. Deleting an edge $\{a,b\}$ changes the corresponding Seidel entries from $-1$ to $+1$. Only triples containing both $a$ and $b$ can change parity. For each third vertex $c$, the deletion reverses the sign of the triangle product associated with $\{a,b,c\}$.

Thus a global spectral change is assembled from a local census: among all third vertices $c$, how many give positive triangle products and how many give negative ones? The answer determines the change in the cubic moment.

Algebraically, the update has rank two:

$$
S'=S+2(e_ae_b^{\mathsf T}+e_be_a^{\mathsf T}),
$$

where $e_a$ and $e_b$ are coordinate vectors. For a symmetric Seidel matrix in which $\{a,b\}$ was an edge, expansion of the cube yields

$$
\operatorname{tr}((S')^3)-\operatorname{tr}(S^3)=12(S^2)_{ab}.
$$

The entry $(S^2)_{ab}$ is itself a sum over third vertices:

$$
(S^2)_{ab}=\sum_{c\in V}S_{ac}S_{cb}.
$$

The matrix perturbation and the triangle-parity count are therefore two views of the same local statistic. This bridge is promising for highly structured graphs, including Turán graphs, where one hopes to understand whether deleting an edge systematically changes Seidel energy.

## Beyond triangles

The triangle is only the first closed walk that can carry nontrivial sign information. For a closed walk

$$
v_0,v_1,\ldots,v_m=v_0,
$$

the product of switched edge signs contains every vertex sign an even number of times. The same cancellation therefore applies to closed walks of every length. Summing their products leads naturally to

$$
\operatorname{tr}(S^m),
$$

the $m$th spectral moment.

This suggests a broad program: interpret every spectral moment as a signed closed-walk count, prove switching invariance through local cancellation, and use the collection of moments to recover characteristic-polynomial information. The second moment supplies a graph-independent sphere, the third detects triangle parity, and higher moments can resolve structures that both miss.

There is also a cautionary lesson. Switching preserves the entire spectrum, so no spectral quantity—Seidel energy included—can strictly increase or decrease within one switching class. And the elementary inequality $\|\lambda\|_1\geq\|\lambda\|_2$ reaches equality only when at most one eigenvalue is nonzero, not when all eigenvalues have equal magnitude. Structural conjectures about energy must respect these basic geometric facts.

The central message is simple: a spectral trace need not be an opaque algebraic statistic. In the Seidel setting, the cube of a matrix listens to every triangle, records only the parity of its edges, and adds the votes. Switching may redraw many edges at once, but each triangular loop remembers exactly the same sign. Local cancellation is what makes the global spectrum endure.
