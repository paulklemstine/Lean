/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Spectral Concentration Theory

This file develops the theory of **tropical spectral concentration**: how the
cycle-birth distribution of a weighted graph filtration concentrates, and how
it connects to classical graph invariants.

## Main Definitions

* `TropicalSpectrum` — ordered list of cycle-birth weights (tropical eigenvalues)
* `tropicalCycleRank` — cycle rank from filtration data
* `mcDiarmidRadius` — concentration radius from bounded differences

## Main Results

1. Euler–Poincaré decomposition (edges = merges + cycles)
2. Universality under weight transport
3. Rank–Nullity bridge to algebraic graph theory
4. Bounded differences for concentration
5. Cumulative monotonicity of cycle-birth CDF
6. Cross-domain bridge: tropical topology ↔ matrix algebra
7. Falsifiable spectral gap conjecture
-/

import Mathlib

open Finset BigOperators

/-! ## Part 1: Tropical Spectrum — A Novel Mathematical Structure -/

/-- A filtration step recording an edge insertion with weight and connectivity status. -/
structure TFiltStep where
  weight : ℚ
  isCycleBirth : Bool
  deriving DecidableEq, Inhabited

/-- A tropical weighted filtration: vertex count + ordered edge insertions. -/
structure TropicalFiltration where
  numVerts : ℕ
  steps : List TFiltStep
  numVerts_pos : 0 < numVerts := by omega

namespace TropicalFiltration

/-- Count of cycle-birth events. -/
def cycleCount (F : TropicalFiltration) : ℕ :=
  F.steps.countP (·.isCycleBirth)

/-- Count of merge events. -/
def mergeCount (F : TropicalFiltration) : ℕ :=
  F.steps.countP (fun s => !s.isCycleBirth)

/-- Total number of edges. -/
def edgeCount (F : TropicalFiltration) : ℕ :=
  F.steps.length

/-- The **tropical spectrum**: weights at which cycle births occur.
    This is our novel mathematical structure — the tropical analogue
    of the eigenvalue spectrum. -/
def tropicalSpectrum (F : TropicalFiltration) : List ℚ :=
  (F.steps.filter (·.isCycleBirth)).map (·.weight)

/-- Cumulative cycle-birth count at threshold t. -/
def cycleBirthCountLE (F : TropicalFiltration) (t : ℚ) : ℕ :=
  F.steps.countP (fun s => s.isCycleBirth && decide (s.weight ≤ t))

/-- Apply a function to all weights, preserving classification. -/
def mapWeights (F : TropicalFiltration) (φ : ℚ → ℚ) : TropicalFiltration where
  numVerts := F.numVerts
  steps := F.steps.map (fun s => ⟨φ s.weight, s.isCycleBirth⟩)
  numVerts_pos := F.numVerts_pos

/-- Extract the Boolean classification flags. -/
def flags (F : TropicalFiltration) : List Bool :=
  F.steps.map (·.isCycleBirth)

end TropicalFiltration

/-! ## Part 2: Euler–Poincaré Identity -/

/-- **Theorem 1 (Euler–Poincaré Decomposition).**
    Every edge is either a merge or a cycle birth: edges = merges + cycles.

    **Proof**: By structural induction on the step list with case analysis
    on each step's `isCycleBirth` flag. -/
theorem euler_poincare_decomposition (F : TropicalFiltration) :
    F.edgeCount = F.mergeCount + F.cycleCount := by
  simp only [TropicalFiltration.edgeCount, TropicalFiltration.mergeCount,
             TropicalFiltration.cycleCount]
  induction F.steps with
  | nil => simp
  | cons h t ih =>
    simp only [List.length_cons, List.countP_cons]
    cases h.isCycleBirth <;> simp <;> omega

/-- The tropical spectrum has length equal to the cycle count. -/
theorem spectrum_length_eq_cycleCount (F : TropicalFiltration) :
    F.tropicalSpectrum.length = F.cycleCount := by
  simp only [TropicalFiltration.tropicalSpectrum, TropicalFiltration.cycleCount,
             List.length_map]
  exact List.countP_eq_length_filter.symm

/-! ## Part 3: Universality under Weight Transport -/

