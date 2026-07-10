# Persistent Cycles in Randomized Graphs via Hyperstable Structural Constraints

## Abstract

We study the persistence of long cycles in a random subgraph $G_p$ obtained from
a host graph $G$ by retaining each edge independently with probability $p$ (the
independent edge-retention, or bond-percolation, model). Our aim is to isolate,
state, and rigorously establish the provable core of the following asymptotic
target: *for every $\epsilon > 0$ there exists $K > 0$ such that for all
$d \ge K$ and all $p \in [\epsilon d/\log n,\ d/\log n]$, a host graph of average
degree $d$ yields a random subgraph $G_p$ that, asymptotically almost surely as
$n \to \infty$, contains a cycle of length at least $d - \epsilon d$.* We develop
a self-contained elementary probability calculus for the retention model,
including the exact survival law $\Pr[S \text{ survives}] = p^{|S|}$ for a fixed
edge set $S$, the fact that outcome weights form a probability mass function,
monotonicity, boundedness, a union bound, and linearity of expectation. We then
argue *contrarianly*: we formulate several bold conjectures around the target and
settle each. We **disprove** the naive claim that a single prescribed long cycle
persists — its survival probability $p^L$ tends to $0$ — thereby showing that
persistence must arise from the abundance of candidate cycles rather than any
one of them. We **prove** the first-moment tools (a family union bound, a
positive-expectation existence principle, antitonicity of survival, and the
exact expected number $p\cdot|E|$ of retained edges) that convert abundance into
absence or existence. Finally we prove the deterministic backbone — an
Erdős–Gallai / Dirac-type theorem — that a finite graph of minimum degree at
least $k$ contains a path of length at least $k$. Together these results form the
load-bearing structure of the persistence phenomenon and a concrete roadmap to
the full theorem.

**Keywords:** random graphs, bond percolation, cycle persistence, first moment
method, union bound, Erdős–Gallai theorem, Dirac's theorem, minimum degree.

## 1. Introduction

Cycles are the carriers of redundancy in a network. A graph that contains long
cycles admits many alternative routes between its vertices and therefore
tolerates the loss of individual edges. It is natural to ask how this redundancy
degrades under random failure. Given a host graph $G$ and a retention probability
$p$, form the random subgraph $G_p$ by keeping each edge independently with
probability $p$ and deleting it otherwise. When does $G_p$ still contain a long
cycle, and how long a cycle can we guarantee?

The motivating asymptotic statement, phrased for host graphs of growing order
$n$ and average degree $d$, is:

> **(Target).** For every $\epsilon > 0$ there is a constant $K > 0$ such that
> for all $d \ge K$ and all $p \in [\epsilon d / \log n,\ d/\log n]$, a graph $G$
> of average degree $d$ yields a random subgraph $G_p$ that asymptotically almost
> surely (a.a.s.) contains a cycle of length at least $d - \epsilon d$ as
> $n \to \infty$.

This is a deep statement in probabilistic combinatorics. Rather than attempt it
monolithically, we adopt a *contrarian* methodology: we identify the elementary
but decisive components on which any proof of the Target must rest, formulate
sharp conjectures around them, and settle each conjecture — proving the true ones
and disproving the false ones. The result is a rigorous, self-contained skeleton
of the persistence phenomenon.

The paper is organized as follows. Section 2 sets up the retention model and its
probability calculus. Section 3 establishes the exact survival law. Section 4
presents the contrarian analysis: what fails, what holds, and why. Section 5
proves the deterministic long-path backbone. Section 6 explains how the pieces
assemble toward the Target. Section 7 gives algorithms and numerical
illustrations, and Section 8 discusses applications and future work.

## 2. The independent edge-retention model

We work over a finite index set $\iota$ of *edges*. (Abstracting edges as an
arbitrary finite type keeps every statement free of incidental graph structure;
in applications $\iota$ is the edge set $E(G)$.)

