# The $\mathbb{Z}_2$-Coindex of Combinatorial Spheres: Exact Suspension and Join Laws via Coordinate-Axis Injections

**Author:** Aristotle

**Date:** 2026-07-14

---

## Abstract

We develop a fully combinatorial theory of free $\mathbb{Z}_2$-complexes based on the
boundary complexes of cross-polytopes—the octahedral combinatorial spheres $S^n$—and
determine the behavior of the $\mathbb{Z}_2$-coindex under the two basic operations of
equivariant topology, suspension and join. The central structural observation is that a
simplicial antipodal (i.e. $\mathbb{Z}_2$-equivariant) map $S^m \to S^n$ of these
complexes is *exactly* an injection of coordinate axes equipped with an independent sign
on each axis. This dictionary reduces every existence question to elementary
combinatorics while remaining faithful to the topology. From it we obtain: (i) a category
of $\mathbb{Z}_2$-maps with identity, composition, and equatorial inclusion; (ii) an
explicit suspension functor $\operatorname{susp}$ on maps and an explicit join functor
$*$ on maps; (iii) the exact existence criterion "a $\mathbb{Z}_2$-map $S^m \to S^n$
exists iff $m \le n$", hence $\operatorname{coind}(S^n) = n$; (iv) the exact suspension
increment $\operatorname{coind}(S^{n+1}) = \operatorname{coind}(S^n) + 1$, anchored by
the base obstructions $S^1 \not\to S^0$ and $S^2 \not\to S^1$; (v) the sharp join law
$\operatorname{coind}(S^a * S^c) = \operatorname{coind}(S^a) + \operatorname{coind}(S^c)
+ 1$; and (vi) an enumerative shadow: the number of $\mathbb{Z}_2$-maps is
supermultiplicative under join, with the exact count
$\#\{S^m \to S^n\} = \tfrac{(n+1)!}{(n-m)!}\,2^{m+1}$ for $m \le n$. We close with a
program for the non-spherical case, where the index and coindex separate and the excess
$\operatorname{ind} - \operatorname{coind}$ becomes the governing invariant.

**Keywords:** $\mathbb{Z}_2$-coindex, Borsuk–Ulam theorem, cross-polytope, combinatorial
sphere, suspension, join, equivariant map, free involution, deleted join.

---

## 1. Introduction

The Borsuk–Ulam theorem and its combinatorial avatar, Tucker's lemma, assert a fundamental
rigidity: a continuous map $S^n \to \mathbb{R}^n$ must identify a pair of antipodes, and
equivalently there is no antipodal (equivariant) map $S^n \to S^{n-1}$. The invariant that
tracks this rigidity across a whole category of spaces carrying a free involution is the
$\mathbb{Z}_2$-**coindex**, which records the largest sphere that can be equivariantly
mapped *into* a given space. Together with its dual, the $\mathbb{Z}_2$-**index** (the
smallest sphere the space maps *out* onto), the coindex organizes a great deal of modern
combinatorial topology, from the chromatic bounds of Lovász–Kneser to fair-division and
splitting-necklace theorems.

This paper isolates the combinatorial skeleton of the theory. We work with the
**octahedral spheres**: the boundary complex of the $(n+1)$-dimensional cross-polytope,
whose $2(n+1)$ vertices are the signed unit vectors $\pm e_0, \dots, \pm e_n$ and whose
free involution is the antipodal map $v \mapsto -v$. In this model a simplicial
equivariant map is captured completely by finite, decidable data. Our thesis is that
this austerity is not a loss of content: the deep constraints of Borsuk–Ulam type reduce,
transparently and without cheating, to the impossibility of injecting a large finite set
of axes into a smaller one.

### 1.1 Contributions

1. A precise combinatorial model of free $\mathbb{Z}_2$-complexes via cross-polytopes, and
   the equivalence of *simpliciality* (faces to faces) with *coordinate injectivity* for
   these complexes (§2–§3).
2. The category structure of $\mathbb{Z}_2$-maps: identity, composition, and equatorial
   inclusion (§4).
3. An explicit suspension functor and an explicit join functor on maps—actual terms, not
   existence statements (§5, §7).
