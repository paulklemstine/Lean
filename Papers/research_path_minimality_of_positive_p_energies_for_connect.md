# Path-Minimality of Positive $p$-Energies for Connected Bipartite Graphs

## Abstract

For a finite simple graph $G$ we study the *positive $p$-energy*
$E_p^{+}(G) = \sum_{\lambda > 0} \lambda^{p}$, the sum of the positive adjacency
eigenvalues each raised to a real exponent $p$, together with its mirror quantity
the negative $p$-energy $E_p^{-}(G) = \sum_{\lambda < 0} (-\lambda)^{p}$. Our central
structural result isolates the algebraic mechanism behind an identity long observed
for special families: whenever a real spectrum is antisymmetric under index
reflection — $\lambda_{n-1-k} = -\lambda_k$ — its positive and negative $p$-energies
coincide for *every* real $p$. This reflection antisymmetry is precisely the spectral
signature of bipartiteness, so we obtain the **Bipartite Balance Theorem**:
$E_p^{+}(G) = E_p^{-}(G)$ for all bipartite $G$ and all $p$. Specializing to the path
graph $P_n$, whose spectrum is the classical closed form
$\lambda_k = 2\cos((k+1)\pi/(n+1))$, we prove the exact evaluation
$E_2^{+}(P_n) = n-1$ via a roots-of-unity cosine sum, and we prove the combinatorial
core of path-minimality at $p=2$: every connected graph on $n$ vertices has at least
$n-1$ edges, with equality for trees. Since $E_2^{+}(G) = |E(G)|$ for bipartite $G$,
this yields $E_2^{+}(G) \ge E_2^{+}(P_n)$ for connected bipartite $G$, with the path
attaining the minimum. We close by formulating the full $p \ge 2$ minimality
conjecture as a spectral majorization problem.

**Keywords.** graph energy, positive $p$-energy, adjacency spectrum, bipartite
graph, path graph, spectral majorization, reflection involution, spanning tree.

---

## 1. Introduction

The **energy** of a graph, introduced in mathematical chemistry, is the sum of the
absolute values of its adjacency eigenvalues. It approximates the total $\pi$-electron
energy of conjugated hydrocarbons and has grown into a rich area of spectral graph
theory. A natural generalization replaces absolute value by a power law: for a real
exponent $p$, split the spectrum into its positive and negative parts and sum the
$p$-th powers separately. The *positive $p$-energy* $E_p^{+}$ isolates the
contribution of the positive eigenvalues, which for many extremal questions carry the
essential information.

This paper answers, at the exponent $p=2$, a concrete extremal question — *which
connected graph minimizes $E_p^{+}$?* — and identifies the reusable structural
principle that governs the whole family. The answer to the extremal question is the
**path graph** $P_n$, the unique tree that is a single simple chain. The structural
principle is that the balance $E_p^{+} = E_p^{-}$ is not a property of any particular
graph but of any *reflection-antisymmetric* real spectrum, of which bipartite spectra
are the archetype.

### Contributions

1. **Abstract bipartite balance (Theorem 1).** For any finite real spectrum
   $f(0), \ldots, f(n-1)$ with $f(n-1-k) = -f(k)$, and any real $p$, the positive and
   negative $p$-energies are equal. The proof is a reindexing plus a termwise sign
   case-split, entirely free of trigonometry.
2. **Path balance (Corollary 2).** The path graph satisfies $E_p^{+}(P_n) =
   E_p^{-}(P_n)$ for all $p$, recovered from Theorem 1 via the reflection identity of
   the path spectrum.
3. **Exact path evaluation (Theorem 4).** $E_2^{+}(P_n) = n-1$, obtained from a
   roots-of-unity evaluation of a Dirichlet cosine sum.
4. **Combinatorial minimality at $p=2$ (Theorem 5 and Corollary 6).** Every
   connected graph on $n$ vertices has at least $n-1$ edges; combined with
   $E_2^{+}(G) = |E(G)|$ for bipartite $G$, this gives $E_2^{+}(G) \ge E_2^{+}(P_n)$
   for connected bipartite $G$, with the path attaining equality.

---

## 2. Definitions

Throughout, $G$ is a finite simple graph on vertex set $\{1, \ldots, n\}$ with
adjacency matrix $A(G)$, the symmetric $0/1$ matrix whose $(i,j)$ entry is $1$ iff
$ij$ is an edge. Because $A(G)$ is real symmetric, its eigenvalues (the **adjacency
spectrum**) are real; we list them as $\lambda_0, \lambda_1, \ldots, \lambda_{n-1}$.

