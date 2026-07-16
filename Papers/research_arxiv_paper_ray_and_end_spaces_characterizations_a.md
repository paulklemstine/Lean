# Coordinate Relabelling of Ray Spaces and Laminar Prime-Adic Cluster Hierarchies

## Abstract

We study two concrete mechanisms by which compatible finite data control infinite topological structure. First, a coordinate tree over an alphabet $A$ is defined as a prefix-closed family of finite words, and its ray space consists of infinite sequences whose every finite prefix belongs to the tree. We prove that a homeomorphic relabelling $e:A\to B$ induces an explicit homeomorphism between the original ray space and the ray space of the relabelled tree. The map and its inverse act coordinatewise, so the combinatorial certificate directly constructs the topological equivalence. Second, for a prime $p$, we study rational threshold clusters defined through the $p$-adic valuation of differences. The strong triangle inequality implies cluster transitivity; thresholds act antitonically; and every member of a cluster may serve as its center. Consequently, equal-threshold clusters are either equal or disjoint, and clusters across thresholds form a laminar hierarchy. These results expose a common architecture: finite prefixes and finite-resolution valuation balls both organize into rooted refinement systems whose compatible chains represent infinite boundary data. We give constructive algorithms, finite examples, and a precise account of the scope and prospective extensions of this framework.

## 1. Introduction

Spaces of infinite paths arise naturally as boundaries of rooted trees, as state spaces of indefinitely continuing processes, and as models of graph-theoretic directions toward infinity. Their topology is determined by finite information: two rays are close when their initial segments agree for a long time. This makes combinatorial descriptions of finite prefixes a promising route to topological classification.

A complete classification of broad families of ray and end spaces may require flexible correspondences between entire systems of finite levels. The present work isolates a rigorous explicit regime in which the combinatorial witness can be converted directly into a homeomorphism. If every coordinate label is changed by a homeomorphism of alphabets and the tree is relabelled accordingly, then coordinatewise relabelling gives a homeomorphism of ray spaces. The proof identifies the exact compatibility law needed: relabelling commutes with passage to every finite initial segment.

We then examine a second refinement system supplied by arithmetic. For a prime $p$, the $p$-adic valuation regards rational numbers as close when their difference is divisible by a high power of $p$. Threshold sets for this notion of closeness differ sharply from Euclidean balls. The strong triangle inequality forces center-independence: once a point lies in a threshold cluster, recentering there does not change the set. Hence clusters at a fixed scale partition the rational numbers, while clusters at increasing thresholds refine one another.

The two developments are mathematically distinct but structurally parallel. A finite prefix is a finite-resolution observation of a ray. A valuation cluster is a finite-resolution observation of a rational point. In each case, refinement is nested, and compatible data across all resolutions suggest a point on an infinite boundary. This parallel motivates the use of cluster trees as presentations of ultrametric spaces and provides a bridge between arithmetic neighborhoods and ray spaces.

The contributions are:

1. a self-contained definition of coordinate trees and their ray-space topology;
2. an explicit coordinate relabelling theorem, including the homeomorphism and its inverse;
3. transitivity, antitonicity, and center-independence for rational prime-adic threshold clusters;
4. the derived partition and laminarity properties of these clusters;
5. constructive algorithms for relabelling finite ray data and building finite cluster hierarchies.

The claims are deliberately scoped. The relabelling theorem handles a single uniform change of alphabet, not arbitrary coherent isomorphisms between tree levels. The cluster results concern rational points and integer valuation thresholds; they provide local structural laws rather than a full realization theorem for all completely ultrametrizable spaces.

## 2. Coordinate trees and ray spaces

### 2.1. Finite words and prefixes

Let $A$ be a set. Write $A^{<\mathbb{N}}$ for the set of all finite words over $A$. A word of length $n$ is a tuple

$$
u=(a_0,a_1,\ldots,a_{n-1}).
$$

The empty word is denoted by $\varnothing$. If $u$ and $v$ are finite words, then $u\preccurlyeq v$ means that $u$ is an initial segment, or prefix, of $v$.

**Definition 2.1 (Coordinate tree).** A coordinate tree over $A$ is a subset $T\subseteq A^{<\mathbb{N}}$ such that:

1. $\varnothing\in T$;
2. if $u\preccurlyeq v$ and $v\in T$, then $u\in T$.

Thus membership records which finite coordinate histories are admissible, and prefix closure guarantees that every earlier stage of an admissible history is itself admissible.

For an infinite sequence $x\in A^{\mathbb{N}}$ and $n\in\mathbb{N}$, define its length-$n$ initial segment by

