/-
# Tropical Reconstruction: Certified Formula Basis Recovery

This file proves that a finite weighted entailment structure can be
reconstructed from its tropical spectrum, and establishes key duality
properties between presentations and spectra.

## Main Results

* `reconstruct_sound` — reconstructed costs match the originals
* `roundtrip_via_canonical` — spectrum ↔ cost roundtrip identity
* `essential_cannot_bypass` — essential edges are irredundant
* `dualSpectrum_determines_cost` — dual spectrum uniquely determines costs
* `threeFormula_edge02_nonessential` — derivable edges are detected
-/

import Mathlib
import Bridges.TropicalStoneDuality.Basic

open Function Set TropicalStoneDuality

namespace TropicalReconstruction

/-! ## §1. Basic Entailment Constructions -/

/-- The identity entailment: only self-derivation at zero cost. -/
def identityEntailment (n : ℕ) : WeightedEntailment n where
  cost i j := if i = j then 0 else ⊤
  cost_refl i := by simp
  cost_triangle i j k := by
    by_cases hij : i = j <;> by_cases hjk : j = k <;> simp_all

/-- A direct-cost entailment from an arbitrary cost function. -/
def directEntailment {n : ℕ} (c : Fin n → Fin n → Trop)
    (hrefl : ∀ i, c i i = 0)
    (htri : ∀ i j k, c i k ≤ c i j + c j k) :
    WeightedEntailment n :=
  ⟨c, hrefl, htri⟩

/-! ## §2. Reconstruction from Spectrum Data -/

/-- Given canonical potential data, reconstruct the cost matrix. -/
def reconstructCost {n : ℕ} (spec : Fin n → Fin n → Trop) :
    Fin n → Fin n → Trop :=
  spec

/-- **Reconstruction Soundness**: canonical potentials recover original costs. -/
theorem reconstruct_sound {n : ℕ} (W : WeightedEntailment n) :
    reconstructCost (fun i => (canonicalPotential W i).val) = W.cost :=
  rfl

/-- **Reconstruction Completeness**: reconstructed costs satisfy axioms. -/
theorem reconstruct_entailment {n : ℕ} (W : WeightedEntailment n) :
    let rc := reconstructCost (fun i => (canonicalPotential W i).val)
    (∀ i, rc i i = 0) ∧ (∀ i j k, rc i k ≤ rc i j + rc j k) :=
  ⟨W.cost_refl, W.cost_triangle⟩

/-! ## §3. Essential Edges and Minimality -/

/-- An edge is essential if it cannot be bypassed via any intermediate vertex. -/
def IsEssentialEdge {n : ℕ} (W : WeightedEntailment n)
    (i k : Fin n) : Prop :=
  W.cost i k < ⊤ ∧ i ≠ k ∧
  ∀ j : Fin n, j ≠ i → j ≠ k →
    W.cost i k < W.cost i j + W.cost j k

/-- Essential edges cannot be bypassed. -/
theorem essential_cannot_bypass {n : ℕ} (W : WeightedEntailment n)
    (i k : Fin n) (he : IsEssentialEdge W i k)
    (j : Fin n) (hji : j ≠ i) (hjk : j ≠ k) :
    W.cost i j + W.cost j k > W.cost i k :=
  he.2.2 j hji hjk

/-- Non-essential finite-cost edges have a cheaper bypass. -/
theorem nonessential_has_witness {n : ℕ} (W : WeightedEntailment n)
    (i k : Fin n) (hik : i ≠ k) (hfin : W.cost i k < ⊤)
    (hne : ¬ IsEssentialEdge W i k) :
    ∃ j : Fin n, j ≠ i ∧ j ≠ k ∧
      W.cost i j + W.cost j k ≤ W.cost i k := by
  unfold IsEssentialEdge at hne
  push_neg at hne
  exact hne hfin hik

/-! ## §4. Spectrum Completeness -/

/-- Every feasible potential is bounded by canonical potentials. -/
theorem spectrum_bounded_by_canonical {n : ℕ} (W : WeightedEntailment n)
    (p : SpecTrop W) (i : Fin n) :
    ∀ j, p.val j ≤ p.val i + (canonicalPotential W i).val j :=
  fun j => p.feasible i j

