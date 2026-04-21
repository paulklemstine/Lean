/-! # CatalogBuild.Shared.Rsa_totient

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

import CatalogBuild.Speculative.OpenDirections
import Mathlib

/-- [Section: # CatalogBuild.Shared.Rsa_totient
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 1] -/
theorem rsa_totient (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    Nat.totient (p * q) = (p - 1) * (q - 1) := by
  have hcop : Nat.Coprime p q :=
    hp.coprime_iff_not_dvd.mpr fun h =>
      hpq (hq.eq_one_or_self_of_dvd p h |>.resolve_left hp.one_lt.ne')
  rw [Nat.totient_mul hcop, Nat.totient_prime hp, Nat.totient_prime hq]



