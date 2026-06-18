# Future Directions: Apollonian Spectral-Polynomial Transfer

## Overview

The spectral-polynomial transfer theorem opens five concrete research directions, each connecting Apollonian dynamics to a different area of mathematics. These are ordered by estimated tractability, from most immediately achievable to most ambitious.

---

## Direction 1: Congruence Apollonian Expansion

### Hypothesis
Reducing the Apollonian generators modulo a prime $q$ yields matrices in $\text{GL}_4(\mathbb{Z}/q\mathbb{Z})$ whose Cayley graph is an expander. The spectral transfer theorem then implies mixing of polynomial observables over $\text{ZMod}(q)$.

### Theorem Statement
```
theorem apollonian_mod_q_mixing
    (q : ℕ) [Fact q.Prime] (k : ℕ)
    (γ : ℝ) (hγ : 0 < γ)
    (hgap : ∀ f : MvPolynomial (Fin 4) (ZMod q),
      f.totalDegree ≤ k → isCentered f →
      ‖avgOp_modq q f‖ ≤ (1 - γ) * ‖f‖) :
    ∀ n : ℕ, ∀ f : MvPolynomial (Fin 4) (ZMod q),
      f.totalDegree ≤ k → isCentered f →
        ‖(avgOp_modq q)^n f‖ ≤ (1 - γ)^n * ‖f‖
```

### Proof Strategy
1. Define `apollonianGen_modq q i := (apollonianGen i).map (ZMod.castHom q)`.
2. Verify that the mod-q generators still satisfy $S_i^2 = I$ in $\text{GL}_4(\mathbb{Z}/q\mathbb{Z})$.
3. Define a finite-dimensional norm on $\text{MvPolynomial (Fin 4) (ZMod q)}$ (which is itself a finite set for bounded degree).
4. Apply the existing spectral transfer theorem with the mod-q averaging operator.

### Why This Opens a New Field Line
Congruence expansion is the key input to the Bourgain-Gamburd-Sarnak affine sieve. Formalizing the polynomial observable shadow of congruence expansion would provide the first machine-checked component of the sieve machinery, potentially enabling formalized proofs of local-global principles for thin orbits.

### Cross-Domain Connections
- **Cryptography**: Expander graphs over $\mathbb{Z}/q\mathbb{Z}$ are used in hash functions and error-correcting codes.
- **Additive combinatorics**: The sum-product phenomenon in finite fields underlies the expansion proof.

---

## Direction 2: Lorentzian Orbit-Counting Transfer

### Hypothesis
The exponential decay of degree-$k$ observable norms under the averaging operator can be converted into counting asymptotics for the number $N(X)$ of distinct curvatures $\leq X$ in an Apollonian orbit.

### Theorem Statement
```
theorem apollonian_counting_from_spectral
    (root : Fin 4 → ℤ) (hroot : descartesQ root = 0)
    (k : ℕ) (γ : ℝ) (hγ : apollonian_spectral_gap_for_degree k = γ)
    (X : ℝ) (hX : 0 < X) :
    ∃ C : ℝ, ∀ f : degree_k_observable k,
      |⟨f, empirical_measure_up_to X root⟩ - ⟨f, invariant_measure⟩|
        ≤ C * X^(-γ * k) * ‖f‖
```

### Proof Strategy
1. Define the empirical measure on curvatures up to $X$ and the invariant measure on the limit set.
2. Express the difference of expectations as an iterated application of the averaging operator.
3. Apply the spectral transfer theorem to bound the difference.
4. The counting function $N(X)$ is recovered by choosing appropriate test observables.

### Why This Opens a New Field Line
Kontorovich and Oh proved $N(X) \sim c \cdot X^{\delta}$ where $\delta \approx 1.305$ is the Hausdorff dimension of the gasket. Formalizing the polynomial observable approach to this estimate would connect spectral theory to Hausdorff dimension computations.

---

## Direction 3: Entropy and Information Observables

### Hypothesis
The spectral transfer theorem applies not only to polynomial observables but to "entropy-like" statistics that measure the information content of a curvature quadruple. Define surrogate entropy as a low-degree polynomial approximation to Shannon entropy, and prove it contracts under the averaging operator.

### Theorem Statement
```
def surrogate_entropy (k : ℕ) : MvPolynomial (Fin 4) ℝ :=
  -- Degree-k Taylor approximation to -∑ pᵢ log pᵢ
  -- where pᵢ = bᵢ / ∑ bⱼ

theorem surrogate_entropy_contracts
    (k : ℕ) (γ : ℝ) (hγ : spectral_gap k = γ) :
    ‖avgOp k (centered_part (surrogate_entropy k))‖ ≤
      (1 - γ) * ‖centered_part (surrogate_entropy k)‖
```

### Proof Strategy
1. Define the normalized curvature ratios $p_i = b_i / \sum b_j$.
2. Approximate $-\sum p_i \log p_i$ by a degree-$k$ polynomial (Taylor expansion of log around 1/4).
3. Show the approximation is a valid element of $\mathcal{A}_k$ and apply spectral transfer.
4. The contraction rate measures how quickly the random walk "forgets" its initial information content.

