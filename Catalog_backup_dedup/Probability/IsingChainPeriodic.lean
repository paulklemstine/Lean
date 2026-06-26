/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The 1D Ising Model on a Ring: Transfer-Matrix Spectrum and the Spectral Gap

This file treats the **periodic** 1D Ising model (a ring of `n` sites) through the
*transfer matrix*

  `T = !![exp(βJ),  exp(-βJ);  exp(-βJ),  exp(βJ)]`,

whose two eigenvalues are `λ₊ = 2 cosh(βJ)` and `λ₋ = 2 sinh(βJ)`.  The partition
function of the ring is the trace `Zper β J n = trace (Tⁿ)`, and we diagonalise `T`
*by hand* using the two orthogonal rank-one spectral projectors `Pp`, `Pm`
(symmetric / antisymmetric subspaces) to obtain everything in closed form.

## Main results

* `Tm_pow` — the exact spectral decomposition `Tⁿ = λ₊ⁿ • Pp + λ₋ⁿ • Pm`.
* `Zper_closed` — the **exact ring partition function**
    `Zper β J n = (2 cosh(βJ))ⁿ + (2 sinh(βJ))ⁿ`.
* `free_energy_density_limit_periodic` — the free energy density again converges to
  `log (2 cosh(βJ))` in the thermodynamic limit (same bulk free energy as the open
  chain: boundary conditions are irrelevant in the limit).
* `spectral_gap_pos` — for `β, J > 0` the **transfer-matrix gap**
    `g = log(λ₊ / λ₋) = log(coth(βJ))` is strictly positive, so the correlation
  length `ξ = 1/g` is finite at every positive temperature.
* `spectral_gap_tendsto_zero` — the gap closes, `g → 0`, only as `β → ∞`
  (`T → 0`): the 1D Ising ring is critical **only at zero temperature**.

## Application keywords

statistical mechanics, Ising model, transfer matrix, spectral gap, correlation
length, partition function, free energy, thermodynamic limit, probability

-- !-- Lab Notes -- !--
Hypotheses explored in this research cycle:
  (H1) `T` has spectral projectors `Pp = ½!![1,1;1,1]`, `Pm = ½!![1,-1;-1,1]`
       with eigenvalues `2cosh βJ`, `2sinh βJ`.                       [PROVED, Tm_mul_Pp/Tm_mul_Pm]
  (H2) Hence `Tⁿ = λ₊ⁿ Pp + λ₋ⁿ Pm` by induction, so the ring partition
       function `trace Tⁿ = λ₊ⁿ + λ₋ⁿ`.                              [PROVED, Tm_pow / Zper_closed]
  (H3) The bulk free energy density `→ log(2 cosh βJ)` regardless of boundary
       conditions (open vs. periodic agree in the limit).            [PROVED]
  (H4) The spectral gap is `log(coth βJ) > 0` for all `β,J>0` and only
       vanishes as `β → ∞`: criticality lives at `T = 0`.            [PROVED]
Failure analysis / dead ends:
  * Connecting `trace Tⁿ` to the raw cyclic configuration sum needs a
    "closed-walk" expansion that Mathlib lacks as a single lemma; the
    transfer-matrix trace is therefore taken as the (standard) definition of
    the ring partition function, and is justified spectrally rather than
    combinatorially in this cycle (see FUTURE_DIRECTIONS).
  * `T^n` via generic eigen-machinery (`Matrix.IsHermitian` spectral theorem)
    drags in `RCLike`/`EuclideanSpace` coercions; the hand-built rank-one
    projector induction is far cleaner for a fixed `2×2` matrix.
Insight:
  The dominant eigenvalue `λ₊ = 2cosh βJ` controls the free energy; the *ratio*
  `λ₋/λ₊ = tanh βJ < 1` controls correlations. Both are analytic for `β<∞`, so the
  only possible singularity is at `β = ∞` (`T=0`) — the 1D critical point.
