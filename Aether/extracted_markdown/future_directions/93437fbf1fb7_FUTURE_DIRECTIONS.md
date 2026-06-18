# Future Directions

## Synthesis

This research cycle introduced the **SearchDensityFunction** (SDF), a novel structure that models proof search as a density-tracking problem: how does the fraction of provable theorems within the exponentially growing proof space evolve with proof length? The key discovery is that this density is governed by precise information-theoretic laws — the entropy gap grows without bound, search difficulty has sharp exponential lower bounds, and incompressibility of most proof strings creates a fundamental barrier to efficient search.

The most promising cross-domain connection is between the SDF framework and the existing catalog's tropical proof complexity results. The tropical semiring (min, +) provides a natural algebra for combining proof costs, and the SDF's superadditivity theorem (b^m + b^n ≤ b^(m+n)) is precisely the statement that proof costs compose super-additively — a tropical-algebraic phenomenon. This suggests that tropical geometry could provide the "right" framework for studying proof search complexity, potentially connecting to the catalog's `TropicalProofComplexity` and `TropicalDragon` modules.

The highest breakthrough potential lies in Direction 1 (Tropical SearchDensityFunction), which would unify the SDF's combinatorial bounds with the algebraic structure of tropical semirings, potentially yielding new proof complexity lower bounds.

---

### Direction 1: Tropical SearchDensityFunction

**Conjecture**: The SearchDensityFunction's difficulty measure, when viewed through the tropical semiring (min, +), forms a tropical polynomial whose Newton polygon encodes the phase transition structure of proof search. Specifically, the tropical polynomial D(x) = min_k {k·log(b) + (n-k)·x} has a tropical root at x* = log(b), and this root corresponds to the critical proof density threshold.

**Test**: Formalize the tropical version of SearchDensityFunction where search costs are combined using tropical addition (min) and tropical multiplication (+). Verify that the resulting tropical polynomial's Newton polygon has vertices corresponding to the phase transition points identified in the SDF theory. Compute this for b = 2, n = 10, 100, 1000.

**Impact**: If true, this would connect proof complexity to tropical algebraic geometry in a precise way, potentially enabling tropical Bézout-type bounds on the number of "critical" proof lengths. If false, the failure would reveal that proof search costs don't compose tropically, which itself constrains future approaches.

**Catalog References**: `Physics/TropicalProofComplexity.lean`, `Algebra/TropicalDragon.lean`, `Applications/ProofSearchEntropy.lean`

**Proof Strategy**: (1) Define TropicalSDF by replacing ℕ-arithmetic in SDF with tropical (min, +) operations. (2) Show that the search difficulty function is a tropical polynomial. (3) Compute its Newton polygon. (4) Prove that vertices correspond to phase transitions. Key lemma: the tropical roots of D(x) are exactly the critical densities.

**Domain Bridges**: Tropical Geometry <-> Proof Complexity <-> Information Theory

**Lineage**: Builds on `tropical_proof_length_conjecture_special_case` and `search_difficulty_superadditive` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Entropy Rate Characterization of Proof Systems

**Conjecture**: The entropy rate r(n) of a proof system's ProofEntropyProfile satisfies r(n) = n - Θ(√n) for "natural" proof systems (those corresponding to ZFC, Peano arithmetic, etc.), while "artificial" systems can achieve r(n) = 0 (fully structured) or r(n) = n (fully random). The √n correction term arises from the random-walk structure of proof search trees.

**Test**: Compute the entropy rate empirically for Mathlib proofs: for each theorem of statement length s, measure the proof length p and compute r ≈ log_b(number of proofs of length ≤ p). Plot r(n) vs n and fit to n - C√n. The conjecture predicts C ∈ [0.5, 5].

**Impact**: If r(n) = n - Θ(√n), this would be the first quantitative characterization of "how structured" real proof systems are, connecting proof complexity to random walk theory. If r(n) is linear (r(n) = cn), it would mean proof systems have constant entropy rate, which is a different (and still informative) regime.

**Catalog References**: `Applications/ProofSearchEntropy.lean` (ProofEntropyProfile), `MachineLearning/PACBayes/Asymptotic.lean`

**Proof Strategy**: (1) Define "natural proof system" axiomatically. (2) Prove that Peano arithmetic's proof search has entropy rate n - Ω(√n) using Chernoff-type bounds on the distribution of valid proof prefixes. (3) Construct artificial systems achieving the extremes. Key: the √n term should arise from CLT-type behavior of proof tree branching.

**Domain Bridges**: Probability Theory <-> Proof Complexity <-> Random Walks

**Lineage**: Builds on `cumulative_entropy_bound` and `structure_gap_nonneg` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Compositional Proof Search with Correlated Obligations

