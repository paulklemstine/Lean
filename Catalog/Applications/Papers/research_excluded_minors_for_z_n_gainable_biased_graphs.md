# Excluded Minors for $\mathbb{Z}/n$-Gainable Biased Graphs: The Parallel-Class Slice and a Divisibility Monotonicity Law

**Author:** Aristotle (Harmonic)
**Date:** 2026-06-28
**Domain:** Novelty — structural graph theory, biased graphs, gain graphs

---

## Abstract

A *biased graph* records, for each cycle of an underlying graph, whether that cycle is *balanced*. A *gain labelling* valued in an additive abelian group $A$ assigns a group element to each edge; it *realises* the biased graph when a cycle is balanced if and only if the signed sum of its edge labels vanishes. The graph is *gainable over $A$* when such a labelling exists, and $\mathbb{Z}/n$-*gainable* when $A = \mathbb{Z}/n$. The Zaslavsky/Funk conjecture predicts that for every $n \ge 2$ a biased graph is $\mathbb{Z}/n$-gainable if and only if it contains none of the minors $(n{+}1)K_2$, $\pm K_3$, or $-K_4$.

We give a complete, self-contained treatment of the **parallel-class (digon) slice** of this conjecture over an *arbitrary* finite cyclic group $\mathbb{Z}/n$, $n \ge 2$, whose unique excluded minor is $(n{+}1)K_2$. Three contributions stand out. First, we remove the primality hypothesis present in prior work: the pigeonhole obstruction and the digon characterization use only $|\mathbb{Z}/n| = n$, never any arithmetic property of $n$. Second, we establish a group-theoretic monotonicity principle, `gainableBy_of_injective_hom`: gainability is preserved by any injective additive homomorphism of the gain group. Specialised to cyclic groups it yields the **divisibility law** `gainable_mono_of_dvd`: if $m \mid n$ then every $\mathbb{Z}/m$-gainable biased graph is $\mathbb{Z}/n$-gainable. Third, we prove the parallel-class excluded-minor characterization `digon_excluded_minor` by reducing both gainability and the presence of a $(n{+}1)K_2$ minor to a single invariant, the number of balance classes, separated by complementary thresholds. All results are formalised and machine-checked.

---

## 1. Introduction

### 1.1 Background and motivation

Biased graphs, introduced by Zaslavsky, abstract the combinatorial content shared by signed graphs, gain graphs, and the frame matroids and Dowling geometries built from them. The data of a biased graph is a graph together with a distinguished collection of *balanced* cycles satisfying a natural theta-graph compatibility axiom. Gain graphs — graphs whose edges are labelled by elements of a group, with a cycle declared balanced when its signed product (here, signed sum, since we work additively) is the identity — are the prototypical source of biased graphs. The central representability question asks: given an abstract biased graph, does it arise from a gain labelling valued in a fixed group?

For a fixed finite cyclic group $\mathbb{Z}/n$, this becomes the question of $\mathbb{Z}/n$-gainability. Because gainability is closed under the appropriate minor relation, it is natural to seek an *excluded-minor characterization*: a finite list of forbidden minors whose avoidance is equivalent to gainability. The conjectured list for $\mathbb{Z}/n$ comprises three families:

$$\{(n{+}1)K_2,\ \pm K_3,\ -K_4\}.$$

Here $(n{+}1)K_2$ is the $n{+}1$-fold parallel edge with all digons unbalanced; $\pm K_3$ and $-K_4$ are fixed signed-graph configurations on three and four vertices respectively.

### 1.2 Contributions

We resolve the $(n{+}1)K_2$ component of this conjecture completely and uniformly in $n$, and we develop the surrounding group-theoretic monotonicity theory.

1. **Primality elimination.** Earlier formal and informal treatments of the parallel-class case assumed $n = p$ prime. We show primality is never used; the proofs need only $\mathrm{NeZero}\,n$, equivalently $|\mathbb{Z}/n| = n$.

2. **Monotonicity under injective homomorphisms** (`gainableBy_of_injective_hom`). Abstracting the gain group to an arbitrary `AddCommGroup`, we show that an injective additive homomorphism $A \hookrightarrow B$ transports gainability from $A$ to $B$.

3. **The divisibility law** (`gainable_mono_of_dvd`). Constructing an explicit injective homomorphism $\mathbb{Z}/m \hookrightarrow \mathbb{Z}/n$ whenever $m \mid n$, we deduce that $m \mid n$ implies every $\mathbb{Z}/m$-gainable graph is $\mathbb{Z}/n$-gainable.

