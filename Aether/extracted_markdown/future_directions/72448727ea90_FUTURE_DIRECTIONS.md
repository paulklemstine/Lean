# Future Directions: Neural Cycle Pressure for Proof Guidance

## Synthesis

The local cycle pressure framework establishes the first mathematically certified interface between proof-theoretic topology and neural proof search. The proved theorems—monotonicity, acyclicity characterization, frustration bounds, entropy domination—form a coherent foundation for extracting topological hardness signals from theorem-dependency graphs. Each future direction below builds on this foundation, extending it toward empirical validation, deeper theory, or broader applications. The common thread is that **cycles in theorem space encode search frustration**, and making this precise opens new avenues in automated reasoning, complexity theory, and machine learning.

---

## Direction 1: Cycle Pressure Predicts Tactic Backtracking Depth

**Conjecture:** For theorems in Mathlib's dependency graph, the local cycle pressure $\text{lcp}_r(v)$ at optimal radius $r^*$ is positively correlated (Spearman $\rho \geq 0.3$) with the mean backtracking depth during proof search by a baseline tactic predictor.

**Test:**
1. Extract Mathlib dependency graph (~200K nodes).
2. Compute `cyclePressureFeatureVector` for each theorem at radii 1–10.
3. Run a baseline prover (e.g., ReProver) on a benchmark set, recording backtracking depth per theorem.
4. Compute Spearman correlation between optimal-radius cycle pressure and mean backtracking depth.

**Impact:** Validates the central claim that topological complexity in the dependency graph translates to search difficulty. Would establish cycle pressure as the first *a priori* predictor of proof-search effort, enabling resource allocation before search begins.

**Catalog References:**
- `Speculative/ProofTheoreticTopology/NeuralCyclePressure.lean`: `localCycleRank`, `localCyclePressure`, `cyclePressureFeatureVector`
- `Catalog/Pythagorean/ProofTheoreticTopology/Defs.lean`: `graphCycleRank`, `semanticGraph`

**Proof Strategy:** The correlation follows heuristically from the entropy surrogate bound (`entropySurrogate_le_localCycleRank`): positive cycle rank forces minimum search entropy, which manifests as increased backtracking.

**Domain Bridges:** Reinforcement learning (revisitation priors), proof complexity (tree-like vs. dag-like proofs).

**Lineage:** Direct extension of `positive_cycleRank_implies_positive_frustration_connected`.

**Ambition:** Solid extension — validates existing theory empirically.

---

## Direction 2: Pressure-Stratified Curriculum Training Improves Convergence

**Conjecture:** Training a GNN-based tactic predictor using a curriculum ordered by increasing cycle pressure (low-pressure theorems first, high-pressure last) improves final proof success rate by ≥5% and reduces training time to convergence by ≥20%, compared to random ordering.

**Test:**
1. Compute cycle pressure for all Mathlib theorems.
2. Define curriculum: epochs 1–3 on bottom quartile, epochs 4–6 on middle half, epochs 7+ on top quartile.
3. Train augmented and baseline models.
4. Compare final accuracy and convergence speed.

**Impact:** Demonstrates that topological structure can guide not just inference but training itself. Would provide the first principled curriculum for theorem prover training based on certified mathematical features.

**Catalog References:**
- `Speculative/ProofTheoreticTopology/NeuralCyclePressure.lean`: `computeLocalCyclePressure`, `enrichedFeatureVector`

**Proof Strategy:** The monotonicity theorem (`localVertexCount_mono`) ensures that low-pressure regions are structurally simpler, making them natural starting points for curriculum learning.

**Domain Bridges:** Curriculum learning, self-paced learning, complexity-guided training.

**Lineage:** Builds on `localCycleRank_eq_zero_of_acyclic` (tree-like regions are genuinely easier).

**Ambition:** Solid extension — applies existing theory to training methodology.

---

## Direction 3: Homological Hardness Hierarchy for Formal Mathematics

**Conjecture (Grand Challenge):** There exists a hierarchy of topological hardness classes $\mathcal{H}_0 \subset \mathcal{H}_1 \subset \mathcal{H}_2 \subset \cdots$ for theorem-dependency neighborhoods, where $\mathcal{H}_k = \{v : \max_r \beta_1(B_r(v)) \leq k\}$, such that the proof success rate of any polynomial-time tactic predictor decreases monotonically across classes. Formally:

$$\Pr[\text{prove } v \mid v \in \mathcal{H}_{k+1} \setminus \mathcal{H}_k] < \Pr[\text{prove } v \mid v \in \mathcal{H}_k \setminus \mathcal{H}_{k-1}]$$

