# The $\mathbb{Z}_2$-Coindex Under Suspension: A Constructive Lower-Bound Theory for Free $\mathbb{Z}_2$-Complexes

## Abstract

We develop a fully combinatorial, self-contained theory of free
$\mathbb{Z}_2$-complexes modeled on the boundary complexes of cross-polytopes —
the octahedral combinatorial spheres $S^n$ — and study the behaviour of the
$\mathbb{Z}_2$-coindex under suspension. Our central contribution is the
**constructive lower-bound half** of this behaviour, established
unconditionally and by explicit construction. We introduce the category of
$\mathbb{Z}_2$-maps between combinatorial spheres, whose morphisms are
antipode-equivariant simplicial maps, characterized by a purely local
(vertex-pair) simpliciality condition equivalent to "faces map to faces." We
prove that suspension is a functor on this category: every $\mathbb{Z}_2$-map
$S^m \to S^n$ lifts to a $\mathbb{Z}_2$-map $S^{m+1} \to S^{n+1}$ by an explicit
pole-preserving recipe. Combined with the equatorial inclusion
$S^n \hookrightarrow S^{n+1}$, this yields the theorem that $m \le n$ implies the
existence of an explicit $\mathbb{Z}_2$-map $S^m \to S^n$, i.e.
$\operatorname{coind}(S^n) \ge n$, and that suspension raises the coindex bound
by (at least) one. We further give a decidable reformulation of the existence of
a $\mathbb{Z}_2$-map in terms of the finite data of the images of the positive
vertices, and use it to verify two genuine finite instances of the Borsuk–Ulam
theorem — the non-existence of $\mathbb{Z}_2$-maps $S^1 \to S^0$ and
$S^2 \to S^1$. These obstructions establish $\operatorname{coind}(S^0) = 0$ and
$\operatorname{coind}(S^1) = 1$, showing that the suspension increment is exactly
one at the base of the tower. The matching upper bound
$\operatorname{coind}(S^n) \le n$ in all dimensions — the full Borsuk–Ulam/Tucker
theorem — is discussed as the principal remaining gap.

**Keywords:** $\mathbb{Z}_2$-coindex, free $\mathbb{Z}_2$-complex, cross-polytope,
combinatorial sphere, suspension functor, Borsuk–Ulam theorem, antipodal map,
topological combinatorics.

---

## 1. Introduction

The Borsuk–Ulam theorem — that every continuous map $S^n \to \mathbb{R}^n$
identifies some pair of antipodes, or equivalently that there is no continuous
antipode-preserving map $S^n \to S^{n-1}$ — is one of the load-bearing results of
topological combinatorics. Through Lovász's theorem it bounds graph chromatic
numbers; it underlies the ham-sandwich and necklace-splitting theorems; and it is
the archetype of a symmetry-based existence principle. The quantitative refinement
of Borsuk–Ulam is organized around a pair of $\mathbb{Z}_2$-homotopy invariants of
a free $\mathbb{Z}_2$-space $X$: the **index** and the **coindex**. The coindex
$\operatorname{coind}(X)$ is the largest $n$ such that there is a
$\mathbb{Z}_2$-map $S^n \to X$; the index $\operatorname{ind}(X)$ is the smallest
$n$ such that there is a $\mathbb{Z}_2$-map $X \to S^n$. They satisfy
$\operatorname{coind}(X) \le \operatorname{ind}(X)$, and the Borsuk–Ulam theorem
is exactly the statement $\operatorname{coind}(S^n) = \operatorname{ind}(S^n) = n$.

This paper isolates and rigorously develops the **constructive lower-bound half**
of the theory for the fundamental family of examples, the spheres themselves,
using a combinatorial model that keeps every statement elementary and every
existence claim genuinely witnessed. We work with the boundary complexes of
cross-polytopes — the octahedral combinatorial spheres — which carry a canonical
free simplicial $\mathbb{Z}_2$-action (the antipodal map) and whose simplicial
structure admits a strikingly clean local description. Within this model we:

- organize antipode-equivariant simplicial maps into a category (Section 3);
- construct the **suspension functor** on maps (Section 4);
- prove the constructive lower bound $\operatorname{coind}(S^n) \ge n$ and the
  suspension increment (Section 5);
