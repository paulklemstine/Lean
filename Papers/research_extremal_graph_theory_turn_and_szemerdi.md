# Density Forces Structure: Extremal Bounds for Cliques, Shadows, and Arithmetic Progressions

## Abstract

We present a unified development of four cornerstone results in extremal combinatorics, each an instance of a single guiding principle: *sufficient density forces unavoidable structure*. First, we establish Turán's theorem in a clean closed integer form — every $K_{r+1}$-free graph on $n$ vertices satisfies $2r\,e(G) \le (r-1)n^2$ — and specialize it to Mantel's theorem $4e(G) \le n^2$ for triangle-free graphs, together with a sharp extremal witness showing the Mantel bound is attained exactly by balanced complete bipartite graphs. Second, we extract from the Kruskal–Katona theorem a directly applicable single-shadow lower bound: an $r$-uniform family with at least $\binom{k}{r}$ members has a shadow of size at least $\binom{k}{r-1}$; its $r=2$ specialization is the graph-theoretic statement that $\binom{k}{2}$ edges must touch at least $k$ vertices. Third, we present Roth's theorem on three-term arithmetic progressions in a *positive* existence form: a sufficiently dense subset of a finite abelian group contains a genuine non-degenerate progression $a, a+d, a+2d$ with $d \ne 0$, specialized to the cyclic groups $\mathbb{Z}/N\mathbb{Z}$. We discuss the regularity and removal-lemma machinery that links these graph- and number-theoretic phenomena, give algorithms and numerical demonstrations, and outline research directions including stability refinements, quantitative density thresholds, iterated-shadow rigidity, and spectral analogues.

**Keywords:** extremal graph theory, Turán's theorem, Mantel's theorem, Kruskal–Katona theorem, shadows of set families, Roth's theorem, three-term arithmetic progressions, regularity, triangle removal lemma.

---

## 1. Introduction

Extremal combinatorics studies how large a discrete structure can be while avoiding a forbidden configuration, and what the near-maximal structures must look like. A recurring meta-theorem governs the field: **once a structure surpasses a density threshold, the forbidden pattern becomes unavoidable, and the structures that come closest to avoiding it are rigid and highly symmetric.**

This paper assembles four classical pillars of the subject into a coherent, self-contained narrative around this meta-theorem:

1. **Turán's theorem** and its progenitor **Mantel's theorem** — edge density forces large cliques.
2. The **Kruskal–Katona theorem** — the size of a uniform set family forces the size of its shadow.
3. **Roth's theorem** — density of a subset of an abelian group forces three-term arithmetic progressions.

We state each result precisely, give a proof sketch, identify the extremal configurations, and emphasize the common thread. Sections 5–6 describe the deeper regularity philosophy that explains why graph-theoretic and number-theoretic extremal phenomena are two faces of one coin.

Throughout, $G$ denotes a finite simple graph with vertex set $V(G)$, $n = |V(G)|$, and edge set $E(G)$; we write $e(G) = |E(G)|$. For a positive integer $r$, $K_r$ is the complete graph (clique) on $r$ vertices. We say $G$ is **$K_{r}$-free** if it contains no subgraph isomorphic to $K_{r}$. We write $\binom{m}{j}$ for the binomial coefficient.

---

## 2. Turán's and Mantel's theorems

### 2.1 Definitions

A **clique** in $G$ of size $r$ is a set of $r$ pairwise-adjacent vertices. A graph is **$K_{r+1}$-free** if it has no clique of size $r+1$. The **Turán graph** $T(n,r)$ is the complete $r$-partite graph on $n$ vertices whose parts are as equal as possible (sizes $\lceil n/r\rceil$ or $\lfloor n/r\rfloor$): two vertices are adjacent if and only if they lie in distinct parts.

### 2.2 Main bound

