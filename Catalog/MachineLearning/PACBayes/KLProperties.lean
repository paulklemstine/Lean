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

/-! ## Section 0: the objects of the theory

The three objects used throughout this file (`FinDist`, `klFinDist`, `klBernoulli`) were
referenced but were missing from the project, so the file did not elaborate.  They are
supplied here with the conventions the rest of the file uses:

* a `FinDist α` is a probability vector on a fintype `α`;
* `klFinDist Q P = ∑ a, Q a * log (Q a / P a)`, with the summand replaced by `0` where
  `Q a = 0` (this is only a cosmetic guard: `0 * log (0 / P a) = 0` anyway);
* `klBernoulli p q = p * log (p/q) + (1-p) * log ((1-p)/(1-q))`, which by the Lean
  convention `log 0 = 0` already encodes `0 log 0 = 0` at the endpoints `p ∈ {0,1}`.
-/

/-- A probability distribution on a finite type. -/
structure FinDist (α : Type*) [Fintype α] where
  /-- The probability mass function. -/
  prob : α → ℝ
  /-- Masses are nonnegative. -/
  prob_nonneg : ∀ a, 0 ≤ prob a
  /-- The masses sum to one. -/
  prob_sum_one : ∑ a, prob a = 1

/-- The Kullback–Leibler divergence `KL(Q ‖ P)` of two distributions on a finite type. -/
def klFinDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  ∑ a, if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)

/-- The Kullback–Leibler divergence of two Bernoulli distributions,
`KL(Ber p ‖ Ber q) = p log (p/q) + (1-p) log ((1-p)/(1-q))`. -/
def klBernoulli (p q : ℝ) : ℝ :=
  p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q))

/-- The `if`-guard in `klFinDist` is cosmetic: the guarded summand vanishes anyway. -/
theorem klFinDist_eq_sum {α : Type*} [Fintype α] (Q P : FinDist α) :
    klFinDist Q P = ∑ a, Q.prob a * Real.log (Q.prob a / P.prob a) := by
  refine Finset.sum_congr rfl fun a _ => ?_
  by_cases h : Q.prob a = 0 <;> simp [h]

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

/-! ### The one-dimensional ingredients of Pinsker's inequality

The route taken here is the classical Csiszár reduction:

1. a calculus lemma (`klAux`, `klAux_mono`, `klAux_anti`) showing that
   `x ↦ KL(Ber p ‖ Ber x) − 2 (p − x)²` is minimised at `x = p`, which is the binary
   Pinsker inequality `bernoulli_pinsker`;
2. the log-sum inequality on a block (`log_sum_block`), proved pointwise from
   `log t ≥ 1 − 1/t`;
3. contraction onto the two-point partition `{P ≤ Q}` / `{Q < P}`, on which the total
   variation distance is exactly the difference of the two block masses.
-/

/-- The auxiliary function `x ↦ −p log x − (1−p) log (1−x) − 2 (p−x)²`, which differs from
`x ↦ KL(Ber p ‖ Ber x) − 2 (p − x)²` by the constant `−(p log p + (1−p) log (1−p))`. -/
def klAux (p x : ℝ) : ℝ :=
  -(p * Real.log x) - (1 - p) * Real.log (1 - x) - 2 * (p - x) ^ 2