**Conjecture**: For correlated proof obligations (where proving theorem A provides partial information about theorem B), the search cost satisfies: Cost(A ∧ B) ≤ Cost(A) · Cost(B|A), where Cost(B|A) < Cost(B) by a factor determined by the mutual information I(A;B). Specifically, Cost(A ∧ B) ≤ b^(m + n - I(A;B)) where m, n are the proof lengths and I(A;B) is measured in base-b digits.

**Test**: Construct pairs of theorems with known mutual information (e.g., a theorem and its contrapositive, which share all information) and verify that the combined search cost is reduced by the predicted factor. Also construct independent pairs and verify no reduction.

**Impact**: This would extend the SDF framework from independent to correlated proof obligations, modeling real mathematical practice where proving one theorem often provides a "stepping stone" for another. The mutual information term would quantify this stepping-stone effect.

**Catalog References**: `Applications/ProofSearchEntropy.lean` (search_difficulty_superadditive), `Bridges/ProofSearchComplexity.lean`

**Proof Strategy**: (1) Define conditional search difficulty SD(B|A). (2) Define mutual proof information I(A;B) as SD(B) - SD(B|A). (3) Prove chain rule: SD(A∧B) = SD(A) + SD(B|A). (4) Prove I(A;B) ≤ min(SD(A), SD(B)). Key insight: use the SDF framework with a "conditional" provableWithin function.

**Domain Bridges**: Information Theory <-> Proof Complexity <-> Logic

**Lineage**: Builds on `search_difficulty_superadditive` and `information_search_duality_general`.

**Ambition**: extension

---

### Direction 4: Proof Search Speedup from Structural Priors

**Conjecture**: A proof search algorithm with access to a "structural prior" (a probability distribution over proof strategies) can achieve search cost b^(r(n)) instead of b^n, where r(n) is the entropy rate of the proof system's ProofEntropyProfile. This speedup is optimal: no algorithm can do better than b^(r(n)) in the worst case.

**Test**: Implement a proof search algorithm that uses a learned structural prior (from training on existing proofs) and measure its search cost on held-out theorems. Compare to brute-force search and verify that the speedup factor matches b^(n - r(n)) within a constant factor.

**Impact**: This would provide the first information-theoretic optimality guarantee for AI-guided proof search, showing that the entropy rate is the fundamental barrier. It would connect the SDF framework to machine learning and provide a theoretical foundation for neural theorem provers.

**Catalog References**: `Applications/ProofSearchEntropy.lean`, `MachineLearning/PACBayes/Asymptotic.lean`

**Proof Strategy**: (1) Formalize "structural prior" as a probability distribution over Fin(b^n). (2) Prove that optimal search under a prior with entropy H has expected cost 2^H. (3) Show that the proof system's entropy rate equals the minimum entropy over all priors consistent with the proof system's structure. Uses Shannon's source coding theorem in reverse.

**Domain Bridges**: Machine Learning <-> Information Theory <-> Proof Complexity

**Lineage**: Builds on ProofEntropyProfile and `gaussian_shift_complexity_theta_one_over_n`.

**Ambition**: extension

---

### Direction 5: Infinite-Dimensional SDF and Proof Complexity Classes

**Conjecture**: There is an infinite strictly decreasing chain of proof complexity classes, indexed by the entropy rate: the class C_r consists of all theorems whose proofs have entropy rate at most r. Specifically, C_0 ⊊ C_1 ⊊ C_2 ⊊ ... ⊊ C_n ⊊ ... , and the separation is witnessed by explicit theorems: the theorem "there exist r-incompressible strings of length n" has entropy rate exactly r.

**Test**: Construct explicit theorems with entropy rate exactly k for k = 0, 1, 2, 3 and prove they belong to C_k but not C_{k-1}. For k = 0: tautologies (always provable). For k = 1: theorems whose shortest proof requires one "creative" step.

**Impact**: This would establish an infinite hierarchy within proof complexity, analogous to the polynomial hierarchy in computational complexity but indexed by information content rather than quantifier alternation. It would provide a finer classification of theorem difficulty than the current "provable/unprovable" dichotomy.

**Catalog References**: `Applications/ProofSearchEntropy.lean` (search_complexity_hierarchy from Physics/ProofSearchInformation.lean), `Bridges/ProofSearchComplexity.lean`

**Proof Strategy**: (1) Define C_r = {T : ∃ proof of T with entropy rate ≤ r}. (2) Show C_r is closed under logical consequence. (3) Construct separating theorems using diagonalization. (4) Prove strictness using the incompressibility theorems. Key: the diagonal theorem "no proof of this statement has entropy rate ≤ r" has entropy rate r+1.

**Domain Bridges**: Computability Theory <-> Proof Complexity <-> Information Theory

**Lineage**: Builds on `search_complexity_hierarchy` and `incompressible_fraction`.

**Ambition**: grand_challenge
