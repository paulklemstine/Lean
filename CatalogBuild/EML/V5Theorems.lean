/-! # CatalogBuild.EML.V5Theorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 63
-/

import Mathlib

noncomputable section

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def emlV (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal map: d(z) = exp(z) - ln(z). -/

def diagV (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- The e-tower: e↑↑n. -/

def eTowerV : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTowerV n)

/-- The tropical EML operator: trop(x,y) = max(x, -y). -/

def tropV (x y : ℝ) : ℝ := max x (-y)

/-! ## Section 1: EML Generates Key Constants -/


theorem emlV_e : emlV 1 1 = Real.exp 1 := by
  simp [emlV, Real.log_one]


theorem emlV_zero : emlV 1 (Real.exp (Real.exp 1)) = 0 := by
  simp [emlV, Real.log_exp]


theorem emlV_sub (a b : ℝ) (ha : 0 < a) :
    emlV (Real.log a) (Real.exp b) = a - b := by
  unfold emlV; rw [Real.exp_log ha, Real.log_exp]


theorem emlV_add (a b : ℝ) (ha : 0 < a) :
    emlV (Real.log a) (Real.exp (-b)) = a + b := by
  unfold emlV; rw [Real.exp_log ha]; simp


theorem emlV_mul (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a * b = Real.exp (Real.log a + Real.log b) := by
  rw [Real.exp_add, Real.exp_log ha, Real.exp_log hb]


theorem emlV_produces_negative : emlV 0 (Real.exp (Real.exp 1)) < 0 := by
  unfold emlV; simp

/-! ## Section 2: e-Tower Growth -/


theorem eTowerV_pos (n : ℕ) : 0 < eTowerV n := by
  induction n with
  | zero => simp [eTowerV]
  | succ n _ => exact Real.exp_pos _


theorem eTowerV_ge_one (n : ℕ) : 1 ≤ eTowerV n := by
  cases n with
  | zero => simp [eTowerV]
  | succ n => exact Real.one_le_exp (le_of_lt (eTowerV_pos n))


theorem eTowerV_strictMono : StrictMono eTowerV := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [eTowerV]
  linarith [Real.add_one_le_exp (eTowerV n)]

/-
e↑↑(n+1) ≥ e · e↑↑n (superexponential growth).
-/

theorem eTowerV_growth (n : ℕ) : eTowerV (n + 1) ≥ Real.exp 1 * eTowerV n := by
  -- Apply the inequality $e^{x} \geq e \cdot x$ with $x = eTowerV(n)$.
  have h_exp_ineq : Real.exp (eTowerV n) ≥ Real.exp 1 * eTowerV n := by
    rw [ show eTowerV n = 1 + ( eTowerV n - 1 ) by ring, Real.exp_add ];
    exact mul_le_mul_of_nonneg_left ( by linarith [ Real.add_one_le_exp ( eTowerV n - 1 ) ] ) ( Real.exp_nonneg _ );
  exact h_exp_ineq

/-
e↑↑n ≥ e^n for all n.
-/

theorem eTowerV_ge_exp_n (n : ℕ) : eTowerV n ≥ Real.exp 1 ^ n := by
  induction' n with n ih;
  · exact le_rfl;
  · rw [ pow_succ' ];
    exact le_trans ( mul_le_mul_of_nonneg_left ih <| by positivity ) ( eTowerV_growth n )

/-
The e-tower grows faster than any fixed polynomial.
-/

theorem eTowerV_dominates_poly (k : ℕ) :
    ∀ᶠ n in Filter.atTop, eTowerV n > (n : ℝ) ^ k := by
  -- Use that $e^n > n^k$ for sufficiently large $n$.
  have h_exp_gt_poly : ∀ᶠ n in Filter.atTop, (Real.exp 1) ^ n > (n : ℝ) ^ k := by
    -- We'll use that exponential functions grow faster than polynomial functions.
    have h_exp_growth : Filter.Tendsto (fun n : ℝ => (Real.exp 1) ^ n / n ^ k) Filter.atTop Filter.atTop := by
      norm_num [ Real.rpow_def_of_pos ( Real.exp_pos _ ) ];
      exact Real.tendsto_exp_div_pow_atTop _;
    filter_upwards [ h_exp_growth.eventually_gt_atTop 1, Filter.eventually_gt_atTop 0 ] with n hn hn' using by rw [ gt_iff_lt ] at *; rw [ lt_div_iff₀ ( pow_pos hn' _ ) ] at *; linarith;
  filter_upwards [ h_exp_gt_poly.natCast_atTop, Filter.eventually_ge_atTop 1 ] with n hn hn' ; norm_cast at *;
  exact hn.trans_le ( mod_cast eTowerV_ge_exp_n n )

/-! ## Section 3: Diagonal Map Analysis -/


theorem diagV_gt (z : ℝ) : diagV z > z := by
  unfold diagV;
  by_cases hz : z ≤ 0;
  · by_cases hz' : z = 0 <;> simp_all +decide [ Real.log_le_iff_le_exp ];
    linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos ( neg_pos.mpr ( lt_of_le_of_ne hz hz' ) ), Real.log_neg_eq_log z ];
  · have := Real.exp_one_gt_d9.le;
    norm_num1 at *; rw [ show Real.exp z = Real.exp 1 * Real.exp ( z - 1 ) by rw [ ← Real.exp_add, add_sub_cancel ] ] ; nlinarith [ Real.add_one_le_exp ( z - 1 ), Real.log_le_sub_one_of_pos ( by linarith : 0 < z ) ] ;


theorem diagV_no_fixedPoint (z : ℝ) : diagV z ≠ z :=
  ne_of_gt (diagV_gt z)


theorem diagV_deriv (z : ℝ) (hz : z ≠ 0) :
    HasDerivAt diagV (Real.exp z - z⁻¹) z :=
  (Real.hasDerivAt_exp z).sub (Real.hasDerivAt_log hz)

/-
d is convex on (0, ∞).
-/

theorem diagV_convexOn : ConvexOn ℝ (Ioi 0) diagV := by
  unfold diagV;
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log hx.out.ne' );
  · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx );
  · exact DifferentiableOn.congr ( show DifferentiableOn ℝ ( fun z => Real.exp z - 1 / z ) ( interior ( Ioi 0 ) ) from DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) <| DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) fun x hx => by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, show x ≠ 0 from ne_of_gt <| interior_subset hx ] ;
  · -- Let's calculate the second derivative of $diagV$.
    have h_deriv2 : ∀ z : ℝ, 0 < z → deriv^[2] (fun z => Real.exp z - Real.log z) z = Real.exp z + 1 / z^2 := by
      have h_deriv2 : ∀ z : ℝ, 0 < z → deriv^[2] (fun z => Real.exp z - Real.log z) z = deriv (fun z => Real.exp z - 1 / z) z := by
        exact fun z hz => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds hz ] with x hx using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hx.ne' ] );
      intro z hz; rw [ h_deriv2 z hz ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hz.ne' ];
    exact fun x hx => h_deriv2 x ( interior_subset hx ) ▸ add_nonneg ( Real.exp_nonneg x ) ( one_div_nonneg.mpr ( sq_nonneg x ) )

/-- The iterated diagonal map. -/

def iterDiagV : ℕ → ℝ → ℝ
  | 0 => id
  | n + 1 => diagV ∘ iterDiagV n


theorem iterDiagV_growth (n : ℕ) (z : ℝ) :
    iterDiagV (n + 1) z > iterDiagV n z := by
  simp [iterDiagV]; exact diagV_gt _

/-! ## Section 4: EML Complexity Theory -/

/-- Pure EML trees (all leaves = 1). -/

inductive PureTree where
  | leaf : PureTree
  | node : PureTree → PureTree → PureTree
  deriving Repr, DecidableEq


def PureTree.nodeCount : PureTree → ℕ
  | .leaf => 0
  | .node l r => 1 + l.nodeCount + r.nodeCount


def PureTree.leafCount : PureTree → ℕ
  | .leaf => 1
  | .node l r => l.leafCount + r.leafCount


noncomputable def PureTree.eval : PureTree → ℝ
  | .leaf => 1
  | .node l r => emlV l.eval r.eval


theorem PureTree.leafCount_eq_nodeCount_succ (t : PureTree) :
    t.leafCount = t.nodeCount + 1 := by
  induction t with
  | leaf => rfl
  | node l r ihl ihr =>
    simp [PureTree.leafCount, PureTree.nodeCount, ihl, ihr]; omega


theorem PureTree.eval_e :
    (PureTree.node .leaf .leaf).eval = Real.exp 1 := by
  simp [PureTree.eval, emlV, Real.log_one]


theorem PureTree.eval_ee :
    (PureTree.node (.node .leaf .leaf) .leaf).eval = Real.exp (Real.exp 1) := by
  simp [PureTree.eval, emlV, Real.log_one]


theorem PureTree.eval_zero :
    (PureTree.node .leaf (.node (.node .leaf .leaf) .leaf)).eval = 0 := by
  simp [PureTree.eval, emlV, Real.log_one, Real.log_exp]


theorem PureTree.eval_e_minus_one :
    (PureTree.node .leaf (.node .leaf .leaf)).eval = Real.exp 1 - 1 := by
  simp [PureTree.eval, emlV, Real.log_one, Real.log_exp]

/-- eml(e, e^e) = e^e - e. A 3-node tree producing e^e - e. -/

theorem PureTree.eval_ee_minus_e :
    (PureTree.node (.node .leaf .leaf) (PureTree.node (.node .leaf .leaf) .leaf)).eval
    = Real.exp (Real.exp 1) - Real.exp 1 := by
  simp [PureTree.eval, emlV, Real.log_one, Real.log_exp]


theorem exp_complexity_one : (PureTree.node .leaf .leaf).nodeCount = 1 := by rfl
theorem exp_exp_complexity_two :
    (PureTree.node (.node .leaf .leaf) .leaf).nodeCount = 2 := by rfl

theorem zero_complexity_three :
    (PureTree.node .leaf (.node (.node .leaf .leaf) .leaf)).nodeCount = 3 := by rfl

/-! ## Section 5: Tropical EML -/


theorem tropV_max (x y : ℝ) : tropV x (-y) = max x y := by
  unfold tropV; simp


theorem tropV_min (x y : ℝ) : -tropV (-x) y = min x y := by
  unfold tropV; simp [neg_sup, neg_neg]

/-- trop(z, z) = max(z, -z) = |z|. -/

theorem tropV_abs (z : ℝ) : tropV z z = |z| := by
  unfold tropV
  rcases le_or_gt z 0 with h | h
  · rw [max_eq_right (by linarith), abs_of_nonpos h]
  · rw [max_eq_left (by linarith), abs_of_pos h]


theorem tropV_comm_max (x y : ℝ) : tropV x (-y) = tropV y (-x) := by
  unfold tropV; simp [max_comm]

/-! ## Section 6: EML Trace and Difference -/


theorem emlV_trace (x y : ℝ) :
    emlV x y + emlV y x = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  unfold emlV; ring


theorem emlV_diff (x y : ℝ) :
    emlV x y - emlV y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold emlV; ring


theorem emlV_diag_double (z : ℝ) :
    emlV z z + emlV z z = 2 * diagV z := by
  unfold emlV diagV; ring

/-! ## Section 7: EML Interval Arithmetic -/


theorem emlV_interval_lower (x y a d : ℝ)
    (hx1 : a ≤ x) (hy2 : y ≤ d) (hy_pos : 0 < y) :
    Real.exp a - Real.log d ≤ emlV x y := by
  unfold emlV
  have h1 : Real.exp a ≤ Real.exp x := Real.exp_le_exp.mpr hx1
  have h2 : Real.log y ≤ Real.log d := Real.log_le_log hy_pos hy2
  linarith


theorem emlV_interval_upper (x y b c : ℝ)
    (hx2 : x ≤ b) (hy1 : c ≤ y) (hc : 0 < c) :
    emlV x y ≤ Real.exp b - Real.log c := by
  unfold emlV
  have h1 : Real.exp x ≤ Real.exp b := Real.exp_le_exp.mpr hx2
  have h2 : Real.log c ≤ Real.log y := Real.log_le_log hc hy1
  linarith

/-! ## Section 8: EML Power-Associativity Failure -/


theorem emlV_not_power_assoc : ∃ x : ℝ,
    emlV x (emlV x x) ≠ emlV (emlV x x) x := by
  use 0; norm_num [ emlV ] ;
  exact Ne.symm <| by norm_num;

/-! ## Section 9: EML Generates Arbitrarily Large Constants -/


theorem eTowerV_step_growth (n : ℕ) : eTowerV (n + 1) ≥ eTowerV n + 1 := by
  simp [eTowerV]; linarith [Real.add_one_le_exp (eTowerV n)]


theorem eTowerV_ge_succ (n : ℕ) : eTowerV n ≥ (n : ℝ) + 1 := by
  induction n with
  | zero => simp [eTowerV]
  | succ n ih => push_cast; linarith [eTowerV_step_growth n]


theorem eTowerV_unbounded : ∀ M : ℝ, ∃ n : ℕ, eTowerV n > M := by
  intro M
  obtain ⟨n, hn⟩ := exists_nat_gt M
  exact ⟨n, by linarith [eTowerV_ge_succ n]⟩


theorem emlV_small_constants : ∀ ε : ℝ, ε > 0 → ∃ n : ℕ,
    Real.exp (-eTowerV n) < ε := by
  intro ε hε
  obtain ⟨n, hn⟩ := eTowerV_unbounded (-Real.log ε)
  exact ⟨n, by
    have : Real.exp (-eTowerV n) < Real.exp (Real.log ε) :=
      Real.exp_lt_exp.mpr (by linarith)
    rwa [Real.exp_log hε] at this⟩

/-! ## Section 10: Complex EML -/


def emlVC (x y : ℂ) : ℂ := Complex.exp x - Complex.log y


def diagVC (z : ℂ) : ℂ := Complex.exp z - Complex.log z


theorem emlVC_differentiable_fst (y : ℂ) :
    Differentiable ℂ (fun x => emlVC x y) :=
  Complex.differentiable_exp.sub (differentiable_const _)

/-! ## Section 11: Fixed Point Iteration -/


def gIterV (z : ℝ) : ℝ := Real.exp 1 - Real.log z


theorem gIterV_fixedPoint_char (z : ℝ) (hfp : gIterV z = z) :
    z + Real.log z = Real.exp 1 := by
  unfold gIterV at hfp; linarith


theorem gIterV_product (z : ℝ) (hz : 0 < z)
    (hsum : z + Real.log z = Real.exp 1) :
    z * Real.exp z = Real.exp (Real.exp 1) := by
  rw [← hsum, Real.exp_add, Real.exp_log hz]; ring


theorem gIterV_contraction (z : ℝ) (hz : z > 1) : |-(z⁻¹)| < 1 := by
  rw [abs_neg, abs_of_pos (inv_pos.mpr (by linarith))]
  exact inv_lt_one_of_one_lt₀ hz


theorem gIterV_fixedPoint_gt_one (z : ℝ) (hz : 0 < z)
    (hfp : z + Real.log z = Real.exp 1) : z > 1 := by
  exact not_le.mp fun h => by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith [ Real.log_le_sub_one_of_pos hz ] ;

/-
The function h(z) = z + ln(z) - e is strictly monotone on (0,∞),
    guaranteeing uniqueness of the fixed point.
-/

theorem gIterV_uniqueness (z₁ z₂ : ℝ) (hz₁ : 0 < z₁) (hz₂ : 0 < z₂)
    (hfp₁ : gIterV z₁ = z₁) (hfp₂ : gIterV z₂ = z₂) : z₁ = z₂ := by
  unfold gIterV at *;
  exact le_antisymm ( le_of_not_gt fun h => by linarith [ Real.log_lt_log ( by positivity ) h ] ) ( le_of_not_gt fun h => by linarith [ Real.log_lt_log ( by positivity ) h ] )

/-! ## Section 12: EML Functional Equations -/

/-- The negation identity: eml(0, exp(x)) = 1 - x. -/

theorem emlV_negation (x : ℝ) : emlV 0 (Real.exp x) = 1 - x := by
  unfold emlV; simp

/-- Double negation via EML: eml(0, exp(eml(0, exp(x)))) = x. -/

theorem emlV_double_neg (x : ℝ) : emlV 0 (Real.exp (emlV 0 (Real.exp x))) = x := by
  unfold emlV; simp [Real.log_exp]

/-- The involution chain. -/

theorem emlV_involution_chain (x : ℝ) :
    emlV (emlV 0 (Real.exp (emlV x 1))) 1 = Real.exp (1 - Real.exp x) := by
  unfold emlV; simp [Real.log_one, Real.log_exp]

/-- eml(x, 1) = exp(x), so eml is an exponential when the second arg is 1. -/

theorem emlV_exp (x : ℝ) : emlV x 1 = Real.exp x := by
  unfold emlV; simp [Real.log_one]

/-- exp and log recovery: e - eml(1, x) = ln(x) for x > 0. -/

theorem emlV_log_recovery (x : ℝ) :
    Real.exp 1 - emlV 1 x = Real.log x := by
  unfold emlV; ring

/-- EML satisfies the chain: eml(a, exp(b)) composed with eml(c, exp(d))
    yields a certain algebraic relation. -/

theorem emlV_chain (a b c d : ℝ) :
    emlV (emlV a (Real.exp b)) (Real.exp (emlV c (Real.exp d))) =
    Real.exp (Real.exp a - b) - (Real.exp c - d) := by
  unfold emlV; simp [Real.log_exp]


end
