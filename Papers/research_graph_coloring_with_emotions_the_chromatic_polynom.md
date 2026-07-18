# Chromatic Positivity Thresholds for Emotion-Labeled Social Networks

**Aristotle**  
**July 18, 2026**

## Abstract

We study a constrained-labeling model in which the vertices of a finite simple graph represent people, edges represent friendship relations, and adjacent vertices must receive distinct labels from an emotional palette. The chromatic counting function $P_G(k)$ counts proper assignments from a palette of size $k$. We define the emotional chromatic number $\tau_E(G)$ as the least palette size $k\ge 3$ for which a proper assignment exists. The lower bound is an explicit modeling convention rather than a graph-theoretic consequence.

Our principal result identifies $\tau_E(G)$ with the positivity threshold of $P_G$ on the admissible range: for every $k\ge 3$, one has $\tau_E(G)\le k$ if and only if $P_G(k)>0$. Consequently, $\tau_E(G)=k$ precisely when $k\ge 3$, $P_G(k)>0$, and $P_G(j)=0$ for every $3\le j<k$. Specializing to a six-label palette yields $P_G(6)>0$ if and only if $3\le \tau_E(G)\le 6$. For the friendship graph $F_n$, formed from $n$ triangles sharing a common vertex, we derive the closed formula $P_{F_n}(k)=k(k-1)^n(k-2)^n$. It follows that $\tau_E(F_n)=3$, that $P_{F_n}(3)=3\cdot 2^n$, and that $P_{F_n}(6)=6\cdot 20^n$. We discuss algorithms, empirical interpretation, limitations of the emotional metaphor, and extensions to complexity, graph minors, high-girth networks, and triangle-gluing geometries.

## 1. Introduction

Graph coloring is a canonical model of local incompatibility. Given a graph, one assigns labels to vertices under the rule that adjacent vertices receive different labels. The smallest number of labels required is the chromatic number, while the number of assignments available from a palette of size $k$ is encoded by the chromatic polynomial.

This paper develops an interpretive specialization for social networks. Vertices represent people, edges represent friendship relations, and labels are called emotions. A proper emotion assignment requires friends to receive different labels. If the palette consists of happiness, sadness, anger, fear, disgust, and surprise, then a proper six-label assignment is an “emotionally consistent” assignment in the limited combinatorial sense of this model.

The language is intentionally metaphorical. Real emotions are not mutually exclusive colors, and friendship does not ordinarily prohibit shared feelings. The value of the model lies instead in its clear mathematical structure. It illustrates how an algebraic counting invariant, an order-theoretic minimum, and a network-labeling constraint describe the same transition from impossibility to feasibility.

We impose a palette floor of three labels. This creates an emotional chromatic number that differs from the ordinary chromatic number on graphs colorable with fewer than three colors. The distinction is essential. The floor is part of the definition and is not inferred from bipartiteness or any psychological premise.

The main contribution is a complete threshold characterization. Above the floor, a palette supports a proper assignment exactly when it bounds the emotional chromatic number, and this condition is equivalent to positivity of the chromatic counting function. The threshold itself is therefore the first positive chromatic evaluation on the admissible integer range. This provides both a conceptual bridge and a direct computational procedure.

We then examine friendship graphs, or windmill graphs, consisting of triangles joined at a single hub. Their product structure yields exact assignment counts at both the minimum palette and the six-label palette. These formulas separate the minimum number of labels from the abundance of assignments: the threshold remains fixed at three while the six-label count grows as $6\cdot 20^n$.

## 2. Graphs and proper assignments

### 2.1 Finite simple graphs

A **finite simple graph** is a pair $G=(V,E)$, where $V$ is a finite set of vertices and $E$ is a set of unordered pairs of distinct vertices. We write $u\sim v$ when $\{u,v\}\in E$. Simplicity means that there are no loops and no multiple edges.

For the social interpretation, each vertex is a person and each edge is a friendship relation. No mathematical result depends on this interpretation; all statements concern finite simple graphs.

### 2.2 Palettes and proper colorings

For a nonnegative integer $k$, let a **$k$-palette** be a set of $k$ distinct labels. A **proper $k$-assignment** of $G$ is a function

$$
c:V\longrightarrow \{1,2,\ldots,k\}
$$

