/-
# EML V13 Research — New Theorems and Explorations

## Novel results extending the EML framework (Version 13):

### Part I: Algebraic Structure
1. Non-commutativity (explicit witness)
2. Non-associativity (explicit witness)
3. No left identity element
4. No right identity element
5. No idempotent elements

### Part II: Generation of Arithmetic
6. EML generates multiplication: exp(ln a + ln b) = a * b
7. EML generates division: exp(ln a - ln b) = a / b
8. EML generates all natural numbers from 1
9. EML generates all integer powers of e

### Part III: Analytic Properties
10. Partial derivatives of EML
11. Gradient non-vanishing
12. The diagonal map d(z) ≥ z + 1 for all z (universal bound)
13. d(z) > z for all z
14. EML lower and upper bounds
15. Diagonal orbit diverges: d^n(z) ≥ z + n

### Part IV: Fixed Point Theory
16. g-map log-Lipschitz property
17. g-map contraction on [2, e]

### Part V: Composition Algebra
18. Double exponential: eml(eml(x,1), 1) = exp(exp(x))
19. Triple exponential tower
20. EML involution: eml(0, exp(eml(0, exp(x)))) = x
21. Right division involution
22. Legendre transform identity
23. Trace identity

### Part VI: Tropical EML
24. Tropical EML is NOT associative
25. Tropical bound and averaging inequality

### Part VII: Riemannian Geometry
26. Curvature is strictly negative
27. Curvature is unbounded
28. Geodesic solutions verified

### Part VIII: Constants and E-Tower
29. e-tower strict monotonicity
30. e-tower positivity
31. Generation of fundamental constants: 0, -1, e, e^e

All results machine-verified in Lean 4.28.0 with Mathlib.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set Finset

/-! ## Core Definitions -/

