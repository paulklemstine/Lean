# The Periodic Table of Finite Groups: A Chemical-Algebraic Framework

## Abstract

We develop a systematic framework for organizing finite groups into a "periodic table" inspired by Mendeleev's classification of chemical elements. The framework assigns to each finite group a set of invariants — order (atomic number), derived depth (period), group valence (chemical valence), and nilpotency class (shell structure) — that parallel chemical properties and enable structural predictions. We prove eight main theorems establishing the mathematical foundations of this analogy: the Derived-Central Series Inequality, the Noble Gas Theorem, the Chemical Synthesis Theorem, the Simple Group Valence Theorem, the Information Dimension Additivity, the Halogen Unsolvability Theorem, the Nilpotency Class Spectrum, and the Derived Depth Product Formula. All results are formally verified in Lean 4 with Mathlib.

## 1. Introduction

The classification of finite groups is one of the grand projects of twentieth-century mathematics. While the classification of finite simple groups (CFSG) identifies all "atoms" of finite group theory, the problem of understanding how these atoms combine — the "chemistry" of groups — remains a central challenge. We propose an organizational framework inspired by the periodic table of elements.

### 1.1 The Chemical Analogy

| Chemical Concept | Group-Theoretic Analogue |
|---|---|
| Atomic number | Group order |
| Period (row) | Derived depth |
| Chemical family (column) | Structural class (abelian, nilpotent, solvable, ...) |
| Electron shell number | Nilpotency class |
| Valence | Number of minimal normal subgroups |
| Noble gas | Nilpotent group |
| Halogen | Symmetric group |
| Transition metal | Simple non-abelian group |
| Chemical stability | Solvability |
| Atomic mass | Information dimension Ω(|G|) |

### 1.2 Catalog Foundation

This work builds on the foundational `simple_group_valence_eq_one` theorem from the Catalog (`EML/PeriodicTableGroups.lean`, `FINAL/EML/PeriodicTableGroups.lean`), which established that simple groups have valence 1. We deepen this result by:
- Proving the full characterization of minimal normal subgroups of simple groups
- Establishing the Derived-Central Series Inequality as the structural backbone
- Proving the Chemical Synthesis Theorem (solvable extensions)
- Developing information dimension theory with additivity under products
- Proving the Derived Depth Product Formula

## 2. Definitions

### 2.1 Derived Series and Derived Depth

The *derived series* of a group G is defined recursively:
- D₀(G) = G
- D_{n+1}(G) = [D_n(G), D_n(G)]

A group is *solvable* if D_n(G) = 1 for some n. The *derived depth* is the minimal such n.

### 2.2 Lower Central Series and Nilpotency Class

The *lower central series* is:
- γ₁(G) = G
- γ_{n+1}(G) = [γ_n(G), G]

A group is *nilpotent* if γ_c(G) = 1 for some c. The *nilpotency class* is the minimal such c.

### 2.3 Group Valence

A normal subgroup N of G is *minimal normal* if N ≠ 1 and there is no normal subgroup strictly between 1 and N. The *group valence* is the number of minimal normal subgroups.

### 2.4 Information Dimension

The *information dimension* of a finite group G is Ω(|G|), the number of prime factors of |G| counted with multiplicity.

## 3. Main Results

### 3.1 Derived–Central Series Inequality

**Theorem 1** (`derived_le_lowerCentral`). *For any group G and natural number n, D_n(G) ≤ γ_n(G).*

*Proof sketch.* By induction on n. The base case is trivial. For the inductive step:
D_{n+1} = [D_n, D_n] ≤ [γ_n, γ_n] ≤ [γ_n, G] = γ_{n+1}
where the first inequality uses the inductive hypothesis with commutator monotonicity, and the second uses the fact that commuting with a subgroup is "easier" than commuting with the whole group. □

**PEGB Analysis:**
- **P**roof: Complete, non-trivial induction using `Subgroup.commutator_mono`.
- **E**xample: For S₃, D₁(S₃) = A₃ (order 3), γ₁(S₃) = A₃. D₂(S₃) = 1, γ₂(S₃) = 1. Equality holds.
- **G**eneralization: The inequality generalizes to the ω-indexed transfinite derived and lower central series for potentially non-Noetherian groups.
- **B**oundary: The inequality is generally strict. For the free group on 2 generators, D₁ = [F₂, F₂] has infinite index, while γ₁ = [F₂, F₂] as well — but at higher levels, the derived series descends more slowly.

### 3.2 The Noble Gas Theorem

**Theorem 2** (`noble_gas_depth_bound`). *If G is nilpotent of class c, then D_c(G) = 1.*

This follows immediately from Theorem 1: D_c(G) ≤ γ_c(G) = 1.