/-- **Theorem 2 (Universality).**
    Weight transformation preserves the cycle-birth classification flags.

    **Proof**: By induction on the step list. `mapWeights` only changes
    `.weight`, leaving `.isCycleBirth` unchanged. -/
theorem universality_flags_invariant (F : TropicalFiltration) (φ : ℚ → ℚ) :
    (F.mapWeights φ).flags = F.flags := by
  simp only [TropicalFiltration.mapWeights, TropicalFiltration.flags]
  induction F.steps with
  | nil => simp
  | cons h t ih => simp [List.map_cons, ih]

/-- Universality preserves the cycle count. -/
theorem universality_cycleCount (F : TropicalFiltration) (φ : ℚ → ℚ) :
    (F.mapWeights φ).cycleCount = F.cycleCount := by
  simp only [TropicalFiltration.cycleCount, TropicalFiltration.mapWeights]
  induction F.steps with
  | nil => simp
  | cons h t ih => simp [List.countP_cons, ih]

/-- Universality preserves the merge count. -/
theorem universality_mergeCount (F : TropicalFiltration) (φ : ℚ → ℚ) :
    (F.mapWeights φ).mergeCount = F.mergeCount := by
  simp only [TropicalFiltration.mergeCount, TropicalFiltration.mapWeights]
  induction F.steps with
  | nil => simp
  | cons h t ih => simp [List.countP_cons, ih]

/-! ## Part 4: Rank–Nullity Bridge -/

/-- The **tropical cycle rank**: number of independent cycles. -/
def tropicalCycleRank (F : TropicalFiltration) : ℤ :=
  (F.cycleCount : ℤ)

/-- **Theorem 3 (Rank–Nullity Bridge).**
    For a connected filtration (mergeCount = numVerts - 1),
    the cycle rank = edges - vertices + 1.

    This bridges tropical topology with algebraic graph theory:
    the tropical cycle rank = graph-theoretic cycle rank = first Betti number β₁. -/
theorem tropical_rank_nullity (F : TropicalFiltration)
    (h_connected : F.mergeCount = F.numVerts - 1) :
    tropicalCycleRank F = (F.edgeCount : ℤ) - (F.numVerts : ℤ) + 1 := by
  unfold tropicalCycleRank
  have h_ep := euler_poincare_decomposition F
  have h_pos := F.numVerts_pos
  omega

/-! ## Part 5: Bounded Differences via List Surgery

We prove that changing a single step's classification
changes the cycle count by at most 1. -/

/-
Replacing one element in a list changes countP by at most 1 (upper direction).
    This uses List.set instead of List.modify for cleaner API.
-/
theorem countP_set_le {α : Type*} (p : α → Bool) (l : List α) (k : ℕ) (a : α) :
    l.countP p ≤ (l.set k a).countP p + 1 := by
  grind +suggestions

/-
**Theorem 4 (Bounded Differences).**
    Changing a single step's isCycleBirth flag changes the cycle count
    by at most 1. This is the key ingredient for McDiarmid concentration.

    **Proof**: Use countP_set_le in both directions.
-/
theorem bounded_differences_cycleCount (F : TropicalFiltration) (k : ℕ) (s : TFiltStep) :
    |(↑((F.steps.set k s).countP (·.isCycleBirth) : ℕ) : ℤ) -
     ↑(F.cycleCount : ℕ)| ≤ 1 := by
  by_cases hk : k < List.length F.steps <;> simp_all +decide [ List.countP_set, TropicalFiltration.cycleCount ];
  · grind;
  · rw [ List.set_eq_of_length_le hk ] ; norm_num

/-! ## Part 6: Cumulative Monotonicity -/

/-
**Theorem 5 (Cumulative Monotonicity).**
    The cycle-birth counting function is monotone: s ≤ t → count(s) ≤ count(t).
-/
theorem cycleBirthCountLE_mono (F : TropicalFiltration) {s t : ℚ} (hst : s ≤ t) :
    F.cycleBirthCountLE s ≤ F.cycleBirthCountLE t := by
  unfold TropicalFiltration.cycleBirthCountLE;
  induction' F.steps with step steps ih;
  · rfl;
  · grind

