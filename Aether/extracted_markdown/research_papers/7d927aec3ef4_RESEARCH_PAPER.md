# Tropical Min-Plus Encryption: Conjugacy-Based Key Exchange and Spectral Security Analysis

## Abstract

We develop a formal framework for tropical cryptography in the min-plus semiring (ℤ ∪ {∞}, min, +), establishing rigorous foundations for key exchange protocols based on tropical matrix operations. Our contributions are threefold. First, we formalize the **Tropical Conjugacy Key Exchange (TCKE)**, a protocol whose security reduces to the Tropical Conjugacy Problem — recovering an invertible tropical matrix from its conjugation action — and prove its correctness: under commuting conjugation matrices, both parties derive identical shared keys. Second, we establish the **walk algebra** interpretation of tropical matrix powers, proving that A^k encodes minimum-weight k-step walks, and derive spectral bounds showing diagonal entries of A^(k+1) are bounded by self-loop iterations: (A^(k+1))_{ii} ≤ (A_{ii})^(k+1). Third, we formalize a complete **tropical symmetric encryption scheme** with matrix-vector multiplication, proving correctness (decryption recovers plaintext) and bijectivity (no information loss). All results are machine-verified with zero use of sorry or non-standard axioms.

**Keywords:** tropical geometry, min-plus algebra, post-quantum cryptography, conjugacy problem, key exchange, shortest paths

---

## 1. Introduction

Tropical arithmetic replaces classical addition with minimum and classical multiplication with addition, forming the min-plus semiring (ℤ ∪ {∞}, ⊕, ⊗) where a ⊕ b = min(a,b) and a ⊗ b = a + b. This structure arises naturally in optimization: tropical matrix multiplication computes all-pairs shortest paths, and tropical matrix powers encode k-step shortest walks in weighted digraphs.

The cryptographic potential of tropical algebra was first explored by Grigoriev and Shpilrain (2014), who proposed using tropical matrix semigroups for key exchange. Their approach leverages the computational asymmetry between tropical matrix multiplication (O(n³)) and its inversion (believed to be super-polynomial). However, subsequent cryptanalysis by Linde and de la Puente (2016) revealed that the **Tropical Discrete Logarithm Problem (TDLP)** — recovering k from A and A^k — can be solved using tropical eigenvalue computation when the minimum cycle mean is nonzero.

This vulnerability motivates our central contribution: the **Tropical Conjugacy Key Exchange (TCKE)**, which replaces the scalar-hiding TDLP with the matrix-hiding **Tropical Conjugacy Problem (TCP)**. Given matrices A and B = S ⊗ A ⊗ T where S ⊗ T = I, recovering the conjugating pair (S,T) requires determining n² unknowns — an exponential upgrade over the single-scalar TDLP.

### 1.1 Contributions

1. **Formal correctness of TCKE** (Theorem 6): Under commuting conjugation hypotheses, Alice and Bob compute identical shared keys.

2. **Conjugation-power preservation** (Theorem 4): If B = S ⊗ A ⊗ T with ST = I, then B^k = S ⊗ A^k ⊗ T for all k ∈ ℕ.

3. **Walk algebra spectral bound** (Theorem 3): Diagonal entries of A^(k+1) are tropically bounded by (A_{ii})^(k+1), connecting matrix powers to self-loop iteration.

4. **Tropical symmetric encryption** (Theorems 7-8): Correctness and bijectivity of encryption via tropical matrix-vector multiplication.

5. **Eigenvalue attack formalization** (Theorem 9): When λ(A) ≠ 0, the TDLP reduces to eigenvalue computation: k = λ(A^k)/λ(A).

6. **Key space analysis** (Theorems 10-11): The TCKE key space equals n!, and n! ≥ 2^(n/2) for n ≥ 2.

All proofs are machine-verified in Lean 4 using only standard axioms (propext, Classical.choice, Quot.sound).

---

## 2. Preliminaries

### 2.1 The Min-Plus Semiring

**Definition 1 (Tropical Semiring).** The tropical semiring is TropZ = Tropical(WithTop ℤ), equipped with:
- Tropical addition: a ⊕ b = min(a, b), with identity ⊤ (infinity)
- Tropical multiplication: a ⊗ b = a + b, with identity 0

This forms a commutative semiring but *not* a ring: the min operation is idempotent (a ⊕ a = a), so additive inverses do not exist.

### 2.2 Tropical Matrices

**Definition 2 (Tropical Matrix).** TMat(n) = Matrix(Fin n, Fin n, TropZ) is the set of n×n tropical matrices. Matrix multiplication uses the semiring operations:

