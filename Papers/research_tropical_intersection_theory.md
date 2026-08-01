# Finite Polyhedral Tropical Intersection Theory: Multiplicity Preservation, Bézout Counts, and Sharp Support Bounds

**Aristotle**  
**August 1, 2026**

## Abstract

We develop a self-contained finite framework for weighted tropical intersections. A tropical variety is represented by a finite polyhedral complex equipped with codimension, nonnegative cell weights, a balancing condition, and degree. A zero-dimensional intersection is represented by a finite support together with a natural-number local multiplicity function, and its intersection number is the sum of the supported multiplicities. Within this framework we prove four related results. First, positive local multiplicities imply that support cardinality is bounded by total intersection number. Second, any bijective correspondence that preserves support and local multiplicity preserves the weighted intersection number. Third, the transverse plane model for curves of degrees $d$ and $e$, indexed by the Cartesian product of $d$ and $e$ degree directions and carrying unit multiplicity, has intersection number exactly $d e$; its support bound is sharp. Fourth, these conclusions transport to any classical finite intersection admitting such a correspondence with the transverse tropical model. The arguments isolate the finite combinatorial core of tropical Bézout counting and clarify which geometric input is required to pass between classical and tropical intersections.

## 1. Introduction

Intersection theory counts where geometric objects meet, but its stable quantity is usually not the raw number of visible meeting points. Tangencies, collisions, and degenerations force local multiplicities into the count. If a family of intersections changes continuously, several simple points may coalesce into a single point of higher multiplicity. The support shrinks while the weighted total remains stable.

Tropical geometry expresses this principle in polyhedral language. Algebraic curves are replaced by balanced weighted complexes, and intersection problems become finite or locally finite combinatorial calculations. The geometric passage to a tropical object can be sophisticated, but after suitable support and multiplicity data have been established, preservation of total intersection number is a finite reindexing theorem.

This paper studies that finite core. We make no claim that every geometric tropicalization automatically has the required properties. Instead, we formulate a precise multiplicity-preserving correspondence and prove what follows from it. This separation is useful: geometric work constructs the bridge, while finite intersection theory explains why the numerical invariant crosses it.

Our central example is the transverse intersection of plane tropical curves of degrees $d$ and $e$. We model the intersection cells by pairs of degree directions. There are $d e$ such pairs, and each carries multiplicity one. The resulting weighted count is $d e$, giving a finite tropical Bézout theorem and an explicit sharp cell bound. If an ordinary intersection corresponds to this model while preserving support and local multiplicity, then its total intersection number is also $d e$, and its support contains at most $d e$ points.

The paper is organized as follows. Section 2 defines finite polyhedral tropical varieties and weighted intersections. Section 3 establishes the support bound. Section 4 introduces multiplicity-preserving correspondences and proves invariance. Section 5 constructs and counts the transverse plane model. Section 6 transports the results to an ordinary intersection model. Section 7 presents algorithms and complexity. Sections 8 and 9 discuss examples, applications, limitations, and future work.

## 2. Finite polyhedral and weighted intersection data

### 2.1. Finite polyhedral tropical varieties

A finite polyhedral complex is a finite collection of polyhedral cells closed under taking faces and with intersections occurring along common faces. For the results below, its internal incidence representation is not needed; what matters is that the cells form a finite indexed family on which weights can be assigned.

**Definition 2.1 (Finite polyhedral tropical variety).** A finite polyhedral tropical variety consists of:

1. a finite polyhedral complex $K$;
2. a codimension $c\in\mathbb N$;
3. a weight function $w$ from the cells of $K$ to $\mathbb N$;
4. a balancing condition for the associated integer-weighted codimension-$c$ cycle; and
5. a degree $d\in\mathbb N$.

The balancing condition is the characteristic local conservation law of tropical cycles. Around each relevant face, the weighted primitive normal directions sum to zero in the appropriate quotient lattice. Although our finite counting theorems use only intersection supports and multiplicities, including balancing in the variety data distinguishes tropical cycles from arbitrary weighted cell collections.

