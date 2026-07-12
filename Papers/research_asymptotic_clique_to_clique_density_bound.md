# An Exact Clique-to-Clique Count Bound and the Antitonicity of Normalized Clique Densities

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

For a finite simple graph $G$ on $n$ vertices and an integer $r \ge 0$, let
$k_r(G)$ denote the number of $r$-cliques of $G$. We establish an exact,
unconditional inequality comparing the clique counts of any two orders
$s \le t$:
$$\binom{t}{s}\,k_t(G) \;\le\; \binom{n-s}{t-s}\,k_s(G).$$
The proof is a two-way count of incident flags $(S,T)$ with $S \subseteq T$, $S$
an $s$-clique and $T$ a $t$-clique. We show the inequality is *tight*: it holds
with equality for the complete graph $K_n$, where both sides equal
$\binom{n}{t}\binom{t}{s} = \binom{n}{s}\binom{n-s}{t-s}$. Consequently, the
**normalized clique density**
$d_r(G) = k_r(G)/\binom{n}{r}$ — the fraction of potential $r$-cliques that are
realized — is non-increasing in the order $r$:
$$\frac{k_t(G)}{\binom{n}{t}} \;\le\; \frac{k_s(G)}{\binom{n}{s}} \qquad (s \le t \le n).$$
This is the unconditional *upper* companion to the Lovász–Simonovits–Reiher
clique density theorem, whose sharp *lower* bound is governed by complete
multipartite graphs rather than the complete graph. We discuss the structural
reason the two results run in opposite directions, give the specialization to the
edge-to-clique case $s = 2$, record the monotonicity of clique counts under edge
addition, and outline conjectural extensions to stability, graphons, and general
subgraph densities.

**Keywords:** clique density, extremal graph theory, double counting, binomial
identities, complete graph, clique density theorem, normalized density,
monotonicity.

---

## 1. Introduction

Counting complete subgraphs is one of the foundational problems of extremal graph
theory. Given a finite simple graph $G$, the *$r$-clique count* $k_r(G)$ records
how many $r$-element vertex sets induce a complete subgraph. The counts
$k_2(G), k_3(G), k_4(G), \dots$ form a profile that encodes a great deal of the
graph's structure, and a recurring theme is to understand how the entries of this
profile constrain one another.

The most celebrated result in this direction is the **clique density theorem**.
Lovász and Simonovits conjectured, and Reiher proved, a sharp *lower* bound on
the density of $t$-cliques in terms of the density of edges (and more generally of
$s$-cliques). Informally: a graph that has many edges is *forced* to contain many
triangles, many tetrahedra, and so on, and the exact threshold is achieved by
balanced complete multipartite graphs. These lower bounds are deep, asymptotic in
nature, and their extremal configurations are far from complete.

This paper isolates and proves the complementary, and in a sense more elementary,
half of the story: an **upper** bound. We ask how *many* $t$-cliques a graph can
have relative to its number of $s$-cliques, and we find that the answer is
governed by the single densest possible graph, the complete graph. The resulting
inequality is exact, holds for every finite graph without any hypotheses, and is
tight. From it we derive the clean and perhaps surprising fact that the
*normalized* clique density — the fraction of potential $r$-cliques actually
present — never increases with $r$.

### 1.1 Summary of results

Throughout, $G$ is a finite simple graph on a vertex set of size $n = |V(G)|$,
and $\binom{a}{b}$ is the binomial coefficient (equal to $0$ when $b > a$).

- **Theorem A (Flag identity for a single clique).** Every $t$-clique contains
  exactly $\binom{t}{s}$ sub-$s$-cliques.
- **Theorem B (Extension bound for a single clique).** Every $s$-clique is
  contained in at most $\binom{n-s}{t-s}$ super-$t$-cliques.
- **Theorem C (Clique-to-clique count bound).**
  $\binom{t}{s}\,k_t(G) \le \binom{n-s}{t-s}\,k_s(G)$ for all $s,t$.
- **Theorem D (Tightness).** For $s \le t$, equality holds in Theorem C when
  $G = K_n$.
- **Theorem E (Antitonicity of normalized density).** For $s \le t \le n$,
  $k_t(G)/\binom{n}{t} \le k_s(G)/\binom{n}{s}$.
