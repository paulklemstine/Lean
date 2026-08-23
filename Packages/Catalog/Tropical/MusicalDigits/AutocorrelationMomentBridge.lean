import Mathlib
import Shared.MusicalDigits.Autocorrelation
import Tropical.MusicalDigits.IntervalDistribution

/-!
# Autocorrelation is the second moment of the interval distribution

`Shared.MusicalDigits.Autocorrelation` proves the polarization identity
`2 · autocorrelation = 2 · energy − intervalEnergy` for a cyclic real signal.  This file
identifies the remaining term: for a *digit* melody, `intervalEnergy` at lag `k` is
exactly the second moment of the pitch-interval distribution at lag `k`
(`intervalEnergy_eq_second_moment`).  Consequently

`2 · autocorrelation(k) = 2 · energy − Σ_v v² · N_k(v)`   (`autocorrelation_moment_identity`)

so the temporal statistic is a *functional of the pitch statistic at that lag*, and two
melodies with equal energy and equal lag-`k` interval distributions have equal lag-`k`
autocorrelation (`autocorrelation_congr_of_intervalDistribution`).  A lag-12
autocorrelation peak is thus a statement about the mass `N₁₂(0)` of **unisons**; the
octave value `v = 12` carries zero mass for every decimal melody
(`cycIntervalCount_octave_eq_zero`).

The last section treats the second half of the corrected methodology, pitch classes
modulo 12.  On the ten-note digit scale the reduction `ℕ → ZMod 12` is *injective*
(`pitchClass_inj_of_lt`), so octave equivalence is trivial there and interval classes
carry exactly the same information as intervals (`intervalClass_eq_iff`).  The boundary is
sharp: in base 13 the reduction identifies the digits `0` and `12`
(`pitchClass_not_injective_base_thirteen`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): every additive lag statistic of a digit melody should factor
through the interval distribution; autocorrelation should be its second moment, up to the
energy normalisation.

Experiment (Experimenter): the pointwise identity `((a : ℝ) - b)^2 = (Nat.dist a b : ℝ)^2`
plus fiberwise summation over the value of `Nat.dist` yields the moment expansion; the
catalog polarization identity then supplies the autocorrelation form.

Analysis (Analyst): the converse fails — equal autocorrelation does not force equal
interval distributions, since only the second moment is seen. This information loss is
quantified in one direction by `autocorrelation_congr_of_intervalDistribution` and
witnessed in the other by the explicit pair of melodies `0,0,0,5` and `0,3,0,4` in
`autocorrelation_does_not_determine_intervalDistribution`.

Critique (Critic): `pitchClass` faithfulness is an artefact of the alphabet size, not of
the melody, and the base-13 counterexample is recorded to mark the boundary.
-/

namespace TropicalMusicalDigits

open Finset MusicalDigits

/-! ### Digit melodies on a cyclic window -/

/-- A cyclic digit melody, viewed as the real signal used by the catalog's
autocorrelation theory. -/
def toSignal {n : ℕ} (d : Fin n → ℕ) : Fin n → ℝ := fun i => (d i : ℝ)

/-- The cyclic pitch-interval distribution: the number of positions `i` of the cyclic
window at which the pair `(i, i + k)` realizes the interval `v`. -/
def cycIntervalCount {n : ℕ} (d : Fin n → ℕ) (k : Fin n) (v : ℕ) : ℕ :=
  (univ.filter fun i => Nat.dist (d i) (d (i + k)) = v).card

lemma sq_sub_cast (a b : ℕ) : ((a : ℝ) - (b : ℝ)) ^ 2 = ((Nat.dist a b : ℕ) : ℝ) ^ 2 := by
  rcases le_total a b with h | h
  · rw [Nat.dist_eq_sub_of_le h, Nat.cast_sub h]
    ring
  · rw [Nat.dist_comm, Nat.dist_eq_sub_of_le h, Nat.cast_sub h]

/-- The catalog's `intervalEnergy` of a digit melody is the sum of squared pitch
intervals across the lag. -/
theorem intervalEnergy_eq_sum_sq {n : ℕ} (d : Fin n → ℕ) (k : Fin n) :
    intervalEnergy (toSignal d) k = ∑ i, ((Nat.dist (d i) (d (i + k)) : ℕ) : ℝ) ^ 2 := by
  unfold intervalEnergy shift toSignal
  exact sum_congr rfl fun i _ => sq_sub_cast _ _

