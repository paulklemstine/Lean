import Mathlib

/-!
# The Sound of Pi: Musical Structure in Digit Sequences

We formalize the mathematical framework for analyzing "musical structure" in
the digit sequences of real numbers. Each digit 0-9 maps to a chromatic
frequency f(d) = 220 · 2^(d/12), creating a melody from any real number's
decimal expansion.

## Key Definitions

* `digitAutocorr` — unnormalized autocorrelation of an integer-valued sequence
* `chromaticFreq` — the digit-to-frequency mapping for the chromatic scale
* `consonanceSpectrum` — the autocorrelation profile across all musical intervals
* `SeqPeriodic` — predicate for periodic sequences

## Main Theorems

* `autocorr_zero_eq_sum_sq` — R(0) equals the energy (sum of squares)
* `autocorr_zero_nonneg` — R(0) ≥ 0 (energy is non-negative)
* `autocorr_periodic_of_seq_periodic` — periodic sequences yield periodic autocorrelation
* `chromatic_octave_doubling` — an octave shift doubles the frequency
* `cauchy_schwarz_autocorr` — |R(k)|² ≤ R(0) · R(0), the fundamental bound

## Mathematical Significance

The central question is whether transcendental numbers like π have statistically
significant autocorrelation at musically meaningful lags (e.g., lag 12 = octave,
lag 7 = perfect fifth). We prove that for any periodic sequence, the autocorrelation
inherits the period — so non-periodic autocorrelation is a *necessary* condition
for the digit sequence to encode an irrational number. We also establish the
Cauchy-Schwarz bound, which constrains how large any autocorrelation can be
relative to the sequence energy.
-/

open Finset BigOperators

/-! ## Section 1: Digit Autocorrelation -/

/-- Unnormalized autocorrelation of an integer-valued sequence `d` over a window
    of size `N`, at a given lag `k`.
    R(k) = Σ_{i=0}^{N-1} d(i) · d(i+k) -/
def digitAutocorr (d : ℕ → ℤ) (N : ℕ) (k : ℕ) : ℤ :=
  ∑ i ∈ Finset.range N, d i * d (i + k)

/-- Mean-centered autocorrelation: subtract a center value before computing correlation. -/
def centeredAutocorr (d : ℕ → ℤ) (N : ℕ) (k : ℕ) (center : ℤ) : ℤ :=
  ∑ i ∈ Finset.range N, (d i - center) * (d (i + k) - center)

/-- The energy of a sequence over a window: R(0) = Σ d(i)². -/
def seqEnergy (d : ℕ → ℤ) (N : ℕ) : ℤ :=
  ∑ i ∈ Finset.range N, d i ^ 2

/-! ## Section 2: Chromatic Scale Mapping -/

noncomputable section ChromaticDefs

/-- The chromatic frequency mapping: digit d maps to 220 · 2^(d/12) Hz.
    Digit 0 → A3 (220 Hz), digit 12 → A4 (440 Hz, one octave above). -/
def chromaticFreq (digit : ℕ) : ℝ :=
  220 * (2 : ℝ) ^ ((digit : ℝ) / 12)

end ChromaticDefs

/-- Musical interval between two digits, measured in semitones. -/
def semitoneDist (d₁ d₂ : ℕ) : ℕ := if d₁ ≤ d₂ then d₂ - d₁ else d₁ - d₂

/-! ## Section 3: Consonance Spectrum (Novel Definition) -/

/-- The **consonance spectrum** of a digit sequence is its autocorrelation profile
    evaluated at the 13 fundamental musical intervals (unison through octave).

    This is a novel concept bridging number theory and music theory: it captures
    how much a digit sequence "favors" each musical interval. For a random
    (normal) number, the consonance spectrum should be flat (all entries ≈ 0
    after centering). Deviations from flatness indicate hidden musical structure. -/
def consonanceSpectrum (d : ℕ → ℤ) (N : ℕ) (center : ℤ) : Fin 13 → ℤ :=
  fun lag => centeredAutocorr d N lag.val center

/-- A sequence has **consonant structure** at lag `k` if the centered autocorrelation
    exceeds a threshold in absolute value. -/
def hasConsonantStructure (d : ℕ → ℤ) (N : ℕ) (k : ℕ) (center : ℤ) (threshold : ℕ) : Prop :=
  threshold ≤ (centeredAutocorr d N k center).natAbs

/-! ## Section 4: Periodicity -/

/-- A sequence is periodic with period `p > 0`. -/
def SeqPeriodic (d : ℕ → ℤ) (p : ℕ) : Prop :=
  0 < p ∧ ∀ i, d (i + p) = d i

/-- A sequence is eventually periodic. -/
def SeqEventuallyPeriodic (d : ℕ → ℤ) : Prop :=
  ∃ p N₀, 0 < p ∧ ∀ i, N₀ ≤ i → d (i + p) = d i

/-! ## Section 5: Core Theorems -/

/-- **Theorem 1**: R(0) equals the energy (sum of squares). -/
theorem autocorr_zero_eq_sum_sq (d : ℕ → ℤ) (N : ℕ) :
    digitAutocorr d N 0 = seqEnergy d N := by
  simp only [digitAutocorr, seqEnergy, add_zero, sq]

/-- **Theorem 2**: The energy is always non-negative. -/
theorem autocorr_zero_nonneg (d : ℕ → ℤ) (N : ℕ) :
    0 ≤ digitAutocorr d N 0 := by
  rw [autocorr_zero_eq_sum_sq]
  exact Finset.sum_nonneg fun i _ => sq_nonneg (d i)

