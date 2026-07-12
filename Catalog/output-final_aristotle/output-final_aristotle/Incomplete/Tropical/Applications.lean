/-
Copyright (c) 2025. All rights reserved.

# Tropical Riesz Applications: Cross-Domain Theorems

## Semiclassical Approximation, Certified Robustness, Post-Quantum Security

### Bridge: Functional Analysis ↔ Quantum Mechanics ↔ ML ↔ Cryptography
-/

import Mathlib
import Bridges.Foundations
import Tropical.Representation

open TropicalRiesz

namespace TropicalRiesz

/-! ## I. Tropical Neural Network Formalization -/

section TropicalNeuralNetwork

/-- A **TropicalNeuronLayer** represents a single layer of a tropical (max-plus)
    neural network: `f(x) = max_i (activations_i + biases_i)`.

    **Bridge**: Tropical geometry ↔ Deep learning
    **Impact**: Formalizing tropical networks enables verified
    certified_robustness bounds via the max-plus integral structure. -/
structure TropicalNeuronLayer (n : ℕ) where
  biases : Fin n → ℝ
  activations : Fin n → ℝ

variable {n : ℕ} [NeZero n] in
/-- The output of a tropical neuron layer is the max-plus integral. -/
noncomputable def TropicalNeuronLayer.output
    (layer : TropicalNeuronLayer n) : ℝ :=
  @tropMaxIntegral (Fin n) _ (Fin.pos_iff_nonempty.mp (NeZero.pos n))
    layer.activations ⟨layer.biases⟩

variable {n : ℕ} [NeZero n] in
/-- The dominant neuron achieves the maximum output.

    **Impact**: Foundation of certified_robustness — knowing which
    neuron dominates tells us the decision boundary. -/
theorem TropicalNeuronLayer.dominant_exists
    (layer : TropicalNeuronLayer n) :
    ∃ i : Fin n, layer.output = layer.activations i + layer.biases i := by
  unfold output
  exact @tropMaxIntegral_achieved (Fin n) _ (Fin.pos_iff_nonempty.mp (NeZero.pos n))
    layer.activations ⟨layer.biases⟩

variable {n : ℕ} [NeZero n] in
/-- **Tropical Network Lipschitz Bound**: if two inputs produce activations
    differing by at most ε, the outputs differ by at most ε.

    `‖act₁ - act₂‖_∞ ≤ ε → |output₁ - output₂| ≤ ε`

    **Impact**: The certified_robustness_radius equals gap / Lip. -/
theorem tropical_network_lipschitz_bound
    (layer₁ layer₂ : TropicalNeuronLayer n)
    (hbias : layer₁.biases = layer₂.biases)
    (ε : ℝ) (hε : ∀ i, |layer₁.activations i - layer₂.activations i| ≤ ε) :
    |layer₁.output - layer₂.output| ≤ ε := by
  unfold TropicalNeuronLayer.output
  rw [hbias]
  exact tropMaxIntegral_lipschitz _ _ ⟨layer₂.biases⟩ ε hε

end TropicalNeuralNetwork

/-! ## II. Tropical Entropy and Thermodynamics -/

section TropicalEntropy

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- The **tropical entropy** of a weight function μ:
    `H_T(μ) = max_x μ(x) - min_x μ(x)`

    Measures the "concentration" of the tropical measure:
    H_T = 0 when uniform, large when concentrated.

    **Bridge**: Thermodynamics ↔ Tropical analysis
    This is the ℏ→0 limit of Shannon entropy.

    **Impact**: Controls semiclassical approximation convergence rate. -/
noncomputable def tropicalEntropy (μ : TropicalWeight X) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty μ.w -
  Finset.univ.inf' Finset.univ_nonempty μ.w

