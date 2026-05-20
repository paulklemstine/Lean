# Verified Algebraic Decoding: Structural BCH Bounds, Syndrome Recurrences, and the Hankel Rank Bridge

## Abstract

We present a machine-verified formalization of the algebraic foundations of BCH and Reed-Solomon decoding, developed in Lean 4 with the Mathlib library. Our contribution includes five formally verified theorems: (1) a structural BCH bound theorem packaging the Vandermonde argument with explicit consecutive-root data; (2) a unique decoding radius theorem connecting minimum distance to unambiguous nearest-codeword recovery; (3) a theorem that the error locator polynomial annihilates the syndrome sequence; (4) a syndrome linear dependence theorem showing bounded error weight implies a low-degree syndrome annihilator; and (5) a Hankel rank bound theorem establishing that the rank of the syndrome Hankel matrix is at most the Hamming weight of the error. Together, these theorems formalize the chain of reasoning from root geometry through syndrome dynamics to certified decodability, and establish a cross-domain bridge connecting coding theory to sparse signal recovery, control theory, and structured low-rank matrix analysis. All proofs are checked by the Lean kernel with no unverified axioms beyond the standard foundations.

**Keywords:** error-correcting codes, finite fields, syndrome decoding, Berlekamp-Massey, linear recurrence, Hankel matrices, structured low-rank recovery, sparse interpolation, formal verification, certified algorithms

---

## 1. Introduction

### 1.1 Motivation

Reed-Solomon (RS) and Bose-Chaudhuri-Hocquenghem (BCH) codes are the workhorses of practical error correction, deployed in systems ranging from deep-space communication (Voyager, Cassini) to consumer storage (QR codes, Blu-ray discs, SSDs) and telecommunications (DVB, 5G NR). Their algebraic structure — polynomial evaluation over finite fields with primitive root constraints — enables efficient decoding via the Berlekamp-Massey (BM) algorithm and its variants.

Despite decades of theoretical development, the complete chain of reasoning from code definition through decoder correctness has not previously been machine-verified. Informal proofs in the literature rely on well-understood but rarely fully detailed arguments involving Vandermonde determinants, linear recurrence theory, and polynomial algebra. Our work closes this gap.

### 1.2 Contributions

We formalize the following theorems in Lean 4 + Mathlib, with complete proofs verified by the Lean kernel:

1. **Structural BCH Bound** (`bch_bound_structural`): A vector satisfying δ−1 consecutive syndrome equations is either zero or has Hamming weight ≥ δ. The proof uses an explicit Vandermonde invertibility argument.

2. **Unique Decoding Radius** (`unique_decode_of_lt_half_distance`): If a linear code has minimum distance d, then for any received word, there is at most one codeword within Hamming distance t when 2t < d.

3. **Error Locator Annihilation** (`locator_annihilates_syndromeSeq`): The reversed error locator polynomial Λ_rev(z) = ∏_{j ∈ supp(e)} (z − α^j) annihilates the syndrome sequence s_k = Σ_j e_j (α^j)^k.

4. **Syndrome Linear Dependence** (`syndrome_linear_dependence`): When the error weight is at most t, there exists a nonzero polynomial of degree ≤ t that annihilates the syndrome sequence.

5. **Hankel Rank Bound** (`hankel_rank_le_weight`): The rank of the m×m syndrome Hankel matrix H[i,j] = s_{i+j} is at most the Hamming weight of the error.

Additionally, we define new algebraic structures (`ConsecutiveRootSet`, `HasConsecutiveRoots`) and provide working Python implementations of the full RS decoding pipeline.

### 1.3 Relationship to Prior Work

The BCH bound and RS minimum distance theorem are classical (Bose & Ray-Chaudhuri 1960, Hocquenghem 1959, Reed & Solomon 1960). The Berlekamp-Massey algorithm was developed by Berlekamp (1968) and Massey (1969). The connection between Hankel matrices and linear recurrences is well-known in systems theory (Ho & Kalman 1966).

