# The Emotional Chromatic Number: Thresholds, Sandwiches and Abundance for the Chromatic Counting Function of Social Networks

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

We develop a systematic theory of the chromatic counting function of a finite social network under an *emotional floor*: the convention, imported from affect psychology, that a meaningful palette contains at least three categories. For a finite simple graph $G$ on a population $V$ with $|V| = n$, let $P_G(q)$ denote the number of proper $q$-colorings ("emotionally consistent assignments"), and define the **emotional chromatic number** $\chi_E(G) = \min\{q \ge 3 : P_G(q) > 0\}$.

Our results fall into four groups. (i) A **structure theorem**, $\chi_E(G) = \max\{\chi(G),3\}$, which reduces the floored invariant to the classical chromatic number and shows it inherits isomorphism-invariance, edge-monotonicity and the disjoint-union law $\chi_E(G \sqcup H) = \max\{\chi_E(G),\chi_E(H)\}$. (ii) **Order-theoretic laws** for the counting function: antitonicity in the friendship relation, monotonicity in the palette, the universal floor $q^{\underline{n}} \le P_G(q)$, and a **threshold law** — for $q \ge 3$, $P_G(q) > 0 \iff \chi_E(G) \le q$ — which is what justifies calling $\chi_E$ "the number of emotions a network needs". (iii) A **sandwich theorem** $\max\{\omega(G),3\} \le \chi_E(G) \le \max\{\Delta(G)+1,3\}$, resting on a self-contained greedy bound $\chi(G) \le \Delta(G)+1$, together with a six-vertex witness (a wheel on a five-cycle) making both inequalities strict simultaneously. (iv) A **quantitative abundance theorem**: if every vertex has degree at most $d$ then $(q-d)^{n} \le P_G(q)$, sharp on the edgeless graph; consequently a hundred-person network of maximum degree five admits at least $5^{100}$ consistent ten-emotion assignments.

We also give a closed form for a family of "cliques with bystanders", $P(q) = q^{\underline{s}}q^{\,N-s}$ with $s=\min\{k,N\}$, and use it to carry out a census of one hundred networks: all have $\chi_E \in [3,6]$, with distribution $63/13/12/12$ over the values $3,4,5,6$ and total emotional load $373$. Finally, a Nordhaus–Gaddum style **conservation law** $n \le \chi_E(G)\chi_E(\overline{G})$ shows that emotional simplicity of a network forces emotional complexity of its complement: a hundred-person network with $\chi_E \le 6$ has $\chi_E(\overline{G}) \ge 17$.

Three pieces of folklore attached to the informal model are corrected: the chromatic polynomial does *not* vanish at $q=2$ for bipartite graphs (it vanishes there precisely for non-bipartite graphs with at least one edge); even friendship circles do *not* have $\chi_E = 2$ (the floor forces $\chi_E(C_n) = 3$ for all $n \ge 3$); and $\chi_E \le 6$ is *not* universal, as a seven-clique has $P(6) = 0$ and $\chi_E = 7$.

**Keywords:** chromatic polynomial, chromatic number, graph coloring, greedy bound, Nordhaus–Gaddum inequality, clique number, maximum degree, social networks.

---

## 1. Introduction

### 1.1 Motivation

The chromatic polynomial $P_G(q)$ of a finite graph $G$, introduced by Birkhoff in 1912, counts proper colorings: maps from vertices to a palette of $q$ colors such that adjacent vertices receive distinct colors. Its interpretations are numerous — map colorings, exam timetabling, frequency allocation, register allocation — but all share one feature: the palette is a set of *interchangeable* labels, and the graph encodes a hard "must differ" constraint.

We take up an interpretation in which the palette is *not* an abstract set of labels but a fixed, small, psychologically motivated list: the six basic emotions of the Ekman taxonomy (happiness, sadness, anger, fear, disgust, surprise). The vertices are people, the edges are friendships, and a proper coloring is an assignment of one emotion to each person such that no two friends display the same emotion — an **emotionally consistent assignment**. Then $P_G(6)$ counts the emotionally consistent assignments available to a social network, and the least admissible palette size measures the network's *emotional demand*.

Two questions organise the paper. First, *how many emotions does a network need?* Second, *given that it can be colored, how many ways are there?* The first is a threshold question about the support of $P_G$; the second is a quantitative question about its values. Our thesis is that both are controlled, in opposite directions, by the same local statistics — clique size and degree — and that the tension between them is the mathematically substantive content of the psychological reading.

### 1.2 The emotional floor

Affect models with fewer than three categories (valence alone: positive/negative) are regarded as degenerate in the psychological literature. We therefore impose a floor of three on the palette. This one convention has non-trivial mathematical consequences, and clarifying them is a recurring theme: it collapses the whole bipartite world to a single value, it erases the parity distinction between even and odd friendship circles at the level of the threshold (though not at the level of the counts), and it makes several natural statements *false without the hypothesis $q \ge 3$*.

