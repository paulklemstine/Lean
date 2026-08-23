import Mathlib
import Computation.SoundOfPi

/-!
# Pitch-interval distributions of digit melodies, separated from temporal lag

The catalog file `Computation.SoundOfPi` observes, for a *single* pair of positions,
that a temporal lag of twelve digit positions is not a twelve-semitone interval.
This file upgrades that pointwise observation to the level of *statistics*: for a
clearly specified family of position pairs `(i, i + ℓ)` we introduce the pitch-interval
distribution

`intervalCount x n ℓ v = #{ i < n : |x i - x (i+ℓ)| = v }`,

the exact object the corrected methodology calls for, and we determine

* its **support** (`intervalCount_eq_zero_of_base_le`): in base `b` no interval value
  `v ≥ b` ever occurs, so the octave value `12` has count `0` in every decimal melody,
  at every lag, in every window — in particular at lag `12`;
* its **total mass** (`sum_intervalCount`): the distribution is a genuine probability
  distribution on `{0, …, b-1}` after dividing by the window length `n`;
* its **moments** (`sum_intervalCount_sq`, `sum_intervalCount_smul`): the raw interval
  sums used by autocorrelation statistics are moments of this distribution;
* its **realizable spectrum** (`interval_spectrum_iff`): for every lag `ℓ ≥ 1` and every
  value `v ≤ 9` there is a decimal melody all of whose lag-`ℓ` intervals equal `v`,
  while for `ℓ = 0` only `v = 0` is realizable. Hence the lag parameter and the interval
  parameter are logically independent: the numeral `12` in "lag 12" carries no interval
  information whatsoever.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the lag index and the interval value should be completely
decoupled parameters; the only constraints are the alphabet bound (`v < b`) and the
degenerate lag `ℓ = 0`.

Experiment (Experimenter): the square-wave melody `i ↦ v * ((i / ℓ) % 2)` realizes the
constant lag-`ℓ` interval `v`; `Nat.add_div_right` makes the parity flip exact. Fiberwise
counting (`Finset.card_eq_sum_card_fiberwise`) converts window sums into distribution
moments.

Analysis (Analyst): every statement survived. The single obstruction found is the
degenerate lag `ℓ = 0`, where the distribution is a point mass at `0` for trivial
reasons; the spectrum theorem therefore had to be stated as a guarded biconditional.

Critique (Critic): "no interval equals 12" is *not* an accident of π; it holds for the
constant melody as well and is a property of the ten-note digit scale. The genuinely
falsifiable content is therefore the spectrum theorem and the moment identities, which
constrain what an empirical study can conclude from a lag statistic.
-/

namespace TropicalMusicalDigits

open Finset

/-! ### Definitions -/

/-- The pitch interval, in semitones, between the digit-notes at positions `i` and `j`
of a digit melody `x`.  This is a *pitch* statistic; it does not refer to `j - i`. -/
def interval (x : ℕ → ℕ) (i j : ℕ) : ℕ := Nat.dist (x i) (x j)

/-- The pitch interval realized by the clearly specified position pair `(i, i + ℓ)`. -/
def lagInterval (x : ℕ → ℕ) (ℓ i : ℕ) : ℕ := interval x i (i + ℓ)

/-- The pitch-interval distribution: the number of window positions `i < n` at which the
position pair `(i, i + ℓ)` realizes the interval value `v` semitones. -/
def intervalCount (x : ℕ → ℕ) (n ℓ v : ℕ) : ℕ :=
  ((range n).filter fun i => lagInterval x ℓ i = v).card

/-- A melody is a base-`b` digit melody when all of its entries are digits. -/
def IsDigitMelody (b : ℕ) (x : ℕ → ℕ) : Prop := ∀ i, x i < b

/-! ### Elementary properties of intervals -/

lemma interval_comm (x : ℕ → ℕ) (i j : ℕ) : interval x i j = interval x j i :=
  Nat.dist_comm _ _

lemma interval_self (x : ℕ → ℕ) (i : ℕ) : interval x i i = 0 := Nat.dist_self _

lemma interval_eq_zero_iff (x : ℕ → ℕ) (i j : ℕ) : interval x i j = 0 ↔ x i = x j :=
  ⟨Nat.eq_of_dist_eq_zero, Nat.dist_eq_zero⟩

lemma lagInterval_zero (x : ℕ → ℕ) (i : ℕ) : lagInterval x 0 i = 0 := by
  simp [lagInterval, interval]

/-- The triangle inequality for pitch intervals. -/
lemma interval_triangle (x : ℕ → ℕ) (i j k : ℕ) :
    interval x i k ≤ interval x i j + interval x j k :=
  Nat.dist.triangle_inequality _ _ _

