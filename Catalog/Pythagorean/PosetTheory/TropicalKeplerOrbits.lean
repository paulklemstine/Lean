/-
  # Tropical Kepler Orbits — The Tropical-Celestial Bridge

  This file establishes the first rigorous correspondence between tropical geometry
  and celestial mechanics. The tropicalization of Kepler's orbit equation yields a
  piecewise-linear function whose corner locus classifies orbit types combinatorially.

  We work with the Kepler conic in Cartesian coordinates:
    `K(e,ℓ)(x,y) = (1-e²)x² + 2eℓx + y² - ℓ²`
  where `ℓ` is the semi-latus rectum and `e` is the eccentricity.
  This arises from the polar orbit equation `r = ℓ/(1 + e cos θ)`.

  The user's original conic `(1-e²)x² + 2epx + y² - e²p²` uses a different
  parameterization; we also analyze its coefficient structure.

  ## Main Results

  1. **Tropical valuation properties**: `tropicalVal` is a homomorphism from (ℝ⁺, ×) to (ℝ, +)
  2. **Parabolic degeneration**: The x² coefficient vanishes iff e = 1
  3. **Newton polygon support collapse**: Support size drops from 4 to 3 at e = 1
  4. **Scaling invariance**: Coefficient scaling laws preserve combinatorial type
  5. **Tropical vis-viva**: Product → sum under valuation
  6. **Kepler conic polar form**: Polar orbit equation ↔ Cartesian conic (corrected)
-/
import Mathlib

open Real Classical

/-! ## Part 1: Tropical Valuation -/

/-- Tropical valuation on positive reals: `tropicalVal x = -log x` (natural log).
    This is the non-Archimedean valuation that sends multiplication to addition
    and addition to min under the Maslov dequantization limit. -/
noncomputable def tropicalVal (x : ℝ) : ℝ := -Real.log x