4. **The parallel-class characterization** (`digon_excluded_minor`). For any parallel-class biased graph over any edge type, $\mathbb{Z}/n$-gainability is equivalent to the absence of a $(n{+}1)K_2$ minor, for every $n \ge 2$.

All statements are fully proved with no unproven assumptions beyond the standard logical axioms.

---

## 2. Definitions

Throughout, $E, F$ denote types of edges, and $A, B$ denote additive abelian groups.

### 2.1 Oriented walks and signed sums

An **oriented closed walk** is a list $c$ of pairs $(e, b)$ where $e \in E$ is an edge and $b \in \{\texttt{true}, \texttt{false}\}$ is a traversal direction. The **signed sum** of a gain labelling $g : E \to A$ around $c$ is

$$\text{signedSum}(g, c) \;=\; \sum_{(e,b)\,\in\, c} \begin{cases} g(e) & \text{if } b = \texttt{true},\\[2pt] -\,g(e) & \text{if } b = \texttt{false}.\end{cases}$$

Formally:
> **Definition (`signedSum`).** For $g : E \to A$ and $c : \mathrm{List}(E \times \mathrm{Bool})$,
> $$\text{signedSum}(g, c) = \Big(\text{map}\,(\lambda (e,b).\ \text{if } b \text{ then } g(e) \text{ else } -g(e))\ c\Big).\text{sum}.$$

### 2.2 Biased graphs and gainability

> **Definition (`BiasedGraph`).** A biased graph on edge type $E$ is a pair of predicates on oriented closed walks: $\text{isCycle} : \mathrm{List}(E \times \mathrm{Bool}) \to \mathrm{Prop}$, designating which walks are cycles, and $\text{balanced} : \mathrm{List}(E \times \mathrm{Bool}) \to \mathrm{Prop}$, designating which are balanced.

This *cycle-only* model deliberately discards the vertex set, retaining exactly the data constrained by the gain condition. It suffices for the parallel-class theory; its limitations are discussed in §7.

> **Definition (`GainableBy`).** A biased graph $G$ on $E$ is **gainable over $A$** if there exists $g : E \to A$ such that for every cycle $c$,
> $$G.\text{balanced}(c) \iff \text{signedSum}(g, c) = 0.$$

> **Definition (`Gainable`).** $G$ is $\mathbb{Z}/n$-**gainable**, written $\text{Gainable}(n, G)$, when it is gainable over $\text{Gain}(n) := \mathbb{Z}/n$.

### 2.3 The minor relation

To transport walks across an edge map we switch orientations selectively.

> **Definition (`mapCycle`).** Given $\varphi : E \to F$ and $\sigma : E \to \mathrm{Bool}$,
> $$\text{mapCycle}(\varphi, \sigma, c) = \text{map}\,\big(\lambda (e,b).\ (\varphi(e),\ \sigma(e) \oplus b)\big)\ c,$$
> where $\oplus$ is exclusive-or.

> **Definition (`pullGain`).** The pullback of $g : F \to A$ along $(\varphi, \sigma)$ is
> $$\text{pullGain}(\varphi, \sigma, g)(e) = \text{if } \sigma(e) \text{ then } -g(\varphi(e)) \text{ else } g(\varphi(e)).$$

> **Definition (`IsMinor`).** $H$ (on $E$) is a **labelled minor** of $G$ (on $F$) if there exist $\varphi : E \to F$ and $\sigma : E \to \mathrm{Bool}$ with $\varphi$ injective such that for every cycle $c$ of $H$, $\text{mapCycle}(\varphi,\sigma,c)$ is a cycle of $G$, and $H.\text{balanced}(c) \iff G.\text{balanced}(\text{mapCycle}(\varphi,\sigma,c))$.

### 2.4 The two distinguished families

> **Definition (`parallelEdges`).** For $n \in \mathbb{N}$, the biased graph $n\,K_2$ on edge type $\mathrm{Fin}\,n$ has cycles exactly the digons $[(i,\texttt{true}),(j,\texttt{false})]$ for $i \ne j$, and **no** balanced cycle ($\text{balanced} \equiv \text{False}$).

The obstruction of interest is $(n{+}1)K_2 = \text{parallelEdges}(n+1)$.

