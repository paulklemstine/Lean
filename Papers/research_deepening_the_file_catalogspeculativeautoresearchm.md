# Factorial Coordinates and Clique Shadows: Two Structural Bridges in Discrete Computation

**Aristotle**  
**July 15, 2026**

## Abstract

This paper develops two self-contained bridges between specialized discrete constructions and general structural theories. The first identifies the factorial number system with the mixed-radix system whose successive radices are $1,2,3,\ldots$. The identity $\prod_{j<i}(j+1)=i!$ yields exact agreement of place values, admissible digits, and digit-extraction algorithms. General mixed-radix reconstruction and uniqueness therefore specialize to sharp factoradic results: every integer $n<k!$ is reconstructed from its first $k$ extracted digits, and every valid length-$k$ factoradic representation is unique. The associated finite code space is the dependent product of alphabets of sizes $1,2,\ldots,k$.

The second bridge views the triangles of a finite simple graph as a $3$-uniform set family. Its lower shadow consists of vertex pairs obtained by deleting one vertex from a triangle, and every such pair is an edge. The Lovász form of the Kruskal–Katona shadow inequality then gives a sharp graph-theoretic consequence: if a graph on $n$ vertices has at least $\binom{k}{3}$ triangles, where $3\le k\le n$, then it has at least $\binom{k}{2}$ edges. Equality is attained by a complete graph on $k$ vertices together with isolated vertices. Alongside proofs, we give extraction, reconstruction, enumeration, and graph-certification algorithms, discuss complexity, and identify extensions to permutation codes, carry normalization, higher cliques, and inverse limits.

## 1. Introduction

Two recurring tasks in discrete mathematics are to design coordinates for finite objects and to infer lower-dimensional structure from higher-dimensional patterns. Positional number systems address the first task. Shadow inequalities for set families address the second. Although the resulting applications look different, their proofs share a useful architecture: identify a specialized object as an instance of a general construction, prove one structural compatibility statement, and transport the general theorem across that compatibility.

The factorial number system represents an integer as

$$
\sum_{i=0}^{k-1} c_i i!,
$$

where the digit in position $i$ satisfies $0\le c_i\le i$. Unlike fixed-base notation, the allowed alphabet grows with the position. This system is often introduced directly, especially in connection with permutation ranking. The first objective of this paper is to show that all of its basic arithmetic is inherited from mixed-radix notation. If the radix at position $i$ is $i+1$, then the corresponding running product is $i!$. Consequently, value, validity, extraction, reconstruction, and uniqueness coincide exactly.

The second objective concerns a graph $G$. Its triangles are naturally three-element subsets of the vertex set. The lower shadow of this family consists of all two-element subsets contained in triangles. Every such pair is necessarily an edge. Thus a theorem about shadows of uniform set families can be converted into a theorem about graph edges. The resulting inequality is

$$
|T(G)|\ge \binom{k}{3}\quad\Longrightarrow\quad |E(G)|\ge\binom{k}{2},
$$

for $3\le k\le |V(G)|$, where $T(G)$ and $E(G)$ denote the triangle and edge sets.

These developments are useful computationally as well as conceptually. Factoradic digits provide a canonical code for integers in a factorial interval. The triangle-to-edge theorem supplies an immediate consistency check for network summaries: a claimed triangle count forces a minimum edge count. Both are exact at their natural thresholds.

The paper is organized as follows. Section 2 defines mixed-radix and factorial representations. Section 3 proves their equivalence. Section 4 derives extraction, reconstruction, uniqueness, and the finite code space. Section 5 introduces uniform families and shadows. Section 6 proves the triangle-to-edge theorem and analyzes equality. Section 7 presents algorithms and examples. Sections 8–10 discuss applications, limitations, and future directions.

## 2. Variable-base positional systems

### 2.1. Mixed radices and running products

Let $b=(b_i)_{i\ge0}$ be a sequence of positive integers, called **radices**. Define the running product

$$
B_0=1,\qquad B_i=\prod_{j=0}^{i-1}b_j\quad(i\ge1).
$$

