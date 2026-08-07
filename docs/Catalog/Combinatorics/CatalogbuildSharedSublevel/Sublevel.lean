import Mathlib

/-! # CatalogBuild.Shared.Sublevel

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5

The generated source referred to an undefined function `E N x`; from the way it
is used (`Nat.dvd_of_mod_eq_zero`, `Nat.mod_eq_zero_of_dvd`, and
`Nat.mod_lt`) it is the remainder `N % x`, which is restored below.  The
declarations are also placed in a namespace so that they cannot clash with the
identically named ones in `Shared.SublevelZeroEqDivisors.Sublevel_zero_eq_divisors`.
-/

namespace CatalogSublevel

/-- The defect function: the remainder of `N` on division by `x`.  It vanishes
exactly on the divisors of `N`. -/
def E (N x : ℕ) : ℕ := N % x

/-- Sublevel set: the elements of `[1, N]` whose defect is at most `t`. -/
def sublevel (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E N x ≤ t)

/-- Sublevel sets are monotone in the threshold. -/
theorem sublevel_mono (N s t : ℕ) (hst : s ≤ t) :
    sublevel N s ⊆ sublevel N t := by
  intro x hx
  simp only [sublevel, Finset.mem_filter] at hx ⊢
  exact ⟨hx.1, le_trans hx.2 hst⟩

/-- The sublevel set at threshold N-1 is all of [1, N]. -/
theorem sublevel_full (N : ℕ) (hN : 0 < N) :
    sublevel N (N - 1) = Finset.Icc 1 N := by
  ext x
  simp only [sublevel, Finset.mem_filter, Finset.mem_Icc, E]
  constructor
  · rintro ⟨hx, _⟩; exact hx
  · intro hx
    refine ⟨hx, ?_⟩
    have : N % x < x := Nat.mod_lt N (by omega)
    have : x ≤ N := hx.2
    omega

/-- Card of sublevel at 0 equals number of divisors. -/
theorem sublevel_zero_card_eq_tau (N : ℕ) (hN : 0 < N) :
    (sublevel N 0).card = N.divisors.card := by
  congr 1; ext x
  simp only [sublevel, Finset.mem_filter, Finset.mem_Icc, Nat.mem_divisors, E, Nat.le_zero]
  constructor
  · rintro ⟨⟨hx1, hx2⟩, hmod⟩
    exact ⟨Nat.dvd_of_mod_eq_zero hmod, hN.ne'⟩
  · rintro ⟨hdvd, _⟩
    exact ⟨⟨Nat.pos_of_dvd_of_pos hdvd hN, Nat.le_of_dvd hN hdvd⟩, Nat.mod_eq_zero_of_dvd hdvd⟩

/-- The sublevel set at threshold 0 is exactly the set of divisors of N in [1,N]. -/
theorem sublevel_zero_is_divisors (N : ℕ) (hN : 0 < N) :
    sublevel N 0 = (Finset.Icc 1 N).filter (fun x => x ∣ N) := by
  ext x
  simp only [sublevel, Finset.mem_filter, Finset.mem_Icc, E, Nat.le_zero]
  constructor
  · rintro ⟨hx, hmod⟩
    exact ⟨hx, Nat.dvd_of_mod_eq_zero hmod⟩
  · rintro ⟨hx, hdvd⟩
    exact ⟨hx, Nat.mod_eq_zero_of_dvd hdvd⟩

end CatalogSublevel