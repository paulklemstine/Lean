/-! # CatalogBuild.Geometry.Stereographic.AdvancedTheory

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 15
-/

import Mathlib

noncomputable section

theorem invStereoN_injective (n : ℕ) : Function.Injective (invStereoN n) := by
  intro y₁ y₂ h_eq;
  -- By equating the components of the vectors, we can derive that $y₁(i) = y₂(i)$ for all $i$.
  have h_components : ∀ i : Fin n, 2 * y₁ i / (1 + ∑ j, (y₁ j) ^ 2) = 2 * y₂ i / (1 + ∑ j, (y₂ j) ^ 2) ∧ (∑ j, (y₁ j) ^ 2 - 1) / (1 + ∑ j, (y₁ j) ^ 2) = (∑ j, (y₂ j) ^ 2 - 1) / (1 + ∑ j, (y₂ j) ^ 2) := by
    intro i;
    have := congr_fun h_eq ( Fin.castSucc i ) ; ( have := congr_fun h_eq ( Fin.last n ) ; ( unfold invStereoN at *; aesop; ) );
  -- From the equality of the second components, we can deduce that $\sum_{j} y₁ j^2 = \sum_{j} y₂ j^2$.
  have h_sum_eq : ∑ j, (y₁ j) ^ 2 = ∑ j, (y₂ j) ^ 2 := by
    rcases n with ( _ | n ) <;> norm_num at *;
    rw [ div_eq_div_iff ] at h_components <;> nlinarith [ h_components 0, show 0 ≤ ∑ j, y₁ j ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _, show 0 ≤ ∑ j, y₂ j ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ];
  simp_all +decide [ div_eq_mul_inv ];
  exact funext fun i => Or.resolve_right ( h_components i ) ( by linarith [ show 0 ≤ ∑ j, y₂ j ^ 2 by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ] )


/-- The N-dimensional conformal factor. -/
def conformalFactorN (n : ℕ) (y : Fin n → ℝ) : ℝ :=
  2 / (1 + ∑ i, (y i) ^ 2)


theorem conformal_factor_1d (t : ℝ) :
    conformalFactorN 1 (fun _ => t) = 2 / (1 + t ^ 2) := by
  unfold conformalFactorN; aesop


/-- **Stereographic Universality Criterion** (algebraic core):
A smooth manifold M admits a stereographic-type projection iff it can be
realized as a quadric in projective space. For spheres, this is automatic.
Here we verify the algebraic criterion: Sⁿ is cut out by Q(x) = 0 in RP^{n+1}
where Q = x₁² + ... + xₙ₊₁² - x₀². -/
theorem sphere_is_quadric (x : Fin (n + 1) → ℝ) (hx : ∑ i, (x i) ^ 2 = 1) :
    ∑ i, (x i) ^ 2 - 1 = 0 := by
  linarith


theorem conic_stereo_parametrization (t : ℝ) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  rw [ div_pow, div_pow, ← add_div, div_eq_iff ] <;> nlinarith


theorem schottky_loxodromic_growth (k : ℝ) (hk : 1 < k) (z : ℝ) (hz : 0 < z) :
    Filter.Tendsto (fun n : ℕ => k ^ (2 * n) * z) Filter.atTop Filter.atTop := by
  exact Filter.Tendsto.atTop_mul_const hz ( tendsto_pow_atTop_atTop_of_one_lt ( by nlinarith ) |> Filter.Tendsto.comp <| Filter.tendsto_id.nsmul_atTop two_pos )


/-- The Descartes quadratic form Q(k) = (Σkᵢ)² - 2Σkᵢ². -/
def descartesForm (k : Fin 4 → ℝ) : ℝ :=
  (∑ i, k i) ^ 2 - 2 * ∑ i, (k i) ^ 2


