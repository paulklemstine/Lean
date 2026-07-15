# Graph Realizations of Closure Orders, Bruhat Symmetry, and a Clique-Shadow Bridge

**Aristotle**  
**15 July 2026**

## Abstract

We develop a general mechanism for representing an ordered parameter space inside a componentwise product without altering its closure structure. Let $(X,\preccurlyeq)$ be a relational space and let $\iota:X\to X$ preserve and reflect the relation. The graph map $\Gamma(x)=(x,\iota(x))$ is injective, realizes $\preccurlyeq$ exactly as the restriction of the product relation, identifies principal lower sets with product-principal lower sets supported on $\Gamma(X)$, and transports arbitrary lower sets exactly. For preorders, inclusion among graph-supported principal closures is equivalent to componentwise comparison.

We then specialize the mechanism to the Bruhat order on permutations, defined by the Ehresmann rank criterion. We prove that rank matrices determine permutations, identify the identity and reversal as the minimum and maximum, and use the transpose identity $r_{w^{-1}}(i,j)=r_w(j,i)$ to establish inversion invariance. Consequently, $w\mapsto(w,w^{-1})$ preserves and reflects Bruhat order and all associated principal closures. This supplies the order-theoretic core of closure comparison in two-projection parametrizations of orbit strata.

Finally, we present a complementary shadow principle in extremal graph theory. The two-element shadow of the triangle family of a graph is contained in its edge family. The Kruskal–Katona theorem therefore implies that a graph on $n$ vertices with at least $\binom{k}{3}$ triangles, for $3\le k\le n$, has at least $\binom{k}{2}$ edges. Algorithms and numerical examples make both correspondences explicit.

## 1. Introduction

Stratified spaces are often studied through a finite set of labels equipped with a degeneration relation. If a stratum indexed by $x$ lies in the closure of a stratum indexed by $y$, one writes $x\preccurlyeq y$. In settings arising from flag varieties, permutations serve as labels and Bruhat order governs the expected degeneration pattern. Products of geometric spaces naturally supply multiple projections, so an orbit may be represented by a pair of Weyl-group elements. The central question is then whether geometric closure comparison agrees with componentwise Bruhat comparison on the image of the parametrization.

The order-theoretic issue can be isolated from geometry. A label $x$ is sent to two compatible coordinates, here represented by $x$ and $\iota(x)$. If $\iota$ preserves and reflects the relation, the graph of $\iota$ is an exact copy of the original ordered space inside the product. This pointwise statement has stronger set-level consequences: principal closures pull back exactly, their intersections with the graph are precisely graph images of original closures, and arbitrary lower sets correspond.

For permutations, the relevant transformation is inversion. Its compatibility with Bruhat order follows transparently from rank matrices: inversion transposes the matrix. Thus the map $w\mapsto(w,w^{-1})$ realizes Bruhat order as the restriction of product Bruhat order. In applications to orbit closures, this is the complete combinatorial component; a geometric application additionally requires identification of the orbit closure relation with the original Bruhat lower sets.

A second result illustrates the reach of “shadow” methods in another domain. Triangles of a graph form a family of $3$-element sets. Their lower shadow consists of $2$-element sets, all of which are graph edges. A sharp lower bound on shadows therefore becomes a sharp triangle-to-edge inequality. Although this theorem is logically independent of the Bruhat application, both developments are governed by the same methodological theme: move to a representation where containment and order become componentwise or set-theoretic, then pull the conclusion back.

The paper is organized as follows. Section 2 develops the abstract graph realization. Section 3 reviews Bruhat order through rank matrices. Section 4 specializes the graph results to inversion. Section 5 derives the triangle-edge inequality. Section 6 gives algorithms and examples, and Sections 7–9 discuss applications, limitations, and future directions.

## 2. Relational graph realizations

### 2.1. Definitions

Let $X$ and $Y$ be sets, with relations $\preccurlyeq_X$ on $X$ and $\preccurlyeq_Y$ on $Y$. The **componentwise product relation** on $X\times Y$ is defined by

$$
(x_1,y_1)\preccurlyeq_{\times}(x_2,y_2)
\quad\Longleftrightarrow\quad
x_1\preccurlyeq_X x_2\text{ and }y_1\preccurlyeq_Y y_2.
$$

