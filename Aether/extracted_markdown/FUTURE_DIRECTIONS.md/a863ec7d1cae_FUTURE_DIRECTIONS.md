# Future Directions: q-ary Information Theory and Tropical Coding

## Overview

This document outlines five concrete breakthrough research directions opened by the formally verified q-ary source coding theorem suite. Each direction includes specific theorem targets, proof strategies, cross-domain connections, and estimated complexity.

---

## Direction 1: q-ary Huffman Optimality Formalization

### Hypothesis
The q-ary Huffman algorithm produces a prefix-free code with minimum expected length among all q-ary prefix codes.

### Specific Theorem Target
```
theorem qary_huffman_optimal
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_pos : ∀ a, 0 < p a) (hp_sum : ∑ a, p a = 1)
    (ℓ_huff : α → ℕ)
    (h_huffman : IsQaryHuffmanCode q p ℓ_huff)
    (ℓ : α → ℕ)
    (h_kraft : ∑ a, (q : ℝ) ^ (-(ℓ a : ℝ)) ≤ 1) :
    ∑ a, p a * (ℓ_huff a : ℝ) ≤ ∑ a, p a * (ℓ a : ℝ)
```

### Proof Strategy
1. Define the q-ary Huffman algorithm as an inductive construction on finite types.
2. For q > 2, handle the padding issue: (n-1) mod (q-1) must equal 0 by adding zero-probability dummy symbols.
3. Prove optimality via the sibling property: in an optimal code, the q least probable symbols share a parent and differ only in the last symbol.
4. Use strong induction on alphabet size, reducing by (q-1) symbols per Huffman merge step.

### Cross-Domain Connections
- Connects to tropical tree combinatorics (q-ary tree structures)
- Generalizes binary Huffman (which already has partial Mathlib coverage via `PrefixCode`)
- Applications to multi-resolution quantization in signal processing

### Estimated Complexity
High. Requires formalizing the Huffman tree construction, proving the sibling lemma, and handling the q-ary padding edge case.

---

## Direction 2: q-ary Mutual Information and Data Processing Inequality

### Hypothesis
For a Markov chain X → Y → Z over finite alphabets, the q-ary mutual information satisfies I_q(X;Z) ≤ I_q(X;Y).

### Specific Theorem Targets

**Target 2a: Non-negativity of mutual information**
```
theorem qary_mutual_info_nonneg
    {α β : Type*} [Fintype α] [Fintype β]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (K : α → β → ℝ)
    (hp_pos : ∀ a, 0 < p a) (hp_sum : ∑ a, p a = 1)
    (hK_nonneg : ∀ a b, 0 ≤ K a b) (hK_stoch : ∀ a, ∑ b, K a b = 1) :
    0 ≤ qaryMutualInfo q p K
```

**Target 2b: Data processing inequality**
```
theorem qary_data_processing
    {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (K₁ : α → β → ℝ) (K₂ : β → γ → ℝ)
    ... :
    qaryMutualInfo q p (channelComp K₁ K₂) ≤ qaryMutualInfo q p K₁
```

### Proof Strategy
1. Express I_q(X;Y) = D_{KL,q}(p_{XY} || p_X ⊗ p_Y) using the q-ary KL divergence.
2. Non-negativity follows from the Gibbs inequality (already proved for q-ary case).
3. Data processing: use the log-sum inequality and the chain rule for KL divergence.
4. The key technical step is showing that marginalizing a joint distribution cannot increase divergence from the product distribution.

### Cross-Domain Connections
- Direct applications to channel capacity computation for non-binary channels
- Connects to the tropical DPI already sketched in the codebase (`tropicalCondEntropy`)
- Foundation for q-ary rate-distortion theory

### Estimated Complexity
Medium-high. The Gibbs inequality infrastructure is already in place; the main challenge is formalizing the chain rule and marginalization properties.

---

## Direction 3: Tropical Rate-Distortion Theorem

### Hypothesis
The minimum achievable q-ary description rate at distortion level D satisfies a variational formula involving q-ary mutual information minimized over test channels.

### Specific Theorem Target
```
theorem qary_rate_distortion_lower
    {α β : Type*} [Fintype α] [Fintype β]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (d : α → β → ℝ) (D : ℝ)
    (hp_pos : ∀ a, 0 < p a) (hp_sum : ∑ a, p a = 1) :
    ∀ (K : α → β → ℝ),
      (∀ a b, 0 ≤ K a b) →
      (∀ a, ∑ b, K a b = 1) →
      (∑ a, ∑ b, p a * K a b * d a b ≤ D) →
      qaryMutualInfo q p K ≤ qaryRateDistortion q p d D
```

### Proof Strategy
1. Define the rate-distortion function R_q(D) = inf_{K : E[d] ≤ D} I_q(X;Y).
2. Prove that R_q(D) is convex and non-increasing in D.
3. The tropical limit (D → 0, q → ∞) should recover a tropical rate-distortion function.
4. Use the Gibbs inequality and Lagrange multiplier techniques from the relaxed optimizer proof.

