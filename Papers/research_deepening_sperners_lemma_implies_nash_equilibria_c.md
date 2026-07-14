# The One-Dimensional Sperner Lemma as an Exact Signed Count: A Discrete Degree and its Consequences for Fixed Points and Nash Equilibria

## Abstract

We refine the one-dimensional Sperner lemma from a statement about parity to an exact integer identity. Given a two-coloring $c$ of the path $0, 1, \dots, n$, we distinguish *up-edges* (transitions from $0$ to $1$) from *down-edges* (transitions from $1$ to $0$), and prove the telescoping identity
$$ U(c,n) - D(c,n) = \llbracket c(n) \rrbracket - \llbracket c(0) \rrbracket, $$
where $U$ and $D$ count up- and down-edges respectively and $\llbracket \cdot \rrbracket$ interprets `false` as $0$ and `true` as $1$. This quantity is a discrete analogue of the *degree* of a boundary map. We show that every classical consequence of the one-dimensional Sperner lemma follows as a corollary of this single identity: the parity form, the balance of ascending and descending crossings when endpoints agree, oriented and unoriented existence of fully colored edges, two discrete intermediate value theorems, and a discrete Brouwer fixed-point statement. We then explain how the discrete fixed-point result is the combinatorial core of Brouwer's theorem and, through Nash's construction, of the existence of mixed-strategy equilibria in finite games. We complement the general theory with a constant-sum criterion under which the uniform strategy profile is a Nash equilibrium, instantiated to a parametric cyclic family of games that recovers Matching Pennies and Rock–Paper–Scissors as special cases.

**Keywords:** Sperner's lemma, discrete degree, telescoping sum, intermediate value theorem, Brouwer fixed point, Nash equilibrium, combinatorial topology, game theory.

**Mathematics Subject Classification:** 05A19 (combinatorial identities), 55M20 (fixed points), 91A05 (two-person games), 54H25 (fixed-point theorems).

---

## 1. Introduction

Sperner's lemma (1928) is a combinatorial statement about proper colorings of triangulated simplices, famous as the discrete counterpart of Brouwer's fixed-point theorem. In its one-dimensional form it concerns a path $0, 1, \dots, n$ whose vertices are colored with two colors. The classical statement asserts that if the two endpoints receive different colors, then an odd number of edges are *fully colored*, i.e. have endpoints of different colors; in particular at least one such edge exists.

This "existence via parity" is enough for many topological applications, but it discards information. Fully colored edges come in two oriented flavors: those that ascend from color $0$ to color $1$, and those that descend from $1$ to $0$. The parity statement is blind to this orientation. Our contribution is to show that the *signed* difference between the number of ascents and the number of descents is not merely determined modulo $2$—it is determined exactly, as an integer, by the colors of the two endpoints.

The resulting identity is elementary but organizing. It plays, in dimension one, the role that the *degree of a map* plays in topology: an integer-valued invariant, additive and conserved, that detects the existence of preimages. From it we recover the full classical package—parity, existence (oriented and unoriented), intermediate value theorems, and a discrete Brouwer fixed point—each as a short corollary rather than as an independent argument.

The final link, from the discrete fixed point to Nash's equilibrium existence theorem, is conceptual: we explain the standard reduction (Sperner $\Rightarrow$ Brouwer $\Rightarrow$ Kakutani $\Rightarrow$ Nash) and give a self-contained constant-sum criterion for uniform equilibria, illustrated on a cyclic family of symmetric games.

### 1.1 Contributions

1. An exact signed identity for the one-dimensional Sperner lemma (Theorem 3.1), proved by a single telescoping sum.
2. A decomposition of fully colored edges into up- and down-edges (Proposition 3.2).
3. A uniform derivation of parity, balance, and existence results as corollaries (Section 4).
4. Two discrete intermediate value theorems and a discrete Brouwer fixed-point theorem (Section 5).
5. The conceptual bridge to Nash equilibria and a constant-sum uniform-equilibrium criterion with a cyclic family of examples (Section 6).

---

## 2. Definitions

Throughout, a **coloring** of the path on $n+1$ vertices is a function $c : \mathbb{N} \to \{\,\texttt{false}, \texttt{true}\,\}$; only the values $c(0), \dots, c(n)$ are relevant to statements involving $n$. We work over the integers.

