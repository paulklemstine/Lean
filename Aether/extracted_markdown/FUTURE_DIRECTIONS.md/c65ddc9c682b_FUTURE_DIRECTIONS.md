# Future Research Directions

## Synthesis

This research cycle established the **Fiber Spectrum Algebra** as a rigorous mathematical framework for analyzing one-way functions and the cryptographic hardness hierarchy. The key discovery is that the combinatorial structure of function fibers — the multiset of preimage sizes — encodes all essential security properties: collision probability, min-entropy, inversion difficulty, and compression capacity.

Three cross-domain connections emerged as particularly promising. First, the fiber spectrum connects to **Rényi entropy theory** from information theory: the collision probability is the exponential of negative Rényi 2-entropy, meaning our Cauchy-Schwarz lower bound translates directly to an entropy upper bound. Second, the **Goldreich-Levin balance theorem** we proved has deep connections to **coding theory** — the inner product mod 2 is a linear code, and the balance property is equivalent to the dual code having minimum distance ≥ 2. Third, the **fiber refinement order** (merging increases collisions, splitting decreases them) is a special case of **majorization theory** from matrix analysis, suggesting connections to spectral graph theory and quantum information.

The highest breakthrough potential lies in Direction 1 (Formal HILL Theorem), which would complete the most important link in the cryptographic chain. The Goldreich-Levin balance theorem proved in this cycle is a critical prerequisite, and the fiber spectrum provides the right framework for analyzing the entropy extraction step.

---

### Direction 1: Formal HILL Theorem — One-Way Functions Imply Pseudorandom Generators

**Conjecture**: The Håstad-Impagliazzo-Levin-Luby (HILL) construction can be formalized as a Lean 4 theorem: given a one-way function family `{fₙ : Fin(2^n) → Fin(2^n)}` satisfying a formal one-wayness predicate (every poly-time inverter succeeds with negligible probability), one can construct a pseudorandom generator `G : Fin(2^n) → Fin(2^(n+1))` whose output is computationally indistinguishable from uniform.

**Test**: Formalize the three main components separately:
1. Goldreich-Levin hardcore bit extraction (combinatorial core proved in this cycle)
2. Entropy amplification via repetition (use the amplification_monotone theorem from the existing HardnessHierarchy catalog)
3. The "next-bit" construction that converts a hardcore predicate into a PRG with 1-bit stretch

If any component fails to formalize, identify precisely which step requires computational assumptions beyond what Lean can express.

**Impact**: This would be the first machine-verified proof of the foundational theorem of cryptography. It would demonstrate that the entire OWF → PRG → PRF → ENC chain can be formalized, and provide a template for verifying cryptographic reductions.

**Catalog References**: `Cryptography/FiberSpectrum.lean` (goldreich_levin_balance, collision_prob_lower_bound), `Catalog/Cryptography/HardnessHierarchy.lean` (amplification_monotone, HybridSequence)

**Proof Strategy**:
1. Define `IsOneWayFamily` as a predicate on function families (every PPT inverter has negligible success probability)
2. Define `IsPRG` as a predicate on stretching functions (output indistinguishable from uniform)
3. Use the Goldreich-Levin balance to construct the hardcore bit
4. Apply the hybrid argument (hybrid_max_step_bound) to analyze the PRG distinguisher
5. Compose using the reduction arrow algebra (ReductionArrow.comp_assoc)

**Domain Bridges**: Cryptography <-> Information Theory (Rényi entropy bounds), Cryptography <-> Coding Theory (linear codes)

**Lineage**: Builds on goldreich_levin_balance and fiber_spec_sum from this cycle

**Ambition**: grand_challenge

---

### Direction 2: Fiber Spectrum Majorization and Schur Convexity

**Conjecture**: The collision probability function CP(f) is Schur-convex with respect to the fiber spectrum: if spectrum S₁ majorizes spectrum S₂ (in the Hardy-Littlewood-Pólya sense), then CP(S₁) ≥ CP(S₂). Moreover, the unique minimum of CP over all fiber spectra with k entries summing to n is achieved by the "most uniform" spectrum (entries differ by at most 1).

**Test**: 
1. Formalize majorization as a partial order on multisets of natural numbers
2. Prove that CP is Schur-convex using the merge/split monotonicity theorems (merge_increases_collisions, split_reduces_collisions)  
3. Verify computationally for all fiber spectra with n ≤ 20 that the uniform spectrum minimizes CP

**Impact**: This would establish a deep connection between cryptographic security and majorization theory, opening the door to applying the extensive literature on Schur-convex functions to cryptographic analysis. In particular, it would give a lattice-theoretic characterization of which functions are "more one-way" than others.

**Catalog References**: `Cryptography/FiberSpectrum.lean` (merge_increases_collisions, split_reduces_collisions, collision_prob_lower_bound)

