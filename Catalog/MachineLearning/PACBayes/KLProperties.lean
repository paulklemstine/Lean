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

/-! ## Finite distributions and the divergences used below

The three notions below (`FinDist`, `klFinDist`, `klBernoulli`) were used
throughout this file but were never defined in the project, so the file did not
elaborate.  They are the standard finitary definitions. -/

/-- A probability distribution on a finite type: a nonnegative weight function
summing to one. -/
structure FinDist (α : Type*) [Fintype α] where
  /-- The probability mass function. -/
  prob : α → ℝ
  /-- Probabilities are nonnegative. -/
  prob_nonneg : ∀ a, 0 ≤ prob a
  /-- Probabilities sum to one. -/
  prob_sum_one : ∑ a, prob a = 1

/-- Kullback–Leibler divergence `KL(Q ‖ P)` of two finite distributions, with the
usual convention `0 · log (0 / x) = 0`. -/
def klFinDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  ∑ a : α, if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)

/-- Kullback–Leibler divergence of two Bernoulli laws, `KL(Ber p ‖ Ber q)`,
with the convention `0 · log 0 = 0` at the two endpoints. -/
def klBernoulli (p q : ℝ) : ℝ :=
  if p = 0 then -Real.log (1 - q)
  else if p = 1 then -Real.log q
  else p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q))

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

/-! ## Ingredients for Pinsker's inequality

The two analytic facts below are the whole content of Pinsker's inequality: a
one-dimensional calculus estimate for the Bernoulli divergence (proved by the
mean value theorem, since the derivative of `q ↦ KL(p ‖ q) - 2 (p - q)²` is
`(q - p)(1/(q(1-q)) - 4)`, which has the sign of `q - p`), and the log-sum
inequality, which lets one collapse an arbitrary block of the alphabet to a
single Bernoulli coordinate. -/

/-- Endpoint estimate: `2 x² ≤ -log (1 - x)` on `[0, 1)`.  This is Pinsker's
inequality for the degenerate Bernoulli laws `Ber 0` and `Ber 1`. -/
theorem two_sq_le_neg_log_one_sub {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x < 1) :
    2 * x ^ 2 ≤ -Real.log (1 - x) := by
  rcases eq_or_lt_of_le hx0 with h | h
  · simp [← h]
  · set f : ℝ → ℝ := fun t => -Real.log (1 - t) - 2 * t ^ 2 with hf
    have hderiv : ∀ y ∈ Set.Ioo (0:ℝ) x, HasDerivAt f (1 / (1 - y) - 4 * y) y := by
      intro y hy
      have h1 : (1 : ℝ) - y ≠ 0 := by nlinarith [hy.1, hy.2]
      have hlog : HasDerivAt (fun t : ℝ => Real.log (1 - t)) (-1 / (1 - y)) y := by
        simpa using (((hasDerivAt_const y (1:ℝ)).sub (hasDerivAt_id y)).log h1)
      have hsq : HasDerivAt (fun t : ℝ => 2 * t ^ 2) (4 * y) y := by
        have h0 := (hasDerivAt_pow 2 y).const_mul (2:ℝ)
        convert h0 using 1
        norm_num
        ring
      have h2 := (hlog.neg).sub hsq
      convert h2 using 1
      field_simp
    have hcont : ContinuousOn f (Set.Icc 0 x) := by
      apply ContinuousOn.sub
      · apply ContinuousOn.neg
        apply ContinuousOn.log (by fun_prop)
        intro t ht
        have h1 := ht.1
        have h2 := ht.2
        nlinarith
      · fun_prop
    obtain ⟨c, hc, hslope⟩ := exists_hasDerivAt_eq_slope f _ h hcont hderiv
    have hc1 : c < 1 := lt_trans hc.2 hx1
    have h1c : 0 < 1 - c := by linarith
    have hpos : 0 ≤ 1 / (1 - c) - 4 * c := by
      rw [sub_nonneg, le_div_iff₀ h1c]
      nlinarith [sq_nonneg (1 - 2*c)]
    have hf0 : f 0 = 0 := by simp [hf]
    rw [hslope, hf0, sub_zero, sub_zero] at hpos
    have h3 : 0 ≤ f x / x * x := mul_nonneg hpos h.le
    rw [div_mul_cancel₀ _ (ne_of_gt h)] at h3
    simp only [hf] at h3
    linarith

