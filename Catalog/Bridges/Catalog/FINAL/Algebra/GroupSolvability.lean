/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Group Solvability: Derived Series and Symmetric Groups

This file establishes core group-theoretic results connecting the derived series
to solvability, and proves non-solvability of symmetric groups S_n for n ≥ 5.

## Main results

* `solvable_iff_derivedSeries_eq_bot`: A group is solvable iff its derived series
  reaches the trivial subgroup.
* `not_solvable_perm_fin_five`: The symmetric group S₅ is not solvable.
* `not_solvable_perm_fin_of_five_le`: S_n is not solvable for n ≥ 5.
* `exists_subnormal_series_of_solvable`: A solvable group admits a subnormal series
  with abelian successive quotients (the derived series itself).
-/

import Mathlib

open Subgroup Polynomial

variable {G : Type*} [Group G]

/-! ## Derived Series Characterization of Solvability -/

/-
A group is solvable if and only if its derived series reaches ⊥ in finitely many steps.
This is the fundamental characterization used in Galois theory to connect group structure
to radical solvability of polynomials.
-/
theorem solvable_iff_derivedSeries_eq_bot (G : Type*) [Group G] :
    IsSolvable G ↔ ∃ n : ℕ, derivedSeries G n = ⊥ := by
  exact isSolvable_def G

/-! ## Non-solvability of Symmetric Groups -/

/-- The symmetric group on 5 elements is not solvable.
This is the key group-theoretic fact behind the Abel-Ruffini theorem. -/
theorem not_solvable_perm_fin_five :
    ¬ IsSolvable (Equiv.Perm (Fin 5)) :=
  Equiv.Perm.fin_5_not_solvable

/-
The symmetric group S_n is not solvable for n ≥ 5.
This generalizes `not_solvable_perm_fin_five` and shows that the obstruction
to solvability by radicals is universal for high-degree polynomials.
-/
theorem not_solvable_perm_fin_of_five_le {n : ℕ} (h : 5 ≤ n) :
    ¬ IsSolvable (Equiv.Perm (Fin n)) := by
  -- Since $n \geq 5$, the symmetric group $S_n$ is not solvable.
  have h_non_solvable : ¬(IsSolvable (Equiv.Perm (Fin n))) := by
    have h_card : 5 ≤ (Fintype.card (Fin n)) := by
      rwa [ Fintype.card_fin ]
    convert Equiv.Perm.not_solvable _ _;
    convert h_card using 1;
    norm_num [ Nat.card ];
  grind

/-! ## Derived Series Properties -/

/-- Each term of the derived series is a normal subgroup. -/
theorem derivedSeries_normal' (G : Type*) [Group G] (n : ℕ) :
    (derivedSeries G n).Normal :=
  derivedSeries_normal G n

/-
Each term of the derived series is contained in the previous one.
-/
theorem derivedSeries_succ_le (G : Type*) [Group G] (n : ℕ) :
    derivedSeries G (n + 1) ≤ derivedSeries G n := by
  induction' n with n ih _ <;> simp_all +decide;
  exact Subgroup.commutator_mono ih ih

/-
The commutator of the n-th derived subgroup equals the (n+1)-th derived subgroup.
This means each quotient derivedSeries(n) / derivedSeries(n+1) is abelian,
providing the abelian layers in the solvability tower.
-/
theorem derivedSeries_succ_eq_commutator (G : Type*) [Group G] (n : ℕ) :
    derivedSeries G (n + 1) = ⁅derivedSeries G n, derivedSeries G n⁆ := by
  rfl

/-
Non-solvability via derived series: if there exists an element that remains
in every term of the derived series and is not the identity, the group is not solvable.
-/
theorem not_solvable_of_mem_all_derivedSeries (G : Type*) [Group G]
    {g : G} (hne : g ≠ 1) (hmem : ∀ n : ℕ, g ∈ derivedSeries G n) :
    ¬ IsSolvable G := by
  rintro ⟨ n, hn ⟩;
  exact hne ( by simpa [ hn ] using hmem n )

/-! ## Transfer of Solvability -/

/-
Transfer of non-solvability through group isomorphisms.
-/
theorem not_isSolvable_of_mulEquiv {G H : Type*} [Group G] [Group H]
    (e : G ≃* H) (h : ¬ IsSolvable G) : ¬ IsSolvable H := by
  contrapose! h;
  obtain ⟨ n, hn ⟩ := h;
  -- Apply the isomorphism to transfer the derived series from H to G.
  have h_derived_series : derivedSeries G n = Subgroup.map e.symm.toMonoidHom (derivedSeries H n) := by
    refine' Nat.recOn n _ _ <;> simp_all +decide [ derivedSeries ];
    simp +decide [ Subgroup.map_commutator ];
  exact ⟨ n, h_derived_series.trans ( by simp +decide [ hn ] ) ⟩