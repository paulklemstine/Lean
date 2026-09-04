/-
# The κ-regression residual: orthogonality and the variance decomposition

## Research context (FACT round-95 #4, exp 606, cycle 5)

`Novelty.KappaResidualVariance` calls the quantity `Var Λ − Cov(Λ,κ)²/Var κ` the *identity
increment* and computes it in closed form.  That name is only earned if the quantity really is
the variance of what the κ-regression leaves behind.  This file proves it.

For the product cell measure we build the fitted line explicitly — slope `olsSlope`, intercept
`olsIntercept` — and show that the residual `R = Λ − (α + β·κ)` is

* **centred**: `E R = 0`,
* **orthogonal to κ**: `Cov(R, κ) = 0` (this is what makes the fit least-squares), and
* **exactly the increment**: `Var R = residualVariance`,

whence the Pythagorean decomposition `Var Λ = β²·Var κ + Var R`: the κ-explained variance and
the identity increment add up to the total, with no cross term.  Combined with
`residualVariance_eq_pairEnergy` this says the experiment's `R²`-style bookkeeping is exact:
the fraction of the log-rate variance explained by composition order is
`β²·Var κ / Var Λ`, and the remainder is a pairwise weight-spread energy.

## Main results

* `cov_sub_left`, `cov_const_left`, `cov_const_mul_left`, `cov_comm` — bilinearity of the
  covariance functional of the product cell measure (proved, not assumed).
* `Emean_olsResidual` — the residual is centred.
* `cov_olsResidual_kappa` — **orthogonality**: the residual is uncorrelated with κ.
* `variance_olsResidual` — the residual variance *is* `residualVariance`.
* `variance_decomposition` — `Var Λ = β²·Var κ + Var R`.
* `explained_fraction_eq` — the explained fraction equals `1 − residualVariance/Var Λ`, so a
  reported increment converts directly into an `R²`.

-- !-- Lab Notes -- !--
-- HYPOTHESIS (cycle 5).  The quantity named "identity increment" in cycle 2 is the variance of
--   the least-squares residual, not merely an algebraic expression resembling one.
-- EXPERIMENT (`#eval`, exact rationals, B = {2,3,5}, q p = 1/p, w = (0.5, 0.35, 0.2)):
--   `E R = 0`, `Cov(R, κ) = 0`, `Var R = 1017/113800` — identical to the cycle-2 residual and
--   to the pairwise-energy formula.  With `w ≡ 0.35` all three vanish.
-- OUTCOME.  Centring, orthogonality and the Pythagorean decomposition proved for arbitrary
--   bases and marginals; the naming of `residualVariance` is now justified.
-- FAILURE ANALYSIS.  Attempting the decomposition directly on `Emean` expansions produced
--   unmanageable goals; isolating four bilinearity lemmas for `cov` first made every proof a
--   two-line `field_simp`/`ring` computation.
-/
import Mathlib
import Novelty.KappaResidualVariance

open Finset

namespace Catalog.Novelty.KappaOlsResidual

open Catalog.Novelty.KappaSufficiencyScale
open Catalog.Novelty.KappaResidualVariance

variable {B : Finset ℕ} {q w : ℕ → ℝ} {D : ℝ}

/-! ## 1. Bilinearity of the covariance functional -/

theorem cov_sub_left (f g h : Finset ℕ → ℝ) :
    cov B q (fun S => f S - g S) h = cov B q f h - cov B q g h := by
  unfold cov
  have h1 : Emean B q (fun S => (f S - g S) * h S)
      = Emean B q (fun S => f S * h S) - Emean B q (fun S => g S * h S) := by
    rw [← Emean_sub]
    exact Emean_congr (fun S _ => by ring)
  rw [h1, Emean_sub]
  ring

theorem cov_const_left (a : ℝ) (h : Finset ℕ → ℝ) : cov B q (fun _ => a) h = 0 := by
  unfold cov
  have h1 : Emean B q (fun S => a * h S) = a * Emean B q h := Emean_const_mul a h
  rw [h1, Emean_const]
  ring

theorem cov_const_mul_left (a : ℝ) (f h : Finset ℕ → ℝ) :
    cov B q (fun S => a * f S) h = a * cov B q f h := by
  unfold cov
  have h1 : Emean B q (fun S => (a * f S) * h S) = a * Emean B q (fun S => f S * h S) := by
    rw [← Emean_const_mul]
    exact Emean_congr (fun S _ => by ring)
  rw [h1, Emean_const_mul]
  ring

theorem Emean_affine (a b : ℝ) (g : Finset ℕ → ℝ) :
    Emean B q (fun S => a + b * g S) = a + b * Emean B q g := by
  have hterm : ∀ S ∈ B.powerset, cellProb B q S * (a + b * g S)
      = a * cellProb B q S + b * (cellProb B q S * g S) := fun S _ => by ring
  rw [Emean, Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.mul_sum,
    ← Finset.mul_sum, sum_cellProb, mul_one]
  rfl

