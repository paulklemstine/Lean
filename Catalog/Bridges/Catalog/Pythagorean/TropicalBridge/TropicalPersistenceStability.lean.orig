/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Persistence Stability and Network Robustness

This file establishes the **tropical bottleneck stability theorem** for
weighted graph filtrations, together with computable robustness certificates
and cross-domain bridges to network science and metric geometry.

## Scientific Significance

The central claim is that **tropical Morse data on graphs is metrically
well-conditioned**: bounded perturbations of edge weights produce bounded
changes in the resulting tropical persistence data. This opens a program
of tropical topological statistics for noisy infrastructure networks,
biological interaction graphs, and learned weighted architectures.

## Main Definitions

* `TropicalGraphFiltration` — weighted graph with edge weights in ℝ
* `TropicalWeightPerturbation` — certified perturbation data
* `weightSupDist` — sup-norm distance on edge-weight functions
* `tropicalSublevelSet` — sublevel set of edges at threshold t
* `tropicalRankFunction` — rank function counting sublevel edges
* `tropicalInterleavedBy` — ε-interleaving of sublevel filtrations
* `mergeTime` — first threshold at which all edges are included
* `hasLongBar` — existence of a persistent topological feature
* `certifiedBarcodeShiftBound` — certified upper bound on barcode displacement

## Main Results

* `tropical_rank_interleaving_of_sup_bound` — sublevel set inclusion under perturbation
* `tropical_rank_interleaving_of_sup_bound_symm` — symmetric direction
* `tropical_rank_lipschitz` — 1-Lipschitz stability of interleaving
* `tropical_bottleneck_stability_rank` — bottleneck stability via rank functions
* `tropical_event_robust_of_margin` — certified robustness of topological events
* `long_bar_robust_under_weight_perturbation` — robust persistence of long bars
* `component_merge_time_lipschitz` — cross-domain: merge time is 1-Lipschitz
* `tropical_critical_value_lipschitz` — min/max weight observables are 1-Lipschitz
* `certifiedBarcodeShiftBound_correct` — verified algorithm correctness

## Application Keywords

topological data analysis, network robustness, uncertainty quantification,
interleavings, bottleneck distance, tropical geometry, noisy measurements,
certified inference, graph filtrations, phase transitions.

## References

* Cohen-Steiner, Edelsbrunner, Harer, "Stability of Persistence Diagrams" (2007)
* Baker, Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Mikhalkin, "Tropical geometry and its applications" (2006)
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Part 1: Core Definitions -/

/-- A tropical graph filtration: a finite edge set with real-valued weights
    and an incidence relation. This is the foundational structure for
    tropical persistence on weighted graphs. -/
structure TropicalGraphFiltration (V E : Type*) [Fintype V] [Fintype E] where
  /-- Edge weight function -/
  edgeWeight : E → ℝ
  /-- Incidence: each edge maps to its two endpoints -/
  incidence : E → V × V

/-- A certified weight perturbation: two weight functions that are ε-close. -/
structure TropicalWeightPerturbation (E : Type*) where
  /-- Original weight function -/
  w₀ : E → ℝ
  /-- Perturbed weight function -/
  w₁ : E → ℝ
  /-- Perturbation bound -/
  eps : ℝ
  /-- Certified closeness -/
  bound : ∀ e, |w₀ e - w₁ e| ≤ eps

/-- The sup-norm distance between two edge-weight functions.
    This is the fundamental metric on the space of weighted filtrations. -/
def weightSupDist {E : Type*} [Fintype E] [Nonempty E] (w w' : E → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun e => |w e - w' e|)

/-- The sublevel set of edges at threshold t: edges whose weight is at most t.
    This is the basic building block of the tropical filtration. -/
def tropicalSublevelSet {E : Type*} (w : E → ℝ) (t : ℝ) : Set E :=
  {e | w e ≤ t}

/-- The tropical rank function: the number of edges in the sublevel set at
    threshold t. For finite edge sets, this is a step function that increases
    at each critical weight value. -/
