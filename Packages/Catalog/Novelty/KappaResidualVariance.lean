/-
# The exact size of the identity increment: a Lagrange-identity law for κ-sufficiency

## Research context (FACT round-95 #4, exp 606, cycle 2)

`Novelty.KappaSufficiencyScale` proved the *qualitative* dichotomy — composition order κ
is a sufficient statistic for the additive log-rate iff all small primes carry the same
weight — and identified the least-squares slope as the `q(1−q)`-weighted mean of `−w`.
It did not say *how large* the failure is.  Experiment 606 reports exactly that number:
the identity increment is `+0.0071 / +0.0084 / +0.0346` at 72 / 96 / 128 bits, against a
pre-registered `0.02` bar.

This file computes the increment in closed form.  Writing `v p = q p (1 − q p)` for the
Bernoulli variance of the divisibility event at `p`, the variance of the log-rate that the
κ-regression *cannot* explain is

  `residualVariance = (½ ∑_{p,r ∈ B} v p · v r · (w p − w r)²) / (∑_{p ∈ B} v p)`,

a *pairwise weight-spread energy* normalised by the total Bernoulli variance.  So the
sufficiency verdict is not a threshold on a heuristic score: it is the vanishing of a
weighted variance, and it fails precisely as much as the weights are heterogeneous.

## Main results

* `lagrange_identity` — the finite Lagrange/Cauchy–Schwarz identity
  `(∑ v)(∑ v w²) − (∑ v w)² = ½ ∑_p ∑_r v p v r (w p − w r)²`, proved by direct double-sum
  expansion (this is the algebraic engine of everything below).
* `variance_logRate` — `Var Λ = ∑_p w p² v p` under the product cell measure.
* `residualVariance_eq_pairEnergy` — **the closed form** above.
* `residualVariance_nonneg` — the increment is never negative (Cauchy–Schwarz, obtained here
  as a corollary of the identity rather than assumed).
* `residualVariance_eq_zero_iff` — **the sufficiency law**: for nondegenerate marginals the
  increment vanishes *iff* all weights agree, i.e. iff `KappaSufficient B w`.  The
  quantitative and qualitative verdicts therefore coincide exactly.
* `arith_residualVariance_eq_zero_iff` — the same statement for the exact arithmetic cell
  measure `q p = 1/p` of `Novelty.KappaCellPeriod`: over the integers, "cell identity adds
  nothing beyond κ" is *equivalent* to weight homogeneity, with no error term.
* `residual_le_of_spread_le`, `residual_popoviciu_sharp` — a usable bound for the experimental
  protocol, with the sharp Popoviciu constant: weights confined to `[m, Mx]` cap the increment
  at `(∑_p v p)·(Mx − m)²/4`, so a measured increment `g` certifies a weight spread of at least
  `2√(g / ∑_p v p)` — the 128-bit `+0.0346` cannot be produced by a nearly homogeneous weight
  profile.  The constant is attained on a balanced two-prime base, so it cannot be improved.

-- !-- Lab Notes -- !--
-- HYPOTHESIS (cycle 2).  The identity increment should be a *variance of the weights*, not
--   an unstructured residual.
-- EXPERIMENT (`#eval`, B = {2,3,5}, q p = 1/p, exact rationals).  With `w ≡ 0.35` the residual
--   is `0` on the nose.  With a perturbed `w = (0.5, 0.35, 0.2)` the residual is
--   `1017/113800 ≈ 0.008937`, and the pairwise-energy formula
--   `(½ ∑∑ v p v r (w p − w r)²)/∑ v` returns the *same rational*, digit for digit.
-- OUTCOME.  Closed form proved for arbitrary bases and marginals; the equality case gives the
--   exact κ-sufficiency criterion.
-- FAILURE ANALYSIS.  Deriving nonnegativity from a Cauchy–Schwarz lemma first made the
--   equality case awkward (it needs the *strict* case analysis).  Proving the Lagrange identity
--   first and reading both facts off it removed the difficulty entirely.
-/
import Mathlib
import Novelty.KappaSufficiencyScale

open Finset