### Why This Opens a New Field Line
This bridges dynamical systems and information theory in a formalized setting. The decay of surrogate entropy under random Apollonian evolution is a quantitative statement about information loss, potentially connecting to thermodynamic interpretations of fractal dynamics.

---

## Direction 4: Representation Stability in Degree $k$

### Hypothesis
The observable representations $\rho_k : \text{Apollonian group} \to \text{GL}(\mathcal{A}_k)$ form a compatible tower as $k$ increases. The decomposition of $\mathcal{A}_k$ into irreducible components stabilizes (in an appropriate sense) as $k \to \infty$.

### Theorem Statement
```
theorem observable_tower_compatibility
    (k : ℕ) (i : Fin 4) :
    ∀ p : MvPolynomial (Fin 4) R,
      p.totalDegree ≤ k →
      inclusion_map k (k+1) (precomposeApollonian R i p) =
        precomposeApollonian R i (inclusion_map k (k+1) p)

theorem invariant_subspace_growth
    (k : ℕ) :
    dim (invariant_subspace k) ≤ dim (invariant_subspace (k+1))
```

### Proof Strategy
1. Define the natural inclusion $\iota_{k,k+1} : \mathcal{A}_k \hookrightarrow \mathcal{A}_{k+1}$.
2. Show $\iota$ commutes with precomposition (naturality).
3. Study the growth of invariant and isotypic subspaces as $k$ increases.
4. Identify the stable irreducible decomposition using representation theory of $O(3,1)$.

### Why This Opens a New Field Line
Representation stability (in the sense of Church-Ellenberg-Farb) for thin group representations is unexplored. Formalizing the tower structure would provide a concrete case study for stability phenomena in infinite-index subgroups of arithmetic groups.

---

## Direction 5: Bridge to Automorphic Shadows (Hecke Operators)

### Hypothesis
The averaging operator $T_k = \frac{1}{4}\sum_i \rho_k(S_i)$ on degree-$k$ observables can be packaged as a discrete Hecke-like operator on a finite-dimensional space. Its spectral theory should relate to automorphic forms on $O(3,1)$.

### Theorem Statement
```
structure HeckeOperator (V : Type*) [Module ℝ V] [FiniteDimensional ℝ V] where
  T : V →ₗ[ℝ] V
  self_adjoint : ∀ v w, ⟪T v, w⟫ = ⟪v, T w⟫
  eigenvalue_bound : ∀ λ ∈ spectrum ℝ T, |λ| ≤ 1

theorem apollonian_avg_is_hecke
    (k : ℕ) :
    ∃ H : HeckeOperator (observable_space ℝ k),
      H.T = apollonian_avg_linear_map k
```

### Proof Strategy
1. Define an inner product on $\mathcal{A}_k$ making the generators orthogonal/unitary.
2. Show the averaging operator is self-adjoint with respect to this inner product.
3. Derive eigenvalue bounds from the spectral gap hypothesis.
4. Connect to the Hecke algebra of $O(3,1;\mathbb{Z})$ by identifying the averaging operator as a Hecke correspondence.

### Why This Opens a New Field Line
The Langlands program connects Hecke operators to automorphic forms and L-functions. Even a finite-dimensional shadow of this connection—formalized and verified—would establish a concrete bridge between combinatorial dynamics and the automorphic world. The Apollonian group, as a thin subgroup of $O(3,1;\mathbb{Z})$, provides a test case where the Langlands philosophy can be made computationally explicit.

### Cross-Domain Connections
- **Analytic number theory**: Hecke eigenvalues encode arithmetic information (Ramanujan conjecture).
- **Quantum chaos**: Hecke operators on hyperbolic manifolds model quantum energy levels.
- **Algebraic geometry**: The modularity theorem connects Hecke algebras to elliptic curves.

---

## Implementation Roadmap

| Direction | Estimated effort | Dependencies | Key Mathlib gaps |
|:---:|:---:|:---:|:---:|
| 1. Congruence | Medium | Current work | ZMod matrix norm |
| 2. Counting | High | Direction 1 | Measure theory on orbits |
| 3. Entropy | Medium | Current work | Taylor polynomial API |
| 4. Stability | High | Current work | Representation theory of O(3,1) |
| 5. Hecke | Very high | Directions 1, 4 | Hecke algebra formalization |

## Team Directive

Form an interdisciplinary team spanning:
- **Formal verification**: Lean/Mathlib expertise for kernel-checked proofs.
- **Number theory**: Understanding of thin groups, automorphic forms, sieves.
- **Dynamical systems**: Transfer operator theory, spectral gap techniques.
- **Computer science**: Expander graph theory, pseudorandomness, complexity.

Each direction should be pursued with:
1. Concrete numerical experiments validating the hypothesis.
2. A formal skeleton with `sorry`-ed helper lemmas.
3. Iterative proof completion, bottom-up from simplest lemmas.
4. Cross-validation with independent computational checks.
