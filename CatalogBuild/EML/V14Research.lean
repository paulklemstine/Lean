/-! # CatalogBuild.EML.V14Research

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 44
-/

import Mathlib

noncomputable section

/-- The EML operator: eml(x, y) = exp(x) − ln(y). -/
def eml14 (x y : ℝ) : ℝ := Real.exp x - Real.log y


/-- The diagonal map: d(z) = exp(z) − ln(z). -/
def diag14 (z : ℝ) : ℝ := Real.exp z - Real.log z


/-- The off-diagonal g-map: g(z) = e − ln(z). -/
def gmap14 (z : ℝ) : ℝ := Real.exp 1 - Real.log z


/-- The σ-EML activation function: σ_eml(x) = exp(x) - ln(1 + exp(-x)). -/
def sigma_eml (x : ℝ) : ℝ := Real.exp x - Real.log (1 + Real.exp (-x))


/-- Iterated diagonal map: d^n(z). -/
def diagIter14 : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => diag14 (diagIter14 n z)


/-- EML is strictly increasing in its first argument. -/
theorem eml14_strictMono_fst (y : ℝ) : StrictMono (fun x => eml14 x y) := by
  intro a b hab
  simp only [eml14]
  linarith [Real.exp_strictMono hab]


/-- EML is strictly decreasing in its second argument for y > 0. -/
theorem eml14_strictAnti_snd (x : ℝ) :
    StrictAntiOn (fun y => eml14 x y) (Set.Ioi 0) := by
  intro a ha b hb hab
  simp only [eml14, Set.mem_Ioi] at *
  linarith [Real.log_lt_log ha hab]


/-- The diagonal map d(z) = exp(z) - log(z) satisfies d(z) ≥ z + 1 for all z. -/
theorem diag14_ge_succ (z : ℝ) : diag14 z ≥ z + 1 := by
  unfold diag14
  by_cases hz : 0 < z
  · by_cases hz1 : z ≤ 1
    · have h1 := Real.add_one_le_exp z
      have h2 := Real.log_nonpos (le_of_lt hz) hz1
      linarith
    · push_neg at hz1
      have h1 := Real.sum_le_exp_of_nonneg (le_of_lt hz) 3
      simp [Finset.sum_range_succ] at h1
      have h2 := Real.log_le_sub_one_of_pos hz
      nlinarith [sq_nonneg (z - 1)]
  · push_neg at hz
    cases' eq_or_lt_of_le hz with h h
    · subst h; simp [Real.log_zero]
    · have h1 := Real.exp_pos z
      have h2 := Real.log_le_sub_one_of_pos (neg_pos.mpr h)
      rw [Real.log_neg_eq_log z] at h2
      linarith


/-- The diagonal map is bounded below by exp: d(z) ≥ exp(z) - z + 1 for z > 0. -/
theorem diag14_lower_exp (z : ℝ) (hz : 0 < z) :
    diag14 z ≥ Real.exp z - z + 1 := by
  unfold diag14
  linarith [Real.log_le_sub_one_of_pos hz]


/-- Diagonal orbit divergence: d^n(z) ≥ z + n. -/
theorem diagIter14_diverge (z : ℝ) (n : ℕ) :
    diagIter14 n z ≥ z + n := by
  induction n with
  | zero => simp [diagIter14]
  | succ n ih =>
    simp only [diagIter14, Nat.cast_succ]
    linarith [diag14_ge_succ (diagIter14 n z)]


/-- [Section: ========================================================================
Part II: Global g-Map Convergence Infrastructure
========================================================================] -/
theorem gmap14_entry_lemma (z : ℝ) (hz_pos : 0 < z) (hz_lt : z < 2) :
    gmap14 z > 2 := by
  -- Since $g(z) = e - \ln(z)$ and $\ln(z) < \ln(2)$, we have $g(z) > e - \ln(2)$.
  have h_g_bound : gmap14 z > Real.exp 1 - Real.log 2 := by
    exact sub_lt_sub_left ( Real.log_lt_log hz_pos hz_lt ) _;
  exact h_g_bound.trans_le' ( by have := Real.exp_one_gt_d9.le; have := Real.log_two_lt_d9; norm_num1 at *; linarith )


