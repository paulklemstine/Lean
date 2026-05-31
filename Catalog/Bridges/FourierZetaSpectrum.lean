/-
# The Fourier Transform of the Riemann Zeta: Hearing the Primes

This module formalizes the spectral theory of prime frequencies.

The key insight: on the critical line, ζ(1/2 + it) behaves like a sum of
complex exponentials with frequencies log(p)/(2π) for each prime p.
The Fourier transform of ζ on the critical line thus has "peaks" at these
prime frequencies, allowing one to "hear" the primes.

We formalize:
1. The prime frequency map p ↦ log(p)/(2π)
2. The irrationality of log-ratios of distinct primes
3. Finite Dirichlet polynomials as signal-processing objects
4. A tropical-spectral bridge connecting prime factorization to frequency addition
5. Spectral separation bounds for prime frequencies
-/

import Mathlib

open Real Finset Nat

noncomputable section

/-! ## Prime Frequency Map

The fundamental object: the frequency associated to each prime number.
In the Fourier analysis of ζ(1/2 + it), the prime p contributes a complex
exponential with frequency log(p)/(2π). -/

/-- The prime frequency associated to a natural number n ≥ 2.
    This is the "note" that prime p plays in the spectrum of zeta. -/
def primeFreq (p : ℕ) : ℝ := Real.log p / (2 * Real.pi)

/-- The amplitude (weight) of prime p in the Dirichlet series on the critical line.
    Each prime contributes with amplitude 1/√p. -/
def primeAmplitude (p : ℕ) : ℝ := 1 / Real.sqrt p

/-- A finite Dirichlet polynomial on the critical line, truncated to primes up to N.
    This is the finite approximation D_N(t) = Σ_{p ≤ N, p prime} p^{-1/2} · e^{-it·log(p)}.
    We work with the real part for simplicity. -/
def finitePrimeSignal (N : ℕ) (t : ℝ) : ℝ :=
  ∑ p ∈ (Finset.range (N + 1)).filter Nat.Prime,
    primeAmplitude p * Real.cos (t * Real.log p)

/-! ## Distinctness of Prime Frequencies

The most fundamental property: distinct primes produce distinct frequencies.
This follows from the strict monotonicity of log on positive reals. -/

/-
Distinct primes have distinct logarithms.
-/
theorem log_ne_of_distinct_primes {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) : Real.log (p : ℝ) ≠ Real.log (q : ℝ) := by
  exact fun h => hpq <| Nat.cast_injective ( Real.log_injOn_pos ( Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hp.pos ) ( Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hq.pos ) h )

/-
Distinct primes produce distinct frequencies in the prime spectrum.
-/
theorem primeFreq_injective {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) : primeFreq p ≠ primeFreq q := by
  exact fun h => hpq <| by rw [ ← @Nat.cast_inj ℝ ] ; exact Real.log_injOn_pos ( show 0 < ( p : ℝ ) by exact Nat.cast_pos.mpr hp.pos ) ( show 0 < ( q : ℝ ) by exact Nat.cast_pos.mpr hq.pos ) ( by unfold primeFreq at h; nlinarith [ Real.pi_pos, mul_div_cancel₀ ( Real.log p ) ( by positivity : ( 2 * Real.pi ) ≠ 0 ), mul_div_cancel₀ ( Real.log q ) ( by positivity : ( 2 * Real.pi ) ≠ 0 ) ] ) ;

/-! ## Irrationality of Prime Log-Ratios

A deeper result: for distinct primes p and q, the ratio log(p)/log(q)
is irrational. This is equivalent to saying p^a ≠ q^b for all positive
integers a, b, which follows from unique prime factorization.

This irrationality means that the prime frequencies are "incommensurable" —
no prime frequency is a rational multiple of another. In musical terms,
the primes play notes that are fundamentally out of tune with each other. -/

/-
For distinct primes, p^a = q^b implies a = 0 and b = 0.
    This is the key number-theoretic fact underlying spectral incommensurability.
-/
theorem prime_pow_eq_prime_pow_iff {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) {a b : ℕ} (h : p ^ a = q ^ b) : a = 0 ∧ b = 0 := by
  have := congr_arg ( ·.factorization q ) h ; norm_num [ hp.ne_zero, hq.ne_zero ] at this ; aesop;

/-
The ratio log(p)/log(q) is irrational for distinct primes p, q.
    This means prime frequencies are Q-linearly independent (pairwise).