$$
x\upharpoonright n=(x_0,x_1,\ldots,x_{n-1}).
$$

At $n=0$, this is the empty word.

**Definition 2.2 (Ray and ray space).** A ray through $T$ is an infinite sequence $x\in A^{\mathbb{N}}$ satisfying

$$
x\upharpoonright n\in T
$$

for every $n\in\mathbb{N}$. The ray space of $T$ is

$$
[T]=\{x\in A^{\mathbb{N}}: \forall n\in\mathbb{N},\ x\upharpoonright n\in T\}.
$$

Suppose now that $A$ is a topological space. Give $A^{\mathbb{N}}$ the product topology and $[T]$ the induced subspace topology. If $A$ is discrete, a standard basic neighborhood fixes finitely many coordinates. For a ray $x$ and an allowed prefix $x\upharpoonright n$, the corresponding cylinder is

$$
N_T(x\upharpoonright n)=\{y\in[T]:y\upharpoonright n=x\upharpoonright n\}.
$$

In the discrete case, these cylinders form a neighborhood basis. The topology therefore records finite agreement.

### 2.2. Examples

**Example 2.3 (Full binary tree).** Let $A=\{0,1\}$ with the discrete topology, and let $T=A^{<\mathbb{N}}$. Every finite binary word is admissible, so $[T]=A^{\mathbb{N}}$. The sequence $x_n=0$ for all $n$ is a ray, as is $x_n=n\bmod 2$.

**Example 2.4 (Forbidden finite patterns).** Let $A=\{0,1\}$ and let $T$ consist of finite words containing no consecutive pair $11$. This family is prefix closed. Its rays are precisely the infinite binary sequences in which every $1$ is followed, if another coordinate follows, by $0$. The topology still measures agreement of finite histories, while the tree imposes a local admissibility constraint.

## 3. Relabelling and classification

### 3.1. Relabelled trees

Let $A$ and $B$ be sets, and let $e:A\to B$ be a bijection. Extend $e$ coordinatewise to finite words and infinite sequences. For a finite word $u=(a_0,\ldots,a_{n-1})$, put

$$
e_*(u)=(e(a_0),\ldots,e(a_{n-1})).
$$

For $x\in A^{\mathbb{N}}$, put

$$
E(x)_n=e(x_n).
$$

**Definition 3.1 (Relabelled coordinate tree).** The relabelling of $T$ along $e$ is

$$
eT=\{v\in B^{<\mathbb{N}}:e^{-1}_*(v)\in T\}.
$$

The empty word lies in $eT$. If $u\preccurlyeq v$ and $v\in eT$, then $e^{-1}_*(u)\preccurlyeq e^{-1}_*(v)$; prefix closure of $T$ gives $e^{-1}_*(u)\in T$, hence $u\in eT$. Thus $eT$ is again a coordinate tree.

The basic compatibility identity is

$$
E(x)\upharpoonright n=e_*(x\upharpoonright n).
$$

Equivalently,

$$
e^{-1}_*(E(x)\upharpoonright n)=x\upharpoonright n.
$$

This identity is the entire combinatorial core of the classification result.

### 3.2. The coordinate relabelling theorem

**Theorem 3.2 (Coordinate Relabelling Theorem).** Let $A$ and $B$ be topological spaces, let $T$ be a coordinate tree over $A$, and let $e:A\to B$ be a homeomorphism. Then $[T]$ and $[eT]$ are homeomorphic. An explicit homeomorphism $E:[T]\to[eT]$ is given by

$$
E(x)_n=e(x_n),
$$

and its inverse $F:[eT]\to[T]$ is given by

$$
F(y)_n=e^{-1}(y_n).
$$

**Proof sketch.** Let $x\in[T]$. For every $n$, the pullback under $e^{-1}$ of $E(x)\upharpoonright n$ equals $x\upharpoonright n$, which belongs to $T$. Therefore $E(x)\upharpoonright n\in eT$, and $E(x)$ is a ray through $eT$. The same argument with $e^{-1}$ shows that $F$ sends $[eT]$ to $[T]$.

Coordinatewise application of $e^{-1}$ after $e$, and of $e$ after $e^{-1}$, gives the identity sequence. Thus $F\circ E$ and $E\circ F$ are identity maps on their respective ray spaces.

For continuity, the $n$th coordinate of $E$ is the composition of the $n$th coordinate projection with $e$. Both maps are continuous, and the universal property of the product topology implies that $E$ is continuous as a map into $B^{\mathbb{N}}$. Restriction to the subspaces preserves continuity. Replacing $e$ by $e^{-1}$ proves continuity of $F$. Hence $E$ is a homeomorphism. $\square$

