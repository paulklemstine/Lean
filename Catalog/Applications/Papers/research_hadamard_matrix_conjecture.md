# A Formally Verified Theory of Hadamard Matrices: Constructions, Obstructions, and Cross-Domain Applications

## Abstract

We present a machine-verified formal development of Hadamard matrix theory in the Lean 4 proof assistant, comprising core definitions, structural theorems, infinite construction families, and cross-domain applications. Our development includes: (1) a robust definition of Hadamard matrices with supporting infrastructure for normalization and equivalence; (2) a proof of the classical divisibility obstruction (order > 2 implies 4 | n); (3) the Sylvester recursive construction establishing Hadamard matrices at all powers of 2; (4) a proof that the Kronecker product preserves the Hadamard property, yielding multiplicative closure of Hadamard orders; (5) the equidistance theorem for Hadamard codes (Hamming distance n/2 between all distinct codewords); (6) the Walsh-Hadamard energy identity; and (7) an excess bound σ(H)² ≤ n³. All proofs are fully verified with no sorry statements and depend only on standard axioms. We accompany the formal development with computational demonstrations and formulate five falsifiable conjectures for future investigation.

**Keywords:** Hadamard matrices, formal verification, Lean 4, Mathlib, orthogonal matrices, coding theory, Walsh-Hadamard transform, combinatorial design, Kronecker product.

---

## 1. Introduction

### 1.1 Background and Motivation

A **Hadamard matrix** of order n is an n × n matrix H with entries in {+1, −1} satisfying HHᵀ = nI, where I is the identity matrix. Equivalently, all pairs of distinct rows are orthogonal, and each row has Euclidean norm √n.

The **Hadamard conjecture** (1893) asserts that Hadamard matrices exist for every order n that is 1, 2, or a multiple of 4. The necessity of the divisibility condition (n > 2 implies 4 | n) was established classically; existence remains open, with the smallest unresolved case being n = 668.

Hadamard matrices arise naturally in:
- **Coding theory**: as generators of equidistant binary codes (Hadamard codes) achieving the Plotkin bound.
- **Signal processing**: as the basis of the Walsh-Hadamard transform, a discrete orthogonal transform computable with only additions and subtractions.
- **Combinatorial design**: as generators of symmetric 2-designs (BIBDs) through the normalization-deletion construction.
- **Compressed sensing**: as deterministic measurement matrices with optimal incoherence properties.

### 1.2 Contributions

Our formal development establishes:

| Theorem | Statement | Proof Technique |
|---------|-----------|----------------|
| Divisibility obstruction | n > 2 ∧ HadamardOrder n → 4 ∣ n | Sign-pattern partition, parity |
| Sylvester family | ∀ k, HadamardOrder (2^k) | Induction + Kronecker |
| Kronecker closure | HadamardOrder m ∧ HadamardOrder n → HadamardOrder (m·n) | Generalized Hadamard on product types |
| Code equidistance | Hamming distance = n/2 for distinct rows | Orthogonality + sign counting |
| Energy identity | ‖Hx‖² = n·‖x‖² for all x ∈ ℤⁿ | Column orthogonality |
| Excess bound | σ(H)² ≤ n³ | Cauchy-Schwarz + energy identity |
| Normalization existence | ∃ normalized equivalent | Explicit sign-flip construction |
| Equivalence invariance | Hadamard property preserved under equivalence | Direct computation |

All proofs are machine-verified in Lean 4 using the Mathlib library, with no sorry axioms, and depend only on propext, Classical.choice, and Quot.sound.

---

## 2. Definitions and Notation

### 2.1 Core Definition

```lean
def IsHadamard {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)
```

This definition works over ℤ to avoid real-number coercion issues while retaining the full algebraic content.

### 2.2 Normalized Hadamard Matrices

```lean
def IsNormalizedHadamard {n : ℕ} [NeZero n] (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamard H ∧ (∀ j, H 0 j = 1) ∧ (∀ i, H i 0 = 1)
```

### 2.3 Hadamard Equivalence

```lean
def HadamardEquivalent {n : ℕ} (H K : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  ∃ (σ τ : Equiv.Perm (Fin n)) (d₁ d₂ : Fin n → ℤ),
    (∀ i, d₁ i = 1 ∨ d₁ i = -1) ∧
    (∀ j, d₂ j = 1 ∨ d₂ j = -1) ∧
    (∀ i j, K i j = d₁ i * H (σ i) (τ j) * d₂ j)
```

### 2.4 Generalized Hadamard (for Kronecker)

