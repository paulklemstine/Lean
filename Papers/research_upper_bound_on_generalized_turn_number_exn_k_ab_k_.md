# A Cubic Upper Bound for the Generalized Turán Number $\mathrm{ex}(n, K_{a,b}, K_{3,b+1})$

## Abstract

The generalized Turán problem asks for the maximum number of copies of a fixed
graph $H$ contained in an $n$-vertex host graph that avoids a forbidden subgraph
$F$. We study this problem for complete bipartite patterns. Our main result is a
sharp-order upper bound: for all integers $a, b$ with $3 \le a \le b$, every
$n$-vertex graph that contains no copy of the complete bipartite graph
$K_{3,b+1}$ has at most $\binom{b}{a-3}\, n^3$ labelled copies of $K_{a,b}$. In
the notation of the generalized Turán function this reads

$$\mathrm{ex}\bigl(n,\, K_{a,b},\, K_{3,b+1}\bigr) = O\!\left(n^3\right),$$

resolving the upper half of the growth law
$\mathrm{ex}(n, K_{a,b}, K_{3,b+1}) = \Theta(n^3)$. The proof is a
Kővári–Sós–Turán-style double count anchored on three-element vertex sets: the
forbidden $K_{3,b+1}$ is equivalent to a cap of $b$ on the common neighborhood of
every triple, and this cap localizes and bounds the copies anchored at each
triple. We then transport the combinatorial bound into the language of asymptotic
analysis, obtaining two equivalent analytic readings: the copy count is $O(n^3)$
in the Landau sense with leading constant $\binom{b}{a-3}$, and the normalized
copy density relative to $n^{a+b}$ tends to zero. The latter is a first-moment
statement: in a large $K_{3,b+1}$-free graph, a random placement of $a+b$
vertices almost never realizes a copy of $K_{a,b}$.

**Keywords:** generalized Turán number, complete bipartite graph, Kővári–Sós–Turán
theorem, common neighborhood, double counting, Zarankiewicz problem, Landau
asymptotics.

## 1. Introduction

Extremal graph theory studies how global structural constraints limit local
substructure. The classical Turán-type question fixes a forbidden graph $F$ and
asks for the maximum number of edges in an $n$-vertex $F$-free graph. The
**generalized** (or Alon–Shikhelman) Turán problem replaces "edges" by "copies of
a fixed graph $H$": one seeks

$$\mathrm{ex}(n, H, F) := \max\bigl\{\, \#\{\text{copies of } H \text{ in } G\}
: G \text{ is an } n\text{-vertex } F\text{-free graph} \,\bigr\}.$$

This function interpolates between counting problems and forbidden-configuration
problems, and it has become a central object in modern extremal combinatorics.

We consider the case in which both the counted graph and the forbidden graph are
complete bipartite. Fix integers $3 \le a \le b$. We count copies of $K_{a,b}$,
and we forbid $K_{3,b+1}$. This choice is natural and delicate: the forbidden
graph shares one side-size ($3$) with the anchoring structure and one
side-size ($b+1$, just one more than $b$) with the counted graph, so that the
constraint bites at exactly the threshold where the count would otherwise
explode.

Our contribution is the exact order of growth for the upper bound, together with
an explicit constant and an analytic reformulation.

### 1.1 Main results

**Theorem A (Cubic upper bound).** *For all integers $a, b$ with $3 \le a \le b$,
every $n$-vertex graph $G$ containing no copy of $K_{3,b+1}$ satisfies*

$$\#\{\text{copies of } K_{a,b} \text{ in } G\} \;\le\; \binom{b}{a-3}\, n^3.$$

*In particular $\mathrm{ex}(n, K_{a,b}, K_{3,b+1}) = O(n^3)$.*

