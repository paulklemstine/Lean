# Boundary Incidence and Tropical Cone Complexes in Moduli of Curves

## Abstract

We develop a self-contained combinatorial criterion comparing a normal-crossings boundary chart with a tropical cone chart. The input consists of boundary divisors, tropical rays, downward-closed families of incident collections, and a divisor–ray bijection preserving simultaneous incidence. From this hypothesis we prove that elementwise transport is an order isomorphism of the complete face posets. It preserves cardinality, inclusion, unions, intersections, codimension, and singleton incidence; it identifies the associated abstract simplicial complexes and restricts to an order isomorphism on the link of every face. We then study numerical signatures of connected weighted dual graphs. Both non-loop contraction, which removes one edge and one vertex, and loop contraction, which removes one edge and increases total vertex weight by one, preserve arithmetic genus and fixed-marking complexity. Every finite sequence of genus-preserving contractions therefore remains in the same genus component. These results isolate the combinatorial content needed to compare Deligne–Mumford boundary strata with tropical moduli. They establish a local toroidal blueprint, while also showing why incidence data alone do not imply a global toric realization: integral lattices, transition monoids, automorphisms, and monodromy remain additional global data.

## 1. Introduction

The moduli space $M_g$ parametrizes smooth curves of genus $g$. Families of smooth curves naturally acquire singular limits, most notably nodal curves. Adding stable nodal curves yields the Deligne–Mumford compactification, whose boundary is stratified according to the combinatorial type of the singular curve. A boundary divisor corresponds locally to imposing one nodal equation; intersections of divisors correspond to imposing several compatible nodes.

Tropical moduli records related information in polyhedral form. A tropical curve is represented by a weighted graph with edge lengths, and a combinatorial graph type determines a cone of length assignments. Setting selected lengths to zero contracts edges and passes to faces of that cone. Boundary strata and tropical cones therefore carry parallel specialization structures.

The purpose of this paper is to identify exactly which local hypothesis makes the parallel precise. We do not assume that a compactification has already been realized as a global toric variety. Instead, we begin with finite combinatorial charts and ask what follows from a divisor–ray correspondence that preserves every simultaneous incidence relation.

The answer is comprehensive at the simplicial level. The whole face poset is determined, not merely its vertices or maximal faces. The correspondence preserves intersections, unions, ranks, and links. Thus all data visible to the dual boundary complex agree with the tropical ray complex. A complementary graph calculation proves that the specialization operation underlying passage to cone faces preserves arithmetic genus, both for ordinary edges and loops.

This formulation also separates local and global issues. A compatible family of such charts is naturally toroidal when its integral monoids glue. To be globally toric, however, the cone complex must admit one fan realization in a common lattice with compatible embeddings and no obstructing monodromy. The present results establish the incidence-theoretic core and identify the extra structures that cannot be inferred from incidence alone.

## 2. Boundary charts and tropical charts

Let $D$ be a finite or locally finite set of labels for irreducible boundary divisors in a fixed chart. We work with finite subsets of $D$.

**Definition 2.1 (Boundary face family).** A boundary face family is a collection $\mathcal B$ of finite subsets of $D$ satisfying:

1. $\varnothing\in\mathcal B$;
2. if $S\in\mathcal B$ and $T\subseteq S$, then $T\in\mathcal B$.

Geometrically, $S\in\mathcal B$ means that the divisors indexed by $S$ have a common stratum. Downward closure expresses the fact that forgetting some incidence conditions cannot destroy an existing intersection.

Let $R$ be a set of labels for rays in a tropical cone chart.

**Definition 2.2 (Tropical face family).** A tropical face family is a collection $\mathcal T$ of finite subsets of $R$ satisfying:

1. $\varnothing\in\mathcal T$;
2. if $U\in\mathcal T$ and $V\subseteq U$, then $V\in\mathcal T$.

The interpretation is that $U\in\mathcal T$ precisely when the rays in $U$ occur together in a common simplicial cone.

**Definition 2.3 (Compatible boundary–ray atlas).** A compatible boundary–ray atlas is a tuple

$$
(D,R,\mathcal B,\mathcal T,\phi)
$$

