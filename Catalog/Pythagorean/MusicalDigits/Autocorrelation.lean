import Catalog.Computation.FourierTransformInversion

/-!
# Cyclic autocorrelation and interval energy of digit melodies

A finite digit melody is modelled as a real-valued function on a cyclic index set.
For a lag `k`, its autocorrelation is the inner product of the melody with its
cyclic shift, while its interval energy is the sum of the squared changes across
that lag.  The main identity proves that these are complementary quantities:

`autocorrelation = total energy - interval energy / 2`.

Thus an unusually large lag correlation is exactly an unusually small squared
interval cost; it is not, by itself, evidence of a privileged musical interval.
The result is independent of the labels assigned to digits and applies equally
to decimal expansions of π, e, √2, or to arbitrary finite melodies.

The final theorem connects this identity to the catalog's Fourier inversion
result: primitive-root Fourier coordinates determine every melody and therefore
all of its cyclic autocorrelations.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A positive lag correlation should admit a deterministic
interpretation as low interval energy, separating a genuine finite-sample fact
from claims about normality or continued fractions.

Experiment (Experimenter): Expanding `(x-y)^2` pointwise suggests an exact
polarization identity.  The only global step is that cyclic translation permutes
all indices, so shifted and unshifted square energies coincide.

Analysis (Analyst): The identity survives for every finite real signal.  It yields
both the sharp energy bound and a precise equality criterion: maximal correlation
at lag `k` occurs exactly when the signal is invariant under that cyclic shift.
Hence finite autocorrelation peaks can result from approximate repetition without
implying any arithmetic law of the underlying infinite decimal expansion.

Critique (Critic): Irrationality rules out an eventually periodic decimal, but it
does not imply any sign or significance level for a finite autocorrelation.
Moreover, "lag 12" is a temporal displacement, whereas an octave is a pitch
interval of twelve semitones; conflating these notions changes the statistic.
The statements below therefore concern cyclic temporal lags and make no claim
specific to π, e, or √2 without a separately certified digit data set.

Synthesis (Principal Investigator): Polarization, sharp equality, and Fourier
reconstruction provide a reusable framework in which empirical digit studies can
state exactly what their finite statistics establish.
-/

namespace MusicalDigits

open scoped BigOperators

/-- Cyclic translation of a finite melody by a temporal lag. -/
def shift {n : ℕ} (s : Fin n → ℝ) (k : Fin n) : Fin n → ℝ :=
  fun i => s (i + k)

/-- Unnormalised cyclic autocorrelation at lag `k`. -/
def autocorrelation {n : ℕ} (s : Fin n → ℝ) (k : Fin n) : ℝ :=
  ∑ i, s i * shift s k i

/-- Sum of squared amplitudes. -/
def signalEnergy {n : ℕ} (s : Fin n → ℝ) : ℝ :=
  ∑ i, (s i) ^ 2

/-- Squared interval cost across a lag. -/
def intervalEnergy {n : ℕ} (s : Fin n → ℝ) (k : Fin n) : ℝ :=
  ∑ i, (s i - shift s k i) ^ 2

/-
Cyclic translation preserves total square energy.
-/
lemma signalEnergy_shift {n : ℕ} (s : Fin n → ℝ) (k : Fin n) :
    signalEnergy (shift s k) = signalEnergy s := by
  unfold signalEnergy; simp +decide [ shift ] ;
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  · fin_cases k ; rfl;
  · exact Equiv.sum_comp ( Equiv.addRight k ) fun i => s i ^ 2

/-
Polarization identity relating autocorrelation to squared interval cost.
-/
theorem two_mul_autocorrelation_eq {n : ℕ} (s : Fin n → ℝ) (k : Fin n) :
    2 * autocorrelation s k = 2 * signalEnergy s - intervalEnergy s k := by
  unfold autocorrelation intervalEnergy signalEnergy;
  simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_assoc, shift ] ; ring;
  rw [ show ∑ x : Fin n, s ( x + k ) ^ 2 = ∑ x : Fin n, s x ^ 2 from ?_ ] ; ring;
  · norm_num [ Finset.sum_mul ];
  · rcases n with ( _ | _ | n ) <;> norm_num at *;
    · fin_cases k ; rfl;
    · exact Equiv.sum_comp ( Equiv.addRight k ) fun x => s x ^ 2

/-
Autocorrelation at every lag is bounded above by zero-lag energy.
-/
theorem autocorrelation_le_energy {n : ℕ} (s : Fin n → ℝ) (k : Fin n) :
    autocorrelation s k ≤ signalEnergy s := by
  linarith [ two_mul_autocorrelation_eq s k, show 0 ≤ intervalEnergy s k from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]

/-
The upper bound is sharp exactly for melodies fixed by the cyclic shift.
-/
theorem autocorrelation_eq_energy_iff {n : ℕ} (s : Fin n → ℝ) (k : Fin n) :
    autocorrelation s k = signalEnergy s ↔ shift s k = s := by
  constructor <;> intro h;
  · -- From the polarization identity, we have 2 * autocorrelation s k = 2 * signalEnergy s - intervalEnergy s k.
    have h_polarization : 2 * autocorrelation s k = 2 * signalEnergy s - intervalEnergy s k :=
      two_mul_autocorrelation_eq s k
    simp_all +decide [ funext_iff, intervalEnergy ];
    exact fun i => by nlinarith only [ h_polarization, Finset.single_le_sum ( fun i _ => sq_nonneg ( s i - shift s k i ) ) ( Finset.mem_univ i ) ] ;
  · unfold autocorrelation signalEnergy;
    simp +decide only [h, pow_two]

/-
A primitive-root Fourier transform determines all cyclic autocorrelations.
This is the structural bridge between lag statistics and the catalog's general
Fourier inversion theorem.
-/
theorem autocorrelation_determined_by_DFT
    {F : Type*} [Field F] {n : ℕ} {ω : F}
    (hω : IsPrimitiveRoot ω n) (hn : 0 < n) (hchar : (n : F) ≠ 0)
    (v w : Fin n → F)
    (hfreq : FourierTransformInversion.DFT ω v =
      FourierTransformInversion.DFT ω w) :
    (fun k => ∑ i, v i * v (i + k)) = (fun k => ∑ i, w i * w (i + k)) := by
  have := FourierTransformInversion.idft_dft hω hn hchar v;
  rw [ ← this, hfreq, FourierTransformInversion.idft_dft hω hn hchar ]

end MusicalDigits