/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import EulerMascheroni.Convergence

/-!
# Irrationality Criteria and Approximation Obstructions

This file establishes general Diophantine approximation criteria for irrationality
and applies them to the Euler–Mascheroni constant γ.

## Main results

### General irrationality criterion
* `irrational_of_good_approx` — if a real number admits infinitely many
  *distinct* rational approximants `p/q` with `|x - p/q| < 1/(2q²)`, then
  it is irrational. The key condition is `p/q ≠ x`.

### Counterexample / obstruction theorems
* `not_irrationality_certificate_of_O_one_over_q` — rational numbers can be
  approximated to `O(1/q)` quality, so this level is insufficient for irrationality.
* `rational_approx_lower_bound` — distinct rational approximants to a rational
  number satisfy `|x - p/q| ≥ 1/(dq)` where `d` is the denominator of `x`.

### Conditional irrationality of γ
* `irrational_eulerMascheroni_of_approx` — if γ admits infinitely many
  good rational approximants (quality `1/(2q²)`), then γ is irrational.

## Mathematical context

The irrationality of the Euler–Mascheroni constant γ is a major open problem.
These theorems isolate the *exact Diophantine threshold* that any irrationality
proof must cross: constructing rational approximants of quality `O(1/q²)`.
The counterexample theorems show that weaker `O(1/q)` approximations are
insufficient, since every rational number admits them trivially.
-/

namespace EulerMascheroni

open Finset Filter Real BigOperators

/-! ### Denominator separation -/

/-- For a rational number `a/b` with `b > 0`, any distinct rational `p/q`
    satisfies `|a/b - p/q| ≥ 1/(bq)`. This is the fundamental denominator
    separation lemma of Diophantine approximation. -/
theorem rational_approx_lower_bound
    (a : ℤ) (b : ℕ) (hb : 0 < b) (p : ℤ) (q : ℕ) (hq : 0 < q)
    (hne : (a : ℝ) / (b : ℝ) ≠ (p : ℝ) / (q : ℝ)) :
    1 / ((b : ℝ) * (q : ℝ)) ≤ |(a : ℝ) / (b : ℝ) - (p : ℝ) / (q : ℝ)| := by
  have h_diff : |(a : ℝ) * q - p * b| ≥ 1 := by
    exact mod_cast abs_pos.mpr (show (a * q - p * b : ℤ) ≠ 0 from fun h =>
      hne <| by rw [div_eq_div_iff] <;> norm_cast at * <;> linarith)
  rw [div_sub_div] <;> try positivity
  rw [abs_div, abs_of_nonneg (by positivity : (0 : ℝ) ≤ b * q)]
  gcongr; simpa [mul_comm] using h_diff

/-! ### General irrationality criterion -/

/-
**Irrationality from good rational approximation (with distinctness).**
    If a real number `x` has infinitely many *distinct* rational approximants
    `p/q` (meaning `p/q ≠ x`) with `|x - p/q| < 1/(2q²)`, then `x` is irrational.

    The proof is by contradiction: if `x = a/b` is rational, then for `p/q ≠ a/b`,
    the denominator separation lemma gives `1/(bq) ≤ |a/b - p/q|`, which combined
    with `|x - p/q| < 1/(2q²)` gives `2q < b`, i.e., `q < b/2`. Choosing
    `q ≥ b` yields a contradiction.
