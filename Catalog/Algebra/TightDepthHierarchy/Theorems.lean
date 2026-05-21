/-
# EML Tight Depth Hierarchy — Core Theorems

This file proves the tight depth hierarchy theorem for inverse-free EML expressions:
no inverse-free EMLExpr of depth D can represent `iterExp n` for any `n > D`.
-/
import Speculative.TightDepthHierarchy.Defs

noncomputable section

open Real Filter Finset

/-! ## Basic Properties of iterExp -/

theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact Real.exp_strictMono.comp ih

theorem iterExp_mono (n : ℕ) : Monotone (iterExp n) :=
  (iterExp_strictMono n).monotone

theorem iterExp_pos_of_pos (n : ℕ) {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  induction n with
  | zero => exact hx
  | succ n _ => exact Real.exp_pos _

theorem iterExp_pos_of_succ (n : ℕ) (x : ℝ) : 0 < iterExp (n + 1) x :=
  Real.exp_pos _

theorem iterExp_strict_level_increase {x : ℝ} (hx : 0 < x) (n : ℕ) :
    iterExp n x < iterExp (n + 1) x := by
  simp [iterExp_succ]; linarith [Real.add_one_le_exp (iterExp n x)]

theorem iterExp_level_mono {n m : ℕ} (hnm : n ≤ m) {x : ℝ} (hx : 0 < x) :
    iterExp n x ≤ iterExp m x := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hnm
  induction k with
  | zero => simp
  | succ k ih =>
    have h1 := ih (by omega)
    have h2 := iterExp_strict_level_increase hx (n + k)
    have h3 : n + k + 1 = n + (k + 1) := by omega
    linarith [h3 ▸ h2]

theorem iterExp_compose (k m : ℕ) (x : ℝ) :
    iterExp k (iterExp m x) = iterExp (k + m) x := by
  induction k with
  | zero => simp [iterExp]
  | succ k ih => simp [iterExp_succ, ih, Nat.succ_add]

theorem iterExp_ge_self (n : ℕ) {x : ℝ} (hx : 0 ≤ x) : x ≤ iterExp n x := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc x ≤ iterExp n x := ih
    _ ≤ Real.exp (iterExp n x) := by linarith [Real.add_one_le_exp (iterExp n x)]

theorem iterExp_nonneg_of_ge_one {n : ℕ} (hn : 1 ≤ n) (x : ℝ) : 0 ≤ iterExp n x := by
  cases n with
  | zero => omega
  | succ n => exact le_of_lt (Real.exp_pos _)

/-! ## Polynomials are dominated by exp -/

theorem poly_lt_exp (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → C * x ^ N < Real.exp x := by
  -- By the properties of the exponential function and polynomials, we know that $\frac{e^x}{x^N}$ tends to infinity as $x$ tends to infinity.
  have h_exp_div_poly_inf : Filter.Tendsto (fun x : ℝ => Real.exp x / x ^ N) Filter.atTop Filter.atTop := by
    exact Real.tendsto_exp_div_pow_atTop N;
  exact Filter.eventually_atTop.mp ( h_exp_div_poly_inf.eventually_gt_atTop ( Max.max ( C + 1 ) 1 ) ) |> fun ⟨ X₀, hX₀ ⟩ ↦ ⟨ Max.max X₀ 1, fun x hx ↦ by have := hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ lt_div_iff₀ ( pow_pos ( by linarith [ le_max_right X₀ 1 ] ) _ ) ] at this; nlinarith [ le_max_left ( C + 1 ) 1, le_max_right ( C + 1 ) 1, pow_pos ( by linarith [ le_max_right X₀ 1 ] : 0 < x ) N ] ⟩

theorem iterExp_poly_lt_iterExp_succ (k : ℕ) (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → iterExp k (C * x ^ N) < iterExp (k + 1) x := by
  induction' k with k ih generalizing C N;
  · simpa using poly_lt_exp C N;
  · obtain ⟨ X₀, hX₀ ⟩ := ih C N;
    exact ⟨ Max.max X₀ 1, fun x hx => by simpa using Real.exp_lt_exp.mpr ( hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ) ⟩

/-! ## Absorption Lemmas -/

theorem iterExp_succ_arg_increment (D : ℕ) (hD : 1 ≤ D) (t : ℝ) (ht : 0 ≤ t) :
    iterExp D t + 1 ≤ iterExp D (t + 1) := by
  induction' hD with D hD ih generalizing t <;> simp_all +decide [ iterExp ];
  · rw [ Real.exp_add ] ; nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp t ] ;
  · -- Apply the exponential function to both sides of the induction hypothesis.
    have h_exp : Real.exp (iterExp D t + 1) ≤ Real.exp (iterExp D (t + 1)) := by
      exact Real.exp_le_exp.mpr ( ih t ht );
    refine le_trans ?_ h_exp;
    rw [ Real.exp_add ];
    nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( iterExp D t ), show 1 ≤ iterExp D t from Nat.le_induction ( by norm_num [ iterExp ] ; positivity ) ( fun k hk ih => by rw [ iterExp ] ; exact Real.one_le_exp ( by linarith ) ) D hD ]

