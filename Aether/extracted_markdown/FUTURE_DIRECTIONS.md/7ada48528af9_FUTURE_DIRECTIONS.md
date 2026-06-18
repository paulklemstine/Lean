# Future Research Directions

## Synthesis

This cycle established a rigorous mathematical framework for the Werewolf (Mafia) social deduction game, proving 22+ theorems including the Werewolf Advantage Theorem (P(w,v) ≤ v/(w+v)), Shannon entropy bounds on belief states, and a formal bridge to Byzantine Fault Tolerance thresholds. The most surprising result is the Werewolf Advantage Theorem, which shows that random elimination can never outperform a single-round success rate — the compounding effect of multi-round play always works against the villagers.

The deepest cross-domain connection discovered is between the BFT 1/3 threshold and the Werewolf critical zone. Both arise from the same mathematical structure: adversarial minorities embedded in honest majorities making collective decisions under uncertainty. This suggests a general "adversarial deduction" framework that could unify results from distributed computing, game theory, and social choice theory.

The highest breakthrough potential lies in Direction 1 (tight bounds via generating functions), which could yield a closed-form expression for P(w,v) and connect the Werewolf recurrence to classical combinatorial identities. The entropy direction (Direction 3) bridges to a large body of existing information-theoretic machinery in Mathlib and could produce results of independent interest.

---

### Direction 1: Tight Werewolf Win Probability via Generating Functions

**Conjecture**: The villager win probability P(w, v) under random elimination satisfies

$$P(w, v) = \frac{w! \cdot (v-w)!}{(v+w)!} \cdot \prod_{i=0}^{w-1} \binom{v-1-2i}{1}$$

or equivalently, there exist polynomials Q_w(v) such that P(w, v) = Q_w(v) / ∏_{i=0}^{w} (v + w - 2i) for v > w. Preliminary evidence: P(1,v) = 1/3, 7/15, 11/21 suggest denominators are products of consecutive odd numbers.

**Test**: Compute P(w, v) for w ∈ {1, 2, 3, 4} and v ∈ {w+1, ..., 20}. Factor the numerator and denominator of each fraction. Check whether the denominators are products of arithmetic progressions. If a pattern emerges, prove it by induction using the recurrence P(w,v) = w/(w+v) · P(w-1,v-1) + v/(w+v) · P(w,v-2).

**Impact**: A closed-form expression would enable asymptotic analysis as n → ∞, connecting to random permutation theory and the theory of ballot problems. It would also give optimal bounds on information advantage.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (P definition, P_one_two, P_one_four, P_two_five, oneWolf_recurrence)

**Proof Strategy**: (1) Compute P(w,v) symbolically for w = 1, 2, 3, 4 using the recurrence. (2) Identify the pattern in numerators and denominators. (3) Formulate the conjecture precisely. (4) Prove by induction on w, with strong induction on v for the inductive step. Use the convex combination structure of the recurrence.

**Domain Bridges**: Combinatorics (generating functions) <-> Probability (Markov chains) <-> Game Theory (Werewolf)

**Lineage**: Builds on P_one_two, P_one_four, P_two_five, oneWolf_recurrence from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Adversarial Deduction Theory — Unifying BFT and Social Deduction

**Conjecture**: There exists a common algebraic framework (a "deduction algebra") that simultaneously captures:
- Byzantine Fault Tolerance threshold (1/3 faulty nodes)
- Werewolf critical zone (v ≤ 2w)
- Jury theorem threshold (majority of informed voters)
- Cryptographic threshold schemes (t-of-n secret sharing)

Specifically, conjecture that all four settings are instances of a single parametric family of "adversarial majority games" on a lattice of coalitions, where the threshold parameter α determines the transition between adversarial and honest majority.

**Test**: Define an abstract "adversarial majority game" with parameters (n, k, α) and derive the BFT, Werewolf, Condorcet, and threshold cryptography thresholds as special cases. Prove that the critical threshold α* = 1/3 (for BFT) and α* = 1/2 (for Condorcet) arise from different coalition structures within the same framework.

**Impact**: Would unify four seemingly disparate areas of mathematics and computer science. Would provide a "meta-theorem" explaining why 1/3 and 1/2 thresholds appear so frequently in adversarial settings.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (bft_threshold, critical_zone_fatal, safe_zone_survives)

**Proof Strategy**: (1) Define an abstract coalition game with adversarial fraction α. (2) Define "safety" as the property that α < threshold. (3) Show BFT embeds as a coalition game with synchronous communication. (4) Show Werewolf embeds with asynchronous elimination. (5) Prove the threshold formula as a function of the communication model.

**Domain Bridges**: Distributed Computing (BFT) <-> Game Theory (Werewolf) <-> Social Choice (Condorcet) <-> Cryptography (threshold schemes)

**Lineage**: Builds on bft_threshold and critical_zone_fatal from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Information-Theoretic Optimality of Bayesian Updates in Werewolf