**Definition 2.1 (Color value).** The *value* of a Boolean color is
$$ \llbracket b \rrbracket = \begin{cases} 1 & b = \texttt{true}, \\ 0 & b = \texttt{false}. \end{cases} $$

**Definition 2.2 (Up-count).** The number of *up-edges* among the first $n$ edges is
$$ U(c, n) = \#\{\, i \in \{0, \dots, n-1\} : c(i) = \texttt{false} \text{ and } c(i+1) = \texttt{true} \,\}. $$

**Definition 2.3 (Down-count).** The number of *down-edges* among the first $n$ edges is
$$ D(c, n) = \#\{\, i \in \{0, \dots, n-1\} : c(i) = \texttt{true} \text{ and } c(i+1) = \texttt{false} \,\}. $$

**Definition 2.4 (Fully colored edges).** The set of *fully colored edges* is
$$ F(c, n) = \{\, i \in \{0, \dots, n-1\} : c(i) \ne c(i+1) \,\}. $$

An edge $i$ (the segment from vertex $i$ to vertex $i+1$) is fully colored precisely when its endpoints receive different colors; equivalently, when it is either an up-edge or a down-edge, and never both.

---

## 3. The signed count

### 3.1 The flagship identity

**Theorem 3.1 (Signed Sperner count).** For every coloring $c$ and every $n \in \mathbb{N}$,
$$ U(c, n) - D(c, n) = \llbracket c(n) \rrbracket - \llbracket c(0) \rrbracket. $$

*Proof sketch.* Rewrite each cardinality as a sum of indicators over $i \in \{0, \dots, n-1\}$:
$$ U(c,n) - D(c,n) = \sum_{i=0}^{n-1} \Big( \mathbf{1}[c(i)=0,\, c(i+1)=1] - \mathbf{1}[c(i)=1,\, c(i+1)=0] \Big). $$
A case analysis on the four possible values of the pair $(c(i), c(i+1))$ shows that the summand equals $\llbracket c(i+1) \rrbracket - \llbracket c(i) \rrbracket$ in every case: it is $+1$ on an up-edge, $-1$ on a down-edge, and $0$ when the endpoints agree, which matches $\llbracket c(i+1) \rrbracket - \llbracket c(i) \rrbracket$ exactly. Hence
$$ U(c,n) - D(c,n) = \sum_{i=0}^{n-1} \big( \llbracket c(i+1) \rrbracket - \llbracket c(i) \rrbracket \big), $$
and the right-hand side telescopes to $\llbracket c(n) \rrbracket - \llbracket c(0) \rrbracket$. $\qquad\blacksquare$

The quantity $U(c,n) - D(c,n)$ is a **discrete degree**: it is the net signed number of sign changes, and Theorem 3.1 identifies it with a boundary term. This is the exact analogue of the statement that the degree of a map equals its boundary evaluation.

### 3.2 Decomposition of fully colored edges

**Proposition 3.2 (Splitting).** For every coloring $c$ and every $n$,
$$ \# F(c, n) = U(c, n) + D(c, n). $$

*Proof sketch.* The predicate $c(i) \ne c(i+1)$ is logically equivalent to the disjunction "($c(i)=0$ and $c(i+1)=1$) or ($c(i)=1$ and $c(i+1)=0$)", verified by a four-case truth table. These two sub-predicates are mutually exclusive, so the corresponding filtered index sets are disjoint, and the cardinality of their union is the sum of their cardinalities. $\qquad\blacksquare$

Theorem 3.1 and Proposition 3.2 together determine $U$ and $D$ modulo the total count: they give $U - D$ exactly and $U + D = \#F$, so knowing the number of fully colored edges pins down both oriented counts.

---

## 4. Combinatorial corollaries

### 4.1 Parity

**Corollary 4.1 (Parity form).** For every coloring $c$ and every $n$,
$$ \#F(c, n) \equiv \begin{cases} 0 \pmod 2 & \text{if } c(0) = c(n), \\ 1 \pmod 2 & \text{if } c(0) \ne c(n). \end{cases} $$

