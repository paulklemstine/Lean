# When Curves Break, Tropical Geometry Draws the Blueprint

A smooth curve can degenerate. A narrow neck pinches until it becomes a node; several components meet; a family that once looked continuous arrives at the edge of its parameter space. Algebraic geometers organize all smooth curves of genus $g$ into a moduli space, traditionally denoted $M_g$. To understand families that approach singular limits, they enlarge it by adding stable nodal curves. The resulting boundary is not an arbitrary fringe. It has a precise incidence pattern, and that pattern can be read as tropical geometry.

Tropical geometry replaces parts of an algebraic curve by a weighted graph whose edges carry lengths. The graph is not merely a sketch. Vertices represent irreducible components, vertex weights record their intrinsic genera, edges represent nodes, and legs can record marked points. Letting an edge length tend to zero contracts that edge, exactly as smoothing or specializing a node changes the combinatorial type of a curve.

The central result developed here is a local bridge between these two pictures. Whenever boundary divisors and tropical rays are matched bijectively, and whenever a collection of divisors meets exactly when the corresponding rays lie in a common tropical cone, the *entire* boundary incidence structure agrees with the tropical cone structure. Strata, dimensions, intersections, specialization order, and links all correspond. A second result shows why this comparison remains inside a fixed genus: every admissible edge contraction preserves the arithmetic genus of the weighted graph.

This is powerful, but it must be stated with care. Incidence data alone establish a combinatorial and local toroidal correspondence. They do not by themselves prove that a compactification is one global toric variety. A global toric realization additionally requires compatible lattices, integral gluing, and the absence of monodromy. The distinction is not technical housekeeping; it identifies exactly what remains after the combinatorics has been solved.

## Two atlases for one boundary

Imagine a finite boundary chart with a set $D$ of irreducible boundary divisors. A finite subset $S\subseteq D$ is called a **boundary face** when all divisors in $S$ meet in a common stratum. The empty set is included, and every subset of a boundary face is again a boundary face.

Now take a tropical cone chart with a set $R$ of rays. A finite subset $T\subseteq R$ is a **tropical face** when its rays lie in a common cone. Again, the empty set is a face, and taking a subset preserves the face property.

Suppose there is a bijection

$$
\phi:D\longrightarrow R
$$

such that, for every finite $S\subseteq D$,

$$
S\text{ is a boundary face}\quad\Longleftrightarrow\quad
\phi(S)\text{ is a tropical face}.
$$

This single equivalence is the atlas compatibility condition. It says more than “individual divisors correspond to individual rays.” It says all simultaneous incidences agree.

Transporting a collection means applying $\phi$ to each member:

$$
\Phi(S)=\{\phi(d):d\in S\}.
$$

Because $\phi$ is bijective, transport has an inverse. It also preserves cardinality, inclusion, unions, and intersections:

$$
|\Phi(S)|=|S|,
$$

$$
\Phi(S)\subseteq\Phi(T)\Longleftrightarrow S\subseteq T,
$$

$$
\Phi(S\cap T)=\Phi(S)\cap\Phi(T),\qquad
\Phi(S\cup T)=\Phi(S)\cup\Phi(T).
$$

These elementary-looking identities carry the main geometric message.

## The face-poset theorem

A **face poset** is the collection of all faces ordered by inclusion. Inclusion records specialization: imposing more boundary equations moves to a deeper stratum, while passing to a subface forgets some equations.

**Face-Poset Correspondence Theorem.** *For compatible boundary and tropical charts as above, elementwise transport $S\mapsto\Phi(S)$ is an order isomorphism from the complete boundary face poset to the complete tropical face poset.*

The proof is short enough to see in one glance. Compatibility says transport takes boundary faces to tropical faces. The inverse bijection takes tropical faces back. Bijectivity makes the two operations inverse, and preservation of inclusion makes them an order isomorphism.

Several consequences arrive at once.

First, a boundary stratum exists if and only if its rays span a tropical face. Second, a single boundary divisor occurs if and only if its corresponding tropical ray occurs. Third, intersections and unions of labels agree under transport. Fourth, the number of independent local boundary equations equals the number of rays in the corresponding simplicial cone. Thus, if a stratum is cut out by $k$ boundary divisors, its tropical face has $k$ rays:

$$
\operatorname{codim}(S)=|S|=|\Phi(S)|.
$$

This is the codimension–ray-count equality.

The same statement can be packaged topologically. The **dual boundary complex** has one vertex for each boundary divisor and one simplex for each nonempty simultaneous intersection. The **tropical ray complex** has one vertex for each tropical ray and one simplex for each collection lying in a common cone. The compatibility condition identifies their simplices exactly. Consequently the two abstract simplicial complexes are isomorphic.

## Looking around a stratum