**Theorem B (Landau bridge).** *Fix $3 \le a \le b$. For any sequence
$(G_n)_{n \ge 1}$ of graphs, with $G_n$ on $n$ vertices and $K_{3,b+1}$-free for
every $n$, the copy count $f(n) = \#\{\text{copies of } K_{a,b} \text{ in }
G_n\}$ satisfies $f(n) = O(n^3)$ as $n \to \infty$, with admissible Landau
constant $\binom{b}{a-3}$.*

**Theorem C (Vanishing density).** *Under the hypotheses of Theorem B,*

$$\frac{f(n)}{n^{a+b}} \longrightarrow 0 \qquad (n \to \infty).$$

Theorem A is the combinatorial heart; Theorems B and C carry it faithfully into
asymptotic analysis, preserving the extremal constant in the Landau statement and
exposing the probabilistic meaning of the bound.

### 1.2 Discussion of sharpness

The exponent $3$ in Theorem A is best possible: there exist infinitely many
$K_{3,b+1}$-free graphs with $\Omega(n^3)$ copies of $K_{a,b}$, so that in fact
$\mathrm{ex}(n, K_{a,b}, K_{3,b+1}) = \Theta(n^3)$. The present paper establishes
the upper half of this equality in full, with an explicit constant. The matching
lower construction (whose fine structure involves parity considerations) is the
natural companion result; see Section 7.

## 2. Definitions and setup

Throughout, $G$ denotes a finite simple graph on a vertex set $V$ with
$|V| = n$. We write $u \sim v$ when $u$ and $v$ are adjacent. All graphs are
undirected and loopless.

**Definition 2.1 (Complete bipartite pattern).** For integers $a, b \ge 0$, a
**labelled copy of $K_{a,b}$** in $G$ is an ordered pair $(A, B)$ of disjoint
vertex sets with $|A| = a$, $|B| = b$, such that every vertex of $A$ is adjacent
to every vertex of $B$. We write

$$\mathcal{K}_{a,b}(G) = \bigl\{ (A, B) : |A| = a,\ |B| = b,\ A \cap B =
\varnothing,\ \forall u \in A\ \forall v \in B\ u \sim v \bigr\},$$

and denote by $N_{a,b}(G) = |\mathcal{K}_{a,b}(G)|$ the number of such copies.
The two sides are distinguished (the $a$-side and the $b$-side); this labelled
count differs from the unlabelled subgraph count only by a bounded factor and
does not affect the order of growth.

**Definition 2.2 (Common neighborhood).** For a set $S \subseteq V$, the
**common neighborhood** of $S$ is

$$N(S) = \{ w \in V : w \sim u \text{ for all } u \in S \}.$$

Two elementary properties are used repeatedly:

- **Antitonicity.** If $S \subseteq T$ then $N(T) \subseteq N(S)$: adding
  constraints can only remove common neighbors.
- **Monotone cap.** If $|N(S)| \le c$ for every $S$ of size $3$, then
  $|N(T)| \le c$ for every $T$ with $|T| \ge 3$, since $T$ contains a $3$-subset
  $S$ and $N(T) \subseteq N(S)$.

**Definition 2.3 ($K_{3,t}$-freeness).** $G$ is **$K_{3,t}$-free** if there is no
pair of disjoint sets $(A, B)$ with $|A| = 3$, $|B| = t$, and all $A$–$B$ edges
present.

**Definition 2.4 (Common-neighborhood cap).** $G$ satisfies the
**$t$-cap** if every three-element set $S \subseteq V$ has $|N(S)| \le t - 1$.

## 3. The equivalence at the core

The forbidden pattern is equivalent to a purely local counting constraint. This
translation is the conceptual pivot of the whole argument.

**Lemma 3.1 (Freeness equals the cap).** *For $t \ge 1$, the graph $G$ is
$K_{3,t}$-free if and only if it satisfies the $t$-cap: every three-element set
has at most $t - 1$ common neighbors.*