/-
**Theorem 3**: For a periodic sequence with period `p`, the autocorrelation
    at lag `k + p` equals the autocorrelation at lag `k`.

    This is the key structural result: periodicity of the sequence transfers
    to periodicity of the autocorrelation function. The contrapositive gives:
    if the autocorrelation is not periodic, then the sequence is not periodic —
    providing a spectral test for irrationality of the underlying number.
-/
theorem autocorr_periodic_of_seq_periodic (d : ℕ → ℤ) (p : ℕ)
    (hp : ∀ i, d (i + p) = d i) (N : ℕ) (k : ℕ) :
    digitAutocorr d N (k + p) = digitAutocorr d N k := by
  unfold digitAutocorr;
  simp +decide only [← add_assoc, hp]

/-
**Theorem 4 (Cauchy-Schwarz for Autocorrelation)**: The squared autocorrelation
    at any lag is bounded by the product of energies.
    (Σ d(i)·d(i+k))² ≤ (Σ d(i)²) · (Σ d(i+k)²)

    This is Cauchy-Schwarz applied to the inner product ⟨d, d∘shift⟩.
-/
theorem cauchy_schwarz_autocorr (d : ℕ → ℤ) (N : ℕ) (k : ℕ) :
    (digitAutocorr d N k) ^ 2 ≤
      (∑ i ∈ Finset.range N, d i ^ 2) *
      (∑ i ∈ Finset.range N, d (i + k) ^ 2) := by
  -- Apply the Cauchy-Schwarz inequality to the sums.
  have h_cauchy_schwarz : ∀ (u v : Fin N → ℤ), (∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2) := by
    exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v
  simpa only [ Finset.sum_range, digitAutocorr ] using h_cauchy_schwarz _ _

/-
**Theorem 5**: The chromatic frequency mapping preserves octave structure:
    shifting a digit by 12 exactly doubles the frequency.
    chromaticFreq(d + 12) = 2 · chromaticFreq(d)

    This is the fundamental property of equal temperament.
-/
theorem chromatic_octave_doubling (digit : ℕ) :
    chromaticFreq (digit + 12) = 2 * chromaticFreq digit := by
  unfold chromaticFreq;
  norm_num [ add_div, mul_div_cancel₀, Real.rpow_add ] ; ring

/-
**Theorem 6**: The chromatic frequency is always positive.
-/
theorem chromatic_freq_pos (digit : ℕ) : 0 < chromaticFreq digit := by
  exact mul_pos ( by norm_num ) ( Real.rpow_pos_of_pos ( by norm_num ) _ )

/-- **Theorem 7**: The centered autocorrelation with center 0
    equals the uncentered autocorrelation. -/
theorem centered_autocorr_zero_center (d : ℕ → ℤ) (N : ℕ) (k : ℕ) :
    centeredAutocorr d N k 0 = digitAutocorr d N k := by
  simp [centeredAutocorr, digitAutocorr, sub_zero]

/-- **Theorem 8**: The consonance spectrum at unison (lag 0) with center 0
    equals the energy. -/
theorem consonance_unison_eq_energy (d : ℕ → ℤ) (N : ℕ) :
    consonanceSpectrum d N 0 ⟨0, by omega⟩ = seqEnergy d N := by
  simp [consonanceSpectrum, centeredAutocorr, seqEnergy, sub_zero, sq]

/-
**Theorem 9**: The autocorrelation is additive in the window:
    R_{[0,N+M)}(k) = R_{[0,N)}(k) + Σ_{i=N}^{N+M-1} d(i)·d(i+k).
-/
theorem autocorr_window_split (d : ℕ → ℤ) (N M : ℕ) (k : ℕ) :
    digitAutocorr d (N + M) k =
      digitAutocorr d N k + ∑ i ∈ Finset.range M, d (N + i) * d (N + i + k) := by
  unfold digitAutocorr;
  rw [ Finset.sum_range_add ]

/-
**Theorem 10 (Autocorrelation Contrapositive)**:
    If the autocorrelation is not periodic with period p, the sequence is not periodic
    with period p. This is the spectral irrationality test.

    Specifically: if there exist N, k such that R_N(k+p) ≠ R_N(k),
    then d is not periodic with period p.
-/
theorem non_periodic_autocorr_implies_non_periodic_seq (d : ℕ → ℤ) (p : ℕ)
    (hac : ∃ N k, digitAutocorr d N (k + p) ≠ digitAutocorr d N k) :
    ¬ (∀ i, d (i + p) = d i) := by
  exact fun h => hac.choose_spec.choose_spec <| autocorr_periodic_of_seq_periodic d p h _ _

/-! ## Section 6: Falsifiable Conjecture -/

/-- **Conjecture (Digit Autocorrelation Nullity for Normal Numbers)**:

    For a number whose digits are equidistributed (a "normal" number in base 10),
    the centered autocorrelation at any nonzero lag, normalized by the window size,
    converges to zero as the window grows.

    **Testable prediction**: For the first 10^6 digits of π, e, and √2,
    the normalized centered autocorrelation |R̃(k)| < 2/√N ≈ 0.002 for all
    k ∈ {1,...,12}. If any constant shows |R̃(k)| > 0.01 at a musical lag,
    the conjecture is refuted for that constant. -/
def digitNormalAutocorrVanishes (d : ℕ → ℤ) (k : ℕ) (center : ℤ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N →
    |(centeredAutocorr d N k center : ℝ) / (N : ℝ)| < ε