**Corollary 3.3 (Cylinder transport).** Under the hypotheses of Theorem 3.2, if $u\in T$, then

$$
E\bigl(N_T(u)\bigr)=N_{eT}(e_*(u)).
$$

**Proof sketch.** A ray begins with $u$ exactly when its coordinatewise relabelling begins with $e_*(u)$. Bijectivity supplies equality rather than only inclusion. $\square$

This corollary makes the topological content especially visible in the discrete case: the homeomorphism transports the canonical finite-prefix basis exactly.

### 3.3. Scope of the theorem

Theorem 3.2 gives a sufficient condition for homeomorphism and a direct certificate. It does not claim that every homeomorphism between ray spaces must arise from one alphabet homeomorphism. Indeed, a general homeomorphism may rearrange cylinders in ways depending on their depth or earlier coordinates. A broader classification would replace the single map $e$ with coherent maps between finite levels, preserving extension and compatibility. The explicit theorem identifies the identities such a generalization must reproduce.

## 4. Prime-adic local multiplicity and threshold clusters

### 4.1. Rational valuations

Fix a prime $p$. Every nonzero rational number $q$ can be written uniquely in the form

$$
q=p^r\frac{a}{b},
$$

where $r\in\mathbb{Z}$ and neither integer $a$ nor integer $b$ is divisible by $p$. Define the $p$-adic valuation by $v_p(q)=r$.

For distinct $x,y\in\mathbb{Q}$, define the local multiplicity

$$
m_p(x,y)=v_p(x-y).
$$

It is symmetric because $x-y=-(y-x)$ and $v_p(-q)=v_p(q)$. Its decisive property is the non-Archimedean, or strong, triangle inequality.

**Lemma 4.1 (Strong triangle law).** If the local multiplicities in the expression are defined, then

$$
m_p(y,z)\ge \min\{m_p(y,x),m_p(x,z)\}.
$$

**Proof sketch.** Write $y-z=(y-x)+(x-z)$. The $p$-adic valuation of a sum is at least the minimum of the valuations of its summands. Applying this valuation law gives the result. Coincident-point cases in later applications are handled separately by equality clauses. $\square$

### 4.2. Threshold clusters

**Definition 4.2 (Valuation cluster).** For an integer $k$ and a center $x\in\mathbb{Q}$, define

$$
C_{p,k}(x)=\{y\in\mathbb{Q}:y=x\text{ or }(y\ne x\text{ and }k\le m_p(x,y))\}.
$$

The explicit equality clause ensures that every center belongs to its own cluster without assigning an integer value to the valuation of zero.

**Example 4.3.** Since $v_2(2)=1$, one has

$$
2\in C_{2,1}(0).
$$

More generally, for an integer $a$ and positive threshold $k$, membership $a\in C_{p,k}(0)$ means that $p^k$ divides $a$, apart from the automatically included center $a=0$.

## 5. Structural theorems for valuation clusters

### 5.1. Transitivity

**Theorem 5.1 (Cluster Transitivity Theorem).** Let $p$ be prime, let $k\in\mathbb{Z}$, and let $x,y,z\in\mathbb{Q}$. If

$$
y\in C_{p,k}(x)
\quad\text{and}\quad
z\in C_{p,k}(x),
$$

then

$$
z\in C_{p,k}(y).
$$

**Proof sketch.** If $z=y$, membership follows from the equality clause. If $x=y$ or $x=z$, the conclusion reduces directly to one of the hypotheses, using symmetry of $m_p$. In the remaining case the points are positioned so that both hypotheses yield

$$
k\le m_p(y,x)
\quad\text{and}\quad
k\le m_p(x,z).
$$

Lemma 4.1 gives

$$
m_p(y,z)\ge\min\{m_p(y,x),m_p(x,z)\}\ge k.
$$

Since $y\ne z$ in the remaining case, the inequality is exactly the nontrivial membership condition for $z\in C_{p,k}(y)$. $\square$

The theorem says that membership at one threshold behaves like an equivalence relation once equality is included. Reflexivity comes from the equality clause, symmetry comes from valuation symmetry, and transitivity is the content above.

### 5.2. Antitonicity in the threshold

**Theorem 5.2 (Threshold Antitonicity Theorem).** Fix $p$ and $x\in\mathbb{Q}$. If $k\le\ell$, then

$$
C_{p,\ell}(x)\subseteq C_{p,k}(x).
$$

