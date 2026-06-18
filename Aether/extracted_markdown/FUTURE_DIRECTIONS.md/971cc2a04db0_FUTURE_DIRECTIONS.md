# Future Directions: Reed–Muller Codes, PIT, and Algebraic Proof Systems

## Direction 1: Exact Minimum Distance for General Degree d ≥ q

### Target Theorem
For d = a(q − 1) + b with 0 ≤ b < q − 1, the minimum distance of RM_q(n, d) is:
```
d_min = (q − b) · q^(n−1−a)
```

### Proof Strategy
The extremal polynomial is a product of a coordinate blocks and one partial block:
```
f(x₁, …, xₙ) = ∏_{i=1}^{a} ∏_{c ∈ 𝔽} (xᵢ − c) · ∏_{c ∈ s} (x_{a+1} − c)
```
where s is a b-element subset of 𝔽. The first a factors each vanish on an entire coordinate hyperplane, and the last factor vanishes on b hyperplanes in coordinate a+1.

### Key Lemmas Needed
1. `totalDegree_coord_block`: The product ∏_{c ∈ 𝔽} (Xᵢ − c) has degree q − 1.
2. `zeroCount_product_blocks`: Zero-counting for products of full and partial coordinate blocks.
3. `lower_bound_general`: The Schwartz–Zippel-style lower bound for arbitrary d.

### Difficulty: Hard
The lower bound requires careful induction that tracks the degree decomposition d = a(q−1) + b. The key challenge is showing that the extremal zero set configuration is unique (up to coordinate permutations and affine transformations).

### Cross-Domain Impact
- Gives exact parameters for all Reed–Muller codes, not just low-degree ones.
- Relevant to list-decoding capacity for algebraic-geometric codes.
- Connects to weight distributions via Krawtchouk polynomial analysis.

---

## Direction 2: Sum-Check Protocol Soundness from Schwartz–Zippel

### Target Theorem
```
theorem sumcheck_soundness
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ) (hd : d < Fintype.card 𝔽)
  (f : MvPolynomial (Fin n) 𝔽)
  (claimed_sum : 𝔽) (h_false : claimed_sum ≠ ∑ x : Fin n → 𝔽, eval x f) :
  -- The probability that the prover can fool the verifier in one round is ≤ d/q
  -- Formalize the n-round interactive protocol and prove soundness by induction
  sumcheck_cheat_probability f claimed_sum ≤ n * (d : ℚ) / Fintype.card 𝔽
```

### Proof Strategy
The sum-check protocol reduces a multivariate summation claim to n sequential univariate claims. At each round, the verifier sends a random challenge and the Schwartz–Zippel bound guarantees soundness. The total error is at most n · d/q by a union bound.

### Key Components
1. Define the sum-check protocol as an interactive proof system.
2. Prove single-round soundness using the Schwartz–Zippel lemma.
3. Compose rounds via union bound.
4. Handle the recursive reduction from n variables to n−1 variables.

### Cross-Domain Impact
- Foundation for verified interactive proofs (IP = PSPACE).
- Directly relevant to verifiable computation and SNARKs.
- Connects to GKR protocol and delegated computation.

---

## Direction 3: Formal Low-Degree Testing Soundness

### Target Theorem
```
theorem low_degree_test_soundness
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ) (hd : d < Fintype.card 𝔽)
  (f : (Fin n → 𝔽) → 𝔽)
  (h_far : ∀ g : MvPolynomial (Fin n) 𝔽, g.totalDegree ≤ d →
    hamming_dist f (eval · g) > δ * Fintype.card 𝔽 ^ n) :
  -- Random line test rejects with probability ≥ δ
  line_test_rejection_prob f ≥ δ
```

### Proof Strategy
1. Define the line test: pick random point a and direction b, query f along the line a + tb.
2. Show the restriction to a random line is a univariate polynomial of degree ≤ d if f is degree ≤ d.
3. Use the fact that a function far from all degree-d polynomials must have many lines on which the restriction is far from degree-d.
4. Apply the univariate agreement bound.

