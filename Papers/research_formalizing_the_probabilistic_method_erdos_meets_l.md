# Finite Avoidance and Extremal Structure: Ramsey Counting, Conditional Survivors, and Balanced Turán Graphs

**Aristotle**  
**July 19, 2026**

## Abstract

The probabilistic method proves existence by showing that forbidden configurations do not exhaust a finite space of candidates. This paper develops that principle as exact finite combinatorics. First, red-blue colorings of the complete graph $K_n$ are represented by subsets of its edge set. Exact Boolean-lattice counts show that if $k\le n$ and

$$
2\binom{n}{k}<2^{\binom{k}{2}},
$$

then some coloring contains neither a red nor a blue copy of $K_k$, and hence $R(k,k)>n$. The bound $\binom{n}{k}\le n^k$ yields a simpler sufficient condition and the concrete conclusion $R(10,10)>16$. Second, a finite conditional-avoidance theorem is proved: if every newly imposed bad set occupies strictly fewer than all outcomes surviving the previous constraints, then a common survivor exists. This isolates the combinatorial core needed by local-lemma arguments while making no unsupported dependency or runtime claim. Third, balanced complete bipartite graphs are shown to be triangle-free with exactly one quarter of all possible ordered-square edge scale, attaining Mantel’s bound on $2m$ vertices. Algorithms for exhaustive Ramsey search, survivor filtering, and Turán graph generation are analyzed. The synthesis presents random avoidance and deterministic extremality as complementary cardinality principles and delineates the additional estimates required for the symmetric Lovász local lemma, classical asymptotic Ramsey bounds, and efficient resampling.

## 1. Introduction

Existence proofs in combinatorics often face a mismatch between local constraints and a global object. A coloring must avoid every monochromatic clique; an assignment must avoid every bad event; a dense graph must avoid a forbidden subgraph. Constructing the desired object one decision at a time may be difficult because local choices interact. The probabilistic method changes the unit of analysis: instead of designing one candidate, it counts or measures the entire candidate space.

In a finite setting, the foundational logic is elementary. Let $\Omega$ be a finite set and let $B\subseteq\Omega$ be the set of failures. If $|B|<|\Omega|$, then $\Omega\setminus B$ is nonempty. For a family of failures $B_i$, one may use the union estimate

$$
\left|\bigcup_i B_i\right|\le\sum_i|B_i|.
$$

If the sum on the right is below $|\Omega|$, a successful candidate exists. Probability is obtained merely by dividing all cardinalities by $|\Omega|$.

This paper develops three manifestations of that principle. The first is an exact first-moment argument for diagonal Ramsey numbers. A coloring of $K_n$ is a point of a Boolean cube with $\binom{n}{2}$ coordinates. Requiring a fixed $k$-vertex set to be monochromatic fixes $\binom{k}{2}$ coordinates; all other coordinates remain free. This gives an exact count of each bad cylinder and therefore a clean union-bound criterion.

The second manifestation is conditional rather than global. After some constraints have been imposed, one studies the set of candidates that remain. If the next constraint never removes all current survivors, induction gives a global survivor. This finite conditional-avoidance theorem is deliberately separated from the analytic estimates of the Lovász local lemma. It identifies what a dependency calculation must prove but does not assume that calculation has already been obtained.

The third manifestation is extremal. Instead of finding one point outside a union of bad sets, Turán-type problems maximize the size of a structure under forbidden-pattern constraints. In the triangle-free case, a balanced complete bipartite graph provides a sharp construction: every edge crosses a two-part partition, so triangles are impossible, while balance maximizes the number of cross-edges.

The contributions are therefore exact but carefully delimited:

1. an exact finite Ramsey counting theorem;
2. a power-bound corollary and the instance $R(10,10)>16$;
3. a finite conditional-avoidance theorem based on strict survivor loss;
4. exact triangle-freeness and edge sharpness for balanced complete bipartite graphs;
5. explicit algorithms illustrating the constructive content and computational cost of each result.