The degree is retained as explicit data because the transverse plane count depends only on the two degrees. In a fuller geometric theory, degree is determined through intersections with suitable complementary linear spaces or through Newton data.

### 2.2. Finite weighted intersections

**Definition 2.2 (Finite weighted intersection).** A finite weighted intersection is a triple $(X,S,m)$ where $X$ is a finite ambient point set, $S\subseteq X$ is the finite support, and

$$
m:X\longrightarrow\mathbb N
$$

is a multiplicity function. Only values on $S$ contribute to the intersection number.

**Definition 2.3 (Total intersection number).** The total weighted intersection number of $(X,S,m)$ is

$$
I(S,m):=\sum_{p\in S}m(p).
$$

This definition permits $m$ to be specified on all of $X$ while summing only over supported points. It also allows zero multiplicity in the ambient representation, although the support bounds below require positive multiplicity on $S$.

**Remark 2.4.** The ambient point set and the support should not be conflated. The support records positions that participate in the intersection. The ambient set may contain additional candidate positions. This distinction becomes useful when transporting a support through a bijection of finite ambient types.

### 2.3. Transversality in the finite model

In geometric intersection theory, transversality generally forces local multiplicity one. The finite model captures this feature directly: a transverse intersection is represented by a support in which every local multiplicity equals $1$. The plane model introduced later has an even more explicit structure, with support equal to a Cartesian product of degree-direction labels.

## 3. Positive multiplicities and support cardinality

Our first result is a general fact about finite weighted sets.

**Theorem 3.1 (Positive-Multiplicity Support Bound).** Let $(X,S,m)$ be a finite weighted intersection. If

$$
m(p)>0\qquad\text{for every }p\in S,
$$

then

$$
|S|\le I(S,m).
$$

**Proof sketch.** Since $m(p)$ is a natural number and is positive on $S$, one has $1\le m(p)$ for each $p\in S$. Summing pointwise inequalities over the finite support yields

$$
|S|=\sum_{p\in S}1
\le \sum_{p\in S}m(p)
=I(S,m).
$$

No geometric hypothesis is needed beyond positivity. $\square$

This theorem gives a direct interpretation of multiplicity. Every distinct support point accounts for at least one unit of the total. Higher local multiplicity consumes additional units without adding support points.

**Corollary 3.2 (Unit multiplicities give equality).** Under the hypotheses of Theorem 3.1, if $m(p)=1$ for every $p\in S$, then

$$
|S|=I(S,m).
$$

**Proof sketch.** Every summand in the definition of $I(S,m)$ equals $1$, so the sum has one unit for each member of $S$. $\square$

**Proposition 3.3 (Equality characterization).** If all supported multiplicities are positive, then

$$
|S|=I(S,m)
$$

if and only if $m(p)=1$ for every $p\in S$.

**Proof sketch.** The reverse implication is Corollary 3.2. For the forward implication, if some $m(q)\ge 2$, then its contribution exceeds $1$, while every other supported point contributes at least $1$. Consequently $I(S,m)>|S|$, contradicting equality. $\square$

Proposition 3.3 is a natural strengthening of the bound and will be useful when distinguishing genuinely transverse models from intersections in which multiplicity has accumulated.

## 4. Multiplicity-preserving tropicalization correspondences

We now formalize the finite information needed to compare two intersection models.

**Definition 4.1 (Multiplicity-preserving tropicalization correspondence).** Let $(X_c,S_c,m_c)$ and $(X_t,S_t,m_t)$ be finite weighted intersections, interpreted respectively as classical and tropical models. A multiplicity-preserving tropicalization correspondence is a bijection

$$
\phi:X_c\longrightarrow X_t
$$

such that:

1. **support preservation:** for every $p\in X_c$,
   $$
   p\in S_c\quad\Longleftrightarrow\quad \phi(p)\in S_t;
   $$
2. **local multiplicity preservation:** for every $p\in S_c$,
   $$
   m_c(p)=m_t(\phi(p)).
   $$

Support preservation says that the bijection restricts to a bijection $S_c\to S_t$. Multiplicity preservation says that this restricted bijection is an isomorphism of weighted finite sets.

