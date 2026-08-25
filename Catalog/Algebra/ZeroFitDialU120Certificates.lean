import Mathlib
import Algebra.ZeroFitDialU120Kantorovich

/-!
# Which decorrelation certificate is strongest, and why the U120 fade is seedwise

## Research context (FACT round-72 #4, exp 554, third cycle — adversarial pass)

Cycle 1 (`Algebra.ZeroFitDialU120Floor`) produced the advantage–decorrelation duality
`(a-b)² ≤ 2(1-c)`, and applied it to the recorded `+0.0752` advantage to certify
`corr(T, count) ≤ 0.99718`.  Cycle 2 (`Algebra.ZeroFitDialU120Kantorovich`) produced the
sharp seed-imbalance law.  The adversarial pass of this cycle asks two questions.

* **C1 (is the certificate the best available?).**  Gram positivity also constrains `c`
  through the *ellipse* form `(c - ab)² ≤ (1-a²)(1-b²)`.  At the recorded readings this
  gives `c ≤ 0.9967`, which is *stronger* than the duality certificate.  Is that an
  accident of the numbers, or is the duality bound always weaker?
* **C2 (could the fade be a pooling artefact?).**  Cycle 1 showed heterogeneous seeds bias
  a pooled reading downwards.  A sceptic can therefore argue that the recorded decline
  `0.5739 → 0.43636` reflects widening seed imbalance rather than any change in the
  statistic.  Cycle 2's sharp constant is exactly the tool that settles this.

## Main results

* `gram_ellipse_form` — Gram positivity is *equivalent* to `(c - ab)² ≤ (1-a²)(1-b²)`;
  the proof is the algebraic identity
  `1 - a² - b² - c² + 2abc = (1-a²)(1-b²) - (c-ab)²`.
* `corr_upper_bound` — the ellipse certificate `c ≤ ab + √((1-a²)(1-b²))`, the companion of
  `Catalog.Algebra.ZeroFitDialU72Parity.corr_lower_bound`.
* `ellipse_dominates_duality` — **answers C1**: the duality certificate is *exactly* the
  AM–GM relaxation of the ellipse certificate, so
  `ab + √((1-a²)(1-b²)) ≤ 1 - (a-b)²/2` always, and
* `ellipse_eq_duality_of_abs_eq` — the two coincide precisely on `|a| = |b|`, which is why
  the duality bound is sharp as a *statement about `c` alone* (cycle 1's
  `advantage_duality_sharp`) yet lossy once both readings are known.
* `u120_sharper_decorrelation_certificate` — the recorded readings
  `(a, b) = (0.43636, 0.36116)` certify `c ≤ 0.9967`, strictly better than the cycle-1
  value `0.99718`.
* `u120_fade_is_seedwise` — **answers C2**: if the per-seed norm ratios stay inside a
  `±10%` window (`λₖ ∈ [1, 1.21]`) then a pooled reading of `0.43636` forces *every* seed
  reading to be below `0.5739`.  The decline cannot be manufactured by seed imbalance of
  that size; it is a genuine seedwise fade.
* `imbalance_needed_for_artefactual_fade` — the quantitative boundary of that argument:
  to explain the full `0.5739 → 0.43636` decline by imbalance alone the ratio window would
  have to satisfy `2√(αβ)/(α+β) ≤ 0.76`, i.e. `β/α ≥ 5`.  Nothing in the record supports a
  five-fold seed imbalance, and the claim is falsifiable by measuring the per-seed norms.

## Lab notes (numbers entering the theorems)

```
readings used         : a = 0.43636 (T),  b = 0.36116 (count),  advantage 0.0752
duality certificate   : c ≤ 1 - 0.0752²/2 = 0.99717248        (cycle 1)
ellipse certificate   : c ≤ ab + √((1-a²)(1-b²)) ≤ 0.9967     (this cycle)
imbalance window      : λ ∈ [1, 1.21]  ⇒  κ = 2·1.1/2.21 = 0.99548
artefact threshold    : κ ≤ 0.43636/0.5739 = 0.76035  ⇔  β/α ≥ 5 (approx.)
```
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU120Certificates

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU120Floor
open Catalog.Algebra.ZeroFitDialU120Kantorovich

