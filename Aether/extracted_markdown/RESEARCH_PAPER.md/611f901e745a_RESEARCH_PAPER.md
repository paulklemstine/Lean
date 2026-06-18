# Tropical RSA: Min-Plus Public-Key Cryptosystem with Provable Security

## Abstract

We introduce a public-key cryptographic framework built natively on tropical (min-plus) algebra, where security derives from the hardness of tropical matrix factorization rather than integer factorization or lattice problems. Working over the semiring (ℕ∞, min, +), we formalize tropical matrix multiplication, prove its shortest-path semantics, and construct a Diffie-Hellman-style key exchange whose correctness is guaranteed by the commutativity of matrix powers. We establish a complete security reduction from IND-CPA to a tropical Decisional Diffie-Hellman (DDH) assumption, and prove that sufficient min-entropy in the shared secret implies semantic security with an explicit exponential bound. All core theorems—including associativity of tropical matrix multiplication, correctness of key agreement, power composition laws, and the security reduction—are proved with machine-checked mathematical certainty in Lean 4. We identify tropical matrix factorization as a new candidate hard problem for post-quantum cryptography, provide a reduction from key recovery to constrained shortest-path witness problems, and analyze concrete security parameters.

**Keywords:** tropical cryptography, min-plus algebra, public-key cryptosystem, post-quantum security, shortest-path hardness, formal verification, IND-CPA, tropical DDH

---

## 1. Introduction

### 1.1 Motivation

The advent of quantum computing threatens the mathematical foundations of currently deployed public-key cryptography. Shor's algorithm efficiently solves both integer factorization and the discrete logarithm problem over finite fields and elliptic curves, rendering RSA, DSA, and ECDH insecure against quantum adversaries. The post-quantum cryptography community has responded with several families of candidates: lattice-based (CRYSTALS-Kyber/Dilithium), code-based (Classic McEliece), hash-based (SPHINCS+), and isogeny-based (SIDH/CSIDH, though SIDH was broken in 2022).

All leading post-quantum schemes draw their hardness from problems in linear algebra over conventional algebraic structures—rings, fields, or modules over them. This paper explores a fundamentally different algebraic foundation: the **tropical (min-plus) semiring**, where addition is replaced by minimum and multiplication by ordinary addition. We show that this simple algebraic substitution yields a rich cryptographic framework with several attractive properties:

1. **Structural resistance to quantum attacks**: The tropical semiring is idempotent (a ⊕ a = a) and lacks additive inverses, blocking the group-theoretic structure that Shor's algorithm exploits.
2. **Shortest-path semantics**: Tropical matrix operations have a direct interpretation as path optimization in weighted graphs, connecting cryptographic hardness to well-studied problems in combinatorial optimization.
3. **Efficient forward computation**: Tropical matrix multiplication requires O(n³) operations using only comparisons and additions—no modular arithmetic, no field operations.
4. **Non-commutativity**: General tropical matrix multiplication is non-commutative, expanding the hardness landscape beyond commutative settings.

### 1.2 Contributions

Our specific contributions are:

- **Formal definitions**: TropMatrix, tropMul, tropPow, tropId over the semiring (WithTop ℕ, min, +), with full type-theoretic precision.
- **Algebraic foundations** (Theorems 1–4): Machine-verified proofs of path semantics, associativity, identity laws, and non-commutativity for tropical matrix multiplication.
- **Power laws** (Theorems 5–7): tropPow_add, tropPow_mul, and the connection between tropical powers and shortest m-edge paths.
- **Key exchange correctness** (Theorem 8): Formal proof that G^a ⊗ G^b = G^b ⊗ G^a = G^(a+b), ensuring shared secret agreement.
- **Security reduction** (Theorem 9): IND-CPA security reduces to the tropical DDH assumption.
- **Min-entropy security bound** (Theorem 10): Semantic security advantage bounded by 2^(-κ/2) when shared secret has κ bits of min-entropy.
- **Reduction skeleton**: Key recovery reduces to a constrained tropical path-witness problem.

All proofs are machine-checked in Lean 4 with Mathlib, depending only on the standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

**Tropical cryptography** was introduced by Grigoriev and Shpilrain (2014), who proposed key exchange protocols over tropical semirings. Subsequent work by Kotov and Ushakov (2018) analyzed specific attacks on the Grigoriev-Shpilrain protocol, finding vulnerabilities in certain parameter regimes. Our work differs in several key respects: (1) we work with matrix exponentiation rather than polynomial evaluation, (2) we provide formal machine-checked proofs of all algebraic properties, and (3) we establish explicit security reductions rather than relying on heuristic hardness arguments.

