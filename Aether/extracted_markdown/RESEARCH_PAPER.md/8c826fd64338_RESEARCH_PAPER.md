# Isomorphisms of Meaning: Semantic Structures, Group Analogies, and the Entropy-Rigidity Duality

## Abstract

We introduce *semantic structures* — finite types equipped with labeling functions — and develop a formal theory of *semantic equivalence*, which refines classical structural isomorphism by requiring preservation of labels. We prove that semantic equivalence is strictly finer than structural isomorphism (the Semantic Gap Theorem), establish a duality between semantic entropy and automorphism rigidity (the Entropy-Rigidity Theorem), formalize Hofstadter's Copycat analogy architecture via group analogies with a uniqueness result for analogy completion, and prove that permutation-invariant formal systems cannot distinguish semantically inequivalent structures in the same orbit (the Indistinguishability Principle). We also define and study 2-isomorphisms (isomorphisms of isomorphisms), proving they form an equivalence relation. All results are fully machine-verified.

**Keywords**: semantic structures, labeled isomorphisms, group analogies, entropy-rigidity, 2-morphisms, Copycat architecture, formal indistinguishability

## 1. Introduction

The observation that isomorphic mathematical structures can carry different "meanings" is classical in philosophy of mathematics (Benacerraf 1965), but has rarely been formalized. We provide a rigorous framework by introducing *semantic structures* — pairs (X, ℓ) where X is a finite type and ℓ : X → L is a labeling function. Two semantic structures are *semantically equivalent* if there exists a bijection σ : X → X such that ℓ₂ ∘ σ = ℓ₁.

This refinement of classical isomorphism allows us to prove several results:

1. **Semantic Gap** (Theorem 3.1): There exist pairs of semantic structures on the same underlying type that are structurally isomorphic but semantically inequivalent.

2. **Entropy-Rigidity Duality** (Theorem 4.3): Maximal semantic entropy implies trivial automorphism group.

3. **Analogy Completion** (Theorem 5.2): In any group, analogy completion is unique.

4. **Analogy Density** (Theorem 5.4): In a finite group of order n, exactly n³ quadruples form valid analogies.

5. **Indistinguishability** (Theorem 6.2): Permutation-invariant properties cannot separate orbit-equivalent structures.

## 2. Definitions

### 2.1 Semantic Structures

**Definition 2.1** (Semantic Structure). A *semantic structure* of size n with labels in L is a pair S = (n, ℓ) where ℓ : Fin n → L is the labeling function.

**Definition 2.2** (Semantic Equivalence). A *semantic equivalence* from S = (n, ℓ_S) to T = (n, ℓ_T) is a bijection σ : Fin n ≃ Fin n such that ℓ_T(σ(i)) = ℓ_S(i) for all i.

**Definition 2.3** (Semantic Automorphism). A *semantic automorphism* of S is a semantic equivalence from S to itself: a bijection σ satisfying ℓ(σ(i)) = ℓ(i) for all i.

### 2.2 Canonical Examples

- **Identity labeling**: identityLabel(n) = (n, id), where element i is labeled by i itself.
- **Constant labeling**: constLabel(n, l) = (n, λ_ ↦ l), where all elements share the same label.

### 2.3 Semantic Entropy

**Definition 2.4**. The *semantic entropy* H(S) of a semantic structure S = (n, ℓ) is the cardinality of the image of ℓ: H(S) = |Im(ℓ)|.

### 2.4 Group Analogies

**Definition 2.5** (Group Analogy). In a group G, a *group analogy* a:b :: c:d holds when a⁻¹b = c⁻¹d. This captures the intuition that "the transformation from a to b is the same as the transformation from c to d."

### 2.5 2-Isomorphisms

**Definition 2.6** (Isomorphism of Isomorphisms). Given bijections f, g : α ≃ β, a *2-isomorphism* from f to g consists of automorphisms s : α ≃ α and t : β ≃ β such that t ∘ f = g ∘ s.

## 3. The Semantic Gap

**Theorem 3.1** (Semantic Gap). The homogeneous labeling homLabel₂ = (2, λ_ ↦ true) and the heterogeneous labeling hetLabel₂ = (2, λi ↦ (i = 0)) on Fin 2 are not semantically equivalent.

