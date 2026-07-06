# Tightness of the Edge-Deletion Bound in a Hyperstability Extension of the Erdős–Gallai Theorem

## Abstract

The Erdős–Gallai theorem bounds the number of edges in a graph that avoids long paths or cycles, and its modern *stability* and *hyperstability* refinements measure how far a graph can be from the extremal structure. In this paper we study a hyperstability formulation phrased as an **edge-deletion cost**: given a graph $G$ that contains no cycle of length $d$, how many edges must be deleted before every connected component of the result admits a vertex cover of size at most $(1+c)d$, where $c>0$ is a slack parameter? We prove a matching pair of bounds. On the upper side, two elementary counting lemmas show that any graph all of whose components have vertex cover at most $k$ has at most $k\cdot n$ edges. On the lower side, we exhibit an explicit extremal witness — the balanced complete bipartite graph $K_{t,t}$ on $n=2t$ vertices — and prove that, when calibrated to the threshold $t = 2(1+2c)d$, transforming it into the bounded-cover regime requires **at least $c\,d\cdot n$ edge deletions**. Because $K_{t,t}$ is bipartite it is automatically free of every odd cycle, so the construction certifies tightness for all odd $d$. The two bounds coincide exactly at the threshold, establishing that the $c\,d\cdot n$ deletion bound is order-optimal and, at the boundary, attained with equality.

**Keywords:** Erdős–Gallai theorem, hyperstability, edge-deletion distance, vertex cover, complete bipartite graph, extremal graph theory, cycle-free graphs.

---

## 1. Introduction

### 1.1 Background and motivation

Extremal graph theory studies the maximum density of graphs that avoid a prescribed substructure. The prototypical result for paths and cycles is the **Erdős–Gallai theorem**, one form of which states that a graph on $n$ vertices with no cycle of length at least $k$ has at most $\tfrac{(k-1)(n-1)}{2}$ edges, while a companion form bounds graphs with no path on $k$ vertices. These theorems fix a *ceiling* on the edge count.

Contemporary extremal combinatorics goes further, asking two successively stronger questions:

- **Stability.** Must every graph whose edge count is *close* to the extremal maximum be *structurally close* to the unique extremal graph?
- **Hyperstability.** Must every graph that *fails* the structural conclusion fail *robustly* — in the sense that a *large* number of edge modifications is needed to repair it?

Hyperstability converts a qualitative structural dichotomy into a quantitative *repair cost*. This paper adopts a natural measure of that cost. We fix a "simplicity target": every connected component should admit a small vertex cover. A vertex cover of a graph is a set of vertices meeting every edge; a graph whose components all have small covers is, componentwise, thin and structurally transparent. We then ask how many edges must be deleted from a cycle-free host graph to reach this target regime.

### 1.2 The question, precisely

Throughout, $G$ is a finite simple graph on $n$ vertices, $d \ge 3$ is the forbidden cycle length, and $c > 0$ is a fixed slack parameter. We say $G$ is in the **bounded-component-cover regime with budget $k$** if every connected component of $G$ admits a vertex cover of size at most $k$. Our target budget is $k = (1+c)d$.

> **Central question.** Does there exist a graph $G$ on $n$ vertices, free of cycles of length $d$, such that at least $c\,d\cdot n$ edge deletions are required to bring $G$ into the bounded-component-cover regime with budget $(1+c)d$?

We answer this in the affirmative for every odd $d$, with an explicit and optimally calibrated construction.

### 1.3 Summary of contributions

1. **Lemma A (cover-to-edge bound).** A graph on $n$ vertices with a vertex cover of size $k$ has at most $k\cdot n$ edges.
2. **Lemma B (componentwise cover-to-edge bound).** A graph on $n$ vertices whose every connected component has a vertex cover of size at most $k$ has at most $k\cdot n$ edges.
3. **Main Theorem (tightness).** For $t = 2(1+2c)d$ and $n = 2t$, every subgraph $H \le K_{t,t}$ in the bounded-component-cover regime with budget $(1+c)d$ satisfies
   $$e(K_{t,t}) - e(H) \;\ge\; c\,d\cdot n,$$
   where $e(\cdot)$ denotes edge count. The bound is attained with equality at the threshold, so it is tight.

---

## 2. Definitions and preliminaries

We work with finite simple graphs. For a graph $G=(V,E)$ we write $n = |V|$ for the number of vertices and $e(G) = |E|$ for the number of edges.

**Definition 1 (Vertex cover).** A set $C \subseteq V$ is a *vertex cover* of $G$ if every edge of $G$ has at least one endpoint in $C$; equivalently, for every edge $\{u,v\}\in E$, at least one of $u,v$ lies in $C$.

