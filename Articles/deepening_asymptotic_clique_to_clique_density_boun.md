# The Downward Gravity of Cliques

## How large complete patterns force a hidden hierarchy of smaller ones

A social network contains a tightly connected group whenever every pair of people in the group knows one another. Network scientists call such a group a **clique**. A clique of size $2$ is an edge, a clique of size $3$ is a triangle, and a clique of size $t$ is a set of $t$ vertices joined by all $\binom{t}{2}$ possible edges.

At first glance, counting cliques of different sizes seems like counting different phenomena. Edges describe pairwise contact; triangles detect mutual trust among triples; larger cliques record increasingly demanding forms of coordination. Yet these counts are not independent. A network rich in large cliques must contain many smaller cliques. The surprising part is that this vague principle has an exact, universal form.

Let $K_r(G)$ denote the number of $r$-vertex cliques in a finite graph $G$. Suppose $G$ has $n$ vertices, and choose integers satisfying $s\le t\le k\le n$. The central result is the following.

> **Clique-to-Clique Shadow Theorem.** If
> $$
> K_t(G)\ge \binom{k}{t},
> $$
> then
> $$
> K_s(G)\ge \binom{k}{s}.
> $$

Thus, having at least as many $t$-cliques as the complete graph on $k$ vertices forces at least as many $s$-cliques as that same complete graph. This holds simultaneously for every pair of clique orders, not merely for triangles and edges.

The theorem is exact. The complete graph on $k$ vertices has precisely $\binom{k}{t}$ cliques of order $t$ and $\binom{k}{s}$ cliques of order $s$, so equality can occur in both the hypothesis and conclusion. No constant can be improved at these binomial thresholds.

## The simple operation behind the theorem

The proof begins with an operation that is almost childlike: erase one vertex.

Take a family $\mathcal F$ of sets, all having size $t$. Its **shadow**, written $\partial\mathcal F$, consists of all $(t-1)$-element sets obtained by deleting one element from a member of $\mathcal F$. Applying the operation repeatedly gives the iterated shadow $\partial^i\mathcal F$. After $i$ deletions, its members have size $t-i$.

Now let $\mathcal C_t(G)$ be the family of vertex sets that form $t$-cliques in $G$. Deleting a vertex from a clique cannot destroy any edge among the vertices that remain. Consequently,

$$
\partial\mathcal C_t(G)\subseteq \mathcal C_{t-1}(G).
$$

Repeating the argument yields the hereditary-containment principle

$$
\partial^i\mathcal C_t(G)\subseteq \mathcal C_{t-i}(G)
\qquad (0\le i\le t).
$$

This statement is the graph-theoretic heart of the story. Every large complete pattern casts a shadow made entirely of smaller complete patterns.

There is one subtlety. Distinct large cliques can cast the same shadow. Two different triangles, for example, may share an edge. We therefore cannot count deletions with naive multiplication. The problem is to determine how much overlap is possible when many sets cast their shadows.

That question is answered by the Kruskal–Katona shadow principle. In the threshold form needed here, it says:

> **Binomial Shadow Principle.** Let $\mathcal F$ be a family of $t$-element sets. If $s\le t\le k$ and
> $$
> |\mathcal F|\ge \binom{k}{t},
> $$
> then
> $$
> |\partial^{t-s}\mathcal F|\ge \binom{k}{s}.
> $$

The family of all $t$-subsets of a fixed $k$-element set shows why these numbers fit perfectly. Its $(t-s)$-fold shadow is exactly the family of all $s$-subsets of that set.

Apply the binomial shadow principle to $\mathcal F=\mathcal C_t(G)$. It produces at least $\binom{k}{s}$ distinct $s$-sets in the iterated shadow. The hereditary-containment principle says that every one of them is an $s$-clique. Hence $K_s(G)\ge\binom{k}{s}$, proving the theorem.

The argument cleanly separates two kinds of reasoning. The shadow principle knows nothing about graphs; it is a theorem about finite set systems. The containment principle knows almost nothing about counting; it uses only the fact that being a clique survives the deletion of vertices. Their combination creates the clique-to-clique bound.

## A concrete example

Imagine a graph with at least $20$ four-vertex cliques. Since

$$
20=\binom{6}{4},
$$

the theorem permits $k=6$. It then forces at least

$$
\binom{6}{3}=20
$$

triangles and at least

$$
\binom{6}{2}=15
$$

edges. The graph need not contain a complete graph on six vertices. The conclusion concerns global counts, not the existence of one common core. Many differently arranged four-cliques may collectively generate the required lower shadows.

For triangles, the familiar specialization is especially transparent. If a graph has at least $\binom{k}{3}$ triangles, then it has at least $\binom{k}{2}$ edges. Every triangle contributes three edges, but shared edges make that elementary count too crude. The shadow theorem captures the most economical possible overlap and gives the sharp binomial threshold.