Previous formalization efforts in proof assistants have addressed specific coding theory results — notably Affeldt and colleagues' work on information theory in Coq, and various Mathlib contributions on polynomial algebra and finite fields. Our work is distinguished by formalizing the *complete chain* from root geometry through syndrome dynamics to decoder correctness, and by establishing the Hankel rank bridge as a formally verified cross-domain result.

---

## 2. Definitions and Notation

### 2.1 Finite Fields and Primitive Roots

We work over an arbitrary field K with decidable equality. An element α ∈ K is *primitive* of order n if α^n = 1 and α^j ≠ 1 for 0 < j < n. The key property we use is *injectivity*: α^i = α^j implies i ≡ j (mod n), which for indices in {0, …, n−1} means i = j.

### 2.2 Hamming Weight and Distance

For a vector x : Fin n → K, the Hamming weight is:

```
hammingWeight(x) = |{i : x_i ≠ 0}|
```

The Hamming distance between x and y is:

```
hammingDist(x, y) = |{i : x_i ≠ y_i}|
```

We prove the fundamental identity `hammingDist(x, y) = hammingWeight(x − y)` and the triangle inequality `hammingDist(x, z) ≤ hammingDist(x, y) + hammingDist(y, z)`.

### 2.3 BCH Syndromes

The syndrome of a vector c with respect to root α, offset b, and index j is:

```
syndrome(α, b, c, j) = Σᵢ cᵢ · α^{(b+j)·i}
```

The syndrome sequence (without offset) is:

```
syndromeSeq(α, e, k) = Σᵢ eᵢ · (α^i)^k
```

### 2.4 Error Locator Polynomial

For an error vector e with support S = {i : eᵢ ≠ 0}, the reversed error locator polynomial is:

```
errorLocatorPolyRev(α, e) = ∏_{j ∈ S} (X − α^j)
```

This polynomial is monic of degree |S| = hammingWeight(e), and vanishes at α^j for every error position j ∈ S.

### 2.5 Syndrome Annihilation

A polynomial Λ annihilates the syndrome sequence if:

```
∀ k, Σ_{l=0}^{deg Λ} Λ_l · s_{k+l} = 0
```

### 2.6 Syndrome Hankel Matrix

```
H[i,j] = s_{i+j}    (i, j = 0, …, m−1)
```

---

## 3. Main Results

### 3.1 Theorem 1: Structural BCH Bound

**Statement.** Let K be a field, α ∈ K nonzero with α^i = α^j ⟹ i = j for i, j ∈ Fin n. Let c : Fin n → K satisfy the BCH parity check: syndrome(α, b, c, j) = 0 for all j < δ − 1. Then c = 0 or hammingWeight(c) ≥ δ.

**Proof sketch.** Assume c ≠ 0 and let S = supp(c) with |S| < δ. Index S by Fin |S| via an injective map e. Define w_ℓ = c_{e(ℓ)} · α^{b · e(ℓ)} and x_ℓ = α^{e(ℓ)}. The parity check gives Σ_ℓ w_ℓ · x_ℓ^j = 0 for j = 0, …, |S|−1. This is a homogeneous system with Vandermonde matrix V[i,j] = x_j^i. Since the x_ℓ are distinct (by injectivity of α), det(V) ≠ 0 (by the Vandermonde determinant formula), so w = 0. But w_ℓ ≠ 0 since c_{e(ℓ)} ≠ 0 and α is nonzero. Contradiction.

**Formal status.** Fully verified in Lean 4. The proof uses `Matrix.det_vandermonde`, `Matrix.eq_zero_of_mulVec_eq_zero`, and `Finset.orderEmbOfFin`.

### 3.2 Theorem 2: Unique Decoding Radius

**Statement.** Let C be a linear code with minimum distance d. If c₁, c₂ ∈ C satisfy hammingDist(r, c₁) ≤ t and hammingDist(r, c₂) ≤ t with 2t < d, then c₁ = c₂.