*Proof sketch.* By Proposition 3.2, $\#F = U + D$, which has the same parity as $U - D$. By Theorem 3.1, $U - D = \llbracket c(n) \rrbracket - \llbracket c(0) \rrbracket \in \{-1, 0, 1\}$, whose parity is $0$ when the endpoints agree and $1$ when they differ. $\qquad\blacksquare$

This recovers the classical one-dimensional Sperner lemma.

### 4.2 Balance

**Corollary 4.2 (Balanced crossings).** If $c(0) = c(n)$, then $U(c, n) = D(c, n)$.

*Proof sketch.* Equal endpoints give $\llbracket c(n) \rrbracket - \llbracket c(0) \rrbracket = 0$, so Theorem 3.1 yields $U - D = 0$. $\qquad\blacksquare$

Every ascent is matched by a descent: a discrete conservation law.

### 4.3 Existence

**Corollary 4.3 (Oriented existence).** If $c(0) = \texttt{false}$ and $c(n) = \texttt{true}$, then there exists $i < n$ with $c(i) = \texttt{false}$ and $c(i+1) = \texttt{true}$.

*Proof sketch.* The hypotheses give $\llbracket c(n) \rrbracket - \llbracket c(0) \rrbracket = 1$, so by Theorem 3.1 $U - D = 1$ and hence $U \ge 1$. A nonempty finite set of up-edges contains an element, which is the desired index. $\qquad\blacksquare$

**Corollary 4.4 (Unoriented existence).** If $c(0) \ne c(n)$, then there exists $i < n$ with $c(i) \ne c(i+1)$.

*Proof sketch.* By Corollary 4.1 the number of fully colored edges is odd, hence positive, so $F(c,n)$ is nonempty. $\qquad\blacksquare$

---

## 5. Discrete intermediate value and fixed-point theorems

The signed count applies to any integer-valued function through the coloring "is this value positive?".

**Theorem 5.1 (Discrete IVT, upward).** Let $f : \mathbb{N} \to \mathbb{Z}$ satisfy $f(0) \le 0 < f(n)$. Then there exists $i < n$ with $f(i) \le 0$ and $f(i+1) > 0$.

*Proof sketch.* Define $c(k) = \texttt{true}$ iff $f(k) > 0$. The hypotheses give $c(0) = \texttt{false}$ and $c(n) = \texttt{true}$, so Corollary 4.3 supplies $i < n$ with $c(i) = \texttt{false}$ (i.e. $f(i) \le 0$) and $c(i+1) = \texttt{true}$ (i.e. $f(i+1) > 0$). $\qquad\blacksquare$

**Theorem 5.2 (Discrete IVT, downward).** Let $f : \mathbb{N} \to \mathbb{Z}$ satisfy $f(n) \le 0 < f(0)$. Then there exists $i < n$ with $f(i) > 0$ and $f(i+1) \le 0$.

*Proof sketch.* Apply Theorem 5.1 with the coloring $c(k) = \texttt{true}$ iff $f(k) \le 0$, which starts `false` and ends `true`; the oriented up-crossing of $c$ is exactly the downward crossing of $f$. $\qquad\blacksquare$

**Theorem 5.3 (Discrete Brouwer fixed point).** Let $g : \mathbb{N} \to \mathbb{N}$ be a self-map of $\{0, \dots, n\}$ with $g(0) > 0$ and $g(n) \le n$. Then there exists $i < n$ with
$$ i < g(i) \qquad\text{and}\qquad g(i+1) \le i+1. $$

*Proof sketch.* Consider the displacement $f(k) = g(k) - k \in \mathbb{Z}$. The hypotheses give $f(0) = g(0) > 0$ and $f(n) = g(n) - n \le 0$, so Theorem 5.2 provides $i < n$ with $f(i) > 0$ and $f(i+1) \le 0$, i.e. $g(i) > i$ and $g(i+1) \le i+1$. $\qquad\blacksquare$

