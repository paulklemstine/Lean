import Catalog.Bridges.BerggrenWalkDrift
import Catalog.Bridges.BerggrenShiftErgodicity

/-!
# Almost sure escape of the Berggren random walk to the boundary

`BerggrenWalkDrift` bounds the *expected* hyperbolic displacement of the Berggren walk after
`n` steps.  Here we upgrade those bounds from expectation to *almost sure* statements along a
random boundary ray, using the strong law of large numbers for the letters
(`strongLaw_letters`).

The random ray `x : Bdry` is distributed according to the harmonic measure `bernoulli P`, and
its depth-`n` prefix labels a node `prefixWord n x` of the Berggren tree.

## Main results

* `ae_freq_middle` : almost surely the frequency of the middle Berggren move in the first `n`
  letters converges to `p₂`.
* `ae_drift_asymptotic` : **almost sure drift sandwich.**  For every `ε > 0`, eventually
  `p₂ log 2 − ε ≤ d(o, prefix_n)/n ≤ log(1+√2) + ε`.
* `ae_tendsto_hdist_atTop` : consequently the walk almost surely escapes to infinity —
  the harmonic measure really is carried by the boundary at infinity, not by the tree.
-/

namespace BerggrenHarmonic

open MeasureTheory Filter HyperbolicBerggrenGeodesics
open scoped Topology

/-- The node of the Berggren tree reached by the first `n` letters of a boundary ray. -/
def prefixWord (n : ℕ) (x : Bdry) : List Move := (List.range n).map (fun i => moveOf (x i))

@[simp] lemma prefixWord_length (n : ℕ) (x : Bdry) : (prefixWord n x).length = n := by
  simp [prefixWord]

/-- The number of middle moves in a prefix is the number of letters equal to `1`. -/
lemma countM_prefixWord (n : ℕ) (x : Bdry) :
    ((countM (prefixWord n x) : ℕ) : ℝ)
      = ∑ i ∈ Finset.range n, (if x i = 1 then (1 : ℝ) else 0) := by
  induction n with
  | zero => simp [prefixWord, countM]
  | succ m ih =>
      rw [Finset.sum_range_succ, ← ih]
      simp only [prefixWord, List.range_succ, List.map_append]
      rw [countM, List.count_append]
      push_cast
      congr 1
      by_cases h : x m = 1
      · simp [h, moveOf]
      · have hne : moveOf (x m) ≠ Move.M := by
          revert h
          generalize x m = a
          fin_cases a <;> simp [moveOf]
        simp [h, hne]

/-- **Almost sure frequency of the middle move.** -/
theorem ae_freq_middle (P : ProbVec) :
    ∀ᵐ x ∂(bernoulli P),
      Tendsto (fun n : ℕ => ((countM (prefixWord n x) : ℕ) : ℝ) / n) atTop (𝓝 (P.p 1)) := by
  have hsum : ∑ a : Letter, P.p a * (if a = 1 then (1 : ℝ) else 0) = P.p 1 := by
    simp
  have h := strongLaw_letters P (fun b : Letter => if b = 1 then (1 : ℝ) else 0)
  rw [hsum] at h
  filter_upwards [h] with x hx
  simpa only [countM_prefixWord] using hx

/-! ## From the deterministic catalog bounds to almost sure drift -/

lemma hdist_prefix_lower (n : ℕ) (x : Bdry) :
    ((countM (prefixWord n x) : ℕ) : ℝ) * Real.log 2 ≤ hdist (prefixWord n x) := by
  have h := (berggren_word_two_sided (prefixWord n x)).1
  have hlog2 : (0 : ℝ) ≤ Real.log 2 := (Real.log_pos (by norm_num)).le
  have : ((countM (prefixWord n x) : ℕ) : ℝ) * Real.log 2
      ≤ (((countM (prefixWord n x) : ℕ) : ℝ) + 1) * Real.log 2 := by nlinarith
  exact this.trans h

lemma hdist_prefix_upper (n : ℕ) (x : Bdry) :
    hdist (prefixWord n x) ≤ ((n : ℝ) + 1) * Real.log silver + Real.log 2 := by
  have h := (berggren_word_two_sided (prefixWord n x)).2
  rwa [prefixWord_length] at h

