# A Sharp Spectral Analysis of Seidel Energy Increase in Complete Bipartite Graphs Under Two Independent Edge Deletions

## Abstract

The **Seidel energy** of a graph is the sum of the absolute values of the
eigenvalues of its Seidel matrix $S = J - I - 2A$. For the complete bipartite
graph $K_{m,n}$ the Seidel matrix is the rank-one object $S = w\,w^{\mathsf T} -
I$, where $w$ is the $\pm 1$ vector that labels the two parts, and its Seidel
energy equals $2(m+n-1)$. It has been known that deleting a *single* cross edge
increases the Seidel energy exactly when $m+n \ge 4$, and a family of *threshold
conditions* — pairs $(m,n)$ such as $(3,6)$, $(6,3)$, $(2,15)$, $(15,2)$ and
$(4,4)$ — had been proposed under which the increase is guaranteed. We deepen and
sharpen this analysis by treating the deletion of **two independent
(vertex-disjoint) cross edges**. Although this is a genuine rank-five
perturbation of $-I$, the entire spectral computation closes in closed form. We
prove that the characteristic polynomial of the two-edge-deleted Seidel matrix
factors as
$$(X+1)^{\,m+n-5}\,(X-1)^2\,(X+3)\,\big(X^2 - (m{+}n{-}4)X - (3(m{+}n){-}11)\big),$$
that the resulting Seidel energy equals $(m+n) + \sqrt{(m+n+2)^2 - 32}$, and,
as our main theorem, that this **strictly exceeds** the base energy $2(m+n-1)$
for *every* admissible pair $(m,n)$ with $m,n \ge 2$ and $m+n \ge 5$. In sharp
contrast with the single-edge case, whose threshold is $m+n \ge 4$, the
two-independent-edge deletion has **no threshold obstruction whatsoever**: the
previously conjectured thresholds are not sharp. The smallest witness is
$K_{2,3}$, whose Seidel energy jumps from $8$ to $5 + \sqrt{17}$. The argument is
a cross-disciplinary bridge combining the combinatorics of complete bipartite
graphs, the linear algebra of low-rank perturbations, and elementary real
analysis of the square-root function.

**Keywords:** Seidel matrix, Seidel energy, complete bipartite graph, edge
deletion, low-rank perturbation, matrix determinant lemma, characteristic
polynomial, graph spectra.

---

## 1. Introduction

### 1.1 Graph energy and the Seidel matrix

Spectral graph theory studies a graph through the eigenvalues of matrices
associated to it. The most classical invariant is the **graph energy**, the sum
of the absolute values of the eigenvalues of the adjacency matrix, introduced as
a graph-theoretic abstraction of the total $\pi$-electron energy of a conjugated
hydrocarbon. Replacing the adjacency matrix by other structured matrices produces
a whole family of energies; the one we study here is built from the **Seidel
matrix**.

**Definition 1 (Seidel matrix).** For a simple graph $G$ on vertex set $V$ with
adjacency matrix $A$, the Seidel matrix is
$$S = J - I - 2A,$$
where $J$ is the all-ones matrix and $I$ is the identity. Equivalently,
$S_{uv} = -1$ if $u$ and $v$ are adjacent, $S_{uv} = +1$ if $u \ne v$ are
non-adjacent, and $S_{uu} = 0$.

The Seidel matrix is real symmetric, hence has real eigenvalues.

**Definition 2 (Seidel energy).** The Seidel energy of $G$ is
$$E_S(G) = \sum_{i} |\lambda_i|,$$
the sum of the absolute values of the eigenvalues $\lambda_i$ of $S$.

The Seidel matrix arises naturally in the theory of two-graphs, equiangular
lines, and regular two-graphs, and its "presence/absence democratic" $\pm 1$
encoding makes it insensitive to the same switching operations under which
two-graphs are defined. Seidel energy is a comparatively young invariant, and the
behavior of $E_S$ under local graph operations — especially edge deletion — is an
active line of inquiry.