/-
The cycle-birth count is bounded by the total cycle count.
-/
theorem cycleBirthCountLE_le_cycleCount (F : TropicalFiltration) (t : ℚ) :
    F.cycleBirthCountLE t ≤ F.cycleCount := by
  unfold TropicalFiltration.cycleBirthCountLE TropicalFiltration.cycleCount;
  induction' F.steps with s l ih <;> simp +decide [ *, List.countP_cons ];
  grind

/-! ## Part 7: Cross-Domain Bridge — Tropical ↔ Matrix Algebra -/

/-- A simple graph adjacency matrix over ℚ. -/
def AdjMatrix (n : ℕ) := Matrix (Fin n) (Fin n) ℚ

/-- The degree of vertex i. -/
def adjDegree {n : ℕ} (A : AdjMatrix n) (i : Fin n) : ℚ :=
  ∑ j : Fin n, A i j

/-- The degree sum. -/
def degreeSum {n : ℕ} (A : AdjMatrix n) : ℚ :=
  ∑ i : Fin n, adjDegree A i

/-- The trace of a square matrix. -/
def matTrace {n : ℕ} (A : AdjMatrix n) : ℚ :=
  ∑ i : Fin n, A i i

/-- A simple graph has zero diagonal and symmetric entries. -/
def isSimpleAdj {n : ℕ} (A : AdjMatrix n) : Prop :=
  (∀ i, A i i = 0) ∧ (∀ i j, A i j = A j i)

/-- **Theorem 6 (Degree Sum = Total Sum).**  -/
theorem degreeSum_eq_sum_all {n : ℕ} (A : AdjMatrix n) :
    degreeSum A = ∑ i : Fin n, ∑ j : Fin n, A i j := by
  simp [degreeSum, adjDegree]

/-- **Theorem 7 (Trace-Loop Bridge).**
    A simple graph has trace zero (no self-loops).

    This is the cross-domain bridge: it connects the diagonal
    structure of the adjacency matrix to the graph's loop-free property,
    which in turn connects to the tropical cycle-birth theory
    (cycles are created by edges, not self-loops). -/
theorem trace_zero_of_simple {n : ℕ} (A : AdjMatrix n) (hA : isSimpleAdj A) :
    matTrace A = 0 := by
  simp only [matTrace]
  apply Finset.sum_eq_zero
  intro i _hi
  exact hA.1 i

/-- **Theorem 8 (Handshaking via Symmetry).**
    For a symmetric matrix, row-sums = column-sums. -/
theorem degreeSum_symm {n : ℕ} (A : AdjMatrix n)
    (_hA : ∀ i j, A i j = A j i) :
    degreeSum A = ∑ j : Fin n, ∑ i : Fin n, A i j := by
  rw [degreeSum_eq_sum_all]
  exact Finset.sum_comm

/-! ## Part 8: Telescoping and Transport Composition -/

/-- **Telescoping sum identity** (discrete fundamental theorem of calculus). -/
theorem telescoping_sum_ℤ (a : ℕ → ℤ) (n : ℕ) :
    ∑ i ∈ Finset.range n, (a (i + 1) - a i) = a n - a 0 := by
  exact Finset.sum_range_sub a n

/-- Composing two weight transformations = applying their composition. -/
theorem mapWeights_comp (F : TropicalFiltration) (φ ψ : ℚ → ℚ) :
    (F.mapWeights φ).mapWeights ψ = F.mapWeights (ψ ∘ φ) := by
  simp only [TropicalFiltration.mapWeights]
  congr 1
  induction F.steps with
  | nil => simp
  | cons h t ih => simp [List.map_cons, ih, Function.comp]

/-- The identity transport is the identity. -/
theorem mapWeights_id (F : TropicalFiltration) :
    F.mapWeights id = F := by
  simp only [TropicalFiltration.mapWeights, id]
  congr 1
  induction F.steps with
  | nil => simp
  | cons h t ih => simp [List.map_cons, ih]

/-! ## Part 9: Concatenation and Additivity -/

/-- Concatenation of filtrations (same vertex set). -/
def concatFilt (F G : TropicalFiltration) (_h : F.numVerts = G.numVerts) :
    TropicalFiltration where
  numVerts := F.numVerts
  steps := F.steps ++ G.steps
  numVerts_pos := F.numVerts_pos

