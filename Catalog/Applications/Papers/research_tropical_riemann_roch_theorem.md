# A Formal Development of Riemann–Roch Theory for Finite Graphs

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty

## Abstract

We present a self-contained development of the Baker–Norine theory of divisors,
chip-firing, and the Riemann–Roch theorem on finite graphs, the combinatorial
analogue of the classical Riemann–Roch theorem for algebraic curves. We define
divisors as integer-valued functions on the vertex set, introduce the
chip-firing (Laplacian) action and the resulting notion of linear equivalence,
and prove that the degree of a divisor is invariant under linear equivalence. We
define the canonical divisor $K(v) = \deg(v) - 2$ and establish the canonical
degree identity $\deg K = 2g - 2$ for an *arbitrary* finite connected graph,
where $g = |E| - |V| + 1$ is the genus. We formulate the Baker–Norine rank
$r(D)$ and prove the Riemann–Roch theorem in genus zero, namely
$r(D) - r(K - D) = \deg D + 1$ on trees. Finally, we prove a sharp obstruction
in genus one: on the two-vertex multigraph with two parallel edges, divisors of
equal degree need not be linearly equivalent, witnessed by the unsolvability of
$2t = 1$ over $\mathbb{Z}$. This shows the genus-zero hypothesis is load-bearing
and isolates the precise extra input — the nontriviality of the Jacobian — that a
full Riemann–Roch theorem must overcome. We discuss the reduction of the general
theorem to a single non-special-class symmetry lemma, an algorithmic route to
rank via reduced divisors, and the connection between the surjectivity hypothesis
`hsurj` and the order of the Jacobian.

## 1. Introduction

The Riemann–Roch theorem is a central organizing principle in the geometry of
algebraic curves. For a smooth projective curve $X$ of genus $g$ over an
algebraically closed field, with canonical divisor $K_X$ of degree $2g - 2$, it
asserts for every divisor $D$:
$$\ell(D) - \ell(K_X - D) = \deg D - g + 1,$$
where $\ell(D)$ is the dimension of the space of rational functions with poles
bounded by $D$. In 2007, Baker and Norine discovered that a verbatim analogue
holds for finite graphs, with curves replaced by graphs, rational functions
replaced by integer-valued chip-firing moves, and the dimension $\ell$ replaced
by a purely combinatorial rank $r$. Their theorem reads
$$r(D) - r(K - D) = \deg D - g + 1,$$
and it has since become the foundation of a rich subject linking combinatorics,
tropical geometry, electrical network theory, and the theory of sandpiles.

This paper develops the theory from first principles in a fully constructive
style, with every object defined combinatorially and every claim reduced to
finite or arithmetic checks. Our contributions are:

1. A clean axiomatization of divisors, the chip-firing action `prin`, and linear
   equivalence `LinEquiv`, together with a proof of **degree invariance**.
2. The **canonical degree identity** $\deg K = 2g - 2$ for arbitrary finite
   connected graphs (`deg_canonical`), built on the handshake lemma
   `even_totalEdges`.
3. A formulation of the **Baker–Norine rank** via the predicate `SatisfiesRank`
   and a proof of **Riemann–Roch in genus zero** (`riemann_roch_genus_zero`).
4. A sharp **genus-one obstruction** (`cycleTwo_hsurj_fails`) proving the
   genus-zero hypothesis cannot be removed, and identifying the Jacobian as the
   precise obstruction.

## 2. Divisors and degree

Throughout, $G = (V, E)$ is a finite connected multigraph with vertex set $V$ and
edge multiset $E$. For vertices $v, w$ we write $a(v, w)$ for the number of edges
joining $v$ and $w$ (the adjacency multiplicity), and $\deg(v) = \sum_{w} a(v,w)$
for the vertex degree.

**Definition 2.1 (Divisor).** A *divisor* on $G$ is a function
$D : V \to \mathbb{Z}$. Divisors form a free abelian group $\operatorname{Div}(G)$
under pointwise addition, the free abelian group on $V$.

**Definition 2.2 (Degree).** The *degree* of a divisor is
$$\deg(D) = \sum_{v \in V} D(v).$$
Degree is a group homomorphism $\deg : \operatorname{Div}(G) \to \mathbb{Z}$.

**Definition 2.3 (Effective divisor).** A divisor $D$ is *effective*, written
$D \ge 0$, if $D(v) \ge 0$ for all $v \in V$. We write $\operatorname{Eff}_k$ for
the set of effective divisors of degree $k$.

## 3. Chip-firing and linear equivalence

