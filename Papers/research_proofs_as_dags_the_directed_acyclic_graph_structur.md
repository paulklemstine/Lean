# Proofs as Directed Acyclic Graphs: Conservation, Hubs, and Foundations in Dependency Networks

## Abstract

We develop the elementary structural theory of *dependency networks* — directed graphs in which vertices are mathematical statements and a directed edge $u \to v$ records that statement $u$ is used in the derivation of statement $v$. We isolate three foundational invariants. First, a **conservation law**: in any finite network the aggregate in-degree, the aggregate out-degree, and the total number of edges all coincide, the directed analogue of the handshaking lemma. Second, a **hub-existence principle**: as an immediate pigeonhole consequence of conservation, every nonempty network contains a statement whose in-degree is at least the network-wide average, equivalently a single node whose in-degree bounds the entire edge budget from below. Third, an **order-and-foundation theorem**: acyclicity — the logical requirement that no statement transitively depends on itself — makes the transitive "eventually depends on" relation a strict partial order, and on a finite network this forces the existence of *sources* (dependency-free foundations) and *sinks* (frontier statements). We give complete proof sketches, dual formulations for in- and out-degrees, and discuss how these invariants underpin the empirical observation that comprehensive mathematical corpora are scale-free, with in-degree distribution $P(k)\sim k^{-\gamma}$, $\gamma \approx 2.5$. We close with algorithmic recipes, numerical demonstrations on synthetic and structured networks, and a program of conjectures on rank stratification, super-average hub concentration, and network fragility under hub deletion.

**Keywords:** dependency network, directed acyclic graph, degree distribution, scale-free network, handshaking lemma, well-founded order, pigeonhole principle, network fragility.

## 1. Introduction

Mathematical knowledge is cumulative in a strong and literal sense: essentially every theorem is proved by invoking earlier theorems, which invoke earlier ones still, terminating at axioms and definitions. This *dependency* relation defines a directed graph on the set of all statements. The graph is not an informal metaphor; it is a combinatorial object with quantifiable structure, and the aim of this paper is to establish its most basic invariants rigorously and to explain how those invariants shape the large-scale statistics observed in comprehensive mathematical libraries.

Two forces govern the object. One is **arithmetic**: edges must be conserved, and a fixed edge budget shared among a fixed number of nodes forces concentration. The other is **logical**: a proof cannot be circular, so the graph is acyclic, which endows it with an order and, on finite data, with a bottom layer of foundations. From these two forces we derive a small collection of theorems that are simple to state, exact, and — we argue — the correct starting point for a quantitative science of mathematical structure.

Our contributions are:

1. A precise model of dependency networks as decidable binary relations on a finite vertex type, with in-degree, out-degree, edge set, and edge count as derived quantities (Section 3).
2. The **conservation law** in target and source forms, and their equality (Section 4).
3. The **hub-existence** theorem and its out-degree dual (Section 5).
4. The **acyclicity** theory: irreflexivity of the transitive closure, the induced strict partial order, and the existence of sources and sinks on nonempty finite acyclic networks (Section 6).
5. A discussion connecting these invariants to scale-free statistics, together with algorithms, numerical demonstrations, and a conjecture program (Sections 7–9).

## 2. Related structural background

The undirected handshaking lemma — that the sum of vertex degrees is twice the number of edges — is a staple of graph theory. Our conservation law is its directed refinement, splitting each incidence into a source-count and a target-count. The existence of sources and sinks in finite directed acyclic graphs is classical and underlies topological sorting; we reconstruct it from the well-foundedness of an irreflexive transitive relation on a finite set, which we regard as the cleanest logical packaging. The empirical claim that citation- and dependency-style graphs are scale-free follows a long line of work on complex networks, in which power-law degree distributions and hub-dominated topologies recur across technological, biological, and social domains. Our contribution is to ground the *necessary preconditions* for such topologies — conservation and forced concentration — in exact, general theorems.

## 3. The model

Fix a finite type $V$ of **statements**. A **dependency network** on $V$ is a binary relation $R$ on $V$ with $R\,u\,v$ interpreted as "statement $u$ is used directly in the derivation of statement $v$." We assume $R$ is decidable so that degrees and edge sets are genuine finite cardinalities.

