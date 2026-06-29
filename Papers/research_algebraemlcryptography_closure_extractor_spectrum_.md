# Closure–Extractor Spectrum Duality via Idempotent Entropy Semimodules and Certified Minimal Seeded Extractor Reconstruction

## Abstract

We establish a finite duality between closure-entropy systems — closure operators equipped with submodular, closure-invariant defect profiles — and finite seeded extractors with witness-determined bias behavior. The main theorem proves that every finite closure-entropy system admits a canonical seed-minimal extractor whose seed count exactly equals the spectrum rank (number of extremal closure-stable witnesses), and conversely, every finite seeded extractor induces a valid closure operator via witness-set intersection. All results are formalized and machine-verified in Lean 4 with Mathlib, producing sorry-free proofs.

**Keywords:** seeded extractors, closure operators, submodular functions, tropical algebra, spectrum rank, seed complexity, formal verification

---

## 1. Introduction

### 1.1 Motivation

Seeded randomness extractors are fundamental objects in cryptography and complexity theory. A seeded extractor takes a weakly random source and a short truly random seed to produce nearly uniform output. The central parameter governing extractor efficiency is the *seed complexity*: the logarithm of the number of seed values required.

Independently, closure operators on finite sets have been studied extensively in lattice theory, matroid theory, and database theory. A closure operator captures structural dependency: the closure of a set is the smallest "self-contained" superset.

This paper proves that these two mathematical objects are, under natural axioms, two presentations of the same underlying combinatorial structure. The connecting thread is the *defect profile* — a submodular, closure-invariant function measuring entropy deficiency — and the *extremal witnesses* — irreducible closed sets where defect increases strictly.

### 1.2 Related Work

The duality pattern we formalize has antecedents in several areas:

- **Closure-capacity duality for attention models** (ClosureCapacityAttentionDuality): established that closure-capacity objects on finite types admit minimal sparse attention realizations with head count equal to extreme rank.
- **Closure-capacity secret sharing** (ClosureCapacitySecretSharingDuality): showed that thresholded capacity functions on closure systems yield access structures whose minimal authorized sets are closure bases.
- **Non-Archimedean information duality** (PadicClosureInformationDuality): proved equivalence between closure capacities and tropical information functionals.
- **Closure-matroid duality** (ClosureMatroidDuality): formalized the equivalence between exchange closure systems and dependency presentations.

Our work bridges these to cryptographic extractor theory, introducing submodular defect profiles and proving the rank-complexity equality.

### 1.3 Contributions

1. **Definition of closure-entropy systems** with submodular, closure-invariant defect profiles (§2).
2. **Canonical extractor construction** from extremal witnesses (§3).
3. **Lower bound theorem**: any extractor realizing a closure-entropy system needs at least spectrum-rank many seeds (§4).
4. **Minimality theorem**: the canonical construction achieves this lower bound (§4).
5. **Reconstruction theorem**: from any extractor, one recovers a valid closure operator (§5).
6. **Rank-complexity equality**: generator rank = minimal seed complexity (§6).
7. **Idempotent witness semimodule**: tropical-algebraic structure of witness aggregation (§7).
8. **Complete Lean 4 formalization** with no remaining `sorry` (§8).

---

## 2. Definitions and Setup

### 2.1 Finite Closure Operators

**Definition 2.1.** A *finite closure operator* on a finite type ι consists of a function cl : Finset ι → Finset ι satisfying:
- **Extensivity**: A ⊆ cl(A) for all A,
- **Monotonicity**: A ⊆ B implies cl(A) ⊆ cl(B),
- **Idempotence**: cl(cl(A)) = cl(A) for all A.

A set A is *closed* if cl(A) = A. The family of closed sets is denoted C(cl).

### 2.2 Closure-Entropy Systems

**Definition 2.2.** A *closure-entropy system* (ι, cl, δ) consists of a finite closure operator cl on ι together with a defect profile δ : Finset ι → ℕ satisfying:

1. **Normalization**: δ(∅) = 0.
2. **Monotonicity on closed sets**: if A, B are closed and A ⊆ B, then δ(A) ≤ δ(B).
3. **Closure invariance**: δ(A) = δ(cl(A)) for all A.
4. **Submodularity on closed sets**: for closed A, B:
   δ(A) + δ(B) ≥ δ(A ∩ B) + δ(A ∪ B).

The closure invariance axiom ensures that δ descends to closure equivalence classes:

**Proposition 2.3** (Closure-class invariance). If cl(A) = cl(B), then δ(A) = δ(B).

*Proof.* δ(A) = δ(cl(A)) = δ(cl(B)) = δ(B). □

### 2.3 Extremal Witnesses

