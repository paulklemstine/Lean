# Future Directions: Formalized Algebraic Coding Theory and Complexity

## Overview

This document outlines five breakthrough-level research directions opened by our formalization of the exact Reed–Muller minimum distance theorem and PIT soundness. Each direction is specific enough for a research team to pursue, with concrete theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Generalized Reed–Muller Minimum Distance for Arbitrary Degree

### Target Theorem
For d = a(q−1) + b with 0 ≤ b < q−1 and a ≥ 0:

```
minDistance(RM_q(n, d)) = (q − b) · q^(n−1−a)
```

The extremal polynomial is:
```
f = (∏_{j=1}^{a} ∏_{c ∈ 𝔽} (X_j − c)) · (∏_{i=1}^{b} (X_{a+1} − c_i))
```
where each inner product ∏_{c ∈ 𝔽} (X_j − c) = X_j^q − X_j vanishes everywhere (the "vanishing polynomial"), and the remaining factor contributes partial coverage in one more coordinate.

### Proof Strategy
1. Generalize the witness construction to products of vanishing polynomials times a partial linear factor product.
2. Extend the Schwartz–Zippel-based lower bound to account for the q-ary structure.
3. Use the Ore–DeMillo–Lipton bound or a direct combinatorial argument for the tight lower bound.

### Hypotheses to Validate
- H1: The vanishing polynomial ∏_{c ∈ 𝔽} (X − c) = X^q − X in MvPolynomial has exactly q^(n−1) · q = q^n zeros.
- H2: Products of vanishing polynomials in different coordinates have multiplicative zero counts.
- H3: The degree formula d = a(q−1) + b decomposes the extremizer cleanly.

### Cross-Domain Impact
- **Coding theory**: Complete characterization of RM code parameters for all rates.
- **Algebraic geometry**: Connection to the Tsfasman–Vlăduţ–Zink bound for function field codes.
- **Complexity theory**: Generalized low-degree testing for arbitrary degree ranges.

---

## Direction 2: Sum-Check Protocol Soundness from Schwartz–Zippel

### Target Theorem
```
theorem sumcheck_soundness
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ) (hd : d < Fintype.card 𝔽)
  (f : MvPolynomial (Fin n) 𝔽)
  (claimed_sum : 𝔽)
  (h_false : claimed_sum ≠ ∑ x : Fin n → 𝔽, MvPolynomial.eval x f) :
  -- Probability that a cheating prover passes all n rounds
  cheatProbability ≤ (n * d : ℚ) / Fintype.card 𝔽
```

### Proof Strategy
1. **Round-by-round analysis**: In each round, the verifier receives a univariate polynomial and checks it at a random point. By Schwartz–Zippel, each round catches a cheat with probability ≥ 1 − d/q.
2. **Union bound**: Over n rounds, the total cheat probability is at most n·d/q.
3. **Formalization requires**:
   - A clean definition of the interactive protocol state
   - Lemma: partial sums over remaining variables produce degree-bounded univariate polynomials
   - Composition of single-round soundness via the union bound

### Key Lemmas to Formalize
- Partial summation preserves polynomial degree
- Single-round soundness from univariate Schwartz–Zippel
- Protocol correctness: honest prover always passes

### Cross-Domain Impact
- **Verifiable computation**: Sum-check is the core of GKR, Spartan, and other proof systems.
- **Interactive proofs**: IP = PSPACE relies on sum-check.
- **Blockchain**: Polynomial commitment schemes use sum-check variants.

---

## Direction 3: Formal Low-Degree Testing Soundness

### Target Theorem
```
theorem low_degree_test_soundness
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ) (hd : d < Fintype.card 𝔽)
  (f : (Fin n → 𝔽) → 𝔽)
  (h_far : hammingDistance f (closestDegreeD_function d) > δ * q^n) :
  -- Random line test rejects with probability ≥ δ - d/q
  rejectionProbability (lineTest f) ≥ δ - (d : ℚ) / Fintype.card 𝔽
```

### Proof Strategy
1. Define "closeness to degree-d" via Hamming distance to the nearest degree-d evaluation.
2. Formalize the line test: pick a random affine line, restrict f to it, check if the restriction has degree ≤ d.
3. Prove soundness: if f is δ-far from degree-d, the line test rejects with good probability.
4. Key mathematical ingredient: the connection between agreement on random lines and global degree.