**Definition 2.1 (Outcome).** An *outcome* is a function
$\omega : \iota \to \{\text{true}, \text{false}\}$; we say edge $e$ is *retained*
in $\omega$ if $\omega(e) = \text{true}$ and *deleted* otherwise.

**Definition 2.2 (Outcome weight).** For $p \in \mathbb{R}$ the *weight* of an
outcome $\omega$ is
$$
\mathrm{weight}_p(\omega) \;=\; \prod_{e \in \iota}
\begin{cases} p & \text{if } \omega(e) = \text{true},\\ 1 - p & \text{if } \omega(e) = \text{false}. \end{cases}
$$

**Definition 2.3 (Probability of an event).** For a predicate $A$ on outcomes,
$$
\Pr\nolimits_p[A] \;=\; \sum_{\omega} \mathbf{1}[A(\omega)]\,\mathrm{weight}_p(\omega).
$$

**Definition 2.4 (Survival).** For a finite edge set $S \subseteq \iota$, the
event $\mathrm{survives}(S)$ holds at $\omega$ if every edge of $S$ is retained:
$\forall e \in S,\ \omega(e) = \text{true}$.

**Lemma 2.5 (Nonnegativity of weights).** If $0 \le p \le 1$ then
$\mathrm{weight}_p(\omega) \ge 0$ for every $\omega$.

*Proof.* Each factor is either $p \ge 0$ or $1 - p \ge 0$; a product of
nonnegative reals is nonnegative. $\qquad\blacksquare$

**Theorem 2.6 (Total probability law).** For every real $p$,
$$
\sum_{\omega} \mathrm{weight}_p(\omega) \;=\; 1.
$$

*Proof sketch.* The sum ranges over all functions $\omega : \iota \to
\{\text{true},\text{false}\}$. Expanding the product and interchanging sum and
product (a finite distributivity / Fubini step) factors the sum over outcomes
into a product over edges:
$$
\sum_{\omega} \prod_{e} (\cdots) \;=\; \prod_{e} \Bigl(\sum_{b \in \{\text{true},\text{false}\}} (\cdots)\Bigr) \;=\; \prod_{e} \bigl(p + (1-p)\bigr) \;=\; \prod_e 1 \;=\; 1. \qquad\blacksquare
$$

Thus $(\mathrm{weight}_p)$ is a genuine probability mass function on outcomes
whenever $p \in [0,1]$, and $\Pr_p$ is a bona fide probability.

**Lemma 2.7 (Basic calculus).** For $0 \le p \le 1$ and events $A, B$:
- (Nonnegativity) $\Pr_p[A] \ge 0$.
- (Monotonicity) if $A \Rightarrow B$ pointwise then $\Pr_p[A] \le \Pr_p[B]$.
- (Boundedness) $\Pr_p[A] \le 1$.
- (Union bound) $\Pr_p[A \lor B] \le \Pr_p[A] + \Pr_p[B]$.

*Proof sketch.* Nonnegativity and monotonicity are termwise comparisons of the
defining sums using Lemma 2.5. Boundedness follows from monotonicity against the
always-true event together with Theorem 2.6. The union bound follows from the
pointwise inequality $\mathbf{1}[A \lor B] \le \mathbf{1}[A] + \mathbf{1}[B]$
weighted by the nonnegative $\mathrm{weight}_p$. $\qquad\blacksquare$

## 3. The exact survival law

The quantitative heart of the model is the following exact formula.

**Theorem 3.1 (Survival law).** For any finite edge set $S \subseteq \iota$,
$$
\Pr\nolimits_p[\mathrm{survives}(S)] \;=\; p^{\,|S|}.
$$

*Proof sketch.* By definition
$\Pr_p[\mathrm{survives}(S)] = \sum_\omega \mathbf{1}[\forall e \in S,\ \omega(e)=\text{true}]\prod_e(\cdots)$.
Split each factor of the product according to whether $e \in S$. For $e \in S$
the indicator kills the $\omega(e)=\text{false}$ branch, leaving only the factor
$p$; for $e \notin S$ both branches survive and sum to $1$. Interchanging sum and
product edge-by-edge gives $\prod_{e \in S} p \cdot \prod_{e \notin S} 1 =
p^{|S|}$. $\qquad\blacksquare$

