# Future Directions

## Research Roadmap: From Polynomial Interpolation Equivalence to Algebraic Coding and Reconstruction Infrastructure

The certified linear equivalence between polynomial evaluation and Lagrange interpolation opens five concrete research directions, each of breakthrough caliber. This document specifies precise theorem targets, proof strategies, and cross-domain impact for each.

---

## 1. Reed–Solomon Minimum Distance Theorem

### Theorem Statement

```
theorem reed_solomon_min_distance
    (K : Type*) [Field K] (v : Fin n → K) (hv : Function.Injective v) (k : ℕ) (hk : k ≤ n) :
    ∀ p q : Polynomial.degreeLT K k,
      p ≠ q → (Finset.univ.filter (fun i => p.1.eval (v i) ≠ q.1.eval (v i))).card ≥ n - k + 1
```

Equivalently: the evaluation code of degree-$< k$ polynomials on $n$ distinct points has minimum Hamming distance $d = n - k + 1$.

### Why Breakthrough

This converts the linear equivalence into a *coding-theoretic engine*. The minimum distance is the fundamental parameter governing error-correction capability of Reed–Solomon codes — the most widely deployed algebraic codes in practice (QR codes, DVDs, deep-space communications, cloud storage). A formal proof would be the first machine-verified RS distance theorem.

### Proof Strategy

1. **Hamming weight lower bound**: If $p \neq q$, then $p - q$ is a nonzero polynomial of degree $< k$, hence has at most $k - 1$ roots among the $n$ evaluation points. Therefore $p$ and $q$ differ in at least $n - (k - 1) = n - k + 1$ positions.
2. **Achievability**: Construct two polynomials differing in exactly $n - k + 1$ positions (one is $q = 0$, the other is a polynomial of degree $k - 1$ that vanishes at exactly $k - 1$ of the $n$ points).
3. **Use** `evalOnNodesLinearEquiv` to transport the distance computation between coefficient and evaluation representations.

### Cross-Domain Impact

- **Coding theory**: Foundational parameter for decoder design and performance guarantees.
- **Cryptography**: Underpins security proofs for polynomial-based commitment schemes.
- **Information theory**: Provides the Singleton bound with equality (MDS codes).

---

## 2. Multivariate Tensor-Product Interpolation

### Theorem Statement

```
noncomputable def multivariateEvalEquiv
    (K : Type*) [Field K] (m : ℕ)
    (ns : Fin m → ℕ) (vs : (i : Fin m) → Fin (ns i + 1) → K)
    (hvs : ∀ i, Function.Injective (vs i)) :
    (⨂[K] i : Fin m, Polynomial.degreeLT K (ns i + 1)) ≃ₗ[K]
    ((i : Fin m) → Fin (ns i + 1)) → K
```

A linear equivalence between tensor products of univariate bounded-degree polynomial spaces and functions on a Cartesian product grid.

### Why Breakthrough

Multivariate interpolation on product grids is the algebraic foundation for:
- Multidimensional spectral methods in numerical PDE,
- Tensor codes in distributed storage,
- Multilinear extensions used in interactive proofs (sum-check protocol).

No formalization of multivariate tensor-product interpolation currently exists.

### Proof Strategy

1. **Base case**: The univariate linear equivalence (`evalOnNodesLinearEquiv`).
2. **Tensor step**: Use the universal property of tensor products to lift the componentwise equivalences. Specifically, the tensor product of linear equivalences is a linear equivalence:
   $(\mathcal{P}_{\le n_1} \otimes \mathcal{P}_{\le n_2}) \cong (\text{Fin}(n_1+1) \to K) \otimes (\text{Fin}(n_2+1) \to K) \cong ((\text{Fin}(n_1+1) \times \text{Fin}(n_2+1)) \to K)$.
3. **Induction** on the number of variables $m$.

### Cross-Domain Impact

- **Numerical analysis**: Rigorous foundation for spectral element methods on product grids.
- **Cryptography**: Certified multilinear extensions for sum-check based proof systems (Lasso, Spartan, etc.).
- **Tensor decomposition**: Algebraic interface for exact tensor reconstruction.

---

## 3. Noisy Reconstruction: Berlekamp–Welch Decoding

### Theorem Statement

```
theorem berlekamp_welch_decoding
    (K : Type*) [Field K] (v : Fin n → K) (hv : Function.Injective v)
    (k : ℕ) (hk : 2 * k ≤ n + 1)
    (p : Polynomial.degreeLT K k)
    (received : Fin n → K)
    (herrors : (Finset.univ.filter (fun i => received i ≠ p.1.eval (v i))).card ≤ (n - k) / 2) :
    ∃! q : Polynomial.degreeLT K k,
      (Finset.univ.filter (fun i => received i ≠ q.1.eval (v i))).card ≤ (n - k) / 2 ∧ q = p
```

### Why Breakthrough

This extends from erasure decoding (known missing positions) to *error correction* (unknown corrupted positions). The Berlekamp–Welch algorithm is the classical algebraic decoder for Reed–Solomon codes. A formalized version would be the first machine-verified result on bounded-distance decoding of algebraic codes.

### Proof Strategy

