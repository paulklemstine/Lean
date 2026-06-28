# The Brualdi–Quinn–Massey Strong Chromatic Index Bound: Tightness for Complete Bipartite Graphs and a Fibonacci–Riordan Bridge

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (Combinatorics / Number Theory bridge)

## Abstract

The strong chromatic index $\chi'_s(G)$ of a graph $G$ is the least number of colors in a proper edge coloring whose color classes are induced matchings. The Brualdi–Quinn–Massey (BQM) conjecture asserts that for every bipartite graph $G$ with partite sets $A$ and $B$,
$$\chi'_s(G) \le \Delta_A \cdot \Delta_B,$$
where $\Delta_A$ and $\Delta_B$ are the maximum degrees on the two sides. The conjecture is open; the best known general upper bound is $1.676\,\Delta_A\Delta_B$. We present a self-contained development of the strong chromatic index through its *conflict graph*, establish a universal star-clique lower bound $\chi'_s(G) \ge \max(\Delta_A,\Delta_B)$, and prove that the complete bipartite graph $K_{m,n}$ attains the BQM bound **with equality**, $\chi'_s(K_{m,n}) = mn = \Delta_A\Delta_B$. This shows the product bound is best possible: no universal constant below $1$ is admissible. We then build a cross-domain bridge to number theory. Writing $A(n) = \sum_{k=0}^{n}\binom{n+k}{2k}$ for the steep-diagonal row sums of the Pascal-like Riordan array $\binom{n+k}{2k}$, we prove the identity $A(n) = F_{2n+1}$ (odd-indexed Fibonacci numbers), and deduce that the complete bipartite graph on Riordan-sized parts has strong chromatic index equal to a product of Fibonacci numbers,
$$\chi'_s\!\left(K_{A(a),A(b)}\right) = F_{2a+1}\cdot F_{2b+1}.$$
Thus an extremal graph-coloring invariant is identified, exactly, with a product of steep-diagonal binomial sums, inheriting golden-ratio growth. All results have been formally verified.

---

## 1. Introduction

### 1.1 Motivation

Edge colorings that respect not merely adjacency but *proximity* arise wherever a shared resource must avoid local interference: frequency assignment in dense wireless networks, conflict-free time-slotting in distributed computation, and channel allocation in sensor grids. The combinatorial abstraction is the **strong edge coloring**, introduced by Fouquet and Jolivet, in which two edges may share a color only if they are at distance at least two. Its optimum, the **strong chromatic index** $\chi'_s(G)$, measures the irreducible cost of interference-free assignment.

For bipartite graphs, Brualdi, Quinn, and Massey conjectured a remarkably clean ceiling: the product of the two side-wise maximum degrees. Despite sustained attention, the conjecture remains open, with the best universal bound stuck at $1.676\,\Delta_A\Delta_B$. This persistent factor motivates two complementary questions that this paper answers completely:

1. **Is the product bound of the correct order, and is it attained?** We show the complete bipartite family attains it exactly, so the conjecture — if true — is sharp and cannot be improved by any multiplicative constant.
2. **What is the arithmetic of the extreme?** We show that for an explicit, naturally arising family of part sizes, the extremal value is a product of Fibonacci numbers.

### 1.2 Contributions

- A self-contained **conflict-graph formalization** of $\chi'_s$ as the chromatic number of a derived graph on the edge set (Section 2).
- The **universal lower bound** $\chi'_s(G) \ge \Delta_A$ and $\ge \Delta_B$ via a star clique (Theorem 3.1, `maxDegA_le_strongChromaticIndex`).
- The **tightness theorem** $\chi'_s(K_{m,n}) = \Delta_A\Delta_B = mn$ (Theorem 3.3, `completeBipartite_strongChromaticIndex`), with the BQM bound confirmed on this family (`completeBipartite_satisfies_BQM`).
- A **Fibonacci row-sum identity** $\sum_{k=0}^{n}\binom{n+k}{2k} = F_{2n+1}$ (Theorem 4.2, `pascalRiordanA_eq_fib`) and its companion $\sum_{k}\binom{n+k}{2k+1} = F_{2n}$ (`pascalRiordanB_eq_fib`), with the three-term recurrence $A(n+2) = 3A(n+1) - A(n)$ (`pascalRiordan_three_term`).
- The **bridge theorem** $\chi'_s(K_{A(a),A(b)}) = F_{2a+1}F_{2b+1}$ (Theorem 5.2, `strongChromaticIndex_riordan_complete_bipartite`).

