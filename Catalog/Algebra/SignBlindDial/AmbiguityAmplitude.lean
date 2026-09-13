/-
# How much can sign-blindness hide?  The exact ambiguity amplitude

Fifth cycle of the `EXTENDED-DIAL-ABSENT` investigation.  Cycle four
(`Algebra.SignBlindDial.CorrelationInvariants`,
`Algebra.SignBlindDial.OpenWitnessFamily`) proved that no function of the three variance
shares can return the augmentation increment, and that the counterexamples form an open
family.  The obvious follow-up question is quantitative: *given* a dashboard reading, how
far apart can the true increments be?

The answer is completely rigid.  The increment is
`ΔR² = (R²(z,y) + R²(x,y)·R²(x,z) − 2P) / (1 − R²(x,z))` where `P = ρ_xy ρ_xz ρ_zy`, and the
dashboard pins `P` down up to sign.  So the ambiguity is a **two-point set**, not an
interval, and its diameter is an explicit function of the readings.

Main results.

* `R2_lt_one_of_partial_pos` — a nondegenerate partialled feature forces `R²(x,z) < 1`.
* `sign_blind_ambiguity_dichotomy` — **rigidity**: two populations with identical dial
  readings either report the *same* increment, or increments differing by exactly
  `4·√(R²(x,y)·R²(z,y)·R²(x,z)) / (1 − R²(x,z))`.  Nothing in between is possible.
* `ambiguity_vanishes_iff_some_reading_zero` — the dashboard is admissible at a given
  reading precisely when one of the three readings is `0`; i.e. sign-blindness is harmless
  exactly on a set of readings of empty interior.
* `masking_amplitude_le` — within the witness family the concealable share of the rate
  variance never exceeds `16/17`, the bound coming from the perfect square `(u² − 5b²)²`.
* `masking_amplitude_attained` — and `16/17` is attained, at the irrational parameter
  `u = √5`, `b = 1`: a dashboard-identical pair of four-key populations one of which
  attributes `16/17 ≈ 94%` of the rate variance to the extra feature while the other
  attributes exactly nothing.
-/
import Algebra.SignBlindDial.OpenWitnessFamily

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

variable {ι : Type*} [Fintype ι]

/-! ## 1. Nondegeneracy of the collinearity reading -/

/-- A feature with strictly positive partialled energy is not perfectly collinear with the
footprint: its collinearity reading is strictly below one. -/
theorem R2_lt_one_of_partial_pos {p x z : ι → ℝ} (hvx : 0 < wvar p x) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x) : R2 p x z < 1 := by
  have hmul : 0 < wvar p x * (wvar p z - (wcov p x z) ^ 2 / wvar p x) := mul_pos hvx hpar
  have hexp : wvar p x * (wvar p z - (wcov p x z) ^ 2 / wvar p x)
      = wvar p x * wvar p z - (wcov p x z) ^ 2 := by field_simp
  rw [hexp] at hmul
  rw [R2, div_lt_one (mul_pos hvx hvz)]
  linarith

/-! ## 2. Rigidity of the ambiguity -/

