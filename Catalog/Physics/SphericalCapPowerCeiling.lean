import Novelty.TDialU84ApproachNotCrossed

/-!
# A spherical-cap power ceiling for near-threshold correlation tests

## Research context

The U84 rung of the `T`-dial ladder (`Novelty.TDialU84ApproachNotCrossed`) records a pooled
Spearman reading `0.558` against a pre-registered band floor `0.55`.  The recorded verdict is
*approaching, not crossed*, and the bootstrap CI straddles the floor.  The catalog theorem
`crossing_states_indistinguishable` shows that the two competing hypotheses — "the dial reads
`0.558`" and "the dial sits exactly on the floor `0.55`" — are realised by predictor vectors
`u`, `v` whose *mutual* correlation is at least `0.9999`.  The whole hypothesis test therefore
lives inside a spherical cap of chordal radius `√(2 − 2·0.9999) = √2/100 ≈ 0.01414`, i.e. an
angular radius below `0.9°`.

This file turns that observation into a quantitative **power ceiling**.

## Main results

### 1. Chordal geometry (Section 2)

* `chord_sq_eq` — for nonzero `u, v` the squared chordal distance between the normalised
  directions is exactly `2 − 2·corr u v`.
* `chord_eq_sqrt`, `chord_le_sqrt_two_mul` — the chordal-distance bound `√(2 − 2c) ≤ √(2ε)`
  whenever `corr u v ≥ 1 − ε`.
* `arccos_le_pi_div_two_mul_chord` — the *angular* form: `arccos c ≤ (π/2)·√(2 − 2c)`, proved
  from the Jordan inequality `2x/π ≤ sin x`.
* `u84_cap_angular_radius_lt_point_nine_degrees` — the recorded alignment `0.9999` corresponds
  to an angular radius strictly below `0.9°` (`= π/200` radians).

### 2. The Lipschitz ceiling (Section 3)

* `lipschitz_gap_le_chord`, `lipschitz_gap_le` — any functional `F` that is `L`-Lipschitz for
  the Euclidean metric on directions satisfies `|F(û) − F(v̂)| ≤ L·√(2ε)`.  **No sample size
  appears**: the dimension `n` is arbitrary and the bound does not involve it.
* `separating_test_needs_large_lipschitz` — contrapositive: a statistic separating the two
  hypotheses by `δ` must have Lipschitz constant `L ≥ δ/√(2ε)`.

### 3. Replication does not help (Section 4)

* `corr_rep` — replicating each coordinate vector `m` times leaves *all* correlations
  unchanged; `chord_rep` says the same for the chordal distance.
* `replication_does_not_help` — the ceiling for the `m`-fold replicated configuration, in
  dimension `2m`, is the identical constant `L·√2/100`.  Increasing the sample size cannot
  buy resolution for a smooth statistic.

### 4. The U84 ceiling and its sharpness (Sections 5–6)

* `u84_smooth_power_ceiling` — there is a configuration realising the two U84 readings on
  which every `L`-Lipschitz test statistic has separation at most `L·√2/100 < L/70`.
* `u84_separating_test_needs_lipschitz_ge_70` — a test with full separation `1` needs
  `L ≥ 70`.
* `u84_threshold_statistic_separates` — the *discontinuous* rank/threshold statistic
  `capIndicator w (0.554)` separates the very same configuration by the maximal amount `1`.
* `capIndicator_not_lipschitz` — and it is not `L`-Lipschitz for *any* `L`: the ceiling is
  escaped only by giving up continuity.

## Lab notes (derived numerics; see `ComputationalEvidence.md`)

```
alignment                 corr u v ≥ 0.9999      (catalog: crossing_states_indistinguishable)
chordal cap radius        √(2·10⁻⁴) = √2/100 = 0.01414213...
angular cap radius        arccos(0.9999) = 0.01414235... rad = 0.81027°   (< 0.9° = π/200)
readings to separate      0.558 vs 0.550, gap 0.008
ceiling for L = 1         0.01414  (dimension-free, replication-free)
Lipschitz needed for δ=1  ≥ 100/√2 = 70.71
threshold statistic       t = 0.554 separates by 1, Lipschitz constant +∞
```
-/

