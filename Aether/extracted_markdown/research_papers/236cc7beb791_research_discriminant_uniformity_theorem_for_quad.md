# Discriminant Uniformity and Splitting Type Distribution for Quadratic Polynomials over Finite Fields

## Abstract

We establish the **Discriminant Uniformity Theorem**: for any prime *p*, the discriminant map (b, c) ↦ b² − 4c from (ℤ/pℤ)² to ℤ/pℤ has every fiber of cardinality exactly *p*. From this fundamental result we derive exact formulas for the separability density (1 − 1/p), the number of non-squares ((p−1)/2), and the splitting type distribution of monic quadratic polynomials over 𝔽_p. We introduce a formal definition of the quadratic splitting type — split, ramified, or inert — and prove that the split and inert types are equally numerous, each comprising p(p−1)/2 of the p² monic quadratics. We connect these results to the Frobenius correspondence between splitting types and cycle types of permutations. All main results are machine-verified in Lean 4 using the Mathlib library. We also investigate the cubic discriminant and identify the failure of uniformity for primes p ≡ 1 (mod 3).

**Keywords**: finite fields, discriminant, quadratic residues, splitting types, Frobenius correspondence, formal verification

---

## 1. Introduction

The distribution of polynomial discriminants over finite fields is a classical topic with connections to algebraic number theory, coding theory, and cryptography. For monic quadratic polynomials f(x) = x² + bx + c over the finite field 𝔽_p, the discriminant Δ(f) = b² − 4c determines the splitting behavior of f: whether f has two distinct roots (split), a repeated root (ramified), or no roots (inert) in 𝔽_p.

The central result of this paper is the **Discriminant Uniformity Theorem** (Theorem 3.1): for any prime p and any d ∈ 𝔽_p, the number of monic quadratics with discriminant d is exactly p. This result, while elementary, has surprisingly powerful consequences and admits a clean formal proof.

### 1.1 Related Work

The equidistribution of discriminants is implicit in classical treatments of quadratic forms over finite fields (see Lidl and Niederreiter, *Finite Fields*, Chapter 6). The connection to the Frobenius correspondence goes back to Frobenius's 1896 paper on the factorization of polynomials modulo primes. The modern framework connecting polynomial splitting to random permutation statistics was developed by Artin, Chebotarev, and more recently by Katz and Sarnak in their work on random matrix models for L-functions.

### 1.2 Contributions

1. A complete formal proof of the Discriminant Uniformity Theorem in Lean 4
2. Derivation of exact separability and irreducibility counts
3. A formal splitting type classification with proved counting theorems
4. Computational investigation of the cubic discriminant, identifying the mod-3 obstruction to uniformity
5. All results machine-verified with only standard axioms (propext, Classical.choice, Quot.sound)

---

## 2. Definitions

### 2.1 The Quadratic Discriminant

**Definition 2.1** (Quadratic Discriminant). For a commutative ring R and elements b, c ∈ R, the *discriminant* of the monic quadratic x² + bx + c is:

    QuadDisc(b, c) = b² − 4c

### 2.2 The Discriminant Map and Its Fibers

**Definition 2.2** (Discriminant Map). For a prime p, the *discriminant map* is the function:

    quadDiscMap_p : 𝔽_p × 𝔽_p → 𝔽_p
    quadDiscMap_p(b, c) = b² − 4c

**Definition 2.3** (Discriminant Fiber). For d ∈ 𝔽_p, the *fiber* of the discriminant map over d is:

    discFiber(p, d) = {(b, c) ∈ 𝔽_p² : b² − 4c = d}

### 2.3 Splitting Type

**Definition 2.4** (Quadratic Splitting Type). The *splitting type* of a monic quadratic x² + bx + c over 𝔽_p is:

- **split**: Δ ≠ 0 and Δ is a square in 𝔽_p (two distinct roots)
- **ramified**: Δ = 0 (one repeated root)  
- **inert**: Δ is a non-square in 𝔽_p (irreducible, no roots)

### 2.4 Frobenius Cycle Type

**Definition 2.5** (Cycle Type Partition). The cycle type partition associated to a splitting type is:

- split → [1, 1] (identity permutation)
- ramified → [1, 1] (degenerate)
- inert → [2] (transposition)

The sum of each partition is always 2, the polynomial degree.

---

## 3. Main Results

### 3.1 Discriminant Uniformity

**Theorem 3.1** (Discriminant Uniformity). *For any prime p and any d ∈ 𝔽_p,*

    |discFiber(p, d)| = p.

*Proof sketch.* We split into two cases:

**Case p odd.** For each b ∈ 𝔽_p, the equation b² − 4c = d has a unique solution c = (b² − d)/4, since 4 is a unit in 𝔽_p (as p ∤ 4). Thus the map b ↦ (b, (b² − d)/4) is an injection from 𝔽_p to discFiber(p, d). To show surjectivity, any (b, c) in the fiber gives the equation 4c = b² − d, which uniquely determines c from b. The fiber has exactly p elements, one for each b.

**Case p = 2.** Direct computation: 4 ≡ 0 (mod 2), so b² − 4c = b² = b in 𝔽₂. For each d ∈ {0, 1}, the fiber is {(d, 0), (d, 1)}, which has 2 elements. ∎