in which $\mathcal B$ and $\mathcal T$ are boundary and tropical face families and $\phi:D\to R$ is a bijection satisfying, for every finite $S\subseteq D$,

$$
S\in\mathcal B\quad\Longleftrightarrow\quad \phi(S)\in\mathcal T,
$$

where

$$
\phi(S)=\{\phi(d):d\in S\}.
$$

The equivalence is the essential incidence hypothesis. A bijection between individual divisors and rays would not suffice: it could send an intersecting pair of divisors to rays that never share a cone. Compatibility requires agreement in every rank.

**Definition 2.4 (Transport and reverse transport).** Define

$$
\Phi(S)=\{\phi(d):d\in S\},\qquad
\Psi(U)=\{\phi^{-1}(r):r\in U\}.
$$

These maps act on all finite subsets, whether or not they are faces.

## 3. Elementary transport identities

We first record the set-theoretic facts from which the structural conclusions follow.

**Lemma 3.1 (Cardinality preservation).** For every finite $S\subseteq D$,

$$
|\Phi(S)|=|S|.
$$

**Proof sketch.** The restriction of the injective map $\phi$ to $S$ is a bijection from $S$ onto $\Phi(S)$. Therefore the two finite sets have equal cardinality. $\square$

**Lemma 3.2 (Mutual inverses).** For every finite $S\subseteq D$ and $U\subseteq R$,

$$
\Psi(\Phi(S))=S,
\qquad
\Phi(\Psi(U))=U.
$$

**Proof sketch.** Membership in the first set is equivalent to being $\phi^{-1}(\phi(d))$ for some $d\in S$, hence to membership in $S$. The second identity is symmetric. $\square$

**Lemma 3.3 (Order preservation and reflection).** For finite $S,T\subseteq D$,

$$
\Phi(S)\subseteq\Phi(T)
\quad\Longleftrightarrow\quad
S\subseteq T.
$$

**Proof sketch.** If $S\subseteq T$, elementwise transport gives the forward inclusion. Conversely, if $d\in S$, then $\phi(d)\in\Phi(S)\subseteq\Phi(T)$. Injectivity of $\phi$ forces $d\in T$. $\square$

**Lemma 3.4 (Boolean operations).** For finite $S,T\subseteq D$,

$$
\Phi(S\cap T)=\Phi(S)\cap\Phi(T),
$$

and

$$
\Phi(S\cup T)=\Phi(S)\cup\Phi(T).
$$

**Proof sketch.** Transport under any function preserves unions. It preserves intersections when the function is injective: if a transported element lies in both images, injectivity identifies its two preimages. $\square$

These statements reveal the role of bijectivity. Without injectivity, distinct divisors could collapse to one ray, changing cardinalities and codimensions. Without surjectivity, reverse transport would not cover every tropical face. Without incidence compatibility, transport would not restrict to the face families.

## 4. Complete face-poset correspondence

Equip $\mathcal B$ and $\mathcal T$ with the partial order of inclusion.

**Theorem 4.1 (Boundary-stratum criterion).** For every finite collection $S\subseteq D$, the corresponding boundary stratum exists if and only if the rays $\Phi(S)$ form a tropical face:

$$
S\in\mathcal B\quad\Longleftrightarrow\quad\Phi(S)\in\mathcal T.
$$

**Proof sketch.** This is precisely the incidence compatibility condition, stated geometrically. $\square$

**Theorem 4.2 (Face-Poset Correspondence Theorem).** For a compatible boundary–ray atlas, transport restricts to an order isomorphism

$$
\Phi:(\mathcal B,\subseteq)\overset{\sim}{\longrightarrow}(\mathcal T,\subseteq),
$$

with inverse $\Psi$.

**Proof sketch.** Theorem 4.1 shows that $\Phi$ maps $\mathcal B$ into $\mathcal T$. Applying the same equivalence to $\Psi(U)$ and using Lemma 3.2 shows that $\Psi$ maps $\mathcal T$ into $\mathcal B$. Lemma 3.2 makes the restrictions inverse bijections, and Lemma 3.3 proves that both order and order reflection are preserved. $\square$

