# Future Directions: Tropical Cryptography

This document outlines five breakthrough-level research directions opened by the
row-separated injectivity theorem for tropical (min-plus) matrix–vector products.

---

## 1. Tropical Trapdoor Functions via Hidden Active-Minimizer Patterns

**Goal.** Construct a trapdoor one-way function where the forward map is a
tropical matrix–vector product and the trapdoor is the hidden permutation σ.

**Theorem target.**

> Let `A` be a random row-separated tropical matrix with hidden designated
> permutation σ and separation δ. Define `Enc(x) = T_A(x)`. Then:
> - **Forward evaluation** is O(n²) (min-plus product).
> - **Inversion with σ** is O(n) (affine readout followed by permutation).
> - **Inversion without σ** requires solving a combinatorial argmin
>   reconstruction problem that is NP-hard in general (or at least
>   exponential in n under plausible worst-case assumptions).

**Proof strategy.**
- Use the row rigidity theorem to show that decryption with the trapdoor is
  simply `x[j] = ct[σ⁻¹(j)] − A[σ⁻¹(j), j]`.
- Reduce inversion-without-trapdoor to the Tropical Assignment Problem or to
  finding the active cell in a tropical hyperplane arrangement, both of which
  are known to be computationally hard in general.
- Formalize the reduction in the proof assistant.

**Cross-domain connections.**
- Lattice-based cryptography: tropical matrices over ℤ with bounded entries
  resemble LWE-type constructions, with min replacing addition modulo q.
- Polyhedral geometry: the complexity of inversion relates to the facial
  structure of tropical polytopes.

---

## 2. Entropy Lower Bounds for Random Separated Tropical Matrices

**Goal.** Prove that a randomly generated row-separated tropical matrix
preserves or amplifies min-entropy when applied to a message distribution.

**Theorem target.**

> Let `A` be drawn uniformly from the set of n×n matrices with separation
> parameter δ and a uniformly random permutation σ. Let X be a random
> variable on Fin(n)→ℝ with bounded oscillation and min-entropy at least k.
> Then with high probability over A:
>
>   H_∞(T_A(X)) ≥ k − O(log n)

**Proof strategy.**
- The injectivity theorem guarantees that T_A is injective on the
  bounded-oscillation domain, so the image has the same cardinality.
- Injectivity directly implies min-entropy is preserved for discrete
  distributions (already proved as `card_range_of_injective_encoding`).
- For continuous distributions, formalize the change-of-variables formula
  for the piecewise-affine tropical map and bound the Jacobian.
- Connect to the Leftover Hash Lemma: if entropy is preserved, key
  derivation via universal hashing produces cryptographically secure keys.

**Key lemma to formalize.**

```
theorem tropical_entropy_preservation
    {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ)
    (σ : Equiv (Fin n) (Fin n))
    (δ : ℝ) (hδ : 0 ≤ δ)
    (hsep : RowSeparated A σ δ)
    {S : Finset (Fin n → ℝ)}
    (hS : ∀ x ∈ S, BoundedOscillation δ x) :
    (S.image (tropicalMatVec A)).card = S.card
```

---

## 3. Tropical Hash Families with Collision Bounds

**Goal.** Define a family of tropical hash functions and prove collision
resistance under the row-separation condition.

**Construction.**
- **Key space:** n×m matrices A with random row separations (m < n for compression).
- **Hash function:** H_A(x) = T_A(x) (project n-dimensional input to m dimensions).
- **Collision:** Two inputs x ≠ y with H_A(x) = H_A(y).

**Theorem target.**

> For any two distinct bounded-oscillation vectors x ≠ y, the probability
> over random separated matrices A that T_A(x) = T_A(y) is at most 2^{−Ω(δ·m)}.

**Proof strategy.**
- When σ is injective (m ≥ n), the injectivity theorem directly gives
  zero collision probability.
- For compression (m < n), collision requires that the projections of x and
  y through σ agree on all m coordinates. Analyze this probabilistically
  over random σ.
- The separation parameter δ controls the size of the "rigidity basin,"
  and larger δ means fewer accidental collisions from oscillation violations.

