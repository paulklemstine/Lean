import Mathlib
import MachineLearning.TropicalAttention.Defs

/-!
# Log-Sum-Exp Convergence to Tropical Maximum

The foundational analytic result: as temperature τ → 0⁺, the log-sum-exp operation
converges pointwise to the maximum. This is the rigorous content behind
"softmax attention is tropical in the log-semiring."

## Main Results

* `lse_squeeze_lower` — `max_j a_j ≤ τ * log(∑_j exp(a_j / τ))`
* `lse_squeeze_upper` — `τ * log(∑_j exp(a_j / τ)) ≤ max_j a_j + τ * log n`
* `lse_tendsto_sup` — `τ * log(∑_j exp(a_j / τ)) → max_j a_j` as `τ → 0⁺`
* `log_softmax_tends_to_row_tropical_normalization` — Theorem 1
* `logsumexp_composition_tends_to_tropical_mul` — Theorem 2
* `finite_temperature_attention_composition_tropicalizes` — Theorem 2 (with tropMulMax)
-/

noncomputable section

open Finset BigOperators Real Filter Topology

/-! ## Scalar log-sum-exp bounds -/

/-
The log of a sum of exponentials is at least the maximum exponent (scaled).
-/
theorem lse_squeeze_lower {n : ℕ} [NeZero n]
    (a : Fin n → ℝ) (τ : ℝ) (hτ : 0 < τ) :
    Finset.univ.sup' Finset.univ_nonempty a ≤
      τ * Real.log (∑ k : Fin n, Real.exp (a k / τ)) := by
  -- By definition of supremum, we know that for any $j$, $a_j \leq \tau \log \sum_{k} \exp(a_k / \tau)$.
  have h_le : ∀ j, a j ≤ τ * Real.log (∑ k, Real.exp (a k / τ)) := by
    intro j; rw [ ← div_le_iff₀' hτ ] ; exact Real.le_log_iff_exp_le ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) |>.2 ( by exact le_trans ( by norm_num [ ← Real.exp_mul, mul_div_cancel₀ _ hτ.ne' ] ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( a i / τ ) ) ( Finset.mem_univ j ) ) ) ;
  exact Finset.sup'_le _ _ fun i _ => h_le i