theorem iterExp_double_absorption (D : ℕ) (hD : 1 ≤ D) (t : ℝ) (ht : 0 ≤ t) :
    2 * iterExp D t ≤ iterExp D (t + 1) := by
  induction' hD with D hD ih generalizing t <;> simp_all +decide [ iterExp ];
  · rw [ Real.exp_add ] ; nlinarith [ Real.add_one_le_exp 1, Real.exp_pos t ];
  · -- By the induction hypothesis, we know that $2 * \text{iterExp } D t \leq \text{iterExp } D (t + 1)$.
    have h_ind : 2 * iterExp D t ≤ iterExp D (t + 1) := by
      exact ih t ht;
    rw [ ← Real.log_le_log_iff ( by positivity ) ( by positivity ), Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp, Real.log_exp ];
    linarith [ Real.log_le_sub_one_of_pos zero_lt_two, show iterExp D t ≥ 1 from Nat.le_induction ( by norm_num [ iterExp ] ; linarith [ Real.add_one_le_exp t ] ) ( fun k hk ih => by rw [ iterExp ] ; exact Real.one_le_exp ( by linarith ) ) D hD ]

theorem iterExp_sum_poly_bound (D : ℕ) (hD : 1 ≤ D) (C₁ C₂ : ℝ) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂)
    (N₁ N₂ : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C₁ * x ^ N₁) + iterExp D (C₂ * x ^ N₂) ≤ iterExp D (C * x ^ N) := by
  refine' ⟨ 1 + Max.max C₁ C₂, _, Max.max N₁ N₂, 1, fun x hx ↦ _ ⟩ <;> norm_num at *;
  · positivity;
  · -- By monotonicity of iterExp D, we have:
    have h_mono : iterExp D (C₁ * x ^ N₁) ≤ iterExp D (max C₁ C₂ * x ^ max N₁ N₂) ∧ iterExp D (C₂ * x ^ N₂) ≤ iterExp D (max C₁ C₂ * x ^ max N₁ N₂) := by
      constructor <;> refine' iterExp_mono _ _;
      · exact mul_le_mul ( le_max_left _ _ ) ( pow_le_pow_right₀ hx ( le_max_left _ _ ) ) ( by positivity ) ( by positivity );
      · exact mul_le_mul ( le_max_right _ _ ) ( pow_le_pow_right₀ hx ( le_max_right _ _ ) ) ( by positivity ) ( by positivity );
    -- By the absorption lemma, we have:
    have h_absorb : 2 * iterExp D (max C₁ C₂ * x ^ max N₁ N₂) ≤ iterExp D (max C₁ C₂ * x ^ max N₁ N₂ + 1) := by
      apply_rules [ iterExp_double_absorption ];
      positivity;
    refine' le_trans ( add_le_add h_mono.1 h_mono.2 ) _;
    convert h_absorb.trans ( iterExp_mono _ <| show max C₁ C₂ * x ^ max N₁ N₂ + 1 ≤ ( 1 + max C₁ C₂ ) * x ^ max N₁ N₂ from _ ) using 1 <;> ring;
    nlinarith [ show 1 ≤ x ^ max N₁ N₂ by exact one_le_pow₀ hx, le_max_left C₁ C₂, le_max_right C₁ C₂ ]

