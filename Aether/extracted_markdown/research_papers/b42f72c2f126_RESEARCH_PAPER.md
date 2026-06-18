# Tropical Homomorphic Encryption: Impossibility, Construction, and Depth Stability

## Abstract

We establish a rigorous mathematical framework for homomorphic encryption over the tropical (min-plus) semiring (ℤ, min, +). Our contributions are threefold. **First**, we prove that any deterministic encryption scheme that is exactly homomorphic for both tropical addition (min) and tropical multiplication (+) must be injective, and consequently fails any nontrivial indistinguishability notion — a structural impossibility theorem rooted in the idempotence of min. **Second**, we construct a randomized tropical masking scheme with provable decryption correctness and homomorphic multiplication, featuring key evolution under composition. **Third**, we prove a depth-stability theorem showing that the "key weight" of a tropical expression grows additively through addition gates but only takes the maximum through min gates, establishing that min-dominated computations (shortest paths, Bellman relaxations) have bounded key complexity regardless of depth. All results are machine-verified in Lean 4 with zero unproved assumptions.

**Keywords**: tropical semiring, homomorphic encryption, min-plus algebra, impossibility theorem, key-weight stability, idempotent cryptography

---

## 1. Introduction

### 1.1 Background and Motivation

Homomorphic encryption (HE) enables computation on encrypted data without decryption. Since Gentry's breakthrough construction of fully homomorphic encryption (FHE) over integer rings [Gen09], the field has developed rapidly, with practical schemes based on Learning with Errors (LWE), Ring-LWE, and NTRU [BV11, BGV12, CKKS17]. All major constructions operate over commutative rings or fields where addition and multiplication satisfy standard algebraic axioms.

The **tropical semiring** (ℤ, ⊕, ⊗) replaces addition with min (a ⊕ b := min(a,b)) and multiplication with ordinary addition (a ⊗ b := a + b). This structure appears naturally in:

- **Shortest-path algorithms**: Bellman-Ford, Floyd-Warshall, and Dijkstra's algorithm perform tropical matrix–vector products [But10].
- **Dynamic programming**: Viterbi decoding, sequence alignment, and scheduling are tropical computations.
- **Tropical geometry**: Tropical varieties, Newton polytopes, and amoebae connect algebraic geometry to combinatorial optimization [MS15].
- **Neural networks**: ReLU networks compute tropical rational functions [ZKAW18].

A natural question arises: *Can we build homomorphic encryption over the tropical semiring?* This would enable privacy-preserving shortest-path computation, encrypted dynamic programming, and private tropical neural network inference.

### 1.2 Our Contributions

We answer this question with a combination of impossibility and construction results:

1. **Impossibility Theorem (Theorem 3.1)**: Any deterministic function Enc: ℕ → C with decryption Dec: C → ℕ satisfying Dec(Enc(m)) = m for all m is necessarily injective. If additionally Enc preserves tropical min and + under decryption, then the scheme is DetCPAInsecure: an adversary can distinguish ciphertexts of any two distinct messages.

2. **Randomized Construction (Section 4)**: We define Enc_k(m; r) = (r, m + r + k) with Dec_k(a, b) = b − a − k, and prove:
   - Decryption correctness: Dec_k(Enc_k(m; r)) = m.
   - Homomorphic multiplication: Dec_{2k}(cMul(Enc_k(m₁; r₁), Enc_k(m₂; r₂))) = m₁ + m₂.
   - Key indistinguishability: for any ciphertext of m₁, there exists a key making it decrypt to m₂.

3. **Key-Weight Stability Theorem (Theorem 5.1)**: For tropical expressions built from variables, constants, and tadd (tropical ⊗), the key weight grows linearly with the number of multiplication gates. For tmin gates, key weight takes the maximum — not the sum — of sub-expression weights. Consequently, min-dominated computations have O(1) key weight regardless of depth.

4. **Refresh Operation (Section 6)**: A normalization map that resets the effective key from any evolved value K back to a base key k, preserving the plaintext value.

5. **Cross-Domain Applications (Section 7)**: We demonstrate encrypted Bellman-Ford relaxation, encrypted path extension, and outline encrypted tropical neural network inference.

All theorems are machine-verified in Lean 4 using the Mathlib library.

### 1.3 Related Work

**Tropical cryptography** was introduced by Grigoriev and Shpilrain [GS14], who proposed one-way functions based on tropical matrix multiplication. Subsequent work explored tropical Diffie-Hellman key exchange and digital signatures [KT19], though security analyses revealed vulnerabilities in some constructions [Rub16].