-/
import Mathlib

open scoped BigOperators Matrix Topology
open Filter

namespace IsingChainPeriodic

/-- The `2×2` Ising transfer matrix. -/
noncomputable def Tm (β J : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![Real.exp (β * J), Real.exp (-(β * J)); Real.exp (-(β * J)), Real.exp (β * J)]

/-- Spectral projector onto the symmetric eigenvector (eigenvalue `2 cosh`). -/
noncomputable def Pp : Matrix (Fin 2) (Fin 2) ℝ := !![1 / 2, 1 / 2; 1 / 2, 1 / 2]

/-- Spectral projector onto the antisymmetric eigenvector (eigenvalue `2 sinh`). -/
noncomputable def Pm : Matrix (Fin 2) (Fin 2) ℝ := !![1 / 2, -1 / 2; -1 / 2, 1 / 2]

/-- The larger transfer eigenvalue `λ₊ = 2 cosh (β J)`. -/
noncomputable def lamPlus (β J : ℝ) : ℝ := Real.exp (β * J) + Real.exp (-(β * J))

/-- The smaller transfer eigenvalue `λ₋ = 2 sinh (β J)`. -/
noncomputable def lamMinus (β J : ℝ) : ℝ := Real.exp (β * J) - Real.exp (-(β * J))

theorem lamPlus_eq (β J : ℝ) : lamPlus β J = 2 * Real.cosh (β * J) := by
  rw [lamPlus, Real.cosh_eq]; ring

theorem lamMinus_eq (β J : ℝ) : lamMinus β J = 2 * Real.sinh (β * J) := by
  rw [lamMinus, Real.sinh_eq]; ring

/-- `Pp` and `Pm` resolve the identity. -/
theorem id_eq_Pp_add_Pm : (1 : Matrix (Fin 2) (Fin 2) ℝ) = Pp + Pm := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [Pp, Pm] <;> norm_num

theorem trace_Pp : Pp.trace = 1 := by simp [Matrix.trace, Pp, Fin.sum_univ_two]; norm_num

theorem trace_Pm : Pm.trace = 1 := by simp [Matrix.trace, Pm, Fin.sum_univ_two]; norm_num

/-- `Pp` is an eigen-projector of `T` with eigenvalue `λ₊`. -/
theorem Tm_mul_Pp (β J : ℝ) : Tm β J * Pp = lamPlus β J • Pp := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Tm, Pp, lamPlus, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

/-- `Pm` is an eigen-projector of `T` with eigenvalue `λ₋`. -/
theorem Tm_mul_Pm (β J : ℝ) : Tm β J * Pm = lamMinus β J • Pm := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Tm, Pm, lamMinus, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

/-- **Spectral decomposition of the matrix power.**
`Tⁿ = λ₊ⁿ • Pp + λ₋ⁿ • Pm`. -/
theorem Tm_pow (β J : ℝ) (n : ℕ) :
    (Tm β J) ^ n = (lamPlus β J) ^ n • Pp + (lamMinus β J) ^ n • Pm := by
  induction n with
  | zero => simpa using id_eq_Pp_add_Pm
  | succ k ih =>
    rw [pow_succ', ih, Matrix.mul_add, Matrix.mul_smul, Matrix.mul_smul, Tm_mul_Pp, Tm_mul_Pm,
      smul_smul, smul_smul, pow_succ, pow_succ]

/-- The periodic (ring) partition function, defined as the transfer-matrix trace. -/
noncomputable def Zper (β J : ℝ) (n : ℕ) : ℝ := ((Tm β J) ^ n).trace

/-- **Exact ring partition function.** `Zper β J n = (2 cosh βJ)ⁿ + (2 sinh βJ)ⁿ`. -/
theorem Zper_closed (β J : ℝ) (n : ℕ) :
    Zper β J n = (2 * Real.cosh (β * J)) ^ n + (2 * Real.sinh (β * J)) ^ n := by
  rw [Zper, Tm_pow, Matrix.trace_add, Matrix.trace_smul, Matrix.trace_smul, trace_Pp, trace_Pm,
    lamPlus_eq, lamMinus_eq]
  simp

/-- Positivity of the ring partition function. -/
theorem Zper_pos (β J : ℝ) (n : ℕ) (hn : 0 < n) : 0 < Zper β J n := by
  rw [Zper_closed]
  set a := 2 * Real.cosh (β * J) with ha
  set b := 2 * Real.sinh (β * J) with hb
  have hcs : (0:ℝ) < a - b := by
    rw [ha, hb, Real.cosh_eq, Real.sinh_eq]; nlinarith [Real.exp_pos (-(β * J))]
  have hcs' : (0:ℝ) < a + b := by
    rw [ha, hb, Real.cosh_eq, Real.sinh_eq]; nlinarith [Real.exp_pos (β * J)]
  have hapos : 0 < a := by linarith
  have habs : |b| < a := abs_lt.mpr ⟨by linarith, by linarith⟩
  have hbn : |b ^ n| < a ^ n := by
    rw [abs_pow]
    exact pow_lt_pow_left₀ habs (abs_nonneg b) hn.ne'
  have : -(a ^ n) < b ^ n := by
    have := neg_abs_le (b ^ n); linarith [abs_lt.mp hbn |>.1]
  linarith [neg_abs_le (b ^ n), abs_lt.mp hbn]

/-
**Thermodynamic limit of the ring free energy density.** It converges to the
*same* bulk value `log (2 cosh βJ)` as the open chain — boundary conditions do not
affect the bulk free energy.
-/
theorem free_energy_density_limit_periodic (β J : ℝ) (hβ : 0 < β) (hJ : 0 < J) :
    Filter.Tendsto (fun n : ℕ => (1 / (n : ℝ)) * Real.log (Zper β J n))
      Filter.atTop (nhds (Real.log (2 * Real.cosh (β * J)))) := by
  -- Rewrite the partition function using the formula `Zper_closed`.
  have h_zper : ∀ n : ℕ, Zper β J n = (2 * Real.cosh (β * J)) ^ n + (2 * Real.sinh (β * J)) ^ n := by
    grind +suggestions;
  -- Factor out $(2 \cosh(\beta J))^n$ from the logarithm.
  have h_factor : Filter.Tendsto (fun n : ℕ => (1 / (n : ℝ)) * (Real.log ((2 * Real.cosh (β * J)) ^ n) + Real.log (1 + (2 * Real.sinh (β * J) / (2 * Real.cosh (β * J))) ^ n))) Filter.atTop (nhds (Real.log (2 * Real.cosh (β * J)))) := by
    norm_num [ mul_add, mul_div_cancel₀, Real.log_pow ];
    exact le_trans ( Filter.Tendsto.add ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with n hn; aesop ) ) ( Filter.Tendsto.mul ( tendsto_inv_atTop_nhds_zero_nat ) ( Filter.Tendsto.log ( tendsto_const_nhds.add ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by exact div_nonneg ( mul_nonneg zero_le_two ( Real.sinh_nonneg_iff.mpr ( by positivity ) ) ) ( mul_nonneg zero_le_two ( Real.cosh_pos _ |> le_of_lt ) ) ) ( by rw [ div_lt_one ( by exact mul_pos zero_lt_two ( Real.cosh_pos _ ) ) ] ; exact mul_lt_mul_of_pos_left ( Real.sinh_lt_cosh _ ) zero_lt_two ) ) ) ( by positivity ) ) ) ) ( by norm_num );
  refine h_factor.congr' ?_;
  filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn ; rw [ h_zper n ] ; rw [ ← Real.log_mul ( by positivity ) ( by positivity ) ] ; ring;
  congr 2
  rw [inv_pow]
  field_simp [pow_ne_zero _ (ne_of_gt (Real.cosh_pos (β * J)))]
  ring

