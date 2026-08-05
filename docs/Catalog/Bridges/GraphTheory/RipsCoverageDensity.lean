/-
  # Coverage, Packing and the `n^{-1/d}` Density Law for Rips-Based Detectors

  This file is the third link of the Phase A thread on quantitative sphere detection
  from finite data.

  * `Bridges/GraphTheory/RipsCorrespondenceInterleaving.lean` (cycle 1) proved the
    *global* statement: a correspondence of distortion `≤ c` between two finite samples
    translates Vietoris–Rips scales by `c`, and the matched / Hausdorff cases give the
    sharp `2δ` translation.
  * `Bridges/GraphTheory/RipsLinkGuardedInterval.lean` (cycle 2) proved the *local*
    statement: vertex-link degrees, the guarded interval, and Lipschitz stability
    `|guardThreshold T k − guardThreshold S k| ≤ 2δ` of its left endpoint under a
    `δ`-matching of an `η`-separated sample with `2δ < η`.

  Both of those results are *scale-free*: they say nothing about how large `δ` and `η`
  may be for a sample of `n` points.  Direction 2 of the mission asks exactly this
  question — the conjectured `n^{-1/d}` coverage law.  This file supplies the
  deterministic (measure-theoretic) half of that law and then feeds it back into the
  cycle-2 stability theorem.

  ## The chain

  1. `IsCoverAt` — the sample `P` is a `ρ`-cover of the set `K`; `IsCoverAt.subset_iUnion`
     turns this into a covering by closed balls.
  2. `IsCoverAt.measure_le` — the additive Haar measure of `K` is at most
     `#P · ρ^d · μ(B(0,1))` (`d = finrank ℝ E`), and `IsCoverAt.volume_le` is its real form.
  3. `IsCoverAt.le_card` / `IsCoverAt.le_pow` — hence `#P ≥ V/(v ρ^d)` and `ρ^d ≥ V/(v · #P)`.
  4. `IsCoverAt.rpow_le` — the covering radius obeys `ρ ≥ (V/(v n))^{1/d}`: the exact
     `n^{-1/d}` lower bound for the coverage scale.
  5. `packing_card_bound` — dually, an `η`-separated sample inside a ball of radius `R`
     satisfies `#P · (η/2)^d ≤ (R + η/2)^d`.
  6. `separation_le_two_radius`, `packing_spacing_bound`, `packing_spacing_rpow` — hence
     `#P · η^d ≤ (4R)^d`, i.e. the spacing also obeys the `n^{-1/d}` law.
  7. `IsCoverAt.hausdorffLe`, `IsCoverAt.exists_rips_shift` — two samples of the *same* set,
     each of resolution `ρ`, are at Hausdorff distance `≤ ρ`, so the cycle-1 interleaving
     applies with shift `2ρ`; `rips_shift_floor` says that this budget can never be smaller
     than `2 (V/(v n))^{1/d}`.
  8. `noise_resolution_tradeoff` — combining 3 and 6: any `δ` admissible for the cycle-2
     stability theorem satisfies `V · δ^d ≤ v · (2Rρ)^d`, i.e. `δ ≲ ρ` with a constant
     independent of the sample size (`noise_resolution_tradeoff_rpow`).
  9. `guardThreshold_shift_le_resolution` — the capstone: the shift of the guarded
     interval's endpoint under a matched perturbation is bounded by the *resolution* of
     the sample, `|Δ|^d · V ≤ v · (4Rρ)^d`, with a constant depending only on the ambient
     geometry.  This is cycle 2's stability theorem made quantitative in the sample size.

  Everything is proved; there are no `sorry`s and no new axioms.
-/
import Mathlib
import Bridges.GraphTheory.RipsCorrespondenceInterleaving
import Bridges.GraphTheory.RipsLinkGuardedInterval

open MeasureTheory Metric Finset
open scoped ENNReal

noncomputable section

namespace RipsCoverage

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [MeasurableSpace E]
  [BorelSpace E] [FiniteDimensional ℝ E]

/-! ## Part 1: Coverage forces a volume inequality -/

