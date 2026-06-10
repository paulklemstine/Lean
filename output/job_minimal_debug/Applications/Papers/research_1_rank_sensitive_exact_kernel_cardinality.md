# Rank-Sensitive Exact Kernel Cardinality over Finite Prime Fields

## Abstract

We formalize a suite of exact cardinality theorems for kernels and affine solution sets of linear maps over finite prime fields ZMod q. The central result states that for any matrix M ∈ GF(q)^{m×p}, the number of vectors r ∈ GF(q)^p satisfying Mr = 0 is exactly q^{p − rank(M)}. We further prove the affine extension: |{r : Mr = b}| = q^{p − rank(M)} when b is in the column space, and 0 otherwise. The proofs are machine-verified in Lean 4 using Mathlib, producing reusable infrastructure for finite-field linear algebra. We discuss applications to randomized verification (Freivalds' algorithm), error-correcting codes, privacy analysis, and complexity theory.

**Keywords:** kernel cardinality, rank-nullity, finite fields, Freivalds algorithm, linear codes, formal verification.

---

## 1. Introduction

### 1.1 Motivation

The cardinality of the kernel of a linear map over a finite field is a fundamental invariant with applications across mathematics and computer science. While the result |ker(M)| = q^{p − rank(M)} is well-known in the finite algebra community, its formal machine-verified treatment creates a reusable interface connecting:

- **Randomized algorithms**: exact false acceptance probabilities for Freivalds-type matrix verification.
- **Coding theory**: dimension-cardinality laws for nullspace codes.
- **Privacy**: quantification of information leakage through linear queries.
- **Complexity theory**: witness counting for linear constraint systems.

### 1.2 Contributions

1. **Exact kernel cardinality** (`card_mulVec_kernel_exact`): For M ∈ GF(q)^{m×p},
   |{r ∈ GF(q)^p : Mr = 0}| = q^{p − rank(M)}.

2. **Affine solution counting** (`card_mulVec_affine_exact`): For any b,
   |{r : Mr = b}| = q^{p − rank(M)} if b ∈ Im(M), and 0 otherwise.

3. **General linear map kernel cardinality** (`card_linearMap_ker_zmod`): For any linear map φ : V →_q W with V finite-dimensional, |ker(φ)| = q^{finrank(ker φ)}.

4. **Reusable infrastructure**: modular lemmas for finrank of function spaces, rank-nullity over ZMod q, and subtype-to-kernel transport.

### 1.3 Related Work

The rank-nullity theorem appears in every linear algebra textbook. The finite-field counting law |V| = q^{dim V} is equally classical. The novelty of this work is:

- Formal machine verification of the composed result, producing a certified interface.
- The affine extension, which handles inhomogeneous systems.
- Explicit connection to algorithmic applications via the Freivalds framework.

In the Mathlib library for Lean 4, the building blocks exist:
- `Module.card_eq_pow_finrank` provides |V| = |K|^{dim V} for finite-dimensional vector spaces over division rings.
- `LinearMap.finrank_range_add_finrank_ker` provides rank-nullity.
- `ZMod.card` provides |ZMod q| = q.

Our contribution is the composition and transport layer that connects these to the concrete matrix setting.

---

## 2. Definitions and Notation

### 2.1 Setting

Let q be a prime number. We work over the field GF(q), represented as ZMod q in Lean 4. For the type theory, ZMod q carries instances of `Field`, `Fintype`, and `DecidableEq` when q is prime.

Fix natural numbers m (rows) and p (columns). A matrix M ∈ GF(q)^{m×p} is a term of type `Matrix (Fin m) (Fin p) (ZMod q)`.

### 2.2 Key Definitions

- **mulVecLin**: The linear map φ_M : GF(q)^p → GF(q)^m defined by φ_M(r) = Mr. In Lean: `Matrix.mulVecLin M`.

- **Kernel**: ker(φ_M) = {r ∈ GF(q)^p : Mr = 0}. In Lean: `LinearMap.ker (Matrix.mulVecLin M)`.

- **Rank**: rank(M) = finrank(Im(φ_M)). In Lean: `Module.finrank (ZMod q) (LinearMap.range (Matrix.mulVecLin M))`.

- **Nullity**: nullity(M) = finrank(ker(φ_M)) = p − rank(M).

### 2.3 Notation

| Symbol | Meaning |
|--------|---------|
| q | Prime field characteristic |
| p | Number of columns (ambient dimension) |
| m | Number of rows |
| M | Matrix in GF(q)^{m×p} |
| φ_M | Linear map r ↦ Mr |
| rank(M) | finrank of the image of φ_M |

---

## 3. Main Results

### 3.1 Rank-Nullity for mulVecLin

**Theorem 1** (finrank_ker_add_finrank_range_mulVecLin).
For M ∈ GF(q)^{m×p}:

$$\text{finrank}(\ker \varphi_M) + \text{finrank}(\text{Im} \, \varphi_M) = p$$

*Proof sketch.* Apply Mathlib's `LinearMap.finrank_range_add_finrank_ker` to φ_M, then rewrite `finrank(GF(q)^p) = p` using `Module.finrank_pi` and `Fintype.card_fin`. □

**Corollary** (finrank_ker_mulVecLin).

$$\text{finrank}(\ker \varphi_M) = p - \text{rank}(M)$$

This follows from Theorem 1 by natural number arithmetic (omega).

### 3.2 Kernel Cardinality

**Theorem 2** (card_mulVecLin_ker_exact).

$$|\ker \varphi_M| = q^{\text{finrank}(\ker \varphi_M)}$$

*Proof.* The kernel is a submodule of the finite-dimensional space GF(q)^p, hence itself finite-dimensional. Apply `Module.card_eq_pow_finrank` (which states |V| = |K|^{dim V} for any finite-dimensional vector space V over a finite division ring K) and `ZMod.card q` (which gives |ZMod q| = q). □

### 3.3 Main Theorem: Exact Kernel Cardinality

**Theorem 3** (card_mulVec_kernel_exact).

$$|\{r \in \text{GF}(q)^p : Mr = 0\}| = q^{p - \text{rank}(M)}$$

*Proof.*
1. Transport the subtype {r // Mr = 0} to ker(φ_M) via `Equiv.subtypeEquivProp`, using the fact that `Mr = 0 ↔ r ∈ ker(φ_M)` (which holds by `LinearMap.mem_ker`).
2. Apply Theorem 2 to get |ker(φ_M)| = q^{finrank(ker φ_M)}.
3. Apply the Corollary to get finrank(ker φ_M) = p − rank(M).
4. Combine. □

### 3.4 Affine Extension

**Theorem 4** (card_mulVec_affine_exact).

$$|\{r \in \text{GF}(q)^p : Mr = b\}| = \begin{cases} q^{p - \text{rank}(M)} & \text{if } b \in \text{Im}(\varphi_M) \\ 0 & \text{otherwise} \end{cases}$$

*Proof sketch.*
- If b ∉ Im(φ_M), the solution set is empty.
- If b = φ_M(r₀) for some r₀, then the map r ↦ r − r₀ is a bijection from {r : Mr = b} to ker(φ_M). Specifically:
  - Forward: if Mr = b, then M(r − r₀) = Mr − Mr₀ = b − b = 0.
  - Backward: if v ∈ ker(φ_M), then M(v + r₀) = 0 + Mr₀ = b.
- Apply `Fintype.card_congr` with this equivalence, then use Theorems 2 and 3. □

### 3.5 General Linear Map Version

**Theorem 5** (card_linearMap_ker_zmod).
For any linear map φ : V →_{GF(q)} W with V finite-dimensional and finite:

$$|\ker \varphi| = q^{\text{finrank}(\ker \varphi)}$$

This generalization applies to any finite-dimensional vector space over GF(q), not just function spaces.

---

## 4. Algorithms

### 4.1 Kernel Cardinality Computation

**Input:** Matrix M ∈ GF(q)^{m×p}, prime q.
**Output:** |ker(M)|.

```
function KernelCardinality(M, q):
    r ← GaussianEliminationRank(M, q)
    return q^(p - r)
```

**Time:** O(m · p · min(m, p)) for Gaussian elimination.
**Space:** O(m · p).

This avoids enumerating all q^p vectors (which takes O(q^p) time).

### 4.2 Kernel Basis Computation

**Input:** Matrix M ∈ GF(q)^{m×p}, prime q.
**Output:** Basis {v₁, ..., v_{p−r}} of ker(M).

```
function KernelBasis(M, q):
    (R, pivots) ← ReducedRowEchelonForm(M, q)
    free ← {0, ..., p-1} \ pivots
    basis ← []
    for j in free:
        v ← zero vector of length p
        v[j] ← 1
        for i, c in enumerate(pivots):
            v[c] ← -R[i][j] mod q
        append v to basis
    return basis
```

**Time:** O(m · p · min(m, p) + p · (p − r)).
**Space:** O(p · (p − r)).

### 4.3 Affine Solution Counting

**Input:** Matrix M ∈ GF(q)^{m×p}, vector b ∈ GF(q)^m, prime q.
**Output:** |{r : Mr = b}|.

```
function AffineSolutionCount(M, b, q):
    r_M ← GaussianEliminationRank(M, q)
    r_aug ← GaussianEliminationRank([M | b], q)
    if r_aug > r_M:
        return 0
    else:
        return q^(p - r_M)
```

**Time:** O(m · (p+1) · min(m, p+1)).

---

## 5. Applications

### 5.1 Freivalds' Algorithm: Rank-Sensitive Analysis

**Classical bound:** For matrices A ∈ GF(q)^{m×n}, B ∈ GF(q)^{n×p}, C ∈ GF(q)^{m×p} with AB ≠ C:

$$\Pr_r[ABr = Cr] \leq 1/q$$

**Rank-sensitive bound (our theorem):** Let E = AB − C.

$$\Pr_r[Er = 0] = q^{-\text{rank}(E)}$$

**Implications:**
- For rank(E) = 1: probability is exactly 1/q (matching the classical bound).
- For rank(E) = k > 1: probability is q^{−k}, exponentially smaller.
- A single random check with q = 2 and rank(E) = 64 gives a 2^{−64} false acceptance probability, equivalent to 64 independent classical checks.

**Experimental verification (q = 5, p = 3):**

| rank(E) | |ker(E)| | Pr[Er=0] | q^{−rank(E)} | Match |
|---------|---------|----------|--------------|-------|
| 0 | 125 | 1.000000 | 1.000000 | ✓ |
| 1 | 25 | 0.200000 | 0.200000 | ✓ |
| 2 | 5 | 0.040000 | 0.040000 | ✓ |

### 5.2 Error-Correcting Codes

A linear code C over GF(q) with parity-check matrix H ∈ GF(q)^{r×n} satisfies:

- C = ker(H)
- dim(C) = n − rank(H)
- |C| = q^{n − rank(H)}

**Example: Hamming [7,4,3] code over GF(2).**

H has rank 3, so |C| = 2^{7−3} = 16 codewords. The code corrects all single-bit errors (minimum distance d = 3).

### 5.3 Privacy Analysis

A database holds x ∈ GF(q)^p. An analyst submits k independent linear queries (matrix M of rank k). The analyst learns Mx.

- Remaining uncertainty about x: q^{p−k} possible values.
- Information leaked: k · log₂(q) bits (exact).
- Redundant queries (rank deficient) leak strictly less.

| Queries | Rank | Remaining secrets | Leaked (bits, q=7) |
|---------|------|-------------------|-------------------|
| 1 | 1 | 7⁴ = 2401 | 2.81 |
| 2 | 2 | 7³ = 343 | 5.61 |
| 3 | 3 | 7² = 49 | 8.42 |
| 5 | 5 | 7⁰ = 1 | 14.04 |

### 5.4 Verification Confidence Engineering

For cryptographic-strength verification (2^{−128} false acceptance), the number of Freivalds trials needed depends on rank:

| rank(E) | Trials (standard) | Trials (rank-aware) | Speedup |
|---------|-------------------|---------------------|---------|
| 1 | 128 | 128 | 1× |
| 4 | 128 | 32 | 4× |
| 16 | 128 | 8 | 16× |
| 64 | 128 | 2 | 64× |

---

## 6. Formal Proof Architecture

### 6.1 Lean 4 Proof Structure

The formalization consists of six main declarations:

1. `subtypeMulVecZeroEquivKer`: Equivalence {r // Mr = 0} ≃ ker(φ_M).
2. `finrank_fin_fun_zmod`: finrank(GF(q)^p) = p.
3. `finrank_ker_add_finrank_range_mulVecLin`: Rank-nullity identity.
4. `finrank_ker_mulVecLin`: Rank-nullity subtraction form.
5. `card_mulVecLin_ker_exact`: |ker(φ_M)| = q^{finrank(ker φ_M)}.
6. `card_mulVec_kernel_exact`: |{r : Mr = 0}| = q^{p − rank(M)}.
7. `card_mulVec_affine_exact`: Affine version with case split on b ∈ Im(M).
8. `card_linearMap_ker_zmod`: General version for arbitrary linear maps.

### 6.2 Key Mathlib Dependencies

| Mathlib lemma | Role |
|---------------|------|
| `Module.card_eq_pow_finrank` | |V| = |K|^{dim V} |
| `LinearMap.finrank_range_add_finrank_ker` | Rank-nullity |
| `Module.finrank_pi` | finrank(ι → R) = |ι| |
| `ZMod.card` | |ZMod n| = n |
| `LinearMap.mem_ker` | r ∈ ker(φ) ↔ φ(r) = 0 |
| `Equiv.subtypeEquivProp` | Transport between equivalent subtypes |
| `Fintype.card_congr` | Cardinality preserved by equivalence |

### 6.3 Axiom Usage

All theorems depend only on the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`. No additional axioms, `sorry`, or `@[implemented_by]` attributes are used.

---

## 7. Discussion

### 7.1 Significance

The formalization demonstrates that the composition of three elementary results — the finite-field counting law, rank-nullity, and subtype transport — produces a theorem with wide applicability. The key insight is that the "transportation layer" between the concrete subtype {r // Mr = 0} and the abstract submodule ker(φ_M) is where formalization adds genuine value: it certifies that the mathematical identification is type-safe and exhaustive.

### 7.2 Limitations

1. The current formalization handles prime fields ZMod q only, not general finite fields GF(q^n).
2. The probabilistic interpretation (Freivalds false acceptance) is stated as a cardinality ratio, not as a measure-theoretic probability.
3. The minimum distance of the nullspace code is not computed; only the dimension/cardinality is established.

### 7.3 Comparison with Classical Treatments

The standard Freivalds analysis (see Motwani & Raghavan, Randomized Algorithms, Chapter 7) derives only the bound Pr[Er = 0] ≤ 1/q. Our result replaces this with an equality, which is strictly stronger whenever rank(E) > 1. This improvement is well-known in the finite algebra community but has not, to our knowledge, been formally verified before.

---

## 8. Future Work

1. **Extension to GF(q^n)**: Replace ZMod q with a generic `FiniteField` and generalize all results.
2. **Freivalds for matrix products**: Compose the theorem with matrix multiplication to derive exact soundness for the AB = C test.
3. **Weight enumerators**: Build MacWilliams duality on top of the kernel cardinality theorem.
4. **Entropy formalization**: Define discrete entropy and prove the exact entropy chain rule for linear maps.
5. **Schwartz-Zippel bridge**: Show that kernel cardinality is the degree-1 case of the Schwartz-Zippel lemma over finite fields.

---

## 9. References

1. Freivalds, R. "Fast probabilistic algorithms." *MFCS 1977*, LNCS 118, pp. 57–69.
2. Motwani, R. and Raghavan, P. *Randomized Algorithms*. Cambridge University Press, 1995.
3. Mathlib Contributors. *Mathlib4*. https://github.com/leanprover-community/mathlib4.
4. MacWilliams, F. J. and Sloane, N. J. A. *The Theory of Error-Correcting Codes*. North-Holland, 1977.
5. Schwartz, J. T. "Fast probabilistic algorithms for verification of polynomial identities." *JACM*, 27(4):701–717, 1980.
6. Zippel, R. "Probabilistic algorithms for sparse polynomials." *EUROSAM 1979*, LNCS 72, pp. 216–226.

---

## Appendix A: Complete Lean 4 Formalization

The complete formalization is in `Catalog/Algebra/KernelCardinality/KernelCardinality.lean`. It builds successfully against Mathlib v4.28.0 with no `sorry` statements and uses only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