For a self-map $\iota:X\to X$, define its **graph parametrization** by

$$
\Gamma:X\longrightarrow X\times X,
\qquad
\Gamma(x)=(x,\iota(x)).
$$

For any relation $\preccurlyeq$ on $X$ and any $x\in X$, define the **principal closure**

$$
\downarrow x=\{y\in X:y\preccurlyeq x\}.
$$

This terminology is order-theoretic. When labels index geometric strata and the relation models degeneration, $\downarrow x$ is the set of strata occurring in the closure of the stratum labeled by $x$.

A subset $S\subseteq X$ is a **lower set** if

$$
y\in S\text{ and }x\preccurlyeq y\quad\Longrightarrow\quad x\in S.
$$

When $\preccurlyeq$ is reflexive and transitive, it is a preorder. Antisymmetry upgrades it to a partial order.

### 2.2. Exact realization in a product

We first require only that $\iota$ preserve and reflect the relation.

**Theorem 2.1 (Graph realization theorem).**  
Let $X$ carry a relation $\preccurlyeq$, and suppose $\iota:X\to X$ satisfies

$$
\iota(x)\preccurlyeq\iota(y)
\quad\Longleftrightarrow\quad
x\preccurlyeq y
$$

for all $x,y\in X$. Then

$$
\Gamma(x)\preccurlyeq_{\times}\Gamma(y)
\quad\Longleftrightarrow\quad
x\preccurlyeq y.
$$

**Proof sketch.** By definition, the left side is the conjunction of $x\preccurlyeq y$ and $\iota(x)\preccurlyeq\iota(y)$. The assumed equivalence makes the second conjunct equivalent to the first, so the conjunction is equivalent to $x\preccurlyeq y$. $\square$

**Lemma 2.2 (Injectivity).**  
For every map $\iota:X\to X$, the graph parametrization $\Gamma(x)=(x,\iota(x))$ is injective.

**Proof sketch.** Equality $\Gamma(x)=\Gamma(y)$ implies equality of first coordinates, hence $x=y$. No injectivity assumption on $\iota$ is needed. $\square$

The first coordinate therefore prevents information loss, while compatibility of the second coordinate prevents distortion of order.

### 2.3. Principal closures

**Lemma 2.3 (Principal-closure inclusion).**  
If $\preccurlyeq$ is reflexive and transitive, then for all $x,y\in X$,

$$
\downarrow x\subseteq\downarrow y
\quad\Longleftrightarrow\quad
x\preccurlyeq y.
$$

**Proof sketch.** If $\downarrow x\subseteq\downarrow y$, reflexivity gives $x\in\downarrow x$, so $x\in\downarrow y$, which means $x\preccurlyeq y$. Conversely, if $x\preccurlyeq y$ and $z\in\downarrow x$, then $z\preccurlyeq x$; transitivity yields $z\preccurlyeq y$, so $z\in\downarrow y$. $\square$

Let $\downarrow_{\times}\Gamma(x)$ denote the principal closure in the product relation.

**Theorem 2.4 (Exact pullback of principal closures).**  
Under the hypotheses of Theorem 2.1,

$$
\Gamma^{-1}(\downarrow_{\times}\Gamma(x))=\downarrow x
$$

for every $x\in X$.

**Proof sketch.** An element $y$ lies in the left side exactly when $\Gamma(y)\preccurlyeq_{\times}\Gamma(x)$. Theorem 2.1 makes this equivalent to $y\preccurlyeq x$, which is membership in $\downarrow x$. $\square$

**Theorem 2.5 (Graph-supported closure identity).**  
Under the same hypotheses,

$$
\downarrow_{\times}\Gamma(x)\cap\Gamma(X)=\Gamma(\downarrow x).
$$

**Proof sketch.** If a point in the intersection has the form $\Gamma(y)$, product comparison with $\Gamma(x)$ is equivalent to $y\preccurlyeq x$, so it lies in $\Gamma(\downarrow x)$. The reverse inclusion follows by the same equivalence. $\square$

The intersection with $\Gamma(X)$ is essential. The ambient product-principal closure may contain unrelated pairs $(a,b)$ that do not equal $(y,\iota(y))$ for any $y$.

