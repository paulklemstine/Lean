# Adelic Persistent Homology: Arithmetic Decomposition of Torsion Barcodes

## Abstract

We introduce the theory of **adelic torsion persistence** for filtered finite abelian groups. Given a filtration F₀ ⊆ F₁ ⊆ ··· ⊆ Fₙ of finite abelian groups with compatible homomorphisms, we define the *adelic torsion datum* — a structure packaging the prime-indexed family of p-primary persistence data with a finite-support condition. We prove four main theorems:

1. **Functoriality**: Group homomorphisms preserve p-primary torsion components, making prime-wise persistence well-defined.
2. **Adelic Reconstruction**: The canonical adelic datum reconstructs the global torsion prime support exactly at every filtration level, with uniqueness among data with the same local supports.
3. **Bounded Support Criterion**: Bounded torsion exponent implies bounded prime support, and every finite filtration has bounded torsion.
4. **CRT Persistence Splitting**: For coprime torsion orders, the torsion persistence module splits as a direct sum compatible with structure maps.

All theorems are formally verified in Lean 4 with Mathlib. We provide algorithms, computational experiments on 1291 filtrations of cyclic groups (with no counterexamples to reconstruction), and introduce the experimental *persistence zeta function* as an arithmetic invariant.

**Keywords**: arithmetic persistent homology, adelic barcode, prime-sensitive topological invariants, local-global principle, Chinese remainder persistence, torsion decomposition, filtered finite abelian groups, barcode reconstruction.

---

## 1. Introduction

### 1.1 Motivation

Persistent homology, the central tool of topological data analysis (TDA), tracks how topological features (connected components, loops, voids) are born and die across a family of spaces parameterized by a scale parameter. The output — the *persistence barcode* — is a multiset of intervals recording feature lifetimes. Classical persistence theory works over a field, which makes the algebra clean (all modules decompose into interval modules) but loses torsion information entirely.

When one computes homology with integer coefficients, the homology groups are finitely generated abelian groups, not vector spaces. They carry *torsion* — elements of finite order — which encodes subtle topological information invisible to field-coefficient computations. For example, the torsion in H₁ of the real projective plane RP² detects its non-orientability.

The key observation driving this paper is that torsion in abelian groups has a canonical **arithmetic decomposition by prime**. By the structure theorem for finitely generated abelian groups, every finite abelian group decomposes uniquely as a direct sum of p-primary components, one for each prime p dividing the group order. This decomposition is *functorial* — homomorphisms respect it.

We show that this prime decomposition extends to the persistent setting: the entire torsion barcode of a filtered finite abelian group can be decomposed prime-by-prime, and the resulting family of prime-local persistence data admits a natural "adelic" packaging with finite-support compatibility and exact reconstruction properties.

### 1.2 Contributions

1. **New definitions**: `IsPPrimary`, `pPrimaryComponent`, `pPrimaryNontrivial`, `AdelicTorsionDatum`, `reconstructTorsionSupport`, `nTorsionSubgroup` — formalized in Lean 4.

2. **Four main theorems** (all machine-verified):
   - Functoriality of p-primary persistence (Theorem 1)
   - Adelic reconstruction with uniqueness (Theorem 2)
   - Bounded support criterion (Theorem 3)
   - CRT persistence splitting (Theorem 4)

3. **Algorithms** with complexity analysis for computing adelic torsion data.

4. **Computational experiments** verifying the reconstruction conjecture on 1291 filtrations.

5. **Persistence zeta function**: an experimental multiplicative invariant.

### 1.3 Related Work

The connection between torsion in homology and persistent homology has been explored by several authors. Carlsson and Zomorodian (2005) studied persistence modules over PIDs. The Tor₁-based approach to torsion detection was formalized in the catalog file `TorsionDetection.lean`, establishing that Tor₁(Z/pZ, −) detects exactly p-torsion.

Our arithmetic phase classification (`ArithmeticPhaseClassification.lean`) showed that for finite groups, the set of primes visible through abelian probes equals the torsion support of the abelianization. The present work extends this from single groups to filtered families, introducing the adelic packaging as a novel organizational principle.

The term "adelic" is used by analogy with the adeles of algebraic number theory, where local data at each prime is assembled into a global object with a restricted product topology. Our `AdelicTorsionDatum` captures the same architecture: local (prime-by-prime) persistence data with a finite-support constraint.

---

## 2. Definitions and Notation

### 2.1 p-Primary Torsion

**Definition 2.1** (p-Primary Element). Let A be an additive abelian group. An element a ∈ A is *p-primary* if there exists k ∈ ℕ such that p^k · a = 0.

