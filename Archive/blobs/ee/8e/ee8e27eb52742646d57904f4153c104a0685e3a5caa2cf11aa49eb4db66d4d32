/-
# Causal Integration Algebra — Core Definitions and Theorems

A lattice-theoretic formalization connecting Integrated Information Theory (IIT)
to minimum cuts of weighted directed graphs. We define:
- `CausalSystem n`: a weighted directed graph on `Fin n` with nonneg weights
- `crossInfo C S`: the total weight of edges from `S` to its complement
- `phi C`: the minimum cross-info over all nontrivial bipartitions (= min cut)

Main results:
- `phi_nonneg`: Φ ≥ 0
- `phi_zero_of_disconnected`: disconnected systems have Φ = 0
- `phi_scale`: Φ(c·C) = c·Φ(C) for c ≥ 0
- `phi_mono_of_weight_le`: pointwise larger weights ⟹ larger Φ
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- A causal system on `n` nodes: a weighted directed graph with nonnegative edge weights. -/
structure CausalSystem (n : ℕ) where
  weight : Fin n → Fin n → ℝ
  weight_nonneg : ∀ i j, 0 ≤ weight i j

namespace CausalSystem

variable {n : ℕ}

/-- Cross-information of a bipartition S: total weight of edges from S to Sᶜ. -/
noncomputable def crossInfo (C : CausalSystem n) (S : Finset (Fin n)) : ℝ :=
  ∑ i ∈ S, ∑ j ∈ Finset.univ \ S, C.weight i j

/-- The set of nontrivial bipartitions: nonempty proper subsets of Fin n. -/
def nontrivialBipartitions (n : ℕ) : Finset (Finset (Fin n)) :=
  Finset.univ.powerset.filter (fun S => S.Nonempty ∧ S ≠ Finset.univ)

/-
When n ≥ 2, nontrivial bipartitions exist (e.g., the singleton {0}).
-/
lemma nontrivialBipartitions_nonempty (hn : 2 ≤ n) :
    (nontrivialBipartitions n).Nonempty := by
      use { ⟨ 0, by linarith ⟩ } ; simp +decide [ *, nontrivialBipartitions ] ;
      exact fun h => by have := Finset.ext_iff.mp h ⟨ 1, by linarith ⟩ ; simp +decide at this;

/-
!-- Cross-info is a double sum of nonneg terms, hence nonneg. -- !--
-/
theorem crossInfo_nonneg (C : CausalSystem n) (S : Finset (Fin n)) :
    0 ≤ C.crossInfo S := by
      exact Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => C.weight_nonneg i j

/-- Integrated information Φ: minimum cross-information over all nontrivial bipartitions. -/
noncomputable def phi (C : CausalSystem n) (hn : 2 ≤ n) : ℝ :=
  (nontrivialBipartitions n).inf' (nontrivialBipartitions_nonempty hn) (C.crossInfo ·)

/-
!-- Φ is the minimum of nonneg values, hence nonneg. -- !--
-/
theorem phi_nonneg (C : CausalSystem n) (hn : 2 ≤ n) : 0 ≤ C.phi hn := by
  refine' le_trans _ ( Finset.le_inf' _ _ _ );
  exacts [ le_rfl, fun b hb => C.crossInfo_nonneg b ]

/-
!-- Φ ≤ crossInfo for any nontrivial bipartition, by definition of inf'. -- !--
-/
theorem phi_le_crossInfo (C : CausalSystem n) (hn : 2 ≤ n)
    (S : Finset (Fin n)) (hS : S ∈ nontrivialBipartitions n) :
    C.phi hn ≤ C.crossInfo S := by
      exact Finset.inf'_le _ hS

/-! ## Disconnectedness and Φ = 0 -/

/-- A system is disconnected if some nontrivial bipartition has zero cross-info. -/
def IsDisconnected (C : CausalSystem n) : Prop :=
  ∃ S : Finset (Fin n), S.Nonempty ∧ S ≠ Finset.univ ∧ C.crossInfo S = 0

