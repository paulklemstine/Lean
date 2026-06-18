# Future Directions: Tropical Homomorphic Encryption

## 1. Formal CPA Game Semantics with Probabilistic Ciphertext Distributions

**Target Theorem**: Define a full IND-CPA security game in Lean using probability monads, where the adversary interacts with either a real or ideal tropical encryption oracle.

**Hypothesis**: The randomized tropical masking scheme `tropEnc k m r` achieves IND-CPA security when `r` is drawn uniformly from a sufficiently large interval `[-B, B]`, and the key `k` is secret. The key insight is that `(r, m + r + k)` forms a one-time pad in the `left` component, and the `right` component is computationally indistinguishable from uniform without knowledge of `k`.

**Proof Strategy**:
1. Formalize `PMF`-based encryption oracles over `TropCipher`.
2. Define the IND-CPA advantage as `|Pr[A(Enc(m₀)) = 1] - Pr[A(Enc(m₁)) = 1]|`.
3. Prove that for uniform `r`, the advantage is zero (information-theoretic security for single queries).
4. For multi-query security, introduce a PRF-based key schedule and reduce to PRF advantage.

**Cross-Domain Connection**: This connects tropical cryptography to the broader theory of provable security and would be the first formal IND-CPA proof for any idempotent-semiring-based scheme.

---

## 2. Encrypted Shortest-Path / Bellman-Ford Correctness over Tropical Ciphertexts

**Target Theorem**:
```
theorem encrypted_bellman_ford_correct (G : WeightedDigraph n) (s : Fin n)
    (k : ℤ) (r : Fin n → ℤ) :
    ∀ v, tropDec (n * k) (encryptedBellmanFord G s k r v) = shortestPathDist G s v
```

**Hypothesis**: Running Bellman-Ford on encrypted edge weights (using `tropCMul` for path extension and ciphertext min-selection for relaxation) produces encrypted shortest-path distances that decrypt correctly under key `n * k`, where `n` is the number of relaxation rounds.

**Proof Strategy**:
1. Define `WeightedDigraph` and `shortestPathDist` using tropical matrix powers.
2. Define `encryptedBellmanFord` using `tropCMul` and ciphertext min-selection.
3. Prove correctness by induction on relaxation rounds, using `evalCipher_correct_tminFree` for the path-extension steps and `evalCipher_tmin_same_randomness` for relaxation steps (under uniform-randomness assumption).
4. The key-weight bound `n * k` follows from the graph having at most `n` edges in any shortest path.

**Cross-Domain Connection**: This would be the first formally verified privacy-preserving shortest-path algorithm, connecting tropical cryptography to secure multi-party computation for network routing and logistics optimization.

---

## 3. Quotient-Semantic Tropical Semiring Instances for Ciphertext Classes

**Target Theorem**:
```
instance : Semiring (Quotient (tropCipherSetoid k)) where
  add := quotient_trop_min k
  mul := quotient_trop_mul k
  ...
```

**Hypothesis**: The quotient `TropCipher / ≈_k` (where `c₁ ≈_k c₂ ↔ tropDec k c₁ = tropDec k c₂`) forms a semiring isomorphic to `(ℤ, min, +)` under the induced operations. This is the correct algebraic framework for tropical HE: the encryption is a semiring homomorphism from plaintexts to quotient ciphertexts.

**Proof Strategy**:
1. Use `tropCipherEquiv_equiv` (already proved) to construct the `Setoid`.
2. Lift `tropCMul` to the quotient using `tropCMul_respects_equiv` (already proved).
3. Define the quotient `min` operation (requires the same-randomness condition or a canonical section).
4. Verify semiring axioms (associativity, commutativity, distributivity, identity).
5. Construct the isomorphism `Quotient ≅ ℤ` via `tropDec`.

**Cross-Domain Connection**: This connects to abstract algebra and category theory — the encryption becomes a morphism of semiring objects, unifying the algebraic and cryptographic perspectives.

