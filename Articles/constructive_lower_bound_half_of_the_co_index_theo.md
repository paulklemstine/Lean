# The Arithmetic of Antipodal Composition

## When symmetry becomes an extensive quantity

Physics is full of quantities that become simpler when systems are combined. Put two boxes of gas together and their volumes add. Join two collections of particles and their particle numbers add. Energy, at least when interactions can be neglected, is extensive: the total is the sum of the parts.

Topology rarely looks so obliging. Its invariants are usually sensitive to how pieces are attached, twisted, or punctured. Yet there is a particularly clean world in which a topological measure of antipodal symmetry obeys an exact many-body law. In that world, a system consists of finitely many vertices paired by a fixed-point-free reversal, and composition is performed by the simplicial join. The natural invariant is the $\mathbb Z_2$ co-index. It is not itself additive—but after adding one, it becomes perfectly extensive.

The resulting law is concise. If $K_0,\ldots,K_r$ are finite, nonempty antipodal systems of the kind described below, then

$$
\operatorname{coind}(K_0*\cdots*K_r)
=\sum_{i=0}^{r}\operatorname{coind}(K_i)+r.
$$

Equivalently,

$$
\operatorname{coind}(K_0*\cdots*K_r)+1
=\sum_{i=0}^{r}\bigl(\operatorname{coind}(K_i)+1\bigr).
$$

That shifted formula is the heart of the story. It says that $\operatorname{coind}+1$ behaves like a particle count.

## A universe made of opposite pairs

Begin with a finite nonempty set $V$ and an operation $v\mapsto -v$ satisfying two rules:

$$
-(-v)=v,\qquad -v\ne v.
$$

Thus every vertex has a distinct antipode, and the vertices split into disjoint two-element orbits $\{v,-v\}$. Suppose there are $q$ such pairs, so $|V|=2q$.

To turn this into a simplicial object, declare a collection of vertices to be a face precisely when it contains no complete antipodal pair. One may choose any number of vertices, but never both $v$ and $-v$. This is the boundary complex of a $q$-dimensional cross-polytope, also called an octahedral sphere. For $q=1$ it is two isolated points; for $q=2$ it is a square; for $q=3$ it is the boundary of an octahedron.

An equivariant simplicial map respects antipodes and faces. It sends $-v$ to the antipode of the image of $v$, and it never collapses a permitted face into a forbidden one. The standard $m$-dimensional octahedral sphere has $m+1$ antipodal pairs. The co-index of $K$ is the largest $m$ for which that sphere admits an equivariant simplicial map into $K$.

This definition turns a geometric question into a test of how much standard antipodal symmetry fits inside a target. A high co-index means that many independent antipodal directions can be represented simultaneously.

In the present model, the answer is exact.

**Classification Theorem.** If $K$ is a finite nonempty antipodal system with $q$ vertex pairs and with every antipodal-pair-free subset declared to be a face, then

$$
\operatorname{coind}(K)=q-1.
$$

Equivalently,

$$
2\bigl(\operatorname{coind}(K)+1\bigr)=|V(K)|.
$$

Why? Choose one representative from every antipodal pair. This identifies the vertices with $q$ labelled axes, each carrying a positive and a negative endpoint. After relabelling, the system is exactly the standard octahedral sphere with $q$ axes. The largest standard sphere that maps into it therefore has dimension $q-1$. The invariant is not merely estimated by orbit count; in this setting it is orbit count minus one.

## Composition by join

The simplicial join $K*L$ is formed by keeping the vertices of $K$ and $L$ disjoint and allowing a face from $K$ to coexist with a face from $L$. Antipodes act within each component. Geometrically, join raises dimension and blends two spaces into a larger one: the join of two zero-spheres is a circle, the join of a zero-sphere and a circle is a two-sphere, and in general

$$
S^a*S^b\cong S^{a+b+1}.
$$

In the octahedral model, the mechanism is especially transparent. Joining simply pools the antipodal axes. If $K$ has $q_K$ pairs and $L$ has $q_L$ pairs, then $K*L$ has $q_K+q_L$ pairs. Applying the classification theorem gives

$$
\operatorname{coind}(K*L)
=(q_K+q_L)-1
=(q_K-1)+(q_L-1)+1.
$$

Hence the **Sharp Binary Join Law**:

$$
\operatorname{coind}(K*L)
=\operatorname{coind}(K)+\operatorname{coind}(L)+1.
$$

The extra $1$ is not an error term. It is the familiar dimension shift in the topology of joins. It also tells us exactly which normalization is natural: define

$$
Q(K):=\operatorname{coind}(K)+1.
$$

Then

$$
Q(K*L)=Q(K)+Q(L).
$$

Moreover, $Q(K)=|V(K)|/2$, so the shifted co-index is literally the number of antipodal orbits.

## From two bodies to many

Real composite systems seldom stop at two components. Let $K_0,\ldots,K_r$ be any finite list of nonempty systems, and form their join with any fixed association. Vertex sets combine by disjoint union, so

$$
|V(K_0*\cdots*K_r)|=\sum_{i=0}^{r}|V(K_i)|.
$$

Repeatedly applying the binary law—or simply counting antipodal pairs—gives the **Exact Finite Composition Theorem**:

