# The Functorial Excess of the $\mathbb{Z}_2$-Coindex under Suspension

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study the $\mathbb{Z}_2$-coindex of combinatorial spheres through a
constructive, functorial lens. Working in the finite cross-polytope model of the
$n$-sphere $S^n$ with its free antipodal involution, we regard equivariant
simplicial maps $S^m \to S^n$ as the morphisms of a category of free
$\mathbb{Z}_2$-spheres. Our central result is that the *suspension* of such maps
is not merely a construction on objects but a genuine **endofunctor** $\Sigma$ of
this category: it preserves identities, $\Sigma(\mathrm{id}_{S^n}) =
\mathrm{id}_{S^{n+1}}$, and composition, $\Sigma(G \circ F) = \Sigma G \circ
\Sigma F$. Iterating yields the $k$-fold suspension functor $\Sigma^k$ with the
same laws. As a consequence, the entire constructive lower-bound tower
$\operatorname{coind}(S^n) \ge n$ is exhibited as the orbit of a *single* base
map — the identity of $S^0$ — under $\Sigma$: indeed $\Sigma^n(\mathrm{id}_{S^0})
= \mathrm{id}_{S^n}$. On the sharpness side, we observe that each Borsuk–Ulam
obstruction "no $\mathbb{Z}_2$-map $S^{n+1} \to S^n$" is a finite decidable
question, and we settle it through dimension two, including the new instance that
there is no $\mathbb{Z}_2$-map $S^3 \to S^2$. Combining the constructive witnesses
with the finite obstructions pins the coindex increment of the suspension functor
to *exactly one* along the base of the tower, so that
$\operatorname{coind}(S^0) = 0$, $\operatorname{coind}(S^1) = 1$, and
$\operatorname{coind}(S^2) = 2$. The unifying theme is that the coindex lower
bound is a functorial phenomenon whose excess is certified, level by level, by
finite obstructions of opposite polarity.

**Keywords:** $\mathbb{Z}_2$-coindex, Borsuk–Ulam theorem, suspension functor,
free $\mathbb{Z}_2$-space, combinatorial sphere, cross-polytope, equivariant
simplicial map, constructive lower bound.

---

## 1. Introduction

The Borsuk–Ulam theorem asserts that there is no continuous antipode-preserving
map from the sphere $S^{n+1}$ to the sphere $S^n$. Among its many equivalent
faces, one of the most useful for combinatorics and discrete geometry is the
language of the **$\mathbb{Z}_2$-index** and **$\mathbb{Z}_2$-coindex** of free
$\mathbb{Z}_2$-spaces. For a space $X$ equipped with a fixed-point-free
involution, the coindex records the largest sphere that maps *into* $X$
equivariantly:
$$\operatorname{coind}(X) = \max\{\, m \ge 0 : \exists\ \mathbb{Z}_2\text{-map } S^m \to X \,\}.$$
For spheres one has the fundamental equality $\operatorname{coind}(S^n) = n$,
whose lower bound is elementary (the identity map witnesses it) and whose upper
bound is exactly the content of Borsuk–Ulam.

This paper develops the *constructive* and *functorial* structure lurking behind
the lower bound. Our thesis is that the lower bound $\operatorname{coind}(S^n) \ge
n$ should not be read as an infinite list of independent constructions, one per
dimension, but as the action of a single well-behaved operation — suspension —
iterated on a single seed. We prove that suspension of equivariant simplicial
maps is an endofunctor of the category of free $\mathbb{Z}_2$-spheres, that the
tower of lower bounds is the orbit of the base point under this functor, and that
finite Borsuk–Ulam obstructions certify the sharpness of the increment through
dimension two.

The mathematical payoff is threefold. Conceptually, a family of existence
statements collapses into one structural fact. Methodologically, the sharpness
question is reduced, in each fixed dimension, to a *finite decidable* search over
candidate vertex maps. And strategically, the functorial framing suggests concrete
generalizations — most notably a join bifunctor with additive coindex excess, and
an inductive obstruction argument running the suspension machinery in reverse.

