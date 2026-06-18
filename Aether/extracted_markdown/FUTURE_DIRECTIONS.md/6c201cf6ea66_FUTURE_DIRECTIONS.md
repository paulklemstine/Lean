# Future Research Directions: Strategic Elimination Algebra

## Synthesis

This research cycle introduced the **Strategic Elimination Algebra (SEA)**, a parameterized framework for social deduction games that abstracts the game Werewolf/Mafia into a family of Markov chains indexed by a strategy function σ : ℕ² → [0,1]. The central achievement is the **Strategy Dominance Theorem**, which establishes that the win probability functional is monotone in strategy accuracy — a natural-sounding result whose proof required the non-trivial **Correct Elimination Dominance** lemma showing that correct elimination always leads to a state at least as good as incorrect elimination.

The framework connects naturally to several areas of the existing Catalog. The Markov chain structure parallels the PRG security analysis in `Tropical/PRGSecurity.lean`, where distinguishing advantages are bounded via similar monotonicity arguments. The information-theoretic aspects connect to the entropy-based analysis in `EML/EMLv17Core.lean`. Most directly, the work builds on and extends `Catalog/MachineLearning/BayesianWerewolf/Core.lean`, which established the basic game state model and Bayesian belief framework.

The highest-potential direction is the **Concavity Conjecture** (Direction 1), which, if true, would establish that the win probability is a concave function of strategy accuracy — implying that diversification between strategies is always suboptimal and commitment to the best available strategy is uniquely optimal. This would have implications for adversarial detection systems beyond games. The **Asymptotic Scaling** direction (Direction 2) connects to classical probability theory and could yield universal scaling laws for social deduction games.

---

### Direction 1: Concavity of Win Probability in Strategy Accuracy

**Conjecture**: For any game state (w, v) with 0 < w < v and v ≥ 2, the function f(p) = P_p(w, v) (win probability under constant strategy σ ≡ p) is concave on [0, 1]. That is, for all p, q ∈ [0,1] and t ∈ [0,1]:

f(t·p + (1-t)·q) ≥ t·f(p) + (1-t)·f(q)

**Test**: Compute P_p(w, v) for (w, v) ∈ {(1,3), (1,5), (2,5), (2,7), (3,7), (3,10)} and p ∈ {0, 0.01, 0.02, ..., 1.00}. Check that the second finite differences Δ²f(p) = f(p+δ) - 2f(p) + f(p-δ) are non-positive for all p and δ = 0.01. A single positive second difference would disprove the conjecture.

**Impact**: If true, this establishes that commitment to the best strategy dominates hedging — the optimal play is to always use your best information, never to mix with a worse strategy. This has implications for adversarial detection: investing in the highest-accuracy detection system is strictly better than diversifying across multiple systems of varying quality. If false, the failure case would identify game states where strategic diversity beats commitment — a counterintuitive and publishable result.

**Catalog References**: `MachineLearning/BayesianWerewolf/StrategyAlgebra.lean` (strategy_dominance, hedgedStrategy), `Catalog/MachineLearning/BayesianWerewolf/Core.lean` (villagerWinProb)

**Proof Strategy**: The key approach is to show that the recursion P_p(w+1, v) = p · P_p(w, v-1) + (1-p) · P_p(w+1, v-2) preserves concavity. If g(p) = P_p(w, v-1) is concave and h(p) = P_p(w+1, v-2) is concave, then f(p) = p·g(p) + (1-p)·h(p). The second derivative is f''(p) = 2g'(p) - 2h'(p) + p·g''(p) + (1-p)·h''(p). By the Correct Elimination Dominance lemma, g(p) ≥ h(p) for all p. The challenge is controlling g'(p) - h'(p). This may require a joint induction on concavity and a monotonicity property of the derivative.

**Domain Bridges**: Game Theory ↔ Optimization (concavity implies unique optimum), Game Theory ↔ Information Theory (concavity relates to channel capacity arguments)

**Lineage**: Builds on strategy_dominance and correct_elim_dominates from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Asymptotic Scaling of Win Probability