theorem iterExp_prod_to_next_level (D : ℕ) (C₁ C₂ : ℝ) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂)
    (N₁ N₂ : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C₁ * x ^ N₁) * Real.exp (iterExp D (C₂ * x ^ N₂))
        ≤ iterExp (D + 1) (C * x ^ N) := by
  by_cases hD : 1 ≤ D;
  · obtain ⟨ C, hC₀, N, X₀, hX₀ ⟩ := iterExp_sum_poly_bound D hD C₁ C₂ hC₁ hC₂ N₁ N₂;
    refine' ⟨ C, hC₀, N, Max.max X₀ 1, fun x hx => _ ⟩ ; specialize hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ; simp_all +decide [ iterExp_succ ];
    refine' le_trans _ ( Real.exp_le_exp.mpr hX₀ );
    rw [ Real.exp_add ] ; gcongr;
    exact le_trans ( by norm_num ) ( Real.add_one_le_exp _ );
  · use C₁ + C₂, by linarith, max N₁ N₂ + 1, 1;
    interval_cases D ; norm_num [ iterExp ];
    intro x hx
    have h_exp : C₁ * x ^ N₁ * Real.exp (C₂ * x ^ N₂) ≤ Real.exp (C₁ * x ^ N₁ + C₂ * x ^ N₂) := by
      rw [ Real.exp_add ];
      exact mul_le_mul_of_nonneg_right ( by linarith [ Real.add_one_le_exp ( C₁ * x ^ N₁ ) ] ) ( Real.exp_nonneg _ );
    refine le_trans h_exp <| Real.exp_le_exp.mpr ?_;
    rw [ add_mul ];
    exact add_le_add ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( by linarith [ Nat.le_max_left N₁ N₂ ] ) ) hC₁.le ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( by linarith [ Nat.le_max_right N₁ N₂ ] ) ) hC₂.le )

theorem iterExp_mul_poly_bound (D : ℕ) (hD : 1 ≤ D) (C₁ C₂ : ℝ) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂)
    (N₁ N₂ : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C₁ * x ^ N₁) * iterExp D (C₂ * x ^ N₂) ≤ iterExp D (C * x ^ N) := by
  rcases D with ( _ | D ) <;> simp_all +decide [ iterExp ];
  by_cases hD : D ≥ 1;
  · obtain ⟨ C, hC₀, N, X₀, h ⟩ := iterExp_sum_poly_bound D hD C₁ C₂ hC₁ hC₂ N₁ N₂;
    exact ⟨ C, hC₀, N, X₀, fun x hx => by rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( h x hx ) ⟩;
  · interval_cases D ; norm_num [ ← Real.exp_add ];
    exact ⟨ C₁ + C₂, by positivity, Max.max N₁ N₂, 1, fun x hx => by nlinarith [ pow_le_pow_right₀ hx ( le_max_left N₁ N₂ ), pow_le_pow_right₀ hx ( le_max_right N₁ N₂ ) ] ⟩

/-! ## Growth Rank -/

theorem growthRank_le_emlDepth (e : EMLExpr) : e.growthRank ≤ e.emlDepth := by
  induction e <;> simp_all +decide [ EMLExpr.growthRank, EMLExpr.emlDepth ];
  · grind +qlia;
  · grind +qlia;
  · grind +qlia

/-! ## Polynomial bound for eml-free expressions -/