**Corollary** (`derivedDepth_le_nilpotencyClass'`). *The derived depth of a nilpotent group is at most its nilpotency class.*

**PEGB Analysis:**
- **P**roof: Direct consequence of the Derived–Central Series Inequality.
- **E**xample: The dihedral group D₄ has nilpotency class 2 and derived depth 1 (since D₁(D₄) = Z(D₄) and D₂(D₄) = 1). The bound 1 ≤ 2 holds.
- **G**eneralization: For p-groups, finer bounds exist: derived depth ≤ ⌊log_p(|G|)⌋.
- **B**oundary: The bound is tight for certain groups (e.g., iterated wreath products of Z/pZ).

### 3.3 Chemical Synthesis Theorem

**Theorem 3** (`solvable_extension'`). *If N ◁ G with both N and G/N solvable, then G is solvable.*

*Proof sketch.* We use the short exact sequence 1 → N → G → G/N → 1. The kernel of the quotient map G → G/N equals the range of the inclusion N ↪ G, so `solvable_of_ker_le_range` applies. □

**PEGB Analysis:**
- **P**roof: Uses the exact sequence characterization of solvability.
- **E**xample: S₃ has normal subgroup A₃ ≅ Z/3Z (solvable) with quotient S₃/A₃ ≅ Z/2Z (solvable), confirming S₃ is solvable.
- **G**eneralization: The result extends to transfinite solvability (where the derived series is indexed by ordinals).
- **B**oundary: Fails spectacularly for *non-solvable* extensions: A₅ ◁ S₅ with S₅/A₅ ≅ Z/2Z solvable, but A₅ is not solvable, so S₅ is not solvable despite having a solvable quotient.

### 3.4 Simple Group Valence Theorem

**Theorem 4** (`simple_valence_one'`). *A nontrivial simple group has valence exactly 1.*

This follows from two sub-results:
- `simple_top_minimal_normal'`: ⊤ is a minimal normal subgroup of any simple group.
- `simple_unique_minimal_normal'`: ⊤ is the *only* minimal normal subgroup.

**PEGB Analysis:**
- **P**roof: Uses IsSimpleGroup's characterization that normal subgroups are ⊥ or ⊤.
- **E**xample: A₅ has valence 1 (its only minimal normal subgroup is A₅ itself).
- **G**eneralization: For *characteristically simple* groups (no nontrivial characteristic subgroups), the valence still equals 1, suggesting a broader "hydrogen atom" phenomenon.
- **B**oundary: Non-simple groups can have arbitrary valence. The Klein four-group V₄ has three minimal normal subgroups (each of order 2), giving valence 3.

### 3.5 Information Dimension Additivity

**Theorem 5** (`groupInfoDimension_prod`). *Ω(|G × H|) = Ω(|G|) + Ω(|H|).*

*Proof sketch.* Since |G × H| = |G| · |H|, this follows from the multiplicativity of Ω (the prime factorization of a product is the concatenation of the factorizations). □

**PEGB Analysis:**
- **P**roof: Uses multiset arithmetic on prime factorizations.
- **E**xample: Ω(|Z/6Z × Z/10Z|) = Ω(60) = 4, and Ω(6) + Ω(10) = 2 + 2 = 4. ✓
- **G**eneralization: Extends to arbitrary finite direct products: Ω(|∏ᵢ Gᵢ|) = Σᵢ Ω(|Gᵢ|).
- **B**oundary: Does not extend to semidirect products in general (the order of a semidirect product is still the product of orders, but the structural decomposition differs).

### 3.6 Halogen Unsolvability

**Theorem 6** (`halogen_unsolvable'`). *The symmetric group S₅ is not solvable.*

This uses the Mathlib result `Equiv.Perm.not_solvable` with the cardinality bound |Fin 5| ≥ 5.

### 3.7 Nilpotency Class Spectrum

**Theorem 7** (`nilpotencyClass_one_iff_comm'`). *A nontrivial nilpotent group has nilpotency class 1 if and only if it is abelian.*

**PEGB Analysis:**
- **P**roof: Reduces to showing that nilpotency class 1 is equivalent to the center being the whole group.
- **E**xample: Z/6Z has class 1 (abelian). The quaternion group Q₈ has class 2 (nilpotent but not abelian).
- **G**eneralization: Class n corresponds to n "layers" of non-commutativity. The class-n nilpotent groups form a variety in the sense of universal algebra.
- **B**oundary: Not all groups are nilpotent — S₃ has trivial center but is not nilpotent.

### 3.8 Derived Depth Product Formula

**Theorem 8** (`derivedDepth_prod'`). *derivedDepth(G × H) = max(derivedDepth(G), derivedDepth(H)).*

