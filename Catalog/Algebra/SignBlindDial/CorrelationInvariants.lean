/-
# Signed correlations: the exact invariant content of the augmentation increment

Fourth cycle of the `EXTENDED-DIAL-ABSENT` investigation, building directly on
`Combinatorics.ExtendedDialMomentGeometry` (`pgain_moment_formula`,
`increment_determined_by_moments`, the suppression pair `rateSB`/`rateSC`).

Cycle three showed that the increment `ΔR²` is a rational function of five second moments.
Those five moments are however *more* data than a dashboard reports: a dashboard reports the
three **variance shares** `R²(x,y)`, `R²(z,y)`, `R²(x,z)`, which are the *squares* of the
signed correlations and are therefore sign-blind.

This file isolates exactly how much of the moment data the increment really needs.

Main results.

* `wcorr`, `R2_eq_wcorr_sq` — the signed correlation, and the fact that a variance-share
  reading is precisely the square of it: a dashboard destroys exactly three sign bits.
* `pgain_correlation_formula` — the increment in *scale-free* form:
  `ΔR² = (ρ_zy − ρ_xy ρ_xz)² / (1 − ρ_xz²)`.  Together with `pgain_moment_formula` this says
  the increment is a function of the three signed correlations and nothing else.
* `pgain_R2_triple_product_formula` — the same increment written in terms of the three dial
  readings and the single extra real number `P = ρ_xy ρ_xz ρ_zy`:
  `ΔR² = (R²(z,y) + R²(x,y)·R²(x,z) − 2P) / (1 − R²(x,z))`.
* `triple_product_sq_eq_R2_prod` — `P² = R²(x,y)·R²(z,y)·R²(x,z)`, so the dashboard already
  determines `|P|`: the *only* missing datum is the sign of `P`.
* `increment_determined_by_R2_and_sign` — **sufficiency of one bit**: two populations that
  agree on the three dial readings and whose correlation triple products have the same sign
  report the same increment.  (The companion file shows the bit is genuinely necessary.)
-/
import Combinatorics.ExtendedDialMomentGeometry

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

variable {ι : Type*} [Fintype ι]

/-! ## 1. Signed correlations and the sign-blindness of a variance share -/

/-- The **signed** correlation of two population features under a draw regime.  This is the
datum a dashboard reporting `R²` throws away. -/
noncomputable def wcorr (p x y : ι → ℝ) : ℝ := wcov p x y / Real.sqrt (wvar p x * wvar p y)

lemma wcorr_eq_div_sqrt_mul_sqrt {p x y : ι → ℝ} (hvx : 0 ≤ wvar p x) :
    wcorr p x y = wcov p x y / (Real.sqrt (wvar p x) * Real.sqrt (wvar p y)) := by
  rw [wcorr, Real.sqrt_mul hvx]

/-- **A variance share is a squared correlation.**  Reporting `R²` is reporting `ρ²`: the
dashboard retains the magnitude of the correlation and destroys its sign. -/
theorem R2_eq_wcorr_sq {p x y : ι → ℝ} (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) :
    R2 p x y = (wcorr p x y) ^ 2 := by
  rw [R2, wcorr, div_pow, Real.sq_sqrt (by positivity)]

/-- Sign-blindness in the sharpest form: two populations whose correlations differ only by a
sign report the very same variance share. -/
theorem R2_sign_blind {p x y : ι → ℝ} {κ : Type*} [Fintype κ] {q u v : κ → ℝ}
    (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvu : 0 < wvar q u) (hvv : 0 < wvar q v)
    (h : wcorr p x y = -wcorr q u v) : R2 p x y = R2 q u v := by
  rw [R2_eq_wcorr_sq hvx hvy, R2_eq_wcorr_sq hvu hvv, h]; ring

/-! ## 2. The increment in scale-free (correlation) form -/

