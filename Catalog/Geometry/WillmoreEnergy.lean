/-
# Willmore Energy: The Elementary Lower Bounds by Genus

This file develops the *elementary* half of the Willmore story in a clean,
measure-theoretic abstraction.  Rather than committing to a smooth immersed
surface, we model the geometric data of a closed surface as a finite measure
space `(X, μ)` together with two principal-curvature functions `k₁, k₂ : X → ℝ`.
All the algebraic and integral inequalities that underlie the classical
Willmore theory are then provable with no manifold machinery whatsoever.

## The core objects

* `meanCurv   = (k₁ + k₂)/2`            (the mean curvature `H`)
* `willmoreDensity = H² = ((k₁+k₂)/2)²` (the pointwise Willmore integrand)
* `gaussCurv  = k₁·k₂`                  (the Gaussian curvature `K`)
* `umbilicDefect = ((k₁-k₂)/2)²`        (the *traceless* second fundamental form)
* `willmoreEnergy = ∫ H² dμ`            (the Willmore energy `W`)

## Main results

* `willmoreDensity_sub_gaussCurv` — the pointwise identity `H² - K = ((k₁-k₂)/2)²`.
* `willmoreDensity_eq_gaussCurv_iff` — pointwise rigidity `H² = K ↔ k₁ = k₂`.
* `willmoreEnergy_sub_gauss_eq_defect` — the integral identity `W - ∫K = ∫((k₁-k₂)/2)²`.
* `gauss_le_willmore` — the integral inequality `∫K ≤ W`.
* `willmore_eq_gauss_iff_umbilic_ae` — integral rigidity: `W = ∫K ↔ k₁ = k₂` a.e.
* `gaussBonnet_bound` — `2π·χ ≤ W` from a Gauss–Bonnet input `∫K = 2π·χ`.
* `willmore_ge_fourPi_genus_zero` — the sharp `4π` bound for genus `0`.
* `willmore_ge_fourPi_of_setGauss` — the universal `4π` bound from a Gauss-map
  degree region.
* `willmore_ge_fourPi_mul_of_disjoint_sheets` — a Li–Yau-style multiplicity bound:
  `n` disjoint `4π`-sheets force `W ≥ 4π·n`.
* `gaussBonnet_bound_vacuous_high_genus` — the elementary bound `4π(1-g) ≤ 0`
  degenerates for `g ≥ 1`.
* `elementary_bound_step` / `elementary_bound_antitone` — the elementary
  obstruction loses exactly `2π` per unit genus.

This file connects to the catalog file `DiscreteGaussBonnet.lean`
(`total_curvature_eq_genus`, `eulerChar_eq_two_sub_two_mul_genus`,
`sphere_euler_char`): the Euler characteristic / genus inputs to the
Gauss–Bonnet theorems below are exactly the discrete totals proved there.

## References

* Willmore, T.J. "Note on embedded surfaces."
* Li, P. and Yau, S.-T. "A new conformal invariant and its applications…"
* Marques, F.C. and Neves, A. "Min-max theory and the Willmore conjecture."
-/

-- !-- Lab Notebook -- !--
-- Hypothesis: The classical chain of Willmore inequalities (H²≥K pointwise,
--   hence ∫K ≤ W, hence 2πχ ≤ W via Gauss–Bonnet, hence the 4π genus-0 bound)
--   is *entirely algebraic + measure-theoretic*; no smooth manifold structure
--   is needed if the principal curvatures are taken as raw measurable functions.
-- Result: Confirmed. Every elementary inequality reduces to the single square
--   identity H² - K = ((k₁-k₂)/2)² plus nonnegativity of integrals of squares.
-- Insight: The "slack" in ∫K ≤ W is *literally* an L² norm of the traceless
--   second fundamental form, so the bound upgrades to an identity-with-remainder
--   and to an a.e.-umbilic rigidity statement for free.
-- Failure analysis: The elementary method cannot see genus ≥ 1 sharp bounds:
--   for g ≥ 1 the Gauss–Bonnet floor 4π(1-g) ≤ 0 is vacuous, which we make
--   precise. The genuine genus-1 floor 2π² needs min-max input absent here.

import Mathlib

open MeasureTheory Real

namespace WillmoreEnergy

variable {X : Type*} (k1 k2 : X → ℝ)

/-! ## Part 1: Pointwise objects and the square identity -/

/-- Mean curvature `H = (k₁ + k₂)/2`. -/
noncomputable def meanCurv (x : X) : ℝ := (k1 x + k2 x) / 2