The theorem identifies every stratum and every specialization relation. It is stronger than a comparison of maximal strata: all intermediate faces and all chains correspond.

**Corollary 4.3 (Divisor–ray correspondence).** For every $d\in D$, the singleton $\{d\}$ is a boundary face if and only if $\{\phi(d)\}$ is a tropical face.

**Proof sketch.** Apply Theorem 4.1 to the singleton set. $\square$

**Corollary 4.4 (Codimension–ray-count equality).** If a boundary face $S$ has simplicial codimension measured by its number of local boundary equations, then the corresponding tropical face has the same number of rays:

$$
\operatorname{codim}(S)=|S|=|\Phi(S)|.
$$

**Proof sketch.** The first equality is the normal-crossings local model; the second is Lemma 3.1. In a simplicial cone, the number of independent generating rays is its cone dimension. $\square$

**Corollary 4.5 (Preservation of meets and compatible joins).** For boundary faces $S,T$,

$$
\Phi(S\cap T)=\Phi(S)\cap\Phi(T).
$$

If $S\cup T$ is also a boundary face, then

$$
\Phi(S\cup T)=\Phi(S)\cup\Phi(T)
$$

is the corresponding tropical face.

**Proof sketch.** Use Lemma 3.4 and incidence compatibility. $\square$

## 5. Dual complexes and links

The face families naturally define abstract simplicial complexes.

**Definition 5.1 (Dual boundary complex).** The dual boundary complex $\Delta_{\partial}$ has vertex set consisting of the boundary labels that occur in at least one boundary face, and its simplices are the nonempty members of $\mathcal B$. Equivalently, one may include the empty simplex and regard all of $\mathcal B$ as its face set.

**Definition 5.2 (Tropical ray complex).** The tropical ray complex $\Delta_{\mathrm{trop}}$ has vertices the rays that occur in tropical faces and face set $\mathcal T$.

Downward closure ensures that both are abstract simplicial complexes. Notice that no geometric realization has yet been chosen; these are incidence objects.

**Theorem 5.3 (Dual-Complex Correspondence).** The vertex bijection $\phi:D\to R$ induces an isomorphism of abstract simplicial complexes

$$
\Delta_{\partial}\cong\Delta_{\mathrm{trop}}.
$$

A finite set is a simplex on the boundary side exactly when its image is a simplex on the tropical side.

**Proof sketch.** The map is bijective on vertices, and Theorem 4.1 identifies the face sets. Its inverse is induced by $\phi^{-1}$. $\square$

To compare neighborhoods of strata, we use links.

**Definition 5.4 (Link).** Let $\sigma$ be a face of an abstract simplicial complex $\Delta$. Its link is

$$
\operatorname{Lk}_{\Delta}(\sigma)
=
\{\tau:\tau\cap\sigma=\varnothing,
\ \tau\cup\sigma\in\Delta\}.
$$

The link records directions transverse to $\sigma$ that remain compatible with it.

**Theorem 5.5 (Link Correspondence Theorem).** For every boundary face $\sigma\in\mathcal B$, transport induces an order isomorphism

$$
\operatorname{Lk}_{\Delta_{\partial}}(\sigma)
\overset{\sim}{\longrightarrow}
\operatorname{Lk}_{\Delta_{\mathrm{trop}}}(\Phi(\sigma)).
$$

**Proof sketch.** Let $\tau$ be in the boundary link. Injectivity of $\phi$ gives

$$
\tau\cap\sigma=\varnothing
\quad\Longleftrightarrow\quad
\Phi(\tau)\cap\Phi(\sigma)=\varnothing.
$$

Lemma 3.4 and incidence compatibility give

$$
\tau\cup\sigma\in\mathcal B
\quad\Longleftrightarrow\quad
\Phi(\tau)\cup\Phi(\sigma)\in\mathcal T.
$$

Thus $\Phi(\tau)$ lies in the tropical link. Reverse transport proves surjectivity, while Lemma 3.3 identifies the inclusion orders. $\square$

The theorem says that the comparison is stable under localization at every stratum. It captures all immediate and iterated specialization directions near that stratum.

