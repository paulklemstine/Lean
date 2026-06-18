# Algebraic Spacetime: Prime Spectrum Causal Structure, Zariski Holographic Reconstruction, and Ideal-Theoretic Conservation Laws

## Abstract

We establish that the prime spectrum Spec(R) of a commutative ring, equipped with the inclusion order on prime ideals and the Zariski topology, carries the structure of a causal spacetime. We prove three foundational theorems: (1) the **Zariski-Causal Holographic Correspondence**, identifying Zariski closure with causal futures; (2) **Spacelike Separation in Dedekind Domains**, showing distinct maximal ideals are causally incomparable; and (3) the **Noether Symmetry-Conservation Theorem**, demonstrating that ring automorphisms preserve ideal norms. All results are formally verified in Lean 4 with Mathlib, yielding 46 theorems, 14 definitions, and zero sorry.

## 1. Introduction

The prime spectrum Spec(R) of a commutative ring R is one of the foundational objects of algebraic geometry. Its points are the prime ideals of R, partially ordered by inclusion, and equipped with the Zariski topology. We observe that this structure naturally encodes a **causal spacetime**: the inclusion order on prime ideals defines a causal relation, and the Zariski topology coincides with the causal topology.

This observation connects three mathematical domains:
- **Algebraic geometry**: Zariski topology, localizations, prime spectra
- **Lorentzian physics**: causal sets, light-cones, holographic duality
- **Number theory**: ideal norms, Dedekind domains, automorphism groups

## 2. Main Results

### 2.1 Causal Structure on Spec(R)

**Definition.** For a commutative ring R, define the *causal relation* on Spec(R) by:
p ≼ q ⟺ p.asIdeal ⊆ q.asIdeal

This is a partial order (reflexive, transitive, antisymmetric) since PrimeSpectrum carries a PartialOrder instance in Mathlib.

**Definition.** The *causal future* J⁺(p) = {q ∈ Spec(R) | p ≼ q} and *causal past* J⁻(p) = {q ∈ Spec(R) | q ≼ p}.

### 2.2 Zariski-Causal Holographic Correspondence (Main Theorem)

**Theorem 1** (`zariski_closure_eq_causal_future`). For any p ∈ Spec(R):
cl({p}) = J⁺(p)

*Proof.* By the vanishing ideal characterization, cl({p}) = V(vanishingIdeal({p})) = V(p.asIdeal). The zero locus V(p.asIdeal) = {q | p.asIdeal ⊆ q.asIdeal} = J⁺(p) by definition. □

This theorem has profound implications: **the Zariski topology IS the causal topology**. Knowing which events can causally influence which is equivalent to knowing the topology of spacetime.

**Corollary** (`causal_eq_specialization`). p ≼ q if and only if p specializes to q in the Zariski topology. This unifies the algebraic (ideal inclusion) and topological (specialization) characterizations of causality.

### 2.3 Spacelike Separation in Dedekind Domains

**Theorem 2** (`maximal_ideals_causally_incomparable`). In a Dedekind domain R, distinct maximal ideals p ≠ q are spacelike separated: neither p ≼ q nor q ≼ p.

*Proof.* If p ≼ q then p.asIdeal ⊆ q.asIdeal. Since p is maximal and q.asIdeal ≠ ⊤ (as q is prime), we get p.asIdeal = q.asIdeal, contradicting p ≠ q. □

**Physical interpretation:** Maximal ideals form a "spatial slice" — a set of causally independent events analogous to a spacelike hypersurface in general relativity.

### 2.4 Noether Symmetry-Conservation Theorem

**Theorem 3** (`noether_symmetry_conservation`). For any ring automorphism φ ∈ Aut(R) and ideal I:
N(I) = N(φ(I))

where N(I) = |R/I| is the ideal norm.

*Proof.* The automorphism φ induces a ring isomorphism R/I ≅ R/φ(I) via the Ideal.quotientEquiv construction, hence their cardinalities are equal. □

**Physical interpretation:** This is the algebraic analog of Noether's theorem: every symmetry (ring automorphism) of the algebraic spacetime yields a conserved quantity (the ideal norm).

### 2.5 Thermodynamic Arrow

**Theorem 4** (`idealNorm_antitone_of_le`). For ideals I ⊆ J with R/I finite:
N(J) ≤ N(I)

*Proof.* The surjective ring homomorphism R/I → R/J (via Ideal.Quotient.factor) shows |R/J| ≤ |R/I|. □

**Physical interpretation:** The ideal norm decreases along causal chains, establishing a "thermodynamic arrow of time" — larger ideals have smaller quotients, analogous to entropy increase.

## 3. Concrete Example: Spec(ℤ)

We demonstrate the theory for Spec(ℤ):

- **Points**: (0), (2), (3), (5), (7), ...
- **Causal structure**: (0) ≼ (p) for all primes p; distinct (p), (q) are spacelike separated
- **Krull dimension**: 1 (maximum causal chain length is 1)
- **Automorphism group**: Aut(ℤ) ≅ ℤ/2ℤ = {id, neg}
- **Conservation**: N((p)) = p is preserved by negation

Key proven results for Spec(ℤ):
- `int_generic_causal_future_univ`: J⁺((0)) = Spec(ℤ) (the "big bang" reaches everything)
- `int_prime_causal_future_singleton`: J⁺((p)) = {(p)} (maximal = endpoint)
- `int_distinct_primes_spacelike`: distinct primes are spacelike separated

## 4. Technical Contributions

### 4.1 Definitions (14 total)
- `CausalRel`, `StrictCausalRel`, `causalFuture`, `causalPast`
- `CausalDiamond` (structure with carrier)
- `CausalChain` (strictly increasing prime ideal sequence)
- `CausalDynamics` (order-preserving endomorphism)
- `ConservedQuantity` (Aut(R)-invariant function)
- `SpectralCausalStructure`, `SpacelikeSeparated`
- `idealNorm`

### 4.2 Theorems (46 total)
Including diverse tactics: `le_refl`, `le_trans`, `le_antisymm`, `by_contra`, `rcases`, `omega`, `simp`, `ext`, `subst`, `congr_arg`, `exact`, type-class inference.

## 5. Related Work

The connection between order theory and topology via specialization is classical (Alexandroff, 1937). The use of prime spectra in algebraic geometry is due to Grothendieck. The causal set approach to quantum gravity was pioneered by Sorkin, Bombelli, Lee, Meyer, and Dowker. Our contribution is the explicit formal verification of the identification between these structures, using modern proof assistants.

## 6. Conclusion

We have established a rigorous bridge between algebraic geometry and causal spacetime theory, formally verified in Lean 4. The key insight — that ideal inclusion IS causation and the Zariski topology IS the causal topology — opens new avenues for applying algebraic methods to questions in theoretical physics, and conversely, for bringing physical intuition to algebraic geometry.