/-- Canonical potentials form a separating family. -/
theorem canonical_family_separates {n : ℕ} (W : WeightedEntailment n)
    (h : ∀ i j : Fin n, i ≠ j → ∃ k, W.cost k i ≠ W.cost k j) :
    ∀ i j : Fin n, i ≠ j →
      ∃ s : Fin n,
        (canonicalPotential W s).val i ≠ (canonicalPotential W s).val j :=
  h

/-! ## §5. Dual Spectrum -/

/-- The dual spectrum: all functions satisfying the feasibility condition. -/
def dualSpectrum {n : ℕ} (W : WeightedEntailment n) :
    Set (Fin n → Trop) :=
  { v | ∀ i j, v j ≤ v i + W.cost i j }

/-- Canonical potentials lie in the dual spectrum. -/
theorem canonical_in_dualSpectrum {n : ℕ} (W : WeightedEntailment n) (s : Fin n) :
    W.cost s ∈ dualSpectrum W :=
  W.cost_triangle s

/-- Normalized feasible potentials are bounded by the cost. -/
theorem normalized_potential_le_cost {n : ℕ} (W : WeightedEntailment n)
    (v : Fin n → Trop) (hv : v ∈ dualSpectrum W)
    (i j : Fin n) (hvi : v i = 0) :
    v j ≤ W.cost i j := by
  have := hv i j
  rwa [hvi, zero_add] at this

/-- **Roundtrip via Canonical**: extracting canonical potentials and
    reading off costs gives back the original cost matrix. -/
theorem roundtrip_via_canonical {n : ℕ} (W : WeightedEntailment n) (i j : Fin n) :
    W.cost i j = (canonicalPotential W i).val j :=
  rfl

/-- **Dual Spectrum Determines Cost**: entailments with the same
    dual spectrum have the same cost matrices. -/
theorem dualSpectrum_determines_cost {n : ℕ} (W₁ W₂ : WeightedEntailment n)
    (h : dualSpectrum W₁ = dualSpectrum W₂) :
    W₁.cost = W₂.cost := by
  ext i j
  apply le_antisymm
  · have hmem : W₁.cost i ∈ dualSpectrum W₂ := h ▸ canonical_in_dualSpectrum W₁ i
    exact normalized_potential_le_cost W₂ _ hmem i j (W₁.cost_refl i)
  · have hmem : W₂.cost i ∈ dualSpectrum W₁ := h ▸ canonical_in_dualSpectrum W₂ i
    exact normalized_potential_le_cost W₁ _ hmem i j (W₂.cost_refl i)

/-! ## §6. Concrete Examples -/

/-- Reconstruction recovers the three-formula cost matrix. -/
theorem threeFormula_reconstruct :
    reconstructCost (fun i => (canonicalPotential threeFormulaExample i).val) =
    threeFormulaExample.cost :=
  rfl

/-- The edge 0 →(2)→ 1 is essential. -/
theorem threeFormula_edge01_essential :
    IsEssentialEdge threeFormulaExample 0 1 := by
  refine ⟨ENat.coe_lt_top 2, by decide, ?_⟩
  intro ⟨j, hj⟩ hj0 hj1
  interval_cases j <;>
    simp_all [threeFormulaExample, Matrix.cons_val_zero, Matrix.cons_val_one]
  · exact ENat.coe_lt_top 2

/-- The edge 1 →(3)→ 2 is essential. -/
theorem threeFormula_edge12_essential :
    IsEssentialEdge threeFormulaExample 1 2 := by
  refine ⟨ENat.coe_lt_top 3, by decide, ?_⟩
  intro ⟨j, hj⟩ hj1 hj2
  interval_cases j <;>
    simp_all [threeFormulaExample, Matrix.cons_val_zero, Matrix.cons_val_one]
  · exact ENat.coe_lt_top 3

/-- The edge 0 →(5)→ 2 is NOT essential: it factors through vertex 1.
    This demonstrates algorithmic detection of redundant entailment rules. -/
theorem threeFormula_edge02_nonessential :
    ¬ IsEssentialEdge threeFormulaExample 0 2 := by
  intro ⟨_, _, h⟩
  have h1 := h 1 (by decide) (by decide)
  simp [threeFormulaExample, Matrix.cons_val_zero, Matrix.cons_val_one] at h1
  norm_num at h1

end TropicalReconstruction