**Cross-domain connections.**
- Coding theory: the row-separation condition is analogous to minimum
  distance in error-correcting codes. Tropical hash families are tropical
  analogues of linear codes over the min-plus semiring.
- Lattice hashing: parallels SIS-based hash functions where collision
  resistance reduces to a lattice problem.

---

## 4. Quantum Query Model for Tropical Inversion

**Goal.** Formalize a quantum query lower bound for inverting tropical
matrix–vector products, establishing post-quantum security.

**Theorem target.**

> Any quantum algorithm making Q queries to the entries of a row-separated
> tropical matrix A requires Q = Ω(√n) queries to recover x from T_A(x),
> even when the row separation and bounded oscillation are publicly known.

**Proof strategy.**
- Model the problem as an unstructured search for the active minimizer
  pattern σ among n! permutations.
- Apply the Grover lower bound (already formalized as
  `post_quantum_grover_lower_bound`): quantum search over N items
  requires Ω(√N) queries.
- The key insight is that without knowing σ, each row of the output
  gives one equation with n unknowns; the quantum adversary must
  identify which column was active in each row.
- Formalize the reduction from tropical inversion to unstructured
  search, then apply the Grover bound.

**Key formalization.**

```
theorem quantum_tropical_inversion_lower_bound
    {n : ℕ} (hn : 2 ≤ n)
    (Q : ℕ)
    (hQ : Q < Nat.sqrt (Nat.factorial n)) :
    ¬ ∃ (algorithm : QuantumOracle n → Fin n → ℝ),
      ∀ A σ δ x, RowSeparated A σ δ → BoundedOscillation δ x →
        algorithm (oracleOf A) (tropicalMatVec A x) = x
```

---

## 5. Tropical Key Encapsulation from Row-Separated Matrices

**Goal.** Design and formalize a complete Key Encapsulation Mechanism (KEM)
based on tropical matrix action, with provable IND-CPA security.

**Construction.**
- **Key generation:** Sample a random permutation σ and separation δ.
  Build a row-separated matrix A. Public key = A. Secret key = σ.
- **Encapsulation:** Sample a random bounded-oscillation vector x.
  Compute ciphertext c = T_A(x). Derive shared key K = Hash(x).
- **Decapsulation:** Using σ, recover x from c via the affine readout
  formula: x[j] = c[σ⁻¹(j)] − A[σ⁻¹(j), j]. Compute K = Hash(x).

**Security proof outline.**
1. **Correctness** follows directly from the row rigidity theorem.
2. **IND-CPA security** reduces to the hardness of recovering σ from A
   (the Tropical Assignment Problem).
3. **Post-quantum security** follows from the quantum query lower bound
   (Direction 4) applied to the permutation recovery problem.

**Theorem target.**

```
theorem tropical_KEM_correctness
    {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ)
    (σ : Equiv (Fin n) (Fin n))
    (δ : ℝ) (hδ : 0 ≤ δ)
    (hsep : RowSeparated A σ δ)
    (x : Fin n → ℝ)
    (hosc : BoundedOscillation δ x) :
    (fun j => (tropicalMatVec A x) (σ.symm j) - A (σ.symm j) j) = x
```

**Cross-domain connections.**
- NIST post-quantum standards: tropical KEMs would be a new family
  alongside lattice-based (Kyber), code-based (Classic McEliece),
  and isogeny-based schemes.
- Neural network verification: the piecewise-linear structure of
  tropical KEMs parallels ReLU network analysis, suggesting shared
  verification tools.

---

## Summary: Research Roadmap

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Trapdoor functions | Medium | High | Row rigidity theorem ✓ |
| 2. Entropy bounds | Medium | High | Injectivity theorem ✓, card preservation ✓ |
| 3. Hash families | Medium–Hard | Very High | Probabilistic analysis |
| 4. Quantum lower bounds | Hard | Very High | Grover bound ✓ |
| 5. KEM construction | Hard | Transformative | Directions 1–4 |

The row rigidity and injectivity theorems (formally verified in this work)
are the foundation upon which all five directions build. Each direction is
independently publishable and collectively they constitute a new subfield:
**formal tropical cryptography**.