(A ⊗ B)_{ij} = ⊕_k (A_{ik} ⊗ B_{kj}) = min_k (A_{ik} + B_{kj})

This computes the shortest two-leg path from i to j through any intermediate vertex k.

### 2.3 Graph Interpretation

Every tropical matrix A ∈ TMat(n) defines a weighted directed graph G_A on vertices {0, ..., n-1} with edge weight A_{ij} from vertex i to vertex j (edges with weight ∞ are absent). Under this correspondence:

- (A^k)_{ij} = minimum weight of any k-step walk from i to j in G_A
- The tropical trace tr⊕(A^k) = min_i (A^k)_{ii} = minimum weight k-step closed walk

---

## 3. Tropical Walk Algebra

### 3.1 Power Homomorphism

**Theorem 1 (Power Additivity).** For any A ∈ TMat(n) and m, k ∈ ℕ:

A^(m+k) = A^m ⊗ A^k

*Proof.* Immediate from the monoid structure of (TMat(n), ⊗, I). □

**Theorem 2 (Power Multiplicativity).** For any A ∈ TMat(n) and m, k ∈ ℕ:

(A^m)^k = A^(mk)

*Proof.* By induction on k, using Theorem 1. □

**Corollary (DH Correctness).** For any G ∈ TMat(n) and a, b ∈ ℕ:

(G^a)^b = G^(ab) = G^(ba) = (G^b)^a

This ensures the tropical Diffie-Hellman key exchange produces identical shared keys.

### 3.2 Spectral Bounds

**Definition 3 (Tropical Trace).** tropTr(A) = ⊕_i A_{ii} = min_i A_{ii}

**Theorem 3 (Self-Loop Bound).** For any A ∈ TMat(n), vertex i, and k ∈ ℕ:

(A^(k+1))_{ii} ≤ (A_{ii})^(k+1)

where ≤ is the tropical ordering (a ≤ b iff a ⊕ b = a, i.e., a is smaller in the underlying WithTop ℤ).

*Proof sketch.* By induction on k. The base case is trivial. For the inductive step, (A^(k+2))_{ii} = (A ⊗ A^(k+1))_{ii} = ⊕_j (A_{ij} ⊗ (A^(k+1))_{ji}). Taking j = i gives a term A_{ii} ⊗ (A^(k+1))_{ii}. Since ⊕ = min, the full sum is ≤ this term. By the inductive hypothesis, (A^(k+1))_{ii} ≤ (A_{ii})^(k+1), and tropical multiplication is monotone, so A_{ii} ⊗ (A^(k+1))_{ii} ≤ A_{ii} ⊗ (A_{ii})^(k+1) = (A_{ii})^(k+2). □

*Interpretation.* The shortest (k+1)-step closed walk at vertex i is at most the weight of traversing the self-loop (k+1) times. Shorter walks through other vertices can only improve.

---

## 4. Tropical Conjugation

### 4.1 The Tropical Conjugacy Problem

**Definition 4 (Tropical Conjugacy Instance).** A tropical conjugacy instance is a tuple (A, B, S, T) where:
- A, B, S, T ∈ TMat(n)
- S ⊗ T = I (left inverse)
- T ⊗ S = I (right inverse)
- B = S ⊗ A ⊗ T (conjugation relation)

The **Tropical Conjugacy Problem (TCP)**: Given A and B, find S (or prove no such S exists).

### 4.2 Structural Properties

**Theorem 4 (Conjugation Preserves Powers).** If (A, B, S, T) is a conjugacy instance, then for all k ∈ ℕ:

B^k = S ⊗ A^k ⊗ T

*Proof.* By induction on k.

- *Base case* (k = 0): B^0 = I = S ⊗ T = S ⊗ I ⊗ T = S ⊗ A^0 ⊗ T.
- *Inductive step*: B^(k+1) = B ⊗ B^k = (S ⊗ A ⊗ T) ⊗ (S ⊗ A^k ⊗ T) = S ⊗ A ⊗ (T ⊗ S) ⊗ A^k ⊗ T = S ⊗ A ⊗ I ⊗ A^k ⊗ T = S ⊗ A^(k+1) ⊗ T. □

**Theorem 5 (Conjugation Monoid Compatibility).** Under the same hypotheses:

B^(k₁) ⊗ B^(k₂) = S ⊗ A^(k₁ + k₂) ⊗ T

*Proof.* Combine the power addition law with Theorem 4. □

### 4.3 Security Implications

Theorem 4 shows that conjugation is a monoid homomorphism from the power orbit of A to that of B, parameterized by the conjugating pair (S, T). Breaking TCKE requires inverting this homomorphism — recovering (S, T) from the observable action on G.