- give a decidable reformulation of map existence (Section 6); and
- verify the base-case Borsuk–Ulam obstructions, establishing sharpness of the
  increment at the bottom of the tower (Section 7).

The upper bound in general dimension — the full strength of Borsuk–Ulam/Tucker —
is not established here beyond the finite base cases, and we describe it as the
main open direction (Section 9).

---

## 2. The combinatorial model

### 2.1 Vertices and the antipodal action

**Definition 2.1 (Combinatorial sphere).** For $n \in \mathbb{N}$, the vertex set
of the $n$-dimensional combinatorial sphere $S^n$ — the boundary complex of the
$(n+1)$-dimensional cross-polytope — is
$$V(S^n) \;=\; \{0, 1, \dots, n\} \times \{\text{true}, \text{false}\}.$$
The pair $(i, \text{true})$ encodes the signed unit vector $+e_i$ and
$(i, \text{false})$ encodes $-e_i$. There are $2(n+1)$ vertices.

**Definition 2.2 (Faces).** A subset $\sigma \subseteq V(S^n)$ is a **face**
(simplex) of $S^n$ iff it contains no antipodal pair, i.e. it contains at most one
of $(i, \text{true}), (i, \text{false})$ for each index $i$. The maximal faces
have $n+1$ vertices, one signed choice per axis, matching the $2^{n+1}$ facets of
the cross-polytope boundary.

**Definition 2.3 (Antipodal map).** The antipodal map
$\operatorname{anti} : V(S^n) \to V(S^n)$ flips the sign bit:
$$\operatorname{anti}(i, b) = (i, \lnot b).$$

**Proposition 2.4 (Free involution).** The antipodal map is an involution
($\operatorname{anti}(\operatorname{anti}(p)) = p$), is injective, and is
fixed-point-free ($\operatorname{anti}(p) \neq p$ for all $p$). Hence $S^n$ is a
free $\mathbb{Z}_2$-complex.

*Proof.* Flipping a Boolean bit twice returns it; a bijection follows from
involutivity; and $\lnot b \ne b$ for every Boolean $b$, so the second coordinate
of $\operatorname{anti}(p)$ differs from that of $p$. $\square$

### 2.2 Vertex suspension

**Definition 2.5 (Vertex suspension).** The map
$\operatorname{suspV} : V(S^n) \to V(S^{n+1})$ reuses the index in the enlarged
sphere by casting it into the first $n+1$ coordinates:
$$\operatorname{suspV}(i, b) = (\iota(i), b),$$
where $\iota : \{0,\dots,n\} \hookrightarrow \{0,\dots,n+1\}$ is the standard
order-preserving inclusion (never hitting the top index $n+1$).

**Proposition 2.6.** Vertex suspension is antipode-equivariant,
$\operatorname{suspV}(\operatorname{anti} p) = \operatorname{anti}(\operatorname{suspV} p)$,
and its image never contains a top-index (pole) vertex:
$\operatorname{suspV}(p) \ne (n+1, b)$ for all $p, b$.

*Proof.* Equivariance is immediate since $\operatorname{suspV}$ leaves the sign
bit untouched. The index of $\operatorname{suspV}(p)$ is $\iota(i) < n+1$, so it
can never equal the top index $n+1$. $\square$

The two vertices $(n+1, \text{true}), (n+1, \text{false})$ of $S^{n+1}$ that lie
outside the image of $\operatorname{suspV}$ are the two **suspension poles**.

---

## 3. The category of $\mathbb{Z}_2$-maps

**Definition 3.1 ($\mathbb{Z}_2$-map).** A $\mathbb{Z}_2$-map $S^m \to S^n$ is a
vertex map $f : V(S^m) \to V(S^n)$ satisfying:

1. **Equivariance:** $f(\operatorname{anti} p) = \operatorname{anti}(f p)$ for all
   $p$;
2. **Simpliciality (local form):** for all $p, q$,
   $$f(p) = \operatorname{anti}(f(q)) \;\Longrightarrow\; p = \operatorname{anti}(q).$$

