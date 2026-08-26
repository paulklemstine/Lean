/-
# Cycle 3 (adversarial): the window curve need not be unimodal

The saturation theorem of `Combinatorics.WindowSaturationMatchedFilter` produces a
*unique interior* argmax under a matched-signal-then-noise hypothesis, and the
empirical instrument that motivated it reports a bimodal bootstrap argmax
(`{400, 1600}`) with the runner-up only `0.0105` below the peak.  The obvious
hope is that this bimodality is an artefact of resampling noise and that the
underlying curve is always unimodal — rising to `B*` and falling afterwards, so
that only *one* local maximum exists.

This file refutes that hope in the strongest reasonable form.  Even for

* perfectly orthonormal columns (all masses equal),
* unit weights, and
* columns sorted by **decreasing** per-column efficiency `a_i / s_i`,

the score curve can have a strict interior local **minimum**, hence two distinct
local maxima.  The witness is `a = (3, 1, 1)` on three orthonormal columns:

  `R²(1) = 27/33 > R²(2) = 24/33 < R²(3) = 25/33`.

So a second bump in an argmax distribution is not evidence of a defect in the
estimator: two local maxima are a genuine feature of prefix `R²` curves
(`bimodalExample_not_unimodal`).

The positive counterpart is `bimodalExample_matched_curve`: on the *same* data
the matched filter produces the strictly increasing curve `9/11, 10/11, 1`.  The
bimodality is again a property of the *weight*, not of the columns.
-/
import Combinatorics.WindowSaturationDesigns

open Finset

namespace WindowSaturation

/-- Unimodality of a curve on the window grid `{0, …, m}`: it is nondecreasing up
to some `t` and nonincreasing afterwards. -/
def UnimodalOn (f : ℕ → ℝ) (m : ℕ) : Prop :=
  ∃ t ≤ m, (∀ B, B < t → f B ≤ f (B + 1)) ∧ (∀ B, t ≤ B → B < m → f (B + 1) ≤ f B)

/-! ## Three orthonormal columns with response `(3,1,1)` -/

/-- The standard basis of `ℝ³` as a column family. -/
def e3 (i : ℕ) : Fin 3 → ℝ := fun j => if (j : ℕ) = i then 1 else 0

/-- The response `(3,1,1)`. -/
def y3 : Fin 3 → ℝ := ![3, 1, 1]

lemma dot_e3_e3 {i k : ℕ} (hi : i < 3) (hk : k < 3) :
    dot (e3 i) (e3 k) = if i = k then 1 else 0 := by
  interval_cases i <;> interval_cases k <;> simp [dot, e3, Fin.sum_univ_three]

lemma dot_e3_y3 {i : ℕ} (hi : i < 3) : dot (e3 i) y3 = if i = 0 then 3 else 1 := by
  interval_cases i <;> simp [dot, e3, y3, Fin.sum_univ_three]

lemma dot_y3_y3 : dot y3 y3 = 11 := by
  simp [dot, y3, Fin.sum_univ_three]
  norm_num

/-- Three orthonormal columns in `ℝ³` with response `(3,1,1)`. -/
def bimodalExample : Model 3 3 where
  v := e3
  y := y3
  self_pos := by
    intro i hi
    rw [dot_e3_e3 hi hi, if_pos rfl]; norm_num
  orth := by
    intro i hi k hk hik
    rw [dot_e3_e3 hi hk, if_neg hik]
  resp_pos := by rw [dot_y3_y3]; norm_num

lemma bimodalExample_s {i : ℕ} (hi : i < 3) : bimodalExample.s i = 1 := by
  show dot (e3 i) (e3 i) = 1
  rw [dot_e3_e3 hi hi, if_pos rfl]

lemma bimodalExample_a {i : ℕ} (hi : i < 3) :
    bimodalExample.a i = if i = 0 then 3 else 1 := by
  show dot (e3 i) y3 = if i = 0 then 3 else 1
  rw [dot_e3_y3 hi]

lemma bimodalExample_yy : dot bimodalExample.y bimodalExample.y = 11 := dot_y3_y3

/-- The per-column efficiencies `a i / s i` are `3, 1, 1`: sorted, decreasing.
There is no "unsorted grid" excuse for the bimodality below. -/
theorem bimodalExample_efficiency_antitone :
    bimodalExample.a 0 / bimodalExample.s 0 = 3 ∧
    bimodalExample.a 1 / bimodalExample.s 1 = 1 ∧
    bimodalExample.a 2 / bimodalExample.s 2 = 1 ∧
    bimodalExample.a 1 / bimodalExample.s 1 ≤ bimodalExample.a 0 / bimodalExample.s 0 ∧
    bimodalExample.a 2 / bimodalExample.s 2 ≤ bimodalExample.a 1 / bimodalExample.s 1 := by
  rw [bimodalExample_a (by norm_num), bimodalExample_a (by norm_num),
    bimodalExample_a (by norm_num), bimodalExample_s (by norm_num),
    bimodalExample_s (by norm_num), bimodalExample_s (by norm_num)]
  norm_num

