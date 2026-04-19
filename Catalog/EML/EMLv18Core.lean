import Mathlib
import EML.EMLv17Core
import EML.EMLv17Advanced

/-!
# EML Operator V18 — New Research Frontiers

Version 18 explores deeper analytical properties of eml(x, y) = exp(x) - ln(y),
including diagonal convexity, σ-EML calculus, Fenchel duality, new integral
identities, and information-geometric connections.
-/

noncomputable section
open Real Set Filter Topology MeasureTheory

/-! ## §1. Diagonal Convexity -/

/-- The second derivative of the diagonal d(z) = e^z - ln z is e^z + 1/z²,
    which is strictly positive for z > 0. -/
theorem emlDiag_second_deriv_pos' (z : ℝ) (hz : 0 < z) :
    exp z + z⁻¹ ^ 2 > 0 := by positivity

/-
The diagonal d(z) = e^z - ln z is strictly convex on (0,∞),
    being the sum of strictly convex e^z and convex -ln z.
-/
theorem emlDiag_strictConvexOn :
    StrictConvexOn ℝ (Ioi 0) emlDiag := by
      fapply strictConvexOn_of_deriv2_pos;
      · exact convex_Ioi 0;
      · exact ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx );
      · -- Let's calculate the second derivative of $f(z) = e^z - \ln z$.
        have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = Real.exp z + 1 / z^2 := by
          have h_second_deriv : ∀ z > 0, deriv^[2] (fun z => Real.exp z - Real.log z) z = deriv (fun z => Real.exp z - 1 / z) z := by
            exact fun z hz => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds hz ] with x hx using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hx.ne' ] );
          intro z hz; rw [ h_second_deriv z hz ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hz.ne' ] ;
        exact fun x hx => h_second_deriv x ( interior_subset hx ) ▸ add_pos_of_pos_of_nonneg ( Real.exp_pos x ) ( by positivity )

/-
The diagonal is convex on (0,∞).
-/
theorem emlDiag_convexOn : ConvexOn ℝ (Ioi 0) emlDiag := by
  exact StrictConvexOn.convexOn emlDiag_strictConvexOn

/-! ## §2. Chain Decomposition Identity -/

/-
EML chain rule: eml(x, z) = eml(x, y) - ln(z/y) for y, z > 0.
-/
theorem eml_chain_identity (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x z = eml x y - log (z / y) := by
      unfold eml; rw [ Real.log_div hz.ne' hy.ne' ] ; ring;

/-
Triangle-like decomposition: eml(x, z) + 1 = eml(x, y) + eml(0, z/y).
-/
theorem eml_triangle_decomposition (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x z + 1 = eml x y + eml 0 (z / y) := by
      unfold eml; simp +decide [ hy.ne', hz.ne', Real.log_div ] ; ring;

/-! ## §3. EML Complement Law -/

/-
The EML complement: eml(0, exp(t)) + t = 1 for all t.
-/
theorem eml_complement (t : ℝ) : eml 0 (exp t) + t = 1 := by
  unfold eml; norm_num;

/-
Every EML value and its "complement" sum to 1.
-/
theorem eml_value_complement (x y : ℝ) :
    eml x y + eml 0 (exp (eml x y)) = 1 := by
      convert eml_complement ( eml x y ) using 1;
      ring

/-! ## §4. σ-EML Calculus -/

/-
The derivative of σ_EML at x is exp(x) + exp(-x)/(1 + exp(-x)).
-/
theorem sigmaEml_hasDerivAt (x : ℝ) :
    HasDerivAt sigmaEml (exp x + exp (-x) / (1 + exp (-x))) x := by
      convert HasDerivAt.sub ( Real.hasDerivAt_exp x ) ( HasDerivAt.log ( HasDerivAt.add ( hasDerivAt_const _ _ ) <| HasDerivAt.exp <| hasDerivAt_neg x ) _ ) using 1 <;> norm_num;
      · ring;
      · positivity

/-
The derivative of σ_EML is always positive.
-/
theorem sigmaEml_deriv_pos (x : ℝ) :
    exp x + exp (-x) / (1 + exp (-x)) > 0 := by
      positivity

/-
σ_EML is differentiable everywhere.
-/
theorem sigmaEml_differentiable : Differentiable ℝ sigmaEml := by
  exact fun x => ( sigmaEml_hasDerivAt x |> HasDerivAt.differentiableAt )

/-
σ_EML is continuous.
-/
theorem sigmaEml_continuous : Continuous sigmaEml := by
  convert sigmaEml_differentiable.continuous using 1

/-
For x ≤ 0, σ_EML(x) ≤ 1.
-/
theorem sigmaEml_le_one_of_nonpos (x : ℝ) (hx : x ≤ 0) :
    sigmaEml x ≤ 1 := by
      exact le_trans ( sub_le_self _ <| Real.log_nonneg <| by linarith [ Real.exp_pos ( -x ) ] ) <| by linarith [ Real.exp_le_one_iff.mpr hx ] ;

/-
σ_EML tends to -∞ as x → -∞ (unbounded below, unlike sigmoid/softplus).
-/
theorem sigmaEml_tendsto_atBot :
    Tendsto sigmaEml atBot atBot := by
      rw [ Filter.tendsto_atBot_atBot ];
      unfold sigmaEml;
      intro b;
      use -2 - |b|;
      intro a ha; cases abs_cases b <;> linarith [ Real.exp_le_one_iff.mpr ( show a ≤ 0 by linarith ), Real.log_exp ( -a ), Real.log_le_log ( by positivity ) ( show 1 + Real.exp ( -a ) ≥ Real.exp ( -a ) by linarith [ Real.exp_pos ( -a ) ] ) ] ;

/-! ## §5. Diagonal Bounds -/

/-
Improved diagonal bound: d(z) ≥ 1 + z for 0 < z ≤ 1.
-/
theorem emlDiag_ge_one_add (z : ℝ) (hz : 0 < z) (hz1 : z ≤ 1) :
    emlDiag z ≥ 1 + z := by
      exact le_tsub_of_add_le_left ( by linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] )

/-
d(z) ≥ exp(z) for 0 < z ≤ 1 (since -ln z ≥ 0).
-/
theorem emlDiag_ge_exp_of_le_one (z : ℝ) (hz : 0 < z) (hz1 : z ≤ 1) :
    emlDiag z ≥ exp z := by
      exact le_tsub_of_add_le_right ( by linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ] )

/-! ## §6. Fenchel-Young Type Inequality -/

/-
Fenchel-Young for -log: -log(y) ≥ 1 - y/s - log(s) for y, s > 0.
-/
theorem neg_log_fenchel (y s : ℝ) (hy : 0 < y) (hs : 0 < s) :
    -log y ≥ 1 - y * s⁻¹ - log s := by
      have := Real.log_le_sub_one_of_pos ( div_pos ( inv_pos.mpr hs ) ( inv_pos.mpr hy ) );
      rw [ Real.log_div ] at this <;> norm_num at * <;> nlinarith [ inv_pos.2 hy, inv_pos.2 hs, mul_inv_cancel₀ hy.ne', mul_inv_cancel₀ hs.ne' ]

/-! ## §7. Exponential Superadditivity -/

/-
exp(a+b) ≥ exp(a) + exp(b) - 1 for a, b ≥ 0.
-/
theorem exp_add_ge (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    exp (a + b) ≥ exp a + exp b - 1 := by
      rw [ Real.exp_add ] ; nlinarith [ Real.exp_pos a, Real.exp_pos b, Real.add_one_le_exp a, Real.add_one_le_exp b ] ;

/-! ## §8. Gibbs Strengthening -/

/-
Quantitative Gibbs: for 0 < p ≤ 1, -log(p) ≥ 1 - p.
    Equivalently p - log(p) ≥ 1 (a specialization of sub_log_ge_one).
-/
theorem neg_log_ge_one_sub (p : ℝ) (hp : 0 < p) (hp1 : p ≤ 1) :
    -log p ≥ 1 - p := by
      linarith [ Real.log_le_sub_one_of_pos hp ]

/-! ## §9. EML Tower Function -/

/-- The n-fold iterated exponential (EML tower). -/
def emlTower : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => exp (emlTower n x)

theorem emlTower_zero (x : ℝ) : emlTower 0 x = x := rfl
theorem emlTower_succ (n : ℕ) (x : ℝ) : emlTower (n + 1) x = exp (emlTower n x) := rfl

/-
emlTower (n+1) x = eml(emlTower n x, 1).
-/
theorem emlTower_eq_eml (n : ℕ) (x : ℝ) :
    emlTower (n + 1) x = eml (emlTower n x) 1 := by
      unfold eml; aesop

/-
The tower sequence is strictly increasing for x ≥ 0.
-/
theorem emlTower_strictMono_nat (x : ℝ) (hx : 0 ≤ x) :
    StrictMono (fun n => emlTower n x) := by
      refine' strictMono_nat_of_lt_succ _;
      intro n; induction n <;> simp_all +decide [ emlTower_succ ] ;
      exact Real.add_one_le_exp _ |> lt_of_lt_of_le ( by linarith )

/-! ## §10. Geometric Mean Identity -/

/-
EML at the geometric mean equals the arithmetic mean of EML values:
    eml(x, √(ab)) = (eml(x,a) + eml(x,b))/2 for a, b > 0.
-/
theorem eml_geometric_mean (x a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml x (Real.sqrt (a * b)) = (eml x a + eml x b) / 2 := by
      unfold eml;
      rw [ Real.log_sqrt ( by positivity ), Real.log_mul ha.ne' hb.ne' ] ; ring

/-! ## §11. Monotone Sequences -/

/-
If (xₙ) is increasing and (yₙ) is decreasing with yₙ > 0,
    then eml(xₙ, yₙ) is increasing.
-/
theorem eml_mono_seq {x y : ℕ → ℝ} (hx : Monotone x) (hy : Antitone y)
    (hyp : ∀ n, 0 < y n) :
    Monotone (fun n => eml (x n) (y n)) := by
      -- By definition of eml, we know that if n ≤ m, then eml(x n, y n) ≤ eml(x m, y m).
      intro n m hnm
      simp [eml];
      linarith [ Real.exp_le_exp.mpr ( hx hnm ), Real.log_le_log ( hyp m ) ( hy hnm ) ]

/-! ## §12. Lambert W at Fixed Point -/

/-
If g(z) = z with z > 0, then z + ln(z) = e.
-/
theorem gmap_fixed_point_lambert (z : ℝ) (hz : 0 < z) (hfix : emlGmap z = z) :
    z + log z = exp 1 := by
      unfold emlGmap at hfix; linarith;

/-! ## §13. EML Antisymmetric Part -/

/-
eml(x,y) - eml(y,x) = (exp x - exp y) + (log x - log y).
-/
theorem eml_antisymmetric (x y : ℝ) :
    eml x y - eml y x = (exp x - exp y) + (log x - log y) := by
      unfold eml; ring;

/-
For x, y ≥ 1 with x ≤ y: eml(y,x) ≥ eml(x,y).
-/
theorem eml_gap_sign (x y : ℝ) (hx : 1 ≤ x) (hy : 1 ≤ y) (hxy : x ≤ y) :
    eml y x ≥ eml x y := by
      exact sub_le_sub ( Real.exp_le_exp.mpr hxy ) ( Real.log_le_log ( by positivity ) hxy )

/-! ## §14. Hessian Properties -/

/-- det(Hessian) = exp(x) · (1/y²) > 0 for y > 0. -/
theorem eml_hessian_det (x y : ℝ) (hy : 0 < y) :
    exp x * (y⁻¹ ^ 2) > 0 := by positivity

/-- The Laplacian exp(x) + 1/y² is strictly positive. -/
theorem eml_laplacian_pos (x y : ℝ) (hy : 0 < y) :
    exp x + y⁻¹ ^ 2 > 0 := by positivity

/-! ## §15. New Evaluation Identities -/

/-
eml(ln 3, 3) = 3 - ln 3.
-/
theorem eml_eval_ln3_3 : eml (log 3) 3 = 3 - log 3 := by
  unfold eml; norm_num [ Real.exp_log ] ;

/-
eml(x, exp(-1)) = exp(x) + 1.
-/
theorem eml_at_inv_e (x : ℝ) : eml x (exp (-1)) = exp x + 1 := by
  unfold eml; norm_num;

/-
eml(1, exp(-1)) = e + 1.
-/
theorem eml_eval_1_inv_e : eml 1 (exp (-1)) = exp 1 + 1 := by
  unfold eml; norm_num

/-
eml(0, exp(-1)) = 2.
-/
theorem eml_eval_0_inv_e : eml 0 (exp (-1)) = 2 := by
  unfold eml; norm_num;

/-! ## §16. Joint Continuity -/

/-
EML is continuous on ℝ × (0,∞).
-/
theorem eml_continuousOn :
    ContinuousOn (fun p : ℝ × ℝ => eml p.1 p.2) (univ ×ˢ Ioi 0) := by
      exact ContinuousOn.sub ( ContinuousOn.rexp continuousOn_fst ) ( ContinuousOn.log continuousOn_snd fun p hp => ne_of_gt hp.2 )

/-! ## §17. Power Scaling -/

/-
eml(x, y^a) = exp(x) - a·ln(y) for y > 0.
-/
theorem eml_power_snd (x y a : ℝ) (hy : 0 < y) :
    eml x (y ^ a) = exp x - a * log y := by
      unfold eml; rw [ Real.log_rpow hy ] ;

/-
eml(2x, y) = (exp x)² - ln(y).
-/
theorem eml_double_fst (x y : ℝ) :
    eml (2 * x) y = (exp x) ^ 2 - log y := by
      rw [ ← Real.exp_nat_mul, mul_comm ];
      unfold eml; ring;

/-! ## §18. Bregman Divergence from exp -/

/-
The Bregman divergence from exp: D_exp(x₁,x₂) = exp(x₁) - exp(x₂) - exp(x₂)·(x₁-x₂) ≥ 0.
-/
theorem eml_bregman_exp_nonneg (x₁ x₂ : ℝ) :
    exp x₁ - exp x₂ - exp x₂ * (x₁ - x₂) ≥ 0 := by
      rw [ show x₁ = x₂ + ( x₁ - x₂ ) by ring, Real.exp_add ];
      nlinarith [ Real.add_one_le_exp x₂, Real.add_one_le_exp ( x₁ - x₂ ), Real.exp_pos x₂, Real.exp_pos ( x₁ - x₂ ) ]

/-
The Itakura-Saito divergence: log(y₂/y₁) + y₁/y₂ - 1 ≥ 0 for y₁, y₂ > 0.
-/
theorem eml_itakura_saito_nonneg (y₁ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    log (y₂ / y₁) + y₁ / y₂ - 1 ≥ 0 := by
      have h := reverse_kl_nonneg ( y₁ / y₂ ) ( by positivity );
      rw [ show y₂ / y₁ = ( y₁ / y₂ ) ⁻¹ by rw [ inv_div ], Real.log_inv ] ; linarith

end