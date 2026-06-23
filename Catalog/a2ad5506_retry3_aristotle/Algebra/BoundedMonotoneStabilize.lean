/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bounded monotone `ℕ → ℕ` sequences stabilize

A monotone (non-decreasing) sequence `f : ℕ → ℕ` that is bounded above by some
`B : ℕ` must eventually become constant.  We give an elementary, well-ordering
based proof and quantify the number of strict improvements.  We then show that
there is no uniform bound on the *index* at which stabilization occurs: the step
function `stepFun B K` is monotone and bounded by `B ≥ 1` but does not stabilize
before index `K`.

## Main results

* `bounded_monotone_stabilizes` — a bounded monotone sequence stabilizes.
* `strict_improvement_count_le` — at most `B` strict improvements occur.
* `stepFun_bounded`, `stepFun_not_stabilize_before`,
  `stabilization_index_unbounded` — the index of stabilization is unbounded.
-/

import Mathlib

namespace BoundedMonotoneStabilize

/-- `f` is monotone (non-decreasing). -/
def IsMonotone (f : ℕ → ℕ) : Prop := ∀ m n, m ≤ n → f m ≤ f n

/-- `f` is bounded above by `B`. -/
def IsBoundedBy (f : ℕ → ℕ) (B : ℕ) : Prop := ∀ n, f n ≤ B

/-- `f` stabilizes at index `j`: it is constant from `j` onwards. -/
def StabilizesAt (f : ℕ → ℕ) (j : ℕ) : Prop := ∀ n, j ≤ n → f n = f j

/-
A bounded monotone sequence eventually stabilizes.
-/
theorem bounded_monotone_stabilizes (f : ℕ → ℕ) (B : ℕ)
    (hmono : IsMonotone f) (hb : IsBoundedBy f B) :
    ∃ j, StabilizesAt f j := by
  -- Since $f$ is monotone and bounded above, it must reach its maximum value.
  have h_max : ∃ m ∈ Set.range f, ∀ n ∈ Set.range f, n ≤ m := by
    apply_rules [ Set.exists_max_image ];
    · exact Set.finite_iff_bddAbove.mpr ⟨ B, Set.forall_mem_range.mpr hb ⟩;
    · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
  obtain ⟨ m, ⟨ j, rfl ⟩, hm ⟩ := h_max; exact ⟨ j, fun n hn => le_antisymm ( hm _ <| Set.mem_range_self _ ) ( hmono _ _ hn ) ⟩ ;

/-
A bounded monotone sequence has at most `B` strict improvements among the
first `N` steps.
-/
theorem strict_improvement_count_le (f : ℕ → ℕ) (B N : ℕ)
    (hmono : IsMonotone f) (hb : IsBoundedBy f B) :
    ((Finset.range N).filter (fun n => f n < f (n + 1))).card ≤ B := by
  -- Consider the set of indices $n$ such that $f(n) < f(n+1)$.
  set S := Finset.filter (fun n => f n < f (n + 1)) (Finset.range N) with hS_def;
  -- Each index $n$ in $S$ corresponds to a strict increase in the sequence, contributing at least 1 to the sum $f(N) - f(0)$.
  have h_sum : ∑ n ∈ S, (f (n + 1) - f n) ≤ f N - f 0 := by
    have h_sum : ∑ n ∈ Finset.range N, (f (n + 1) - f n) ≤ f N - f 0 := by
      exact Nat.le_sub_of_add_le ( by exact Nat.recOn N ( by norm_num ) fun n ihn => by rw [ Finset.sum_range_succ ] ; linarith [ Nat.sub_add_cancel ( show f n ≤ f ( n + 1 ) from hmono _ _ ( Nat.le_succ _ ) ) ] );
    exact le_trans ( Finset.sum_le_sum_of_subset ( Finset.filter_subset _ _ ) ) h_sum;
  exact le_trans ( by simpa using Finset.sum_le_sum fun i ( hi : i ∈ S ) => Nat.succ_le_of_lt <| Nat.sub_pos_of_lt <| Finset.mem_filter.mp hi |>.2 ) ( h_sum.trans <| Nat.sub_le_of_le_add <| by linarith [ hb 0, hb N ] )

/-- The step function: `0` below `K`, `1` from `K` onwards. -/
def stepFun (B K : ℕ) : ℕ → ℕ
  | n => if n < K then 0 else 1

/-- The step function is monotone. -/
lemma stepFun_monotone (B K : ℕ) : IsMonotone (stepFun B K) := by
  intro m n hmn
  simp only [stepFun]
  by_cases hm : m < K <;> by_cases hn : n < K <;> simp only [hm, hn, if_true, if_false] <;> omega

/-
The step function is bounded by `B` whenever `1 ≤ B`.
-/
theorem stepFun_bounded (B K : ℕ) (hB : 1 ≤ B) : IsBoundedBy (stepFun B K) B := by
  exact fun n => by rw [ stepFun ] ; split_ifs <;> linarith;

/-
The step function does not stabilize before index `K`.
-/
theorem stepFun_not_stabilize_before (B K : ℕ) (j : ℕ) (hj : j < K) :
    ¬ StabilizesAt (stepFun B K) j := by
  -- Assume StabilizesAt (stepFun B K) j, i.e. ∀ n, j ≤ n → stepFun B K n = stepFun B K j.
  by_contra h
  have hK : stepFun B K K = stepFun B K j := by
    exact h K hj.le;
  unfold stepFun at hK; aesop;

/-
The index at which a bounded monotone sequence stabilizes is unbounded:
for every `K` there is a monotone sequence bounded by `B` that does not
stabilize before `K`.
-/
theorem stabilization_index_unbounded (B K : ℕ) (hB : 1 ≤ B) :
    ∃ f, IsMonotone f ∧ IsBoundedBy f B ∧ ∀ j < K, ¬ StabilizesAt f j := by
  use stepFun B K, stepFun_monotone B K, stepFun_bounded B K hB, stepFun_not_stabilize_before B K

end BoundedMonotoneStabilize