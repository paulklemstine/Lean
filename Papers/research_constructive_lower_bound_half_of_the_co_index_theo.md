# Extensive Co-Index Laws for Finite Antipodal Composite Systems

**Aristotle**  
**July 15, 2026**

## Abstract

We study finite nonempty systems equipped with a fixed-point-free involution and the complete octahedral simplicial structure, in which a vertex subset is a face exactly when it contains no antipodal pair. The standard $n$-dimensional octahedral sphere has $n+1$ antipodal vertex orbits. The $\mathbb Z_2$ co-index of a system is the largest $n$ for which an equivariant simplicial map from this standard sphere exists. We prove that every finite nonempty system in this model is equivariantly isomorphic to a unique octahedral sphere determined by its orbit count. Consequently, co-index equals the number of antipodal orbits minus one, or equivalently twice the shifted co-index equals the number of vertices. We then establish an exact finite composition law under simplicial join. For systems $K_0,\ldots,K_r$,

$$
\operatorname{coind}(K_0*\cdots*K_r)
=\sum_{i=0}^{r}\operatorname{coind}(K_i)+r.
$$

Thus the shifted invariant $Q(K)=\operatorname{coind}(K)+1$ is extensive under arbitrary finite composition, and it coincides with antipodal orbit count. We give constructive algorithms, complexity bounds, examples, physical interpretations, and a precise discussion of the boundary beyond the complete octahedral model.

## 1. Introduction

Composition laws are central in both topology and physics. A topological construction combines spaces, while an extensive physical observable assigns to a composite the sum of its values on the components. The simplicial join is one of the most basic topological composition operations. For ordinary spheres it satisfies

$$
S^a*S^b\cong S^{a+b+1},
$$

so even at the level of dimension it is additive only after a shift.

This paper develops the corresponding exact law for a class of finite systems with free $\mathbb Z_2$ symmetry. The objects are finite vertex sets partitioned into antipodal pairs, endowed with the maximal simplicial structure compatible with the rule that no face may contain both members of a pair. This restriction is important: it makes the entire complex recoverable from its free involution. Such systems are precisely finite octahedral spheres up to equivariant relabelling.

The invariant of interest is co-index. Informally, it measures the largest standard antipodal sphere that can be mapped equivariantly and simplicially into a target. The principal conclusions are:

1. a finite nonempty complete antipodal system with $q$ vertex orbits has co-index $q-1$;
2. binary join obeys the sharp law

$$
\operatorname{coind}(K*L)
=\operatorname{coind}(K)+\operatorname{coind}(L)+1;
$$

3. arbitrary finite composition obeys

$$
\operatorname{coind}(K_0*\cdots*K_r)
=\sum_{i=0}^{r}\operatorname{coind}(K_i)+r;
$$

4. the shifted quantity

$$
Q(K):=\operatorname{coind}(K)+1
$$

is exactly additive and satisfies $2Q(K)=|V(K)|$.

The proof is elementary once the classification is exposed. The free involution decomposes the vertex set into two-element orbits. Choosing one representative from each orbit identifies the system with a standard cross-polytope boundary. Join is disjoint union at the vertex level, hence it adds orbit counts. The many-body statement then follows by induction.

The result should not be confused with an unrestricted theorem for arbitrary free $\mathbb Z_2$-simplicial complexes. If faces are deleted while the same paired vertex set is retained, orbit count no longer determines the complex and may no longer determine co-index. The exact law proved here belongs to the complete octahedral free-set model.

## 2. Finite antipodal systems

### 2.1 Free involutions

**Definition 2.1 (Finite free antipodal set).** A finite free antipodal set is a finite set $V$ equipped with a map $\alpha:V\to V$ such that, for every $v\in V$,

$$
\alpha(\alpha(v))=v
\quad\text{and}\quad
\alpha(v)\ne v.
$$

We write $-v$ for $\alpha(v)$. The cyclic group $\mathbb Z_2$ acts freely by the identity and the antipodal operation.

The orbits are exactly the pairs $\{v,-v\}$. Since no point is fixed, $|V|$ is even. We denote the orbit count by

$$
q(V):=|V/\mathbb Z_2|=\frac{|V|}{2}.
$$

### 2.2 Complete octahedral face structure

**Definition 2.2 (Complete antipodal system).** A finite complete antipodal system $K$ consists of a finite free antipodal vertex set $V(K)$ together with the simplicial complex whose faces are exactly the subsets $\sigma\subseteq V(K)$ satisfying

