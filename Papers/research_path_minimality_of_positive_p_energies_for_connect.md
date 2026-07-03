# Path-Minimality of Positive $p$-Energies for Connected Bipartite Graphs

## Abstract

We study the *positive $p$-energy* $E_p^{+}(G) = \sum_{\lambda_k > 0} \lambda_k^{\,p}$
of a finite simple graph $G$, where $\lambda_1, \dots, \lambda_n$ are the
eigenvalues of the adjacency matrix. Our central contribution is an exact,
elementary anchor for the extremal theory of these energies at the exponent
$p = 2$. We prove a spectral–combinatorial identity, that the squared spectral
energy equals twice the number of edges,
$\sum_{i} \lambda_i^2 = 2\,|E(G)|$, valid for every finite simple graph. Combining
it with the tree bound $|E(G)| \ge n-1$ for connected graphs yields
**path-minimality of the squared spectral energy**: every connected graph on $n$
vertices has $\sum_i \lambda_i^2 \ge 2(n-1)$, the exact value attained by the path
$P_n$. For bipartite graphs the spectrum is symmetric about zero, which we
formalize as a reflection-antisymmetry property of the ordered spectrum; this
collapses the positive $p$-energy to exactly one half of the absolute (Schatten)
$p$-energy $\sum_k |\lambda_k|^p$ for every nonzero exponent $p$. As a consequence,
for connected bipartite $G$ we obtain $E_2^{+}(G) = |E(G)| \ge n-1 = E_2^{+}(P_n)$:
the path minimizes the positive $2$-energy among connected bipartite graphs. We
also record the closed-form path spectrum $\lambda_k = 2\cos((k+1)\pi/(n+1))$ and
verify consistency of the two computations. We conclude with a program for
extending path-minimality to all $p \ge 2$ via spectral majorization.

**Keywords:** graph energy, adjacency spectrum, positive $p$-energy, bipartite
graph, path graph, Schatten norm, spectral–combinatorial identity, majorization.

---

## 1. Introduction

The *spectrum* of a graph — the multiset of eigenvalues of its adjacency
matrix — is one of the most fruitful invariants in combinatorics, encoding
connectivity, expansion, coloring bounds, and much more. A recurring theme is to
attach a scalar *energy* to the spectrum and ask which graphs are extremal. The
original notion, due to Gutman, is the graph energy
$\mathcal{E}(G) = \sum_k |\lambda_k|$, motivated by Hückel molecular-orbital theory,
where it approximates the total $\pi$-electron energy of a conjugated hydrocarbon.
Since then a family of variants — Schatten energies, Estrada indices, signed and
one-sided energies — has been studied intensively.

This paper concerns the **positive $p$-energy**
$$
E_p^{+}(G) = \sum_{\lambda_k > 0} \lambda_k^{\,p},
$$
the sum over positive eigenvalues of their $p$-th powers. We ask the extremal
question: *among connected graphs on a fixed number of vertices, which minimizes
$E_p^{+}$?* We conjecture, and for the exponent $p = 2$ prove, that the answer is
the **path** $P_n$ — the unique tree with maximum diameter, a straight line of
vertices.

Our results are organized around a single clarifying identity. While
$E_p^{+}$ is defined spectrally, at $p = 2$ it is *purely combinatorial*: the sum
of the squares of all eigenvalues equals twice the edge count. This transforms an
extremal spectral problem into the elementary observation that connected graphs
need at least $n-1$ edges. Bipartiteness then supplies a symmetry that turns the
"all eigenvalues" statement into the desired "positive eigenvalues" statement,
because the positive $p$-energy of a bipartite graph is exactly half of a Schatten
$p$-norm.

### Contributions

1. **The squared-energy identity** (Theorem 4.1):
   $\sum_i \lambda_i^2 = 2|E(G)|$ for every finite simple graph, proved via the
   trace of $A^2$ and the degree sum.
2. **Path-minimality at $p = 2$** (Theorem 4.4): every connected graph on $n$
   vertices satisfies $\sum_i \lambda_i^2 \ge 2(n-1)$, with equality for $P_n$.
3. **Positive energy as half a Schatten norm** (Theorem 5.3): for a
   reflection-antisymmetric (bipartite) spectrum and any nonzero $p$,
   $\sum_k |\lambda_k|^p = 2 E_p^{+}$; equivalently $E_p^{+} = \tfrac12 \sum_k |\lambda_k|^p$.
