import Catalog.Novelty.CollatzSpectralNormalized

/-!
# The arithmetic of the resonance sets of the `a n + 1` maps

`Catalog/Novelty/CollatzSpectralNormalized.lean` shows that the normalized
transform of the `a n + 1` map converges to `limitAmp a ω`, and that it vanishes
exactly on the *resonance set*

`R a = {ω : (2a - 1) ω ∈ 2ℤ + 1}`.

This file studies the arithmetic of these sets.  The picture that emerges is a
clean dichotomy:

* every multiplier resonates at every odd integer frequency
  (`limitAmp_odd_int`) — these carry no information about `a`;
* off the odd integers the resonance sets are genuinely different, and their
  pairwise intersections are governed by a linear Diophantine condition.  For
  the three classical multipliers we compute the intersections exactly
  (`common_resonance_three_five`, `common_resonance_three_seven`,
  `common_resonance_five_seven`): they contain *nothing but* the trivial odd
  integers.

Thus any spectral discriminator between the `3n+1`, `5n+1` and `7n+1` maps must
be read off at non-integer frequencies; the behaviour near frequency `0`, or at
any integer frequency, is identical for all three maps
(`limitAmp_int_indep_of_multiplier`).
-/

namespace CollatzSpectral

open Filter Complex
open scoped Real Topology

/-- Every multiplier resonates at every odd integer frequency. -/
theorem limitAmp_odd_int (a : ℕ) (t : ℤ) : limitAmp a (2 * (t : ℝ) + 1) = 0 := by
  rw [limitAmp_eq_zero_iff]
  refine ⟨(2 * (a : ℤ) - 1) * t + ((a : ℤ) - 1), ?_⟩
  push_cast
  ring

/-- At an *even* integer frequency the amplitude has modulus `1` for every
multiplier: the transform is then as large as it can possibly be. -/
theorem norm_limitAmp_even_int (a : ℕ) (t : ℤ) : ‖limitAmp a (2 * (t : ℝ))‖ = 1 := by
  rw [norm_limitAmp]
  have h : Real.pi * ((a : ℝ) - 1 / 2) * (2 * (t : ℝ))
      = ((2 * (a : ℤ) - 1) * t : ℤ) * Real.pi := by
    push_cast
    ring
  rw [h, Real.cos_int_mul_pi, abs_zpow]
  norm_num

/-- Consequently the amplitude at integer frequencies does not depend on the
multiplier at all: no discriminator can live at integer frequencies. -/
theorem limitAmp_int_indep_of_multiplier (a b : ℕ) (t : ℤ) :
    ‖limitAmp a (t : ℝ)‖ = ‖limitAmp b (t : ℝ)‖ := by
  rcases Int.even_or_odd t with ⟨s, hs⟩ | ⟨s, hs⟩
  · have h : ((t : ℤ) : ℝ) = 2 * (s : ℝ) := by rw [hs]; push_cast; ring
    rw [h, norm_limitAmp_even_int, norm_limitAmp_even_int]
  · have h : ((t : ℤ) : ℝ) = 2 * (s : ℝ) + 1 := by rw [hs]; push_cast; ring
    rw [h, limitAmp_odd_int, limitAmp_odd_int]

/-- A convenient reformulation of the resonance condition for two multipliers. -/
lemma resonance_pair_diophantine (a b : ℕ) (ω : ℝ)
    (ha : ∃ m : ℤ, (2 * (a : ℝ) - 1) * ω = 2 * m + 1)
    (hb : ∃ k : ℤ, (2 * (b : ℝ) - 1) * ω = 2 * k + 1) :
    ∃ m k : ℤ, (2 * (b : ℤ) - 1) * (2 * m + 1) = (2 * (a : ℤ) - 1) * (2 * k + 1) ∧
      (2 * (a : ℝ) - 1) * ω = 2 * m + 1 := by
  obtain ⟨m, hm⟩ := ha
  obtain ⟨k, hk⟩ := hb
  refine ⟨m, k, ?_, hm⟩
  have hR : (2 * (b : ℝ) - 1) * (2 * (m : ℝ) + 1) = (2 * (a : ℝ) - 1) * (2 * (k : ℝ) + 1) := by
    rw [← hm, ← hk]
    ring
  exact_mod_cast hR

/-- **The `3n+1` and `5n+1` maps share only the trivial resonances.**  Their
common spectral gaps occur exactly at odd integer frequencies. -/
theorem common_resonance_three_five (ω : ℝ) :
    (limitAmp 3 ω = 0 ∧ limitAmp 5 ω = 0) ↔ ∃ t : ℤ, ω = 2 * (t : ℝ) + 1 := by
  constructor
  · rintro ⟨h3, h5⟩
    obtain ⟨m, k, hzz, hm⟩ := resonance_pair_diophantine 3 5 ω
      ((limitAmp_eq_zero_iff 3 ω).mp h3) ((limitAmp_eq_zero_iff 5 ω).mp h5)
    push_cast at hzz hm
    refine ⟨(m - 2) / 5, ?_⟩
    have hint : 2 * m + 1 = 5 * (2 * ((m - 2) / 5) + 1) := by omega
    have hR : 2 * (m : ℝ) + 1 = 5 * (2 * (((m - 2) / 5 : ℤ) : ℝ) + 1) := by exact_mod_cast hint
    linarith
  · rintro ⟨t, rfl⟩
    exact ⟨limitAmp_odd_int 3 t, limitAmp_odd_int 5 t⟩

