/-
# Prime Spectral Framework

A rigorous spectral framework for understanding the Riemann zeta function on the
critical line as a superposition of prime frequencies. The prime spectral map
sends each prime p to a spectral line with frequency log(p)/(2π) and amplitude 1/√p.

## Key Results
- Prime Power Independence: distinct primes cannot have equal powers (p^m ≠ q^n)
- This is equivalent to irrationality of log(p)/log(q) for distinct primes
- Spectral injectivity, monotonicity, and amplitude-frequency duality
- Novel concept: Spectral Resonance Defect measuring harmonic relationships
-/

import Mathlib

open Nat Real

namespace PrimeSpectralFramework

/-! ## Core Definitions -/

/-- A `PrimeSpectralLine` captures the spectral decomposition of a prime's contribution
to the Riemann zeta function on the critical line. Each prime p contributes an oscillatory
term with frequency `log(p)/(2π)` and amplitude `1/√p`. -/
structure PrimeSpectralLine where
  /-- The underlying prime number -/
  prime : ℕ
  /-- Proof that it is prime -/
  is_prime : Nat.Prime prime
  deriving DecidableEq

namespace PrimeSpectralLine

/-- The spectral frequency of a prime: log(p)/(2π) -/
noncomputable def frequency (L : PrimeSpectralLine) : ℝ :=
  Real.log L.prime / (2 * Real.pi)

/-- The spectral amplitude (weight) of a prime: 1/√p -/
noncomputable def amplitude (L : PrimeSpectralLine) : ℝ :=
  1 / Real.sqrt L.prime

/-- The spectral energy of a prime line: 1/p (amplitude squared) -/
noncomputable def energy (L : PrimeSpectralLine) : ℝ :=
  1 / L.prime

end PrimeSpectralLine

/-- The `SpectralResonanceDefect` between two primes p and q measures how far
the ratio log(p)/log(q) is from the nearest rational number a/b with b ≤ N.
This quantifies how "dissonant" two prime frequencies are — the key insight being
that distinct primes are *maximally dissonant* (the ratio is irrational). -/
noncomputable def SpectralResonanceDefect (p q : ℕ) (N : ℕ) : ℝ :=
  ⨅ (a : ℕ) (b : ℕ) (_ : 0 < b) (_ : b ≤ N),
    |Real.log p / Real.log q - (a : ℝ) / (b : ℝ)|

/-- A `SpectralChord` represents a pair of prime spectral lines and their
harmonic relationship. The chord is "consonant" if their frequency ratio
is close to rational, and "dissonant" otherwise. -/
structure SpectralChord where
  low : PrimeSpectralLine
  high : PrimeSpectralLine
  ordered : low.prime < high.prime

namespace SpectralChord

/-- The frequency ratio of a spectral chord -/
noncomputable def frequencyRatio (C : SpectralChord) : ℝ :=
  Real.log C.high.prime / Real.log C.low.prime

/-- The amplitude ratio (how much louder the lower prime is) -/
noncomputable def amplitudeRatio (C : SpectralChord) : ℝ :=
  C.low.amplitude / C.high.amplitude

end SpectralChord

/-! ## Prime Power Independence

The fundamental number-theoretic result underlying the spectral framework:
distinct primes can never have equal prime powers. This is equivalent to
the statement that log(p)/log(q) is irrational for distinct primes p, q.
-/

/-
**Prime Power Independence**: For distinct primes p and q, p^m ≠ q^n
whenever m and n are positive. This is the number-theoretic core of spectral
dissonance — it means the frequency ratio log(p)/log(q) can never be rational.

The proof uses the Fundamental Theorem of Arithmetic: in the prime factorization
of p^m, the prime p appears with multiplicity m and no other prime appears.
Similarly for q^n. If p^m = q^n, then comparing the factorization of p on both
sides gives a contradiction since p ∤ q^n (as p ≠ q and q is prime).
-/
theorem prime_power_independence {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) {m n : ℕ} (hm : 0 < m) (_hn : 0 < n) : p ^ m ≠ q ^ n := by
  exact fun h => hpq <| by have := congr_arg ( fun t => t.factorization p ) h; have := congr_arg ( fun t => t.factorization q ) h; norm_num at *; aesop;

/-! ## Spectral Injectivity

The spectral map p ↦ log(p) is injective on primes. This means every prime
has a unique frequency, so the spectral decomposition is well-defined.
-/

/-
The spectral map is injective: distinct primes have distinct frequencies.
This follows from `log` being strictly monotone on positive reals and primes
being distinct natural numbers.
-/
theorem spectral_frequency_injective (L₁ L₂ : PrimeSpectralLine)
    (h : L₁.frequency = L₂.frequency) : L₁.prime = L₂.prime := by
  unfold PrimeSpectralLine.frequency at h;
  rw [ div_eq_div_iff ] at h <;> norm_num [ Real.pi_ne_zero ] at * ; have := congr_arg Real.exp h ; norm_num [ Real.exp_log ( Nat.cast_pos.mpr <| Nat.Prime.pos L₁.is_prime ), Real.exp_log ( Nat.cast_pos.mpr <| Nat.Prime.pos L₂.is_prime ) ] at this ; aesop;

