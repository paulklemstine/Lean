/-
# Sorted Canonical Representatives for Voice-Leading Geometry

This file establishes that the quotient metric on chord space (under permutation of voices)
is exactly computed by sorting both chords and summing coordinatewise absolute differences.
This is a formalization of the discrete 1D optimal transport theorem / rearrangement inequality
applied to music-theoretic voice leading.

## Main Results

* `sortChord` — Canonical sorted representative of a chord's permutation orbit.
* `sortChord_monotone` — The sorted representative is monotone (weakly increasing).
* `sortChord_perm` — The sorted representative is a permutation of the original.
* `vlCostN` — Voice-leading cost: minimum over all permutations of coordinatewise |·|.
* `vlCostN_perm_left` / `vlCostN_perm_right` — Permutation invariance on both arguments.
* `vlCostN_eq_sorted_pairing` — **Main theorem**: the voice-leading cost equals the
  coordinatewise L¹ distance between sorted representatives.
* `vlCostN_compute` / `vlCostN_compute_correct` — Certified computable evaluator.

## Mathematical Significance

The key conceptual move is to replace an abstract quotient by a canonical section: the
sorted representative. The main theorem shows this representative preserves the quotient
metric exactly, turning the voice-leading cost from an existential (infimum over n!
permutations) into an explicit O(n log n) computation: sort and sum.

This is the finite-dimensional shadow of optimal transport theory: monotone coupling
minimizes Wasserstein-1 cost in one dimension.
-/

import Mathlib
import Bridges.VoiceLeadingMonge
open Finset Equiv

/-! ## Definitions -/

/-- Sort a chord (Fin n → ℤ) into weakly increasing order using merge sort.
    This is the canonical representative of the chord's permutation orbit. -/
def sortChord {n : ℕ} (x : Fin n → ℤ) : Fin n → ℤ :=
  fun i => ((List.ofFn x).mergeSort)[i.val]'(by simp [List.length_mergeSort])

/-- The voice-leading cost between two chords: the minimum over all voice permutations
    of the sum of absolute pitch differences. -/
noncomputable def vlCostN {n : ℕ} (x y : Fin n → ℤ) : ℕ :=
  Finset.inf' Finset.univ ⟨1, Finset.mem_univ 1⟩
    (fun σ : Equiv.Perm (Fin n) => ∑ i : Fin n, Int.natAbs (x i - y (σ i)))

/-- Computable voice-leading cost: sort both chords and sum coordinatewise distances. -/
def vlCostN_compute {n : ℕ} (x y : Fin n → ℤ) : ℕ :=
  ∑ i : Fin n, Int.natAbs (sortChord x i - sortChord y i)

/-! ## Properties of sortChord -/

/-- The sorted list has the same length as the original. -/
theorem sortChord_list_length {n : ℕ} (x : Fin n → ℤ) :
    ((List.ofFn x).mergeSort).length = n := by
  simp [List.length_mergeSort, List.length_ofFn]

/-
The sorted chord is monotone (weakly increasing).
-/
theorem sortChord_monotone {n : ℕ} (x : Fin n → ℤ) : Monotone (sortChord x) := by
  unfold sortChord;
  intro i j hij;
  have h_sorted : List.Pairwise (· ≤ ·) ((List.ofFn x).mergeSort (fun a b => decide (a ≤ b))) := by
    exact?;
  rw [ List.pairwise_iff_getElem ] at h_sorted;
  grind

/-- The sorted chord is a permutation of the original (same multiset of values). -/
theorem sortChord_perm_list {n : ℕ} (x : Fin n → ℤ) :
    (List.ofFn x).mergeSort |>.Perm (List.ofFn x) :=
  List.mergeSort_perm _ _

