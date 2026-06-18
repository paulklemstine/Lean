# Future Directions: Tropical Spectral Theory for EML Algebras

## Completed Work

This project establishes the formal foundations for tropical spectral duality between max-plus matrix algebra and finitely generated EML endomorphisms. The main results, formalized in Lean 4 with Mathlib, include:

1. **Tropical Perron–Frobenius Theorem**: For any n×n real matrix M (n ≥ 1), there exists a vector v such that (M ⊗ v)_i = μ + v_i, where μ is the maximal cycle mean.

2. **EML Eigencharacter Theorem**: Any finitely generated invariant presentation of an EML endomorphism admits a tropical eigencharacter with eigenvalue equal to the maximal cycle mean.

3. **Iterate Growth Formula**: Under the eigencharacter, the k-th tropical matrix power grows as (k+1)·μ + χ_i, establishing exact linear growth.

## Five Concrete Next Theorems

### 1. Tropical Jordan Theory for Eventually Periodic Max-Plus Operators

**Statement**: For any n×n max-plus matrix M with maximal cycle mean μ, the sequence of normalized matrix powers M^k ⊖ k·μ (where ⊖ denotes tropical subtraction) becomes eventually periodic with period dividing lcm(cycle lengths of critical components).

**Significance**: This is the tropical analogue of the Jordan normal form. It would decompose the long-term behavior of max-plus operators into a finite number of "resonant modes."

**Lean target**:
```lean
theorem tropMatPow_eventually_periodic {n : ℕ} [NeZero n]
    (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (T p : ℕ), 0 < p ∧ ∀ k ≥ T, ∀ i j : Fin n,
      (tropMatPow M (k + p)) i j - (↑(k + p) + 1) * maxCycleMean M =
      (tropMatPow M k) i j - (↑k + 1) * maxCycleMean M
```

### 2. Spectral Decomposition by Critical Components

**Statement**: The critical graph of M decomposes into strongly connected components C₁, ..., C_r. Each component C_a determines an eigenvector v_a supported on vertices reachable from C_a. The general eigenvector is a tropical linear combination of these component eigenvectors.

**Significance**: This generalizes our Perron theorem from irreducible to reducible matrices, providing a complete spectral decomposition.

**Approach**: Define the critical graph, prove its decomposition, and show that the eigenvector space is the tropical convex hull of component eigenvectors.

### 3. Collatz–Wielandt Min-Max Duality for EML Endomorphisms

**Statement**: 
```
maxCycleMean M = min_v max_i (maxPlusMV M v i - v i)
             = max_v min_i (maxPlusMV M v i - v i)  [under irreducibility]
```

**Significance**: This is the tropical analogue of the classical Collatz–Wielandt formula. It characterizes the spectral radius as a saddle point, providing a variational principle for EML spectral theory.

**Lean target**:
```lean
theorem collatz_wielandt_tropical {n : ℕ} [NeZero n]
    (M : Matrix (Fin n) (Fin n) ℝ) :
    maxCycleMean M = ⨅ v : Fin n → ℝ,
      ⨆ i : Fin n, maxPlusMV M v i - v i
```

### 4. Tropical Koopman Eigencharacter Theory for Symbolic Dynamics

**Statement**: Given a symbolic dynamical system on a finite alphabet with an EML observable algebra, the Koopman operator T_φ (composition with the dynamics) admits tropical eigencharacters. The eigenvalues are precisely the growth rates of the observables along orbits.

**Significance**: This connects tropical spectral theory to dynamical systems. The eigencharacters serve as "tropical Koopman modes" — computable invariants of the dynamics analogous to Fourier modes in classical ergodic theory.

**Approach**: Model the shift map on sequences over Fin n, define the EML observable algebra as tropical polynomials, and show the coefficient matrix of the Koopman operator encodes the transition structure.

### 5. Complexity-Theoretic Interpretation of Max Cycle Mean

**Statement**: For a weighted automaton with transition matrix M, the maximal cycle mean equals the asymptotic growth rate of the maximum weight accepted word of length k. Moreover, computing the maximal cycle mean is polynomial-time (O(n³) via Karp's algorithm), while computing individual eigencharacter components requires solving a tropical linear system.

**Significance**: This bridges formal verification with computational complexity. It shows that the spectral invariants we've formalized are not just theoretically interesting but computationally tractable, with applications to:
- Worst-case analysis of timed systems
- Growth rates of neural network activations under tropical interpretation
- Resource consumption bounds in program analysis

**Lean target**: Formalize Karp's dynamic programming algorithm and prove its correctness:
```lean
def karpMaxCycleMean {n : ℕ} [NeZero n] (M : Matrix (Fin n) (Fin n) ℝ) : ℝ := ...

theorem karpMaxCycleMean_correct {n : ℕ} [NeZero n]
    (M : Matrix (Fin n) (Fin n) ℝ) :
    karpMaxCycleMean M = maxCycleMean M
```

## Broader Research Program

These five directions collectively build toward an **idempotent Gelfand theory** — a complete duality between:
- EML operator algebras (the "noncommutative" side)
- Tropical characters and critical graphs (the "spectral" side)

Just as classical Gelfand theory reconstructs a C*-algebra from its character space, tropical Gelfand theory would reconstruct an EML module from its eigencharacter data. The critical graph plays the role of the spectrum, and the eigencharacters play the role of multiplicative functionals.

This vision requires formal verification at each step because the tropical world lacks the topological completeness properties that make classical proofs work. Each theorem above contributes a verified building block toward this larger edifice.