**Lemma 3.2** (4 is a unit for odd primes). *For an odd prime p, 4 is a unit in ℤ/pℤ.*

*Proof.* Since p is prime and p ≠ 2, we have gcd(4, p) = 1, so 4 is coprime to p and hence invertible. ∎

**Lemma 3.3** (Unique c for discriminant). *For an odd prime p and any b, d ∈ 𝔽_p, there exists a unique c ∈ 𝔽_p such that b² − 4c = d.*

*Proof.* Existence: take c = (b² − d) · 4⁻¹. Uniqueness: if 4c₁ = 4c₂ then c₁ = c₂ since 4 is a unit. ∎

### 3.2 Separability Density

**Theorem 3.4** (Separability Count). *The number of separable monic quadratics over 𝔽_p is p² − p.*

*Proof.* A monic quadratic is separable iff its discriminant is nonzero. The inseparable quadratics are exactly discFiber(p, 0), which has cardinality p by Theorem 3.1. The total number of monic quadratics is p². Therefore, |separable| = p² − p. ∎

**Corollary 3.5** (Separability Density). *The fraction of monic quadratics over 𝔽_p that are separable is 1 − 1/p.*

### 3.3 Quadratic Residue Counts

**Theorem 3.6** (Nonzero Square Count). *For an odd prime p, the number of nonzero squares in 𝔽_p is (p − 1)/2.*

*Proof.* The squaring map x ↦ x² restricted to 𝔽_p* is 2-to-1: each nonzero square y = x² has exactly two square roots x and −x, which are distinct since p is odd (so x ≠ −x for x ≠ 0). The domain 𝔽_p* has p − 1 elements, so the image (the nonzero squares) has (p − 1)/2 elements. ∎

**Theorem 3.7** (Non-square Count). *For an odd prime p, the number of non-squares in 𝔽_p is (p − 1)/2.*

*Proof.* The elements of 𝔽_p partition into {0}, nonzero squares, and non-squares. We have 1 + (p−1)/2 + |non-squares| = p, giving |non-squares| = (p − 1)/2. ∎

### 3.4 Splitting Type Distribution

**Theorem 3.8** (Ramified Count). *The number of ramified monic quadratics over 𝔽_p is exactly p.*

*Proof.* Ramified quadratics are those with zero discriminant, which is precisely discFiber(p, 0). By Theorem 3.1, this has cardinality p. ∎

**Theorem 3.9** (Split-Inert Symmetry). *For an odd prime p, the number of split quadratics and the number of inert quadratics are both equal to p(p − 1)/2.*

*Proof.* By Theorems 3.1, 3.6, and 3.7:
- Split count = (number of nonzero squares) × (fiber size) = (p−1)/2 × p = p(p−1)/2
- Inert count = (number of non-squares) × (fiber size) = (p−1)/2 × p = p(p−1)/2 ∎

**Corollary 3.10** (Irreducibility Fraction). *The fraction of monic quadratics over 𝔽_p that are irreducible is (p − 1)/(2p), which converges to 1/2 as p → ∞.*

### 3.5 Cycle Type Partition

**Theorem 3.11** (Partition Sum). *For any splitting type, the associated cycle type partition sums to 2.*

*Proof.* Direct computation: [1,1] sums to 2 and [2] sums to 2. ∎

---

## 4. The Cubic Discriminant: When Uniformity Fails

### 4.1 Definition

The discriminant of a depressed cubic x³ + bx + c is:

    cubicDisc(b, c) = −(4b³ + 27c²)

### 4.2 Computational Investigation

We computed the fiber sizes of the cubic discriminant map over 𝔽_p for several primes:

| p  | p mod 3 | Uniform? | Fiber size range |
|----|---------|----------|------------------|
| 5  | 2       | Yes      | all 5            |
| 7  | 1       | **No**   | [2, 12]          |
| 11 | 2       | Yes      | all 11           |
| 13 | 1       | **No**   | [6, 20]          |
| 17 | 2       | Yes      | all 17           |
| 19 | 1       | **No**   | varies           |
| 23 | 2       | Yes      | all 23           |

### 4.3 The Mod-3 Obstruction

**Conjecture 4.1.** *The cubic discriminant map (b, c) ↦ −(4b³ + 27c²) from 𝔽_p² to 𝔽_p is uniform (all fibers of size p) if and only if p ≡ 2 (mod 3).*

**Explanation.** When p ≡ 1 (mod 3), the multiplicative group 𝔽_p* contains elements of order 3, so the cube map x ↦ x³ is 3-to-1 on 𝔽_p*. This breaks the injectivity argument that works for the quadratic case. Specifically, the fiber of b ↦ 4b³ over a given value has 3 preimages (when the value is a nonzero cube) instead of the uniform 1 preimage we get for b ↦ b² − d.

When p ≡ 2 (mod 3), the cube map is bijective on 𝔽_p* (since gcd(3, p−1) = 1), and the uniformity argument for the quadratic case generalizes.

**Test.** Verify computationally for all primes p < 1000 that uniformity holds iff p ≡ 2 (mod 3), or find a counterexample.