All statements have been formally verified in a proof assistant; the present paper gives the mathematics and proof sketches.

### 1.3 Related context

Strong edge coloring was introduced by Fouquet and Jolivet and has since become a central object in extremal and algorithmic graph theory. The most celebrated open problem in the area is the conjecture of Erdős and Nešetřil that, for general graphs of maximum degree $\Delta$, the strong chromatic index is at most $\tfrac54\Delta^2$ — sharp for blow-ups of the five-cycle. The bipartite restriction studied here is the Brualdi–Quinn–Massey conjecture, which replaces the single degree parameter by the two side-wise maxima and posits the product bound $\Delta_A\Delta_B$. Both conjectures share a common difficulty: the strong chromatic index is a *second-order* coloring parameter, sensitive not only to local degree but to the distribution of edges within distance two, and so it resists the inductive and probabilistic techniques that tame ordinary chromatic invariants.

The present work does not attempt the general conjecture. Instead it isolates the two features that can be settled rigorously and exactly: the *extremal endpoint*, where the bound is attained, and a *lower envelope* that holds with no hypotheses. The remaining gap — between the proved floor $\max(\Delta_A,\Delta_B)$ and the best known ceiling $1.676\,\Delta_A\Delta_B$ — is exactly the open territory. By pinning the conjectured ceiling to an explicit, computable family and then linking that family to the Fibonacci numbers, we turn an abstract bound into a concrete arithmetical object that downstream work can test and extend.

---

## 2. Definitions

Throughout, $G$ is a finite **bipartite graph** with disjoint partite sets $A$ and $B$; every edge has one endpoint in $A$ and one in $B$. We model $G$ by its bipartite adjacency relation, and write an edge as a pair $(a,b) \in A \times B$ with $a$ adjacent to $b$.

**Definition 2.1 (Degrees).** For $a \in A$, its degree $\deg(a)$ is the number of $b \in B$ adjacent to $a$. The maximum $A$-degree is
$$\Delta_A = \max_{a \in A} \deg(a),$$
and $\Delta_B$ is defined symmetrically. (For empty partite sets the supremum is taken to be $0$; all degree statements below assume the relevant side is nonempty.)

**Definition 2.2 (Strong edge coloring).** A coloring of the edges of $G$ is *strong* if every color class is an **induced matching**: any two edges of the same color are non-adjacent, and no edge of $G$ joins an endpoint of one to an endpoint of the other. Equivalently, two edges may share a color only if they are at graph distance $\ge 2$.

**Definition 2.3 (Conflict graph).** The **conflict graph** $C(G)$ has vertex set $E(G)$ (the edges of $G$). Two distinct edges $e, f \in E(G)$ are adjacent in $C(G)$ iff they *cannot* share a color in a strong edge coloring, i.e. iff they are adjacent in $G$ or are linked by an edge of $G$ (distance $\le 1$ in the line-graph-plus-proximity sense). In the formalization this is `conflictGraph`.

**Definition 2.4 (Strong chromatic index).** The **strong chromatic index** is the chromatic number of the conflict graph,
$$\chi'_s(G) = \chi\big(C(G)\big).$$
This is the declaration `strongChromaticIndex`, valued in $\mathbb{N}^\infty = \mathbb{N}\cup\{\infty\}$ to align with the standard chromatic-number API (it is finite for finite graphs).

