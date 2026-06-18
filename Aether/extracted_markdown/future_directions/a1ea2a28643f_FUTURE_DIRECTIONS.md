# Future Research Directions

## Synthesis

This research cycle established a rigorous foundation for analyzing social deduction games through the lens of recursive probability theory. The key discovery — the **parity paradox** — reveals that the win probability function `randomWinProb(v, w)` is *not* monotone in the number of villagers, contradicting naive intuition. However, a deeper structure appears to govern the function: the **Skip-Two Monotonicity Conjecture** suggests that adding *two* villagers always helps, and we showed this conjecture reduces to a "diagonal" inequality `P(v+1, w-1) ≥ P(v, w)`.

The most promising cross-domain connection is between the random elimination game and **urn models** from probability theory. The game dynamics — drawing from a mixed population with asymmetric replenishment — closely mirror Pólya-type urn processes with removal. If this connection can be made precise, it would import powerful asymptotic tools (embedding theorems, martingale convergence) into the social deduction setting. Additionally, the `SocialDeductionGame` structure connects naturally to the Catalog's information-theoretic framework in `Computation/InfoEfficientAlgorithms.lean`, since optimal play in social deduction is fundamentally an information-efficient search problem.

The highest breakthrough potential lies in Direction 1 (proving the diagonal inequality), as it would close the skip-two conjecture and reveal the complete monotonicity structure of the game. Direction 3 (connection to urn models) has the highest potential for unexpected cross-domain results.

---

### Direction 1: Diagonal Monotonicity in Asymmetric Elimination Games

**Conjecture**: For all natural numbers v ≥ w + 2 with w ≥ 1, the random elimination win probability satisfies `randomWinProb(v+1, w-1) ≥ randomWinProb(v, w)`. That is, trading one werewolf for one additional villager always (weakly) improves the villagers' odds.

**Test**: Compute `randomWinProb(v+1, w-1) - randomWinProb(v, w)` for all `v ∈ [3..100]`, `w ∈ [1..50]` and verify non-negativity. A single negative value disproves the conjecture. Additionally, prove the conjecture in Lean 4 by strong induction on `v + w`, using the coupled recursions for `P(v, w)` and `P(v+1, w-1)`.

**Impact**: If true, this immediately implies the Skip-Two Monotonicity Conjecture (`P(v, w) ≤ P(v+2, w)`) via the algebraic reduction established in this cycle: `P(v+2, w) - P(v, w) = (w/(v+w+1)) · [P(v+1, w-1) - P(v, w)]`. More broadly, it establishes a total order on the "advantage landscape" of the game, showing that the villager-to-werewolf ratio is the controlling parameter, not individual counts.

**Catalog References**: `MachineLearning/BayesianWerewolf/GameTheory.lean` (randomWinProb, randomWinProb_pos_iff, randomWinProb_skip_two_mono_conjecture)

**Proof Strategy**: Write the recursion for both `P(v, w)` and `P(v+1, w-1)`, expand, and attempt to show the difference is non-negative by expressing it as a sum of non-negative terms. The key challenge is that the recursion couples (v, w) with (v-1, w-1) and (v-2, w), creating a two-dimensional dependency. One approach: define `D(v, w) = P(v+1, w-1) - P(v, w)` and derive a recursion for D, then show D ≥ 0 by induction. The recursion for D involves D evaluated at smaller arguments plus correction terms from the changing coefficients.

**Domain Bridges**: Social deduction game theory <-> Urn model asymptotics <-> Martingale theory

**Lineage**: Builds on this cycle's randomWinProb_pos_iff, parity_paradox, and the algebraic reduction of skip-two to diagonal monotonicity.

**Ambition**: grand_challenge

---

### Direction 2: Generalized Night-Day Dynamics

**Conjecture**: For a `SocialDeductionGame` with `nightKills = m` (werewolves eliminate `m` villagers per night) and `dayElims = d` (villagers eliminate `d` players per day), the game viability threshold becomes `v ≥ w + m + 1`, and a parity paradox occurs when `gcd(m + d, 2) = 2` (i.e., when `m + d` is even).

**Test**: Implement `generalizedWinProb(v, w, m, d)` with the generalized recursion. After night: `(v - m, w)`. Day: `d` random eliminations from `v - m + w` players (multinomial draws). Compute for `m ∈ {1,2,3}`, `d ∈ {1,2,3}`, and `v, w ∈ [1..30]`. Verify the conjectured threshold and test for parity effects.

**Impact**: Extends the theory to real-world variants (e.g., "double kill" werewolf variants, games with multiple elimination rounds per day). The parity conjecture would explain why certain game variants feel "unfair" — it's a structural property of the night-day asymmetry, not a tuning issue.

**Catalog References**: `MachineLearning/BayesianWerewolf/GameTheory.lean` (SocialDeductionGame), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: Generalize `randomWinProb` to accept `nightKills` and `dayElims` parameters. The viability threshold proof should generalize from the current argument: after `m` night kills, we need `w < v - m`, i.e., `v > w + m`, hence `v ≥ w + m + 1`. The parity conjecture requires analyzing the recursion modulo 2 to understand which parities interact constructively vs. destructively.

**Domain Bridges**: Social deduction game theory <-> Combinatorial game theory <-> Sequential hypothesis testing