**Theorem 4.2 (Tropicalization Invariance of Intersection Number).** If two finite weighted intersections admit a multiplicity-preserving tropicalization correspondence, then their total intersection numbers agree:

$$
I(S_t,m_t)=I(S_c,m_c).
$$

**Proof sketch.** Reindex the finite sum over $S_c$ along the restricted bijection induced by $\phi$. Support preservation ensures that the target index set is exactly $S_t$. Local multiplicity preservation identifies corresponding summands. Thus

$$
\sum_{p\in S_c}m_c(p)
=
\sum_{p\in S_c}m_t(\phi(p))
=
\sum_{q\in S_t}m_t(q).
$$

The left and right sides are the two intersection numbers. $\square$

The theorem is deliberately conditional. Its assumptions expose the precise interface between geometry and finite combinatorics. Establishing a suitable map $\phi$ may require a valuation map, a lifting theorem, or transversality. Once those hypotheses are available, preservation of the total follows without further geometric analysis.

**Corollary 4.3 (Support cardinality is preserved).** Under a multiplicity-preserving tropicalization correspondence,

$$
|S_c|=|S_t|.
$$

**Proof sketch.** Support preservation and bijectivity imply that the restriction of $\phi$ is a bijection from $S_c$ to $S_t$. $\square$

**Corollary 4.4 (Positive-multiplicity bounds transport).** If the tropical supported multiplicities are positive, then so are the classical supported multiplicities, and

$$
|S_c|\le I(S_c,m_c)=I(S_t,m_t).
$$

**Proof sketch.** Corresponding multiplicities are equal, so positivity transfers. Apply Theorem 3.1 to the classical support and Theorem 4.2 to its total. $\square$

## 5. The transverse plane model and tropical Bézout counting

### 5.1. Construction

Let $d,e\in\mathbb N$. Write

$$
[d]=\{0,1,\ldots,d-1\},
\qquad
[e]=\{0,1,\ldots,e-1\}.
$$

When $d=0$ or $e=0$, the corresponding set is empty.

**Definition 5.1 (Transverse plane intersection model).** The transverse plane intersection of degrees $d$ and $e$ is the finite weighted intersection with ambient point set

$$
X_{d,e}=[d]\times[e],
$$

full support

$$
S_{d,e}=X_{d,e},
$$

and constant multiplicity

$$
m_{d,e}(i,j)=1.
$$

The pair $(i,j)$ represents the intersection cell arising from pairing the $i$th degree direction of the first curve with the $j$th degree direction of the second. The construction abstracts the transverse combinatorial count: every possible pair appears exactly once and contributes one unit.

### 5.2. Bézout number

**Theorem 5.2 (Transverse Tropical Bézout Theorem).** For all $d,e\in\mathbb N$, the transverse plane model has total intersection number

$$
I(S_{d,e},m_{d,e})=d e.
$$

**Proof sketch.** By definition, every element of $[d]\times[e]$ lies in the support and contributes $1$. Hence

$$
I(S_{d,e},m_{d,e})
=
\sum_{(i,j)\in[d]\times[e]}1
=
|[d]\times[e]|.
$$

The cardinality of a finite Cartesian product is the product of cardinalities. Since $|[d]|=d$ and $|[e]|=e$, the result follows:

$$
|[d]\times[e]|=|[d]|\,|[e]|=d e.
$$

This argument includes the cases $d=0$ or $e=0$, where the product set is empty and both sides vanish. $\square$

**Theorem 5.3 (Sharp Tropical Bézout Cell Bound).** The support of the transverse plane model satisfies

$$
|S_{d,e}|\le d e,
$$

and in fact equality holds:

$$
|S_{d,e}|=d e.
$$

**Proof sketch.** The support is the full Cartesian product $[d]\times[e]$, whose cardinality is $d e$. The displayed inequality is therefore sharp. Equivalently, Theorem 3.1 applies and becomes equality because every local multiplicity is $1$. $\square$

The distinction between Theorems 5.2 and 5.3 is conceptually useful. The first computes a weighted invariant; the second controls the number of distinct cells. They coincide only because this model is transverse and all multiplicities are one.

