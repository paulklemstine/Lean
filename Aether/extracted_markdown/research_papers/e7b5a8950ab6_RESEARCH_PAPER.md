# Spectral Contraction Theory for Collatz Dynamics: A Formally Verified Framework

## Abstract

We develop a rigorous, formally verified framework connecting binary parity words to orbit contraction in Collatz dynamics through spectral analysis. The central result is the *density–contraction biconditional*: the ones-density of a Collatz parity word falling below the critical threshold ρ\* = log(2)/log(3) ≈ 0.6309 is equivalent to positive contraction exponent. We establish the *fundamental inequality* log(3) < 2·log(2), which ensures that even 50% ones-density yields contraction — the built-in bias of Collatz dynamics. The *spectral reformulation* bridges this to Fourier analysis: the DC spectral energy being below (ρ\*)² characterizes contraction. The *additivity theorem* for the contraction exponent reduces the Collatz conjecture to a statement about sustained density bounds on parity word segments. We introduce the novel *Tropical Contraction Certificate* structure bridging Collatz contraction theory to tropical spectral gap theory. All results are formally verified in Lean 4 with Mathlib.

**Keywords**: Collatz conjecture, parity word, contraction exponent, spectral analysis, formal verification, tropical geometry

---

## 1. Introduction

The Collatz conjecture, proposed in 1937, asserts that iterating the map T(n) = n/2 (if n even) or T(n) = 3n+1 (if n odd) eventually reaches 1 from any positive starting integer. Despite its elementary formulation, the conjecture remains one of the most notorious open problems in mathematics, with Paul Erdős famously declaring that "mathematics is not yet ready for such problems."

Recent approaches to the Collatz conjecture have emphasized the *statistical* behavior of orbits rather than individual trajectories. Terras (1976) showed that "almost all" positive integers have a finite stopping time, and Tao (2019) proved that "almost all" orbits become arbitrarily small. These results rely on understanding the *parity statistics* of Collatz orbits — the distribution of odd and even iterates.

In this paper, we develop a formally verified framework that makes the connection between parity statistics and orbit contraction precise and quantitative. Our approach centers on three key ideas:

1. **The contraction exponent** ξ(k,s) = k·log(2) − s·log(3), which measures the net multiplicative effect of k Collatz steps containing s odd steps.
2. **The critical density** ρ\* = log(2)/log(3), the threshold parity density separating contraction from expansion.
3. **The spectral reformulation**, which connects parity density to the DC component of the Fourier transform of the parity word.

### 1.1. Main Results

Our main results, all formally verified in Lean 4 with Mathlib, are:

**Theorem 3.1** (Fundamental Inequality). *log(3) < 2·log(2).*

**Theorem 3.2** (Half-Density Contraction). *If 2s ≤ k and k > 0, then ξ(k,s) > 0.*

**Theorem 3.4** (Density–Contraction Biconditional). *For k > 0 and s ≤ k: ξ(k,s) > 0 if and only if s/k < ρ\*.*

**Theorem 3.5** (Spectral Energy Characterization). *For k > 0 and s ≤ k: ξ(k,s) > 0 if and only if (s/k)² < (ρ\*)².*

**Theorem 3.8** (Additivity). *ξ(k₁+k₂, s₁+s₂) = ξ(k₁,s₁) + ξ(k₂,s₂).*

We also introduce the *Tropical Contraction Certificate* structure and prove that certificate contraction decomposes as the sum of segment contractions.

### 1.2. Related Work

The study of Collatz dynamics through parity words has a long history. Everett (1977) observed that the behavior of the Collatz map modulo powers of 2 is determined by the initial value's parity word. Lagarias (1985) provided comprehensive surveys of results on the 3x+1 problem. The connection between parity density and orbit growth was implicit in Terras's (1976) work on stopping times.

Our spectral approach is related to the transfer operator methods used by Kontorovich and Lagarias (2009, 2010) and Lagarias and Soundararajan (2006). However, our framework differs in working directly with the parity word as a combinatorial object rather than with the transfer operator as an analytic object.

The formally verified nature of our results builds on the growing body of formalized mathematics in the Lean proof assistant, including significant portions of number theory, real analysis, and spectral theory available in Mathlib.

---

## 2. Definitions

### 2.1. The Collatz Map and Orbits

**Definition 2.1** (Collatz Step). The Collatz step function T : ℕ → ℕ is defined by:
```
T(n) = n/2       if n ≡ 0 (mod 2)
T(n) = 3n + 1    if n ≡ 1 (mod 2)
```