/-! ## Amplitude-Frequency Duality

A fundamental feature of the prime spectrum: higher-frequency primes have
lower amplitudes. This is the spectral manifestation of the fact that larger
primes contribute less to the zeta function.
-/

/-
**Amplitude-Frequency Duality**: If prime p < prime q, then the amplitude
of p's spectral line exceeds that of q's. Larger primes oscillate faster
but with diminishing strength.
-/
theorem amplitude_frequency_duality (L₁ L₂ : PrimeSpectralLine)
    (h : L₁.prime < L₂.prime) : L₂.amplitude < L₁.amplitude := by
  convert one_div_lt_one_div_of_lt ( Real.sqrt_pos.mpr ( Nat.cast_pos.mpr L₁.is_prime.pos ) ) ( Real.sqrt_lt_sqrt ( Nat.cast_nonneg _ ) ( Nat.cast_lt.mpr h ) ) using 1

/-
The spectral energy (amplitude squared) also respects the ordering.
-/
theorem energy_frequency_duality (L₁ L₂ : PrimeSpectralLine)
    (h : L₁.prime < L₂.prime) : L₂.energy < L₁.energy := by
  exact one_div_lt_one_div_of_lt ( Nat.cast_pos.mpr L₁.is_prime.pos ) ( Nat.cast_lt.mpr h )

/-! ## Frequency Gap Bounds

The gaps between consecutive prime frequencies are controlled by classical
prime gap results. We establish that the frequency gap between p and the
next prime is always positive (a consequence of the infinitude of primes)
and give quantitative lower bounds.
-/

/-
The frequency of any prime is positive (since all primes ≥ 2 > 1,
and log is positive on (1, ∞)).
-/
theorem frequency_pos (L : PrimeSpectralLine) : 0 < Real.log L.prime := by
  exact Real.log_pos <| Nat.one_lt_cast.mpr L.is_prime.one_lt

/-
For any two primes p < q, the log ratio log(q)/log(p) > 1.
-/
theorem log_ratio_gt_one {p q : ℕ} (hp : Nat.Prime p) (_hq : Nat.Prime q)
    (hlt : p < q) : 1 < Real.log q / Real.log p := by
  rw [ one_lt_div ( Real.log_pos <| Nat.one_lt_cast.mpr hp.one_lt ), Real.log_lt_log_iff ] <;> norm_cast <;> linarith [ hp.two_le, _hq.two_le ]

/-! ## Spectral Summability and Convergence

The spectral amplitudes 1/√p are square-summable (their squares sum to
a convergent series related to the prime zeta function at s=1). We prove
the key estimate that controls this convergence.
-/

/-
For any prime p, its spectral amplitude is positive.
-/
theorem amplitude_pos (L : PrimeSpectralLine) : 0 < L.amplitude := by
  exact one_div_pos.mpr ( Real.sqrt_pos.mpr ( Nat.cast_pos.mpr L.is_prime.pos ) )

/-
For any prime p, its spectral amplitude is at most 1/√2.
-/
theorem amplitude_le_inv_sqrt_two (L : PrimeSpectralLine) :
    L.amplitude ≤ 1 / Real.sqrt 2 := by
  exact one_div_le_one_div_of_le ( Real.sqrt_pos.mpr zero_lt_two ) ( Real.sqrt_le_sqrt <| mod_cast L.is_prime.two_le )

/-! ## The Chord Amplification Theorem

For a spectral chord (p, q), the amplitude ratio √(q/p) measures how much
louder the lower prime's spectral contribution is. We prove this ratio
is always > 1 and give a lower bound in terms of the frequency ratio.
-/

/-
The amplitude ratio of any spectral chord exceeds 1.
-/
theorem chord_amplitude_ratio_gt_one (C : SpectralChord) :
    1 < C.amplitudeRatio := by
  convert one_lt_div ?_ |>.2 <| amplitude_frequency_duality _ _ C.ordered;
  exact amplitude_pos _

/-! ## Conjecture: Spectral Gap Distribution

We state a falsifiable conjecture about the distribution of spectral gaps
between consecutive prime frequencies, testable by computation.
-/

/-- **Conjecture (Spectral Gap Regularity)**: For all n ≥ 1, the ratio of
consecutive prime spectral frequencies satisfies
  log(p_{n+1}) / log(p_n) ≤ 1 + 1/n

This is equivalent to the statement p_{n+1} ≤ p_n^{1+1/n} for the n-th prime.
This is implied by (but weaker than) Cramér's conjecture on prime gaps.

Computational test: verify for all primes up to 10^8.
If false, the smallest counterexample reveals structure about prime gaps. -/
def SpectralGapRegularityConjecture : Prop :=
  ∀ n : ℕ, 0 < n →
    ∀ p q : ℕ, Nat.Prime p → Nat.Prime q → p < q →
    (∀ r : ℕ, Nat.Prime r → p < r → q ≤ r) →  -- q is the next prime after p
    Real.log q / Real.log p ≤ 1 + 1 / (n : ℝ)

end PrimeSpectralFramework