**Theorem 2.6 (Closure inclusion on the graph).**  
If $\preccurlyeq$ is reflexive and transitive, then for any self-map $\iota:X\to X$ and all $x,y\in X$,

$$
\bigl(\downarrow_{\times}\Gamma(x)\cap\Gamma(X)\bigr)
\subseteq
\bigl(\downarrow_{\times}\Gamma(y)\cap\Gamma(X)\bigr)
$$

if and only if

$$
\Gamma(x)\preccurlyeq_{\times}\Gamma(y).
$$

**Proof sketch.** For the forward implication, $\Gamma(x)$ belongs to its own graph-supported principal closure by reflexivity; inclusion places it in the closure below $\Gamma(y)$. For the reverse implication, let a graph point lie below $\Gamma(x)$. Coordinatewise transitivity with $\Gamma(x)\preccurlyeq_{\times}\Gamma(y)$ places that point below $\Gamma(y)$. $\square$

Notably, this theorem needs no order compatibility of $\iota$: it is a preorder fact internal to the graph-supported product closures.

### 2.4. Arbitrary lower sets

**Theorem 2.7 (Lower-set correspondence).**  
Under the hypotheses of Theorem 2.1, a subset $S\subseteq X$ is lower under $\preccurlyeq$ if and only if $\Gamma(S)$ is lower within $\Gamma(X)$ under the componentwise product relation. Explicitly, the latter means that whenever $p,q\in\Gamma(X)$, $p\preccurlyeq_{\times}q$, and $q\in\Gamma(S)$, then $p\in\Gamma(S)$.

**Proof sketch.** Write $p=\Gamma(x)$ and $q=\Gamma(y)$. Injectivity makes $q\in\Gamma(S)$ equivalent to $y\in S$, while Theorem 2.1 makes $p\preccurlyeq_{\times}q$ equivalent to $x\preccurlyeq y$. Thus the graph condition is exactly the definition that $S$ is lower. $\square$

This result extends the principal-closure theorem to arbitrary unions and intersections of degeneration-stable strata.

## 3. Bruhat order through rank matrices

Let $S_n$ be the symmetric group on $\{0,1,\ldots,n-1\}$. For $w\in S_n$ and indices $0\le i,j<n$, define the **Ehresmann rank count**

$$
r_w(i,j)=\#\{k:0\le k\le i\text{ and }w(k)\le j\}.
$$

Equivalently, place a $1$ in row $k$, column $w(k)$ of an $n\times n$ permutation matrix. Then $r_w(i,j)$ counts the $1$ entries in the northwest rectangle with southeast corner $(i,j)$.

**Definition 3.1 (Bruhat order).**  
For $u,v\in S_n$, write $u\le_B v$ if

$$
r_v(i,j)\le r_u(i,j)
$$

for every $i,j$. On $S_n\times S_n$, define product Bruhat order by

$$
(a,b)\le_{B\times B}(c,d)
\quad\Longleftrightarrow\quad
a\le_B c\text{ and }b\le_B d.
$$

Reflexivity and transitivity follow immediately from equality and transitivity of integer inequalities. Antisymmetry requires the fact that ranks determine the permutation.

**Theorem 3.2 (Rank determination and antisymmetry).**  
If $u\le_B v$ and $v\le_B u$, then $u=v$. Hence Bruhat order is a partial order.

**Proof sketch.** The two comparisons imply $r_u(i,j)=r_v(i,j)$ for all $i,j$. The difference between the count through row $i$ and the count through row $i-1$ is the indicator of the event $w(i)\le j$. Thus the common rank matrix determines, for every $i,j$, whether $u(i)\le j$ and whether $v(i)\le j$. These threshold predicates agree for every $j$, forcing $u(i)=v(i)$ for every $i$. $\square$

**Theorem 3.3 (Extremal permutations).**  
The identity permutation is the minimum of $(S_n,\le_B)$, and the reversal permutation $w_0(i)=n-1-i$ is the maximum.

**Proof sketch.** For the identity, the northwest rectangle contains exactly $\min(i,j)+1$ diagonal entries. Any permutation contributes at most $i+1$ entries because the rectangle has that many rows, and at most $j+1$ entries because permutation values are distinct; therefore its count is at most $\min(i,j)+1$. This gives $\mathrm{id}\le_B w$ for every $w$.

