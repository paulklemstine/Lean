# Combinatorial Fixed Points and Nash Equilibria: From Sperner's Lemma to the Pure-Deviation Principle

## Abstract

We present a self-contained development linking the combinatorial core of fixed-point theory to the existence and computation of Nash equilibria in finite games. On the combinatorial side we prove the one-dimensional Sperner lemma in its exact parity form — the number of fully colored edges of a two-colored path has the parity of the endpoint discrepancy — and derive from it a discrete intermediate value theorem and a discrete Brouwer fixed-point theorem. On the game-theoretic side we develop finite two-player games, mixed strategies, and expected payoffs, and prove the **pure-deviation principle**: because expected payoff is linear (an average) in each player's mixed strategy, a strategy profile is a Nash equilibrium as soon as no player can profit by deviating to a *pure* strategy. This reduces the verification of equilibrium — nominally a statement about a continuum of deviations — to finitely many checks, and it is exactly the finiteness that makes Sperner/Brouwer-based algorithms for Nash equilibria possible. We illustrate the framework with two canonical games: Matching Pennies, whose unique equilibrium is fully mixed, and the Prisoner's Dilemma, whose unique equilibrium is mutual defection. Throughout, we emphasize that Nash equilibria are, at heart, *combinatorial fixed points*.

**Keywords:** Sperner's lemma, Brouwer fixed point, Nash equilibrium, mixed strategy, best response, pure-deviation principle, discrete intermediate value theorem, game theory.

---

## 1. Introduction

Two great existence theorems anchor twentieth-century applied mathematics. **Brouwer's fixed-point theorem** asserts that every continuous self-map of a compact convex set has a fixed point; **Nash's theorem** asserts that every finite game has a mixed-strategy equilibrium. The two are intimately related: Nash's original proof deduces equilibrium existence from a fixed point of a best-response correspondence, via Kakutani's generalization of Brouwer's theorem.

Beneath Brouwer's theorem, in turn, lies a purely combinatorial fact: **Sperner's lemma**, which counts the fully labeled cells of a colored triangulation. Sperner's lemma is elementary, finite, and *constructive*. It thus offers an appealing bottom-up route to the whole edifice: Sperner $\Rightarrow$ Brouwer $\Rightarrow$ Nash, with each arrow refining a finite combinatorial certificate into an analytic existence statement.

This paper develops both ends of that arc rigorously and makes the connecting principle explicit. We work out the one-dimensional Sperner lemma completely — including the parity statement, an oriented existence corollary, a discrete intermediate value theorem, and a discrete Brouwer fixed point — and we develop the algebra of finite two-player games up to the structural theorem that governs all equilibrium computation: the **pure-deviation principle**. The one-dimensional case is deliberately chosen so that every step is elementary and transparent while exhibiting the exact mechanism (a parity/sign-change count) that generalizes to arbitrary dimension.

Our contributions are:

1. A clean parity form of the one-dimensional Sperner lemma and its oriented existence corollary (§3).
2. A discrete intermediate value theorem and a discrete Brouwer fixed point derived from it (§4).
3. A formal treatment of finite two-player games, culminating in the pure-deviation principle: equilibrium verification reduces to finitely many pure-strategy checks (§5–6).
4. Worked equilibria for Matching Pennies (fully mixed) and the Prisoner's Dilemma (pure), demonstrating the framework end to end (§7).

We close with the conceptual synthesis — Nash equilibria as combinatorial fixed points — and a roadmap of extensions (§8–9).

---

## 2. The combinatorial setting

Fix an integer $n \geq 0$. Consider the path graph on vertices $0, 1, \ldots, n$, whose edges are the adjacent pairs $(i, i+1)$ for $0 \le i < n$. A **two-coloring** is a function $c$ assigning to each vertex a Boolean color, which we may read as red/blue or as false/true.

**Definition 2.1 (Fully colored edge).** An edge $(i, i+1)$ is *fully colored* if its endpoints receive different colors, $c(i) \neq c(i+1)$. In the language of Sperner's lemma, in dimension one the fully colored edges are exactly the *fully labeled simplices*. We write
$$\mathrm{FC}(c, n) = \{\, i : 0 \le i < n,\ c(i) \neq c(i+1)\,\}$$
for the set of (left endpoints of) fully colored edges, and $|\mathrm{FC}(c,n)|$ for its cardinality.

