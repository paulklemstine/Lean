/-
# LYM Inequality (Lubell–Yamamoto–Meshalkin)

The LYM inequality states that for an antichain `𝒜` in the power set of an
n-element set, ∑_{A ∈ 𝒜} 1/C(n,|A|) ≤ 1.

This implies the Sperner bound: the largest antichain in 2^[n] has size C(n, ⌊n/2⌋).

We formalize this via a counting argument with permutations.
-/

import Mathlib

open Finset Fintype Nat

namespace LYM

set_option maxHeartbeats 800000
set_option maxRecDepth 1000

variable {n : ℕ}

/-- An antichain in the power set lattice: no element contains another. -/
def IsAntichain (𝒜 : Finset (Finset (Fin n))) : Prop :=
  ∀ A ∈ 𝒜, ∀ B ∈ 𝒜, A ⊆ B → A = B

/-
The LYM inequality: for an antichain 𝒜 in 2^[n],
    ∑_{A ∈ 𝒜} 1/C(n,|A|) ≤ 1.
-/
theorem lym_inequality (𝒜 : Finset (Finset (Fin n)))
    (h_anti : IsAntichain 𝒜) :
    ∑ A ∈ 𝒜, ((n.choose A.card : ℚ))⁻¹ ≤ 1 := by
      -- For each set A of size k, define the set of maximal chains through A: these are permutations σ of [n] such that {σ(1),...,σ(k)} = A. There are k!(n-k)! such permutations.
      have h_chain_count : ∀ A ∈ 𝒜, (Nat.factorial (Finset.card A) * Nat.factorial (n - Finset.card A) : ℚ) ≤ Finset.card (Finset.filter (fun σ : Equiv.Perm (Fin n) => Finset.image (fun i => σ i) (Finset.univ.filter (fun j => j.val < Finset.card A)) = A) (Finset.univ : Finset (Equiv.Perm (Fin n)))) := by
        intro A hA;
        -- Fix an ordering of the elements of $A$ and $[n] \setminus A$.
        obtain ⟨σ_A, hσ_A⟩ : ∃ σ_A : Fin (Finset.card A) → Fin n, Function.Injective σ_A ∧ ∀ i, σ_A i ∈ A := by
          exact ⟨ fun i => A.orderEmbOfFin rfl i, by aesop_cat, fun i => A.orderEmbOfFin_mem rfl _ ⟩
        obtain ⟨σ_notA, hσ_notA⟩ : ∃ σ_notA : Fin (n - Finset.card A) → Fin n, Function.Injective σ_notA ∧ ∀ i, σ_notA i ∉ A := by
          have h_compl : Finset.card (Finset.univ \ A) = n - Finset.card A := by
            simp +decide [ Finset.card_sdiff ];
          exact ⟨ fun i => Finset.orderEmbOfFin _ ( by aesop ) i, by aesop_cat, fun i => Finset.mem_sdiff.mp ( Finset.orderEmbOfFin_mem _ ( by aesop ) i ) |>.2 ⟩;
        -- For each permutation of $A$ and $[n] \setminus A$, we can construct a permutation of $[n]$ that maps to $A$.
        have h_permutations : Finset.image (fun (p : Equiv.Perm (Fin (Finset.card A)) × Equiv.Perm (Fin (n - Finset.card A))) => Equiv.ofBijective (fun i => if h : i.val < Finset.card A then σ_A (p.1 ⟨i.val, h⟩) else σ_notA (p.2 ⟨i.val - Finset.card A, by
          rw [ tsub_lt_tsub_iff_right ] <;> linarith [ Fin.is_lt i ]⟩)) ⟨by
        intro i j hij;
        by_cases hi : ( i : ℕ ) < Finset.card A <;> by_cases hj : ( j : ℕ ) < Finset.card A <;> simp_all +decide [ hσ_A.1.eq_iff, hσ_notA.1.eq_iff ];
        · exact Fin.ext hij;
        · exact False.elim <| hσ_notA.2 _ <| hij ▸ hσ_A.2 _;
        · exact False.elim <| hσ_notA.2 _ <| hij.symm ▸ hσ_A.2 _;
        · grind, by
          intro x; by_cases hx : x ∈ A <;> simp_all +decide [ Function.Surjective ] ;
          · -- Since $x \in A$, there exists some $i \in \{0, 1, ..., |A| - 1\}$ such that $\sigma_A(i) = x$.
            obtain ⟨i, hi⟩ : ∃ i : Fin (Finset.card A), σ_A i = x := by
              have h_image : Finset.image σ_A Finset.univ = A := by
                exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => hσ_A.2 i ) ( by rw [ Finset.card_image_of_injective _ hσ_A.1, Finset.card_fin ] );
              exact Finset.mem_image.mp ( h_image.symm ▸ hx ) |> Exists.imp fun i => And.right;
            use ⟨ p.1.symm i, by
              exact lt_of_lt_of_le ( Fin.is_lt _ ) ( Nat.le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ⟩
            generalize_proofs at *;
            aesop;
          · -- Since $x \notin A$, there exists some $i$ such that $\sigma_notA i = x$.
            obtain ⟨i, hi⟩ : ∃ i : Fin (n - Finset.card A), σ_notA i = x := by
              have h_image : Finset.image σ_notA Finset.univ = Finset.univ \ A := by
                refine' Finset.eq_of_subset_of_card_le ( fun x hx => _ ) _;
                · grind +revert;
                · rw [ Finset.card_image_of_injective _ hσ_notA.1 ] ; simp +decide [ Finset.card_sdiff ];
              replace h_image := Finset.ext_iff.mp h_image x; aesop;
            use ⟨ p.2.symm i + Finset.card A, by
              grind ⟩ ; aesop⟩) (Finset.univ : Finset (Equiv.Perm (Fin (Finset.card A)) × Equiv.Perm (Fin (n - Finset.card A)))) ⊆ Finset.filter (fun σ : Equiv.Perm (Fin n) => Finset.image (fun i => σ i) (Finset.univ.filter (fun j => j.val < Finset.card A)) = A) (Finset.univ : Finset (Equiv.Perm (Fin n))) := by
          simp +decide [ Finset.subset_iff ];
          rintro σ p q rfl; ext x; simp +decide [ Finset.mem_image, Finset.mem_filter ] ;
          constructor;
          · grind;
          · intro hx;
            -- Since $x \in A$, there exists some $i \in \{0, 1, ..., |A|-1\}$ such that $\sigma_A(i) = x$.
            obtain ⟨i, hi⟩ : ∃ i : Fin (Finset.card A), σ_A i = x := by
              have h_image : Finset.image σ_A Finset.univ = A := by
                exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => hσ_A.2 i ) ( by rw [ Finset.card_image_of_injective _ hσ_A.1, Finset.card_fin ] );
              exact Finset.mem_image.mp ( h_image.symm ▸ hx ) |> Exists.imp fun i => And.right;
            use ⟨ p.symm i, by
              exact lt_of_lt_of_le ( Fin.is_lt _ ) ( Nat.le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ⟩ ; aesop;
        refine' mod_cast le_trans _ ( Finset.card_mono h_permutations );
        rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
        · norm_num [ Fintype.card_perm ];
        · intro a b c d h; simp_all +decide [ Equiv.Perm.ext_iff, funext_iff ] ;
          constructor;
          · intro x; specialize h ⟨ x, by linarith [ Fin.is_lt x, Finset.card_le_univ A, show n ≥ #A from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ] ⟩ ; aesop;
          · intro x; specialize h ⟨ x + #A, by linarith [ Fin.is_lt x, Nat.sub_add_cancel ( show #A ≤ n from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ] ⟩ ; aesop;
      -- Since these sets of permutations are pairwise disjoint for an antichain, we can sum their cardinalities.
      have h_disjoint : ∀ A ∈ 𝒜, ∀ B ∈ 𝒜, A ≠ B → Disjoint (Finset.filter (fun σ : Equiv.Perm (Fin n) => Finset.image (fun i => σ i) (Finset.univ.filter (fun j => j.val < Finset.card A)) = A) (Finset.univ : Finset (Equiv.Perm (Fin n)))) (Finset.filter (fun σ : Equiv.Perm (Fin n) => Finset.image (fun i => σ i) (Finset.univ.filter (fun j => j.val < Finset.card B)) = B) (Finset.univ : Finset (Equiv.Perm (Fin n)))) := by
        intro A hA B hB hAB; rw [ Finset.disjoint_left ] ; intro σ hσ hσ'; simp_all +decide [ Finset.ext_iff ] ;
        -- Since $A$ and $B$ are distinct and $\mathcal{A}$ is an antichain, $A$ cannot be a subset of $B$ and $B$ cannot be a subset of $A$.
        have h_not_subset : ¬(A ⊆ B) ∧ ¬(B ⊆ A) := by
          exact ⟨ fun h => hAB.elim fun x hx => hx <| by have := h_anti A hA B hB h; aesop, fun h => hAB.elim fun x hx => hx <| by have := h_anti B hB A hA h; aesop ⟩;
        grind;
      -- Therefore, the sum of the cardinalities of these sets is at most the total number of permutations, which is n!.
      have h_sum_card : ∑ A ∈ 𝒜, (Nat.factorial (Finset.card A) * Nat.factorial (n - Finset.card A) : ℚ) ≤ Nat.factorial n := by
        refine' le_trans ( Finset.sum_le_sum h_chain_count ) _;
        rw_mod_cast [ ← Finset.card_biUnion ];
        · exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide [ Fintype.card_perm ] );
        · exact fun x hx y hy hxy => h_disjoint x hx y hy hxy;
      convert div_le_one_of_le₀ h_sum_card ( by positivity : ( 0 : ℚ ) ≤ n ! ) using 1;
      rw [ Finset.sum_div _ _ _ ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rw [ Nat.cast_choose ] ; ring;
      · norm_num ; ring;
      · exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-
**Sperner's theorem**: the largest antichain in 2^[n] has size at most C(n, ⌊n/2⌋).
-/
theorem sperner_bound (𝒜 : Finset (Finset (Fin n)))
    (h_anti : IsAntichain 𝒜) :
    𝒜.card ≤ n.choose (n / 2) := by
      -- Applying the inequality from the LYM theorem where each term is weighted by the reciprocal of binomial coefficients.
      have h_l : (∑ A ∈ 𝒜, (1 : ℚ) / Nat.choose n A.card) ≤ 1 := by
        simpa using lym_inequality 𝒜 h_anti;
      have h_bound : ∀ A ∈ 𝒜, (1 / Nat.choose n A.card : ℚ) ≥ 1 / Nat.choose n (n / 2) := by
        exact fun A hA => one_div_le_one_div_of_le ( Nat.cast_pos.mpr ( Nat.choose_pos ( show #A ≤ n from le_trans ( Finset.card_le_univ _ ) ( by simpa ) ) ) ) ( mod_cast Nat.choose_le_middle _ _ );
      contrapose! h_l;
      refine' lt_of_lt_of_le _ ( Finset.sum_le_sum h_bound ) ; norm_num [ h_l, Nat.choose_pos ];
      rw [ ← div_eq_mul_inv, one_lt_div ] <;> norm_cast ; linarith [ Nat.choose_pos ( Nat.div_le_self n 2 ) ]

end LYM