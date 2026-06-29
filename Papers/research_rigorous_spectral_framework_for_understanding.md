# A Spectral Framework for Prime Frequencies and the Zeta Function

## Abstract

We develop a rigorous spectral framework for understanding the Riemann zeta function on the critical line as a superposition of prime frequencies. The *prime spectral map* sends each prime *p* to a spectral line with frequency log(*p*)/(2π) and amplitude 1/√*p*. We establish nine theorems characterizing this spectral decomposition: injectivity of the spectral map (Theorem 1), prime power independence (Theorem 2), amplitude-frequency duality (Theorems 3–4), frequency positivity and gap bounds (Theorems 5–6), amplitude bounds (Theorems 7–8), and the chord amplification theorem (Theorem 9). We introduce the novel concept of *spectral resonance defect*, which quantifies the harmonic dissonance between pairs of prime frequencies. All results are formalized and verified in Lean 4 with the Mathlib library. We state a falsifiable conjecture on spectral gap regularity and provide computational evidence.

**Keywords**: prime numbers, Riemann zeta function, spectral decomposition, prime power independence, Diophantine approximation

---

## 1. Introduction

The Euler product formula connects the Riemann zeta function ζ(s) to the prime numbers through the identity

ζ(s) = ∏_p (1 - p^{-s})^{-1}

valid for Re(s) > 1. On the critical line s = 1/2 + it, the logarithmic derivative of ζ can be expressed as a sum over prime powers, with each prime *p* contributing oscillatory terms of the form p^{-1/2-it} = p^{-1/2} · e^{-it log p}. This representation naturally suggests viewing each prime as a *spectral line* with:

- **Frequency**: ν_p = log(p)/(2π)
- **Amplitude**: A_p = 1/√p

The collection {(ν_p, A_p) : p prime} constitutes the **prime spectrum**, and the zeta function on the critical line is, in a precise sense, the superposition of these spectral contributions.

This paper develops the mathematical theory of the prime spectrum, establishing its fundamental structural properties and introducing new concepts for measuring the harmonic relationships between prime frequencies.

## 2. Definitions

### 2.1. Prime Spectral Line

**Definition 1** (Prime Spectral Line). A *prime spectral line* is a pair L = (p, is_prime(p)) consisting of a natural number p and a proof of its primality. Its associated quantities are:
- Frequency: freq(L) = log(p)/(2π)  
- Amplitude: amp(L) = 1/√p  
- Energy: E(L) = 1/p = amp(L)²

### 2.2. Spectral Resonance Defect

**Definition 2** (Spectral Resonance Defect). For primes p, q and a resolution parameter N ∈ ℕ, the *spectral resonance defect* is:

D_N(p,q) = inf { |log(p)/log(q) - a/b| : a,b ∈ ℕ, 0 < b ≤ N }

This measures how closely the frequency ratio log(p)/log(q) can be approximated by rationals with bounded denominator. By our Prime Power Independence theorem, D_N(p,q) > 0 for all N when p ≠ q — the infimum is never zero.

### 2.3. Spectral Chord

**Definition 3** (Spectral Chord). A *spectral chord* C = (L_low, L_high, ordered) consists of two prime spectral lines with L_low.prime < L_high.prime. Its invariants are:
- Frequency ratio: R(C) = log(p_high)/log(p_low)
- Amplitude ratio: A(C) = amp(L_low)/amp(L_high) = √(p_high/p_low)

## 3. Main Results

### 3.1. Prime Power Independence (Theorem 2)

**Theorem** (Prime Power Independence). *For distinct primes p, q and positive integers m, n: p^m ≠ q^n.*

*Proof sketch.* Suppose for contradiction that p^m = q^n. Consider the prime factorization of both sides. The left side p^m has factorization {p: m}, with the prime p appearing m times. The right side q^n has factorization {q: n}. Since p ≠ q, comparing the multiplicity of p in both factorizations gives m = 0, contradicting m > 0. ∎

**Corollary.** For distinct primes p, q: log(p)/log(q) ∉ ℚ. That is, the ratio is irrational.

*Proof.* If log(p)/log(q) = a/b with a,b positive integers, then b·log(p) = a·log(q), so log(p^b) = log(q^a), giving p^b = q^a, contradicting the theorem. ∎

This result is the number-theoretic foundation of spectral dissonance: distinct prime frequencies can never stand in a rational ratio.