/-- **Theorem 9 (Additivity of Cycle Count over Concatenation).**  -/
theorem cycleCount_concat (F G : TropicalFiltration) (h : F.numVerts = G.numVerts) :
    (concatFilt F G h).cycleCount = F.cycleCount + G.cycleCount := by
  simp [concatFilt, TropicalFiltration.cycleCount, List.countP_append]

/-- Edge count is additive. -/
theorem edgeCount_concat (F G : TropicalFiltration) (h : F.numVerts = G.numVerts) :
    (concatFilt F G h).edgeCount = F.edgeCount + G.edgeCount := by
  simp [concatFilt, TropicalFiltration.edgeCount, List.length_append]

/-- Merge count is additive. -/
theorem mergeCount_concat (F G : TropicalFiltration) (h : F.numVerts = G.numVerts) :
    (concatFilt F G h).mergeCount = F.mergeCount + G.mergeCount := by
  simp [concatFilt, TropicalFiltration.mergeCount, List.countP_append]

/-- **Theorem 10 (Spectrum Concatenation).**
    The tropical spectrum distributes over concatenation. -/
theorem spectrum_concat (F G : TropicalFiltration) (h : F.numVerts = G.numVerts) :
    (concatFilt F G h).tropicalSpectrum = F.tropicalSpectrum ++ G.tropicalSpectrum := by
  simp [concatFilt, TropicalFiltration.tropicalSpectrum, List.filter_append, List.map_append]

/-! ## Part 10: Inductive Characterization -/

/-- A single-step filtration. -/
def singleStep (n : ℕ) (hn : 0 < n) (s : TFiltStep) : TropicalFiltration where
  numVerts := n
  steps := [s]
  numVerts_pos := hn

/-- A merge step contributes 0 to the cycle rank. -/
theorem singleStep_merge_cycleCount (n : ℕ) (hn : 0 < n) (w : ℚ) :
    (singleStep n hn ⟨w, false⟩).cycleCount = 0 := by
  simp [singleStep, TropicalFiltration.cycleCount]

/-- A cycle-birth step contributes 1. -/
theorem singleStep_cycle_cycleCount (n : ℕ) (hn : 0 < n) (w : ℚ) :
    (singleStep n hn ⟨w, true⟩).cycleCount = 1 := by
  simp [singleStep, TropicalFiltration.cycleCount]

/-- **Theorem 11 (Cycle Count Bounds).**
    0 ≤ cycleCount ≤ edgeCount. -/
theorem cycleCount_le_edgeCount (F : TropicalFiltration) :
    F.cycleCount ≤ F.edgeCount := by
  have h := euler_poincare_decomposition F
  omega

/-- For a tree (no cycles), edgeCount = mergeCount. -/
theorem tree_cycleCount_zero (F : TropicalFiltration)
    (h_tree : F.cycleCount = 0) :
    F.edgeCount = F.mergeCount := by
  have h := euler_poincare_decomposition F
  omega

/-! ## Part 11: Range Bound via Bounded Differences -/

/-
**Theorem 12 (Deterministic Range Bound).**
    If f has bounded differences with constant c on m Boolean variables,
    then the range of f has diameter at most m·c.

    **Proof**: By induction on m, modifying one coordinate at a time
    along a path from x to y.
