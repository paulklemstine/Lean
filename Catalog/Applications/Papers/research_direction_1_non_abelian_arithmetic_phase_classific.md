# Non-Abelian Arithmetic Phase Classification: Abelianization Controls Prime Torsion Visibility

## Abstract

We introduce the **arithmetic phase profile** of a finite group G — the set of primes p for which G admits an abelian quotient with p-torsion — and prove that this profile is entirely determined by the abelianization G^ab = G/[G,G]. Specifically, for any finite group G and prime p, the prime p belongs to the arithmetic phase profile of G if and only if G^ab has an element of order p (Theorem A). As corollaries, we establish that groups with isomorphic abelianizations have identical phase profiles (Theorem B) and that the phase profile of a direct product is the union of the factor profiles (Product Theorem). All results are formally verified with complete, machine-checked proofs, with no unproven steps. We provide algorithms for computing phase profiles and verify the theory on benchmark non-abelian groups including S₃, A₄, Q₈, D₄, and S₄.

**Keywords:** finite groups, abelianization, torsion, phase classification, arithmetic invariants, Cauchy's theorem

---

## 1. Introduction

### 1.1 Motivation

The abelianization map π : G → G^ab := G/[G,G] is the universal homomorphism from a group to an abelian group. It is well-known that G^ab captures certain homological information about G — for instance, H₁(G, ℤ) ≅ G^ab for discrete groups. A natural question arises: **to what extent does the abelianization determine the "arithmetic" structure of G, specifically its torsion properties as seen through abelian quotients?**

This question has roots in several mathematical traditions:

1. **Homological algebra**: The functor G ↦ G^ab is left adjoint to the inclusion of abelian groups into groups. Understanding what information it preserves or destroys is fundamental.

2. **Lattice gauge theory**: In topological phases of matter with finite gauge group G, the arithmetic structure of abelian quotients determines which "prime-level" topological sectors are observable through linear (additive/homological) probes.

3. **Derived functor theory**: The torsion detection results of [Catalog: TorsionDetection] show that Tor₁(ℤ/pℤ, A) vanishes if and only if A has no p-torsion. Our work extends this from abelian coefficient groups to non-abelian source groups via abelianization.

### 1.2 Prior Work

The classification of finite abelian groups (structure theorem) completely determines their torsion properties. For non-abelian groups, the relationship between the group's torsion and its abelian quotients' torsion has been understood informally but, to our knowledge, has not been formalized as a classification principle in the sense we present here.

The catalog results we build upon include:
- `HasPTorsion_ZMod_iff_dvd`: For ℤ/nℤ, p-torsion exists iff p | n.
- `torsionProfileUpTo_prod`: Torsion profiles decompose over products.
- `torsion_invisible_wrong_characteristic`: Torsion at prime p is invisible to probes in characteristic coprime to p.

### 1.3 Contributions

1. We formalize the definition of **PrimePhaseVisible** — an intrinsic notion of arithmetic phase detection for finite groups — and prove it equivalent to torsion in the abelianization.

2. We prove the **Arithmetic Phase Classification Theorem** (Theorem A): for finite G and prime p, PrimePhaseVisible(G, p) ↔ GroupHasPTorsion(G^ab, p).

3. We prove the **Classification Invariance** (Theorem B): isomorphic abelianizations imply identical phase profiles.

4. We prove the **Product Theorem**: Profile(G × H) = Profile(G) ∪ Profile(H).

5. All proofs are formally verified with no unproven steps (no `sorry` in the final code).

---

## 2. Definitions and Notation

### 2.1 Group Torsion

**Definition 2.1** (GroupHasPTorsion). A group G *has p-torsion* if there exists g ∈ G with g ≠ 1 and g^p = 1.

Note: For prime p, g^p = 1 with g ≠ 1 implies orderOf(g) = p.

### 2.2 Prime Phase Visibility

**Definition 2.2** (PrimePhaseVisible). A prime p is *phase-visible* for a group G if there exists a normal subgroup N ⊇ [G,G] of G such that G/N has p-torsion.

