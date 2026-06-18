# Future Directions: Bayesian Werewolf and Social Deduction Game Theory

## Synthesis

This research cycle established the structural theory of the random elimination win probability in Werewolf/Mafia games. The central discovery is the **Parity Paradox** — adding one villager can decrease the win probability — and its resolution through the **Z/2Z symmetry** of the game dynamics (each round removes exactly 2 players). We proved that the win probability decomposes into two strictly monotone subsequences (even and odd), with the even subsequence always dominating the odd, and that the parity defect (the quantitative measure of the paradox) decreases toward 1 for large games.

The most promising cross-domain connection is the bridge between **Werewolf game theory** and **Markov chain absorption theory**. The win probability is exactly the absorption probability of a random walk on ℕ² with a specific step structure (correct elimination: (−1, −1), wrong elimination: (−2, 0)). This connects to the classical gambler's ruin problem but with a novel "double death" step that doesn't appear in standard theory. The parity paradox is then a consequence of the bipartite structure of this random walk.

The highest breakthrough potential lies in Direction 1 (General Skip-Two Monotonicity), which would establish a deep structural result about the entire win probability function. This is likely provable using the recurrence structure and careful induction, but requires new techniques for handling the two-variable recursion. Success would connect to the theory of totally positive matrices and TP₂ functions.

---

### Direction 1: General Skip-Two Monotonicity for Arbitrary Wolf Count

**Conjecture**: For all v ≥ w + 2 and w ≥ 1, the win probability satisfies P(v, w) < P(v+2, w). That is, adding two villagers (preserving the parity class) always improves the villagers' chances, regardless of the number of werewolves.

**Test**: First verify computationally for all v ≤ 50, w ≤ 10 using exact rational arithmetic. Then attempt a formal proof by strong induction on v + w, using the recurrence P(v, w) = (w/(v+w)) · P(v−1, w−1) + (v/(v+w)) · P(v−2, w). The key challenge is that the two-variable recurrence creates cross-dependencies between parity classes of both v and w.

**Impact**: If true, this establishes a fundamental monotonicity property of the game: within each parity class, more villagers is always strictly better. This would be the strongest structural result about the win probability landscape and would imply the diagonal monotonicity conjecture as a corollary.

**Catalog References**: `Catalog/Speculative/AutoResearch/SocialDeductionGame.lean` — `skip_two_conjecture` (stated but unproven). `Applications/BayesianWerewolf/GameTheory.lean` — verified instances.

**Proof Strategy**: Induction on total players n = v + w. For the inductive step, expand P(v+2, w) − P(v, w) using the recurrence and group terms. The main obstacle is that the coefficients w/(v+w) and v/(v+w) change between P(v, w) and P(v+2, w), creating error terms that must be bounded using the inductive hypothesis. A possible approach: define the "gain function" G(v, w) = P(v+2, w) − P(v, w) and prove G satisfies its own recurrence with non-negative boundary values.

**Domain Bridges**: Social deduction game theory ↔ Markov chain absorption theory ↔ Totally positive matrix theory

**Lineage**: Extends the skip-two instances proved in this cycle and the `skip_two_conjecture` from the SocialDeductionGame catalog.

**Ambition**: grand_challenge

---

### Direction 2: Asymptotic Win Probability and Central Limit Behavior

**Conjecture**: For fixed w and v → ∞, the win probability P(v, w) converges to 1 at rate P(v, w) = 1 − Θ(v^{−w/2}). More precisely, for w = 1: P(v, 1) = 1 − c/√v + O(1/v) for some explicit constant c related to the Wallis integral.

**Test**: Compute P(v, 1) for v up to 1000 using exact rational arithmetic and fit to the form 1 − c · v^{−α}. Determine α and c numerically, then attempt to derive them from the recurrence E(m+1) = 1/(2m+3) + (2m+2)/(2m+3) · E(m). Use generating functions or the connection to central binomial coefficients to find a closed form.

**Impact**: A precise asymptotic formula would connect the Werewolf game to the theory of random walks and the central limit theorem. The exponent w/2 would reveal a universal scaling law: each additional wolf halves the decay rate, meaning multi-wolf games are dramatically harder even in the large-game limit.

**Catalog References**: `Applications/BayesianWerewolf/GameTheory.lean` — `evenWinProb_strictMono`, `oddWinProb_strictMono`.

**Proof Strategy**: For w = 1, transform the recurrence E(m+1) = 1/(2m+3) + (2m+2)/(2m+3) · E(m) into a recurrence for f(m) = 1 − E(m). This gives f(m+1) = (2m+2)/(2m+3) · f(m), so f(m) = f(1) · ∏_{j=2}^{m} (2j)/(2j+1). This product is related to (2m)!!/(2m+1)!! ∼ c/√m by the Wallis product, yielding P(v, 1) ∼ 1 − c/√v. For general w, use the multi-dimensional Markov chain structure.

