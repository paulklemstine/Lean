# Boolean-Cube Attachments and Exact Linear Face Complexity in Recursive Simplicial $k$-Trees

**Aristotle**  
**July 15, 2026**

## Abstract

We isolate the local enumeration principle responsible for the linear face complexity of recursively constructed simplicial $k$-trees. Let $K$ be a finite simplicial complex supported on a ground set $G$, let $
ho\subseteq G$ be a face of cardinality $k$, and let $v\notin G$ be a fresh vertex. Coning $v$ over every subface of $
ho$ creates the family $\{\{v\}\cup\tau:\tau\subseteq\rho\}$. We prove that this family is in bijection with the Boolean cube of subsets of $
ho$, has cardinality exactly $2^k$, and is disjoint from every old face supported on $G$. Consequently, a construction beginning with the full simplex on $k+1$ vertices and making $s$ fresh $k$-face attachments has exactly

$$
2^{k+1}+s2^k=2^k(s+2)
$$

faces when the empty face is included. In terms of the final vertex count $n=k+1+s$, the count is $2^k(n-k+1)$, linear in $n$ for fixed $k$. This exact formula implies a previously proposed linear estimate and improves it by the constant $2^k-1$. We also derive the graded increment $x(1+x)^k$, present output-sensitive enumeration algorithms, contrast recursive acyclicity with width-only polynomial bounds, and discuss applications to compact combinatorial witnesses.

## 1. Introduction

Finite simplicial complexes can have enormous face sets. A simplex on $n$ vertices contains all $2^n$ subsets, while even the restriction to faces of cardinality at most $k+1$ yields

$$
\sum_{j=0}^{k+1}\binom{n}{j}
$$

faces. For fixed $k$, this skeleton count is polynomial of degree $k+1$ in $n$. Such width restrictions are useful, but they do not exploit global structure.

Recursive simplicial $k$-trees add a second resource: acyclic assembly. Starting with a full simplex on $k+1$ vertices, one repeatedly selects a $k$-vertex face and attaches a fresh vertex over it. Each new vertex interacts with the existing complex only through its chosen base. The central question is quantitative: how many new faces does one attachment create, and how do these increments accumulate?

The answer is governed by a Boolean cube. If the attaching face has $k$ vertices, each subset of those vertices may accompany the new apex, producing one new face. There are $2^k$ such subsets. Freshness of the apex ensures both that distinct subsets produce distinct faces and that none of those faces was present before. Thus each attachment makes an exact, disjoint increment of $2^k$ faces.

This mechanism establishes a two-parameter complexity law. Dependence on width is exponential through $2^k$, whereas dependence on the number of vertices is linear. The distinction is valuable in algorithms parameterized by a small interface width: when $k$ is fixed or modest, very large complexes can be generated, represented, and searched with cost proportional to their number of construction steps.

The results are elementary but structural. They identify the precise source of linearity, clarify constants arising from different counting conventions, and provide a bridge from geometric attachment operations to binary enumeration. They also furnish a local counting lemma suitable for inductive treatments of graph-theoretic $k$-trees, clique complexes, elimination orderings, and witness subcomplexes.

## 2. Definitions and conventions

### 2.1. Finite simplicial complexes

Let $G$ be a finite set. A **simplicial complex** on $G$ is a family $K$ of subsets of $G$ such that whenever $	au\in K$ and $	au'\subseteq\tau$, then $	au'\in K$. Elements of $K$ are called **faces**. A face of cardinality $j$ has dimension $j-1$. We count the empty face, which has cardinality $0$ and dimension $-1$.

For a finite set $
ho$, its **full simplex** is the power set

$$
2^\rho=\{\tau:\tau\subseteq\rho\}.
$$

If $|\rho|=m$, the full simplex has $2^m$ faces. Equivalently, each face corresponds to a binary word in $\{0,1\}^m$, with one bit recording whether each vertex is selected.

### 2.2. Cone attachments

Let $K$ be a simplicial complex whose faces are supported on a finite ground set $G$. Let $
ho\subseteq G$ be a face, and let $v$ be a vertex not in $G$. The **cone-face family with apex $v$ and base $
ho$** is

$$
C(v,\rho)=\bigl\{\{v\}\cup\tau:\tau\subseteq\rho\bigr\}.
$$

The attached complex is

