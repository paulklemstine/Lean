# Finite Join Laws and Constructive Lower Bounds for the $\mathbb Z_2$ Co-Index

**Aristotle**  
**July 15, 2026**

## Abstract

We develop a finite multi-join calculus for octahedral spheres equipped with their antipodal $\mathbb Z_2$-actions. The central structural fact is that the join of octahedral spheres of dimensions $m$ and $n$ is antipodally isomorphic to the octahedral sphere of dimension $m+n+1$. Iteration gives an exact formula for every nonempty finite family: the join of factors of dimensions $d_0,\ldots,d_{p-1}$ has $\mathbb Z_2$ co-index $\sum_i d_i+p-1$. This proves invariance under permutation of the factors and recovers repeated suspension by the zero-sphere. We also treat arbitrary free $\mathbb Z_2$-spaces constructively. If an equivariant map from the octahedral $a$-sphere to $K$ exists, then joining $p$ copies of that map produces an equivariant map from the octahedral sphere of dimension $p(a+1)-1$ to the $p$-fold self-join of $K$. Hence the latter has co-index at least $p(a+1)-1$. For octahedral spheres the bound is sharp. We give inductive proofs, one-pass computational algorithms, numerical examples, and applications to suspension towers and modular construction of equivariant witnesses.

## 1. Introduction

The topological join is an operation that combines two spaces while introducing a new interpolation parameter. Its familiar dimension rule,

$$
\dim(X*Y)=\dim X+\dim Y+1,
$$

is particularly transparent for spheres. In equivariant topology the join has an additional advantage: equivariant maps can themselves be joined. It therefore serves both as a geometric constructor and as a mechanism for amplifying certificates of symmetry.

This paper studies that mechanism for spaces carrying a free action of $\mathbb Z_2$. The standard models are octahedral spheres, the boundaries of cross-polytopes with their antipodal action. Their combinatorial nature allows the join operation to be described directly at the level of antipodal coordinate pairs. The resulting binary identity can be iterated without invoking a new obstruction argument for each number of factors.

Our first result is an exact multi-join law. For a nonempty family of octahedral spheres $O_{d_0},\ldots,O_{d_{p-1}}$, the iterated join is antipodally isomorphic to $O_D$, where

$$
D=\sum_{i=0}^{p-1}d_i+p-1.
$$

Since $O_D$ has co-index $D$, this determines the co-index exactly. The expression is symmetric in the factor dimensions, so permutation invariance follows immediately. Setting some or all dimensions to zero recovers the suspension tower and the classical identity that a $p$-fold join of zero-spheres is a $(p-1)$-sphere.

Our second result isolates the constructive lower-bound content. Suppose a free $\mathbb Z_2$-space $K$ receives an equivariant map from $O_a$. Joining $p$ copies of this map yields a concrete equivariant witness

$$
O_{p(a+1)-1}\longrightarrow K^{*p}.
$$

Thus $\operatorname{coind}(K^{*p})\ge p(a+1)-1$. When $K=O_a$, the exact multi-join law shows equality. This separates two roles that are often intertwined: witness construction supplies the lower bound, while knowledge of the target’s octahedral type supplies sharpness.

The paper is organized as follows. Section 2 defines free $\mathbb Z_2$-spaces, equivariant maps, octahedral spheres, co-index, and joins. Section 3 establishes the octahedral join calculus. Section 4 proves the finite multi-join theorem and permutation invariance. Section 5 recovers suspension. Section 6 proves the constructive self-join bound and its sharp octahedral specialization. Sections 7 and 8 present algorithms and applications. Sections 9 and 10 discuss limitations and future directions.

## 2. Definitions and basic principles

### 2.1. Free $\mathbb Z_2$-spaces

A **$\mathbb Z_2$-space** is a space $K$ equipped with an involution $\tau_K:K\to K$, meaning that $\tau_K(\tau_K(x))=x$ for every $x\in K$. We write $-x$ for $\tau_K(x)$. The action is **free** if $-x\neq x$ for every $x\in K$.

A map $f:K\to L$ between $\mathbb Z_2$-spaces is **equivariant** if it commutes with the involutions:

$$
f(-x)=-f(x)
$$

for all $x\in K$. An equivariant isomorphism is a bijective equivariant map whose inverse is equivariant. In the finite combinatorial setting used here, such an isomorphism is an antipode-preserving vertex bijection compatible with the relevant complexes.

### 2.2. Octahedral spheres

For $n\ge 0$, the **octahedral $n$-sphere** $O_n$ is the boundary complex of the $(n+1)$-dimensional cross-polytope. Its vertex set is

$$
V(O_n)=\{+e_0,-e_0,\ldots,+e_n,-e_n\},
$$

and the antipodal action exchanges $+e_i$ with $-e_i$. A face chooses at most one vertex from each antipodal pair. The realization of this complex is homeomorphic to $S^n$ with the antipodal action. The first cases are $O_0=S^0$, a pair of points; $O_1$, the boundary of a square; and $O_2$, the boundary of an octahedron.

### 2.3. Co-index

The **$\mathbb Z_2$ co-index** of a free $\mathbb Z_2$-space $K$ is the largest nonnegative integer $n$ for which there exists an equivariant map $O_n\to K$:

$$
\operatorname{coind}(K)
=
\max\{n\in\mathbb N: O_n\longrightarrow K\text{ equivariantly}\}.
$$

Where no finite maximum is assumed, the assertion $\operatorname{coind}(K)\ge n$ means precisely that such a map exists. The arguments below primarily construct these witnesses and therefore remain meaningful in this order-theoretic reading.

We use two basic principles.

**Proposition 2.1 (Equivariant invariance).** If $K$ and $L$ are equivariantly isomorphic, then

$$
\operatorname{coind}(K)=\operatorname{coind}(L).
$$

**Proof sketch.** Compose an equivariant map $O_n\to K$ with the isomorphism $K\to L$ to transfer every witness from $K$ to $L$. Compose with the inverse to transfer witnesses in the opposite direction. The same integers are therefore admissible for both spaces. $\square$

**Proposition 2.2 (Normalization on octahedral spheres).** For every $n\ge 0$,

$$
\operatorname{coind}(O_n)=n.
$$

**Proof sketch.** The identity map gives the lower bound. The matching upper bound is the standard antipodal obstruction: no equivariant map from a strictly higher-dimensional antipodal sphere to $S^n$ exists. Thus the largest admissible index is $n$. $\square$

### 2.4. The join

The **join** $K*L$ is obtained from $K\times L\times[0,1]$ by identifying all triples with the same $K$-coordinate at $t=0$ and all triples with the same $L$-coordinate at $t=1$. A point is denoted $[x,y,t]$. If $K$ and $L$ carry involutions, then

$$
-[x,y,t]=[-x,-y,t]
$$

defines an involution on $K*L$. It is free when the original actions are free.

Given equivariant maps $f:K\to K'$ and $g:L\to L'$, their **join map** is

$$
(f*g)([x,y,t])=[f(x),g(y),t].
$$

It is equivariant because

$$
(f*g)(-[x,y,t])=[f(-x),g(-y),t]=[-f(x),-g(y),t]=-(f*g)([x,y,t]).
$$

This functoriality is the engine of the constructive lower bounds.

We define the right-associated $p$-fold self-join recursively. For $p\ge 1$,

$$
K^{*1}=K,
\qquad
K^{*(p+1)}=K*K^{*p}.
$$

Associativity up to canonical equivariant isomorphism ensures that the chosen parenthesization does not alter the resulting co-index.

## 3. The octahedral join calculus

The pivotal structural statement is closure of octahedral spheres under joins.

**Theorem 3.1 (Binary Octahedral Join Theorem).** For all $m,n\ge 0$, there is an equivariant isomorphism

$$
O_m*O_n\cong O_{m+n+1}.
$$

**Proof sketch.** The complex $O_m$ has $m+1$ antipodal vertex pairs, and $O_n$ has $n+1$. In the simplicial join the vertex sets are taken disjointly, while a face is the union of a face from each factor. Hence a face of $O_m*O_n$ selects at most one vertex from each of the combined