The quantity $B_i$ is the place value of position $i$. For a sequence of nonnegative digits $c=(c_i)_{i\ge0}$ and a cutoff $k$, define the truncated mixed-radix value by

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iB_i.
$$

A digit sequence is **valid through position $k-1$** when

$$
0\le c_i<b_i\qquad\text{for every }0\le i<k.
$$

The upper bound is the no-overflow condition for a single column: $b_i$ units at position $i$ have value $b_iB_i=B_{i+1}$ and therefore carry to the next position.

A fixed-base system is the special case $b_i=q$ for every $i$, giving $B_i=q^i$. The varying-base definition is broader: the conversion ratio between consecutive positions may change with $i$.

### 2.2. General digit extraction

Given an integer $n\ge0$, define its mixed-radix digit at position $i$ by

$$
D_{b,i}(n)=\left\lfloor\frac{n}{B_i}\right\rfloor\bmod b_i.
$$

The quotient removes all contributions below position $i$. Reduction modulo $b_i$ discards the contribution from positions above $i$, leaving the unique residue admissible at the current position. By construction,

$$
0\le D_{b,i}(n)<b_i.
$$

For the first $k$ positions, the total representational capacity is

$$
B_k=\prod_{i=0}^{k-1}b_i.
$$

The standard mixed-radix reconstruction principle states that if $0\le n<B_k$, then

$$
n=\sum_{i=0}^{k-1}D_{b,i}(n)B_i.
$$

The associated uniqueness principle states that if $c$ and $e$ are valid through position $k-1$ and $V_b(c;k)=V_b(e;k)$, then $c_i=e_i$ for all $i<k$.

For completeness, both principles can be understood inductively. Reduction modulo $b_0$ determines the lowest digit. Subtract it and divide by $b_0$; the remaining quotient is represented in the tail system with radices $b_1,b_2,\ldots$. Repeating this operation reconstructs all digits and also proves that no two valid strings can have the same value.

## 3. The factorial system as a mixed-radix specialization

### 3.1. Factorial notation

The **factorial number system** assigns place value $i!$ to position $i$. For a digit sequence $c$, define

$$
V_!(c;k)=\sum_{i=0}^{k-1}c_i i!.
$$

The sequence is **factorially valid through position $k-1$** if

$$
0\le c_i\le i\qquad(0\le i<k).
$$

Equivalently, $c_i<i+1$. Position $0$ has only the digit $0$, position $1$ has digits $0,1$, position $2$ has digits $0,1,2$, and so on.

### 3.2. Running products become factorials

Set

$$
b_i=i+1.
$$

Then for every $i\ge0$,

$$
B_i=\prod_{j=0}^{i-1}(j+1)=1\cdot2\cdots i=i!.
$$

For $i=0$, both sides equal $1$ by the empty-product convention and the definition $0!=1$.

This identity is the complete structural input for the arithmetic bridge.

### Theorem 3.1 (Equality of value maps)

For every nonnegative digit sequence $c$ and every cutoff $k$, mixed-radix evaluation with $b_i=i+1$ agrees with factorial evaluation:

$$
V_b(c;k)=V_!(c;k).
$$

**Proof sketch.** Substitute $B_i=i!$ into each summand of the mixed-radix value:

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iB_i
=\sum_{i=0}^{k-1}c_i i!
=V_!(c;k).
$$

The equality is termwise and requires no condition on the digits. $\square$

### Theorem 3.2 (Equality of validity conditions)

For every digit sequence $c$ and cutoff $k$, mixed-radix validity for $b_i=i+1$ is equivalent to factorial validity:

$$
\bigl(0\le c_i<b_i\text{ for all }i<k\bigr)
\quad\Longleftrightarrow\quad
\bigl(0\le c_i\le i\text{ for all }i<k\bigr).
$$

**Proof sketch.** Since $b_i=i+1$, the mixed-radix condition is $c_i<i+1$. For integer digits, this is equivalent to $c_i\le i$. $\square$

Together, Theorems 3.1 and 3.2 show that factorial notation is not merely analogous to a mixed-radix system. It is exactly the system with the increasing radix sequence $1,2,3,\ldots$.

## 4. Extraction, reconstruction, and finite factorial codes

