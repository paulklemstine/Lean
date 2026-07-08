/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra

/-!
# Tropical Hash Collisions

This file develops two basic properties of the tropical (min-plus) hash function
`TSHA h m = ⨅ i, m i + h i`:

* `TSHA_lipschitz` — the hash is 1-Lipschitz in the message (in sup norm).
* `TSHA_preimage_nonunique` — whenever the index type has at least two elements,
  every message admits a distinct message with the same hash value.
-/

noncomputable section
open Finset
open scoped Classical
namespace TSHACollisions
variable {ι : Type*} [Fintype ι] [Nonempty ι]

def TSHA (h m : ι → ℝ) : ℝ := ⨅ i, m i + h i

lemma TSHA_eq_inf' (h m : ι → ℝ) :
    TSHA h m = Finset.univ.inf' Finset.univ_nonempty (fun i => m i + h i) := by
  unfold TSHA
  exact (Finset.inf'_univ_eq_ciInf _).symm

lemma TSHA_le (h m : ι → ℝ) (i : ι) : TSHA h m ≤ m i + h i := by
  rw [TSHA_eq_inf']
  exact Finset.inf'_le _ (Finset.mem_univ i)

lemma TSHA_exists_eq (h m : ι → ℝ) : ∃ i, TSHA h m = m i + h i := by
  rw [TSHA_eq_inf']
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty (fun i => m i + h i)
  exact ⟨i, hi⟩

lemma TSHA_eq_of (h m : ι → ℝ) (i : ι) (hmin : ∀ j, m i + h i ≤ m j + h j) : TSHA h m = m i + h i := by
  rw [TSHA_eq_inf']
  refine le_antisymm (Finset.inf'_le _ (Finset.mem_univ i)) ?_
  exact Finset.le_inf' _ _ (fun j _ => hmin j)

theorem TSHA_lipschitz (h m m' : ι → ℝ) : |TSHA h m - TSHA h m'| ≤ ⨆ i, |m i - m' i| := by
  convert abs_inf_sub_inf_le_sup Finset.univ Finset.univ_nonempty ( fun i => m i + h i ) ( fun i => m' i + h i ) using 1;
  · rw [ ← TSHA_eq_inf', ← TSHA_eq_inf' ];
  · convert ( ciSup_eq_of_forall_le_of_forall_lt_exists_gt ( fun i => ?_ ) ( fun x hx => ?_ ) );
    · grind;
    · exact Finset.le_sup' ( fun k => |m k + h k - ( m' k + h k )| ) ( Finset.mem_univ i ) |> le_trans ( by simp +decide [ add_sub_add_right_eq_sub ] );
    · contrapose! hx; aesop;

/-
Perturbing the message at a coordinate `k` other than a minimizer `imin`
(by adding `1`) leaves the tropical hash unchanged.
-/
lemma TSHA_perturb_eq (h m : ι → ℝ) (imin k : ι) (hk : k ≠ imin)
    (heq : TSHA h m = m imin + h imin) :
    TSHA h (fun i => if i = k then m i + 1 else m i) = TSHA h m := by
  rw [ heq, TSHA_eq_of ];
  rw [ if_neg ( Ne.symm hk ) ];
  intro j; split_ifs <;> simp_all +decide ;
  · linarith [ TSHA_le h m k ];
  · exact heq ▸ TSHA_le h m j

theorem TSHA_preimage_nonunique (h : ι → ℝ) (m : ι → ℝ) (hcard : ∃ (i j : ι), i ≠ j) :
    ∃ m', m' ≠ m ∧ TSHA h m' = TSHA h m := by
  obtain ⟨i₀, j₀, hij⟩ := hcard
  obtain ⟨imin, heq⟩ := TSHA_exists_eq h m
  obtain ⟨k, hk⟩ : ∃ k : ι, k ≠ imin := by
    by_cases hj : j₀ = imin
    · exact ⟨i₀, fun hc => hij (hc.trans hj.symm)⟩
    · exact ⟨j₀, hj⟩
  refine ⟨fun i => if i = k then m i + 1 else m i, ?_, ?_⟩
  · intro hcontra
    have hkk := congrFun hcontra k
    simp only [if_true] at hkk
    linarith
  · exact TSHA_perturb_eq h m imin k hk heq

end TSHACollisions