The classical asymptotic scale $R(k,k)>2^{k/2}$, the symmetric Lovász local lemma under $e p(d+1)\le1$, the Moser–Tardos runtime analysis, and the general $K_{r+1}$-free Turán theorem are discussed as future extensions rather than claimed consequences.

## 2. Finite graphs, colorings, and Ramsey notation

A **simple graph** $G=(V,E)$ consists of a finite vertex set $V$ and a set $E$ of unordered pairs of distinct vertices. The complete graph $K_n$ has $n$ vertices and contains every possible edge. Its number of edges is

$$
|E(K_n)|=\binom{n}{2}.
$$

A **red-blue edge coloring** of $K_n$ assigns one of two colors to each edge. It may equivalently be represented by the subset $R\subseteq E(K_n)$ of red edges; the complement $E(K_n)\setminus R$ is the set of blue edges.

For $T\subseteq V$ with $|T|=k$, write $E(T)$ for the set of edges with both endpoints in $T$. Then

$$
|E(T)|=\binom{k}{2}.
$$

The set $T$ spans a red $K_k$ exactly when $E(T)\subseteq R$. It spans a blue $K_k$ exactly when $E(T)\cap R=\varnothing$.

The diagonal Ramsey number $R(k,k)$ is the least integer $N$ such that every red-blue coloring of $K_N$ contains a monochromatic $K_k$. Thus proving $R(k,k)>n$ is equivalent to proving that at least one coloring of $K_n$ has no monochromatic $K_k$.

A graph is **triangle-free** if it has no three vertices that are pairwise adjacent. A complete bipartite graph with parts $A$ and $B$ contains all edges joining $A$ to $B$ and no edges within either part. If $|A|=|B|=m$, it is called balanced and has $2m$ vertices.

## 3. Boolean-lattice counts

The edge-subset representation reduces coloring counts to elementary facts about power sets.

### Lemma 3.1. Superset interval count

Let $G$ be a finite set and let $S\subseteq G$. The number of subsets $A\subseteq G$ satisfying $S\subseteq A$ is

$$
2^{|G|-|S|}.
$$

**Proof sketch.** Every such $A$ is uniquely of the form $S\cup B$, where $B\subseteq G\setminus S$. Conversely, every $B\subseteq G\setminus S$ gives an admissible $A$. Since $G\setminus S$ has $|G|-|S|$ elements, it has $2^{|G|-|S|}$ subsets. $\square$

### Lemma 3.2. Disjoint-subset count

Let $G$ be a finite set and let $S\subseteq G$. The number of subsets $A\subseteq G$ satisfying $A\cap S=\varnothing$ is

$$
2^{|G|-|S|}.
$$

**Proof sketch.** Such an $A$ is precisely a subset of $G\setminus S$. Equivalently, the complement map $A\mapsto G\setminus A$ bijects subsets disjoint from $S$ with subsets containing $S$. Lemma 3.1 supplies the count. $\square$

These two lemmas express red-blue symmetry. A fixed clique is red when its internal edge set is contained in the red set; it is blue when that internal edge set is disjoint from the red set. Both events have the same cardinality.

### Proposition 3.3. Count for a fixed monochromatic clique

Fix a $k$-vertex subset $T$ of $K_n$. The number of red-blue colorings in which $T$ spans a red $K_k$ is

$$
2^{\binom{n}{2}-\binom{k}{2}},
$$

and the number in which $T$ spans a blue $K_k$ is the same.

**Proof sketch.** Use the full edge set as $G$ and the internal edge set $E(T)$ as $S$. The red count is Lemma 3.1; the blue count is Lemma 3.2. $\square$

## 4. The finite Ramsey counting theorem

There are $2^{\binom{n}{2}}$ red-blue colorings of $K_n$. For every $k$-vertex set $T$, define $B_T^{\mathrm{red}}$ and $B_T^{\mathrm{blue}}$ as the colorings in which $T$ is respectively all red or all blue.

### Theorem 4.1. Ramsey counting criterion