> **Theorem 2.1 (Turán, closed integer form).** If $G$ is a $K_{r+1}$-free graph on $n$ vertices with $r \ge 1$, then
> $$2r \cdot e(G) \;\le\; (r-1)\, n^2.$$
> Equivalently, $e(G) \le \left(1 - \frac{1}{r}\right)\frac{n^2}{2}$.

**Proof sketch.** The sharp form of Turán's theorem identifies the Turán graph $T(n,r)$ as the unique maximizer of the edge count among $K_{r+1}$-free graphs on $n$ vertices; hence $e(G) \le e(T(n,r))$. Writing $n = qr + s$ with $0 \le s < r$, a direct count gives
$$e(T(n,r)) = \frac{n^2 - s^2}{2}\cdot\frac{r-1}{r} + \binom{s}{2},$$
and one checks the elementary inequality $e(T(n,r)) \le \frac{r-1}{2r}n^2$ by bounding the integer remainder terms (the correction $\binom{s}{2}$ minus the deficit from $s^2$ is non-positive). Multiplying through by $2r$ yields $2r\,e(G) \le (r-1)n^2$. $\;\square$

An equivalent and frequently more convenient route is the probabilistic/degree-sequence argument: in a $K_{r+1}$-free graph the neighborhoods contain no $K_r$, and an averaging (or Motzkin–Straus / Zykov symmetrization) argument shows that shifting weight toward a balanced complete $r$-partite configuration never decreases the edge count, again pinning the maximum at $T(n,r)$.

### 2.3 Mantel's theorem and its sharpness

> **Theorem 2.2 (Mantel).** A triangle-free graph $G$ on $n$ vertices satisfies $4\,e(G) \le n^2$.

**Proof sketch.** Apply Theorem 2.1 with $r = 2$: $K_3$-free means $K_{r+1}$-free for $r=2$, giving $4\,e(G) \le n^2$. $\;\square$

> **Theorem 2.3 (Sharpness of Mantel).** For every $k \in \mathbb{N}$, the balanced complete bipartite graph $K_{k,k}$ (equivalently the Turán graph $T(2k,2)$) on $n = 2k$ vertices is triangle-free and satisfies $4\,e = n^2$ with equality.

**Proof sketch.** $K_{k,k}$ is bipartite, hence contains no odd cycle and in particular no triangle. It has $e = k\cdot k = k^2$ edges, so $4e = 4k^2 = (2k)^2 = n^2$. $\;\square$

Theorems 2.2 and 2.3 together show the bound $n^2/4$ is exact and identifies the balanced bipartite graph as extremal — the prototype of the "density forces structure" phenomenon.

---

## 3. The Kruskal–Katona shadow bound

### 3.1 Definitions

Let $[n] = \{1,\dots,n\}$ (or any $n$-element ground set). A family $\mathcal A$ of subsets is **$r$-uniform** (or *$r$-sized*) if every member has exactly $r$ elements. The **shadow** of $\mathcal A$ is
$$\partial \mathcal A \;=\; \{\, B : |B| = r-1,\ B \subseteq A \text{ for some } A \in \mathcal A \,\},$$
the family of all $(r-1)$-subsets obtained by deleting one element from a member of $\mathcal A$.

### 3.2 Single-shadow lower bound

The full Kruskal–Katona theorem describes the *minimum possible shadow size* of a family of a given size via the colex order; its Lovász form packages this into a clean binomial inequality, and iterating handles higher shadows. We isolate the most applicable single-shadow consequence.

> **Theorem 3.1 (Single-shadow Kruskal–Katona).** Let $1 \le r \le k \le n$ and let $\mathcal A$ be an $r$-uniform family of subsets of an $n$-element set with $|\mathcal A| \ge \binom{k}{r}$. Then
> $$|\partial \mathcal A| \;\ge\; \binom{k}{r-1}.$$

