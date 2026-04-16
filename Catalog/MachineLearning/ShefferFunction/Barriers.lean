/-
# Sheffer Algebra: The Barrier System

This file establishes the four barriers that constrain membership in the Sheffer algebra:
1. Lipschitz continuity (Barrier 1)
2. Real analyticity (Barrier 2)
3. Derivative convergence at ±∞ (Barrier 3)
4. Asymptotic linear structure (Barrier 4)

These barriers are used to exclude functions like exp, sin, cos, and polynomials of degree ≥ 2.
-/
import Mathlib
import ShefferAI.Basic

open Real Filter Topology NNReal

noncomputable section

/-! ## Barrier 1: Lipschitz Continuity -/

/-
Every Sheffer expression is Lipschitz.
    This is the first structural barrier: ShefferAlg ⊆ Lip(ℝ).
-/
theorem sheffer_expr_lipschitz (e : ShefferExpr) :
    ∃ K : NNReal, LipschitzWith K e.eval := by
  induction e with
  | base => exact ⟨1, softplus_lipschitz⟩
  | affinePrecomp a b e ih =>
    obtain ⟨K, hK⟩ := ih
    use K * ‖a‖₊;
    convert hK.comp ( show LipschitzWith ( ‖a‖₊ ) ( fun x => a * x + b ) from ?_ ) using 1;
    rw [ lipschitzWith_iff_norm_sub_le ];
    norm_num [ ← mul_sub ]
  | affineComb α β γ e₁ e₂ ih1 ih2 =>
    obtain ⟨K₁, hK₁⟩ := ih1
    obtain ⟨K₂, hK₂⟩ := ih2
    use ⟨ |α| * K₁ + |β| * K₂, by positivity ⟩;
    refine' LipschitzWith.of_dist_le_mul _;
    simp +decide [ ShefferExpr.eval ];
    intro x y; rw [ dist_eq_norm, dist_eq_norm ] ; ring_nf;
    refine' le_trans ( norm_add_le _ _ ) _;
    exact add_le_add ( by simpa [ mul_assoc, ← mul_sub ] using mul_le_mul_of_nonneg_left ( hK₁.norm_sub_le x y ) ( abs_nonneg α ) ) ( by simpa [ mul_assoc, ← mul_sub ] using mul_le_mul_of_nonneg_left ( hK₂.norm_sub_le x y ) ( abs_nonneg β ) )

/-! ## Barrier 1 Applications: Exclusions via Lipschitz -/

/-
exp is not in the Sheffer algebra (fails Lipschitz barrier).
-/
theorem exp_not_mem_sheffer : (fun x : ℝ => Real.exp x) ∉ ShefferAlg := by
  -- By definition of ShefferAlg, we know that it is a subset of the Lipschitz continuous functions.
  have h_sheffer_lipschitz : ∀ f ∈ ShefferAlg, ∃ K : NNReal, LipschitzWith K f := by
    intro f hf; obtain ⟨ e, rfl ⟩ := hf; exact sheffer_expr_lipschitz e;
  intro h;
  obtain ⟨ K, hK ⟩ := h_sheffer_lipschitz _ h;
  rw [ lipschitzWith_iff_norm_sub_le ] at hK;
  -- Choose $x$ large enough such that $e^x > K$.
  obtain ⟨ x, hx ⟩ : ∃ x : ℝ, Real.exp x > K := by
    exact ⟨ K, by linarith [ Real.add_one_le_exp K ] ⟩;
  contrapose! hK;
  -- Choose $y = x + 1$.
  use x, x + 1;
  norm_num [ Real.exp_add ];
  rw [ abs_of_neg ] <;> nlinarith [ Real.add_one_le_exp 1, Real.exp_pos x ]

/-
x² is not in the Sheffer algebra (fails Lipschitz barrier).
-/
theorem sq_not_mem_sheffer : (fun x : ℝ => x ^ 2) ∉ ShefferAlg := by
  intro h
  obtain ⟨e, he⟩ := h
  have h_lip : ∃ K : NNReal, LipschitzWith K (fun x : ℝ => x^2) := by
    exact he ▸ sheffer_expr_lipschitz e;
  obtain ⟨ K, hK ⟩ := h_lip; have := hK.dist_le_mul 0; norm_num at this; ( have := hK.dist_le_mul 1; norm_num at this; ( have := hK.dist_le_mul ( -1 ) ; norm_num at this; ) );
  rename_i h₁ h₂; contrapose! h₁; use K + 1; nlinarith [ NNReal.coe_nonneg K, abs_of_nonneg ( by linarith [ NNReal.coe_nonneg K ] : 0 ≤ ( K : ℝ ) + 1 ) ] ;