/-- The pure algebraic identity behind the partial-correlation form of the increment. -/
private lemma corr_ratio_identity {sx sy sz cxy cxz czy : ℝ} (hsx : sx ≠ 0) (hsy : sy ≠ 0)
    (hsz : sz ≠ 0) (hd : sx ^ 2 * sz ^ 2 - cxz ^ 2 ≠ 0) :
    ((czy - cxy * cxz / sx ^ 2) ^ 2 / (sz ^ 2 - cxz ^ 2 / sx ^ 2)) / sy ^ 2
      = (czy / (sz * sy) - (cxy / (sx * sy)) * (cxz / (sx * sz))) ^ 2
        / (1 - (cxz / (sx * sz)) ^ 2) := by
  have h1 : sz ^ 2 - cxz ^ 2 / sx ^ 2 ≠ 0 := by
    intro hc
    apply hd
    have hsx2 : (sx : ℝ) ^ 2 ≠ 0 := pow_ne_zero _ hsx
    field_simp at hc
    linarith [hc]
  have h2 : (1 : ℝ) - (cxz / (sx * sz)) ^ 2 ≠ 0 := by
    intro hc
    apply hd
    have hsx2 : (sx : ℝ) ^ 2 ≠ 0 := pow_ne_zero _ hsx
    have hsz2 : (sz : ℝ) ^ 2 ≠ 0 := pow_ne_zero _ hsz
    field_simp at hc
    linarith [hc]
  field_simp