**Definition 2.4.** A closed set C ∈ C(cl) is an *extremal witness* if:
- C ≠ ∅, and
- for every closed D ⊊ C, we have δ(D) < δ(C).

The set of all extremal witnesses is denoted Ext(cl, δ), and the *spectrum rank* is r(cl, δ) = |Ext(cl, δ)|.

Extremal witnesses are the irreducible elements where defect increases strictly — analogous to extreme points in convexity, atoms in lattice theory, or circuits in matroid theory.

### 2.4 Finite Seeded Extractors

**Definition 2.5.** A *finite seeded extractor* on ι with n seeds consists of:
- A number of seeds n ∈ ℕ,
- Witness sets W_s ⊆ ι for each seed s ∈ Fin(n),
- Defect bounds d_s ∈ ℕ for each seed s.

**Definition 2.6.** An extractor *realizes* a closure-entropy system (cl, δ) if:
1. Each W_s is closed under cl,
2. Every extremal witness appears as some W_s,
3. d_s = δ(W_s) for all s.

**Definition 2.7.** An extractor is *seed-minimal* if it realizes the system and no realization uses fewer seeds.

---

## 3. Canonical Extractor Construction

**Construction 3.1.** Given a closure-entropy system (cl, δ) with spectrum rank r, fix an enumeration {C₁, ..., C_r} of the extremal witnesses. Define the *canonical extractor* E_can with:
- n = r seeds,
- W_i = C_i for each i,
- d_i = δ(C_i) for each i.

**Theorem 3.2** (Canonical realization). The canonical extractor realizes (cl, δ).

*Proof.* Each C_i is closed by definition of extremal witness. Every extremal witness appears by construction. Defect bounds match by definition. □

---

## 4. Lower Bound and Minimality

**Theorem 4.1** (Spectrum rank lower bound). If an extractor E with n seeds realizes (cl, δ), then r(cl, δ) ≤ n.

*Proof.* By the realization condition, for each extremal witness C there exists a seed s(C) with W_{s(C)} = C. The map C ↦ s(C) is injective: if s(C₁) = s(C₂), then C₁ = W_{s(C₁)} = W_{s(C₂)} = C₂. Therefore |Ext(cl, δ)| ≤ n. □

**Theorem 4.2** (Minimality). The canonical extractor is seed-minimal.

*Proof.* By Theorem 3.2, it realizes the system. By Theorem 4.1, any realization needs at least r seeds. The canonical extractor uses exactly r seeds. □

**Corollary 4.3** (Seed count characterization). For any seed-minimal extractor E:
n(E) = r(cl, δ).

*Proof.* n(E) ≤ r by minimality of E applied to the canonical extractor. n(E) ≥ r by Theorem 4.1. □

---

## 5. Reconstruction from Extractors

**Definition 5.1.** Given an extractor E, define the *reconstructed closure*:
cl_E(A) = ⋂{W_s : A ⊆ W_s} if any seed covers A, else ι.

**Theorem 5.2** (Reconstruction is a closure operator). cl_E satisfies extensivity, monotonicity, and idempotence.

*Proof sketch.* 
- **Extensivity**: A ⊆ W_s for each covering seed, so A ⊆ ⋂ W_s = cl_E(A).
- **Monotonicity**: If A ⊆ B, every seed covering B also covers A. The intersection over a superset of seeds is a subset.
- **Idempotence**: cl_E(A) is an intersection of witness sets. Any witness set containing cl_E(A) must contain A (since A ⊆ cl_E(A)), so the covering for cl_E(A) is the same as for A. □

**Definition 5.3.** The *reconstructed defect* is:
δ_E(A) = max{d_s : A ⊆ W_s}.

**Theorem 5.4** (Defect recovery). δ_E(W_s) ≥ d_s for all seeds s.

---

## 6. The Rank-Complexity Equality

**Theorem 6.1** (Generator rank = minimal seed complexity). 
generatorRank(cl, δ) = minimalSeedComplexity(cl, δ) = r(cl, δ).

This is the central duality equation. It says the algebraic complexity of the closure-entropy system (how many irreducible witnesses generate it) exactly equals the cryptographic complexity (how many seed values suffice for extraction).

---

## 7. Idempotent Witness Semimodule

The witness aggregation operation f ⊕ g := max(f, g) (pointwise maximum) satisfies:
- **Commutativity**: f ⊕ g = g ⊕ f,
- **Associativity**: (f ⊕ g) ⊕ h = f ⊕ (g ⊕ h),
- **Idempotence**: f ⊕ f = f.

This makes the witness space into a *sup-semilattice* — the finite shadow of a tropical max-plus semimodule. In the tropical interpretation, the extremal witnesses are the generators of this semimodule, and the spectrum rank is the tropical rank.

The submodularity of δ ensures that the witness semimodule is "tame" — bounded by finitely many generators — rather than requiring infinitely many directions to describe.