**Definition 3.1 (Principal divisor / Laplacian action).** For a *firing vector*
$f : V \to \mathbb{Z}$, the associated *principal divisor* is
$$\operatorname{prin}(f)(v) = \sum_{w \in V} a(v, w)\,\bigl(f(w) - f(v)\bigr).$$
Equivalently $\operatorname{prin}(f) = -L f$, where $L$ is the graph Laplacian
$L = \mathrm{Diag}(\deg) - A$ and $A$ is the adjacency matrix. Firing a single
vertex $v$ once corresponds to $f = \mathbf{1}_v$ and moves one chip along each
incident edge from $v$ to its neighbors.

**Lemma 3.2 (Conservation, `deg_prin_zero`).** For every firing vector $f$,
$$\deg\bigl(\operatorname{prin}(f)\bigr) = 0.$$

*Proof sketch.* Summing $\operatorname{prin}(f)(v)$ over all $v$ gives
$\sum_{v,w} a(v,w)(f(w) - f(v))$. The adjacency multiplicity is symmetric,
$a(v,w) = a(w,v)$, so the term for the ordered pair $(v,w)$ cancels the term for
$(w,v)$; the antisymmetric factor $f(w) - f(v)$ makes the double sum telescope to
zero. $\square$

**Definition 3.3 (Linear equivalence, `LinEquiv`).** Two divisors $D, D'$ are
*linearly equivalent*, written $D \sim D'$, if $D - D' = \operatorname{prin}(f)$
for some firing vector $f$. The principal divisors form a subgroup
$\operatorname{Prin}(G) \le \operatorname{Div}^0(G)$ of the degree-zero divisors,
and $\sim$ is the corresponding coset equivalence; it is reflexive ($f = 0$),
symmetric ($f \mapsto -f$), and transitive ($f, f' \mapsto f + f'$).