/-
!-- If there's a zero-weight cut, Φ ≤ 0; combined with Φ ≥ 0 we get Φ = 0. -- !--
-/
theorem phi_zero_of_disconnected (C : CausalSystem n) (hn : 2 ≤ n)
    (hd : C.IsDisconnected) : C.phi hn = 0 := by
      obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := hd;
      exact le_antisymm ( phi_le_crossInfo C hn S ( Finset.mem_filter.mpr ⟨ Finset.mem_powerset.mpr ( Finset.subset_univ _ ), hS₁, hS₂ ⟩ ) |> le_trans <| by aesop ) ( phi_nonneg C hn )

/-! ## Scaling -/

/-- Scale all weights by a nonneg constant. -/
noncomputable def scale (C : CausalSystem n) (c : ℝ) (hc : 0 ≤ c) : CausalSystem n where
  weight i j := c * C.weight i j
  weight_nonneg i j := mul_nonneg hc (C.weight_nonneg i j)

/-
Scaling cross-info is linear.
-/
theorem crossInfo_scale (C : CausalSystem n) (S : Finset (Fin n)) (c : ℝ) (hc : 0 ≤ c) :
    (C.scale c hc).crossInfo S = c * C.crossInfo S := by
      unfold CausalSystem.crossInfo CausalSystem.scale;
      simp +decide only [Finset.mul_sum _ _ _]

/-
!-- Scaling Φ: min_S(c·f(S)) = c·min_S f(S) for c ≥ 0. -- !--
-/
theorem phi_scale (C : CausalSystem n) (hn : 2 ≤ n) (c : ℝ) (hc : 0 ≤ c) :
    (C.scale c hc).phi hn = c * C.phi hn := by
      unfold CausalSystem.phi;
      simp +decide [ Finset.inf'_eq_csInf_image, crossInfo_scale ];
      rw [ ← smul_eq_mul, ← Real.sInf_smul_of_nonneg hc ];
      congr! 1;
      ext; simp [Set.mem_smul_set, Set.mem_image]

/-! ## Monotonicity -/

/-
If weights of C₁ ≤ C₂ pointwise, then crossInfo C₁ ≤ crossInfo C₂ for each cut.
-/
theorem crossInfo_mono (C₁ C₂ : CausalSystem n)
    (h : ∀ i j, C₁.weight i j ≤ C₂.weight i j) (S : Finset (Fin n)) :
    C₁.crossInfo S ≤ C₂.crossInfo S := by
      exact Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => h i j

/-
!-- min f ≤ min g when f ≤ g pointwise: min f ≤ f(argmin g) ≤ g(argmin g) = min g. -- !--
-/
theorem phi_mono_of_weight_le (C₁ C₂ : CausalSystem n) (hn : 2 ≤ n)
    (h : ∀ i j, C₁.weight i j ≤ C₂.weight i j) :
    C₁.phi hn ≤ C₂.phi hn := by
      unfold phi;
      simp +zetaDelta at *;
      exact fun S hS => ⟨ S, hS, crossInfo_mono C₁ C₂ h S ⟩

/-! ## Total Weight Bound -/

/-- Total weight of all edges in the system. -/
noncomputable def totalWeight (C : CausalSystem n) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n, C.weight i j

/-
Cross-info of any bipartition is at most the total weight.
-/
theorem crossInfo_le_totalWeight (C : CausalSystem n) (S : Finset (Fin n)) :
    C.crossInfo S ≤ C.totalWeight := by
      refine' le_trans ( Finset.sum_le_sum fun i hi => Finset.sum_le_sum_of_subset_of_nonneg _ _ ) _;
      rotate_left;
      exact fun _ _ _ => C.weight_nonneg _ _;
      exact fun i => Finset.univ;
      · exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => Finset.sum_nonneg fun _ _ => C.weight_nonneg _ _;
      · exact sdiff_subset

/-
Φ is bounded above by the total weight.
-/
theorem phi_le_totalWeight (C : CausalSystem n) (hn : 2 ≤ n)
    (hnt : (nontrivialBipartitions n).Nonempty := nontrivialBipartitions_nonempty hn) :
    C.phi hn ≤ C.totalWeight := by
      obtain ⟨ S, hS ⟩ := hnt;
      exact le_trans ( phi_le_crossInfo C hn S hS ) ( crossInfo_le_totalWeight C S )

end CausalSystem