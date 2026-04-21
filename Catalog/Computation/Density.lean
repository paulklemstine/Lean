/-! # CatalogBuild.Computation.Density

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Density
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15] -/
def EML_den (a b : ℝ) : ℝ := Real.exp a - Real.log b




/-- [Section: # CatalogBuild.Computation.Density
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15] -/
def EMLReach : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S =>
    let prev := EMLReach n S
    prev ∪ {v | ∃ a ∈ prev, ∃ b ∈ prev, v = EML_den a b}




def EMLFull (S : Set ℝ) : Set ℝ := ⋃ n, EMLReach n S




theorem EMLReach_mono (S : Set ℝ) (n : ℕ) :
    EMLReach n S ⊆ EMLReach (n + 1) S :=
  fun _ hx => Or.inl hx




theorem EMLReach_mono_gen (S : Set ℝ) {m n : ℕ} (h : m ≤ n) :
    EMLReach m S ⊆ EMLReach n S := by
  induction h with
  | refl => exact Set.Subset.rfl
  | step _ ih => exact Set.Subset.trans ih (EMLReach_mono S _)




theorem mem_EMLFull_of_mem_reach (S : Set ℝ) (n : ℕ) (x : ℝ) (hx : x ∈ EMLReach n S) :
    x ∈ EMLFull S :=
  Set.mem_iUnion.mpr ⟨n, hx⟩




theorem one_in_reach : (1 : ℝ) ∈ EMLReach 0 {1} := Set.mem_singleton 1




theorem e_in_reach : Real.exp 1 ∈ EMLReach 1 {1} := by
  show Real.exp 1 ∈ {(1 : ℝ)} ∪ _
  right
  exact ⟨1, Set.mem_singleton 1, 1, Set.mem_singleton 1, by simp [EML_den, Real.log_one]⟩




def eTow : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTow n)




theorem eTow_pos (n : ℕ) : 0 < eTow n := by
  induction n with
  | zero => norm_num [eTow]
  | succ _ _ => exact Real.exp_pos _




theorem eTow_in_reach (n : ℕ) : eTow n ∈ EMLReach n {1} := by
  induction n with
  | zero => exact one_in_reach
  | succ n ih =>
    show eTow (n + 1) ∈ EMLReach n {1} ∪ _
    right
    refine ⟨eTow n, ih, 1, EMLReach_mono_gen {1} (Nat.zero_le n) one_in_reach, ?_⟩
    simp [eTow, EML_den, Real.log_one]




theorem eTow_strictMono : StrictMono eTow := by
  apply strictMono_nat_of_lt_succ
  intro n; simp [eTow]
  linarith [Real.add_one_le_exp (eTow n)]




theorem EMLFull_unbounded_above :
    ∀ M : ℝ, ∃ v ∈ EMLFull {1}, v > M := by
  intro M
  obtain ⟨n, hn⟩ : ∃ n : ℕ, eTow n > M := by
    by_contra h; push_neg at h
    have hge : ∀ k : ℕ, eTow k ≥ 1 + k := by
      intro k; induction k with
      | zero => simp [eTow]
      | succ k ihk => simp [eTow]; push_cast; linarith [Real.add_one_le_exp (eTow k)]
    have := h (⌈M⌉₊ + 2)
    have := hge (⌈M⌉₊ + 2)
    have : (⌈M⌉₊ : ℝ) ≥ M := Nat.le_ceil M
    push_cast at *; linarith
  exact ⟨eTow n, mem_EMLFull_of_mem_reach {1} n _ (eTow_in_reach n), hn⟩




theorem one_minus_log_lt_one (y : ℝ) (hy : 1 < y) :
    EML_den 0 y < 1 := by
  simp [EML_den]; linarith [Real.log_pos hy]




theorem depth_zero_singleton : EMLReach 0 {1} = {1} := rfl




end