**Definition 2.2** (Collatz Orbit). The orbit of n ∈ ℕ is the sequence (T^k(n))_{k≥0}.

### 2.2. Parity Words and Statistics

**Definition 2.3** (Parity Word). The parity word of the orbit of n is the binary sequence w(n) = (w_0, w_1, w_2, ...) where w_k = T^k(n) mod 2.

**Definition 2.4** (Odd Step Count). For a prefix of length k, the odd step count is s_k(n) = Σ_{i=0}^{k-1} w_i(n).

**Definition 2.5** (Parity Density). The parity density of a prefix of length k is ρ_k(n) = s_k(n)/k (for k > 0).

### 2.3. Contraction Exponent

**Definition 2.6** (Contraction Exponent). For k total steps and s odd steps:
```
ξ(k,s) = k · log(2) − s · log(3)
```

The contraction exponent measures the logarithmic ratio of the "shrinking factor" 2^k to the "growth factor" 3^s accumulated over k Collatz steps with s odd steps.

**Definition 2.7** (Critical Density).
```
ρ* = log(2)/log(3) ≈ 0.63093
```

### 2.4. Spectral Quantities

**Definition 2.8** (Spectral Cosine Sum). For a parity word w of length K and frequency ω:
```
S_cos(ω) = Σ_{k=0}^{K-1} w_k · cos(2πωk)
```

**Definition 2.9** (Normalized DC Energy). The normalized DC spectral energy is:
```
E_DC = (s/k)² = (ρ_k)²
```

This equals the spectral energy at frequency ω = 0, normalized by k².

### 2.5. Novel Structures

**Definition 2.10** (Parity Word Segment). A ParityWordSegment consists of:
- A finite binary word w : Fin(n) → Bool
- The word length n
- The count of 1-bits (ones)
- A proof that the count equals |{i : w_i = 1}|
- A proof that ones ≤ len

**Definition 2.11** (Tropical Contraction Certificate). A TropicalContractionCertificate consists of:
- A sequence of ParityWordSegments
- Total length and total ones (with consistency proofs)
- A proof that the total contraction exponent is positive

The tropical contraction certificate provides a formal bridge between Collatz contraction analysis and tropical spectral gap theory. The contraction exponent ξ(k,s) = k·log(2) − s·log(3) is a tropical linear function of (k,s), and the additivity theorem (Theorem 3.8) is the tropical analog of linearity.

---

## 3. Main Results

### 3.1. The Fundamental Inequality

**Theorem 3.1** (Fundamental Inequality). *log(3) < 2·log(2).*

*Proof sketch.* Since log is strictly monotone and 3 < 4 = 2², we have log(3) < log(4) = log(2²) = 2·log(2). ∎

This inequality, while elementary, is the deep reason behind the Collatz process's built-in contraction bias. It is equivalent to the statement 3 < 2² = 4.

**Corollary 3.1.1.** *The critical density satisfies 1/2 < ρ\* < 1.*

*Proof.* The left inequality: ρ\* = log(2)/log(3) > 1/2 iff log(3) < 2·log(2), which is Theorem 3.1. The right inequality: ρ\* < 1 iff log(2) < log(3), which holds since 2 < 3. ∎

### 3.2. Half-Density Contraction

**Theorem 3.2** (Half-Density Contraction). *If 2s ≤ k and k > 0, then ξ(k,s) > 0.*

*Proof sketch.* Since 2s ≤ k, we have s ≤ k/2, so:
```
ξ(k,s) = k·log(2) − s·log(3) ≥ k·log(2) − (k/2)·log(3) = (k/2)·(2·log(2) − log(3)) > 0
```
The last inequality uses the fundamental inequality (Theorem 3.1). ∎

This theorem captures the built-in bias: orbits with at most 50% odd steps always contract.

### 3.3. Quantitative Contraction Bound

**Theorem 3.3** (Contraction Lower Bound). *If 2s ≤ k and k > 0, then:*
```
ξ(k,s) ≥ (k/2)·(2·log(2) − log(3))
```

### 3.4. Density–Contraction Biconditional

**Theorem 3.4** (Density–Contraction Biconditional). *For k > 0 and s ≤ k:*
```
ξ(k,s) > 0 ⟺ s/k < ρ*
```

*Proof sketch.* ξ(k,s) > 0 iff k·log(2) > s·log(3) iff s/k < log(2)/log(3) = ρ\* (dividing both sides by k·log(3), both positive). ∎

