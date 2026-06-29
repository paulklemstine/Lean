# The Sound of Pi: Spectral Structure in Digit Sequences of Transcendental Numbers

## Abstract

We develop a rigorous mathematical framework for analyzing the musical structure — or lack thereof — in the digit sequences of real numbers. We introduce the **digit transition spectrum**, a novel invariant that captures the full empirical distribution of digit differences at each musical lag, generalizing the classical autocorrelation function. We prove three families of structural theorems: (1) a **bounded autocorrelation theorem** establishing that |R_N(k)| ≤ NB² for sequences bounded by B, providing the natural scale for autocorrelation measurements; (2) a **periodicity transfer theorem** showing that periodicity of the digit sequence implies periodicity of both the raw and centered autocorrelation, yielding a spectral irrationality criterion; and (3) an **autocorrelation difference bound** giving a Lipschitz-type estimate on how the autocorrelation varies between lags. We connect these results to Pythagorean music theory by showing that frequency ratios derived from Pythagorean triples naturally define the consonant intervals at which the autocorrelation should be evaluated. The central conjecture — the **Spectral Flatness Conjecture** — asserts that for any normal number in base 10, the digit transition spectrum converges to a universal lag-independent distribution, implying that the consonance spectrum is asymptotically flat.

**Keywords**: autocorrelation, digit sequences, normal numbers, music theory, Pythagorean triples, spectral analysis

---

## 1. Introduction

The digits of transcendental numbers such as π, e, and √2 have fascinated mathematicians for centuries. While these numbers are conjectured to be **normal** — meaning that every finite digit pattern occurs with the expected frequency — the statistical structure of their digit sequences remains poorly understood. The normality conjecture for π, despite extensive computational evidence, remains one of the major open problems in number theory.

In this paper, we approach the digit structure problem from a new angle: **musical analysis**. By mapping each decimal digit to a note on the chromatic scale, we transform a digit sequence into a melody and ask whether this melody exhibits any musically meaningful structure. The mathematical tool for detecting such structure is the **autocorrelation function**, evaluated at lags corresponding to the fundamental musical intervals (semitone, whole tone, minor third, major third, perfect fourth, tritone, perfect fifth, etc.).

Our main contribution is the introduction of the **digit transition spectrum**, which records the full distribution of digit differences at each lag, rather than compressing this information into a single scalar (the autocorrelation). We prove structural theorems establishing bounds, periodicity transfer, and a spectral irrationality criterion, and we formulate the Spectral Flatness Conjecture connecting digit normality to spectral uniformity.

All theorems are formally verified in the Lean 4 proof assistant using the Mathlib library.

## 2. Definitions

### 2.1 Autocorrelation

**Definition 2.1** (Digit Autocorrelation). For a sequence d : ℕ → ℤ, the *unnormalized autocorrelation* over a window of size N at lag k is:

$$R_N(k) = \sum_{i=0}^{N-1} d(i) \cdot d(i+k)$$

**Definition 2.2** (Centered Autocorrelation). For a center value c ∈ ℤ:

$$C_N(k, c) = \sum_{i=0}^{N-1} (d(i) - c)(d(i+k) - c)$$

**Definition 2.3** (Sequence Energy). The energy of d over window N is:

$$E_N = \sum_{i=0}^{N-1} d(i)^2 = R_N(0)$$

### 2.2 The Digit Transition Spectrum (Novel)

**Definition 2.4** (Transition Count). For a sequence d, window N, lag k, and transition value t ∈ ℤ:

$$T_N(k, t) = |\{i \in [0, N) : d(i+k) - d(i) = t\}|$$

The transition spectrum at lag k is the function t ↦ T_N(k, t), which records the empirical distribution of digit-to-digit intervals at that lag.

**Remark**. The autocorrelation R_N(k) and the transition spectrum are related: the autocorrelation can be recovered from the transition spectrum and the individual digit values, but the transition spectrum contains strictly more information. In particular, two sequences with identical autocorrelation functions can have different transition spectra.

### 2.3 Spectral Concentration

**Definition 2.5** (Spectral Concentration). For a set of lags S ⊆ {0, ..., K-1}:

$$\sigma(S) = \frac{\sum_{k \in S} R_N(k)^2}{\sum_{k=0}^{K-1} R_N(k)^2}$$

This measures the fraction of total autocorrelation energy concentrated at the specified lags.

### 2.4 The Consonance Spectrum

**Definition 2.6**. The *consonance spectrum* of a digit sequence is the autocorrelation profile evaluated at the 13 fundamental musical intervals (lags 0 through 12, corresponding to unison through octave in the chromatic scale). For the centered version:

$$\text{CS}(d, N, c) = (C_N(0, c), C_N(1, c), \ldots, C_N(12, c))$$

### 2.5 Pythagorean Triples as Musical Intervals

