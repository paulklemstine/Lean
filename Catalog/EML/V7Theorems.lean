/-! # CatalogBuild.EML.V7Theorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 48
-/

import Mathlib

noncomputable section

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def eml7 (x y : ℝ) : ℝ := Real.exp x - Real.log y



/-- The diagonal map: d(z) = exp(z) - ln(z). -/
def diag7 (z : ℝ) : ℝ := Real.exp z - Real.log z



/-- The e-tower: e↑↑n (iterated exponential). -/
def eTower7 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower7 n)



/-- Iterated diagonal map: d^n(z). -/
def diagIter7 : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => diag7 (diagIter7 n z)



/-- Tropical EML: tropEml(x,y) = max(x, -y). -/
def tropEml7 (x y : ℝ) : ℝ := max x (-y)



/-- [Section: # CatalogBuild.EML.V7Theorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 48] -/
theorem eml7_strictMono_fst (y : ℝ) : StrictMono (fun x => eml7 x y) := by
  exact fun x y hxy => sub_lt_sub_right ( Real.exp_lt_exp.2 hxy ) _



theorem eml7_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => eml7 x y) (Ioi 0) := by
  exact fun y hy z hz hyz => sub_lt_sub_left ( Real.log_lt_log hy hyz ) _



/-- EML is injective in its first argument. -/
theorem eml7_injective_fst (y : ℝ) : Function.Injective (fun x => eml7 x y) := by
  exact (eml7_strictMono_fst y).injective



/-- EML is injective in its second argument on (0, ∞). -/
theorem eml7_injective_snd (x : ℝ) {a b : ℝ} (ha : 0 < a) (hb : 0 < b)
    (h : eml7 x a = eml7 x b) : a = b := by
  exact (eml7_strictAnti_snd x).injOn (mem_Ioi.mpr ha) (mem_Ioi.mpr hb) h



theorem eml7_not_comm : ∃ x y : ℝ, eml7 x y ≠ eml7 y x := by
  unfold eml7;
  refine' ⟨ 0, 1, _ ⟩ ; norm_num;
  exact Ne.symm <| by norm_num;



theorem eml7_not_assoc : ∃ x y z : ℝ, eml7 (eml7 x y) z ≠ eml7 x (eml7 y z) := by
  unfold eml7;
  use 0;
  refine' ⟨ Real.exp 1, Real.exp 0, _ ⟩ ; norm_num;
  linarith [ Real.exp_pos 1 ]



theorem eml7_not_medial :
    ∃ a b c d : ℝ, eml7 (eml7 a b) (eml7 c d) ≠ eml7 (eml7 a c) (eml7 b d) := by
  unfold eml7;
  use 0;
  use 1;
  use 0; norm_num;
  use 0; norm_num



theorem eml7_not_flexible : ∃ a b : ℝ, eml7 (eml7 a b) a ≠ eml7 a (eml7 b a) := by
  use 0, 1; norm_num [eml7]



theorem eml7_not_left_alt : ∃ a b : ℝ, eml7 (eml7 a a) b ≠ eml7 a (eml7 a b) := by
  use 0, 1; norm_num [eml7]



theorem eml7_not_right_alt : ∃ a b : ℝ, eml7 (eml7 a b) b ≠ eml7 a (eml7 b b) := by
  use 0, 1; norm_num [eml7]



theorem eml7_no_left_identity : ¬ ∃ e₀ : ℝ, ∀ x : ℝ, eml7 e₀ x = x := by
  -- Assume that there exists a left identity element $e_0$.
  by_contra h_contra
  obtain ⟨e₀, he₀⟩ := h_contra

  -- Then we have $\exp(e_0) - \log(0) = 0$ since $\log(0)$ is undefined.
  have he_0 : Real.exp e₀ - Real.log 0 = 0 := by
    exact he₀ 0;
  norm_num at he_0



theorem eml7_no_right_identity : ¬ ∃ e₀ : ℝ, ∀ x : ℝ, eml7 x e₀ = x := by
  unfold eml7;
  intro ⟨ e₀, h ⟩ ; have := h 0 ; have := h 1 ; ( ( have := h ( -1 ) ; ( ( norm_num at * ; linarith [ Real.add_one_le_exp 1, Real.exp_pos ( -1 ) ] ; ) ) ) )