### Hypotheses to Validate
- H1: Restriction to a random line produces a univariate polynomial (algebraic formulation).
- H2: If f agrees with a degree-d polynomial on > (1−δ) fraction of a line, that polynomial is unique.
- H3: The "self-correction" property of RM codes enables local-to-global degree certification.

### Cross-Domain Impact
- **PCP theorem**: Low-degree testing is the algebraic core of probabilistically checkable proofs.
- **Property testing**: Foundation for sublinear-time algorithms.
- **Coding theory**: Local testability of RM codes.

---

## Direction 4: Dual Reed–Muller Codes and Secret Sharing Thresholds

### Target Theorem
```
theorem dual_reed_muller_minimum_distance
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ) (hd : d < Fintype.card 𝔽) :
  -- The dual of RM_q(n, d) has minimum distance d + 1
  dualMinimumDistance (reedMullerCode 𝔽 n d) = d + 1
```

Combined with:
```
theorem secret_sharing_threshold
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n t : ℕ) (ht : t ≤ n) :
  -- A (t, n)-threshold Shamir scheme is information-theoretically secure
  -- iff the underlying code has dual distance ≥ t
  secureShamirScheme 𝔽 n t ↔ dualMinimumDistance (shamirCode 𝔽 n t) ≥ t
```

### Proof Strategy
1. Define the dual code via the inner product pairing on evaluation vectors.
2. Relate the dual of RM_q(n, d) to RM_q(n, n(q−1)−d−1) via Delsarte's theorem.
3. Apply the minimum distance formula to the dual.
4. Translate to secret sharing via the equivalence between privacy and dual distance.

### Cross-Domain Impact
- **Cryptography**: Formal certification of Shamir threshold correctness.
- **MPC**: Security of multiparty computation protocols.
- **Coding theory**: Weight enumerator duality.

---

## Direction 5: Derandomized PIT for Restricted Circuit Classes

### Target Theorem
```
theorem derandomized_pit_depth3
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n s : ℕ)
  (C : Depth3Circuit 𝔽 n s)
  (hC : circuitPolynomial C ≠ 0) :
  -- There exists an explicit hitting set of polynomial size
  ∃ H : Finset (Fin n → 𝔽),
    H.card ≤ poly(n, s) ∧
    ∃ x ∈ H, MvPolynomial.eval x (circuitPolynomial C) ≠ 0
```

### Proof Strategy
1. Define depth-3 arithmetic circuits (ΣΠΣ circuits).
2. Use the Dvir–Shpilka generator or Kabanets–Impagliazzo approach.
3. Key ingredient: if a ΣΠΣ circuit of size s computes a nonzero polynomial, it has a "structured" nonzero evaluation that can be found deterministically.
4. The Reed–Muller minimum distance provides the base case: the polynomial has a large support.

### Hypotheses to Validate
- H1: Depth-3 circuits of size s compute polynomials of degree at most s.
- H2: The rank of the linear forms in a ΣΠΣ circuit controls the "dimension" of the zero set.
- H3: Subspace-evasive sets can be constructed explicitly and used as hitting sets.

### Cross-Domain Impact
- **Complexity theory**: Progress toward P ≠ NP via algebraic circuit lower bounds.
- **Algorithms**: Efficient deterministic polynomial identity testing.
- **Cryptography**: Derandomization of cryptographic primitives.

---

## Implementation Roadmap

### Phase 1 (Near-term, 1–3 months)
- Direction 1: Generalized RM distance for d < 2(q−1)
- Direction 4: Shamir secret sharing threshold for univariate case (Reed–Solomon)

### Phase 2 (Medium-term, 3–6 months)
- Direction 2: Sum-check protocol soundness
- Direction 1: Full generalized RM distance

### Phase 3 (Long-term, 6–12 months)
- Direction 3: Low-degree testing
- Direction 5: Derandomized PIT for restricted circuits

### Dependencies
- Direction 2 depends on Direction 1 (need general degree bounds)
- Direction 3 depends on Direction 2 (sum-check is used in low-degree tests)
- Direction 4 is largely independent
- Direction 5 depends on Directions 1–3

---

## Key Infrastructure Needed

1. **Evaluation codes as linear codes**: Define the subspace structure of RM codes.
2. **Dual code construction**: General framework for code duality.
3. **Interactive protocol formalization**: State machines for verifier-prover interactions.
4. **Circuit complexity**: Arithmetic circuits, depth, and size measures.
5. **Subspace-evasive sets**: Explicit constructions from algebraic geometry.

Each piece of infrastructure should be designed for reuse across multiple directions, following the modular approach of our current formalization.