4. **Bipartite path-minimality of positive $2$-energy** (Corollary 5.4):
   $E_2^{+}(G) = |E(G)| \ge n-1 = E_2^{+}(P_n)$ for connected bipartite $G$.
5. **Closed-form consistency** (Section 6): the path spectrum
   $\lambda_k = 2\cos((k+1)\pi/(n+1))$ satisfies $\sum_k \lambda_k^2 = 2(n-1)$,
   reconciling the closed-form and combinatorial routes.

---

## 2. Preliminaries and notation

Let $G = (V, E)$ be a finite simple graph on $n = |V|$ vertices, with no loops or
multiple edges. Fix an ordering $v_1, \dots, v_n$ of the vertices.

**Adjacency matrix.** The *adjacency matrix* $A = A(G) \in \mathbb{R}^{n\times n}$
has entries
$$
A_{ij} = \begin{cases} 1 & \text{if } v_i \text{ and } v_j \text{ are adjacent},\\ 0 & \text{otherwise.}\end{cases}
$$
Because adjacency is symmetric and irreflexive, $A$ is a real symmetric matrix with
zero diagonal; in particular $A^{\mathsf T} = A$ (it is Hermitian over $\mathbb{R}$).

**Spectrum.** By the spectral theorem, $A$ has $n$ real eigenvalues (with
multiplicity) $\lambda_1(G) \ge \lambda_2(G) \ge \cdots \ge \lambda_n(G)$, and an
orthonormal eigenbasis; equivalently $A = U D U^{\mathsf T}$ for an orthogonal $U$
and $D = \operatorname{diag}(\lambda_1, \dots, \lambda_n)$. This multiset is the
*spectrum* of $G$.

**Degree.** The degree $\deg(v)$ of a vertex is the number of edges incident to
$v$. The handshake identity $\sum_v \deg(v) = 2|E|$ holds because each edge
contributes to exactly two degrees.

**Energies.** For a real exponent $p$, define
$$
E_p^{+}(G) = \sum_{k:\ \lambda_k > 0} \lambda_k^{\,p}, \qquad
E_p^{-}(G) = \sum_{k:\ \lambda_k < 0} (-\lambda_k)^{\,p}, \qquad
\|G\|_p^p = \sum_{k} |\lambda_k|^{\,p}.
$$
$E_p^{+}$ and $E_p^{-}$ are the *positive* and *negative* $p$-energies;
$\|G\|_p^p$ is the *absolute* (Schatten) $p$-energy. Zero eigenvalues contribute to
none of the three sums for $p > 0$.

**The path graph.** The *path* $P_n$ has vertex set $\{1, \dots, n\}$ and edges
$\{i, i+1\}$ for $1 \le i \le n-1$; it is connected, bipartite, and has exactly
$n-1$ edges. Its adjacency eigenvalues have the classical closed form
$$
\lambda_k(P_n) = 2\cos\!\left(\frac{(k+1)\pi}{n+1}\right), \qquad k = 0, 1, \dots, n-1.
$$

**Bipartite graphs.** $G$ is *bipartite* if $V$ partitions into $V = X \sqcup Y$
with every edge having one endpoint in each part. Equivalently $G$ has no odd
cycle. A foundational fact of spectral graph theory is that $G$ is bipartite iff
its spectrum is symmetric about $0$: $\lambda$ is an eigenvalue (with multiplicity
$m$) iff $-\lambda$ is (with the same multiplicity). We encode this symmetry
combinatorially below (Definition 5.1).

---

## 3. The extremal question

Fix $n$ and range over all connected graphs on $n$ vertices. We seek
$$
\min_{G\ \text{connected}} E_p^{+}(G).
$$
The path $P_n$ is the natural candidate minimizer: it is the sparsest connected
shape (a tree), and its spectrum hugs the interval $(-2, 2)$ as tightly as a
connected graph can. The following sections prove this minimality exactly at
$p = 2$ and reduce the general $p \ge 2$ case to a majorization statement.

We restrict the sharpest conclusions to **bipartite** graphs for a structural
reason: only for bipartite graphs does the positive $p$-energy relate cleanly (by
a factor of two) to the symmetric absolute energy, which is what our identity
controls. The path is bipartite, so this is the natural class in which to state
its extremality.

---

## 4. The squared-energy identity and path-minimality at $p = 2$

