import Catalog.FINAL.Physics.ErdosStrausOneModEight

/-!
# Unified coverage engine

This file assembles the elementary families, the prime-core reduction and the
residual-class results into a single coverage statement, and records the updated
coverage map after the work on `n ≡ 1 (mod 8)`.

## Coverage map (by smallest prime factor `p` of `n`)

| residue of `p`            | status        | witness                                   |
| ------------------------- | ------------- | ----------------------------------------- |
| `p = 2`                   | solved        | `es_even`                                 |
| `p ≡ 3 (mod 4)`           | solved        | `es_three_mod_four` (Sierpiński)          |
| `p ≡ 5 (mod 8)`           | solved        | `es_five_mod_eight` (Komornik / halving)  |
| `p ≡ 1 (mod 8), 2 (mod 3)`| solved        | `es_two_mod_three` (this work)            |
| `p ≡ 1 (mod 8), p < 10⁴`  | solved        | `one_mod_eight_solver` (verified search)  |
| `p ≡ 1 (mod 8), 1 (mod 3), p ≥ 10⁴` | **open** | residual core of Erdős–Straus      |

The combined effect is recorded by:

* `es_prime_unified` — a prime is solvable unless it lies in the narrowed residual
  `p ≡ 1 (mod 8) ∧ p ≡ 1 (mod 3) ∧ p ≥ 10⁴`;
* `erdosStraus_lt_10000` — the Erdős–Straus conjecture holds for every `2 ≤ n < 10⁴`.

The residual class is **narrowed, not eliminated**: a closed form covering all
primes `p ≡ 1 (mod 8)` is not known (see `OneModEightConjecture`).
-/

namespace ErdosStraus

/-- **Unified prime engine.**  Every prime `p` is Erdős–Straus solvable, *provided*
the narrowed residual `p ≡ 1 (mod 8) ∧ p ≡ 1 (mod 3) ∧ 10⁴ ≤ p` is solvable.
All other primes are discharged by the four elementary families, the new
`es_two_mod_three` family, and the verified bounded solver `one_mod_eight_solver`. -/
theorem es_prime_unified (p : ℕ) (hp : p.Prime)
    (H : p % 8 = 1 → p % 3 = 1 → 10000 ≤ p → ErdosStrausSolution p) :
    ErdosStrausSolution p := by
  refine es_prime hp (fun h8 => ?_)
  -- now `p ≡ 1 (mod 8)`; split on `p mod 3`
  have h3cases : p % 3 = 0 ∨ p % 3 = 1 ∨ p % 3 = 2 := by omega
  rcases h3cases with h3 | h3 | h3
  · -- `3 ∣ p` forces `p = 3`, contradicting `p ≡ 1 (mod 8)`
    have : (3 : ℕ) ∣ p := Nat.dvd_of_mod_eq_zero h3
    have hp3 : p = 3 := ((Nat.prime_dvd_prime_iff_eq Nat.prime_three hp).mp this).symm
    omega
  · -- `p ≡ 1 (mod 3)`: either below the verified bound, or in the residual core
    by_cases hlt : p < 10000
    · exact one_mod_eight_solver p hp h8 hlt
    · exact H h8 h3 (by omega)
  · -- `p ≡ 2 (mod 3)`: the new infinite family settles it
    exact oneModEight_two_mod_three p hp h8 h3

/-- **Finite verification, extended to `10⁴`.**  The Erdős–Straus conjecture holds for
every `2 ≤ n < 10000`.  (Bumped from the previous bound of `1000` using the verified
residual-class solver `one_mod_eight_solver`.) -/
theorem erdosStraus_lt_10000 {n : ℕ} (hn : 2 ≤ n) (hN : n < 10000) :
    ErdosStrausSolution n :=
  erdosStraus_reduction_bounded 10000
    (fun p hp h8 hlt => one_mod_eight_solver p hp h8 hlt) hn hN

end ErdosStraus