$$
K'=K\cup C(v,\rho).
$$

Because $
ho$ is a face and $K$ is closed under subsets, all subsets of $
ho$ already lie in $K$. The union $K'$ is again a simplicial complex: a subset of a new face either contains $v$ and remains in $C(v,\rho)$, or excludes $v$ and is a subface of $
ho$, hence belongs to $K$.

Freshness, expressed by $v\notin G$, is essential. Without it, inserting $v$ could identify distinct subsets or reproduce old faces. With it, the apex serves as an unambiguous marker of the new layer.

### 2.3. Recursive simplicial $k$-trees

Fix $k\geq 0$. A **recursive simplicial $k$-tree with $s$ attachment steps** is obtained as follows:

1. Begin with the full simplex on a set of $k+1$ vertices.
2. At each of $s$ steps, choose a face $
ho$ with $|\rho|=k$ in the current complex.
3. Introduce a fresh vertex $v$ and replace the current complex $K$ by $K\cup C(v,\rho)$.

After $s$ steps, the final number of vertices is

$$
n=k+1+s.
$$

The terminology emphasizes recursive attachment rather than any particular graph model. In graph-theoretic language, closely related objects arise by adding a vertex adjacent to every vertex of an existing $k$-clique and then taking the clique complex.

### 2.4. Face enumerators

For a finite simplicial complex $K$, define the cardinality-graded face enumerator

$$
F_K(x)=\sum_{\tau\in K}x^{|\tau|}.
$$

The constant coefficient counts the empty face. The coefficient of $x^j$ counts faces of cardinality $j$, and $F_K(1)=|K|$ gives the total face count.

## 3. The Boolean-cube attachment principle

We first identify the exact local increment.

### Lemma 3.1. Apex insertion is injective

Let $
ho$ be a finite vertex set and let $v\notin\rho$. The map

$$
\Phi:2^\rho\longrightarrow C(v,\rho),\qquad
\Phi(\tau)=\{v\}\cup\tau,
$$

is a bijection.

**Proof sketch.** Surjectivity follows from the definition of $C(v,\rho)$. For injectivity, suppose $\{v\}\cup\tau_1=\{v\}\cup\tau_2$. Since $v\notin\rho$, neither $	au_1$ nor $	au_2$ contains $v$. Removing $v$ from both sides gives $	au_1=\tau_2$. Thus $	au$ can be recovered uniquely from its cone face by deleting the apex. $\square$

### Theorem 3.2. Boolean-Cube Attachment Theorem

Let $
ho$ be a finite face of cardinality $k$, and let $v\notin\rho$. Then

$$
|C(v,\rho)|=2^k.
$$

**Proof sketch.** By Lemma 3.1, the new cone faces are in bijection with all subsets of $
ho$. A $k$-element set has $2^k$ subsets, because each of its $k$ vertices supplies one independent binary choice. $\square$

The theorem gives more than an upper bound. Every binary choice occurs, and no two choices collide. This exactness is the source of the later recurrence.

### Lemma 3.3. Disjointness from old faces

Let $K$ be supported on $G$, meaning $	au\subseteq G$ for every $	au\in K$. If $v\notin G$, then

$$
K\cap C(v,\rho)=\varnothing.
$$

**Proof sketch.** Every face in $C(v,\rho)$ contains $v$. Every face in $K$ is a subset of $G$ and therefore omits $v$. No face can satisfy both conditions. $\square$

### Theorem 3.4. Exact one-step recurrence

Under the hypotheses of Lemma 3.3, if $|\rho|=k$ and

$$
K'=K\cup C(v,\rho),
$$

then

$$
|K'|=|K|+2^k.
$$

**Proof sketch.** The union is disjoint by Lemma 3.3, so its cardinality is the sum of the two cardinalities. The new family has cardinality $2^k$ by Theorem 3.2. $\square$

The recurrence is independent of the shape of $K$ and of the position of $
ho$ within it. Only the cardinality of the attaching face matters.

## 4. Exact global face counts

### Theorem 4.1. Exact Stacked Face-Count Theorem

A recursive simplicial $k$-tree formed from a full simplex on $k+1$ vertices by $s$ fresh $k$-face attachments has exactly

$$
T(k,s)=2^{k+1}+s2^k=2^k(s+2)
$$

faces, including the empty face.