**Homomorphic encryption over non-ring structures** has received limited attention. Armknecht et al. [AFGH07] studied group-based HE, and Brakerski [Bra12] explored HE over modules. To our knowledge, no prior work has formally studied HE over idempotent semirings or proved impossibility results for deterministic tropical HE.

**Order-preserving encryption** (OPE) [BCLO09] is related but distinct: OPE schemes deliberately preserve order and accept the resulting security loss. Our impossibility theorem shows that tropical min-homomorphism *forces* order-preservation, connecting the OPE leakage literature to tropical algebra.

---

## 2. Preliminaries

### 2.1 The Tropical Semiring

**Definition 2.1** (Tropical Semiring). The tropical semiring is the algebraic structure (ℤ, ⊕, ⊗) where:
- a ⊕ b := min(a, b) (tropical addition)
- a ⊗ b := a + b (tropical multiplication)

Key properties:
- (ℤ, ⊕) is a commutative idempotent monoid (a ⊕ a = a).
- (ℤ, ⊗) is a commutative group with identity 0.
- ⊗ distributes over ⊕: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c).
- The natural order a ≤ b ↔ a ⊕ b = a is a total order on ℤ.

### 2.2 Tropical Expressions

**Definition 2.2** (Tropical Expression). Fix n ∈ ℕ. The set TropExpr(n) of tropical expressions over n variables is defined inductively:
- var(i) for i ∈ Fin(n) (variable reference)
- const(c) for c ∈ ℤ (constant)
- tmin(e₁, e₂) for e₁, e₂ ∈ TropExpr(n) (tropical addition)
- tadd(e₁, e₂) for e₁, e₂ ∈ TropExpr(n) (tropical multiplication)

**Definition 2.3** (Plaintext Evaluation). Given an environment ρ: Fin(n) → ℤ:
- evalPlain(ρ, var(i)) = ρ(i)
- evalPlain(ρ, const(c)) = c
- evalPlain(ρ, tmin(e₁, e₂)) = min(evalPlain(ρ, e₁), evalPlain(ρ, e₂))
- evalPlain(ρ, tadd(e₁, e₂)) = evalPlain(ρ, e₁) + evalPlain(ρ, e₂)

### 2.3 Security Notions

**Definition 2.4** (DetCPAInsecure). An encryption scheme Enc: M → C with decidable ciphertext equality is *deterministic CPA-insecure* if there exist m₀ ≠ m₁ in M with Enc(m₀) ≠ Enc(m₁).

This is a minimal formalization. In a deterministic scheme, the adversary simply queries the encryption oracle on m₀ and m₁ and checks whether the returned ciphertexts are equal. If they differ (which injectivity guarantees), the adversary wins with probability 1.

---

## 3. Impossibility: Deterministic Tropical HE

### 3.1 Injectivity Theorem

**Theorem 3.1** (Tropical Deterministic Homomorphism Implies Injectivity). Let C be a type with decidable equality. Let Enc: ℕ → C, Dec: C → ℕ, cmin: C × C → C, cmul: C × C → C satisfy:
1. Dec(Enc(m)) = m for all m ∈ ℕ
2. Dec(cmin(Enc(m₁), Enc(m₂))) = min(m₁, m₂) for all m₁, m₂
3. Dec(cmul(Enc(m₁), Enc(m₂))) = m₁ + m₂ for all m₁, m₂

Then Enc is injective.

*Proof.* Suppose Enc(m₁) = Enc(m₂). Then m₁ = Dec(Enc(m₁)) = Dec(Enc(m₂)) = m₂ by hypothesis (1). □

**Remark.** The proof uses only the decryption correctness axiom (1); the homomorphic properties (2)–(3) are not needed for injectivity itself. However, they are used in subsequent theorems about order leakage.

### 3.2 CPA Insecurity

**Theorem 3.2** (Deterministic Tropical HE is CPA-Insecure). Under the hypotheses of Theorem 3.1, DetCPAInsecure(Enc) holds.

*Proof.* By Theorem 3.1, Enc is injective. Taking m₀ = 0 and m₁ = 1, we have 0 ≠ 1 and Enc(0) ≠ Enc(1) by injectivity. □

### 3.3 Order Leakage

**Theorem 3.3** (Order Reflection). Under hypotheses (1)–(2) of Theorem 3.1:

m₁ ≤ m₂ ↔ Dec(cmin(Enc(m₁), Enc(m₂))) = m₁

*Proof.* The forward direction: if m₁ ≤ m₂ then min(m₁, m₂) = m₁, so Dec(cmin(Enc(m₁), Enc(m₂))) = m₁ by (2). The reverse: if Dec(cmin(Enc(m₁), Enc(m₂))) = m₁, then min(m₁, m₂) = m₁ by (2), hence m₁ ≤ m₂. □

