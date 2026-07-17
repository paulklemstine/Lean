# Reticulations, Cooperative Systems, and Rectangular Latin Structures

**Aristotle**  
**17 July 2026**

## Abstract

We develop a finite coordinate theory unifying two-type incidence structures, rectangular Latin conditions, orthogonal matrix pairs, and balanced arrays. A reticulation consists of a finite point set equipped with two classes of coordinate families such that every coordinate map chosen from opposite classes jointly labels the points bijectively. A cooperative system consists of column-Latin matrices and row-Latin matrices, every cross-type pair being orthogonal. A svelte semi-orthogonal array records the same cross-coordinate condition row by row. We prove the unique-position and unique-intersection properties, characterize column- and row-Latin matrices by orthogonality to the canonical coordinate matrices, construct reticulations and svelte arrays from cooperative systems, and construct reticulations from svelte arrays. The central counting consequence is that every nonempty two-sided finite reticulation has exactly $mn$ points, and every corresponding svelte array has exactly $mn$ rows. We also give direct validation and conversion algorithms, analyze their complexity, and discuss applications to balanced experimental design, combinatorial data representations, and cross-view indexing.

## 1. Introduction

Classical nets, orthogonal arrays, and mutually orthogonal Latin squares all encode a common phenomenon: independently meaningful partitions of a finite set interact with exact regularity. The usual square case can obscure two useful freedoms. First, the two sides may have different alphabet sizes $m$ and $n$. Second, compatibility may be required only across two types of families, rather than between every pair of families.

The resulting asymmetric theory has three natural presentations.

1. In the **incidence presentation**, points lie on fibres called lines. Lines come in weft and warp families, and opposite-type lines intersect uniquely.
2. In the **matrix presentation**, an $m$-symbol matrix is Latin down columns, an $n$-symbol matrix is Latin across rows, and opposite-type matrices are orthogonal.
3. In the **array presentation**, rows carry several left and right coordinates, and every projection onto one left and one right coordinate is a complete rectangular grid.

The principal aim of this paper is to establish the finite coordinate core connecting these presentations. The coordinate viewpoint avoids unnecessary set-partition bookkeeping while retaining the incidence content: the fibres of a coordinate map are precisely the lines, and a family of fibres automatically partitions the point set.

The basic hypothesis is bijectivity. For a weft coordinate $w_u:P\to [m]$ and a warp coordinate $z_v:P\to[n]$, the combined map

$$
p\longmapsto (w_u(p),z_v(p))
$$

is required to be a bijection for every $u$ and $v$. Here $[k]=\{0,1,\ldots,k-1\}$. This single condition simultaneously gives unique intersections, a grid representation, and the cardinality $|P|=mn$.

The same condition appears in the matrix model. If $C:[m]\times[n]\to[m]$ and $R:[m]\times[n]\to[n]$, orthogonality means that

$$
(i,j)\longmapsto(C(i,j),R(i,j))
$$

is bijective. The fibres of $C$ and $R$ are opposite-type lines. When entire collections of such matrices are cross-orthogonal, every selected pair supplies a coordinate chart on the common grid.

The paper proceeds from definitions through structural theorems, algorithms, and applications. All finiteness and nonemptiness assumptions required for counting are stated explicitly.

## 2. Basic notation and definitions

For a positive integer $k$, write $[k]=\{0,1,\ldots,k-1\}$. For positive integers $m$ and $n$, define the rectangular grid

$$
G_{m,n}=[m]\times[n].
$$

An $a$-symbol matrix of shape $m\times n$ is simply a function

$$
M:G_{m,n}\to[a].
$$

The functional notation is convenient because no algebraic operations on entries are assumed.

### Definition 2.1 (Column-Latin matrix)

A matrix $C:G_{m,n}\to[m]$ is **column-Latin** if, for every $j\in[n]$, the map

$$
[m]\to[m],\qquad i\longmapsto C(i,j)
$$

is bijective. Equivalently, every symbol in $[m]$ occurs exactly once in every column.

### Definition 2.2 (Row-Latin matrix)

A matrix $R:G_{m,n}\to[n]$ is **row-Latin** if, for every $i\in[m]$, the map

$$
[n]\to[n],\qquad j\longmapsto R(i,j)
$$

is bijective. Equivalently, every symbol in $[n]$ occurs exactly once in every row.

### Definition 2.3 (Orthogonality)

A matrix $C:G_{m,n}\to[m]$ and a matrix $R:G_{m,n}\to[n]$ are **orthogonal** if the combined labeling