$$
(m+1)+(n+1)=m+n+2
$$

antipodal pairs. This is exactly the face rule for $O_{m+n+1}$. Map the first block of pairs to coordinates $0,\ldots,m$ and the second block to coordinates $m+1,\ldots,m+n+1$. This gives a bijection on vertices, preserves faces, and sends each negative vertex to the negative of its image. The inverse block decomposition has the same properties. $\square$

The binary theorem has an immediate co-index consequence.

**Corollary 3.2 (Sharp Binary Join Law).** For all $m,n\ge 0$,

$$
\operatorname{coind}(O_m*O_n)=m+n+1.
$$

**Proof sketch.** Apply equivariant invariance to Theorem 3.1 and then use normalization on $O_{m+n+1}$. $\square$

It is useful to abstract the mechanism. Say that a free $\mathbb Z_2$-space $K$ has **octahedral type $n$** if $K$ is equivariantly isomorphic to $O_n$. Three rules constitute the octahedral calculus:

1. $O_n$ has octahedral type $n$.
2. A space of octahedral type $n$ has co-index $n$.
3. If $K$ has octahedral type $m$ and $L$ has octahedral type $n$, then $K*L$ has octahedral type $m+n+1$.

The third rule follows by joining the two given equivariant isomorphisms and then applying Theorem 3.1. This calculus propagates one known upper-bound theorem—normalization on octahedral spheres—through arbitrarily many joins.

## 4. Finite multi-joins

Let $d_0,\ldots,d_{p-1}$ be nonnegative integers, where $p\ge 1$. Define the right-associated iterated join

$$
J(d_0,\ldots,d_{p-1})
=
O_{d_0}*(O_{d_1}*(\cdots*O_{d_{p-1}})).
$$

**Theorem 4.1 (Finite Octahedral Multi-Join Theorem).** The iterated join $J(d_0,\ldots,d_{p-1})$ is equivariantly isomorphic to

$$
O_D,
\qquad
D=\sum_{i=0}^{p-1}d_i+p-1.
$$

Consequently,

$$
\operatorname{coind}(J(d_0,\ldots,d_{p-1}))
=
\sum_{i=0}^{p-1}d_i+p-1.
$$

**Proof sketch.** Induct on $p$. For $p=1$, the space is $O_{d_0}$ and $D=d_0$. Suppose the claim holds for the final $p-1$ factors. Their join has octahedral type

$$
D'=\sum_{i=1}^{p-1}d_i+p-2.
$$

Joining $O_{d_0}$ to that sphere and using the binary theorem gives octahedral type

$$
d_0+D'+1
=d_0+\sum_{i=1}^{p-1}d_i+p-2+1
=\sum_{i=0}^{p-1}d_i+p-1.
$$

The co-index formula follows from equivariant invariance and normalization. $\square$

The theorem may also be understood by counting antipodal coordinate pairs. Factor $O_{d_i}$ contributes $d_i+1$ pairs. The total number of pairs is $\sum_i(d_i+1)=\sum_i d_i+p$. An octahedral sphere with that many pairs has dimension one less, namely $\sum_i d_i+p-1$.

**Corollary 4.2 (Permutation Invariance).** If $\sigma$ is any permutation of $\{0,\ldots,p-1\}$, then

$$
\operatorname{coind}(J(d_0,\ldots,d_{p-1}))
=
\operatorname{coind}(J(d_{\sigma(0)},\ldots,d_{\sigma(p-1)})).
$$

**Proof sketch.** Both values equal the sum of the same dimensions plus $p-1$. Addition is commutative, and a permutation preserves the number of factors. $\square$

This conclusion concerns more than the numerical invariant: Theorem 4.1 identifies every ordering with the same $O_D$. Thus any two orderings are equivariantly isomorphic through their common octahedral model.

**Example 4.3.** For dimensions $(2,0,3,1)$,

$$
D=2+0+3+1+4-1=9.
$$

Every ordering and every standard association of these four factors has co-index $9$.

## 5. Suspension towers