### Theorem 4.1 (Agreement of digit extraction)

For every $n\ge0$ and every position $i\ge0$, the mixed-radix digit for $b_j=j+1$ equals the factoradic digit

$$
D_{!,i}(n)=\left\lfloor\frac{n}{i!}\right\rfloor\bmod(i+1).
$$

**Proof sketch.** The general extraction rule is $D_{b,i}(n)=\lfloor n/B_i\rfloor\bmod b_i$. Substituting $B_i=i!$ and $b_i=i+1$ gives the displayed formula. $\square$

This theorem asserts pointwise algorithmic identity: the two procedures compute the same digit at every index, not only the same reconstructed integer.

### Theorem 4.2 (Factoradic reconstruction below capacity)

Let $k\ge0$ and $0\le n<k!$. Define

$$
d_i=\left\lfloor\frac{n}{i!}\right\rfloor\bmod(i+1)
$$

for $0\le i<k$. Then every digit satisfies $0\le d_i\le i$, and

$$
\sum_{i=0}^{k-1}d_i i!=n.
$$

**Proof sketch.** The product of the first $k$ radices is

$$
B_k=\prod_{i=0}^{k-1}(i+1)=k!.
$$

Thus $n<k!$ is exactly the mixed-radix capacity hypothesis $n<B_k$. Apply mixed-radix reconstruction, then replace $B_i$ by $i!$ and the extracted digits by the formula of Theorem 4.1. The remainder operation gives $d_i<i+1$, hence $d_i\le i$. $\square$

The bound is sharp in the natural sense. Valid strings of length $k$ represent values from $0$ through $k!-1$. The value $k!$ is one unit in position $k$ and cannot be represented using only positions below $k$.

### Theorem 4.3 (Uniqueness of valid factorial representations)

Let $c=(c_i)$ and $e=(e_i)$ be nonnegative digit sequences satisfying $c_i\le i$ and $e_i\le i$ for every $i<k$. If

$$
\sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}e_i i!,
$$

then

$$
c_i=e_i\qquad\text{for every }i<k.
$$

**Proof sketch.** By Theorem 3.2 both sequences are valid mixed-radix strings for $b_i=i+1$, and by Theorem 3.1 their factorial values are their mixed-radix values. General mixed-radix uniqueness therefore applies.

A direct magnitude argument gives the same intuition. If $r$ is the largest position at which the strings differ, then the discrepancy at position $r$ has absolute value at least $r!$. The maximum possible contribution from all lower positions is

$$
\sum_{i=0}^{r-1} i\,i!
=\sum_{i=0}^{r-1}\bigl((i+1)!-i!\bigr)
=r!-1.
$$

Lower positions cannot cancel the discrepancy, contradicting equality of values. $\square$

### 4.1. The finite code space

A **length-$k$ factorial code** is a tuple

$$
(c_0,c_1,\ldots,c_{k-1})
$$

with $c_i\in\{0,1,\ldots,i\}$. This is naturally a position-dependent Cartesian product

$$
\mathcal C_k=\prod_{i=0}^{k-1}\{0,1,\ldots,i\}.
$$

Its cardinality is

$$
|\mathcal C_k|=\prod_{i=0}^{k-1}(i+1)=k!.
$$

A finite code can be extended to an infinite digit sequence by setting every digit at an index $i\ge k$ equal to $0$. Theorems 4.2 and 4.3 show that evaluation gives a bijection

$$
\mathcal C_k\longleftrightarrow\{0,1,\ldots,k!-1\},
$$

with inverse given by factoradic digit extraction.

### 4.2. Example

For $n=463$ and $k=6$, the extracted digits are

$$
(d_0,d_1,d_2,d_3,d_4,d_5)=(0,1,0,1,4,3).
$$

Reconstruction gives

$$
0\cdot0!+1\cdot1!+0\cdot2!+1\cdot3!+4\cdot4!+3\cdot5!
=1+6+96+360=463.
$$

Since $463<6!=720$, the first six positions suffice, and uniqueness excludes any other valid six-digit representation.

## 5. Uniform families and lower shadows

We now turn to a separate bridge, from extremal set theory to graph theory.

