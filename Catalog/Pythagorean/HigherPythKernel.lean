import Pythagorean.ConicKernelDefect

/-!
# Kernel spectra in higher dimension: the cone `x² + y² + z² = w²`

`Pythagorean.PythagoreanKernelSpectrum` shows that the plane Pythagorean cone realises
`4` of the `Nat.bell 3 = 5` equality patterns of a triple, a *defect* of `1`.  This file
computes the next case completely: the cone `x² + y² + z² = w²` realises exactly `8` of the
`Nat.bell 4 = 15` patterns of a quadruple, a defect of `7`.

The whole computation rests on one structural theorem, valid in **every** dimension:

* `HigherPyth.legs_zero_of_hyp_eq_leg` — if `∑ᵢ xᵢ² = y²` and the hypotenuse `y` equals one
  of the legs `x j`, then *every other leg vanishes*.  Consequently
  (`HigherPyth.legs_eq_of_hyp_eq_leg`) all remaining legs are equal, so no realised pattern
  can both merge the hypotenuse with a leg and separate two other legs.

This single rigidity statement kills `6` of the `7` missing patterns; the seventh,
"all three legs equal, hypotenuse apart", is killed by the classical fact that `3` is not a
square (the dimension-dependence already isolated in
`PythagoreanKernel.constant_legs_dim_two_three_four`).

Main results.

* `HigherPyth.legs_zero_of_hyp_eq_leg`, `HigherPyth.legs_eq_of_hyp_eq_leg` (all dimensions).
* `HigherPyth.pyth3_kernel_spectrum` — the exact spectrum, an explicit list of `8` patterns.
* `HigherPyth.card_pyth3Spectrum` and `HigherPyth.pyth3_defect` — `8` realised, defect `7`.
* `HigherPyth.defect_strictly_increases` — the defect jumps from `1` to `7` between
  dimension `2` and dimension `3`, so it is a genuinely dimension-sensitive invariant.
-/

open KernelPattern PythagoreanKernel

namespace HigherPyth

/-! ## Hypotenuse–leg rigidity in arbitrary dimension -/

/-- **Rigidity.**  If `∑ᵢ xᵢ² = y²` and some leg equals the hypotenuse, then every other leg
is zero. -/
theorem legs_zero_of_hyp_eq_leg {k : ℕ} {x : Fin k → ℕ} {y : ℕ} {j : Fin k}
    (h : ∑ i, x i ^ 2 = y ^ 2) (hj : x j = y) : ∀ i, i ≠ j → x i = 0 := by
  have hsum : (∑ i ∈ Finset.univ.erase j, x i ^ 2) + x j ^ 2 = x j ^ 2 := by
    rw [Finset.sum_erase_add _ _ (Finset.mem_univ j), h, hj]
  have hz : (∑ i ∈ Finset.univ.erase j, x i ^ 2) = 0 := by omega
  intro i hi
  have := (Finset.sum_eq_zero_iff.1 hz) i (Finset.mem_erase.2 ⟨hi, Finset.mem_univ i⟩)
  exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this