open Finset
open Catalog.Algebra.ZeroFitDialU72Parity

namespace Catalog.Physics.SphericalCapPowerCeiling

variable {n : ℕ}

/-! ## 1. Normalised directions -/

/-- The normalised direction of a coordinate vector (the zero vector is sent to itself). -/
noncomputable def nz (u : Fin n → ℝ) : Fin n → ℝ := fun i => u i / nrm u

lemma dot_nz_nz (u v : Fin n → ℝ) : dot (nz u) (nz v) = corr u v := by
  simp only [dot, nz, corr, div_mul_div_comm, ← Finset.sum_div]

lemma dot_nz_self (u : Fin n → ℝ) (hu : dot u u ≠ 0) : dot (nz u) (nz u) = 1 := by
  rw [dot_nz_nz, corr]
  have h : nrm u * nrm u = dot u u := by
    rw [← nrm_sq u]; ring
  rw [h, div_self hu]

lemma nrm_nz (u : Fin n → ℝ) (hu : dot u u ≠ 0) : nrm (nz u) = 1 := by
  rw [nrm, dot_nz_self u hu, Real.sqrt_one]

/-- Normalising does not change a correlation: `corr` is invariant under positive rescaling. -/
lemma corr_nz_left (u w : Fin n → ℝ) (hu : dot u u ≠ 0) : corr (nz u) w = corr u w := by
  have hpos : 0 < nrm u := nrm_pos hu
  have hdot : dot (nz u) w = dot u w / nrm u := by
    simp only [dot, nz, div_mul_eq_mul_div, ← Finset.sum_div]
  rw [corr, corr, hdot, nrm_nz u hu, one_mul]
  field_simp

/-! ## 2. Chordal geometry of a correlation cap -/

/-- The chordal (Euclidean) distance between the normalised directions of `u` and `v`. -/
noncomputable def chord (u v : Fin n → ℝ) : ℝ := nrm (fun i => nz u i - nz v i)

lemma chord_nonneg (u v : Fin n → ℝ) : 0 ≤ chord u v := Real.sqrt_nonneg _

