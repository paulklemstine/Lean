import Mathlib

/-!
# Stratum A: the definition-routes to factoring (`τ`, `σ₁` and the trial-division scan)

This file is the arithmetic stratum of the *three-strata plane* for semiprime
factoring.  A **definition-route** is a witness that is read off from `N` alone
by evaluating an arithmetic function (here the divisor count `τ` and the divisor
sum `σ₁`), as opposed to a *method* that exploits the multiplicative structure
of `N` (Stratum B) or a quantum subroutine (Stratum C).

Main results.

* `sigmaOne_semiprime` : `σ₁(pq) = 1 + p + q + pq` exactly, for distinct primes;
* `numDivisors_semiprime` : `τ(pq) = 4`;
* `sum_of_factors_eq` : the `σ₁`-oracle hands over `p + q` in one subtraction;
* `vieta_pair_unique` / `semiprime_pair_unique` : `(p+q, pq)` determines the
  ordered pair `(p,q)` — the Vieta step behind the route;
* `recoverSmallerFactor_eq` : an explicit **closed formula** recovering `p` from
  `N` and `σ₁(N)`, i.e. the `σ₁`-route factors in `O(1)` arithmetic operations
  after the oracle call;
* `divisors_le_sqrt`, `scanCost_eq_smaller_factor_bound`,
  `twinPrime_scanCost_eq_sqrt` : evaluating `τ` or `σ₁` from `N` alone by trial
  division costs `⌊√N⌋` divisions, and that bound is attained — the discrete
  form of the measured exponent `α = 1/2`;
* `scan_exponent_half_sandwich` : `2·log(scanCost N) ≤ log N ≤ 2·log(scanCost N + 1)`,
  the honest two-sided statement of "`α = 0.500`".

Everything here is unconditional; no hypothesis about the difficulty of
factoring is used or needed.
-/

namespace ThreeStrata

open Finset

/-! ## The two definition-route witnesses -/