The suspension $\Sigma K$ of a space $K$ is naturally its join with $S^0$. Since $S^0=O_0$, repeated suspension is a specialization of the multi-join law.

**Theorem 5.1 (Octahedral Suspension Tower).** For $n,k\ge 0$, joining $O_n$ with $k$ copies of $O_0$ gives an octahedral sphere of dimension $n+k$. In particular,

$$
\operatorname{coind}(O_n*\underbrace{O_0*\cdots*O_0}_{k\text{ copies}})=n+k.
$$

**Proof sketch.** Apply Theorem 4.1 to $k+1$ factors with dimensions $n,0,\ldots,0$. Their dimension sum is $n$, and the number of joins is $k$. $\square$

**Corollary 5.2 (Repeated Zero-Sphere Join).** For every $p\ge 1$,

$$
\underbrace{O_0*\cdots*O_0}_{p\text{ factors}}
\cong O_{p-1},
$$

and its co-index is $p-1$.

**Proof sketch.** Set $n=0$ and $k=p-1$ in Theorem 5.1. $\square$

The first few stages are $O_0$, $O_1$, $O_2$, and $O_3$. Geometrically these are two points, a circle, a two-sphere, and a three-sphere, each carrying its antipodal symmetry.

## 6. Constructive lower bounds for arbitrary self-joins

We now leave the octahedral tower. Let $K$ be an arbitrary free $\mathbb Z_2$-space, and assume that an equivariant witness

$$
f:O_a\longrightarrow K
$$

is given. The join operation combines copies of $f$.

**Lemma 6.1 (Join of Witnesses).** If equivariant maps $f:O_a\to K$ and $g:O_b\to L$ exist, then there is an equivariant map

$$
O_{a+b+1}\longrightarrow K*L.
$$

**Proof sketch.** The join map $f*g:O_a*O_b\to K*L$ is equivariant. Precompose it with the inverse of the equivariant isomorphism $O_a*O_b\cong O_{a+b+1}$ from Theorem 3.1. $\square$

**Theorem 6.2 (Constructive Self-Join Lower Bound).** Let $p\ge 1$. If there is an equivariant map $O_a\to K$, then there is an equivariant map

$$
O_{p(a+1)-1}\longrightarrow K^{*p}.
$$

Consequently,

$$
\operatorname{coind}(K^{*p})\ge p(a+1)-1.
$$

**Proof sketch.** Induct on $p$. For $p=1$, the required source dimension is $1(a+1)-1=a$, so the given map is the desired witness. Assume a witness

$$
O_{p(a+1)-1}\longrightarrow K^{*p}
$$

has been constructed. Join it with the original map $O_a\to K$. Lemma 6.1 produces a map from an octahedral sphere of dimension

$$
a+\bigl(p(a+1)-1\bigr)+1
=(p+1)(a+1)-1
$$

into $K*K^{*p}=K^{*(p+1)}$. This closes the induction. $\square$

The proof is algorithmic: retain the original witness, recursively join it to the current witness, and relabel the source through the binary octahedral isomorphism. It requires $p-1$ join operations.

A shifted notation clarifies the growth law. Define the certified shifted co-index $c=a+1$. The theorem states that the $p$-fold self-join has a certificate of shifted size at least $pc$:

$$
\operatorname{coind}(K^{*p})+1\ge p(a+1).
$$

Thus repeated joining linearizes after the natural shift by one.

## 7. Sharpness for octahedral self-joins

For arbitrary $K$, Theorem 6.2 is only a lower bound: the target may admit maps from still larger octahedral spheres. For octahedral $K$, its exact type supplies the matching upper bound.

**Theorem 7.1 (Sharp Octahedral Self-Join Law).** For all $a\ge 0$ and $p\ge 1$,

$$
O_a^{*p}\cong O_{p(a+1)-1}
$$

equivariantly, and therefore

$$
\operatorname{coind}(O_a^{*p})=p(a+1)-1.
$$

**Proof sketch.** Apply Theorem 4.1 to $p$ factors, all of dimension $a$. The sum of dimensions is $pa$, and there are $p-1$ joins, so the resulting dimension is

$$
pa+p-1=p(a+1)-1.
$$

