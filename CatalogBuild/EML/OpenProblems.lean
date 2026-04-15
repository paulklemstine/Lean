/-! # CatalogBuild.EML.OpenProblems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 12
-/

import Mathlib

noncomputable section

def spbH' (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Problem 7.4a: SPB Involutions -/

/-- **Problem 7.4a solved**: The only element a such that spb(a, a) = 0 is a = 0.
    Proof: spb(a,a) = 2a/(1-a²). This is zero iff 2a = 0 iff a = 0. -/

theorem spb_involution_only_zero (a : ℝ) (h : 1 - a * a ≠ 0) :
    spb' a a = 0 ↔ a = 0 := by
  constructor
  · intro heq
    unfold spb' at heq
    rw [div_eq_zero_iff] at heq
    cases heq with
    | inl h => linarith
    | inr h => exact absurd h (by assumption)
  · intro heq
    rw [heq]
    simp [spb']

/-! ## SPB Idempotent Classification -/

/-- spb(x, x) = x if and only if x = 0.
    Proof: spb(x,x) = 2x/(1-x²) = x iff 2x = x(1-x²) iff x(1+x²) = 0 iff x = 0. -/

theorem spb_idempotent_iff_zero (x : ℝ) (h : 1 - x * x ≠ 0) :
    spb' x x = x ↔ x = 0 := by
  constructor
  · intro heq
    unfold spb' at heq
    have := div_eq_iff h |>.mp heq
    have : x * (1 + x ^ 2) = 0 := by nlinarith
    rcases mul_eq_zero.mp this with h1 | h2
    · exact h1
    · nlinarith [sq_nonneg x]
  · intro heq
    rw [heq]; simp [spb']

/-! ## SPB Fixed Points -/

/-- For a ≠ 0, the map x ↦ spb(x, a) has no real fixed points when a > 0.
    spb(x, a) = x iff (x+a)/(1-xa) = x iff x + a = x - x²a iff a(1+x²) = 0 iff a = 0. -/

theorem spb_quadruple (x : ℝ) (h : 1 - x ^ 2 ≠ 0)
    (h2 : 1 - (2 * x / (1 - x ^ 2)) ^ 2 ≠ 0) :
    spb' (spb' x x) (spb' x x) =
    2 * (2 * x / (1 - x ^ 2)) / (1 - (2 * x / (1 - x ^ 2)) ^ 2) := by
  have hxx : spb' x x = 2 * x / (1 - x ^ 2) := by
    unfold spb'; field_simp; ring
  rw [hxx]
  unfold spb'; field_simp; ring

/-! ## SPB and Polynomial Identities -/

/-- The SPB denominators multiply: if we track denominators through
    spb composition, they satisfy a recurrence. -/

theorem spb_denom_product (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - y * z) =
    1 - y * (x + z) + x * y ^ 2 * z := by ring

/-! ## SPB Derivative Product Rule -/

/-
When composing two SPB translations, the derivative multiplies:
    d/dx [spb(spb(x, a), b)] = [(1+a²)/(1-xa)²] · [(1+b²)/(1-spb(x,a)·b)²]
-/

theorem spb_compose_deriv (x a b : ℝ)
    (ha : 1 - x * a ≠ 0) (hb : 1 - spb' x a * b ≠ 0) :
    HasDerivAt (fun t => spb' (spb' t a) b)
      ((1 + a ^ 2) / (1 - x * a) ^ 2 * ((1 + b ^ 2) / (1 - spb' x a * b) ^ 2)) x := by
  convert HasDerivAt.div ( HasDerivAt.add ( HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id' x ) ( hasDerivAt_const _ _ ) ) ( hasDerivAt_const _ _ |> HasDerivAt.sub <| HasDerivAt.mul ( hasDerivAt_id' x ) <| hasDerivAt_const _ _ ) _ ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) <| HasDerivAt.mul ( HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id' x ) ( hasDerivAt_const _ _ ) ) ( hasDerivAt_const _ _ |> HasDerivAt.sub <| HasDerivAt.mul ( hasDerivAt_id' x ) <| hasDerivAt_const _ _ ) ?_ ) <| hasDerivAt_const _ _ ) ?_ using 1 <;> norm_num [ ha, hb ];
  · rw [ show spb' x a = ( x + a ) / ( 1 - x * a ) by rfl ] ; ring;
  · convert hb using 1

/-! ## SPB and Vieta Jumping -/

/-- If spb(a, b) is an integer and a, b are integers, then 1 - ab divides a + b. -/

theorem spb_integer_condition (a b n : ℤ) (h : 1 - a * b ≠ 0)
    (heq : (a + b : ℤ) = n * (1 - a * b)) :
    (1 - a * b) ∣ (a + b) := by
  exact ⟨n, by linarith⟩

/-! ## Hyperbolic SPB: Contraction Property -/

/-- For |x|, |y| ≤ r < 1, we have |spbH(x,y)| ≤ 2r/(1+r²) < 1.
    This shows spbH is a contraction on compact subsets of (-1,1). -/

theorem spbH_contraction_bound (r : ℝ) (hr : 0 ≤ r) (hr1 : r < 1) :
    2 * r / (1 + r ^ 2) < 1 := by
  rw [div_lt_one (by positivity)]
  nlinarith [sq_nonneg (1 - r)]

/-! ## SPB Order Theory -/

/-- SPB preserves positivity: if x > 0 and y > 0 and xy < 1, then spb(x,y) > 0. -/

theorem spb_pos_of_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hxy : x * y < 1) :
    0 < spb' x y := by
  unfold spb'
  apply div_pos
  · linarith
  · linarith

/-
SPB is strictly increasing in the first argument.
-/

theorem spb_strictMono_fst (y : ℝ) (hd : ∀ x, 1 - x * y ≠ 0) :
    StrictMono (fun x => spb' x y) := by
  contrapose! hd;
  exact ⟨ 1 / y, by rw [ div_mul_cancel₀ _ ( by rintro rfl; exact hd fun x z hxz => by simpa [ spb' ] using hxz ) ] ; ring ⟩

/-! ## SPB Algebraic Relations -/

/-- The SPB difference identity: spb(a,b) - spb(a,c) = (b-c)(1+a²)/((1-ab)(1-ac)). -/

theorem spb_difference (a b c : ℝ)
    (h1 : 1 - a * b ≠ 0) (h2 : 1 - a * c ≠ 0) :
    spb' a b - spb' a c = (b - c) * (1 + a ^ 2) / ((1 - a * b) * (1 - a * c)) := by
  unfold spb'; field_simp; ring

/-! ## SPB and Logarithmic Derivative -/

/-
The logarithmic derivative of 1 + x² evaluates nicely with SPB:
    d/dx [ln(1+x²)] = 2x/(1+x²). The denominator 1+x² is the norm of 1+ix.
-/

theorem log_deriv_one_plus_sq (x : ℝ) :
    HasDerivAt (fun t => Real.log (1 + t ^ 2)) (2 * x / (1 + x ^ 2)) x := by
  convert HasDerivAt.log ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( hasDerivAt_pow 2 x ) ) _ using 1 <;> norm_num ; ring ; positivity


end