*Proof sketch.* Uses the Derived Series Product Decomposition (`derivedSeries_prod'`): the derived series of a product decomposes component-wise. The derived depth of the product is the first n where both components have reached ⊥, which is the maximum of the individual depths. □

## 4. The Periodic Table Structure

Groups are organized into families (columns) based on their structural properties:

| Family | Characterization | Chemical Analogue | Valence Behavior |
|---|---|---|---|
| Abelian | Class 1 nilpotent | Noble gas (He, Ne) | Varies |
| Nilpotent (class > 1) | Non-abelian nilpotent | Noble gas (Ar, Kr) | ≥ 1 |
| Solvable non-nilpotent | Solvable, not nilpotent | Alkali/alkaline | ≥ 1 |
| Non-solvable | Not solvable | Transition metal/halogen | ≥ 1 |
| Simple non-abelian | No normal subgroups | Transition metal (pure) | = 1 |

The *period* (row) is determined by the derived depth: groups with the same derived depth share a "chemical period."

## 5. Algorithms

### 5.1 Group Classification Algorithm

Given a finite group G (presented by its multiplication table):
1. Compute |G| and its prime factorization → information dimension
2. Compute the derived series D₀ ⊇ D₁ ⊇ ... → derived depth (if solvable)
3. Compute the lower central series → nilpotency class (if nilpotent)
4. Find all minimal normal subgroups → valence
5. Assign family: abelian < nilpotent < solvable < general
6. Place in periodic table: row = derived depth, column = family

### 5.2 Composition Factor Extraction

Given a finite group G:
1. Find a maximal normal subgroup N
2. Record the simple quotient G/N
3. Recurse on N
4. Output the multiset of composition factors

By the Jordan-Hölder theorem, this multiset is independent of choices.

## 6. Cross-Domain Connections

### 6.1 Bridge to Lattice Theory

The set of normal subgroups of G forms a modular lattice. The group valence is the number of atoms in this lattice. This connects our periodic table to the theory of lattice invariants: the *width* of the normal subgroup lattice bounds the valence from above, while the *height* corresponds to the chief series length.

### 6.2 Bridge to Galois Theory

The solvability of a group is directly connected to the solvability of polynomial equations via Galois theory. Our Chemical Synthesis Theorem (solvable extensions are solvable) is the algebraic underpinning of the Galois-theoretic fact that solvable extensions of solvable extensions are solvable — which is why the class of polynomials solvable by radicals is closed under composition.

### 6.3 Bridge to Representation Theory

The derived depth of a group constrains its representation theory: a group of derived depth d has at least d + 1 distinct irreducible representations (one for each quotient in the derived series). The information dimension Ω(|G|) bounds the total number of irreducible representations.

## 7. Discussion

### 7.1 Predictive Power

Our periodic table makes predictions analogous to Mendeleev's:
- A group of order 120 with composition factors {Z/2Z, Z/2Z, Z/2Z, Z/3Z, Z/5Z} must be solvable (all factors are abelian, by the Chemical Synthesis Theorem applied iteratively).
- A group containing A₅ as a composition factor cannot be solvable (the Halogen Unsolvability Theorem propagates through extensions).
- The derived depth of any group of order 2ⁿ is at most n (Information Dimension bound).

### 7.2 Limitations

The chemical analogy has boundaries:
- Unlike chemical elements, groups of the same order can belong to different families (Z/6Z is abelian, S₃ is solvable non-nilpotent).
- The number of groups of order n grows super-exponentially (there are 49,487,365,422 groups of order 1024), making exhaustive classification impractical.
- Group valence, unlike chemical valence, is not bounded by a small constant.

## 8. Future Work

1. **Quantitative Periodic Law**: Prove that derivedDepth(G) ≤ Ω(|G|) for all nontrivial finite solvable groups.
2. **Socle Structure Theorem**: Characterize the socle (join of all minimal normal subgroups) for solvable groups.
3. **Computational Periodic Table**: Implement the classification algorithm for all groups of order ≤ 100 and verify predictions.
4. **Profinite Extension**: Extend the periodic table framework to profinite groups, connecting to Galois theory of infinite extensions.

## References

1. Catalog: `EML/PeriodicTableGroups.lean` — foundational periodic table framework
2. Catalog: `FINAL/EML/PeriodicTableGroups.lean` — verified simple_group_valence_eq_one
3. Catalog: `Algebra/FutureExploration.lean` — symmetric_group_order
4. Catalog: `FINAL/Algebra/FutureExploration.lean` — symmetric_group_order (verified)
5. Robinson, D.J.S., *A Course in the Theory of Groups*, Springer, 1996
6. Rotman, J.J., *An Introduction to the Theory of Groups*, Springer, 1995
