/-
# Causal Integration Algebra — Composition and Symmetrization

Advanced results on causal systems:
- Symmetrization preserves Φ for symmetric cuts
- Direct sum of systems and its Φ
- Strongly positive systems have Φ > 0
-/

import Mathlib
import Shared.CausalIntegration.Core

open Finset BigOperators

namespace CausalSystem

variable {n : ℕ}

/-! ## Symmetrization -/

/-- Symmetrize a causal system: w'(i,j) = w(i,j) + w(j,i). -/
noncomputable def symmetrize (C : CausalSystem n) : CausalSystem n where
  weight i j := C.weight i j + C.weight j i
  weight_nonneg i j := add_nonneg (C.weight_nonneg i j) (C.weight_nonneg j i)

/-
The symmetrized system has symmetric weights.
-/
theorem symmetrize_weight_comm (C : CausalSystem n) (i j : Fin n) :
    (C.symmetrize).weight i j = (C.symmetrize).weight j i := by
      exact add_comm _ _

/-
Cross-info of the symmetrized system equals the sum of both directed cross-infos.
-/
theorem symmetrize_crossInfo (C : CausalSystem n) (S : Finset (Fin n)) :
    (C.symmetrize).crossInfo S = C.crossInfo S + C.crossInfo (Finset.univ \ S) := by
      unfold CausalSystem.crossInfo CausalSystem.symmetrize; simp +decide [ Finset.sum_add_distrib ] ;
      exact congrArg₂ _ ( Finset.sum_comm ) ( Finset.sum_comm )

/-! ## Strongly Positive Systems -/

/-- A system is strongly positive if all off-diagonal weights are positive. -/
def IsStronglyPositive (C : CausalSystem n) : Prop :=
  ∀ i j, i ≠ j → 0 < C.weight i j

/-
In a strongly positive system, every nontrivial cut has positive cross-info.
-/
theorem crossInfo_pos_of_stronglyPositive (C : CausalSystem n)
    (hsp : C.IsStronglyPositive) (S : Finset (Fin n))
    (hne : S.Nonempty) (hne' : (Finset.univ \ S).Nonempty) :
    0 < C.crossInfo S := by
      -- Since S is nonempty, pick i ∈ S. Since univ \ S is nonempty, pick j ∈ univ \ S.
      obtain ⟨i, hi⟩ : ∃ i, i ∈ S := hne
      obtain ⟨j, hj⟩ : ∃ j, j ∈ Finset.univ \ S := hne';
      refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun i _ => _ ) hi );
      · exact lt_of_lt_of_le ( hsp i j ( by aesop ) ) ( Finset.single_le_sum ( fun x _ => C.weight_nonneg i x ) hj );
      · exact Finset.sum_nonneg fun _ _ => C.weight_nonneg _ _

/-
Strongly positive systems with n ≥ 2 have Φ > 0.
-/
theorem phi_pos_of_stronglyPositive (C : CausalSystem n) (hn : 2 ≤ n)
    (hsp : C.IsStronglyPositive) :
    0 < C.phi hn := by
      unfold CausalSystem.phi;
      simp +zetaDelta at *;
      intro S hS;
      apply_rules [ crossInfo_pos_of_stronglyPositive ];
      · exact Finset.mem_filter.mp hS |>.2.1;
      · contrapose! hS; simp_all +decide ;
        unfold nontrivialBipartitions; aesop;

/-! ## Complement Duality for Symmetric Systems -/

/-
For any system, crossInfo of Sᶜ uses only edges from Sᶜ to S.
-/
theorem crossInfo_compl (C : CausalSystem n) (S : Finset (Fin n)) :
    C.crossInfo (Finset.univ \ S) =
    ∑ i ∈ Finset.univ \ S, ∑ j ∈ S, C.weight i j := by
      unfold CausalSystem.crossInfo; aesop;

end CausalSystem