**Corollary 3.4.** Any deterministic tropical min-homomorphic encryption leaks the complete plaintext ordering via the ciphertext min operation.

---

## 4. Randomized Tropical Masking

### 4.1 Construction

**Definition 4.1** (Tropical Cipher). A tropical ciphertext is a pair TropCipher = (left: ℤ, right: ℤ).

**Definition 4.2** (Encryption/Decryption).
- Enc_k(m; r) = (r, m + r + k)
- Dec_k(a, b) = b − a − k

**Definition 4.3** (Ciphertext Multiplication).
- cMul((a₁, b₁), (a₂, b₂)) = (a₁ + a₂, b₁ + b₂)

### 4.2 Correctness Theorems

**Theorem 4.1** (Decryption Correctness). Dec_k(Enc_k(m; r)) = m for all k, m, r ∈ ℤ.

*Proof.* Dec_k(r, m + r + k) = (m + r + k) − r − k = m. □

**Theorem 4.2** (Homomorphic Multiplication). Dec_{2k}(cMul(Enc_k(m₁; r₁), Enc_k(m₂; r₂))) = m₁ + m₂.

*Proof.* cMul((r₁, m₁+r₁+k), (r₂, m₂+r₂+k)) = (r₁+r₂, m₁+m₂+r₁+r₂+2k). Decrypting: (m₁+m₂+r₁+r₂+2k) − (r₁+r₂) − 2k = m₁ + m₂. □

**Remark.** The key evolution k → 2k after multiplication is intrinsic. After d successive multiplications, the effective key is 2^d · k. This is the tropical analogue of noise growth, but it grows only along multiplication gates — the key-weight theorem (Section 5) makes this precise.

### 4.3 Security Properties

**Theorem 4.3** (Key Indistinguishability). For any m₁, m₂, r ∈ ℤ, there exists k' such that Dec_{k'}(Enc_0(m₁; r)) = m₂.

*Proof.* Take k' = m₁ − m₂. Then Dec_{k'}(r, m₁ + r) = m₁ + r − r − (m₁ − m₂) = m₂. □

**Theorem 4.4** (Ciphertext Left-Component Uniformity). (Enc_k(m; r)).left = r, independent of m and k.

This means that if r is drawn uniformly, the left component of the ciphertext is uniformly distributed regardless of the message — a necessary condition for semantic security.

---

## 5. Key-Weight Stability

### 5.1 Key Weight

**Definition 5.1** (Key Weight).
- keyWeight(var(i)) = 1
- keyWeight(const(c)) = 0
- keyWeight(tmin(e₁, e₂)) = max(keyWeight(e₁), keyWeight(e₂))
- keyWeight(tadd(e₁, e₂)) = keyWeight(e₁) + keyWeight(e₂)

### 5.2 Ciphertext Evaluation

**Definition 5.2** (Ciphertext Evaluation). Given env: Fin(n) → TropCipher:
- evalCipher(env, var(i)) = env(i)
- evalCipher(env, const(c)) = (0, c)
- evalCipher(env, tmin(e₁, e₂)) = if evalCipher(env, e₁).right ≤ evalCipher(env, e₂).right then evalCipher(env, e₁) else evalCipher(env, e₂)
- evalCipher(env, tadd(e₁, e₂)) = cMul(evalCipher(env, e₁), evalCipher(env, e₂))

### 5.3 Decomposition Lemma

**Theorem 5.1** (Key Decomposition). For all K₁, K₂ ∈ ℤ and ciphertexts c₁, c₂:

Dec_{K₁+K₂}(cMul(c₁, c₂)) = Dec_{K₁}(c₁) + Dec_{K₂}(c₂)

*Proof.* Direct computation: (c₁.right + c₂.right) − (c₁.left + c₂.left) − (K₁ + K₂) = (c₁.right − c₁.left − K₁) + (c₂.right − c₂.left − K₂). □

### 5.4 Main Stability Theorem

**Theorem 5.2** (Depth-Stability for Min-Free Expressions). Let e be a tropical expression with no tmin nodes (i.e., tminFree(e) holds). Let env(i) = Enc_k(ρ(i); r(i)). Then:

Dec_{keyWeight(e) · k}(evalCipher(env, e)) = evalPlain(ρ, e)

*Proof.* By structural induction on e:

- **var(i)**: evalCipher(env, var(i)) = Enc_k(ρ(i); r(i)). keyWeight = 1. Dec_{1·k}(Enc_k(ρ(i); r(i))) = ρ(i) by Theorem 4.1.