namespace Catalog.Novelty.KappaResidualVariance

open Catalog.Novelty.KappaCellPeriod
open Catalog.Novelty.KappaSufficiencyScale

variable {B : Finset ℕ} {v w q : ℕ → ℝ} {D : ℝ}

/-! ## 1. The algebraic engine -/

/-- **Lagrange's identity** in the form needed here: the Cauchy–Schwarz defect of the vectors
`√v` and `w√v` is the pairwise energy `½ ∑_{p,r} v p v r (w p − w r)²`. -/
theorem lagrange_identity (B : Finset ℕ) (v w : ℕ → ℝ) :
    (∑ p ∈ B, v p) * (∑ p ∈ B, v p * (w p) ^ 2) - (∑ p ∈ B, v p * w p) ^ 2
      = (1 / 2) * ∑ p ∈ B, ∑ r ∈ B, v p * v r * (w p - w r) ^ 2 := by
  have h1 : (∑ p ∈ B, v p) * (∑ r ∈ B, v r * (w r) ^ 2)
      = ∑ p ∈ B, ∑ r ∈ B, v p * (v r * (w r) ^ 2) := Finset.sum_mul_sum _ _ _ _
  have h2 : (∑ p ∈ B, v p * (w p) ^ 2) * (∑ r ∈ B, v r)
      = ∑ p ∈ B, ∑ r ∈ B, (v p * (w p) ^ 2) * v r := Finset.sum_mul_sum _ _ _ _
  have h3 : (∑ p ∈ B, v p * w p) * (∑ r ∈ B, v r * w r)
      = ∑ p ∈ B, ∑ r ∈ B, (v p * w p) * (v r * w r) := Finset.sum_mul_sum _ _ _ _
  have hrow : ∀ p ∈ B, ∑ r ∈ B, v p * v r * (w p - w r) ^ 2
      = (∑ r ∈ B, v p * (v r * (w r) ^ 2)) + (∑ r ∈ B, (v p * (w p) ^ 2) * v r)
        - 2 * ∑ r ∈ B, (v p * w p) * (v r * w r) := by
    intro p _
    rw [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun r _ => by ring)
  have h4 : ∑ p ∈ B, ∑ r ∈ B, v p * v r * (w p - w r) ^ 2
      = (∑ p ∈ B, ∑ r ∈ B, v p * (v r * (w r) ^ 2))
        + (∑ p ∈ B, ∑ r ∈ B, (v p * (w p) ^ 2) * v r)
        - 2 * ∑ p ∈ B, ∑ r ∈ B, (v p * w p) * (v r * w r) := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl hrow
  rw [h4, ← h1, ← h2, ← h3]
  ring

/-- Nonnegativity of the pairwise energy. -/
theorem pairEnergy_nonneg (hv : ∀ p ∈ B, 0 ≤ v p) :
    0 ≤ ∑ p ∈ B, ∑ r ∈ B, v p * v r * (w p - w r) ^ 2 :=
  Finset.sum_nonneg fun p hp => Finset.sum_nonneg fun r hr =>
    mul_nonneg (mul_nonneg (hv p hp) (hv r hr)) (sq_nonneg _)

/-- The pairwise energy vanishes exactly when the weights are constant on a base with strictly
positive Bernoulli variances. -/
theorem pairEnergy_eq_zero_iff (hv : ∀ p ∈ B, 0 < v p) :
    (∑ p ∈ B, ∑ r ∈ B, v p * v r * (w p - w r) ^ 2) = 0 ↔ ∀ p ∈ B, ∀ r ∈ B, w p = w r := by
  constructor
  · intro h p hp r hr
    have hterm : ∀ x ∈ B, 0 ≤ ∑ y ∈ B, v x * v y * (w x - w y) ^ 2 := fun x hx =>
      Finset.sum_nonneg fun y hy =>
        mul_nonneg (mul_nonneg (hv x hx).le (hv y hy).le) (sq_nonneg _)
    have hrow : ∑ y ∈ B, v p * v y * (w p - w y) ^ 2 = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg hterm).1 h p hp
    have hcell : v p * v r * (w p - w r) ^ 2 = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun y hy =>
        mul_nonneg (mul_nonneg (hv p hp).le (hv y hy).le) (sq_nonneg _))).1 hrow r hr
    have hvp : v p * v r ≠ 0 := ne_of_gt (mul_pos (hv p hp) (hv r hr))
    have : (w p - w r) ^ 2 = 0 := by
      rcases mul_eq_zero.1 hcell with h1 | h2
      · exact absurd h1 hvp
      · exact h2
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
    linarith
  · intro h
    refine Finset.sum_eq_zero (fun p hp => Finset.sum_eq_zero (fun r hr => ?_))
    rw [h p hp r hr]
    ring