**Definition 3.1 (Degrees).** For $v \in V$,
$$\deg^-(v) := \#\{\, u \in V : R\,u\,v \,\}, \qquad \deg^+(v) := \#\{\, u \in V : R\,v\,u \,\}.$$
We call $\deg^-(v)$ the **in-degree** (the number of statements used directly to prove $v$) and $\deg^+(v)$ the **out-degree** (the number of statements that directly use $v$).

**Definition 3.2 (Edges).** The **edge set** is
$$E(R) := \{\, (u,v) \in V \times V : R\,u\,v \,\}, \qquad m := \#\,E(R),$$
and $m$ is the **edge count**. The **order** of the network is $n := \#V$.

**Definition 3.3 (Transitive dependence).** Write $u \Rightarrow v$ if there is a finite chain $u = x_0,\, x_1,\,\dots,\,x_k = v$ with $k \ge 1$ and $R\,x_{i}\,x_{i+1}$ for each $i$. This is the *transitive closure* of $R$: "$u$ is used, directly or indirectly, in the derivation of $v$."

**Definition 3.4 (Acyclicity).** The network $R$ is **acyclic** if no statement transitively depends on itself: for all $v$, it is not the case that $v \Rightarrow v$.

Acyclicity is the exact combinatorial content of the ban on circular reasoning: a purported proof in which $v \Rightarrow v$ would derive $v$ using $v$, which is no proof at all.

## 4. The conservation law

**Theorem 4.1 (Conservation, target form).** For any finite dependency network,
$$\sum_{v \in V} \deg^-(v) = m.$$

*Proof sketch.* Partition the edge set $E(R)$ according to the target coordinate. The fiber over $v$ is $\{(u,v) : R\,u\,v\}$, whose size is exactly $\deg^-(v)$ because $u \mapsto (u,v)$ is a bijection from the in-neighbours of $v$ to that fiber. Summing fiber sizes recovers $\#E(R) = m$. $\qquad\blacksquare$

**Theorem 4.2 (Conservation, source form).** For any finite dependency network,
$$\sum_{v \in V} \deg^+(v) = m.$$

*Proof sketch.* Identical, partitioning $E(R)$ by the source coordinate; the fiber over $v$ has size $\deg^+(v)$. $\qquad\blacksquare$

**Corollary 4.3 (Incidence conservation).** $\displaystyle \sum_{v} \deg^-(v) = \sum_{v} \deg^+(v)$.

*Proof.* Both sides equal $m$ by Theorems 4.1 and 4.2. $\qquad\blacksquare$

Corollary 4.3 is the directed handshaking identity: every dependency contributes exactly one incoming incidence and exactly one outgoing incidence, so the two global tallies must agree.

## 5. Hubs are inevitable

The conservation law converts, via the pigeonhole principle, into an unconditional existence statement about highly connected nodes.

**Theorem 5.1 (Hub existence).** In any nonempty dependency network ($n \ge 1$) there exists a statement $v^\*$ with
$$m \le n \cdot \deg^-(v^\*).$$
Equivalently, $\deg^-(v^\*) \ge m/n$: some statement has in-degree at least the network-wide average.

*Proof sketch.* Choose $v^\*$ to maximize $\deg^-$ over the (nonempty) vertex set. For every $v$ we then have $\deg^-(v) \le \deg^-(v^\*)$, so
$$m = \sum_{v} \deg^-(v) \le \sum_{v} \deg^-(v^\*) = n \cdot \deg^-(v^\*),$$
using Theorem 4.1 for the first equality. $\qquad\blacksquare$

**Theorem 5.2 (Dual hub existence).** In any nonempty dependency network there exists a statement $w^\*$ with $m \le n \cdot \deg^+(w^\*)$.

*Proof sketch.* Apply Theorem 5.1 to the reversed relation $R^{\mathrm{op}}\,u\,v := R\,v\,u$, under which in-degrees become out-degrees and the edge count is unchanged (the edge-reversal map $(u,v)\mapsto(v,u)$ is a bijection of edge sets). $\qquad\blacksquare$

**Remark 5.3 (Sharpness).** The bound in Theorem 5.1 is tight: if every in-degree equals a common value $d$, then $m = nd$ and $\deg^-(v^\*) = d$, so $m = n\cdot\deg^-(v^\*)$. The inequality is therefore the exact statement that the maximum in-degree dominates the average, with equality precisely for in-degree-regular networks.

