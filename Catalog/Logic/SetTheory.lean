import Mathlib

/-! # CatalogBuild.Logic.SetTheory

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6
-/

/-- [Section: # CatalogBuild.Logic.SetTheory
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6] -/
theorem nat_int_equipollent : Cardinal.mk ℕ = Cardinal.mk ℤ := by
  simp +decide [ Cardinal.mk_int ]

/-- [Section: # CatalogBuild.Logic.SetTheory
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6] -/
theorem nat_countable : Cardinal.mk ℕ = Cardinal.aleph0 := by
  simp +zetaDelta at *

theorem nat_well_ordered (S : Set ℕ) (hS : S.Nonempty) :
    ∃ m ∈ S, ∀ n ∈ S, m ≤ n := by
      exact ⟨ _, Nat.sInf_mem hS, fun n hn => Nat.sInf_le hn ⟩

theorem strong_induction (P : ℕ → Prop)
    (h : ∀ n, (∀ m, m < n → P m) → P n) : ∀ n, P n := by
      exact?

theorem de_morgan_union {α : Type*} (A B : Set α) :
    (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ := by
      exact Set.compl_union A B

theorem de_morgan_inter {α : Type*} (A B : Set α) :
    (A ∩ B)ᶜ = Aᶜ ∪ Bᶜ := by
      grind