/-
There exists a permutation σ such that sortChord x = x ∘ σ.
-/
theorem sortChord_exists_perm {n : ℕ} (x : Fin n → ℤ) :
    ∃ σ : Equiv.Perm (Fin n), ∀ i, sortChord x i = x (σ i) := by
      unfold sortChord;
      -- By definition of `List.mergeSort`, the sorted list is a permutation of the original list.
      have h_perm : List.Perm (List.mergeSort (List.ofFn x)) (List.ofFn x) := by
        grind +suggestions;
      have h_perm : ∀ (l1 l2 : List ℤ), List.Perm l1 l2 → l1.length = l2.length → ∃ σ : Fin l1.length ≃ Fin l2.length, ∀ i, l1[i] = l2[σ i] := by
        intros l1 l2 h_perm h_len
        induction' h_perm with l1 l2 h_perm h_len ih;
        · exact ⟨ Equiv.refl _, by simp +decide ⟩;
        · obtain ⟨ σ, hσ ⟩ := ih ( by simpa using h_len );
          refine' ⟨ Equiv.ofBijective ( fun i => Fin.cases ⟨ 0, by simp +decide ⟩ ( fun i => Fin.succ ( σ i ) ) i ) ⟨ _, _ ⟩, _ ⟩ <;> simp +decide [ Fin.forall_fin_succ ];
          all_goals simp_all +decide [ Function.Injective, Function.Surjective ];
          all_goals norm_num [ Fin.forall_fin_succ, Fin.exists_fin_succ ] at *;
          exact fun i hi => absurd hi ( ne_of_lt ( Fin.succ_pos _ ) );
          exact fun i => Or.inr ⟨ σ.symm i, by simp +decide ⟩;
          exact fun i => hσ i ▸ rfl;
        · refine' ⟨ Equiv.swap ⟨ 0, by simp +decide ⟩ ⟨ 1, by simp +decide ⟩, _ ⟩ ; simp +decide [ Fin.forall_fin_succ ];
          simp +decide [ Fin.ext_iff, swap_apply_def ];
        · rename_i l₁ l₂ l₃ h₁₂ h₂₃ ih₁ ih₂;
          obtain ⟨σ₁, hσ₁⟩ := ih₁ (by
          exact h₁₂.length_eq)
          obtain ⟨σ₂, hσ₂⟩ := ih₂ (by
          exact h₂₃.length_eq)
          use σ₁.trans σ₂
          intro i
          simp [hσ₁, hσ₂];
      specialize h_perm _ _ ‹_› ( by simp +decide [ List.length_mergeSort ] );
      simp_all +decide [ Fin.ext_iff, List.getElem_ofFn ];
      obtain ⟨ σ, hσ ⟩ := h_perm;
      use Equiv.ofBijective (fun i => ⟨σ ⟨i.val, by
        simp +decide [ List.length_mergeSort ]⟩, by
        grind⟩) (by
      exact ⟨ fun i j hij => by simpa [ Fin.ext_iff ] using σ.injective ( Fin.ext <| by simpa [ Fin.ext_iff ] using hij ), Finite.injective_iff_surjective.mp <| fun i j hij => by simpa [ Fin.ext_iff ] using σ.injective ( Fin.ext <| by simpa [ Fin.ext_iff ] using hij ) ⟩);
      intro i; specialize hσ ⟨ i, by simp +decide [ List.length_mergeSort ] ⟩ ; aesop;

/-
Sorting is invariant under permutation of the input.
-/
theorem sortChord_perm_invariant {n : ℕ} (x : Fin n → ℤ) (σ : Equiv.Perm (Fin n)) :
    sortChord (fun i => x (σ i)) = sortChord x := by
      -- By definition of `sortChord`, we know that `sortChord x` is the sorted version of `x`.
      have h_sort_eq : List.mergeSort (List.ofFn (fun i => x (σ i))) (fun a b => decide (a ≤ b)) = List.mergeSort (List.ofFn x) (fun a b => decide (a ≤ b)) := by
        apply @List.Perm.eq_of_pairwise _ (fun a b => decide (a ≤ b));
        · grind;
        · apply_rules [ List.pairwise_mergeSort ];
          · exact fun a b c ha hb => by simpa using le_trans ( by simpa using ha ) ( by simpa using hb ) ;
          · grind +qlia;
        · -- Apply the lemma that states merge sort produces a sorted list.
          apply List.pairwise_mergeSort;
          · exact fun a b c ha hb => by simpa using le_trans ( by simpa using ha ) ( by simpa using hb ) ;
          · grind +qlia;
        · have h_perm : List.Perm (List.ofFn (fun i => x (σ i))) (List.ofFn x) := by
            rw [ List.ofFn_eq_map, List.ofFn_eq_map ];
            have h_perm : List.Perm (List.map σ (List.finRange n)) (List.finRange n) := by
              exact?;
            simpa using h_perm.map x;
          exact List.Perm.trans ( List.mergeSort_perm _ _ ) ( h_perm.trans ( List.mergeSort_perm _ _ |> List.Perm.symm ) );
      unfold sortChord;
      grind

