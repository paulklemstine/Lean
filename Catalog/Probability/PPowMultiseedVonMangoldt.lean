import Mathlib
import Probability.PPowMultiseedLift

/-!
# The prime-power lift is a von Mangoldt mass: exact window law and density floor

Second cycle of the PPOW-MULTISEED study (round-46 #2, experiment 506).  In
`Probability.PPowMultiseedLift` the prime-power feature was identified with
`ppExcess n = log n - log (rad n)` and shown to be a non-negative, squarefree-
vanishing signal with an offset-uniform window floor.  Here that signal is
identified with a **von Mangoldt mass carried by the non-prime prime powers**,
which yields an *exact* window law rather than a bound.

Writing `Λ` for the von Mangoldt function and

`ppWeight d = if d.Prime then 0 else Λ d`  (so `ppWeight` is supported on `p^k`, `k ≥ 2`),

the results are:

* `ppExcess_eq_sum_divisors` — `ppExcess n = ∑_{d ∣ n} ppWeight d`.  Combining
  Chebyshev's identity `∑_{d ∣ n} Λ d = log n` with `∑_{p ∣ n} log p = log (rad n)`:
  the base feature is the *prime* part of the divisor sum, and the `pp_sum`
  feature is exactly the remaining *higher prime power* part.
* `sum_divisorSum_eq_sum_mul_div` — the Dirichlet-swap identity
  `∑_{n ≤ N} ∑_{d ∣ n} f d = ∑_{d ≤ N} f d ⌊N/d⌋`.
* `ppMass_eq_sum_ppWeight_mul_div` — **the exact window law**
  `∑_{n ≤ N} ppExcess n = ∑_{d ≤ N} ppWeight d · ⌊N/d⌋`, i.e. the total lift of
  a window `[1, N]` is a weighted prime-power counting function.
* `ppMass_ge_density_of_finset` — for **any** finite family `D` of higher prime
  powers, `∑_{n ≤ N} ppExcess n ≥ (∑_{d ∈ D} Λ d / d)·N - ∑_{d ∈ D} Λ d`.  The
  attainable densities `∑_{d ∈ D} Λ d / d` increase to `∑_p log p / (p(p-1))`,
  so the lift is genuinely *linear* in the window length — the deterministic
  form of "the lift grows with window length".
* `ppMass_ge_quarter_mul` — an explicit numerical instance: the mass over
  `[1, N]` is at least `N/4 - 2`.

Together with the first file this closes the loop: the lift is (i) real
(`prime_square_residual_lower_bound`), (ii) offset/seed-uniform
(`windowMass_ge_of_offset`), and (iii) exactly linear in the window length with
an explicit density floor (here).
-/

namespace PPowMultiseed

open Finset ArithmeticFunction

/-- The prime-power weight: the von Mangoldt function restricted to the
*non-prime* prime powers `p^k`, `k ≥ 2`.  This is the arithmetic kernel of the
`pp_sum` feature. -/
noncomputable def ppWeight (d : ℕ) : ℝ := if d.Prime then 0 else Λ d

lemma ppWeight_nonneg (d : ℕ) : 0 ≤ ppWeight d := by
  unfold ppWeight
  split
  · exact le_rfl
  · exact vonMangoldt_nonneg

lemma ppWeight_eq_zero_of_not_isPrimePow {d : ℕ} (hd : ¬ IsPrimePow d) : ppWeight d = 0 := by
  unfold ppWeight
  split
  · rfl
  · simp [vonMangoldt_apply, hd]

lemma ppWeight_prime_pow {p k : ℕ} (hp : p.Prime) (hk : 2 ≤ k) :
    ppWeight (p ^ k) = Real.log p := by
  have hnp : ¬ (p ^ k).Prime := by
    intro h
    have hd : p ∣ p ^ k := dvd_pow_self p (by omega)
    have : p = 1 ∨ p = p ^ k := (Nat.Prime.eq_one_or_self_of_dvd h p hd)
    rcases this with h1 | h1
    · exact absurd h1 hp.ne_one
    · have hpk : p ^ 1 = p ^ k := by simpa using h1
      have : (1 : ℕ) = k := Nat.pow_right_injective hp.two_le hpk
      omega
  unfold ppWeight
  rw [if_neg hnp, vonMangoldt_apply_pow (by omega), vonMangoldt_apply_prime hp]

/-- **The base/prime-power split of Chebyshev's divisor identity.**  The divisor
sum of `Λ` is `log n`; its *prime* part is the base feature `log (rad n)`; the
remainder is exactly the prime-power excess. -/
theorem ppExcess_eq_sum_divisors (n : ℕ) :
    ppExcess n = ∑ d ∈ n.divisors, ppWeight d := by
  classical
  have hsplit : ∑ d ∈ n.divisors, Λ d
      = (∑ d ∈ n.divisors with d.Prime, Λ d) + ∑ d ∈ n.divisors with ¬ d.Prime, Λ d :=
    (Finset.sum_filter_add_sum_filter_not _ _ _).symm
  have hprime : (∑ d ∈ n.divisors with d.Prime, Λ d) = Real.log (rad n) := by
    rw [log_rad, ← Nat.primeFactors_eq_to_filter_divisors_prime]
    exact Finset.sum_congr rfl fun p hp =>
      vonMangoldt_apply_prime (Nat.prime_of_mem_primeFactors hp)
  have hpp : (∑ d ∈ n.divisors, ppWeight d) = ∑ d ∈ n.divisors with ¬ d.Prime, Λ d := by
    rw [Finset.sum_filter]
    exact Finset.sum_congr rfl fun d _ => by unfold ppWeight; split <;> simp_all
  rw [hpp, ppExcess]
  have := vonMangoldt_sum (n := n)
  rw [hsplit, hprime] at this
  linarith

/-- The Dirichlet swap: summing a divisor sum over `[1, N]` counts each `d` with
multiplicity `⌊N/d⌋`. -/
theorem sum_divisorSum_eq_sum_mul_div (N : ℕ) (f : ℕ → ℝ) :
    ∑ n ∈ Finset.Icc 1 N, ∑ d ∈ n.divisors, f d
      = ∑ d ∈ Finset.Icc 1 N, f d * ((N / d : ℕ) : ℝ) := by
  classical
  have hIcc : Finset.Icc 1 N = Finset.Ioc 0 N := by ext x; simp [Nat.lt_iff_add_one_le]
  have step1 : ∀ n ∈ Finset.Icc 1 N, ∑ d ∈ n.divisors, f d
      = ∑ d ∈ Finset.Icc 1 N, if d ∣ n then f d else 0 := by
    intro n hn
    simp only [Finset.mem_Icc] at hn
    rw [← Finset.sum_filter]
    refine (Finset.sum_congr ?_ fun _ _ => rfl).symm
    ext d
    simp only [Finset.mem_filter, Finset.mem_Icc, Nat.mem_divisors]
    constructor
    · rintro ⟨⟨_, _⟩, hd⟩
      exact ⟨hd, by omega⟩
    · rintro ⟨hd, _⟩
      have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hd (by omega)
      exact ⟨⟨hdpos, le_trans (Nat.le_of_dvd (by omega) hd) hn.2⟩, hd⟩
  rw [Finset.sum_congr rfl step1, Finset.sum_comm]
  refine Finset.sum_congr rfl fun d _ => ?_
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero, add_zero]
  have hcard : ({n ∈ Finset.Icc 1 N | d ∣ n}).card = N / d := by
    rw [hIcc]
    exact Nat.Ioc_filter_dvd_card_eq_div N d
  rw [hcard, nsmul_eq_mul, mul_comm]