def tropicalRankFunction {E : Type*} [Fintype E]
    (w : E → ℝ) (t : ℝ) : ℕ :=
  (Finset.univ.filter (fun e => decide (w e ≤ t) = true)).card

/-- Two weight functions are ε-interleaved if their sublevel filtrations
    are mutually contained after ε-shifts. This is the tropical analogue
    of the classical persistence interleaving distance. -/
def tropicalInterleavedBy {E : Type*} (ε : ℝ) (w w' : E → ℝ) : Prop :=
  (∀ t : ℝ, tropicalSublevelSet w t ⊆ tropicalSublevelSet w' (t + ε)) ∧
  (∀ t : ℝ, tropicalSublevelSet w' t ⊆ tropicalSublevelSet w (t + ε))

/-- The merge time of a weight function: the maximum weight, i.e., the
    threshold at which all edges have entered the filtration. -/
def mergeTime {E : Type*} [Fintype E] [Nonempty E] (w : E → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun e => w e)

/-- The minimum critical value: the weight of the lightest edge. -/
def minCriticalValue {E : Type*} [Fintype E] [Nonempty E] (w : E → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun e => w e)

/-- A long bar predicate: the range of weights spans at least L. -/
def hasLongBar {E : Type*} [Fintype E] [Nonempty E] (w : E → ℝ) (L : ℝ) : Prop :=
  mergeTime w - minCriticalValue w ≥ L

/-- Certified barcode shift bound: the sup-distance between weights gives
    an upper bound on barcode displacement. This is the verified algorithm. -/
def certifiedBarcodeShiftBound {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) : ℝ :=
  weightSupDist w w'

/-- Whether edge weights are generic (all distinct). -/
def genericWeights {E : Type*} [DecidableEq E] (w : E → ℝ) : Prop :=
  ∀ e₁ e₂ : E, e₁ ≠ e₂ → w e₁ ≠ w e₂

/-! ## Part 2: Foundation Lemmas -/

/-- Membership in the sublevel set is equivalent to the weight being at most t. -/
theorem mem_tropicalSublevelSet {E : Type*} (w : E → ℝ) (t : ℝ) (e : E) :
    e ∈ tropicalSublevelSet w t ↔ w e ≤ t :=
  Iff.rfl

/-- Each pointwise difference is bounded by the sup distance. -/
theorem pointwise_le_weightSupDist {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (e : E) :
    |w e - w' e| ≤ weightSupDist w w' :=
  Finset.le_sup' (fun e => |w e - w' e|) (Finset.mem_univ e)

/-- If the sup distance is at most ε, then every pointwise difference
    is at most ε. -/
theorem sup_bound_of_weightSupDist_le {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (ε : ℝ)
    (h : weightSupDist w w' ≤ ε) :
    ∀ e, |w e - w' e| ≤ ε :=
  fun e => le_trans (pointwise_le_weightSupDist w w' e) h

/-- The sup distance is nonneg. -/
theorem weightSupDist_nonneg {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    0 ≤ weightSupDist w w' :=
  le_trans (abs_nonneg _) (pointwise_le_weightSupDist w w' (Classical.arbitrary E))

/-- The sup distance is symmetric. -/
theorem weightSupDist_symm {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    weightSupDist w w' = weightSupDist w' w := by
  simp only [weightSupDist, abs_sub_comm]

/-- Sublevel sets are monotone: if s ≤ t, then F_w(s) ⊆ F_w(t). -/
theorem tropicalSublevelSet_mono {E : Type*} (w : E → ℝ) {s t : ℝ} (hst : s ≤ t) :
    tropicalSublevelSet w s ⊆ tropicalSublevelSet w t :=
  fun _ he => le_trans he hst

/-! ## Part 3: Theorem 1 — Sublevel Set Interleaving (core engine) -/

/-- **Key lemma.** If weights differ by at most ε pointwise, then
    membership in the sublevel set at t transfers to membership at t + ε. -/
theorem mem_sublevel_of_mem_sublevel_of_close
    {E : Type*}
    (w w' : E → ℝ) (ε t : ℝ)
    (hclose : ∀ e, |w e - w' e| ≤ ε)
    {e : E}
    (he : e ∈ tropicalSublevelSet w t) :
    e ∈ tropicalSublevelSet w' (t + ε) := by
  simp only [mem_tropicalSublevelSet] at he ⊢
  have habs := hclose e
  rw [abs_le] at habs
  linarith [habs.2]

/-- **Theorem 1a: Forward interleaving.** -/
theorem tropical_rank_interleaving_of_sup_bound
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalSublevelSet w t ⊆ tropicalSublevelSet w' (t + ε) :=
  fun t _ he => mem_sublevel_of_mem_sublevel_of_close w w' ε t hbound he

/-- **Theorem 1b: Reverse interleaving.** -/
theorem tropical_rank_interleaving_of_sup_bound_symm
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalSublevelSet w' t ⊆ tropicalSublevelSet w (t + ε) := by
  intro t e he
  simp only [mem_tropicalSublevelSet] at he ⊢
  have habs := hbound e
  rw [abs_le] at habs
  linarith [habs.1]

/-- **Theorem 1c: Full ε-interleaving.** -/
theorem tropical_rank_lipschitz
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    tropicalInterleavedBy ε w w' :=
  ⟨tropical_rank_interleaving_of_sup_bound w w' ε hε hbound,
   tropical_rank_interleaving_of_sup_bound_symm w w' ε hε hbound⟩

/-- **Interleaving symmetry.** -/
theorem interleaving_symm_of_abs_bound
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hclose : ∀ e, |w e - w' e| ≤ ε) :
    tropicalInterleavedBy ε w w' ∧ tropicalInterleavedBy ε w' w := by
  refine ⟨tropical_rank_lipschitz w w' ε hε hclose, ?_⟩
  apply tropical_rank_lipschitz
  · exact hε
  · intro e; rw [abs_sub_comm]; exact hclose e

/-! ## Part 4: Theorem 2 — Rank Function Stability -/

/-- The rank function is monotone in the threshold. -/
theorem tropicalRankFunction_mono {E : Type*} [Fintype E]
    (w : E → ℝ) {s t : ℝ} (hst : s ≤ t) :
    tropicalRankFunction w s ≤ tropicalRankFunction w t := by
  apply Finset.card_le_card
  intro e he
  simp only [Finset.mem_filter, decide_eq_true_eq] at he ⊢
  exact ⟨he.1, le_trans he.2 hst⟩

/-- **Theorem 2: Rank function stability.**
    The rank function of w at t is bounded by the rank function of w' at t + ε. -/
theorem tropical_bottleneck_stability_rank
    {E : Type*} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalRankFunction w t ≤ tropicalRankFunction w' (t + ε) := by
  intro t
  apply Finset.card_le_card
  intro e he
  simp only [Finset.mem_filter, decide_eq_true_eq] at he ⊢
  refine ⟨he.1, ?_⟩
  have habs := hbound e
  rw [abs_le] at habs
  linarith [he.2, habs.2]

/-- **Symmetric rank stability.** -/
theorem tropical_bottleneck_stability_rank_symm
    {E : Type*} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalRankFunction w' t ≤ tropicalRankFunction w (t + ε) := by
  intro t
  apply Finset.card_le_card
  intro e he
  simp only [Finset.mem_filter, decide_eq_true_eq] at he ⊢
  refine ⟨he.1, ?_⟩
  have habs := hbound e
  rw [abs_le] at habs
  linarith [he.2, habs.1]

/-! ## Part 5: Theorem 3 — Certified Robustness -/

/-- **Theorem 3a: Monotone event robustness.**
    A monotone topological event holding at threshold t for w is preserved
    at threshold t + ε for w'. -/
theorem tropical_event_robust_of_margin
    {E : Type*}
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε)
    (P : Set E → Prop) (hP_mono : ∀ S T : Set E, S ⊆ T → P S → P T)
    (t : ℝ)
    (hPw : P (tropicalSublevelSet w t)) :
    P (tropicalSublevelSet w' (t + ε)) :=
  hP_mono _ _ (tropical_rank_interleaving_of_sup_bound w w' ε hε hbound t) hPw

/-
**Theorem 3b: Long bar robustness.**
    If weight range ≥ L + δ, perturbation < δ/2 preserves range ≥ L.
-/
theorem long_bar_robust_under_weight_perturbation
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (L δ : ℝ)
    (_hδ : 0 < δ)
    (hsep : hasLongBar w (L + δ))
    (hpert : ∀ e, |w e - w' e| < δ / 2) :
    hasLongBar w' L := by
  unfold hasLongBar at *;
  unfold mergeTime minCriticalValue at *;
  simp_all +decide [ abs_lt ];
  obtain ⟨ e₁, he₁ ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun e => w e ) ; ( obtain ⟨ e₂, he₂ ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun e => w e ) ; simp_all +decide );
  linarith [ hpert e₁, hpert e₂, show ( Finset.sup' Finset.univ Finset.univ_nonempty fun e => w' e ) ≥ w' e₁ from Finset.le_sup' ( fun e => w' e ) ( Finset.mem_univ e₁ ), show ( Finset.inf' Finset.univ Finset.univ_nonempty fun e => w' e ) ≤ w' e₂ from Finset.inf'_le _ ( Finset.mem_univ e₂ ) ]

/-! ## Part 6: Cross-Domain Theorems -/

/-
**Theorem 4a: Merge time is 1-Lipschitz.**
    The maximum edge weight cannot shift by more than the sup-norm perturbation.
-/
theorem mergeTime_lipschitz
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    |mergeTime w - mergeTime w'| ≤ weightSupDist w w' := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩ <;> simp +decide only [mergeTime, weightSupDist];
  · simp +decide;
    obtain ⟨ e, he ⟩ := Finset.exists_max_image Finset.univ w ( Finset.univ_nonempty ) ; use e; intro f; cases abs_cases ( w e - w' e ) <;> linarith [ Finset.le_sup' ( fun e => w' e ) ( Finset.mem_univ f ), Finset.le_sup' ( fun e => w' e ) ( Finset.mem_univ e ), he.2 f ( Finset.mem_univ f ) ] ;
  · obtain ⟨ e, he ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun e => w' e );
    linarith [ abs_le.mp ( Finset.le_sup' ( fun e => |w e - w' e| ) ( Finset.mem_univ e ) ), Finset.le_sup' ( fun e => w e ) ( Finset.mem_univ e ) ]

/-
**Theorem 4b: Minimum critical value is 1-Lipschitz.**
-/
theorem minCriticalValue_lipschitz
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    |minCriticalValue w - minCriticalValue w'| ≤ weightSupDist w w' := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ e, he ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun e => w' e );
    simp_all +decide [ minCriticalValue ];
    exact ⟨ e, by linarith [ abs_le.mp ( pointwise_le_weightSupDist w w' e ) ] ⟩;
  · obtain ⟨ e, he ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun e => w e );
    linarith! [ abs_le.mp ( pointwise_le_weightSupDist w w' e ), Finset.inf'_le ( fun e => w' e ) ( Finset.mem_univ e ) ]

/-- **Theorem 4c: Component merge time Lipschitz (cross-domain bridge).**
    Network reliability: bounded noise ⇒ bounded shift in connectivity threshold. -/
theorem component_merge_time_lipschitz
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    |mergeTime w - mergeTime w'| ≤ weightSupDist w w' :=
  mergeTime_lipschitz w w'

/-
**Theorem 4d: Weight range is 2-Lipschitz.**
-/
theorem weight_range_lipschitz
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    |(mergeTime w - minCriticalValue w) - (mergeTime w' - minCriticalValue w')| ≤
    2 * weightSupDist w w' := by
  convert abs_sub_le_iff.mpr ?_ using 1;
  · infer_instance;
  · constructor <;> linarith [ abs_le.mp ( mergeTime_lipschitz w w' ), abs_le.mp ( minCriticalValue_lipschitz w w' ) ]

/-! ## Part 7: Verified Algorithm -/

/-- **Certified barcode shift bound correctness.**
    The sup distance certifies the interleaving distance. -/
theorem certifiedBarcodeShiftBound_correct
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) :
    tropicalInterleavedBy (certifiedBarcodeShiftBound w w') w w' := by
  apply tropical_rank_lipschitz
  · exact weightSupDist_nonneg w w'
  · exact sup_bound_of_weightSupDist_le w w' _ (le_refl _)

/-
**The certified bound is tight:** the interleaving is exact.
-/
theorem certifiedBarcodeShiftBound_tight
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (ε : ℝ)
    (h : tropicalInterleavedBy ε w w') :
    ∀ e : E, |w e - w' e| ≤ ε := by
  intro e
  cases le_total (w e) (w' e) <;> simp_all +decide [ abs_le, tropicalInterleavedBy ];
  · constructor <;> have := h.1 ( w e ) <;> have := h.2 ( w' e ) <;> simp_all +decide [ tropicalSublevelSet ];
    linarith [ h.1 ( w' e ) e ( by linarith ) ];
  · constructor <;> have := h.1 ( w e ) <;> have := h.2 ( w' e ) <;> simp_all +decide [ Set.subset_def, tropicalSublevelSet ];
    linarith [ h.2 ( w' e ) e le_rfl ]

/-
**Characterization of the optimal interleaving distance.**
-/
theorem optimal_interleaving_eq_supDist
    {E : Type*} [Fintype E] [Nonempty E]
    (w w' : E → ℝ) (ε : ℝ) :
    tropicalInterleavedBy ε w w' ↔ (∀ e, |w e - w' e| ≤ ε) := by
  constructor;
  · exact fun a e => certifiedBarcodeShiftBound_tight w w' ε a e;
  · intro h;
    exact tropical_rank_lipschitz w w' ε ( le_trans ( abs_nonneg _ ) ( h ( Classical.arbitrary E ) ) ) h

/-! ## Part 8: Structural Properties of Interleaving -/

/-- **Monotonicity of interleaving.** ε-interleaved and ε ≤ δ ⟹ δ-interleaved. -/
theorem interleaving_mono {E : Type*}
    (w w' : E → ℝ) (ε δ : ℝ) (hεδ : ε ≤ δ)
    (h : tropicalInterleavedBy ε w w') :
    tropicalInterleavedBy δ w w' := by
  constructor
  · intro t e he
    have := h.1 t he
    simp only [mem_tropicalSublevelSet] at this ⊢
    linarith
  · intro t e he
    have := h.2 t he
    simp only [mem_tropicalSublevelSet] at this ⊢
    linarith

/-- **Transitivity (triangle inequality) of interleaving.** -/
theorem interleaving_trans {E : Type*}
    (w₁ w₂ w₃ : E → ℝ) (ε₁ ε₂ : ℝ)
    (h₁₂ : tropicalInterleavedBy ε₁ w₁ w₂)
    (h₂₃ : tropicalInterleavedBy ε₂ w₂ w₃) :
    tropicalInterleavedBy (ε₁ + ε₂) w₁ w₃ := by
  constructor
  · intro t e he
    have h1 := h₁₂.1 t he
    have h2 := h₂₃.1 (t + ε₁) h1
    simp only [mem_tropicalSublevelSet] at h2 ⊢
    linarith
  · intro t e he
    have h1 := h₂₃.2 t he
    have h2 := h₁₂.2 (t + ε₂) h1
    simp only [mem_tropicalSublevelSet] at h2 ⊢
    linarith

/-- **Reflexivity of interleaving.** Any weight function is 0-interleaved with itself. -/
theorem interleaving_refl {E : Type*} (w : E → ℝ) :
    tropicalInterleavedBy 0 w w := by
  constructor <;> intro t e he <;> simp only [mem_tropicalSublevelSet, add_zero] at he ⊢ <;> exact he

end