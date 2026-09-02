import Physics.SphericalCapPowerCeilingSharp

/-!
# Hölder ceilings and how many hypotheses fit inside the U84 cap

Third cycle of the spherical-cap analysis.  Cycle 1 proved the sample-size-free Lipschitz
ceiling, cycle 2 proved it sharp and identified the alignment window forced by the recorded
margin.  The adversarial question left open was: *is "Lipschitz" the right smoothness class,
or does the ceiling collapse for merely Hölder statistics, and how many mutually resolvable
hypotheses can a cap hold at all?*

## Main results

### 1. Hölder ceilings (Section 1)

* `IsHolderSphere`, `holder_gap_le` — an `(C, α)`-Hölder statistic on the sphere separates two
  predictors correlated at level `≥ 1 − ε` by at most `C·(√(2ε))^α`.  For `α = 1` this is the
  Lipschitz ceiling (`isHolderSphere_one_iff_isLipSphere`); for `α < 1` the ceiling *weakens*
  (the cap radius is `< 1`), quantifying exactly how much roughness buys.
* `holder_separating_needs_constant` — the converse: separating by `δ` needs
  `C ≥ δ/(√(2ε))^α`.
* `u84_holder_ceiling` — the U84 instance: `C·(√2/100)^α`.

### 2. Cap capacity: how many rungs fit (Section 2)

* `ladder_value_growth`, `cap_ladder_count_bound` — if a smooth statistic gains at least `δ`
  per rung of a ladder whose endpoints stay inside an `ε`-cap, then `k·δ ≤ L·√(2ε)`: the cap
  has a *capacity*, measured in resolvable rungs.
* `u84_at_most_one_resolvable_rung` — at U84 numbers (`δ = 0.008`, `ε = 10⁻⁴`, `L = 1`) the
  capacity is exactly one rung: no `1`-Lipschitz statistic can resolve two successive
  band-margin steps inside the recorded cap.  This is the structural reason the ladder reading
  `0.558` cannot be separated from the floor `0.55` by a smooth test.

## Lab notes (derived numerics)

```
Lipschitz ceiling (L = 1)      √2/100     = 0.0141421
per-rung gain at U84           δ = 0.008
capacity  ⌊√2/100 / 0.008⌋     = 1 rung
Hölder α = 1/2, C = 1 ceiling  (√2/100)^½ = 0.1189   (rougher statistics see more)
Hölder α = 1/2 needed constant δ/(√2/100)^½ = 0.0673
```
-/

open Finset
open Catalog.Algebra.ZeroFitDialU72Parity

namespace Catalog.Physics.SphericalCapPowerCeiling

variable {n : ℕ}

/-! ## 1. Hölder ceilings -/

/-- `F` is `(C, α)`-Hölder on the unit sphere. -/
def IsHolderSphere (C alpha : ℝ) (F : (Fin n → ℝ) → ℝ) : Prop :=
  ∀ x y : Fin n → ℝ, dot x x = 1 → dot y y = 1 →
    |F x - F y| ≤ C * nrm (fun i => x i - y i) ^ alpha

/-- Exponent `α = 1` recovers the Lipschitz class exactly. -/
theorem isHolderSphere_one_iff_isLipSphere {L : ℝ} {F : (Fin n → ℝ) → ℝ} :
    IsHolderSphere L 1 F ↔ IsLipSphere L F := by
  constructor <;> intro h x y hx hy <;> have := h x y hx hy <;>
    simpa [Real.rpow_one] using this