### 1.3 Contributions

1. A structure theorem identifying the floored invariant with a truncation of the chromatic number (§3), with its functorial consequences.
2. Order-theoretic laws and a threshold law for the counting function (§4).
3. A self-contained greedy bound $\chi(G) \le \Delta(G) + 1$ and the resulting sandwich theorem, with a sharpness witness showing both inequalities can be strict at once (§5).
4. A counting refinement of the greedy argument giving the exponential abundance bound $(q-d)^n \le P_G(q)$ (§6).
5. A closed-form chromatic polynomial for cliques-with-bystanders and a census of one hundred networks (§7).
6. Nordhaus–Gaddum conservation laws and their emotional-duality consequences (§8).
7. A catalogue of corrected folklore (§9), algorithms (§10), applications (§11) and open conjectures (§12).

---

## 2. Definitions

Throughout, $V$ is a finite set (the **population**) with $|V| = n$, and $G$ is a finite simple graph on $V$: a symmetric, irreflexive relation $\sim_G$ (**friendship**). We write $\overline{G}$ for the complement (the **stranger network**), $\deg_G(v)$ for the number of friends of $v$, $\Delta(G) = \max_v \deg_G(v)$ for the **maximum degree**, and $\omega(G)$ for the **clique number**, the largest cardinality of a set of pairwise friends. $\chi(G)$ denotes the classical chromatic number, and $G \le H$ means $\sim_G\;\subseteq\;\sim_H$ (same vertex set, fewer friendships). $q^{\underline{m}} = q(q-1)\cdots(q-m+1)$ is the falling factorial, with $q^{\underline{m}} = 0$ when $m > q$.

**Definition 2.1 (Emotionally consistent assignment).** For $q \in \mathbb{N}$, a map $c : V \to \{1,\dots,q\}$ is *emotionally consistent* for $G$ if $c(x) \ne c(y)$ whenever $x \sim_G y$.

**Definition 2.2 (Chromatic counting function).** $P_G(q)$ is the number of emotionally consistent assignments $c : V \to \{1,\dots,q\}$.

$P_G$ agrees with the chromatic polynomial of $G$ evaluated at non-negative integers; we work only with these evaluations, so all statements are about a function $\mathbb{N} \to \mathbb{N}$ and no polynomiality is assumed anywhere.

**Definition 2.3 (Emotional chromatic number).** $\chi_E(G) = \min\{q \in \mathbb{N} : q \ge 3 \text{ and } P_G(q) > 0\}$.

The minimum is over a non-empty set: $q = n$ always works (color everyone differently), and $q = \max\{n,3\}$ certainly works, so $\chi_E(G)$ is well defined and $\chi_E(G) \le \max\{n,3\}$.

Two immediate facts, used constantly and recorded for reference:

- **(Floor)** $\chi_E(G) \ge 3$.
- **(Realisability)** $G$ admits an emotionally consistent assignment with $\chi_E(G)$ emotions; and if $q \ge 3$ and $G$ admits a consistent $q$-assignment then $\chi_E(G) \le q$.

---

## 3. The structure theorem

**Theorem 3.1 (Structure theorem).** For every finite social network $G$,
$$\chi_E(G) = \max\{\chi(G),\,3\}.$$

*Proof sketch.* ($\le$) Since $V$ is finite, $G$ admits a proper coloring with $\chi(G)$ colors; enlarging the palette to $\max\{\chi(G),3\}$ preserves properness, and $\max\{\chi(G),3\} \ge 3$, so realisability gives $\chi_E(G) \le \max\{\chi(G),3\}$. ($\ge$) By realisability, $G$ is $\chi_E(G)$-colorable, so $\chi(G) \le \chi_E(G)$; and $3 \le \chi_E(G)$ by the floor. Taking the maximum gives the reverse inequality. $\square$

Finiteness is load-bearing: for infinite graphs the chromatic number may be infinite while the floored invariant is still defined only through finite palettes, and the identity fails.

**Corollary 3.2.** If $\chi(G) \ge 3$ then $\chi_E(G) = \chi(G)$: above the floor, the two invariants coincide.

**Corollary 3.3 (Bipartite collapse).** If $G$ is bipartite — equivalently, $2$-colorable — then $\chi_E(G) = 3$. Conversely $\chi_E(G) = 3$ iff $G$ is $3$-colorable.

**Corollary 3.4 (Complete networks).** $\chi_E(K_n) = \max\{n,3\}$.

**Corollary 3.5 (Friendship circles).** For every $n \ge 3$, $\chi_E(C_n) = 3$, irrespective of parity.