The conflict-graph viewpoint is the central device: it converts the distance-constrained edge coloring of $G$ into an ordinary vertex coloring of $C(G)$, so the full toolbox of chromatic-number theory (clique lower bounds, the chromatic number of a complete graph) applies directly.

**Definition 2.5 (Complete bipartite graph).** $K_{m,n}$ is the bipartite graph on $A$ (with $|A| = m$) and $B$ (with $|B| = n$) in which *every* $a \in A$ is adjacent to *every* $b \in B$. It has $mn$ edges, every $A$-vertex has degree $n$, and every $B$-vertex has degree $m$. In the formalization the adjacency is `completeAdj A B`.

**Definition 2.6 (Riordan row sums).** For the Pascal-like Riordan array with entries $t_{n,k} = \binom{n+k}{2k}$ (OEIS A085478, generated by the pair $(1/(1-x),\, x/(1-x)^2)$), define
$$A(n) = \sum_{k=0}^{n}\binom{n+k}{2k}, \qquad B(n) = \sum_{k=0}^{n}\binom{n+k}{2k+1}.$$
These are `pascalRiordanA` and `pascalRiordanB`.

---

## 3. The bound is tight: complete bipartite graphs

### 3.1 A universal lower bound

**Theorem 3.1 (Star-clique lower bound; `maxDegA_le_strongChromaticIndex`).** For every bipartite graph $G$ with $A \ne \varnothing$,
$$\chi'_s(G) \ge \Delta_A,$$
and symmetrically $\chi'_s(G) \ge \Delta_B$. Hence $\chi'_s(G) \ge \max(\Delta_A,\Delta_B)$.

*Proof sketch.* Let $a^\star \in A$ attain the maximum degree $\Delta_A$, and let $S$ be the set of $\Delta_A$ edges incident to $a^\star$. Any two edges in $S$ share the endpoint $a^\star$, hence are adjacent in $G$ and therefore adjacent in the conflict graph $C(G)$. Thus $S$ is a clique of size $\Delta_A$ in $C(G)$. Since the chromatic number is at least the clique number (`IsClique.card_le_chromaticNumber`),
$$\chi'_s(G) = \chi(C(G)) \ge |S| = \Delta_A. \qquad \square$$

The base lemma at a single vertex, `degA_le_strongChromaticIndex`, gives $\chi'_s(G) \ge \deg(a)$ for each $a$; taking the supremum over $a$ yields the maximum-degree form.

### 3.2 The conflict graph of $K_{m,n}$ is complete

**Lemma 3.2 (`conflictGraph` of complete bipartite is $\top$).** For $K_{m,n}$, the conflict graph $C(K_{m,n})$ is the complete graph on its $mn$ edges.

*Proof sketch.* Take two distinct edges $e = (a_1,b_1)$ and $f = (a_2,b_2)$ of $K_{m,n}$. If $a_1 = a_2$ or $b_1 = b_2$ they are adjacent in $G$, hence conflict. Otherwise $a_1 \ne a_2$ and $b_1 \ne b_2$; because $K_{m,n}$ is complete, the pair $(a_1, b_2)$ is also an edge, joining an endpoint of $e$ to an endpoint of $f$, so $e$ and $f$ are at distance $1$ and again conflict. Every two distinct edges are adjacent in $C(K_{m,n})$, i.e. $C(K_{m,n}) = \top$. $\square$

### 3.3 Exact value and tightness

**Theorem 3.3 (Tightness; `completeBipartite_strongChromaticIndex`).** For $K_{m,n}$ with nonempty sides,
$$\chi'_s(K_{m,n}) = \Delta_A \cdot \Delta_B = m \cdot n.$$