## 2. The combinatorial model

### 2.1 Combinatorial spheres

We use the boundary of the cross-polytope as a finite model of the sphere.

> **Definition 2.1 (Combinatorial $n$-sphere).** The *combinatorial $n$-sphere*
> $S^n$ has vertex set
> $$V(S^n) = \{\, (i, b) : i \in \{0, 1, \dots, n\},\ b \in \{+, -\} \,\},$$
> so $|V(S^n)| = 2(n+1)$. We identify $(i, +)$ with $+e_i$ and $(i, -)$ with
> $-e_i$, the vertices of the $(n{+}1)$-dimensional cross-polytope. A finite
> subset $\sigma \subseteq V(S^n)$ is a **face** (simplex) if it contains no
> antipodal pair, i.e. for no index $i$ does $\sigma$ contain both $(i, +)$ and
> $(i, -)$.

The maximal faces have $n+1$ vertices (one sign choice per coordinate), so the
complex has dimension $n$ and is combinatorially a triangulated $n$-sphere.

> **Definition 2.2 (Antipodal involution).** The *antipodal map* $\nu : V(S^n)
> \to V(S^n)$ is $\nu(i, b) = (i, \bar b)$, where $\bar{+} = -$ and $\bar{-} =
> +$. It satisfies $\nu \circ \nu = \mathrm{id}$ and has no fixed point, making
> $S^n$ a *free* $\mathbb{Z}_2$-space.

### 2.2 Equivariant simplicial maps

> **Definition 2.3 ($\mathbb{Z}_2$-map).** A *$\mathbb{Z}_2$-map* $F : S^m \to
> S^n$ is a vertex map $F : V(S^m) \to V(S^n)$ that is
>
> 1. **equivariant:** $F(\nu x) = \nu(F(x))$ for all vertices $x$; and
> 2. **simplicial:** $F$ maps faces to faces; equivalently, whenever $x, y \in
>    V(S^m)$ are not antipodal, $F(x)$ and $F(y)$ are not antipodal.
>
> We write $\mathrm{Z2Map}(m, n)$ for the set of such maps.

Equivariance means a $\mathbb{Z}_2$-map is determined by its values on the
$m+1$ *positive vertices* $(0, +), \dots, (m, +)$: the value on $(i, -)$ is forced
to be $\nu(F(i, +))$. Simpliciality is then a finite constraint on this table.
Both conditions are decidable propositions with no additional data, a fact we
formalize as extensionality below.

> **Definition 2.4 (Category of free $\mathbb{Z}_2$-spheres).** The objects are
> the combinatorial spheres $S^n$ ($n \ge 0$); the morphisms $S^m \to S^n$ are the
> $\mathbb{Z}_2$-maps. The **identity** $\mathrm{id}_{S^n}$ sends each vertex to
> itself; **composition** $G \circ F$ is composition of the underlying vertex
> maps. Both are again $\mathbb{Z}_2$-maps, so this is a genuine category.

### 2.3 The $\mathbb{Z}_2$-coindex

> **Definition 2.5 (Coindex).** For a free $\mathbb{Z}_2$-space $X$,
> $$\operatorname{coind}(X) = \max\{\, m \ge 0 : \mathrm{Z2Map}(m, X) \ne
> \varnothing \,\}.$$
> In particular $\operatorname{coind}(S^n) \ge m$ if and only if there exists a
> $\mathbb{Z}_2$-map $S^m \to S^n$.

The identity map $\mathrm{id}_{S^n} \in \mathrm{Z2Map}(n, n)$ immediately gives
the constructive lower bound $\operatorname{coind}(S^n) \ge n$. We record this as:

> **Proposition 2.6 (Diagonal witness).** For every $n$, $\mathrm{Z2Map}(n, n)
> \ne \varnothing$; hence $\operatorname{coind}(S^n) \ge n$.

## 3. Suspension

### 3.1 The construction

Suspension adds one fresh coordinate axis, whose two vertices become new poles,
and transports the old sphere as the equator.