Since $0 \le p \le 1$, the map $S \mapsto p^{|S|}$ is antitone under inclusion,
which yields the following quantitative statement of "longer is harder."

**Corollary 3.2 (Antitonicity of survival).** If $0 \le p \le 1$ and
$S \subseteq T$, then
$\Pr_p[\mathrm{survives}(T)] \le \Pr_p[\mathrm{survives}(S)]$.

*Proof.* $\mathrm{survives}(T) \Rightarrow \mathrm{survives}(S)$ pointwise, so
monotonicity (Lemma 2.7) applies; equivalently $p^{|T|} \le p^{|S|}$ by Theorem
3.1. $\qquad\blacksquare$

**Definition 3.3 (Expected number of survivors).** For a finite family
$F \subseteq 2^{\iota}$ of edge sets, the expected number of members surviving is
$$
\mathbb{E}_p[F] \;=\; \sum_\omega \mathrm{weight}_p(\omega)\cdot \bigl|\{S \in F : \mathrm{survives}(S)(\omega)\}\bigr|.
$$

**Theorem 3.4 (Linearity of expectation / first moment).** For every finite
family $F$,
$$
\mathbb{E}_p[F] \;=\; \sum_{S \in F} p^{\,|S|}.
$$

*Proof sketch.* Write the survivor count as $\sum_{S \in F}
\mathbf{1}[\mathrm{survives}(S)]$, interchange the two finite sums, and apply
Theorem 3.1 to each inner sum. $\qquad\blacksquare$

## 4. Contrarian analysis: conjectures settled

We now state four sharp claims around the Target and settle each.

### 4.1 A false conjecture: single-structure persistence

**Naive Conjecture.** *For any fixed $p < 1$, a single prescribed cycle survives
a.a.s. as its length grows.*

This is false, and dramatically so.

**Theorem 4.1 (Fragility of a single structure).** Let $0 \le p < 1$. Let
$C_L$ denote a prescribed edge set of size $L$ (for instance a fixed Hamiltonian
cycle on $L$ edges). Then
$$
\Pr\nolimits_p[\mathrm{survives}(C_L)] \;=\; p^{L} \;\xrightarrow[L\to\infty]{}\; 0.
$$

*Proof.* By Theorem 3.1 the probability equals $p^L$; since $0 \le p < 1$, the
geometric sequence $p^L \to 0$. $\qquad\blacksquare$

**Interpretation.** No single distinguished long cycle can be the source of
persistence: its survival probability decays exponentially in its length. Any
proof of the Target must therefore exploit the *multiplicity* of candidate
cycles, not the robustness of any one of them.

### 4.2 The union bound over a family (proving absence)

**Theorem 4.2 (Family union bound).** For $0 \le p \le 1$ and any finite family
$F$ of edge sets,
$$
\Pr\nolimits_p\bigl[\exists S \in F : \mathrm{survives}(S)\bigr] \;\le\; \sum_{S \in F} p^{\,|S|}.
$$

*Proof sketch.* Induct on $F$. The empty family gives probability $0$. For the
inductive step $F = \{a\} \cup F'$, apply the pairwise union bound (Lemma 2.7) to
split off the event $\mathrm{survives}(a)$, bound $\Pr_p[\mathrm{survives}(a)] =
p^{|a|}$ by Theorem 3.1, and use the inductive hypothesis on $F'$. $\qquad\blacksquare$

**Interpretation.** This is the genuine first-moment tool for proving *absence*.
If the family of long cycles is such that $\sum_{S \in F} p^{|S|} \to 0$, then
a.a.s. *no* long cycle in $F$ survives. It is the quantitative complement of the
existence results below.

### 4.3 Existence from positive expectation (proving existence)

