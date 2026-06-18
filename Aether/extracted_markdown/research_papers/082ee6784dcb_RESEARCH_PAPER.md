# The Consistency Nerve: Simplicial Topology of Database Compatibility

## Abstract

We develop the **Consistency Nerve**, an abstract simplicial complex that captures the higher-order consistency structure of families with pairwise compatibility relations. Our central result is the **Nerve-Sheaf Equivalence**: the consistency nerve equals the full simplex if and only if the sheaf condition holds — that is, the ability to glue local data into a global section is equivalent to the combinatorial completeness of the consistency graph. We further develop a **defect filtration** that defines a persistence module analogous to the Vietoris-Rips filtration in topological data analysis, with the critical threshold of a face equaling the maximum pairwise defect. We establish the **conflict graph duality**: the sheaf condition holds if and only if the conflict graph (complement of the consistency graph) is edgeless. All results are formally verified in Lean 4 with Mathlib, requiring only the standard axioms (propext, Classical.choice, Quot.sound).

**Keywords**: simplicial complex, sheaf condition, consistency graph, defect filtration, topological data analysis, formal verification

## 1. Introduction

The problem of integrating multiple partial, overlapping data sources into a single coherent whole is fundamental to modern data science, arising in database merging, sensor fusion, multi-modal learning, and distributed systems. Mathematically, this is the *gluing problem*: given a family of "local sections" defined on overlapping domains, when can they be assembled into a "global section"?

In algebraic geometry, this question is answered by sheaf theory: a presheaf is a sheaf if and only if compatible local sections glue uniquely. The key condition is *pairwise consistency on overlaps*. While this theory is highly developed for topological spaces and sites, its application to finite, discrete data has been less systematically studied.

We introduce the **Consistency Nerve** as the natural bridge between discrete data integration and sheaf-theoretic abstraction. Given a family of objects indexed by a set ι, equipped with a reflexive, symmetric "compatibility" relation, the consistency nerve is the clique complex (flag complex) of the induced graph — the abstract simplicial complex whose faces are the mutually compatible subsets.

### 1.1 Main Contributions

1. **Abstract Consistency Systems** (§2): A minimal axiomatic framework (reflexive, symmetric relations) that captures pairwise compatibility in full generality.

2. **Nerve-Sheaf Equivalence** (§3): The consistency nerve is the full simplex ↔ the sheaf condition holds (Theorem 3.1).

3. **Consistency-Completeness Bridge** (§4): The consistency graph is complete ↔ the sheaf condition holds (Theorem 4.1).

4. **Conflict Graph Duality** (§5): The conflict graph is edgeless ↔ the sheaf condition holds (Theorem 5.1).

5. **Defect Filtration** (§6): A monotone filtration of simplicial complexes parametrized by tolerance threshold, with computable critical thresholds (Theorems 6.1–6.4).

6. **Gluing Preservation** (§7): Gluing consistent partial assignments preserves consistency with third parties (Theorem 7.1).

### 1.2 Related Work

The clique complex (or flag complex) construction is classical in combinatorial topology (see Jonsson [2008]). The connection between sheaves on posets and data integration was explored by Goguen [1992] and more recently by Robinson [2014] and Curry [2014]. Persistent homology of Vietoris-Rips complexes is due to Edelsbrunner et al. [2000] and Carlsson [2009]. Our contribution is the precise equivalence between the sheaf condition and graph completeness, and the defect filtration as a persistence module.

## 2. Abstract Consistency Systems

**Definition 2.1** (Consistency System). An *abstract consistency system* on a type ι is a triple C = (ι, compatible, P) where:
- compatible : ι → ι → Prop is the compatibility relation
- P_symm : ∀ i j, compatible(i,j) → compatible(j,i) (symmetry)
- P_refl : ∀ i, compatible(i,i) (reflexivity)

**Definition 2.2** (Sheaf Condition). The *sheaf condition* for C is: ∀ i j : ι, compatible(i,j).

**Remark**: The sheaf condition asserts that the compatibility relation is the *total* relation (restricted to the universal relation minus the identity for irreflexive formulations). This is the discrete analogue of the Čech 0-cocycle condition.

## 3. The Consistency Nerve

**Definition 3.1** (Nerve Face). A finset σ ⊆ ι is a *face* of the consistency nerve if ∀ i ∈ σ, ∀ j ∈ σ, compatible(i,j).

**Theorem 3.1** (Hereditary Property). If σ is a face and τ ⊆ σ, then τ is a face. □