Normalization on octahedral spheres gives the co-index equality. $\square$

**Corollary 7.2 (Zero-Sphere Power).** For every $p\ge 1$,

$$
\operatorname{coind}(O_0^{*p})=p-1.
$$

**Proof sketch.** Substitute $a=0$ in Theorem 7.1. $\square$

**Example 7.3.** With $a=2$ and $p=4$,

$$
\operatorname{coind}(O_2^{*4})=4(2+1)-1=11.
$$

**Example 7.4.** With $a=1$ and $p=5$,

$$
\operatorname{coind}(O_1^{*5})=5(1+1)-1=9.
$$

The lower bound from Theorem 6.2 reaches these values exactly because the targets are themselves identified with the corresponding octahedral spheres.

## 8. Algorithms and numerical realization

The formulas support simple computational procedures. These algorithms calculate the theorem’s numerical consequences; they do not replace the geometric hypotheses.

### 8.1. Exact co-index of a finite octahedral join

Given a nonempty list $(d_0,\ldots,d_{p-1})$ of nonnegative integers, accumulate its sum $S$ and length $p$, then return $S+p-1$.

**Correctness.** Theorem 4.1 states exactly that this value is the co-index.

**Complexity.** A one-pass implementation takes $O(p)$ time and $O(1)$ auxiliary space. If the sum and length are already available, evaluation is $O(1)$.

### 8.2. Iterated self-join certificate

Given a certified source dimension $a$ and a positive repetition count $p$, return

$$
B=p(a+1)-1.
$$

**Correctness.** Theorem 6.2 constructs an equivariant map $O_B\to K^{*p}$. If $K=O_a$, Theorem 7.1 further states that $B$ is exact.

**Complexity.** The closed-form numerical computation is $O(1)$ in unit-cost arithmetic. Constructing the witness recursively uses $p-1$ join steps; the concrete data size depends on the representation of maps and complexes.

### 8.3. Permutation audit

For a collection of reordered dimension lists, compute the pair consisting of total sum and length for each. Equal pairs imply equal co-index values by Theorem 4.1. When every list is a permutation of a fixed list, equality is automatic.

**Correctness.** The output co-index depends only on those two statistics.

**Complexity.** Auditing $q$ lists of length $p$ takes $O(qp)$ time and $O(q)$ output space, or constant auxiliary space if results are streamed.

## 9. Applications and interpretation

### 9.1. Modular equivariant constructions

Suppose several components are understood through octahedral witnesses. The join-of-witnesses lemma combines them without redesigning an equivariant map globally. For maps $O_{a_i}\to K_i$, repeated joining gives

$$
O_{\sum_i a_i+p-1}\longrightarrow K_0*\cdots*K_{p-1}.
$$

Thus local certificates compose into a global certificate, with completely explicit dimension accounting.

### 9.2. Suspension bookkeeping

Repeated suspension occurs throughout topology. Theorem 5.1 shows that on octahedral models every suspension raises co-index exactly once. It therefore provides a direct bookkeeping rule for towers formed by successively adjoining two antipodal cone points.

### 9.3. Symmetric combinatorial models

Cross-polytope boundaries are finite complexes, so the formulas apply naturally to combinatorial constructions carrying sign-reversal symmetry. Counting antipodal coordinate pairs gives an elementary explanation of the dimension formula and can guide implementations that build joins from disjoint vertex blocks.

### 9.4. Separation of construction and obstruction

The theory separates lower and upper bounds cleanly. Functoriality of joins constructs maps and therefore lower bounds. Exact octahedral identification, together with the antipodal obstruction embodied in $\operatorname{coind}(O_n)=n$, gives upper bounds. For arbitrary targets, only the first part is automatic. This distinction prevents an unwarranted equality claim when a target contains more equivariant complexity than the exhibited witness detects.

## 10. Discussion, limitations, and future work

The multi-join law is exact because octahedral spheres form a class closed under joins. Their shifted dimensions $d+1$ count antipodal coordinate pairs, and joining concatenates those pairs. Consequently,

$$
(D+1)=\sum_{i=0}^{p-1}(d_i+1),
$$

