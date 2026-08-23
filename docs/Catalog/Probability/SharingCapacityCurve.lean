import Probability.MultiFineTuneSharingPhase

/-!
# The serving-capacity curve `M*(k) = (1 + √(1 + 4k(k−1)β))/(2k)`

This file closes the *upper* half of Conjecture 5 of the previous cycle
(`FUTURE_DIRECTIONS.md`, "Serving-Capacity Law at Two Over One Minus Beta").

`MultiFineTuneSharingPhase.sharing_mean_quadratic` proves the quadratic constraint
`k M² ≤ M + (k−1)β` on the mean agreement `M` of one shared model with `k`
fine-tunes whose pairwise agreement is at most `β`.  A quadratic inequality is not
yet a number; here we solve it.  Writing

`capacityCurve k β = (1 + √(1 + 4k(k−1)β)) / (2k)`

for the positive root of `k x² − x − (k−1)β`, the results are:

* `meanAgree_le_capacityCurve` — the exact solution of the constraint:
  `M ≤ capacityCurve k β` for every shared model.  This is the whole content of
  the quadratic bound, in closed form.
* `capacityCurve_hub`, `hub_on_capacityCurve` — the curve is *attained*: at the
  threshold budget `β = 1 − 2/k` it equals `1 − 1/k = (1 + β)/2`, which the hub
  family of `MultiFineTuneSharingPhase.hub_attains_sharing_ceiling` realises
  exactly.  So the curve cannot be lowered at the threshold.
* `capacityCurve_le_ceiling_of_threshold`, `capacityCurve_lt_ceiling`,
  `ceiling_lt_capacityCurve` — the curve and the pairwise ceiling `(1+β)/2` cross
  **exactly** at `k(1 − β) = 2`: above the threshold the curve is the strictly
  better bound, below it the pairwise ceiling is.  The phase transition of the
  previous cycle is the crossing point of the two bounds, and each bound is the
  operative one on its own side.
* `sqrt_le_capacityCurve`, `capacityCurve_le_sqrt_add` — the sandwich
  `√β ≤ capacityCurve k β ≤ √β + 1/k`, whence `capacityCurve_tendsto_sqrt`: the
  capacity curve **converges to the geometric mean** `√β`.  The limit is exact,
  not merely an upper bound, so the asymptotic serving value is `√β`.
* `net54_twelve_finetunes_curve`, `net54_hundred_finetunes_curve` — the curve at
  the measured NET-54 cross-parent baseline `β = 0.8327`, sharpening the numeric
  bounds of the previous cycle.
-/

namespace Catalog.Probability.SharingCapacityCurve

open Finset Filter Topology
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.MultiFineTuneSharingPhase

variable {Ω Y : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq Y]
variable {k : ℕ}

/-! ### 1. The curve -/

/-- The **serving-capacity curve**: the positive root of `k x² − x − (k−1)β`, i.e. the
exact solution of the multiplicity constraint `k M² ≤ M + (k−1)β`. -/
noncomputable def capacityCurve (k : ℕ) (beta : ℝ) : ℝ :=
  (1 + Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta)) / (2 * (k : ℝ))

/-- The discriminant of the quadratic is at least `1` for `k ≥ 1` and `β ≥ 0`. -/
lemma one_le_disc (hk : 1 ≤ k) {beta : ℝ} (hb : 0 ≤ beta) :
    (1 : ℝ) ≤ 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have h1 : (0 : ℝ) ≤ 4 * (k : ℝ) := by linarith
  have h2 : (0 : ℝ) ≤ (k : ℝ) - 1 := by linarith
  have := mul_nonneg (mul_nonneg h1 h2) hb
  linarith

lemma disc_nonneg (hk : 1 ≤ k) {beta : ℝ} (hb : 0 ≤ beta) :
    (0 : ℝ) ≤ 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta :=
  le_trans zero_le_one (one_le_disc hk hb)

/-- A convenient form of `√x ≤ c`. -/
lemma sqrt_le_of_sq_le {x c : ℝ} (hc : 0 ≤ c) (h : x ≤ c ^ 2) : Real.sqrt x ≤ c := by
  rw [show c = Real.sqrt (c ^ 2) by rw [Real.sqrt_sq hc]]
  exact Real.sqrt_le_sqrt h

/-- A convenient form of `c ≤ √x`. -/
lemma le_sqrt_of_sq_le {x c : ℝ} (h : c ^ 2 ≤ x) : c ≤ Real.sqrt x := by
  by_cases hc : c ≤ 0
  · exact le_trans hc (Real.sqrt_nonneg x)
  · push_neg at hc
    rw [show c = Real.sqrt (c ^ 2) by rw [Real.sqrt_sq hc.le]]
    exact Real.sqrt_le_sqrt h

