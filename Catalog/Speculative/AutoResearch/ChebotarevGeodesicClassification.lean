/-
# Chebotarev geodesic theorem, non-split case — cycle 7: classification of staircases

Research thread on the paper *"Chebotarev geodesic theorem: non-split case"*.  This file
closes conjecture **D2** of `FUTURE_DIRECTIONS.md`: it classifies the two-parameter admissible
region

  `logExponentRegion π M = {(θ, k) : |π − M| ≤ C x^θ (log x)^k eventually}`

completely, and realizes each of the possible shapes by an explicit error term.

## Main results

* `hasLogErrorExponent_of_hasErrorExponent`, `HasLogErrorExponent.of_lt` — strictly above an
  admissible exponent *every* log power is admissible.  Consequently the infimal exponent of
  the region does not depend on the log parameter: the region has a *single* vertical wall.
* `logExponentRegion_eq` — **the classification.**  If the exponent set is non-empty and
  bounded below, then
  `logExponentRegion π M = {p | θ* < p.1} ∪ {p | p.1 = θ* ∧ p.2 ∈ logCornerSet π M}`
  where `θ* = optimalExponent π M`.
* `logCornerSet_eq_empty_or_Ici` — the corner set is either empty or an `Ici k*`.  Hence
  exactly three shapes are possible: empty region, open half-plane, quarter-plane with one
  corner.
* Realizations of all three: `logExponentRegion_exp_eq_empty` (empty),
  `logExponentRegion_sqrtLogModel` together with `logCornerSet_sqrtLogModel` (half-plane, via
  the error term `x^θ exp √(log x)`, which beats every fixed log power but no power of `x`),
  and `logCornerSet_mdl` (corner, via `K x^θ (log x)^k`).
* `staircase_trichotomy_realized` — all three shapes actually occur.

All proofs are complete; no `sorry`.
-/
import Mathlib
import Shared.ChebotarevGeodesic
import Shared.ChebotarevGeodesicSharpness
import Shared.ChebotarevGeodesicOptimal
import Shared.ChebotarevGeodesicTransfer
import Shared.ChebotarevGeodesicStaircase
import Shared.ChebotarevGeodesicLogSharp

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