### 1.2 The complete bipartite case

The complete bipartite graph $K_{m,n}$ has vertex set partitioned into a left
part $L$ of size $m$ and a right part $R$ of size $n$, with an edge between every
$u \in L$ and $v \in R$ and no edges inside either part. We index its vertices by
the disjoint union $\{1,\dots,m\} \sqcup \{1,\dots,n\}$.

The key structural observation is a rank-one representation of the Seidel matrix.

**Definition 3 (part-labeling vector).** Let $w \in \mathbb{R}^{V}$ be the vector
with $w_u = +1$ for $u \in L$ and $w_v = -1$ for $v \in R$.

**Proposition 4 (rank-one form).** The Seidel matrix of $K_{m,n}$ is
$$S = w\,w^{\mathsf T} - I.$$

*Proof sketch.* The outer product $w\,w^{\mathsf T}$ has entry $w_u w_v$. For $u,v$
in the same part this is $+1$; for $u,v$ in opposite parts it is $-1$; and on the
diagonal it is $w_u^2 = 1$. Subtracting $I$ zeroes the diagonal, keeps $+1$ on
same-part off-diagonal entries (the non-edges of $K_{m,n}$), and keeps $-1$ on
opposite-part entries (the edges). This is exactly $J - I - 2A$ for $K_{m,n}$.
$\square$

From this we obtain the baseline energy.

**Theorem 5 (base energy).** For $m + n \ge 1$,
$$E_S(K_{m,n}) = 2\,(m+n-1).$$

*Proof sketch.* The characteristic polynomial of $w\,w^{\mathsf T} - I$ is
obtained from that of the rank-one $w\,w^{\mathsf T}$, whose only nonzero
eigenvalue is $\|w\|^2 = w^{\mathsf T} w = m+n$ (with all-ones eigenvector along
$w$), the rest being $0$ with multiplicity $m+n-1$. Subtracting $I$ shifts every
eigenvalue down by $1$, giving one eigenvalue $m+n-1$ and $m+n-1$ copies of $-1$.
Concretely the characteristic polynomial factors as
$$\chi_S(X) = (X+1)^{m+n-1}\,\big(X - (m+n-1)\big).$$
Summing absolute values, $|m+n-1| + (m+n-1)\cdot|-1| = (m+n-1) + (m+n-1) =
2(m+n-1)$. $\square$

### 1.3 Prior single-edge results and the threshold question

Deleting a single cross edge $\{u,v\}$ of $K_{m,n}$ flips the corresponding
$\pm 1$ entries and is a rank-three perturbation of $S$. The resulting Seidel
energy strictly exceeds $2(m+n-1)$ precisely when $m+n \ge 4$. In the course of
establishing such results, a list of **threshold conditions** was recorded —
pairs $(m,n)$ under which the strict increase was proven, including $(3,6)$,
$(6,3)$, $(2,15)$, $(15,2)$, and $(4,4)$. It was conjectured that these thresholds
are *not sharp*: that the guaranteed-increase region is in fact much larger, and
that the recorded thresholds merely reflect the limits of the technique used to
derive them.

This paper resolves the sharpness question for the natural next case — deletion of
**two independent edges** — and finds that the answer is even cleaner than
expected: in the two-edge regime the threshold disappears entirely.

### 1.4 Contributions

1. A closed-form characteristic polynomial for $K_{m,n}$ with two independent
   cross edges deleted (Theorem 11).
2. A closed-form Seidel energy $(m+n)+\sqrt{(m+n+2)^2-32}$ for that graph
   (Theorem 13).
3. A proof that the Seidel energy *strictly increases* for **all** $m,n\ge 2$ with
   $m+n\ge 5$, showing there is no threshold obstruction (Theorem 14).
4. An explicit smallest witness, $K_{2,3}$, with energy jump $8 \to 5+\sqrt{17}$
   (Corollary 15).
5. A conjectural generalization to matchings of arbitrary size $k$
   (Section 6).

