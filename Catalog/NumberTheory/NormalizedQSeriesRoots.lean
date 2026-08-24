import Mathlib
import Catalog.NumberTheory.NormalizedQSeriesDivisible

/-!
# Power automorphisms and explicit root expansions for normalized `q`-series

Fifth research cycle.  Cycles 3–4
(`Catalog.NumberTheory.NormalizedQSeriesGroup`,
`Catalog.NumberTheory.NormalizedQSeriesDivisible`) established that the
normalized Laurent series `q⁻¹ + a₀ + a₁ q + ⋯` form a torsion-free, divisible
abelian group under the corrected product `f ⋆ g = q f g`.  Here we exploit that
structure in two directions.

* **Power maps are automorphisms.**  `NormalizedQSeries.powMulEquiv`: for every
  `n ≥ 1` the `n`-th power map of the group of normalized `q`-series is a group
  *automorphism*.  Equivalently `q^{n-1} f ↦ q^{n-1} fⁿ` permutes the set of
  normalized series bijectively.  This is the sharpest possible form of the
  statement "the pole-order obstruction disappears after correction".
* **Explicit low-order expansions.**  The abstract root is made concrete:
  `NormalizedQSeries.coeff_star_inv` computes the first two Laurent coefficients
  of the `⋆`-inverse, and `NormalizedQSeries.coeff_star_sqrt` those of the
  `⋆`-square root:
  `√f = q⁻¹ + a₀/2 + (a₁/2 - a₀²/8) q + ⋯` for `f = q⁻¹ + a₀ + a₁ q + ⋯`.
  These are Newton-type identities dual to the ones of cycle 2.
* **Moonshine lab notes.**  For the McKay–Thompson normalization `a₀ = 0`
  the square root of `J = q⁻¹ + 196884 q + ⋯` begins `q⁻¹ + 98442 q + ⋯`, and
  its `⋆`-inverse begins `q⁻¹ - 196884 q + ⋯`; both are verified in Lean.
-/

namespace NormalizedQSeries

open HahnSeries Finset PoleOrderObstruction PowerSeries

/-! ## 1. The `n`-th power map is an automorphism -/

theorem Normalized.pow_left_injective {n : ℕ} (hn : 0 < n) :
    Function.Injective fun f : Normalized => f ^ n := by
  intro f g hfg
  have h1 : (f * g⁻¹) ^ n = 1 := by
    simp only at hfg
    rw [mul_pow, inv_pow, hfg, mul_inv_cancel]
  have := (Normalized.pow_eq_one_iff _ hn).mp h1
  rwa [mul_inv_eq_one] at this

theorem Normalized.pow_left_surjective {n : ℕ} (hn : 0 < n) :
    Function.Surjective fun f : Normalized => f ^ n := by
  intro f
  obtain ⟨g, hg, -⟩ := Normalized.existsUnique_pow f hn
  exact ⟨g, hg⟩

/-- **Power automorphism.**  For `n ≥ 1` the `n`-th power map of the group of
normalized `q`-series is a group automorphism: every normalized series is the
`⋆`-`n`-th power of exactly one normalized series. -/
noncomputable def powMulEquiv {n : ℕ} (hn : 0 < n) : Normalized ≃* Normalized :=
  MulEquiv.ofBijective (powMonoidHom n)
    ⟨Normalized.pow_left_injective hn, Normalized.pow_left_surjective hn⟩

@[simp] theorem powMulEquiv_apply {n : ℕ} (hn : 0 < n) (f : Normalized) :
    powMulEquiv hn f = f ^ n := rfl

/-! ## 2. Explicit expansions of `⋆`-inverses and `⋆`-square roots -/

@[simp] theorem normalizedPart_qInv : normalizedPart qInv = 1 := by
  have h := normalizedPart_qInv_mul (u := (1 : PowerSeries ℂ)) (by simp)
  simpa using h