-/
theorem irrational_of_good_approx
    {x : ℝ}
    (h : ∀ N : ℕ, ∃ p : ℤ, ∃ q : ℕ, q ≥ N ∧ 0 < q ∧
      (p : ℝ) / (q : ℝ) ≠ x ∧
      |x - (p : ℝ) / (q : ℝ)| < 1 / (2 * (q : ℝ)^2)) :
    Irrational x := by
  by_contra h_rat;
  -- Since $x$ is rational, there exist integers $a$ and $b$ with $b > 0$ such that $x = a / b$.
  obtain ⟨a, b, hb_pos, hx_eq⟩ : ∃ a b : ℤ, b > 0 ∧ x = a / b := by
    unfold Irrational at h_rat;
    norm_num +zetaDelta at *;
    exact ⟨ h_rat.choose.num, h_rat.choose.den, Nat.cast_pos.mpr h_rat.choose.pos, by simpa only [ Rat.cast_def ] using h_rat.choose_spec.symm ⟩;
  -- Choose $N$ such that $N > b$.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, N > b := by
    exact exists_nat_gt b;
  obtain ⟨ p, q, hq₁, hq₂, hq₃, hq₄ ⟩ := h N ; have := rational_approx_lower_bound a b.natAbs ( by positivity ) p q ( by positivity ) ; simp_all +decide [ abs_div, abs_mul, abs_of_pos, hb_pos ];
  refine' absurd ( this ( Ne.symm hq₃ ) ) ( not_le_of_gt ( lt_of_lt_of_le hq₄ _ ) );
  field_simp;
  exact_mod_cast ( by linarith : ( b : ℤ ) ≤ q * 2 )

/-! ### Counterexample: O(1/q) approximation is insufficient -/

/-- Every rational number can be approximated with quality `C/q` for
    arbitrary `C > 0` and arbitrarily large denominators.
    This shows that `O(1/q)`-quality approximation is too weak to
    certify irrationality: it applies to rationals trivially.

    Proof: take `x = 0`, `p = 0`, `q = N+1`. Then `|0 - 0/(N+1)| = 0 < C/(N+1)`. -/
theorem not_irrationality_certificate_of_O_one_over_q
    (C : ℝ) (hC : 0 < C) :
    ∃ x : ℝ, ¬ Irrational x ∧
      ∀ N : ℕ, ∃ p : ℤ, ∃ q : ℕ, q ≥ N ∧ 0 < q ∧
        |x - (p : ℝ) / (q : ℝ)| < C / (q : ℝ) := by
  exact ⟨0, fun h => h.ne_zero rfl, fun N =>
    ⟨0, N + 1, by linarith, by linarith, by simpa using by positivity⟩⟩

/-! ### Conditional irrationality of γ -/

/-- **Conditional irrationality of the Euler–Mascheroni constant.**
    If γ admits infinitely many rational approximants *distinct from γ* with
    quality better than `1/(2q²)`, then γ is irrational.

    This theorem isolates the exact Diophantine condition that any
    irrationality proof for γ must establish. It transforms the open
    question "Is γ irrational?" into a concrete approximation task. -/
theorem irrational_eulerMascheroni_of_approx
    (h : ∀ N : ℕ, ∃ p : ℤ, ∃ q : ℕ, q ≥ N ∧ 0 < q ∧
      (p : ℝ) / (q : ℝ) ≠ eulerMascheroni ∧
      |eulerMascheroni - (p : ℝ) / (q : ℝ)| < 1 / (2 * (q : ℝ)^2)) :
    Irrational eulerMascheroni :=
  irrational_of_good_approx h

/-! ### Approximation rate of the Euler–Mascheroni sequence -/

/-
The Euler–Mascheroni sequence approaches γ from above: each term
    exceeds the limit for `n ≥ 1`.
