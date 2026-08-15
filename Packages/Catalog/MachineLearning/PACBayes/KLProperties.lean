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

/-! ## Finite distributions and the KL divergence

The definitions below were referenced throughout this file (and by
`Bridges.GameTheory.McAllester`) but were missing from the project, so the file did
not elaborate.  They are the standard finite-support objects: a probability vector on
a finite type, the discrete Kullback-Leibler divergence (with the usual convention
`0 log 0 = 0`) and its two-point (Bernoulli) specialisation. -/

/-- A probability distribution on a finite type: a nonnegative weight vector summing
to one. -/
structure FinDist (α : Type*) [Fintype α] where
  /-- The probability mass function. -/
  prob : α → ℝ
  /-- Masses are nonnegative. -/
  prob_nonneg : ∀ a, 0 ≤ prob a
  /-- Masses sum to one. -/
  prob_sum_one : ∑ a, prob a = 1

/-- The Kullback-Leibler divergence `KL(Q ‖ P) = ∑ Q(a) log (Q(a)/P(a))` of finite
distributions, with the convention `0 log 0 = 0`. -/
def klFinDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  ∑ a, if Q.prob a = 0 then 0 else Q.prob a * Real.log (Q.prob a / P.prob a)

/-- The Bernoulli KL divergence `kl(p ‖ q) = p log (p/q) + (1-p) log ((1-p)/(1-q))`,
with the convention `0 log 0 = 0` at both endpoints. -/
def klBernoulli (p q : ℝ) : ℝ :=
  (if p = 0 then 0 else p * Real.log (p / q)) +
    (if p = 1 then 0 else (1 - p) * Real.log ((1 - p) / (1 - q)))

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

/-! ## Analytic toolkit for Pinsker's inequality

The two Pinsker statements below (`pinsker_inequality` and `bernoulli_pinsker`) are
proved from scratch here.  The route is the classical one:

* a *raw* Bernoulli divergence `klRaw` (no `if`s: the junk value `Real.log 0 = 0`
  already implements the convention `0 log 0 = 0`);
* the two-point Pinsker bound `2 (p - q)^2 ≤ klRaw p q`, obtained by showing that
  `x ↦ klRaw p x - 2 (p - x)^2` has derivative `(x - p)(1 - 2x)^2 / (x(1-x))`, hence is
  monotone above `p`, and vanishes at `x = p` (the branch `q < p` follows from the
  symmetry `klRaw (1-p) (1-q) = klRaw p q`);
* the log-sum inequality on a finset, proved by the tangent-line bound
  `log z ≥ 1 - 1/z`;
* the data-processing step for the two-block partition `{P ≤ Q}`, `{Q < P}`, which
  turns the general statement into the two-point one. -/

/-- `a * log (a / b) = a * log a - a * log b` for `0 ≤ a` and `0 < b`; the case `a = 0`
is covered by the convention `0 log 0 = 0`. -/
lemma mul_log_div_eq {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) :
    a * Real.log (a / b) = a * Real.log a - a * Real.log b := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [← h]
  · rw [Real.log_div (ne_of_gt h) (ne_of_gt hb)]; ring

/-- The Bernoulli divergence without the `if`s: `klRaw p q = p log (p/q) + (1-p) log
((1-p)/(1-q))`. -/
def klRaw (p q : ℝ) : ℝ :=
  p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q))

/-- `klBernoulli` agrees with `klRaw`: the `if`-branches only re-state the convention
`0 log 0 = 0`. -/
lemma klBernoulli_eq_klRaw (p q : ℝ) : klBernoulli p q = klRaw p q := by
  unfold klBernoulli klRaw
  split_ifs with h1 h2 h2
  · exact absurd (h1.symm.trans h2) (by norm_num)
  · simp [h1]
  · simp [h2]
  · rfl

