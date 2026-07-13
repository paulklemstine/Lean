# A Cross-Domain Bridge for the √2 Threshold: Vietoris–Rips Complexes, Extremal Graph Theory, and Information Theory

## Abstract

The Vietoris–Rips complex is the central combinatorial object of topological
data analysis, but its size can grow as $2^n$ in the number $n$ of data points,
making faithful representation and approximation a fundamental computational
concern. We give a self-contained account of why, below the multiplicative
threshold $c = \sqrt{2}$, this exponential blow-up is unavoidable, and we do so
by aligning three classically distinct viewpoints on a single extremal object:
the equidistant configuration realized by the $n$ standard basis vectors of
Euclidean space, whose pairwise distances all equal $\sqrt{2}$. First, we
establish the *clique dictionary*: the Vietoris–Rips complex at scale $r$ equals
the clique complex of the proximity graph at scale $r$. Second, we invoke the
*extremal bound* of graph theory: a graph on $n$ vertices has at most $2^n$
cliques, with equality exactly for the complete graph. Third, we translate the
resulting count into an *information-theoretic floor*: a family of $M$ objects
requires $\lceil \log_2 M\rceil$ addressing bits, so a level of $2^n$ simplices
requires $n$ bits. Combining these, every multiplicative $c$-approximation of the
equidistant Vietoris–Rips filtration has a level containing at least $2^n$
simplices, hence requiring at least $n$ bits of storage. The sharp exponent is
$\gamma(c) = \tfrac12 - \log_2 c$, which is strictly positive on the entire
regime $1 \le c < \sqrt{2}$ and vanishes exactly at $c = \sqrt{2}$. The result
packages a geometric, a combinatorial, and an information-theoretic extremum into
one coincidence.

## 1. Introduction

Topological data analysis (TDA) extracts qualitative, multi-scale shape
information — connected components, loops, higher voids — from finite metric data.
Its principal construction is the *Vietoris–Rips filtration*, a nested family of
simplicial complexes indexed by a scale parameter. Because the Vietoris–Rips
complex of $n$ points can contain up to $2^n$ simplices, a large body of work
seeks smaller structures — sparsified, approximate, or otherwise compressed —
that preserve the persistent homology up to a controlled multiplicative
distortion $c \ge 1$ of the scale.

A natural and sharp question is: *how small can such a $c$-approximation be, in
the worst case?* We present a clean, fully explicit lower bound. On the
equidistant configuration (all pairwise distances equal), no $c$-approximation
with $1 \le c < \sqrt{2}$ can avoid a level of $2^n$ simplices, and hence a
description-length cost of $n$ bits. The number $\sqrt{2}$ is not incidental: it
is the exact pairwise distance of the $n$ standard basis vectors, the canonical
Euclidean realization of an equidistant point set.

Our contribution is not merely the bound but the *bridge*: the argument threads
through three subjects, each contributing one link, and the equidistant
configuration is exactly the object at which all three attain their extremes
simultaneously.

- **Metric geometry / TDA** supplies the Vietoris–Rips complex and the
  equidistant configuration.
- **Extremal graph theory** supplies the clique-count ceiling $2^n$ and its
  unique maximizer, the complete graph.
- **Information theory** supplies the description-length reading: a level of
  $2^n$ simplices carries $n$ bits.

## 2. Definitions

Throughout, $n \in \mathbb{N}$ and the point set is identified with
$\{0,1,\dots,n-1\}$. A *dissimilarity* is a function $D : \{0,\dots,n-1\}^2 \to
\mathbb{R}$; we do not assume $D$ is a metric, only using symmetry and the
diagonal condition where needed.

**Definition 2.1 (Vietoris–Rips simplex and complex).**
A subset $S$ of the point set is a *Vietoris–Rips simplex at scale $r$* if every
pair of its vertices is within $r$:
$$\forall\, i, j \in S,\quad D(i,j) \le r.$$
The *Vietoris–Rips complex* $\mathrm{VR}(D, r)$ is the family of all such
simplices:
$$\mathrm{VR}(D,r) = \{\, S \subseteq \{0,\dots,n-1\} : \forall i,j \in S,\ D(i,j) \le r \,\}.$$