> **Definition (`digonGraph`).** Given an equivalence relation (`Setoid`) $s$ on $E$, the parallel-class biased graph $\text{digonGraph}(s)$ has cycles the digons $[(i,\texttt{true}),(j,\texttt{false})]$ with $i \ne j$, and such a digon is balanced exactly when $s$ relates $i$ and $j$.

A parallel-class biased graph models a single parallel class of edges between two vertices; the balance relation $s$ partitions the edges into *balance classes*.

---

## 3. The transport theory: signed sums and homomorphisms

The technical backbone is that signed sums commute with additive homomorphisms.

> **Lemma 3.1 (`signedSum_addHom`).** Let $f : A \to_+ B$ be an additive group homomorphism, $g : E \to A$, and $c$ an oriented walk. Then
> $$\text{signedSum}(f \circ g,\ c) = f\big(\text{signedSum}(g, c)\big).$$

*Proof sketch.* Expand both sides by the definition of `signedSum`. The right side is $f$ applied to a list-sum, which equals the list-sum of $f$ applied termwise ($f$ preserves sums). The left side is the list-sum of $f(g(e))$ or $-f(g(e))$ termwise. Since $f(-x) = -f(x)$, the two termwise lists agree, so the sums agree. Formally one rewrites with `map_list_sum` and `List.map_map`, then applies `List.map_congr_left` and case-splits on the orientation bit. $\qquad\blacksquare$

> **Lemma 3.2 (`signedSum_mapCycle`).** For $\varphi : E \to F$, $\sigma : E \to \mathrm{Bool}$, $g : F \to A$, and any walk $c$,
> $$\text{signedSum}(\text{pullGain}(\varphi, \sigma, g),\ c) = \text{signedSum}(g,\ \text{mapCycle}(\varphi, \sigma, c)).$$

*Proof sketch.* Both sides expand to list-sums over $c$. Comparing termwise, the contribution of edge $(e,b)$ on the left is $\pm \text{pullGain}(\dots)(e)$ and on the right is $\pm g(\varphi(e))$ with the orientation $\sigma(e)\oplus b$. A four-way case split on $(\sigma(e), b)$ shows the signs match in every case (the negation in `pullGain` exactly compensates the xor flip). $\qquad\blacksquare$

### 3.1 Minor-closedness

> **Theorem 3.3 (`gainableBy_of_isMinor`).** If $G$ is gainable over $A$ and $H$ is a labelled minor of $G$, then $H$ is gainable over $A$.

*Proof sketch.* Let $g$ realise $G$ and let $(\varphi, \sigma)$ witness $H \le_m G$. Set $g' = \text{pullGain}(\varphi, \sigma, g)$. For a cycle $c$ of $H$: by the minor definition, $H.\text{balanced}(c) \iff G.\text{balanced}(\text{mapCycle}(\varphi,\sigma,c))$; by realisation of $G$, the latter is $\iff \text{signedSum}(g, \text{mapCycle}(\varphi,\sigma,c)) = 0$; by Lemma 3.2 this equals $\text{signedSum}(g', c) = 0$. Hence $g'$ realises $H$. $\qquad\blacksquare$

The $\mathbb{Z}/n$ instance is the statement that $\text{Gainable}(n,\cdot)$ is minor-closed.

### 3.2 Monotonicity under injective homomorphisms

> **Theorem 3.4 (`gainableBy_of_injective_hom`).** Let $f : A \to_+ B$ be an injective additive homomorphism. If $G$ is gainable over $A$, then $G$ is gainable over $B$.

*Proof sketch.* Let $g : E \to A$ realise $G$ over $A$. Define $g_B = f \circ g : E \to B$. For each cycle $c$, by Lemma 3.1, $\text{signedSum}(g_B, c) = f(\text{signedSum}(g, c))$. Since $f$ is injective and $f(0) = 0$, we have $f(\text{signedSum}(g, c)) = 0 \iff \text{signedSum}(g, c) = 0$. Chaining with the realisation of $g$ over $A$:
$$G.\text{balanced}(c) \iff \text{signedSum}(g,c) = 0 \iff \text{signedSum}(g_B,c) = 0,$$
so $g_B$ realises $G$ over $B$. $\qquad\blacksquare$

This is the conceptual heart: gainability sees the gain group only through which signed sums vanish, and an injective homomorphism preserves exactly that.

---

## 4. The divisibility law

> **Lemma 4.1 (`exists_injective_zmod_addHom_of_dvd`).** If $m \mid n$ then there exists an injective additive homomorphism $\mathbb{Z}/m \to_+ \mathbb{Z}/n$.

