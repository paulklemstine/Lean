import Mathlib

/-! # The remainder observable `E`

`E N x = N % x` is the observable whose sublevel sets `{x ∈ [1,N] | E N x ≤ t}`
interpolate between the divisors of `N` (threshold `0`) and the whole interval
`[1, N]` (threshold `N - 1`).  The auto-generated catalog files
`Shared.CatalogbuildSharedSublevel.Sublevel`,
`Shared.CatalogbuildSharedSublevelFull.Sublevel_full` and
`Shared.SublevelZeroEqDivisors.Sublevel_zero_eq_divisors` use it without stating
it; this module supplies the definition.
-/

/-- The remainder observable: `E N x = N % x`. -/
def E (N x : ℕ) : ℕ := N % x

/-- `E N x = 0` exactly when `x` divides `N`. -/
theorem E_eq_zero_iff (N x : ℕ) : E N x = 0 ↔ x ∣ N := by
  unfold E
  exact Nat.dvd_iff_mod_eq_zero.symm