/-- In base `b` every realized pitch interval is strictly smaller than `b`. -/
lemma lagInterval_lt_base {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (ℓ i : ℕ) :
    lagInterval x ℓ i < b := by
  have h1 := hx i
  have h2 := hx (i + ℓ)
  have : Nat.dist (x i) (x (i + ℓ)) ≤ max (x i) (x (i + ℓ)) := by
    unfold Nat.dist; omega
  simp only [lagInterval, interval]
  omega

/-- Specialization to the decimal scale of `Computation.SoundOfPi`: every interval
between two digit-notes is at most nine semitones. -/
lemma lagInterval_le_nine {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (ℓ i : ℕ) :
    lagInterval x ℓ i ≤ 9 := by
  have := lagInterval_lt_base hx ℓ i; omega

/-! ### Support of the distribution -/

/-- Interval values at or above the base never occur: the distribution is supported on
`{0, …, b-1}`. -/
theorem intervalCount_eq_zero_of_base_le {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x)
    (n ℓ v : ℕ) (hv : b ≤ v) : intervalCount x n ℓ v = 0 := by
  simp only [intervalCount, card_eq_zero]
  rw [filter_eq_empty_iff]
  intro i _ h
  have := lagInterval_lt_base hx ℓ i
  omega

/-- **The octave never appears in a decimal digit melody.**  For every decimal melody,
every window length, and every temporal lag — in particular the lag `12` used by
autocorrelation studies — the number of position pairs realizing a twelve-semitone
interval is zero. -/
theorem decimal_octave_count_eq_zero {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (n ℓ : ℕ) :
    intervalCount x n ℓ 12 = 0 :=
  intervalCount_eq_zero_of_base_le hx n ℓ 12 (by norm_num)

/-- The lag-12 interval distribution assigns zero mass to the octave, while the lag-12
autocorrelation statistic counts the *unison* mass `intervalCount x n 12 0`.  The two
numbers are different statistics of the same position pairs. -/
theorem lag_twelve_octave_versus_unison {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (n : ℕ) :
    intervalCount x n 12 12 = 0 ∧
      intervalCount x n 12 0 =
        ((range n).filter fun i => x i = x (i + 12)).card := by
  refine ⟨decimal_octave_count_eq_zero hx n 12, ?_⟩
  simp only [intervalCount, lagInterval]
  congr 1
  apply filter_congr
  intro i _
  simp [interval_eq_zero_iff]

/-! ### Total mass and moments -/

/-- The interval distribution is a distribution: its total mass over the admissible
interval values is the window length. -/
theorem sum_intervalCount {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (n ℓ : ℕ) :
    ∑ v ∈ range b, intervalCount x n ℓ v = n := by
  have := (card_eq_sum_card_fiberwise
    (f := fun i => lagInterval x ℓ i) (s := range n) (t := range b)
    (fun i _ => mem_range.2 (lagInterval_lt_base hx ℓ i))).symm
  simpa [intervalCount] using this

/-- Every additive window statistic of the lag-`ℓ` intervals is a moment of the interval
distribution.  This is the exact sense in which a lag statistic is a *functional of the
pitch-interval distribution at that lag*. -/
theorem sum_intervalCount_smul {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (n ℓ : ℕ)
    (g : ℕ → ℕ) :
    ∑ v ∈ range b, g v * intervalCount x n ℓ v = ∑ i ∈ range n, g (lagInterval x ℓ i) := by
  rw [← sum_fiberwise_of_maps_to (g := fun i => lagInterval x ℓ i) (t := range b)
    (fun i _ => mem_range.2 (lagInterval_lt_base hx ℓ i)) (fun i => g (lagInterval x ℓ i))]
  refine sum_congr rfl fun v _ => ?_
  rw [intervalCount, mul_comm, sum_congr rfl (fun i hi => by
      rw [(mem_filter.1 hi).2]), sum_const, smul_eq_mul]

/-- The second moment of the interval distribution equals the squared-interval energy
across the lag, the quantity that appears in the polarization identity for
autocorrelation. -/
theorem sum_intervalCount_sq {b : ℕ} {x : ℕ → ℕ} (hx : IsDigitMelody b x) (n ℓ : ℕ) :
    ∑ v ∈ range b, v ^ 2 * intervalCount x n ℓ v
      = ∑ i ∈ range n, (lagInterval x ℓ i) ^ 2 :=
  sum_intervalCount_smul hx n ℓ (fun v => v ^ 2)

/-- Sharp bound on the second moment of a decimal interval distribution. -/
theorem sum_intervalCount_sq_le {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (n : ℕ) (ℓ : ℕ) :
    ∑ v ∈ range 10, v ^ 2 * intervalCount x n ℓ v ≤ 81 * n := by
  rw [sum_intervalCount_sq hx n ℓ]
  calc ∑ i ∈ range n, (lagInterval x ℓ i) ^ 2 ≤ ∑ _i ∈ range n, 81 := by
        refine sum_le_sum fun i _ => ?_
        have := lagInterval_le_nine hx ℓ i
        nlinarith
    _ = 81 * n := by simp [mul_comm]

/-! ### The realizable lag/interval spectrum -/

/-- The square-wave melody with amplitude `v` and half-period `ℓ`. -/
def squareWave (v ℓ : ℕ) : ℕ → ℕ := fun i => v * ((i / ℓ) % 2)

lemma squareWave_isDigitMelody {v ℓ b : ℕ} (hv : v < b) :
    IsDigitMelody b (squareWave v ℓ) := by
  intro i
  have : (i / ℓ) % 2 = 0 ∨ (i / ℓ) % 2 = 1 := by omega
  rcases this with h | h <;> simp [squareWave, h] <;> omega

/-- Every lag-`ℓ` interval of the square wave with amplitude `v` equals `v`, provided the
half-period matches the lag and `ℓ ≥ 1`. -/
lemma squareWave_lagInterval {v ℓ : ℕ} (hℓ : 0 < ℓ) (i : ℕ) :
    lagInterval (squareWave v ℓ) ℓ i = v := by
  have hdiv : (i + ℓ) / ℓ = i / ℓ + 1 := Nat.add_div_right i hℓ
  have : (i / ℓ) % 2 = 0 ∨ (i / ℓ) % 2 = 1 := by omega
  simp only [lagInterval, interval, squareWave, hdiv]
  rcases this with h | h
  · have h2 : (i / ℓ + 1) % 2 = 1 := by omega
    simp [h, h2, Nat.dist]
  · have h2 : (i / ℓ + 1) % 2 = 0 := by omega
    simp [h, h2, Nat.dist]

/-- **Lag/interval decoupling.**  A constant interval value `v` is realizable by some
decimal melody at lag `ℓ` exactly when `v ≤ 9` and the lag is nondegenerate (or `v = 0`).
In particular `v = 12` — the octave — is realizable at *no* lag, and every `v ≤ 9` is
realizable at *every* nonzero lag, including lag `12`.  The temporal lag therefore
carries no information about the interval content. -/
theorem interval_spectrum_iff (ℓ v : ℕ) :
    (∃ x : ℕ → ℕ, IsDigitMelody 10 x ∧ ∀ i, lagInterval x ℓ i = v) ↔
      (v ≤ 9 ∧ (0 < ℓ ∨ v = 0)) := by
  constructor
  · rintro ⟨x, hx, hval⟩
    refine ⟨by have h := lagInterval_le_nine hx ℓ 0; rw [hval 0] at h; exact h, ?_⟩
    rcases Nat.eq_zero_or_pos ℓ with h | h
    · subst h
      exact Or.inr (by simpa [lagInterval_zero x 0] using (hval 0).symm)
    · exact Or.inl h
  · rintro ⟨hv, hℓ⟩
    rcases hℓ with hℓ | hv0
    · exact ⟨squareWave v ℓ, squareWave_isDigitMelody (by omega),
        fun i => squareWave_lagInterval hℓ i⟩
    · subst hv0
      exact ⟨fun _ => 0, fun _ => by norm_num, fun i => by simp [lagInterval, interval]⟩

/-- Concretely at the much-discussed lag twelve: every interval value from a unison up to
a major sixth (nine semitones) occurs as the *constant* lag-12 interval of some decimal
melody, while a twelve-semitone octave occurs at no position of any decimal melody. -/
theorem lag_twelve_spectrum (v : ℕ) :
    (∃ x : ℕ → ℕ, IsDigitMelody 10 x ∧ ∀ i, lagInterval x 12 i = v) ↔ v ≤ 9 := by
  rw [interval_spectrum_iff]
  constructor
  · exact fun h => h.1
  · exact fun h => ⟨h, Or.inl (by norm_num)⟩

/-- A quantitative separation witness at lag twelve: the square wave of amplitude `7`
has *no* unison at lag 12 (all of its lag-12 mass sits on the interval value `7`), yet
its lag-12 mass at the octave value remains zero. -/
theorem lag_twelve_separation (n : ℕ) :
    intervalCount (squareWave 7 12) n 12 7 = n ∧
      intervalCount (squareWave 7 12) n 12 0 = 0 ∧
      intervalCount (squareWave 7 12) n 12 12 = 0 := by
  have hconst : ∀ i, lagInterval (squareWave 7 12) 12 i = 7 :=
    fun i => squareWave_lagInterval (by norm_num) i
  refine ⟨?_, ?_, ?_⟩
  · simp only [intervalCount, hconst]
    simp
  · simp only [intervalCount, hconst]
    simp
  · exact decimal_octave_count_eq_zero (squareWave_isDigitMelody (by norm_num)) n 12

end TropicalMusicalDigits