-/
theorem eulerMascheroniSeq_sub_eulerMascheroni_pos (n : ℕ) (hn : 1 ≤ n) :
    0 < eulerMascheroniSeq n - eulerMascheroni := by
  refine' sub_pos_of_lt ( lt_of_le_of_lt _ ( show eulerMascheroniSeq ( n + 1 ) < eulerMascheroniSeq n from _ ) );
  · exact le_of_tendsto ( tendsto_eulerMascheroni ) ( Filter.eventually_atTop.mpr ⟨ n + 1, fun m hm => eulerMascheroniSeq_antitone _ _ ( by linarith ) hm ⟩ );
  · unfold eulerMascheroniSeq;
    norm_num [ harmonic_succ ];
    rw [ show ( n : ℝ ) + 1 = n * ( 1 + ( n : ℝ ) ⁻¹ ) by nlinarith only [ mul_inv_cancel₀ ( by positivity : ( n : ℝ ) ≠ 0 ) ], Real.log_mul ( by positivity ) ( by positivity ) ];
    ring_nf;
    nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ), inv_pos.mpr ( by positivity : 0 < ( n + n * ( n : ℝ ) ⁻¹ ) ), mul_inv_cancel₀ ( by positivity : ( n : ℝ ) ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( n + n * ( n : ℝ ) ⁻¹ ) ≠ 0 ), Real.log_inv ( 1 + ( n : ℝ ) ⁻¹ ), Real.log_lt_sub_one_of_pos ( inv_pos.mpr ( by positivity : 0 < ( 1 + ( n : ℝ ) ⁻¹ ) ) ) ( by aesop ), inv_mul_cancel₀ ( by positivity : ( 1 + ( n : ℝ ) ⁻¹ ) ≠ 0 ) ]

/-
Upper bound on convergence rate: the Euler–Mascheroni sequence
    satisfies `eulerMascheroniSeq n - eulerMascheroni < 1/n` for `n ≥ 1`.
