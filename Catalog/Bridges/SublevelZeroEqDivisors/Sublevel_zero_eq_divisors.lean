import Mathlib

/-! # CatalogBuild.Shared.Sublevel_zero_eq_divisors

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

As delivered, this file used two names that were never defined — the error function `E`
and `sublevel_set`, the latter also being used before its definition — so it did not
elaborate.  Both are supplied below, in the only reading consistent with the statements
that use them: `E N x` is the remainder of `N` on division by `x`, so that the sublevel
set at level `0` is exactly the set of divisors of `N`.  The declarations are also put in
dependency order.
-/

/-- The division error of `x` against `N`: the remainder `N % x`.  It vanishes exactly
when `x` divides `N`. -/
def E (N x : ℕ) : ℕ := N % x

/-- Sublevel set: the set of `x ∈ [1,N]` with `E N x ≤ t`. -/
def sublevel_set (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E N x ≤ t)

/-- [Section: # CatalogBuild.Shared.Sublevel_zero_eq_divisors
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3] -/
theorem sublevel_zero_eq_divisors (N : ℕ) (hN : 0 < N) :
    sublevel_set N 0 = N.divisors := by
  ext x
  simp only [sublevel_set, E, Finset.mem_filter, Finset.mem_Icc, Nat.le_zero,
    Nat.mem_divisors]
  constructor
  · rintro ⟨-, h3⟩
    exact ⟨Nat.dvd_of_mod_eq_zero h3, hN.ne'⟩
  · rintro ⟨hd, -⟩
    exact ⟨⟨Nat.pos_of_dvd_of_pos hd hN, Nat.le_of_dvd hN hd⟩, Nat.mod_eq_zero_of_dvd hd⟩

/-- [Section: # CatalogBuild.Shared.Sublevel_zero_eq_divisors
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3] -/
theorem sublevel_monotone (N t₁ t₂ : ℕ) (h : t₁ ≤ t₂) :
    sublevel_set N t₁ ⊆ sublevel_set N t₂ :=
  fun x hx => Finset.mem_filter.mpr
    ⟨(Finset.mem_filter.mp hx).1, le_trans (Finset.mem_filter.mp hx).2 h⟩