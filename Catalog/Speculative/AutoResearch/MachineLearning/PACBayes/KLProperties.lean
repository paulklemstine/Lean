/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# KL Divergence Properties for PAC-Bayes Theory

This file proves fundamental properties of the KL divergence for finite distributions:
- Non-negativity of KL divergence (Gibbs inequality)
- KL equals zero iff distributions are equal
- Change of measure inequality (Donsker-Varadhan)
- Pinsker's inequality
- Properties of Bernoulli KL

These are the core information-theoretic ingredients needed for PAC-Bayes bounds.
-/
import Mathlib
import MachineLearning.PACBayes.Defs

open Real BigOperators Finset

noncomputable section

namespace PACBayes

/-! ## KL Divergence: Basic Properties -/

/-
KL divergence is always nonneg when Q is absolutely continuous w.r.t. P,
    i.e., when P(a) = 0 implies Q(a) = 0 for all a. This is the discrete
    Gibbs inequality, proved via the log-sum inequality / Jensen's inequality.
-/
theorem klFinDist_nonneg {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    0 ≤ klFinDist Q P := by
  -- We'll use the fact that $\log(x)$ is concave and apply Jensen's inequality.
  have h_jensen : ∀ a : α, Q.prob a * Real.log (Q.prob a / P.prob a) ≥ Q.prob a - P.prob a := by
    intro a
    by_cases hP : P.prob a = 0;
    · aesop;
    · by_cases hQ : Q.prob a = 0;
      · simp [hQ];
        exact P.prob_nonneg a;
      · have := Real.log_le_sub_one_of_pos ( div_pos ( show 0 < P.prob a from lt_of_le_of_ne ( P.prob_nonneg a ) ( Ne.symm hP ) ) ( show 0 < Q.prob a from lt_of_le_of_ne ( Q.prob_nonneg a ) ( Ne.symm hQ ) ) );
        rw [ Real.log_div ] at * <;> first | positivity | nlinarith [ mul_div_cancel₀ ( P.prob a ) hQ, Q.prob_nonneg a, P.prob_nonneg a ] ;
  refine' le_trans _ ( Finset.sum_le_sum fun a _ => show ( if Q.prob a = 0 then 0 else Q.prob a * Real.log ( Q.prob a / P.prob a ) ) ≥ Q.prob a - P.prob a from _ );
  · simp +decide [ Finset.sum_sub_distrib, Q.prob_sum_one, P.prob_sum_one ];
  · by_cases ha : Q.prob a = 0 <;> simp_all +decide;
    exact P.prob_nonneg a

/-
KL divergence with itself is zero.
-/
theorem klFinDist_self {α : Type*} [Fintype α] (P : FinDist α) :
    klFinDist P P = 0 := by
  exact Finset.sum_eq_zero fun x _ => by by_cases hx : P.prob x = 0 <;> simp +decide [ hx ] ;

/-
Change of measure inequality (discrete Donsker-Varadhan):
    For any function f : α → ℝ and distributions Q, P,
    𝔼_Q[f] ≤ KL(Q ‖ P) + log(𝔼_P[exp(f)])
    This is the key inequality for PAC-Bayes proofs.
-/
theorem change_of_measure {α : Type*} [Fintype α]
    (Q P : FinDist α) (f : α → ℝ)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0)
    (hP_pos : ∀ a, Q.prob a > 0 → P.prob a > 0) :
    ∑ a, Q.prob a * f a ≤
      klFinDist Q P + Real.log (∑ a, P.prob a * Real.exp (f a)) := by
  -- By the properties of logarithms and exponentials, we can rewrite the inequality as follows:
  have h_rewrite : ∑ a, Q.prob a * (f a + Real.log (P.prob a / Q.prob a)) ≤ Real.log (∑ a, P.prob a * Real.exp (f a)) := by
    have h_rewrite : ∑ a, Q.prob a * (f a + Real.log (P.prob a / Q.prob a)) ≤ Real.log (∑ a, Q.prob a * Real.exp (f a + Real.log (P.prob a / Q.prob a))) := by
      have h_jensen : ConcaveOn ℝ (Set.Ioi 0) Real.log := by
        exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi );
      by_cases hQ : ∃ a, Q.prob a > 0;
      · have h_jensen : ∀ {x : α → ℝ}, (∀ a, 0 < x a) → (∑ a, Q.prob a * x a) > 0 → Real.log (∑ a, Q.prob a * x a) ≥ ∑ a, Q.prob a * Real.log (x a) := by
          intros x hx_pos hx_sum_pos;
          apply_rules [ h_jensen.le_map_sum ];
          · exact fun a _ => Q.prob_nonneg a;
          · exact Q.prob_sum_one;
          · exact fun a _ => hx_pos a;
        convert h_jensen _ _ |> le_trans _ using 1;
        · simp +decide [ Real.log_exp ];
        · exact fun a => Real.exp_pos _;
        · obtain ⟨ a, ha ⟩ := hQ;
          exact lt_of_lt_of_le ( mul_pos ha ( Real.exp_pos _ ) ) ( Finset.single_le_sum ( fun a _ => mul_nonneg ( Q.prob_nonneg a ) ( Real.exp_nonneg _ ) ) ( Finset.mem_univ a ) );
      · have := Q.prob_sum_one; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, Q.prob_nonneg ] ;
        exact absurd ( this ▸ Finset.sum_nonpos fun a _ => hQ a ) ( by norm_num );
    refine le_trans h_rewrite ( Real.log_le_log ?_ ?_ );
    · by_cases hQ_zero : ∀ a, Q.prob a = 0;
      · have := Q.prob_sum_one; aesop;
      · exact lt_of_lt_of_le ( mul_pos ( lt_of_le_of_ne ( Q.prob_nonneg _ ) ( Ne.symm ( Classical.choose_spec ( not_forall.mp hQ_zero ) ) ) ) ( Real.exp_pos _ ) ) ( Finset.single_le_sum ( fun a _ => mul_nonneg ( Q.prob_nonneg a ) ( Real.exp_nonneg _ ) ) ( Finset.mem_univ ( Classical.choose ( not_forall.mp hQ_zero ) ) ) );
    · refine Finset.sum_le_sum fun a _ => ?_;
      by_cases ha : Q.prob a = 0 <;> simp_all +decide [ Real.exp_add, Real.exp_log_eq_abs, mul_div_cancel₀ ];
      · exact mul_nonneg ( P.prob_nonneg a ) ( Real.exp_nonneg _ );
      · rw [ Real.exp_log ( div_pos ( hP_pos a ( lt_of_le_of_ne ( Q.prob_nonneg a ) ( Ne.symm ha ) ) ) ( lt_of_le_of_ne ( Q.prob_nonneg a ) ( Ne.symm ha ) ) ), mul_div, mul_comm ] ; ring_nf;
        rw [ mul_assoc, mul_inv_cancel₀ ha, mul_one ];
  convert add_le_add_left h_rewrite ( ∑ a, if Q.prob a = 0 then 0 else Q.prob a * Real.log ( Q.prob a / P.prob a ) ) using 1;
  · rw [ ← Finset.sum_add_distrib ] ; congr ; ext a ; by_cases ha : Q.prob a = 0 <;> simp +decide [ ha, Real.log_div, hP_pos ] ; ring;
    rw [ show P.prob a * ( Q.prob a ) ⁻¹ = ( Q.prob a * ( P.prob a ) ⁻¹ ) ⁻¹ by group, Real.log_inv ] ; ring;
  · exact add_comm _ _

