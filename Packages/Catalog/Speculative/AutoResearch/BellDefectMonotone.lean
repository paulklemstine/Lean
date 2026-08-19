import Combinatorics.BellDefectSeparation

/-!
# Monotonicity of the Stirling columns and of the Bell defect

The propagation bound `bellDefect_propagation` of
`Catalog/Combinatorics/BellDefectGradedSpectrum.lean` compares the defects at two levels through
the *spectral* values `t_r`.  This file proves the complementary, purely combinatorial comparison:
the Stirling triangle is monotone along its columns,

  `S(j,s) ≤ S(k,s)`  for `1 ≤ j ≤ k`  (`stirling_le_stirling_of_le`),

realized by an explicit injection of patterns (`extendPattern`: keep the first `j` coordinates,
attach all new coordinates to the block of `0`; this preserves the number of blocks).  Together
with the spectral formula for the defect this gives

  `D_j ≤ D_k`  for `j ≤ k ≤ |X|`  (`bellDefect_mono`),

so the Bell defect is a *monotone* obstruction to transitivity: it can only grow with the tuple
length, and any failure at a short length persists at every longer one
(`bellDefect_pos_of_lt_pos`).

Note the boundary: the inequality `S(j,s) ≤ S(k,s)` genuinely needs `j ≥ 1`, since
`S(0,0) = 1 > 0 = S(k,0)` for `k ≥ 1`.  The defect statement is nevertheless true for `j = 0`,
because `D_0 = 0` (`bellDefect_zero`).

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace BellDefectGraded

open MoonshineBell MoonshineFibre FibreSpectrum

/-! ## Part 1: extending a pattern to more coordinates -/

section Extend

variable {j k : ℕ}

/-- **Extension of a pattern.**  Given a pattern of `Fin j` and `j ≤ k`, extend it to `Fin k` by
attaching every new coordinate to the block of `0`.  As long as `j ≥ 1` this does not change the
number of blocks, because `0` is already a block leader. -/
def extendPattern (hj : 1 ≤ j) (hjk : j ≤ k) (p : Pattern j) : Pattern k :=
  ⟨fun i =>
      if h : (i : ℕ) < j then ⟨(p.1 ⟨i, h⟩ : ℕ), lt_of_lt_of_le (p.1 ⟨i, h⟩).isLt hjk⟩
      else ⟨0, by omega⟩,
    fun i => by
      by_cases h : (i : ℕ) < j
      · have := p.2.1 ⟨i, h⟩
        simp only [Fin.le_def, dif_pos h]
        simpa [Fin.le_def] using this
      · simp only [Fin.le_def, dif_neg h]
        omega,
    fun i => by
      by_cases h : (i : ℕ) < j
      · have hlt : ((p.1 ⟨i, h⟩ : Fin j) : ℕ) < j := (p.1 ⟨i, h⟩).isLt
        refine Fin.ext ?_
        simp only [dif_pos h, dif_pos hlt]
        have : p.1 ⟨((p.1 ⟨i, h⟩ : Fin j) : ℕ), hlt⟩ = p.1 ⟨i, h⟩ := by
          have hfe : (⟨((p.1 ⟨i, h⟩ : Fin j) : ℕ), hlt⟩ : Fin j) = p.1 ⟨i, h⟩ := Fin.ext rfl
          rw [hfe]
          exact p.2.2 ⟨i, h⟩
        rw [this]
      · refine Fin.ext ?_
        have hz : ((0 : ℕ)) < j := by omega
        simp only [dif_neg h, dif_pos hz]
        have h0 : p.1 ⟨0, hz⟩ = ⟨0, hz⟩ := by
          have := p.2.1 ⟨0, hz⟩
          exact Fin.ext (by simpa [Fin.le_def] using this)
        rw [h0]⟩

theorem extendPattern_apply_of_lt (hj : 1 ≤ j) (hjk : j ≤ k) (p : Pattern j) {i : Fin k}
    (h : (i : ℕ) < j) : ((extendPattern hj hjk p).1 i : ℕ) = (p.1 ⟨i, h⟩ : ℕ) := by
  simp [extendPattern, h]

theorem extendPattern_apply_of_ge (hj : 1 ≤ j) (hjk : j ≤ k) (p : Pattern j) {i : Fin k}
    (h : ¬ (i : ℕ) < j) : ((extendPattern hj hjk p).1 i : ℕ) = 0 := by
  simp [extendPattern, h]

/-- Extension preserves the number of blocks. -/
theorem rank_extendPattern (hj : 1 ≤ j) (hjk : j ≤ k) (p : Pattern j) :
    rank (extendPattern hj hjk p) = rank p := by
  classical
  have hcast : Function.Injective (fun m : Fin j => (⟨m.val, lt_of_lt_of_le m.isLt hjk⟩ : Fin k)) :=
    fun a b hab => Fin.ext (by simpa using congrArg Fin.val hab)
  have himg : leaders (extendPattern hj hjk p)
      = Finset.image (fun m : Fin j => (⟨m.val, lt_of_lt_of_le m.isLt hjk⟩ : Fin k))
        (leaders p) := by
    have hz : (0 : ℕ) < j := by omega
    have h0 : p.1 ⟨0, hz⟩ = ⟨0, hz⟩ := Fin.ext (by simpa [Fin.le_def] using p.2.1 ⟨0, hz⟩)
    ext x
    constructor
    · intro hx
      obtain ⟨i, -, hi⟩ := Finset.mem_image.1 hx
      by_cases h : (i : ℕ) < j
      · refine Finset.mem_image.2 ⟨p.1 ⟨i, h⟩, leader_mem p ⟨i, h⟩, Fin.ext ?_⟩
        rw [← hi]
        exact (extendPattern_apply_of_lt hj hjk p h).symm
      · refine Finset.mem_image.2 ⟨⟨0, hz⟩, ?_, Fin.ext ?_⟩
        · rw [← h0]; exact leader_mem p _
        · rw [← hi]
          exact (extendPattern_apply_of_ge hj hjk p h).symm
    · intro hx
      obtain ⟨m, hm, hmx⟩ := Finset.mem_image.1 hx
      obtain ⟨n, -, hn⟩ := Finset.mem_image.1 hm
      have hnj : ((⟨n.val, lt_of_lt_of_le n.isLt hjk⟩ : Fin k) : ℕ) < j := n.isLt
      refine Finset.mem_image.2 ⟨⟨n.val, lt_of_lt_of_le n.isLt hjk⟩, Finset.mem_univ _,
        Fin.ext ?_⟩
      rw [extendPattern_apply_of_lt hj hjk p hnj]
      have hnn : (⟨((⟨n.val, lt_of_lt_of_le n.isLt hjk⟩ : Fin k) : ℕ), hnj⟩ : Fin j) = n :=
        Fin.ext rfl
      rw [hnn, hn, ← hmx]
  rw [rank, himg, Finset.card_image_of_injective _ hcast, card_leaders]