theorem cov_affine_left (a b : ℝ) (g h : Finset ℕ → ℝ) :
    cov B q (fun S => a + b * g S) h = b * cov B q g h := by
  unfold cov
  have h1 : Emean B q (fun S => (a + b * g S) * h S)
      = a * Emean B q h + b * Emean B q (fun S => g S * h S) := by
    rw [Emean_congr (g := fun S => a * h S + b * (g S * h S)) (fun S _ => by ring),
      Emean_add, Emean_const_mul, Emean_const_mul]
  rw [h1, Emean_affine]
  ring

theorem cov_comm (f g : Finset ℕ → ℝ) : cov B q f g = cov B q g f := by
  unfold cov
  rw [Emean_congr (f := fun S => f S * g S) (g := fun S => g S * f S) (fun S _ => mul_comm _ _)]
  ring

theorem cov_sub_right (f g h : Finset ℕ → ℝ) :
    cov B q f (fun S => g S - h S) = cov B q f g - cov B q f h := by
  rw [cov_comm, cov_sub_left, cov_comm (f := g), cov_comm (f := h)]

theorem cov_const_right (a : ℝ) (f : Finset ℕ → ℝ) : cov B q f (fun _ => a) = 0 := by
  rw [cov_comm, cov_const_left]

theorem cov_const_mul_right (a : ℝ) (f h : Finset ℕ → ℝ) :
    cov B q f (fun S => a * h S) = a * cov B q f h := by
  rw [cov_comm, cov_const_mul_left, cov_comm (f := h)]

theorem cov_affine_right (a b : ℝ) (f g : Finset ℕ → ℝ) :
    cov B q f (fun S => a + b * g S) = b * cov B q f g := by
  rw [cov_comm, cov_affine_left, cov_comm (f := g)]

/-! ## 2. The fitted line and its residual -/

/-- The intercept of the least-squares fit of the log-rate on the composition order. -/
noncomputable def olsIntercept (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) : ℝ :=
  Emean B q (logRate D w) - olsSlope B q D w * Emean B q (fun S => (S.card : ℝ))

/-- The residual of the κ-regression: what cell identity still has to explain. -/
noncomputable def olsResidual (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ)
    (S : Finset ℕ) : ℝ :=
  logRate D w S - (olsIntercept B q D w + olsSlope B q D w * (S.card : ℝ))

/-- **The residual is centred.** -/
theorem Emean_olsResidual (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) :
    Emean B q (olsResidual B q D w) = 0 := by
  unfold olsResidual
  rw [Emean_sub, Emean_affine, olsIntercept]
  ring

/-- **Orthogonality.**  The residual of the least-squares fit is uncorrelated with the
composition order — the defining property of the fit. -/
theorem cov_olsResidual_kappa (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ)
    (hV : cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ)) ≠ 0) :
    cov B q (olsResidual B q D w) (fun S => (S.card : ℝ)) = 0 := by
  unfold olsResidual
  rw [cov_sub_left, cov_affine_left, olsSlope]
  field_simp
  ring

/-- **The residual variance is exactly the identity increment.** -/
theorem variance_olsResidual (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ)
    (hV : cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ)) ≠ 0) :
    cov B q (olsResidual B q D w) (olsResidual B q D w) = residualVariance B q D w := by
  -- expand the right argument first, using orthogonality to kill the κ-part
  have hright : cov B q (olsResidual B q D w) (olsResidual B q D w)
      = cov B q (olsResidual B q D w) (logRate D w) := by
    have h := cov_sub_right (B := B) (q := q) (olsResidual B q D w) (logRate D w)
      (fun S => olsIntercept B q D w + olsSlope B q D w * ((S.card : ℝ)))
    rw [cov_affine_right, cov_olsResidual_kappa B q D w hV, mul_zero, sub_zero] at h
    exact h
  rw [hright]
  unfold olsResidual
  rw [cov_sub_left, cov_affine_left, residualVariance, olsSlope]
  rw [cov_comm (f := fun S : Finset ℕ => ((S.card : ℝ))) (g := logRate D w)]
  field_simp

/-- **Pythagorean variance decomposition.**  The κ-explained variance and the identity
increment sum to the total log-rate variance, with no cross term. -/
theorem variance_decomposition (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ)
    (hV : cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ)) ≠ 0) :
    cov B q (logRate D w) (logRate D w)
      = (olsSlope B q D w) ^ 2 * cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ))
        + cov B q (olsResidual B q D w) (olsResidual B q D w) := by
  rw [variance_olsResidual B q D w hV, residualVariance, olsSlope]
  field_simp
  ring

/-- **The explained fraction.**  With a nondegenerate log-rate variance, the share of the
variance captured by composition order is `1 − increment / Var Λ`. -/
theorem explained_fraction_eq (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ)
    (hV : cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ)) ≠ 0)
    (hL : cov B q (logRate D w) (logRate D w) ≠ 0) :
    (olsSlope B q D w) ^ 2 * cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ))
        / cov B q (logRate D w) (logRate D w)
      = 1 - residualVariance B q D w / cov B q (logRate D w) (logRate D w) := by
  have hdec := variance_decomposition B q D w hV
  rw [variance_olsResidual B q D w hV] at hdec
  field_simp
  linarith [hdec]

end Catalog.Novelty.KappaOlsResidual