1. **Key equation**: If $p$ is the transmitted polynomial and $E$ is the error-locator polynomial (vanishing at corrupted positions), then $r(x) \cdot E(x) = p(x) \cdot E(x)$ at all evaluation points. This yields a *linear* system in the unknowns (coefficients of $p \cdot E$ and $E$).
2. **Uniqueness**: Two solutions $(p_1, E_1)$ and $(p_2, E_2)$ satisfy $p_1 \cdot E_2 = p_2 \cdot E_1$ (polynomial equality from agreement at sufficiently many points). Factor and use degree bounds.
3. **Connect** to `evalOnNodesLinearEquiv` via the noiseless case as a special instance.

### Cross-Domain Impact

- **Communications**: Foundation for verified decoder implementations.
- **Storage systems**: Certified error recovery for distributed databases.
- **Computational complexity**: Connects to algebraic proof systems and PCP constructions.

---

## 4. Sheaf-Theoretic Interpolation

### Theorem Statement

```
-- Define the sheaf of bounded-degree polynomial functions on a finite discrete site
-- Prove: global sections ≃ local compatible evaluations

theorem interpolation_as_sheaf_gluing
    (K : Type*) [Field K] (s : Finset K) (n : ℕ) (hcard : s.card = n + 1)
    (f : ↑s → K) :
    -- The unique global section (polynomial of degree ≤ n) restricting to f
    -- exists and is computed by Lagrange interpolation
    ∃! p : Polynomial.degreeLT K (n + 1),
      ∀ x : ↑s, p.1.eval ↑x = f x
```

### Why Breakthrough

This recasts polynomial interpolation in the language of sheaf theory, connecting it to:
- The Čech-to-derived functor spectral sequence on finite sites,
- The étale cohomology of affine schemes over finite fields,
- The broader program of "local-to-global" reconstruction in algebraic geometry.

The connection is not merely metaphorical: on a finite discrete topological space, the sheaf of degree-bounded polynomial germs has global sections computed by interpolation, and the vanishing of higher cohomology corresponds to the surjectivity of the evaluation map.

### Proof Strategy

1. **Existence**: Follows from `interpAtNodes` — the Lagrange interpolant provides the global section.
2. **Uniqueness**: Follows from `interp_eval_eq_id` — any bounded-degree polynomial agreeing at all nodes equals the interpolant.
3. **Sheaf axioms**: Define the presheaf on subsets of $s$ (restricting polynomial degree accordingly) and verify the gluing axiom using the linear equivalence.

### Cross-Domain Impact

- **Algebraic geometry**: First formalized sheaf-interpolation connection on finite sites.
- **Topological data analysis**: Sheaf models for sensor networks and distributed reconstruction.
- **Category theory**: Concrete example of a sheaf-theoretic phenomenon with computational content.

---

## 5. Tropical–Classical Comparison Theorem

### Theorem Statement

```
-- Classical: canonical two-sided linear inverse exists
-- Tropical: no left inverse exists for max-plus evaluation

theorem classical_vs_tropical_eval_inverse :
    -- Over a classical field:
    (∀ (K : Type*) [Field K] (v : Fin (n+1) → K) (hv : Function.Injective v),
      ∃ inv : (Fin (n+1) → K) →ₗ[K] Polynomial.degreeLT K (n+1),
        Function.LeftInverse inv (evalAtNodes v) ∧ Function.RightInverse inv (evalAtNodes v))
    -- Contrast: over tropical semiring, left inverse fails
    ∧ ¬ (∀ (v : Fin 2 → ℤ) (hv : Function.Injective v),
          ∃ inv, Function.LeftInverse inv (tropicalEval v))
```

### Why Breakthrough

This is a novel cross-algebraic comparison theorem that makes precise the structural difference between classical and tropical polynomial evaluation. It demonstrates that the invertibility of evaluation is not a general-algebraic phenomenon but depends on specific properties of fields (zero divisor freeness, root counting bounds).

### Proof Strategy

1. **Classical direction**: Immediate from `evalOnNodesLinearEquiv`.
2. **Tropical direction**: Exhibit two distinct tropical polynomials (e.g., $\max(x, 0)$ and $\max(x, 0, x + (-\infty))$) that have identical evaluations at all integer points. This shows evaluation is not injective, precluding a left inverse.
3. **Structural analysis**: Identify the precise algebraic axiom (polynomial root bound) that holds classically but fails tropically.

### Cross-Domain Impact

- **Algebraic combinatorics**: Clarifies the boundary between invertible and non-invertible evaluation problems.
- **Optimization**: Tropical algebra underlies linear programming duality; understanding its structural limits informs algorithm design.
- **Mathematical foundations**: A rare example of a formally verified comparison theorem across algebraic structures.

---

## Team Directive

Each direction above is specified with sufficient precision for an independent research team to pursue:

1. **Hypotheses**: Each theorem statement is concrete and falsifiable.
2. **Proof strategies**: Each includes a decomposition into sub-lemmas with identified Mathlib dependencies.
3. **Cross-domain connections**: Each links to at least two application areas outside pure algebra.
4. **File targets**: All should build on `Bridges/PolynomialInterpolationEquiv.lean` as a dependency.

**Priority ordering**: (1) Reed–Solomon distance → (4) Sheaf interpolation → (3) Berlekamp–Welch → (2) Multivariate → (5) Tropical comparison.

Direction (1) is the highest-impact near-term target because it requires the least new infrastructure and has the most immediate applications. Direction (4) is conceptually the deepest and connects to the largest body of existing mathematical theory. Direction (5) is the most novel and would establish a new kind of cross-algebraic formal result.
