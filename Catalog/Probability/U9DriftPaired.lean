/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Why paired controls are the right design: empirical variance of a matched contrast

Context (experiment 569, paper 216).  The band-9 replication draws, for every candidate
value `j² - N`, a *paired* control of the same bit length and the same 3-bit mantissa head,
and runs both through the identical smoothness classifier.  The ledger asserts that control
integrity is then "satisfied by construction".  This file supplies the quantitative content
of that assertion: for the empirical contrast `X - Y` over the realised sample, pairing pays
exactly the covariance.

Main results (all for the empirical, finite-sample functionals over `Fin n`):

* `U9Drift.evar_sub` — the exact decomposition
  `Var(X - Y) = Var X + Var Y - 2 Cov(X, Y)`.
* `U9Drift.ecov_sq_le` — Cauchy–Schwarz for the empirical covariance,
  `Cov(X, Y)² ≤ Var X · Var Y`, hence the contrast variance is never worse than
  `(√Var X + √Var Y)²` and never better than `0`.
* `U9Drift.paired_beats_unpaired_iff` — pairing strictly beats independent sampling exactly
  when the induced covariance is positive.
* `U9Drift.ecov_eq_emean_mul_sub` — the covariance of two indicator sequences is
  `(agreement-on-1 rate) - p·q`: matching helps precisely to the extent that a candidate
  being smooth predicts its matched control being smooth.
* `U9Drift.evar_indicator` — for indicators `Var X = p(1-p)`, so the paired contrast of two
  rare events (`p, q ≈ 3·10⁻⁵`, as at band 9) has variance essentially `p + q - 2·(joint
  rate)`, which the pairing drives down.
* `U9Drift.evar_sub_self` — the degenerate extreme: a perfectly predictive pairing gives a
  zero-variance contrast.
-/

namespace U9Drift

open Finset

variable {n : ℕ}

/-! ## Empirical functionals -/

/-- Empirical mean over the `n` sampled units. -/
noncomputable def emean (f : Fin n → ℝ) : ℝ := (∑ i, f i) / n

/-- Empirical variance over the `n` sampled units. -/
noncomputable def evar (f : Fin n → ℝ) : ℝ := (∑ i, (f i - emean f) ^ 2) / n

/-- Empirical covariance over the `n` sampled units. -/
noncomputable def ecov (f g : Fin n → ℝ) : ℝ :=
  (∑ i, (f i - emean f) * (g i - emean g)) / n

theorem evar_nonneg (f : Fin n → ℝ) : 0 ≤ evar f := by
  apply div_nonneg _ (Nat.cast_nonneg n)
  exact Finset.sum_nonneg fun i _ => sq_nonneg _

theorem evar_eq_ecov_self (f : Fin n → ℝ) : evar f = ecov f f := by
  simp only [evar, ecov]
  congr 1
  exact Finset.sum_congr rfl fun i _ => by ring

theorem emean_sub (f g : Fin n → ℝ) :
    emean (fun i => f i - g i) = emean f - emean g := by
  simp only [emean, Finset.sum_sub_distrib, sub_div]

/-! ## The paired-contrast decomposition -/

/-- **The paired decomposition.**  `Var(X - Y) = Var X + Var Y - 2 Cov(X, Y)`. -/
theorem evar_sub (f g : Fin n → ℝ) :
    evar (fun i => f i - g i) = evar f + evar g - 2 * ecov f g := by
  have key : (∑ i, ((f i - g i) - (emean f - emean g)) ^ 2)
      = (∑ i, (f i - emean f) ^ 2) + (∑ i, (g i - emean g) ^ 2)
        - 2 * ∑ i, (f i - emean f) * (g i - emean g) := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp only [evar, ecov, emean_sub]
  rw [key]
  ring

/-- A perfectly predictive pairing annihilates the contrast. -/
theorem evar_sub_self (f : Fin n → ℝ) : evar (fun i => f i - f i) = 0 := by
  simp [evar, emean]

/-- Cauchy–Schwarz for the empirical covariance. -/
theorem ecov_sq_le (f g : Fin n → ℝ) : ecov f g ^ 2 ≤ evar f * evar g := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i => f i - emean f) (fun i => g i - emean g)
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn
    simp [ecov, evar]
  · have hnR : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
    rw [ecov, evar, evar, div_pow, div_mul_div_comm, ← sq]
    gcongr