4. The constructive lower bound $\operatorname{coind}(S^n) \ge n$ and the matching upper
   bound, hence the exact value $\operatorname{coind}(S^n) = n$ (§6).
5. The sharp suspension increment of exactly one, anchored by two hand-verified base
   obstructions (§6).
6. The sharp join law and its enumerative consequences, including an exact count of
   $\mathbb{Z}_2$-maps (§7).
7. A research program for the excess $\operatorname{ind} - \operatorname{coind}$ off the
   sphere (§9).

---

## 2. The combinatorial model

### 2.1 Signed vertices and the octahedral sphere

Fix $n \in \mathbb{N}$.

**Definition 2.1 (Signed vertex).** A *signed vertex* on $n+1$ axes is a pair
$v = (i, s)$ with $i \in \{0, 1, \dots, n\}$ (an *axis*) and $s \in \{+, -\}$ (a *sign*).
We write the set of signed vertices as $\mathrm{SVert}(n)$; it has $2(n+1)$ elements.

**Definition 2.2 (Antipodal involution).** The *antipode* of $v = (i, s)$ is
$-v := (i, -s)$. The map $v \mapsto -v$ is a fixed-point-free involution of
$\mathrm{SVert}(n)$; it is the free $\mathbb{Z}_2$-action.

**Definition 2.3 (Combinatorial sphere $S^n$).** The *octahedral sphere* $S^n$ is the
simplicial complex whose vertices are $\mathrm{SVert}(n)$ and whose faces are the sets of
signed vertices lying on *pairwise distinct axes*:
$$
\sigma \subseteq \mathrm{SVert}(n) \text{ is a face } \iff \text{the axis coordinates of the elements of } \sigma \text{ are distinct.}
$$
Equivalently, $\sigma$ contains no antipodal pair. This is the boundary complex of the
cross-polytope $\operatorname{conv}\{\pm e_0, \dots, \pm e_n\}$, a triangulation of the
topological $n$-sphere on which the antipodal map acts freely.

For example, $S^0$ is two points $\{+e_0, -e_0\}$ swapped by the involution; $S^1$ is the
$4$-cycle $\pm e_0, \pm e_1$ (a square on its corner); $S^2$ is the octahedron.

### 2.2 Equivariant simplicial maps

**Definition 2.4 ($\mathbb{Z}_2$-map).** A $\mathbb{Z}_2$-*map* $F : S^m \to S^n$ is a
vertex map $F : \mathrm{SVert}(m) \to \mathrm{SVert}(n)$ that is
1. **equivariant:** $F(-v) = -F(v)$ for all $v$; and
2. **simplicial:** $F$ sends faces of $S^m$ to faces of $S^n$.

We denote by $\mathrm{Z2Map}(m,n)$ the set of such maps.

Equivariance means $F$ is determined by its values on the *positive* vertices $(i, +)$,
$i \in \{0, \dots, m\}$: once $F(i, +) = (\varphi(i), \sigma(i))$ is chosen,
$F(i, -) = (\varphi(i), -\sigma(i))$ is forced. Thus a candidate $F$ is exactly a pair
$$
\varphi : \{0, \dots, m\} \to \{0, \dots, n\}, \qquad \sigma : \{0, \dots, m\} \to \{+, -\},
$$
the *coordinate map* and the *sign map*. We call $\varphi$ the coordinate map of $F$.

---

## 3. Simpliciality equals coordinate injectivity

The technical linchpin of the theory is that, for octahedral spheres, the global
simpliciality condition collapses to a single local condition on the coordinate map.

**Theorem 3.1 (Local–global principle).** Let $F : S^m \to S^n$ be an equivariant vertex
map with coordinate map $\varphi$. Then $F$ is simplicial if and only if $\varphi$ is
injective.

*Proof sketch.* A face of $S^m$ is a set of vertices on distinct axes. Its image under
$F$ is a set of vertices whose axes are $\{\varphi(i) : (i, \cdot) \in \sigma\}$; this is a
face of $S^n$ precisely when those axes are distinct, i.e. when $\varphi$ restricted to the
axes appearing in $\sigma$ is injective. Since every pair of axes appears together in some
face (any two distinct axes span an edge), the condition "every face maps to a face" is
equivalent to "$\varphi$ is injective on all pairs," i.e. $\varphi$ is injective globally.
The equivariance guarantees the sign data never creates an antipodal collision within an
image face, so no additional constraint arises. $\square$