## 6. Weighted dual graphs and arithmetic genus

We now describe the combinatorial types associated with nodal curves.

**Definition 6.1 (Weighted dual signature).** The numerical signature of a connected weighted dual graph is a quadruple

$$
G=(V,E,W,N)\in\mathbb N^4,
$$

where $V$ is the number of vertices, $E$ the number of edges, $W$ the sum of all vertex weights, and $N$ the number of marked legs.

The full graph carries adjacency and automorphism data not present in the signature. The signature is nevertheless sufficient for genus calculations.

**Definition 6.2 (Arithmetic genus).** For a connected weighted dual graph, define

$$
g(G)=W+E+1-V.
$$

The term $E+1-V$ is the first Betti number of a connected underlying graph, and $W$ adds the genera attached to vertices. The connectedness assumption ensures $E+1-V\ge 0$ in the unweighted graph; more generally, the numerical condition

$$
V\le W+E+1
$$

ensures that the displayed nonnegative formula behaves as ordinary integer subtraction.

**Definition 6.3 (Augmented marked complexity).** Define

$$
A(G)=2g(G)+N.
$$

For fixed $N$, preserving $A$ is equivalent to preserving $g$. The usual stability expression $2g-2+N$ differs from $A$ by $2$, so the same contraction invariance applies to it whenever interpreted integrally.

### 6.1 Non-loop contraction

A non-loop edge joins distinct vertices. Contracting it merges its endpoints and removes that edge.

**Definition 6.4 (Non-loop contraction).** For $V\ge2$ and $E\ge1$, set

$$
C_{\mathrm{nl}}(V,E,W,N)=(V-1,E-1,W,N).
$$

**Theorem 6.5 (Genus invariance under non-loop contraction).** Suppose $V\ge2$, $E\ge1$, and $V\le W+E+1$. Then

$$
g(C_{\mathrm{nl}}(G))=g(G).
$$

**Proof sketch.** Direct substitution yields

$$
\begin{aligned}
g(C_{\mathrm{nl}}(G))
&=W+(E-1)+1-(V-1)\\
&=W+E+1-V\\
&=g(G).
\end{aligned}
$$

The lower bounds ensure the decrements are genuine, and the connectedness inequality avoids truncation artifacts. $\square$

### 6.2 Loop contraction

A loop contributes one cycle at a single vertex. Contracting it removes one edge while converting that cycle contribution into one additional unit of vertex weight.

**Definition 6.6 (Loop contraction).** For $E\ge1$, set

$$
C_{\ell}(V,E,W,N)=(V,E-1,W+1,N).
$$

**Theorem 6.7 (Genus invariance under loop contraction).** Suppose $E\ge1$ and $V\le W+E+1$. Then

$$
g(C_{\ell}(G))=g(G).
$$

**Proof sketch.** Again,

$$
\begin{aligned}
g(C_{\ell}(G))
&=(W+1)+(E-1)+1-V\\
&=W+E+1-V\\
&=g(G).
\end{aligned}
$$

The lost cycle has been transferred exactly into vertex weight. $\square$

**Corollary 6.8 (Complexity invariance).** Under the hypotheses of Theorem 6.5 or Theorem 6.7,

$$
A(C_{\mathrm{nl}}(G))=A(G),
\qquad
A(C_{\ell}(G))=A(G),
$$

respectively.

**Proof sketch.** Both contractions preserve $g$ and leave $N$ unchanged. Substitute into $A=2g+N$. $\square$

**Theorem 6.9 (Finite specialization invariance).** Let $F$ be any operation on weighted dual signatures satisfying

$$
g(F(G))=g(G)
$$

for every admissible $G$. Then for every integer $m\ge0$,

$$
g(F^m(G))=g(G).
$$

More generally, any finite sequence in which each individual step is an admissible loop or non-loop contraction preserves genus and marked complexity.

**Proof sketch.** Induct on $m$. The case $m=0$ is immediate. If the statement holds after $m$ steps, then applying one further genus-preserving step gives

$$
g(F^{m+1}(G))=g(F(F^m(G)))=g(F^m(G))=g(G).
$$

