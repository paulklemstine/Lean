# Equality Cases for the Maximum-Degree Spectral Bound of Signed Graphs

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Spectral graph theory × Linear algebra)

---

## Abstract

A *signed graph* is a graph whose edges are labelled $+1$ or $-1$; its *signed
adjacency matrix* is the real symmetric matrix $A$ with entries in $\{-1,0,1\}$
and zero diagonal. The classical maximum-degree bound asserts that every
eigenvalue $\mu$ of $A$ satisfies $|\mu| \le \Delta$, where
$\Delta = \max_i \sum_j |A_{ij}|$ is the maximum (unsigned) degree. We give a
self-contained development of this **Δ-bound together with its equality
structure**. Our main contributions are: (i) a Rayleigh/Gershgorin-flavoured
proof of $|\mu| \le \Delta$ via the maximum-magnitude entry of the eigenvector;
(ii) two *local equality theorems* showing that when $|\mu| = \Delta$, any vertex
attaining the peak eigenvector magnitude has degree exactly $\Delta$ (degree
saturation) and every neighbour of such a vertex also attains the peak magnitude
(magnitude propagation); and (iii) a sharpness witness — the all-positive complete
graph $K_n^+$ has the all-ones eigenvector with eigenvalue $n-1 = \Delta$,
realising equality. All results are formalised and machine-checked. The equality
theorems are the local engines from which global regularity and balance
characterisations follow, which we outline as future work. Throughout, every
bound depends only on $|A_{ij}|$, so the inequality is governed by the underlying
unsigned multigraph while the signs determine which switching class meets a given
extreme.

**Keywords:** signed graph, signed adjacency matrix, spectral radius, maximum
degree, eigenvalue bound, equality case, complete graph, Rayleigh quotient.

---

## 1. Introduction

Spectral graph theory extracts combinatorial information about a graph from the
eigenvalues of matrices attached to it. For an ordinary graph, the adjacency
matrix is a symmetric $0/1$ matrix, and a foundational fact is that its spectral
radius lies between the average and the maximum degree. The **maximum-degree
upper bound** — that every eigenvalue is at most the maximum degree in absolute
value — is among the first inequalities one proves, and its equality cases (for
connected graphs, equality forces regularity) are a staple of the subject.

*Signed graphs* generalise this picture by attaching a sign $\pm 1$ to each edge,
modelling antagonistic as well as cooperative relations. They arise in social
balance theory, statistical mechanics (frustrated spin systems), and the spectral
theory of line graphs and root systems. The signed adjacency matrix $A$ is still
real symmetric, so it has $n$ real eigenvalues, but the interplay between the
*signs* and the *spectrum* introduces phenomena absent in the unsigned world,
most notably the role of **balance**.

This paper isolates a clean, fully verified core: the maximum-degree bound for
signed adjacency matrices, *with* a complete description of its local equality
structure and an explicit sharpness witness. The treatment follows the spirit of
recent equality-case analyses for spectral bounds (e.g. Sun–Das 2020; Lan,
Wang and collaborators 2023) but is developed from first principles so that every
statement is self-contained.

### 1.1 Summary of results

- **Theorem 1 (Δ-bound).** If $Av = \mu v$ with $v \ne 0$ and every absolute row
  sum is $\le \Delta$, then $|\mu| \le \Delta$.
- **Theorem 2 (Degree saturation at equality).** If additionally $|\mu| = \Delta$
  and $i_0$ attains the peak magnitude $|v_{i_0}| = \max_j |v_j| > 0$, then the
  degree of $i_0$ equals $\Delta$.
- **Theorem 3 (Magnitude propagation at equality).** Under the same hypotheses,
  every neighbour $j$ of $i_0$ (every $j$ with $A_{i_0 j} \ne 0$) satisfies
  $|v_j| = |v_{i_0}|$.
- **Theorem 4 (Sharpness via $K_n^+$).** For the all-positive complete graph,
  the all-ones vector is an eigenvector with eigenvalue $n-1$, and every vertex has
  degree $n-1$; hence equality $|\mu| = \Delta = n-1$ is attained.

---

## 2. Definitions

We work over $\mathbb{R}$ with vertex set $\mathrm{Fin}\,n = \{0,1,\dots,n-1\}$.

> **Definition 1 (Signed adjacency matrix).** A *signed adjacency matrix* on $n$
> vertices is a real $n \times n$ matrix $A$ satisfying:
> 1. **Symmetry:** $A_{ij} = A_{ji}$ for all $i,j$ (i.e. $A^{\mathsf T} = A$);
> 2. **Sign entries:** $A_{ij} \in \{-1, 0, +1\}$ for all $i,j$;
> 3. **No loops:** $A_{ii} = 0$ for all $i$.