This biconditional is the central result: it establishes a precise equivalence between the analytic condition (positive contraction) and the combinatorial condition (sub-critical density).

### 3.5. Spectral Energy Characterization

**Theorem 3.5** (Spectral Energy Characterization). *For k > 0 and s ≤ k:*
```
ξ(k,s) > 0 ⟺ (s/k)² < (ρ*)²
```

*Proof sketch.* By Theorem 3.4, ξ(k,s) > 0 iff s/k < ρ\*. Since s/k ≥ 0 and ρ\* > 0, this is equivalent to (s/k)² < (ρ\*)² by the monotonicity of x ↦ x² on [0,∞). ∎

This reformulation connects the contraction criterion to spectral analysis: the normalized DC energy (s/k)² being below the threshold (ρ\*)² characterizes contraction.

### 3.6. Monotonicity Properties

**Theorem 3.6** (Antitone in Ones). *ξ(k, s₂) ≤ ξ(k, s₁) whenever s₁ ≤ s₂.*

**Theorem 3.7** (Monotone in Length). *ξ(k₁, s) ≤ ξ(k₂, s) whenever k₁ ≤ k₂.*

These express the intuitive facts that more odd steps reduce contraction while more total steps increase contraction (holding odd steps fixed).

### 3.8. Additivity

**Theorem 3.8** (Additivity of Contraction Exponent). *For all k₁, k₂, s₁, s₂ ∈ ℕ:*
```
ξ(k₁+k₂, s₁+s₂) = ξ(k₁,s₁) + ξ(k₂,s₂)
```

*Proof.* Direct computation:
```
ξ(k₁+k₂, s₁+s₂) = (k₁+k₂)·log(2) − (s₁+s₂)·log(3)
                  = k₁·log(2) − s₁·log(3) + k₂·log(2) − s₂·log(3)
                  = ξ(k₁,s₁) + ξ(k₂,s₂)
```
∎

**Corollary 3.8.1** (Scaling). *ξ(mk, ms) = m·ξ(k,s) for all m, k, s ∈ ℕ.*

**Corollary 3.8.2** (Certificate Decomposition). *For a tropical contraction certificate with segments (kᵢ, sᵢ):*
```
ξ(Σkᵢ, Σsᵢ) = Σ ξ(kᵢ, sᵢ)
```

### 3.9. Extremal Results

**Theorem 3.9** (All-Even Maximum). *ξ(k, 0) = k·log(2).*

**Theorem 3.10** (All-Odd Expansion). *For k > 0, ξ(k, k) < 0.*

*Proof sketch.* ξ(k,k) = k·(log(2) − log(3)) < 0 since log(2) < log(3). ∎

### 3.10. Conjecture Implications

