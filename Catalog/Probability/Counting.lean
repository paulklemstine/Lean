import Probability.ThreeCubes.Basic

/-!
# Counting representations: `1` and `2` are exceptional

Heath-Brown's conjecture predicts that for a *generic* admissible `n` the number of
representations `n = x³ + y³ + z³` with `max(|x|,|y|,|z|) ≤ B` grows like `c_n log B`.  The
integers `1` and `2` are famously exceptional: the classical one-parameter families give
`≫ B^{1/4}` and `≫ B^{1/3}` representations respectively, which is vastly more than
logarithmic.

This file makes those lower bounds explicit and formal:

* `ThreeCubes.card_repsBox_one` : at least `2T+1` representations of `1` inside the box of
  radius `12T⁴ + 9T³ + 3T + 1`, i.e. `≫ B^{1/4}` representations of height `≤ B`;
* `ThreeCubes.card_repsBox_two` : at least `2T+1` representations of `2` inside the box of
  radius `6T³ + 6T² + 1`, i.e. `≫ B^{1/3}` representations of height `≤ B`.
-/

namespace ThreeCubes

/-- The set of representations of `n` as an ordered sum of three cubes inside the box of
radius `B`. -/
def repsBox (n : ℤ) (B : ℤ) : Finset (ℤ × ℤ × ℤ) :=
  ((Finset.Icc (-B) B) ×ˢ (Finset.Icc (-B) B) ×ˢ (Finset.Icc (-B) B)).filter
    (fun q => q.1 ^ 3 + q.2.1 ^ 3 + q.2.2 ^ 3 = n)

theorem card_Icc_neg (T : ℕ) : (Finset.Icc (-(T : ℤ)) T).card = 2 * T + 1 := by
  rw [Int.card_Icc]; omega

/-- Elementary monotonicity facts for small powers on `[-T, T]`. -/
theorem pow_bounds {t T : ℤ} (h : |t| ≤ T) :
    t ^ 4 ≤ T ^ 4 ∧ t ^ 3 ≤ T ^ 3 ∧ -T ^ 3 ≤ t ^ 3 ∧ t ^ 2 ≤ T ^ 2 ∧ t ≤ T ∧ -T ≤ t := by
  have habs := abs_nonneg t
  have h4 : |t| ^ 4 ≤ T ^ 4 := pow_le_pow_left₀ habs h 4
  have h3 : |t| ^ 3 ≤ T ^ 3 := pow_le_pow_left₀ habs h 3
  have h2 : |t| ^ 2 ≤ T ^ 2 := pow_le_pow_left₀ habs h 2
  have e4 : t ^ 4 = |t| ^ 4 := by rw [← abs_pow]; exact (abs_of_nonneg (by positivity)).symm
  have e2 : t ^ 2 = |t| ^ 2 := by rw [← abs_pow]; exact (abs_of_nonneg (by positivity)).symm
  have e3 : |t ^ 3| = |t| ^ 3 := abs_pow t 3
  have hle := abs_le.mp h
  refine ⟨by omega, ?_, ?_, by omega, hle.2, hle.1⟩
  · have : t ^ 3 ≤ |t ^ 3| := le_abs_self _
    omega
  · have : -|t ^ 3| ≤ t ^ 3 := neg_abs_le _
    omega