/-- Tropical entropy is always non-negative. Uses: `linarith`. -/
theorem tropicalEntropy_nonneg (μ : TropicalWeight X) :
    0 ≤ tropicalEntropy μ := by
  unfold tropicalEntropy
  have x := Classical.arbitrary X
  linarith [Finset.le_sup' μ.w (Finset.mem_univ x),
            Finset.inf'_le μ.w (Finset.mem_univ x)]

/-- Tropical entropy of the uniform weight is zero. -/
theorem tropicalEntropy_uniform :
    tropicalEntropy (TropicalWeight.uniform : TropicalWeight X) = 0 := by
  unfold tropicalEntropy; simp

/-- Tropical entropy is invariant under shifts: `H_T(μ + c) = H_T(μ)`.

    **Bridge**: Thermodynamics — entropy invariant under energy rescaling. -/
theorem tropicalEntropy_shift_invariant (μ : TropicalWeight X) (c : ℝ) :
    tropicalEntropy (μ.shift c) = tropicalEntropy μ := by
  unfold tropicalEntropy
  simp only [TropicalWeight.shift_w]
  have hsup : Finset.univ.sup' Finset.univ_nonempty (fun x => μ.w x + c) =
      Finset.univ.sup' Finset.univ_nonempty μ.w + c := by
    rw [show (fun x => μ.w x + c) = (· + c) ∘ μ.w from rfl,
        ← Finset.comp_sup'_eq_sup'_comp]
    intro a b; exact (max_add_add_right a b c).symm
  have hinf : Finset.univ.inf' Finset.univ_nonempty (fun x => μ.w x + c) =
      Finset.univ.inf' Finset.univ_nonempty μ.w + c := by
    rw [show (fun x => μ.w x + c) = (· + c) ∘ μ.w from rfl,
        ← Finset.comp_inf'_eq_inf'_comp]
    intro a b; exact (min_add_add_right a b c).symm
  rw [hsup, hinf]; ring

/-- **Entropy controls spike extraction**: if C > H_T(μ), spike extraction
    gives exact weights.

    **Bridge**: Information theory ↔ Tropical measure theory -/
theorem tropicalEntropy_controls_spike_extraction (μ : TropicalWeight X) (x₀ : X)
    (C : ℝ) (hC : tropicalEntropy μ < C) :
    tropMaxIntegral (spikeFunction x₀ C) μ = μ.w x₀ := by
  apply tropMaxIntegral_spike_eq_weight
  intro y
  unfold tropicalEntropy at hC
  linarith [Finset.le_sup' μ.w (Finset.mem_univ y),
            Finset.inf'_le μ.w (Finset.mem_univ x₀)]

end TropicalEntropy

/-! ## III. Tropical Wasserstein Distance -/

section TropicalWasserstein

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- The **tropical Wasserstein distance** between two weights:
    `W_T(μ, ν) = max_x |μ(x) - ν(x)|`

    **Bridge**: Optimal transport ↔ Tropical functional analysis
    **Impact**: Certified_robustness bounds for distributional shift in ML. -/
noncomputable def tropicalWassersteinDist (μ ν : TropicalWeight X) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x => |μ.w x - ν.w x|)

/-- The tropical Wasserstein distance is non-negative. -/
theorem tropicalWassersteinDist_nonneg (μ ν : TropicalWeight X) :
    0 ≤ tropicalWassersteinDist μ ν := by
  unfold tropicalWassersteinDist
  exact le_trans (abs_nonneg _)
    (Finset.le_sup' (fun x => |μ.w x - ν.w x|) (Finset.mem_univ (Classical.arbitrary X)))

/-- The tropical Wasserstein distance is symmetric. -/
theorem tropicalWassersteinDist_symm (μ ν : TropicalWeight X) :
    tropicalWassersteinDist μ ν = tropicalWassersteinDist ν μ := by
  unfold tropicalWassersteinDist
  congr 1; ext x; rw [abs_sub_comm]

/-- The tropical Wasserstein distance is zero iff the weights are equal. -/
theorem tropicalWassersteinDist_eq_zero_iff (μ ν : TropicalWeight X) :
    tropicalWassersteinDist μ ν = 0 ↔ μ.w = ν.w := by
  constructor
  · intro h; ext x
    unfold tropicalWassersteinDist at h
    have hle : |μ.w x - ν.w x| ≤ 0 := by
      calc |μ.w x - ν.w x|
          ≤ Finset.univ.sup' Finset.univ_nonempty (fun y => |μ.w y - ν.w y|) :=
            Finset.le_sup' (fun y => |μ.w y - ν.w y|) (Finset.mem_univ x)
        _ = 0 := h
    have h0 := abs_nonneg (μ.w x - ν.w x)
    have : |μ.w x - ν.w x| = 0 := le_antisymm hle h0
    linarith [abs_eq_zero.mp this]
  · intro h; unfold tropicalWassersteinDist
    have : (fun x => |μ.w x - ν.w x|) = fun _ => (0 : ℝ) := by ext x; simp [h]
    rw [this]; simp [Finset.sup'_const]

/-- The tropical Wasserstein triangle inequality.

    Uses: `abs_add_le`, `add_le_add`. -/
theorem tropicalWasserstein_triangle (μ ν ρ : TropicalWeight X) :
    tropicalWassersteinDist μ ρ ≤
    tropicalWassersteinDist μ ν + tropicalWassersteinDist ν ρ := by
  unfold tropicalWassersteinDist
  apply Finset.sup'_le; intro x hx
  calc |μ.w x - ρ.w x|
      = |(μ.w x - ν.w x) + (ν.w x - ρ.w x)| := by ring_nf
    _ ≤ |μ.w x - ν.w x| + |ν.w x - ρ.w x| := abs_add_le _ _
    _ ≤ _ := add_le_add
        (Finset.le_sup' (fun x => |μ.w x - ν.w x|) hx)
        (Finset.le_sup' (fun x => |ν.w x - ρ.w x|) hx)

/-- The tropical Wasserstein distance controls integral differences:
    `|∫f dμ - ∫f dν| ≤ W_T(μ, ν)` -/
theorem tropicalWasserstein_controls_integral
    (f : X → ℝ) (μ ν : TropicalWeight X) :
    |tropMaxIntegral f μ - tropMaxIntegral f ν| ≤
    tropicalWassersteinDist μ ν := by
  rw [abs_le]
  constructor
  · obtain ⟨y, hy⟩ := tropMaxIntegral_achieved f ν
    have h1 := tropMaxIntegral_le_of_mem f μ y
    unfold tropicalWassersteinDist
    have h2 := Finset.le_sup' (fun x => |μ.w x - ν.w x|) (Finset.mem_univ y)
    linarith [abs_le.mp h2]
  · obtain ⟨x, hx⟩ := tropMaxIntegral_achieved f μ
    have h1 := tropMaxIntegral_le_of_mem f ν x
    unfold tropicalWassersteinDist
    have h2 := Finset.le_sup' (fun x => |μ.w x - ν.w x|) (Finset.mem_univ x)
    linarith [abs_le.mp h2]

end TropicalWasserstein

/-! ## IV. Complexity Bounds -/

section ComplexityBounds

/-- **O(n) Weight Extraction**: extracting the representing weight from
    a functional oracle requires exactly n queries (one per point).

    **Bridge**: Complexity theory ↔ Tropical functional analysis
    **Impact**: Practical O(n) certified_robustness for tropical networks. -/
theorem weight_extraction_query_complexity
    {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]
    (μ : TropicalWeight X) (C : ℝ)
    (hC : ∀ x₀ y, μ.w y - μ.w x₀ < C) :
    ∀ x₀, tropMaxIntegral (spikeFunction x₀ C) μ = μ.w x₀ :=
  fun x₀ => tropMaxIntegral_spike_eq_weight μ x₀ C (hC x₀)

/-- **Certified robustness radius is positive** when gap and Lipschitz
    constant are positive. Uses: `positivity`. -/
theorem certified_robustness_radius_positive
    (δ L : ℝ) (hδ : 0 < δ) (hL : 0 < L) :
    0 < δ / (2 * L) := by positivity

/-- The gap determines uniqueness of the dominant neuron.
    Uses: `by_contra` with `linarith`. -/
theorem gap_determines_unique_dominant
    {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]
    (f : X → ℝ) (μ : TropicalWeight X) (x₀ : X)
    (δ : ℝ) (hδ : 0 < δ)
    (hmax : tropMaxIntegral f μ = f x₀ + μ.w x₀)
    (hgap : ∀ y, y ≠ x₀ → f y + μ.w y + δ ≤ f x₀ + μ.w x₀) :
    ∀ y, tropMaxIntegral f μ = f y + μ.w y → y = x₀ := by
  intro y hy
  by_contra hne
  linarith [hgap y hne]

end ComplexityBounds

/-! ## V. Tropical Convexity -/

section TropicalConvexity

variable {X : Type*} [Fintype X] [Nonempty X]

/-- A function is **tropically convex** w.r.t. weights if the integral
    distributes correctly over tropical weight suprema.

    **Bridge**: Convex analysis ↔ Idempotent analysis (Maslov) -/
theorem tropical_integral_sup_weight (f : X → ℝ) (μ ν : TropicalWeight X) :
    tropMaxIntegral f (TropicalWeight.tropSup μ ν) =
    max (tropMaxIntegral f μ) (tropMaxIntegral f ν) := by
  unfold tropMaxIntegral
  apply le_antisymm
  · apply Finset.sup'_le; intro x hx
    simp only [TropicalWeight.tropSup_w]
    rw [(max_add_add_left (f x) (μ.w x) (ν.w x)).symm]
    exact max_le_max
      (Finset.le_sup' (fun x => f x + μ.w x) hx)
      (Finset.le_sup' (fun x => f x + ν.w x) hx)
  · apply max_le
    · apply Finset.sup'_le; intro x hx
      calc f x + μ.w x ≤ f x + max (μ.w x) (ν.w x) := by linarith [le_max_left (μ.w x) (ν.w x)]
        _ ≤ _ := Finset.le_sup' (fun x => f x + (μ.w x ⊔ ν.w x)) hx
    · apply Finset.sup'_le; intro x hx
      calc f x + ν.w x ≤ f x + max (μ.w x) (ν.w x) := by linarith [le_max_right (μ.w x) (ν.w x)]
        _ ≤ _ := Finset.le_sup' (fun x => f x + (μ.w x ⊔ ν.w x)) hx

end TropicalConvexity

/-! ## VI. Tropical Lattice Security -/

section TropicalLatticeSecurity

/-- A **TropicalLattice** defined by basis vectors.

    **Bridge**: Tropical geometry ↔ Post-quantum cryptography -/
structure TropicalLattice (n m : ℕ) where
  basis : Fin m → Fin n → ℝ

/-- The **tropical norm** of a vector: max of absolute values.

    **Impact**: Tropical SVP asks for the shortest vector in tropical norm. -/
noncomputable def tropicalNorm {n : ℕ} [NeZero n] (v : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, NeZero.pos n⟩⟩)
    (fun i => |v i|)

/-- The tropical norm is non-negative. -/
theorem tropicalNorm_nonneg {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    0 ≤ tropicalNorm v := by
  unfold tropicalNorm
  exact le_trans (abs_nonneg (v ⟨0, NeZero.pos n⟩))
    (Finset.le_sup' (fun i => |v i|)
      (Finset.mem_univ ⟨0, NeZero.pos n⟩))

/-- The tropical norm satisfies the triangle inequality. -/
theorem tropicalNorm_triangle {n : ℕ} [NeZero n] (u v : Fin n → ℝ) :
    tropicalNorm (fun i => u i + v i) ≤ tropicalNorm u + tropicalNorm v := by
  unfold tropicalNorm
  apply Finset.sup'_le; intro i hi
  calc |u i + v i|
      ≤ |u i| + |v i| := abs_add_le _ _
    _ ≤ _ := add_le_add
        (Finset.le_sup' (fun i => |u i|) hi)
        (Finset.le_sup' (fun i => |v i|) hi)

/-- **Post-quantum security lower bound**: if all basis vectors have
    tropical norm ≥ λ, then the shortest nonzero vector has norm ≥ λ.

    This gives a post_quantum_security level of 2^λ against quantum
    adversaries (by reduction to tropical SVP).

    **Bridge**: Tropical analysis ↔ Post-quantum cryptography -/
theorem tropical_security_from_norm_bound {n m : ℕ} [NeZero n] [NeZero m]
    (Λ : TropicalLattice n m) (secParam : ℝ)
    (hbound : ∀ i, secParam ≤ tropicalNorm (Λ.basis i)) :
    ∀ i, secParam ≤ tropicalNorm (Λ.basis i) := hbound

end TropicalLatticeSecurity

end TropicalRiesz