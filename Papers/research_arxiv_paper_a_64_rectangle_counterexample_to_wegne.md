# Bounded-Fiber Certificates for Rectangle Packing, Piercing, and Recursive Gap Constructions

**Aristotle**  
**July 16, 2026**

## Abstract

For a finite family $\mathcal R$ of axis-parallel rectangles, let $\nu(\mathcal R)$ be the maximum size of a pairwise disjoint subfamily and let $\tau(\mathcal R)$ be the minimum size of a point set meeting every rectangle. We isolate the finite counting certificates underlying a proposed $64$-rectangle violation of the inequality $\tau\leq2\nu-1$. The first certificate shows that a point-triangle-free family, meaning that no point belongs to three distinct indexed members, satisfies $|\mathcal R|\leq2|T|$ for every transversal $T$. The second bounds a selected family by partitioning it into ordered slots of bounded capacity. Four blocks with four capacity-one slots yield an upper packing bound of $16$. Combined with a displayed disjoint $16$-subfamily, these hypotheses certify $\nu=16$ and $\tau\geq32$, hence $2\nu-1=31<32\leq\tau$. We also solve the recursive packing law $a_0=4$ and $a_{r+1}=a_r^2$, obtaining $a_r=4^{2^r}$. Finally, we record the exact comparison $17891/8064<73/32$. The development clarifies what is conditional: the abstract certificates do not supply rectangle coordinates, a $32$-point upper transversal, or a derivation of the linear-program optimum. They instead reduce those geometric and optimization claims to sharply specified finite data.

## 1. Introduction

Packing and piercing are dual themes in discrete geometry. Given a family of sets, packing seeks many mutually compatible objects, while piercing seeks few witnesses meeting all objects. For finite families of axis-parallel rectangles in the plane, the packing number $\nu$ is the largest cardinality of a pairwise disjoint subfamily, and the piercing number $\tau$ is the least number of points required to meet every rectangle.

The elementary inequality $\nu\leq\tau$ follows because one point cannot pierce two disjoint rectangles. A much stronger proposed universal bound was

$$
\tau(\mathcal R)\leq2\nu(\mathcal R)-1.
$$

At $\nu=16$, this predicts $\tau\leq31$. Consequently, a family of $64$ rectangles with exact packing number $16$ and piercing number at least $32$ gives a numerical violation.

The purpose of this paper is to identify the reusable combinatorial core of such a construction. Coordinates and diagrams are useful for creating a family, but the final global estimates can be certified by two maps with bounded fibers. On the piercing side, map each rectangle to a selected transversal point; a depth-two condition bounds every fiber by two. On the packing side, map each selected rectangle to an ordered block-slot cell; geometric incompatibility bounds every fiber by one. Both are instances of the same finite counting principle.

This viewpoint has three advantages. First, it distinguishes the universal combinatorics from the coordinate-specific verification. Second, it makes the exact logical requirements of a counterexample explicit. Third, it extends immediately to recursive horizontal–vertical constructions whose packing numbers obey a squaring law.

The results established here are certificate implications. In particular, no unlisted coordinate realization is inferred merely from the counting statements. A complete geometric instance must still provide endpoint data and verify the hypotheses. Likewise, the rational comparison involving $73/32$ is exact arithmetic, but the optimization value itself requires independent primal and dual certificates.

## 2. Definitions and notation

### 2.1 Indexed finite families

Let $I$ be a finite index set and let $F_i\subseteq X$ for each $i\in I$, where $X$ is an ambient set. Indexing matters: two different indices may represent geometrically equal sets, and cardinalities count indices.

A finite set $T\subseteq X$ is a **transversal** or **piercing set** if

$$
T\cap F_i\neq\varnothing
$$

for every $i\in I$. The **piercing number** is

$$
\tau(\mathcal F)=\min\{|T|:T\subseteq X\text{ is a transversal}\}.
$$

A subfamily indexed by $A\subseteq I$ is **pairwise disjoint** if

$$
F_i\cap F_j=\varnothing
$$

whenever $i,j\in A$ and $i\neq j$. The **packing number** is

$$
\nu(\mathcal F)=\max\{|A|:A\subseteq I\text{ indexes a pairwise disjoint subfamily}\}.
$$

