# Future Directions: Tropical Residuation Trapdoor Duality

## Overview

This document outlines five breakthrough-level research directions that build directly on the formalized theory of tropical residuation trapdoor duality. Each direction includes specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Green-Relation Cryptography

### Goal
Classify cryptographic hardness of tropical matrix inversion via Green's relations (L, R, J, H, D) for the tropical matrix semigroup. Green's relations capture reachability under left/right/two-sided multiplication — precisely the structure that controls trapdoor ambiguity.

### Key Theorem Targets

```
theorem green_L_class_fiber_bound {n K : ℕ} (A B Z : TropMat n) :
  -- The number of distinct L-classes in a fiber grows polynomially in K
  ∃ c : ℕ, fiber_L_class_count A B Z K ≤ c * K ^ (n - 1)

theorem green_J_class_determines_spectrum {n : ℕ} (X Y : TropMat n) :
  -- Matrices in the same J-class have the same residuation spectrum
  sameJClass X Y → residuationSpectrum X = residuationSpectrum Y

theorem green_H_class_singleton_iff_invertible {n : ℕ} (X : TropMat n) :
  -- H-class is a singleton iff the matrix is "tropically invertible"
  HClassSingleton X ↔ TropicallyInvertible X
```

### Proof Strategy
Define Green's relations over the tropical matrix semigroup using the witness-based residuation (`resLe`) as the foundation. L-equivalence is `∃ L, X = tropMul L Y ∧ ∃ L', Y = tropMul L' X`, and similarly for R. Show that the compression profile (row/column minima) is an L-class invariant, and the residuation spectrum is a J-class invariant. Use `rowMins_tropMul` to transfer L-class invariance through the functoriality of row minima.

### Cross-Domain Impact
- **Semigroup theory**: First formal connection between Green's relations and cryptographic security
- **Complexity theory**: J-class structure may yield polynomial-time distinguishers for tropically invertible matrices
- **Quantum computing**: Green's relation structure is preserved under tropical tensor products, potentially yielding quantum-resistant classification

---

## Direction 2: Entropy of Tropical Fibers

### Goal
Define and prove lower bounds for a tropical fiber entropy invariant that quantifies the structural ambiguity in inverse fibers. This transforms the "fiber is large" statement into a quantitative information-theoretic measure.

### Key Theorem Targets

```
theorem fiber_entropy_linear_growth {n : ℕ} (hn : 2 ≤ n) :
  -- Fiber entropy grows at least linearly in the bound parameter K
  ∃ c > 0, ∀ K : ℕ, K ≥ 1 →
    fiberEntropy (constMat 0) (constMat 0) (constMat 0 : TropMat n) K ≥ c * K

theorem fiber_entropy_superlinear_generic {n : ℕ} (hn : 3 ≤ n) :
  -- For generic public keys, fiber entropy grows superlinearly
  ∃ A B : TropMat n, ∀ K : ℕ, K ≥ 1 →
    fiberEntropy A B (publicMap A B (constMat 0)) K ≥ K * (n - 1)

theorem entropy_monotone_under_composition {n : ℕ} :
  -- Composing public maps cannot decrease fiber entropy
  fiberEntropy A₁ B₁ Z₁ K ≤ fiberEntropy A₂ B₂ Z₂ K →
  -- when Z₂ is in the image of Z₁ under a further public map
  (∃ C D, publicMap C D Z₁ = Z₂) →
  fiberEntropy (tropMul A₂ (tropMul C A₁)) (tropMul B₁ (tropMul D B₂)) Z₂ K ≥
    fiberEntropy A₁ B₁ Z₁ K
```

### Proof Strategy
Define `fiberEntropy A B Z K := log₂(|{X : boundedEntries K X ∧ publicMap A B X = Z}|)`. For the zero-matrix case, enumerate the fiber explicitly using the global-minimum characterization (`publicMap_zero_eq_globalMin`). The fiber consists of all bounded matrices with global minimum equal to a fixed value, which can be counted combinatorially. For the generic case, use the compression profile functoriality to decompose the fiber by compression class, then count within each class.