Theorem 3.1 is the sentence that makes the whole subject decidable and elementary. It also
yields the reusable fact that *the coordinate map of any $\mathbb{Z}_2$-map is injective*,
which we invoke repeatedly.

**Corollary 3.2 (Decidable reformulation).** A $\mathbb{Z}_2$-map $S^m \to S^n$ exists if
and only if there exists an injection $\{0, \dots, m\} \hookrightarrow \{0, \dots, n\}$
together with an arbitrary sign vector. Existence therefore reduces to a finite check over
the images of the positive vertices.

---

## 4. The category of $\mathbb{Z}_2$-maps

The maps $\mathrm{Z2Map}(m,n)$ are the morphisms of a category whose objects are the
combinatorial spheres.

**Proposition 4.1 (Identity and composition).** The identity vertex map
$\mathrm{id} : S^n \to S^n$ is a $\mathbb{Z}_2$-map, and if $F : S^m \to S^n$ and
$G : S^n \to S^p$ are $\mathbb{Z}_2$-maps then so is their composite $G \circ F : S^m \to S^p$.
On coordinate maps this is the composition of injections; on signs it is the pointwise
product $\sigma_{G \circ F}(i) = \sigma_G(\varphi_F(i)) \cdot \sigma_F(i)$.

**Definition 4.2 (Equatorial inclusion).** The *equatorial inclusion*
$\iota : S^n \hookrightarrow S^{n+1}$ is the $\mathbb{Z}_2$-map with coordinate map the
inclusion $\{0, \dots, n\} \hookrightarrow \{0, \dots, n+1\}$ and all signs positive. It
realizes $S^n$ as the equator (the subcomplex omitting the new axis $n+1$) of $S^{n+1}$.

The equatorial inclusions provide, by composition, an explicit $\mathbb{Z}_2$-map
$S^m \to S^n$ for every $m \le n$—the concrete witness of the lower bound in §6.

---

## 5. The suspension functor

**Definition 5.1 (Suspension of a map).** Given $F : S^m \to S^n$ with coordinate map
$\varphi$ and signs $\sigma$, its *suspension* $\operatorname{susp}(F) : S^{m+1} \to S^{n+1}$
is defined by
$$
\varphi_{\operatorname{susp}(F)}(i) =
\begin{cases}
\varphi(i), & 0 \le i \le m, \\
n+1, & i = m+1,
\end{cases}
\qquad
\sigma_{\operatorname{susp}(F)}(i) =
\begin{cases}
\sigma(i), & 0 \le i \le m, \\
+, & i = m+1.
\end{cases}
$$
That is, suspension adjoins a new pair of poles $\pm e_{m+1} \mapsto \pm e_{n+1}$ and acts
by $F$ on all other coordinates.

**Proposition 5.2 (Suspension is functorial).** $\operatorname{susp}(F)$ is a
$\mathbb{Z}_2$-map, $\operatorname{susp}(\mathrm{id}) = \mathrm{id}$, and
$\operatorname{susp}(G \circ F) = \operatorname{susp}(G) \circ \operatorname{susp}(F)$.

*Proof sketch.* The coordinate map of $\operatorname{susp}(F)$ extends the injection
$\varphi$ by sending the fresh axis $m+1$ to the fresh axis $n+1$, which lies outside the
range of $\varphi$; a one-point extension of an injection into a fresh value is again an
injection. Theorem 3.1 then gives simpliciality. Functoriality is immediate on coordinate
maps and signs. $\square$

**Corollary 5.3 (Suspension raises the coindex).** If a $\mathbb{Z}_2$-map $S^m \to S^n$
exists, then so does a $\mathbb{Z}_2$-map $S^{m+1} \to S^{n+1}$. Hence suspension raises the
coindex lower bound by one at every level.

---