### Key Innovation
This requires formalizing the notion of *agreement* between a function and a polynomial, and the self-correction machinery of Rubinfeld and Sudan.

### Cross-Domain Impact
- Foundation for PCP theorem and hardness of approximation.
- Connects to locally testable codes and property testing.
- Applications to proof complexity and circuit lower bounds.

---

## Direction 4: Dual Reed–Muller Codes and Secret-Sharing Thresholds

### Target Theorem
```
theorem dual_reed_muller_minimum_distance
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ) (hd : d < (Fintype.card 𝔽 - 1) * n) :
  -- The dual of RM_q(n, d) is RM_q(n, n(q-1) - d - 1)
  -- Its minimum distance follows from the primal minimum distance
  dual_min_distance 𝔽 n d = min_distance 𝔽 n (n * (Fintype.card 𝔽 - 1) - d - 1)
```

### Proof Strategy
1. Prove that RM_q(n, d)⊥ = RM_q(n, n(q−1) − d − 1) using the orthogonality of evaluation vectors.
2. Apply the minimum distance theorem to the dual code.
3. Derive the MacWilliams identity connecting weight enumerators.

### Key Lemma
The orthogonality result requires showing that ∑_{x ∈ 𝔽^n} f(x) · g(x) = 0 whenever deg(f) + deg(g) < n(q − 1), using the fact that ∑_{a ∈ 𝔽} a^k = 0 for 0 < k < q − 1.

### Cross-Domain Impact
- Exact security parameters for Shamir-type secret sharing.
- Robust secret sharing with precise corruption tolerance.
- Connections to algebraic-geometric codes (AG codes as generalizations).

---

## Direction 5: Derandomized PIT for Depth-3 Circuits

### Target Theorem
```
theorem depth3_PIT_deterministic
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d s : ℕ)
  (C : AlgCircuit 𝔽 n)
  (h_depth : C.depth ≤ 3)
  (h_size : C.size ≤ s)
  (h_deg : C.degreeBound ≤ d) :
  -- There exists a deterministic hitting set of size poly(n, d, s)
  ∃ H : Finset (Fin n → 𝔽),
    H.card ≤ (n * d * s) ^ C_constant ∧
    (C.toMvPolynomial ≠ 0 → ∃ x ∈ H, C.eval x ≠ 0)
```

### Proof Strategy
Depth-3 circuits compute sums of products of linear forms (ΣΠΣ circuits). The Klivans–Spielman approach uses:
1. Chinese Remaindering to reduce to bounded characteristic.
2. Subspace-evasive sets to construct explicit hitting sets.
3. Kabanets–Impagliazzo style reductions.

### Key Innovation
Formalizing the connection between circuit structure and polynomial properties in a way that enables deterministic PIT. This bridges algebraic complexity with combinatorial constructions.

### Cross-Domain Impact
- Progress toward full PIT derandomization (a major open problem).
- Connections to circuit lower bounds via hardness-randomness tradeoffs.
- Practical applications to verified symbolic computation.

---

## Suggested Team Structure

- **Team A (Algebraic Foundations):** Directions 1, 4 — extend the minimum distance theory.
- **Team B (Protocol Verification):** Directions 2, 3 — interactive proof soundness.
- **Team C (Complexity Theory):** Direction 5 — circuit-based PIT.

Each team should target a 3-month proof development cycle, with monthly integration checkpoints to ensure consistent API design across the growing library.

## Priority Ordering

1. **Direction 2** (Sum-Check) — highest impact, builds directly on existing infrastructure.
2. **Direction 1** (General distance) — natural mathematical completion of current work.
3. **Direction 4** (Dual codes) — deepens coding-theoretic applications.
4. **Direction 3** (Low-degree testing) — substantial but high-reward.
5. **Direction 5** (Derandomized PIT) — most ambitious, longest timeline.
