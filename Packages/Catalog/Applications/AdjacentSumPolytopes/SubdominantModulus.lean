import Applications.AdjacentSumPolytopes.SecantSpectrum

/-!
# The subdominant modulus crosses `1` exactly at slack `s = 3`

The previous cycle conjectured (Conjecture 5) that "the subdominant eigenvalues of the
secant family have modulus `< 1` for `s ≥ 2`", which would make the error term in the
trace asymptotics *summable*.  This file settles that sub-claim: it is **false**, and the
failure is sharp.

The subdominant eigenvalue of `adjMat s` is
`λ₁ = -1 / (2 sin(3π/(2(2s+3))))`, so `|λ₁| < 1` iff `sin(3π/(2(2s+3))) > 1/2` iff
`3π/(2(2s+3)) > π/6` iff `4s + 6 < 18` iff `s ≤ 2`.

## Main results

* `AdjSum.abs_secEigval_one` : `|λ₁| = 1/(2 sin(3π/(2(2s+3))))` for `s ≥ 1`.
* `AdjSum.abs_secEigval_one_lt_one` : `|λ₁| < 1` for `1 ≤ s ≤ 2` (the conjecture holds
  only here).
* `AdjSum.secEigval_three_one` : `λ₁ = -1` exactly when `s = 3` — the crossing point.
* `AdjSum.one_lt_abs_secEigval_one` : `|λ₁| > 1` for every `s ≥ 4`, refuting the
  conjectured summability of the error term for all large slack.

-- !-- Lab Notes -- !--
* **Experiment.** `|λ₁|` for `s = 1, …, 6`: `0.618034, 0.801938, 1.000000, 1.203616,
  1.410020, 1.618034` (against the dominant `λ₀ = 1.618034, 2.246980, 2.879385, 3.513337,
  4.148115, 4.783386`); the crossing is exact at `s = 3` because `3π/(2·9) = π/6`.
* **Analysis.** The previous cycle's numerical claim was extrapolated from `s = 2`; the
  correct statement is that only the *ratio* `|λ₁|/λ₀ = sin(π/(2(2s+3)))/sin(3π/(2(2s+3)))`
  stays below `1` (it tends to `1/3`), which is what the proved asymptotics in
  `SecantSpectrum.lean` actually use.  Summability of the error is therefore false, while
  the exponential-gap asymptotics survive.
* **Critique.** The three statements below are mutually exclusive and exhaustive over
  `s ≥ 1`, so no boundary case is hidden: the conjecture holds for `s ∈ {1, 2}`, is an
  equality at `s = 3`, and fails for all `s ≥ 4`.
-/

namespace AdjSum

/-- The modulus of the subdominant eigenvalue in closed form. -/
theorem abs_secEigval_one {s : ℕ} (hs : 1 ≤ s) :
    |secEigval s 1| = 1 / (2 * Real.sin (3 * Real.pi / (2 * (2 * (s : ℝ) + 3)))) := by
  have hden : (0 : ℝ) < 2 * (s : ℝ) + 3 := by positivity
  have hangle : secAngle s 1 / 2 = 3 * Real.pi / (2 * (2 * (s : ℝ) + 3)) := by
    unfold secAngle
    push_cast
    field_simp
    ring
  have hsinpos : 0 < Real.sin (secAngle s 1 / 2) := sin_secAngle_half_pos hs
  have hval : secEigval s 1 = -(1 / (2 * Real.sin (secAngle s 1 / 2))) := by
    unfold secEigval
    rw [pow_one]
    ring
  rw [hval, abs_neg, abs_of_pos (by positivity), hangle]

/-- The half-angle of the subdominant eigenvalue lies in the first quadrant. -/
lemma subAngle_mem {s : ℕ} :
    3 * Real.pi / (2 * (2 * (s : ℝ) + 3)) ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
  have hpi := Real.pi_pos
  have hs0 : (0 : ℝ) ≤ (s : ℝ) := Nat.cast_nonneg s
  constructor
  · have : (0 : ℝ) < 3 * Real.pi / (2 * (2 * (s : ℝ) + 3)) := by positivity
    linarith
  · rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith

lemma pi_div_six_mem : Real.pi / 6 ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
  have hpi := Real.pi_pos
  constructor <;> linarith

/-- **The conjecture holds only for `s ≤ 2`.**  For slack `1` and `2` the subdominant
eigenvalue is inside the unit circle. -/
theorem abs_secEigval_one_lt_one {s : ℕ} (hs1 : 1 ≤ s) (hs2 : s ≤ 2) :
    |secEigval s 1| < 1 := by
  have hpi := Real.pi_pos
  have hs' : (s : ℝ) ≤ 2 := by exact_mod_cast hs2
  have hs0 : (0 : ℝ) ≤ (s : ℝ) := Nat.cast_nonneg s
  have hgt : Real.pi / 6 < 3 * Real.pi / (2 * (2 * (s : ℝ) + 3)) := by
    rw [div_lt_div_iff₀ (by norm_num) (by positivity)]
    nlinarith
  have hsin : 1 / 2 < Real.sin (3 * Real.pi / (2 * (2 * (s : ℝ) + 3))) := by
    have := Real.strictMonoOn_sin pi_div_six_mem subAngle_mem hgt
    rwa [Real.sin_pi_div_six] at this
  rw [abs_secEigval_one hs1, div_lt_one (by linarith)]
  linarith

/-- **The exact crossing point.**  At slack `3` the subdominant eigenvalue is `-1`. -/
theorem secEigval_three_one : secEigval 3 1 = -1 := by
  have hangle : secAngle 3 1 / 2 = Real.pi / 6 := by
    unfold secAngle
    norm_num
    ring
  unfold secEigval
  rw [pow_one, hangle, Real.sin_pi_div_six]
  norm_num

/-- **Refutation of the summability conjecture.**  For every slack `s ≥ 4` the subdominant
eigenvalue lies *outside* the unit circle, so the error term in the trace asymptotics grows
exponentially and cannot be summable. -/
theorem one_lt_abs_secEigval_one {s : ℕ} (hs : 4 ≤ s) : 1 < |secEigval s 1| := by
  have hpi := Real.pi_pos
  have hs' : (4 : ℝ) ≤ (s : ℝ) := by exact_mod_cast hs
  have hlt : 3 * Real.pi / (2 * (2 * (s : ℝ) + 3)) < Real.pi / 6 := by
    rw [div_lt_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  have hsin : Real.sin (3 * Real.pi / (2 * (2 * (s : ℝ) + 3))) < 1 / 2 := by
    have := Real.strictMonoOn_sin subAngle_mem pi_div_six_mem hlt
    rwa [Real.sin_pi_div_six] at this
  have hpos : 0 < Real.sin (3 * Real.pi / (2 * (2 * (s : ℝ) + 3))) := by
    have hsinpos : 0 < Real.sin (secAngle s 1 / 2) := sin_secAngle_half_pos (by omega)
    have hangle : secAngle s 1 / 2 = 3 * Real.pi / (2 * (2 * (s : ℝ) + 3)) := by
      unfold secAngle
      push_cast
      field_simp
      ring
    rwa [hangle] at hsinpos
  rw [abs_secEigval_one (by omega), lt_div_iff₀ (by linarith)]
  linarith

/-- The three regimes are exhaustive: for every `s ≥ 1` the subdominant modulus is
`< 1`, `= 1` or `> 1` according as `s ≤ 2`, `s = 3` or `s ≥ 4`. -/
theorem abs_secEigval_one_trichotomy {s : ℕ} (hs : 1 ≤ s) :
    (s ≤ 2 ∧ |secEigval s 1| < 1) ∨ (s = 3 ∧ |secEigval s 1| = 1) ∨
      (4 ≤ s ∧ 1 < |secEigval s 1|) := by
  rcases Nat.lt_or_ge s 3 with h | h
  · exact Or.inl ⟨by omega, abs_secEigval_one_lt_one hs (by omega)⟩
  · rcases eq_or_lt_of_le h with heq | hlt
    · refine Or.inr (Or.inl ⟨heq.symm, ?_⟩)
      subst heq
      rw [secEigval_three_one]
      norm_num
    · exact Or.inr (Or.inr ⟨by omega, one_lt_abs_secEigval_one (by omega)⟩)

end AdjSum