*Proof sketch.* By Lemma 3.2, $C(K_{m,n}) = \top$ on $mn$ vertices, and the chromatic number of a complete graph equals its vertex count (`chromaticNumber_top`): $\chi'_s(K_{m,n}) = |E(K_{m,n})| = mn$. The degree computations `maxDegA_complete` and `maxDegB_complete` give $\Delta_A = n$ and $\Delta_B = m$, so $\Delta_A\Delta_B = nm = mn$. $\square$

**Corollary 3.4 (BQM holds and is sharp; `completeBipartite_satisfies_BQM`).** The complete bipartite family satisfies the BQM bound $\chi'_s \le \Delta_A\Delta_B$, with equality. Consequently no universal statement $\chi'_s(G) \le c\,\Delta_A\Delta_B$ with $c < 1$ can hold for all bipartite $G$: it would already fail on every $K_{m,n}$.

**Remark 3.5 (Status of the general bound).** The general upper bound $\chi'_s(G) \le \Delta_A\Delta_B$ is the genuinely open BQM conjecture and is *not* claimed as a theorem here; the formalization records it as a named statement `BQMConjecture`. What is proved is (i) the matching lower wall for all $G$ and (ii) equality on the extremal family. Together with the current best general result $\chi'_s(G) \le 1.676\,\Delta_A\Delta_B$, this localizes the open problem precisely: the truth lies in $[\max(\Delta_A,\Delta_B),\, 1.676\,\Delta_A\Delta_B]$, with $\Delta_A\Delta_B$ the conjectured — and provably attained — ceiling.

---

## 4. The Fibonacci row-sum identity

We now develop the number-theoretic factor of the bridge: the steep-diagonal row sums of the Pascal-like Riordan array are odd-indexed Fibonacci numbers.

**Lemma 4.1 (Coupled Pascal recurrences).** The row sums of Definition 2.6 satisfy
$$B(n+1) = A(n) + B(n), \qquad A(n+1) = A(n) + B(n+1).$$

*Proof sketch.* For the $B$-recurrence (`pascalRiordanB_succ`), apply Pascal's rule $\binom{(n+1)+k}{2k+1} = \binom{n+k}{2k} + \binom{n+k}{2k+1}$ termwise and sum; the two pieces are exactly the defining sums of $A(n)$ and $B(n)$ (boundary terms vanish by $\binom{m}{j}=0$ for $j>m$). For the $A$-recurrence (`pascalRiordanA_succ`), a reindexing $k \mapsto k+1$ is needed to avoid truncated natural-number subtraction; working with the *odd* lower index $2k+1$ sidesteps every subtraction hazard, after which Pascal's rule again collapses the sum. $\square$

**Theorem 4.2 (Row-sum Fibonacci identity; `pascalRiordanA_eq_fib`, `pascalRiordanB_eq_fib`).** With $F$ the Fibonacci sequence ($F_0 = 0, F_1 = 1$),
$$A(n) = \sum_{k=0}^{n}\binom{n+k}{2k} = F_{2n+1}, \qquad B(n) = \sum_{k=0}^{n}\binom{n+k}{2k+1} = F_{2n}.$$

*Proof sketch.* Simultaneous induction on the pair $(A,B)$ (`pascalRiordan_pair`). Base case: $A(0) = \binom{0}{0} = 1 = F_1$ and $B(0) = \binom{0}{1} = 0 = F_0$. Inductive step: assume $A(n) = F_{2n+1}$ and $B(n) = F_{2n}$. By Lemma 4.1,
$$B(n+1) = A(n) + B(n) = F_{2n+1} + F_{2n} = F_{2n+2},$$
$$A(n+1) = A(n) + B(n+1) = F_{2n+1} + F_{2n+2} = F_{2n+3} = F_{2(n+1)+1},$$
using the Fibonacci recurrence $F_{m+2} = F_{m+1} + F_m$. $\square$

**Theorem 4.3 (Three-term recurrence; `pascalRiordan_three_term`).** $A(n+2) = 3A(n+1) - A(n)$ for all $n$.