/-- **The partial-correlation form of the increment.**  Starting from the five-moment
formula `pgain_moment_formula`, the increment of the variance share is the squared partial
correlation of feature and rate given the footprint:
`ΔR² = (ρ_zy − ρ_xy ρ_xz)² / (1 − ρ_xz²)`.
It depends on the three *signed* correlations and on nothing else — in particular it is
invariant under rescaling footprint, feature or rate. -/
theorem pgain_correlation_formula {p x y r z zt : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (h : IsPartial p x z zt)
    (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x) :
    pgain p r zt / wvar p y
      = (wcorr p z y - wcorr p x y * wcorr p x z) ^ 2 / (1 - (wcorr p x z) ^ 2) := by
  have hsxp : 0 < Real.sqrt (wvar p x) := Real.sqrt_pos.mpr hvx
  have hsyp : 0 < Real.sqrt (wvar p y) := Real.sqrt_pos.mpr hvy
  have hszp : 0 < Real.sqrt (wvar p z) := Real.sqrt_pos.mpr hvz
  set sx := Real.sqrt (wvar p x)
  set sy := Real.sqrt (wvar p y)
  set sz := Real.sqrt (wvar p z)
  have hsx2 : sx ^ 2 = wvar p x := Real.sq_sqrt hvx.le
  have hsy2 : sy ^ 2 = wvar p y := Real.sq_sqrt hvy.le
  have hsz2 : sz ^ 2 = wvar p z := Real.sq_sqrt hvz.le
  have hcxy : wcorr p x y = wcov p x y / (sx * sy) := wcorr_eq_div_sqrt_mul_sqrt hvx.le
  have hcxz : wcorr p x z = wcov p x z / (sx * sz) := wcorr_eq_div_sqrt_mul_sqrt hvx.le
  have hczy : wcorr p z y = wcov p z y / (sz * sy) := wcorr_eq_div_sqrt_mul_sqrt hvz.le
  have hd : sx ^ 2 * sz ^ 2 - (wcov p x z) ^ 2 ≠ 0 := by
    have hmul : 0 < wvar p x * (wvar p z - (wcov p x z) ^ 2 / wvar p x) := mul_pos hvx hpar
    have hexp : wvar p x * (wvar p z - (wcov p x z) ^ 2 / wvar p x)
        = wvar p x * wvar p z - (wcov p x z) ^ 2 := by
      field_simp
    rw [hexp] at hmul
    rw [hsx2, hsz2]
    exact ne_of_gt hmul
  rw [pgain_moment_formula hp hy hr h hvx, hcxy, hcxz, hczy, ← hsx2, ← hsy2, ← hsz2]
  exact corr_ratio_identity hsxp.ne' hsyp.ne' hszp.ne' hd

/-! ## 3. Dial readings plus one sign bit -/

/-- The **correlation triple product** `P = ρ_xy · ρ_xz · ρ_zy`: the single scale-free
invariant a sign-blind dashboard cannot see. -/
noncomputable def tripleProd (p x y z : ι → ℝ) : ℝ :=
  wcorr p x y * wcorr p x z * wcorr p z y

/-- The dashboard determines `|P|`: the square of the triple product is the product of the
three variance shares.  Hence exactly one bit — the sign of `P` — is missing. -/
theorem triple_product_sq_eq_R2_prod {p x y z : ι → ℝ} (hvx : 0 < wvar p x)
    (hvy : 0 < wvar p y) (hvz : 0 < wvar p z) :
    (tripleProd p x y z) ^ 2 = R2 p x y * R2 p x z * R2 p z y := by
  rw [tripleProd, R2_eq_wcorr_sq hvx hvy, R2_eq_wcorr_sq hvx hvz, R2_eq_wcorr_sq hvz hvy]
  ring

/-- **The increment in dashboard coordinates plus the missing invariant.**
`ΔR² = (R²(z,y) + R²(x,y)·R²(x,z) − 2P) / (1 − R²(x,z))`.  Everything on the right except
`P` is a dial reading; `P` is the one datum the dashboard destroys. -/
theorem pgain_R2_triple_product_formula {p x y r z zt : ι → ℝ} {a b : ℝ} (hp : ∑ i, p i = 1)
    (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r) (h : IsPartial p x z zt)
    (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x) :
    pgain p r zt / wvar p y
      = (R2 p z y + R2 p x y * R2 p x z - 2 * tripleProd p x y z) / (1 - R2 p x z) := by
  rw [pgain_correlation_formula hp hy hr h hvx hvy hvz hpar, tripleProd,
    R2_eq_wcorr_sq hvz hvy, R2_eq_wcorr_sq hvx hvy, R2_eq_wcorr_sq hvx hvz]
  congr 1
  ring

/-- Two reals with equal squares and nonnegative product are equal. -/
private lemma eq_of_sq_eq_of_mul_nonneg {P Q : ℝ} (hsq : P ^ 2 = Q ^ 2) (hmul : 0 ≤ P * Q) :
    P = Q := by
  rcases mul_self_eq_mul_self_iff.mp (show P * P = Q * Q by nlinarith) with h | h
  · exact h
  · have hQ : Q = 0 := by nlinarith
    rw [h, hQ, neg_zero]

/-- **One bit restores admissibility.**  Two populations — different key sets, different draw
regimes — that agree on the three dial readings `R²(x,y)`, `R²(z,y)`, `R²(x,z)` *and* whose
correlation triple products have the same sign report exactly the same increment.  Combined
with the impossibility theorem of the companion file, this pins the failure of sign-blind
reporting to a single missing bit of information. -/
theorem increment_determined_by_R2_and_sign {κ : Type*} [Fintype κ]
    {p x y r z zt : ι → ℝ} {a b : ℝ} {q x' y' r' z' zt' : κ → ℝ} {a' b' : ℝ}
    (hp : ∑ i, p i = 1) (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r)
    (h : IsPartial p x z zt) (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x)
    (hq : ∑ i, q i = 1) (hy' : ∀ i, y' i = a' + b' * x' i + r' i) (hr' : IsResidual q x' r')
    (h' : IsPartial q x' z' zt') (hvx' : 0 < wvar q x') (hvy' : 0 < wvar q y')
    (hvz' : 0 < wvar q z') (hpar' : 0 < wvar q z' - (wcov q x' z') ^ 2 / wvar q x')
    (e1 : R2 p x y = R2 q x' y') (e2 : R2 p z y = R2 q z' y') (e3 : R2 p x z = R2 q x' z')
    (hsign : 0 ≤ tripleProd p x y z * tripleProd q x' y' z') :
    pgain p r zt / wvar p y = pgain q r' zt' / wvar q y' := by
  have hPsq : (tripleProd p x y z) ^ 2 = (tripleProd q x' y' z') ^ 2 := by
    rw [triple_product_sq_eq_R2_prod hvx hvy hvz, triple_product_sq_eq_R2_prod hvx' hvy' hvz',
      e1, e2, e3]
  have hP : tripleProd p x y z = tripleProd q x' y' z' := eq_of_sq_eq_of_mul_nonneg hPsq hsign
  rw [pgain_R2_triple_product_formula hp hy hr h hvx hvy hvz hpar,
    pgain_R2_triple_product_formula hq hy' hr' h' hvx' hvy' hvz' hpar', e1, e2, e3, hP]

end ExtendedDial

end Catalog.UniformDial