/-- **Almost sure drift sandwich.**  Along almost every ray of the harmonic measure the
hyperbolic speed is asymptotically between `p₂ log 2` and the silver exponent
`log(1+√2)`. -/
theorem ae_drift_asymptotic (P : ProbVec) :
    ∀ᵐ x ∂(bernoulli P), ∀ ε > (0 : ℝ), ∀ᶠ n : ℕ in atTop,
      P.p 1 * Real.log 2 - ε ≤ hdist (prefixWord n x) / n ∧
        hdist (prefixWord n x) / n ≤ Real.log silver + ε := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  filter_upwards [ae_freq_middle P] with x hx ε hε
  -- the lower bound comes from the strong law
  have hδ : (0 : ℝ) < ε / Real.log 2 := div_pos hε hlog2
  have h1 : ∀ᶠ n : ℕ in atTop,
      P.p 1 - ε / Real.log 2 < ((countM (prefixWord n x) : ℕ) : ℝ) / n := by
    have := hx.eventually (eventually_gt_nhds (show P.p 1 - ε / Real.log 2 < P.p 1 by linarith))
    exact this
  -- the upper bound is deterministic: the additive constant dies in the limit
  have h2 : ∀ᶠ n : ℕ in atTop, (Real.log silver + Real.log 2) / n ≤ ε := by
    have htend : Tendsto (fun n : ℕ => (Real.log silver + Real.log 2) / n) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    exact htend.eventually (eventually_le_nhds hε)
  filter_upwards [h1, h2, eventually_gt_atTop 0] with n hn1 hn2 hn0
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
  constructor
  · have hlow := hdist_prefix_lower n x
    rw [le_div_iff₀ hnR]
    have hlt : (P.p 1 - ε / Real.log 2) * n < ((countM (prefixWord n x) : ℕ) : ℝ) := by
      rw [lt_div_iff₀ hnR] at hn1; linarith
    have hmul : (P.p 1 - ε / Real.log 2) * n * Real.log 2
        ≤ ((countM (prefixWord n x) : ℕ) : ℝ) * Real.log 2 :=
      mul_le_mul_of_nonneg_right hlt.le hlog2.le
    have key : (P.p 1 * Real.log 2 - ε) * n = (P.p 1 - ε / Real.log 2) * n * Real.log 2 := by
      field_simp
    rw [key]
    exact hmul.trans hlow
  · have hup := hdist_prefix_upper n x
    rw [div_le_iff₀ hnR]
    rw [div_le_iff₀ hnR] at hn2
    nlinarith

/-- **The Berggren random walk almost surely escapes to infinity** (as soon as the middle move
has positive probability, which holds for every `ProbVec`): the hyperbolic distance from the
base point to the depth-`n` node tends to `+∞`. -/
theorem ae_tendsto_hdist_atTop (P : ProbVec) :
    ∀ᵐ x ∂(bernoulli P), Tendsto (fun n : ℕ => hdist (prefixWord n x)) atTop atTop := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  filter_upwards [ae_freq_middle P] with x hx
  have hp : (0 : ℝ) < P.p 1 := P.pos 1
  have h1 : ∀ᶠ n : ℕ in atTop,
      P.p 1 / 2 < ((countM (prefixWord n x) : ℕ) : ℝ) / n :=
    hx.eventually (eventually_gt_nhds (by linarith))
  refine tendsto_atTop_mono' atTop ?_
    (Filter.tendsto_atTop_atTop.2 (fun b => ?_) :
      Tendsto (fun n : ℕ => (n : ℝ) * (P.p 1 / 2 * Real.log 2)) atTop atTop)
  · filter_upwards [h1, eventually_gt_atTop 0] with n hn1 hn0
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
    have hlow := hdist_prefix_lower n x
    have : (P.p 1 / 2) * n < ((countM (prefixWord n x) : ℕ) : ℝ) := by
      rw [lt_div_iff₀ hnR] at hn1; linarith
    nlinarith
  · obtain ⟨m, hm⟩ := exists_nat_gt (b / (P.p 1 / 2 * Real.log 2))
    refine ⟨m, fun k hk => ?_⟩
    have hc : (0 : ℝ) < P.p 1 / 2 * Real.log 2 := by positivity
    have hkR : (m : ℝ) ≤ k := by exact_mod_cast hk
    have : b / (P.p 1 / 2 * Real.log 2) < (k : ℝ) := lt_of_lt_of_le hm hkR
    rw [div_lt_iff₀ hc] at this
    nlinarith

end BerggrenHarmonic