**Test:**
1. Compute maximum local cycle rank for all Mathlib theorems.
2. Partition into classes $\mathcal{H}_0, \mathcal{H}_1 \setminus \mathcal{H}_0, \ldots$
3. Run multiple provers. Check if success rate is monotonically decreasing across classes.
4. Reject if any class inversion is significant at $p \leq 0.01$.

**Impact:** Would establish cycle rank as a *complexity measure* for formal mathematics, analogous to circuit complexity for computation. This would be a paradigm-shifting result connecting proof complexity to topological data analysis.

**Catalog References:**
- `Speculative/ProofTheoreticTopology/NeuralCyclePressure.lean`: `localCycleRank`, `cycleRank_nonneg_general`
- `Catalog/Pythagorean/ProofTheoreticTopology/Theorems.lean`: `graphCycleRank_pos_of_connected_many_edges`

**Proof Strategy:** The monotonicity of cycle rank under radius expansion ensures the hierarchy is well-defined. The entropy bound suggests each level adds genuine search complexity.

**Domain Bridges:** Computational complexity, proof complexity, topological data analysis.

**Lineage:** Extends `entropySurrogate_le_localCycleRank` to a full complexity hierarchy.

**Ambition:** Grand challenge — would create a new subfield of proof complexity.

---

## Direction 4: Spin-Glass Model of Theorem Dependency Frustration

**Conjecture (Grand Challenge):** The distribution of local cycle pressures in large formal mathematical libraries follows a spin-glass-like phase transition: below a critical density threshold $\rho_c$, cycle pressure is concentrated near zero (paramagnetic phase); above $\rho_c$, it follows a power-law distribution (frustrated phase). The critical exponent matches a universality class from random graph theory.

**Test:**
1. Compute cycle pressure distributions for Mathlib, Isabelle/AFP, and Coq's Mathematical Components.
2. Fit power-law distributions above empirical $\rho_c$.
3. Compare critical exponents across libraries.
4. Reject if distributions are Gaussian or exponential rather than power-law.

**Impact:** Would establish a deep connection between the structure of formal mathematics and statistical physics, potentially enabling the use of replica methods, cavity equations, and other powerful physics tools for analyzing proof difficulty.

**Catalog References:**
- `Speculative/ProofTheoreticTopology/NeuralCyclePressure.lean`: `localFrustration`, `positive_cycleRank_implies_positive_frustration_connected`
- `Catalog/Pythagorean/ProofTheoreticTopology/CoreCollapseEntropy.lean`: entropy-collapse framework

**Proof Strategy:** Random graph models of dependency structures (Erdős–Rényi or preferential attachment) undergo phase transitions in cycle rank at specific edge density thresholds. The local cycle rank formula $E - V + C$ connects directly to the giant component transition.

**Domain Bridges:** Statistical mechanics, random graph theory, universality.

**Lineage:** Extends `cycleRank_nonneg_general` and the frustration theorems to statistical ensembles.

**Ambition:** Grand challenge — paradigm-shifting if validated.

---

## Direction 5: Pressure-Aware Exploration Reduces Redundant Revisitation

**Conjecture:** Modifying the exploration policy of a Monte Carlo tree search (MCTS)-based prover to discount actions leading toward high-cycle-pressure nodes reduces the number of redundant state revisitations by ≥30%, without decreasing proof success rate.

**Test:**
1. Implement a modified MCTS with cycle-pressure-weighted UCB scores: $\text{UCB}'(a) = \text{UCB}(a) - \lambda \cdot \text{lcp}(a)$.
2. Run on a benchmark of 1000 Mathlib theorems.
3. Count state revisitations (search nodes visited more than once) for baseline and modified versions.
4. Reject if revisitation reduction < 30% or success rate drops > 2%.

**Impact:** Directly improves proof search efficiency by using topological features to avoid frustration-inducing regions.

**Catalog References:**
- `Speculative/ProofTheoreticTopology/NeuralCyclePressure.lean`: `localCyclePressure`, `computeLocalCyclePressure_spec`

**Proof Strategy:** The entropy bound guarantees that high-pressure nodes have high branching ambiguity. By de-prioritizing these nodes, the search avoids regions where it would otherwise cycle.

**Domain Bridges:** Reinforcement learning, MCTS, exploration-exploitation tradeoff.

**Lineage:** Builds on `entropySurrogate_le_localCycleRank` and `localCyclePressure_nonneg`.

**Ambition:** Solid extension — direct application of theory to existing systems.