theorem noInv_noEml_poly_bound (e : EMLExpr) (hInv : e.noInv) (hEml : e.noEml) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      |e.eval x| ≤ C * x ^ N := by
  by_contra! h_contra;
  obtain ⟨ x, hx₁, hx₂ ⟩ := h_contra 1 zero_lt_one 0 ( |e.eval 0| + 1 );
  -- Since $e$ is a polynomial, we can write it as $e(x) = p(x)$ for some polynomial $p$.
  obtain ⟨ p, hp ⟩ : ∃ p : Polynomial ℝ, ∀ x : ℝ, e.eval x = p.eval x := by
    have h_poly : ∀ e : EMLExpr, e.noInv → e.noEml → ∃ p : Polynomial ℝ, ∀ x : ℝ, e.eval x = p.eval x := by
      intro e hInv hEml;
      induction' e with e ih;
      all_goals norm_num [ EMLExpr.eval, EMLExpr.noInv, EMLExpr.noEml ] at *;
      · exact ⟨ Polynomial.X, fun x => by norm_num ⟩;
      · exact ⟨ Polynomial.C e, fun x => by simp +decide ⟩;
      · rename_i k hk₁ hk₂;
        obtain ⟨ p, hp ⟩ := hk₁ hInv.1 hEml.1; obtain ⟨ q, hq ⟩ := hk₂ hInv.2 hEml.2; exact ⟨ p + q, fun x => by simp +decide [ hp, hq ] ⟩ ;
      · rename_i a b ha hb;
        obtain ⟨ p, hp ⟩ := ha hInv.1 hEml.1; obtain ⟨ q, hq ⟩ := hb hInv.2 hEml.2; exact ⟨ p * q, fun x => by simp +decide [ hp, hq ] ⟩ ;
      · rename_i k hk;
        obtain ⟨ p, hp ⟩ := hk hInv hEml; exact ⟨ -p, fun x => by simp +decide [ hp ] ⟩ ;
    exact h_poly e hInv hEml;
  -- Since $p$ is a polynomial, there exists a constant $C$ and a natural number $N$ such that $|p(x)| \leq C * x^N$ for all $x \geq 1$.
  obtain ⟨ C, hC ⟩ : ∃ C : ℝ, ∀ x : ℝ, 1 ≤ x → |p.eval x| ≤ C * x ^ p.natDegree := by
    use ∑ i ∈ Finset.range (p.natDegree + 1), |p.coeff i|;
    intro x hx; rw [ Polynomial.eval_eq_sum_range ] ; rw [ Finset.sum_mul _ _ _ ] ; exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => by rw [ abs_mul, abs_of_nonneg ( by positivity : 0 ≤ x ^ i ) ] ; exact mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ hx ( Finset.mem_range_succ_iff.mp hi ) ) ( abs_nonneg _ ) ) ;
  obtain ⟨ x, hx₁, hx₂ ⟩ := h_contra ( Max.max C 1 ) ( by positivity ) p.natDegree 1 ; specialize hC x ( by linarith ) ; simp_all +decide [ abs_mul ];
  nlinarith [ le_max_left C 1, le_max_right C 1, pow_pos ( zero_lt_one.trans_le hx₁ ) p.natDegree ]

/-! ## Main Structural Theorem -/

/-! ### Per-case lemmas for structural induction -/

private theorem hasPTM_add {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.emlDepth a) (hb : HasPolyTowerMajorant b.emlDepth b) :
    HasPolyTowerMajorant (a.add b).emlDepth (a.add b) := by
  by_cases hD : a.emlDepth = 0 ∧ b.emlDepth = 0;
  · obtain ⟨ Ca, hCa, Na, Xa, ha ⟩ := ha
    obtain ⟨ Cb, hCb, Nb, Xb, hb ⟩ := hb
    use Ca + Cb, by linarith, max Na Nb, max Xa (max Xb 1);
    intro x hx; have := ha x ( le_trans ( le_max_left _ _ ) hx ) ; have := hb x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ; simp_all +decide [ abs_le ] ;
    -- By definition of `iterExp`, we know that `iterExp 0 (y) = y`.
    have h_iterExp_zero : iterExp 0 ((Ca + Cb) * x ^ max Na Nb) = (Ca + Cb) * x ^ max Na Nb := by
      rfl;
    rw [ show ( a.add b ).emlDepth = 0 by
          exact max_eq_left ( by linarith ) |> fun h => h.trans ( by linarith ) ] ; simp_all +decide [ EMLExpr.eval ] ; constructor <;> nlinarith [ ha x hx.1, hb x hx.2.1, pow_le_pow_right₀ hx.2.2 ( show Na ≤ max Na Nb by exact le_max_left _ _ ), pow_le_pow_right₀ hx.2.2 ( show Nb ≤ max Na Nb by exact le_max_right _ _ ) ] ;
  · -- By definition of `HasPolyTowerMajorant`, there exist constants `Ca`, `Na`, `Xa` and `Cb`, `Nb`, `Xb` such that for all `x ≥ Xa` and `x ≥ Xb`, the evaluations of `a` and `b` are bounded by the respective iterExp terms.
    obtain ⟨Ca, hCa_pos, Na, Xa, ha_bound⟩ := ha
    obtain ⟨Cb, hCb_pos, Nb, Xb, hb_bound⟩ := hb;
    -- Let $D = \max(a.emlDepth, b.emlDepth)$.
    set D := max a.emlDepth b.emlDepth with hD_def
    have hD_ge : D ≥ 1 := by
      grind;
    -- By iterExp_level_mono, both terms ≤ iterExp D (Ca * x^Na) and iterExp D (Cb * x^Nb) for x > 0.
    have h_bound : ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → |a.eval x| ≤ iterExp D (Ca * x ^ Na) ∧ |b.eval x| ≤ iterExp D (Cb * x ^ Nb) := by
      use max Xa (max Xb 1);
      simp +zetaDelta at *;
      exact fun x hx₁ hx₂ hx₃ => ⟨ le_trans ( ha_bound x hx₁ ) ( iterExp_level_mono ( le_max_left _ _ ) ( by positivity ) ), le_trans ( hb_bound x hx₂ ) ( iterExp_level_mono ( le_max_right _ _ ) ( by positivity ) ) ⟩;
    -- By iterExp_sum_poly_bound, there exist constants $C$, $N$, and $X₀$ such that for all $x ≥ X₀$, $iterExp D (Ca * x^Na) + iterExp D (Cb * x^Nb) ≤ iterExp D (C * x^N)$.
    obtain ⟨C, hC_pos, N, X₀, h_sum_bound⟩ := iterExp_sum_poly_bound D hD_ge Ca Cb hCa_pos hCb_pos Na Nb;
    use C, hC_pos, N, Max.max X₀ ( Max.max h_bound.choose 1 );
    intro x hx; specialize h_bound; have := h_bound.choose_spec x ( by linarith [ le_max_left X₀ ( Max.max h_bound.choose 1 ), le_max_right X₀ ( Max.max h_bound.choose 1 ), le_max_left h_bound.choose 1, le_max_right h_bound.choose 1 ] ) ; simp_all +decide [ abs_le ] ;
    constructor <;> linarith! [ h_sum_bound x hx.1, show ( a.add b ).eval x = a.eval x + b.eval x from rfl, show ( a.add b ).emlDepth = D from rfl ]