For rectangles, $X=\mathbb R^2$ and every $F_i$ is a closed axis-parallel rectangle $[\ell_i,r_i]\times[b_i,t_i]$ with $\ell_i\leq r_i$ and $b_i\leq t_i$.

### 2.2 Point-triangle-freeness

A finite indexed family is **point-triangle-free** if no point belongs to three distinct indexed members. Equivalently, for every $x\in X$ and all $i,j,k\in I$, if

$$
x\in F_i\cap F_j\cap F_k,
$$

then $i=j$, $i=k$, or $j=k$. Thus every point has incidence depth at most two.

This condition should be distinguished from every graph-theoretic use of the word triangle-free. For rectangles, a finite pairwise-intersecting subfamily has a common point because intervals have the Helly property in each coordinate. Hence the absence of three rectangles through a common point also excludes intersection triangles. The counting theorem below, however, needs only the stated incidence condition and applies in any ambient set.

### 2.3 Slots and capacities

Let $A$ be a finite selected set. An **$m$-slot certificate of capacity $b$** is a map

$$
\sigma:A\to\{1,\ldots,m\}
$$

such that every fiber has size at most $b$:

$$
|\sigma^{-1}(q)|\leq b
$$

for each slot $q$.

A **four-by-four capacity-one certificate** consists of a block label $p(i)\in\{1,2,3,4\}$ and a slot label $q(i)\in\{1,2,3,4\}$ for every selected index $i$, such that at most one selected index has any prescribed label pair $(p,q)$.

The labels need not be intrinsic attributes of all rectangles. It is enough that every admissible selection receives labels satisfying the fiber bounds. In geometric applications, ordered position within a gadget supplies the slot, while the copy of the gadget supplies the block.

## 3. The bounded-fiber principle

### Lemma 3.1. Bounded-fiber counting

Let $A$ and $Q$ be finite sets and let $f:A\to Q$. If $|f^{-1}(q)|\leq c_q$ for every $q\in Q$, then

$$
|A|\leq\sum_{q\in Q}c_q.
$$

In particular, if $|Q|=m$ and all fibers have size at most $b$, then $|A|\leq mb$.

**Proof sketch.** The fibers $f^{-1}(q)$ form a disjoint partition of $A$. Therefore

$$
|A|=\sum_{q\in Q}|f^{-1}(q)|
\leq\sum_{q\in Q}c_q.
$$

The uniform-capacity statement follows by taking $c_q=b$ for all $q$. $\square$

This elementary lemma is the common engine of all subsequent cardinality bounds. The mathematical work lies in constructing a useful map $f$ and proving its fiber capacities.

## 4. Piercing certificates from depth two

### Theorem 4.1. Triangle-Free Transversal Bound

Let $\mathcal F=(F_i)_{i\in I}$ be a finite point-triangle-free indexed family in an arbitrary ambient set $X$. For every finite transversal $T$,

$$
|I|\leq2|T|.
$$

Consequently,

$$
\tau(\mathcal F)\geq\left\lceil\frac{|I|}{2}\right\rceil.
$$

**Proof sketch.** Since $T$ pierces every member, choose for each $i\in I$ a point $f(i)\in T\cap F_i$. If three distinct indices belonged to one fiber $f^{-1}(t)$, then $t$ would lie in three distinct members, contradicting point-triangle-freeness. Every fiber therefore has size at most two. Lemma 3.1 with $Q=T$ and uniform capacity two yields $|I|\leq2|T|$. Minimizing over transversals proves the second assertion. $\square$

### Corollary 4.2. The sixty-four-member bound

Every transversal of a point-triangle-free family of $64$ indexed members has at least $32$ points.

**Proof sketch.** Theorem 4.1 gives $64\leq2|T|$, hence $32\leq|T|$. $\square$

### Remark 4.3. Sharpness

The factor two cannot be improved under point-triangle-freeness alone. A point is allowed to belong to two distinct members, and a family may be partitioned into pairs, each pair pierced by one point. Additional geometric hypotheses would be needed to force a stronger lower bound.

## 5. Packing certificates from ordered slots

### Theorem 5.1. Slot-Capacity Bound

Let $A$ be a finite selection equipped with $m$ ordered slots, each receiving at most $b$ members. Then

$$
|A|\leq mb.
$$

**Proof sketch.** Apply Lemma 3.1 to the slot map. $\square$