/-- The pattern-level consequence: once the hypotenuse meets a leg, all the other legs are
forced into a single block. -/
theorem legs_eq_of_hyp_eq_leg {k : ℕ} {x : Fin k → ℕ} {y : ℕ} {j : Fin k}
    (h : ∑ i, x i ^ 2 = y ^ 2) (hj : x j = y) {i i' : Fin k} (hi : i ≠ j) (hi' : i' ≠ j) :
    x i = x i' := by
  rw [legs_zero_of_hyp_eq_leg h hj i hi, legs_zero_of_hyp_eq_leg h hj i' hi']

/-! ## The three-dimensional cone -/

/-- Solutions of `x² + y² + z² = w²`, packaged as a quadruple. -/
def IsPyth3 (t : Fin 4 → ℕ) : Prop := t 0 ^ 2 + t 1 ^ 2 + t 2 ^ 2 = t 3 ^ 2

instance : DecidablePred IsPyth3 :=
  fun t => inferInstanceAs (Decidable (t 0 ^ 2 + t 1 ^ 2 + t 2 ^ 2 = t 3 ^ 2))

theorem isPyth3_iff (a b c d : ℕ) :
    IsPyth3 ![a, b, c, d] ↔ a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := Iff.rfl

/-- The rigidity theorem, transported to the concrete quadruple form: if `w` equals the
`j`-th leg then the two remaining legs vanish. -/
theorem pyth3_rigidity {t : Fin 4 → ℕ} (h : IsPyth3 t) :
    (t 3 = t 0 → t 1 = 0 ∧ t 2 = 0) ∧ (t 3 = t 1 → t 0 = 0 ∧ t 2 = 0) ∧
      (t 3 = t 2 → t 0 = 0 ∧ t 1 = 0) := by
  rw [IsPyth3] at h
  refine ⟨fun h3 => ?_, fun h3 => ?_, fun h3 => ?_⟩ <;> rw [h3] at h <;>
    constructor <;>
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 (by omega)

/-! ## The 15 patterns of a quadruple -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 1000000 in
theorem patterns_four_eq :
    Patterns 4 = ({![0, 0, 0, 0], ![0, 0, 0, 3], ![0, 0, 2, 0], ![0, 0, 2, 2],
      ![0, 0, 2, 3], ![0, 1, 0, 0], ![0, 1, 0, 1], ![0, 1, 0, 3], ![0, 1, 1, 0], ![0, 1, 1, 1],
      ![0, 1, 1, 3], ![0, 1, 2, 0], ![0, 1, 2, 1], ![0, 1, 2, 2], ![0, 1, 2, 3]} :
        Finset (Fin 4 → Fin 4)) := by
  rw [patterns_eq_filter]; decide

/-! ## The seven blocked patterns -/

theorem not_isSquare_three : ¬ IsSquare 3 := by
  rintro ⟨r, hr⟩
  have : r < 2 := by nlinarith
  interval_cases r <;> omega

/-- The pattern "all three legs equal, hypotenuse apart" is blocked because `3` is not a
perfect square. -/
theorem blocked_0003 {t : Fin 4 → ℕ} (h : IsPyth3 t) : canon t ≠ ![0, 0, 0, 3] := by
  intro hcan
  have hk := (ConicKernel.canon_eq_iff_ker (by decide)).1 hcan
  have h01 : t 0 = t 1 := (hk 0 1).2 (by decide)
  have h02 : t 0 = t 2 := (hk 0 2).2 (by decide)
  have h03 : t 0 ≠ t 3 := fun hc => by simpa using (hk 0 3).1 hc
  rw [IsPyth3, ← h01, ← h02] at h
  have hkey : 3 * t 0 ^ 2 = t 3 ^ 2 := by omega
  rcases Nat.eq_zero_or_pos (t 0) with h0 | h0
  · have : t 3 ^ 2 = 0 := by rw [← hkey, h0]; ring
    exact h03 (by rw [h0, pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this])
  · exact not_isSquare_three (isSquare_of_mul_sq_eq_sq h0.ne' hkey)

/-- Six patterns are blocked by rigidity alone: whenever the hypotenuse joins a leg, the
other two legs are both zero, hence in the same block. -/
theorem blocked_of_hyp_merge {t : Fin 4 → ℕ} (h : IsPyth3 t) :
    canon t ≠ ![0, 0, 2, 0] ∧ canon t ≠ ![0, 1, 0, 0] ∧ canon t ≠ ![0, 1, 1, 1] ∧
      canon t ≠ ![0, 1, 2, 0] ∧ canon t ≠ ![0, 1, 2, 1] ∧ canon t ≠ ![0, 1, 2, 2] := by
  obtain ⟨r0, r1, r2⟩ := pyth3_rigidity h
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> intro hcan <;>
    have hk := (ConicKernel.canon_eq_iff_ker (by decide)).1 hcan
  · obtain ⟨h1, h2⟩ := r0 ((hk 3 0).2 (by decide))
    exact absurd ((hk 1 2).1 (by rw [h1, h2])) (by decide)
  · obtain ⟨h1, h2⟩ := r0 ((hk 3 0).2 (by decide))
    exact absurd ((hk 1 2).1 (by rw [h1, h2])) (by decide)
  · obtain ⟨h1, h2⟩ := r1 ((hk 3 1).2 (by decide))
    exact absurd ((hk 0 2).1 (by rw [h1, h2])) (by decide)
  · obtain ⟨h1, h2⟩ := r0 ((hk 3 0).2 (by decide))
    exact absurd ((hk 1 2).1 (by rw [h1, h2])) (by decide)
  · obtain ⟨h1, h2⟩ := r1 ((hk 3 1).2 (by decide))
    exact absurd ((hk 0 2).1 (by rw [h1, h2])) (by decide)
  · obtain ⟨h1, h2⟩ := r2 ((hk 3 2).2 (by decide))
    exact absurd ((hk 0 1).1 (by rw [h1, h2])) (by decide)

/-! ## The spectrum -/

/-- The eight patterns realised by `x² + y² + z² = w²`. -/
def pyth3Spectrum : Finset (Fin 4 → Fin 4) :=
  {![0, 0, 0, 0], ![0, 0, 2, 2], ![0, 0, 2, 3], ![0, 1, 0, 1], ![0, 1, 0, 3], ![0, 1, 1, 0],
    ![0, 1, 1, 3], ![0, 1, 2, 3]}

/-- **Kernel spectrum of the three-dimensional Pythagorean cone.**  A pattern of a
quadruple is realised by a solution of `x² + y² + z² = w²` iff it is one of the eight
patterns listed in `pyth3Spectrum`. -/
theorem pyth3_kernel_spectrum (p : Fin 4 → Fin 4) :
    (∃ t : Fin 4 → ℕ, IsPyth3 t ∧ canon t = p) ↔ p ∈ pyth3Spectrum := by
  constructor
  · rintro ⟨t, ht, rfl⟩
    have hmem : canon t ∈ Patterns 4 := canon_mem_patterns t
    rw [patterns_four_eq] at hmem
    obtain ⟨b1, b2, b3, b4, b5, b6⟩ := blocked_of_hyp_merge ht
    have b0 := blocked_0003 ht
    simp only [pyth3Spectrum, Finset.mem_insert, Finset.mem_singleton] at hmem ⊢
    rcases hmem with h | h | h | h | h | h | h | h | h | h | h | h | h | h | h
    · exact Or.inl h
    · exact absurd h b0
    · exact absurd h b1
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr (Or.inl h))
    · exact absurd h b2
    · exact Or.inr (Or.inr (Or.inr (Or.inl h)))
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h))))
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h)))))
    · exact absurd h b3
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h))))))
    · exact absurd h b4
    · exact absurd h b5
    · exact absurd h b6
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr h))))))
  · intro hp
    simp only [pyth3Spectrum, Finset.mem_insert, Finset.mem_singleton] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact ⟨![0, 0, 0, 0], by decide, by decide⟩
    · exact ⟨![0, 0, 1, 1], by decide, by decide⟩
    · exact ⟨![2, 2, 1, 3], by decide, by decide⟩
    · exact ⟨![0, 1, 0, 1], by decide, by decide⟩
    · exact ⟨![2, 1, 2, 3], by decide, by decide⟩
    · exact ⟨![1, 0, 0, 1], by decide, by decide⟩
    · exact ⟨![1, 2, 2, 3], by decide, by decide⟩
    · exact ⟨![2, 3, 6, 7], by decide, by decide⟩