/-- The unit-weight curve of the example: `0, 27/33, 24/33, 25/33`. -/
theorem bimodalExample_curve :
    bimodalExample.R2 (fun _ => 1) 0 = 0 ∧
    bimodalExample.R2 (fun _ => 1) 1 = 9/11 ∧
    bimodalExample.R2 (fun _ => 1) 2 = 8/11 ∧
    bimodalExample.R2 (fun _ => 1) 3 = 25/33 := by
  have ha : ∀ i < 3, bimodalExample.a i = if i = 0 then 3 else 1 :=
    fun i hi => bimodalExample_a hi
  have hs : ∀ i < 3, bimodalExample.s i = 1 := fun i hi => bimodalExample_s hi
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [Model.R2, Model.num, Model.den, bimodalExample_yy, Finset.sum_range_succ,
      Finset.sum_range_zero, ha 0 (by norm_num), ha 1 (by norm_num), ha 2 (by norm_num),
      hs 0 (by norm_num), hs 1 (by norm_num), hs 2 (by norm_num)] <;> norm_num

/-- **A strict interior local minimum.**  The curve falls from window `1` to
window `2` and rises again from `2` to `3`. -/
theorem bimodalExample_dip :
    bimodalExample.R2 (fun _ => 1) 2 < bimodalExample.R2 (fun _ => 1) 1 ∧
    bimodalExample.R2 (fun _ => 1) 2 < bimodalExample.R2 (fun _ => 1) 3 := by
  obtain ⟨-, h1, h2, h3⟩ := bimodalExample_curve
  rw [h1, h2, h3]
  constructor <;> norm_num

/-- **The window curve need not be unimodal**, even for orthonormal columns of
equal mass, unit weights and decreasing per-column efficiency.  Two local maxima
(here at the windows `1` and `3`) are possible, so a bimodal argmax distribution
is not by itself evidence of estimator noise. -/
theorem bimodalExample_not_unimodal :
    ¬ UnimodalOn (bimodalExample.R2 (fun _ => 1)) 3 := by
  rintro ⟨t, htm, hup, hdown⟩
  obtain ⟨hdip1, hdip2⟩ := bimodalExample_dip
  rcases Nat.lt_or_ge t 2 with ht | ht
  · exact absurd (hdown 2 (by omega) (by omega)) (not_le.mpr hdip2)
  · exact absurd (hup 1 (by omega)) (not_le.mpr hdip1)

/-- On the same data the **matched filter** yields the strictly increasing curve
`9/11, 10/11, 1`: the bimodality of the unit-weight curve is a property of the
weight, not of the columns. -/
theorem bimodalExample_matched_curve :
    bimodalExample.R2 bimodalExample.mf 1 = 9/11 ∧
    bimodalExample.R2 bimodalExample.mf 2 = 10/11 ∧
    bimodalExample.R2 bimodalExample.mf 3 = 1 ∧
    bimodalExample.R2 bimodalExample.mf 1 < bimodalExample.R2 bimodalExample.mf 2 ∧
    bimodalExample.R2 bimodalExample.mf 2 < bimodalExample.R2 bimodalExample.mf 3 := by
  have ha : ∀ i < 3, bimodalExample.a i = if i = 0 then 3 else 1 :=
    fun i hi => bimodalExample_a hi
  have hs : ∀ i < 3, bimodalExample.s i = 1 := fun i hi => bimodalExample_s hi
  have hE : ∀ B ≤ 3, bimodalExample.R2 bimodalExample.mf B
      = bimodalExample.E B / 11 := by
    intro B hB
    rw [Model.R2_mf bimodalExample hB, bimodalExample_yy]
  have h1 : bimodalExample.R2 bimodalExample.mf 1 = 9/11 := by
    rw [hE 1 (by norm_num)]
    simp only [Model.E, Finset.sum_range_succ, Finset.sum_range_zero,
      ha 0 (by norm_num), hs 0 (by norm_num)]
    norm_num
  have h2 : bimodalExample.R2 bimodalExample.mf 2 = 10/11 := by
    rw [hE 2 (by norm_num)]
    simp only [Model.E, Finset.sum_range_succ, Finset.sum_range_zero,
      ha 0 (by norm_num), ha 1 (by norm_num), hs 0 (by norm_num), hs 1 (by norm_num)]
    norm_num
  have h3 : bimodalExample.R2 bimodalExample.mf 3 = 1 := by
    rw [hE 3 (by norm_num)]
    simp only [Model.E, Finset.sum_range_succ, Finset.sum_range_zero,
      ha 0 (by norm_num), ha 1 (by norm_num), ha 2 (by norm_num),
      hs 0 (by norm_num), hs 1 (by norm_num), hs 2 (by norm_num)]
    norm_num
  refine ⟨h1, h2, h3, ?_, ?_⟩
  · rw [h1, h2]; norm_num
  · rw [h2, h3]; norm_num

end WindowSaturation