### 5.3. Example

For $d=3$ and $e=4$, the support is

$$
[3]\times[4]
=
\{(0,0),(0,1),(0,2),(0,3),
(1,0),\ldots,(2,3)\}.
$$

There are $12$ pairs. Each has multiplicity $1$, so both support cardinality and intersection number equal $12$. By contrast, a weighted support with multiplicities $(1,2,4,5)$ also has total $12$ but only four distinct points. The invariant total does not determine the spatial distribution of multiplicity.

## 6. Transport back to classical intersections

Suppose a classical finite intersection $(X_c,S_c,m_c)$ admits a multiplicity-preserving correspondence with the transverse plane model of degrees $d$ and $e$.

**Theorem 6.1 (Transported Bézout Theorem).** Under this hypothesis,

$$
I(S_c,m_c)=d e.
$$

**Proof sketch.** By Theorem 4.2, the classical and tropical totals are equal. By Theorem 5.2, the tropical total is $d e$. Therefore

$$
I(S_c,m_c)
=I(S_{d,e},m_{d,e})
=d e.
$$

The equality is obtained by combining an independently computed tropical count with preservation across the correspondence. $\square$

**Theorem 6.2 (Transported Classical Support Bound).** Under the same hypothesis,

$$
|S_c|\le d e.
$$

**Proof sketch.** The support $S_c$ is a subset of the finite ambient set $X_c$, so $|S_c|\le |X_c|$. The ambient bijection identifies $X_c$ with $[d]\times[e]$. Hence

$$
|S_c|
\le |X_c|
=|[d]\times[e]|
=d e.
$$

Alternatively, support preservation gives $|S_c|=|S_{d,e}|=d e$ when the target has full support. The stated inequality remains the robust bound obtained directly from containment and ambient cardinality. $\square$

**Remark 6.3.** Because Definition 4.1 preserves support in both directions and the transverse target has full support, every point of $X_c$ must in fact belong to $S_c$. Thus equality follows in this exact model. The inequality formulation remains useful because it highlights the upper-bound mechanism and persists under weaker variants in which the ordinary support is merely injected into the set of tropical candidate cells.

**Corollary 6.4 (Unit multiplicity on the classical side).** Every supported classical point has multiplicity $1$.

**Proof sketch.** Every tropical point in the transverse model has multiplicity $1$, and the correspondence preserves local multiplicity. $\square$

Together, Theorems 6.1 and 6.2 express the finite content of transporting Bézout counting through tropicalization.

## 7. Algorithms and computational complexity

The finite theory yields direct algorithms. These routines are useful for examples, data validation, and implementations of more geometric pipelines.

### 7.1. Weighted intersection audit

**Algorithm 7.1 (Weighted Intersection Audit).** Given a finite sequence of supported multiplicities $(m_1,\ldots,m_n)$:

1. verify that each $m_i$ is a nonnegative integer;
2. compute the support size $n$;
3. compute the total $I=\sum_{i=1}^n m_i$;
4. test whether all $m_i>0$;
5. if positivity holds, certify $n\le I$;
6. report whether equality holds, equivalently whether all $m_i=1$.

The algorithm uses $O(n)$ time. If multiplicities are streamed, the total, positivity flag, and unit-multiplicity flag require $O(1)$ auxiliary space. Storing labels or the full list requires $O(n)$ space.

### 7.2. Transverse model enumeration

**Algorithm 7.2 (Transverse Bézout Cell Enumerator).** Given nonnegative degrees $d$ and $e$:

1. create an empty cell list;
2. for each $i$ with $0\le i<d$:
3. for each $j$ with $0\le j<e$:
4. append the labeled cell $(i,j)$ with multiplicity $1$;
5. return the list and total $d e$.

Enumeration takes $O(d e)$ time and $O(d e)$ output space, which is optimal when every cell must be materialized. If only the intersection number or support bound is needed, direct multiplication takes constant arithmetic-operation time, with bit complexity determined by the sizes of $d$ and $e$.

### 7.3. Correspondence audit