For reversal,

$$
r_{w_0}(i,j)=\max(0,i+j+2-n).
$$

For any permutation $w$, consider the $i+1$ positions at most $i$ and the $j+1$ positions whose images are at most $j$. Both are subsets of an $n$-element set, so their intersection has size at least $(i+1)+(j+1)-n$, truncated below by zero. That intersection is counted by $r_w(i,j)$. Hence $r_{w_0}(i,j)\le r_w(i,j)$, which means $w\le_B w_0$. $\square$

Define the inversion set and length by

$$
\operatorname{Inv}(w)=\{(i,j):i<j\text{ and }w(j)<w(i)\},
\qquad
\ell(w)=|\operatorname{Inv}(w)|.
$$

**Lemma 3.4 (Zero length).**  
A permutation satisfies $\ell(w)=0$ if and only if $w$ is the identity.

**Proof sketch.** Zero inversions make $w$ strictly increasing. The only strictly increasing bijection of a finite chain to itself is the identity. The converse is immediate. $\square$

**Corollary 3.5 (Length characterization of the minimum).**  
A permutation lies below every element of $S_n$ in Bruhat order if and only if its inversion length is zero.

**Proof sketch.** If $w$ lies below every permutation, it lies below the identity. Since the identity lies below $w$, antisymmetry gives $w=\mathrm{id}$ and hence $\ell(w)=0$. Conversely, zero length gives the identity, which is the minimum. $\square$

## 4. Inversion and the two-projection closure law

**Lemma 4.1 (Transpose identity).**  
For every $w\in S_n$,

$$
r_{w^{-1}}(i,j)=r_w(j,i).
$$

**Proof sketch.** The left side counts values $k\le i$ whose preimages satisfy $w^{-1}(k)\le j$. Sending $k$ to $w^{-1}(k)$ bijects this set with the positions $a\le j$ for which $w(a)\le i$, counted by the right side. In permutation-matrix language, inversion transposes the matrix and therefore transposes every northwest rank count. $\square$

**Theorem 4.2 (Inversion invariance).**  
For all $u,v\in S_n$,

$$
u\le_B v
\quad\Longleftrightarrow\quad
u^{-1}\le_B v^{-1}.
$$

**Proof sketch.** Apply the defining rank inequalities after exchanging $i$ and $j$, then use Lemma 4.1. The reverse implication follows identically because inversion is an involution. $\square$

Define

$$
\Phi:S_n\longrightarrow S_n\times S_n,
\qquad
\Phi(w)=(w,w^{-1}).
$$

**Theorem 4.3 (Two-projection Bruhat embedding).**  
The map $\Phi$ is injective and, for all $u,v\in S_n$,

$$
u\le_B v
\quad\Longleftrightarrow\quad
\Phi(u)\le_{B\times B}\Phi(v).
$$

**Proof sketch.** Injectivity follows from the first coordinate. Product comparison asks simultaneously for $u\le_B v$ and $u^{-1}\le_B v^{-1}$. By Theorem 4.2 these are equivalent conditions. $\square$

For each $w$, let $C(w)=\{u:u\le_B w\}$ be its principal Bruhat closure, and let $C_\times(\Phi(w))$ be the corresponding product-principal closure.

**Corollary 4.4 (Exact closure correspondence).**  
For every $w\in S_n$,

$$
\Phi^{-1}(C_\times(\Phi(w)))=C(w)
$$

and

$$
C_\times(\Phi(w))\cap\Phi(S_n)=\Phi(C(w)).
$$

Moreover,

$$
C_\times(\Phi(u))\cap\Phi(S_n)
\subseteq
C_\times(\Phi(v))\cap\Phi(S_n)
$$

if and only if $\Phi(u)\le_{B\times B}\Phi(v)$, equivalently $u\le_B v$.

**Proof sketch.** Apply Theorems 2.4–2.6 to Bruhat order and inversion, using Theorem 4.2. $\square$

**Corollary 4.5 (Bruhat lower sets on the image).**  
A subset $S\subseteq S_n$ is Bruhat-lower if and only if $\Phi(S)$ is product-Bruhat-lower relative to $\Phi(S_n)$.