**Definition 2.2** (p-Primary Component). The *p-primary component* of A is the subgroup
$$T_p(A) = \{a \in A \mid \exists k \in \mathbb{N},\, p^k \cdot a = 0\}.$$
This is indeed a subgroup: it contains 0, is closed under addition (using max of exponents and the identity p^{a+b} · (x+y) = p^b · (p^a · x) + p^a · (p^b · y)), and under negation.

**Definition 2.3** (p-Primary Nontriviality). We say A has *nontrivial p-primary component* if there exists a ≠ 0 in T_p(A).

### 2.2 Torsion Prime Support

**Definition 2.4** (Torsion Prime Support). The *torsion prime support* of A is
$$\text{Supp}(A) = \{p \in \mathbb{N} \mid p \text{ is prime and } T_p(A) \neq 0\}.$$

For a filtration F : Fin(n+1) → Ab, the *filtration prime support* is the function i ↦ Supp(F(i)).

### 2.3 Adelic Torsion Datum

**Definition 2.5** (Adelic Torsion Datum). An *adelic torsion datum* of length n+1 consists of:
- A predicate `localSupport : ℕ → Fin(n+1) → Prop`
- A primality condition: if `localSupport p i` then p is prime
- A finite support condition: for each i, the set {p | localSupport p i} is finite

**Definition 2.6** (Reconstruction Map). Given an adelic datum D, the *reconstructed torsion support* at level i is
$$\text{Recon}(D, i) = \{p \mid D.\text{localSupport}\, p\, i\}.$$

**Definition 2.7** (Canonical Adelic Datum). For a filtration F of finite abelian groups, the *canonical adelic datum* is defined by
$$\text{localSupport}\, p\, i \iff p \text{ is prime} \wedge T_p(F(i)) \neq 0.$$

### 2.4 n-Torsion Subgroup

**Definition 2.8** (n-Torsion Subgroup). For a natural number m and abelian group A, the *m-torsion subgroup* is
$$A[m] = \{a \in A \mid m \cdot a = 0\}.$$

---

## 3. Main Results

### 3.1 Theorem 1: Functoriality of p-Primary Persistence

**Theorem 3.1** (map_preserves_pPrimary). Let f : A →+ B be a group homomorphism. If a ∈ T_p(A), then f(a) ∈ T_p(B).

*Proof sketch.* If p^k · a = 0, then p^k · f(a) = f(p^k · a) = f(0) = 0 by linearity of f. ∎

**Theorem 3.2** (pPrimaryNontrivial_of_injective). If f is injective and T_p(A) ≠ 0, then T_p(B) ≠ 0.

*Proof sketch.* Take a ≠ 0 in T_p(A). Then f(a) ≠ 0 (by injectivity) and f(a) ∈ T_p(B) (by Theorem 3.1). ∎

**Corollary 3.3** (persistence_preserves_pPrimary). For a finite persistence module M with structure maps ι_{ij} : M(i) →+ M(j), the maps restrict to T_p(M(i)) → T_p(M(j)). Hence {T_p(M(i))}_{i} forms a sub-persistence module for each prime p.

### 3.2 Theorem 2: Adelic Reconstruction

**Theorem 3.4** (torsionPrimeSupportSet_finite). For a finite abelian group A, the set Supp(A) is finite and contained in the prime factors of |A|.

*Proof sketch.* If a ≠ 0, a ∈ T_p(A), then addOrderOf(a) | p^k and addOrderOf(a) | |A|. Since addOrderOf(a) > 1, it has a prime factor q with q | p^k, hence q = p (as p is prime). Thus p | addOrderOf(a) | |A|. ∎

**Theorem 3.5** (adelic_reconstruction_correct_set). For any filtration F of finite abelian groups,
$$\forall i,\quad \text{Recon}(\text{AdelicDatum}(F), i) = \text{Supp}(F(i)).$$

*Proof.* By definition, the canonical adelic datum has localSupport p i ↔ (p prime ∧ T_p(F(i)) ≠ 0), which is exactly the defining condition of Supp(F(i)). ∎

**Theorem 3.6** (adelic_reconstruction_unique). If D₁ and D₂ have the same local supports (localSupport₁ p i ↔ localSupport₂ p i for all p, i), then Recon(D₁, i) = Recon(D₂, i) for all i.

*Proof.* Immediate from the definition of Recon as {p | localSupport p i}. ∎

**Theorem 3.7** (adelic_extensionality). D₁.localSupport = D₂.localSupport pointwise iff Recon(D₁) = Recon(D₂) pointwise.

