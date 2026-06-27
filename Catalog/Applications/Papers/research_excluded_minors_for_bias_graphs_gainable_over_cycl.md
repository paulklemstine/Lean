# Excluded Minors for $\mathbb{Z}/p$-Gainable Biased Graphs: A Self-Contained Treatment of the Parallel-Class Obstruction

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Novelty (Combinatorics / Matroid Theory / Graph Gains)

---

## Abstract

A *biased graph* is a graph equipped with a distinguished family of *balanced* cycles. A *$\mathbb{Z}/p$-gain labelling* assigns to each edge a value in the cyclic group $\mathbb{Z}/p$ so that a cycle is balanced exactly when the signed sum of its edge labels vanishes; a biased graph is *$\mathbb{Z}/p$-gainable* when such a labelling exists. We develop a deliberately minimalist, vertex-free model of biased graphs that records only oriented cycles and their balance, and we work with the *labelled minor* (weak-map) relation under which gain labellings pull back. Within this framework we establish three structural facts. First, the gain of a cycle is preserved under pull-back along a labelled-minor embedding (the *pull-back identity*). Second, $\mathbb{Z}/p$-gainability is closed under labelled minors. Third, the contrabalanced bundle $(p+1)K_2$ — two vertices joined by $p+1$ parallel edges, every digon unbalanced — fails to be $\mathbb{Z}/p$-gainable, by a pigeonhole argument. Combining these yields a universal necessary condition: no $\mathbb{Z}/p$-gainable biased graph contains a $(p+1)K_2$ minor. For the family of *parallel-class* biased graphs we obtain a complete excluded-minor characterisation: such a graph is $\mathbb{Z}/p$-gainable if and only if it contains no $(p+1)K_2$ minor, with both directions bridged by the number of balanced parallel classes. We situate this result inside the conjectured full characterisation, whose three excluded minors are $(p+1)K_2$, the balanced triangle $\pm K_3$, and the unbalanced four-cycle $-K_4$, and we explain why the remaining two obstructions belong to the deeper signed-graph / Dowling-geometry theory.

**Keywords:** biased graph, gain graph, $\mathbb{Z}/p$, excluded minor, minor-closed, pigeonhole, contrabalanced, signed sum, weak map, Dowling geometry, frame matroid.

---

## 1. Introduction

### 1.1 Motivation

Many networks carry *gains*: numerical quantities attached to oriented edges that accumulate, with sign, as one traverses a closed walk. Electrical potential differences, currency conversion factors, gauge-theoretic holonomies, and the $\pm$ signs of social balance theory are all instances. A recurring structural question is *realisability*: given only a prescription of which cycles "should" close up (balanced) and which "should not" (unbalanced), does there exist an assignment of gains reproducing exactly that prescription?

When the gains take values in the cyclic group $\mathbb{Z}/p$ for a prime $p$, realisability is a *minor-closed* property, and minor-closed properties of combinatorial objects are frequently governed by a finite set of forbidden substructures. The guiding conjecture for this work states:

> For every odd prime $p$, the class of biased graphs admitting a $\mathbb{Z}/p$-gain labelling is minor-closed, and its only excluded minors are the contrabalanced parallel bundle $(p+1)K_2$, the balanced triangle $\pm K_3$, and the unbalanced four-cycle $-K_4$.

This paper isolates and proves, completely and self-containedly, the part of this picture that admits an elementary, vertex-free combinatorial proof: the obstruction $(p+1)K_2$ and the resulting complete characterisation for the *parallel-class* (digon) family. The remaining two excluded minors require signed-graph and matroid-representability machinery and are discussed but not derived here.

### 1.2 Contributions