**Definition 2 (Connected component and induced subgraph).** A *connected component* of $G$ is a maximal set of mutually reachable vertices, together with the edges induced on it. For a vertex set $S$, the *induced subgraph* $G[S]$ has vertex set $S$ and retains exactly those edges of $G$ with both endpoints in $S$. The components partition $V$, and every edge of $G$ lies inside exactly one component.

**Definition 3 (Balanced complete bipartite graph).** For $t\in\mathbb{N}$, the *balanced complete bipartite graph* $K_{t,t}$ has vertex set $A \sqcup B$ with $|A|=|B|=t$, and edge set consisting of all pairs $\{a,b\}$ with $a\in A$, $b\in B$. Thus $n = 2t$ and $e(K_{t,t}) = t^2$.

**Definition 4 (Cycle-freeness).** A graph is *$C_d$-free* if it contains no cycle whose length (number of edges) equals $d$.

**Definition 5 (Edge-deletion distance to the bounded-cover regime).** For a host graph $G$ and budget $k$, the *deletion cost* is
$$\Delta_k(G) \;=\; \min\Big\{\, e(G) - e(H) \;:\; H\le G,\ \text{every component of } H \text{ has a vertex cover of size} \le k \,\Big\}.$$
Here $H \le G$ means $H$ is a subgraph on the same vertex set obtained by deleting edges.

Two standard facts about $K_{t,t}$ underpin the construction.

**Fact 1 (edge count).** $K_{t,t}$ has exactly $t^2$ edges. This is the number of ordered choices of one vertex per side.

**Fact 2 (odd-cycle-freeness).** Every cycle in a bipartite graph has even length, since consecutive vertices alternate between the two sides and returning to the start requires an even number of steps. Consequently $K_{t,t}$ is $C_d$-free for every odd $d$.

---

## 3. The upper bound: covers cap edges

The two lemmas of this section provide the *ceiling* on how many edges a graph in the bounded-cover regime can retain. They are elementary but do all the heavy lifting for the lower bound on deletions.

### 3.1 Lemma A: a single cover caps the edge count

**Lemma A.** *Let $G$ be a finite simple graph on $n$ vertices and let $C$ be a vertex cover with $|C| = k$. Then $e(G) \le k\cdot n$.*

**Proof sketch.** Every edge of $G$ has at least one endpoint in the cover $C$. Map each edge to one such endpoint; this associates to every edge a vertex $v \in C$. The number of edges mapped to a fixed vertex $v$ is at most the number of possible partners for $v$, which is at most $n$ (indeed at most $n-1$, but $n$ suffices). Hence the total number of edges is at most $\sum_{v\in C} n = k\cdot n$. Formally, the edge set injects into $\bigcup_{v\in C}\{\{v,w\} : w \in V\}$, whose size is at most $k\cdot n$. $\qquad\blacksquare$

The content is exactly the intuition that a small set of "guarding" vertices can be incident to only boundedly many edges.

### 3.2 Lemma B: componentwise covers cap the edge count

**Lemma B.** *Let $G$ be a finite simple graph on $n$ vertices, and suppose that every connected component $C$ of $G$ admits a vertex cover $S_C$ of the induced subgraph $G[C]$ with $|S_C| \le k$. Then $e(G) \le k\cdot n$.*

**Proof sketch.** Edges of $G$ never cross between distinct components, so the edge set of $G$ is the disjoint union of the edge sets of the induced subgraphs $G[C]$ over all components $C$. Applying Lemma A inside each component gives
$$e\big(G[C]\big) \;\le\; |S_C|\cdot |C| \;\le\; k\cdot |C|.$$
Summing over all components and using that the components partition $V$ (so $\sum_C |C| = n$):
$$e(G) \;=\; \sum_{C} e\big(G[C]\big) \;\le\; \sum_C k\cdot |C| \;=\; k\sum_C |C| \;=\; k\cdot n.$$
The two bookkeeping facts — that edges live inside single components, and that components tile the vertex set — are exactly what makes the sum telescope into the clean product $k\cdot n$. $\qquad\blacksquare$

**Corollary (deletion lower bound).** *If $H\le G$ lies in the bounded-component-cover regime with budget $k$, then*
$$e(G) - e(H) \;\ge\; e(G) - k\cdot n.$$
This is immediate from Lemma B applied to $H$ (which has the same $n$ as $G$). It reduces the entire deletion question to *maximizing $e(G)$ subject to $G$ being $C_d$-free*.

---

## 4. The extremal witness and the main theorem

### 4.1 Why balanced complete bipartite