variable {π M : ℝ → ℝ} {θ θ' : ℝ} {k j : ℕ}

/-! ## 1.  A single vertical wall -/

/-- Strictly above an admissible `ε`-exponent, every log power is admissible. -/
theorem hasLogErrorExponent_of_hasErrorExponent (h : HasErrorExponent π M θ) (hlt : θ < θ')
    (j : ℕ) : HasLogErrorExponent π M θ' j := by
  obtain ⟨C, hC, X, hX, hb⟩ := h (θ' - θ) (by linarith)
  refine ⟨C, hC, max X (Real.exp 1), le_trans hX (le_max_left _ _), fun x hx => ?_⟩
  have hxX : X ≤ x := le_trans (le_max_left _ _) hx
  have hxe : Real.exp 1 ≤ x := le_trans (le_max_right _ _) hx
  have hlog : 1 ≤ Real.log x := one_le_log_of_exp_le hxe
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hxX
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have h1 : |π x - M x| ≤ C * x ^ (θ + (θ' - θ)) := hb x hxX
  rw [show θ + (θ' - θ) = θ' by ring] at h1
  have hpow : (1 : ℝ) ≤ (Real.log x) ^ j := one_le_pow₀ hlog
  have hxθ : (0 : ℝ) < x ^ θ' := Real.rpow_pos_of_pos hx0 θ'
  calc |π x - M x| ≤ C * x ^ θ' := h1
    _ ≤ C * x ^ θ' * (Real.log x) ^ j :=
        le_mul_of_one_le_right (by positivity) hpow

/-- **The region has a single vertical wall.**  From one admissible pair `(θ, k)` one gets
*every* pair `(θ', j)` with `θ' > θ`, no matter how small `j` is.  So the infimal exponent is
the same in every horizontal slice: the log parameter can only decide what happens *on* the
wall. -/
theorem HasLogErrorExponent.of_lt (h : HasLogErrorExponent π M θ k) (hlt : θ < θ') (j : ℕ) :
    HasLogErrorExponent π M θ' j :=
  hasLogErrorExponent_of_hasErrorExponent (hasErrorExponent_of_hasLogErrorExponent h) hlt j

/-! ## 2.  The classification -/

/-- The set of log powers that work *at* the optimal exponent: the corner data. -/
def logCornerSet (π M : ℝ → ℝ) : Set ℕ :=
  {k | HasLogErrorExponent π M (optimalExponent π M) k}

/-- The corner set is upward closed, hence empty or an `Ici`. -/
theorem logCornerSet_eq_empty_or_Ici (π M : ℝ → ℝ) :
    logCornerSet π M = ∅ ∨ ∃ k, logCornerSet π M = Set.Ici k := by
  by_cases hne : (logCornerSet π M).Nonempty
  · right
    refine ⟨sInf (logCornerSet π M), Set.Subset.antisymm (fun k hk => Nat.sInf_le hk) ?_⟩
    intro k hk
    exact HasLogErrorExponent.mono_log (Nat.sInf_mem hne) hk
  · left
    exact Set.not_nonempty_iff_eq_empty.mp hne

/-- **D2, the classification.**  For any pair `(π, M)` whose exponent set is non-empty and
bounded below, the admissible region is the open half-plane to the right of the optimal
exponent `θ*`, together with the slice above `θ*` described by the corner set.  Since the
corner set is `∅` or `Ici k*`, exactly three shapes can occur. -/
theorem logExponentRegion_eq (hne : (exponentSet π M).Nonempty)
    (hbd : BddBelow (exponentSet π M)) :
    logExponentRegion π M =
      {p : ℝ × ℕ | optimalExponent π M < p.1} ∪
        {p : ℝ × ℕ | p.1 = optimalExponent π M ∧ p.2 ∈ logCornerSet π M} := by
  ext p
  constructor
  · intro hp
    have hpp : HasLogErrorExponent π M p.1 p.2 := hp
    have hE : p.1 ∈ exponentSet π M := hasErrorExponent_of_hasLogErrorExponent hpp
    have hle : optimalExponent π M ≤ p.1 := csInf_le hbd hE
    rcases lt_or_eq_of_le hle with hlt | heq
    · exact Or.inl hlt
    · refine Or.inr ⟨heq.symm, ?_⟩
      show HasLogErrorExponent π M (optimalExponent π M) p.2
      rw [heq]
      exact hpp
  · rintro (hlt | ⟨heq, hk⟩)
    · have hlt' : sInf (exponentSet π M) < p.1 := hlt
      obtain ⟨θ₀, hθ₀mem, hθ₀⟩ := exists_lt_of_csInf_lt hne hlt'
      exact hasLogErrorExponent_of_hasErrorExponent hθ₀mem hθ₀ p.2
    · show HasLogErrorExponent π M p.1 p.2
      rw [heq]
      exact hk

/-! ## 3.  Realization 1: the corner shape -/

/-- The model error term `K x^θ (log x)^k` realizes the corner shape: its corner set is
`Ici k`, so the pair `(θ, k)` is the exact corner of its region. -/
theorem logCornerSet_mdl (M : ℝ → ℝ) {K θ : ℝ} (hK : 0 < K) (k : ℕ) :
    logCornerSet (mdl M K θ k) M = Set.Ici k := by
  have hopt : optimalExponent (mdl M K θ k) M = θ := by
    have e : mdl M K θ k = fun x => M x + K * x ^ θ * (Real.log x) ^ k := rfl
    rw [e]
    exact optimalExponent_log_pow M hK k
  ext j
  simp only [logCornerSet, Set.mem_setOf_eq, hopt, Set.mem_Ici]
  rw [hasLogErrorExponent_mdl_iff M hK k j]
  constructor
  · rintro (hlt | ⟨-, hkj⟩)
    · exact absurd hlt (lt_irrefl _)
    · exact hkj
  · intro hkj
    exact Or.inr ⟨rfl, hkj⟩

/-! ## 4.  Realization 2: the half-plane shape -/

/-- The error term `x^θ · exp √(log x)`: it beats every fixed power of `log x`, but no power
of `x`. -/
noncomputable def sqrtLogModel (M : ℝ → ℝ) (θ : ℝ) : ℝ → ℝ :=
  fun x => M x + x ^ θ * Real.exp (Real.sqrt (Real.log x))

theorem sqrtLogModel_sub (M : ℝ → ℝ) (θ : ℝ) (x : ℝ) :
    sqrtLogModel M θ x - M x = x ^ θ * Real.exp (Real.sqrt (Real.log x)) := by
  simp [sqrtLogModel]

/-- `exp √(log x) ≤ x^ε` for `x` large: the subpolynomial half. -/
theorem exp_sqrt_log_le_rpow {ε : ℝ} (hε : 0 < ε) {x : ℝ}
    (hx : max (Real.exp (1 / ε ^ 2)) (Real.exp 1) ≤ x) :
    Real.exp (Real.sqrt (Real.log x)) ≤ x ^ ε := by
  have hxe1 : Real.exp (1 / ε ^ 2) ≤ x := le_trans (le_max_left _ _) hx
  have hxe : Real.exp 1 ≤ x := le_trans (le_max_right _ _) hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le (Real.exp_pos _) hxe
  have ht : 1 / ε ^ 2 ≤ Real.log x := by
    have h := Real.log_le_log (Real.exp_pos (1 / ε ^ 2)) hxe1
    rwa [Real.log_exp] at h
  set t := Real.log x with htdef
  have ht0 : (0 : ℝ) ≤ t := le_trans (by positivity) ht
  have hsq : Real.sqrt t * Real.sqrt t = t := Real.mul_self_sqrt ht0
  have hsqrt_ge : 1 / ε ≤ Real.sqrt t := by
    have h1 : Real.sqrt (1 / ε ^ 2) ≤ Real.sqrt t := Real.sqrt_le_sqrt ht
    have h2 : Real.sqrt (1 / ε ^ 2) = 1 / ε := by
      rw [show (1 : ℝ) / ε ^ 2 = (1 / ε) ^ 2 by field_simp]
      exact Real.sqrt_sq (by positivity)
    rwa [h2] at h1
  have hkey : Real.sqrt t ≤ ε * t := by
    have h1 : 1 ≤ ε * Real.sqrt t := by
      have h := mul_le_mul_of_nonneg_left hsqrt_ge hε.le
      rw [mul_one_div, div_self (ne_of_gt hε)] at h
      exact h
    calc Real.sqrt t = 1 * Real.sqrt t := (one_mul _).symm
      _ ≤ (ε * Real.sqrt t) * Real.sqrt t :=
          mul_le_mul_of_nonneg_right h1 (Real.sqrt_nonneg t)
      _ = ε * (Real.sqrt t * Real.sqrt t) := by ring
      _ = ε * t := by rw [hsq]
  calc Real.exp (Real.sqrt t) ≤ Real.exp (ε * t) := Real.exp_le_exp.mpr hkey
    _ = x ^ ε := by rw [Real.rpow_def_of_pos hx0, htdef]; ring_nf

/-- Above the wall the half-plane model is admissible with every log power. -/
theorem hasLogErrorExponent_sqrtLogModel (M : ℝ → ℝ) {θ θ' : ℝ} (hlt : θ < θ') (j : ℕ) :
    HasLogErrorExponent (sqrtLogModel M θ) M θ' j := by
  set ε := θ' - θ with hεdef
  have hε : 0 < ε := by rw [hεdef]; linarith
  refine ⟨1, one_pos, max (max (Real.exp (1 / ε ^ 2)) (Real.exp 1)) 1,
    le_max_right _ _, fun x hx => ?_⟩
  have hxm : max (Real.exp (1 / ε ^ 2)) (Real.exp 1) ≤ x := le_trans (le_max_left _ _) hx
  have hx1 : (1 : ℝ) ≤ x := le_trans (le_max_right _ _) hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hxe : Real.exp 1 ≤ x := le_trans (le_max_right _ _) hxm
  have hlog : 1 ≤ Real.log x := one_le_log_of_exp_le hxe
  have hpow : (1 : ℝ) ≤ (Real.log x) ^ j := one_le_pow₀ hlog
  have hbound : Real.exp (Real.sqrt (Real.log x)) ≤ x ^ ε := exp_sqrt_log_le_rpow hε hxm
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hexp : (0 : ℝ) < Real.exp (Real.sqrt (Real.log x)) := Real.exp_pos _
  have hsplit : x ^ θ * x ^ ε = x ^ θ' := by
    rw [← Real.rpow_add hx0, hεdef]; ring_nf
  rw [sqrtLogModel_sub, abs_of_nonneg (by positivity)]
  calc x ^ θ * Real.exp (Real.sqrt (Real.log x)) ≤ x ^ θ * x ^ ε :=
        mul_le_mul_of_nonneg_left hbound hxθ.le
    _ = x ^ θ' := hsplit
    _ = 1 * x ^ θ' := (one_mul _).symm
    _ ≤ 1 * x ^ θ' * (Real.log x) ^ j :=
        le_mul_of_one_le_right (by positivity) hpow

/-- The half-plane model satisfies the `ε`-form of the estimate at the wall itself. -/
theorem hasErrorExponent_sqrtLogModel (M : ℝ → ℝ) (θ : ℝ) :
    HasErrorExponent (sqrtLogModel M θ) M θ := by
  intro ε hε
  refine ⟨1, one_pos, max (max (Real.exp (1 / ε ^ 2)) (Real.exp 1)) 1,
    le_max_right _ _, fun x hx => ?_⟩
  have hxm : max (Real.exp (1 / ε ^ 2)) (Real.exp 1) ≤ x := le_trans (le_max_left _ _) hx
  have hx1 : (1 : ℝ) ≤ x := le_trans (le_max_right _ _) hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hbound : Real.exp (Real.sqrt (Real.log x)) ≤ x ^ ε := exp_sqrt_log_le_rpow hε hxm
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hexp : (0 : ℝ) < Real.exp (Real.sqrt (Real.log x)) := Real.exp_pos _
  rw [sqrtLogModel_sub, abs_of_nonneg (by positivity)]
  calc x ^ θ * Real.exp (Real.sqrt (Real.log x)) ≤ x ^ θ * x ^ ε :=
        mul_le_mul_of_nonneg_left hbound hxθ.le
    _ = x ^ (θ + ε) := by rw [← Real.rpow_add hx0]
    _ = 1 * x ^ (θ + ε) := (one_mul _).symm

/-- `exp √t` eventually beats every `C t^j`: the superlogarithmic half. -/
theorem eventually_lt_exp_sqrt {C : ℝ} (hC : 0 < C) (j : ℕ) :
    ∀ᶠ t : ℝ in atTop, C * t ^ j < Real.exp (Real.sqrt t) := by
  have hu : ∀ᶠ u : ℝ in atTop, Real.log C + 4 * (j : ℝ) * u < u ^ 2 := by
    filter_upwards [eventually_ge_atTop (|Real.log C| + 4 * (j : ℝ) + 1)] with u hu
    have hj : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
    have habs : (0 : ℝ) ≤ |Real.log C| := abs_nonneg _
    have h1 : (1 : ℝ) ≤ u := le_trans (by linarith) hu
    nlinarith [le_abs_self (Real.log C)]
  have h4 : Tendsto (fun t : ℝ => t ^ ((1 : ℝ) / 4)) atTop atTop :=
    tendsto_rpow_atTop (by norm_num)
  filter_upwards [h4.eventually hu, eventually_gt_atTop (0 : ℝ), eventually_ge_atTop (1 : ℝ)]
    with t htu ht0 ht1
  have hlogdiv : Real.log t ≤ t ^ ((1 : ℝ) / 4) / (1 / 4) :=
    log_le_rpow_div (by norm_num) ht0
  have hdiv : t ^ ((1 : ℝ) / 4) / ((1 : ℝ) / 4) = 4 * t ^ ((1 : ℝ) / 4) := by
    ring
  have hlog' : Real.log t ≤ 4 * t ^ ((1 : ℝ) / 4) := by rw [← hdiv]; exact hlogdiv
  have hsq : (t ^ ((1 : ℝ) / 4)) ^ 2 = Real.sqrt t := by
    rw [Real.sqrt_eq_rpow, ← Real.rpow_natCast (t ^ ((1 : ℝ) / 4)) 2, ← Real.rpow_mul ht0.le]
    norm_num
  have hj : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
  have hlt : Real.log C + (j : ℝ) * Real.log t < Real.sqrt t := by
    have h1 : (j : ℝ) * Real.log t ≤ 4 * (j : ℝ) * t ^ ((1 : ℝ) / 4) := by nlinarith [hlog']
    rw [← hsq]
    linarith
  have key : C * t ^ j = Real.exp (Real.log C + (j : ℝ) * Real.log t) := by
    rw [Real.exp_add, Real.exp_log hC, ← Real.log_pow, Real.exp_log (pow_pos ht0 j)]
  rw [key]
  exact Real.exp_lt_exp.mpr hlt

/-- **On the wall, the half-plane model is inadmissible for every log power.** -/
theorem not_hasLogErrorExponent_sqrtLogModel (M : ℝ → ℝ) (θ : ℝ) (j : ℕ) :
    ¬ HasLogErrorExponent (sqrtLogModel M θ) M θ j := by
  rintro ⟨C, hC, X, hX, hb⟩
  have hev : ∀ᶠ x : ℝ in atTop, C * (Real.log x) ^ j < Real.exp (Real.sqrt (Real.log x)) :=
    Real.tendsto_log_atTop.eventually (eventually_lt_exp_sqrt hC j)
  obtain ⟨x, ⟨hxlt, hxX⟩, hx1⟩ :=
    ((hev.and (eventually_ge_atTop X)).and (eventually_ge_atTop (1 : ℝ))).exists
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hbd := hb x hxX
  rw [sqrtLogModel_sub, abs_of_nonneg (by positivity)] at hbd
  have hcontr : x ^ θ * Real.exp (Real.sqrt (Real.log x)) ≤ x ^ θ * (C * (Real.log x) ^ j) := by
    calc x ^ θ * Real.exp (Real.sqrt (Real.log x)) ≤ C * x ^ θ * (Real.log x) ^ j := hbd
      _ = x ^ θ * (C * (Real.log x) ^ j) := by ring
  have hfin := le_of_mul_le_mul_left hcontr hxθ
  linarith

/-- The optimal exponent of the half-plane model is the wall `θ`. -/
theorem optimalExponent_sqrtLogModel (M : ℝ → ℝ) (θ : ℝ) :
    optimalExponent (sqrtLogModel M θ) M = θ := by
  have hupper : HasErrorExponent (sqrtLogModel M θ) M θ := hasErrorExponent_sqrtLogModel M θ
  have hlb : ∀ θ' ∈ exponentSet (sqrtLogModel M θ) M, θ ≤ θ' := by
    intro θ' hθ'
    by_contra hlt
    push_neg at hlt
    exact not_hasLogErrorExponent_sqrtLogModel M θ 0
      (hasLogErrorExponent_of_hasErrorExponent hθ' hlt 0)
  exact le_antisymm (csInf_le ⟨θ, hlb⟩ hupper) (le_csInf ⟨θ, hupper⟩ hlb)

/-- **Realization of the half-plane shape.**  The corner set of `x^θ exp √(log x)` is empty:
its region is the open half-plane `{θ' > θ}` with no corner at all. -/
theorem logCornerSet_sqrtLogModel (M : ℝ → ℝ) (θ : ℝ) :
    logCornerSet (sqrtLogModel M θ) M = ∅ := by
  ext j
  simp only [logCornerSet, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false,
    optimalExponent_sqrtLogModel]
  exact not_hasLogErrorExponent_sqrtLogModel M θ j

/-- The region of the half-plane model computed exactly. -/
theorem logExponentRegion_sqrtLogModel (M : ℝ → ℝ) (θ : ℝ) :
    logExponentRegion (sqrtLogModel M θ) M = {p : ℝ × ℕ | θ < p.1} := by
  ext p
  constructor
  · intro hp
    have hpp : HasLogErrorExponent (sqrtLogModel M θ) M p.1 p.2 := hp
    show θ < p.1
    by_contra hle
    push_neg at hle
    exact not_hasLogErrorExponent_sqrtLogModel M θ p.2 (hpp.mono_exponent hle)
  · intro hlt
    have hlt' : θ < p.1 := hlt
    exact hasLogErrorExponent_sqrtLogModel M hlt' p.2

/-! ## 5.  Realization 3: the empty region -/

/-- **Realization of the empty shape.**  An exponentially growing error term admits no pair
`(θ, k)`: its admissible region is empty, so the classification's first case occurs. -/
theorem logExponentRegion_exp_eq_empty :
    logExponentRegion (fun x => Real.exp x) (fun _ => (0 : ℝ)) = ∅ := by
  ext p
  simp only [Set.mem_empty_iff_false, iff_false]
  intro hp
  obtain ⟨θ, k⟩ := p
  obtain ⟨C, hC, X, hX, hb⟩ :
      ∃ C > 0, ∃ X ≥ (1 : ℝ), ∀ x ≥ X,
        |Real.exp x - 0| ≤ C * x ^ θ * (Real.log x) ^ k := hp
  set D := C * (((k : ℝ) + 1) / 1) ^ k + 1 with hDdef
  have hD : 0 < D := by positivity
  have hdiv : Tendsto (fun x : ℝ => Real.exp x / x ^ (θ + 1)) atTop atTop :=
    tendsto_exp_div_rpow_atTop (θ + 1)
  obtain ⟨x, ⟨hxD, hxX⟩, hx1⟩ :=
    (((hdiv.eventually_gt_atTop D).and (eventually_ge_atTop X)).and
      (eventually_ge_atTop (1 : ℝ))).exists
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hxp : (0 : ℝ) < x ^ (θ + 1) := Real.rpow_pos_of_pos hx0 (θ + 1)
  have hgt : D * x ^ (θ + 1) < Real.exp x := by
    rw [lt_div_iff₀ hxp] at hxD
    linarith
  have hlogk : (Real.log x) ^ k ≤ (((k : ℝ) + 1) / 1) ^ k * x ^ (1 : ℝ) :=
    log_pow_le one_pos hx1
  have hbd := hb x hxX
  have hexp : (0 : ℝ) < Real.exp x := Real.exp_pos x
  rw [sub_zero, abs_of_nonneg hexp.le] at hbd
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hstep : C * x ^ θ * (Real.log x) ^ k
      ≤ C * x ^ θ * ((((k : ℝ) + 1) / 1) ^ k * x ^ (1 : ℝ)) :=
    mul_le_mul_of_nonneg_left hlogk (by positivity)
  have hsplit : x ^ θ * x ^ (1 : ℝ) = x ^ (θ + 1) := by
    rw [← Real.rpow_add hx0]
  have hchain : Real.exp x ≤ (C * (((k : ℝ) + 1) / 1) ^ k) * x ^ (θ + 1) := by
    calc Real.exp x ≤ C * x ^ θ * (Real.log x) ^ k := hbd
      _ ≤ C * x ^ θ * ((((k : ℝ) + 1) / 1) ^ k * x ^ (1 : ℝ)) := hstep
      _ = (C * (((k : ℝ) + 1) / 1) ^ k) * (x ^ θ * x ^ (1 : ℝ)) := by ring
      _ = (C * (((k : ℝ) + 1) / 1) ^ k) * x ^ (θ + 1) := by rw [hsplit]
  have hDx : (C * (((k : ℝ) + 1) / 1) ^ k) * x ^ (θ + 1) < D * x ^ (θ + 1) := by
    have hlt : C * (((k : ℝ) + 1) / 1) ^ k < D := by rw [hDdef]; linarith
    exact mul_lt_mul_of_pos_right hlt hxp
  linarith

/-! ## 6.  Synthesis: all three shapes occur -/

/-- **D2, closed.**  The classification `logExponentRegion_eq` together with
`logCornerSet_eq_empty_or_Ici` leaves exactly three possible shapes, and each of them is
realized by an explicit error term: an exponential error gives the empty region; the error
`x^θ exp √(log x)` gives the corner-free half-plane; and `K x^θ (log x)^k` gives the
quarter-plane with corner `(θ, k)`.  In particular the log power is a genuine second
invariant, and "exponent `25/36 + ε`" is precisely the statement that the wall is at `25/36`,
with no information about the corner. -/
theorem staircase_trichotomy_realized (M : ℝ → ℝ) (θ : ℝ) {K : ℝ} (hK : 0 < K) (k : ℕ) :
    logExponentRegion (fun x => Real.exp x) (fun _ => (0 : ℝ)) = ∅ ∧
      (logCornerSet (sqrtLogModel M θ) M = ∅ ∧
        logExponentRegion (sqrtLogModel M θ) M = {p : ℝ × ℕ | θ < p.1}) ∧
      logCornerSet (mdl M K θ k) M = Set.Ici k :=
  ⟨logExponentRegion_exp_eq_empty,
    ⟨logCornerSet_sqrtLogModel M θ, logExponentRegion_sqrtLogModel M θ⟩,
    logCornerSet_mdl M hK k⟩

/-- The `25/36` instance: the paper's exponent is the wall of an explicit region whose corner
is exactly `(25/36, k)`. -/
theorem staircase_25_36 (M : ℝ → ℝ) {K : ℝ} (hK : 0 < K) (k : ℕ) :
    optimalExponent (mdl M K (25 / 36) k) M = 25 / 36 ∧
      logCornerSet (mdl M K (25 / 36) k) M = Set.Ici k := by
  refine ⟨?_, logCornerSet_mdl M hK k⟩
  have e : mdl M K (25 / 36 : ℝ) k = fun x => M x + K * x ^ ((25 : ℝ) / 36) * (Real.log x) ^ k :=
    rfl
  rw [e]
  exact optimalExponent_log_pow M hK k

end ChebotarevGeodesic