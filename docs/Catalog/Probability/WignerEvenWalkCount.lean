/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Kernel-verified even-walk counts, and exact small-dimension trace moments

`Probability.WignerAllOrderParity` reduces every trace moment of the symmetric
Rademacher ensemble to a *count*:

`E [tr (W^(m+1))] = #{ closed (m+1)-walks that are loop-free with all edge
multiplicities even }`.

Because `RademacherWigner.IsEvenWalk` is decidable, this count is a finite,
kernel-checkable quantity.  This file records the packaged counting form
(`expect_trace_pow_eq_card`) together with several exact values obtained by
`decide` — a genuine verification of the numerical evidence of
`ComputationalEvidence.md` inside the kernel, rather than by an external
computation:

* `N = 3, m = 4`: `18` even closed walks, so `E [tr W⁴] = 18`, matching
  `2N(N-1)² - N(N-1) = 18`;
* `N = 4, m = 4`: `60`, matching `2·4·9 - 12 = 60`;
* `N = 2, m = 6`: `2`, and `N = 3, m = 6`: `66`, matching the conjectural sixth
  moment `N(N-1)(5N² - 15N + 11)` of `FUTURE_DIRECTIONS.md` (`2` and `66`);
* `N = 3, m = 3` and `N = 3, m = 5`: `0`, an independent kernel check of the
  odd-order vanishing theorem `expect_trace_pow_odd`.
-/
import Probability.WignerAllOrderParity

open Matrix BigOperators Finset

namespace RademacherWigner

variable {N : ℕ}

/-- The set of even closed `(m+1)`-walks, as a `Finset` of pairs
(starting vertex, intermediate vertices). -/
def evenWalks (N m : ℕ) : Finset (Fin N × (Fin m → Fin N)) :=
  (univ : Finset (Fin N × (Fin m → Fin N))).filter fun x => IsEvenWalk m x.1 x.2

/-- **The trace moments are literally a cardinality.**  `E [tr (W^(m+1))]` is the
number of even closed `(m+1)`-walks. -/
theorem expect_trace_pow_eq_card (m : ℕ) :
    expect (fun g : Config N => ((W g) ^ (m + 1)).trace) = (evenWalks N m).card := by
  rw [expect_trace_pow_eq_sum_indicator, evenWalks, Finset.card_filter]
  push_cast
  rw [Fintype.sum_prod_type]

/-! ### Kernel-verified counts -/

/-- There are `18` even closed `4`-walks on `3` vertices. -/
theorem card_evenWalks_three_four : (evenWalks 3 3).card = 18 := by decide

/-- There are `60` even closed `4`-walks on `4` vertices. -/
theorem card_evenWalks_four_four : (evenWalks 4 3).card = 60 := by decide

/-- There are `2` even closed `6`-walks on `2` vertices. -/
theorem card_evenWalks_two_six : (evenWalks 2 5).card = 2 := by decide

/-- There are `66` even closed `6`-walks on `3` vertices. -/
theorem card_evenWalks_three_six : (evenWalks 3 5).card = 66 := by decide

/-- There are no even closed `3`-walks on `3` vertices (odd order). -/
theorem card_evenWalks_three_three : (evenWalks 3 2).card = 0 := by decide

/-- There are no even closed `5`-walks on `3` vertices (odd order). -/
theorem card_evenWalks_three_five : (evenWalks 3 4).card = 0 := by decide

/-! ### The resulting exact moments -/

/-- `E [tr W⁴] = 18` in dimension `3`, in agreement with the closed formula
`2N(N-1)² - N(N-1)`. -/
theorem expect_trace_four_dim_three :
    expect (fun g : Config 3 => ((W g) ^ 4).trace) = 18 := by
  have h := expect_trace_pow_eq_card (N := 3) 3
  rw [card_evenWalks_three_four] at h
  norm_num at h ⊢
  exact h

/-- `E [tr W⁴] = 60` in dimension `4`. -/
theorem expect_trace_four_dim_four :
    expect (fun g : Config 4 => ((W g) ^ 4).trace) = 60 := by
  have h := expect_trace_pow_eq_card (N := 4) 3
  rw [card_evenWalks_four_four] at h
  norm_num at h ⊢
  exact h

/-- `E [tr W⁶] = 2` in dimension `2`, in agreement with the conjectural sixth-moment
formula `N(N-1)(5N² - 15N + 11)`. -/
theorem expect_trace_six_dim_two :
    expect (fun g : Config 2 => ((W g) ^ 6).trace) = 2 := by
  have h := expect_trace_pow_eq_card (N := 2) 5
  rw [card_evenWalks_two_six] at h
  norm_num at h ⊢
  exact h

/-- `E [tr W⁶] = 66` in dimension `3`, again matching `N(N-1)(5N² - 15N + 11)`.
Together with `expect_trace_six_dim_two` this is a kernel-checked confirmation of the
sixth-moment conjecture at `N = 2, 3`. -/
theorem expect_trace_six_dim_three :
    expect (fun g : Config 3 => ((W g) ^ 6).trace) = 66 := by
  have h := expect_trace_pow_eq_card (N := 3) 5
  rw [card_evenWalks_three_six] at h
  norm_num at h ⊢
  exact h

/-- `E [tr W⁵] = 0` in dimension `3`: an independent kernel check of
`expect_trace_pow_odd`. -/
theorem expect_trace_five_dim_three :
    expect (fun g : Config 3 => ((W g) ^ 5).trace) = 0 := by
  have h := expect_trace_pow_eq_card (N := 3) 4
  rw [card_evenWalks_three_five] at h
  norm_num at h ⊢
  exact h

end RademacherWigner