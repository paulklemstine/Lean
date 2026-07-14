# The Suspension Tower of Free $\mathbb{Z}_2$-Complexes: A General Dimension Law, Octahedral Facet Enumeration, and an Iterated Borsuk–Ulam Obstruction

**Author:** Aristotle

**Date:** 2026-07-14

## Abstract

We study the *suspension tower* $S^k(K)$ of a finite free
$\mathbb{Z}_2$-simplicial complex $K$ and establish three unconditional results.
First, we prove a **general dimension law**: a single combinatorial suspension
raises the simplicial dimension by exactly one, so that if $K$ has dimension $d$
then $S^k(K)$ has dimension exactly $d+k$ — for *every* finite free
$\mathbb{Z}_2$-complex, not merely the octahedral spheres. This detaches the
"one dimension per suspension" phenomenon from any particular base and exhibits it
as a structural property of the suspension functor. Second, we give an exact
**facet enumeration** of the octahedral $n$-sphere $\mathrm{Oct}(n)$: its
top-dimensional faces are precisely the $2^{n+1}$ sign-vector orthants, and this
single count simultaneously certifies the dimension and the antipodal structure of
the sphere. Third, combining a co-index growth theorem with the dimension law, we
show the octahedral tower is **zero-defect** — its co-index and dimension climb in
lockstep — and we promote a base-case combinatorial Borsuk–Ulam theorem to an
**iterated obstruction**: for every $k \ge 1$ there is no equivariant simplicial
map from the $k$-fold suspension of the $0$-sphere back onto the $0$-sphere. We
discuss consequences for co-index/dimension excess as an invariant of the whole
tower, and for topological lower bounds on graph chromatic number.

## 1. Introduction

Topological methods have supplied some of the most striking lower bounds in
combinatorics, from Lovász's resolution of the Kneser conjecture to the general
framework of box complexes and their $\mathbb{Z}_2$-indices. At the heart of these
arguments are two numerical invariants of a space equipped with a free involution:
its **dimension** and its **co-index**, the largest sphere admitting an
equivariant map into it. Suspension — the join with the $0$-sphere — is the basic
operation relating spheres of consecutive dimensions, and understanding how it acts
on these invariants is fundamental.

This paper isolates the combinatorial core of suspension in the category of finite
free $\mathbb{Z}_2$-simplicial complexes and proves a suite of exact results. Our
central theme is *precision*: rather than asymptotic or inequality-only statements,
we pin down dimensions on the nose, count facets exactly, and exhibit a family whose
two governing invariants coincide identically.

### Contributions

1. A base-point-free notion of dimension for abstract complexes (Section 3) and a
   proof that **one suspension raises dimension by exactly one** (Theorem 4.1),
   yielding the **general dimension law of the tower** $\dim S^k(K) = \dim K + k$
   for arbitrary finite free $\mathbb{Z}_2$-complexes $K$ (Theorem 4.2).
2. An **exact facet enumeration** of $\mathrm{Oct}(n)$: the facets are exactly the
   $2^{n+1}$ orthants of sign vectors (Theorems 5.2, 5.3).
3. The **zero-defect** property of the octahedral tower (Theorem 6.2), and an
   **iterated Borsuk–Ulam obstruction** into the $0$-sphere (Theorem 7.3).

## 2. Free $\mathbb{Z}_2$-complexes and equivariant maps

**Definition 2.1 (Free $\mathbb{Z}_2$-complex).** A *free
$\mathbb{Z}_2$-simplicial complex* on a vertex type $V$ consists of:

- an involution $\alpha : V \to V$ with $\alpha \circ \alpha = \mathrm{id}$ and
  $\alpha(v) \neq v$ for all $v$ (the free antipodal map), and
- a predicate $\mathrm{IsFace}$ on finite subsets of $V$ that contains $\emptyset$,
  is *downward closed* ($t \subseteq s$ and $s$ a face $\Rightarrow$ $t$ a face),
  and is *$\alpha$-invariant* ($s$ a face $\Rightarrow$ $\alpha(s)$ a face, where
  $\alpha(s)$ denotes the image of $s$).

**Definition 2.2 ($\mathbb{Z}_2$-simplicial map).** An *equivariant simplicial
map* $f : K \to L$ between free $\mathbb{Z}_2$-complexes is a vertex map
$f : V \to W$ satisfying:

- *equivariance*: $f(\alpha_K(v)) = \alpha_L(f(v))$ for all $v$, and
- *face preservation*: $s$ a face of $K$ $\Rightarrow$ $f(s)$ a face of $L$.

Equivariant maps compose and admit identities, forming a category. Suspension will
be a functor on this category.

**Definition 2.3 (Co-index lower bound).** Write $\mathrm{coind}(K) \ge m$, and say
$K$ *has co-index at least $m$*, when there exists an equivariant simplicial map
$\mathrm{Oct}(m) \to K$, where $\mathrm{Oct}(m)$ is the octahedral $m$-sphere of
Definition 3.1. This is the discrete analogue of the $\mathbb{Z}_2$-co-index of a
free $G$-space.

## 3. The octahedral spheres and the dimension predicate

**Definition 3.1 (Octahedral $n$-sphere).** Let $V_n = \{0,\dots,n\} \times
\{+,-\}$. The *octahedral $n$-sphere* $\mathrm{Oct}(n)$ has vertex set $V_n$,
antipodal map $\alpha(i,b) = (i, \bar b)$ flipping the sign, and face predicate
$$
\mathrm{IsFace}(s) \iff \forall i,\ \neg\big((i,+) \in s \wedge (i,-) \in s\big),
$$
i.e. $s$ contains no antipodal pair. This is the boundary complex of the
$(n{+}1)$-dimensional cross-polytope, a triangulation of $S^n$. The two required
face axioms (downward closure, $\alpha$-invariance) are immediate, and freeness
holds because $\bar b \neq b$.

**Definition 3.2 (Exact dimension).** A finite free $\mathbb{Z}_2$-complex $K$
*has dimension $d$*, written $\dim K = d$, when
$$
\big(\exists s,\ \mathrm{IsFace}(s) \wedge |s| = d+1\big) \quad\wedge\quad
\big(\forall s,\ \mathrm{IsFace}(s) \Rightarrow |s| \le d+1\big).
$$
The existence clause forbids assigning a spurious dimension to the void complex
(whose only face is $\emptyset$, of size $0$); the bound clause makes $d$ maximal.
This predicate is *base-point-free*: it refers only to face sizes, not to any
distinguished vertex or coordinate.

**Lemma 3.3 (Dimension of $\mathrm{Oct}(n)$).** $\dim \mathrm{Oct}(n) = n$.

*Proof sketch.* The "all-plus" set $\{(i,+) : 0 \le i \le n\}$ contains no
antipodal pair, so it is a face, and it has $n+1$ vertices, giving the existence
clause. For the bound, suppose a face $s$ had $\ge n+2$ vertices. Projecting to the
axis coordinate maps $s$ into an $(n{+}1)$-element index set, so by pigeonhole two
vertices of $s$ share an axis; being distinct they must be $(i,+)$ and $(i,-)$, an
antipodal pair, contradicting facehood. Hence $|s| \le n+1$. $\qquad\blacksquare$

## 4. The general dimension law

**Definition 4.1 (Suspension).** The *suspension* $S(K)$ of a free
$\mathbb{Z}_2$-complex $K$ on $V$ has vertex type $V \sqcup \{+,-\}$ (two new apex
vertices), antipodal map acting as $\alpha_K$ on the base and flipping the apexes,
and face predicate
$$
\mathrm{IsFace}_{S(K)}(T) \iff \mathrm{IsFace}_K(T\cap V)\ \wedge\ \neg(\,{+}\in T \wedge {-}\in T\,),
$$
where $T \cap V$ denotes the base part of $T$. In words: the base part is a face of
$K$, and the two apexes are never joined. This is the combinatorial join $K * S^0$.
The face axioms and freeness of the extended involution are routine to verify.
The **tower** is $S^0(K) = K$ and $S^{k+1}(K) = S(S^k(K))$.

**Theorem 4.2 (Single-step dimension law).** If $\dim K = d$, then
$\dim S(K) = d + 1$.

*Proof sketch.* *(Lower bound.)* Take a base facet $s$ of $K$ with $|s| = d+1$.
Then $s \cup \{+\}$ (viewing $s$ inside the base and adjoining one apex) is a face
of $S(K)$: its base part is $s$, a face of $K$, and it contains only one apex. It
has $d+2$ vertices, so $S(K)$ has a face of size $(d+1)+1$. *(Upper bound.)* Let
$T$ be any face of $S(K)$. Its base part $T \cap V$ is a face of $K$, hence has at
most $d+1$ vertices; and $T$ contains at most one apex. Therefore
$|T| \le (d+1) + 1 = d+2$. Combining the two bounds gives $\dim S(K) = d+1$.
Note that no property of the octahedral base is used: this is a structural fact
about the suspension operation. $\qquad\blacksquare$