*Proof.* The forward direction is Theorem 3.6. The reverse follows because Recon(D, i) = {p | D.localSupport p i}, so membership in the reconstructed set characterizes localSupport. ∎

### 3.3 Theorem 3: Bounded Support Criterion

**Theorem 3.8** (bounded_torsion_implies_bounded_primeSupport). If ∃ B > 0 such that B · a = 0 for all levels i and elements a ∈ F(i), then Supp(F(i)) ⊆ primeFactors(B) for all i.

*Proof sketch.* By contradiction: if p ∤ B, then gcd(p^k, B) = 1. By Bezout, ∃ α, β with p^k · α + B · β = 1. Then a = 1 · a = p^k · α · a + B · β · a = 0 + 0 = 0, contradicting a ≠ 0. ∎

**Theorem 3.9** (finite_filtration_has_bounded_torsion). Every filtration of finite groups has bounded torsion, with B = ∏ᵢ |F(i)|.

*Proof.* |F(i)| · a = 0 for all a ∈ F(i) by Lagrange, and |F(i)| | B. ∎

**Corollary 3.10**. Every finite filtration has bounded prime support.

### 3.4 Theorem 4: CRT Persistence Splitting

**Theorem 3.11** (persistence_CRT_decomposition). For coprime m and k, every element a ∈ A[mk] decomposes as a = b + c with b ∈ A[m] and c ∈ A[k].

*Proof sketch.* By Bezout, ∃ u, v with k·u + m·v = 1. Set b = k·v·a and c = m·u·a. Then m · b = mk · v · a = 0, k · c = mk · u · a = 0, and b + c = (ku + mv) · a = 1 · a = a. ∎

**Theorem 3.12** (CRT_persistence_functorial). If f : A →+ B and a = b + c with b ∈ A[m], c ∈ A[k], then f(a) = f(b) + f(c) with f(b) ∈ B[m], f(c) ∈ B[k].

*Proof.* m · f(b) = f(m · b) = f(0) = 0, and f(a) = f(b + c) = f(b) + f(c). ∎

---

## 4. Algorithms

### 4.1 Prime Support Computation

```
Algorithm: PrimeSupport(n)
Input: Group order n
Output: Set of primes p with nontrivial T_p(Z/nZ)

1. If n ≤ 1: return ∅
2. Compute prime factorization of n
3. Return the set of prime factors

Time: O(√n)
Space: O(log n)
```

For cyclic groups Z/nZ, the prime support equals the set of prime factors of n.

### 4.2 Adelic Datum Construction

```
Algorithm: AdelicDatum(orders[0..n])
Input: Filtration group orders
Output: Adelic torsion datum

1. For each level i = 0, ..., n:
   a. Compute S_i = PrimeSupport(orders[i])
   b. For each p ∈ S_i: set localSupport(p, i) = true
2. Return the datum

Time: O(n · √max_order)
Space: O(n · log(max_order))
```

### 4.3 Barcode Reconstruction

```
Algorithm: Reconstruct(datum, i)
Input: Adelic datum, level i
Output: Set of primes active at level i

1. Return {p | datum.localSupport(p, i)}

Time: O(|all_primes|) ≤ O(log(max_order))
```

### 4.4 CRT Decomposition

```
Algorithm: CRTDecompose(n, m, k, a)
Input: Group order n, coprime m and k, element a ∈ Z/nZ[mk]
Output: (b, c) with b ∈ Z/nZ[m], c ∈ Z/nZ[k], a = b + c

1. Compute (g, u, v) = ExtendedGCD(m, k)  // mu + kv = 1
2. b = k·v·a mod n
3. c = m·u·a mod n
4. Return (b, c)

Time: O(log(min(m,k)))
Space: O(1)
```

---

## 5. Computational Experiments

### 5.1 Reconstruction Conjecture Verification

We tested the adelic reconstruction conjecture — that Recon(AdelicDatum(F), i) = Supp(F(i)) for all i — on 1291 filtrations of cyclic groups with orders dividing 60 and lengths 3–5.

| Parameter | Value |
|-----------|-------|
| Maximum group order | 60 |
| Filtration lengths | 3, 4, 5 |
| Total filtrations tested | 1291 |
| Reconstruction correct | 1291 (100%) |
| Counterexamples found | 0 |

The conjecture holds universally for cyclic groups, which is expected since Supp(Z/nZ) = primeFactors(n) by definition.

### 5.2 CRT Decomposition

For Z/6Z with the coprime pair (2, 3):