**Conjecture**: The optimal villager strategy (maximizing win probability) is equivalent to the maximum entropy reduction strategy: at each round, vote to eliminate the player whose removal maximizes the expected decrease in total belief entropy.

More precisely: let S_t denote the total entropy at round t. The Bayesian strategy (vote for highest posterior probability) and the entropy-minimization strategy (vote for maximum E[S_t - S_{t+1}]) produce the same elimination ordering with probability 1, provided all players have distinct posteriors.

**Test**: For the 7-player game (n=7, k=2), enumerate all possible evidence patterns (there are finitely many). For each pattern, compute the Bayesian posterior ordering and the entropy-reduction ordering. Verify they agree.

**Impact**: Would establish a formal equivalence between two fundamental optimization principles: maximum a posteriori (MAP) estimation and minimum entropy. This has implications for active learning, experimental design, and sequential hypothesis testing.

**Catalog References**: `MachineLearning/BayesianWerewolf/Strategy.lean` (H_nonneg, H_max, totalEntropy_bounded, uniform_expected, BayesBelief)

**Proof Strategy**: (1) Define the entropy reduction from eliminating player i. (2) Show this equals the KL divergence between prior and posterior given elimination of i. (3) Use the connection between KL divergence and log-likelihood to show equivalence with posterior maximization. (4) Handle the degenerate case of equal posteriors separately.

**Domain Bridges**: Information Theory (entropy) <-> Game Theory (optimal play) <-> Machine Learning (active learning)

**Lineage**: Builds on H_max, totalEntropy_bounded, infoGap_eq from this cycle.

**Ambition**: extension

---

### Direction 4: Large-Game Asymptotics and Phase Transitions

**Conjecture**: As n → ∞ with k/n → α ∈ (0, 1/2), the villager win probability P(⌊αn⌋, n − ⌊αn⌋) converges to a limiting function f(α) that exhibits a phase transition at α* = 1/3:
- For α < 1/3: f(α) > 0 (villagers have positive win probability)
- For α = 1/3: f(α) = 0 (transition point)
- For α > 1/3: f(α) = 0 (werewolves always win)

Furthermore, near the transition: f(α) ~ C · (1/3 - α)^β for some critical exponent β > 0.

**Test**: Compute P(k, n-k) for n = 50, 100, 200, 500 with k/n ≈ 0.2, 0.25, 0.3, 0.33, 0.35. Plot log P vs log(1/3 - k/n) near the transition to estimate β.

**Impact**: Would connect the Werewolf game to the theory of phase transitions in statistical mechanics. The critical exponent β would classify the "universality class" of the Werewolf transition, potentially linking to percolation theory or random graph thresholds.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (werewolf_advantage, P definition)

**Proof Strategy**: (1) Establish monotonicity of P in both w and v (the monotonicity in v requires careful induction). (2) Show that the normalized probability P(⌊αn⌋, n − ⌊αn⌋) is monotone decreasing in α. (3) Identify the limit using Stirling's approximation on the configuration count. (4) For the critical exponent, use saddle-point approximation on the generating function (if Direction 1 succeeds).

**Domain Bridges**: Probability (random walks) <-> Statistical Mechanics (phase transitions) <-> Combinatorics (asymptotic enumeration)

**Lineage**: Builds on P_nonneg, P_le_one, werewolf_advantage from this cycle.

**Ambition**: extension

---

### Direction 5: Werewolf on Graphs — Spatial Social Deduction

**Conjecture**: When the Werewolf game is played on a graph G (players are vertices; werewolves can only kill neighbors; information propagates along edges), the villager win probability is determined by the graph's expansion properties. Specifically, if G is a d-regular expander with spectral gap λ, then:

P_graph(k, n-k) ≥ P_random(k, n-k) · (1 + c·λ/d)

for some universal constant c > 0. Expander graphs help villagers because information propagates faster.

**Test**: Simulate the game on specific graph families: complete graph K_n (= standard Werewolf), cycle C_n, hypercube Q_n, random d-regular graphs. Compare win probabilities and correlate with spectral gap.

**Impact**: Would connect social deduction to spectral graph theory, opening a new direction in combinatorial game theory. Has applications to modeling information spread in social networks.

**Catalog References**: `MachineLearning/BayesianWerewolf/Core.lean` (P definition), `Bridges/HellyPrinciple.lean` (structural parallel with Helly-type results)

**Proof Strategy**: (1) Define the graph Werewolf game formally. (2) Show that on the complete graph, it reduces to standard Werewolf. (3) Use mixing time bounds from spectral theory to quantify information propagation. (4) Prove the expansion-based lower bound by coupling with a random walk.

**Domain Bridges**: Graph Theory (expanders) <-> Game Theory (spatial games) <-> Information Theory (communication networks)

**Lineage**: New direction, building on the complete-graph baseline from this cycle.

**Ambition**: extension