/-- **Hölder spherical-cap ceiling.**  A `(C, α)`-Hölder statistic separates two predictors
inside an `ε`-cap by at most `C·(√(2ε))^α`, again independently of the sample size. -/
theorem holder_gap_le {C alpha : ℝ} (hC : 0 ≤ C) (halpha : 0 ≤ alpha)
    {F : (Fin n → ℝ) → ℝ} (hF : IsHolderSphere C alpha F) {u v : Fin n → ℝ}
    (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) {eps : ℝ} (h : 1 - eps ≤ corr u v) :
    |F (nz u) - F (nz v)| ≤ C * Real.sqrt (2 * eps) ^ alpha := by
  have h1 : |F (nz u) - F (nz v)| ≤ C * chord u v ^ alpha :=
    hF (nz u) (nz v) (dot_nz_self u hu) (dot_nz_self v hv)
  have h2 : chord u v ^ alpha ≤ Real.sqrt (2 * eps) ^ alpha :=
    Real.rpow_le_rpow (chord_nonneg u v) (chord_le_sqrt_two_mul u v hu hv h) halpha
  exact le_trans h1 (mul_le_mul_of_nonneg_left h2 hC)

/-- **Converse Hölder bound.**  Separating the two hypotheses by `δ` inside an `ε`-cap forces
the Hölder constant `C ≥ δ/(√(2ε))^α`. -/
theorem holder_separating_needs_constant {C alpha : ℝ} (hC : 0 ≤ C) (halpha : 0 ≤ alpha)
    {F : (Fin n → ℝ) → ℝ} (hF : IsHolderSphere C alpha F) {u v : Fin n → ℝ}
    (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) {eps delta : ℝ} (heps : 0 < eps)
    (h : 1 - eps ≤ corr u v) (hsep : delta ≤ |F (nz u) - F (nz v)|) :
    delta / Real.sqrt (2 * eps) ^ alpha ≤ C := by
  have hpos : 0 < Real.sqrt (2 * eps) := Real.sqrt_pos.mpr (by linarith)
  have hrpos : 0 < Real.sqrt (2 * eps) ^ alpha := Real.rpow_pos_of_pos hpos alpha
  have hb := holder_gap_le hC halpha hF hu hv h
  rw [div_le_iff₀ hrpos]
  linarith

/-- The U84 instance of the Hölder ceiling. -/
theorem u84_holder_ceiling {C alpha : ℝ} (hC : 0 ≤ C) (halpha : 0 ≤ alpha) :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u w = 558 / 1000 ∧ corr v w = 55 / 100 ∧
      ∀ F : (Fin 2 → ℝ) → ℝ, IsHolderSphere C alpha F →
        |F (nz u) - F (nz v)| ≤ C * (Real.sqrt 2 / 100) ^ alpha := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  refine ⟨u, v, w, hu, hv, hw, huw, hvw, fun F hF => ?_⟩
  have h := holder_gap_le hC halpha hF hu hv (eps := 1 / 10000) (by linarith)
  rwa [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius] at h

/-! ## 2. Capacity of a cap: how many rungs a smooth statistic can resolve -/

/-- Along a ladder on which a statistic gains at least `δ` per step, the value grows at least
linearly. -/
theorem ladder_value_growth {F : (Fin n → ℝ) → ℝ} (f : ℕ → Fin n → ℝ) {delta : ℝ}
    (k : ℕ) (hstep : ∀ i, i < k → delta ≤ F (nz (f (i + 1))) - F (nz (f i))) :
    (k : ℝ) * delta ≤ F (nz (f k)) - F (nz (f 0)) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have hlast := hstep k (Nat.lt_succ_self k)
      have hprev := ih (fun i hi => hstep i (Nat.lt_succ_of_lt hi))
      push_cast
      linarith