private theorem hasPTM_mul {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.emlDepth a) (hb : HasPolyTowerMajorant b.emlDepth b) :
    HasPolyTowerMajorant (a.mul b).emlDepth (a.mul b) := by
  by_cases hD : max a.emlDepth b.emlDepth = 0;
  · obtain ⟨ Ca, hCa, Na, Xa, ha ⟩ := ha
    obtain ⟨ Cb, hCb, Nb, Xb, hb ⟩ := hb
    use Ca * Cb, mul_pos hCa hCb, Na + Nb, max Xa Xb
    intro x hx
    have : |(a.mul b).eval x| ≤ Ca * Cb * x ^ (Na + Nb) := by
      have : |(a.mul b).eval x| = |a.eval x| * |b.eval x| := by
        exact abs_mul _ _
      rw [this]
      have : |a.eval x| ≤ Ca * x ^ Na := by
        rw [ show a.emlDepth = 0 by aesop ] at ha; aesop;
      have : |b.eval x| ≤ Cb * x ^ Nb := by
        convert hb x ( le_trans ( le_max_right _ _ ) hx ) using 1 ; aesop ( simp_config := { singlePass := true } ) ;
      have : |a.eval x| * |b.eval x| ≤ (Ca * x ^ Na) * (Cb * x ^ Nb) := by
        gcongr;
        exact le_trans ( abs_nonneg _ ) ‹|a.eval x| ≤ Ca * x ^ Na›
      rw [pow_add] at *; ring_nf at *; aesop;
    exact this.trans (by
    unfold EMLExpr.emlDepth; aesop;);
  · -- By level monotonicity, we have |a.eval x| ≤ iterExp D (Ca * x^Na) and |b.eval x| ≤ iterExp D (Cb * x^Nb).
    obtain ⟨Ca, hCa_pos, Na, Xa, hCa⟩ := ha
    obtain ⟨Cb, hCb_pos, Nb, Xb, hCb⟩ := hb
    have hCa_le : ∀ x ≥ max Xa 1, |a.eval x| ≤ iterExp (max a.emlDepth b.emlDepth) (Ca * x ^ Na) := by
      intros x hx
      have hCa_le : |a.eval x| ≤ iterExp a.emlDepth (Ca * x ^ Na) := by
        exact hCa x ( le_trans ( le_max_left _ _ ) hx );
      refine' le_trans hCa_le ( iterExp_level_mono _ _ );
      · exact le_max_left _ _;
      · exact mul_pos hCa_pos ( pow_pos ( by linarith [ le_max_right Xa 1 ] ) _ )
    have hCb_le : ∀ x ≥ max Xb 1, |b.eval x| ≤ iterExp (max a.emlDepth b.emlDepth) (Cb * x ^ Nb) := by
      intros x hx
      have hCb_le : |b.eval x| ≤ iterExp b.emlDepth (Cb * x ^ Nb) := by
        exact hCb x ( le_trans ( le_max_left _ _ ) hx );
      refine' le_trans hCb_le ( iterExp_level_mono _ _ );
      · exact le_max_right _ _;
      · exact mul_pos hCb_pos ( pow_pos ( by linarith [ le_max_right Xb 1 ] ) _ );
    -- By the polynomial bound for the product of two iterated exponentials, we have |a.eval x * b.eval x| ≤ iterExp D (C * x^N) for some C and N.
    obtain ⟨C, hC_pos, N, X₀, hC⟩ : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → iterExp (max a.emlDepth b.emlDepth) (Ca * x ^ Na) * iterExp (max a.emlDepth b.emlDepth) (Cb * x ^ Nb) ≤ iterExp (max a.emlDepth b.emlDepth) (C * x ^ N) := by
      apply_rules [ iterExp_mul_poly_bound ];
      exact Nat.pos_of_ne_zero hD;
    use C, hC_pos, N, Max.max ( Max.max X₀ ( Max.max Xa 1 ) ) ( Max.max Xb 1 );
    intro x hx; specialize hC x ( le_trans ( le_max_left _ _ ) ( le_trans ( le_max_left _ _ ) hx ) ) ; specialize hCa_le x ( le_trans ( le_max_right _ _ ) ( le_trans ( le_max_left _ _ ) hx ) ) ; specialize hCb_le x ( le_trans ( le_max_right _ _ ) hx ) ; simp_all +decide [ abs_mul, EMLExpr.eval ] ;
    convert le_trans ( mul_le_mul hCa_le hCb_le ( by positivity ) ( by exact le_trans ( by positivity ) hCa_le ) ) hC using 1