which is equivalent to $D=\sum_i d_i+p-1$. This shifted-additive viewpoint unifies the binary law, the suspension tower, and repeated self-joins.

Several limitations should be explicit. First, the exact equality for arbitrary $K$ does not follow from a single witness $O_a\to K$; only a lower bound follows. A matching upper bound requires additional obstruction theory or a structural classification of $K^{*p}$. Second, the present treatment concerns nonempty finite joins. Infinite joins require choices of topology, convergence, and an appropriate extension of co-index. Third, the octahedral models are especially rigid; analogous formulas for other group actions may involve representation dimensions or different normalization shifts.

Natural future work is to determine when the constructive lower bound

$$
\operatorname{coind}(K^{*p})\ge p(\operatorname{coind}(K)+1)-1
$$

is sharp, and to quantify any maximal excess above it. Another direction is a heterogeneous version for arbitrary spaces $K_i$, beginning with witnesses $O_{a_i}\to K_i$ and studying conditions for equality in

$$
\operatorname{coind}(K_0*\cdots*K_{p-1})
\ge
\sum_i a_i+p-1.
$$

Further questions include extensions from $\mathbb Z_2$ to other finite groups, algorithmic construction of explicit simplicial maps, and applications where joins encode combined combinatorial constraints.

### 10.1. Further structural consequences

The same induction also yields a heterogeneous constructive statement. Suppose that, for each $i$ with $0\le i<p$, an equivariant map $O_{a_i}\to K_i$ is given. Joining all maps produces an equivariant map

$$
O_{\sum_i a_i+p-1}\longrightarrow K_0*\cdots*K_{p-1}.
$$

Indeed, the joined source is octahedral by Theorem 4.1, while functoriality joins the maps on the target side. Therefore

$$
\operatorname{coind}(K_0*\cdots*K_{p-1})\ge \sum_i a_i+p-1.
$$

This formulation shows that self-joins are not essential to the construction; they merely turn the heterogeneous sum into the closed expression $p(a+1)-1$. It also suggests a practical modular workflow: certify each component independently, concatenate the certificates through joins, and defer any global upper-bound question until after construction.

A second consequence concerns grouping. Partition the factors into blocks, compute the octahedral type of each block, and then join the block results. If block $B_j$ contains dimensions indexed by a set of size $q_j$, its type is $\sum_{i\in B_j}d_i+q_j-1$. Joining $s$ blocks adds $s-1$, and since $\sum_j(q_j-1)+(s-1)=p-1$, the final dimension is unchanged. This directly explains parenthesization invariance at the level of the dimension formula.

### 10.2. Reproducible numerical checks

Small numerical tables provide useful sanity checks. For equal factors, the first rows of the sharp formula are

$$
\begin{array}{c|cccc}
a\backslash p & 1&2&3&4\\ \hline
0&0&1&2&3\\
1&1&3&5&7\\
2&2&5&8&11\\
3&3&7&11&15
\end{array}
$$

Each row is an arithmetic progression of common difference $a+1$, reflecting that one additional copy contributes its $a$ dimensions and one new join dimension. Each column is also an arithmetic progression: increasing the factor dimension by one raises the result by $p$. These patterns are direct consequences of $p(a+1)-1$ and offer quick checks for implementations.

## 11. Conclusion

The join operation turns equivariant information into reusable structure. For octahedral spheres it obeys the exact rule

$$
O_m*O_n\cong O_{m+n+1},
$$

and induction converts this binary identity into a complete finite calculus:

$$
\operatorname{coind}(O_{d_0}*\cdots*O_{d_{p-1}})
=
\sum_i d_i+p-1.
$$

Permutation invariance and suspension are immediate specializations. For an arbitrary free $\mathbb Z_2$-space, any witness $O_a\to K$ can be joined with itself to produce

$$
O_{p(a+1)-1}\to K^{*p},
$$

establishing a constructive lower bound. On the octahedral tower this bound is exact. The resulting framework reduces a broad family of iterated equivariant constructions to one structural isomorphism, one functorial operation, and transparent arithmetic.