The condition [G,G] ≤ N ensures G/N is abelian. This definition quantifies over all abelian quotients of G (not just specific ones), making it an intrinsic property of G.

**Remark.** This definition is not a trivial abbreviation of "G^ab has p-torsion." It quantifies existentially over *all* normal subgroups containing the commutator, not just the commutator itself. The equivalence with G^ab torsion (Theorem A) is a genuine theorem requiring Cauchy's theorem and the divisibility properties of quotient maps.

### 2.3 Arithmetic Phase Profile

**Definition 2.3** (arithmeticPhaseProfile). The *arithmetic phase profile* of G is:

    arithmeticPhaseProfile(G) = {p prime : PrimePhaseVisible(G, p)}

---

## 3. Main Results

### 3.1 Theorem A: Abelianization Controls Phase Visibility

**Theorem 3.1** (primePhaseVisible_iff_abelianization). *For any finite group G and prime p:*

    PrimePhaseVisible(G, p) ↔ GroupHasPTorsion(Abelianization(G), p)

**Proof sketch.**

*Forward direction (⇒):* Suppose N ⊴ G with [G,G] ≤ N and G/N has p-torsion.

1. Since [G,G] ≤ N, the quotient map factors: G → G/[G,G] → G/N.
2. The induced map G^ab → G/N is surjective (quotient_map_surjective).
3. G/N has p-torsion, so p | |G/N| (by Lagrange via prime_dvd_natcard_of_torsion).
4. Since G^ab → G/N is surjective, |G/N| divides |G^ab| (by nat_card_dvd_of_surjective_hom).
5. Therefore p | |G^ab|.
6. By Cauchy's theorem (torsion_of_prime_dvd_natcard), G^ab has p-torsion.

*Backward direction (⇐):* Take N = [G,G]. Then G/N = G^ab, and [G,G] ≤ [G,G] trivially.

**Key lemmas used:**
- `quotient_map_surjective`: If N ≤ M (both normal), then G/N →* G/M is surjective.
- `nat_card_dvd_of_surjective_hom`: Surjective group homomorphisms preserve divisibility of cardinalities.
- `prime_dvd_natcard_of_torsion`: If G has p-torsion (p prime), then p | |G|.
- `torsion_of_prime_dvd_natcard`: Cauchy's theorem — if p | |G|, then G has p-torsion.

### 3.2 Theorem B: Classification Invariance

**Theorem 3.2** (primePhaseVisible_iff_of_abelianization_iso). *For finite groups G₁, G₂ with G₁^ab ≃* G₂^ab and prime p:*

    PrimePhaseVisible(G₁, p) ↔ PrimePhaseVisible(G₂, p)

**Proof.** Apply Theorem A to both sides, reducing to GroupHasPTorsion(G₁^ab, p) ↔ GroupHasPTorsion(G₂^ab, p). Transport torsion witnesses across the isomorphism e : G₁^ab ≃* G₂^ab using groupHasPTorsion_of_mulEquiv.

**Corollary 3.3** (arithmeticPhaseProfile_eq_of_abelianization_iso).
    
    G₁^ab ≃* G₂^ab ⟹ arithmeticPhaseProfile(G₁) = arithmeticPhaseProfile(G₂)

### 3.3 Product Theorem (Cross-Domain Bridge)

**Theorem 3.4** (primePhaseVisible_prod_iff). *For finite groups G, H and prime p:*

    PrimePhaseVisible(G × H, p) ↔ PrimePhaseVisible(G, p) ∨ PrimePhaseVisible(H, p)

**Proof.** Apply Theorem A to reduce to abelianization torsion. The key step is constructing the canonical isomorphism Abelianization(G × H) ≃* Abelianization(G) × Abelianization(H), then applying groupHasPTorsion_prod_iff.

The isomorphism is built using the universal property: the map G × H → G^ab × H^ab (project, then abelianize each factor) is a homomorphism to an abelian group, hence factors through (G × H)^ab. Bijectivity follows from a cardinality argument using the decomposition of the commutator subgroup: [G × H, G × H] = [G,G] × [H,H].