/-- **Chordal identity.**  `‖û − v̂‖² = 2 − 2·corr u v`. -/
theorem chord_sq_eq (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) :
    chord u v ^ 2 = 2 - 2 * corr u v := by
  rw [chord, nrm_sq]
  have hexp : dot (fun i => nz u i - nz v i) (fun i => nz u i - nz v i)
      = dot (nz u) (nz u) - 2 * dot (nz u) (nz v) + dot (nz v) (nz v) := by
    simp only [dot, Finset.mul_sum, ← Finset.sum_sub_distrib,
      ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl (fun i _ => by ring)
  rw [hexp, dot_nz_self u hu, dot_nz_self v hv, dot_nz_nz]
  ring

/-- **Chordal distance formula.**  `‖û − v̂‖ = √(2 − 2c)` with `c = corr u v`. -/
theorem chord_eq_sqrt (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) :
    chord u v = Real.sqrt (2 - 2 * corr u v) := by
  have h := chord_sq_eq u v hu hv
  rw [← h, Real.sqrt_sq (chord_nonneg u v)]

/-- **The cap bound.**  Correlation at least `1 − ε` means chordal distance at most `√(2ε)`. -/
theorem chord_le_sqrt_two_mul (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    {eps : ℝ} (h : 1 - eps ≤ corr u v) :
    chord u v ≤ Real.sqrt (2 * eps) := by
  rw [chord_eq_sqrt u v hu hv]
  exact Real.sqrt_le_sqrt (by linarith)

/-- **Angular form of the cap bound** (Jordan's inequality).  The angle `arccos c` between two
unit vectors is at most `π/2` times their chordal distance `√(2 − 2c)`. -/
theorem arccos_le_pi_div_two_mul_chord {c : ℝ} (hc1 : -1 ≤ c) (hc2 : c ≤ 1) :
    Real.arccos c ≤ Real.pi / 2 * Real.sqrt (2 - 2 * c) := by
  set t : ℝ := Real.arccos c with ht
  have ht0 : 0 ≤ t := Real.arccos_nonneg c
  have htpi : t ≤ Real.pi := Real.arccos_le_pi c
  have hcos : Real.cos t = c := Real.cos_arccos hc1 hc2
  have hhalf : Real.cos t = 1 - 2 * Real.sin (t / 2) ^ 2 := by
    have h2 : Real.sin (t / 2) ^ 2 + Real.cos (t / 2) ^ 2 = 1 := Real.sin_sq_add_cos_sq _
    have h3 : Real.cos (2 * (t / 2)) = 2 * Real.cos (t / 2) ^ 2 - 1 :=
      Real.cos_two_mul (t / 2)
    rw [show (2 : ℝ) * (t / 2) = t by ring] at h3
    nlinarith [h2, h3]
  have hsin_nonneg : 0 ≤ Real.sin (t / 2) :=
    Real.sin_nonneg_of_nonneg_of_le_pi (by linarith) (by linarith [Real.pi_pos])
  have hsqrt : Real.sqrt (2 - 2 * c) = 2 * Real.sin (t / 2) := by
    have harg : 2 - 2 * c = (2 * Real.sin (t / 2)) ^ 2 := by
      rw [← hcos, hhalf]; ring
    rw [harg, Real.sqrt_sq (by positivity)]
  rw [hsqrt]
  have hjordan : 2 / Real.pi * (t / 2) ≤ Real.sin (t / 2) :=
    Real.mul_le_sin (by linarith) (by linarith)
  have hpi : 0 < Real.pi := Real.pi_pos
  have : t ≤ Real.pi * Real.sin (t / 2) := by
    have := mul_le_mul_of_nonneg_left hjordan (le_of_lt hpi)
    calc t = Real.pi * (2 / Real.pi * (t / 2)) := by field_simp
      _ ≤ Real.pi * Real.sin (t / 2) := this
  linarith

/-! ## 3. The Lipschitz power ceiling -/

/-- `F` is `L`-Lipschitz on coordinate vectors for the Euclidean metric. -/
def IsLip (L : ℝ) (F : (Fin n → ℝ) → ℝ) : Prop :=
  ∀ x y : Fin n → ℝ, |F x - F y| ≤ L * nrm (fun i => x i - y i)

/-- Any `L`-Lipschitz statistic separates two directions by at most `L` times their chordal
distance. -/
theorem lipschitz_gap_le_chord {L : ℝ} {F : (Fin n → ℝ) → ℝ} (hF : IsLip L F)
    (u v : Fin n → ℝ) : |F (nz u) - F (nz v)| ≤ L * chord u v :=
  hF (nz u) (nz v)

/-- **Spherical-cap power ceiling.**  If two predictor directions correlate at level `≥ 1 − ε`
then every `L`-Lipschitz test statistic assigns them values within `L·√(2ε)`.  The bound is
free of the ambient dimension `n`, i.e. of the sample size. -/
theorem lipschitz_gap_le {L : ℝ} (hL : 0 ≤ L) {F : (Fin n → ℝ) → ℝ} (hF : IsLip L F)
    {u v : Fin n → ℝ} (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) {eps : ℝ}
    (h : 1 - eps ≤ corr u v) :
    |F (nz u) - F (nz v)| ≤ L * Real.sqrt (2 * eps) :=
  le_trans (lipschitz_gap_le_chord hF u v)
    (mul_le_mul_of_nonneg_left (chord_le_sqrt_two_mul u v hu hv h) hL)

/-- **Converse form.**  A statistic that separates the two hypotheses by `δ > 0` inside an
`ε`-cap must have Lipschitz constant at least `δ/√(2ε)`. -/
theorem separating_test_needs_large_lipschitz {L : ℝ} (hL : 0 ≤ L) {F : (Fin n → ℝ) → ℝ}
    (hF : IsLip L F) {u v : Fin n → ℝ} (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    {eps delta : ℝ} (heps : 0 < eps) (h : 1 - eps ≤ corr u v)
    (hsep : delta ≤ |F (nz u) - F (nz v)|) :
    delta / Real.sqrt (2 * eps) ≤ L := by
  have hpos : 0 < Real.sqrt (2 * eps) := Real.sqrt_pos.mpr (by linarith)
  have hb := lipschitz_gap_le hL hF hu hv h
  rw [div_le_iff₀ hpos]
  linarith

/-! ## 4. Replication leaves the cap invariant -/

/-- `rep m u` repeats the coordinate vector `u` `m` times, the model of `m` independent
replications of the same experiment. -/
def rep (m : ℕ) (u : Fin n → ℝ) : Fin (m * n) → ℝ :=
  fun k => u (finProdFinEquiv.symm k).2

lemma dot_rep (m : ℕ) (u v : Fin n → ℝ) : dot (rep m u) (rep m v) = m * dot u v := by
  have h : dot (rep m u) (rep m v) = ∑ p : Fin m × Fin n, u p.2 * v p.2 := by
    rw [dot]
    rw [← Equiv.sum_comp finProdFinEquiv (fun k => rep m u k * rep m v k)]
    refine Finset.sum_congr rfl (fun p _ => by simp [rep])
  rw [h, Fintype.sum_prod_type]
  simp [dot, Finset.sum_const, nsmul_eq_mul]

lemma nrm_rep (m : ℕ) (u : Fin n → ℝ) : nrm (rep m u) = Real.sqrt m * nrm u := by
  rw [nrm, nrm, dot_rep, Real.sqrt_mul (by positivity)]

/-- **Replication invariance of correlation.**  Repeating both vectors `m ≥ 1` times changes
neither their correlation nor, hence, the cap they live in. -/
theorem corr_rep {m : ℕ} (hm : 0 < m) (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) :
    corr (rep m u) (rep m v) = corr u v := by
  have hmr : (0 : ℝ) < m := by exact_mod_cast hm
  have hsq : Real.sqrt m * Real.sqrt m = (m : ℝ) := Real.mul_self_sqrt (le_of_lt hmr)
  have hnu : 0 < nrm u := nrm_pos hu
  have hnv : 0 < nrm v := nrm_pos hv
  rw [corr, corr, dot_rep, nrm_rep, nrm_rep]
  rw [show Real.sqrt m * nrm u * (Real.sqrt m * nrm v)
      = (Real.sqrt m * Real.sqrt m) * (nrm u * nrm v) by ring, hsq]
  rw [mul_div_mul_left _ _ (ne_of_gt hmr)]

lemma dot_rep_self_ne_zero {m : ℕ} (hm : 0 < m) (u : Fin n → ℝ) (hu : dot u u ≠ 0) :
    dot (rep m u) (rep m u) ≠ 0 := by
  have hmr : (0 : ℝ) < m := by exact_mod_cast hm
  have hpos : 0 < dot u u := lt_of_le_of_ne (dot_self_nonneg u) (Ne.symm hu)
  rw [dot_rep]
  positivity

/-- The chordal distance is replication-invariant as well. -/
theorem chord_rep {m : ℕ} (hm : 0 < m) (u v : Fin n → ℝ) (hu : dot u u ≠ 0)
    (hv : dot v v ≠ 0) : chord (rep m u) (rep m v) = chord u v := by
  rw [chord_eq_sqrt _ _ (dot_rep_self_ne_zero hm u hu) (dot_rep_self_ne_zero hm v hv),
    chord_eq_sqrt u v hu hv, corr_rep hm u v hu hv]

/-! ## 5. The U84 configuration and its power ceiling -/

/-- The recorded alignment level: `corr ≥ 1 − 10⁻⁴` between a crossed and an uncrossed
predictor. -/
noncomputable def u84Eps : ℝ := 1 / 10000

/-- The chordal radius of the U84 cap, `√(2·10⁻⁴) = √2/100`. -/
theorem u84_cap_radius : Real.sqrt (2 * u84Eps) = Real.sqrt 2 / 100 := by
  have hsq : (Real.sqrt 2 / 100) ^ 2 = 2 * u84Eps := by
    rw [div_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), u84Eps]
    norm_num
  rw [← hsq, Real.sqrt_sq (by positivity)]

/-- **The U84 cap has angular radius below `0.9°`.**  `0.9° = π/200` radians. -/
theorem u84_cap_angular_radius_lt_point_nine_degrees :
    Real.arccos (9999 / 10000) < Real.pi / 200 := by
  have hpi3 : (3 : ℝ) < Real.pi := Real.pi_gt_three
  have hpi4 : Real.pi ≤ 4 := Real.pi_le_four
  set x : ℝ := Real.pi / 400 with hx
  have hx0 : 0 < x := by rw [hx]; linarith
  have hxlb : (3 : ℝ) / 400 < x := by rw [hx]; linarith
  have hxub : x ≤ 1 / 100 := by rw [hx]; linarith
  have hx1 : x ≤ 1 := by linarith
  have hsin : x - x ^ 3 / 4 < Real.sin x := Real.sin_gt_sub_cube hx0 hx1
  have hcube : x ^ 3 ≤ 1 / 1000000 := by nlinarith [hx0, hxub, mul_pos hx0 hx0]
  have hs : (74 : ℝ) / 10000 < Real.sin x := by linarith [hsin, hxlb, hcube]
  have hcos2 : Real.cos (2 * x) = 1 - 2 * Real.sin x ^ 2 := by
    have h2 : Real.sin x ^ 2 + Real.cos x ^ 2 = 1 := Real.sin_sq_add_cos_sq x
    have h3 := Real.cos_two_mul x
    nlinarith [h2, h3]
  have h2x : 2 * x = Real.pi / 200 := by rw [hx]; ring
  have hcoslt : Real.cos (Real.pi / 200) < 9999 / 10000 := by
    rw [← h2x, hcos2]; nlinarith [hs]
  have hmem1 : Real.cos (Real.pi / 200) ∈ Set.Icc (-1 : ℝ) 1 :=
    ⟨Real.neg_one_le_cos _, Real.cos_le_one _⟩
  have hmem2 : (9999 / 10000 : ℝ) ∈ Set.Icc (-1 : ℝ) 1 := by
    constructor <;> norm_num
  have hlt := Real.strictAntiOn_arccos hmem1 hmem2 hcoslt
  rwa [Real.arccos_cos (by linarith [Real.pi_pos]) (by linarith [Real.pi_pos])] at hlt

/-- **The U84 spherical-cap power ceiling.**  There is a configuration of predictors realising
the crossed reading `0.55` and the uncrossed reading `0.558` against a common response, whose
mutual correlation is `≥ 0.9999`, and on which *every* `L`-Lipschitz test statistic — in any
dimension, for any number of replications — separates the two hypotheses by at most
`L·√2/100 < L/70`. -/
theorem u84_smooth_power_ceiling :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u w = 558 / 1000 ∧ corr v w = 55 / 100 ∧ (9999 : ℝ) / 10000 ≤ corr u v ∧
      ∀ (L : ℝ) (F : (Fin 2 → ℝ) → ℝ), 0 ≤ L → IsLip L F →
        |F (nz u) - F (nz v)| ≤ L * (Real.sqrt 2 / 100) := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  refine ⟨u, v, w, hu, hv, hw, huw, hvw, huv, ?_⟩
  intro L F hL hF
  have h := lipschitz_gap_le hL hF hu hv (eps := 1 / 10000) (by linarith)
  rwa [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius] at h

/-- **Replication cannot break the ceiling.**  For every number `m ≥ 1` of replications the
`m`-fold replicated configuration lives in dimension `2m`, realises the same two readings,
and obeys the *identical* ceiling `L·√2/100`. -/
theorem replication_does_not_help (m : ℕ) (hm : 0 < m) :
    ∃ u v : Fin (m * 2) → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧
      (9999 : ℝ) / 10000 ≤ corr u v ∧
      ∀ (L : ℝ) (F : (Fin (m * 2) → ℝ) → ℝ), 0 ≤ L → IsLip L F →
        |F (nz u) - F (nz v)| ≤ L * (Real.sqrt 2 / 100) := by
  obtain ⟨u, v, w, hu, hv, _, _, _, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  have hru := dot_rep_self_ne_zero hm u hu
  have hrv := dot_rep_self_ne_zero hm v hv
  have hcorr : corr (rep m u) (rep m v) = corr u v := corr_rep hm u v hu hv
  refine ⟨rep m u, rep m v, hru, hrv, by rw [hcorr]; exact huv, ?_⟩
  intro L F hL hF
  have h := lipschitz_gap_le hL hF hru hrv (eps := 1 / 10000) (by rw [hcorr]; linarith)
  rwa [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius] at h

/-- A statistic achieving full separation `1` on the U84 cap must be at least `70`-Lipschitz. -/
theorem u84_separating_test_needs_lipschitz_ge_70 {u v : Fin 2 → ℝ} (hu : dot u u ≠ 0)
    (hv : dot v v ≠ 0) (huv : (9999 : ℝ) / 10000 ≤ corr u v) {L : ℝ} (hL : 0 ≤ L)
    {F : (Fin 2 → ℝ) → ℝ} (hF : IsLip L F) (hsep : 1 ≤ |F (nz u) - F (nz v)|) :
    70 ≤ L := by
  have h := separating_test_needs_large_lipschitz hL hF hu hv (eps := 1 / 10000) (delta := 1)
    (by norm_num) (by linarith) hsep
  rw [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius] at h
  have hs2 : Real.sqrt 2 < 1.415 := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  have hpos : 0 < Real.sqrt 2 / 100 := by positivity
  have h70 : (70 : ℝ) ≤ 1 / (Real.sqrt 2 / 100) := by
    rw [le_div_iff₀ hpos]; nlinarith [hs2]
  linarith

/-! ## 6. Escaping the ceiling: a discontinuous statistic -/

open Classical in
/-- The rank/threshold statistic: reject when the correlation with the response `w` reaches
the threshold `t`.  This is the prototype of a discontinuous (rank-based) test. -/
noncomputable def capIndicator (w : Fin n → ℝ) (t : ℝ) : (Fin n → ℝ) → ℝ :=
  fun x => if t ≤ corr x w then 1 else 0

/-- **A discontinuous statistic attains full separation on the very same cap.** -/
theorem u84_threshold_statistic_separates :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      (9999 : ℝ) / 10000 ≤ corr u v ∧
      capIndicator w (554 / 1000) (nz u) - capIndicator w (554 / 1000) (nz v) = 1 := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  refine ⟨u, v, w, hu, hv, hw, huv, ?_⟩
  have h1 : corr (nz u) w = 558 / 1000 := by rw [corr_nz_left u w hu, huw]
  have h2 : corr (nz v) w = 55 / 100 := by rw [corr_nz_left v w hv, hvw]
  simp only [capIndicator, h1, h2]
  rw [if_pos (by norm_num : (554 : ℝ) / 1000 ≤ 558 / 1000),
    if_neg (by norm_num : ¬ (554 : ℝ) / 1000 ≤ 55 / 100)]
  norm_num

/-- **The threshold statistic is not Lipschitz for any constant.**  Hence the ceiling of
`lipschitz_gap_le` is escaped exactly by abandoning continuity. -/
theorem capIndicator_not_lipschitz (L : ℝ) :
    ¬ IsLip L (capIndicator (![1, 0] : Fin 2 → ℝ) (554 / 1000)) := by
  intro hF
  obtain ⟨t, ht⟩ : ∃ t : ℝ, t = (554 : ℝ) / 1000 := ⟨_, rfl⟩
  obtain ⟨w, hw⟩ : ∃ w : Fin 2 → ℝ, w = ![1, 0] := ⟨_, rfl⟩
  rw [← ht, ← hw] at hF
  have ht0 : 0 < t := by rw [ht]; norm_num
  have ht1 : t < 1 := by rw [ht]; norm_num
  obtain ⟨s, hsdef⟩ : ∃ s : ℝ, s = Real.sqrt (1 - t ^ 2) := ⟨_, rfl⟩
  have hs2 : s ^ 2 = 1 - t ^ 2 := by rw [hsdef]; exact Real.sq_sqrt (by nlinarith)
  obtain ⟨d, hd⟩ : ∃ d : ℝ, d = min (t / 2) (1 / (2 * (|L| + 1))) := ⟨_, rfl⟩
  have hd0 : 0 < d := by rw [hd]; exact lt_min (by linarith) (by positivity)
  have hdt : d ≤ t / 2 := by rw [hd]; exact min_le_left _ _
  have hdL : d ≤ 1 / (2 * (|L| + 1)) := by rw [hd]; exact min_le_right _ _
  obtain ⟨x, hxdef⟩ : ∃ x : Fin 2 → ℝ, x = ![t, s] := ⟨_, rfl⟩
  obtain ⟨y, hydef⟩ : ∃ y : Fin 2 → ℝ, y = ![t - d, s] := ⟨_, rfl⟩
  have hww : dot w w = 1 := by simp [dot, Fin.sum_univ_two, hw]
  have hnw : nrm w = 1 := by rw [nrm, hww, Real.sqrt_one]
  have hxx : dot x x = 1 := by
    simp only [dot, Fin.sum_univ_two, hxdef, Matrix.cons_val_zero, Matrix.cons_val_one]
    nlinarith [hs2]
  have hnx : nrm x = 1 := by rw [nrm, hxx, Real.sqrt_one]
  have hxw : dot x w = t := by simp [dot, Fin.sum_univ_two, hxdef, hw]
  have hcx : corr x w = t := by rw [corr, hxw, hnx, hnw]; norm_num
  have hyy : dot y y = 1 - 2 * t * d + d ^ 2 := by
    simp only [dot, Fin.sum_univ_two, hydef, Matrix.cons_val_zero, Matrix.cons_val_one]
    nlinarith [hs2]
  have hyypos : 0 < dot y y := by
    rw [hyy]
    have : 1 - 2 * t * d + d ^ 2 = (t - d) ^ 2 + (1 - t ^ 2) := by ring
    rw [this]
    nlinarith [sq_nonneg (t - d), ht0, ht1]
  have hny : 0 < nrm y := Real.sqrt_pos.mpr hyypos
  have hny2 : nrm y ^ 2 = dot y y := nrm_sq y
  have hyw : dot y w = t - d := by simp [dot, Fin.sum_univ_two, hydef, hw]
  have hkey : (t - d) ^ 2 < (t * nrm y) ^ 2 := by
    rw [mul_pow, hny2, hyy]
    have hfac : t ^ 2 * (1 - 2 * t * d + d ^ 2) - (t - d) ^ 2 = (1 - t ^ 2) * (d * (2 * t - d)) := by
      ring
    have hpos1 : 0 < 1 - t ^ 2 := by nlinarith
    have hpos2 : 0 < d * (2 * t - d) := mul_pos hd0 (by linarith)
    linarith [hfac, mul_pos hpos1 hpos2]
  have hbpos : 0 < t * nrm y := mul_pos ht0 hny
  have hapos : 0 < t - d := by linarith
  have hcy : corr y w < t := by
    rw [corr, hyw, hnw, mul_one, div_lt_iff₀ hny]
    nlinarith [hkey, hbpos, hapos]
  have hix : capIndicator w t x = 1 := by
    simp only [capIndicator, hcx]; rw [if_pos le_rfl]
  have hiy : capIndicator w t y = 0 := by
    simp only [capIndicator]; rw [if_neg (not_le.mpr hcy)]
  have hdist : nrm (fun i => x i - y i) = d := by
    have hdd : dot (fun i => x i - y i) (fun i => x i - y i) = d ^ 2 := by
      simp only [dot, Fin.sum_univ_two, hxdef, hydef, Matrix.cons_val_zero, Matrix.cons_val_one]
      ring
    rw [nrm, hdd, Real.sqrt_sq hd0.le]
  have hlip := hF x y
  rw [hix, hiy, hdist] at hlip
  rw [show |(1 : ℝ) - 0| = 1 by norm_num] at hlip
  have h1 : L * d ≤ |L| * d := mul_le_mul_of_nonneg_right (le_abs_self L) hd0.le
  have h2 : |L| * d ≤ |L| * (1 / (2 * (|L| + 1))) :=
    mul_le_mul_of_nonneg_left hdL (abs_nonneg L)
  have h3 : |L| * (1 / (2 * (|L| + 1))) < 1 := by
    rw [mul_one_div, div_lt_one (by positivity)]
    linarith [abs_nonneg L]
  linarith

end Catalog.Physics.SphericalCapPowerCeiling