**Conjecture**: For the random elimination strategy (σ(w,v) = w/(w+v)) with k werewolves among n players (k < n/2), the villager win probability satisfies:

P_random(k, n-k) ~ C(ρ) · n^{-α(ρ)}  as n → ∞ with k/n → ρ ∈ (0, 1/2)

where C(ρ) and α(ρ) are explicit functions of the asymptotic wolf fraction ρ. Specifically, for ρ = 1/3 (equal wolf and villager "weights" per round), we conjecture α(1/3) = 1/2, connecting to the central limit theorem.

**Test**: Compute P_random(k, n-k) for ρ = k/n ∈ {0.1, 0.2, 0.3, 0.4} and n ∈ {10, 20, 50, 100, 200, 500}. Plot log P vs log n and fit the slope to determine α(ρ). If the fit is not power-law (e.g., exponential decay), the conjecture is false.

**Impact**: If the scaling is power-law with exponent α(ρ), this connects social deduction games to random walk theory and potentially to universality classes in statistical mechanics. The exponent α would characterize the "hardness" of the detection problem as a function of adversary density. If exponential, it suggests a qualitatively different (and more pessimistic) scaling regime.

**Catalog References**: `Catalog/MachineLearning/BayesianWerewolf/Core.lean` (villagerWinProb), `Tropical/PRGSecurity.lean` (nw_advantage_from_gap_bound — similar scaling analysis for distinguishing advantages)

**Proof Strategy**: Model the random walk (w, v) → (w-1, v-1) with probability w/(w+v) and (w, v) → (w, v-2) with probability v/(w+v). In the scaling limit, this becomes a 2D diffusion process. Use the Fokker-Planck equation to derive the asymptotic absorption probability. The drift vector is (−w/(w+v), −1−v/(w+v)) and the diffusion tensor can be computed from the transition probabilities. The boundary conditions (w=0: absorb at 1, w=v: absorb at 0) define a PDE whose solution gives the scaling.

**Domain Bridges**: Game Theory ↔ Probability Theory (random walks with absorbing barriers), Game Theory ↔ Statistical Physics (universality classes)

**Lineage**: Builds on villagerWinProb recurrence from Core.lean and the random strategy analysis from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Multi-Faction Elimination Games

**Conjecture**: In a three-faction game (Villagers, Werewolves, Serial Killer) where each faction has independent objectives, the strategy dominance theorem fails: there exist strategy profiles where increasing one faction's accuracy *decreases* its win probability due to kingmaker effects.

More precisely, define a three-faction game with states (w, s, v) ∈ ℕ³ where w = werewolves, s = serial killers, v = villagers. Each day, villagers vote with accuracy σ_w (probability of finding a wolf) and σ_s (probability of finding the serial killer). The conjecture is that there exist states where increasing σ_w while fixing σ_s decreases P(villagers win).

**Test**: Compute the three-faction win probability for (w, s, v) = (2, 1, 5) with σ_w ∈ {0.1, 0.2, ..., 0.9} and σ_s = 0.3. Check if P(villagers win) is monotone in σ_w. A non-monotonicity would confirm the conjecture.

**Impact**: If true, this would demonstrate that the Strategy Dominance Theorem is specific to two-faction games and does not generalize to multi-faction settings. This has implications for multi-agent adversarial detection: targeting one threat more aggressively can sometimes make the overall situation worse.

**Catalog References**: `MachineLearning/BayesianWerewolf/StrategyAlgebra.lean` (strategy_dominance — the two-faction result), `MachineLearning/ProofSchemata/Core.lean` (global_theorem_of_strategy_triad — three-component strategy analysis)

**Proof Strategy**: Define the three-faction recurrence and compute directly. The mechanism for non-monotonicity: if villagers focus too much on werewolves (high σ_w), they neglect the serial killer, who then eliminates villagers faster. The serial killer acts as a "spoiler" that breaks the monotonicity of the two-faction analysis.

