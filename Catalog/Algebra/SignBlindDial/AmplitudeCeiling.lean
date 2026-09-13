/-
# A universal ceiling for the sign-blind ambiguity

Sixth cycle of the `EXTENDED-DIAL-ABSENT` investigation.  Cycle five
(`Algebra.SignBlindDial.AmbiguityAmplitude`) showed that the harm done by a sign-blind
dashboard is *quantised*: two populations with identical dial readings either report the same
increment, or increments differing by exactly

`A = 4·√(R²(x,y)·R²(x,z)·R²(z,y)) / (1 − R²(x,z))`,

and it exhibited a two-parameter family in which `A` reaches `16/17`.  That left the obvious
question open: is `A` bounded at all over *arbitrary* populations?  The formula alone gives
no bound — as a function of three free numbers in `[0,1)` it is unbounded (take all three
readings close to `1`).  The missing ingredient is that a triple of readings, *together with
a sign-flipped partner realising the same readings*, is heavily constrained: it must satisfy
the Gram (positive-semidefiniteness) inequality of the three-variable correlation matrix for
*both* signs of the triple product.

This file proves that constraint from the catalog's Cauchy–Schwarz inequality and derives the
sharp ceiling.

Main results.

* `total_share_le_one` — the base share plus the increment never exceeds the whole rate
  variance: `R²(x,y) + ΔR² ≤ 1`.  (Cauchy–Schwarz on the partialled feature.)
* `correlation_det_nonneg` — hence the correlation Gram determinant is nonnegative:
  `1 − R²(x,y) − R²(x,z) − R²(z,y) + 2P ≥ 0`, where `P = ρ_xy ρ_xz ρ_zy`.
* `amplitude_ceiling_algebraic` — the sharp algebraic consequence: under that constraint the
  amplitude is at most `2√e/(1 + √e)`, where `e = R²(x,z)`.
* `sign_blind_amplitude_universal_ceiling` — **the ceiling**: for any two finite populations
  with identical dial readings and opposite triple-product signs, the increments differ by at
  most `2√(R²(x,z))/(1 + √(R²(x,z))) < 1`.  A sign-blind dashboard can therefore never
  misattribute *more* than the whole rate variance, and the deficit is governed entirely by
  the footprint–feature collinearity reading.
* `masking_amplitude_family_lt_one` — the explicit family of cycle five obeys the ceiling,
  with the ceiling being strictly larger than the family's `16/17` unless the collinearity
  reading is extreme.
-/
import Algebra.SignBlindDial.AmbiguityAmplitude

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

variable {ι : Type*} [Fintype ι]

/-! ## 1. The total explained share is at most one -/

/-- **No population explains more than all of its variance.**  The base dial reading plus the
increment contributed by the extra feature is at most `1`.  This is Cauchy–Schwarz applied to
the residual and the partialled feature, fed through the catalog's exact increment identity
`partial_gain_identity`. -/
theorem total_share_le_one {p x y r zt : ι → ℝ} {a b : ℝ} (hp0 : ∀ i, 0 ≤ p i)
    (hp : ∑ i, p i = 1) (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r)
    (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hrr : 0 < wip p r r)
    (hzt : 0 < wip p zt zt) :
    R2 p x y + pgain p r zt / wvar p y ≤ 1 := by
  have hid := partial_gain_identity hp hy hr hvx hvy hrr hzt
  have hcs := wip_sq_le hp0 r zt
  have hres := one_sub_R2_eq_residual_share hp hy hr hvx hvy
  have hnn : 0 ≤ 1 - R2 p x y := by rw [hres]; positivity
  have hratio : (wip p r zt) ^ 2 / (wip p r r * wip p zt zt) ≤ 1 :=
    (div_le_one (by positivity)).mpr hcs
  have hmul := mul_le_mul_of_nonneg_left hratio hnn
  rw [mul_one] at hmul
  rw [hid]
  linarith

/-! ## 2. The Gram inequality in dashboard coordinates -/