/-- The EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml13 (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) − ln(z). -/
def diag13 (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The off-diagonal g-map: g(z) = e − ln(z). -/
def gmap13 (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-- The e-tower: e↑↑n. -/
def eTow13 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTow13 n)

/-- Iterated diagonal map: d^n(z). -/
def diagIter13 : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => diag13 (diagIter13 n z)

/-- Tropical EML: trop(x,y) = max(x, −y). -/
def trop13 (x y : ℝ) : ℝ := max x (-y)

/-! ========================================================================
    Part I: Algebraic Structure — EML is a "Wild Magma"
    ======================================================================== -/

/-- EML is NOT commutative: eml(0, 1) = 1 but eml(1, 0) = e. -/
theorem eml13_not_comm : ∃ x y : ℝ, eml13 x y ≠ eml13 y x := by
  unfold eml13
  refine ⟨0, 1, ?_⟩; norm_num
  exact Ne.symm <| by norm_num

/-- EML is NOT associative: eml(eml(1,1), 1) = e^e but eml(1, eml(1,1)) = e − 1. -/
theorem eml13_not_assoc :
    ∃ x y z : ℝ, eml13 (eml13 x y) z ≠ eml13 x (eml13 y z) := by
  use 1, 1, 1; norm_num [eml13]
  linarith [Real.add_one_le_exp 1, Real.add_one_le_exp (Real.exp 1)]

/-- EML has no left identity element. -/
theorem eml13_no_left_identity : ¬∃ e₀ : ℝ, ∀ x : ℝ, eml13 e₀ x = x := by
  rintro ⟨e₀, h⟩
  unfold eml13 at h
  have := h (-2); have := h (-1); norm_num at *
  linarith [Real.exp_pos e₀]

/-- EML has no right identity element. -/
theorem eml13_no_right_identity : ¬∃ e₀ : ℝ, ∀ x : ℝ, eml13 x e₀ = x := by
  unfold eml13
  intro ⟨e₀, h⟩
  have := h 0; have := h 1; have := h (-1); norm_num at *
  linarith [Real.add_one_le_exp 1, Real.exp_pos (-1)]

/-- EML has no idempotent element: there is no a with eml(a,a) = a. -/
theorem eml13_no_idempotent : ¬∃ a : ℝ, eml13 a a = a := by
  simp +zetaDelta at *
  intros x hx
  unfold eml13 at hx
  by_cases hx_pos : 0 < x
  · have := Real.add_one_le_exp (x - 1)
    rw [Real.exp_sub] at this
    rw [le_div_iff₀ (Real.exp_pos _)] at this
    nlinarith [Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos hx_pos]
  · cases lt_or_eq_of_le (le_of_not_gt hx_pos) <;> simp_all +decide [Real.exp_pos]
    linarith [Real.exp_pos x, Real.log_le_sub_one_of_pos (neg_pos.mpr ‹_›), Real.log_neg_eq_log x]

/-! ========================================================================
    Part II: Generation of Arithmetic Operations
    ======================================================================== -/

/-- EML generates multiplication: eml(ln(a) + ln(b), 1) = a * b. -/
theorem eml13_generates_mult (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml13 (Real.log a + Real.log b) 1 = a * b := by
  unfold eml13; rw [Real.exp_add, Real.exp_log ha, Real.exp_log hb]; norm_num

/-- EML generates division: eml(ln(a) - ln(b), 1) = a / b. -/
theorem eml13_generates_div (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml13 (Real.log a - Real.log b) 1 = a / b := by
  convert eml13_generates_mult (a := a / b) (b := 1) (by positivity) zero_lt_one using 1
    <;> [rw [Real.log_div ha.ne' hb.ne']; ring]
  norm_num [Real.exp_sub, Real.exp_log, ha, hb]

/-- EML generates all natural numbers: eml(ln(n), 1) = n for n ≥ 1. -/
theorem eml13_generates_nat (n : ℕ) (hn : 1 ≤ n) :
    eml13 (Real.log n) 1 = n := by
  unfold eml13
  rw [Real.exp_log (by positivity), Real.log_one, sub_zero]

/-- EML generates all integer powers of e: eml(n, 1) = exp(n). -/
theorem eml13_generates_exp_int (n : ℤ) :
    eml13 n 1 = Real.exp n := by
  unfold eml13; norm_num

/-! ========================================================================
    Part III: Analytic Properties
    ======================================================================== -/

/-- Partial derivative of eml w.r.t. x equals exp(x). -/
theorem eml13_deriv_fst (x y : ℝ) (_hy : y ≠ 0) :
    HasDerivAt (fun t => eml13 t y) (Real.exp x) x := by
  convert HasDerivAt.sub (Real.hasDerivAt_exp x) (hasDerivAt_const _ _) using 1
  ring

/-- Partial derivative of eml w.r.t. y equals -1/y for y > 0. -/
theorem eml13_deriv_snd (x y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun t => eml13 x t) (-1 / y) y := by
  simpa [div_eq_inv_mul] using
    HasDerivAt.sub (hasDerivAt_const _ _) (Real.hasDerivAt_log hy.ne')

/-- The gradient of eml never vanishes for y > 0. -/
theorem eml13_gradient_nonzero (x : ℝ) (y : ℝ) (_hy : 0 < y) :
    Real.exp x ≠ 0 :=
  ne_of_gt (Real.exp_pos x)

/-- Universal diagonal bound: d(z) ≥ z + 1 for ALL z ∈ ℝ.
    This strengthens the previous result that only applied for z ≥ 0. -/
theorem diag13_ge_succ (z : ℝ) : diag13 z ≥ z + 1 := by
  unfold diag13
  by_cases hz : 0 < z
  · by_cases hz1 : z ≤ 1
    · -- For 0 < z ≤ 1: log(z) ≤ 0 and exp(z) ≥ 1 + z
      have h1 := Real.add_one_le_exp z
      have h2 := Real.log_nonpos (le_of_lt hz) hz1
      linarith
    · -- For z > 1: use Taylor bound exp ≥ 1 + x + x²/2
      push_neg at hz1
      have h1 := Real.sum_le_exp_of_nonneg (le_of_lt hz) 3
      simp [Finset.sum_range_succ] at h1
      have h2 := Real.log_le_sub_one_of_pos hz
      nlinarith [sq_nonneg (z - 1)]
  · push_neg at hz
    cases' eq_or_lt_of_le hz with h h
    · subst h; simp [Real.log_zero]
    · -- z < 0: log(z) = log(-z) ≤ -z - 1
      have h1 := Real.exp_pos z
      have h2 := Real.log_le_sub_one_of_pos (neg_pos.mpr h)
      rw [Real.log_neg_eq_log z] at h2
      linarith

/-- d(z) > z for all z ∈ ℝ (orbit always increases). -/
theorem diag13_gt (z : ℝ) : diag13 z > z := by
  linarith [diag13_ge_succ z]

/-- EML lower bound: eml(x, y) ≥ 1 + x - ln(y). -/
theorem eml13_lower_bound (x y : ℝ) :
    eml13 x y ≥ 1 + x - Real.log y := by
  exact sub_le_sub_right (by linarith [Real.add_one_le_exp x]) _

/-- EML upper bound for y ≥ 1: eml(x, y) ≤ exp(x). -/
theorem eml13_upper_bound (x y : ℝ) (hy : 1 ≤ y) :
    eml13 x y ≤ Real.exp x :=
  sub_le_self _ (Real.log_nonneg hy)

/-- Diagonal orbit is strictly increasing. -/
theorem diagIter13_increasing (z : ℝ) (n : ℕ) :
    diagIter13 n z < diagIter13 (n + 1) z := by
  simp only [diagIter13]; exact diag13_gt _

/-- Diagonal orbit diverges: d^n(z) ≥ z + n. -/
theorem diagIter13_diverge (z : ℝ) (n : ℕ) :
    diagIter13 n z ≥ z + n := by
  induction n with
  | zero => simp [diagIter13]
  | succ n ih =>
    simp only [diagIter13, Nat.cast_succ]
    have h := diag13_ge_succ (diagIter13 n z)
    linarith

/-! ========================================================================
    Part IV: Fixed Point Theory for the g-Map
    ======================================================================== -/

/-- The g-map satisfies |g(x) - g(y)| = |ln(x) - ln(y)| for all x, y > 0. -/
theorem gmap13_lipschitz_log (x y : ℝ) (_hx : 0 < x) (_hy : 0 < y) :
    |gmap13 x - gmap13 y| = |Real.log x - Real.log y| := by
  unfold gmap13; simp only [sub_sub_sub_cancel_left]; rw [abs_sub_comm]

/-- The g-map is 1/c-Lipschitz via the MVT: |g(x) - g(y)| ≤ (1/c)|x-y|
    where c = min(x,y). For x, y ≥ 2, this gives a 1/2 contraction. -/
theorem gmap13_contraction_on_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    |gmap13 x - gmap13 y| ≤ (1 / min x y) * |x - y| := by
  unfold gmap13
  simp only [sub_sub_sub_cancel_left]
  rcases le_or_gt x y with hxy | hxy
  · rw [show min x y = x from min_eq_left hxy]
    have hlog : Real.log x ≤ Real.log y := Real.log_le_log hx hxy
    rw [abs_of_nonneg (sub_nonneg.mpr hlog)]
    rw [abs_sub_comm, abs_of_nonneg (sub_nonneg.mpr hxy)]
    rw [← Real.log_div (ne_of_gt hy) (ne_of_gt hx)]
    have h1 := Real.log_le_sub_one_of_pos (div_pos hy hx)
    rw [div_sub_one (ne_of_gt hx)] at h1
    rw [one_div, inv_mul_eq_div]
    exact h1
  · rw [show min x y = y from min_eq_right (le_of_lt hxy)]
    have hlog : Real.log y ≤ Real.log x := Real.log_le_log hy (le_of_lt hxy)
    rw [abs_of_nonpos (sub_nonpos.mpr hlog), neg_sub]
    rw [abs_of_nonneg (sub_nonneg.mpr (le_of_lt hxy))]
    rw [← Real.log_div (ne_of_gt hx) (ne_of_gt hy)]
    have h1 := Real.log_le_sub_one_of_pos (div_pos hx hy)
    rw [div_sub_one (ne_of_gt hy)] at h1
    rw [one_div, inv_mul_eq_div]
    exact h1

/-! ========================================================================
    Part V: Composition Algebra
    ======================================================================== -/

/-- Double exponential: eml(eml(x,1), 1) = exp(exp(x)). -/
theorem eml13_double_exp (x : ℝ) :
    eml13 (eml13 x 1) 1 = Real.exp (Real.exp x) := by
  unfold eml13; norm_num

/-- Triple exponential tower: eml(eml(eml(x,1), 1), 1) = exp(exp(exp(x))). -/
theorem eml13_triple_exp (x : ℝ) :
    eml13 (eml13 (eml13 x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  unfold eml13; norm_num [← Real.exp_add]

/-- EML involution ("double negation"): eml(0, exp(eml(0, exp(x)))) = x. -/
theorem eml13_involution (x : ℝ) :
    eml13 0 (Real.exp (eml13 0 (Real.exp x))) = x := by
  unfold eml13; norm_num

/-- Right division identity: eml(a, exp(exp(a) - b)) = b. -/
theorem eml13_rdiv_involution (a b : ℝ) :
    eml13 a (Real.exp (Real.exp a - b)) = b := by
  unfold eml13; norm_num

/-- The Legendre transform identity: eml(x, exp(y)) = exp(x) - y. -/
theorem eml13_legendre (x y : ℝ) :
    eml13 x (Real.exp y) = Real.exp x - y := by
  norm_num [eml13, Real.log_exp]

/-- exp(x) = eml(x, 1). -/
theorem eml13_recovers_exp (x : ℝ) : eml13 x 1 = Real.exp x :=
  sub_eq_self.mpr Real.log_one

/-- eml(0, y) = 1 - ln(y). -/
theorem eml13_zero_left (y : ℝ) : eml13 0 y = 1 - Real.log y := by
  show Real.exp 0 - Real.log y = 1 - Real.log y; norm_num

/-- The trace identity: eml(x,y) + eml(y,x) = exp(x) + exp(y) - ln(x) - ln(y). -/
theorem eml13_trace (x y : ℝ) :
    eml13 x y + eml13 y x = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  unfold eml13; ring

/-! ========================================================================
    Part VI: Tropical EML
    ======================================================================== -/

/-- Tropical EML is NOT associative. -/
theorem trop13_not_assoc :
    ∃ x y z : ℝ, trop13 (trop13 x y) z ≠ trop13 x (trop13 y z) := by
  refine ⟨0, 1, -1, ?_⟩
  unfold trop13; norm_num

/-- Tropical EML satisfies |trop(x,y)| ≤ max(|x|, |y|). -/
theorem trop13_bound (x y : ℝ) :
    |trop13 x y| ≤ max (|x|) (|y|) := by
  unfold trop13
  cases le_or_gt x (-y) with
  | inl h => rw [max_eq_right h]; rw [abs_neg]; exact le_max_right _ _
  | inr h => rw [max_eq_left (le_of_lt h)]; exact le_max_left _ _

/-- Tropical EML averaging bound: trop(x,y) ≥ (x - y) / 2. -/
theorem trop13_avg_bound (x y : ℝ) :
    trop13 x y ≥ (x - y) / 2 := by
  unfold trop13
  cases le_or_gt x (-y) with
  | inl h => rw [max_eq_right h]; linarith
  | inr h => rw [max_eq_left (le_of_lt h)]; linarith

/-! ========================================================================
    Part VII: Riemannian Geometry of the EML Hessian Metric
    ======================================================================== -/

/-- The EML curvature K = -exp(x)/(4y²) is strictly negative for y > 0. -/
theorem eml13_curvature_neg (x y : ℝ) (hy : 0 < y) :
    -(Real.exp x) / (4 * y ^ 2) < 0 :=
  div_neg_of_neg_of_pos (neg_neg_of_pos (Real.exp_pos x)) (by positivity)

/-- The curvature is unbounded: for any M, there exist (x,y) with |K| > M. -/
theorem eml13_curvature_unbounded :
    ∀ M : ℝ, ∃ x y : ℝ, 0 < y ∧ Real.exp x / (4 * y ^ 2) > M := by
  intro M
  refine ⟨Real.log (4 * (max M 0 + 1)), 1, one_pos, ?_⟩
  simp [Real.exp_log (by positivity : (0:ℝ) < 4 * (max M 0 + 1))]
  linarith [le_max_left M 0]

/-- The y-geodesic y(t) = C·exp(kt) stays positive for C > 0. -/
theorem eml13_ygeodesic_pos (C k t : ℝ) (hC : 0 < C) :
    0 < C * Real.exp (k * t) := by positivity

/-- The x-geodesic ODE is satisfied: x'' + (1/2)(x')² = 0. -/
theorem eml13_xgeodesic_ode (a b t : ℝ) (h : 0 < a * t + b) :
    let x' := 2 * a / (a * t + b)
    let x'' := -(2 * a ^ 2) / (a * t + b) ^ 2
    x'' + (1/2) * x' ^ 2 = 0 := by
  field_simp; ring

/-! ========================================================================
    Part VIII: Constants Hierarchy and E-Tower
    ======================================================================== -/

/-- The e-tower is strictly increasing. -/
theorem eTow13_strictMono : StrictMono eTow13 := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [eTow13]
  linarith [Real.add_one_le_exp (eTow13 n)]

/-- E-tower values are all positive. -/
theorem eTow13_pos (n : ℕ) : 0 < eTow13 n := by
  induction n with
  | zero => simp [eTow13]
  | succ n _ => exact Real.exp_pos _

/-- E-tower connects to iterated EML: e↑↑(n+1) = eml(e↑↑n, 1). -/
theorem eTow13_eml (n : ℕ) : eTow13 (n + 1) = eml13 (eTow13 n) 1 := by
  simp [eTow13, eml13, Real.log_one]

/-- EML generates 0: eml(0, e) = 0. -/
theorem eml13_generates_zero : eml13 0 (Real.exp 1) = 0 := by simp [eml13]

/-- EML generates -1: eml(0, e²) = -1. -/
theorem eml13_generates_neg_one : eml13 0 (Real.exp 2) = -1 := by
  unfold eml13; norm_num

/-- EML generates e: eml(1, 1) = e. -/
theorem eml13_generates_e : eml13 1 1 = Real.exp 1 := by simp [eml13, Real.log_one]

/-- EML generates e^e: eml(e, 1) = e^e. -/
theorem eml13_generates_ee : eml13 (Real.exp 1) 1 = Real.exp (Real.exp 1) := by
  simp [eml13, Real.log_one]

end