### Cross-Domain Connections
- Connects to lossy compression for DNA storage (practical rate-distortion for q = 4)
- The tropical limit R_∞(D) relates to the existing `tropicalEntropy` definition
- Applications to quantization theory for multi-level cells

### Estimated Complexity
High. Requires formalizing conditional mutual information, the infimum over channels, and convexity arguments.

---

## Direction 4: Coding-Theoretic Interpretation of Multi-Class Tropical Robustness

### Hypothesis
The certified robustness margin in multi-class tropical neural networks can be interpreted as a q-ary coding slack, where q equals the number of classes and the margin gap equals the redundancy E[ℓ] - H_q(p).

### Specific Theorem Target
```
theorem tropical_robustness_as_coding_slack
    {α : Type*} [Fintype α] (n_classes : ℕ) (hn : 2 ≤ n_classes)
    (logits : α → ℝ) (p : α → ℝ)
    (hp : IsSoftmax logits p) :
    certifiedRadius logits ≥ 
      (∑ a, p a * ↑(shannonLength n_classes p a)) - qaryEntropy n_classes p
```

### Proof Strategy
1. Observe that softmax probabilities define a distribution p over classes.
2. The certified robustness radius is determined by the gap between the top-1 and top-2 logits.
3. Express this gap in terms of q-ary information: the margin is related to the "information advantage" of the correct class.
4. Use the Shannon upper bound (E[ℓ] < H_q + 1) to bound the maximum achievable margin from below.

### Cross-Domain Connections
- Directly extends `multi_class_tropical_certified_robustness` from the codebase
- Connects adversarial robustness to source coding theory
- Applications to certified defenses in q-class classification problems

### Estimated Complexity
Medium. Requires formalizing the softmax → probability distribution connection and the relationship between logit gaps and coding redundancy.

---

## Direction 5: Variational Tropical Free-Energy Formalism

### Hypothesis
The relaxed coding optimizer L*(a) = log_q(1/p(a)) is a Gibbs state that minimizes a tropical free energy functional, connecting source coding to statistical mechanics via a formal Legendre duality.

### Specific Theorem Targets

**Target 5a: Free energy characterization**
```
theorem coding_free_energy_minimizer
    {α : Type*} [Fintype α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_pos : ∀ a, 0 < p a) (hp_sum : ∑ a, p a = 1)
    (β : ℝ) (hβ : β > 0) :
    let F := fun (L : α → ℝ) => ∑ a, p a * L a + β⁻¹ * Real.log (∑ a, q ^ (-L a))
    IsMinOn F {L | True} (fun a => Real.logb q (1 / p a))
```

**Target 5b: Legendre duality**
```
theorem coding_legendre_duality
    {α : Type*} [Fintype α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_pos : ∀ a, 0 < p a) (hp_sum : ∑ a, p a = 1) :
    qaryEntropy q p = 
      ⨆ (L : α → ℝ), (∑ a, p a * L a - Real.logb q (∑ a, q ^ (-L a)))
```

### Proof Strategy
1. Formulate the coding problem as a variational principle: minimize E_p[L] subject to ∑ q^{-L} ≤ 1.
2. Introduce a Lagrange multiplier β for the constraint.
3. Show that the KKT conditions yield L*(a) = log_q(1/p(a)) with β = 1/(log q).
4. Verify that the Legendre transform of the log-partition function log(∑ q^{-L}) gives the entropy.

### Cross-Domain Connections
- Connects to `tropicalPartitionFunction` and `boltzmannDist` in the existing codebase
- The tropical limit β → ∞ recovers the tropical entropy as a ground-state energy
- Applications to thermodynamic computing and free-energy-based neural architectures
- Links to the existing `tropical_spectral_bound` via spectral/variational duality

### Estimated Complexity
High. Requires convex analysis infrastructure (Legendre transforms, KKT conditions) that may need to be built from scratch.

---

## Team Structure Recommendations

### Phase 1 (Immediate): Direction 2 — Mutual Information
- **Estimated effort:** 2-3 research cycles
- **Prerequisites:** q-ary source coding (completed)
- **Key risk:** Chain rule formalization

### Phase 2 (Near-term): Direction 1 — Huffman Optimality
- **Estimated effort:** 3-4 research cycles
- **Prerequisites:** Direction 2 (for comparison theorems)
- **Key risk:** Inductive tree construction

### Phase 3 (Medium-term): Direction 4 — Robustness Connection
- **Estimated effort:** 2-3 research cycles
- **Prerequisites:** Directions 1-2
- **Key risk:** Softmax formalization

### Phase 4 (Long-term): Directions 3 and 5 — Rate-Distortion and Free Energy
- **Estimated effort:** 4-6 research cycles each
- **Prerequisites:** All of above
- **Key risk:** Missing convex analysis infrastructure in Mathlib

---

## Success Metrics

1. **Zero sorry count** in all formalized theorems
2. **Standard axioms only** (propext, Classical.choice, Quot.sound)
3. **Binary specialization test:** Every q-ary theorem recovers the binary case at q = 2
4. **Cross-reference count:** Each new theorem should cite ≥ 2 existing catalog theorems
5. **Application coverage:** Each direction should have ≥ 1 concrete numerical example demonstrating the theorem