/-- `capacityCurve` is the positive root: it satisfies the quadratic exactly. -/
lemma capacityCurve_isRoot (hk : 1 ≤ k) {beta : ℝ} (hb : 0 ≤ beta) :
    (k : ℝ) * (capacityCurve k beta) ^ 2
      = capacityCurve k beta + ((k : ℝ) - 1) * beta := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  set s : ℝ := Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) with hsdef
  have hs2 : s ^ 2 = 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta :=
    Real.sq_sqrt (disc_nonneg hk hb)
  have hcurve : capacityCurve k beta = (1 + s) / (2 * (k : ℝ)) := rfl
  have hid : (k : ℝ) * ((1 + s) / (2 * (k : ℝ))) ^ 2
      - ((1 + s) / (2 * (k : ℝ)) + ((k : ℝ) - 1) * beta)
      = (s ^ 2 - (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta)) / (4 * (k : ℝ)) := by
    field_simp
    ring
  rw [hs2, sub_self, zero_div] at hid
  rw [hcurve]
  linarith [hid]

/-! ### 2. The curve solves the constraint -/

/-- **The exact solution of the multiplicity constraint.**  Any
real satisfying `k x² ≤ x + (k−1)β` is at most the positive root
`capacityCurve k β` (no sign hypothesis on `x` is needed: a negative `x` violates the
constraint outright). -/
theorem le_capacityCurve_of_quadratic (hk : 1 ≤ k) {beta x : ℝ} (hb : 0 ≤ beta)
    (hquad : (k : ℝ) * x ^ 2 ≤ x + ((k : ℝ) - 1) * beta) :
    x ≤ capacityCurve k beta := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  set s : ℝ := Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) with hsdef
  have hs0 : 0 ≤ s := Real.sqrt_nonneg _
  have hs2 : s ^ 2 = 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta :=
    Real.sq_sqrt (disc_nonneg hk hb)
  have hs1 : 1 ≤ s := by nlinarith [one_le_disc hk hb, hs2, hs0]
  have hcurve : capacityCurve k beta = (1 + s) / (2 * (k : ℝ)) := rfl
  set R : ℝ := (1 + s) / (2 * (k : ℝ)) with hR
  set R' : ℝ := (1 - s) / (2 * (k : ℝ)) with hR'
  have hfac : (k : ℝ) * (x - R) * (x - R')
      = (k : ℝ) * x ^ 2 - x + (1 - s ^ 2) / (4 * (k : ℝ)) := by
    rw [hR, hR']
    field_simp
    ring
  rw [hs2] at hfac
  have hsimp : (1 - (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta)) / (4 * (k : ℝ))
      = -(((k : ℝ) - 1) * beta) := by
    field_simp
    ring
  rw [hsimp] at hfac
  by_contra hcon
  push_neg at hcon
  rw [hcurve] at hcon
  have hxR : 0 < x - R := by linarith
  have hR'le : R' ≤ 0 := by
    rw [hR']
    apply div_nonpos_of_nonpos_of_nonneg (by linarith)
    positivity
  have hRpos : 0 < R := by
    rw [hR]
    exact div_pos (by linarith) (by positivity)
  have hxR' : 0 < x - R' := by linarith
  nlinarith [mul_pos (mul_pos hkpos hxR) hxR']

/-- **The capacity curve bounds every shared model.**  For `k ≥ 2` fine-tunes with
pairwise agreement at most `β`, the mean agreement of any single shared model is at
most `capacityCurve k β`. -/
theorem meanAgree_le_capacityCurve (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) :
    meanAgree H A ≤ capacityCurve k beta :=
  le_capacityCurve_of_quadratic (le_trans (by norm_num) hk)
    (beta_nonneg_of_pair hk A beta hpair)
    (sharing_mean_quadratic hN hk H A beta hpair)

/-! ### 3. The curve at the threshold: attainment by the hub family -/

/-- **The curve is attained.**  At the threshold budget `β = 1 − 2/k` the capacity
curve equals `1 − 1/k = (1 + β)/2`, the pairwise ceiling, which the explicit hub
family of `hub_attains_sharing_ceiling` realises exactly.  So the bound
`meanAgree_le_capacityCurve` is sharp for every `k ≥ 2`. -/
theorem capacityCurve_hub (hk : 2 ≤ k) :
    capacityCurve k (1 - 2 / (k : ℝ)) = 1 - 1 / (k : ℝ) := by
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have hval : 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * (1 - 2 / (k : ℝ)) = (2 * (k : ℝ) - 3) ^ 2 := by
    field_simp
    ring
  unfold capacityCurve
  rw [hval, Real.sqrt_sq (by linarith)]
  field_simp
  ring

/-- The hub family sits exactly on the capacity curve: its mean agreement equals
`capacityCurve k β` for its own pairwise budget `β = 1 − 2/k`. -/
theorem hub_on_capacityCurve (hk : 2 ≤ k) :
    ∃ (A : Fin k → (Fin k → Fin 2)) (H : Fin k → Fin 2) (beta : ℝ),
      beta = 1 - 2 / (k : ℝ) ∧
      (∀ i j, i ≠ j → agreeFrac (A i) (A j) = beta) ∧
      meanAgree H A = capacityCurve k beta := by
  obtain ⟨A, H, beta, hbeta, hp, hmean, _⟩ := hub_saturates_multiplicity_bound (k := k) hk
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  refine ⟨A, H, beta, hbeta, hp, ?_⟩
  rw [hmean, hbeta, capacityCurve_hub hk]
  field_simp
  ring

/-! ### 4. The curve versus the pairwise ceiling: the two bounds cross at the
threshold -/

/-- The algebraic identity behind the crossing: the difference of the squared
comparison is `k(1−β)·(k(1−β) − 2)`. -/
lemma crossing_identity (beta : ℝ) :
    ((k : ℝ) * (1 + beta) - 1) ^ 2 - (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta)
      = ((k : ℝ) * (1 - beta)) * (((k : ℝ) * (1 - beta)) - 2) := by
  ring

/-- Above the threshold `k(1 − β) ≥ 2` the capacity curve is at least as strong as the
pairwise ceiling. -/
theorem capacityCurve_le_ceiling_of_threshold (hk : 1 ≤ k) {beta : ℝ}
    (hb : 0 ≤ beta) (hthr : 2 ≤ (k : ℝ) * (1 - beta)) :
    capacityCurve k beta ≤ (1 + beta) / 2 := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have hc0 : (0 : ℝ) ≤ (k : ℝ) * (1 + beta) - 1 := by
    nlinarith [mul_nonneg hkpos.le hb]
  have hprod : (0 : ℝ) ≤ ((k : ℝ) * (1 - beta)) * (((k : ℝ) * (1 - beta)) - 2) :=
    mul_nonneg (by linarith) (by linarith)
  have hkey : Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) ≤ (k : ℝ) * (1 + beta) - 1 := by
    refine sqrt_le_of_sq_le hc0 ?_
    linarith [crossing_identity (k := k) beta]
  have hexp : (1 + beta) / 2 * (2 * (k : ℝ)) = (k : ℝ) * (1 + beta) := by ring
  unfold capacityCurve
  rw [div_le_iff₀ (by positivity), hexp]
  linarith

/-- Strictly above the threshold, the capacity curve is strictly below the pairwise
ceiling: this is the closed-form version of `sharing_strict_decay`. -/
theorem capacityCurve_lt_ceiling (hk : 1 ≤ k) {beta : ℝ}
    (hb : 0 ≤ beta) (hthr : 2 < (k : ℝ) * (1 - beta)) :
    capacityCurve k beta < (1 + beta) / 2 := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have hc0 : (0 : ℝ) ≤ (k : ℝ) * (1 + beta) - 1 := by
    nlinarith [mul_nonneg hkpos.le hb]
  have hprod : (0 : ℝ) < ((k : ℝ) * (1 - beta)) * (((k : ℝ) * (1 - beta)) - 2) :=
    mul_pos (by linarith) (by linarith)
  have hlt : 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta < ((k : ℝ) * (1 + beta) - 1) ^ 2 := by
    linarith [crossing_identity (k := k) beta]
  have hkey : Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) < (k : ℝ) * (1 + beta) - 1 := by
    have h1 : Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta)
        < Real.sqrt (((k : ℝ) * (1 + beta) - 1) ^ 2) :=
      Real.sqrt_lt_sqrt (disc_nonneg hk hb) hlt
    rwa [Real.sqrt_sq hc0] at h1
  have hexp : (1 + beta) / 2 * (2 * (k : ℝ)) = (k : ℝ) * (1 + beta) := by ring
  unfold capacityCurve
  rw [div_lt_iff₀ (by positivity), hexp]
  linarith

/-- Below the threshold the ordering reverses: the pairwise ceiling is the strictly
better bound.  Together with `capacityCurve_lt_ceiling` this shows the two bounds
cross exactly at `k(1 − β) = 2`. -/
theorem ceiling_lt_capacityCurve (hk : 1 ≤ k) {beta : ℝ}
    (hb : 0 ≤ beta) (hb1 : beta < 1) (hthr : (k : ℝ) * (1 - beta) < 2) :
    (1 + beta) / 2 < capacityCurve k beta := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have hc0 : (0 : ℝ) ≤ (k : ℝ) * (1 + beta) - 1 := by
    nlinarith [mul_nonneg hkpos.le hb]
  have hpos : (0 : ℝ) < (k : ℝ) * (1 - beta) := mul_pos hkpos (sub_pos.2 hb1)
  have hprod : ((k : ℝ) * (1 - beta)) * (((k : ℝ) * (1 - beta)) - 2) < 0 :=
    mul_neg_of_pos_of_neg hpos (by linarith)
  have hgt : ((k : ℝ) * (1 + beta) - 1) ^ 2 < 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta := by
    linarith [crossing_identity (k := k) beta]
  have hkey : (k : ℝ) * (1 + beta) - 1 < Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) := by
    have h1 : Real.sqrt (((k : ℝ) * (1 + beta) - 1) ^ 2)
        < Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) :=
      Real.sqrt_lt_sqrt (by positivity) hgt
    rwa [Real.sqrt_sq hc0] at h1
  have hexp : (1 + beta) / 2 * (2 * (k : ℝ)) = (k : ℝ) * (1 + beta) := by ring
  unfold capacityCurve
  rw [lt_div_iff₀ (by positivity), hexp]
  linarith