### 4.1 Squared spectral energy equals twice the edge count

**Theorem 4.1 (Squared-energy identity).**
*For every finite simple graph $G$ with adjacency matrix $A$ and eigenvalues
$\lambda_1, \dots, \lambda_n$,*
$$
\sum_{i=1}^{n} \lambda_i^2 \;=\; \operatorname{trace}(A^2) \;=\; \sum_{v \in V} \deg(v) \;=\; 2\,|E(G)|.
$$

*Proof sketch.* We chain three equalities.

*(a) $\sum_i \lambda_i^2 = \operatorname{trace}(A^2)$.* Since $A$ is real
symmetric, the spectral theorem gives $A = U D U^{\mathsf T}$ with $U$ orthogonal
and $D = \operatorname{diag}(\lambda_1,\dots,\lambda_n)$. Then
$A^2 = U D^2 U^{\mathsf T}$, and the trace is invariant under conjugation
(equivalently, cyclic:
$\operatorname{trace}(U D^2 U^{\mathsf T}) = \operatorname{trace}(D^2 U^{\mathsf T} U) = \operatorname{trace}(D^2)$).
As $D^2 = \operatorname{diag}(\lambda_1^2, \dots, \lambda_n^2)$, its trace is
$\sum_i \lambda_i^2$.

*(b) $\operatorname{trace}(A^2) = \sum_v \deg(v)$.* The $(v,v)$ diagonal entry of
$A^2$ is $\sum_w A_{vw} A_{wv} = \sum_w A_{vw}^2$. Since entries are $0/1$,
$A_{vw}^2 = A_{vw}$, so this sum counts the neighbors of $v$, i.e. equals
$\deg(v)$. Summing the diagonal gives $\operatorname{trace}(A^2) = \sum_v \deg(v)$.
(Combinatorially, $(A^2)_{vv}$ counts closed walks of length two from $v$, each of
which goes to a neighbor and back.)

*(c) $\sum_v \deg(v) = 2|E|$.* This is the handshake lemma: summing degrees counts
each edge once from each of its two endpoints. $\qquad\blacksquare$

**Remark 4.2.** The identity is not a definitional rewrite: step (a) uses genuine
spectral theory (orthogonal diagonalizability of symmetric matrices). It fails for
non-symmetric $0/1$ matrices, where eigenvalues can be complex and
$\sum \lambda_i^2 \ne \operatorname{trace}(A^2)$ in general is replaced by more
delicate statements.

### 4.2 The tree bound

**Lemma 4.3 (Connectivity forces $n-1$ edges).**
*Every connected simple graph on $n \ge 1$ vertices has at least $n-1$ edges, i.e.
$|E(G)| \ge n-1$. Equality holds iff $G$ is a tree.*

*Proof sketch.* A connected graph contains a spanning tree — a connected acyclic
subgraph on all $n$ vertices — obtained, e.g., by repeatedly deleting an edge lying
on a cycle until none remain, which cannot disconnect the graph. A tree on $n$
vertices has exactly $n-1$ edges (by induction: a leaf and its edge can be removed,
reducing both counts by one). Since the spanning tree is a subgraph,
$|E(G)| \ge n-1$, with equality precisely when $G$ has no extra edges, i.e. $G$ is
itself a tree. $\qquad\blacksquare$

### 4.3 Path-minimality of the squared energy

Combining the identity with the tree bound gives the anchor result.

**Theorem 4.4 (Path-minimality at $p = 2$).**
*Let $G$ be a connected simple graph on $n = |V| \ge 1$ vertices. Then*
$$
\sum_{i=1}^{n} \lambda_i(G)^2 \;\ge\; 2(n-1) \;=\; \sum_{k=0}^{n-1} \lambda_k(P_n)^2.
$$
*That is, the path $P_n$ minimizes the squared spectral energy among connected
graphs on $n$ vertices.*

*Proof sketch.* By Theorem 4.1, $\sum_i \lambda_i(G)^2 = 2|E(G)|$. By Lemma 4.3,
$|E(G)| \ge n-1$, so $\sum_i \lambda_i(G)^2 \ge 2(n-1)$. The path $P_n$ is
connected with exactly $n-1$ edges, so its squared energy is $2(n-1)$, attaining
the bound. (Section 6 verifies $\sum_k \lambda_k(P_n)^2 = 2(n-1)$ directly from the
cosine closed form, independent of the edge count.) $\qquad\blacksquare$