**Proof sketch.** The Lovász form of Kruskal–Katona states that for each $i \ge 1$, if $|\mathcal A| \ge \binom{k}{r}$ then the $i$-th iterated shadow satisfies $|\partial^{(i)} \mathcal A| \ge \binom{k}{r-i}$. Taking $i = 1$ and noting $\partial^{(1)} = \partial$ gives the claim. The hypotheses $1 \le r \le k \le n$ are load-bearing: they ensure the binomial coefficients are the relevant non-degenerate quantities and that a witnessing family (the colex-initial segment, realized by the full $k$-set system) exists. $\;\square$

### 3.3 Graph interpretation

A $2$-element set is precisely an edge; a family $E$ of $2$-sets is a graph's edge set, and its shadow $\partial E$ is the family of singletons $\{v\}$ for vertices $v$ incident to some edge — i.e., the **non-isolated vertices**. Specializing Theorem 3.1 to $r = 2$:

> **Corollary 3.2 (Edge density forces vertex spread).** Let $2 \le k \le n$ and let $E$ be a family of $2$-element subsets of an $n$-element vertex set with $|E| \ge \binom{k}{2}$. Then the set of vertices covered by $E$ has size at least $k$:
> $$|\partial E| \ge k.$$

**Proof sketch.** Apply Theorem 3.1 with $r = 2$, using $\binom{k}{2-1} = \binom{k}{1} = k$. $\;\square$

This bound is tight: the clique $K_k$ has exactly $\binom{k}{2}$ edges on exactly $k$ vertices, so $\binom{k}{2}$ edges cannot be packed onto fewer than $k$ vertices. Like Turán's theorem, it expresses that an abundance of one resource (edges, or $r$-sets) forces a spread of its support (vertices, or $(r-1)$-sets).

---

## 4. Roth's theorem on three-term arithmetic progressions

### 4.1 Definitions

Let $G$ be a finite abelian group, written additively. A **three-term arithmetic progression (3-AP)** in $G$ is a triple $(a,\ a+d,\ a+2d)$ with $a, d \in G$; it is **non-degenerate** if $d \ne 0$. A set $A \subseteq G$ is **3-AP-free** (or *progression-free*) if the only 3-APs it contains are the trivial ones, i.e. whenever $a, b, c \in A$ satisfy $a + c = 2b$ then $a = b = c$. We measure density relative to $|G|$: $A$ has density $\ge \varepsilon$ if $|A| \ge \varepsilon |G|$.

### 4.2 Positive existence form

The standard quantitative formulation of Roth's theorem is *negative*: a sufficiently dense set is **not** progression-free. For applications one wants the *positive* statement, exhibiting an actual progression. We record it explicitly. Here $B(\varepsilon)$ denotes the effective threshold for the density $\varepsilon$ supplied by the quantitative (corners/regularity) proof — a finite quantity depending only on $\varepsilon$.

> **Theorem 4.1 (Roth, positive form).** Let $G$ be a finite abelian group and $\varepsilon > 0$. If $|G| \ge B(\varepsilon)$ and $A \subseteq G$ satisfies $|A| \ge \varepsilon |G|$, then $A$ contains a non-degenerate three-term arithmetic progression: there exist $a, d \in G$ with $d \ne 0$ and
> $$a \in A,\qquad a + d \in A,\qquad a + 2d \in A.$$

**Proof sketch.** The quantitative Roth/corners theorem gives that under $|A| \ge \varepsilon|G|$ and $|G| \ge B(\varepsilon)$, $A$ is not progression-free. Unfolding the definition of progression-freeness, its negation yields witnesses $a, b, c \in A$ with $a + c = b + b$ and $a \ne b$. Set $d := b - a$. Then $b = a + d$, and from $a + c = 2b$ we obtain $c = 2b - a = 2(a+d) - a = a + 2d$. Non-degeneracy $d \ne 0$ follows from $a \ne b$ since $d = b - a = 0$ would force $a = b$. Thus $(a, a+d, a+2d)$ is a non-degenerate 3-AP entirely contained in $A$. $\;\square$

The non-vacuousness of Theorem 4.1 hinges on both hypotheses: density $|A| \ge \varepsilon|G|$ and largeness $|G| \ge B(\varepsilon)$. Without them the underlying quantitative theorem does not apply, so the statement is genuinely a consequence of Roth's theorem and not a triviality.