/-- The divisor sum `σ₁(n) = ∑_{d ∣ n} d`. -/
def sigmaOne (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

/-- The divisor count `τ(n)`. -/
def numDivisors (n : ℕ) : ℕ := n.divisors.card

/-- The cost (number of trial divisions) of evaluating `τ` or `σ₁` at `n`
by the structure-blind scan `d = 1, …, ⌊√n⌋`. -/
def scanCost (n : ℕ) : ℕ := Nat.sqrt n

/-! ## The divisor set of a semiprime -/

/-- The divisors of a product of two distinct primes. -/
theorem divisors_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    (p * q).divisors = {1, p, q, p * q} := by
  rw [Nat.divisors_mul, hp.divisors, hq.divisors]
  ext d
  simp [Finset.mem_mul, eq_comm]
  tauto

/-- `σ₁(pq) = 1 + p + q + pq` — exact at every size. -/
theorem sigmaOne_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    sigmaOne (p * q) = 1 + p + q + p * q := by
  have h : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have hs : ∀ r : ℕ, r.Prime → ∑ d ∈ r.divisors, d = 1 + r := fun r hr => by
    rw [hr.divisors, Finset.sum_pair hr.one_lt.ne]
  unfold sigmaOne
  rw [Nat.Coprime.sum_divisors_mul h, hs p hp, hs q hq]
  ring

/-- `τ(pq) = 4`. -/
theorem numDivisors_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    numDivisors (p * q) = 4 := by
  have h : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  unfold numDivisors
  rw [Nat.Coprime.card_divisors_mul h, hp.divisors, hq.divisors,
    Finset.card_pair hp.one_lt.ne, Finset.card_pair hq.one_lt.ne]

/-- The `σ₁`-oracle hands over the sum of the prime factors. -/
theorem sum_of_factors_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    sigmaOne (p * q) - (p * q) - 1 = p + q := by
  rw [sigmaOne_semiprime hp hq hpq]; omega

/-! ## Vieta: the pair `(sum, product)` pins the factors down -/

/-- Over `ℤ`: an ordered pair is determined by its sum and product. -/
theorem vieta_pair_unique {a b c d : ℤ} (hs : a + b = c + d) (hm : a * b = c * d)
    (hab : a ≤ b) (hcd : c ≤ d) : a = c ∧ b = d := by
  have hsq : (b - a) ^ 2 = (d - c) ^ 2 := by
    have e1 : (b - a) ^ 2 = (a + b) ^ 2 - 4 * (a * b) := by ring
    have e2 : (d - c) ^ 2 = (c + d) ^ 2 - 4 * (c * d) := by ring
    rw [e1, e2, hs, hm]
  have hx : (0 : ℤ) ≤ b - a := by linarith
  have hy : (0 : ℤ) ≤ d - c := by linarith
  have : b - a = d - c := by nlinarith
  exact ⟨by linarith, by linarith⟩

/-- Over `ℕ`: same statement, the form used by the `σ₁`-route. -/
theorem semiprime_pair_unique {a b c d : ℕ} (hs : a + b = c + d) (hm : a * b = c * d)
    (hab : a ≤ b) (hcd : c ≤ d) : a = c ∧ b = d := by
  have hs' : (a : ℤ) + b = (c : ℤ) + d := by exact_mod_cast hs
  have hm' : (a : ℤ) * b = (c : ℤ) * d := by exact_mod_cast hm
  obtain ⟨h1, h2⟩ := vieta_pair_unique hs' hm' (by exact_mod_cast hab) (by exact_mod_cast hcd)
  exact ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩

/-! ## The closed formula: `σ₁` plus `O(1)` arithmetic factors `N` -/

/-- The smaller factor of `N`, recovered from `N` and the factor sum `s`
by the quadratic formula: `p = (s - √(s² - 4N))/2`. -/
def recoverSmallerFactor (N s : ℕ) : ℕ := (s - Nat.sqrt (s * s - 4 * N)) / 2

/-- The discriminant of the Vieta quadratic is a perfect square: `(p+q)² - 4pq = (q-p)²`. -/
theorem discriminant_eq {p q : ℕ} (h : p ≤ q) :
    (p + q) * (p + q) - 4 * (p * q) = (q - p) * (q - p) := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  have hk : p + (p + k) = 2 * p + k := by ring
  simp only [hk, Nat.add_sub_cancel_left]
  ring_nf
  omega

/-- **The `σ₁`-route in closed form.**  Given `N = pq` and the oracle value
`σ₁(N)`, the smaller prime factor is produced by one square root and one
division — no search. -/
theorem recoverSmallerFactor_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q) :
    recoverSmallerFactor (p * q) (sigmaOne (p * q) - p * q - 1) = p := by
  rw [sum_of_factors_eq hp hq hpq.ne]
  unfold recoverSmallerFactor
  rw [discriminant_eq hpq.le, Nat.sqrt_eq]
  omega

/-! ## The trial-division scan: cost `⌊√N⌋`, and the bound is attained -/

/-- The smaller prime factor is found at or before step `⌊√N⌋`. -/
theorem smaller_factor_le_sqrt {p q : ℕ} (h : p ≤ q) : p ≤ Nat.sqrt (p * q) :=
  Nat.le_sqrt.2 (Nat.mul_le_mul_left p h)

/-- The larger prime factor is never reached by a scan up to `⌊√N⌋`. -/
theorem sqrt_lt_larger_factor {p q : ℕ} (hp : 0 < p) (h : p < q) : Nat.sqrt (p * q) < q :=
  Nat.sqrt_lt'.2 (by nlinarith)