**Remark 3.2 (Equivalence with "faces map to faces").** For cross-polytope
complexes the local condition (2) is *exactly* the statement that $f$ maps faces
to faces. Indeed a set $\sigma$ is a face iff it contains no antipodal pair; the
image $f(\sigma)$ fails to be a face iff it contains some antipodal pair
$f(p), \operatorname{anti}(f(p)) = f(q)$ with $p, q \in \sigma$ and
$p \ne \operatorname{anti}(q)$ — which is precisely the negation of (2). This local
characterization is what makes the whole theory decidable and elementary while
remaining faithful to the underlying simplicial topology.

**Theorem 3.3 (Category structure).** $\mathbb{Z}_2$-maps of combinatorial
spheres form a category:

- **Identity.** For each $n$, the identity vertex map $\operatorname{id}$ is a
  $\mathbb{Z}_2$-map $S^n \to S^n$.
- **Composition.** If $F : S^m \to S^n$ and $G : S^n \to S^k$ are
  $\mathbb{Z}_2$-maps, then $G \circ F : S^m \to S^k$ is a $\mathbb{Z}_2$-map.

*Proof.* Identity: equivariance and simpliciality hold trivially. Composition:
equivariance chains, $G(F(\operatorname{anti} p)) = G(\operatorname{anti}(Fp)) =
\operatorname{anti}(G(Fp))$; and if $G(F(p)) = \operatorname{anti}(G(F(q)))$ then
$G$'s simpliciality gives $F(p) = \operatorname{anti}(F(q))$, and $F$'s gives
$p = \operatorname{anti}(q)$. $\square$

**Theorem 3.4 (Equatorial inclusion).** The map
$\operatorname{incl} : V(S^n) \to V(S^{n+1})$, $(i, b) \mapsto (\iota(i), b)$, is a
$\mathbb{Z}_2$-map $S^n \hookrightarrow S^{n+1}$ realizing $S^n$ as the equator of
$S^{n+1}$.

*Proof.* Equivariance is immediate (the sign bit is preserved). For
simpliciality, if $(\iota(i), b) = \operatorname{anti}(\iota(j), c) =
(\iota(j), \lnot c)$ then $\iota(i) = \iota(j)$ and $b = \lnot c$; since $\iota$ is
injective, $i = j$ and $b = \lnot c$, i.e. $(i,b) = \operatorname{anti}(j,c)$.
$\square$

---

## 4. The suspension functor

The technical heart of the constructive theory is that suspension, a fundamental
topological operation on spaces, lifts to an operation on antipode-equivariant
maps.

**Definition 4.1 (Suspension of a map).** Let $F : S^m \to S^n$ be a
$\mathbb{Z}_2$-map. Its **suspension** $\operatorname{susp}(F) : S^{m+1} \to
S^{n+1}$ is defined on vertices by case analysis on the index:
$$
\operatorname{susp}(F)(i, b) =
\begin{cases}
(n+1, b) & \text{if } i = m+1 \text{ (a pole of } S^{m+1}), \\[4pt]
\operatorname{suspV}\!\big(F(j, b)\big) & \text{if } i = \iota(j),\ j \le m.
\end{cases}
$$
That is: the two poles of $S^{m+1}$ map to the two poles of $S^{n+1}$ preserving
sign, and every non-pole vertex is transported by $F$ and then relabeled one
dimension up.

**Theorem 4.2 (Suspension is a well-defined $\mathbb{Z}_2$-map).** For every
$\mathbb{Z}_2$-map $F : S^m \to S^n$, the map $\operatorname{susp}(F)$ is a
$\mathbb{Z}_2$-map $S^{m+1} \to S^{n+1}$.

*Proof.* **Equivariance.** On a pole vertex $(m+1, b)$ we have
$\operatorname{susp}(F)(\operatorname{anti}(m+1, b)) =
\operatorname{susp}(F)(m+1, \lnot b) = (n+1, \lnot b) =
\operatorname{anti}(n+1, b)$. On a non-pole vertex $(\iota(j), b)$,
$$
\operatorname{susp}(F)(\operatorname{anti}(\iota(j), b))
= \operatorname{suspV}(F(j, \lnot b))
= \operatorname{suspV}(\operatorname{anti}(F(j, b)))
= \operatorname{anti}(\operatorname{suspV}(F(j, b))),
$$
using equivariance of $F$ and of $\operatorname{suspV}$ (Proposition 2.6).