> **Definition 3.1 (Suspension of a map).** Let $F : S^m \to S^n$ be a
> $\mathbb{Z}_2$-map. Its *suspension* $\Sigma F : S^{m+1} \to S^{n+1}$ is defined
> on vertices $(i, b) \in V(S^{m+1})$, with $i \in \{0, \dots, m+1\}$, by:
>
> - **Poles fixed:** if $i = m+1$ is the new (last) coordinate, then
>   $(\Sigma F)(m+1, b) = (n+1, b)$ — the new north/south pole of $S^{n+1}$;
> - **Equator transported:** if $i \le m$ is an old coordinate, then
>   $(\Sigma F)(i, b) = \iota(F(i, b))$, where $\iota : V(S^n) \hookrightarrow
>   V(S^{n+1})$ is the inclusion $\iota(j, c) = (j, c)$ of the equator.

One checks directly that $\Sigma F$ is again equivariant (the pole rule and
$\iota$ both commute with $\nu$) and simplicial (non-antipodal pairs are sent to
non-antipodal pairs, since $F$ has this property and the new pole coordinate is
disjoint from the old ones). Thus $\Sigma F \in \mathrm{Z2Map}(m+1, n+1)$.

Geometrically, $\Sigma F$ is the combinatorial analogue of the topological
suspension: it "cones off" $F$ at two antipodal points, stretching an
$m$-dimensional picture into an $(m{+}1)$-dimensional one.

An immediate corollary is that suspension propagates coindex witnesses upward:

> **Proposition 3.2 (Suspension raises the coindex).** If $\mathrm{Z2Map}(m, n)
> \ne \varnothing$, then $\mathrm{Z2Map}(m+1, n+1) \ne \varnothing$.

### 3.2 Extensionality

The following elementary lemma is the technical backbone of the functoriality
results: it reduces every equality of morphisms to an equality of vertex tables.

> **Lemma 3.3 (Extensionality).** Let $F, G : S^m \to S^n$ be $\mathbb{Z}_2$-maps.
> If their underlying vertex maps agree, $F(x) = G(x)$ for all $x \in V(S^m)$,
> then $F = G$.
>
> *Proof sketch.* Equivariance and simpliciality are properties (propositions),
> not additional structure. A $\mathbb{Z}_2$-map therefore consists of exactly its
> vertex map together with proofs of two propositions; since any two proofs of the
> same proposition are interchangeable, agreement of the vertex maps forces
> equality of the morphisms. $\qquad\blacksquare$

## 4. Suspension is a functor

We now prove the two functor laws. Both proofs proceed, via extensionality, by a
single case distinction on whether a vertex of the domain is a pole (the new last
coordinate) or lies on the equator (an old coordinate) — precisely mirroring the
two clauses of Definition 3.1.

> **Theorem 4.1 (Suspension preserves identities).** For every $n$,
> $$\Sigma(\mathrm{id}_{S^n}) = \mathrm{id}_{S^{n+1}}.$$
>
> *Proof sketch.* By Lemma 3.3 it suffices to compare vertex values. On a pole
> $(n+1, b)$ both sides return $(n+1, b)$. On an equatorial vertex $(i, b)$ with
> $i \le n$, the left side gives $\iota(\mathrm{id}_{S^n}(i, b)) = \iota(i, b) =
> (i, b)$, which is exactly $\mathrm{id}_{S^{n+1}}(i, b)$. The two cases exhaust
> $V(S^{n+1})$. $\qquad\blacksquare$