---

## 2. The two-edge-deleted Seidel matrix

Fix $m,n \ge 2$. Choose two independent cross edges to delete: $\{a_0, b_0\}$ and
$\{a_1, b_1\}$ with $a_0, a_1 \in L$, $b_0, b_1 \in R$, and $a_0 \ne a_1$,
$b_0 \ne b_1$. Deleting an edge $\{a,b\}$ from $K_{m,n}$ changes the two Seidel
entries $S_{ab}, S_{ba}$ from $-1$ to $+1$, i.e. adds $2$ to each.

**Definition 6 (two-edge-deleted Seidel matrix).** With $E_{ab}$ denoting the
matrix unit with a single $1$ in position $(a,b)$,
$$S' = S + 2\big(E_{a_0 b_0} + E_{b_0 a_0}\big) + 2\big(E_{a_1 b_1} + E_{b_1 a_1}\big).$$
This is the Seidel matrix of $K_{m,n}$ with the two independent edges removed, and
it is symmetric.

The perturbation touches five directions: the original rank-one $w$ and the four
unit vectors at the endpoints $a_0, b_0, a_1, b_1$. We package these.

**Definition 7 (extended factor matrix).** Let $U$ be the $V \times 5$ matrix
whose columns are
$$\big[\; w \;\big|\; e_{a_0} \;\big|\; e_{b_0} \;\big|\; e_{a_1} \;\big|\; e_{b_1}\;\big],$$
where $e_x$ is the standard unit vector at vertex $x$.

**Definition 8 (core coefficient matrix).** Let
$$K = \begin{pmatrix} 1 & 0 & 0 & 0 & 0 \\ 0 & 0 & 2 & 0 & 0 \\ 0 & 2 & 0 & 0 & 0 \\ 0 & 0 & 0 & 0 & 2 \\ 0 & 0 & 0 & 2 & 0 \end{pmatrix}
= [1] \oplus \begin{pmatrix} 0 & 2 \\ 2 & 0\end{pmatrix} \oplus \begin{pmatrix} 0 & 2 \\ 2 & 0\end{pmatrix}.$$

The block $[1]$ accounts for the rank-one $w w^{\mathsf T}$; each off-diagonal
$\begin{smallmatrix}0&2\\2&0\end{smallmatrix}$ block accounts for one symmetric
edge-flip $2(E_{ab}+E_{ba})$.

**Lemma 9 (rank-five decomposition).** For independent deletions
($a_0 \ne a_1$, $b_0 \ne b_1$),
$$S' + I = U\,K\,U^{\mathsf T}.$$

*Proof sketch.* Expanding $U K U^{\mathsf T}$ entrywise: the $[1]$ block yields
$w w^{\mathsf T}$; each $\begin{smallmatrix}0&2\\2&0\end{smallmatrix}$ block
yields $2(e_a e_b^{\mathsf T} + e_b e_a^{\mathsf T}) = 2(E_{ab}+E_{ba})$. Summing
gives $w w^{\mathsf T} + 2(E_{a_0 b_0}+E_{b_0 a_0}) + 2(E_{a_1 b_1}+E_{b_1 a_1})
= (S + I) + [\text{edge flips}] = S' + I$. A finite case check on vertex pairs
confirms the entries agree; independence guarantees the four unit vectors are
distinct, so no cross terms collapse. $\square$

**Lemma 10 (Gram matrix of the columns).** For independent deletions,
$$U^{\mathsf T} U = \begin{pmatrix}
m+n & 1 & -1 & 1 & -1 \\
1 & 1 & 0 & 0 & 0 \\
-1 & 0 & 1 & 0 & 0 \\
1 & 0 & 0 & 1 & 0 \\
-1 & 0 & 0 & 0 & 1
\end{pmatrix}.$$

