# Disjunctive Sums and the Mirror Principle in Well-Founded Impartial Games

**Aristotle**  
**15 July 2026**

## Abstract

We develop the outcome theory of disjunctive sums for set-sized, well-founded impartial games, allowing game trees of transfinite rank and arbitrary branching. A position is classified recursively as winning precisely when it has an option that is not winning. We prove that this recursive equation uniquely determines the outcome class, that disjunctive sums preserve well-foundedness, and that the empty game is a two-sided identity for outcomes. For a self-sum, coordinate exchange preserves outcomes. The principal result is a transfinite mirror theorem: for every position $a$, the doubled position $(a,a)$ is losing. Consequently, every opening move from the diagonal gives the opponent a winning position, yielding an explicit second-player strategy. We specialize the theory to the countdown game on natural numbers and obtain the exact two-heap classification: $(m,n)$ is winning if and only if $m\ne n$. This classification supplies counterexamples to two plausible but false composition principles: two winning components can have a losing sum, and an arbitrary losing position need not be neutral. We conclude with algorithms for finite truncations, applications to adversarial planning, and a program toward ordinal Sprague–Grundy theory.

## 1. Introduction

The classical recursive rule for a terminating impartial game is simple: a position is winning when it has a move to a losing position. The apparent simplicity conceals two distinct mathematical tasks. First, one must justify that the recursion is meaningful when the game tree is not finite. Second, one must understand how outcomes behave when independent games are combined and a player may move in either component.

The appropriate termination hypothesis is well-foundedness, not finiteness. A well-founded game has no infinite legal play, but it may have infinitely many options at a position, arbitrarily long finite plays, and ordinal rank greater than every natural number. Well-founded recursion therefore extends ordinary backward induction to a genuinely transfinite setting while retaining the operational meaning of normal play.

The disjunctive sum is the fundamental composition operation. A state of the sum is a pair, and a turn changes exactly one coordinate. Although termination is preserved and order of components does not affect outcomes, the binary labels “winning” and “losing” interact with addition in ways that resist naive intuition. In particular, winning plus winning need not be winning, and losing does not mean neutral.

The main theorem identifies a robust positive principle. Two identical copies of any well-founded impartial position form a losing sum. The opponent of the opening player mirrors each move in the untouched copy, restoring equality after every pair of turns. Well-foundedness guarantees that this response process cannot continue forever. The result is rank-independent: no finite bound on the height of the game tree is assumed.

The countdown game gives a complete concrete model. A heap of size $m$ may be replaced by any smaller natural number. For two heaps, equality is exactly the losing condition. If the heaps differ, reduce the larger to the smaller; if they agree, mirror. This elementary classification both illustrates the transfinite theorem and exposes the failure of two erroneous algebraic heuristics.

## 2. Well-founded impartial games

### 2.1. Positions and moves

A **set-sized impartial game** is a pair $(P,\to)$, where $P$ is a set of positions and $p\to q$ means that $q$ is a legal option from $p$. The same relation governs both players, which is the impartiality assumption. Play alternates, and under the normal-play convention a player unable to move loses.

The move relation is **well-founded** if there is no infinite sequence

$$
p_0\to p_1\to p_2\to\cdots.
$$

Equivalently, every nonempty subset $S\subseteq P$ contains a position $p\in S$ with no move $p\to q$ remaining inside $S$. This minimal-element formulation is particularly useful for uniqueness and contradiction arguments.

Well-foundedness does not impose a uniform finite bound on play. For example, a root may have one option leading to a path of length $n$ for every natural number $n$. Every play terminates, but the root has transfinite rank $\omega$. More complicated well-founded relations produce larger ordinal ranks.

### 2.2. Recursive outcomes

Let $W(p)$ mean that position $p$ is winning for the player whose turn it is. The outcome equation is

$$
W(p)\iff \exists q\in P\,\bigl(p\to q\ \wedge\ \neg W(q)\bigr).
$$

Thus a winning position has an option that is losing for the next player. Negating the equation gives the corresponding characterization

$$
\neg W(p)\iff \forall q\in P\,\bigl(p\to q\Rightarrow W(q)\bigr).
$$

A terminal position is therefore losing. Well-founded recursion defines $W$ by evaluating the options of a position before evaluating the position itself.

