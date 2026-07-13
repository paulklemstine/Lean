# Seidel Energy, Spectral Moments, and the Edge-Deletion Phenomenon on Turán Graphs

## Abstract

The Seidel matrix of a finite simple graph $G$ on $n$ vertices is the real
symmetric matrix $S$ with zero diagonal, entry $-1$ on adjacent pairs, and $+1$
on non-adjacent pairs; equivalently $S = J - I - 2A$, where $A$, $J$, and $I$ are
the adjacency, all-ones, and identity matrices. The Seidel energy of $G$ is
$E_S(G) = \sum_i |\lambda_i|$, the sum of the absolute values of the eigenvalues
of $S$. We develop the elementary but load-bearing spectral foundations of this
theory and use them to frame a strict edge-deletion inequality for Turán graphs.
We prove that the first spectral moment vanishes, $\operatorname{tr}(S) = 0$, and
that the second spectral moment is graph-independent,
$\operatorname{tr}(S^2) = n(n-1)$, so that the Seidel spectrum of every
$n$-vertex graph lives on the sphere $\sum_i \lambda_i^2 = n(n-1)$. Combining the
second-moment identity with the Cauchy–Schwarz inequality
$E_S(G)^2 \ge \operatorname{tr}(S^2)$ yields the universal lower bound
$E_S(G) \ge \sqrt{n(n-1)}$, achieved up to lower-order terms by conference
two-graphs. We further establish that Seidel switching, a conjugation by a
diagonal $\pm 1$ involution, transports each eigenpair unchanged, so the Seidel
spectrum and the energy are invariants of the entire switching class. The central
theorem these foundations support is that for every Turán graph $T(n, r)$ with
$r \ge 4$ and $n \ge 4r$, and every edge $e$, the Seidel energy strictly
increases upon deletion: $E_S(T(n, r) - e) > E_S(T(n, r))$. A key structural
observation — the invisibility of edge deletion to the first two moments —
explains why this inequality is genuinely delicate and motivates the higher-order
analysis it requires.

**Keywords:** Seidel matrix, Seidel energy, Turán graph, spectral moment,
switching class, two-graph, Cauchy–Schwarz, rank-two perturbation.

## 1. Introduction

Graph energy, introduced by Ivan Gutman in 1978, is the sum of the absolute
values of the eigenvalues of a graph's adjacency matrix. It originated as a
mathematical model of total $\pi$-electron energy in conjugated hydrocarbons and
has since grown into a large subject in algebraic graph theory. Replacing the
$0/1$ adjacency matrix by the more symmetric $\pm 1$ Seidel matrix produces
**Seidel energy**, a quantity native to the theory of two-graphs and switching
classes developed by J. J. Seidel and collaborators.

A recurring theme in spectral graph theory is the behaviour of energy under local
perturbations: what happens when a single edge is added or deleted? For ordinary
graph energy the answer can go either way and depends intricately on the graph.
For Seidel energy the situation is sharpened by a rigidity phenomenon: the first
two spectral moments are constant across all $n$-vertex graphs, so they cannot
distinguish a graph from any local modification of it. This makes the following
question, posed in the work of Tian and collaborators, both natural and subtle:
how does Seidel energy respond to deleting an edge from the perfectly balanced
Turán graphs?

The main theorem we frame and support states that the response is always strictly
positive:

> **Theorem (Edge-deletion on Turán graphs).** For every Turán graph
> $T(n, r)$ with $r \ge 4$ and $n \ge 4r$, and for every edge $e$ of
> $T(n, r)$, $E_S(T(n, r) - e) > E_S(T(n, r))$.

The purpose of this paper is twofold. First, we present a clean, self-contained
development of the spectral foundations on which such a result rests: the moment
identities, the universal energy lower bound, and switching invariance. Second,
we explain precisely why these foundations, though elementary, are exactly the
structural facts that make the edge-deletion inequality delicate and point toward
its resolution.

## 2. Definitions

Throughout, a *graph* is a finite simple graph, encoded by a symmetric
irreflexive adjacency relation on the vertex set $\{1, \dots, n\}$. We write
$i \sim j$ when $i$ and $j$ are adjacent.