lemma windowMass_one_eq_sum_Icc (N : ℕ) :
    windowMass 1 N = ∑ n ∈ Finset.Icc 1 N, ppExcess n := by
  unfold windowMass
  congr 1
  ext n
  simp [Nat.add_comm]

/-- **The exact window law.**  The total prime-power lift of the window `[1, N]`
is the weighted prime-power counting function `∑_{d ≤ N} ppWeight d · ⌊N/d⌋`.
This is an identity, not an estimate. -/
theorem ppMass_eq_sum_ppWeight_mul_div (N : ℕ) :
    windowMass 1 N = ∑ d ∈ Finset.Icc 1 N, ppWeight d * ((N / d : ℕ) : ℝ) := by
  rw [windowMass_one_eq_sum_Icc, ← sum_divisorSum_eq_sum_mul_div]
  exact Finset.sum_congr rfl fun n _ => ppExcess_eq_sum_divisors n

/-- **A linear density floor from any finite family of higher prime powers.**
For every finite `D` of integers `≤ N`, the lift over `[1, N]` is at least
`(∑_{d ∈ D} ppWeight d / d) · N - ∑_{d ∈ D} ppWeight d`.  Since the achievable
densities `∑_{d ∈ D} Λ d / d` increase to `∑_p log p /(p(p-1))`, the lift grows
*linearly* in the window length. -/
theorem ppMass_ge_density_of_finset {N : ℕ} {D : Finset ℕ} (hD : D ⊆ Finset.Icc 1 N) :
    (∑ d ∈ D, ppWeight d / (d : ℝ)) * N - (∑ d ∈ D, ppWeight d) ≤ windowMass 1 N := by
  classical
  rw [ppMass_eq_sum_ppWeight_mul_div]
  have hsub : ∑ d ∈ D, ppWeight d * ((N / d : ℕ) : ℝ)
      ≤ ∑ d ∈ Finset.Icc 1 N, ppWeight d * ((N / d : ℕ) : ℝ) := by
    refine Finset.sum_le_sum_of_subset_of_nonneg hD fun d _ _ => ?_
    have := ppWeight_nonneg d
    positivity
  have hterm : ∀ d ∈ D, ppWeight d / (d : ℝ) * N - ppWeight d
      ≤ ppWeight d * ((N / d : ℕ) : ℝ) := by
    intro d hd
    have hd1 : 1 ≤ d := (Finset.mem_Icc.1 (hD hd)).1
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd1
    have hdivmod : d * (N / d) + N % d = N := Nat.div_add_mod N d
    have hmod : N % d < d := Nat.mod_lt _ (by omega)
    have hcast : (d : ℝ) * ((N / d : ℕ) : ℝ) ≥ (N : ℝ) - d := by
      have h1 : ((d * (N / d) : ℕ) : ℝ) = (N : ℝ) - ((N % d : ℕ) : ℝ) := by
        have : ((d * (N / d) + N % d : ℕ) : ℝ) = (N : ℝ) := by exact_mod_cast hdivmod
        push_cast at this ⊢
        linarith
      have h2 : ((N % d : ℕ) : ℝ) ≤ (d : ℝ) := by exact_mod_cast hmod.le
      push_cast at h1
      linarith
    have hw := ppWeight_nonneg d
    have key : ppWeight d * ((N : ℝ) - d) ≤ ppWeight d * ((d : ℝ) * ((N / d : ℕ) : ℝ)) :=
      mul_le_mul_of_nonneg_left hcast hw
    rw [div_mul_eq_mul_div, sub_le_iff_le_add, div_le_iff₀ hdpos]
    nlinarith
  have := Finset.sum_le_sum hterm
  rw [Finset.sum_sub_distrib] at this
  calc (∑ d ∈ D, ppWeight d / (d : ℝ)) * N - (∑ d ∈ D, ppWeight d)
      = (∑ d ∈ D, ppWeight d / (d : ℝ) * N) - (∑ d ∈ D, ppWeight d) := by
        rw [Finset.sum_mul]
    _ ≤ ∑ d ∈ D, ppWeight d * ((N / d : ℕ) : ℝ) := this
    _ ≤ _ := hsub