*Proof sketch.* Write $n = m \cdot k$ with $k = n/m$. Multiplication by $k$ induces a well-defined additive homomorphism $\iota : \mathbb{Z}/m \to \mathbb{Z}/n$, sending the class of $j$ to the class of $j k$. (Well-definedness: if $j \equiv j' \pmod m$ then $jk \equiv j'k \pmod{mk = n}$.) Injectivity: if $jk \equiv 0 \pmod{n} = mk$, then $n \mid jk$, i.e. $mk \mid jk$, so $m \mid j$, i.e. $j \equiv 0 \pmod m$. As an additive homomorphism between finite groups of orders $m$ and $n$ with $m \le n$, injectivity is exactly the kernel-triviality just shown. $\qquad\blacksquare$

> **Theorem 4.2 (Divisibility law, `gainable_mono_of_dvd`).** If $m \mid n$ then every $\mathbb{Z}/m$-gainable biased graph is $\mathbb{Z}/n$-gainable:
> $$m \mid n \ \Longrightarrow\ \big(\text{Gainable}(m, G) \Rightarrow \text{Gainable}(n, G)\big).$$

*Proof.* Combine Lemma 4.1 with Theorem 3.4: the injective homomorphism $\mathbb{Z}/m \hookrightarrow \mathbb{Z}/n$ transports any realisation over $\mathbb{Z}/m$ to a realisation over $\mathbb{Z}/n$. $\qquad\blacksquare$

**Remark (concrete example).** For $m = 3$, $n = 12$ ($k = 4$), the embedding sends $0,1,2 \mapsto 0,4,8$. A three-class parallel graph untangled with labels in $\{0,1,2\}$ mod $3$ becomes untangled with labels in $\{0,4,8\}$ mod $12$. Note the law is genuinely about divisibility, not size: $\mathbb{Z}/3$ does **not** embed homomorphically into $\mathbb{Z}/4$ despite $3 < 4$, because $3 \nmid 4$.

---

## 5. The obstruction $(n{+}1)K_2$

> **Theorem 5.1 (`parallelEdges_not_gainable`).** For every $n \ge 2$ (i.e. $\mathrm{NeZero}\,n$ with $n \ge 2$), the biased graph $(n{+}1)K_2 = \text{parallelEdges}(n+1)$ is not $\mathbb{Z}/n$-gainable.

*Proof sketch.* Suppose $g : \mathrm{Fin}(n+1) \to \mathbb{Z}/n$ realised it. For distinct $i, j$, the digon $[(i,\texttt{true}),(j,\texttt{false})]$ is a cycle and is **unbalanced** (balance is identically false). Realisation forces $\text{signedSum}(g, \cdot) = g(i) - g(j) \ne 0$, i.e. $g(i) \ne g(j)$. Thus $g$ is injective on a domain of size $n+1$ into a codomain $\mathbb{Z}/n$ of size $n$ — impossible by pigeonhole (`Fintype.card_le_of_injective` gives $n+1 \le n$). $\qquad\blacksquare$

Crucially, the only fact about $n$ used is $|\mathbb{Z}/n| = n$; primality plays no role. This is the precise sense in which the result is *primality-free*.

> **Theorem 5.2 (General necessity, `not_isMinor_parallelEdges_of_gainable`).** Any $\mathbb{Z}/n$-gainable biased graph (on any edge type) contains no $(n{+}1)K_2$ minor.

*Proof.* If it contained such a minor, minor-closedness (Theorem 3.3) would make $(n{+}1)K_2$ gainable, contradicting Theorem 5.1. $\qquad\blacksquare$

---

## 6. The parallel-class characterization

We reduce everything to one invariant: the number of balance classes $|\text{Quotient}(s)|$.

> **Lemma 6.1 (Realisation rephrasing, `digon_gainable_iff_realises`).** $\text{digonGraph}(s)$ is gainable over $\mathbb{Z}/n$ iff there is $g : E \to \mathbb{Z}/n$ with $s(i,j) \iff g(i) = g(j)$ for all $i, j$.

*Proof sketch.* Unwind gainability on digons. The cycle $[(i,\texttt{true}),(j,\texttt{false})]$ has signed sum $g(i) - g(j)$, which is $0$ iff $g(i) = g(j)$; and it is balanced iff $s(i,j)$. The reflexive case $i = j$ is handled separately and holds trivially. $\qquad\blacksquare$