**Definition 2.2 (Equidistant dissimilarity).**
For $d \in \mathbb{R}$, the *equidistant dissimilarity* $\mathrm{eq}_d$ sets
$\mathrm{eq}_d(i,i) = 0$ and $\mathrm{eq}_d(i,j) = d$ for $i \ne j$. For $d =
\sqrt{2}$ this is realized isometrically by the $n$ standard basis vectors
$e_0,\dots,e_{n-1}$ in $\mathbb{R}^n$, since $\lVert e_i - e_j\rVert = \sqrt{2}$
for $i \ne j$.

**Definition 2.3 (Proximity graph).**
The *proximity graph* $\mathcal{G}(D,r)$ has vertex set $\{0,\dots,n-1\}$, with
distinct $i, j$ adjacent iff $D(i,j) \le r$ and $D(j,i) \le r$.

**Definition 2.4 (Clique complex).**
For a simple graph $H$, its *clique complex* (flag complex) $\mathrm{Cl}(H)$ is
the family of all cliques of $H$ — subsets $S$ that are pairwise adjacent:
$$\mathrm{Cl}(H) = \{\, S \subseteq V(H) : S \text{ is a clique of } H \,\}.$$

**Definition 2.5 (Multiplicative $c$-approximation).**
A family $G : \mathbb{R} \to \{\text{complexes on } \{0,\dots,n-1\}\}$ is a
*multiplicative $c$-approximation* (a $c$-interleaving) of $\mathrm{VR}(D,\cdot)$
if $c \ge 1$ and, for all $t \ge 0$,
$$\mathrm{VR}(D,t) \subseteq G(ct) \qquad\text{and}\qquad G(t) \subseteq \mathrm{VR}(D, ct).$$

**Definition 2.6 (Bit complexity).**
For a finite family $F$ of size $|F|$, its *bit complexity* is
$$\mathrm{bits}(F) = \lceil \log_2 |F| \rceil,$$
the number of bits needed to give each member a distinct binary address.

## 3. The Clique Dictionary (Geometry ↔ Graph Theory)

The first bridge identifies the Vietoris–Rips complex with a purely
graph-theoretic object.

**Theorem 3.1 (Clique dictionary).**
Let $D$ be a dissimilarity and $r \in \mathbb{R}$ with $D(i,i) \le r$ for all
$i$. Then
$$\mathrm{VR}(D, r) = \mathrm{Cl}\big(\mathcal{G}(D, r)\big).$$

*Proof sketch.* Let $S$ be a subset. If $S \in \mathrm{VR}(D,r)$, then for
distinct $i,j \in S$ we have $D(i,j) \le r$ and $D(j,i) \le r$, so $i,j$ are
adjacent in $\mathcal{G}(D,r)$; hence $S$ is a clique. Conversely, if $S$ is a
clique, then any two distinct vertices are adjacent, giving $D(i,j) \le r$; and
for $i = j$ the diagonal hypothesis $D(i,i) \le r$ supplies the remaining pairs.
Thus $S \in \mathrm{VR}(D,r)$. $\square$

This is the standard flag-complex identity underlying the homotopy theory of
Vietoris–Rips complexes; here it is the hinge that lets extremal graph theory act
on a geometric object.

## 4. The Extremal Bound (Graph Theory)

**Theorem 4.1 (Clique-count ceiling).**
Every graph $H$ on $n$ vertices satisfies
$$|\mathrm{Cl}(H)| \le 2^n.$$

*Proof sketch.* Every clique is in particular a subset of the $n$-vertex set, so
$\mathrm{Cl}(H)$ is contained in the power set, which has $2^n$ elements.
$\square$

**Theorem 4.2 (Maximizer).**
For the complete graph $K_n$, every subset is a clique, so
$$\mathrm{Cl}(K_n) = \mathcal{P}(\{0,\dots,n-1\}), \qquad |\mathrm{Cl}(K_n)| = 2^n.$$
Hence $K_n$ attains the ceiling of Theorem 4.1, and $|\mathrm{Cl}(H)| \le
|\mathrm{Cl}(K_n)|$ for every graph $H$ on $n$ vertices.

*Proof sketch.* In $K_n$ all distinct pairs are adjacent, so the pairwise
adjacency condition defining a clique is vacuously satisfied by every subset;
therefore $\mathrm{Cl}(K_n)$ is the full power set of size $2^n$. Combining with
Theorem 4.1 gives the comparison. $\square$

## 5. The Equidistant Configuration Is Extremal

We now show the equidistant configuration is precisely the case where the ceiling
is reached.