set_option maxRecDepth 100000 in
theorem card_pyth3Spectrum : pyth3Spectrum.card = 8 := by decide

set_option maxRecDepth 1000000 in
theorem pyth3Spectrum_ssubset : pyth3Spectrum ⊂ Patterns 4 := by
  rw [patterns_four_eq, pyth3Spectrum]
  decide

/-- The defect in dimension three is `7 = Nat.bell 4 - 8`. -/
theorem pyth3_defect : (Patterns 4).card - pyth3Spectrum.card = 7 := by
  rw [card_patterns_four, card_pyth3Spectrum]

theorem pyth3_defect_eq_bell_sub : (Patterns 4).card - pyth3Spectrum.card = Nat.bell 4 - 8 := by
  rw [card_patterns_four, card_pyth3Spectrum, bell_four']

/-- **The kernel defect is dimension-sensitive.**  Passing from `x² + y² = z²` to
`x² + y² + z² = w²` the defect jumps from `1` to `7`, even though the number of realised
patterns only doubles (`4` to `8`) while the number of available patterns triples
(`5` to `15`). -/
theorem defect_strictly_increases :
    (Patterns 3).card - pythSpectrum.card = 1 ∧
      (Patterns 4).card - pyth3Spectrum.card = 7 ∧
      (Patterns 3).card - pythSpectrum.card < (Patterns 4).card - pyth3Spectrum.card := by
  refine ⟨by rw [card_patterns_three, card_pythSpectrum], pyth3_defect, ?_⟩
  rw [card_patterns_three, card_pythSpectrum, card_patterns_four, card_pyth3Spectrum]
  norm_num

/-- The realised counts in dimensions `2` and `3` are `4` and `8`. -/
theorem realised_counts : pythSpectrum.card = 4 ∧ pyth3Spectrum.card = 8 :=
  ⟨card_pythSpectrum, card_pyth3Spectrum⟩

end HigherPyth