/-! ### 5. The sandwich by the geometric mean, and the limit -/

/-- Lower half of the sandwich: `√β ≤ capacityCurve k β` for `0 ≤ β ≤ 1`. -/
theorem sqrt_le_capacityCurve (hk : 1 ≤ k) {beta : ℝ} (hb : 0 ≤ beta) (hb1 : beta ≤ 1) :
    Real.sqrt beta ≤ capacityCurve k beta := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  set s : ℝ := Real.sqrt beta with hsdef
  have hs0 : 0 ≤ s := Real.sqrt_nonneg beta
  have hs2 : s ^ 2 = beta := Real.sq_sqrt hb
  have hs1 : s ≤ 1 := by nlinarith
  have hstep : (0 : ℝ) ≤ (k : ℝ) * s * (1 - s) :=
    mul_nonneg (mul_nonneg hkpos.le hs0) (by linarith)
  have hsq : (2 * (k : ℝ) * s - 1) ^ 2 ≤ 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta := by
    calc (2 * (k : ℝ) * s - 1) ^ 2 = 4 * (k : ℝ) ^ 2 * s ^ 2 - 4 * ((k : ℝ) * s) + 1 := by ring
      _ ≤ 4 * (k : ℝ) ^ 2 * s ^ 2 - 4 * ((k : ℝ) * s ^ 2) + 1 := by nlinarith [hstep]
      _ = 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * s ^ 2 := by ring
      _ = 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta := by rw [hs2]
  have hkey : 2 * (k : ℝ) * s - 1
      ≤ Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) :=
    le_sqrt_of_sq_le hsq
  have hexp : s * (2 * (k : ℝ)) = 2 * (k : ℝ) * s := by ring
  unfold capacityCurve
  rw [le_div_iff₀ (by positivity), hexp]
  linarith