### 3.2. Spectral Injectivity (Theorem 1)

**Theorem** (Spectral Injectivity). *The spectral map p ↦ freq(p) = log(p)/(2π) is injective on primes.*

*Proof sketch.* If freq(L₁) = freq(L₂), then log(p₁)/(2π) = log(p₂)/(2π). Since 2π ≠ 0, we get log(p₁) = log(p₂). The exponential function is injective, so p₁ = p₂ as real numbers. Since both are natural numbers, p₁ = p₂. ∎

### 3.3. Amplitude-Frequency Duality (Theorems 3–4)

**Theorem** (Amplitude Duality). *If L₁.prime < L₂.prime, then amp(L₂) < amp(L₁).*

**Theorem** (Energy Duality). *If L₁.prime < L₂.prime, then E(L₂) < E(L₁).*

These results formalize the intuition that larger primes contribute weaker spectral lines. The amplitude decay is O(p^{-1/2}), giving square-summable amplitudes related to the prime zeta function P(s) = Σ_p p^{-s} at s = 1/2 (which diverges, reflecting the infinitude of primes, but whose partial sums grow slowly).

### 3.4. Frequency Gap Bounds (Theorems 5–6)

**Theorem** (Frequency Positivity). *For every prime spectral line L: log(L.prime) > 0.*

**Theorem** (Log Ratio Bound). *For primes p < q: log(q)/log(p) > 1.*

The log ratio bound establishes that every spectral chord has a frequency ratio exceeding 1, a necessary condition for the spectral decomposition to be well-ordered.

### 3.5. Amplitude Bounds (Theorems 7–8)

**Theorem** (Amplitude Positivity). *For every prime spectral line L: amp(L) > 0.*

**Theorem** (Universal Amplitude Bound). *For every prime spectral line L: amp(L) ≤ 1/√2.*

The universal bound follows from the fact that the smallest prime is 2, so every prime's amplitude is at most 1/√2 ≈ 0.707.

### 3.6. Chord Amplification (Theorem 9)

**Theorem** (Chord Amplification). *For every spectral chord C: A(C) > 1.*

This means that in any pair of prime spectral lines, the lower-frequency prime is strictly louder. The amplification factor √(q/p) quantifies the spectral dominance of small primes.

## 4. The Spectral Resonance Defect

### 4.1. Properties

The spectral resonance defect D_N(p,q) satisfies:
1. **Positivity**: D_N(p,q) > 0 for all N, when p ≠ q (by Prime Power Independence)
2. **Monotonicity**: D_N(p,q) ≥ D_{N+1}(p,q) (larger denominators allow better approximation)  
3. **Symmetry of irrationality**: D_N(p,q) > 0 iff D_N(q,p) > 0

The rate at which D_N(p,q) → 0 as N → ∞ is controlled by the irrationality measure of log(p)/log(q). By the Thue-Siegel-Roth theorem, for any ε > 0:

D_N(p,q) ≫ N^{-2-ε}

For specific pairs, stronger results are known. The continued fraction expansion of log(2)/log(3) = [0; 1, 1, 1, 2, 3, 1, ...] shows that this ratio is "moderately well approximable" — not as resistant to rational approximation as algebraically defined irrationals, but still definitively irrational.

### 4.2. Connection to Transcendence

By the Gelfond-Schneider theorem, if α is algebraic and α ∉ {0,1}, and β is algebraic and irrational, then α^β is transcendental. Setting α = p and considering the equation p^{a/b} = q (which would require q to be transcendental unless a/b is rational), we see that the irrationality of log(p)/log(q) connects to deep questions in transcendental number theory.

## 5. Spectral Gap Regularity Conjecture

**Conjecture.** For all n ≥ 1, if p_n and p_{n+1} are consecutive primes, then:

log(p_{n+1})/log(p_n) ≤ 1 + 1/n

Equivalently: p_{n+1} ≤ p_n^{1+1/n}.

### 5.1. Relation to Cramér's Conjecture

Cramér's conjecture asserts that p_{n+1} - p_n = O((log p_n)²). Our conjecture is substantially weaker: it requires only p_{n+1}/p_n → 1, which follows from the prime number theorem, plus a quantitative rate. Specifically:

log(p_{n+1})/log(p_n) = 1 + log(p_{n+1}/p_n)/log(p_n) ≈ 1 + (p_{n+1}-p_n)/(p_n log p_n)

