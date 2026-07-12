# Tightness of the Isolation-Lemma Region Bound for Arbitrary Edge Offsets

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

The Isolation Lemma asserts that a random weight assignment to the elements of a
ground set makes the minimum-weight member of any set system unique with good
probability. Behind this probabilistic statement lies an exact combinatorial
quantity: for an inclusion-free hypergraph $H$ on $n$ vertices and integer weights
drawn from $\{0,\dots,d-1\}$, the number of *isolating* assignments (those with a
unique minimum-weight edge) is at least the **region bound**
$$B(n,d) \;=\; n\sum_{j=0}^{d-1} j^{\,n-1}.$$
It is known that the *singleton hypergraph* (all $1$-element edges) attains this
bound exactly with zero offsets. We deepen this picture in two directions. First,
we refute the natural **general tightness conjecture**: it is *not* true that every
inclusion-free hypergraph can be made extremal by choosing suitable real edge
offsets. A single-edge hypergraph makes every assignment isolating for *every*
offset, giving an offset-independent count of $d^n > B(n,d)$ (already $4 > 2$ at
$n=d=2$). Second, we exhibit a new, symmetric extremal witness: the **co-singleton
hypergraph** (all $(n-1)$-element edges) also attains $B(n,d)$ exactly with zero
offsets, via a min$\leftrightarrow$max reflection duality on the weight palette.
Thus the region bound has at least two symmetric extremal families, yet tightness
is a genuinely special structural property rather than a universal one attainable by
tuning.

## 1. Introduction

The Isolation Lemma of Mulmuley, Vazirani, and Vazirani is a cornerstone of
randomized computation. In its combinatorial form it concerns a **hypergraph**
$H$: a family of edges, each a subset of a vertex set $V = \{1,\dots,n\}$. A
**weight assignment** $w : V \to \{0,\dots,d-1\}$ assigns to each vertex one of $d$
integer values; there are $d^n$ assignments in all. Attaching a real **offset**
$f(S)$ to each edge $S$, the *adjusted weight* of an edge is
$$W_f(S, w) \;=\; f(S) + \sum_{v \in S} w(v).$$
The assignment $w$ is **isolating** for $(H, f)$ if there is a unique edge of
minimum adjusted weight.

Two standing assumptions make the theory clean and nontrivial:

- $H$ is **inclusion-free** (an *antichain*, or *Sperner family*): no edge is a
  subset of another.
- Weights are integers in the palette $\{0,\dots,d-1\}$.

A basic lower bound — which we call the **region bound** — states that every
nonempty inclusion-free hypergraph on $n$ vertices has at least
$$B(n,d) \;=\; n\sum_{j=0}^{d-1} j^{\,n-1}$$
isolating assignments. This quantity controls how much randomness the Isolation
Lemma requires, so understanding *when it is tight* is of direct interest.

It is known that the **singleton hypergraph** $H_1 = \{\{v\} : v \in V\}$ attains
$B(n,d)$ exactly with zero offsets. This paper answers the two most natural
follow-up questions.

**Question 1 (Universality).** Can *every* inclusion-free hypergraph be brought
down to the bound $B(n,d)$ by a suitable choice of real offsets $f$?

**Question 2 (Other witnesses).** Is the singleton family the *only* extremal
hypergraph, or are there others?

We answer Question 1 in the negative (Section 4) and Question 2 by exhibiting a
second, mirror-symmetric extremal family (Section 5). Section 3 gives a
self-contained derivation of the exact singleton count, which underlies both
results.

### 1.1 Summary of contributions

1. **Exact singleton count (Theorem 3.5).** The number of assignments in
   $\{0,\dots,d-1\}^n$ with a unique strict minimum vertex is exactly $B(n,d)$.
2. **Failure of general tightness (Theorem 4.3).** There is an inclusion-free,
   nonempty hypergraph whose isolating count is $d^n$ for *every* real offset, and
   $d^n \ne B(n,d)$ in general (e.g. $n=d=2$: $4 \ne 2$).
3. **A new extremal witness (Theorem 5.5).** The co-singleton hypergraph attains
   $B(n,d)$ exactly with zero offsets, via a reflection duality (Theorem 5.3).

## 2. Definitions

Throughout, $V = \{1,\dots,n\}$ and the palette is $D = \{0,1,\dots,d-1\}$.