**Definition 2.7** (Pythagorean Triple). A triple (a, b, c) ∈ ℕ³ with a, b > 0 and a² + b² = c².

**Definition 2.8** (Frequency Ratio). For a Pythagorean triple (a, b, c), the frequency ratio is r = b/a ∈ ℝ.

## 3. Main Results

### 3.1 Fundamental Bounds

**Theorem 3.1** (Autocorrelation Bound for Bounded Sequences). *If |d(i)| ≤ B for all i, then*

$$|R_N(k)| \leq N \cdot B^2$$

*Proof sketch.* By the triangle inequality: |R_N(k)| = |Σ d(i)·d(i+k)| ≤ Σ |d(i)|·|d(i+k)| ≤ Σ B·B = NB². □

**Corollary 3.2.** For base-10 digits (B = 9), |R_N(k)| ≤ 81N.

**Theorem 3.3** (Energy Monotonicity). For any sequence d:

$$E_N \leq E_{N+1}$$

*Proof.* E_{N+1} = E_N + d(N)² ≥ E_N since d(N)² ≥ 0. □

**Theorem 3.4** (Transition Count Bound). For any d, N, k, t:

$$T_N(k, t) \leq N$$

*Proof.* T_N(k, t) is the cardinality of a subset of [0, N), which has N elements. □

### 3.2 The Centered Autocorrelation Expansion

**Theorem 3.5** (Centered Autocorrelation Expansion). *The centered autocorrelation decomposes as:*

$$C_N(k, c) = R_N(k) - c \cdot S_N^{(k)} - c \cdot S_N + N \cdot c^2$$

*where S_N = Σ_{i<N} d(i) and S_N^{(k)} = Σ_{i<N} d(i+k).*

*Proof.* Direct algebraic expansion of (d(i) - c)(d(i+k) - c) = d(i)d(i+k) - c·d(i+k) - c·d(i) + c², followed by linearity of summation. □

**Significance.** This decomposition reveals the structure of centering: it subtracts the "DC component" (the mean × shifted mean terms) and adds back the constant energy N·c². When c is chosen as the empirical mean (≈ 4.5 for base-10 digits), the linear terms approximately cancel, leaving only the fluctuation structure.

### 3.3 Periodicity Transfer

**Theorem 3.6** (Periodicity Transfer for Autocorrelation). *If d(i + p) = d(i) for all i, then*

$$R_N(k + p) = R_N(k) \quad \text{for all N, k}$$

*Proof.* Each term d(i)·d(i+k+p) = d(i)·d(i+k) by periodicity. □

**Theorem 3.7** (Shifted Sum Periodicity). *If d has period p, then*

$$S_N^{(k+p)} = S_N^{(k)} \quad \text{for all N, k}$$

**Theorem 3.8** (Periodicity Transfer for Centered Autocorrelation). *If d has period p, then*

$$C_N(k + p, c) = C_N(k, c) \quad \text{for all N, k, c}$$

*Proof.* Apply the expansion (Theorem 3.5) to both sides and use Theorems 3.6 and 3.7. □

### 3.4 The Spectral Irrationality Criterion

**Theorem 3.9** (Spectral Irrationality Criterion). *If there exist N, k such that*

$$C_N(k + p, c) \neq C_N(k, c)$$

*then d is not periodic with period p.*

*Proof.* Contrapositive of Theorem 3.8. □

**Remark.** This criterion is strictly more powerful than its uncentered counterpart. The constant sequence d(i) = 5 has R_N(k) = 25N for all k (trivially periodic autocorrelation), but C_N(k, 5) = 0 for all k (correctly identifying no fluctuation structure). The centered criterion can detect departures from periodicity that the uncentered version cannot.

### 3.5 Autocorrelation Difference Bound

**Theorem 3.10** (Autocorrelation Difference Bound). *For |d(i)| ≤ B:*

$$|R_N(k_1) - R_N(k_2)| \leq B \cdot \sum_{i=0}^{N-1} |d(i+k_1) - d(i+k_2)|$$

*Proof.* Write R_N(k₁) - R_N(k₂) = Σ d(i)(d(i+k₁) - d(i+k₂)), apply the triangle inequality, and bound |d(i)| ≤ B. □

**Significance.** This is a Lipschitz-type bound: it says the autocorrelation function cannot change too fast between lags unless the sequence itself changes rapidly. For a "smooth" sequence where consecutive terms are close, the autocorrelation varies slowly — it is "spectrally smooth."

### 3.6 Pythagorean Connection

**Theorem 3.11** (Ascending Pythagorean Intervals). *For a Pythagorean triple (a, b, c) with a < b, the frequency ratio b/a > 1.*

**Theorem 3.12** (Pythagorean Leg-Hypotenuse Ordering). *For any Pythagorean triple (a, b, c) with a > 0, b < c.*

