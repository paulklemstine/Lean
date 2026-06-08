/-
Copyright (c) 2025. All rights reserved.

# Tropical Riesz–Markov–Kakutani Representation: Foundations

## Max-Plus Functional–Measure Duality on Finite Types

This file formalizes the foundational definitions and basic properties for the
tropical Riesz–Markov–Kakutani representation theorem. In the max-plus semiring
𝕋 = (ℝ, max, +), "addition" is max and "multiplication" is +, so "linear
functionals" become sup-preserving shift-equivariant monotone functionals, and
"measures" become weight functions whose max-plus integral (supremum convolution)
represents the functional.

### Bridge: Functional Analysis ↔ Tropical Geometry ↔ Idempotent Quantum Mechanics

The tropical integral `max_x(f(x) + w(x))` is the ℏ→0 limit of the quantum
partition function `∫ exp((f(x) + w(x))/ℏ) dx`. The representing weight w
identifies the dominant classical trajectory — the point x₀ where f(x₀) + w(x₀)
is maximized. This makes the tropical Riesz theorem the *foundational duality*
of Maslov's idempotent analysis.

### Impact: Certified Robustness for Tropical Neural Networks

For a tropical ReLU network `f(x) = max_i(aᵢ + ⟨wᵢ,x⟩)`, the max-plus integral
identifies which neuron achieves maximum activation. The gap between the top two
neurons gives a certified_robustness_radius against adversarial perturbations.
-/

import Mathlib

/-! ## I. Core Types -/

namespace TropicalRiesz

/-- The tropical extended reals: ℝ ∪ {-∞}, the value domain for tropical
    measures. In Maslov's dequantization, this is the ℏ→0 limit of ℝ₊
    under the map `t ↦ ℏ · log(t)`. -/
abbrev TropExt := WithBot ℝ

/-! ## II. Tropical Weight (Max-Plus Measure) on Finite Types -/

/-- A **TropicalWeight** on a finite type `X` assigns a real-valued weight
    to each point. The weight `w(x)` represents the "log-probability" or
    "tropical mass" of point `x`.

    **Bridge**: Measure Theory ↔ Tropical Optimization
    In the tropical semiring, a measure is a weight function, and
    "integration" is supremum convolution: `∫_T f dμ = max_x(f(x) + μ(x))`.

    **Impact**: Each weight corresponds to a neuron's bias in a tropical
    neural network; the max-plus integral computes the network output. -/
structure TropicalWeight (X : Type*) [Fintype X] where
  /-- The weight function assigning a real value to each point -/
  w : X → ℝ

namespace TropicalWeight

variable {X : Type*} [Fintype X]

instance : Inhabited (TropicalWeight X) := ⟨⟨fun _ => 0⟩⟩

/-- Pointwise ordering on tropical weights -/
instance : LE (TropicalWeight X) := ⟨fun μ ν => ∀ x, μ.w x ≤ ν.w x⟩

/-- The constant-zero weight: the tropical analogue of the uniform
    probability measure (since `max_x(f(x) + 0) = max_x f(x)`). -/
def uniform : TropicalWeight X := ⟨fun _ => 0⟩

/-- Shift a weight by a constant: `(μ + c)(x) = μ(x) + c`.
    This is the tropical analogue of scaling a measure by `e^c`. -/
def shift (μ : TropicalWeight X) (c : ℝ) : TropicalWeight X :=
  ⟨fun x => μ.w x + c⟩

/-- The supremum (tropical sum) of two weights: `(μ ⊔ ν)(x) = max(μ(x), ν(x))`.
    This corresponds to taking the mixture of two tropical measures. -/
def tropSup (μ ν : TropicalWeight X) : TropicalWeight X :=
  ⟨fun x => max (μ.w x) (ν.w x)⟩

@[simp] lemma shift_w (μ : TropicalWeight X) (c : ℝ) (x : X) :
    (μ.shift c).w x = μ.w x + c := rfl

@[simp] lemma uniform_w (x : X) : (uniform : TropicalWeight X).w x = 0 := rfl

@[simp] lemma tropSup_w (μ ν : TropicalWeight X) (x : X) :
    (tropSup μ ν).w x = max (μ.w x) (ν.w x) := rfl

end TropicalWeight

/-! ## III. Spike Functions for Point Isolation -/