Equivalently, the set-valued function $k\mapsto C_{p,k}(x)$ is antitone.

**Proof sketch.** Let $y\in C_{p,\ell}(x)$. If $y=x$, then $y\in C_{p,k}(x)$ automatically. Otherwise, $\ell\le m_p(x,y)$. Since $k\le\ell$, transitivity of the ordinary order gives $k\le m_p(x,y)$, proving the desired membership. $\square$

Thus increasing the required valuation produces smaller clusters. The threshold is a resolution parameter: larger $k$ reveals finer distinctions.

### 5.3. Independence of the center

**Theorem 5.3 (Center-Independence Theorem).** Let $p$ be prime. If $y\in C_{p,k}(x)$, then

$$
C_{p,k}(y)=C_{p,k}(x).
$$

**Proof sketch.** To prove $C_{p,k}(x)\subseteq C_{p,k}(y)$, take $z\in C_{p,k}(x)$ and apply Theorem 5.1 to the two memberships $y,z\in C_{p,k}(x)$. For the reverse inclusion, first apply Theorem 5.1 to $y\in C_{p,k}(x)$ and $x\in C_{p,k}(x)$; this gives $x\in C_{p,k}(y)$. Then any $z\in C_{p,k}(y)$ may be combined with this last membership in another application of transitivity, yielding $z\in C_{p,k}(x)$. The two inclusions establish equality. $\square$

Center-independence is the characteristic geometry of an ultrametric ball: every point inside the ball is an equally valid center.

### 5.4. Partition and laminarity consequences

**Corollary 5.4 (Equal-threshold partition).** For fixed prime $p$ and threshold $k$, any two clusters $C_{p,k}(x)$ and $C_{p,k}(y)$ are either disjoint or equal.

**Proof sketch.** Suppose they intersect at $z$. Then $z\in C_{p,k}(x)$ and $z\in C_{p,k}(y)$. Center-independence gives

$$
C_{p,k}(x)=C_{p,k}(z)=C_{p,k}(y).
$$

Hence a nonempty intersection forces equality. $\square$

**Corollary 5.5 (Cross-threshold laminarity).** Let $k\le\ell$. If

$$
C_{p,k}(x)\cap C_{p,\ell}(y)\ne\varnothing,
$$

then

$$
C_{p,\ell}(y)\subseteq C_{p,k}(x).
$$

**Proof sketch.** Choose $z$ in the intersection. Center-independence gives $C_{p,k}(x)=C_{p,k}(z)$ and $C_{p,\ell}(y)=C_{p,\ell}(z)$. Threshold antitonicity then yields $C_{p,\ell}(z)\subseteq C_{p,k}(z)$. $\square$

The family of all clusters is therefore laminar: intersecting clusters are comparable by inclusion. This permits one to regard clusters as vertices of a rooted refinement tree, with edges joining a cluster to its immediate represented refinements when such immediate levels are selected.

## 6. Constructive algorithms

### 6.1. Coordinatewise ray relabelling

Given a finite observed prefix $u=(a_0,\ldots,a_{n-1})$ and a relabelling $e$, compute $e_*(u)$ by applying $e$ independently to every coordinate. If evaluating $e$ costs $O(1)$, the time complexity is $O(n)$ and the output space is $O(n)$. For a streamed ray, the procedure is online: the $i$th output is emitted as soon as the $i$th input arrives, using $O(1)$ auxiliary space beyond input and output buffering.

Correctness follows from prefix compatibility. If $u$ is an admissible prefix in $T$, then $e_*(u)$ is admissible in $eT$ by definition. Applying $e^{-1}$ coordinatewise recovers $u$.

### 6.2. Exact rational valuation

For a nonzero rational $q=a/b$ in lowest terms, repeatedly divide the numerator by $p$ while possible and increase a counter; repeatedly divide the denominator by $p$ while possible and decrease the counter. The final counter is $v_p(q)$. With ordinary integer arithmetic, the number of divisions is $O(\log_p|a|+\log_p|b|)$ in the worst case, while bit complexity depends on the integer division model.

This routine gives exact membership tests for $C_{p,k}(x)$: equality succeeds immediately; otherwise compute $v_p(x-y)$ and compare it with $k$.

### 6.3. Finite cluster hierarchy construction

For a finite sample $S\subset\mathbb{Q}$ and thresholds $k_1<\cdots<k_r$, define a relation at level $k_i$ by

$$
x\sim_{k_i}y
\quad\Longleftrightarrow\quad
x=y\text{ or }k_i\le v_p(x-y).
$$

