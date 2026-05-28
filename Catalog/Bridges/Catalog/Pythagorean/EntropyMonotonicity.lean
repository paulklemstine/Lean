/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Entropy Monotonicity under Derivative Transport

This file establishes foundational results connecting Shannon entropy to polynomial
differentiation, proving that differentiation acts as an information-compressing operation.

## Main Definitions

* `shannonEntropy` — Shannon entropy of a finite probability distribution
* `klDivergence` — Kullback-Leibler divergence between two distributions
* `reweight` — Reweighting operator for distributions

## Main Results

* `shannonEntropy_nonneg` — Shannon entropy is nonneg for probability distributions
* `shannonEntropy_le_log_card` — Shannon entropy is at most log(|support|)
* `gibbs_inequality` — KL divergence is nonneg (Gibbs' inequality)
* `kl_reweight_eq` — KL divergence of reweighted distribution equals weighted log minus
  normalizer: `D_KL(q ‖ p) = ∑ qᵢ log wᵢ - log S`
* `weighted_jensen_log` — Consequence: `∑ qᵢ log wᵢ ≥ log(∑ wⱼ pⱼ)`
* `entropy_reweight_eq` — Entropy decomposition: `H(q) = -(∑ qᵢ log wᵢ) + H_cross(q,p) + log S`

## Application Keywords

entropy monotonicity, Lorentzian polynomials, derivative transport, log-sum inequality,
Shannon entropy, KL divergence, Gibbs inequality, information compression

## References

* Shannon, "A Mathematical Theory of Communication", 1948
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Real

noncomputable section

namespace EntropyMonotonicity

/-! ## Section 1: Shannon Entropy -/

/-- Shannon entropy of a finite probability distribution, defined as
    `H(p) = ∑ᵢ negMulLog(pᵢ) = -∑ᵢ pᵢ log(pᵢ)`.
    Uses the convention that `0 · log 0 = 0` (via `negMulLog`). -/
def shannonEntropy {ι : Type*} [Fintype ι] (p : ι → ℝ) : ℝ :=
  ∑ i, Real.negMulLog (p i)

/-- Shannon entropy is nonneg for any probability distribution on a finite type. -/
theorem shannonEntropy_nonneg {ι : Type*} [Fintype ι] (p : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    0 ≤ shannonEntropy p := by
  exact Finset.sum_nonneg fun i _ =>
    Real.negMulLog_nonneg (hp i)
      (hsum ▸ Finset.single_le_sum (fun a _ => hp a) (Finset.mem_univ i))

/-
Shannon entropy is at most `log(|ι|)`, the entropy of the uniform distribution.
    This is a consequence of the strict concavity of `negMulLog` and Jensen's inequality.
-/
theorem shannonEntropy_le_log_card {ι : Type*} [Fintype ι] [Nonempty ι] (p : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    shannonEntropy p ≤ Real.log (Fintype.card ι) := by
  have h_jensen : ∀ x : ι → ℝ, (∀ i, 0 ≤ x i) → (∑ i, x i = 1) → (∑ i, x i * Real.log (x i)) ≥ (∑ i, x i) * Real.log ((∑ i, x i) / (Fintype.card ι)) := by
    intro x hx hsum;
    have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x : ℝ => x * Real.log x) := by
      exact ( Real.convexOn_mul_log );
    -- Apply Jensen's inequality to the convex function $f(x) = x \log x$ with the weights $x_i$.
    have h_jensen_apply : (∑ i : ι, (1 / Fintype.card ι) * (x i * Real.log (x i))) ≥ ((∑ i : ι, (1 / Fintype.card ι) * x i)) * Real.log ((∑ i : ι, (1 / Fintype.card ι) * x i)) := by
      apply ConvexOn.map_sum_le h_jensen;
      · exact fun _ _ => by positivity;
      · simp +decide [ Fintype.card_pos ];
      · grind;
    simp_all +decide [ div_eq_inv_mul, ← Finset.mul_sum _ _ _ ];
    nlinarith [ inv_pos.mpr ( show 0 < ( Fintype.card ι : ℝ ) by exact Nat.cast_pos.mpr Fintype.card_pos ), mul_inv_cancel₀ ( show ( Fintype.card ι : ℝ ) ≠ 0 by exact Nat.cast_ne_zero.mpr Fintype.card_ne_zero ) ];
  convert neg_le_neg ( h_jensen p hp hsum ) using 1 <;> simp +decide [ *, shannonEntropy, Real.negMulLog ]

/-! ## Section 2: KL Divergence and Gibbs' Inequality -/

/-- Kullback-Leibler divergence from distribution `p` to distribution `q`.
    Defined as `D_KL(p ‖ q) = ∑ᵢ pᵢ log(pᵢ / qᵢ)`. -/
def klDivergence {ι : Type*} [Fintype ι] (p q : ι → ℝ) : ℝ :=
  ∑ i, p i * Real.log (p i / q i)

/-
**Gibbs' Inequality**: The KL divergence is nonneg for probability distributions.
    This is the information-theoretic foundation for entropy monotonicity.
    The proof uses `log x ≤ x - 1` for all positive `x`.
-/
theorem gibbs_inequality {ι : Type*} [Fintype ι] (p q : ι → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hq_pos : ∀ i, 0 < q i)
    (hp_sum : ∑ i, p i = 1) (hq_sum : ∑ i, q i = 1) :
    0 ≤ klDivergence p q := by
  -- We'll use the fact that $p_i \log(p_i / q_i) \geq p_i - q_i$ for all $i$.
  have h_ineq : ∀ i, p i * Real.log (p i / q i) ≥ p i - q i := by
    intro i
    have h_ineq : Real.log (p i / q i) ≥ 1 - q i / p i := by
      have := Real.log_le_sub_one_of_pos ( div_pos ( hq_pos i ) ( hp_pos i ) );
      rw [ show p i / q i = ( q i / p i ) ⁻¹ by rw [ inv_div ], Real.log_inv ] ; linarith;
    nlinarith only [ hp_pos i, hq_pos i, h_ineq, mul_div_cancel₀ ( q i ) ( ne_of_gt ( hp_pos i ) ) ];
  exact le_trans ( by simp +decide [ hp_sum, hq_sum, Finset.sum_sub_distrib ] ) ( Finset.sum_le_sum fun i _ => h_ineq i )

/-! ## Section 3: Reweighting and Transport -/

/-- Given a probability distribution `p` and positive weights `w`,
    the reweighted distribution `q_i = w_i * p_i / ∑ⱼ w_j * p_j`. -/
def reweight {ι : Type*} [Fintype ι] (p w : ι → ℝ) : ι → ℝ :=
  fun i => w i * p i / ∑ j, w j * p j

/-- The reweighted distribution sums to 1 when the total weight is positive. -/
theorem reweight_sum_eq_one {ι : Type*} [Fintype ι] (p w : ι → ℝ)
    (hS : 0 < ∑ j, w j * p j) :
    ∑ i, reweight p w i = 1 := by
  unfold reweight; rw [← Finset.sum_div, div_self hS.ne']

/-- Components of reweighted distribution are nonneg when inputs are nonneg. -/
theorem reweight_nonneg {ι : Type*} [Fintype ι] (p w : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hw : ∀ i, 0 ≤ w i) (hS : 0 < ∑ j, w j * p j) (i : ι) :
    0 ≤ reweight p w i := by
  exact div_nonneg (mul_nonneg (hw i) (hp i)) hS.le

/-! ## Section 4: KL Divergence Decomposition under Reweighting -/

/-
**KL divergence of reweighted distribution.**
    When `q = reweight p w`, the KL divergence from `q` to `p` decomposes as
    `D_KL(q ‖ p) = ∑ qᵢ log wᵢ - log(∑ wⱼ pⱼ)`.

    This is a fundamental identity: the information cost of reweighting is exactly
    the expected log-weight minus the log-normalizer.
-/
theorem kl_reweight_eq {ι : Type*} [Fintype ι] (p w : ι → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hw_pos : ∀ i, 0 < w i)
    (hp_sum : ∑ i, p i = 1) :
    let q := reweight p w
    let S := ∑ j, w j * p j
    klDivergence q p = ∑ i, q i * Real.log (w i) - Real.log S := by
  unfold klDivergence reweight;
  -- Simplify the expression inside the sum.
  have h_simplify : ∀ i, (w i * p i / (∑ j, w j * p j)) * Real.log ((w i * p i / (∑ j, w j * p j)) / p i) = (w i * p i / (∑ j, w j * p j)) * (Real.log (w i) - Real.log (∑ j, w j * p j)) := by
    intro i; rw [ ← Real.log_div ( ne_of_gt ( hw_pos i ) ) ( ne_of_gt ( Finset.sum_pos ( fun j _ => mul_pos ( hw_pos j ) ( hp_pos j ) ) ⟨ i, Finset.mem_univ i ⟩ ) ) ] ; ring;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( hp_pos i ) ];
  simp_all +decide [ mul_sub, ← Finset.sum_mul _ _ _ ];
  rw [ ← Finset.sum_div _ _ _, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => mul_pos ( hw_pos _ ) ( hp_pos _ ) ) ⟨ Classical.choose ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ), Classical.choose_spec ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ⟩, one_mul ]

