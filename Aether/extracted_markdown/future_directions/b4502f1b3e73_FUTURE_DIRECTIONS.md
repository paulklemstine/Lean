# Future Directions — Ternary Spectral Pseudorandomness

## Overview

This document outlines five breakthrough-level research directions opened by the ternary spectral analysis framework. Each direction includes a precise theorem target, motivation, required definitions, proof strategy, and dependency on the current cycle's results.

---

## Direction 1: Complete Tensor Power Contraction via Product Fourier Basis

### Exact Theorem Target

```
theorem product_fourier_orthonormal_basis (L : ℕ) (ρ : ℝ) :
  ∃ (basis : (Fin L → Fin 3) → ((Fin L → Fin 3) → ℝ)),
    IsOrthonormalBasis basis ∧
    ∀ S, ternaryNoiseOp L ρ (basis S) = (∏ i, eigenvalue (S i) ρ) • basis S
```

### Why It Matters

This is the completion of the one remaining sorry in the current library. The product Fourier basis is the foundational object for all downstream harmonic analysis on {0,1,2}^L, including hypercontractivity, influence theory, and noise stability. Without it, the tensor power contraction theorem relies on an unverified step.

### Required New Definitions

- `ternaryEigenvector : Fin 3 → (Fin 3 → ℝ)` — the three eigenvectors of N_ρ on Fin 3
- `productEigenvector : (Fin L → Fin 3) → ((Fin L → Fin 3) → ℝ)` — tensor products
- `IsOrthonormalBasis` — orthonormality with respect to the uniform inner product

### Proof Strategy

1. Define the 1D eigenbasis explicitly: u₀ = (1,1,1)/√3, u₁ = (1,-1,0)/√2, u₂ = (1,1,-2)/√6
2. Verify orthonormality by computation (fin_cases)
3. Build product eigenvectors by pointwise multiplication
4. Prove they diagonalize the tensor power operator by coordinate independence
5. Apply Parseval's identity to conclude the contraction

### Dependency

Directly completes `ternary_tensor_power_L2_contraction` from this cycle.

---

## Direction 2: Sharp Beckner Inequality for q-ary Product Spaces

### Exact Theorem Target

```
theorem qary_hypercontractive (q : ℕ) (hq : 2 ≤ q) (L : ℕ) (ρ : ℝ)
    (hρ : ρ ^ 2 ≤ 1 / 3) (f : (Fin L → Fin q) → ℝ) :
    finLpNorm 4 (noiseOp q L ρ f) ≤ finLpNorm 2 f
```

### Why It Matters

The (2,4)-hypercontractive inequality is the gateway to small-set expansion, influence bounds, and invariance principles on non-Boolean domains. The threshold ρ ≤ 1/√3 is universal across all alphabet sizes, a deep structural fact that the current framework positions us to prove.

### Required New Definitions

- `finLpNorm (p : ℝ) (f : α → ℝ) : ℝ` — finite Lp norm for general p
- `noiseOp (q L : ℕ) (ρ : ℝ)` — generalized noise operator for q-ary alphabets
- Level-k Fourier decomposition for q-ary functions

### Proof Strategy

**Strategy C (combinatorial moment method):** Expand ‖N_ρ f‖₄⁴ as a sum over quadruples, use coordinate independence and orthogonality relations to annihilate mixed terms, and bound surviving terms using ρ² ≤ 1/3.

Alternative: **Strategy B (semigroup interpolation)** using the log-Sobolev inequality on the q-ary noise chain, which tensorizes by the Gross-Rothaus theorem.

### Dependency

Requires the product Fourier basis (Direction 1) for the clean level-by-level argument.

---

## Direction 3: Influence Theory and KKL on {0,1,2}^L

### Exact Theorem Target

```
theorem ternary_KKL (L : ℕ) (f : (Fin L → Fin 3) → ℝ) (hf : IsMeanZero f) :
    ∃ i : Fin L, influence i f ≥ finL2NormSq f * C / L
```

where `influence i f = ∑_{x : Fin L → Fin 3} Var_{x_i}(f(x))` and C is an explicit constant.

### Why It Matters

The KKL theorem is one of the most influential results in combinatorics, establishing that balanced Boolean functions must have an influential coordinate. A ternary analogue would extend this to 3-coloring problems, cap set analysis, and social choice on three alternatives.