$$
\operatorname{coind}(K_0*\cdots*K_r)
=\sum_{i=0}^{r}\operatorname{coind}(K_i)+r.
$$

There are $r$ join operations among $r+1$ factors, and each contributes one unit. Shifting removes that bookkeeping:

$$
Q(K_0*\cdots*K_r)=\sum_{i=0}^{r}Q(K_i).
$$

A second identity ties the topological and combinatorial descriptions together:

$$
2Q(K_0*\cdots*K_r)
=|V(K_0*\cdots*K_r)|.
$$

Thus three calculations are really the same calculation: count vertices and divide by two; count antipodal orbits; or compute the co-index and add one.

Consider factors with $2$, $3$, and $5$ antipodal pairs. Their co-indices are $1$, $2$, and $4$. The composite has $10$ pairs, hence $20$ vertices and co-index $9$. The many-body formula agrees:

$$
1+2+4+2=9.
$$

The final $2$ records the two joins. In shifted form, the same computation is cleaner:

$$
(1+1)+(2+1)+(4+1)=2+3+5=10.
$$

## Why this resembles thermodynamics

The analogy with extensive physical variables is structural, not metaphorical. An extensive quantity is compatible with composition: its value on a noninteracting composite is the sum of its values on the factors. Here the join plays the role of composition, and $Q=\operatorname{coind}+1$ is extensive.

The unshifted co-index resembles a quantity measured relative to a baseline. Joining two systems combines their available antipodal directions, but dimensions are conventionally counted starting at zero. A system with one axis has co-index $0$, not $1$. The shift restores the underlying count.

This matters whenever symmetry sectors are assembled. In models with a binary reversal—spin flip, sign reversal, particle-hole exchange, or an antipodal configuration symmetry—one often wants a number that survives relabelling and composes predictably. In the complete octahedral face model, $Q$ provides precisely that number. It can be computed locally for each factor and summed without constructing the full composite.

The computational gain is immediate. If factor $i$ has $2q_i$ vertices, explicitly constructing the join still creates $2\sum_i q_i$ vertices and potentially a huge family of faces. Yet the co-index of the composite requires only

$$
\operatorname{coind}(K_0*\cdots*K_r)=\left(\sum_i q_i\right)-1.
$$

One pass through the list of orbit counts suffices. The running time is linear in the number of factors and independent of the exponentially large face family.

## The boundary of the theorem

The simplicity has a precise source. Every subset avoiding a full antipodal pair is assumed to be a face. This “complete octahedral” condition means that vertex-orbit data determines the entire simplicial object. If selected faces are removed, two systems can have the same paired vertices but different topological obstructions. Orbit count may then cease to determine co-index, and exact additivity may fail.

Nonemptiness is also essential. The formula $q-1$ presupposes at least one antipodal orbit. With no vertices, the natural-number normalization and the existence-based definition of co-index enter a degenerate regime.

These qualifications sharpen rather than weaken the result. They identify a solvable phase of equivariant topology: finite, free binary symmetry with maximal face structure. Within that phase, classification is complete, the join law is exact, and arbitrary finite composition is governed by ordinary addition.

## A practical symmetry ledger

The identities also provide a diagnostic tool. Suppose a database records a purported system with $N$ vertices and co-index $c$. In the complete antipodal model, consistency demands

$$
N=2(c+1).
$$

An odd value of $N$ immediately reveals a missing partner or an invalid fixed point. A mismatch for even $N$ signals either incorrect metadata or a complex that does not have the complete octahedral face structure. For a family of components, the same audit can be performed before and after composition:

$$
2\sum_i(c_i+1)=\sum_iN_i.
$$

This gives model builders a compact symmetry ledger. Local records determine the global invariant, while the global vertex count independently checks the sum. Because the calculation stores only one integer per component, it scales to systems whose full lists of faces would be impossible to enumerate: $q$ antipodal pairs already generate $3^q$ allowed faces, since each pair contributes the choice of its positive vertex, its negative vertex, or neither.

The compression is exact rather than approximate, but only because the model has no interactions beyond antipodal exclusion. Additional forbidden combinations carry information not visible in $q$. In physical language, the theorem describes an ideal noninteracting symmetry composition law; deleted faces play the role of constraints coupling otherwise independent sectors.

## A small law with a broad lesson

The most useful invariants are not always born additive. Sometimes the correct extensive variable is hidden by a conventional offset. Here co-index measures the dimension of the largest standard antipodal sphere that fits equivariantly into a system. Dimension starts at zero; orbit count starts at one. Adding one reconciles the two.

The final picture is therefore remarkably unified. A finite antipodal system is classified by its number of opposite pairs. Join composition adds those pairs. The shifted co-index counts them. Vertex number is twice that count. For every finite family,

$$
\boxed{
\operatorname{coind}(K_0*\cdots*K_r)+1
=\sum_{i=0}^{r}\bigl(\operatorname{coind}(K_i)+1\bigr)
=\frac12\sum_{i=0}^{r}|V(K_i)|
}.
$$

Topology, symmetry, and extensive bookkeeping meet in one equation. What first appears to be a geometric obstruction becomes, after classification and one well-chosen shift, the arithmetic of composition.