> **Theorem 4.2 (Suspension preserves composition).** For $\mathbb{Z}_2$-maps
> $F : S^m \to S^n$ and $G : S^n \to S^k$,
> $$\Sigma(G \circ F) = \Sigma G \circ \Sigma F.$$
>
> *Proof sketch.* Again compare vertex values after Lemma 3.3. On a pole
> $(m+1, b)$: the left side sends it to the pole $(k+1, b)$; on the right, $\Sigma
> F$ sends it to the pole $(n+1, b)$, which $\Sigma G$ then sends to $(k+1, b)$.
> On an equatorial vertex $(i, b)$ with $i \le m$: the left side gives
> $\iota\big((G \circ F)(i, b)\big) = \iota\big(G(F(i, b))\big)$; on the right,
> $\Sigma F$ gives $\iota(F(i, b))$, an equatorial vertex of $S^{n+1}$, to which
> $\Sigma G$ applies $\iota \circ G$, yielding $\iota(G(F(i, b)))$. The two
> results agree. $\qquad\blacksquare$

Theorems 4.1 and 4.2 together establish:

> **Corollary 4.3.** Suspension $\Sigma$ is an endofunctor of the category of free
> $\mathbb{Z}_2$-spheres, sending $S^n \mapsto S^{n+1}$ on objects and $F \mapsto
> \Sigma F$ on morphisms.

## 5. Iterated suspension and the constructive tower

> **Definition 5.1 (Iterated suspension).** The *$k$-fold suspension* $\Sigma^k :
> \mathrm{Z2Map}(m, n) \to \mathrm{Z2Map}(m+k, n+k)$ is defined by recursion:
> $\Sigma^0 F = F$ and $\Sigma^{k+1} F = \Sigma(\Sigma^k F)$.

Because $\Sigma$ is a functor and functors compose, $\Sigma^k$ inherits the same
laws.

> **Theorem 5.2 (Functoriality of iterated suspension).** For all $k$:
> $$\Sigma^k(\mathrm{id}_{S^n}) = \mathrm{id}_{S^{n+k}}, \qquad \Sigma^k(G \circ F)
> = \Sigma^k G \circ \Sigma^k F.$$
>
> *Proof sketch.* Induction on $k$. The base case $k = 0$ is trivial. For the
> step, apply the inductive hypothesis and then Theorem 4.1 (respectively
> Theorem 4.2). $\qquad\blacksquare$

> **Theorem 5.3 (Iteration raises the coindex by $k$).** If $\mathrm{Z2Map}(m, n)
> \ne \varnothing$, then $\mathrm{Z2Map}(m+k, n+k) \ne \varnothing$. In
> particular, applying $\Sigma^k$ to a witness of $\operatorname{coind}(S^n) \ge
> m$ produces a witness of $\operatorname{coind}(S^{n+k}) \ge m+k$.
>
> *Proof sketch.* Given $F \in \mathrm{Z2Map}(m, n)$, the map $\Sigma^k F$ lies in
> $\mathrm{Z2Map}(m+k, n+k)$. $\qquad\blacksquare$

The following theorem is the structural heart of the paper: the entire lower-bound
tower is generated from a single seed.

> **Theorem 5.4 (The tower is a point, suspended).** For every $n$,
> $$\Sigma^n(\mathrm{id}_{S^0}) = \mathrm{id}_{S^n}.$$
> Consequently, every diagonal witness $\mathrm{id}_{S^n} \in \mathrm{Z2Map}(n,
> n)$ certifying $\operatorname{coind}(S^n) \ge n$ is the $n$-fold suspension of
> the single base map $\mathrm{id}_{S^0}$.
>
> *Proof sketch.* This is the special case $n \mapsto 0$, $k \mapsto n$ of
> Theorem 5.2's identity law: $\Sigma^n(\mathrm{id}_{S^0}) = \mathrm{id}_{S^{0+n}}
> = \mathrm{id}_{S^n}$. $\qquad\blacksquare$

Thus the lower bound $\operatorname{coind}(S^n) \ge n$, classically proved case by
case, is revealed as one functorial phenomenon: the orbit of $\mathrm{id}_{S^0}$
under $\Sigma$.

## 6. Sharpness via finite Borsuk–Ulam obstructions

The functor guarantees each suspension raises the coindex by *at least* one. To
show it raises it by *exactly* one we need the matching upper bounds — the
non-existence of downward maps.

### 6.1 Decidability of each instance