such that $c(u)\ne c(v)$ whenever $u\sim v$. The particular names of the labels do not matter. In the emotional interpretation, they may be names of emotions.

A graph is **$k$-colorable** if it has at least one proper $k$-assignment. If it is $r$-colorable and $r\le k$, then it is $k$-colorable: regard the $r$ labels as a subset of the larger palette and leave the additional labels unused. We call this the **palette monotonicity principle**.

### 2.3 The chromatic counting function

For a finite graph $G$, define

$$
P_G(k)=\#\{c:V\to\{1,\ldots,k\}: c \text{ is proper}\}.
$$

This function agrees on nonnegative integers with a polynomial in $k$, the **chromatic polynomial** of $G$. We use only its counting interpretation.

The following elementary lemma is fundamental.

> **Lemma 2.1 (Positivity and colorability).** For every finite simple graph $G$ and every nonnegative integer $k$,
> $$
> P_G(k)>0 \quad\Longleftrightarrow\quad G \text{ is } k\text{-colorable}.
> $$

**Proof sketch.** The value $P_G(k)$ is the cardinality of the finite set of proper $k$-assignments. A finite set has positive cardinality exactly when it is nonempty. Nonemptiness is precisely the existence of a proper assignment. $\square$

## 3. The emotional chromatic number

### 3.1 Definition and relation to ordinary coloring

> **Definition 3.1 (Emotional chromatic number).** The emotional chromatic number of a finite graph $G$ is
> $$
> \tau_E(G)=\min\{k\in\mathbb{N}: k\ge 3 \text{ and } G \text{ is } k\text{-colorable}\}.
> $$

The set is nonempty because every finite graph can be colored by assigning a distinct label to every vertex, and palettes can always be enlarged to reach size at least three. Thus the minimum exists.

Let $\chi(G)$ denote the ordinary chromatic number. The definition immediately implies

$$
\tau_E(G)=\max\{3,\chi(G)\}.
$$

Indeed, an admissible palette must be at least both $3$ and $\chi(G)$, while a palette of their maximum size is sufficient. This identity clarifies the model: $\tau_E$ is the ordinary chromatic threshold truncated below by three.

> **Lemma 3.2 (Floor and attainment).** Every finite graph $G$ satisfies $\tau_E(G)\ge 3$, and $G$ admits a proper $\tau_E(G)$-assignment.

**Proof sketch.** The inequality is built into the defining set. Since $\tau_E(G)$ is its minimum, it belongs to that set and therefore supports a proper assignment. $\square$

The floor changes familiar examples. An edgeless graph and a nonempty bipartite graph may have ordinary chromatic number at most two, but both have emotional chromatic number three. A clique $K_n$ satisfies $\tau_E(K_n)=\max\{3,n\}$; in particular, the frequently stated formula $\tau_E(K_n)=n$ requires $n\ge 3$.

For a cycle $C_n$ with $n\ge 3$, the ordinary chromatic number is two when $n$ is even and three when $n$ is odd. Under Definition 3.1, however,

$$
\tau_E(C_n)=3
$$

for every $n\ge 3$. The ordinary even–odd distinction remains visible in $\chi(C_n)$ and in evaluations below the emotional floor, but not in $\tau_E(C_n)$.

### 3.2 Correction of a false bipartite-root claim

It is false that every bipartite graph has $P_G(2)=0$. Consider the graph consisting of a single edge. Either endpoint can receive the first of two labels, after which the other endpoint is forced to receive the second. Hence

$$
P_G(2)=2.
$$

More generally, bipartiteness means that a proper two-coloring exists, so any bipartite graph has positive chromatic count at two. For a connected bipartite graph with at least one vertex, there are exactly two proper two-colorings. The emotional floor at three is therefore a convention, not a consequence of a root at two.

## 4. Positivity as an exact threshold

We now establish the central equivalence.

> **Theorem 4.1 (Emotional Threshold Theorem).** Let $G$ be a finite simple graph and let $k\ge 3$. Then
> $$
> \tau_E(G)\le k
> \quad\Longleftrightarrow\quad
> G \text{ is } k\text{-colorable}.
> $$

