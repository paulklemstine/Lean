import Mathlib

/-!
# The sound-of-π proposal: a precise structural audit

This file formalizes the digit-to-pitch map in the proposal and separates two notions
that the informal conjecture conflates:

* a **temporal lag** compares entries at positions `i` and `i + ℓ`;
* a **musical interval** compares the pitch numbers of the two entries.

Under the stated map, a decimal digit `d` has pitch number `d`, so all generated
notes lie in a span of nine semitones. Consequently no pair of generated notes is
an octave (twelve semitones) apart. In particular, equality at temporal lag 12 is
a repeated pitch (unison), not an octave interval.
-/

namespace SoundOfPi

/-- A decimal digit, represented with its range proof. -/
abbrev Digit := Fin 10

/-- The pitch offset in semitones prescribed by the proposal. -/
def pitch (d : Digit) : ℕ := d.val

/-- Absolute pitch distance in semitones. -/
def pitchDistance (a b : Digit) : ℕ := Nat.dist (pitch a) (pitch b)

/-- Two digit-notes form an exact octave when their pitch distance is 12. -/
def IsOctave (a b : Digit) : Prop := pitchDistance a b = 12

/-- A temporal match at lag `lag`: the two digits at the compared positions agree. -/
def MatchAtLag (x : ℕ → Digit) (lag i : ℕ) : Prop := x i = x (i + lag)

/-- The constant-zero digit stream, used for the final concrete counterexample. -/
def zeroStream : ℕ → Digit := fun _ => 0

/-- Every digit-note has pitch offset strictly below ten semitones. -/
theorem pitch_lt_ten (d : Digit) : pitch d < 10 := by
  exact d.isLt

/-- The pitch distance between any two decimal digit-notes is at most nine semitones. -/
theorem pitchDistance_le_nine (a b : Digit) : pitchDistance a b ≤ 9 := by
  have ha := pitch_lt_ten a
  have hb := pitch_lt_ten b
  simp only [pitchDistance, pitch]
  by_cases h : a.val ≤ b.val
  · rw [Nat.dist_eq_sub_of_le h]
    omega
  · have h' : b.val ≤ a.val := by omega
    rw [Nat.dist_comm, Nat.dist_eq_sub_of_le h']
    omega

/-- Therefore the proposed ten-note digit scale contains no octave-separated pair. -/
theorem no_digit_pair_is_octave (a b : Digit) : ¬ IsOctave a b := by
  intro h
  have hbound := pitchDistance_le_nine a b
  simp only [IsOctave] at h
  omega

/-- Equal digit-notes are a unison and, by the preceding global bound, not an octave. -/
theorem equal_digits_are_unison_not_octave (a b : Digit) (h : a = b) :
    pitchDistance a b = 0 ∧ ¬ IsOctave a b := by
  subst b
  refine ⟨by simp [pitchDistance], ?_⟩
  exact no_digit_pair_is_octave a a

/-- A match at any temporal lag is a unison rather than an octave, irrespective
of the numerical value of the lag. -/
theorem lag_match_is_unison_not_octave (x : ℕ → Digit) (lag i : ℕ)
    (h : MatchAtLag x lag i) :
    pitchDistance (x i) (x (i + lag)) = 0 ∧ ¬ IsOctave (x i) (x (i + lag)) := by
  exact equal_digits_are_unison_not_octave _ _ h

/-- Specializing the preceding result: a match twelve digit positions later is
still a musical unison, not a musical octave. -/
theorem lag_twelve_match_is_unison_not_octave (x : ℕ → Digit) (i : ℕ)
    (h : MatchAtLag x 12 i) :
    pitchDistance (x i) (x (i + 12)) = 0 ∧ ¬ IsOctave (x i) (x (i + 12)) := by
  exact lag_match_is_unison_not_octave x 12 i h

/-- A concrete witness that temporal lag 12 does not mean a twelve-semitone octave:
the constant-zero stream matches at lag 12, and the resulting interval is a unison. -/
theorem temporal_lag_twelve_does_not_mean_octave (i : ℕ) :
    MatchAtLag zeroStream 12 i ∧
      pitchDistance (zeroStream i) (zeroStream (i + 12)) = 0 ∧
      ¬ IsOctave (zeroStream i) (zeroStream (i + 12)) := by
  have hmatch : MatchAtLag zeroStream 12 i := by
    simp [MatchAtLag, zeroStream]
  exact ⟨hmatch, lag_twelve_match_is_unison_not_octave zeroStream i hmatch⟩

end SoundOfPi