```lean
def IsHadamardGen {ι : Type*} [Fintype ι] [DecidableEq ι]
    (H : Matrix ι ι ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (Fintype.card ι : ℤ) • (1 : Matrix ι ι ℤ)
```

### 2.5 Excess

```lean
def hadamardExcess {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : ℤ :=
  ∑ i, ∑ j, H i j
```

---

## 3. Main Results

### 3.1 Divisibility Obstruction

**Theorem 1.** If n > 2 and a Hadamard matrix of order n exists, then 4 ∣ n.

*Proof sketch.* Take any three rows r₁, r₂, r₃. For each column k, the product (1 + r₁(k)r₂(k))(1 + r₁(k)r₃(k)) equals either 0 or 4 (by exhaustive case analysis on ±1 entries). The sum over all columns equals n (using orthogonality ∑r₁r₂ = 0, ∑r₁r₃ = 0, and ∑r₁²r₂r₃ = ∑r₂r₃ = 0). Since each term is divisible by 4 and they sum to n, we conclude 4 ∣ n. □

This proof avoids the traditional normalization step entirely, working directly with any three rows. The key insight is that the product (1 + ab)(1 + ac) filters for the pattern where a agrees with both b and c, and its four-valuedness forces the divisibility.

### 3.2 Sylvester Construction

**Theorem 2.** For every k ∈ ℕ, there exists a Hadamard matrix of order 2^k.

*Proof sketch.* By induction on k, using the Kronecker closure theorem (Theorem 3). The base case k = 0 is the 1×1 matrix [1]. The inductive step uses HadamardOrder(2^k) and HadamardOrder(2) (the matrix [[1,1],[1,−1]]) to obtain HadamardOrder(2^(k+1)) via Kronecker. □

### 3.3 Kronecker Closure

**Theorem 3.** If H₁ is a Hadamard matrix indexed by ι₁ and H₂ is indexed by ι₂, then their Kronecker product (kroneckerMap (· * ·) H₁ H₂) is Hadamard on ι₁ × ι₂.

*Proof sketch.* Entries: the product of two ±1 values is ±1. Orthogonality: expand (H₁ ⊗ H₂)(H₁ ⊗ H₂)ᵀ using the mixed-product property of Kronecker products. The key identity is:

(H₁ ⊗ H₂)(H₁ᵀ ⊗ H₂ᵀ) = (H₁H₁ᵀ) ⊗ (H₂H₂ᵀ) = (n₁·I) ⊗ (n₂·I) = n₁n₂ · (I ⊗ I) = n₁n₂ · I

The formal proof expands this at the level of sums over product types and uses `Fintype.sum_prod_type_right` to factor the double sum. □

A corollary gives multiplicativity of Hadamard orders via reindexing from Fin m × Fin n to Fin (m·n).

### 3.4 Code Equidistance

**Theorem 4.** For a Hadamard matrix H of order n, the Hamming distance between the binary codes of any two distinct rows equals n/2.

*Proof sketch.* Map +1 → false, −1 → true. Two codes disagree at position k iff H(i,k) · H(j,k) = −1. Partition columns into "agree" (product = +1) and "disagree" (product = −1). Since entries are ±1, the sum ∑ H(i,k)H(j,k) = |agree| − |disagree| = 0 (by orthogonality), and |agree| + |disagree| = n. Thus |disagree| = n/2. □

### 3.5 Walsh-Hadamard Energy Identity

**Theorem 5.** For any Hadamard matrix H of order n and any integer vector x ∈ ℤⁿ:

∑ᵢ (∑ₖ Hᵢₖ xₖ)² = n · ∑ₖ xₖ²

*Proof sketch.* Expand the left side as a double sum and swap summation order to obtain ∑ₖ ∑ₗ xₖ xₗ (∑ᵢ Hᵢₖ Hᵢₗ). The inner sum is the (k,l)-entry of HᵀH. To establish column orthogonality (HᵀH = nI), we cast to ℚ, use invertibility of H (from HHᵀ = nI), and derive HᵀH = nI. The result follows: only diagonal terms (k = l) survive, giving n · ∑ₖ xₖ². □

### 3.6 Excess Bound

**Theorem 6.** For any Hadamard matrix H of order n, σ(H)² ≤ n³.

*Proof sketch.* Let sᵢ = ∑ⱼ Hᵢⱼ be the i-th row sum. Then σ(H) = ∑ᵢ sᵢ. By Cauchy-Schwarz: (∑ᵢ sᵢ)² ≤ n · ∑ᵢ sᵢ². The energy identity with x = (1,...,1) gives ∑ᵢ sᵢ² = n². Hence σ(H)² ≤ n · n² = n³. □