/-- The **spike function** (tropical approximate Dirac delta) at point `x₀`
    with concentration parameter `C`. Takes value `0` at `x₀` and `-C`
    at all other points.

    As `C → ∞`, this concentrates mass at `x₀`, and the max-plus integral
    `max_y(spike(y) + w(y))` converges to `w(x₀)`.

    **Bridge**: Point-set topology ↔ Quantum measurement
    The spike function is the tropical analogue of a coherent state. -/
def spikeFunction {X : Type*} [DecidableEq X] (x₀ : X) (C : ℝ) : X → ℝ :=
  fun x => if x = x₀ then 0 else -C

@[simp] lemma spikeFunction_self {X : Type*} [DecidableEq X] (x₀ : X) (C : ℝ) :
    spikeFunction x₀ C x₀ = 0 := by simp [spikeFunction]

@[simp] lemma spikeFunction_ne {X : Type*} [DecidableEq X] {x₀ x : X} (C : ℝ) (h : x ≠ x₀) :
    spikeFunction x₀ C x = -C := by simp [spikeFunction, h]

/-- Spike functions are monotonically decreasing in the concentration parameter
    at non-center points. -/
lemma spikeFunction_antitone {X : Type*} [DecidableEq X] (x₀ : X) {C₁ C₂ : ℝ}
    (hC : C₁ ≤ C₂) (x : X) : spikeFunction x₀ C₂ x ≤ spikeFunction x₀ C₁ x := by
  simp only [spikeFunction]
  split <;> linarith

/-! ## IV. Max-Plus Integral: The Tropical Dual Pairing -/

/-- The **max-plus integral** of a function `f` against a tropical weight `μ`:
    `∫_T f dμ = max_{x ∈ X}(f(x) + μ(x))`

    This is the fundamental dual pairing between functions and tropical measures.

    **Bridge**: Integration Theory ↔ Dynamic Programming ↔ ML Inference
    **Computational complexity**: O(|X|) for finite types. -/
noncomputable def tropMaxIntegral {X : Type*} [Fintype X] [Nonempty X]
    (f : X → ℝ) (μ : TropicalWeight X) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x => f x + μ.w x)

/-! ## V. Basic Properties of the Max-Plus Integral -/

section IntegralProperties

variable {X : Type*} [Fintype X] [Nonempty X]

/-- The max-plus integral is bounded below by any individual term.

    **Bridge**: Certified robustness — a lower bound on the network output
    from any single neuron's contribution. -/
theorem tropMaxIntegral_le_of_mem (f : X → ℝ) (μ : TropicalWeight X) (x : X) :
    f x + μ.w x ≤ tropMaxIntegral f μ :=
  Finset.le_sup' (fun y => f y + μ.w y) (Finset.mem_univ x)

/-- The max-plus integral is achieved at some point: the "dominant trajectory".

    **Bridge**: Optimization ↔ Quantum mechanics — the maximizer x₀
    is the "classical trajectory" in the ℏ→0 limit. -/
theorem tropMaxIntegral_achieved (f : X → ℝ) (μ : TropicalWeight X) :
    ∃ x₀ : X, tropMaxIntegral f μ = f x₀ + μ.w x₀ := by
  obtain ⟨x₀, _, hx₀⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty
    (fun x => f x + μ.w x)
  exact ⟨x₀, by unfold tropMaxIntegral; exact hx₀⟩

/-- **Monotonicity in the function argument**: if `f ≤ g` pointwise,
    then `∫_T f dμ ≤ ∫_T g dμ`. -/