**Simpliciality.** Suppose $\operatorname{susp}(F)(p) =
\operatorname{anti}(\operatorname{susp}(F)(q))$; we show $p = \operatorname{anti}(q)$
by cases on whether $p, q$ are poles.

- *Both poles*, $p = (m+1, b), q = (m+1, c)$: the equation reads
  $(n+1, b) = (n+1, \lnot c)$, so $b = \lnot c$, whence
  $p = \operatorname{anti}(q)$.
- *Exactly one pole*: say $p = (m+1, b)$ and $q = (\iota(j), c)$. Then the equation
  equates a top-index vertex $(n+1, b)$ with
  $\operatorname{anti}(\operatorname{suspV}(F(j,c)))$, whose index is $< n+1$ by
  Proposition 2.6 — a contradiction. The symmetric case is identical. Hence this
  case is vacuous.
- *Neither pole*, $p = (\iota(i), b), q = (\iota(j), c)$: the equation becomes
  $\operatorname{suspV}(F(i,b)) = \operatorname{anti}(\operatorname{suspV}(F(j,c)))
  = \operatorname{suspV}(\operatorname{anti}(F(j,c)))$. Since $\operatorname{suspV}$
  is injective (it is injective on indices via $\iota$ and preserves sign), we get
  $F(i,b) = \operatorname{anti}(F(j,c))$. Simpliciality of $F$ yields
  $(i,b) = \operatorname{anti}(j,c)$, i.e. $i = j$ and $b = \lnot c$; applying
  $\iota$ and reattaching the bit gives $p = \operatorname{anti}(q)$. $\square$

**Corollary 4.3 (Functoriality).** Suspension preserves identities and
composition up to the evident relabeling; in particular it defines a functor from
the category of $\mathbb{Z}_2$-maps of spheres to itself, raising both dimensions
by one.

---

## 5. The constructive lower bound

**Theorem 5.1 (Suspension raises the coindex bound).** If there exists a
$\mathbb{Z}_2$-map $S^m \to S^n$, then there exists a $\mathbb{Z}_2$-map
$S^{m+1} \to S^{n+1}$.

*Proof.* Apply the suspension functor (Theorem 4.2) to the given map. $\square$

**Theorem 5.2 (Constructive lower bound).** For all $m, n$ with $m \le n$ there
exists an explicit $\mathbb{Z}_2$-map $S^m \to S^n$. Equivalently,
$\operatorname{coind}(S^n) \ge n$.

*Proof.* Induction on $n$. If $n = 0$ then $m = 0$ and the identity map works. For
$n = k+1$: if $m = k+1$, use the identity $S^{k+1} \to S^{k+1}$; otherwise
$m \le k$, so by the inductive hypothesis there is a $\mathbb{Z}_2$-map
$F : S^m \to S^k$, and $\operatorname{incl} \circ F : S^m \to S^{k+1}$ is the
desired map (Theorems 3.3, 3.4). Concretely, the witness for $m \le n$ is the
identity of $S^m$ post-composed with $n - m$ equatorial inclusions. $\square$

**Corollary 5.3 (Diagonal witness).** For every $n$, the identity map is a
$\mathbb{Z}_2$-map $S^n \to S^n$, so $\operatorname{coind}(S^n) \ge n$ directly.

The content of Theorem 5.2 is that every existence claim is *witnessed by an
explicit, hand-written map*; nothing is asserted non-constructively. This is the
"lower-bound half" of the coindex-under-suspension programme.

---

## 6. Decidable reformulation

Equivariance forces a $\mathbb{Z}_2$-map to be determined by its values on the
positive vertices. This yields a finite, decidable criterion for existence.

