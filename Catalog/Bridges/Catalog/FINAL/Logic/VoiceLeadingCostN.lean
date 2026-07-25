/-
# N-Voice Voice-Leading Cost: Generalized Metric Geometry

This file generalizes the four-voice voice-leading cost to arbitrary `n` voices,
proving the triangle inequality, permutation invariance, symmetry, and self-cost
properties for `Fin n → ℤ`. These results establish that voice-leading cost
defines a pseudometric on chord space for any number of voices.

## Main Results

* `vlCostN_triangle`: Triangle inequality for n-voice cost (pseudometric property).
* `vlCostN_perm_invariant`: Cost is invariant under voice relabeling.
* `vlCostN_self`: Self-cost is zero.
* `vlCostN_symm`: Cost is symmetric.
* `vlCostN_eq_zero_iff`: Cost zero iff chords agree up to permutation.
* `vlCostN_pseudometric`: Summary of all pseudometric axioms.
-/

import Mathlib

open Finset Function Equiv

/-! ## Generalized Definitions for n voices -/

/-- An n-voice chord: an assignment of integer pitches to n voices. -/
abbrev ChordN (n : ℕ) := Fin n → ℤ

/-- The cost of a specific voice assignment given by permutation `σ` for n voices. -/
def permCostN {n : ℕ} (x y : ChordN n) (σ : Equiv.Perm (Fin n)) : ℕ :=
  ∑ i : Fin n, Int.natAbs (x i - y (σ i))

/-- The optimal n-voice voice-leading cost: minimum over all permutations. -/
noncomputable def vlCostN {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) : ℕ :=
  Finset.inf' Finset.univ ⟨1, Finset.mem_univ 1⟩ (permCostN x y)

/-! ## Core lemmas -/

theorem vlCostN_le_permCost {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) (σ : Equiv.Perm (Fin n)) :
    vlCostN x y ≤ permCostN x y σ :=
  Finset.inf'_le _ (Finset.mem_univ σ)

theorem vlCostN_exists_optimal {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) :
    ∃ σ : Equiv.Perm (Fin n), vlCostN x y = permCostN x y σ := by
  obtain ⟨σ, _, hσ⟩ := Finset.exists_mem_eq_inf' (⟨1, Finset.mem_univ 1⟩ : (Finset.univ : Finset (Equiv.Perm (Fin n))).Nonempty) (permCostN x y)
  exact ⟨σ, hσ⟩

theorem vlCostN_le_inf' {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) (k : ℕ)
    (h : ∀ σ : Equiv.Perm (Fin n), k ≤ permCostN x y σ) :
    k ≤ vlCostN x y := by
  exact Finset.le_inf' _ _ fun σ _ => h σ

/-! ## Permutation cost reindexing -/

theorem permCostN_reindex {n : ℕ} (x y : ChordN n)
    (σ : Equiv.Perm (Fin n)) (τ : Equiv.Perm (Fin n)) :
    permCostN (x ∘ τ) (y ∘ τ) σ = permCostN x y (τ * σ * τ⁻¹) := by
  unfold permCostN;
  conv_rhs => rw [ ← Equiv.sum_comp ( Equiv.ofBijective τ ⟨ τ.injective, τ.surjective ⟩ ) ] ;
  simp +decide [ mul_assoc, mul_comm, mul_left_comm ]

theorem permCostN_comp_both {n : ℕ} (x y : ChordN n)
    (σ τ₁ τ₂ : Equiv.Perm (Fin n)) :
    permCostN (x ∘ τ₁) (y ∘ τ₂) σ = permCostN x y (τ₂ * σ * τ₁⁻¹) := by
  -- By definition of permutation cost, we can rewrite the left-hand side as the sum over i of |x(τ₁(i)) - y(τ₂(σ(i)))|.
  simp [permCostN];
  conv_rhs => rw [ ← Equiv.sum_comp τ₁ ] ; simp +decide [ sub_eq_iff_eq_add ] ;

/-! ## Triangle Inequality -/

theorem permCostN_triangle_comp {n : ℕ}
    (x y z : ChordN n) (σ τ : Equiv.Perm (Fin n)) :
    permCostN x z (τ * σ) ≤ permCostN x y σ + permCostN y z τ := by
  convert Finset.sum_le_sum fun i _ => ?_ using 1;
  rotate_left;
  exact fun i => Int.natAbs ( x i - y ( σ i ) ) + Int.natAbs ( y ( σ i ) - z ( ( τ * σ ) i ) );
  · infer_instance;
  · omega;
  · simp +decide [ Finset.sum_add_distrib, permCostN ];
    conv_lhs => rw [ ← Equiv.sum_comp σ ] ;

theorem vlCostN_triangle {n : ℕ} [Nonempty (Fin n)]
    (x y z : ChordN n) :
    vlCostN x z ≤ vlCostN x y + vlCostN y z := by
  obtain ⟨σ, hσ⟩ := vlCostN_exists_optimal x y
  obtain ⟨τ, hτ⟩ := vlCostN_exists_optimal y z
  calc vlCostN x z ≤ permCostN x z (τ * σ) := vlCostN_le_permCost x z _
    _ ≤ permCostN x y σ + permCostN y z τ := permCostN_triangle_comp x y z σ τ
    _ = vlCostN x y + vlCostN y z := by rw [← hσ, ← hτ]

/-! ## Self-cost, symmetry -/

