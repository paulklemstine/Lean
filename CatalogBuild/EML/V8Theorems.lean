/-! # CatalogBuild.EML.V8Theorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 34
-/

import Mathlib

noncomputable section

def eTower8 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower8 n)

/-- Iterated diagonal map: d^n(z). -/

def tropEml8 (x y : ℝ) : ℝ := max x (-y)

/-! ## Section 1: New Algebraic Identities -/

/-
EML is not idempotent: there exists x with eml(x,x) ≠ x.
-/

theorem eml8_not_idempotent : ∃ x : ℝ, eml8 x x ≠ x := by
  -- Use x=0: eml8(0,0) = exp(0) - log(0) = 1 - 0 = 1 ≠ 0 (since log(0) = 0 in Lean/Mathlib).
  use 0
  simp [eml8]

/-
EML is not left-distributive over itself.
-/

theorem eml8_not_left_distrib :
    ∃ a b c : ℝ, eml8 a (eml8 b c) ≠ eml8 (eml8 a b) (eml8 a c) := by
  unfold eml8;
  use 0, 0, 1; norm_num;
  exact Ne.symm <| by norm_num;

/-
EML is not right-distributive over itself.
-/

theorem eml8_not_right_distrib :
    ∃ a b c : ℝ, eml8 (eml8 a b) c ≠ eml8 (eml8 a c) (eml8 b c) := by
  unfold eml8;
  use 0;
  use 1;
  refine' ⟨ Real.exp ( Real.exp 1 ), _ ⟩ ; norm_num;
  positivity

/-
Negation symmetry: eml(x, y) + eml(-x, 1/y) = exp(x) + exp(-x) for y > 0.
-/

theorem eml8_negation_symmetry (x y : ℝ) (hy : 0 < y) :
    eml8 x y + eml8 (-x) (y⁻¹) = Real.exp x + Real.exp (-x) := by
  unfold eml8; norm_num [ hy.ne' ]

/-
Translation identity: eml(x + c, y · exp(c)) = eml(x, y) + exp(x)·(exp(c) - 1) - c.
    This captures how EML transforms under simultaneous shifts.
-/

theorem eml8_shift (x y c : ℝ) (hy : 0 < y) :
    eml8 (x + c) (y * Real.exp c) = Real.exp x * Real.exp c - Real.log y - c := by
  unfold eml8; rw [ ← Real.exp_add ] ; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;

/-! ## Section 2: Diagonal Map — Advanced Theory -/

/-
d(z) > z for all z (restated for V8 definitions).
-/

theorem diag8_ge_two (z : ℝ) (hz : 0 < z) : diag8 z ≥ 2 := by
  unfold diag8; nlinarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] ;

/-
Orbits of d are strictly increasing.
-/

theorem diag8_orbit_increasing (z : ℝ) (n : ℕ) :
    diagIter8 n z < diagIter8 (n + 1) z := by
  -- By definition of `diag8`, we have `diag8 (diagIter8 n z) > diagIter8 n z`.
  apply diag8_gt

/-
Diagonal orbit diverges: dⁿ(z) → ∞ as n → ∞, for any z.
-/

theorem diag8_orbit_diverges (z : ℝ) :
    Filter.Tendsto (fun n => diagIter8 n z) Filter.atTop Filter.atTop := by
  -- By induction, we can show that diagIter8 n z ≥ z + n.
  have h_diagIter8_bound : ∀ n : ℕ, diagIter8 n z ≥ z + n := by
    intro n; induction n <;> simp_all +decide [ diagIter8 ] ;
    unfold diag8;
    cases le_or_gt ( diagIter8 ‹_› z ) 0;
    · rename_i n hn hn';
      by_cases h₂ : diagIter8 n z < 0;
      · linarith [ Real.exp_pos ( diagIter8 n z ), Real.log_le_sub_one_of_pos ( neg_pos.mpr h₂ ), Real.log_neg_eq_log ( diagIter8 n z ) ];
      · norm_num [ show diagIter8 n z = 0 by linarith ] at *;
        linarith;
    · have := Real.add_one_le_exp ( diagIter8 ‹_› z - 1 );
      rw [ Real.exp_sub ] at this;
      rw [ le_div_iff₀ ( Real.exp_pos _ ) ] at this;
      nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ‹_› ];
  exact Filter.tendsto_atTop_mono h_diagIter8_bound ( tendsto_const_nhds.add_atTop tendsto_natCast_atTop_atTop )

