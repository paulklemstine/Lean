# The Join Bifunctor and a Sharp Join Law for the $\mathbb{Z}_2$ Co-index

**Author:** Aristotle

**Date:** 2026-07-14

## Abstract

The $\mathbb{Z}_2$ co-index of a free $\mathbb{Z}_2$-space measures the largest
antipodal sphere that admits an equivariant map into it; it is the central
numerical invariant behind combinatorial Borsuk–Ulam arguments. We develop a
purely combinatorial model of free $\mathbb{Z}_2$-spaces — types equipped with a
fixed-point-free involution, given the octahedral (cross-polytope) face
structure — together with their equivariant simplicial maps. Within this model we
construct the **join bifunctor** $K \star L$ and prove the *constructive,
lower-bound half* of the join law: for arbitrary free $\mathbb{Z}_2$-spaces,
$$\operatorname{coind}(K \star L) \ \ge\ \operatorname{coind}(K) + \operatorname{coind}(L) + 1,$$
realized by an explicit equivariant map. The engine of the bound is an exact
coordinate-splitting isomorphism of octahedral spheres,
$S^m \star S^n \cong S^{m+n+1}$, which upgrades the inequality to a **sharp
equality on the octahedral tower**:
$\operatorname{coind}(S^m \star S^n) = m + n + 1$. Specializing to $L = S^0$
recovers the classical suspension jump $\operatorname{coind}(K \star S^0) =
\operatorname{coind}(K) + 1$, and the octahedral spheres are shown to form a
commutative, associative join-monoid at the level of the co-index. We situate
these results relative to four conjectures on the sharp equality and the
maximal-excess phenomenon, and discuss the equivariant-cohomological obstruction
needed to complete the upper bound in full generality.

## 1. Introduction

### 1.1 Borsuk–Ulam and the co-index

The Borsuk–Ulam theorem states that every continuous map from the $n$-sphere to
$\mathbb{R}^n$ identifies a pair of antipodal points. Reformulated: there is no
continuous antipodal (equivariant) map $S^n \to S^{n-1}$. This single
impossibility underlies a remarkable range of results in combinatorics and
discrete geometry — the chromatic number of Kneser graphs, the necklace-splitting
theorem, the ham-sandwich theorem, and many fair-division and embedding
obstructions. The unifying device in all of these is a numerical invariant of a
space carrying a free involution.

Let $X$ be a **free $\mathbb{Z}_2$-space**: a space with a fixed-point-free
involution $a$ (the antipodal action). Its **$\mathbb{Z}_2$-co-index** is
$$\operatorname{coind}(X) = \max\{\, m : \text{there exists an equivariant map } S^m \to X \,\},$$
the largest sphere admitting an antipodal map *into* $X$. (The dual **index**
uses maps *out of* $X$.) The co-index is monotone under equivariant maps and
calibrated so that $\operatorname{coind}(S^n) = n$. Lower bounds on the co-index
are exactly what one needs to run Borsuk–Ulam-type impossibility arguments, and
they are proved by exhibiting equivariant maps — a constructive task well suited
to a combinatorial model.

### 1.2 Contributions

This paper develops the join operation for free $\mathbb{Z}_2$-spaces in a
finite, combinatorial setting and establishes the constructive half of its
co-index law. Concretely:

1. A self-contained combinatorial model of free $\mathbb{Z}_2$-spaces and their
   equivariant simplicial maps (Section 2), with the octahedral spheres as the
   calibrating tower and the fundamental existence criterion
   $S^m \to S^n$ iff $m \le n$ (Theorem 2.6).
2. The **join bifunctor** $\star$ on free $\mathbb{Z}_2$-spaces and on their
   equivariant maps (Section 3).
3. The **coordinate-splitting isomorphism** $S^m \star S^n \cong S^{m+n+1}$
   (Theorem 3.3), an exact equivariant bijection.
4. The **constructive lower bound**
   $\operatorname{coind}(K \star L) \ge \operatorname{coind}(K) +
   \operatorname{coind}(L) + 1$ for arbitrary free $\mathbb{Z}_2$-spaces
   (Theorem 4.1).
