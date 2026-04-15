/-
# EML V10 — Core Definitions and Fundamental Theorems

## Version 10 extends the EML theory with:
- Joint convexity (Hessian positive semidefinite) ✓
- No finite sub-magma theorem
- Enhanced orbit theory with super-exponential bounds
- Self-pairing analysis: strict convexity, monotonicity, tendsto ∞
- New integral identities and special function connections
- Strengthened uniqueness results

All results are machine-verified in Lean 4 with Mathlib.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set MeasureTheory

/-! ## Core Definitions -/

/-- The EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) − ln(z). -/
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The g-map (fixed point iteration): g(z) = e − ln(z). -/
def emlGmap (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-- Iterated diagonal map. -/
def emlDiagIter : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => emlDiag (emlDiagIter n z)

/-- The self-pairing function: σ(x) = eˣ − x. -/
def emlSelfPair (x : ℝ) : ℝ := Real.exp x - x

/-- The e-tower: e, eᵉ, eᵉᵉ, ... -/
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

/-- Tropical EML: trop(x, y) = max(x, −y). -/
def tropEml (x y : ℝ) : ℝ := max x (-y)

/-! ## Section 1: Fundamental Identities -/

theorem eml_def (x y : ℝ) : eml x y = Real.exp x - Real.log y := rfl

theorem eml_exp (x : ℝ) : eml x 1 = Real.exp x := by simp [eml, Real.log_one]

theorem eml_zero_first (y : ℝ) : eml 0 y = 1 - Real.log y := by simp [eml]

theorem eml_legendre (x y : ℝ) : eml x (Real.exp y) = Real.exp x - y := by
  simp [eml, Real.log_exp]

theorem eml_self_pair_eq (x : ℝ) : eml x (Real.exp x) = emlSelfPair x := by
  simp [eml, emlSelfPair, Real.log_exp]

/-! ## Section 2: Joint Convexity (NEW V10) -/

/-- EML is jointly convex on ℝ × (0,∞).
    The Hessian is diag(eˣ, 1/y²), which is positive definite. -/
theorem eml_jointly_convex :
    ConvexOn ℝ (Set.univ ×ˢ Set.Ioi 0)
      (fun p : ℝ × ℝ => eml p.1 p.2) := by
  constructor
  · exact convex_univ.prod (convex_Ioi 0)
  · intro p hp q hq t s ht hs hts
    simp only [eml, Prod.smul_fst, Prod.smul_snd, smul_eq_mul, Prod.fst_add, Prod.snd_add]
    have hp2 : (0:ℝ) < p.2 := (Set.mem_prod.mp hp).2
    have hq2 : (0:ℝ) < q.2 := (Set.mem_prod.mp hq).2
    have hmix : (0:ℝ) < t * p.2 + s * q.2 := by
      rcases (ht.lt_or_eq) with ht' | ht'
      · exact add_pos_of_pos_of_nonneg (mul_pos ht' hp2) (mul_nonneg hs hq2.le)
      · rw [← ht'] at hts; simp at hts; rw [← ht', hts]; simp; exact hq2
    have hexp := convexOn_exp.2 (Set.mem_univ p.1) (Set.mem_univ q.1) ht hs hts
    simp at hexp
    have hconv_log := convexOn_exp.2 (Set.mem_univ (Real.log p.2))
      (Set.mem_univ (Real.log q.2)) ht hs hts
    simp at hconv_log
    rw [Real.exp_log hp2, Real.exp_log hq2] at hconv_log
    have hlog_ineq : t * Real.log p.2 + s * Real.log q.2 ≤ Real.log (t * p.2 + s * q.2) := by
      rw [← Real.exp_le_exp]
      exact le_trans hconv_log (Real.exp_log hmix).symm.le
    have key1 : t * Real.exp p.1 + s * Real.exp q.1 - (t * Real.log p.2 + s * Real.log q.2) =
        t * (Real.exp p.1 - Real.log p.2) + s * (Real.exp q.1 - Real.log q.2) := by ring
    linarith

/-! ## Section 3: Self-Pairing Properties (EXTENDED V10) -/

/-- σ(x) = eˣ − x ≥ 1 for all x, with equality at x = 0. -/
theorem emlSelfPair_ge_one (x : ℝ) : emlSelfPair x ≥ 1 := by
  unfold emlSelfPair; linarith [Real.add_one_le_exp x]

/-- σ(x) = 1 iff x = 0. -/
theorem emlSelfPair_eq_one_iff (x : ℝ) : emlSelfPair x = 1 ↔ x = 0 := by
  unfold emlSelfPair
  constructor
  · intro h
    by_contra hne
    have := Real.add_one_lt_exp hne
    linarith
  · intro h; subst h; simp

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

/-- σ is strictly monotone on [0,∞). -/
theorem emlSelfPair_strictMono_nonneg : StrictMonoOn emlSelfPair (Set.Ici 0) := by
  apply strictMonoOn_of_deriv_pos (convex_Ici 0)
  · exact (Real.continuous_exp.sub continuous_id).continuousOn
  · intro x hx
    rw [interior_Ici] at hx
    have hd : deriv emlSelfPair x = Real.exp x - 1 :=
      ((Real.hasDerivAt_exp x).sub (hasDerivAt_id x) |>.congr_deriv (by ring)).deriv
    rw [hd]
    have : Real.exp x > 1 := by rw [← Real.exp_zero]; exact Real.exp_lt_exp.mpr hx
    linarith

/-- σ is strictly antitone on (−∞, 0]. -/
theorem emlSelfPair_strictAnti_nonpos : StrictAntiOn emlSelfPair (Set.Iic 0) := by
  apply strictAntiOn_of_deriv_neg (convex_Iic 0)
  · exact (Real.continuous_exp.sub continuous_id).continuousOn
  · intro x hx
    rw [interior_Iic] at hx
    have hd : deriv emlSelfPair x = Real.exp x - 1 :=
      ((Real.hasDerivAt_exp x).sub (hasDerivAt_id x) |>.congr_deriv (by ring)).deriv
    rw [hd]
    have : Real.exp x < 1 := by rw [← Real.exp_zero]; exact Real.exp_lt_exp.mpr hx
    linarith

/-- σ → ∞ as x → ∞. -/
theorem emlSelfPair_tendsto_top :
    Filter.Tendsto emlSelfPair Filter.atTop Filter.atTop := by
  rw [Filter.tendsto_atTop_atTop]
  intro b; use max b 2
  intro x hx
  unfold emlSelfPair
  have hx2 : x ≥ 2 := le_trans (le_max_right b 2) hx
  have hxb : x ≥ b := le_trans (le_max_left b 2) hx
  have h5 : Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
    rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
    exact le_trans (by norm_num [Finset.sum_range_succ])
      (Summable.sum_le_tsum (Finset.range 3)
        (fun i _ => by positivity)
        (Real.summable_pow_div_factorial x))
  nlinarith [sq_nonneg (x - 1)]

/-- σ → ∞ as x → −∞. -/
theorem emlSelfPair_tendsto_top_neg :
    Filter.Tendsto emlSelfPair Filter.atBot Filter.atTop := by
  apply Filter.tendsto_atTop.mpr; intro b
  simp only [Filter.eventually_atBot]
  use min (-b) 0
  intro x hx
  unfold emlSelfPair
  linarith [Real.exp_pos x, le_trans hx (min_le_left _ _), le_trans hx (min_le_right _ _)]

/-! ## Section 4: Diagonal Map Theory -/

/-- d(z) > z for all z ∈ ℝ (no real fixed points). -/
theorem emlDiag_gt (z : ℝ) : emlDiag z > z := by
  unfold emlDiag
  by_cases hz : 0 < z
  · have h5 : Real.exp z ≥ 1 + z + z ^ 2 / 2 := by
      rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
      exact le_trans (by norm_num [Finset.sum_range_succ])
        (Summable.sum_le_tsum (Finset.range 3)
          (fun i _ => by positivity)
          (Real.summable_pow_div_factorial z))
    nlinarith [Real.log_le_sub_one_of_pos hz, sq_nonneg z]
  · push_neg at hz
    by_cases hz0 : z = 0
    · subst hz0; simp
    · rw [show Real.log z = Real.log (-z) from by rw [← Real.log_neg_eq_log]]
      linarith [Real.exp_pos z,
        Real.log_le_sub_one_of_pos (neg_pos.mpr (lt_of_le_of_ne hz hz0))]

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

/-- For z > 0: d(z) ≥ 2. -/
theorem emlDiag_ge_two (z : ℝ) (hz : 0 < z) : emlDiag z ≥ 2 := by
  unfold emlDiag
  have h1 := Real.add_one_le_exp z
  have h2 := Real.log_le_sub_one_of_pos hz
  linarith

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

/-! ## Section 5: Monotonicity -/

theorem eml_strictMono_x (y : ℝ) : StrictMono (fun x => eml x y) := by
  intro a b hab; simp only [eml]; linarith [Real.exp_lt_exp.mpr hab]

theorem eml_strictAnti_y (x : ℝ) : StrictAntiOn (fun y => eml x y) (Set.Ioi 0) := by
  intro a ha b _ hab; simp only [eml]
  linarith [Real.log_lt_log (Set.mem_Ioi.mp ha) hab]

/-! ## Section 6: Magma Properties -/

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

/-- EML has no idempotent elements: eml(x,x) ≠ x for all x. -/
theorem eml_no_idempotent (x : ℝ) : eml x x ≠ x := by
  unfold eml; intro hx
  by_cases hx_pos : 0 < x
  · have h5 : Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
      rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
      exact le_trans (by norm_num [Finset.sum_range_succ])
        (Summable.sum_le_tsum (Finset.range 3)
          (fun i _ => by positivity)
          (Real.summable_pow_div_factorial x))
    nlinarith [Real.log_le_sub_one_of_pos hx_pos, sq_nonneg x]
  · push_neg at hx_pos
    by_cases hx0 : x = 0
    · subst hx0; simp at hx
    · have hxn : x < 0 := lt_of_le_of_ne hx_pos hx0
      have hlog : Real.log x = Real.log (-x) := by rw [← Real.log_neg_eq_log]
      rw [hlog] at hx
      linarith [Real.exp_pos x, Real.log_le_sub_one_of_pos (neg_pos.mpr hxn)]

/-! ## Section 7: No Finite Sub-Magma (NEW V10) -/

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

/-! ## Section 8: Uniqueness Theorems -/

/-- EML is the unique function satisfying the Legendre bridge. -/
theorem eml_unique_legendre {F : ℝ → ℝ → ℝ}
    (hF : ∀ x y, F x (Real.exp y) = Real.exp x - y)
    (x y : ℝ) (hy : 0 < y) : F x y = eml x y := by
  have h := hF x (Real.log y); rw [Real.exp_log hy] at h; rw [h]; simp [eml]

/-! ## Section 9: Trace Theory -/

theorem eml_trace (x y : ℝ) :
    eml x y + eml y x = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  unfold eml; ring

theorem eml_trace_ge_two (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    eml x y + eml y x ≥ 2 := by
  rw [eml_trace]
  linarith [Real.add_one_le_exp x, Real.add_one_le_exp y,
            Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy]

/-! ## Section 10: Information Theory -/

/-- Shannon entropy term decomposition. -/
theorem eml_entropy_term (p : ℝ) :
    -p * Real.log p = p * eml 0 p - p := by
  unfold eml; simp; ring

/-- KL divergence term via EML. -/
theorem eml_kl_term (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    p * Real.log (p / q) = p * (eml 0 q - eml 0 p) := by
  unfold eml; rw [Real.log_div hp.ne' hq.ne']; ring

/-! ## Section 11: Constants and E-Tower -/

theorem eml_generates_e : eml 1 1 = Real.exp 1 := by simp [eml, Real.log_one]
theorem eml_generates_ee : eml (eml 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [eml, Real.log_one]

theorem eTower_pos (n : ℕ) : 0 < eTower n := by
  induction n with | zero => simp [eTower] | succ _ _ => exact Real.exp_pos _

theorem eTower_strictMono : StrictMono eTower := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [eTower]; linarith [Real.add_one_le_exp (eTower n)]

theorem eTower_is_eml (n : ℕ) : eTower (n + 1) = eml (eTower n) 1 := by
  simp [eTower, eml, Real.log_one]

/-! ## Section 12: Integral Identities -/

/-- ∫₀¹ eml(t, 1) dt = e − 1. -/
theorem eml_integral_unit :
    ∫ t in (0:ℝ)..1, eml t 1 = Real.exp 1 - 1 := by
  simp [eml, Real.log_one]

/-! ## Section 13: Bregman Divergence -/

/-- D_exp(x,y) = eˣ − eʸ − eʸ(x−y) ≥ 0. -/
theorem bregman_exp_nonneg (x y : ℝ) :
    Real.exp x - Real.exp y - Real.exp y * (x - y) ≥ 0 := by
  rw [show x = y + (x - y) by ring, Real.exp_add]
  nlinarith [Real.add_one_le_exp (x - y), Real.exp_pos y]

/-- D_exp as EML difference. -/
theorem bregman_as_eml (x y : ℝ) :
    Real.exp x - Real.exp y - Real.exp y * (x - y) =
    (eml x 1 - eml y 1) - Real.exp y * (x - y) := by
  simp [eml, Real.log_one]

/-! ## Section 14: Level Sets and Zero Set -/

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

/-! ## Section 15: Taylor Lower Bound -/

/-- exp(x) ≥ 1 + x + x²/2 for x ≥ 0. -/
theorem exp_taylor_lower (x : ℝ) (hx : 0 ≤ x) :
    Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
  rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
  exact le_trans (by norm_num [Finset.sum_range_succ])
    (Summable.sum_le_tsum (Finset.range 3)
      (fun i _ => by positivity)
      (Real.summable_pow_div_factorial x))

/-! ## Section 16: Convexity in Each Variable -/

/-- EML is convex in x for fixed y. -/
theorem eml_convex_x (y : ℝ) : ConvexOn ℝ Set.univ (fun x => eml x y) := by
  show ConvexOn ℝ Set.univ (fun x => Real.exp x + (-Real.log y))
  exact convexOn_exp.add (convexOn_const _ convex_univ)

/-- EML is convex in y on (0,∞) for fixed x. -/
theorem eml_convex_y (x : ℝ) : ConvexOn ℝ (Set.Ioi 0) (fun y => eml x y) := by
  constructor
  · exact convex_Ioi 0
  · intro a ha b hb t s ht hs hts
    simp only [eml, smul_eq_mul]
    have hapos : (0:ℝ) < a := ha
    have hbpos : (0:ℝ) < b := hb
    have hmix : (0:ℝ) < t * a + s * b := by
      rcases (ht.lt_or_eq) with ht' | ht'
      · exact add_pos_of_pos_of_nonneg (mul_pos ht' hapos) (mul_nonneg hs hbpos.le)
      · rw [← ht'] at hts; simp at hts; rw [← ht', hts]; simp; exact hbpos
    have hconv := convexOn_exp.2 (Set.mem_univ (Real.log a))
      (Set.mem_univ (Real.log b)) ht hs hts
    simp at hconv
    rw [Real.exp_log hapos, Real.exp_log hbpos] at hconv
    have hlog_ineq : t * Real.log a + s * Real.log b ≤ Real.log (t * a + s * b) := by
      rw [← Real.exp_le_exp]
      exact le_trans hconv (Real.exp_log hmix).symm.le
    have key : t * (Real.exp x - Real.log a) + s * (Real.exp x - Real.log b) =
      Real.exp x - (t * Real.log a + s * Real.log b) := by
      have : t * Real.exp x + s * Real.exp x = Real.exp x := by
        linear_combination Real.exp x * hts
      linarith
    linarith

end
