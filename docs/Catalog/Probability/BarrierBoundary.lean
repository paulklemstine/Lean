/-
# Adversarial review: where the barriers stop

This file is the Critic's contribution: it delimits precisely what the
structural-orthogonality framework does and does not say.

1. **The barriers are not information-theoretic.**  The smaller prime factor
   *is* a function of `N` alone (`FactoringLab.smaller_factor_is_N_only`,
   witnessed by `Nat.minFac`).  So "any computable function of `N` alone is
   `N`-only" must be read structurally, not informationally: what the proved
   barriers exclude are *specific structured classes* of such functions
   (polynomial, rational, holomorphically rigid, symmetric-power-sum).
2. **The near-equal-`N` test needs genuinely coarse bands.**  If the band label
   separates the population points (`Function.Injective` on `Ω`), the band mean
   reproduces the target exactly (`FactoringLab.bandMean_eq_self_of_injOn`) and
   the residual vanishes, so the test is vacuous.
3. **The constant-band-mean hypothesis is necessary.**  Without it an `N`-only
   invariant can have strictly nonzero covariance with the smaller factor:
   `FactoringLab.cov_pos_counterexample` exhibits `Ω = {6, 15}` with covariance
   `9/4 > 0`.
-/
import Mathlib
import Probability.StructuralOrthogonality

namespace FactoringLab

/-! ### The barrier is structural, not informational -/

/-- For distinct primes `p < q`, the least prime factor of the semiprime `p*q`
is `p`. -/
theorem minFac_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q) :
    (p * q).minFac = p := by
  have hN1 : p * q ≠ 1 := by
    have := hp.two_le; have := hq.two_le; nlinarith
  have hdvd : (p * q).minFac ∣ p * q := Nat.minFac_dvd _
  have hprime : ((p * q).minFac).Prime := Nat.minFac_prime hN1
  have hle : (p * q).minFac ≤ p :=
    Nat.minFac_le_of_dvd hp.two_le ⟨q, rfl⟩
  rcases (Nat.Prime.dvd_mul hprime).1 hdvd with h | h
  · exact ((Nat.prime_dvd_prime_iff_eq hprime hp).1 h)
  · have : q ≤ p := Nat.le_of_dvd hp.pos (by
      rw [(Nat.prime_dvd_prime_iff_eq hprime hq).1 h] at hle
      exact absurd hle (by omega))
    omega

/-- **The barriers are not information-theoretic.**  There is a function of `N`
alone returning the smaller prime factor of every semiprime.  Consequently the
eight barriers must be read as statements about *structured* classes of
invariants (polynomials, rational functions, entire functions, symmetric power
sums), not as an information-theoretic obstruction. -/
theorem smaller_factor_is_N_only :
    ∃ g : ℕ → ℕ, ∀ p q : ℕ, p.Prime → q.Prime → p < q → g (p * q) = p :=
  ⟨Nat.minFac, fun _ _ hp hq hpq => minFac_semiprime hp hq hpq⟩

/-! ### The near-equal-`N` test is vacuous for fine bands -/

variable {ι κ : Type*} [DecidableEq κ]

/-- If the band label separates the population, each band is a singleton and the
band mean is the target itself: the residual, and hence the whole
structural-orthogonality argument, degenerates. -/
theorem bandMean_eq_self_of_injOn (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (hinj : ∀ i ∈ Ω, ∀ j ∈ Ω, n i = n j → i = j) {i : ι} (hi : i ∈ Ω) :
    bandMean Ω n Y i = Y i := by
  have hband : band Ω n i = {i} := by
    apply Finset.eq_singleton_iff_unique_mem.2
    refine ⟨by simp [band, hi], ?_⟩
    intro j hj
    have hj' := Finset.mem_filter.1 hj
    exact hinj j hj'.1 i hi hj'.2
  simp [bandMean, hband]

/-- With separating bands the prediction error of the band mean is zero, so the
barrier statement `bandMean_is_best_predictor` carries no information: the
near-equal-`N` test only has content for bands pooling several moduli. -/
theorem sq_error_zero_of_injOn (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (hinj : ∀ i ∈ Ω, ∀ j ∈ Ω, n i = n j → i = j) :
    ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 = 0 := by
  refine Finset.sum_eq_zero fun i hi => ?_
  rw [bandMean_eq_self_of_injOn Ω n Y hinj hi]
  ring

/-! ### The constant-band-mean hypothesis cannot be dropped -/

/-- **Sharpness of the near-equal-`N` test.**  On the two-element population of
semiprimes `{6, 15}` with the identity band label, the `N`-only invariant
`g(N) = N` has covariance `9/4` with the smaller prime factor.  Hence the
hypothesis that band means are constant in `nearEqualN_test` is indispensable:
across size bands, `N`-only invariants *do* correlate with `p`. -/
theorem cov_pos_counterexample :
    cov ({6, 15} : Finset ℕ) (fun i => (i : ℝ)) (fun i => ((Nat.minFac i : ℕ) : ℝ))
      = 9 / 4 := by
  have h6 : Nat.minFac 6 = 2 := by norm_num
  have h15 : Nat.minFac 15 = 3 := by norm_num
  have hpair : ∀ f : ℕ → ℝ, ∑ i ∈ ({6, 15} : Finset ℕ), f i = f 6 + f 15 :=
    fun f => Finset.sum_pair (by norm_num)
  have hcard : ({6, 15} : Finset ℕ).card = 2 := Finset.card_pair (by norm_num)
  simp only [cov, expect, hpair, hcard, h6, h15]
  norm_num

end FactoringLab