1. A minimalist, vertex-free formalisation of biased graphs (Section 2) recording only oriented cycles and their balance.
2. The *pull-back identity* (Theorem 4.1): the signed sum of a pulled-back gain equals the signed sum of the original gain on the image cycle.
3. *Minor-closedness* (Theorem 4.2 / Lemma B): $\mathbb{Z}/p$-gainability descends to labelled minors.
4. The *pigeonhole obstruction* (Theorem 5.1 / Lemma A): $(p+1)K_2$ is not $\mathbb{Z}/p$-gainable.
5. A *universal necessary condition* (Theorem 5.2): no $\mathbb{Z}/p$-gainable biased graph contains a $(p+1)K_2$ minor.
6. A *complete excluded-minor characterisation for parallel classes* (Theorem 6.3 / Lemma C + Theorem), via the parallel-class count.

---

## 2. Definitions and the model

### 2.1 Oriented walks and the vertex-free model

Let $E$ be a type (set) of *edges*. An **oriented walk** is a finite list
$$c = [(e_1, b_1), (e_2, b_2), \ldots, (e_k, b_k)], \qquad e_i \in E,\; b_i \in \{\text{true}, \text{false}\},$$
where the Boolean $b_i$ records the *direction of traversal* of edge $e_i$: `true` = forward, `false` = backward.

**Definition 2.1 (Biased graph).** A *biased graph* on edge type $E$ is a pair of predicates on oriented walks,
$$G = (\,G.\mathrm{isCycle},\ G.\mathrm{balanced}\,), \qquad G.\mathrm{isCycle},\ G.\mathrm{balanced} : \mathrm{List}(E \times \mathrm{Bool}) \to \mathrm{Prop},$$
where $G.\mathrm{isCycle}(c)$ asserts that $c$ is a cycle of the underlying graph and $G.\mathrm{balanced}(c)$ asserts that $c$ is balanced.

This abstraction discards the vertex set, retaining exactly the data the gain condition constrains. It is faithful for our purposes because gains interact with a graph only through its cycles and their orientations.

### 2.2 Gains and the signed sum

Fix a prime $p$ and write $\mathbb{Z}/p$ for the cyclic group of order $p$, which we call the **gain group**. A **$\mathbb{Z}/p$-gain labelling** is a function $g : E \to \mathbb{Z}/p$.

**Definition 2.2 (Signed sum).** The *signed sum* (gain) of an oriented walk $c$ under a labelling $g$ is
$$\mathrm{signedSum}(g, c) \;=\; \sum_{(e,\,b)\in c} \big[\, b \,?\, g(e) : -g(e) \,\big] \;\in\; \mathbb{Z}/p,$$
i.e. each forward edge contributes $+g(e)$ and each backward edge contributes $-g(e)$.

**Definition 2.3 (Realisation; gainability).** A labelling $g$ *realises* the biased graph $G$ if, for every cycle $c$,
$$G.\mathrm{balanced}(c) \iff \mathrm{signedSum}(g, c) = 0.$$
$G$ is **$\mathbb{Z}/p$-gainable** when some labelling realises it:
$$\mathrm{Gainable}_p(G) \;:\!\iff\; \exists\, g : E \to \mathbb{Z}/p,\ \forall c,\ G.\mathrm{isCycle}(c) \Rightarrow \big(G.\mathrm{balanced}(c) \iff \mathrm{signedSum}(g, c) = 0\big).$$

### 2.3 The labelled-minor relation

To transport walks between edge types we use an injection together with a per-edge orientation switch.

**Definition 2.4 (Walk transport).** Given $\varphi : E \to F$ and a switch $\sigma : E \to \mathrm{Bool}$, define the transported walk
$$\mathrm{mapCycle}(\varphi, \sigma)(c) \;=\; \big[\,(\varphi(e),\ \sigma(e) \oplus b) \;:\; (e,b) \in c\,\big],$$
where $\oplus$ denotes Boolean XOR: edge $e$ keeps its orientation when $\sigma(e) = \text{false}$ and reverses it when $\sigma(e) = \text{true}$.

