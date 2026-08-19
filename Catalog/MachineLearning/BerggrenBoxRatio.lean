import MachineLearning.BerggrenBoxDensity

/-!
# The two ratios of the mission statement, made exact

`MachineLearning.BerggrenBoxDensity` establishes the set-level facts.  This file turns them
into the two *ratio* statements of the mission claim, as honest statements about real
numbers, and transports the `Θ(H)` bound and the vanishing-density statement from the
Berggren tree to the full set of primitive Pythagorean triples in the cube.

## Main results

* `boxNode_card_pos` : the cube is never empty of Berggren nodes once `H ≥ 5`, so both
  ratios below are genuinely defined.
* `boxPPT_card_theta` : `#(boxPPT H) = Θ(H)` as well, with explicit constants
  `H ≤ 64 · #(boxPPT H)` and `#(boxPPT H) ≤ 2H`.
* `boxPPT_density_zero` : primitive Pythagorean triples are a vanishing fraction of the
  cube, `#(boxPPT H)/H³ → 0`.
* `single_seed_ratio` : with the single seed `(3,4,5)` the ratio to the primitive
  Pythagorean count is **exactly `1/2`** for every `H ≥ 5` — the `(1 - o(1))` reading of
  the mission statement is therefore false for one seed.
* `two_seed_ratio` : with both seeds `(3,4,5)` and `(4,3,5)` the ratio is **exactly `1`**
  for every `H ≥ 5` — stronger than `1 - o(1)`.
-/

namespace BerggrenStars

open Finset Filter Topology

/-- The seed `(3,4,5)` lies in the cube as soon as `H ≥ 5`. -/
theorem root_mem_boxNode {H : ℕ} (hH : 5 ≤ H) : ((3 : ℤ), (4 : ℤ), (5 : ℤ)) ∈ boxNode H := by
  have h5 : (5 : ℤ) ≤ (H : ℤ) := by exact_mod_cast hH
  rw [boxNode, Finset.mem_filter]
  refine ⟨?_, by norm_num, by norm_num, by norm_num, by norm_num, ?_, by decide⟩
  · rw [mem_box]
    exact ⟨⟨by norm_num, by linarith⟩, ⟨by norm_num, by linarith⟩, ⟨by norm_num, h5⟩⟩
  · decide

/-- Consequently the Berggren count in the cube is positive for `H ≥ 5`. -/
theorem boxNode_card_pos {H : ℕ} (hH : 5 ≤ H) : 0 < (boxNode H).card :=
  Finset.card_pos.mpr ⟨_, root_mem_boxNode hH⟩

/-- ... and so is the primitive Pythagorean count. -/
theorem boxPPT_card_pos {H : ℕ} (hH : 5 ≤ H) : 0 < (boxPPT H).card := by
  rw [card_boxPPT_eq_two_mul]
  have := boxNode_card_pos hH
  omega

/-! ### `Θ(H)` for the primitive Pythagorean triples of the cube -/

/-- **`Θ(H)` for the full primitive Pythagorean count.**  Doubling the Berggren estimate,
`#(boxPPT H)` is squeezed between `H/64` and `2H`. -/
theorem boxPPT_card_theta (H : ℕ) (hH : 32 ≤ H) :
    H ≤ 64 * (boxPPT H).card ∧ (boxPPT H).card ≤ 2 * H := by
  obtain ⟨hlo, hhi⟩ := boxNode_card_theta H hH
  rw [card_boxPPT_eq_two_mul]
  omega

/-- **Primitive Pythagorean triples are a vanishing fraction of the cube.** -/
theorem boxPPT_density_zero :
    Tendsto (fun H : ℕ => ((boxPPT H).card : ℝ) / (H : ℝ) ^ 3) atTop (𝓝 0) := by
  have h2 : Tendsto (fun H : ℕ => 2 * (((boxNode H).card : ℝ) / (H : ℝ) ^ 3)) atTop (𝓝 (2 * 0)) :=
    boxNode_density_zero.const_mul 2
  rw [mul_zero] at h2
  refine h2.congr fun H => ?_
  rw [card_boxPPT_eq_two_mul]
  push_cast
  ring

/-! ### The two ratios -/

/-- **One seed gives exactly one half.**  For every `H ≥ 5` the number of triples of the
cube generated from the single seed `(3,4,5)` is exactly half the number of primitive
Pythagorean triples of the cube.  In particular the ratio does *not* tend to `1`. -/
theorem single_seed_ratio {H : ℕ} (hH : 5 ≤ H) :
    ((boxNode H).card : ℝ) / ((boxPPT H).card : ℝ) = 1 / 2 := by
  have hpos : (0 : ℝ) < ((boxNode H).card : ℝ) := by
    exact_mod_cast boxNode_card_pos hH
  have hcard : ((boxPPT H).card : ℝ) = 2 * ((boxNode H).card : ℝ) := by
    exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) (card_boxPPT_eq_two_mul H)
  rw [hcard]
  field_simp

/-- **Two seeds give exactly one.**  For every `H ≥ 5` the triples of the cube generated
from the two seeds `(3,4,5)` and `(4,3,5)` are *precisely* the primitive Pythagorean
triples of the cube, so the ratio is exactly `1` — an exact identity rather than
`1 - o(1)`. -/
theorem two_seed_ratio {H : ℕ} (hH : 5 ≤ H) :
    (((boxNode H ∪ boxNodeSwap H).card : ℝ)) / ((boxPPT H).card : ℝ) = 1 := by
  have hpos : (0 : ℝ) < ((boxPPT H).card : ℝ) := by
    exact_mod_cast boxPPT_card_pos hH
  rw [card_boxBerggren_eq_card_boxPPT]
  exact div_self (ne_of_gt hpos)

end BerggrenStars