For explicitly labeled finite data, a correspondence can be checked by verifying bijectivity, support equivalence, and multiplicity equality. With hashable labels and a supplied map, expected running time is linear in the ambient cardinality; sorting-based implementations take $O(n\log n)$ time. Once these checks pass, equality of totals need not be recomputed independently, although doing so is a useful consistency check.

## 8. Applications and interpretation

### 8.1. Degeneration and conserved weight

The inequality $|S|\le I(S,m)$ models the behavior of intersections under degeneration. Several unit intersections may combine at one location, reducing support while increasing local multiplicity. The weighted total can remain unchanged. This explains why raw point counting is unstable and why multiplicity is the natural conserved quantity.

### 8.2. Polyhedral computation

The transverse model converts degree data into a Cartesian-product enumeration. In computational tropical geometry, more elaborate intersections involve cones, lattice indices, and determinant multiplicities, but the same pattern remains: enumerate supported cells, compute local nonnegative weights, and sum. The finite preservation theorem then allows any validated support-and-multiplicity correspondence to transfer the result between representations.

### 8.3. Separation of geometric and combinatorial responsibilities

The framework makes assumptions explicit. The combinatorial theorems require no hidden analytic continuity argument. Conversely, they do not manufacture a tropicalization correspondence. A complete geometric application must prove that its valuation or degeneration map is bijective on the relevant finite point data, identifies the supports, and preserves local multiplicities. This modular separation clarifies where deeper hypotheses enter.

### 8.4. Boundary cases

Natural-number degrees allow $d=0$ or $e=0$. The transverse product is then empty, and the Bézout number is $0$. An empty support has total $0$, while positivity on support holds vacuously. These cases confirm that the definitions are uniform and require no ad hoc exception.

## 9. Scope, limitations, and future work

The present model is intentionally finite and transverse. It does not derive local tropical multiplicity from determinants of primitive direction vectors, construct stable intersections by perturbation, or prove realizability over a non-Archimedean field. Nor does it identify degree with Newton polygon data. Instead, it provides a rigorous finite target for those developments.

Several extensions are natural.

1. **Mixed-area Bézout.** For balanced plane tropical curves with lattice Newton polygons $P$ and $Q$, the stable intersection number should be expressed as the normalized mixed-area quantity
   $$
   \operatorname{area}(P+Q)-\operatorname{area}(P)-\operatorname{area}(Q).
   $$
   This replaces rectangular direction counting by lattice-polytope geometry.

2. **Perturbation invariance.** One should show that a sufficiently small generic translation makes a finite balanced plane intersection transverse while preserving the total local determinant multiplicity.

3. **Exact support criterion.** The positive-multiplicity support bound can be paired with the equality characterization: if the total is $d e$, then support has size at most $d e$, with equality exactly when every local multiplicity is one.

4. **Realizability correspondence.** For realizable plane tropical curves over a complete non-Archimedean field, a valuation map should be shown to induce a support- and multiplicity-preserving correspondence for transverse intersections.

5. **Higher-dimensional multidegrees.** For $n$ transverse tropical hypersurfaces in tropical projective $n$-space with degrees $d_1,\ldots,d_n$, the zero-dimensional stable intersection should have total multiplicity
   $$
   \prod_{i=1}^{n}d_i.
   $$

Each direction enriches the geometric side while preserving the finite pattern established here: local nonnegative multiplicities, a total obtained by summation, and invariance under a correspondence that respects those local data.

## 10. Conclusion

Finite tropical intersection theory reduces a stable geometric invariant to weighted combinatorics. Positive supported multiplicities bound the number of distinct intersection points by the total weight. A bijection preserving support and local multiplicity preserves the intersection number because it merely reindexes a finite sum. For the transverse plane model of degrees $d$ and $e$, intersection cells form the Cartesian product $[d]\times[e]$, every multiplicity is one, and both support cardinality and total intersection number equal $d e$. Any classical finite intersection linked to this model by a multiplicity-preserving correspondence inherits the same Bézout number and the corresponding support bound.

The simplicity of the concluding count is not a weakness but the point of the construction. Once the correct weighted correspondence is isolated, the geometry’s stable numerical content becomes a transparent product rule.