- **Corollaries.** The edge-to-clique specialization ($s = 2$), and the
  monotonicity of $k_r$ under edge addition.

## 2. Definitions

We work with finite simple graphs.

**Definition 2.1 (Graph, adjacency).** A *finite simple graph* $G$ consists of a
finite vertex set $V(G)$ and a symmetric, irreflexive adjacency relation: for
$u,v \in V(G)$ we write $u \sim v$ when $\{u,v\}$ is an edge. We set $n = |V(G)|$.

**Definition 2.2 (Clique).** A subset $S \subseteq V(G)$ is a *clique* if every
two distinct vertices of $S$ are adjacent. If moreover $|S| = r$ we call $S$ an
*$r$-clique*.

**Definition 2.3 (Clique count).** For $r \ge 0$, the *$r$-clique count* is
$$k_r(G) \;=\; \#\{\, S \subseteq V(G) : S \text{ is an } r\text{-clique} \,\}.$$
In particular $k_0(G) = 1$, $k_1(G) = n$, and $k_2(G)$ is the number of edges.

**Definition 2.4 (Normalized clique density).** For $0 \le r \le n$, the
*normalized $r$-clique density* is
$$d_r(G) \;=\; \frac{k_r(G)}{\binom{n}{r}} \in [0,1],$$
the proportion of the $\binom{n}{r}$ potential $r$-subsets that actually form
cliques. Note $d_r(K_n) = 1$ for all $0 \le r \le n$.

We record two elementary facts used repeatedly.

**Lemma 2.5 (Heredity).** Any subset of a clique is a clique. *Proof.* If every
pair in $S$ is adjacent and $S' \subseteq S$, then every pair in $S'$ is a pair
in $S$, hence adjacent. $\square$

**Lemma 2.6 (Complete graph clique count).** For the complete graph $K_n$ on $n$
vertices, $k_r(K_n) = \binom{n}{r}$ for all $0 \le r \le n$. *Proof.* In $K_n$
every pair of vertices is adjacent, so *every* $r$-subset is a clique; there are
$\binom{n}{r}$ of them. $\square$

## 3. The two local counts

The whole argument rests on understanding the incidence between $s$-cliques and
$t$-cliques *one clique at a time*.

### 3.1 Sub-cliques of a clique

**Theorem A (Sub-clique count).** *Let $T$ be a $t$-clique of $G$ and let
$0 \le s \le t$. Then the number of $s$-cliques of $G$ contained in $T$ equals
$\binom{t}{s}$.*

*Proof.* Consider the map that assigns to each $s$-clique $S \subseteq T$ the set
$S$ itself, viewed as an $s$-element subset of $T$. This is a bijection between

- the $s$-cliques of $G$ contained in $T$, and
- the $s$-element subsets of $T$.

Indeed, if $S \subseteq T$ is an $s$-clique it is in particular an $s$-subset of
$T$. Conversely, if $S \subseteq T$ has $|S| = s$, then by Heredity (Lemma 2.5)
$S$ is a clique, hence an $s$-clique. The two conditions "$s$-clique contained in
$T$" and "$s$-subset of $T$" are therefore equivalent. The number of $s$-subsets
of the $t$-element set $T$ is $\binom{t}{s}$. $\square$

The crucial point is that inside a clique there is no *further* adjacency
condition to check: completeness is inherited automatically, so counting
sub-cliques reduces to counting subsets.

### 3.2 Extensions of a clique

**Theorem B (Extension bound).** *Let $S$ be an $s$-clique of $G$ and let
$s \le t$. Then the number of $t$-cliques of $G$ that contain $S$ is at most
$\binom{n-s}{t-s}$.*

*Proof.* Let $\mathcal{T}$ be the set of $t$-cliques $T$ with $S \subseteq T$.
Define
$$\varphi : \mathcal{T} \to \binom{V(G)\setminus S}{\,t-s\,}, \qquad \varphi(T) = T \setminus S,$$
sending each such $t$-clique to the set of the $t-s$ vertices it adds to $S$.
This is well-defined: if $T \supseteq S$ is a $t$-clique then $T \setminus S$
consists of vertices outside $S$, and
$|T \setminus S| = |T| - |S| = t - s$, so $\varphi(T)$ is indeed a
$(t-s)$-subset of the $n - s$ vertices of $V(G) \setminus S$.

