import Mathlib

/-!
# ReLU networks are affine on feasible activation cells

This file advances the finite activation-space semantics to a geometric statement.
For a one-hidden-layer ReLU network, a Boolean pattern describes a system of strict
and weak affine inequalities.  The corresponding activation cell is nonempty
exactly when that system is feasible.  On every such cell, ReLU may be replaced by
the affine expression selected by the pattern, so the network output agrees with
an explicit affine formula.
-/

open Finset Function Set
open scoped BigOperators

namespace ReluActivationCells

/-- Boolean activation patterns for `k` hidden neurons. -/
abbrev Pattern (k : ℕ) := Fin k → Bool

/-- The affine preactivation of hidden neuron `j`. -/
def preactivation {n k : ℕ} (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ) (j : Fin k) : ℝ :=
  (∑ i, w j i * x i) + b j

/-- The strict-positive activation pattern of an affine hidden layer. -/
noncomputable def activation {n k : ℕ} (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ) : Pattern k :=
  fun j => decide (0 < preactivation w b x j)

/-- Inputs realizing one fixed activation pattern. -/
def cell {n k : ℕ} (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (p : Pattern k) : Set (Fin n → ℝ) :=
  {x | activation w b x = p}

/-- The mixed strict/weak system represented by an activation pattern. -/
def PatternInequalities {n k : ℕ} (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (p : Pattern k) (x : Fin n → ℝ) : Prop :=
  ∀ j, if p j then 0 < preactivation w b x j else preactivation w b x j ≤ 0

/-- An activation cell is nonempty exactly when its associated strict/weak affine
inequality system has a solution. -/
theorem cell_nonempty_iff_inequalities {n k : ℕ}
    (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ) (p : Pattern k) :
    (cell w b p).Nonempty ↔ ∃ x, PatternInequalities w b p x := by
  constructor
  · rintro ⟨x, hx⟩
    use x
    simp only [Set.mem_setOf_eq, cell] at hx
    intro j
    have h := congr_fun hx j
    simp only [activation] at h
    cases hp : p j <;> simp_all
  · rintro ⟨x, hx⟩
    use x
    simp only [Set.mem_setOf_eq, cell]
    ext j
    simp only [activation]
    have hxi := hx j
    cases hp : p j <;> simp_all

/-- Scalar ReLU, written explicitly to keep the development self-contained. -/
def relu (z : ℝ) : ℝ := max z 0

/-- A scalar-output, one-hidden-layer ReLU network. -/
def networkOutput {n k : ℕ} (w : Fin k → Fin n → ℝ) (b v : Fin k → ℝ)
    (c : ℝ) (x : Fin n → ℝ) : ℝ :=
  (∑ j, v j * relu (preactivation w b x j)) + c

/-- The affine formula selected by a fixed hidden activation pattern. -/
def selectedAffine {n k : ℕ} (w : Fin k → Fin n → ℝ) (b v : Fin k → ℝ)
    (c : ℝ) (p : Pattern k) (x : Fin n → ℝ) : ℝ :=
  (∑ j, if p j then v j * preactivation w b x j else 0) + c

/-- On an activation cell, each ReLU gate equals the affine branch selected by
that cell's pattern; hence the whole network agrees with `selectedAffine`. -/
theorem networkOutput_eq_selectedAffine_of_mem_cell {n k : ℕ}
    (w : Fin k → Fin n → ℝ) (b v : Fin k → ℝ) (c : ℝ)
    (p : Pattern k) {x : Fin n → ℝ} (hx : x ∈ cell w b p) :
    networkOutput w b v c x = selectedAffine w b v c p x := by
  simp only [networkOutput, selectedAffine, cell, Set.mem_setOf_eq] at hx ⊢
  rw [hx.symm]
  simp [relu, activation, max_def]
  apply Finset.sum_congr rfl
  intro j _
  by_cases h : preactivation w b x j ≤ 0 <;> simp [h]

/-- The formula selected by a pattern preserves affine combinations. -/
theorem selectedAffine_affineCombination {n k : ℕ}
    (w : Fin k → Fin n → ℝ) (b v : Fin k → ℝ) (c t : ℝ)
    (p : Pattern k) (x y : Fin n → ℝ) :
    selectedAffine w b v c p (fun i => t * x i + (1 - t) * y i) =
      t * selectedAffine w b v c p x +
        (1 - t) * selectedAffine w b v c p y := by
  have preact_linear : ∀ j, preactivation w b (fun i => t * x i + (1 - t) * y i) j =
      t * preactivation w b x j + (1 - t) * preactivation w b y j := by
    intro j
    simp [preactivation]
    have : ∀ i, w j i * (t * x i + (1 - t) * y i) = t * (w j i * x i) + (1 - t) * (w j i * y i) := by
      intro i; ring
    simp_rw [this, Finset.sum_add_distrib]
    simp_rw [← Finset.mul_sum, mul_add]
    ring
  simp [selectedAffine]
  simp_rw [preact_linear]
  simp_rw [mul_add]
  have h1 : ∀ x_1, v x_1 * (t * preactivation w b x x_1) = t * (v x_1 * preactivation w b x x_1) := by
    intro x_1; ring
  have h2 : ∀ x_1, v x_1 * ((1 - t) * preactivation w b y x_1) = (1 - t) * (v x_1 * preactivation w b y x_1) := by
    intro x_1; ring
  simp_rw [h1, h2]
  have h3 : ∀ x_1, (if p x_1 then t * (v x_1 * preactivation w b x x_1) + (1 - t) * (v x_1 * preactivation w b y x_1) else 0) =
            t * (if p x_1 then v x_1 * preactivation w b x x_1 else 0) + (1 - t) * (if p x_1 then v x_1 * preactivation w b y x_1 else 0) := by
    intro x_1
    by_cases hx : p x_1 <;> simp [hx]
  simp_rw [h3, Finset.sum_add_distrib]
  simp_rw [← Finset.mul_sum]
  ring

/-- Consequently, the ReLU network itself preserves affine combinations whenever
the two endpoints and their affine combination remain in one activation cell. -/
theorem networkOutput_affineCombination_on_cell {n k : ℕ}
    (w : Fin k → Fin n → ℝ) (b v : Fin k → ℝ) (c t : ℝ)
    (p : Pattern k) (x y : Fin n → ℝ)
    (hx : x ∈ cell w b p) (hy : y ∈ cell w b p)
    (hxy : (fun i => t * x i + (1 - t) * y i) ∈ cell w b p) :
    networkOutput w b v c (fun i => t * x i + (1 - t) * y i) =
      t * networkOutput w b v c x + (1 - t) * networkOutput w b v c y := by
  rw [networkOutput_eq_selectedAffine_of_mem_cell w b v c p hxy,
    selectedAffine_affineCombination,
    networkOutput_eq_selectedAffine_of_mem_cell w b v c p hx,
    networkOutput_eq_selectedAffine_of_mem_cell w b v c p hy]

end ReluActivationCells