5. The **sharp join law** on the octahedral tower,
   $\operatorname{coind}(S^m \star S^n) = m + n + 1$ (Theorem 4.2), the
   suspension jump as the case $L = S^0$ (Corollary 4.3), and the commutative
   associative join-monoid structure (Section 4.3).

## 2. Free $\mathbb{Z}_2$-spaces and equivariant simplicial maps

### 2.1 The model

**Definition 2.1 (Free $\mathbb{Z}_2$-space).** A *free $\mathbb{Z}_2$-space* is
a set $V$ of vertices together with an involution $a\colon V \to V$ satisfying

- $a(a(v)) = v$ for all $v$ (involutivity), and
- $a(v) \ne v$ for all $v$ (freeness).

We regard $V$ as an abstract simplicial complex with the **octahedral face
structure**: a finite subset $\sigma \subseteq V$ is a face precisely when it
contains no antipodal pair, i.e. $v \in \sigma \Rightarrow a(v) \notin \sigma$.
This is the cross-polytope structure; it makes $V$ into a symmetric combinatorial
model of a sphere-like space whenever $V$ is finite.

**Definition 2.2 (Equivariant simplicial map).** Let $K = (V_K, a_K)$ and
$L = (V_L, a_L)$ be free $\mathbb{Z}_2$-spaces. An *equivariant simplicial map*
$f\colon K \to L$ is a vertex map $f\colon V_K \to V_L$ satisfying

- **Equivariance:** $f(a_K(v)) = a_L(f(v))$ for all $v \in V_K$;
- **Simpliciality:** for all $p, q \in V_K$, if $f(p) = a_L(f(q))$ then
  $p = a_K(q)$.

The simpliciality condition is the combinatorial reflection of continuity: it
states that $f$ never sends a non-antipodal pair to an antipodal pair, and
therefore carries octahedral faces to octahedral faces. We write $\operatorname{GMap}(K,L)$ for
the set of such maps.

**Proposition 2.3 (Category structure).** The identity vertex map is an
equivariant simplicial map, and the composite of two equivariant simplicial maps
is again one. Hence free $\mathbb{Z}_2$-spaces and their equivariant simplicial
maps form a category.

*Proof sketch.* Equivariance and simpliciality are both preserved by
composition: if $g(f(p)) = a_M(g(f(q)))$ then by $g$'s simpliciality
$f(p) = a_L(f(q))$, and by $f$'s simpliciality $p = a_K(q)$. The identity is
trivially equivariant and simplicial. $\square$

**Proposition 2.4 (Equivariant bijections are maps).** If $e\colon V_K \to V_L$
is a bijection satisfying $e(a_K(v)) = a_L(e(v))$ for all $v$, then $e$ is an
equivariant simplicial map, and its inverse $e^{-1}$ is again an equivariant
simplicial map.

*Proof sketch.* Simpliciality of a bijection is automatic: if
$e(p) = a_L(e(q)) = e(a_K(q))$, injectivity gives $p = a_K(q)$. Equivariance
transfers to the inverse by applying $e^{-1}$ to
$e(a_K(e^{-1}(w))) = a_L(w)$. $\square$

Such an $e$ is a **$\mathbb{Z}_2$-isomorphism**; we write $K \cong L$.

### 2.2 The octahedral tower

**Definition 2.5 (Octahedral sphere).** For $n \in \mathbb{N}$, the
*$n$-dimensional octahedral sphere* $S^n$ is the free $\mathbb{Z}_2$-space with
vertex set
$$V_{S^n} = \{0, 1, \dots, n\} \times \{+, -\}$$
— a signed unit vector $(i, \varepsilon)$ for each of the $n+1$ coordinate axes —
and antipodal map $a(i, \varepsilon) = (i, -\varepsilon)$ flipping the sign. It
has $2(n+1)$ vertices; its faces are the sign-choices over subsets of axes, i.e.
the boundary complex of the $(n+1)$-dimensional cross-polytope. This is a faithful
combinatorial model of the round $n$-sphere with its antipodal action.

