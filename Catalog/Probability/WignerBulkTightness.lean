/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tightness of the empirical spectral distribution

`Probability.WignerSpectralEdge` bounds the probability that *some* eigenvalue of
`W/√N` is large.  This file records the complementary — and for the semicircle law
more fundamental — statement about the *bulk*: the empirical spectral distribution
(ESD) of `W/√N` puts almost no mass far from the origin, uniformly in the dimension.

* `WignerBridge.frac_large_eigenvalues_le` is deterministic and holds for an
  arbitrary real symmetric matrix: the fraction of eigenvalues of `A/√N` of modulus
  at least `t` is at most `(2k)`-th normalised moment divided by `t^(2k)` — Markov's
  inequality applied to the ESD itself rather than to the ensemble.

* `RademacherWigner.expect_frac_large_eigenvalues_le` combines this with the uniform
  moment bound `expect_normalizedMoment_two_mul_le` to give, for every `k ≥ 1`,

    `E [ #{ i : |λᵢ|/√N ≥ t } / N ] ≤ (k+1)^(2k) / t^(2k)`,

  a bound independent of `N`.

* `RademacherWigner.esd_tight` is the resulting **tightness** statement: for every
  `ε > 0` there is a threshold `t` such that, in *every* dimension, the expected
  fraction of eigenvalues of `W/√N` outside `[-t, t]` is at most `ε`.  Tightness is
  exactly the compactness hypothesis under which convergence of all moments upgrades
  to weak convergence of the ESD, i.e. it is the missing analytic half of the moment
  method (Conjecture 4 of `FUTURE_DIRECTIONS.md`).
-/
import Probability.WignerMomentGrowth

open Matrix BigOperators Finset

namespace WignerBridge

/-- **Markov's inequality for the empirical spectral distribution.**  For a real
symmetric matrix `A` in dimension `N > 0`, the fraction of eigenvalues of `A/√N` of
modulus at least `t` is bounded by the `2k`-th normalised spectral moment divided by
`t^(2k)`.  Nothing probabilistic is used: this holds for every single matrix. -/
theorem frac_large_eigenvalues_le {N : ℕ} (hN : 0 < N) {A : Matrix (Fin N) (Fin N) ℝ}
    (hA : A.IsHermitian) (k : ℕ) {t : ℝ} (ht : 0 < t) :
    (((univ.filter fun i => t ≤ |hA.eigenvalues i| / Real.sqrt (N : ℝ)).card : ℝ) / (N : ℝ))
      ≤ normalizedMoment A (2 * k) / t ^ (2 * k) := by
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hcard : (Fintype.card (Fin N) : ℝ) = (N : ℝ) := by simp
  set S : Finset (Fin N) := univ.filter fun i => t ≤ |hA.eigenvalues i| / Real.sqrt (N : ℝ)
    with hS
  set mu : Fin N → ℝ := fun i => hA.eigenvalues i / Real.sqrt (N : ℝ) with hmu
  have hnonneg : ∀ i : Fin N, 0 ≤ (mu i) ^ (2 * k) := by
    intro i
    rw [pow_mul]
    positivity
  have hbig : ∀ i ∈ S, t ^ (2 * k) ≤ (mu i) ^ (2 * k) := by
    intro i hi
    have hti : t ≤ |mu i| := by
      have := (Finset.mem_filter.1 hi).2
      rwa [hmu, abs_div, abs_of_nonneg (Real.sqrt_nonneg _)]
    have h1 : t ^ (2 * k) ≤ |mu i| ^ (2 * k) := pow_le_pow_left₀ ht.le hti _
    rwa [pow_mul, pow_mul, sq_abs, ← pow_mul, ← pow_mul] at h1
  have hsum : (S.card : ℝ) * t ^ (2 * k) ≤ ∑ i : Fin N, (mu i) ^ (2 * k) := by
    calc (S.card : ℝ) * t ^ (2 * k) = ∑ _i ∈ S, t ^ (2 * k) := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ∑ i ∈ S, (mu i) ^ (2 * k) := Finset.sum_le_sum hbig
      _ ≤ ∑ i : Fin N, (mu i) ^ (2 * k) :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
            fun i _ _ => hnonneg i
  have hmoment : normalizedMoment A (2 * k) = (1 / (N : ℝ)) * ∑ i : Fin N, (mu i) ^ (2 * k) := by
    rw [normalizedMoment_eq_sum_eigenvalues hA, hcard]
  rw [hmoment, div_le_div_iff₀ hNR (by positivity)]
  have hpos : (0 : ℝ) < t ^ (2 * k) := by positivity
  calc (S.card : ℝ) * t ^ (2 * k) ≤ ∑ i : Fin N, (mu i) ^ (2 * k) := hsum
    _ = 1 / (N : ℝ) * (∑ i : Fin N, (mu i) ^ (2 * k)) * (N : ℝ) := by
        field_simp