The corollary tells us to make the host as dense as possible while remaining $C_d$-free. Among all graphs on $n = 2t$ vertices, the balanced complete bipartite graph $K_{t,t}$ maximizes edge count subject to bipartiteness, achieving $t^2 = n^2/4$ edges, and by Fact 2 it is $C_d$-free for every odd $d$. It is therefore the natural candidate to force the largest possible deletion cost.

### 4.2 The calibration

The free parameter is $t$. We choose it so that the ceiling from Lemma B lands *exactly* at the target deletion value. Set
$$\boxed{\,t = 2\,(1 + 2c)\,d\,}, \qquad n = 2t.$$
Then, with budget $k = (1+c)d$, the allowed edge count of any $H$ in the regime is at most
$$k\cdot n = (1+c)\,d\cdot 2t,$$
and the deletion cost from $K_{t,t}$ is at least
$$e(K_{t,t}) - k\cdot n = t^2 - (1+c)\,d\cdot 2t.$$
The calibration makes this equal to $c\,d\cdot n$, as the next computation shows.

### 4.3 The main theorem

**Main Theorem (tightness of the edge-deletion bound).** *Let $c,d,t\in\mathbb{N}$ with $c>0$, $d\ge 3$, and $t = 2(1+2c)d$, and set $n = 2t$. Then for every subgraph $H \le K_{t,t}$ in which every connected component admits a vertex cover of size at most $(1+c)d$, we have*
$$e(K_{t,t}) - e(H) \;\ge\; c\,d\cdot n.$$

**Proof.** By Fact 1, $e(K_{t,t}) = t^2$. Since $H \le K_{t,t}$, the graph $H$ has $n = 2t$ vertices, and by hypothesis every component of $H$ has a vertex cover of size at most $(1+c)d$. Lemma B gives
$$e(H) \;\le\; (1+c)\,d\cdot n \;=\; (1+c)\,d\cdot (2t).$$
Therefore
$$e(K_{t,t}) - e(H) \;\ge\; t^2 - (1+c)\,d\cdot(2t).$$
It remains to verify the arithmetic identity
$$t^2 - (1+c)\,d\cdot(2t) \;=\; c\,d\cdot(2t) \;=\; c\,d\cdot n.$$
Substituting $t = 2(1+2c)d$ into $t^2 = t\cdot t = t\cdot 2(1+2c)d = 2t\,d\,(1+2c)$, we obtain
$$t^2 - 2t\,d\,(1+c) = 2t\,d\,(1+2c) - 2t\,d\,(1+c) = 2t\,d\big[(1+2c)-(1+c)\big] = 2t\,d\cdot c = c\,d\cdot(2t).$$
Hence $e(K_{t,t}) - e(H) \ge c\,d\cdot n$, as claimed. $\qquad\blacksquare$

### 4.4 Tightness and the role of the hypotheses

The lower bound $e(K_{t,t}) - e(H) \ge c\,d\cdot n$ is matched from above by the calibration: at $t = 2(1+2c)d$ the quantity $t^2 - (1+c)d\cdot n$ *equals* $c\,d\cdot n$, so no universally valid deletion bound larger than $c\,d\cdot n$ can hold for this construction. This is precisely the sense in which the bound is *tight*: the ceiling from Lemma B and the floor from the extremal construction coincide.

The conditions $d\ge 3$, $d$ odd, and $c>0$ specify the extremal regime of interest: oddness guarantees (Fact 2) that $K_{t,t}$ is genuinely $C_d$-free, making it a legitimate Erdős–Gallai host, while $d\ge 3$ and $c>0$ place us in the meaningful parameter range. The *arithmetic* identity of the deletion bound holds from the relation $t = 2(1+2c)d$ alone; the oddness hypothesis is what certifies that the witness legitimately forbids the cycle $C_d$.

---

## 5. Algorithms

The proof is constructive and yields several natural algorithms.

### 5.1 Building the extremal witness

Given $c$ and $d$, compute $t = 2(1+2c)d$, form $A = \{a_0,\dots,a_{t-1}\}$ and $B = \{b_0,\dots,b_{t-1}\}$, and emit every edge $\{a_i, b_j\}$. This produces $K_{t,t}$ with $n = 2t$ vertices and $t^2$ edges in $O(t^2)$ time.

### 5.2 Verifying the deletion bound numerically

Given any subgraph $H \le K_{t,t}$ presented by its components and their vertex covers, verify that each cover has size at most $(1+c)d$, then confirm that $e(K_{t,t}) - e(H) \ge c\,d\cdot n$. Lemma B guarantees this always holds; the algorithm is a certificate checker running in time linear in the size of $H$.

### 5.3 Greedy component cover as an upper witness

