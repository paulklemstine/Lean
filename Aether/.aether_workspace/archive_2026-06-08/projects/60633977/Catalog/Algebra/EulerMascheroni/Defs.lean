/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Euler–Mascheroni Constant: Definitions and Core Properties

This file defines the harmonic numbers, the Euler renormalization sequence,
and the Euler–Mascheroni constant γ. It proves that the renormalization
sequence is decreasing and bounded below, yielding the existence of γ as a limit.

## Main definitions

* `EulerGamma.harmonicSum n` — the n-th harmonic number H_n = ∑_{k=1}^{n} 1/k
* `EulerGamma.eulerRenorm n` — the renormalized sequence E_n = H_{n+1} - log(n+1)
* `EulerGamma.eulerMascheroni` — the Euler–Mascheroni constant γ = lim E_n

## Main results

* `EulerGamma.eulerRenorm_antitone` — E_n is a decreasing sequence
* `EulerGamma.eulerRenorm_pos` — E_n > 0 for all n
* `EulerGamma.eulerRenorm_tendsto` — E_n converges to γ
* `EulerGamma.euler_error_nonneg` — E_n - γ ≥ 0 for all n
* `EulerGamma.euler_error_upper` — E_n - γ ≤ 1/(n+1)
-/

namespace EulerGamma

open Finset Filter Topology BigOperators Real

noncomputable section

/-! ## Harmonic numbers -/

/-- The n-th harmonic number: H_n = ∑_{k=1}^{n} 1/k,
    implemented as ∑_{k ∈ range n} 1/(k+1). -/
def harmonicSum (n : ℕ) : ℝ := ∑ k ∈ Finset.range n, (1 : ℝ) / (↑k + 1)

@[simp]
theorem harmonicSum_zero : harmonicSum 0 = 0 := by simp [harmonicSum]

theorem harmonicSum_succ (n : ℕ) :
    harmonicSum (n + 1) = harmonicSum n + 1 / (↑n + 1) := by
  simp [harmonicSum, Finset.sum_range_succ]

theorem harmonicSum_pos (n : ℕ) (hn : 0 < n) : 0 < harmonicSum n := by
  exact Finset.sum_pos ( fun _ _ => by positivity ) ( by aesop )

/-! ## Euler renormalization sequence -/

/-- The Euler renormalization sequence: E_n = H_{n+1} - log(n+1).
    This sequence decreases monotonically to the Euler–Mascheroni constant γ. -/
def eulerRenorm (n : ℕ) : ℝ := harmonicSum (n + 1) - Real.log (↑n + 1)

/-! ## Logarithmic inequalities -/

/-- For x > 0, log(x) ≤ x - 1. -/
theorem log_le_sub_one' (x : ℝ) (hx : 0 < x) : Real.log x ≤ x - 1 :=
  Real.log_le_sub_one_of_pos hx

/-
For x > 0, 1 - 1/x ≤ log(x). Equivalently, log(x) ≥ 1 - 1/x.
-/
theorem one_sub_inv_le_log (x : ℝ) (hx : 0 < x) : 1 - 1/x ≤ Real.log x := by
  have := Real.log_le_sub_one_of_pos ( inv_pos.mpr hx ) ; norm_num at * ; linarith;

/-! ## Monotonicity -/

/-
The Euler renormalization sequence is antitone (decreasing):
    E_{n+1} ≤ E_n for all n. This uses the inequality log(1+t) ≥ t/(1+t).
-/
theorem eulerRenorm_antitone : Antitone eulerRenorm := by
  refine' antitone_nat_of_succ_le _;
  intro n
  unfold eulerRenorm
  simp [harmonicSum_succ];
  have := one_sub_inv_le_log ( ( n + 1 + 1 ) / ( n + 1 ) ) ( by positivity );
  rw [ Real.log_div ] at this <;> norm_num at * <;> nlinarith [ mul_div_cancel₀ ( ( n : ℝ ) + 1 ) ( by linarith : ( n : ℝ ) + 1 + 1 ≠ 0 ), inv_mul_cancel₀ ( by linarith : ( n : ℝ ) + 1 ≠ 0 ), inv_mul_cancel₀ ( by linarith : ( n : ℝ ) + 1 + 1 ≠ 0 ) ]

/-! ## Positivity -/

/-
Each term of the Euler renormalization sequence is positive:
    H_{n+1} > log(n+1) for all n. This uses the inequality 1/k > log(k+1) - log(k)
    which follows from log(x) ≤ x - 1.
-/
theorem eulerRenorm_pos (n : ℕ) : 0 < eulerRenorm n := by
  -- By definition of $harmonicSum$, we know that $harmonicSum (n + 1) \geq \log (n + 2)$.
  have h_harmonic_log : ∀ n : ℕ, harmonicSum (n + 1) ≥ Real.log (n + 2) := by
    intro n;
    induction' n with n ih <;> norm_num [ Finset.sum_range_succ, harmonicSum ] at *;
    · linarith [ Real.log_le_sub_one_of_pos zero_lt_two ];
    · rw [ show ( n + 1 + 2 : ℝ ) = ( n + 2 ) * ( 1 + ( n + 1 + 1 : ℝ ) ⁻¹ ) by nlinarith [ mul_inv_cancel₀ ( by linarith : ( n + 1 + 1 : ℝ ) ≠ 0 ) ], Real.log_mul ( by linarith ) ( by positivity ) ];
      exact add_le_add ih ( le_trans ( Real.log_le_sub_one_of_pos ( by positivity ) ) ( by norm_num ) );
  exact sub_pos_of_lt ( lt_of_lt_of_le ( Real.log_lt_log ( by positivity ) ( by linarith ) ) ( h_harmonic_log n ) )