/-- Upper half of the sandwich: `capacityCurve k β ≤ √β + 1/k`. -/
theorem capacityCurve_le_sqrt_add (hk : 1 ≤ k) {beta : ℝ} (hb : 0 ≤ beta) :
    capacityCurve k beta ≤ Real.sqrt beta + 1 / (k : ℝ) := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  set s : ℝ := Real.sqrt beta with hsdef
  have hs0 : 0 ≤ s := Real.sqrt_nonneg beta
  have hs2 : s ^ 2 = beta := Real.sq_sqrt hb
  have hstep : (0 : ℝ) ≤ (k : ℝ) * s := mul_nonneg hkpos.le hs0
  have hsq : 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta ≤ (2 * (k : ℝ) * s + 1) ^ 2 := by
    calc 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta
        = 1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * s ^ 2 := by rw [hs2]
      _ = 4 * (k : ℝ) ^ 2 * s ^ 2 - 4 * ((k : ℝ) * s ^ 2) + 1 := by ring
      _ ≤ 4 * (k : ℝ) ^ 2 * s ^ 2 + 4 * ((k : ℝ) * s) + 1 := by nlinarith [hstep, sq_nonneg s]
      _ = (2 * (k : ℝ) * s + 1) ^ 2 := by ring
  have hkey : Real.sqrt (1 + 4 * (k : ℝ) * ((k : ℝ) - 1) * beta) ≤ 2 * (k : ℝ) * s + 1 :=
    sqrt_le_of_sq_le (by positivity) hsq
  have hexp : (s + 1 / (k : ℝ)) * (2 * (k : ℝ)) = 2 * (k : ℝ) * s + 2 := by
    field_simp
  unfold capacityCurve
  rw [div_le_iff₀ (by positivity), hexp]
  linarith