**Definition 6.1 (Induced map).** Given data $g : \{0,\dots,m\} \to V(S^n)$
assigning a vertex to each positive index, the **induced** vertex map
$\operatorname{ind}(g) : V(S^m) \to V(S^n)$ is
$$\operatorname{ind}(g)(i, b) =
\begin{cases} g(i) & b = \text{true}, \\ \operatorname{anti}(g(i)) & b = \text{false}. \end{cases}$$

**Proposition 6.2.** The induced map is always equivariant:
$\operatorname{ind}(g)(\operatorname{anti} p) = \operatorname{anti}(\operatorname{ind}(g)(p))$.

*Proof.* Case on the sign bit of $p$; both cases reduce to
$\operatorname{anti}(\operatorname{anti}(g(i))) = g(i)$ or its reverse. $\square$

**Theorem 6.3 (Finite existence criterion).** There exists a $\mathbb{Z}_2$-map
$S^m \to S^n$ if and only if there exists positive-vertex data
$g : \{0,\dots,m\} \to V(S^n)$ whose induced map is simplicial:
$$\exists\, g,\ \forall p, q,\quad
\operatorname{ind}(g)(p) = \operatorname{anti}(\operatorname{ind}(g)(q))
\;\Rightarrow\; p = \operatorname{anti}(q).$$
Because $V(S^n)$ and the index set are finite, the right-hand side is a decidable
finite check.

*Proof.* ($\Rightarrow$) Given $F$, set $g(i) = F(i, \text{true})$. Equivariance
shows $\operatorname{ind}(g) = F$ on all vertices (the negative vertices agree by
equivariance), so $F$'s simpliciality transfers. ($\Leftarrow$) Given such $g$,
the induced map is equivariant (Proposition 6.2) and simplicial by hypothesis,
hence a $\mathbb{Z}_2$-map. $\square$

This reduction is what turns the infinite-looking question "does a
$\mathbb{Z}_2$-map exist?" into a terminating search, over the
$\big(2(n+1)\big)^{\,m+1}$ candidate assignments of positive-vertex images.

---

## 7. Sharpness: finite Borsuk–Ulam instances

Applying the decidable criterion at the base of the tower yields two genuine
finite obstructions.

**Theorem 7.1 (No $\mathbb{Z}_2$-map $S^1 \to S^0$).** There is no
$\mathbb{Z}_2$-map from the circle to the two-point sphere $S^0 = \{+e_0, -e_0\}$.

*Proof.* By Theorem 6.3 it suffices to check that no assignment
$g : \{0, 1\} \to V(S^0)$ (there are $2^2 = 4$) induces a simplicial map. Exhaustive
verification: for any $g$, the two positive vertices $(0, T), (1, T)$ of $S^1$ must
map into the two-element set $V(S^0)$, so two of the four vertices $(0,T),(1,T)$
and their antipodes collide onto an antipodal pair without being antipodal in
$S^1$, violating simpliciality. $\square$

**Theorem 7.2 (No $\mathbb{Z}_2$-map $S^2 \to S^1$).** There is no
$\mathbb{Z}_2$-map from the $2$-sphere to the circle.

*Proof.* By Theorem 6.3, an exhaustive check over the $\big(2 \cdot 2\big)^{3} =
64$ candidate assignments $g : \{0,1,2\} \to V(S^1)$ shows none induces a
simplicial map: three positive vertices must be placed in $S^1$ so that no two
non-antipodal vertices land on an antipodal pair, which the pigeonhole structure
of $S^1$ (only two antipodal axes) forbids. $\square$

Theorem 7.2 is the combinatorial incarnation of the classical Borsuk–Ulam
statement that no continuous antipode-preserving map $S^2 \to S^1$ exists.

**Theorem 7.3 (Sharp suspension increment at the base).** Combining the
constructive lower bound with the obstructions above:
$$
\operatorname{coind}(S^0) = 0, \qquad \operatorname{coind}(S^1) = 1.
$$
Explicitly: $S^0$ admits a $\mathbb{Z}_2$-map to itself but none from $S^1$; and
$S^1$ admits $\mathbb{Z}_2$-maps from $S^0$ and from itself but none from $S^2$.
Therefore suspending $S^0$ to $S^1$ raises the coindex by exactly one.

