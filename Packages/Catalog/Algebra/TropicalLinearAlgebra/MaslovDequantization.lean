/-
# Maslov dequantization: classical matrix powers converge to tropical ones

Tropical algebra is the "zero-temperature limit" of ordinary algebra.  Concretely, for
`t > 0` let `E_t(A)` be the *classical* nonnegative matrix with entries `exp (t · A i j)`.
Then ordinary matrix powers of `E_t(A)` are squeezed between the tropical power and
`n^m` times it:

  `exp (t · (A^{⊗(m+1)}) i j) ≤ (E_t(A)^{m+1}) i j ≤ n^m · exp (t · (A^{⊗(m+1)}) i j)`,

so that `log ((E_t(A)^{m+1}) i j) / t → (A^{⊗(m+1)}) i j` as `t → ∞`.  This is the
matrix form of Maslov dequantization, and it links the combinatorial optimum computed by
`tpow` with genuine analysis (`Real.exp`, `Real.log`, limits).
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalMatrix

namespace TropicalLA

open Filter Topology

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The Boltzmann/exponential lift of a max-plus matrix at inverse temperature `t`. -/
noncomputable def expMat (t : ℝ) (A : Matrix ι ι ℝ) : Matrix ι ι ℝ :=
  Matrix.of fun i j => Real.exp (t * A i j)

/-- Classical (ordinary) matrix powers, indexed like `tpow`: `cpow X m = X ^ (m+1)`. -/
noncomputable def cpow (X : Matrix ι ι ℝ) : ℕ → Matrix ι ι ℝ
  | 0 => X
  | (m + 1) => cpow X m * X

theorem cpow_pos {X : Matrix ι ι ℝ} (hX : ∀ i j, 0 < X i j) (m : ℕ) (i j : ι) :
    0 < cpow X m i j := by
  induction m generalizing i j with
  | zero => exact hX i j
  | succ m ih =>
      rw [show cpow X (m + 1) = cpow X m * X from rfl, Matrix.mul_apply]
      exact Finset.sum_pos (fun k _ => mul_pos (ih i k) (hX k j)) Finset.univ_nonempty

/-- **Squeeze between the classical and the tropical power.**  Every entry of the
`(m+1)`-st ordinary power of the Boltzmann lift lies between the tropical value and
`n^m` times it. -/
theorem cpow_expMat_bounds {t : ℝ} (ht : 0 < t) (A : Matrix ι ι ℝ) (m : ℕ) (i j : ι) :
    Real.exp (t * tpow A m i j) ≤ cpow (expMat t A) m i j ∧
      cpow (expMat t A) m i j ≤ (Fintype.card ι : ℝ) ^ m * Real.exp (t * tpow A m i j) := by
  induction m generalizing i j with
  | zero =>
      constructor
      · exact le_of_eq rfl
      · simp [cpow, expMat, tpow]
  | succ m ih =>
      have hpos : ∀ (k : ι), 0 < expMat t A k j := fun k => Real.exp_pos _
      constructor
      · obtain ⟨k, hk⟩ := exists_tmul_eq (tpow A m) A i j
        have hterm : Real.exp (t * tpow A (m + 1) i j)
            ≤ cpow (expMat t A) m i k * expMat t A k j := by
          have h1 := (ih i k).1
          have h2 : Real.exp (t * tpow A (m + 1) i j)
              = Real.exp (t * tpow A m i k) * Real.exp (t * A k j) := by
            rw [← Real.exp_add]
            congr 1
            rw [show tpow A (m + 1) i j = tmul (tpow A m) A i j from rfl, hk]
            ring
          rw [h2]
          exact mul_le_mul_of_nonneg_right h1 (le_of_lt (Real.exp_pos _))
        refine le_trans hterm ?_
        rw [show cpow (expMat t A) (m + 1) = cpow (expMat t A) m * expMat t A from rfl,
          Matrix.mul_apply]
        refine Finset.single_le_sum (f := fun k => cpow (expMat t A) m i k * expMat t A k j)
          (fun k _ => ?_) (Finset.mem_univ k)
        exact le_of_lt (mul_pos (cpow_pos (fun a b => Real.exp_pos _) m i k) (hpos k))
      · rw [show cpow (expMat t A) (m + 1) = cpow (expMat t A) m * expMat t A from rfl,
          Matrix.mul_apply]
        have hbound : ∀ k ∈ (Finset.univ : Finset ι),
            cpow (expMat t A) m i k * expMat t A k j
              ≤ (Fintype.card ι : ℝ) ^ m * Real.exp (t * tpow A (m + 1) i j) := by
          intro k _
          have h1 := (ih i k).2
          have hle : tpow A m i k + A k j ≤ tpow A (m + 1) i j := le_tmul (tpow A m) A i j k
          have h2 : Real.exp (t * tpow A m i k) * Real.exp (t * A k j)
              ≤ Real.exp (t * tpow A (m + 1) i j) := by
            rw [← Real.exp_add]
            exact Real.exp_le_exp.mpr (by nlinarith)
          have h3 : cpow (expMat t A) m i k * expMat t A k j
              ≤ ((Fintype.card ι : ℝ) ^ m * Real.exp (t * tpow A m i k)) * Real.exp (t * A k j) :=
            mul_le_mul_of_nonneg_right h1 (le_of_lt (Real.exp_pos _))
          calc cpow (expMat t A) m i k * expMat t A k j
              ≤ ((Fintype.card ι : ℝ) ^ m * Real.exp (t * tpow A m i k)) * Real.exp (t * A k j) := h3
            _ = (Fintype.card ι : ℝ) ^ m * (Real.exp (t * tpow A m i k) * Real.exp (t * A k j)) := by
                ring
            _ ≤ (Fintype.card ι : ℝ) ^ m * Real.exp (t * tpow A (m + 1) i j) := by
                have : (0 : ℝ) ≤ (Fintype.card ι : ℝ) ^ m := by positivity
                exact mul_le_mul_of_nonneg_left h2 this
        calc ∑ k, cpow (expMat t A) m i k * expMat t A k j
            ≤ ∑ _k : ι, (Fintype.card ι : ℝ) ^ m * Real.exp (t * tpow A (m + 1) i j) :=
              Finset.sum_le_sum hbound
          _ = (Fintype.card ι : ℝ) ^ (m + 1) * Real.exp (t * tpow A (m + 1) i j) := by
              rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
              ring

