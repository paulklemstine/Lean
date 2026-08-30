import Combinatorics.FisherSimplexCurvature

/-!
# Identifiability first, curvature second: exponential sensitivity is *not* negative curvature

This file is the methodological payload of the project.  It separates two
properties of a statistical model that are routinely (and wrongly) conflated:

* **exponential sensitivity / identifiability** — distinct parameter values become
  distinguishable at an exponential rate from i.i.d. samples;
* **negative curvature** — the Fisher–Rao geometry is hyperbolic.

For the concrete trinomial (finite-support) model we prove that the *first* holds
in the strongest possible form while the *second* **fails everywhere**:

* `hellinger_affinity_prod` : the Hellinger affinity of the `n`-fold product model
  is exactly `ρⁿ`, where `ρ = Σ_a √(p_a q_a)`;
* `rho_lt_one` : `ρ < 1` whenever the two parameter points differ, so the two
  product models separate **exponentially fast** in the sample size;
* `gaussianCurvature_pos`, `no_constant_negative_curvature` : nevertheless the
  Gauss curvature is the constant `+1/4` — there is *no* point of the simplex, and
  *no* value of Amari's `α` with `|α| ≤ 1`, at which the curvature is negative;
* `fisher_metric_unbounded` : the Fisher metric coefficients blow up at the
  boundary, i.e. the model *is* arbitrarily sensitive, again with no effect on the
  sign of the curvature;
* `exponential_sensitivity_with_positive_curvature` : the two facts packaged as a
  single theorem, which is precisely the counterexample to the inference
  "exponential sensitivity ⟹ constant negative curvature".

The structural explanation is supplied by the sphere embedding
`sphereMap p = 2(√p₁, √p₂, √p₃)`: it lands in the sphere of radius `2`
(`sphereMap_normSq`), its pullback is the Fisher metric
(`pullback_eq_fisher`), and the Hellinger affinity is exactly the normalised
Euclidean inner product of the embedded points (`rho_eq_inner_div_four`).  So the
exponential rate `ρ` is a *cosine of a spherical angle* — a positively curved
quantity all along.
-/

open Finset TrinomialFisher

noncomputable section

namespace FisherIdentifiability

/-! ## 1. The open simplex -/

/-- The open parameter domain of the trinomial model. -/
def OpenSimplex (x y : ℝ) : Prop := 0 < x ∧ 0 < y ∧ 0 < 1 - x - y

theorem OpenSimplex.x_ne (h : OpenSimplex x y) : x ≠ 0 := ne_of_gt h.1
theorem OpenSimplex.y_ne (h : OpenSimplex x y) : y ≠ 0 := ne_of_gt h.2.1
theorem OpenSimplex.z_ne (h : OpenSimplex x y) : 1 - x - y ≠ 0 := ne_of_gt h.2.2

theorem prob_pos (h : OpenSimplex x y) (a : Fin 3) : 0 < prob a x y := by
  fin_cases a <;> simp only [prob] <;> [exact h.1; exact h.2.1; exact h.2.2]

theorem prob_nonneg (h : OpenSimplex x y) (a : Fin 3) : 0 ≤ prob a x y :=
  (prob_pos h a).le

/-! ## 2. The curvature is positive everywhere; no negative-curvature claim survives -/

/-- The Gauss curvature of the trinomial Fisher–Rao metric is strictly positive. -/
theorem gaussianCurvature_pos (h : OpenSimplex x y) : 0 < gaussianCurvature x y := by
  rw [gaussianCurvature_eq x y h.x_ne h.y_ne h.z_ne]
  norm_num

/-- **No point of the model is negatively curved.** -/
theorem no_negative_curvature : ¬ ∃ x y : ℝ, OpenSimplex x y ∧ gaussianCurvature x y < 0 := by
  rintro ⟨x, y, h, hlt⟩
  exact absurd hlt (not_lt.2 (gaussianCurvature_pos h).le)