### Cross-Domain Impact
- **Information theory**: First rigorous definition of "tropical information loss" in a cryptographic context
- **Statistical physics**: Fiber entropy is analogous to configurational entropy in tropical statistical mechanics
- **Coding theory**: Bounds on fiber entropy translate to bounds on list-decoding capacity for tropical codes

---

## Direction 3: Chosen-Ciphertext Stability of Tropical Signatures

### Goal
Prove that the public signature (compression profile + residuation spectrum) remains stable under bounded perturbations of the input, establishing certified robustness of the tropical cryptographic scheme against adaptive chosen-ciphertext attacks.

### Key Theorem Targets

```
theorem signature_lipschitz {n : ℕ} [NeZero n] (X Y : TropMat n) :
  -- Signature difference is bounded by entry-wise distance
  signatureDistance (signature X) (signature Y) ≤ 2 * tropDist X Y

theorem publicMap_perturbation_bound {n : ℕ} [NeZero n] (A B X δ : TropMat n) :
  -- Perturbing X by δ changes the output by at most 2·max|δ|
  tropDist (publicMap A B X) (publicMap A B (fun i j => X i j + δ i j)) ≤
    2 * Finset.univ.sup' Finset.univ_nonempty (fun i =>
      Finset.univ.sup' Finset.univ_nonempty (fun j => |δ i j|))

theorem cca_stability {n : ℕ} [NeZero n] (A B X : TropMat n) (ε : ℤ) :
  -- If the adversary perturbs by ≤ ε, the spectrum changes by ≤ 2ε
  ∀ Y, tropDist X Y ≤ ε →
    spectrumHausdorff (residuationSpectrum (publicMap A B X))
                      (residuationSpectrum (publicMap A B Y)) ≤ 2 * ε
```

### Proof Strategy
Use the monotonicity theorem `publicMap_mono` to establish that small perturbations in the tropical ordering translate to small perturbations in the image. Define `tropDist X Y := max_{i,j} |X_{ij} - Y_{ij}|` and show it is a metric. Then use `tropMul_mono_right` and `tropMul_mono_left` to bound the entry-wise change in the public map output. The spectrum stability follows from the row-min functoriality: `rowMins_tropMul` shows that row minima change by at most `tropDist`, and the gaps X_{ij} - rowMins(X, i) change by at most 2·tropDist.

### Cross-Domain Impact
- **Post-quantum cryptography**: First stability theorem for a tropical cryptographic scheme
- **Adversarial machine learning**: The Lipschitz bound can certify robustness of tropical neural network classifiers
- **Signal processing**: Stability under perturbation is essential for tropical filter design

---

## Direction 4: Tropical Zero-Knowledge Proofs via Residuation Class Membership

### Goal
Prove that membership in a residuation class admits a succinct certificate that reveals no information about the specific representative matrix, establishing a tropical zero-knowledge protocol.

### Key Theorem Targets

```
theorem class_membership_certificate_exists {n : ℕ} (X Y : TropMat n) :
  -- If X and Y are in the same class, there exists a short certificate
  sameResiduationClass X Y →
  ∃ cert : ClassCertificate n, verifyCertificate cert X Y ∧ certSize cert ≤ 2 * n^2

theorem certificate_hides_representative {n : ℕ} (X₁ X₂ Y : TropMat n) :
  -- Certificates for X₁∼Y and X₂∼Y are indistinguishable
  sameResiduationClass X₁ Y → sameResiduationClass X₂ Y →
  sameResiduationClass X₁ X₂ →
  ∀ cert₁ cert₂, verifyCertificate cert₁ X₁ Y → verifyCertificate cert₂ X₂ Y →
    certificateDistribution cert₁ = certificateDistribution cert₂

theorem zkp_soundness {n : ℕ} (X Y : TropMat n) :
  -- A valid certificate implies class membership
  ∀ cert, verifyCertificate cert X Y → sameResiduationClass X Y
```