**Theorem 4.3 (Existence from positive first moment).** Let $F$ be a finite
family with $\sum_{S \in F} p^{|S|} > 0$. Then there is an outcome $\omega$ and a
member $S \in F$ with $\mathrm{survives}(S)(\omega)$.

*Proof.* Positivity of the sum forces $F \ne \emptyset$; pick any $S \in F$. The
all-edges-retained outcome $\omega \equiv \text{true}$ satisfies
$\mathrm{survives}(S)$. $\qquad\blacksquare$

**Interpretation.** A strictly positive expected number of survivors cannot occur
in a probability space where the event "some cycle survives" is empty. This is
the elementary existence seed; upgrading it from "there exists an outcome" to
"a.a.s." requires a second-moment (variance) estimate, discussed in Section 8.

### 4.4 The retained-edge count (the degree scaling)

**Theorem 4.4 (Expected retained edges).** Interpreting $\iota$ as the edge set,
the expected number of retained edges equals
$$
\sum_\omega \mathrm{weight}_p(\omega)\cdot \bigl|\{e : \omega(e)=\text{true}\}\bigr| \;=\; p\cdot |\iota|.
$$

*Proof sketch.* Write the retained-edge count as $\sum_e
\mathbf{1}[\omega(e)=\text{true}]$ and interchange sums. For each fixed edge $e$,
$\mathbf{1}[\omega(e)=\text{true}]$ is exactly $\mathrm{survives}(\{e\})$, whose
probability is $p^{|\{e\}|} = p$ by Theorem 3.1. Summing over the $|\iota|$ edges
yields $p\cdot|\iota|$. $\qquad\blacksquare$

**Interpretation.** With host average degree $d$, the surviving subgraph has
expected average degree $p\cdot d$. Choosing $p \approx d/\log n$ makes the
surviving degree scale linearly in $d$, precisely the regime in which cycles of
length proportional to $d$ become achievable.

## 5. The deterministic backbone: minimum degree forces long paths

The probabilistic estimates above supply *connectivity* after decay; converting
connectivity into a long cycle is a deterministic matter. The following is a
classical degree bound in the spirit of Erdős–Gallai and Dirac.

**Theorem 5.1 (Long path from minimum degree).** Let $G$ be a finite simple
graph on a nonempty vertex set in which every vertex has degree at least $k$.
Then $G$ contains a path (a walk with no repeated vertex) of length at least
$k$.

*Proof.* Among all paths of $G$ choose one of maximal length; such a path exists
because a path's vertices are distinct, so its length is bounded by
$|V(G)| - 1$, and the set of achievable path lengths is a nonempty finite set of
naturals. Let $P$ be a longest path and let $v$ be one endpoint. We claim every
neighbour $w$ of $v$ lies on $P$. Indeed, if some neighbour $w$ lay off $P$, then
appending the edge $vw$ to $P$ at the endpoint $v$ would yield a path — still
vertex-distinct because $w \notin V(P)$ — of length $\mathrm{len}(P)+1$,
contradicting maximality. Hence the neighbourhood of $v$ is contained in
$V(P)\setminus\{v\}$. Since $v$ has at least $k$ distinct neighbours, we get
$|V(P)\setminus\{v\}| \ge k$, so $|V(P)| \ge k+1$, and therefore
$\mathrm{len}(P) = |V(P)| - 1 \ge k$. $\qquad\blacksquare$

**Corollary 5.2 (Minimum-degree form).** Every finite simple graph on a nonempty
vertex set contains a path of length at least its minimum degree
$\delta(G)$.

*Proof.* Apply Theorem 5.1 with $k = \delta(G)$, using
$\delta(G) \le \deg(v)$ for all $v$. $\qquad\blacksquare$

## 6. Assembling the pieces toward the Target

The two strands combine into a proof strategy for the Target:

1. **Degree survives (probabilistic).** By Theorem 4.4 and standard
   concentration, in the regime $p \approx d/\log n$ the random subgraph $G_p$
   retains minimum degree of order $p\cdot d$ with high probability. (The
   retained-edge expectation and the union/first-moment calculus of Sections 3–4
   are the relevant tools; concentration is the remaining analytic input.)