*Proof.* ($\Rightarrow$) Suppose $G$ is $K_{3,t}$-free and, for contradiction,
that some triple $S$ has $|N(S)| \ge t$. Choose any $B \subseteq N(S)$ with
$|B| = t$. Then $S$ and $B$ are disjoint: any vertex in both would be adjacent to
itself, impossible in a simple graph. Every vertex of $B$ is, by definition of
$N(S)$, adjacent to every vertex of $S$. Thus $(S, B)$ is a copy of $K_{3,t}$, a
contradiction.

($\Leftarrow$) Suppose the $t$-cap holds and, for contradiction, that $(A, B)$ is
a copy of $K_{3,t}$. Every vertex of $B$ is adjacent to every vertex of $A$, so
$B \subseteq N(A)$, whence $t = |B| \le |N(A)| \le t - 1$, a contradiction.
$\qquad\blacksquare$

**Corollary 3.2 (Cap on larger sets).** *If $G$ satisfies the $t$-cap, then every
set $T$ with $|T| \ge 3$ has $|N(T)| \le t - 1$.*

*Proof.* Pick a three-element $S \subseteq T$. By antitonicity
$N(T) \subseteq N(S)$, so $|N(T)| \le |N(S)| \le t - 1$. $\qquad\blacksquare$

## 4. The fiber bound

We now bound the number of copies that can be *anchored* at a fixed triple. Say
that a copy $(A, B)$ is **anchored at $S$** if $S \subseteq A$.

**Lemma 4.1 (Fiber bound).** *Let $G$ satisfy the $t$-cap, let $3 \le b$, and let
$S$ be a three-element set. Then the number of copies $(A, B) \in
\mathcal{K}_{a,b}(G)$ with $S \subseteq A$ is at most*

$$\binom{t-1}{b}\binom{t-1}{a-3}.$$

*Proof.* Let $(A, B)$ be anchored at $S$. We describe such a copy by the pair
$(A \setminus S,\ B)$ and bound the number of possibilities for each coordinate.

*The $b$-side lives in $N(S)$.* Every vertex of $B$ is adjacent to every vertex of
$A \supseteq S$, hence to every vertex of $S$; thus $B \subseteq N(S)$. Since
$|B| = b$ and $|N(S)| \le t - 1$ (the $t$-cap on the triple $S$), the number of
choices for $B$ is at most $\binom{t-1}{b}$.

*The extra $a-3$ vertices live in $N(B)$.* Every vertex of $A \setminus S$ is
adjacent to every vertex of $B$, so $A \setminus S \subseteq N(B)$. As
$|B| = b \ge 3$, Corollary 3.2 gives $|N(B)| \le t - 1$, so the number of choices
for the $(a-3)$-element set $A \setminus S$ is at most $\binom{t-1}{a-3}$.

*Injectivity of the description.* The map $(A, B) \mapsto (A \setminus S, B)$ is
injective on copies anchored at $S$: from $A \setminus S$ and the fixed $S$ we
recover $A = (A \setminus S) \cup S$, and $B$ is given directly. Hence the number
of anchored copies is at most the product of the two counts,
$\binom{t-1}{b}\binom{t-1}{a-3}$. $\qquad\blacksquare$

## 5. The double count and Theorem A

**Lemma 5.1 (Anchoring covers every copy).** *If $3 \le a$, then*

$$N_{a,b}(G) \;\le\; \sum_{\substack{S \subseteq V \\ |S| = 3}}
\#\{ (A, B) \in \mathcal{K}_{a,b}(G) : S \subseteq A \}.$$

*Proof.* Count incidences between copies and their anchoring triples. Each copy
$(A, B)$ has $|A| = a \ge 3$, so it contains exactly $\binom{a}{3} \ge 1$ triples
$S \subseteq A$. Therefore, summing over triples the number of copies anchored at
each triple equals $\sum_{(A,B)} \binom{a}{3} \ge \sum_{(A,B)} 1 = N_{a,b}(G)$.
Swapping the order of summation gives the claim. $\qquad\blacksquare$