*Proof.* $\operatorname{coind}(S^0) \ge 0$ (identity) and $< 1$ (Theorem 7.1);
$\operatorname{coind}(S^1) \ge 1$ (Theorem 5.2/Corollary 5.3) and $< 2$
(Theorem 7.2). $\square$

---

## 8. Applications and context

The coindex is not an isolated invariant; it is the driver of several landmark
results:

- **Chromatic numbers (Lovász).** For a graph $G$, the neighbourhood/box complex
  $\mathsf{B}(G)$ is a free $\mathbb{Z}_2$-complex and
  $\chi(G) \ge \operatorname{coind}(\mathsf{B}(G)) + 2$. This topological lower
  bound resolved the Kneser conjecture and founded topological combinatorics.
- **Fair division.** Necklace-splitting and consensus-halving theorems are
  Borsuk–Ulam consequences: a suitable equivariant map cannot avoid a balanced
  configuration.
- **Geometric bisection.** The ham-sandwich theorem — that $d$ finite measures in
  $\mathbb{R}^d$ can be simultaneously bisected by a hyperplane — is a direct
  corollary of the non-existence of certain $\mathbb{Z}_2$-maps.

In each case the operative fact is a coindex lower bound (something exists because
symmetry cannot be undone) together with an index/obstruction upper bound. The
present work supplies a clean, elementary, and fully constructive account of the
lower-bound side for the generating examples, the spheres, and the exact base-case
obstructions on the upper side.

---

## 9. Discussion and future work

The results here establish, unconditionally, the constructive lower bound
$\operatorname{coind}(S^n) \ge n$ realized by explicit suspended maps, together
with sharpness at the base of the tower. The complementary general upper bound
$\operatorname{coind}(S^n) \le n$ — the non-existence of a $\mathbb{Z}_2$-map
$S^{n+1} \to S^n$ in every dimension — is the full strength of Borsuk–Ulam/Tucker
and is proved here only in the two finite base cases. We highlight the natural
continuations:

1. **General Tucker's lemma.** Prove that no $\mathbb{Z}_2$-map $S^{n+1} \to S^n$
   exists for all $n$, via a combinatorial Tucker labelling argument on the
   cross-polytope, yielding $\operatorname{coind}(S^n) = n$ unconditionally.
2. **Abstract free $\mathbb{Z}_2$-complexes.** Generalize $\mathbb{Z}_2$-maps from
   spheres to arbitrary simplicial complexes carrying a free simplicial
   $\mathbb{Z}_2$-action; define $\operatorname{coind}$ and $\operatorname{ind}$ as
   supremum/infimum over $\mathbb{N} \cup \{\infty\}$; and prove
   $\operatorname{coind} \le \operatorname{ind}$ together with the join/suspension
   laws $\operatorname{coind}(X * Y) \ge \operatorname{coind}(X) +
   \operatorname{coind}(Y) + 1$.
3. **The excess $\operatorname{ind} - \operatorname{coind}$.** With both indices in
   hand, construct and study complexes of positive excess and its growth under
   suspension — the "maximal-excess programme."
4. **Deleted joins and the Lovász bound.** Connect the coindex of the
   neighbourhood/box complex to graph chromatic numbers via
   $\chi(G) \ge \operatorname{coind}(\cdot) + 2$.

**On the model.** The purely local (vertex-pair) form of simpliciality is exactly
equivalent to "faces map to faces" for cross-polytope complexes. This keeps every
statement decidable and every proof elementary while remaining faithful to the
topology: the lower bound is genuinely constructed, not assumed, and the base-case
obstructions are genuinely verified by exhaustive finite search.

---

## 10. Conclusion

We have given a self-contained combinatorial theory of free $\mathbb{Z}_2$-complexes
via cross-polytope spheres, built the suspension functor on antipode-equivariant
simplicial maps, and proved constructively that suspension raises the coindex,
that $\operatorname{coind}(S^n) \ge n$ with explicit witnesses, and that the
increment is exactly one at the base of the tower. The framework is elementary,
decidable, and extensible, and it isolates precisely which half of the
coindex-under-suspension programme is constructive and which awaits the general
Borsuk–Ulam/Tucker obstruction.
