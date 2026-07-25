import Mathlib

/-!
# The Character Class Contradiction

This file formalises a small "zeta-function" computation for the rank-one matrix

`A = !![1,1;1,1]`

over `ℚ`, and uses it to refute the *naive expectation* that the point counts
`Nᵣ = trace (Aʳ)` should vanish for all `r ≠ 1`.

The matrix `A` has eigenvalues `0` and `2`, so `trace (Aʳ) = 0ʳ + 2ʳ`.  For
`r ≥ 1` this equals `2ʳ`, while for `r = 0` it equals `trace (1) = 2 ≠ 2⁰ = 1`.

## Main results

* `A_mul_A_eq_two_mul_A` — `A * A = 2 • A`.
* `trace_pow_two_shift` — `trace (Aʳ) = 2ʳ` for `r ≥ 1`.
* `det_one_sub_t_mul_A` — `det (1 - t • A) = 1 - 2 t`.
* `zeta_function` — the zeta series `Z t = exp (∑ Nᵣ tʳ / r)` equals
  `1 / (1 - 2 t)` (for `|t| < 1/2`, where the defining series converges).
* `naive_expectation_false` — it is **not** the case that `trace (Aʳ) = 0`
  for all `r ≠ 1`.

## Implementation notes

* The matrix-multiplication notation `⬝` used in older Mathlib has been removed;
  square-matrix multiplication is the ordinary `*`, which is what we use.
* `trace_pow_two_shift` is stated with the hypothesis `1 ≤ r`.  This is necessary:
  at `r = 0` the literal identity `trace (A⁰) = 2⁰` is false because
  `trace (1) = 2` while `2⁰ = 1`.  The zeta series only ever sees the `r ≥ 1`
  values (the `r = 0` summand is killed by the `/ r` with `r = 0`).
* `zeta_function` carries the hypothesis `|t| < 1/2`, the radius of convergence of
  the defining logarithmic series; outside this disc the series diverges, so the
  identity cannot hold for *all* rational `t`.
-/

open Matrix

/-- The rank-one all-ones `2 × 2` matrix over `ℚ`. -/
abbrev A : Matrix (Fin 2) (Fin 2) ℚ := !![1, 1; 1, 1]

/-- `A * A = 2 • A`: the defining quadratic relation of the rank-one matrix `A`. -/
theorem A_mul_A_eq_two_mul_A : A * A = (2 : ℚ) • A := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [A, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

/-- The powers of `A` are scalar multiples of `A`: `A ^ (n+1) = 2 ^ n • A`. -/
theorem A_pow_succ (n : ℕ) : A ^ (n + 1) = (2 ^ n : ℚ) • A := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [pow_succ, ih, Matrix.smul_mul, A_mul_A_eq_two_mul_A, smul_smul]
    congr 1
    ring

/-- The trace of `A` is `2`. -/
theorem trace_A : A.trace = (2 : ℚ) := by
  simp [Matrix.trace_fin_two, A]
  norm_num

/-- For `r ≥ 1`, `trace (A ^ r) = 2 ^ r`.

The hypothesis `1 ≤ r` is essential: at `r = 0` we have `trace (A ^ 0) =
trace 1 = 2 ≠ 1 = 2 ^ 0`. -/
theorem trace_pow_two_shift (r : ℕ) (hr : 1 ≤ r) : (A ^ r).trace = 2 ^ r := by
  obtain ⟨n, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : r ≠ 0)
  rw [A_pow_succ, Matrix.trace_smul, trace_A, smul_eq_mul, pow_succ]

/-- The "spectral determinant" `det (1 - t • A) = 1 - 2 t`. -/
theorem det_one_sub_t_mul_A (t : ℚ) : Matrix.det (1 - t • A) = 1 - 2 * t := by
  have h : (1 : Matrix (Fin 2) (Fin 2) ℚ) - t • A = !![1 - t, -t; -t, 1 - t] := by
    ext i j
    fin_cases i <;> fin_cases j <;> simp [A]
  rw [h, Matrix.det_fin_two_of]
  ring

/-- The point counts `Nᵣ = trace (A ^ r)`. -/
noncomputable def N (r : ℕ) : ℚ := (A ^ r).trace

/-- The (exponential) zeta function `Z t = exp (∑ Nᵣ tʳ / r)`.

The `r = 0` term of the sum is `N₀ · t⁰ / 0 = 0` (division by `0` is `0` in
`ℝ`), so only the `r ≥ 1` contributions matter. -/
noncomputable def Z (t : ℚ) : ℝ := Real.exp (∑' r : ℕ, (N r : ℝ) * (t : ℝ) ^ r / r)

/-- The zeta function evaluates to `Z t = 1 / (1 - 2 t)`.

We require `|t| < 1/2`, the radius of convergence of the defining series. -/
theorem zeta_function (t : ℚ) (ht : |(t : ℝ)| < 1 / 2) :
    Z t = 1 / (1 - 2 * (t : ℝ)) := by
  set x : ℝ := 2 * (t : ℝ) with hx
  have hxlt : |x| < 1 := by rw [hx, abs_mul, abs_two]; linarith
  -- Each `r ≥ 1` summand equals the corresponding term of the `-log (1 - x)` series.
  have hfun : ∀ n : ℕ,
      (N (n + 1) : ℝ) * (t : ℝ) ^ (n + 1) / (n + 1) = x ^ (n + 1) / ((n : ℝ) + 1) := by
    intro n
    have hN : N (n + 1) = (2 : ℚ) ^ (n + 1) :=
      trace_pow_two_shift (n + 1) (by omega)
    rw [hN, hx, mul_pow]
    push_cast
    ring
  -- Power series for `-log (1 - x)`.
  have hs0 : HasSum (fun n : ℕ => x ^ (n + 1) / ((n : ℝ) + 1)) (-Real.log (1 - x)) :=
    Real.hasSum_pow_div_log_of_abs_lt_one hxlt
  have hs1 : HasSum (fun n : ℕ => (N (n + 1) : ℝ) * (t : ℝ) ^ (n + 1) / (n + 1))
      (-Real.log (1 - x)) :=
    hs0.congr_fun (fun n => hfun n)
  -- Reinsert the (vanishing) `r = 0` term.
  have hsfull : HasSum (fun r : ℕ => (N r : ℝ) * (t : ℝ) ^ r / r) (-Real.log (1 - x)) := by
    rw [← hasSum_nat_add_iff' 1]
    simpa using hs1
  rw [Z, hsfull.tsum_eq, Real.exp_neg,
    Real.exp_log (by linarith [abs_lt.mp hxlt |>.2]), hx]
  field_simp

/-- The naive expectation that all higher point counts vanish is **false**:
it is not the case that `trace (A ^ r) = 0` for every `r ≠ 1`.  Indeed
`trace (A ^ 2) = 4 ≠ 0`. -/
theorem naive_expectation_false : ¬ (∀ r ≠ 1, (A ^ r).trace = 0) := by
  intro h
  have h2 := h 2 (by norm_num)
  rw [trace_pow_two_shift 2 (by norm_num)] at h2
  norm_num at h2