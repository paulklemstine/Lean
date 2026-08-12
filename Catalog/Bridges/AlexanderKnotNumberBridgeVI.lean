/-
# The knot–number bridge VI: the local–global factorization of the knot determinant

Cycle II of this thread computed the "local determinants" `Φ_{2d}(-1)` in two special
cases (`d` prime and `d` a product of two distinct primes) by dividing the global
determinant `A_N(-1) = N` by the other factors.  This file proves the *general* local–global
statement conjectured as `C2` in `FUTURE_DIRECTIONS.md`:

* `Bridges.AlexanderTorus.cyclotomic_two_mul_eval_neg_one` :
  for odd `n > 0`, `Φ_{2n}(-1) = Φ_n(1)`.  This is proved by strong induction from the two
  divisor-product identities
  `∏_{d ∣ n, d > 1} Φ_{2d} = A_n` (the knot side, cycle I) and
  `∏_{d ∣ n, d > 1} Φ_d = 1 + X + ⋯ + X^{n-1}` (the classical side),
  evaluated at `-1` and `1` respectively — both give `n`.
* `Bridges.AlexanderTorus.cyclotomic_two_mul_prime_pow_eval_neg_one` :
  `Φ_{2p^{k+1}}(-1) = p` for an odd prime `p`.
* `Bridges.AlexanderTorus.cyclotomic_two_mul_eval_neg_one_of_not_isPrimePow` :
  `Φ_{2d}(-1) = 1` if `d > 1` is odd and not a prime power.
* `Bridges.AlexanderTorus.knot_determinant_local_global` :
  `∏_{d ∣ N, d > 1} Φ_{2d}(-1) = N`, i.e. the determinant of `T(2,N)` is the product of the
  local determinants; combined with the two previous results, the only divisors contributing
  a nontrivial local determinant are the prime powers `p^j ∣ N`, each contributing `p`.
-/
import Bridges.AlexanderKnotNumberBridge

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-! ## The two divisor-product identities, evaluated -/

/-- **Local–global determinant formula.** For odd `N > 0` the determinant `N` of the torus
knot `T(2,N)` is the product of the local determinants `Φ_{2d}(-1)` over the divisors
`d > 1` of `N`. -/
theorem knot_determinant_local_global {N : ℕ} (hN : Odd N) (hpos : 0 < N) :
    ∏ d ∈ N.divisors.erase 1, (cyclotomic (2 * d) ℤ).eval (-1) = (N : ℤ) := by
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.2 hpos.ne') with h1 | h1
  · simp [← h1]
  · have h := congrArg (Polynomial.eval (-1 : ℤ)) (alexander_eq_prod_cyclotomic hN h1)
    rw [eval_prod, knot_determinant] at h
    exact h.symm

/-- The classical companion identity: `∏_{d ∣ N, d > 1} Φ_d(1) = N`. -/
theorem prod_eval_one_cyclotomic_erase_one {N : ℕ} (hpos : 0 < N) :
    ∏ d ∈ N.divisors.erase 1, (cyclotomic d ℤ).eval 1 = (N : ℤ) := by
  have h := congrArg (Polynomial.eval (1 : ℤ)) (prod_cyclotomic_eq_geom_sum hpos ℤ)
  rw [eval_prod] at h
  simpa using h

/-! ## `Φ_{2n}(-1) = Φ_n(1)` for odd `n` -/

/-- **The local bridge.** For odd `n > 0`, evaluating the `2n`-th cyclotomic polynomial at
`-1` gives the same value as evaluating the `n`-th one at `1`.