**Theorem 5.1 (Equidistant proximity graph is complete).**
If $d \le r$, then $\mathcal{G}(\mathrm{eq}_d, r) = K_n$.

*Proof sketch.* For distinct $i, j$, the values $\mathrm{eq}_d(i,j) =
\mathrm{eq}_d(j,i) = d \le r$, so every distinct pair is adjacent; conversely
adjacency requires distinctness. Thus the graph is exactly the complete graph.
$\square$

**Corollary 5.2 (Exponential count).**
If $0 \le d \le r$, then
$$\mathrm{VR}(\mathrm{eq}_d, r) = \mathcal{P}(\{0,\dots,n-1\}), \qquad |\mathrm{VR}(\mathrm{eq}_d, r)| = 2^n.$$

*Proof sketch.* Directly, for any subset $S$ and any $i,j \in S$, the value
$\mathrm{eq}_d(i,j)$ is either $0$ (if $i=j$) or $d \le r$; in both cases it is
$\le r$, so every subset is a simplex. Equivalently, combine the clique
dictionary (Theorem 3.1, whose diagonal hypothesis holds since $\mathrm{eq}_d(i,i)
= 0 \le r$) with Theorem 5.1 and Theorem 4.2. The cardinality is the size of the
power set, $2^n$. $\square$

## 6. The Information-Theoretic Floor

We formalize the description-length reading of the count.

**Lemma 6.1 (Sufficiency of $\mathrm{bits}$).**
For every finite family $F$, $\;|F| \le 2^{\mathrm{bits}(F)}$.

*Proof sketch.* This is the defining property of the ceiling logarithm:
$M \le 2^{\lceil \log_2 M\rceil}$ for all $M$. $\square$

**Lemma 6.2 (Necessity / lower bound on bits).**
If a finite family $F$ satisfies $2^k \le |F|$, then $k \le \mathrm{bits}(F)$.

*Proof sketch.* From $2^k \le |F| \le 2^{\mathrm{bits}(F)}$ (Lemma 6.1) and the
strict monotonicity of $m \mapsto 2^m$, we conclude $k \le \mathrm{bits}(F)$.
$\square$

## 7. The Lower Bound and the Bridge Theorem

**Theorem 7.1 (Simplex lower bound for approximations).**
Let $d \ge 0$ and let $G$ be a multiplicative $c$-approximation of
$\mathrm{VR}(\mathrm{eq}_d, \cdot)$. Then the level $G(cd)$ contains at least
$2^n$ simplices:
$$2^n \le |G(cd)|.$$

*Proof sketch.* The interleaving inclusion at scale $t = d$ gives
$\mathrm{VR}(\mathrm{eq}_d, d) \subseteq G(cd)$. Monotonicity of cardinality under
inclusion and Corollary 5.2 (with $r = d$) give $2^n = |\mathrm{VR}(\mathrm{eq}_d,
d)| \le |G(cd)|$. $\square$

**Theorem 7.2 (Bit lower bound for approximations).**
Under the hypotheses of Theorem 7.1,
$$n \le \mathrm{bits}\big(G(cd)\big).$$

*Proof sketch.* Apply Lemma 6.2 with $k = n$ and $F = G(cd)$, using Theorem 7.1's
inequality $2^n \le |G(cd)|$. $\square$

**Theorem 7.3 (Cross-domain bridge for the $\sqrt2$ threshold).**
Fix $c$ with $1 \le c < \sqrt{2}$, and let $G$ be a multiplicative
$c$-approximation of the equidistant Vietoris–Rips filtration
$\mathrm{VR}(\mathrm{eq}_{\sqrt2}, \cdot)$ on $n$ points. Then:

1. *(Geometry ↔ graph theory.)* $\mathrm{VR}(\mathrm{eq}_{\sqrt2}, \sqrt2) =
   \mathrm{Cl}(K_n)$.
2. *(Extremal graph theory.)* $|\mathrm{Cl}(K_n)| = 2^n$, and
   $|\mathrm{Cl}(H)| \le 2^n$ for every graph $H$ on $n$ vertices.
3. *(Information theory.)* The level $G(c\sqrt2)$ requires at least $n$ bits:
   $n \le \mathrm{bits}(G(c\sqrt2))$.
4. *(Sharp exponent.)* The effective exponent $\gamma(c) = \tfrac12 - \log_2 c$
   is strictly positive on the whole regime $1 \le c < \sqrt2$.

