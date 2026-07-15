# Symmetry by Counting: Why a Topological-Looking Join Law Becomes Arithmetic

Imagine a collection of objects arranged in inseparable opposite pairs. Every vertex has a unique antipode, applying “opposite” twice returns the original vertex, and no vertex is its own opposite. This modest symmetry appears in antipodal geometry, signed data, centrally symmetric polytopes, and combinatorial models of spaces with a free two-fold action.

At first, maps between such systems seem capable of complicated behavior. Joins—operations that combine two systems—seem more complicated still. A familiar topological instinct says that proving an exact formula for a symmetry index should require a global obstruction, perhaps something cohomological. In the octahedral combinatorial setting studied here, the surprise is the opposite: the entire theory collapses to orbit counting.

The central result is exact and memorable. For any finite, nonempty systems $K$ and $L$ of the kind described below, their coindices obey

$$
\operatorname{coind}(K*L)=\operatorname{coind}(K)+\operatorname{coind}(L)+1.
$$

The mysterious extra $1$ is not an artifact of notation. It records the way two independent families of antipodal axes concatenate under a join.

## The world of antipodal pairs

A **finite free $\mathbb Z_2$-set** is a finite vertex set $V$ equipped with a function $v\mapsto \bar v$ such that $\bar{\bar v}=v$ and $\bar v\ne v$. Its vertices therefore split into disjoint two-element orbits $\{v,\bar v\}$.

We give this set its **octahedral simplicial structure**: a finite collection of vertices is a face precisely when it contains no complete antipodal pair. Thus one may select at most one vertex from each orbit. If there are $r$ antipodal orbits, a maximal face chooses one sign from every orbit and has $r$ vertices.

The model sphere $S^n_{\mathrm{oct}}$ has signed coordinate vertices

$$
\{\pm e_0,\pm e_1,\ldots,\pm e_n\}.
$$

It has $2(n+1)$ vertices and $n+1$ antipodal orbits. Its faces are exactly the subsets that never contain both $e_i$ and $-e_i$. Geometrically, this is the boundary of the $(n+1)$-dimensional cross-polytope.

A map between two such systems must respect opposites and faces. Concretely, an **equivariant simplicial map** $f:K\to L$ satisfies $f(\bar v)=\overline{f(v)}$, and it cannot turn two non-antipodal source vertices into an antipodal target pair.

The **coindex** of a nonempty system $K$ is the largest integer $n$ for which there is an equivariant simplicial map

$$
S^n_{\mathrm{oct}}\longrightarrow K.
$$

It measures how large a standard octahedral sphere can be represented inside $K$ without violating antipodal symmetry or the face structure.

## The tiny argument that unlocks everything

The key theorem says that every equivariant simplicial map in this model is injective on vertices.

Why? Suppose $f(p)=f(q)$. Equivariance gives

$$
f(\bar q)=\overline{f(q)}.
$$

Hence $f(p)$ is antipodal to $f(\bar q)$. Simpliciality says that if two images are antipodal, their sources must already be antipodal. Therefore $p$ must be antipodal to $\bar q$, which means $p=q$.

This is the decisive rigidity. Maps cannot fold two vertices together. They cannot even collapse two different antipodal orbits. The resulting counting bound resembles a finite Borsuk–Ulam principle:

**Vertex Bound.** If $S^m_{\mathrm{oct}}$ maps equivariantly and simplicially into a finite free $\mathbb Z_2$-set $K$, then

$$
2(m+1)\le |V(K)|.
$$

The proof is immediate once injectivity is known: the source has $2(m+1)$ distinct vertices, and all must remain distinct in the target.

This bound already says that the possible source dimensions are bounded. Nonemptiness supplies a map from $S^0_{\mathrm{oct}}$, and finiteness ensures that the largest admissible dimension is genuinely achieved rather than merely approached.

## Every finite object is an octahedral sphere in disguise

The strongest structural fact is a classification theorem.

**Classification Theorem.** Every finite nonempty free $\mathbb Z_2$-set with the octahedral simplicial structure is equivariantly isomorphic to $S^{r-1}_{\mathrm{oct}}$, where $r$ is its number of antipodal orbits.

The construction is wonderfully concrete. Choose one representative from each antipodal pair. Number the representatives $0,1,\ldots,r-1$. Send each chosen representative to $+e_i$ and its antipode to $-e_i$. This is a bijection, respects the antipodal action, and preserves exactly the rule that forbids complete antipodal pairs.

So these apparently varied finite systems have no hidden geometry beyond the number of paired orbits. Their coindex is therefore a complete numerical invariant:

$$
\operatorname{coind}(K)=r-1,
$$

or equivalently,

$$
2\bigl(\operatorname{coind}(K)+1\bigr)=|V(K)|.
$$

This identity packages the entire classification into one line. Count the vertices, halve to count antipodal orbits, then subtract one.

There is also a converse hidden here. If two finite nonempty systems have the same coindex, then they have the same number of antipodal orbits. Choose and number one representative from each pair in both systems; matching equal numbers and matching their antipodes produces an isomorphism. Thus coindex does more than measure size: in this category, it determines the entire object up to symmetry-preserving relabeling. Any apparent differences between two systems of equal coindex amount only to permuting their axes or reversing selected signs.

