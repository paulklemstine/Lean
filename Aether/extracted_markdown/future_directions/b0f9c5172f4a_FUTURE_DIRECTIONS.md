# Future Directions: Bayesian Werewolf and Social Deduction Theory

## Synthesis

This research cycle established the mathematical foundations of social deduction games through 18 formally verified theorems in Lean 4. The key discovery is the *vicious cycle effect*: a pair of monotonicity theorems (werewolf_fraction_increases, werewolf_fraction_decreases) that rigorously explain why the game structurally favors werewolves. Combined with the Shannon entropy framework connecting game strategy to information theory, this creates a cross-domain bridge between combinatorial game theory and information-theoretic security analysis.

The most promising connection emerged between the Markov chain absorption model for villager win probability and the Bayesian posterior framework. These two perspectives — the probabilistic (Markov chain) and the information-theoretic (entropy) — provide complementary lenses on the same phenomenon. The Markov chain tells us *what happens* under random play; the entropy framework tells us *how much information* optimal play needs to extract. Bridging these formally could yield tight bounds on the advantage of Bayesian play over random play, connecting to the Catalog's existing work on PAC-Bayes bounds (`Speculative/AutoResearch/MachineLearning/PACBayes/KLProperties.lean`) and information-efficient algorithms (`Computation/InfoEfficientAlgorithms.lean`).

The highest breakthrough potential lies in Direction 1: proving the villager win probability conjecture for general n, k. This would establish the first general closed-form bound for social deduction games, with immediate applications to mechanism design and adversarial inference. The computational evidence is strong (verified up to n=20), and the proof strategy via inductive Markov chain analysis is concrete.

---

### Direction 1: Closed-Form Villager Win Probability Bound

**Conjecture**: For k werewolves among n total players with k < n/2, the villager win probability under random elimination satisfies villagerWinProb(k, n−k) ≤ 1 − k/(n−k). More ambitiously, the exact asymptotics satisfy villagerWinProb(k, n−k) ~ C · ∏_{i=0}^{k-1} 1/(n−2i−1) for some constant C.

**Test**: Compute villagerWinProb exactly for n up to 100 using the verified recursion. Fit the asymptotic formula to the computed values. If the relative error exceeds 5% for any tested case, the asymptotic conjecture is refuted.

**Impact**: A closed-form bound would be the first general result on social deduction game outcomes, enabling fair game design (choosing n, k to balance win rates) and providing baseline complexity for adversarial detection problems. If the bound is tight, it characterizes the exact information gap between informed adversaries and uninformed majority.

**Catalog References**: `Speculative/BayesianWerewolf/Core.lean` (villagerWinProb definition, one_wolf_win_prob_recurrence), `Computation/InfoEfficientAlgorithms.lean` (information-theoretic bounds on algorithm performance)

**Proof Strategy**: (1) Prove the k=1 case by solving the recurrence P(1,v) = 1/(1+v)·1 + v/(1+v)·P(1,v-2) explicitly, obtaining P(1,v) = 1/v for even v and a similar formula for odd v. (2) Use strong induction on k, with the inductive step applying the recursion and the k−1 bound. (3) The key lemma is that the "incorrect" branch P(k, v-2) is bounded by the "correct" branch P(k-1, v-1) times a factor < 1.

**Domain Bridges**: GameTheory <-> Probability, Combinatorics <-> InformationTheory

**Lineage**: Builds on villagerWinProb, one_wolf_win_prob_recurrence from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Bayesian Advantage Quantification

**Conjecture**: The Bayesian MAP strategy (always eliminate the player with highest posterior) achieves a villager win probability at least 2× higher than random elimination for all valid game configurations with n ≥ 7. Precisely, if P_random(k, n−k) denotes the win probability under random elimination and P_bayes(k, n−k) denotes the win probability under Bayesian MAP, then P_bayes(k, n−k) ≥ 2 · P_random(k, n−k).

**Test**: Run Monte Carlo simulations (10^6 games each) comparing random vs. Bayesian strategies for n ∈ {7, 9, 11, 13, 15}, k ∈ {1, ..., ⌊n/2⌋−1}. If any configuration shows P_bayes < 2 · P_random, the conjecture is refuted.

**Impact**: Quantifying the Bayesian advantage would establish the value of rational inference in adversarial settings. The 2× factor would imply that information processing is more valuable than luck in social deduction, with implications for AI-assisted security systems.

**Catalog References**: `Speculative/BayesianWerewolf/Core.lean` (BayesianBelief, uniformPrior, expectedWolves), `Speculative/AutoResearch/MachineLearning/PACBayes/KLProperties.lean` (risk_bound_from_kl_bernoulli)

**Proof Strategy**: (1) Formalize the Bayesian MAP strategy as a deterministic function from belief states to elimination targets. (2) Show that MAP always selects a target with werewolf probability ≥ k/n (the uniform prior), so the correct elimination probability is at least as good as random. (3) Show that after any evidence, the MAP target has strictly higher probability than k/n, giving strict improvement. (4) Aggregate over rounds using the Markov chain framework.