/-- The `⋆`-inverse of a normalized series, in Laurent coefficients:
`f⁻¹ = q⁻¹ - a₀ + (a₀² - a₁) q + ⋯` for `f = q⁻¹ + a₀ + a₁ q + ⋯`. -/
theorem coeff_star_inv {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g)
    (h : g ⋆ f = qInv) :
    g.coeff 0 = -f.coeff 0 ∧ g.coeff 1 = (f.coeff 0) ^ 2 - f.coeff 1 := by
  have hprod : normalizedPart g * normalizedPart f = 1 := by
    have hstar := normalizedPart_star hg hf
    rw [h, normalizedPart_qInv] at hstar
    exact hstar.symm
  have hG0 : PowerSeries.constantCoeff (normalizedPart g) = 1 :=
    constantCoeff_normalizedPart g hg
  have hF0 : PowerSeries.constantCoeff (normalizedPart f) = 1 :=
    constantCoeff_normalizedPart f hf
  have hG1 : PowerSeries.coeff 1 (normalizedPart g) = g.coeff 0 := by
    rw [coeff_normalizedPart hg 1]; norm_num
  have hF1 : PowerSeries.coeff 1 (normalizedPart f) = f.coeff 0 := by
    rw [coeff_normalizedPart hf 1]; norm_num
  have hG2 : PowerSeries.coeff 2 (normalizedPart g) = g.coeff 1 := by
    rw [coeff_normalizedPart hg 2]; norm_num
  have hF2 : PowerSeries.coeff 2 (normalizedPart f) = f.coeff 1 := by
    rw [coeff_normalizedPart hf 2]; norm_num
  have e1 : PowerSeries.coeff 1 (normalizedPart g * normalizedPart f) = 0 := by
    rw [hprod]; simp
  have e2 : PowerSeries.coeff 2 (normalizedPart g * normalizedPart f) = 0 := by
    rw [hprod]; simp
  rw [PowerSeries.coeff_one_mul, hG0, hF0, hG1, hF1] at e1
  rw [coeff_two_mul, hG0, hF0, hG1, hF1, hG2, hF2] at e2
  constructor
  · linear_combination e1
  · linear_combination e2 - f.coeff 0 * e1

/-- **`⋆`-square root expansion.**  If `g ⋆ g = f` with both normalized, then
`g = q⁻¹ + a₀/2 + (a₁/2 - a₀²/8) q + ⋯` where `f = q⁻¹ + a₀ + a₁ q + ⋯`. -/
theorem coeff_star_sqrt {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g)
    (h : g ⋆ g = f) :
    g.coeff 0 = f.coeff 0 / 2 ∧ g.coeff 1 = f.coeff 1 / 2 - (f.coeff 0) ^ 2 / 8 := by
  have hprod : normalizedPart g * normalizedPart g = normalizedPart f := by
    rw [← normalizedPart_star hg hg, h]
  have hG0 : PowerSeries.constantCoeff (normalizedPart g) = 1 :=
    constantCoeff_normalizedPart g hg
  have hG1 : PowerSeries.coeff 1 (normalizedPart g) = g.coeff 0 := by
    rw [coeff_normalizedPart hg 1]; norm_num
  have hF1 : PowerSeries.coeff 1 (normalizedPart f) = f.coeff 0 := by
    rw [coeff_normalizedPart hf 1]; norm_num
  have hG2 : PowerSeries.coeff 2 (normalizedPart g) = g.coeff 1 := by
    rw [coeff_normalizedPart hg 2]; norm_num
  have hF2 : PowerSeries.coeff 2 (normalizedPart f) = f.coeff 1 := by
    rw [coeff_normalizedPart hf 2]; norm_num
  have e1 : PowerSeries.coeff 1 (normalizedPart g * normalizedPart g)
      = PowerSeries.coeff 1 (normalizedPart f) := by rw [hprod]
  have e2 : PowerSeries.coeff 2 (normalizedPart g * normalizedPart g)
      = PowerSeries.coeff 2 (normalizedPart f) := by rw [hprod]
  rw [PowerSeries.coeff_one_mul, hG0, hG1, hF1] at e1
  rw [coeff_two_mul, hG0, hG1, hG2, hF2] at e2
  have hg0 : g.coeff 0 = f.coeff 0 / 2 := by linear_combination e1 / 2
  refine ⟨hg0, ?_⟩
  rw [hg0] at e2
  linear_combination e2 / 2

