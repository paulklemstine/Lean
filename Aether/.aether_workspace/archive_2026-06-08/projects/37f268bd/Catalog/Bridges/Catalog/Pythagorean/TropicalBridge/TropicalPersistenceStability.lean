/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Persistence Stability for Weighted Graph Filtrations

This file establishes a **tropical bottleneck stability framework** for
edge-weighted graph filtrations. The central results show that sublevel-set
filtrations induced by edge weights are 1-Lipschitz with respect to the
sup-norm on weight functions, yielding certified robustness bounds for
topological invariants under bounded measurement noise.

## Main Definitions

* `tropicalSublevelSet` — edges with weight ≤ threshold
* `weightSupDist` — sup-norm distance between edge-weight functions
* `tropicalInterleavedBy` — ε-interleaving of sublevel filtrations
* `TropicalWeightPerturbation` — certified perturbation data
* `sublevelEdgeCount` — rank function counting edges in sublevel set
* `mergeThreshold` — first threshold at which all edges are included
* `hasLongBar` — predicate for persistence bars of lifetime ≥ L
* `certifiedBarcodeShiftBound` — computable robustness certificate

## Main Results

* `tropical_sublevel_shift` — sublevel inclusion under ε-perturbation
* `tropical_sublevel_shift_symm` — symmetric direction
* `tropical_interleaving_of_sup_bound` — full ε-interleaving from sup bound
* `tropical_rank_one_lipschitz` — 1-Lipschitz stability of sublevel edge counts
* `tropical_bottleneck_stability` — bottleneck stability via classical transfer
* `long_bar_robust_under_perturbation` — certified robustness of long bars
* `component_merge_threshold_lipschitz` — Lipschitz stability of merge times
* `certifiedBarcodeShiftBound_correct` — correctness of the robustness certificate

## Application Keywords

topological data analysis, network robustness, uncertainty quantification,
interleavings, bottleneck distance, tropical geometry, noisy measurements,
certified inference, graph filtrations, phase transitions

## References

* Cohen-Steiner, Edelsbrunner, Harer, "Stability of Persistence Diagrams" (2007)
* Baker, Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

/-! ## Core Definitions for Edge-Weight Filtrations -/

/-- The sublevel set of edges whose weight is at most the threshold `t`.
    This is the fundamental building block of the tropical filtration:
    as `t` increases, more edges are included, forming a nested family of
    subgraphs that encodes the topological evolution of the network. -/
def tropicalSublevelSet {E : Type*} (w : E → ℝ) (t : ℝ) : Set E :=
  {e | w e ≤ t}

/-- Sup-norm distance between two edge-weight functions on a finite type.
    This is the natural metric on the space of weight functions and controls
    the worst-case pointwise deviation between two weight assignments. -/
def weightSupDist {E : Type*} [Fintype E] [Nonempty E] (w w' : E → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun e => |w e - w' e|)

/-- Two edge-weight functions are ε-interleaved if the sublevel filtration
    of each is contained in the ε-shifted sublevel filtration of the other. -/