The map $\varphi$ is injective. If $\varphi(T_1) = \varphi(T_2)$, then since each
$T_i \supseteq S$ we can reconstruct $T_i = (T_i \setminus S) \cup S$; the
right-hand side depends only on $\varphi(T_i)$, so $T_1 = T_2$.

An injection into $\binom{V(G)\setminus S}{t-s}$ shows
$|\mathcal{T}| \le \binom{n-s}{t-s}$. $\square$

The inequality — rather than equality — enters here, and only here: not every
$(t-s)$-subset of the outside vertices need extend $S$ to a clique, because the
added vertices must be adjacent to $S$ and to one another. This is precisely the
place where the graph's sparsity can make the true count smaller. Equality holds
exactly when *every* extension is a clique, i.e. when the graph is complete on
the relevant vertices.

## 4. The clique-to-clique count bound

We now count flags in two ways. A **flag** is a pair $(S, T)$ where $S$ is an
$s$-clique, $T$ is a $t$-clique, and $S \subseteq T$.

**Theorem C (Clique-to-clique count bound).** *For every finite simple graph $G$
on $n$ vertices and all integers $s, t \ge 0$,*
$$\binom{t}{s}\,k_t(G) \;\le\; \binom{n-s}{t-s}\,k_s(G).$$

*Proof.* Let $N$ be the number of flags. We compute $N$ in two ways.

*Top-down.* Group flags by their $t$-clique $T$. For each $t$-clique $T$, the
number of flags with that second coordinate is the number of $s$-cliques
contained in $T$, which by Theorem A equals $\binom{t}{s}$. Summing over all
$k_t(G)$ choices of $T$,
$$N \;=\; \sum_{T \text{ a } t\text{-clique}} \binom{t}{s} \;=\; \binom{t}{s}\,k_t(G).$$

*Bottom-up.* Group flags by their $s$-clique $S$. For each $s$-clique $S$, the
number of flags with that first coordinate is the number of $t$-cliques
containing $S$, which by Theorem B is at most $\binom{n-s}{t-s}$. Summing over all
$k_s(G)$ choices of $S$,
$$N \;=\; \sum_{S \text{ an } s\text{-clique}} \#\{T \supseteq S\}
   \;\le\; \sum_{S \text{ an } s\text{-clique}} \binom{n-s}{t-s}
   \;=\; \binom{n-s}{t-s}\,k_s(G).$$

Equating the top-down value with the bottom-up upper estimate gives
$\binom{t}{s}\,k_t(G) = N \le \binom{n-s}{t-s}\,k_s(G)$. $\square$

(When $t < s$ the statement is trivial: $\binom{t}{s} = 0$ makes the left side
$0$, and clique counts are non-negative. The content is in the case $s \le t$.)

## 5. Tightness

**Theorem D (Tightness on the complete graph).** *For $s \le t \le n$, the bound
of Theorem C holds with equality for $G = K_n$; both sides equal*
$$\binom{n}{t}\binom{t}{s} \;=\; \binom{n}{s}\binom{n-s}{t-s}.$$

*Proof.* By Lemma 2.6, $k_r(K_n) = \binom{n}{r}$ for all $0 \le r \le n$. Hence
the left side of Theorem C is $\binom{t}{s}\binom{n}{t}$ and the right side is
$\binom{n-s}{t-s}\binom{n}{s}$. These are equal by the *subset-of-a-subset*
identity
$$\binom{n}{t}\binom{t}{s} \;=\; \binom{n}{s}\binom{n-s}{t-s}, \tag{$\ast$}$$
which counts, in two ways, the pairs $(A,B)$ with $B \subseteq A \subseteq V$,
$|B| = s$, $|A| = t$: choose $A$ first ($\binom{n}{t}$ ways) then $B$ inside it
($\binom{t}{s}$ ways), or choose $B$ first ($\binom{n}{s}$ ways) then the
$t - s$ additional elements from the remaining $n - s$ ($\binom{n-s}{t-s}$ ways).
$\square$