/-! ## 3. The third coefficient of the `⋆`-square root -/

/-- Cubic coefficient of a product of power series. -/
theorem coeff_three_mul (a b : PowerSeries ℂ) :
    PowerSeries.coeff 3 (a * b) =
      PowerSeries.constantCoeff a * PowerSeries.coeff 3 b
        + PowerSeries.coeff 1 a * PowerSeries.coeff 2 b
        + PowerSeries.coeff 2 a * PowerSeries.coeff 1 b
        + PowerSeries.coeff 3 a * PowerSeries.constantCoeff b := by
  have hanti : Finset.antidiagonal (3 : ℕ) = {(0, 3), (1, 2), (2, 1), (3, 0)} := rfl
  rw [PowerSeries.coeff_mul, hanti]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  simp [PowerSeries.coeff_zero_eq_constantCoeff]
  ring

/-- **Third-order Newton identity for the `⋆`-square root.**  If `g ⋆ g = f`
with `f = q⁻¹ + a₀ + a₁ q + a₂ q² + ⋯`, then
`g.coeff 2 = a₂/2 - a₀ a₁/4 + a₀³/16`. -/
theorem coeff_star_sqrt_third {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g)
    (h : g ⋆ g = f) :
    g.coeff 2 = f.coeff 2 / 2 - f.coeff 0 * f.coeff 1 / 4 + (f.coeff 0) ^ 3 / 16 := by
  obtain ⟨hg0, hg1⟩ := coeff_star_sqrt hf hg h
  have hprod : normalizedPart g * normalizedPart g = normalizedPart f := by
    rw [← normalizedPart_star hg hg, h]
  have hG0 : PowerSeries.constantCoeff (normalizedPart g) = 1 :=
    constantCoeff_normalizedPart g hg
  have hG1 : PowerSeries.coeff 1 (normalizedPart g) = g.coeff 0 := by
    rw [coeff_normalizedPart hg 1]; norm_num
  have hG2 : PowerSeries.coeff 2 (normalizedPart g) = g.coeff 1 := by
    rw [coeff_normalizedPart hg 2]; norm_num
  have hG3 : PowerSeries.coeff 3 (normalizedPart g) = g.coeff 2 := by
    rw [coeff_normalizedPart hg 3]; norm_num
  have hF3 : PowerSeries.coeff 3 (normalizedPart f) = f.coeff 2 := by
    rw [coeff_normalizedPart hf 3]; norm_num
  have e3 : PowerSeries.coeff 3 (normalizedPart g * normalizedPart g)
      = PowerSeries.coeff 3 (normalizedPart f) := by rw [hprod]
  rw [coeff_three_mul, hG0, hG1, hG2, hG3, hF3] at e3
  rw [hg0, hg1] at e3
  linear_combination e3 / 2

/-! ## 4. Moonshine lab notes: verified numerical instances -/

/-- The `⋆`-square root of a McKay–Thompson-shaped series with vanishing
constant term again has vanishing constant term, and its linear coefficient is
half of the original one. -/
theorem coeff_star_sqrt_traceLaurent (c : ℕ → ℂ) (hc : c 0 = 0) {g : LC}
    (hg : IsNormalized g) (h : g ⋆ g = traceLaurent c) :
    g.coeff 0 = 0 ∧ g.coeff 1 = c 1 / 2 := by
  obtain ⟨h0, h1⟩ := coeff_star_sqrt (isNormalized_traceLaurent c) hg h
  rw [coeff_zero_traceLaurent, hc] at h0 h1
  rw [coeff_one_traceLaurent] at h1
  exact ⟨by simpa using h0, by rw [h1]; ring⟩