/-- **The interval energy is the second moment of the pitch-interval distribution.** -/
theorem intervalEnergy_eq_second_moment {b n : ℕ} (d : Fin n → ℕ) (hd : ∀ i, d i < b)
    (k : Fin n) :
    intervalEnergy (toSignal d) k
      = ∑ v ∈ range b, (v : ℝ) ^ 2 * (cycIntervalCount d k v : ℝ) := by
  rw [intervalEnergy_eq_sum_sq]
  have hmaps : ∀ i ∈ (univ : Finset (Fin n)), Nat.dist (d i) (d (i + k)) ∈ range b := by
    intro i _
    have h1 := hd i
    have h2 := hd (i + k)
    simp only [mem_range, Nat.dist]
    omega
  rw [← sum_fiberwise_of_maps_to (g := fun i => Nat.dist (d i) (d (i + k))) (t := range b)
    hmaps (fun i => ((Nat.dist (d i) (d (i + k)) : ℕ) : ℝ) ^ 2)]
  refine sum_congr rfl fun v _ => ?_
  rw [cycIntervalCount, sum_congr rfl (fun i hi => by rw [(mem_filter.1 hi).2]), sum_const,
    nsmul_eq_mul, mul_comm]

/-- **Moment identity for cyclic autocorrelation.**  The lag-`k` autocorrelation of a
digit melody is determined by its energy together with the second moment of its lag-`k`
pitch-interval distribution. -/
theorem autocorrelation_moment_identity {b n : ℕ} (d : Fin n → ℕ) (hd : ∀ i, d i < b)
    (k : Fin n) :
    2 * autocorrelation (toSignal d) k
      = 2 * signalEnergy (toSignal d)
        - ∑ v ∈ range b, (v : ℝ) ^ 2 * (cycIntervalCount d k v : ℝ) := by
  rw [two_mul_autocorrelation_eq (toSignal d) k, intervalEnergy_eq_second_moment d hd k]

/-- **Autocorrelation is a functional of the interval distribution.**  Two digit melodies
with the same energy and the same lag-`k` interval distribution have the same lag-`k`
autocorrelation — even if they are otherwise unrelated. -/
theorem autocorrelation_congr_of_intervalDistribution {b n : ℕ} (d e : Fin n → ℕ)
    (hd : ∀ i, d i < b) (he : ∀ i, e i < b) (k : Fin n)
    (hE : signalEnergy (toSignal d) = signalEnergy (toSignal e))
    (hN : ∀ v, cycIntervalCount d k v = cycIntervalCount e k v) :
    autocorrelation (toSignal d) k = autocorrelation (toSignal e) k := by
  have h1 := autocorrelation_moment_identity d hd k
  have h2 := autocorrelation_moment_identity e he k
  have hsum : ∑ v ∈ range b, (v : ℝ) ^ 2 * (cycIntervalCount d k v : ℝ)
      = ∑ v ∈ range b, (v : ℝ) ^ 2 * (cycIntervalCount e k v : ℝ) :=
    sum_congr rfl fun v _ => by rw [hN v]
  rw [hE, hsum] at h1
  linarith [h1, h2]

/-- The octave has zero mass in the cyclic interval distribution of a decimal melody, at
every lag — while the autocorrelation peak at that lag measures the *unison* mass. -/
theorem cycIntervalCount_octave_eq_zero {n : ℕ} (d : Fin n → ℕ) (hd : ∀ i, d i < 10)
    (k : Fin n) : cycIntervalCount d k 12 = 0 := by
  simp only [cycIntervalCount, card_eq_zero, filter_eq_empty_iff]
  intro i _ hcon
  have h1 := hd i
  have h2 := hd (i + k)
  simp only [Nat.dist] at hcon
  omega

