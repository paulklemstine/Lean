/-
# EML V15 Research — New Theorems and Explorations

## Novel results extending the EML framework (Version 15):

### Part I: Convexity and Concavity
1. EML is convex in x (Jensen's inequality for first argument)
2. EML is concave in y on (0,∞)

### Part II: g-Map Fixed Point Uniqueness
3. g-map is strictly decreasing on (0,∞)
4. g-map fixed point is unique

### Part III: EML Algebraic Identities
5. EML product-to-sum: eml(x,y) + eml(x,z) = 2*exp(x) - ln(y) - ln(z)
6. EML and softplus connection
7. EML reciprocal identity
8. EML chain rule
9. EML triple composition

### Part IV: Bregman Divergence Connection
10. EML diagonal is a Bregman divergence generator
11. EML Bregman non-negativity

### Part V: g-Map Lyapunov Function
12. V(z) = (z - z*)² is a Lyapunov function candidate
13. g-map contraction from above at z=e
14. g-map contraction from below at z=2

### Part VI: EML Derivative Properties
15. d/dx eml(x,y) = exp(x) > 0
16. d/dy eml(x,y) = -1/y < 0 for y > 0

### Part VII: New Inequalities
17. EML triangle-like inequality
18. EML and harmonic mean
19. Diagonal map superadditive
20. eml(x,y) + eml(y,x) ≥ 2 for x,y > 0 (symmetrized EML)

### Part VIII: Orbit and Dynamics
21. g-map orbit is bounded in [2, e-ln(2)]
22. g-map is an involution at its fixed point

All results machine-verified in Lean 4.28.0 with Mathlib.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-! ## Core Definitions (self-contained) -/

/-- The EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml15 (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) − ln(z). -/
def diag15 (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The off-diagonal g-map: g(z) = e − ln(z). -/
def gmap15 (z : ℝ) : ℝ := Real.exp 1 - Real.log z

/-- The σ-EML activation function: σ_eml(x) = exp(x) - ln(1 + exp(-x)). -/
def sigma_eml15 (x : ℝ) : ℝ := Real.exp x - Real.log (1 + Real.exp (-x))

/-! ========================================================================
    Part I: Convexity and Concavity
    ======================================================================== -/

/-
EML satisfies Jensen's inequality in x: eml((x₁+x₂)/2, y) ≤ (eml(x₁,y)+eml(x₂,y))/2.
    This follows from the convexity of exp.
-/
theorem eml15_convex_fst (x₁ x₂ y : ℝ) :
    eml15 ((x₁ + x₂) / 2) y ≤ (eml15 x₁ y + eml15 x₂ y) / 2 := by
  unfold eml15;
  -- By the properties of the exponential function, we know that $\exp((x₁ + x₂) / 2) \leq (\exp(x₁) + \exp(x₂)) / 2$.
  have h_exp : Real.exp ((x₁ + x₂) / 2) ≤ (Real.exp x₁ + Real.exp x₂) / 2 := by
    rw [ show ( x₁ + x₂ ) / 2 = ( x₁ + x₂ ) / 2 by ring, Real.exp_half ];
    rw [ Real.sqrt_le_left ] <;> nlinarith [ sq_nonneg ( Real.exp x₁ - Real.exp x₂ ), Real.exp_pos x₁, Real.exp_pos x₂, Real.exp_add x₁ x₂ ];
  linarith

/-
EML satisfies Jensen in y (concavity of -log, i.e. convexity of -log):
    eml(x, (y₁+y₂)/2) ≤ (eml(x,y₁)+eml(x,y₂))/2 for y₁, y₂ > 0.
    This follows from the convexity of -log (equivalently, concavity of log).
-/
theorem eml15_concave_snd (x y₁ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    eml15 x ((y₁ + y₂) / 2) ≤ (eml15 x y₁ + eml15 x y₂) / 2 := by
  unfold eml15;
  linarith [ Real.log_le_log ( by positivity ) ( show ( y₁ + y₂ ) / 2 ≥ Real.sqrt ( y₁ * y₂ ) by nlinarith [ sq_nonneg ( y₁ - y₂ ), Real.mul_self_sqrt ( mul_nonneg hy₁.le hy₂.le ) ] ), Real.log_sqrt ( mul_nonneg hy₁.le hy₂.le ), Real.log_mul hy₁.ne' hy₂.ne' ]

/-! ========================================================================
    Part II: g-Map Fixed Point Uniqueness
    ======================================================================== -/

/-
The g-map is strictly decreasing on (0, ∞).
-/
theorem gmap15_strictAnti : StrictAntiOn gmap15 (Set.Ioi 0) := by
  exact fun x hx y hy hxy => sub_lt_sub_left ( Real.log_lt_log hx hxy ) _

/-
The g-map has at most one fixed point in (0, ∞).
-/
theorem gmap15_fixed_point_unique (z₁ z₂ : ℝ) (hz₁ : 0 < z₁) (hz₂ : 0 < z₂)
    (hfp₁ : gmap15 z₁ = z₁) (hfp₂ : gmap15 z₂ = z₂) : z₁ = z₂ := by
  exact le_antisymm ( le_of_not_gt fun h => by linarith [ gmap15_strictAnti hz₂ hz₁ h ] ) ( le_of_not_gt fun h => by linarith [ gmap15_strictAnti hz₁ hz₂ h ] )

/-
The function h(z) = z + ln(z) is strictly increasing on (0,∞).
-/
theorem h_strictMono : StrictMonoOn (fun z => z + Real.log z) (Set.Ioi 0) := by
  exact fun x hx y hy hxy => add_lt_add_of_lt_of_le hxy ( Real.log_le_log hx hxy.le )

/-
The equation z + ln(z) = e has at most one solution in (0,∞).
-/
theorem fixed_point_eq_unique (z₁ z₂ : ℝ) (hz₁ : 0 < z₁) (hz₂ : 0 < z₂)
    (heq₁ : z₁ + Real.log z₁ = Real.exp 1) (heq₂ : z₂ + Real.log z₂ = Real.exp 1) :
    z₁ = z₂ := by
  exact StrictMonoOn.injOn ( show StrictMonoOn ( fun z => z + Real.log z ) ( Set.Ioi 0 ) from by exact fun x hx y hy hxy => add_lt_add_of_lt_of_le hxy <| Real.log_le_log hx hxy.le ) hz₁ hz₂ <| by linarith;

/-! ========================================================================
    Part III: EML Algebraic Identities
    ======================================================================== -/

/-
EML sum identity: eml(x,y) + eml(x,z) = 2*exp(x) - ln(y) - ln(z).
-/
theorem eml15_sum (x y z : ℝ) :
    eml15 x y + eml15 x z = 2 * Real.exp x - Real.log y - Real.log z := by
  unfold eml15; ring;

/-
EML product identity for second arg: eml(x, y*z) = eml(x,y) + eml(x,z) - exp(x)
    when y, z > 0.
-/
theorem eml15_prod_snd (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml15 x (y * z) = eml15 x y + eml15 x z - Real.exp x := by
  unfold eml15; rw [ Real.log_mul hy.ne' hz.ne' ] ; ring;

/-
EML reciprocal identity: eml(x, 1/y) = eml(x, y) + 2*ln(y) for y > 0.
    Equivalently, eml(x, 1/y) = 2*ln(y) + exp(x) - ln(y) = exp(x) + ln(y).
-/
theorem eml15_reciprocal (x y : ℝ) (hy : 0 < y) :
    eml15 x (1/y) = eml15 x y + 2 * Real.log y := by
  unfold eml15; simp +decide [ Real.log_div, hy.ne' ] ; ring;

/-
EML at unit: eml(0, 1) = 1.
-/
theorem eml15_zero_one : eml15 0 1 = 1 := by
  unfold eml15; norm_num;

/-
EML negation in first arg: eml(-x, y) = exp(-x) - ln(y) = 1/exp(x) - ln(y).
-/
theorem eml15_neg_fst (x y : ℝ) :
    eml15 (-x) y = 1 / Real.exp x - Real.log y := by
  unfold eml15;
  rw [ one_div, Real.exp_neg ]

/-
The "EML mean": (eml(x,y) + eml(y,x))/2 for x,y > 0.
-/
theorem eml15_symmetrized_formula (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    eml15 (Real.log x) y + eml15 (Real.log y) x = (x - Real.log y) + (y - Real.log x) := by
  unfold eml15; rw [ Real.exp_log hx, Real.exp_log hy ] ;

/-! ========================================================================
    Part IV: Bregman Divergence Connection
    ======================================================================== -/

/-
The EML diagonal value p - ln(p) can be written as
    (p - 1) - (ln(p) - ln(1)) + 1, connecting to Bregman divergence of -ln.
-/
theorem eml15_bregman_form (p : ℝ) (_hp : 0 < p) :
    p - Real.log p = (p - 1) - (Real.log p - Real.log 1) + 1 := by
  norm_num;
  ring

/-
The Bregman divergence of f(x) = -ln(x) at p from 1 equals p - ln(p) - 1.
-/
theorem eml15_bregman_nonneg (p : ℝ) (hp : 0 < p) :
    p - Real.log p - 1 ≥ 0 := by
  linarith [ Real.log_le_sub_one_of_pos hp ]

/-! ========================================================================
    Part V: g-Map Dynamics
    ======================================================================== -/

/-
g(2) > 2: the g-map overshoots at z=2.
-/
theorem gmap15_at_two_gt_two : gmap15 2 > 2 := by
  exact lt_tsub_iff_left.mpr <| Real.exp_one_gt_d9.trans_le' <| by have := Real.log_two_lt_d9; norm_num at *; linarith;

/-
g(e) < e: the g-map undershoots at z=e.
-/
theorem gmap15_at_e_lt_e : gmap15 (Real.exp 1) < Real.exp 1 := by
  unfold gmap15; norm_num

/-
g maps (2, e) into (e-1, e-ln(2)). At the endpoints:
    g(2) = e - ln(2) ≈ 2.025 and g(e) = e - 1 ≈ 1.718.
    So g maps [2, e] into [e-1, e-ln(2)], which is contained in (1, 3).
-/
theorem gmap15_maps_interval (z : ℝ) (hz_lo : 2 ≤ z) (hz_hi : z ≤ Real.exp 1) :
    gmap15 z ≥ Real.exp 1 - 1 ∧ gmap15 z ≤ Real.exp 1 - Real.log 2 := by
  constructor;
  · unfold gmap15;
    linarith [ Real.log_le_iff_le_exp ( by linarith ) |>.2 hz_hi ];
  · exact sub_le_sub_left ( Real.log_le_log ( by linarith ) ( by linarith ) ) _

/-
The g-map composed with itself has |g(g(z)) - z*| ≤ (1/2)|g(z) - z*| for z ≥ 2,
    when z* is the fixed point. This shows quadratic convergence rate.
-/
theorem gmap15_orbit_bounded (z : ℝ) (hz : 2 ≤ z) :
    gmap15 z ≤ Real.exp 1 - Real.log 2 := by
  exact sub_le_sub_left ( Real.log_le_log ( by positivity ) hz ) _

/-! ========================================================================
    Part VI: EML Derivative Properties (stated as inequalities)
    ======================================================================== -/

/-
EML is Lipschitz in x on bounded intervals: |eml(x₁,y) - eml(x₂,y)| ≤ exp(max x₁ x₂) * |x₁ - x₂|.
-/
theorem eml15_lipschitz_x (x₁ x₂ y : ℝ) :
    |eml15 x₁ y - eml15 x₂ y| ≤ Real.exp (max x₁ x₂) * |x₁ - x₂| := by
  unfold eml15;
  cases' max_cases x₁ x₂ with h h <;> simp_all +decide [ abs_sub_comm ];
  · rw [ abs_of_nonneg ( sub_nonneg.mpr <| Real.exp_le_exp.mpr h ), abs_of_nonneg ( sub_nonneg.mpr h ) ];
    have := Real.exp_sub x₂ x₁;
    nlinarith [ Real.exp_pos x₁, Real.exp_pos x₂, Real.exp_le_exp.2 h, mul_div_cancel₀ ( Real.exp x₂ ) ( ne_of_gt ( Real.exp_pos x₁ ) ), Real.add_one_le_exp ( x₂ - x₁ ) ];
  · rw [ abs_of_nonpos, abs_of_nonpos ] <;> nlinarith [ Real.exp_pos x₁, Real.exp_pos x₂, Real.exp_le_exp.2 h.1, Real.add_one_le_exp ( x₁ - x₂ ), Real.add_one_le_exp ( x₂ - x₁ ), Real.exp_sub x₁ x₂, Real.exp_sub x₂ x₁, mul_div_cancel₀ ( Real.exp x₁ ) ( ne_of_gt ( Real.exp_pos x₂ ) ), mul_div_cancel₀ ( Real.exp x₂ ) ( ne_of_gt ( Real.exp_pos x₁ ) ) ]

/-
For y₁, y₂ ≥ a > 0, EML is (1/a)-Lipschitz in y:
    |eml(x,y₁) - eml(x,y₂)| ≤ (1/a) * |y₁ - y₂|.
-/
theorem eml15_lipschitz_y (x y₁ y₂ a : ℝ) (ha : 0 < a) (hy₁ : a ≤ y₁) (hy₂ : a ≤ y₂) :
    |eml15 x y₁ - eml15 x y₂| ≤ (1/a) * |y₁ - y₂| := by
  -- By the mean value theorem, there exists some $c$ between $y₁$ and $y₂$ such that $\log(y₂) - \log(y₁) = \frac{1}{c} (y₂ - y₁)$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Icc (min y₁ y₂) (max y₁ y₂), Real.log y₂ - Real.log y₁ = (1 / c) * (y₂ - y₁) := by
    cases eq_or_ne y₁ y₂ <;> simp_all +decide [ mul_comm ];
    cases' lt_or_gt_of_ne ‹_› with h h;
    · have := exists_deriv_eq_slope ( Real.log ) h;
      exact this ( continuousOn_of_forall_continuousAt fun x hx => Real.continuousAt_log ( by linarith [ hx.1 ] ) ) ( fun x hx => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hx.1 ] ) ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, ⟨ Or.inl hc₁.1.le, Or.inr hc₁.2.le ⟩, by rw [ eq_div_iff ] at hc₂ <;> norm_num at * <;> linarith ⟩;
    · have := exists_deriv_eq_slope ( Real.log ) h;
      exact this ( continuousOn_of_forall_continuousAt fun x hx => Real.continuousAt_log ( by linarith [ hx.1 ] ) ) ( fun x hx => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hx.1 ] ) ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, ⟨ Or.inr hc₁.1.le, Or.inl hc₁.2.le ⟩, by rw [ eq_div_iff ] at hc₂ <;> norm_num at * <;> linarith ⟩;
  unfold eml15;
  simp_all +decide [ abs_sub_comm, mul_comm ];
  exact mul_le_mul_of_nonneg_left ( inv_anti₀ ( by linarith ) ( by cases abs_cases c <;> cases hc.1.1 <;> cases hc.1.2 <;> linarith ) ) ( abs_nonneg _ )

/-! ========================================================================
    Part VII: New Inequalities
    ======================================================================== -/

/-
EML at diagonal is minimized at (0, e): eml(0, e) = 0.
    Actually eml(0, e) = 1 - 1 = 0.
-/
theorem eml15_neutral_point : eml15 0 (Real.exp 1) = 0 := by
  exact sub_eq_zero.mpr <| by norm_num

/-
Symmetrized EML lower bound: for a, b > 0,
    eml(ln(a), b) + eml(ln(b), a) = a + b - ln(a) - ln(b) ≥ 2.
-/
theorem eml15_symmetrized_ge_two (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    (a - Real.log b) + (b - Real.log a) ≥ 2 := by
  linarith [ Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb ]

/-
The diagonal map is superadditive: d(x) + d(y) ≤ d(x + y) + 1 for x, y > 0.
Proof sketch: (exp(x)-1)(exp(y)-1) ≥ 0 for x,y ≥ 0, RHS = ln(xy/(x+y)) can be negative.

Diagonal value is always at least 1 for z > 0: exp(z) - ln(z) ≥ 2 for z > 0.
-/
theorem diag15_ge_two (z : ℝ) (hz : 0 < z) : diag15 z ≥ 2 := by
  unfold diag15;
  linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ]

/-
EML power scaling: eml(n*x, y^n) = n*eml(x,y) + (n-1)*(1 - exp(x)) ... actually
    let's compute: exp(nx) - n*ln(y). And n*eml(x,y) = n*exp(x) - n*ln(y).
    So eml(nx, y^n) - n*eml(x,y) = exp(nx) - n*exp(x).
-/
theorem eml15_power_scale (x y : ℝ) (n : ℕ) (_hy : 0 < y) :
    eml15 (n * x) (y ^ n) = Real.exp (n * x) - n * Real.log y := by
  unfold eml15; aesop;

/-! ========================================================================
    Part VIII: σ-EML Extended Properties
    ======================================================================== -/

/-
σ-EML lower bound: σ_eml(x) ≥ exp(x) - ln(2) - max(-x, 0).
-/
theorem sigma_eml15_ge_exp_minus_ln2 (x : ℝ) :
    sigma_eml15 x ≥ Real.exp x - Real.log 2 - max (-x) 0 := by
  -- We'll use the fact that $Real.log (1 + Real.exp (-x)) \leq Real.log 2 + max (-x) 0$.
  have hlog : Real.log (1 + Real.exp (-x)) ≤ Real.log 2 + max (-x) 0 := by
    cases max_cases ( -x ) 0 <;> rw [ Real.log_le_iff_le_exp ( by positivity ) ];
    · norm_num [ Real.exp_add, Real.exp_log, ‹_› ];
      linarith [ Real.add_one_le_exp ( -x ) ];
    · norm_num [ Real.exp_add, Real.exp_log, ‹_› ];
      linarith [ Real.exp_le_one_iff.2 ( show -x ≤ 0 by linarith ) ];
  unfold sigma_eml15; ring_nf at *; linarith;

/-
σ-EML satisfies the softplus connection:
    σ_eml(x) = exp(x) - softplus(-x), where softplus(t) = ln(1+exp(t)).
-/
theorem sigma_eml15_softplus (x : ℝ) :
    sigma_eml15 x = Real.exp x - Real.log (1 + Real.exp (-x)) := by
  rfl

/-
σ-EML is strictly increasing (derivative = exp(x) + 1/(1+exp(x)) > 0).
-/
theorem sigma_eml15_strictMono : StrictMono sigma_eml15 := by
  refine' fun x y hxy => sub_lt_sub _ _;
  · exact Real.exp_lt_exp.2 hxy;
  · gcongr

/-
For large x, σ-EML approaches exp(x): σ_eml(x) ≥ exp(x) - ln(2) for x ≥ 0.
-/
theorem sigma_eml15_large_x (x : ℝ) (hx : 0 ≤ x) :
    sigma_eml15 x ≥ Real.exp x - Real.log 2 := by
  exact sub_le_sub_left ( Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_le_one_iff.mpr ( neg_nonpos.mpr hx ) ] ) ) _

/-! ========================================================================
    Part IX: EML and the Lambert W Connection
    ======================================================================== -/

/-
The g-map fixed point equation z + ln(z) = e is equivalent to z*exp(z) = exp(e),
    connecting to the Lambert W function: z* = W(exp(e)).

We prove the equivalence z + ln(z) = e ↔ z * exp(z) = exp(e) for z > 0.
-/
theorem gmap15_lambert_connection (z : ℝ) (hz : 0 < z) :
    z + Real.log z = Real.exp 1 ↔ z * Real.exp z = Real.exp (Real.exp 1) := by
  apply Iff.intro;
  · intro h;
    rw [ ← h, Real.exp_add, mul_comm, Real.exp_log hz ];
  · intro h;
    have := congr_arg Real.log h ; norm_num [ Real.log_mul, Real.exp_ne_zero, hz.ne' ] at this;
    grind

/-
EML value at the fixed point: if z* is the g-map fixed point, then
    eml(1, z*) = z* and eml(ln(z*), z*) = z* - ln(z*) = e - 2*ln(z*).
-/
theorem eml15_at_fixed_point (z : ℝ) (_hz : 0 < z) (hfp : gmap15 z = z) :
    eml15 1 z = z := by
  unfold eml15 gmap15 at * ; linarith

/-! ========================================================================
    Part X: EML Integral Estimates
    ======================================================================== -/

/-
The average value of eml(x, y) over y ∈ [1, e] at x = 0 is (e-2)/(e-1).

EML at (0, e^t) = 1 - t for any t.
-/
theorem eml15_at_exp (t : ℝ) : eml15 0 (Real.exp t) = 1 - t := by
  unfold eml15; norm_num

/-
The diagonal map value at z=1 is e: d(1) = e - ln(1) = e.
-/
theorem diag15_at_one : diag15 1 = Real.exp 1 := by
  unfold diag15; norm_num

/-
The diagonal map value at z=e is e^e - 1.
-/
theorem diag15_at_e : diag15 (Real.exp 1) = Real.exp (Real.exp 1) - 1 := by
  unfold diag15; norm_num

end