private theorem hasPTM_eml {a b : EMLExpr}
    (ha : HasPolyTowerMajorant a.emlDepth a) (hb : HasPolyTowerMajorant b.emlDepth b) :
    HasPolyTowerMajorant (a.eml b).emlDepth (a.eml b) := by
  -- By definition of `HasPolyTowerMajorant`, we need to show that there exists a constant `C` such that for sufficiently large `x`, `|a.eval x * exp(b.eval x)| ≤ C * x^N`.
  obtain ⟨Ca, hCa_pos, Na, Xa, hCa⟩ := ha
  obtain ⟨Cb, hCb_pos, Nb, Xb, hCb⟩ := hb;
  -- By definition of `HasPolyTowerMajorant`, we need to show that there exists a constant `C` such that for sufficiently large `x`, `|a.eval x * exp(b.eval x)| ≤ C * x^N`. We can use the bounds from `ha` and `hb`.
  have h_bound : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    |a.eval x| * Real.exp (|b.eval x|) ≤ iterExp (max a.emlDepth b.emlDepth + 1) (C * x ^ N) := by
      -- By definition of `HasPolyTowerMajorant`, we need to show that there exists a constant `C` such that for sufficiently large `x`, `|a.eval x| * exp(|b.eval x|) ≤ C * x^N`. We can use the bounds from `ha` and `hb` to construct such a constant.
      have h_bound : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
        iterExp a.emlDepth (Ca * x ^ Na) * Real.exp (iterExp b.emlDepth (Cb * x ^ Nb)) ≤ iterExp (max a.emlDepth b.emlDepth + 1) (C * x ^ N) := by
          have h_bound : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
            iterExp (max a.emlDepth b.emlDepth) (Ca * x ^ Na) * Real.exp (iterExp (max a.emlDepth b.emlDepth) (Cb * x ^ Nb)) ≤ iterExp (max a.emlDepth b.emlDepth + 1) (C * x ^ N) := by
              convert iterExp_prod_to_next_level ( max a.emlDepth b.emlDepth ) Ca Cb hCa_pos hCb_pos Na Nb using 1;
          refine' ⟨ h_bound.choose, h_bound.choose_spec.1, h_bound.choose_spec.2.choose, Max.max h_bound.choose_spec.2.choose_spec.choose 1, fun x hx => le_trans _ ( h_bound.choose_spec.2.choose_spec.choose_spec x ( le_trans ( le_max_left _ _ ) hx ) ) ⟩;
          gcongr;
          · exact le_of_lt ( iterExp_pos_of_pos _ ( mul_pos hCa_pos ( pow_pos ( by linarith [ le_max_right ( h_bound.choose_spec.2.choose_spec.choose ) 1 ] ) _ ) ) );
          · apply_rules [ iterExp_level_mono ];
            · exact le_max_left _ _;
            · exact mul_pos hCa_pos ( pow_pos ( by linarith [ le_max_right ( h_bound.choose_spec.2.choose_spec.choose ) 1 ] ) _ );
          · apply_rules [ iterExp_level_mono ];
            · exact le_max_right _ _;
            · exact mul_pos hCb_pos ( pow_pos ( by linarith [ le_max_right ( h_bound.choose_spec.2.choose_spec.choose ) 1 ] ) _ );
      obtain ⟨ C, hC_pos, N, X₀, hC ⟩ := h_bound;
      refine' ⟨ C, hC_pos, N, Max.max X₀ ( Max.max Xa Xb ), fun x hx => le_trans _ ( hC x ( le_trans ( le_max_left _ _ ) hx ) ) ⟩;
      exact mul_le_mul ( hCa x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ) ( Real.exp_le_exp.mpr ( hCb x ( le_trans ( le_max_of_le_right ( le_max_right _ _ ) ) hx ) ) ) ( by positivity ) ( by exact le_trans ( abs_nonneg _ ) ( hCa x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ) );
  obtain ⟨ C, hC_pos, N, X₀, hC ⟩ := h_bound;
  use C, hC_pos, N, Max.max X₀ 1;
  intro x hx; specialize hC x ( le_trans ( le_max_left _ _ ) hx ) ; simp_all +decide [ abs_mul, EMLExpr.eval ] ;
  refine' le_trans _ ( hC.trans _ );
  · exact mul_le_mul_of_nonneg_left ( Real.exp_le_exp.mpr ( le_abs_self _ ) ) ( abs_nonneg _ );
  · rw [ show ( a.eml b ).emlDepth = 1 + max a.emlDepth b.emlDepth from rfl ];
    rw [ add_comm, iterExp_succ ]