**Remark 4.5 (Non-vacuity).** Connectivity is essential. The empty graph on
$n \ge 2$ vertices has all eigenvalues $0$, so $\sum_i \lambda_i^2 = 0 < 2(n-1)$;
without connectivity the bound is false. The theorem's content is exactly that
connectivity, and nothing more, forces the path's energy.

---

## 5. Bipartite symmetry: positive energy as half a Schatten norm

Theorem 4.4 controls the *total* squared energy $\sum_i \lambda_i^2$. To descend to
the *positive* energy $E_2^{+}$ we exploit the sign symmetry of bipartite spectra.
We phrase the symmetry combinatorially, so that it applies to any ordered real
spectrum, not just to graph eigenvalues.

**Definition 5.1 (Reflection-antisymmetric spectrum).**
A finite real spectrum, given as values $f(0), f(1), \dots, f(n-1)$ of a function
$f : \{0, \dots, n-1\} \to \mathbb{R}$, is *reflection-antisymmetric* if
$$
f(n-1-k) = -\,f(k) \qquad \text{for all } 0 \le k < n.
$$
The ordered adjacency spectrum of a bipartite graph is reflection-antisymmetric:
pairing the $k$-th largest eigenvalue with the $k$-th smallest realizes the
$\lambda \leftrightarrow -\lambda$ symmetry. For the path, this is visible directly
from the closed form, since
$2\cos\!\big(\tfrac{(n-k)\pi}{n+1}\big) = -\,2\cos\!\big(\tfrac{(k+1)\pi}{n+1}\big)$.

**Theorem 5.2 (Bipartite balance).**
*Let $f$ be a reflection-antisymmetric spectrum on $\{0, \dots, n-1\}$ and let
$p \in \mathbb{R}$ be any exponent. Then the positive and negative $p$-energies
coincide:*
$$
\sum_{k:\ f(k) > 0} f(k)^{\,p} \;=\; \sum_{k:\ f(k) < 0} (-f(k))^{\,p}.
$$

*Proof sketch.* Reindex the negative-side sum by the reflection $k \mapsto n-1-k$,
a bijection of $\{0, \dots, n-1\}$ onto itself. Under it $f(k) < 0$ becomes
$f(n-1-k) = -f(k) > 0$, and the summand $(-f(k))^p$ becomes
$(-f(n-1-k))^p = (f(k))^p$ wait — carefully: after substitution the negative-side
term at index $n-1-k$ equals $(-f(n-1-k))^p = (f(k))^p$ evaluated where $f(k) > 0$.
Thus the reflected negative-side sum is termwise identical to the positive-side
sum. Formally, reflecting the summation index and applying the antisymmetry
$f(n-1-k) = -f(k)$ turns each negative-side contribution into the matching
positive-side contribution, so the two sums are equal. $\qquad\blacksquare$

**Theorem 5.3 (Positive energy is half the Schatten energy).**
*Let $f$ be a spectrum on $\{0, \dots, n-1\}$ and let $p \ne 0$. Then the absolute
$p$-energy splits as*
$$
\sum_{k} |f(k)|^{\,p} \;=\; \Big(\sum_{f(k)>0} f(k)^p\Big) + \Big(\sum_{f(k)<0} (-f(k))^p\Big) \;=\; E_p^{+} + E_p^{-}.
$$
*If in addition $f$ is reflection-antisymmetric (bipartite), then*
$$
\sum_{k} |f(k)|^{\,p} \;=\; 2\,E_p^{+}, \qquad\text{equivalently}\qquad E_p^{+} = \tfrac12 \sum_{k} |f(k)|^{\,p}.
$$

*Proof sketch.* For the split, partition the index set by the sign of $f(k)$ into
positive, negative, and zero parts. On the positive part $|f(k)|^p = f(k)^p$; on
the negative part $|f(k)|^p = (-f(k))^p$; on the zero part $|f(k)|^p = 0^p = 0$
because $p \ne 0$. Summing gives $E_p^{+} + E_p^{-}$. The hypothesis $p \ne 0$ is
load-bearing: at $p = 0$ the convention $0^0 = 1$ makes each zero eigenvalue
contribute $1$ to the left side but $0$ to both signed energies, so the split fails
whenever a zero eigenvalue is present (e.g. paths of odd order). Given the split,
apply Theorem 5.2 to replace $E_p^{-}$ by $E_p^{+}$, yielding
$\sum_k |f(k)|^p = 2 E_p^{+}$. $\qquad\blacksquare$

