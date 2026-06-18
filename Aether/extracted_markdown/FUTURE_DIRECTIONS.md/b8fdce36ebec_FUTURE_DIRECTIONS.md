# Future Directions: Cohomological Causal Inference

## Breakthrough Opportunities (ranked by impact)

### 1. Non-trivial H¹ on Restricted Covers

**Theorem Statement**: For a causal DAG G with n variables and a cover 𝒰 consisting of Markov blankets, dim H¹(𝒰, F) equals the number of independent non-identifiable causal effects.

**Proof Strategy**:
- (A) Compute the Čech complex explicitly for Markov blanket covers of small DAGs (n ≤ 6)
- (B) Show that the rank of δ⁰ restricted to the Markov blanket cover equals the number of edges minus the number of d-connected components
- (C) Use the rank-nullity theorem to compute dim H¹

**Why This Is Revolutionary**: Our current formalization proves H¹ = 0 on the *total* space (all variable subsets). The interesting case is restricted covers—where only certain subsets are observable. This would give the first algebraic formula for the number of non-identifiable effects.

**Catalog Leverage**: `cocycle_eq_coboundary_on_total`, `cocycle_effective_dimension`

**Research Mode**: prove  
**Estimated Depth**: 4

---

### 2. Persistent Causal Cohomology

**Theorem Statement**: For a sequence of causal models M₁ ⊆ M₂ ⊆ ... ⊆ Mₙ ordered by variable inclusion, the persistent H¹ groups form a barcode that tracks birth/death of identifiability obstructions.

**Proof Strategy**:
- (A) Define the persistence module H¹(M₁) → H¹(M₂) → ... → H¹(Mₙ)
- (B) Show this is a pointwise finite-dimensional module over the polynomial ring k[t]
- (C) Apply the structure theorem for finitely generated modules to obtain the barcode decomposition

**Why This Is Revolutionary**: Connects topological data analysis (TDA) to causal inference—persistent barcodes would reveal which identifiability obstructions are robust and which are artifacts of variable selection.

**Catalog Leverage**: `filteredObstructionNorm_mono`, `spectral_filtration`

**Research Mode**: formalize  
**Estimated Depth**: 5

---

### 3. Derived Causal Categories

**Theorem Statement**: The derived category D^b(CausalPresheaves) has a t-structure whose heart is the abelian category of identifiable effects.

**Proof Strategy**:
- (A) Define the category of causal presheaves using Mathlib's category theory library
- (B) Construct the derived category using chain complexes and quasi-isomorphisms
- (C) Show that the natural t-structure selects exactly the identifiable sub-effects

**Why This Is Revolutionary**: Opens the door to derived functors for causal inference—left/right derived functors of the "do" operator would compute higher-order counterfactual effects.

**Catalog Leverage**: Mathlib's `CategoryTheory` library, `coboundaryZeroLinear`, `coboundaryOneLinear`

**Research Mode**: formalize  
**Estimated Depth**: 5

---

### 4. Tropical Causal Cohomology

**Theorem Statement**: The tropicalization of the Čech complex yields a min-plus cohomology where dim H¹_trop equals the minimum number of interventional experiments needed for full identifiability.

**Proof Strategy**:
- (A) Replace ℝ with the tropical semiring (ℝ ∪ {∞}, min, +) in the cochain complex
- (B) Show that tropical d²=0 still holds (the proof carries over since min-plus satisfies the required algebraic identities)
- (C) Interpret tropical cocycles as shortest-path problems

**Why This Is Revolutionary**: Reduces experiment design to a shortest-path computation—O(n³) algorithm for determining the minimal experiment set.

**Catalog Leverage**: `TropicalCausalOptimization` module, `coboundary_composition_zero`

**Research Mode**: prove  
**Estimated Depth**: 3

---

### 5. Neural Sheaf Robustness

**Theorem Statement**: A neural network's feature presheaf is a sheaf iff the network has certified Lipschitz robustness, with the Lipschitz constant equal to ‖H¹(F_features)‖.

**Proof Strategy**:
- (A) Define feature presheaves on neural network layer decompositions
- (B) Show that the sheaf condition on feature spaces is equivalent to Lipschitz continuity of the layer-wise representation
- (C) Connect ‖H¹‖ to the spectral norm of weight matrices

**Why This Is Revolutionary**: Gives a topological criterion for neural network robustness—certified robustness becomes a cohomological computation.

**Catalog Leverage**: `cochainPairing_self_zero_iff`, `three_hop_lipschitz`, `four_hop_lipschitz`

**Research Mode**: formalize  
**Estimated Depth**: 4

## Under-explored Territory

1. **Higher cohomology groups H² and beyond**: Our formalization only uses H¹. Higher groups should classify higher-order causal obstructions—e.g., obstructions to identifying joint effects of multiple interventions simultaneously.

2. **Sheaf cohomology vs. Čech cohomology**: For nice topological spaces, these agree. For finite posets, they may differ. Characterizing when they agree for causal presheaves would resolve fundamental questions about which cover is "correct."

3. **Quantum causal presheaves**: Replacing real-valued sections with density matrices would connect to quantum causal models. The failure of the sheaf condition should characterize entanglement.

## Cross-Domain Bridges

1. **Čech cohomology ↔ Information geometry**: The Fisher information metric on the space of interventional distributions should induce a Riemannian metric on cochains. The obstruction norm ‖H¹‖ should equal the geodesic distance between the nearest identifiable model.

2. **Spectral filtration ↔ Renormalization group**: The filtration levels in our spectral sequence correspond to "energy scales" in physics. The E₂ page should correspond to the effective theory at each scale.

3. **Cocycle lattice ↔ Post-quantum cryptography**: The lattice of integer-valued cocycles defines a lattice-based hash function. The shortest vector problem on this lattice should be equivalent to finding the most efficiently identifiable sub-model.

## Open Problems Encountered

1. **Quantitative H¹ bounds for sparse DAGs**: We prove dim(H¹) = 0 on the total space, but for restricted covers on bounded-in-degree DAGs, what is the tight bound? Conjecture: dim(H¹) = O(n²/k) where k is the maximum in-degree.

2. **Spectral sequence degeneration**: Does the Čech spectral sequence for causal presheaves always degenerate at E₃? We proved filtration monotonicity but not degeneration.

3. **Functorial backdoor criterion**: Is there a natural transformation from the backdoor presheaf to the causal presheaf that preserves cohomology? This would give a "functorial" version of the backdoor criterion.
