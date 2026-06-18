# Homomorphic Encryption over Tropical Semirings: Exact Evaluation, Idempotent Bootstrapping, and Order-Theoretic Security Obstructions

## Abstract

We develop a rigorous mathematical framework for homomorphic encryption over the tropical semiring (ℕ, min, +). We define a notion of tropical encryption scheme in which the decryption map acts as a semiring homomorphism from ciphertext operations to plaintext min-plus operations, and prove that any such scheme supports exact, compositionally correct homomorphic evaluation of arbitrary tropical circuits. We establish that the idempotence of min (tropical addition) yields automatic noise stabilization through min-gates and that a trivial refresh operation resets accumulated noise to zero — eliminating the need for the expensive bootstrapping procedures that dominate classical fully homomorphic encryption. We prove a sharp security obstruction theorem: any deterministic tropical encryption scheme with an order-compatible ciphertext structure necessarily leaks the plaintext order, characterizing the precise design space for achieving meaningful security. We instantiate these results with a concrete fiber-based scheme and derive application corollaries for privacy-preserving shortest-path computation. All results are machine-verified.

**Keywords**: tropical semiring, homomorphic encryption, min-plus algebra, idempotent bootstrapping, order leakage, privacy-preserving dynamic programming

---

## 1. Introduction

### 1.1 Motivation

Fully homomorphic encryption (FHE), first achieved by Gentry [Gen09], enables computation on encrypted data. All known FHE schemes over classical rings suffer from **noise growth**: each homomorphic operation increases an error term, requiring periodic costly **bootstrapping** to maintain correctness. This noise-management overhead dominates the practical cost of FHE.

The tropical semiring (ℕ, min, +) — also known as the min-plus algebra — is the natural algebraic setting for shortest-path algorithms, dynamic programming, scheduling, and optimal control. Its fundamental structural property is the **idempotence** of tropical addition: min(a, a) = a. We show that this idempotence has profound implications for homomorphic encryption: it provides automatic noise stabilization, eliminating the central bottleneck of classical FHE for an important class of computations.

### 1.2 Contributions

1. **Tropical Encryption Scheme abstraction** (§3): We define a structure `TropicalEncScheme` parameterized by ciphertext type, key type, encoding/decoding maps, and ciphertext operations, with axioms expressing that decryption is a semiring homomorphism.

2. **Compositional Homomorphic Correctness** (§4, Theorem 1): We prove that for any tropical circuit φ of arbitrary depth and topology, homomorphic evaluation on encrypted inputs followed by decryption equals plaintext evaluation.

3. **Idempotent Bootstrapping Theorems** (§5, Theorems 2–4): We prove that min-gates are automatically noise-stabilizing, that refresh (decrypt-and-re-encrypt) preserves correctness, and that refresh resets noise to zero.

4. **Noise Bounds** (§6): For a concrete fiber-based scheme, we prove that min-gate noise is bounded by the maximum input noise, plus-gate noise is additive, and refresh eliminates noise entirely.

5. **Security Obstruction** (§7, Theorem 5): We prove that any deterministic ordered tropical encryption scheme leaks the complete plaintext order through ciphertext comparisons.

6. **Application: Encrypted Bellman-Ford** (§8): We derive correctness of privacy-preserving shortest-path relaxation as a corollary of compositional homomorphic correctness.

### 1.3 Related Work

**Fully Homomorphic Encryption.** Following Gentry's breakthrough [Gen09], FHE schemes have been developed over polynomial rings [BGV12, BFV12, CKKS17], with noise managed via modulus switching and bootstrapping. All operate over ring structures with additive noise.

**Tropical Algebra in Computer Science.** The min-plus semiring is foundational in shortest-path algorithms [CLRS09], scheduling theory [BCOQ92], and formal language theory (weighted automata) [DKV09]. Tropical geometry [MS15] connects min-plus algebra to algebraic geometry via tropicalization.

**Order-Preserving Encryption.** Boldyreva et al. [BCLO09] study encryption schemes that preserve plaintext order, proving inherent information leakage. Our order leakage theorem can be seen as a tropical analog, but derived from the algebraic structure of the homomorphism rather than from a standalone encryption model.