Let $k$ and $n$ be natural numbers with $k\le n$. If

$$
2\binom{n}{k}<2^{\binom{k}{2}},
$$

then some red-blue coloring of $K_n$ contains no monochromatic $K_k$. Consequently,

$$
R(k,k)>n.
$$

**Proof sketch.** There are $\binom{n}{k}$ choices of $T$. By Proposition 3.3, each red or blue bad class has cardinality $2^{\binom{n}{2}-\binom{k}{2}}$. Therefore the union of all bad classes has size at most

$$
2\binom{n}{k}2^{\binom{n}{2}-\binom{k}{2}}.
$$

The hypothesis makes this strictly smaller than

$$
2^{\binom{k}{2}}2^{\binom{n}{2}-\binom{k}{2}}
=2^{\binom{n}{2}},
$$

where $k\le n$ ensures $\binom{k}{2}\le\binom{n}{2}$. Hence the bad union does not cover the coloring space. A coloring outside it contains no red and no blue $K_k$. $\square$

The hypothesis $k\le n$ is natural in the lower-bound regime. If $k>n$, no $K_k$ fits inside $K_n$, so the conclusion remains true for a simpler reason; however, the displayed factorization of the total coloring count is formulated for the nonnegative exponent difference ensured by $k\le n$.

### Corollary 4.2. Power criterion

Let $k\le n$. If

$$
2n^k<2^{\binom{k}{2}},
$$

then $R(k,k)>n$.

**Proof sketch.** The elementary inequality $\binom{n}{k}\le n^k$ implies

$$
2\binom{n}{k}\le2n^k<2^{\binom{k}{2}}.
$$

Apply Theorem 4.1. $\square$

### Corollary 4.3. A concrete diagonal lower bound

There is a red-blue coloring of $K_{16}$ containing no monochromatic $K_{10}$. Hence

$$
R(10,10)>16.
$$

**Proof sketch.** Since $10\le16$ and

$$
2\cdot16^{10}=2\cdot(2^4)^{10}=2^{41}<2^{45}=2^{\binom{10}{2}},
$$

Corollary 4.2 applies. $\square$

### 4.1. Probabilistic interpretation

If a coloring is sampled uniformly, a fixed $T$ is monochromatic with probability

$$
2\cdot2^{-\binom{k}{2}}=2^{1-\binom{k}{2}}.
$$

Let $X$ count monochromatic $k$-vertex sets. Linearity of expectation gives

$$
\mathbb{E}[X]=\binom{n}{k}2^{1-\binom{k}{2}}.
$$

Theorem 4.1 assumes $\mathbb{E}[X]<1$. Since $X$ is a nonnegative integer, not every coloring can satisfy $X\ge1$; therefore some coloring has $X=0$. This is the same finite count normalized by the total number of colorings.

The exact theorem should not be confused with the sharper asymptotic statement at the classical exponential scale. Deriving a uniform lower bound near $2^{k/2}$ requires additional estimates for $\binom{n}{k}$. The Boolean-lattice calculation establishes the combinatorial core; asymptotic arithmetic remains a distinct step.

## 5. Conditional survival in an arbitrary finite space

A global union bound can be wasteful because bad events overlap. Conditional methods instead examine what remains after some constraints have already been applied.

Let $\Omega$ be a nonempty finite set of outcomes, let $I$ be a finite set of constraint indices, and assign to each $i\in I$ a bad set $B_i\subseteq\Omega$. For $S\subseteq I$, define

$$
\operatorname{Surv}(S)
=
\{\omega\in\Omega:\text{ for every }i\in S,\ \omega\notin B_i\}.
$$

### Lemma 5.1. One-step filtering identity

For every $S\subseteq I$ and $i\in I$,

$$
\operatorname{Surv}(S\cup\{i\})
=
\operatorname{Surv}(S)\setminus B_i.
$$

**Proof sketch.** Membership in the left side means avoiding all bad sets indexed by $S$ and also avoiding $B_i$. This is exactly membership in the right side. $\square$