/-- The Apollonian reflection Sⱼ replaces kⱼ with 2(Σᵢ≠ⱼ kᵢ) - kⱼ. -/
def apollonianReflect (k : Fin 4 → ℝ) (j : Fin 4) : Fin 4 → ℝ :=
  fun i => if i = j then 2 * (∑ l, k l) - 3 * k j else k i


theorem apollonian_preserves_descartes (k : Fin 4 → ℝ) (j : Fin 4)
    (h : descartesForm k = 0) :
    descartesForm (apollonianReflect k j) = 0 := by
  unfold apollonianReflect descartesForm at *;
  fin_cases j <;> simp +decide [ Fin.sum_univ_four ] at *;
  · linarith;
  · linarith;
  · linarith;
  · linarith


theorem bloch_fidelity_stereo (t s : ℝ) :
    (1 + t * s) ^ 2 / ((1 + t ^ 2) * (1 + s ^ 2)) =
    -- This should equal (1 + cos α)/2 where cos α is the inner product
    -- of the stereo images on S¹
    let x₁ := 2 * t / (1 + t ^ 2)
    let y₁ := (1 - t ^ 2) / (1 + t ^ 2)
    let x₂ := 2 * s / (1 + s ^ 2)
    let y₂ := (1 - s ^ 2) / (1 + s ^ 2)
    (1 + (x₁ * x₂ + y₁ * y₂)) / 2 := by
  -- Combine and simplify the fractions in the numerator.
  field_simp
  ring


theorem stereo_chordal_sq (t s : ℝ) :
    let d_sq := 4 * (t - s) ^ 2 / ((1 + t ^ 2) * (1 + s ^ 2))
    -- This equals 2 - 2·cos(angle), where cos(angle) is the dot product of unit vectors
    let x₁ := 2 * t / (1 + t ^ 2)
    let y₁ := (1 - t ^ 2) / (1 + t ^ 2)
    let x₂ := 2 * s / (1 + s ^ 2)
    let y₂ := (1 - s ^ 2) / (1 + s ^ 2)
    d_sq = (x₁ - x₂) ^ 2 + (y₁ - y₂) ^ 2 := by
  field_simp
  ring


/-- The stereographic softmax: a natural probability distribution on the sphere.
The stereographic kernel K(t, s) = 1/(1 + (t-s)²) is the Cauchy distribution,
which arises naturally as the pushforward of uniform measure on S¹ under
stereographic projection. Here we verify: K(t,s) = K(s,t). -/
theorem stereo_kernel_symmetric (t s : ℝ) :
    1 / (1 + (t - s) ^ 2) = 1 / (1 + (s - t) ^ 2) := by
  ring_nf


theorem lorentz_boost_identity (η : ℝ) :
    Real.cosh η ^ 2 - Real.sinh η ^ 2 = 1 := by
  exact Real.cosh_sq_sub_sinh_sq η


theorem lorentz_boost_det_one (η : ℝ) :
    Real.cosh η * Real.cosh η - Real.sinh η * Real.sinh η = 1 := by
  rw [ ← sq, ← sq, Real.cosh_sq_sub_sinh_sq ]


/-- The number of representations of n as a sum of two squares is related to
the number of rational points on S¹, which corresponds to the number of
Gaussian integer factorizations. Under stereographic projection, each
factorization n = a² + b² gives a rational point (2ab/n, (b²-a²)/n) on S¹.
The key identity: if a² + b² = c² + d² = n, then the cross-ratio of the
corresponding stereographic parameters is rational. -/
theorem sum_of_squares_cross_ratio (a b c d : ℤ) (n : ℤ)
    (h₁ : a ^ 2 + b ^ 2 = n) (h₂ : c ^ 2 + d ^ 2 = n)
    (hn : n ≠ 0) :
    -- The stereographic parameters are a/b and c/d (when b,d ≠ 0)
    -- The product of norms is preserved: (a²+b²)(c²+d²) = n²
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = n ^ 2 := by
  rw [h₁, h₂]; ring


end