**Definition 2.1 (Positive and negative $p$-energy).** For a real exponent $p$,
$$E_p^{+}(G) = \sum_{k \,:\, \lambda_k > 0} \lambda_k^{\,p},
\qquad
E_p^{-}(G) = \sum_{k \,:\, \lambda_k < 0} (-\lambda_k)^{\,p}.$$
Equivalently, writing $x_+ = \max(x,0)$ and using the convention that terms with a
non-positive base contribute $0$,
$$E_p^{+}(G) = \sum_{k} \big[\lambda_k > 0\big]\,\lambda_k^{p},
\qquad
E_p^{-}(G) = \sum_{k} \big[\lambda_k < 0\big]\,(-\lambda_k)^{p}.$$

**Definition 2.2 (Path spectrum).** The adjacency spectrum of the path graph $P_n$ on
$n$ vertices is the classical closed form
$$\lambda_k \;=\; 2\cos\!\left(\frac{(k+1)\pi}{n+1}\right), \qquad k = 0, 1, \ldots, n-1.$$
Since the angles $(k+1)\pi/(n+1)$ lie strictly between $0$ and $\pi$, every $\lambda_k$
lies in the open interval $(-2, 2)$, and the eigenvalues are strictly decreasing in
$k$. Accordingly we write
$$E_p^{+}(P_n) = \sum_{k=0}^{n-1} \big[\lambda_k > 0\big]\,\lambda_k^p,
\qquad
E_p^{-}(P_n) = \sum_{k=0}^{n-1} \big[\lambda_k < 0\big]\,(-\lambda_k)^p.$$

**Definition 2.3 (Reflection antisymmetry).** A finite real sequence
$f(0), \ldots, f(n-1)$ is *antisymmetric under index reflection* if
$$f(n-1-k) = -f(k) \qquad \text{for all } 0 \le k < n.$$
Reflection $k \mapsto n-1-k$ is an order-reversing involution on $\{0, \ldots, n-1\}$;
antisymmetry says it realizes the sign involution $\lambda \mapsto -\lambda$ on the
values.

**Remark.** A graph is bipartite iff its spectrum is symmetric about $0$ (each
eigenvalue $\lambda$ is matched by $-\lambda$ with equal multiplicity). Ordering the
spectrum monotonically, this symmetry becomes exactly the reflection antisymmetry of
Definition 2.3. Thus "bipartite" and "reflection-antisymmetric spectrum" are two views
of the same phenomenon, and this is the bridge between our abstract theorem and its
graph-theoretic corollaries.

---

## 3. Abstract Bipartite Balance

**Theorem 1 (Abstract bipartite balance).** Let $n \in \mathbb{N}$, let $p$ be any
real number, and let $f : \{0, \ldots, n-1\} \to \mathbb{R}$ satisfy
$f(n-1-k) = -f(k)$ for all $0 \le k < n$. Then
$$\sum_{k=0}^{n-1} \big[f(k) > 0\big]\,f(k)^p
\;=\;
\sum_{k=0}^{n-1} \big[f(k) < 0\big]\,(-f(k))^p.$$

*Proof.* Apply the reflection reindexing $k \mapsto n-1-k$ to the left-hand sum; this
is a bijection of the summation range, so the value is unchanged:
$$\sum_{k=0}^{n-1} \big[f(k) > 0\big]\,f(k)^p
= \sum_{k=0}^{n-1} \big[f(n-1-k) > 0\big]\,f(n-1-k)^p.$$
By hypothesis $f(n-1-k) = -f(k)$, so the reindexed term is
$$\big[-f(k) > 0\big]\,(-f(k))^p = \big[f(k) < 0\big]\,(-f(k))^p,$$
which is exactly the $k$-th term of the right-hand sum. A termwise case-split on the
sign of $f(k)$ (positive, negative, or zero — the zero case contributing $0$ on both
sides) confirms the equality term by term. Summing gives the claim. $\qquad\blacksquare$

The proof uses no property of the values beyond the antisymmetry relation; in
particular it holds for every real $p$ simultaneously, including non-integer and
negative exponents (with the standard convention $0^p = 0$ for the vanishing base
contributions). This is the reusable structural core of the paper.

**Corollary 2 (Path balance).** For every $n$ and every real $p$,
$$E_p^{+}(P_n) = E_p^{-}(P_n).$$

*Proof.* The path spectrum satisfies the reflection identity
$$\lambda_{n-1-k}
= 2\cos\!\left(\frac{(n-k)\pi}{n+1}\right)
= 2\cos\!\left(\pi - \frac{(k+1)\pi}{n+1}\right)
= -2\cos\!\left(\frac{(k+1)\pi}{n+1}\right)
= -\lambda_k,$$
using $\cos(\pi - \theta) = -\cos\theta$. Thus $f(k) = \lambda_k$ satisfies the
hypothesis of Theorem 1, and the conclusion is precisely $E_p^{+}(P_n) =
E_p^{-}(P_n)$. $\qquad\blacksquare$