**Domain Bridges**: GameTheory <-> MachineLearning, Probability <-> DecisionTheory

**Lineage**: Builds on BayesianBelief, uniformPrior, random_elim_prob_strict from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Entropy Rate of Social Deduction Games

**Conjecture**: The rate of entropy decrease per round in a Werewolf game under optimal (Bayesian MAP) play is at least ln(2) / k nats per round. That is, if H_t denotes the belief entropy at round t, then E[H_t − H_{t+1}] ≥ ln(2)/k for all rounds where the game is active.

**Test**: Simulate games under Bayesian play, recording entropy at each round. Compute the average entropy decrease per round and compare to ln(2)/k. If the average falls below the bound for any configuration, the conjecture is refuted.

**Impact**: An entropy rate bound would connect social deduction to Shannon's channel coding theorem, establishing a "channel capacity" for information extraction in adversarial games. This would bridge game theory to information theory at a fundamental level.

**Catalog References**: `Speculative/BayesianWerewolf/Core.lean` (beliefEntropy, binaryEntropy_le_log2, beliefEntropy_bounded), `EML/EMLv17Core.lean` (information-theoretic constructions)

**Proof Strategy**: (1) Formalize the conditional entropy H(role | evidence_t) at each round. (2) Show that each elimination reveals at least 1 bit of role information on average. (3) Use the chain rule for mutual information: I(roles; evidence_t) = H(roles) − H(roles | evidence_t). (4) The lower bound follows from the data processing inequality.

**Domain Bridges**: GameTheory <-> InformationTheory, Probability <-> Coding

**Lineage**: Builds on beliefEntropy_bounded, binaryEntropy_le_log2 from this cycle.

**Ambition**: extension

---

### Direction 4: Werewolf Game as Tropical Semiring Optimization

**Conjecture**: The optimal elimination strategy in Werewolf can be reformulated as a shortest-path problem in a tropical semiring over the game tree. Specifically, define a tropical weight on each edge of the game tree as −log(P(correct elimination)). Then the optimal strategy corresponds to the tropical shortest path from root to a villager-win leaf.

**Test**: Construct the game tree for n=7, k=2 and compute the tropical shortest path. Verify that it matches the Bayesian MAP strategy. If they differ, the correspondence is inexact (but may hold asymptotically).

**Impact**: A tropical formulation would connect social deduction to the Catalog's extensive tropical geometry work, potentially yielding algebraic tools for game analysis. The tropical semiring structure (min-plus algebra) is natural for optimization over game trees.

**Catalog References**: `Speculative/TropicalDyson/HexBoundary.lean` (hexEdgeBoundary_formula), `Catalog/Tropical/` (tropical algebraic geometry)

**Proof Strategy**: (1) Define the tropical game tree as a directed acyclic graph with min-plus weights. (2) Show that the Bellman equation for shortest paths in this graph coincides with the Markov chain recursion. (3) The tropical structure arises because log converts products (probabilities) to sums (weights).

**Domain Bridges**: GameTheory <-> TropicalGeometry, Probability <-> Algebra

**Lineage**: Builds on villagerWinProb Markov chain model from this cycle.

**Ambition**: extension

---

### Direction 5: Coalition-Resistant Bayesian Strategies

**Conjecture**: In a variant of Werewolf where werewolves can coordinate their day votes (forming a coalition), the optimal villager strategy requires a coalition-proof Bayesian update that discounts correlated votes. Specifically, if m players all vote for the same target, the Bayesian update should weight this as m^α evidence for some α < 1 (sublinear in coalition size) rather than m independent pieces of evidence.

**Test**: Simulate games with coordinated wolf voting and compare: (a) naive Bayesian update (treats each vote independently), (b) coalition-aware update (sublinear weighting). If the coalition-aware strategy outperforms naive by >10% for k ≥ 3, the conjecture about coalition resistance is confirmed.

**Impact**: Coalition-resistant inference is a fundamental problem in mechanism design and distributed security. Formalizing it in the Werewolf framework provides a clean test case for more general coalition-proof mechanisms (e.g., Sybil-resistant voting).

**Catalog References**: `Speculative/BayesianWerewolf/Core.lean` (BayesianBelief framework), `Logic/` (logical foundations for coalition reasoning)

**Proof Strategy**: (1) Define a coalition model where k wolves coordinate votes. (2) Show that independent Bayesian updates overweight correlated evidence. (3) Derive the optimal sublinear weighting using the theory of exchangeable sequences. (4) Prove that the coalition-aware update dominates the naive update in expectation.

**Domain Bridges**: GameTheory <-> MechanismDesign, Probability <-> Logic

**Lineage**: Builds on BayesianBelief, werewolf_fraction_increases from this cycle.

**Ambition**: extension