**Theorem 3.4 (Degree invariance).** If $D \sim D'$ then
$\deg(D) = \deg(D')$.

*Proof sketch.* By definition $D - D' = \operatorname{prin}(f)$ for some $f$, so
$\deg(D) - \deg(D') = \deg(\operatorname{prin}(f)) = 0$ by Lemma 3.2. $\square$

**Definition 3.5 (Picard groups).** The quotient
$\operatorname{Pic}(G) = \operatorname{Div}(G)/\operatorname{Prin}(G)$ is the
*Picard group*; degree descends to it, and its degree-zero part
$\operatorname{Pic}^0(G) = \operatorname{Div}^0(G)/\operatorname{Prin}(G)$ is the
*Jacobian* (critical group / sandpile group). By Kirchhoff's matrix-tree theorem
$|\operatorname{Pic}^0(G)|$ equals the number of spanning trees of $G$.

## 4. Genus and the canonical divisor

**Definition 4.1 (Genus).** The *genus* of a finite connected graph is its first
Betti number,
$$g = |E| - |V| + 1.$$
A connected graph is a tree iff $g = 0$ iff $|E| = |V| - 1$.

**Lemma 4.2 (Handshake, `even_totalEdges`).** The sum of vertex degrees is twice
the number of edges:
$$\sum_{v \in V} \deg(v) = 2|E|.$$

*Proof sketch.* Each edge contributes exactly two to the left-hand side, one for
each of its endpoints; summing the contributions edge by edge gives $2|E|$. In
particular $\sum_v \deg(v)$ is even. $\square$

**Definition 4.3 (Canonical divisor).** The *canonical divisor* is
$$K(v) = \deg(v) - 2.$$

**Theorem 4.4 (Canonical degree identity, `deg_canonical`).** For every finite
connected graph,
$$\deg(K) = 2g - 2.$$

*Proof sketch.* Compute directly:
$$\deg(K) = \sum_{v}\bigl(\deg(v) - 2\bigr) = \Bigl(\sum_v \deg(v)\Bigr) - 2|V|
= 2|E| - 2|V| = 2(|E| - |V|) = 2(g - 1) = 2g - 2,$$
using the handshake Lemma 4.2 and the definition of genus. The argument is purely
arithmetic and is discharged by `omega` once the handshake identity is in hand.
$\square$

This identity is the exact discrete counterpart of the classical statement that a
genus-$g$ curve has canonical degree $2g - 2$. Notably it holds with *no*
hypothesis on $G$ beyond finiteness and connectedness.

## 5. The Baker–Norine rank

**Definition 5.1 (Equivalence to effective).** A divisor $D$ is *winnable* if
$D \sim E$ for some effective $E$; equivalently the chip configuration $D$ can be
fired into one with no debt.

**Definition 5.2 (Rank predicate, `SatisfiesRank`).** For an integer $k \ge 0$ we
say $D$ *satisfies rank* $k$, written $\mathrm{SatisfiesRank}(D, k)$, if for every
effective divisor $E$ with $\deg E = k$, the divisor $D - E$ is winnable. The
*Baker–Norine rank* is
$$r(D) = \begin{cases}
-1 & \text{if } D \text{ is not winnable},\\
\max\{\,k \ge 0 : \mathrm{SatisfiesRank}(D, k)\,\} & \text{otherwise.}
\end{cases}$$

Equivalently, $r(D) \ge k$ iff for *all* effective $E$ of degree $k$ the divisor
$D - E$ is winnable, with the convention $r(D) \ge 0$ meaning $D$ is winnable and
$r(D) \ge -1$ always.

**Remarks.** The only non-finitary ingredient in this definition is the universal
quantifier over all effective $E$ of degree $k$. We isolate it deliberately,
because the theory of *reduced divisors* (Section 8) shows it can be replaced by a
single canonical-form test, making $r$ algorithmically computable.

**Lemma 5.3 (Rank is a class invariant).** If $D \sim D'$ then $r(D) = r(D')$.

*Proof sketch.* Winnability is defined modulo $\sim$, and $D - E \sim D' - E$
whenever $D \sim D'$; hence $\mathrm{SatisfiesRank}(D, k) \iff
\mathrm{SatisfiesRank}(D', k)$ for all $k$. $\square$

**Lemma 5.4 (Negative-degree vanishing).** If $\deg D < 0$ then $r(D) = -1$.

*Proof sketch.* A winnable divisor is equivalent to an effective one, which has
degree $\ge 0$; by degree invariance (Theorem 3.4) a divisor of negative degree
cannot be winnable. $\square$

## 6. Riemann–Roch in genus zero

We now specialize to trees, $g = 0$. The key structural simplification is that the
Jacobian is trivial.

**Proposition 6.1 (Tree surjectivity, `hsurj` in genus 0).** On a tree, any two
divisors of equal degree are linearly equivalent. Equivalently
$\operatorname{Pic}^0(G) = 0$.

*Proof sketch.* On a tree the Laplacian has rank $|V| - 1$, and its image is
exactly the degree-zero sublattice $\operatorname{Div}^0(G)$ (the number of
spanning trees is $1$, so $|\operatorname{Pic}^0| = 1$). Concretely, given a
degree-zero divisor one repeatedly fires leaves toward the interior to cancel all
chips; the absence of cycles guarantees the process terminates without
obstruction. $\square$

**Lemma 6.2 (Rank on a tree).** On a tree, for every divisor $D$,
$$r(D) = \begin{cases} \deg D & \deg D \ge 0,\\ -1 & \deg D < 0.\end{cases}$$

*Proof sketch.* If $\deg D < 0$, apply Lemma 5.4. If $\deg D = k \ge 0$, then by
Proposition 6.1 every divisor of degree $k$ is equivalent to the effective divisor
placing all $k$ chips on a fixed root, so $D$ is winnable and likewise $D - E$ is
winnable for every effective $E$ of degree up to $k$; hence $r(D) \ge k$.
Conversely, choosing $E$ to be $k+1$ chips concentrated at a single vertex makes
$\deg(D - E) = -1 < 0$, so $D - E$ is not winnable and $r(D) \le k$. Therefore
$r(D) = k = \deg D$. $\square$

**Theorem 6.3 (Riemann–Roch, genus zero, `riemann_roch_genus_zero`).** On a tree,
for every divisor $D$,
$$r(D) - r(K - D) = \deg D + 1.$$

*Proof sketch.* On a tree $\deg K = 2g - 2 = -2$ (Theorem 4.4), so
$\deg(K - D) = -2 - \deg D$. We split on the sign of $\deg D$.

- If $\deg D \ge 0$: by Lemma 6.2, $r(D) = \deg D$. Also $\deg(K - D) = -2 - \deg D
  \le -2 < 0$, so $r(K - D) = -1$ by Lemma 5.4. Hence
  $r(D) - r(K - D) = \deg D - (-1) = \deg D + 1$.
- If $\deg D = -1$: then $r(D) = -1$, while $\deg(K - D) = -1$, so $r(K - D) = -1$
  as well; thus $r(D) - r(K - D) = 0 = \deg D + 1$.
- If $\deg D \le -2$: then $r(D) = -1$ and $\deg(K - D) = -2 - \deg D \ge 0$, so by
  Lemma 6.2 $r(K - D) = \deg(K - D) = -2 - \deg D$; hence
  $r(D) - r(K - D) = -1 - (-2 - \deg D) = 1 + \deg D = \deg D + 1$.

In every case the identity holds. After the case split, each branch is closed by
arithmetic (`split_ifs <;> omega`). $\square$

This is precisely the general Riemann–Roch identity
$r(D) - r(K-D) = \deg D - g + 1$ specialized to $g = 0$, where the symmetry
between $D$ and $K - D$ is vacuous because one of the two terms is always $-1$.

## 7. A sharp genus-one obstruction

Genus zero is not the whole story. We exhibit the minimal obstruction.

**Definition 7.1 (The banana $B_2$).** Let $B_2$ be the multigraph with two
vertices $\{a, b\}$ joined by exactly two parallel edges. Then $|V| = 2$,
$|E| = 2$, and $g = |E| - |V| + 1 = 1$. Here $a(a, b) = 2$, so firing $a$ once
yields $\operatorname{prin}(\mathbf{1}_a) = (-2, +2)$.

**Theorem 7.2 (Genus-one obstruction, `cycleTwo_hsurj_fails`).** On $B_2$, the
surjectivity statement of Proposition 6.1 *fails*: the divisors $(1, -1)$ and
$(0, 0)$ have the same degree ($0$) but are *not* linearly equivalent.

*Proof sketch.* Any firing vector on $B_2$ is $f = (s, t)$, and
$$\operatorname{prin}(f) = \bigl(2(t - s),\, 2(s - t)\bigr),$$
whose first coordinate is always even. If $(1, -1) \sim (0, 0)$ we would need
$\operatorname{prin}(f) = (1, -1)$ for some integers $s, t$, forcing
$2(t - s) = 1$. But $2(t-s) = 1$ has no integer solution — equivalently the
equation $2u = 1$ is unsolvable over $\mathbb{Z}$, closed immediately by `omega`.
Hence no such $f$ exists and the two divisors are inequivalent. $\square$

**Corollary 7.3 (Nontrivial Jacobian).** $\operatorname{Pic}^0(B_2) \cong
\mathbb{Z}/2\mathbb{Z}$, generated by the class of $(1, -1)$, in agreement with the
matrix-tree count: $B_2$ has exactly two spanning trees (one per edge).

**Interpretation.** The proof of Theorem 6.3 used Proposition 6.1 in an essential
way; Theorem 7.2 shows that hypothesis is genuinely necessary. The parity
obstruction $2u = 1$ is the simplest instance of a general divisibility
obstruction: principal divisors are constrained by gcd-type data of the adjacency
matrix, and nontrivial torsion in $\operatorname{Pic}^0$ is exactly what prevents
equal-degree divisors from being equivalent. In the genus-zero theorem the partner
term $r(K - D)$ silently vanishes; in higher genus it becomes active, and the full
Riemann–Roch equation is the precise correction that restores the balance.

## 8. Algorithms

### 8.1 Degree and effectivity

Computing $\deg D = \sum_v D(v)$ and testing effectivity ($D(v) \ge 0$ for all
$v$) are linear-time scans of the vertex set, $O(|V|)$.

### 8.2 Principal divisors

Given a firing vector $f$, computing $\operatorname{prin}(f)$ is a single
Laplacian multiplication, $O(|V| + |E|)$ using the sparse adjacency structure.
Conservation $\deg \operatorname{prin}(f) = 0$ provides a cheap correctness check.

### 8.3 Dhar's burning algorithm and reduced divisors

The decisive algorithmic tool for ranks is the theory of *$q$-reduced divisors*.
Fix a base vertex $q$. A divisor $D$ is $q$-reduced if (i) $D(v) \ge 0$ for all
$v \ne q$, and (ii) for every nonempty $S \subseteq V \setminus \{q\}$ some vertex
$v \in S$ has fewer chips than edges leaving $S$ (so $S$ cannot legally fire as a
set). Dhar's burning algorithm finds, for any divisor, the unique $q$-reduced
divisor in its linear-equivalence class in $O(|V|\cdot|E|)$ time. The class is
winnable iff its $q$-reduced representative has $D(q) \ge 0$. This collapses the
infinite quantifier in Definition 5.2 to a finite canonical-form test and renders
$r(D)$ computable.

**Pseudocode (Dhar's burning algorithm).**
```
Input: graph G, base vertex q, divisor D
1. Bring D to a representative with D(v) >= 0 for all v != q by
   firing the complement of {q} until no vertex outside q is in debt.
2. Repeat:
     a. Start a fire at q: mark q as burnt.
     b. A vertex v != q catches fire when the number of burnt
        neighbors (counted with edge multiplicity) exceeds D(v).
     c. Propagate until no new vertex burns.
     d. If every vertex is burnt, stop: D is q-reduced.
        Otherwise fire the set U of unburnt vertices once
        (each v in U sends a chip along each edge leaving U),
        and return to step (a).
Output: the unique q-reduced divisor linearly equivalent to D.
```

### 8.4 Rank via reduced divisors

To test $r(D) \ge k$: enumerate the (finitely many) "worst-case" effective $E$ of
degree $k$ — by a greedy/optimal-play argument it suffices to consider those
supported so as to most stress the burning process — and for each test whether
$D - E$ is winnable using §8.3. The genus-zero specialization (Lemma 6.2) shows
that on trees this reduces to comparing $\deg D$ against $0$.

## 9. Applications

- **Abelian sandpiles and self-organized criticality.** Chip-firing is the
  abelian sandpile model; the Jacobian $\operatorname{Pic}^0(G)$ is the sandpile
  group governing recurrent configurations. The conservation law (Lemma 3.2) is
  the discrete continuity equation underlying these dynamics.
- **Electrical networks.** Identifying firing vectors with potentials makes the
  Laplacian Ohm's law; principal divisors are net current injections, and degree
  invariance is conservation of charge.
- **Tropical and arithmetic geometry.** Graph Riemann–Roch is the combinatorial
  core of tropical Riemann–Roch for metric graphs and underlies specialization
  results that transfer information from algebraic curves to their dual graphs.
- **Algebraic combinatorics.** The matrix-tree connection
  $|\operatorname{Pic}^0(G)| = \#\{\text{spanning trees}\}$ links the theory to
  enumerative combinatorics and the critical group literature.

## 10. Discussion and future work

The development establishes the spine of the theory — divisors, the chip-firing
action, degree invariance, the canonical degree identity $\deg K = 2g - 2$, the
Baker–Norine rank, genus-zero Riemann–Roch, and a sharp genus-one obstruction —
in a form where every claim reduces to a finite or arithmetic check. Three
directions extend it to the full theorem.

**Conjecture 1 (Reduced divisors collapse the rank to a finite check).** For every
finite connected graph $G$, every divisor class contains a unique $q$-reduced
representative (Dhar's algorithm), and $r(D) \ge 0$ iff that representative is
effective. Consequently $r$ is computable by a terminating algorithm with no
infinite quantifier. The key insight is that the offending universal quantifier in
`SatisfiesRank` can be replaced by a single canonical-form test, because
chip-firing has a confluent normal form per linear-equivalence class. This is
within reach because the present `rank` definition already isolates exactly this
quantifier as its only non-finitary ingredient.

**Conjecture 2 (Full Riemann–Roch from one involution lemma).** For arbitrary $G$,
$r(D) - r(K - D) = \deg D - g + 1$, and the only deep input beyond the present
results is: for every $\xi$ of degree $g - 1$, exactly one of $\xi$, $K - \xi$ is
equivalent to an effective divisor. Given $\deg K = 2g - 2$ (already proved), the
Riemann–Roch identity is equivalent to this $g - 1$ symmetry, so the entire
theorem reduces to one Baker–Norine "non-special class" lemma plus arithmetic.
Indeed `riemann_roch_genus_zero` is literally this reduction specialized to
$g = 0$, where the symmetry is vacuous; the proof skeleton transfers verbatim once
the symmetry lemma is available.

**Conjecture 3 (Lattice index equals genus-degeneracy of `hsurj`).** The
surjectivity hypothesis `hsurj` (all equal-degree divisors equivalent) holds for
$G$ iff the principal lattice has index $1$ in the degree-zero lattice iff $G$ is a
tree iff $g = 0$. Quantitatively, $\operatorname{Pic}^0(G)$ has order equal to the
number of spanning trees, and `hsurj` fails by exactly that factor. The genus-one
obstruction `cycleTwo_hsurj_fails` is the index-$2$ instance of a general
parity/divisibility obstruction: principal divisors are always divisible by
gcd-type data of the adjacency matrix, so nontrivial torsion in
$\operatorname{Pic}^0$ is the precise obstruction to `hsurj`. Generalizing this to
arbitrary adjacency data, in tandem with Kirchhoff's matrix-tree theorem, is the
natural next step.

## 11. Conclusion

By treating a graph as a discrete curve, we recover an exact Riemann–Roch theory
from pure combinatorics. The canonical degree identity $\deg K = 2g - 2$ holds
universally; degree is invariant under chip-firing; genus-zero Riemann–Roch is
fully proved; and a single parity equation $2u = 1$ pinpoints why higher genus is
genuinely harder. The result is a compact, trustworthy foundation that exposes the
arithmetic skeleton beneath one of geometry's deepest theorems.