/-- **Main structural theorem**: For any inv-free EMLExpr `e`,
    |e.eval x| ≤ iterExp (emlDepth e) (C * x^N) for some C, N and large x. -/
theorem noInv_hasPolyTowerMajorant (e : EMLExpr) (hInv : e.noInv) :
    HasPolyTowerMajorant e.emlDepth e := by
  induction e with
  | var =>
    refine ⟨1, by norm_num, 1, 0, fun x hx => ?_⟩
    simp [EMLExpr.eval, EMLExpr.emlDepth]
    rw [abs_of_nonneg (by linarith)]
  | const c =>
    refine ⟨|c| + 1, by positivity, 0, 0, fun x _ => ?_⟩
    simp [EMLExpr.eval, EMLExpr.emlDepth]
  | neg a ih =>
    simp [EMLExpr.noInv] at hInv
    have h := ih hInv
    simp only [EMLExpr.emlDepth] at h ⊢
    obtain ⟨C, hC, N, X₀, hBound⟩ := h
    exact ⟨C, hC, N, X₀, fun x hx => by simp [EMLExpr.eval]; exact hBound x hx⟩
  | inv _ _ => simp [EMLExpr.noInv] at hInv
  | add a b iha ihb =>
    simp [EMLExpr.noInv] at hInv
    exact hasPTM_add (iha hInv.1) (ihb hInv.2)
  | mul a b iha ihb =>
    simp [EMLExpr.noInv] at hInv
    exact hasPTM_mul (iha hInv.1) (ihb hInv.2)
  | eml a b iha ihb =>
    simp [EMLExpr.noInv] at hInv
    exact hasPTM_eml (iha hInv.1) (ihb hInv.2)

/-
Theorem 1: Sharp upper majorization by depth
-/
theorem invFree_depth_majorized_sharp (D : ℕ)
    (e : EMLExpr) (hInv : e.noInv) (hDepth : e.emlDepth ≤ D) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      |e.eval x| ≤ iterExp D (C * x ^ N) := by
  -- By noInv_hasPolyTowerMajorant, we know that e has a polynomial-argument tower majorant at level emlDepth e.
  obtain ⟨C, hC_pos, N, X₀, h_majorant⟩ : ∃ C > 0, ∃ N X₀, ∀ x ≥ X₀, |e.eval x| ≤ iterExp e.emlDepth (C * x^N) := by
    convert noInv_hasPolyTowerMajorant e hInv using 1;
  refine' ⟨ C, hC_pos, N, Max.max X₀ 1, fun x hx => le_trans ( h_majorant x <| le_trans ( le_max_left _ _ ) hx ) _ ⟩;
  apply_rules [ iterExp_level_mono ];
  exact mul_pos hC_pos ( pow_pos ( by linarith [ le_max_right X₀ 1 ] ) _ )