/-! ## Permutation invariance of vlCostN -/

/-
The voice-leading cost is invariant under permutation of the left argument.
-/
theorem vlCostN_perm_left {n : ℕ} (x y : Fin n → ℤ) (σ : Equiv.Perm (Fin n)) :
    vlCostN (fun i => x (σ i)) y = vlCostN x y := by
      unfold vlCostN;
      have h_reorder : ∀ (f : Equiv.Perm (Fin n) → ℕ), Finset.inf' (Finset.univ : Finset (Equiv.Perm (Fin n))) (by
      exact ⟨ 1, Finset.mem_univ _ ⟩) f = Finset.inf' (Finset.univ : Finset (Equiv.Perm (Fin n))) (by
      exact ⟨ 1, Finset.mem_univ _ ⟩) (fun τ => f (τ * σ)) := by
        intro f
        apply le_antisymm;
        · simp +decide [ Finset.inf'_le_iff ];
          exact fun b => ⟨ _, le_rfl ⟩;
        · simp +decide [ Finset.inf'_le_iff ];
          exact fun b => ⟨ b * σ⁻¹, by simp +decide ⟩
      generalize_proofs at *;
      rw [ h_reorder ] ; simp +decide [ Equiv.Perm.inv_eq_iff_eq ] ;
      exact congr_arg _ ( funext fun τ => Equiv.sum_comp ( σ ) fun i => Int.natAbs ( x i - y ( τ i ) ) )

/-
The voice-leading cost is invariant under permutation of the right argument.
-/
theorem vlCostN_perm_right {n : ℕ} (x y : Fin n → ℤ) (σ : Equiv.Perm (Fin n)) :
    vlCostN x (fun i => y (σ i)) = vlCostN x y := by
      -- By the properties of the infimum, we can rewrite the goal in terms of the infimum over τ' of ∑_i |x(i) - y(τ' i)|.
      apply le_antisymm;
      · unfold vlCostN;
        simp +zetaDelta at *;
        exact fun b => ⟨ σ⁻¹ * b, by simp +decide [ mul_assoc ] ⟩;
      · unfold vlCostN;
        simp +decide [ Finset.inf'_le_iff ];
        exact fun b => ⟨ σ * b, by simp +decide [ Int.natAbs_eq_natAbs_iff ] ⟩

/-- Combined permutation invariance. -/
theorem vlCostN_perm_both {n : ℕ} (x y : Fin n → ℤ) (σ τ : Equiv.Perm (Fin n)) :
    vlCostN (fun i => x (σ i)) (fun i => y (τ i)) = vlCostN x y := by
  rw [vlCostN_perm_left, vlCostN_perm_right]

/-! ## Core: vlCostN equals sorted pairing -/

/-- The optimal cost is at most any specific permutation's cost. -/
theorem vlCostN_le_perm {n : ℕ} (x y : Fin n → ℤ) (σ : Equiv.Perm (Fin n)) :
    vlCostN x y ≤ ∑ i, Int.natAbs (x i - y (σ i)) :=
  Finset.inf'_le _ (Finset.mem_univ σ)

/-- For monotone x and y, the identity matching achieves the optimum. -/
theorem vlCostN_monotone_eq {n : ℕ} (x y : Fin n → ℤ)
    (hx : Monotone x) (hy : Monotone y) :
    vlCostN x y = ∑ i, Int.natAbs (x i - y i) := by
  apply le_antisymm
  · exact vlCostN_le_perm x y 1
  · apply Finset.le_inf'
    intro σ _
    exact sorted_identity_minimizes x y hx hy σ

/-
**Main Theorem.** The voice-leading cost equals the coordinatewise L¹ distance
    between sorted representatives. This identifies the quotient metric with
    the L¹ metric on the sorted Weyl chamber.
-/
theorem vlCostN_eq_sorted_pairing {n : ℕ} (x y : Fin n → ℤ) :
    vlCostN x y =
      ∑ i : Fin n, Int.natAbs (sortChord x i - sortChord y i) := by
        -- By sortChord_exists_perm, there exist σ₁ σ₂ such that sortChord x i = x (σ₁ i) and sortChord y i = y (σ₂ i).
        obtain ⟨σ₁, hσ₁⟩ := sortChord_exists_perm x
        obtain ⟨σ₂, hσ₂⟩ := sortChord_exists_perm y;
        convert vlCostN_monotone_eq ( fun i => sortChord x i ) ( fun i => sortChord y i ) ?_ ?_ using 1;
        · rw [ show ( fun i => sortChord x i ) = fun i => x ( σ₁ i ) from funext hσ₁, show ( fun i => sortChord y i ) = fun i => y ( σ₂ i ) from funext hσ₂, vlCostN_perm_both ];
        · exact sortChord_monotone x;
        · exact sortChord_monotone y

/-- **Correctness of the computable evaluator.** The sorting-based algorithm
    exactly computes the quotient metric. -/
theorem vlCostN_compute_correct {n : ℕ} (x y : Fin n → ℤ) :
    vlCostN_compute x y = vlCostN x y := by
  unfold vlCostN_compute
  exact (vlCostN_eq_sorted_pairing x y).symm

/-! ## Additional properties -/

/-- The voice-leading cost of a chord to itself is zero. -/
theorem vlCostN_self {n : ℕ} (x : Fin n → ℤ) : vlCostN x x = 0 := by
  apply le_antisymm
  · calc vlCostN x x ≤ ∑ i, Int.natAbs (x i - x ((1 : Equiv.Perm (Fin n)) i)) := vlCostN_le_perm x x 1
      _ = 0 := by simp [Equiv.Perm.one_apply]
  · exact Nat.zero_le _

/-
The voice-leading cost is symmetric.
-/
theorem vlCostN_symm {n : ℕ} (x y : Fin n → ℤ) : vlCostN x y = vlCostN y x := by
  convert vlCostN_eq_sorted_pairing x y using 1;
  convert vlCostN_eq_sorted_pairing y x using 1;
  exact Finset.sum_congr rfl fun _ _ => by rw [ ← Int.natAbs_neg, neg_sub ] ;

/-
The voice-leading cost satisfies the triangle inequality.
-/
theorem vlCostN_triangle {n : ℕ} (x y z : Fin n → ℤ) :
    vlCostN x z ≤ vlCostN x y + vlCostN y z := by
      -- Let σ be an optimal permutation for (x, y) and τ be an optimal permutation for (y, z).
      obtain ⟨σ, hσ⟩ : ∃ σ : Equiv.Perm (Fin n), ∑ i, Int.natAbs ((x i) - (y (σ i))) = vlCostN x y := by
        have h_inf : ∃ σ : Equiv.Perm (Fin n), ∀ τ : Equiv.Perm (Fin n), ∑ i, Int.natAbs (x i - y (σ i)) ≤ ∑ i, Int.natAbs (x i - y (τ i)) := by
          simpa using Finset.exists_min_image Finset.univ ( fun τ : Equiv.Perm ( Fin n ) => ∑ i, Int.natAbs ( x i - y ( τ i ) ) ) ⟨ 1, Finset.mem_univ _ ⟩;
        exact ⟨ h_inf.choose, le_antisymm ( Finset.le_inf' _ _ fun τ _ => h_inf.choose_spec τ ) ( Finset.inf'_le _ <| Finset.mem_univ _ ) ⟩
      obtain ⟨τ, hτ⟩ : ∃ τ : Equiv.Perm (Fin n), ∑ i, Int.natAbs ((y (σ i)) - (z (τ (σ i)))) = vlCostN y z := by
        have h_perm : ∃ τ : Equiv.Perm (Fin n), ∑ i, Int.natAbs (y (σ i) - z (τ (σ i))) = vlCostN (fun i => y (σ i)) (fun i => z i) := by
          have h_perm : ∃ τ : Equiv.Perm (Fin n), ∑ i, Int.natAbs (y (σ i) - z (τ i)) = vlCostN (fun i => y (σ i)) (fun i => z i) := by
            have h_perm : ∃ τ : Equiv.Perm (Fin n), ∀ τ' : Equiv.Perm (Fin n), ∑ i, Int.natAbs (y (σ i) - z (τ i)) ≤ ∑ i, Int.natAbs (y (σ i) - z (τ' i)) := by
              simpa using Finset.exists_min_image Finset.univ ( fun τ : Equiv.Perm ( Fin n ) => ∑ i, Int.natAbs ( y ( σ i ) - z ( τ i ) ) ) ⟨ 1, Finset.mem_univ 1 ⟩;
            exact ⟨ h_perm.choose, le_antisymm ( Finset.le_inf' _ _ fun τ' _ => h_perm.choose_spec τ' ) ( Finset.inf'_le _ <| Finset.mem_univ _ ) ⟩;
          obtain ⟨ τ, hτ ⟩ := h_perm; use τ * σ⁻¹; simp_all +decide [ Equiv.Perm.mul_apply ] ;
        exact ⟨ h_perm.choose, h_perm.choose_spec.trans ( vlCostN_perm_left _ _ _ ) ⟩;
      have h_triangle : ∑ i, Int.natAbs ((x i) - (z (τ (σ i)))) ≤ ∑ i, Int.natAbs ((x i) - (y (σ i))) + ∑ i, Int.natAbs ((y (σ i)) - (z (τ (σ i)))) := by
        simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => by omega;
      exact le_trans ( Finset.inf'_le _ <| Finset.mem_univ <| τ * σ ) ( by simpa [ hσ, hτ ] using h_triangle )

/-! ## Quotient structure -/

/-
Two chords are in the same permutation orbit iff they have the same sorted form.
-/
theorem sortChord_eq_iff_same_orbit {n : ℕ} (x y : Fin n → ℤ) :
    sortChord x = sortChord y ↔
      ∃ σ : Equiv.Perm (Fin n), ∀ i, x i = y (σ i) := by
        constructor <;> intro h;
        · -- By definition of $sortChord$, we know that there exist permutations $\sigma$ and $\tau$ such that $sortChord x = x \circ \sigma$ and $sortChord y = y \circ \tau$.
          obtain ⟨σ, hσ⟩ : ∃ σ : Equiv.Perm (Fin n), ∀ i, sortChord x i = x (σ i) := sortChord_exists_perm x
          obtain ⟨τ, hτ⟩ : ∃ τ : Equiv.Perm (Fin n), ∀ i, sortChord y i = y (τ i) := sortChord_exists_perm y;
          use τ * σ⁻¹; aesop;
        · obtain ⟨ σ, hσ ⟩ := h;
          rw [ show x = fun i => y ( σ i ) from funext hσ ];
          exact?

/-! ## Computational Examples -/

/-- C major triad in close position -/
def cMajor3 : Fin 3 → ℤ := ![48, 52, 55]

/-- F major triad in close position -/
def fMajor3 : Fin 3 → ℤ := ![53, 57, 60]

/-- The computable voice-leading cost between C major and F major. -/
example : vlCostN_compute cMajor3 fMajor3 = 15 := by native_decide

/-- Sorting is the identity on already-sorted chords. -/
example : sortChord (![1, 2, 3, 4] : Fin 4 → ℤ) = ![1, 2, 3, 4] := by native_decide

/-- Sorting reorders unsorted chords. -/
example : sortChord (![3, 1, 4, 1] : Fin 4 → ℤ) = ![1, 1, 3, 4] := by native_decide