/-- **`1` has at least `2T+1` representations of height `≤ 12T⁴ + 9T³ + 3T + 1`.**
Since the box radius is `≍ T⁴`, this gives `≫ B^{1/4}` representations of height `≤ B`,
far more than the conjectured `log B` for generic `n`. -/
theorem card_repsBox_one (T : ℕ) :
    2 * T + 1 ≤ (repsBox 1 (12 * (T : ℤ) ^ 4 + 9 * (T : ℤ) ^ 3 + 3 * (T : ℤ) + 1)).card := by
  set B : ℤ := 12 * (T : ℤ) ^ 4 + 9 * (T : ℤ) ^ 3 + 3 * (T : ℤ) + 1 with hB
  set f : ℤ → ℤ × ℤ × ℤ := fun t => (9 * t ^ 4, 3 * t - 9 * t ^ 4, 1 - 9 * t ^ 3) with hf
  have hsub : (Finset.Icc (-(T : ℤ)) T).image f ⊆ repsBox 1 B := by
    intro q hq
    rw [Finset.mem_image] at hq
    obtain ⟨t, ht, rfl⟩ := hq
    rw [Finset.mem_Icc] at ht
    have habs : |t| ≤ (T : ℤ) := abs_le.mpr ht
    obtain ⟨b4, b3, b3', -, -, -⟩ := pow_bounds habs
    have hT0 : (0 : ℤ) ≤ (T : ℤ) := Int.natCast_nonneg T
    have hT3 : (0 : ℤ) ≤ (T : ℤ) ^ 3 := by positivity
    have hT4 : (0 : ℤ) ≤ (T : ℤ) ^ 4 := by positivity
    have ht4 : (0 : ℤ) ≤ t ^ 4 := by positivity
    simp only [repsBox, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc, hf, hB]
    refine ⟨⟨⟨by linarith, by linarith⟩, ⟨by linarith [ht.1, ht.2], by linarith [ht.1, ht.2]⟩,
      ⟨by linarith, by linarith⟩⟩, by ring⟩
  have hinj : Set.InjOn f (Finset.Icc (-(T : ℤ)) T) := by
    intro a _ b _ hab
    exact mahler_one_injective hab
  calc 2 * T + 1 = (Finset.Icc (-(T : ℤ)) T).card := (card_Icc_neg T).symm
    _ = ((Finset.Icc (-(T : ℤ)) T).image f).card := (Finset.card_image_of_injOn hinj).symm
    _ ≤ _ := Finset.card_le_card hsub

/-- **`2` has at least `2T+1` representations of height `≤ 6T³ + 6T² + 1`**, hence
`≫ B^{1/3}` representations of height `≤ B`. -/
theorem card_repsBox_two (T : ℕ) :
    2 * T + 1 ≤ (repsBox 2 (6 * (T : ℤ) ^ 3 + 6 * (T : ℤ) ^ 2 + 1)).card := by
  set B : ℤ := 6 * (T : ℤ) ^ 3 + 6 * (T : ℤ) ^ 2 + 1 with hB
  set g : ℤ → ℤ × ℤ × ℤ := fun t => (1 + 6 * t ^ 3, 1 - 6 * t ^ 3, -6 * t ^ 2) with hg
  have hsub : (Finset.Icc (-(T : ℤ)) T).image g ⊆ repsBox 2 B := by
    intro q hq
    rw [Finset.mem_image] at hq
    obtain ⟨t, ht, rfl⟩ := hq
    rw [Finset.mem_Icc] at ht
    have habs : |t| ≤ (T : ℤ) := abs_le.mpr ht
    obtain ⟨-, b3, b3', b2, -, -⟩ := pow_bounds habs
    have hT2 : (0 : ℤ) ≤ (T : ℤ) ^ 2 := by positivity
    have hT3 : (0 : ℤ) ≤ (T : ℤ) ^ 3 := by positivity
    have ht2 : (0 : ℤ) ≤ t ^ 2 := by positivity
    simp only [repsBox, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc, hg, hB]
    refine ⟨⟨⟨by linarith, by linarith⟩, ⟨by linarith, by linarith⟩,
      ⟨by linarith, by linarith⟩⟩, by ring⟩
  have hinj : Set.InjOn g (Finset.Icc (-(T : ℤ)) T) := by
    intro a _ b _ hab
    exact family_two_injective hab
  calc 2 * T + 1 = (Finset.Icc (-(T : ℤ)) T).card := (card_Icc_neg T).symm
    _ = ((Finset.Icc (-(T : ℤ)) T).image g).card := (Finset.card_image_of_injOn hinj).symm
    _ ≤ _ := Finset.card_le_card hsub

/-- The number of representations of `1` is unbounded as the box grows. -/
theorem repsBox_one_unbounded (M : ℕ) : ∃ B : ℤ, M ≤ (repsBox 1 B).card :=
  ⟨12 * (M : ℤ) ^ 4 + 9 * (M : ℤ) ^ 3 + 3 * (M : ℤ) + 1,
    le_trans (by omega) (card_repsBox_one M)⟩

end ThreeCubes