### Lemma 5.2. Strict loss leaves a survivor

If

$$
|\operatorname{Surv}(S)\cap B_i|
<
|\operatorname{Surv}(S)|,
$$

then $\operatorname{Surv}(S\cup\{i\})$ is nonempty.

**Proof sketch.** If no survivor remained after adding $i$, then every current survivor would lie in $B_i$, making the two displayed cardinalities equal. This contradicts strict inequality. $\square$

### Theorem 5.3. Finite conditional-avoidance principle

Suppose $\Omega$ is nonempty. Assume that for every $S\subseteq I$ and every $i\in I\setminus S$, whenever $\operatorname{Surv}(S)$ is nonempty,

$$
|\operatorname{Surv}(S)\cap B_i|
<
|\operatorname{Surv}(S)|.
$$

Then there exists $\omega\in\Omega$ such that $\omega\notin B_i$ for every $i\in I$.

**Proof sketch.** Order the finite set $I$ as $i_1,\ldots,i_r$. Initially, $\operatorname{Surv}(\varnothing)=\Omega$ is nonempty. Inductively assume that $\operatorname{Surv}(\{i_1,\ldots,i_j\})$ is nonempty. The hypothesis and Lemma 5.2 show that adding $i_{j+1}$ leaves a nonempty survivor set. After all indices have been added, $\operatorname{Surv}(I)$ is nonempty, and any of its elements avoids every $B_i$. $\square$

### 5.1. Relation to local-lemma reasoning

The symmetric Lovász local lemma is commonly stated as follows: if each event has probability at most $p$, each is dependent on at most $d$ others, and

$$
ep(d+1)\le1,
$$

then all bad events can be avoided with positive probability. Theorem 5.3 is not that result. It contains neither a probability distribution nor a dependency graph, and it does not prove that the displayed analytic criterion implies its strict-cardinality hypothesis.

Its role is structural. A finite local-lemma proof may aim to show that dependency estimates force a positive conditional survivor ratio, for example a bound of the form

$$
\frac{|\operatorname{Surv}(S)\setminus B_i|}
{|\operatorname{Surv}(S)|}>0.
$$

Once such a statement is available uniformly, Theorem 5.3 completes the existence argument. This cleanly separates analytic dependency estimates from finite induction.

Nor does Theorem 5.3 establish an efficient search algorithm in an implicitly represented outcome space. Explicit filtering may require enumerating all of $\Omega$. Efficient variable-model algorithms need additional resampling analysis, often encoded by witness trees.

## 6. Balanced Turán graphs and sharp triangle avoidance

Let $A$ and $B$ be disjoint sets with $|A|=|B|=m$. Define $T_{2m,2}$ to have vertex set $A\cup B$, all edges between $A$ and $B$, and no edges within either part.

### Theorem 6.1. Balanced Turán sharpness

For every natural number $m$, the graph $T_{2m,2}$ is triangle-free and has exactly $m^2$ edges. Equivalently,

$$
4|E(T_{2m,2})|=(2m)^2.
$$

**Proof sketch.** Among any three vertices, at least two lie in the same one of the two parts. Those two are nonadjacent, so the three vertices cannot form a triangle. Every edge is determined uniquely by choosing one endpoint in $A$ and one in $B$, giving $|A||B|=m^2$. The displayed equality follows immediately. $\square$

Mantel’s theorem states that every triangle-free graph on $N$ vertices has at most $\lfloor N^2/4\rfloor$ edges. For $N=2m$, Theorem 6.1 supplies the equality construction. The theorem here records both structural avoidance and exact attainment; a proof of the upper bound for arbitrary triangle-free graphs is logically separate.

The broader Turán theorem says that a $K_{r+1}$-free graph is maximized by a complete $r$-partite graph with parts as equal as possible. Its leading edge count is

$$
\left(1-\frac1r\right)\frac{n^2}{2},
$$

with integer rounding determined by the part sizes. The present sharp result is the balanced case $r=2$ and even $n$.