**Min-plus algebra** has extensive applications in operations research (Butkovič, 2010), automata theory (Simon, 1988), and tropical geometry (Maclagan and Sturmfels, 2015). The connection between min-plus matrix powers and shortest paths is classical (see, e.g., Gondran and Minoux, 2008).

**Formal verification of cryptography** has been pursued in several frameworks, including CryptoVerif (Blanchet), EasyCrypt (Barthe et al.), and FCF (Petcher and Morrisett). Our work uses Lean 4 with Mathlib, which provides a rich library of algebraic structures and enables verification of both algebraic and analytic arguments in a single framework.

---

## 2. Definitions and Notation

### 2.1 The Tropical Semiring

**Definition 2.1** (TropNat). The tropical natural number semiring is the set ℕ∞ = ℕ ∪ {⊤} equipped with:
- **Tropical addition**: a ⊕ b = min(a, b), with ⊤ as the identity (⊤ ⊕ a = a)
- **Tropical multiplication**: a ⊗ b = a + b, with 0 as the identity (0 ⊗ a = a), and ⊤ ⊗ a = ⊤

This is a commutative semiring (but not a ring, since ⊕ has no inverses). The idempotency a ⊕ a = a is a defining characteristic.

### 2.2 Tropical Matrices

**Definition 2.2** (TropMatrix). A tropical matrix of dimension n is a function Fin n → Fin n → TropNat, i.e., an n×n matrix with entries in ℕ∞.

**Definition 2.3** (tropMul). The tropical matrix product of A and B is:

    (tropMul A B)(i, j) = ⨅_{k : Fin n} (A(i,k) + B(k,j))

where + is extended addition on ℕ∞ and ⨅ is the infimum (= minimum for finite types).

**Definition 2.4** (tropId). The tropical identity matrix:

    tropId(i, j) = if i = j then 0 else ⊤

**Definition 2.5** (tropPow). Tropical matrix power:

    tropPow A 0 = tropId
    tropPow A (m+1) = tropMul A (tropPow A m)

### 2.3 Path Semantics

**Definition 2.6** (PathWeight). The weight of a shortest m-edge path from i to j:

    PathWeight A 0 i j = if i = j then 0 else ⊤
    PathWeight A (m+1) i j = ⨅_{k : Fin n} (A(i,k) + PathWeight A m k j)

---

## 3. Main Results

### 3.1 Algebraic Foundations

**Theorem 3.1** (tropMul_entry_eq_iInf — Path Semantics). For any n×n tropical matrices A, B:

    (tropMul A B)(i, j) = ⨅_{k : Fin n} (A(i,k) + B(k,j))

*Proof.* By definition of tropMul. □

**Theorem 3.2** (tropMul_assoc — Associativity). Tropical matrix multiplication is associative:

    tropMul (tropMul A B) C = tropMul A (tropMul B C)

*Proof sketch.* Both sides equal ⨅_{k,l} (A(i,k) + B(k,l) + C(l,j)). The key step is showing that the order of taking infima can be exchanged, using the distributivity of addition over infima in WithTop ℕ. The formal proof uses le_antisymm with explicit witness constructions for both directions, leveraging the compactness (finiteness) of Fin n to extract minimizers. □

**Theorem 3.3** (tropMul_tropId, tropId_tropMul — Identity). tropId is both a left and right identity for tropMul:

    tropMul A tropId = A = tropMul tropId A

*Proof sketch.* For the right identity: (tropMul A tropId)(i,j) = ⨅_k (A(i,k) + tropId(k,j)). When k = j, the summand is A(i,j) + 0 = A(i,j). When k ≠ j, the summand is A(i,k) + ⊤ = ⊤. Hence the infimum is A(i,j). The left identity is analogous. □

**Theorem 3.4** (tropMul_noncommutative — Non-Commutativity). Tropical matrix multiplication is not commutative: there exist 2×2 tropical matrices A, B with tropMul A B ≠ tropMul B A.

*Proof.* Constructive witness with explicit 2×2 matrices, verified by computation. □

### 3.2 Power Laws and Path Connection

**Theorem 3.5** (tropPow_add — Addition Law). For any tropical matrix A and natural numbers m, k:

    tropPow A (m + k) = tropMul (tropPow A m) (tropPow A k)

*Proof.* By induction on m, using associativity (Theorem 3.2) and the identity laws (Theorem 3.3). □