**Proof sketch.** Suppose first that $\tau_E(G)\le k$. By Lemma 3.2, a proper assignment exists using $\tau_E(G)$ labels. Palette monotonicity enlarges this assignment to a $k$-palette, so $G$ is $k$-colorable. Conversely, if $G$ is $k$-colorable and $k\ge 3$, then $k$ lies in the set minimized in Definition 3.1. Therefore its minimum satisfies $\tau_E(G)\le k$. $\square$

Combining this theorem with Lemma 2.1 gives the algebraic form.

> **Corollary 4.2 (Positivity-threshold equivalence).** Let $G$ be a finite simple graph and $k\ge 3$. Then
> $$
> \tau_E(G)\le k
> \quad\Longleftrightarrow\quad
> P_G(k)>0.
> $$

**Proof sketch.** Theorem 4.1 equates the left-hand condition with $k$-colorability; Lemma 2.1 equates $k$-colorability with positivity of $P_G(k)$. $\square$

This corollary identifies two kinds of information. The inequality $\tau_E(G)\le k$ is order-theoretic, while $P_G(k)>0$ is enumerative. Above the floor they define exactly the same decision boundary.

### 4.1 The minimal-positive-value law

> **Theorem 4.3 (Minimal-Positive-Value Theorem).** For every finite simple graph $G$ and every nonnegative integer $k$, the following are equivalent:
>
> 1. $\tau_E(G)=k$;
> 2. $k\ge 3$, $P_G(k)>0$, and $P_G(j)=0$ for every integer $j$ satisfying $3\le j<k$.

**Proof sketch.** Assume $\tau_E(G)=k$. The floor gives $k\ge 3$, and attainment gives a proper $k$-assignment, hence $P_G(k)>0$. If some $j$ with $3\le j<k$ had $P_G(j)>0$, Corollary 4.2 would imply $\tau_E(G)\le j<k$, a contradiction. Since chromatic counts are nonnegative integers, failure of positivity means equality to zero.

Conversely, suppose the three conditions in item 2 hold. Positivity at $k$ and Corollary 4.2 imply $\tau_E(G)\le k$. If strict inequality held, let $j=\tau_E(G)$. Lemma 3.2 gives $j\ge 3$, attainment gives $P_G(j)>0$, and strict inequality gives $j<k$. This contradicts the assumed vanishing of every earlier admissible evaluation. Therefore $\tau_E(G)=k$. $\square$

The theorem says that $\tau_E(G)$ is the first positive entry in the sequence

$$
P_G(3),P_G(4),P_G(5),\ldots.
$$

The values preceding it form a contiguous interval of zeros on the admissible range. This is a statement about integer evaluations, not about the full complex root structure of the chromatic polynomial.

### 4.2 Six labels

> **Theorem 4.4 (Six-Emotion Characterization).** For every finite simple graph $G$,
> $$
> P_G(6)>0
> \quad\Longleftrightarrow\quad
> 3\le \tau_E(G)\le 6.
> $$

**Proof sketch.** The lower bound $3\le\tau_E(G)$ always holds. By Corollary 4.2 with $k=6$, positivity of $P_G(6)$ is equivalent to $\tau_E(G)\le 6$. Combining these observations yields the equivalence. $\square$

The theorem does not assert that every social network lies in this interval. A clique $K_7$ has no proper six-assignment because its seven pairwise adjacent vertices require seven distinct labels. Rather, the theorem gives an exact test: six labels suffice if and only if the count at six is positive.

## 5. Friendship graphs

### 5.1 Definition

For $n\ge 0$, the **friendship graph** $F_n$ is formed from $n$ triangles by identifying one vertex from each triangle into a common hub. Equivalently, its vertices consist of a hub $h$ and outer vertices $a_i,b_i$ for $1\le i\le n$. Its edges are

$$
\{h,a_i\},\quad \{h,b_i\},\quad \{a_i,b_i\}
$$

for each $i$. There are no edges between outer vertices belonging to different pairs. When $n=0$, the graph consists only of the hub.

The triangles make three labels necessary in the ordinary sense whenever $n\ge 1$. More importantly, the conditional independence of outer pairs gives a closed product formula.

> **Theorem 5.1 (Friendship chromatic formula).** For every $n,k\ge 0$,
> $$
> P_{F_n}(k)=k(k-1)^n(k-2)^n
> =k\bigl((k-1)(k-2)\bigr)^n,
> $$
> interpreted through the polynomial identity and, for nonnegative palettes, through direct counting whenever the factors describe available choices.

