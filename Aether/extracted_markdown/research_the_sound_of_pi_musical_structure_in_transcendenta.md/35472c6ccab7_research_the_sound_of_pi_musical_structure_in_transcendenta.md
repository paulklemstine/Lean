# The Sound of Pi: Musical Structure in Transcendental Constants

## Abstract

We introduce the *consonance spectrum*, a novel analytical tool that measures the autocorrelation of a real number's digit sequence at each of the 13 fundamental musical intervals (unison through octave) under the equal-tempered chromatic mapping. We develop a rigorous mathematical framework for studying musical structure in digit sequences, proving three principal results: (1) the Cauchy-Schwarz bound for digit autocorrelation, constraining the magnitude of all musical correlations; (2) the periodicity transfer theorem, showing that periodic digit sequences yield periodic autocorrelation functions; and (3) the spectral irrationality test, a contrapositive result providing a necessary condition for aperiodic digit expansions. We compute the consonance spectrum for π, e, and √2 using high-precision digit expansions, finding no statistically significant autocorrelation at any musical interval — consistent with the conjecture that these constants are normal in base 10. We formalize all results in the Lean 4 theorem prover with machine-verified proofs.

**Keywords:** digit autocorrelation, consonance spectrum, normal numbers, transcendental constants, equal temperament, Cauchy-Schwarz inequality, spectral analysis

---

## 1. Introduction

The decimal expansion of a real number defines a canonical sequence of digits d₀, d₁, d₂, ... ∈ {0, 1, ..., 9}. By mapping each digit to a frequency on the chromatic scale via f(d) = 220 · 2^{d/12} Hz, we obtain a "melody" — an infinite sequence of musical tones. This digit-to-frequency mapping assigns A3 (220 Hz) to digit 0, A#3 to digit 1, and so on through the chromatic scale.

The central question of this paper is: **do the digit sequences of transcendental constants exhibit statistically significant autocorrelation at musically meaningful lags?** In particular, we ask whether π "favors" octaves (lag 12), whether e "favors" perfect fifths (lag 7), or whether √2 "favors" minor thirds (lag 3).

Our answer is negative, but the mathematics underlying this negative result is rich and instructive.

### 1.1 Related Work

The study of digit distributions of mathematical constants has a long history. Borel (1909) introduced the concept of normal numbers — those whose digits are equidistributed in every base. The normality of π remains unproven, though extensive computational evidence supports it (Bailey and Crandall, 2001). The musical interpretation of digit sequences has been explored informally in popular science, but to our knowledge, no rigorous analysis of digit autocorrelation at musical intervals has been undertaken.

### 1.2 Contributions

1. **The consonance spectrum** (Definition 3.1): A novel mathematical object that bridges number theory, signal processing, and music theory.
2. **Cauchy-Schwarz autocorrelation bound** (Theorem 5.4): A tight upper bound on digit autocorrelation at any lag.
3. **Periodicity transfer theorem** (Theorem 5.3): Periodic sequences yield periodic autocorrelation.
4. **Spectral irrationality test** (Theorem 5.10): A necessary condition for non-periodic digit expansions.
5. **Chromatic octave theorem** (Theorem 5.5): The equal-tempered mapping preserves octave structure exactly.
6. **Streaming decomposition** (Theorem 5.9): Additive window splitting for incremental computation.
7. **Computational analysis** of π, e, and √2 consonance spectra.
8. **Machine-verified proofs** of all theoretical results in Lean 4.

---

## 2. Preliminaries

### 2.1 Notation

- **ℕ, ℤ, ℝ**: natural numbers, integers, reals
- **d : ℕ → ℤ**: a digit sequence (integer-valued for algebraic convenience)
- **R(k) = Σᵢ d(i) · d(i+k)**: unnormalized autocorrelation at lag k
- **R̃(k)**: centered autocorrelation (mean-subtracted)

### 2.2 Equal Temperament

The equal-tempered chromatic scale divides the octave into 12 equal semitones. The frequency ratio between consecutive semitones is 2^{1/12} ≈ 1.05946. Starting from A3 = 220 Hz:

