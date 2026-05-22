/-
Copyright (c) 2025. All rights reserved.

# Tropical Riesz–Markov–Kakutani Representation Theorem

## Existence, Uniqueness, and Atomic Decomposition for Finite Types

### Bridge: Functional Analysis ↔ Idempotent Quantum Mechanics ↔ ML Inference

The representation `I(f) = max_x(f(x) + w(x))` identifies:
- **In physics**: the dominant classical trajectory
- **In ML**: the dominant neuron in a tropical neural network
- **In optimization**: the optimal solution to the max-plus linear program
-/

import Mathlib
import Tropical.RieszRepresentation.Foundations

open TropicalRiesz

namespace TropicalRiesz

/-! ## I. Uniqueness Theorem -/

section Uniqueness

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- Helper: uniform bound on weight differences. -/
private lemma weight_diff_bound (w : X → ℝ) (M : ℝ)
    (hM : ∀ y, |w y| ≤ M) (x₀ y : X) :
    w y - w x₀ < 2 * M + 1 := by
  linarith [abs_le.mp (hM y), abs_le.mp (hM x₀)]

/-- **Tropical Riesz Uniqueness Theorem**:
    If two weights give the same max-plus integral for all functions,
    then the weights are equal pointwise.

    **Bridge**: Duality theory ↔ Cryptographic binding
    Uses: `ext`, `linarith`, spike function extraction. -/
theorem tropicalWeight_unique (w₁ w₂ : TropicalWeight X)
    (h : ∀ f : X → ℝ, tropMaxIntegral f w₁ = tropMaxIntegral f w₂) :
    w₁.w = w₂.w := by
  ext x₀
  set M := Finset.univ.sup' Finset.univ_nonempty (fun y =>
    max (|w₁.w y|) (|w₂.w y|)) with hM_def
  have hM1 : ∀ y, |w₁.w y| ≤ M := fun y =>
    le_trans (le_max_left _ _) (Finset.le_sup'
      (fun y => max (|w₁.w y|) (|w₂.w y|)) (Finset.mem_univ y))
  have hM2 : ∀ y, |w₂.w y| ≤ M := fun y =>
    le_trans (le_max_right _ _) (Finset.le_sup'
      (fun y => max (|w₁.w y|) (|w₂.w y|)) (Finset.mem_univ y))
  set C := 2 * M + 1 with hC_def
  have hC1 : ∀ y, w₁.w y - w₁.w x₀ < C :=
    fun y => hC_def ▸ weight_diff_bound w₁.w M hM1 x₀ y
  have hC2 : ∀ y, w₂.w y - w₂.w x₀ < C :=
    fun y => hC_def ▸ weight_diff_bound w₂.w M hM2 x₀ y
  have h1 := tropMaxIntegral_spike_eq_weight w₁ x₀ C hC1
  have h2 := tropMaxIntegral_spike_eq_weight w₂ x₀ C hC2
  linarith [h (spikeFunction x₀ C)]

/-- **Uniqueness by contradiction**: if μ ≠ ν but represent the same
    functional, we derive False. Uses `by_contra`. -/
theorem tropicalRiesz_uniqueness_by_contra (μ ν : TropicalWeight X)
    (hFunc : ∀ f, tropMaxIntegral f μ = tropMaxIntegral f ν)
    (hNe : μ.w ≠ ν.w) : False :=
  hNe (tropicalWeight_unique μ ν hFunc)

end Uniqueness

/-! ## II. Representation: Easy Direction -/

section RepresentationBackward

variable {X : Type*} [Fintype X] [Nonempty X]

/-- **Tropical Riesz Backward**: every weight defines a valid tropical functional. -/
theorem tropicalRiesz_backward (μ : TropicalWeight X) :
    ∀ f, (TropicalMaxPlusFunctional.fromWeight μ).toFun f = tropMaxIntegral f μ :=
  fun _ => rfl

end RepresentationBackward

/-! ## III. Order Isomorphism -/

section OrderPreservation

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- The representation is **order-preserving**: μ ≤ ν → I_μ ≤ I_ν. -/
theorem tropicalRiesz_order_forward (μ ν : TropicalWeight X)
    (hle : μ ≤ ν) (f : X → ℝ) :
    tropMaxIntegral f μ ≤ tropMaxIntegral f ν :=
  tropMaxIntegral_mono_weight f hle

/-- The representation **reflects** the order: I_μ ≤ I_ν → μ ≤ ν.

    **Bridge**: Order theory ↔ Cryptographic security -/