$$
\text{there is no }v\in V(K)\text{ for which }\{v,-v\}\subseteq\sigma.
$$

The system is called nonempty when $V(K)\ne\varnothing$.

Every face chooses at most one vertex from each antipodal pair. A maximal face chooses exactly one from each pair, so if $q(K)=q$, every maximal face has $q$ vertices and the geometric dimension is $q-1$.

**Definition 2.3 (Standard octahedral sphere).** For $n\ge 0$, the standard octahedral sphere $O_n$ has vertex set

$$
V(O_n)=\{(i,s):0\le i\le n,\ s\in\{-1,+1\}\},
$$

with antipode $-(i,s)=(i,-s)$. A subset is a face precisely when it contains at most one of $(i,+1)$ and $(i,-1)$ for each $i$. Thus $O_n$ has $n+1$ antipodal orbits, $2(n+1)$ vertices, and dimension $n$.

The cases $O_0$, $O_1$, and $O_2$ are respectively a two-point zero-sphere, a four-cycle, and the boundary of the three-dimensional octahedron.

### 2.3 Equivariant simplicial maps

**Definition 2.4 (Equivariant simplicial map).** Let $K$ and $L$ be complete antipodal systems. An equivariant simplicial map $f:K\to L$ is a vertex map $f:V(K)\to V(L)$ such that

$$
f(-v)=-f(v)
$$

for every vertex $v$, and the image of every face of $K$ is a face of $L$.

In this model, simpliciality has a useful pairwise formulation: if $f(v)=-f(w)$, then $v=-w$. Indeed, a non-antipodal pair $\{v,w\}$ is a face, and its image may not become a forbidden antipodal pair.

**Definition 2.5 ($\mathbb Z_2$ co-index).** For a finite nonempty complete antipodal system $K$, define

$$
\operatorname{coind}(K)
:=\max\{n\in\mathbb N: \text{there exists an equivariant simplicial map }O_n\to K\}.
$$

Finiteness ensures that the maximum is bounded, while nonemptiness ensures that the defining set is nonempty because $O_0$ can be sent onto any chosen antipodal pair.

## 3. Classification by antipodal orbit count

The complete face structure removes all information except the number of antipodal pairs.

**Lemma 3.1 (Orbit-coordinate representation).** Let $K$ be a finite nonempty complete antipodal system with $q$ antipodal orbits. Then there is an equivariant simplicial isomorphism

$$
K\cong O_{q-1}.
$$

**Proof sketch.** Choose one representative $r_i$ from each orbit, indexed by $i\in\{0,\ldots,q-1\}$. Send $r_i$ to $(i,+1)$ and $-r_i$ to $(i,-1)$. This is an equivariant bijection. A subset contains an antipodal pair in $K$ exactly when its image contains both signs of one coordinate in $O_{q-1}$. Hence the bijection and its inverse preserve faces. $\square$

The next lemma identifies maps between standard objects.

**Lemma 3.2 (Standard mapping criterion).** There exists an equivariant simplicial map $O_m\to O_n$ if and only if

$$
m\le n.
$$

**Proof sketch.** If $m\le n$, include the first $m+1$ signed coordinates into the $n+1$ available coordinates. Conversely, consider the $m+1$ source orbit pairs. Equivariance sends each pair to a target pair. Two distinct source pairs cannot be sent to the same target pair: after choosing suitable signs, two non-antipodal source vertices would map to antipodal target vertices, violating simpliciality. Thus source orbits inject into target orbits, so $m+1\le n+1$. $\square$

**Theorem 3.3 (Complete classification of co-index).** Let $K$ be a finite nonempty complete antipodal system with $q(K)$ antipodal vertex orbits. Then

$$
\operatorname{coind}(K)=q(K)-1.
$$

Equivalently,

$$
2\bigl(\operatorname{coind}(K)+1\bigr)=|V(K)|.
$$

**Proof sketch.** By Lemma 3.1, $K$ is equivariantly simplicially isomorphic to $O_{q(K)-1}$. Co-index is invariant under such an isomorphism because maps can be transported in either direction. Lemma 3.2 says that the greatest $m$ admitting a map $O_m\to O_{q(K)-1}$ is $q(K)-1$. Since $|V(K)|=2q(K)$, the cardinality identity follows. $\square$

This theorem shows that co-index is a complete numerical invariant within the present class: two systems are equivariantly simplicially isomorphic if and only if their co-indices agree.

## 4. Join as composition

### 4.1 Definition and elementary properties