/-- Interior estimate: the Bernoulli divergence dominates `2 (p - q)²` for
parameters strictly inside `(0, 1)`.  Proved by the mean value theorem applied to
`x ↦ KL(p ‖ x) - 2 (p - x)²`, whose derivative is
`(x - p)(1 - 2x)² / (x (1 - x))`. -/
theorem pinsker_core_interior {p q : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (hq0 : 0 < q) (hq1 : q < 1) :
    2 * (p - q) ^ 2 ≤
      p * (Real.log p - Real.log q) + (1 - p) * (Real.log (1 - p) - Real.log (1 - q)) := by
  set G : ℝ → ℝ := fun x =>
    p * (Real.log p - Real.log x) + (1 - p) * (Real.log (1 - p) - Real.log (1 - x))
      - 2 * (p - x) ^ 2 with hG
  have hGp : G p = 0 := by simp [hG]
  have hderiv : ∀ y : ℝ, 0 < y → y < 1 →
      HasDerivAt G (-(p / y) + (1 - p) / (1 - y) + 4 * (p - y)) y := by
    intro y hy0 hy1
    have hy : y ≠ 0 := ne_of_gt hy0
    have h1y : (1 : ℝ) - y ≠ 0 := by linarith
    have hlog1 : HasDerivAt (fun t : ℝ => Real.log t) (1 / y) y := by
      simpa [one_div] using (Real.hasDerivAt_log hy)
    have hlog2 : HasDerivAt (fun t : ℝ => Real.log (1 - t)) (-1 / (1 - y)) y := by
      simpa using (((hasDerivAt_const y (1:ℝ)).sub (hasDerivAt_id y)).log h1y)
    have d1 : HasDerivAt (fun x : ℝ => p * (Real.log p - Real.log x)) (p * (0 - 1 / y)) y :=
      (((hasDerivAt_const y (Real.log p)).sub hlog1).const_mul p)
    have d2 : HasDerivAt (fun x : ℝ => (1 - p) * (Real.log (1 - p) - Real.log (1 - x)))
        ((1 - p) * (0 - (-1 / (1 - y)))) y :=
      (((hasDerivAt_const y (Real.log (1 - p))).sub hlog2).const_mul (1 - p))
    have d3 : HasDerivAt (fun t : ℝ => 2 * (p - t) ^ 2) (-4 * (p - y)) y := by
      have h0 : HasDerivAt (fun t : ℝ => (p - t)) (-1) y := by
        simpa using (hasDerivAt_const y p).sub (hasDerivAt_id y)
      have h1 := (h0.pow 2).const_mul (2:ℝ)
      convert h1 using 1
      ring
    have h2 := (d1.add d2).sub d3
    convert h2 using 1
    field_simp
    ring
  have hcont : ∀ a b : ℝ, 0 < a → b < 1 → ContinuousOn G (Set.Icc a b) := by
    intro a b ha hb
    apply ContinuousOn.sub
    · apply ContinuousOn.add
      · apply ContinuousOn.mul continuousOn_const
        apply ContinuousOn.sub continuousOn_const
        apply ContinuousOn.log (by fun_prop)
        intro t ht
        have := ht.1
        linarith
      · apply ContinuousOn.mul continuousOn_const
        apply ContinuousOn.sub continuousOn_const
        apply ContinuousOn.log (by fun_prop)
        intro t ht
        have := ht.2
        intro hcon
        linarith [sub_eq_zero.mp hcon]
    · fun_prop
  have hsign : ∀ c : ℝ, 0 < c → c < 1 →
      -(p / c) + (1 - p) / (1 - c) + 4 * (p - c) = (c - p) * (1 - 2 * c) ^ 2 / (c * (1 - c)) := by
    intro c hc0 hc1
    have h1 : c ≠ 0 := ne_of_gt hc0
    have h2 : (1 : ℝ) - c ≠ 0 := by linarith
    field_simp
    ring
  have hGq : 0 ≤ G q := by
    rcases lt_trichotomy p q with h | h | h
    · obtain ⟨c, hc, hslope⟩ := exists_hasDerivAt_eq_slope G
        (fun y => -(p / y) + (1 - p) / (1 - y) + 4 * (p - y)) h
        (hcont p q hp0 hq1) (fun y hy => hderiv y (lt_trans hp0 hy.1) (lt_trans hy.2 hq1))
      have hc0 : 0 < c := lt_trans hp0 hc.1
      have hc1 : c < 1 := lt_trans hc.2 hq1
      have hnn : 0 ≤ -(p / c) + (1 - p) / (1 - c) + 4 * (p - c) := by
        rw [hsign c hc0 hc1]
        apply div_nonneg
        · have : 0 ≤ c - p := by linarith [hc.1]
          positivity
        · nlinarith
      rw [hslope, hGp, sub_zero] at hnn
      have hqp : 0 < q - p := by linarith
      have := mul_nonneg hnn hqp.le
      rwa [div_mul_cancel₀ _ (ne_of_gt hqp)] at this
    · rw [← h, hGp]
    · obtain ⟨c, hc, hslope⟩ := exists_hasDerivAt_eq_slope G
        (fun y => -(p / y) + (1 - p) / (1 - y) + 4 * (p - y)) h
        (hcont q p hq0 hp1) (fun y hy => hderiv y (lt_trans hq0 hy.1) (lt_trans hy.2 hp1))
      have hc0 : 0 < c := lt_trans hq0 hc.1
      have hc1 : c < 1 := lt_trans hc.2 hp1
      have hnp : -(p / c) + (1 - p) / (1 - c) + 4 * (p - c) ≤ 0 := by
        rw [hsign c hc0 hc1]
        apply div_nonpos_of_nonpos_of_nonneg
        · have : c - p ≤ 0 := by linarith [hc.2]
          nlinarith [sq_nonneg (1 - 2*c)]
        · nlinarith
      rw [hslope, hGp] at hnp
      have hpq : 0 < p - q := by linarith
      have := mul_nonpos_of_nonpos_of_nonneg hnp hpq.le
      rw [div_mul_cancel₀ _ (ne_of_gt hpq)] at this
      linarith
  simp only [hG] at hGq
  linarith

/-- `a log (a / b) = a (log a - log b)` for `a ≥ 0 < b`, including the convention
`0 · log 0 = 0`. -/
theorem mul_log_div_eq {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) :
    a * Real.log (a / b) = a * (Real.log a - Real.log b) := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [← h]
  · rw [Real.log_div (ne_of_gt h) (ne_of_gt hb)]

/-- Pinsker's inequality for Bernoulli laws, in expanded form: for `p ∈ [0,1]`
and `q ∈ (0,1)`, `2 (p - q)² ≤ KL(Ber p ‖ Ber q)`. -/
theorem pinsker_core {p q : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    2 * (p - q) ^ 2 ≤ p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q)) := by
  rw [mul_log_div_eq hp0 hq0,
    mul_log_div_eq (by linarith : (0:ℝ) ≤ 1 - p) (by linarith : (0:ℝ) < 1 - q)]
  rcases eq_or_lt_of_le hp0 with hp00 | hppos
  · rw [← hp00]
    have := two_sq_le_neg_log_one_sub (le_of_lt hq0) hq1
    simp
    linarith
  rcases eq_or_lt_of_le hp1 with hp11 | hplt
  · rw [hp11]
    have := two_sq_le_neg_log_one_sub (x := 1 - q) (by linarith) (by linarith)
    simp only [sub_sub_cancel] at this
    simp
    linarith
  · exact pinsker_core_interior hppos hplt hq0 hq1

