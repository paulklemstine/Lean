# Future Directions: Reed–Muller Codes, PIT, and Algebraic Proof Systems

## Overview

The formal verification of the exact minimum distance theorem for Reed–Muller codes and PIT soundness opens a rich landscape of follow-up research. Each direction below is a concrete, breakthrough-level target with specific theorem statements, proof strategies, and cross-domain connections.

---

## Direction 1: Generalized Reed–Muller Minimum Distance for Arbitrary Degree

### Target Theorem

For a finite field 𝔽_q, n variables, and any degree d ≥ 0, write d = a(q−1) + b with 0 ≤ b < q−1. The minimum Hamming weight of nonzero codewords in RM_q(n, d) is:

```
min_weight = (q − b) · q^(n−1−a)
```

when a < n (i.e., d < n(q−1)). When d ≥ n(q−1), the minimum weight is 1 (the code includes all functions).

### Proof Strategy

1. **Lower bound**: Generalize Schwartz–Zippel using "degree reduction" — when d ≥ q−1, the polynomial x^q − x vanishes everywhere, so effective degree is controlled by the quotient-remainder decomposition.

2. **Extremal witness**: The witness is
   ```
   f(x₁,...,xₙ) = ∏_{i=1}^{a} ∏_{c ∈ 𝔽_q \ {0}} (xᵢ − c) · ∏_{j=1}^{b} (x_{a+1} − cⱼ)
   ```
   This vanishes on a precisely computable union of coordinate subspaces.

3. **Key challenge**: The fibers are no longer parallel hyperplanes in a single coordinate; the zero set has a tensor-product structure across multiple coordinates.

### Formalization Target

```lean
theorem generalized_reedMuller_min_distance
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d a b : ℕ)
    (h_decomp : d = a * (Fintype.card 𝔽 - 1) + b)
    (hb : b < Fintype.card 𝔽 - 1)
    (ha : a < n) :
    reedMullerMinWeight 𝔽 n d = (Fintype.card 𝔽 - b) * (Fintype.card 𝔽) ^ (n - 1 - a)
```

### Cross-Domain Connections
- **Coding theory**: Completes the parameter analysis for all generalized Reed–Muller codes
- **Algebraic geometry**: Classification of extremal hypersurfaces in finite affine space
- **Complexity theory**: Tight soundness bounds for algebraic PCPs with arbitrary degree

### Difficulty: ★★★★☆

---

## Direction 2: Sum-Check Protocol Soundness

### Target Theorem

The sum-check protocol allows a prover to convince a verifier of the value of
```
H = Σ_{x₁ ∈ {0,1}} Σ_{x₂ ∈ {0,1}} ··· Σ_{xₙ ∈ {0,1}} g(x₁, ..., xₙ)
```
for a polynomial g of total degree d, using n rounds of interaction. The verifier uses O(n) random field elements and O(d · n) communication.

**Soundness**: If the prover claims a wrong sum H' ≠ H, the verifier rejects with probability at least 1 − nd/q.

### Proof Strategy

1. **Round-by-round analysis**: At each round i, the prover sends a univariate polynomial sᵢ(xᵢ) of degree ≤ d. The verifier checks sᵢ(0) + sᵢ(1) against the expected partial sum, then replaces xᵢ with a random rᵢ.

2. **Inductive soundness**: If the prover cheats in round i, they must send a polynomial sᵢ that disagrees with the true partial sum polynomial. By Schwartz–Zippel (d=1 univariate case), the verifier catches this with probability at least 1 − d/q.

3. **Union bound**: Over n rounds, the total error probability is at most nd/q.

### Formalization Target

```lean
theorem sumCheck_soundness
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d : ℕ) (g : MvPolynomial (Fin n) 𝔽) (H_claimed H_true : 𝔽)
    (hH : H_claimed ≠ H_true)
    (hdeg : g.totalDegree ≤ d) :
    verifierRejectProbability n d g H_claimed ≥ 1 - n * d / Fintype.card 𝔽
```

### Cross-Domain Connections
- **Interactive proofs**: The sum-check protocol is the core of IP = PSPACE
- **Zero-knowledge proofs**: Sum-check is used in zkSNARKs and zkSTARKs
- **Verifiable computation**: Delegating computation to untrusted servers
- **Cryptographic commitments**: Polynomial commitment schemes build on sum-check

### Difficulty: ★★★★★

---

## Direction 3: Low-Degree Test Soundness (Rubinfeld–Sudan)

### Target Theorem

The Rubinfeld–Sudan low-degree test:
1. Pick a random point x ∈ 𝔽_q^n and a random direction y ∈ 𝔽_q^n
2. Query f at d+2 points on the line {x + ty : t ∈ 𝔽_q}
3. Check if the queried values lie on a univariate polynomial of degree ≤ d

**Soundness**: If f is δ-far from every degree-≤d polynomial (in relative Hamming distance), the test rejects with probability at least Ω(δ).

### Proof Strategy

1. **Restriction to lines**: Show that a random line through 𝔽_q^n gives a univariate restriction of f.
2. **Agreement counting**: If f agrees with some degree-≤d polynomial g on a random line with high probability, then f agrees with g on many points overall.
3. **Self-correction**: Use agreement on many lines to show f is globally close to a low-degree polynomial.
4. **Distance amplification**: Use the Reed–Muller minimum distance to convert "close to a codeword" into "is a codeword."

### Formalization Target

```lean
theorem lowDegreeTest_soundness
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d : ℕ) (f : (Fin n → 𝔽) → 𝔽)
    (hδ : relativeDistance f (closestCodeword f n d) ≥ δ) :
    rejectProbability (lowDegreeTest f n d) ≥ c * δ
```