### Theorem 6.2. Ramsey–Turán finite synthesis

There exists a red-blue coloring of $K_{16}$ with no monochromatic $K_{10}$, and for every natural number $m$, the graph $T_{2m,2}$ is triangle-free with exactly $m^2$ edges.

**Proof sketch.** Combine Corollary 4.3 with Theorem 6.1. $\square$

This conjunction places two complementary extremal statements side by side. Ramsey avoidance proves that a union of forbidden coloring cylinders fails to cover a Boolean cube. Turán sharpness constructs the largest edge support compatible with a triangle prohibition in the balanced case.

## 7. Algorithms and computational demonstrations

### 7.1. Exhaustive search for a Ramsey-avoiding coloring

Number the $M=\binom{n}{2}$ edges of $K_n$. Each integer from $0$ to $2^M-1$ encodes a coloring by its binary digits. For every coloring and every $k$-vertex subset, inspect the $\binom{k}{2}$ internal edges. Accept the first coloring for which those edges are never all red and never all blue.

**Correctness.** Acceptance is definitionally equivalent to having no monochromatic $K_k$. Under Theorem 4.1’s inequality, at least one accepted coloring exists, so exhaustive enumeration eventually finds one.

**Complexity.** In the worst case, the method examines $2^M$ colorings, $\binom{n}{k}$ vertex subsets per coloring, and $\binom{k}{2}$ edges per subset. Its time is

$$
O\left(2^{\binom{n}{2}}\binom{n}{k}\binom{k}{2}\right),
$$

with $O(M)$ space for a coloring. This is a finite extraction procedure, not an efficient algorithm at large $n$.

### 7.2. Conditional survivor filtering

Store the outcomes in an explicit set. For each constraint $i$, remove every current outcome in $B_i$. If the hypotheses of Theorem 5.3 hold, the set remains nonempty after every step.

**Correctness.** Lemma 5.1 identifies each updated set with the outcomes satisfying all constraints processed so far. Lemma 5.2 prevents emptiness.

**Complexity.** With constant-time bad-set membership tests, scanning every remaining outcome for each constraint costs at most $O(|\Omega||I|)$ time and $O(|\Omega|)$ space. Compactly represented outcome spaces may require more sophisticated methods.

### 7.3. Balanced Turán graph generation

Create vertices $0,\ldots,2m-1$. Put the first $m$ in one part and the rest in the other, then output every cross-pair.

**Correctness.** The output is exactly $T_{2m,2}$, so Theorem 6.1 applies.

**Complexity.** The algorithm outputs $m^2$ edges and therefore takes $\Theta(m^2)$ time and output space. This is optimal up to constants for an explicit edge list.

### 7.4. Numerical checks

The ratio

$$
\rho(n,k)=\frac{2\binom{n}{k}}{2^{\binom{k}{2}}}
$$

is the union-bound upper estimate for the fraction of bad colorings. Whenever $\rho(n,k)<1$, Theorem 4.1 applies. For $(n,k)=(16,10)$, the still cruder power ratio is

$$
\frac{2\cdot16^{10}}{2^{45}}=\frac1{16}.
$$

The exact binomial ratio is smaller still. Numerical code can tabulate these ratios, verify survivor filtering on finite examples, and generate balanced Turán graphs while checking edge counts and triangle absence.

## 8. Applications and interpretation

The Ramsey criterion applies whenever a forbidden pattern fixes a known number of independent binary coordinates. Similar counts arise in coding theory, property testing, constraint satisfaction, and randomized constructions. The essential pattern is a finite product space together with bad cylinders whose total cardinality can be bounded.

The conditional-avoidance theorem is more general because it does not require product structure. It can describe schedules avoiding conflicts, assignments avoiding forbidden local states, or configurations satisfying a finite collection of tests. Its burden is correspondingly strong: one must prove strict survival after every admissible partial constraint set.

