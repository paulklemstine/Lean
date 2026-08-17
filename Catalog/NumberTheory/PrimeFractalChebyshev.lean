import Mathlib

/-!
# A Chebyshev-type lower bound for the prime counting function

This file proves an explicit elementary (Chebyshev-style) lower bound

  `n ≤ 8 * π n * log n`   for `n ≥ 8`,

where `π = Nat.primeCounting`.  Mathlib contains Chebyshev's *upper* bound
(`Chebyshev.eventually_primeCounting_le`); here we derive a lower bound from the
central binomial coefficient, following the classical argument

  `4 ^ n < n * centralBinom n ≤ n * (2n) ^ π (2n)`.

The bound is used in `NumberTheory.PrimeFractalBoxDimension` to show that the
box-counting dimension of the "prime fractal" is exactly `1`.
-/

namespace PrimeFractal

open Finset

/-- The central binomial coefficient is a product of prime powers, each at most `2n`,
and there are `π (2n)` primes involved; hence `centralBinom n ≤ (2n) ^ π (2n)`. -/
theorem centralBinom_le_pow_primeCounting (n : ℕ) (hn : 0 < n) :
    n.centralBinom ≤ (2 * n) ^ (Nat.primeCounting (2 * n)) := by
  have hsub : Nat.primesBelow (2 * n + 1) ⊆ Finset.range (2 * n + 1) := by
    intro p hp
    exact Finset.mem_range.mpr (Nat.lt_of_mem_primesBelow hp)
  have hprod : ∏ p ∈ Nat.primesBelow (2 * n + 1), p ^ (n.centralBinom.factorization p)
      = n.centralBinom := by
    have hstep : ∏ p ∈ Nat.primesBelow (2 * n + 1), p ^ (n.centralBinom.factorization p)
        = ∏ p ∈ Finset.range (2 * n + 1), p ^ (n.centralBinom.factorization p) := by
      refine Finset.prod_subset (f := fun p => p ^ (n.centralBinom.factorization p)) hsub ?_
      intro p hp hnp
      have hnotprime : ¬ Nat.Prime p := by
        intro hpp
        exact hnp (Nat.mem_primesBelow.mpr ⟨Finset.mem_range.mp hp, hpp⟩)
      show p ^ (n.centralBinom.factorization p) = 1
      rw [Nat.factorization_eq_zero_of_not_prime _ hnotprime, pow_zero]
    rw [hstep, Nat.prod_pow_factorization_centralBinom n]
  have hcard : (Nat.primesBelow (2 * n + 1)).card = Nat.primeCounting (2 * n) := by
    rw [Nat.primesBelow_card_eq_primeCounting']
    simpa using (Nat.primeCounting_sub_one (2 * n + 1)).symm
  calc n.centralBinom
      = ∏ p ∈ Nat.primesBelow (2 * n + 1), p ^ (n.centralBinom.factorization p) := hprod.symm
    _ ≤ ∏ _p ∈ Nat.primesBelow (2 * n + 1), (2 * n) := by
          refine Finset.prod_le_prod' ?_
          intro p _
          exact Nat.pow_factorization_choose_le (by positivity)
    _ = (2 * n) ^ (Nat.primeCounting (2 * n)) := by rw [Finset.prod_const, hcard]

/-- Logarithmic form of the central binomial bound. -/
theorem log_four_le (n : ℕ) (hn : 4 ≤ n) :
    (n : ℝ) * Real.log 4 ≤
      Real.log n + (Nat.primeCounting (2 * n) : ℝ) * Real.log (2 * (n : ℝ)) := by
  have hn0 : 0 < n := by omega
  have h1 : (4 : ℕ) ^ n ≤ n * n.centralBinom := (Nat.four_pow_lt_mul_centralBinom n hn).le
  have h2 : n * n.centralBinom ≤ n * (2 * n) ^ (Nat.primeCounting (2 * n)) :=
    Nat.mul_le_mul_left _ (centralBinom_le_pow_primeCounting n hn0)
  have h3 : (4 : ℕ) ^ n ≤ n * (2 * n) ^ (Nat.primeCounting (2 * n)) := le_trans h1 h2
  have h3' : (4 : ℝ) ^ n ≤ (n : ℝ) * (2 * (n : ℝ)) ^ (Nat.primeCounting (2 * n)) := by
    have := (Nat.cast_le (α := ℝ)).mpr h3
    push_cast at this
    exact this
  have hpos : (0 : ℝ) < (4 : ℝ) ^ n := by positivity
  have hlog := Real.log_le_log hpos h3'
  rw [Real.log_pow] at hlog
  have hn0' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn0
  rw [Real.log_mul (by positivity) (by positivity), Real.log_pow] at hlog
  linarith [hlog]

/-- **Chebyshev-type lower bound.** For `n ≥ 8` we have `n ≤ 8 * π n * log n`,
i.e. `π n ≥ n / (8 log n)`. -/
theorem le_primeCounting_mul_log (n : ℕ) (hn : 8 ≤ n) :
    (n : ℝ) ≤ 8 * (Nat.primeCounting n : ℝ) * Real.log n := by
  -- the even case, with the better constant `4`
  have even_case : ∀ k : ℕ, 4 ≤ k → 2 * (k : ℝ) ≤
      4 * (Nat.primeCounting (2 * k) : ℝ) * Real.log (2 * (k : ℝ)) := by
    intro k hk
    have hbase := log_four_le k hk
    have hk4 : (4 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hk0 : (0 : ℝ) < (k : ℝ) := by linarith
    have hlogk : Real.log k ≤ Real.log (2 * (k : ℝ)) := by
      apply Real.log_le_log hk0
      linarith
    have hpi1 : 1 ≤ Nat.primeCounting (2 * k) := by
      rcases Nat.eq_zero_or_pos (Nat.primeCounting (2 * k)) with h | h
      · rw [Nat.primeCounting_eq_zero_iff] at h; omega
      · exact h
    have hpi1' : (1 : ℝ) ≤ (Nat.primeCounting (2 * k) : ℝ) := by exact_mod_cast hpi1
    have hlogpos : 0 < Real.log (2 * (k : ℝ)) := Real.log_pos (by linarith)
    have hlog4 : Real.log 4 = 2 * Real.log 2 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
      push_cast; ring
    have hlog2 : (1 : ℝ) / 2 < Real.log 2 := by
      have := Real.log_two_gt_d9
      linarith
    -- `log k ≤ π(2k) * log (2k)`
    have hstep : Real.log k ≤ (Nat.primeCounting (2 * k) : ℝ) * Real.log (2 * (k : ℝ)) := by
      nlinarith [hlogpos, hpi1', hlogk]
    nlinarith [hbase, hstep, hlogpos, hlog2, hk0]
  rcases Nat.even_or_odd n with he | ho
  · obtain ⟨k, hk⟩ := he
    have hk' : n = 2 * k := by omega
    have hk4 : 4 ≤ k := by omega
    have h1 := even_case k hk4
    have hnk : (n : ℝ) = 2 * (k : ℝ) := by rw [hk']; push_cast; ring
    have hpc : Nat.primeCounting n = Nat.primeCounting (2 * k) := by rw [hk']
    rw [← hnk, ← hpc] at h1
    have hpi : (0 : ℝ) ≤ (Nat.primeCounting n : ℝ) := by positivity
    have hlogpos : 0 < Real.log n := Real.log_pos (by exact_mod_cast (by omega : 1 < n))
    nlinarith [h1]
  · -- odd case: pass to `n - 1`
    obtain ⟨j, hj⟩ := ho
    have hn9 : 9 ≤ n := by omega
    have hk4 : 4 ≤ j := by omega
    have h1 := even_case j hk4
    have hcast : (n : ℝ) - 1 = 2 * (j : ℝ) := by
      have : (n : ℝ) = 2 * (j : ℝ) + 1 := by rw [hj]; push_cast; ring
      linarith
    have hpc : Nat.primeCounting (n - 1) = Nat.primeCounting (2 * j) := by
      congr 1; omega
    rw [← hcast, ← hpc] at h1
    have hmono : Nat.primeCounting (n - 1) ≤ Nat.primeCounting n :=
      Nat.monotone_primeCounting (by omega)
    have hmono' : (Nat.primeCounting (n - 1) : ℝ) ≤ (Nat.primeCounting n : ℝ) := by
      exact_mod_cast hmono
    have hn9' : (9 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn9
    have hlogle : Real.log ((n : ℝ) - 1) ≤ Real.log n :=
      Real.log_le_log (by linarith) (by linarith)
    have hlogpos : 0 < Real.log ((n : ℝ) - 1) := Real.log_pos (by linarith)
    have hpi0 : (0 : ℝ) ≤ (Nat.primeCounting (n - 1) : ℝ) := by positivity
    have hchain : 4 * (Nat.primeCounting (n - 1) : ℝ) * Real.log ((n : ℝ) - 1)
        ≤ 4 * (Nat.primeCounting n : ℝ) * Real.log n := by
      nlinarith [hmono', hlogle, hlogpos, hpi0]
    linarith [h1, hchain]

end PrimeFractal