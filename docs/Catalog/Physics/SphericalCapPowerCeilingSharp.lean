import Physics.SphericalCapPowerCeiling

/-!
# Sharpness, metric structure, and the alignment window of the U84 cap

Second cycle of the spherical-cap analysis of `Physics.SphericalCapPowerCeiling`.  Cycle 1
proved a sample-size-free ceiling `|F(û) − F(v̂)| ≤ L·√(2ε)` for `L`-Lipschitz statistics and
showed that a discontinuous threshold statistic escapes it.  The obvious adversarial questions
are: *is the constant `√(2ε)` real or an artefact of a crude estimate?*, *is the Lipschitz
class non-vacuous?*, and *how tightly is the alignment `0.9999` itself constrained by the
recorded margin `0.008`?*  All three are answered here.

## Main results

### 1. Euclidean scaffolding (Section 1)

* `dot_le_nrm_mul_nrm`, `abs_dot_le_nrm_mul_nrm` — Cauchy–Schwarz in norm form.
* `nrm_add_le`, `abs_nrm_sub_nrm_le` — Minkowski and the reverse triangle inequality.
* `chord_comm`, `chord_self`, `chord_triangle` — the chordal distance is a pseudometric on
  nonzero vectors, so cap estimates compose along a ladder of hypotheses.

### 2. The ceiling is sharp (Section 2)

* `lipschitz_ceiling_attained` — for every `L ≥ 0` and every pair of directions there *is* an
  `L`-Lipschitz statistic with `|F(û) − F(v̂)| = L·chord(u,v)`: the ceiling of cycle 1 is
  attained, not merely an upper estimate.

### 3. The Lipschitz class is non-vacuous (Section 3)

* `IsLipSphere`, `sphere_lipschitz_gap_le` — the ceiling only needs Lipschitz behaviour *on the
  unit sphere*, a strictly weaker hypothesis (`isLipSphere_of_isLip`).
* `corr_isLipSphere_one` — the correlation functional `x ↦ corr x w` is `1`-Lipschitz on the
  sphere.  The class therefore contains the statistic actually used at U84.

### 4. The alignment window (Section 4)

* `corr_diff_le_chord` — `|corr u w − corr v w| ≤ chord u v`: a reading gap forces a chordal
  separation.
* `margin_forces_alignment_ceiling` — a recorded margin `δ` caps the alignment at
  `1 − δ²/2`.
* `u84_alignment_window` — combining with the catalog configuration: the two U84 hypotheses can
  be aligned to `≥ 0.9999`, and *no* realisation can beat `0.999968`.  The recorded alignment is
  therefore within `6.8·10⁻⁵` of the geometric optimum.
* `u84_correlation_test_near_optimal` — the correlation statistic itself separates the two
  readings by exactly `0.008`, against a ceiling `√2/100 = 0.014142…` for all `1`-Lipschitz
  statistics: the smooth-test ceiling is loose by less than a factor `1.7678`.

### 5. Ladders (Section 5)

* `chord_chain_le` — along a ladder of `k` successive hypotheses each aligned at `1 − ε` the
  chordal separation is at most `k·√(2ε)`, hence a smooth statistic separates the endpoints by
  at most `k·L·√(2ε)` (`lipschitz_chain_gap_le`).  Eight recorded rungs at U84-level alignment
  still give a ceiling below `0.12·L`.

## Lab notes (derived numerics)

```
recorded margin δ            0.008
alignment ceiling 1 − δ²/2   0.999968
catalog attained alignment   0.9999            (gap to optimum 6.8e-5)
1-Lipschitz ceiling          √2/100 = 0.0141421
correlation-test separation  0.008             (ratio to ceiling 0.5657)
8-rung ladder ceiling        8·√2/100 = 0.1131 (still o(1))
```
-/

open Finset
open Catalog.Algebra.ZeroFitDialU72Parity

namespace Catalog.Physics.SphericalCapPowerCeiling

variable {n : ℕ}

/-! ## 1. Cauchy–Schwarz, Minkowski, and the chordal pseudometric -/

lemma dot_le_nrm_mul_nrm (a b : Fin n → ℝ) : dot a b ≤ nrm a * nrm b := by
  have h1 : nrm a * nrm b = Real.sqrt (dot a a * dot b b) := by
    rw [nrm, nrm, ← Real.sqrt_mul (dot_self_nonneg a)]
  have h2 : |dot a b| ≤ Real.sqrt (dot a a * dot b b) := by
    rw [← Real.sqrt_sq_eq_abs]
    exact Real.sqrt_le_sqrt (dot_sq_le a b)
  calc dot a b ≤ |dot a b| := le_abs_self _
    _ ≤ Real.sqrt (dot a a * dot b b) := h2
    _ = nrm a * nrm b := h1.symm