This is the precise order-theoretic content needed for a two-projection parametrization of strata. If a geometric classification identifies strata with $S_n$ and identifies geometric closure with principal Bruhat lower sets, then closure inclusion of strata is equivalent to componentwise Bruhat comparison of their two projection labels. The present result establishes the combinatorial mechanism; it does not by itself supply the geometric identification.

## 5. A Kruskal–Katona bridge from triangles to edges

Let $G=(V,E)$ be a finite simple graph with $|V|=n$. Write $\mathcal{T}(G)$ for its family of triangles, viewed as $3$-element subsets of $V$. For a family $\mathcal{F}$ of $r$-element sets, define its **lower shadow** by

$$
\partial\mathcal{F}
=
\{A:|A|=r-1\text{ and }A\subset B\text{ for some }B\in\mathcal{F}\}.
$$

**Lemma 5.1 (Triangle shadow lies in the edge set).**  
For every finite simple graph,

$$
\partial\mathcal{T}(G)\subseteq E.
$$

Here an edge is identified with its two-element endpoint set.

**Proof sketch.** A member of $\partial\mathcal{T}(G)$ is obtained by deleting one vertex from a triangle. The two remaining vertices were adjacent in the triangle, so their pair is an edge. $\square$

We use the following $3$-uniform consequence of the Kruskal–Katona theorem.

**Theorem 5.2 (Uniform shadow bound).**  
Let $\mathcal{F}$ be a family of $3$-element subsets of an $n$-element set. If $3\le k\le n$ and

$$
|\mathcal{F}|\ge\binom{k}{3},
$$

then

$$
|\partial\mathcal{F}|\ge\binom{k}{2}.
$$

**Proof sketch.** Kruskal–Katona states that among uniform families of a fixed size, initial segments in colexicographic order minimize the lower shadow. At the binomial threshold $\binom{k}{3}$, the extremal family is all triples from a fixed $k$-element set, whose shadow is all pairs from that set and has size $\binom{k}{2}$. Adding triples cannot decrease the shadow. $\square$

**Theorem 5.3 (Triangle-edge inequality).**  
Let $G$ be a simple graph on $n$ vertices. If $3\le k\le n$ and $G$ has at least $\binom{k}{3}$ triangles, then $G$ has at least $\binom{k}{2}$ edges.

**Proof sketch.** Apply Theorem 5.2 to the $3$-uniform family $\mathcal{T}(G)$. It yields $|\partial\mathcal{T}(G)|\ge\binom{k}{2}$. Lemma 5.1 places the shadow inside $E$, so

$$
\binom{k}{2}
\le |\partial\mathcal{T}(G)|
\le |E|.
$$

Thus $|E|\ge\binom{k}{2}$. $\square$

The theorem is sharp: a complete graph on $k$ vertices with $n-k$ isolated vertices has exactly $\binom{k}{3}$ triangles and $\binom{k}{2}$ edges.

## 6. Algorithms and numerical illustrations

### 6.1. Rank-matrix comparison

A direct Bruhat comparison algorithm constructs $r_u$ and $r_v$ and checks $r_v(i,j)\le r_u(i,j)$ for all $i,j$. A naive count for each cell scans up to $n$ positions, giving $O(n^3)$ time and $O(n^2)$ storage. A prefix method first places the permutation matrix and then computes two-dimensional cumulative sums, reducing construction to $O(n^2)$ time.

For $w=[2,0,3,1]$, the inverse is $w^{-1}=[1,3,0,2]$. Computing both rank matrices shows cell by cell that the latter is the transpose of the former. Exhaustive enumeration for small $n$ then confirms that comparison of $u$ and $v$ agrees with componentwise comparison of $(u,u^{-1})$ and $(v,v^{-1})$.

### 6.2. Principal closures

For finite $X$, compute $\downarrow x$ by scanning all $y\in X$ and retaining those satisfying $y\preccurlyeq x$. Then compute the graph-supported product closure by scanning all $y$ and testing whether both $y\preccurlyeq x$ and $\iota(y)\preccurlyeq\iota(x)$. Theorem 2.4 predicts identical retained labels. With permutations, one may enumerate $S_n$ for modest $n$ and use rank comparisons.