/-- The finite sample `P` is a `ρ`-cover of `K`: every point of `K` has a sample point
    within distance `ρ`.  Equivalently, the (one-sided) Hausdorff distance from `K` to
    `P` is at most `ρ`; `ρ` is the *resolution* of the sample. -/
def IsCoverAt (P : Finset E) (K : Set E) (ρ : ℝ) : Prop :=
  ∀ x ∈ K, ∃ p ∈ P, dist x p ≤ ρ

omit [NormedSpace ℝ E] [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E] in
/-- A `ρ`-cover exhibits `K` as a subset of the union of the closed `ρ`-balls around the
    sample points. -/
theorem IsCoverAt.subset_iUnion {P : Finset E} {K : Set E} {ρ : ℝ} (h : IsCoverAt P K ρ) :
    K ⊆ ⋃ p ∈ P, closedBall p ρ := by
  intro x hx
  obtain ⟨p, hp, hd⟩ := h x hx
  exact Set.mem_biUnion hp (by simpa [mem_closedBall] using hd)

/-- **Coverage volume bound.**  Subadditivity of an additive Haar measure together with
    the scaling law `μ (closedBall x ρ) = ρ^d · μ (ball 0 1)` bounds the measure of `K`
    by the number of sample points times the measure of a single ball. -/
theorem IsCoverAt.measure_le (μ : Measure E) [μ.IsAddHaarMeasure]
    {P : Finset E} {K : Set E} {ρ : ℝ} (hρ : 0 ≤ ρ) (h : IsCoverAt P K ρ) :
    μ K ≤ P.card * (ENNReal.ofReal (ρ ^ Module.finrank ℝ E) * μ (ball 0 1)) := by
  calc μ K ≤ μ (⋃ p ∈ P, closedBall p ρ) := measure_mono h.subset_iUnion
    _ ≤ ∑ p ∈ P, μ (closedBall p ρ) := measure_biUnion_finset_le _ _
    _ = ∑ _p ∈ P, (ENNReal.ofReal (ρ ^ Module.finrank ℝ E) * μ (ball 0 1)) :=
        Finset.sum_congr rfl fun p _ => Measure.addHaar_closedBall μ p hρ
    _ = P.card * (ENNReal.ofReal (ρ ^ Module.finrank ℝ E) * μ (ball 0 1)) := by
        rw [Finset.sum_const, nsmul_eq_mul]

/-- The real-valued form of `IsCoverAt.measure_le`: with `V = μ K` and `v = μ (ball 0 1)`
    (both as real numbers) a `ρ`-cover by `n` points satisfies `V ≤ n · ρ^d · v`. -/
theorem IsCoverAt.volume_le (μ : Measure E) [μ.IsAddHaarMeasure]
    {P : Finset E} {K : Set E} {ρ : ℝ} (hρ : 0 ≤ ρ) (h : IsCoverAt P K ρ) :
    (μ K).toReal ≤ P.card * ρ ^ Module.finrank ℝ E * (μ (ball 0 1)).toReal := by
  have hball : μ (ball (0 : E) 1) ≠ ⊤ := measure_ball_lt_top.ne
  have hfin :
      ((P.card : ℝ≥0∞) * (ENNReal.ofReal (ρ ^ Module.finrank ℝ E) * μ (ball 0 1))) ≠ ⊤ := by
    finiteness
  have h2 := ENNReal.toReal_mono hfin (h.measure_le μ hρ)
  rw [ENNReal.toReal_mul, ENNReal.toReal_mul, ENNReal.toReal_ofReal (by positivity),
    ENNReal.toReal_natCast] at h2
  linarith [h2]

omit [BorelSpace E] in
/-- The measure of the unit ball is a strictly positive real number. -/
theorem ball_toReal_pos (μ : Measure E) [μ.IsAddHaarMeasure] :
    0 < (μ (ball (0 : E) 1)).toReal :=
  ENNReal.toReal_pos (measure_ball_pos μ (0 : E) one_pos).ne' measure_ball_lt_top.ne

/-- **Sample-size lower bound.**  A set of positive volume needs at least `V/(v ρ^d)`
    sample points to be covered at resolution `ρ`. -/