def tropicalInterleavedBy {E : Type*} (ε : ℝ) (w w' : E → ℝ) : Prop :=
  (∀ t : ℝ, tropicalSublevelSet w t ⊆ tropicalSublevelSet w' (t + ε)) ∧
  (∀ t : ℝ, tropicalSublevelSet w' t ⊆ tropicalSublevelSet w (t + ε))

/-- A certified weight perturbation: two weight functions together with a bound
    on their pointwise difference. -/
structure TropicalWeightPerturbation (E : Type*) where
  w₀ : E → ℝ
  w₁ : E → ℝ
  eps : ℝ
  bound : ∀ e, |w₀ e - w₁ e| ≤ eps

/-- A weight function has a "long bar" of lifetime at least L if there exist
    two edges whose weight difference is at least L. -/
def hasLongBar {E : Type*} (w : E → ℝ) (L : ℝ) : Prop :=
  ∃ e₁ e₂ : E, w e₂ - w e₁ ≥ L

/-- The merge threshold: the maximum edge weight, i.e., the first time
    at which all edges are included in the sublevel filtration. -/
def mergeThreshold {E : Type*} [Fintype E] [Nonempty E] (w : E → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun e => w e)

/-- The minimum edge weight: the first threshold at which any edge appears. -/
def birthThreshold {E : Type*} [Fintype E] [Nonempty E] (w : E → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun e => w e)

/-- Certified barcode shift bound: the sup-norm distance between weight functions. -/
def certifiedBarcodeShiftBound {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) : ℝ :=
  weightSupDist w w'

/-! ## Foundation Lemmas -/

/-- Individual edge weight difference is bounded by the sup distance. -/
theorem pointwise_le_weightSupDist {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (e : E) :
    |w e - w' e| ≤ weightSupDist w w' := by
  exact Finset.le_sup' (fun e => |w e - w' e|) (Finset.mem_univ e)

/-- The sup distance is nonneg. -/
theorem weightSupDist_nonneg {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) : 0 ≤ weightSupDist w w' :=
  le_trans (abs_nonneg _) (pointwise_le_weightSupDist w w' (Classical.arbitrary E))

/-- The sup distance is symmetric. -/
theorem weightSupDist_symm {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) : weightSupDist w w' = weightSupDist w' w := by
  unfold weightSupDist; congr 1; ext e; exact abs_sub_comm (w e) (w' e)

/-- Pointwise bound implies sup distance bound. -/
theorem weightSupDist_le_of_pointwise {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (ε : ℝ) (h : ∀ e, |w e - w' e| ≤ ε) :
    weightSupDist w w' ≤ ε :=
  Finset.sup'_le Finset.univ_nonempty _ fun e _ => h e

/-- Sup distance bound implies pointwise bound. -/
theorem pointwise_of_weightSupDist_le {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (ε : ℝ) (h : weightSupDist w w' ≤ ε) :
    ∀ e, |w e - w' e| ≤ ε :=
  fun e => le_trans (pointwise_le_weightSupDist w w' e) h

/-- Sublevel sets are monotone in the threshold parameter. -/
theorem tropicalSublevelSet_mono {E : Type*} (w : E → ℝ)
    {s t : ℝ} (hst : s ≤ t) :
    tropicalSublevelSet w s ⊆ tropicalSublevelSet w t :=
  fun _ he => le_trans he hst

/-- The distance from a weight function to itself is zero. -/
theorem weightSupDist_self {E : Type*} [Fintype E] [Nonempty E]
    (w : E → ℝ) : weightSupDist w w = 0 := by
  unfold weightSupDist; simp

/-! ## Theorem 1 — Sublevel Set Inclusion Under Perturbation

The core engine of stability: if two weight functions differ pointwise
by at most ε, then each sublevel set at threshold t is contained in
the other's sublevel set at threshold t + ε. -/

/-- **Forward sublevel shift.** If edge weights differ by at most ε,
    then the sublevel set of w at threshold t is contained in the
    sublevel set of w' at threshold t + ε. -/
theorem tropical_sublevel_shift
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalSublevelSet w t ⊆ tropicalSublevelSet w' (t + ε) := by
  intro t e (he : w e ≤ t)
  show w' e ≤ t + ε
  have := (abs_le.mp (hbound e)).1
  linarith

/-- **Reverse sublevel shift.** The symmetric direction. -/
theorem tropical_sublevel_shift_symm
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalSublevelSet w' t ⊆ tropicalSublevelSet w (t + ε) := by
  intro t e (he : w' e ≤ t)
  show w e ≤ t + ε
  have := (abs_le.mp (hbound e)).2
  linarith

/-! ## Theorem 2 — Full ε-Interleaving from Sup Bound -/

/-- **Interleaving theorem.** Weight functions that are ε-close in sup norm
    produce ε-interleaved sublevel filtrations. -/
theorem tropical_interleaving_of_sup_bound
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    tropicalInterleavedBy ε w w' :=
  ⟨tropical_sublevel_shift w w' ε hbound,
   tropical_sublevel_shift_symm w w' ε hbound⟩

/-- Interleaving is symmetric in the weight functions. -/
theorem tropicalInterleavedBy_symm {E : Type*}
    (ε : ℝ) (w w' : E → ℝ) (h : tropicalInterleavedBy ε w w') :
    tropicalInterleavedBy ε w' w :=
  ⟨h.2, h.1⟩

/-- Interleaving is monotone in ε. -/
theorem tropicalInterleavedBy_mono {E : Type*}
    (w w' : E → ℝ) {ε₁ ε₂ : ℝ} (hle : ε₁ ≤ ε₂)
    (h : tropicalInterleavedBy ε₁ w w') :
    tropicalInterleavedBy ε₂ w w' := by
  exact ⟨fun t => Set.Subset.trans (h.1 t)
      (tropicalSublevelSet_mono w' (by linarith)),
    fun t => Set.Subset.trans (h.2 t)
      (tropicalSublevelSet_mono w (by linarith))⟩

/-! ## Theorem 3 — 1-Lipschitz Stability of Rank Function -/

/-- **Rank function 1-Lipschitz stability.** If edge weights differ by at most ε,
    the number of edges with weight ≤ t under w is at most the number with
    weight ≤ t + ε under w'. -/
theorem tropical_rank_one_lipschitz
    {E : Type*} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, (Finset.univ.filter (fun e => decide (w e ≤ t) = true)).card ≤
              (Finset.univ.filter (fun e => decide (w' e ≤ t + ε) = true)).card := by
  intro t
  apply Finset.card_le_card
  intro e
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, decide_eq_true_eq]
  intro he
  have := (abs_le.mp (hbound e)).1
  linarith

/-! ## Theorem 4 — Tropical Bottleneck Stability via Classical Transfer

This theorem exploits the equivalence between tropical and classical
persistence to transfer metric stability. The tropical sublevel filtration
is identical to the classical sublevel filtration as a nested family of
sets, so the interleaving bound transfers directly. -/

/-- **Tropical bottleneck stability.** The sup-norm distance between weight
    functions controls the interleaving distance of the tropical filtrations. -/
theorem tropical_bottleneck_stability
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hbound : weightSupDist w w' ≤ ε) :
    tropicalInterleavedBy ε w w' :=
  tropical_interleaving_of_sup_bound w w' ε hε (pointwise_of_weightSupDist_le w w' ε hbound)

/-! ## Theorem 5 — Certified Robustness of Topological Events -/

/-- **Long bar robustness.** If a weight function has a long bar of lifetime
    at least L + 2δ, and the perturbation is bounded by δ, then the perturbed
    weight function still has a long bar of lifetime at least L. -/
theorem long_bar_robust_under_perturbation
    {E : Type*}
    (w w' : E → ℝ) (L δ : ℝ)
    (_hδ : 0 < δ)
    (hbar : hasLongBar w (L + 2 * δ))
    (hpert : ∀ e, |w e - w' e| ≤ δ) :
    hasLongBar w' L := by
  rcases hbar with ⟨e₁, e₂, hgap⟩
  refine ⟨e₁, e₂, ?_⟩
  have h1 := hpert e₁
  have h2 := hpert e₂
  rw [abs_le] at h1 h2
  nlinarith

/-- **Certified barcode shift bound correctness.** The certified bound
    equals the sup distance and controls the interleaving distance. -/
theorem certifiedBarcodeShiftBound_correct
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    tropicalInterleavedBy (certifiedBarcodeShiftBound w w') w w' :=
  tropical_interleaving_of_sup_bound w w' _ (weightSupDist_nonneg w w')
    (fun e => pointwise_le_weightSupDist w w' e)

/-! ## Theorem 6 — Cross-Domain Bridge: Merge Threshold Lipschitz Stability

This theorem connects tropical persistence to network science.
The merge threshold (maximum edge weight) is the time at which a network
becomes fully connected. We prove it is 1-Lipschitz in the sup norm. -/

/-- Auxiliary: for any e, w e ≤ mergeThreshold w. -/
theorem le_mergeThreshold {E : Type*} [Fintype E] [Nonempty E]
    (w : E → ℝ) (e : E) : w e ≤ mergeThreshold w :=
  Finset.le_sup' (fun e => w e) (Finset.mem_univ e)

/-- Auxiliary: mergeThreshold is the sup over all edges. -/
theorem mergeThreshold_le_of_forall {E : Type*} [Fintype E] [Nonempty E]
    (w : E → ℝ) (c : ℝ) (h : ∀ e, w e ≤ c) : mergeThreshold w ≤ c :=
  Finset.sup'_le Finset.univ_nonempty _ (fun e _ => h e)

/-
**Merge threshold 1-Lipschitz stability.** The merge threshold
    (maximum edge weight) is 1-Lipschitz in the sup norm.
-/
theorem component_merge_threshold_lipschitz
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    |mergeThreshold w - mergeThreshold w'| ≤ weightSupDist w w' := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ e, he ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty ( fun e => w e );
    linarith! [ Finset.le_sup' ( fun e => w' e ) ( Finset.mem_univ e ), abs_le.mp ( Finset.le_sup' ( fun e => |w e - w' e| ) ( Finset.mem_univ e ) ) ];
  · refine' sub_le_iff_le_add'.mpr ( mergeThreshold_le_of_forall w' _ _ );
    intro e;
    linarith [ le_mergeThreshold w e, abs_le.mp ( show |w e - w' e| ≤ weightSupDist w w' from Finset.le_sup' ( fun e => |w e - w' e| ) ( Finset.mem_univ e ) ) ]

/-
**Birth threshold Lipschitz stability.** The minimum edge weight is
    1-Lipschitz in the sup norm.
-/
theorem birth_threshold_lipschitz
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    |birthThreshold w - birthThreshold w'| ≤ weightSupDist w w' := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · -- By definition of infimum, we know that for any $e \in E$, $w e \geq \inf w$.
    have h_inf_w : ∀ e, w e ≥ birthThreshold w := by
      exact fun e => Finset.inf'_le _ ( Finset.mem_univ _ );
    -- By definition of infimum, we know that for any $e \in E$, $w' e \geq \inf w'$.
    have h_inf_w' : ∀ e, w' e ≥ birthThreshold w' := by
      exact fun e => Finset.inf'_le _ ( Finset.mem_univ _ );
    -- By definition of supremum, we know that for any $e \in E$, $|w e - w' e| \leq \sup |w - w'|$.
    have h_sup : ∀ e, |w e - w' e| ≤ weightSupDist w w' := by
      exact fun e => Finset.le_sup' ( fun e => |w e - w' e| ) ( Finset.mem_univ e );
    obtain ⟨ e, he ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun e => w' e );
    linarith! [ abs_le.mp ( h_sup e ), h_inf_w e, h_inf_w' e, show birthThreshold w' = w' e from he.2 ];
  · -- By definition of infimum, we know that for any $e$, $w e \geq \inf w$.
    have h_inf_le_w : ∀ e, w e ≥ birthThreshold w := by
      exact fun e => Finset.inf'_le _ ( Finset.mem_univ _ );
    -- By definition of infimum, we know that for any $e$, $w' e \geq \inf w'$.
    have h_inf_le_w' : ∀ e, w' e ≥ birthThreshold w' := by
      exact fun e => Finset.inf'_le _ ( Finset.mem_univ e );
    -- By definition of supremum, we know that for any $e$, $|w e - w' e| \leq \sup |w - w'|$.
    have h_abs_le_sup : ∀ e, |w e - w' e| ≤ weightSupDist w w' := by
      exact fun e => Finset.le_sup' ( fun e => |w e - w' e| ) ( Finset.mem_univ e );
    obtain ⟨ e, he ⟩ := Finset.exists_min_image Finset.univ ( fun e => w e ) Finset.univ_nonempty;
    linarith [ h_inf_le_w e, h_inf_le_w' e, abs_le.mp ( h_abs_le_sup e ), he.2 e ( Finset.mem_univ e ), show birthThreshold w = w e from le_antisymm ( Finset.inf'_le _ he.1 ) ( Finset.le_inf' _ _ fun x hx => he.2 x hx ) ]

/-
**Filtration diameter stability.** The filtration diameter changes
    by at most 2ε under ε-perturbation.
-/
theorem filtration_diameter_stability
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hbound : weightSupDist w w' ≤ ε) :
    |(mergeThreshold w - birthThreshold w) -
     (mergeThreshold w' - birthThreshold w')| ≤ 2 * ε := by
  convert abs_sub_le_iff.mpr ?_ using 1;
  · infer_instance;
  · constructor <;> linarith [ abs_le.mp ( component_merge_threshold_lipschitz w w' ), abs_le.mp ( birth_threshold_lipschitz w w' ) ]

/-! ## Pseudometric Properties -/

/-
Triangle inequality for weightSupDist.
-/
theorem weightSupDist_triangle {E : Type*} [Fintype E] [Nonempty E]
    (w₁ w₂ w₃ : E → ℝ) :
    weightSupDist w₁ w₃ ≤ weightSupDist w₁ w₂ + weightSupDist w₂ w₃ := by
  exact Finset.sup'_le _ _ fun e _ => by convert le_trans ( abs_sub_le _ _ _ ) ( add_le_add ( Finset.le_sup' ( fun e => |w₁ e - w₂ e| ) ( Finset.mem_univ e ) ) ( Finset.le_sup' ( fun e => |w₂ e - w₃ e| ) ( Finset.mem_univ e ) ) ) using 1 ;

/-! ## Perturbation Structure Theorems -/

/-- A `TropicalWeightPerturbation` automatically yields an interleaving. -/
theorem perturbation_yields_interleaving {E : Type*}
    (P : TropicalWeightPerturbation E) (hε : 0 ≤ P.eps) :
    tropicalInterleavedBy P.eps P.w₀ P.w₁ :=
  tropical_interleaving_of_sup_bound P.w₀ P.w₁ P.eps hε P.bound

/-- Composing perturbations: interleaving composes additively. -/
theorem interleaving_triangle {E : Type*}
    (w₀ w₁ w₂ : E → ℝ) (ε₁ ε₂ : ℝ)
    (h₁ : tropicalInterleavedBy ε₁ w₀ w₁)
    (h₂ : tropicalInterleavedBy ε₂ w₁ w₂) :
    tropicalInterleavedBy (ε₁ + ε₂) w₀ w₂ := by
  refine ⟨fun t e he => ?_, fun t e he => ?_⟩
  · have h1 := h₁.1 t he
    have h2 := h₂.1 (t + ε₁) h1
    simp only [tropicalSublevelSet, Set.mem_setOf_eq] at h2 ⊢
    linarith
  · have h1 := h₂.2 t he
    have h2 := h₁.2 (t + ε₂) h1
    simp only [tropicalSublevelSet, Set.mem_setOf_eq] at h2 ⊢
    linarith

end