**Non-vacuity.** The antisymmetry hypothesis is essential. The triangle $K_3$ has
spectrum $\{2, -1, -1\}$, which is not reflection-antisymmetric; here $E_p^{+}(K_3) =
2^p$ while $E_p^{-}(K_3) = 2 \cdot 1^p = 2$, so $E_p^{+} \ne E_p^{-}$ for all
$p \ne 1$. Balance is genuinely a consequence of the spectral symmetry, not a formal
triviality.

---

## 4. Exact Evaluation at $p = 2$

**Lemma 3 (Trace identity).** For any simple graph $G$ on $n$ vertices,
$$\sum_{k=0}^{n-1} \lambda_k^2 = 2\,|E(G)|.$$

*Proof.* The left side is $\operatorname{tr}(A(G)^2)$, whose diagonal entries count
closed walks of length two from each vertex, i.e. the degree of the vertex. Hence
$\operatorname{tr}(A(G)^2) = \sum_v \deg(v) = 2|E(G)|$ by the handshake
lemma. $\qquad\blacksquare$

**Theorem 4 (Exact path evaluation).** For every $n \ge 1$,
$$E_2^{+}(P_n) = n - 1.$$

*Proof.* Using $\cos^2\theta = \tfrac12(1 + \cos 2\theta)$,
$$\sum_{k=0}^{n-1} \lambda_k^2
= \sum_{k=0}^{n-1} 4\cos^2\!\left(\frac{(k+1)\pi}{n+1}\right)
= 2n + 2\sum_{k=0}^{n-1} \cos\!\left(\frac{2(k+1)\pi}{n+1}\right).$$
Reindexing $j = k+1$ gives the Dirichlet cosine sum
$\sum_{j=1}^{n} \cos(2\pi j/(n+1))$. The full sum over a complete set of $(n+1)$-th
roots of unity vanishes,
$$\sum_{j=0}^{n} \cos\!\left(\frac{2\pi j}{n+1}\right)
= \operatorname{Re}\!\sum_{j=0}^{n} e^{2\pi i j/(n+1)} = 0,$$
so removing the $j=0$ term (equal to $1$) leaves
$\sum_{j=1}^{n} \cos(2\pi j/(n+1)) = -1$. Therefore
$$\sum_{k=0}^{n-1} \lambda_k^2 = 2n + 2(-1) = 2(n-1).$$
By Corollary 2 with $p = 2$, the positive and negative $2$-energies are equal, and
together they exhaust the sum of squares (no eigenvalue of $P_n$ is zero for the
relevant indices, and any zero eigenvalue contributes $0$ to both). Hence
$$E_2^{+}(P_n) = \tfrac12 \sum_{k=0}^{n-1} \lambda_k^2 = n-1.
\qquad\blacksquare$$

**Interpretation.** The path has $n-1$ edges, so Theorem 4 says the positive
$2$-energy of the path equals its number of edges. This is a special case of the
following general phenomenon.

**Proposition 4$'$ ($p=2$ energy is edge count for bipartite graphs).** For a
bipartite graph $G$, $E_2^{+}(G) = |E(G)|$.

*Proof.* Bipartiteness gives $E_2^{+}(G) = E_2^{-}(G)$ (Theorem 1 via the ordered
spectrum). These two quantities partition the sum of squares of all eigenvalues, which
equals $2|E(G)|$ by Lemma 3. Hence each equals $|E(G)|$. $\qquad\blacksquare$

---

## 5. Combinatorial Minimality at $p = 2$

**Theorem 5 (Connectivity edge bound).** Every connected simple graph $G$ on $n$
vertices satisfies $|E(G)| \ge n-1$.

*Proof.* A connected graph contains a spanning tree $T$ — a connected, acyclic
subgraph on all $n$ vertices. A tree on $n$ vertices has exactly $n-1$ edges (by
induction: removing a leaf reduces both the vertex count and edge count by one, down
to the single-vertex base case with $0$ edges). Since $T \subseteq G$,
$|E(G)| \ge |E(T)| = n-1$. $\qquad\blacksquare$

**Corollary 6 (Path-minimality at $p=2$).** For every connected bipartite graph $G$
on $n$ vertices,
$$E_2^{+}(G) \ge E_2^{+}(P_n) = n-1,$$
and the path $P_n$ attains equality.

*Proof.* By Proposition 4$'$, $E_2^{+}(G) = |E(G)|$; by Theorem 5,
$|E(G)| \ge n-1$; by Theorem 4, $n-1 = E_2^{+}(P_n)$. The path is a tree, so
$|E(P_n)| = n-1$, giving equality. $\qquad\blacksquare$

Thus, at the exponent $p = 2$, path-minimality of positive energy is *exactly* the
elementary fact that a connected graph needs at least $n-1$ edges. The spectral
question collapses onto a counting question, and the path wins because it is the
sparsest connected graph.

---

## 6. Algorithms