/-- **The "constant negative curvature" claim is false for this model**, for every
negative constant. -/
theorem no_constant_negative_curvature (c : ℝ) (hc : c < 0) :
    ¬ ∀ x y : ℝ, OpenSimplex x y → gaussianCurvature x y = c := by
  intro hall
  have h : OpenSimplex (1 / 3) (1 / 3) := by
    refine ⟨by norm_num, by norm_num, by norm_num⟩
  have := hall (1 / 3) (1 / 3) h
  rw [gaussianCurvature_eq _ _ h.x_ne h.y_ne h.z_ne] at this
  linarith

/-- Over Amari's whole `α`-family the curvature is nonnegative exactly on `|α| ≤ 1`. -/
theorem alphaCurv_nonneg (a : ℝ) (ha : |a| ≤ 1) (h : OpenSimplex x y) :
    0 ≤ alphaCurv a x y := by
  rw [alphaCurv_eq a x y h.x_ne h.y_ne h.z_ne]
  have : a ^ 2 ≤ 1 := by
    have := abs_nonneg a
    nlinarith [sq_abs a]
  linarith

/-- The `α`-curvature is negative *only* outside the statistically meaningful range
`|α| ≤ 1`; inside it, no negative curvature ever occurs. -/
theorem alphaCurv_neg_iff (a : ℝ) (h : OpenSimplex x y) :
    alphaCurv a x y < 0 ↔ 1 < |a| := by
  rw [alphaCurv_eq a x y h.x_ne h.y_ne h.z_ne]
  constructor
  · intro hlt
    have h1 : 1 < a ^ 2 := by linarith
    nlinarith [sq_abs a, abs_nonneg a]
  · intro hlt
    have : 1 < a ^ 2 := by nlinarith [sq_abs a, abs_nonneg a]
    linarith

/-! ## 3. The model *is* arbitrarily sensitive: the Fisher metric is unbounded -/

/-- **Unbounded sensitivity.**  The Fisher information of the first coordinate
exceeds any prescribed bound somewhere in the open simplex.  So "the model is
extremely sensitive near the boundary" is true — and, by the previous section,
carries no negative-curvature consequence whatsoever. -/
theorem fisher_metric_unbounded (M : ℝ) :
    ∃ x y : ℝ, OpenSimplex x y ∧ M < gL 0 0 x y := by
  set c : ℝ := max M 0 with hc
  have hc0 : 0 ≤ c := le_max_right _ _
  have hcM : M ≤ c := le_max_left _ _
  refine ⟨1 / (c + 4), 1 / 4, ⟨by positivity, by norm_num, ?_⟩, ?_⟩
  · have h1 : 1 / (c + 4) ≤ 1 / 4 := by
      apply one_div_le_one_div_of_le <;> linarith
    linarith
  · have hx : (0 : ℝ) < 1 / (c + 4) := by positivity
    have hz : (0 : ℝ) < 1 - 1 / (c + 4) - 1 / 4 := by
      have h1 : 1 / (c + 4) ≤ 1 / 4 := by
        apply one_div_le_one_div_of_le <;> linarith
      linarith
    have hval : gL 0 0 (1 / (c + 4)) (1 / 4) = (c + 4) + 1 / (1 - 1 / (c + 4) - 1 / 4) := by
      simp only [gL]
      rw [one_div_one_div]
    rw [hval]
    have : 0 < 1 / (1 - 1 / (c + 4) - 1 / 4) := by positivity
    linarith

/-! ## 4. Hellinger affinity: exponential separation of the product models -/

/-- The Hellinger affinity `ρ = Σ_a √(p_a) √(q_a)` of two parameter points. -/
def rho (x y x' y' : ℝ) : ℝ :=
  ∑ a : Fin 3, Real.sqrt (prob a x y) * Real.sqrt (prob a x' y')

/-- The `n`-fold i.i.d. product model on `Fin n → Fin 3`. -/
def probN (n : ℕ) (ω : Fin n → Fin 3) (x y : ℝ) : ℝ := ∏ i : Fin n, prob (ω i) x y