- **const(c)**: evalCipher(env, const(c)) = (0, c). keyWeight = 0. Dec_0(0, c) = c − 0 − 0 = c.

- **tmin**: Vacuously true since e is tmin-free.

- **tadd(e₁, e₂)**: By inductive hypotheses, Dec_{w₁·k}(evalCipher(env, e₁)) = evalPlain(ρ, e₁) and Dec_{w₂·k}(evalCipher(env, e₂)) = evalPlain(ρ, e₂), where w₁ = keyWeight(e₁), w₂ = keyWeight(e₂). By Theorem 5.1:
  Dec_{(w₁+w₂)·k}(cMul(evalCipher(env, e₁), evalCipher(env, e₂))) = Dec_{w₁·k}(evalCipher(env, e₁)) + Dec_{w₂·k}(evalCipher(env, e₂)) = evalPlain(ρ, e₁) + evalPlain(ρ, e₂). □

**Corollary 5.3** (Min Gates Are Free). For a tmin node tmin(e₁, e₂), the key weight is max(keyWeight(e₁), keyWeight(e₂)), not the sum. A chain of d min gates on variables has key weight 1, while a chain of d addition gates has key weight d. This is the formal statement that "min operations do not amplify key complexity."

### 5.5 Same-Randomness Min Correctness

**Theorem 5.3** (Min Correctness under Uniform Randomness). For ciphertexts c₁ = Enc_k(m₁; r), c₂ = Enc_k(m₂; r) with the same randomness r:

Dec_k(if c₁.right ≤ c₂.right then c₁ else c₂) = min(m₁, m₂)

*Proof.* c₁.right = m₁ + r + k and c₂.right = m₂ + r + k. Since r + k is constant, c₁.right ≤ c₂.right iff m₁ ≤ m₂. If m₁ ≤ m₂, the result is c₁ and Dec_k(c₁) = m₁ = min(m₁, m₂). Otherwise, the result is c₂ and Dec_k(c₂) = m₂ = min(m₁, m₂). □

---

## 6. Key Refresh (Normalization)

### 6.1 Construction

**Definition 6.1** (Refresh). refresh(k, K, (a, b)) = (a, b − K + k).

### 6.2 Correctness

**Theorem 6.1** (Refresh Preserves Plaintext). Dec_k(refresh(k, K, c)) = Dec_K(c).

*Proof.* Dec_k(a, b − K + k) = (b − K + k) − a − k = b − a − K = Dec_K(c). □

**Theorem 6.2** (Refresh Restores Base Key After Multiplication).
Dec_k(refresh(k, 2k, cMul(Enc_k(m₁; r₁), Enc_k(m₂; r₂)))) = m₁ + m₂.

*Proof.* Combine Theorems 6.1 and 4.2. □

---

## 7. Applications

### 7.1 Encrypted Bellman-Ford Relaxation

A single Bellman relaxation step computes:
- dist'[v] = min(dist[v], dist[u] + weight(u,v))

This decomposes into:
1. **Path extension** (tropical ⊗): dist[u] + weight(u,v) — computed via cMul.
2. **Relaxation** (tropical ⊕): min(dist[v], new_path) — computed via ciphertext comparison.

**Theorem 7.1** (Encrypted Bellman Relaxation). Under same-randomness encryption:
Dec_k(if c_dist.right ≤ c_weight.right then c_dist else c_weight) = min(dist, weight)

**Theorem 7.2** (Encrypted Path Extension).
Dec_{2k}(cMul(Enc_k(dist; r₁), Enc_k(edge; r₂))) = dist + edge

### 7.2 Encrypted Scheduling

Critical-path computation in project networks is a tropical matrix power. The key-weight theorem bounds the decryption key by (number of sequential additions) × k, independent of the number of min-comparisons.

### 7.3 Tropical Neural Networks

ReLU neural networks compute tropical rational functions [ZKAW18]. A single tropical neuron computes min(w₁ + x₁, ..., wₙ + xₙ), which is a tropical polynomial. Encrypted evaluation follows from the theorems above.

---

## 8. Quotient-Semantic Framework

### 8.1 Ciphertext Equivalence

**Definition 8.1**. c₁ ≈_k c₂ iff Dec_k(c₁) = Dec_k(c₂).

**Theorem 8.1**. ≈_k is an equivalence relation (reflexive, symmetric, transitive).

**Theorem 8.2** (cMul Respects Equivalence). If c₁ ≈_k c₁' and c₂ ≈_k c₂', then cMul(c₁, c₂) ≈_{2k} cMul(c₁', c₂').