Let $X$ be a finite set. A family $\mathcal F\subseteq\binom{X}{r}$ is **$r$-uniform** if every member has exactly $r$ elements. Its **lower shadow** is

$$
\partial\mathcal F
=
\left\{A\in\binom{X}{r-1}: A\subseteq F\text{ for some }F\in\mathcal F\right\}.
$$

Thus $\partial\mathcal F$ records every set obtained by deleting one element from a member of $\mathcal F$.

The Kruskal–Katona theorem controls how small this shadow can be. We use the following integer-threshold consequence, often called the Lovász form.

### Theorem 5.1 (Uniform shadow bound)

Let $\mathcal F$ be an $r$-uniform family on an $n$-element ground set. If $r\le k\le n$ and

$$
|\mathcal F|\ge\binom{k}{r},
$$

then

$$
|\partial\mathcal F|\ge\binom{k}{r-1}.
$$

**Proof sketch.** The Kruskal–Katona principle states that among $r$-uniform families of fixed size, initial segments in colexicographic order minimize the lower shadow. At the threshold $\binom{k}{r}$, the minimizing family is all $r$-subsets of a fixed $k$-element set. Its shadow is all $(r-1)$-subsets of that set and therefore has size $\binom{k}{r-1}$. Any family with at least as many members has shadow no smaller. $\square$

The threshold is exact, as witnessed by $\mathcal F=\binom{K}{r}$ for a fixed $k$-element set $K$.

## 6. The graph-theoretic bridge

Let $G=(V,E)$ be a finite simple graph. An **edge** is a two-element set $\{u,v\}$ with adjacent endpoints. A **triangle** is a three-element set $\{u,v,w\}$ for which all three pairs are edges. Write $E(G)$ for the edge family and $T(G)$ for the triangle family.

The family $T(G)$ is $3$-uniform. Its shadow consists of the pairs contained in at least one triangle.

### Lemma 6.1 (Triangle shadows are edges)

For every finite simple graph $G$,

$$
\partial T(G)\subseteq E(G).
$$

**Proof sketch.** Take $A\in\partial T(G)$. Then $A$ is a two-element subset of some triangle $F\in T(G)$. Every pair of vertices in a triangle is adjacent, so $A$ is an edge. $\square$

This inclusion is the geometric heart of the bridge. Notice that equality need not hold: an edge that belongs to no triangle lies outside the shadow.

### Theorem 6.2 (Kruskal–Katona triangle-to-edge inequality)

Let $G$ be a finite simple graph on $n$ vertices. Let $k$ be an integer satisfying $3\le k\le n$. If

$$
|T(G)|\ge\binom{k}{3},
$$

then

$$
|E(G)|\ge\binom{k}{2}.
$$

**Proof sketch.** Apply Theorem 5.1 with $r=3$ to the $3$-uniform family $T(G)$. The triangle hypothesis gives

$$
|\partial T(G)|\ge\binom{k}{2}.
$$

Lemma 6.1 gives $\partial T(G)\subseteq E(G)$, so

$$
\binom{k}{2}
\le |\partial T(G)|
\le |E(G)|.
$$

This proves the claim. $\square$

### 6.1. Equality and sharpness

Let $G$ consist of a complete graph on $k$ vertices and $n-k$ isolated vertices. Then every pair among the distinguished $k$ vertices is an edge and every triple is a triangle. Hence

$$
|E(G)|=\binom{k}{2},\qquad |T(G)|=\binom{k}{3}.
$$

The theorem is therefore sharp simultaneously in its triangle threshold and edge conclusion.

The theorem does not assert a complete classification of equality cases. Its sharpness claim requires only an extremizing construction. A full stability or equality classification would ask whether graphs near the bound must resemble a $k$-vertex clique plus sparse residue; that is a further problem.

### 6.2. Numerical thresholds

For $k=3$, one triangle forces three edges. For $k=4$, four triangles force six edges. For $k=6$, twenty triangles force fifteen edges. For $k=10$, one hundred twenty triangles force forty-five edges. In each case the complete graph on $k$ vertices reaches equality.

## 7. Algorithms and computational demonstrations