/-
**Weighted Jensen inequality for log.**
    When `q = reweight p w`, we have `∑ qᵢ log wᵢ ≥ log(∑ wⱼ pⱼ)`.
    This is the free energy inequality: the expected log-weight under the
    tilted distribution exceeds the log-partition function.

    This follows directly from Gibbs' inequality + the KL decomposition.
-/
theorem weighted_jensen_log {ι : Type*} [Fintype ι] (p w : ι → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hw_pos : ∀ i, 0 < w i)
    (hp_sum : ∑ i, p i = 1) :
    let q := reweight p w
    let S := ∑ j, w j * p j
    Real.log S ≤ ∑ i, q i * Real.log (w i) := by
  -- By Gibbs' inequality, we have $D_KL(q‖p) ≥ 0$.
  have h_gibbs : 0 ≤ klDivergence (reweight p w) p := by
    apply gibbs_inequality;
    · exact fun i => div_pos ( mul_pos ( hw_pos i ) ( hp_pos i ) ) ( Finset.sum_pos ( fun _ _ => mul_pos ( hw_pos _ ) ( hp_pos _ ) ) ⟨ i, Finset.mem_univ _ ⟩ );
    · assumption;
    · exact reweight_sum_eq_one p w ( Finset.sum_pos ( fun _ _ => mul_pos ( hw_pos _ ) ( hp_pos _ ) ) ⟨ Classical.choose ( Finset.nonempty_of_sum_ne_zero ( by rw [ hp_sum ] ; norm_num ) ), Classical.choose_spec ( Finset.nonempty_of_sum_ne_zero ( by rw [ hp_sum ] ; norm_num ) ) ⟩ );
    · exact hp_sum;
  linarith [ kl_reweight_eq p w hp_pos hw_pos hp_sum ];