In the formalisation this is the structure `SignedAdj n`, bundling the matrix `A`
with proofs `isSymm`, `entries`, and `diag`. A signed graph is precisely the
combinatorial data encoded by such an $A$: an edge $\{i,j\}$ exists iff
$A_{ij} \ne 0$, and its sign is the value $A_{ij}$.

> **Definition 2 (Degree).** The *(unsigned) degree* of vertex $i$ is the absolute
> row sum
> $$d(i) \;=\; \sum_{j} |A_{ij}|,$$
> the number of edges incident to $i$. The *maximum degree* $\Delta$ is any upper
> bound for all absolute row sums: $\Delta \ge \sum_j |A_{ij}|$ for every $i$.

In the formalisation this is `degree A i = ∑ j, |A i j|`. We deliberately phrase
Theorems 1–3 with $\Delta$ as *any* uniform upper bound on the absolute row sums,
which is logically slightly stronger than fixing $\Delta = \max_i d(i)$ and makes
the hypotheses minimal.

> **Definition 3 (All-positive complete graph $K_n^+$).** The matrix
> $$\big(K_n^+\big)_{ij} \;=\; \begin{cases} 0 & i = j,\\ 1 & i \ne j,\end{cases}$$
> i.e. every off-diagonal entry is $+1$. This is `completePositive n`; it is a
> signed adjacency matrix (`completePositiveSignedAdj n`): symmetry, sign entries,
> and zero diagonal are immediate.

Here and below, for a vector $v \in \mathbb{R}^n$ the matrix–vector product is
$(Av)_i = \sum_j A_{ij} v_j$ (written `A *ᵥ v`), and $\mu \cdot v$ denotes scalar
multiplication.

---

## 3. The maximum-degree bound

> **Theorem 1 (Δ-bound; `eigenvalue_abs_le_maxDeg`).** Let
> $A \in \mathbb{R}^{n \times n}$, $v \in \mathbb{R}^n$, and $\mu, \Delta \in
> \mathbb{R}$. Suppose
> $$Av = \mu v, \qquad v \ne 0, \qquad \forall i,\ \sum_j |A_{ij}| \le \Delta.$$
> Then $|\mu| \le \Delta$.

**Proof sketch.** Since $v \ne 0$, the finite set $\{|v_i|\}_i$ has a maximiser:
choose $i_0$ with $|v_j| \le |v_{i_0}|$ for all $j$, and set $M := |v_{i_0}|$.
Because $v \ne 0$, $M > 0$ (if $M = 0$ then every $|v_j| \le 0$ forces $v = 0$).

Reading off coordinate $i_0$ of $Av = \mu v$ gives
$\mu\, v_{i_0} = \sum_j A_{i_0 j}\, v_j$. Taking absolute values and applying the
triangle inequality (`Finset.abs_sum_le_sum_abs`),
$$|\mu|\, M \;=\; \Big|\textstyle\sum_j A_{i_0 j}\, v_j\Big|
\;\le\; \sum_j |A_{i_0 j}|\,|v_j|.$$
Bounding each $|v_j| \le M$ termwise (`Finset.sum_le_sum` with
`mul_le_mul_of_nonneg_left`),
$$\sum_j |A_{i_0 j}|\,|v_j| \;\le\; \Big(\sum_j |A_{i_0 j}|\Big) M
\;\le\; \Delta\, M,$$
the last step using $\sum_j |A_{i_0 j}| \le \Delta$. Chaining yields
$|\mu|\, M \le \Delta\, M$. Cancelling the positive factor $M$
(`le_of_mul_le_mul_of_pos_right`) gives $|\mu| \le \Delta$. $\qquad\blacksquare$

The argument is a Rayleigh/Gershgorin hybrid: it is exactly the Gershgorin
disc estimate applied at the eigenvector's dominant coordinate. Crucially it uses
only $|A_{ij}|$, so the bound is a property of the underlying unsigned multigraph.

---

## 4. Equality cases

The power of Theorem 1 lies in analysing when the chain of inequalities in its
proof is tight. Two distinct inequalities can lose ground:
(a) the termwise bound $|v_j| \le M$, and (b) the row-sum bound
$\sum_j |A_{i_0 j}| \le \Delta$. Equality $|\mu| = \Delta$ forces *both* to be
equalities, yielding two structural theorems.

> **Theorem 2 (Degree saturation; `eq_case_degree_saturated`).** Suppose
> $Av = \mu v$, $\forall i,\ \sum_j |A_{ij}| \le \Delta$, and $|\mu| = \Delta$.
> Let $i_0$ satisfy $|v_j| \le |v_{i_0}|$ for all $j$ and $|v_{i_0}| > 0$. Then
> $$\sum_j |A_{i_0 j}| \;=\; \Delta,$$
> i.e. the peak vertex has degree exactly $\Delta$.