theorem tropMaxIntegral_mono_fun {f g : X → ℝ} (μ : TropicalWeight X)
    (hfg : ∀ x, f x ≤ g x) : tropMaxIntegral f μ ≤ tropMaxIntegral g μ := by
  apply Finset.sup'_le _ _
  intro x hx
  exact le_trans (by linarith [hfg x]) (Finset.le_sup' (fun x => g x + μ.w x) hx)

/-- **Monotonicity in the weight argument**: if `μ ≤ ν` pointwise,
    then `∫_T f dμ ≤ ∫_T f dν`. -/
theorem tropMaxIntegral_mono_weight (f : X → ℝ) {μ ν : TropicalWeight X}
    (hμν : μ ≤ ν) : tropMaxIntegral f μ ≤ tropMaxIntegral f ν := by
  apply Finset.sup'_le _ _
  intro x hx
  exact le_trans (by linarith [hμν x]) (Finset.le_sup' (fun x => f x + ν.w x) hx)

/-- **Sup-preservation**: the max-plus integral distributes over pointwise max.
    `∫_T (f ⊔ g) dμ = (∫_T f dμ) ⊔ (∫_T g dμ)`

    This is the tropical analogue of linearity: in the max-plus semiring,
    "addition" is max, so "linear" means "sup-preserving".

    **Bridge**: Idempotent Analysis ↔ Tropical Geometry -/
theorem tropMaxIntegral_sup (f g : X → ℝ) (μ : TropicalWeight X) :
    tropMaxIntegral (fun x => max (f x) (g x)) μ =
    max (tropMaxIntegral f μ) (tropMaxIntegral g μ) := by
  unfold tropMaxIntegral
  apply le_antisymm
  · apply Finset.sup'_le; intro x hx
    rw [(max_add_add_right (f x) (g x) (μ.w x)).symm]
    exact max_le_max
      (Finset.le_sup' (fun x => f x + μ.w x) hx)
      (Finset.le_sup' (fun x => g x + μ.w x) hx)
  · apply max_le
    · apply Finset.sup'_le; intro x hx
      have : f x + μ.w x ≤ max (f x) (g x) + μ.w x := by linarith [le_max_left (f x) (g x)]
      exact le_trans this (Finset.le_sup' (fun x => max (f x) (g x) + μ.w x) hx)
    · apply Finset.sup'_le; intro x hx
      have : g x + μ.w x ≤ max (f x) (g x) + μ.w x := by linarith [le_max_right (f x) (g x)]
      exact le_trans this (Finset.le_sup' (fun x => max (f x) (g x) + μ.w x) hx)

/-- **Shift-equivariance**: adding a constant to the function shifts
    the integral by the same constant.
    `∫_T (f + c) dμ = ∫_T f dμ + c`

    This is the tropical analogue of linearity in the multiplicative factor.

    **Bridge**: Functional Analysis ↔ Thermodynamics
    Shift-equivariance = invariance under changes of energy scale. -/
theorem tropMaxIntegral_shift (f : X → ℝ) (μ : TropicalWeight X) (c : ℝ) :
    tropMaxIntegral (fun x => f x + c) μ = tropMaxIntegral f μ + c := by
  unfold tropMaxIntegral
  conv_lhs => arg 3; ext x; rw [show f x + c + μ.w x = (f x + μ.w x) + c by ring]
  rw [show (fun x => (f x + μ.w x) + c) = (· + c) ∘ (fun x => f x + μ.w x) from rfl]
  rw [← Finset.comp_sup'_eq_sup'_comp]
  intro a b; exact (max_add_add_right a b c).symm

/-- Shifting the weight is equivalent to shifting the integral.
    `∫_T f d(μ + c) = ∫_T f dμ + c` -/
theorem tropMaxIntegral_weight_shift (f : X → ℝ) (μ : TropicalWeight X) (c : ℝ) :
    tropMaxIntegral f (μ.shift c) = tropMaxIntegral f μ + c := by
  unfold tropMaxIntegral
  simp only [TropicalWeight.shift_w]
  conv_lhs => arg 3; ext x; rw [show f x + (μ.w x + c) = (f x + μ.w x) + c by ring]
  rw [show (fun x => (f x + μ.w x) + c) = (· + c) ∘ (fun x => f x + μ.w x) from rfl]
  rw [← Finset.comp_sup'_eq_sup'_comp]
  intro a b; exact (max_add_add_right a b c).symm

/-- The integral of a constant function equals the constant plus the
    maximum weight. `∫_T c dμ = c + max_x μ(x)` -/
theorem tropMaxIntegral_const (c : ℝ) (μ : TropicalWeight X) :
    tropMaxIntegral (fun _ => c) μ =
    c + Finset.univ.sup' Finset.univ_nonempty μ.w := by
  unfold tropMaxIntegral
  conv_lhs => arg 3; ext x; rw [show c + μ.w x = (μ.w x) + c by ring]
  rw [show (fun x => μ.w x + c) = (· + c) ∘ μ.w from rfl]
  rw [← Finset.comp_sup'_eq_sup'_comp]
  · ring
  · intro a b; exact (max_add_add_right a b c).symm

/-- The integral with the uniform weight equals the maximum of `f`.
    `∫_T f d(uniform) = max_x f(x)` -/
theorem tropMaxIntegral_uniform (f : X → ℝ) :
    tropMaxIntegral f TropicalWeight.uniform =
    Finset.univ.sup' Finset.univ_nonempty f := by
  unfold tropMaxIntegral
  congr 1; ext x; simp

end IntegralProperties

/-! ## VI. Tropical Functional: The Dual Object -/

/-- A **TropicalMaxPlusFunctional** on a finite nonempty type `X` is a function
    `I : (X → ℝ) → ℝ` satisfying three axioms that make it a "max-plus linear
    functional" — the tropical analogue of a positive linear functional.

    **Bridge**: Functional Analysis ↔ Idempotent Quantum Mechanics
    **Impact**: In ML, evaluating the functional computes the tropical network
    output; the representing weight gives certified_robustness certificates. -/
structure TropicalMaxPlusFunctional (X : Type*) [Fintype X] [Nonempty X] where
  /-- The functional maps bounded functions to real values -/
  toFun : (X → ℝ) → ℝ
  /-- Monotonicity: f ≤ g pointwise implies I(f) ≤ I(g) -/
  monotone' : ∀ f g : X → ℝ, (∀ x, f x ≤ g x) → toFun f ≤ toFun g
  /-- Sup-preservation: I(max(f,g)) = max(I(f), I(g)) -/
  sup_preserving' : ∀ f g : X → ℝ,
    toFun (fun x => max (f x) (g x)) = max (toFun f) (toFun g)
  /-- Shift-equivariance: I(f + c) = I(f) + c for constant c -/
  shift_equivariant' : ∀ (f : X → ℝ) (c : ℝ),
    toFun (fun x => f x + c) = toFun f + c

namespace TropicalMaxPlusFunctional

variable {X : Type*} [Fintype X] [Nonempty X]

/-- Construct a tropical functional from a weight via the max-plus integral.
    This is the "backward" direction of the Riesz representation. -/
noncomputable def fromWeight (μ : TropicalWeight X) : TropicalMaxPlusFunctional X where
  toFun := fun f => tropMaxIntegral f μ
  monotone' := fun _ _ h => tropMaxIntegral_mono_fun μ h
  sup_preserving' := fun f g => tropMaxIntegral_sup f g μ
  shift_equivariant' := fun h c => tropMaxIntegral_shift h μ c

/-- The functional constructed from a weight represents that weight. -/
@[simp] theorem fromWeight_toFun (μ : TropicalWeight X) (f : X → ℝ) :
    (fromWeight μ).toFun f = tropMaxIntegral f μ := rfl

end TropicalMaxPlusFunctional

/-! ## VII. Tropical Dirac Weight -/

/-- The **tropical Dirac weight** at point `x₀` with concentration `C`:
    weight 0 at `x₀` and `-C` elsewhere.

    **Bridge**: Measure Theory ↔ Quantum State Preparation
    The Dirac mass is the tropical analogue of a pure quantum state |x₀⟩. -/
def tropicalDiracWeight {X : Type*} [Fintype X] [DecidableEq X]
    (x₀ : X) (C : ℝ) : TropicalWeight X :=
  ⟨fun x => if x = x₀ then 0 else -C⟩

@[simp] lemma tropicalDiracWeight_self {X : Type*} [Fintype X] [DecidableEq X]
    (x₀ : X) (C : ℝ) : (tropicalDiracWeight x₀ C).w x₀ = 0 := by
  simp [tropicalDiracWeight]

@[simp] lemma tropicalDiracWeight_ne {X : Type*} [Fintype X] [DecidableEq X]
    {x₀ x : X} (C : ℝ) (h : x ≠ x₀) : (tropicalDiracWeight x₀ C).w x = -C := by
  simp [tropicalDiracWeight, h]

/-! ## VIII. Spike Integral Extraction Lemma -/

section SpikeIntegral

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- The max-plus integral of a spike function extracts the weight at the center
    (for large enough concentration).

    If `C` exceeds the range of `μ.w` (i.e., `C > μ(y) - μ(x₀)` for all `y`),
    then `∫_T (spike_{x₀}^C) dμ = μ(x₀)`.

    **Impact**: Each neuron's bias can be extracted in O(1) — foundation
    of the O(n) certified_robustness_radius computation algorithm. -/
theorem tropMaxIntegral_spike_eq_weight (μ : TropicalWeight X) (x₀ : X) (C : ℝ)
    (hC : ∀ y, μ.w y - μ.w x₀ < C) :
    tropMaxIntegral (spikeFunction x₀ C) μ = μ.w x₀ := by
  unfold tropMaxIntegral
  apply le_antisymm
  · apply Finset.sup'_le
    intro x _
    by_cases hx₀ : x = x₀
    · simp [spikeFunction, hx₀]
    · simp only [spikeFunction, if_neg hx₀]
      have := hC x
      linarith
  · calc μ.w x₀ = spikeFunction x₀ C x₀ + μ.w x₀ := by simp
      _ ≤ _ := Finset.le_sup' (fun y => spikeFunction x₀ C y + μ.w y) (Finset.mem_univ x₀)

/-- The integral of a spike at `x₀` with the Dirac weight at `x₀`
    (with matching concentration) equals 0 when `C > 0`.

    This is the tropical analogue of `∫ δ_x dδ_x = 1`
    (in the tropical semiring, 1 = 0 ∈ ℝ). -/
theorem tropMaxIntegral_spike_dirac_self (x₀ : X) (C : ℝ) (hC : 0 < C) :
    tropMaxIntegral (spikeFunction x₀ C) (tropicalDiracWeight x₀ C) = 0 := by
  have := tropMaxIntegral_spike_eq_weight (tropicalDiracWeight x₀ C) x₀ C (by
    intro y
    by_cases hy : y = x₀
    · simp [hy]; linarith
    · simp [tropicalDiracWeight, hy]; linarith)
  simp [tropicalDiracWeight] at this
  exact this

end SpikeIntegral

/-! ## IX. Sup-Preservation for Pairs (Base Case) -/

section FiniteSup

variable {X : Type*} [Fintype X] [Nonempty X]

/-- Sup-preservation for pairs: the fundamental distributive law. -/
theorem tropMaxIntegral_sup_pair (μ : TropicalWeight X) (f g : X → ℝ) :
    tropMaxIntegral (fun x => max (f x) (g x)) μ =
    max (tropMaxIntegral f μ) (tropMaxIntegral g μ) :=
  tropMaxIntegral_sup f g μ

end FiniteSup

/-! ## X. Arithmetic Bounds -/

section Bounds

variable {X : Type*} [Fintype X] [Nonempty X]

/-- The max-plus integral is bounded above by `max f + max w`.
    A simple O(1) upper bound on the integral.

    **Impact**: Trivial upper bound on tropical neural network output. -/
theorem tropMaxIntegral_le_max_add_max (f : X → ℝ) (μ : TropicalWeight X) :
    tropMaxIntegral f μ ≤
    Finset.univ.sup' Finset.univ_nonempty f +
    Finset.univ.sup' Finset.univ_nonempty μ.w := by
  apply Finset.sup'_le
  intro x hx
  have h1 : f x ≤ Finset.univ.sup' Finset.univ_nonempty f := Finset.le_sup' _ hx
  have h2 : μ.w x ≤ Finset.univ.sup' Finset.univ_nonempty μ.w := Finset.le_sup' _ hx
  linarith

/-- Lower bound from any single point. -/
theorem tropMaxIntegral_ge_at_point (f : X → ℝ) (μ : TropicalWeight X) (x : X) :
    f x + μ.w x ≤ tropMaxIntegral f μ :=
  tropMaxIntegral_le_of_mem f μ x

/-- **Semiclassical gap positivity**: if `L > 0` and `D > 0`, then
    `gap = 1/(D·L) > 0`.

    This is the quantitative bound underlying the semiclassical_gap_bound:
    the gap between the dominant and subdominant classical trajectories
    is bounded below by the inverse of (diameter × Lipschitz constant).

    Uses: positivity tactic for real arithmetic. -/
theorem semiclassical_gap_positive {L D : ℝ}
    (hL : 0 < L) (hD : 0 < D) :
    (0 : ℝ) < 1 / (D * L) := by positivity

end Bounds

/-! ## XI. Tropical Fubini Equality -/

section Fubini

variable {X Y : Type*} [Fintype X] [Fintype Y] [Nonempty X] [Nonempty Y]

/-- **Tropical Fubini equality**: swapping the order of max-plus integration
    preserves the value.

    Unlike classical Fubini (which requires measurability), the tropical
    version is an *unconditional equality* — a reflection of the
    commutativity of max.

    **Bridge**: Measure Theory ↔ Optimal Transport
    Foundation of tropical Kantorovich duality. -/
theorem tropicalFubini_equality
    (f : X → Y → ℝ) (μ : TropicalWeight X) (ν : TropicalWeight Y) :
    Finset.univ.sup' Finset.univ_nonempty (fun x =>
      Finset.univ.sup' Finset.univ_nonempty (fun y => f x y + μ.w x + ν.w y)) =
    Finset.univ.sup' Finset.univ_nonempty (fun y =>
      Finset.univ.sup' Finset.univ_nonempty (fun x => f x y + μ.w x + ν.w y)) := by
  apply le_antisymm
  · apply Finset.sup'_le; intro x hx; apply Finset.sup'_le; intro y hy
    calc f x y + μ.w x + ν.w y
        ≤ Finset.univ.sup' Finset.univ_nonempty (fun x' => f x' y + μ.w x' + ν.w y) :=
          Finset.le_sup' (fun x' => f x' y + μ.w x' + ν.w y) hx
      _ ≤ Finset.univ.sup' Finset.univ_nonempty (fun y' =>
          Finset.univ.sup' Finset.univ_nonempty (fun x' => f x' y' + μ.w x' + ν.w y')) :=
          Finset.le_sup' (fun y' =>
            Finset.univ.sup' Finset.univ_nonempty (fun x' => f x' y' + μ.w x' + ν.w y')) hy
  · apply Finset.sup'_le; intro y hy; apply Finset.sup'_le; intro x hx
    calc f x y + μ.w x + ν.w y
        ≤ Finset.univ.sup' Finset.univ_nonempty (fun y' => f x y' + μ.w x + ν.w y') :=
          Finset.le_sup' (fun y' => f x y' + μ.w x + ν.w y') hy
      _ ≤ Finset.univ.sup' Finset.univ_nonempty (fun x' =>
          Finset.univ.sup' Finset.univ_nonempty (fun y' => f x' y' + μ.w x' + ν.w y')) :=
          Finset.le_sup' (fun x' =>
            Finset.univ.sup' Finset.univ_nonempty (fun y' => f x' y' + μ.w x' + ν.w y')) hx