**Proof sketch.** Choose the hub label in $k$ ways. For each $i$, the vertex $a_i$ must differ from the hub and therefore has $k-1$ choices. The vertex $b_i$ must differ from both the hub and $a_i$, giving $k-2$ choices. Outer pairs from different triangles are nonadjacent, so their choices are independent. Multiplication over the $n$ pairs yields the formula. $\square$

At $k=3$, the formula is positive for every $n$. Since palettes below three are inadmissible, this immediately determines the emotional threshold.

> **Theorem 5.2 (Friendship-network threshold profile).** For every $n\ge 0$,
> $$
> \tau_E(F_n)=3,
> $$
> and the assignment counts at the minimum and six-label palettes are
> $$
> P_{F_n}(3)=3\cdot 2^n,
> \qquad
> P_{F_n}(6)=6\cdot 20^n.
> $$

**Proof sketch.** Substituting $k=3$ into Theorem 5.1 gives

$$
P_{F_n}(3)=3(2)^n(1)^n=3\cdot 2^n>0.
$$

Corollary 4.2 implies $\tau_E(F_n)\le 3$, while the floor implies $\tau_E(F_n)\ge 3$. Hence equality holds. Substitution of $k=6$ gives

$$
P_{F_n}(6)=6(5)^n(4)^n=6\cdot 20^n.
$$

$\square$

The ratio of the six-label count to the minimum-palette count is

$$
R_n=\frac{P_{F_n}(6)}{P_{F_n}(3)}
=\frac{6\cdot 20^n}{3\cdot 2^n}
=2\cdot 10^n.
$$

Thus each added triangle multiplies the three-label count by $2$ and the six-label count by $20$. The emotional chromatic number remains unchanged, but the configuration space expands at sharply different rates.

### 5.2 Numerical examples

For $n=1$, $F_1$ is a triangle. The formulas give

$$
P_{F_1}(3)=6,
\qquad
P_{F_1}(6)=120.
$$

For $n=2$, two triangles share a hub:

$$
P_{F_2}(3)=12,
\qquad
P_{F_2}(6)=2400.
$$

For $n=5$,

$$
P_{F_5}(3)=96,
\qquad
P_{F_5}(6)=19{,}200{,}000.
$$

These examples demonstrate that a fixed threshold does not imply a fixed or modest number of assignments.

## 6. Algorithms

### 6.1 Threshold search by colorability

The Minimal-Positive-Value Theorem yields a direct algorithm. Starting at $k=3$, test whether the graph is $k$-colorable. Return the first successful value. A backtracking solver assigns labels vertex by vertex and rejects partial assignments as soon as an edge has equal endpoint labels.

If $N=|V|$, a naive test explores at most $k^N$ complete assignments, with polynomial overhead for edge checks. Testing all palettes from $3$ through an upper bound $U$ therefore has worst-case time

$$
O\left(|E|\sum_{k=3}^{U}k^N\right),
$$

though good vertex ordering and early pruning can dramatically reduce practical search. Taking $U=\max\{3,N\}$ always suffices.

### 6.2 Direct chromatic evaluation by enumeration

To compute $P_G(k)$ rather than merely test positivity, enumerate all assignments and count the proper ones. This has worst-case time $O(|E|k^N)$ and space $O(N)$ with depth-first recursion. The method is suitable only for small graphs, but it provides transparent numerical examples and an independent check of closed formulas.

### 6.3 Closed-form friendship evaluation

For $F_n$, no graph construction or search is needed. Evaluate

$$
k((k-1)(k-2))^n.
$$

Using exponentiation by squaring, the arithmetic operation count is $O(\log n)$, although the bit complexity also depends on the exponentially growing output length. The special values $3\cdot 2^n$ and $6\cdot 20^n$ are equally immediate.

## 7. Applications and interpretation

The threshold framework applies to any constrained labeling problem represented by a graph. In frequency assignment, adjacent transmitters must receive distinct frequencies. In examination scheduling, conflicting examinations need different time slots. In register allocation, simultaneously active variables compete for registers. In each case, the analogue of $\tau_E(G)$ gives a minimum admissible resource count, while $P_G(k)$ measures the number of feasible configurations at resource level $k$.

