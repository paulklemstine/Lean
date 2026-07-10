/-
# The Circle of Fifths as a Hamiltonian Cycle, and Normalised Persistence Bars

This file builds directly on `BachTopology.IntervalCycles`.

Two complementary refinements of the mission:

1. **The circle of fifths as an explicit Hamiltonian cycle.**  We list the pitch
   classes in the order in which stacking perfect fifths visits them,
   `cof = [0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5]`, and prove it is a
   *duplicate-free enumeration of all twelve pitch classes*: `cof.Nodup`,
   `cof.length = 12` and `∀ x, x ∈ cof`.  Topologically this is the single
   1-cycle threading every vertex of the pitch-class space — the longest `H₁`
   generator.

2. **Normalised persistence-bar lengths.**  The mission measures `H₁` bars on a
   normalised `[0,1]` scale and predicts three regimes: Bach `> 0.5`, pop
   `0.2–0.5`, atonal `≈ 0`.  We set `barLen k = cycleLen k / 12 ∈ (0,1]` and
   prove the two decisive thresholds:
   * `fifth_barLen_gt_half : barLen 7 > 1/2` — Bach's circular harmony,
   * `tritone_barLen_lt_half : barLen 6 < 1/2` — the atonal/short-bar regime,
   together with the exact values and the fact that the fifth attains the global
   maximum `barLen 7 = 1`.
-/

import Mathlib
import Catalog.Applications.BachTopology.IntervalCycles

open scoped Classical

namespace BachTopology

/-! ### The circle of fifths as an explicit Hamiltonian cycle -/

/-- The **circle of fifths**: the pitch classes listed in the order visited by
stacking perfect fifths, `i ↦ 7·i`.  Concretely
`[0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5]`. -/
def cof : List PC := (List.range 12).map (fun i => ((7 * i : ℕ) : PC))

/-- The circle of fifths has length `12`. -/
theorem cof_length : cof.length = 12 := by decide

/-- **No pitch class is repeated.**  The circle of fifths is duplicate-free:
each of its twelve steps lands on a fresh pitch class. -/
theorem cof_nodup : cof.Nodup := by decide

/-- **The circle of fifths reaches every pitch class.** -/
theorem cof_complete : ∀ x : PC, x ∈ cof := by decide

/-- **Hamiltonicity.**  The circle of fifths is a duplicate-free enumeration of
*all* twelve pitch classes: it visits every vertex of pitch-class space exactly
once, i.e. it is a Hamiltonian cycle on the pitch-class space.  This is the
combinatorial incarnation of the single longest `H₁` generator. -/
theorem cof_hamiltonian :
    cof.Nodup ∧ cof.length = 12 ∧ (∀ x : PC, x ∈ cof) :=
  ⟨cof_nodup, cof_length, cof_complete⟩

/-- The circle of fifths, viewed as a set of pitch classes, is everything. -/
theorem cof_toFinset : cof.toFinset = (Finset.univ : Finset PC) := by
  apply Finset.eq_univ_of_forall
  intro x
  simpa [List.mem_toFinset] using cof_complete x

/-! ### Normalised persistence-bar lengths -/

/-- The **normalised persistence-bar length** of the interval `k`: the harmonic
cycle length rescaled into `[0,1]` by the octave's twelve pitch classes.  This is
the mission's normalised `H₁`-bar length. -/
noncomputable def barLen (k : ℕ) : ℚ := (cycleLen k : ℚ) / 12

/-- Every normalised bar length lies in `[0,1]`; the longest possible bar has
length `1`. -/
theorem barLen_le_one (k : ℕ) : barLen k ≤ 1 := by
  unfold barLen
  rw [div_le_one (by norm_num)]
  have := cycleLen_le k
  exact_mod_cast this

/-- **Bach's bar is maximal:** the circle of fifths attains the top of the
scale, `barLen 7 = 1`. -/
theorem fifth_barLen : barLen 7 = 1 := by
  unfold barLen; rw [fifth_cycleLen]; norm_num

/-- **Bach regime (`> 0.5`).**  The circle of fifths produces a persistence bar
longer than half the scale — the mission's threshold for genuinely circular
harmonic motion. -/
theorem fifth_barLen_gt_half : barLen 7 > 1 / 2 := by
  rw [fifth_barLen]; norm_num

/-- Exact value for the tritone. -/
theorem tritone_barLen : barLen 6 = 1 / 6 := by
  unfold barLen; rw [tritone_cycleLen]; norm_num

/-- **Atonal / short-bar regime (`< 0.5`).**  The tritone's harmonic cycle dies
quickly: its normalised bar sits well below the half-scale threshold. -/
theorem tritone_barLen_lt_half : barLen 6 < 1 / 2 := by
  rw [tritone_barLen]; norm_num

/-- **The circle of fifths dominates the tritone.**  Bach's fundamental cycle is
strictly longer than the tritone's, separating the two regimes. -/
theorem fifth_barLen_gt_tritone : barLen 6 < barLen 7 := by
  rw [fifth_barLen, tritone_barLen]; norm_num

/-- **The fifth's bar is globally maximal** among all intervals: no interval
produces a longer normalised persistence bar than the circle of fifths. -/
theorem fifth_barLen_maximal (k : ℕ) : barLen k ≤ barLen 7 := by
  rw [fifth_barLen]; exact barLen_le_one k

end BachTopology