---

## 4. Lower Bounds: Which Semiring-Homomorphic Security Notions Are Impossible?

**Target Theorem**:
```
theorem no_order_hiding_min_hom {C : Type} [LinearOrder C]
    (Enc : ℤ → C) (hmin : ∀ a b, Enc (min a b) = min (Enc a) (Enc b))
    (hinj : Injective Enc) :
    StrictMono Enc ∨ StrictAnti Enc
```

**Hypothesis**: Any injective function from a linearly ordered set to a linearly ordered set that preserves `min` must be order-preserving. Combined with our impossibility theorem (`tropical_det_hom_injective`), this shows that deterministic tropical HE necessarily leaks the complete plaintext ordering — a much stronger impossibility than mere distinguishability.

**Proof Strategy**:
1. Prove that min-preserving injections between linear orders are monotone.
2. Extend to show that min-and-plus preserving maps are affine (i.e., `Enc(m) = m + c` for some constant `c`).
3. This would establish that the ONLY deterministic exact tropical homomorphic encryption is a shift cipher, which is trivially breakable.

**Cross-Domain Connection**: This connects to lattice theory and order-preserving encryption (OPE), establishing tropical HE impossibility as a special case of the well-known OPE leakage problem.

---

## 5. Tropical Polynomial Evaluation on Encrypted Inputs with Polyhedral Decision Extraction

**Target Theorem**:
```
theorem encrypted_tropical_poly_eval_correct
    (p : TropicalPolynomial n) (k : ℤ) (x : Fin n → ℤ) (r : Fin n → ℤ) :
    tropDec (p.degree * k) (evalEncrypted p k x r) = evalPlain p x
```

**Hypothesis**: Tropical polynomials (finite min-sums of affine functions) can be evaluated homomorphically on encrypted inputs. The key weight equals the polynomial's degree (maximum number of variable additions in any monomial). Since tropical polynomial evaluation defines piecewise-linear functions, this enables encrypted computation of polyhedral decision boundaries.

**Proof Strategy**:
1. Define `TropicalPolynomial` as a formal sum `⊕_α (c_α ⊗ x^α)` where exponents are multi-indices.
2. Reduce to `TropExpr` evaluation using the existing `evalCipher_correct_tminFree` and `evalCipher_tmin_same_randomness`.
3. Prove the degree bound on key weight by structural analysis of the polynomial.
4. Connect to tropical hypersurface theory: the locus where the minimum is achieved by two or more monomials defines a polyhedral complex, and this structure is preserved under encryption.

**Cross-Domain Connection**: This bridges tropical geometry and privacy-preserving machine learning. Tropical polynomials define ReLU neural network decision boundaries (Zhang et al., 2018). Encrypted tropical polynomial evaluation would enable private inference on tropical neural networks — a concrete application of tropical cryptography to AI safety.

---

## Research Team Directive

Each direction above should be pursued by a team that:
1. **States precise conjectures** as Lean theorem signatures with `sorry`.
2. **Validates computationally** using `#eval` with concrete examples before attempting formal proofs.
3. **Decomposes aggressively** — no theorem should require more than 50 lines of proof.
4. **Cross-references** the existing verified theorems (`tropical_det_hom_injective`, `evalCipher_correct_tminFree`, `tropCMul_respects_equiv`, etc.) as building blocks.
5. **Documents impossibility results** as carefully as positive constructions — the impossibility frontier is the most original contribution of this research program.

Priority ordering: Direction 4 (lower bounds) and Direction 2 (Bellman-Ford) are most likely to yield breakthroughs in the next cycle. Direction 1 (CPA games) requires probabilistic Lean infrastructure that may need to be built from scratch. Direction 3 (quotient semiring) is algebraically clean but may encounter Lean `Quotient` API friction. Direction 5 (tropical polynomials) is the most ambitious and should be attempted after Directions 2-4 are established.
