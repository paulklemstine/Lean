# Future Directions: Tropical Information Theory

This document outlines concrete next steps for extending the tropical information theory foundations established in this work. Each direction includes precise theorem statements, proof strategies, and cross-domain significance.

---

## 1. Tropical Channel Capacity

**Goal:** Define a finite capacity-like invariant as the supremum of TMI over admissible encodings, and prove a first upper bound.

### Definition
```lean
noncomputable def tropicalCapacity {Y : Type} [Fintype Y] [Nonempty Y]
    (n : ℕ) (K : Fin n → Y → ℝ) : ℝ :=
  tropicalMutualInformation K

/-- The operational capacity: supremum of TMI over all input cardinalities
    and all channel matrices with a fixed output type Y. -/
noncomputable def tropicalOperationalCapacity {Y : Type} [Fintype Y] [Nonempty Y]
    (n : ℕ) : ℝ :=
  ⨆ (K : Fin n → Y → ℝ), tropicalMutualInformation K
```

### Target Theorem
```lean
theorem tropicalCapacity_upper_bound {n : ℕ} {Y : Type} [Fintype Y] [Nonempty Y]
    (K : Fin n → Y → ℝ) :
    tropicalMutualInformation K ≤
      2 * (Finset.univ.sup' Finset.univ_nonempty (fun x =>
        Finset.univ.sup' Finset.univ_nonempty (fun y => K x y)) -
      Finset.univ.sup' Finset.univ_nonempty (fun x =>
        Finset.univ.inf' Finset.univ_nonempty (fun y => K x y)))
```

### Proof Strategy
The tropical distinguishability between any two rows is bounded by twice the dynamic range of the channel. Each one-sided separation `sup_y(K x₁ y - K x₂ y) ≤ sup_{x,y} K x y - inf_{x,y} K x y`. The factor of 2 comes from summing both directions.

### Significance
This provides the first tropical analogue of channel capacity bounds, connecting to coding theory via the maximum number of distinguishable codewords under tropical noise.

---

## 2. Spectral Bound on TMI

**Goal:** Relate `tropicalMutualInformation K` to a tropical operator seminorm or spectral radius.

### Definition
```lean
/-- Tropical oscillation seminorm of a channel, measuring the maximum
    row-to-row variation. -/
noncomputable def tropicalOscillation {X Y : Type} [Fintype X] [Nonempty X]
    [Fintype Y] [Nonempty Y] (K : X → Y → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x₁ =>
    Finset.univ.sup' Finset.univ_nonempty (fun x₂ =>
      Finset.univ.sup' Finset.univ_nonempty (fun y => K x₁ y - K x₂ y)))
```

### Target Theorem
```lean
theorem tropicalMutualInformation_le_oscillation
    {X Y : Type} [Fintype X] [Nonempty X] [Fintype Y] [Nonempty Y]
    (K : X → Y → ℝ) :
    tropicalMutualInformation K ≤ 2 * tropicalOscillation K
```

### Proof Strategy
By definition, `tropicalDist K x₁ x₂ = tropicalOneSidedSep K x₁ x₂ + tropicalOneSidedSep K x₂ x₁ ≤ 2 * tropicalOscillation K`. Taking the sup over pairs gives the bound.

### Cross-domain Connection
This connects TMI to the Hilbert projective metric and Birkhoff contraction theory. The oscillation seminorm is precisely the diameter in the Hilbert metric, and contraction under composition would yield geometric decay of information flow — a tropical analogue of mixing.

---

## 3. Decision-Theoretic Blackwell Order

**Goal:** Define a tropical informativeness preorder on channels and prove monotonicity of TMI.

### Definitions
```lean
/-- Channel K₁ tropically dominates K₂ if there exists a stochastic post-processing
    (here: deterministic surjective map on outputs) transforming K₁ to K₂. -/
def tropicalDominates {X Y₁ Y₂ : Type} [Fintype Y₁] [Fintype Y₂]
    [DecidableEq Y₂]
    (K₁ : X → Y₁ → ℝ) (K₂ : X → Y₂ → ℝ) : Prop :=
  ∃ (g : Y₁ → Y₂), Function.Surjective g ∧ ∀ x z, K₂ x z = postprocess K₁ g x z
```

