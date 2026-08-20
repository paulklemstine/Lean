/-
# The two-parameter exponent staircase

Fifth research cycle on the paper *"Chebotarev geodesic theorem: non-split case"*.

`HasErrorExponent π M θ` (the shape "exponent `θ + ε`") deliberately forgets logarithmic
factors: `Shared.ChebotarevGeodesicTransfer` proves `optimalExponent (M + K x^θ log^k x) M = θ`
for every `k`.  The natural question left open there is what the `ε` actually hides.  This
file answers it completely for the model error terms produced by trace formulae.

We introduce the **two-parameter, `ε`-free** predicate

  `HasLogErrorExponent π M θ k  :  |π x − M x| ≤ C x^θ (log x)^k  for large x`,

show that its truth region is a *staircase* (upward closed in both parameters) whose
projection to the first coordinate recovers `HasErrorExponent`, and then compute the region
exactly for `π = M + K x^θ (log x)^k`:

  `HasLogErrorExponent π M θ' j ↔ θ < θ' ∨ (θ' = θ ∧ k ≤ j)`.

So the region has a single corner, at `(θ, k)`, and both coordinates of that corner are
genuine invariants of the pair `(π, M)`: the exponent `θ` *and* the log power `k`.  In
particular an error term `x^{25/36} (log x)^k` is not compatible with `x^{25/36} (log x)^{k−1}`,
which is precisely the information destroyed by writing "exponent `25/36 + ε`".
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic
import Catalog.Shared.ChebotarevGeodesicSharpness

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-- The `ε`-free two-parameter error predicate: `|π − M| ≤ C x^θ (log x)^k` for large `x`.
This is literally the shape a trace-formula computation outputs. -/
def HasLogErrorExponent (π M : ℝ → ℝ) (θ : ℝ) (k : ℕ) : Prop :=
  ∃ C > 0, ∃ X ≥ (1 : ℝ), ∀ x ≥ X, |π x - M x| ≤ C * x ^ θ * (Real.log x) ^ k

