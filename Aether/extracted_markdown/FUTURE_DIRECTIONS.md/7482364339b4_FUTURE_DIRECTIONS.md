# Future Directions

## Overview

The formalization of cyclotomic subfield extraction via the cyclic Galois correspondence opens several concrete research directions. Each direction below includes a precise theorem statement, expected proof strategy, and cross-domain significance.

---

## 1. Order-Isomorphism Between Intermediate Fields and Divisors of p−1

### Theorem Statement

For an odd prime p, the lattice of intermediate fields of ℚ(ζ_p)/ℚ is order-isomorphic (via reverse inclusion) to the divisor poset of p−1.

```lean
theorem intermediateField_orderIso_divisors_prime_pred
  (p : ℕ) [Fact (Nat.Prime p)] (hpodd : p ≠ 2) :
  Nonempty (
    IntermediateField ℚ (CyclotomicField p ℚ) ≃o
    OrderDual {d : ℕ // d ∣ (p - 1)}
  )
```

### Proof Strategy

1. Use the Galois correspondence `IsGalois.intermediateFieldEquivSubgroup` to identify intermediate fields with subgroups of `Gal(ℚ(ζ_p)/ℚ)`.
2. Use `cyclic_group_unique_subgroup_of_card` to establish a bijection between subgroups and divisors.
3. Show that inclusion of subgroups corresponds to divisibility, and that the Galois correspondence reverses inclusion.
4. Compose these order isomorphisms.

### Cross-Domain Significance

- **Lattice theory**: Provides a concrete realization of divisor lattices as field extension lattices.
- **Computational algebra**: Enables algorithmic enumeration of all subfields of cyclotomic fields.
- **Class field theory**: The divisor lattice structure is the prototype for conductor-subfield relationships in abelian extensions.

---

## 2. Prime-Degree Subfield Iff Divisibility of p−1

### Theorem Statement

For primes p (odd) and q, there exists a degree-q subfield of ℚ(ζ_p) if and only if q | (p−1).

```lean
theorem exists_prime_degree_subfield_iff
  (p q : ℕ) [Fact (Nat.Prime p)] (hpodd : p ≠ 2) (hq : q.Prime) :
  (∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
      Module.finrank ℚ K = q) ↔ q ∣ (p - 1)
```

### Proof Strategy

- **Forward direction**: Given an intermediate field K of degree q (prime) over ℚ, the extension K/ℚ is separable (char 0). By the primitive element theorem, K = ℚ(α) for some α. Since K embeds into a Galois extension (ℚ(ζ_p)), the Galois group acts on K, and by degree counting, q must divide |Gal| = p−1. Alternatively, use `prime_degree_divides_galois_order`.
- **Reverse direction**: Direct application of `exists_intermediateField_prime_cyclotomic_finrank_eq`.

### Cross-Domain Significance

- **Number theory**: Provides an arithmetic criterion for when prime-degree extensions can be realized inside cyclotomic fields — directly related to the Kronecker–Weber theorem.
- **Cryptography**: In pairing-based cryptography, the existence of specific-degree subfields controls embedding degree calculations.

---

## 3. General Cyclic Galois Extension Uniqueness-by-Degree Theorem

### Theorem Statement

In any finite cyclic Galois extension L/K, for every divisor d of [L:K], there exists a unique intermediate field of degree d over K.

```lean
theorem unique_intermediateField_of_finrank_in_cyclic_galois_extension
  (K L : Type*) [Field K] [Field L] [Algebra K L]
  [FiniteDimensional K L]
  (hgal : IsGalois K L)
  (hcyc : IsCyclic (L ≃ₐ[K] L))
  (d : ℕ)
  (hd : d ∣ Module.finrank K L) :
  ∃! E : IntermediateField K L, Module.finrank K E = d
```

### Proof Strategy

1. Use `IsGalois.intermediateFieldEquivSubgroup` for the bijection between intermediate fields and subgroups.
2. Apply `cyclic_group_unique_subgroup_of_card` to the cyclic Galois group.
3. Show that the Galois correspondence converts cardinality of subgroups to finrank of intermediate fields via the tower law.

### Cross-Domain Significance

- **Algebra**: This is the definitive structural theorem for cyclic Galois extensions, generalizing our cyclotomic results.
- **Algebraic geometry**: Cyclic covers of curves are classified by their intermediate fields; this theorem provides the formal backbone.

---

## 4. Explicit Real Subfield via ζ_p + ζ_p⁻¹

### Theorem Statement

The maximal real subfield of ℚ(ζ_p) is ℚ(ζ_p + ζ_p⁻¹), and it has degree (p−1)/2 over ℚ.

```lean
theorem maximal_real_subfield_cyclotomic (p : ℕ) [Fact (Nat.Prime p)] (hpodd : p ≠ 2) :
  ∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
    Module.finrank ℚ K = (p - 1) / 2 ∧
    ∀ x : K, (algebraMap K (CyclotomicField p ℚ) x) =
      starRingEnd (CyclotomicField p ℚ) (algebraMap K (CyclotomicField p ℚ) x)
```

### Proof Strategy

1. The complex conjugation on ℚ(ζ_p) generates a subgroup of order 2 in the Galois group (sending ζ_p to ζ_p⁻¹).
2. The fixed field of this subgroup is the maximal totally real subfield.
3. By the Galois correspondence, its degree over ℚ is |Gal|/2 = (p−1)/2.
4. Show that ζ_p + ζ_p⁻¹ generates this fixed field.

### Cross-Domain Significance

- **Number theory**: The maximal real subfield controls the class number of ℚ(ζ_p) via Kummer's theorem and Vandiver's conjecture.
- **Explicit constructions**: Gauss periods and explicit generators of intermediate fields are built from ζ_p + ζ_p⁻¹.

---

## 5. Cryptographic Bridge: Subgroup Hardness from Cyclotomic Towers

### Theorem Statement (Conceptual)

The subgroup structure of (ℤ/pℤ)× determines the lattice of intermediate fields in ℚ(ζ_p)/ℚ. Each subgroup of index d corresponds to a degree-d extension, and the discrete logarithm problem in the index-d subgroup is at least as hard as in the full group (by Pohlig–Hellman reduction).

```lean
-- Formalization target: show that the Pohlig-Hellman decomposition
-- respects the cyclotomic subfield tower
theorem pohlig_hellman_subgroup_tower (p : ℕ) [Fact (Nat.Prime p)] (hpodd : p ≠ 2)
    (q : ℕ) (hq : q.Prime) (hqdvd : q ∣ (p - 1)) :
    ∃ (H : Subgroup (ZMod p)ˣ),
      Nat.card H = q ∧
      ∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
        Module.finrank ℚ K = (p - 1) / q
```

### Proof Strategy

1. From the subgroup existence theorem, extract the unique subgroup of (ℤ/pℤ)× of order q.
2. Transport through the Galois isomorphism to a subgroup of Gal.
3. Apply the fixed field construction to get the corresponding intermediate field of degree (p−1)/q.

### Cross-Domain Significance

- **Cryptography**: The Pohlig–Hellman algorithm decomposes the DLP into prime-order subgroup problems. Formalizing this bridge connects:
  - algebraic structure (subgroup lattice) with
  - computational hardness (DLP in subgroups) and
  - field-theoretic structure (intermediate fields).
- **Post-quantum cryptography**: Understanding the algebraic structure of cyclotomic fields is essential for analyzing lattice-based cryptographic constructions (e.g., Ring-LWE over cyclotomic number fields).
- **Verified security**: A certified subgroup-subfield dictionary enables formal security proofs for protocols built on the algebraic structure of finite fields.
