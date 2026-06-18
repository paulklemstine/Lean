# Future Directions: Tropical Metastability Theory

## Synthesis

The results established here — the Dictionary Theorem (tropical balance ↔ metastable degeneracy), the Rank-Count Equality under non-resonance, and the Arrhenius Bridge — form the foundation of a new field we call **tropical metastability theory**. These results open five concrete research directions, each combining tropical algebraic techniques with domain-specific physical or mathematical structures. The unifying theme is that min-plus algebra provides exactly the right language for understanding the low-temperature limit of stochastic dynamics on weighted graphs, and this insight extends far beyond pairwise barrier degeneracies.

The directions below range from immediate extensions (higher-order degeneracies, continuous Morse-theoretic generalizations) to grand challenges (tropical optimal transport on reaction networks, tropical information theory for rare-event channels). Each direction is grounded in the catalog results from `WeightedTropicalHodge.lean` and the new theorems in `TropicalMetastability.lean`, and each is specific enough to admit computational testing and potential disproof.

---

## Direction 1: Higher-Order Tropical Degeneracies and k-fold Metastability

**Conjecture:** For a weighted energy landscape W on n states, define the *k-fold metastability rank* as the maximum number of states in S whose minimum barrier is attained by at least k distinct exits, with k-tuples of witnesses pairwise non-overlapping. Then for k ≥ 2, the k-fold rank satisfies:
$$\text{MetastabilityRank}_k(W, S) = |\{i \in S : |\text{outMinimizerSet}(W,i)| \geq k\}|$$
under a generalized non-resonance condition requiring k-tuple witness disjointness.

**Test:** Construct random 8-vertex landscapes with forced 3-fold and 4-fold degeneracies. Compute the exact k-fold rank by brute-force subset enumeration and compare with the conjectured count formula. A single counterexample with non-overlapping k-tuples that violates equality would refute the conjecture.

**Impact:** This would establish a complete tropical hierarchy for metastable landscapes, where each level k captures progressively rarer but more consequential multi-pathway degeneracies. In protein folding, k=3 degeneracies correspond to three-way folding pathway junctions — critical for understanding allosteric regulation.

**Catalog References:** `Pythagorean/TropicalMetastability.lean` (MetastabilityRank, IsBalancedIndependentFamily), `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (WeightDegenerateAt, tropBalancedAt).

**Proof Strategy:** Generalize IsBalancedIndependentFamily from pairs to k-tuples. The upper bound (rank ≤ count) should follow by the same argument: any independent family is contained in the degenerate set. The lower bound under non-resonance requires showing the full degenerate set with k-tuple witnesses is independent.

**Domain Bridges:** Computational chemistry (multi-pathway reactions), materials science (polymorphic nucleation with ≥3 competing crystal phases), network science (multi-commodity flow bottlenecks).

**Lineage:** Direct extension of Theorems 2–3.

**Ambition:** Medium — extends existing techniques to a natural generalization.

---

## Direction 2: Tropical Morse Theory on Continuous Energy Surfaces

**Conjecture:** For a Morse function f : M → ℝ on a compact Riemannian manifold, define the *tropical Morse complex* by taking the finite graph of critical points connected by gradient flow lines, with edge weights equal to saddle heights. Then the tropical metastability rank of this graph equals the number of degenerate saddle connections (pairs of critical points connected by saddle points of equal height) minus the number of resonant overlaps.

More precisely: the Dictionary Theorem lifts from finite graphs to the combinatorial structure of Morse-Smale complexes. The metastability rank of the discretized landscape captures the Betti number contributions from degenerate critical point connections.

**Test:** Compute Morse-Smale complexes for random trigonometric polynomials on the torus T² (a well-studied testbed). Extract the barrier graph, compute metastability rank, and compare with the actual number of degenerate saddle connections obtained from numerical gradient flow integration. A systematic mismatch between tropical rank and saddle degeneracy count would falsify the conjecture.

**Impact:** This would bridge tropical metastability theory to differential topology, creating a new "tropical Morse theory" that captures degeneracy phenomena invisible to classical Morse homology. It would also connect to persistent homology, since barrier degeneracies correspond to persistence diagram points colliding on the diagonal.

**Catalog References:** `Pythagorean/TropicalMetastability.lean` (tropicallyBalancedRow_iff_metastablyDegenerate), `Catalog/Pythagorean/TropicalMorse/` (existing tropical Morse definitions).

**Proof Strategy:** Discretize the Morse-Smale complex into a finite weighted graph. Apply the Dictionary Theorem to the discretization. Show that the discretization error vanishes for generic Morse functions (where saddle heights are distinct), and that the non-resonance condition is satisfied generically.

**Domain Bridges:** Algebraic topology (persistent homology, Morse homology), data science (topological data analysis on energy surfaces), theoretical physics (instantons and tunneling amplitudes).

**Lineage:** Combines Theorem 1 with classical Morse theory.

**Ambition:** Grand challenge — requires significant new mathematical infrastructure.

---

## Direction 3: Tropical Optimal Transport for Reaction Networks

**Conjecture:** Given two probability distributions μ, ν on the states of an energy landscape, define the *tropical transport cost* as the min-plus analogue of the Wasserstein distance:
$$T_{\text{trop}}(\mu, \nu) = \min_\gamma \max_{(i,j) \in \text{supp}(\gamma)} W(i,j)$$
where γ ranges over transport plans. Then the tropical transport cost detects metastable bottlenecks: the optimal transport plan must route through a metastably degenerate state if and only if no alternative path avoids all degenerate crossroads.

Furthermore, the number of distinct optimal transport plans (when the minimum is achieved by multiple plans) equals the metastability rank of the bottleneck states traversed.

**Test:** For small random graphs (n ≤ 10), enumerate all optimal transport plans between random source/target distributions. Count distinct plans and compare with the metastability rank of the bottleneck states. A case where the number of distinct optimal plans exceeds the metastability rank would disprove the conjecture.

**Impact:** This would create a new bridge between optimal transport theory (a major current research area) and tropical geometry, with immediate applications to understanding how probability flows through metastable networks in chemical kinetics.

**Catalog References:** `Pythagorean/TropicalMetastability.lean` (MetastabilityRank, NonResonantOn), `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (weightedTropKernelOn).