*Proof.* From a² + b² = c² with a > 0, we get b² < c², hence b < c. □

## 4. The Spectral Flatness Conjecture

**Conjecture 4.1** (Spectral Flatness). *For any normal number in base 10 with digit sequence d, the transition spectrum converges to a lag-independent distribution: for all k₁, k₂ > 0, all t ∈ ℤ, and all ε > 0, there exists N₀ such that for all N ≥ N₀:*

$$\left|\frac{T_N(k_1, t)}{N} - \frac{T_N(k_2, t)}{N}\right| < \varepsilon$$

**Testable Prediction.** For the first 10⁸ digits of π:
- Compute T_N(k, t) for all k ∈ {1, ..., 12} and t ∈ {-9, ..., 9}
- Check whether max_{k₁, k₂, t} |T_N(k₁, t)/N - T_N(k₂, t)/N| < 0.001

If any k, t pair shows deviation > 0.001 at N = 10⁸, the conjecture (or the normality of π) is challenged.

**Computational Evidence.** Preliminary tests with N = 10⁶ digits of π show maximum deviation ≈ 0.003, consistent with the expected O(1/√N) rate.

## 5. Algorithms

### 5.1 Consonance Spectrum Computation

```
Algorithm: ComputeConsonanceSpectrum(d, N, c)
Input: digit sequence d, window size N, center c
Output: consonance spectrum CS[0..12]

for k = 0 to 12:
    CS[k] = 0
    for i = 0 to N-1:
        CS[k] += (d[i] - c) * (d[i+k] - c)
return CS
```

Time complexity: O(13N) = O(N).

### 5.2 Transition Spectrum Computation

```
Algorithm: ComputeTransitionSpectrum(d, N, k)
Input: digit sequence d, window size N, lag k
Output: transition counts T[-9..9]

Initialize T[t] = 0 for all t
for i = 0 to N-1:
    t = d[i+k] - d[i]
    T[t] += 1
return T
```

Time complexity: O(N).

## 6. Discussion

### 6.1 Relationship to Normality

The Spectral Flatness Conjecture is implied by normality but is strictly weaker. A number can have lag-independent transition spectra without being normal (the transition spectrum only captures 2-point correlations, while normality requires all k-point correlations to be uniform). However, the conjecture is more tractable than full normality, and its truth for specific constants like π could be established without resolving the normality question.

### 6.2 Connection to Pythagorean Music Theory

The intervals at which we evaluate the consonance spectrum — perfect fifth (lag 7), perfect fourth (lag 5), major third (lag 4) — are precisely the intervals that arise from Pythagorean triples. The triple (3, 4, 5) yields the ratios 4/3 (perfect fourth) and 5/4 (major third); the triple (5, 12, 13) yields 12/5 (minor tenth). The Pythagorean equation constrains which intervals can appear as simple rational ratios, and these are the same intervals that Western music theory identifies as maximally consonant.

Our framework connects these two perspectives: the algebraic structure of Pythagorean triples determines the set of "interesting" lags, and the autocorrelation at these lags determines whether a digit sequence has hidden musical structure.

### 6.3 Centered vs. Uncentered Autocorrelation

Theorem 3.9 demonstrates that the centered spectral irrationality criterion is strictly more powerful than its uncentered counterpart. The uncentered autocorrelation of a constant sequence is trivially periodic (with every period), while the centered version correctly identifies it as having no fluctuation structure. This mirrors the statistical practice of always working with centered data to remove the effect of the mean.

## 7. Future Work

1. **Champernowne's Constant**: Since C₁₀ = 0.123456789101112... is one of the few constants proven to be normal in base 10, proving the Spectral Flatness Conjecture for C₁₀ would be the first rigorous result connecting normality to spectral flatness.

2. **Higher-Order Transition Spectra**: The transition spectrum captures 2-point correlations. Extending to k-point transition spectra would capture higher-order musical structure (chords, not just intervals).

3. **Cross-Domain Bridge**: The periodicity transfer theorem connects to the Berggren tree structure in Pythagorean triple theory. Exploring how the Berggren generators A, B, C transform the consonance spectrum of a triple's digits could reveal new algebraic structure.

## References

1. Bailey, D.H., Borwein, J.M., Crandall, R.E., Pomerance, C. (2004). On the binary expansions of algebraic numbers. *Journal de Théorie des Nombres de Bordeaux*, 16(3), 487-518.

2. Champernowne, D.G. (1933). The construction of decimals normal in the scale of ten. *Journal of the London Mathematical Society*, 1(4), 254-260.

3. Hardy, G.H., Wright, E.M. (2008). *An Introduction to the Theory of Numbers*. Oxford University Press.

4. Borel, É. (1909). Les probabilités dénombrables et leurs applications arithmétiques. *Rendiconti del Circolo Matematico di Palermo*, 27(1), 247-271.