/-- The derivative of `klAux p` at an interior point of `(0,1)`. -/
theorem klAux_hasDerivAt (p x : ℝ) (hx0 : 0 < x) (hx1 : x < 1) :
    HasDerivAt (klAux p) (-(p / x) + (1 - p) / (1 - x) + 4 * (p - x)) x := by
  have h1 : HasDerivAt (fun y : ℝ => Real.log y) (1 / x) x := by
    simpa [one_div] using Real.hasDerivAt_log (ne_of_gt hx0)
  have h2 : HasDerivAt (fun y : ℝ => Real.log (1 - y)) (-(1 / (1 - x))) x := by
    have hb : HasDerivAt (fun y : ℝ => 1 - y) (-1) x := by
      simpa using (hasDerivAt_id x).const_sub 1
    have := (Real.hasDerivAt_log (by linarith : (1:ℝ) - x ≠ 0)).comp x hb
    simpa [mul_comm, one_div] using this
  have h3 : HasDerivAt (fun y : ℝ => 2 * (p - y) ^ 2) (2 * (2 * (p - x) * (-1))) x := by
    have hb : HasDerivAt (fun y : ℝ => (p - y) ^ 2) (2 * (p - x) * (-1)) x := by
      have hc : HasDerivAt (fun y : ℝ => p - y) (-1) x := by
        simpa using (hasDerivAt_id x).const_sub p
      simpa using hc.pow 2
    simpa using hb.const_mul (2:ℝ)
  have := ((h1.const_mul p).neg.sub (h2.const_mul (1 - p))).sub h3
  convert this using 1
  field_simp
  ring

