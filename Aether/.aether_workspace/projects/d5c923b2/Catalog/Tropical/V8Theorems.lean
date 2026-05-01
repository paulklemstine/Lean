import Mathlib

/-! # CatalogBuild.EML.V8Theorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 34
-/

noncomputable section

/-- The e-tower: e↑↑n (iterated exponential). -/
def eTower8 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower8 n)

/-- Tropical EML: tropEml(x,y) = max(x, -y). -/
def tropEml8 (x y : ℝ) : ℝ := max x (-y)

/-- [Section: # CatalogBuild.EML.V8Theorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 34] -/
theorem eml8_not_idempotent : ∃ x : ℝ, eml8 x x ≠ x := by
  -- Use x=0: eml8(0,0) = exp(0) - log(0) = 1 - 0 = 1 ≠ 0 (since log(0) = 0 in Lean/Mathlib).
  use 0
  simp [eml8]

/-- [Section: # CatalogBuild.EML.V8Theorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 34] -/
theorem eml8_not_left_distrib :
    ∃ a b c : ℝ, eml8 a (eml8 b c) ≠ eml8 (eml8 a b) (eml8 a c) := by
  unfold eml8;
  use 0, 0, 1; norm_num;
  exact Ne.symm <| by norm_num;

theorem eml8_not_right_distrib :
    ∃ a b c : ℝ, eml8 (eml8 a b) c ≠ eml8 (eml8 a c) (eml8 b c) := by
  unfold eml8;
  use 0;
  use 1;
  refine' ⟨ Real.exp ( Real.exp 1 ), _ ⟩ ; norm_num;
  positivity

theorem eml8_negation_symmetry (x y : ℝ) (hy : 0 < y) :
    eml8 x y + eml8 (-x) (y⁻¹) = Real.exp x + Real.exp (-x) := by
  unfold eml8; norm_num [ hy.ne' ]

theorem eml8_shift (x y c : ℝ) (hy : 0 < y) :
    eml8 (x + c) (y * Real.exp c) = Real.exp x * Real.exp c - Real.log y - c := by
  unfold eml8; rw [ ← Real.exp_add ] ; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;

theorem diag8_ge_two (z : ℝ) (hz : 0 < z) : diag8 z ≥ 2 := by
  unfold diag8; nlinarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] ;

theorem diag8_orbit_increasing (z : ℝ) (n : ℕ) :
    diagIter8 n z < diagIter8 (n + 1) z := by
  -- By definition of `diag8`, we have `diag8 (diagIter8 n z) > diagIter8 n z`.
  apply diag8_gt

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

theorem diag8_lower_bound_large (z : ℝ) (hz : 1 ≤ z) :
    diag8 z ≥ Real.exp z / 2 := by
  -- We'll use the fact that $e^z \geq 2z$ for $z \geq 1$.
  have h_exp_ge_two_z : ∀ z : ℝ, 1 ≤ z → Real.exp z ≥ 2 * z := by
    intro z hz; nlinarith [Real.add_one_le_exp z, quadratic_le_exp_of_nonneg (by linarith : (0 : ℝ) ≤ z)]
  unfold diag8;
  linarith [ h_exp_ge_two_z z hz, Real.log_le_sub_one_of_pos ( zero_lt_one.trans_le hz ) ]

theorem eTower8_pos (n : ℕ) : 0 < eTower8 n := by
  induction' n with n ih;
  · exact zero_lt_one;
  · exact Real.exp_pos _

theorem eTower8_strictMono : StrictMono eTower8 := by
  refine' strictMono_nat_of_lt_succ _;
  exact fun n => Real.add_one_le_exp _ |> lt_of_lt_of_le ( by linarith )

theorem eTower8_ge_one (n : ℕ) : eTower8 n ≥ 1 := by
  exact Nat.recOn n ( by norm_num [ eTower8 ] ) fun n ih => by rw [ eTower8 ] ; exact Real.one_le_exp ( by linarith ) ;

theorem eTower8_ge_n (n : ℕ) : eTower8 n ≥ n := by
  induction' n with n ih <;> norm_num [ eTower8 ] at *;
  linarith [ Real.add_one_le_exp ( eTower8 n ) ]

theorem eml8_am_gm (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a + b - Real.log a - Real.log b ≥ 2 := by
  linarith [ Real.log_le_sub_one_of_pos ha, Real.log_le_sub_one_of_pos hb ]

theorem eml8_diag_ge_two_pos (t : ℝ) (ht : 0 < t) : diag8 t ≥ 2 := by
  exact diag8_ge_two t ht

theorem eml8_sandwich (x y : ℝ) (hx : 0 ≤ x) (hy1 : 0 < y) (hy2 : y ≤ 1) :
    eml8 x y ≥ 1 := by
  exact le_tsub_of_add_le_left ( by have := Real.add_one_le_exp x; linarith [ Real.log_le_sub_one_of_pos hy1 ] )

theorem eml8_upper_bound (x y : ℝ) (hy : 1 ≤ y) :
    eml8 x y ≤ Real.exp x := by
  exact sub_le_self _ ( Real.log_nonneg hy )

theorem eml8_quadratic_bound (x y : ℝ) (hx : 0 ≤ x) :
    eml8 x y ≥ 1 + x + x ^ 2 / 2 - Real.log y := by
  have h_quad : Real.exp x ≥ 1 + x + x ^ 2 / 2 := quadratic_le_exp_of_nonneg hx
  unfold eml8; linarith

theorem eml8_double_exp (x : ℝ) : eml8 (eml8 x 1) 1 = Real.exp (Real.exp x) := by
  unfold eml8; norm_num;

theorem eml8_triple_exp (x : ℝ) :
    eml8 (eml8 (eml8 x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  unfold eml8; norm_num;

theorem eml8_involution (x : ℝ) : eml8 0 (Real.exp x) = 1 - x := by
  unfold eml8; norm_num

theorem eml8_double_involution (x : ℝ) :
    eml8 0 (Real.exp (eml8 0 (Real.exp x))) = x := by
  unfold eml8; norm_num

theorem eml8_log_exp (a b : ℝ) (ha : 0 < a) :
    eml8 (Real.log a) (Real.exp b) = a - b := by
  unfold eml8; simp +decide [ Real.exp_log ha ] ;

theorem tropEml8_not_comm : ∃ x y : ℝ, tropEml8 x y ≠ tropEml8 y x := by
  exact ⟨ 1, -1, by unfold tropEml8; norm_num ⟩

theorem tropEml8_diag (x : ℝ) : tropEml8 x x = |x| := by
  unfold tropEml8; aesop;

theorem tropEml8_zero_right (x : ℝ) : tropEml8 x 0 = max x 0 := by
  -- By definition of tropEml8, we have tropEml8 x 0 = max x (-0).
  simp [tropEml8]

theorem eml8_pos_region (x y : ℝ) (hx : 0 < x) (hy1 : 0 < y) (hy2 : y ≤ 1) :
    eml8 x y > 0 := by
  exact sub_pos.mpr ( lt_of_le_of_lt ( Real.log_le_sub_one_of_pos hy1 ) ( by linarith [ Real.add_one_le_exp x ] ) )

theorem eml8_zero_one : eml8 0 1 = 1 := by
  unfold eml8; norm_num;

theorem eml8_one_one : eml8 1 1 = Real.exp 1 := by
  unfold eml8; norm_num

theorem eml8_power (x : ℝ) (n : ℕ) : eml8 (n * x) 1 = (Real.exp x) ^ n := by
  unfold eml8;
  norm_num [ ← Real.exp_nat_mul ]

theorem eml8_continuousOn : ContinuousOn (fun p : ℝ × ℝ => eml8 p.1 p.2) (Set.univ ×ˢ Set.Ioi 0) := by
  exact ContinuousOn.sub ( ContinuousOn.rexp continuousOn_fst ) ( ContinuousOn.log continuousOn_snd fun x hx => ne_of_gt hx.2 )

theorem diag8_continuousOn : ContinuousOn diag8 (Set.Ioi 0) := by
  exact ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx )

end