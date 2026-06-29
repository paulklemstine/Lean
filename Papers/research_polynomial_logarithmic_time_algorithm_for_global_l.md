# A Rigorous Foundation for the Global Label Min-Cut Problem

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Computation / Combinatorial Optimization

## Abstract

We give a complete, self-contained mathematical foundation for the **Global Label Min-Cut (GLMC)** problem on finite labeled graphs. In GLMC, every edge of an undirected graph carries a label from a finite palette of size $p$, and the cost of a bipartition of the vertex set is the number of *distinct labels* appearing on the edges that cross it; the objective is to minimize this cost over all nontrivial bipartitions. We formalize the model precisely — vertices, labeled edges, crossing edges, cut-label sets, the cut value, the set of proper cuts, and the global optimum — and establish its core theory: the objective is bounded above by the palette size $p$; a proper cut exists whenever the graph has at least two vertices; the optimum is genuinely attained by a witnessing proper cut and is a true minimum (both the lower-bound and attainment directions are proved); and the optimum is zero exactly when the graph already admits an edge-free bipartition. The optimum is realized as an explicit finite (exponential-time) brute-force solver over the $2^{|V|}$ vertex subsets, and our correctness theorems certify that this solver returns the genuine minimum. We additionally document, with proof-level care, why a previously conjectured "polynomial-in-$n$-and-$p$, fixed-genus" algorithm cannot be obtained by the proposed treewidth pipeline: the running time the pipeline yields is quasi-polynomial rather than polynomial, the underlying genus-to-treewidth bound is false without an additive $+1$ correction, and an NP-hardness backdrop makes the polynomial target implausible. The contribution is a trustworthy, foundation-independent kernel on which sharper algorithmic results can be built.

## 1. Introduction

Classical minimum-cut theory measures the cost of separating a graph by counting *edges* (or summing edge weights). In many applications, however, edges are grouped into *types*, and the meaningful unit of cost is the *type*, not the individual edge: disabling one type disables all edges bearing it simultaneously. Communication conduits, shared infrastructure corridors, regulatory-molecule influences, and vulnerability classes in security systems all share this structure. The resulting optimization — minimize the number of distinct edge-types whose removal disconnects the graph — is the **Global Label Min-Cut (GLMC)** problem. The "global" qualifier indicates that we seek *any* nontrivial bipartition, not a separation of two designated terminals.

This paper provides the foundational layer for GLMC: an exact model and the theorems that make the objective well posed and computable. We deliberately separate two things that are often conflated. The first is the *mathematical content* of the problem — what it asks and what is provably true about it — which we establish in full. The second is the *runtime conjecture* originally attached to the problem — a fast algorithm for surface-embedded graphs — which we analyze and show cannot be obtained as stated. Distinguishing solid theory from aspirational algorithmics is itself a contribution: it prevents downstream work from building on a flawed shortcut.

Throughout, we fix a finite vertex type $V$ and a finite label type $L$, with $n = |V|$ and $p = |L|$, both equipped with decidable equality so that all set operations below are finite computations.

### 1.1 Related problems and context

GLMC belongs to the family of *labeled* (or *colored*) graph optimization problems, in which a coloring of the edges modulates the cost of a structure. The closest relatives are the **Minimum Label Cut** problem (separate two designated terminals $s$ and $t$ using the fewest edge-labels) and the **Minimum Label Spanning Tree** problem (connect the graph using the fewest labels). GLMC is the *global, terminal-free* cut analogue: it asks for the cheapest nontrivial bipartition rather than the cheapest $s$–$t$ separation. The distinction matters algorithmically, exactly as it does in classical (unlabeled) cut theory, where global min-cut admits a near-linear randomized algorithm while the labeled variants are markedly harder.

Two features set the labeled objective apart from classical weighted min-cut. First, the cost is the *cardinality of a label set*, not a sum of edge weights; it is therefore inherently a *set-cover-like* quantity, and many labeled cut problems inherit the NP-hardness of set cover. Second, removing a label is an *all-or-nothing* action affecting every edge of that label simultaneously, which destroys the local, edge-by-edge exchange arguments underlying classical max-flow/min-cut duality. These two features are precisely why a clean, verified foundation is valuable before any algorithmic claim is made: the intuitions transported from weighted min-cut are unreliable here.

### 1.2 Notation and conventions

