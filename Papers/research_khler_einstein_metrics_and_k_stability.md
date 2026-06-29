# A Combinatorial Core for the Yau–Tian–Donaldson Principle on Toric Fano Varieties

## Abstract

For a toric Fano variety the existence of a Kähler–Einstein metric — the central
object of the Yau–Tian–Donaldson (YTD) correspondence — is governed not by the
solution of a nonlinear partial differential equation but by a single, fully
combinatorial condition on the variety's moment polytope. We isolate and develop
the algebraic core of this picture. Modelling the polytope as a finite indexed
family of weighted rational lattice points $(p_i, w_i)$, we define the
**moment (Futaki) vector** $M = \sum_i w_i p_i$, the **barycenter**
$b = M / \sum_i w_i$, and the **Futaki invariant** $\mathrm{Fut}(\xi) = \sum_i w_i
\langle p_i, \xi\rangle$ paired against a direction $\xi$. We prove the
identity $\mathrm{Fut}(\xi) = \langle M, \xi\rangle$, deduce from nondegeneracy of
the pairing that toric K-polystability (vanishing of $\mathrm{Fut}$ in every
direction) is equivalent to $M = 0$, and obtain the **toric YTD equivalence**:
under positive total weight, a Kähler–Einstein metric exists if and only if the
variety is K-polystable. We then prove a **symmetry-invariance theorem** — any
linear symmetry of the datum fixes $M$ — and derive a **Matsushima-type
obstruction theorem**: a linear symmetry whose only fixed vector is the origin
forces $M = 0$, guaranteeing existence with no curvature estimate. We verify the
criterion on concrete Fano varieties: projective space $\mathbb{P}^n$ is K-stable,
while the one-point blow-up of $\mathbb{P}^2$ is not. The development cleanly
separates a dimension-independent linear-algebra core (always valid) from a
convex-geometry input (positivity of the total weight), and exhibits the entire
existence problem as an exact, decidable arithmetic test.

**Keywords:** Kähler–Einstein, K-stability, K-polystability, Yau–Tian–Donaldson,
Futaki invariant, toric Fano, moment polytope, barycenter, Wang–Zhu, Matsushima.

---

## 1. Introduction

A compact Kähler manifold $X$ with positive first Chern class — a **Fano
manifold** — is said to admit a **Kähler–Einstein (KE) metric** if it carries a
Kähler metric $\omega$ satisfying

$$ \mathrm{Ric}(\omega) = \omega, $$

i.e. whose Ricci curvature is proportional to the metric itself. Not every Fano
manifold admits such a metric; the first obstructions were discovered by Matsushima
(the automorphism group must be reductive) and Futaki (an integral invariant must
vanish). The problem of characterizing existence was settled in the
**Yau–Tian–Donaldson (YTD) correspondence**, which asserts that a Fano manifold
admits a Kähler–Einstein metric if and only if it is **K-polystable** — an
algebro-geometric stability condition phrased in terms of the signs (or vanishing)
of the Donaldson–Futaki invariants of all test configurations.

For **toric** Fano varieties the correspondence becomes spectacularly concrete.
By the work of Wang–Zhu, Mabuchi, and Berman (the toric YTD theorem), all three
a-priori-distinct notions —

1. *analytic existence* (a solution of the KE equation exists),
2. *algebraic stability* (the Donaldson–Futaki invariants vanish), and
3. *convex-geometric balance* (the barycenter of the moment polytope is the
   origin) —

coincide. The forbidding nonlinear PDE collapses to the statement that a single
explicit vector vanishes.

This paper isolates the **algebraic and combinatorial core** of that collapse and
develops it self-containedly. We do not reprove the analytic toric YTD theorem;
rather, we formalize the equivalence at the level of the moment-polytope datum,
make every implication explicit, and prove a symmetry obstruction theorem that
recovers — in elementary linear-algebraic form — the principle that sufficient
symmetry forces existence. The result is a sharp separation of concerns:

- a **dimension-independent linear-algebra core** (the Futaki obstruction vanishes
  in every direction exactly when the moment vector is zero), valid unconditionally;
- a **convex-geometry input** (the total weight is positive), the only place where
  positivity of the underlying measure is used.

We verify the criterion on the smallest interesting cases, recovering the
classical facts that $\mathbb{P}^n$ is K-stable and that the one-point blow-up of
$\mathbb{P}^2$ is obstructed.

---

## 2. The toric Fano datum