*Proof sketch.* The $(1,1)$ entry is $w^{\mathsf T} w = m+n$. Entry $(1,j)$ for
$j\ge 2$ is $w_x$ at the corresponding endpoint: $+1$ for the left endpoints
$a_0, a_1$, and $-1$ for the right endpoints $b_0, b_1$. The lower-right $4\times
4$ block is $I_4$ because the four endpoints are distinct (this is exactly where
independence is used). $\square$

---

## 3. The characteristic polynomial

The engine is the **matrix determinant lemma** in its characteristic-polynomial
form: for a $V \times k$ matrix $U$ and $k \times V$ matrix $M$ with $k \le |V|$,
$$\det(X I_{V} - U M) = X^{\,|V|-k}\,\det(X I_k - M U).$$
This reduces a large eigenproblem for $U(KU^{\mathsf T})$ to a $5\times 5$ core
$K\,(U^{\mathsf T} U)$.

**Definition 11 (core spectral matrix).** With $N = m+n$, define
$$P = K\,(U^{\mathsf T} U) = \begin{pmatrix}
N & 1 & -1 & 1 & -1 \\
-2 & 0 & 2 & 0 & 0 \\
2 & 2 & 0 & 0 & 0 \\
-2 & 0 & 0 & 0 & 2 \\
2 & 0 & 0 & 2 & 0
\end{pmatrix}.$$

**Theorem 11 (characteristic polynomial of the core).**
$$\chi_P(X) = (X-2)^2\,(X+2)\,\big(X^2 - (N-2)X - (2N-8)\big).$$

*Proof sketch.* Form the characteristic matrix $XI_5 - P$ and expand its
determinant along the first row. Each $4\times 4$ minor is evaluated by explicit
Laplace expansion. Collecting terms and simplifying (a routine polynomial
identity) yields the stated factorization. The three "structural" roots $2, 2,
-2$ come from the two rank-two edge blocks; the quadratic factor carries the
interaction with the rank-one direction. $\square$

