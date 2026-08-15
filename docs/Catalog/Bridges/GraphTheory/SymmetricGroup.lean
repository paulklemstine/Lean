/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Symmetric Group Specialization

This file specializes the abstract Cayley graph spectral framework
to the symmetric group S_n, using the classical generators
(adjacent transposition and long cycle) and proving energy rigidity.

## Main results

* `adjTransposition` — the adjacent transposition (0 1) in S_n
* `longCycleSn` — the long cycle (0 1 2 ... n-1) in S_n
* `longCycle_adjTransp_closure_eq_top` — these generators generate S_n
* `spectral_nondegeneracy_Sn` — energy rigidity for these generators
-/
import Mathlib
import Logic.GraphTheory.Defs
import Bridges.Connectivity
import Bridges.LFunctions.SpectralGap
open Finset BigOperators Equiv.Perm

/-! ## Standard generators of S_n -/

/-- The adjacent transposition (0 1) in S_n. -/
def adjTransposition (n : ℕ) (hn : 2 ≤ n) : Equiv.Perm (Fin n) :=
  Equiv.swap (⟨0, by omega⟩ : Fin n) (⟨1, by omega⟩ : Fin n)

/-- The long cycle (0 1 2 ... n-1) in S_{n+1}, using Fin.cycleRange. -/
def longCycleSn (n : ℕ) : Equiv.Perm (Fin (n + 1)) :=
  Fin.cycleRange (Fin.last n)

/-
The adjacent transposition (0 1) together with the long cycle (0 1 ... n)
    generate the full symmetric group S_{n+1}.

    This is a classical theorem in combinatorial group theory. The proof
    works by showing that all adjacent transpositions (i, i+1) can be
    obtained by conjugation, and these generate S_{n+1}.
-/
theorem longCycle_adjTransp_closure_eq_top (n : ℕ) (hn : 1 ≤ n) :
    Subgroup.closure ({Equiv.swap (⟨0, by omega⟩ : Fin (n + 1))
      ⟨1, by omega⟩, longCycleSn n} :
      Set (Equiv.Perm (Fin (n + 1)))) = ⊤ := by
  -- By conjugating the swap of 0 and 1 with powers of the long cycle, we can obtain all adjacent swaps.
  have h_adjacent_swaps : ∀ i : Fin n, Equiv.swap (⟨i, by linarith [Fin.is_lt i]⟩ : Fin (n + 1)) (⟨i + 1, by linarith [Fin.is_lt i]⟩ : Fin (n + 1)) ∈ Subgroup.closure ({Equiv.swap ⟨0, by omega⟩ ⟨1, by omega⟩, longCycleSn n} : Set (Equiv.Perm (Fin (n + 1)))) := by
    intro i;
    induction' i with i ih;
    induction' i with i ih;
    · exact Subgroup.subset_closure ( Set.mem_insert _ _ );
    · -- By conjugating the swap of i and i+1 with the long cycle, we get the swap of i+1 and i+2.
      have h_conj : Equiv.swap (⟨i + 1, by linarith⟩ : Fin (n + 1)) (⟨i + 2, by linarith⟩ : Fin (n + 1)) = (longCycleSn n) * Equiv.swap (⟨i, by linarith⟩ : Fin (n + 1)) (⟨i + 1, by linarith⟩ : Fin (n + 1)) * (longCycleSn n)⁻¹ := by
        ext x; simp +decide [ Equiv.swap_apply_def, longCycleSn ] ;
        rcases x with ⟨ _ | x, hx ⟩ <;> norm_num [ Fin.ext_iff, Fin.val_add ];
        · split_ifs <;> norm_num ; linarith;
          linarith;
        · split_ifs <;> simp_all +decide [ Fin.ext_iff, Fin.coe_sub_one ];
          · rw [ Nat.mod_eq_of_lt ( by linarith ) ];
          · rw [ Nat.mod_eq_of_lt ( by linarith ) ];
          · rw [ Nat.mod_eq_of_lt hx ];
      exact h_conj.symm ▸ Subgroup.mul_mem _ ( Subgroup.mul_mem _ ( Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) ) ( by solve_by_elim [ Nat.lt_of_succ_lt ] ) ) ( Subgroup.inv_mem _ ( Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) ) );
  -- By induction on $j - i$, we can show that any transposition $(i, j)$ is in the subgroup.
  have h_transpositions_induction : ∀ i j : Fin (n + 1), i < j → Equiv.swap i j ∈ Subgroup.closure ({Equiv.swap ⟨0, by omega⟩ ⟨1, by omega⟩, longCycleSn n} : Set (Equiv.Perm (Fin (n + 1)))) := by
    intro i j hij
    induction' j using Fin.induction with j ih generalizing i;
    · tauto;
    · by_cases hij' : i < Fin.castSucc j;
      · have h_transpositions_induction_step : Equiv.swap i (Fin.succ j) = Equiv.swap i (Fin.castSucc j) * Equiv.swap (Fin.castSucc j) (Fin.succ j) * Equiv.swap i (Fin.castSucc j) := by
          grind +suggestions;
        exact h_transpositions_induction_step.symm ▸ Subgroup.mul_mem _ ( Subgroup.mul_mem _ ( ih _ hij' ) ( h_adjacent_swaps _ ) ) ( ih _ hij' );
      · cases eq_or_lt_of_le ( show i ≤ Fin.castSucc j from Nat.le_of_lt_succ hij ) <;> aesop;
  refine' eq_top_iff.mpr fun g hg => _;
  induction' g using Equiv.Perm.swap_induction_on' with g i j hij ih;
  · exact OneMemClass.one_mem _;
  · exact Subgroup.mul_mem _ ( ih trivial ) ( if hij' : i < j then h_transpositions_induction i j hij' else by simpa [ Equiv.swap_comm, hij' ] using h_transpositions_induction j i ( lt_of_le_of_ne ( le_of_not_gt hij' ) hij.symm ) )

