/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import Mathlib

/-!
# Subgroup existence and uniqueness in finite cyclic groups

For a finite cyclic group `G`, every divisor `d` of `|G|` gives rise to a unique subgroup
of order `d`. This is a fundamental structural theorem that drives the Galois correspondence
for cyclic extensions.

## Main results

* `cyclic_group_exists_subgroup_of_card_dvd`: existence of a subgroup of any divisor order
* `cyclic_group_unique_subgroup_of_card`: uniqueness of such subgroups
-/

open Finset Subgroup

variable {G : Type*} [Group G] [Fintype G]

/-
In a finite cyclic group, for every divisor `d` of the group order,
    there exists an element of order `d`.
-/
theorem cyclic_exists_orderOf_eq_of_dvd [IsCyclic G] {d : ℕ} (hd : d ∣ Fintype.card G) :
    ∃ g : G, orderOf g = d := by
  -- Use IsCyclic.card_orderOf_eq_totient to show that the set {a | orderOf a = d} has cardinality d.totient > 0 (since d ≥ 1 because d divides Fintype.card G and G is finite nonempty). Therefore there exists an element of order d.
  have h_card_pos : 0 < Finset.card (Finset.filter (fun a : G => orderOf a = d) Finset.univ) := by
    convert Nat.totient_pos.mpr ( Nat.pos_of_dvd_of_pos hd ( Fintype.card_pos ) ) using 1;
    convert IsCyclic.card_orderOf_eq_totient hd;
  exact Exists.elim ( Finset.card_pos.mp h_card_pos ) fun x hx => ⟨ x, by simpa using hx ⟩

/-
In a finite cyclic group, for every divisor `d` of the group order,
    there exists a subgroup of cardinality `d`.
-/
theorem cyclic_group_exists_subgroup_of_card_dvd [IsCyclic G]
    (d : ℕ) (hd : d ∣ Fintype.card G) :
    ∃ H : Subgroup G, Nat.card H = d := by
  -- By the existence of elements of order `d` in cyclic groups, there exists `g` in `G` such that `orderOf g = d`.
  obtain ⟨g, hg⟩ : ∃ g : G, orderOf g = d := cyclic_exists_orderOf_eq_of_dvd hd;
  exact ⟨ Subgroup.zpowers g, by rw [ Nat.card_eq_fintype_card, Fintype.card_zpowers, hg ] ⟩

/-
In a finite cyclic group, the subgroup of a given divisor order is unique.
-/
theorem cyclic_group_unique_subgroup_of_card [IsCyclic G]
    (d : ℕ) (hd : d ∣ Fintype.card G) :
    ∃! H : Subgroup G, Nat.card H = d := by
  -- Let $H$ be a subgroup of $G$ with order $d$.
  obtain ⟨H, hH⟩ : ∃ H : Subgroup G, Nat.card H = d := cyclic_group_exists_subgroup_of_card_dvd d hd;
  -- In a cyclic group of order $n$, for each $d \mid n$ there is exactly one subgroup of order $d$ - it consists of all elements whose order divides $d$.
  have h_unique : ∀ H : Subgroup G, (Nat.card H) = d → ∀ K : Subgroup G, (Nat.card K) = d → H = K := by
    -- Any two subgroups of the same finite order in a cyclic group must be equal because they both equal the set of elements x with x^d = 1, and in a cyclic group |{x | x^d = 1}| ≤ d (from IsCyclic.card_pow_eq_one_le).
    have h_card_pow_eq_one_le : {x : G | x ^ d = 1}.ncard ≤ d := by
      convert IsCyclic.card_pow_eq_one_le ( Nat.pos_of_dvd_of_pos hd Fintype.card_pos );
      convert Set.ncard_coe_finset _;
      all_goals try infer_instance;
      swap;
      exacts [ Classical.decEq G, by simp +decide ];
    -- If $H$ and $K$ are subgroups of $G$ with $|H| = |K| = d$, then $H$ and $K$ are both contained in the set of elements of order dividing $d$.
    intros H hH K hK
    have hH_subset : H ≤ {x : G | x ^ d = 1} := by
      intro x hx
      have hx_order : x ^ d = 1 := by
        have h_order_div_d : ∀ x : H, x ^ d = 1 := by
          simp +decide [ ← hH, pow_card_eq_one ];
        simpa using congr_arg Subtype.val ( h_order_div_d ⟨ x, hx ⟩ )
      exact hx_order
    have hK_subset : K ≤ {x : G | x ^ d = 1} := by
      intro x hx; have := Subgroup.card_subgroup_dvd_card K; simp_all +decide [ Nat.dvd_prime ] ;
      have h_order_div_d : ∀ x : K, x ^ d = 1 := by
        simp +decide [ ← hK, pow_card_eq_one ];
      simpa [ Subtype.ext_iff ] using h_order_div_d ⟨ x, hx ⟩;
    -- Since $H$ and $K$ are both subsets of the set of elements of order dividing $d$ and have the same cardinality $d$, they must be equal.
    have h_eq : (H : Set G) = {x : G | x ^ d = 1} ∧ (K : Set G) = {x : G | x ^ d = 1} := by
      have h_eq : (H : Set G).ncard = d ∧ (K : Set G).ncard = d := by
        aesop;
      exact ⟨ Set.eq_of_subset_of_ncard_le hH_subset ( by linarith ), Set.eq_of_subset_of_ncard_le hK_subset ( by linarith ) ⟩;
    exact SetLike.coe_injective ( h_eq.1.trans h_eq.2.symm );
  exact ⟨ H, hH, fun K hK => h_unique K hK H hH ⟩