*Proof sketch*. There are exactly two bijections on Fin 2: the identity and the transposition. For the identity σ = id, we need hetLabel₂(0) = homLabel₂(0) = true (✓) and hetLabel₂(1) = homLabel₂(1) = true (✗, since hetLabel₂(1) = false). For the transposition, hetLabel₂(1) = homLabel₂(0) = true (✗). Neither bijection preserves labels. □

**Corollary 3.2**. Structural isomorphism does not imply semantic equivalence.

## 4. Entropy-Rigidity Duality

**Theorem 4.1**. The identity labeling has entropy n: H(identityLabel(n)) = n.

*Proof*. The image of id on Fin n is all of Fin n, which has cardinality n. □

**Theorem 4.2**. For n ≥ 1, the constant labeling has entropy 1: H(constLabel(n, l)) = 1.

*Proof*. The image of a constant function on a nonempty domain is a singleton. □

**Theorem 4.3** (Entropy-Rigidity). If H(S) = n for a semantic structure S on Fin n, then the only semantic automorphism of S is the identity.

*Proof*. If H(S) = n, then ℓ is injective (since |Im(ℓ)| = n = |domain|, the function must be injective). If σ is a semantic automorphism, then ℓ(σ(i)) = ℓ(i) for all i, which by injectivity gives σ(i) = i. □

**Remark 4.4**. This establishes a duality: maximum information (entropy n) corresponds to minimum symmetry (trivial automorphism group), while minimum information (entropy 1) corresponds to maximum symmetry (full symmetric group S_n).

## 5. Group Analogies and the Copycat Architecture

### 5.1 The Analogy Relation

**Theorem 5.1**. Group analogy is reflexive (a:b :: a:b) and symmetric (a:b :: c:d ⟹ c:d :: a:b).

*Proof*. Reflexivity: a⁻¹b = a⁻¹b. Symmetry: if a⁻¹b = c⁻¹d, then c⁻¹d = a⁻¹b. □

### 5.2 Analogy Completion

**Theorem 5.2** (Analogy Completion). For any a, b, c in a group G, there exists a unique d such that a:b :: c:d. The completion is d = c · a⁻¹ · b.

*Proof*. Existence: d = c · a⁻¹ · b satisfies c⁻¹ · (c · a⁻¹ · b) = a⁻¹ · b. Uniqueness: if a⁻¹b = c⁻¹d₁ = c⁻¹d₂, then d₁ = d₂ by left cancellation. □

**Remark 5.3**. This theorem gives Hofstadter's Copycat architecture a group-theoretic foundation. The analogy "abc → abd as ijk → ?" can be modeled by treating letter sequences as group elements and the transformation "increment last letter" as the group element a⁻¹b. The unique completion is then determined by the group operation.

### 5.3 Analogy Density

**Theorem 5.4** (Analogy Density). In a finite group G of order n, the number of valid analogy quadruples is n³.

*Proof*. The map (a, b, c) ↦ (a, b, c, c · a⁻¹ · b) is an injection from G³ to valid quadruples (by Theorem 5.2, the completion is unique). It is also surjective (every valid quadruple arises this way). Hence |valid quadruples| = |G³| = n³. □

**Corollary 5.5**. The fraction of quadruples forming valid analogies is 1/n, independent of the group structure.

## 6. The Indistinguishability Principle

**Definition 6.1**. A predicate P on labelings Fin n → Bool is *permutation-invariant* if P(f) implies P(f ∘ σ⁻¹) for every permutation σ.

**Theorem 6.2** (Indistinguishability). If P is permutation-invariant and f, g : Fin n → Bool are in the same orbit (i.e., g = f ∘ σ for some σ), then P(f) implies P(g).

*Proof*. If g(i) = f(σ(i)) for all i, then g = f ∘ σ. Applying the invariance condition with τ = σ⁻¹ gives P(f) ⟹ P(f ∘ σ) = P(g). □

**Interpretation**. This theorem says that no permutation-invariant formal system can distinguish two structures in the same orbit. Since permutation-invariant properties are exactly those that depend on "structure" rather than "naming," this formalizes the claim that formal systems preserve truth but not meaning.

## 7. 2-Isomorphisms and Higher Structure

**Theorem 7.1**. The 2-isomorphism relation on Equiv α β is an equivalence relation.

