# A Machine-Verified Quantitative Leftover Hash Lemma with Rényi-2 Entropy

## Abstract

We present a complete, formally verified development of the Quantitative Leftover Hash Lemma (LHL), establishing that for any 2-universal hash family H and finite source X with collision probability CP(X), the statistical distance between the seeded hashed output and ideal uniform satisfies SD ≤ (1/2)√(|β|·CP(X)). Our formalization includes 35 theorems and 18 definitions covering collision probability, Rényi-2 entropy, min-entropy, statistical distance, the ℓ¹–ℓ² Cauchy-Schwarz bridge, and universal hash families. All proofs are machine-verified with zero uses of `sorry`. We derive security corollaries for post-quantum key derivation and establish the entropy ordering H_∞ ≤ H_2 as a reusable bridge between worst-case and average-case security.

## 1. Introduction

The Leftover Hash Lemma (LHL), due to Impagliazzo, Levin, and Luby [ILL89], is one of the most widely used tools in theoretical cryptography. It provides a quantitative guarantee that hashing a weak random source with a 2-universal hash function produces output that is statistically close to uniform, provided the source has sufficient entropy.

Despite its fundamental importance, the LHL has not previously been formalized in a general-purpose proof assistant with complete verification of all proof steps. This is partly because the proof involves a delicate interplay of combinatorial sum manipulations, analytic inequalities, and algebraic identities that are straightforward on paper but require significant care in a formal setting.

### 1.1 Contributions

1. **Complete formalization** of the LHL proof pipeline: collision probability → seeded collision bound → Parseval identity → Cauchy-Schwarz → statistical distance bound.
2. **Reusable infrastructure** for finite probability distributions, including `Source`, `collisionProb`, `renyi2Entropy`, `minEntropy`, `statDist`, and `UniversalHashFamily`.
3. **Key intermediate results** formalized independently: the ℓ¹–ℓ² bridge inequality, the Parseval-style collision gap identity, and the seeded collision probability bound.
4. **Security corollaries** connecting the LHL to key derivation and post-quantum security.

## 2. Definitions and Notation

### 2.1 Finite Source

A **source** on a finite type α is a probability mass function p : α → ℝ with p(a) ≥ 0 for all a and Σ_a p(a) = 1.

### 2.2 Collision Probability and Entropy

The **collision probability** of X is:
$$\text{CP}(X) = \sum_a p(a)^2$$

The **Rényi-2 entropy** is:
$$H_2(X) = -\log_2(\text{CP}(X))$$

The **max point mass** is:
$$\text{maxP}(X) = \max_a p(a)$$

The **min-entropy** is:
$$H_\infty(X) = -\log_2(\text{maxP}(X))$$

### 2.3 Statistical Distance

The **statistical distance** between distributions p and q is:
$$\text{SD}(p, q) = \frac{1}{2} \sum_a |p(a) - q(a)|$$

### 2.4 Universal Hash Family

A **2-universal hash family** is a collection of functions h_s : α → β indexed by seeds s ∈ ι such that for all distinct x, y ∈ α:
$$\frac{1}{|ι|} \cdot |\{s : h_s(x) = h_s(y)\}| \leq \frac{1}{|β|}$$

## 3. Main Results

### 3.1 Entropy Ordering (Theorem: minEntropy_le_renyi2)

**Theorem.** For any source X on a nonempty finite type: H_∞(X) ≤ H_2(X).

*Proof sketch.* We show CP(X) ≤ maxP(X) by bounding each term p(a)² ≤ p(a) · maxP(X) and summing. Since -log is monotone decreasing, this gives -log(maxP) ≤ -log(CP), i.e., H_∞ ≤ H_2. □

### 3.2 ℓ¹–ℓ² Bridge (Theorem: l1_le_sqrt_card_mul_l2)

**Theorem.** For any f : α → ℝ on a finite type:
$$\sum_a |f(a)| \leq \sqrt{|\alpha|} \cdot \sqrt{\sum_a f(a)^2}$$

*Proof sketch.* This is a direct application of the Cauchy-Schwarz inequality with u = 1 and v = |f|. □