### 6.3. Triangle shadows

Given an adjacency matrix, enumerate triples $a<b<c$ and record those for which all three adjacencies hold. For every triangle, insert its three two-element subsets into a set. This computes the shadow in $O(n^3)$ time, with set operations contributing expected constant time. Every recorded pair can then be checked against the edge set. For the complete graph $K_6$, the counts are

$$
|\mathcal{T}(K_6)|=\binom{6}{3}=20,
\qquad
|\partial\mathcal{T}(K_6)|=|E(K_6)|=\binom{6}{2}=15.
$$

For $K_5$ plus isolated vertices, the corresponding counts are $10$ triangles and $10$ edges, again attaining equality at $k=5$.

## 7. Applications

The graph realization theorem applies whenever a classification naturally supplies a label and a compatible transformed label. In orbit theory, two projections from a product of flag spaces can produce a pair of Weyl-group elements. If the image has graph form and the second coordinate is an order automorphism such as inversion, componentwise comparison is exact on the image.

The lower-set theorem is useful for unions of strata. Closed or degeneration-stable unions correspond to lower subsets of the indexing poset. Rather than verifying stability separately in two coordinates, one can transfer it through the graph embedding. In computational classification, this also supplies a data-integrity test: any proposed closure table must agree with product order after restriction to the parametrization image.

The triangle-edge inequality has applications in network analysis. Triangles represent transitive triples, clustered interactions, or three-way compatibility. The theorem gives a universal edge floor at binomial thresholds. It is especially informative for concentrated structures: complete subgraphs attain equality and therefore explain the extremal configuration.

## 8. Discussion and limitations

The abstract graph theorems deliberately separate order theory from geometry. They establish that compatible coordinates preserve a specified relation and its lower sets. To conclude a statement about Zariski closures of actual Borel orbits, one must additionally construct the orbit parametrization and prove that the geometric closure relation is the Bruhat relation used here. Without that bridge, the conclusions concern the combinatorial labels rather than the topology of a particular variety.

The map $w\mapsto(w,w^{-1})$ uses the first coordinate to guarantee injectivity. More general parametrizations may involve two different target posets and neither coordinate alone may be injective. The correct hypothesis is then that the combined map is injective and jointly preserves and reflects order.

The triangle-edge result is a threshold theorem. It does not state the optimal edge lower bound for every possible triangle count in a closed elementary formula. The full Kruskal–Katona binomial representation gives finer piecewise information. Nor does the theorem assert that all near-equality graphs are close to a clique plus isolated vertices; such stability questions require additional arguments.

## 9. Future work

Four directions arise naturally.

1. Instantiate the graph-supported closure theorems directly with the Ehresmann rank definition of Bruhat order on permutations and permutation inversion in a unified treatment.
2. Connect principal lower sets to the Zariski closures of actual Borel orbits after introducing the required algebraic-group and flag-variety geometry.
3. Generalize the graph construction to parametrizations with two distinct order-reflecting coordinate maps into different Weyl groups.
4. Show that the lower-set correspondence is an order isomorphism between the lattice of Bruhat lower sets and the lattice of product-order lower subsets supported on the parametrization image.

For extremal graphs, natural extensions replace triangles by $r$-cliques: the $(r-1)$-shadow of the $r$-clique family lies in the family of $(r-1)$-cliques. Kruskal–Katona then yields a hierarchy of clique-count inequalities. Stability, weighted variants, and hypergraph analogues offer further directions.

## 10. Conclusion

A relation-preserving and relation-reflecting transformation turns its graph into an exact ordered copy of the original space inside a product. This elementary observation controls principal closures, closure inclusion, and all lower sets. Bruhat inversion supplies a concrete and geometrically relevant instance because permutation inversion transposes Ehresmann rank matrices. The resulting two-projection map preserves and reflects Bruhat order exactly.

The graph-theoretic shadow theorem provides a parallel lesson: the shadow of every triangle is an edge, and a sharp uniform-family bound converts triangle abundance into an edge lower bound. In both settings, the decisive step is to choose a representation in which a complicated structural question becomes a transparent statement about product comparison or set containment.