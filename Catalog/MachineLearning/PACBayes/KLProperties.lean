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
import Logic.GraphTheory.Defs

open Real BigOperators Finset

noncomputable section

namespace PACBayes

/-! ## Basic objects

The definitions the results of this file are stated in terms of: a probability
distribution on a finite type, the discrete KL divergence (with the usual convention
`0 * log 0 = 0`, implemented by the `if Q.prob a = 0` guard), and the Bernoulli KL.
-/

/-- A probability distribution on a finite type. -/
structure FinDist (α : Type*) [Fintype α] where
  /-- The probability mass function. -/
  prob : α → ℝ
  /-- Probabilities are nonnegative. -/
  prob_nonneg : ∀ a, 0 ≤ prob a
  /-- Probabilities sum to one. -/
  prob_sum_one : ∑ a, prob a = 1

/-- Kullback–Leibler divergence `KL(Q ‖ P)` of two finite distributions, with the
convention `0 * log (0 / x) = 0`. -/
def klFinDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  ∑ a, if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)

/-- KL divergence between the Bernoulli laws `Ber p` and `Ber q`, with the convention
`0 * log 0 = 0` spelled out in the two degenerate branches. -/
def klBernoulli (p q : ℝ) : ℝ :=
  if p = 0 then -Real.log (1 - q)
  else if p = 1 then -Real.log q
  else p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q))

/-! ## Analytic ingredients of Pinsker's inequality -/

/-- The scalar inequality `2x² ≤ -log (1 - x)` on `[0, 1)`, proved by showing that
`x ↦ -log (1 - x) - 2x²` has nonnegative derivative `(1 - 2x)²/(1 - x)`. -/
theorem two_sq_le_neg_log_one_sub {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x < 1) :
    2 * x ^ 2 ≤ -Real.log (1 - x) := by
  set f : ℝ → ℝ := fun t => -Real.log (1 - t) - 2 * t ^ 2 with hf
  have hderiv : ∀ t : ℝ, t < 1 → HasDerivAt f (1 / (1 - t) - 4 * t) t := by
    intro t ht
    have h1 : (1 : ℝ) - t ≠ 0 := by linarith
    have h2 : HasDerivAt (fun t : ℝ => 1 - t) (-1) t := by
      simpa using (hasDerivAt_id t).const_sub 1
    have h3 : HasDerivAt (fun t : ℝ => Real.log (1 - t)) (-1 / (1 - t)) t := h2.log h1
    have h4 : HasDerivAt (fun t : ℝ => 2 * t ^ 2) (4 * t) t := by
      have := (hasDerivAt_pow 2 t).const_mul (2 : ℝ)
      convert this using 1
      ring
    have := (h3.neg).sub h4
    convert this using 1
    field_simp
  have hmono : MonotoneOn f (Set.Ico (0 : ℝ) 1) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ico 0 1)
    · intro t ht
      exact ((hderiv t ht.2).continuousAt).continuousWithinAt
    · intro t ht
      rw [interior_Ico] at ht
      exact (hderiv t ht.2).differentiableAt.differentiableWithinAt
    · intro t ht
      rw [interior_Ico] at ht
      rw [(hderiv t ht.2).deriv]
      have h1 : (0 : ℝ) < 1 - t := by linarith [ht.2]
      rw [sub_nonneg, le_div_iff₀ h1]
      nlinarith [sq_nonneg (1 - 2 * t)]
  have := hmono (Set.mem_Ico.mpr ⟨le_refl 0, by norm_num⟩) (Set.mem_Ico.mpr ⟨hx0, hx1⟩) hx0
  simp [hf] at this
  linarith

