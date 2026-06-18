# Future Directions: Reed–Muller Codes, PIT, and Algebraic Proof Systems

## Overview

This document outlines five concrete, breakthrough-level research directions opened by the formalization of the exact Reed–Muller minimum distance theorem and PIT soundness for algebraic circuits. Each direction includes specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Generalized Reed–Muller Minimum Distance for Arbitrary Degree

### Target Theorem

For d = a(q − 1) + b with 0 ≤ b < q − 1, the minimum distance of RM_q(n, d) is:

> δ = (q − b) · q^(n − 1 − a)

This generalizes our result (which covers a = 0, b = d < q) to arbitrary degrees d ≥ 0.

### Why It Matters

- Completes the coding-theoretic picture for all Reed–Muller codes, not just the "low-degree" regime.
- The extremal codeword is no longer a product of linear factors in one variable — it becomes a product of a(q−1) factors spread across a coordinates, plus b factors in a (a+1)-th coordinate. This richer structure connects to tensor product codes and recursive code constructions.

### Proof Strategy

1. **Decompose d = a(q − 1) + b** and define the extremal polynomial as:
   ```
   f = (∏_{i=1}^{a} ∏_{c ∈ 𝔽_q \ {0}} (X_i − c)) · (∏_{j=1}^{b} (X_{a+1} − c_j))
   ```
   This vanishes when any of the first a coordinates is nonzero (which happens with probability (1 − 1/q)^a ≈ e^{-a/q}) OR when the (a+1)-th coordinate is in {c_1, ..., c_b}.

2. **Count zeros by inclusion-exclusion** or, more elegantly, by the tensor product structure: the zero set is a union of coordinate flats.

3. **Prove the lower bound** by a refined induction on variables using the structure theory of the leading coefficient polynomial.

### Lean Target

```lean
theorem reedMuller_generalized_minimum_distance
    (q n d a b : ℕ)
    (hq : 1 < q) (hn : a + 1 ≤ n)
    (hd : d = a * (q - 1) + b)
    (hb : b < q - 1) :
    reedMullerMinDist 𝔽 n d = (q - b) * q ^ (n - 1 - a)
```

### Cross-Domain Impact

- **Coding theory:** Completes the weight hierarchy for Reed–Muller codes.
- **Algebraic geometry:** Characterizes extremal hypersurface arrangements over finite fields.
- **Complexity theory:** Sharpens degree-reduction arguments in algebraic circuit lower bounds.

---

## Direction 2: Sum-Check Protocol Soundness

### Target Theorem

The sum-check protocol for verifying ∑_{x ∈ {0,1}^n} f(x) = T has soundness error at most nd/|𝔽|, where d = deg(f).

### Why It Matters

The sum-check protocol (Lund–Fortnow–Karloff–Nisan, 1992) is the workhorse of interactive proof systems. It underlies:
- The IP = PSPACE theorem
- GKR protocol for verifiable computation
- All modern SNARK and STARK constructions
- Multilinear extension-based proof systems

A formal verification would be the first machine-checked proof of interactive proof soundness.

### Proof Strategy

1. **Define the sum-check protocol** as an n-round interactive protocol.
2. **Prove round soundness:** In each round, the prover sends a univariate polynomial of degree ≤ d. The verifier checks consistency at a random point. By Schwartz–Zippel (degree d, univariate), the error per round is ≤ d/q.
3. **Union bound:** Over n rounds, the total soundness error is ≤ nd/q.

### Lean Target

```lean
theorem sumcheck_soundness
    (f : MvPolynomial (Fin n) 𝔽) (T : 𝔽)
    (hT : ∑ x in (Finset.univ : Finset (Fin n → 𝔽)), MvPolynomial.eval x f ≠ T)
    (hd : f.totalDegree ≤ d) :
    cheating_probability_sumcheck f T ≤ n * d / Fintype.card 𝔽
```

### Cross-Domain Impact

- **Complexity theory:** First formal proof of IP = PSPACE ingredients.
- **Cryptography:** Foundation for formally verified SNARKs.
- **Blockchain:** Verified scalability arguments for rollup protocols.

---

## Direction 3: Low-Degree Testing Soundness

### Target Theorem

The Rubinfeld–Sudan low-degree test: given oracle access to a function f : 𝔽_q^n → 𝔽_q, the test accepts with high probability if and only if f is close to a polynomial of degree ≤ d.

### Why It Matters

Low-degree testing is the algebraic foundation of probabilistically checkable proofs (PCPs). The PCP theorem — one of the most celebrated results in theoretical computer science — relies on the ability to test whether a function is "close" to a low-degree polynomial by querying it at a small number of points.

### Proof Strategy

1. **Define the test:** Pick a random line ℓ in 𝔽_q^n. Query f at d + 2 points on ℓ. Check if the restriction f|_ℓ is a univariate polynomial of degree ≤ d.

2. **Prove completeness:** If f is degree-≤-d, the test always accepts.

3. **Prove soundness:** If f is δ-far from every degree-≤-d polynomial, the test rejects with probability ≥ Ω(δ). This requires the "self-correction" lemma and the agreement theorem.

### Lean Target

