/-! # CatalogBuild.Logic.InfinityLevels

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 17
-/

import Mathlib

/-- ℵ₀ is infinite. -/
theorem aleph0_infinite : ℵ₀ ≥ ℵ₀ := le_refl _



/-- [Section: # CatalogBuild.Logic.InfinityLevels
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 17] -/
theorem aleph_one_gt_aleph_zero : aleph 0 < aleph 1 := by
  norm_num +zetaDelta at *;
  -- The cardinality of the natural numbers is strictly less than the cardinality of the first uncountable ordinal.
  apply Cardinal.aleph0_lt_aleph_one



theorem aleph_lt_of_lt {α β : Ordinal} (h : α < β) : aleph α < aleph β := by
  convert Cardinal.aleph_lt_aleph.mpr _;
  assumption



theorem every_infinite_cardinal_is_aleph (κ : Cardinal) (hκ : ℵ₀ ≤ κ) :
    ∃ α : Ordinal, aleph α = κ := by
      obtain ⟨α, hα⟩ : ∃ α : Ordinal, ℵ_ α = κ := by
        have h_aleph : κ ∈ Set.range Cardinal.aleph := by
          aesop
        exact h_aleph
      aesop



theorem beth_zero : beth 0 = ℵ₀ := by
  exact?



theorem beth_one : beth 1 = 2 ^ ℵ₀ := by
  -- By definition of beth, we have ℶ 1 = 2^ℵ₀.
  simp [beth]



theorem beth_strictMono : StrictMono beth := by
  refine' fun α β h => _;
  cases' lt_or_eq_of_le ( show α ≤ β from le_of_lt h ) with h h <;> simp_all +decide [ beth ]



theorem beth_ge_aleph (α : Ordinal) : aleph α ≤ beth α := by
  exact?



theorem aleph0_add_self : ℵ₀ + ℵ₀ = ℵ₀ := by
  simp +zetaDelta at *



theorem aleph0_mul_self : ℵ₀ * ℵ₀ = ℵ₀ := by
  norm_num +zetaDelta at *



theorem infinite_add_self (κ : Cardinal) (hκ : ℵ₀ ≤ κ) : κ + κ = κ := by
  rw [ Cardinal.add_eq_max ] ; aesop_cat;
  assumption



theorem infinite_mul_self (κ : Cardinal) (hκ : ℵ₀ ≤ κ) : κ * κ = κ := by
  rw [ Cardinal.mul_eq_self ] ; aesop



theorem infinite_add_finite (κ : Cardinal) (hκ : ℵ₀ ≤ κ) (n : ℕ) :
    κ + n = κ := by
      rw [ Cardinal.add_eq_left ] ; aesop;
      exact le_trans ( Cardinal.nat_lt_aleph0 _ |> le_of_lt ) hκ



theorem omega_cof : Ordinal.cof ω = ℵ₀ := by
  aesop



theorem aleph0_regular : (aleph 0).ord.cof = aleph 0 := by
  rw [ eq_comm ] ; aesop;



theorem cantor_cardinal (κ : Cardinal) : κ < 2 ^ κ := by
  exact?



theorem continuum_uncountable : ℵ₀ < 2 ^ ℵ₀ := by
  exact?