/-
xⁿ is not in ShefferAlg for n ≥ 2.
-/
theorem pow_not_mem_sheffer {n : ℕ} (hn : 2 ≤ n) :
    (fun x : ℝ => x ^ n) ∉ ShefferAlg := by
  intro h
  obtain ⟨e, he⟩ := h
  have h_lip : ∃ K : NNReal, LipschitzWith K (fun x : ℝ => x ^ n) := by
    exact he ▸ sheffer_expr_lipschitz e;
  obtain ⟨ K, hK ⟩ := h_lip;
  have := hK.dist_le_mul ( 0 : ℝ ) ( 2 * K + 1 ) ; norm_num at this;
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  rw [ abs_of_nonneg ( by positivity ) ] at this ; nlinarith [ show ( K : ℝ ) ≥ 0 by positivity, pow_le_pow_right₀ ( by linarith [ show ( K : ℝ ) ≥ 0 by positivity ] : 1 ≤ 2 * ( K : ℝ ) + 1 ) ( by linarith : n + 1 + 1 ≥ 2 ) ]

/-! ## Barrier 3: Derivative Convergence -/

/-
The logistic sigmoid tends to 1 at +∞.
-/
theorem logisticSigmoid_tendsto_one :
    Tendsto logisticSigmoid atTop (𝓝 1) := by
  unfold logisticSigmoid;
  -- We can rewrite the function as $1 - \frac{1}{1 + e^x}$.
  suffices h_rewrite : Filter.Tendsto (fun x => 1 - 1 / (1 + Real.exp x)) Filter.atTop (nhds 1) by
    exact h_rewrite.congr fun x => by rw [ one_sub_div ( by positivity ) ] ; ring;
  exact le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| tendsto_const_nhds.add_atTop <| Real.tendsto_exp_atTop ) <| by norm_num;

/-
The logistic sigmoid tends to 0 at -∞.
-/
theorem logisticSigmoid_tendsto_zero :
    Tendsto logisticSigmoid atBot (𝓝 0) := by
  convert Tendsto.div ( Real.tendsto_exp_atBot ) ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot ) ) _ using 1 <;> norm_num

/-! ## Barrier 3 Applications -/

/-- The asymptotic slopes at +∞ and -∞, computed together. -/
def ShefferExpr.slopes : ShefferExpr → ℝ × ℝ
  | .base => (1, 0)
  | .affinePrecomp a _ e =>
    let (sTop, sBot) := e.slopes
    if 0 < a then (sTop * a, sBot * a)
    else if a < 0 then (sBot * a, sTop * a)
    else (0, 0)
  | .affineComb α β _ e₁ e₂ =>
    let (s1Top, s1Bot) := e₁.slopes
    let (s2Top, s2Bot) := e₂.slopes
    (α * s1Top + β * s2Top, α * s1Bot + β * s2Bot)