/-- **The capacity curve converges to the geometric mean.**  As the number of served
fine-tunes grows, the best achievable mean agreement of a single shared model tends
to `√β` — not to the pairwise ceiling `(1 + β)/2`. -/
theorem capacityCurve_tendsto_sqrt {beta : ℝ} (hb : 0 ≤ beta) (hb1 : beta ≤ 1) :
    Tendsto (fun k : ℕ => capacityCurve k beta) atTop (𝓝 (Real.sqrt beta)) := by
  have hlow : ∀ᶠ k : ℕ in atTop, Real.sqrt beta ≤ capacityCurve k beta := by
    filter_upwards [eventually_ge_atTop 1] with k hk using sqrt_le_capacityCurve hk hb hb1
  have hhigh : ∀ᶠ k : ℕ in atTop, capacityCurve k beta ≤ Real.sqrt beta + 1 / (k : ℝ) := by
    filter_upwards [eventually_ge_atTop 1] with k hk using capacityCurve_le_sqrt_add hk hb
  have h0 : Tendsto (fun k : ℕ => 1 / (k : ℝ)) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hup : Tendsto (fun k : ℕ => Real.sqrt beta + 1 / (k : ℝ)) atTop (𝓝 (Real.sqrt beta)) := by
    simpa using (tendsto_const_nhds (x := Real.sqrt beta) (f := (atTop : Filter ℕ))).add h0
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hup hlow hhigh

/-! ### 6. The NET-54 numbers -/

section NET54

/-- At the measured cross-parent baseline `β = 0.8327`, twelve fine-tunes cannot be
served above `0.91634` — sharper than the previous cycle's `0.91635`, and obtained
from the exact root rather than from the threshold argument. -/
theorem net54_twelve_finetunes_curve (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin 12 → (Ω → Y))
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ 0.8327) :
    meanAgree H A ≤ 0.91634 := by
  have h := meanAgree_le_capacityCurve hN (by norm_num) H A 0.8327 hpair
  have hcurve : capacityCurve 12 (0.8327 : ℝ) ≤ 0.91634 := by
    have hD : 1 + 4 * ((12 : ℕ) : ℝ) * (((12 : ℕ) : ℝ) - 1) * (0.8327 : ℝ)
        = (440.6656 : ℝ) := by norm_num
    have hden : (0 : ℝ) < 2 * ((12 : ℕ) : ℝ) := by norm_num
    have hsq : Real.sqrt (440.6656 : ℝ) ≤ 20.99216 :=
      sqrt_le_of_sq_le (by norm_num) (by norm_num)
    unfold capacityCurve
    rw [hD, div_le_iff₀ hden]
    have : (0.91634 : ℝ) * (2 * ((12 : ℕ) : ℝ)) = 21.99216 := by norm_num
    rw [this]
    linarith
  linarith

/-- With a hundred fine-tunes the exact curve gives `0.91297`, below the previous
cycle's `0.913`. -/
theorem net54_hundred_finetunes_curve (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin 100 → (Ω → Y))
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ 0.8327) :
    meanAgree H A ≤ 0.91297 := by
  have h := meanAgree_le_capacityCurve hN (by norm_num) H A 0.8327 hpair
  have hcurve : capacityCurve 100 (0.8327 : ℝ) ≤ 0.91297 := by
    have hD : 1 + 4 * ((100 : ℕ) : ℝ) * (((100 : ℕ) : ℝ) - 1) * (0.8327 : ℝ)
        = (32975.92 : ℝ) := by norm_num
    have hden : (0 : ℝ) < 2 * ((100 : ℕ) : ℝ) := by norm_num
    have hsq : Real.sqrt (32975.92 : ℝ) ≤ 181.594 :=
      sqrt_le_of_sq_le (by norm_num) (by norm_num)
    unfold capacityCurve
    rw [hD, div_le_iff₀ hden]
    have : (0.91297 : ℝ) * (2 * ((100 : ℕ) : ℝ)) = 182.594 := by norm_num
    rw [this]
    linarith
  linarith

end NET54

end Catalog.Probability.SharingCapacityCurve