**Proof Strategy:** Formalize tropical transport as a min-max optimization. Show that bottleneck vertices must be balanced (by a tropical duality argument). Connect the multiplicity of optimal plans to the kernel dimension via the catalog's kernel theory.

**Domain Bridges:** Optimal transport (Villani theory), chemical kinetics (reaction coordinate identification), machine learning (Wasserstein GANs on molecular spaces).

**Lineage:** Novel combination of Theorem 1 with tropical optimization.

**Ambition:** Grand challenge — entirely new mathematical territory.

---

## Direction 4: Metastability in Spin Glass Energy Landscapes

**Conjecture:** For the Sherrington-Kirkpatrick spin glass model on n spins, the barrier matrix between local energy minima defines a weighted graph whose tropical metastability rank grows as Θ(2^{n/2}) — matching the known scaling of the number of metastable states.

More specifically: the non-resonance condition fails with vanishing probability as n → ∞ for random Gaussian couplings, so the metastability rank equals the degeneracy count with high probability. This would provide a new algebraic proof of the exponential metastability landscape in mean-field spin glasses.

**Test:** For small n (n = 8, 10, 12), enumerate all local minima of random SK instances. Compute the barrier graph via minimum-energy paths between minima. Compute the tropical metastability rank and compare with the total number of barrier-degenerate minima. If the non-resonance condition fails with increasing probability as n grows (contrary to the conjecture), this would falsify the conjecture.

**Impact:** Connecting tropical metastability to spin glass theory would bring the techniques to one of the most active areas of mathematical physics. If the rank scaling matches the known metastability scaling, it would provide an entirely new algebraic perspective on spin glass complexity.

**Catalog References:** `Pythagorean/TropicalMetastability.lean` (metastabilityRank_eq_degeneracyCount), `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (generic_zero_not_balanced).

**Proof Strategy:** Use the genericity results from the catalog (generic weights prevent balance) to argue that non-resonance holds with high probability for continuous random couplings. Then apply Theorem 3 to get rank = count. Estimate the count using known results on the number of local minima in SK models.

**Domain Bridges:** Statistical physics (spin glasses, random energy model), probability theory (Gaussian process extrema), computer science (random constraint satisfaction).

**Lineage:** Extension of Theorem 3 to random matrix theory.

**Ambition:** Grand challenge — connects to deep open problems in spin glass theory.

---

## Direction 5: Tropical Information Theory for Rare-Event Channels

**Conjecture:** Define a *tropical channel capacity* for a metastable communication channel where transmission probabilities follow Arrhenius kinetics:
$$C_{\text{trop}}(W) = \max_{i} \log_2 |\text{outMinimizerSet}(W, i)|$$
measuring the maximum number of bits that can be transmitted per transition through equally favorable channels. Then the total tropical channel capacity of a network equals the sum of log₂ contributions from independent metastable degeneracies, i.e., it is controlled by the metastability rank.

**Test:** Construct small channel networks with known tropical capacities. Verify that the total capacity decomposition matches the metastability rank for non-resonant networks. Check that resonant networks violate the additive decomposition.

**Impact:** This would create a new "tropical Shannon theory" applicable to rare-event communication channels, with potential applications to molecular computing and biological signaling networks where signal transmission occurs via thermally activated barrier crossings.

**Catalog References:** `Pythagorean/TropicalMetastability.lean` (equal_prefactor_equal_rate_iff_equal_barrier, MetastabilityRank), `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (weightedTropKernelOn).

**Proof Strategy:** Formalize tropical channel capacity as a function of the minimizer set cardinalities. Show additivity under non-resonance using the independence structure from Theorem 2. For the converse (resonance breaks additivity), construct explicit counterexamples.

**Domain Bridges:** Information theory (channel capacity, Shannon theory), molecular computing (DNA-based computation), neuroscience (synaptic barrier transmission).

**Lineage:** Combines Theorem 4 (Arrhenius bridge) with information-theoretic concepts.

**Ambition:** Medium-high — novel conceptual bridge with tractable formalization path.