**Definition 4.1 (Equivariant simplicial join).** Let $K$ and $L$ be complete antipodal systems. Their join $K*L$ has the disjoint union

$$
V(K*L)=V(K)\sqcup V(L)
$$

as its vertex set. The antipode acts componentwise. A subset is a face when its intersection with $V(K)$ is a face of $K$ and its intersection with $V(L)$ is a face of $L$.

Because each factor has the complete antipodal structure, a subset of the disjoint union is a face exactly when it contains no antipodal pair. Hence $K*L$ is again a complete antipodal system. If both factors are nonempty, so is the join.

**Lemma 4.2 (Vertex and orbit addition).** For finite complete antipodal systems $K$ and $L$,

$$
|V(K*L)|=|V(K)|+|V(L)|
$$

and

$$
q(K*L)=q(K)+q(L).
$$

**Proof sketch.** The vertex set is a disjoint union. Every antipodal orbit remains entirely inside the component from which it came, so the orbit sets also form a disjoint union. $\square$

**Proposition 4.3 (Octahedral join law).** For $m,n\ge 0$,

$$
O_m*O_n\cong O_{m+n+1}
$$

by an equivariant simplicial isomorphism.

**Proof sketch.** The left side has $(m+1)+(n+1)=m+n+2$ antipodal pairs. Relabel the coordinates from the first factor as $0,\ldots,m$ and those from the second as $m+1,\ldots,m+n+1$. The complete face rule is preserved. $\square$

### 4.2 Exact binary composition

**Theorem 4.4 (Sharp binary join law).** Let $K$ and $L$ be finite nonempty complete antipodal systems. Then

$$
\operatorname{coind}(K*L)
=\operatorname{coind}(K)+\operatorname{coind}(L)+1.
$$

**Proof sketch.** Write $q_K=q(K)$ and $q_L=q(L)$. By Lemma 4.2, the join has $q_K+q_L$ orbits. Theorem 3.3 therefore gives

$$
\operatorname{coind}(K*L)=q_K+q_L-1.
$$

Again by Theorem 3.3, $q_K=\operatorname{coind}(K)+1$ and $q_L=\operatorname{coind}(L)+1$. Substitution yields the stated identity. $\square$

There is also a constructive lower-bound interpretation. Maps $O_a\to K$ and $O_b\to L$ can be combined by splitting the $a+b+2$ source coordinates into two blocks, producing a map

$$
O_{a+b+1}\to K*L.
$$

Taking $a=\operatorname{coind}(K)$ and $b=\operatorname{coind}(L)$ gives the lower bound. Classification supplies the matching upper bound because no more source orbit pairs can inject into the target than the target possesses.

**Corollary 4.5 (Extensive shifted co-index).** Define

$$
Q(K):=\operatorname{coind}(K)+1.
$$

Then

$$
Q(K*L)=Q(K)+Q(L),
$$

and

$$
Q(K)=q(K)=\frac{|V(K)|}{2}.
$$

Thus $Q$ simultaneously records shifted co-index, antipodal orbit count, and half the vertex count.

## 5. Arbitrary finite composition

Let $K_0,K_1,\ldots,K_r$ be a nonempty finite sequence of finite nonempty complete antipodal systems. Define their right-associated composite recursively by

$$
C_0=K_0,
$$

and, for a tail sequence, by

$$
K_0*(K_1*(\cdots*K_r)).
$$

Associativity up to canonical equivariant simplicial isomorphism means that the numerical results do not depend on parenthesization.

**Lemma 5.1 (Vertex count for a finite composite).** The composite satisfies

$$
|V(K_0*\cdots*K_r)|=\sum_{i=0}^{r}|V(K_i)|.
$$

**Proof sketch.** Induct on $r$. The case $r=0$ is immediate. At each additional join, Definition 4.1 replaces the vertex set by a disjoint union, and cardinalities add. $\square$

**Theorem 5.2 (Exact finite composition law).** For every finite nonempty sequence $K_0,\ldots,K_r$,

$$
\operatorname{coind}(K_0*\cdots*K_r)
=\sum_{i=0}^{r}\operatorname{coind}(K_i)+r.
$$

**Proof sketch.** Induct on the number of join operations. For one factor, the formula is tautological. Suppose it holds for the tail $K_1*\cdots*K_r$. Apply Theorem 4.4 to $K_0$ and that tail. This adds $\operatorname{coind}(K_0)$ and one additional unit to the inductive formula. The result contains one shift for each of the $r$ join operations. $\square$

**Corollary 5.3 (Many-body extensivity).** For the same systems,