**Proof sketch.** Write $M = |v_{i_0}| > 0$. From coordinate $i_0$ of the
eigenvalue equation and the triangle inequality,
$|\mu|\,M \le \sum_j |A_{i_0 j}|\,|v_j|$. Two further estimates bound the
right-hand side:
$$\sum_j |A_{i_0 j}|\,|v_j| \;\le\; \sum_j |A_{i_0 j}|\, M
\;=\; \Big(\sum_j |A_{i_0 j}|\Big) M.$$
Substituting $|\mu| = \Delta$ on the left gives
$\Delta\, M \le \big(\sum_j |A_{i_0 j}|\big) M$, hence
$\Delta \le \sum_j |A_{i_0 j}|$ after cancelling $M > 0$. The reverse inequality
$\sum_j |A_{i_0 j}| \le \Delta$ is the hypothesis. Therefore
$\sum_j |A_{i_0 j}| = \Delta$. (The Lean proof packages these estimates into a
single `nlinarith` call fed the relevant termwise and factored inequalities.)
$\qquad\blacksquare$

> **Theorem 3 (Magnitude propagation; `eq_case_neighbors_attain_max`).** Under the
> hypotheses of Theorem 2, every neighbour of $i_0$ attains the peak magnitude:
> $$\forall j,\quad A_{i_0 j} \ne 0 \;\Longrightarrow\; |v_j| = |v_{i_0}|.$$

**Proof sketch.** Consider the nonnegative quantities
$g(j) := |A_{i_0 j}|\,(M - |v_j|) \ge 0$, which are nonnegative because
$|A_{i_0 j}| \ge 0$ and $M - |v_j| \ge 0$ by maximality of $M$. From the
eigenvalue equation, $|\mu|\, M \le \sum_j |A_{i_0 j}|\,|v_j|$ (call this S1).

Argue by contraposition. Suppose some neighbour $j^\*$ has $A_{i_0 j^\*} \ne 0$ yet
$|v_{j^\*}| \ne M$; then $|v_{j^\*}| < M$ strictly, so $g(j^\*) > 0$, while
$g(j) \ge 0$ for all $j$. Hence the termwise comparison is *strict*:
$$\sum_j |A_{i_0 j}|\,|v_j| \;<\; \sum_j |A_{i_0 j}|\, M
\;=\; \Big(\sum_j |A_{i_0 j}|\Big) M \;\le\; \Delta\, M,$$
where the last step uses $\sum_j |A_{i_0 j}| \le \Delta$ and $M > 0$. Combining
with S1 gives $|\mu|\, M < \Delta\, M$, i.e. $|\mu| < \Delta$, contradicting
$|\mu| = \Delta$. Therefore no such $j^\*$ exists, and every neighbour attains the
peak. $\qquad\blacksquare$

Theorems 2 and 3 are *local*: they constrain the immediate neighbourhood of a peak
vertex. Their importance is that they are the inductive engine for *global*
conclusions. Since each neighbour $j$ of $i_0$ now also satisfies $|v_j| = M$, it
is itself a peak vertex, and Theorems 2–3 apply at $j$ in turn. Iterating along a
path shows: **in a connected signed graph, equality $|\mu| = \Delta$ forces every
vertex to have degree $\Delta$ and $|v|$ to be constant** — i.e. the graph is
$\Delta$-regular. We state this as Conjecture C1 in §7 and leave its formalisation
(a walk-induction argument) to future work.

---

## 5. Sharpness: the complete graph realises equality

A bound and its equality analysis are vacuous without a witness that equality is
attainable. The all-positive complete graph provides one in every dimension.

> **Theorem 4 (Sharpness; `completePositive_realizes_equality`).** For
> $K_n^+ = $ `completePositive n` and the all-ones vector $\mathbf{1} =
> (1,\dots,1)$,
> $$K_n^+\, \mathbf{1} = (n-1)\,\mathbf{1}, \qquad
> \text{and}\qquad \forall i,\ \sum_j \big|(K_n^+)_{ij}\big| = n-1.$$
> Consequently $\Delta = n-1$ and the eigenvalue $\mu = n-1$ saturates the Δ-bound:
> $|\mu| = \Delta = n-1$.

**Proof sketch.** For each row $i$, $(K_n^+ \mathbf{1})_i = \sum_j (K_n^+)_{ij}
= \sum_{j \ne i} 1 = n-1$, since exactly one entry (the diagonal) is $0$ and the
other $n-1$ entries are $1$. Thus $K_n^+\mathbf{1} = (n-1)\mathbf{1}$. The same
count gives $\sum_j |(K_n^+)_{ij}| = n-1$ for every $i$, so every degree — and
hence $\Delta$ — equals $n-1$. Applying Theorem 1 with $\Delta = n-1$, the
eigenvalue $\mu = n-1$ meets the bound with equality. $\qquad\blacksquare$

