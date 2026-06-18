# Summary of changes for run 3a5317a7-927f-4783-a4de-7c3bea33279f
## Tropical Satake Correspondence for GL₃ — Completed Deliverables

### Critical Finding: The Proposed Theorem is FALSE

The theorem `tropical_satake_GL3_algebraHom` as stated is **mathematically false**. I discovered a concrete counterexample: using indicator functions f = g = δ₍₁,₀,₀₎, the left side evaluates to +∞ at λ = (1,1,0) while the right side evaluates to 0. The root cause is that the sorting map (which sends coweights to their dominant representatives) is **not additive**: sort(1,0,0) + sort(0,1,0) = (2,0,0) ≠ (1,1,0) = sort(1,1,0). This non-additivity is formally proved as `sort_not_additive_witness` (verified by `decide`).

The correct formulation requires using **full tropical convolution** on the entire coweight lattice ℤ³ (not restricted to dominant coweights). Under this formulation, S₃-invariance is indeed preserved — which I formally proved.

### 1. Formally Verified Mathematics (Lean 4, sorry-free)

**`Tropical/Langlands/TropicalSatakeGL3.lean`** (~230 lines, pre-existing, enhanced):
- Tropical Chevalley Theorem: tropical symmetric polynomials completely separate S₃-orbits
- Satake Cone characterization: image is {(x,y,z) : 2x ≥ y ∧ 2y ≥ x+z}
- Tropical Newton's identity: p_k = k·e₁
- Satake injectivity on sorted triples

**`Tropical/Langlands/TropicalSatakeGL3Algebra.lean`** (~330 lines, new):
- **Dominant submonoid**: sum of dominant coweights is dominant (`dominant_add_closed`)
- **Sorting properties**: sort₃ is dominant, idempotent, sum-preserving (`sort_is_dominant`, `sort_idempotent`, `sort_preserves_sum`)
- **S₃ generators**: swap₁₂ and 3-cycle generate all permutations; swap₂₃ derived (`weyl_inv_swap23`)
- **Weyl invariance of sort**: composing with sort yields S₃-invariant functions (`weyl_inv_of_sort`, `weyl_inv_eq_at_sort`)
- **Sort non-additivity**: formal proof and counterexample (`sort_not_additive`, `sort_not_additive_witness`)
- **Tropical convolution on EReal**: preserves S₃-invariance (`tropConv_swap12`, `tropConv_cycle`, `tropConv_weyl_invariant`)
- **Convolution commutativity** (`tropConv_comm`)
- **Tropical Schur polynomials**: S₃-invariance, fundamental weight specializations, rearrangement inequality (`tropSchur_weylInvariant`, `tropSchur_dominant_eval`)
- **Satake restriction-extension isomorphism**: S₃-invariant functions biject with dominant-chamber functions (`satake_extend_restrict`, `satake_restrict_extend`)
- **ρ-pairing not invariant**: explains why the modular character correction is needed (`rhoPairing_not_invariant`)

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### 2. Python Demos (`demos/`)

- **`tropical_satake_demo.py`**: Interactive demonstration of all theorems with visualizations
  - Orbit separation examples
  - Satake cone visualization
  - Sort non-additivity counterexample
  - Tropical convolution S₃-invariance verification
  - Tropical Schur polynomial evaluation and rearrangement inequality
  - Three publication-quality PNG figures

- **`applications.py`**: Four practical applications
  - Three-machine job scheduling (20.8× symmetry reduction)
  - Shortest paths in symmetric networks
  - Permutation-invariant feature extraction (ML on sets)
  - Morphological signal processing

### 3. Research Paper (`ResearchOutput/tropical_satake/paper.md`)

Complete mathematical paper covering:
- All main results with precise theorem statements
- Detailed explanation of the disproof with counterexample
- Proof architecture and formalization techniques
- Scientific American-style discussion section with analogies
- Four concrete applications
- Future directions for GL_n generalization

### 4. Key Mathematical Contributions

1. **Disproof**: The naive tropical Satake transform with dominant-restricted convolution is NOT an algebra homomorphism
2. **Correct formulation**: Full tropical convolution on ℤ³ preserves Weyl invariance (formally proved)
3. **Rearrangement inequality**: Tropical Schur polynomials at doubly-dominant inputs equal the reverse inner product
4. **Complete invariants**: Tropical elementary symmetric polynomials separate all S₃-orbits