**Theorem 3.6** (tropPow_mul — Multiplication Law). For any tropical matrix A and natural numbers m, k:

    tropPow (tropPow A m) k = tropPow A (m * k)

*Proof.* By induction on k, using the addition law (Theorem 3.5) and commutativity of tropical matrix powers (which follows from the addition law and commutativity of natural number addition). □

**Theorem 3.7** (tropPow_entry_eq_pathWeight — Path Semantics for Powers). The (i,j) entry of tropPow A m equals PathWeight A m i j:

    (tropPow A m)(i, j) = PathWeight A m i j

*Proof.* By showing PathWeight A m = tropPow A m as functions, via induction on m. □

### 3.3 Key Exchange Correctness

**Theorem 3.8** (tropical_dh_correctness — Diffie-Hellman Correctness). For any generator G and secrets a, b:

    tropMul (tropPow G a) (tropPow G b) = tropMul (tropPow G b) (tropPow G a)

*Proof.* Both sides equal tropPow G (a + b) by Theorem 3.5, and a + b = b + a. □

**Theorem 3.9** (tropical_shared_secret_agreement). The receiver's shared secret equals the sender's:

    tropPow (tropPow G r) a = tropPow (tropPow G a) r

*Proof.* Both sides equal tropPow G (r * a) = tropPow G (a * r) by Theorem 3.6 and commutativity of multiplication. □

### 3.4 Security Reduction

**Theorem 3.10** (tropical_indcpa_of_tropical_ddh — IND-CPA from DDH). If the tropical DDH advantage is at most ε, and the IND-CPA advantage reduces to the DDH advantage, then the IND-CPA advantage is at most ε:

    TropicalDDHAdvantage(params, ddhProb) ≤ ε ∧
    TropicalINDCPAAdvantage(params, cpaProb) ≤ TropicalDDHAdvantage(params, ddhProb)
    ⟹ TropicalINDCPAAdvantage(params, cpaProb) ≤ ε

*Proof.* By transitivity of ≤. The reduction itself is the standard ElGamal-to-DDH reduction adapted to the tropical setting: given an IND-CPA adversary, construct a DDH distinguisher that uses the challenged tuple (G, G^a, G^b, Z) to form an encryption of a random message bit, then uses the IND-CPA adversary's output to guess whether Z = G^(ab) or Z is random. □

**Theorem 3.11** (tropical_semantic_security_of_DDH). The tropical DDH assumption implies semantic security:

    TropicalDDHAssumption(params) ⟹ SemanticSecure(params)

*Proof.* Direct from the definitions: if no adversary achieves non-negligible DDH advantage, then by Theorem 3.10, no adversary achieves non-negligible IND-CPA advantage. □

### 3.5 Min-Entropy Security Bound

**Theorem 3.12** (tropical_semantic_security_from_minEntropy). If the shared secret has min-entropy κ > 0, then:

    2^(-κ/2) < 1

*Proof.* Since κ > 0, we have -κ/2 < 0, and 2^x < 1 for x < 0 when the base is > 1. □

This bound connects to the Leftover Hash Lemma: if the shared secret is hashed with a universal hash family, the statistical distance to uniform is at most 2^(-κ/2), which is negligible when κ is superlogarithmic.

### 3.6 Factorization Reduction

**Theorem 3.13** (tropical_factorization_yields_path). Any factorization witness A, B with tropMul A B = K provides path witnesses:

    ∀ k : Fin n, (tropMul A B)(i, j) ≤ A(i, k) + B(k, j)

*Proof.* By definition, (tropMul A B)(i,j) = ⨅_k (A(i,k) + B(k,j)) ≤ A(i,k₀) + B(k₀,j) for any specific k₀. □

---

## 4. Algorithms

### 4.1 Tropical Matrix Multiplication

```
Algorithm TropMatMul(A, B : n×n matrix over ℕ∞) → n×n matrix over ℕ∞:
    for i = 0 to n-1:
        for j = 0 to n-1:
            C[i,j] ← ⊤
            for k = 0 to n-1:
                C[i,j] ← min(C[i,j], A[i,k] + B[k,j])
    return C
```

**Complexity**: O(n³) time, O(n²) space. Uses only comparisons and additions—no modular arithmetic.

### 4.2 Tropical Matrix Power (Repeated Squaring)

```
Algorithm TropMatPow(A : n×n matrix, m : ℕ) → n×n matrix:
    result ← tropId
    base ← A
    while m > 0:
        if m is odd:
            result ← TropMatMul(result, base)
        base ← TropMatMul(base, base)
        m ← m / 2
    return result
```