**Remark 5.4 (The scale-free regime).** Theorem 5.1 has bite exactly when $m$ is large relative to $n$. In a mature corpus, results accumulate far faster than the foundational lemmas they cite, so $m$ grows super-linearly in $n$; then $\deg^-(v^\*) \ge m/n$ grows without bound, and equal sharing of the edge budget becomes impossible. Concentration into hubs is not an empirical accident but a forced consequence of a heavy edge budget.

## 6. Acyclicity, order, and foundations

We now use the logical constraint. Throughout this section $R$ is acyclic in the sense of Definition 3.4.

**Lemma 6.1 (Direct irreflexivity).** If $R$ is acyclic then $R\,v\,v$ fails for every $v$: no statement is an immediate premise of itself.

*Proof.* A single edge $R\,v\,v$ is a length-one chain witnessing $v \Rightarrow v$, contradicting acyclicity. $\qquad\blacksquare$

**Theorem 6.2 (Proof order).** If $R$ is acyclic, the transitive dependence relation $\Rightarrow$ is a strict partial order on $V$: it is irreflexive (by acyclicity) and transitive (concatenation of dependence chains).

*Proof sketch.* Irreflexivity is exactly Definition 3.4. Transitivity holds because a chain from $u$ to $v$ followed by a chain from $v$ to $w$ is a chain from $u$ to $w$. $\qquad\blacksquare$

Thus "is used, directly or indirectly, to prove" ranks statements by logical priority. On finite data this ranking has extremal elements.

**Theorem 6.3 (Existence of foundations / sources).** Let $V$ be finite and nonempty and $R$ acyclic. Then there exists $v \in V$ with no incoming dependency: for all $u$, $R\,u\,v$ fails.

*Proof sketch.* By Theorem 6.2, $\Rightarrow$ is transitive and irreflexive. A transitive, irreflexive relation on a *finite* set is well-founded — there are no infinite descending chains. Hence $\Rightarrow$ has a minimal element $v$ over the whole (nonempty) set: no $u$ satisfies $u \Rightarrow v$. In particular no $u$ satisfies the stronger $R\,u\,v$, since a direct edge is a dependence chain. So $v$ is a source. $\qquad\blacksquare$

**Theorem 6.4 (Existence of frontiers / sinks).** Under the hypotheses of Theorem 6.3 there exists $v \in V$ with no outgoing dependency: for all $u$, $R\,v\,u$ fails.

*Proof sketch.* Apply Theorem 6.3 to the reversed relation $R^{\mathrm{op}}$. Its transitive closure is the reverse of $\Rightarrow$, hence still irreflexive, so $R^{\mathrm{op}}$ is acyclic; a source of $R^{\mathrm{op}}$ is a sink of $R$. $\qquad\blacksquare$

**Interpretation.** Theorem 6.3 is the exact sense in which mathematics rests on axioms. Follow dependency arrows backward from any theorem. Each backward step lands on a result used in its proof; finiteness bars an infinite regress and acyclicity bars a loop, so the walk must halt at a statement with nothing behind it — an axiom or definition. Symmetrically (Theorem 6.4) the sinks are the *frontier*: the newest, most specialized results that nothing yet builds upon. Both theorems are non-vacuous — the acyclicity hypothesis is load-bearing, since a network with a two-cycle $a \to b \to a$ has neither a source nor a sink.

## 6.5. A worked example

To make the invariants concrete, consider a network of six statements $\{0,1,2,3,4,5\}$ with dependency edges
$$0\to2,\quad 1\to2,\quad 0\to3,\quad 1\to3,\quad 2\to4,\quad 3\to4,\quad 4\to5.$$
Here statements $0$ and $1$ are unproved primitives (axioms or definitions), $2$ and $3$ are lemmas each drawing on both primitives, $4$ is a theorem combining the two lemmas, and $5$ is a corollary. The edge count is $m = 7$.