The proof is a strong induction: both sides satisfy the *same* multiplicative recursion over
the divisor lattice of `n`, one coming from the knot side (`A_n(-1) = n`) and one from the
classical geometric-sum identity. -/
theorem cyclotomic_two_mul_eval_neg_one :
    ∀ n : ℕ, Odd n → 0 < n →
      (cyclotomic (2 * n) ℤ).eval (-1) = (cyclotomic n ℤ).eval 1 := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn hpos
    rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.2 hpos.ne') with h1 | h1
    · subst h1
      simp [cyclotomic_one]
    · have hmem : n ∈ n.divisors.erase 1 :=
        Finset.mem_erase.2 ⟨by omega, Nat.mem_divisors_self n hpos.ne'⟩
      have hu := knot_determinant_local_global hn hpos
      have hv := prod_eval_one_cyclotomic_erase_one (N := n) hpos
      rw [← Finset.mul_prod_erase _ _ hmem] at hu hv
      have hEq : ∏ d ∈ (n.divisors.erase 1).erase n, (cyclotomic (2 * d) ℤ).eval (-1)
          = ∏ d ∈ (n.divisors.erase 1).erase n, (cyclotomic d ℤ).eval 1 := by
        refine Finset.prod_congr rfl ?_
        intro d hd
        rw [Finset.mem_erase, Finset.mem_erase, Nat.mem_divisors] at hd
        obtain ⟨hdn, -, hdvd, -⟩ := hd
        have hdlt : d < n := lt_of_le_of_ne (Nat.le_of_dvd hpos hdvd) hdn
        exact ih d hdlt (odd_of_dvd_odd hn hdvd) (Nat.pos_of_dvd_of_pos hdvd hpos)
      rw [hEq] at hu
      have hPne : (∏ d ∈ (n.divisors.erase 1).erase n, (cyclotomic d ℤ).eval 1) ≠ 0 := by
        intro h
        rw [h, mul_zero] at hu
        exact hpos.ne' (by exact_mod_cast hu.symm)
      exact mul_right_cancel₀ hPne (hu.trans hv.symm)

/-! ## The local determinants -/

/-- The local determinant at a prime power: `Φ_{2p^{k+1}}(-1) = p` for an odd prime `p`. -/
theorem cyclotomic_two_mul_prime_pow_eval_neg_one {p : ℕ} (hp : p.Prime) (hpo : Odd p) (k : ℕ) :
    (cyclotomic (2 * p ^ (k + 1)) ℤ).eval (-1) = (p : ℤ) := by
  haveI : Fact p.Prime := ⟨hp⟩
  rw [cyclotomic_two_mul_eval_neg_one (p ^ (k + 1)) (hpo.pow) (pow_pos hp.pos _)]
  exact eval_one_cyclotomic_prime_pow (R := ℤ) k

/-- The local determinant is trivial away from prime powers: `Φ_{2d}(-1) = 1` for odd `d > 1`
which is not a prime power. -/
theorem cyclotomic_two_mul_eval_neg_one_of_not_isPrimePow {d : ℕ} (hd : Odd d) (h1 : 1 < d)
    (hpp : ¬ IsPrimePow d) : (cyclotomic (2 * d) ℤ).eval (-1) = 1 := by
  rw [cyclotomic_two_mul_eval_neg_one d hd (by omega)]
  refine eval_one_cyclotomic_not_prime_pow ?_
  intro p hp k hk
  have hkpos : 0 < k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk'
    · simp at hk; omega
    · exact hk'
  exact hpp ⟨p, k, hp.prime, hkpos, hk⟩

/-! ## Consequences: the cycle II computations, generalized -/

/-- The prime case (`k = 0`), recovering `cyclotomic_two_mul_prime_eval_neg_one` of cycle II. -/
theorem cyclotomic_two_mul_prime_eval_neg_one' {p : ℕ} (hp : p.Prime) (hpo : Odd p) :
    (cyclotomic (2 * p) ℤ).eval (-1) = (p : ℤ) := by
  simpa using cyclotomic_two_mul_prime_pow_eval_neg_one hp hpo 0

/-- The semiprime case, recovering `cyclotomic_two_mul_semiprime_eval_neg_one` of cycle II
and extending it to *all* products of two distinct odd primes. -/
theorem cyclotomic_two_mul_semiprime_eval_neg_one' {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpo : Odd p) (hqo : Odd q) (hne : p ≠ q) :
    (cyclotomic (2 * (p * q)) ℤ).eval (-1) = 1 := by
  have h1 : 1 < p * q := by nlinarith [hp.one_lt, hq.one_lt]
  refine cyclotomic_two_mul_eval_neg_one_of_not_isPrimePow (hpo.mul hqo) h1 ?_
  rintro ⟨r, k, hr, hk, hrk⟩
  have hpq0 : p * q ≠ 0 := by positivity
  have hfac : (p * q).primeFactors = {r} := by
    rw [← hrk, Nat.primeFactors_pow _ hk.ne', hr.nat_prime.primeFactors]
  have hpm : p ∈ (p * q).primeFactors :=
    Nat.mem_primeFactors.2 ⟨hp, dvd_mul_right p q, hpq0⟩
  have hqm : q ∈ (p * q).primeFactors :=
    Nat.mem_primeFactors.2 ⟨hq, dvd_mul_left q p, hpq0⟩
  rw [hfac, Finset.mem_singleton] at hpm hqm
  exact hne (hpm.trans hqm.symm)

end Bridges.AlexanderTorus