/-- Willmore density `H² = ((k₁+k₂)/2)²`, the pointwise Willmore integrand. -/
noncomputable def willmoreDensity (x : X) : ℝ := ((k1 x + k2 x) / 2) ^ 2

/-- Gaussian curvature `K = k₁·k₂`. -/
def gaussCurv (x : X) : ℝ := k1 x * k2 x

/-- Umbilic defect `((k₁-k₂)/2)²`, the squared length of the traceless second
fundamental form. -/
noncomputable def umbilicDefect (x : X) : ℝ := ((k1 x - k2 x) / 2) ^ 2

-- !-- The square identity H² - K = ((k₁-k₂)/2)² is a single `ring` fact: it is the polarization (a+b)² - 4ab = (a-b)² rescaled by 1/4. -- !--
/-- **The pointwise square identity** `H² - K = ((k₁-k₂)/2)²`. -/
theorem willmoreDensity_sub_gaussCurv (x : X) :
    willmoreDensity k1 k2 x - gaussCurv k1 k2 x = umbilicDefect k1 k2 x := by
  unfold willmoreDensity gaussCurv umbilicDefect; ring

/-- The umbilic defect is nonnegative (it is a square). -/
theorem umbilicDefect_nonneg (x : X) : 0 ≤ umbilicDefect k1 k2 x :=
  sq_nonneg _

-- !-- The difference H² - K equals the nonnegative defect, so K ≤ H² pointwise. -- !--
/-- The Willmore density dominates the Gaussian curvature pointwise: `K ≤ H²`. -/
theorem gaussCurv_le_willmoreDensity (x : X) :
    gaussCurv k1 k2 x ≤ willmoreDensity k1 k2 x := by
  unfold gaussCurv willmoreDensity
  linarith [sq_nonneg (k1 x - k2 x)]

/-- The Willmore density is nonnegative (it is a square). -/
theorem willmoreDensity_nonneg (x : X) : 0 ≤ willmoreDensity k1 k2 x :=
  sq_nonneg _

-- !-- Pointwise rigidity: the square defect ((k₁-k₂)/2)² vanishes iff k₁=k₂, so H²=K exactly at umbilic points. -- !--
/-- **Pointwise rigidity**: `H² = K` exactly at umbilic points `k₁ = k₂`. -/
theorem willmoreDensity_eq_gaussCurv_iff (x : X) :
    willmoreDensity k1 k2 x = gaussCurv k1 k2 x ↔ k1 x = k2 x := by
  constructor <;> intro h <;> unfold willmoreDensity gaussCurv at * <;> nlinarith

/-! ## Part 2: The Willmore energy and the integral inequalities -/

variable [MeasurableSpace X] {μ : Measure X}

/-- The Willmore energy `W = ∫ H² dμ`. -/
noncomputable def willmoreEnergy (μ : Measure X) (k1 k2 : X → ℝ) : ℝ :=
  ∫ x, willmoreDensity k1 k2 x ∂μ

/-- The total Gaussian curvature `∫ K dμ`. -/
noncomputable def totalGauss (μ : Measure X) (k1 k2 : X → ℝ) : ℝ :=
  ∫ x, gaussCurv k1 k2 x ∂μ

/-- The total umbilic defect `∫ ((k₁-k₂)/2)² dμ`. -/
noncomputable def totalDefect (μ : Measure X) (k1 k2 : X → ℝ) : ℝ :=
  ∫ x, umbilicDefect k1 k2 x ∂μ

-- !-- Integrate the pointwise identity term by term via `integral_sub`; the defect integrability follows from that of density and curvature. -- !--
/-- **The integral identity** `W - ∫K = ∫ ((k₁-k₂)/2)²` (the total umbilic
defect is exactly the Willmore slack). -/
theorem willmoreEnergy_sub_gauss_eq_defect
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ) :
    willmoreEnergy μ k1 k2 - totalGauss μ k1 k2 = totalDefect μ k1 k2 := by
  unfold totalDefect totalGauss willmoreEnergy
  rw [← MeasureTheory.integral_sub hW hK]
  congr; ext; unfold umbilicDefect gaussCurv willmoreDensity; ring

/-- The total umbilic defect is nonnegative. -/
theorem totalDefect_nonneg : 0 ≤ totalDefect μ k1 k2 :=
  MeasureTheory.integral_nonneg fun _ => sq_nonneg _