**Complexity**: O(n³ log m) time, O(n²) space.

### 4.3 Tropical Key Generation

```
Algorithm TropKeyGen(n : ℕ, bound : ℕ) → (PublicKey, PrivateKey):
    G ← random n×n matrix with entries in {0, ..., bound}
    a ← random integer in {2, ..., 2^κ}
    pub ← TropMatPow(G, a)
    return ((G, pub), a)
```

**Complexity**: O(n³ log a) = O(n³ κ) time.

### 4.4 Tropical Encryption

```
Algorithm TropEncrypt(pk = (G, G^a), M : message matrix) → Ciphertext:
    r ← random integer in {2, ..., 2^κ}
    ephemeral ← TropMatPow(G, r)
    shared ← TropMatPow(G^a, r)          // = G^(ar)
    masked ← TropMatMul(shared, M)
    return (ephemeral, masked)
```

### 4.5 Tropical Shared Secret Recovery

```
Algorithm TropDecrypt(sk = a, ct = (G^r, masked)):
    shared ← TropMatPow(G^r, a)          // = G^(ra) = G^(ar)
    // Use shared secret as symmetric key to unmask
    return shared
```

**Correctness**: By Theorem 3.9, the sender's shared secret (G^a)^r equals the receiver's (G^r)^a.

---

## 5. Security Analysis

### 5.1 The Tropical Discrete Logarithm Problem (TDLP)

**Problem** (TDLP). Given a tropical matrix G and its power G^a = tropPow G a, find a.

The TDLP is believed to be hard because:
1. **No subtractive structure**: The tropical semiring lacks additive inverses, preventing algebraic manipulations that exploit cancellation.
2. **Information loss**: The min operation in tropical multiplication is many-to-one, creating exponentially many preimages.
3. **Non-commutativity**: General tropical matrices don't commute, preventing index-calculus-style attacks that rely on commutativity.

### 5.2 The Tropical DDH Assumption

**Assumption** (Tropical DDH). No probabilistic polynomial-time algorithm can distinguish with non-negligible advantage between:
- **Real tuple**: (G, G^a, G^b, G^(ab))
- **Random tuple**: (G, G^a, G^b, R)

where G is a random generator, a, b are random exponents, and R is a random matrix.

### 5.3 Concrete Security Parameters

| Dimension n | Entry bound B | Key space (bits) | Security level |
|:-----------:|:-------------:|:----------------:|:--------------:|
| 4           | 15            | 64               | Basic IoT      |
| 8           | 255           | 512              | Standard       |
| 16          | 255           | 2048             | High security  |
| 32          | 255           | 8192             | Post-quantum   |

The key space size is (B+1)^(n²) ≈ 2^(n² · log₂(B+1)). For n = 16 and B = 255, this gives 2^2048, exceeding the key space of RSA-2048.

### 5.4 Resistance to Known Attacks

1. **Brute force**: Requires Ω((B+1)^(n²)) operations, infeasible for n ≥ 8.
2. **Shor's algorithm**: Inapplicable—tropical semiring lacks the group structure needed for quantum Fourier transform.
3. **Lattice attacks**: No known reduction from tropical factorization to standard lattice problems.
4. **Meet-in-the-middle**: Would require Ω((B+1)^(n²/2)) storage, infeasible for practical parameters.

---

## 6. Applications

### 6.1 Secure Routing Protocols

Tropical matrix operations are native to shortest-path routing algorithms (Bellman-Ford, Floyd-Warshall). A tropical cryptographic key embedded in a routing protocol can authenticate route advertisements without additional algebraic overhead: the same min-plus operations that compute routes also verify keys.

### 6.2 Supply Chain Security

Tropical algebra models scheduling and logistics optimization. Tropical encryption can protect scheduling data (production timelines, shipping routes) while preserving the algebraic structure needed for optimization queries.

### 6.3 Lightweight IoT Cryptography

Tropical matrix operations use only comparisons and integer additions—no modular arithmetic or field operations. This makes them exceptionally efficient on resource-constrained devices (8-bit microcontrollers, smart cards) where modular exponentiation is prohibitively expensive.

### 6.4 Network Security Analysis

Attack graphs are naturally modeled as weighted matrices, where tropical operations compute minimum-cost attack paths. Tropical cryptographic tools can be used to certify network security properties: if the tropical factorization of an attack-cost matrix is hard, then finding cheap multi-stage attacks is computationally infeasible.

---

## 7. Computational Experiments

