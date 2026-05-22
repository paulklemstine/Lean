/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import EulerMascheroni.Defs

/-!
# Euler–Mascheroni Constant: Convergence

We prove that the Euler–Mascheroni sequence `a_n = H_n - log(n)` converges,
establishing the existence of the Euler–Mascheroni constant γ. The proof uses
monotone convergence: we show the sequence is eventually decreasing and bounded below.

## Main results

* `eulerMascheroniSeq_antitone` — the sequence is antitone for n ≥ 1
* `eulerMascheroniSeq_pos` — the sequence is positive for n ≥ 1
* `tendsto_eulerMascheroniSeq` — convergence to a limit
* `eulerMascheroni` — the Euler–Mascheroni constant γ

## Strategy

The key inequalities are:
1. `1/(n+1) < log((n+1)/n)` — gives that `a_n` is decreasing
2. `H_n > log(n+1)` — gives that `a_n > log(n+1) - log(n) > 0`

Both follow from the integral comparison `∫_k^{k+1} 1/x dx` vs `1/k` and `1/(k+1)`.
-/

namespace EulerMascheroni

open Finset Filter Real BigOperators

/-! ### Key logarithmic inequalities -/

/-
For `x > 0`, `log(1 + x) ≤ x`. Equivalently, `1 + x ≤ exp(x)`.
-/
theorem log_one_add_le (x : ℝ) (hx : 0 < x) : Real.log (1 + x) ≤ x := by
  linarith [ Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + x ) ]

/-
For `x > 0`, `x / (1 + x) < log(1 + x)`. This is equivalent to
    `1/(n+1) < log((n+1)/n)` when `x = 1/n`.
-/
theorem lt_log_one_add (x : ℝ) (hx : 0 < x) : x / (1 + x) < Real.log (1 + x) := by
  rw [ div_lt_iff₀ ( by positivity ) ];
  nlinarith [ Real.log_inv ( 1 + x ), Real.log_lt_sub_one_of_pos ( inv_pos.mpr ( by linarith : 0 < 1 + x ) ) ( by nlinarith [ inv_mul_cancel₀ ( by linarith : ( 1 + x ) ≠ 0 ) ] ), inv_mul_cancel₀ ( by linarith : ( 1 + x ) ≠ 0 ) ]

/-! ### Monotonicity of the Euler–Mascheroni sequence -/

/-
The Euler–Mascheroni sequence satisfies `a_{n+1} ≤ a_n` for `n ≥ 1`.
    This follows from `log((n+1)/n) ≥ 1/(n+1)`.
-/
theorem eulerMascheroniSeq_succ_le (n : ℕ) (hn : 1 ≤ n) :
    eulerMascheroniSeq (n + 1) ≤ eulerMascheroniSeq n := by
  unfold eulerMascheroniSeq;
  rw [ harmonic_succ ];
  have := lt_log_one_add ( 1 / ( n : ℝ ) ) ( by positivity );
  norm_num [ add_comm, add_left_comm, add_assoc ] at *;
  rw [ show ( n : ℝ ) ⁻¹ + 1 = ( n + 1 ) / n by ring_nf; norm_num [ show n ≠ 0 by linarith ], Real.log_div ] at this <;> norm_num at * <;> try linarith;
  rw [ div_div_eq_mul_div, inv_mul_cancel₀ ( by positivity ) ] at this ; ring_nf at * ; linarith

/-! ### Lower bound -/

/-
The harmonic sum exceeds `log(n+1)` for all `n ≥ 1`.
    This follows from the integral comparison `1/k > ∫_k^{k+1} 1/x dx = log((k+1)/k)`.
-/
theorem log_succ_le_harmonic (n : ℕ) (hn : 1 ≤ n) :
    Real.log (↑n + 1) ≤ harmonic n := by
  induction hn <;> simp_all +decide [ Nat.cast_add, Nat.cast_one, harmonic_succ ];
  · exact le_trans ( Real.log_le_sub_one_of_pos ( by norm_num ) ) ( by norm_num );
  · rw [ Real.log_le_iff_le_exp ( by positivity ) ] at *;
    rw [ Real.exp_add ];
    nlinarith [ Real.add_one_le_exp ( ( ↑‹ℕ› : ℝ ) + 1 ) ⁻¹, Real.exp_pos ( ( ↑‹ℕ› : ℝ ) + 1 ) ⁻¹, mul_inv_cancel₀ ( by positivity : ( ( ↑‹ℕ› : ℝ ) + 1 ) ≠ 0 ) ]

/-
The Euler–Mascheroni sequence is positive for `n ≥ 1`.
-/
theorem eulerMascheroniSeq_pos (n : ℕ) (hn : 1 ≤ n) :
    0 < eulerMascheroniSeq n := by
  exact sub_pos_of_lt ( lt_of_lt_of_le ( Real.log_lt_log ( by positivity ) ( by norm_num ) ) ( log_succ_le_harmonic _ hn ) )

/-! ### Convergence -/