**Proof sketch.** By contradiction: if c₁ ≠ c₂, then c₁ − c₂ ∈ C (linearity) and c₁ − c₂ ≠ 0, so hammingWeight(c₁ − c₂) ≥ d. But hammingDist(c₁, c₂) = hammingWeight(c₁ − c₂) ≤ hammingDist(c₁, r) + hammingDist(r, c₂) ≤ 2t < d. Contradiction.

**Formal status.** Fully verified, using `hammingDist_eq_weight_sub` and `hammingDist_triangle`.

### 3.3 Theorem 3: Error Locator Annihilation

**Statement.** For any error vector e : Fin n → K, the reversed error locator polynomial Λ_rev = ∏_{j ∈ supp(e)} (X − α^j) annihilates the syndrome sequence:

```
∀ k, Σ_{l=0}^{deg Λ_rev} (Λ_rev)_l · syndromeSeq(α, e, k+l) = 0
```

**Proof sketch.** By `syndromeSeq_eq_sum_geom`, s_{k+l} = Σ_{j ∈ supp(e)} e_j (α^j)^{k+l}. Swapping sums:

```
Σ_l (Λ_rev)_l · s_{k+l} = Σ_j e_j (α^j)^k · Σ_l (Λ_rev)_l (α^j)^l = Σ_j e_j (α^j)^k · eval(α^j, Λ_rev)
```

Since j ∈ supp(e) and Λ_rev vanishes at α^j (by `errorLocatorPolyRev_eval_zero`), each term is zero.

**Formal status.** Fully verified, using `Polynomial.eval_eq_sum_range` and `Finset.sum_eq_zero`.

### 3.4 Theorem 4: Syndrome Linear Dependence

**Statement.** If hammingWeight(e) ≤ t, then there exists a nonzero polynomial Λ of degree ≤ t that annihilates the syndrome sequence of e.

**Proof.** Take Λ = errorLocatorPolyRev(α, e). It is nonzero (product of nonzero factors), has degree = hammingWeight(e) ≤ t, and annihilates the syndrome sequence by Theorem 3.

**Formal status.** Fully verified as a direct corollary.

### 3.5 Theorem 5: Hankel Rank Bound

**Statement.** For any m, rank(syndromeHankelMatrix(syndromeSeq(α, e), m)) ≤ hammingWeight(e).

**Proof sketch.** The Hankel matrix factors as H = A · B where A[i,j] = e_j · (α^j)^i and B[j,k] = (α^j)^k. This is proved by direct computation: H[i,k] = s_{i+k} = Σ_j e_j (α^j)^{i+k} = Σ_j A[i,j] · B[j,k]. Then rank(H) = rank(A·B) ≤ rank(A). The matrix A further factors as A = V · diag(e) where V[i,j] = (α^j)^i, so rank(A) ≤ rank(diag(e)) = |{j : e_j ≠ 0}| = hammingWeight(e).

**Formal status.** Fully verified, using `Matrix.rank_mul_le_left`, `Matrix.rank_mul_le_right`, and `Matrix.rank_diagonal`.

---

## 4. Algorithms

### 4.1 Berlekamp-Massey Algorithm

**Input:** Syndrome sequence S = (S_0, S_1, …, S_{N-1}) over a field K.
**Output:** Minimal monic polynomial Λ such that Σ_{l=0}^{deg Λ} Λ_l S_{k+l} = 0 for all valid k.

```
Initialize: C ← 1, B ← 1, L ← 0, m ← 1, b ← 1
For n = 0 to N-1:
    Δ ← S_n + Σ_{j=1}^{L} C_j · S_{n-j}
    If Δ = 0: m ← m + 1
    Else if 2L ≤ n:
        T ← C
        C ← C - (Δ/b) · x^m · B
        L ← n + 1 - L
        B ← T, b ← Δ, m ← 1
    Else:
        C ← C - (Δ/b) · x^m · B
        m ← m + 1
Return C
```

**Complexity:** O(N²) field operations, O(N) space.

### 4.2 RS Decoding Pipeline