The social-emotion interpretation adds an accessible narrative but should not be mistaken for a psychological theory. The graph records only a binary relation, the labels are exclusive categories, and the constraint forbids adjacent equality. Actual emotions are multidimensional, temporally varying, and often shared among friends. Consequently, numerical values should be understood as properties of a chosen network-labeling model.

An empirical study of $100$ social networks could test the hypothesis that most observed values satisfy

$$
3\le \tau_E(G)\le 6.
$$

By Theorem 4.4, this is equivalent to asking whether $P_G(6)>0$ for most sampled networks. Such a study must specify sampling, edge construction, network size, and preprocessing. The theorem supplies the equivalence but does not supply empirical data or guarantee the hypothesis.

Dense subgraphs offer immediate obstructions. If $G$ contains a clique on seven vertices, then $P_G(6)=0$. Conversely, absence of a seven-clique does not by itself ensure six-colorability, because chromatic complexity need not arise only from cliques. The six-label test is therefore a genuine global coloring problem.

## 8. Discussion

The results distinguish three levels of information.

First, **existence** asks whether $P_G(k)>0$. Second, **threshold** asks for the first admissible $k$ where existence begins. Third, **abundance** asks for the magnitude of $P_G(k)$ once positive. The Emotional Threshold Theorem identifies the first two, while friendship graphs illustrate how strongly the third can vary even when the threshold is fixed.

The minimal-positive characterization can also be read as a vanishing theorem. If $\tau_E(G)=k$, then

$$
P_G(3)=P_G(4)=\cdots=P_G(k-1)=0,
$$

while $P_G(k)>0$. This interval of integer zeros is a compressed certificate of infeasibility for all smaller admissible palettes. It suggests studying structural graph properties through forced patterns of vanishing evaluations.

The friendship graph has unusually clean multiplicative structure because triangles interact only through the hub. Once the hub color is chosen, each outer pair contributes an independent factor. More complicated triangle-gluing patterns destroy this independence and may reduce assignment counts. Comparing such graphs could quantify how overlap geometry creates combinatorial entropy loss.

## 9. Future research

Several directions follow naturally.

**Clique minors and vanishing intervals.** One may ask how minor structure forces lower bounds on chromatic thresholds and therefore intervals of zero chromatic evaluations. Hadwiger-type questions can be reframed in this language, while converses may become tractable on restricted minor-closed classes.

**Computational complexity.** For fixed $k\ge 3$, deciding whether $\tau_E(G)\le k$ is exactly the same instance-level decision as testing $P_G(k)>0$. This equality invites comparisons between decision, counting, parameterized, and approximation complexity, especially for succinct graph representations.

**High girth and high thresholds.** Graphs can be locally tree-like yet globally require many colors. The emotional formulation asks for networks of large girth whose chromatic evaluations vanish across a long admissible interval before becoming positive.

**Stability under triangle gluing.** The windmill ratio $2\cdot 10^n$ provides a benchmark for connected graphs assembled from $n$ triangles. A natural extremal problem is to determine whether the windmill maximizes or minimizes the ratio between six-label assignments and minimum-palette assignments under specified triangle-intersection rules, and to characterize equality.

**Empirical network studies.** Real datasets could determine how often six labels suffice, how the threshold correlates with density and community structure, and whether exact counts or approximations reveal distinctions invisible to the threshold alone.

## 10. Conclusion

For a finite graph $G$, the emotional chromatic number is the least proper-coloring palette constrained to be at least three. Above this floor, it is exactly the positivity threshold of the chromatic counting function:

$$
\tau_E(G)\le k \Longleftrightarrow P_G(k)>0.
$$

It equals $k$ precisely when $k$ is admissible, the count at $k$ is positive, and every earlier admissible count is zero. Six labels suffice exactly when $P_G(6)>0$, equivalently when $3\le\tau_E(G)\le6$.

For friendship graphs, the geometry of triangles around a hub gives

$$
P_{F_n}(k)=k(k-1)^n(k-2)^n,
$$

and hence the exact profile

$$
\tau_E(F_n)=3,
\qquad
P_{F_n}(3)=3\cdot2^n,
\qquad
P_{F_n}(6)=6\cdot20^n.
$$

The threshold identifies the onset of possibility; the later polynomial values measure the abundance of choice. Together they provide a concise mathematical language for constrained diversity in networks.