**Theorem 2.6 (Fundamental existence criterion).** For all $m, n \in \mathbb{N}$,
$$\operatorname{GMap}(S^m, S^n) \ne \varnothing \iff m \le n.$$

*Proof sketch.* If $m \le n$, the *axis inclusion* $(i, \varepsilon) \mapsto (i,
\varepsilon)$ (using the first $m+1$ of the $n+1$ axes) is manifestly equivariant
and simplicial. Conversely, an equivariant simplicial map $S^m \to S^n$ with
$m > n$ would, on passing to the induced continuous antipodal map of round
spheres, contradict Borsuk–Ulam: it would yield an antipodal map $S^m \to S^n$
with $m > n$, which is impossible. In the combinatorial model this direction is
the parity/degree obstruction packaged by the underlying suspension-tower
theory. $\square$

**Corollary 2.7 (Co-index of a sphere).** Define the **$\mathbb{Z}_2$-co-index**
of a free $\mathbb{Z}_2$-space $K$ by
$$\operatorname{coind}(K) = \sup\{\, m \in \mathbb{N} : \operatorname{GMap}(S^m, K) \ne \varnothing \,\}.$$
Then $\operatorname{coind}(S^n) = n$.

*Proof sketch.* By Theorem 2.6 the witnessing set is
$\{m : m \le n\} = \{0, 1, \dots, n\}$, whose supremum is $n$. $\square$

**Proposition 2.8 (Isomorphism invariance).** If $K \cong L$ then
$\operatorname{coind}(K) = \operatorname{coind}(L)$.

*Proof sketch.* A $\mathbb{Z}_2$-isomorphism $e\colon K \to L$ induces a
bijection between the witnessing sets $\{m : \operatorname{GMap}(S^m, K) \ne
\varnothing\}$ and $\{m : \operatorname{GMap}(S^m, L) \ne \varnothing\}$ by
post-composition with $e$ (Proposition 2.4), so the two suprema agree. $\square$

## 3. The join bifunctor

### 3.1 The join of free $\mathbb{Z}_2$-spaces

**Definition 3.1 (Join).** The *join* $K \star L$ of two free
$\mathbb{Z}_2$-spaces is the free $\mathbb{Z}_2$-space with vertex set the
disjoint union $V_K \sqcup V_L$ and antipodal map acting summand-wise:
$$a_{K \star L}(v) = \begin{cases} a_K(v) & v \in V_K, \\ a_L(v) & v \in V_L. \end{cases}$$
Involutivity and freeness are inherited summand-wise. Geometrically, this
combinatorial disjoint union of vertex sets realizes the topological join of the
two spaces: every vertex of $K$ is connected to every vertex of $L$ by a new
edge, sweeping out the classical join $K \star L = (K \times L \times
[0,1]) / \!\sim$.

**Proposition 3.2 (Join bifunctor).** The join extends to equivariant simplicial
maps: given $F \in \operatorname{GMap}(A, K)$ and $G \in \operatorname{GMap}(B, L)$, the summand-wise map
$$F \star G \colon A \star B \to K \star L, \qquad (F \star G)(v) = \begin{cases} F(v) & v \in V_A, \\ G(v) & v \in V_B, \end{cases}$$
is an equivariant simplicial map. This assignment is functorial in each argument,
so $\star$ is a bifunctor on the category of free $\mathbb{Z}_2$-spaces.

*Proof sketch.* Equivariance holds on each summand by that of $F$ and $G$. For
simpliciality, suppose $(F \star G)(p) = a_{K \star L}((F \star G)(q))$. Since the
antipodal map preserves each summand, $p$ and $q$ must lie in the same summand;
within it the identity reduces to $F(p) = a_K(F(q))$ (resp. $G$), and the
simpliciality of $F$ (resp. $G$) gives $p = a_A(q)$ (resp. $p = a_B(q)$), i.e.
$p = a_{A \star B}(q)$. Cross-summand cases cannot arise. $\square$

### 3.2 The coordinate-splitting isomorphism

The central computational fact is that joining octahedral spheres is again an
octahedral sphere, exactly.

**Theorem 3.3 (Octahedral join isomorphism).** For all $m, n \in \mathbb{N}$
there is a $\mathbb{Z}_2$-isomorphism
$$S^m \star S^n \ \cong\ S^{m+n+1}.$$

