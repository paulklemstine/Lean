# Future Directions: Tropical One-Way Kernel Duality

## 1. Tropical Hankel-Rank Lower Bounds for One-Way Circuit Complexity

**Goal**: Establish that the generator rank of the kernel semimodule provides a lower bound on the complexity (depth, width, or total gate count) of any tropical circuit computing a given function.

**Concrete theorem target**:
```
theorem tropical_circuit_lower_bound (K : FiniteTropKernelSemimodule n hn) :
    ∀ C : TropicalCircuit n, C.computes K.κ → generatorRank K ≤ C.size
```

**Proof strategy**: Adapt the Hankel matrix rank argument from linear systems theory. Define the tropical Hankel matrix of a circuit as the matrix of input-output tropical inner products. Show that each gate in the circuit contributes at most one generator to the kernel factorization, yielding the lower bound. The idempotent characterization (`idempotent_iff_metric`) provides the key algebraic constraint: any factorization through fewer generators must violate the triangle inequality.

**Impact**: This would be the first formal lower bound technique for tropical circuit complexity derived from algebraic invariants rather than combinatorial arguments. It connects to the broader program of arithmetic circuit lower bounds via algebraic geometry.

---

## 2. Enriched-Category Formulation of Kernel Realization Duality

**Goal**: Formalize the kernel realization duality as an adjunction between:
- The category of bounded tropical hash networks (with tropical matrix morphisms)
- The category of finite idempotent kernel semimodules (with kernel-preserving maps)

**Concrete theorem target**:
```
theorem kernel_realization_adjunction :
    Adjunction (kernelProfileFunctor) (realizationFunctor)
```

**Proof strategy**: The kernel profile functor sends a network H to its kernel semimodule (H.kernelProfile, witnesses). The realization functor sends a semimodule to its reconstructed network. The unit is the inclusion of a network into the reconstruction of its kernel (showing the reconstruction is at least as expressive). The counit is the kernel recovery bound (`reconstructNetwork_matches_kernel`). The triangle identities follow from the idempotent theorem.

**Impact**: Elevates the duality from isolated theorems to categorical infrastructure, enabling compositional reasoning about tropical one-way architectures. This is the tropical analogue of the Kalman realization adjunction in linear systems theory.

---

## 3. Probabilistic Kernel Reconstruction and Stability

**Goal**: Extend the deterministic reconstruction to a noisy setting where the kernel profile is observed with additive tropical noise. Prove stability: small perturbations in the kernel profile yield bounded perturbations in the reconstructed network.

**Concrete theorem target**:
```
theorem noisy_reconstruction_stability
    (K : FiniteTropKernelSemimodule n hn) (ε : ℝ) (hε : 0 < ε)
    (κ_noisy : Fin n → Fin n → ℝ)
    (h_close : ∀ a b, |κ_noisy a b - K.κ a b| ≤ ε) :
    ∀ a b, |(reconstructFromNoisy κ_noisy).kernelProfile a b -
            (reconstructNetwork hn K).kernelProfile a b| ≤ 2 * ε
```

**Proof strategy**: The tropical inf' operation is 1-Lipschitz in the sup-norm (as established by `tropLinMap_nonexpansive` in the existing codebase). Since the kernel profile is defined as an inf', pointwise perturbation of the matrix entries by ε perturbs the kernel profile by at most 2ε (one ε from each factor in M(a,k) + M(b,k)). The reconstruction inherits this stability.

**Impact**: Makes the theory applicable to real-world settings where kernel profiles are estimated from finite samples. Connects to the certified ML robustness results in the tropical one-way functions file.

---

## 4. Tropical Public-Key Asymmetry via Non-Self-Dual Kernel Profiles

**Goal**: Identify kernel profiles where the forward direction (network → kernel) is computationally easy but the reverse (kernel → network) is computationally hard. Formalize this as a separation between the complexity of kernel evaluation and kernel inversion.

**Concrete theorem target**:
```
theorem tropical_one_way_separation (n : ℕ) (hn : 10 ≤ n) :
    ∃ κ : Fin n → Fin n → ℝ,
      CollisionSeparationProfile n (by omega) κ ∧
      kernelEvalComplexity κ ≤ n^3 ∧
      kernelInversionComplexity κ ≥ 2^(n/2)
```

**Proof strategy**: Use tropical matrix powering as the kernel construction: κ = tropicalGram(M^⊗k) where M^⊗k is the k-th tropical power. The forward evaluation is O(n³ log k) by repeated squaring, while inversion requires recovering k from the Gram matrix, which reduces to the tropical discrete logarithm problem. The hardness gap leverages `tropical_security_exponential_gap` from the existing codebase.

**Impact**: Would establish the first formal connection between tropical kernel duality and cryptographic key exchange, potentially leading to a post-quantum key agreement protocol based on tropical matrix invariants.

---

## 5. Certified Indistinguishability Obstructions from Semimodule Invariants

**Goal**: Prove that two tropical networks are computationally indistinguishable (in a formal complexity-theoretic sense) if and only if their kernel semimodules are isomorphic. This gives a complete algebraic characterization of network equivalence.

**Concrete theorem target**:
```
theorem indistinguishability_iff_kernel_iso
    (H₁ H₂ : BoundedTropicalHashNetwork n hn) :
    ComputationallyIndistinguishable H₁ H₂ ↔
    KernelSemimoduleIsomorphic H₁.kernelSemimodule H₂.kernelSemimodule
```

**Proof strategy**: Forward: if the kernel semimodules are isomorphic, the networks have identical kernel profiles, so any distinguisher based on pairwise queries fails. Backward: if the kernel profiles differ at some (a,b), construct a distinguisher that queries the network at inputs a and b and compares. The generator rank invariant (`generatorRank`) provides a coarse obstruction: networks with different generator ranks are trivially distinguishable.

**Impact**: Creates a formal framework for security proofs of tropical cryptographic primitives. The kernel semimodule becomes the canonical "security parameter" — two schemes are secure relative to each other if their kernels are isomorphic. This is the tropical analogue of indistinguishability obfuscation.

---

## Cross-Cutting Themes

All five directions share a common structure: the kernel semimodule as a **universal algebraic invariant** for tropical one-way computation. The progression is:

1. **Lower bounds** (Direction 1): The kernel measures what a circuit *must* compute.
2. **Categories** (Direction 2): The kernel determines what a circuit *is* up to equivalence.
3. **Stability** (Direction 3): The kernel tolerates what a circuit *approximately* computes.
4. **Hardness** (Direction 4): The kernel separates what is *easy* from what is *hard*.
5. **Security** (Direction 5): The kernel certifies what is *indistinguishable*.

Together, these form a comprehensive research program: **tropical realization theory as a foundation for certified one-way computation**.
