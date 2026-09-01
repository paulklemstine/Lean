/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A third mechanism: the coincidence (MA-1) scan and profile-shape identification

Companion to `Catalog.Bridges.ConsecutiveVDependency`.  That file separates two
mechanisms for a 0/1 scan: *pure density* (independent hits, position-dependent
rate) and *Markov dependence*, whose lag profile is exactly geometric, `λ^k`.

A third mechanism is on the open list of the research thread: a **moving-average
/ coincidence** rule, in which a hit is recorded when two neighbouring cells of a
latent independent scan both fire,

  `Y i = X i * X (i+1)`,  `X` independent with rate curve `p`.

The `Y` sequence is *not* independent — neighbouring `Y`'s share a latent cell —
yet its dependence has finite range 1.  Working inside the same finite product
model, this file computes its lag profile exactly, for an **arbitrary latent rate
curve** (so the density confound is included, not assumed away):

* `bernExp_maHit` — the marginal hit rate is `p i * p (i+1)`;
* `maCov_lag_one` — the lag-1 autocovariance is
  `p i * p (i+1) * p (i+2) * (1 - p (i+1))`, strictly positive for rates in
  `(0,1)`;
* `maCov_lag_ge_two` — **every** autocovariance at lag `≥ 2` is exactly `0`,
  whatever the rate curve: heterogeneity cannot leak into the far lags;
* `maCorr_lag_one_const` — at constant latent rate `q` the lag-1 autocorrelation
  is `q / (1 + q)`, so the profile is a single spike followed by exact zeros;
* `ma_scan_not_markov` — consequently the coincidence scan is *not* a stationary
  two-state Markov chain: no `(a, b)` reproduces its profile, because a geometric
  profile that vanishes at lag 2 vanishes at lag 1 as well.

Together with `ConsecutiveVDependency.density_dependence_dichotomy` this upgrades
the dichotomy to a **trichotomy of profile shapes**: flat (density), geometric
(Markov), one-spike (coincidence / MA-1), pairwise distinguished by the first two
lags alone (`profile_shape_trichotomy`).
-/

import Bridges.ConsecutiveVDependency

open Finset ConsecutiveVDependency

namespace MovingAverageScan

/-! ## 1. Third and fourth joint moments of the latent scan -/

