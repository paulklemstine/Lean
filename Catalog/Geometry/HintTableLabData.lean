/-
# HINT-TABLE-COMPLETION, part IV: the paper-104 table as data

The six reported rows, as exact decimals, checked against the theorems of part I:
`total_hint` (`4.0908`), `total_capacity` (`5.5015`), `table_within_windows` (every row
lies in its proved window), and `pearson_bounds` (`0.255 < r < 0.257`, confirming the
reported `r = 0.256`), `pearson_sq_lt` (`r² < 0.07`).

-- !-- Lab Notes -- !--
These are arithmetic checks of reported numbers, not theorems about batteries; the structural
content is in parts I–III.
-/
import Mathlib
import Geometry.HintTableCompletion

namespace HintTable.LabData

/-! ## 8. The paper-104 table, checked against the proved windows -/

/-- Capacities `I(N)` of the six dials, in table order
`C₅@11, F₂₀@5, S₃a@31, S₃b@23, D₄@8, A₄@9`. -/
def capacity : Fin 6 → ℝ := ![1.2062, 0.2920, 1.0011, 1.0008, 1.9999, 0.0015]

/-- Reported hint values of the six dials. -/
def hint : Fin 6 → ℝ := ![1.5896, 0.9538, 0.5201, 0.5121, 0.5032, 0.0120]

/-- Moduli of the six dials. -/
def modulus : Fin 6 → ℕ := ![11, 5, 31, 23, 8, 9]

theorem total_hint : ∑ i, hint i = 4.0908 := by
  simp [Fin.sum_univ_succ, hint]; norm_num

theorem total_capacity : ∑ i, capacity i = 5.5015 := by
  simp [Fin.sum_univ_succ, capacity]; norm_num

/-- Every reported hint value lies inside the proved window: `[0, 2 log₂ m]` at odd moduli
and `[-1, 2 log₂ m]` at the even modulus. -/
theorem table_within_windows (i : Fin 6) :
    (if Odd (modulus i) then (0 : ℝ) else -1) ≤ hint i ∧
      hint i ≤ 2 * Real.logb 2 (modulus i) := by
  have hlog : ∀ m : ℕ, 5 ≤ m → 2 ≤ 2 * Real.logb 2 (m : ℝ) := by
    intro m hm
    have : (1 : ℝ) ≤ Real.logb 2 (m : ℝ) := by
      rw [Real.le_logb_iff_rpow_le (by norm_num) (by positivity)]
      have : (5 : ℝ) ≤ m := by exact_mod_cast hm
      norm_num; linarith
    linarith
  have hm : 5 ≤ modulus i := by fin_cases i <;> decide
  refine ⟨?_, le_trans ?_ (hlog _ hm)⟩ <;>
    fin_cases i <;> simp [hint, modulus] <;> norm_num

/-- Sample means, covariance and variances of the table. -/
noncomputable def mean (v : Fin 6 → ℝ) : ℝ := (∑ i, v i) / 6
noncomputable def cov (u v : Fin 6 → ℝ) : ℝ := ∑ i, (u i - mean u) * (v i - mean v)

/-- The Pearson correlation of capacity and hint. -/
noncomputable def pearson : ℝ :=
  cov capacity hint / Real.sqrt (cov capacity capacity * cov hint hint)

/-- **The reported correlation `r = 0.256` is exact to three places**: `0.255 < r < 0.257`. -/
theorem pearson_bounds : 0.255 < pearson ∧ pearson < 0.257 := by
  have hc : cov capacity hint = 48451189 / 100000000 := by
    simp [cov, mean, Fin.sum_univ_succ, capacity, hint]; norm_num
  have hcc : cov capacity capacity = 299900341 / 120000000 := by
    simp [cov, mean, Fin.sum_univ_succ, capacity]; norm_num
  have hhh : cov hint hint = 71677991 / 50000000 := by
    simp [cov, mean, Fin.sum_univ_succ, hint]; norm_num
  have hpos : (0 : ℝ) < Real.sqrt (299900341 / 120000000 * (71677991 / 50000000)) :=
    Real.sqrt_pos.mpr (by norm_num)
  rw [pearson, hc, hcc, hhh]
  constructor
  · rw [lt_div_iff₀ hpos, ← lt_div_iff₀' (by norm_num),
      Real.sqrt_lt' (by norm_num)]
    norm_num
  · rw [div_lt_iff₀ hpos, ← div_lt_iff₀' (by norm_num),
      Real.lt_sqrt (by norm_num)]
    norm_num

/-- The correlation is positive but weak: `r² < 0.07`, i.e. capacity explains less than `7%`
of the variance of the hint across the six dials. -/
theorem pearson_sq_lt : pearson ^ 2 < 0.07 := by
  obtain ⟨h1, h2⟩ := pearson_bounds
  nlinarith

end HintTable.LabData