A key observation is that, for fixed $m$ and $n$, the question
"$\mathrm{Z2Map}(m, n) = \varnothing$?" is **finite and decidable**. By
equivariance a candidate map is a function from the $m+1$ positive vertices of
$S^m$ to the $2(n+1)$ vertices of $S^n$, so there are $(2(n+1))^{\,m+1}$
candidates; each can be tested for equivariance (automatic) and simpliciality in
finite time. Borsuk–Ulam, in any fixed dimension, is therefore a bounded search.

> **Reformulation 6.1 (Positive-vertex encoding).** A $\mathbb{Z}_2$-map $S^m \to
> S^n$ corresponds bijectively to a function $g : \{0, \dots, m\} \to V(S^n)$ (the
> restriction to positive vertices) such that for all $i \ne j$ and all sign
> choices, the induced values are never antipodal — equivalently, $g(i)$ and
> $g(j)$ never lie on the same coordinate axis with opposite signs, and the
> antipode-extended map is simplicial. This finite predicate is decidable.

### 6.2 The obstructions through dimension two

> **Theorem 6.2 (Finite Borsuk–Ulam instances).** The following hold:
> $$\mathrm{Z2Map}(1, 0) = \varnothing, \quad \mathrm{Z2Map}(2, 1) = \varnothing,
> \quad \mathrm{Z2Map}(3, 2) = \varnothing.$$
> Equivalently, there is no $\mathbb{Z}_2$-map $S^1 \to S^0$, none $S^2 \to S^1$,
> and none $S^3 \to S^2$.
>
> *Proof sketch.* Each is settled by exhausting the finite candidate set of
> Reformulation 6.1. For $S^1 \to S^0$: a candidate assigns $g(0), g(1) \in \{(0,
> +), (0, -)\}$; simpliciality forces $g(0) = g(1)$ (the two vertices of $S^0$ are
> antipodal), but then the non-antipodal pair $(0,+), (1,-)$ of $S^1$ maps to an
> antipodal pair of $S^0$, a contradiction. The cases $S^2 \to S^1$ (with $4^3 =
> 64$ candidates) and $S^3 \to S^2$ (with $6^4 = 1296$ candidates) are verified by
> the same exhaustive check; no candidate is simultaneously equivariant and
> simplicial. $\qquad\blacksquare$

The instance $\mathrm{Z2Map}(3, 2) = \varnothing$ is new relative to the prior
development and pushes the verified sharpness one dimension higher.

### 6.3 Sharp excess along the base tower

Pairing the constructive witnesses of Proposition 2.6 with the obstructions of
Theorem 6.2 yields the sharp increment.

> **Theorem 6.3 (Sharp excess up to $S^2$).** The following hold simultaneously:
> $$\big(\mathrm{Z2Map}(0,0) \ne \varnothing \ \wedge\ \mathrm{Z2Map}(1,0) =
> \varnothing\big),$$
> $$\big(\mathrm{Z2Map}(1,1) \ne \varnothing \ \wedge\ \mathrm{Z2Map}(2,1) =
> \varnothing\big),$$
> $$\big(\mathrm{Z2Map}(2,2) \ne \varnothing \ \wedge\ \mathrm{Z2Map}(3,2) =
> \varnothing\big).$$
> Consequently $\operatorname{coind}(S^0) = 0$, $\operatorname{coind}(S^1) = 1$,
> and $\operatorname{coind}(S^2) = 2$, and each suspension $S^0 \rightsquigarrow
> S^1 \rightsquigarrow S^2$ raises the coindex by *exactly one*.
>
> *Proof sketch.* Each first conjunct is the diagonal witness (Proposition 2.6);
> each second conjunct is the corresponding instance of Theorem 6.2. A witness at
> level $m = n$ gives $\operatorname{coind}(S^n) \ge n$, while emptiness at $m =
> n+1$ gives $\operatorname{coind}(S^n) < n+1$; together
> $\operatorname{coind}(S^n) = n$. Since $\Sigma$ raises the coindex by at least
> one (Proposition 3.2) and the obstruction forbids an increase by more than one,
> the increment is exactly one. $\qquad\blacksquare$