/-
The Euler–Mascheroni sequence is eventually antitone.
-/
theorem eulerMascheroniSeq_antitone :
    ∀ m n : ℕ, 1 ≤ m → m ≤ n → eulerMascheroniSeq n ≤ eulerMascheroniSeq m := by
  intros m n hm hmn;
  induction hmn <;> simp_all +decide [ Nat.succ_eq_add_one, eulerMascheroniSeq_succ_le ];
  exact le_trans ( eulerMascheroniSeq_succ_le _ ( by linarith ) ) ‹_›

/-
The Euler–Mascheroni sequence is bounded below by 0.
-/
theorem eulerMascheroniSeq_bddBelow :
    BddBelow (Set.range (fun n => eulerMascheroniSeq (n + 1))) := by
  exact ⟨ 0, Set.forall_mem_range.mpr fun n => le_of_lt ( eulerMascheroniSeq_pos _ ( Nat.succ_pos _ ) ) ⟩

/-
**Main theorem**: The Euler–Mascheroni sequence converges.
-/
theorem tendsto_eulerMascheroniSeq :
    ∃ γ : ℝ, Tendsto eulerMascheroniSeq atTop (nhds γ) := by
  -- The added constant 1 does away with the case about n=0.
  have h_shift_bddBelow : BddBelow (Set.range (fun n ↦ eulerMascheroniSeq (n + 1))) := by
    exact EulerMascheroni.eulerMascheroniSeq_bddBelow
  have h_shift_antitone : Antitone (fun n ↦ eulerMascheroniSeq (n + 1)) := by
    exact antitone_nat_of_succ_le fun n => eulerMascheroniSeq_antitone _ _ ( Nat.succ_pos _ ) ( Nat.le_succ _ )
  have v_tendsto_zero : ∃ r : ℝ, (Filter.Tendsto (fun n => eulerMascheroniSeq (n + 1)) Filter.atTop (nhds r)) := by
    exact ⟨ _, tendsto_atTop_ciInf h_shift_antitone h_shift_bddBelow ⟩;
  exact ⟨ v_tendsto_zero.choose, Filter.tendsto_add_atTop_iff_nat 1 |>.1 v_tendsto_zero.choose_spec ⟩

/-- The Euler–Mascheroni constant γ, defined as the limit of `H_n - log(n)`. -/
noncomputable def eulerMascheroni : ℝ := Classical.choose tendsto_eulerMascheroniSeq

/-- The Euler–Mascheroni sequence converges to `eulerMascheroni`. -/
theorem tendsto_eulerMascheroni :
    Tendsto eulerMascheroniSeq atTop (nhds eulerMascheroni) :=
  Classical.choose_spec tendsto_eulerMascheroniSeq

/-
The Euler–Mascheroni constant is positive.
-/
theorem eulerMascheroni_pos : 0 < eulerMascheroni := by
  refine' lt_of_lt_of_le _ ( le_of_tendsto_of_tendsto tendsto_const_nhds tendsto_eulerMascheroni <| Filter.eventually_atTop.mpr _ );
  swap;
  exact 1 - Real.log 2;
  · exact sub_pos_of_lt ( Real.log_two_lt_d9.trans_le ( by norm_num ) );
  · use 1;
    intro n hn;
    -- We'll use the fact that $H_n - \log(n+1) \geq 1 - \log 2$ for all $n \geq 1$.
    have h_lower_bound : ∀ n : ℕ, 1 ≤ n → harmonic n - Real.log (n + 1) ≥ 1 - Real.log 2 := by
      intro n hn
      induction' n, hn using Nat.le_induction with n hn ih;
      · norm_num [ harmonic ];
      · -- Using the induction hypothesis and the fact that $1/(n+1) > \log(n+2) - \log(n+1)$, we can show that the inequality holds.
        have h_step : 1 / (n + 1 : ℝ) > Real.log (n + 2) - Real.log (n + 1) := by
          rw [ ← Real.log_div ( by positivity ) ( by positivity ) ];
          exact lt_of_lt_of_le ( Real.log_lt_sub_one_of_pos ( by positivity ) ( by rw [ div_eq_mul_inv ] ; nlinarith [ mul_inv_cancel₀ ( by positivity : ( n : ℝ ) + 1 ≠ 0 ) ] ) ) ( by ring_nf; nlinarith [ mul_inv_cancel₀ ( by positivity : ( 1 + n : ℝ ) ≠ 0 ) ] );
        norm_num [ add_assoc, harmonic_succ ] at * ; linarith;
    exact le_trans ( h_lower_bound n hn ) ( sub_le_sub_left ( Real.log_le_log ( by positivity ) ( by linarith ) ) _ )

/-
The Euler–Mascheroni constant is at most 1.
-/
theorem eulerMascheroni_le_one : eulerMascheroni ≤ 1 := by
  exact le_of_tendsto tendsto_eulerMascheroni ( Filter.eventually_atTop.mpr ⟨ 1, fun n hn => by linarith [ eulerMascheroniSeq_antitone 1 n le_rfl hn, show eulerMascheroniSeq 1 ≤ 1 by simp [ eulerMascheroniSeq, harmonic ] ] ⟩ )

end EulerMascheroni