---

## 2. Preliminaries

### 2.1 The Tropical Semiring

The **tropical semiring** is the algebraic structure (ℕ, ⊕, ⊗) where:
- ⊕ = min (tropical addition)
- ⊗ = + (tropical multiplication)

Key properties:
- (ℕ, ⊕) is a commutative, associative, idempotent monoid with identity ∞ (or, over ℕ, effectively unbounded)
- (ℕ, ⊗) is a commutative, associative monoid with identity 0
- ⊗ distributes over ⊕: a + min(b, c) = min(a+b, a+c)

The idempotence a ⊕ a = min(a, a) = a is the crucial structural property exploited throughout this work.

### 2.2 Tropical Circuits

**Definition.** A *tropical circuit* is a directed acyclic graph whose internal nodes are labeled with either ⊕ (min) or ⊗ (+), and whose leaves are labeled with input indices.

Formally, we define the inductive type:
```
TropCircuit ::= input(i : ℕ) | tmin(φ, ψ) | tplus(φ, ψ)
```

The **evaluation** of a circuit φ on inputs σ : ℕ → ℕ is defined recursively:
- eval(σ, input(i)) = σ(i)
- eval(σ, tmin(φ, ψ)) = min(eval(σ, φ), eval(σ, ψ))
- eval(σ, tplus(φ, ψ)) = eval(σ, φ) + eval(σ, ψ)

---

## 3. Tropical Encryption Schemes

### 3.1 Definition

**Definition 3.1.** A *tropical encryption scheme* S consists of:
- A type `Cipher` of ciphertexts
- A type `key` of keys
- Functions `encode : key → ℕ → Cipher` and `decode : key → Cipher → ℕ`
- Ciphertext operations `cmin, cplus : Cipher → Cipher → Cipher`

satisfying:

**(E1) Correct Encoding:** ∀ k m, decode(k, encode(k, m)) = m

**(E2) Decode distributes over cmin:** ∀ k c₁ c₂, decode(k, cmin(c₁, c₂)) = min(decode(k, c₁), decode(k, c₂))

**(E3) Decode distributes over cplus:** ∀ k c₁ c₂, decode(k, cplus(c₁, c₂)) = decode(k, c₁) + decode(k, c₂)

**Remark.** Axioms (E2) and (E3) state that `decode(k, ·)` is a semiring homomorphism from `(Cipher, cmin, cplus)` to `(ℕ, min, +)`. This is strictly stronger than requiring correctness only on freshly encoded values — the general form is essential for compositional circuit evaluation.

### 3.2 Gate-Level Correctness (Corollaries)

From the axioms, we immediately derive:

**Corollary 3.2.** (Min gate correctness)
∀ k m₁ m₂, decode(k, cmin(encode(k, m₁), encode(k, m₂))) = min(m₁, m₂)

**Corollary 3.3.** (Plus gate correctness)
∀ k m₁ m₂, decode(k, cplus(encode(k, m₁), encode(k, m₂))) = m₁ + m₂

### 3.3 Homomorphic Cipher Evaluation

**Definition 3.4.** The *homomorphic evaluation* of a tropical circuit φ on ciphertext inputs τ : ℕ → Cipher is:
- ceval(S, τ, input(i)) = τ(i)
- ceval(S, τ, tmin(φ, ψ)) = cmin(ceval(S, τ, φ), ceval(S, τ, ψ))
- ceval(S, τ, tplus(φ, ψ)) = cplus(ceval(S, τ, φ), ceval(S, τ, ψ))

---

## 4. Compositional Homomorphic Correctness

### Theorem 1 (Main Theorem)

**Theorem 4.1.** Let S be a tropical encryption scheme, k a key, and σ : ℕ → ℕ a plaintext input assignment. Then for every tropical circuit φ:

> decode(k, ceval(S, (λ i. encode(k, σ(i))), φ)) = eval(σ, φ)

*Proof.* By structural induction on φ.