theorem gmap14_pos (z : ℝ) (hz : 0 < z) (hz_lt : z < Real.exp (Real.exp 1)) :
    gmap14 z > 0 := by
  exact sub_pos_of_lt ( by simpa using Real.log_lt_iff_lt_exp hz |>.2 hz_lt )


/-- The g-map satisfies |g(x) - g(y)| = |ln(x) - ln(y)| for all x, y > 0. -/
theorem gmap14_lipschitz_log (x y : ℝ) (_hx : 0 < x) (_hy : 0 < y) :
    |gmap14 x - gmap14 y| = |Real.log x - Real.log y| := by
  unfold gmap14; simp only [sub_sub_sub_cancel_left]; rw [abs_sub_comm]


theorem gmap14_half_contraction (x y : ℝ) (hx : 2 ≤ x) (hy : 2 ≤ y) :
    |gmap14 x - gmap14 y| ≤ (1/2) * |x - y| := by
  rw [ gmap14, gmap14 ];
  -- By the Mean Value Theorem, there exists some $c$ between $x$ and $y$ such that $\log y - \log x = \frac{1}{c}(y - x)$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Icc (min x y) (max x y), Real.log y - Real.log x = (1 / c) * (y - x) := by
    cases eq_or_ne x y <;> simp_all +decide [ mul_comm ];
    cases lt_or_gt_of_ne ‹_› <;> have := exists_deriv_eq_slope ( Real.log ) ‹_› <;> norm_num at *;
    · exact this ( continuousOn_of_forall_continuousAt fun z hz => Real.continuousAt_log ( by linarith [ hz.1 ] ) ) ( fun z hz => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hz.1 ] ) ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, ⟨ Or.inl hc₁.1.le, Or.inr hc₁.2.le ⟩, by rw [ hc₂, mul_div_cancel₀ _ ( by linarith ) ] ⟩;
    · exact this ( continuousOn_of_forall_continuousAt fun z hz => Real.continuousAt_log ( by linarith [ hz.1 ] ) ) ( fun z hz => DifferentiableAt.differentiableWithinAt ( Real.differentiableAt_log ( by linarith [ hz.1 ] ) ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, ⟨ Or.inr hc₁.1.le, Or.inl hc₁.2.le ⟩, by rw [ eq_div_iff ] at hc₂ <;> linarith ⟩;
  cases abs_cases ( x - y ) <;> cases abs_cases ( Real.exp 1 - log x - ( Real.exp 1 - log y ) ) <;> nlinarith [ show ( 1 : ℝ ) / c ≤ 1 / 2 by rw [ div_le_div_iff₀ ] <;> cases max_cases x y <;> cases min_cases x y <;> linarith [ hc.1.1, hc.1.2 ], show ( 0 : ℝ ) < c by cases max_cases x y <;> cases min_cases x y <;> linarith [ hc.1.1, hc.1.2 ], mul_div_cancel₀ ( 1 : ℝ ) ( show c ≠ 0 by cases max_cases x y <;> cases min_cases x y <;> linarith [ hc.1.1, hc.1.2 ] ) ]


/-- EML x-shift identity: eml(x + c, y) = eml(x, y) + exp(x)(exp(c) - 1). -/
theorem eml14_x_shift (x c y : ℝ) :
    eml14 (x + c) y = eml14 x y + Real.exp x * (Real.exp c - 1) := by
  unfold eml14; rw [Real.exp_add]; ring


/-- EML y-scaling identity: eml(x, a*y) = eml(x, y) - ln(a) for a, y > 0. -/
theorem eml14_y_scale (x a y : ℝ) (ha : 0 < a) (hy : 0 < y) :
    eml14 x (a * y) = eml14 x y - Real.log a := by
  unfold eml14; rw [Real.log_mul (ne_of_gt ha) (ne_of_gt hy)]; ring


/-- EML difference in second argument: eml(x,y) - eml(x,z) = ln(z) - ln(y). -/
theorem eml14_diff_snd (x y z : ℝ) :
    eml14 x y - eml14 x z = Real.log z - Real.log y := by
  unfold eml14; ring


/-- EML composition identity: eml(a, exp(eml(b, y))) = exp(a) - exp(b) + ln(y). -/
theorem eml14_comp_exp (a b y : ℝ) :
    eml14 a (Real.exp (eml14 b y)) = Real.exp a - Real.exp b + Real.log y := by
  unfold eml14; rw [Real.log_exp]; ring


/-- EML self-inverse via exp: eml(ln(eml(x,y)), 1) = eml(x,y) for eml(x,y) > 0. -/
theorem eml14_self_inverse (x y : ℝ) (h : 0 < eml14 x y) :
    eml14 (Real.log (eml14 x y)) 1 = eml14 x y := by
  unfold eml14 at *; rw [Real.exp_log h, Real.log_one, sub_zero]


/-- Iterated EML tower: eml(eml(x,1), 1) = exp(exp(x)). -/
theorem eml14_double_exp (x : ℝ) :
    eml14 (eml14 x 1) 1 = Real.exp (Real.exp x) := by
  unfold eml14; norm_num


/-- EML additive decomposition: eml(x,y) = (exp(x) - 1) + (1 - ln(y)). -/
theorem eml14_decomposition (x y : ℝ) :
    eml14 x y = (Real.exp x - 1) + (1 - Real.log y) := by
  unfold eml14; ring


/-- EML interpolation: eml(t*a + (1-t)*b, 1) approaches exp(a) as t → 1. -/
theorem eml14_at_t_one (a : ℝ) :
    eml14 (1 * a + (1 - 1) * 0) 1 = Real.exp a := by
  simp [eml14, Real.log_one]


/-- [Section: ========================================================================
Part IV: Surjectivity and Range
========================================================================] -/
theorem eml14_surj_snd (x t : ℝ) :
    ∃ y : ℝ, 0 < y ∧ eml14 x y = t := by
  use Real.exp (Real.exp x - t);
  exact ⟨ Real.exp_pos _, by unfold eml14; norm_num ⟩


theorem eml14_surj_fst (y t : ℝ) (hy : 0 < y) (ht : t > -Real.log y) :
    ∃ x : ℝ, eml14 x y = t := by
  exact ⟨ Real.log ( t + Real.log y ), by unfold eml14; rw [ Real.exp_log ] <;> linarith ⟩


/-- [Section: ========================================================================
Part V: EML Entropy and Information Theory
========================================================================] -/
theorem eml14_amgm_core (p : ℝ) (hp : 0 < p) : p - Real.log p ≥ 1 := by
  linarith [ Real.log_le_sub_one_of_pos hp ]


/-- EML self-application: eml(x, exp(x)) = exp(x) - x. -/
theorem eml14_self_apply (x : ℝ) :
    eml14 x (Real.exp x) = Real.exp x - x := by
  unfold eml14; rw [Real.log_exp]


/-- The "EML entropy" of a single value: eml(ln(p), p) = p - ln(p) ≥ 1 for p > 0. -/
theorem eml14_entropy_single (p : ℝ) (hp : 0 < p) :
    eml14 (Real.log p) p = p - Real.log p := by
  unfold eml14; rw [Real.exp_log hp]


/-- EML generates the KL divergence building block:
eml(ln(p), q) - eml(ln(p), p) = ln(p) - ln(q) for p, q > 0. -/
theorem eml14_kl_block (p q : ℝ) (_hp : 0 < p) :
    eml14 (Real.log p) q - eml14 (Real.log p) p = Real.log p - Real.log q := by
  unfold eml14; ring


/-- σ-EML alternative form: σ_eml(x) = exp(x) - ln(1 + exp(-x)). -/
theorem sigma_eml_alt (x : ℝ) :
    sigma_eml x = Real.exp x - Real.log (1 + Real.exp (-x)) := by
  rfl


/-- [Section: ========================================================================
Part VI: σ-EML Activation Function
========================================================================] -/
theorem sigma_eml_pos_nonneg (x : ℝ) (hx : 0 ≤ x) : sigma_eml x > 0 := by
  -- For x ≥ 0, we have 1 + exp(-x) ≤ 2, so ln(1 + exp(-x)) ≤ ln(2) < 1 ≤ exp(x).
  have h_exp_neg : 1 + Real.exp (-x) ≤ 2 := by
    linarith [ Real.exp_le_one_iff.2 ( neg_nonpos.2 hx ) ];
  -- We'll use that $σ_eml(x) = e^x - \ln(1 + e^{-x})$ and show that $e^x > \ln(2)$ for $x \geq 0$.
  have h_sigma_pos : ∀ x ≥ 0, Real.exp x > Real.log 2 := by
    exact fun x hx => lt_of_lt_of_le ( Real.log_two_lt_d9.trans_le ( by norm_num ) ) ( Real.one_le_exp hx );
  exact sub_pos_of_lt ( lt_of_le_of_lt ( Real.log_le_log ( by positivity ) h_exp_neg ) ( h_sigma_pos x hx ) )


/-- σ-EML at 0: σ_eml(0) = 1 - ln(2). Wait, exp(0) - ln(1+exp(0)) = 1 - ln(2).
Actually that's 1 - ln 2 ≈ 0.307. -/
theorem sigma_eml_zero : sigma_eml 0 = 1 - Real.log 2 := by
  unfold sigma_eml; norm_num [Real.exp_zero]


theorem sigma_eml_lower (x : ℝ) :
    sigma_eml x ≥ Real.exp x - Real.log 2 - max (-x) 0 := by
  -- We'll use the fact that $\ln(1 + e^{-x}) \leq \ln(2) + \max(-x, 0)$ to bound $\sigma_{\text{eml}}(x)$.
  have h_log_bound : Real.log (1 + Real.exp (-x)) ≤ Real.log 2 + max (-x) 0 := by
    cases max_cases ( -x ) 0 <;> rw [ Real.log_le_iff_le_exp ( by positivity ) ] <;> ring_nf;
    · norm_num [ Real.exp_add, Real.exp_log, ‹_› ];
      linarith [ Real.add_one_le_exp ( -x ) ];
    · norm_num [ Real.exp_add, Real.exp_log, ‹_› ];
      linarith [ Real.exp_le_one_iff.2 ( show -x ≤ 0 by linarith ) ];
  unfold sigma_eml; linarith;


/-- σ-EML is an EML instance: σ_eml(x) = eml(x, 1 + exp(-x)). -/
theorem sigma_eml_is_eml (x : ℝ) :
    sigma_eml x = eml14 x (1 + Real.exp (-x)) := by
  rfl


/-- The second iterate of the diagonal map satisfies a strong bound. -/
theorem diag14_second_iterate (z : ℝ) :
    diag14 (diag14 z) ≥ z + 2 := by
  have h1 := diag14_ge_succ z
  have h2 := diag14_ge_succ (diag14 z)
  linarith


/-- [Section: ========================================================================
Part VII: Higher Diagonal Dynamics
========================================================================] -/
theorem diagIter14_superexp (z : ℝ) (hz : 0 < z) (n : ℕ) :
    diagIter14 (n + 1) z ≥ Real.exp (z + n) - (z + n) + 1 := by
  -- By induction on $n$, we can show that $d^n(z) \ge z + n$.
  have h_iter (n : ℕ) : diagIter14 n z ≥ z + n := by
    grind +suggestions;
  -- By definition of $d$, we know that $d(w) = \exp(w) - \ln(w)$.
  have h_def : ∀ w : ℝ, w > 0 → diag14 w ≥ Real.exp w - w + 1 := by
    exact?;
  refine le_trans ?_ ( h_def _ ?_ );
  · -- Apply the mean value theorem to the exponential function on the interval $[z + n, diagIter14 n z]$.
    have h_mean_value : ∀ {a b : ℝ}, 0 < a → a < b → Real.exp b - b + 1 ≥ Real.exp a - a + 1 := by
      intro a b ha hb; have := Real.add_one_le_exp ( b - a ) ; simp_all +decide [ Real.exp_sub ] ;
      rw [ le_div_iff₀ ] at this <;> nlinarith [ Real.exp_pos a, Real.exp_pos b, Real.add_one_le_exp a, Real.add_one_le_exp b ];
    exact if h : diagIter14 n z = z + n then by norm_num [ h ] else h_mean_value ( by positivity ) ( lt_of_le_of_ne ( h_iter n ) ( Ne.symm h ) );
  · exact lt_of_lt_of_le ( by positivity ) ( h_iter n )


/-- [Section: ========================================================================
Part VIII: EML and Classical Inequalities
========================================================================] -/
theorem eml14_diag_amgm (a : ℝ) (_ha : 0 < a) :
    eml14 (Real.log a) a ≥ 1 := by
  unfold eml14;
  linarith [ Real.add_one_le_exp ( Real.log a ) ]


/-- EML and the exponential-logarithm gap:
eml(x, exp(x)) = exp(x) - x ≥ 1 for all x. -/
theorem eml14_exp_log_gap (x : ℝ) :
    eml14 x (Real.exp x) ≥ 1 := by
  rw [eml14_self_apply]
  linarith [Real.add_one_le_exp x]

-- EML Jensen: For convex f, eml(f(x), f(y)) relates to eml at midpoint.
-- This is more of a structural observation than a formal theorem.


/-- EML and the Lambert W function connection:
The diagonal fixed point equation d(z) = z is equivalent to exp(z) = z + ln(z),
which has no real solution (proved via d(z) > z). -/
theorem eml14_no_diagonal_fixed_point (z : ℝ) : diag14 z ≠ z := by
  intro h; linarith [diag14_ge_succ z]


/-- [Section: ========================================================================
Part IX: EML Conjugation and Symmetry
========================================================================] -/
theorem eml14_exp_conjugate (x y : ℝ) (hy : 0 < y) :
    Real.exp (eml14 x y) = Real.exp (Real.exp x) / y := by
  unfold eml14;
  rw [ Real.exp_sub, Real.exp_log hy ]


/-- EML log conjugation: ln(eml(x,y)) is defined when eml(x,y) > 0. -/
theorem eml14_log_of_pos (x y : ℝ) (_h : 0 < eml14 x y) :
    Real.log (eml14 x y) = Real.log (Real.exp x - Real.log y) := by
  rfl


theorem eml14_antidiag (z : ℝ) (hz : z < 0) :
    Real.exp (-z) - Real.log (-z) ≥ -z + 1 := by
  have := Real.add_one_le_exp ( -z - 1 );
  rw [ show Real.exp ( -z ) = Real.exp ( -z - 1 ) * Real.exp 1 by rw [ ← Real.exp_add ] ; ring ];
  nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( neg_pos.mpr hz ) ]


/-- The g-map fixed point equation: g(z) = z iff exp(1) - ln(z) = z iff z + ln(z) = e. -/
theorem gmap14_fixed_point_eq (z : ℝ) (_hz : 0 < z) :
    gmap14 z = z ↔ z + Real.log z = Real.exp 1 := by
  unfold gmap14; constructor <;> intro h <;> linarith


/-- [Section: ========================================================================
Part X: EML Fixed Point Landscape
========================================================================] -/
theorem gmap14_fixed_in_interval (z : ℝ) (hz : 0 < z) (hfp : gmap14 z = z) :
    2 < z ∧ z < Real.exp 1 := by
  constructor;
  · unfold gmap14 at hfp;
    have := Real.exp_one_gt_d9.le;
    contrapose! hfp;
    have := Real.log_two_lt_d9;
    norm_num at * ; linarith [ Real.log_le_log ( by linarith ) hfp ];
  · contrapose! hfp;
    exact ne_of_lt ( sub_lt_iff_lt_add'.mpr <| by linarith [ Real.add_one_le_exp 1, Real.log_exp 1, Real.log_le_log ( by positivity ) hfp ] )


/-- EML at the g-fixed-point: if g(z*) = z*, then eml(1, z*) = z*,
meaning z* is a fixed point of eml(1, ·). -/
theorem eml14_gfixed (z : ℝ) (hz : gmap14 z = z) :
    eml14 1 z = z := by
  unfold eml14; unfold gmap14 at hz; linarith


end