theorem bernExp_hit_prod3 (n : ℕ) (p : ℕ → ℝ) {i j l : ℕ} (hi : i < n) (hj : j < n) (hl : l < n)
    (hij : i ≠ j) (hil : i ≠ l) (hjl : j ≠ l) :
    bernExp n p (fun s => hit n s i * (hit n s j * hit n s l)) = p i * (p j * p l) := by
  have hnij : (⟨i, hi⟩ : Fin n) ≠ ⟨j, hj⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hij
  have hnil : (⟨i, hi⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hil
  have hnjl : (⟨j, hj⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hjl
  have hmem : (⟨i, hi⟩ : Fin n) ∉ ({⟨j, hj⟩, ⟨l, hl⟩} : Finset (Fin n)) := by simp [hnij, hnil]
  have hfun : (fun s : Fin n → Bool => hit n s i * (hit n s j * hit n s l))
      = fun s => ∏ x ∈ ({⟨i, hi⟩, ⟨j, hj⟩, ⟨l, hl⟩} : Finset (Fin n)),
          (if s x then (1 : ℝ) else 0) := by
    funext s
    rw [Finset.prod_insert hmem, Finset.prod_pair hnjl, hit_eq n s hi, hit_eq n s hj,
      hit_eq n s hl]
  rw [hfun, bernExp_marker, Finset.prod_insert hmem, Finset.prod_pair hnjl]

theorem bernExp_hit_prod4 (n : ℕ) (p : ℕ → ℝ) {i j l r : ℕ} (hi : i < n) (hj : j < n) (hl : l < n)
    (hr : r < n) (hij : i ≠ j) (hil : i ≠ l) (hir : i ≠ r) (hjl : j ≠ l) (hjr : j ≠ r)
    (hlr : l ≠ r) :
    bernExp n p (fun s => hit n s i * (hit n s j * (hit n s l * hit n s r)))
      = p i * (p j * (p l * p r)) := by
  have hnij : (⟨i, hi⟩ : Fin n) ≠ ⟨j, hj⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hij
  have hnil : (⟨i, hi⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hil
  have hnir : (⟨i, hi⟩ : Fin n) ≠ ⟨r, hr⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hir
  have hnjl : (⟨j, hj⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hjl
  have hnjr : (⟨j, hj⟩ : Fin n) ≠ ⟨r, hr⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hjr
  have hnlr : (⟨l, hl⟩ : Fin n) ≠ ⟨r, hr⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hlr
  have hmem1 : (⟨i, hi⟩ : Fin n) ∉ ({⟨j, hj⟩, ⟨l, hl⟩, ⟨r, hr⟩} : Finset (Fin n)) := by
    simp [hnij, hnil, hnir]
  have hmem2 : (⟨j, hj⟩ : Fin n) ∉ ({⟨l, hl⟩, ⟨r, hr⟩} : Finset (Fin n)) := by simp [hnjl, hnjr]
  have hfun : (fun s : Fin n → Bool => hit n s i * (hit n s j * (hit n s l * hit n s r)))
      = fun s => ∏ x ∈ ({⟨i, hi⟩, ⟨j, hj⟩, ⟨l, hl⟩, ⟨r, hr⟩} : Finset (Fin n)),
          (if s x then (1 : ℝ) else 0) := by
    funext s
    rw [Finset.prod_insert hmem1, Finset.prod_insert hmem2, Finset.prod_pair hnlr,
      hit_eq n s hi, hit_eq n s hj, hit_eq n s hl, hit_eq n s hr]
  rw [hfun, bernExp_marker, Finset.prod_insert hmem1, Finset.prod_insert hmem2,
    Finset.prod_pair hnlr]

/-! ## 2. The coincidence scan on an arbitrary latent rate curve -/

/-- The coincidence observable: a hit at `i` when the latent scan fires at both
`i` and `i + 1`. -/
def maHit (n : ℕ) (s : Fin n → Bool) (i : ℕ) : ℝ := hit n s i * hit n s (i + 1)

/-- The coincidence rate at position `i`. -/
def maRate (p : ℕ → ℝ) (i : ℕ) : ℝ := p i * p (i + 1)

/-- Latent scan with constant rate `q`. -/
def constRate (q : ℝ) : ℕ → ℝ := fun _ => q

/-- The coincidence indicator is idempotent. -/
theorem maHit_sq (n : ℕ) (s : Fin n → Bool) (i : ℕ) : maHit n s i * maHit n s i = maHit n s i := by
  unfold maHit
  have h1 := hit_sq n s i
  have h2 := hit_sq n s (i + 1)
  nlinarith [h1, h2]

/-- Marginal rate of the coincidence scan. -/
theorem bernExp_maHit (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi : i < n) (hi1 : i + 1 < n) :
    bernExp n p (fun s => maHit n s i) = maRate p i := by
  unfold maHit maRate
  rw [bernExp_hit_mul n p hi hi1 (by omega)]

/-- **Lag-1 autocovariance of the coincidence scan**, for an arbitrary latent rate
curve: `p i · p (i+1) · p (i+2) · (1 - p (i+1))`, strictly positive whenever the
three rates lie in `(0,1)`. -/
theorem maCov_lag_one (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi2 : i + 2 < n) :
    bernExp n p (fun s => (maHit n s i - maRate p i) * (maHit n s (i + 1) - maRate p (i + 1)))
      = p i * p (i + 1) * p (i + 2) * (1 - p (i + 1)) := by
  have hi : i < n := by omega
  have hi1 : i + 1 < n := by omega
  have hfun : (fun s : Fin n → Bool =>
        (maHit n s i - maRate p i) * (maHit n s (i + 1) - maRate p (i + 1)))
      = fun s => 1 * (hit n s i * (hit n s (i + 1) * hit n s (i + 2)))
          + (-(maRate p (i + 1))) * maHit n s i + (-(maRate p i)) * maHit n s (i + 1)
          + maRate p i * maRate p (i + 1) := by
    funext s
    unfold maHit
    have h2 := hit_sq n s (i + 1)
    have hadd : i + 1 + 1 = i + 2 := by omega
    rw [hadd]
    linear_combination (hit n s i * hit n s (i + 2)) * h2
  rw [hfun, bernExp_comb,
    bernExp_hit_prod3 n p hi hi1 hi2 (by omega) (by omega) (by omega),
    bernExp_maHit n p hi hi1, bernExp_maHit n p hi1 hi2]
  unfold maRate
  have hadd : i + 1 + 1 = i + 2 := by omega
  rw [hadd]
  ring

/-- **All autocovariances at lag `≥ 2` vanish exactly**, for every latent rate
curve: the coincidence scan has dependence range exactly one, and rate
heterogeneity cannot leak into the far lags. -/
theorem maCov_lag_ge_two (n : ℕ) (p : ℕ → ℝ) {i k : ℕ} (hk : 2 ≤ k) (hik : i + k + 1 < n) :
    bernExp n p (fun s => (maHit n s i - maRate p i) * (maHit n s (i + k) - maRate p (i + k)))
      = 0 := by
  have hi : i < n := by omega
  have hi1 : i + 1 < n := by omega
  have hik0 : i + k < n := by omega
  have hfun : (fun s : Fin n → Bool =>
        (maHit n s i - maRate p i) * (maHit n s (i + k) - maRate p (i + k)))
      = fun s => 1 * (hit n s i * (hit n s (i + 1) * (hit n s (i + k) * hit n s (i + k + 1))))
          + (-(maRate p (i + k))) * maHit n s i + (-(maRate p i)) * maHit n s (i + k)
          + maRate p i * maRate p (i + k) := by
    funext s
    unfold maHit
    ring
  rw [hfun, bernExp_comb,
    bernExp_hit_prod4 n p hi hi1 hik0 hik (by omega) (by omega) (by omega)
      (by omega) (by omega) (by omega),
    bernExp_maHit n p hi hi1, bernExp_maHit n p hik0 hik]
  unfold maRate
  ring

/-- Variance of the coincidence indicator. -/
theorem maVar (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi : i < n) (hi1 : i + 1 < n) :
    bernExp n p (fun s => (maHit n s i - maRate p i) * (maHit n s i - maRate p i))
      = maRate p i - maRate p i ^ 2 := by
  have hfun : (fun s : Fin n → Bool => (maHit n s i - maRate p i) * (maHit n s i - maRate p i))
      = fun s => (1 - 2 * maRate p i) * maHit n s i + 0 * maHit n s i + 0 * maHit n s i
          + maRate p i * maRate p i := by
    funext s
    have h := maHit_sq n s i
    nlinarith [h]
  rw [hfun, bernExp_comb, bernExp_maHit n p hi hi1]
  ring

/-! ## 3. Constant latent rate: the one-spike profile -/

/-- **Lag-1 autocorrelation at constant latent rate** is `q / (1 + q)`. -/
theorem maCorr_lag_one_const (n : ℕ) (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) {i : ℕ} (hi2 : i + 2 < n) :
    bernExp n (constRate q) (fun s => (maHit n s i - maRate (constRate q) i)
          * (maHit n s (i + 1) - maRate (constRate q) (i + 1)))
        / bernExp n (constRate q) (fun s => (maHit n s i - maRate (constRate q) i)
          * (maHit n s i - maRate (constRate q) i))
      = q / (1 + q) := by
  have hi : i < n := by omega
  have hi1 : i + 1 < n := by omega
  rw [maCov_lag_one n (constRate q) hi2, maVar n (constRate q) hi hi1]
  unfold constRate maRate
  have hq2 : 0 < q * q := by positivity
  have h1 : q * q < 1 := by nlinarith
  have hgt : 0 < q * q - (q * q) ^ 2 := by
    nlinarith [mul_pos hq2 (by linarith : (0 : ℝ) < 1 - q * q)]
  have hden : q * q - (q * q) ^ 2 ≠ 0 := ne_of_gt hgt
  rw [div_eq_div_iff hden (by linarith : (0 : ℝ) < 1 + q).ne']
  ring

/-- The lag-1 autocorrelation of the coincidence scan is strictly positive and
strictly below `1/2`. -/
theorem maCorr_lag_one_pos (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) :
    0 < q / (1 + q) ∧ q / (1 + q) < 1 / 2 := by
  constructor
  · positivity
  · rw [div_lt_div_iff₀ (by linarith) (by norm_num)]
    linarith

/-! ## 4. Shape identification -/

/-- **A one-spike profile is not Markov.**  A stationary two-state chain has
profile `λ^k`, and `λ² = 0` forces `λ = 0`, hence a zero lag-1 value; so no
`(a, b)` reproduces a profile that is positive at lag 1 and zero at lag 2. -/
theorem ma_not_markov (rho : ℕ → ℝ) (hrho1 : 0 < rho 1) (hrho2 : rho 2 = 0) :
    ¬ ∃ a b : ℝ, 0 < a + b ∧ statRate a b * (1 - statRate a b) ≠ 0 ∧
      ∀ k : ℕ, 1 ≤ k → rho k = markovCorr a b k := by
  rintro ⟨a, b, hab, hpos, hmatch⟩
  have h2 : (0 : ℝ) = lam a b ^ 2 := by
    rw [← hrho2, hmatch 2 (by omega), markovCorr_eq_lambda_pow a b hab hpos]
  have hlam : lam a b = 0 := sq_eq_zero_iff.mp h2.symm
  have h1 : rho 1 = 0 := by
    rw [hmatch 1 le_rfl, markovCorr_eq_lambda_pow a b hab hpos, pow_one, hlam]
  linarith

/-- The lag profile of the coincidence scan anchored at position `i`. -/
noncomputable def maCorrProfile (n : ℕ) (p : ℕ → ℝ) (i k : ℕ) : ℝ :=
  bernExp n p (fun s => (maHit n s i - maRate p i) * (maHit n s (i + k) - maRate p (i + k)))
    / bernExp n p (fun s => (maHit n s i - maRate p i) * (maHit n s i - maRate p i))

theorem maCorrProfile_one_const (n : ℕ) (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) {i : ℕ}
    (hi2 : i + 2 < n) : maCorrProfile n (constRate q) i 1 = q / (1 + q) :=
  maCorr_lag_one_const n q hq0 hq1 hi2

theorem maCorrProfile_ge_two (n : ℕ) (p : ℕ → ℝ) {i k : ℕ} (hk : 2 ≤ k) (hik : i + k + 1 < n) :
    maCorrProfile n p i k = 0 := by
  unfold maCorrProfile
  rw [maCov_lag_ge_two n p hk hik, zero_div]

/-- **The coincidence scan really is outside the Markov family.** -/
theorem ma_scan_not_markov (n : ℕ) (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) {i : ℕ} (hi3 : i + 3 < n) :
    ¬ ∃ a b : ℝ, 0 < a + b ∧ statRate a b * (1 - statRate a b) ≠ 0 ∧
      ∀ k : ℕ, 1 ≤ k → maCorrProfile n (constRate q) i k = markovCorr a b k := by
  refine ma_not_markov (maCorrProfile n (constRate q) i) ?_
    (maCorrProfile_ge_two n (constRate q) le_rfl (by omega))
  rw [maCorrProfile_one_const n q hq0 hq1 (by omega)]
  exact (maCorr_lag_one_pos q hq0 hq1).1

/-- **Trichotomy of profile shapes.**  The first two lags already separate the
three mechanisms: pure density stays below the bar at *both* lags
(`ConsecutiveVDependency.curvature_cannot_fake_H1`), a Markov chain has a nonzero
lag-2 value whenever `λ ≠ 0`, and the coincidence scan has a positive lag-1 value
together with an exactly vanishing lag-2 value. -/
theorem profile_shape_trichotomy (n : ℕ) (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) {i : ℕ}
    (hi3 : i + 3 < n) (a b : ℝ) (hab : 0 < a + b)
    (hpos : statRate a b * (1 - statRate a b) ≠ 0) (hlam : lam a b ≠ 0) :
    (bernExp n (constRate q) (fun s => (maHit n s i - maRate (constRate q) i)
          * (maHit n s (i + 1) - maRate (constRate q) (i + 1))) > 0 ∧
      bernExp n (constRate q) (fun s => (maHit n s i - maRate (constRate q) i)
          * (maHit n s (i + 2) - maRate (constRate q) (i + 2))) = 0) ∧
      markovCorr a b 2 ≠ 0 := by
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · rw [maCov_lag_one n (constRate q) (by omega)]
    unfold constRate
    have h := mul_pos (mul_pos (mul_pos hq0 hq0) hq0) (by linarith : (0 : ℝ) < 1 - q)
    linarith
  · exact maCov_lag_ge_two n (constRate q) le_rfl (by omega)
  · rw [markovCorr_eq_lambda_pow a b hab hpos]
    exact pow_ne_zero 2 hlam

end MovingAverageScan