/-- **The ambiguity of a sign-blind reading is a two-point set.**  Two finite populations —
different key sets, different draw regimes — that agree on the three dial readings
`R²(x,y)`, `R²(z,y)`, `R²(x,z)` either report the *same* increment, or report increments
differing by exactly `4·√(R²(x,y)·R²(z,y)·R²(x,z)) / (1 − R²(x,z))`.  No intermediate
disagreement is possible: the harm done by discarding the signs is quantised. -/
theorem sign_blind_ambiguity_dichotomy {κ : Type*} [Fintype κ]
    {p x y r z zt : ι → ℝ} {a b : ℝ} {q x' y' r' z' zt' : κ → ℝ} {a' b' : ℝ}
    (hp : ∑ i, p i = 1) (hy : ∀ i, y i = a + b * x i + r i) (hr : IsResidual p x r)
    (h : IsPartial p x z zt) (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x)
    (hq : ∑ i, q i = 1) (hy' : ∀ i, y' i = a' + b' * x' i + r' i) (hr' : IsResidual q x' r')
    (h' : IsPartial q x' z' zt') (hvx' : 0 < wvar q x') (hvy' : 0 < wvar q y')
    (hvz' : 0 < wvar q z') (hpar' : 0 < wvar q z' - (wcov q x' z') ^ 2 / wvar q x')
    (e1 : R2 p x y = R2 q x' y') (e2 : R2 p z y = R2 q z' y') (e3 : R2 p x z = R2 q x' z') :
    pgain p r zt / wvar p y = pgain q r' zt' / wvar q y' ∨
      |pgain p r zt / wvar p y - pgain q r' zt' / wvar q y'|
        = 4 * Real.sqrt (R2 p x y * R2 p x z * R2 p z y) / (1 - R2 p x z) := by
  have hR1 : R2 p x z < 1 := R2_lt_one_of_partial_pos hvx hvz hpar
  have hone : (0 : ℝ) < 1 - R2 p x z := by linarith
  have hf := pgain_R2_triple_product_formula hp hy hr h hvx hvy hvz hpar
  have hf' := pgain_R2_triple_product_formula hq hy' hr' h' hvx' hvy' hvz' hpar'
  have hPsq : (tripleProd p x y z) ^ 2 = (tripleProd q x' y' z') ^ 2 := by
    rw [triple_product_sq_eq_R2_prod hvx hvy hvz, triple_product_sq_eq_R2_prod hvx' hvy' hvz',
      e1, e2, e3]
  rcases mul_self_eq_mul_self_iff.mp (show tripleProd p x y z * tripleProd p x y z
      = tripleProd q x' y' z' * tripleProd q x' y' z' by nlinarith) with hP | hP
  · left
    rw [hf, hf', e1, e2, e3, hP]
  · right
    have hone' : (0 : ℝ) < 1 - R2 q x' z' := by rwa [e3] at hone
    have habs : Real.sqrt (R2 p x y * R2 p x z * R2 p z y) = |tripleProd q x' y' z'| := by
      rw [← triple_product_sq_eq_R2_prod hvx hvy hvz, Real.sqrt_sq_eq_abs, hP, abs_neg]
    rw [hf, hf', habs, e1, e2, e3, hP]
    set A := R2 q z' y' + R2 q x' y' * R2 q x' z' with hA
    set P := tripleProd q x' y' z' with hPdef
    have hdiff : (A - 2 * -P) / (1 - R2 q x' z') - (A - 2 * P) / (1 - R2 q x' z')
        = 4 * P / (1 - R2 q x' z') := by
      field_simp
      ring
    rw [hdiff, abs_div, abs_of_pos hone', abs_mul]
    norm_num

/-- **When is a sign-blind dashboard admissible?**  Exactly when the ambiguity amplitude
vanishes, which happens precisely when one of the three readings is zero — a nowhere-dense
condition.  On every other reading the two admissible increments are genuinely distinct. -/
theorem ambiguity_vanishes_iff_some_reading_zero {p x y z : ι → ℝ}
    (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) (hvz : 0 < wvar p z)
    (hpar : 0 < wvar p z - (wcov p x z) ^ 2 / wvar p x) :
    4 * Real.sqrt (R2 p x y * R2 p x z * R2 p z y) / (1 - R2 p x z) = 0 ↔
      R2 p x y = 0 ∨ R2 p x z = 0 ∨ R2 p z y = 0 := by
  have hR1 : R2 p x z < 1 := R2_lt_one_of_partial_pos hvx hvz hpar
  have hone : (0 : ℝ) < 1 - R2 p x z := by linarith
  have hxy : 0 ≤ R2 p x y := div_nonneg (sq_nonneg _) (by positivity)
  have hxz : 0 ≤ R2 p x z := div_nonneg (sq_nonneg _) (by positivity)
  have hzy : 0 ≤ R2 p z y := div_nonneg (sq_nonneg _) (by positivity)
  rw [div_eq_zero_iff]
  constructor
  · rintro (hc | hc)
    · have hs : Real.sqrt (R2 p x y * R2 p x z * R2 p z y) = 0 := by linarith
      have hprod : R2 p x y * R2 p x z * R2 p z y = 0 :=
        (Real.sqrt_eq_zero (by positivity)).mp hs
      rcases mul_eq_zero.mp hprod with h1 | h1
      · rcases mul_eq_zero.mp h1 with h2 | h2
        · exact Or.inl h2
        · exact Or.inr (Or.inl h2)
      · exact Or.inr (Or.inr h1)
    · exact absurd hc hone.ne'
  · intro hc
    left
    have hprod : R2 p x y * R2 p x z * R2 p z y = 0 := by
      rcases hc with h | h | h <;> rw [h] <;> ring
    rw [hprod, Real.sqrt_zero]
    ring

/-! ## 3. The maximal concealable share inside the witness family -/

/-- **A ceiling for sign masking in the family.**  Whatever the parameters, the increment the
active member reports — i.e. the share of rate variance the sign-blind dashboard fails to
attribute — is at most `16/17`.  The bound comes from the perfect square `(u² − 5b²)²`. -/
theorem masking_amplitude_le {b u : ℝ} (hu : 0 < u) :
    pgain pU (residFamC b u) ztA / wvar pU (rateFamC b u)
      - pgain pU (residFamB b u) ztA / wvar pU (rateFamB b u) ≤ 16/17 := by
  have hden : (0 : ℝ) < 5 * b ^ 2 * u ^ 2 + 4 * (u ^ 2 + 5 * b ^ 2) ^ 2 := by
    have h1 : (0 : ℝ) < (u ^ 2 + 5 * b ^ 2) ^ 2 := by positivity
    have h2 : (0 : ℝ) ≤ 5 * b ^ 2 * u ^ 2 := by positivity
    linarith
  rw [increment_famB, increment_famC hu, sub_zero, div_le_iff₀ hden]
  nlinarith [sq_nonneg (u ^ 2 - 5 * b ^ 2)]

/-- **The ceiling is attained.**  At the parameters `b = 1`, `u = √5` the two members of the
pair agree on every sign-blind dial reading, one of them attributes `16/17 ≈ 94%` of the rate
variance to the prime-power feature, and the other attributes exactly nothing. -/
theorem masking_amplitude_attained :
    pgain pU (residFamC 1 (Real.sqrt 5)) ztA / wvar pU (rateFamC 1 (Real.sqrt 5))
        - pgain pU (residFamB 1 (Real.sqrt 5)) ztA / wvar pU (rateFamB 1 (Real.sqrt 5))
      = 16/17 ∧
    R2 pU foot (rateFamB 1 (Real.sqrt 5)) = R2 pU foot (rateFamC 1 (Real.sqrt 5)) ∧
    R2 pU pp (rateFamB 1 (Real.sqrt 5)) = R2 pU pp (rateFamC 1 (Real.sqrt 5)) := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hu : (0 : ℝ) < Real.sqrt 5 := Real.sqrt_pos.mpr (by norm_num)
  refine ⟨?_, R2_foot_fam_agree hu.ne', R2_pp_fam_agree hu.ne'⟩
  rw [increment_famB, increment_famC hu, sub_zero, h5]
  norm_num

/-- **Sharpness of the family ceiling.**  The supremum `16/17` of the concealable share is
attained and never exceeded: the pair `(1, √5)` is an exact maximiser. -/
theorem masking_amplitude_isGreatest :
    IsGreatest {t : ℝ | ∃ b u : ℝ, 0 < u ∧
        t = pgain pU (residFamC b u) ztA / wvar pU (rateFamC b u)
            - pgain pU (residFamB b u) ztA / wvar pU (rateFamB b u)} (16/17) := by
  constructor
  · exact ⟨1, Real.sqrt 5, Real.sqrt_pos.mpr (by norm_num), (masking_amplitude_attained.1).symm⟩
  · rintro t ⟨b, u, hu, rfl⟩
    exact masking_amplitude_le hu

end ExtendedDial

end Catalog.UniformDial