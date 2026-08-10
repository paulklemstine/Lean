import Mathlib

/-!
# Lyapunov Exponents for Recurrent EML Architectures I: the linear cocycle theory

A *recurrent EML cell* is an iterated map `x ↦ σ (W x + b)` on a state space.  The
back-propagation-through-time gradient of such a system after `T` steps is a product
of Jacobians
`J_T = A_{T-1} A_{T-2} ⋯ A_0`,
a *linear cocycle*.  Exploding / vanishing gradients are exactly the statement that
`‖J_T‖` grows / decays exponentially, i.e. that the **maximum Lyapunov exponent**

`λ = limsup_{T → ∞} (1/T) log ‖J_T‖`

is positive / negative.  This file develops that theory abstractly in a Banach algebra
and then *computes the exponent exactly* in two situations:

* **Gelfand exactness** (`lyapunov_eq_log_spectralRadius`): for a weight-tied (autonomous)
  linear recurrent cell with Jacobian `a` in a complex Banach algebra, the limsup is a
  genuine limit and equals `log ρ(a)`, the logarithm of the *spectral radius*.  This is a
  bridge from dynamics to Banach-algebra spectral theory, via Gelfand's formula.
* **Fekete certificate** (`mle_le_ftle` / `tendsto_ftle_fekete`): for an invertible
  Jacobian the sequence of finite-time exponents converges and the limit is the
  *infimum*.  Consequently a single finite `T` with `‖a^T‖ ≤ 1` certifies
  `λ ≤ 0`: a checkable, non-asymptotic non-exploding-gradient guarantee.
* **Diagonal (gated) cells** (`ftle_diagonal`): for a diagonal recurrent cell the
  finite-time exponent is *exactly* `log (max_i |v i|)` for **every** `T ≥ 1`; no limit
  is needed.  Combining with Gelfand exactness recovers `ρ (diagonal v) = ‖v‖`.

## Main results

* `norm_jacProd_le_prod`, `norm_jacProd_le_pow` — submultiplicative cocycle bounds.
* `norm_jacProd_le_one_of_nonexpansive` — **non-exploding gradient guarantee**.
* `mle_le_log` — the maximum Lyapunov exponent is at most `log ρ` under a spectral-norm
  budget `‖A_k‖ ≤ ρ`.
* `tendsto_norm_jacProd_zero` — a strict budget `ρ < 1` forces gradients to vanish
  geometrically.
* `tendsto_ftle_fekete`, `mle_le_ftle` — Fekete (subadditivity) theory for invertible cells.
* `lyapunov_eq_log_spectralRadius`, `mle_eq_log_spectralRadius` — **exact** exponent.
* `ftle_diagonal`, `mle_diagonal`, `spectralRadius_diagonal` — exact exponent for a
  diagonal cell, and the resulting spectral radius identity.
-/

open Filter Topology Matrix
open scoped NNReal ENNReal

namespace EMLLyapunov

/-! ## 1.  The Jacobian cocycle of a recurrent EML architecture -/

/-- `jacProd J T` is the backpropagation-through-time Jacobian product
`J_{T-1} * J_{T-2} * ⋯ * J_0` of a recurrent cell whose Jacobian at time `k` is `J k`. -/
def jacProd {A : Type*} [Monoid A] (J : ℕ → A) : ℕ → A
  | 0 => 1
  | (T + 1) => J T * jacProd J T

@[simp] lemma jacProd_zero {A : Type*} [Monoid A] (J : ℕ → A) : jacProd J 0 = 1 := rfl

@[simp] lemma jacProd_succ {A : Type*} [Monoid A] (J : ℕ → A) (T : ℕ) :
    jacProd J (T + 1) = J T * jacProd J T := rfl

