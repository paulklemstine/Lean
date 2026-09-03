import Bridges.Ma1EffectiveQuadraticPrice

/-!
# Sharpness of the quadratic information price

Sixth cycle of the MA-1 effectivization loop.  Cycle 5
(`Bridges.Ma1EffectiveQuadraticPrice`) proves that the information price of the
equidistribution assumption is *at most* quadratic in the certificate:
`D(p‖u) ≤ (2ε/(1−ε))²` at one scale and `16ε₀²/(1−ρ²)` over all dyadic scales.  The direction
recorded there ("Matching Lower Bound for the Quadratic Information Price") asks whether the
exponent `2` is exact or merely an artefact of the proof.  It is exact.

* `log_ge_one_sub_inv` — the reverse form `1 − 1/y ≤ log y` of `log t ≤ t − 1`.
* `kl_two_class_ge` — for a saturated two-class certificate the divergence obeys the *lower*
  bound `t²/4 ≤ D(p‖u)`.  The proof avoids all calculus: writing `A = log(1+t)` and
  `B = log(1−t)`, the divergence is `((A+B) + t(A−B))/2`, and the two reverse logarithm
  bounds applied to `1−t²` and to `(1+t)/(1−t)` give `A + B ≥ −t²/(1−t²)` and
  `A − B ≥ 2t/(1+t)`, which already suffice for `t ≤ 1/4`.
* `quadratic_price_exponent_sharp` — hence for every `ε ∈ (0, 1/4]` and every target `μ > 0`
  there is a genuine `ε`-certificate whose information price is at least `ε²/4`.  Combined
  with `kl_le_sixteen_eps_sq` the price of a saturated certificate is pinned between `ε²/4`
  and `16ε²`: the exponent is exactly `2` and only the constant is negotiable.
* `no_cubic_price_bound` — the sharp corollary: no bound of the form `D(p‖u) ≤ C·ε³` can hold
  for all certificates, whatever the constant `C`.  So the quadratic improvement of cycle 5
  cannot itself be improved to a cubic one.
-/

namespace Ma1Effective

open Finset

/-! ## A reverse logarithm bound -/

/-- The reverse form of `log t ≤ t − 1`: for `y > 0` one has `1 − 1/y ≤ log y`. -/
theorem log_ge_one_sub_inv {y : ℝ} (hy : 0 < y) : 1 - 1 / y ≤ Real.log y := by
  have hinv : 0 < 1 / y := by positivity
  have h := Real.log_le_sub_one_of_pos hinv
  rw [one_div, Real.log_inv] at h
  rw [one_div]
  linarith

/-! ## The two-class lower bound -/

/-- The saturated two-class probability vector: one class at `(1+t)/2`, the other at
`(1−t)/2`. -/
noncomputable def twoClassDist (t : ℝ) : Fin 2 → ℝ := ![(1 + t) / 2, (1 - t) / 2]

/-- **The quadratic lower bound.**  A saturated two-class certificate with deviation `t ≤ 1/4`
costs at least `t²/4` nats: the information price really is quadratic, not smaller. -/
theorem kl_two_class_ge {t : ℝ} (ht0 : 0 ≤ t) (ht : t ≤ 1 / 4) :
    t ^ 2 / 4 ≤ klFromUniform (twoClassDist t) := by
  have h1p : (0 : ℝ) < 1 + t := by linarith
  have h1m : (0 : ℝ) < 1 - t := by linarith
  have hsq : (0 : ℝ) < 1 - t ^ 2 := by nlinarith
  -- the divergence in terms of the two logarithms
  have hkl : klFromUniform (twoClassDist t)
      = (1 + t) / 2 * Real.log (1 + t) + (1 - t) / 2 * Real.log (1 - t) := by
    unfold klFromUniform twoClassDist
    rw [Fin.sum_univ_two]
    norm_num
    rw [show (2 : ℝ) * ((1 + t) / 2) = 1 + t by ring,
      show (2 : ℝ) * ((1 - t) / 2) = 1 - t by ring]
  -- `A + B = log (1 − t²)` and `A − B = log ((1+t)/(1−t))`
  have hsum : Real.log (1 + t) + Real.log (1 - t) = Real.log (1 - t ^ 2) := by
    rw [← Real.log_mul (ne_of_gt h1p) (ne_of_gt h1m)]
    ring_nf
  have hdiff : Real.log (1 + t) - Real.log (1 - t) = Real.log ((1 + t) / (1 - t)) := by
    rw [Real.log_div (ne_of_gt h1p) (ne_of_gt h1m)]
  -- the two reverse logarithm bounds
  have hS : -t ^ 2 / (1 - t ^ 2) ≤ Real.log (1 + t) + Real.log (1 - t) := by
    have h := log_ge_one_sub_inv hsq
    rw [hsum]
    have hrw : 1 - 1 / (1 - t ^ 2) = -t ^ 2 / (1 - t ^ 2) := by
      field_simp
      ring
    rw [← hrw]
    exact h
  have hD : 2 * t / (1 + t) ≤ Real.log (1 + t) - Real.log (1 - t) := by
    have hpos : (0 : ℝ) < (1 + t) / (1 - t) := by positivity
    have h := log_ge_one_sub_inv hpos
    rw [hdiff]
    have hrw : 1 - 1 / ((1 + t) / (1 - t)) = 2 * t / (1 + t) := by
      field_simp
      ring
    rw [← hrw]
    exact h
  -- combine the two bounds
  have hcomb : (-t ^ 2 / (1 - t ^ 2)) / 2 + t * (2 * t / (1 + t)) / 2
      ≤ (1 + t) / 2 * Real.log (1 + t) + (1 - t) / 2 * Real.log (1 - t) := by
    have h2 := mul_le_mul_of_nonneg_left hD ht0
    have hexp : (1 + t) / 2 * Real.log (1 + t) + (1 - t) / 2 * Real.log (1 - t)
        = (Real.log (1 + t) + Real.log (1 - t)) / 2
          + t * (Real.log (1 + t) - Real.log (1 - t)) / 2 := by ring
    rw [hexp]
    linarith
  -- and evaluate the resulting rational function
  have hnum : t ^ 2 / 4 ≤ (-t ^ 2 / (1 - t ^ 2)) / 2 + t * (2 * t / (1 + t)) / 2 := by
    have hE : (-t ^ 2 / (1 - t ^ 2)) / 2 + t * (2 * t / (1 + t)) / 2 - t ^ 2 / 4
        = t ^ 2 * (1 - 4 * t + t ^ 2) / (4 * (1 - t ^ 2)) := by
      field_simp
      ring
    have hEnn : 0 ≤ t ^ 2 * (1 - 4 * t + t ^ 2) / (4 * (1 - t ^ 2)) := by
      apply div_nonneg
      · nlinarith [sq_nonneg t]
      · linarith
    linarith
  rw [hkl]
  linarith