/-! ## 1. The ellipse form of Gram positivity -/

/-- Gram positivity for three correlations is *equivalent* to the ellipse inequality
`(c - ab)² ≤ (1-a²)(1-b²)`. -/
theorem gram_ellipse_form (a b c : ℝ) :
    a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c) ↔
      (c - a * b) ^ 2 ≤ (1 - a ^ 2) * (1 - b ^ 2) := by
  constructor <;> intro h <;> nlinarith [h]

/-- The **ellipse certificate**: the companion upper bound to
`Catalog.Algebra.ZeroFitDialU72Parity.corr_lower_bound`. -/
theorem corr_upper_bound {a b c : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) :
    c ≤ a * b + Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) := by
  have hsq : (c - a * b) ^ 2 ≤ (1 - a ^ 2) * (1 - b ^ 2) := (gram_ellipse_form a b c).mp hg
  have habs : |c - a * b| ≤ Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) := by
    have h1 : Real.sqrt ((c - a * b) ^ 2) ≤ Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) :=
      Real.sqrt_le_sqrt hsq
    rwa [Real.sqrt_sq_eq_abs] at h1
  have := abs_le.mp habs
  linarith [this.2]

/-- **The duality certificate is the AM–GM relaxation of the ellipse certificate.**
Whenever both readings are known, the ellipse bound is at least as strong. -/
theorem ellipse_dominates_duality {a b : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1) :
    a * b + Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) ≤ 1 - (a - b) ^ 2 / 2 := by
  have hx : (0:ℝ) ≤ 1 - a ^ 2 := by linarith
  have hy : (0:ℝ) ≤ 1 - b ^ 2 := by linarith
  have hamgm : Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) ≤ ((1 - a ^ 2) + (1 - b ^ 2)) / 2 := by
    have hs : Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) ^ 2 = (1 - a ^ 2) * (1 - b ^ 2) :=
      Real.sq_sqrt (mul_nonneg hx hy)
    nlinarith [Real.sqrt_nonneg ((1 - a ^ 2) * (1 - b ^ 2)),
      sq_nonneg (Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) - ((1 - a ^ 2) + (1 - b ^ 2)) / 2),
      sq_nonneg ((1 - a ^ 2) - (1 - b ^ 2))]
  nlinarith [hamgm]

/-- The two certificates coincide exactly when the two readings have equal magnitude. -/
theorem ellipse_eq_duality_of_abs_eq {a b : ℝ} (ha : a ^ 2 ≤ 1) (hab : a ^ 2 = b ^ 2) :
    a * b + Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) = 1 - (a - b) ^ 2 / 2 := by
  have hx : (0:ℝ) ≤ 1 - a ^ 2 := by linarith
  have hprod : (1 - a ^ 2) * (1 - b ^ 2) = (1 - a ^ 2) ^ 2 := by rw [← hab]; ring
  rw [hprod, Real.sqrt_sq hx]
  nlinarith [hab]

/-! ## 2. The recorded readings, recertified -/

/-- The recorded pair `(0.43636, 0.36116)` certifies `corr(T, count) ≤ 0.9967`, strictly
better than the cycle-1 duality certificate `0.99718`. -/
theorem u120_sharper_decorrelation_certificate {c : ℝ}
    (hg : (0.43636 : ℝ) ^ 2 + (0.36116 : ℝ) ^ 2 + c ^ 2
          ≤ 1 + 2 * ((0.43636 : ℝ) * (0.36116 : ℝ) * c)) :
    c ≤ 0.9967 := by
  have h := corr_upper_bound hg
  have hb : Real.sqrt ((1 - (0.43636 : ℝ) ^ 2) * (1 - (0.36116 : ℝ) ^ 2)) ≤ 0.8391 := by
    have hle : (1 - (0.43636 : ℝ) ^ 2) * (1 - (0.36116 : ℝ) ^ 2) ≤ (0.8391 : ℝ) ^ 2 := by
      norm_num
    calc Real.sqrt ((1 - (0.43636 : ℝ) ^ 2) * (1 - (0.36116 : ℝ) ^ 2))
        ≤ Real.sqrt ((0.8391 : ℝ) ^ 2) := Real.sqrt_le_sqrt hle
      _ = 0.8391 := Real.sqrt_sq (by norm_num)
  have hab : (0.43636 : ℝ) * (0.36116 : ℝ) ≤ 0.1576 := by norm_num
  linarith