/-- **The scan window sees exactly half the divisors.**  For `N = pq` with
`p < q` primes, the divisors of `N` that lie in the scan window `[1, ⌊√N⌋]` are
exactly `{1, p}` — so the structure-blind evaluation of `τ(N)` or `σ₁(N)` both
terminates with, and certifies, the factorization. -/
theorem divisors_le_sqrt {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q) :
    (p * q).divisors.filter (· ≤ Nat.sqrt (p * q)) = {1, p} := by
  have hp1 : 1 < p := hp.one_lt
  have hple : p ≤ Nat.sqrt (p * q) := smaller_factor_le_sqrt hpq.le
  have hqgt : Nat.sqrt (p * q) < q := sqrt_lt_larger_factor hp.pos hpq
  have hNgt : Nat.sqrt (p * q) < p * q := lt_of_lt_of_le hqgt (Nat.le_mul_of_pos_left q hp.pos)
  ext d
  simp only [Finset.mem_filter, divisors_semiprime hp hq, Finset.mem_insert,
    Finset.mem_singleton]
  constructor
  · rintro ⟨rfl | rfl | rfl | rfl, hd⟩
    · exact Or.inl rfl
    · exact Or.inr rfl
    · omega
    · omega
  · rintro (rfl | rfl)
    · exact ⟨Or.inl rfl, by omega⟩
    · exact ⟨Or.inr (Or.inl rfl), hple⟩

/-- For a twin-prime semiprime the scan cost is *exactly* `⌊√N⌋`: the worst case
of the definition-route is attained, so the exponent `1/2` is sharp and not just
an upper bound. -/
theorem twinPrime_scanCost_eq_sqrt {p : ℕ} (hp : 1 < p) : scanCost (p * (p + 2)) = p := by
  unfold scanCost
  have h1 : p ≤ Nat.sqrt (p * (p + 2)) := Nat.le_sqrt.2 (by nlinarith)
  have h2 : Nat.sqrt (p * (p + 2)) < p + 1 := Nat.sqrt_lt'.2 (by nlinarith)
  omega

/-- The scan finds the smaller factor at step `p ≤ ⌊√N⌋`, i.e. `scanCost` is an
upper bound for the trial-division work on a semiprime. -/
theorem scanCost_eq_smaller_factor_bound {p q : ℕ} (h : p ≤ q) : p ≤ scanCost (p * q) :=
  smaller_factor_le_sqrt h

/-! ## The measured exponent `α = 1/2`, in honest two-sided form -/

/-- **`α = 0.500` as a sandwich.**  For every `N ≥ 1`,
`2 log(scanCost N) ≤ log N ≤ 2 log(scanCost N + 1)`; both sides are within
`O(1/√N)` of each other, so `log(scanCost N)/log N → 1/2`. -/
theorem scan_exponent_half_sandwich (N : ℕ) (hN : 1 ≤ N) :
    2 * Real.log (scanCost N) ≤ Real.log N ∧
      Real.log N ≤ 2 * Real.log (scanCost N + 1) := by
  have hsq : (Nat.sqrt N) ^ 2 ≤ N := Nat.sqrt_le' N
  have hsq' : N < (Nat.sqrt N + 1) ^ 2 := Nat.lt_succ_sqrt' N
  have h1 : (0 : ℝ) < (Nat.sqrt N : ℝ) := by
    have : 0 < Nat.sqrt N := Nat.sqrt_pos.2 hN
    exact_mod_cast this
  constructor
  · have hle : ((Nat.sqrt N : ℝ)) ^ 2 ≤ (N : ℝ) := by exact_mod_cast hsq
    calc 2 * Real.log (scanCost N) = Real.log ((Nat.sqrt N : ℝ) ^ 2) := by
          rw [Real.log_pow]; simp [scanCost]
      _ ≤ Real.log N := Real.log_le_log (by positivity) hle
  · have h2 : (N : ℝ) ≤ ((Nat.sqrt N : ℝ) + 1) ^ 2 := by
      have : (N : ℝ) < ((Nat.sqrt N : ℝ) + 1) ^ 2 := by exact_mod_cast hsq'
      linarith
    calc Real.log N ≤ Real.log (((Nat.sqrt N : ℝ) + 1) ^ 2) :=
          Real.log_le_log (by exact_mod_cast hN) h2
      _ = 2 * Real.log (scanCost N + 1) := by
          rw [Real.log_pow]; simp [scanCost]

end ThreeStrata