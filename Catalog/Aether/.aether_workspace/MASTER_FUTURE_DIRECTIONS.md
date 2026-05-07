# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-07 16:40*

## Breakthrough Opportunities (Ranked by Impact)

### 1. Berggren Tree Completeness Theorem

**Theorem Statement**: Every primitive Pythagorean triple (a,b,c) with a² + b² = c², gcd(a,b) = 1, and a,b,c > 0 appears exactly once in the Berggren tree.

**Proof Strategy**:
- **Approach A (Matrix Inversion)**: Show that each triple has a unique parent via the inverse Berggren matrices. The parent has strictly smaller hypotenuse (already proven: `berggrenA_hyp_increases`, `berggrenB_hyp_increases`, `berggrenC_hyp_increases`). By well-founded induction on c, every triple reduces to (3,4,5).
- **Approach B (Euclid Parametrization)**: Use the parametrization (m²-n², 2mn, m²+n²) and show that the Berggren tree traversal corresponds to the Stern-Brocot tree on the (m,n) parameter space.
- **Key Lemma**: For any primitive triple with c > 5, exactly one of the three inverse matrices produces a triple with all components positive.

**Why This Is Revolutionary**: Completes the algebraic characterization of primitive Pythagorean triples. Opens the door to proving that the quantum walk is complete (every target is reachable).

**Catalog Leverage**: `berggrenA_hyp_increases`, `berggrenB_hyp_increases`, `berggrenC_hyp_increases`, `berggrenPath_pythagorean`

**Research Mode**: prove

**Estimated Depth**: 4

---

### 2. Spectral Gap of the Finite Berggren Walk

**Theorem Statement**: The spectral gap γ_d of the walk operator on B_d satisfies γ_d ≥ C/(d+1) for some absolute constant C > 0.

**Proof Strategy**:
- **Approach A (Cheeger Inequality)**: The Berggren tree at depth d has Cheeger constant h(G) ≥ c/d for some constant c. By the discrete Cheeger inequality, the spectral gap satisfies γ ≥ h²/(2Δ) where Δ = 4 (max degree).
- **Approach B (Kesten's Theorem Transfer)**: The spectral radius of the adjacency operator on the infinite 4-regular tree is 2√3/4 = √3/2 (Kesten). The finite truncation's gap interlaces with this, giving a lower bound.
- **Key Lemma**: The tree expansion constant (ratio of boundary to interior) is Ω(1/d).

**Why This Is Revolutionary**: Determines the convergence rate of the quantum walk and thus the precise quantum search complexity. Connects tree spectral theory to quantum algorithms.

**Catalog Leverage**: `ternary_total_recurrence`, `quantum_faster_than_classical`

**Research Mode**: prove

**Estimated Depth**: 5

---

### 3. Divisibility Filter Amplitude Bounds

**Theorem Statement**: For the quantum walk state |ψ_t⟩ after t steps on B_d, and for N composite:
- |⟨v|ψ_t⟩|² ≥ C₁/(d·|T|) when c_v | N (where T = {v : c_v | N})
- |⟨v|ψ_t⟩|² ≤ C₂/d² when gcd(c_v, N) = 1

**Proof Strategy**:
- Formalize the modular propagation results (`berggrenB_hyp_mod`, etc.) into a phase coherence argument
- Show that divisor vertices have aligned phases (constructive interference) while coprime vertices have randomized phases (destructive interference)
- Use the Pell sequence structure to bound the phase alignment

**Why This Is Revolutionary**: Would provide the first rigorous quantum algorithm for number-theoretic divisibility testing on trees, with applications to Gaussian integer factorization.

**Catalog Leverage**: `berggrenB_hyp_mod`, `filter_ratio`, `berggrenPath_pythagorean`

**Research Mode**: formalize

**Estimated Depth**: 5

---

### 4. Pell Eigenvalue Phase Classification

**Theorem Statement**: For each depth d, the eigenvalues of the walk operator U_d on the B-branch subspace have phases θ ∈ Q(√2), and the full walk operator has eigenvalues with phases in ⋃_k Q(√d_k) for a finite set of fundamental discriminants {d_k}.

**Proof Strategy**:
- The B-branch walk is governed by the matrix B with characteristic polynomial related to t² - 6t + 1 = 0
- The eigenvalues of B^n are determined by the Pell sequence, which lives in Q(√2)
- For the full tree, use the representation theory of the Berggren subgroup of O(2,1;ℤ)

**Why This Is Revolutionary**: Establishes a direct dictionary between quantum walk spectra and Pell equation solutions, opening quantum approaches to fundamental discriminant computation.

**Catalog Leverage**: `pellHypSeq_recurrence`, `pell_char_discriminant`, `berggrenMatB_sq_trace`

**Research Mode**: formalize

**Estimated Depth**: 4

---

### 5. Quantum Walk on PSL(2,ℤ) via Berggren-Modular Correspondence

**Theorem Statement**: The Berggren subgroup ⟨A,B,C⟩ ⊂ O(2,1;ℤ) maps to a finite-index subgroup of PSL(2,ℤ) via the isomorphism O(2,1;ℤ)/{±I} ≅ PGL(2,ℤ).

**Proof Strategy**:
- Construct the explicit 2×2 matrix representatives for A, B, C in PGL(2,ℤ)
- Compute the index of the Berggren subgroup
- Transfer spectral results from the modular group

**Why This Is Revolutionary**: Connects the Berggren tree to the theory of modular forms and Maass waveforms, potentially linking quantum walk eigenvalues to L-functions.

**Catalog Leverage**: `lorentz_product_closure`, `berggren_all_lorentz`

**Research Mode**: formalize

**Estimated Depth**: 3

---