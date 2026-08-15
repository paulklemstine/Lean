import Cryptography.MordellDenominators.Counterexample
import Cryptography.MordellDenominators.Family

/-!
# What a denominator `gcd` actually extracts

The cryptographic motivation for studying these denominators is the hope that
`gcd(den x(nP), N)` reveals a factor of `N` — the elliptic-curve analogue of the
collision `gcd` studied in `Cryptography/FactoringBarriers/RandomnessBarrier.lean`.
The results proved here say that on the very examples where the denominators are
richest, this `gcd` returns nothing:

* `MordellDenominators.gcd_den_eq_one_of_no_prime_factor` — the general
  criterion: if no prime factor of `N` divides the denominator, the `gcd` is `1`;
* `MordellDenominators.N55.gcd_den_eq_one` — for `N = 55` and `P = (9,28)` the
  denominator `3136` is coprime to `N`, even though it contains the good prime
  `7` with multiplicity two;
* `MordellDenominators.Family.gcd_den_prime_eq_two` — for the infinite family
  `N = ℓ² - 1` the only prime the `gcd` can ever return at the first doubling is
  the trivial prime `2`.

So the denominators do broadcast a prime — just never one of the primes one is
looking for.
-/

namespace MordellDenominators

/-- If no prime factor of `M` divides `d`, then `gcd d M = 1`. -/
theorem gcd_den_eq_one_of_no_prime_factor {d M : ℕ}
    (h : ∀ r : ℕ, r.Prime → r ∣ M → ¬ r ∣ d) : Nat.gcd d M = 1 := by
  by_contra hne
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd hne
  exact h r hr (hrd.trans (Nat.gcd_dvd_right d M)) (hrd.trans (Nat.gcd_dvd_left d M))

namespace N55

/-- For `E₅₅` and `P = (9, 28)` the `gcd` of the denominator of `x(2P)` with
`N = 55` is `1`: the denominator is rich (`2⁶ · 7²`) but arithmetically
orthogonal to the factorisation of `N`. -/
theorem gcd_den_eq_one : Nat.gcd (dblX 55 9).den 55 = 1 := by
  rw [den_dblX]
  norm_num

end N55

namespace Family

variable {l : ℕ}

/-- For the family `N = ℓ² - 1` the only prime that `gcd(den x(2P), N)` can
contain is `2`; no odd factor of `N` is ever exposed at the first doubling. -/
theorem gcd_den_prime_eq_two (hl : l.Prime) (h5 : 5 ≤ l) {r : ℕ} (hr : r.Prime)
    (hrg : r ∣ Nat.gcd (dblX (NN l) 1).den (NN l).natAbs) : r = 2 := by
  by_contra hr2
  have hrd : r ∣ (dblX (NN l) 1).den := hrg.trans (Nat.gcd_dvd_left _ _)
  have hrN : r ∣ (NN l).natAbs := hrg.trans (Nat.gcd_dvd_right _ _)
  exact odd_prime_factor_not_dvd_den hl h5 hr hr2 (Int.ofNat_dvd_left.mpr hrN) hrd

end Family
end MordellDenominators