Theorem 5.1 ensures transitivity, so this is an equivalence relation. Compute connected components using pairwise tests or union-find. Threshold antitonicity ensures that the partition at $k_{i+1}$ refines the partition at $k_i$. A straightforward pairwise implementation takes $O(r|S|^2)$ valuation tests; union-find adds near-constant amortized overhead per successful union. The output is a dendrogram with no partial overlaps.

## 7. Applications and interpretation

### 7.1. Presentation invariance

Coordinate systems are rarely canonical. Symbols may be renamed, states may be re-encoded, and branch labels may be transported between homeomorphic parameter spaces. Theorem 3.2 guarantees that such presentation changes do not alter the topology of the infinite path space. Because cylinders are transported exactly, finite-resolution queries retain their meaning after relabelling.

### 7.2. Arithmetic boundaries

Prime-adic clusters naturally form vertices of a refinement system. A chain

$$
C_{p,k_0}(x)\supseteq C_{p,k_1}(x)\supseteq C_{p,k_2}(x)\supseteq\cdots,
\qquad k_0<k_1<k_2<\cdots,
$$

records successively finer arithmetic information. Center-independence means the cluster itself, rather than a chosen representative, is the intrinsic object. This removes arbitrary choices when clusters are treated as tree vertices.

### 7.3. Hierarchical data analysis

Laminar clusters are computationally attractive. A sample point may be represented by the chain of clusters containing it. Equal-threshold clusters form partitions, and later partitions refine earlier ones. Unlike general metric clustering, no two clusters at one level overlap partially. This supports exact dendrograms and deterministic multiscale indexing.

### 7.4. Relation to end spaces

A rooted tree has an end-like boundary formed by infinite compatible choices of descendants. The cluster hierarchy supplies such descendants arithmetically. The present results establish the local laws needed for that analogy: transitivity gives well-defined blocks, center-independence removes dependence on representatives, and antitonicity gives refinement. Constructing a canonical graph or proving a full boundary homeomorphism requires additional work concerning completeness, cofinal thresholds, and the realization of coherent chains.

## 8. Discussion and limitations

The central unity is an inverse-system viewpoint. At level $n$, a ray supplies a prefix. At threshold $k$, a rational point supplies a cluster. Forgetful or coarsening maps connect levels. An infinite object is represented by compatible finite-resolution data.

The relabelling result is exact but rigid. It requires one homeomorphism $e$ applied at every coordinate, independent of depth and history. It does not classify trees related by variable levelwise bijections, cofinal pruning, or general transformations preserving eventual branching.

The valuation results are local and rational. They do not alone prove that every coherent descending chain of clusters has a rational point in its intersection. Such a statement is generally tied to completeness and may require passage to a completion. Nor do these results by themselves characterize all graph end spaces, edge-end spaces, or completely ultrametrizable spaces.

These limitations clarify rather than diminish the conclusions. The established theorems provide explicit building blocks for broader classification: a direct homeomorphism in the uniform relabelling regime and the exact laminar laws required to turn ultrametric balls into a tree.

## 9. Future work

A natural first extension replaces the global alphabet homeomorphism with coherent bijections on finite tree levels. Such maps should preserve extension and commute with truncation. The main question is whether these compatibility conditions suffice to define mutually inverse continuous maps on rays.

A second direction constructs a ray presentation for a complete ultrametric space using nonempty balls at a countable cofinal family of radii. Laminarity creates the tree, while completeness should identify coherent descending chains with points.

A third direction seeks graph realizations of completed prime-adic cluster boundaries. Clusters would serve as vertices, refinement as edges, and infinite strictly nested chains as ends.

Further questions concern invariance under cofinal pruning and generalized ray presentations for spaces with asymmetric or nonmetrizable local bases. The proved results suggest that the decisive datum is not literal depth but compatible finite separation.

## 10. Conclusion

A coordinate tree packages admissible finite histories, and its ray space packages all compatible infinite continuations. Homeomorphic coordinate relabelling preserves every finite-history relation and therefore yields an explicit homeomorphism of ray spaces. Prime-adic threshold clusters supply a second, arithmetic hierarchy: the strong triangle law gives transitivity, thresholds give antitonic refinement, and membership makes centers interchangeable. The resulting clusters form partitions at fixed scales and a laminar family across scales.

Both theories demonstrate the same organizing principle. Infinite boundaries can be understood through compatible finite observations. When those observations are preserved, topology is preserved; when they obey a strong non-Archimedean law, they organize themselves into a tree.