**Definition 2.1 (Hypergraph).** A *hypergraph* on $V$ is a finite family $H$ of
subsets (edges) of $V$.

**Definition 2.2 (Inclusion-free).** $H$ is *inclusion-free* if for all $S,T \in H$
with $S \subseteq T$ we have $S = T$; equivalently, no edge is a proper subset of
another.

**Definition 2.3 (Weight assignment).** A *weight assignment* is a map
$w : V \to D$. There are $d^n$ of them.

**Definition 2.4 (Isolating assignment).** Given offsets $f : H \to \mathbb{R}$, an
assignment $w$ is *isolating for $(H,f)$* if there is a unique $S \in H$ with
$$f(S) + \sum_{v \in S} w(v) \;\le\; f(T) + \sum_{v \in T} w(v) \quad
\text{for all } T \in H.$$

**Definition 2.5 (Strict minimum / maximum).** An assignment $w$ *has a strict
minimum* if there is a vertex $i$ with $w(i) < w(j)$ for all $j \ne i$. It *has a
strict maximum* if there is a vertex $i$ with $w(j) < w(i)$ for all $j \ne i$.

**Definition 2.6 (Region bound).**
$$B(n,d) \;=\; n\sum_{j=0}^{d-1} j^{\,n-1}.$$
Small values: $B(2,2)=2$, $B(3,2)=3$, $B(2,3)=6$, $B(3,3)=15$, $B(4,3) = 4\cdot(0+1+8)=36$.

## 3. The exact singleton count

For the singleton hypergraph $H_1 = \{\{v\} : v \in V\}$ with zero offsets, the
adjusted weight of edge $\{v\}$ is simply $w(v)$. A unique minimum edge exists iff
$w$ has a strict minimum vertex. Thus counting isolating assignments for $H_1$ is
counting assignments with a strict minimum.

**Lemma 3.1 (Values above a threshold).** For any $m \in D$, the number of palette
values strictly greater than $m$ equals $d - 1 - m$.

*Proof.* The values above $m$ are $m+1, m+2, \dots, d-1$, of which there are
$d-1-m$. $\square$

**Lemma 3.2 (Fiber count).** Fix a vertex $i$ and a value $m \in D$. The number of
assignments $w$ with $w(i) = m$ and $w(j) > m$ for all $j \ne i$ is
$(d-1-m)^{\,n-1}$.

*Proof.* Vertex $i$ is pinned to $m$. Each of the remaining $n-1$ vertices must take
one of the $d-1-m$ values above $m$ (Lemma 3.1), independently. The count is the
product $(d-1-m)^{\,n-1}$. $\square$

**Lemma 3.3 (Winners at a fixed vertex).** For any fixed vertex $i$, the number of
assignments for which $i$ is the strict minimum equals
$$\sum_{j=0}^{d-1} j^{\,n-1}.$$

*Proof.* Partition the strict-min-at-$i$ assignments by the value $m = w(i)$. By
Lemma 3.2 the class with $w(i) = m$ has size $(d-1-m)^{\,n-1}$. Summing,
$$\sum_{m=0}^{d-1} (d-1-m)^{\,n-1} \;=\; \sum_{j=0}^{d-1} j^{\,n-1}$$
after the substitution $j = d-1-m$. Note the count is independent of $i$. $\square$

**Lemma 3.4 (Disjointness).** An assignment has at most one strict minimum vertex,
so the events "$i$ is the strict minimum" ($i \in V$) are pairwise disjoint, and the
set of assignments with a strict minimum is their disjoint union.