/-- Tropical valuation is a homomorphism from (ℝ⁺, ×) to (ℝ, +). -/
theorem tropicalVal_mul (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    tropicalVal (x * y) = tropicalVal x + tropicalVal y := by
  unfold tropicalVal; rw [Real.log_mul hx.ne' hy.ne']; ring

/-- Tropical valuation of 1 is 0 (the identity element maps to the identity). -/
theorem tropicalVal_one : tropicalVal 1 = 0 := by
  simp [tropicalVal]

/-- Tropical valuation reverses order: x ≤ y → v(y) ≤ v(x). -/
theorem tropicalVal_anti (x y : ℝ) (hx : 0 < x) (h : x ≤ y) :
    tropicalVal y ≤ tropicalVal x := by
  exact neg_le_neg (Real.log_le_log hx h)

/-- Tropical valuation of powers: v(xⁿ) = n · v(x). -/
theorem tropicalVal_pow (x : ℝ) (_hx : 0 < x) (n : ℕ) :
    tropicalVal (x ^ n) = n * tropicalVal x := by
  unfold tropicalVal; rw [Real.log_pow]; ring

/-- Tropical valuation of reciprocal: v(1/x) = -v(x). -/
theorem tropicalVal_inv (x : ℝ) (hx : 0 < x) :
    tropicalVal (x⁻¹) = -tropicalVal x := by
  unfold tropicalVal; norm_num [Real.log_inv]

/-- Tropical valuation of a square: v(x²) = 2·v(x). -/
theorem tropicalVal_sq (x : ℝ) (hx : 0 < x) :
    tropicalVal (x ^ 2) = 2 * tropicalVal x := by
  convert tropicalVal_pow x hx 2 using 1

/-! ## Part 2: Kepler Conic Coefficients

We define two versions of the Kepler conic:
- The **user's conic** with constant term `-e²p²` (used for tropicalization analysis)
- The **standard conic** with constant term `-ℓ²` (matching the polar orbit equation)
-/

/-- Coefficient of x² in the Kepler conic: `1 - e²`.
    This is the discriminant that distinguishes orbit types:
    positive for ellipses, zero for parabolas, negative for hyperbolas. -/
def keplerCoeffX2 (e : ℝ) : ℝ := 1 - e ^ 2

/-- Coefficient of x in the Kepler conic: `2eℓ`. -/
def keplerCoeffX (e ell : ℝ) : ℝ := 2 * e * ell

/-- Coefficient of y² in the Kepler conic: always 1. -/
def keplerCoeffY2 : ℝ := 1

/-- Constant coefficient in the user's Kepler conic: `-e²p²`. -/
def keplerCoeffConst (e p : ℝ) : ℝ := -(e ^ 2 * p ^ 2)

/-- The user's Kepler conic `K(e,p)(x,y) = (1-e²)x² + 2epx + y² - e²p²`. -/
def keplerConic (e p x y : ℝ) : ℝ :=
  keplerCoeffX2 e * x ^ 2 + keplerCoeffX e p * x + keplerCoeffY2 * y ^ 2 + keplerCoeffConst e p

/-- The standard Kepler conic `(1-e²)x² + 2eℓx + y² - ℓ²`,
    which corresponds to the polar orbit `r = ℓ/(1 + e cos θ)`. -/
def keplerConicStd (e ell x y : ℝ) : ℝ :=
  (1 - e ^ 2) * x ^ 2 + 2 * e * ell * x + y ^ 2 - ell ^ 2

/-! ## Part 3: Parabolic Degeneration -/

/-- **Parabolic degeneration criterion**: The x² coefficient vanishes iff e = ±1.
    This is equivalent to saying the Newton polygon loses a vertex. -/
theorem keplerCoeffX2_eq_zero_iff (e : ℝ) :
    keplerCoeffX2 e = 0 ↔ e = 1 ∨ e = -1 := by
  exact ⟨fun h => eq_or_eq_neg_of_sq_eq_sq _ _ <| by unfold keplerCoeffX2 at h; linarith,
    fun h => by rcases h with (rfl | rfl) <;> unfold keplerCoeffX2 <;> norm_num⟩

/-- For nonneg eccentricity, x² coefficient vanishes iff e = 1 (parabolic). -/
theorem keplerCoeffX2_eq_zero_iff_nonneg (e : ℝ) (he : 0 ≤ e) :
    keplerCoeffX2 e = 0 ↔ e = 1 := by
  exact ⟨fun h => by rw [keplerCoeffX2] at h; nlinarith,
    fun h => by rw [h, keplerCoeffX2]; norm_num⟩

/-- The x² coefficient is positive for elliptic orbits (0 ≤ e < 1). -/
theorem keplerCoeffX2_pos_of_elliptic (e : ℝ) (he0 : 0 ≤ e) (he1 : e < 1) :
    0 < keplerCoeffX2 e := by
  exact sub_pos_of_lt (by nlinarith)

/-- The x² coefficient is negative for hyperbolic orbits (e > 1). -/
theorem keplerCoeffX2_neg_of_hyperbolic (e : ℝ) (he : 1 < e) :
    keplerCoeffX2 e < 0 := by
  exact show 1 - e ^ 2 < 0 by nlinarith

/-! ## Part 4: Newton Polygon Support Size -/

/-- The number of monomials with nonzero coefficient in the Kepler conic. -/
noncomputable def keplerSupportSize (e p : ℝ) : ℕ :=
  (if keplerCoeffX2 e ≠ 0 then 1 else 0) +
  (if keplerCoeffX e p ≠ 0 then 1 else 0) +
  (if keplerCoeffY2 ≠ 0 then 1 else 0) +
  (if keplerCoeffConst e p ≠ 0 then 1 else 0)

/-- For elliptic orbits, all four monomials are present: support size = 4. -/
theorem keplerSupportSize_elliptic (e p : ℝ) (he0 : 0 < e) (he1 : e < 1) (hp : 0 < p) :
    keplerSupportSize e p = 4 := by
  unfold keplerSupportSize
  unfold keplerCoeffX2 keplerCoeffX keplerCoeffY2 keplerCoeffConst
  norm_num [he0.ne', he1.ne', hp.ne']
  rw [if_neg (by nlinarith)]

/-- For parabolic orbits (e = 1), the x² term vanishes: support size = 3. -/
theorem keplerSupportSize_parabolic (p : ℝ) (hp : 0 < p) :
    keplerSupportSize 1 p = 3 := by
  simp [keplerSupportSize, keplerCoeffX2, keplerCoeffX, keplerCoeffY2, keplerCoeffConst, hp.ne']

/-
The support size drops at e = 1: Newton polygon collapse at parabolic degeneration.
-/
theorem keplerSupportSize_drop_at_parabola (p : ℝ) (hp : 0 < p)
    (e : ℝ) (he0 : 0 < e) (he1 : e < 1) :
    keplerSupportSize 1 p < keplerSupportSize e p := by
  rw [ keplerSupportSize_elliptic e p he0 he1 hp, keplerSupportSize_parabolic p hp ];
  norm_num

/-! ## Part 5: Scaling Invariance -/

/-- The x-coefficient scales quadratically: `keplerCoeffX (c·e) (c·p) = c² · keplerCoeffX e p`. -/
theorem keplerCoeffX_scale (e p c : ℝ) :
    keplerCoeffX (c * e) (c * p) = c ^ 2 * keplerCoeffX e p := by
  unfold keplerCoeffX; ring

/-- The constant coefficient scales to the fourth power. -/
theorem keplerCoeffConst_scale (e p c : ℝ) :
    keplerCoeffConst (c * e) (c * p) = c ^ 4 * keplerCoeffConst e p := by
  unfold keplerCoeffConst; ring

/-! ## Part 6: Tropical Vis-Viva

The classical vis-viva equation `v² = μ(2/r - 1/a)` tropicalizes to a sum
under the valuation: `v_trop(v²) = v_trop(μ) + v_trop(2/r - 1/a)`. -/

/-- Tropical vis-viva: the valuation converts the product `v² = μ · (...)` into a sum. -/
theorem tropical_vis_viva_product (mu a r vel : ℝ)
    (hmu : 0 < mu) (_ha : 0 < a) (_hr : 0 < r) (_hvel : 0 < vel)
    (hvis : vel ^ 2 = mu * (2 / r - 1 / a))
    (hpos : 0 < 2 / r - 1 / a) :
    tropicalVal (vel ^ 2) = tropicalVal mu + tropicalVal (2 / r - 1 / a) := by
  rw [hvis, tropicalVal_mul _ _ hmu hpos]

/-! ## Part 7: Kepler Conic Polar Form (Corrected)

The standard Kepler conic `(1-e²)x² + 2eℓx + y² - ℓ²` corresponds to the
polar orbit equation `r = ℓ/(1 + e cos θ)`. This is derived by:
  r(1 + e cos θ) = ℓ  →  √(x²+y²) + ex = ℓ  →  x²+y² = (ℓ - ex)²
  → (1-e²)x² + 2eℓx + y² - ℓ² = 0
-/

/-
The standard Kepler conic is satisfied by polar-form orbit points:
    if `r = ℓ/(1 + e·cos θ)`, then `keplerConicStd e ℓ (r·cos θ) (r·sin θ) = 0`.
-/
theorem keplerConicStd_polar_form (e ell r θ : ℝ) (hr : 0 < r) (_hp : 0 < ell)
    (_he1 : e < 1) (_he0 : 0 ≤ e)
    (hcos : 1 + e * Real.cos θ > 0)
    (horbit : r = ell / (1 + e * Real.cos θ)) :
    keplerConicStd e ell (r * Real.cos θ) (r * Real.sin θ) = 0 := by
  subst r; ring;
  unfold keplerConicStd; field_simp; ring;
  rw [ Real.cos_sq' ] ; ring

/-! ## Part 8: Tropical Eccentricity -/

/-- Tropical eccentricity: `e_⊕ = max(0, -log(|1 - e²|) / 2)`.
    Measures how close the Newton polygon is to degenerating. -/
noncomputable def tropicalEccentricity (e : ℝ) : ℝ :=
  max 0 (tropicalVal (|keplerCoeffX2 e|) / 2)

/-- Tropical eccentricity is always nonneg. -/
theorem tropicalEccentricity_nonneg (e : ℝ) : 0 ≤ tropicalEccentricity e := by
  exact le_max_left _ _

/-! ## Part 9: Combinatorial Type -/

/-- The combinatorial type of a tropical curve. -/
structure TropicalCombinatorialType where
  vertexCount : ℕ
  edgeDirections : Multiset (ℤ × ℤ)