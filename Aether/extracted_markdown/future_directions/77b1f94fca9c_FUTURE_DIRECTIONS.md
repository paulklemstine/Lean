# Future Research Directions

## Synthesis

This research cycle introduced the **Elimination Algebra**, a novel mathematical structure that captures the algebraic core of sequential elimination games with hidden roles. The key discovery is that all such games — Werewolf, Mafia, The Resistance, Secret Hitler — share a common graded algebraic structure with two transition operators (correct/incorrect elimination), a probability function, and a well-founded grading that guarantees termination. Within this framework, we proved that the villager win probability satisfies a clean two-term recurrence, that the critical ratio `w/(w+v)` exhibits strict monotonicity under both types of transitions, and that Bayesian play provably dominates random elimination.

The most promising cross-domain connection is between **Elimination Algebras and Markov chain absorption theory**. The win probability is precisely the absorption probability of a random walk on `ℕ × ℕ` with two types of absorbing barriers, connecting our game-theoretic results to the classical theory of Gambler's ruin, Pólya urns, and random permutations. The one-wolf recurrence `P(1,v) = 1/(v+1) + v/(v+1)·P(1,v-2)` has the structure of a continued fraction, suggesting deep connections to analytic combinatorics.

The highest breakthrough potential lies in **Direction 1** (Generating Function Analysis), where the two-term recurrence for win probabilities may admit a closed-form solution via hypergeometric functions, potentially revealing a universal scaling law for all elimination games.

---

### Direction 1: Generating Function Analysis of Elimination Recurrences

**Conjecture**: The villager win probability `P(w, v)` for fixed `w` has a generating function `F_w(x) = Σ_v P(w, v) x^v` that is a ratio of hypergeometric functions. Specifically, for `w = 1`, `F_1(x)` satisfies a second-order linear ODE with polynomial coefficients, and its coefficients can be expressed in terms of double factorials or Pochhammer symbols.

**Test**: Compute `P(1, v)` for `v = 2, ..., 100` and fit the coefficients to candidate hypergeometric sequences. Check whether the ratio `P(1, v+2)/P(1, v)` converges, and if so, to what limit. Verify the ODE by computing the first 50 terms and checking that the relation holds exactly (as rational numbers).

**Impact**: A closed-form generating function would enable asymptotic analysis of win probabilities for large games, settling the conjecture that `P(w, v) ~ C_w · v^{-α_w}` for some exponents `α_w`. This would connect elimination games to the theory of special functions and asymptotic combinatorics, potentially revealing universality classes.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (one_wolf_recurrence_simplified, villagerWinProb)

**Proof Strategy**: 
1. Define the exponential generating function `G_w(x) = Σ_v P(w,v) x^v / v!`.
2. Substitute the recurrence to derive a differential equation for `G_w`.
3. Identify the equation as a confluent hypergeometric equation.
4. Extract the coefficients using standard hypergeometric identities.
5. Formalize the closed form in Lean using Mathlib's analysis library.

**Domain Bridges**: Elimination Algebras ↔ Analytic Combinatorics, Game Theory ↔ Special Functions

**Lineage**: Builds on `one_wolf_recurrence_simplified` and the computed values `one_wolf_two_villagers`, `one_wolf_three_villagers`, `one_wolf_four_villagers` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Monotonicity Conjecture for Win Probabilities

**Conjecture**: For fixed `w ≥ 1` and `v ≥ w + 2`, the villager win probability is monotonically non-decreasing in villagers with step 2: `P(w, v) ≤ P(w, v + 2)`. That is, adding two villagers (preserving the parity structure of the game) always weakly increases the villager's chances.

**Test**: Compute `P(w, v)` for all `w ∈ {1, ..., 10}` and `v ∈ {w+1, ..., 100}`. Verify `P(w, v) ≤ P(w, v+2)` for all valid pairs. A single counterexample disproves the conjecture. Additionally, check whether strict monotonicity `P(w, v) < P(w, v+2)` holds (which would be a stronger statement).

**Impact**: If true, this establishes that "more villagers always helps" — a fundamental structural property of elimination games. The proof technique would likely reveal a coupling argument or a dominance relation on the underlying Markov chains. If false, the counterexample would reveal a surprising phase transition where additional players can actually hurt.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (villagerWinProb_nonneg, villagerWinProb_le_one, villagerWinProb)

**Proof Strategy**:
1. Attempt induction on `v` with the recurrence.
2. The main challenge: `P(w, v+2) - P(w, v)` involves terms at both `v` and `v-2`, creating a coupled system.
3. Alternative: define `D(w, v) = P(w, v+2) - P(w, v)` and derive a recurrence for `D`.
4. Show `D(w, v) ≥ 0` by induction, using the recurrence for `D`.
5. May require a coupling argument on the Markov chains: construct a joint distribution where the `(w, v+2)` chain dominates.

**Domain Bridges**: Elimination Algebras ↔ Stochastic Dominance, Markov Chains ↔ Coupling Theory

**Lineage**: Builds on `villagerWinProb_nonneg`, `villagerWinProb_le_one`, and the critical ratio monotonicity theorems from this cycle.

**Ambition**: extension

---

### Direction 3: Nash Equilibrium in Adversarial Elimination Games

**Conjecture**: In the two-player zero-sum formulation of Werewolf (villager team vs. werewolf team), there exists a unique Nash equilibrium in mixed strategies. At equilibrium, the werewolves' optimal night-kill strategy is to eliminate the villager with the highest posterior probability of being "informed" (i.e., the one most likely to correctly identify a werewolf on the next day vote). The equilibrium win probability satisfies `P_eq(w, v) = P_random(w, v) · (1 + Θ(1/v))`.