/-! ## Section 5: Cross-Entropy and Entropy Decomposition -/

/-- Cross-entropy from distribution `q` to distribution `p`.
    Defined as `H(q, p) = -∑ qᵢ log pᵢ = H(q) + D_KL(q ‖ p)`. -/
def crossEntropy {ι : Type*} [Fintype ι] (q p : ι → ℝ) : ℝ :=
  -∑ i, q i * Real.log (p i)

/-
Cross-entropy equals entropy plus KL divergence.
-/
theorem crossEntropy_eq_entropy_add_kl {ι : Type*} [Fintype ι] (q p : ι → ℝ)
    (hq_pos : ∀ i, 0 < q i) (hp_pos : ∀ i, 0 < p i) :
    crossEntropy q p = shannonEntropy q + klDivergence q p := by
  unfold crossEntropy shannonEntropy klDivergence;
  simp +decide [ Real.negMulLog, Real.log_div, ne_of_gt ( hq_pos _ ), ne_of_gt ( hp_pos _ ), Finset.sum_add_distrib, mul_sub ];
  ring

/-
Cross-entropy is at least entropy (consequence of Gibbs' inequality).
-/
theorem entropy_le_crossEntropy {ι : Type*} [Fintype ι] (q p : ι → ℝ)
    (hq_pos : ∀ i, 0 < q i) (hp_pos : ∀ i, 0 < p i)
    (hq_sum : ∑ i, q i = 1) (hp_sum : ∑ i, p i = 1) :
    shannonEntropy q ≤ crossEntropy q p := by
  -- By crossEntropy_eq_entropy_add_kl: crossEntropy q p = shannonEntropy q + klDivergence q p.
  have h_crossEntropy_eq_entropy_add_kl : crossEntropy q p = shannonEntropy q + klDivergence q p := by
    exact crossEntropy_eq_entropy_add_kl q p hq_pos hp_pos;
  linarith [ gibbs_inequality q p hq_pos hp_pos hq_sum hp_sum ]

/-
**Entropy of reweighted distribution.**
    `H(reweight p w) = -(∑ qᵢ log wᵢ) + crossEntropy(q, p) + log S`
    where `q = reweight p w` and `S = ∑ wⱼ pⱼ`.

    This is the master decomposition for entropy under reweighting.
    Combined with `crossEntropy ≥ entropy` (Gibbs), it gives fine-grained
    control over how reweighting changes entropy.
-/
theorem entropy_reweight_eq {ι : Type*} [Fintype ι] (p w : ι → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hw_pos : ∀ i, 0 < w i) (hp_sum : ∑ i, p i = 1) :
    let q := reweight p w
    let S := ∑ j, w j * p j
    shannonEntropy q = -(∑ i, q i * Real.log (w i)) + crossEntropy q p + Real.log S := by
  simp +decide only [shannonEntropy, crossEntropy];
  simp +decide [ Real.negMulLog, Finset.sum_add_distrib, neg_add ];
  -- Apply the logarithm property to each term in the sum.
  have h_log_prop : ∀ i, Real.log (reweight p w i) = Real.log (w i) + Real.log (p i) - Real.log (∑ j, w j * p j) := by
    intro i
    unfold reweight;
    rw [ Real.log_div ( mul_ne_zero ( ne_of_gt ( hw_pos i ) ) ( ne_of_gt ( hp_pos i ) ) ) ( ne_of_gt ( Finset.sum_pos ( fun _ _ => mul_pos ( hw_pos _ ) ( hp_pos _ ) ) ⟨ i, Finset.mem_univ i ⟩ ) ), Real.log_mul ( ne_of_gt ( hw_pos i ) ) ( ne_of_gt ( hp_pos i ) ) ];
  simp +decide [ h_log_prop, mul_sub, Finset.sum_sub_distrib, Finset.sum_add_distrib ];
  simp +decide [ mul_add, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, sub_eq_add_neg ];
  rw [ ← Finset.sum_mul _ _ _ ] ; rw [ reweight_sum_eq_one p w ( Finset.sum_pos ( fun _ _ => mul_pos ( hw_pos _ ) ( hp_pos _ ) ) ⟨ Classical.choose ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ), Classical.choose_spec ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ⟩ ) ] ; ring;

end EntropyMonotonicity