**Corollary 5.4 (Bipartite path-minimality of positive $2$-energy).**
*Let $G$ be a connected bipartite graph on $n \ge 1$ vertices. Then*
$$
E_2^{+}(G) \;=\; |E(G)| \;\ge\; n-1 \;=\; E_2^{+}(P_n).
$$
*The path $P_n$ minimizes the positive $2$-energy among connected bipartite graphs
on $n$ vertices, with minimum value $n-1$.*

*Proof sketch.* Apply Theorem 5.3 with $p = 2$ to the (bipartite,
reflection-antisymmetric) spectrum of $G$:
$\sum_k |\lambda_k|^2 = 2 E_2^{+}(G)$. But $\sum_k |\lambda_k|^2 = \sum_k \lambda_k^2 = 2|E(G)|$
by Theorem 4.1, so $E_2^{+}(G) = |E(G)|$. Lemma 4.3 gives $|E(G)| \ge n-1$, and
$P_n$ (bipartite, connected, $n-1$ edges) attains equality with
$E_2^{+}(P_n) = n-1$. $\qquad\blacksquare$

---

## 6. Closed-form consistency check

The path spectrum admits the closed form $\lambda_k(P_n) = 2\cos((k+1)\pi/(n+1))$,
$k = 0, \dots, n-1$. We verify that the direct sum-of-squares matches the
combinatorial value $2(n-1)$ from Theorem 4.4, providing an independent check.

**Proposition 6.1.** *For every $n \ge 1$,*
$$
\sum_{k=0}^{n-1} \Big(2\cos\tfrac{(k+1)\pi}{n+1}\Big)^2 \;=\; 2(n-1).
$$

*Proof sketch.* Using $4\cos^2\theta = 2 + 2\cos 2\theta$,
$$
\sum_{k=0}^{n-1} 4\cos^2\!\tfrac{(k+1)\pi}{n+1}
= 2n + 2\sum_{k=0}^{n-1}\cos\tfrac{2(k+1)\pi}{n+1}.
$$
The remaining cosine sum is a Dirichlet kernel evaluated at nonzero frequency: the
$n+1$-st roots of unity sum to zero, so $\sum_{j=0}^{n}\cos\tfrac{2\pi j}{n+1} = 0$;
removing the $j=0$ term (value $1$) leaves
$\sum_{k=0}^{n-1}\cos\tfrac{2(k+1)\pi}{n+1} = -1$. Hence the total is
$2n + 2(-1) = 2(n-1)$. $\qquad\blacksquare$

This reconciles the two derivations: the closed-form cosine computation and the
"edges $\times 2$" combinatorial identity both give $2(n-1)$, as they must, since
both compute the squared spectral energy of the same graph.

---

## 7. Algorithms

We describe the procedures used to compute and verify the quantities above.

**Algorithm A (Squared energy via edges).** *Input:* a graph $G$. *Output:*
$\sum_i \lambda_i^2$. By Theorem 4.1 this is simply $2|E(G)|$; the algorithm counts
edges in $O(|V| + |E|)$ time — no eigenvalue computation is needed. This is the
practical payoff of the identity: a spectral quantity computed combinatorially.

**Algorithm B (Positive $p$-energy from the spectrum).** *Input:* symmetric matrix
$A$, exponent $p$. *Output:* $E_p^{+}$. Diagonalize $A$ (cost $O(n^3)$), then sum
$\lambda^p$ over positive eigenvalues. For bipartite $A$ one may instead compute
$\tfrac12 \sum_k |\lambda_k|^p$ (Theorem 5.3), halving the bookkeeping and improving
numerical symmetry.

**Algorithm C (Extremal sweep).** *Input:* $n$, exponent $p$. *Output:* the minimum
of $E_p^{+}$ over connected graphs on $n$ vertices, and a minimizer. Enumerate
connected graphs (or a certified family), compute $E_p^{+}$ for each, and return the
minimum. The theory predicts the path attains it at $p = 2$; the sweep provides
empirical support for the conjectured $p \ge 2$ extension.

---

## 8. Applications

- **Chemical graph theory.** Graph energies model $\pi$-electron energies of
  conjugated molecules. Extremal energies bound the range of stability among
  isomeric carbon skeletons; the path corresponds to a linear polyene, the least
  energetic connected topology at $p = 2$.