/-- Pairing never makes the contrast worse than the unpaired bound by more than the
covariance allows: the contrast variance is at least `(√Var X - √Var Y)²`-type slack. -/
theorem evar_sub_le_of_cov_nonneg {f g : Fin n → ℝ} (h : 0 ≤ ecov f g) :
    evar (fun i => f i - g i) ≤ evar f + evar g := by
  rw [evar_sub]; linarith

/-- **Pairing strictly beats independent sampling exactly when the covariance is
positive.** -/
theorem paired_beats_unpaired_iff (f g : Fin n → ℝ) :
    evar (fun i => f i - g i) < evar f + evar g ↔ 0 < ecov f g := by
  rw [evar_sub]; constructor <;> intro h <;> linarith

/-! ## Indicator sequences: what the matching actually buys -/

theorem sum_eq_card_mul_emean (f : Fin n → ℝ) (hn : 0 < n) :
    ∑ i, f i = (n : ℝ) * emean f := by
  have hnR : ((n : ℝ)) ≠ 0 := by
    have : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
    exact ne_of_gt this
  simp only [emean]
  field_simp

/-- The covariance in product form: `Cov(X, Y) = E[XY] - E[X]E[Y]`. -/
theorem ecov_eq_emean_mul_sub (f g : Fin n → ℝ) (hn : 0 < n) :
    ecov f g = emean (fun i => f i * g i) - emean f * emean g := by
  have hnR : ((n : ℝ)) ≠ 0 := by
    have : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
    exact ne_of_gt this
  have expand : ∀ a b : ℝ, (∑ i, (f i - a) * (g i - b))
      = (∑ i, f i * g i) - b * (∑ i, f i) - a * (∑ i, g i) + (n : ℝ) * (a * b) := by
    intro a b
    rw [Finset.sum_congr rfl (fun i _ => by ring :
      ∀ i ∈ (Finset.univ : Finset (Fin n)), (f i - a) * (g i - b)
        = f i * g i - b * f i - a * g i + a * b)]
    simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  simp only [ecov, emean, expand]
  field_simp
  ring

/-- The empirical variance of an indicator sequence is `p(1-p)`. -/
theorem evar_indicator {f : Fin n → ℝ} (hn : 0 < n) (hf : ∀ i, f i = 0 ∨ f i = 1) :
    evar f = emean f * (1 - emean f) := by
  have hsq : ∀ i, f i * f i = f i := by
    intro i; rcases hf i with h | h <;> rw [h] <;> ring
  rw [evar_eq_ecov_self, ecov_eq_emean_mul_sub f f hn]
  have : (fun i => f i * f i) = f := funext hsq
  rw [this]
  ring

/-- **What the matching buys, for the band-9 design.**  For paired smoothness indicators the
contrast variance is `p(1-p) + q(1-q) - 2(r - pq)` where `r` is the joint smooth rate: every
unit of excess joint smoothness above independence is subtracted twice. -/
theorem evar_sub_indicator {f g : Fin n → ℝ} (hn : 0 < n)
    (hf : ∀ i, f i = 0 ∨ f i = 1) (hg : ∀ i, g i = 0 ∨ g i = 1) :
    evar (fun i => f i - g i)
      = emean f * (1 - emean f) + emean g * (1 - emean g)
        - 2 * (emean (fun i => f i * g i) - emean f * emean g) := by
  rw [evar_sub, evar_indicator hn hf, evar_indicator hn hg, ecov_eq_emean_mul_sub f g hn]

/-- Positive dependence of the matched pair is exactly the condition under which the paired
design has a tighter contrast than an unpaired one. -/
theorem paired_design_gain_iff {f g : Fin n → ℝ} (hn : 0 < n) :
    evar (fun i => f i - g i) < evar f + evar g ↔
      emean f * emean g < emean (fun i => f i * g i) := by
  rw [paired_beats_unpaired_iff, ecov_eq_emean_mul_sub f g hn]
  constructor <;> intro h <;> linarith

end U9Drift