**Proof sketch.** The initial full simplex has one face for every subset of its $k+1$ vertices, hence $2^{k+1}$ faces. By Theorem 3.4, each of the $s$ attachments adds exactly $2^k$ new faces and shares none of them with the previous complex. Summing the base count and the $s$ equal increments gives $2^{k+1}+s2^k$. Factoring out $2^k$ yields $2^k(s+2)$. $\square$

### Corollary 4.2. Vertex-count form

If the final complex has $n=k+1+s$ vertices, then

$$
T(k,n)=2^k(n-k+1).
$$

In particular, for each fixed $k$, the total number of faces is linear in $n$.

**Proof sketch.** Solve $n=k+1+s$ for $s=n-k-1$ and substitute into Theorem 4.1:

$$
2^k(s+2)=2^k(n-k+1).
$$

$\square$

### Corollary 4.3. Exact counts for small widths

For $k=0$, the base is one vertex and each attachment is made over the empty face. The total is $s+2=n+1$, consisting of the empty face and $n$ singleton vertices.

For $k=1$, the base is an edge and every attachment over a one-vertex face adds a new vertex and a new edge. Thus

$$
T(1,s)=4+2s=2n.
$$

For $k=2$, the base is a triangle and every attachment over an edge adds one vertex, two edges, and one triangle. Thus

$$
T(2,s)=8+4s=4(n-1).
$$

For $k=3$, every attachment adds eight faces, distributed as one vertex, three edges, three triangles, and one tetrahedron. The total is

$$
T(3,s)=16+8s=8(n-2).
$$

These examples display the same pattern at successive widths: the increment is a shifted row of Pascal’s triangle whose sum is a power of two.

## 5. Comparison with a proposed linear estimate

Consider the estimate

$$
B(k,s)=2^k(s+1)+\bigl(2^{k+1}-1\bigr).
$$

### Theorem 5.1. Sharp comparison with the proposed bound

For all $k,s\geq 0$,

$$
T(k,s)\leq B(k,s),
$$

and the slack is exactly

$$
B(k,s)-T(k,s)=2^k-1.
$$

**Proof sketch.** Substitute $T(k,s)=2^k(s+2)$. Then

$$
\begin{aligned}
B(k,s)-T(k,s)
&=2^k(s+1)+2^{k+1}-1-2^k(s+2)\\
&=2^k-1.
\end{aligned}
$$

This quantity is nonnegative for every $k\geq 0$. $\square$

The difference does not depend on $s$. Thus the proposed estimate has the correct linear slope, and the exact Boolean-cube analysis improves only its intercept. For $k=0$, the two formulas coincide. For positive width, the slack is positive.

Counting conventions explain many nearby formulas. Omitting the empty face subtracts one from the total. Counting only maximal faces produces an entirely different statistic. Choosing a different initial object changes the base term but not the $2^k$ increment. The local attachment theorem is stable across these conventions; only initialization and the selected grading vary.

## 6. Graded enumeration

The total $2^k$ increment is the specialization of a more informative polynomial identity.

### Theorem 6.1. Face-vector increment

For a cone attachment over a $k$-vertex face, the number of newly created faces of cardinality $j$ is

$$
\binom{k}{j-1}
$$

for $1\leq j\leq k+1$, and is zero for all other $j$.

**Proof sketch.** Every new face contains the apex. A new face has cardinality $j$ precisely when it contains $j-1$ vertices from the $k$-vertex base. There are $\binom{k}{j-1}$ ways to select those vertices. $\square$

### Corollary 6.2. Generating-polynomial recurrence

If $K'$ is obtained from $K$ by one $k$-face attachment, then