**Proof Strategy**:
1. Define majorization: S₁ ≻ S₂ iff the sorted partial sums of S₁ dominate those of S₂
2. Show that a single Robin Hood transfer (move one unit from a large fiber to a small one) strictly decreases CP
3. Any majorization can be decomposed into a sequence of Robin Hood transfers (Muirhead's inequality)
4. Compose to get Schur-convexity

**Domain Bridges**: Cryptography <-> Matrix Analysis (majorization theory), Cryptography <-> Combinatorial Optimization (scheduling theory)

**Lineage**: Directly extends merge_increases_collisions and split_reduces_collisions

**Ambition**: extension

---

### Direction 3: Oracle Separation Combinatorics — Random Oracle Lower Bounds

**Conjecture**: In the random oracle model, any "black-box" construction of a length-doubling PRG from a random permutation π : Fin(2^n) → Fin(2^n) must make at least n queries to π. Formally: for any oracle algorithm A making q queries to π, there exists a distinguisher that separates A^π from uniform using advantage ≥ q²/2^n (the birthday bound), implying q ≥ 2^{n/2} for negligible advantage.

**Test**: 
1. Formalize the random oracle model as a probability space over permutations
2. Prove the birthday bound: any q-query algorithm has collision probability ≥ q(q-1)/(2·2^n) 
3. Show that the collision probability directly translates to a distinguishing advantage for PRG output vs. uniform

If the full probabilistic formalization is infeasible, prove the combinatorial core: among all permutations π of Fin(2^n), the fraction with any particular q-element subset S mapping to a specified q-element subset T is exactly (2^n - q)! / (2^n)!.

**Impact**: This would formalize the Impagliazzo-Rudich barrier, showing that certain cryptographic constructions provably cannot exist in a black-box sense. This is one of the most important negative results in cryptography.

**Catalog References**: `Cryptography/OracleSeparation.lean` (compression_barrier, compression_collateral, non_injective_majority, birthday_collision)

**Proof Strategy**:
1. Define the random oracle model over `Equiv.Perm (Fin (2^n))`
2. Use the non_injective_majority result to bound collision probabilities
3. Apply the hybrid argument to decompose multi-query distinguishing advantages
4. Connect to the compression barrier for the stretch argument

**Domain Bridges**: Cryptography <-> Combinatorics (permutation counting), Cryptography <-> Probability Theory (random oracle model)

**Lineage**: Extends compression_collateral and non_injective_majority from this cycle

**Ambition**: grand_challenge

---

### Direction 4: Negligible Function Hierarchy and Polynomial Security

**Conjecture**: The negligible functions form a proper ideal in the ring of eventually non-negative functions ℕ → ℚ, and this ideal admits a natural filtration by "negligibility degree" — the minimum polynomial exponent c such that f(n) · n^c ≤ 1 for large n. Moreover, the security of a k-level reduction chain with negligible advantage functions is still negligible, with the negligibility degree increasing by at most k.

**Test**:
1. Prove that negligible functions are closed under multiplication (strengthening the constant multiplication already proved)
2. Define "negligibility degree" and prove it is well-defined for all negligible functions
3. Show that composing k reductions, each with negligible security loss, yields a construction with negligible security loss (degree increases additively)

**Impact**: This would provide a quantitative framework for analyzing the cost of long reduction chains, directly relevant to the practical security of multi-step cryptographic constructions. The "negligibility degree" would give concrete security parameter recommendations.

**Catalog References**: `Cryptography/OracleSeparation.lean` (IsNegligible, negligible_add, negligible_const_mul, loss_accumulation_strict)

**Proof Strategy**:
1. Extend the negligible function algebra with multiplication closure
2. Define negligibility degree as the infimum of valid exponents
3. Use the reduction arrow composition (ReductionArrow.comp_assoc) to track degree through chains
4. Prove the additive degree bound by induction on chain length

**Domain Bridges**: Cryptography <-> Analysis (asymptotic analysis), Cryptography <-> Algebra (ideal theory in function rings)

**Lineage**: Directly extends negligible_add and negligible_const_mul from this cycle

**Ambition**: extension

---

### Direction 5: Tropical Fiber Spectra and Post-Quantum OWF Candidates

**Conjecture**: The fiber spectrum of tropical matrix multiplication (computing A ⊕ B in the min-plus semiring) has a rigid combinatorial structure: for generic n × n tropical matrices A over {0, ..., M}, the fiber spectrum of the map B ↦ A ⊕ B has max fiber size at most M^{n-1}. This makes tropical matrix multiplication a candidate one-way function with quantifiable hardness.

**Test**:
1. Compute fiber spectra for small tropical matrix multiplications (2×2, 3×3) using #eval
2. Verify the conjectured bound for n = 2, 3 with M = 1, 2, 3, 4
3. If the bound holds, attempt to prove it using the existing tropical cryptography infrastructure

**Impact**: This would bridge the fiber spectrum algebra with the tropical cryptography research thread, providing the first quantitative security analysis of tropical OWF candidates. The existing catalog contains tropical lattice bounds (tropical_lattice_det_bound) and NP-hardness results that could anchor the analysis.

**Catalog References**: `Cryptography/TropicalOneWayFoundations.lean` (tropical_lattice_det_bound), `Cryptography/TropicalMinPlusCrypto.lean` (tropMV_one_sided_bound), `Cryptography/FiberSpectrum.lean` (image_size_from_max_fiber, collision_prob_lower_bound)

**Proof Strategy**:
1. Define tropical matrix multiplication as a concrete function between Fin types
2. Compute its fiber spectrum using the FiberSpec definition
3. Apply image_size_from_max_fiber to derive image size lower bounds
4. Connect to existing tropical lattice bounds for the hardness argument

**Domain Bridges**: Cryptography <-> Tropical Geometry (min-plus algebra), Cryptography <-> Post-Quantum Cryptography (lattice-based hardness)

**Lineage**: Bridges FiberSpectrum (this cycle) with TropicalOneWayFoundations and TropicalMinPlusCrypto (existing catalog)

**Ambition**: extension