/-- `klAux p` is nondecreasing to the right of `p`. -/
theorem klAux_mono (p a b : ℝ) (ha : 0 < a) (hb : b < 1) (hpa : p ≤ a) (hab : a ≤ b) :
    klAux p a ≤ klAux p b := by
  have hsub : Set.Icc a b ⊆ Set.Ioo (0:ℝ) 1 := fun x hx =>
    ⟨lt_of_lt_of_le ha hx.1, lt_of_le_of_lt hx.2 hb⟩
  have hmono : MonotoneOn (klAux p) (Set.Icc a b) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc a b)
    · intro x hx
      have hx' := hsub hx
      exact ((klAux_hasDerivAt p x hx'.1 hx'.2).continuousAt).continuousWithinAt
    · intro x hx
      rw [interior_Icc] at hx
      have hx' : x ∈ Set.Ioo (0:ℝ) 1 := hsub (Set.Ioo_subset_Icc_self hx)
      exact (klAux_hasDerivAt p x hx'.1 hx'.2).differentiableAt.differentiableWithinAt
    · intro x hx
      rw [interior_Icc] at hx
      have hx' : x ∈ Set.Ioo (0:ℝ) 1 := hsub (Set.Ioo_subset_Icc_self hx)
      rw [(klAux_hasDerivAt p x hx'.1 hx'.2).deriv]
      have hxp : p ≤ x := le_trans hpa (le_of_lt hx.1)
      have h0 : 0 < x := hx'.1
      have h1 : 0 < 1 - x := by linarith [hx'.2]
      have e : -(p / x) + (1 - p) / (1 - x) + 4 * (p - x)
          = ((x - p) * (1 - 2 * x) ^ 2) / (x * (1 - x)) := by
        field_simp; ring
      rw [e]
      exact div_nonneg (mul_nonneg (by linarith) (sq_nonneg _)) (le_of_lt (mul_pos h0 h1))
  exact hmono (Set.left_mem_Icc.2 hab) (Set.right_mem_Icc.2 hab) hab

/-- `klAux p` is nonincreasing to the left of `p`. -/
theorem klAux_anti (p a b : ℝ) (ha : 0 < a) (hb : b < 1) (hbp : b ≤ p) (hab : a ≤ b) :
    klAux p b ≤ klAux p a := by
  have hsub : Set.Icc a b ⊆ Set.Ioo (0:ℝ) 1 := fun x hx =>
    ⟨lt_of_lt_of_le ha hx.1, lt_of_le_of_lt hx.2 hb⟩
  have hanti : AntitoneOn (klAux p) (Set.Icc a b) := by
    apply antitoneOn_of_deriv_nonpos (convex_Icc a b)
    · intro x hx
      have hx' := hsub hx
      exact ((klAux_hasDerivAt p x hx'.1 hx'.2).continuousAt).continuousWithinAt
    · intro x hx
      rw [interior_Icc] at hx
      have hx' : x ∈ Set.Ioo (0:ℝ) 1 := hsub (Set.Ioo_subset_Icc_self hx)
      exact (klAux_hasDerivAt p x hx'.1 hx'.2).differentiableAt.differentiableWithinAt
    · intro x hx
      rw [interior_Icc] at hx
      have hx' : x ∈ Set.Ioo (0:ℝ) 1 := hsub (Set.Ioo_subset_Icc_self hx)
      rw [(klAux_hasDerivAt p x hx'.1 hx'.2).deriv]
      have hxp : x ≤ p := le_trans (le_of_lt hx.2) hbp
      have h0 : 0 < x := hx'.1
      have h1 : 0 < 1 - x := by linarith [hx'.2]
      have e : -(p / x) + (1 - p) / (1 - x) + 4 * (p - x)
          = ((x - p) * (1 - 2 * x) ^ 2) / (x * (1 - x)) := by
        field_simp; ring
      rw [e]
      exact div_nonpos_of_nonpos_of_nonneg
        (mul_nonpos_of_nonpos_of_nonneg (by linarith) (sq_nonneg _)) (le_of_lt (mul_pos h0 h1))
  exact hanti (Set.left_mem_Icc.2 hab) (Set.right_mem_Icc.2 hab) hab

/-- The endpoint case of the binary Pinsker inequality: `2x² ≤ −log (1−x)` on `[0,1)`. -/
theorem two_sq_le_neg_log_one_sub (x : ℝ) (hx0 : 0 ≤ x) (hx1 : x < 1) :
    2 * x ^ 2 ≤ -Real.log (1 - x) := by
  set G : ℝ → ℝ := fun y => -Real.log (1 - y) - 2 * y ^ 2 with hG
  have hderiv : ∀ y : ℝ, y < 1 → HasDerivAt G (1 / (1 - y) - 4 * y) y := by
    intro y hy
    have h2 : HasDerivAt (fun z : ℝ => Real.log (1 - z)) (-(1 / (1 - y))) y := by
      have hb : HasDerivAt (fun z : ℝ => 1 - z) (-1) y := by
        simpa using (hasDerivAt_id y).const_sub 1
      have := (Real.hasDerivAt_log (by linarith : (1:ℝ) - y ≠ 0)).comp y hb
      simpa [mul_comm, one_div] using this
    have h3 : HasDerivAt (fun z : ℝ => 2 * z ^ 2) (2 * (2 * y)) y := by
      simpa using ((hasDerivAt_pow 2 y).const_mul (2:ℝ))
    have := h2.neg.sub h3
    convert this using 1
    ring
  have hmono : MonotoneOn G (Set.Icc 0 x) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc 0 x)
    · intro y hy
      exact ((hderiv y (lt_of_le_of_lt hy.2 hx1)).continuousAt).continuousWithinAt
    · intro y hy
      rw [interior_Icc] at hy
      exact (hderiv y (lt_trans hy.2 hx1)).differentiableAt.differentiableWithinAt
    · intro y hy
      rw [interior_Icc] at hy
      have hy1 : y < 1 := lt_trans hy.2 hx1
      rw [(hderiv y hy1).deriv]
      have h1 : 0 < 1 - y := by linarith
      have e : 1 / (1 - y) - 4 * y = (1 - 2 * y) ^ 2 / (1 - y) := by field_simp; ring
      rw [e]
      exact div_nonneg (sq_nonneg _) (le_of_lt h1)
  have := hmono (Set.left_mem_Icc.2 hx0) (Set.right_mem_Icc.2 hx0) hx0
  simp only [hG] at this
  norm_num at this
  linarith

/-- **Binary Pinsker inequality**: `2 (p − q)² ≤ KL(Ber p ‖ Ber q)`. -/
theorem klBernoulli_ge_two_sq {p q : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    (p - q) ^ 2 ≤ klBernoulli p q / 2 := by
  rcases eq_or_lt_of_le hp0 with hp | hp
  · have h := two_sq_le_neg_log_one_sub q (le_of_lt hq0) hq1
    simp only [klBernoulli, ← hp]
    norm_num
    linarith
  rcases eq_or_lt_of_le hp1 with hp' | hp'
  · have h := two_sq_le_neg_log_one_sub (1 - q) (by linarith) (by linarith)
    have hq : (1:ℝ) - (1 - q) = q := by ring
    rw [hq] at h
    simp only [klBernoulli, hp']
    norm_num
    linarith
  · have hkey : klAux p p ≤ klAux p q := by
      rcases le_total p q with h | h
      · exact klAux_mono p p q hp hq1 le_rfl h
      · exact klAux_anti p q p hq0 hp' le_rfl h
    simp only [klAux] at hkey
    have hlog1 : Real.log (p / q) = Real.log p - Real.log q :=
      Real.log_div (ne_of_gt hp) (ne_of_gt hq0)
    have hlog2 : Real.log ((1 - p) / (1 - q)) = Real.log (1 - p) - Real.log (1 - q) :=
      Real.log_div (by linarith) (by linarith)
    simp only [klBernoulli, hlog1, hlog2]
    nlinarith [hkey]

/-- **Log-sum inequality on a block**: for a subset `T` of positive `P`-mass,
`(∑_T Q) log ((∑_T Q)/(∑_T P)) ≤ ∑_T Q log (Q/P)`. -/
theorem log_sum_block {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) (T : Finset α)
    (hy : 0 < ∑ a ∈ T, P.prob a) :
    (∑ a ∈ T, Q.prob a) * Real.log ((∑ a ∈ T, Q.prob a) / (∑ a ∈ T, P.prob a))
      ≤ ∑ a ∈ T, Q.prob a * Real.log (Q.prob a / P.prob a) := by
  set x := ∑ a ∈ T, Q.prob a with hx
  set y := ∑ a ∈ T, P.prob a with hydef
  have hx0 : 0 ≤ x := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
  have key : ∀ a ∈ T, Q.prob a * Real.log (x / y) + (Q.prob a - P.prob a * (x / y))
      ≤ Q.prob a * Real.log (Q.prob a / P.prob a) := by
    intro a ha
    rcases eq_or_lt_of_le (Q.prob_nonneg a) with hQ | hQ
    · have hnn : 0 ≤ P.prob a * (x / y) :=
        mul_nonneg (P.prob_nonneg a) (div_nonneg hx0 hy.le)
      rw [← hQ]
      simp only [zero_mul, zero_sub, zero_add]
      linarith
    · have hP : 0 < P.prob a := by
        rcases eq_or_lt_of_le (P.prob_nonneg a) with hP | hP
        · exact absurd (hac a hP.symm) (ne_of_gt hQ)
        · exact hP
      have hxpos : 0 < x :=
        lt_of_lt_of_le hQ (Finset.single_le_sum (fun b _ => Q.prob_nonneg b) ha)
      set t := (Q.prob a * y) / (P.prob a * x) with ht
      have htpos : 0 < t := by positivity
      have hlog : 1 - 1 / t ≤ Real.log t := by
        have := Real.log_le_sub_one_of_pos (x := 1 / t) (by positivity)
        rw [Real.log_div one_ne_zero (ne_of_gt htpos), Real.log_one] at this
        linarith
      have hteq : Real.log t = Real.log (Q.prob a / P.prob a) - Real.log (x / y) := by
        rw [ht, Real.log_div (by positivity) (by positivity),
          Real.log_div (ne_of_gt hQ) (ne_of_gt hP), Real.log_div (ne_of_gt hxpos) (ne_of_gt hy),
          Real.log_mul (ne_of_gt hQ) (ne_of_gt hy), Real.log_mul (ne_of_gt hP) (ne_of_gt hxpos)]
        ring
      have hinv : 1 / t = (P.prob a * x) / (Q.prob a * y) := by rw [ht]; field_simp
      rw [hteq, hinv] at hlog
      have hmul := mul_le_mul_of_nonneg_left hlog (le_of_lt hQ)
      have hsimp : Q.prob a * (1 - P.prob a * x / (Q.prob a * y))
          = Q.prob a - P.prob a * (x / y) := by field_simp
      rw [hsimp] at hmul
      linarith
  have hsum := Finset.sum_le_sum key
  have hL : ∑ a ∈ T, (Q.prob a * Real.log (x / y) + (Q.prob a - P.prob a * (x / y)))
      = x * Real.log (x / y) := by
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, Finset.sum_sub_distrib, ← Finset.sum_mul]
    rw [← hx, ← hydef]
    field_simp
    ring
  linarith [hL ▸ hsum]

/-- On the block `{P ≤ Q}` the total variation distance is the difference of the masses. -/
theorem tvDist_eq_block {α : Type*} [Fintype α] [DecidableEq α] (Q P : FinDist α) :
    tvDist Q P = (∑ a ∈ Finset.univ.filter (fun a => P.prob a ≤ Q.prob a), Q.prob a)
      - (∑ a ∈ Finset.univ.filter (fun a => P.prob a ≤ Q.prob a), P.prob a) := by
  classical
  set S := Finset.univ.filter (fun a => P.prob a ≤ Q.prob a) with hS
  have hsplit : ∑ a ∈ S, |Q.prob a - P.prob a|
      + ∑ a ∈ Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a), |Q.prob a - P.prob a|
      = ∑ a : α, |Q.prob a - P.prob a| :=
    Finset.sum_filter_add_sum_filter_not _ _ _
  have h1 : ∑ a ∈ S, |Q.prob a - P.prob a| = ∑ a ∈ S, (Q.prob a - P.prob a) := by
    refine Finset.sum_congr rfl fun a ha => ?_
    have : P.prob a ≤ Q.prob a := (Finset.mem_filter.mp ha).2
    exact abs_of_nonneg (by linarith)
  have h2 : ∑ a ∈ Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a), |Q.prob a - P.prob a|
      = ∑ a ∈ Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a), (P.prob a - Q.prob a) := by
    refine Finset.sum_congr rfl fun a ha => ?_
    have h : ¬ P.prob a ≤ Q.prob a := (Finset.mem_filter.mp ha).2
    rw [abs_of_nonpos (by linarith [not_le.mp h])]; ring
  have hQ : ∑ a ∈ S, Q.prob a
      + ∑ a ∈ Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a), Q.prob a = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not]; exact Q.prob_sum_one
  have hP : ∑ a ∈ S, P.prob a
      + ∑ a ∈ Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a), P.prob a = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not]; exact P.prob_sum_one
  rw [tvDist, ← hsplit, h1, h2, Finset.sum_sub_distrib, Finset.sum_sub_distrib]
  linarith