theorem IsCoverAt.le_card (μ : Measure E) [μ.IsAddHaarMeasure]
    {P : Finset E} {K : Set E} {ρ : ℝ} (hρ : 0 < ρ) (h : IsCoverAt P K ρ) :
    (μ K).toReal / ((μ (ball (0 : E) 1)).toReal * ρ ^ Module.finrank ℝ E) ≤ P.card := by
  have hv := ball_toReal_pos μ (E := E)
  have hpos : 0 < (μ (ball (0 : E) 1)).toReal * ρ ^ Module.finrank ℝ E := by positivity
  rw [div_le_iff₀ hpos]
  nlinarith [h.volume_le μ hρ.le]

/-- **The `n^{-1/d}` law, `d`-th power form.**  The resolution of an `n`-point sample of a
    set of volume `V` satisfies `ρ^d ≥ V/(v n)`. -/
theorem IsCoverAt.le_pow (μ : Measure E) [μ.IsAddHaarMeasure]
    {P : Finset E} {K : Set E} {ρ : ℝ} (hP : P.Nonempty) (hρ : 0 ≤ ρ) (h : IsCoverAt P K ρ) :
    (μ K).toReal / ((μ (ball (0 : E) 1)).toReal * P.card) ≤ ρ ^ Module.finrank ℝ E := by
  have hv := ball_toReal_pos μ (E := E)
  have hcard : (0 : ℝ) < P.card := by exact_mod_cast Finset.card_pos.mpr hP
  have hpos : 0 < (μ (ball (0 : E) 1)).toReal * P.card := by positivity
  rw [div_le_iff₀ hpos]
  nlinarith [h.volume_le μ hρ]

/-- **The `n^{-1/d}` law.**  The covering radius of an `n`-point sample of a set of
    positive volume is at least `(V/(v n))^{1/d}`: no sampling scheme, random or not, can
    beat the bare power law `n^{-1/d}`.  (The extra logarithmic factor in the
    *probabilistic* coverage threshold is therefore a genuine excess over this
    deterministic floor, not an artefact.) -/
