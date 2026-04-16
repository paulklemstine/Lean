/-! # CatalogBuild.MachineLearning.ShefferFunction.Barriers

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5
-/

import Mathlib
import EML.Basic

noncomputable section

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


/-- [Section: ## Barrier 3 Applications] -/
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


/-- [Section: ## Barrier 4: Asymptotic Linear Structure] -/
theorem softplus_sub_id_tendsto_zero_atTop :
    Tendsto (fun x => softplus x - x) atTop (𝓝 0) := by
  convert Tendsto.log ( show Filter.Tendsto ( fun x : ℝ => ( 1 + Real.exp x ) / ( Real.exp x ) ) Filter.atTop ( nhds ( 1 : ℝ ) ) from ?_ ) _ using 1 <;> norm_num [ add_div ];
  · ext x; rw [ show ( Real.exp x ) ⁻¹ + 1 = ( 1 + Real.exp x ) / Real.exp x by ring_nf; norm_num [ Real.exp_ne_zero ] ] ; rw [ Real.log_div ( by positivity ) ( by positivity ) ] ; ring;
    unfold softplus; norm_num;
  · simpa using tendsto_inv_atTop_zero.comp Real.tendsto_exp_atTop |> Filter.Tendsto.add_const 1


end