*Proof sketch.* Part (1) combines the clique dictionary (Theorem 3.1, valid
because $\mathrm{eq}_{\sqrt2}(i,i) = 0 \le \sqrt2$) with Theorem 5.1 (at $d = r =
\sqrt2$). Part (2) is Theorems 4.2 and 4.1. Part (3) is Theorem 7.2 applied at
$d = \sqrt2$. For part (4), $\gamma(c) > 0$ iff $\log_2 c < \tfrac12 = \log_2
\sqrt2$, i.e. iff $c < \sqrt2$, which holds by hypothesis. $\square$

## 8. Discussion: three extremes, one object

The force of Theorem 7.3 is the coincidence it records. The number $2^n$ appears
three times, wearing three different hats:

- As a **maximum**: the largest possible clique count over all $n$-vertex graphs
  (Theorem 4.1), uniquely achieved by $K_n$.
- As a **count**: the exact number of simplices in the equidistant Vietoris–Rips
  complex at scale $\sqrt2$ (Corollary 5.2).
- As an **exponential of a bit cost**: $2^n$ addressable objects require exactly
  $n$ bits (Lemma 6.2), a hard description-length floor.

The equidistant configuration is the unique geometric object whose proximity
graph is the extremal graph, whose complex hits the extremal count, and whose
level thereby carries the maximal irreducible bit content. The
$\sqrt2$ threshold is where these extremes lock together: it is simultaneously the
pairwise distance of the standard simplex of basis vectors and the value at which
$\gamma(c) = \tfrac12 - \log_2 c$ crosses zero.

**On sharpness.** The equidistant family delivers a uniform $2^n$ lower bound but
does not by itself *witness* the graceful degradation of $\gamma(c)$ as $c \to
\sqrt2^-$: on this single family the bound is the flat value $2^n$ for every $c <
\sqrt2$, and $\gamma(c)$ enters only as the reason the threshold sits at $\sqrt2$.
A configuration whose *optimal* approximation size is genuinely $2^{\gamma(c)\,n}$
with $\gamma(c) \to 0$ would make the exponent sharp; see Section 10.

## 9. Applications

- **Guarantees for TDA pipelines.** The bound certifies that any
  approximation scheme claiming faithfulness better than a $\sqrt2$ stretch cannot
  provide worst-case sub-exponential size. It delineates the achievable region for
  sparsification.
- **Benchmark hard instance.** The equidistant cloud (standard basis vectors) is
  a compact, fully explicit worst case against which candidate compression
  algorithms can be stress-tested.
- **A reusable dictionary.** Theorem 3.1 lets extremal-graph-theoretic results
  (clique counts, forbidden-subgraph bounds) be imported wholesale into TDA, and
  the bit-complexity reading connects complex size to coding-theoretic cost.

## 10. Future Directions

1. **Homological refinement.** Replace the multiplicative interleaving of
   *complexes* by an interleaving of *persistence modules*, and derive the lower
   bound at the level of barcodes / interleaving distance rather than raw simplex
   counts.
2. **Beyond the equidistant instance.** Construct families (e.g. spherical codes,
   or perturbed simplices realizing Jung's constant $\sqrt{2n/(n+1)} \to
   \sqrt2$) whose optimal approximation size is genuinely $2^{\gamma(c)\,n}$ with
   $\gamma(c) \to 0$, making the exponent sharp rather than a mere lower bound.
3. **Quantitative extremal graph theory.** Strengthen the clique-count ceiling to
   the Moon–Moser / Kruskal–Katona regime, bounding clique counts in terms of
   edge counts or forbidden subgraphs, and transport these into TDA via the
   proximity-graph dictionary.
4. **Entropic information theory.** Upgrade the worst-case bit complexity to a
   Shannon-entropy statement: the uniform distribution over the $2^n$ simplices
   has entropy exactly $n$ bits, giving an average-case / coding-theoretic
   companion to the description-length floor.

## 11. Conclusion

Below the $\sqrt2$ threshold, the exponential size of the Vietoris–Rips
filtration is not an artifact of a particular data set or algorithm — it is a
law, visible from geometry, graph theory, and information theory at once. The
equidistant configuration of $n$ points at mutual distance $\sqrt2$ is the single
object where all three subjects reach their extremes together, and the exponent
$\gamma(c) = \tfrac12 - \log_2 c$ measures exactly how much room compression has:
none, until the stretch reaches $\sqrt2$.