/-! ## 2. Variance of the log-rate and the residual -/

lemma Emean_add (f g : Finset ℕ → ℝ) :
    Emean B q (fun S => f S + g S) = Emean B q f + Emean B q g := by
  unfold Emean
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl (fun S _ => by ring)

/-- **Variance of the additive log-rate** under the product cell measure. -/
theorem variance_logRate (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) :
    cov B q (logRate D w) (logRate D w)
      = ∑ p ∈ B, (w p) ^ 2 * (q p * (1 - q p)) := by
  unfold cov
  have hfun : ∀ S ∈ B.powerset, logRate D w S * logRate D w S
      = (D * D + (∑ p ∈ S, w p) * (∑ r ∈ S, w r)) - (2 * D) * (∑ p ∈ S, w p) := by
    intro S _
    simp only [logRate]; ring
  rw [Emean_congr hfun,
    Emean_sub (f := fun S => D * D + (∑ p ∈ S, w p) * (∑ r ∈ S, w r))
      (g := fun S => (2 * D) * (∑ p ∈ S, w p)),
    Emean_add (f := fun _ => D * D) (g := fun S => (∑ p ∈ S, w p) * (∑ r ∈ S, w r)),
    Emean_const, Emean_mul_sums, Emean_const_mul, Emean_sum, Emean_logRate]
  have h2 : ∑ p ∈ B, w p * w p * (q p * (1 - q p))
      = ∑ p ∈ B, (w p) ^ 2 * (q p * (1 - q p)) :=
    Finset.sum_congr rfl (fun p _ => by ring)
  rw [h2]; ring

/-- The part of the log-rate variance that the κ-regression cannot explain: the *identity
increment* of experiment 606. -/
noncomputable def residualVariance (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) : ℝ :=
  cov B q (logRate D w) (logRate D w)
    - (cov B q (logRate D w) (fun S => (S.card : ℝ))) ^ 2
      / cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ))

/-- **Closed form for the identity increment.**  It is the pairwise weight-spread energy,
normalised by the total Bernoulli variance of the base. -/
theorem residualVariance_eq_pairEnergy (hden : ∑ p ∈ B, q p * (1 - q p) ≠ 0) :
    residualVariance B q D w
      = ((1 / 2) * ∑ p ∈ B, ∑ r ∈ B,
            (q p * (1 - q p)) * (q r * (1 - q r)) * (w p - w r) ^ 2)
        / ∑ p ∈ B, q p * (1 - q p) := by
  classical
  have hlag := lagrange_identity B (fun p => q p * (1 - q p)) w
  simp only [] at hlag
  have hnum : ∑ p ∈ B, w p * (q p * (1 - q p)) = ∑ p ∈ B, (q p * (1 - q p)) * w p :=
    Finset.sum_congr rfl (fun p _ => mul_comm _ _)
  have hvar : ∑ p ∈ B, (w p) ^ 2 * (q p * (1 - q p))
      = ∑ p ∈ B, (q p * (1 - q p)) * (w p) ^ 2 :=
    Finset.sum_congr rfl (fun p _ => mul_comm _ _)
  unfold residualVariance
  rw [variance_logRate, cov_logRate_kappa, variance_kappa, hvar, hnum,
    eq_div_iff hden, sub_mul, div_mul_cancel₀ _ hden]
  linear_combination hlag