### 4.3 Specialization to cyclic groups

> **Corollary 4.2 (Roth in $\mathbb{Z}/N\mathbb{Z}$).** Let $N \ge 1$ and $\varepsilon > 0$ with $N \ge B(\varepsilon)$. If $A \subseteq \mathbb{Z}/N\mathbb{Z}$ satisfies $|A| \ge \varepsilon N$, then $A$ contains a non-degenerate 3-AP $a, a+d, a+2d$ with $d \ne 0$.

**Proof sketch.** Apply Theorem 4.1 with $G = \mathbb{Z}/N\mathbb{Z}$, using $|G| = N$. $\;\square$

This is the form most useful in additive combinatorics and number theory: any positive-density set of residues modulo a large $N$ contains a genuine arithmetic progression.

---

## 5. The common thread: density forces structure

The four theorems are instances of one principle, and the connection between the graph results and the arithmetic result is more than analogical.

- **Turán/Mantel:** Among $K_{r+1}$-free graphs, edge density is maximized by the balanced $r$-partite Turán graph; exceeding the threshold forces a clique. The extremal object is unique and rigid.
- **Kruskal–Katona:** Among $r$-uniform families of a given size, the shadow is minimized by the colex-initial (clique-like) family; size forces shadow. For graphs, edges force covered vertices, tight at the clique.
- **Roth:** Among subsets of a finite abelian group, progression-freeness caps the density; exceeding the cap forces a 3-AP.

The deep bridge is the **regularity method**. Szemerédi's regularity lemma asserts that the vertex set of any large graph can be partitioned into a bounded number of parts so that almost all pairs of parts behave pseudorandomly (the edge distribution between them is uniform up to a small error $\varepsilon$). Within such a partition, the count of any small subgraph — a triangle, say — can be estimated as if edges were placed independently at random. This yields:

> **Triangle Removal Lemma (statement).** For every $\delta > 0$ there is $\gamma > 0$ such that any $n$-vertex graph with at most $\gamma n^3$ triangles can be made triangle-free by deleting at most $\delta n^2$ edges.