**Proposition 3.6 (Functoriality).** Let $G,H$ be finite social networks.
1. *(Edge monotonicity)* $G \le H \implies \chi_E(G) \le \chi_E(H)$.
2. *(Isomorphism invariance)* If $G \cong H$ then $\chi_E(G) = \chi_E(H)$.
3. *(Disjoint communities)* $\chi_E(G \sqcup H) = \max\{\chi_E(G),\chi_E(H)\}$.
4. *(Universal fallback)* $\chi_E(G) \le \max\{n,3\}$.

*Proof sketch.* (1) A consistent $\chi_E(H)$-assignment for $H$ is one for $G$; apply realisability with $q = \chi_E(H) \ge 3$. (2) Transport colorings along the isomorphism in both directions. (3) A consistent assignment for a disjoint union is precisely a pair of consistent assignments for the parts; both directions then follow from realisability, using $\max\{\chi_E(G),\chi_E(H)\} \ge 3$. (4) Color everyone distinctly. $\square$

Part (3) is the formal expression of "emotional demand is a property of the most tangled component": isolation costs nothing.

---

## 4. Order-theoretic laws for the counting function

**Theorem 4.1 (Antitone in friendships).** If $G \le H$ on the same population, then $P_H(q) \le P_G(q)$ for every $q$.

*Proof sketch.* The set of consistent assignments for $H$ is a subset of the set for $G$: any assignment separating all $H$-friendships separates all $G$-friendships, since $G$ has fewer. Compare cardinalities. $\square$

**Theorem 4.2 (Monotone in the palette).** If $q \le r$ then $P_G(q) \le P_G(r)$.

*Proof sketch.* The inclusion $\{1,\dots,q\} \hookrightarrow \{1,\dots,r\}$ induces a map $c \mapsto \iota \circ c$ on assignments. It sends consistent assignments to consistent assignments ($\iota$ is injective, so $\iota c(x) = \iota c(y) \Rightarrow c(x)=c(y)$) and is itself injective (post-composition with an injection is injective). $\square$

**Theorem 4.3 (Universal floor).** For every $G$ on $n$ people and every $q$,
$$q^{\underline{n}} \le P_G(q).$$

*Proof sketch.* Apply Theorem 4.1 with $H = K_n$, the complete network, which dominates every $G$; and $P_{K_n}(q) = q^{\underline{n}}$ because consistent assignments to a clique are exactly injections into the palette. $\square$

The bound is vacuous when $n > q$ (both the falling factorial and the guarantee degenerate to $0 \le P_G(q)$); its content is for $n \le q$, where it is a genuine and often surprisingly large lower bound:

**Corollary 4.4 (Small groups are emotionally rich).** Every group of $n \le 6$ people, whatever their friendships, admits at least $6^{\underline{n}}$ consistent assignments of the six basic emotions; in particular at least $720$ when $n = 6$.

The central structural fact is that the support of $P_G$ above the floor is an up-set.

**Theorem 4.5 (Threshold law).** Let $q \ge 3$. Then
$$P_G(q) > 0 \iff \chi_E(G) \le q.$$

*Proof sketch.* $P_G(q) > 0$ is equivalent to $q$-colorability (a positive count is a witness; a witness contributes to the count). If $G$ is $q$-colorable with $q \ge 3$, realisability gives $\chi_E(G) \le q$. Conversely, if $\chi_E(G) \le q$, then $G$ is $\chi_E(G)$-colorable, and enlarging the palette preserves properness, so $G$ is $q$-colorable. $\square$

**Remark 4.6 (The hypothesis $q \ge 3$ is necessary).** For $q = 2$ the statement is false: a bipartite network with at least one edge has $P_G(2) > 0$ while $\chi_E(G) = 3 > 2$. This is precisely the artefact introduced by the emotional floor, and it is the correct formulation of the folklore about "bipartite networks and the value $2$" (see §9).

**Corollary 4.7 (Upward propagation).** If $q \le r$ and $P_G(q) > 0$, then $P_G(r) > 0$. (Immediate from Theorem 4.2, with no floor hypothesis.)

---

## 5. The sandwich theorem

### 5.1 The greedy bound

**Theorem 5.1 (Greedy bound).** If every person in $G$ has at most $d$ friends, then $G$ is $(d+1)$-colorable. Consequently $\chi(G) \le \Delta(G) + 1$.

*Proof sketch.* We prove the stronger partial statement by induction on a finite set $S$ of already-served people: for every $S \subseteq V$ there is an assignment $c : V \to \{1,\dots,d+1\}$ that is consistent *on $S$* (no two friends inside $S$ share an emotion). For $S = \emptyset$ any constant map works. For $S \cup \{a\}$ with $a \notin S$, take $c$ consistent on $S$ by induction; the set of emotions used by the friends of $a$ inside $S$ has at most $d$ elements, so with $d+1$ emotions available there is a free emotion $e$; the updated assignment $c' = c[a \mapsto e]$ is consistent on $S \cup \{a\}$, because any friendship inside $S\cup\{a\}$ either lies in $S$ (untouched) or involves $a$ (handled by the choice of $e$). Take $S = V$. $\square$