Under Cramér's conjecture, the gap p_{n+1}-p_n is O((log p_n)²), so the ratio is approximately 1 + O(log(p_n)/p_n), which tends to 1 + 0 much faster than 1/n. Thus Cramér implies our conjecture, but ours is potentially provable by weaker means.

### 5.2. Computational Evidence

| n | p_n | p_{n+1} | log(p_{n+1})/log(p_n) | 1 + 1/n |
|---|-----|---------|----------------------|---------|
| 1 | 2 | 3 | 1.585 | 2.000 |
| 2 | 3 | 5 | 1.465 | 1.500 |
| 3 | 5 | 7 | 1.209 | 1.333 |
| 4 | 7 | 11 | 1.232 | 1.250 |
| 5 | 11 | 13 | 1.069 | 1.200 |
| 10 | 29 | 31 | 1.020 | 1.100 |
| 100 | 541 | 547 | 1.002 | 1.010 |

The conjecture holds with substantial margin for all computed cases.

## 6. Algorithms

### 6.1. Spectral Line Computation

Given a prime p, compute its spectral line in O(log p) arithmetic operations:
1. Compute ν = ln(p)/(2π) using standard logarithm algorithms
2. Compute A = 1/√p using Newton's method for square roots
3. Return (ν, A)

### 6.2. Resonance Defect Computation

Given primes p, q and resolution N:
1. Compute r = ln(p)/ln(q) to sufficient precision
2. For each b from 1 to N, compute a = round(r·b) and the distance |r - a/b|
3. Return the minimum distance

This is O(N) in the resolution parameter, with each step requiring O(M(d)) bit operations where M(d) is the cost of d-digit multiplication.

## 7. Discussion

### 7.1. Physical Analogies

The prime spectrum bears a striking resemblance to the energy spectrum of a quantum system:
- Spectral lines ↔ energy levels
- Amplitudes ↔ transition matrix elements  
- Frequency gaps ↔ energy gaps
- Spectral injectivity ↔ non-degeneracy

The amplitude-frequency duality 1/√p mirrors the Boltzmann factor e^{-E/kT} that suppresses high-energy contributions in statistical mechanics. The spectral resonance defect plays the role of a level repulsion statistic in random matrix theory, where energy levels of quantum chaotic systems resist being in rational ratios.

### 7.2. Connections to Existing Work

Our framework connects to several active research areas:
- **Spectral gap theory** (cf. catalog entries `spectral_gap_from_poincare`, `spectral_gap_from_contraction`): The gap between consecutive prime frequencies is a spectral gap in the literal sense.
- **Lorentzian structures** (cf. `Bridges/LorentzianIsingAntiCancel.lean`): The spectral decomposition parallels eigenmode decomposition in Lorentzian quantum field theory.
- **Stabilizer codes** (cf. `Physics/StabilizerBounds.lean`): Prime spectral lines could encode quantum error-correcting codes where each prime frequency becomes a stabilizer generator.

## 8. Future Work

1. **Spectral density from PNT**: Establish that the spectral counting function π_S(f) = #{p : ν_p ≤ f} satisfies π_S(f) ~ e^{2πf}/(2πf), the PNT in spectral coordinates.

2. **Quantitative resonance defect bounds**: Prove effective lower bounds on D_N(p,q) for specific prime pairs using Baker's theorem on linear forms in logarithms.

3. **Tropical prime spectrum**: Map prime spectral data into a tropical semiring, where the spectral frequencies become tropical eigenvalues.

4. **Spectral zeta function**: Define Z_S(s) = Σ_p ν_p^{-s} and study its analytic properties.

## References

1. Euler, L. (1737). Various observations on infinite series. *Commentarii academiae scientiarum Petropolitanae*, 9, 160-188.

2. Riemann, B. (1859). On the number of primes less than a given magnitude. *Monatsberichte der Berliner Akademie*.

3. Hardy, G.H. & Wright, E.M. (2008). *An Introduction to the Theory of Numbers*, 6th ed. Oxford University Press.

4. Montgomery, H.L. (1973). The pair correlation of zeros of the zeta function. *Proc. Symp. Pure Math.*, 24, 181-193.

5. Cramér, H. (1936). On the order of magnitude of the difference between consecutive prime numbers. *Acta Arithmetica*, 2, 23-46.