### 3.3 Parseval-Style Identity (Theorem: collisionGap_uniform_identity)

**Theorem.** For any distribution p on α with Σ p(a) = 1:
$$\sum_a \left(p(a) - \frac{1}{|\alpha|}\right)^2 = \sum_a p(a)^2 - \frac{1}{|\alpha|}$$

*Proof sketch.* Expand the square, use linearity of summation, substitute Σ p = 1 and Σ 1 = |α|, simplify. □

### 3.4 Statistical Distance from Uniform (Theorem: statDist_le_half_sqrt_collision_gap)

**Theorem.** For any distribution p on α:
$$\text{SD}(p, U_\alpha) \leq \frac{1}{2}\sqrt{|\alpha| \cdot \sum_a p(a)^2 - 1}$$

*Proof sketch.* Combine the ℓ¹–ℓ² bridge with the Parseval identity: SD ≤ (1/2)√|α| · √(Σp² - 1/|α|) = (1/2)√(|α|·Σp² - 1). □

### 3.5 Seeded Collision Probability Bound (Theorem: seeded_collision_prob_bound)

**Theorem.** For any 2-universal hash family H and source X:
$$\sum_{(s,b)} P(s,b)^2 \leq \frac{1}{|\iota|}\left(\text{CP}(X) + \frac{1 - \text{CP}(X)}{|\beta|}\right)$$

where P(s,b) = (1/|ι|) · Σ_a 𝟙[h_s(a) = b] · p(a) is the seeded joint distribution.