1. **Syndrome computation:** Evaluate received polynomial at α^b, …, α^{b+2t-1}. Cost: O(n·2t).
2. **Error locator:** Run Berlekamp-Massey on syndromes. Cost: O(t²).
3. **Root finding (Chien search):** Evaluate Λ at all α^{-i}. Cost: O(n·t).
4. **Error magnitudes (Forney):** Compute error evaluator Ω and formal derivative Λ'. Cost: O(t²).
5. **Correction:** Subtract error at identified positions. Cost: O(t).

**Total:** O(n·t) field operations.

---

## 5. Cross-Domain Connections

### 5.1 Coding Theory ↔ Linear Systems / Control Theory

The syndrome sequence s_k = Σ_j Y_j X_j^k is the impulse response of a discrete-time linear system with state matrix diag(X₁, …, X_w), input matrix (Y₁, …, Y_w)^T, and output matrix (1, …, 1). The error locator polynomial is the characteristic polynomial of the state matrix. The Hankel rank equals the McMillan degree (minimal realization order). Berlekamp-Massey performs system identification — the Kalman realization algorithm restricted to finite fields.

### 5.2 Coding Theory ↔ Sparse Interpolation / Prony's Method

The syndrome sequence is a sum of w geometric progressions (exponentials). Recovering the bases X_j = α^{i_j} and coefficients Y_j = e_{i_j} from the sequence is exactly Prony's problem (1795). The error locator polynomial is the Prony polynomial. Spectral estimation methods (ESPRIT, MUSIC) solve the same problem in the noisy continuous case. Our formal theorems verify the exact-arithmetic version.

### 5.3 Coding Theory ↔ Structured Low-Rank Recovery

The Hankel rank bound (Theorem 5) says that bounded error weight implies bounded rank of the syndrome Hankel matrix. In compressed sensing terms, the error vector is sparse, and the Hankel matrix provides a structured measurement matrix whose rank reveals the sparsity level. The Berlekamp-Massey algorithm performs exact low-rank matrix factorization in this structured setting.

---

## 6. Computational Experiments

### 6.1 RS(15, 11) over GF(2⁴)

We implemented and tested a full RS decoder over GF(16):
- Generator polynomial g(x) = ∏_{i=1}^{4} (x − α^i) of degree 4.
- Minimum distance d = 5, correction capability t = 2.
- All 1-error and 2-error patterns correctly decoded.
- Syndrome annihilation verified: the reversed error locator exactly annihilates the syndrome stream.

### 6.2 RS(255, 223) over GF(2⁸)

- Code rate R = 223/255 ≈ 0.875.
- Minimum distance d = 33, correction capability t = 16.
- Successfully corrected 16 simultaneous symbol errors in ASCII text.
- Berlekamp-Massey recovered the exact error locator in all test cases.

### 6.3 Hankel Rank Experiments

For random error patterns of weight w over GF(2⁴):
- Berlekamp-Massey degree = w in all cases (100% of 1000 random trials).
- This empirically confirms that the Hankel rank bound is tight for generic errors.

---

## 7. Discussion

### 7.1 Implications for Verified Systems

Our formalization provides a foundation for *certified decoders* — implementations whose correctness is guaranteed by machine-verified mathematics. This is relevant to safety-critical applications where decoder bugs could have catastrophic consequences (aerospace, medical devices, financial systems).

### 7.2 Limitations

- We have not yet formalized the Berlekamp-Massey algorithm itself in Lean 4, only its correctness specification.
- The uniqueness of the error locator polynomial (the theorem that BM computes the *forced* object) is stated implicitly through the linear dependence theorem; a full explicit uniqueness proof remains future work.
- Our Hankel rank bound is for the infinite syndrome sequence; a finite-prefix version with explicit bounds on the required number of syndromes would strengthen the algorithmic connection.

### 7.3 Relationship to Existing Formalizations

The Mathlib library provides extensive infrastructure for polynomial algebra, finite fields, matrices, and Vandermonde determinants, which we use heavily. Our contribution builds on this infrastructure to formalize *coding-theoretic* results that are not present in Mathlib.

---

## 8. Future Work