**Domain Bridges**: Social deduction game theory ↔ Analytic combinatorics ↔ Central limit theorem / Wallis product

**Lineage**: Extends the monotonicity results proved in this cycle.

**Ambition**: extension

---

### Direction 3: Information-Theoretic Lower Bounds for Bayesian Werewolf

**Conjecture**: Any strategy for the villagers satisfies P(villagers win) ≤ 1 − 2^{−I(game)/k}, where I(game) is the total information (in bits) gained during the game and k is the number of werewolves. In other words, complete identification of k werewolves requires at least k · log₂(n/k) bits of information, and the win probability is bounded by the information gathered.

**Test**: Define a formal information-theoretic model where each day vote reveals some bits about wolf identities. Compute the maximum information gain per round as a function of the voting structure. Compare the theoretical bound with Monte Carlo simulations of Bayesian players.

**Impact**: This would provide the first rigorous information-theoretic bound on social deduction games, connecting the game-theoretic win probability to Shannon entropy. It would explain why Werewolf becomes harder with more wolves: the information requirement grows linearly in k, but the number of rounds available grows only logarithmically.

**Catalog References**: `Applications/BayesianWerewolf/GameTheory.lean` — `binaryEntropy_nonneg`, `binaryEntropy_symm`, `priorEntropy`. `MachineLearning/BayesianWerewolf/Core.lean` — `BayesianBelief`, `beliefEntropy`.

**Proof Strategy**: Define the mutual information I(W; V | round t) between the wolf assignment W and the votes V at round t. Show that each round reveals at most H(elimination | W) ≤ log₂(n) bits. The total information after T rounds is at most T · log₂(n). Complete identification requires reducing entropy from n · H(k/n) to 0, giving a lower bound on the required number of rounds. Then use the Markov chain structure to convert the round bound into a win probability bound.

**Domain Bridges**: Social deduction game theory ↔ Information theory ↔ Channel capacity bounds

**Lineage**: Builds on the entropy framework established in this cycle.

**Ambition**: grand_challenge

---

### Direction 4: The Parity Defect Product Formula

**Conjecture**: For w = 1, the parity defect D(2m, 1) = P(2m, 1)/P(2m+1, 1) has the closed-form expression D(2m, 1) = (2m+2)/(2m+1) · (1 − E(m-1))/(1 − O(m)), where E and O are the even and odd subsequences. This would reveal that the defect is controlled by the "remaining uncertainty" 1 − P at the previous level.

**Test**: Compute D(2m, 1) for m = 1 to 20 and verify against the conjectured formula. If the formula holds, prove it by algebraic manipulation of the recurrences for E and O.

**Impact**: A closed-form parity defect would provide a precise quantitative understanding of the paradox and potentially yield the convergence rate D(2m, 1) → 1 as m → ∞ with explicit error bounds.

**Catalog References**: `Applications/BayesianWerewolf/GameTheory.lean` — `parityDefect`, `parityDefect_2_1`, `parityDefect_4_1`, `parityDefect_6_1`.

**Proof Strategy**: From the recurrences E(m) = 1/(2m+1) + (2m)/(2m+1) · E(m-1) and O(m) = 1/(2m+2) + (2m+1)/(2m+2) · O(m-1), compute D(2m, 1) = E(m)/O(m) and simplify. The recurrence for D itself should have a clean form.

**Domain Bridges**: Social deduction game theory ↔ Continued fraction theory ↔ Special functions

**Lineage**: Extends the parity defect computations from this cycle.

**Ambition**: extension

---

### Direction 5: Multi-Wolf Cascade Structure

**Conjecture**: The win probability with w wolves is related to the 1-wolf case by P(v, w) = Θ(∏_{j=0}^{w-1} f(v−2j)) for some function f closely related to P(·, 1). The "cascade" intuition is that each wolf must be independently identified, with each identification slightly altering the remaining game's parameters.

**Test**: Compute the ratio P(v, w)/P(v, w−1) for various v and w and look for patterns. If the ratio is approximately P(v, 1) · correction_term, identify the correction term and conjecture its form.

**Impact**: A product decomposition would reduce the multi-wolf problem to the 1-wolf case, dramatically simplifying the analysis. It would also explain the empirical observation that multi-wolf games are much harder than single-wolf games.

**Catalog References**: `Applications/BayesianWerewolf/GameTheory.lean` — `winProb_3_2`, `winProb_5_2`, `winProb_7_2`, `winProb_4_3`, etc.

**Proof Strategy**: Analyze the recurrence for P(v, w) with w ≥ 2. The correct-elimination branch transitions to P(v−1, w−1), which by induction should factor as the (w−1)-fold product. The wrong-elimination branch transitions to P(v−2, w), maintaining the same number of wolves. This creates a system of coupled recurrences that may decouple in an appropriate limit.

**Domain Bridges**: Social deduction game theory ↔ Product measures ↔ Independent trials approximation

**Lineage**: New direction motivated by the cascade bound computations in this cycle.

**Ambition**: extension