Theorem 5.3 is the combinatorial fixed point behind Brouwer's theorem in dimension one. A continuous self-map $h : [0,1] \to [0,1]$ sampled on a grid of $n+1$ points produces a discrete self-map satisfying (after a boundary normalization) the hypotheses of Theorem 5.3; the located diagonal crossing has displacement changing sign within one grid cell, and as the mesh $1/n \to 0$ these crossings accumulate, by compactness, at a genuine fixed point $h(x) = x$. This is the standard route from the discrete lemma to Brouwer's theorem on the interval.

---

## 6. From fixed points to Nash equilibria

### 6.1 The reduction

A finite game specifies, for each of finitely many players, a finite set of pure strategies and a real-valued payoff depending on the whole profile of choices. A **mixed strategy** for a player is a probability distribution over their pure strategies; a **mixed-strategy profile** assigns one to each player. A profile is a **Nash equilibrium** if no player can strictly increase their expected payoff by changing only their own mixed strategy.

Nash's theorem states that every finite game has at least one such equilibrium. The classical proof constructs a continuous self-map (or set-valued best-response correspondence) on the compact convex product of the players' probability simplices, whose fixed points are exactly the Nash equilibria; existence of a fixed point follows from Brouwer's theorem (or Kakutani's set-valued generalization). Since Brouwer's theorem is the continuous limit of the discrete fixed point of Theorem 5.3, and that discrete fixed point is a corollary of the signed count (Theorem 3.1), the chain
$$ \text{Theorem 3.1} \Rightarrow \text{Theorem 5.3} \Rightarrow \text{Brouwer} \Rightarrow \text{Kakutani} \Rightarrow \text{Nash} $$
exhibits the existence of equilibria as ultimately resting on a telescoping identity.

### 6.2 A constant-sum criterion for uniform equilibria

We give a self-contained criterion producing explicit equilibria without invoking the full fixed-point machinery. Consider a two-player game where player 1 chooses a row $i \in I$ and player 2 a column $j \in J$, with $I, J$ finite and nonempty. Let $A_{ij}$ be player 1's payoff and $B_{ij}$ player 2's payoff. The *uniform profile* has each player randomizing uniformly over their strategy set.

**Theorem 6.1 (Uniform equilibrium under constant sums).** Suppose there are constants $S_1, S_2$ such that
$$ \sum_{j \in J} A_{ij} = S_1 \text{ for every } i \in I, \qquad \sum_{i \in I} B_{ij} = S_2 \text{ for every } j \in J. $$
Then the uniform profile is a Nash equilibrium, and the players' expected payoffs are
$$ E_1 = \frac{S_1}{|J|}, \qquad E_2 = \frac{S_2}{|I|}. $$

*Proof sketch.* If player 2 plays uniformly, then player 1's expected payoff from any pure row $i$ is $\frac{1}{|J|}\sum_{j} A_{ij} = S_1/|J|$, independent of $i$. Hence player 1 is indifferent among all rows, and no deviation (pure or mixed) can beat the uniform strategy's payoff of $S_1/|J|$; the uniform strategy is a best response. The symmetric argument applies to player 2 with value $S_2/|I|$. Both best-response conditions holding simultaneously is exactly the equilibrium condition. $\qquad\blacksquare$

### 6.3 A cyclic family of examples

Fix $n \ge 1$ and identify the strategy set of each player with $\mathbb{Z}/n\mathbb{Z}$. Define a *cyclic game* by a payoff pattern that depends only on the difference of the two players' choices modulo $n$: player 1's payoff is $a(j - i \bmod n)$ and player 2's payoff is $b(i - j \bmod n)$ for fixed functions $a, b : \mathbb{Z}/n\mathbb{Z} \to \mathbb{R}$. Because summing over a full residue system covers each difference exactly once,
$$ \sum_{j} a(j - i) = \sum_{d \in \mathbb{Z}/n\mathbb{Z}} a(d) =: S_1, \qquad \sum_{i} b(i - j) = \sum_{d} b(d) =: S_2 $$
are independent of $i$ and $j$. Theorem 6.1 applies immediately.

**Corollary 6.2.** For every cyclic game, the uniform strategy (each move played with probability $1/n$) is a Nash equilibrium, with values $S_1/n$ and $S_2/n$.

Two familiar games are special cases:

- **Matching Pennies** ($n = 2$): with the win/lose pattern $a = (\,-1, +1\,)$-type and its zero-sum complement for $b$, the uniform equilibrium is each player choosing heads or tails with probability $1/2$.
- **Rock–Paper–Scissors** ($n = 3$): with the cyclic dominance pattern (each move beats the next and loses to the previous), the uniform equilibrium is each move with probability $1/3$.

Both are recovered as instances of Corollary 6.2, and the family provides an infinite supply of symmetric games with explicit equilibria.

---

## 7. Algorithms

The signed-count framework is directly computational. We record the core procedures.

**Algorithm A (Signed count).** Given a coloring $c$ and length $n$, iterate $i$ from $0$ to $n-1$, incrementing an up-counter on each $0\to1$ transition and a down-counter on each $1\to0$ transition; return the pair $(U, D)$. Cost: $O(n)$ time, $O(1)$ additional space. By Theorem 3.1 the returned value satisfies $U - D = \llbracket c(n) \rrbracket - \llbracket c(0)\rrbracket$, providing an $O(1)$ consistency check.

**Algorithm B (Discrete root finding).** Given $f : \{0,\dots,n\} \to \mathbb{Z}$ with $f(0) \le 0 < f(n)$, scan for the first index where the sign of $f$ turns positive; Theorem 5.1 guarantees such an index exists. A bisection variant runs in $O(\log n)$ evaluations when $f$ is monotone.

**Algorithm C (Uniform-equilibrium verification).** Given payoff matrices $A, B$, check that all row sums of $A$ are equal and all column sums of $B$ are equal; if so, report the uniform profile as an equilibrium with values $S_1/|J|$ and $S_2/|I|$ per Theorem 6.1. Cost: $O(|I|\,|J|)$.

---

## 8. Applications and Discussion

The exact signed identity clarifies what the one-dimensional Sperner lemma "really counts". By separating the two orientations of a crossing, it exposes the degree structure hidden inside the parity statement. This has three payoffs. First, *uniformity*: parity, balance, oriented and unoriented existence, and the discrete intermediate value theorems all become one-line corollaries of a single identity, rather than separate ad hoc arguments. Second, *strength*: the oriented existence statement is genuinely stronger than the classical parity assertion, pinpointing a crossing of a specified direction. Third, *computability*: the identity furnishes a free correctness check for any algorithm that counts sign changes.

Conceptually, the result situates the one-dimensional Sperner lemma as the base case of degree theory. The telescoping sum is the discrete boundary operator; the endpoint difference is the boundary evaluation; and the equality between them is Stokes' theorem in its most elementary incarnation.

---

## 9. Future Directions

1. **Two-dimensional Sperner lemma.** Extend the signed count to an oriented count of fully labeled triangles in a triangulated $2$-simplex, via the "door"/edge-counting argument. The one-dimensional telescoping identity is the base-case degree; the two-dimensional case is a boundary-degree argument over the edges of the triangulation.

2. **Brouwer in higher dimension.** Package the discrete Brouwer statement as a limit theorem: a continuous self-map of $[0,1]$ has a fixed point, via the discrete intermediate value theorem on a fine grid together with compactness. This route generalizes to higher-dimensional simplices through the two-dimensional lemma above.

3. **General $2 \times 2$ Nash existence.** Beyond the constant-sum criterion, prove that *every* $2 \times 2$ game has a mixed equilibrium: either a pure equilibrium exists, or the indifference probabilities lie in $[0,1]$; the downward discrete intermediate value theorem can locate the best-response crossing.

4. **Best-response correspondence.** Formalize the best-response map and derive Nash existence for finite games from a Kakutani fixed-point theorem, whose combinatorial core is the higher-dimensional Sperner lemma of step 1.

5. **Symmetric games.** Show that every finite symmetric two-player game has a symmetric equilibrium; the cyclic family provides a rich supply of test cases.

---

## 10. Conclusion

We have upgraded the one-dimensional Sperner lemma from a parity statement to an exact signed identity—a discrete degree—and shown that the entire classical package, up to a discrete Brouwer fixed point, follows from this one telescoping equation. Together with a constant-sum criterion for uniform equilibria and a cyclic family of examples, the development traces a clean line from an elementary combinatorial count to the existence of equilibria in finite games.