For a heterogeneous sequence, the same induction uses the invariance of the selected step at each stage. $\square$

## 7. Algorithms

The proofs lead directly to finite algorithms for comparing charts and simulating graph specialization.

### 7.1 Incidence-atlas validation

Given finite sets $D$ and $R$, a proposed bijection $\phi$, and explicit face families $\mathcal B$ and $\mathcal T$, validation proceeds as follows:

1. check that $\phi$ is bijective;
2. check that each family contains the empty face;
3. for each listed face, check that every subset is listed;
4. for every finite $S\subseteq D$, compare membership of $S$ in $\mathcal B$ with membership of $\Phi(S)$ in $\mathcal T$.

If $|D|=n$ and face families are represented by hash sets, exhaustive validation takes $O(n2^n)$ time: there are $2^n$ candidate subsets and transporting each costs at most $O(n)$. When the families are given by maximal faces, downward closure may be generated first; the worst-case output remains exponential because an $n$-simplex has $2^n$ faces.

Once validation succeeds, the face-poset isomorphism is computed simply by elementwise transport. A single face of size $k$ is transported in $O(k)$ expected time with hashed labels. Intersections and unions can likewise be computed in linear expected time in the input sizes.

### 7.2 Link extraction

For a fixed face $\sigma$, scan the face family and retain precisely the faces $\tau$ satisfying

$$
\tau\cap\sigma=\varnothing,
\qquad
\tau\cup\sigma\in\mathcal B.
$$

With hashed faces, each test takes $O(|\tau|+|\sigma|)$ expected time. Theorem 5.5 guarantees that transporting the resulting list produces exactly the tropical link; it is unnecessary to recompute the link independently except as a consistency check.

### 7.3 Genus-preserving contraction

For each contraction request, inspect whether it is a loop. A non-loop step decrements $V$ and $E$; a loop step decrements $E$ and increments $W$. In either case $N$ is unchanged. Each update and invariant check uses constant arithmetic time, so a sequence of $m$ contractions runs in $O(m)$ time and $O(1)$ auxiliary space if only the current signature is retained.

## 8. Worked example

Let

$$
D=\{a,b,c,d\},\qquad R=\{\rho_a,\rho_b,\rho_c,\rho_d\},
$$

with $\phi(x)=\rho_x$. Suppose the maximal boundary faces are

$$
\{a,b,c\},\qquad \{b,c,d\},
$$

and $\mathcal B$ contains these and every subset. Define $\mathcal T$ to consist of every subset of

$$
\{\rho_a,\rho_b,\rho_c\},\qquad
\{\rho_b,\rho_c,\rho_d\}.
$$

The atlas is compatible by construction. The two maximal strata map to the two maximal tropical faces. Their intersection is

$$
\{a,b,c\}\cap\{b,c,d\}=\{b,c\},
$$

and transport gives

$$
\{\rho_a,\rho_b,\rho_c\}\cap
\{\rho_b,\rho_c,\rho_d\}
=\{\rho_b,\rho_c\}.
$$

Fix $\sigma=\{b\}$. The face $\{a\}$ belongs to its link because it is disjoint from $\{b\}$ and $\{a,b\}$ is a face. The face $\{d\}$ also belongs to the link, while $\{a,d\}$ does not because $\{a,b,d\}$ is contained in neither maximal face. The transported link around $\{\rho_b\}$ has exactly the same pattern.

For the graph calculation, start with

$$
G_0=(V,E,W,N)=(4,6,2,3).
$$

Then

$$
g(G_0)=2+6+1-4=5,
\qquad
A(G_0)=2\cdot5+3=13.
$$

A non-loop contraction gives

$$
G_1=(3,5,2,3),
$$

and $g(G_1)=5$, $A(G_1)=13$. A loop contraction gives

$$
G_2=(3,4,3,3),
$$

again with $g(G_2)=5$ and $A(G_2)=13$. The specialization moves through graph types while remaining in the genus-$5$, three-marked component.

## 9. Geometric interpretation and limitations