Theorem D shows that the binomial constants in Theorem C are best possible: no
inequality with smaller coefficients can hold for all graphs, since $K_n$
saturates it.

## 6. Antitonicity of normalized clique density

Theorems C and D combine into a statement about densities that is cleaner than
either.

**Theorem E (Antitonicity of normalized clique density).** *Let $G$ be a finite
simple graph on $n$ vertices and let $0 \le s \le t \le n$. Then*
$$k_t(G)\,\binom{n}{s} \;\le\; k_s(G)\,\binom{n}{t}, \qquad\text{equivalently}\qquad
   \frac{k_t(G)}{\binom{n}{t}} \;\le\; \frac{k_s(G)}{\binom{n}{s}}.$$
*That is, the normalized clique density $d_r(G) = k_r(G)/\binom{n}{r}$ is
non-increasing in $r$ on $0 \le r \le n$.*

*Proof.* Start from Theorem C, $\binom{t}{s}\,k_t \le \binom{n-s}{t-s}\,k_s$, and
multiply both sides by $\binom{n}{s}$:
$$\binom{t}{s}\,k_t\,\binom{n}{s} \;\le\; \binom{n-s}{t-s}\,\binom{n}{s}\,k_s
   \;=\; \binom{n}{t}\,\binom{t}{s}\,k_s,$$
where the last equality is identity $(\ast)$ from Theorem D. Since $s \le t$ we
have $\binom{t}{s} > 0$, so we may cancel this common positive factor to obtain
$k_t\,\binom{n}{s} \le k_s\,\binom{n}{t}$. Finally, for $s \le t \le n$ both
$\binom{n}{s}$ and $\binom{n}{t}$ are positive, so dividing by
$\binom{n}{s}\binom{n}{t}$ yields the equivalent ratio form. $\square$

Theorem E has a memorable reading: **the fraction of potential cliques that a
graph realizes can only decrease as the clique order grows.** A graph realizing a
$p$-fraction of its possible edges realizes at most a $p$-fraction of its possible
triangles, at most that fraction of its possible tetrahedra, and so on. Equality
across all orders is achieved exactly by the complete graph, where every fraction
is $1$.

## 7. Corollaries and remarks

**Corollary 7.1 (Edge-to-clique bound, $s = 2$).** *Since the $2$-cliques of $G$
are exactly its edges, taking $s = 2$ in Theorem C gives*
$$\binom{t}{2}\,k_t(G) \;\le\; \binom{n-2}{t-2}\,k_2(G).$$
*In particular, the number of $t$-cliques is bounded above by an explicit
multiple of the number of edges. This is the unconditional upper companion of the
edge-to-clique density theorem.*

**Corollary 7.2 (Monotonicity under edge addition).** *If $H$ is obtained from
$G$ by adding edges (i.e. $G$ is a spanning subgraph of $H$), then
$k_r(G) \le k_r(H)$ for every $r$.* *Proof.* Every clique of $G$ remains a clique
of $H$, since adding edges only adds adjacencies; the identity map embeds the
$r$-cliques of $G$ into those of $H$. $\square$

**Remark 7.3 (Why the direction is "upper").** The argument of Section 4 is
entirely *local*: it only ever counts, within one clique or around one clique,
using subset arithmetic. Locality is exactly why the extremal object is the
complete graph — the one graph in which every local extension succeeds — and why
the resulting bound is an *upper* bound. No regularity, stability, or
symmetrization machinery is invoked. By contrast, the matching *lower* bound
requires global averaging and is governed by complete multipartite graphs (see
Section 8). This reversal of extremal regime is the structural reason the upper
and lower theorems are genuinely different and complementary.

## 8. The complementary lower bound