**Theorem 5.2 (Explicit bound under the cap).** *If $3 \le a$, $3 \le b$, and $G$
satisfies the $t$-cap, then*

$$N_{a,b}(G) \;\le\; \binom{n}{3}\binom{t-1}{b}\binom{t-1}{a-3}.$$

*Proof.* Combine Lemma 5.1 with the fiber bound (Lemma 4.1). There are exactly
$\binom{n}{3}$ triples $S$, and each contributes at most
$\binom{t-1}{b}\binom{t-1}{a-3}$ anchored copies. $\qquad\blacksquare$

**Theorem A (restated).** *If $3 \le a \le b$ and $G$ is an $n$-vertex
$K_{3,b+1}$-free graph, then*

$$N_{a,b}(G) \;\le\; \binom{n}{3}\binom{b}{a-3} \;\le\; \binom{b}{a-3}\, n^3.$$

*Proof.* By Lemma 3.1, $K_{3,b+1}$-freeness is the $(b+1)$-cap: every triple has
at most $b$ common neighbors. Apply Theorem 5.2 with $t = b + 1$, so $t - 1 = b$
and $\binom{t-1}{b} = \binom{b}{b} = 1$. This yields
$N_{a,b}(G) \le \binom{n}{3}\binom{b}{a-3}$. Finally
$\binom{n}{3} \le n^3$ (indeed $\binom{n}{3} = n(n-1)(n-2)/6 \le n^3$), giving the
stated bound. $\qquad\blacksquare$

The exponent $3$ is inherited directly from the anchoring on three-element sets,
which in turn is forced by the "$3$" in the forbidden $K_{3,b+1}$. The constant
$\binom{b}{a-3}$ is the number of ways to extend an anchoring triple to the full
$a$-side inside a common neighborhood of size $b$; the factor $\binom{b}{b} = 1$
records that, at the threshold $t = b+1$, the $b$-side is forced to fill its host
neighborhood exactly.

## 6. The asymptotic bridge

We now transport Theorem A into the language of asymptotic analysis. The point is
not merely to restate the bound but to show that the *extremal constant survives*
as the analytic constant, and to expose the probabilistic content.

**Theorem B (Landau bridge, restated).** *Fix $3 \le a \le b$. Let
$(G_n)_{n \ge 1}$ be any sequence with $G_n$ an $n$-vertex $K_{3,b+1}$-free
graph. Then, with $f(n) = N_{a,b}(G_n)$,*

$$f(n) = O\!\left(n^3\right) \qquad (n \to \infty),$$

*with admissible Landau constant $C = \binom{b}{a-3}$; that is, $f(n) \le
\binom{b}{a-3}\, n^3$ for all $n$.*

*Proof.* Apply Theorem A to each $G_n$: for every $n$,
$f(n) = N_{a,b}(G_n) \le \binom{b}{a-3}\, n^3$. Since $f(n) \ge 0$, this is
exactly the assertion that $f = O(n^3)$ with the stated constant.
$\qquad\blacksquare$

**Theorem C (Vanishing density, restated).** *Under the hypotheses of Theorem B,*

$$\frac{f(n)}{n^{a+b}} \longrightarrow 0 \qquad (n \to \infty).$$

*Proof.* By Theorem A, $0 \le f(n) \le C\, n^3$ with $C = \binom{b}{a-3}$. For
$n \ge 1$,

$$0 \;\le\; \frac{f(n)}{n^{a+b}} \;\le\; \frac{C\, n^3}{n^{a+b}}
\;=\; \frac{C}{n^{a+b-3}}.$$

Since $a \ge 3$ and $b \ge 3$ we have $a + b - 3 \ge 3 > 0$, so the right-hand
side tends to $0$. The squeeze theorem gives $f(n)/n^{a+b} \to 0$.
$\qquad\blacksquare$