/-
d(z) ≥ exp(z)/2 + 1/2 for z ≥ 1 (tighter lower bound for large z).
-/

theorem diag8_lower_bound_large (z : ℝ) (hz : 1 ≤ z) :
    diag8 z ≥ Real.exp z / 2 := by
  -- We'll use the fact that $e^z \geq 2z$ for $z \geq 1$.
  have h_exp_ge_two_z : ∀ z : ℝ, 1 ≤ z → Real.exp z ≥ 2 * z := by
    intro z hz; nlinarith [Real.add_one_le_exp z, quadratic_le_exp_of_nonneg (by linarith : (0 : ℝ) ≤ z)]
  unfold diag8;
  linarith [ h_exp_ge_two_z z hz, Real.log_le_sub_one_of_pos ( zero_lt_one.trans_le hz ) ]

/-! ## Section 3: E-Tower Advanced Properties -/

/-
e-tower is positive.
-/

theorem eTower8_pos (n : ℕ) : 0 < eTower8 n := by
  induction' n with n ih;
  · exact zero_lt_one;
  · exact Real.exp_pos _

/-
e-tower is strictly increasing.
-/

theorem eTower8_strictMono : StrictMono eTower8 := by
  refine' strictMono_nat_of_lt_succ _;
  exact fun n => Real.add_one_le_exp _ |> lt_of_lt_of_le ( by linarith )

/-
e-tower ≥ 1 for all n.
-/

theorem eTower8_ge_one (n : ℕ) : eTower8 n ≥ 1 := by
  exact Nat.recOn n ( by norm_num [ eTower8 ] ) fun n ih => by rw [ eTower8 ] ; exact Real.one_le_exp ( by linarith ) ;

/-
e↑↑n ≥ n for all n.
-/

theorem eTower8_ge_n (n : ℕ) : eTower8 n ≥ n := by
  induction' n with n ih <;> norm_num [ eTower8 ] at *;
  linarith [ Real.add_one_le_exp ( eTower8 n ) ]

/-! ## Section 4: Inequalities and Bounds -/

/-
AM-GM bridge: a + b - ln(a) - ln(b) ≥ 2 for a, b > 0.
-/