/-
The generator set {τ, τ⁻¹, σ, σ⁻¹} for the long cycle and adjacent
    transposition is symmetric.
-/
theorem adjTransp_longCycle_gens_symm (n : ℕ) (hn : 1 ≤ n) :
    let σ := Equiv.swap (⟨0, by omega⟩ : Fin (n + 1)) ⟨1, by omega⟩
    let τ := longCycleSn n
    let S : Finset (Equiv.Perm (Fin (n + 1))) := {σ, σ⁻¹, τ, τ⁻¹}
    ∀ g ∈ S, g⁻¹ ∈ S := by
  simp +zetaDelta at *

/-- **Theorem 4 (Spectral nondegeneracy for S_{n+1} with standard generators)** -/
theorem spectral_nondegeneracy_Sn (n : ℕ) (hn : 1 ≤ n)
    (f : Equiv.Perm (Fin (n + 1)) → ℝ) :
    let σ := Equiv.swap (⟨0, by omega⟩ : Fin (n + 1)) ⟨1, by omega⟩
    let τ := longCycleSn n
    let S : Finset (Equiv.Perm (Fin (n + 1))) := {σ, σ⁻¹, τ, τ⁻¹}
    cayleyDirichletEnergy S f = 0 ↔ ∃ c : ℝ, ∀ x, f x = c := by
  intro σ τ S
  apply cayleyDirichletEnergy_eq_zero_iff_constant
  · exact adjTransp_longCycle_gens_symm n hn
  · have h := longCycle_adjTransp_closure_eq_top n hn
    refine le_antisymm le_top ?_
    rw [← h]
    apply Subgroup.closure_mono
    intro g hg
    simp only [S]
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hg
    rcases hg with rfl | rfl <;> simp [σ, τ]

/-- Zero Dirichlet energy implies zero variance for the standard S_{n+1} generators. -/
theorem variance_Sn_zero_of_energy_zero (n : ℕ) (hn : 1 ≤ n)
    (f : Equiv.Perm (Fin (n + 1)) → ℝ) :
    let σ := Equiv.swap (⟨0, by omega⟩ : Fin (n + 1)) ⟨1, by omega⟩
    let τ := longCycleSn n
    let S : Finset (Equiv.Perm (Fin (n + 1))) := {σ, σ⁻¹, τ, τ⁻¹}
    cayleyDirichletEnergy S f = 0 → variance f = 0 := by
  intro σ τ S hE
  obtain ⟨c, hc⟩ := (spectral_nondegeneracy_Sn n hn f).mp hE
  unfold variance meanValue
  simp [hc]