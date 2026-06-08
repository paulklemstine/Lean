/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Persistence Barcode for Graph Filtrations

This file develops a **tropical persistence barcode** theory for graph
filtrations relative to a basepoint `q`. The theory tracks both
homological cycles and **q-visibility** phenomena.

## Main Results

* `tropicalKernelDim_step_decomposition` — one-step increment decomposes
    into cycle rank change plus visibility change
* `tropicalKernelDim_of_barcode` — global reconstruction via telescoping
* `tropicalDelta_eq_H1_plus_visibility` — cross-domain decomposition
* `extractEvent_delta_eq` — event extraction is faithful
-/

import Mathlib
import Pythagorean.TropicalBridge.Defs

open Finset BigOperators Classical

namespace TropicalPersistence

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Filtration Event Structure -/

/-- A filtration event encodes the combinatorial data of a single step
    in a graph filtration relative to a basepoint. -/
structure TropicalFiltrationEvent where
  /-- Number of new independent cycles created -/
  cycleBirth : ℕ
  /-- Number of new q-visible components born -/
  qVisibleBirth : ℕ
  /-- Number of q-invisible components destroyed by mergers -/
  invisibleMergeDeath : ℕ

/-- The signed delta of a filtration event. -/
def TropicalFiltrationEvent.delta (e : TropicalFiltrationEvent) : ℤ :=
  ↑e.cycleBirth + ↑e.qVisibleBirth - ↑e.invisibleMergeDeath

/-! ## Filtration Step Analysis -/

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The signed change in cycle rank when inserting vertex `v` into `S`. -/
noncomputable def cycleRankDelta (S : Finset V) (v : V) : ℤ :=
  (inducedCycleRank G (insert v S) : ℤ) - (inducedCycleRank G S : ℤ)

/-- The signed change in q-visible component count. -/
noncomputable def qVisibleDelta (q : V) (S : Finset V) (v : V) : ℤ :=
  (qVisibleComponentCount G q (insert v S) : ℤ) - (qVisibleComponentCount G q S : ℤ)

/-- The signed change in tropical kernel dimension. -/
noncomputable def tropicalDelta (q : V) (S : Finset V) (v : V) : ℤ :=
  (tropicalKernelDim G q (insert v S) : ℤ) - (tropicalKernelDim G q S : ℤ)

/-- **One-step decomposition theorem.** The change in tropical kernel dimension
    decomposes into cycle rank change plus visibility change. -/
theorem tropicalKernelDim_step_decomposition
    (q : V) (S : Finset V) (v : V) :
    tropicalDelta G q S v = cycleRankDelta G S v + qVisibleDelta G q S v := by
  simp only [tropicalDelta, cycleRankDelta, qVisibleDelta, tropicalKernelDim]
  omega

/-! ## Filtration Event Delta Along Lists -/

/-- The signed change in tropical kernel dimension between consecutive stages. -/
noncomputable def filtrationEventDelta (q : V) (F : List (Finset V)) (k : ℕ) : ℤ :=
  if h : k + 1 < F.length then
    (tropicalKernelDim G q (F.get ⟨k + 1, h⟩) : ℤ) -
    (tropicalKernelDim G q (F.get ⟨k, by omega⟩) : ℤ)
  else 0

/-- **Filtration step formula.** -/
theorem tropicalKernelDim_filtration_sum_events
    (q : V) (F : List (Finset V))
    (_hmono : F.Chain' (· ⊆ ·))
    (_hq : ∀ S ∈ F, q ∉ S)
    (k : ℕ) (hk : k + 1 < F.length) :
    (tropicalKernelDim G q (F.get ⟨k+1, hk⟩) : ℤ)
      - tropicalKernelDim G q (F.get ⟨k, by omega⟩)
    = filtrationEventDelta G q F k := by
  unfold filtrationEventDelta
  rw [dif_pos hk]

/-! ## Telescoping Sum -/

/-- **Telescoping sum lemma.** -/
theorem sum_of_successive_differences (f : ℕ → ℤ) (n : ℕ) :
    ∑ i ∈ Finset.range n, (f (i + 1) - f i) = f n - f 0 := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ, ih]
    ring

/-! ## Barcode Reconstruction Theorem -/