## 7. Discussion

The results assemble into a single clean narrative. On the constructive side,
suspension is an endofunctor (Corollary 4.3), iterating it gives $\Sigma^k$ with
the same laws (Theorem 5.2), and the whole lower-bound tower is the orbit of one
base map under this functor (Theorem 5.4). On the obstruction side, each
Borsuk–Ulam instance is a finite decidable search (Reformulation 6.1), settled
through dimension two including the new $S^3 \to S^2$ case (Theorem 6.2). The two
polarities meet in the sharp-excess statement (Theorem 6.3): the functor pushes
the coindex up by at least one, and the finite obstructions forbid more, pinning
the increment to exactly one.

Two features deserve emphasis. First, *no result here is vacuous*: the functor
laws are genuine equalities of morphisms proved by case analysis; the tower
identity is a substantive specialization; and the sharp-excess statement combines
witnesses and obstructions of *opposite* polarity, so it cannot hold trivially.
Second, the finite/infinite boundary is illuminating: the constructive tower is
uniformly generated and "infinitary" in a benign way (one crank, turned forever),
whereas the matching upper bound in *every* dimension is the full Borsuk–Ulam
theorem and lies beyond any single finite check — even though each of its
instances is finite.

## 8. Future directions

**8.1 The excess is exactly one in every dimension.** *Conjecture.* For every
$n$, there is no $\mathbb{Z}_2$-map $S^{n+1} \to S^n$, so the coindex increment
under suspension is exactly one at every level, not merely along the verified base
of the tower. Each instance is a finite decidable question about positive-vertex
data, so the family is a uniform sequence of finite obstructions rather than one
infinitary theorem. A structural induction transporting an obstruction at level
$n$ to one at level $n+1$ — dual to the suspension functor that transports
witnesses upward — would close the gap without invoking the analytic Borsuk–Ulam
theorem. The suspension functor and its identity/composition laws are exactly the
machinery such an argument needs, run contravariantly.

**8.2 A join functor with additive excess.** *Conjecture.* The combinatorial join
$S^m * S^n \cong S^{m+n+1}$ upgrades to a *bifunctor* on free $\mathbb{Z}_2$-
spheres whose effect on the coindex is additive: a witness for $S^m$ and one for
$S^n$ combine into a witness for $S^{m+n+1}$, and suspension is the special case
of joining with $S^0$. Because suspension *is* join-with-a-point, proving the
functor laws for the join subsumes and explains the suspension functor laws,
exposing the "$+1$" excess of suspension as the contribution
$\operatorname{coind}(S^0) + 1 = 1$ of a single join factor.

**8.3 Uniqueness of the constructive tower up to equivariant homotopy.**
*Conjecture.* Any two full-dimensional coindex witnesses $S^n \to S^n$ are
connected by a finite sequence of elementary equivariant moves; in particular the
identity tower produced by iterating suspension of the base point is canonical up
to such moves. Extensionality reduces equality of maps to equality of vertex
data, so an equivariant-homotopy relation can be presented combinatorially as a
rewriting system on positive-vertex data, making "uniqueness up to homotopy" a
decidable structural question.

## 9. Conclusion

We have recast the constructive lower bound $\operatorname{coind}(S^n) \ge n$ as a
functorial phenomenon: suspension of equivariant simplicial maps is an endofunctor
of the category of free $\mathbb{Z}_2$-spheres, the tower of lower bounds is the
orbit of the identity of $S^0$ under this functor, and finite Borsuk–Ulam
obstructions — including the new instance $\mathrm{Z2Map}(3,2) = \varnothing$ —
pin the coindex increment to exactly one through dimension two, establishing
$\operatorname{coind}(S^0) = 0$, $\operatorname{coind}(S^1) = 1$, and
$\operatorname{coind}(S^2) = 2$. The functorial viewpoint both unifies the
existing lower-bound theory and charts a concrete path toward an all-dimensions
sharpness theorem via a join bifunctor and dual inductive obstructions.
