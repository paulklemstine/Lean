/-
# The Knot–Number bridge, fifth cycle: the extraction pipeline is correct

The cycles I–IV showed that the irreducible factorization of the Alexander polynomial
`A_N` of `T(2,N)` has degree multiset `D_N = {φ(d) : d ∣ N, d > 1}`. This file closes the
loop by proving that the *stated extraction procedure works*, with no oracle beyond the
degree multiset:

* `totient_eq_max_factor_degree` : `φ(N)` is the maximum of `D_N` (and is attained,
  by the factor `Φ_{2N}`);
* `semiprime_extraction_pipeline` : for a semiprime `N = pq` (`p < q` odd primes),
  taking `m := max D_N`, `s := N + 1 - m`, the integers
  `(s ∓ √(s² − 4N))/2` are exactly `p` and `q`.

So the whole "read the factor degrees, output the primes" pipeline is verified; the
only obstruction is the size of `A_N` (`alexander_support_card`, cycle IV).
-/
import Bridges.AlexanderKnotNumberBridgeIV

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-- Among the degrees `φ(d)` of the irreducible factors `Φ_{2d}` of `A_N`, the largest is
`φ(N)`, attained by the top factor `Φ_{2N}`. -/
theorem totient_eq_max_factor_degree {N : ℕ} (h1 : 1 < N) :
    Nat.totient N ∈ (N.divisors.erase 1).val.map Nat.totient ∧
    ∀ x ∈ (N.divisors.erase 1).val.map Nat.totient, x ≤ Nat.totient N := by
  have hpos : 0 < N := by omega
  constructor
  · refine Multiset.mem_map.2 ⟨N, ?_, rfl⟩
    exact Finset.mem_erase.2 ⟨by omega, Nat.mem_divisors.2 ⟨dvd_rfl, hpos.ne'⟩⟩
  · intro x hx
    obtain ⟨d, hd, rfl⟩ := Multiset.mem_map.1 hx
    have hdvd : d ∣ N := (Nat.mem_divisors.1 (Finset.mem_erase.1 hd).2).1
    exact Nat.le_of_dvd (Nat.totient_pos.2 hpos) (Nat.totient_dvd_of_dvd hdvd)

/-- **The extraction pipeline is correct.** Let `N = pq` with `p < q` odd primes, let
`D` be the multiset of degrees of the irreducible factors of `A_N`, and let `m` be its
maximum. Then with `s = N + 1 - m`, the two integers `(s ∓ √(s²-4N))/2` are exactly
`p` and `q`. -/
theorem semiprime_extraction_pipeline {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q)
    (D : Multiset ℕ) (hD : D = ((p * q).divisors.erase 1).val.map Nat.totient)
    (m : ℕ) (hm : m ∈ D) (hmax : ∀ x ∈ D, x ≤ m) (s : ℕ) (hs : s = p * q + 1 - m) :
    (s - Nat.sqrt (s ^ 2 - 4 * (p * q))) / 2 = p ∧
    (s + Nat.sqrt (s ^ 2 - 4 * (p * q))) / 2 = q := by
  have h1 : 1 < p * q := by nlinarith [hp.one_lt, hq.one_lt]
  obtain ⟨hmem, hle⟩ := totient_eq_max_factor_degree (N := p * q) h1
  have hm1 : m ≤ Nat.totient (p * q) := by
    rw [hD] at hm
    exact hle m hm
  have hm2 : Nat.totient (p * q) ≤ m := hmax _ (by rw [hD]; exact hmem)
  have hmeq : m = Nat.totient (p * q) := le_antisymm hm1 hm2
  exact recover_factors_from_degrees hp hq hlt s (by rw [hs, hmeq])

end Bridges.AlexanderTorus