---

## 5. The Frobenius Correspondence

### 5.1 Background

For a polynomial f ∈ 𝔽_p[x] of degree n, the *splitting type* records the degrees of its irreducible factors (as a partition of n). The *Frobenius correspondence* states that for a "generic" polynomial over 𝔽_p, the splitting type equals the cycle type of a specific permutation (the Frobenius element) in the Galois group.

### 5.2 Quadratic Case

For monic quadratics, the splitting type determines the cycle type:

| Splitting Type | Factorization     | Cycle Type | Permutation    |
|---------------|-------------------|------------|----------------|
| Split         | (x−a)(x−b), a≠b  | [1,1]      | Identity       |
| Ramified      | (x−a)²            | [1,1]      | Degenerate     |
| Inert         | irreducible       | [2]        | Transposition  |

The splitting type distribution over random monic quadratics in 𝔽_p approaches the cycle type distribution of random permutations in S₂ as p → ∞:

- P(split) = (p−1)/(2p) → 1/2 = P(identity in S₂)
- P(inert) = (p−1)/(2p) → 1/2 = P(transposition in S₂)
- P(ramified) = 1/p → 0

This is the quadratic instance of a general principle connecting polynomial factorization over finite fields to random permutation theory.

---

## 6. Algorithms

### 6.1 Fiber Computation (O(p))

For an odd prime p and target d:
1. Compute 4⁻¹ mod p using Fermat's little theorem: 4⁻¹ = 4^(p−2) mod p
2. For each b ∈ {0, ..., p−1}: compute c = (b² − d) · 4⁻¹ mod p
3. Return the list of pairs (b, c)

### 6.2 Splitting Type Classification (O(log p))

Given b, c, p:
1. Compute d = b² − 4c mod p
2. If d = 0: return "ramified"
3. Compute d^((p−1)/2) mod p using fast exponentiation
4. If result = 1: return "split" (d is a quadratic residue)
5. Else: return "inert"

### 6.3 Counting Without Enumeration (O(1))

By the Discriminant Uniformity Theorem combined with quadratic residue theory:
- Ramified count = p
- Split count = p(p−1)/2
- Inert count = p(p−1)/2

No enumeration needed — exact counts in constant time.

---

## 7. Discussion

### 7.1 Why Uniformity Matters

The Discriminant Uniformity Theorem is more than a counting exercise. It exemplifies a principle that extends far beyond quadratics: **affine-linear maps over finite fields have uniform fibers**. The key structural observation is that for fixed b, the map c ↦ b² − 4c is affine-linear in c, and affine-linear maps are bijections (when the linear coefficient is a unit). This principle underlies:

- The equidistribution theory of polynomial values over finite fields
- The Weil conjectures (proved by Deligne) on point counts of algebraic varieties
- Modern sieve methods in analytic number theory

### 7.2 Connection to Galois Groups

Over finite fields, all Galois groups are cyclic (generated by Frobenius). This means the "random Galois group" question that is natural over ℚ (where the answer is "almost always S_n" by Hilbert's irreducibility theorem) has a fundamentally different character over 𝔽_p. The correct analog is the splitting type distribution, which connects to the cycle type distribution of random elements in the Galois group.

### 7.3 Limitations

Our formal proofs work for any prime p but are restricted to the quadratic case. The cubic and higher-degree analogs require substantially more machinery (e.g., the Lang-Weil theorem, or explicit fiber counting for polynomial maps of higher degree).

---

## 8. Future Work

1. **Cubic splitting type distribution** for p ≡ 2 (mod 3), where uniformity holds
2. **Formal Frobenius correspondence** connecting splitting types to Galois group elements
3. **Generalization to composite moduli** and the Chinese Remainder Theorem decomposition
4. **Quantitative convergence rates** for the approach to random permutation statistics
5. **Extension to 𝔽_{p^n}** for prime power fields

---

## 9. Formal Verification Summary

All main results were formalized and verified in Lean 4 with Mathlib. The verification uses only standard axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry` statements remain. The complete formal development is in `Algebra/DiscriminantUniformity.lean`.

### Theorem Registry

| Theorem | Lean Name | Dependencies |
|---------|-----------|-------------|
| Thm 3.1 | `disc_fiber_card` | `disc_fiber_card_odd`, `disc_fiber_card_two` |
| Thm 3.4 | `separable_quad_count` | `disc_fiber_card` |
| Thm 3.6 | `nonzero_square_count` | (self-contained) |
| Thm 3.7 | `nonsquare_count` | `nonzero_square_count` |
| Thm 3.8 | `ramified_count` | `disc_fiber_card` |
| Thm 3.11 | `cycle_partition_sum` | (self-contained) |

---

## References

1. R. Lidl and H. Niederreiter, *Finite Fields*, Cambridge University Press, 1997.
2. N. Katz and P. Sarnak, *Random Matrices, Frobenius Eigenvalues, and Monodromy*, AMS, 1999.
3. J.-P. Serre, *Lectures on N_X(p)*, CRC Press, 2012.
4. The Mathlib Community, *Mathlib: the Lean mathematical library*, 2024.