This makes the consistency nerve an abstract simplicial complex in the standard sense.

**Theorem 3.2** (Singletons and Emptyset). The empty set and every singleton {i} are faces. □

**Theorem 3.3** (Pair Characterization). {i,j} is a face ↔ compatible(i,j). □

**Theorem 3.4** (Nerve-Sheaf Equivalence). The following are equivalent:
1. Every finset σ ⊆ ι is a face of the consistency nerve.
2. The sheaf condition holds.

*Proof sketch*: (1→2): Apply to σ = {i,j}. (2→1): For any σ and any i,j ∈ σ, use the sheaf condition. □

**Corollary 3.5**. The full universe Finset.univ is a face ↔ the sheaf condition holds. □

## 4. The Consistency Graph

**Definition 4.1**. The *consistency graph* G_C has vertex set ι and edge set {(i,j) : i ≠ j ∧ compatible(i,j)}.

**Theorem 4.1** (Completeness-Sheaf Equivalence). G_C is complete ↔ the sheaf condition holds.

*Proof*: (→): For i = j, use reflexivity. For i ≠ j, use completeness to get the edge, which gives compatible(i,j). (←): For i ≠ j, the sheaf condition gives compatible(i,j), so (i,j) is an edge. □

## 5. The Conflict Graph

**Definition 5.1**. The *conflict graph* Ḡ_C has vertex set ι and edge set {(i,j) : i ≠ j ∧ ¬compatible(i,j)}.

**Theorem 5.1** (Conflict-Sheaf Duality). Ḡ_C is edgeless ↔ the sheaf condition holds.

*Proof*: (→): If ¬compatible(i,j) and i ≠ j, then (i,j) is a conflict edge, contradicting edgelessness. So compatible(i,j) for all i,j (using reflexivity when i = j). (←): If compatible(i,j) for all i,j, no edge can exist (the second conjunct of the edge condition always fails). □

**Corollary 5.2**. The consistency graph is complete ↔ the conflict graph is edgeless.

## 6. Defect Filtration

**Definition 6.1** (Defect Measure). A *defect measure* on ι is a triple D = (defect, P_symm, P_zero) where:
- defect : ι → ι → ℕ
- P_symm : ∀ i j, defect(i,j) = defect(j,i)
- P_zero : ∀ i, defect(i,i) = 0

**Definition 6.2** (Approximate System). The *t-approximate consistency system* D_t has compatible_t(i,j) ↔ defect(i,j) ≤ t.

**Theorem 6.1** (Monotonicity). If t₁ ≤ t₂ and σ is a face at threshold t₁, then σ is a face at threshold t₂.

*Proof*: If defect(i,j) ≤ t₁ ≤ t₂, then defect(i,j) ≤ t₂. □

This defines a filtration of simplicial complexes:
Nerve₀ ⊆ Nerve₁ ⊆ Nerve₂ ⊆ ⋯

**Definition 6.3** (Critical Threshold). The *critical threshold* of σ is:
ct(σ) = max{defect(i,j) : i,j ∈ σ}

**Theorem 6.2** (Birth Time). σ is a face at threshold ct(σ).

*Proof*: For i,j ∈ σ, defect(i,j) ≤ max over all pairs in σ = ct(σ). □

**Theorem 6.3** (Zero Threshold). If compatible(i,j) ↔ defect(i,j) = 0, then the 0-approximate nerve equals the exact nerve.

*Proof*: isApproxNerveFace D 0 σ ↔ ∀ i,j ∈ σ, defect(i,j) ≤ 0 ↔ ∀ i,j ∈ σ, defect(i,j) = 0 ↔ ∀ i,j ∈ σ, compatible(i,j) ↔ isNerveFace C σ. □

**Theorem 6.4** (Obstruction). If t < defect(i,j), then {i,j} is not a face at threshold t.

*Proof*: Contrapositive of the face condition applied to the pair. □

### 6.1 Connection to Persistent Homology

The defect filtration defines a persistence module in the sense of topological data analysis. The persistent Betti numbers β_k(t₁, t₂) count the k-dimensional holes that are born at or before threshold t₁ and survive to threshold t₂. This connects the consistency analysis to the full machinery of persistence barcodes and stability theorems.

**Conjecture** (Stability): If D₁ and D₂ are defect measures with |D₁.defect(i,j) - D₂.defect(i,j)| ≤ ε for all i,j, then the bottleneck distance between the persistence diagrams of their defect filtrations is at most ε.

## 7. Gluing Theory

