# Future Directions: Algebraic Proof Systems for Linear Computation

This document outlines concrete next theorems and research directions opened by the commitment-based matrix verification protocol formalized in this project. Each direction includes a precise statement, motivation, proof strategy, and dependency on the current development.

---

## 1. Freivalds-Style Probabilistic Soundness over Finite Fields

### Statement

For a finite field `𝔽` with `|𝔽| = q`, and matrices `A : Matrix (Fin m) (Fin n) 𝔽`, `B : Matrix (Fin n) (Fin p) 𝔽`, `K : Matrix (Fin m) (Fin p) 𝔽`:

```
theorem freivalds_soundness
    {q m n p : ℕ} [Field (ZMod q)] [Fintype (ZMod q)]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B)
    (r : Fin p → ZMod q) :
    -- The probability over uniformly random r that K * r = (A * B) * r
    -- is at most 1/q.
```

### Why It Matters

Freivalds' algorithm verifies matrix multiplication in O(n²) time with one-sided error 1/q per round. Formalizing its soundness creates the first probabilistic verification theorem in this framework, moving from deterministic full-row checking to efficient randomized testing.

### Proof Strategy

1. Define the "error matrix" `E = K - A * B`.
2. Show `E ≠ 0` implies there exists a nonzero row in `E`.
3. For a random vector `r`, `E * r = 0` requires the random vector to lie in a specific hyperplane.
4. Use the Schwartz-Zippel lemma (or a direct counting argument for degree-1 polynomials) to bound the probability.

### Dependency

Builds directly on `matrix_mul_eq_iff_rowwise` and `oneHotRow_mul_extracts_row`. The deterministic row-check theorem is the `q → ∞` limit of Freivalds' bound.

---

## 2. Approximate Row-Check Soundness with Error Propagation

### Statement

```
theorem approximate_row_check_soundness
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (K : Matrix (Fin m) (Fin p) ℝ)
    (ε : ℝ) (hε : 0 < ε)
    (hchecks : ∀ i : Fin m, ∀ k : Fin p,
      |K i k - ∑ j, A i j * B j k| ≤ ε) :
    ∀ i k, |K i k - (A * B) i k| ≤ ε
```

And the stronger norm-based version:

```
theorem approximate_row_check_norm_bound
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (K : Matrix (Fin m) (Fin p) ℝ)
    (εrow : Fin m → ℝ)
    (hchecks : ∀ i k, |K i k - ∑ j, A i j * B j k| ≤ εrow i) :
    ∀ i k, |K i k - (A * B) i k| ≤ εrow i
```

### Why It Matters

Real-world computations (floating-point neural network inference, approximate matrix multiplication) produce approximate results. This theorem shows that row-local error bounds propagate cleanly to global error bounds, enabling verification of approximate computations.

### Proof Strategy

1. Unfold `Matrix.mul_apply` to reduce `(A * B) i k` to the summation form.
2. The approximate version is essentially the same as the exact version, but with absolute value bounds.
3. For the norm version, use triangle inequality and row-norm bounds.

### Dependency

Direct extension of `binding_and_all_row_checks_imply_global_correctness`. The exact theorem is the ε = 0 case.

---

## 3. Tropical Dominant-Row Verification

### Statement

```
def dominantEntry {n : ℕ} (v : Fin n → ℝ) : Fin n :=
  Finset.univ.argmax v  -- index of maximum entry

theorem tropical_dominant_verification
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (K : Matrix (Fin m) (Fin p) ℝ)
    (sep : ℝ) (hsep : 0 < sep)
    -- Each row of K has a dominant entry separated by at least sep
    (hdom : ∀ i, ∃ j_max : Fin p,
      ∀ j ≠ j_max, K i j_max - K i j ≥ sep)
    -- Row checks are approximately correct within sep/2
    (hcheck : ∀ i k, |K i k - (A * B) i k| < sep / 2) :
    -- The argmax structure is preserved
    ∀ i, dominantEntry (fun k => K i k) = dominantEntry (fun k => (A * B) i k)
```

### Why It Matters

In attention mechanisms and classification networks, often only the argmax (dominant coordinate) of an output row matters, not its exact values. This theorem shows that approximate verification suffices to certify the argmax structure when there is sufficient separation. This is the bridge to tropical verification: in the tropical semiring, only the maximum matters.

### Proof Strategy

1. Show that if K i j_max is dominant by `sep` and the perturbation is at most `sep/2`, then (A*B) i j_max is still dominant.
2. Use triangle inequality: `(A*B) i j_max ≥ K i j_max - sep/2 > K i j + sep/2 ≥ (A*B) i j` for `j ≠ j_max`.
3. Conclude argmax preservation.

### Dependency

Combines `matrix_mul_eq_iff_rowwise` with dominant-coordinate analysis. Connects to the tropical verification theme.

---

## 4. Sheaf-Theoretic Gluing for Block Matrices

### Statement

```
-- A block decomposition of a matrix with overlap consistency
theorem block_gluing_reconstruction
    {m p : ℕ}
    (blocks : Fin 2 → Set (Fin m))
    (hcover : blocks 0 ∪ blocks 1 = Set.univ)
    (K L : Matrix (Fin m) (Fin p) ℝ)
    -- Agreement on each block
    (h0 : ∀ i ∈ blocks 0, ∀ k, K i k = L i k)
    (h1 : ∀ i ∈ blocks 1, ∀ k, K i k = L i k) :
    K = L
```

And the more general version with an arbitrary finite cover:

```
theorem general_cover_reconstruction
    {m p b : ℕ}
    (blocks : Fin b → Set (Fin m))
    (hcover : ⋃ i, blocks i = Set.univ)
    (K L : Matrix (Fin m) (Fin p) ℝ)
    (h : ∀ t : Fin b, ∀ i ∈ blocks t, ∀ k, K i k = L i k) :
    K = L
```

### Why It Matters

This formalizes the Čech-style reconstruction principle for matrices: a matrix is determined by its restrictions to a covering family of row sets. This is the algebraic analogue of the sheaf gluing axiom, and enables verification protocols where different provers (or verification rounds) certify different blocks of the matrix.

### Proof Strategy

1. Use `Matrix.ext` to reduce to pointwise equality.
2. For each index `i`, use `hcover` to find a block `t` containing `i`.
3. Apply the local agreement hypothesis for that block.

### Dependency

Extends `committed_matrix_determined_by_all_opened_rows` from individual rows to arbitrary row covers.

---

## 5. Verifiable Neural Layer Execution

### Statement

```
-- An affine layer computes x ↦ W * x + b
def affineLayer {m n : ℕ}
    (W : Matrix (Fin m) (Fin n) ℝ)
    (b : Fin m → ℝ)
    (x : Fin n → ℝ) : Fin m → ℝ :=
  fun i => (∑ j, W i j * x j) + b i

-- Verification protocol for affine layers
theorem affine_layer_row_verification
    {m n : ℕ}
    (W : Matrix (Fin m) (Fin n) ℝ)
    (b : Fin m → ℝ)
    (x : Fin n → ℝ)
    (y : Fin m → ℝ)
    (hchecks : ∀ i : Fin m,
      y i = (∑ j, W i j * x j) + b i) :
    y = affineLayer W b x
```

### Why It Matters

Dense linear layers and attention layers in neural networks are matrix multiplications followed by bias addition. This theorem instantiates the row-check protocol for the specific case of neural network layers, creating the first building block for verifiable AI inference.

### Proof Strategy

1. Use `funext` to reduce to pointwise equality.
2. Apply the hypothesis `hchecks` for each index.
3. The definition of `affineLayer` matches the hypothesis exactly.

### Dependency

Builds on `matrix_mul_eq_iff_rowwise` and `binding_and_all_row_checks_imply_global_correctness`. The matrix multiplication is the core of the affine layer computation.

---

## 6. Sum-Check Protocol for Matrix Inner Products

### Statement

```
-- The sum-check protocol reduces verifying ∑_j A[i,j]*B[j,k] to
-- evaluations of a univariate polynomial
theorem sumcheck_matrix_entry
    {n : ℕ} {F : Type} [Field F] [Fintype F]
    (a b : Fin n → F) :
    -- The inner product ∑ j, a j * b j can be verified via
    -- a degree-2 univariate polynomial evaluation protocol
    -- with soundness error at most 2/|F| per round
    ∑ j, a j * b j = ∑ j, a j * b j  -- placeholder for the full protocol
```

### Why It Matters

The sum-check protocol is the backbone of modern interactive proof systems (GKR protocol, Spartan, etc.). Formalizing it for matrix entries connects our row-check framework to the broader theory of algebraic interactive proofs.

### Proof Strategy

1. Formalize the sum-check protocol for degree-d univariate polynomials.
2. Specialize to degree-2 (product of two linear functions).
3. Prove soundness via Schwartz-Zippel over the finite field.

### Dependency

Extends `matrix_mul_eq_iff_rowwise` by providing an efficient interactive protocol for verifying individual row-column dot products.

---

## Cross-Domain Connection Map

```
                    ┌─────────────────────┐
                    │  Sheaf Gluing (4)    │
                    │  Block Matrix Recon  │
                    └────────┬────────────┘
                             │ generalizes
                    ┌────────┴────────────┐
                    │ Row-Local = Global   │
                    │ (Current Work)       │
                    └───┬───────┬─────────┘
                        │       │
           ┌────────────┘       └──────────────┐
           │                                    │
  ┌────────┴─────────┐              ┌──────────┴──────────┐
  │ Freivalds (1)    │              │ Approx Checks (2)   │
  │ Probabilistic    │              │ Error Propagation    │
  └────────┬─────────┘              └──────────┬──────────┘
           │                                    │
           │                         ┌──────────┴──────────┐
           │                         │ Tropical Dom (3)    │
           │                         │ Argmax Verification │
           │                         └─────────────────────┘
           │
  ┌────────┴─────────┐
  │ Sum-Check (6)    │
  │ GKR Protocol     │
  └──────────────────┘

  ┌──────────────────┐
  │ Neural Layers(5) │
  │ Verifiable ML    │
  └──────────────────┘
```

---

## Research Team Directive

Each direction above can be pursued independently by a sub-team:

- **Team 1 (Probabilistic)**: Freivalds + Sum-Check. Requires finite field infrastructure in Mathlib.
- **Team 2 (Robustness)**: Approximate checks + Tropical. Requires norm theory and order theory.
- **Team 3 (Structure)**: Sheaf gluing + Block matrices. Pure linear algebra and set theory.
- **Team 4 (Applications)**: Neural layer verification. Requires connecting to concrete ML architectures.

**Hypothesis pipeline**: Each team should (1) state precise conjectures, (2) test with `#eval` on small instances, (3) prove key lemmas, (4) assemble the full theorem, (5) document cross-connections.

The current formalization provides the algebraic core that all teams build on. The key insight — that global matrix identities decompose into row-local checks verifiable via one-hot linear functionals — is the seed from which all these directions grow.