This sharply separates the present model from arbitrary symmetric simplicial complexes. If one were free to delete extra faces, equal orbit counts would not determine the complex. The classification works because the octahedral rule includes every subset except those containing a forbidden opposite pair. Its power comes from the exact match between the involution and the face structure.

The nonempty assumption matters. With no vertex, there is no initial $S^0_{\mathrm{oct}}$ witness, and the “orbits minus one” expression no longer belongs naturally to the nonnegative integers.

## Joining worlds

The **join** $K*L$ takes the disjoint union of the vertices of $K$ and $L$, retaining the antipodal action separately on each side. In the octahedral structure, a face may choose compatible vertices from both systems. The operation combines independent coordinate families.

For standard spheres, this combination is explicit:

$$
S^m_{\mathrm{oct}}*S^n_{\mathrm{oct}}\cong S^{m+n+1}_{\mathrm{oct}}.
$$

The first sphere contributes $m+1$ antipodal axes, the second contributes $n+1$, and together they produce $(m+1)+(n+1)=m+n+2$ axes. A sphere with that many axes has dimension $m+n+1$.

Maps join as naturally as spaces do. Given equivariant simplicial maps $S^a_{\mathrm{oct}}\to K$ and $S^b_{\mathrm{oct}}\to L$, use the first map on the first summand and the second on the second summand. After identifying the joined source with $S^{a+b+1}_{\mathrm{oct}}$, one obtains a map

$$
S^{a+b+1}_{\mathrm{oct}}\longrightarrow K*L.
$$

This gives the constructive lower bound

$$
\operatorname{coind}(K*L)\ge
\operatorname{coind}(K)+\operatorname{coind}(L)+1.
$$

The matching upper bound now needs no elaborate obstruction. If $K$ and $L$ have $r$ and $s$ orbits, their disjoint union has $r+s$ orbits. Classification then yields

$$
\operatorname{coind}(K*L)=(r+s)-1.
$$

Since $\operatorname{coind}(K)=r-1$ and $\operatorname{coind}(L)=s-1$, elementary arithmetic gives the sharp join law.

This also explains suspension. Joining with $S^0_{\mathrm{oct}}$, which has one antipodal orbit and coindex $0$, increases coindex by exactly one:

$$
\operatorname{coind}(K*S^0_{\mathrm{oct}})=\operatorname{coind}(K)+1.
$$

Repeated joins simply keep adding orbit families. Commutativity and associativity at the level of coindex become the commutativity and associativity of addition.

## Maps as one-way size certificates

There is another useful consequence. If an equivariant simplicial map $K\to L$ exists and $L$ is finite, then

$$
\operatorname{coind}(K)\le \operatorname{coind}(L).
$$

Indeed, every sphere mapping into $K$ can be followed by the map from $K$ to $L$. In the finite nonempty classification, this statement is also simple orbit arithmetic: injectivity forces the target to have at least as many vertices and hence at least as many antipodal orbits.

Composition behaves exactly as expected, and joining maps respects identities and composition. Thus the join is not merely a numerical trick; it is a coherent operation on objects and maps. The coindex translates that structure into arithmetic.

A useful normalization makes this even cleaner. Define the shifted coindex by $\widehat c(K)=\operatorname{coind}(K)+1$. Then $\widehat c(K)$ is exactly the number of antipodal orbits, and the join formula becomes ordinary additivity:

$$
\widehat c(K*L)=\widehat c(K)+\widehat c(L).
$$

In other words, the unshifted $+1$ appears only because an $n$-sphere has $n+1$ coordinate axes. At the level of axes rather than dimensions, there is no correction term at all.

## A numerical glimpse

Take systems with $4$ and $7$ antipodal orbits. They have $8$ and $14$ vertices, and their coindices are $3$ and $6$. Their join has $11$ orbits and $22$ vertices, so its coindex is $10$. The formula reads

$$
10=3+6+1.
$$

For three systems with orbit counts $2$, $3$, and $5$, either parenthesization of the join has $10$ orbits and coindex $9$. Numerically,

$$
((2-1)+(3-1)+1)+(5-1)+1=9,
$$

and the other parenthesization gives the same result.

## Why the result matters

The broader lesson is methodological. A quantity defined through the existence of maps from spheres looks global and topological. Yet definitions can conceal rigidity. Here the simplicial rule and equivariance interact so strongly that every admissible map is injective. Once folding is impossible, finite classification follows from pairing, and a suspected obstruction becomes a count.

This clarity has practical echoes. In signed data structures, paired states can represent opposite orientations, binary phases, or mutually exclusive labels. The vertex bound says that a symmetry-preserving, compatibility-preserving encoding cannot compress such states by collision. The join law says that combining independent signed systems adds their orbit capacities, with the dimension normalization producing the single extra unit.

The result also points forward. One can weight antipodal orbits and ask for a graded join law; translate injectivity into exact coloring bounds for graphs built from incompatibility; or characterize coindex as the unique normalized invariant that is monotone under equivariant maps and additive under joins. In each direction, the central insight remains the same: before reaching for a global obstruction, ask whether the local rules have already made every map rigid.