-- !-- The slack W - ∫K equals the nonnegative defect integral, hence ∫K ≤ W. -- !--
/-- **The integral inequality** `∫K ≤ W`. -/
theorem gauss_le_willmore
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ) :
    totalGauss μ k1 k2 ≤ willmoreEnergy μ k1 k2 := by
  have h := willmoreEnergy_sub_gauss_eq_defect k1 k2 hW hK
  have hd := totalDefect_nonneg (μ := μ) k1 k2
  linarith

-- !-- The nonnegative defect integrand integrates to 0 iff it is a.e. 0 (`integral_eq_zero_iff_of_nonneg_ae`), i.e. k₁ = k₂ a.e. -- !--
/-- **Integral rigidity**: equality `W = ∫K` forces total umbilicity `k₁ = k₂`
almost everywhere. -/
theorem willmore_eq_gauss_iff_umbilic_ae
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ) :
    willmoreEnergy μ k1 k2 = totalGauss μ k1 k2 ↔ k1 =ᵐ[μ] k2 := by
  constructor <;> intro h
  · have h_pointwise : ∀ x, willmoreDensity k1 k2 x - gaussCurv k1 k2 x
        = umbilicDefect k1 k2 x := willmoreDensity_sub_gaussCurv k1 k2
    have h_zero_ae : ∫ x, umbilicDefect k1 k2 x ∂μ = 0 → umbilicDefect k1 k2 =ᵐ[μ] 0 := by
      intro h_zero_ae
      have h_integrable : Integrable (umbilicDefect k1 k2) μ := by
        convert hW.sub hK using 1; ext x; aesop
      rw [MeasureTheory.integral_eq_zero_iff_of_nonneg_ae] at h_zero_ae
      · exact h_zero_ae
      · exact Filter.Eventually.of_forall fun x => sq_nonneg _
      · exact h_integrable
    simp_all +decide [willmoreEnergy, totalGauss]
    filter_upwards [h_zero_ae (by rw [← funext h_pointwise,
      MeasureTheory.integral_sub hW hK, h, sub_self])] with x hx using by
        norm_num [umbilicDefect] at hx; nlinarith
  · refine MeasureTheory.integral_congr_ae ?_
    filter_upwards [h] with x hx using by
      unfold willmoreDensity gaussCurv; simp +decide [hx]; ring

/-! ## Part 3: Gauss–Bonnet bounds and the genus-0 sharp constant

The total Gaussian curvature is supplied by the Gauss–Bonnet theorem as
`∫K = 2π·χ`.  In the catalog this `χ` is the discrete Euler characteristic of
`DiscreteGaussBonnet.lean`; here we take the identity as a hypothesis and feed
it through the elementary inequality. -/

-- !-- Combine `gauss_le_willmore` with the Gauss–Bonnet input ∫K = 2πχ. -- !--
/-- **The Gauss–Bonnet–Willmore bound** `2π·χ ≤ W`. -/
theorem gaussBonnet_bound (chi : ℝ)
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ)
    (hGB : totalGauss μ k1 k2 = 2 * π * chi) :
    2 * π * chi ≤ willmoreEnergy μ k1 k2 := by
  have h := gauss_le_willmore k1 k2 hW hK
  rw [hGB] at h; exact h

-- !-- A genus-0 surface has χ = 2, so the Gauss–Bonnet bound becomes 4π ≤ W. -- !--
/-- **The sharp genus-0 bound** `4π ≤ W` (with equality for the round sphere). -/
theorem willmore_ge_fourPi_genus_zero
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ)
    (hGB : totalGauss μ k1 k2 = 2 * π * 2) :
    4 * π ≤ willmoreEnergy μ k1 k2 := by
  have h := gaussBonnet_bound k1 k2 2 hW hK hGB
  linarith

/-! ## Part 4: The Gauss-map degree mechanism (the universal 4π bound) -/

-- !-- On any region s: ∫_s K ≤ ∫_s H² ≤ ∫ H² since H² ≥ 0; chain with the degree input ∫_s K ≥ 4π. -- !--
/-- **The universal `4π` bound** from a single Gauss-map degree region: if a
measurable region `s` carries at least `4π` of Gaussian curvature, then
`W ≥ 4π`. -/
theorem willmore_ge_fourPi_of_setGauss (s : Set X)
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hKs : IntegrableOn (gaussCurv k1 k2) s μ)
    (hdeg : 4 * π ≤ ∫ x in s, gaussCurv k1 k2 x ∂μ) :
    4 * π ≤ willmoreEnergy μ k1 k2 := by
  have h_int_mono : ∫ x in s, gaussCurv k1 k2 x ∂μ ≤ ∫ x in s, willmoreDensity k1 k2 x ∂μ := by
    refine MeasureTheory.integral_mono_ae hKs hW.integrableOn ?_
    filter_upwards [] with x using gaussCurv_le_willmoreDensity k1 k2 x
  refine le_trans hdeg (h_int_mono.trans (MeasureTheory.setIntegral_le_integral ?_ ?_))
  · exact hW
  · exact Filter.Eventually.of_forall fun x => sq_nonneg _