Roth's theorem follows by a now-classical reduction. Given a progression-free set $A \subseteq \mathbb{Z}/N\mathbb{Z}$, one builds a tripartite graph whose triangles correspond exactly to 3-APs in $A$. Progression-freeness makes the triangles essentially disjoint (each edge lies in at most one triangle), so the triangle removal lemma forces the triangle count — hence $|A|$ — to be small. This is the precise sense in which "edge density forcing triangles" (Mantel/Turán's world) and "set density forcing progressions" (Roth's world) are the same theorem viewed through two windows.

A complementary, purely enumerative viewpoint is the **first-moment method**: in a random graph, the expected number of $r$-cliques is $\binom{n}{r} p^{\binom{r}{2}}$, where $p$ is the edge probability. Comparing this *expected* count against the *deterministic* extremal count (e.g. the $0$ triangles realized by the extremal Turán graph $T(2k,2)$ versus the $\binom{n}{3}$ potential triangles of the complete graph) pinches the density of forbidden configurations from two sides. This pincer — random upper bound meeting extremal lower bound — is a powerful and reusable proof template.

---

## 6. Algorithms

We summarize three computational procedures that operationalize the results above. Full type-hinted implementations appear in the accompanying demonstration code.

### 6.1 Turán bound checker and extremal generator

**Purpose.** Given $n$ and $r$, compute the Turán edge bound and the exact edge count of $T(n,r)$, and verify $e(T(n,r)) \le \frac{r-1}{2r}n^2$.

**Method.** Write $n = qr + s$. The part sizes are $s$ parts of size $q+1$ and $r-s$ parts of size $q$. The Turán graph edge count is $\binom{n}{2}$ minus the within-part edges: $e(T(n,r)) = \binom{n}{2} - s\binom{q+1}{2} - (r-s)\binom{q}{2}$. Complexity $O(1)$ arithmetic.

### 6.2 Kruskal–Katona shadow computation

**Purpose.** Given an explicit $r$-uniform family, compute its shadow and verify the bound $|\partial\mathcal A| \ge \binom{k}{r-1}$ for the largest $k$ with $\binom{k}{r} \le |\mathcal A|$.

**Method.** For each set in the family, generate all $(r-1)$-subsets by single-element deletion; collect into a set to deduplicate. Complexity $O(|\mathcal A|\cdot r)$ subset generations.

### 6.3 Progression search via triangle counting

**Purpose.** Given $A \subseteq \mathbb{Z}/N\mathbb{Z}$, exhibit a non-degenerate 3-AP, or certify density too low.

**Method.** Brute-force scan over $a \in A$ and nonzero $d$; report the first $(a, a+d, a+2d)$ all lying in $A$. A Fourier-analytic count of progressions (via the discrete transform of the indicator of $A$) gives the asymptotic count $\approx |A|^3/N$ and confirms positivity above the Roth threshold. Complexity $O(N^2)$ brute force, or $O(N\log N)$ via FFT for the count.

---

## 7. Applications

- **Network science.** Mantel/Turán bounds cap the edge density of networks that must avoid small dense clusters (cliques), informing the design of conflict-free schedules and interference-free communication graphs.
- **Extremal set theory and coding.** Kruskal–Katona governs trade-offs between the size of a uniform family and the size of its shadow, underpinning bounds on error-correcting codes and the combinatorics of simplicial complexes.
- **Additive number theory.** Roth's theorem is the first nontrivial case of Szemerédi's theorem on arbitrarily long arithmetic progressions, foundational to additive combinatorics and the Green–Tao theorem on primes.
- **Theoretical computer science.** The regularity and removal-lemma machinery powers property testing — certifying global structural properties of huge graphs from constant-size random samples.

---

## 8. Discussion and future work

The results assembled here are exact and sharp in their extremal cases, but each opens onto a richer landscape.

1. **Stability for Mantel/Turán.** Near-extremal triangle-free graphs (with $4e \ge n^2 - cn$) are conjectured to be $O(c)$-close to balanced bipartite — robustness of the unique extremal witness $K_{k,k}$.
2. **Quantitative density thresholds for Roth.** Replacing the fixed density $\varepsilon$ with a shrinking $\varepsilon(N) \to 0$ pushes Roth from the positive-density regime into the quantitative regime, tracking how small the density may be as $N$ grows.
3. **Iterated-shadow rigidity.** For an $r$-uniform family of size exactly $\binom{k}{r}$, every iterated shadow satisfies $|\partial^{(i)}\mathcal A| \ge \binom{k}{r-i}$, with equality conjecturally characterizing the colex-isomorphic full $k$-set system.
4. **Hypergraph removal and multidimensional Roth.** The contrast between deterministic extremal counts (zero forbidden configurations) and random first-moment counts can be leveraged, via hypergraph removal, toward corner-free set sparsity and higher-dimensional patterns.
5. **Spectral Mantel.** A triangle-free graph is conjectured to satisfy $\lambda_1(G) \le \sqrt{e}$ on its largest adjacency eigenvalue, with the same extremal graphs $K_{k,k}$ — a spectral refinement of Mantel's theorem.

These directions share the program's signature: convert a global density hypothesis into a local structural conclusion, and characterize the boundary cases exactly.

---

## 9. Conclusion

Across graphs, set systems, and the integers, a single law recurs: cross a density threshold and forbidden structure becomes inevitable, while the objects that barely avoid it are forced into rigid, symmetric shapes. Turán's and Mantel's theorems quantify it for cliques, Kruskal–Katona for shadows, and Roth's theorem for arithmetic progressions — and the regularity method reveals these as facets of one phenomenon. The boundary between abundance and order is sharper, and more beautiful, than intuition suggests.
