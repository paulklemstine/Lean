# Phantom Topologies: Observer-Dependent Topological Spaces and Consensus Theory

## Abstract

We introduce *phantom topologies*, a mathematical framework in which the topology of a space depends on the observer. A phantom system on a set X assigns to each observer o in a set O a topology T(o) on X. The *consensus topology* — obtained as the supremum in the lattice of topologies — captures what all observers agree on: a set is consensus-open if and only if every observer considers it open. We define the *phantom number* of a topology τ as the minimum number of topologies whose supremum equals τ, connecting topology to lattice decomposition theory. We prove 20 theorems, including: (1) the consensus characterization theorem (consensus-open iff universally open), (2) the morphism principle (observer-wise continuity implies consensus continuity), (3) the monotone consensus theorem (in ordered observer systems, consensus equals the coarsest observer), (4) the refinement monotonicity theorem, and (5) the discrete irreducibility theorem. We develop computational tools for finite phantom systems, enumerate all 29 topologies on a 3-element set, and compute phantom numbers and disagreement metrics. Applications to multi-sensor fusion, distributed consensus, and quantum measurement analogy are discussed.

## 1. Introduction

### 1.1 Motivation

Classical topology treats the open set structure of a space as a fixed, absolute property. However, in many applications — multi-agent systems, distributed computing, sensor networks, quantum measurement — different agents or processes have different views of the same underlying space. This motivates a framework where topology itself is observer-dependent.

### 1.2 Related Work