/-- **Capacity of a correlation cap.**  If an `L`-Lipschitz statistic gains at least `δ` on
each of `k` successive rungs, and the two endpoints of the ladder are still correlated at
level `≥ 1 − ε`, then `k·δ ≤ L·√(2ε)`.  A cap of radius `√(2ε)` holds only
`⌊L√(2ε)/δ⌋` resolvable rungs, however many samples are taken. -/
theorem cap_ladder_count_bound {L delta eps : ℝ} (hL : 0 ≤ L) {F : (Fin n → ℝ) → ℝ}
    (hF : IsLipSphere L F) (f : ℕ → Fin n → ℝ) (hf : ∀ i, dot (f i) (f i) ≠ 0) (k : ℕ)
    (hstep : ∀ i, i < k → delta ≤ F (nz (f (i + 1))) - F (nz (f i)))
    (halign : 1 - eps ≤ corr (f 0) (f k)) :
    (k : ℝ) * delta ≤ L * Real.sqrt (2 * eps) := by
  have hgrow := ladder_value_growth f k hstep
  have hbound := sphere_lipschitz_gap_le hL hF (hf 0) (hf k) halign
  have habs : F (nz (f k)) - F (nz (f 0)) ≤ |F (nz (f 0)) - F (nz (f k))| := by
    rw [abs_sub_comm]
    exact le_abs_self _
  linarith

/-- **At U84 numbers a cap holds exactly one rung.**  With the recorded per-rung margin
`δ = 0.008`, the recorded alignment `0.9999` and a `1`-Lipschitz statistic, no ladder of two
or more resolvable steps fits inside the cap. -/
theorem u84_at_most_one_resolvable_rung {F : (Fin 2 → ℝ) → ℝ} (hF : IsLipSphere 1 F)
    (f : ℕ → Fin 2 → ℝ) (hf : ∀ i, dot (f i) (f i) ≠ 0) (k : ℕ)
    (hstep : ∀ i, i < k → (8 : ℝ) / 1000 ≤ F (nz (f (i + 1))) - F (nz (f i)))
    (halign : (9999 : ℝ) / 10000 ≤ corr (f 0) (f k)) :
    k ≤ 1 := by
  have h := cap_ladder_count_bound (eps := 1 / 10000) (by norm_num) hF f hf k hstep
    (by linarith)
  rw [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius,
    one_mul] at h
  have hs2 : Real.sqrt 2 < 1.415 := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  by_contra hk
  push_neg at hk
  have hk2 : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  nlinarith [h, hk2, hs2]

/-- **The capacity bound is attained: one rung really is resolvable.**  The correlation
statistic against the (normalised) response, which is `1`-Lipschitz on the sphere, gains
exactly the recorded margin `0.008` on the catalog configuration, whose two members are
aligned at `0.9999`.  Together with `u84_at_most_one_resolvable_rung` this pins the capacity
of the U84 cap at exactly one rung. -/
theorem u84_one_rung_is_resolvable :
    ∃ (F : (Fin 2 → ℝ) → ℝ) (f : ℕ → Fin 2 → ℝ), IsLipSphere 1 F ∧
      (∀ i, dot (f i) (f i) ≠ 0) ∧
      (∀ i, i < 1 → (8 : ℝ) / 1000 ≤ F (nz (f (i + 1))) - F (nz (f i))) ∧
      (9999 : ℝ) / 10000 ≤ corr (f 0) (f 1) := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  refine ⟨fun x => corr x (nz w), fun i => if i = 0 then v else u,
    corr_isLipSphere_one (nz w) (dot_nz_self w hw), ?_, ?_, ?_⟩
  · intro i
    by_cases hi : i = 0 <;> simp [hi, hu, hv]
  · intro i hi
    interval_cases i
    have hfu : corr (nz u) (nz w) = 558 / 1000 := by rw [corr_nz_nz u w hu hw, huw]
    have hfv : corr (nz v) (nz w) = 55 / 100 := by rw [corr_nz_nz v w hv hw, hvw]
    show (8 : ℝ) / 1000 ≤ corr (nz (if 0 + 1 = 0 then v else u)) (nz w)
        - corr (nz (if (0 : ℕ) = 0 then v else u)) (nz w)
    norm_num [hfu, hfv]
  · show (9999 : ℝ) / 10000 ≤ corr v u
    rw [corr_comm]
    exact huv

end Catalog.Physics.SphericalCapPowerCeiling