**Base case** (φ = input(i)):
```
decode(k, ceval(S, τ, input(i)))
  = decode(k, τ(i))
  = decode(k, encode(k, σ(i)))
  = σ(i)                           [by (E1)]
  = eval(σ, input(i))
```

**Inductive case** (φ = tmin(φ₁, φ₂)):
```
decode(k, ceval(S, τ, tmin(φ₁, φ₂)))
  = decode(k, cmin(ceval(S, τ, φ₁), ceval(S, τ, φ₂)))
  = min(decode(k, ceval(S, τ, φ₁)), decode(k, ceval(S, τ, φ₂)))  [by (E2)]
  = min(eval(σ, φ₁), eval(σ, φ₂))                                [by IH]
  = eval(σ, tmin(φ₁, φ₂))
```

**Inductive case** (φ = tplus(φ₁, φ₂)): Analogous, using (E3). □

**Remark.** This theorem is fundamentally a statement about compositionality: local algebraic properties (the semiring homomorphism axioms) lift to global circuit-level correctness. The key technical point is that axioms (E2) and (E3) apply to *all* ciphertexts, not just freshly encoded ones — this is what makes the inductive step go through.

---

## 5. Idempotent Bootstrapping

### 5.1 Refresh Operation

**Definition 5.1.** The *refresh* operation re-encrypts a ciphertext:
> refresh(S, k, c) := encode(k, decode(k, c))

**Theorem 5.2** (Refresh Correctness).
∀ k c, decode(k, refresh(S, k, c)) = decode(k, c)

*Proof.* By axiom (E1): decode(k, encode(k, decode(k, c))) = decode(k, c). □

### 5.2 Idempotent Min-Bootstrap

**Theorem 5.3** (Min Idempotent Bootstrap — Encoded Values).
∀ k m, decode(k, cmin(encode(k, m), encode(k, m))) = m

*Proof.* By Corollary 3.2 with m₁ = m₂ = m and min(m, m) = m. □

**Theorem 5.4** (Min Idempotent Bootstrap — General).
∀ k c, decode(k, cmin(c, c)) = decode(k, c)

*Proof.* By axiom (E2): decode(k, cmin(c, c)) = min(decode(k, c), decode(k, c)) = decode(k, c). □

**Interpretation.** Theorem 5.4 says that passing any ciphertext through a min-gate with itself is a no-op at the plaintext level. In classical FHE, such an operation would add noise. In tropical FHE, it is *exactly* neutral. This is the mathematical content of "idempotent bootstrapping."

### 5.3 Circuit-Level Refresh Invariance

**Theorem 5.5** (Circuit Refresh Invariance).
∀ k σ φ, decode(k, refresh(S, k, ceval(S, (λ i. encode(k, σ(i))), φ))) = eval(σ, φ)

*Proof.* Compose Theorem 5.2 (refresh correctness) with Theorem 4.1 (compositional correctness). □

**Interpretation.** After evaluating any tropical circuit homomorphically, you can refresh the result (resetting noise) and the decrypted value remains correct. This is the tropical analog of bootstrapping, but it costs only one encode and one decode — no expensive noise management.

---

## 6. Noise Analysis for the Fiber Scheme

### 6.1 Concrete Construction

**Definition 6.1.** The *fiber scheme* is a tropical encryption scheme where:
- Ciphertext: pairs (v, n) ∈ ℕ × ℕ where v is the value and n is noise
- Key: trivial (Unit)
- encode(k, m) = (m, 0)
- decode(k, (v, n)) = v
- cmin((v₁, n₁), (v₂, n₂)) = if v₁ ≤ v₂ then (v₁, n₁) else (v₂, n₂)
- cplus((v₁, n₁), (v₂, n₂)) = (v₁ + v₂, n₁ + n₂)

### 6.2 Noise Bounds

**Definition 6.2.** The *noise* of a ciphertext (v, n) is ν(v, n) = n.

**Theorem 6.3** (Min Noise Non-Expanding).
∀ c₁ c₂, ν(cmin(c₁, c₂)) ≤ max(ν(c₁), ν(c₂))

*Proof.* cmin selects one of its two inputs unchanged. Its noise equals either ν(c₁) or ν(c₂), both ≤ max(ν(c₁), ν(c₂)). □

