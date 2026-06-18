# Future Directions

## Synthesis

This cycle established a rigorous mathematical framework for analyzing social deduction games through the lens of sequential elimination processes. The key mathematical objects — the survival value function V(w,v), the suspicion profile, and the skilled strategy family — capture the essential strategic structure of Werewolf/Mafia games. The most surprising discovery was the parity oscillation in single-wolf survival probabilities: adding a villager can actually *decrease* the villagers' chances, depending on the parity of the total.

The strongest cross-domain connection is to **voting theory and information aggregation**: the day vote in Werewolf is equivalent to a sequential binary decision under uncertainty, connecting to the Condorcet jury theorem and mechanism design. The Suspicion Profile structure is essentially a constrained probability simplex, linking to information geometry and exponential families. The skilled strategy's smooth interpolation between random and perfect play mirrors the skill parameter in PAC-Bayes generalization bounds (see `MachineLearning/ProofSchemata/Core.lean`).

The highest breakthrough potential lies in **Direction 1**: proving the strategy monotonicity theorem would establish that information is always valuable in sequential elimination games, a result with implications for mechanism design and adversarial decision-making. This requires proving that wolf elimination is always weakly better than villager elimination, which connects to stochastic dominance theory.

---

### Direction 1: Strategy Monotonicity and the Value of Information

**Conjecture**: For any two elimination strategies σ₁, σ₂ where σ₁ has at least as high wolf-elimination probability as σ₂ at every state (p_{σ₁}(w,v) ≥ p_{σ₂}(w,v) for all w, v), the survival value satisfies V_{σ₁}(w,v) ≥ V_{σ₂}(w,v) for all (w,v).

**Test**: This requires proving a helper lemma: for any strategy σ and state (w, v) with w > 0 and v > w+1, the value after wolf elimination A_σ(w,v) ≥ B_σ(w,v) the value after villager elimination. Verify computationally for all (w,v) with w ≤ 10, v ≤ 30. Then attempt the formal proof by nested induction on fuel and game complexity.

**Impact**: If true, this establishes that information is *always* valuable in sequential elimination games — a clean Bayesian analog of Blackwell's theorem on comparison of experiments. If false, it would reveal surprising game states where more information hurts the informed player, analogous to Braess's paradox.

**Catalog References**: `Applications/BayesianWerewolf/Theorems.lean` (survivalValue_nonneg, survivalValue_le_one), `Applications/BayesianWerewolf/Defs.lean` (survivalValue, EliminationStrategy)

**Proof Strategy**: (1) Prove wolf-elimination dominance: A_σ(w,v) ≥ B_σ(w,v) by induction on w+v. This requires showing V(w-1, v-1) ≥ V(w, v-2), i.e., having fewer wolves with the same total is better. (2) Use wolf-elimination dominance plus the convex combination structure of V to prove the full monotonicity. (3) The key arithmetic: p₁·A₁ + (1-p₁)·B₁ ≥ p₂·A₂ + (1-p₂)·B₂ follows from p₁ ≥ p₂, A₁ ≥ A₂, B₁ ≥ B₂ (by IH), A₁ ≥ B₁ (wolf dominance), and all values in [0,1].

**Domain Bridges**: Applications (game theory) <-> MachineLearning (PAC-Bayes: skill parameter α mirrors PAC-Bayes temperature) <-> Algebra (lattice theory: the space of strategies ordered by pointwise probability comparison forms a lattice)

**Lineage**: Builds on survivalValue_nonneg, survivalValue_le_one, perfect_always_wins from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Closed-Form Formula for Single-Wolf Survival

**Conjecture**: For the random strategy with one wolf, the survival value satisfies:
V(1, 2m) = 1 - ∏_{j=1}^{m} (2j)/(2j+1) for even v = 2m,
and V(1, 2m+1) = ∏_{j=1}^{m} (2j-1)/(2j) for odd v = 2m+1.

Equivalently, V(1, v) involves ratios of double factorials: V(1, 2m) = (2m-1)!!/(2m)!! · correction.

**Test**: Compute V(1, v) for v = 2, 3, ..., 30 using the exact recursive formula and check against the conjectured closed form. The pattern should be exactly verifiable for these cases.

**Impact**: A closed form would connect Werewolf theory to classical combinatorics (Catalan numbers, Wallis product, beta function). It would also enable asymptotic analysis: what is lim_{v→∞} V(1, v)? The data suggests convergence to values ≈ 0.64 (even) and ≈ 0.55 (odd).

**Catalog References**: `Applications/BayesianWerewolf/Theorems.lean` (random_survival_1_2, random_survival_1_3, random_survival_1_4)

**Proof Strategy**: (1) Unwind the recursion V(1, v) = (1/(v+1)) + (v/(v+1)) · 0_or_V(1, v-2). (2) For odd v, V(1, 2m+1) = 1/(2m+2) (only the wolf-hit branch contributes, since villager-hit → (1, 2m) → night → (1, 2m-1) and check parity). (3) For even v, the recursion telescopes into a product. (4) Verify the product matches double factorial ratios.

**Domain Bridges**: Applications (game theory) <-> Algebra (double factorial identities, Wallis-type products) <-> EML (connection to exponential-logarithmic structures via generating functions)

**Lineage**: Direct extension of the exact computations in this cycle.