theorem IsCoverAt.rpow_le (μ : Measure E) [μ.IsAddHaarMeasure] [Nontrivial E]
    {P : Finset E} {K : Set E} {ρ : ℝ} (hP : P.Nonempty) (hρ : 0 ≤ ρ) (h : IsCoverAt P K ρ) :
    ((μ K).toReal / ((μ (ball (0 : E) 1)).toReal * P.card)) ^ ((Module.finrank ℝ E : ℝ)⁻¹)
      ≤ ρ := by
  set d := Module.finrank ℝ E with hd
  have hdpos : 0 < d := Module.finrank_pos
  have hv := ball_toReal_pos μ (E := E)
  have hcard : (0 : ℝ) < P.card := by exact_mod_cast Finset.card_pos.mpr hP
  set A := (μ K).toReal / ((μ (ball (0 : E) 1)).toReal * P.card) with hA
  have hA0 : 0 ≤ A := by
    have : 0 ≤ (μ K).toReal := ENNReal.toReal_nonneg
    positivity
  have hstep : A ^ ((d : ℝ)⁻¹) ≤ (ρ ^ d) ^ ((d : ℝ)⁻¹) :=
    Real.rpow_le_rpow hA0 (h.le_pow μ hP hρ) (by positivity)
  rwa [← Real.rpow_natCast ρ d, ← Real.rpow_mul hρ,
    mul_inv_cancel₀ (by exact_mod_cast hdpos.ne' : (d : ℝ) ≠ 0), Real.rpow_one] at hstep

/-! ## Part 2: Packing — separated samples cannot be large -/

/-- **Packing bound.**  If the sample `P` is `η`-separated (in the sense of
    `RipsGuard.Separated`, the hypothesis of the cycle-2 stability theorem) and lies in a
    ball of radius `R`, then `#P · (η/2)^d ≤ (R + η/2)^d`: the open `η/2`-balls around the
    sample points are disjoint and fit inside a ball of radius `R + η/2`. -/
theorem packing_card_bound (μ : Measure E) [μ.IsAddHaarMeasure] [Nontrivial E]
    {P : Finset E} {c : E} {R η : ℝ} (hη : 0 < η) (hR : 0 ≤ R)
    (hsep : RipsGuard.Separated P η) (hin : ∀ p ∈ P, dist p c ≤ R) :
    (P.card : ℝ) * (η / 2) ^ Module.finrank ℝ E ≤ (R + η / 2) ^ Module.finrank ℝ E := by
  set d := Module.finrank ℝ E with hd
  have hdisj : (↑P : Set E).PairwiseDisjoint (fun p => ball p (η / 2)) := by
    intro p hp q hq hpq
    exact ball_disjoint_ball (by linarith [hsep p hp q hq hpq])
  have hsum :
      μ (⋃ p ∈ P, ball p (η / 2)) = ∑ _p ∈ P, ENNReal.ofReal ((η / 2) ^ d) * μ (ball 0 1) := by
    rw [measure_biUnion_finset hdisj (fun p _ => measurableSet_ball)]
    exact Finset.sum_congr rfl fun p _ => Measure.addHaar_ball μ p (by linarith)
  have hsub : (⋃ p ∈ P, ball p (η / 2)) ⊆ closedBall c (R + η / 2) := by
    intro x hx
    simp only [Set.mem_iUnion, mem_ball, exists_prop] at hx
    obtain ⟨p, hp, hxp⟩ := hx
    have htri := dist_triangle x p c
    simp only [mem_closedBall]
    linarith [hin p hp]
  have hle : (P.card : ℝ≥0∞) * (ENNReal.ofReal ((η / 2) ^ d) * μ (ball 0 1))
      ≤ ENNReal.ofReal ((R + η / 2) ^ d) * μ (ball 0 1) :=
    calc (P.card : ℝ≥0∞) * (ENNReal.ofReal ((η / 2) ^ d) * μ (ball 0 1))
        = μ (⋃ p ∈ P, ball p (η / 2)) := by rw [hsum, Finset.sum_const, nsmul_eq_mul]
      _ ≤ μ (closedBall c (R + η / 2)) := measure_mono hsub
      _ = ENNReal.ofReal ((R + η / 2) ^ d) * μ (ball 0 1) :=
          Measure.addHaar_closedBall μ c (by linarith)
  have hball : μ (ball (0 : E) 1) ≠ ⊤ := measure_ball_lt_top.ne
  have hv := ball_toReal_pos μ (E := E)
  have h2 := ENNReal.toReal_mono (by finiteness) hle
  rw [ENNReal.toReal_mul, ENNReal.toReal_mul, ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (by positivity), ENNReal.toReal_ofReal (by positivity),
    ENNReal.toReal_natCast] at h2
  nlinarith [h2, hv]

omit [NormedSpace ℝ E] [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E] in
/-- A separation parameter of a sample with at least two points inside a ball of radius
    `R` cannot exceed the diameter `2R`. -/
theorem separation_le_two_radius {P : Finset E} {c : E} {R η : ℝ}
    (hcard : 2 ≤ P.card) (hsep : RipsGuard.Separated P η) (hin : ∀ p ∈ P, dist p c ≤ R) :
    η ≤ 2 * R := by
  obtain ⟨x, hx, y, hy, hxy⟩ := Finset.one_lt_card.mp hcard
  have h1 := hsep x hx y hy hxy
  have h2 : dist x y ≤ dist x c + dist c y := dist_triangle x c y
  have h3 := hin x hx
  have h4 := hin y hy
  rw [dist_comm c y] at h2
  linarith

/-- **Spacing obeys the `n^{-1/d}` law.**  An `η`-separated sample of `n` points inside a
    ball of radius `R` satisfies `n · η^d ≤ (4R)^d`.  Together with `IsCoverAt.le_pow`
    this shows that spacing and resolution are governed by the *same* power of `n`. -/
theorem packing_spacing_bound (μ : Measure E) [μ.IsAddHaarMeasure] [Nontrivial E]
    {P : Finset E} {c : E} {R η : ℝ} (hη : 0 < η) (hR : 0 ≤ R) (hcard : 2 ≤ P.card)
    (hsep : RipsGuard.Separated P η) (hin : ∀ p ∈ P, dist p c ≤ R) :
    (P.card : ℝ) * η ^ Module.finrank ℝ E ≤ (4 * R) ^ Module.finrank ℝ E := by
  set d := Module.finrank ℝ E with hd
  have hpack := packing_card_bound μ hη hR hsep hin
  have hηR : η ≤ 2 * R := separation_le_two_radius hcard hsep hin
  have hmono : (R + η / 2) ^ d ≤ (2 * R) ^ d :=
    pow_le_pow_left₀ (by linarith) (by linarith) d
  have hsplit : (P.card : ℝ) * η ^ d = 2 ^ d * ((P.card : ℝ) * (η / 2) ^ d) := by
    rw [div_pow]; field_simp
  have h2d : (0 : ℝ) < 2 ^ d := by positivity
  calc (P.card : ℝ) * η ^ d = 2 ^ d * ((P.card : ℝ) * (η / 2) ^ d) := hsplit
    _ ≤ 2 ^ d * (2 * R) ^ d := by nlinarith [hpack, hmono]
    _ = (4 * R) ^ d := by rw [← mul_pow]; ring_nf

/-- The `rpow` form of `packing_spacing_bound`: `η · n^{1/d} ≤ 4R`. -/
theorem packing_spacing_rpow (μ : Measure E) [μ.IsAddHaarMeasure] [Nontrivial E]
    {P : Finset E} {c : E} {R η : ℝ} (hη : 0 < η) (hR : 0 ≤ R) (hcard : 2 ≤ P.card)
    (hsep : RipsGuard.Separated P η) (hin : ∀ p ∈ P, dist p c ≤ R) :
    η * (P.card : ℝ) ^ ((Module.finrank ℝ E : ℝ)⁻¹) ≤ 4 * R := by
  set d := Module.finrank ℝ E with hd
  have hdpos : 0 < d := Module.finrank_pos
  have hdne : ((d : ℝ)) ≠ 0 := by exact_mod_cast hdpos.ne'
  have hbase := packing_spacing_bound μ hη hR hcard hsep hin
  have hcard0 : (0 : ℝ) ≤ P.card := Nat.cast_nonneg _
  have hR' : (0 : ℝ) ≤ 4 * R := by linarith
  have hstep : ((P.card : ℝ) * η ^ d) ^ ((d : ℝ)⁻¹) ≤ ((4 * R) ^ d) ^ ((d : ℝ)⁻¹) :=
    Real.rpow_le_rpow (by positivity) hbase (by positivity)
  rw [Real.mul_rpow hcard0 (by positivity), ← Real.rpow_natCast η d, ← Real.rpow_natCast (4*R) d,
    ← Real.rpow_mul hη.le, ← Real.rpow_mul hR', mul_inv_cancel₀ hdne] at hstep
  simp only [Real.rpow_one] at hstep
  rw [mul_comm]
  exact hstep

/-! ## Part 4: Two samples of the same set — back to the cycle-1 interleaving -/

omit [NormedSpace ℝ E] [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E] in
/-- Two samples *of the same set* `K`, each of resolution `ρ`, are automatically at
    Hausdorff distance at most `ρ`.  This is the bridge from the density notions of this
    file to the correspondence interleaving of cycle 1. -/
theorem IsCoverAt.hausdorffLe {S T : Finset E} {K : Set E} {ρ : ℝ}
    (hSK : ∀ x ∈ S, x ∈ K) (hTK : ∀ y ∈ T, y ∈ K)
    (hS : IsCoverAt S K ρ) (hT : IsCoverAt T K ρ) : HausdorffLe S T ρ := by
  refine ⟨fun x hx => ?_, fun y hy => ?_⟩
  · exact hT x (hSK x hx)
  · obtain ⟨p, hp, hd⟩ := hS y (hTK y hy)
    exact ⟨p, hp, by rwa [dist_comm] at hd⟩

omit [NormedSpace ℝ E] [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E] in
/-- **Resolution controls the interleaving.**  For two samples of the same set `K`, each of
    resolution `ρ`, there is a map `f : S → T` under which every `ε`-Rips simplex of `S`
    becomes an `(ε + 2ρ)`-Rips simplex of `T`.  The scale translation of cycle 1 is thus
    driven entirely by the *resolution* of the samples. -/
theorem IsCoverAt.exists_rips_shift [DecidableEq E] {S T : Finset E} {K : Set E} {ρ : ℝ}
    (hSK : ∀ x ∈ S, x ∈ K) (hTK : ∀ y ∈ T, y ∈ K)
    (hS : IsCoverAt S K ρ) (hT : IsCoverAt T K ρ) :
    ∃ f : E → E, (∀ x ∈ S, f x ∈ T ∧ dist x (f x) ≤ ρ) ∧
      ∀ (ε : ℝ) (s : Finset E), IsRipsSimplex S ε s →
        IsRipsSimplex T (ε + 2 * ρ) (s.image f) := by
  obtain ⟨f, hf⟩ :=
    Correspondence.exists_map (hausdorff_isCorrespondence (hS.hausdorffLe hSK hTK hT))
  exact ⟨f, hf, fun ε s hs => hausdorff_image_isRipsSimplex hf hs⟩

/-- **The interleaving budget has an `n^{-1/d}` floor.**  Combining
    `IsCoverAt.exists_rips_shift` with `IsCoverAt.rpow_le`: the scale translation `2ρ`
    needed to compare two `n`-point samples of a set of volume `V` can never be smaller
    than `2 (V/(v n))^{1/d}`.  In particular, refining the sample is the *only* way to
    shrink the interleaving error, and it shrinks only like `n^{-1/d}`. -/
theorem rips_shift_floor (μ : Measure E) [μ.IsAddHaarMeasure] [Nontrivial E]
    {S : Finset E} {K : Set E} {ρ : ℝ} (hS : S.Nonempty) (hρ : 0 ≤ ρ)
    (hcov : IsCoverAt S K ρ) :
    2 * ((μ K).toReal / ((μ (ball (0 : E) 1)).toReal * S.card))
        ^ ((Module.finrank ℝ E : ℝ)⁻¹) ≤ 2 * ρ := by
  have := hcov.rpow_le μ hS hρ
  linarith

/-! ## Part 5: The noise/resolution trade-off, and the guarded endpoint -/

/-- **Noise/resolution trade-off.**  Suppose a sample `P` of a set `K` of volume `V`

    * is a `ρ`-cover of `K` (resolution `ρ`),
    * is `η`-separated and contained in a ball of radius `R`,
    * and the matching parameter `δ ≥ 0` satisfies the cycle-2 hypothesis `2δ < η`.

    Then `V · δ^d ≤ v · (2Rρ)^d`, where `v = μ (ball 0 1)`.  The sample size has
    cancelled: the admissible noise level is at most a *fixed* multiple of the
    resolution, `δ ≲ ρ`.  This is the deterministic content of the `n^{-1/d}` law:
    both the noise budget and the resolution scale like `n^{-1/d}`, so their ratio is
    bounded by a constant of the ambient geometry alone. -/
theorem noise_resolution_tradeoff (μ : Measure E) [μ.IsAddHaarMeasure] [Nontrivial E]
    {P : Finset E} {K : Set E} {c : E} {R η ρ δ : ℝ}
    (hη : 0 < η) (hR : 0 ≤ R) (hρ : 0 ≤ ρ) (hδ : 0 ≤ δ) (hδη : 2 * δ < η)
    (hcard : 2 ≤ P.card) (hsep : RipsGuard.Separated P η) (hin : ∀ p ∈ P, dist p c ≤ R)
    (hcov : IsCoverAt P K ρ) :
    (μ K).toReal * δ ^ Module.finrank ℝ E
      ≤ (μ (ball (0 : E) 1)).toReal * (2 * R * ρ) ^ Module.finrank ℝ E := by
  set d := Module.finrank ℝ E with hd
  set v := (μ (ball (0 : E) 1)).toReal with hv'
  have hv := ball_toReal_pos μ (E := E)
  have hpack := packing_card_bound μ hη hR hsep hin
  have hηR : η ≤ 2 * R := separation_le_two_radius hcard hsep hin
  have hmono : (R + η / 2) ^ d ≤ (2 * R) ^ d :=
    pow_le_pow_left₀ (by linarith) (by linarith) d
  -- packing, cleaned up: `#P · δ^d ≤ (2R)^d`
  have hδη2 : δ ≤ η / 2 := by linarith
  have hpowδ : δ ^ d ≤ (η / 2) ^ d := pow_le_pow_left₀ hδ hδη2 d
  have hcard0 : (0 : ℝ) ≤ P.card := Nat.cast_nonneg _
  have hpack' : (P.card : ℝ) * δ ^ d ≤ (2 * R) ^ d := by nlinarith [hpack, hpowδ, hcard0]
  -- coverage: `V ≤ #P · ρ^d · v`
  have hcov' : (μ K).toReal ≤ P.card * ρ ^ d * v := hcov.volume_le μ hρ
  have hδd : (0 : ℝ) ≤ δ ^ d := by positivity
  have hρd : (0 : ℝ) ≤ ρ ^ d := by positivity
  calc (μ K).toReal * δ ^ d ≤ ((P.card : ℝ) * ρ ^ d * v) * δ ^ d :=
        mul_le_mul_of_nonneg_right hcov' hδd
    _ = (ρ ^ d * v) * ((P.card : ℝ) * δ ^ d) := by ring
    _ ≤ (ρ ^ d * v) * (2 * R) ^ d :=
        mul_le_mul_of_nonneg_left hpack' (by positivity)
    _ = v * (2 * R * ρ) ^ d := by rw [mul_pow, mul_pow]; ring

/-- The `rpow` form of the trade-off: `δ · V^{1/d} ≤ 2Rρ · v^{1/d}`. -/
theorem noise_resolution_tradeoff_rpow (μ : Measure E) [μ.IsAddHaarMeasure] [Nontrivial E]
    {P : Finset E} {K : Set E} {c : E} {R η ρ δ : ℝ}
    (hη : 0 < η) (hR : 0 ≤ R) (hρ : 0 ≤ ρ) (hδ : 0 ≤ δ) (hδη : 2 * δ < η)
    (hcard : 2 ≤ P.card) (hsep : RipsGuard.Separated P η) (hin : ∀ p ∈ P, dist p c ≤ R)
    (hcov : IsCoverAt P K ρ) :
    δ * ((μ K).toReal) ^ ((Module.finrank ℝ E : ℝ)⁻¹)
      ≤ 2 * R * ρ * ((μ (ball (0 : E) 1)).toReal) ^ ((Module.finrank ℝ E : ℝ)⁻¹) := by
  set d := Module.finrank ℝ E with hd
  have hdpos : 0 < d := Module.finrank_pos
  have hdne : ((d : ℝ)) ≠ 0 := by exact_mod_cast hdpos.ne'
  have hV0 : (0 : ℝ) ≤ (μ K).toReal := ENNReal.toReal_nonneg
  have hv0 : (0 : ℝ) ≤ (μ (ball (0 : E) 1)).toReal := ENNReal.toReal_nonneg
  have hRρ : (0 : ℝ) ≤ 2 * R * ρ := by positivity
  have hbase := noise_resolution_tradeoff μ hη hR hρ hδ hδη hcard hsep hin hcov
  have hstep : ((μ K).toReal * δ ^ d) ^ ((d : ℝ)⁻¹)
      ≤ ((μ (ball (0 : E) 1)).toReal * (2 * R * ρ) ^ d) ^ ((d : ℝ)⁻¹) :=
    Real.rpow_le_rpow (by positivity) hbase (by positivity)
  rw [Real.mul_rpow hV0 (by positivity), Real.mul_rpow hv0 (by positivity),
    ← Real.rpow_natCast δ d, ← Real.rpow_natCast (2 * R * ρ) d,
    ← Real.rpow_mul hδ, ← Real.rpow_mul hRρ, mul_inv_cancel₀ hdne] at hstep
  simp only [Real.rpow_one] at hstep
  rw [mul_comm δ _, mul_comm (2 * R * ρ) _]
  exact hstep

/-- **Capstone.**  Combine the cycle-2 endpoint-stability theorem
    `RipsGuard.guardThreshold_stability_abs` with the density law.

    Let `S` be a sample of `K` which is `η`-separated, lies in a ball of radius `R`, and
    covers `K` at resolution `ρ`; let `T` be a matched `δ`-perturbation of `S` (and
    conversely), with `2δ < η`.  Then the shift `Δ` of the left endpoint of the guarded
    interval satisfies
    `V · |Δ|^d ≤ v · (4Rρ)^d`.

    In words: the endpoint of the guarded Poincaré interval moves by no more than a
    fixed geometric constant times the resolution of the sample — the stability estimate
    of cycle 2 is not merely Lipschitz in `δ`, it is quantitatively tied to how finely the
    underlying set has been sampled, uniformly in the number of sample points. -/
theorem guardThreshold_shift_le_resolution (μ : Measure E) [μ.IsAddHaarMeasure]
    [Nontrivial E] [DecidableEq E]
    {S T : Finset E} {K : Set E} {f g : E → E} {c : E} {R η ρ δ : ℝ} {k : ℕ}
    (hη : 0 < η) (hR : 0 ≤ R) (hρ : 0 ≤ ρ) (hδ : 0 ≤ δ) (hδη : 2 * δ < η)
    (hcard : 2 ≤ S.card) (hin : ∀ p ∈ S, dist p c ≤ R) (hcov : IsCoverAt S K ρ)
    (hf : RipsGuard.IsDeltaMatching S T f δ) (hg : RipsGuard.IsDeltaMatching T S g δ)
    (hsepS : RipsGuard.Separated S η) (hsepT : RipsGuard.Separated T η)
    (hk : 1 ≤ k) (hkS : k ≤ S.card) (hkT : k ≤ T.card) :
    (μ K).toReal * |RipsGuard.guardThreshold T k - RipsGuard.guardThreshold S k|
        ^ Module.finrank ℝ E
      ≤ (μ (ball (0 : E) 1)).toReal * (4 * R * ρ) ^ Module.finrank ℝ E := by
  set d := Module.finrank ℝ E with hd
  set Δ := |RipsGuard.guardThreshold T k - RipsGuard.guardThreshold S k| with hΔ
  have hstab : Δ ≤ 2 * δ :=
    RipsGuard.guardThreshold_stability_abs hf hg hsepS hsepT hδη hk hkS hkT
  have hΔ0 : 0 ≤ Δ := abs_nonneg _
  have hpow : Δ ^ d ≤ (2 * δ) ^ d := pow_le_pow_left₀ hΔ0 hstab d
  have htrade := noise_resolution_tradeoff μ hη hR hρ hδ hδη hcard hsepS hin hcov
  have hV0 : (0 : ℝ) ≤ (μ K).toReal := ENNReal.toReal_nonneg
  have hv0 : (0 : ℝ) ≤ (μ (ball (0 : E) 1)).toReal := ENNReal.toReal_nonneg
  have hexp : (2 * δ) ^ d = 2 ^ d * δ ^ d := by rw [mul_pow]
  have h4 : (4 * R * ρ) ^ d = 2 ^ d * (2 * R * ρ) ^ d := by
    rw [← mul_pow]; ring_nf
  have h2d : (0 : ℝ) < 2 ^ d := by positivity
  calc (μ K).toReal * Δ ^ d ≤ (μ K).toReal * (2 ^ d * δ ^ d) := by
        rw [← hexp]; exact mul_le_mul_of_nonneg_left hpow hV0
    _ = 2 ^ d * ((μ K).toReal * δ ^ d) := by ring
    _ ≤ 2 ^ d * ((μ (ball (0 : E) 1)).toReal * (2 * R * ρ) ^ d) := by
        exact mul_le_mul_of_nonneg_left htrade h2d.le
    _ = (μ (ball (0 : E) 1)).toReal * (4 * R * ρ) ^ d := by rw [h4]; ring

end RipsCoverage

end