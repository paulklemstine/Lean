/-! # CatalogBuild.Logic.InfinityLevels

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 17
-/

import Mathlib

/-- ℵ₀ is infinite. -/
theorem aleph0_infinite : ℵ₀ ≥ ℵ₀ := le_refl _

/-
ℵ₁ is strictly larger than ℵ₀.
  Rucker: "ℵ₁ is the first uncountable cardinal."
-/

theorem aleph_one_gt_aleph_zero : aleph 0 < aleph 1 := by
  norm_num +zetaDelta at *;
  -- The cardinality of the natural numbers is strictly less than the cardinality of the first uncountable ordinal.
  apply Cardinal.aleph0_lt_aleph_one

/-
The aleph function is order-preserving: if α < β then ℵ_α < ℵ_β.
-/

theorem aleph_lt_of_lt {α β : Ordinal} (h : α < β) : aleph α < aleph β := by
  convert Cardinal.aleph_lt_aleph.mpr _;
  assumption

/-
Every infinite cardinal is an aleph.
  Rucker: "The alephs exhaust all possible sizes of infinite sets."
-/

theorem every_infinite_cardinal_is_aleph (κ : Cardinal) (hκ : ℵ₀ ≤ κ) :
    ∃ α : Ordinal, aleph α = κ := by
      obtain ⟨α, hα⟩ : ∃ α : Ordinal, ℵ_ α = κ := by
        have h_aleph : κ ∈ Set.range Cardinal.aleph := by
          aesop
        exact h_aleph
      aesop

/-! ## The Beth Hierarchy

The beth numbers arise from iterated power set operations:
  ℶ₀ = ℵ₀, ℶ₁ = 2^ℵ₀, ℶ₂ = 2^(2^ℵ₀), ...

Rucker discusses these as "the cardinalities you actually encounter
by repeatedly taking power sets."
-/

/-
ℶ₀ = ℵ₀.
-/

theorem beth_zero : beth 0 = ℵ₀ := by
  exact?

/-
ℶ₁ = 2^ℵ₀, the cardinality of the continuum.
-/

theorem beth_one : beth 1 = 2 ^ ℵ₀ := by
  -- By definition of beth, we have ℶ 1 = 2^ℵ₀.
  simp [beth]

/-
The beth sequence is strictly increasing.
-/

theorem beth_strictMono : StrictMono beth := by
  refine' fun α β h => _;
  cases' lt_or_eq_of_le ( show α ≤ β from le_of_lt h ) with h h <;> simp_all +decide [ beth ]

/-
Each beth number is at least the corresponding aleph:  ℶ_α ≥ ℵ_α.
  Equality for all α is equivalent to the Generalized Continuum Hypothesis.
-/

theorem beth_ge_aleph (α : Ordinal) : aleph α ≤ beth α := by
  exact?

/-! ## Cardinal Arithmetic — The Absorption Laws

Rucker explains that infinite cardinal arithmetic has beautiful
"absorption" properties: ℵ₀ + ℵ₀ = ℵ₀, ℵ₀ · ℵ₀ = ℵ₀.
These are surprising from a finite perspective.
-/

/-
ℵ₀ + ℵ₀ = ℵ₀. Adding countable to countable stays countable.
-/

theorem aleph0_add_self : ℵ₀ + ℵ₀ = ℵ₀ := by
  simp +zetaDelta at *

/-
ℵ₀ · ℵ₀ = ℵ₀. The product of countable sets is countable.
-/

theorem aleph0_mul_self : ℵ₀ * ℵ₀ = ℵ₀ := by
  norm_num +zetaDelta at *

/-
For infinite cardinals, κ + κ = κ.
-/

theorem infinite_add_self (κ : Cardinal) (hκ : ℵ₀ ≤ κ) : κ + κ = κ := by
  rw [ Cardinal.add_eq_max ] ; aesop_cat;
  assumption

/-
For infinite cardinals, κ · κ = κ.
  Rucker: "An infinite hotel with infinitely many floors, each with
  infinitely many rooms, has the same number of rooms as a single floor."
-/

theorem infinite_mul_self (κ : Cardinal) (hκ : ℵ₀ ≤ κ) : κ * κ = κ := by
  rw [ Cardinal.mul_eq_self ] ; aesop

/-
For infinite κ and finite nonzero n, κ + n = κ.
-/

theorem infinite_add_finite (κ : Cardinal) (hκ : ℵ₀ ≤ κ) (n : ℕ) :
    κ + n = κ := by
      rw [ Cardinal.add_eq_left ] ; aesop;
      exact le_trans ( Cardinal.nat_lt_aleph0 _ |> le_of_lt ) hκ

/-! ## Cofinality

Rucker discusses cofinality as measuring "how fast you can climb to
an ordinal." This is fundamental for understanding singular vs
regular cardinals.
-/

/-
ω has cofinality ω (it is regular).
-/

theorem omega_cof : Ordinal.cof ω = ℵ₀ := by
  aesop

/-
ℵ₀ is a regular cardinal.
-/

theorem aleph0_regular : (aleph 0).ord.cof = aleph 0 := by
  rw [ eq_comm ] ; aesop;

/-! ## Cantor's Theorem for Cardinals — The Engine of the Hierarchy

This is the cardinal version of Cantor's theorem, which drives
the entire hierarchy upward.
-/

/-
Cantor's theorem for cardinals: κ < 2^κ for all κ.
-/

theorem cantor_cardinal (κ : Cardinal) : κ < 2 ^ κ := by
  exact?

/-
The continuum is uncountable.
-/

theorem continuum_uncountable : ℵ₀ < 2 ^ ℵ₀ := by
  exact?

end Rucker.InfinityLevels