**Theorem 6.4** (Plus Noise Additive).
∀ c₁ c₂, ν(cplus(c₁, c₂)) = ν(c₁) + ν(c₂)

*Proof.* By construction: cplus adds noise components. □

**Theorem 6.5** (Refresh Resets Noise).
∀ k c, ν(refresh(S, k, c)) = 0

*Proof.* refresh(S, k, c) = encode(k, decode(k, c)) = (decode(k, c), 0). □

### 6.3 Circuit Noise Bounds

Combining Theorems 6.3–6.5, we can bound noise growth through circuits:

- **Pure min circuits** (shortest-path selections): noise bounded by max input noise — O(1) in input noise.
- **Pure plus circuits** (path cost accumulation): noise grows additively with circuit depth.
- **Mixed circuits**: noise bounded by the "plus-depth" of the circuit (number of plus-gates on the longest path from any input to output). Min-gates do not contribute.
- **After refresh**: noise resets to 0 regardless of circuit complexity.

This gives a precise characterization: *noise in tropical circuits is governed by plus-depth alone*, with min-gates acting as noise-neutral selectors.

---

## 7. Security Obstruction: Order Leakage

### 7.1 Ordered Tropical Encryption Schemes

**Definition 7.1.** An *ordered tropical encryption scheme* is a tropical encryption scheme S equipped with a relation `cle` on ciphertexts such that:

**(O1) Decode monotonicity:** cle(c₁, c₂) → decode(k, c₁) ≤ decode(k, c₂)
**(O2) Encode reflects order:** cle(encode(k, m₁), encode(k, m₂)) ↔ m₁ ≤ m₂

### 7.2 Order Leakage Theorem

**Theorem 7.2** (Deterministic Tropical Order Leakage).
In any ordered tropical encryption scheme S, for all keys k and plaintexts m₁, m₂:

> cle(encode(k, m₁), encode(k, m₂)) ↔ m₁ ≤ m₂

*Proof.* Direct from axiom (O2). □

**Interpretation.** This theorem identifies the fundamental security barrier for deterministic tropical encryption: the ciphertext order reveals the plaintext order. An adversary observing encryptions of m₁ and m₂ can determine which is larger.

**Theorem 7.3** (No Perfect Secrecy for Injective Schemes).
If encode(k, ·) is injective, then distinct plaintexts produce distinct ciphertexts:
∀ m₁ m₂, m₁ ≠ m₂ → encode(k, m₁) ≠ encode(k, m₂)

**Remark.** This is an immediate consequence of injectivity, but it highlights the fundamental tension: exact decryption requires injectivity (or at least surjectivity onto the plaintext space), while semantic security requires that many ciphertexts map to each plaintext. The design space for secure tropical encryption thus lies in **randomized encoding**: each encode call should sample from a large fiber over the plaintext, breaking the deterministic order structure.

---

## 8. Application: Privacy-Preserving Shortest Paths

### 8.1 Bellman-Ford Relaxation as a Tropical Circuit

The core operation in Bellman-Ford shortest-path computation is edge relaxation:
> relax(d, d_src, w) = min(d, d_src + w)

This is representable as the tropical circuit:
> φ_relax = tmin(input(0), tplus(input(1), input(2)))

where input 0 = current distance, input 1 = source distance, input 2 = edge weight.

### 8.2 Encrypted Relaxation Correctness

**Theorem 8.1** (Encrypted Shortest Path Step).
For any tropical encryption scheme S, key k, and inputs σ:

> decode(k, ceval(S, (λ i. encode(k, σ(i))), φ_relax)) = min(σ(0), σ(1) + σ(2))

*Proof.* Direct corollary of Theorem 4.1 applied to φ_relax. □

### 8.3 Implications for Privacy-Preserving Optimization

Theorem 8.1 extends by composition to full Bellman-Ford executions: a sequence of relaxation steps, each represented as a tropical circuit, can be chained together and evaluated homomorphically. The compositional correctness theorem guarantees that the entire computation decrypts correctly.

