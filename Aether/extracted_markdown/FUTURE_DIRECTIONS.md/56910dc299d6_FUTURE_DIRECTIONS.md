# Future Research Directions: Tropical γ-Spreadness and Post-Quantum Cryptography

## Overview

This document outlines specific, actionable research directions opened by our formalization of tropical γ-spreadness and KEM security. Each direction includes theorem statements, proof strategies, and cross-domain connections.

---

## Direction 1: Tight Concrete Security Bounds for Tropical Matrix Decomposition

### Hypothesis
The Tropical Matrix Decomposition Problem (TMDP) for n×n matrices with entries in {0, ..., B-1} requires Ω(B^{n/2}) operations in the worst case.

### Theorem Statements to Prove

```lean
/-- Lower bound on TMDP complexity: exponential in dimension. -/
theorem tmdp_complexity_lower_bound (n B : ℕ) (hn : 4 ≤ n) (hB : 2 ≤ B) :
    ∃ (G : TropMat n), ∀ (algorithm : TropMat n → ℕ),
      (algorithm (G ^ (algorithm (G ^ 0))) = 0) →
      ∃ (steps : ℕ), B ^ (n / 2) ≤ steps := by sorry
```

### Proof Strategy
- Construct explicit "hard" generator matrices using random tropical polynomials
- Use counting arguments: the number of possible secret exponents is B, while the search space has B^(n²) matrices
- Connect to the tropical Nullstellensatz for lower bounds on system solving

### Cross-Domain Connections
- **Complexity Theory**: Relates to circuit lower bounds for tropical circuits
- **Optimization**: Connects to hardness of shortest-path reconstruction
- **Lattice Theory**: May yield new reductions to known hard lattice problems

---

## Direction 2: Rényi Entropy Spreadness and Tighter FO Reductions

### Hypothesis
Tropical ciphertexts satisfy not just min-entropy spreadness but also Rényi entropy bounds of all orders α > 1, enabling tighter FO reductions.

### Theorem Statements

```lean
/-- Rényi entropy of order α for the tropical ciphertext distribution. -/
theorem tropical_renyi_spread (B : ℕ) (hB : 1 < B) (α : ℝ) (hα : 1 < α) :
    (1 / (1 - α)) * Real.log (B * (1 / B) ^ α) ≥ Real.logb 2 B := by sorry

/-- Tighter FO bound using Rényi entropy. -/
theorem fo_renyi_tighter (ε_cpa : ℝ) (γ₂ : ℝ) (q_dec : ℕ)
    (hε : 0 ≤ ε_cpa) (hγ : 0 < γ₂) :
    ε_cpa + q_dec * (2 : ℝ) ^ (-γ₂ / 2) ≥ 0 := by sorry
```

### Proof Strategy
- For uniform distributions, all Rényi entropies equal log₂(B)
- The key insight is that non-uniform tropical distributions (from structured generators) may have different Rényi vs min-entropy, requiring careful analysis
- Use the existing `uniform_gamma_spread` as a base case

### Cross-Domain Connections
- **Information Theory**: Connects to source coding and compression bounds
- **Quantum Information**: Rényi entropy appears in quantum state discrimination
- **Statistics**: Relates to hypothesis testing power

---

## Direction 3: Tropical Lattice Reduction and Kannan-Style Enumeration

### Hypothesis
The tropical analogue of LLL lattice reduction can solve TMDP for small dimensions (n ≤ 6) but fails for n ≥ 8 due to the absence of additive inverses.

### Theorem Statements

```lean
/-- Tropical analogue of LLL basis reduction. -/
structure TropicalReducedBasis (n : ℕ) where
  basis : Fin n → Fin n → TropInt
  reduced : ∀ i j : Fin n, i < j →
    tropNorm (basis i) ≤ 2 * tropNorm (basis j)

/-- LLL-type reduction does not apply to tropical semirings. -/
theorem tropical_no_lll (n : ℕ) (hn : 8 ≤ n) :
    ¬ ∀ (M : TropMat n), ∃ (R : TropicalReducedBasis n),
      ∀ i, tropNorm (R.basis i) ≤ tropNorm (M i) := by sorry
```

### Proof Strategy
- Construct explicit matrices where no basis reduction is possible
- Use the tropical Nullstellensatz: the lack of additive inverses prevents Gram-Schmidt orthogonalization
- Connect to known NP-hardness results for tropical optimization

### Cross-Domain Connections
- **Cryptanalysis**: Direct impact on parameter selection
- **Convex Optimization**: Tropical convexity vs classical convexity
- **Algebraic Geometry**: Tropical varieties and Gröbner fans

---

## Direction 4: Hybrid Tropical-Lattice KEM

### Hypothesis
A hybrid KEM combining tropical and lattice hardness provides security even if one of the two underlying problems is broken.

### Theorem Statements

```lean
/-- Hybrid KEM: security is the minimum of the two component securities. -/
theorem hybrid_kem_security (ε_trop ε_lwe : ℝ) (hT : 0 ≤ ε_trop) (hL : 0 ≤ ε_lwe) :
    min ε_trop ε_lwe ≤ ε_trop ∧ min ε_trop ε_lwe ≤ ε_lwe := by sorry

/-- Hybrid KEM key agreement is correct if both components are correct. -/
theorem hybrid_kem_correctness :
    ∀ (sk_trop sk_lwe r : ℕ),
      -- Both components agree → hybrid agrees
      True := by sorry
```

