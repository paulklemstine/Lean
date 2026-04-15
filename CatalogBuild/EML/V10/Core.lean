/-! # CatalogBuild.EML.V10.Core

Auto-generated from theorem catalog database.
Domain: EML/V10
Declarations: 31
-/

import Mathlib

noncomputable section

/-- [Section: ## Section 1: Fundamental Identities] -/
theorem eml_def (x y : ℝ) : eml x y = Real.exp x - Real.log y := rfl


theorem eml_exp (x : ℝ) : eml x 1 = Real.exp x := by simp [eml, Real.log_one]


theorem eml_zero_first (y : ℝ) : eml 0 y = 1 - Real.log y := by simp [eml]


theorem eml_legendre (x y : ℝ) : eml x (Real.exp y) = Real.exp x - y := by
  simp [eml, Real.log_exp]


theorem eml_self_pair_eq (x : ℝ) : eml x (Real.exp x) = emlSelfPair x := by
  simp [eml, emlSelfPair, Real.log_exp]


/-- σ is strictly convex. -/
theorem emlSelfPair_strictConvex : StrictConvexOn ℝ Set.univ emlSelfPair := by
  apply strictConvexOn_of_deriv2_pos (convex_univ)
  · exact (Real.continuous_exp.sub continuous_id).continuousOn
  · intro x _
    show 0 < (deriv ∘ deriv) emlSelfPair x
    simp only [Function.comp]
    have : deriv emlSelfPair = fun x => Real.exp x - 1 := by
      ext y; exact (Real.hasDerivAt_exp y).sub (hasDerivAt_id y)
        |>.congr_deriv (by ring) |>.deriv
    rw [this]
    have : deriv (fun x => Real.exp x - 1) x = Real.exp x := by
      exact ((Real.hasDerivAt_exp x).sub (hasDerivAt_const x 1)
        |>.congr_deriv (by ring)).deriv
    rw [this]; exact Real.exp_pos x


/-- σ'(x) = eˣ − 1. -/
theorem emlSelfPair_deriv (x : ℝ) :
    HasDerivAt emlSelfPair (Real.exp x - 1) x := by
  unfold emlSelfPair
  exact (Real.hasDerivAt_exp x).sub (hasDerivAt_id x) |>.congr_deriv (by ring)


/-- d(z) ≥ z + 1 for all z. -/
theorem emlDiag_ge_add_one (z : ℝ) : emlDiag z ≥ z + 1 := by
  unfold emlDiag
  by_cases hz : 0 < z
  · have h5 : Real.exp z ≥ 1 + z + z ^ 2 / 2 := by
      rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
      exact le_trans (by norm_num [Finset.sum_range_succ])
        (Summable.sum_le_tsum (Finset.range 3)
          (fun i _ => by positivity)
          (Real.summable_pow_div_factorial z))
    nlinarith [Real.log_le_sub_one_of_pos hz, sq_nonneg (z - 1)]
  · push_neg at hz
    by_cases hz0 : z = 0
    · subst hz0; simp
    · rw [show Real.log z = Real.log (-z) from by rw [← Real.log_neg_eq_log]]
      linarith [Real.exp_pos z,
        Real.log_le_sub_one_of_pos (neg_pos.mpr (lt_of_le_of_ne hz hz0))]


/-- Orbit linear divergence: dⁿ(z) ≥ z + n. -/
theorem emlDiag_orbit_diverge (z : ℝ) (n : ℕ) :
    emlDiagIter n z ≥ z + n := by
  induction n with
  | zero => simp [emlDiagIter]
  | succ n ih =>
    simp only [emlDiagIter]
    push_cast; linarith [emlDiag_ge_add_one (emlDiagIter n z)]


/-- The gap function gap(z) = eᶻ − ln(z) − z ≥ 1. -/
theorem emlGap_ge_one (z : ℝ) : Real.exp z - Real.log z - z ≥ 1 := by
  have := emlDiag_ge_add_one z; unfold emlDiag at this; linarith


/-- The orbit is strictly increasing. -/
theorem emlDiag_orbit_strictMono (z : ℝ) : StrictMono (fun n => emlDiagIter n z) := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [emlDiagIter]; exact emlDiag_gt _


/-- [Section: ## Section 5: Monotonicity] -/
theorem eml_strictMono_x (y : ℝ) : StrictMono (fun x => eml x y) := by
  intro a b hab; simp only [eml]; linarith [Real.exp_lt_exp.mpr hab]


theorem eml_strictAnti_y (x : ℝ) : StrictAntiOn (fun y => eml x y) (Set.Ioi 0) := by
  intro a ha b _ hab; simp only [eml]
  linarith [Real.log_lt_log (Set.mem_Ioi.mp ha) hab]


/-- [Section: ## Section 6: Magma Properties] -/
theorem eml_noncomm : ∃ x y : ℝ, eml x y ≠ eml y x := by
  use 0, 1; simp [eml]; exact Ne.symm (by norm_num)


theorem eml_nonassoc : ∃ x y z : ℝ, eml (eml x y) z ≠ eml x (eml y z) := by
  unfold eml; by_contra! h; have := h 0 0 0; norm_num at this


theorem eml_no_left_id : ¬∃ e₀ : ℝ, ∀ x : ℝ, eml e₀ x = x := by
  intro ⟨e₀, he₀⟩
  have h0 := he₀ 1; have h1 := he₀ (Real.exp 1)
  simp [eml] at h0 h1; subst h0; simp at h1; linarith [Real.exp_one_gt_d9]


theorem eml_no_right_id : ¬∃ e₀ : ℝ, ∀ x : ℝ, eml x e₀ = x := by
  intro ⟨e₀, he₀⟩
  have h0 := he₀ 0; have h1 := he₀ 1
  simp [eml] at h0 h1; linarith [Real.exp_one_gt_d9]


/-- The EML magma (ℝ, eml) has no finite sub-magma. -/
theorem eml_no_finite_submagma :
    ¬∃ (S : Finset ℝ), S.Nonempty ∧ ∀ x ∈ S, ∀ y ∈ S, eml x y ∈ S := by
  intro ⟨S, ⟨x, hx⟩, hclosed⟩
  have h_in : ∀ n, emlDiagIter n x ∈ S := by
    intro n; induction n with
    | zero => exact hx
    | succ n ih => simp only [emlDiagIter, emlDiag]; exact hclosed _ ih _ ih
  have h_strict : StrictMono (fun n => emlDiagIter n x) := emlDiag_orbit_strictMono x
  have h_inj : Function.Injective (fun n => emlDiagIter n x) := h_strict.injective
  exact Set.infinite_of_injective_forall_mem h_inj h_in S.finite_toSet


/-- EML is the unique function satisfying the Legendre bridge. -/
theorem eml_unique_legendre {F : ℝ → ℝ → ℝ}
    (hF : ∀ x y, F x (Real.exp y) = Real.exp x - y)
    (x y : ℝ) (hy : 0 < y) : F x y = eml x y := by
  have h := hF x (Real.log y); rw [Real.exp_log hy] at h; rw [h]; simp [eml]


/-- [Section: ## Section 9: Trace Theory] -/
theorem eml_trace (x y : ℝ) :
    eml x y + eml y x = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  unfold eml; ring


theorem eml_trace_ge_two (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    eml x y + eml y x ≥ 2 := by
  rw [eml_trace]
  linarith [Real.add_one_le_exp x, Real.add_one_le_exp y,
            Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy]


/-- Shannon entropy term decomposition. -/
theorem eml_entropy_term (p : ℝ) :
    -p * Real.log p = p * eml 0 p - p := by
  unfold eml; simp; ring


/-- KL divergence term via EML. -/
theorem eml_kl_term (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    p * Real.log (p / q) = p * (eml 0 q - eml 0 p) := by
  unfold eml; rw [Real.log_div hp.ne' hq.ne']; ring


theorem eml_generates_ee : eml (eml 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [eml, Real.log_one]


theorem eTower_is_eml (n : ℕ) : eTower (n + 1) = eml (eTower n) 1 := by
  simp [eTower, eml, Real.log_one]


/-- ∫₀¹ eml(t, 1) dt = e − 1. -/
theorem eml_integral_unit :
    ∫ t in (0:ℝ)..1, eml t 1 = Real.exp 1 - 1 := by
  simp [eml, Real.log_one]


/-- D_exp as EML difference. -/
theorem bregman_as_eml (x y : ℝ) :
    Real.exp x - Real.exp y - Real.exp y * (x - y) =
    (eml x 1 - eml y 1) - Real.exp y * (x - y) := by
  simp [eml, Real.log_one]


/-- [Section: ## Section 14: Level Sets and Zero Set] -/
theorem eml_level_nonempty (c : ℝ) : ∃ x y : ℝ, 0 < y ∧ eml x y = c := by
  use 0, Real.exp (1 - c)
  exact ⟨Real.exp_pos _, by simp [eml, Real.log_exp]⟩


theorem eml_level_parametrize (x c : ℝ) :
    eml x (Real.exp (Real.exp x - c)) = c := by
  simp [eml, Real.log_exp]


theorem eml_zero_set (x y : ℝ) (hy : 0 < y) :
    eml x y = 0 ↔ y = Real.exp (Real.exp x) := by
  constructor
  · intro h; simp [eml] at h
    have : Real.log y = Real.exp x := by linarith
    rw [← this, Real.exp_log hy]
  · intro h; subst h; simp [eml, Real.log_exp]


/-- exp(x) ≥ 1 + x + x²/2 for x ≥ 0. -/
theorem exp_taylor_lower (x : ℝ) (hx : 0 ≤ x) :
    Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
  rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
  exact le_trans (by norm_num [Finset.sum_range_succ])
    (Summable.sum_le_tsum (Finset.range 3)
      (fun i _ => by positivity)
      (Real.summable_pow_div_factorial x))


end