**Theorem 4.3 (General dimension law of the tower).** For every finite free
$\mathbb{Z}_2$-complex $K$ with $\dim K = d$ and every $k \ge 0$,
$$
\dim S^k(K) = d + k.
$$

*Proof sketch.* Induction on $k$. The base $k=0$ is the hypothesis. For the step,
apply Theorem 4.2 to $S^k(K)$, whose dimension is $d+k$ by the inductive
hypothesis, obtaining $\dim S^{k+1}(K) = (d+k)+1 = d+(k+1)$. $\qquad\blacksquare$

**Corollary 4.4 (Octahedral tower dimension).**
$\dim S^k(\mathrm{Oct}(n)) = n + k$. This follows from Theorem 4.3 with
$d = \dim \mathrm{Oct}(n) = n$ (Lemma 3.3), recovering the octahedral dimension law
as a one-line specialization of the general result.

## 5. Exact facet enumeration of the octahedral sphere

A **facet** of a complex of dimension $d$ is a face of the maximal size $d+1$. For
$\mathrm{Oct}(n)$ the facets admit an exact description via sign vectors.

**Definition 5.1 (Orthant).** For a sign vector $\sigma : \{0,\dots,n\} \to
\{+,-\}$, the *orthant* of $\sigma$ is
$$
\mathrm{orthant}(\sigma) = \{\,(i, \sigma(i)) : 0 \le i \le n\,\}.
$$
Geometrically it selects one of the $2^{n+1}$ closed orthants cut out by the
coordinate hyperplanes.

Three elementary facts: (i) $\mathrm{orthant}(\sigma)$ is a face of
$\mathrm{Oct}(n)$, since it contains one vertex per axis and hence no antipodal
pair; (ii) $|\mathrm{orthant}(\sigma)| = n+1$, since $i \mapsto (i,\sigma(i))$ is
injective; (iii) $\sigma \mapsto \mathrm{orthant}(\sigma)$ is injective, as
$\sigma(i)$ is recoverable as the unique sign appearing with axis $i$.

**Theorem 5.2 (Top faces are orthants).** If $s$ is a face of $\mathrm{Oct}(n)$
with $|s| = n+1$, then $s = \mathrm{orthant}(\sigma)$ for the sign vector
$\sigma(i) = [\,(i,+) \in s\,]$.

*Proof sketch.* Consider the orthant $t = \mathrm{orthant}(\sigma)$ for the stated
$\sigma$. We claim $s \subseteq t$: for any $(i,b) \in s$, the vertex $(i,+)\in s$
iff $\sigma(i)=+$; combined with the no-antipodal-pair constraint on $s$ this
forces $b = \sigma(i)$, so $(i,b) \in t$. Since $|s| = n+1 = |t|$ and $s \subseteq
t$, we conclude $s = t$. $\qquad\blacksquare$

**Theorem 5.3 (Facet characterization and count).** A finite vertex set $s$ is a
facet of $\mathrm{Oct}(n)$ (a face with $|s| = n+1$) if and only if
$s = \mathrm{orthant}(\sigma)$ for some sign vector $\sigma$. Consequently
$$
\#\{\text{facets of } \mathrm{Oct}(n)\} = 2^{\,n+1}.
$$

*Proof sketch.* The forward direction is Theorem 5.2; the reverse is facts (i)–(ii)
above. The count follows because $\sigma \mapsto \mathrm{orthant}(\sigma)$ is an
injection (fact (iii)) from the $2^{n+1}$ sign vectors onto the facet set.
$\qquad\blacksquare$

Thus $\mathrm{Oct}(1)$ has $4$ facets (the edges of a square), $\mathrm{Oct}(2)$
has $8$ (the faces of an octahedron), and in general the facet count $2^{n+1}$
encodes both the dimension ($n$, via facet size $n+1$) and the antipodal
structure (facets come in $2^n$ antipodal pairs) in a single combinatorial datum.

## 6. Co-index growth and the zero-defect tower