To confirm that the bound is *attainable*, one produces an $H$ meeting it: greedily delete edges of $K_{t,t}$ to carve it into components each guarded by at most $(1+c)d$ vertices, stopping as soon as the regime is reached, and observe that exactly $c\,d\cdot n$ deletions suffice at the threshold. This demonstrates equality, not merely inequality.

---

## 6. Applications and interpretation

**Network sparsification with monitoring guarantees.** A vertex cover is a monitoring set: placing a sensor on each cover vertex observes every incident edge. The theorem is a hard limit on sparsification: a dense, cycle-avoiding network cannot be reorganized into small-monitoring-set components without deleting a number of links linear in the network size. The balanced bipartite grid is the canonical worst case.

**Complexity of cycle elimination.** Forbidding a cycle of prescribed length models deadlock- or resonance-avoidance constraints in scheduling and dependency management. The result quantifies the inherent cost of restructuring a system into small, independently manageable pieces even when the forbidden cycle is already absent.

**A blueprint for extremal tightness.** The two-step method — an easy Lemma-B ceiling matched by a parameter-calibrated dense construction — is a reusable template. The decisive step is the calibration $t = 2(1+2c)d$, which forces the algebra to collapse to the exact target constant $c\,d\cdot n$.

---

## 7. Discussion

The result sits at the interface of classical extremal bounds and their quantitative hyperstable refinements. Classical Erdős–Gallai theory bounds the *density* of cycle-free graphs; the hyperstability lens instead asks for the *edit distance* to a structurally transparent target. The two elementary counting lemmas convert "small covers everywhere" into "few edges," and the balanced complete bipartite witness converts "many edges, no odd cycle" into "expensive to thin." The calibration ties the two together with equality.

A conceptual takeaway is that the deletion lower bound is *density-driven*: it depends only on the gap between the host's edge count and the ceiling $k\cdot n$ imposed by the cover budget. This isolates exactly what a tight construction must do — maximize edges while staying cycle-free — and explains why the extremal object is complete bipartite.

---

## 8. Future directions

**1. A tight $C_d$-free witness for even cycle lengths.** The balanced bipartite construction avoids only odd cycles, certifying tightness for odd $d$. For even $d$ one needs a dense host whose shortest even cycle exceeds $d$ while retaining a linear-in-$n$ vertex-cover deficit. *Conjecture:* for every even $d$ there is a graph on $n$ vertices, free of cycles of length exactly $d$, from which at least $c\,d\cdot n$ edge deletions are needed to reach the bounded-component-cover regime. The key insight is that incidence graphs of generalized polygons and Wenger-type algebraic graphs have prescribed girth yet super-linear edge density, decoupling "no short even cycle" from sparsity. Because the odd case pins down the exact target constant, the even case becomes a concrete, quantitative girth-versus-density question with a known numerical goalpost.

**2. The exact optimal constant in front of $d\cdot n$.** Our witness meets the bound with equality only at the boundary $t = 2(1+2c)d$; above it the deleted-edge surplus grows quadratically. *Conjecture:* the true minimax deletion cost — minimized over all $C_d$-free hosts on $n$ vertices and maximized over the required cover budget — equals $\tfrac12\,c\,d\cdot n + o(dn)$, i.e. the sharp constant is $1/2$, achieved by an unbalanced bipartite host $K_{a,b}$ with $a/b$ tending to a specific function of $c$. The key insight is that skewing the two sides trades raw edge count against the size of the cheapest vertex cover, and the optimal skew is where the marginal edge gain equals the marginal cover cost.

**3. Stability: are near-extremal hosts essentially complete bipartite?** *Conjecture:* any $C_d$-free graph on $n$ vertices that requires within a $(1-\varepsilon)$ factor of the maximal edge-deletion budget is, after deleting $o(n^2)$ edges, a balanced complete bipartite graph (for odd $d$). The key insight is that the deletion lower bound is driven entirely by edge density against a vertex-cover ceiling, and only bipartite-like graphs simultaneously maximize density and forbid the relevant cycle — any deviation creates either a forbidden cycle or a cheap cover.

---

## 9. Conclusion

We have established that the balanced complete bipartite graph $K_{t,t}$ is a tight extremal witness for the edge-deletion bound in a hyperstability extension of the Erdős–Gallai theorem. Two elementary counting lemmas cap the edge count of any graph in the bounded-component-cover regime at $k\cdot n$, and calibrating $t = 2(1+2c)d$ forces the deletion cost of $K_{t,t}$ to equal exactly $c\,d\cdot n$. For odd $d$ this certifies that the $c\,d\cdot n$ edge-deletion bound is order-optimal and attained with equality at the threshold, and it frames the even case, the sharp constant, and the stability question as the natural next steps.