$$
\Phi_{C,R}:G_{m,n}\to[m]\times[n],\qquad
\Phi_{C,R}(p)=(C(p),R(p))
$$

is bijective. Hence every ordered pair $(q,r)\in[m]\times[n]$ occurs at exactly one grid position.

### Definition 2.4 (Cooperative pair and cooperative system)

A **cooperative pair** of parameters $(m,n)$ is a pair $(C,R)$ in which $C$ is column-Latin, $R$ is row-Latin, and $C$ is orthogonal to $R$.

More generally, let $U$ and $V$ be index sets. A **cooperative system** consists of matrices

$$
C_u:G_{m,n}\to[m]\quad(u\in U),
\qquad
R_v:G_{m,n}\to[n]\quad(v\in V),
$$

such that every $C_u$ is column-Latin, every $R_v$ is row-Latin, and $C_u$ is orthogonal to $R_v$ for every $(u,v)\in U\times V$. No same-type orthogonality is required.

### Definition 2.5 (Coordinate reticulation)

Let $P$ be a finite set and let $U,V$ be index sets. A **coordinate reticulation** with parameters $(m,n)$ consists of maps

$$
w_u:P\to[m]\quad(u\in U),
\qquad
z_v:P\to[n]\quad(v\in V),
$$

such that for every $u\in U$ and $v\in V$, the cross-coordinate map

$$
\Psi_{u,v}:P\to[m]\times[n],\qquad
\Psi_{u,v}(p)=(w_u(p),z_v(p))
$$

is bijective.

For fixed $u$ and $q$, the fibre $w_u^{-1}(q)$ is a weft line. For fixed $v$ and $r$, the fibre $z_v^{-1}(r)$ is a warp line. For each fixed coordinate family, its fibres are disjoint and cover $P$, so they form a partition automatically.

### Definition 2.6 (Svelte semi-orthogonal array)

A **svelte semi-orthogonal array** with parameters $(m,n)$ and coordinate index sets $(U,V)$ consists of a finite row set $Y$ and entries

$$
L:Y\times U\to[m],
\qquad
T:Y\times V\to[n],
$$

such that for every $u\in U$ and $v\in V$, the projection

$$
y\longmapsto(L(y,u),T(y,v))
$$

is a bijection from $Y$ to $[m]\times[n]$.

The adjective “svelte” reflects the index-one property: each cross-type ordered pair occurs exactly once, not merely a fixed larger number of times.

## 3. Local regularity and unique intersections

We first extract the exact uniqueness statements implicit in the definitions.

### Theorem 3.1 (Unique symbol position in a column)

Let $C:G_{m,n}\to[m]$ be column-Latin. For every $j\in[n]$ and $q\in[m]$, there exists a unique $i\in[m]$ such that

$$
C(i,j)=q.
$$

**Proof sketch.** For fixed $j$, column-Latinness says that $i\mapsto C(i,j)$ is a bijection of $[m]$. Surjectivity supplies a preimage of $q$, and injectivity makes that preimage unique. $\square$

### Theorem 3.2 (Unique symbol position in a row)

Let $R:G_{m,n}\to[n]$ be row-Latin. For every $i\in[m]$ and $r\in[n]$, there exists a unique $j\in[n]$ such that

$$
R(i,j)=r.
$$

**Proof sketch.** Fix $i$ and apply surjectivity and injectivity of the row permutation $j\mapsto R(i,j)$. $\square$

These statements show that every fibre of a column-Latin matrix meets every geometric column exactly once, while every fibre of a row-Latin matrix meets every geometric row exactly once.

### Theorem 3.3 (Unique cross-intersection in a cooperative pair)

Let $(C,R)$ be a cooperative pair. For every $q\in[m]$ and $r\in[n]$, there exists a unique point $p\in G_{m,n}$ such that

$$
C(p)=q
\qquad\text{and}\qquad
R(p)=r.
$$

**Proof sketch.** Orthogonality states that $p\mapsto(C(p),R(p))$ is bijective. The ordered pair $(q,r)$ therefore has exactly one preimage. $\square$

In incidence language, the fibre $C^{-1}(q)$ and the fibre $R^{-1}(r)$ meet in exactly one point. This is the fundamental reticulation rule.

## 4. Canonical coordinate matrices

Define the horizontal and vertical coordinate matrices by

$$
H(i,j)=i,
\qquad
V(i,j)=j.
$$

The pair $(H,V)$ is the basic cooperative pair: $H$ is column-Latin, $V$ is row-Latin, and the combined map $(i,j)\mapsto(H(i,j),V(i,j))$ is the identity on $G_{m,n}$.