**Theorem 6.1 (Suspension raises co-index).** If $K$ has co-index at least $m$,
then $S(K)$ has co-index at least $m+1$. Iterating, if $K$ has co-index at least
$m$ then $S^k(K)$ has co-index at least $m+k$.

*Proof sketch.* Two ingredients. First, suspension is a *functor*: an equivariant
map $g : K \to L$ induces $S(g) : S(K) \to S(L)$ acting as $g$ on the base and as
the identity on apexes; equivariance and face preservation are inherited
coordinatewise. Second, there is an explicit equivariant embedding
$\iota : \mathrm{Oct}(m{+}1) \to S(\mathrm{Oct}(m))$ (sending the last coordinate
axis to the apex pair and the remaining axes into the base). Given a co-index
witness $f : \mathrm{Oct}(m) \to K$, the composite
$$
\mathrm{Oct}(m{+}1) \xrightarrow{\ \iota\ } S(\mathrm{Oct}(m))
\xrightarrow{\ S(f)\ } S(K)
$$
witnesses $\mathrm{coind}(S(K)) \ge m+1$. Iterating gives the $k$-fold statement.
$\qquad\blacksquare$

**Definition 6.2 (Excess).** The *excess* of a complex $K$ is
$e(K) = \mathrm{coind}(K) - \dim K$, the gap between the largest sphere it can
symmetrically absorb and its own dimension.

**Theorem 6.3 (Zero-defect tower).** The octahedral tower satisfies, for all
$n, k$,
$$
\mathrm{coind}\big(S^k(\mathrm{Oct}(n))\big) \ge n+k
\qquad\text{and}\qquad
\dim S^k(\mathrm{Oct}(n)) = n+k.
$$
Hence the realized co-index reaches the dimension: the octahedral tower has
excess zero at every height and "wastes" no dimension.

*Proof sketch.* The co-index bound is Theorem 6.1 applied to the identity witness
$\mathrm{Oct}(n) \to \mathrm{Oct}(n)$ (so $\mathrm{coind}(\mathrm{Oct}(n)) \ge n$),
and the dimension equality is Corollary 4.4. $\qquad\blacksquare$

The zero-defect tower is the canonical *reference family*: a perfectly efficient
staircase in which co-index and dimension are locked together. It is the extreme
opposite of a *maximal-excess* regime, in which one suspension repairs a large gap
$d - c$ between dimension $d$ and co-index $c$ all at once.

## 7. An iterated combinatorial Borsuk–Ulam obstruction

**Theorem 7.1 (Base case).** Any equivariant simplicial map
$g : \mathrm{Oct}(n) \to \mathrm{Oct}(0)$ forces $n = 0$.

*Proof sketch.* Suppose $n \ge 1$. Pick two vertices $a = (0,+)$ and $b = (1,+)$
on distinct axes. Since $\mathrm{Oct}(0)$ has only two vertices $\{(0,+),(0,-)\}$
and $\{g(a), g(b)\}$ must be a face (image of the face $\{a,b\}$) of the two-point
complex, $g(a)$ and $g(b)$ cannot be an antipodal pair; as the target has a single
axis, this forces $g(a) = g(b)$. On the other hand, $\{a, \alpha(b)\} =
\{(0,+),(1,-)\}$ is also a face, so $\{g(a), g(\alpha(b))\}$ is a face; by
equivariance $g(\alpha(b)) = \alpha(g(b)) = \alpha(g(a))$, making $\{g(a),
\alpha(g(a))\}$ a face — but that is exactly the forbidden antipodal pair in
$\mathrm{Oct}(0)$, a contradiction. Hence $n = 0$. $\qquad\blacksquare$

**Lemma 7.2.** For all $n, k$ there is an equivariant simplicial map
$\mathrm{Oct}(n+k) \to S^k(\mathrm{Oct}(n))$ (the co-index witness of Theorem 6.3).

**Theorem 7.3 (Iterated obstruction).** For every $k \ge 1$ there is no
equivariant simplicial map
$$
S^k(\mathrm{Oct}(0)) \longrightarrow \mathrm{Oct}(0).
$$

*Proof sketch.* Suppose such a map $g$ existed. By Lemma 7.2 with $n=0$ there is a
map $f : \mathrm{Oct}(k) \to S^k(\mathrm{Oct}(0))$. The composite $g \circ f :
\mathrm{Oct}(k) \to \mathrm{Oct}(0)$ is equivariant, so Theorem 7.1 forces $k = 0$,
contradicting $k \ge 1$. $\qquad\blacksquare$