$$
Q(K_0*\cdots*K_r)=\sum_{i=0}^{r}Q(K_i).
$$

**Proof sketch.** Add one to both sides of Theorem 5.2. Since there are $r+1$ factors,

$$
1+r=\sum_{i=0}^{r}1,
$$

which combines with the sum of the co-indices. $\square$

**Corollary 5.4 (Agreement with vertex counting).** Every finite composite satisfies

$$
2Q(K_0*\cdots*K_r)
=|V(K_0*\cdots*K_r)|
=\sum_{i=0}^{r}|V(K_i)|.
$$

**Proof sketch.** Apply Theorem 3.3 to the composite and Lemma 5.1 to its vertex set. Alternatively, use Corollary 5.3 and the factorwise identity $2Q(K_i)=|V(K_i)|$. $\square$

These statements also imply commutativity and associativity at the invariant level. Permuting factors leaves the sum unchanged, and changing parentheses does not affect it.

## 6. Algorithms

### 6.1 Co-index from vertex data

Suppose a system is supplied as an explicit list of vertices together with its free involution, and the complete face condition is guaranteed. Theorem 3.3 yields the following algorithm.

**Algorithm 6.1 (Orbit-count co-index).** Validate that the involution is fixed-point free and partitions the vertices into pairs. Let $N$ be the number of vertices. Return

$$
\frac{N}{2}-1.
$$

If vertices are hashable and the involution is available in constant expected time, validation and orbit enumeration require $O(N)$ time and $O(N)$ auxiliary space. If validity is trusted and only $N$ is needed, the arithmetic itself is $O(1)$.

### 6.2 Co-index of a many-body composite

When each factor is represented only by its co-index, there is no need to construct vertices or faces.

**Algorithm 6.2 (Shifted-sum composition).** Given co-indices $c_0,\ldots,c_r$, compute

$$
T=\sum_{i=0}^{r}(c_i+1)
$$

and return $T-1$ as the composite co-index. The composite vertex count is $2T$.

The algorithm takes $O(r)$ time and $O(1)$ extra space. This is asymptotically preferable to face enumeration. A system with $q$ antipodal pairs has $3^q$ faces, because for each pair a face chooses the positive vertex, the negative vertex, or neither. A join with total orbit count $Q$ therefore has $3^Q$ faces, while its co-index is computed from a linear scan of the factors.

### 6.3 Consistency audit

For datasets containing both vertex counts and claimed co-indices, one can audit the model using

$$
2(c_i+1)=N_i
$$

for every factor. After summing, verify

$$
2\left(\sum_i(c_i+1)\right)=\sum_iN_i.
$$

This detects parity errors, missing antipodal partners, and inconsistent metadata. It does not by itself certify the complete face condition; that structural assumption must be checked separately if faces are explicitly supplied.

## 7. Numerical examples

**Example 7.1 (Three-factor composite).** Suppose the factors have orbit counts $2$, $3$, and $5$. Their co-indices are $1$, $2$, and $4$. The composite orbit count is $10$, its vertex count is $20$, and

$$
\operatorname{coind}(K_0*K_1*K_2)=1+2+4+2=9.
$$

The shifted calculation is

$$
Q=2+3+5=10.
$$

**Example 7.2 (Repeated zero-sphere composition).** Each copy of $O_0$ has co-index $0$ and shifted co-index $1$. The join of $s$ copies has

$$
Q=s,
\qquad
\operatorname{coind}=s-1,
\qquad
|V|=2s.
$$

It is isomorphic to $O_{s-1}$. In particular, two copies form $O_1$, the four-cycle, and three copies form $O_2$, the octahedral two-sphere.

**Example 7.3 (Large factors without face construction).** Let the factor co-indices be $7$, $12$, $0$, and $4$. Then

$$
Q=(7+1)+(12+1)+(0+1)+(4+1)=27.
$$

Therefore the composite has co-index $26$ and $54$ vertices. Its complete face family has $3^{27}$ members, but neither the face family nor the joined vertex structure needs to be generated to compute the invariant.

## 8. Physical interpretation and applications

The binary symmetry may represent reversal of sign, spin inversion, an exchange of two orientations, or another fixed-point-free two-state symmetry. Each orbit is a paired degree of freedom. The complete octahedral face rule says that a compatible configuration may choose at most one state from each opposite pair, with no additional cross-orbit restrictions.

Under join, independent sectors are pooled. The quantity $Q(K)$ counts paired degrees of freedom and is consequently extensive:

$$
Q(\text{composite})=\sum Q(\text{components}).
$$

The co-index itself is one less because it is normalized as a sphere dimension. The shift is analogous to replacing a zero-based coordinate label by the number of available coordinates. This interpretation clarifies why the extra unit in the join law is universal rather than interaction-dependent.

Three practical uses follow.

First, **modular calculation**: a large composite can be analyzed from factor summaries. Second, **consistency checking**: topological, orbit, and vertex descriptions must satisfy the same arithmetic identity. Third, **symmetry-aware coarse graining**: any equivariant relabelling leaves $Q$ unchanged, so only the number of paired sectors matters within this model.

The result is relevant to physical bookkeeping, but it does not assert that all physical interactions are captured by a complete octahedral complex. Additional compatibility constraints correspond to deleting faces, which may introduce genuinely new topology.

## 9. Scope and failure boundary

The complete face condition is mathematically decisive. Given only a free involution on vertices, one can construct many invariant simplicial complexes by selecting different collections of antipodal-pair-free faces. Those complexes can share the same vertex orbit count while differing in connectivity, dimension, and equivariant mapping obstructions.

The classification proof uses completeness in two places. First, any equivariant bijection between paired vertex sets is automatically a simplicial isomorphism because faces are characterized solely by avoidance of antipodal pairs. Second, join remains completely described by disjoint union of orbit sets. Without completeness, an equivariant bijection need not preserve faces, and orbit counting need not determine co-index.

Nonemptiness is also explicit. For $q\ge1$, the formula $\operatorname{coind}=q-1$ is a natural number and the system admits a map from $O_0$. At $q=0$, this normalization degenerates. All composition theorems here therefore assume every factor has at least one antipodal orbit.

Finally, the results concern finite systems. Infinite free antipodal sets require cardinal and supremum considerations not represented by the finite formulas or algorithms.

## 10. Discussion

The many-body theorem is more than repeated notation for the binary case. It confirms that all closure conditions—finiteness, nonemptiness, freeness, and completeness—persist through arbitrarily many joins, and it identifies the exact accumulated shift. The formula has two equivalent forms:

$$
\operatorname{coind}(K_0*\cdots*K_r)
=\sum_i\operatorname{coind}(K_i)+r
$$

and

$$
Q(K_0*\cdots*K_r)=\sum_iQ(K_i).
$$

The second is conceptually preferable. It reveals that the natural invariant is not dimension itself but the number of antipodal axes represented by that dimension. In categorical language, $Q$ is a homomorphism from join composition to addition of positive integers. In combinatorial language, it is orbit count. In geometric language, it is one plus the dimension of the classified octahedral sphere.

This convergence explains the strength and limitation of the theory. Exactness arises because the chosen category has no hidden face data. Once richer complexes are allowed, co-index can encode information beyond orbit count, and the simple extensive law becomes a question rather than an identity.

## 11. Future work

Several extensions are natural. The join monoid of isomorphism classes can be studied through its group completion, with $Q$ as a candidate universal additive invariant. Equivariant embedding counts should refine the scalar law: injections of source orbits into a disjoint union split by target component, suggesting binomial convolution formulas. A species-level treatment could retain automorphism information and expose the hyperoctahedral symmetry groups generated by orbit permutations and sign reversals.

The most important boundary problem is to identify minimal face deletions that destroy classification by orbit count or strict additivity under join. Such examples would quantify exactly how additional interaction constraints alter the extensive law. Stable behavior under iterated suspension and relationships with equivariant connectivity also remain to be explored for arbitrary finite free $\mathbb Z_2$-simplicial complexes.

## 12. Conclusion

Finite nonempty complete antipodal systems admit a full classification by the number of vertex orbits. Their $\mathbb Z_2$ co-index is orbit count minus one, and simplicial join adds orbit counts. Consequently, arbitrary finite composition satisfies the exact law

$$
\operatorname{coind}(K_0*\cdots*K_r)
=\sum_{i=0}^{r}\operatorname{coind}(K_i)+r.
$$

After the canonical shift, co-index becomes an extensive quantity:

$$
\boxed{
Q(K_0*\cdots*K_r)
=\sum_{i=0}^{r}Q(K_i),
\qquad
Q(K)=\operatorname{coind}(K)+1
=\frac{|V(K)|}{2}.
}
$$

The theorem unifies equivariant topology, antipodal orbit combinatorics, and additive many-body bookkeeping. Within the complete octahedral model, these are not merely compatible descriptions; they are the same invariant viewed from three directions.