The coordinate matrices do more than provide an example. They characterize the one-sided Latin conditions.

### Theorem 4.1 (Column-coordinate characterization)

For a matrix $C:G_{m,n}\to[m]$, the following are equivalent:

1. $C$ is column-Latin.
2. $C$ is orthogonal to the vertical coordinate matrix $V$.

**Proof sketch.** Suppose $C$ is column-Latin. To recover a grid point from $(q,j)$, use Theorem 3.1 to find the unique $i$ satisfying $C(i,j)=q$; then $(i,j)$ is the unique preimage of $(q,j)$ under $p\mapsto(C(p),V(p))$. Hence that map is bijective.

Conversely, assume $p\mapsto(C(p),V(p))$ is bijective. Fix $j$. If $C(i,j)=C(i',j)$, then the two positions have equal $C$-values and equal $V$-values, so global injectivity gives $i=i'$. Given $q$, global surjectivity supplies a point mapped to $(q,j)$; its second coordinate must be $j$, giving a row $i$ with $C(i,j)=q$. Thus the $j$th column map is bijective. $\square$

### Theorem 4.2 (Row-coordinate characterization)

For a matrix $R:G_{m,n}\to[n]$, the following are equivalent:

1. $R$ is row-Latin.
2. The horizontal coordinate matrix $H$ is orthogonal to $R$.

**Proof sketch.** This is the row-column dual of Theorem 4.1. Pairing $R(i,j)$ with $H(i,j)=i$ records a row and a symbol. Global bijectivity is equivalent to each symbol occurring exactly once in each fixed row. $\square$

These equivalences replace $n$ separate bijectivity conditions for $C$, or $m$ separate conditions for $R$, by one global orthogonality condition. They also show that the elementary coordinate pair is a neutral reference frame for the theory.

## 5. From cooperative systems to reticulations

Let

$$
\mathcal{S}=\bigl((C_u)_{u\in U},(R_v)_{v\in V}\bigr)
$$

be a cooperative system on $G_{m,n}$. Take the cells themselves as points. Define weft and warp coordinates by

$$
w_u(p)=C_u(p),
\qquad
z_v(p)=R_v(p).
$$

### Theorem 5.1 (Reticulation induced by a cooperative system)

The preceding coordinates define a reticulation on $G_{m,n}$. For every $u\in U$, $v\in V$, $q\in[m]$, and $r\in[n]$, there exists a unique grid point $p$ satisfying

$$
w_u(p)=q,
\qquad
z_v(p)=r.
$$

**Proof sketch.** For each $(u,v)$, the cross-coordinate map is exactly $p\mapsto(C_u(p),R_v(p))$, which is bijective by the cross-orthogonality requirement. Unique existence follows by taking the unique preimage of $(q,r)$. $\square$

The fibres of each $C_u$ partition the grid into $m$ weft lines, and the fibres of each $R_v$ partition it into $n$ warp lines. Every line from a selected weft family meets every line from a selected warp family exactly once.

## 6. Svelte array encoding

A cooperative system can be serialized row by row. Let the row set be $Y=G_{m,n}$. For $p\in Y$, define

$$
L(p,u)=C_u(p),
\qquad
T(p,v)=R_v(p).
$$

Thus each grid cell contributes one data row containing all its weft labels and all its warp labels.

### Theorem 6.1 (Cooperative-system encoding)

The row encoding of a cooperative system is a svelte semi-orthogonal array. More precisely, for every $u\in U$, $v\in V$, $q\in[m]$, and $r\in[n]$, there exists a unique row $y$ such that

$$
L(y,u)=q,
\qquad
T(y,v)=r.
$$

**Proof sketch.** A row is a grid point. The required projection sends $p$ to $(C_u(p),R_v(p))$, which is bijective by orthogonality. $\square$

The construction preserves the complete cross-coordinate information. Each left-right pair of table columns is a lossless coordinate chart for the row set.

There is also a direct conversion in the opposite direction.

### Theorem 6.2 (Reticulation induced by a svelte array)

Let $(Y,L,T)$ be a svelte semi-orthogonal array. Define $w_u(y)=L(y,u)$ and $z_v(y)=T(y,v)$. Then these maps form a reticulation on $Y$.

**Proof sketch.** The defining axiom of a svelte array states exactly that every map $y\mapsto(w_u(y),z_v(y))$ is bijective. The fibres are therefore line families with unique cross-intersections. $\square$

Theorems 5.1, 6.1, and 6.2 establish the forward coordinate correspondences needed to move freely among grid matrices, incidence fibres, and balanced row arrays. A full structure-level equivalence would additionally normalize arbitrary coordinate choices and prove that the round trips preserve all structure up to the appropriate notion of isomorphism.

## 7. Cardinality consequences

The cross-coordinate bijection determines the size of every finite object in the theory.

### Theorem 7.1 (Reticulation cardinality)

Let $P$ be a finite reticulation with parameters $(m,n)$. If $U$ and $V$ are nonempty, then

$$
|P|=mn.
$$

**Proof sketch.** Choose $u\in U$ and $v\in V$. The map

$$
P\to[m]\times[n],\qquad p\mapsto(w_u(p),z_v(p))
$$

is a bijection. Therefore

$$
|P|=|[m]\times[n]|=|[m]|\,|[n]|=mn.
$$

The assumptions that both coordinate index sets are nonempty are essential to select a cross-coordinate map. $\square$

### Corollary 7.2 (Svelte array row count)

Let $(Y,L,T)$ be a svelte semi-orthogonal array with parameters $(m,n)$. If $U$ and $V$ are nonempty, then

$$
|Y|=mn.
$$

**Proof sketch.** By Theorem 6.2 the array defines a reticulation on its row set. Apply Theorem 7.1. Equivalently, choose one left and one right column; their projection is a bijection from $Y$ to $[m]\times[n]$. $\square$

The count does not depend on the numbers of coordinate families. Additional families provide additional compatible descriptions of the same $mn$ points; they do not add points.

## 8. Algorithms

The definitions lead to simple finite algorithms. Assume matrices are stored as rectangular arrays with constant-time entry access.

### 8.1 Testing the Latin conditions

To test whether $C$ is column-Latin, inspect each column and mark the symbols encountered. Reject an out-of-range symbol or a repetition. Since a column contains $m$ entries from an alphabet of size $m$, absence of repetition implies that every symbol occurs. The total running time is $O(mn)$ and a reusable marker array requires $O(m)$ auxiliary space.

The row-Latin test is dual: inspect every row of $R$, using $O(n)$ auxiliary space and $O(mn)$ time.

### 8.2 Testing orthogonality

To test whether $C$ and $R$ are orthogonal, scan all $mn$ cells and mark the ordered pair $(C(i,j),R(i,j))$. Reject repeated or invalid pairs. There are exactly $mn$ cells and $mn$ possible pairs, so distinctness implies bijectivity. The running time and direct marker storage are both $O(mn)$.

For a cooperative system containing $a=|U|$ column-type matrices and $b=|V|$ row-type matrices, direct validation costs

$$
O\bigl(mn(a+b+ab)\bigr),
$$

because there are $a+b$ local Latin tests and $ab$ cross-orthogonality tests.

### 8.3 Constructing fibres and unique intersections

Given a coordinate map, construct its line family by grouping points according to their labels. For one map this takes $O(mn)$ time. For a cooperative pair, an inverse table indexed by $(q,r)$ can be built in $O(mn)$ time and then answers every unique-intersection query in $O(1)$ time.

### 8.4 Encoding a cooperative system as a svelte array

With $a$ left matrices and $b$ right matrices, produce one output row per grid point and copy its $a+b$ labels. The cost is

$$
O\bigl(mn(a+b)\bigr)
$$

time and output space. Any projection onto one left and one right output column can be checked by the orthogonality algorithm.

### 8.5 Canonical-coordinate diagnostics

Theorems 4.1 and 4.2 give diagnostic shortcuts. Column-Latinness can be tested as orthogonality with $V$, while row-Latinness can be tested as orthogonality with $H$. Although this does not improve asymptotic complexity, it unifies implementations around a single pair-bijection routine and can simplify software interfaces.

## 9. Worked example

Let $m=3$ and $n=4$. Define

$$
C(i,j)=i,
\qquad
R(i,j)=j.
$$

Then each of the four columns of $C$ is $(0,1,2)$, and each of the three rows of $R$ is $(0,1,2,3)$. The combined labels are

$$
(C(i,j),R(i,j))=(i,j),
$$

so all twelve pairs occur once. A fixed value of $C$ selects a horizontal three? No: on a $3$-by-$4$ grid it selects one row containing $4$ points, while a fixed value of $R$ selects one column containing $3$ points. Their intersection is one cell. This distinction illustrates the asymmetric parameters: a weft fibre has $n$ points and a warp fibre has $m$ points.

The corresponding svelte array has twelve rows and two displayed coordinate columns:

$$
(0,0),(0,1),(0,2),(0,3),
(1,0),(1,1),(1,2),(1,3),
(2,0),(2,1),(2,2),(2,3).
$$

Permuting the entries separately within each column of a proposed $C$ preserves column-Latinness; permuting entries separately within each row of a proposed $R$ preserves row-Latinness. However, arbitrary simultaneous choices can destroy orthogonality by repeating a cross-pair. This separates local regularity from global cooperation.

## 10. Applications

### 10.1 Balanced experimental design

Suppose rows represent experimental units, left coordinates represent levels of one class of factors, and right coordinates represent another. The svelte condition guarantees exact pairwise balance across types: for every selected cross-type factor pair, each ordered level pair appears once. This prevents cross-type confounding at index one and gives a transparent sample-size requirement of $mn$.

### 10.2 Cross-view data indexing

In a data system, each $w_u$ and $z_v$ may be viewed as a categorical feature. Cross-bijectivity says that any one feature from each type uniquely identifies a record and that every admissible feature pair is realized. Thus every cross-type pair is simultaneously a candidate key and a completeness certificate.

### 10.3 Representation learning and benchmark construction

When data have two groups of attributes, a cooperative design gives exact combinatorial coverage. Every left-right attribute pair is represented uniformly, avoiding accidental imbalance in evaluation sets. Multiple coordinate families can model multiple encodings or views of the same examples. The theory is combinatorial rather than statistical—it does not itself guarantee generalization—but it supplies a precise design invariant.

### 10.4 Communications and reversible transitions

The unique-intersection property provides deterministic encoding and decoding. Given a left label and a right label, exactly one state is selected. Multiple compatible coordinate pairs provide redundant but lossless descriptions, a pattern related to reversible finite-state systems and permutation-based channels.

## 11. Discussion

The most economical formulation of the theory is the cross-coordinate bijection. It contains several familiar conditions as different readings:

- as incidence, it says opposite-type fibres intersect exactly once;
- as matrix theory, it says opposite-type matrices are orthogonal;
- as array theory, it says every left-right projection contains every ordered pair once;
- as counting, it exhibits a bijection with an $m$-by-$n$ grid.

The coordinate characterization theorems show that even the local Latin axioms fit this pattern: a one-sided Latin matrix is precisely a matrix orthogonal to the appropriate canonical coordinate matrix.

The asymmetry between $m$ and $n$ is structural, not cosmetic. Column-Latin matrices use $m$ symbols because columns have $m$ positions; row-Latin matrices use $n$ symbols because rows have $n$ positions. Their cross-pairs range over exactly $mn$ possibilities, matching the number of cells. Square Latin structures arise when $m=n$, but the proofs require no equality of parameters.

There are also clear boundaries to the present results. The coordinate formulation treats lines as fibres rather than as independently stored finite subsets. It establishes direct constructions but not yet a complete equivalence of normalized structures under isomorphism. It permits repeated coordinate families unless an additional repetition-free condition is imposed. Finally, it addresses exact index-one balance rather than higher multiplicities.

## 12. Future work

Several developments would extend the finite coordinate core.

1. **Partition-level incidence structures.** Introduce lines explicitly as finite subsets, require pairwise-disjoint covers, and prove equivalence with the fibre representation, including all regularity clauses for line sizes and incidences.
2. **Full inverse correspondence.** Package ordered reticulations, svelte semi-orthogonal arrays, and normalized cooperative systems as equivalent structures, with round-trip isomorphisms.
3. **Multiplicity and repetition.** Allow multisets of line families, define repetition-free systems, and characterize when coordinate families coincide.
4. **Parastrophy and isotopy.** Study permutation actions on points, labels, and families, proving preservation of cooperation and reticulation axioms.
5. **Constructions.** Develop prolongation, splicing, and direct-product operations and derive their parameter formulas.
6. **Classical specializations.** Recover nets, mixed orthogonal arrays, mutually orthogonal Latin squares, and reversible finite-state constructions as special cases.
7. **Finite classification.** Enumerate small repetition-free systems up to isotopy and provide independently checkable certificates for reported counts.

## 13. Conclusion

A finite set with two types of coordinate families becomes rigid as soon as every opposite-type pair labels it bijectively. Unique intersections force a rectangular grid, and that grid has exactly $mn$ points. Column-Latin and row-Latin matrices describe the two directions; orthogonality supplies their cooperation. Recording all labels row by row yields a svelte array, while reading array entries as fibre labels reconstructs an incidence geometry.

The resulting dictionary is concise: fibres are lines, ordered symbol pairs are intersections, orthogonality is a coordinate chart, and cross-projection balance is the array form of the same bijection. This common language supports both theoretical generalization and direct linear-time validation of finite examples.