The witness is internally consistent with §4. Degree saturation (Theorem 2) is
trivially satisfied because *every* vertex has degree $n-1$. Magnitude propagation
(Theorem 3) is also visible: the eigenvector $\mathbf{1}$ is flat, so all
magnitudes are equal — the "peak plateau" covers the whole graph, as the
propagation principle predicts for a connected equality case. The triangle
$K_3^+$ is the smallest instance: $\Delta = 2$, $\mu = 2$.

---

## 6. Algorithms

The results translate into elementary, exact numerical procedures.

### 6.1 Peak-vertex degree-bound certificate

Given a signed adjacency matrix $A$ and a candidate eigenpair $(\mu, v)$, one can
*certify* the Δ-bound and locate the structures from Theorems 2–3:

1. Compute degrees $d(i) = \sum_j |A_{ij}|$ and $\Delta = \max_i d(i)$.
2. Locate the peak set $P = \{ i : |v_i| = \max_j |v_j| \}$.
3. Report $|\mu| \le \Delta$ (Theorem 1).
4. If $|\mu| = \Delta$: for each $i_0 \in P$, verify $d(i_0) = \Delta$ (Theorem 2)
   and that every neighbour $j$ (with $A_{i_0 j} \ne 0$) lies in $P$ (Theorem 3).

This runs in $O(n^2)$ time (dominated by the row sums) and yields an exact,
auditable certificate of the equality structure.

### 6.2 Regularity propagation (connected case)

The inductive content of §4 is an explicit graph traversal: starting from any peak
vertex, breadth-first search across nonzero entries marks every reached vertex as a
peak (Theorem 3) and confirms its degree is $\Delta$ (Theorem 2). On a connected
graph at equality, the traversal visits all $n$ vertices, certifying
$\Delta$-regularity. This is the algorithmic form of Conjecture C1.

---

## 7. Discussion and future work

The proofs above are deliberately minimal: every step is an absolute-value
estimate at a single dominant coordinate, and equality is read off by demanding
that no estimate waste ground. This minimalism is what makes the equality analysis
so clean — and it also explains why the *signs* are invisible to the inequality
itself. The bound and its equality cases are determined entirely by $|A_{ij}|$,
the unsigned skeleton. Signs re-enter only when one asks *which* signed graph meets
a *signed* extreme ($\mu = +\Delta$ vs. $\mu = -\Delta$), a question governed by
balance.

Building on this foundation, we record four directions, each phrased to become a
formal target in a later cycle.

**C1 (Global regularity from equality).** For a *connected* signed graph with
eigenpair $(\mu, v)$ and $|\mu| = \Delta$, the graph is $\Delta$-regular and $|v|$
is constant. The path-induction sketched in §4 should formalise via a
walk-existence argument.

**C2 (Balance characterisation at the extremes).** For a connected $\Delta$-regular
signed graph, $\lambda_{\max} = \Delta$ iff the graph is *balanced* (switching-
equivalent to all-positive), and $\lambda_{\min} = -\Delta$ iff *antibalanced*.
Switching is conjugation by a $\pm 1$ diagonal $S$, an orthogonal similarity
preserving the spectrum; $K_n^+$ and $K_n^-$ realise the two extremes.

**C3 (Hong-type edge-count bound).** For a signed graph with $m$ edges on $n$
vertices, $\rho(A) \le \sqrt{2m - n + 1}$, with equality iff $A$ is (the switching
class of) a star $K_{1,n-1}$ or a complete graph $K_n$. The absolute-value
reduction used throughout suggests the unsigned proof transfers, with balance
fixing the equality side. This is the bound named in the original concept framing;
it is *not* proved here and is recorded as a conjecture.

**C4 (Two-degree refinement).** With $d_1 \ge d_2$ the two largest degrees,
Rayleigh refinements using the top two rows give bounds strictly improving
$\rho \le \Delta$ unless the graph is regular, in the flavour of Lan et al.

---

## 8. Conclusion

We have given a self-contained, machine-checked account of the maximum-degree
spectral bound for signed adjacency matrices and, more importantly, of its
equality structure: at equality the eigenvector's peak vertex is degree-saturated
and its peak magnitude propagates to all neighbours, while the all-positive
complete graph $K_n^+$ shows the bound is sharp in every dimension. The local
equality theorems are exactly the ingredients needed to drive global regularity
and balance characterisations, charting a concrete path from a one-line
inequality to a complete structural classification.

---

## References

The development is self-contained. Readers interested in the surrounding
literature on equality cases for spectral bounds of (signed) graphs may consult
the works of Sun and Das (2020) and Lan and collaborators (2023) on degree-based
spectral radius bounds and their extremal graphs, and standard texts on spectral
graph theory and the theory of balance in signed graphs.
