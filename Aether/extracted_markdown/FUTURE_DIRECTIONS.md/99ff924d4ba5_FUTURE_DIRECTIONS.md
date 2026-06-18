# Future Directions: Extensive Complexity Accumulation

This document outlines specific next steps for extending the summation-bound framework formalized in `Bridges/SumBounds.lean`.

---

## 1. Subadditive Horizon Law (Fekete-Type Asymptotics)

**Theorem Statement:**
```lean
theorem subadditive_horizon_law (L : ℕ → ℝ)
    (hL : ∀ T₁ T₂, L (T₁ + T₂) ≤ L T₁ + L T₂)
    (hL_nonneg : ∀ T, 0 ≤ L T) :
    ∃ r : ℝ, Tendsto (fun T => L T / T) atTop (𝓝 r)
```

**Proof Strategy:**
Apply Fekete's subadditive lemma: if `L` is subadditive and nonneg, then `L(T)/T` converges to `inf { L(n)/n | n ≥ 1 }`. The proof proceeds by showing the sequence `L(n)/n` is eventually bounded below, then using the subadditivity to show it is a Cauchy sequence. Mathlib's `Filter.Tendsto` and `Real.iInf` machinery should suffice.

**Cross-Domain Connection:**
This connects entropy rates in information theory (Shannon's theorem on the limit of `H(X₁,...,Xₙ)/n`) to amortized complexity in algorithm analysis and to the thermodynamic limit in statistical mechanics where extensive free energy per particle converges.

---

## 2. Weighted / Non-Uniform Extensive Bounds

**Theorem Statement:**
```lean
theorem weighted_extensive_bound
    (T : ℕ) (ℓ w : ℕ → ℝ)
    (h : ∀ t < T, ℓ t ≤ w t) :
    ∑ t in Finset.range T, ℓ t ≤ ∑ t in Finset.range T, w t
```

Already captured by our pointwise comparison, but the interesting extension is:

```lean
theorem weighted_average_bound
    (T : ℕ) (hT : 0 < T) (ℓ w : ℕ → ℝ)
    (h : ∀ t < T, ℓ t ≤ w t) :
    (∑ t in Finset.range T, ℓ t) / T ≤ (∑ t in Finset.range T, w t) / T
```

**Proof Strategy:**
Divide both sides of the pointwise sum comparison by `T` (using `div_le_div_of_nonneg_right`). The key lemma is monotonicity of division by a positive constant.

**Cross-Domain Connection:**
Models nonstationary coding (time-varying channel capacity), energy budgets in physics (varying Hamiltonian), and adaptive learning rates in ML where per-step cost varies but remains controlled.

---

## 3. Asymptotic Average-Length Theorem

**Theorem Statement:**
```lean
theorem average_length_bound
    (T : ℕ) (hT : 0 < T) (C : ℝ) (ℓ : ℕ → ℝ)
    (hℓ : ∀ t < T, ℓ t ≤ C) :
    (∑ t in Finset.range T, ℓ t) / T ≤ C
```

**Proof Strategy:**
From `total_real_length_le_horizon_mul_bound`, we have `∑ ℓ ≤ T * C`. Dividing by `T > 0` gives `(∑ ℓ)/T ≤ C`. Use `div_le_iff` and the horizon bound.

**Cross-Domain Connection:**
- Information theory: Shannon entropy rate as the limit of average code length
- Amortized analysis: average cost per operation bounded by worst-case
- Persistence: average barcode lifetime bounded by maximum feature lifetime
- ML: average per-sample certification cost

---

## 4. Tropical Semiring Analogue (Max-Plus Composition)

**Theorem Statement:**
```lean
theorem tropical_max_bound
    (T : ℕ) (C : ℝ) (ℓ : ℕ → ℝ)
    (hℓ : ∀ t < T, ℓ t ≤ C)
    (hT : 0 < T) :
    Finset.sup' (Finset.range T) (by positivity) ℓ ≤ C
```

**Proof Strategy:**
Use `Finset.sup'_le` and the pointwise bound. The tropical (max-plus) version says that if each component is bounded, the max is bounded — a different but complementary extensivity principle.

**Cross-Domain Connection:**
- Tropical geometry: bounds on valuations under composition
- Shortest-path problems: max edge weight bounds total path weight
- Neural networks: max activation bound across layers
- Proof complexity: max proof-step length bounds

---

## 5. Matrix/Network Complexity Accumulation

**Theorem Statement:**
```lean
theorem layerwise_complexity_bound
    (L : ℕ) (d : ℕ) (cost : Fin L → ℕ) (C : ℕ)
    (hC : ∀ l, cost l ≤ C) :
    ∑ l : Fin L, cost l ≤ L * C
```

**Proof Strategy:**
Convert `Fin L` sum to `Finset.range L` sum via `Finset.sum_fin_eq_sum_range`, then apply `total_length_le_horizon_mul_bound`.

**Cross-Domain Connection:**
- Neural network verification: per-layer certificate cost → total verification budget
- Matrix factorization: per-factor complexity → total decomposition cost
- Categorical compositionality: per-morphism description length → total diagram complexity
- Circuit complexity: per-gate cost → total circuit size

---

## Research Team Organization

### Team A: Foundations
- Formalize Fekete's subadditive lemma in full generality
- Extend to superadditive sequences (dual bounds)
- Connect to Mathlib's `Filter.Tendsto` and `asymptotics` libraries

### Team B: Applications
- Instantiate against specific coding theorems (Huffman, arithmetic coding)
- Apply to neural network verification pipelines
- Connect to persistent homology computation bounds

### Team C: Generalizations
- Tropical/idempotent semiring versions
- Categorical formulation (functorial complexity measures)
- Quantum information analogues (entanglement accumulation)

Each team should maintain a shared Lean library of reusable lemmas, with the summation bounds from `Bridges/SumBounds.lean` as the foundation.