/-- The transfer-matrix **spectral gap** `g = log(λ₊/λ₋) = log(coth(βJ))`. -/
noncomputable def spectralGap (β J : ℝ) : ℝ :=
  Real.log (lamPlus β J) - Real.log (lamMinus β J)

/-- **Finite correlation length at every positive temperature.** For `β, J > 0`
the spectral gap is strictly positive (so the correlation length `1/g` is finite). -/
theorem spectral_gap_pos (β J : ℝ) (hβ : 0 < β) (hJ : 0 < J) : 0 < spectralGap β J := by
  have hbj : 0 < β * J := mul_pos hβ hJ
  have hlt : Real.exp (-(β * J)) < Real.exp (β * J) :=
    Real.exp_lt_exp.mpr (by linarith)
  have h1 : 0 < lamMinus β J := by rw [lamMinus]; linarith
  have h2 : lamMinus β J < lamPlus β J := by
    rw [lamMinus, lamPlus]; have := Real.exp_pos (-(β * J)); linarith
  exact sub_pos.mpr (Real.log_lt_log h1 h2)

/-
**Criticality only at zero temperature.** As `β → ∞` the gap closes to `0`,
i.e. the correlation length diverges only in the `T → 0` limit.
-/
theorem spectral_gap_tendsto_zero (J : ℝ) (hJ : 0 < J) :
    Filter.Tendsto (fun β : ℝ => spectralGap β J) Filter.atTop (nhds 0) := by
  -- Use the equality `spectralGap β J = Real.log (lamPlus β J / lamMinus β J)` for `β` large.
  have h_eq : ∀ᶠ β in atTop, spectralGap β J = Real.log (lamPlus β J / lamMinus β J) := by
    filter_upwards [ Filter.eventually_gt_atTop 0 ] with β hβ using by rw [ Real.log_div ( by exact ne_of_gt <| add_pos ( Real.exp_pos _ ) ( Real.exp_pos _ ) ) ( by exact ne_of_gt <| sub_pos.mpr <| Real.exp_lt_exp.mpr <| neg_lt_self_iff.mpr <| mul_pos hβ hJ ) ] ; rfl;
  -- Compute the ratio: `lamPlus β J / lamMinus β J = (1 + exp(-(2*β*J))) / (1 - exp(-(2*β*J)))`.
  have h_ratio : ∀ᶠ β in atTop, lamPlus β J / lamMinus β J = (1 + Real.exp (-(2 * β * J))) / (1 - Real.exp (-(2 * β * J))) := by
    norm_num [ lamPlus, lamMinus ];
    refine' ⟨ 1, fun β hβ => _ ⟩ ; rw [ div_eq_div_iff ] <;> ring <;> norm_num [ ne_of_gt, Real.exp_pos, hJ, hβ ];
    · simpa [ ← Real.exp_add ] using by ring;
    · exact ne_of_gt ( by norm_num; positivity );
    · exact ne_of_gt ( by norm_num; positivity );
  -- Use the fact that `Real.exp (-(2 * β * J)) → 0` as `β → ∞`.
  have h_exp : Filter.Tendsto (fun β => Real.exp (-(2 * β * J))) Filter.atTop (nhds 0) := by
    norm_num;
    exact Filter.Tendsto.atTop_mul_const ( by positivity ) ( Filter.tendsto_id.const_mul_atTop zero_lt_two );
  rw [ Filter.tendsto_congr' ( by filter_upwards [ h_eq, h_ratio ] with x hx₁ hx₂ using by rw [ hx₁, hx₂ ] ) ] ; convert Filter.Tendsto.log ( Filter.Tendsto.div ( tendsto_const_nhds.add h_exp ) ( tendsto_const_nhds.sub h_exp ) _ ) _ using 2 <;> norm_num;

end IsingChainPeriodic