/-- Logarithmic form of the squeeze. -/
theorem log_cpow_expMat_bounds {t : ℝ} (ht : 0 < t) (A : Matrix ι ι ℝ) (m : ℕ) (i j : ι) :
    tpow A m i j ≤ Real.log (cpow (expMat t A) m i j) / t ∧
      Real.log (cpow (expMat t A) m i j) / t
        ≤ tpow A m i j + m * Real.log (Fintype.card ι) / t := by
  obtain ⟨hlow, hhigh⟩ := cpow_expMat_bounds ht A m i j
  have hposE : 0 < cpow (expMat t A) m i j := cpow_pos (fun a b => Real.exp_pos _) m i j
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by
    exact_mod_cast Fintype.card_pos
  constructor
  · rw [le_div_iff₀ ht]
    have := Real.log_le_log (Real.exp_pos _) hlow
    rw [Real.log_exp] at this
    linarith
  · rw [div_le_iff₀ ht]
    have hlog := Real.log_le_log hposE hhigh
    rw [Real.log_mul (by positivity) (Real.exp_pos _).ne', Real.log_exp, Real.log_pow] at hlog
    have : m * Real.log (Fintype.card ι) / t * t = m * Real.log (Fintype.card ι) := by
      field_simp
    nlinarith [hlog, this]

/-- **Maslov dequantization for matrix powers.**  As the inverse temperature `t` tends to
infinity, the normalised logarithm of the classical power converges to the tropical
power. -/
theorem tendsto_log_cpow_expMat (A : Matrix ι ι ℝ) (m : ℕ) (i j : ι) :
    Tendsto (fun t : ℝ => Real.log (cpow (expMat t A) m i j) / t) atTop
      (𝓝 (tpow A m i j)) := by
  have h0 : Tendsto (fun t : ℝ => (m : ℝ) * Real.log (Fintype.card ι) / t) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id
  have hhigh : Tendsto (fun t : ℝ => tpow A m i j + (m : ℝ) * Real.log (Fintype.card ι) / t)
      atTop (𝓝 (tpow A m i j)) := by
    simpa using (tendsto_const_nhds (x := tpow A m i j) (f := (atTop : Filter ℝ))).add h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hhigh ?_ ?_
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    exact (log_cpow_expMat_bounds ht A m i j).1
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    exact (log_cpow_expMat_bounds ht A m i j).2

end TropicalLA