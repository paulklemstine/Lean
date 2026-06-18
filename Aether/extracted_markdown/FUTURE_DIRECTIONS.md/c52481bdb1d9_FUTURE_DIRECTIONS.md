# Future Directions: Tropical Witness Geometry for Cryptographic Primitives

## Status of Current Work

We have formalized and machine-verified the following core results in Lean 4:

1. **Gauge Invariance Theorems**: Tropical products and witness sets are invariant under gauge transformations (additive shifts on hidden indices) and permutations.
2. **Witness Equality Determines Differences**: Shared witness entries pin down pairwise differences of factor entries, the engine of reconstruction.
3. **Rank-1 Classification**: For rank-1 factorizations, any two realizations of the same separated witness profile are gauge-equivalent (σ = id, one degree of freedom t).
4. **Rank-1 Normalized Reconstruction**: Under normalization (min = 0), the rank-1 factorization is unique.
5. **General Classification Theorem**: Under full-column witness and column-completeness conditions, any two realizations of the same witness profile are gauge-equivalent.

The realizability theorem (admissible profiles are realizable) remains open due to the complexity of constructing explicit factorizations that satisfy all separation constraints simultaneously.

---

## Direction 1: Tensor (Higher-Arity) Tropical Witness Duality

**Statement**: For tropical trilinear maps C_{ijℓ} = min_k (A_{ik} + B_{kj} + D_{kℓ}), the witness geometry should admit a classification theorem with gauge group acting as t_k shifts on all three factors simultaneously.

**Proof Strategy**:
- Define tropical 3-tensor multiplication via `Finset.inf'` over the hidden index
- The gauge group becomes {(t_k)} acting by A_{•k} ↦ A_{•k} + t_k, B_{k•} ↦ B_{k•} - α_k t_k, D_{k•} ↦ D_{k•} - (1-α_k) t_k for partition parameters α_k
- Witness sets W_{ijℓ} = argmin_k (...) generalize directly
- The classification theorem should follow from the same column-completeness argument applied to each factor pair

**Cross-Domain**: This connects to tropical secant varieties and tensor decomposition identifiability — a fundamental problem in machine learning (tensor factor analysis).

**Difficulty**: Medium. The main challenge is managing the three-way gauge freedom parametrization.

---

## Direction 2: Hardness Reductions from Tropical Rank

**Statement**: Formalize the computational complexity gap between forward tropical multiplication (polynomial time) and inversion without witness data (tropical rank factorization, conjectured NP-hard).

**Specific Theorem Target**:
> Tropical rank-r factorization of an m×n matrix over ℤ is at least as hard as determining whether an integer matrix has tropical rank ≤ r.

**Proof Strategy**:
- Reduce tropical rank decision to tropical factorization with witness recovery
- Use the classification theorem to show that witness-free inversion requires searching over gauge/permutation classes
- Connect to known NP-hardness results for tropical rank (Kim–Roush, Shitov)

**Cross-Domain**: This establishes tropical factorization as a candidate one-way function for post-quantum cryptography, analogous to integer factorization for RSA.

**Difficulty**: Hard. Requires formalizing complexity-theoretic reductions in Lean.

---

## Direction 3: Zero-Knowledge Witness-Profile Protocols

**Statement**: Design and formalize a zero-knowledge proof protocol where the prover demonstrates knowledge of a tropical factorization witness without revealing the factors.

**Protocol Sketch**:
1. Prover commits to (A, B) with C = tropMul(A, B)
2. Verifier challenges with random (i, j) pairs
3. Prover reveals W_{ij} and the gap certificate γ_{ij}
4. Verifier checks consistency without learning A or B

**Theorem Target**:
> The protocol is complete (honest prover always convinces), sound (no fake proof exists), and zero-knowledge (verifier learns nothing beyond the validity claim).

**Cross-Domain**: This bridges tropical algebra to modern cryptographic protocol design and could yield novel post-quantum ZK proofs.

**Difficulty**: Hard. Requires formalizing probabilistic arguments and simulation-based security.

---

## Direction 4: Probabilistic/Noisy Witness Certification

**Statement**: When entries of A and B are perturbed by noise (e.g., A_{ik} → A_{ik} + ε_{ik}), characterize the stability of witness sets under perturbation.

**Theorem Target**:
> If the separation gap γ > 2·max|ε|, then the witness set is preserved under perturbation. Moreover, the gauge shift recovered from the perturbed factorization approximates the true gauge shift within O(max|ε|).

**Proof Strategy**:
- Use the separation condition: non-witness entries are γ-separated
- Perturbation of size < γ/2 cannot flip witness/non-witness status
- Reconstruct approximate factors and bound the error

**Cross-Domain**: This is essential for practical applications where measurements are noisy (ML, signal processing, genomics).

**Difficulty**: Medium. Builds directly on the separation framework already formalized.

---

## Direction 5: Tropical Secant Variety Identifiability from Certified Active Sets

**Statement**: The witness profile of a tropical rank-r factorization defines a regular subdivision of the output matrix. Prove that this subdivision, together with the separation data, determines the secant variety fiber uniquely up to the gauge/permutation action.

**Theorem Target**:
> Let V_r denote the tropical rank-≤r variety. The fiber of the projection π: (A, B) → C over C ∈ V_r is a finite union of gauge/permutation orbits, and each orbit is determined by its witness profile.

**Proof Strategy**:
- Formalize tropical rank as a min over factorization dimensions
- Show that the witness profile is a combinatorial invariant of the secant fiber
- Use the classification theorem to decompose fibers into orbits

**Cross-Domain**: This connects to tropical algebraic geometry (Maclagan–Sturmfels) and establishes a dictionary between cryptographic trapdoors and geometric invariants.

**Difficulty**: Very hard. Requires significant tropical algebraic geometry infrastructure.

---

## Concrete Next Steps (Ordered by Priority)

1. **Prove realizability theorem**: Complete the construction of factorizations from admissible profiles. Key missing piece: handling the min-plus constraint system constructively.

2. **Formalize graph-connectivity approach**: Replace the full-column witness condition with a bipartite-graph connectivity condition on the witness pattern, yielding a more general classification theorem.

3. **Implement tropical key exchange**: Build a concrete key-exchange protocol using the trapdoor structure and test it computationally.

4. **Compute examples**: Generate families of matrices with known tropical rank and witness profiles, measure the computational gap between witness-aided and witness-free inversion.

5. **Connect to Mathlib tropical infrastructure**: As Mathlib's tropical semiring support grows, migrate from our ad-hoc ℤ-based definitions to the canonical `Tropical` type.