**Lineage**: Direct extension of this cycle's SocialDeductionGame definition and randomWinProb analysis.

**Ambition**: extension

---

### Direction 3: Urn Model Correspondence and Asymptotic Win Probability

**Conjecture**: The random elimination win probability `randomWinProb(v, w)` equals the probability that all `w` red balls are drawn before the urn reaches a configuration with ≥ 50% red balls, in a modified Pólya urn that starts with `v-1` blue and `w` red balls and removes one ball per step (drawn uniformly), but where one extra blue ball is removed deterministically before each draw.

**Test**: Implement both the game simulation and the urn simulation for `v ∈ [3..50]`, `w ∈ [1..10]`. Verify that the probabilities agree to within Monte Carlo error (< 0.001 for 10^6 trials each). If they agree, prove the equivalence formally.

**Impact**: If established, this correspondence would import the rich theory of urn models into social deduction analysis. In particular, asymptotic results for urn processes would yield scaling laws for `randomWinProb(αn, βn)` as `n → ∞`, connecting to large-population game theory.

**Catalog References**: `MachineLearning/BayesianWerewolf/GameTheory.lean` (randomWinProb)

**Proof Strategy**: Define the urn process formally as a Markov chain on `ℕ × ℕ` states. Show that the transition probabilities match the randomWinProb recursion exactly. The "deterministic removal of one blue ball" in the urn corresponds to the night phase. The key is getting the stopping conditions to align: the game stops when w ≥ v (after night), while the urn stops when red ≥ total/2 (before draw). These need to be shown equivalent under the state mapping.

**Domain Bridges**: Social deduction games <-> Urn models <-> Martingale convergence <-> Random walks

**Lineage**: Builds on this cycle's exact recursion and probability bounds.

**Ambition**: grand_challenge

---

### Direction 4: Information Value Quantification

**Conjecture**: The **information multiplier** `IM(v, w) = P_Bayesian(v, w) / randomWinProb(v, w)` (ratio of optimal Bayesian win probability to random elimination win probability) is maximized when `w ≈ v/3`, and satisfies `IM(v, w) ≤ v` for all configurations.

**Test**: Compute `P_Bayesian(v, w)` by backwards induction on the complete game tree for small games (`v + w ≤ 12`). For each configuration, compute the information multiplier and check whether it is bounded by `v` and maximized near `w = v/3`.

**Impact**: Quantifies the **value of information** in adversarial group settings. The bound `IM ≤ v` would mean that perfect Bayesian reasoning can at most multiply the baseline win probability by the number of remaining villagers — a linear bound on the power of information. The maximum at `w ≈ v/3` would identify the "sweet spot" where information matters most: games that are neither too easy (few werewolves) nor too hard (many werewolves).

**Catalog References**: `MachineLearning/BayesianWerewolf/GameTheory.lean` (randomWinProb, EliminationStrategy)

**Proof Strategy**: First compute P_Bayesian exactly for small games using minimax/expectimax on the game tree (this is a finite computation, feasible for v+w ≤ 12). Then examine the ratio numerically to identify patterns. For the upper bound, consider that the Bayesian strategy can at most achieve hit probability 1 (certainty) on each day vote, compared to the random strategy's w/(v+w-1). The ratio of these is bounded, giving a bound on the multiplier.

**Domain Bridges**: Social deduction <-> Information theory <-> Sequential statistical decision theory

**Lineage**: Extends this cycle's randomWinProb computations into the information-theoretic domain.

**Ambition**: extension

---

### Direction 5: Tropical Semiring Structure of Elimination Games

**Conjecture**: The game value function `randomWinProb` satisfies a tropical (min-plus) analogue: define `tropicalWinDepth(v, w) = min number of "lucky catches" needed for villagers to win` (the minimum number of werewolf eliminations on the day vote, across all possible game paths). Then `tropicalWinDepth(v, w) = w` when `v ≥ w + 2`, and the probability satisfies `randomWinProb(v, w) ≥ (w/(v+w-1))^w` — a lower bound given by the "all-lucky" path where every day vote catches a werewolf.

**Test**: Compute `(w/(v+w-1))^w` and compare to `randomWinProb(v, w)` for `v ∈ [3..50]`, `w ∈ [1..10]`. Verify the lower bound holds. Also verify that `tropicalWinDepth(v, w) = w` by checking that the minimum-catch path exists.

**Impact**: Connects the probabilistic game theory to tropical geometry, a rapidly developing area of mathematics. If the tropical structure is real, it would provide a principled way to approximate win probabilities (using the tropical lower bound) and might connect to the Catalog's tropical semiring work.

**Catalog References**: `MachineLearning/BayesianWerewolf/GameTheory.lean` (randomWinProb), `Tropical/` (tropical semiring infrastructure)

**Proof Strategy**: The "all-lucky" path has probability `∏_{i=0}^{w-1} (w-i)/(v+w-1-2i)` (at each step, catch a werewolf from a shrinking pool). Show this equals or is bounded below by `(w/(v+w-1))^w`. The tropical depth equals `w` because villagers need exactly `w` successful werewolf catches to win. Prove by induction on w.

**Domain Bridges**: Social deduction game theory <-> Tropical geometry <-> Combinatorial optimization

**Lineage**: Novel cross-domain connection suggested by the recursive structure of randomWinProb.

**Ambition**: extension