/-- **Tensorisation of the Hellinger affinity.**  The affinity of the `n`-fold
product model is exactly `ρⁿ`. -/
theorem hellinger_affinity_prod (n : ℕ) (x y x' y' : ℝ)
    (h : OpenSimplex x y) (h' : OpenSimplex x' y') :
    ∑ ω : Fin n → Fin 3, Real.sqrt (probN n ω x y * probN n ω x' y') = rho x y x' y' ^ n := by
  have hfun : ∀ ω : Fin n → Fin 3, Real.sqrt (probN n ω x y * probN n ω x' y')
      = ∏ i : Fin n, (Real.sqrt (prob (ω i) x y) * Real.sqrt (prob (ω i) x' y')) := by
    intro ω
    rw [probN, probN, ← Finset.prod_mul_distrib,
      Real.sqrt_prod _ (fun i _ => mul_nonneg (prob_nonneg h _) (prob_nonneg h' _))]
    exact Finset.prod_congr rfl fun i _ => Real.sqrt_mul (prob_nonneg h _) _
  rw [Finset.sum_congr rfl fun ω _ => hfun ω]
  exact (Fintype.sum_pow (fun a : Fin 3 =>
    Real.sqrt (prob a x y) * Real.sqrt (prob a x' y')) n).symm

/-- The affinity written as `1 - ½ Σ (√p - √q)²`: the Hellinger distance identity. -/
theorem rho_eq_one_sub (x y x' y' : ℝ) (h : OpenSimplex x y) (h' : OpenSimplex x' y') :
    rho x y x' y' = 1 - (1 / 2) *
      ∑ a : Fin 3, (Real.sqrt (prob a x y) - Real.sqrt (prob a x' y')) ^ 2 := by
  have hsq : ∀ a : Fin 3, Real.sqrt (prob a x y) ^ 2 = prob a x y := fun a =>
    Real.sq_sqrt (prob_nonneg h a)
  have hsq' : ∀ a : Fin 3, Real.sqrt (prob a x' y') ^ 2 = prob a x' y' := fun a =>
    Real.sq_sqrt (prob_nonneg h' a)
  have h1 := sum_prob x y
  have h2 := sum_prob x' y'
  simp only [rho, Fin.sum_univ_three] at *
  rw [sub_sq, sub_sq, sub_sq, hsq 0, hsq 1, hsq 2, hsq' 0, hsq' 1, hsq' 2]
  linarith

theorem rho_le_one (x y x' y' : ℝ) (h : OpenSimplex x y) (h' : OpenSimplex x' y') :
    rho x y x' y' ≤ 1 := by
  rw [rho_eq_one_sub x y x' y' h h']
  have : 0 ≤ ∑ a : Fin 3, (Real.sqrt (prob a x y) - Real.sqrt (prob a x' y')) ^ 2 :=
    Finset.sum_nonneg fun a _ => sq_nonneg _
  linarith

theorem rho_pos (x y x' y' : ℝ) (h : OpenSimplex x y) (h' : OpenSimplex x' y') :
    0 < rho x y x' y' := by
  refine Finset.sum_pos (fun a _ => ?_) ⟨0, Finset.mem_univ 0⟩
  exact mul_pos (Real.sqrt_pos.2 (prob_pos h a)) (Real.sqrt_pos.2 (prob_pos h' a))

/-- **Strict contraction.**  Distinct parameter points have affinity `< 1`. -/
theorem rho_lt_one (x y x' y' : ℝ) (h : OpenSimplex x y) (h' : OpenSimplex x' y')
    (hne : x ≠ x') : rho x y x' y' < 1 := by
  have hsqrt : Real.sqrt x ≠ Real.sqrt x' := by
    intro hEq
    exact hne (by
      have := congrArg (fun t => t ^ 2) hEq
      simpa [Real.sq_sqrt h.1.le, Real.sq_sqrt h'.1.le] using this)
  have hterm : 0 < (Real.sqrt (prob 0 x y) - Real.sqrt (prob 0 x' y')) ^ 2 := by
    have : Real.sqrt (prob 0 x y) - Real.sqrt (prob 0 x' y') ≠ 0 := by
      simp only [prob]
      exact sub_ne_zero.2 hsqrt
    positivity
  have hsum : 0 < ∑ a : Fin 3, (Real.sqrt (prob a x y) - Real.sqrt (prob a x' y')) ^ 2 := by
    simp only [Fin.sum_univ_three]
    have h1 := sq_nonneg (Real.sqrt (prob 1 x y) - Real.sqrt (prob 1 x' y'))
    have h2 := sq_nonneg (Real.sqrt (prob 2 x y) - Real.sqrt (prob 2 x' y'))
    linarith
  rw [rho_eq_one_sub x y x' y' h h']
  linarith

/-- **Exponential distinguishability.**  For distinct parameter points the Hellinger
affinity of the `n`-fold product model tends to `0` geometrically. -/
theorem affinity_tendsto_zero (x y x' y' : ℝ) (h : OpenSimplex x y) (h' : OpenSimplex x' y')
    (hne : x ≠ x') :
    Filter.Tendsto
      (fun n : ℕ => ∑ ω : Fin n → Fin 3, Real.sqrt (probN n ω x y * probN n ω x' y'))
      Filter.atTop (nhds 0) := by
  have hr0 : 0 < rho x y x' y' := rho_pos x y x' y' h h'
  have hr1 : rho x y x' y' < 1 := rho_lt_one x y x' y' h h' hne
  have := tendsto_pow_atTop_nhds_zero_of_lt_one hr0.le hr1
  refine this.congr fun n => ?_
  exact (hellinger_affinity_prod n x y x' y' h h').symm

/-! ## 5. The structural reason: the model is a piece of the sphere of radius 2 -/

/-- The Hellinger/Bhattacharyya embedding `p ↦ 2(√p₁, √p₂, √p₃)`. -/
def sphereMap (a : Fin 3) (x y : ℝ) : ℝ := 2 * Real.sqrt (prob a x y)

/-- The embedding lands on the Euclidean sphere of radius `2`. -/
theorem sphereMap_normSq (x y : ℝ) (h : OpenSimplex x y) :
    ∑ a : Fin 3, sphereMap a x y ^ 2 = 4 := by
  have hsq : ∀ a : Fin 3, Real.sqrt (prob a x y) ^ 2 = prob a x y := fun a =>
    Real.sq_sqrt (prob_nonneg h a)
  have h1 := sum_prob x y
  simp only [sphereMap, Fin.sum_univ_three, mul_pow] at *
  rw [hsq 0, hsq 1, hsq 2]
  linarith

/-- Partial derivatives of the embedding. -/
def dSphere : Fin 2 → Fin 3 → ℝ → ℝ → ℝ
  | 0, 0, x, _ => 1 / Real.sqrt x
  | 0, 1, _, _ => 0
  | 0, 2, x, y => -1 / Real.sqrt (1 - x - y)
  | 1, 0, _, _ => 0
  | 1, 1, _, y => 1 / Real.sqrt y
  | 1, 2, x, y => -1 / Real.sqrt (1 - x - y)

theorem hasDerivAt_sphereMap_fst (a : Fin 3) (x y : ℝ) (h : OpenSimplex x y) :
    HasDerivAt (fun t => sphereMap a t y) (dSphere 0 a x y) x := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - t - y) (-1) x := by
    simpa using ((hasDerivAt_id x).const_sub (1 : ℝ)).sub_const y
  have hsx : Real.sqrt x ≠ 0 := ne_of_gt (Real.sqrt_pos.2 h.1)
  have hsz : Real.sqrt (1 - x - y) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 h.2.2)
  fin_cases a <;> simp only [sphereMap, prob, dSphere]
  · refine (((Real.hasDerivAt_sqrt h.x_ne).const_mul 2)).congr_deriv ?_
    field_simp
  · exact hasDerivAt_const x _
  · refine ((((Real.hasDerivAt_sqrt h.z_ne).comp x hlin)).const_mul 2).congr_deriv ?_
    field_simp

theorem hasDerivAt_sphereMap_snd (a : Fin 3) (x y : ℝ) (h : OpenSimplex x y) :
    HasDerivAt (fun t => sphereMap a x t) (dSphere 1 a x y) y := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - x - t) (-1) y := by
    simpa using (hasDerivAt_const y (1 - x)).sub (hasDerivAt_id y)
  have hsy : Real.sqrt y ≠ 0 := ne_of_gt (Real.sqrt_pos.2 h.2.1)
  have hsz : Real.sqrt (1 - x - y) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 h.2.2)
  fin_cases a <;> simp only [sphereMap, prob, dSphere]
  · exact hasDerivAt_const y _
  · refine (((Real.hasDerivAt_sqrt h.y_ne).const_mul 2)).congr_deriv ?_
    field_simp
  · refine ((((Real.hasDerivAt_sqrt h.z_ne).comp y hlin)).const_mul 2).congr_deriv ?_
    field_simp

/-- **The embedding is an isometry onto the sphere of radius 2:** the Euclidean
pullback of `sphereMap` is exactly the Fisher–Rao metric.  This is the structural
reason for `gaussianCurvature = 1/4 = 1/2²`. -/
theorem pullback_eq_fisher (i j : Fin 2) (x y : ℝ) (h : OpenSimplex x y) :
    ∑ a : Fin 3, dSphere i a x y * dSphere j a x y = gL i j x y := by
  have key : ∀ u : ℝ, 0 < u → 1 / Real.sqrt u * (1 / Real.sqrt u) = 1 / u := by
    intro u hu
    rw [div_mul_div_comm, Real.mul_self_sqrt hu.le]
    norm_num
  have keyn : ∀ u : ℝ, 0 < u → -1 / Real.sqrt u * (-1 / Real.sqrt u) = 1 / u := by
    intro u hu
    rw [div_mul_div_comm, Real.mul_self_sqrt hu.le]
    norm_num
  fin_cases i <;> fin_cases j <;>
    simp only [dSphere, gL, Fin.sum_univ_three, key x h.1, key y h.2.1,
      keyn (1 - x - y) h.2.2] <;> ring

/-- The Hellinger affinity is the normalised Euclidean inner product of the embedded
points: `ρ` is the cosine of the spherical angle between them. -/
theorem rho_eq_inner_div_four (x y x' y' : ℝ) :
    rho x y x' y' = (∑ a : Fin 3, sphereMap a x y * sphereMap a x' y') / 4 := by
  simp only [rho, sphereMap, Fin.sum_univ_three]
  ring

/-! ## 6. The separation theorem -/

/-- **Main separation theorem.**  For any two distinct points of the open trinomial
simplex, the `n`-fold product models separate at an exponential rate `rⁿ` with
`0 < r < 1` — maximal statistical sensitivity — while the Fisher–Rao geometry of the
model has *constant positive* Gauss curvature `1/4` at both points.  Hence
"exponential sensitivity" does **not** imply, and must be tested separately from,
"constant negative curvature". -/
theorem exponential_sensitivity_with_positive_curvature
    (x y x' y' : ℝ) (h : OpenSimplex x y) (h' : OpenSimplex x' y') (hne : x ≠ x') :
    (∃ r : ℝ, 0 < r ∧ r < 1 ∧ ∀ n : ℕ,
        ∑ ω : Fin n → Fin 3, Real.sqrt (probN n ω x y * probN n ω x' y') = r ^ n) ∧
      gaussianCurvature x y = 1 / 4 ∧ gaussianCurvature x' y' = 1 / 4 := by
  refine ⟨⟨rho x y x' y', rho_pos x y x' y' h h', rho_lt_one x y x' y' h h' hne,
    fun n => hellinger_affinity_prod n x y x' y' h h'⟩, ?_, ?_⟩
  · exact gaussianCurvature_eq x y h.x_ne h.y_ne h.z_ne
  · exact gaussianCurvature_eq x' y' h'.x_ne h'.y_ne h'.z_ne

end FisherIdentifiability