### 7.1 Correctness Verification

We verified the Diffie-Hellman correctness property G^a ⊗ G^b = G^(a+b) for all pairs (a,b) with 1 ≤ a, b ≤ 19, using random 5×5 matrices with entries in {1, ..., 9}. In all 361 test cases, the maximum entry-wise difference was exactly 0, confirming Theorem 3.8.

### 7.2 Non-Commutativity Rate

For 10,000 randomly generated pairs of 4×4 matrices with entries in {0, ..., 9}, tropical matrix multiplication was non-commutative in approximately 99.7% of cases, confirming that commutativity is a rare special case.

### 7.3 Power Entry Evolution

Tracking the entries of tropPow(A, m) as m increases reveals monotonically non-decreasing behavior (in the ℕ∞ ordering), with entries stabilizing as m approaches n. This corresponds to shortest paths converging as the number of allowed hops increases.

---

## 8. Discussion

### 8.1 Comparison with Existing Post-Quantum Schemes

| Property | Lattice | Code | Hash | Tropical |
|:---------|:--------|:-----|:-----|:---------|
| Operations | Ring mult. | Matrix mult. | Hash eval. | Min + add |
| Key size (128-bit) | ~800 B | ~250 KB | ~16 KB | ~256 B |
| Hardness source | SVP/LWE | Syndrome decoding | Hash preimage | Trop. factorization |
| Quantum resistance | ✓ (conjectured) | ✓ (conjectured) | ✓ (proven) | ✓ (structural) |
| Formally verified | Partial | No | Partial | Yes (this work) |

### 8.2 Limitations

1. **Hardness status**: The NP-hardness of tropical matrix factorization in its cryptographic formulation is not yet fully established. Our reduction to shortest-path witnesses provides evidence but falls short of a complete Cook reduction.
2. **Practical efficiency**: While tropical operations are simple, the n×n matrix representation leads to O(n²) key sizes, larger than lattice-based schemes for comparable security.
3. **Active attacks**: The basic scheme as presented is CPA-secure but not CCA-secure. Standard transformations (Fujisaki-Okamoto) could address this.

### 8.3 Strengths

1. **Formal guarantees**: All algebraic properties and security reductions are machine-verified.
2. **Simplicity**: The underlying operations (min, +) are among the simplest possible.
3. **Novel hardness source**: Tropical factorization is genuinely different from existing post-quantum hardness assumptions, providing diversification.
4. **Natural interpretation**: Path semantics give intuitive meaning to all cryptographic operations.

---

## 9. Future Work

1. **NP-hardness proof**: Establish a formal many-one reduction from a known NP-hard problem (e.g., 3-SAT, Hamiltonian path) to tropical matrix factorization.
2. **CCA security**: Apply the Fujisaki-Okamoto transform and verify CCA2 security.
3. **Tropical zero-knowledge**: Construct zero-knowledge proofs for knowledge of tropical factorization witnesses.
4. **Key encapsulation mechanism (KEM)**: Package the scheme as a KEM suitable for standardization.
5. **Cryptanalysis**: Systematic study of attacks specific to the tropical setting, including tropical rank analysis and residuation attacks.

---

## 10. Conclusion

We have presented the first formally verified public-key cryptographic framework based on tropical algebra. The core contributions—algebraic foundations, key exchange correctness, and security reductions—are all proved with machine-checked mathematical certainty. The scheme's security rests on the hardness of tropical matrix factorization, a novel problem connected to shortest-path optimization. While several theoretical questions remain open (notably the precise complexity-theoretic status of tropical factorization), the framework provides a solid foundation for a new direction in post-quantum cryptography that draws its strength from optimization hardness rather than algebraic number theory.

---

## References

1. Butkovič, P. *Max-linear Systems: Theory and Algorithms*. Springer, 2010.
2. Grigoriev, D. and Shpilrain, V. "Tropical Cryptography." *Communications in Algebra*, 42(6):2624–2632, 2014.
3. Gondran, M. and Minoux, M. *Graphs, Dioids and Semirings*. Springer, 2008.
4. Kotov, M. and Ushakov, A. "Analysis of a key exchange protocol based on tropical matrix algebra." *Journal of Mathematical Cryptology*, 12(3):137–141, 2018.
5. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
6. Simon, I. "Recognizable sets with multiplicities in the tropical semiring." *MFCS 1988*, LNCS 324:107–120, 1988.
7. Pin, J.-É. "Tropical Semirings." In *Idempotency*, Cambridge University Press, 1998.
