import Mathlib
import Speculative.SumThreeCubes.Defs

/-!
# Exact Counting and Asymptotic Density of Admissible Integers

We prove that `admissibleCount(9q + r) = 7q + tail(r)` where `tail(r)` counts
the admissible residues below `r`. This yields the bounded error estimate
`|9 * admissibleCount(N) - 7 * N| ≤ 8`, which immediately implies the
natural density of admissible integers is exactly 7/9.

## Strategy

Partition `Finset.range (9*q + r)` into `q` complete blocks of length 9 plus a
tail of length `r`. Each complete block contributes exactly 7 admissible integers
(since residues 4 and 5 are the only forbidden ones). The tail contributes at
most 7 and the error is bounded by the difference between `7*r/9` and the tail count.
-/

open Finset

/-- Helper: count of admissible residues below `r` (for `r < 9`). -/
def admissibleTail (r : ℕ) : ℕ :=
  ((Finset.range r).filter (fun n : ℕ => decide (CubeSumAdmissible (n : ℤ)))).card

/-- The exact counting formula: admissibleCount decomposes into
full blocks of 7 plus a tail. -/
theorem admissibleCount_eq (q r : ℕ) (hr : r < 9) :
    admissibleCount (9 * q + r) = 7 * q + admissibleTail r := by
  induction' q with q IH
  · interval_cases r <;> native_decide
  · simp_all +arith +decide [Nat.mul_succ, admissibleCount, admissibleTail]
    rw [← IH, Finset.range_add, Finset.filter_union]
    rw [Finset.card_union_of_disjoint]
    · simp_all +decide [CubeSumAdmissible, Finset.filter_map]
      interval_cases r <;> norm_cast
      all_goals simp +arith +decide [Function.comp, Nat.add_mod, Finset.filter]
    · norm_num [Finset.disjoint_right]

/-
The bounded error estimate: `|9 * admissibleCount(N) - 7 * N| ≤ 8`.
This implies the natural density of admissible integers is 7/9.
-/
theorem admissibleCount_error_bound (N : ℕ) :
    |(admissibleCount N : ℤ) * 9 - 7 * N| ≤ 8 := by
  -- Write N = 9*q + r with r < 9 using Nat.div_add_mod. Apply admissibleCount_eq to get admissibleCount N = 7*q + admissibleTail r.
  obtain ⟨q, r, hr⟩ : ∃ q r, N = 9 * q + r ∧ r < 9 := by
    exact ⟨ N / 9, N % 9, by rw [ Nat.div_add_mod ], Nat.mod_lt _ <| by decide ⟩;
  rw [ hr.1 ];
  rw [ admissibleCount_eq q r hr.2 ] ; norm_num ; ring_nf ;
  rcases hr with ⟨ rfl, hr ⟩ ; interval_cases r <;> native_decide;

/-
The natural density of admissible integers is 7/9.
-/
theorem tendsto_admissible_density :
    Filter.Tendsto
      (fun N : ℕ => (admissibleCount N : ℝ) / N)
      Filter.atTop
      (nhds (7 / 9 : ℝ)) := by
  -- We'll use the fact that |admissibleCount(N)/N - 7/9| ≤ 8/(9*N) to show that the limit is indeed 7/9.
  have h_bound : ∀ N > 0, abs ((admissibleCount N : ℝ) / N - 7 / 9) ≤ 8 / (9 * N) := by
    intro N hN_pos
    have h_error : abs ((admissibleCount N : ℤ) * 9 - 7 * N) ≤ 8 := by
      convert admissibleCount_error_bound N using 1;
    rw [ div_sub_div, abs_div ] <;> try positivity;
    rw [ mul_comm ( N : ℝ ) 7, mul_comm ( 9 : ℝ ) N ] ; gcongr ; norm_cast at *;
    exact le_abs_self _;
  exact tendsto_iff_norm_sub_tendsto_zero.mpr <| squeeze_zero_norm' ( Filter.eventually_atTop.mpr ⟨ 1, fun N hN => by simpa using h_bound N <| by positivity ⟩ ) <| tendsto_const_nhds.div_atTop <| Filter.Tendsto.const_mul_atTop ( by norm_num ) <| tendsto_natCast_atTop_atTop