> **Theorem 6.2 (`digon_gainable_iff_card`).** For finite $E$ and $n \ge 2$,
> $$\text{Gainable}(n, \text{digonGraph}(s)) \iff |\text{Quotient}(s)| \le n.$$

*Proof sketch.* ($\Rightarrow$) From Lemma 6.1, $g$ satisfies $g(i) = g(j) \iff s(i,j)$, so $g$ descends to an **injective** map $\text{Quotient}(s) \to \mathbb{Z}/n$ (send a class to the $g$-value of any representative). Pigeonhole gives $|\text{Quotient}(s)| \le |\mathbb{Z}/n| = n$. ($\Leftarrow$) If $|\text{Quotient}(s)| \le n = |\mathbb{Z}/n|$, choose an injection $\bar g : \text{Quotient}(s) \to \mathbb{Z}/n$ and set $g(e) = \bar g([e])$. Then $g(i) = g(j) \iff [i] = [j] \iff s(i,j)$, and Lemma 6.1 applies. $\qquad\blacksquare$

> **Theorem 6.3 (`digon_isMinor_iff_card`).** For finite $E$,
> $$\text{IsMinor}\big((n{+}1)K_2,\ \text{digonGraph}(s)\big) \iff n + 1 \le |\text{Quotient}(s)|.$$

*Proof sketch.* ($\Rightarrow$) A minor witness $(\varphi,\sigma)$ sends each unbalanced digon of $(n{+}1)K_2$ to an unbalanced digon of $\text{digonGraph}(s)$; unwinding shows that for $a \ne b$ in $\mathrm{Fin}(n+1)$, $\varphi(a)$ and $\varphi(b)$ are non-equivalent under $s$. Hence $a \mapsto [\varphi(a)]$ is injective $\mathrm{Fin}(n+1) \to \text{Quotient}(s)$, giving $n+1 \le |\text{Quotient}(s)|$. ($\Leftarrow$) Given $n+1 \le |\text{Quotient}(s)|$, pick an injection $\psi : \mathrm{Fin}(n+1) \to \text{Quotient}(s)$ and define $\varphi(i)$ to be a representative of $\psi(i)$, with $\sigma \equiv \texttt{false}$. Distinct $i,j$ map to distinct, non-equivalent edges, so every (unbalanced) digon of $(n{+}1)K_2$ maps to an (unbalanced) digon of $\text{digonGraph}(s)$, verifying the minor conditions. $\qquad\blacksquare$

> **Theorem 6.4 (Excluded-minor characterization, `digon_excluded_minor`).** For finite $E$ and $n \ge 2$,
> $$\text{Gainable}(n, \text{digonGraph}(s)) \iff \neg\,\text{IsMinor}\big((n{+}1)K_2,\ \text{digonGraph}(s)\big).$$

*Proof.* By Theorem 6.2 the left side is $|\text{Quotient}(s)| \le n$; by Theorem 6.3 the minor condition is $n+1 \le |\text{Quotient}(s)|$, whose negation is $|\text{Quotient}(s)| \le n$. The two coincide (`omega`). $\qquad\blacksquare$

Thus for the entire parallel-class family the single excluded minor $(n{+}1)K_2$ characterizes $\mathbb{Z}/n$-gainability, uniformly for every $n \ge 2$.

---

## 7. Discussion

### 7.1 What the cycle-only model can and cannot see

The abstraction `BiasedGraph` records only cycles and their balance, discarding the vertex set. This is exactly enough to express the gain condition, and it suffices to capture $(n{+}1)K_2$, whose obstruction is a pure counting fact about digons. It is, however, provably *blind* to the remaining conjectured obstructions $\pm K_3$ and $-K_4$. Those configurations encode contradictions that live not in any single cycle but in the way several incident triangles share vertices — information the model deliberately omits. Detecting them requires an enriched model carrying explicit incidence (vertex) data.

### 7.2 The role of arithmetic

Two complementary phenomena emerge. The $(n{+}1)K_2$ obstruction is *uniform and primality-free*: it depends on $n$ only through the cardinality $|\mathbb{Z}/n| = n$. By contrast, the *relationship between different moduli* is genuinely arithmetic: gainability climbs monotonically along the divisibility order via the embeddings $\mathbb{Z}/m \hookrightarrow \mathbb{Z}/n$ for $m \mid n$. The dependence on $n$ thus factors cleanly through the lattice $(\mathbb{N}_{\ge 1}, \mid)$ of cyclic groups, rather than through the primes individually.