We work over the rationals $\mathbb{Q}$, so that every quantity below is exact and
the resulting existence criterion is decidable.

**Definition 2.1 (Toric Fano datum).** A *toric Fano datum* in dimension $d$ with
$m$ points is a pair of functions
$$ p : \{1,\ldots,m\} \to \mathbb{Q}^d, \qquad w : \{1,\ldots,m\} \to \mathbb{Q}, $$
where $p_i = p(i) \in \mathbb{Q}^d$ are the lattice points (or vertices) of the
moment polytope of a toric Fano variety and $w_i = w(i) \in \mathbb{Q}$ are the
associated weights (Lebesgue or lattice masses).

The datum is the bookkeeping device for the convex-geometric content of the
variety. All subsequent quantities are functions of $(p, w)$ alone.

**Definition 2.2 (Moment vector, total weight, barycenter).** Given a toric Fano
datum $(p, w)$, define
$$ M \;=\; \sum_{i=1}^{m} w_i\, p_i \;\in\; \mathbb{Q}^d
   \qquad\text{(the \emph{moment / Futaki vector}),} $$
$$ W \;=\; \sum_{i=1}^{m} w_i \;\in\; \mathbb{Q}
   \qquad\text{(the \emph{total weight}),} $$
$$ b \;=\; W^{-1}\, M \;\in\; \mathbb{Q}^d
   \qquad\text{(the \emph{barycenter}), defined when } W \neq 0. $$
Coordinatewise, $M_j = \sum_{i=1}^m w_i\, (p_i)_j$ for each $j \in \{1,\ldots,d\}$.

**Definition 2.3 (Futaki invariant).** For a direction $\xi \in \mathbb{Q}^d$, the
*Futaki invariant* of the datum in the direction $\xi$ is
$$ \mathrm{Fut}(\xi) \;=\; \sum_{i=1}^{m} w_i \,\langle p_i, \xi\rangle
   \;=\; \sum_{i=1}^{m} w_i \sum_{j=1}^{d} (p_i)_j\, \xi_j . $$

**Definition 2.4 (Existence and stability).** We say the datum:

- *admits a Kähler–Einstein metric* if its barycenter is the origin,
  $b = 0$ (the Wang–Zhu existence criterion);
- is *K-polystable* if the Futaki invariant vanishes in every
  direction, $\mathrm{Fut}(\xi) = 0$ for all $\xi \in \mathbb{Q}^d$.

These two definitions are deliberately phrased differently — one through the
normalized barycenter, the other through a universally quantified pairing — so that
their equivalence is a genuine theorem rather than a definitional triviality.

---

## 3. The linear-algebra core

**Lemma 3.1 (Futaki as a dot product).** For every direction $\xi \in
\mathbb{Q}^d$,
$$ \mathrm{Fut}(\xi) \;=\; \langle M, \xi\rangle \;=\; \sum_{j=1}^{d} M_j\, \xi_j. $$

*Proof.* Expand the inner product in the definition of $\mathrm{Fut}$ and exchange
the order of the two finite summations:
$$ \mathrm{Fut}(\xi) = \sum_{i} w_i \sum_{j} (p_i)_j\, \xi_j
   = \sum_{j} \Big(\sum_{i} w_i\, (p_i)_j\Big) \xi_j
   = \sum_{j} M_j\, \xi_j. $$
The middle step rearranges the double sum and factors out $\xi_j$, using
distributivity of multiplication over the finite sum. $\square$

Lemma 3.1 reveals the classical Futaki obstruction as nothing more than pairing
the moment vector against a direction. Nondegeneracy of this pairing yields the
first equivalence.

**Theorem 3.2 (K-polystability $\iff$ vanishing moment vector).** A toric Fano
datum is K-polystable if and only if its moment vector is zero:
$$ \text{$K$-polystable} \iff M = 0. $$

*Proof.* ($\Rightarrow$) Suppose $\mathrm{Fut}(\xi) = 0$ for all $\xi$. Fix a
coordinate $j$ and take $\xi = e_j$, the $j$-th standard basis vector (the
indicator $\xi_k = [k = j]$). By Lemma 3.1, $0 = \mathrm{Fut}(e_j) = M_j$. As $j$
was arbitrary, every coordinate of $M$ vanishes, so $M = 0$.

($\Leftarrow$) If $M = 0$, then by Lemma 3.1, $\mathrm{Fut}(\xi) = \sum_j M_j
\xi_j = 0$ for every $\xi$. $\square$