### Required New Definitions

- `influence (i : Fin L) (f : (Fin L → Fin 3) → ℝ) : ℝ`
- `totalInfluence (f : (Fin L → Fin 3) → ℝ) : ℝ`
- Fourier weight at level k

### Proof Strategy

Use the hypercontractive inequality (Direction 2) to prove a level-k Fourier concentration bound, then deduce the influence inequality by the standard KKL argument with the noise operator semigroup.

### Dependency

Requires hypercontractivity (Direction 2) and the product Fourier basis (Direction 1).

---

## Direction 4: Certified Extractor Families with Explicit Output Length

### Exact Theorem Target

```
theorem ternary_extractor_family (L : ℕ) (k : ℝ) (ε : ℝ) (hε : 0 < ε) :
    ∃ (m : ℕ) (Ext : (Fin L → Fin 3) → Fin m → Bool),
      m ≥ k - 2 * Real.log (1/ε) / Real.log 2 ∧
      ∀ μ, minEntropy μ ≥ k →
        totalVariationDist (pushforward Ext μ) (uniformDist (Fin m → Bool)) ≤ ε
```

### Why It Matters

This would be the first formally verified multi-bit extractor for ternary sources with explicit output length bounds. The construction connects spectral contraction to information-theoretic extraction parameters.

### Required New Definitions

- `minEntropy` for PMF-style distributions
- `pushforward` of a distribution through a function
- Explicit hash function construction (e.g., inner product extractor mod 2)

### Proof Strategy

1. Use spectral smoothing to show N_ρ μ has bounded collision probability
2. Apply leftover hash lemma (formalize for finite groups)
3. Combine to get TV bound on extracted bits
4. Optimize ρ to maximize output length

### Dependency

Requires tensor power contraction (this cycle) and collision probability bounds (this cycle).

---

## Direction 5: Expansion in Thin Arithmetic Group Quotients

### Exact Theorem Target

```
theorem apollonian_quotient_expander (N : ℕ) (hN : 2 ≤ N) :
    ∃ (G : SimpleGraph (ApollonianOrbit N)) (δ : ℝ),
      0 < δ ∧ IsExpander G δ
```

### Why It Matters

Proving expansion for Apollonian group quotients would connect the spectral framework to deep questions in arithmetic dynamics and thin groups. The Bourgain-Gamburd-Sarnak program has established such expansion results non-constructively; a formal certificate would be a significant advance.

### Required New Definitions

- `ApollonianOrbit (N : ℕ)` — orbits of the Apollonian group action mod N
- `ApollonianGenerator` — the four generators of the Apollonian group
- `IsExpander (G : SimpleGraph α) (δ : ℝ)` — expansion property

### Proof Strategy

For small N (N = 2, 3, 5, 7), construct the Cayley graph explicitly, compute its adjacency matrix, and verify the spectral gap computationally (using `native_decide` or explicit matrix eigenvalue bounds). For general N, use the Selberg property and representation-theoretic methods.

### Dependency

Extends the Apollonian gap certificate from this cycle. Uses spectral gap structures and the MarkovSpectralGap interface.

---

## Implementation Priorities

| Priority | Direction | Estimated Effort | Impact |
|----------|-----------|-----------------|--------|
| 1 (next cycle) | Direction 1: Product Fourier Basis | Medium | Completes the library foundation |
| 2 | Direction 4: Extractor Families | Medium | Highest applied impact |
| 3 | Direction 2: Hypercontractivity | High | Deepest mathematical content |
| 4 | Direction 3: KKL Theory | High | Broadest combinatorial reach |
| 5 | Direction 5: Apollonian Expansion | Very High | Most ambitious number theory |

---

## Cross-Domain Research Opportunities

Each direction connects to neighboring fields:

1. **Machine learning**: Spectral extractors can certify privacy-preserving randomness in federated learning
2. **Cryptography**: Ternary extractors support post-quantum key generation from physical sources
3. **Coding theory**: Hypercontractivity on 𝔽₃^n yields list-decoding bounds for ternary codes
4. **Statistical mechanics**: Noise sensitivity analysis describes phase transitions in 3-state Potts models
5. **Computational complexity**: Influence bounds on {0,1,2}^L extend PCP constructions to ternary verifiers