/-- A weight-tied (autonomous) cell has Jacobian cocycle `a ^ T`. -/
lemma jacProd_const {A : Type*} [Monoid A] (a : A) (T : ℕ) :
    jacProd (fun _ => a) T = a ^ T := by
  induction T with
  | zero => simp
  | succ T ih => rw [jacProd_succ, ih, ← pow_succ']

/-- The finite-time (time-`T`) maximal Lyapunov exponent of the cocycle `J`. -/
noncomputable def ftle {A : Type*} [NormedRing A] (J : ℕ → A) (T : ℕ) : ℝ :=
  (T : ℝ)⁻¹ * Real.log ‖jacProd J T‖

/-- The maximum Lyapunov exponent of a recurrent EML architecture. -/
noncomputable def mle {A : Type*} [NormedRing A] (J : ℕ → A) : ℝ :=
  limsup (ftle J) atTop

/-! ## 2.  Submultiplicative bounds and the non-exploding gradient guarantee -/

variable {A : Type*} [NormedRing A] [NormOneClass A]

/-- Submultiplicativity of the norm gives the basic cocycle bound. -/
theorem norm_jacProd_le_prod (J : ℕ → A) (T : ℕ) :
    ‖jacProd J T‖ ≤ ∏ k ∈ Finset.range T, ‖J k‖ := by
  induction T with
  | zero => simp
  | succ T ih =>
      rw [jacProd_succ, Finset.prod_range_succ]
      calc ‖J T * jacProd J T‖ ≤ ‖J T‖ * ‖jacProd J T‖ := norm_mul_le _ _
        _ ≤ ‖J T‖ * ∏ k ∈ Finset.range T, ‖J k‖ := by
              exact mul_le_mul_of_nonneg_left ih (norm_nonneg _)
        _ = (∏ k ∈ Finset.range T, ‖J k‖) * ‖J T‖ := mul_comm _ _

/-- With a per-step spectral-norm budget `ρ`, the `T`-step gradient is at most `ρ ^ T`. -/
theorem norm_jacProd_le_pow {J : ℕ → A} {ρ : ℝ} (h : ∀ k, ‖J k‖ ≤ ρ) (T : ℕ) :
    ‖jacProd J T‖ ≤ ρ ^ T := by
  refine (norm_jacProd_le_prod J T).trans ?_
  calc ∏ k ∈ Finset.range T, ‖J k‖ ≤ ∏ _k ∈ Finset.range T, ρ :=
        Finset.prod_le_prod (fun i _ => norm_nonneg _) (fun i _ => h i)
    _ = ρ ^ T := by simp

/-- **Non-exploding gradient guarantee.**  If every step is non-expansive (`‖A_k‖ ≤ 1`,
the design constraint enforced by orthogonal / spectral-normalised recurrent layers) then
the backpropagated gradient never exceeds its initial size, at any depth. -/
theorem norm_jacProd_le_one_of_nonexpansive {J : ℕ → A} (h : ∀ k, ‖J k‖ ≤ 1) (T : ℕ) :
    ‖jacProd J T‖ ≤ 1 := by
  simpa using norm_jacProd_le_pow h T

/-- Under a budget `ρ > 0` every finite-time exponent (at positive depth, for a
nondegenerate cocycle) is at most `log ρ`.

The nondegeneracy hypothesis `jacProd J T ≠ 0` cannot be dropped: with the Lean
convention `Real.log 0 = 0`, a cocycle that collapses to `0` would report exponent `0`
whereas its true exponent is `-∞`. -/
theorem ftle_le_log {J : ℕ → A} {ρ : ℝ} (h : ∀ k, ‖J k‖ ≤ ρ) {T : ℕ}
    (hT : 0 < T) (hne : jacProd J T ≠ 0) : ftle J T ≤ Real.log ρ := by
  have hTpos : (0:ℝ) < T := by exact_mod_cast hT
  have h0 : 0 < ‖jacProd J T‖ := norm_pos_iff.mpr hne
  have h1 : Real.log ‖jacProd J T‖ ≤ Real.log (ρ ^ T) :=
    Real.log_le_log h0 (norm_jacProd_le_pow h T)
  rw [Real.log_pow] at h1
  rw [ftle, inv_mul_le_iff₀ hTpos]
  linarith

/-! ## 3.  Lower bounds: invertible cells cannot lose gradient either -/

/-- For an invertible cocycle, the inverse Jacobian product obeys the dual bound. -/
theorem norm_inv_jacProd_le_pow {J : ℕ → Aˣ} {μ : ℝ}
    (h : ∀ k, ‖Units.val (J k)⁻¹‖ ≤ μ) (T : ℕ) :
    ‖Units.val (jacProd J T)⁻¹‖ ≤ μ ^ T := by
  have hμ : 0 ≤ μ := le_trans (norm_nonneg _) (h 0)
  induction T with
  | zero => simp
  | succ T ih =>
      have hrw : Units.val (jacProd J (T + 1))⁻¹
          = Units.val (jacProd J T)⁻¹ * Units.val (J T)⁻¹ := by
        rw [jacProd_succ, _root_.mul_inv_rev, Units.val_mul]
      rw [hrw, pow_succ]
      calc ‖Units.val (jacProd J T)⁻¹ * Units.val (J T)⁻¹‖
          ≤ ‖Units.val (jacProd J T)⁻¹‖ * ‖Units.val (J T)⁻¹‖ := norm_mul_le _ _
        _ ≤ μ ^ T * μ := mul_le_mul ih (h T) (norm_nonneg _) (by positivity)

omit [NormOneClass A] in
/-- The Jacobian cocycle of an invertible cell, computed in the unit group, agrees with
the cocycle of the underlying ring elements. -/
lemma jacProd_units_val (J : ℕ → Aˣ) (T : ℕ) :
    jacProd (fun k => Units.val (J k)) T = Units.val (jacProd J T) := by
  induction T with
  | zero => simp
  | succ T ih => rw [jacProd_succ, jacProd_succ, ih, Units.val_mul]

/-- **No vanishing gradient for invertible cells.**  If every inverse Jacobian is bounded
by `μ`, the `T`-step gradient is at least `μ ^ (-T)`. -/
theorem inv_pow_le_norm_jacProd {J : ℕ → Aˣ} {μ : ℝ} (hμ : 0 < μ)
    (h : ∀ k, ‖Units.val (J k)⁻¹‖ ≤ μ) (T : ℕ) :
    (μ ^ T)⁻¹ ≤ ‖jacProd (fun k => Units.val (J k)) T‖ := by
  have key : (1:ℝ) ≤ ‖Units.val (jacProd J T)‖ * μ ^ T := by
    have h1 : Units.val (jacProd J T) * Units.val (jacProd J T)⁻¹ = 1 := by
      simp
    calc (1:ℝ) = ‖(1 : A)‖ := by simp
      _ = ‖Units.val (jacProd J T) * Units.val (jacProd J T)⁻¹‖ := by rw [h1]
      _ ≤ ‖Units.val (jacProd J T)‖ * ‖Units.val (jacProd J T)⁻¹‖ := norm_mul_le _ _
      _ ≤ ‖Units.val (jacProd J T)‖ * μ ^ T :=
            mul_le_mul_of_nonneg_left (norm_inv_jacProd_le_pow h T) (norm_nonneg _)
  rw [jacProd_units_val, inv_le_iff_one_le_mul₀ (by positivity)]
  linarith

/-- Finite-time exponents of an invertible cell are bounded below by `-log μ`. -/
theorem neg_log_le_ftle {J : ℕ → Aˣ} {μ : ℝ} (hμ : 0 < μ)
    (h : ∀ k, ‖Units.val (J k)⁻¹‖ ≤ μ) {T : ℕ} (hT : 0 < T) :
    -Real.log μ ≤ ftle (fun k => Units.val (J k)) T := by
  have hTpos : (0:ℝ) < T := by exact_mod_cast hT
  have hlow := inv_pow_le_norm_jacProd hμ h T
  have hpos : (0:ℝ) < (μ ^ T)⁻¹ := by positivity
  have h1 : Real.log ((μ ^ T)⁻¹) ≤ Real.log ‖jacProd (fun k => Units.val (J k)) T‖ :=
    Real.log_le_log hpos hlow
  rw [Real.log_inv, Real.log_pow] at h1
  rw [ftle, le_inv_mul_iff₀ hTpos]
  linarith

/-! ## 4.  The exponent of an invertible cell is sandwiched -/

/-- **Two-sided Lyapunov sandwich.**  A recurrent EML cell whose Jacobians satisfy a
forward budget `‖A_k‖ ≤ ρ` and a backward budget `‖A_k⁻¹‖ ≤ μ` has maximum Lyapunov
exponent in `[-log μ, log ρ]`: gradients neither explode nor vanish exponentially.
For orthogonal / unitary recurrent parameterisations one may take `ρ = μ = 1`, forcing
the exponent to be exactly `0`. -/
theorem mle_mem_Icc {J : ℕ → Aˣ} {ρ μ : ℝ} (hμ : 0 < μ)
    (hup : ∀ k, ‖Units.val (J k)‖ ≤ ρ) (hlow : ∀ k, ‖Units.val (J k)⁻¹‖ ≤ μ) :
    mle (fun k => Units.val (J k)) ∈ Set.Icc (-Real.log μ) (Real.log ρ) := by
  set u := ftle (fun k => Units.val (J k)) with hu
  have hlowev : ∀ᶠ T in atTop, -Real.log μ ≤ u T := by
    filter_upwards [eventually_gt_atTop 0] with T hT using neg_log_le_ftle hμ hlow hT
  have hupev : ∀ᶠ T in atTop, u T ≤ Real.log ρ := by
    filter_upwards [eventually_gt_atTop 0] with T hT
    have hpos : (0:ℝ) < ‖jacProd (fun k => Units.val (J k)) T‖ :=
      lt_of_lt_of_le (by positivity) (inv_pow_le_norm_jacProd hμ hlow T)
    exact ftle_le_log hup hT (norm_pos_iff.mp hpos)
  constructor
  · exact le_limsup_of_frequently_le hlowev.frequently
      (Filter.isBoundedUnder_of_eventually_le hupev)
  · exact limsup_le_of_le (Filter.isCoboundedUnder_le_of_eventually_le atTop hlowev) hupev

/-- **Orthogonal / unitary recurrent cells sit exactly at the edge of chaos.**  If every
Jacobian and every inverse Jacobian is norm-`≤ 1` (the defining property of an isometric,
e.g. orthogonal or unitary, recurrent parameterisation) then the maximum Lyapunov exponent
is *exactly* `0`: gradients neither explode nor vanish exponentially. -/
theorem mle_eq_zero_of_isometric {J : ℕ → Aˣ}
    (hup : ∀ k, ‖Units.val (J k)‖ ≤ 1) (hlow : ∀ k, ‖Units.val (J k)⁻¹‖ ≤ 1) :
    mle (fun k => Units.val (J k)) = 0 := by
  have h := mle_mem_Icc (ρ := 1) (μ := 1) one_pos hup hlow
  rw [Real.log_one, neg_zero] at h
  exact le_antisymm h.2 h.1

/-- **Geometric gradient decay.**  A strict per-step budget `ρ < 1` makes the
backpropagated gradient vanish geometrically. -/
theorem tendsto_norm_jacProd_zero {J : ℕ → A} {ρ : ℝ} (h : ∀ k, ‖J k‖ ≤ ρ) (hρ : ρ < 1) :
    Tendsto (fun T => ‖jacProd J T‖) atTop (𝓝 0) := by
  have hρ0 : 0 ≤ ρ := le_trans (norm_nonneg _) (h 0)
  refine squeeze_zero (fun T => norm_nonneg _) (fun T => norm_jacProd_le_pow h T) ?_
  exact tendsto_pow_atTop_nhds_zero_of_lt_one hρ0 hρ

/-! ## 5.  Fekete theory: the exponent exists and finite depth certifies it -/

/-- For a weight-tied invertible cell the gradient norm is strictly positive. -/
lemma norm_pow_pos (a : Aˣ) (T : ℕ) : 0 < ‖(Units.val a) ^ T‖ := by
  set μ := max ‖Units.val a⁻¹‖ 1 with hμdef
  have hμ : 0 < μ := lt_of_lt_of_le zero_lt_one (le_max_right _ _)
  have := inv_pow_le_norm_jacProd (J := fun _ : ℕ => a) hμ (fun _ => le_max_left _ _) T
  rw [jacProd_const] at this
  exact lt_of_lt_of_le (by positivity) this

/-- `T ↦ log ‖a ^ T‖` is subadditive: this is the abstract source of Fekete convergence
of finite-time Lyapunov exponents. -/
lemma subadditive_log_norm_pow (a : Aˣ) :
    Subadditive (fun T => Real.log ‖(Units.val a) ^ T‖) := by
  intro m n
  have hm := norm_pow_pos a m
  have hn := norm_pow_pos a n
  have hle : ‖(Units.val a) ^ (m + n)‖ ≤ ‖(Units.val a) ^ m‖ * ‖(Units.val a) ^ n‖ := by
    rw [pow_add]; exact norm_mul_le _ _
  calc Real.log ‖(Units.val a) ^ (m + n)‖
      ≤ Real.log (‖(Units.val a) ^ m‖ * ‖(Units.val a) ^ n‖) :=
        Real.log_le_log (norm_pow_pos a (m + n)) hle
    _ = Real.log ‖(Units.val a) ^ m‖ + Real.log ‖(Units.val a) ^ n‖ :=
        Real.log_mul (ne_of_gt hm) (ne_of_gt hn)

/-- **Fekete existence and finite-depth certificate.**  For a weight-tied invertible
recurrent EML cell with Jacobian `a`, the finite-time Lyapunov exponents converge, and the
limit is *below every one of them*.  Hence measuring the gradient growth at a single depth
`T` already certifies an upper bound on the asymptotic exponent — a non-asymptotic
non-exploding-gradient guarantee. -/
theorem tendsto_ftle_fekete (a : Aˣ) :
    ∃ L : ℝ, Tendsto (ftle (fun _ : ℕ => Units.val a)) atTop (𝓝 L) ∧
      ∀ T : ℕ, T ≠ 0 → L ≤ ftle (fun _ : ℕ => Units.val a) T := by
  set u : ℕ → ℝ := fun T => Real.log ‖(Units.val a) ^ T‖ with hu
  have hsub : Subadditive u := subadditive_log_norm_pow a
  set μ := max ‖Units.val a⁻¹‖ 1 with hμdef
  have hμ : 0 < μ := lt_of_lt_of_le zero_lt_one (le_max_right _ _)
  have hcoc : ∀ T : ℕ, jacProd (fun _ : ℕ => Units.val a) T = (Units.val a) ^ T :=
    fun T => jacProd_const _ T
  have hftle : ∀ T : ℕ, ftle (fun _ : ℕ => Units.val a) T = u T / T := by
    intro T
    rw [ftle, hcoc, hu]
    ring
  have hbdd : BddBelow (Set.range fun n => u n / n) := by
    refine ⟨min (-Real.log μ) 0, ?_⟩
    rintro x ⟨n, rfl⟩
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp [hu]
    · have := neg_log_le_ftle (J := fun _ : ℕ => a) hμ (fun _ => le_max_left _ _) hn
      rw [hftle n] at this
      exact le_trans (min_le_left _ _) this
  refine ⟨hsub.lim, ?_, ?_⟩
  · have := hsub.tendsto_lim hbdd
    refine this.congr (fun T => ?_)
    rw [hftle T]
  · intro T hT
    rw [hftle T]
    exact hsub.lim_le_div hbdd hT


/-! ## 6.  Gelfand exactness: the exponent *is* the log spectral radius -/

section Gelfand

variable {B : Type*} [NormedRing B] [NormOneClass B] [NormedAlgebra ℂ B] [CompleteSpace B]

lemma spectralRadius_ne_top (a : B) : spectralRadius ℂ a ≠ ⊤ :=
  ne_top_of_le_ne_top ENNReal.coe_ne_top (spectrum.spectralRadius_le_nnnorm a)

omit [NormOneClass B] in
/-- A cell with nonzero spectral radius has nonvanishing gradient at every depth. -/
lemma norm_pow_pos_of_spectralRadius_ne_zero {a : B} (h0 : spectralRadius ℂ a ≠ 0) {T : ℕ}
    (hT : 0 < T) : 0 < ‖a ^ T‖ := by
  rcases eq_or_lt_of_le (norm_nonneg (a ^ T)) with h | h
  · exfalso
    obtain ⟨m, rfl⟩ : ∃ m, T = m + 1 := ⟨T - 1, by omega⟩
    have hb := spectrum.spectralRadius_le_pow_nnnorm_pow_one_div ℂ a m
    have hz : ‖a ^ (m + 1)‖₊ = 0 := nnnorm_eq_zero.mpr (norm_eq_zero.mp h.symm)
    rw [hz] at hb
    rw [ENNReal.coe_zero, ENNReal.zero_rpow_of_pos (by positivity), zero_mul] at hb
    exact h0 (le_antisymm hb (zero_le _))
  · exact h

/-- **Exact maximum Lyapunov exponent (Gelfand form).**  For a weight-tied linear
recurrent EML cell with Jacobian `a` in a complex Banach algebra, the finite-time
Lyapunov exponents *converge*, and the limit is exactly `log ρ(a)`, the logarithm of the
spectral radius.  This is the promised exact computation: the asymptotic gradient growth
rate is a purely spectral quantity, independent of the chosen (submultiplicative) norm. -/
theorem tendsto_ftle_log_spectralRadius (a : B) (h0 : spectralRadius ℂ a ≠ 0) :
    Tendsto (ftle (fun _ : ℕ => a)) atTop (𝓝 (Real.log (spectralRadius ℂ a).toReal)) := by
  have hfin := spectralRadius_ne_top a
  have G := spectrum.pow_nnnorm_pow_one_div_tendsto_nhds_spectralRadius a
  have G2 : Tendsto (fun n : ℕ => ((‖a ^ n‖₊ : ℝ≥0∞) ^ (1 / n : ℝ)).toReal) atTop
      (𝓝 (spectralRadius ℂ a).toReal) := (ENNReal.tendsto_toReal hfin).comp G
  have hne : (spectralRadius ℂ a).toReal ≠ 0 := ENNReal.toReal_ne_zero.mpr ⟨h0, hfin⟩
  have G3 := (Real.continuousAt_log hne).tendsto.comp G2
  refine G3.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with n hn
  have hpos : 0 < ‖a ^ n‖ := norm_pow_pos_of_spectralRadius_ne_zero h0 hn
  have hnn : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  show Real.log (((‖a ^ n‖₊ : ℝ≥0∞) ^ (1 / n : ℝ)).toReal) = ftle (fun _ : ℕ => a) n
  rw [← ENNReal.toReal_rpow]
  simp only [ENNReal.coe_toReal, coe_nnnorm]
  rw [Real.log_rpow hpos, ftle, jacProd_const]
  field_simp

/-- The maximum Lyapunov exponent of a weight-tied linear recurrent EML cell equals
`log ρ(a)` exactly. -/
theorem mle_eq_log_spectralRadius (a : B) (h0 : spectralRadius ℂ a ≠ 0) :
    mle (fun _ : ℕ => a) = Real.log (spectralRadius ℂ a).toReal :=
  (tendsto_ftle_log_spectralRadius a h0).limsup_eq

/-- **Spectral finite-depth certificate.**  Combining Gelfand exactness with Fekete
subadditivity: for an invertible weight-tied cell the exact exponent `log ρ(a)` is
dominated by the measured finite-depth exponent at *every* depth `T ≥ 1`.  A single
measurement `‖a ^ T‖ ≤ 1` therefore certifies `ρ(a) ≤ 1`, i.e. no exploding gradients at
any depth. -/
theorem log_spectralRadius_le_ftle (a : Bˣ) (h0 : spectralRadius ℂ (Units.val a) ≠ 0)
    {T : ℕ} (hT : T ≠ 0) :
    Real.log (spectralRadius ℂ (Units.val a)).toReal ≤ ftle (fun _ : ℕ => Units.val a) T := by
  obtain ⟨L, hL, hcert⟩ := tendsto_ftle_fekete a
  have : L = Real.log (spectralRadius ℂ (Units.val a)).toReal :=
    tendsto_nhds_unique hL (tendsto_ftle_log_spectralRadius (Units.val a) h0)
  rw [← this]
  exact hcert T hT

end Gelfand

/-! ## 7.  Exact exponent of a diagonal (gated) recurrent EML cell

A diagonal recurrent cell `x ↦ v ⊙ x` — the linearisation of a gated unit such as a
leaky-integrator / diagonal-RNN layer — has an exponent that requires no limiting
procedure at all: *every* finite-time exponent already equals `log (max_i |v i|)`.
-/

section Diagonal

open scoped Matrix.Norms.Operator

variable {m : Type*} [Fintype m] [DecidableEq m] [Nonempty m]

omit [DecidableEq m] in
/-- On a finite product of copies of `ℂ` (sup norm) the norm is exactly multiplicative on
powers. -/
lemma nnnorm_pi_pow (v : m → ℂ) (T : ℕ) : ‖v ^ T‖₊ = ‖v‖₊ ^ T := by
  have hv : ∀ i, (v ^ T) i = (v i) ^ T := fun i => rfl
  obtain ⟨i₀, -, hi₀⟩ :=
    Finset.exists_mem_eq_sup (Finset.univ : Finset m) Finset.univ_nonempty (fun i => ‖v i‖₊)
  rw [Pi.nnnorm_def, Pi.nnnorm_def]
  refine le_antisymm (Finset.sup_le fun i _ => ?_) ?_
  · rw [hv i, nnnorm_pow]
    exact pow_le_pow_left' (Finset.le_sup (f := fun j => ‖v j‖₊) (Finset.mem_univ i)) T
  · rw [hi₀]
    calc ‖v i₀‖₊ ^ T = ‖(v ^ T) i₀‖₊ := by rw [hv i₀, nnnorm_pow]
      _ ≤ Finset.univ.sup fun i => ‖(v ^ T) i‖₊ :=
            Finset.le_sup (f := fun j => ‖(v ^ T) j‖₊) (Finset.mem_univ i₀)

/-- The `T`-step gradient of a diagonal cell is exactly `(max_i |v i|) ^ T`. -/
lemma nnnorm_diagonal_pow (v : m → ℂ) (T : ℕ) :
    ‖(Matrix.diagonal v) ^ T‖₊ = ‖v‖₊ ^ T := by
  rw [Matrix.diagonal_pow, Matrix.linfty_opNNNorm_diagonal, nnnorm_pi_pow v T]

/-- The `T`-step gradient of a diagonal cell is exactly `(max_i |v i|) ^ T`. -/
theorem norm_diagonal_pow (v : m → ℂ) (T : ℕ) :
    ‖(Matrix.diagonal v) ^ T‖ = ‖v‖ ^ T := by
  have := congrArg (fun x : ℝ≥0 => (x : ℝ)) (nnnorm_diagonal_pow v T)
  simpa using this

/-- **Exact finite-time exponent of a diagonal cell.**  For every depth `T ≥ 1` the
finite-time Lyapunov exponent is exactly `log ‖v‖ = log (max_i |v i|)`; there is no
transient and no limit to take. -/
theorem ftle_diagonal (v : m → ℂ) {T : ℕ} (hT : 0 < T) :
    ftle (fun _ : ℕ => Matrix.diagonal v) T = Real.log ‖v‖ := by
  have hT' : (T : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hT.ne'
  rw [ftle, jacProd_const, norm_diagonal_pow v T, Real.log_pow]
  field_simp

/-- The maximum Lyapunov exponent of a diagonal recurrent EML cell is `log (max_i |v i|)`:
the gate spectrum alone decides stability. -/
theorem mle_diagonal (v : m → ℂ) :
    mle (fun _ : ℕ => Matrix.diagonal v) = Real.log ‖v‖ := by
  refine Tendsto.limsup_eq ?_
  refine Tendsto.congr' ?_ (tendsto_const_nhds (x := Real.log ‖v‖) (f := atTop))
  filter_upwards [eventually_gt_atTop 0] with T hT
  exact (ftle_diagonal v hT).symm

/-- **A spectral by-product.**  Comparing the exact diagonal computation with Gelfand
exactness identifies the spectral radius of a diagonal matrix with the sup norm of its
diagonal — a dynamical proof of a spectral fact. -/
theorem spectralRadius_diagonal (v : m → ℂ) (hv : ‖v‖ ≠ 0) :
    (spectralRadius ℂ (Matrix.diagonal v)).toReal = ‖v‖ := by
  have hvpos : 0 < ‖v‖ := lt_of_le_of_ne (norm_nonneg _) (Ne.symm hv)
  have h0 : spectralRadius ℂ (Matrix.diagonal v) ≠ 0 := by
    intro hzero
    have hlim := spectrum.pow_nnnorm_pow_one_div_tendsto_nhds_spectralRadius
      (Matrix.diagonal v)
    rw [hzero] at hlim
    have hconst : ∀ᶠ T : ℕ in atTop,
        ((‖(Matrix.diagonal v) ^ T‖₊ : ℝ≥0∞) ^ (1 / T : ℝ)) = (‖v‖₊ : ℝ≥0∞) := by
      filter_upwards [eventually_gt_atTop 0] with T hT
      have hTpos : (0:ℝ) < T := by exact_mod_cast hT
      rw [nnnorm_diagonal_pow v T, ENNReal.coe_pow, ← ENNReal.rpow_natCast (‖v‖₊ : ℝ≥0∞) T,
        ← ENNReal.rpow_mul, mul_one_div, div_self (ne_of_gt hTpos), ENNReal.rpow_one]
    have hlim0 : Tendsto (fun _ : ℕ => (‖v‖₊ : ℝ≥0∞)) atTop (𝓝 0) := hlim.congr' hconst
    have hzz := tendsto_nhds_unique hlim0 tendsto_const_nhds
    exact hv (by simpa using congrArg ENNReal.toReal hzz.symm)
  have hgel := tendsto_ftle_log_spectralRadius (Matrix.diagonal v) h0
  have hconst : Tendsto (ftle (fun _ : ℕ => Matrix.diagonal v)) atTop (𝓝 (Real.log ‖v‖)) := by
    refine Tendsto.congr' ?_ (tendsto_const_nhds (x := Real.log ‖v‖) (f := atTop))
    filter_upwards [eventually_gt_atTop 0] with T hT
    exact (ftle_diagonal v hT).symm
  have hlog := tendsto_nhds_unique hgel hconst
  have hρpos : 0 < (spectralRadius ℂ (Matrix.diagonal v)).toReal := by
    have := ENNReal.toReal_ne_zero.mpr ⟨h0, spectralRadius_ne_top _⟩
    exact lt_of_le_of_ne ENNReal.toReal_nonneg (Ne.symm this)
  exact Real.log_injOn_pos (Set.mem_Ioi.mpr hρpos) (Set.mem_Ioi.mpr hvpos) hlog

end Diagonal

end EMLLyapunov