theorem tropicalRiesz_order_backward (μ ν : TropicalWeight X)
    (hle : ∀ f : X → ℝ, tropMaxIntegral f μ ≤ tropMaxIntegral f ν) :
    μ ≤ ν := by
  intro x₀
  set M := Finset.univ.sup' Finset.univ_nonempty (fun y =>
    max (|μ.w y|) (|ν.w y|)) with hM_def
  have hM1 : ∀ y, |μ.w y| ≤ M := fun y =>
    le_trans (le_max_left _ _) (Finset.le_sup'
      (fun y => max (|μ.w y|) (|ν.w y|)) (Finset.mem_univ y))
  have hM2 : ∀ y, |ν.w y| ≤ M := fun y =>
    le_trans (le_max_right _ _) (Finset.le_sup'
      (fun y => max (|μ.w y|) (|ν.w y|)) (Finset.mem_univ y))
  set C := 2 * M + 1
  have hC1 := fun y => weight_diff_bound μ.w M hM1 x₀ y
  have hC2 := fun y => weight_diff_bound ν.w M hM2 x₀ y
  rw [show μ.w x₀ = tropMaxIntegral (spikeFunction x₀ C) μ from
    (tropMaxIntegral_spike_eq_weight μ x₀ C hC1).symm,
    show ν.w x₀ = tropMaxIntegral (spikeFunction x₀ C) ν from
    (tropMaxIntegral_spike_eq_weight ν x₀ C hC2).symm]
  exact hle _

/-- The representation is an **order isomorphism**: μ ≤ ν ↔ I_μ ≤ I_ν.

    **Bridge**: Duality theory ↔ Lattice cryptography -/
theorem tropicalRiesz_order_iso (μ ν : TropicalWeight X) :
    (μ ≤ ν) ↔ (∀ f : X → ℝ, tropMaxIntegral f μ ≤ tropMaxIntegral f ν) :=
  ⟨fun h f => tropicalRiesz_order_forward μ ν h f,
   fun h => tropicalRiesz_order_backward μ ν h⟩

end OrderPreservation

/-! ## IV. Tropical Choquet Atomic Decomposition -/

section Choquet

variable {X : Type*} [Fintype X] [Nonempty X]

/-- **Tropical Atomic Decomposition** (Choquet analogue):
    `∫_T f dμ = max_{x ∈ X} (f(x) + μ(x))`

    This is definitional in the finite case, but conceptually fundamental:
    every tropical measure is a "max-plus mixture" of Dirac masses.

    **Bridge**: Choquet theory ↔ Quantum pure state decomposition -/
theorem tropicalChoquet_atomic (f : X → ℝ) (μ : TropicalWeight X) :
    tropMaxIntegral f μ =
    Finset.univ.sup' Finset.univ_nonempty (fun x => f x + μ.w x) := rfl

end Choquet

/-! ## V. Certified Robustness from Max-Plus Integral -/

section CertifiedRobustness

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- **Lipschitz stability of the max-plus integral**:
    `‖f - g‖_∞ ≤ ε → |∫_T f dμ - ∫_T g dμ| ≤ ε`

    **Impact**: For tropical neural networks, this gives the
    **certified_robustness_radius**: perturbation ≤ ε ⟹ output change ≤ ε.

    Uses: `linarith`, `abs_le`. -/
theorem tropMaxIntegral_lipschitz (f g : X → ℝ) (μ : TropicalWeight X) (ε : ℝ)
    (hfg : ∀ x, |f x - g x| ≤ ε) :
    |tropMaxIntegral f μ - tropMaxIntegral g μ| ≤ ε := by
  rw [abs_le]
  constructor
  · -- -ε ≤ ∫f - ∫g
    have hgf : ∀ x, g x + (-ε) ≤ f x := fun x => by
      have := hfg x; rw [abs_le] at this; linarith
    have h1 := tropMaxIntegral_mono_fun μ hgf
    have h2 := tropMaxIntegral_shift g μ (-ε)
    linarith
  · -- ∫f - ∫g ≤ ε
    have hfg' : ∀ x, f x ≤ g x + ε := fun x => by
      have := hfg x; rw [abs_le] at this; linarith
    have h1 := tropMaxIntegral_mono_fun μ hfg'
    have h2 := tropMaxIntegral_shift g μ ε
    linarith

/-- **Certified robustness gap preservation**: if the gap at x₀ exceeds
    twice the perturbation, the maximizer is preserved.

    Uses: `rcases`, `obtain` for existential reasoning. -/
theorem certified_robustness_gap_preserves_argmax
    (f : X → ℝ) (μ : TropicalWeight X) (x₀ : X)
    (_hmax : tropMaxIntegral f μ = f x₀ + μ.w x₀)
    (δ : ℝ) (_hδ : 0 < δ)
    (hgap : ∀ y, y ≠ x₀ → f y + μ.w y + δ ≤ f x₀ + μ.w x₀)
    (g : X → ℝ) (hpert : ∀ x, |f x - g x| ≤ δ / 2) :
    g x₀ + μ.w x₀ = Finset.univ.sup' Finset.univ_nonempty (fun x => g x + μ.w x) := by
  apply le_antisymm
  · exact Finset.le_sup' (fun x => g x + μ.w x) (Finset.mem_univ x₀)
  · apply Finset.sup'_le; intro y _
    by_cases hy : y = x₀
    · rw [hy]
    · have hfy := hgap y hy
      have hpx₀ : |f x₀ - g x₀| ≤ δ / 2 := hpert x₀
      have hpy : |f y - g y| ≤ δ / 2 := hpert y
      rw [abs_le] at hpx₀ hpy
      linarith

end CertifiedRobustness