### Proof Strategy
The certificate is the pair (L, R) witnessing `X = tropMul (tropMul L Y) R`. Verification is checking this equation. Soundness is trivial. For zero-knowledge, show that the distribution of valid (L, R) pairs depends only on the residuation class, not on the specific representative. Use `resLe_trans` to show that certificates compose: if cert₁ witnesses X₁ from Y and cert₂ witnesses X₂ from Y, then they can be combined to witness X₁ from X₂ (and vice versa).

### Cross-Domain Impact
- **Cryptographic protocols**: First zero-knowledge proof system based on tropical algebra
- **Blockchain**: Tropical ZK proofs could enable privacy-preserving tropical computations
- **Secure computation**: Class membership certificates enable verifiable tropical delegation

---

## Direction 5: Functorial Cryptanalysis — When Valuations Preserve or Destroy Hardness

### Goal
Characterize exactly which valuation functors (homomorphisms from multiplicative to tropical algebra) preserve the one-wayness of tropical public maps, and which destroy it by collapsing too many residuation classes.

### Key Theorem Targets

```
theorem valuation_preserves_fiber_structure {n : ℕ} (v : ℤ → ℤ)
    (hv_add : ∀ a b, v (a + b) = v a + v b) :
  -- Additive valuations preserve fiber ambiguity
  FiberCollapseWitness A B Z K →
  FiberCollapseWitness (v ∘ A) (v ∘ B) (v ∘ Z) K'

theorem linear_valuation_destroys_spectrum {n : ℕ} :
  -- The identity valuation (v = id) preserves spectrum fully
  -- but constant valuations collapse all spectra
  (∀ X : TropMat n, residuationSpectrum (constValuation X) = trivialSpectrum n)

theorem optimal_valuation_dimension {n : ℕ} :
  -- The minimal dimension of a valuation that preserves all class distinctions
  -- is exactly n² - n + 1
  minPreservingDimension n = n^2 - n + 1
```

### Proof Strategy
A valuation v : ℤ → ℤ induces a map on tropical matrices entry-wise. If v is additive (a group homomorphism), then it commutes with tropical multiplication: `v(min_k(A_{ik} + B_{kj})) = min_k(v(A_{ik}) + v(B_{kj}))` when v preserves order. Use `tropMul_assoc` and the functoriality of row minima to show that the compression profile transforms covariantly under such valuations. The dimension bound comes from counting the degrees of freedom in the residuation spectrum (n² entries minus n row-minimum normalizations, plus 1 for the global level).

### Cross-Domain Impact
- **Number theory**: p-adic valuations are the canonical example; this theory classifies which number-theoretic structures are "cryptographically useful" in the tropical world
- **Algebraic geometry**: Valuations are tropicalization maps; this characterizes when tropicalization preserves cryptographic hardness
- **Complexity theory**: Valuation dimension bounds translate to circuit complexity lower bounds for tropical inversion

---

## Implementation Priorities

1. **Direction 2** (Fiber Entropy) — Most directly builds on `inverse_fiber_nontrivial` and `publicMap_zero_eq_globalMin`. Can be started immediately with combinatorial enumeration arguments.

2. **Direction 3** (CCA Stability) — Builds on `publicMap_mono` and `rowMins_tropMul`. Requires defining a tropical metric but the monotonicity infrastructure is already in place.

3. **Direction 1** (Green's Relations) — Builds on `resLe_trans` and `sameResiduationClass_trans`. Requires significant new definitions but the algebraic foundation is solid.

4. **Direction 4** (Zero-Knowledge) — Most speculative but highest potential impact. Requires formalizing certificate structures and distribution equivalence.

5. **Direction 5** (Functorial Cryptanalysis) — Most abstract. Best approached after Directions 1-3 establish the structural vocabulary.

---

## Cross-Cutting Themes

All five directions share a common architecture:
- **Structure over computation**: Hardness is proved via algebraic/order-theoretic collapse, not computational complexity assumptions
- **Functoriality**: Every invariant transforms predictably under the public map, enabling compositional security proofs
- **Certified verification**: All results target machine-checked proofs, eliminating the gap between cryptographic claims and mathematical truth

This program, if completed, would establish **tropical algebra as the first post-quantum cryptographic framework with machine-verified structural security guarantees**.