theorem extendPattern_injective (hj : 1 ≤ j) (hjk : j ≤ k) :
    Function.Injective (extendPattern hj hjk) := by
  intro p q hpq
  refine Subtype.ext (funext fun m => Fin.ext ?_)
  have hm : ((⟨m.val, lt_of_lt_of_le m.isLt hjk⟩ : Fin k) : ℕ) < j := m.isLt
  have h := congrArg (fun P : Pattern k => (P.1 ⟨m.val, lt_of_lt_of_le m.isLt hjk⟩ : ℕ)) hpq
  simp only at h
  rw [extendPattern_apply_of_lt hj hjk p hm, extendPattern_apply_of_lt hj hjk q hm] at h
  have hmm : (⟨(m : ℕ), hm⟩ : Fin j) = m := Fin.ext rfl
  rw [hmm] at h
  exact h

/-- **The Stirling triangle is monotone along columns**: `S(j,s) ≤ S(k,s)` for `1 ≤ j ≤ k`.
(The hypothesis `j ≥ 1` is necessary: `S(0,0) = 1` while `S(k,0) = 0` for `k ≥ 1`.) -/
theorem stirling_le_stirling_of_le (hj : 1 ≤ j) (hjk : j ≤ k) (s : ℕ) :
    stirling j s ≤ stirling k s := by
  classical
  refine Finset.card_le_card_of_injOn (extendPattern hj hjk) (fun p hp => ?_)
    (fun a _ b _ hab => extendPattern_injective hj hjk hab)
  simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hp ⊢
  rw [rank_extendPattern hj hjk p, hp]

end Extend

/-! ## Part 2: monotonicity of the Bell defect -/

section Defect

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- The defect at level `0` vanishes: `B_0·|G| = |G| = Σ_g |X^g|^0`. -/
theorem bellDefect_zero : bellDefect 0 G X = 0 := by
  rw [bellDefect_eq_spectrum 0 G X (Nat.zero_le _)]
  simp [injOrbits_zero_eq_one G X]

/-- **The Bell defect is monotone in the tuple length.**  For `j ≤ k ≤ |X|` we have
`D_j ≤ D_k`: the obstruction to transitivity can only grow with the length of the tuples.
The proof combines column monotonicity of the Stirling triangle with monotonicity of the fibre
spectrum. -/
theorem bellDefect_mono {j k : ℕ} (hjk : j ≤ k) (hk : k ≤ Nat.card X) :
    bellDefect j G X ≤ bellDefect k G X := by
  rcases Nat.eq_zero_or_pos j with hj0 | hj
  · rw [hj0, bellDefect_zero G X]
    exact Nat.zero_le _
  have hj : 1 ≤ j := hj
  have hjX : j ≤ Nat.card X := le_trans hjk hk
  rw [bellDefect_eq_spectrum j G X hjX, bellDefect_eq_spectrum k G X hk]
  refine Nat.mul_le_mul_right _ ?_
  have hsub : Finset.range (j + 1) ⊆ Finset.range (k + 1) := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  calc ∑ s ∈ Finset.range (j + 1), stirling j s * (injOrbits G X s - 1)
      ≤ ∑ s ∈ Finset.range (j + 1), stirling k s * (injOrbits G X s - 1) :=
        Finset.sum_le_sum fun s _ =>
          Nat.mul_le_mul_right _ (stirling_le_stirling_of_le hj hjk s)
    _ ≤ ∑ s ∈ Finset.range (k + 1), stirling k s * (injOrbits G X s - 1) :=
        Finset.sum_le_sum_of_subset hsub

/-- Failure of `j`-transitivity persists, as a positive defect, at every longer tuple length. -/
theorem bellDefect_pos_of_lt_pos {j k : ℕ} (hjk : j ≤ k) (hk : k ≤ Nat.card X)
    (hj : 0 < bellDefect j G X) : 0 < bellDefect k G X :=
  lt_of_lt_of_le hj (bellDefect_mono G X hjk hk)

/-- Combining monotonicity with the propagation constant: for `2 ≤ k ≤ |X|` the defect at level
`k` dominates both `D_2` and `(B_k − 1)/2 · D_2`. -/
theorem bellDefect_two_le_and_propagation (k : ℕ) (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X) :
    bellDefect 2 G X ≤ bellDefect k G X
      ∧ (bell k - 1) * bellDefect 2 G X ≤ 2 * bellDefect k G X :=
  ⟨bellDefect_mono G X hk2 hk, bellDefect_two_propagation k G X hk2 hk⟩

end Defect

end BellDefectGraded