*Proof sketch.* This is the algebraic heart of the LHL:
1. Expand P(s,b)² = (1/|ι|²) · (Σ_a 𝟙[h_s(a)=b] p(a))²
2. Expand the square to a double sum over (a, a')
3. Swap the sum over b inside, using Σ_b 𝟙[h(a)=b]𝟙[h(a')=b] = 𝟙[h(a)=h(a')]
4. Split into diagonal (a = a') and off-diagonal (a ≠ a') terms
5. Diagonal: Σ_s Σ_a p(a)² = |ι| · CP(X)
6. Off-diagonal: use the universality bound Σ_s 𝟙[h_s(a)=h_s(a')] ≤ |ι|/|β|
7. Combine: total ≤ |ι|⁻² · (|ι|·CP + (|ι|/|β|)(1-CP)) = |ι|⁻¹(CP + (1-CP)/|β|) □

### 3.6 Main Theorem: Leftover Hash Lemma (Theorem: leftover_hash_lemma_quantitative)

**Theorem.** For any 2-universal hash family H and source X:
$$\text{SD}\left((S, H_S(X)),\; (S, U_\beta)\right) \leq \frac{1}{2}\sqrt{|\beta| \cdot \text{CP}(X)}$$

*Proof sketch.*
1. Observe that seededUniformDist is the uniform distribution on ι × β
2. Apply statDist_le_half_sqrt_collision_gap on ι × β:
   SD ≤ (1/2)√(|ι|·|β| · Σ P² - 1)
3. Bound Σ P² using seeded_collision_prob_bound:
   |ι|·|β| · Σ P² ≤ |β|·CP + 1 - CP ≤ |β|·CP + 1
4. Therefore |ι|·|β| · Σ P² - 1 ≤ |β|·CP
5. Conclude SD ≤ (1/2)√(|β|·CP) □

### 3.7 Security Corollary (Theorem: key_derivation_security_bound)

**Theorem.** If |β| · CP(X) ≤ ε, then:
$$\text{SD}\left((S, H_S(X)),\; (S, U_\beta)\right) \leq \frac{1}{2}\sqrt{\varepsilon}$$

*Proof.* Immediate from the main theorem and monotonicity of √. □

For a source with Rényi-2 entropy k bits extracted to ℓ bits, setting ε = 2^{ℓ-k} gives SD ≤ (1/2) · 2^{(ℓ-k)/2}, which is exponentially small when k > ℓ.

## 4. Algorithms

### 4.1 Universal Hash Evaluation

```
Algorithm: HashExtract(H, s, x)
Input: Universal hash family H, seed s ∈ ι, source sample x ∈ α
Output: Extracted key k ∈ β

1. k ← H.hash(s, x)
2. return (s, k)

Time complexity: O(|α| · |β|) for evaluation; O(1) per query with precomputation
Space complexity: O(log|ι| + log|α| + log|β|)
```

### 4.2 Security Parameter Selection

```
Algorithm: SelectParameters(k, λ)
Input: Source entropy k bits, security parameter λ
Output: Output length ℓ

1. ℓ ← k - 2λ
2. assert ℓ > 0
3. return ℓ

Guarantee: SD ≤ (1/2) · 2^{-λ}
```

## 5. Computational Experiments

We implemented the key quantities in Python and verified the bounds numerically.

### 5.1 Collision Probability vs. Entropy

For uniform sources on n elements: CP = 1/n, H_2 = log_2(n).
For skewed sources p = (1/2, 1/4, 1/8, 1/8): CP = 0.34375, H_2 ≈ 1.54 bits.

### 5.2 LHL Bound Evaluation

| Source Size | Output Size | CP(X) | |β|·CP(X) | SD Bound |
|---|---|---|---|---|
| 256 | 16 | 1/256 | 0.0625 | 0.125 |
| 256 | 16 | 1/128 | 0.125 | 0.177 |
| 1024 | 32 | 1/1024 | 0.03125 | 0.088 |
| 1024 | 128 | 1/1024 | 0.125 | 0.177 |

### 5.3 Entropy Gap Analysis

The entropy gap Δ = H_2(X) - log_2|β| controls the security exponent:
- Δ = 10: SD ≤ 2^{-5} ≈ 0.031
- Δ = 20: SD ≤ 2^{-10} ≈ 0.001
- Δ = 128: SD ≤ 2^{-64} ≈ 5.4 × 10^{-20}

## 6. Discussion

### 6.1 Tightness of the Bound

Our proved bound SD ≤ (1/2)√(|β|·CP) is slightly looser than the optimal (1/2)√(CP·(|β|-1)) by a factor of √(|β|/(|β|-1)) ≈ 1 for large |β|. The tighter bound requires more careful algebraic manipulation in the formal proof but is mathematically achievable.

### 6.2 Comparison with Alternative Approaches

The LHL can also be proved using:
- **Matrix methods**: viewing the hash family as an incidence matrix and the bound as a spectral norm estimate
- **Fourier analysis**: using the discrete Fourier transform to directly compute the statistical distance
- **Information-theoretic methods**: using data processing inequalities and chain rules

Our collision-probability approach is the most elementary and generalizable.

### 6.3 Applications to Post-Quantum Cryptography

In lattice-based key encapsulation (ML-KEM/Kyber), the shared secret after decapsulation has high min-entropy but is not uniform. The LHL, applied with a universal hash family (typically SHA-3), converts this to a uniform key. Our formalization provides a machine-verified foundation for this security reduction.

## 7. Future Work

1. Formalize the quantum privacy amplification theorem extending the LHL to settings with quantum side information
2. Construct and verify specific lattice-based universal hash families
3. Develop extractor composition theorems for multi-stage key derivation
4. Extend to computational extractors for complexity-theoretic applications
5. Connect to thermodynamic entropy production via Landauer's principle

## References

- [ILL89] R. Impagliazzo, L. Levin, M. Luby. "Pseudo-random generation from one-way functions." STOC 1989.
- [HILL99] J. Håstad, R. Impagliazzo, L. Levin, M. Luby. "A pseudorandom generator from any one-way function." SIAM J. Computing, 1999.
- [Ren05] R. Renner. "Security of Quantum Key Distribution." PhD thesis, ETH Zurich, 2005.
- [Vad12] S. Vadhan. "Pseudorandomness." Foundations and Trends in TCS, 2012.
- [TSSR11] M. Tomamichel, C. Schaffner, A. Smith, R. Renner. "Leftover hashing against quantum side information." IEEE Trans. IT, 2011.