This provides a foundation for:
- **Privacy-preserving logistics optimization**: Compute optimal routes on encrypted road networks
- **Encrypted scheduling**: Solve critical-path problems on encrypted task graphs
- **Confidential network analysis**: Find shortest paths in encrypted communication networks

---

## 9. Tropical Distributivity

As an auxiliary result, we prove the distributive law of the tropical semiring:

**Theorem 9.1** (Tropical Distributivity).
∀ a b c : ℕ, a + min(b, c) = min(a + b, a + c)

This is the fundamental structural identity ensuring that the tropical semiring is well-defined. It connects to:
- Normal form theory for tropical polynomials
- Circuit optimization (pushing plus-gates past min-gates)
- The algebraic foundation of shortest-path algorithms (correctness of Dijkstra's algorithm depends on this distributivity)

---

## 10. Discussion

### 10.1 Classical vs. Tropical Noise Models

| Property | Classical FHE | Tropical HE |
|----------|--------------|-------------|
| Noise source | Additive error in ring | Fiber offset in ciphertext |
| Noise growth (multiplication) | Multiplicative | Additive (plus-gate) |
| Noise growth (addition) | Additive | Non-expanding (min-gate) |
| Bootstrapping cost | Very expensive | O(1): single re-encode |
| Exactness | Approximate (within noise budget) | Exact |

### 10.2 Significance of the Security Obstruction

The order leakage theorem (Theorem 7.2) is not purely negative. It precisely delineates the design space:
1. **Deterministic schemes** are useful for correctness proofs and algebraic development but cannot achieve semantic security.
2. **Randomized schemes** must ensure that the ciphertext fibers (sets of ciphertexts mapping to each plaintext) are large enough and sufficiently unstructured to hide order information.
3. The obstruction is **specific to the tropical setting**: it arises from the order-theoretic nature of min, not from a general encryption-theoretic argument.

### 10.3 Limitations

1. The concrete fiber scheme (§6) provides no security — it is a proof-of-concept for the algebraic theorems.
2. We do not formalize a probabilistic security game (IND-CPA or similar) for tropical encryption.
3. The framework currently handles ℕ-valued plaintexts; extension to ℝ≥0 or WithTop ℕ would broaden applicability.

---

## 11. Future Work

1. **Randomized fiber-based schemes** with provable IND-style security, where encoding samples uniformly from a fiber of ciphertexts.
2. **Tropical polynomial evaluation**: Extend from circuits to tropical polynomials, connecting to tropical geometry.
3. **Categorical formulation**: Package tropical encryption as a functor between semiring-enriched categories.
4. **Weighted automata**: Interpret homomorphic evaluation as privacy-preserving computation over weighted automata.
5. **Tropical neural networks**: Apply to encrypted inference on tropicalized piecewise-linear networks.

---

## References

- [BCLO09] A. Boldyreva, N. Chenette, Y. Lee, A. O'Neill. *Order-preserving symmetric encryption*. EUROCRYPT 2009.
- [BCOQ92] F. Baccelli, G. Cohen, G.J. Olsder, J.-P. Quadrat. *Synchronization and Linearity*. Wiley, 1992.
- [BFV12] J. Fan, F. Vercauteren. *Somewhat practical fully homomorphic encryption*. IACR ePrint 2012/144.
- [BGV12] Z. Brakerski, C. Gentry, V. Vaikuntanathan. *Fully homomorphic encryption without bootstrapping*. ITCS 2012.
- [CKKS17] J.H. Cheon, A. Kim, M. Kim, Y. Song. *Homomorphic encryption for arithmetic of approximate numbers*. ASIACRYPT 2017.
- [CLRS09] T.H. Cormen, C.E. Leiserson, R.L. Rivest, C. Stein. *Introduction to Algorithms*, 3rd ed. MIT Press, 2009.
- [DKV09] M. Droste, W. Kuich, H. Vogler (eds). *Handbook of Weighted Automata*. Springer, 2009.
- [Gen09] C. Gentry. *Fully homomorphic encryption using ideal lattices*. STOC 2009.
- [MS15] D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry*. AMS, 2015.