$$
F_{K'}(x)=F_K(x)+x(1+x)^k.
$$

After $s$ attachments to the initial $(k+1)$-vertex simplex,

$$
F_{k,s}(x)=(1+x)^{k+1}+sx(1+x)^k.
$$

**Proof sketch.** The new apex contributes a factor of $x$, and each base vertex contributes either $1$ when omitted or $x$ when included. Hence the new-face polynomial is $x(1+x)^k$. The initial simplex has enumerator $(1+x)^{k+1}$, and disjoint increments add. $\square$

Evaluating at $x=1$ recovers Theorem 4.1. Differentiating or reading coefficients yields additional aggregate information. For example, the total number of vertex incidences among new faces is the derivative at $x=1$:

$$
\left.\frac{d}{dx}\bigl[x(1+x)^k\bigr]\right|_{x=1}
=2^k+k2^{k-1}.
$$

Thus the Boolean-cube model controls both ungraded and graded complexity.

## 7. Algorithms

### 7.1. Enumerating one attachment

Represent the $k$ base vertices as an ordered list $(b_0,\ldots,b_{k-1})$. For every integer mask $m$ from $0$ through $2^k-1$, construct

$$
\{v\}\cup\{b_i:\text{the }i\text{-th bit of }m\text{ is }1\}.
$$

This lists every new face exactly once by Lemma 3.1.

The algorithm takes $\Theta(k2^k)$ elementary bit inspections if faces are materialized explicitly, or $\Theta(2^k)$ delay steps if masks serve as an implicit face representation. Its output contains $2^k$ faces, so no explicit enumerator can use asymptotically fewer than $\Omega(2^k)$ output operations.

### 7.2. Counting without enumeration

When only the number of faces is required, enumeration is unnecessary. Given $k$ and $s$, compute

$$
2^k(s+2).
$$

With fixed-width machine integers and no overflow, this takes constant arithmetic time. In an arbitrary-precision bit model, exponentiation by shifting and multiplication have cost polynomial in the bit length of the result. The algorithm uses constant auxiliary storage apart from the output integer.

### 7.3. Computing the complete face vector

Initialize the vector of cardinality counts for the $(k+1)$-vertex simplex:

$$
f_j=\binom{k+1}{j},\qquad 0\leq j\leq k+1.
$$

For $1\leq j\leq k+1$, add

$$
s\binom{k}{j-1}.
$$

Therefore the final count of $j$-vertex faces is

$$
f_j=\binom{k+1}{j}+s\binom{k}{j-1},
$$

with $f_0=1$. Computing the vector from binomial coefficients takes $O(k)$ arithmetic operations using the standard multiplicative recurrence for adjacent coefficients. This is preferable to enumerating all faces when only graded statistics are needed.

### 7.4. Validating a construction record

A construction may be stored as an initial list of $k+1$ vertices followed by pairs $(v_i,\rho_i)$, where each $v_i$ is a new apex and each $
ho_i$ is a $k$-vertex attaching face. To validate the record, process pairs in order, checking that $v_i$ has not appeared previously, $|\rho_i|=k$, and $
ho_i$ is a face of the current complex. If explicit face storage is used, membership is direct but may consume $\Theta(2^k s)$ space. More compact data structures can exploit the recursive history, depending on which membership queries must be supported.

## 8. Width, acyclicity, and witness complexity

The exact count clarifies the difference between two controls on combinatorial growth.

A **width-only** condition permits all faces with at most $k+1$ vertices. The resulting full skeleton on $n$ vertices has exactly

$$
S_k(n)=\sum_{j=0}^{k+1}\binom{n}{j}
$$

faces. For fixed $k$, its leading term is $n^{k+1}/(k+1)!$, so the growth has degree $k+1$.

A recursive simplicial $k$-tree imposes the same local dimensional ceiling but also restricts global assembly. New vertices enter through one $k$-vertex interface, and interactions between independent attachment choices do not proliferate into all possible small subsets. The resulting count

$$
2^k(n-k+1)
$$

is linear in $n$.

This contrast is relevant to witness complexity. Suppose a geometric or combinatorial claim can be certified by a face in some subcomplex. A width bound guarantees a polynomial-size search family. If the subcomplex can additionally be chosen with recursive acyclic structure, the family can be linear-size for fixed $k$. The present results solve the enumeration side of that pipeline: once an appropriate recursive witness complex is available, its size is known exactly.

No geometric capture theorem is assumed here. The counting statements are conditional only on the recursive attachment description. Separating enumeration from existence is useful: the same Boolean-cube mechanism can support multiple applications, while each application supplies its own criterion ensuring that a desired witness lies in the constructed subcomplex.

## 9. Applications and interpretations

### 9.1. Clique complexes and elimination orders

A graph-theoretic $k$-tree begins from a $(k+1)$-clique and repeatedly adds a vertex whose older neighborhood is a $k$-clique. In its clique complex, every new clique containing the fresh vertex is formed by combining that vertex with a subset of the older $k$-clique. Therefore the local clique increment has the same Boolean-cube form. Establishing the exact equivalence of recursive graph and simplicial descriptions transfers the face formula to clique enumeration and relates the construction to perfect-elimination orderings.

### 9.2. Sparse certificates

In optimization, geometry, and topological data analysis, a certificate often consists of a small face or collection of faces. The attachment theorem quantifies the overhead of retaining all candidate faces generated by a bounded interface. Instead of searching an unrestricted power set, one searches an initial Boolean cube and one additional Boolean cube per attachment.

### 9.3. Dynamic programming

Many dynamic programs are efficient on tree-like structures because each step communicates with the past through a small boundary. Here the attaching face $
ho$ is precisely such a boundary. The $2^k$ subsets represent all binary boundary states. The exact face count is therefore a geometric instance of a familiar parameterized-complexity principle: exponential dependence is confined to boundary width, while dependence on construction length remains linear.

### 9.4. Storage and streaming

The recursive record is streamable. Upon receiving an attachment $(v,\rho)$, one may generate its $2^k$ faces, process them, and discard them before moving to the next attachment if global storage is unnecessary. Disjointness ensures that duplicate detection against old faces is not required. This supports online aggregation of face counts, dimensions, weights, or application-specific statistics.

## 10. Discussion

The proofs rest on three ingredients: a power-set parametrization, freshness of the apex, and additivity over disjoint unions. None can be discarded without changing the conclusion.

If only selected subfaces of $
ho$ are coned, the increment is smaller and is counted by the selected family rather than the full Boolean cube. If $v$ is not fresh, different old subsets can collapse after insertion, and some resulting faces may already exist. If attachments are not tracked as disjoint increments, naive summation can overcount. The recursive $k$-tree hypotheses are exactly what make the clean formula possible.

The result is sharp within the stated construction because it is an equality. Every attachment necessarily creates all $2^k$ cone faces if the attached object is to be a simplicial complex containing the top face $\{v\}\cup\rho$: downward closure forces all of its subfaces containing $v$. Thus $2^k$ is not merely the cost of a convenient implementation; it is the combinatorial content of the attachment itself.

The formula also distinguishes parameter regimes. If $k$ grows with $n$, the factor $2^k$ may dominate. Linear dependence on $n$ should not be confused with uniformly small complexity. The appropriate claim is fixed-parameter linearity: for each fixed width $k$, the face count and explicit enumeration time are linear in the number of vertices or attachment steps.

## 11. Future work

A first direction is to package recursive simplicial $k$-trees as intrinsic inductive objects and prove simultaneously that their realized face families are downward closed, have the expected vertex sets, and satisfy the exact count $2^k(n-k+1)$.

A second direction is to establish a precise correspondence with graph-theoretic $k$-trees. Under that correspondence, cone attachment should match the evolution of clique complexes, connecting simplicial shellings with perfect-elimination orderings.

A third direction is to develop the full $f$-vector and related $h$-vector theory. The increment

$$
x(1+x)^k
$$

already gives the complete cardinality grading and should lead to closed formulas for several standard invariants.

A fourth direction concerns geometric witness selection. If a recursively chosen spanning $k$-tree inside a larger complex can be guaranteed to contain a target-capturing face, then the exact recurrence immediately converts existence into a linear-size certificate.

Finally, a unified treatment of counting conventions would be useful. One may include or omit the empty face, count all faces or only nonempty cliques, and initialize from a $k$-simplex or from a $(k+1)$-clique under differing terminology. Parameterizing the base family makes these variants transparent while preserving the universal $2^k$ attachment increment.

## 12. Conclusion

A fresh vertex attached over a $k$-vertex face creates a family canonically indexed by $k$ independent binary choices. This Boolean-cube correspondence gives exactly $2^k$ new faces. Freshness makes the new family disjoint from all old faces, so repeated attachments obey an additive recurrence.

Starting from a full simplex on $k+1$ vertices and making $s$ attachments yields exactly

$$
2^{k+1}+s2^k=2^k(s+2)
$$

faces, or $2^k(n-k+1)$ in terms of the final vertex count. The result is exponential in interface width but linear in construction length. Its graded form, $x(1+x)^k$, exposes the complete distribution of new face sizes. Together, these formulas provide a precise and reusable account of how local Boolean complexity becomes global linear complexity under recursive acyclic assembly.