/-
The log of a sum of exponentials is at most the max exponent plus τ * log n.
-/
theorem lse_squeeze_upper {n : ℕ} [NeZero n]
    (a : Fin n → ℝ) (τ : ℝ) (hτ : 0 < τ) :
    τ * Real.log (∑ k : Fin n, Real.exp (a k / τ)) ≤
      Finset.univ.sup' Finset.univ_nonempty a + τ * Real.log n := by
  -- By dividing both sides of the inequality by τ, we obtain the desired result.
  have h_div : Real.log (∑ k : Fin n, Real.exp (a k / τ)) ≤ Real.log (n : ℝ) + (Finset.univ.sup' Finset.univ_nonempty a) / τ := by
    rw [ Real.log_le_iff_le_exp ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ];
    refine' le_trans ( Finset.sum_le_sum fun i _ => Real.exp_le_exp.mpr <| show a i / τ ≤ univ.sup' ( Finset.univ_nonempty ) a / τ from div_le_div_of_nonneg_right ( Finset.le_sup' ( fun x => a x ) ( Finset.mem_univ i ) ) hτ.le ) _ ; norm_num [ Real.exp_add, Real.exp_log, hτ.ne', NeZero.pos ];
  nlinarith [ mul_div_cancel₀ ( Finset.univ.sup' Finset.univ_nonempty a ) hτ.ne' ]

/-
**Core convergence theorem**: `τ * log(∑ exp(aₖ/τ)) → max aₖ` as `τ → 0⁺`.
-/
theorem lse_tendsto_sup {n : ℕ} [NeZero n]
    (a : Fin n → ℝ) :
    Tendsto
      (fun τ : ℝ => τ * Real.log (∑ k : Fin n, Real.exp (a k / τ)))
      (nhdsWithin (0 : ℝ) (Set.Ioi 0))
      (𝓝 (Finset.univ.sup' Finset.univ_nonempty a)) := by
  refine' ( tendsto_order.2 ⟨ fun x hx => _, fun x hx => _ ⟩ );
  · filter_upwards [ self_mem_nhdsWithin ] with τ hτ using hx.trans_le ( lse_squeeze_lower a τ hτ );
  · -- Since $x > \sup a$, there exists a $\delta > 0$ such that for all $b$ with $0 < b < \delta$, we have $\tau \log(n) < x - \sup a$.
    obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ b : ℝ, 0 < b ∧ b < δ → b * Real.log n < x - (Finset.univ.sup' Finset.univ_nonempty a) := by
      exact ⟨ ( x - Finset.univ.sup' Finset.univ_nonempty a ) / ( Real.log n + 1 ), div_pos ( sub_pos.mpr hx ) ( add_pos_of_nonneg_of_pos ( Real.log_natCast_nonneg _ ) zero_lt_one ), fun b hb => by nlinarith [ mul_div_cancel₀ ( x - Finset.univ.sup' Finset.univ_nonempty a ) ( show ( Real.log n + 1 ) ≠ 0 by linarith [ Real.log_nonneg ( Nat.one_le_cast.mpr ( NeZero.pos n ) ) ] ), Real.log_nonneg ( Nat.one_le_cast.mpr ( NeZero.pos n ) ) ] ⟩;
    filter_upwards [ Ioo_mem_nhdsGT hδ_pos ] with b hb using by linarith [ lse_squeeze_upper a b hb.1, hδ b hb ] ;

/-! ## Theorem 1: Zero-temperature softmax is tropical row normalization -/

/-
**Theorem 1.** For every finite score matrix S, the log-softmax at temperature τ
    converges pointwise to tropical row normalization as τ → 0⁺:
    `S i j - τ * log(∑_k exp(S i k / τ)) → S i j - max_k S i k`.
-/
theorem log_softmax_tends_to_row_tropical_normalization
    {n : ℕ} [NeZero n]
    (S : Matrix (Fin n) (Fin n) ℝ) :
    ∀ i j : Fin n,
      Tendsto
        (fun τ : ℝ =>
          S i j - τ * Real.log (∑ k : Fin n, Real.exp (S i k / τ)))
        (nhdsWithin (0 : ℝ) (Set.Ioi 0))
        (𝓝 (S i j - Finset.univ.sup' Finset.univ_nonempty (fun k : Fin n => S i k))) := by
  exact fun i j => tendsto_const_nhds.sub ( lse_tendsto_sup _ )

/-! ## Theorem 2: Tropicalization of attention composition -/

/-
**Theorem 2.** The log-sum-exp composition of two matrices converges to
    their tropical (max-plus) product as τ → 0⁺.
-/
theorem logsumexp_composition_tends_to_tropical_mul
    {m n p : ℕ} [NeZero m] [NeZero n] [NeZero p]
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ) :
    ∀ i : Fin m, ∀ k : Fin p,
      Tendsto
        (fun τ : ℝ =>
          τ * Real.log (∑ j : Fin n, Real.exp ((A i j + B j k) / τ)))
        (nhdsWithin (0 : ℝ) (Set.Ioi 0))
        (𝓝 (Finset.univ.sup' Finset.univ_nonempty (fun j : Fin n => A i j + B j k))) := by
  intro i k;
  convert lse_tendsto_sup ( fun j => A i j + B j k ) using 1

/-- **Theorem 2 (reformulated).** Finite-temperature attention composition
    tropicalizes to the max-plus matrix product. -/
theorem finite_temperature_attention_composition_tropicalizes
    {m n p : ℕ} [NeZero m] [NeZero n] [NeZero p]
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ) :
    ∀ i k, Tendsto
      (fun τ : ℝ =>
        τ * Real.log (∑ j : Fin n, Real.exp ((A i j + B j k) / τ)))
      (nhdsWithin (0 : ℝ) (Set.Ioi 0))
      (𝓝 ((tropMulMax A B) i k)) := by
  intro i k
  exact logsumexp_composition_tends_to_tropical_mul A B i k

end