/-- **Nonnegativity of the correlation Gram determinant.**  Written in dial coordinates, the
positive-semidefiniteness of the `3 × 3` correlation matrix of `(x, y, z)` reads
`1 − R²(x,y) − R²(x,z) − R²(z,y) + 2P ≥ 0` with `P = ρ_xy ρ_xz ρ_zy`.  Here it is *derived*
from `total_share_le_one`, i.e. from Cauchy–Schwarz, rather than assumed. -/
theorem correlation_det_nonneg {p x y r z zt : ι → ℝ} {a b : ℝ} (hp0 : ∀ i, 0 ≤ p i)
    (hp : ∑ i, p i = 1) (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r)
    (h : IsPartial p x z zt) (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x) (hrr : 0 < wip p r r)
    (hzt : 0 < wip p zt zt) :
    0 ≤ 1 - R2 p x y - R2 p x z - R2 p z y + 2 * tripleProd p x y z := by
  have hR1 : R2 p x z < 1 := R2_lt_one_of_partial_pos hvx hvz hpar
  have hone : (0 : ℝ) < 1 - R2 p x z := by linarith
  have htot := total_share_le_one hp0 hp hy hr hvx hvy hrr hzt
  rw [pgain_R2_triple_product_formula hp hy hr h hvx hvy hvz hpar] at htot
  have hstep : (R2 p z y + R2 p x y * R2 p x z - 2 * tripleProd p x y z) / (1 - R2 p x z)
      ≤ 1 - R2 p x y := by linarith
  rw [div_le_iff₀ hone] at hstep
  nlinarith [hstep]

/-! ## 3. The sharp algebraic ceiling -/

/-- **The amplitude ceiling, as pure algebra.**  If a triple of readings `(a, e, c)` admits
*both* signs of the triple product — equivalently, if the Gram inequality holds with the
unfavourable sign, `2√(aec) ≤ 1 − a − e − c` — then the ambiguity amplitude
`4√(aec)/(1 − e)` is at most `2√e/(1 + √e)`.  The proof is the AM–GM step `a + c ≥ 2√(ac)`
followed by clearing the denominator. -/
theorem amplitude_ceiling_algebraic {a c e : ℝ} (ha : 0 ≤ a) (hc : 0 ≤ c) (he : 0 ≤ e)
    (he1 : e < 1) (hcon : 2 * Real.sqrt (a * e * c) ≤ 1 - a - e - c) :
    4 * Real.sqrt (a * e * c) / (1 - e) ≤ 2 * Real.sqrt e / (1 + Real.sqrt e) := by
  set sa := Real.sqrt a with hsa
  set sc := Real.sqrt c with hsc
  set se := Real.sqrt e with hse
  have hsa0 : 0 ≤ sa := Real.sqrt_nonneg _
  have hsc0 : 0 ≤ sc := Real.sqrt_nonneg _
  have hse0 : 0 ≤ se := Real.sqrt_nonneg _
  have hsa2 : sa ^ 2 = a := Real.sq_sqrt ha
  have hsc2 : sc ^ 2 = c := Real.sq_sqrt hc
  have hse2 : se ^ 2 = e := Real.sq_sqrt he
  have hsplit : Real.sqrt (a * e * c) = sa * se * sc := by
    rw [hsa, hse, hsc, ← Real.sqrt_mul ha, ← Real.sqrt_mul (by positivity)]
  have hone : (0 : ℝ) < 1 - e := by linarith
  have hse1 : se < 1 := by nlinarith [hse2, hse0]
  have hamgm : 2 * (sa * sc) ≤ a + c := by nlinarith [sq_nonneg (sa - sc)]
  have hkey : 2 * (sa * sc) * (1 + se) ≤ 1 - e := by
    rw [hsplit] at hcon
    nlinarith [hcon, hamgm]
  rw [hsplit, div_le_div_iff₀ hone (by linarith : (0:ℝ) < 1 + se)]
  nlinarith [mul_le_mul_of_nonneg_left hkey (mul_nonneg (by norm_num : (0:ℝ) ≤ 2) hse0),
    hse2, hse0, hsa0, hsc0]