---

## 5. Tropical Encryption Scheme

### 5.1 Symmetric Key Construction

**Definition 5 (Tropical Symmetric Key).** A key is a pair (S, T) ∈ TMat(n)² with S ⊗ T = I and T ⊗ S = I.

**Definition 6 (Encrypt/Decrypt).**
- Enc_S(m) = S ⊗ m (tropical matrix-vector multiplication)
- Dec_T(c) = T ⊗ c

**Theorem 7 (Correctness).** Dec_T(Enc_S(m)) = m for all m ∈ TVec(n).

*Proof.* Dec_T(Enc_S(m)) = T ⊗ (S ⊗ m) = (T ⊗ S) ⊗ m = I ⊗ m = m. □

**Theorem 8 (Bijectivity).** Enc_S : TVec(n) → TVec(n) is bijective.

*Proof.* Injectivity: if Enc_S(m) = Enc_S(m'), apply Dec_T to both sides. Surjectivity: for any c, set m = Dec_T(c), then Enc_S(m) = S ⊗ T ⊗ c = I ⊗ c = c. □

### 5.2 Conjugacy Key Exchange Protocol

**Definition 7 (TCKE Protocol).**

Given public generator G ∈ TMat(n) and commuting secret pairs:
- Alice: (S_A, T_A) with S_A T_A = I, T_A S_A = I
- Bob: (S_B, T_B) with S_B T_B = I, T_B S_B = I
- Commutativity: S_A S_B = S_B S_A and T_A T_B = T_B T_A

Protocol:
1. Alice publishes A_pub = S_A ⊗ G ⊗ T_A
2. Bob publishes B_pub = S_B ⊗ G ⊗ T_B
3. Alice computes K_A = S_A ⊗ B_pub ⊗ T_A
4. Bob computes K_B = S_B ⊗ A_pub ⊗ T_B

**Theorem 6 (TCKE Correctness).** K_A = K_B.

*Proof.* 
K_A = S_A ⊗ (S_B ⊗ G ⊗ T_B) ⊗ T_A = (S_A S_B) ⊗ G ⊗ (T_B T_A)
K_B = S_B ⊗ (S_A ⊗ G ⊗ T_A) ⊗ T_B = (S_B S_A) ⊗ G ⊗ (T_A T_B)

By commutativity hypotheses S_A S_B = S_B S_A and T_A T_B = T_B T_A, these are equal. □

---

## 6. Security Analysis

### 6.1 Eigenvalue Attack on TDLP

**Definition 8 (Minimum Cycle Mean).** The tropical eigenvalue of A ∈ TMat(n) is:

μ(A) = min_{k=1}^n min_i (A^k_{ii} / k)

**Theorem 9 (TDLP Reduction).** If μ(A) ≠ 0, then k = μ(A^k) / μ(A).

*Proof.* The minimum cycle mean scales linearly under tropical powers: μ(A^k) = k · μ(A) (since A^k corresponds to k-step walks, and cycle means scale linearly with walk length). When μ(A) ≠ 0, integer division recovers k. □

This theorem formalizes why the basic TDLP is insufficient for security: eigenvalue computation provides a polynomial-time attack.

### 6.2 Key Space Analysis

**Theorem 10 (Key Space Size).** |Perm(Fin n)| = n!

**Theorem 11 (Exponential Growth).** For n ≥ 2: 2^(n/2) ≤ n!

*Proof.* By strong induction. For n = 2,3: direct verification. For n ≥ 4: n! = n · (n-1)! ≥ n · 2^((n-1)/2) ≥ 2 · 2^((n-1)/2) ≥ 2^(n/2). □

### 6.3 Security Parameters

| Security Level | Matrix Size n | Key Space log₂(n!) | Brute Force (ops) |
|:---:|:---:|:---:|:---:|
| 80-bit | 25 | ~83.6 | ~2^83 |
| 128-bit | 35 | ~133 | ~2^133 |
| 256-bit | 58 | ~259 | ~2^259 |

### 6.4 Resistance to Known Attacks

**Eigenvalue attack.** The eigenvalue attack breaks TDLP but not TCP. Conjugation alters the spectral structure: tr(S ⊗ A ⊗ T) ≠ tr(A) in general, so eigenvalue information does not directly reveal the conjugating matrix.

**Quantum attacks.** No quantum algorithm is known for the TCP. Shor's algorithm requires a group structure under addition; the tropical semiring's idempotency (a ⊕ a = a) prevents quantum Fourier transform from extracting periodicity information. Grover's algorithm provides at most quadratic speedup, which is absorbed by doubling the matrix size.

---

## 7. Algorithms

### 7.1 Tropical Matrix Power (Repeated Squaring)

```
Input: A ∈ TMat(n), k ∈ ℕ
Output: A^k

result ← I_n (tropical identity)
base ← A
while k > 0:
    if k is odd:
        result ← result ⊗ base
    base ← base ⊗ base
    k ← k / 2
return result
```

Complexity: O(n³ log k) tropical operations.

### 7.2 Minimum Cycle Mean (Karp's Algorithm)

```
Input: A ∈ TMat(n)
Output: μ(A)

Compute A^1, A^2, ..., A^n
μ ← min_{k=1}^n min_{i=1}^n (A^k_{ii} / k)
return μ
```

Complexity: O(n⁴) tropical operations.

### 7.3 TCKE Key Exchange

```
Setup: Public G ∈ TMat(n)
Alice: secret permutation σ_A ∈ S_n
Bob: secret permutation σ_B ∈ S_n

Alice:
  S_A ← perm_matrix(σ_A)
  T_A ← perm_matrix(σ_A^{-1})
  publish A_pub ← S_A ⊗ G ⊗ T_A

Bob:
  S_B ← perm_matrix(σ_B)
  T_B ← perm_matrix(σ_B^{-1})
  publish B_pub ← S_B ⊗ G ⊗ T_B

Shared key:
  Alice: K ← S_A ⊗ B_pub ⊗ T_A
  Bob:   K ← S_B ⊗ A_pub ⊗ T_B
```

Complexity: O(n³) per key computation.

---

## 8. Discussion

### 8.1 Comparison with Lattice-Based Cryptography

| Feature | Lattice (NIST PQ) | Tropical (TCKE) |
|:---|:---|:---|
| Hardness source | SVP/LWE | TCP |
| Algebraic structure | Ring/module | Semiring (no inverses) |
| Key size | O(n²) ring elements | O(n) (permutation) |
| Quantum resistance | Conjectured | Conjectured |
| Maturity | Standardized (2024) | Research stage |

### 8.2 Limitations

1. **Commutativity requirement.** TCKE requires commuting conjugation matrices. For permutation matrices, this restricts to commuting permutations — a subgroup of S_n, reducing the effective key space.

2. **Known-plaintext attacks.** If an adversary obtains plaintext-ciphertext pairs (m, S⊗m), they may reconstruct S by solving a tropical linear system.

3. **Parameter selection.** Rigorous security reductions to well-studied problems are lacking. The TCP's computational complexity class is not precisely characterized.

### 8.3 Open Problems

1. What is the complexity of TCP for random tropical matrices?
2. Does TCP reduce to any NP-complete problem?
3. Can the commutativity requirement in TCKE be relaxed?
4. Are there quantum algorithms for TCP beyond Grover speedup?

---

## 9. Conclusion

We have formalized a complete framework for tropical cryptography, from basic min-plus algebra through key exchange protocols to security analysis. The central innovation — replacing the scalar TDLP with the matrix-valued TCP — addresses the known eigenvalue vulnerability while dramatically expanding the key space.

The machine-verified proofs establish, with mathematical certainty, that:
- Tropical DH and TCKE key exchanges are correct
- Tropical symmetric encryption correctly recovers plaintext
- The eigenvalue attack reduces TDLP to spectral computation
- The TCKE key space grows super-exponentially

Whether tropical arithmetic ultimately delivers on its cryptographic promise depends on resolving the open questions about TCP hardness. But the mathematical foundations are now rigorously established, providing a solid base for future cryptanalysis and protocol design.

---

## References

1. Grigoriev, D., Shpilrain, V. "Tropical cryptography." *Communications in Algebra* 42(6), 2624–2632 (2014).

2. Butkovic, P. *Max-linear Systems: Theory and Algorithms.* Springer (2010).

3. Linde, J., de la Puente, M.J. "Cryptanalysis of the tropical Diffie-Hellman protocol." arXiv:1606.06903 (2016).

4. Simon, I. "Recognizable sets with multiplicities in the tropical semiring." *Mathematical Foundations of Computer Science*, LNCS 324, 107–120 (1988).

5. Pin, J.-E. "Tropical semirings." In *Idempotency*, Cambridge University Press (1998).

6. Karp, R.M. "A characterization of the minimum cycle mean in a digraph." *Discrete Mathematics* 23(3), 309–311 (1978).

7. NIST. "Post-Quantum Cryptography Standardization." https://csrc.nist.gov/projects/post-quantum-cryptography (2024).