## 6. The coindex of spheres and the sharp suspension increment

**Definition 6.1 (Coindex).** For a free $\mathbb{Z}_2$-complex $X$,
$$
\operatorname{coind}(X) = \max\{\, n \in \mathbb{N} : \mathrm{Z2Map}(n, X) \ne \varnothing \,\},
$$
the largest $n$ such that $S^n$ admits a $\mathbb{Z}_2$-map into $X$.

**Theorem 6.2 (Existence criterion).** A $\mathbb{Z}_2$-map $S^m \to S^n$ exists if and
only if $m \le n$.

*Proof.* ($\Leftarrow$) If $m \le n$, compose $m$-fold equatorial inclusions, or
equivalently take the coordinate map to be the inclusion $\{0,\dots,m\} \hookrightarrow
\{0,\dots,n\}$ with all signs positive; this is a $\mathbb{Z}_2$-map by Theorem 3.1.
($\Rightarrow$) A $\mathbb{Z}_2$-map has, by Theorem 3.1, an injective coordinate map
$\{0,\dots,m\} \hookrightarrow \{0,\dots,n\}$. An injection between finite sets of sizes
$m+1$ and $n+1$ forces $m+1 \le n+1$, i.e. $m \le n$ (pigeonhole). $\square$

**Corollary 6.3 (Coindex of a sphere).** $\operatorname{coind}(S^n) = n$.

**Corollary 6.4 (No dimension drop; combinatorial Borsuk–Ulam).** For every $n$ there is
*no* $\mathbb{Z}_2$-map $S^{n+1} \to S^n$; equivalently $\mathrm{Z2Map}(n+1, n) = \varnothing$.

The two lowest instances are verifiable entirely by hand and anchor the tower:

**Lemma 6.5 (Base obstructions).**
$S^1 \not\to S^0$ (no injection $\{0,1\} \hookrightarrow \{0\}$) and $S^2 \not\to S^1$
(no injection $\{0,1,2\} \hookrightarrow \{0,1\}$). Consequently
$\operatorname{coind}(S^0) = 0$ and $\operatorname{coind}(S^1) = 1$.

**Theorem 6.6 (Sharp suspension increment).** For all $n$,
$$
\operatorname{coind}(S^{n+1}) = \operatorname{coind}(S^n) + 1.
$$
*Proof.* The lower bound $\operatorname{coind}(S^{n+1}) \ge \operatorname{coind}(S^n) + 1$
is Corollary 5.3 applied to a coindex witness of $S^n$. The upper bound
$\operatorname{coind}(S^{n+1}) \le \operatorname{coind}(S^n) + 1$ is Corollary 6.4: a
larger witness would furnish a map $S^{n+2} \to S^{n+1}$, forbidden by pigeonhole.
Combining with Corollary 6.3 gives the exact increment. $\square$

The increment is *exactly* one, with no slack: the lower half is a genuine construction
(suspension) and the upper half a genuine obstruction (pigeonhole), so the theory neither
under- nor over-counts.

---

## 7. The join functor and the join law

Topologically, the join of the octahedral spheres is again an octahedral sphere: gluing a
cross-polytope on $a+1$ axes to one on $c+1$ axes produces a cross-polytope on
$(a+1)+(c+1) = (a+c+1)+1$ axes, so $S^a * S^c \cong S^{a+c+1}$. This identification lifts to
a functor on maps.

**Definition 7.1 (Join data).** Given $F : S^a \to S^b$ and $G : S^c \to S^d$, define the
coordinate map of the join on the $a+c+2$ source axes $\{0, \dots, a+c+1\}$ by
$$
\varphi_{F * G}(i) =
\begin{cases}
\varphi_F(i), & 0 \le i \le a \quad (\text{low block, into } \{0,\dots,b\}), \\
(b+1) + \varphi_G(i - (a+1)), & a+1 \le i \le a+c+1 \quad (\text{high block, into } \{b+1,\dots,b+d+1\}),
\end{cases}
$$
with signs $\sigma_{F*G}(i) = \sigma_F(i)$ on the low block and
$\sigma_{F*G}(i) = \sigma_G(i-(a+1))$ on the high block.