## From counts to densities

For a graph on $n$ vertices, define the power-normalized clique count

$$
d_r(G)=\frac{K_r(G)}{n^r}.
$$

The theorem immediately gives a density statement. Whenever $s\le t\le k\le n$ and

$$
d_t(G)\ge \frac{\binom{k}{t}}{n^t},
$$

we have

$$
d_s(G)\ge \frac{\binom{k}{s}}{n^s}.
$$

This exact finite implication has a clean asymptotic profile. Consider graphs $G_n$ on $n$ vertices and integers $k_n$ with $k_n/n\to\alpha$, where $0\le\alpha\le1$. If

$$
K_t(G_n)\ge\binom{k_n}{t}
$$

for every $n$, then

$$
\liminf_{n\to\infty} d_s(G_n)\ge \frac{\alpha^s}{s!}.
$$

Indeed, $\binom{k_n}{s}/n^s\to\alpha^s/s!$. At the same time, the threshold in the hypothesis satisfies $\binom{k_n}{t}/n^t\to\alpha^t/t!$. In this sense, the finite theorem traces the curve that one obtains from complete graphs whose size is an $\alpha$ fraction of the ambient vertex set.

This is a threshold theorem, not a complete solution to every prescribed-density optimization problem. Between consecutive values of $\binom{k}{t}$, a sharper theory would interpolate continuously and identify the exact extremal graph structures. Complete multipartite graphs are expected to control those finer envelopes. The present result supplies the discrete skeleton any such interpolation must respect.

## Why shadows travel well

The method matters beyond this one inequality because it exposes a reusable architecture.

First, cliques form a **hereditary family**: every subset of a clique is a clique. The same downward-closed behavior appears throughout combinatorics. Faces of a simplicial complex remain faces after deleting vertices. Frequent itemsets in a database remain frequent only under additional assumptions, but ordinary itemsets themselves are downward closed. Feasible coalitions, compatible feature groups, and complete interaction patterns often have similar inheritance rules.

Second, shadows convert high-order observations into unavoidable low-order structure without assuming randomness. A large collection of complex interactions can overlap heavily, yet there is a hard limit on how efficiently it can reuse its smaller components. The binomial shadow principle quantifies that limit.

Third, the proof is constructive enough to inspire computation. Given a graph, one may enumerate its $t$-cliques, repeatedly delete one vertex from each set, deduplicate, and compare the resulting family with the graph’s $s$-cliques. This procedure is not the fastest way to count cliques in large networks—the number of candidates can grow like $n^t$—but it makes the theorem visible. Each iteration reveals how many distinct lower-dimensional patterns survive after overlaps are merged.

In data analysis, the idea warns against treating high-order motifs as isolated statistics. If a collaboration network contains an abundance of fully connected teams of size $t$, then its lower-order collaboration counts must cross explicit thresholds. In topology, the clique complex of a graph turns each clique into a simplex, and the theorem becomes a constraint on its face numbers. In extremal graph theory, it supplies a universal bridge between every two levels of the clique hierarchy.

## What the theorem does—and does not—say

Precision is important. The theorem requires $s\le t\le k\le n$. The condition $t\le k$ keeps the binomial threshold in its natural range, while $k\le n$ ensures that comparison with a $k$-vertex complete graph is meaningful inside an $n$-vertex setting.

The conclusion is a lower bound on the total number of smaller cliques. It does not say that all those cliques lie inside one set of $k$ vertices. Nor does equality in the count automatically provide a stability theorem describing graphs that nearly attain the bound. Such structural questions ask how close an almost extremal graph must be to a canonical construction, and they require more delicate information about where overlap occurs at each shadow step.

The theorem also moves downward, from larger cliques to smaller ones. No comparable unconditional implication runs upward: a graph may have many edges and no triangles at all. Downward inheritance is powerful precisely because every large clique contains all of its smaller faces.

## A hierarchy held together by deletion

The deepest feature of the result is its economy. A graph may be vast, irregular, and assembled without any visible global plan. Still, once its inventory of $t$-cliques crosses the binomial threshold $\binom{k}{t}$, its inventory at every lower order $s$ must cross $\binom{k}{s}$.

The mechanism is not a complicated transformation. It is repeated deletion, followed by the recognition that overlap has limits. Large cliques cast shadows; those shadows remain cliques; and finite set theory dictates how small the shadow can be.

This turns a collection of separate motif counts into a single descending hierarchy. Triangles constrain edges, four-cliques constrain triangles, and every higher order constrains every lower order through the same law. The complete graph provides the measuring stick, while the shadow provides the bridge. What looks like a web of unrelated statistics is, underneath, one coherent combinatorial geometry.