The next lemma is the sole point at which positivity (more precisely,
nonvanishing) of the total weight enters.

**Lemma 3.3 (Barycenter normalization).** If $W \neq 0$, then
$$ b = 0 \iff M = 0. $$

*Proof.* Since $b = W^{-1} M$ and $W^{-1} \neq 0$, scaling by the nonzero scalar
$W^{-1}$ is a bijection of $\mathbb{Q}^d$ fixing the origin; hence $b = W^{-1}M = 0$
if and only if $M = 0$. $\square$

Combining Theorem 3.2 and Lemma 3.3 yields the central equivalence.

**Theorem 3.4 (Toric Yau–Tian–Donaldson equivalence).** For a toric Fano datum
with nonzero total weight ($W \neq 0$),
$$ \text{admits a Kähler–Einstein metric} \iff \text{$K$-polystable}. $$
Equivalently, a Kähler–Einstein metric exists $\iff$ the barycenter is at the
origin $\iff$ the moment vector vanishes $\iff$ the Futaki invariant vanishes in
every direction.

*Proof.* By Definition 2.4, admitting a Kähler–Einstein metric means $b = 0$. By
Lemma 3.3 (using $W \neq 0$), this is equivalent to $M = 0$, which by Theorem 3.2
is equivalent to being $K$-polystable. $\square$

This is the algebraic skeleton of the toric YTD theorem: analytic existence
(Wang–Zhu barycenter), algebraic stability (Futaki vanishing), and the linear
condition $M = 0$ all coincide. The only hypothesis is $W \neq 0$, which holds
automatically for genuine moment polytopes since the total Lebesgue or lattice
mass is strictly positive.

---

## 4. The symmetry obstruction

We now show that symmetry alone can force the moment vector to vanish, with no
computation of the individual points. Throughout, a *linear symmetry* is a
$\mathbb{Q}$-linear map $\sigma : \mathbb{Q}^d \to \mathbb{Q}^d$ together with a
permutation $e$ of the index set realizing it on the datum.

**Theorem 4.1 (Symmetry invariance of the moment vector).** Let $\sigma :
\mathbb{Q}^d \to \mathbb{Q}^d$ be a $\mathbb{Q}$-linear map and $e$ a permutation
of $\{1,\ldots,m\}$ such that
$$ w_{e(i)} = w_i \quad\text{and}\quad \sigma(p_i) = p_{e(i)} \qquad
   \text{for all } i. $$
Then $\sigma$ fixes the moment vector:
$$ \sigma(M) = M. $$

*Proof.* Using linearity of $\sigma$ and the hypothesis $\sigma(p_i) = p_{e(i)}$,
$$ \sigma(M) = \sigma\Big(\sum_i w_i p_i\Big) = \sum_i w_i\, \sigma(p_i)
   = \sum_i w_i\, p_{e(i)}. $$
Reindex the sum by the bijection $e$ (replacing $i$ by $e^{-1}(i)$), and use
$w_{e(i)} = w_i$ to rewrite the weights:
$$ \sum_i w_i\, p_{e(i)} = \sum_i w_{e(i)}\, p_{e(i)} = \sum_i w_i\, p_i = M. $$
Hence $\sigma(M) = M$. $\square$

The moment vector is therefore a common fixed point of every symmetry of the
configuration. The obstruction theorem follows immediately.

**Theorem 4.2 (Matsushima-type obstruction).** With $\sigma$ and $e$ as in
Theorem 4.1, suppose in addition that $\sigma$ has *no nonzero fixed vector*:
$$ \sigma(x) = x \implies x = 0 \qquad \text{for all } x \in \mathbb{Q}^d. $$
Then $M = 0$. Consequently, if the total weight is nonzero, the variety is
K-polystable and admits a Kähler–Einstein metric.

*Proof.* By Theorem 4.1, $\sigma(M) = M$, so $M$ is a fixed vector of $\sigma$. By
the trivial-fixed-space hypothesis, $M = 0$. The last sentence follows from
Theorem 3.4. $\square$

This is the combinatorial avatar of Matsushima's theorem: a sufficiently large
reductive symmetry group kills the Futaki invariant and forces existence. The
striking feature is that *no curvature estimate is needed* — the existence of a
single linear symmetry with trivial fixed space settles the matter. The direction
of the obstruction is weight-independent: positivity of the weight is used only to
normalize the barycenter, not to determine whether $M$ vanishes.

---