/-- eml(x, 1) = exp(x). -/
theorem eml7_exp (x : ℝ) : eml7 x 1 = Real.exp x := by
  simp [eml7, Real.log_one]



/-- eml(0, 1) = 1. -/
theorem eml7_zero_one : eml7 0 1 = 1 := by
  simp [eml7, Real.log_one, Real.exp_zero]



/-- eml(1, 1) = e. -/
theorem eml7_one_one : eml7 1 1 = Real.exp 1 := by
  simp [eml7, Real.log_one]



/-- Power identity: eml(n * x, 1) = exp(x)^n. -/
theorem eml7_power (x : ℝ) (n : ℕ) : eml7 (n * x) 1 = (Real.exp x) ^ n := by
  simp [eml7, Real.log_one, Real.exp_nat_mul]



/-- Involution identity: eml(0, exp(x)) = 1 - x. -/
theorem eml7_involution (x : ℝ) : eml7 0 (Real.exp x) = 1 - x := by
  unfold eml7
  rw [Real.exp_zero, Real.log_exp]



/-- Log-split identity: eml(x, y * z) = eml(x, y) - ln(z) for y, z > 0. -/
theorem eml7_log_split (x : ℝ) {y z : ℝ} (hy : 0 < y) (hz : 0 < z) :
    eml7 x (y * z) = eml7 x y - Real.log z := by
  unfold eml7
  rw [Real.log_mul (ne_of_gt hy) (ne_of_gt hz)]
  ring



/-- Subtraction identity: eml(x, exp(y)) = exp(x) - y. -/
theorem eml7_sub (x y : ℝ) : eml7 x (Real.exp y) = Real.exp x - y := by
  simp [eml7, Real.log_exp]



/-- e-tower base case: eTower7 0 = 1. -/
theorem eTower7_zero : eTower7 0 = 1 := rfl



/-- e-tower step: eTower7 (n+1) = exp(eTower7 n). -/
theorem eTower7_succ (n : ℕ) : eTower7 (n + 1) = Real.exp (eTower7 n) := rfl



theorem eTower7_pos (n : ℕ) : 0 < eTower7 n := by
  induction n <;> [ exact zero_lt_one; exact Real.exp_pos _ ]



theorem eTower7_strictMono : StrictMono eTower7 := by
  exact strictMono_nat_of_lt_succ fun n ↦ by simpa [ eTower7_succ ] using Real.add_one_le_exp ( eTower7 n ) |> lt_of_lt_of_le ( by linarith [ eTower7_pos n ] ) ;



theorem eTower7_superexp (n : ℕ) : eTower7 (n + 2) ≥ Real.exp (2 ^ n) := by
  induction' n with n ih <;> norm_num [ Nat.pow_succ', pow_add, eTower7 ] at *;
  -- We'll use that $e^x \geq 1 + x + \frac{x^2}{2}$ for all $x \geq 0$.
  have h_exp_bound : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ 1 + x + x^2 / 2 := by
    exact fun x a => quadratic_le_exp_of_nonneg a;
  nlinarith [ h_exp_bound ( Real.exp ( eTower7 n ) ) ( Real.exp_nonneg _ ), Real.add_one_le_exp ( eTower7 n ), Real.add_one_le_exp ( Real.exp ( eTower7 n ) ), pow_le_pow_right₀ ( by norm_num : ( 1 : ℝ ) ≤ 2 ) n.zero_le ]



theorem diag7_gt (z : ℝ) : diag7 z > z := by
  by_cases hz : z > 0;
  · unfold diag7;
    have := Real.add_one_le_exp ( z - 1 );
    rw [ show z = 1 + ( z - 1 ) by ring, Real.exp_add ];
    nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( z - 1 ) ) ];
  · unfold diag7;
    by_cases h : z = 0 <;> simp_all +decide;
    linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr ( lt_of_le_of_ne hz h ) ), Real.log_neg_eq_log z ]



theorem diag7_ge_two (z : ℝ) (hz : 0 < z) : diag7 z ≥ 2 := by
  unfold diag7; nlinarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] ;