/-- The log-sum inequality, in the form needed for the data-processing step of
Pinsker's inequality: lumping a block `s` of the alphabet into a single symbol
can only decrease the divergence. -/
theorem klFinDist_block_ge {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) (s : Finset α) :
    (∑ a ∈ s, Q.prob a) * Real.log ((∑ a ∈ s, Q.prob a) / (∑ a ∈ s, P.prob a)) ≤
      ∑ a ∈ s, (if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)) := by
  classical
  set F := ∑ a ∈ s, Q.prob a with hF
  set G := ∑ a ∈ s, P.prob a with hGdef
  have hFnn : 0 ≤ F := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
  have hGnn : 0 ≤ G := Finset.sum_nonneg fun a _ => P.prob_nonneg a
  rcases eq_or_lt_of_le hFnn with hF0 | hFpos
  · have hz : ∀ a ∈ s, Q.prob a = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun a _ => Q.prob_nonneg a)).mp hF0.symm
    have hzero :
        ∑ a ∈ s, (if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)) = 0 :=
      Finset.sum_eq_zero fun a ha => by simp [hz a ha]
    rw [hzero, ← hF0]
    simp
  · have hGpos : 0 < G := by
      rcases eq_or_lt_of_le hGnn with hG0 | h
      · exfalso
        have hz : ∀ a ∈ s, P.prob a = 0 :=
          (Finset.sum_eq_zero_iff_of_nonneg (fun a _ => P.prob_nonneg a)).mp hG0.symm
        have : F = 0 := Finset.sum_eq_zero fun a ha => hac a (hz a ha)
        linarith
      · exact h
    have key : ∀ a ∈ s, Q.prob a - P.prob a * (F / G) ≤
        (if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a))
          - Q.prob a * Real.log (F / G) := by
      intro a ha
      by_cases h : Q.prob a = 0
      · simp only [h, if_pos, zero_sub, zero_mul, sub_zero]
        have : 0 ≤ P.prob a * (F / G) :=
          mul_nonneg (P.prob_nonneg a) (div_nonneg hFnn hGnn)
        linarith
      · have hQa : 0 < Q.prob a := lt_of_le_of_ne (Q.prob_nonneg a) (Ne.symm h)
        have hPa : 0 < P.prob a := lt_of_le_of_ne (P.prob_nonneg a)
          (fun hc => h (hac a hc.symm))
        set u : ℝ := (Q.prob a / P.prob a) / (F / G) with hu
        have hupos : 0 < u := div_pos (div_pos hQa hPa) (div_pos hFpos hGpos)
        have hlogu : Real.log u = Real.log (Q.prob a / P.prob a) - Real.log (F / G) :=
          Real.log_div (ne_of_gt (div_pos hQa hPa)) (ne_of_gt (div_pos hFpos hGpos))
        have hlow : 1 - 1 / u ≤ Real.log u := by
          have h1 := Real.log_le_sub_one_of_pos (show (0:ℝ) < 1 / u by positivity)
          rw [Real.log_div one_ne_zero (ne_of_gt hupos), Real.log_one] at h1
          linarith
        have hmul := mul_le_mul_of_nonneg_left hlow hQa.le
        have hcancel : Q.prob a * (1 / u) = P.prob a * (F / G) := by
          rw [hu]
          field_simp
        simp only [if_neg h]
        rw [hlogu] at hmul
        nlinarith [hmul, hcancel]
    have hsum := Finset.sum_le_sum key
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_mul] at hsum
    rw [← hF, ← hGdef] at hsum
    have hGF : G * (F / G) = F := by field_simp
    rw [hGF] at hsum
    linarith