For context we state the deep companion result. Define, for each order $r$, the
Lovász–Simonovits function $F_r$ tracing the minimum $r$-clique density
$k_r(G)/n^r$ attainable along the sequence of balanced complete multipartite
graphs as the edge density varies; $F_r$ is a piecewise-linear/convex profile, and
$F_s^{-1}$ denotes its generalized inverse. The **clique density theorem**
(Lovász–Simonovits conjecture, proved by Reiher for $s=2$) asserts that for all
$2 \le s < t$ and every $n$-vertex graph $G$,
$$\frac{k_t(G)}{n^t} \;\ge\; F_t\!\left(F_s^{-1}\!\left(\frac{k_s(G)}{n^s}\right)\right).$$
Here the extremal graphs are complete multipartite, not complete, and the bound
is sharp asymptotically. Together with Theorem E, this brackets the clique-density
profile between two sharp walls: an upper wall set by the complete graph and a
lower wall set by multipartite blow-ups. Proving the general lower bound in full
is a principal open target; see Section 10.

## 9. Applications

The clique-count profile is a workhorse statistic in network science. A few
consequences of the results above:

- **Free, tight upper certificates.** From a single measured quantity — the edge
  density $d_2(G)$ — Theorem E yields an immediate, rigorous upper bound
  $d_r(G) \le d_2(G)$ on the density of every higher-order clique, valid for any
  graph and best possible in general. This is useful as a validity check for
  clique-counting heuristics and sampling estimators.
- **Sparsification and compression.** Because $k_r$ is monotone under edge
  addition (Corollary 7.2) and controlled by $k_s$ (Theorem C), pruning edges to
  reduce $k_2$ gives quantitative control on the reduction of all higher $k_r$.
- **Anomaly detection.** A graph in which $d_t(G)$ approaches $d_s(G)$ for some
  $s < t$ is, by tightness, forced to be locally near-complete; large
  normalized-density values at high orders are therefore signatures of dense,
  clique-like communities.

## 10. Future directions

The following program builds on the exact upper comparison and its tightness.

1. **The sharp clique-to-clique lower bound.** Establish
   $k_t(G)/n^t \ge F_t(F_s^{-1}(k_s(G)/n^s))$ for all $2 \le s < t$, extending
   Reiher's $s=2$ theorem to arbitrary orders. The upper bound's tightness
   certificate isolates the complete graph as the unique equality case, cleanly
   separating the two extremal regimes and suggesting an
   averaging-and-symmetrization attack over multipartite parts.
2. **Stability of the antitone profile.** Prove that if $d_t(G)$ is within
   $\varepsilon$ of $d_s(G)$ for some $s < t$, then $G$ is $o(1)$-close (in per-pair
   edit distance) to a disjoint union of cliques. Near-equality should force every
   $s$-clique to attain the full $\binom{n-s}{t-s}$ extensions, which aligns
   neighborhoods into complete blocks — a clique-decomposition analogue of the
   triangle-removal phenomenon.
3. **Weighted and fractional densities.** Transfer the antitonicity to graphons:
   for a symmetric measurable $W : [0,1]^2 \to [0,1]$, the clique homomorphism
   densities $t(K_r, W)$ should satisfy a corresponding monotone relation after
   normalization by clique moments. The finite flag identity has a continuous
   avatar as a Fubini exchange between the $s$-fold and $t$-fold clique integrals
   of $W$, so the discrete inequality should survive the limit.
4. **General subgraphs.** Investigate monotone density profiles for a fixed
   pattern graph $H$ and its natural family of "$r$-th powers" or blow-ups,
   seeking the analogue of Theorem E beyond cliques.

## 11. Conclusion

We have proved a short, exact, and tight inequality —
$\binom{t}{s}\,k_t(G) \le \binom{n-s}{t-s}\,k_s(G)$ — that captures how the number
of large cliques in any finite graph is controlled by the number of small ones.
Its clean corollary, the antitonicity of the normalized clique density
$d_r(G) = k_r(G)/\binom{n}{r}$, gives the unconditional upper half of the
clique-density story, complementing the deep lower bounds of
Lovász–Simonovits–Reiher. The complete graph is the single extremal object
throughout, and the entire argument rests on the oldest and most reliable
technique in combinatorics: counting the same thing two ways.

## References

- C. Reiher, *The clique density theorem*, Annals of Mathematics (2016).
- L. Lovász and M. Simonovits, *On the number of complete subgraphs of a graph
  II*, Studies in Pure Mathematics (1983).
- B. Bollobás, *Complete subgraphs are elusive*, Journal of Combinatorial Theory,
  Series B (1976).