- **Network science.** The identity $\sum_i \lambda_i^2 = 2|E|$ ties a spectral
  "complexity" measure to raw edge density, giving a zero-cost proxy for spectral
  spread.
- **Machine learning on graphs.** Schatten-type spectral norms are used as
  regularizers; recognizing positive $p$-energy as half a Schatten norm on
  bipartite data lets one import the full norm-optimization toolkit and identify
  the sparsest (path-like) minimizers.

---

## 9. Discussion

The organizing insight is that the exponent $p = 2$ is an *anchor* where the
positive energy degenerates into a combinatorial count. Theorem 4.1 makes this
precise: squared spectral energy is twice the edges. Everything extremal at $p = 2$
then reduces to the elementary tree bound. Bipartiteness supplies exactly the
symmetry (Definition 5.1, Theorems 5.2–5.3) needed to pass from total energy to
positive energy without loss, revealing positive energy as half a Schatten norm.

Two subtleties deserve emphasis. First, the $p \ne 0$ hypothesis in Theorem 5.3 is
genuinely necessary, not a convenience: the $0^0$ anomaly at a zero eigenvalue
breaks the split, and paths of odd order carry such an eigenvalue. Second,
connectivity is indispensable in Theorem 4.4; disconnected graphs (e.g. the empty
graph) violate the bound, confirming the result is not vacuous.

---

## 10. Future directions

**Full path-minimality of positive $p$-energy via spectral majorization.**
For every connected bipartite graph on $n$ vertices and every real exponent
$p \ge 2$, the positive $p$-energy $\sum_{\lambda>0}\lambda^p$ should be minimized
by the path $P_n$. The key insight is that the ordered positive part of the
adjacency spectrum of any connected graph *majorizes* that of the path in the
Hardy–Littlewood–Pólya sense, and $t \mapsto t^p$ is convex for $p \ge 2$, so
Karamata's inequality transports the majorization into the energy inequality. The
$p = 2$ anchor is settled exactly (positive energy equals the edge count, which the
spanning-tree bound minimizes), so the remaining task is the upgrade from one fixed
exponent to the whole convex family.

**Uniqueness of the path as the strict minimizer.**
Beyond the inequality, the path should be the *unique* connected minimizer of
positive $p$-energy for $p > 2$. Equality in Karamata's inequality for a strictly
convex power forces the two spectra to coincide, and only the path realizes the
extremal interlacing pattern of positive eigenvalues among connected graphs. Strict
convexity of $t \mapsto t^p$ for $p > 2$ is elementary, so uniqueness reduces to a
finite rigidity statement about which connected graphs share the path's positive
spectrum.

**Sharp two-sided Schatten sandwich for bipartite graphs.**
For a connected bipartite graph the positive $p$-energy equals exactly one half of
the Schatten $p$-energy $\sum_k |\lambda_k|^p$, so extremal questions for positive
energy are extremal questions for a Schatten norm — squeezed between the path
(minimizer) and the complete bipartite graph (maximizer). The halving identity is
already isolated, so both extremes can be attacked with the same toolkit.

**Spectral-radius transfer at large exponent.**
As $p$ grows the positive $p$-energy is dominated by the largest eigenvalue, so
path-minimality for large $p$ should follow from the fact that the path minimizes
the spectral radius among connected graphs on $n$ vertices, with
$\lambda_{\max}(P_n) = 2\cos(\pi/(n+1))$. Since $E_p^{+}(G)^{1/p} \to \lambda_{\max}(G)$
and subleading terms are uniformly controlled, a spectral-radius lower bound plus a
tail estimate yields the energy inequality for all sufficiently large $p$.

---

## 11. Conclusion

We have established an exact, elementary foundation for the extremal theory of
positive $p$-energies. The squared-energy identity $\sum_i \lambda_i^2 = 2|E(G)|$
turns a spectral quantity into an edge count; the tree bound then delivers
path-minimality at $p = 2$; and bipartite reflection symmetry recasts positive
energy as half a Schatten norm, yielding
$E_2^{+}(G) = |E(G)| \ge n-1 = E_2^{+}(P_n)$ for connected bipartite graphs. These
anchors localize the remaining difficulty — the full $p \ge 2$ inequality — to a
clean majorization problem, charting a concrete path forward.