### Proof Strategy
- Formalize the combiner: shared_key = H(key_trop || key_lwe) where H is a random oracle
- Security reduction: if adversary breaks hybrid, it must break both components
- Use the existing `fo_cpa_to_cca` for each component separately

### Cross-Domain Connections
- **NIST Standardization**: Hybrid KEMs are of interest for NIST Round 4+
- **Risk Management**: Defense-in-depth against cryptographic breaks
- **Protocol Design**: TLS 1.3 hybrid key exchange

---

## Direction 5: Tropical Circuit Complexity and One-Way Functions

### Hypothesis
The evaluation of tropical matrix powers can be computed by polynomial-size tropical circuits, but inversion requires super-polynomial circuits.

### Theorem Statements

```lean
/-- Forward evaluation: O(n³ log k) tropical operations for G^k. -/
theorem tropical_eval_efficient (n k : ℕ) (hn : 0 < n) (hk : 0 < k) :
    ∃ (circuit_size : ℕ), circuit_size ≤ n ^ 3 * (Nat.log 2 k + 1) := by sorry

/-- Tropical circuit lower bound for inversion. -/
theorem tropical_inversion_hard (n : ℕ) (hn : 10 ≤ n) :
    ∀ (C : ℕ), C < n ^ (n / 4) →
      ¬ ∀ (G : TropMat n) (k : ℕ), k < 2^n →
        -- No size-C circuit inverts the power map
        True := by sorry
```

### Proof Strategy
- Forward direction: formalize repeated squaring (already have `tropical_pow_mul`)
- Inverse direction: use tropical Bézout theorem to lower-bound the number of operations
- Connect to existing `TropicalCircuitLowerBounds` in the catalog

### Cross-Domain Connections
- **Complexity Theory**: P vs NP barrier for tropical circuits
- **Neural Networks**: Tropical circuits = ReLU network layers
- **Optimization**: Tropical polynomial optimization complexity

---

## Direction 6: Certified Robustness via Tropical Spectral Gap

### Hypothesis
The tropical spectral gap of a KEM's generator matrix simultaneously bounds cryptographic security and adversarial robustness of associated neural networks.

### Theorem Statements

```lean
/-- Spectral gap bounds both security and robustness. -/
theorem spectral_gap_dual_bound (G : TropMat n) (Δ : ℝ) (hΔ : 0 < Δ)
    (hgap : tropicalSpectralRadius G ≥ Δ) :
    -- Security: at least n · log₂(Δ) bits
    0 < (n : ℝ) * Real.logb 2 Δ ∧
    -- Robustness: certified radius ≥ margin / (n · Δ)
    ∀ (margin : ℝ), 0 < margin →
      0 < certifiedRobustnessRadius (n * Δ) margin := by sorry
```

### Proof Strategy
- Use existing `pq_security_from_dimension` for security direction
- Use existing `certified_robustness_radius_pos` for robustness direction
- The novel connection is that both bounds depend on the same spectral gap

### Cross-Domain Connections
- **ML Safety**: Adversarial robustness certification
- **Control Theory**: Stability of tropical dynamical systems
- **Statistical Physics**: Tropical partition function and ground states

---

## Direction 7: Quantum Tropical Algorithms and Oracle Separations

### Hypothesis
Grover's algorithm provides at most a quadratic speedup for TMDP, and no quantum algorithm achieves better than O(√B) queries.

### Theorem Statements

```lean
/-- Quantum query lower bound for tropical inversion. -/
theorem quantum_tmdp_lower_bound (B : ℕ) (hB : 2 ≤ B) :
    -- Any quantum algorithm needs Ω(√B) queries
    ∃ (lower : ℕ), lower ≥ Nat.sqrt B ∧
      -- (formalization of query complexity omitted)
      True := by sorry
```

### Proof Strategy
- Use the polynomial method (Beals et al.) for quantum query lower bounds
- The key insight: TMDP has unstructured search character due to the absence of group structure
- Formalize the oracle separation using quantum information theory from the catalog

### Cross-Domain Connections
- **Quantum Computing**: Query complexity separations
- **Physics**: Quantum walk algorithms on tropical graphs
- **Information Theory**: Holevo bound and quantum distinguishability

---

## Priority Ranking

| Priority | Direction | Impact | Feasibility | Dependencies |
|:--------:|:----------|:------:|:-----------:|:------------:|
| 1 | Rényi entropy spreadness | High | High | Current work |
| 2 | Concrete TMDP bounds | Very High | Medium | Tropical Nullstellensatz |
| 3 | Hybrid KEM | High | High | Current work + lattice KEM |
| 4 | Circuit complexity | Very High | Low | Tropical circuit library |
| 5 | Spectral gap duality | Medium | High | Current work |
| 6 | Tropical lattice reduction | High | Medium | Convexity library |
| 7 | Quantum lower bounds | Very High | Low | Quantum query complexity |

---

## Team Structure for Next Cycle

1. **Algebraic Foundations Team**: Directions 2, 6 — extend entropy and spectral analysis
2. **Cryptanalysis Team**: Directions 1, 3 — attack complexity and lattice reduction
3. **Systems Team**: Directions 3, 4 — hybrid KEMs and implementation
4. **Complexity Team**: Directions 5, 7 — circuit bounds and quantum separation
5. **Bridge Team**: Cross-cutting — connect tropical results to ML, physics, optimization

Each team should produce:
- Lean 4 theorem statements (even if sorry'd initially)
- Computational experiments validating conjectures
- Cross-domain connection documentation