### 3.7 Normalization and Equivalence

**Theorem 7.** Every Hadamard matrix of positive order is equivalent (under sign flips) to a normalized Hadamard matrix.

*Proof.* Define H'(i,j) = H(0,0) · H(i,0) · H(0,j) · H(i,j). Then:
- H'(0,j) = H(0,0)² · H(0,j)² = 1 (first row all +1)
- H'(i,0) = H(0,0)² · H(i,0)² = 1 (first column all +1)
- Entries are products of four ±1 values, hence ±1
- Orthogonality is preserved because sign factors cancel in the inner products. □

**Theorem 8.** Hadamard equivalence preserves the Hadamard property.

---

## 4. Algorithms

### 4.1 Sylvester Matrix Construction

**Input:** k ∈ ℕ  
**Output:** 2^k × 2^k Hadamard matrix

```
function Sylvester(k):
    H ← [[1]]
    for i = 1 to k:
        H ← [[H, H], [H, -H]]
    return H
```

**Complexity:** O(4^k) time and space. Each iteration quadruples the matrix size.

**Correctness:** Certified by `hadamardOrder_pow_two` in Lean.

### 4.2 Normalization Procedure

**Input:** Hadamard matrix H of order n  
**Output:** Normalized Hadamard matrix H'

```
function Normalize(H):
    for j = 0 to n-1:
        H[*, j] ← H[*, j] * H[0, j]    // Fix first row
    for i = 0 to n-1:
        H[i, *] ← H[i, *] * H[i, 0]    // Fix first column
    return H
```

**Complexity:** O(n²) time, O(1) additional space (in-place).

**Correctness:** Certified by `exists_normalized_of_isHadamard` in Lean.

### 4.3 Hadamard Code Generator

**Input:** Hadamard matrix H of order n  
**Output:** n binary codewords of length n

```
function HadamardCode(H):
    C ← empty n × n binary matrix
    for i = 0 to n-1:
        for j = 0 to n-1:
            C[i,j] ← (1 - H[i,j]) / 2    // +1→0, -1→1
    return C
```

**Properties (certified):**
- n codewords of length n
- All pairwise Hamming distances equal n/2
- Minimum distance n/2 (meets Plotkin bound)

---

## 5. Applications

### 5.1 Error-Correcting Codes

A Hadamard code of order n = 2^k:
- Has 2^k codewords of length 2^k
- Minimum distance 2^(k-1)
- Can correct up to 2^(k-2) − 1 errors
- Code rate: k/2^k (exponentially small, traded for robustness)

The equidistance property (Theorem 4) means these codes are optimal for channels with high noise: they maximize the guaranteed separation between any pair of transmitted messages.

### 5.2 Walsh-Hadamard Transform

The energy identity (Theorem 5) guarantees lossless signal transformation. For a signal x of length 2^k:
- Forward transform: y = H_k · x (O(n log n) via fast algorithm)
- Inverse transform: x = (1/n) · H_k · y
- Energy preservation: ‖y‖² = n · ‖x‖²

Applications include: image compression, spectral analysis, Boolean function analysis, and quantum computing (the Hadamard gate is the 2×2 case).

### 5.3 Combinatorial Designs

A normalized Hadamard matrix of order 4t yields a symmetric 2-(4t−1, 2t−1, t−1) design by deleting the first row and column and mapping +1 → "in block", −1 → "not in block". This design has:
- v = 4t − 1 points and b = 4t − 1 blocks
- Each block contains k = 2t − 1 points
- Each pair of points appears in λ = t − 1 blocks

These are optimal for balanced experimental design.

---

## 6. Computational Experiments

### 6.1 Sylvester Family Verification

| k | Order n = 2^k | Excess σ | σ²/n³ | Verified |
|---|---------------|----------|-------|----------|
| 1 | 2 | 2 | 0.5000 | ✓ |
| 2 | 4 | 4 | 0.2500 | ✓ |
| 3 | 8 | 8 | 0.1250 | ✓ |
| 4 | 16 | 16 | 0.0625 | ✓ |
| 5 | 32 | 32 | 0.0312 | ✓ |
| 6 | 64 | 64 | 0.0156 | ✓ |
| 7 | 128 | 128 | 0.0078 | ✓ |

The Sylvester excess follows σ = n, giving σ²/n³ = 1/n → 0.

### 6.2 Paley Construction

| q (prime) | Order q+1 | Construction | Verified |
|-----------|-----------|--------------|----------|
| 3 | 4 | Paley I | ✓ |
| 7 | 8 | Paley I | ✓ |
| 11 | 12 | Paley I | ✓ |
| 19 | 20 | Paley I | ✓ |
| 23 | 24 | Paley I | ✓ |
| 31 | 32 | Paley I | ✓ |
| 43 | 44 | Paley I | ✓ |