/-- Splitting `klRaw` into four logarithms (valid for `0 ≤ p ≤ 1`, `0 < q < 1`). -/
lemma klRaw_eq_split {p q : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    klRaw p q = (p * Real.log p - p * Real.log q) +
      ((1 - p) * Real.log (1 - p) - (1 - p) * Real.log (1 - q)) := by
  rw [klRaw, mul_log_div_eq hp0 hq0, mul_log_div_eq (by linarith : (0:ℝ) ≤ 1 - p)
    (by linarith : (0:ℝ) < 1 - q)]

/-- `klRaw` is invariant under `(p, q) ↦ (1 - p, 1 - q)`. -/
lemma klRaw_symm (p q : ℝ) : klRaw (1 - p) (1 - q) = klRaw p q := by
  simp [klRaw, add_comm]

/-- Two-point Pinsker, upper branch `p ≤ q`. -/
lemma two_sq_le_klRaw_of_le {p q : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hpq : p ≤ q)
    (hq0 : 0 < q) (hq1 : q < 1) : 2 * (p - q) ^ 2 ≤ klRaw p q := by
  have hp1' : p < 1 := lt_of_le_of_lt hpq hq1
  set F : ℝ → ℝ := fun x => (p * Real.log p - p * Real.log x) +
      ((1 - p) * Real.log (1 - p) - (1 - p) * Real.log (1 - x)) - 2 * (p - x) ^ 2 with hF
  have hcontlog : ContinuousOn (fun x : ℝ => p * Real.log x) (Set.Ico p 1) := by
    rcases eq_or_lt_of_le hp0 with h | h
    · simpa [← h] using (continuousOn_const : ContinuousOn (fun _ : ℝ => (0:ℝ)) (Set.Ico p 1))
    · exact continuousOn_const.mul (Real.continuousOn_log.mono (by
        intro x hx
        simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
        exact ne_of_gt (lt_of_lt_of_le h hx.1)))
  have hcont : ContinuousOn F (Set.Ico p 1) := by
    have h2 : ContinuousOn (fun x : ℝ => (1 - p) * Real.log (1 - x)) (Set.Ico p 1) := by
      refine continuousOn_const.mul (Real.continuousOn_log.comp (by fun_prop) ?_)
      intro x hx
      simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
      exact ne_of_gt (by simpa using sub_pos.mpr hx.2)
    exact ((continuousOn_const.sub hcontlog).add (continuousOn_const.sub h2)).sub (by fun_prop)
  have hint : interior (Set.Ico p 1) = Set.Ioo p 1 := interior_Ico
  have hderiv : ∀ x ∈ Set.Ioo p 1, HasDerivAt F
      (-(p / x) + (1 - p) / (1 - x) + 4 * (p - x)) x := by
    intro x hx
    have hx0 : 0 < x := lt_of_le_of_lt hp0 hx.1
    have hx1 : (0:ℝ) < 1 - x := by linarith [hx.2]
    have d1 : HasDerivAt (fun x : ℝ => p * Real.log x) (p / x) x := by
      simpa [mul_one_div] using (Real.hasDerivAt_log (ne_of_gt hx0)).const_mul p
    have d2 : HasDerivAt (fun x : ℝ => (1 - p) * Real.log (1 - x)) (-((1 - p) / (1 - x))) x := by
      have hlin : HasDerivAt (fun x : ℝ => (1:ℝ) - x) (-1) x := by
        simpa using (hasDerivAt_id x).const_sub 1
      have h3 := (Real.hasDerivAt_log (ne_of_gt hx1)).comp x hlin
      have h4 := h3.const_mul (1 - p)
      convert h4 using 1
      field_simp
    have d3 : HasDerivAt (fun x : ℝ => 2 * (p - x) ^ 2) (-(4 * (p - x))) x := by
      have hsq : HasDerivAt (fun x : ℝ => (p - x) ^ 2) (2 * (p - x) * (-1)) x := by
        have hb : HasDerivAt (fun x : ℝ => p - x) (-1) x := by
          simpa using (hasDerivAt_id x).const_sub p
        simpa using hb.pow 2
      have h5 := hsq.const_mul (2:ℝ)
      convert h5 using 1
      ring
    have h6 := (((hasDerivAt_const x (p * Real.log p)).sub d1).add
      ((hasDerivAt_const x ((1 - p) * Real.log (1 - p))).sub d2)).sub d3
    convert h6 using 1
    ring
  have hderivnonneg : ∀ x ∈ interior (Set.Ico p 1), 0 ≤ deriv F x := by
    rw [hint]
    intro x hx
    have hx0 : 0 < x := lt_of_le_of_lt hp0 hx.1
    have hx1 : (0:ℝ) < 1 - x := by linarith [hx.2]
    rw [(hderiv x hx).deriv]
    have key : -(p / x) + (1 - p) / (1 - x) + 4 * (p - x)
        = ((x - p) * (1 - 2 * x) ^ 2) / (x * (1 - x)) := by
      field_simp
      ring
    rw [key]
    exact div_nonneg (mul_nonneg (by linarith [hx.1]) (sq_nonneg _)) (by positivity)
  have hdiff : DifferentiableOn ℝ F (interior (Set.Ico p 1)) := by
    rw [hint]
    exact fun x hx => ((hderiv x hx).differentiableAt).differentiableWithinAt
  have hmono : MonotoneOn F (Set.Ico p 1) :=
    monotoneOn_of_deriv_nonneg (convex_Ico p 1) hcont hdiff hderivnonneg
  have hFp : F p = 0 := by simp [hF]
  have hle := hmono (Set.mem_Ico.mpr ⟨le_refl p, hp1'⟩) (Set.mem_Ico.mpr ⟨hpq, hq1⟩) hpq
  rw [hFp] at hle
  rw [klRaw_eq_split hp0 hp1 hq0 hq1]
  simp only [hF] at hle
  linarith

/-- **Two-point Pinsker inequality**: `2 (p - q)^2 ≤ kl(p ‖ q)`. -/
lemma two_sq_le_klRaw {p q : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    2 * (p - q) ^ 2 ≤ klRaw p q := by
  rcases le_total p q with h | h
  · exact two_sq_le_klRaw_of_le hp0 hp1 h hq0 hq1
  · have hsym := two_sq_le_klRaw_of_le (p := 1 - p) (q := 1 - q) (by linarith) (by linarith)
      (by linarith) (by linarith) (by linarith)
    rw [klRaw_symm] at hsym
    nlinarith [hsym]

/-- Tangent-line bound `1 - 1/z ≤ log z` for `z > 0`. -/
lemma one_sub_inv_le_log {z : ℝ} (hz : 0 < z) : 1 - 1 / z ≤ Real.log z := by
  have h := Real.log_le_sub_one_of_pos (inv_pos.mpr hz)
  rw [Real.log_inv] at h
  rw [one_div]
  linarith

/-- **Log-sum inequality** on a finset: the divergence of the block totals is a lower
bound for the sum of the pointwise divergences. -/
lemma log_sum_finset_ineq {α : Type*} (Q P : α → ℝ) (B : Finset α)
    (hQ : ∀ a, 0 ≤ Q a) (hP : ∀ a, 0 ≤ P a) (hac : ∀ a, P a = 0 → Q a = 0)
    (ht : 0 < ∑ a ∈ B, P a) :
    (∑ a ∈ B, Q a) * Real.log ((∑ a ∈ B, Q a) / (∑ a ∈ B, P a)) ≤
      ∑ a ∈ B, Q a * Real.log (Q a / P a) := by
  set s := ∑ a ∈ B, Q a with hs
  set t := ∑ a ∈ B, P a with htdef
  have hs0 : 0 ≤ s := Finset.sum_nonneg fun a _ => hQ a
  have key : ∀ a ∈ B, Q a * Real.log (s / t) + (Q a - P a * (s / t)) ≤
      Q a * Real.log (Q a / P a) := by
    intro a ha
    rcases eq_or_lt_of_le (hQ a) with h | h
    · have hPa : 0 ≤ P a * (s / t) := mul_nonneg (hP a) (div_nonneg hs0 ht.le)
      simp [← h]
      linarith
    · have hPa : 0 < P a := by
        rcases eq_or_lt_of_le (hP a) with h2 | h2
        · exact absurd (hac a h2.symm) (ne_of_gt h)
        · exact h2
      rcases eq_or_lt_of_le hs0 with hs' | hs'
      · exact absurd (Finset.single_le_sum (f := Q) (fun b _ => hQ b) ha) (by
          rw [← hs, ← hs']; linarith)
      · have hz : 0 < (Q a * t) / (P a * s) := by positivity
        have hlog := one_sub_inv_le_log hz
        have hexp : Real.log ((Q a * t) / (P a * s))
            = Real.log (Q a / P a) - Real.log (s / t) := by
          rw [Real.log_div (by positivity) (by positivity),
            Real.log_div (by positivity) (by positivity),
            Real.log_div (by positivity) (by positivity),
            Real.log_mul (by positivity) (by positivity),
            Real.log_mul (by positivity) (by positivity)]
          ring
        rw [hexp] at hlog
        have hinv : 1 / ((Q a * t) / (P a * s)) = (P a * s) / (Q a * t) := by field_simp
        rw [hinv] at hlog
        have h2 := mul_le_mul_of_nonneg_left hlog (le_of_lt h)
        have hcancel : Q a * ((P a * s) / (Q a * t)) = P a * (s / t) := by field_simp
        nlinarith [h2, hcancel]
  have hsum := Finset.sum_le_sum key
  have hL : ∑ a ∈ B, (Q a * Real.log (s / t) + (Q a - P a * (s / t))) = s * Real.log (s / t) := by
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, Finset.sum_sub_distrib, ← Finset.sum_mul,
      ← hs, ← htdef]
    field_simp
    ring
  rw [hL] at hsum
  exact hsum

/-- The `if` in `klFinDist` is redundant: `0 * log (0/y) = 0` already. -/
lemma klFinDist_eq_sum {α : Type*} [Fintype α] (Q P : FinDist α) :
    klFinDist Q P = ∑ a, Q.prob a * Real.log (Q.prob a / P.prob a) := by
  refine Finset.sum_congr rfl fun a _ => ?_
  split_ifs with h
  · simp [h]
  · rfl

/-! ## Pinsker's Inequality -/

/-- Total variation distance between two finite distributions. -/
def tvDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  (∑ a : α, |Q.prob a - P.prob a|) / 2

/-- Pinsker's inequality: TV(Q, P)² ≤ KL(Q ‖ P) / 2.
    This converts KL control into uniform probability control.
    The proof reduces the general case to the two-point case by the log-sum
    inequality applied to the partition `{P ≤ Q}`, `{Q < P}`, on which the total
    variation distance is realised. -/
theorem pinsker_inequality {α : Type*} [Fintype α] (Q P : FinDist α)
    (hac : ∀ a, P.prob a = 0 → Q.prob a = 0) :
    tvDist Q P ^ 2 ≤ klFinDist Q P / 2 := by
  classical
  set A : Finset α := Finset.univ.filter (fun a => P.prob a ≤ Q.prob a) with hA
  set B : Finset α := Finset.univ.filter (fun a => ¬ (P.prob a ≤ Q.prob a)) with hB
  set s : ℝ := ∑ a ∈ A, Q.prob a with hs
  set t : ℝ := ∑ a ∈ A, P.prob a with ht
  have hQsplit : s + ∑ a ∈ B, Q.prob a = 1 := by
    rw [hs, hA, hB, Finset.sum_filter_add_sum_filter_not]
    exact Q.prob_sum_one
  have hPsplit : t + ∑ a ∈ B, P.prob a = 1 := by
    rw [ht, hA, hB, Finset.sum_filter_add_sum_filter_not]
    exact P.prob_sum_one
  have hBQ : ∑ a ∈ B, Q.prob a = 1 - s := by linarith
  have hBP : ∑ a ∈ B, P.prob a = 1 - t := by linarith
  have hs0 : 0 ≤ s := Finset.sum_nonneg fun a _ => Q.prob_nonneg a
  have ht0 : 0 ≤ t := Finset.sum_nonneg fun a _ => P.prob_nonneg a
  have hs1 : s ≤ 1 := by
    have h := Finset.sum_nonneg (f := Q.prob) (s := B) fun a _ => Q.prob_nonneg a
    linarith
  have ht1 : t ≤ 1 := by
    have h := Finset.sum_nonneg (f := P.prob) (s := B) fun a _ => P.prob_nonneg a
    linarith
  have htv : tvDist Q P = s - t := by
    have hsplit : ∑ a ∈ A, |Q.prob a - P.prob a| + ∑ a ∈ B, |Q.prob a - P.prob a|
        = ∑ a, |Q.prob a - P.prob a| := by
      rw [hA, hB, Finset.sum_filter_add_sum_filter_not]
    have hA' : ∑ a ∈ A, |Q.prob a - P.prob a| = s - t := by
      rw [hs, ht, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a ha => ?_
      have hle : P.prob a ≤ Q.prob a := by
        rw [hA] at ha; simpa using (Finset.mem_filter.mp ha).2
      exact abs_of_nonneg (by linarith)
    have hB' : ∑ a ∈ B, |Q.prob a - P.prob a| = (1 - t) - (1 - s) := by
      rw [← hBP, ← hBQ, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a ha => ?_
      have hlt : Q.prob a < P.prob a := by
        rw [hB] at ha; simpa using not_le.mp (Finset.mem_filter.mp ha).2
      rw [abs_of_nonpos (by linarith)]
      ring
    rw [tvDist, ← hsplit, hA', hB']
    ring
  rcases eq_or_lt_of_le ht0 with htz | htpos
  · -- the block `A` carries no `P`-mass, hence (by absolute continuity) no `Q`-mass
    have hzero : ∀ a ∈ A, P.prob a = 0 := fun a ha =>
      (Finset.sum_eq_zero_iff_of_nonneg (fun b _ => P.prob_nonneg b)).mp htz.symm a ha
    have hsz : s = 0 := by
      rw [hs]
      exact Finset.sum_eq_zero fun a ha => hac a (hzero a ha)
    have hnn := klFinDist_nonneg Q P hac
    rw [htv, hsz, ← htz]
    simpa using by linarith
  rcases eq_or_lt_of_le ht1 with hto | htlt
  · -- the block `B` carries no `P`-mass
    have hzero : ∀ a ∈ B, P.prob a = 0 := by
      intro a ha
      have hBz : ∑ a ∈ B, P.prob a = 0 := by rw [hBP, hto]; ring
      exact (Finset.sum_eq_zero_iff_of_nonneg (fun b _ => P.prob_nonneg b)).mp hBz a ha
    have hsz : ∑ a ∈ B, Q.prob a = 0 := Finset.sum_eq_zero fun a ha => hac a (hzero a ha)
    have hs1' : s = 1 := by rw [hBQ] at hsz; linarith
    have hnn := klFinDist_nonneg Q P hac
    rw [htv, hs1', ← hto]
    simpa using by linarith
  · have h1 := log_sum_finset_ineq Q.prob P.prob A Q.prob_nonneg P.prob_nonneg hac
      (by rw [← ht]; exact htpos)
    have h2 := log_sum_finset_ineq Q.prob P.prob B Q.prob_nonneg P.prob_nonneg hac
      (by rw [hBP]; linarith)
    rw [← hs, ← ht] at h1
    rw [hBQ, hBP] at h2
    have hklsplit : klFinDist Q P
        = ∑ a ∈ A, Q.prob a * Real.log (Q.prob a / P.prob a)
          + ∑ a ∈ B, Q.prob a * Real.log (Q.prob a / P.prob a) := by
      rw [klFinDist_eq_sum, hA, hB, Finset.sum_filter_add_sum_filter_not]
    have hkl : klRaw s t ≤ klFinDist Q P := by
      rw [hklsplit, klRaw]
      linarith
    have hpin := two_sq_le_klRaw hs0 hs1 htpos htlt
    rw [htv]
    linarith

/-! ## Bernoulli KL Properties -/

/-
Bernoulli KL is nonneg for p, q ∈ [0, 1].
-/
theorem klBernoulli_nonneg {p q : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 < q) (hq1 : q < 1) :
    0 ≤ klBernoulli p q := by
  rw [klBernoulli_eq_klRaw]
  nlinarith [two_sq_le_klRaw hp0 hp1 hq0 hq1, sq_nonneg (p - q)]

/-
The original, `if`-splitting argument for `klBernoulli_nonneg`; it is kept (inert)
for the record.  It only covered the interior case `0 < p < 1`, leaving the boundary
case `p = 1` open, which is why the proof above goes through the two-point Pinsker
bound instead.

  unfold klBernoulli;
  split_ifs <;> try linarith [ Real.log_le_sub_one_of_pos ( sub_pos.mpr hq1 ), Real.log_le_sub_one_of_pos hq0 ];
  -- Applying the inequality $\log(x) \leq x - 1$ to both terms, we get:
  have h_log_ineq : log (p / q) ≥ 1 - q / p ∧ log ((1 - p) / (1 - q)) ≥ 1 - (1 - q) / (1 - p) := by
    have h_log_ineq : ∀ x : ℝ, 0 < x → log x ≥ 1 - 1 / x := by
      exact fun x x_pos => by have := Real.log_le_sub_one_of_pos ( inv_pos.mpr x_pos ) ; norm_num at * ; linarith;
    exact ⟨ by simpa using h_log_ineq ( p / q ) ( div_pos ( lt_of_le_of_ne hp0 ( Ne.symm ‹_› ) ) hq0 ), by simpa using h_log_ineq ( ( 1 - p ) / ( 1 - q ) ) ( div_pos ( sub_pos.mpr ( lt_of_le_of_ne hp1 ‹_› ) ) ( sub_pos.mpr hq1 ) ) ⟩;
  nlinarith [ mul_div_cancel₀ q ( show p ≠ 0 by assumption ), mul_div_cancel₀ ( 1 - q ) ( show ( 1 - p ) ≠ 0 by cases lt_or_gt_of_ne ‹¬p = 1› <;> linarith ) ]
-/

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
  rw [klBernoulli_eq_klRaw]
  linarith [two_sq_le_klRaw hp0 hp1 hq0 hq1]

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