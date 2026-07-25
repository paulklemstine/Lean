import Mathlib

/-!
# The `d = 1` case: random recursive trees

The descendant limit law for random recursive `d`-DAGs specialises, at `d = 1`, to the
classical random recursive tree (Drmota, 2009).  Here the mean-growth product
`P_n(a) = ∏_{k=1}^n (1 + a/k)` is taken with `a = 1`, and it degenerates to a strikingly
simple closed form.

The main results are:

* `descProductOne_eq` : the exact identity `P_n(1) = n + 1`, so the expected number of
  descendants grows **linearly** in `n` (in contrast to the `n^{1/d}` growth for
  `d ≥ 2`);
* `descProductOne_div_tendsto` : consequently `P_n(1) / n ⟶ 1`, i.e. the scaling
  exponent is exactly `1`, the `d = 1` value of `1/d`.

The product is defined here independently so that this file is self-contained.
-/

open Real Filter Topology

namespace DDAG

/-- The mean-growth product `P_n(a) = ∏_{k=1}^n (1 + a/k)` (repeated here so the file is
self-contained). -/
noncomputable def rrtProduct (a : ℝ) (n : ℕ) : ℝ := ∏ k ∈ Finset.Icc 1 n, (1 + a / (k : ℝ))

/-
**Closed form at `a = 1`.** For the random recursive tree, `P_n(1) = n + 1`.
-/
theorem descProductOne_eq (n : ℕ) : rrtProduct 1 n = (n : ℝ) + 1 := by
  unfold rrtProduct
  induction n with
  | zero => simp
  | succ n ih =>
    rw [ Finset.prod_Icc_succ_top (Nat.le_add_left 1 n), ih ]
    have : ((n : ℝ) + 1) ≠ 0 := by positivity
    push_cast
    field_simp

/-
**Linear scaling of descendants for `d = 1`.** `P_n(1) / n ⟶ 1`, so the scaling
exponent equals `1`, matching the value `1/d` at `d = 1`.
-/
theorem descProductOne_div_tendsto :
    Tendsto (fun n : ℕ => rrtProduct 1 n / (n : ℝ)) atTop (𝓝 1) := by
      convert Tendsto.congr' _ ( tendsto_one_div_atTop_nhds_zero_nat.const_add ( 1 : ℝ ) ) using 1;
      · norm_num;
      · filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn using by rw [ descProductOne_eq n, add_div, div_self ( by positivity ) ] ;

end DDAG