The induction never inspects the structure of $G$ on $V \setminus S$; this is exactly the flexibility that a Brooks-type refinement would exploit (§10).

**Corollary 5.2 (Emotional greedy bound).** $\chi_E(G) \le \max\{\Delta(G)+1,\,3\}$.

**Corollary 5.3 (Six emotions suffice).** If $\Delta(G) \le 5$, then $G$ admits a consistent six-emotion assignment and $3 \le \chi_E(G) \le 6$; equivalently $P_G(6) > 0$.

### 5.2 The clique bound

**Theorem 5.4 (Cliques force emotions).** If $S \subseteq V$ is a set of pairwise friends, then $|S| \le \chi_E(G)$. Consequently $\max\{\omega(G),3\} \le \chi_E(G)$.

*Proof sketch.* A consistent assignment restricted to $S$ is injective, so $|S|$ is at most the palette size of any consistent assignment; apply it to a consistent $\chi_E(G)$-assignment. Combine with the floor. $\square$

### 5.3 The sandwich and its sharpness

**Theorem 5.5 (Sandwich theorem).** For every finite social network,
$$\max\{\omega(G),\,3\} \;\le\; \chi_E(G) \;\le\; \max\{\Delta(G)+1,\,3\}.$$

**Corollary 5.6 (Locally decidable window).** If $\Delta(G) \le 5$ then $\omega(G) \le 6$ and $3 \le \chi_E(G) \le 6$: two local statistics certify membership in the six-emotion window with no global search.

**Corollary 5.7.** $\chi_E(G) \le 6 \iff G$ is $6$-colorable.

Is the sandwich ever loose on both sides at once? Yes, and minimally so.

**Definition 5.8 (Hub-and-circle network).** Let $W$ be the graph on six people $\{0,1,2,3,4,5\}$ where $0,1,2,3,4$ form a five-cycle and person $5$ (the *hub*) is friends with all of $0,\dots,4$. (This is the wheel $W_5$.)

**Theorem 5.9 (Simultaneous strictness).** For the hub-and-circle network,
$$P_W(3) = 0, \qquad P_W(4) = 120, \qquad \Delta(W) = 5, \qquad \omega(W) = 3, \qquad \chi_E(W) = 4,$$
so that
$$\max\{\omega(W),3\} = 3 \;<\; \chi_E(W) = 4 \;<\; 6 = \max\{\Delta(W)+1,3\}.$$

*Proof sketch.* The counts $P_W(3) = 0$ and $P_W(4) = 120$ are finite verifications over $3^6 = 729$ and $4^6 = 4096$ assignments respectively; the value $120$ matches the classical wheel polynomial $q\bigl((q-2)^5 - (q-2)\bigr)$ at $q = 4$, an independent check of the encoding. The hub together with any two adjacent circle-dwellers is a triangle, so $\omega(W) \ge 3$; an exhaustive check shows no four people are pairwise friends, so $\omega(W) = 3$. The hub has five friends and nobody has more, so $\Delta(W) = 5$. Finally $P_W(3) = 0$ rules out $\chi_E(W) = 3$ by the threshold law, and $P_W(4) > 0$ gives $\chi_E(W) \le 4$; with the floor, $\chi_E(W) = 4$. $\square$

This is the smallest witness of the general phenomenon that $\chi - \omega$ is unbounded: emotional demand is not a function of either local statistic. Structurally, the odd cycle beneath the hub is responsible — a $3$-coloring would have to $2$-color the five-cycle after fixing the hub's emotion, which parity forbids.

---

## 6. Abundance: a counting greedy theorem

Existence is the case $q = d+1$ of a much stronger, quantitative statement.

**Theorem 6.1 (Greedy abundance).** If every person has at most $d$ friends, then for every $q$,
$$(q-d)^{\,n} \;\le\; P_G(q),$$
where $n = |V|$ and subtraction is truncated at zero.