theorem vlCostN_self {n : ℕ} [Nonempty (Fin n)]
    (x : ChordN n) : vlCostN x x = 0 := by
  apply le_antisymm
  · calc vlCostN x x ≤ permCostN x x 1 := vlCostN_le_permCost x x 1
      _ = 0 := by simp [permCostN]
  · exact Nat.zero_le _

theorem permCostN_symm {n : ℕ} (x y : ChordN n) (σ : Equiv.Perm (Fin n)) :
    permCostN x y σ = permCostN y x σ⁻¹ := by
  unfold permCostN;
  conv_rhs => rw [ ← Equiv.sum_comp σ ] ; simp +decide [ Int.natAbs_eq_natAbs_iff ] ;
  exact Finset.sum_congr rfl fun _ _ => by rw [ ← Int.natAbs_neg, neg_sub ] ;

theorem vlCostN_symm {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) : vlCostN x y = vlCostN y x := by
  apply le_antisymm
  · obtain ⟨σ, hσ⟩ := vlCostN_exists_optimal y x
    calc vlCostN x y ≤ permCostN x y σ⁻¹ := vlCostN_le_permCost x y _
      _ = permCostN y x (σ⁻¹)⁻¹ := permCostN_symm x y _
      _ = permCostN y x σ := by simp
      _ = vlCostN y x := hσ.symm
  · obtain ⟨σ, hσ⟩ := vlCostN_exists_optimal x y
    calc vlCostN y x ≤ permCostN y x σ⁻¹ := vlCostN_le_permCost y x _
      _ = permCostN x y (σ⁻¹)⁻¹ := permCostN_symm y x _
      _ = permCostN x y σ := by simp
      _ = vlCostN x y := hσ.symm

/-! ## Permutation Invariance -/

theorem vlCostN_perm_invariant {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) (τ₁ τ₂ : Equiv.Perm (Fin n)) :
    vlCostN (x ∘ τ₁) (y ∘ τ₂) = vlCostN x y := by
  apply le_antisymm
  · obtain ⟨σ, hσ⟩ := vlCostN_exists_optimal x y
    calc vlCostN (x ∘ τ₁) (y ∘ τ₂)
        ≤ permCostN (x ∘ τ₁) (y ∘ τ₂) (τ₂⁻¹ * σ * τ₁) := vlCostN_le_permCost _ _ _
      _ = permCostN x y σ := by rw [permCostN_comp_both]; simp [mul_assoc]
      _ = vlCostN x y := hσ.symm
  · obtain ⟨σ, hσ⟩ := vlCostN_exists_optimal (x ∘ τ₁) (y ∘ τ₂)
    calc vlCostN x y
        ≤ permCostN x y (τ₂ * σ * τ₁⁻¹) := vlCostN_le_permCost _ _ _
      _ = permCostN (x ∘ τ₁) (y ∘ τ₂) σ := by
          rw [permCostN_comp_both]; group
      _ = vlCostN (x ∘ τ₁) (y ∘ τ₂) := hσ.symm

/-! ## Tropical Path Bounds -/

theorem three_chord_bound {n : ℕ} [Nonempty (Fin n)]
    (a b c : ChordN n) :
    vlCostN a c ≤ vlCostN a b + vlCostN b c :=
  vlCostN_triangle a b c

theorem four_chord_bound {n : ℕ} [Nonempty (Fin n)]
    (a b c d : ChordN n) :
    vlCostN a d ≤ vlCostN a b + vlCostN b c + vlCostN c d :=
  calc vlCostN a d ≤ vlCostN a c + vlCostN c d := vlCostN_triangle a c d
    _ ≤ (vlCostN a b + vlCostN b c) + vlCostN c d := by
        linarith [vlCostN_triangle a b c]

theorem five_chord_bound {n : ℕ} [Nonempty (Fin n)]
    (a b c d e : ChordN n) :
    vlCostN a e ≤ vlCostN a b + vlCostN b c + vlCostN c d + vlCostN d e :=
  calc vlCostN a e ≤ vlCostN a d + vlCostN d e := vlCostN_triangle a d e
    _ ≤ (vlCostN a b + vlCostN b c + vlCostN c d) + vlCostN d e := by
        linarith [four_chord_bound a b c d]

/-! ## Zero-cost characterization -/

theorem vlCostN_eq_zero_iff {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) :
    vlCostN x y = 0 ↔ ∃ σ : Equiv.Perm (Fin n), ∀ i, x i = y (σ i) := by
  constructor
  · intro h
    obtain ⟨σ, hσ⟩ := vlCostN_exists_optimal x y
    rw [h] at hσ
    refine ⟨σ, fun i => ?_⟩
    have : permCostN x y σ = 0 := hσ.symm
    unfold permCostN at this
    have := Finset.sum_eq_zero_iff.mp this i (Finset.mem_univ i)
    omega
  · intro ⟨σ, hσ⟩
    apply le_antisymm
    · calc vlCostN x y ≤ permCostN x y σ := vlCostN_le_permCost _ _ _
        _ = 0 := by
            unfold permCostN
            apply Finset.sum_eq_zero; intro i _; simp [hσ i]
    · exact Nat.zero_le _

/-! ## Pseudometric summary -/

theorem vlCostN_pseudometric {n : ℕ} [Nonempty (Fin n)] :
    (∀ x : ChordN n, vlCostN x x = 0) ∧
    (∀ x y : ChordN n, vlCostN x y = vlCostN y x) ∧
    (∀ x y z : ChordN n, vlCostN x z ≤ vlCostN x y + vlCostN y z) :=
  ⟨vlCostN_self, vlCostN_symm, vlCostN_triangle⟩