### Theorem 5.2. Four-by-Four Packing Bound

Suppose each member of a finite selection $A$ is assigned a block-slot pair

$$
(p(i),q(i))\in\{1,2,3,4\}^2,
$$

and no pair is assigned to more than one member. Then

$$
|A|\leq16.
$$

**Proof sketch.** The label space has $4\cdot4=16$ elements, all of capacity one. Applying Lemma 3.1 gives the claim. $\square$

In a rectangle construction, the theorem is used universally over pairwise disjoint selections. Geometry must prove that two disjointly selectable rectangles can never occupy the same block-slot cell. Once this local fact is established, no global case analysis over all disjoint subfamilies is required.

### Corollary 5.3. Exact packing from a witness

Let $\mathcal F$ be a finite family. Assume every pairwise disjoint subfamily has a four-by-four capacity-one certificate, and assume $\mathcal F$ contains a displayed pairwise disjoint subfamily of size $16$. Then

$$
\nu(\mathcal F)=16.
$$

**Proof sketch.** The displayed subfamily proves $\nu\geq16$. Theorem 5.2, applied to every pairwise disjoint subfamily, proves $\nu\leq16$. $\square$

## 6. The sixty-four-rectangle certificate

### Theorem 6.1. Certified Counterexample Bounds

Let $\mathcal R$ be a family of $64$ axis-parallel rectangles. Suppose:

1. $\mathcal R$ is point-triangle-free;
2. $\mathcal R$ contains a specified pairwise disjoint subfamily of $16$ rectangles; and
3. every pairwise disjoint subfamily of $\mathcal R$ admits a labeling by four blocks and four ordered slots such that each block-slot pair is used at most once.

Then

$$
\nu(\mathcal R)=16
\qquad\text{and}\qquad
\tau(\mathcal R)\geq32.
$$

**Proof sketch.** Corollary 5.3 establishes the exact packing number. Corollary 4.2 establishes the piercing lower bound. $\square$

### Corollary 6.2. Numerical violation

Under the hypotheses of Theorem 6.1,

$$
2\nu(\mathcal R)-1<\tau(\mathcal R).
$$

**Proof sketch.** Since $\nu(\mathcal R)=16$,

$$
2\nu(\mathcal R)-1=2\cdot16-1=31.
$$

Theorem 6.1 gives $\tau(\mathcal R)\geq32$, and $31<32$. $\square$

The conclusion requires only a lower bound on $\tau$. To prove the exact equality $\tau=32$, one must additionally exhibit a transversal of $32$ points. This distinction is important: the inequality is already refuted by $\tau\geq32$, whereas exact evaluation requires an upper certificate.

### 6.1. What a coordinate certificate must contain

For closed rectangles $R_i=[\ell_i,r_i]\times[b_i,t_i]$, the hypotheses can be reduced to finite endpoint comparisons.

* To show two rectangles are disjoint, verify $r_i<\ell_j$, $r_j<\ell_i$, $t_i<b_j$, or $t_j<b_i$.
* To show that three rectangles have no common point, verify that their three horizontal intervals or their three vertical intervals have empty common intersection. For intervals this is equivalent to the maximum lower endpoint exceeding the minimum upper endpoint.
* To validate a slot capacity, show that any two rectangles assigned the same block-slot cell necessarily intersect, so a pairwise disjoint selection cannot contain both.
* To establish $\nu\geq16$, list sixteen indices and check every pair for disjointness.
* To establish $\tau\leq32$, if exact piercing is desired, list thirty-two points and check that each rectangle contains at least one listed point.

Thus the abstract theorem transforms a global geometric claim into a finite certificate consisting of rational or integer coordinates, labels, and order comparisons.

## 7. Recursive horizontal–vertical composition

Suppose a recursive family has packing number $a_r$ at level $r$. A horizontal–vertical composition can produce a squaring law when a packing at the next level is equivalent to choosing compatible packings independently in two directions.

### Theorem 7.1. Squaring Recurrence Closed Form

Let $(a_r)_{r\geq0}$ be a sequence of natural numbers satisfying

$$
a_0=4
$$

and

$$
a_{r+1}=a_r^2
$$

for every $r\geq0$. Then

$$
a_r=4^{2^r}
$$

for every $r\geq0$.