/-- **The identity increment is never negative** — Cauchy–Schwarz, read off the identity. -/
theorem residualVariance_nonneg (hv : ∀ p ∈ B, 0 ≤ q p * (1 - q p))
    (hden : 0 < ∑ p ∈ B, q p * (1 - q p)) : 0 ≤ residualVariance B q D w := by
  rw [residualVariance_eq_pairEnergy (ne_of_gt hden)]
  refine div_nonneg ?_ hden.le
  have := pairEnergy_nonneg (B := B) (v := fun p => q p * (1 - q p)) (w := w) hv
  linarith

/-- **The sufficiency law.**  For nondegenerate marginals the identity increment vanishes
exactly when composition order is a sufficient statistic. -/
theorem residualVariance_eq_zero_iff (hv : ∀ p ∈ B, 0 < q p * (1 - q p))
    (hden : 0 < ∑ p ∈ B, q p * (1 - q p)) :
    residualVariance B q D w = 0 ↔ KappaSufficient B w := by
  rw [residualVariance_eq_pairEnergy (ne_of_gt hden), kappaSufficient_iff_constant_weights,
    div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · have h0 : (∑ p ∈ B, ∑ r ∈ B,
          (q p * (1 - q p)) * (q r * (1 - q r)) * (w p - w r) ^ 2) = 0 := by linarith
      exact (pairEnergy_eq_zero_iff (v := fun p => q p * (1 - q p)) hv).1 h0
    · exact absurd h (ne_of_gt hden)
  · intro h
    left
    rw [(pairEnergy_eq_zero_iff (v := fun p => q p * (1 - q p)) hv).2 h]
    ring

/-! ## 3. The arithmetic instance and an experimental bound -/

/-- Over the exact arithmetic cell measure of a nonempty prime base, every Bernoulli variance
`(1/p)(1 − 1/p)` is strictly positive. -/
theorem arith_v_pos (hB : ∀ p ∈ B, Nat.Prime p) {p : ℕ} (hp : p ∈ B) :
    0 < (1 / (p : ℝ)) * (1 - 1 / (p : ℝ)) := by
  have h2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast (hB p hp).two_le
  have hp0 : (0 : ℝ) < p := by linarith
  have hhalf : 1 / (p : ℝ) ≤ 1 / 2 := one_div_le_one_div_of_le (by norm_num) h2
  have h1 : 0 < 1 / (p : ℝ) := by positivity
  nlinarith

/-- **Sufficiency over the integers.**  For the exact one-period distribution of small-prime
cells (`Novelty.KappaCellPeriod.cellFiber_density`), cell identity adds nothing beyond κ *iff*
all small primes carry the same composition penalty. -/
theorem arith_residualVariance_eq_zero_iff (hB : ∀ p ∈ B, Nat.Prime p) (hne : B.Nonempty) :
    residualVariance B (fun p => 1 / (p : ℝ)) D w = 0 ↔ KappaSufficient B w :=
  residualVariance_eq_zero_iff (fun _p hp => arith_v_pos hB hp) (arith_variance_pos hB hne)

/-- **A protocol bound (Popoviciu form, sharp).**  Weights confined to `[m, Mx]` cap the
identity increment at `(∑_p v p)·(Mx − m)²/4`; contrapositively a measured increment `g`
certifies a weight spread of at least `2√(g / ∑_p v p)`.  Equality holds for a two-prime base
with equal Bernoulli variances and weights at the two endpoints, so the constant `1/4` cannot
be improved. -/
theorem residual_le_of_spread_le (hv : ∀ p ∈ B, 0 ≤ q p * (1 - q p))
    (hden : 0 < ∑ p ∈ B, q p * (1 - q p)) (hlo : ∀ p ∈ B, m ≤ w p) (hhi : ∀ p ∈ B, w p ≤ Mx) :
    residualVariance B q D w
      ≤ (∑ p ∈ B, q p * (1 - q p)) * (Mx - m) ^ 2 / 4 := by
  classical
  -- recentre the weights at the midpoint of their range
  set c : ℝ := (m + Mx) / 2 with hc
  set z : ℕ → ℝ := fun p => w p - c with hz
  have hdiff : ∀ p r : ℕ, w p - w r = z p - z r := by intro p r; rw [hz]; ring
  have hlagz := lagrange_identity B (fun p => q p * (1 - q p)) z
  simp only [] at hlagz
  have henergy : (1 / 2) * ∑ p ∈ B, ∑ r ∈ B,
        (q p * (1 - q p)) * (q r * (1 - q r)) * (w p - w r) ^ 2
      = (∑ p ∈ B, q p * (1 - q p)) * (∑ p ∈ B, (q p * (1 - q p)) * (z p) ^ 2)
        - (∑ p ∈ B, (q p * (1 - q p)) * z p) ^ 2 := by
    have hcongr : ∑ p ∈ B, ∑ r ∈ B, (q p * (1 - q p)) * (q r * (1 - q r)) * (w p - w r) ^ 2
        = ∑ p ∈ B, ∑ r ∈ B, (q p * (1 - q p)) * (q r * (1 - q r)) * (z p - z r) ^ 2 :=
      Finset.sum_congr rfl (fun p _ => Finset.sum_congr rfl (fun r _ => by rw [hdiff p r]))
    rw [hcongr, ← hlagz]
  -- each recentred weight is within half the spread of `0`
  have hzsq : ∀ p ∈ B, (q p * (1 - q p)) * (z p) ^ 2
      ≤ (q p * (1 - q p)) * ((Mx - m) ^ 2 / 4) := by
    intro p hp
    have h1 := hlo p hp
    have h2 := hhi p hp
    have hzb : (z p) ^ 2 ≤ (Mx - m) ^ 2 / 4 := by
      rw [hz, hc]
      nlinarith [sq_nonneg (w p - (m + Mx) / 2)]
    exact mul_le_mul_of_nonneg_left hzb (hv p hp)
  have hzsum : ∑ p ∈ B, (q p * (1 - q p)) * (z p) ^ 2
      ≤ (∑ p ∈ B, q p * (1 - q p)) * ((Mx - m) ^ 2 / 4) := by
    calc ∑ p ∈ B, (q p * (1 - q p)) * (z p) ^ 2
        ≤ ∑ p ∈ B, (q p * (1 - q p)) * ((Mx - m) ^ 2 / 4) := Finset.sum_le_sum hzsq
      _ = (∑ p ∈ B, q p * (1 - q p)) * ((Mx - m) ^ 2 / 4) := by rw [Finset.sum_mul]
  rw [residualVariance_eq_pairEnergy (ne_of_gt hden), div_le_div_iff₀ hden (by norm_num : (0:ℝ) < 4)]
  rw [henergy]
  nlinarith [hzsum, hden, sq_nonneg (∑ p ∈ B, (q p * (1 - q p)) * z p)]

/-- **The Popoviciu constant `1/4` is attained.**  On a two-prime base with balanced marginals
the identity increment equals `(∑_p v p)·(w p − w r)²/4` exactly, so `residual_le_of_spread_le`
cannot be improved. -/
theorem residual_popoviciu_sharp {p r : ℕ} (hpr : p ≠ r) (q w : ℕ → ℝ) (D : ℝ)
    (hqp : q p = 1 / 2) (hqr : q r = 1 / 2) :
    residualVariance {p, r} q D w
      = (∑ x ∈ ({p, r} : Finset ℕ), q x * (1 - q x)) * (w p - w r) ^ 2 / 4 := by
  classical
  have hsum : ∑ x ∈ ({p, r} : Finset ℕ), q x * (1 - q x) = 1 / 2 := by
    rw [Finset.sum_pair hpr, hqp, hqr]; norm_num
  have hden : ∑ x ∈ ({p, r} : Finset ℕ), q x * (1 - q x) ≠ 0 := by
    rw [hsum]; norm_num
  rw [residualVariance_eq_pairEnergy hden, hsum]
  rw [Finset.sum_pair hpr, Finset.sum_pair hpr, Finset.sum_pair hpr, hqp, hqr]
  ring

end Catalog.Novelty.KappaResidualVariance