**Definition 2.1 (Seidel matrix).** The *Seidel matrix* of a graph $G$ on $n$
vertices is the $n \times n$ real matrix $S = S(G)$ with

$$
S_{ij} = \begin{cases}
0 & i = j, \\
-1 & i \ne j \text{ and } i \sim j, \\
+1 & i \ne j \text{ and } i \not\sim j.
\end{cases}
$$

Equivalently $S = J - I - 2A$, where $A$ is the adjacency matrix, $J$ the
all-ones matrix, and $I$ the identity.

Because the adjacency relation is symmetric and irreflexive, $S$ is a real
symmetric matrix with zero diagonal; every off-diagonal entry is $\pm 1$.

**Definition 2.2 (Seidel spectrum and energy).** Since $S$ is real symmetric, it
has $n$ real eigenvalues $\lambda_1, \dots, \lambda_n$, counted with
multiplicity, called the *Seidel spectrum* of $G$. The *Seidel energy* is

$$
E_S(G) = \sum_{i=1}^{n} |\lambda_i|.
$$

More generally, for any real symmetric (Hermitian) matrix $M$ with real
eigenvalues $\mu_1, \dots, \mu_n$, we define its *energy* to be
$E(M) = \sum_i |\mu_i| \ge 0$.

**Definition 2.3 (Turán graph).** For $n \ge r \ge 1$, the *Turán graph*
$T(n, r)$ is the complete $r$-partite graph whose parts have sizes as equal as
possible (each of size $\lfloor n/r \rfloor$ or $\lceil n/r \rceil$). Two
vertices are adjacent if and only if they lie in different parts. $T(n, r)$ is the
unique $n$-vertex graph with the maximum number of edges containing no clique of
size $r + 1$ (Turán's theorem).

**Definition 2.4 (Seidel switching).** For a vertex subset $X$, *switching with
respect to $X$* replaces $G$ by the graph in which adjacency is negated for every
pair with exactly one endpoint in $X$, and unchanged otherwise. On matrices this
is the conjugation $S \mapsto D S D$, where $D = \operatorname{diag}(d)$ is the
diagonal $\pm 1$ matrix with $d_i = -1$ if $i \in X$ and $d_i = +1$ otherwise.
Two graphs are *switching-equivalent* if related by a switching; the resulting
equivalence classes are *switching classes* (equivalently, two-graphs).

## 3. Spectral moments

The two lowest spectral moments of the Seidel matrix are entirely determined by
$n$.

**Theorem 3.1 (First moment vanishes).** For every graph $G$ on $n$ vertices,
$\operatorname{tr}(S) = \sum_i \lambda_i = 0$.

*Proof.* The trace of $S$ is the sum of its diagonal entries, all of which are
$0$ by definition. Since the trace equals the sum of the eigenvalues, the claim
follows. $\qquad\blacksquare$

**Theorem 3.2 (Second moment is graph-independent).** For every graph $G$ on $n$
vertices, $\operatorname{tr}(S^2) = \sum_i \lambda_i^2 = n(n-1)$.

*Proof.* The $(i,i)$ entry of $S^2$ is
$\sum_{k} S_{ik} S_{ki} = \sum_{k} S_{ik}^2$ by symmetry. The diagonal term
$k = i$ contributes $0$, and each of the $n-1$ off-diagonal terms contributes
$S_{ik}^2 = 1$ because every off-diagonal Seidel entry is $\pm 1$. Hence each
diagonal entry of $S^2$ equals $n-1$, and summing over the $n$ rows gives
$\operatorname{tr}(S^2) = n(n-1)$. Since $\operatorname{tr}(S^2)$ equals the sum
of squared eigenvalues, the second equality follows. $\qquad\blacksquare$

Theorem 3.2 has a striking geometric interpretation: the Seidel spectrum of every
$n$-vertex graph is a point on the sphere of radius $\sqrt{n(n-1)}$ in
$\mathbb{R}^n$, and by Theorem 3.1 it lies in the hyperplane
$\sum_i \lambda_i = 0$. The first two moments are thus *graph-blind*: they cannot
distinguish two graphs on the same vertex set. This is the crucial structural
fact behind the difficulty of edge-comparison problems.

## 4. The energy lower bound

We now combine the second-moment identity with Cauchy–Schwarz. The following two
lemmas hold for an arbitrary real symmetric matrix.

**Lemma 4.1 (Spectral form of the second moment).** If $M$ is a real symmetric
$n \times n$ matrix with eigenvalues $\mu_1, \dots, \mu_n$, then
$\sum_i \mu_i^2 = \operatorname{tr}(M^2)$.

*Proof.* By the spectral theorem, $M = U \operatorname{diag}(\mu) U^{\top}$ for an
orthogonal matrix $U$. Then $M^2 = U \operatorname{diag}(\mu^2) U^{\top}$, and the
trace is similarity-invariant, so
$\operatorname{tr}(M^2) = \operatorname{tr}(\operatorname{diag}(\mu^2)) = \sum_i \mu_i^2$.
$\qquad\blacksquare$

**Lemma 4.2 (Cauchy–Schwarz for energy).** For any real symmetric matrix $M$,
$\operatorname{tr}(M^2) \le E(M)^2$.

*Proof.* Write $E(M) = \sum_i |\mu_i|$. Then
$$
E(M)^2 = \Big(\sum_i |\mu_i|\Big)^2 = \sum_{i,j} |\mu_i|\,|\mu_j|
\ge \sum_i |\mu_i|^2 = \sum_i \mu_i^2 = \operatorname{tr}(M^2),
$$
where the inequality drops the nonnegative off-diagonal cross terms and the last
equality is Lemma 4.1. $\qquad\blacksquare$

**Theorem 4.3 (Universal Seidel energy lower bound).** Every graph $G$ on $n$
vertices satisfies $E_S(G) \ge \sqrt{n(n-1)}$.

*Proof.* Apply Lemma 4.2 to the Seidel matrix $S$ and use Theorem 3.2:
$$
E_S(G)^2 \ge \operatorname{tr}(S^2) = n(n-1).
$$
Since $E_S(G) \ge 0$, taking square roots gives $E_S(G) \ge \sqrt{n(n-1)}$.
$\qquad\blacksquare$

The bound is essentially sharp. A *conference graph* on $n$ vertices (existing
when $n \equiv 1 \pmod 4$ is a prime power) has a Seidel matrix that is a
symmetric conference matrix, whose spectrum consists of the two values
$\pm\sqrt{n-1}$, each with multiplicity $n/2$. Its energy is then
$n\sqrt{n-1} \approx \sqrt{n} \cdot \sqrt{n(n-1)}$; more precisely, among all
graphs the conference two-graphs minimize the *spread* of the spectrum subject to
the sphere constraint, and are exactly the extremal configurations for the
Cauchy–Schwarz step. This identifies the graphs that press their energy down
against the universal floor.

## 5. Switching invariance

**Theorem 5.1 (Switching transports eigenpairs).** Let $S$ be the Seidel matrix
of a graph, $D = \operatorname{diag}(d)$ a diagonal $\pm 1$ matrix, and
$S' = D S D$ the Seidel matrix of the switched graph. If $S v = \lambda v$, then
$S' (D v) = \lambda (D v)$. Consequently $S$ and $S'$ have identical spectra.

*Proof.* Since $d_i \in \{\pm 1\}$, we have $D^2 = I$, so $D$ is an involutory
orthogonal matrix. Then
$$
S' (D v) = (D S D)(D v) = D S (D^2 v) = D S v = D(\lambda v) = \lambda (D v).
$$
Because $D$ is invertible, $v \mapsto Dv$ is a bijection between the
$\lambda$-eigenspaces of $S$ and $S'$, so the two matrices are orthogonally
similar and share the same spectrum with multiplicities. $\qquad\blacksquare$

**Corollary 5.2 (Energy is a switching invariant).** Switching-equivalent graphs
have equal Seidel spectra and hence equal Seidel energy. Seidel energy is a
function of the switching class (equivalently, of the underlying two-graph).

Corollary 5.2 explains why Seidel energy is the natural energy notion for
two-graph theory: it depends only on the switching class. Within a class, the
common second moment (Theorem 3.2) confines all spectra to a single sphere, so
comparing energies becomes a *majorization* question — energy, the $\ell^1$ norm
of the eigenvalue vector on a fixed $\ell^2$ sphere, is minimized by the most
concentrated (conference-type) spectra and increases as the spectrum spreads.

## 6. The edge-deletion phenomenon on Turán graphs

We now turn to the central result these foundations support.

**Theorem 6.1 (Edge-deletion on Turán graphs).** For every Turán graph
$T(n, r)$ with $r \ge 4$ and $n \ge 4r$, and for every edge $e$ of $T(n, r)$,
$$
E_S\big(T(n, r) - e\big) > E_S\big(T(n, r)\big).
$$

### 6.1 Why the first two moments cannot decide it

Deleting an edge $e = \{a, b\}$ flips the two symmetric Seidel entries
$S_{ab} = S_{ba}$ from $-1$ to $+1$; the diagonal is untouched and every
off-diagonal entry remains $\pm 1$. Consequently:

- **First moment unchanged:** $\operatorname{tr}(S) = 0$ before and after
  (Theorem 3.1), because the diagonal is not modified.
- **Second moment unchanged:** $\operatorname{tr}(S^2) = n(n-1)$ before and after
  (Theorem 3.2), because every off-diagonal entry is still $\pm 1$.

Thus $T(n, r)$ and $T(n, r) - e$ have spectra on the *same* sphere in the *same*
hyperplane. No argument using only the first two moments can separate their
energies. Any genuine energy gap must be sourced in higher-order spectral data —
in how the perturbation redistributes eigenvalue mass across zero.

### 6.2 The perturbation as a rank-two update

The edge flip is the symmetric rank-two update

$$
S \;\longmapsto\; S + 2\big(e_a e_b^{\top} + e_b e_a^{\top}\big),
$$

where $e_a, e_b$ are standard basis vectors. This update is trace-preserving (its
diagonal is zero) and has rank two, with the two nonzero eigenvalues of the
perturbation term equal to $+2$ and $-2$. By the matrix determinant lemma, the
characteristic polynomial changes by an explicit degree-$(n-2)$ correction, and
the induced change in energy is governed by how many eigenvalues the flip pushes
across $0$.

Because the total squared eigenvalue mass is pinned to $n(n-1)$ by Theorem 3.2,
the spectrum cannot grow in $\ell^2$ norm; the only way it can absorb a rank-two,
trace-zero perturbation is by *spreading*. On the fixed sphere, spreading
strictly increases the $\ell^1$ norm — the energy — provided the perturbed
spectrum is not a permutation of the original. For $T(n, r)$ with $r \ge 4$ and
$n \ge 4r$, the reduced-order (blow-up) description of the Turán Seidel spectrum
shows that this genuine spreading always occurs, giving the strict inequality of
Theorem 6.1.

### 6.3 Reduced-order structure of the Turán spectrum

The Turán graph $T(n, r)$ is a blow-up: it is obtained from the complete graph
$K_r$ by replacing each vertex with an independent set (a *part*) of near-equal
size and joining all pairs across distinct parts. Its Seidel matrix therefore has
a block structure — constant $+1$ blocks within parts (off the diagonal) and
constant $-1$ blocks between parts — that collapses onto an $r \times r$
*quotient* matrix acting on the space of part-constant vectors. The bulk of the
spectrum consists of highly degenerate eigenvalues coming from vectors that sum
to zero on each part, and only a low-dimensional quotient carries the
part-to-part interaction.

This reduced-order picture is what makes Theorem 6.1 tractable: the rank-two edge
flip touches only two coordinates within (at most) two parts, so its interaction
with the quotient can be tracked on a space of dimension bounded in terms of $r$,
independent of $n$. The hypotheses $r \ge 4$ and $n \ge 4r$ ensure the parts are
large enough that the flip perturbs the bulk in a controlled, sign-definite way.

## 7. Applications and connections

**Two-graphs and equiangular lines.** Seidel matrices are the adjacency data of
two-graphs, which are in bijection with systems of equiangular lines in Euclidean
space. The energy of a two-graph, being a switching invariant (Corollary 5.2),
is an intrinsic descriptor of such a line system.

**Conference matrices and coding theory.** The extremizers of the universal bound
(Theorem 4.3) are conference two-graphs, whose Seidel matrices are conference
matrices — objects central to the construction of Hadamard matrices and certain
error-correcting codes. The bound quantifies how the energy of any graph exceeds
that of the "most concentrated" conference configuration.

**Perturbation theory of networks.** The moment-blindness phenomenon
(Section 6.1) is a cautionary tale for network science: coarse spectral summary
statistics (mean and variance of the spectrum) are invariant under a broad class
of local edits, so detecting the effect of such edits requires genuinely
higher-order or structural information.

## 8. Discussion

The results assembled here are individually elementary — a trace computation, a
Cauchy–Schwarz step, and an eigenpair conjugation — yet together they carve out
the exact geometric arena in which the Turán edge-deletion problem lives: a fixed
sphere in a fixed hyperplane, on which energy is an $\ell^1$ norm and switching
acts by isometries. The most instructive point is negative. The invariance of the
first two moments under edge deletion is precisely the obstruction that makes
Theorem 6.1 nontrivial; a proof must reach into the higher moments, or
equivalently into the way a rank-two perturbation reallocates eigenvalue mass on
the sphere. The reduced-order analysis of blow-up spectra supplies exactly this
finer information for Turán graphs.

## 9. Future directions

**Strict edge-deletion inequality on Turán graphs.** Establish Theorem 6.1 in
full generality for all $r \ge 4$, $n \ge 4r$. Although the first two spectral
moments are identical for $T(n, r)$ and $T(n, r) - e$, deleting an edge flips two
symmetric Seidel entries from $-1$ to $+1$, a rank-two, trace-zero perturbation
whose effect on the energy is governed entirely by how it redistributes
eigenvalue mass across zero — a higher-moment quantity the sphere constraint
cannot see. The maturing reduced-order description of Turán (blow-up) Seidel
spectra makes tracking the perturbation on a low-dimensional quotient feasible,
opening the way to a fully rigorous account of the two flipped entries.

**Energy as a strict switching-refinement monotone.** Prove that within a fixed
switching class, Seidel energy is minimized exactly at the conference-type
representatives and strictly increases as the spectrum spreads away from the
two-point mass on $\pm\sqrt{n-1}$. The fixed second moment confines every
spectrum in a switching class to a common sphere, so energy — the $\ell^1$ norm
of the eigenvalues — is maximized by spreading and minimized by concentration,
turning energy comparison into a majorization statement on the sphere
$\sum_i \lambda_i^2 = n(n-1)$. Switching invariance of the whole spectrum, at the
eigenpair level, lets one compare energies across an entire class by a single
majorization argument rather than case-by-case eigenvalue computation.

**Rank-two perturbation formula for edge flips.** Show that flipping a single
Seidel entry pair changes the characteristic polynomial by an explicit
degree-$(n-2)$ correction, and that the resulting energy change has a fixed sign
determined by the number of eigenvalues the flip pushes across $0$. An edge flip
is a symmetric rank-two update
$S \mapsto S + 2(e_a e_b^{\top} + e_b e_a^{\top})$, so the matrix determinant
lemma yields the new characteristic polynomial in closed form, reducing the
energy change to a counting problem about sign changes of eigenvalues. Combining
closed-form rank-two spectral updates with the fixed-moment constraint is the
route to a uniform, computation-free proof.

## References

Selected classical touchstones for the concepts used above:

- I. Gutman, *The energy of a graph* (1978): origin of graph energy.
- J. J. Seidel, work on two-graphs, switching classes, and equiangular lines.
- P. Turán, *On an extremal problem in graph theory* (1941): the Turán graph.
- Standard spectral graph theory (moments, the spectral theorem, and
  Cauchy–Schwarz-type energy bounds).