*Proof sketch.* For $S \subseteq V$ let $\mathcal{A}(S)$ denote the set of maps $c : V \to \{1,\dots,q\}$ that are consistent on $S$. We prove by induction on $S$ that
$$|\mathcal{A}(S)| \;\ge\; (q-d)^{|S|}\, q^{\,n - |S|}.$$
For $S = \emptyset$ this reads $|\mathcal{A}(\emptyset)| = q^n$, an equality. For the step $S \to S \cup \{a\}$, consider the "forget $a$" map $\mathcal{A}(S\cup\{a\}) \to \mathcal{A}(S)$, $c \mapsto c[a \mapsto c_0]$ for a fixed reference color $c_0$. Each fibre of the analogous map on $\mathcal{A}(S)$ has exactly $q$ elements (the color of $a$ is unconstrained there), while inside $\mathcal{A}(S\cup\{a\})$ at most $d$ colors are forbidden for $a$ — the colors of $a$'s friends already lying in $S$ — so each fibre retains at least $q-d$ elements. Hence
$$|\mathcal{A}(S\cup\{a\})| \;\ge\; \frac{q-d}{q}\,|\mathcal{A}(S)| \;\ge\; (q-d)^{|S|+1} q^{\,n-|S|-1},$$
where the division is carried out as a fibre-by-fibre count to stay within the integers. Taking $S = V$ gives $\mathcal{A}(V) = $ the set of consistent assignments, of size $P_G(q)$, and the bound $(q-d)^n$. $\square$

**Corollary 6.2.** $(q - \Delta(G))^n \le P_G(q)$ for every $q$.

**Corollary 6.3 (Exponential abundance in sparse networks).** A community of $100$ people in which nobody has more than five friends admits at least $5^{100} \approx 7.9 \times 10^{69}$ consistent assignments of ten emotions.

**Proposition 6.4 (Sharpness).** For the friendless population ($d = 0$) the bound is attained: $P_{\overline{K_n}}(q) = q^{n}$.

**Remark 6.5 (Range of validity).** For $q \le d$ the bound degenerates to $0 \le P_G(q)$ and carries no information; the content is the regime $q > d$, where it is exponential in the population. In particular Theorem 6.1 does *not* claim positivity when $q \le d$ — and indeed positivity may fail there, as $K_7$ with $q = 6$ shows.

Theorems 4.3 and 6.1 are complementary rather than comparable: the universal floor is strong for small populations with large palettes ($n \le q$), the abundance bound is strong for large sparse populations ($q > d$).

---

## 7. A closed form and a census

### 7.1 Cliques with bystanders

**Definition 7.1.** For $N,k \in \mathbb{N}$, let $B_{N,k}$ be the network on $N$ people in which the first $s = \min\{k,N\}$ are pairwise friends and all remaining $N - s$ people ("bystanders") have no friends at all.

**Theorem 7.2 (Closed form).** For all $N,k,q$, with $s = \min\{k,N\}$,
$$P_{B_{N,k}}(q) \;=\; q^{\underline{s}} \cdot q^{\,N-s}.$$

*Proof sketch.* An assignment is consistent for $B_{N,k}$ exactly when it is injective on the clique $\{0,\dots,s-1\}$ and arbitrary on the bystanders: the only friendships are inside the clique, and they are all of them. Consistent assignments therefore biject with pairs (injection of the $s$-element clique into the $q$-element palette, arbitrary map from the $N-s$ bystanders to the palette). The number of injections is $q^{\underline{s}}$ and the number of arbitrary maps is $q^{N-s}$. $\square$

**Theorem 7.3.** $\chi_E(B_{N,k}) = \max\{s,3\}$ with $s = \min\{k,N\}$.

*Proof sketch.* Upper bound: color the clique injectively with $\max\{s,3\}$ available emotions and give every bystander emotion $1$. Lower bound: the clique of $s$ pairwise friends forces $s \le \chi_E$ by Theorem 5.4, and the floor forces $3 \le \chi_E$. $\square$

### 7.2 The census

**Definition 7.4 (Census).** The census consists of one hundred networks:
- for $i = 0,\dots,49$, the **friendship circle** $C_{i+3}$ ($i+3$ people in a ring);
- for $i = 0,\dots,49$, the **clique network** $B_{10,\,3+(i \bmod 4)}$ (ten people, of whom the first $3+(i \bmod 4)$ are mutual friends).

**Theorem 7.5 (Census values).** $\chi_E(C_{i+3}) = 3$ for all $i$, and $\chi_E(B_{10,\,3+(i\bmod 4)}) = 3 + (i \bmod 4)$.

*Proof sketch.* The circles: Corollary 3.5. The clique networks: Theorem 7.3 with $s = \min\{3+(i\bmod 4),10\} = 3+(i \bmod 4) \ge 3$. $\square$

**Theorem 7.6 (Census window).** Every network in the census satisfies $3 \le \chi_E \le 6$.

**Theorem 7.7 (Load and distribution).** Writing $L(i)$ for the emotional chromatic number of the $i$-th census network ($L(i) = 3$ for $i < 50$; $L(i) = 3 + ((i-50) \bmod 4)$ for $i \ge 50$):
$$\sum_{i=0}^{99} L(i) = 373,$$
an average of $3.73$ emotions per network, with distribution
$$\#\{i : L(i)=3\} = 63,\quad \#\{i : L(i)=4\} = 13,\quad \#\{i : L(i)=5\} = 12,\quad \#\{i : L(i)=6\} = 12,$$
and every $L(i) \in \{3,4,5,6\}$.