**Theorem 2.1 (Outcome existence and recursion).** *Every well-founded impartial game admits an outcome classification $W:P\to\{\mathrm{false},\mathrm{true}\}$ satisfying the recursive outcome equation.*

**Proof sketch.** Apply well-founded recursion to the move relation. At $p$, all values attached to legal options $q$ are already available because $q$ is lower than $p$. Declare $W(p)$ true exactly when one of those option values is false. The construction is valid at every ordinal rank because it follows the well-founded relation itself rather than induction on a fixed natural depth. $\square$

**Theorem 2.2 (Uniqueness of recursive outcomes).** *Suppose $X:P\to\{\mathrm{false},\mathrm{true}\}$ satisfies*

$$
X(p)\iff \exists q\,\bigl(p\to q\ \wedge\ \neg X(q)\bigr)
$$

*for every $p$. Then $X(p)\iff W(p)$ for every $p$.*

**Proof sketch.** If disagreement existed, let $S$ be the set of positions where $X$ and $W$ differ. Choose a move-minimal $p\in S$. Every option $q$ of $p$ lies outside $S$, so $X(q)$ and $W(q)$ agree. The two recursive equations at $p$ then have equivalent right-hand sides, forcing $X(p)$ and $W(p)$ to agree, a contradiction. $\square$

This uniqueness principle permits structural proofs without unfolding a particular transfinite recursion. It suffices to show that a transformed classification obeys the same equation.

## 3. Disjunctive addition

### 3.1. Definition

Let $(P,\to_P)$ and $(Q,\to_Q)$ be impartial games. Their **disjunctive sum** has position set $P\times Q$. A move changes exactly one coordinate:

$$
(p,q)\to (p',q)\quad\text{if }p\to_P p',
$$

or

$$
(p,q)\to (p,q')\quad\text{if }q\to_Q q'.
$$

No move changes both coordinates. We write $W_{P+Q}(p,q)$ for the recursive outcome in the sum.

### 3.2. Preservation of termination

**Theorem 3.1 (Well-foundedness of the disjunctive sum).** *If $(P,\to_P)$ and $(Q,\to_Q)$ are well-founded, then their disjunctive sum is well-founded.*

**Proof sketch.** Suppose an infinite sum play existed. Color each move left or right according to the changed coordinate. At least one color occurs infinitely often. Taking the corresponding subsequence yields an infinite descending chain in that component, contradicting its well-foundedness. Equivalently, one may combine ordinal rank functions for the components using a well-founded product order. $\square$

The theorem ensures that $W_{P+Q}$ is available for arbitrary well-founded components, including components of transfinite rank.

### 3.3. The empty game

The **empty game** $0$ is the one-position game whose sole position $\ast$ has no options. It is important that “empty” describes the move structure, not merely the outcome label.

**Theorem 3.2 (Two-sided terminal identity).** *For every position $p$ of every well-founded impartial game,*

$$
W_{P+0}(p,\ast)\iff W_P(p)
$$

*and*

$$
W_{0+P}(\ast,p)\iff W_P(p).
$$

**Proof sketch.** In $(p,\ast)$ every legal move has the form $(p,\ast)\to(p',\ast)$ with $p\to_Pp'$, since the empty coordinate has no move. Therefore the function $(p,\ast)\mapsto W_P(p)$ satisfies exactly the recursive outcome equation of the sum. Uniqueness gives the right-identity statement. The left-identity statement is symmetric. $\square$

### 3.4. Coordinate symmetry

For a self-sum $P+P$, let $\sigma(p,q)=(q,p)$.

**Lemma 3.3 (Move symmetry).** *For all self-sum positions $x$ and $y$, there is a legal move $x\to y$ if and only if there is a legal move $\sigma(x)\to\sigma(y)$.*

**Proof sketch.** A left-coordinate move becomes a right-coordinate move after swapping, and conversely. $\square$

**Theorem 3.4 (Outcome commutativity for a self-sum).** *For all $a,b\in P$,*

$$
W_{P+P}(a,b)\iff W_{P+P}(b,a).
$$

**Proof sketch.** Define $X(a,b)=W_{P+P}(b,a)$. By Lemma 3.3, $X$ satisfies the same recursive outcome equation as $W_{P+P}$. The uniqueness theorem implies $X=W_{P+P}$. $\square$

For heterogeneous games, swapping coordinates similarly gives an isomorphism between $P+Q$ and $Q+P$. The self-sum formulation is enough for the mirror theorem.

## 4. The transfinite mirror theorem

**Theorem 4.1 (Transfinite Mirror Theorem).** *Let $(P,\to)$ be any well-founded impartial game. For every $a\in P$, the diagonal self-sum position $(a,a)$ is losing:*

$$
\neg W_{P+P}(a,a).
$$

**Proof sketch by well-founded induction.** Assume the result holds for every option $b$ of $a$. Any opening move from $(a,a)$ changes one copy, producing either $(b,a)$ or $(a,b)$ with $a\to b$. In the first case, the opponent can move in the second component to $(b,b)$; in the second case, the opponent can move in the first component to $(b,b)$. By the induction hypothesis, $(b,b)$ is losing. Hence every option from $(a,a)$ is winning, so $(a,a)$ is losing. Well-founded induction applies regardless of the ordinal rank of $a$. $\square$

A global contradiction proof emphasizes the necessity of termination. If some diagonal were winning, recursive analysis would produce a smaller winning diagonal. Repeating this selection would yield

$$
a_0\to a_1\to a_2\to\cdots,
$$

contrary to well-foundedness.

### 4.1. Strategic interpretation

Define the assertion that the mover can force an immediate strategic advantage at $p$ by

$$
M(p)\iff \exists q\,\bigl(p\to q\ \wedge\ \neg W(q)\bigr).
$$

Define the assertion that the opponent controls $p$ by

$$
O(p)\iff \forall q\,\bigl(p\to q\Rightarrow W(q)\bigr).
$$

**Theorem 4.2 (Well-founded determinacy).** *At every position $p$ of a well-founded impartial game, exactly one strategic alternative applies: either $W(p)$ and $M(p)$ hold, or $\neg W(p)$ and $O(p)$ hold.*

**Proof sketch.** If $W(p)$ holds, the recursive equation supplies a legal move to a losing option, so $M(p)$ holds. If $W(p)$ fails, no legal option can be losing; therefore every option is winning and $O(p)$ holds. The alternatives are incompatible by definition. $\square$

**Corollary 4.3 (Diagonal opponent control).** *From $(a,a)$, every legal opening move gives the opponent a winning position. More concretely, the opponent can restore equality by making the corresponding move in the other component.*

**Proof sketch.** Theorem 4.1 says the diagonal is losing, and Theorem 4.2 says every option from a losing position is winning. The explicit mirror response reaches the smaller losing diagonal described in the proof of Theorem 4.1. $\square$

The strategic statement is stronger in presentation than a bare outcome label: it identifies the invariant maintained by the second player. After every response, both coordinates agree. An infinite succession of responses would contradict well-foundedness, so the strategy eventually makes the final move.

## 5. Countdown and the exact two-heap law

### 5.1. The countdown game

Let positions be natural numbers. Define a move by

$$
m\to n\iff n<m.
$$

Thus a heap may be replaced by any strictly smaller heap. This relation is well-founded because the natural numbers admit no infinite strictly descending sequence.

The two-component sum consists of pairs $(m,n)\in\mathbb N^2$. A move strictly decreases exactly one coordinate.

**Theorem 5.1 (Two-Heap Countdown Theorem).** *For all $m,n\in\mathbb N$,*

$$
W(m,n)\iff m\ne n.
$$

**Proof sketch.** If $m=n$, Theorem 4.1 applies and the position is losing. If $m<n$, reduce the second heap from $n$ to $m$, reaching $(m,m)$; if $n<m$, reduce the first heap from $m$ to $n$, reaching $(n,n)$. In either unequal case the mover has a legal option to a losing diagonal position and therefore wins. $\square$

The theorem yields a constant-time optimal policy when heaps are represented as machine integers:

1. If $m=n$, no winning move exists against perfect play.
2. If $m<n$, replace $n$ by $m$.
3. If $n<m$, replace $m$ by $n$.

After an opponent disturbs equality, repeat the rule. The mathematical policy uses $O(1)$ comparisons and assignments. If bit complexity is counted and the heaps have at most $b$ bits, comparison costs $O(b)$.

### 5.2. Dynamic programming on a finite window

For computation, restrict to $0\le m,n\le N$. Process states by increasing $m+n$. Set $(0,0)$ losing. A state is winning if at least one smaller one-coordinate neighbor is losing. There are $(N+1)^2$ states, and naive option enumeration checks at most $2N$ moves per state, giving $O(N^3)$ time and $O(N^2)$ space. Theorem 5.1 collapses this table computation to $O(N^2)$ time merely to emit all entries, or $O(1)$ time for a single query.

The resulting matrix has false entries exactly on the main diagonal. This provides a useful validation pattern for outcome solvers: recursion and the direct equality criterion must agree on every bounded instance.

## 6. Contrarian consequences

The exact countdown law separates three notions often conflated in informal reasoning: a component that is winning by itself, a position that is losing by itself, and a game that contributes no moves.

**Proposition 6.1 (Two winning components can sum to a loss).** *In countdown, each one-heap position $1$ is winning, but the sum $(1,1)$ is losing.*

**Proof sketch.** A player at heap $1$ moves to $0$ and wins, so each component is winning. The pair lies on the diagonal, so Theorem 5.1 makes it losing. $\square$

This refutes the implication

$$
W(a)\wedge W(b)\Rightarrow W(a+b).
$$

Outcome labels do not add monotonically. The players alternate globally across both components, allowing two individually favorable opportunities to cancel.

**Proposition 6.2 (A losing position need not be neutral).** *In countdown, the position $0$ is losing, while $(0,1)$ is winning.*

**Proof sketch.** Heap $0$ has no legal move, so it is losing. Since $0\ne1$, Theorem 5.1 makes $(0,1)$ winning; explicitly, the mover reduces $1$ to $0$ and leaves $(0,0)$. $\square$

There is no contradiction with Theorem 3.2. The theorem concerns the empty game as a whole. Proposition 6.2 concerns a terminal position embedded as one component beside a nonterminal component. More broadly, the isolated outcome label of a position does not encode all option structure required for composition.

It is equally important not to overread Proposition 6.2. It does not refute the expected statement that the sum of two losing impartial positions is losing; indeed $(0,0)$ is losing. It refutes the stronger and different claim that adding a losing component never changes the other component’s winner. The distinction motivates a richer compositional invariant.

## 7. Algorithms and numerical demonstrations

### 7.1. Recursive outcome evaluation on finite acyclic graphs

A finite well-founded game may be represented by a directed acyclic graph. Memoized depth-first search evaluates a position $p$ as follows: recursively evaluate each option until a losing option is found; return winning if one exists and losing otherwise. Each reachable vertex is evaluated once and each outgoing edge is inspected at most once, for time $O(|V|+|E|)$ and storage $O(|V|)$, in addition to recursion depth.

For a sum graph, options are generated lazily by changing one coordinate. Materializing the entire product can be expensive, with up to $|P||Q|$ states. Symmetry and the mirror theorem avoid that blowup for diagonal self-sums: no product search is needed to classify $(a,a)$.

### 7.2. Strategy simulation

A simulation of the countdown mirror strategy begins from $(n,n)$. An adversarial first player selects a legal decrease in one heap. The second player copies the resulting heap size into the other coordinate. The state returns to $(k,k)$ with $k<n$. Repetition strictly decreases the diagonal value, so at most $n$ mirrored rounds occur if each decrease is by one; larger jumps finish sooner.

### 7.3. Visualization

Three numerical views are informative:

- an outcome heatmap showing a losing diagonal;
- trajectories under mirror play, which touch the diagonal after every second move;
- a directed move neighborhood illustrating that every off-diagonal countdown state points directly to a diagonal state.

These are demonstrations, not substitutes for the general theorem. Their role is to reveal the geometry that the proof captures for arbitrary well-founded move relations.

## 8. Applications and interpretation

Well-founded games arise whenever a progress measure strictly decreases. In planning, the measure may be a lexicographic objective, an ordinal rank attached to recursive subtasks, or a certificate that prevents cyclic execution. Disjunctive sums model systems in which a controller chooses one independent task to update at each step.

The mirror theorem supplies a compositional policy for duplicated systems. If two subsystems have identical state spaces and transition rules and begin in the same state, the responding player need not solve the entire combined search problem. It suffices to preserve the equality invariant. This can reduce a potentially enormous policy computation to recognition of the opponent’s transition and its replay in the paired component.

In adversarial machine learning and multi-agent planning, the result offers two conceptual lessons. First, termination certificates can support backward reasoning beyond bounded horizons; a well-founded rank is enough. Second, symmetry can be algorithmic information. An invariant-respecting response may dominate brute-force search even when the state graph is infinitely branching or has transfinite rank.

The counterexamples provide a caution about learned value labels. A binary classifier that marks positions winning or losing is sufficient for isolated optimal play, but insufficient as a compositional representation. Coupling two states can reverse an apparent advantage, and a losing state is not necessarily behaviorally equivalent to an absent subsystem. Compositional prediction calls for a richer latent quantity preserving addition.

## 9. Toward ordinal Grundy values

For finite impartial games, the required invariant is the Grundy value. It is defined recursively as the least nonnegative integer not attained by an option. For set-sized well-founded games, the natural extension is ordinal-valued:

$$
g(p)=\operatorname{mex}\{g(q):p\to q\},
$$

where $\operatorname{mex}$ denotes the least ordinal absent from the displayed set.

The expected classification is

$$
W(p)\iff g(p)\ne0.
$$

Indeed, $g(p)=0$ should mean no option has value $0$, while $g(p)\ne0$ should imply that $0$ occurs among the option values. A full treatment must establish that ordinal least-exclusion interacts correctly with well-founded recursion for every set-sized option family.

The anticipated addition theorem is

$$
g(p+q)=g(p)\mathbin{\oplus}g(q),
$$

where $\oplus$ is ordinal nim-addition rather than ordinary ordinal addition. This would explain the mirror theorem through the identity $\alpha\oplus\alpha=0$ and establish closure of arbitrary losing positions under addition. It would also organize finite-support sums into a commutative monoid of values.

The present results provide stringent tests for such a theory. Any proposed transfinite Grundy construction must preserve well-founded sums, treat the empty game as zero, respect coordinate exchange, recover diagonal cancellation, and specialize in countdown to the equality criterion.

## 10. Discussion

The development shows that a substantial part of combinatorial game algebra depends only on well-foundedness. Neither finite branching nor finite height is needed for recursive outcomes, determinacy, closure under binary sum, terminal identity, commutativity of self-sum outcomes, or diagonal cancellation.

The mirror theorem combines local and global reasoning. Locally, every disturbance of one coordinate can be reproduced in the other. Globally, well-foundedness ensures that repeated responses terminate. Removing either ingredient breaks the conclusion: without identical move structures there may be no matching response, and without termination an endless mirrored play need not award victory under normal play.

Outcome commutativity follows from uniqueness of the recursive equation, while diagonal loss admits an explicit invariant strategy. These are complementary proof patterns. Structural equivalences are naturally established by showing that a transported outcome function satisfies the same recursion. Strategic cancellation is naturally established by well-founded induction on the component move relation.

The countdown classification demonstrates sharpness. The diagonal theorem completely settles the equal case, and a single balancing move settles every unequal case. It also proves that compositional reasoning cannot operate solely on the two outcome classes. A richer value theory is not optional bookkeeping; it is forced by elementary counterexamples.

## 11. Future work

Five directions emerge.

First, construct the ordinal least-excluded value for every set-sized well-founded impartial game and prove that zero values are exactly losing positions. Second, establish the ordinal nim-addition theorem for binary disjunctive sums. Third, derive as a corollary that sums of arbitrary losing positions, even from heterogeneous games, are losing. Fourth, extend binary addition to finite-support indexed families and prove independence of ordering and bracketing. Fifth, connect ordinal rank in terminating games to open games of length $\omega$, preserving the winning player and extracting strategies uniformly from rank.

These objectives would connect recursive outcome theory, algebraic composition, and infinite-play determinacy. The results established here supply the binary operation, its basic symmetries, a universal cancellation law, and a complete nontrivial example against which the broader theory can be measured.

## 12. Conclusion

Well-founded impartial games support a transfinite version of backward induction governed by a unique recursive outcome equation. Their disjunctive sums remain well-founded; the empty game is outcome-neutral; and coordinate exchange preserves the outcome of a self-sum. Most importantly, every diagonal position $(a,a)$ is losing, with a concrete mirror strategy for the second player.

For two countdown heaps, this principle yields the exact law $W(m,n)\iff m\ne n$. Equal heaps cancel, while unequal heaps can be balanced in one move. The same example proves that winning components may combine into a loss and that a losing position is not automatically neutral. Together, these results identify both the power and the limits of binary outcome classification and set the stage for an ordinal-valued arithmetic of transfinite games.