For a stable nodal curve, vertices of the weighted dual graph represent irreducible components, vertex weights record component genera, edges record nodes, and legs record markings. Smoothing or specializing nodes changes the graph by contractions. Theorems 6.5–6.9 show numerically that these operations preserve total arithmetic genus.

On the boundary side, collections of nodes define intersections of boundary divisors. On the tropical side, edge-length coordinates define rays and cones. If a geometric construction supplies a compatible boundary–ray atlas, Theorems 4.2, 5.3, and 5.5 identify the entire incidence skeleton and all local links. This is the precise combinatorial connection between a Deligne–Mumford boundary chart and a tropical moduli chart.

The hypothesis is substantial. It is not a construction of the compactification, nor does it imply smoothness, representability, or stack-theoretic equivalence. In particular, an abstract simplicial complex forgets stabilizer groups of curves and automorphisms of weighted graphs. A stack-sensitive comparison should retain those isotropy groups.

Likewise, the conclusion is locally toroidal rather than automatically globally toric. A cone complex can have the same face poset as a fan without embedding globally into a single lattice. Transition maps may carry integral monodromy; local lattices may fail to glue; distinct cones may have nontrivial automorphisms. A global toric variety requires one coherent fan realization. Thus the face-poset theorem proves everything visible at the incidence level while sharply exposing the missing lattice and monodromy data.

## 10. Applications

The first application is a verification principle for proposed tropicalizations of boundary charts. Rather than compare strata one dimension at a time, it suffices to establish a bijection on divisors and the incidence equivalence for arbitrary finite collections. All poset, codimension, complex, and link comparisons then follow functorially.

The second application is computational. Finite incidence tables can be transported directly, and local links need only be computed on one side. This reduces duplicated calculations in examples of low-genus moduli spaces.

The third application concerns degeneration algorithms. A graph simplification routine based on admissible contractions can certify at each step that genus and marking count remain fixed. Loop and non-loop edges require different updates, but both preserve the same invariant.

The fourth application is conceptual. The decomposition separates three levels of structure:

1. **Incidence:** face posets and simplicial complexes;
2. **Integral geometry:** lattices, monoids, and balancing weights;
3. **Stack structure:** automorphisms and isotropy.

The current criterion completely handles the first level and supplies the genus invariant needed for specialization. This organization makes subsequent global questions more precise.

## 11. Future work

A first direction is stacky cone reconstruction. Stable weighted graphs of genus $g$ with $n$ legs form a category generated by edge contractions and graph automorphisms. The expectation is that this category reconstructs the extended tropical moduli space and matches the specialization category of Deligne–Mumford boundary strata. Genus-preserving contractions supply the morphisms, while automorphisms retain isotropy omitted by an ordinary simplicial complex.

A second direction is a toroidal compactification criterion. Compatible boundary–ray atlases should yield a toroidal object when transition maps preserve integral monoids. Global toricity should be equivalent to the existence of a single fan realization with compatible lattice embeddings and trivial monodromy.

A third direction is link recursion. The link of the cone indexed by a stable weighted graph is expected to decompose as a join of local deformation complexes attached to vertices and a contraction complex for remaining edges. Such a result would expose product structure hidden by the abstract link correspondence.

A fourth direction is balancing. Boundary intersection multiplicities should transport to integral weights satisfying tropical balancing at codimension-two cones. This would strengthen the incidence correspondence into a statement about tropical cycles and numerical intersection theory.

## 12. Conclusion

A divisor–ray bijection preserving all finite incidence relations determines far more than a correspondence of generators. It identifies complete specialization posets, preserves ranks and set operations, matches dual and tropical simplicial complexes, and identifies the link around every face. Weighted graph contractions provide the compatible dynamics: non-loop contraction trades one edge for one vertex, loop contraction trades one edge for one unit of weight, and both preserve arithmetic genus and marked complexity.

Together these results give a reusable local criterion for comparing boundary strata in compactified moduli of curves with cones in tropical moduli. They establish the full combinatorial blueprint while respecting the distinction between that blueprint and a global toric realization. The next layer is therefore clear: enrich incidence with integral lattices, monodromy, automorphisms, and balancing weights.