```lean
theorem low_degree_test_soundness
    (f : (Fin n → 𝔽) → 𝔽)
    (hfar : ∀ g : MvPolynomial (Fin n) 𝔽, g.totalDegree ≤ d →
      hammingDist f (MvPolynomial.eval · g) ≥ δ * Fintype.card 𝔽 ^ n) :
    rejection_probability_ldt f ≥ C * δ
```

### Cross-Domain Impact

- **PCP theory:** First formal ingredient toward verified PCP construction.
- **Property testing:** Foundation for formally verified property testing algorithms.
- **Coding theory:** Connection to list-decoding radius of Reed–Muller codes.

---

## Direction 4: Reed–Muller Dual Codes and Weight Distribution

### Target Theorem

The weight distribution of RM_q(n, d) — the number of codewords of each Hamming weight — satisfies the MacWilliams identity relating it to the weight distribution of the dual code RM_q(n, n(q−1) − d − 1).

### Why It Matters

- **Secret sharing:** The weight distribution determines the information-theoretic security of polynomial-based secret sharing against coalitions of arbitrary size, not just threshold coalitions.
- **Coding bounds:** Weight distributions yield improved bounds on code performance under maximum likelihood decoding.
- **Combinatorics:** The weight distribution of Reed–Muller codes encodes deep combinatorial information about polynomial zero sets.

### Proof Strategy

1. **Formalize the dual code** RM_q(n, d)^⊥ and prove it equals RM_q(n, n(q−1) − d − 1).
2. **Prove the MacWilliams identity** relating weight enumerators via the Krawtchouk transform.
3. **Compute the weight distribution** for small cases and verify against known formulas.

### Lean Target

```lean
theorem reed_muller_dual
    (n d : ℕ) (hd : d ≤ n * (q - 1)) :
    dualCode (reedMullerCode 𝔽 n d) = reedMullerCode 𝔽 n (n * (q - 1) - d - 1)
```

### Cross-Domain Impact

- **Cryptography:** Exact security analysis for polynomial-based secret sharing.
- **Information theory:** Capacity-achieving properties of Reed–Muller codes.
- **Algebraic combinatorics:** Connections to association schemes and harmonic analysis on finite groups.

---

## Direction 5: Derandomized PIT for Restricted Circuit Classes

### Target Theorem

For depth-3 ΣΠΣ circuits (sums of products of sums) of polynomial size over 𝔽_q, PIT can be solved deterministically in polynomial time using a hitting set of size poly(n, d, s) where s is the circuit size.

### Why It Matters

Derandomizing PIT is one of the central open problems in computational complexity. While general PIT derandomization is as hard as proving circuit lower bounds (Kabanets–Impagliazzo), restricted classes admit explicit hitting sets. This is a concrete, achievable target with deep implications:

- **Complexity theory:** Progress on the PIT ↔ circuit lower bounds connection.
- **Algebra:** Structural understanding of polynomial identity testing.
- **Practice:** Deterministic algorithms for symbolic computation.

### Proof Strategy

1. **Define depth-3 ΣΠΣ circuits** and their polynomial semantics.
2. **Construct an explicit hitting set** using the Shpilka–Volkovich method (based on variable reduction and small evaluation domains).
3. **Prove completeness and soundness** of the hitting set: every nonzero ΣΠΣ polynomial evaluates to nonzero on at least one point of the hitting set.

### Lean Target

```lean
theorem sigma_pi_sigma_pit_derandomized
    (C : ΣΠΣCircuit 𝔽 n)
    (hs : C.size ≤ s)
    (hd : C.degree ≤ d) :
    C.toPoly ≠ 0 →
    ∃ x ∈ hittingSet 𝔽 n d s, MvPolynomial.eval x C.toPoly ≠ 0
```

### Cross-Domain Impact

- **Complexity theory:** Concrete progress on PIT derandomization.
- **Formal methods:** First verified algebraic derandomization result.
- **Symbolic computation:** Certified polynomial identity testing without randomness.

---

## Research Methodology

Each direction should proceed by:

1. **Literature survey:** Identify the sharpest known results and proof techniques.
2. **Mathlib audit:** Check which algebraic/combinatorial infrastructure exists.
3. **Skeleton development:** Write theorem statements and proof skeletons with sorry.
4. **Bottom-up proving:** Prove auxiliary lemmas first, main theorems last.
5. **Verification:** Ensure all proofs compile without sorry and use only standard axioms.
6. **Documentation:** Write detailed docstrings and proof sketches for each theorem.

---

## Priority Ordering

1. **Direction 2 (Sum-Check):** Most impactful, builds directly on Schwartz–Zippel.
2. **Direction 1 (Generalized RM):** Natural extension, moderate difficulty.
3. **Direction 3 (Low-Degree Testing):** High impact, requires substantial new infrastructure.
4. **Direction 4 (Dual Codes):** Clean mathematics, connects to cryptographic applications.
5. **Direction 5 (Derandomized PIT):** Most ambitious, potentially transformative.

---

## Cross-Cutting Themes

All five directions share common infrastructure needs:

- **Polynomial evaluation and counting over finite fields** (established in this work)
- **Interactive protocol formalization** (needed for Directions 2, 3)
- **Circuit complexity models** (established in this work, needed for Direction 5)
- **Code duality and weight enumerators** (needed for Direction 4)
- **Hitting set constructions** (needed for Directions 3, 5)

Building this infrastructure creates a reusable foundation for the entire research program in formalized algebraic complexity theory.