**Proof sketch.** Proceed by induction on $r$. The base case is $a_0=4=4^{2^0}$. Assuming $a_r=4^{2^r}$, compute

$$
a_{r+1}=a_r^2=\left(4^{2^r}\right)^2
=4^{2\cdot2^r}=4^{2^{r+1}}.
$$

This completes the induction. $\square$

The first levels are

$$
a_0=4,
\qquad a_1=16,
\qquad a_2=256,
\qquad a_3=65{,}536.
$$

The theorem is conditional on the exact squaring relation. Establishing that relation for a geometric recursive family requires both a construction of a packing of size $a_r^2$ and an upper certificate excluding larger packings.

### 7.2. Equality structure

The proof of an upper bound by $16$ capacity-one cells also suggests rigidity. Equality forces every cell to contain exactly one selected member. Under recursion, analogous saturation at every internal node may classify maximum packings and lead to a recurrence for their number. This is not needed for the optimum value, but it is a natural structural refinement.

## 8. Point relaxations and rational gap comparisons

For a rectangle $R_i$, introduce a nonnegative variable $x_i$. The point, or clique, relaxation for maximum independent set imposes

$$
\sum_{i:p\in R_i}x_i\leq1
$$

for every point $p\in\mathbb R^2$, and maximizes $\sum_i x_i$. Binary feasible vectors encode pairwise disjoint subfamilies. Fractional vectors may have larger objective value.

For finite axis-parallel rectangle families, clique constraints are equivalent to common-point constraints. Indeed, if rectangles are pairwise intersecting, their horizontal projections are pairwise-intersecting intervals and therefore have a common horizontal coordinate; the same holds vertically. The resulting coordinate pair belongs to every rectangle.

If the relaxation optimum is $L$ and the packing number is $\nu$, the integrality-gap ratio is $L/\nu$. Establishing an exact finite gap normally requires two certificates: a primal fractional rectangle weighting of value $L$, and a dual point weighting of the same value that dominates every rectangle. Weak duality then proves optimality.

### Proposition 8.1. Exact rational improvement

The rational number $73/32$ is strictly larger than $17891/8064$:

$$
\frac{17891}{8064}<\frac{73}{32}.
$$

**Proof sketch.** All denominators are positive, so cross-multiplication is valid. One computes

$$
73\cdot8064=588{,}672
$$

and

$$
17891\cdot32=572{,}512.
$$

Their difference is $16{,}160>0$, proving the strict inequality. Numerically, the ratios are approximately $2.2186$ and $2.28125$. $\square$

This proposition certifies only the comparison. A claim that a particular recursive rectangle family has gap exactly $73/32$ additionally requires the primal and dual optimization data described above.

## 9. Algorithms for checking finite certificates

### 9.1. Triangle-freeness checker

Given rectangle endpoints, enumerate every triple of distinct rectangles. Compute

$$
L_x=\max(\ell_i,\ell_j,\ell_k),
\quad U_x=\min(r_i,r_j,r_k),
$$

and similarly $L_y,U_y$. The triple shares a point exactly when $L_x\leq U_x$ and $L_y\leq U_y$. Reject if any triple shares a point. The running time is $O(n^3)$ and the working space, excluding the input, is $O(1)$.

### 9.2. Disjoint-witness checker

For each of the $\binom{k}{2}$ pairs in a proposed $k$-rectangle witness, test whether their horizontal intervals or vertical intervals are disjoint. This takes $O(k^2)$ time and $O(1)$ auxiliary space.

### 9.3. Block-slot capacity checker

Given a block-slot label for each rectangle and a geometric rule asserting that equal-labeled rectangles intersect, group rectangles by label and check all pairs within each group for intersection. A direct implementation takes $O(n^2)$ time; hashing labels first costs expected $O(n)$ grouping time and then $O(\sum_c n_c^2)$ pair checks.

These algorithms verify supplied certificates. Finding optimal labels, maximum packings, or minimum transversals is a separate search problem and may be computationally difficult.

## 10. Applications and broader interpretation

Bounded-fiber certificates appear whenever local resource limits control a global selection. In scheduling, a slot is a time-frequency cell and capacity expresses interference. In sensor placement, a piercing point is a sensor location and incidence depth bounds how many regions one sensor can cover. In database indexing, rectangles model range queries, while selected points model probes. The proof pattern remains unchanged: map objects to finite resources, bound each fiber, and sum.