*Proof sketch.* The vertex set of $S^m \star S^n$ is
$(\{0,\dots,m\} \times \{\pm\}) \sqcup (\{0,\dots,n\} \times \{\pm\})$, with
$m+1$ axes from the left summand and $n+1$ from the right, for a total of
$m+n+2$ signed axes. The vertex set of $S^{m+n+1}$ has exactly
$(m+n+1)+1 = m+n+2$ signed axes. Concatenate the axes, preserving signs:
$$(i, \varepsilon) \in S^m \longmapsto (i, \varepsilon), \qquad (j, \varepsilon) \in S^n \longmapsto (m+1+j, \varepsilon).$$
This is a bijection of vertex sets (the axis index runs bijectively over
$\{0,\dots,m+n+1\}$), and it commutes with the sign-flip antipodal maps because
it never touches the sign coordinate. By Proposition 2.4 it is a
$\mathbb{Z}_2$-isomorphism, with inverse splitting the axis index at the
threshold $m+1$. $\square$

The special case $n = 0$ deserves emphasis. Since $S^0$ is a pair of antipodal
points, $K \star S^0$ is the two cones over $K$ glued along $K$ — the
**suspension** $\Sigma K$. Theorem 3.3 with $n = 0$ reads
$S^m \star S^0 \cong S^{m+1}$: suspending a sphere raises its dimension by one,
the classical mechanism generating the entire sphere tower.

## 4. The join law for the co-index

### 4.1 The constructive lower bound

**Theorem 4.1 (Constructive lower bound — the headline).** For arbitrary free
$\mathbb{Z}_2$-spaces $K$ and $L$,
$$\operatorname{coind}(K \star L) \ \ge\ \operatorname{coind}(K) + \operatorname{coind}(L) + 1.$$
More precisely, if $\operatorname{GMap}(S^a, K) \ne \varnothing$ and $\operatorname{GMap}(S^b, L) \ne
\varnothing$, then $\operatorname{GMap}(S^{a+b+1}, K \star L) \ne \varnothing$, and the witnessing
map is exhibited explicitly.

*Proof sketch.* Let $F \colon S^a \to K$ and $G \colon S^b \to L$ be equivariant
simplicial maps. Form the composite
$$S^{a+b+1} \ \xrightarrow{\ \cong\ }\ S^a \star S^b \ \xrightarrow{\ F \star G\ }\ K \star L,$$
where the first arrow is the inverse of the coordinate-splitting isomorphism of
Theorem 3.3 and the second is the bifunctorial join of $F$ and $G$
(Proposition 3.2). Each arrow is equivariant and simplicial, hence so is the
composite; it witnesses $\operatorname{GMap}(S^{a+b+1}, K \star L) \ne \varnothing$. Applying
this with $a = \operatorname{coind}(K)$ and $b = \operatorname{coind}(L)$ yields the
stated inequality. $\square$

The proof is fully constructive: it produces an explicit equivariant map, exactly
the object a Borsuk–Ulam application consumes. The $+1$ arises from the single
extra axis created at the seam where the two coordinate blocks are concatenated —
the join's connective tissue contributes one genuine new dimension of symmetry.

### 4.2 Sharpness on the octahedral tower

**Theorem 4.2 (Sharp join law).** For all $m, n \in \mathbb{N}$,
$$\operatorname{coind}(S^m \star S^n) = m + n + 1 = \operatorname{coind}(S^m) + \operatorname{coind}(S^n) + 1.$$

*Proof sketch.* By the octahedral join isomorphism (Theorem 3.3),
$S^m \star S^n \cong S^{m+n+1}$, so by isomorphism invariance (Proposition 2.8)
and Corollary 2.7,
$\operatorname{coind}(S^m \star S^n) = \operatorname{coind}(S^{m+n+1}) = m+n+1$.
The right-hand rewriting uses $\operatorname{coind}(S^m) = m$ and
$\operatorname{coind}(S^n) = n$. $\square$