/-- **Lab note (moonshine, `J = q⁻¹ + 196884 q + ⋯`).**  The unique normalized
`⋆`-square root of `J` begins `q⁻¹ + 0 + 98442 q + ⋯`. -/
theorem coeff_star_sqrt_J {g : LC} (hg : IsNormalized g)
    (h : g ⋆ g = traceLaurent (fun n => if n = 1 then (196884 : ℂ) else 0)) :
    g.coeff 0 = 0 ∧ g.coeff 1 = 98442 := by
  obtain ⟨h0, h1⟩ := coeff_star_sqrt_traceLaurent _ (by norm_num) hg h
  refine ⟨h0, ?_⟩
  rw [h1]
  norm_num

/-- **Lab note.**  The `⋆`-inverse of `J` begins `q⁻¹ + 0 - 196884 q + ⋯`. -/
theorem coeff_star_inv_J {g : LC} (hg : IsNormalized g)
    (h : g ⋆ traceLaurent (fun n => if n = 1 then (196884 : ℂ) else 0) = qInv) :
    g.coeff 0 = 0 ∧ g.coeff 1 = -196884 := by
  obtain ⟨h0, h1⟩ := coeff_star_inv (isNormalized_traceLaurent _) hg h
  rw [coeff_zero_traceLaurent] at h0 h1
  rw [coeff_one_traceLaurent] at h1
  norm_num at h0 h1
  exact ⟨h0, h1⟩

/-- **Lab note.**  Third coefficient of the `⋆`-square root of
`J = q⁻¹ + 196884 q + 21493760 q² + ⋯`: it equals `10746880 = 21493760 / 2`,
an integer — the empirical `2`-integrality of the moonshine square root. -/
theorem coeff_star_sqrt_J_third {g : LC} (hg : IsNormalized g)
    (h : g ⋆ g = traceLaurent
      (fun n => if n = 1 then (196884 : ℂ) else if n = 2 then (21493760 : ℂ) else 0)) :
    g.coeff 2 = 10746880 := by
  have hf := isNormalized_traceLaurent
    (fun n => if n = 1 then (196884 : ℂ) else if n = 2 then (21493760 : ℂ) else 0)
  have hkey := coeff_star_sqrt_third hf hg h
  have h0 : (traceLaurent
      (fun n => if n = 1 then (196884 : ℂ) else if n = 2 then (21493760 : ℂ) else 0)).coeff 0
      = 0 := by
    rw [coeff_zero_traceLaurent]; norm_num
  have h2 : (traceLaurent
      (fun n => if n = 1 then (196884 : ℂ) else if n = 2 then (21493760 : ℂ) else 0)).coeff 2
      = 21493760 := by
    have hco : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk
        (fun n => if n = 1 then (196884 : ℂ) else if n = 2 then (21493760 : ℂ) else 0))).coeff
        ((2 : ℕ) : ℤ) = 21493760 := by
      rw [coeff_ofPowerSeries_natCast]
      simp
    rw [traceLaurent]
    have : ((2 : ℕ) : ℤ) = (2 : ℤ) := by norm_num
    rw [this] at hco
    simp [hco]
  rw [hkey, h0, h2]
  norm_num

/-- **Existence of the moonshine square root.**  There is exactly one normalized
`g` with `q · g² = J`. -/
theorem existsUnique_star_sqrt_J :
    ∃! g : LC, IsNormalized g ∧
      HahnSeries.single (1 : ℤ) (1 : ℂ) * g ^ 2
        = traceLaurent (fun n => if n = 1 then (196884 : ℂ) else 0) := by
  have := existsUnique_star_root
    (isNormalized_traceLaurent (fun n => if n = 1 then (196884 : ℂ) else 0)) (n := 2) (by norm_num)
  simpa using this

end NormalizedQSeries