*Proof.* If both $i \ne i'$ were strict minima then $w(i) < w(i')$ and
$w(i') < w(i)$, a contradiction. $\square$

**Theorem 3.5 (Singleton tightness).** The number of assignments in $D^n$ with a
strict minimum vertex is exactly
$$n \sum_{j=0}^{d-1} j^{\,n-1} \;=\; B(n,d).$$

*Proof.* By Lemma 3.4 the strict-minimum set is the disjoint union over $i \in V$ of
the strict-min-at-$i$ sets, each of size $\sum_{j=0}^{d-1} j^{\,n-1}$ by Lemma 3.3.
There are $n$ vertices, so the total is $n\sum_{j=0}^{d-1} j^{\,n-1} = B(n,d)$.
$\square$

Hence the singleton hypergraph attains the region bound with equality — it is
*extremal*.

## 4. Failure of the general tightness conjecture

The freedom to choose real offsets is a continuum of parameters per edge. It is
tempting to believe this suffices to tune any inclusion-free hypergraph down to the
minimum $B(n,d)$. We refute this.

**Lemma 4.1 (Single-edge count).** Let $H = \{E\}$ consist of a single edge $E
\subseteq V$, and let $f$ be any offset. Then *every* assignment is isolating, so
the number of isolating assignments is $d^n$, independent of $f$.

*Proof.* With one edge, the minimum adjusted weight is attained by $E$ alone, and it
is attained *uniquely* because there is no other edge to tie with. The uniqueness
condition of Definition 2.4 holds for every $w$. Hence all $d^n$ assignments are
isolating. $\square$

**Lemma 4.2 (A single edge is admissible).** A single-edge hypergraph $\{E\}$ is
nonempty and inclusion-free.

*Proof.* Nonemptiness is immediate. Inclusion-freeness is vacuous: the only pair of
edges is $(E,E)$, and $E \subseteq E$ forces $E = E$. $\square$

**Theorem 4.3 (General tightness fails).** There exist $n, d$ and a nonempty,
inclusion-free hypergraph $H$ on $n$ vertices such that for *every* real offset
$f$, the number of isolating assignments differs from $B(n,d)$.

*Proof.* Take $n = d = 2$ and $H = \{\{1,2\}\}$ (equivalently any single edge). By
Lemma 4.2, $H$ is nonempty and inclusion-free. By Lemma 4.1 the isolating count is
$d^n = 2^2 = 4$ for every offset $f$. But $B(2,2) = 2 \cdot (0^1 + 1^1) = 2 \ne 4$.
So no offset achieves the bound. $\square$

The single-edge example shows the failure is not marginal: the count is *frozen* at
$d^n$ and exceeds $B(n,d)$ by a genuine gap. Offsets are powerless against a
hypergraph that intrinsically over-counts.

**Remark 4.4 (Beyond the degenerate case).** The single edge is the cleanest
witness because its count is provably offset-independent. Computation indicates the
phenomenon is far broader: covering antichains such as $\{\{1,2\},\{1,3\}\}$
overshoot $B(n,d)$ for every offset as well (excess $\ge 1$ in small cases). A
formal proof quantifying over the *continuum* of offsets requires reducing offsets
to their finitely many order-types; this reduction is a natural next step
(Section 7).

## 5. A new extremal witness: the co-singleton hypergraph

We now show the region bound has a second extremal witness, dual to the singletons.

**Definition 5.1 (Co-singleton hypergraph).** The *co-singleton hypergraph* is
$$H_{n-1} \;=\; \{\, V \setminus \{v\} : v \in V \,\},$$
the family of all $(n-1)$-element edges.

**Lemma 5.2 (Admissibility).** $H_{n-1}$ is inclusion-free.

*Proof.* All edges have the same size $n-1$. Equal-size sets cannot properly
contain one another, so $S \subseteq T$ with $S,T \in H_{n-1}$ forces $S = T$.
$\square$

**Reduction to strict maxima.** With zero offsets, the adjusted weight of the edge
$V \setminus \{v\}$ is
$$\sum_{u \ne v} w(u) \;=\; \Big(\sum_{u \in V} w(u)\Big) - w(v).$$
The grand total $\sum_u w(u)$ is common to all edges, so *minimizing* the edge
weight over $v$ is equivalent to *maximizing* $w(v)$. Therefore a unique
minimum-weight edge exists iff $w$ has a unique strict *maximum* vertex. Isolating
assignments for $H_{n-1}$ are exactly the assignments with a strict maximum.

**Theorem 5.3 (Reflection duality).** Define the palette reflection
$\rho : D \to D$, $\rho(x) = d - 1 - x$, and lift it to assignments by
$(\rho \cdot w)(i) = \rho(w(i))$. Then $w$ has a strict minimum iff $\rho \cdot w$
has a strict maximum. Moreover $w \mapsto \rho \cdot w$ is an involutive bijection of
$D^n$.

*Proof.* $\rho$ is an order-reversing bijection of $D$: $x < y \iff \rho(y) <
\rho(x)$. Hence $w(i) < w(j)$ for all $j \ne i$ iff $(\rho\cdot w)(j) < (\rho\cdot
w)(i)$ for all $j \ne i$, i.e. $i$ is a strict minimum of $w$ iff it is a strict
maximum of $\rho \cdot w$. Since $\rho(\rho(x)) = x$, the map $w \mapsto \rho\cdot w$
is its own inverse, hence a bijection. $\square$

**Corollary 5.4 (Equinumerosity).** The number of assignments with a strict maximum
equals the number with a strict minimum.

*Proof.* The bijection of Theorem 5.3 carries the strict-minimum set onto the
strict-maximum set. $\square$

**Theorem 5.5 (Co-singleton tightness).** The number of isolating assignments for
the co-singleton hypergraph with zero offsets — equivalently, the number of
assignments with a unique strict maximum — is exactly
$$n \sum_{j=0}^{d-1} j^{\,n-1} \;=\; B(n,d).$$

*Proof.* By the reduction above, co-singleton isolating assignments are exactly
those with a strict maximum. By Corollary 5.4 these are equinumerous with the
strict-minimum assignments, which number $B(n,d)$ by Theorem 3.5. $\square$

Thus the co-singleton family is a second extremal witness, a mirror image of the
singletons under the palette reflection $\rho$.

## 6. Discussion

The results together sharpen the picture of extremality for the region bound.

**Tightness is structural, not tunable.** Theorem 4.3 shows the extra freedom of
real offsets does not confer universality: over-counting hypergraphs (already the
single edge) remain over-counting for every offset. Extremality is therefore a
property of the hypergraph's combinatorial structure, not something achievable by
weighting.

**A symmetry among extremal families.** Theorems 3.5 and 5.5 exhibit two extremal
witnesses — the $1$-uniform and $(n-1)$-uniform complete families — related by a
single involution, the reflection $\rho$ of the weight palette. This symmetry
suggests that extremal families come in dual pairs and that vertex-transitivity plus
a "sum-symmetry" condition may be the governing principle.

**Interpretation for randomness.** Because $B(n,d)$ controls the randomness budget
of the Isolation Lemma, tightness for the singleton and co-singleton families
certifies that the analysis is best-possible for them; the failure of general
tightness certifies that many set systems are strictly *more* isolation-rich than
the floor, an asymmetry that any fine-grained analysis must respect.

## 7. Future directions

- **Characterise the extremal hypergraphs.** For $n=3$, computation shows exactly
  the singletons and the all-pairs (co-singleton) families reach the bound.
  Conjecture: for the offset-free problem, an antichain attains $B(n,d)$ iff it is
  vertex-transitive and "sum-symmetric" (e.g. suitable $k$-uniform complete
  designs). A formal characterisation is open.
- **Covering antichains still fail.** Even covering antichains such as
  $\{\{1,2\},\{1,3\}\}$ overshoot the bound for every offset (verified
  computationally, excess $\ge 1$). A proof of failure quantifying over *all* real
  offsets — not just the degenerate single-edge case — would strengthen
  Theorem 4.3. The obstacle is reducing the continuum of offsets to the finite set
  of order-types.
- **Intermediate $k$-uniform families.** Singletons ($k=1$) and co-singletons
  ($k=n-1$) are extremal. Are complete $k$-uniform families extremal for
  intermediate $k$? Preliminary data suggests not in general; a clean criterion is
  open.
- **Quantitative excess.** Define $\mathrm{excess}(H) = \min_f \#\mathrm{isolating}
  (H,f) - B(n,d) \ge 0$. Understanding $\mathrm{excess}$ as a hypergraph invariant
  (monotonicity, additivity under disjoint unions) is an appealing direction.

## 8. Conclusion

The region bound $B(n,d) = n\sum_{j=0}^{d-1} j^{\,n-1}$ for isolating weight
assignments of inclusion-free hypergraphs is attained exactly by two symmetric
families — the singletons and their complements — but *not* universally: no choice
of real offsets can make an over-counting hypergraph extremal, as the frozen count
$d^n$ of a single edge demonstrates. Tightness is a special structural property,
and its extremal witnesses appear to be governed by symmetry. Mapping out the full
set of extremal families is the central open problem left in its wake.