| Digit | Note | Frequency (Hz) |
|-------|------|-----------------|
| 0     | A3   | 220.00          |
| 1     | A#3  | 233.08          |
| 2     | B3   | 246.94          |
| 3     | C4   | 261.63          |
| 4     | C#4  | 277.18          |
| 5     | D4   | 293.66          |
| 6     | D#4  | 311.13          |
| 7     | E4   | 329.63          |
| 8     | F4   | 349.23          |
| 9     | F#4  | 369.99          |

### 2.3 Musical Intervals as Lags

Each lag k ∈ {0, 1, ..., 12} corresponds to a musical interval:

| Lag | Interval        | Frequency Ratio |
|-----|----------------|-----------------|
| 0   | Unison         | 1:1             |
| 3   | Minor Third    | ~6:5            |
| 4   | Major Third    | ~5:4            |
| 5   | Perfect Fourth | ~4:3            |
| 7   | Perfect Fifth  | ~3:2            |
| 12  | Octave         | 2:1             |

---

## 3. Definitions

### Definition 3.1 (Digit Autocorrelation)

For a sequence d : ℕ → ℤ, window size N, and lag k:

$$R_N(k) = \sum_{i=0}^{N-1} d(i) \cdot d(i+k)$$

### Definition 3.2 (Centered Autocorrelation)

With centering value μ ∈ ℤ:

$$\tilde{R}_N(k) = \sum_{i=0}^{N-1} (d(i) - \mu)(d(i+k) - \mu)$$

For digits uniformly distributed on {0,...,9}, the natural center is μ ≈ 4.5. We use μ = 4 or μ = 5 for integer arithmetic.

### Definition 3.3 (Sequence Energy)

$$E_N(d) = \sum_{i=0}^{N-1} d(i)^2 = R_N(0)$$

### Definition 3.4 (Consonance Spectrum) [NOVEL]

The **consonance spectrum** of a digit sequence d with window N and center μ is the function:

$$\mathcal{C}_{N,\mu}(d) : \text{Fin}_{13} \to \mathbb{Z}, \quad \mathcal{C}_{N,\mu}(d)(k) = \tilde{R}_N(k)$$

This captures the autocorrelation profile at all 13 fundamental musical intervals (lags 0 through 12). For a sequence with no musical structure, the consonance spectrum is approximately flat at zero (for nonzero lags).

### Definition 3.5 (Consonant Structure)

A sequence has **consonant structure** at lag k with threshold τ if |R̃_N(k)| ≥ τ.

### Definition 3.6 (Periodic Sequence)

d is periodic with period p > 0 if d(i + p) = d(i) for all i ∈ ℕ.

### Definition 3.7 (Eventually Periodic Sequence)

d is eventually periodic if there exist p > 0 and N₀ such that d(i + p) = d(i) for all i ≥ N₀.

---

## 4. The Chromatic Frequency Mapping

### Definition 4.1

$$f : \mathbb{N} \to \mathbb{R}, \quad f(d) = 220 \cdot 2^{d/12}$$

### Properties

**Theorem 4.2 (Octave Doubling).**  
$f(d + 12) = 2 \cdot f(d)$ for all $d \in \mathbb{N}$.

*Proof.* $f(d+12) = 220 \cdot 2^{(d+12)/12} = 220 \cdot 2^{d/12 + 1} = 2 \cdot 220 \cdot 2^{d/12} = 2 \cdot f(d)$. □

**Theorem 4.3 (Positivity).**  
$f(d) > 0$ for all $d \in \mathbb{N}$.

*Proof.* Both 220 and $2^{d/12}$ are positive. □

---

## 5. Main Results

### Theorem 5.1 (Energy Identity)

$R_N(0) = E_N(d)$ — the autocorrelation at lag 0 equals the sum of squares.

*Proof.* Direct computation: $R_N(0) = \sum d(i) \cdot d(i+0) = \sum d(i)^2 = E_N(d)$. □

### Theorem 5.2 (Energy Non-negativity)

$R_N(0) \geq 0$ for all d, N.

*Proof.* Sum of squares is non-negative. □

### Theorem 5.3 (Periodicity Transfer)