### 6.3 Code Equidistance Verification

| Order | Codewords | Distance | Equidistant |
|-------|-----------|----------|-------------|
| 4 | 4 | 2 | ✓ |
| 8 | 8 | 4 | ✓ |
| 16 | 16 | 8 | ✓ |
| 32 | 32 | 16 | ✓ |

---

## 7. Discussion

### 7.1 Formal Verification Methodology

The development uses Lean 4 with the Mathlib library. Key design decisions:

1. **ℤ vs ℝ:** Working over ℤ avoids coercion overhead and aligns naturally with the ±1 entry constraint. The column orthogonality proof required a brief excursion to ℚ for invertibility arguments.

2. **Fin n vs general Fintype:** The Kronecker closure theorem required a generalized IsHadamardGen predicate on arbitrary Fintype indices, since kroneckerMap produces matrices indexed by product types. A reindexing lemma bridges back to Fin n.

3. **Normalization:** The explicit formula H'(i,j) = H(0,0)·H(i,0)·H(0,j)·H(i,j) avoids iterative sign-flipping and gives a direct existential witness.

### 7.2 Limitations

- The Paley construction is implemented computationally in Python but not yet formally verified in Lean (this requires substantial finite field infrastructure).
- The BIBD connection is described but not formalized due to the lack of design-theory infrastructure in Mathlib.
- The Hadamard conjecture itself remains unresolved.

### 7.3 Comparison with Prior Work

To our knowledge, this is the first comprehensive formal verification of Hadamard matrix theory including the divisibility obstruction, Sylvester construction, Kronecker closure, code distance theorem, and energy identity in a single unified development.

---

## 8. Future Work

1. **Paley construction formalization:** Verify the Paley Type I construction for primes q ≡ 3 (mod 4) using Mathlib's finite field and Legendre symbol infrastructure.

2. **BIBD formalization:** Build a formal design theory library and prove the Hadamard-to-BIBD correspondence.

3. **Equivalence classification:** Formally verify the classification of Hadamard equivalence classes at small orders.

4. **Fast Walsh-Hadamard transform:** Verify the O(n log n) butterfly algorithm for the Walsh-Hadamard transform.

5. **Approach the conjecture:** Formalize additional construction families (Williamson, Turyn) to expand the set of certified Hadamard orders.

See `FUTURE_DIRECTIONS.md` for five specific falsifiable conjectures.

---

## 9. File Organization

| File | Contents |
|------|----------|
| `Algebra/Hadamard/Defs.lean` | Core definitions: IsHadamard, NormalizedHadamard, HadamardEquivalent, excess, bundled structure, basic lemmas |
| `Algebra/Hadamard/Kronecker.lean` | Generalized Hadamard, Kronecker closure, reindexing, multiplicativity |
| `Algebra/Hadamard/Sylvester.lean` | 2×2 seed, Sylvester family for all 2^k |
| `Algebra/Hadamard/Obstruction.lean` | Divisibility obstruction: n > 2 → 4 ∣ n |
| `Algebra/Hadamard/Code.lean` | Hadamard codes, equidistance, column orthogonality, energy identity, excess bound |
| `Algebra/Hadamard/Normalization.lean` | Sign-flipping, normalization existence, equivalence invariance |
| `demo.py` | Interactive demonstration of all constructions |
| `algorithms.py` | Core algorithms with docstrings and type hints |
| `applications.py` | Cross-domain application demonstrations |

---

## References

1. Hadamard, J. (1893). Résolution d'une question relative aux déterminants. *Bull. Sci. Math.* 17, 240–246.

2. Sylvester, J.J. (1867). Thoughts on inverse orthogonal matrices. *Phil. Mag.* 34, 461–475.

3. Paley, R.E.A.C. (1933). On orthogonal matrices. *J. Math. Phys.* 12, 311–320.

4. Horadam, K.J. (2007). *Hadamard Matrices and Their Applications*. Princeton University Press.

5. Hedayat, A. and Wallis, W.D. (1978). Hadamard matrices and their applications. *Ann. Statist.* 6, 1184–1238.

6. de Launey, W. and Levin, M.D. (2010). A Fourier-analytic approach to counting partial Hadamard matrices. *Cryptogr. Commun.* 2, 307–334.

7. The Mathlib Community (2024). Mathlib4: The mathematics library for Lean 4. https://github.com/leanprover-community/mathlib4