lemma abs_dot_le_nrm_mul_nrm (a b : Fin n → ℝ) : |dot a b| ≤ nrm a * nrm b := by
  rw [abs_le]
  constructor
  · have h := dot_le_nrm_mul_nrm (fun i => -a i) b
    have he : dot (fun i => -a i) b = -dot a b := by
      simp [dot, ← Finset.sum_neg_distrib, neg_mul]
    have hn : nrm (fun i => -a i) = nrm a := by
      rw [nrm, nrm]
      congr 1
      simp [dot]
    rw [he, hn] at h
    linarith
  · exact dot_le_nrm_mul_nrm a b

lemma nrm_nonneg (a : Fin n → ℝ) : 0 ≤ nrm a := Real.sqrt_nonneg _

/-- **Minkowski's inequality** for `nrm`. -/
lemma nrm_add_le (a b : Fin n → ℝ) : nrm (fun i => a i + b i) ≤ nrm a + nrm b := by
  have hexp : dot (fun i => a i + b i) (fun i => a i + b i)
      = dot a a + 2 * dot a b + dot b b := by
    simp only [dot, two_mul, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun i _ => by ring)
  have hcs := dot_le_nrm_mul_nrm a b
  have hsq : nrm (fun i => a i + b i) ^ 2 ≤ (nrm a + nrm b) ^ 2 := by
    rw [nrm_sq, hexp, ← nrm_sq a, ← nrm_sq b]
    nlinarith [hcs]
  nlinarith [hsq, nrm_nonneg (fun i => a i + b i), nrm_nonneg a, nrm_nonneg b]

/-- **Reverse triangle inequality** for `nrm`. -/
lemma abs_nrm_sub_nrm_le (a b : Fin n → ℝ) :
    |nrm a - nrm b| ≤ nrm (fun i => a i - b i) := by
  have h1 : nrm a ≤ nrm (fun i => a i - b i) + nrm b := by
    have h := nrm_add_le (fun i => a i - b i) b
    simpa using h
  have h2 : nrm b ≤ nrm (fun i => a i - b i) + nrm a := by
    have h := nrm_add_le (fun i => b i - a i) a
    have hswap : nrm (fun i => b i - a i) = nrm (fun i => a i - b i) := by
      rw [nrm, nrm]
      congr 1
      simp only [dot]
      exact Finset.sum_congr rfl (fun i _ => by ring)
    rw [hswap] at h
    simpa using h
  rw [abs_le]
  constructor <;> linarith

lemma chord_comm (u v : Fin n → ℝ) : chord u v = chord v u := by
  rw [chord, chord, nrm, nrm]
  congr 1
  simp only [dot]
  exact Finset.sum_congr rfl (fun i _ => by ring)

lemma chord_self (u : Fin n → ℝ) : chord u u = 0 := by
  rw [chord, nrm]
  simp [dot]

/-- The chordal distance obeys the triangle inequality: cap estimates compose. -/
theorem chord_triangle (u v w : Fin n → ℝ) : chord u w ≤ chord u v + chord v w := by
  have hsplit : (fun i => nz u i - nz w i)
      = fun i => (nz u i - nz v i) + (nz v i - nz w i) := by
    funext i; ring
  rw [chord, hsplit]
  exact nrm_add_le _ _

/-! ## 2. The ceiling is attained -/

/-- **Sharpness of the spherical-cap ceiling.**  For any two directions and any `L ≥ 0` there
is an honest `L`-Lipschitz statistic whose separation equals `L` times the chordal distance.
So the bound `L·√(2ε)` of `lipschitz_gap_le` cannot be improved as a function of the cap
radius. -/
theorem lipschitz_ceiling_attained {L : ℝ} (hL : 0 ≤ L) (u v : Fin n → ℝ) :
    ∃ F : (Fin n → ℝ) → ℝ, IsLip L F ∧ |F (nz u) - F (nz v)| = L * chord u v := by
  refine ⟨fun x => L * nrm (fun i => x i - nz v i), ?_, ?_⟩
  · intro x y
    have hrev : |nrm (fun i => x i - nz v i) - nrm (fun i => y i - nz v i)|
        ≤ nrm (fun i => x i - y i) := by
      have h := abs_nrm_sub_nrm_le (fun i => x i - nz v i) (fun i => y i - nz v i)
      have hfun : (fun i => (x i - nz v i) - (y i - nz v i)) = fun i => x i - y i := by
        funext i; ring
      rwa [hfun] at h
    calc |L * nrm (fun i => x i - nz v i) - L * nrm (fun i => y i - nz v i)|
        = L * |nrm (fun i => x i - nz v i) - nrm (fun i => y i - nz v i)| := by
          rw [← mul_sub, abs_mul, abs_of_nonneg hL]
      _ ≤ L * nrm (fun i => x i - y i) := mul_le_mul_of_nonneg_left hrev hL
  · have hzero : nrm (fun i => nz v i - nz v i) = 0 := by
      rw [nrm]; simp [dot]
    show |L * nrm (fun i => nz u i - nz v i) - L * nrm (fun i => nz v i - nz v i)|
        = L * chord u v
    rw [hzero, mul_zero, sub_zero, chord,
      abs_of_nonneg (mul_nonneg hL (nrm_nonneg (fun i => nz u i - nz v i)))]