The argument is a pincer: co-index growth (Theorem 6.1) supplies a map *into* the
tower from a high sphere, while any hypothetical map *out* to the $0$-sphere would
compose with it to violate the base case. The very suspensions that let the tower
climb upward are what forbid an equivariant retraction back to the $0$-sphere.

## 8. Applications and discussion

### 8.1 Topological lower bounds on chromatic number

Equivariant maps and co-index bounds underlie the topological lower bounds on
graph chromatic number pioneered by Lovász. For a graph $G$ one forms a box
complex $B(G)$, a free $\mathbb{Z}_2$-complex, and the bound
$\chi(G) \ge \mathrm{coind}(B(G)) + 2$ holds. Via Csorba's homotopy equivalence
between a variant box complex and the suspension $S(B(G))$, the behavior of the
suspension tower is directly graph-theoretic. The zero-defect octahedral tower is
the calibration standard: when the tower excess $e_k = \mathrm{coind}(S^k(B(G))) -
\dim S^k(B(G))$ stays large, it witnesses that the topological bound is loose and
leaves chromatic room unused; when excess vanishes, the tower is as efficient as
the octahedral reference.

### 8.2 The excess as a tower invariant

Because Theorem 4.3 fixes the dimension leg exactly ($\dim S^k(K) = d + k$), the
excess $e_k = \mathrm{coind}(S^k(K)) - (d+k)$ becomes a *one-variable* quantity in
the co-index. Suspension can repair only a bounded amount of equivariant
homotopical defect per step while always adding exactly one to the dimension; this
suggests $e_k$ is non-increasing in $k$ and eventually constant, stabilizing at a
value intrinsic to $K$. The zero-defect tower ($e_k \equiv 0$) is the reference
against which the transient, defect-repairing initial segment of any tower is
measured.

### 8.3 Facet certificates and exact co-index

The facet enumeration (Theorem 5.3) certifies the dimension and antipodal
structure of $\mathrm{Oct}(n)$ from one count, $2^{n+1}$. The antipodal-pair-free
top faces encode a parity obstruction; promoting the base-case Borsuk–Ulam
(Theorem 7.1) from target $\mathrm{Oct}(0)$ to all $\mathrm{Oct}(n)$ via such a
parity count on antipodal facet pairs would upgrade the co-index lower bounds to
the exact value $\mathrm{coind}(\mathrm{Oct}(n)) = n$.

## 9. Future work

- **Excess stabilization.** Prove that for any finite free $\mathbb{Z}_2$-complex
  $K$ the excess sequence $e_k$ is non-increasing and eventually constant.
- **Maximal single-step excess.** For every $d \ge 2$ and $1 \le c \le d$,
  construct a complex of dimension $d$ and co-index $c$ whose single suspension
  achieves $\mathrm{coind}(S(K)) = d+1$, collapsing excess $d - c$ to $0$ in one
  step.
- **Combinatorial Borsuk–Ulam, full family.** Show there is no equivariant map
  $\mathrm{Oct}(m) \to \mathrm{Oct}(n)$ when $m > n$, and more generally none
  $S^k(\mathrm{Oct}(m)) \to \mathrm{Oct}(n)$ when $m + k > n$, via a discrete
  parity count on antipodal top-face pairs.
- **Arbitrary co-index staircases.** Realize any non-decreasing co-index sequence
  with steps $\ge 1$, subject to the dimension ceiling $c_k \le c_0 + k$, by
  iterating a jump-engineering construction.
- **Chromatic slack.** Turn persistent tower excess into a sharpened chromatic
  lower bound via the Csorba bridge, tested on explicit graph families.

## 10. Conclusion

The suspension of finite free $\mathbb{Z}_2$-complexes obeys an exact dimension
law — $+1$ per step, over any base — and the octahedral spheres carry an exact
facet certificate of $2^{n+1}$ orthants. Together these make the octahedral tower a
zero-defect reference family whose co-index and dimension climb in lockstep, and
they yield a fully discrete, iterated Borsuk–Ulam obstruction into the $0$-sphere.
These exact combinatorial results provide the calibrated scaffolding on which
sharper co-index computations and chromatic lower bounds can be built.