### Target Theorem
```lean
theorem tropicalDominates_implies_tmi_le
    {X Y₁ Y₂ : Type} [Fintype X] [Nonempty X]
    [Fintype Y₁] [Nonempty Y₁] [Fintype Y₂] [Nonempty Y₂]
    [DecidableEq Y₂]
    (K₁ : X → Y₁ → ℝ) (K₂ : X → Y₂ → ℝ)
    (h : tropicalDominates K₁ K₂) :
    tropicalMutualInformation K₂ ≤ tropicalMutualInformation K₁
```

### Proof Strategy
Immediate from the data processing inequality and the definition of dominance: extract `g` and `hg` from the dominance hypothesis, rewrite `K₂` as `postprocess K₁ g`, and apply `tropical_mutual_information_data_processing`.

### Significance
This establishes TMI as a monotone invariant of the tropical Blackwell order, the natural preorder on statistical experiments in the max-plus world. It opens the door to tropical statistical decision theory: a channel is "more informative" precisely when it preserves more distinguishability.

---

## 4. Learning-Theoretic Compression Theorem

**Goal:** Formalize tropical representation maps and prove information contraction under compression layers in max-plus neural networks.

### Setup
A max-plus neural network layer computes `y_j = max_i (W_{ji} + x_i)` where `W` is a weight matrix. A composition of layers is itself a max-plus map. When a layer reduces dimension (pooling/compression), it acts as a deterministic post-processing on the tropical channel defined by the preceding layers.

### Target Theorem
```lean
/-- A max-plus layer as a tropical channel transformation. -/
def maxPlusLayer {m n : ℕ} (W : Fin n → Fin m → ℝ) : (Fin m → ℝ) → (Fin n → ℝ) :=
  fun x j => Finset.univ.sup' Finset.univ_nonempty (fun i => W j i + x i)

/-- Information contraction: composing with a deterministic pooling map
    cannot increase tropical distinguishability of inputs. -/
theorem maxplus_pooling_contracts_tmi
    {m n k : ℕ}
    (K : Fin m → Fin n → ℝ) (pool : Fin n → Fin k)
    (hpool : Function.Surjective pool) :
    tropicalMutualInformation (postprocess K pool) ≤ tropicalMutualInformation K
```

### Proof Strategy
Direct application of the data processing inequality. The key insight is that any deterministic pooling/compression layer on the output of a tropical channel is exactly a `postprocess` operation.

### Cross-domain Impact
This gives certified bounds on information loss in tropical neural networks. For ReLU networks (which are piecewise-linear, hence tropically structured), this provides a rigorous framework for understanding representation bottlenecks and feature compression.

---

## 5. Tensorization Equality and Tropical Coding Rates

**Goal:** Strengthen the tensor subadditivity to equality under a natural normalization, and use it to define tropical coding rates.

### Target Theorem (Tensor Equality)
```lean
theorem tropical_mutual_information_tensor_eq
    {X₁ Y₁ X₂ Y₂ : Type}
    [Fintype X₁] [Nonempty X₁] [Fintype Y₁] [Nonempty Y₁]
    [Fintype X₂] [Nonempty X₂] [Fintype Y₂] [Nonempty Y₂]
    (K₁ : X₁ → Y₁ → ℝ) (K₂ : X₂ → Y₂ → ℝ) :
    tropicalMutualInformation (tensorChannel K₁ K₂) =
      tropicalMutualInformation K₁ + tropicalMutualInformation K₂
```

### Proof Strategy
The ≤ direction is already proved (`tropical_mutual_information_tensor_le`). For ≥: the supremum defining `TMI(K₁ ⊗ K₂)` ranges over all pairs `((a₁,a₂), (b₁,b₂))`. In particular, choosing `(a₁*, a₂*)` and `(b₁*, b₂*)` that achieve the individual optima for `K₁` and `K₂` respectively gives `tropicalDist(K₁ ⊗ K₂, (a₁*,a₂*), (b₁*,b₂*)) = tropicalDist(K₁, a₁*, b₁*) + tropicalDist(K₂, a₂*, b₂*)`, and this equals `TMI(K₁) + TMI(K₂)` because these pairs achieve the individual maxima.