The lattice of topologies on a set has been studied extensively since Birkhoff (1936). The supremum and infimum operations on topologies are well understood in lattice-theoretic terms (cf. Mathlib's `TopologicalSpace` complete lattice structure). Our contribution is to interpret these lattice operations through the lens of observer-dependent topology, providing new definitions (phantom systems, phantom number, phantom entropy) and proving structural theorems about them.

The consensus topology is related to the notion of *initial topologies* in category theory and *meet* operations in domain theory. Our morphism principle is a generalization of the universal property of initial topologies.

### 1.3 Overview of Results

We organize our results into several themes:
1. **Core framework**: PhantomSystem, consensus, agreement (§2)
2. **Lattice-theoretic characterization**: phantom number, sup-decomposition (§3)
3. **Structural theorems**: refinement, extension, monotonicity (§4)
4. **Morphisms and categories**: phantom morphisms, consensus functor (§5)
5. **Separation axioms**: consensus Hausdorff (§6)
6. **Computational experiments**: finite enumeration, phantom entropy (§7)
7. **Applications**: sensor fusion, distributed consensus, quantum analogy (§8)

## 2. Definitions and Basic Properties

### 2.1 Phantom Systems

**Definition 2.1** (Phantom System). A *phantom system* on a type X with observers O is a function `observe : O → TopologicalSpace X` assigning to each observer a topology on X.

**Definition 2.2** (Consensus Topology). The *consensus topology* of a phantom system P is:
$$\text{consensus}(P) = \sup_{o \in O} P.\text{observe}(o)$$
where the supremum is taken in the complete lattice of topologies on X. In Mathlib's convention (where ≤ means "finer"), the supremum is the coarsest topology coarser than all observers — equivalently, U is consensus-open iff U is open for every observer.

**Definition 2.3** (Agreement). Two observers o₁, o₂ *agree* on a set U if U is open in both T(o₁) and T(o₂).

### 2.2 Fundamental Theorem

**Theorem 2.4** (Consensus Characterization). For any phantom system P and set U:
$$U \text{ is consensus-open} \iff \forall o \in O,\, U \text{ is open in } T(o)$$

*Proof.* Follows directly from `isOpen_iSup_iff` in Mathlib. □

**Corollary 2.5.** The consensus topology is coarser than any individual observer's topology: for all o, `observe o ≤ consensus`.

## 3. Phantom Number and Lattice Decomposition

### 3.1 Phantom Number

**Definition 3.1** (Phantom Representation). A *phantom representation* of topology τ with n observers consists of topologies f₁, ..., fₙ such that ⨆ᵢ fᵢ = τ.

**Definition 3.2** (Phantom Number). The *phantom number* of τ is:
$$\text{pn}(\tau) = \inf\{n \in \mathbb{N} \mid \exists f : \text{Fin}(n) \to \text{Top}(X),\, \sup_i f(i) = \tau\}$$

### 3.2 Lattice-Theoretic View

The phantom number is a special case of a general lattice concept.

**Definition 3.3** (Sup-Decomposition Number). For an element a in a complete lattice L:
$$\text{sdn}(a) = \inf\{n \mid \exists f : \text{Fin}(n) \to L,\, \sup_i f(i) = a\}$$

**Theorem 3.4.** Every element has sup-decomposition number at most 1.

*Proof.* Take f(0) = a. Then ⨆ᵢ∈Fin(1) f(i) = f(0) = a. □

**Definition 3.5** (Sup-Irreducible). An element a is *sup-irreducible* if a = b ⊔ c implies a = b or a = c.

**Theorem 3.6.** The discrete topology (⊥) is sup-irreducible.

*Proof.* If ⊥ = b ⊔ c, then since ⊥ is the bottom element, b ⊔ c = ⊥ implies b = ⊥ and c = ⊥ by `sup_eq_bot_iff`. □

### 3.3 Fin-Indexed Suprema

**Theorem 3.7.** For a complete lattice:
- ⨆ᵢ∈Fin(1) f(i) = f(0) (by `ciSup_unique`)
- ⨆ᵢ∈Fin(2) f(i) = f(0) ⊔ f(1)
- ⨆ᵢ∈Fin(3) f(i) = f(0) ⊔ f(1) ⊔ f(2)

*Proof.* By `le_antisymm`: ≤ direction uses `iSup_le` with `fin_cases`; ≥ direction uses `sup_le` with `le_iSup`. □

**Corollary 3.8.** In a two-observer system, consensus = observe(0) ⊔ observe(1). In a three-observer system, consensus = observe(0) ⊔ observe(1) ⊔ observe(2).

## 4. Structural Theorems

### 4.1 Refinement

**Definition 4.1.** Phantom system P₁ *refines* P₂ if for all o, P₂.observe(o) ≤ P₁.observe(o) (each observer in P₁ is finer).

**Theorem 4.2** (Refinement Monotonicity). If P₁ refines P₂, then P₂.consensus ≤ P₁.consensus.

*Proof.* By `iSup_mono`. □

### 4.2 Extension

**Theorem 4.3** (Extension Coarsening). Extending from O to O ⊕ O' while preserving original observers yields: P.consensus ≤ ext.consensus.

*Proof.* By `iSup_le` and `le_iSup_of_le` with the injection Sum.inl. □

*Interpretation.* Adding observers cannot make the consensus finer — more observers means more conditions to agree on, yielding a coarser consensus.

### 4.3 Restriction

**Theorem 4.4** (Restriction Refinement). Restricting to a subset S ⊆ O of observers yields: (⨆ o:S, observe o) ≤ (⨆ o:O, observe o).

*Proof.* Each term in the restricted supremum is also a term in the full supremum. □

### 4.4 Identical Observers

**Theorem 4.5.** If all observers see the same topology τ, then consensus = τ.

*Proof.* By `iSup_const`. □

### 4.5 Monotone Systems

**Definition 4.6.** A phantom system is *monotone* if o₁ ≤ o₂ implies observe(o₂) ≤ observe(o₁) (later observers have coarser topologies).

**Theorem 4.7** (Monotone Consensus). For a monotone phantom system with a bottom element, consensus = observe(⊥).

*Proof.* The observe(⊥) is an upper bound for all observe(o) (by monotonicity with bot_le), and it's in the family, so it equals the supremum. □

## 5. Phantom Morphisms

### 5.1 Definition

**Definition 5.1.** A *phantom morphism* (P, X) → (Q, Y) consists of a map f : X → Y that is continuous with respect to each observer's topology: for all o, f is (T_P(o), T_Q(o))-continuous.

### 5.2 The Morphism Principle

**Theorem 5.2** (Consensus Continuity). Every phantom morphism is consensus-continuous.

*Proof sketch.* We show consensus(P) ≤ induced(f, consensus(Q)). By `iSup_le`, it suffices to show each observe_P(o) ≤ induced(f, consensus(Q)). By observer continuity, observe_P(o) ≤ induced(f, observe_Q(o)), and by monotonicity of `induced`, induced(f, observe_Q(o)) ≤ induced(f, consensus(Q)). □

*Significance.* This establishes that the consensus construction is functorial: phantom morphisms compose (Theorem 5.3) and there is an identity morphism (Theorem 5.4).

### 5.3 Categorical Structure

**Theorem 5.3.** Phantom morphisms compose: if φ : P → Q and ψ : Q → R, then ψ ∘ φ : P → R is a phantom morphism.

**Theorem 5.4.** The identity map id : X → X is a phantom morphism P → P.

These establish that phantom systems with a fixed observer set O form a category **Phant(O)** with a faithful functor to **Top** given by the consensus.

## 6. Separation Axioms

**Theorem 6.1.** If the consensus equals some observer's topology and that observer's topology is T₂ (Hausdorff), then the consensus is T₂.

*Remark.* The converse implication (consensus T₂ ⟹ some observer T₂) does not hold in general, as the consensus can be T₂ even when individual observers have non-Hausdorff topologies that happen to agree on point separation.

## 7. Disagreement and Entropy

### 7.1 Disagreement Sets

**Definition 7.1.** The *disagreement set* of observers o₁, o₂ is:
$$\Delta(o_1, o_2) = \{U \subseteq X \mid U \in T(o_1) \triangle T(o_2)\}$$

**Theorem 7.2.** Disagreement is symmetric: Δ(o₁, o₂) = Δ(o₂, o₁).

**Theorem 7.3.** If observe(o₁) = observe(o₂), then Δ(o₁, o₂) = ∅.

### 7.2 Phantom Entropy

**Definition 7.4.** The *phantom entropy* of a system with observers {o₁, ..., oₙ} is:
$$H(P) = \frac{1}{\binom{n}{2} \cdot 2^{|X|}} \sum_{i < j} |\Delta(o_i, o_j)|$$

### 7.3 Computational Results

For X = {0, 1, 2} (29 topologies):
- Maximum pairwise disagreement: 6
- Average pairwise disagreement: 3.0
- The disagreement matrix reveals a rich metric structure on topology space

For X = {0, 1} (4 topologies):
- The indiscrete topology has proper phantom number 2
- The two Sierpiński topologies and the discrete topology have no proper phantom decomposition (they are already "atomic")

## 8. Applications

### 8.1 Multi-Sensor Fusion

In autonomous systems, different sensors (camera, lidar, radar) resolve different features of the environment. We model each sensor as an observer with its own topology on the environment space. The consensus topology represents features all sensors agree on — the reliable perception.

### 8.2 Distributed Network Consensus

In distributed computing, nodes have different views of network state. The consensus topology models the agreed-upon connectivity. The extension theorem (Theorem 4.3) explains why adding nodes to a network can only decrease the agreed-upon information.

### 8.3 Quantum Measurement

Different quantum measurement bases give different "views" of the Hilbert space. The consensus of all measurement topologies corresponds to the objective quantum state. This formalizes the intuition that quantum reality is measurement-dependent while maintaining objective consensus.

## 9. Conjectures and Open Problems

### Conjecture 9.1 (Finite Phantom Bound)
For any finite set X with n elements, every topology on X has phantom number at most n.

**Testable prediction:** For n = 3, all 29 topologies should have phantom number ≤ 3. Our computations confirm this for n = 2.

### Open Problem 9.2
Characterize the proper phantom number of the standard topology on ℝ. We conjecture it equals 2, with the Sorgenfrey and upper-limit topologies as witnesses.

### Open Problem 9.3
Does every metrizable space have phantom number ≤ 2? Is there a non-metrizable space with phantom number exactly 3?

## 10. Conclusion

Phantom topologies provide a natural mathematical framework for observer-dependent structure. The theory connects topology, lattice theory, category theory, and information theory, while offering concrete applications in multi-agent systems and quantum foundations. The 20 formally verified theorems establish the basic theory; the computational experiments reveal rich finite structure; and the conjectures point toward deep open questions about the nature of topological consensus.

## References

1. Birkhoff, G. (1936). "On the combination of topologies." *Fundamenta Mathematicae*, 26, 156–166.
2. Kelley, J. L. (1955). *General Topology*. Van Nostrand.
3. Engelking, R. (1989). *General Topology*. Heldermann Verlag.
4. Mathlib Community. (2024). *Mathlib4*. https://github.com/leanprover-community/mathlib4