/-- The Euler renormalization sequence is bounded below by 0. -/
theorem eulerRenorm_bddBelow : BddBelow (Set.range eulerRenorm) :=
  ⟨0, by rintro _ ⟨n, rfl⟩; exact le_of_lt (eulerRenorm_pos n)⟩

/-! ## Existence of limit and definition of γ -/

/-- The Euler–Mascheroni constant γ, defined as the infimum of the
    Euler renormalization sequence. Since the sequence is antitone and
    bounded below, this equals the limit. -/
noncomputable def eulerMascheroni : ℝ := ⨅ n, eulerRenorm n

/-- The Euler renormalization sequence converges to the Euler–Mascheroni constant. -/
theorem eulerRenorm_tendsto :
    Tendsto eulerRenorm atTop (nhds eulerMascheroni) :=
  tendsto_atTop_ciInf eulerRenorm_antitone eulerRenorm_bddBelow

/-- The Euler–Mascheroni constant is nonneg. -/
theorem eulerMascheroni_nonneg : 0 ≤ eulerMascheroni :=
  le_ciInf (fun n => le_of_lt (eulerRenorm_pos n))

/-- The error E_n - γ is always nonneg (E_n decreases to γ from above). -/
theorem euler_error_nonneg (n : ℕ) : 0 ≤ eulerRenorm n - eulerMascheroni :=
  sub_nonneg.mpr (ciInf_le eulerRenorm_bddBelow n)

/-! ## Error bound -/

/-
The error E_n - γ is at most 1/(n+1).
-/
theorem euler_error_upper (n : ℕ) :
    eulerRenorm n - eulerMascheroni ≤ 1 / (↑n + 1) := by
  -- By the properties of the Euler renormalization sequence, we have that for all $k$, $\text{eulerRenorm}(n) - \text{eulerRenorm}(n+k) \leq \frac{1}{n+1}$.
  have h_bound : ∀ k : ℕ, eulerRenorm n - eulerRenorm (n + k) ≤ 1 / (n + 1) := by
    intro k
    have h_sum : eulerRenorm n - eulerRenorm (n + k) = ∑ j ∈ Finset.range k, (eulerRenorm (n + j) - eulerRenorm (n + j + 1)) := by
      exact Nat.recOn k ( by norm_num ) fun j ih => by rw [ Nat.add_succ, Finset.sum_range_succ, ← ih ] ; ring;
    -- Each term in the sum is less than or equal to $1/(n+j+1) - 1/(n+j+2)$.
    have h_term_bound : ∀ j : ℕ, eulerRenorm (n + j) - eulerRenorm (n + j + 1) ≤ 1 / (n + j + 1 : ℝ) - 1 / (n + j + 2 : ℝ) := by
      intro j
      have h_term_bound : eulerRenorm (n + j) - eulerRenorm (n + j + 1) = Real.log ((n + j + 2) / (n + j + 1)) - 1 / (n + j + 2 : ℝ) := by
        unfold eulerRenorm;
        norm_num [ harmonicSum ];
        rw [ Real.log_div ] <;> norm_num [ Finset.sum_range_succ ] <;> ring <;> positivity;
      have := Real.log_le_sub_one_of_pos ( by positivity : 0 < ( n + j + 2 : ℝ ) / ( n + j + 1 ) );
      grind +qlia;
    -- Summing these inequalities from $j=0$ to $j=k-1$, we get $\text{eulerRenorm}(n) - \text{eulerRenorm}(n+k) \leq \sum_{j=0}^{k-1} \left( \frac{1}{n+j+1} - \frac{1}{n+j+2} \right)$.
    have h_sum_bound : eulerRenorm n - eulerRenorm (n + k) ≤ ∑ j ∈ Finset.range k, (1 / (n + j + 1 : ℝ) - 1 / (n + j + 2 : ℝ)) := by
      exact h_sum.symm ▸ Finset.sum_le_sum fun _ _ => h_term_bound _;
    -- The series $\sum_{j=0}^{k-1} \left( \frac{1}{n+j+1} - \frac{1}{n+j+2} \right)$ is a telescoping series.
    have h_telescoping : ∑ j ∈ Finset.range k, (1 / (n + j + 1 : ℝ) - 1 / (n + j + 2 : ℝ)) = 1 / (n + 1 : ℝ) - 1 / (n + k + 1 : ℝ) := by
      convert Finset.sum_range_sub' ( fun x => 1 / ( n + x + 1 : ℝ ) ) k using 3 <;> push_cast <;> ring;
    exact h_sum_bound.trans ( h_telescoping ▸ sub_le_self _ ( by positivity ) );
  -- Taking the limit of the bound as $k$ approaches infinity, we get the desired inequality.
  have h_limit : Filter.Tendsto (fun k : ℕ => eulerRenorm n - eulerRenorm (n + k)) Filter.atTop (nhds (eulerRenorm n - eulerMascheroni)) := by
    exact tendsto_const_nhds.sub ( eulerRenorm_tendsto.comp <| Filter.tendsto_atTop_mono ( fun k => by simp +arith +decide ) tendsto_natCast_atTop_atTop );
  exact le_of_tendsto_of_tendsto' h_limit tendsto_const_nhds h_bound

end

end EulerGamma