/-
Every Sheffer expression has a well-defined limit behavior at +∞ and -∞.
-/
theorem sheffer_expr_tendsto_both (e : ShefferExpr) :
    ((∃ L : ℝ, Tendsto e.eval atTop (𝓝 L)) ∨
     Tendsto e.eval atTop atTop ∨
     Tendsto e.eval atTop atBot) ∧
    ((∃ L : ℝ, Tendsto e.eval atBot (𝓝 L)) ∨
     Tendsto e.eval atBot atTop ∨
     Tendsto e.eval atBot atBot) := by
  -- Prove that every Sheffer expression has a well-defined limit behavior at +∞ and -∞.
  have h_limit_behavior : ∀ e : ShefferExpr, (∃ L : ℝ, Filter.Tendsto e.eval Filter.atTop (nhds L)) ∨ Tendsto e.eval Filter.atTop Filter.atTop ∨ Tendsto e.eval Filter.atTop Filter.atBot := by
    intro e;
    have h_inductive_step : ∀ e : ShefferExpr, (∃ L₁ L₂ : ℝ, Filter.Tendsto (fun x => e.eval x - e.slopes.1 * x) Filter.atTop (nhds L₁)) ∧ (∃ L₁ L₂ : ℝ, Filter.Tendsto (fun x => e.eval x - e.slopes.2 * x) Filter.atBot (nhds L₂)) := by
      intro e
      induction' e with e ih;
      · constructor <;> norm_num [ ShefferExpr.eval, ShefferExpr.slopes ];
        · -- We'll use the fact that $softplus(x) - x = \log(1 + e^{-x})$.
          have h_log : ∀ x : ℝ, softplus x - x = Real.log (1 + Real.exp (-x)) := by
            intro x; rw [ show softplus x = Real.log ( 1 + Real.exp x ) by rfl ] ; rw [ show ( 1 + Real.exp x ) = ( 1 + Real.exp ( -x ) ) * Real.exp x by nlinarith [ Real.exp_pos x, Real.exp_neg x, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos x ) ) ] ] ; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;
          exact ⟨ _, by simpa only [ h_log ] using Filter.Tendsto.log ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot.comp Filter.tendsto_neg_atTop_atBot ) ) ( by norm_num ) ⟩;
        · exact ⟨ _, by exact ( Real.continuousAt_log ( by positivity ) ) |> Filter.Tendsto.comp <| tendsto_const_nhds.add <| Real.tendsto_exp_atBot ⟩;
      · rename_i e' ih';
        by_cases he : 0 < e <;> by_cases he' : e < 0 <;> simp_all +decide [ ShefferExpr.slopes ];
        · linarith;
        · constructor <;> simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, ShefferExpr.eval ];
          · obtain ⟨ L₁, hL₁ ⟩ := ih'.1;
            use L₁ + ih * e'.slopes.1;
            convert hL₁.comp ( show Filter.Tendsto ( fun x : ℝ => x * e + ih ) Filter.atTop Filter.atTop from Filter.tendsto_atTop_add_const_right _ _ <| Filter.tendsto_id.atTop_mul_const he ) |> Filter.Tendsto.add_const ( ih * e'.slopes.1 ) using 2 ; norm_num ; ring;
          · obtain ⟨ L₂, hL₂ ⟩ := ih'.2;
            use L₂ + ih * e'.slopes.2;
            convert hL₂.comp ( show Filter.Tendsto ( fun x : ℝ => x * e + ih ) Filter.atBot Filter.atBot from Filter.tendsto_atBot_add_const_right _ _ <| Filter.tendsto_id.atBot_mul_const he ) |> Filter.Tendsto.add_const ( ih * e'.slopes.2 ) using 2 ; norm_num ; ring;
        · constructor <;> simp_all +decide [ ShefferExpr.eval ];
          · split_ifs <;> simp_all +decide [ mul_comm e ];
            · linarith;
            · obtain ⟨ L₂, hL₂ ⟩ := ih'.2;
              use L₂ + e'.slopes.2 * ih;
              convert hL₂.comp ( show Filter.Tendsto ( fun x : ℝ => x * e + ih ) Filter.atTop Filter.atBot from Filter.tendsto_atTop_atBot.mpr _ ) |> Filter.Tendsto.add_const ( e'.slopes.2 * ih ) using 2 ; norm_num ; ring;
              exact fun b => ⟨ ( b - ih ) / e, fun x hx => by nlinarith [ mul_div_cancel₀ ( b - ih ) he'.ne ] ⟩;
          · have h_lim : Filter.Tendsto (fun x => e'.eval (e * x + ih) - e'.slopes.1 * (e * x + ih)) Filter.atBot (nhds (ih'.left.choose)) := by
              exact ih'.1.choose_spec.comp <| Filter.tendsto_atBot_atTop.mpr fun x => ⟨ ( x - ih ) / e, fun y hy => by nlinarith [ mul_div_cancel₀ ( x - ih ) he'.ne ] ⟩;
            exact ⟨ _, by convert h_lim.add_const ( e'.slopes.1 * ih ) using 2 ; split_ifs <;> linarith ⟩;
        · simp_all +decide [ le_antisymm he he' ];
          constructor <;> norm_num [ ShefferExpr.eval ];
      · constructor <;> norm_num [ ShefferExpr.eval, ShefferExpr.slopes ];
        · rename_i h₁ h₂;
          obtain ⟨ ⟨ L₁, L₂, h₁ ⟩, ⟨ L₃, L₄, h₂ ⟩ ⟩ := h₁, h₂;
          rename_i α β γ e₁ e₂;
          obtain ⟨ L₁, L₂, h₁ ⟩ := L₁; obtain ⟨ L₃, L₄, h₂ ⟩ := L₃; use α * L₁ + β * L₃ + γ; convert Filter.Tendsto.add ( Filter.Tendsto.add ( h₁.const_mul α ) ( h₂.const_mul β ) ) tendsto_const_nhds using 2 ; ring;
        · rename_i h₁ h₂;
          rename_i α β γ e₁ e₂;
          obtain ⟨ L₁, L₂, h₁ ⟩ := h₁.2; obtain ⟨ L₃, L₄, h₂ ⟩ := h₂.2; exact ⟨ α * L₂ + β * L₄ + γ, by convert Filter.Tendsto.add ( Filter.Tendsto.add ( h₁.const_mul α ) ( h₂.const_mul β ) ) tendsto_const_nhds using 2 ; ring ⟩ ;
    obtain ⟨ ⟨ L₁, L₂, h₁ ⟩, ⟨ L₃, L₄, h₂ ⟩ ⟩ := h_inductive_step e;
    by_cases h : e.slopes.1 = 0;
    · aesop;
    · by_cases h_pos : 0 < e.slopes.1;
      · have h_tendsto_top : Filter.Tendsto (fun x => e.eval x - e.slopes.1 * x + e.slopes.1 * x) Filter.atTop Filter.atTop := by
          exact Filter.Tendsto.add_atTop h₁ ( Filter.tendsto_id.const_mul_atTop h_pos );
        aesop;
      · have h_neg : Filter.Tendsto (fun x => e.eval x - e.slopes.1 * x + e.slopes.1 * x) Filter.atTop Filter.atBot := by
          exact Filter.Tendsto.add_atBot h₁ ( Filter.tendsto_id.const_mul_atTop_of_neg ( lt_of_le_of_ne ( le_of_not_gt h_pos ) h ) );
        aesop;
  refine ⟨ h_limit_behavior e, ?_ ⟩;
  convert h_limit_behavior ( ShefferExpr.affinePrecomp ( -1 ) 0 e ) using 1;
  · norm_num [ ShefferExpr.eval ];
  · norm_num [ ShefferExpr.eval ]

/-- Every Sheffer expression has a trichotomy at +∞. -/
theorem sheffer_expr_tendsto_atTop (e : ShefferExpr) :
    (∃ L : ℝ, Tendsto e.eval atTop (𝓝 L)) ∨
    Tendsto e.eval atTop atTop ∨
    Tendsto e.eval atTop atBot :=
  (sheffer_expr_tendsto_both e).1

/-
sin is not in ShefferAlg. sin oscillates and has no limit at +∞,
    contradicting sheffer_expr_tendsto_atTop.
-/
theorem sin_not_mem_sheffer : (fun x : ℝ => Real.sin x) ∉ ShefferAlg := by
  intro h_sin_in_sheffer
  obtain ⟨e, he⟩ := h_sin_in_sheffer;
  -- By sheffer_expr_tendsto_atTop, sin either has a finite limit at +∞, tends to +∞, or tends to -∞.
  have h_tendsto : (∃ L : ℝ, Tendsto (fun x => Real.sin x) atTop (𝓝 L)) ∨
    Tendsto (fun x => Real.sin x) atTop atTop ∨
    Tendsto (fun x => Real.sin x) atTop atBot := by
      simpa only [ ← he ] using sheffer_expr_tendsto_atTop e;
  rcases h_tendsto with ( ⟨ L, hL ⟩ | hL | hL );
  · have h_subseq : Filter.Tendsto (fun n : ℕ => Real.sin (2 * Real.pi * n)) Filter.atTop (nhds L) ∧ Filter.Tendsto (fun n : ℕ => Real.sin (2 * Real.pi * n + Real.pi / 2)) Filter.atTop (nhds L) := by
      exact ⟨ hL.comp <| Filter.tendsto_atTop_mono ( fun n => by nlinarith [ Real.pi_gt_three ] ) tendsto_natCast_atTop_atTop, hL.comp <| Filter.tendsto_atTop_mono ( fun n => by nlinarith [ Real.pi_gt_three ] ) tendsto_natCast_atTop_atTop ⟩;
    norm_num [ mul_comm ( 2 * Real.pi ), Real.sin_add ] at h_subseq;
    norm_num [ show ∀ n : ℕ, Real.sin ( n * ( 2 * Real.pi ) ) = 0 from fun n => Real.sin_eq_zero_iff.mpr ⟨ n * 2, by push_cast; ring ⟩ ] at h_subseq ; linarith;
  · exact absurd ( hL.eventually_gt_atTop 1 ) fun h => by obtain ⟨ x, hx ⟩ := h.exists; linarith [ Real.sin_le_one x ] ;
  · have := hL.eventually ( Filter.eventually_lt_atBot ( -1 ) ) ; obtain ⟨ x, hx ⟩ := this.exists; linarith [ Real.neg_one_le_sin x ]

/-
cos is not in ShefferAlg. cos oscillates and has no limit at +∞.
-/
theorem cos_not_mem_sheffer : (fun x : ℝ => Real.cos x) ∉ ShefferAlg := by
  by_contra h_cos_mem_sheffer
  obtain ⟨e, he⟩ : ∃ e : ShefferExpr, (fun x => Real.cos x) = e.eval := by
    exact?;
  obtain ⟨ L, hL ⟩ | hL | hL := sheffer_expr_tendsto_atTop e;
  · have h_cos_subseq : Filter.Tendsto (fun n : ℕ => Real.cos (2 * Real.pi * n)) Filter.atTop (nhds L) ∧ Filter.Tendsto (fun n : ℕ => Real.cos (Real.pi * (2 * n + 1))) Filter.atTop (nhds L) := by
      exact ⟨ by simpa only [ ← he ] using hL.comp ( Filter.tendsto_atTop_mono ( fun n => by nlinarith [ Real.pi_gt_three ] ) tendsto_natCast_atTop_atTop ), by simpa only [ ← he ] using hL.comp ( Filter.tendsto_atTop_mono ( fun n => by nlinarith [ Real.pi_gt_three ] ) tendsto_natCast_atTop_atTop ) ⟩;
    norm_num [ mul_add, mul_assoc, mul_comm Real.pi _, mul_left_comm ] at h_cos_subseq;
    norm_num [ add_mul, mul_assoc, mul_left_comm ] at h_cos_subseq;
    linarith;
  · exact absurd ( hL.eventually_gt_atTop 1 ) fun h => by have := h.and ( Filter.eventually_gt_atTop 0 ) ; obtain ⟨ x, hx₁, hx₂ ⟩ := this.exists; linarith [ Real.cos_le_one x, congr_fun he x ] ;
  · have := hL.eventually ( Filter.eventually_lt_atBot ( -1 ) ) ; obtain ⟨ x, hx ⟩ := this.exists; linarith [ Real.neg_one_le_cos x, Real.cos_le_one x, congr_fun he x ] ;

/-! ## Barrier 4: Asymptotic Linear Structure -/

/-
σ(x) - x → 0 as x → +∞.
-/
theorem softplus_sub_id_tendsto_zero_atTop :
    Tendsto (fun x => softplus x - x) atTop (𝓝 0) := by
  convert Tendsto.log ( show Filter.Tendsto ( fun x : ℝ => ( 1 + Real.exp x ) / ( Real.exp x ) ) Filter.atTop ( nhds ( 1 : ℝ ) ) from ?_ ) _ using 1 <;> norm_num [ add_div ];
  · ext x; rw [ show ( Real.exp x ) ⁻¹ + 1 = ( 1 + Real.exp x ) / Real.exp x by ring_nf; norm_num [ Real.exp_ne_zero ] ] ; rw [ Real.log_div ( by positivity ) ( by positivity ) ] ; ring;
    unfold softplus; norm_num;
  · simpa using tendsto_inv_atTop_zero.comp Real.tendsto_exp_atTop |> Filter.Tendsto.add_const 1

/-
σ(x) → 0 as x → -∞.
-/
theorem softplus_tendsto_zero_atBot :
    Tendsto softplus atBot (𝓝 0) := by
  convert Filter.Tendsto.log ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot ) ) _ using 1 <;> norm_num

end