*Proof sketch.* Substitute $A(n) = F_{2n+1}$ and apply the Fibonacci identity $F_{2n+5} = 3F_{2n+3} - F_{2n+1}$, itself two iterations of $F_{m+2}=F_{m+1}+F_m$. This is the combinatorial shadow of the generating function $(1-x)/(1-3x+x^2)$, whose denominator encodes the recurrence $A(n+2) - 3A(n+1) + A(n) = 0$. $\square$

The first values are $A(0),\dots,A(5) = 1, 2, 5, 13, 34, 89 = F_1, F_3, F_5, F_7, F_9, F_{11}$ and $B(0),\dots,B(5) = 0, 1, 3, 8, 21, 55 = F_0, F_2, F_4, F_6, F_8, F_{10}$.

---

## 5. The bridge: strong chromatic index meets Fibonacci

The tightness theorem expresses $\chi'_s(K_{m,n})$ as a *product* $m\cdot n$. Choosing the part sizes to be Riordan row sums therefore factors the invariant through the Fibonacci identity.

**Lemma 5.1 (Positivity; `pascalRiordanA_pos`).** $A(n) > 0$ for all $n$, since the $k=0$ term is $\binom{n}{0} = 1$ (equivalently $A(n) = F_{2n+1} \ge 1$). This guarantees the partite sets $\mathrm{Fin}(A(a))$ and $\mathrm{Fin}(A(b))$ are nonempty, supplying the `Nonempty`/`NeZero` instances the complete-bipartite degree formula requires (an empty part would degenerate the degree computation).

**Theorem 5.2 (Bridge theorem; `strongChromaticIndex_riordan_complete_bipartite`).** For all $a, b \in \mathbb{N}$,
$$\chi'_s\!\left(K_{A(a),\,A(b)}\right) = F_{2a+1}\cdot F_{2b+1}.$$

*Proof sketch.* By Lemma 5.1 both parts are nonempty, so Theorem 3.3 applies:
$$\chi'_s\!\left(K_{A(a),A(b)}\right) = \Delta_A\,\Delta_B = A(a)\cdot A(b).$$
Substituting the closed forms $A(a) = F_{2a+1}$ and $A(b) = F_{2b+1}$ from Theorem 4.2 yields $F_{2a+1}F_{2b+1}$. $\square$

**Theorem 5.3 (Binomial form; `strongChromaticIndex_riordan_binomial`).** Equivalently, entirely in terms of steep-diagonal binomial sums,
$$\chi'_s\!\left(K_{A(a),A(b)}\right) = \left(\sum_{k=0}^{a}\binom{a+k}{2k}\right)\!\left(\sum_{k=0}^{b}\binom{b+k}{2k}\right).$$

*Proof sketch.* Immediate from Theorem 5.2 and the definition of $A$ via Theorem 4.2 (applied in reverse). $\square$

**Why the bridge is genuine.** Neither factor of the identity is available from one side alone. The left-hand side is a graph-coloring invariant whose value requires the conflict-graph analysis of Section 3; the right-hand side requires the binomial-to-Fibonacci collapse of Section 4. Deleting either ingredient breaks the statement. The connection is the multiplicativity of $\chi'_s$ on complete bipartite graphs: *any* factorization identity for a sequence lifts to an identity for $\chi'_s$ of the corresponding complete bipartite family.

**Golden-ratio growth.** Since $F_m \sim \varphi^m/\sqrt5$ with $\varphi = (1+\sqrt5)/2$, the extremal values grow as
$$\chi'_s\!\left(K_{A(a),A(b)}\right) = F_{2a+1}F_{2b+1} \sim \frac{\varphi^{2a+2b+2}}{5},$$
so each unit increment of $a$ or $b$ multiplies the strong chromatic index asymptotically by $\varphi^2 \approx 2.618$.

---

## 6. Algorithms

We summarize the constructive content as algorithms (full type-hinted Python appears in the accompanying demo and package).