We write $A^c = V \setminus A$ for the complement of a vertex subset, $|S|$ for cardinality, and identify a finite "set of edges" with a finite collection of triples (parallel edges and repeated labels are permitted; only *distinct labels* are counted in the objective). All quantities are natural numbers; subtraction never appears, so no truncation subtleties arise. The empty minimum convention ($\min \varnothing = 0$) is used only for $\mathrm{glmcOpt}$ and only in the degenerate case $|V| \le 1$, where no proper cut exists; every substantive theorem either avoids this case or treats it explicitly.

## 2. The model

### 2.1 Instances

**Definition 2.1 (Instance).** An *instance* of GLMC is a finite set of labeled edges
$$ E \subseteq V \times V \times L, $$
where a triple $(u, v, \ell) \in E$ denotes an undirected edge $\{u, v\}$ carrying label $\ell$.

The encoding is directed (ordered triples) but models an undirected problem faithfully, because every quantity we define depends only on the unordered pair: storing $(u, v, \ell)$ versus $(v, u, \ell)$ changes neither whether the edge crosses a given cut nor its label.

### 2.2 Cuts and crossing edges

**Definition 2.2 (Cut, crossing).** A *cut* is a subset $A \subseteq V$, inducing the bipartition $(A, A^c)$. An edge $(u, v, \ell)$ *crosses* $A$ iff exactly one endpoint lies in $A$:
$$ (u \in A) \neq (v \in A). $$

**Definition 2.3 (Cut-label set, cut value).** The *cut-label set* of $A$ is the set of labels on crossing edges,
$$ \mathrm{cutLabels}(E, A) = \bigl\{\, \ell \;:\; \exists\, (u,v,\ell) \in E,\ (u \in A) \neq (v \in A) \,\bigr\}, $$
realized concretely as the image, under the label projection $(u,v,\ell) \mapsto \ell$, of the subset of $E$ consisting of crossing edges. The *cut value* is its cardinality,
$$ \mathrm{cutValue}(E, A) = \bigl|\mathrm{cutLabels}(E, A)\bigr|. $$

The defining modeling choice is that $\mathrm{cutValue}$ counts *distinct labels*, not crossing edges: parallel crossing edges of the same label contribute a single unit of cost.

### 2.3 Proper cuts and the optimum

**Definition 2.4 (Proper cuts).** The set of *proper cuts* of $V$ is
$$ \mathrm{properCuts}(V) = \{\, A \subseteq V \;:\; A \neq \varnothing \ \text{and}\ A \neq V \,\}. $$
These are exactly the nontrivial bipartitions $(A, V \setminus A)$.

**Definition 2.5 (GLMC optimum).** The *GLMC optimum* is the minimum cut value over proper cuts, with value $0$ by convention when no proper cut exists:
$$ \mathrm{glmcOpt}(E) = \min_{A \in \mathrm{properCuts}(V)} \mathrm{cutValue}(E, A), $$
where the empty minimum is taken to be $0$.

Because $V$ is finite, $\mathrm{properCuts}(V)$ is a finite collection of at most $2^{n}$ subsets, and $\mathrm{glmcOpt}$ is a finite computation. Operationally, $\mathrm{glmcOpt}$ *is* the brute-force solver: enumerate proper cuts, evaluate $\mathrm{cutValue}$ on each, take the minimum. Sections 3–4 prove this returns the true minimum.

## 3. Boundedness and existence

**Theorem 3.1 (Cut value bounded by palette size).** For every instance $E$ and every cut $A$,
$$ \mathrm{cutValue}(E, A) \le p. $$

*Proof.* $\mathrm{cutLabels}(E, A)$ is a subset of the finite label type $L$, hence its cardinality is at most $|L| = p$. ∎

**Theorem 3.2 (Existence of a proper cut).** If $n = |V| \ge 2$, then $\mathrm{properCuts}(V) \neq \varnothing$.

*Proof.* Since $|V| \ge 2$, choose distinct vertices $a \neq b$. The singleton $A = \{a\}$ is nonempty, and it is not all of $V$ because $b \notin A$. Hence $A \in \mathrm{properCuts}(V)$. ∎

**Theorem 3.3 (Membership characterization).** For $A \subseteq V$,
$$ A \in \mathrm{properCuts}(V) \iff A \neq \varnothing \ \text{and}\ A \neq V. $$