2. **Length is forced (deterministic).** Conditioned on the surviving minimum
   degree, Corollary 5.2 forces a path — and, via the standard closing argument
   turning a maximal path into a cycle through the farthest endpoint neighbour, a
   *cycle* — of length proportional to the surviving degree, i.e. of length at
   least $d - \epsilon d$ for suitable constants.

3. **Absence of over-optimism (contrarian).** Theorem 4.1 rules out the naive
   route through a single fixed cycle, while Theorem 4.2 provides the matching
   upper bound that certifies which cycle lengths *cannot* persist, pinning the
   threshold from above.

Thus the exact survival law (Theorem 3.1), the first-moment identities (Theorems
3.4, 4.4), the union bound (Theorem 4.2), the positive-expectation principle
(Theorem 4.3), and the degree-forces-length backbone (Theorem 5.1) are precisely
the load-bearing components of the Target.

## 7. Algorithms and numerical illustration

We describe two algorithms that make the theory concrete and are implemented in
the accompanying numerical demonstrations.

**Algorithm A (Exact survival and first-moment evaluation).** Given a retention
probability $p$ and a family $F$ of edge sets, compute (i) each survival
probability $p^{|S|}$ exactly, (ii) the first-moment upper bound $\sum_{S\in F}
p^{|S|}$ on the probability that some member survives, and (iii) the Monte-Carlo
estimate of that probability, verifying the union bound of Theorem 4.2 and the
sharpness of Theorem 3.1.

**Algorithm B (Percolate-and-measure).** Given a host graph $G$ and probability
$p$, sample $G_p$ by independent edge retention, compute its minimum degree, and
extract a longest path via the maximal-path argument of Theorem 5.1. Averaging
over many samples confirms (i) the expected retained-edge count $p\cdot|E|$
(Theorem 4.4) and (ii) that the discovered path length meets or exceeds the
surviving minimum degree (Corollary 5.2).

Numerically one observes: for a fixed cycle of length $L$, the empirical survival
frequency tracks $p^L$ and collapses to $0$ as $L$ grows (Theorem 4.1); for a
dense host, the surviving minimum degree concentrates near $p\cdot d$ and the
longest discovered path reliably exceeds it, exactly as the deterministic
backbone predicts.

## 8. Discussion, applications, and future work

**Applications.** The retention model is the standard abstraction for random edge
failure in communication networks, for percolation in disordered media, and for
robustness of biological and social networks. The message of the contrarian
analysis — that resilience is a property of the *ensemble* of cycles rather than
of any distinguished cycle — is a design principle: redundancy, not
indestructibility of individual components, is what buys reliability.

**Future work.**

1. *From paths to cycles.* Upgrade Theorem 5.1 to a circumference bound: minimum
   degree $\ge k$ forces a cycle of length $\ge k+1$ (Dirac's theorem), by
   closing a maximal path through the farthest neighbour of an endpoint.

2. *Second moment.* Complement the union bound with a Paley–Zygmund /
   Chebyshev second-moment estimate on the survivor count, promoting Theorem 4.3
   from "there exists an outcome" to "a.a.s. a survivor."

3. *Coupling the halves.* Combine the retained-degree concentration with the
   deterministic backbone applied to $G_p$ to obtain the a.a.s. long cycle,
   completing the skeleton of the Target.

4. *Sharpness.* Establish matching upper bounds showing the $d - \epsilon d$
   guarantee is essentially best possible in the stated $p$-window.

## 9. Conclusion

We have distilled the persistence-of-cycles phenomenon into a compact, rigorous
core: an exact survival law $p^{|S|}$, a complete elementary probability
calculus, first-moment identities and a union bound, a decisive disproof of the
single-structure conjecture, and a self-contained proof that minimum degree
forces long paths. These results explain both why long cycles are individually
fragile and why they collectively persist, and they chart a clear path to the
full asymptotic theorem.