**Theorem 7.2 (Join functor).** $F * G$ is a $\mathbb{Z}_2$-map
$S^{a+c+1} \to S^{b+d+1}$.

*Proof sketch.* By Theorem 3.1 it suffices to show $\varphi_{F*G}$ is injective. It is a
*block sum*: on the low block it agrees with $\varphi_F$, which is injective with range in
$\{0, \dots, b\}$; on the high block it agrees with $\varphi_G$ shifted by $b+1$, injective
with range in $\{b+1, \dots, b+d+1\}$. The two ranges are disjoint, so no collision occurs
between blocks, and injectivity within each block is inherited from $F$ and $G$. $\square$

**Theorem 7.3 (Constructive join law).** If $\mathbb{Z}_2$-maps $S^a \to S^b$ and
$S^c \to S^d$ exist, then a $\mathbb{Z}_2$-map $S^{a+c+1} \to S^{b+d+1}$ exists.

**Theorem 7.4 (Sharp join law for the coindex).** For all $a, c$,
$$
\operatorname{coind}(S^a * S^c) = \operatorname{coind}(S^a) + \operatorname{coind}(S^c) + 1.
$$
*Proof.* Using $S^a * S^c \cong S^{a+c+1}$ and Corollary 6.3,
$\operatorname{coind}(S^{a+c+1}) = a+c+1 = a + c + 1 =
\operatorname{coind}(S^a) + \operatorname{coind}(S^c) + 1$. $\square$

This is the *sharp* instance—an exact equality—of the general join inequality
$\operatorname{coind}(X * Y) \ge \operatorname{coind}(X) + \operatorname{coind}(Y) + 1$
that holds for arbitrary free $\mathbb{Z}_2$-complexes. Equality here is a manifestation of
the rigidity of spheres, whose coindex equals their dimension.

### 7.1 Honest scope: strictly sufficient, not necessary

The join is a *construction* of $\mathbb{Z}_2$-maps from blockwise data, and it is strictly
stronger than the exact existence criterion of Theorem 6.2.

**Proposition 7.5 (Strict sufficiency).** The join produces a map
$S^{a+c+1} \to S^{b+d+1}$ from the blockwise hypotheses $a \le b$ and $c \le d$. But a
$\mathbb{Z}_2$-map into the joined target can exist even when a block admits none: there is
no map $S^1 \to S^0$ (first block fails, since $1 > 0$), yet a map
$S^{1+1+1} = S^3 \to S^{0+2+1} = S^3$ exists (namely the identity), because the exact
criterion $a + c \le b + d$ (here $1 + 1 \le 0 + 2$) is genuinely weaker than
"$a \le b$ and $c \le d$."

This records the boundary of the construction explicitly rather than hiding it.

### 7.2 Enumerative consequences

**Theorem 7.6 (Join is injective on pairs).** The map
$(F, G) \mapsto F * G$, $\mathrm{Z2Map}(a,b) \times \mathrm{Z2Map}(c,d) \to
\mathrm{Z2Map}(a+c+1, b+d+1)$, is injective: the joined map determines $F$ on the low block
of axes and $G$ on the high block, so distinct pairs give distinct joins.

**Corollary 7.7 (Supermultiplicativity of the map count).**
$$
\#\mathrm{Z2Map}(a,b) \cdot \#\mathrm{Z2Map}(c,d) \le \#\mathrm{Z2Map}(a+c+1, b+d+1).
$$

**Proposition 7.8 (Exact count).** For $m \le n$,
$$
\#\mathrm{Z2Map}(m,n) = \frac{(n+1)!}{(n-m)!} \cdot 2^{\,m+1},
$$
and $\#\mathrm{Z2Map}(m,n) = 0$ for $m > n$. Indeed a $\mathbb{Z}_2$-map is an injection of
$m+1$ axes into $n+1$ slots ($\tfrac{(n+1)!}{(n-m)!}$ choices) times an independent sign on
each of the $m+1$ source axes ($2^{m+1}$ choices).