*Proof.* Immediate by unfolding Definition 2.4. ∎

**Theorem 3.4 (Optimum bounded by palette size).** For every instance $E$,
$$ \mathrm{glmcOpt}(E) \le p. $$

*Proof.* If no proper cut exists, $\mathrm{glmcOpt}(E) = 0 \le p$. Otherwise the minimum is attained at some proper cut $A$ (Theorem 4.2), and $\mathrm{glmcOpt}(E) = \mathrm{cutValue}(E, A) \le p$ by Theorem 3.1. More directly: every element of the set $\{\mathrm{cutValue}(E, A) : A \in \mathrm{properCuts}(V)\}$ is at most $p$, so its minimum is too. ∎

## 4. Correctness: the optimum is the true minimum

The central guarantee splits into a lower-bound direction and an attainment direction; together they certify that $\mathrm{glmcOpt}$ equals the genuine minimum over proper cuts.

**Theorem 4.1 (Lower-bound correctness).** For every instance $E$ and every proper cut $A \in \mathrm{properCuts}(V)$,
$$ \mathrm{glmcOpt}(E) \le \mathrm{cutValue}(E, A). $$

*Proof.* $\mathrm{cutValue}(E, A)$ is one of the elements of the finite set over which $\mathrm{glmcOpt}(E)$ takes a minimum; a minimum is $\le$ each of its elements. (When the set is empty the statement is vacuous, since no such $A$ exists.) ∎

**Theorem 4.2 (Attainment).** If $n = |V| \ge 2$, then for every instance $E$ there exists a proper cut $A$ with
$$ \mathrm{cutValue}(E, A) = \mathrm{glmcOpt}(E). $$

*Proof.* By Theorem 3.2 the set $\mathrm{properCuts}(V)$ is nonempty, so the finite, nonempty image $\{\mathrm{cutValue}(E, A) : A \in \mathrm{properCuts}(V)\}$ of natural numbers attains its minimum at some $A^\star \in \mathrm{properCuts}(V)$: that is, $\mathrm{cutValue}(E, A^\star) \le \mathrm{cutValue}(E, B)$ for all proper $B$. By definition of $\mathrm{glmcOpt}$ as the minimum over exactly this image, $\mathrm{cutValue}(E, A^\star) = \mathrm{glmcOpt}(E)$. ∎

Theorems 4.1 and 4.2 jointly state that $\mathrm{glmcOpt}(E)$ is a *witnessed* minimum: it lower-bounds the cost of every split, and some explicit split achieves it. The brute-force enumeration of Definition 2.5 therefore returns the correct optimum.

**Theorem 4.3 (Zero optimum from a separated bipartition).** Let $A \in \mathrm{properCuts}(V)$ be a proper cut such that no edge of $E$ crosses it:
$$ \forall\, (u,v,\ell) \in E,\quad \neg\bigl((u \in A) \neq (v \in A)\bigr). $$
Then
$$ \mathrm{glmcOpt}(E) = 0. $$

*Proof.* With no crossing edges, $\mathrm{cutLabels}(E, A) = \varnothing$, so $\mathrm{cutValue}(E, A) = 0$. By Theorem 4.1, $\mathrm{glmcOpt}(E) \le 0$, and since the value is a natural number, $\mathrm{glmcOpt}(E) = 0$. ∎

Theorem 4.3 identifies $\mathrm{glmcOpt}(E) = 0$ as the exact algebraic signature of an already-disconnected graph: a value of $0$ holds precisely when some nontrivial bipartition cuts no edges, i.e. when $A$ is a union of connected components.

## 5. Algorithms

### 5.1 Exact brute-force solver

**Algorithm BF (Exhaustive enumeration).** Given an instance $E$ over vertex set $V$ with $|V| = n$:

1. Enumerate every subset $A \subseteq V$ (there are $2^n$).
2. Discard $A = \varnothing$ and $A = V$ (the improper cuts).
3. For each remaining $A$, scan $E$, collect the labels of crossing edges into a set, and record its cardinality $\mathrm{cutValue}(E, A)$.
4. Return the minimum recorded value (or $0$ if none was recorded).

**Correctness.** By Theorems 4.1–4.2, the value returned equals $\mathrm{glmcOpt}(E)$. **Complexity.** $O(2^n \cdot |E|)$ time and $O(p)$ working space per cut. The exponential factor is inherent to enumeration; the per-cut work is linear in the instance size.