### 7.3 Relation to prior work

The parallel-class result was previously available only for prime moduli. The present development shows the prime hypothesis is inessential and adds the homomorphism-monotonicity layer, which is new: it transports realisations across *different* groups via an explicitly constructed injective homomorphism, rather than re-deriving each case.

---

## 8. Algorithms

The constructive content yields effective procedures for parallel-class graphs.

**(A) Gainability test.** Given a finite parallel class with balance relation $s$ and a modulus $n$: compute the number of balance classes $q = |\text{Quotient}(s)|$ by union–find; return *gainable* iff $q \le n$ (Theorem 6.2). Complexity: near-linear in the number of edges via union–find with path compression.

**(B) Witness labelling.** If $q \le n$, enumerate the classes $C_1, \dots, C_q$ and assign label $i-1 \in \mathbb{Z}/n$ to every edge of class $C_i$. This realises the graph (Theorem 6.1/6.2).

**(C) Minor certificate.** If $q \ge n+1$, pick one representative edge from each of $n+1$ distinct classes; these $n+1$ pairwise non-equivalent edges form an explicit $(n{+}1)K_2$ minor (Theorem 6.3), certifying non-gainability.

**(D) Divisibility transport.** Given a witness over $\mathbb{Z}/m$ and $n$ with $m \mid n$, multiply every label by $k = n/m$ to obtain a witness over $\mathbb{Z}/n$ (Theorem 4.2).

---

## 9. Applications

- **Signed graphs and social balance.** Over $\mathbb{Z}/2$ the gain condition is the classical balance of signed graphs; gainability tests whether a network of agreements/conflicts splits consistently. The general-$n$ theory extends this to many-valued consistency.
- **Frame matroids and Dowling geometries.** $\mathbb{Z}/n$-gain graphs coordinatize the rank-$3$ Dowling geometry $Q_3(\mathbb{Z}/n)$ and related frame matroids; excluded-minor results feed directly into representability questions for these matroids.
- **Constraint consistency.** A parallel class encodes difference constraints "edge $e$ must/must-not agree with edge $f$" valued in $\mathbb{Z}/n$; Theorem 6.2 is a sharp feasibility criterion, and Algorithm (C) produces a minimal infeasibility certificate.

---

## 10. Future Directions

**C1. The full three-minor characterization for all $n \ge 2$.** Conjecture: a biased graph is $\mathbb{Z}/n$-gainable iff it contains none of $(n{+}1)K_2$, $\pm K_3$, $-K_4$. The counting part ($(n{+}1)K_2$) is now closed and $n$-uniform; the open frontier is the *fixed*, $n$-independent obstruction set $\{\pm K_3, -K_4\}$ from $3$- and $4$-vertex signed-graph geometry.

**C2. A vertexed biased-graph model.** Enriching `BiasedGraph` with explicit incidence data should make $\pm K_3$ and $-K_4$ first-class excluded minors detectable by a local certificate (a $3$- or $4$-vertex unbalanced configuration admitting no consistent gain).

**C3. Divisibility lattice of gainability classes.** Conjecture: $n \mapsto \{\text{graphs gainable over } \mathbb{Z}/n\}$ is a lattice homomorphism from $(\mathbb{N}_{\ge 1}, \mid)$ into the powerset lattice, with the $\mathrm{lcm}$ step supplied by the Chinese Remainder embedding $\mathbb{Z}/\mathrm{lcm} \hookrightarrow \mathbb{Z}/m \times \mathbb{Z}/k$.

**C4. Tightness (strictness) of the divisibility law.** Conjecture: for $m \nmid n$ with $m, n \ge 2$ there exists a biased graph gainable over $\mathbb{Z}/m$ but not over $\mathbb{Z}/n$, showing the monotonicity is strictly indexed by divisibility.

---

## 11. Conclusion

For every cyclic group $\mathbb{Z}/n$ with $n \ge 2$ — prime or composite — the parallel-class slice of the Zaslavsky/Funk excluded-minor conjecture holds with the single excluded minor $(n{+}1)K_2$, and gainability is monotone along divisibility of the modulus via explicit group embeddings. The counting obstruction is uniform and primality-free; the inter-modular structure is governed transparently by the divisibility lattice. The remaining frontier is sharply isolated to two fixed small minors, $\pm K_3$ and $-K_4$, requiring an incidence-aware model — a well-scoped target for future work.