/-- The ceiling itself is strictly below `1`: a collinearity reading `e < 1` leaves a strictly
positive share of the rate variance that sign-blindness cannot touch. -/
theorem ceiling_lt_one {e : ℝ} (he : 0 ≤ e) (he1 : e < 1) :
    2 * Real.sqrt e / (1 + Real.sqrt e) < 1 := by
  have hse0 : 0 ≤ Real.sqrt e := Real.sqrt_nonneg _
  have hse2 : Real.sqrt e ^ 2 = e := Real.sq_sqrt he
  have hse1 : Real.sqrt e < 1 := by nlinarith
  rw [div_lt_one (by linarith)]
  linarith

/-! ## 4. The universal ceiling for matched population pairs -/

/-- **Universal ceiling for sign-blind misattribution.**  Let two finite populations — on
different key sets, under different draw regimes — agree on all three dial readings
`R²(x,y)`, `R²(z,y)`, `R²(x,z)` while their correlation triple products are exact opposites,
the configuration that makes a sign-blind dashboard unable to distinguish them.  Then their
increments differ by at most `2√(R²(x,z))/(1 + √(R²(x,z)))`, which is strictly less than `1`.

So the two-point ambiguity of cycle five can never exceed the total rate variance, and the
ceiling depends *only* on the footprint–feature collinearity reading: a dashboard reporting a
small `R²(x,z)` is provably close to admissible, whatever the other two readings say. -/
theorem sign_blind_amplitude_universal_ceiling {κ : Type*} [Fintype κ]
    {p x y r z zt : ι → ℝ} {a b : ℝ} {q x' y' r' z' zt' : κ → ℝ} {a' b' : ℝ}
    (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1) (hy : ∀ i, y i = a + b * x i + r i)
    (hr : IsResidual p x r) (h : IsPartial p x z zt) (hvx : 0 < wvar p x)
    (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x) (hrr : 0 < wip p r r)
    (hzt : 0 < wip p zt zt)
    (hq0 : ∀ i, 0 ≤ q i) (hq : ∑ i, q i = 1) (hy' : ∀ i, y' i = a' + b' * x' i + r' i)
    (hr' : IsResidual q x' r') (h' : IsPartial q x' z' zt') (hvx' : 0 < wvar q x')
    (hvy' : 0 < wvar q y') (hvz' : 0 < wvar q z')
    (hpar' : 0 < wvar q z' - (wcov q x' z') ^ 2 / wvar q x') (hrr' : 0 < wip q r' r')
    (hzt' : 0 < wip q zt' zt')
    (e1 : R2 p x y = R2 q x' y') (e2 : R2 p z y = R2 q z' y') (e3 : R2 p x z = R2 q x' z')
    (hflip : tripleProd q x' y' z' = -tripleProd p x y z) :
    |pgain p r zt / wvar p y - pgain q r' zt' / wvar q y'|
        ≤ 2 * Real.sqrt (R2 p x z) / (1 + Real.sqrt (R2 p x z)) ∧
      2 * Real.sqrt (R2 p x z) / (1 + Real.sqrt (R2 p x z)) < 1 := by
  have hR1 : R2 p x z < 1 := R2_lt_one_of_partial_pos hvx hvz hpar
  have hone : (0 : ℝ) < 1 - R2 p x z := by linarith
  have hxy : 0 ≤ R2 p x y := div_nonneg (sq_nonneg _) (by positivity)
  have hxz : 0 ≤ R2 p x z := div_nonneg (sq_nonneg _) (by positivity)
  have hzy : 0 ≤ R2 p z y := div_nonneg (sq_nonneg _) (by positivity)
  refine ⟨?_, ceiling_lt_one hxz hR1⟩
  -- the two Gram inequalities, one for each sign of the triple product
  have hg := correlation_det_nonneg hp0 hp hy hr h hvx hvy hvz hpar hrr hzt
  have hg' := correlation_det_nonneg hq0 hq hy' hr' h' hvx' hvy' hvz' hpar' hrr' hzt'
  rw [← e1, ← e2, ← e3, hflip] at hg'
  -- the triple product is pinned in absolute value by the readings
  have hPsq : (tripleProd p x y z) ^ 2 = R2 p x y * R2 p x z * R2 p z y :=
    triple_product_sq_eq_R2_prod hvx hvy hvz
  have habs : Real.sqrt (R2 p x y * R2 p x z * R2 p z y) = |tripleProd p x y z| := by
    rw [← hPsq, Real.sqrt_sq_eq_abs]
  -- the constraint feeding the algebraic ceiling
  have hcon : 2 * Real.sqrt (R2 p x y * R2 p x z * R2 p z y)
      ≤ 1 - R2 p x y - R2 p x z - R2 p z y := by
    rw [habs]
    rcases abs_cases (tripleProd p x y z) with ⟨hv, _⟩ | ⟨hv, _⟩
    · rw [hv]; linarith
    · rw [hv]; linarith
  -- the increment difference is exactly the amplitude
  have hfp := pgain_R2_triple_product_formula hp hy hr h hvx hvy hvz hpar
  have hfq := pgain_R2_triple_product_formula hq hy' hr' h' hvx' hvy' hvz' hpar'
  rw [← e1, ← e2, ← e3, hflip] at hfq
  have hdiff : pgain p r zt / wvar p y - pgain q r' zt' / wvar q y'
      = -(4 * tripleProd p x y z) / (1 - R2 p x z) := by
    rw [hfp, hfq]
    field_simp
    ring
  rw [hdiff, abs_div, abs_of_pos hone, abs_neg, abs_mul]
  have h4 : |(4 : ℝ)| = 4 := by norm_num
  rw [h4, ← habs]
  exact amplitude_ceiling_algebraic hxy hzy hxz hR1 hcon

/-! ## 5. The hypotheses are satisfiable: the catalog witness family -/

lemma wip_residFamB_self (b u : ℝ) :
    wip pU (residFamB b u) (residFamB b u) = (u + 5 * b ^ 2 / u) ^ 2 := by
  simp only [wip, residFamB, eVec, pU, Fin.sum_univ_four, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons]
  ring

lemma wip_residFamC_self (b u : ℝ) :
    wip pU (residFamC b u) (residFamC b u) = (u - 5 * b ^ 2 / u) ^ 2 + 20 * b ^ 2 := by
  simp only [wip, residFamC, eVec, ztA, pU, Fin.sum_univ_four, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons]
  ring

lemma wip_residFamB_self_pos {b u : ℝ} (hu : 0 < u) :
    0 < wip pU (residFamB b u) (residFamB b u) := by
  have hdiv : 0 ≤ 5 * b ^ 2 / u := div_nonneg (by positivity) hu.le
  have hsum : 0 < u + 5 * b ^ 2 / u := by linarith
  rw [wip_residFamB_self]
  positivity

lemma wip_residFamC_self_pos {b u : ℝ} (hb : b ≠ 0) :
    0 < wip pU (residFamC b u) (residFamC b u) := by
  have hb2 : 0 < b ^ 2 := by rcases hb.lt_or_gt with h | h <;> nlinarith
  rw [wip_residFamC_self]
  nlinarith [sq_nonneg (u - 5 * b ^ 2 / u)]

/-- The footprint-feature collinearity reading of the four-key population. -/
lemma R2_foot_pp_value : R2 pU foot pp = 4/5 := by
  rw [R2, wcov_foot_pp, wvar_foot, wvar_pp]
  norm_num

/-- The partialled feature of the four-key population is nondegenerate. -/
lemma pp_partial_energy_pos : 0 < wvar pU pp - (wcov pU foot pp) ^ 2 / wvar pU foot := by
  rw [wcov_foot_pp, wvar_foot, wvar_pp]
  norm_num

/-- **The witness pair flips the triple product.**  Both members of the family share their
rate variance, their footprint-rate covariance and the footprint-feature covariance, while
their feature-rate covariances are opposite; hence their correlation triple products are
exact negatives.  This is precisely the configuration the universal ceiling governs, so the
hypotheses of the ceiling theorem are not vacuous. -/
theorem tripleProd_famC_eq_neg_famB {b u : ℝ} (hu : u ≠ 0) :
    tripleProd pU foot (rateFamC b u) pp = -tripleProd pU foot (rateFamB b u) pp := by
  simp only [tripleProd, wcorr, wcov_foot_rateFamB hu, wcov_foot_rateFamC hu,
    wcov_pp_rateFamB hu, wcov_pp_rateFamC hu, wvar_rateFamB hu, wvar_rateFamC hu]
  ring

/-- **The ceiling, applied to the witness family.**  For every parameter pair with `b ≠ 0`
and `u > 0` the two dashboard-identical populations differ in their reported increments by at
most `2√(4/5)/(1 + √(4/5))`, the universal ceiling evaluated at the family's collinearity
reading `R²(foot, pp) = 4/5`. -/
theorem family_obeys_universal_ceiling {b u : ℝ} (hb : b ≠ 0) (hu : 0 < u) :
    |pgain pU (residFamC b u) ztA / wvar pU (rateFamC b u)
        - pgain pU (residFamB b u) ztA / wvar pU (rateFamB b u)|
      ≤ 2 * Real.sqrt (4/5) / (1 + Real.sqrt (4/5)) := by
  have hceil := sign_blind_amplitude_universal_ceiling
    (p := pU) (x := foot) (y := rateFamC b u) (r := residFamC b u) (z := pp) (zt := ztA)
    (q := pU) (x' := foot) (y' := rateFamB b u) (r' := residFamB b u) (z' := pp) (zt' := ztA)
    pU_nonneg pU_total (rateFamC_decomp b u) (residFamC_isResidual b u) pp_isPartial
    (by rw [wvar_foot]; norm_num) (wvar_rateFamC_pos hu) (by rw [wvar_pp]; norm_num)
    pp_partial_energy_pos (wip_residFamC_self_pos hb) wip_ztA_pos
    pU_nonneg pU_total (rateFamB_decomp b u) (residFamB_isResidual b u) pp_isPartial
    (by rw [wvar_foot]; norm_num) (wvar_rateFamB_pos hu) (by rw [wvar_pp]; norm_num)
    pp_partial_energy_pos (wip_residFamB_self_pos hu) wip_ztA_pos
    (R2_foot_fam_agree hu.ne').symm (R2_pp_fam_agree hu.ne').symm rfl
    (by rw [tripleProd_famC_eq_neg_famB hu.ne', neg_neg])
  rw [R2_foot_pp_value] at hceil
  exact hceil.1

/-! ## 6. The explicit family obeys the ceiling -/

/-- The witness family of cycle five, whose concealable share peaks at `16/17`, indeed sits
below the universal ceiling: its collinearity reading is `R²(foot, pp) = 4/5`, for which the
ceiling equals `2√(4/5)/(1 + √(4/5)) = 4/(2 + √5) ≈ 0.944`, and `16/17 ≈ 0.941 < 0.944`. -/
theorem masking_amplitude_family_lt_ceiling :
    (16 : ℝ)/17 < 4 / (2 + Real.sqrt 5) := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hlt : Real.sqrt 5 < 9/4 := by nlinarith [Real.sqrt_nonneg 5, h5]
  have hpos : (0 : ℝ) < 2 + Real.sqrt 5 := by positivity
  rw [lt_div_iff₀ hpos]
  linarith

end ExtendedDial

end Catalog.UniformDial