/-! ## 3. The Lipschitz class is non-vacuous: correlation is `1`-Lipschitz on the sphere -/

/-- Lipschitz *only on the unit sphere* — a weaker requirement than `IsLip`, under which the
cap ceiling still holds. -/
def IsLipSphere (L : ℝ) (F : (Fin n → ℝ) → ℝ) : Prop :=
  ∀ x y : Fin n → ℝ, dot x x = 1 → dot y y = 1 →
    |F x - F y| ≤ L * nrm (fun i => x i - y i)

lemma isLipSphere_of_isLip {L : ℝ} {F : (Fin n → ℝ) → ℝ} (hF : IsLip L F) :
    IsLipSphere L F := fun x y _ _ => hF x y

/-- **The ceiling under the weaker sphere-Lipschitz hypothesis.** -/
theorem sphere_lipschitz_gap_le {L : ℝ} (hL : 0 ≤ L) {F : (Fin n → ℝ) → ℝ}
    (hF : IsLipSphere L F) {u v : Fin n → ℝ} (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    {eps : ℝ} (h : 1 - eps ≤ corr u v) :
    |F (nz u) - F (nz v)| ≤ L * Real.sqrt (2 * eps) := by
  have h1 : |F (nz u) - F (nz v)| ≤ L * chord u v :=
    hF (nz u) (nz v) (dot_nz_self u hu) (dot_nz_self v hv)
  exact le_trans h1 (mul_le_mul_of_nonneg_left (chord_le_sqrt_two_mul u v hu hv h) hL)

/-- **Correlation with a fixed unit response is `1`-Lipschitz on the sphere.** -/
theorem corr_isLipSphere_one (w : Fin n → ℝ) (hw : dot w w = 1) :
    IsLipSphere 1 (fun x => corr x w) := by
  intro x y hx hy
  have hnx : nrm x = 1 := by rw [nrm, hx, Real.sqrt_one]
  have hny : nrm y = 1 := by rw [nrm, hy, Real.sqrt_one]
  have hnw : nrm w = 1 := by rw [nrm, hw, Real.sqrt_one]
  have hcx : corr x w = dot x w := by rw [corr, hnx, hnw]; norm_num
  have hcy : corr y w = dot y w := by rw [corr, hny, hnw]; norm_num
  show |corr x w - corr y w| ≤ 1 * nrm (fun i => x i - y i)
  rw [hcx, hcy, ← dot_sub_left x y w, one_mul]
  have h := abs_dot_le_nrm_mul_nrm (fun i => x i - y i) w
  rwa [hnw, mul_one] at h

/-! ## 4. The alignment window forced by the recorded margin -/

/-- Correlation is invariant under normalising both arguments. -/
lemma corr_nz_nz (u w : Fin n → ℝ) (hu : dot u u ≠ 0) (hw : dot w w ≠ 0) :
    corr (nz u) (nz w) = corr u w := by
  rw [corr_nz_left u (nz w) hu, corr_comm, corr_nz_left w u hw, corr_comm]

/-- A gap between the two readings against a common response forces a chordal separation. -/
theorem corr_diff_le_chord (u v w : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (hw : dot w w ≠ 0) : |corr u w - corr v w| ≤ chord u v := by
  have hlip := corr_isLipSphere_one (nz w) (dot_nz_self w hw)
  have h : |corr (nz u) (nz w) - corr (nz v) (nz w)| ≤ 1 * nrm (fun i => nz u i - nz v i) :=
    hlip (nz u) (nz v) (dot_nz_self u hu) (dot_nz_self v hv)
  rw [one_mul, ← chord] at h
  rwa [corr_nz_nz u w hu hw, corr_nz_nz v w hv hw] at h

/-- **A recorded margin caps the achievable alignment.**  If two predictors read `δ` apart
against a common response, their mutual correlation cannot exceed `1 − δ²/2`. -/
theorem margin_forces_alignment_ceiling {u v w : Fin n → ℝ} (hu : dot u u ≠ 0)
    (hv : dot v v ≠ 0) (hw : dot w w ≠ 0) {delta : ℝ} (hd0 : 0 ≤ delta)
    (hd : delta ≤ corr u w - corr v w) :
    corr u v ≤ 1 - delta ^ 2 / 2 := by
  have hch : delta ≤ chord u v := by
    have h := corr_diff_le_chord u v w hu hv hw
    have h2 : corr u w - corr v w ≤ |corr u w - corr v w| := le_abs_self _
    linarith
  have hsq := chord_sq_eq u v hu hv
  nlinarith [hch, hsq, hd0]

/-- **The U84 alignment window.**  The two hypotheses *can* be aligned to `0.9999` (catalog
configuration) and *cannot* be aligned beyond `0.999968`, the geometric ceiling imposed by the
recorded margin `0.008`. -/
theorem u84_alignment_window :
    (∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
        corr u w = 558 / 1000 ∧ corr v w = 55 / 100 ∧ (9999 : ℝ) / 10000 ≤ corr u v) ∧
      (∀ (m : ℕ) (u v w : Fin m → ℝ), dot u u ≠ 0 → dot v v ≠ 0 → dot w w ≠ 0 →
        corr u w = 558 / 1000 → corr v w = 55 / 100 →
        corr u v ≤ 1 - 32 / 1000000) := by
  constructor
  · exact Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  · intro m u v w hu hv hw huw hvw
    have h := margin_forces_alignment_ceiling (delta := 8 / 1000) hu hv hw (by norm_num)
      (by rw [huw, hvw]; norm_num)
    nlinarith [h]

/-- **The correlation statistic is near-optimal among smooth tests.**  On the catalog
configuration it separates the two hypotheses by exactly the recorded margin `0.008`, while no
`1`-Lipschitz statistic can exceed `√2/100 = 0.014142…`.  The smooth-test ceiling is loose by a
factor below `1.7678`. -/
theorem u84_correlation_test_near_optimal :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      |corr (nz u) w - corr (nz v) w| = 8 / 1000 ∧
      (∀ F : (Fin 2 → ℝ) → ℝ, IsLipSphere 1 F →
        |F (nz u) - F (nz v)| ≤ Real.sqrt 2 / 100) := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  refine ⟨u, v, w, hu, hv, hw, ?_, ?_⟩
  · rw [corr_nz_left u w hu, corr_nz_left v w hv, huw, hvw]
    rw [show (558 : ℝ) / 1000 - 55 / 100 = 8 / 1000 by norm_num]
    exact abs_of_nonneg (by norm_num)
  · intro F hF
    have h := sphere_lipschitz_gap_le (L := 1) (by norm_num) hF hu hv
      (eps := 1 / 10000) (by linarith)
    rw [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius,
      one_mul] at h
    exact h

/-! ## 5. Ladders of hypotheses -/

/-- **Chordal chain bound.**  Along a ladder of hypotheses whose consecutive members are
aligned at level `1 − ε`, the endpoints are at chordal distance at most `k·√(2ε)`. -/
theorem chord_chain_le (f : ℕ → Fin n → ℝ) (hf : ∀ i, dot (f i) (f i) ≠ 0) {eps : ℝ}
    (k : ℕ) (h : ∀ i, i < k → 1 - eps ≤ corr (f i) (f (i + 1))) :
    chord (f 0) (f k) ≤ k * Real.sqrt (2 * eps) := by
  induction k with
  | zero => simpa using le_of_eq (chord_self (f 0))
  | succ k ih =>
      have hstep : chord (f k) (f (k + 1)) ≤ Real.sqrt (2 * eps) :=
        chord_le_sqrt_two_mul (f k) (f (k + 1)) (hf k) (hf (k + 1)) (h k (Nat.lt_succ_self k))
      have hprev := ih (fun i hi => h i (Nat.lt_succ_of_lt hi))
      have htri := chord_triangle (f 0) (f k) (f (k + 1))
      push_cast
      linarith

/-- A smooth statistic cannot separate the two ends of such a ladder by more than
`k·L·√(2ε)`. -/
theorem lipschitz_chain_gap_le {L : ℝ} (hL : 0 ≤ L) {F : (Fin n → ℝ) → ℝ}
    (hF : IsLipSphere L F) (f : ℕ → Fin n → ℝ) (hf : ∀ i, dot (f i) (f i) ≠ 0) {eps : ℝ}
    (k : ℕ) (h : ∀ i, i < k → 1 - eps ≤ corr (f i) (f (i + 1))) :
    |F (nz (f 0)) - F (nz (f k))| ≤ k * L * Real.sqrt (2 * eps) := by
  have h1 : |F (nz (f 0)) - F (nz (f k))| ≤ L * chord (f 0) (f k) :=
    hF (nz (f 0)) (nz (f k)) (dot_nz_self _ (hf 0)) (dot_nz_self _ (hf k))
  have h2 := chord_chain_le f hf k h
  nlinarith [h1, h2, hL, chord_nonneg (f 0) (f k)]

end Catalog.Physics.SphericalCapPowerCeiling