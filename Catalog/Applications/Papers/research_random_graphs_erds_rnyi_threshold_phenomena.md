# Exact First-Moment Identities for the Erdős–Rényi Random Graph $G(n,p)$ and the Combinatorial Origin of Threshold Phenomena

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Algebra / Combinatorial Probability

## Abstract

We develop, from first principles, the exact first-moment theory of the
Erdős–Rényi random graph $G(n,p)$ on a fixed labelled vertex set, and we exhibit
how the three classical thresholds of the model — the connectivity threshold at
$p = \ln n / n$, the giant-component / triangle-appearance transition at
$p = 1/n$, and the appearance thresholds of fixed subgraphs — all descend from a
single linearity-of-expectation identity evaluated on three different families of
events. Concretely, we prove (i) a general counting identity
$\mathbb{E}\big[\#\{i\in I : g \in A_i\}\big] = \sum_{i\in I}\mathbb{P}(A_i)$
with no independence hypothesis; (ii) the combinatorial cardinalities
$|\mathrm{Edge}(n)| = \binom{n}{2}$, $|\mathrm{incident}(v)| = n-1$, and
$|\mathrm{triEdges}(T)| = 3$ for $|T|=3$; and (iii) the three exact expectations
$\mathbb{E}[\#\text{edges}] = \binom{n}{2}p$,
$\mathbb{E}[\#\text{isolated vertices}] = n(1-p)^{n-1}$, and
$\mathbb{E}[\#\text{triangles}] = \binom{n}{3}p^3$. We explain how these exact
identities feed the first- and second-moment methods to localize each threshold,
state the asymptotic threshold theorems as corollaries-in-waiting, and record the
open conjectures (sharp connectivity via the second moment of isolated vertices,
variance factorization for subgraph counts, the general $n^{-1/m(H)}$ appearance
threshold, and the Poisson limit for triangles at criticality) that the present
exact machinery makes tractable.

## 1. Introduction

The random graph model $G(n,p)$ of Erdős and Rényi (1959) assigns, independently
and with probability $p$, an edge to each of the $\binom{n}{2}$ pairs of a fixed
set of $n$ labelled vertices. Despite its disarming simplicity, $G(n,p)$ is the
canonical setting in which to study **threshold phenomena**: monotone graph
properties that, as $p$ increases through a critical scale, switch from "almost
surely false" to "almost surely true" within a vanishingly narrow window. The
three landmark examples are:

1. **Connectivity**, with sharp threshold $p = \ln n / n$;
2. **The giant component**, a phase transition at $p = 1/n$;
3. **Appearance of a fixed subgraph $H$**, with threshold $p = n^{-1/m(H)}$,
   where $m(H)$ is the maximum edge-to-vertex density of a subgraph of $H$
   (for a triangle, $m(K_3)=1$, giving threshold $1/n$).

The unifying methodological insight — the *moment method* — is that these
qualitative transitions are governed quantitatively by the first two moments of
natural counting statistics. The purpose of this paper is to isolate and prove
the **exact, finite-$n$ first-moment identities** at the foundation of the theory,
to make explicit the single linear-algebraic identity from which they all flow,
and to delineate precisely how far the first moment alone determines each
threshold and where the second moment must take over.

Our contribution is twofold. Mathematically, we package the first-moment layer of
Erdős–Rényi theory as one master identity plus three combinatorial cardinality
computations, emphasizing the symmetry between "present" events (subgraph copies)
and "absent" events (isolated vertices). Structurally, we organize the
development so that the asymptotic threshold theorems become clean corollaries of
the exact identities once paired with standard concentration tools, and we record
the precise covariance estimates that remain.

## 2. The model

Throughout, $n \in \mathbb{N}$ and $p \in [0,1]$ (formally $p \in \mathbb{R}$;
the identities below are polynomial in $p$ and hold over $\mathbb{R}$).

**Definition 1 (Configuration space and edges).**
Fix the vertex set $V = \{0,1,\dots,n-1\}$. The set of *potential edges* is
$$\mathrm{Edge}(n) \;=\; \{\, (i,j) \in V \times V : i < j \,\}.$$
A *configuration* (a sample graph) is a Boolean assignment
$g : \mathrm{Edge}(n) \to \{\texttt{true},\texttt{false}\}$, where $g(e)=\texttt{true}$
means edge $e$ is present. The Erdős–Rényi law is the product Bernoulli$(p)$
measure on configurations: edges are present independently, each with probability
$p$.

**Definition 2 (Expectation and probability).**
For a real functional $f$ of the configuration, $\mathbb{E}_p[f]$ denotes its
expectation under the product Bernoulli$(p)$ law (`expectation p f`). For an event
$A$ (a set of configurations), $\mathbb{P}_p(A)$ is its probability (`prob p A`).

**Definition 3 (Present / absent events).**
For a set of edges $S \subseteq \mathrm{Edge}(n)$:
- $\mathrm{allPresent}(S)$ is the event "every edge of $S$ is present";
- $\mathrm{allAbsent}(S)$ is the event "every edge of $S$ is absent".

By edge independence (lemmas `prob_allPresent`, `prob_allAbsent` of the imported
model), these have the dual product probabilities
$$\mathbb{P}_p(\mathrm{allPresent}(S)) = p^{|S|}, \qquad
  \mathbb{P}_p(\mathrm{allAbsent}(S)) = (1-p)^{|S|}. \tag{2.1}$$

**Definition 4 (Subgraph count).**
Given a family of edge-sets $(S_i)$, $\mathrm{subgraphCount}$ counts how many of
the corresponding copies are fully present in a configuration. Its first moment
is $\mathbb{E}_p[\mathrm{subgraphCount}] = \sum_i p^{|S_i|}$ (lemma
`expectation_subgraphCount`), an immediate consequence of (2.1) and linearity.

## 3. The master identity

The entire first-moment layer rests on one statement, free of any independence
hypothesis.

**Theorem 1 (Linearity of expectation for counts; `expectation_count`).**
Let $I$ be a finite index set and $(A_i)_{i \in I}$ a family of events. Define the
count $X(g) = \#\{\, i \in I : g \in A_i \,\}$. Then
$$\mathbb{E}_p[X] \;=\; \sum_{i \in I} \mathbb{P}_p(A_i).$$

*Proof sketch.* Write $X(g) = \sum_{i\in I} \mathbf{1}[g \in A_i]$ as a sum of
indicator functions. Expectation is a finite linear functional over the
configuration space (it is a weighted finite sum over configurations), so it
commutes with the finite sum over $i$: $\mathbb{E}_p[X] = \sum_{i\in I}
\mathbb{E}_p[\mathbf{1}[\cdot \in A_i]] = \sum_{i \in I}\mathbb{P}_p(A_i)$.
Formally this is the exchange of two finite sums (Fubini for finite sums,
`Finset.sum_comm`) after expanding `card_filter` as a sum of indicators. No
property of the measure beyond linearity is used; in particular the events $A_i$
need not be independent. $\qquad\blacksquare$

Theorem 1 is the only probabilistic input we need. Every expectation below is
Theorem 1 specialized to a particular event family, and the *only* additional work
is to compute one probability via (2.1) and one cardinality. We now carry this out
for edges, isolated vertices, and triangles.

## 4. Edges

**Lemma 2 (Number of potential edges; `card_edge`).**
$$\bigl|\mathrm{Edge}(n)\bigr| \;=\; \binom{n}{2}.$$

*Proof sketch.* $\mathrm{Edge}(n)$ is the subtype of pairs $(i,j)$ with $i<j$.
Counting by the larger coordinate, the number of pairs with second coordinate
$j$ is $j$, so the total is $\sum_{j=0}^{n-1} j = \binom{n}{2}$ (Gauss's sum,
`Finset.sum_range_id` together with `Nat.choose_two_right`). $\qquad\blacksquare$

**Theorem 3 (Expected number of edges; `expected_edges`).**
$$\mathbb{E}_p[\#\text{edges}] \;=\; \binom{n}{2}\, p.$$

*Proof sketch.* The edge count is the subgraph count for the singleton family
$e \mapsto \{e\}$, each copy having $|S|=1$. By `expectation_subgraphCount`
(equivalently Theorem 1 with $A_e = \mathrm{allPresent}(\{e\})$ and (2.1)), the
expectation is $\sum_{e}p^{1} = |\mathrm{Edge}(n)|\cdot p = \binom{n}{2}p$ by
Lemma 2. $\qquad\blacksquare$

## 5. Isolated vertices and the connectivity threshold

**Definition 5 (Incident edges).** For a vertex $v$,
$$\mathrm{incident}(v) \;=\; \{\, e \in \mathrm{Edge}(n) : v \text{ is an
endpoint of } e \,\}.$$

**Lemma 4 (Degree of the complete graph; `card_incident`).**
For every vertex $v$,
$$\bigl|\mathrm{incident}(v)\bigr| \;=\; n-1.$$

*Proof sketch.* The map sending an incident edge to its *other* endpoint is a
bijection between $\mathrm{incident}(v)$ and $V \setminus \{v\}$; explicitly,
$u \mapsto (u,v)$ if $u<v$ and $u\mapsto (v,u)$ otherwise is an injection from the
$n-1$ vertices $u \neq v$ onto $\mathrm{incident}(v)$ (formally, an
`image_of_injOn` argument over $\mathrm{univ}.\mathrm{erase}\,v$).
$\qquad\blacksquare$

**Theorem 5 (Expected number of isolated vertices; `expected_isolated`).**
A vertex is *isolated* when all of its incident edges are absent. Then
$$\mathbb{E}_p[\#\text{isolated vertices}] \;=\; n\,(1-p)^{\,n-1}.$$

*Proof sketch.* Apply Theorem 1 with index set $I = V$ and events
$A_v = \mathrm{allAbsent}(\mathrm{incident}(v))$. By (2.1),
$\mathbb{P}_p(A_v) = (1-p)^{|\mathrm{incident}(v)|} = (1-p)^{n-1}$ using Lemma 4.
Summing over the $n$ vertices gives $n(1-p)^{n-1}$. $\qquad\blacksquare$

**Corollary 5.1 (Sharp connectivity threshold — asymptotic; *not formalized,
stated for context*).** Let $X_n$ be the number of isolated vertices in
$G(n,p_n)$ with $p_n = (\ln n + c)/n$. Then from Theorem 5,
$$\mathbb{E}[X_n] = n(1-p_n)^{n-1} \longrightarrow e^{-c} > 0.$$
Combined with a second-moment (covariance) estimate showing
$\mathrm{Var}(X_n)/\mathbb{E}[X_n]^2 \to 0$, the second-moment method yields
$X_n \ge 1$ — hence disconnection — with probability $\to 1 - e^{-e^{-c}}$ as
$c \to -\infty$ and connection with probability $\to 1$ as $c \to +\infty$. The
sharp threshold therefore sits at $p = \ln n / n$. The factor $\ln n$ is exactly
the value making $n(1-p)^{n-1}$ tend to a positive constant. *(This corollary is a
classical theorem of Erdős–Rényi; in the present development the exact mean
$n(1-p)^{n-1}$ is proved and the covariance estimate is recorded as Conjecture C1
of §8.)*

## 6. Triangles and the appearance threshold

**Definition 6 (Edges spanned by a vertex set).** For $T \subseteq V$,
$$\mathrm{triEdges}(T) \;=\; \{\, e \in \mathrm{Edge}(n) : \text{both endpoints
of } e \text{ lie in } T \,\}.$$

**Lemma 6 (A triple spans three edges; `card_triEdges`).**
If $|T| = 3$ then
$$\bigl|\mathrm{triEdges}(T)\bigr| \;=\; 3.$$

*Proof sketch.* The map $e \mapsto \{e_1, e_2\}$ (the unordered endpoint pair)
is a bijection from $\mathrm{triEdges}(T)$ onto the $2$-element subsets of $T$,
of which there are $\binom{3}{2} = 3$ (formally a bijection onto
$\mathrm{powersetCard}\,2\,T$, injective on $\mathrm{triEdges}(T)$).
$\qquad\blacksquare$

**Theorem 7 (Expected number of triangles; `expected_triangles`).**
Triangles are indexed by $3$-element vertex subsets; a triple $T$ forms a triangle
when all of $\mathrm{triEdges}(T)$ are present. Then
$$\mathbb{E}_p[\#\text{triangles}] \;=\; \binom{n}{3}\, p^{3}.$$

*Proof sketch.* Apply Theorem 1 with index set the $3$-subsets
$\mathrm{powersetCard}\,3\,V$ (of which there are $\binom{n}{3}$) and events
$A_T = \mathrm{allPresent}(\mathrm{triEdges}(T))$. By (2.1) and Lemma 6,
$\mathbb{P}_p(A_T) = p^{|\mathrm{triEdges}(T)|} = p^{3}$ for every such $T$.
Summing the constant $p^3$ over the $\binom{n}{3}$ triples gives $\binom{n}{3}p^3$.
$\qquad\blacksquare$

**Corollary 7.1 (Triangle / giant-component scale — asymptotic; *not formalized,
stated for context*).** Since $\binom{n}{3} \sim n^3/6$, Theorem 7 gives
$\mathbb{E}[\#\text{triangles}] \sim \tfrac{1}{6}(np)^3$. If $np \to 0$ the first
moment $\to 0$ and Markov's inequality (the first-moment method) forces
$\#\text{triangles} = 0$ whp; if $np \to \infty$ the second-moment method forces
$\#\text{triangles} \ge 1$ whp. Hence triangles appear at threshold $p = 1/n$,
the same scale at which the giant component emerges. $\qquad\blacksquare$

## 7. The two-sided moment method

We make explicit the logical skeleton that turns the exact means of §§4–6 into
threshold statements. Let $X \ge 0$ be an integer-valued count.

- **First-moment (Markov) bound `firstMoment`.** $\mathbb{P}(X \ge 1) \le
  \mathbb{E}[X]$. Thus $\mathbb{E}[X] \to 0$ implies $X = 0$ whp. This handles the
  *disappearance* side of every threshold: below the critical $p$, the relevant
  count has vanishing mean.
- **Second-moment bound `second_moment_zero`.** If
  $\mathrm{Var}(X)/\mathbb{E}[X]^2 \to 0$ then $X > 0$ whp (indeed
  $X/\mathbb{E}[X] \to 1$ in probability). This handles the *appearance* side:
  above the critical $p$, provided the variance is controlled, the count is
  positive.

The exact identities of §§4–6 supply the numerators ($\mathbb{E}[X]$) that decide
the first-moment side outright. The second-moment side additionally requires a
variance estimate; for triangles and for isolated vertices these reduce to finite
sums over pairs of copies graded by their *edge overlap*, where (2.1) again gives
each joint probability exactly as $p^{|S'\cup S''|}$. This is the content of the
conjectures in §8.

## 8. Open problems and future directions

The exact first-moment layer being in place, each classical threshold reduces to
one self-contained covariance estimate. We record the program.

**C1. Sharp connectivity via the second moment of isolated vertices.** With
$p_n = (\ln n + c)/n$, show $\mathrm{Var}(X_n)/\mathbb{E}[X_n]^2 \to 0$ for the
isolated-vertex count $X_n$. Combined with $\mathbb{E}[X_n] \to e^{-c}$
(Theorem 5) and `second_moment_zero`, this yields disconnection probability
$\to 1 - e^{-e^{-c}}$ and the sharp threshold $p = \ln n / n$. The only missing
input is the two-vertex covariance.

**C2. Variance of subgraph counts factors over edge overlaps.** For a fixed graph
$H$ with $e_H$ edges, the count $X_H$ of copies of $H$ satisfies
$$\mathrm{Var}(X_H) = \sum_{H',H''} \bigl(p^{|E(H')\cup E(H'')|} - p^{2e_H}\bigr),$$
summed over ordered pairs of copies, the dominant contribution coming from pairs
sharing at least one edge. The key input, $\mathbb{P}(\text{both present}) =
p^{|E(H')\cup E(H'')|}$, is exactly `prob_allPresent`, so the variance is a pure
finite sum — no measure theory beyond (2.1).

**C3. Appearance threshold $p = n^{-1/m(H)}$.** For a fixed connected $H$ with
$m(H) = \max_{H'\subseteq H} |E(H')|/|V(H')|$, copies of $H$ vanish below
$n^{-1/m(H)}$ and appear above it. The "below" direction is already a corollary of
`firstMoment` (mean $\Theta(n^{|V(H)|}p^{|E(H)|}) \to 0$); the "above" direction is
exactly the regime in which C2 gives $\mathrm{Var}/\mathbb{E}^2 \to 0$. The
remaining content is the densest-subgraph optimization defining $m(H)$.

**C4. Poisson limit for triangles at criticality.** At $p_n = c/n$, the triangle
count $T_n$ converges in distribution to $\mathrm{Poisson}(c^3/6)$; the mean
$\binom{n}{3}p_n^3 \to c^3/6$ is precisely Theorem 7 evaluated at $p_n = c/n$, and
the method of moments reduces the limit to controlling the factorial moments via
the same overlap-graded sums as C2.

## 9. Conclusion

We have shown that the first-moment foundations of Erdős–Rényi threshold theory
collapse to a single identity — linearity of expectation for counts (Theorem 1) —
applied to three event families, with the only combinatorial inputs being three
cardinalities ($\binom{n}{2}$, $n-1$, $3$). The resulting exact means
$\binom{n}{2}p$, $n(1-p)^{n-1}$, and $\binom{n}{3}p^3$ localize, respectively, the
density of the graph, the connectivity threshold $\ln n / n$, and the
triangle / giant-component scale $1/n$. The symmetry between present-events
(triangles) and absent-events (isolated vertices) is exactly the duality
$p^{|S|} \leftrightarrow (1-p)^{|S|}$ of (2.1). What remains for the full
asymptotic theorems are the matching second-moment estimates, which the present
exact framework reduces to finite, overlap-graded sums.

## Appendix A. Symbol glossary

| Symbol | Meaning |
|---|---|
| $G(n,p)$ | Erdős–Rényi random graph: $n$ vertices, each edge present independently with probability $p$ |
| $\mathrm{Edge}(n)$ | Potential edges $\{(i,j): i<j\}$; $|\mathrm{Edge}(n)| = \binom{n}{2}$ |
| $\mathbb{E}_p, \mathbb{P}_p$ | Expectation / probability under the product Bernoulli$(p)$ law |
| $\mathrm{allPresent}(S), \mathrm{allAbsent}(S)$ | Events "all of $S$ present / absent"; probabilities $p^{|S|}, (1-p)^{|S|}$ |
| $\mathrm{incident}(v)$ | Edges with endpoint $v$; size $n-1$ |
| $\mathrm{triEdges}(T)$ | Edges with both endpoints in $T$; size $3$ when $|T|=3$ |
| $m(H)$ | Maximum subgraph density $\max_{H'\subseteq H}|E(H')|/|V(H')|$ |
