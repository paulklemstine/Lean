import Tropical.EtaQuotientRecursion
import Tropical.EtaQuotientHeadStructure

/-!
# Positivity of every coefficient of a normalised eta quotient

The logarithmic-derivative recursion of `Tropical.EtaQuotientRecursion`,

  `n · [q^n] F = ∑_{i < n} [q^i] F · σ_b(n - i)`,

has all its structure constants `σ_b(j) = ∑_{m ∣ j, m ≤ N} m · b m` *nonnegative* as
soon as the divisor data `b` is nonnegative.  Since the recursion expresses `n·c(n)`
as a nonnegative combination of the earlier coefficients, a strong induction gives:

* `coeff_nonneg_of_bCoeff_nonneg` : `b ≥ 0` implies `[q^n] F ≥ 0` for all `n`;
* `one_le_coeff_of_bCoeff_pos`    : if moreover `b 1 ≥ 1` then `[q^n] F ≥ 1`;
* `coeff_delta_pos`               : all coefficients of `q/Δ` are `≥ 1`
  (the classical positivity of OEIS A006922, `1, 24, 324, 3200, 25650, …`).

This is a genuinely *infinite-degree* statement: no finite jet calculus can reach it,
and it is exactly the kind of conclusion the recursion was built to supply.  Note the
hypothesis is on `b = ∑_{k ∣ m} a k`, not on `a` itself: the eta quotient `1/Δ` has
`a = 24·δ₁` supported in a single index, but `b m = 24` for every `m ≥ 1`.
-/

namespace EtaHead

open PowerSeries Finset

/-! ## Nonnegativity of the structure constants -/

/-- If all the divisor data `b m` (`1 ≤ m ≤ N`) are nonnegative, then so are all the
twisted divisor sums `σ_b(j)`. -/
theorem sigmaB_nonneg (a : ℕ → ℤ) (N j : ℕ)
    (hb : ∀ m, 1 ≤ m → m ≤ N → 0 ≤ bCoeff a m) : 0 ≤ sigmaB a N j := by
  unfold sigmaB
  refine Finset.sum_nonneg fun m hm => ?_
  obtain ⟨hmIcc, _⟩ := Finset.mem_filter.mp hm
  obtain ⟨hm1, hmN⟩ := Finset.mem_Icc.mp hmIcc
  exact mul_nonneg (by positivity) (hb m hm1 hmN)

/-- Since `1` divides every `j`, the term `m = 1` is always present in `σ_b(j)`; hence
`σ_b(j) ≥ b 1` whenever the remaining data are nonnegative. -/
theorem bCoeff_one_le_sigmaB (a : ℕ → ℤ) {N j : ℕ} (hN : 1 ≤ N)
    (hb : ∀ m, 1 ≤ m → m ≤ N → 0 ≤ bCoeff a m) : bCoeff a 1 ≤ sigmaB a N j := by
  have hmem : (1 : ℕ) ∈ (Icc 1 N).filter (fun m => m ∣ j) := by
    simp only [Finset.mem_filter, Finset.mem_Icc]
    exact ⟨⟨le_refl 1, hN⟩, one_dvd j⟩
  have hsplit :
      sigmaB a N j
        = ((1 : ℕ) : ℤ) * bCoeff a 1
          + ∑ m ∈ ((Icc 1 N).filter (fun m => m ∣ j)).erase 1, (m : ℤ) * bCoeff a m := by
    unfold sigmaB
    exact (Finset.add_sum_erase _ _ hmem).symm
  have hrest : 0 ≤ ∑ m ∈ ((Icc 1 N).filter (fun m => m ∣ j)).erase 1,
      (m : ℤ) * bCoeff a m := by
    refine Finset.sum_nonneg fun m hm => ?_
    obtain ⟨hmIcc, _⟩ := Finset.mem_filter.mp (Finset.mem_of_mem_erase hm)
    obtain ⟨hm1, hmN⟩ := Finset.mem_Icc.mp hmIcc
    exact mul_nonneg (by positivity) (hb m hm1 hmN)
  rw [hsplit]
  push_cast
  linarith

/-! ## Positivity of the coefficients -/