end WignerBridge

namespace RademacherWigner

variable {N : ℕ}

/-- A pointwise inequality passes to the ensemble average. -/
theorem expect_le_of_forall {f h : Config N → ℝ} (hfh : ∀ g, f g ≤ h g) :
    expect f ≤ expect h := by
  have hc := card_config_pos N
  unfold expect
  gcongr with g
  exact hfh g

/-- **Uniform tail bound for the empirical spectral distribution.**  For every order
`k ≥ 1` and every threshold `t > 0`, the expected fraction of eigenvalues of `W/√N`
of modulus at least `t` is at most `(k+1)^(2k) / t^(2k)`, a bound that does not
depend on the dimension `N`. -/
theorem expect_frac_large_eigenvalues_le {k : ℕ} (hk : 1 ≤ k) (hN : 0 < N) {t : ℝ}
    (ht : 0 < t) :
    expect (fun g : Config N =>
        (((univ.filter fun i =>
            t ≤ |(W_isHermitian g).eigenvalues i| / Real.sqrt (N : ℝ)).card : ℝ) / (N : ℝ)))
      ≤ ((k : ℝ) + 1) ^ (2 * k) / t ^ (2 * k) := by
  have hpos : (0 : ℝ) < t ^ (2 * k) := by positivity
  have hstep : expect (fun g : Config N =>
      (((univ.filter fun i =>
          t ≤ |(W_isHermitian g).eigenvalues i| / Real.sqrt (N : ℝ)).card : ℝ) / (N : ℝ)))
      ≤ expect (fun g : Config N =>
          (t ^ (2 * k))⁻¹ * WignerBridge.normalizedMoment (W g) (2 * k)) := by
    refine expect_le_of_forall fun g => ?_
    have h := WignerBridge.frac_large_eigenvalues_le hN (W_isHermitian g) k ht
    rwa [div_eq_inv_mul (WignerBridge.normalizedMoment (W g) (2 * k))] at h
  refine hstep.trans ?_
  rw [expect_const_mul, div_eq_inv_mul]
  exact mul_le_mul_of_nonneg_left (expect_normalizedMoment_two_mul_le hk hN)
    (by positivity)

/-- **Tightness of the empirical spectral distribution, uniformly in the dimension.**
For every `ε > 0` there is a threshold `t > 0` such that, in *every* dimension `N`,
the expected fraction of eigenvalues of `W/√N` of modulus at least `t` is at most
`ε`.  Concretely one may take `t = 2/√ε`, coming from the second moment. -/
theorem esd_tight {ε : ℝ} (hε : 0 < ε) :
    ∃ t : ℝ, 0 < t ∧ ∀ N : ℕ, 0 < N →
      expect (fun g : Config N =>
          (((univ.filter fun i =>
              t ≤ |(W_isHermitian g).eigenvalues i| / Real.sqrt (N : ℝ)).card : ℝ) / (N : ℝ)))
        ≤ ε := by
  refine ⟨2 / Real.sqrt ε, by positivity, fun N hN => ?_⟩
  have hsq : Real.sqrt ε > 0 := Real.sqrt_pos.2 hε
  have ht : (0 : ℝ) < 2 / Real.sqrt ε := by positivity
  have h := expect_frac_large_eigenvalues_le (N := N) (k := 1) le_rfl hN ht
  have hval : ((1 : ℝ) + 1) ^ (2 * 1) / (2 / Real.sqrt ε) ^ (2 * 1) = ε := by
    rw [div_pow, div_div_eq_mul_div, Real.sq_sqrt hε.le]
    norm_num
  rw [show ((1 : ℕ) : ℝ) = 1 from Nat.cast_one] at h
  rwa [hval] at h

end RademacherWigner