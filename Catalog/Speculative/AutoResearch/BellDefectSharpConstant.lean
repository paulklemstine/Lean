import Combinatorics.BellDefectMonotone

/-!
# The sharp propagation constant for the Bell defect

`Catalog/Combinatorics/BellDefectGradedSpectrum.lean` proves Conjecture F in the form
`(B_k − 1)·D_2 ≤ 2·D_k`.  A numerical scan of the admissible spectra (see
`ComputationalEvidence.md`) shows that the extremal configuration is the *constant* spectrum
`t_1 = t_2 = ⋯ = t_k`, for which `2·D_k / D_2 = B_k` exactly.  This file proves the resulting
sharp inequality

  `B_k · D_2 ≤ 2 · D_k`  (`bellDefect_two_propagation_sharp`),

improving the constant from `(B_k − 1)/2` to `B_k/2`.  The constant `B_k/2` is optimal *for the
spectral relaxation*: `bellDefect_sharp_constant_attained` shows that equality holds for every
spectrum that is constant on `1 ≤ r ≤ k`, which is exactly the extremal ray of the linear program
`min Σ_r S(k,r)x_r` subject to `x_1 + x_2 = 1`, `x_1 ≤ x_2 ≤ x_3 ≤ ⋯`.  (Whether that ray is
realized by an actual group action with `x_1 > 0` for `k ≥ 3` is left open; the numerical samples
in `ComputationalEvidence.md` all satisfy the inequality strictly.)

The extra ingredient beyond the previous cycle is the *ordering* `t_1 ≤ t_2` of the two lowest
spectral values, which lets one trade the deficient weight `S(k,1) = 1` on the first coordinate
against the surplus weight `B_k − 1` on the rest.

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace BellDefectGraded

open MoonshineBell MoonshineFibre FibreSpectrum

section Sharp

variable (k : ℕ) (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- The second defect, in closed form: `D_2 = |G|·((t_1 − 1) + (t_2 − 1))`. -/
theorem bellDefect_two_eq (hX : 2 ≤ Nat.card X) :
    bellDefect 2 G X
      = ((injOrbits G X 1 - 1) + (injOrbits G X 2 - 1)) * Nat.card G := by
  rw [bellDefect_eq_spectrum 2 G X hX]
  congr 1
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    stirling_zero_right (by omega : 1 ≤ 2), stirling_one (by omega : 1 ≤ 2), stirling_self 2]
  ring

/-- Lower bound for the `k`-th defect by the two lowest spectral values: the rank-`1` pattern
contributes `t_1 − 1`, and each of the `B_k − 1` patterns of rank `≥ 2` contributes at least
`t_2 − 1`. -/
theorem le_bellDefect_of_two_le (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X) :
    ((injOrbits G X 1 - 1) + (bell k - 1) * (injOrbits G X 2 - 1)) * Nat.card G
      ≤ bellDefect k G X := by
  classical
  rw [bellDefect_eq_spectrum k G X hk]
  refine Nat.mul_le_mul_right _ ?_
  have h1mem : (1 : ℕ) ∉ Finset.Icc 2 k := by simp
  have hsub : insert 1 (Finset.Icc 2 k) ⊆ Finset.range (k + 1) := by
    intro r hr
    rcases Finset.mem_insert.1 hr with h | h
    · exact Finset.mem_range.2 (by omega)
    · rw [Finset.mem_Icc] at h
      exact Finset.mem_range.2 (by omega)
  have hkey : (injOrbits G X 1 - 1) + (bell k - 1) * (injOrbits G X 2 - 1)
      ≤ ∑ r ∈ insert 1 (Finset.Icc 2 k), stirling k r * (injOrbits G X r - 1) := by
    rw [Finset.sum_insert h1mem, stirling_one (by omega : 1 ≤ k), one_mul]
    refine Nat.add_le_add_left ?_ _
    calc (bell k - 1) * (injOrbits G X 2 - 1)
        = (∑ r ∈ Finset.Icc 2 k, stirling k r) * (injOrbits G X 2 - 1) := by
          rw [sum_stirling_Icc_two (by omega : 1 ≤ k)]
      _ = ∑ r ∈ Finset.Icc 2 k, stirling k r * (injOrbits G X 2 - 1) := by rw [Finset.sum_mul]
      _ ≤ ∑ r ∈ Finset.Icc 2 k, stirling k r * (injOrbits G X r - 1) := by
          refine Finset.sum_le_sum fun r hr => ?_
          rw [Finset.mem_Icc] at hr
          exact Nat.mul_le_mul_left _ (Nat.sub_le_sub_right
            (injOrbits_monotone G X hr.1 (le_trans hr.2 hk)) 1)
  exact le_trans hkey (Finset.sum_le_sum_of_subset hsub)