*Consistency check.* With $a=c=1$, $b=d=1$: $\#\mathrm{Z2Map}(1,1) = \tfrac{2!}{0!} 2^2 = 8$,
so the left side of Corollary 7.7 is $64$, while $\#\mathrm{Z2Map}(3,3) = \tfrac{4!}{0!}2^4
= 24 \cdot 16 = 384 \ge 64$; the inequality is strict, as expected off the diagonal of
constructible maps.

---

## 8. The unified coordinate-injection picture

Assembling §4–§7, all five structural operations on $\mathbb{Z}_2$-maps of octahedral
spheres are governed by a single principle:

> A simplicial antipodal map of cross-polytopes is an injection of coordinate axes with
> independent signs.

- **Identity / composition:** identity and composition of injections; signs multiply.
- **Equatorial inclusion:** the standard one-slot inclusion of axis sets.
- **Suspension:** extend an injection by sending one fresh axis to one fresh axis (join
  with $S^0$).
- **Join:** block sum of two injections into disjoint axis ranges.

Suspension is the special case of join with the $0$-sphere; join contributes a whole
independent block. This unifies the suspension tower and the join into one operadic
picture, all consistent with $\operatorname{coind}(S^n) = n$.

---

## 9. Discussion and future work

The spherical case is exact because for spheres the coindex coincides with the *index*
(the smallest sphere the space maps onto), so both the "map in" and "map out" problems are
solved by the same axis count. The rich phenomena appear once these two invariants
separate, off the sphere. The coordinate-injection analysis developed here is exactly the
apparatus needed to pursue them.

**Beyond spheres: the excess.** For a free $\mathbb{Z}_2$-complex $X$ define the coindex
(largest sphere mapping in) and the index $\operatorname{ind}(X)$ (smallest sphere $X$ maps
out onto); always $\operatorname{coind}(X) \le \operatorname{ind}(X)$ (Borsuk–Ulam), with
equality for spheres. The difference $\operatorname{ind}(X) - \operatorname{coind}(X)$, the
*excess*, is the first invariant invisible to dimension alone.

**Program.**
1. **General Tucker's lemma.** Extend the pigeonhole obstruction to abstract free
   $\mathbb{Z}_2$-complexes via a combinatorial Tucker labelling, establishing
   $\operatorname{coind} \le \operatorname{ind}$ in full generality.
2. **Abstract free $\mathbb{Z}_2$-complexes.** Generalize the map notion from spheres to
   arbitrary simplicial complexes with a free simplicial involution, defining coindex and
   index as $\sup$/$\inf$ over the extended naturals, and prove the join/suspension laws
   $\operatorname{coind}(X * Y) \ge \operatorname{coind}(X) + \operatorname{coind}(Y) + 1$.
3. **Positive excess.** Construct explicit families $X_k$ with
   $\operatorname{ind}(X_k) - \operatorname{coind}(X_k) = k$, using deleted joins of small
   complexes, and study how the excess evolves under join and suspension.
4. **Deleted joins and chromatic numbers.** Connect the coindex of the box/neighborhood
   complex of a graph $G$ to its chromatic number via the Lovász-type bound
   $\chi(G) \ge \operatorname{coind}(\cdot) + 2$.

**Conjectures.** The join inequality should become *strict* for complexes whose coindex
lies below their dimension; suspension should raise both index and coindex by exactly one
(hence preserve the excess) while join should add the excesses,
$\operatorname{excess}(X * Y) = \operatorname{excess}(X) + \operatorname{excess}(Y)$.

---

## 10. Conclusion

By modeling free $\mathbb{Z}_2$-complexes as boundary complexes of cross-polytopes we have
reduced the equivariant topology of spheres to the combinatorics of axis-injections with
signs. In this model the coindex equals the dimension, suspension raises it by exactly one,
and the join is coindex-additive plus one—each a sharp, unconditional statement with a
constructive lower bound and a pigeonhole upper bound. The base obstructions
$S^1 \not\to S^0$ and $S^2 \not\to S^1$ are genuine Borsuk–Ulam phenomena, not
technicalities, and the constructions (suspension, join) are explicit maps rather than mere
existence claims. The same coordinate-injection lens now points toward the non-spherical
world, where the index and coindex separate and the excess awaits systematic study.