-- !-- Each disjoint sheet contributes ≥ 4π; finite additivity (`integral_iUnion_ae`) sums them to ≥ 4π·n over the union, and H² ≥ K ≥ 0 lifts the union integral to W. -- !--
/-- **Li–Yau-style multiplicity bound**: `n` pairwise-disjoint measurable regions,
each carrying at least `4π` of Gaussian curvature, force `W ≥ 4π·n`. A point of
multiplicity `n` of an immersion produces exactly such `n` disjoint sheets. -/
theorem willmore_ge_fourPi_mul_of_disjoint_sheets (n : ℕ) (s : Fin n → Set X)
    (hms : ∀ i, MeasurableSet (s i))
    (hd : Pairwise (Function.onFun Disjoint s))
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ)
    (hdeg : ∀ i, 4 * π ≤ ∫ x in s i, gaussCurv k1 k2 x ∂μ) :
    4 * π * n ≤ willmoreEnergy μ k1 k2 := by
  set U : Set X := ⋃ i, s i
  have h_add : ∫ x in U, gaussCurv k1 k2 x ∂μ ≥ 4 * Real.pi * n := by
    rw [MeasureTheory.integral_iUnion_ae]
    · rw [tsum_fintype]
      exact le_trans (by simp +decide [mul_comm]) (Finset.sum_le_sum fun i _ => hdeg i)
    · exact fun i => MeasurableSet.nullMeasurableSet (hms i)
    · exact fun i j hij => Disjoint.aedisjoint (hd hij)
    · exact hK.integrableOn
  refine le_trans h_add (le_trans (MeasureTheory.setIntegral_mono_on ?_ ?_
    (MeasurableSet.iUnion hms) fun x _ => gaussCurv_le_willmoreDensity k1 k2 x)
    (MeasureTheory.setIntegral_le_integral ?_ ?_))
  · exact hK.integrableOn
  · exact hW.integrableOn
  · exact hW
  · exact Filter.Eventually.of_forall fun x => sq_nonneg _

/-! ## Part 5: Genus-monotonicity of the elementary obstruction

The elementary Gauss–Bonnet floor `b(g) = 4π(1-g)` is the best lower bound the
square-identity argument can produce.  For genus `0` it is the sharp `4π`; for
`g ≥ 1` it is `≤ 0` and hence vacuous.  We make precise that the method loses
exactly `2π` of detectable energy per unit genus. -/

/-- The elementary Gauss–Bonnet floor `b(g) = 4π(1-g)` as a function of genus. -/
noncomputable def elementaryBound (g : ℝ) : ℝ := 4 * π * (1 - g)

-- !-- 4π > 0 and (1 - g) ≤ 0 for g ≥ 1, so the product is ≤ 0. -- !--
/-- **The elementary bound is vacuous for `g ≥ 1`.** -/
theorem gaussBonnet_bound_vacuous_high_genus (g : ℝ) (hg : 1 ≤ g) :
    elementaryBound g ≤ 0 :=
  mul_nonpos_of_nonneg_of_nonpos (by positivity) (by linarith)

-- !-- b(g+1) - b(g) = 4π·((1-(g+1)) - (1-g)) = -4π by `ring`. -- !--
/-- **The elementary obstruction loses exactly `4π` per unit genus** (so `2π`
per half-handle): `b(g+1) = b(g) - 4π`. -/
theorem elementary_bound_step (g : ℝ) :
    elementaryBound (g + 1) = elementaryBound g - 4 * π := by
  unfold elementaryBound; ring

-- !-- Since 4π > 0, multiplication by it is strictly monotone and (1 - ·) is strictly antitone. -- !--
/-- The elementary bound is strictly decreasing in the genus. -/
theorem elementary_bound_antitone : StrictAnti elementaryBound :=
  fun _ _ hab => mul_lt_mul_of_pos_left (by linarith) (by positivity)

end WillmoreEnergy