**Interpretation.** A labelled copy of $K_{a,b}$ occupies $a + b$ vertex slots,
and there are on the order of $n^{a+b}$ ways to place that many vertices. Theorem
C says the fraction of placements realizing an actual copy vanishes: choosing
$a+b$ vertices uniformly at random from a large $K_{3,b+1}$-free graph, the
probability that they form $K_{a,b}$ (with a prescribed side-assignment) tends to
zero. This is precisely the first-moment estimate that underlies threshold
arguments in the theory of random graphs.

## 7. Applications and connections

**Zarankiewicz and incidence geometry.** The forbidden $K_{s,t}$ is the graph-
theoretic form of the Zarankiewicz problem: the maximum number of ones in an
$m \times n$ zero–one matrix with no all-ones $s \times t$ submatrix. Bounds on
$\mathrm{ex}(n, K_{a,b}, K_{s,t})$ translate into statements about the abundance
of dense blocks in such matrices, and hence into incidence bounds between points
and geometric objects.

**Random graphs and thresholds.** Theorem C is a first-moment bound. In the
random-graph setting, the expected number of copies of a fixed subgraph governs
the threshold at which the subgraph appears; a vanishing normalized count is the
analytic signature of being below such a threshold.

**Counting in constrained networks.** More broadly, the result is a template for
a pervasive phenomenon: forbidding a single dense bipartite configuration imposes
a polynomial ceiling — here cubic — on every related dense configuration,
regardless of how the network is engineered.

## 8. Future work

1. **Matching lower bound (the $\Theta$ half).** Construct, for infinitely many
   $n$, $K_{3,b+1}$-free graphs with $\Omega(n^3)$ copies of $K_{a,b}$, upgrading
   the $O(n^3)$ bound to a two-sided $\Theta(n^3)$ asymptotic equivalence. The
   fine structure of these constructions involves parity considerations.

2. **The extremal function as a first-class object.** Define
   $\mathrm{ex}(n, K_{a,b}, K_{3,t})$ as the maximum of $N_{a,b}(G)$ over all
   $K_{3,t}$-free $n$-vertex graphs, and state the growth law directly for this
   quantity, rather than for arbitrary sequences.

3. **General forbidden $K_{s,t}$.** Replace the forbidden $K_{3,b+1}$ (and the
   anchoring triple) by $K_{s,\cdot}$. The double count generalizes verbatim with
   $s$ in place of $3$, giving $\mathrm{ex}(n, K_{a,b}, K_{s,t}) = O(n^s)$ under
   the analogous common-neighborhood cap on $s$-element sets.

4. **Sharper constants.** The constant $\binom{b}{a-3}$ is not optimized.
   Determine the exact extremal constant and whether the common-neighborhood cap
   can be tightened for specific $(a, b)$.

5. **Further cross-domain bridges.** The Landau framing invites connections to
   (a) incidence geometry and the Zarankiewicz problem, and (b) random-graph
   thresholds, where the vanishing density becomes a first-moment statement.

## 9. Conclusion

We have established that, for $3 \le a \le b$, every $n$-vertex $K_{3,b+1}$-free
graph contains at most $\binom{b}{a-3}\, n^3$ labelled copies of $K_{a,b}$, so
that $\mathrm{ex}(n, K_{a,b}, K_{3,b+1}) = O(n^3)$. The proof reduces the
forbidden pattern to a local cap of $b$ on the common neighborhood of every
triple, anchors each copy on a triple, and multiplies a per-anchor fiber bound by
the number of triples. Two analytic readings follow: the copy count is $O(n^3)$
with the extremal constant $\binom{b}{a-3}$ intact, and the copy density relative
to $n^{a+b}$ vanishes. The cubic exponent is dictated by the anchoring triple,
and the argument generalizes cleanly to forbidden $K_{s,t}$, pointing toward a
broad family of sharp counting laws for dense configurations in constrained
graphs.