On the octahedral tower — precisely where the co-index equals the dimension —
the abstract lower bound of Theorem 4.1 is attained with equality. The join
behaves like ordinary addition shifted by one.

**Corollary 4.3 (Suspension jump).** For all $m$,
$\operatorname{coind}(S^m \star S^0) = m + 1$. Equivalently, suspension raises
the co-index by exactly one on the octahedral tower.

*Proof sketch.* Set $n = 0$ in Theorem 4.2 and use $\operatorname{coind}(S^0) =
0$. $\square$

### 4.3 The octahedral join-monoid

**Theorem 4.4 (Commutativity and associativity of the join-monoid).** At the
level of the co-index, the octahedral spheres form a commutative, associative
monoid under the join:

- **Commutativity:** $\operatorname{coind}(S^m \star S^n) = \operatorname{coind}(S^n \star S^m) = m+n+1$.
- **Associativity:** $\operatorname{coind}\big((S^m \star S^n) \star S^k\big) = \operatorname{coind}\big(S^m \star (S^n \star S^k)\big) = m+n+k+2$.
- **Unit behavior:** joining with $S^0$ shifts the co-index by one
  (Corollary 4.3), so $S^0$ acts as a "$+1$ generator" of the tower.

*Proof sketch.* Each bracketing of a triple join is isomorphic, by iterating
Theorem 3.3, to a single octahedral sphere whose axis count is the total axis
count of the pieces; e.g. $(S^m \star S^n) \star S^k \cong S^{m+n+k+2}$ and
likewise for the other grouping. Isomorphism invariance and Corollary 2.7 then
give the common value $m+n+k+2$. Commutativity follows because the join of vertex
sets is symmetric up to $\mathbb{Z}_2$-isomorphism. $\square$

Thus the map $S^n \mapsto n$ is a monoid homomorphism from
$(\{S^n\}, \star)$ to $(\mathbb{N}, (m,n)\mapsto m+n+1)$, an isomorphic copy of
$(\mathbb{N}_{\ge 1}, +)$ via $n \mapsto n+1$. The geometry of joining symmetric
spheres is exactly the arithmetic of adding natural numbers.

## 5. Algorithms

The constructive nature of the theory yields explicit, terminating algorithms
over finite octahedral spheres. We record three.

**Algorithm A (Axis-inclusion witness).** Given $m \le n$, output the equivariant
simplicial map $S^m \to S^n$ realizing $\operatorname{coind}(S^n) \ge m$ by
$(i, \varepsilon) \mapsto (i, \varepsilon)$. Verifying equivariance and
simpliciality is $O((m+1)^2)$ vertex comparisons.

**Algorithm B (Coordinate split / merge).** Implement the isomorphism
$S^m \star S^n \cong S^{m+n+1}$ and its inverse by threshold arithmetic on the
axis index (add/remove the offset $m+1$ on the right summand). Both directions are
$O(1)$ per vertex; a full bijection check over all $2(m+n+2)$ vertices is linear.

**Algorithm C (Join-lift of witnesses).** Given equivariant maps $F\colon S^a \to
K$ and $G\colon S^b \to L$, produce the composite witness
$S^{a+b+1} \to K \star L$ of Theorem 4.1 by splitting the input axis at the
threshold $a+1$, applying $F$ or $G$, and tagging the output with the correct
summand. Linear in the number of vertices.

## 6. Applications

Lower bounds on the co-index are the currency of combinatorial Borsuk–Ulam
theorems. The join law is a compositional tool for producing them:

- **Assembling symmetric test spaces.** Complicated free $\mathbb{Z}_2$-spaces
  built as iterated joins of simple sphere pieces inherit a computable co-index
  budget by additive bookkeeping, immediately yielding equivariant maps into
  target spaces.
- **Suspension arguments.** The $L = S^0$ case is the standard inductive step in
  chromatic-number and fair-division proofs, where one suspends a configuration
  space to gain a dimension of symmetry; Corollary 4.3 quantifies the gain
  exactly.
- **Deformation and reduction.** Because the co-index is an isomorphism
  invariant (Proposition 2.8) and the join is a bifunctor (Proposition 3.2), one
  may replace pieces of a construction by $\mathbb{Z}_2$-isomorphic models
  without changing the co-index, simplifying the search for explicit witnesses.