/-- An explicit numerical density floor: using only the prime powers `4` and `8`
the lift over `[1, N]` is at least `N/4 - 2`.  (The true density constant is
`∑_p log p /(p(p-1)) ≈ 0.7554`; the family `{4, 8}` alone already gives
`3 log 2 / 8 ≈ 0.2599`.) -/
theorem ppMass_ge_quarter_mul {N : ℕ} (hN : 8 ≤ N) :
    (N : ℝ) / 4 - 2 ≤ windowMass 1 N := by
  classical
  have hD : ({4, 8} : Finset ℕ) ⊆ Finset.Icc 1 N := by
    intro d hd
    simp only [Finset.mem_insert, Finset.mem_singleton] at hd
    rcases hd with rfl | rfl <;> (simp only [Finset.mem_Icc]; omega)
  have h := ppMass_ge_density_of_finset hD
  have h4 : ppWeight 4 = Real.log 2 := by
    have : (4 : ℕ) = 2 ^ 2 := by norm_num
    rw [this, ppWeight_prime_pow Nat.prime_two le_rfl]
    norm_num
  have h8 : ppWeight 8 = Real.log 2 := by
    have : (8 : ℕ) = 2 ^ 3 := by norm_num
    rw [this, ppWeight_prime_pow Nat.prime_two (by norm_num)]
    norm_num
  have hsum1 : ∑ d ∈ ({4, 8} : Finset ℕ), ppWeight d / (d : ℝ)
      = Real.log 2 / 4 + Real.log 2 / 8 := by
    rw [Finset.sum_insert (by decide), Finset.sum_singleton, h4, h8]
    norm_num
  have hsum2 : ∑ d ∈ ({4, 8} : Finset ℕ), ppWeight d = 2 * Real.log 2 := by
    rw [Finset.sum_insert (by decide), Finset.sum_singleton, h4, h8]
    ring
  rw [hsum1, hsum2] at h
  have hlo : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hhi : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hNpos : (8 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  nlinarith

end PPowMultiseed