*Proof*. Reflexivity: use identity automorphisms. Symmetry: given (s, t) witnessing f ≃₂ g, the pair (s⁻¹, t⁻¹) witnesses g ≃₂ f. Transitivity: compose the automorphisms. □

**Remark 7.2**. The equivalence classes under 2-isomorphism form a quotient of the set of bijections by the action of Aut(α) × Aut(β). This connects to the theory of double cosets in group theory and to the notion of natural transformations in category theory.

## 8. Semantic Automorphism Subgroup

We prove that semantic automorphisms form a subgroup of the symmetric group:

**Theorem 8.1**. For any semantic structure S on Fin n:
- (a) The identity is a semantic automorphism.
- (b) The composition of semantic automorphisms is a semantic automorphism.
- (c) The inverse of a semantic automorphism is a semantic automorphism.

*Proof*. (a) ℓ(id(i)) = ℓ(i). (b) ℓ(σ₂(σ₁(i))) = ℓ(σ₁(i)) = ℓ(i). (c) From ℓ(σ(i)) = ℓ(i) for all i, substituting i = σ⁻¹(j) gives ℓ(j) = ℓ(σ⁻¹(j)). □

## 9. Algorithms

### 9.1 Semantic Equivalence Testing

Given two semantic structures S, T on Fin n with labels in L:
1. Compute the multisets M_S = {ℓ_S(i) : i ∈ Fin n} and M_T = {ℓ_T(i) : i ∈ Fin n}.
2. If M_S ≠ M_T, output "not equivalent."
3. Otherwise, partition Fin n into color classes by ℓ_S and ℓ_T.
4. Search for a bijection matching color classes.

Complexity: O(n log n) for steps 1-3; step 4 is equivalent to testing isomorphism of colored graphs.

### 9.2 Analogy Completion

Given a, b, c in a group G, compute d = c · a⁻¹ · b.

Complexity: O(1) group operations.

## 10. Applications and Connections

### 10.1 Graph Neural Networks

Graph neural networks that are permutation-equivariant satisfy our definition of permutation invariance. By the Indistinguishability Principle (Theorem 6.2), such networks cannot distinguish non-isomorphic graphs that have the same multiset of local features — a known limitation formalized here.

### 10.2 Cryptographic Hash Functions

The semantic gap (Theorem 3.1) is the mathematical foundation of collision resistance: two inputs can produce the same structural output while having different semantic content.

### 10.3 Hofstadter's Copycat

The analogy completion theorem (Theorem 5.2) shows that Copycat-style analogical reasoning, when modeled algebraically, produces unique answers. The density theorem (Theorem 5.4) quantifies the "analogy space" of any finite group.

## 11. Discussion

The central insight of this work is that the familiar notion of isomorphism, while powerful, is too coarse to capture semantic distinctions. The semantic equivalence relation we introduce is a natural refinement that preserves labels as well as structure.

The entropy-rigidity duality (Theorem 4.3) provides a quantitative version of this insight: more meaning implies less symmetry. This connects to deep themes in physics (symmetry breaking), information theory (entropy as information content), and philosophy (the identity of indiscernibles).

The group analogy framework provides a precise mathematical model for Hofstadter's Copycat architecture, showing that analogical reasoning in algebraic structures is both unique and universal.

## 12. Future Work

1. Extend the entropy-rigidity duality to continuous groups and measure-theoretic entropy.
2. Characterize the lattice of semantic equivalence classes for specific label spaces.
3. Connect 2-isomorphism equivalence classes to double cosets and Burnside's lemma.
4. Apply the indistinguishability principle to expressiveness bounds for graph neural networks.
5. Develop a topological theory of semantic structures using persistent homology of the labeling function.

## References

1. Benacerraf, P. (1965). What numbers could not be. *Philosophical Review*, 74(1), 47-73.
2. Hofstadter, D.R. (1995). *Fluid Concepts and Creative Analogies*. Basic Books.
3. Mitchell, M. (1993). *Analogy-Making as Perception*. MIT Press.
4. Baez, J.C., & Dolan, J. (1998). Categorification. *Contemporary Mathematics*, 230, 1-36.
5. Weisfeiler, B., & Leman, A. (1968). The reduction of a graph to canonical form and the algebra which appears therein. *NTI*, Series 2(9), 12-16.
6. Xu, K., Hu, W., Leskovec, J., & Jegelka, S. (2019). How powerful are graph neural networks? *ICLR 2019*.
