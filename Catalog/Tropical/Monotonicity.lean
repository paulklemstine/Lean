/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Surgery: Spectral Monotonicity

This file proves the core spectral monotonicity theorem for tropical surgery:
entrywise smaller matrices have smaller-or-equal tropical spectral radius.
This is then applied to rank-2 surgery, rank-1 surgery, and two-entry surgery.
-/
import Tropical.Surgery.Defs

open Finset

noncomputable section

/-! ## Part 1: Entrywise Bounds for Surgery -/

/-- Rank-two surgery yields an entrywise smaller-or-equal matrix. -/
theorem tropicalRankTwoSurgery_le {n : ℕ} (A : Fin n → Fin n → ℝ)
    (u v u' v' : Fin n → ℝ) (i j : Fin n) :
    tropicalRankTwoSurgery A u v u' v' i j ≤ A i j := by
  simp [tropicalRankTwoSurgery]

/-- Two-entry surgery yields an entrywise smaller-or-equal matrix. -/
theorem twoEntrySurgery_le {n : ℕ} (A : Fin n → Fin n → ℝ)
    (i₁ j₁ i₂ j₂ : Fin n) (c₁ c₂ : ℝ) (i j : Fin n) :
    twoEntrySurgery A i₁ j₁ i₂ j₂ c₁ c₂ i j ≤ A i j := by
  simp only [twoEntrySurgery]
  split_ifs <;> simp

/-- Rank-one surgery yields entrywise ≤. -/
theorem tropicalRankOneSurgery_le {n : ℕ} (A : Fin n → Fin n → ℝ)
    (u v : Fin n → ℝ) (i j : Fin n) :
    min (A i j) (u i + v j) ≤ A i j :=
  min_le_left _ _

/-! ## Part 2: Cycle Weight and Cycle Mean Monotonicity -/

/-- If `B` is entrywise ≤ `A`, then every closed walk has smaller-or-equal weight in `B`. -/
theorem closedWalkWeight_mono {n : ℕ} {A B : Fin n → Fin n → ℝ} {k : ℕ}
    (hk : 0 < k) (σ : Fin k → Fin n) (h : ∀ i j, B i j ≤ A i j) :
    closedWalkWeight B hk σ ≤ closedWalkWeight A hk σ :=
  Finset.sum_le_sum fun _ _ => h _ _

/-- If `B` is entrywise ≤ `A`, then every cycle mean is smaller-or-equal in `B`. -/
theorem cycleMean_mono {n : ℕ} {A B : Fin n → Fin n → ℝ} {k : ℕ}
    (hk : 0 < k) (σ : Fin k → Fin n) (h : ∀ i j, B i j ≤ A i j) :
    cycleMean B hk σ ≤ cycleMean A hk σ :=
  div_le_div_of_nonneg_right (closedWalkWeight_mono hk σ h) (Nat.cast_nonneg _)

/-- Walk-parameter level monotonicity. -/
theorem walkParamCycleMean_mono {n : ℕ} {A B : Fin (n + 1) → Fin (n + 1) → ℝ}
    (h : ∀ i j, B i j ≤ A i j) (p : WalkParam n) :
    walkParamCycleMean B p ≤ walkParamCycleMean A p :=
  cycleMean_mono _ _ h

/-! ## Part 3: Spectral Radius Monotonicity — The Core Theorem -/

/-
**Tropical spectral monotonicity**: if `B` is entrywise ≤ `A`,
    then the tropical spectral radius of `B` is ≤ that of `A`.

    This is the fundamental structural theorem: entrywise decrease of matrix entries
    cannot increase the minimum cycle mean.