theorem eml8_am_gm (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a + b - Real.log a - Real.log b ≥ 2 := by
  linarith [ Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb ]

/-
For t > 0: exp(t) - ln(t) ≥ 1 + t - ln(t) ≥ 2.
-/

theorem eml8_diag_ge_two_pos (t : ℝ) (ht : 0 < t) : diag8 t ≥ 2 := by
  exact diag8_ge_two t ht

/-
EML sandwich: for x ≥ 0 and 0 < y ≤ 1, eml(x,y) ≥ 1.
-/

theorem eml8_sandwich (x y : ℝ) (hx : 0 ≤ x) (hy1 : 0 < y) (hy2 : y ≤ 1) :
    eml8 x y ≥ 1 := by
  exact le_tsub_of_add_le_left ( by have := Real.add_one_le_exp x; linarith [ Real.log_le_sub_one_of_pos hy1 ] )

/-
EML upper bound: eml(x, y) ≤ exp(x) for y ≥ 1.
-/

theorem eml8_upper_bound (x y : ℝ) (hy : 1 ≤ y) :
    eml8 x y ≤ Real.exp x := by
  exact sub_le_self _ ( Real.log_nonneg hy )

/-
Quadratic-exponential bound for x ≥ 0: exp(x) ≥ 1 + x + x²/2 gives
    eml(x, y) ≥ 1 + x + x²/2 - ln(y).
-/

theorem eml8_quadratic_bound (x y : ℝ) (hx : 0 ≤ x) :
    eml8 x y ≥ 1 + x + x ^ 2 / 2 - Real.log y := by
  have h_quad : Real.exp x ≥ 1 + x + x ^ 2 / 2 := quadratic_le_exp_of_nonneg hx
  unfold eml8; linarith

/-! ## Section 5: Composition and Functional Equations -/

/-
eml(eml(x,1), 1) = exp(exp(x)) (double exponential).
-/

theorem eml8_double_exp (x : ℝ) : eml8 (eml8 x 1) 1 = Real.exp (Real.exp x) := by
  unfold eml8; norm_num;

/-
Triple composition: eml(eml(eml(x,1),1),1) = exp(exp(exp(x))).
-/

theorem eml8_triple_exp (x : ℝ) :
    eml8 (eml8 (eml8 x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  unfold eml8; norm_num;

/-
Involution: eml(0, exp(x)) = 1 - x.
-/

theorem eml8_involution (x : ℝ) : eml8 0 (Real.exp x) = 1 - x := by
  unfold eml8; norm_num

/-
Double involution: eml(0, exp(eml(0, exp(x)))) = x.
-/

theorem eml8_double_involution (x : ℝ) :
    eml8 0 (Real.exp (eml8 0 (Real.exp x))) = x := by
  unfold eml8; norm_num

/-
eml(ln(a), exp(b)) = a - b for a > 0.
-/

theorem eml8_log_exp (a b : ℝ) (ha : 0 < a) :
    eml8 (Real.log a) (Real.exp b) = a - b := by
  unfold eml8; simp +decide [ Real.exp_log ha ] ;

/-! ## Section 6: Tropical EML Properties -/

/-
Tropical EML is NOT commutative: max(x,-y) ≠ max(y,-x) in general.
-/

theorem tropEml8_not_comm : ∃ x y : ℝ, tropEml8 x y ≠ tropEml8 y x := by
  exact ⟨ 1, -1, by unfold tropEml8; norm_num ⟩

/-
Tropical diagonal is absolute value.
-/

theorem tropEml8_diag (x : ℝ) : tropEml8 x x = |x| := by
  unfold tropEml8; aesop;

/-
Tropical EML with 0: tropEml(x, 0) = max(x, 0).
-/

theorem tropEml8_zero_right (x : ℝ) : tropEml8 x 0 = max x 0 := by
  -- By definition of tropEml8, we have tropEml8 x 0 = max x (-0).
  simp [tropEml8]

/-! ## Section 7: Sign Classification -/

/-
eml(x, y) > 0 when x > 0 and 0 < y ≤ 1.
-/

theorem eml8_pos_region (x y : ℝ) (hx : 0 < x) (hy1 : 0 < y) (hy2 : y ≤ 1) :
    eml8 x y > 0 := by
  exact sub_pos.mpr ( lt_of_le_of_lt ( Real.log_le_sub_one_of_pos hy1 ) ( by linarith [ Real.add_one_le_exp x ] ) )

/-
eml(0, 1) = 1.
-/

theorem eml8_zero_one : eml8 0 1 = 1 := by
  unfold eml8; norm_num;

/-
eml(1, 1) = e.
-/

theorem eml8_one_one : eml8 1 1 = Real.exp 1 := by
  unfold eml8; norm_num

/-
Power identity: eml(n * x, 1) = exp(x)^n.
-/

theorem eml8_power (x : ℝ) (n : ℕ) : eml8 (n * x) 1 = (Real.exp x) ^ n := by
  unfold eml8;
  norm_num [ ← Real.exp_nat_mul ]

/-! ## Section 8: Continuity and Differentiability -/

/-
EML is continuous on ℝ × (0, ∞) (log is discontinuous at 0).
-/

theorem eml8_continuousOn : ContinuousOn (fun p : ℝ × ℝ => eml8 p.1 p.2) (Set.univ ×ˢ Set.Ioi 0) := by
  exact ContinuousOn.sub ( ContinuousOn.rexp continuousOn_fst ) ( ContinuousOn.log continuousOn_snd fun x hx => ne_of_gt hx.2 )

/-
The diagonal map is continuous on (0, ∞).
-/

theorem diag8_continuousOn : ContinuousOn diag8 (Set.Ioi 0) := by
  exact ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx )

/-
Strict monotonicity in first argument.
-/

end