**Theorem 3.11** (Conjecture Implies Eventual Contraction). *If the Uniform Density Bound Conjecture holds (every orbit's running density eventually falls below ρ\*), then every orbit eventually has positive contraction exponent.*

---

## 4. Algorithms

### 4.1. Contraction Exponent Computation

**Input**: Natural numbers k (total steps), s (odd steps)
**Output**: Real number ξ(k,s)

```
function contractionExponent(k, s):
    return k * log(2) - s * log(3)
```

**Complexity**: O(1) arithmetic operations.

### 4.2. Running Density Analysis

**Input**: Starting value n, maximum steps M
**Output**: Running density sequence (ρ₁, ρ₂, ..., ρ_M) and threshold crossing index K

```
function runningDensityAnalysis(n, M):
    orbit = computeOrbit(n, M)
    running_sum = 0
    for k = 0, 1, ..., M-1:
        running_sum += orbit[k] mod 2
        densities[k] = running_sum / (k+1)
    K = first k such that densities[j] < ρ* for all j ≥ k
    return densities, K
```

**Complexity**: O(M) time, O(M) space.

### 4.3. Certificate Construction

**Input**: Starting value n, segment length L, number of segments N
**Output**: TropicalContractionCertificate

```
function buildCertificate(n, L, N):
    orbit = computeOrbit(n, L * N)
    segments = []
    for i = 0, 1, ..., N-1:
        word = parityWord(orbit[i*L : (i+1)*L])
        segments.append(ParityWordSegment(word))
    totalLen = sum of segment lengths
    totalOnes = sum of segment ones counts
    contraction = contractionExponent(totalLen, totalOnes)
    return TropicalContractionCertificate(segments, totalLen, totalOnes, contraction)
```

**Complexity**: O(L·N) time, O(L·N) space.

---

## 5. Discussion

### 5.1. Tropical Structure

The contraction exponent ξ(k,s) = k·log(2) − s·log(3) is a linear function in the tropical semiring (ℝ, min, +). The additivity theorem (Theorem 3.8) is precisely the statement that ξ is a tropical linear map from the "orbit segment" monoid to (ℝ, +). This connection opens the door to applying tropical spectral theory — including tropical eigenvalue theory and min-plus algebra — to Collatz dynamics.

The tropical contraction certificate structure formalizes this bridge: it packages a finite collection of orbit segments with a proof that their total tropical linear functional is positive. This could potentially connect to the tropical spectral gap framework developed in parallel work on symbolic dynamics.

### 5.2. Relationship to Transfer Operators

The finite-state spectral criterion from the existing Catalog (`Speculative/CollatzSpectral/SpectralCriterion.lean`) establishes that if the transfer matrix for Collatz dynamics modulo q has spectral norm < 1, then all orbits in that residue class terminate. Our framework provides a complementary viewpoint: rather than analyzing the matrix directly, we analyze the *parity words* produced by orbits and show that sub-critical density is equivalent to contraction.

The two approaches could be unified: the transfer matrix's spectral gap controls the mixing properties of the parity word, and rapid mixing implies that the parity density cannot sustain high values. This connection, if formalized, would provide a path toward proving the Uniform Density Bound Conjecture and hence the Collatz conjecture.

### 5.3. Limitations

Our framework does not prove the Collatz conjecture. The gap lies in establishing that actual Collatz orbits must eventually have sub-critical parity density. The Uniform Density Bound Conjecture (Definition 2.11 in the Lean file) makes this precise: for every n > 1, there exists K such that the running density stays below ρ\* for all k ≥ K. This conjecture is computationally verified for all tested values but remains unproven.

---

## 6. Future Work

1. **Tropical spectral gap**: Establish that the tropical spectral gap of the Collatz transfer operator implies the Uniform Density Bound Conjecture.

2. **Effective bounds**: Give explicit bounds on K (the threshold crossing index) in terms of n.

3. **Higher-order spectral analysis**: Analyze non-DC spectral components to characterize the "pseudo-randomness" of Collatz parity words.

4. **Connection to Tao's result**: Relate our density framework to Tao's (2019) result on almost all orbits becoming arbitrarily small.

5. **Accelerated Collatz map**: Extend the framework to the accelerated map T(n) = (3n+1)/2^{ν₂(3n+1)}, which operates only on odd numbers.

---

## 7. References

1. Collatz, L. (1937). Unpublished problem.
2. Terras, R. (1976). A stopping time problem on the positive integers. *Acta Arithmetica*, 30, 241-252.
3. Lagarias, J.C. (1985). The 3x+1 problem and its generalizations. *American Mathematical Monthly*, 92, 3-23.
4. Kontorovich, A.V. and Lagarias, J.C. (2009). Stochastic models for the 3x+1 and 5x+1 problems and related problems. *The Ultimate Challenge: the 3x+1 Problem*, AMS.
5. Tao, T. (2019). Almost all orbits of the Collatz map attain almost bounded values. *Forum of Mathematics, Pi*, 10, e12.
6. Lagarias, J.C. and Soundararajan, K. (2006). Benford's law for the 3x+1 function. *Journal of the London Mathematical Society*, 74(2), 289-303.

---

## Appendix: Formal Verification Summary

All theorems in this paper have been formally verified in Lean 4 with Mathlib. The proofs use only the standard axioms (propext, Classical.choice, Quot.sound). The Lean source is available in `Catalog/Shared/CollatzContraction.lean`.

| Theorem | Lines | Key Tactics |
|---------|-------|-------------|
| 3.1 (Fundamental Inequality) | 1 | norm_num, log_rpow, log_lt_log |
| 3.2 (Half-Density Contraction) | 4 | convert, nlinarith, positivity |
| 3.4 (Density–Contraction Biconditional) | 3 | unfold, split_ifs, div_lt_iff |
| 3.5 (Spectral Energy) | 3 | convert, nlinarith, positivity |
| 3.8 (Additivity) | 1 | unfold, push_cast, ring |
| Certificate Decomposition | 2 | simp, sum_mul |
| Monotonicity (antitone) | 1 | sub_le_sub_left, mul_le_mul |
| Monotonicity (monotone) | 1 | sub_le_sub_right, mul_le_mul |