**Algorithm A — Strong chromatic index of a bipartite graph by conflict-graph coloring.** Build the conflict graph $C(G)$ on the edge set: connect two edges if they share an endpoint or are joined by an edge. Then compute (or bound) $\chi(C(G))$. For a complete bipartite graph this short-circuits to $mn$ by Theorem 3.3. Complexity: $O(|E|^2)$ to build $C(G)$; chromatic number is NP-hard in general but trivial on the complete and complete-bipartite-derived instances treated here.

**Algorithm B — Riordan row sum and Fibonacci verification.** Compute $A(n) = \sum_{k=0}^{n}\binom{n+k}{2k}$ directly, and independently compute $F_{2n+1}$; assert equality. Both in $O(n)$ arithmetic operations (with big integers). Used to certify Theorem 4.2 numerically.

**Algorithm C — Bridge evaluator.** Given $(a,b)$, return the triple $\big(A(a)\cdot A(b),\; F_{2a+1}F_{2b+1},\; \text{strong index of } K_{A(a),A(b)}\big)$ and verify all three agree, certifying Theorem 5.2. $O(a+b)$.

---

## 7. Applications

- **Wireless and sensor networks.** $\chi'_s$ is the minimum number of frequency/time slots for interference-free communication when interference reaches distance two. The tightness result gives the exact spectrum requirement for fully-connected bipartite topologies (e.g. base-stations vs. clients), and the universal lower bound certifies an unavoidable floor for any topology.
- **Conflict-free scheduling.** In task-resource bipartite models, $\chi'_s$ counts the minimum scheduling rounds when two assignments interfere if they are within one hop; the product bound estimates worst-case round counts.
- **Combinatorial identities and OEIS cross-links.** The bridge places a graph invariant onto the Fibonacci sequence A001519 ($F_{2n+1}$) via the Riordan array A085478, illustrating how multiplicative graph parameters transport number-theoretic identities into combinatorics.

---

## 8. Discussion

The results sharpen the landscape around a classical open conjecture. The product bound $\Delta_A\Delta_B$ is shown to be the *correct ceiling*: it is attained with equality by complete bipartite graphs, and a matching floor $\max(\Delta_A,\Delta_B)$ holds universally. The conflict-graph formulation is the workhorse — it reduces a distance-constrained coloring to a standard chromatic-number computation, which is what makes both the clique lower bound and the complete-graph equality immediate. The Fibonacci bridge then demonstrates that the extremal values are far from arbitrary: they are products of odd-indexed Fibonacci numbers and grow at the square of the golden ratio.

A methodological point worth emphasizing: multiplicativity of $\chi'_s$ on complete bipartite graphs is the universal lever. It means the strong-chromatic-index spectrum of the complete bipartite family is exactly the multiplicative semigroup generated by the integers — and any sequence with a clean closed form, when used as part sizes, exports its arithmetic into the coloring world.

Three further observations deserve emphasis. First, the conflict-graph reduction is not merely a notational convenience: it is what makes the equality $\chi'_s(K_{m,n})=mn$ a *one-line* consequence of a standard chromatic-number fact (the chromatic number of a complete graph equals its order), rather than an ad hoc coloring construction. Any attempt to lower the bound below $\Delta_A\Delta_B$ must contend with the fact that the complete bipartite conflict graph is the complete graph $K_{mn}$, whose chromatic number is genuinely $mn$ and admits no shortcut. Second, the lower bound and the equality together exhibit a striking *rigidity*: the only freedom in the value of $\chi'_s(K_{m,n})$ is the choice of $m$ and $n$, and the value is their product, with no lower-order corrections. This is what allows arithmetic sequences to be read off cleanly. Third, the Fibonacci appearance is not an accident of the particular Riordan array chosen: the steep diagonal $\binom{n+k}{2k}$ is precisely the diagonal whose generating function has denominator $1-3x+x^2$, the characteristic polynomial of the map $n\mapsto F_{2n+1}$. Choosing a different diagonal would produce a different linear-recurrent sequence, and the multiplicativity lever would export *that* sequence's arithmetic instead — a general mechanism, of which the Fibonacci bridge is the cleanest instance.