### Cross-Domain Connections
- **PCP theorem**: Low-degree testing is the algebraic core of probabilistically checkable proofs
- **Property testing**: Paradigmatic example of local testability
- **Coding theory**: Testing proximity to a Reed–Muller codeword

### Difficulty: ★★★★★

---

## Direction 4: Dual Reed–Muller Structure and Secret-Sharing Thresholds

### Target Theorem

The dual code of RM_q(n, d) is RM_q(n, n(q−1)−d−1). This duality relates:
- Minimum distance of the code → covering properties of the dual
- Weight distribution of the code → MacWilliams transform of the dual

For Shamir's secret sharing: the (t, n)-threshold scheme over 𝔽_q using degree-(t−1) polynomials has:
- **Reconstruction threshold**: Any t shares determine the secret (by Lagrange interpolation)
- **Privacy threshold**: Any t−1 shares reveal zero information (by the minimum distance of the dual)
- **Robustness**: Can detect up to (n − 2t + 1) / 2 cheating shareholders (by the minimum distance)

### Proof Strategy

1. **Dual code identification**: Show the annihilator of RM_q(n, d) under the evaluation inner product is RM_q(n, n(q−1)−d−1).
2. **MacWilliams identity**: Relate weight enumerators via the MacWilliams transform.
3. **Threshold extraction**: Derive secret-sharing parameters from code parameters.

### Formalization Target

```lean
theorem reedMuller_dual
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d : ℕ) (hd : d < n * (Fintype.card 𝔽 - 1)) :
    dualCode (reedMullerCode 𝔽 n d) = reedMullerCode 𝔽 n (n * (Fintype.card 𝔽 - 1) - d - 1)
```

### Cross-Domain Connections
- **Cryptography**: Optimal secret sharing, verifiable secret sharing
- **Quantum error correction**: CSS codes from Reed–Muller and dual Reed–Muller
- **Algebraic combinatorics**: Weight enumeration and association schemes

### Difficulty: ★★★★☆

---

## Direction 5: Deterministic PIT for Restricted Circuit Classes

### Target Theorem

For depth-3 ΣΠΣ circuits (sums of products of sums of variables) computing n-variate polynomials of degree d over 𝔽_q, there exists a deterministic polynomial-time identity testing algorithm.

Specifically: there exists a **hitting set** H ⊆ 𝔽_q^n of size poly(n, d, q) such that every nonzero polynomial computed by a ΣΠΣ circuit of the given parameters is nonzero on some point in H.

### Proof Strategy

1. **Subspace-evasive sets**: Construct sets that avoid low-dimensional affine subspaces. These serve as hitting sets because the zero set of a ΣΠΣ circuit is a union of low-dimensional subspaces.

2. **Rank-based analysis**: Decompose ΣΠΣ circuits by the rank of their linear forms. Low-rank circuits have structured zero sets; high-rank circuits have few zeros by Schwartz–Zippel.

3. **Bootstrapping**: Use the minimum distance theorem to show that polynomials with structured zero sets must have very specific forms, enabling deterministic enumeration.

### Formalization Target

```lean
theorem deterministic_PIT_depth3
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d : ℕ)
    (C : Depth3Circuit 𝔽 n) (hdeg : circuitDegree C ≤ d)
    (hnz : circuitPolynomial C ≠ 0) :
    ∃ x ∈ hittingSet 𝔽 n d, circuitEval C x ≠ 0
```

### Cross-Domain Connections
- **Complexity theory**: P vs BPP — derandomization of randomized algorithms
- **Algebraic complexity**: Lower bounds from upper bounds (the "hardness vs randomness" paradigm)
- **Pseudorandomness**: Explicit constructions of pseudorandom objects
- **Coding theory**: Subspace designs and list-decodable codes

### Difficulty: ★★★★★

---

## Research Infrastructure Recommendations

### Near-Term (1–3 months)
- Formalize the weight enumerator of RM_q(n, 1) (first-order Reed–Muller)
- Build a reusable library for evaluation codes over finite fields
- Formalize Freivalds' algorithm as a verified program using PIT soundness

### Medium-Term (3–6 months)
- Generalized minimum distance (Direction 1)
- Sum-check protocol with verified soundness (Direction 2)
- Dual code structure for Reed–Muller codes (Direction 4)

### Long-Term (6–12 months)
- Low-degree testing soundness (Direction 3)
- Deterministic PIT for restricted circuits (Direction 5)
- Connections to quantum error correction (CSS codes from Reed–Muller duality)

### Team Structure
- **Core formalization team**: 2–3 researchers experienced in Mathlib-style formalization
- **Mathematical advisors**: Experts in coding theory, algebraic complexity, and cryptography
- **Infrastructure**: Continuous integration for Lean builds, documentation generation

---

## Impact Assessment

Each direction, if successfully formalized, would represent a significant advance:

| Direction | Mathematical Impact | CS Impact | Crypto Impact |
|-----------|-------------------|-----------|---------------|
| 1. Generalized min dist | ★★★★★ | ★★★☆☆ | ★★★☆☆ |
| 2. Sum-check | ★★★☆☆ | ★★★★★ | ★★★★★ |
| 3. Low-degree test | ★★★★☆ | ★★★★★ | ★★★★☆ |
| 4. Dual codes | ★★★★★ | ★★★☆☆ | ★★★★★ |
| 5. Deterministic PIT | ★★★★☆ | ★★★★★ | ★★★☆☆ |

The combination of Directions 1 + 2 + 4 would create the most complete formal library for algebraic coding theory and its cryptographic applications. Direction 5 is the most ambitious but would have transformative impact on the theory of derandomization.