**Definition 2.5 (Labelled minor / weak map).** A biased graph $H$ on $E$ is a *(labelled) minor* of a biased graph $G$ on $F$, written $H \preceq G$, if there exist an injection $\varphi : E \to F$ and a switch $\sigma : E \to \mathrm{Bool}$ such that
1. $\varphi$ is injective;
2. (cycles to cycles) for every $c$, $H.\mathrm{isCycle}(c) \Rightarrow G.\mathrm{isCycle}(\mathrm{mapCycle}(\varphi,\sigma)(c))$;
3. (balance matches) for every cycle $c$ of $H$, $H.\mathrm{balanced}(c) \iff G.\mathrm{balanced}(\mathrm{mapCycle}(\varphi,\sigma)(c))$.

**Definition 2.6 (Pull-back labelling).** Given $\varphi$, $\sigma$ and a labelling $g : F \to \mathbb{Z}/p$ on the larger graph, the *pull-back* labelling on $E$ is
$$\mathrm{pullGain}(\varphi, \sigma, g)(e) \;=\; \begin{cases} -\,g(\varphi(e)) & \text{if } \sigma(e) = \text{true},\\[2pt] \;\;\;g(\varphi(e)) & \text{if } \sigma(e) = \text{false}.\end{cases}$$

### 2.4 The principal examples

**Definition 2.7 (Contrabalanced parallel bundle $nK_2$).** For $n \in \mathbb{N}$, define the biased graph $\mathrm{parallelEdges}(n)$ on edge type $\mathrm{Fin}\,n = \{0,1,\ldots,n-1\}$ by
$$\mathrm{isCycle}(c) :\!\iff \exists\, i \neq j,\ c = [(i,\text{true}),(j,\text{false})], \qquad \mathrm{balanced}(c) :\!\iff \text{False}.$$
Its cycles are precisely the *digons* — out along edge $i$, back along edge $j$ — and **no** digon is balanced. This is the contrabalanced bundle $nK_2$; the case $n = p+1$ is the obstruction of interest.

**Definition 2.8 (Parallel-class biased graph).** A *parallel-class* biased graph has all edges joining the same two vertices, so its cycles are exactly the digons. A digon $[(i,\text{true}),(j,\text{false})]$ is balanced precisely when $i$ and $j$ lie in a common *balanced class*, i.e. when they are related by a fixed equivalence relation on the edge set. The bias is therefore encoded by the number of balanced classes, the **parallel-class count** $\kappa(G)$.

---

## 3. Overview of results

| Result | Statement | Lean name |
|---|---|---|
| Pull-back identity | $\mathrm{signedSum}(\mathrm{pullGain},c) = \mathrm{signedSum}(g, \mathrm{mapCycle}\,c)$ | `signedSum_mapCycle` |
| Minor-closedness (Lemma B) | $\mathrm{Gainable}_p(G) \wedge H \preceq G \Rightarrow \mathrm{Gainable}_p(H)$ | `gainable_of_isMinor` |
| Pigeonhole obstruction (Lemma A) | $(p+1)K_2$ is not $\mathbb{Z}/p$-gainable | `parallelEdges_not_gainable` |
| Universal necessity | gainable $\Rightarrow$ no $(p+1)K_2$ minor | `not_isMinor_parallelEdges_of_gainable` |
| Counting bridges | gainable $\iff \kappa \le p$; minor $\iff \kappa \ge p+1$ | `digon_gainable_iff_card`, `digon_isMinor_iff_card` |
| Excluded-minor theorem (Lemma C + Thm) | parallel-class: gainable $\iff$ no $(p+1)K_2$ minor | `digon_excluded_minor` |

---

## 4. The pull-back machinery

### 4.1 The pull-back identity

**Theorem 4.1 (Pull-back identity; `signedSum_mapCycle`).** For all $\varphi : E \to F$, $\sigma : E \to \mathrm{Bool}$, $g : F \to \mathbb{Z}/p$, and every oriented walk $c$,
$$\mathrm{signedSum}\big(\mathrm{pullGain}(\varphi,\sigma,g),\ c\big) \;=\; \mathrm{signedSum}\big(g,\ \mathrm{mapCycle}(\varphi,\sigma)(c)\big).$$