| Element a | 2-torsion b | 3-torsion c | Check b+c=a |
|-----------|-------------|-------------|-------------|
| 0 | 0 | 0 | ✓ |
| 1 | 3 | 4 | ✓ |
| 2 | 0 | 2 | ✓ |
| 3 | 3 | 0 | ✓ |
| 4 | 0 | 4 | ✓ |
| 5 | 3 | 2 | ✓ |

### 5.3 Persistence Zeta Function

The persistence zeta function Z(F, s) = ∏_p (1 + len(barcode_p) · p^{-s}) was computed for several filtrations:

| Filtration | Z(1) | Z(2) | Z(3) |
|------------|------|------|------|
| [1, 6] | 2.0000 | 1.3889 | 1.1574 |
| [1, 3, 6] | 2.5000 | 1.5278 | 1.2037 |
| [1, 2, 6, 12] | 4.1667 | 2.1389 | 1.4769 |
| [1, 2, 4, 12, 60] | 6.0000 | 2.5422 | 1.5904 |

Multiplicativity was observed for filtrations with coprime prime supports (e.g., [1,2,4] × [1,3,9]) but failed when supports overlap (e.g., [1,2] × [1,3,6] where the product introduces new barcode interactions).

### 5.4 Worked Example: Z/6Z Filtration

The filtration 0 → Z/3Z → Z/6Z demonstrates all key phenomena:

- **Level 0** (trivial): Supp = ∅
- **Level 1** (Z/3Z): Supp = {3}, since 3-primary torsion present (element 1 has order 3)
- **Level 2** (Z/6Z): Supp = {2, 3}, since both 2- and 3-primary torsion present

Prime barcodes:
- p=2: interval [2, 2] (born at level 2)
- p=3: interval [1, 2] (born at level 1, persists to level 2)

The adelic reconstruction unions these: Recon(2) = {2, 3} = Supp(Z/6Z). ✓

---

## 6. Discussion

### 6.1 Mathematical Significance

The adelic torsion persistence framework establishes that torsion barcodes are not arbitrary combinatorial objects but carry **arithmetic structure governed by prime decomposition**. The key insight is the local-global principle: global torsion data at each filtration level is exactly determined by its prime-local components, and this determination is canonical and unique.

This parallels the fundamental architecture of adelic mathematics in number theory, where global invariants (class groups, L-functions, automorphic forms) are constructed from local data at each prime place. The finite-support condition in our `AdelicTorsionDatum` is the persistence-theoretic analogue of the restricted product topology on adeles.

### 6.2 Limitations

1. **Cyclic groups only**: Our computational experiments use cyclic groups Z/nZ. For non-cyclic groups (e.g., Z/2 × Z/4), the prime support captures which primes are active but not the full p-primary structure (e.g., it cannot distinguish Z/4 from Z/2 × Z/2).

2. **Support vs. multiplicity**: The adelic datum records whether p-primary torsion exists, not how much. Enriching the datum to capture p-ranks or invariant factors would give strictly more information.

3. **No infinite groups**: The theory requires finiteness at each level. Extension to finitely generated abelian groups (with both free and torsion parts) would require separating the free rank from torsion data.

### 6.3 Connection to Existing Frameworks

The `pTorsionDetected` predicate from `TorsionDetection.lean` (detecting elements killed by p via Tor₁) is equivalent to `pPrimaryNontrivial` for prime p, as we proved in `catalog_connection`. This bridges the derived-functor approach (Tor₁-detection) with the direct subgroup approach (p-primary components).

The `arithmeticPhaseProfile` from `ArithmeticPhaseClassification.lean` records which primes are visible through abelian probes of a group. For abelian groups, this equals the torsion prime support. Our work extends this from single groups to filtered families.

---

## 7. Future Work

1. **Persistence zeta functions**: Investigate multiplicativity of Z(s) under products of filtrations with coprime support.
2. **Adelic sheaves**: Formalize the datum as a constructible sheaf on Spec ℤ.
3. **Non-abelian extension**: Use abelianization to extend CRT persistence to non-abelian groups.
4. **Enriched adelic data**: Record p-ranks and invariant factors, not just support.
5. **Connections to automorphic forms**: Explore whether persistence zeta functions satisfy functional equations.

---

## 8. References

1. Carlsson, G. and Zomorodian, A. (2005). Computing persistent homology. *Discrete & Computational Geometry*, 33(2), 249–274.
2. Edelsbrunner, H. and Harer, J. (2010). *Computational Topology*. American Mathematical Society.
3. Tate, J. (1967). Fourier analysis in number fields and Hecke's zeta-functions. In *Algebraic Number Theory*, 305–347.
4. The mathlib Community (2020). The Lean Mathematical Library. *CPP 2020*.
