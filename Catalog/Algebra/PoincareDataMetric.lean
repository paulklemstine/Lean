import Mathlib

/-!
# Where the `d^{1/2}` factor in the Poincaré-for-data threshold comes from

The informal conjecture predicts a detection threshold `ε_⋆ = C · d^{1/2} · n^{-1/d}`.
The `n^{-1/d}` part is a genuine packing exponent (see `PoincareDataScaling.lean`).
This file pins down the origin of the *dimensional* factor `d^{1/2}`: it is exactly the
comparison constant between the ℓ^∞ (Chebyshev) metric — in which the clean packing bound
lives — and the Euclidean ℓ² metric, in which the sphere `S^d ⊂ ℝ^{d+1}` and the
Vietoris–Rips scale `ε` are measured.

We prove the sharp two-sided comparison

  `‖x‖_∞ ≤ ‖x‖_2 ≤ √d · ‖x‖_∞`   for `x ∈ ℝ^d`,

with `√d` as the exact worst-case constant. Thus an ℓ^∞ covering radius `r` corresponds to
a Euclidean radius between `r` and `√d · r`, which is precisely the `d^{1/2}` prefactor of
the conjecture. This shows the `d^{1/2}` is a *metric artifact*, not intrinsic topology.
-/

open Finset

namespace PoincareData

/-
Lower comparison: every coordinate is dominated by the ℓ² norm.
`|x i| ≤ √(∑ j, x j ^ 2)`.
-/
lemma linfty_le_l2 (d : ℕ) (x : Fin d → ℝ) (i : Fin d) :
    |x i| ≤ Real.sqrt (∑ j, (x j) ^ 2) := by
  exact Real.abs_le_sqrt ( Finset.single_le_sum ( fun j _ => sq_nonneg ( x j ) ) ( Finset.mem_univ i ) )

/-
Upper comparison: if all coordinates are bounded by `M ≥ 0`, then
`√(∑ j, x j ^ 2) ≤ √d · M`. Together with `linfty_le_l2` this is the sharp
`‖·‖_2 ≤ √d ‖·‖_∞` inequality, the source of the `d^{1/2}` factor.
-/
lemma l2_le_sqrt_d_linfty (d : ℕ) (x : Fin d → ℝ) (M : ℝ) (hM : 0 ≤ M)
    (hbound : ∀ i, |x i| ≤ M) :
    Real.sqrt (∑ j, (x j) ^ 2) ≤ Real.sqrt d * M := by
  rw [ ← Real.sqrt_sq ( le_trans ( by norm_num ) ( mul_nonneg ( Real.sqrt_nonneg d ) hM ) ), mul_pow ];
  exact Real.sqrt_le_sqrt <| le_trans ( Finset.sum_le_sum fun i _ => show x i ^ 2 ≤ M ^ 2 by nlinarith only [ abs_le.mp ( hbound i ) ] ) ( by norm_num [ mul_comm ] )

/-
**Sharpness of the constant `√d`.** For the all-ones vector, the ℓ² norm equals
exactly `√d · ‖·‖_∞` (here `‖·‖_∞ = 1`), so no constant smaller than `√d` works.
-/
theorem sqrt_d_is_sharp (d : ℕ) :
    Real.sqrt (∑ _j : Fin d, (1 : ℝ) ^ 2) = Real.sqrt d * (1 : ℝ) := by
  norm_num

end PoincareData