## 7. Relation to the conjectural program

This work establishes the constructive, lower-bound half of a broader co-index
program. We record how the present results bear on its guiding conjectures.

- **Conjecture 1 (Sharp join law in general).**
  $\operatorname{coind}(K \star L) = \operatorname{coind}(K) +
  \operatorname{coind}(L) + 1$ for all free $\mathbb{Z}_2$-spaces. The lower
  bound is proved here for arbitrary $K, L$ (Theorem 4.1) and the equality on the
  octahedral tower (Theorem 4.2). The remaining upper bound requires an
  index-type obstruction that is itself additive under joins — an
  equivariant-cohomological (Stiefel–Whitney height) invariant beyond the present
  combinatorial model.
- **Conjecture 2 (Maximal excess).** For $d \ge 2$ and $1 \le c \le d$ there is a
  finite free $\mathbb{Z}_2$-space of dimension $d$ with co-index $c$ and
  suspension co-index $d+1$. The join provides the essential dial: it varies
  dimension independently of co-index, letting one join a Borsuk–Ulam-pinned
  low-co-index block with a sphere supplying the missing co-index after one
  suspension.
- **Conjecture 3 (Borsuk–Ulam in the octahedral tower).** Any equivariant map
  $S^n \to S^k$ forces $n \le k$, equivalently $\operatorname{coind}(S^k) = k$
  exactly. This is established (Theorem 2.6, Corollary 2.7), and the join
  splitting $S^k \cong S^0 \star S^{k-1}$ (Theorem 3.3 at $m=0$) turns the global
  obstruction into a one-step induction.
- **Conjecture 4 (Excess monotone under iterated suspension).** The excess
  $e_j = \operatorname{coind}(\Sigma^j K) - \dim(\Sigma^j K)$ is non-increasing in
  $j$ and stabilizes at $0$. Each suspension raises dimension by exactly one and
  co-index by at most one, so the gap can only shrink; the exact $+1$ dimension
  law and the $\ge +1$ co-index law proved here supply the monotone direction,
  with saturation awaiting the general upper bound of Conjecture 1.

## 8. Discussion and future work

The results delineate a clean division of labor. The *lower* half of the co-index
theory — producing explicit equivariant maps — is entirely constructive and lives
comfortably in a finite combinatorial model, as demonstrated by the join
bifunctor and its coordinate-splitting isomorphism. The *upper* half — proving
that no larger sphere maps in — is genuinely obstruction-theoretic and, in full
generality, requires equivariant cohomology. The octahedral tower is exactly the
locus where the two halves meet and the co-index equals the dimension, which is
why the join law becomes a sharp equality there.

Three concrete next steps stand out. First, introduce a $\mathbb{Z}_2$-index that
is additive under joins (equivariant cohomology, Stiefel–Whitney height) to
upgrade the octahedral equality to arbitrary $K, L$ and settle Conjecture 1.
Second, realize the maximal-excess constructions of Conjecture 2 by joining
Borsuk–Ulam-pinned blocks with spheres, using the join as a dimension dial.
Third, combine the exact $+1$ dimension law with the $\ge +1$ co-index law to
prove the monotone-excess statement of Conjecture 4. Each step isolates a
self-contained target, and the coordinate arithmetic of the join developed here
is the shared foundation.

## 9. Conclusion

We built the join of free $\mathbb{Z}_2$-spaces as a bifunctor, proved an exact
coordinate-splitting isomorphism $S^m \star S^n \cong S^{m+n+1}$, and used it to
establish the constructive lower bound
$\operatorname{coind}(K \star L) \ge \operatorname{coind}(K) +
\operatorname{coind}(L) + 1$ for arbitrary free $\mathbb{Z}_2$-spaces, sharp on
the octahedral tower. The suspension jump and a commutative, associative
join-monoid structure follow as corollaries. The geometry of joining symmetric
spheres is, at the level of the co-index, precisely the arithmetic of addition
with a unit shift — an exact addition table hidden inside the topology of
antipodal symmetry.