*Proof sketch.* Fifty circles contribute $3$ each. Among the fifty clique networks, the residues $i \bmod 4 = 0,1,2,3$ occur $13,13,12,12$ times respectively, contributing $3,4,5,6$; summing, $150 + (13\cdot3 + 13\cdot4 + 12\cdot 5 + 12\cdot 6) = 150 + 223 = 373$. $\square$

**Theorem 7.8 (Six-emotion counts).** For the ten-person clique networks,
$$P_{B_{10,3}}(6) = 33{,}592{,}320,\quad P_{B_{10,4}}(6) = 16{,}796{,}160,\quad P_{B_{10,5}}(6) = 5{,}598{,}720,\quad P_{B_{10,6}}(6) = 933{,}120,$$
and these are strictly decreasing in the clique size.

*Proof sketch.* Substitute into Theorem 7.2: e.g. $6^{\underline{3}} \cdot 6^{7} = 120 \cdot 279936 = 33{,}592{,}320$ and $6^{\underline{6}} \cdot 6^{4} = 720 \cdot 1296 = 933{,}120$. $\square$

**Corollary 7.9 (Census abundance, sharp).** Every clique network of the census admits at least $933{,}120$ consistent six-emotion assignments, and the bound is attained exactly by the six-clique network.

*Proof sketch.* Each clique network is a subnetwork of $B_{10,6}$ (its clique is contained in the six-clique), so Theorem 4.1 gives $P_{B_{10,6}}(6) \le P_{B_{10,k}}(6)$ for $k \le 6$; evaluate the right-hand minimum by Theorem 7.8. $\square$

This is the paper's quantitative moral: *emotional demand and emotional freedom move in opposite directions.* Increasing the core clique from three to six raises $\chi_E$ from $3$ to $6$ while cutting the number of consistent six-emotion assignments by a factor of $36$.

**Theorem 7.10 (The window is not universal).** For the seven-person clique, $P_{K_7}(6) = 0$ and $\chi_E(K_7) = 7$.

Hence "$\chi_E \in [3,6]$" is a property of the sample, not a theorem; the honest general statement is the sandwich theorem, and the census window is what the sandwich yields under $\omega \le 6$ (or $\Delta \le 5$).

---

## 8. Conservation laws: the network and its complement

**Theorem 8.1 (Product injection).** If $G$ is $a$-colorable and $\overline{G}$ is $b$-colorable, then $n \le ab$.

*Proof sketch.* Let $c$ be a proper $a$-coloring of $G$ and $d$ a proper $b$-coloring of $\overline{G}$. The map $v \mapsto (c(v),d(v))$ is injective: if $x \ne y$ then $x,y$ are either friends (so $c(x)\ne c(y)$) or strangers (so $d(x)\ne d(y)$). Hence $n \le ab$. $\square$

**Corollary 8.2 (Nordhaus–Gaddum product law).** $n \le \chi(G)\,\chi(\overline{G})$ and $n \le \chi_E(G)\,\chi_E(\overline{G})$.

**Corollary 8.3 (Sum law).** $4n \le \bigl(\chi(G) + \chi(\overline{G})\bigr)^2$ and $4n \le \bigl(\chi_E(G) + \chi_E(\overline{G})\bigr)^2$; equivalently $\chi_E(G)+\chi_E(\overline{G}) \ge 2\sqrt{n}$.

*Proof sketch.* From $n \le ab$ and $(a+b)^2 \ge 4ab$ (i.e. $(a-b)^2 \ge 0$). $\square$

**Corollary 8.4 (Emotional duality).** If $\chi_E(G) \le 6$ then $n \le 6\,\chi_E(\overline{G})$. In particular a hundred-person community whose friendships require only the six basic emotions has $\chi_E(\overline{G}) \ge 17$.

**Theorem 8.5 (Sparse networks have dense stranger networks).** If $n = 100$ and $\Delta(G) \le 5$ then $\Delta(\overline{G}) \ge 16$.

*Proof sketch.* By Corollary 5.3, $\chi_E(G) \le 6$; by Corollary 8.4, $\chi_E(\overline{G}) \ge 17$; by Corollary 5.2 applied to $\overline{G}$, $17 \le \max\{\Delta(\overline{G})+1,3\}$, which forces $\Delta(\overline{G}) \ge 16$. $\square$

**Theorem 8.6 (Self-complementary networks).** If $G \cong \overline{G}$ then $n \le \chi_E(G)^2$.

*Proof sketch.* Isomorphism invariance (Proposition 3.6(2)) gives $\chi_E(\overline{G}) = \chi_E(G)$; substitute into Corollary 8.2. $\square$