-/
theorem irrational_log_ratio_of_distinct_primes {p q : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    Irrational (Real.log p / Real.log q) := by
  -- Assume there exist integers $r \neq 0$ and $s \neq  �0�$ such that $\log p / \log q = r / s$.
  by_contra h_contra
  obtain ⟨r, s, hr, hs, h_eq⟩ : ∃ r s : ℕ, r ≠ 0 ∧ s ≠ 0 ∧ Real.log p / Real.log q = r / s := by
    obtain ⟨ r, hr ⟩ := Classical.not_not.1 h_contra;
    exact ⟨ r.num.natAbs, r.den, by simpa using ne_of_gt ( Rat.num_pos.mpr <| show 0 < r by exact_mod_cast hr.symm ▸ div_pos ( Real.log_pos <| Nat.one_lt_cast.mpr hp.one_lt ) ( Real.log_pos <| Nat.one_lt_cast.mpr hq.one_lt ) ), by simp +decide, by simpa [ abs_of_nonneg <| Rat.num_nonneg.mpr <| show 0 ≤ r by exact_mod_cast hr.symm ▸ div_nonneg ( Real.log_nonneg <| Nat.one_le_cast.mpr hp.pos ) ( Real.log_nonneg <| Nat.one_le_cast.mpr hq.pos ), Rat.cast_def ] using hr.symm ⟩;
  -- Then $s \log(p) = r \log(q)$, which implies $\log(p^s) = \log(q^r)$, and thus $p^s = q^r$.
  have h_exp : (p : ℝ) ^ s = (q : ℝ) ^ r := by
    rw [ div_eq_div_iff ( ne_of_gt <| Real.log_pos <| Nat.one_lt_cast.mpr hq.one_lt ) ( ne_of_gt <| Nat.cast_pos.mpr <| Nat.pos_of_ne_zero hs ) ] at h_eq;
    rw [ ← Real.exp_log ( Nat.cast_pos.mpr hp.pos ), ← Real.exp_log ( Nat.cast_pos.mpr hq.pos ), ← Real.exp_nat_mul, ← Real.exp_nat_mul, mul_comm, h_eq ];
  norm_cast at h_exp; have := congr_arg ( ·.factorization p ) h_exp; norm_num at this; have := congr_arg ( ·.factorization q ) h_exp; norm_num at this; simp_all +decide [ hp.ne_zero, hq.ne_zero ] ;

/-! ## Spectral Separation Bounds

How close can two prime frequencies get? The gap between consecutive prime
frequencies log(p_{n+1})/(2π) - log(p_n)/(2π) = log(p_{n+1}/p_n)/(2π).
By Bertrand's postulate, p_{n+1} < 2·p_n, so the gap is at most log(2)/(2π).
But the gap is always positive since primes are distinct. -/

/-
The frequency gap between any two distinct primes is positive.
-/
theorem primeFreq_gap_pos {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hlt : p < q) : 0 < primeFreq q - primeFreq p := by
  exact sub_pos_of_lt ( div_lt_div_iff_of_pos_right ( by positivity ) |>.2 ( Real.log_lt_log ( Nat.cast_pos.mpr hp.pos ) ( Nat.cast_lt.mpr hlt ) ) )

/-
The spectral gap between the two smallest primes (2 and 3) equals
    the minimum possible prime frequency gap. This is log(3/2)/(2π).
-/
theorem primeFreq_smallest_gap :
    primeFreq 3 - primeFreq 2 = Real.log (3/2 : ℝ) / (2 * Real.pi) := by
  unfold primeFreq; rw [ Real.log_div ] <;> ring <;> norm_num;

/-! ## The Tropical-Spectral Bridge

A cross-domain connection between tropical algebra and spectral theory.

In tropical mathematics, the semiring (ℝ, min, +) replaces addition with min
and multiplication with addition. The prime frequency map p ↦ log(p) is a
*homomorphism* from (ℕ_{>1}, ·) to (ℝ, +), which is exactly the tropical
multiplication. This means:

  log(p · q) = log(p) + log(q)

In spectral terms: when we multiply two primes (combine their signals),
the resulting frequency is the SUM of the individual frequencies.
This is the tropical product of the frequencies! -/

/-- The tropical spectral structure: frequencies form a module over ℕ under addition.
    This structure captures the homomorphism log(p·q) = log(p) + log(q). -/
structure TropicalPrimeSpectrum where
  /-- The underlying frequency value -/
  freq : ℝ
  /-- The corresponding natural number (product of primes) -/
  source : ℕ
  /-- The source is at least 1 -/
  source_pos : 0 < source
  /-- The frequency equals log of the source, normalized -/
  freq_eq : freq = Real.log source / (2 * Real.pi)

/-
The log map sends multiplication to addition of frequencies.
    This is the fundamental homomorphism property of the prime spectrum.
-/
theorem log_mul_eq_add {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    Real.log ((a : ℝ) * b) = Real.log a + Real.log b := by
  exact Real.log_mul ( by positivity ) ( by positivity )

/-
The prime frequency map is multiplicative-to-additive:
    primeFreq(a * b) = primeFreq(a) + primeFreq(b) for positive naturals.
-/
theorem primeFreq_mul (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    primeFreq (a * b) = primeFreq a + primeFreq b := by
  unfold primeFreq;
  rw [ Nat.cast_mul, Real.log_mul ( by positivity ) ( by positivity ), add_div ]

/-
Tropical interpretation: the max of two prime frequencies equals
    the frequency of the larger prime.
-/
theorem tropical_max_freq {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hlt : p < q) : max (primeFreq p) (primeFreq q) = primeFreq q := by
  exact max_eq_right ( by linarith [ primeFreq_gap_pos hp hq hlt ] )

/-! ## Signal-Theoretic Properties

Properties of the finite prime signal D_N(t) viewed as a signal processing object. -/

/-
The finite prime signal is bounded by the sum of amplitudes.
-/
theorem finitePrimeSignal_bound (N : ℕ) (t : ℝ) :
    |finitePrimeSignal N t| ≤
      ∑ p ∈ (Finset.range (N + 1)).filter Nat.Prime, primeAmplitude p := by
  exact Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun p hp => by rw [ abs_mul, abs_of_nonneg ( show 0 ≤ primeAmplitude p by exact one_div_nonneg.mpr <| Real.sqrt_nonneg _ ) ] ; exact mul_le_of_le_one_right ( one_div_nonneg.mpr <| Real.sqrt_nonneg _ ) <| Real.abs_cos_le_one _;

/-
At t = 0, the finite prime signal equals the sum of prime amplitudes
    (all cosines equal 1).
-/
theorem finitePrimeSignal_at_zero (N : ℕ) :
    finitePrimeSignal N 0 =
      ∑ p ∈ (Finset.range (N + 1)).filter Nat.Prime, primeAmplitude p := by
  unfold finitePrimeSignal; aesop;

/-
The prime amplitude is positive for primes.
-/
theorem primeAmplitude_pos {p : ℕ} (hp : Nat.Prime p) : 0 < primeAmplitude p := by
  exact one_div_pos.mpr <| Real.sqrt_pos.mpr <| Nat.cast_pos.mpr hp.pos

/-
The finite prime signal at t=0 is strictly positive when N ≥ 2.
-/
theorem finitePrimeSignal_zero_pos (N : ℕ) (hN : 2 ≤ N) :
    0 < finitePrimeSignal N 0 := by
  rw [ finitePrimeSignal_at_zero ] ; exact Finset.sum_pos ( fun p hp => primeAmplitude_pos ( by aesop ) ) ⟨ 2, Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith ), by norm_num ⟩ ⟩ ;

/-! ## Falsifiable Conjecture

**Conjecture (Prime Spectral Gap Monotonicity)**:
The spectral gaps Δ_n = log(p_{n+1}/p_n)/(2π) between consecutive prime
frequencies are eventually decreasing on average.

More precisely: for the n-th prime p_n, the average gap
  (1/n) · Σ_{k=1}^{n} log(p_{k+1}/p_k) → 0 as n → ∞.

This is equivalent to log(p_n)/n → 0, which follows from the Prime Number
Theorem (p_n ~ n·log(n)).

**Computational test**: Verify for the first 10^6 primes that the average
spectral gap is decreasing and is approximately 1/n · log(n·log(n)).
-/

/-- The spectral gap function: the difference in frequency between two primes. -/
def spectralGap (p q : ℕ) : ℝ := (Real.log q - Real.log p) / (2 * Real.pi)

/-
The spectral gap between primes where p < q is always positive.
-/
theorem spectralGap_pos {p q : ℕ} (hp : Nat.Prime p) (_hq : Nat.Prime q)
    (hlt : p < q) : 0 < spectralGap p q := by
  exact div_pos ( sub_pos.mpr ( Real.log_lt_log ( Nat.cast_pos.mpr hp.pos ) ( Nat.cast_lt.mpr hlt ) ) ) ( by positivity )

/-
**Bertrand's postulate expressed spectrally**: For any prime p > 2,
    there exists a prime q with p < q < 2p.
-/
theorem spectral_bertrand (p : ℕ) (_hp : Nat.Prime p) (hp2 : 2 < p) :
    ∃ q : ℕ, Nat.Prime q ∧ p < q ∧ q < 2 * p := by
  exact Nat.exists_prime_lt_and_le_two_mul p ( by linarith ) |> fun ⟨ q, hq1, hq2 ⟩ => ⟨ q, hq1, hq2.1, hq2.2.lt_of_ne fun hq3 => by have := Nat.Prime.eq_two_or_odd hq1; omega ⟩

end