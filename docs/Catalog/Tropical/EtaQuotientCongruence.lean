import Tropical.EtaQuotientPositivity

/-!
# Divisibility congruences for eta-quotient coefficients

The recursion `n · c(n) = ∑_{i<n} c(i) · σ_b(n-i)` of `Tropical.EtaQuotientRecursion`
has an immediate arithmetic consequence that no finite jet computation can see: every
common divisor `d` of the divisor data `b` divides each structure constant `σ_b(j)`,
hence divides `n · c(n)` for every `n ≥ 1`.  Whenever `d` is coprime to `n` this
forces `d ∣ c(n)`.

For `1/Δ`, where `b m = 24` for every `m ≥ 1`, this gives

  `24 ∣ c(n)`  for every `n ≥ 1` coprime to `24`

(`coeff_delta_dvd_of_coprime`), and in general `24 ∣ n · c(n)`.  The numerical data
`c(1) = 24`, `c(2) = 324`, `c(3) = 3200`, `c(4) = 25650`, `c(5) = 176256` show the
coprimality hypothesis is not removable: `324`, `3200`, `25650` are *not* divisible by
`24`, while `24` and `176256 = 24 · 7344` are.  This is verified in Lean below by
`coeff_two_delta_not_dvd_24`.
-/

namespace EtaHead

open PowerSeries Finset

/-! ## Divisibility of the structure constants -/

/-- A common divisor of the divisor data `b` divides every twisted divisor sum. -/
theorem dvd_sigmaB {d : ℤ} (a : ℕ → ℤ) (N j : ℕ)
    (hd : ∀ m, 1 ≤ m → m ≤ N → d ∣ bCoeff a m) : d ∣ sigmaB a N j := by
  unfold sigmaB
  refine Finset.dvd_sum fun m hm => ?_
  obtain ⟨hmIcc, _⟩ := Finset.mem_filter.mp hm
  obtain ⟨hm1, hmN⟩ := Finset.mem_Icc.mp hmIcc
  exact Dvd.dvd.mul_left (hd m hm1 hmN) _

/-- **Congruence from the recursion.**  If `d` divides every `b m` (`1 ≤ m ≤ N`) then
`d ∣ n · c(n)` for every `n ≥ 1`. -/
theorem dvd_nat_mul_coeff {d : ℤ} (a : ℕ → ℤ) {N : ℕ} {n : ℕ} (hn : 1 ≤ n)
    (hd : ∀ m, 1 ≤ m → m ≤ N → d ∣ bCoeff a m) :
    d ∣ (n : ℤ) * coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  rw [coeff_recursion a N hn]
  refine Finset.dvd_sum fun i _ => ?_
  exact Dvd.dvd.mul_left (dvd_sigmaB a N _ hd) _

/-- If moreover `d` is coprime to `n`, the divisibility descends to `c(n)` itself. -/
theorem dvd_coeff_of_isCoprime {d : ℤ} (a : ℕ → ℤ) {N : ℕ} {n : ℕ} (hn : 1 ≤ n)
    (hd : ∀ m, 1 ≤ m → m ≤ N → d ∣ bCoeff a m) (hcop : IsCoprime d (n : ℤ)) :
    d ∣ coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) :=
  hcop.dvd_of_dvd_mul_left (dvd_nat_mul_coeff a hn hd)

/-! ## The case of `1/Δ` -/

/-- `24 ∣ n · c(n)` for the coefficients of `q/Δ`. -/
theorem dvd_24_nat_mul_coeff_delta {N n : ℕ} (hn : 1 ≤ n) :
    (24 : ℤ) ∣ (n : ℤ) * coeff n
      ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  refine dvd_nat_mul_coeff deltaExp hn (fun m hm1 _ => ?_)
  rw [bCoeff_deltaExp hm1]

/-- **A moonshine-flavoured congruence.**  For every `n ≥ 1` coprime to `24`, the
`n`-th coefficient of `q/Δ` is divisible by `24`. -/
theorem coeff_delta_dvd_of_coprime {N n : ℕ} (hn : 1 ≤ n) (hcop : Nat.gcd n 24 = 1) :
    (24 : ℤ) ∣ coeff n ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  refine dvd_coeff_of_isCoprime deltaExp hn (fun m hm1 _ => by rw [bCoeff_deltaExp hm1]) ?_
  rw [Int.isCoprime_iff_gcd_eq_one]
  simpa [Int.gcd, Nat.gcd_comm] using hcop

/-- The coprimality hypothesis in `coeff_delta_dvd_of_coprime` cannot be dropped: for
`n = 2` the coefficient is `324`, and `24 ∤ 324`. -/
theorem coeff_two_delta_not_dvd_24 {N : ℕ} (hN : 2 ≤ N) :
    ¬ ((24 : ℤ) ∣ coeff 2
      ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)) := by
  rw [coeff_two_delta hN]
  decide

/-- The first instance of the congruence: the `q`-coefficient `24` is divisible by
`24`. -/
theorem coeff_one_delta_dvd_24 (N : ℕ) :
    (24 : ℤ) ∣ coeff 1 ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) :=
  coeff_delta_dvd_of_coprime (by omega) (by decide)

/-! ## A general two-sided statement -/

/-- Combining positivity with the congruence: for `1/Δ` and `n ≥ 1` coprime to `24`,
the coefficient `c(n-1)` is a *positive* multiple of `24`, hence at least `24`. -/
theorem coeff_delta_ge_24_of_coprime {N n : ℕ} (hN : 1 ≤ N) (hn : 1 ≤ n)
    (hcop : Nat.gcd n 24 = 1) :
    24 ≤ coeff n ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  obtain ⟨t, ht⟩ := coeff_delta_dvd_of_coprime (N := N) hn hcop
  have hpos : 1 ≤ coeff n ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) :=
    coeff_delta_pos hN n
  have ht1 : 1 ≤ t := by nlinarith [ht, hpos]
  nlinarith [ht, ht1]

end EtaHead