We record the computational procedures underlying the numerical evidence.

**Algorithm A (Positive $p$-energy of a graph).** Given the adjacency matrix, compute
the eigenvalues, retain the positive ones, raise each to the power $p$, and sum. Cost
is dominated by the symmetric eigensolver, $O(n^3)$.

**Algorithm B (Closed-form path energy).** Generate the path eigenvalues directly from
$\lambda_k = 2\cos((k+1)\pi/(n+1))$ without forming a matrix; sum the positive $p$-th
powers. Cost $O(n)$. This confirms Theorem 4 and Corollary 2 numerically.

**Algorithm C (Bipartite balance checker).** Given any real spectrum, sort it, verify
the reflection identity $\lambda_{n-1-k} = -\lambda_k$ to a tolerance, and compare
$E_p^{+}$ against $E_p^{-}$. On bipartite spectra the two agree to machine precision;
on $K_3$ they diverge, witnessing non-vacuity.

---

## 7. Applications and Context

Positive $p$-energies interpolate between combinatorial and spectral invariants. At
$p=2$ they reduce to edge counts (for bipartite graphs) and hence to the most basic
connectivity statistics; for larger $p$ they weight the dominant eigenvalues, making
them sensitive to spectral radius and to how spread out the spectrum is. Extremal
questions for such functionals connect to:

- **Mathematical chemistry**, where energy-type invariants track molecular stability
  and where bipartite molecular graphs (alternant hydrocarbons) enjoy exactly the
  pairing symmetry of Theorem 1.
- **Network science**, where sparse connected structures (trees, paths) are baseline
  models and extremal energy identifies the "least reactive" topology.
- **Spectral majorization**, where comparing whole spectra under convex functionals is
  the natural framework for the open $p \ge 2$ conjecture below.

The Bipartite Balance Theorem also has a clean self-contained life outside graph
theory: it is a statement about any real data vector symmetric under an order-reversing
sign involution, asserting that its positive and negative power-sums are equal.

---

## 8. Discussion and Future Work

The exponent $p=2$ is fully resolved: positive energy is edge count for bipartite
graphs, and path-minimality is the spanning-tree bound. The structural balance
$E_p^{+} = E_p^{-}$ holds for all real $p$ and is the reusable heart of the theory.
What remains is to upgrade the $p=2$ comparison to all $p \ge 2$.

**Future Direction 1 — Full path-minimality for $p \ge 2$.** *Conjecture:* for every
connected bipartite graph $G$ on $n$ vertices and every real $p \ge 2$,
$E_p^{+}(G) \ge E_p^{+}(P_n)$, with equality iff $G$ is the path. The path has the
most "spread-out yet smallest" spectrum among connected graphs: minimal spectral
radius, and remaining positive eigenvalues filling $(0,2)$ as slowly as connectivity
permits. Convexity of $x \mapsto x^p$ for $p \ge 2$ should convert this spectral
spreading into an energy inequality via majorization of the positive part of the
spectrum. The exact $p=2$ identity and the reflection description of bipartite spectra
pinpoint precisely which spectral comparison must be lifted from $p=2$ to $p \ge 2$.

**Future Direction 2 — Uniqueness and the runner-up.** *Conjecture:* the path is the
unique minimizer for every $p > 2$, and the second-smallest value is attained by a
"broom" (path with a relocated pendant edge). Equality at $p=2$ forces the edge count
$n-1$, characterizing trees; strict convexity for $p>2$ breaks all ties except the
path. Identifying the runner-up asks how a single local tree modification perturbs the
whole positive spectrum — a stability/spectral-gap refinement of bare extremality.

**Future Direction 3 — A $p$-energy isoperimetric sandwich.** *Conjecture:* for
bipartite graphs with fixed part sizes $a, b$, positive $p$-energy is minimized by the
balanced caterpillar ("double path") and maximized by the complete bipartite graph
$K_{a,b}$, for all $p \ge 2$. Positive $p$-energy behaves like a convex isoperimetric
functional: adding edges pushes spectral mass toward the extreme eigenvalue
$\sqrt{ab}$ of $K_{a,b}$, while sparsifying spreads it toward zero. The exact path
evaluation gives one calibrated endpoint and the single dominant eigenvalue of
$K_{a,b}$ the other, making the intermediate ordering a well-posed target.

---

## 9. Conclusion

We have shown that the balance of positive and negative $p$-energies is a universal
consequence of reflection antisymmetry of a spectrum — the spectral fingerprint of
bipartiteness — and used it, at $p=2$, to prove that the path graph minimizes positive
energy among connected bipartite graphs, with the exact value $E_2^{+}(P_n) = n-1$.
The concrete path result is one instance of a general involution principle; the
remaining challenge, to extend minimality to all $p \ge 2$, is now sharply posed as a
spectral majorization problem.