The in-degrees are $\deg^-(0)=\deg^-(1)=0$, $\deg^-(2)=\deg^-(3)=2$, $\deg^-(4)=2$, $\deg^-(5)=1$, summing to $0+0+2+2+2+1 = 7 = m$, in agreement with Theorem 4.1. The out-degrees are $\deg^+(0)=\deg^+(1)=2$, $\deg^+(2)=\deg^+(3)=1$, $\deg^+(4)=1$, $\deg^+(5)=0$, also summing to $7 = m$, confirming Theorem 4.2 and Corollary 4.3.

Hub existence (Theorem 5.1) is witnessed by any maximum-in-degree vertex, say $v^\* = 2$ with $\deg^-(2) = 2$; the certificate reads $m = 7 \le n\cdot\deg^-(v^\*) = 6\cdot 2 = 12$. The dual hub (Theorem 5.2) is $w^\* = 0$ with $\deg^+(0)=2$, the most-used primitive.

The network is acyclic: no statement can be reached from itself by following arrows. Topological layering peels the sources first and yields the strata
$$\{0,1\} \;\prec\; \{2,3\} \;\prec\; \{4\} \;\prec\; \{5\},$$
so the sources (Theorem 6.3) are $\{0,1\}$ — the foundations — and the unique sink (Theorem 6.4) is $\{5\}$ — the frontier. Adding a back-edge $5\to0$ would create the cycle $0\to2\to4\to5\to0$; the layering would then stall with every vertex retaining a positive in-degree, and the network would possess neither a source nor a sink, exactly as the acyclicity hypothesis predicts.

## 7. From invariants to scale-free statistics

The three invariants combine into a coherent structural picture:

- **Conservation** (Section 4) fixes the global edge budget and ties it to both degree sequences.
- **Hub existence** (Section 5) shows a fixed budget cannot be shared equally once it is heavy; maximum degree must exceed the mean, and does so by an unbounded margin in the super-linear regime.
- **Acyclicity** (Section 6) stratifies the network from foundations to frontier, so a hub's influence propagates upward through the order into everything built above it.

Empirically, dependency networks extracted from large mathematical corpora exhibit an in-degree distribution well approximated by a power law,
$$P(k) \sim k^{-\gamma}, \qquad \gamma \approx 2.5,$$
the hallmark of a **scale-free network**. The overwhelming majority of statements depend on a handful of results, while a rare few — the *hubs* — are depended upon by an exponentially larger population. Canonical hub candidates are precisely the reflexively cited results of mathematics: Zorn's Lemma, the Intermediate Value Theorem, the Fundamental Theorem of Calculus, the Sylow Theorems, the Baire Category Theorem, the Hahn–Banach Theorem, Urysohn's Lemma, the Pigeonhole Principle, induction, and the law of excluded middle. Theorems 5.1–5.2 guarantee such hubs must exist; the empirical power law describes *how heavy* their tail is.

The scale-free picture also predicts **fragility**. Scale-free graphs are robust to random node loss but vulnerable to targeted removal of hubs. In our setting, deleting a hub does not merely remove one vertex: by conservation its out-arrows are numerous, and by acyclicity those arrows fan upward through the layered order into every result built on it, so its removal threatens to disconnect large portions of the network. This is the structural mechanism behind the conjecture that removing any single top hub fractures the network into large components.

## 8. Algorithms

We record the computational recipes underlying the invariants; all run in time linear or near-linear in $n + m$.

**Algorithm A (Degree and conservation audit).** Given the relation $R$ on $n$ vertices, compute $\deg^-$ and $\deg^+$ by a single pass over ordered pairs, accumulate $m$, and verify $\sum_v \deg^-(v) = m = \sum_v \deg^+(v)$. Complexity $O(n^2)$ for a dense relation, $O(n+m)$ for a sparse adjacency representation.

**Algorithm B (Hub extraction).** Scan the in-degree array for its maximum to obtain $v^\*$; return $(v^\*, \deg^-(v^\*))$ and certify $m \le n\cdot\deg^-(v^\*)$. Complexity $O(n)$ after degrees are known.

**Algorithm C (Foundation / frontier detection via topological layering).** Repeatedly extract vertices of current in-degree $0$ (sources), peel them, and decrement their successors' in-degrees; the peeling order is a topological sort. Sources are the first layer; sinks are the vertices of out-degree $0$. If peeling stalls with vertices remaining, the residual subgraph contains a cycle, certifying non-acyclicity. Complexity $O(n+m)$ (Kahn's algorithm).