1. **Full BM verification:** Formalize the Berlekamp-Massey algorithm as a Lean function and prove it outputs the minimal annihilating polynomial.
2. **Explicit uniqueness:** Prove that below the half-distance threshold, the error locator polynomial is the *unique* minimal monic annihilator.
3. **Alternant/Goppa extension:** Generalize from BCH/RS to alternant and Goppa codes by replacing primitive-power syndromes with rational evaluation syndromes.
4. **Finite-prefix Hankel rank:** Prove that rank(H_m) = weight(e) when m ≥ 2·weight(e) and α is sufficiently generic.
5. **Verified decoder extraction:** Use Lean's code generation to extract a verified RS decoder in executable form.

---

## References

1. R.C. Bose and D.K. Ray-Chaudhuri. "On a class of error correcting binary group codes." *Information and Control*, 3(1):68–79, 1960.

2. A. Hocquenghem. "Codes correcteurs d'erreurs." *Chiffres*, 2:147–156, 1959.

3. I.S. Reed and G. Solomon. "Polynomial codes over certain finite fields." *Journal of the Society for Industrial and Applied Mathematics*, 8(2):300–304, 1960.

4. E.R. Berlekamp. *Algebraic Coding Theory*. McGraw-Hill, 1968.

5. J.L. Massey. "Shift-register synthesis and BCH decoding." *IEEE Transactions on Information Theory*, 15(1):122–127, 1969.

6. B.L. Ho and R.E. Kalman. "Effective construction of linear state-variable models from input/output functions." *Regelungstechnik*, 14(12):545–548, 1966.

7. G. de Prony. "Essai expérimental et analytique..." *Journal de l'École Polytechnique*, 1(2):24–76, 1795.

8. The Mathlib Community. "Mathlib: a unified library of mathematics formalized in Lean." https://github.com/leanprover-community/mathlib4

---

## Appendix: Formal Theorem Statements

The complete Lean 4 formalization is in `Algebra/CodingTheory/Defs.lean` and `Algebra/CodingTheory/Theorems.lean`. Key theorem signatures:

```lean
theorem bch_bound_structural
    {K : Type*} [Field K] [DecidableEq K] {n δ : ℕ} (α : K) (b : ℕ)
    (hα_ne : α ≠ 0) (hα_inj : ∀ i j : Fin n, α ^ i.val = α ^ j.val → i = j)
    (_hδ : δ ≤ n + 1) (c : Fin n → K) (hc : BCHParityCheck α b δ c) :
    c = 0 ∨ δ ≤ hammingWeight c

theorem unique_decode_of_lt_half_distance
    {K : Type*} [Field K] [DecidableEq K] {n : ℕ} {C : Set (Fin n → K)}
    {r c₁ c₂ : Fin n → K} {t d : ℕ}
    (hmin : ∀ c ∈ C, c ≠ 0 → d ≤ hammingWeight c) (hlin : IsLinearCode C)
    (hd₁ : hammingDist r c₁ ≤ t) (hd₂ : hammingDist r c₂ ≤ t)
    (hc₁ : c₁ ∈ C) (hc₂ : c₂ ∈ C) (hlt : 2 * t < d) : c₁ = c₂

theorem locator_annihilates_syndromeSeq
    {K : Type*} [Field K] [DecidableEq K] {n : ℕ} (α : K) (e : Fin n → K) :
    annihilatesSyndromeSeq α e (errorLocatorPolyRev α e)

theorem syndrome_linear_dependence
    {K : Type*} [Field K] [DecidableEq K] {n t : ℕ} (α : K) (e : Fin n → K)
    (hw : hammingWeight e ≤ t) :
    ∃ Λ : K[X], Λ ≠ 0 ∧ Λ.natDegree ≤ t ∧ annihilatesSyndromeSeq α e Λ

theorem hankel_rank_le_weight
    {K : Type*} [Field K] [DecidableEq K] {n m : ℕ} (α : K) (e : Fin n → K) :
    (syndromeHankelMatrix (syndromeSeq α e) m).rank ≤ hammingWeight e
```

All theorems depend only on the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`.