*Proof sketch.* Both sides are sums over the entries of $c$ of a per-entry contribution; it suffices to show the contributions agree entry by entry. Fix an entry $(e, b)$. The left side contributes
$$b \,?\, \mathrm{pullGain}(e) : -\mathrm{pullGain}(e),$$
while the right side, after applying $\mathrm{mapCycle}$, contributes
$$(\sigma(e)\oplus b) \,?\, g(\varphi(e)) : -g(\varphi(e)).$$
A four-way case split on $\sigma(e) \in \{\text{true},\text{false}\}$ and $b \in \{\text{true},\text{false}\}$ verifies equality in each case, because reversing an edge ($\sigma(e)=\text{true}$) and negating its label produce the same effect on a signed sum: e.g. for $\sigma(e)=\text{true}, b=\text{true}$ the left gives $\mathrm{pullGain}(e) = -g(\varphi(e))$ and the right gives $(\text{false})\,?\cdots = -g(\varphi(e))$. The remaining three cases are identical in spirit. $\qquad\blacksquare$

This identity is the structural engine: it says that "switch and pull back the label" is the exact inverse of "switch the orientation," so signed sums are an invariant of the labelled-minor embedding.

### 4.2 Minor-closedness

**Theorem 4.2 (Minor-closedness; Lemma B; `gainable_of_isMinor`).** If $\mathrm{Gainable}_p(G)$ and $H \preceq G$, then $\mathrm{Gainable}_p(H)$.