**Proposition 8.7 (Neither vacuous nor tight).** On a complete network the product law is attained after the floor is stripped: $\chi(K_n)\chi(\overline{K_n}) = n \cdot 1 = n$. On the five-cycle it is strictly loose: $\overline{C_5} \cong C_5$, so $\chi_E(C_5)\chi_E(\overline{C_5}) = 9 > 5$.

The interpretation is worth stating plainly: emotional simplicity is a conserved quantity. A society whose *friendships* are easy to color has *strangerhood* that is hard to color, and vice versa; the two complexities multiply to at least the population.

---

## 9. Three corrections to the folklore

The informal model that motivates this work carries three plausible-sounding claims. All three are false as stated, and the corrections are instructive.

**(F1) "The chromatic polynomial has a root at $q=2$ for every bipartite graph, so a network splitting cleanly into two groups has no consistent two-emotion assignment."**
Backwards. Bipartite is *equivalent* to $2$-colorable; a connected bipartite network with at least one edge has exactly $P_G(2) = 2$. The polynomial vanishes at $q=2$ precisely for networks that are not bipartite (those containing an odd cycle) — plus, trivially, never for edgeless networks, where $P_G(2) = 2^n$. What is true, and is the correct form of the intuition under the emotional floor, is Corollary 3.3: every bipartite network sits exactly at $\chi_E = 3$.

**(F2) "$\chi_E(C_n) = 2$ for even $n$ and $3$ for odd $n$."**
The parity statement is correct for the classical chromatic number, $\chi(C_n) = 2$ or $3$, but the floor $q \ge 3$ makes it invisible: $\chi_E(C_n) = 3$ for all $n \ge 3$ (Corollary 3.5). Parity survives only in the *counts*: $P_{C_n}(q) = (q-1)^n + (-1)^n(q-1)$, which is what one should look at to detect it.

**(F3) "$3 \le \chi_E(G) \le 6$ for real social networks."**
This is a statistical regularity of samples with small cliques and bounded degree, not a theorem. Theorem 7.10 exhibits a seven-person clique with $\chi_E = 7$ and *zero* consistent six-emotion assignments. The rigorous replacement is the sandwich theorem together with Corollary 5.6: $\Delta(G) \le 5$ certifies the window, and nothing weaker does so unconditionally.

---

## 10. Algorithms

Three procedures underlie the computational content of the paper.

**Algorithm A (Exact chromatic counting by deletion–contraction).** To compute $P_G(q)$ exactly for a graph with $m$ edges: if $G$ has no edges, return $q^{n}$; otherwise pick an edge $uv$ and return $P_{G - uv}(q) - P_{G / uv}(q)$, where $G - uv$ deletes the edge and $G/uv$ merges its endpoints. The recursion terminates because each call reduces $m + n$; it costs $O(\varphi^{\,n+m})$ in the worst case, but is exact and works for symbolic $q$. For small graphs (up to roughly $n = 8$ and any $q$) brute-force enumeration over $q^n$ assignments is simpler and is used here as an independent check.

**Algorithm B (Greedy coloring and the degree bound).** Order the population arbitrarily; assign to each person in turn the least emotion not used by their already-colored friends. This runs in $O(n + m)$ time with an auxiliary bitmask and always succeeds with $\Delta+1$ emotions. It is the constructive core of Theorem 5.1, and its fibre-counting refinement is Theorem 6.1.

**Algorithm C (Emotional chromatic number by threshold search).** By the threshold law (Theorem 4.5) the predicate $q \mapsto [P_G(q) > 0]$ is monotone for $q \ge 3$, so $\chi_E(G)$ can be found by scanning $q = 3,4,\dots$ and stopping at the first success; each test is a $q$-colorability check (NP-complete in general, but bounded above by $\max\{\Delta+1,3\}$ tests thanks to Corollary 5.2). The sandwich theorem gives a certified bracket $[\max\{\omega,3\},\max\{\Delta+1,3\}]$ before any search begins, which for many networks pins the answer without any coloring at all.

---

## 11. Discussion and applications

The mathematics above is classical graph coloring, but the emotional reading forces two questions that are not usually asked side by side: the threshold question (how many colors are needed) and the abundance question (how many colorings exist). The results show these are governed by the same two local statistics with opposite signs. Cliques push $\chi_E$ up (Theorem 5.4) and $P_G$ down (Theorem 4.1). Degree bounds push $\chi_E$ down (Corollary 5.2) and $P_G$ up (Theorem 6.1). The census makes the trade-off numerical: as the core clique of a ten-person group grows from three to six, demand rises $3 \to 6$ and supply falls $33{,}592{,}320 \to 933{,}120$.

Three applications beyond the motivating story:

- **Timetabling and conflict scheduling.** $\chi_E$ with a floor models a scheduler required to use at least three time slots for administrative reasons; the sandwich gives an *a priori* certified range for the number of slots needed, and the abundance bound guarantees a large solution space (useful for randomised or preference-aware scheduling) whenever conflicts are locally bounded.
- **Frequency assignment.** $\Delta \le 5 \Rightarrow$ six frequencies suffice, and $(q-d)^n$ lower-bounds the number of valid plans — a robustness statement: a locally sparse interference graph admits exponentially many assignments, so a plan can be re-randomised after any local failure.
- **Complementarity diagnostics.** Theorem 8.5 is a genuine structural statement about data: measuring $\Delta$ on a hundred-node network with $\Delta \le 5$ certifies, without further computation, that the complement graph has a vertex of degree $\ge 16$. Analogous conservation constraints bound how simple both a relation and its negation can simultaneously be.

**Limitations.** The model treats friendship as symmetric, unweighted and static, and emotional consistency as a hard constraint. Realistic affect dynamics would want weighted edges (intensity), directed edges (asymmetric regard), soft constraints (penalised rather than forbidden coincidences — a Potts-model rather than a coloring formulation), and time. The chromatic polynomial is precisely the zero-temperature limit of the antiferromagnetic Potts partition function, which suggests the natural soft generalisation: replace $P_G(q)$ by $Z_G(q,\beta) = \sum_c \prod_{x\sim y} \bigl(1 + (e^{-\beta} - 1)\,\delta_{c(x),c(y)}\bigr)$, with all results here recovered as $\beta \to \infty$.

---

## 12. Future directions

Three conjectures are the natural next targets; each is falsifiable and each is stated so that a single focused development could settle it.

**Conjecture A (Brooks' theorem, emotional form).** *If a finite connected social network is neither a clique nor an odd friendship circle, then $\chi(G) \le \Delta(G)$, hence $\chi_E(G) \le \max\{\Delta(G),3\}$.* The key insight is that the greedy bound proved here wastes exactly one color, and the waste can be recovered by ordering the population so that the last person colored has two already-colored neighbours who are themselves non-adjacent — a purely local surgery that the finite-set induction of Theorem 5.1 can carry, because that induction never refers to the graph structure of the *remaining* people.

**Conjecture B (Chromatic polynomial of the friendship circle).** *For $n \ge 3$ and every $q$, the number of consistent $q$-assignments of $C_n$ is $(q-1)^n + (-1)^n(q-1)$; consequently the six-emotion count of an $n$-person friendship circle is $5^n + (-1)^n\cdot 5$.* The key insight is that the closed form is a transfer-matrix trace — the count is $\operatorname{tr}\bigl((J-I)^n\bigr)$ for the $q\times q$ all-ones-minus-identity matrix — so a deletion–contraction recursion reduces the cyclic count to the path count via a gluing bijection identifying the two endpoints. This would turn the qualitative census ($\chi_E(C_n)=3$) into a quantitative one, and would be the first exact chromatic polynomial for an infinite family containing cycles in this framework.

**Conjecture C′ (Degeneracy abundance).** *If a social network is $k$-degenerate — every sub-community contains somebody with at most $k$ friends inside it — then $P_G(q) \ge (q-k)^{n}$ and $\chi_E(G) \le \max\{k+1,3\}$, with $k$ typically far smaller than the maximum degree.* (Its predecessor, the maximum-degree form $P_G(q) \ge (q-d)^n$, is Theorem 6.1 above.) Degeneracy is the right parameter for real social data, where a few hubs inflate $\Delta$ without making the network hard to color; the induction of Theorem 6.1 should go through verbatim once the vertices are processed in a degeneracy order, since at the moment each vertex is colored only its at-most-$k$ back-neighbours constrain it.

---

## 13. Conclusion

We have shown that the chromatic counting function of a social network, read under a three-category floor, obeys a tidy set of laws: it is antitone in friendships and monotone in the palette; its support above the floor is an up-set, making the emotional chromatic number a genuine threshold; that threshold is sandwiched between clique number and maximum degree plus one, with both inequalities strict for the six-person hub-and-circle network; and where the sandwich guarantees existence, a counting refinement guarantees exponential abundance, $(q-d)^n \le P_G(q)$. Closed forms for cliques-with-bystanders make a hundred-network census exact, and the census exhibits the central trade-off numerically. A complementarity law, $n \le \chi_E(G)\chi_E(\overline{G})$, closes the theory by showing that emotional simplicity cannot be had on both sides of a relation at once.

Three appealing but false claims — bipartite networks having no two-color assignments, even circles needing only two categories, and a universal $[3,6]$ window — have been replaced by correct statements. What remains is the picture we set out to draw: the chromatic polynomial is not only combinatorics. It simultaneously measures how much diversity a system of constraints *forces* and how much freedom it *leaves*, and in a social network those two quantities are inversely coupled by the size of its tightest clique.