---

## 8. Submodularity Applications

**Theorem 8.1** (Union bound). For closed sets A, B:
δ(A ∪ B) ≤ δ(A) + δ(B).

*Proof.* From submodularity, δ(A) + δ(B) ≥ δ(A ∩ B) + δ(A ∪ B). Since δ(A ∩ B) ≥ 0. □

**Theorem 8.2** (Intersection bound). For closed A, B with A ∩ B closed:
δ(A ∩ B) ≤ min(δ(A), δ(B)).

*Proof.* From monotonicity: A ∩ B ⊆ A, B implies δ(A ∩ B) ≤ δ(A) and δ(A ∩ B) ≤ δ(B). □

---

## 9. Computational Demonstrations

We implemented the duality in Python and verified it on several concrete examples.

### Example 1: Rank-2 Matroid (3 elements)
- Ground set: {0, 1, 2}
- Closure: singletons are closed; any pair closes to the full set
- Closed sets: ∅, {0}, {1}, {2}, {0,1,2}
- Defect: δ(∅) = 0, δ({i}) = 1, δ({0,1,2}) = 1
- Extremal witnesses: {0}, {1}, {2}
- Spectrum rank: 3
- Canonical extractor: 3 seeds, one per singleton
- Verified: seed-minimal, round-trip reconstruction exact

### Example 2: Partition Closure (4 elements)
- Ground set: {0,1,2,3}, partition {0,1} | {2,3}
- Closed sets: ∅, {0,1}, {2,3}, {0,1,2,3}
- Spectrum rank: 3
- Canonical extractor: 3 seeds

### Example 3: Chain Closure (4 elements)
- Chain: ∅ ⊂ {0} ⊂ {0,1} ⊂ {0,1,2} ⊂ {0,1,2,3}
- Spectrum rank: 4
- All 4 non-empty closed sets are extremal (chain = each step increases defect)

---

## 10. Discussion

### 10.1 Relationship to Prior Dualities

Our closure-extractor duality follows the same structural skeleton as:
- The closure-capacity-attention duality (capacity → attention heads → reconstruction),
- The closure-capacity-secret-sharing duality (capacity → access structure → bases),
- The p-adic closure-information duality (capacity → tropical information → residuation).

The new contribution is the *cryptographic instantiation* (seeded extractors rather than attention models or access structures) and the *submodularity axiom* (which enables the union and intersection bounds).

### 10.2 Limitations

The current formalization uses ℕ-valued defect profiles rather than real-valued entropies. This is a deliberate choice for clean formalization, but it limits direct application to concrete extraction scenarios where entropy is measured in real-valued bits. Extending to ℝ≥0 or ℚ≥0 is straightforward but requires additional type coercion infrastructure.

The submodularity axiom is stated only for closed sets, which is weaker than full submodularity. This is sufficient for the duality but may not capture all information-theoretic applications.

### 10.3 Open Questions

1. Does the duality extend to infinite ground sets with appropriate compactness conditions?
2. Can the tropical rank interpretation be made fully rigorous with Mathlib's tropical algebra?
3. What is the precise relationship between spectrum rank and the critical exponent of the underlying matroid (when the closure operator has the exchange property)?

---

## 11. Formal Verification Details

The complete formalization is in `Bridges/AlgebraEMLCryptography/ClosureExtractorSpectrumDuality.lean`. Key statistics:
- **Lines of code**: ~500
- **Structures defined**: 3 (FiniteClosure, ClosureEntropySystem, FiniteSeededExtractor)
- **Theorems proved**: 20+
- **Sorry count**: 0
- **Axioms used**: only `propext`, `Classical.choice`, `Quot.sound` (standard)

All proofs are machine-checked by the Lean 4 kernel. The formalization imports Mathlib and uses its Finset, Fintype, and order theory libraries extensively.

---

## 12. Conclusion

We have established a rigorous finite duality between closure-entropy systems and seeded extractors, proving that the spectrum rank (number of extremal witnesses) exactly equals the minimal seed complexity. The duality is certified by machine-verified proofs and demonstrated on concrete numerical examples. This creates a new bridge between algebraic closure theory and cryptographic pseudorandomness, with connections to tropical geometry and information theory.

---

## References

1. Nisan, N. and Zuckerman, D. "Randomness is linear in space." *JCSS*, 1996.
2. Shaltiel, R. "Recent developments in explicit constructions of extractors." *Bulletin of the EATCS*, 2002.
3. Birkhoff, G. *Lattice Theory.* AMS, 1967.
4. Oxley, J. *Matroid Theory.* Oxford University Press, 2011.
5. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry.* AMS, 2015.
6. Fujishige, S. *Submodular Functions and Optimization.* Elsevier, 2005.