A global matching can conceal local mistakes, so one should zoom in. Fix a boundary face $\sigma$. Its **link** consists of faces $\tau$ disjoint from $\sigma$ for which $\tau\cup\sigma$ is still a face. Intuitively, the link records all new degeneration directions available near the chosen stratum without repeating directions already imposed.

**Link Correspondence Theorem.** *Transport induces an order isomorphism between the link of every boundary face $\sigma$ and the link of the tropical face $\Phi(\sigma)$.*

Indeed, a bijection preserves disjointness, while compatibility and preservation of unions give

$$
\tau\cup\sigma\text{ is a boundary face}
\Longleftrightarrow
\Phi(\tau)\cup\Phi(\sigma)\text{ is a tropical face}.
$$

So the comparison is not only global. Every neighborhood in the incidence complex has the same combinatorial specialization directions on both sides.

## Why contraction does not change genus

The bridge to curves needs one more ingredient. A connected weighted dual graph can be summarized numerically by four nonnegative integers:

- $V$, the number of vertices;
- $E$, the number of edges;
- $W$, the sum of the vertex weights;
- $N$, the number of marked legs.

Its arithmetic genus is

$$
g=W+E+1-V.
$$

Its marked stability complexity may be recorded as

$$
C=2g+N,
$$

which differs from the familiar $2g-2+N$ only by a constant shift and avoids irrelevant subtraction issues in nonnegative arithmetic.

There are two local edge contractions.

For a non-loop edge joining two distinct vertices, contraction merges those vertices and deletes the edge:

$$
(V,E,W,N)\longmapsto(V-1,E-1,W,N).
$$

Provided the graph has at least two vertices and at least one edge, direct substitution gives

$$
W+(E-1)+1-(V-1)=W+E+1-V=g.
$$

For a loop, contraction deletes the loop and adds one unit to the weight of its vertex:

$$
(V,E,W,N)\longmapsto(V,E-1,W+1,N).
$$

Again,

$$
(W+1)+(E-1)+1-V=W+E+1-V=g.
$$

**Genus-Preservation Theorem.** *Every admissible non-loop or loop contraction of a connected weighted dual graph preserves arithmetic genus and the number of legs; hence it preserves $C=2g+N$.*

Repeated contractions preserve genus as well: if every step preserves $g$, induction on the number of steps shows that any finite chain does. This is the numerical mechanism ensuring that tropical specialization stays in the same fixed-genus, fixed-marking component.

As an example, take $(V,E,W,N)=(4,6,2,3)$. Then $g=2+6+1-4=5$. A non-loop contraction produces $(3,5,2,3)$, still of genus $5$. A subsequent loop contraction produces $(3,4,3,3)$, again of genus $5$. The graph changes, but the moduli problem does not.

## From local agreement to global geometry

The results clarify what a tropical compactification statement truly requires. At the simplicial level, compatible divisor–ray atlases settle everything visible through incidence: faces, strata, links, codimensions, and specialization. They give a rigorous local criterion for identifying the boundary complex of a stable-curve compactification with a tropical moduli complex.

But “toroidal” and “toric” are not synonyms. A toroidal space is locally modeled on toric charts. A globally toric variety must arise from a single fan in a common lattice. Incidence alone does not remember lattice embeddings, transition monoids, automorphism groups, or monodromy around loops in the cone complex. Therefore the correct conclusion is conditional and structural: compatible atlases provide the full combinatorial skeleton of the desired compactification; a global toric conclusion requires additional global gluing data.

That boundary matters far beyond moduli theory. Degeneration methods appear in enumerative geometry, mirror symmetry, non-Archimedean geometry, and the study of singular limits in mathematical physics. Whenever a complicated geometric family breaks into combinatorial pieces, one asks whether the pieces retain enough information to reconstruct how the family fits together. Here the answer is precise: a bijection on elementary directions is insufficient, but a bijection preserving *all simultaneous incidence* recovers the complete face architecture.

There is also a practical lesson for computation. One may store a chart as a finite table of compatible subsets. After checking the incidence equivalence once, there is no need to compare codimensions, links, and specialization chains separately: each is transported automatically. A graph-specialization program likewise needs only two constant-time updates. For a non-loop it subtracts one from both $V$ and $E$; for a loop it subtracts one from $E$ and adds one to $W$. The invariant $g=W+E+1-V$ becomes a simple diagnostic that detects an invalid update immediately.

The emerging picture is vivid. A nodal curve leaves behind a weighted graph. Each node becomes an edge; each boundary divisor becomes a ray; each compatible cluster of degenerations becomes a cone. Contracting edges moves to faces without changing genus. The boundary and the tropical world are therefore not merely analogous drawings. Under the atlas compatibility condition, they are the same combinatorial blueprint, viewed once through algebraic degeneration and once through polyhedral geometry.