**Definition 7.1** (Partial Assignment). A *partial assignment* f : α → Option V assigns optional values to positions.

**Definition 7.2** (PA-Consistency). f and g are *PA-consistent* if they agree wherever both are defined: ∀ x, f(x) = some v₁ → g(x) = some v₂ → v₁ = v₂.

**Definition 7.3** (Gluing). The *gluing* of f and g is: (f ⊔ g)(x) = f(x) if defined, else g(x).

**Theorem 7.1** (Gluing Extension). The gluing extends the first argument (always) and the second (on gaps):
- f(x) = some v → (f ⊔ g)(x) = some v
- f(x) = none ∧ g(x) = some v → (f ⊔ g)(x) = some v

**Theorem 7.2** (Consistency Preservation). If f, g, h are pairwise PA-consistent, then f ⊔ g is PA-consistent with h.

*Proof*: For any x with (f ⊔ g)(x) = some v₁ and h(x) = some v₂, case-split on whether f(x) is defined. If so, v₁ comes from f and consistency of f with h applies. Otherwise, v₁ comes from g and consistency of g with h applies. □

**Theorem 7.3** (Bridge). The abstract sheaf condition for the PA consistency system equals pairwise PA-consistency:
(paConsistencySystem dbs).sheafCondition ↔ ∀ i j, PAConsistent (dbs i) (dbs j)

## 8. Discussion

### 8.1 The Hereditary Property and Independence Systems

The consistency nerve is closed under taking subsets (hereditary property), making it an *independence system* in the sense of matroid theory. A natural question is: when does the consistency nerve satisfy the *exchange axiom*, making it a matroid? This would connect data consistency to the rich theory of greedy algorithms and matroid optimization.

### 8.2 Computational Complexity

For a family of n databases, checking the sheaf condition requires O(n²) pairwise consistency checks. The full nerve has up to 2ⁿ potential faces, but the clique complex structure means it's determined by its 1-skeleton (the consistency graph). Computing the clique complex of a graph is in general NP-hard, but specialized structure (chordality, bounded treewidth) can make it tractable.

### 8.3 Limitations

Our framework assumes an exact, binary notion of consistency. Real-world data integration often involves fuzzy matching, probabilistic consistency, and multi-valued attributes. The defect filtration addresses quantitative aspects, but a more principled probabilistic framework — perhaps via sheaves of probability measures — remains future work.

## 9. Conclusion

The Consistency Nerve provides a rigorous geometric framework for understanding data compatibility. The central Nerve-Sheaf Equivalence shows that the global integrability of a data family is equivalent to the combinatorial completeness of its consistency graph — a surprisingly clean bridge between sheaf theory, simplicial topology, and graph theory. The defect filtration extends this to approximate consistency, connecting to the persistence machinery of topological data analysis.

All results are formally verified in Lean 4 with Mathlib, requiring only the standard axioms (propext, Classical.choice, Quot.sound).

## References

- Carlsson, G. (2009). Topology and data. *Bulletin of the AMS*, 46(2), 255–308.
- Curry, J. (2014). Sheaves, cosheaves, and applications. PhD thesis, University of Pennsylvania.
- Edelsbrunner, H., Letscher, D., and Zomorodian, A. (2000). Topological persistence and simplification. *Discrete & Computational Geometry*, 28(4), 511–533.
- Goguen, J. (1992). Sheaf semantics for concurrent interacting objects. *Mathematical Structures in Computer Science*, 2(2), 159–191.
- Jonsson, J. (2008). *Simplicial Complexes of Graphs*. Springer.
- Robinson, M. (2014). *Topological Signal Processing*. Springer.

## Appendix A: Formal Verification Summary

| Theorem | Axioms Used | Lines |
|---------|------------|-------|
| nerve_hereditary | propext, Quot.sound | 1 |
| nerve_full_simplex_iff_allPairs | propext, Quot.sound | 3 |
| consistency_graph_complete_iff | propext, Quot.sound | 3 |
| conflict_edgeless_iff_sheaf | propext, Classical.choice, Quot.sound | 2 |
| defect_nerve_antitone | propext, Quot.sound | 1 |
| face_at_critical_threshold | propext, Classical.choice, Quot.sound | 2 |
| approx_nerve_zero | propext, Quot.sound | 3 |
| not_face_below_pair_defect | propext, Classical.choice, Quot.sound | 2 |
| max_face_card_eq_card_iff_sheaf | propext, Quot.sound | 1 |
| paglue_preserves_consistency | propext | 3 |