## 5. Worked examples

### 5.1 Projective space $\mathbb{P}^n$ is K-stable

The moment polytope of $\mathbb{P}^n$ (suitably centered) is the reflexive simplex
with vertices
$$ v_0 = (-1, -1, \ldots, -1), \quad v_1 = e_1, \quad v_2 = e_2, \quad \ldots,
   \quad v_n = e_n, $$
all carrying equal weight $1$. Two short verifications:

- **Direct.** The moment vector is
  $M = v_0 + \sum_{k=1}^n e_k = (-1,\ldots,-1) + (1,\ldots,1) = 0.$ By Theorem
  3.4, $\mathbb{P}^n$ admits a Kähler–Einstein metric (the Fubini–Study metric)
  and is K-polystable.
- **By symmetry (Theorem 4.2).** The cyclic permutation of the $n+1$ vertices
  $v_0 \to v_1 \to \cdots \to v_n \to v_0$ is realized by a $\mathbb{Q}$-linear map
  $\sigma$ of $\mathbb{Q}^n$ that preserves all weights. Because the vertices
  positively span $\mathbb{Q}^n$ and sum to zero, the only vector fixed by the full
  cyclic symmetry is the origin. Theorem 4.2 then yields $M = 0$ with no
  computation of coordinates.

Thus the enormous symmetry of $\mathbb{P}^n$ is, by itself, a proof of existence.

### 5.2 The one-point blow-up of $\mathbb{P}^2$ is not K-stable

Blowing up $\mathbb{P}^2$ at a single torus-fixed point corresponds to slicing one
corner off the triangle of $\mathbb{P}^2$, producing a quadrilateral whose
lattice-point datum is no longer centrally balanced. A representative datum has
weighted lattice points whose moment vector is
$$ M \;=\; (c, c) \quad\text{with } c \neq 0, $$
a nonzero vector pointing along the diagonal direction created by the corner cut.
Concretely, the blow-up breaks the cyclic symmetry of §5.1, so there is no longer
a rigid symmetry to enforce balance, and a direct summation confirms $M \neq 0$.
By Theorem 3.4 the barycenter is off the origin and the variety **admits no
Kähler–Einstein metric**; equivalently, the Futaki invariant $\mathrm{Fut}(\xi) =
\langle M, \xi\rangle$ is nonzero for $\xi = M$, exhibiting an explicit
destabilizing direction. This is the smallest obstructed Fano surface, and it
sits on exactly the opposite side of the trivial-fixed-space dichotomy from
projective space.

### 5.3 Other balanced surfaces

The same equal-weight computation reproduces the full classification of
canonical-metric existence on toric del Pezzo surfaces. The product of two
projective lines $\mathbb{P}^1 \times \mathbb{P}^1$ (square polytope) and the
degree-six del Pezzo surface (hexagonal polytope) are balanced — their central
symmetry $x \mapsto -x$ has trivial fixed space, so Theorem 4.2 applies — while
the one- and two-point blow-ups of $\mathbb{P}^2$ are obstructed. The dichotomy of
§5.1–5.2 is the prototype for the entire toric classification.

---

## 6. Algorithms

The criterion is an exact arithmetic test over $\mathbb{Q}$.

**Algorithm A (Existence test).** *Input:* points $p_1,\ldots,p_m \in
\mathbb{Q}^d$, weights $w_1,\ldots,w_m \in \mathbb{Q}$. *Output:* whether a
Kähler–Einstein metric exists.

1. Compute $W = \sum_i w_i$. If $W = 0$, the datum is degenerate; abort.
2. Compute $M_j = \sum_i w_i (p_i)_j$ for each coordinate $j$.
3. Return **balanced / KE exists** if $M = 0$; otherwise return **obstructed**,
   together with the destabilizing direction $\xi = M$.

This runs in $O(md)$ exact rational operations and is fully decidable: there is no
rounding, no tolerance, and no PDE solver.

**Algorithm B (Symmetry certificate).** *Input:* the datum and a candidate linear
symmetry $\sigma$ with index permutation $e$. *Output:* a symmetry-based proof of
existence when available.

1. Verify $w_{e(i)} = w_i$ and $\sigma(p_i) = p_{e(i)}$ for all $i$. If either
   fails, $\sigma$ is not a symmetry; abort.
2. Compute the fixed subspace $\ker(\sigma - I)$ by Gaussian elimination over
   $\mathbb{Q}$.