/-- Theorem 2: iterExp at next level escapes all poly-tower majorants -/
theorem iterExp_escapes_poly_tower (D : ℕ) (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
      iterExp D (C * x ^ N) < iterExp (D + 1) x := by
  exact iterExp_poly_lt_iterExp_succ D C N

/-
**Theorem 3: THE MAIN RESULT** — No inv-free EMLExpr of depth ≤ D
    can represent `iterExp n` for any `n > D`.
-/
theorem no_invFree_lowDepth_represents_iterExp
    (D n : ℕ) (hnd : D < n) :
    ¬ ∃ e : EMLExpr,
        e.noInv ∧ e.emlDepth ≤ D ∧ RepresentsOnPos e (iterExp n) := by
  by_contra h_contra
  obtain ⟨e, he_inv, he_depth, he_repr⟩ := h_contra
  have h_bound : ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → |e.eval x| ≤ iterExp D (C * x ^ N) := by
    apply invFree_depth_majorized_sharp D e he_inv he_depth
  obtain ⟨C, hC_pos, N, X₀, h_bound⟩ := h_bound
  have h_escaped : ∃ X₁ : ℝ, ∀ x : ℝ, x ≥ X₁ → iterExp D (C * x ^ N) < iterExp (D + 1) x := by
    exact?
  obtain ⟨X₁, h_escaped⟩ := h_escaped
  have h_le : ∀ x > 0, iterExp (D + 1) x ≤ iterExp n x := by
    exact fun x hx => iterExp_level_mono ( by linarith ) hx;
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : ℝ, x₀ > 0 ∧ x₀ ≥ X₀ ∧ x₀ ≥ X₁ ∧ e.eval x₀ = iterExp n x₀ := by
    exact ⟨ Max.max ( Max.max X₀ X₁ ) 1, by positivity, le_max_of_le_left ( le_max_left _ _ ), le_max_of_le_left ( le_max_right _ _ ), he_repr _ ( by positivity ) ⟩
  have h_contradiction : iterExp n x₀ ≤ |e.eval x₀| ∧ |e.eval x₀| < iterExp n x₀ := by
    exact ⟨ by rw [ hx₀.2.2.2 ] ; exact le_abs_self _, by linarith [ h_bound x₀ hx₀.2.1, h_escaped x₀ hx₀.2.2.1, h_le x₀ hx₀.1 ] ⟩
  linarith [h_contradiction.left, h_contradiction.right]

/-
Corollary: The canonical construction is depth-optimal
-/
theorem emlExprIterExp_depth_optimal (n : ℕ) :
    ¬ ∃ e : EMLExpr,
        e.noInv ∧ e.emlDepth < n ∧ RepresentsOnPos e (iterExp n) := by
  by_contra h_contra
  obtain ⟨e, hInv, hDepth, hRep⟩ := h_contra;
  convert no_invFree_lowDepth_represents_iterExp ( e.emlDepth ) n hDepth ⟨ e, hInv, le_rfl, hRep ⟩ using 1

/-
Cross-domain: Depth hierarchy for the iterExp family
-/
theorem depth_hierarchy_for_iterExp_family
    {m n : ℕ} (h : m < n) :
    ¬ ∃ e : EMLExpr,
        e.noInv ∧ e.emlDepth ≤ m ∧ RepresentsOnPos e (iterExp n) := by
  convert no_invFree_lowDepth_represents_iterExp m n h using 1

/-! ## Canonical Construction Properties -/

theorem emlExprIterExp_eval (n : ℕ) (x : ℝ) :
    (emlExprIterExp n).eval x = iterExp n x := by
  induction' n with n ih generalizing x <;> simp_all +decide [ iterExp ];
  · rfl;
  · convert congr_arg ( fun y => 1 * Real.exp y ) ( ih x ) using 1;
    grind

theorem emlExprIterExp_emlDepth (n : ℕ) : (emlExprIterExp n).emlDepth = n := by
  induction' n with k ih <;> simp_all +decide [ emlExprIterExp ];
  convert congr_arg ( fun x => 1 + x ) ih using 1;
  exact?

theorem emlExprIterExp_noInv (n : ℕ) : (emlExprIterExp n).noInv := by
  induction' n with n ih;
  · trivial;
  · exact ⟨ trivial, ih ⟩

end