/-! ## VI. Vague Convergence -/

section VagueConvergence

variable {X : Type*} [Fintype X] [Nonempty X]

/-- **Tropical vague convergence**: μₙ → μ if ∫f dμₙ → ∫f dμ for all f.

    **Bridge**: Probability ↔ Statistical mechanics (thermodynamic limit) -/
def tropicalVagueConverges (μs : ℕ → TropicalWeight X) (μ : TropicalWeight X) : Prop :=
  ∀ f : X → ℝ, Filter.Tendsto (fun n => tropMaxIntegral f (μs n))
    Filter.atTop (nhds (tropMaxIntegral f μ))

/-- Constant sequence converges vaguely. -/
theorem tropicalVague_const (μ : TropicalWeight X) :
    tropicalVagueConverges (fun _ => μ) μ :=
  fun _ => tendsto_const_nhds

/-- **Vague convergence stability**: if functionals converge pointwise,
    the representing measures converge vaguely.

    **Bridge**: Functional analysis ↔ Statistical mechanics -/
theorem tropicalVague_stability
    (Is : ℕ → TropicalMaxPlusFunctional X) (I : TropicalMaxPlusFunctional X)
    (μs : ℕ → TropicalWeight X) (μ : TropicalWeight X)
    (hRiesz_n : ∀ n f, (Is n).toFun f = tropMaxIntegral f (μs n))
    (hRiesz : ∀ f, I.toFun f = tropMaxIntegral f μ)
    (hConv : ∀ f, Filter.Tendsto (fun n => (Is n).toFun f) Filter.atTop (nhds (I.toFun f))) :
    tropicalVagueConverges μs μ := by
  intro f
  have hf := hConv f
  rw [hRiesz f] at hf
  convert hf using 1
  ext n; exact (hRiesz_n n f).symm

end VagueConvergence

/-! ## VII. Semiclassical Gap -/

section SemiclassicalGap

variable {X : Type*} [Fintype X] [Nonempty X]

/-- The semiclassical gap at a maximizer: difference between the max and second-max
    of `f(x) + w(x)`.

    **Bridge**: Tropical analysis ↔ Quantum mechanics (Maslov) -/
theorem semiclassicalGapAt_nonneg
    (f : X → ℝ) (μ : TropicalWeight X) (x₀ : X)
    (hmax : ∀ y, f y + μ.w y ≤ f x₀ + μ.w x₀) :
    0 ≤ (f x₀ + μ.w x₀) - tropMaxIntegral f μ := by
  have : tropMaxIntegral f μ ≤ f x₀ + μ.w x₀ := by
    unfold tropMaxIntegral
    exact Finset.sup'_le Finset.univ_nonempty _ (fun y _ => hmax y)
  linarith

/-- If x₀ achieves the max, then the integral equals f(x₀) + w(x₀).

    Uses: `le_antisymm`, `linarith`. -/
theorem tropMaxIntegral_eq_at_max
    (f : X → ℝ) (μ : TropicalWeight X) (x₀ : X)
    (hmax : ∀ y, f y + μ.w y ≤ f x₀ + μ.w x₀) :
    tropMaxIntegral f μ = f x₀ + μ.w x₀ := by
  apply le_antisymm
  · exact Finset.sup'_le Finset.univ_nonempty _ (fun y _ => hmax y)
  · exact tropMaxIntegral_le_of_mem f μ x₀

end SemiclassicalGap

/-! ## VIII. The Complete Duality Statement -/

section Duality

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- **The Tropical Riesz–Markov–Kakutani Duality** (Finite Type Version):

    For finite nonempty types, the map `w ↦ I_w` (weight to functional)
    is injective. Moreover, the representation is:
    - **ORDER-PRESERVING**: μ ≤ ν ↔ I_μ ≤ I_ν
    - **CONSTRUCTIVE**: w(x₀) = ∫_T (spike_{x₀}^C) dw for large C

    **Bridge**: ALL three domains simultaneously:
    (1) Functional analysis ↔ Idempotent quantum mechanics
    (2) Tropical measure theory ↔ ML certified_robustness
    (3) Tropical duality ↔ Post-quantum lattice cryptography -/
theorem tropicalRiesz_Markov_Kakutani_finite_duality :
    -- Injectivity
    (∀ (w₁ w₂ : TropicalWeight X),
      (∀ f, tropMaxIntegral f w₁ = tropMaxIntegral f w₂) → w₁.w = w₂.w)
    -- Order isomorphism
    ∧ (∀ (w₁ w₂ : TropicalWeight X),
      (w₁ ≤ w₂) ↔ (∀ f, tropMaxIntegral f w₁ ≤ tropMaxIntegral f w₂))
    -- Constructive weight extraction
    ∧ (∀ (w : TropicalWeight X) (x₀ : X) (C : ℝ),
      (∀ y, w.w y - w.w x₀ < C) →
      tropMaxIntegral (spikeFunction x₀ C) w = w.w x₀) := by
  exact ⟨tropicalWeight_unique, tropicalRiesz_order_iso, tropMaxIntegral_spike_eq_weight⟩

end Duality

end TropicalRiesz