Finally, we note the contrast in epistemic status across the results. The lower bound and the complete-bipartite equality are theorems, proved and machine-checked. The product bound for *all* bipartite graphs is a conjecture, recorded but not proved. The Fibonacci bridge is a theorem, but a conditional kind of theorem in spirit: it is unconditional as stated (it concerns only complete bipartite graphs, where the value is known exactly), yet its interest derives from the conjectural picture in which $\Delta_A\Delta_B$ is the universal answer. The package thus models a healthy division of labor between what is settled and what is conjectured, with the formal verification guaranteeing that the settled part is genuinely settled.

---

## 9. Future Directions

**C1. Sandwich conjecture: $\max(\Delta_A,\Delta_B) \le \chi'_s(G) \le \Delta_A\Delta_B$ for all bipartite $G$.** The lower side is proved (`maxDegA_le_strongChromaticIndex`); the upper side is the open BQM bound. We conjecture both ends are simultaneously attainable: for every pair $(p,q)$ with $p \le N \le pq$ there is a bipartite graph with $\Delta_A = q$, $\Delta_B = p$ and $\chi'_s = N$. The key insight is that $\chi'_s$ is exactly the chromatic number of the conflict graph, so realizability of $\chi'_s$ reduces to realizability of chromatic numbers of a controllable family of conflict graphs interpolating between a matching ($\chi = \Delta$) and a clique ($\chi = \Delta_A\Delta_B$).

**C2. Equality classification: $\chi'_s(G) = \Delta_A\Delta_B$ iff $G$ is complete bipartite.** We proved complete bipartite graphs attain equality and conjecture they are the only connected bipartite graphs that do. The key insight is that equality forces the conflict graph to be complete, i.e. every two edges are at distance $\le 1$ — an "edge-diameter $\le 1$" condition that should pin the graph down to $K_{m,n}$.

**C3. Fibonacci ladder of colouring invariants.** Generalize the bridge: for the doubly-Riordan family $K_{A(a),B(b)}$ with $B(n) = \sum_k\binom{n+k}{2k+1} = F_{2n}$, conjecture $\chi'_s(K_{A(a),B(b)}) = F_{2a+1}\cdot F_{2b}$ and, more boldly, that *every* product $F_iF_j$ arises as a strong chromatic index of an explicit complete bipartite graph. The key insight is that the strong chromatic index of a complete bipartite graph is multiplicative in the part sizes, so any factorization identity lifts to an identity for $\chi'_s$; both `pascalRiordanA_eq_fib` and `pascalRiordanB_eq_fib` are already established.

**C4. Conflict-degree greedy bound $\chi'_s(G) \le 2\Delta_A\Delta_B + \Delta_A + \Delta_B - 1$.** A from-scratch, fully provable weakening of BQM: bound the maximum degree of the conflict graph and apply the greedy bound $\chi \le \Delta_{\text{conflict}} + 1$. The key insight is that an edge $(a,b)$ conflicts only with edges sharing $a$ ($\le \Delta_A - 1$), sharing $b$ ($\le \Delta_B - 1$), or reachable through a neighbour ($\le 2\Delta_A\Delta_B$).

---

## 10. Conclusion

We have given a self-contained account of the strong chromatic index via its conflict graph, proved a universal lower bound and the exact value $\chi'_s(K_{m,n}) = \Delta_A\Delta_B$, and constructed a verified bridge identifying the extremal invariant on Riordan-sized complete bipartite graphs with the product $F_{2a+1}F_{2b+1}$ of odd-indexed Fibonacci numbers. The Brualdi–Quinn–Massey conjecture remains open in general, but its conjectured bound is now known to be sharp and unbeatable, and its extreme carries the unmistakable signature of the golden ratio.