### 3.4 Abelian Transparency

**Theorem 3.5** (primePhaseVisible_comm_iff). *For a finite commutative group G and prime p:*

    PrimePhaseVisible(G, p) ↔ GroupHasPTorsion(G, p)

**Proof.** Since G is commutative, Abelianization.equivOfComm gives G ≃* G^ab. Apply Theorem A and transport across this equivalence.

### 3.5 Concrete ZMod Computation

**Theorem 3.6** (groupHasPTorsion_multiplicative_zmod). *For n ≥ 2 and prime p:*

    GroupHasPTorsion(Multiplicative(ZMod n), p) ↔ p | n

**Proof.** Forward: If g ≠ 1 has g^p = 1, then orderOf(g) = p, so p | n (since all orders divide |ZMod n| = n). Backward: If p | n, write n = pk. The element k ∈ ZMod n satisfies k ≠ 0 (since 1 ≤ k < n) and p · k = pk = n = 0 in ZMod n.

---

## 4. Algorithms

### 4.1 Phase Profile Computation

**Algorithm 1: ArithmeticPhaseProfile(G)**

```
Input: Finite group G (given by Cayley table)
Output: Set of primes in the arithmetic phase profile

1. Compute S = {[a,b] : a,b ∈ G}                    // O(|G|²)
2. [G,G] ← GenerateSubgroup(S)                       // O(|G|³)
3. k ← |G| / |[G,G]|                                // O(1)
4. Return PrimeFactors(k)                             // O(√k)
```

**Time complexity:** O(|G|³) dominated by subgroup generation.
**Space complexity:** O(|G|).

### 4.2 Profile Comparison

**Algorithm 2: SamePhaseProfile(G₁, G₂)**

```
Input: Finite groups G₁, G₂
Output: Boolean — whether they have the same arithmetic phase profile

1. P₁ ← ArithmeticPhaseProfile(G₁)
2. P₂ ← ArithmeticPhaseProfile(G₂)
3. Return P₁ = P₂
```

**Time complexity:** O(|G₁|³ + |G₂|³).

### 4.3 Product Profile (Fast)

**Algorithm 3: ProductPhaseProfile(G, H)**

By the Product Theorem, we avoid constructing G × H (which would have size |G|·|H|):

```
Input: Finite groups G, H
Output: arithmeticPhaseProfile(G × H)

1. P_G ← ArithmeticPhaseProfile(G)
2. P_H ← ArithmeticPhaseProfile(H)
3. Return P_G ∪ P_H
```

**Time complexity:** O(|G|³ + |H|³), versus O(|G|³·|H|³) for direct computation.

---

## 5. Computational Experiments

### 5.1 Benchmark Groups

| Group | |G| | |G^ab| | G^ab structure | Profile | Notes |
|-------|-----|--------|----------------|---------|-------|
| S₃    | 6   | 2      | ℤ/2ℤ          | {2}     | Simplest non-abelian |
| A₄    | 12  | 3      | ℤ/3ℤ          | {3}     | Even permutations |
| Q₈    | 8   | 4      | (ℤ/2ℤ)²       | {2}     | Quaternion group |
| D₄    | 8   | 4      | (ℤ/2ℤ)²       | {2}     | Dihedral group |
| S₄    | 24  | 2      | ℤ/2ℤ          | {2}     | |S₄^ab| = 2 |
| ℤ/6ℤ  | 6   | 6      | ℤ/6ℤ          | {2,3}   | Abelian benchmark |

### 5.2 Isomorphic Abelianization Test

Q₈ and D₄ have isomorphic abelianizations ((ℤ/2ℤ)²) despite being non-isomorphic groups. Theorem B predicts identical phase profiles. **Verified: both have profile {2}.**

### 5.3 Product Theorem Verification

Profile(ℤ/2ℤ × ℤ/3ℤ) = {2} ∪ {3} = {2,3} = Profile(ℤ/6ℤ). **Verified.**