/-- Pinsker's inequality for two Bernoulli laws with parameters strictly inside `(0,1)`,
in the additive form.  The proof is a monotonicity argument for
`t ↦ -p log t - (1-p) log (1-t) - 2(p-t)²`, whose derivative is
`(t - p) (1/(t(1-t)) - 4)`. -/
theorem pinsker_core_interior {p q : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    (hq0 : 0 < q) (hq1 : q < 1) :
    2 * (p - q) ^ 2 ≤
      p * (Real.log p - Real.log q) + (1 - p) * (Real.log (1 - p) - Real.log (1 - q)) := by
  set g : ℝ → ℝ := fun t => -(p * Real.log t) - (1 - p) * Real.log (1 - t) - 2 * (p - t) ^ 2
    with hg
  have hderiv : ∀ t : ℝ, 0 < t → t < 1 →
      HasDerivAt g (-p / t + (1 - p) / (1 - t) + 4 * (p - t)) t := by
    intro t ht0 ht1
    have hne0 : t ≠ 0 := ne_of_gt ht0
    have hne1 : (1 : ℝ) - t ≠ 0 := by intro h; linarith [sub_eq_zero.mp h]
    have hlog1 : HasDerivAt (fun t : ℝ => Real.log t) (1 / t) t := by
      simpa [one_div] using Real.hasDerivAt_log hne0
    have hlog2 : HasDerivAt (fun t : ℝ => Real.log (1 - t)) (-1 / (1 - t)) t :=
      (by simpa using (hasDerivAt_id t).const_sub 1 :
        HasDerivAt (fun t : ℝ => 1 - t) (-1) t).log hne1
    have hA : HasDerivAt (fun t : ℝ => -(p * Real.log t)) (-p / t) t := by
      have := (hlog1.const_mul p).neg
      convert this using 1
      field_simp
    have hB : HasDerivAt (fun t : ℝ => (1 - p) * Real.log (1 - t)) (-(1 - p) / (1 - t)) t := by
      have := hlog2.const_mul (1 - p)
      convert this using 1
      field_simp
    have hC : HasDerivAt (fun t : ℝ => 2 * (p - t) ^ 2) (-4 * (p - t)) t := by
      have h := ((hasDerivAt_id t).const_sub p)
      have := (h.pow 2).const_mul (2 : ℝ)
      simp only [id_eq] at this
      convert this using 1
      ring
    have := (hA.sub hB).sub hC
    convert this using 1
    field_simp
    ring
  have hkey : ∀ t : ℝ, 0 < t → t < 1 → -p / t + (1 - p) / (1 - t) = (t - p) / (t * (1 - t)) := by
    intro t ht0 ht1
    have hne0 : t ≠ 0 := ne_of_gt ht0
    have hne1 : (1 : ℝ) - t ≠ 0 := by intro h; linarith [sub_eq_zero.mp h]
    field_simp
    ring
  have main : g p ≤ g q := by
    rcases le_total p q with h | h
    · have hmono : MonotoneOn g (Set.Icc p q) := by
        apply monotoneOn_of_deriv_nonneg (convex_Icc p q)
        · intro t ht
          exact ((hderiv t (lt_of_lt_of_le hp0 ht.1)
            (lt_of_le_of_lt ht.2 hq1)).continuousAt).continuousWithinAt
        · intro t ht
          rw [interior_Icc] at ht
          exact (hderiv t (lt_trans hp0 ht.1)
            (lt_trans ht.2 hq1)).differentiableAt.differentiableWithinAt
        · intro t ht
          rw [interior_Icc] at ht
          have ht0 : 0 < t := lt_trans hp0 ht.1
          have ht1 : t < 1 := lt_trans ht.2 hq1
          rw [(hderiv t ht0 ht1).deriv, hkey t ht0 ht1]
          have hd : 0 < t * (1 - t) := by nlinarith
          have h2 : 0 ≤ t - p := by linarith [ht.1]
          have h3 : 4 * (t - p) ≤ (t - p) / (t * (1 - t)) := by
            rw [le_div_iff₀ hd]
            nlinarith [sq_nonneg (1 - 2 * t)]
          linarith
      exact hmono (Set.left_mem_Icc.mpr h) (Set.right_mem_Icc.mpr h) h
    · have hanti : AntitoneOn g (Set.Icc q p) := by
        apply antitoneOn_of_deriv_nonpos (convex_Icc q p)
        · intro t ht
          exact ((hderiv t (lt_of_lt_of_le hq0 ht.1)
            (lt_of_le_of_lt ht.2 hp1)).continuousAt).continuousWithinAt
        · intro t ht
          rw [interior_Icc] at ht
          exact (hderiv t (lt_trans hq0 ht.1)
            (lt_trans ht.2 hp1)).differentiableAt.differentiableWithinAt
        · intro t ht
          rw [interior_Icc] at ht
          have ht0 : 0 < t := lt_trans hq0 ht.1
          have ht1 : t < 1 := lt_trans ht.2 hp1
          rw [(hderiv t ht0 ht1).deriv, hkey t ht0 ht1]
          have hd : 0 < t * (1 - t) := by nlinarith
          have h2 : t - p ≤ 0 := by linarith [ht.2]
          have h3 : (t - p) / (t * (1 - t)) ≤ 4 * (t - p) := by
            rw [div_le_iff₀ hd]
            nlinarith [sq_nonneg (1 - 2 * t)]
          linarith
      exact hanti (Set.left_mem_Icc.mpr h) (Set.right_mem_Icc.mpr h) h
  simp only [hg] at main
  nlinarith [main]

/-- Pinsker's inequality for Bernoulli laws, allowing the degenerate values `p = 0`
and `p = 1`. -/
theorem pinsker_core {p q : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    2 * (p - q) ^ 2 ≤ p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q)) := by
  rcases eq_or_lt_of_le hp0 with hp | hp
  · subst_vars
    have hlem := two_sq_le_neg_log_one_sub (le_of_lt hq0) hq1
    have hlog : Real.log (((1 : ℝ) - 0) / (1 - q)) = -Real.log (1 - q) := by
      rw [sub_zero, one_div, Real.log_inv]
    rw [hlog]
    simp
    nlinarith
  · rcases eq_or_lt_of_le hp1 with hp' | hp'
    · subst hp'
      have hlem := two_sq_le_neg_log_one_sub (by linarith : (0 : ℝ) ≤ 1 - q)
        (by linarith : 1 - q < 1)
      simp only [sub_self, Real.log_zero, mul_zero, add_zero, one_mul]
      rw [show (1 : ℝ) - (1 - q) = q by ring] at hlem
      rw [Real.log_div one_ne_zero (ne_of_gt hq0)]
      simp
      linarith
    · have h1 : (0 : ℝ) < 1 - p := by linarith
      rw [Real.log_div (ne_of_gt hp) (ne_of_gt hq0),
          Real.log_div (ne_of_gt h1) (by linarith : (1 : ℝ) - q ≠ 0)]
      exact pinsker_core_interior hp hp' hq0 hq1