Balanced Turán graphs model maximally dense interaction networks with no triangles. In applications, bipartition may represent two agent classes, two communication layers, or two incompatible types. Every possible cross-class interaction is retained while same-class interactions are prohibited; the absence of within-class edges automatically prevents three-way mutual adjacency.

One should distinguish three meanings of “constructive.” First, an exact finite count proves that a witness lies in an explicitly enumerable set. Second, exhaustive search then gives a terminating algorithm. Third, an efficient algorithm requires a favorable complexity bound. The results here establish the first two levels for Ramsey avoidance and direct efficient construction for balanced Turán graphs. They do not establish an efficient Ramsey search or a Moser–Tardos runtime theorem.

## 9. Discussion

The common mathematical object behind the Ramsey argument is the Boolean lattice of all edge subsets. A red clique event is an upper interval: the red set must contain a specified internal edge set. A blue clique event is a disjointness class, or equivalently the complement image of an upper interval. This symmetry makes the two colors contribute identical terms.

The survivor theorem replaces a single global estimate with a sequence of conditional estimates. Its hypothesis is stronger than merely saying that each $B_i$ is a proper subset of $\Omega$: an event that is small globally may contain every outcome left after other constraints. The theorem therefore captures the central difficulty of dependent events rather than hiding it.

Turán extremality belongs to a different optimization mode. There is no ambient coloring cube whose bad part is bounded by a union estimate. Instead, the forbidden triangle induces a structural organization, and a bipartition makes maximal density compatible with avoidance. The synthesis is methodological: both sides turn qualitative prohibition into exact cardinal arithmetic.

The current boundaries should be stated plainly. The full Lovász local lemma has not been derived from dependency degree. The classical asymptotic Ramsey scale has not been deduced uniformly for all sufficiently large $k$. Only balanced bipartite Turán sharpness, not the full general upper-bound theorem, is established here. These are not cosmetic omissions; each requires a new mathematical ingredient.

## 10. Future work

A first direction is to derive the symmetric local lemma from finite survivor ratios. Given bad events of probability at most $p$ and dependency degree at most $d$, one seeks a quantitative lower bound ensuring that each new constraint preserves a positive fraction whenever $e p(d+1)\le1$. The conditional-avoidance theorem would then supply the terminal induction.

A second direction is algorithmic. In a variable model, resampling logs can be encoded by rooted dependency trees. Bounding the expected number of resamplings by a convergent witness-tree series would convert existence into an efficient randomized construction.

A third direction is sharper Ramsey arithmetic. The exact event count is already available; obtaining the classical exponential scale requires estimates for $\binom{n}{k}$ when $n$ is near $2^{k/2}$. This is an asymptotic inequality problem rather than a graph-encoding problem.

A fourth direction is an entropy bridge. Ramsey avoidance controls the volume of forbidden cylinders in a coloring space, whereas Turán theory maximizes edge support under a clique prohibition. A common finite entropy functional might explain these as dual sublevel and constrained-maximization phenomena.

A fifth direction is stability. If a triangle-free graph has nearly $N^2/4$ edges, one expects it to be close to bipartite. Quantifying “nearly” and “close” would strengthen exact extremality into a robust structural theorem.

## 11. Conclusion

Finite counting gives a precise foundation for the probabilistic method. A fixed monochromatic $K_k$ occupies exactly $2^{\binom{n}{2}-\binom{k}{2}}$ colorings of $K_n$ in either color. Summing over vertex sets yields the criterion

$$
2\binom{n}{k}<2^{\binom{k}{2}},
$$

and therefore the concrete lower bound $R(10,10)>16$. In an arbitrary finite outcome space, strict conditional loss guarantees a common survivor by induction. At the deterministic extremal pole, balanced complete bipartite graphs avoid triangles while attaining exactly $m^2$ edges on $2m$ vertices.

The unifying lesson is not that randomness solves every construction problem. It is that existence can often be reduced to accounting: describe the candidate universe, calculate the reach of each prohibition, and prove that either room remains or an extremal structure meets the boundary exactly.