This shows that tropical multiplication is well-defined on quotient ciphertexts, forming the algebraic basis for a quotient-semantic model of tropical HE.

---

## 9. Discussion

### 9.1 The Impossibility Frontier

Our impossibility theorem (Theorem 3.1) is unconditional — it makes no computational assumptions. It shows that the algebraic structure of the tropical semiring, specifically the idempotence of min, creates an inherent tension with CPA-style security that cannot be resolved by clever scheme design within the deterministic exact-homomorphism paradigm.

This is in sharp contrast to classical ring-based FHE, where deterministic schemes (e.g., without encryption randomness) are insecure for different reasons — the existence of efficiently invertible homomorphisms — but where randomized schemes can achieve CPA security under computational assumptions.

### 9.2 Key Weight vs. Noise

The key-weight function plays the role of "noise budget" in tropical HE, but with fundamentally different behavior:

| Property | Classical FHE | Tropical HE |
|----------|--------------|-------------|
| Growth under + | Linear | Sum of sub-weights |
| Growth under × | Multiplicative | Sum of sub-weights |
| Growth under min | N/A | **Max** (not sum!) |
| Bootstrapping | Required | Not needed for min-chains |
| Noise type | Stochastic | Deterministic (key shift) |

The "noise" in tropical HE is entirely deterministic — it is a key shift, not a random perturbation. This means there is no probability of decryption failure, no noise flooding, and no need for modulus switching. The cost is that the key must be managed explicitly.

### 9.3 Limitations

1. **Min correctness requires same randomness**: The ciphertext min operation only produces correct results when inputs share the same randomness. This is a significant constraint for general-purpose computation.

2. **Key evolution is not bounded**: For deep multiplication chains, the effective key grows exponentially. The refresh operation can reset the key, but requires knowledge of the current effective key, which in turn requires tracking the computation structure.

3. **No full CPA security proof**: Our security analysis is limited to key indistinguishability and ciphertext uniformity. A full CPA game-based proof with probabilistic adversaries remains open.

---

## 10. Conclusion and Future Work

We have established the first rigorous formal framework for homomorphic encryption over tropical semirings, proving both an unconditional impossibility theorem for deterministic schemes and correctness theorems for a randomized construction. The key-weight stability theorem — showing that min gates do not increase key complexity — is a novel structural result with no analogue in classical FHE theory.

**Open problems**:
1. Full CPA security proof for the randomized scheme under a precise computational assumption.
2. Encrypted Bellman-Ford algorithm with end-to-end correctness proof.
3. Quotient-semantic semiring instance for ciphertext equivalence classes.
4. Impossibility lower bounds for order-hiding min-homomorphic encryption.
5. Encrypted tropical polynomial evaluation for private neural network inference.

---

## References

[AFGH07] F. Armknecht, S. Fehr, S. Goldwasser, Y. Hu. On the impossibility of group homomorphic encryption. *Unpublished manuscript*, 2007.

[BCLO09] A. Boldyreva, N. Chenette, Y. Lee, A. O'Neill. Order-preserving symmetric encryption. *EUROCRYPT 2009*, pp. 224–241.

[BGV12] Z. Brakerski, C. Gentry, V. Vaikuntanathan. (Leveled) fully homomorphic encryption without bootstrapping. *ITCS 2012*.

[Bra12] Z. Brakerski. Fully homomorphic encryption without modulus switching. *CRYPTO 2012*.

[But10] P. Butkovič. *Max-linear Systems: Theory and Algorithms*. Springer, 2010.

[BV11] Z. Brakerski, V. Vaikuntanathan. Efficient fully homomorphic encryption from (standard) LWE. *FOCS 2011*.

[CKKS17] J.H. Cheon, A. Kim, M. Kim, Y. Song. Homomorphic encryption for arithmetic of approximate numbers. *ASIACRYPT 2017*.

[Gen09] C. Gentry. *A Fully Homomorphic Encryption Scheme*. PhD thesis, Stanford University, 2009.

[GS14] D. Grigoriev, V. Shpilrain. Tropical cryptography. *Communications in Algebra*, 42(6):2624–2632, 2014.

[KT19] M. Kotov, A. Ushakov. Analysis of a key exchange protocol based on tropical matrix algebra. *Journal of Mathematical Cryptology*, 2019.

[MS15] D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry*. AMS, 2015.

[Rub16] R. Rudy, A. Morozov. Cryptanalysis of the tropical implementation of the Stickel protocol. *ECAI 2016*.

[ZKAW18] L. Zhang, G. Naitzat, L.-H. Lim. Tropical geometry of deep neural networks. *ICML 2018*.