If d(i + p) = d(i) for all i, then $R_N(k + p) = R_N(k)$ for all N, k.

*Proof sketch.* Each term in the sum for R_N(k+p) has the form d(i) · d(i+k+p). By the periodicity hypothesis applied to i+k, we have d(i+k+p) = d(i+k). Thus each term equals d(i) · d(i+k), and the sums agree. □

**Remark.** The contrapositive — Theorem 5.10 below — is the spectral irrationality test.

### Theorem 5.4 (Cauchy-Schwarz Autocorrelation Bound)

$$R_N(k)^2 \leq \left(\sum_{i=0}^{N-1} d(i)^2\right) \cdot \left(\sum_{i=0}^{N-1} d(i+k)^2\right)$$

*Proof sketch.* This is the Cauchy-Schwarz inequality applied to the vectors $(d(0), d(1), \ldots, d(N-1))$ and $(d(k), d(k+1), \ldots, d(N-1+k))$. The inner product of these vectors is exactly $R_N(k)$, and their squared norms are the two sums on the right. □

**Corollary 5.5.** For any sequence with values in {0,...,9}, we have $|R_N(k)| \leq 81N$ for all k.

### Theorem 5.6 (Center Zero Reduction)

$\tilde{R}_N(k; \mu=0) = R_N(k)$ — centering at zero recovers the uncentered autocorrelation.

### Theorem 5.7 (Unison Energy)

The consonance spectrum at lag 0 with center 0 equals the energy: $\mathcal{C}_{N,0}(d)(0) = E_N(d)$.

### Theorem 5.8 (Streaming Decomposition)

$$R_{N+M}(k) = R_N(k) + \sum_{i=0}^{M-1} d(N+i) \cdot d(N+i+k)$$

*Proof sketch.* Split the range [0, N+M) into [0, N) and [N, N+M). The first part gives $R_N(k)$. For the second part, re-index by setting j = i - N. □

**Application.** This decomposition enables streaming computation of the consonance spectrum. As new digits of π are computed, the consonance spectrum can be updated incrementally in O(1) time per digit per lag.

### Theorem 5.9 (Spectral Irrationality Test)

If there exist N and k such that $R_N(k+p) \neq R_N(k)$, then d is not periodic with period p.

*Proof.* Contrapositive of Theorem 5.3. If d were periodic with period p, then $R_N(k+p) = R_N(k)$ for all N, k — contradicting the hypothesis. □

---

## 6. Computational Results

### 6.1 Methodology

We computed the consonance spectrum for the first 10,000 digits of π, e, and √2 using high-precision arithmetic (mpmath with 10,050 decimal places). The centering value was μ = 4.5 (the mean of the uniform distribution on {0,...,9}).

### 6.2 Results

For all three constants, the normalized autocorrelation |R̃(k)/N| at every nonzero lag k ∈ {1,...,12} was below the 95% significance threshold of 2/√N ≈ 0.02. No musical interval showed statistically significant autocorrelation.

### 6.3 Interpretation

The absence of significant autocorrelation is consistent with the conjecture that π, e, and √2 are normal in base 10. If a number is normal, its digit pairs (dᵢ, dᵢ₊ₖ) are asymptotically equidistributed over {0,...,9}², which implies the centered autocorrelation converges to zero at every lag.

---

## 7. Conjecture: Autocorrelation Nullity for Normal Numbers

**Conjecture 7.1.** Let d be the digit sequence (in base 10) of a normal number. Then for all k ≥ 1 and all centering values μ:

$$\lim_{N \to \infty} \frac{1}{N} \sum_{i=0}^{N-1} (d(i) - \mu)(d(i+k) - \mu) = 0$$

**Testable prediction.** For the first 10⁶ digits of π:
- The normalized autocorrelation |R̃(k)/N| < 0.002 for all k ∈ {1,...,12}.
- The chi-squared statistic for digit uniformity satisfies χ² < 16.92 (df = 9, α = 0.05).

If either test fails, the conjecture is refuted for π at the given sample size, and would constitute evidence against the normality of π.