/-- Maximal lag-`k` autocorrelation of a digit melody happens exactly when the whole
interval distribution mass sits on the unison, and this is the catalog's shift-invariance
criterion. -/
theorem autocorrelation_eq_energy_iff_unison_mass {n : ℕ} (d : Fin n → ℕ) (k : Fin n) :
    autocorrelation (toSignal d) k = signalEnergy (toSignal d) ↔
      ∀ i, Nat.dist (d i) (d (i + k)) = 0 := by
  rw [autocorrelation_eq_energy_iff]
  constructor
  · intro h i
    have : toSignal d (i + k) = toSignal d i := congrFun h i
    simp only [toSignal, Nat.cast_inj] at this
    simp [this]
  · intro h
    funext i
    have : d (i + k) = d i := (Nat.eq_of_dist_eq_zero (h i)).symm
    simp [shift, toSignal, this]

/-- **The moment bridge is not invertible.**  Autocorrelation sees only the second moment,
so two decimal melodies can share their energy *and* their lag-1 autocorrelation while
having different interval distributions: the melody `0,0,0,5` has two unisons at lag 1,
the melody `0,3,0,4` has none.  A correlation statistic therefore cannot certify any
statement about which musical intervals occur. -/
theorem autocorrelation_does_not_determine_intervalDistribution :
    ∃ d e : Fin 4 → ℕ, (∀ i, d i < 10) ∧ (∀ i, e i < 10) ∧
      signalEnergy (toSignal d) = signalEnergy (toSignal e) ∧
      autocorrelation (toSignal d) 1 = autocorrelation (toSignal e) 1 ∧
      cycIntervalCount d 1 0 ≠ cycIntervalCount e 1 0 := by
  refine ⟨![0, 0, 0, 5], ![0, 3, 0, 4], by decide, by decide, ?_, ?_, by decide⟩
  · simp [signalEnergy, toSignal, Fin.sum_univ_four]
    norm_num
  · simp [autocorrelation, shift, toSignal, Fin.sum_univ_four]

/-! ### Pitch classes modulo twelve -/

/-- The pitch class of a note, i.e. its pitch modulo the octave. -/
def pitchClass (a : ℕ) : ZMod 12 := (a : ZMod 12)

/-- The interval class: the pitch interval reduced modulo the octave. -/
def intervalClass (a b : ℕ) : ZMod 12 := pitchClass (Nat.dist a b)

/-- Below the octave, pitch classes separate notes. -/
theorem pitchClass_inj_of_lt {a b : ℕ} (ha : a < 12) (hb : b < 12) :
    pitchClass a = pitchClass b ↔ a = b := by
  constructor
  · intro h
    have : a ≡ b [MOD 12] := (ZMod.natCast_eq_natCast_iff a b 12).1 h
    unfold Nat.ModEq at this
    rw [Nat.mod_eq_of_lt ha, Nat.mod_eq_of_lt hb] at this
    exact this
  · rintro rfl; rfl

/-- **Octave equivalence is trivial on the decimal digit scale.**  For decimal melodies,
two notes have the same pitch class exactly when they are the same note; so no genuine
octave identification ever takes place. -/
theorem pitchClass_faithful_on_digits {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (i j : ℕ) :
    pitchClass (x i) = pitchClass (x j) ↔ x i = x j :=
  pitchClass_inj_of_lt (by have := hx i; omega) (by have := hx j; omega)

/-- Interval classes of decimal melodies carry exactly the same information as intervals:
reducing modulo the octave loses nothing, because no interval reaches an octave. -/
theorem intervalClass_eq_iff {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (i j k l : ℕ) :
    intervalClass (x i) (x j) = intervalClass (x k) (x l) ↔
      interval x i j = interval x k l := by
  have h1 : Nat.dist (x i) (x j) < 12 := by
    have := hx i; have := hx j; simp only [Nat.dist]; omega
  have h2 : Nat.dist (x k) (x l) < 12 := by
    have := hx k; have := hx l; simp only [Nat.dist]; omega
  simpa [intervalClass, interval] using pitchClass_inj_of_lt h1 h2

/-- The boundary of the previous two results: from base 13 on, pitch-class reduction is no
longer faithful — the digits `0` and `12` become octave-equivalent while being distinct
notes, so mod-12 analysis and interval analysis genuinely differ there. -/
theorem pitchClass_not_injective_base_thirteen :
    pitchClass 0 = pitchClass 12 ∧ (0 : ℕ) ≠ 12 := by
  refine ⟨?_, by norm_num⟩
  simp [pitchClass]
  decide

end TropicalMusicalDigits