**Ambition**: extension

---

### Direction 3: Multi-Wolf Bayesian Inference as Information Geometry

**Conjecture**: The space of valid suspicion profiles with n players and k wolves forms a (n-1)-dimensional simplex embedded in ℝⁿ, and the Bayesian update rule defines a natural Riemannian metric (Fisher information metric) on this simplex. The uniform profile is the point of maximum entropy, and the information value functional V: SuspicionProfile → ℝ is concave with respect to the Fisher metric.

**Test**: (1) Verify computationally that for n=5, k=2, the Fisher information metric can be computed from the likelihood function. (2) Check concavity of V by sampling 1000 random suspicion profiles and comparing V at midpoints vs. averages. (3) Formalize the Fisher metric on the suspicion simplex in Lean 4.

**Impact**: This would establish a geometric foundation for social deduction games, connecting them to the rich theory of information geometry. The concavity of V would imply that "hedging" suspicions (staying close to the uniform distribution) is suboptimal — decisive beliefs always outperform cautious ones.

**Catalog References**: `Applications/BayesianWerewolf/Advanced.lean` (SuspicionProfile, uniformProfile, bayesianUpdate)

**Proof Strategy**: (1) Define the Fisher metric on the constrained simplex {s ∈ ℝⁿ : s_i ≥ 0, Σs_i = k} using the standard formula g_{ij} = E[∂_i log L · ∂_j log L]. (2) Show that Bayesian updates are geodesics in this metric (the exponential family property). (3) Prove concavity of V by showing that the Hessian of V composed with the survival value is negative semidefinite. This likely requires the wolf-elimination dominance from Direction 1.

**Domain Bridges**: Applications (Bayesian games) <-> Geometry (information geometry, Riemannian manifolds) <-> MachineLearning (PAC-Bayes: Fisher information controls generalization bounds)

**Lineage**: Builds on SuspicionProfile and bayesianUpdate from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Asymptotic Survival as n → ∞ with Fixed Wolf Fraction

**Conjecture**: Fix the wolf fraction θ = k/n ∈ (0, 1/2). As n → ∞ with k = ⌊θn⌋ wolves:
- Under random play: V_random → 0 exponentially fast, specifically V_random ~ C(θ) · exp(-n · D(θ)) where D(θ) is a rate function related to the binary KL divergence.
- Under perfect play: V_perfect = 1 for all n (trivially, since k < n-k).
- Under skilled play with fixed α > 0: V_α → 1 as n → ∞.

**Test**: Compute V_random(k, n-k) for n = 10, 20, 50, 100 with θ = 0.2 and fit the exponential decay. Estimate D(0.2) from the data. Compare with D_KL(1/2 || θ).

**Impact**: This would establish a sharp phase transition: any positive amount of skill guarantees victory in large games, but pure random play fails exponentially. This has implications for large-committee decision-making: even minimal expertise suffices if the group is large enough.

**Catalog References**: `Applications/BayesianWerewolf/Advanced.lean` (skilledStrategy, informationGap)

**Proof Strategy**: (1) For random play, observe that the probability of eliminating all k wolves before reaching parity is at most (k/n)^k times lower-order terms, which decays exponentially. (2) For skilled play with α > 0, use a martingale argument: the expected number of wolves eliminated per round is at least α + (1-α)·θ > θ, so wolves are eliminated faster than the parity threshold approaches. Apply optional stopping.

**Domain Bridges**: Applications (large deviations) <-> Algebra (exponential generating functions) <-> Cryptography (security parameter scaling — both involve exponential decay in a complexity parameter)

**Lineage**: Builds on exact computations and skilled strategy from this cycle.

**Ambition**: extension

---

### Direction 5: Adversarial Wolf Strategies and Minimax Values

**Conjecture**: The minimax value of the Werewolf game (where wolves play optimally and villagers play optimally) satisfies V_minimax(w, v) = V_random(w, v) when villagers have no information, but V_minimax(w, v) < V_perfect(w, v) when wolves can strategically manipulate information channels.

More precisely, if wolves can choose their night-kill target adversarially (rather than randomly), the survival value decreases, but the *relative* benefit of information remains the same.

**Test**: (1) Modify the survival value computation to allow adversarial night kills (wolves always kill the most-suspected villager, or the least-suspected villager). (2) Compare V_adversarial vs V_random_night for (w,v) with w ≤ 5, v ≤ 15. (3) Formalize adversarial night kills in Lean as a modified EliminationStrategy.

**Impact**: This would connect Werewolf theory to zero-sum game theory and minimax optimization. The gap between random-night and adversarial-night values measures the wolves' "strategic advantage" — how much they gain from choosing victims wisely.

**Catalog References**: `Applications/BayesianWerewolf/Defs.lean` (EliminationStrategy, survivalValue)

**Proof Strategy**: (1) Extend the game state to include a "night strategy" parameter. (2) Show that adversarial night kills never help villagers (they can only reduce V). (3) Prove that the minimax theorem applies: the game has a value in the sense of von Neumann.

**Domain Bridges**: Applications (game theory, minimax) <-> Computation (algorithmic game theory, equilibrium computation) <-> Logic (strategy quantifier alternation ∀∃ corresponds to minimax)

**Lineage**: Extends the core framework from this cycle with adversarial dynamics.

**Ambition**: extension