### 7.1. Direct factoradic extraction

Given $n$ and $k$ with $0\le n<k!$, compute

$$
d_i=\left(\left\lfloor\frac{n}{i!}\right\rfloor\right)\bmod(i+1)
$$

for $i=0,\ldots,k-1$. Factorials may be accumulated iteratively: begin with $0!=1$ and update $(i+1)!= (i+1)i!$. With arbitrary-precision integer arithmetic, the algorithm performs $k$ divisions and remainders. Counting arithmetic operations, its time is $O(k)$; bit complexity depends on the growth of integers of size $O(\log(k!))$.

A commonly used equivalent procedure repeatedly divides a quotient by the next radix. Set $q=n$. For $i=0,1,\ldots,k-1$, assign $d_i=q\bmod(i+1)$ and replace $q$ by $\lfloor q/(i+1)\rfloor$. The first step always yields $d_0=0$ because reduction modulo $1$ is zero. This procedure makes the mixed-radix structure explicit.

### 7.2. Reconstruction and validation

To reconstruct, accumulate $d_i i!$. Simultaneously check $0\le d_i\le i$. This takes $O(k)$ arithmetic operations and $O(1)$ auxiliary big integers beyond the digit storage. If all bounds hold, the result lies below $k!$ because

$$
\sum_{i=0}^{k-1}i\,i!=k!-1.
$$

The telescoping identity follows from $i\,i!=(i+1)!-i!$.

### 7.3. Enumerating graph triangles

For a graph represented by an adjacency matrix, one may inspect every vertex triple. A triple forms a triangle exactly when all three pairwise adjacency entries are true. This direct method costs $O(n^3)$ time and $O(1)$ additional working space beyond the graph and output counters. Edge counting costs $O(n^2)$.

More sophisticated sparse-graph algorithms can count triangles faster in practice, but cubic enumeration is sufficient for transparent demonstrations of Theorem 6.2.

### 7.4. Threshold certification

Given $n$, $k$, an edge count $m$, and a triangle count $t$, a certificate checks the hypotheses $3\le k\le n$ and $t\ge\binom{k}{3}$. If they hold, the theorem requires $m\ge\binom{k}{2}$. Failure of the edge inequality means the reported graph statistics cannot both be correct. The certificate runs in constant arithmetic time once the counts are known; graph enumeration dominates the end-to-end cost.

## 8. Applications and conceptual consequences

### 8.1. Permutation indexing

The factoradic alphabet sizes are $1,2,\ldots,k$, whose product is $k!$, the number of permutations of $k$ objects. This numerical match underlies Lehmer codes. In one standard orientation, a permutation is encoded by inversion counts whose admissible ranges vary by position. The finite factorial-code bijection with $\{0,\ldots,k!-1\}$ supplies a canonical rank space for permutations.

The arithmetic results here establish the coordinate side of that application: extracted digits are valid, reconstruction is exact below $k!$, and the representation is unique. To obtain a fully equivariant permutation theorem, one must additionally define the insertion or deletion correspondence and prove compatibility with lexicographic order and adjacent transpositions.

### 8.2. Variable-radix data formats

Mixed-radix systems occur whenever units change by level: time has seconds, minutes, hours, and days; calendars use still more irregular transitions; combinatorial ranking schemes use position-dependent choice counts. The factorial specialization illustrates how a product identity can turn a bespoke encoding into an instance of general conversion logic. This reduces duplicate reasoning and makes capacity bounds explicit.

### 8.3. Network consistency checks

Triangle counts are common summaries of clustering in social, biological, and communication networks. The triangle-to-edge inequality gives a universal lower bound independent of how the graph was generated. If a network on at least $k$ vertices is reported to contain $\binom{k}{3}$ or more triangles but fewer than $\binom{k}{2}$ edges, the summary is impossible.

The bound is global and extremal. It does not estimate the typical edge count of a random network, nor does it recover the graph. Its value lies in providing a sharp, assumption-free constraint.

### 8.4. Higher-dimensional clique shadows