### 5.2 Optimization: cut-by-singletons lower bound and early exit

Because $\mathrm{cutValue} \ge 0$ and is integer-valued, BF can early-exit the moment a cut of value $0$ is found (Theorem 4.3 guarantees this is globally optimal). More generally, the palette bound (Theorem 3.1) gives the a priori certificate $\mathrm{glmcOpt}(E) \le p$, so the search can stop as soon as a cut of value $1$ is found whenever $p \ge 1$ and no $0$-cut exists below it, etc. These are sound pruning rules, not asymptotic improvements.

## 6. The runtime conjecture: analysis of why the proposed pipeline fails

The originating motivation conjectured a deterministic algorithm solving GLMC on genus-$g$ surface-embedded graphs in time $2^{O(g)} \cdot n^{O(1)} \cdot p^{O(1)}$ — polynomial in $n$ and $p$ for fixed $g$ — via a three-step pipeline: (1) a genus-to-treewidth bound, (2) a tree-decomposition dynamic program, (3) composition. We record, foundation-independently, why this cannot be carried out as stated. None of the points below depend on GLMC itself, so there is no circularity.

**6.1 Quasi-polynomial vs. polynomial.** Even granting all ingredients, a treewidth-$w$ dynamic program for a labeled cut objective incurs running time exponential in $w$. With the (corrected) bound $w = O(\sqrt{(g+1)\,n})$, composition yields
$$ 2^{O(\sqrt{(g+1)\,n})} \cdot p^{O(\sqrt{(g+1)\,n})} \cdot n^{O(1)}, $$
which for fixed $g$ is *quasi-polynomial* in $n$ and $p$, strictly weaker than the conjectured polynomial bound. The pipeline's own composition step delivers only the quasi-polynomial estimate; the conjectured and derived bounds are inconsistent.

**6.2 The genus-to-treewidth bound is false as stated.** The correct statement is that a graph of (Euler) genus $g$ on $n$ vertices has treewidth $O(\sqrt{(g+1)\,n})$; the additive $+1$ is essential. The version $O(\sqrt{g\,n})$ collapses to $0$ at $g = 0$, yet the planar $\sqrt{n} \times \sqrt{n}$ grid has treewidth $\Theta(\sqrt{n})$. Hence step (1), as stated without the $+1$, is incorrect on planar inputs.