/-! ## Sharpness of the exponent -/

/-- **The exponent is exact.**  For every deviation `ε ∈ (0, 1/4]` and every target `μ > 0`
there is a count vector satisfying the `ε`-certificate whose information price is at least
`ε²/4`.  Together with `kl_le_sixteen_eps_sq` this pins the price of a saturated certificate
between `ε²/4` and `16ε²`. -/
theorem quadratic_price_exponent_sharp {ε μ : ℝ} (hε0 : 0 < ε) (hε : ε ≤ 1 / 4) (hμ : 0 < μ) :
    ∃ N : Fin 2 → ℝ, EquiCert N μ ε ∧ ε ^ 2 / 4 ≤ klFromUniform (classDist N) := by
  refine ⟨![(1 + ε) * μ, (1 - ε) * μ], ?_, ?_⟩
  · intro i
    fin_cases i
    · show |(1 + ε) * μ - μ| ≤ ε * μ
      rw [show (1 + ε) * μ - μ = ε * μ by ring, abs_of_nonneg (by positivity)]
    · show |(1 - ε) * μ - μ| ≤ ε * μ
      rw [show (1 - ε) * μ - μ = -(ε * μ) by ring, abs_neg, abs_of_nonneg (by positivity)]
  · have hclass : classDist ![(1 + ε) * μ, (1 - ε) * μ] = twoClassDist ε := by
      funext i
      unfold classDist twoClassDist
      rw [Fin.sum_univ_two]
      fin_cases i
      · show (1 + ε) * μ / ((1 + ε) * μ + (1 - ε) * μ) = (1 + ε) / 2
        rw [show (1 + ε) * μ + (1 - ε) * μ = 2 * μ by ring]
        field_simp
      · show (1 - ε) * μ / ((1 + ε) * μ + (1 - ε) * μ) = (1 - ε) / 2
        rw [show (1 + ε) * μ + (1 - ε) * μ = 2 * μ by ring]
        field_simp
    rw [hclass]
    exact kl_two_class_ge (le_of_lt hε0) hε

/-- **No cubic improvement.**  Whatever the constant `C`, the bound `D(p‖u) ≤ C·ε³` fails for
some genuine certificate: the quadratic price of cycle 5 cannot be sharpened to a cubic one. -/
theorem no_cubic_price_bound (C : ℝ) :
    ∃ (ε : ℝ) (N : Fin 2 → ℝ), 0 < ε ∧ EquiCert N 1 ε ∧
      C * ε ^ 3 < klFromUniform (classDist N) := by
  have hC : (0 : ℝ) < |C| + 1 := by positivity
  set ε : ℝ := min (1 / 4) (1 / (8 * (|C| + 1))) with hεdef
  have hε0 : 0 < ε := lt_min (by norm_num) (by positivity)
  have hε4 : ε ≤ 1 / 4 := min_le_left _ _
  have hεC : ε ≤ 1 / (8 * (|C| + 1)) := min_le_right _ _
  obtain ⟨N, hcert, hkl⟩ := quadratic_price_exponent_sharp hε0 hε4 (by norm_num : (0:ℝ) < 1)
  refine ⟨ε, N, hε0, hcert, ?_⟩
  have hCle : C * ε ^ 3 ≤ |C| * ε ^ 3 := by
    have hle := le_abs_self C
    nlinarith [pow_pos hε0 3]
  have hkey : |C| * ε ^ 3 < ε ^ 2 / 4 := by
    have hmul : |C| * ε ≤ 1 / 8 := by
      rw [le_div_iff₀ (by positivity : (0:ℝ) < 8 * (|C| + 1))] at hεC
      nlinarith [abs_nonneg C]
    nlinarith [pow_pos hε0 2, hε0]
  linarith

end Ma1Effective