/-
**Barcode reconstruction theorem.** The tropical kernel dimension at
    any stage of a filtration is determined by the initial dimension plus
    the cumulative sum of event deltas.
-/
theorem tropicalKernelDim_of_barcode
    (q : V) (F : List (Finset V))
    (_hmono : F.Chain' (· ⊆ ·))
    (_hq : ∀ S ∈ F, q ∉ S)
    (_hne : F ≠ [])
    (k : ℕ) (hk : k < F.length) :
    (tropicalKernelDim G q (F.get ⟨k, hk⟩) : ℤ)
      =
    (tropicalKernelDim G q (F.get ⟨0, by omega⟩) : ℤ)
      + ∑ i ∈ Finset.range k, filtrationEventDelta G q F i := by
  induction' k with k ih;
  · simp +decide;
  · convert congr_arg ( fun x : ℤ => x + filtrationEventDelta G q F k ) ( ih ( Nat.lt_of_succ_lt hk ) ) using 1;
    · grind +suggestions;
    · rw [ Finset.sum_range_succ, add_assoc ]

/-! ## Tropical Persistence Barcode -/

/-- A **tropical filtration**. -/
structure TropicalFiltration (W : Type*) [DecidableEq W] where
  stages : List (Finset W)
  monotone : stages.Chain' (· ⊆ ·)

/-- The **tropical persistence barcode**: sequence of signed dimension changes. -/
noncomputable def tropicalPersistenceBarcode (q : V) (F : List (Finset V)) :
    List ℤ :=
  (List.range (F.length - 1)).map (filtrationEventDelta G q F)

/-- The dimension sequence of a filtration. -/
noncomputable def computeDims (q : V) (F : List (Finset V)) : List ℕ :=
  F.map (tropicalKernelDim G q)

/-- Reconstruct dimensions from initial value and event deltas. -/
def reconstructDimsAux (init : ℤ) (deltas : List ℤ) : List ℤ :=
  deltas.scanl (fun acc d => acc + d) init

/-- Length of the barcode. -/
theorem computeBarcode_correct_length
    (q : V) (F : List (Finset V)) :
    (tropicalPersistenceBarcode G q F).length = F.length - 1 := by
  simp [tropicalPersistenceBarcode]

/-! ## Base Cases -/

/-
The cycle rank of the empty set is zero.
-/
theorem inducedCycleRank_empty : inducedCycleRank G (∅ : Finset V) = 0 := by
  exact?

/-
There are no q-visible components in the empty set.
-/
theorem qVisibleComponentCount_empty (q : V) :
    qVisibleComponentCount G q (∅ : Finset V) = 0 := by
  convert Fintype.card_eq_zero_iff.mpr ?_;
  exact ⟨ fun c => by cases c ; unfold isQVisibleComponent at * ; aesop ⟩

/-- **Empty set base case.** -/
theorem tropicalKernelDim_empty (q : V) :
    tropicalKernelDim G q (∅ : Finset V) = 0 := by
  simp [tropicalKernelDim, inducedCycleRank_empty, qVisibleComponentCount_empty]

/-! ## Cross-Domain Bridge -/

/-- The change in cycle rank between consecutive filtration stages. -/
noncomputable def graphH1RankDelta (F : List (Finset V)) (k : ℕ) : ℤ :=
  if h : k + 1 < F.length then
    (inducedCycleRank G (F.get ⟨k + 1, h⟩) : ℤ) -
    (inducedCycleRank G (F.get ⟨k, by omega⟩) : ℤ)
  else 0

/-- **Cross-domain decomposition.** The tropical event delta decomposes into
    the H₁ delta plus the visibility delta. -/
theorem tropicalDelta_eq_H1_plus_visibility
    (q : V) (F : List (Finset V)) (k : ℕ) (hk : k + 1 < F.length) :
    filtrationEventDelta G q F k =
      graphH1RankDelta G F k +
      ((qVisibleComponentCount G q (F.get ⟨k+1, hk⟩) : ℤ) -
       (qVisibleComponentCount G q (F.get ⟨k, by omega⟩) : ℤ)) := by
  unfold filtrationEventDelta graphH1RankDelta
  rw [dif_pos hk, dif_pos hk]
  simp only [tropicalKernelDim]
  omega

/-- **Visibility-nonneg implies tropical dominates H₁.** -/
theorem graphH1RankDelta_le_tropicalDelta
    (q : V) (F : List (Finset V)) (k : ℕ) (hk : k + 1 < F.length)
    (hvis : (qVisibleComponentCount G q (F.get ⟨k, by omega⟩) : ℤ) ≤
            (qVisibleComponentCount G q (F.get ⟨k+1, hk⟩) : ℤ)) :
    graphH1RankDelta G F k ≤ filtrationEventDelta G q F k := by
  rw [tropicalDelta_eq_H1_plus_visibility G q F k hk]
  linarith

/-! ## Event Extraction -/

/-- Extract a `TropicalFiltrationEvent` from a single vertex-insertion step. -/
noncomputable def extractEvent (q : V) (S : Finset V) (v : V) :
    TropicalFiltrationEvent where
  cycleBirth := max (inducedCycleRank G (insert v S)) (inducedCycleRank G S)
      - inducedCycleRank G S
  qVisibleBirth := max (qVisibleComponentCount G q (insert v S))
      (qVisibleComponentCount G q S) - qVisibleComponentCount G q S
  invisibleMergeDeath :=
    (max (inducedCycleRank G S) (inducedCycleRank G (insert v S))
      - inducedCycleRank G (insert v S)) +
    (max (qVisibleComponentCount G q S) (qVisibleComponentCount G q (insert v S))
      - qVisibleComponentCount G q (insert v S))

/-
The event delta of `extractEvent` agrees with `tropicalDelta`.
-/
theorem extractEvent_delta_eq (q : V) (S : Finset V) (v : V) :
    (extractEvent G q S v).delta = tropicalDelta G q S v := by
  unfold extractEvent tropicalDelta;
  unfold TropicalFiltrationEvent.delta tropicalKernelDim; simp +decide [ max_comm ] ;
  ring

/-! ## General Cumulative Formula -/

/-
Cumulative formula from arbitrary starting point.
-/
theorem tropicalKernelDim_cumulative
    (q : V) (F : List (Finset V))
    (_hmono : F.Chain' (· ⊆ ·))
    (_hq : ∀ S ∈ F, q ∉ S)
    (j k : ℕ) (hjk : j ≤ k) (hk : k < F.length) :
    (tropicalKernelDim G q (F.get ⟨k, hk⟩) : ℤ) =
    (tropicalKernelDim G q (F.get ⟨j, by omega⟩) : ℤ)
      + ∑ i ∈ Finset.Ico j k, filtrationEventDelta G q F i := by
  convert tropicalKernelDim_of_barcode G q F _hmono _hq _ k hk using 1;
  · induction' j with j ih;
    · rw [ Finset.range_eq_Ico ];
    · rw [ ← ih ( Nat.le_of_succ_le hjk ), Finset.sum_Ico_eq_sub _ ( by linarith ) ] at *;
      rw [ Finset.sum_Ico_eq_sub _ ( by linarith ) ];
      simp +decide [ Finset.sum_range_succ, filtrationEventDelta ];
      grind;
  · grind

/-
The total dimension change equals the sum of all event deltas.
-/
theorem total_delta_eq_sum_events
    (q : V) (F : List (Finset V))
    (hmono : F.Chain' (· ⊆ ·))
    (hq : ∀ S ∈ F, q ∉ S)
    (hne : F ≠ []) :
    (tropicalKernelDim G q (F.getLast hne) : ℤ) -
    (tropicalKernelDim G q (F.get ⟨0, List.length_pos_iff.mpr hne⟩) : ℤ)
      = ∑ i ∈ Finset.range (F.length - 1), filtrationEventDelta G q F i := by
  -- By definition of `F.getLast`, we know that `F.getLast hne` is the last element of `F`, and its index is `F.length - 1`.
  have h_last_index : F.getLast hne = F.get ⟨F.length - 1, by
    exact Nat.pred_lt ( ne_bot_of_gt ( List.length_pos_iff.mpr hne ) )⟩ := by
    grind
  generalize_proofs at *;
  have := tropicalKernelDim_cumulative G q F hmono hq 0 ( F.length - 1 ) ( Nat.zero_le _ ) ( by omega ) ; aesop;

end TropicalPersistence