variable {π M : ℝ → ℝ} {θ θ' : ℝ} {k j : ℕ}

/-- `1 ≤ log x` for `x ≥ e`; the basic fact behind monotonicity in the log parameter. -/
theorem one_le_log_of_exp_le {x : ℝ} (hx : Real.exp 1 ≤ x) : 1 ≤ Real.log x :=
  (Real.le_log_iff_exp_le (lt_of_lt_of_le (Real.exp_pos 1) hx)).mpr hx

/-- The staircase is upward closed in the log parameter. -/
theorem HasLogErrorExponent.mono_log (h : HasLogErrorExponent π M θ k) (hkj : k ≤ j) :
    HasLogErrorExponent π M θ j := by
  obtain ⟨C, hC, X, hX, hb⟩ := h
  refine ⟨C, hC, max X (Real.exp 1), le_trans hX (le_max_left _ _), fun x hx => ?_⟩
  have hxX : X ≤ x := le_trans (le_max_left _ _) hx
  have hxe : Real.exp 1 ≤ x := le_trans (le_max_right _ _) hx
  have hlog : 1 ≤ Real.log x := one_le_log_of_exp_le hxe
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hxX
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hpow : (Real.log x) ^ k ≤ (Real.log x) ^ j := pow_le_pow_right₀ hlog hkj
  calc |π x - M x| ≤ C * x ^ θ * (Real.log x) ^ k := hb x hxX
    _ ≤ C * x ^ θ * (Real.log x) ^ j := by
        exact mul_le_mul_of_nonneg_left hpow (by positivity)

/-- The staircase is upward closed in the exponent. -/
theorem HasLogErrorExponent.mono_exponent (h : HasLogErrorExponent π M θ k) (hle : θ ≤ θ') :
    HasLogErrorExponent π M θ' k := by
  obtain ⟨C, hC, X, hX, hb⟩ := h
  refine ⟨C, hC, max X (Real.exp 1), le_trans hX (le_max_left _ _), fun x hx => ?_⟩
  have hxX : X ≤ x := le_trans (le_max_left _ _) hx
  have hxe : Real.exp 1 ≤ x := le_trans (le_max_right _ _) hx
  have hlog : 1 ≤ Real.log x := one_le_log_of_exp_le hxe
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hxX
  have hstep : x ^ θ ≤ x ^ θ' := Real.rpow_le_rpow_of_exponent_le hx1 hle
  have hlogk : (0 : ℝ) ≤ (Real.log x) ^ k := by positivity
  calc |π x - M x| ≤ C * x ^ θ * (Real.log x) ^ k := hb x hxX
    _ ≤ C * x ^ θ' * (Real.log x) ^ k := by
        have : C * x ^ θ ≤ C * x ^ θ' := mul_le_mul_of_nonneg_left hstep hC.le
        exact mul_le_mul_of_nonneg_right this hlogk

/-- The two-parameter predicate refines the one-parameter one: the projection of the
staircase to its first coordinate is the exponent set. -/
theorem hasErrorExponent_of_hasLogErrorExponent (h : HasLogErrorExponent π M θ k) :
    HasErrorExponent π M θ := by
  obtain ⟨C, hC, X, hX, hb⟩ := h
  intro ε hε
  refine ⟨C * ((k + 1) / ε) ^ k + 1, by positivity, X, hX, fun x hx => ?_⟩
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hlogk : (Real.log x) ^ k ≤ ((k + 1) / ε) ^ k * x ^ ε := log_pow_le hε hx1
  have hsplit : x ^ (θ + ε) = x ^ θ * x ^ ε := Real.rpow_add hx0 θ ε
  have hxε : (0 : ℝ) < x ^ ε := Real.rpow_pos_of_pos hx0 ε
  calc |π x - M x| ≤ C * x ^ θ * (Real.log x) ^ k := hb x hx
    _ ≤ C * x ^ θ * (((k + 1) / ε) ^ k * x ^ ε) :=
        mul_le_mul_of_nonneg_left hlogk (by positivity)
    _ = (C * ((k + 1) / ε) ^ k) * (x ^ θ * x ^ ε) := by ring
    _ ≤ (C * ((k + 1) / ε) ^ k + 1) * (x ^ θ * x ^ ε) := by nlinarith
    _ = (C * ((k + 1) / ε) ^ k + 1) * x ^ (θ + ε) := by rw [hsplit]

/-! ## The staircase of a model error term

Throughout: `mdl M K θ k` is the counting function `M + K x^θ (log x)^k`. -/

/-- The model counting function `M(x) + K x^θ (log x)^k`. -/
noncomputable def mdl (M : ℝ → ℝ) (K θ : ℝ) (k : ℕ) : ℝ → ℝ :=
  fun x => M x + K * x ^ θ * (Real.log x) ^ k

theorem mdl_sub (M : ℝ → ℝ) (K θ : ℝ) (k : ℕ) (x : ℝ) :
    mdl M K θ k x - M x = K * x ^ θ * (Real.log x) ^ k := by
  simp [mdl]

/-- The model sits on its own corner: `(θ, k)` is admissible. -/
theorem hasLogErrorExponent_mdl (M : ℝ → ℝ) {K θ : ℝ} (hK : 0 < K) (k : ℕ) :
    HasLogErrorExponent (mdl M K θ k) M θ k := by
  refine ⟨K, hK, 1, le_rfl, fun x hx => ?_⟩
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
  have hlog : 0 ≤ Real.log x := Real.log_nonneg hx
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  rw [mdl_sub, abs_of_nonneg (by positivity)]

/-- Above the corner exponent, no log factor is needed at all. -/
theorem hasLogErrorExponent_mdl_of_lt (M : ℝ → ℝ) {K θ θ' : ℝ} (hK : 0 < K) (k : ℕ)
    (hθθ' : θ < θ') : HasLogErrorExponent (mdl M K θ k) M θ' 0 := by
  set δ := θ' - θ with hδdef
  have hδ : 0 < δ := by rw [hδdef]; linarith
  refine ⟨K * ((k + 1) / δ) ^ k, by positivity, 1, le_rfl, fun x hx => ?_⟩
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
  have hlog : 0 ≤ Real.log x := Real.log_nonneg hx
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hlogk : (Real.log x) ^ k ≤ ((k + 1) / δ) ^ k * x ^ δ := log_pow_le hδ hx
  have hsplit : x ^ θ' = x ^ θ * x ^ δ := by
    rw [← Real.rpow_add hx0]; rw [hδdef]; ring_nf
  rw [mdl_sub, abs_of_nonneg (by positivity), hsplit]
  calc K * x ^ θ * (Real.log x) ^ k
      ≤ K * x ^ θ * (((k + 1) / δ) ^ k * x ^ δ) :=
        mul_le_mul_of_nonneg_left hlogk (by positivity)
    _ = K * ((k + 1) / δ) ^ k * (x ^ θ * x ^ δ) * 1 := by ring
    _ = K * ((k + 1) / δ) ^ k * (x ^ θ * x ^ δ) * (Real.log x) ^ 0 := by norm_num

/-- **Rigidity in the log parameter.**  For the model, the exponent `θ` cannot be kept while
lowering the log power: the corner really is a corner. -/
theorem not_hasLogErrorExponent_mdl_of_lt_log (M : ℝ → ℝ) {K θ : ℝ} (hK : 0 < K) {k j : ℕ}
    (hjk : j < k) : ¬ HasLogErrorExponent (mdl M K θ k) M θ j := by
  rintro ⟨C, hC, X, hX, hb⟩
  -- pick `x` large: `x ≥ X`, `x ≥ e`, and `log x > C / K`
  obtain ⟨x, hxX, hxe, hxlog⟩ :
      ∃ x : ℝ, X ≤ x ∧ Real.exp 1 ≤ x ∧ C / K < Real.log x := by
    obtain ⟨x, hx⟩ := ((eventually_ge_atTop X).and ((eventually_ge_atTop (Real.exp 1)).and
      (Real.tendsto_log_atTop.eventually_gt_atTop (C / K)))).exists
    exact ⟨x, hx.1, hx.2.1, hx.2.2⟩
  have hx1 : (1 : ℝ) ≤ x := le_trans (Real.one_le_exp (by norm_num)) hxe
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hlog : 1 ≤ Real.log x := one_le_log_of_exp_le hxe
  have hlogpos : (0 : ℝ) < Real.log x := lt_of_lt_of_le one_pos hlog
  have hbound := hb x hxX
  rw [mdl_sub, abs_of_nonneg (by positivity)] at hbound
  -- `log^k ≥ log^(j+1)`
  have hstep : (Real.log x) ^ (j + 1) ≤ (Real.log x) ^ k :=
    pow_le_pow_right₀ hlog hjk
  have h1 : K * x ^ θ * (Real.log x) ^ (j + 1) ≤ C * x ^ θ * (Real.log x) ^ j := by
    calc K * x ^ θ * (Real.log x) ^ (j + 1)
        ≤ K * x ^ θ * (Real.log x) ^ k :=
          mul_le_mul_of_nonneg_left hstep (by positivity)
      _ ≤ C * x ^ θ * (Real.log x) ^ j := hbound
  have hlogj : (0 : ℝ) < (Real.log x) ^ j := by positivity
  have h2 : K * Real.log x ≤ C := by
    have hexp : K * x ^ θ * (Real.log x) ^ (j + 1)
        = (K * Real.log x) * (x ^ θ * (Real.log x) ^ j) := by ring
    have hexp' : C * x ^ θ * (Real.log x) ^ j = C * (x ^ θ * (Real.log x) ^ j) := by ring
    rw [hexp, hexp'] at h1
    have hposf : (0 : ℝ) < x ^ θ * (Real.log x) ^ j := by positivity
    exact le_of_mul_le_mul_right (by linarith [h1]) hposf
  rw [div_lt_iff₀ hK] at hxlog
  linarith

/-- **Rigidity in the exponent.**  For the model, no log power can compensate a smaller
exponent. -/
theorem not_hasLogErrorExponent_mdl_of_lt_exponent (M : ℝ → ℝ) {K θ θ' : ℝ} (hK : 0 < K)
    (k j : ℕ) (hθ'θ : θ' < θ) : ¬ HasLogErrorExponent (mdl M K θ k) M θ' j := by
  rintro ⟨C, hC, X, hX, hb⟩
  set δ := (θ - θ') / 2 with hδdef
  have hδ : 0 < δ := by rw [hδdef]; linarith
  have hgap : 0 < θ - θ' - δ := by rw [hδdef]; linarith
  set C' := C * ((j + 1) / δ) ^ j with hC'def
  have hC' : 0 < C' := by rw [hC'def]; positivity
  -- pick `x` large enough that `x^(θ-θ'-δ) > C'/K`
  have hbig : Tendsto (fun x : ℝ => x ^ (θ - θ' - δ)) atTop atTop := tendsto_rpow_atTop hgap
  obtain ⟨x, hxX, hxe, hxbig⟩ :
      ∃ x : ℝ, X ≤ x ∧ Real.exp 1 ≤ x ∧ C' / K < x ^ (θ - θ' - δ) := by
    obtain ⟨x, hx⟩ := ((eventually_ge_atTop X).and ((eventually_ge_atTop (Real.exp 1)).and
      (hbig.eventually_gt_atTop (C' / K)))).exists
    exact ⟨x, hx.1, hx.2.1, hx.2.2⟩
  have hx1 : (1 : ℝ) ≤ x := le_trans (Real.one_le_exp (by norm_num)) hxe
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hlog : 1 ≤ Real.log x := one_le_log_of_exp_le hxe
  have hxθ' : (0 : ℝ) < x ^ θ' := Real.rpow_pos_of_pos hx0 θ'
  have hbound := hb x hxX
  rw [mdl_sub, abs_of_nonneg (by positivity)] at hbound
  -- lower bound the left-hand side, upper bound the right-hand side
  have hlow : K * x ^ θ ≤ K * x ^ θ * (Real.log x) ^ k := by
    have h1 : (1 : ℝ) ≤ (Real.log x) ^ k := one_le_pow₀ hlog
    have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
    calc K * x ^ θ = K * x ^ θ * 1 := by ring
      _ ≤ K * x ^ θ * (Real.log x) ^ k := mul_le_mul_of_nonneg_left h1 (by positivity)
  have hlogj : (Real.log x) ^ j ≤ ((j + 1) / δ) ^ j * x ^ δ := log_pow_le hδ hx1
  have hhigh : C * x ^ θ' * (Real.log x) ^ j ≤ C' * x ^ (θ' + δ) := by
    have hsplit : x ^ (θ' + δ) = x ^ θ' * x ^ δ := Real.rpow_add hx0 θ' δ
    calc C * x ^ θ' * (Real.log x) ^ j
        ≤ C * x ^ θ' * (((j + 1) / δ) ^ j * x ^ δ) :=
          mul_le_mul_of_nonneg_left hlogj (by positivity)
      _ = C' * (x ^ θ' * x ^ δ) := by rw [hC'def]; ring
      _ = C' * x ^ (θ' + δ) := by rw [hsplit]
  have hkey : K * x ^ θ ≤ C' * x ^ (θ' + δ) := le_trans hlow (le_trans hbound hhigh)
  have hsplit2 : x ^ θ = x ^ (θ - θ' - δ) * x ^ (θ' + δ) := by
    rw [← Real.rpow_add hx0]; ring_nf
  have hxpos : (0 : ℝ) < x ^ (θ' + δ) := Real.rpow_pos_of_pos hx0 _
  rw [hsplit2] at hkey
  have hfin : K * x ^ (θ - θ' - δ) ≤ C' := by
    refine le_of_mul_le_mul_right ?_ hxpos
    calc K * x ^ (θ - θ' - δ) * x ^ (θ' + δ)
        = K * (x ^ (θ - θ' - δ) * x ^ (θ' + δ)) := by ring
      _ ≤ C' * x ^ (θ' + δ) := hkey
  rw [div_lt_iff₀ hK] at hxbig
  nlinarith

/-- **The staircase of the model, computed exactly.**  For `π = M + K x^θ (log x)^k` the set
of admissible pairs `(θ', j)` is
`{θ < θ'} ∪ {θ' = θ, k ≤ j}`: a quarter-plane with a single corner at `(θ, k)`.  Hence both
the exponent `θ` and the log power `k` are invariants of the pair `(π, M)`; only the first of
them is visible to `HasErrorExponent`. -/
theorem hasLogErrorExponent_mdl_iff (M : ℝ → ℝ) {K θ θ' : ℝ} (hK : 0 < K) (k j : ℕ) :
    HasLogErrorExponent (mdl M K θ k) M θ' j ↔ (θ < θ' ∨ (θ' = θ ∧ k ≤ j)) := by
  constructor
  · intro h
    rcases lt_trichotomy θ' θ with hlt | heq | hgt
    · exact absurd h (not_hasLogErrorExponent_mdl_of_lt_exponent M hK k j hlt)
    · refine Or.inr ⟨heq, ?_⟩
      by_contra hjk
      push_neg at hjk
      subst heq
      exact not_hasLogErrorExponent_mdl_of_lt_log M hK hjk h
    · exact Or.inl hgt
  · rintro (hlt | ⟨rfl, hkj⟩)
    · exact (hasLogErrorExponent_mdl_of_lt M hK k hlt).mono_log (Nat.zero_le j)
    · exact (hasLogErrorExponent_mdl M hK k).mono_log hkj

/-- The corner of the staircase of `M + K x^{25/36} (log x)^k`, in the shape in which trace
formulae deliver the Chebotarev geodesic theorem: the exponent is exactly `25/36`, the log
power is exactly `k`, and dropping either one is impossible. -/
theorem mdl_corner_25_36 (M : ℝ → ℝ) {K : ℝ} (hK : 0 < K) (k : ℕ) :
    HasLogErrorExponent (mdl M K (25 / 36) k) M (25 / 36) k ∧
      (∀ j < k, ¬ HasLogErrorExponent (mdl M K (25 / 36) k) M (25 / 36) j) ∧
      (∀ θ' < (25 : ℝ) / 36, ∀ j, ¬ HasLogErrorExponent (mdl M K (25 / 36) k) M θ' j) ∧
      HasErrorExponent (mdl M K (25 / 36) k) M (25 / 36) := by
  refine ⟨hasLogErrorExponent_mdl M hK k, fun j hj => ?_, fun θ' hθ' j => ?_, ?_⟩
  · exact not_hasLogErrorExponent_mdl_of_lt_log M hK hj
  · exact not_hasLogErrorExponent_mdl_of_lt_exponent M hK k j hθ'
  · exact hasErrorExponent_of_hasLogErrorExponent (hasLogErrorExponent_mdl M hK k)

end ChebotarevGeodesic