We now assemble the full spectrum. Because $S' + I = U K U^{\mathsf T}$, the
matrix determinant lemma gives
$$\chi_{S'+I}(X) = X^{\,N-5}\,\chi_{P}(X),$$
and since $S' = (S'+I) - I$, we substitute $X \mapsto X+1$ (a shift by $-1$ in
each eigenvalue) to recover $\chi_{S'}$.

**Theorem 12 (characteristic polynomial of the deleted graph).** For $m,n\ge 2$
and $N = m+n \ge 5$,
$$\chi_{S'}(X) = (X+1)^{\,N-5}\,(X-1)^2\,(X+3)\,\big(X^2 - (N-4)X - (3N-11)\big).$$

*Proof sketch.* Apply the shift $X \mapsto X+1$ to $X^{N-5}\chi_P(X)$. The factor
$X^{N-5}$ becomes $(X+1)^{N-5}$; $(X-2)^2$ becomes $(X-1)^2$; $(X+2)$ becomes
$(X+3)$; and $X^2-(N-2)X-(2N-8)$ becomes $X^2-(N-4)X-(3N-11)$, verified by direct
substitution and expansion. $\square$

**Corollary (Seidel spectrum).** The Seidel eigenvalues of $K_{m,n}$ with two
independent edges deleted are
$$\underbrace{-1,\dots,-1}_{N-5},\quad 1,\ 1,\quad -3,\quad
\frac{(N-4)\pm\sqrt{(N+2)^2-32}}{2}.$$
The discriminant of the quadratic is $(N-4)^2 + 4(3N-11) = N^2 + 4N - 28 =
(N+2)^2 - 32$.

---

## 4. The energy formula

**Theorem 13 (Seidel energy after two deletions).** For $m,n \ge 2$ and
$N = m+n \ge 5$, the Seidel energy of $K_{m,n}$ with two independent edges deleted
is
$$E_2 = N + \sqrt{(N+2)^2 - 32} = (m+n) + \sqrt{(m+n+2)^2 - 32}.$$

*Proof sketch.* Sum the absolute values of the eigenvalues from the Corollary.
The frozen eigenvalues contribute $(N-5)\cdot 1 + 2\cdot 1 + 1\cdot 3 = N$. For
the two quadratic roots $r_\pm = \frac{(N-4)\pm\sqrt{D}}{2}$ with
$D = (N+2)^2 - 32$: their sum is $r_+ + r_- = N-4$ and their product is
$r_+ r_- = -(3N-11) = 11 - 3N$, which is negative for $N \ge 4$. Hence one root is
positive and the other negative, so
$$|r_+| + |r_-| = |r_+ - r_-| = \sqrt{(r_+ + r_-)^2 - 4 r_+ r_-}
= \sqrt{(N-4)^2 + 4(3N-11)} = \sqrt{D}.$$
Adding, $E_2 = N + \sqrt{(N+2)^2 - 32}$. The discriminant is nonnegative because
$(N+2)^2 - 32 \ge 49 - 32 = 17 > 0$ for $N \ge 5$. $\square$

---

## 5. No threshold obstruction

**Theorem 14 (main theorem — strict increase, no threshold).** For every $m,n
\ge 2$ with $m + n \ge 5$, deleting any two independent (vertex-disjoint) cross
edges of $K_{m,n}$ strictly increases the Seidel energy:
$$E_S(K_{m,n}) = 2(m+n-1) \;<\; (m+n) + \sqrt{(m+n+2)^2 - 32} = E_2.$$
Unlike the single-edge case, whose sharp threshold is $m+n \ge 4$, the two-edge
deletion has *no* threshold obstruction: whenever such a pair of edges exists (and
is not the degenerate perfect matching of $K_{2,2}$), the energy goes up.

*Proof sketch.* Write $N = m+n \ge 5$. The claim $2N-2 < N + \sqrt{(N+2)^2-32}$ is
equivalent to $\sqrt{(N+2)^2-32} > N-2$. Since $N \ge 5$, the right side is
positive, so we may square: the inequality becomes $(N+2)^2 - 32 > (N-2)^2$, i.e.
$8N - 32 > 0$, i.e. $N > 4$. This holds for all $N \ge 5$. Rigorously, write
$(N+2)^2 - 32 = (N-2)^2 + (8N-32)$; for $N \ge 5$ the added term $8N-32 \ge 8 > 0$
is strictly positive, so
$$N - 2 = \sqrt{(N-2)^2} < \sqrt{(N-2)^2 + (8N-32)} = \sqrt{(N+2)^2-32},$$
using strict monotonicity of the square root. Adding $N$ to both sides gives
$2N - 2 < N + \sqrt{(N+2)^2-32}$. $\square$

**Remark (why the threshold vanishes).** In the single-edge case the boundary
$N \ge 4$ is genuine: below it the perturbation is too small to overcome the
concentration of the base spectrum. Deleting two independent edges injects a
strictly larger discriminant term ($8N - 32$ versus the corresponding single-edge
quantity), and this surplus is exactly what erases the threshold. The earlier
conjectured thresholds $(3,6)$, $(2,15)$, $(4,4)$, etc. are therefore not sharp:
they are far inside the true guaranteed-increase region, which — for two
independent edges — is *everything*.

**Corollary 15 (smallest witness $K_{2,3}$).** The Seidel energy of $K_{2,3}$ is
$2(2+3-1) = 8$; after deleting two independent edges it is
$$E_2 = 5 + \sqrt{(5+2)^2 - 32} = 5 + \sqrt{17} \approx 9.1231.$$
Thus $8 < 5 + \sqrt{17}$, a strict increase in the very smallest admissible case.

---

## 6. Generalization and future work

### 6.1 Matching deletions of arbitrary size

The same change of basis — expand into the rank-one direction $w$ plus the unit
vectors at the deleted endpoints, then reduce via the matrix determinant lemma —
extends to a **matching of size $k$** (i.e., $k$ pairwise vertex-disjoint cross
edges). The predicted Seidel spectrum is
$$\{-1\}^{\,N-2k-1} \cup \{1\}^{k} \cup \{-3\}^{k-1} \cup
\left\{ \frac{(N-4)\pm\sqrt{(N+2)^2 - 16k}}{2} \right\}, \qquad N = m+n,$$
valid in the non-degenerate regime $N \ge 2k+1$, with energy
$$E_k = (N + 2k - 4) + \sqrt{(N+2)^2 - 16k}.$$
The predicted sharp threshold for a strict increase is $N \ge k + 3$; combined
with the existence constraint $N \ge 2k+1$, this means that for every $k \ge 2$
the energy *always* increases whenever the matching exists. The case $k = 1$
recovers the classical single-edge threshold $N \ge 4$, and $k = 2$ is the fully
worked result of this paper. Formalizing general $k$ requires a variable-size core
matrix and a $k$-indexed matching, but the structure is uniform.

### 6.2 Non-independent deletions

Deleting two edges that **share a vertex** (a path $P_3$ of deletions), or a star
$K_{1,t}$ of deletions at a single vertex, is only a rank-three perturbation, but
the reduced core is a *cubic* whose roots are not rational in $N$. The energy
remains algebraic but loses the clean single-square-root closed form. A careful
sign analysis of that cubic would settle the star case.

### 6.3 The degenerate perfect-matching case

When $N = 2k$ — for instance $K_{k,k}$ minus a perfect matching — the labeling
vector $w$ becomes linearly dependent on the deleted unit vectors, the core drops
rank, and both the spectrum and the energy change shape. This boundary case
(already visible at $K_{2,2}$, where the discriminant $(N+2)^2-32 = -16$ turns
imaginary) deserves separate treatment.

### 6.4 Beyond bipartite

The rank-one identity $S = w w^{\mathsf T} - I$ is special to complete bipartite
graphs. The natural higher-rank generalization is to complete **multipartite**
graphs $K_{n_1,\dots,n_r}$, whose Seidel matrices have rank $r$. Extending the
"energy increases under deletion" analysis to that setting is the principal open
direction.

---

## 7. Discussion

The result reframes a scattered list of threshold conditions as artifacts of a
single-edge technique. Once one deletes a *matching* rather than a lone edge, the
spectral perturbation is large and structured enough that the energy increase
becomes universal. Methodologically, the paper is a compact illustration of a
powerful pattern: a local combinatorial operation (deleting a few disjoint edges)
becomes a **low-rank perturbation** of a highly symmetric matrix, and the matrix
determinant lemma collapses the entire spectral question to a constant-size core
whose characteristic polynomial can be written down explicitly. The interplay of
three ingredients — the combinatorics of $K_{m,n}$, the linear algebra of low-rank
updates, and the elementary analysis of the discriminant $\sqrt{(N+2)^2-32}$ —
is what makes the answer both exact and sharp.

---

## Appendix: Summary of formulas

| Quantity | Value |
|---|---|
| Base Seidel energy of $K_{m,n}$ | $2(m+n-1)$ |
| Base characteristic polynomial | $(X+1)^{m+n-1}(X-(m+n-1))$ |
| Two-deletion characteristic polynomial | $(X{+}1)^{m+n-5}(X{-}1)^2(X{+}3)\big(X^2{-}(m{+}n{-}4)X{-}(3(m{+}n){-}11)\big)$ |
| Two-deletion spectrum | $\{-1\}^{N-5}\cup\{1,1\}\cup\{-3\}\cup\left\{\tfrac{(N-4)\pm\sqrt{(N+2)^2-32}}{2}\right\}$ |
| Two-deletion Seidel energy | $(m+n)+\sqrt{(m+n+2)^2-32}$ |
| Increase condition | all $m,n\ge 2$, $m+n\ge 5$ (no threshold) |
| Smallest witness $K_{2,3}$ | $8 \to 5+\sqrt{17}\approx 9.1231$ |
| Conjectured $k$-matching energy | $(N+2k-4)+\sqrt{(N+2)^2-16k}$, $N=m+n$ |