**6.3 Hardness backdrop.** Minimum-label cut problems are NP-hard in general. If GLMC is NP-hard already on planar graphs, a polynomial-in-$n$-and-$p$ algorithm at $g = 0$ (the conjecture's specialization) would imply $P = NP$, making the conjectured polynomial bound implausible. A quasi-polynomial bound is consistent with hardness; the polynomial one is not. (This is a caution, not a proof of hardness.)

**6.4 Foundational gaps.** The structural prerequisites — treewidth, tree decompositions, the graph-minor/grid-minor theory, and genus/surface-embedding theory — are not available as formal infrastructure in the environment used here, so steps (1)–(3) have no formal basis to invoke. The well-posed, foundation-independent content that *is* established is exactly the model and theory of Sections 2–5.

## 7. Worked examples

**Example 7.1 (Barbell).** Two triangles $T_1, T_2$, each internally wired with label $r$, joined by a single bridge labeled $b$. The bipartition $(V(T_1), V(T_2))$ crosses only the bridge, so its value is $1$; no proper cut achieves $0$ (the graph is connected). Hence $\mathrm{glmcOpt} = 1$.

**Example 7.2 (Doubled bridge).** As in 7.1 but with a second bridge labeled $g$ in parallel with $b$. The triangle-vs-triangle split now crosses two labels, value $2$, but carving off a single triangle vertex crosses fewer label-types depending on internal labeling; the optimum is the minimum over all such splits, computed by Algorithm BF.

**Example 7.3 (Already disconnected).** Two triangles with no bridge at all. The split $(V(T_1), V(T_2))$ crosses no edge, so by Theorem 4.3, $\mathrm{glmcOpt} = 0$.

**Example 7.4 (Palette bound tightness).** A complete bipartite "double star" whose every crossing must hit all $p$ labels forces $\mathrm{cutValue} = p$ on every proper cut, showing the bound $\mathrm{glmcOpt} \le p$ of Theorem 3.4 is tight in the worst case.

## 8. Applications

- **Communication resilience.** Labels = fiber conduits; $\mathrm{glmcOpt}$ = fewest conduit-types whose failure isolates a region.
- **Shared infrastructure corridors.** Labels = corridor-types shared by power/gas/rail; $\mathrm{glmcOpt}$ = corridor-type fragility.
- **Systems biology.** Labels = regulatory molecules; $\mathrm{glmcOpt}$ = fewest molecules to suppress to modularize a network.
- **Cybersecurity.** Labels = vulnerability classes; $\mathrm{glmcOpt}$ = size of the smallest exploit toolkit that partitions a system.

In each, the labeled cut value captures a resilience invariant invisible to ordinary edge-counting min-cut. The common thread is *shared mode of failure*: when many connections fail together because they belong to one administrative, physical, chemical, or logical class, the right unit of cost is the class, and GLMC is its canonical optimization.

## 9. Limitations and threats to validity

Three caveats deserve emphasis. (i) *Computational scope.* The verified solver is exponential; nothing here yields a practical algorithm for large $n$, and Section 6 argues that, in general, none should be expected. The foundation is a correctness baseline, not a performance result. (ii) *Modeling faithfulness.* The directed-triple encoding of undirected edges is faithful for every quantity we define (each depends only on the unordered endpoint pair), but a user importing the model should confirm that their application truly counts *distinct labels* rather than weighted or multiplicity-sensitive costs; a different objective is a different problem. (iii) *Hardness is cited, not proved here.* The NP-hardness backdrop invoked in Section 6 is standard for minimum-label cut problems but is used only as a plausibility caution against the conjectured polynomial bound; we do not formalize a hardness reduction, and doing so is left as future work (Section 10, item iv).

## 10. Discussion and future work

The contribution is a trustworthy kernel: a faithful finite model, the palette upper bound, existence of proper cuts, two-sided correctness of the optimum (lower bound and attainment), the zero-optimum disconnection criterion, and an exact brute-force solver certified against the definition. We also delineate the negative space: the conjectured fast surface algorithm fails as stated for the reasons of Section 6, and a genuinely polynomial general algorithm is implausible under standard complexity assumptions.

Promising directions include: (i) a submodularity/matroid analysis of the component-count function on label sets, which could power fractional relaxations; (ii) recursive label-bucketing toward sub-brute-force exact algorithms, verifiable against BF on finite instances; (iii) a labeled Menger-type min-cut/max-flow duality with label-disjoint path packings; and (iv) parameterized-complexity classification — fixed-parameter tractability in the optimum value $k$ versus W[1]-hardness in the palette size $p$. The exact, verified baseline established here is precisely what makes these conjectures sharply falsifiable.

## 11. Conclusion

The value of this work lies less in any single theorem than in the *completeness and reliability* of the package as a whole. We have isolated the genuinely well-posed core of the Global Label Min-Cut problem and proved, end to end, the statements a downstream user needs to trust before building anything: that the objective is a finite, well-defined natural number; that it never exceeds the palette size $p$ (Theorem 3.1, Theorem 3.4); that a proper cut exists whenever the graph is nontrivial (Theorem 3.2); that the optimum is simultaneously a lower bound on every cut and an attained minimum, so the brute-force enumeration is correct (Theorems 4.1–4.2); and that a value of zero is exactly the algebraic fingerprint of an already-separated graph (Theorem 4.3). Each of these is elementary, and that is deliberate: a foundation should be unsurprising, exhaustively checkable, and free of hidden assumptions.

Equally deliberate is the candor of Section 6. A weaker write-up might have advertised the originally conjectured fixed-genus polynomial-time algorithm as an aspiration; instead we record precisely why the proposed treewidth pipeline cannot deliver it — the bound it actually yields is quasi-polynomial, the genus-to-treewidth estimate is false without its additive correction, and the polynomial target collides with the NP-hardness of label-cut problems. Mapping this negative space is not a concession but a service: it steers future effort toward the open, genuinely interesting questions (submodular structure, sub-brute-force exact search, labeled duality, and parameterized hardness) and away from a shortcut that does not exist. The result is a small, sturdy, and honest platform on which sharper algorithmic theory can now be built.