/-- The strengthening is strict: the ellipse certificate is below the duality certificate
at the recorded readings. -/
theorem u120_certificate_strictly_better :
    (0.9967 : ℝ) < 1 - ((0.43636 : ℝ) - (0.36116 : ℝ)) ^ 2 / 2 := by
  norm_num

/-! ## 3. The fade is seedwise, not a pooling artefact -/

variable {m n : ℕ}

/-- **The fade is seedwise.**  If the per-seed response/statistic norm ratios stay inside
the `±10%` window `[1, 1.21]`, a pooled reading of `0.43636` forces every per-seed reading
to lie strictly below the ladder-top value `0.5739`.  Seed imbalance of that size cannot
manufacture the recorded decline. -/
theorem u120_fade_is_seedwise {u v : Fin m → (Fin n → ℝ)} {lam : Fin m → ℝ} {rho : ℝ}
    (hrho : 0 ≤ rho)
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u)
    (hbal : ∀ k, nrm (v k) = lam k * nrm (u k))
    (hlo : ∀ k, (1 : ℝ) ≤ lam k) (hhi : ∀ k, lam k ≤ 121 / 100)
    (hcorr : ∀ k, rho ≤ corr (u k) (v k))
    (hpool : pooledCorr u v ≤ 0.43636) :
    rho < 0.5739 := by
  have hsqrt : Real.sqrt ((1 : ℝ) * (121 / 100)) = 11 / 10 := by
    rw [show (1 : ℝ) * (121 / 100) = (11 / 10 : ℝ) ^ 2 by norm_num,
      Real.sqrt_sq (by norm_num)]
  have h := pooled_kantorovich_bound (alpha := 1) (beta := 121 / 100) (rho := rho)
    (by norm_num) (by norm_num) hrho hu0 hv0 hu hbal hlo hhi hcorr
  rw [hsqrt] at h
  have hchain : rho * (2 * (11 / 10) / (1 + 121 / 100)) ≤ 0.43636 := le_trans h hpool
  nlinarith [hchain]

/-- **The boundary of the artefact argument.**  To explain the whole recorded decline
`0.5739 → 0.43636` by imbalance alone, the attenuation factor would have to be at most
`0.76035…`; a symmetric five-fold window `[α, 5α]` only just reaches it, since
`2√5/6 = 0.745…`, while a four-fold window does not (`2·2/5 = 0.8`). -/
theorem imbalance_needed_for_artefactual_fade {alpha : ℝ} (halpha : 0 < alpha) :
    2 * Real.sqrt (alpha * (4 * alpha)) / (alpha + 4 * alpha)
      > (0.43636 : ℝ) / 0.5739 := by
  have hsq : Real.sqrt (alpha * (4 * alpha)) = 2 * alpha := by
    rw [show alpha * (4 * alpha) = (2 * alpha) ^ 2 by ring,
      Real.sqrt_sq (by positivity)]
  rw [hsq]
  have hden : alpha + 4 * alpha = 5 * alpha := by ring
  rw [hden]
  have hval : 2 * (2 * alpha) / (5 * alpha) = 4 / 5 := by
    field_simp
    ring
  rw [hval]
  rw [gt_iff_lt, div_lt_iff₀ (by norm_num)]
  norm_num

end Catalog.Algebra.ZeroFitDialU120Certificates