/-! # CatalogBuild.Logic.SetTheory

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6
-/

import Mathlib

theorem nat_int_equipollent : Cardinal.mk ℕ = Cardinal.mk ℤ := by
  simp +decide [ Cardinal.mk_int ]

/-
PROBLEM
ℕ is countably infinite.

PROVIDED SOLUTION
Use Cardinal.mk_nat which says Cardinal.mk ℕ = ℵ₀.
-/

theorem nat_countable : Cardinal.mk ℕ = Cardinal.aleph0 := by
  simp +zetaDelta at *

/-
PROBLEM
ℝ is uncountable.

PROVIDED SOLUTION
Use Cardinal.not_countable_real or the fact that cardinal of ℝ is continuum > ℵ₀.
-/

theorem nat_well_ordered (S : Set ℕ) (hS : S.Nonempty) :
    ∃ m ∈ S, ∀ n ∈ S, m ≤ n := by
      exact ⟨ _, Nat.sInf_mem hS, fun n hn => Nat.sInf_le hn ⟩

/-
PROBLEM
Strong induction principle.

PROVIDED SOLUTION
Use Nat.strongRecOn or well-founded induction on ℕ.
-/

theorem strong_induction (P : ℕ → Prop)
    (h : ∀ n, (∀ m, m < n → P m) → P n) : ∀ n, P n := by
      exact?

/-! ## Section 3: Boolean Algebra -/

/-
PROBLEM
De Morgan's laws for sets.

PROVIDED SOLUTION
Use Set.compl_union.
-/

theorem de_morgan_union {α : Type*} (A B : Set α) :
    (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ := by
      exact Set.compl_union A B

/-
PROVIDED SOLUTION
Use Set.compl_inter.
-/

theorem de_morgan_inter {α : Type*} (A B : Set α) :
    (A ∩ B)ᶜ = Aᶜ ∪ Bᶜ := by
      grind