/-- Pinsker's inequality: TV(Q, P)² ≤ KL(Q ‖ P) / 2.
    This converts KL control into uniform probability control.
    The proof contracts the divergence onto the two-point partition `{P ≤ Q}`/`{Q < P}`
    with the log-sum inequality and then applies the binary Pinsker inequality. -/
theorem pinsker_inequality {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    tvDist Q P ^ 2 ≤ klFinDist Q P / 2 := by
  classical
  set S := Finset.univ.filter (fun a => P.prob a ≤ Q.prob a) with hS
  set Sc := Finset.univ.filter (fun a => ¬ P.prob a ≤ Q.prob a) with hSc
  set x := ∑ a ∈ S, Q.prob a with hx
  set y := ∑ a ∈ S, P.prob a with hy
  have hxc : ∑ a ∈ Sc, Q.prob a = 1 - x := by
    have : ∑ a ∈ S, Q.prob a + ∑ a ∈ Sc, Q.prob a = 1 := by
      rw [hS, hSc, Finset.sum_filter_add_sum_filter_not]; exact Q.prob_sum_one
    linarith
  have hyc : ∑ a ∈ Sc, P.prob a = 1 - y := by
    have : ∑ a ∈ S, P.prob a + ∑ a ∈ Sc, P.prob a = 1 := by
      rw [hS, hSc, Finset.sum_filter_add_sum_filter_not]; exact P.prob_sum_one
    linarith
  have htv : tvDist Q P = x - y := tvDist_eq_block Q P
  have hy0 : 0 ≤ y := Finset.sum_nonneg fun a _ => P.prob_nonneg a
  have hx0 : 0 ≤ x := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
  have hx1 : x ≤ 1 := by
    have : 0 ≤ ∑ a ∈ Sc, Q.prob a := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
    linarith [hxc]
  have hy1 : y ≤ 1 := by
    have : 0 ≤ ∑ a ∈ Sc, P.prob a := Finset.sum_nonneg fun a _ => P.prob_nonneg a
    linarith [hyc]
  rcases eq_or_lt_of_le hy0 with hy0' | hy0'
  · have hallP : ∀ a ∈ S, P.prob a = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun b _ => P.prob_nonneg b)).mp hy0'.symm
    have hxz : x = 0 := Finset.sum_eq_zero fun a ha => hac a (hallP a ha)
    have htv0 : tvDist Q P = 0 := by rw [htv, hxz, ← hy0']; ring
    rw [htv0]
    have := klFinDist_nonneg Q P hac
    nlinarith
  rcases eq_or_lt_of_le hy1 with hy1' | hy1'
  · have hzero : ∑ a ∈ Sc, P.prob a = 0 := by rw [hyc, ← hy1']; ring
    have hallP : ∀ a ∈ Sc, P.prob a = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun b _ => P.prob_nonneg b)).mp hzero
    have hxz : ∑ a ∈ Sc, Q.prob a = 0 := Finset.sum_eq_zero fun a ha => hac a (hallP a ha)
    have hx1' : x = 1 := by rw [hxc] at hxz; linarith
    have htv0 : tvDist Q P = 0 := by rw [htv, hx1', ← hy1']; ring
    rw [htv0]
    have := klFinDist_nonneg Q P hac
    nlinarith
  · have h1 := log_sum_block Q P hac S (by rw [← hy]; exact hy0')
    rw [← hx, ← hy] at h1
    have h2 := log_sum_block Q P hac Sc (by rw [hyc]; linarith)
    rw [hxc, hyc] at h2
    have hsplit : ∑ a ∈ S, Q.prob a * Real.log (Q.prob a / P.prob a)
        + ∑ a ∈ Sc, Q.prob a * Real.log (Q.prob a / P.prob a)
        = klFinDist Q P := by
      rw [klFinDist_eq_sum, hS, hSc, Finset.sum_filter_add_sum_filter_not]
    have hkl : klBernoulli x y ≤ klFinDist Q P := by
      rw [klBernoulli, ← hsplit]
      linarith
    have hbp := klBernoulli_ge_two_sq hx0 hx1 hy0' hy1'
    rw [htv]
    linarith

/-! ## Bernoulli KL Properties -/

/-
Bernoulli KL is nonneg for p, q ∈ [0, 1].
-/
theorem klBernoulli_nonneg {p q : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    0 ≤ klBernoulli p q := by
  have h := klBernoulli_ge_two_sq hp0 hp1 hq0 hq1
  nlinarith [sq_nonneg (p - q)]

/-
Bernoulli KL is zero iff p = q.
-/
theorem klBernoulli_eq_zero_iff {p q : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) (hq0 : 0 < q) (hq1 : q < 1) :
    klBernoulli p q = 0 ↔ p = q := by
  constructor
  · intro h
    have hb := klBernoulli_ge_two_sq hp0.le hp1.le hq0 hq1
    rw [h] at hb
    have hsq : (p - q) ^ 2 = 0 := le_antisymm (by linarith) (sq_nonneg _)
    have : p - q = 0 := by
      exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hsq
    linarith
  · intro h
    subst h
    rw [klBernoulli, div_self (ne_of_gt hp0), div_self (by linarith : (1:ℝ) - p ≠ 0),
      Real.log_one]
    ring

/-
Pinsker for Bernoulli: |p - q|² ≤ klBernoulli(p, q) / 2.
    This is the key inequality for converting KL bounds into risk bounds.
-/
/-- Bernoulli Pinsker: (p - q)² ≤ KL(Ber(p) ‖ Ber(q)) / 2.
    Direct proof without the general Pinsker inequality. -/
theorem bernoulli_pinsker {p q : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    (p - q) ^ 2 ≤ klBernoulli p q / 2 :=
  klBernoulli_ge_two_sq hp0 hp1 hq0 hq1

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