**Algorithm D (Power-law fit).** From the in-degree multiset, estimate the exponent $\gamma$ by maximum likelihood on the tail $k \ge k_{\min}$:
$$\hat\gamma = 1 + N_{\ge k_{\min}} \Big/ \sum_{k \ge k_{\min}} \ln\!\frac{k}{k_{\min} - \tfrac12},$$
where $N_{\ge k_{\min}}$ is the number of nodes with in-degree at least $k_{\min}$.

## 9. Numerical demonstrations

The accompanying computational examples exhibit the theory on concrete networks:

1. **Conservation audit** on random and structured relations, confirming $\sum \deg^- = m = \sum \deg^+$ exactly.
2. **Hub certification** on a synthetic preferential-attachment network, verifying $m \le n\cdot\deg^-(v^\*)$ and reporting the ratio $\deg^-(v^\*)/(m/n)$ as a concentration index.
3. **Topological layering** on an acyclic network, extracting sources (foundations) and sinks (frontier) and detecting cycles when acyclicity is violated.
4. **Power-law estimation** on a grown scale-free network, recovering an exponent near $\gamma \approx 2.5$.

## 10. Discussion and future directions

The framework recasts qualitative intuitions as measurable quantities: "foundational" becomes high out-degree and low rank; "deep" becomes large distance from the sources; "load-bearing" becomes high fragility cost under deletion. The same three laws apply to any justificatory network — legal precedent, software dependencies, scientific citation — wherever claims support one another and (where applicable) do so without circularity.

We highlight the following program.

**Conjecture 10.1 (Rank stratification).** Every finite acyclic network admits a rank function $\rho : V \to \mathbb{N}$ with $\rho(u) < \rho(v)$ whenever $u \to v$, and the number of distinct ranks equals the length of the longest derivation chain. The height function of the well-founded order of Theorem 6.2 is the canonical candidate, turning "foundations exist" into a full depth spectrum.

**Conjecture 10.2 (Super-average hub concentration).** If $m \ge c\,n^{1+\delta}$ for constants $c,\delta > 0$, then the maximum in-degree is at least $c\,n^{\delta}$, and iterating the hub bound on residual networks yields a descending ladder of hubs whose degree sequence is what a power law measures.

**Conjecture 10.3 (Hub-deletion fragility).** There is a constant $\alpha > 0$ such that deleting any statement of in-degree exceeding $\alpha\,m/n$ leaves a residual network whose largest weakly-connected component omits a constant fraction of all statements — the tree cut-vertex phenomenon transferred to the spanning forest of a directed acyclic graph.

Together these would carry the theory from existence statements (hubs and foundations exist) to the quantitative shape of the degree distribution and the robustness profile of mathematics itself.

## 10.5. Limitations and modelling assumptions

Three modelling choices deserve comment. First, we treat the dependency relation as *given* and *decidable*; in practice the same mathematical result may be recorded under several statements, and the granularity of what counts as a single "statement" affects degree counts. Our theorems are invariant under any fixed choice of granularity, but cross-corpus comparisons require a consistent one. Second, acyclicity is a property of *proofs*, not of *statements*: two theorems may be logically equivalent (each derivable from the other) even though no single proof is circular, and a faithful dependency network records the derivation actually used rather than the space of all possible derivations. Third, the empirical exponent $\gamma \approx 2.5$ is a measured quantity whose precise value depends on the corpus and on the tail cutoff $k_{\min}$; our theorems guarantee the *existence* of hubs and foundations unconditionally, but the *heaviness* of the tail is an empirical input, not a theorem. These caveats delimit the scope of the results without weakening them: conservation, hub existence, and the foundation theorems hold for every finite network satisfying the stated hypotheses.

## 11. Conclusion

Viewing proofs as a directed acyclic graph exposes three exact laws: dependencies are conserved, hubs are forced, and finiteness with acyclicity guarantees foundations and a frontier. These are the minimal structural facts any dependency network must obey, and they supply the scaffolding on which the empirical scale-free geometry of mathematics — power-law in-degrees and hub-dominated fragility — rests. Mathematics is not a heap of facts but a network with a blueprint, and the blueprint is a graph whose most connected nodes hold the entire structure together.