-/
theorem eulerMascheroniSeq_sub_eulerMascheroni_lt (n : ℕ) (hn : 1 ≤ n) :
    eulerMascheroniSeq n - eulerMascheroni < 1 / (n : ℝ) := by
  have h_diff : eulerMascheroniSeq n - eulerMascheroni ≤ ∑' k : ℕ, (Real.log (1 + 1 / (n + k : ℝ)) - 1 / (n + k + 1 : ℝ)) := by
    have h_diff : eulerMascheroniSeq n - eulerMascheroni = ∑' k : ℕ, (eulerMascheroniSeq (n + k) - eulerMascheroniSeq (n + k + 1)) := by
      have h_diff : Filter.Tendsto (fun m => ∑ k ∈ Finset.range m, (eulerMascheroniSeq (n + k) - eulerMascheroniSeq (n + k + 1))) Filter.atTop (nhds (eulerMascheroniSeq n - eulerMascheroni)) := by
        have h_telescope : ∀ m : ℕ, ∑ k ∈ Finset.range m, (eulerMascheroniSeq (n + k) - eulerMascheroniSeq (n + k + 1)) = eulerMascheroniSeq n - eulerMascheroniSeq (n + m) := by
          exact fun m => by simpa using Finset.sum_range_sub' ( fun k => eulerMascheroniSeq ( n + k ) ) m;
        simpa only [ h_telescope ] using tendsto_const_nhds.sub ( tendsto_eulerMascheroni.comp ( Filter.tendsto_atTop_mono ( fun m => by simp +arith +decide ) tendsto_natCast_atTop_atTop ) );
      refine' tendsto_nhds_unique h_diff ( Summable.hasSum _ |> HasSum.tendsto_sum_nat );
      exact ( summable_iff_not_tendsto_nat_atTop_of_nonneg ( fun _ => sub_nonneg_of_le <| eulerMascheroniSeq_antitone _ _ ( by linarith ) ( by linarith ) ) ) |>.2 fun h => not_tendsto_nhds_of_tendsto_atTop h _ h_diff;
    have h_diff : ∀ k : ℕ, eulerMascheroniSeq (n + k) - eulerMascheroniSeq (n + k + 1) = Real.log (1 + 1 / (n + k : ℝ)) - 1 / (n + k + 1 : ℝ) := by
      intro k; unfold eulerMascheroniSeq; norm_num [ harmonic_succ ] ; ring;
      rw [ show ( 1 + ( n + k : ℝ ) ⁻¹ ) = ( 1 + n + k : ℝ ) / ( n + k : ℝ ) by rw [ inv_eq_one_div, add_div' ] <;> ring ; positivity, Real.log_div ] <;> ring <;> positivity;
    aesop;
  -- Each term in the sum is less than $1/(n+k) - 1/(n+k+1)$, which telescopes to $1/n$.
  have h_term_bound : ∀ k : ℕ, Real.log (1 + 1 / (n + k : ℝ)) - 1 / (n + k + 1 : ℝ) ≤ 1 / (n + k : ℝ) - 1 / (n + k + 1 : ℝ) := by
    exact fun k => sub_le_sub_right ( le_trans ( Real.log_le_sub_one_of_pos ( by positivity ) ) ( by norm_num ) ) _;
  have h_sum_bound : ∑' k : ℕ, (1 / (n + k : ℝ) - 1 / (n + k + 1 : ℝ)) = 1 / (n : ℝ) := by
    have h_sum_bound : ∀ N : ℕ, ∑ k ∈ Finset.range N, (1 / (n + k : ℝ) - 1 / (n + k + 1 : ℝ)) = 1 / (n : ℝ) - 1 / (n + N : ℝ) := by
      exact fun N => by convert Finset.sum_range_sub' _ _ using 3 <;> push_cast <;> ring;
    have h_sum_bound : Filter.Tendsto (fun N : ℕ => ∑ k ∈ Finset.range N, (1 / (n + k : ℝ) - 1 / (n + k + 1 : ℝ))) Filter.atTop (nhds (1 / (n : ℝ))) := by
      simpa only [ h_sum_bound ] using by simpa using tendsto_const_nhds.sub ( tendsto_inv_atTop_zero.comp ( show Filter.Tendsto ( fun N : ℕ => ( n : ℝ ) + N ) Filter.atTop ( Filter.atTop ) from Filter.tendsto_atTop_add_const_left _ _ tendsto_natCast_atTop_atTop ) ) ;
    refine' HasSum.tsum_eq _;
    rw [ hasSum_iff_tendsto_nat_of_nonneg ];
    · convert h_sum_bound using 1;
    · exact fun k => sub_nonneg_of_le <| one_div_le_one_div_of_le ( by positivity ) <| by linarith;
  refine' lt_of_le_of_lt h_diff ( lt_of_lt_of_le ( _ ) h_sum_bound.le );
  apply_rules [ Summable.tsum_lt_tsum ];
  · exact sub_lt_sub_right ( lt_of_lt_of_le ( Real.log_lt_sub_one_of_pos ( by positivity ) ( by norm_num; positivity ) ) ( by norm_num ) ) _;
  · refine' Summable.of_nonneg_of_le ( fun k => _ ) ( fun k => h_term_bound k ) _;
    · have h_log_bound : ∀ x : ℝ, 0 < x → Real.log (1 + x) ≥ x / (1 + x) := by
        exact fun x x_pos => by rw [ ge_iff_le ] ; rw [ div_le_iff₀ ( by positivity ) ] ; nlinarith [ Real.log_inv ( 1 + x ), Real.log_le_sub_one_of_pos ( inv_pos.mpr ( by positivity : 0 < ( 1 + x ) ) ), mul_inv_cancel₀ ( by positivity : ( 1 + x ) ≠ 0 ) ] ;
      exact sub_nonneg_of_le ( le_trans ( by rw [ div_le_div_iff₀ ] <;> nlinarith [ show ( n : ℝ ) ≥ 1 by norm_cast, one_div_mul_cancel ( by positivity : ( n : ℝ ) + k ≠ 0 ) ] ) ( h_log_bound _ ( by positivity ) ) );
    · exact ( by contrapose! h_sum_bound; erw [ tsum_eq_zero_of_not_summable h_sum_bound ] ; positivity );
  · exact ( by contrapose! h_sum_bound; erw [ tsum_eq_zero_of_not_summable h_sum_bound ] ; positivity )

end EulerMascheroni