**Relation to normality.** Conjecture 7.1 is strictly weaker than base-10 normality. Normality requires equidistribution of all finite digit blocks; our conjecture requires only pairwise digit independence at each lag. A proof of normality for π would immediately imply Conjecture 7.1, but the converse is false.

---

## 8. Discussion

### 8.1 The Silence Is the Signal

Our most important finding is negative: transcendental constants do not have hidden musical structure in their digit sequences. The consonance spectrum is flat. But this flatness itself is deeply meaningful — it reflects the maximal information content of normal digit sequences.

### 8.2 The Periodicity-Irrationality Bridge

The periodicity transfer theorem (5.3) and its contrapositive (5.9) create a precise bridge between temporal structure (periodicity) in digit sequences and algebraic structure (rationality) of the underlying number. This bridge operates through the autocorrelation function, which serves as a "spectral lens" for examining digit patterns.

### 8.3 The Role of Cauchy-Schwarz

The Cauchy-Schwarz bound (Theorem 5.4) is not merely a technical tool — it is a fundamental constraint on the possible musical structures in any digit sequence. It tells us that no lag can produce correlations exceeding the energy, and for sequences with bounded digit values, this constrains the absolute autocorrelation to grow at most linearly with N. For normal numbers, the actual growth is o(N), making the normalized autocorrelation vanish.

### 8.4 Connections to Existing Work

Our chromatic frequency mapping connects to the Pythagorean music theory formalized in `Pythagorean/HarmonicMusicTheory.lean`, where frequency ratios from Pythagorean triples are classified by consonance. The present work shifts from rational frequency ratios (Pythagorean tuning) to equal-tempered frequencies (chromatic scale), reflecting the historical transition from just intonation to equal temperament.

---

## 9. Algorithms

### Algorithm 1: Consonance Spectrum Computation

```
Input: digit sequence d[0..N-1], center μ, max_lag L
Output: consonance spectrum C[0..L]

for k = 0 to L:
    C[k] = 0
    for i = 0 to N-k-1:
        C[k] += (d[i] - μ) * (d[i+k] - μ)
    C[k] /= (N - k)
return C
```

Time complexity: O(N · L). Space: O(L).

### Algorithm 2: Streaming Autocorrelation Update

```
Input: current R_N(k), new digits d[N..N+M-1], lag k
Output: updated R_{N+M}(k)

delta = 0
for i = 0 to M-1:
    delta += d[N+i] * d[N+i+k]
return R_N(k) + delta
```

This exploits Theorem 5.8 for incremental updates.

---

## 10. Future Work

1. **Prove Conjecture 7.1** for specific classes of normal numbers (e.g., Champernowne's constant, which is known to be normal in base 10).
2. **Extend to block autocorrelation**: study correlations between digit blocks (bigrams, trigrams) at musical lags.
3. **Cross-base analysis**: compare the consonance spectrum of π in bases 10, 12, and 7 (the last matching the diatonic scale).
4. **Connections to continued fractions**: investigate whether the continued fraction expansion of a number influences the structure of its digit autocorrelation.

---

## References

1. Borel, E. (1909). Les probabilités dénombrables et leurs applications arithmétiques. *Rendiconti del Circolo Matematico di Palermo*, 27, 247–271.
2. Bailey, D. H., & Crandall, R. E. (2001). On the random character of fundamental constant expansions. *Experimental Mathematics*, 10(2), 175–190.
3. Hardy, G. H., & Wright, E. M. (2008). *An Introduction to the Theory of Numbers* (6th ed.). Oxford University Press.

---

## Appendix A: Formalization Details

All theorems in this paper have been formally verified in Lean 4 using the Mathlib library. The formalization is contained in `Geometry/DigitMelody.lean`. Key aspects:

- Autocorrelation is defined over ℤ-valued sequences to avoid subtraction issues with ℕ.
- The Cauchy-Schwarz bound uses Mathlib's `sum_mul_sq_le_sq_mul_sq` lemma.
- The chromatic frequency uses `Real.rpow` for non-integer exponents.
- The consonance spectrum is typed as `Fin 13 → ℤ` for the 13 musical intervals.
- The periodicity transfer theorem is proved by congruence under the Finset sum.