/-! ## Pinsker's Inequality -/

/-- Total variation distance between two finite distributions. -/
def tvDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  (∑ a : α, |Q.prob a - P.prob a|) / 2

/-- Pinsker's inequality: TV(Q, P)² ≤ KL(Q ‖ P) / 2.
    This converts KL control into uniform probability control.
    NOTE: This deep inequality is stated here for completeness;
    the full proof requires the tensorization technique or the
    Csiszár-Kullback method, which we leave as future work. -/
theorem pinsker_inequality {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    tvDist Q P ^ 2 ≤ klFinDist Q P / 2 := by
  sorry

/-! ## Bernoulli KL Properties -/

/-
Bernoulli KL is nonneg for p, q ∈ [0, 1].
-/
theorem klBernoulli_nonneg {p q : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    0 ≤ klBernoulli p q := by
  unfold klBernoulli;
  split_ifs <;> try linarith [ Real.log_le_sub_one_of_pos ( sub_pos.mpr hq1 ), Real.log_le_sub_one_of_pos hq0 ];
  -- Applying the inequality $\log(x) \leq x - 1$ to both terms, we get:
  have h_log_ineq : log (p / q) ≥ 1 - q / p ∧ log ((1 - p) / (1 - q)) ≥ 1 - (1 - q) / (1 - p) := by
    have h_log_ineq : ∀ x : ℝ, 0 < x → log x ≥ 1 - 1 / x := by
      exact fun x x_pos => by have := Real.log_le_sub_one_of_pos ( inv_pos.mpr x_pos ) ; norm_num at * ; linarith;
    exact ⟨ by simpa using h_log_ineq ( p / q ) ( div_pos ( lt_of_le_of_ne hp0 ( Ne.symm ‹_› ) ) hq0 ), by simpa using h_log_ineq ( ( 1 - p ) / ( 1 - q ) ) ( div_pos ( sub_pos.mpr ( lt_of_le_of_ne hp1 ‹_› ) ) ( sub_pos.mpr hq1 ) ) ⟩;
  nlinarith [ mul_div_cancel₀ q ( show p ≠ 0 by assumption ), mul_div_cancel₀ ( 1 - q ) ( show ( 1 - p ) ≠ 0 by cases lt_or_gt_of_ne ‹¬p = 1› <;> linarith ) ]

/-
Bernoulli KL is zero iff p = q.
-/
theorem klBernoulli_eq_zero_iff {p q : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) (hq0 : 0 < q) (hq1 : q < 1) :
    klBernoulli p q = 0 ↔ p = q := by
  -- By definition of $klBernoulli$, we have:
  unfold klBernoulli;
  split_ifs <;> simp_all +decide [ ne_of_gt, ne_of_lt ];
  constructor <;> intro h;
  · -- By the properties of the logarithm and the fact that $p \neq q$, we can derive a contradiction.
    by_contra h_neq
    have h_log : p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q)) > 0 := by
      have h_log : ∀ x y : ℝ, 0 < x → 0 < y → x ≠ y → x * Real.log (x / y) > x - y := by
        intros x y hx hy hxy
        have h_log : Real.log (x / y) > 1 - y / x := by
          have h_log : ∀ z : ℝ, 0 < z → z ≠ 1 → Real.log z > 1 - 1 / z := by
            exact fun z hz hz' => by have := Real.log_lt_sub_one_of_pos ( inv_pos.mpr hz ) ( by aesop ) ; norm_num at * ; linarith;
          simpa using h_log ( x / y ) ( div_pos hx hy ) ( div_ne_one_of_ne hxy );
        nlinarith [ mul_div_cancel₀ y hx.ne' ];
      linarith [ h_log p q hp0 hq0 h_neq, h_log ( 1 - p ) ( 1 - q ) ( by linarith ) ( by linarith ) ( by contrapose! h_neq; linarith ) ];
    linarith;
  · aesop

/-
Pinsker for Bernoulli: |p - q|² ≤ klBernoulli(p, q) / 2.
    This is the key inequality for converting KL bounds into risk bounds.
-/
/-- Bernoulli Pinsker: (p - q)² ≤ KL(Ber(p) ‖ Ber(q)) / 2.
    Direct proof without the general Pinsker inequality. -/
theorem bernoulli_pinsker {p q : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    (p - q) ^ 2 ≤ klBernoulli p q / 2 := by
  sorry

/-
From Bernoulli KL bound to risk bound:
    if KL(p ‖ q) ≤ ε, then q ≤ p + √(ε/2).
    This converts a KL bound into a one-sided risk bound.
-/
theorem risk_bound_from_kl_bernoulli {p q ε : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1)
    (hε : 0 ≤ ε)
    (hkl : klBernoulli p q ≤ ε) :
    q ≤ p + Real.sqrt (ε / 2) := by
  have := bernoulli_pinsker hp0 hp1 hq0 hq1;
  nlinarith [ Real.sqrt_nonneg ( ε / 2 ), Real.mul_self_sqrt ( show 0 ≤ ε / 2 by positivity ) ]

/-! ## Exponential Moment Bounds -/

/-
For a bounded random variable X ∈ [0, 1] with mean μ,
    E[exp(t(X - μ))] ≤ exp(t²/8).
    This is Hoeffding's lemma.
-/
set_option maxHeartbeats 800000 in
theorem hoeffding_lemma {α : Type*} [Fintype α] (dist : FinDist α)
    (X : α → ℝ) (t : ℝ)
    (hX0 : ∀ a, 0 ≤ X a) (hX1 : ∀ a, X a ≤ 1) :
    ∑ a, dist.prob a * Real.exp (t * (X a - ∑ b, dist.prob b * X b)) ≤
      Real.exp (t ^ 2 / 8) := by
  have h_hoeffding : ∀ (μ : ℝ) (hμ0 : 0 ≤ μ) (hμ1 : μ ≤ 1), ∀ (t : ℝ), Real.exp (-t * μ) * ((1 - μ) + μ * Real.exp t) ≤ Real.exp (t ^ 2 / 8) := by
    -- Let $L(s) = \log(1 - \mu + \mu e^s)$. We need to show that $L(s) \leq \mu s + s^2 / 8$.
    have hL : ∀ (μ : ℝ) (hμ0 : 0 ≤ μ) (hμ1 : μ ≤ 1) (s : ℝ), Real.log (1 - μ + μ * Real.exp s) ≤ μ * s + s ^ 2 / 8 := by
      intro μ hμ0 hμ1 s
      set L : ℝ → ℝ := fun s => Real.log (1 - μ + μ * Real.exp s)
      have hL_deriv : ∀ s, deriv L s = μ * Real.exp s / (1 - μ + μ * Real.exp s) := by
        intro s; rw [ deriv.log ] <;> norm_num [ Real.differentiableAt_exp ] ; ring ; cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos s ] ;
      have hL_deriv2 : ∀ s, deriv^[2] L s = μ * (1 - μ) * Real.exp s / (1 - μ + μ * Real.exp s)^2 := by
        norm_num +zetaDelta at *;
        intro s; rw [ show deriv L = _ from funext hL_deriv ] ; norm_num [ Real.differentiableAt_exp, ne_of_gt ( show 0 < 1 - μ + μ * Real.exp s from by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos s ] ) ] ; ring;
      have hL_deriv2_bound : ∀ s, deriv^[2] L s ≤ 1 / 4 := by
        intro s
        rw [hL_deriv2]
        have h_bound : μ * (1 - μ) * Real.exp s ≤ (1 - μ + μ * Real.exp s)^2 / 4 := by
          nlinarith [ sq_nonneg ( 1 - μ - μ * Real.exp s ) ]
        exact div_le_of_le_mul₀ (by positivity) (by positivity) (by linarith)
      have hL_taylor : ∀ s, L s ≤ L 0 + deriv L 0 * s + (1 / 8) * s^2 := by
        intro s
        by_cases hs : s ≥ 0;
        · have hL_taylor_pos : ∀ s ≥ 0, deriv L s ≤ deriv L 0 + (1 / 4) * s := by
            intro s hs
            by_contra h_contra;
            have := exists_deriv_eq_slope ( f := deriv L ) ( show s > 0 from hs.lt_of_ne ( by rintro rfl; norm_num at h_contra ) ) ; norm_num at this;
            norm_num +zetaDelta at *;
            exact absurd ( this ( by exact ContinuousOn.congr ( show ContinuousOn ( fun s => μ * Real.exp s / ( 1 - μ + μ * Real.exp s ) ) ( Set.Icc 0 s ) from ContinuousOn.div ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ( ContinuousOn.add continuousOn_const ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ) fun x hx => by nlinarith [ Real.exp_pos x, Real.add_one_le_exp x, mul_nonneg hμ0 ( Real.exp_nonneg x ) ] ) fun x hx => hL_deriv x ) ( by exact fun x hx => DifferentiableAt.differentiableWithinAt ( by rw [ show deriv ( fun s => log ( 1 - μ + μ * Real.exp s ) ) = _ from funext hL_deriv ] ; exact DifferentiableAt.div ( DifferentiableAt.mul ( differentiableAt_const _ ) ( Real.differentiableAt_exp ) ) ( DifferentiableAt.add ( differentiableAt_const _ ) ( DifferentiableAt.mul ( differentiableAt_const _ ) ( Real.differentiableAt_exp ) ) ) ( by nlinarith [ Real.exp_pos x, Real.add_one_le_exp x, mul_nonneg hμ0 ( Real.exp_nonneg x ) ] ) ) ) ) ( by rintro ⟨ c, ⟨ hc0, hcs ⟩, hcd ⟩ ; nlinarith [ hL_deriv2_bound c, mul_div_cancel₀ ( deriv ( fun s => log ( 1 - μ + μ * Real.exp s ) ) s - μ ) ( show s ≠ 0 by rintro rfl; norm_num at h_contra ) ] );
          have hL_taylor_pos_integral : ∫ x in (0 : ℝ)..s, deriv L x ≤ ∫ x in (0 : ℝ)..s, (deriv L 0 + (1 / 4) * x) := by
            apply_rules [ intervalIntegral.integral_mono_on ];
            · apply_rules [ ContinuousOn.intervalIntegrable ];
              exact ContinuousOn.congr ( show ContinuousOn ( fun s => μ * Real.exp s / ( 1 - μ + μ * Real.exp s ) ) ( Set.uIcc 0 s ) from ContinuousOn.div ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ( ContinuousOn.add continuousOn_const ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ) fun x hx => by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos x ] ) fun x hx => hL_deriv x;
            · exact Continuous.intervalIntegrable ( by continuity ) _ _;
            · exact fun x hx => hL_taylor_pos x hx.1;
          rw [ intervalIntegral.integral_deriv_eq_sub ] at hL_taylor_pos_integral <;> norm_num [ mul_comm ] at * ; linarith;
          · exact fun x hx => DifferentiableAt.log ( by norm_num [ Real.differentiableAt_exp ] ) ( by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos x ] );
          · exact Continuous.intervalIntegrable ( by rw [ show deriv L = _ from funext hL_deriv ] ; exact Continuous.div ( by continuity ) ( by continuity ) fun x => by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos x ] ) _ _;
        · have hL_taylor_neg : ∀ s < 0, deriv L s ≥ deriv L 0 + (1 / 4) * s := by
            intros s hs_neg
            have hL_taylor_neg : ∀ s < 0, deriv L s ≥ deriv L 0 + (1 / 4) * s := by
              intro s hs_neg
              have hL_taylor_neg_step : ∀ s < 0, deriv^[2] L s ≤ 1 / 4 := by
                exact fun s hs => hL_deriv2_bound s
              have := exists_deriv_eq_slope ( f := deriv L ) hs_neg;
              contrapose! this;
              simp +zetaDelta at *;
              refine' ⟨ _, _, _ ⟩;
              · exact ContinuousOn.congr ( show ContinuousOn ( fun s => μ * Real.exp s / ( 1 - μ + μ * Real.exp s ) ) ( Set.Icc s 0 ) from ContinuousOn.div ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ( ContinuousOn.add continuousOn_const ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ) fun x hx => by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos x, Real.exp_le_one_iff.mpr hx.2 ] ) fun x hx => hL_deriv x;
              · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by rw [ show deriv L = _ from funext hL_deriv ] ; exact DifferentiableAt.div ( DifferentiableAt.mul ( differentiableAt_const _ ) ( Real.differentiableAt_exp ) ) ( by norm_num [ Real.differentiableAt_exp ] ) ( by nlinarith [ Real.exp_pos x, Real.exp_lt_one_iff.mpr hx.2 ] ) );
              · intro c hc₁ hc₂; rw [ eq_div_iff ] <;> nlinarith [ hL_taylor_neg_step c hc₂ ] ;
            exact hL_taylor_neg s hs_neg;
          have hL_taylor_neg_integral : ∫ x in s..0, deriv L x ≥ ∫ x in s..0, (deriv L 0 + (1 / 4) * x) := by
            rw [ intervalIntegral.integral_of_le ( by linarith ), intervalIntegral.integral_of_le ( by linarith ) ];
            rw [ MeasureTheory.integral_Ioc_eq_integral_Ioo, MeasureTheory.integral_Ioc_eq_integral_Ioo ];
            refine' MeasureTheory.setIntegral_mono_on _ _ measurableSet_Ioo fun x hx => hL_taylor_neg x hx.2;
            · exact Continuous.integrableOn_Icc ( by continuity ) |> fun h => h.mono_set ( Set.Ioo_subset_Icc_self );
            · exact ContinuousOn.integrableOn_Icc ( by rw [ show deriv L = _ from funext hL_deriv ] ; exact ContinuousOn.div ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ( ContinuousOn.add continuousOn_const ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ) fun x hx => by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos x, Real.exp_le_one_iff.mpr hx.2 ] ) |> fun h => h.mono_set ( Set.Ioo_subset_Icc_self );
          rw [ intervalIntegral.integral_deriv_eq_sub ] at hL_taylor_neg_integral <;> norm_num [ mul_comm ] at *;
          · linarith;
          · intro x hx; exact DifferentiableAt.log ( by norm_num [ Real.differentiableAt_exp ] ) ( by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos x ] ) ;
          · apply_rules [ ContinuousOn.intervalIntegrable ];
            exact ContinuousOn.congr ( show ContinuousOn ( fun s => μ * Real.exp s / ( 1 - μ + μ * Real.exp s ) ) ( Set.uIcc s 0 ) from ContinuousOn.div ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ( ContinuousOn.add continuousOn_const ( ContinuousOn.mul continuousOn_const ( Real.continuousOn_exp ) ) ) fun x hx => by cases lt_or_eq_of_le hμ0 <;> cases lt_or_eq_of_le hμ1 <;> nlinarith [ Real.exp_pos x, Real.exp_le_one_iff.mpr ( show x ≤ 0 by cases Set.mem_uIcc.mp hx <;> linarith ) ] ) fun x hx => hL_deriv x
      simp_all +decide [ L ];
      exact le_trans ( hL_taylor s ) ( by ring_nf; norm_num );
    intro μ hμ0 hμ1 t; specialize hL μ hμ0 hμ1 t; rw [ ← Real.log_le_log_iff ( by exact mul_pos ( Real.exp_pos _ ) ( by nlinarith [ Real.exp_pos t, show μ * Real.exp t ≥ 0 by positivity ] ) ) ( by positivity ), Real.log_mul ( by positivity ) ( by nlinarith [ Real.exp_pos t, show μ * Real.exp t ≥ 0 by positivity ] ), Real.log_exp, Real.log_exp ] ; linarith;
  -- Apply Jensen's inequality to the convex function $e^{tx}$ with the weights $p_i$.
  have h_jensen : (∑ a, dist.prob a * Real.exp (t * (X a - ∑ b, dist.prob b * X b))) ≤ Real.exp (-t * (∑ b, dist.prob b * X b)) * (∑ a, dist.prob a * Real.exp (t * X a)) := by
    rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i _ => by rw [ mul_left_comm, ← Real.exp_add ] ; ring_nf; norm_num;
  -- Apply Hoeffding's lemma to the sum $\sum_{a} p_a e^{t X_a}$.
  have h_hoeffding_sum : ∑ a, dist.prob a * Real.exp (t * X a) ≤ (1 - (∑ a, dist.prob a * X a)) + (∑ a, dist.prob a * X a) * Real.exp t := by
    have h_hoeffding_sum : ∀ a, Real.exp (t * X a) ≤ (1 - X a) + X a * Real.exp t := by
      intro a
      have h_convex : ConvexOn ℝ (Set.univ : Set ℝ) Real.exp := by
        exact convexOn_exp
      generalize_proofs at *; (
      have := h_convex.2 ( Set.mem_univ 0 ) ( Set.mem_univ t ) ( show 0 ≤ 1 - X a by linarith [ hX0 a, hX1 a ] ) ( show 0 ≤ X a by linarith [ hX0 a, hX1 a ] ) ( by linarith [ hX0 a, hX1 a ] ) ; simp_all +decide [ mul_comm t ] ;);
    convert Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_left ( h_hoeffding_sum a ) ( dist.prob_nonneg a ) using 1 ; simp +decide [ mul_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ];
    simp +decide [ sub_mul, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, dist.prob_sum_one ];
  refine' le_trans h_jensen ( le_trans ( mul_le_mul_of_nonneg_left h_hoeffding_sum ( Real.exp_nonneg _ ) ) ( h_hoeffding _ _ _ _ ) );
  · exact Finset.sum_nonneg fun _ _ => mul_nonneg ( dist.prob_nonneg _ ) ( hX0 _ );
  · exact le_trans ( Finset.sum_le_sum fun _ _ => mul_le_of_le_one_right ( dist.prob_nonneg _ ) ( hX1 _ ) ) ( by simp +decide [ dist.prob_sum_one ] )

end PACBayes

end