/-- **The sharp propagation constant.**  `B_k·D_2 ≤ 2·D_k` for `2 ≤ k ≤ |X|`: the failure of
`2`-transitivity is multiplied by at least `B_k/2` when passing to `k`-tuples.  This improves
`bellDefect_two_propagation`, whose constant was `(B_k − 1)/2`, and is the best constant
obtainable from the spectral formula (see `bellDefect_sharp_constant_attained`). -/
theorem bellDefect_two_propagation_sharp (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X) :
    bell k * bellDefect 2 G X ≤ 2 * bellDefect k G X := by
  have hX : 2 ≤ Nat.card X := le_trans hk2 hk
  set a := injOrbits G X 1 - 1 with ha
  set b := injOrbits G X 2 - 1 with hb
  have hab : a ≤ b := Nat.sub_le_sub_right (injOrbits_monotone G X (by omega) hX) 1
  have hB : 2 ≤ bell k := two_le_bell hk2
  obtain ⟨c, hc⟩ : ∃ c, bell k = 2 + c := ⟨bell k - 2, by omega⟩
  have hlow := le_bellDefect_of_two_le k G X hk2 hk
  have harith : bell k * (a + b) ≤ 2 * (a + (bell k - 1) * b) := by
    rw [hc]
    have h1 : 2 + c - 1 = 1 + c := by omega
    rw [h1]
    have hcc : c * a ≤ c * b := Nat.mul_le_mul_left c hab
    nlinarith [hcc]
  calc bell k * bellDefect 2 G X
      = bell k * ((a + b) * Nat.card G) := by rw [bellDefect_two_eq G X hX]
    _ = (bell k * (a + b)) * Nat.card G := by ring
    _ ≤ (2 * (a + (bell k - 1) * b)) * Nat.card G := Nat.mul_le_mul_right _ harith
    _ = 2 * ((a + (bell k - 1) * b) * Nat.card G) := by ring
    _ ≤ 2 * bellDefect k G X := Nat.mul_le_mul_left _ hlow

/-- **Sharpness of the spectral relaxation.**  If the spectrum is constant on `1 ≤ r ≤ k` — the
extremal ray found numerically — then `2·D_k = B_k·D_2` exactly, so no constant larger than
`B_k/2` can be derived from the spectral formula alone. -/
theorem bellDefect_sharp_constant_attained (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X)
    (hconst : ∀ r, 1 ≤ r → r ≤ k → injOrbits G X r = injOrbits G X 1) :
    2 * bellDefect k G X = bell k * bellDefect 2 G X := by
  classical
  have hX : 2 ≤ Nat.card X := le_trans hk2 hk
  set a := injOrbits G X 1 - 1 with ha
  have hDk : bellDefect k G X = (bell k * a) * Nat.card G := by
    rw [bellDefect_eq_spectrum k G X hk]
    congr 1
    have hterm : ∀ r ∈ Finset.range (k + 1),
        stirling k r * (injOrbits G X r - 1) = stirling k r * a := by
      intro r hr
      rcases Nat.eq_zero_or_pos r with hr0 | hrpos
      · rw [hr0, stirling_zero_right (by omega : 1 ≤ k), zero_mul, zero_mul]
      · rw [hconst r hrpos (Nat.lt_succ_iff.1 (Finset.mem_range.1 hr))]
    rw [Finset.sum_congr rfl hterm, ← Finset.sum_mul, ← bell_eq_sum_stirling]
  have hD2 : bellDefect 2 G X = (2 * a) * Nat.card G := by
    rw [bellDefect_two_eq G X hX, hconst 2 (by omega) hk2]
    ring
  rw [hDk, hD2]
  ring

end Sharp

end BellDefectGraded