Profile(S₃ × ℤ/5ℤ) = {2} ∪ {5} = {2,5}. **Verified by direct computation.**

---

## 6. Discussion

### 6.1 The Abelianization Boundary

The classification theorem identifies a precise boundary in the hierarchy of group invariants:

- **Below the boundary** (first-order arithmetic probes through abelian quotients): all information is captured by G^ab.
- **Above the boundary** (higher-order probes): genuinely non-abelian information appears.

The first invariant above the boundary is the **Schur multiplier** H₂(G, ℤ). For example, Q₈ and V₄ = (ℤ/2ℤ)² have isomorphic abelianizations but different Schur multipliers (ℤ/2ℤ vs. trivial). This demonstrates that the second homology group carries strictly more information than the first.

### 6.2 Physical Interpretation

In lattice gauge theory with finite gauge group G, the phase profile determines which "arithmetic topological sectors" are observable through linear (additive/homological) probes. The classification theorem says that non-abelian gauge structure contributes nothing beyond what the abelianization provides at this level.

The product theorem provides a Künneth-type decomposition: independent gauge sectors contribute independently to the phase spectrum, with no interference at the prime level.

### 6.3 Limitations

1. The theorem addresses only prime-level torsion detection, not the full torsion structure. Two groups can have the same phase profile but different torsion counts (e.g., ℤ/4ℤ vs. (ℤ/2ℤ)² both have profile {2} but different numbers of 2-torsion elements).

2. The theorem is specific to first-order probes (through abelian quotients). Higher derived functors (Ext, Tor at higher degrees) may detect non-abelian structure.

3. For infinite groups, the theorem requires modification (Cauchy's theorem fails for infinite groups).

---

## 7. Future Work

1. **Second-order classification**: Extend the theory to include the Schur multiplier H₂(G, ℤ) as a "second arithmetic phase invariant."

2. **Profinite groups**: Generalize to profinite groups where the abelianization map G → G^ab is replaced by a continuous homomorphism.

3. **Representation-theoretic profiles**: Define "representation phase visibility" using characters rather than torsion, and study the analogous classification question.

4. **Computational complexity**: Determine the complexity of computing the full torsion type (not just the prime set) of G^ab given G's Cayley table.

5. **Counterexample search at degree 2**: Systematically search for groups where the Schur multiplier provides strictly more information than the abelianization at the arithmetic level.

---

## 8. References

1. Rotman, J.J. *An Introduction to the Theory of Groups*. Springer, 4th ed., 1995. (Abelianization, Cauchy's theorem)

2. Brown, K.S. *Cohomology of Groups*. Springer GTM 87, 1982. (Group homology, Schur multipliers)

3. Weibel, C.A. *An Introduction to Homological Algebra*. Cambridge, 1994. (Derived functors, Tor)

4. Catalog: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — Tor₁-based torsion detection.

5. Catalog: `Pythagorean/AbelianizationTorsion.lean` — Base abelianization torsion results.

---

## Appendix: Formal Verification Summary

All theorems in this paper have been formally verified in Lean 4 with Mathlib. The verification covers:

| Theorem | Lean Name | Sorry-free | Axioms |
|---------|-----------|------------|--------|
| Theorem A | `primePhaseVisible_iff_abelianization` | ✓ | propext, Classical.choice, Quot.sound |
| Theorem B | `primePhaseVisible_iff_of_abelianization_iso` | ✓ | same |
| Corollary B | `arithmeticPhaseProfile_eq_of_abelianization_iso` | ✓ | same |
| Product | `primePhaseVisible_prod_iff` | ✓ | same |
| Abelian | `primePhaseVisible_comm_iff` | ✓ | same |
| ZMod | `groupHasPTorsion_multiplicative_zmod` | ✓ | same |
| Prod torsion | `groupHasPTorsion_prod_iff` | ✓ | same |
| MulEquiv | `groupHasPTorsion_of_mulEquiv` | ✓ | propext, Quot.sound |

Total: 8 theorems, 0 sorry, all axioms standard.