/-- The `3n+1` and `7n+1` maps share only the trivial resonances. -/
theorem common_resonance_three_seven (ω : ℝ) :
    (limitAmp 3 ω = 0 ∧ limitAmp 7 ω = 0) ↔ ∃ t : ℤ, ω = 2 * (t : ℝ) + 1 := by
  constructor
  · rintro ⟨h3, h7⟩
    obtain ⟨m, k, hzz, hm⟩ := resonance_pair_diophantine 3 7 ω
      ((limitAmp_eq_zero_iff 3 ω).mp h3) ((limitAmp_eq_zero_iff 7 ω).mp h7)
    push_cast at hzz hm
    refine ⟨(m - 2) / 5, ?_⟩
    have hint : 2 * m + 1 = 5 * (2 * ((m - 2) / 5) + 1) := by omega
    have hR : 2 * (m : ℝ) + 1 = 5 * (2 * (((m - 2) / 5 : ℤ) : ℝ) + 1) := by exact_mod_cast hint
    linarith
  · rintro ⟨t, rfl⟩
    exact ⟨limitAmp_odd_int 3 t, limitAmp_odd_int 7 t⟩

/-- The `5n+1` and `7n+1` maps share only the trivial resonances. -/
theorem common_resonance_five_seven (ω : ℝ) :
    (limitAmp 5 ω = 0 ∧ limitAmp 7 ω = 0) ↔ ∃ t : ℤ, ω = 2 * (t : ℝ) + 1 := by
  constructor
  · rintro ⟨h5, h7⟩
    obtain ⟨m, k, hzz, hm⟩ := resonance_pair_diophantine 5 7 ω
      ((limitAmp_eq_zero_iff 5 ω).mp h5) ((limitAmp_eq_zero_iff 7 ω).mp h7)
    push_cast at hzz hm
    refine ⟨(m - 4) / 9, ?_⟩
    have hint : 2 * m + 1 = 9 * (2 * ((m - 4) / 9) + 1) := by omega
    have hR : 2 * (m : ℝ) + 1 = 9 * (2 * (((m - 4) / 9 : ℤ) : ℝ) + 1) := by exact_mod_cast hint
    linarith
  · rintro ⟨t, rfl⟩
    exact ⟨limitAmp_odd_int 5 t, limitAmp_odd_int 7 t⟩

/-- **Separation of the three classical multipliers.**  There is a frequency at
which `3n+1` has a spectral gap while `5n+1` and `7n+1` do not, and symmetrically
for the other two multipliers; the three resonance sets are pairwise distinct. -/
theorem resonance_sets_pairwise_distinct :
    (limitAmp 3 (1 / 5 : ℝ) = 0 ∧ limitAmp 5 (1 / 5 : ℝ) ≠ 0 ∧ limitAmp 7 (1 / 5 : ℝ) ≠ 0) ∧
    (limitAmp 5 (1 / 9 : ℝ) = 0 ∧ limitAmp 3 (1 / 9 : ℝ) ≠ 0 ∧ limitAmp 7 (1 / 9 : ℝ) ≠ 0) ∧
    (limitAmp 7 (1 / 13 : ℝ) = 0 ∧ limitAmp 3 (1 / 13 : ℝ) ≠ 0 ∧
      limitAmp 5 (1 / 13 : ℝ) ≠ 0) := by
  refine ⟨⟨resonance_three_one_fifth, no_resonance_five_one_fifth,
      no_resonance_seven_one_fifth⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩⟩
  · rw [limitAmp_eq_zero_iff]; exact ⟨0, by norm_num⟩
  · rw [Ne, limitAmp_eq_zero_iff]
    rintro ⟨m, hm⟩
    norm_num at hm
    have hz : (5 : ℤ) = 18 * m + 9 := by exact_mod_cast (by linarith : (5 : ℝ) = 18 * m + 9)
    omega
  · rw [Ne, limitAmp_eq_zero_iff]
    rintro ⟨m, hm⟩
    norm_num at hm
    have hz : (13 : ℤ) = 18 * m + 9 := by exact_mod_cast (by linarith : (13 : ℝ) = 18 * m + 9)
    omega
  · rw [limitAmp_eq_zero_iff]; exact ⟨0, by norm_num⟩
  · rw [Ne, limitAmp_eq_zero_iff]
    rintro ⟨m, hm⟩
    norm_num at hm
    have hz : (5 : ℤ) = 26 * m + 13 := by exact_mod_cast (by linarith : (5 : ℝ) = 26 * m + 13)
    omega
  · rw [Ne, limitAmp_eq_zero_iff]
    rintro ⟨m, hm⟩
    norm_num at hm
    have hz : (9 : ℤ) = 26 * m + 13 := by exact_mod_cast (by linarith : (9 : ℝ) = 26 * m + 13)
    omega

end CollatzSpectral