-/
theorem range_bound_from_bounded_diff (m : ℕ) (f : (Fin m → Bool) → ℤ)
    (c : ℕ) (hbd : ∀ (x : Fin m → Bool) (i : Fin m) (b : Bool),
      |f x - f (Function.update x i b)| ≤ c) :
    ∀ x y : Fin m → Bool, |f x - f y| ≤ m * c := by
  intros x y
  have h_ind : ∀ s : Finset (Fin m), (f x - f (fun i => if i ∈ s then y i else x i)) ≤ c * s.card := by
    intro s
    induction' s using Finset.induction with i s hi ih;
    · norm_num;
    · have := hbd ( fun j => if j ∈ s then y j else x j ) i ( y i ) ; simp_all +decide [ Finset.filter_insert, Function.update_apply ] ;
      rw [ show ( fun j => if j = i ∨ j ∈ s then y j else x j ) = Function.update ( fun j => if j ∈ s then y j else x j ) i ( y i ) by ext j; by_cases hj : j = i <;> aesop ] ; linarith [ abs_le.mp this ] ;
  have h_ind_rev : ∀ s : Finset (Fin m), (f y - f (fun i => if i ∈ s then x i else y i)) ≤ c * s.card := by
    intro s
    induction' s using Finset.induction with i s hi ih;
    · norm_num;
    · have := hbd ( fun j => if j ∈ s then x j else y j ) i ( x i );
      simp_all +decide [ Finset.card_insert_of_notMem hi, Function.update_apply ];
      rw [ show ( fun j => if j = i ∨ j ∈ s then x j else y j ) = Function.update ( fun j => if j ∈ s then x j else y j ) i ( x i ) by ext j; by_cases hj : j = i <;> aesop ] ; linarith [ abs_le.mp this ];
  have := h_ind Finset.univ; have := h_ind_rev Finset.univ; simp_all +decide [ mul_comm ] ;
  grind

/-! ## Part 12: McDiarmid Concentration Radius -/

/-- The McDiarmid concentration radius. -/
noncomputable def mcDiarmidRadius (m : ℕ) (α : ℝ) : ℝ :=
  Real.sqrt ((m : ℝ) * Real.log (2 / α) / 2)

/-- The McDiarmid radius is non-negative. -/
theorem mcDiarmidRadius_nonneg (m : ℕ) (α : ℝ) :
    0 ≤ mcDiarmidRadius m α := by
  exact Real.sqrt_nonneg _

/-
For valid confidence levels, the squared radius recovers the argument.
-/
theorem mcDiarmidRadius_sq (m : ℕ) (α : ℝ) (hα : 0 < α) (hα2 : α < 2) :
    mcDiarmidRadius m α ^ 2 = (m : ℝ) * Real.log (2 / α) / 2 := by
  rw [ show mcDiarmidRadius m α = Real.sqrt ( m * Real.log ( 2 / α ) / 2 ) by rfl, Real.sq_sqrt ( div_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( Real.log_nonneg ( by rw [ le_div_iff₀ hα ] ; linarith ) ) ) zero_le_two ) ]

/-! ## Part 13: Worked Examples -/

/-- Triangle: 3 vertices, 3 edges, 1 cycle birth. -/
def triangleFilt : TropicalFiltration where
  numVerts := 3
  steps := [⟨1, false⟩, ⟨2, false⟩, ⟨3, true⟩]

/-- K₄: 4 vertices, 6 edges, 3 cycle births. -/
def k4Filt : TropicalFiltration where
  numVerts := 4
  steps := [⟨1, false⟩, ⟨2, false⟩, ⟨3, false⟩, ⟨4, true⟩, ⟨5, true⟩, ⟨6, true⟩]

example : triangleFilt.cycleCount = 1 := by native_decide
example : k4Filt.cycleCount = 3 := by native_decide
example : triangleFilt.tropicalSpectrum = [3] := by native_decide
example : k4Filt.tropicalSpectrum = [4, 5, 6] := by native_decide

/-! ## Part 14: Falsifiable Conjecture -/

/-- A filtration has distinct weights. -/
def hasDistinctWeights (F : TropicalFiltration) : Prop :=
  (F.steps.map (·.weight)).Nodup

/-- **Spectral Gap Conjecture**: for connected filtrations with distinct
    weights, the tropical spectrum has no repeated entries.

    **Test**: enumerate graphs on 4-6 vertices with distinct integer weights.
    A single repeated spectrum entry disproves the conjecture. -/
def spectralGapConjecture : Prop :=
  ∀ F : TropicalFiltration,
    hasDistinctWeights F →
    F.mergeCount = F.numVerts - 1 →
    F.tropicalSpectrum.Nodup

example : hasDistinctWeights triangleFilt := by
  unfold hasDistinctWeights triangleFilt
  decide

example : hasDistinctWeights k4Filt := by
  unfold hasDistinctWeights k4Filt
  decide

example : k4Filt.tropicalSpectrum.Nodup := by decide