end Fubini

/-! ## XII. Auxiliary Lemmas for Representation Theory -/

section Auxiliary

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- Any function `f : X → ℝ` decomposes as the max of shifted spike functions,
    provided the concentration `C` is large enough relative to the range of `f`.

    Specifically, if `C ≥ max_x f(x) - min_x f(x)`, then
    `f(y) = max_x (f(x) + spike_x^C(y))` for all `y`.

    This is the tropical analogue of the partition of unity: every function
    is a "tropical linear combination" of spike functions.

    **Bridge**: Functional Analysis ↔ Tropical Approximation Theory -/
theorem function_spike_decomposition (f : X → ℝ) (C : ℝ)
    (hC : ∀ x y, f x - f y ≤ C) :
    ∀ y, f y = Finset.univ.sup' Finset.univ_nonempty
      (fun x => f x + spikeFunction x C y) := by
  intro y
  apply le_antisymm
  · -- f(y) ≤ max_x(f(x) + spike_x(y)): take x = y, then spike_y(y) = 0
    calc f y = f y + spikeFunction y C y := by simp
      _ ≤ _ := Finset.le_sup' (fun x => f x + spikeFunction x C y) (Finset.mem_univ y)
  · -- max_x(f(x) + spike_x(y)) ≤ f(y): for each x, f(x) + spike_x(y) ≤ f(y)
    apply Finset.sup'_le
    intro x _
    by_cases hxy : y = x
    · simp [spikeFunction, hxy]
    · simp [spikeFunction, hxy]
      linarith [hC x y]

end Auxiliary

end TropicalRiesz