The structural inclusion extends immediately at the level of ideas. The shadow of the family of $r$-cliques is contained in the family of $(r-1)$-cliques, because deleting a vertex from a clique leaves a clique. Combined with an appropriate uniform-shadow theorem, this suggests the general threshold

$$
\#K_r(G)\ge\binom{k}{r}
\quad\Longrightarrow\quad
\#K_{r-1}(G)\ge\binom{k}{r-1}.
$$

The triangle-to-edge result is the case $r=3$. The same bridge therefore belongs to a hierarchy rather than standing alone.

## 9. Discussion

The factorial bridge is driven by an identity of weights. Once $B_i=i!$ is known, equality of values and digits is immediate, while reconstruction and uniqueness are transported from general mixed-radix theory. The sharp interval $[0,k!)$ is not an arbitrary convention: it is the product capacity of the first $k$ radices and the cardinality of the finite code space.

The graph bridge is driven by an inclusion of families. The difficult numerical information comes from Kruskal–Katona; the graph-specific content is the elementary fact that a pair inside a triangle is an edge. This division of labor is mathematically efficient. It separates a universal extremal theorem from the local compatibility needed for the application.

There is also a useful contrast. Factoradic evaluation is information-preserving on valid codes: uniqueness makes it injective, and reconstruction makes it surjective onto the factorial interval. Taking a shadow, by contrast, generally loses information: many different triangle families may have the same collection of pairs. Nevertheless, the shadow retains enough cardinal information to force an optimal edge bound.

Both bridges demonstrate the importance of choosing the correct intermediate object. For factorial arithmetic, it is the running product of radices. For graph triangles, it is the lower shadow of a uniform family. Neither intermediate object is merely decorative; each exposes the invariant to which a general theorem applies.

## 10. Future research

Several natural directions extend the factorial-coordinate results.

First, the length-$k$ factorial-code space should be related canonically to permutations of $k$ elements so that factoradic evaluation equals lexicographic rank and digit extraction equals the sequence of Lehmer inversion counts. A refined result would describe how adjacent transpositions act as explicit carry-and-borrow transformations on codes.

Second, one can allow unrestricted nonnegative digits and orient

$$
(i+1)i!=(i+1)!
$$

as a local carry rule. The aim is to prove that the induced rewriting system on finitely supported sequences terminates and is confluent, with valid factorial codes as its unique normal forms. Value preservation is immediate for each local carry; the deeper issue is global confluence.

Third, factorial codes resemble residue coordinates but use nested divisibility rather than pairwise coprime moduli. It is natural to ask for which $k$ the interval of $k!$ residues admits product coordinates compatible with truncation, and to classify the obstruction to a multiplicative coordinate system caused by overlap among $1,2,\ldots,k$.

Fourth, truncation of infinite factorial codes suggests an inverse system. One may seek a canonical homeomorphism between carry-normalized infinite codes and the inverse limit of the rings $\mathbb Z/(k!)\mathbb Z$, with finite evaluation as residue projection and normalized addition recovering a topological ring structure.

On the graph side, three directions stand out. The first is the full higher-clique hierarchy suggested in Section 8.4. The second is a classification of equality cases and a stability theorem for graphs whose edge count is close to $\binom{k}{2}$ while their triangle count is at least $\binom{k}{3}$. The third is algorithmic: use shadow-based bounds as certificates inside streaming or approximate network-analysis pipelines, where exact triangle enumeration may be expensive.

## 11. Conclusion

The factorial number system is exactly the mixed-radix system with radix $i+1$ at position $i$. Its running products are factorials, its validity bounds coincide with factoradic digit bounds, and its extraction formula is the general mixed-radix formula under substitution. Consequently, every integer below $k!$ has a unique valid length-$k$ representation, recovered digit by digit.

Independently, the triangle family of a graph is a $3$-uniform set family whose lower shadow lies inside the edge family. The Kruskal–Katona shadow bound therefore implies that at least $\binom{k}{3}$ triangles force at least $\binom{k}{2}$ edges. Complete graphs show sharpness.

In each case, a specialized discrete statement becomes transparent after passage through the right general structure. Running products explain factorial coordinates; shadows explain the edge content of triangles. These bridges turn local identities and inclusions into exact global theorems.