/-- **All coefficients of a nonnegative eta quotient are nonnegative.**
If `b m ≥ 0` for `1 ≤ m ≤ N`, then every coefficient of
`F = ∏_{m=1}^{N} (1 - X^m)^{-b m}` is `≥ 0`. -/
theorem coeff_nonneg_of_bCoeff_nonneg (a : ℕ → ℤ) (N : ℕ)
    (hb : ∀ m, 1 ≤ m → m ≤ N → 0 ≤ bCoeff a m) (n : ℕ) :
    0 ≤ coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · rw [coeff_zero_eq_constantCoeff_apply, constantCoeff_etaQuotientProd_direct a N]
      norm_num
    · have hrec := coeff_recursion a N (n := n) hn
      have hsum : 0 ≤ ∑ i ∈ range n,
          coeff i ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
            * sigmaB a N (n - i) := by
        refine Finset.sum_nonneg fun i hi => ?_
        exact mul_nonneg (ih i (Finset.mem_range.mp hi)) (sigmaB_nonneg a N _ hb)
      have hpos : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
      nlinarith [hrec, hsum, hpos]

/-- **Strict positivity.**  If in addition `b 1 ≥ 1`, then every coefficient of the
eta quotient is at least `1`.  The proof is a strong induction: the recursion writes
`n · c(n)` as a sum of `n` terms, each of which is `≥ 1 · 1`. -/
theorem one_le_coeff_of_bCoeff_pos (a : ℕ → ℤ) {N : ℕ} (hN : 1 ≤ N)
    (hb : ∀ m, 1 ≤ m → m ≤ N → 0 ≤ bCoeff a m) (hb1 : 1 ≤ bCoeff a 1) (n : ℕ) :
    1 ≤ coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · rw [coeff_zero_eq_constantCoeff_apply, constantCoeff_etaQuotientProd_direct a N]
    · have hrec := coeff_recursion a N (n := n) hn
      have hterm : ∀ i ∈ range n, (1 : ℤ) ≤
          coeff i ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
            * sigmaB a N (n - i) := by
        intro i hi
        have h1 : (1 : ℤ) ≤ coeff i ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) :=
          ih i (Finset.mem_range.mp hi)
        have h2 : (1 : ℤ) ≤ sigmaB a N (n - i) :=
          le_trans hb1 (bCoeff_one_le_sigmaB a (by omega) hb)
        nlinarith
      have hsum : (n : ℤ) ≤ ∑ i ∈ range n,
          coeff i ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
            * sigmaB a N (n - i) := by
        have := Finset.sum_le_sum hterm
        simpa using this
      have hpos : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
      nlinarith [hrec, hsum, hpos]

/-! ## The classical example: `q/Δ` -/

lemma bCoeff_deltaExp {m : ℕ} (hm : 1 ≤ m) : bCoeff deltaExp m = 24 := by
  unfold bCoeff deltaExp
  rw [Finset.sum_ite_eq' m.divisors 1 (fun _ => (24 : ℤ))]
  rw [if_pos (Nat.one_mem_divisors.mpr (by omega))]

/-- **Positivity of the coefficients of `1/Δ`.**  Every coefficient of the truncated
`q/Δ = ∏_{m=1}^{N}(1 - q^m)^{-24}` is at least `1`; the coefficient sequence
`1, 24, 324, 3200, 25650, …` (OEIS A006922) is therefore strictly positive. -/
theorem coeff_delta_pos {N : ℕ} (hN : 1 ≤ N) (n : ℕ) :
    1 ≤ coeff n ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  refine one_le_coeff_of_bCoeff_pos deltaExp hN (fun m hm1 _ => ?_) ?_ n
  · rw [bCoeff_deltaExp hm1]; norm_num
  · rw [bCoeff_deltaExp (le_refl 1)]; norm_num

/-- Strict monotonicity of the head data for `1/Δ`: the `q²`-coefficient `324` is
consistent with the general positivity bound, and in fact strictly exceeds it. -/
theorem coeff_two_delta_gt_one {N : ℕ} (hN : 2 ≤ N) :
    1 < coeff 2 ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  rw [coeff_two_delta hN]
  norm_num

end EtaHead