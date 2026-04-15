/-! # CatalogBuild.EML.EMLv8Core

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 37
-/

import Mathlib

noncomputable section

/-- The real EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml8 (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) − ln(z). -/

def diag8 (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The off-diagonal reflection map: g(z) = e − ln(z). -/

def gmap8 (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-- The e-tower: e↑↑n (iterated exponential). -/

def eTow8 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTow8 n)

/-- Iterated diagonal map: dⁿ(z). -/

def diagIter8 : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => diag8 (diagIter8 n z)

/-! ## Section 1: Fundamental Identities -/

/-- exp(x) = eml(x, 1). -/

theorem eml8_recovers_exp (x : ℝ) : eml8 x 1 = Real.exp x := by
  simp [eml8, Real.log_one]

/-- eml(0, y) = 1 − ln(y). -/

theorem eml8_zero_fst (y : ℝ) : eml8 0 y = 1 - Real.log y := by
  simp [eml8]

/-- eml(1, 1) = e. -/

theorem eml8_e : eml8 1 1 = Real.exp 1 := by
  simp [eml8, Real.log_one]

/-- eml(1, e^e) = 0 — zero generation. -/

theorem eml8_zero_gen : eml8 1 (Real.exp (Real.exp 1)) = 0 := by
  simp [eml8, Real.log_exp]

/-! ## Section 2: Legendre Transform Structure -/

/-- The Legendre transform identity: eml(x, eʸ) = eˣ − y. -/

theorem eml8_legendre (x y : ℝ) : eml8 x (Real.exp y) = Real.exp x - y := by
  simp [eml8, Real.log_exp]

/-- Consequence: eml(x, eˣ) = eˣ − x. -/

theorem eml8_self_exp (x : ℝ) : eml8 x (Real.exp x) = Real.exp x - x := by
  simp [eml8, Real.log_exp]

/-! ## Section 3: Power Identity -/

/-- The power identity: eml(n·x, 1) = exp(x)ⁿ for natural number n. -/

theorem eml8_power_nat (x : ℝ) (n : ℕ) :
    eml8 (n * x) 1 = (Real.exp x) ^ n := by
  simp [eml8, Real.log_one, Real.exp_nat_mul]

/-- Integer scaling: eml((↑n)·x, 1) = exp(n·x). -/

theorem eml8_power_int (x : ℝ) (n : ℤ) :
    eml8 (n * x) 1 = Real.exp (n * x) := by
  simp [eml8, Real.log_one]

/-! ## Section 4: Strict Monotonicity -/

/-- EML is strictly monotone increasing in the first argument. -/

theorem eml8_strictMono_fst (y : ℝ) : StrictMono (fun x => eml8 x y) := by
  intro a b hab
  simp only [eml8]
  linarith [Real.exp_lt_exp.mpr hab]

/-- EML is strictly anti-monotone in the second argument for y > 0. -/

theorem eml8_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => eml8 x y) (Ioi 0) := by
  intro a ha b _ hab
  simp only [eml8]
  linarith [Real.log_lt_log (mem_Ioi.mp ha) hab]

/-! ## Section 5: AM-GM Bridge -/

/-- The AM-GM bridge: for a, b > 0,
    eml(ln a, b) + eml(ln b, a) = a + b − ln a − ln b. -/

theorem eml8_amgm_trace (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml8 (Real.log a) b + eml8 (Real.log b) a =
    a + b - Real.log a - Real.log b := by
  simp [eml8, Real.exp_log ha, Real.exp_log hb]; ring

/-- The diagonal AM-GM: exp(x) − ln(x) ≥ 2 for x > 0. -/

theorem eml8_diag_ge_two (x : ℝ) (hx : 0 < x) : diag8 x ≥ 2 := by
  unfold diag8
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]

/-- AM-GM inequality via EML: a + b − ln(a) − ln(b) ≥ 2 for a, b > 0. -/

theorem eml8_amgm_ineq (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a + b - Real.log a - Real.log b ≥ 2 := by
  linarith [Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb]

/-! ## Section 6: Log-Split and Product Identities -/

/-- Log-split: eml(x, y·z) = eml(x, y) − ln(z) for y, z > 0. -/

theorem eml8_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml8 x (y * z) = eml8 x y - Real.log z := by
  unfold eml8; rw [Real.log_mul hy.ne' hz.ne']; ring

/-- Log-ratio: eml(x, y/z) = eml(x, y) + ln(z) for y, z > 0. -/

theorem eml8_log_ratio (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml8 x (y / z) = eml8 x y + Real.log z := by
  unfold eml8; rw [Real.log_div hy.ne' hz.ne']; ring

/-! ## Section 7: Diagonal Map Properties -/

/-
The diagonal map has no real fixed points: d(z) > z for all z.
-/

theorem diag8_gt (z : ℝ) : diag8 z > z := by
  by_cases hz : z ≤ 0;
  · unfold diag8;
    by_cases hz' : z < 0;
    · linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr hz' ), Real.log_neg_eq_log z ];
    · norm_num [ show z = 0 by linarith ];
  · have := Real.add_one_le_exp ( z - 1 );
    unfold diag8;
    rw [ show z = ( z - 1 ) + 1 by ring, Real.exp_add ];
    nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < z - 1 + 1 ) ]