theorem diag7_orbit_increasing (z : ℝ) (n : ℕ) :
    diagIter7 n z < diagIter7 (n + 1) z := by
  exact diag7_gt _



/-- The diagonal map has no real fixed points. -/
theorem diag7_no_fixed_point (z : ℝ) : diag7 z ≠ z := by
  exact ne_of_gt (diag7_gt z)



theorem eml7_am_gm_connection (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a + b - Real.log a - Real.log b ≥ 2 := by
  linarith [ Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb ]



theorem eml7_t_minus_log_ge_one (t : ℝ) (ht : 0 < t) :
    t - Real.log t ≥ 1 := by
  linarith [ Real.log_le_sub_one_of_pos ht ]



theorem eml7_level_set_nonempty (c : ℝ) :
    ∃ x : ℝ, ∃ y : ℝ, 0 < y ∧ eml7 x y = c := by
  exact ⟨ c, Real.exp ( Real.exp c - c ), Real.exp_pos _, sub_eq_iff_eq_add'.mpr <| by norm_num ⟩



theorem eml7_ge_one (x : ℝ) (y : ℝ) (hx : 0 ≤ x) (hy1 : 0 < y) (hy2 : y ≤ 1) :
    eml7 x y ≥ 1 := by
  exact le_tsub_of_add_le_left ( by linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hy1 ] )



theorem eml7_gradient_nonvanishing (x y : ℝ) (hy : y ≠ 0) :
    Real.exp x ^ 2 + (1 / y) ^ 2 > 0 := by
  positivity



/-- Tropical diagonal absolute value: tropEml(x, x) = |x| when x ≤ 0,
and tropEml(x, x) = x when x ≥ 0, i.e., max(x, -x) = |x|. -/
theorem trop7_diag_abs (x : ℝ) : tropEml7 x x = |x| := by
  simp [tropEml7, abs_eq_max_neg]



/-- Tropical EML is idempotent on the diagonal for nonneg: tropEml(x,x) = x for x ≥ 0. -/
theorem trop7_diag_nonneg (x : ℝ) (hx : 0 ≤ x) : tropEml7 x x = x := by
  simp [tropEml7]
  exact hx



/-- eml via exp and log: eml(ln(a), exp(b)) = a - b for a > 0. -/
theorem eml7_ln_exp (a b : ℝ) (ha : 0 < a) :
    eml7 (Real.log a) (Real.exp b) = a - b := by
  simp [eml7, Real.exp_log ha, Real.log_exp]



/-- eml(x, y) + eml(y, x) = exp(x) + exp(y) - ln(x) - ln(y) for x, y > 0. -/
theorem eml7_sum_sym (x y : ℝ) :
    eml7 x y + eml7 y x = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  simp [eml7]; ring



/-- Composition: eml(eml(x,1), 1) = exp(exp(x)). -/
theorem eml7_double_exp (x : ℝ) : eml7 (eml7 x 1) 1 = Real.exp (Real.exp x) := by
  simp [eml7, Real.log_one]



/-- exp(x) can be recovered: eml(x, 1) = exp(x). -/
theorem eml7_recover_exp (x : ℝ) : eml7 x 1 = Real.exp x := by
  simp [eml7, Real.log_one]



/-- Zero is reachable: eml(1, exp(e)) = exp(1) - e = 0. -/
theorem eml7_zero : eml7 1 (Real.exp (Real.exp 1)) = Real.exp 1 - Real.exp 1 := by
  simp [eml7, Real.log_exp]



/-- Diagonal map is convex on (0, ∞): d''(x) = exp(x) + 1/x² > 0. -/
theorem diag7_second_deriv_pos (x : ℝ) (hx : 0 < x) :
    Real.exp x + x⁻¹ ^ 2 > 0 := by
  positivity



/-- eml(0, y) = 1 - ln(y) for y > 0. -/
theorem eml7_zero_left (y : ℝ) : eml7 0 y = 1 - Real.log y := by
  simp [eml7, Real.exp_zero]



/-- eml(x, e) = exp(x) - 1. -/
theorem eml7_at_e (x : ℝ) : eml7 x (Real.exp 1) = Real.exp x - 1 := by
  simp [eml7, Real.log_exp]



end