-/
theorem tropicalSpectralRadius_mono {n : ℕ} {A B : Fin (n + 1) → Fin (n + 1) → ℝ}
    (h : ∀ i j, B i j ≤ A i j) :
    tropicalSpectralRadius B ≤ tropicalSpectralRadius A := by
  unfold tropicalSpectralRadius;
  simp +decide [ Finset.inf'_eq_csInf_image ];
  exact le_csInf ( Set.range_nonempty _ ) ( by rintro x ⟨ p, rfl ⟩ ; exact le_trans ( csInf_le ( by exact Set.finite_range _ |> Set.Finite.bddBelow ) ⟨ p, rfl ⟩ ) ( walkParamCycleMean_mono h p ) )

/-! ## Part 4: Main Surgery Spectral Theorems -/

/-- **Main Theorem (Rank-2 Tropical Spectral Monotonicity).**
    Rank-two surgery cannot increase the tropical spectral radius. -/
theorem tropicalRankTwoSurgery_spectral_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (u v u' v' : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (tropicalRankTwoSurgery A u v u' v') ≤
      tropicalSpectralRadius A :=
  tropicalSpectralRadius_mono (fun i j => tropicalRankTwoSurgery_le A u v u' v' i j)

/-- Two-entry surgery cannot increase the tropical spectral radius. -/
theorem twoEntrySurgery_spectral_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (i₁ j₁ i₂ j₂ : Fin (n + 1)) (c₁ c₂ : ℝ) :
    tropicalSpectralRadius (twoEntrySurgery A i₁ j₁ i₂ j₂ c₁ c₂) ≤
      tropicalSpectralRadius A :=
  tropicalSpectralRadius_mono (fun i j => twoEntrySurgery_le A i₁ j₁ i₂ j₂ c₁ c₂ i j)

/-- Rank-one surgery cannot increase the tropical spectral radius. -/
theorem tropicalRankOneSurgery_spectral_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (u v : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (fun i j => min (A i j) (u i + v j)) ≤
      tropicalSpectralRadius A :=
  tropicalSpectralRadius_mono (fun _ _ => min_le_left _ _)

/-! ## Part 5: Spectral Radius of Rank-One Matrices -/

/-
The spectral radius of a rank-one matrix `u ⊕ v` (with entry `u(i) + v(j)`)
    is at most `min_i (u(i) + v(i))`.
-/
theorem rankOne_spectralRadius_le_diag_min {n : ℕ}
    (u v : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (tropicalRankOneUpdate u v) ≤
      Finset.univ.inf' Finset.univ_nonempty (fun i => u i + v i) := by
  unfold tropicalSpectralRadius;
  simp +decide [ walkParamCycleMean, cycleMean ];
  intro i; use 0; use fun _ => i; simp +decide [ closedWalkWeight ] ;
  exact le_rfl

/-! ## Part 6: Explicit Spectral Bound for Rank-Two Surgery -/

/-
**Explicit bound**: the spectral radius after rank-two surgery is at most
    the minimum of the original spectral radius and the diagonal minima of
    the two rank-one components.
-/
theorem tropicalRankTwoSurgery_explicit_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (u v u' v' : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (tropicalRankTwoSurgery A u v u' v') ≤
      min (tropicalSpectralRadius A)
        (min (Finset.univ.inf' Finset.univ_nonempty (fun i => u i + v i))
             (Finset.univ.inf' Finset.univ_nonempty (fun i => u' i + v' i))) := by
  refine' le_min ( tropicalRankTwoSurgery_spectral_bound A u v u' v' ) _;
  refine' le_min ( rankOne_spectralRadius_le_diag_min _ _ |> le_trans ( tropicalSpectralRadius_mono _ ) ) ( rankOne_spectralRadius_le_diag_min _ _ |> le_trans ( tropicalSpectralRadius_mono _ ) );
  · exact fun i j => min_le_of_right_le ( min_le_left _ _ );
  · exact fun i j => min_le_of_right_le ( min_le_right _ _ )

/-! ## Part 7: Algebraic Properties -/

/-- Addition distributes over min from the left. -/
theorem tropical_add_min_left (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

/-- Addition distributes over min from the right. -/
theorem tropical_add_min_right (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) :=
  (min_add_add_right a b c).symm

/-! ## Part 8: Surgery Composition and Properties -/

/-- Rank-two surgery is idempotent. -/
theorem tropicalRankTwoSurgery_idem {n : ℕ}
    (A : Fin n → Fin n → ℝ) (u v u' v' : Fin n → ℝ) (i j : Fin n) :
    tropicalRankTwoSurgery (tropicalRankTwoSurgery A u v u' v') u v u' v' i j =
      tropicalRankTwoSurgery A u v u' v' i j := by
  simp [tropicalRankTwoSurgery]

/-- Surgery with large outer products is identity. -/
theorem tropicalRankTwoSurgery_of_ge {n : ℕ}
    (A : Fin n → Fin n → ℝ) (u v u' v' : Fin n → ℝ)
    (hu : ∀ i j, A i j ≤ u i + v j) (hv : ∀ i j, A i j ≤ u' i + v' j)
    (i j : Fin n) :
    tropicalRankTwoSurgery A u v u' v' i j = A i j := by
  simp [tropicalRankTwoSurgery]
  exact ⟨hu i j, hv i j⟩

/-! ## Part 9: Self-loop and Diagonal Bounds -/

/-- The diagonal entry `A(i,i)` is the cycle mean of the self-loop at vertex `i`. -/
theorem selfLoop_cycleMean {n : ℕ} (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (i : Fin (n + 1)) :
    cycleMean A (Nat.succ_pos 0) (fun _ => i) = A i i := by
  simp [cycleMean, closedWalkWeight]

/-
The spectral radius is at most any diagonal entry.
-/
theorem tropicalSpectralRadius_le_diag {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ) (i : Fin (n + 1)) :
    tropicalSpectralRadius A ≤ A i i := by
  -- By definition of tropical spectral radius, we have:
  simp [tropicalSpectralRadius];
  use ⟨0, by norm_num⟩, fun _ => i;
  convert selfLoop_cycleMean A i |> le_of_eq

/-! ## Part 10: Off-Critical Surgery Preserves Spectral Radius -/

/-
If a walk avoids the surgery support, then B = A on all walk edges.
-/
lemma eq_on_avoiding_walk {n : ℕ} {A B : Fin n → Fin n → ℝ}
    (hle : ∀ i j, B i j ≤ A i j)
    {k : ℕ} (hk : 0 < k) {σ : Fin k → Fin n}
    (havoid : walkAvoids hk σ (surgerySupport A B))
    (t : Fin k) :
    B (σ t) (σ ⟨(t.val + 1) % k, Nat.mod_lt _ hk⟩) =
    A (σ t) (σ ⟨(t.val + 1) % k, Nat.mod_lt _ hk⟩) := by
  exact le_antisymm ( hle _ _ ) ( not_lt.mp fun contra => havoid t contra )

/-
If B = A on all edges of a walk, then closedWalkWeight B = closedWalkWeight A.
-/
lemma closedWalkWeight_eq_of_eq_on_edges {n : ℕ} {A B : Fin n → Fin n → ℝ}
    {k : ℕ} (hk : 0 < k) (σ : Fin k → Fin n)
    (heq : ∀ t : Fin k,
      B (σ t) (σ ⟨(t.val + 1) % k, Nat.mod_lt _ hk⟩) =
      A (σ t) (σ ⟨(t.val + 1) % k, Nat.mod_lt _ hk⟩)) :
    closedWalkWeight B hk σ = closedWalkWeight A hk σ := by
  exact Finset.sum_congr rfl fun _ _ => heq _

/-
The spectral radius is ≤ the cycle mean of any specific walk parameter.
-/
lemma tropicalSpectralRadius_le_walkParam {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ) (p : WalkParam n) :
    tropicalSpectralRadius A ≤ walkParamCycleMean A p := by
  exact Finset.inf'_le _ ( Finset.mem_univ p )

/-
If B = A on all edges of a walk, then their cycle means are equal.
-/
lemma walkParamCycleMean_eq_of_avoiding {n : ℕ}
    {A B : Fin (n + 1) → Fin (n + 1) → ℝ}
    (hle : ∀ i j, B i j ≤ A i j)
    {k : Fin (n + 1)} {σ : Fin (k.val + 1) → Fin (n + 1)}
    (havoid : walkAvoids (Nat.succ_pos k.val) σ (surgerySupport A B)) :
    walkParamCycleMean B ⟨k, σ⟩ = walkParamCycleMean A ⟨k, σ⟩ := by
  unfold walkParamCycleMean cycleMean;
  exact congr_arg₂ _ ( closedWalkWeight_eq_of_eq_on_edges ( Nat.succ_pos k ) σ ( fun t => ( eq_on_avoiding_walk hle ( Nat.succ_pos k ) havoid t ) ) ) rfl

/-- **Off-critical surgery preserves the optimal walk's cycle mean**:
    If a walk avoiding the surgery support achieves the spectral radius of `A`,
    then the same walk has the same cycle mean in `B`. Combined with monotonicity,
    this shows `tropicalSpectralRadius B ≤ walkParamCycleMean B ⟨k, σ⟩ = tropicalSpectralRadius A`. -/
theorem avoiding_walk_cycleMean_eq {n : ℕ}
    {A B : Fin (n + 1) → Fin (n + 1) → ℝ}
    (hle : ∀ i j, B i j ≤ A i j)
    {k : Fin (n + 1)} {σ : Fin (k.val + 1) → Fin (n + 1)}
    (hopt : walkParamCycleMean A ⟨k, σ⟩ = tropicalSpectralRadius A)
    (havoid : walkAvoids (Nat.succ_pos k.val) σ (surgerySupport A B)) :
    walkParamCycleMean B ⟨k, σ⟩ = tropicalSpectralRadius A := by
  rw [walkParamCycleMean_eq_of_avoiding hle havoid, hopt]

/-
**Spectral equality from lower bound**: If `B ≤ A` entrywise and every
    cycle mean of `B` is at least `tropicalSpectralRadius A`, then equality holds.
    This is the key criterion for off-critical surgery invariance.
-/
theorem spectral_eq_of_cycleMean_lower_bound {n : ℕ}
    {A B : Fin (n + 1) → Fin (n + 1) → ℝ}
    (hle : ∀ i j, B i j ≤ A i j)
    (hbound : ∀ p : WalkParam n,
      tropicalSpectralRadius A ≤ walkParamCycleMean B p) :
    tropicalSpectralRadius B = tropicalSpectralRadius A := by
  exact le_antisymm ( tropicalSpectralRadius_mono hle ) ( Finset.le_inf' _ _ fun p hp => hbound p )

end