**Domain Bridges**: Game Theory ↔ Multi-Agent Systems, Game Theory ↔ Voting Theory (Arrow's impossibility theorem as a structural obstacle to universal monotonicity)

**Lineage**: Extends the two-faction framework from this cycle to the natural three-faction generalization.

**Ambition**: extension

---

### Direction 4: Information-Entropy Duality for Elimination Games

**Conjecture**: For the Bayesian belief framework defined in `Core.lean`, the optimal strategy (maximizing win probability) is equivalent to the strategy that minimizes the expected posterior entropy at each step. That is, the greedy entropy-minimization strategy is globally optimal.

More precisely, define the **entropy-greedy strategy** σ_E that, at each state, votes to eliminate the player whose removal would minimize the expected Shannon entropy of the posterior belief. The conjecture is that σ_E achieves the same win probability as the globally optimal strategy (computed by backward induction).

**Test**: Implement backward induction on the full game tree for n ≤ 9 to compute the globally optimal strategy. Compare with the entropy-greedy strategy. If their win probabilities differ for any state, the conjecture is false.

**Impact**: If true, this establishes a deep connection between information theory and game theory: in social deduction games, the optimal strategy is equivalent to maximum entropy reduction. This would connect to rate-distortion theory and the information bottleneck method. If false, the gap between greedy entropy minimization and optimal play would quantify the "cost of myopia" in adversarial detection.

**Catalog References**: `Catalog/MachineLearning/BayesianWerewolf/Core.lean` (BayesianBelief, beliefEntropy, binaryEntropy_le_log2), `EML/EMLv17Core.lean` (entropy-based analysis)

**Proof Strategy**: The key would be to show that entropy reduction is a sufficient statistic for win probability improvement — that among all possible vote outcomes, the one that reduces entropy most also increases win probability most. This may require a convexity argument on the belief simplex.

**Domain Bridges**: Information Theory ↔ Game Theory (entropy as a Lyapunov function for the game), Information Theory ↔ Decision Theory (value of information)

**Lineage**: Builds on the BayesianBelief and entropy framework from Core.lean and the strategy analysis from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Semiring Structure of Win Probabilities

**Conjecture**: The win probability recurrence P(w,v) = σ·P(w-1,v-1) + (1-σ)·P(w,v-2), when lifted to the tropical semiring (ℝ ∪ {-∞}, max, +), yields a *tropical win probability* T(w,v) = max(log σ + T(w-1,v-1), log(1-σ) + T(w,v-2)) that captures the "most likely winning path" through the game tree. The tropical solution satisfies a max-plus analogue of the Strategy Dominance Theorem.

**Test**: Compute T(w,v) for (w,v) ∈ {(1,3), (2,5), (3,7)} and σ ∈ {0.3, 0.5, 0.7}. Verify that the tropical solution correctly identifies the most likely path to victory and that T is monotone in σ.

**Impact**: This would connect social deduction games to tropical geometry and the theory of optimal paths in stochastic networks. The tropical approach could yield efficient approximation algorithms for win probability computation in large games where exact computation is intractable.

**Catalog References**: `Tropical/PRGSecurity.lean` (tropical semiring analysis, nw_advantage_from_gap_bound), `Bridges/TropicalAmplificationBridge.lean` (product_cardinality_from_tropical_bound)

**Proof Strategy**: Use the Maslov dequantization: as a temperature parameter β → ∞ in the "soft" version P_β(w,v) = (σ^β · P_β(w-1,v-1)^β + (1-σ)^β · P_β(w,v-2)^β)^{1/β}, the limit is the tropical max-plus expression. The Strategy Dominance Theorem should survive this limit because it's a monotonicity statement.

**Domain Bridges**: Game Theory ↔ Tropical Geometry (dequantization), Game Theory ↔ Optimal Control (Bellman equation in max-plus algebra)

**Lineage**: Connects this cycle's SEA framework with the Catalog's tropical mathematics in `Tropical/` and `Bridges/TropicalAmplificationBridge.lean`.

**Ambition**: extension