**Test**: For small games (n ≤ 8), enumerate all pure strategies for both teams and compute the minimax value using linear programming. Compare the equilibrium value to `P_random(w, v)` and fit the ratio to `1 + c/v` for some constant `c`. Check whether `c` is universal across different `w` values.

**Impact**: This would provide the first rigorous analysis of optimal adversarial play in Werewolf, moving beyond the "random elimination" baseline to a game-theoretically sound solution concept. The equilibrium structure would reveal how much the werewolves' strategic choice of victims affects the game.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (bayesian_advantage_ge_one, EliminationAlgebra.werewolfAlgebra)

**Proof Strategy**:
1. Formalize the game tree as an extensive-form game with imperfect information.
2. Use Kuhn's theorem (every finite extensive-form game has a Nash equilibrium in behavioral strategies).
3. Exploit the symmetry of the game to reduce the strategy space.
4. Derive the minimax recurrence and compare to the random elimination recurrence.
5. Analyze the gap between minimax and random values.

**Domain Bridges**: Elimination Algebras ↔ Extensive-Form Game Theory, Bayesian Inference ↔ Minimax Optimization

**Lineage**: Builds on `bayesian_advantage_ge_one` and the Elimination Algebra framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Elimination Algebras

**Conjecture**: Replacing the probability semiring `(ℝ, +, ×)` with the tropical semiring `(ℝ ∪ {∞}, min, +)` in the Elimination Algebra yields a "tropical win probability" that equals the minimum number of correct eliminations needed to guarantee a villager win. Specifically, `P_trop(w, v) = w` (the villagers need exactly `w` correct identifications). The tropical Bayesian advantage is then `w - ⌊log₂(w+v)⌋`, connecting information-theoretic lower bounds to tropical geometry.

**Test**: Compute the tropical win probability for the recurrence `P_trop(w, v) = min(P_trop(w-1, v-1), P_trop(w, v-2))` with base cases `P_trop(0, v) = 0` (win, cost 0) and `P_trop(w, v) = ∞` for `w ≥ v`. Verify that `P_trop(w, v) = w` for all `w, v` with `w < v`.

**Impact**: This connects Elimination Algebras to the growing field of tropical mathematics, providing a discrete optimization perspective on social deduction games. It would also connect to the existing Catalog work on tropical cryptography and tropical PRG security.

**Catalog References**: `Tropical/PRGSecurity.lean` (nw_advantage_from_gap_bound), `Bridges/TropicalAmplificationBridge.lean` (product_cardinality_from_tropical_bound), `MachineLearning/BayesianWerewolf/Core.lean`

**Proof Strategy**:
1. Define the tropical semiring in Lean (or use existing Mathlib definitions).
2. Instantiate the Elimination Algebra with tropical arithmetic.
3. Prove the tropical recurrence by induction on `w + v`.
4. Show `P_trop(w, v) = w` by demonstrating that the minimum path always requires exactly `w` correct choices.

**Domain Bridges**: Elimination Algebras ↔ Tropical Geometry, Game Theory ↔ Min-Plus Optimization, Social Deduction ↔ PRG Security

**Lineage**: Builds on this cycle's Elimination Algebra and the existing tropical semiring work in `Tropical/PRGSecurity.lean` and `Bridges/TropicalAmplificationBridge.lean`.

**Ambition**: extension

---

### Direction 5: Information-Theoretic Lower Bounds via Entropy Reduction

**Conjecture**: In any Elimination Algebra with `n` players and `k` hidden adversaries, the expected number of rounds to identify all adversaries is at least `k · n / (n - k) · 1/log(n)`. This bound is achieved (up to constant factors) by the Bayesian optimal strategy, making it tight. The proof would use the entropy bound `H ≤ n · log 2` together with a lower bound on the entropy reduction per round.

**Test**: For the Werewolf game with `k = 1, ..., 5` and `n = 2k+1, ..., 4k`, compute the expected number of rounds under both random and Bayesian play. Compare to the conjectured lower bound `k · n / ((n-k) · log(n))`. Check whether the ratio of actual to lower bound converges.

**Impact**: This would establish fundamental information-theoretic limits on social deduction, analogous to channel capacity theorems in communication theory. It would quantify exactly how much "harder" the game gets as the number of adversaries grows, providing a scaling law for social deduction difficulty.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (beliefEntropy_bounded, binaryEntropy_nonneg), `MachineLearning/PACBayes/Bounds.lean`

**Proof Strategy**:
1. Formalize the entropy of the joint distribution over hidden roles.
2. Prove that each round reduces entropy by at most `log(n/(n-1))` bits in the worst case.
3. Since the initial entropy is `log(C(n,k))` ≈ `k · log(n/k)`, the number of rounds is at least `k · log(n/k) / log(n/(n-1))` ≈ `k · (n-1) · log(n/k) / 1`.
4. Simplify and compare to the Bayesian strategy's actual performance.

**Domain Bridges**: Elimination Algebras ↔ Information Theory, Bayesian Inference ↔ Channel Capacity, Social Deduction ↔ PAC-Bayes Learning

**Lineage**: Builds on `beliefEntropy_bounded` and `binaryEntropy_nonneg` from this cycle, and connects to the PAC-Bayes bounds in `MachineLearning/PACBayes/Bounds.lean`.

**Ambition**: grand_challenge