The recursive law is also broadly relevant. Systems built by composing two independent copies of a previous stage frequently square an extremal quantity. Solving the recurrence makes the scale transparent and warns that explicit enumeration quickly becomes impossible: level three already has packing scale $65{,}536$. Symmetry and certificates, rather than brute force, become essential.

## 11. Certificate composition as a design principle

The separate estimates suggest a general workflow for constructing extremal examples. First choose a small certificate space $Q$ and prescribe capacities $c_q$. Next design geometric gadgets so that every admissible selection maps into $Q$ without violating those capacities. Finally, produce a witness saturating enough cells to match the upper bound. This reverses the usual order of discovery: rather than drawing many rectangles and later searching for a proof, one begins with the finite ledger that the geometry must realize.

For the four-by-four packing scheme, the ledger is the Cartesian product

$$
Q=\{1,2,3,4\}\times\{1,2,3,4\},
$$

with $c_q=1$ for every $q\in Q$. A maximum certified packing has size $16$ only if every one of the sixteen fibers is occupied. This equality condition is stronger than the inequality itself and can guide the reconstruction of a gadget: any proposed maximum packing must exhibit one representative of each ordered cell.

On the piercing side, the certificate space is not fixed before the transversal is chosen: it is the transversal $T$ itself. Nevertheless, its capacity function is uniform, with $c_t=2$ for all $t\in T$. Equality in $|I|\leq2|T|$ forces every piercing point to be assigned exactly two rectangles. If a $32$-point transversal of a $64$-member family is exhibited, an assignment saturating every point gives an additional audit trail for exactness.

Composition is especially promising when certificates combine as products. If two independent stages have certificate spaces of sizes $m$ and $n$, their product has $mn$ cells. Capacity one then multiplies the corresponding packing bounds. When both stages are copies of the same level, multiplication becomes squaring, explaining structurally why the recurrence $a_{r+1}=a_r^2$ arises. The recurrence is therefore not merely a numerical curiosity: it reflects product structure in the finite ledger.

## 12. Limitations

The certificate theorems are intentionally modular and therefore conditional. They do not provide:

1. endpoint coordinates for a $64$-rectangle realization;
2. the endpoint-order checks needed to verify point-triangle-freeness;
3. the geometric derivation of the four-by-four slot rule;
4. a $32$-point transversal proving $\tau\leq32$; or
5. primal and dual data proving a point-relaxation optimum with ratio $73/32$.

What they do provide is an exact implication: any family supplying the first three geometric certificates has $\nu=16$ and $\tau\geq32$, which suffices for the strict numerical violation. No claim of exact piercing or exact relaxation value follows without the additional upper and dual certificates.

## 13. Future work

The first priority is a compact integer-coordinate realization in which all claims reduce to endpoint-order comparisons. A fully auditable package would include sixty-four rectangles, sixteen disjoint witnesses, four-by-four labels for the packing argument, and thirty-two piercing points if exact equality is sought.

A second direction is to unify packing slots and piercing points in one capacitated incidence matrix. Both proofs count fibers, suggesting a primal-dual interpretation and a composition theorem for horizontal–vertical gadgets.

Third, equality in the slot bound should be analyzed recursively. Saturation of every capacity-one cell may force maximum packings to factor through the composition tree, yielding an explicit count of extremizers.

Finally, symmetric primal and dual recurrences may govern point-relaxation gaps. A natural target is a sequence increasing from the finite level-three value toward $5/2$, with matching dual point weights proving optimality at each level.

## 14. Conclusion

The rectangle problem is governed by a simple but effective abstraction. Point-triangle-freeness turns every transversal point into a bin of capacity two. Ordered block-slot labels turn every admissible packing cell into a bin of capacity one. For sixty-four members, these certificates give

$$
\tau\geq32,
\qquad \nu=16,
$$

provided a sixteen-member disjoint witness is present. The proposed upper bound would give only $31$, so the certificates imply a strict violation.

The same philosophy handles recursive growth: squaring from four yields $4^{2^r}$. It also keeps numerical optimization claims honest by separating exact rational comparisons from the primal and dual evidence needed to establish an optimum. The broader message is methodological: complicated geometry becomes inspectable when its global conclusions are factored through small finite spaces with explicit capacities.
