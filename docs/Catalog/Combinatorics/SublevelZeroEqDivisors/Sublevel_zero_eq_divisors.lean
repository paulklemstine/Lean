import Mathlib

/-! # CatalogBuild.Shared.Sublevel_zero_eq_divisors

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

The generated source used `sublevel_set` before defining it and referred to an
undefined defect function `E N x`, which the proofs identify with `N % x`.  Both
are supplied below, and the declarations are placed in a namespace so that they
cannot clash with `Shared.CatalogbuildSharedSublevel.Sublevel`.
-/

namespace SublevelZeroEqDivisors

/-- The defect function: the remainder of `N` on division by `x`. -/
def E (N x : ℕ) : ℕ := N % x

/-- Sublevel set: the set of x ∈ [1,N] with E(x) ≤ t. -/
def sublevel_set (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E N x ≤ t)

/-- At threshold `0` the sublevel set is exactly the set of divisors of `N`. -/
theorem sublevel_zero_eq_divisors (N : ℕ) (hN : 0 < N) :
    sublevel_set N 0 = N.divisors := by
  ext x
  simp [sublevel_set, E]
  exact ⟨fun h => ⟨Nat.dvd_of_mod_eq_zero h.2, hN.ne'⟩,
    fun h => ⟨⟨Nat.pos_of_dvd_of_pos h.1 hN, Nat.le_of_dvd hN h.1⟩,
      Nat.mod_eq_zero_of_dvd h.1⟩⟩

/-- Sublevel sets are monotone in the threshold. -/
theorem sublevel_monotone (N t₁ t₂ : ℕ) (h : t₁ ≤ t₂) :
    sublevel_set N t₁ ⊆ sublevel_set N t₂ :=
  fun x hx => Finset.mem_filter.mpr
    ⟨(Finset.mem_filter.mp hx).1, le_trans (Finset.mem_filter.mp hx).2 h⟩

end SublevelZeroEqDivisors