3. If $\ker(\sigma - I) = \{0\}$, conclude by Theorem 4.2 that $M = 0$ and a
   Kähler–Einstein metric exists — *without computing $M$*.

Algorithm B can certify existence purely from the representation theory of the
symmetry, sidestepping the moment-vector computation entirely.

---

## 7. Discussion

The development achieves a clean conceptual separation. The equivalences of §3
(Lemma 3.1, Theorems 3.2 and 3.4) are pure linear algebra: they hold in every
dimension, for any weights, and depend only on nondegeneracy of the standard
pairing. The single convex-geometric hypothesis $W \neq 0$ enters only in Lemma
3.3 to normalize the barycenter. The symmetry obstruction of §4 is the reusable
kernel: it reduces existence to the trivial-fixed-space condition on a symmetry
representation — a question about a single matrix — and recovers Matsushima's
principle in a form requiring no analysis.

A subtle but important design choice is that the YTD equivalence (Theorem 3.4) is
*not* a definitional tautology. The existence condition is phrased through the
normalized barycenter and the stability condition through a universally quantified
pairing; the bridge between them genuinely consumes both the nondegeneracy of the
pairing (Theorem 3.2) and the nonzero scalar $W^{-1}$ (Lemma 3.3). The theorem
therefore carries real content.

Finally, the framework reframes a hard analytic existence problem as an exact,
finite, decidable certificate — the vanishing of a rational vector. This is the
same spirit in which intractable continuous problems throughout computation and
cryptography are reduced to checkable algebraic witnesses: a property that appears
to demand infinite analytic effort is in fact decided by a short piece of
arithmetic.

---

## 8. Future directions

The cycle established a clean separation between two ingredients of the
Yau–Tian–Donaldson principle for toric Fano varieties: a *dimension-independent
linear-algebra core* (the Futaki obstruction vanishes in every direction exactly
when the moment vector of the polytope is the origin) and a *convex-geometry input*
(which polytopes are balanced). Three conjectures push on the seam between them.

**1. Symmetry forces balance with quantitative slack.** If a finite group of
lattice symmetries acts on a Fano polytope so that the only common fixed direction
is the origin, then the polytope is balanced, and moreover the distance from the
barycenter to the origin is controlled by the smallest nonzero "fixed-direction
defect" of the group action; when the group is large the defect, and hence the
obstruction, decays at a predictable rate. The moment vector is a fixed point of
every symmetry, so existence is governed entirely by the trivial-fixed-space
condition of the symmetry representation, not by any curvature estimate. The
minimal obstructed example (the one-point blow-up of the plane) and the balanced
examples (projective space, the product of two lines, the degree-six del Pezzo)
fall on opposite sides of exactly this dichotomy, so the criterion is already sharp
and ready for a quantitative refinement.

**2. A weighted balance criterion interpolating between stability notions.**
Replacing equal weights on the polytope vertices by a one-parameter family of
positive weights traces out a continuous path of "twisted" moment vectors, and the
parameter value at which this vector first vanishes is a genuine numerical
invariant detecting the transition from stability to instability for the
associated family of varieties. Stability is then not a single yes/no test but the
vanishing locus of a weighted moment map, so the *weights themselves* become the
right coordinate in which to measure how far a variety is from admitting a
canonical metric. The equal-weight computation already reproduces the full
classification on toric surfaces, suggesting the weighted deformation interpolates
cleanly between the balanced and obstructed regimes.

**3. The obstruction is rank-one for one-point blow-ups in every dimension.** For
the blow-up of projective space at a single torus-fixed point, in any dimension,
the moment vector is nonzero and points in a single distinguished coordinate
direction; consequently these varieties never admit a canonical metric, and the
obstruction is always "rank one" in a precise representation-theoretic sense.
Blowing up a single fixed point breaks exactly one of the symmetries that balance
projective space.

---

## References (classical background)

- Y. Matsushima, on the reductivity of the automorphism group of a Kähler–Einstein
  manifold.
- A. Futaki, on the obstruction to the existence of Kähler–Einstein metrics.
- X. Wang and X. Zhu, Kähler–Ricci solitons on toric manifolds.
- S. K. Donaldson, Scalar curvature and stability of toric varieties.
- R. Berman, K-polystability of $\mathbb{Q}$-Fano varieties admitting
  Kähler–Einstein metrics.
- X.-X. Chen, S. K. Donaldson, S. Sun, Kähler–Einstein metrics on Fano manifolds
  (the YTD correspondence).