*Proof sketch.* Let $g$ realise $G$, and let $(\varphi,\sigma)$ witness $H \preceq G$. Take the pull-back labelling $g' = \mathrm{pullGain}(\varphi,\sigma,g)$ on $H$. For any cycle $c$ of $H$:
$$H.\mathrm{balanced}(c) \overset{(\mathrm{D2.5.3})}{\iff} G.\mathrm{balanced}(\mathrm{mapCycle}\,c) \overset{(g \text{ realises } G)}{\iff} \mathrm{signedSum}(g, \mathrm{mapCycle}\,c) = 0 \overset{(\mathrm{Thm\ 4.1})}{\iff} \mathrm{signedSum}(g', c) = 0,$$
using that $\mathrm{mapCycle}\,c$ is a cycle of $G$ (Definition 2.5.2). Hence $g'$ realises $H$. $\qquad\blacksquare$

Minor-closedness is precisely the structural prerequisite for an excluded-minor characterisation: the family of gainable biased graphs is downward closed under $\preceq$.

---

## 5. The obstruction $(p+1)K_2$

### 5.1 The pigeonhole obstruction

**Theorem 5.1 (Lemma A; `parallelEdges_not_gainable`).** For every prime $p$, the contrabalanced bundle $(p+1)K_2 = \mathrm{parallelEdges}(p+1)$ is *not* $\mathbb{Z}/p$-gainable.

*Proof sketch.* Suppose, for contradiction, that $g : \mathrm{Fin}(p+1) \to \mathbb{Z}/p$ realises $\mathrm{parallelEdges}(p+1)$. We show $g$ is injective. Take $i \neq j$. The digon $c = [(i,\text{true}),(j,\text{false})]$ is a cycle and is unbalanced (every digon is). Realisation gives
$$\text{False} = \mathrm{balanced}(c) \iff \mathrm{signedSum}(g, c) = 0,$$
so $\mathrm{signedSum}(g,c) = g(i) - g(j) \neq 0$, i.e. $g(i) \neq g(j)$. Thus $g$ is injective on a set of size $p+1$. But then $|\mathrm{Fin}(p+1)| = p+1 \le |\mathbb{Z}/p| = p$, a contradiction (pigeonhole). Hence no realising labelling exists. $\qquad\blacksquare$

The contrapositive form of the injectivity step is exactly the formal proof: an injection $g$ from a $(p+1)$-element type into $\mathbb{Z}/p$ forces $p+1 \le p$.

### 5.2 Universal necessity

**Theorem 5.2 (Universal necessity; `not_isMinor_parallelEdges_of_gainable`).** Every $\mathbb{Z}/p$-gainable biased graph $G$ (of any edge type) contains *no* $(p+1)K_2$ minor:
$$\mathrm{Gainable}_p(G) \;\Rightarrow\; \neg\,\big((p+1)K_2 \preceq G\big).$$

*Proof sketch.* If $(p+1)K_2 \preceq G$ and $G$ were gainable, then by minor-closedness (Theorem 4.2) the bundle $(p+1)K_2$ would itself be gainable, contradicting Theorem 5.1. $\qquad\blacksquare$

This is the necessity half of the excluded-minor characterisation, and it holds for arbitrary biased graphs, not merely parallel classes.

---

## 6. The complete characterisation for parallel classes

We now restrict to parallel-class biased graphs (Definition 2.8), where the bias is encoded by the parallel-class count $\kappa(G)$ = number of balanced classes. Two counting lemmas bridge gainability and the minor relation.

**Lemma 6.1 (Gainability by counting; `digon_gainable_iff_card`).** A parallel-class biased graph $G$ is $\mathbb{Z}/p$-gainable if and only if $\kappa(G) \le p$.

*Proof sketch.* ($\Leftarrow$) If there are $k \le p$ balanced classes, choose $k$ distinct values $v_1,\ldots,v_k \in \mathbb{Z}/p$ (possible since $k \le p = |\mathbb{Z}/p|$) and define $g(e) = v_{[e]}$ where $[e]$ is the class of $e$. Then for a digon $[(i,+),(j,-)]$,
$$\mathrm{signedSum}(g) = g(i) - g(j) = 0 \iff v_{[i]} = v_{[j]} \iff [i]=[j] \iff \text{digon balanced},$$
the middle step using that distinct classes carry distinct values. So $g$ realises $G$.
($\Rightarrow$) If $\kappa(G) \ge p+1$, pick representatives of $p+1$ distinct classes; their pairwise digons are all unbalanced, and a realising $g$ would have to take $p+1$ distinct values in $\mathbb{Z}/p$, impossible by pigeonhole (as in Theorem 5.1). $\qquad\blacksquare$

**Lemma 6.2 (Minor by counting; `digon_isMinor_iff_card`).** A parallel-class biased graph $G$ contains a $(p+1)K_2$ minor if and only if $\kappa(G) \ge p+1$.

*Proof sketch.* ($\Leftarrow$) Given $p+1$ distinct balanced classes, choose one edge from each; the injection $\varphi$ sending the $p+1$ abstract edges of $(p+1)K_2$ to these representatives, with trivial switch $\sigma \equiv \text{false}$, maps each digon to a digon between distinct classes, which is unbalanced — matching the all-unbalanced bias of $(p+1)K_2$. Hence $(p+1)K_2 \preceq G$.
($\Rightarrow$) A labelled-minor embedding of $(p+1)K_2$ injects $p+1$ edges into $G$ whose pairwise digons are all unbalanced; pairwise-unbalanced means pairwise-inequivalent, so these $p+1$ edges lie in $p+1$ distinct classes, giving $\kappa(G) \ge p+1$. $\qquad\blacksquare$

**Theorem 6.3 (Excluded-minor theorem for parallel classes; Lemma C + Theorem; `digon_excluded_minor`).** A parallel-class biased graph $G$ is $\mathbb{Z}/p$-gainable if and only if it contains no $(p+1)K_2$ minor:
$$\mathrm{Gainable}_p(G) \iff \neg\big((p+1)K_2 \preceq G\big).$$

*Proof sketch.* By Lemma 6.1, $\mathrm{Gainable}_p(G) \iff \kappa(G) \le p$. By Lemma 6.2, $(p+1)K_2 \preceq G \iff \kappa(G) \ge p+1$, whose negation is $\kappa(G) \le p$. Chaining the two equivalences gives the result. $\qquad\blacksquare$

This is a complete, vertex-free characterisation for the parallel-class family: both directions reduce to the single integer $\kappa(G)$ compared against $p$.

---

## 7. Algorithms

The constructive content of Section 6 yields explicit, low-complexity algorithms.

### 7.1 Gainability test for parallel classes

**Input:** a parallel-class biased graph given by its balance equivalence relation on $m$ edges; a prime $p$.
**Output:** `gainable?` and, if so, a realising labelling.

1. Compute the balanced classes (union–find over the $m$ edges).
2. Let $\kappa$ be the number of classes.
3. If $\kappa > p$, return *not gainable* (and a certificate: any $p+1$ class representatives form a $(p+1)K_2$ minor).
4. Else, enumerate the classes $0,1,\ldots,\kappa-1$ and set $g(e) = (\text{class index of } e) \bmod p$. Return *gainable* with labelling $g$.

**Complexity:** $O(m\,\alpha(m))$ for the union–find, then $O(m)$ to label; overall near-linear in the number of edges.

### 7.2 Excluded-minor certificate extraction

**Input:** a parallel-class biased graph with $\kappa > p$.
**Output:** an explicit $(p+1)K_2$ minor.

1. Identify $p+1$ distinct balanced classes.
2. Pick one representative edge from each: $e_0, \ldots, e_p$.
3. Return the injection $\varphi(i) = e_i$ with switch $\sigma \equiv \text{false}$; its $\binom{p+1}{2}$ digons are all unbalanced, certifying the minor.

**Complexity:** $O(m)$ to extract representatives; the certificate has $p+1$ edges.

### 7.3 Pull-back of a labelling along a minor

**Input:** a labelling $g$ on $G$, a minor embedding $(\varphi,\sigma)$ of $H$ into $G$.
**Output:** a labelling on $H$ realising $H$ (guaranteed by Theorem 4.2).

1. For each edge $e$ of $H$, set $g'(e) = -g(\varphi(e))$ if $\sigma(e)$ else $g(\varphi(e))$.
2. Return $g'$.

**Complexity:** $O(|E(H)|)$, a single pass.

---

## 8. Applications

- **Social balance ($p = 2$).** With $\mathbb{Z}/2$ gains, a signed graph is balanced-realisable iff its vertices split into two camps with all positive edges inside and all negative edges across — the Cartwright–Harary theorem. The obstruction $3K_2$ ($=(p+1)K_2$ for $p=2$) flags a parallel class with three mutually "different" relations, which cannot be 2-coloured.
- **Electrical and flow networks.** Gains model potential or impedance shifts; balanced cycles encode Kirchhoff-type closure. The excluded-minor test certifies, in near-linear time, when a prescribed pattern of loop-closures is inconsistent with any $\mathbb{Z}/p$ potential.
- **Discrete gauge theory.** $\mathbb{Z}/p$ gains are discrete connections; balance is trivial holonomy. The characterisation says exactly when a prescribed holonomy pattern arises from a flat $\mathbb{Z}/p$-connection on a parallel class.
- **Constraint satisfaction / scheduling.** Edge gains are offsets and balanced cycles are consistency constraints; a $(p+1)K_2$ minor is a human-readable certificate of an over-constrained (infeasible) specification.

---

## 9. Discussion: the full characterisation and its frontier

The parallel-class theorem is one panel of the conjectured full result. For every odd prime $p$, the class of $\mathbb{Z}/p$-gainable biased graphs is conjectured to have exactly three excluded minors:

1. $(p+1)K_2$ — the contrabalanced parallel bundle (proved here);
2. $\pm K_3$ — the *balanced triangle*: a 3-cycle whose prescribed bias cannot be realised by any three edge labels;
3. $-K_4$ — the *unbalanced four-cycle*: a four-vertex obstruction whose bias is unrealisable.

The first has the transparent pigeonhole proof above. The other two are intrinsically *vertex-dependent* and connect to **signed-graph theory** and **Dowling geometries**: the *frame matroid* of a $\mathbb{Z}/p$-gain graph is representable over the field $GF(p)$, and excluded minors for gainability correspond to excluded minors for $GF(p)$-representability of these rank-bounded matroids. A revealing numerical signature of this correspondence is the **threshold gap**:

- *Gain* realisability of the bundle $kK_2$ over $\mathbb{Z}/p$ has threshold $k \le p$ — the number of distinct points on the *affine line* $\mathbb{A}^1(\mathbb{Z}/p)$.
- *Matroid* representability of the associated rank-2 uniform matroid $U_{2,k}$ over $GF(p)$ has threshold $k \le p+1$ — the number of points on the *projective line* $\mathbb{P}^1(GF(p))$.

The gap of exactly one corresponds to the single "point at infinity," realised combinatorially by adjoining one balanced (joint) edge. This is precisely the affine-versus-frame dichotomy flagged in the future-directions programme.

---

## 10. Future work

The following precise, falsifiable conjectures extend the present results; each is a candidate for a follow-up formalisation.

- **C1 (Theta excluded minor, group-independent).** The theta graph (two vertices joined by three internally disjoint paths) with *exactly two* of its three cycles balanced is $A$-gainable for *no* nontrivial group $A$, because balance of the three theta-cycles satisfies the transitivity $(g_1=g_2 \wedge g_1=g_3)\Rightarrow g_2=g_3$, so "exactly two balanced" is unrealisable.
- **C2 (Sharp gain-count = falling factorial).** The number of contrabalanced $\mathbb{Z}/p$-gains on the bundle $CB(k) = kK_2$ equals $p!/(p-k)! = p^{\underline{k}}$ for $k \le p$ and $0$ for $k > p$; formally, $|\{g : \mathrm{Fin}\,k \to \mathbb{Z}/p \mid g \text{ injective}\}| = \mathrm{descFactorial}(p,k)$ (OEIS A008279).
- **C3 (Switching classes = first cohomology).** For a connected graph with $n$ vertices and $m$ edges, $\mathbb{Z}/p$-gain functions modulo switching biject with $(\mathbb{Z}/p)^{m-n+1}$ (the cycle-space dimension), and balance depends only on the switching class.
- **C4 (Affine vs. frame threshold dichotomy).** Adjoining a single balanced edge to $CB(k)$ raises the gainability threshold from $k \le p$ to $k \le p+1$; target: $\mathrm{Gainable}_p(CB(k)\cup\{\text{one balanced edge}\}) \iff k \le p+1$.
- **C5 (Prime vs. composite obstruction spectrum).** For composite $n$ the contrabalanced threshold for $\mathbb{Z}/n$ remains $k \le n$, but partial-bias realisability differs because $\mathbb{Z}/n$ has nontrivial subgroups; conjecture: a partial bias on $CB(k)$ with balanced-class sizes $(s_1,\ldots,s_t)$ is $\mathbb{Z}/n$-realisable iff $t \le n$, with enumeration governed by the subgroup lattice.

---

## 11. Conclusion

Working in a deliberately spare, vertex-free model, we proved that $\mathbb{Z}/p$-gainability of biased graphs is preserved by pulling gains back along labelled minors, hence is minor-closed; that the contrabalanced bundle $(p+1)K_2$ is not $\mathbb{Z}/p$-gainable by a pigeonhole argument; and consequently that no gainable biased graph contains a $(p+1)K_2$ minor. For parallel-class biased graphs we obtained the complete excluded-minor characterisation, with both directions controlled by the single parallel-class count. This is the elementary core of the conjectured three-obstruction theorem, whose remaining members $\pm K_3$ and $-K_4$ point toward the deeper Dowling-geometry and matroid-representability theory.

---

## References

- T. Zaslavsky, *Biased graphs. I. Bias, balance, and gains*, Journal of Combinatorial Theory, Series B, 47 (1989), 32–52.
- T. Zaslavsky, *Biased graphs. II. The three matroids*, Journal of Combinatorial Theory, Series B, 51 (1991), 46–72.
- F. Harary, *On the notion of balance of a signed graph*, Michigan Mathematical Journal, 2 (1953), 143–146.
- D. Cartwright and F. Harary, *Structural balance: a generalization of Heider's theory*, Psychological Review, 63 (1956), 277–293.
- T. A. Dowling, *A class of geometric lattices based on finite groups*, Journal of Combinatorial Theory, Series B, 14 (1973), 61–86.