The subtlety: the product supremum optimizes over *all* pairs simultaneously, so the maximizers for the two factors need not compose to the global maximizer for the product. However, by `tropicalDist_tensor`, the product distinguishability decomposes additively, so the product maximizer IS the product of individual maximizers.

### Coding Rate Application
```lean
/-- Tropical coding rate: the per-use TMI in the limit of tensor products. -/
noncomputable def tropicalRate {X Y : Type} [Fintype X] [Nonempty X]
    [Fintype Y] [Nonempty Y] (K : X → Y → ℝ) : ℝ :=
  tropicalMutualInformation K  -- equals lim (1/n) * TMI(K^⊗n) by additivity
```

With tensor equality, `TMI(K^⊗n) = n * TMI(K)`, so the rate is simply `TMI(K)` itself — no limiting procedure needed. This is a significant simplification compared to Shannon theory, where the capacity requires a limit over block lengths.

---

## 6. Tropical f-Divergences and Convex Duality

**Goal:** Generalize the tropical distinguishability to a family of tropical f-divergence functionals, and characterize the data processing inequality as a duality phenomenon.

### Definition
```lean
/-- Tropical f-divergence: a generalized distinguishability using a convex function φ. -/
noncomputable def tropicalFDiv {X Y : Type} [Fintype Y] [Nonempty Y]
    (φ : ℝ → ℝ) (K : X → Y → ℝ) (x₁ x₂ : X) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun y => φ (K x₁ y - K x₂ y))
```

### Conjectured Theorem
For convex `φ` with `φ(0) = 0`, the tropical f-divergence satisfies a data processing inequality under surjective post-processing, provided `φ` is monotone on `[0, ∞)`.

### Significance
This would create a full tropical divergence theory parallel to Csiszár's f-divergence framework, with applications to hypothesis testing, estimation, and statistical mechanics in the max-plus setting.

---

## 7. Tropical Markov Chains and Contraction Rates

**Goal:** Define tropical Markov chains (iterated max-plus matrix multiplication) and prove geometric contraction of TMI under mixing conditions.

### Setup
A tropical Markov chain on state space `S` is given by a sequence of max-plus transition matrices `T_n : S → S → ℝ`. The composition `T₁ ⊕ T₂` is max-plus matrix multiplication: `(T₁ ⊕ T₂)(i,k) = max_j (T₁(i,j) + T₂(j,k))`.

### Conjectured Theorem
Under a tropical ergodicity condition (the Birkhoff contraction coefficient `τ(T) < 1`), iterated composition contracts TMI geometrically:
```
TMI(T₁ ⊕ T₂ ⊕ ... ⊕ Tₙ) ≤ τ^n * TMI(T₁)
```

### Cross-domain Connection
This connects tropical information theory to:
- **Dynamical systems**: observability decay under coarse observation
- **Statistical mechanics**: zero-temperature mixing (Maslov dequantization of Markov mixing)
- **Control theory**: tropical controllability and reachability analysis

---

## Summary Priority

| Priority | Direction | Difficulty | Impact |
|----------|-----------|------------|--------|
| 1 | Tensor equality (§5) | Low | Enables coding rates |
| 2 | Blackwell order (§3) | Low | Decision theory bridge |
| 3 | Spectral bound (§2) | Medium | Connects to Birkhoff theory |
| 4 | Channel capacity (§1) | Medium | Coding theory foundation |
| 5 | Compression theorem (§4) | Low | ML applications |
| 6 | f-Divergences (§6) | High | Full divergence theory |
| 7 | Markov contraction (§7) | High | Dynamical systems bridge |

The first five directions can be pursued immediately with the infrastructure established in this work. Directions 6 and 7 require additional mathematical development but would significantly expand the scope of tropical information theory.