/-! ## Pinsker's Inequality -/

/-- Total variation distance between two finite distributions. -/
def tvDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  (∑ a : α, |Q.prob a - P.prob a|) / 2

/-- Pinsker's inequality: TV(Q, P)² ≤ KL(Q ‖ P) / 2.
    This converts KL control into uniform probability control.
    The proof is the classical two-step argument: the log-sum inequality
    (`klFinDist_block_ge`) collapses the alphabet along the set where `Q ≥ P`,
    reducing the claim to the Bernoulli case (`pinsker_core`). -/
theorem pinsker_inequality {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    tvDist Q P ^ 2 ≤ klFinDist Q P / 2 := by
  classical
  set A : Finset α := Finset.univ.filter (fun a => P.prob a ≤ Q.prob a) with hAdef
  set B : Finset α := Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a) with hBdef
  set p : ℝ := ∑ a ∈ A, Q.prob a with hp
  set q : ℝ := ∑ a ∈ A, P.prob a with hq
  have hQsplit : p + ∑ a ∈ B, Q.prob a = 1 := by
    rw [hp, hAdef, hBdef, Finset.sum_filter_add_sum_filter_not]
    exact Q.prob_sum_one
  have hPsplit : q + ∑ a ∈ B, P.prob a = 1 := by
    rw [hq, hAdef, hBdef, Finset.sum_filter_add_sum_filter_not]
    exact P.prob_sum_one
  have hQB : ∑ a ∈ B, Q.prob a = 1 - p := by linarith
  have hPB : ∑ a ∈ B, P.prob a = 1 - q := by linarith
  have htv : tvDist Q P = p - q := by
    have hsplit : (∑ a ∈ A, |Q.prob a - P.prob a|) + (∑ a ∈ B, |Q.prob a - P.prob a|)
        = ∑ a : α, |Q.prob a - P.prob a| := by
      rw [hAdef, hBdef, Finset.sum_filter_add_sum_filter_not]
    have hA1 : (∑ a ∈ A, |Q.prob a - P.prob a|) = p - q := by
      rw [← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a ha => ?_
      have : P.prob a ≤ Q.prob a := by
        rw [hAdef] at ha; exact (Finset.mem_filter.mp ha).2
      exact abs_of_nonneg (by linarith)
    have hB1 : (∑ a ∈ B, |Q.prob a - P.prob a|) = (1 - q) - (1 - p) := by
      rw [← hPB, ← hQB, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a ha => ?_
      have : ¬ P.prob a ≤ Q.prob a := by
        rw [hBdef] at ha; exact (Finset.mem_filter.mp ha).2
      push_neg at this
      rw [abs_of_nonpos (by linarith)]
      ring
    unfold tvDist
    rw [← hsplit, hA1, hB1]
    ring
  have hkl : klFinDist Q P
      = (∑ a ∈ A, (if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)))
        + ∑ a ∈ B, (if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)) := by
    rw [hAdef, hBdef, Finset.sum_filter_add_sum_filter_not]
    rfl
  have hq0 : 0 ≤ q := Finset.sum_nonneg fun a _ => P.prob_nonneg a
  have hq1 : q ≤ 1 := by
    have : 0 ≤ ∑ a ∈ B, P.prob a := Finset.sum_nonneg fun a _ => P.prob_nonneg a
    linarith
  have hp0 : 0 ≤ p := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
  have hp1 : p ≤ 1 := by
    have : 0 ≤ ∑ a ∈ B, Q.prob a := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
    linarith
  rcases eq_or_lt_of_le hq0 with hq00 | hq0pos
  · have hz : ∀ a ∈ A, P.prob a = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun a _ => P.prob_nonneg a)).mp hq00.symm
    have hp00 : p = 0 := Finset.sum_eq_zero fun a ha => hac a (hz a ha)
    have htv0 : tvDist Q P = 0 := by rw [htv, hp00, ← hq00]; ring
    rw [htv0]
    have := klFinDist_nonneg Q P hac
    simp
    linarith
  rcases eq_or_lt_of_le hq1 with hq11 | hq1lt
  · have hPB0 : ∑ a ∈ B, P.prob a = 0 := by rw [hPB, hq11]; ring
    have hz : ∀ a ∈ B, P.prob a = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun a _ => P.prob_nonneg a)).mp hPB0
    have hQB0 : ∑ a ∈ B, Q.prob a = 0 := Finset.sum_eq_zero fun a ha => hac a (hz a ha)
    have hp11 : p = 1 := by rw [hQB] at hQB0; linarith
    have htv0 : tvDist Q P = 0 := by rw [htv, hp11, hq11]; ring
    rw [htv0]
    have := klFinDist_nonneg Q P hac
    simp
    linarith
  · have hA' := klFinDist_block_ge Q P hac A
    have hB' := klFinDist_block_ge Q P hac B
    rw [hQB, hPB] at hB'
    rw [← hp, ← hq] at hA'
    have hcore := pinsker_core hp0 hp1 hq0pos hq1lt
    rw [htv, hkl]
    nlinarith [hA', hB', hcore]

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
  have hexp : klBernoulli p q
      = p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q)) := by
    unfold klBernoulli
    split_ifs with h0 h1
    · subst h0
      simp [Real.log_div one_ne_zero (by linarith : (1:ℝ) - q ≠ 0)]
    · subst h1
      simp [Real.log_div one_ne_zero (ne_of_gt hq0)]
    · rfl
  rw [hexp]
  have := pinsker_core hp0 hp1 hq0 hq1
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