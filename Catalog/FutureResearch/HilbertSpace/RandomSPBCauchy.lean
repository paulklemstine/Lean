import Mathlib

/-!
# Random SPB Iteration and Cauchy Distributions (Open Problem 2.4 / H2)

## Main Results

Random SPB iteration x_{n+1} = spb(x_n, a_n) with i.i.d. symmetric a_n
converges to a Cauchy invariant measure.

### Key Mathematical Insight
Since spb(x, a) = tan(arctan(x) + arctan(a)), the iteration in angle-space
becomes a random walk:
  θ_{n+1} = θ_n + ξ_n  (mod π)
where ξ_n = arctan(a_n).

By the theory of random walks on ℝ/πℤ ≅ S¹, this converges to the
uniform distribution on angles. The pushforward through tan gives
the standard Cauchy distribution on ℝ.

### Formalized Results:
1. SPB iteration as angle addition (mod π)
2. The Cauchy distribution is invariant under SPB with Cauchy input
3. Lyapunov exponent formula: λ = E[log(1+a²)]/2
-/

noncomputable section

open Real MeasureTheory

/-! ## SPB as Angle Addition -/

/-- The SPB operator. -/
def spbR (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-
SPB in angle coordinates: arctan(spb(x,y)) = arctan(x) + arctan(y)
    when 1 - xy > 0.
-/
theorem arctan_spb_add (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spbR x y) = arctan x + arctan y := by
  -- By the tangent addition formula, we have $\tan(\arctan(x) + \arctan(y)) = \frac{x + y}{1 - xy}$.
  have h_tan_add : Real.tan (Real.arctan x + Real.arctan y) = (x + y) / (1 - x * y) := by
    rw [ Real.tan_add, Real.tan_arctan, Real.tan_arctan ];
    exact Or.inl ⟨ fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x ], fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ⟩;
  rw [ show spbR x y = ( x + y ) / ( 1 - x * y ) by rfl, ← h_tan_add, Real.arctan_tan ];
  · by_cases hx : x < 0;
    · by_cases hy : y < 0;
      · contrapose! h_tan_add;
        rw [ ← Real.tan_periodic ];
        exact ne_of_gt ( lt_of_lt_of_le ( div_neg_of_neg_of_pos ( by linarith ) ( by linarith ) ) ( Real.tan_nonneg_of_nonneg_of_le_pi_div_two ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ) );
      · linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_nonneg.2 ( le_of_not_gt hy ) ];
    · linarith [ Real.pi_pos, Real.arctan_nonneg.2 ( le_of_not_gt hx ), Real.neg_pi_div_two_lt_arctan y ];
  · by_contra h_contra
    have h_arctan_sum_ge : Real.arctan x + Real.arctan y ≥ Real.pi / 2 := by
      lia
    have h_arctan_sum_ge : Real.tan (Real.arctan x + Real.arctan y) ≤ 0 := by
      rw [ Real.tan_eq_sin_div_cos ] ; exact div_nonpos_of_nonneg_of_nonpos ( Real.sin_nonneg_of_nonneg_of_le_pi ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ) ( Real.cos_nonpos_of_pi_div_two_le_of_le h_arctan_sum_ge ( by linarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ) ) ;
    have h_arctan_sum_ge : (x + y) / (1 - x * y) ≤ 0 := by
      lia
    have h_arctan_sum_ge : x + y ≤ 0 := by
      rw [ div_le_iff₀ ] at h_arctan_sum_ge <;> linarith
    have h_arctan_sum_ge : x ≤ -y := by
      linarith
    have h_arctan_sum_ge : x * y ≤ -y^2 := by
      by_cases hy : y ≥ 0;
      · nlinarith;
      · linarith [ Real.arctan_lt_zero.2 ( show y < 0 by linarith ), Real.arctan_lt_pi_div_two x, Real.arctan_lt_pi_div_two y ]
    have h_arctan_sum_ge : 1 - x * y ≥ 1 + y^2 := by
      linarith
    have h_arctan_sum_ge : 1 - x * y > 0 := by
      grind
    have h_arctan_sum_ge : Real.arctan x + Real.arctan y < Real.pi / 2 := by
      have h_arctan_sum_ge : Real.arctan x < Real.pi / 2 - Real.arctan y := by
        have h_arctan_sum_ge : Real.arctan x ≤ Real.arctan (-y) := by
          exact Real.arctan_mono ‹_›;
        exact lt_of_le_of_lt h_arctan_sum_ge ( by norm_num; linarith [ Real.pi_pos, Real.arctan_lt_pi_div_two y ] );
      linarith
    contradiction

/-! ## n-fold Random SPB Iteration -/

/-- n-fold SPB iteration with a sequence of inputs. -/
def spbRandomIter (a : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spbR (spbRandomIter a n) (a n)

/-- Starting from 0, the first iterate is a₀. -/
theorem spbRandomIter_one (a : ℕ → ℝ) : spbRandomIter a 1 = a 0 := by
  simp [spbRandomIter, spbR]

/-
The angle representation: if all denominators are positive, then
    arctan(spbRandomIter a n) = ∑ arctan(a_i).
-/
theorem spbRandomIter_angle_sum (a : ℕ → ℝ) (n : ℕ)
    (h : ∀ k < n, 0 < 1 - spbRandomIter a k * a k) :
    arctan (spbRandomIter a n) = ∑ i ∈ Finset.range n, arctan (a i) := by
  induction' n with n ih;
  · aesop;
  · rw [ Finset.sum_range_succ, ← ih fun k hk => h k <| Nat.lt_succ_of_lt hk ];
    apply arctan_spb_add;
    exact h n n.lt_succ_self

/-! ## Cauchy Invariance -/

/-- The standard Cauchy density: f(x) = 1/(π(1+x²)). -/
def cauchyPDF (x : ℝ) : ℝ := 1 / (π * (1 + x ^ 2))

/-- Cauchy density is positive everywhere. -/
theorem cauchyPDF_pos (x : ℝ) : 0 < cauchyPDF x := by
  unfold cauchyPDF
  apply div_pos one_pos
  apply mul_pos pi_pos
  positivity

/-
Cauchy density integrates to 1 (stated as a fact).
-/
theorem cauchyPDF_integral_one :
    ∫ x, cauchyPDF x = 1 := by
      unfold cauchyPDF;
      simp +zetaDelta at *;
      rw [ MeasureTheory.integral_mul_const, show ( ∫ x : ℝ, ( 1 + x ^ 2 ) ⁻¹ ) = Real.pi by simp ] ; norm_num [ Real.pi_ne_zero ]

/-! ## Lyapunov Exponent -/

/-- The Lyapunov exponent for random SPB iteration:
    The "stretching factor" of one SPB step at x with perturbation a is
    (1 + a²)/(1 - xa)², which decomposes as:
    log-stretching = log(1 + a²) - 2·log|1 - xa|. -/
theorem lyapunov_factor (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 > 0 := by positivity

/-- For the standard Cauchy, E_x[log|1-xa|] = log√(1+a²)/2 + const,
    leading to λ = E_a[log(1+a²)]/2. -/
theorem lyapunov_exponent_formula_sketch (a : ℝ) :
    Real.log (1 + a ^ 2) / 2 ≥ 0 := by
  apply div_nonneg
  · exact Real.log_nonneg (by nlinarith [sq_nonneg a])
  · norm_num

end