/-- The log-sum inequality: `(∑ Q) log ((∑ Q)/(∑ P)) ≤ ∑ Q log (Q/P)`, with the
`0 log 0 = 0` convention.  Proved from `log x ≥ 1 - 1/x`. -/
theorem log_sum_ineq {α : Type*} (s : Finset α) (Q P : α → ℝ)
    (hQ : ∀ a, 0 ≤ Q a) (hP : ∀ a, 0 ≤ P a)
    (hac : ∀ a, P a = 0 → Q a = 0) (hPs : 0 < ∑ a ∈ s, P a) :
    (∑ a ∈ s, Q a) * Real.log ((∑ a ∈ s, Q a) / (∑ a ∈ s, P a)) ≤
      ∑ a ∈ s, (if Q a = 0 then 0 else Q a * Real.log (Q a / P a)) := by
  set QA := ∑ a ∈ s, Q a with hQA
  set PA := ∑ a ∈ s, P a with hPA
  have hQA0 : 0 ≤ QA := Finset.sum_nonneg fun a _ => hQ a
  rcases eq_or_lt_of_le hQA0 with hz | hpos
  · have hall : ∀ a ∈ s, Q a = 0 := fun a ha =>
      (Finset.sum_eq_zero_iff_of_nonneg (fun a _ => hQ a)).mp hz.symm a ha
    rw [← hz]
    simp only [zero_mul]
    exact Finset.sum_nonneg fun a ha => by rw [if_pos (hall a ha)]
  · have hstep : ∀ a ∈ s, Q a * Real.log (QA / PA) + Q a - P a * (QA / PA) ≤
        (if Q a = 0 then 0 else Q a * Real.log (Q a / P a)) := by
      intro a _
      by_cases hqa : Q a = 0
      · rw [if_pos hqa, hqa]
        have : 0 ≤ P a * (QA / PA) := mul_nonneg (hP a) (div_nonneg hQA0 hPs.le)
        simp
        linarith
      · rw [if_neg hqa]
        have hqa' : 0 < Q a := lt_of_le_of_ne (hQ a) (Ne.symm hqa)
        have hpa' : 0 < P a := lt_of_le_of_ne (hP a) (fun h => hqa (hac a h.symm))
        have hlog : Real.log (Q a / P a) - Real.log (QA / PA)
            = Real.log ((Q a * PA) / (P a * QA)) := by
          rw [Real.log_div (ne_of_gt hqa') (ne_of_gt hpa'),
            Real.log_div (ne_of_gt hpos) (ne_of_gt hPs),
            Real.log_div (by positivity) (by positivity),
            Real.log_mul (ne_of_gt hqa') (ne_of_gt hPs),
            Real.log_mul (ne_of_gt hpa') (ne_of_gt hpos)]
          ring
        have hineq : 1 - (P a * QA) / (Q a * PA) ≤ Real.log ((Q a * PA) / (P a * QA)) := by
          have := Real.log_le_sub_one_of_pos
            (show 0 < ((Q a * PA) / (P a * QA))⁻¹ by positivity)
          rw [Real.log_inv, inv_div] at this
          linarith
        have hmul := mul_le_mul_of_nonneg_left hineq hqa'.le
        have hQPa : Q a * ((P a * QA) / (Q a * PA)) = P a * (QA / PA) := by
          field_simp
        nlinarith [hlog, hmul, hQPa]
    have hsum := Finset.sum_le_sum hstep
    have hL : ∑ a ∈ s, (Q a * Real.log (QA / PA) + Q a - P a * (QA / PA))
        = QA * Real.log (QA / PA) := by
      rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.sum_mul,
        ← hQA, ← hPA]
      have hcancel : PA * (QA / PA) = QA := by field_simp
      rw [hcancel]
      ring
    linarith [hL ▸ hsum]

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
    The proof reduces to the Bernoulli case by the log-sum inequality applied to the
    set `{P ≤ Q}` and its complement (the data-processing step), and then applies the
    scalar Bernoulli Pinsker bound `pinsker_core`. -/
theorem pinsker_inequality {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    tvDist Q P ^ 2 ≤ klFinDist Q P / 2 := by
  classical
  set B : Finset α := Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a) with hB
  set A : Finset α := Finset.univ.filter (fun a => P.prob a ≤ Q.prob a) with hA
  set QA := ∑ a ∈ A, Q.prob a with hQA
  set PA := ∑ a ∈ A, P.prob a with hPA
  set QB := ∑ a ∈ B, Q.prob a with hQB
  set PB := ∑ a ∈ B, P.prob a with hPB
  have hQsplit : QA + QB = 1 := by
    rw [hQA, hQB, hA, hB, Finset.sum_filter_add_sum_filter_not]; exact Q.prob_sum_one
  have hPsplit : PA + PB = 1 := by
    rw [hPA, hPB, hA, hB, Finset.sum_filter_add_sum_filter_not]; exact P.prob_sum_one
  have hQAnn : 0 ≤ QA := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
  have hQBnn : 0 ≤ QB := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
  have hPAnn : 0 ≤ PA := Finset.sum_nonneg fun a _ => P.prob_nonneg a
  have hPBnn : 0 ≤ PB := Finset.sum_nonneg fun a _ => P.prob_nonneg a
  have htv : tvDist Q P = QA - PA := by
    have h1 : ∑ a ∈ A, |Q.prob a - P.prob a| = QA - PA := by
      rw [hQA, hPA, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a ha => ?_
      rw [hA, Finset.mem_filter] at ha
      exact abs_of_nonneg (by linarith [ha.2])
    have h2 : ∑ a ∈ B, |Q.prob a - P.prob a| = PB - QB := by
      rw [hQB, hPB, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a ha => ?_
      rw [hB, Finset.mem_filter] at ha
      rw [abs_of_nonpos (by linarith [not_le.mp ha.2])]; ring
    have hsplit : ∑ a : α, |Q.prob a - P.prob a|
        = ∑ a ∈ A, |Q.prob a - P.prob a| + ∑ a ∈ B, |Q.prob a - P.prob a| := by
      rw [hA, hB, Finset.sum_filter_add_sum_filter_not]
    rw [tvDist, hsplit, h1, h2, show PB - QB = QA - PA by linarith]
    ring
  have hKLsplit : klFinDist Q P
      = (∑ a ∈ A, if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a))
        + ∑ a ∈ B, (if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)) := by
    rw [klFinDist, hA, hB, Finset.sum_filter_add_sum_filter_not]
  rcases eq_or_lt_of_le hPAnn with hPA0 | hPApos
  · have hzeroA : ∀ a ∈ A, Q.prob a = 0 := fun a ha =>
      hac a ((Finset.sum_eq_zero_iff_of_nonneg (fun a _ => P.prob_nonneg a)).mp hPA0.symm a ha)
    have hQA0 : QA = 0 := Finset.sum_eq_zero hzeroA
    rw [htv, hQA0, ← hPA0]
    simpa using (by linarith [klFinDist_nonneg Q P hac] : (0 : ℝ) ≤ klFinDist Q P / 2)
  · rcases eq_or_lt_of_le hPBnn with hPB0 | hPBpos
    · have hzeroB : ∀ a ∈ B, Q.prob a = 0 := fun a ha =>
        hac a ((Finset.sum_eq_zero_iff_of_nonneg (fun a _ => P.prob_nonneg a)).mp hPB0.symm a ha)
      have hQB0 : QB = 0 := Finset.sum_eq_zero hzeroB
      have hzero : QA - PA = 0 := by linarith
      rw [htv, hzero]
      simpa using (by linarith [klFinDist_nonneg Q P hac] : (0 : ℝ) ≤ klFinDist Q P / 2)
    · have hlsA := log_sum_ineq A Q.prob P.prob Q.prob_nonneg P.prob_nonneg hac
        (by rw [← hPA]; exact hPApos)
      have hlsB := log_sum_ineq B Q.prob P.prob Q.prob_nonneg P.prob_nonneg hac
        (by rw [← hPB]; exact hPBpos)
      rw [← hQA, ← hPA] at hlsA
      rw [← hQB, ← hPB] at hlsB
      have hcore := pinsker_core (p := QA) (q := PA) hQAnn (by linarith) hPApos (by linarith)
      rw [show (1 : ℝ) - QA = QB by linarith, show (1 : ℝ) - PA = PB by linarith] at hcore
      rw [htv, hKLsplit]
      nlinarith [hcore, hlsA, hlsB]

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
  unfold klBernoulli
  split_ifs with h0 h1
  · subst h0
    have := two_sq_le_neg_log_one_sub (le_of_lt hq0) hq1
    nlinarith
  · subst h1
    have := two_sq_le_neg_log_one_sub (by linarith : (0 : ℝ) ≤ 1 - q) (by linarith : 1 - q < 1)
    rw [show (1 : ℝ) - (1 - q) = q by ring] at this
    nlinarith
  · have := pinsker_core hp0 hp1 hq0 hq1
    linarith

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