---

## 3. The one-dimensional Sperner lemma

**Theorem 3.1 (Sperner's lemma, parity form).** For every two-coloring $c$ and every $n \geq 0$,
$$|\mathrm{FC}(c, n)| \equiv \begin{cases} 0 \pmod 2 & \text{if } c(0) = c(n), \\ 1 \pmod 2 & \text{if } c(0) \neq c(n). \end{cases}$$

*Proof sketch.* Induct on $n$. For $n = 0$ there are no edges, $c(0) = c(n)$ trivially, and the empty count is even. For the inductive step, compare the path of length $n$ to that of length $n+1$, which adds the single edge $(n, n+1)$.

- If $c(n) = c(n+1)$, the new edge is not fully colored, so the count is unchanged; and the endpoint comparison $c(0)$ versus $c(n+1) = c(n)$ is also unchanged. Both sides of the claimed congruence are preserved.
- If $c(n) \neq c(n+1)$, the count increases by one, flipping its parity; and the endpoint comparison flips too, since $c(n+1) \neq c(n)$ reverses whether $c(0)$ agrees with the right endpoint. Both sides flip in lockstep.

In either case the congruence for $n+1$ follows from that for $n$. $\square$

The parity form is the sharpest statement: it does not merely assert existence but pins down the count modulo two. Its immediate consequences are the existence results.

**Corollary 3.2 (Existence of a fully colored edge).** If $c(0) \neq c(n)$, then some edge is fully colored: there exists $i < n$ with $c(i) \neq c(i+1)$.

*Proof.* By Theorem 3.1 the count is odd, hence nonzero. Equivalently, and constructively: if *no* edge were fully colored, then $c$ would be constant along the whole path, forcing $c(0) = c(n)$, a contradiction. $\square$

**Corollary 3.3 (Oriented Sperner existence).** Suppose $c$ satisfies the *Sperner boundary condition* $c(0) = \text{false}$ and $c(n) = \text{true}$. Then there exists $i < n$ with $c(i) = \text{false}$ and $c(i+1) = \text{true}$ — an oriented fully colored edge, with false on the left and true on the right.

*Proof sketch.* Induct on $n$, tracking the first index at which the color becomes true. Because the path begins false and ends true, there is a first ascent from false to true, and its location gives the oriented edge. $\square$

The orientation in Corollary 3.3 is the source of the lemma's *algorithmic* power: it does not merely certify that a boundary between the colors exists, it specifies the direction of the crossing, so the crossing can be located by a directed search rather than an exhaustive one.

---

## 4. Discrete intermediate value and discrete Brouwer

Recoloring by sign turns Sperner's lemma into order-theoretic statements. Given integers $f(0), \ldots, f(n)$, color vertex $j$ false if $f(j) \le 0$ and true if $f(j) > 0$; a fully colored edge is then precisely a sign change.

**Theorem 4.1 (Discrete intermediate value theorem).** Let $f : \{0, \ldots, n\} \to \mathbb{Z}$ with $n \ge 1$, $f(0) \le 0$, and $f(n) \ge 0$. Then there exists $i < n$ with
$$f(i) \le 0 \quad\text{and}\quad f(i+1) \ge 0.$$

*Proof sketch.* If $f$ is identically nonpositive then $f(n) \le 0$ together with $f(n) \ge 0$ gives $f(n) = 0$, and the edge $(n-1, n)$ works. Otherwise let $i+1$ be the first index where $f$ becomes strictly positive; then $f(i) \le 0$ and $f(i+1) > 0 \ge 0$. This is exactly Corollary 3.2/3.3 read through the sign coloring. $\square$

This is the discrete, finite skeleton of the classical intermediate value theorem: a quantity passing from non-positive to non-negative must cross a sign boundary across a single step.

**Theorem 4.2 (Discrete Brouwer fixed point).** Let $g : \{0, \ldots, n\} \to \{0, \ldots, n\}$ be any self-map, with $n \ge 1$. Then there exists $i < n$ with
$$i \le g(i) \quad\text{and}\quad g(i+1) \le i+1.$$
That is, $g$ pushes weakly rightward at $i$ and weakly leftward at $i+1$ — an approximate fixed point straddled by the edge $(i, i+1)$.

*Proof sketch.* Apply Theorem 4.1 to the displacement $f(j) = j - g(j)$. Since $g$ maps into $\{0, \ldots, n\}$ we have $f(0) = -g(0) \le 0$ and $f(n) = n - g(n) \ge 0$. The theorem yields $i < n$ with $f(i) \le 0$ (i.e. $i \le g(i)$) and $f(i+1) \ge 0$ (i.e. $g(i+1) \le i+1$). $\square$

Theorem 4.2 is the combinatorial fixed point at the heart of the Sperner $\Rightarrow$ Brouwer bridge. In higher dimension, and after refining the triangulation and passing to a limit by compactness, it yields Brouwer's theorem on the simplex; through the best-response construction that in turn yields Nash equilibria. We now develop the algebraic side that meets it.

---

## 5. Finite two-player games

**Definition 5.1 (Finite game).** A *finite two-player game* consists of finite strategy sets $I$ and $J$ and two payoff functions $u_1, u_2 : I \times J \to \mathbb{R}$. The value $u_1(i,j)$ is player 1's payoff, and $u_2(i,j)$ player 2's payoff, when the pure strategy pair $(i,j)$ is played.

**Definition 5.2 (Mixed strategy).** A *mixed strategy* for a player with strategy set $I$ is a probability distribution $p : I \to \mathbb{R}$, meaning $p_i \ge 0$ for all $i$ and $\sum_{i \in I} p_i = 1$. The **pure strategy** $a \in I$ corresponds to the degenerate distribution $e_a$ with $(e_a)_i = 1$ if $i = a$ and $0$ otherwise; one checks immediately that $e_a$ is a distribution.

**Definition 5.3 (Expected payoff).** Under a mixed profile $(p, q)$ with $p$ a distribution on $I$ and $q$ a distribution on $J$, the expected payoffs are
$$E_1(p, q) = \sum_{i \in I}\sum_{j \in J} p_i\, q_j\, u_1(i,j), \qquad E_2(p, q) = \sum_{i \in I}\sum_{j \in J} p_i\, q_j\, u_2(i,j).$$

**Definition 5.4 (Nash equilibrium).** A profile $(p, q)$ of distributions is a **Nash equilibrium** if neither player can strictly improve by unilateral deviation:
$$E_1(p', q) \le E_1(p, q) \ \text{ for every distribution } p', \qquad E_2(p, q') \le E_2(p, q) \ \text{ for every distribution } q'.$$

Note the quantifiers range over the entire simplex of mixed strategies — a continuum of potential deviations. The central structural theorem of §6 collapses this to a finite condition.

**Lemma 5.5 (Pure-strategy payoffs).** For a pure strategy $a \in I$,
$$E_1(e_a, q) = \sum_{j \in J} q_j\, u_1(a, j),$$
and symmetrically $E_2(p, e_b) = \sum_{i \in I} p_i\, u_2(i, b)$.

*Proof.* Substitute $e_a$ into Definition 5.3; the inner sum over $i$ collapses to the single term $i = a$ because $(e_a)_i = 0$ otherwise. $\square$

---

## 6. The pure-deviation principle

The engine of finite game theory is that expected payoff is **linear** — an average — in each player's own randomization.

**Theorem 6.1 (Linearity of expected payoff).** For any distribution $q$ on $J$ and any distribution $p'$ on $I$,
$$E_1(p', q) = \sum_{i \in I} p'_i\, E_1(e_i, q).$$
Symmetrically, $E_2(p, q') = \sum_{j \in J} q'_j\, E_2(p, e_j)$.

*Proof.* Using Lemma 5.5, $\sum_i p'_i E_1(e_i, q) = \sum_i p'_i \sum_j q_j u_1(i,j) = \sum_i \sum_j p'_i q_j u_1(i,j) = E_1(p', q)$, by distributing the sum. $\square$

Theorem 6.1 says the payoff of a mixed strategy is exactly the $p'$-weighted average of the pure-strategy payoffs $E_1(e_i, q)$. A weighted average of numbers never exceeds the largest of them, and more usefully, never exceeds any common upper bound. This yields the monotonicity lemma:

**Lemma 6.2 (Mixed deviations are dominated by pure deviations).** Fix $q$ (a distribution on $J$) and a profile component $p$. If every pure deviation is unprofitable, i.e. $E_1(e_a, q) \le E_1(p, q)$ for all $a \in I$, then every mixed deviation is unprofitable: $E_1(p', q) \le E_1(p, q)$ for every distribution $p'$. The symmetric statement holds for player 2.

*Proof.* By Theorem 6.1, $E_1(p', q) = \sum_i p'_i E_1(e_i, q)$. Since each $p'_i \ge 0$ and $E_1(e_i, q) \le E_1(p, q)$, term-by-term we get $\sum_i p'_i E_1(e_i, q) \le \sum_i p'_i E_1(p, q) = E_1(p, q) \sum_i p'_i = E_1(p, q)$, using $\sum_i p'_i = 1$. $\square$

Combining Lemma 6.2 for both players gives the principle in full.

**Theorem 6.3 (Pure-deviation principle).** Let $(p, q)$ be a profile of distributions. Suppose:
$$E_1(e_a, q) \le E_1(p, q) \ \text{ for every pure } a \in I, \qquad E_2(p, e_b) \le E_2(p, q) \ \text{ for every pure } b \in J.$$
Then $(p, q)$ is a Nash equilibrium.

*Proof.* Immediate from Definition 5.4 and two applications of Lemma 6.2. $\square$

**Significance.** Definition 5.4 quantifies over infinitely many mixed deviations; Theorem 6.3 replaces this by checking $|I| + |J|$ pure deviations. This is the finiteness that (i) makes equilibrium a *decidable* property of a rational-payoff game, (ii) permits "best response" to be tabulated, and (iii) connects Nash equilibria to the finite combinatorics of Sperner's lemma. In the Sperner/Brouwer construction, the best-response map is defined by comparing finitely many pure payoffs at each mixed profile; a fixed point of that map is, by exactly Theorem 6.3, a Nash equilibrium.

---

## 7. Worked equilibria

**7.1 Matching Pennies.** Let $I = J = \{\text{H}, \text{T}\}$ with $u_1(a,b) = +1$ if $a = b$ and $-1$ otherwise, and $u_2 = -u_1$ (a zero-sum game): player 1 wins on a match, player 2 on a mismatch. This game has *no* pure equilibrium — for any deterministic pair, the loser strictly prefers to switch.

**Claim.** The uniform profile $p = q = (\tfrac12, \tfrac12)$ is a Nash equilibrium.

*Proof.* Both are distributions. Against the uniform $q$, each pure strategy of player 1 yields $E_1(e_a, q) = \tfrac12(+1) + \tfrac12(-1) = 0$, and $E_1(p, q) = 0$ as well, so no pure deviation helps; symmetrically for player 2, each pure payoff is $0 = E_2(p, q)$. By Theorem 6.3, $(p, q)$ is an equilibrium. $\square$

Matching Pennies exhibits the necessity of *mixed* strategies: equilibrium exists (as Nash's theorem guarantees) but only through randomization. Deliberate unpredictability is the stable behavior.

**7.2 Prisoner's Dilemma.** Let $I = J = \{\text{C}, \text{D}\}$ (Cooperate/Defect) with the classic payoffs: mutual cooperation $(3,3)$, mutual defection $(1,1)$, and for a unilateral defection the defector earns $5$ while the cooperator earns $0$.

**Claim.** Mutual defection $(e_{\text{D}}, e_{\text{D}})$ is a Nash equilibrium.

*Proof.* Both components are (degenerate) distributions. Given player 2 defects, player 1's pure payoffs are $E_1(e_{\text{C}}, e_{\text{D}}) = 0$ and $E_1(e_{\text{D}}, e_{\text{D}}) = 1$; the incumbent choice D is the maximizer, so no pure deviation helps. By symmetry the same holds for player 2. Theorem 6.3 gives the equilibrium. $\square$

The Prisoner's Dilemma illustrates the gap between individual rationality and collective welfare: the unique equilibrium $(1,1)$ is Pareto-dominated by the non-equilibrium outcome $(3,3)$. Equilibrium is a statement about stability, not optimality.

---

## 8. Algorithms

The constructive content of the theory yields concrete algorithms. We record three.

**8.1 Equilibrium verification.** By Theorem 6.3, checking whether $(p, q)$ is a Nash equilibrium requires only: (a) confirm $p, q$ are distributions; (b) compute $E_1(p,q)$ and $E_2(p,q)$; (c) for each pure $a$, verify $E_1(e_a, q) \le E_1(p, q)$; (d) for each pure $b$, verify $E_2(p, e_b) \le E_2(p, q)$. Cost: $O(|I| \cdot |J|)$ arithmetic operations. This is the algorithmic face of the pure-deviation principle.

**8.2 Support enumeration for $2\times 2$ (and general) games.** A Nash equilibrium is characterized by its *support* — the set of pure strategies played with positive probability. On the support, each player must be indifferent among their played pure strategies (else they would shift weight toward the better one), while off-support pure strategies must be no better. This gives, for each candidate pair of supports, a small linear system; solving it and testing feasibility plus the off-support inequalities (again via Theorem 6.3) locates all equilibria. For $2\times 2$ games this enumerates a constant number of cases and finds every equilibrium exactly.

**8.3 Sperner path-following (schematic).** Triangulate the product of strategy simplices; label each vertex by a pure best response of a designated player; by the higher-dimensional Sperner lemma a fully labeled cell exists, and its barycenter is an approximate equilibrium certified by Theorem 6.3. Refining the triangulation drives the approximation to an exact equilibrium. The oriented existence result (Corollary 3.3) is what makes the search *directed* — the higher-dimensional analogue underlies path-following methods of Lemke–Howson/Scarf type.

---

## 9. Discussion and future directions

We have exhibited the arc Sperner $\Rightarrow$ discrete Brouwer, and independently developed the algebra of finite games up to the pure-deviation principle, the exact hinge that connects the finite combinatorial fixed point to equilibrium existence and computation. The unifying theme is that **Nash equilibria are combinatorial fixed points**: fully labeled simplices of a best-response coloring.

Natural extensions, roughly in order of effort:

1. **Higher-dimensional Sperner.** Generalize the parity theorem to a triangulated $n$-simplex: any Sperner coloring has an odd number of fully labeled cells. A clean route is the door/room (index) argument, a parity count of boundary faces analogous to the one-dimensional edge count established here.

2. **Discrete Brouwer in higher dimension.** From the $n$-dimensional Sperner lemma, extract an approximate fixed point of any self-map of the discrete simplex, mirroring the one-dimensional discrete Brouwer theorem.

3. **Limit to continuous Brouwer.** Refine the triangulation (barycentric subdivision) and pass to the limit using compactness to obtain Brouwer's theorem on the standard simplex, and compare with the classical proof.

4. **Nash existence.** Combine (3) with the best-response construction: the map sending a profile to its regularized best response is continuous on the product of simplices, and a fixed point is a Nash equilibrium. The pure-deviation principle is exactly the finiteness needed to certify the fixed point as an equilibrium.

5. **Zero-sum / minimax.** Specialize to two-player zero-sum games and connect the equilibrium payoff to the minimax value; this needs only the pure-deviation principle together with linear-programming duality.

6. **Algorithmic content.** The oriented existence result is constructive. Turning the higher-dimensional analogue into a verified path-following (Lemke–Howson/Scarf) procedure would yield a fully certified Nash-equilibrium algorithm.

---

## 10. Conclusion

Starting from a fact a child can verify — a two-colored fence with red at one end and blue at the other must flip colors an odd number of times — we built a ladder to one of the load-bearing theorems of modern economics. The parity form of the one-dimensional Sperner lemma gives a discrete intermediate value theorem and a discrete Brouwer fixed point; the linearity of expected payoff gives the pure-deviation principle, collapsing equilibrium verification to finitely many checks; and the two meet in the statement that Nash equilibria are combinatorial fixed points. The finite, oriented, constructive nature of Sperner's lemma is not incidental — it is precisely what turns an existence theorem into an algorithm.