/-- d(z) ≥ 2 for z > 0. -/

theorem diag8_ge_two_pos (z : ℝ) (hz : 0 < z) : diag8 z ≥ 2 :=
  eml8_diag_ge_two z hz

/-! ## Section 8: Derivative and Gradient -/

/-- The partial derivative ∂eml/∂x = exp(x). -/

theorem eml8_deriv_fst (x y : ℝ) :
    HasDerivAt (fun x' => eml8 x' y) (Real.exp x) x := by
  unfold eml8
  have h := (Real.hasDerivAt_exp x).sub (hasDerivAt_const x (Real.log y))
  simp only [sub_zero] at h
  exact h

/-- The partial derivative ∂eml/∂y = −1/y for y > 0. -/

theorem eml8_deriv_snd (x y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun y' => eml8 x y') (-y⁻¹) y := by
  unfold eml8
  have h := (hasDerivAt_const y (Real.exp x)).sub (Real.hasDerivAt_log hy.ne')
  simp only [zero_sub] at h
  exact h

/-- The gradient ∇eml = (eˣ, −1/y) has both components nonzero for y > 0.
    This means the gradient never vanishes, so level sets are smooth curves. -/

theorem eml8_gradient_nonzero (x y : ℝ) (hy : 0 < y) :
    Real.exp x > 0 ∧ y⁻¹ > 0 := by
  exact ⟨Real.exp_pos x, inv_pos.mpr hy⟩

/-! ## Section 9: Non-commutativity and Non-associativity -/

/-
EML is non-commutative.
-/

theorem eml8_noncomm : ∃ x y : ℝ, eml8 x y ≠ eml8 y x := by
  -- Let's calculate the values of `eml8 0 1` and `eml8 1 0`.
  use 0, 1
  simp [eml8];
  exact Ne.symm <| by norm_num;

/-
EML is non-associative.
-/

theorem eml8_nonassoc : ∃ x y z : ℝ, eml8 (eml8 x y) z ≠ eml8 x (eml8 y z) := by
  unfold eml8;
  by_contra! h;
  have := h 0 0 0; norm_num at this

/-! ## Section 10: No Identity Elements -/

/-
EML has no left identity element.
-/

theorem eml8_no_left_identity : ¬ ∃ e₀ : ℝ, ∀ x : ℝ, eml8 e₀ x = x := by
  simp +zetaDelta at *;
  intro x;
  by_contra! h;
  have := h 0; have := h 1; norm_num [ eml8 ] at *;

/-
EML has no right identity element.
-/

theorem eml8_no_right_identity : ¬ ∃ e₀ : ℝ, ∀ x : ℝ, eml8 x e₀ = x := by
  -- Assume there exists $e₀$ such that for all $x$, $eml8 x e₀ = x$.
  by_contra h
  obtain ⟨e₀, he₀⟩ := h
  have h1 : 1 - Real.log e₀ = 0 := by
    simpa [ eml8 ] using he₀ 0
  have h2 : Real.exp 1 - Real.log e₀ = 1 := by
    have := he₀ 1; simp [eml8] at this; linarith
  have h3 : Real.exp 1 = 1 + 1 := by
    linarith
  have h4 : Real.exp 1 > 2 := by
    exact Real.exp_one_gt_d9.trans_le' <| by norm_num;
  linarith

/-! ## Section 11: Trace and Antisymmetry -/

/-- The trace identity: eml(x,y) + eml(y,x) = exp(x) + exp(y) − ln(x) − ln(y). -/

theorem eml8_trace (x y : ℝ) :
    eml8 x y + eml8 y x = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  unfold eml8; ring

/-- The difference: eml(x,y) − eml(y,x) = (exp(x) − exp(y)) + (ln(x) − ln(y)). -/

theorem eml8_diff (x y : ℝ) :
    eml8 x y - eml8 y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold eml8; ring

/-! ## Section 12: EML Constants -/

/-- eml(2, 1) = e². -/

theorem eml8_exp2 : eml8 2 1 = Real.exp 2 := by
  simp [eml8, Real.log_one]

/-- eml(0, 1) = 1. -/

theorem eml8_one_val : eml8 0 1 = 1 := by
  simp [eml8, Real.log_one]

/-- eml(e, e) = e^e − 1. -/

theorem eml8_e_e : eml8 (Real.exp 1) (Real.exp 1) = Real.exp (Real.exp 1) - 1 := by
  simp [eml8, Real.log_exp]

/-- eml(eml(1,1), 1) = e^e. -/

theorem eml8_ee : eml8 (eml8 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [eml8, Real.log_one]

/-- eml(eml(eml(1,1),1), 1) = e^(e^e). -/

theorem eml8_eee : eml8 (eml8 (eml8 1 1) 1) 1 = Real.exp (Real.exp (Real.exp 1)) := by
  simp [eml8, Real.log_one]

/-- Double negation identity: eml(0, exp(eml(0, exp(x)))) = x. -/

theorem eml8_double_neg (x : ℝ) : eml8 0 (Real.exp (eml8 0 (Real.exp x))) = x := by
  unfold eml8; simp [Real.log_exp]

end

end
