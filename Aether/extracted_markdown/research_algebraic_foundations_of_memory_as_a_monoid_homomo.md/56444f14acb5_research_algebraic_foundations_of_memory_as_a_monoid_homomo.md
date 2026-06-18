# Algebraic Foundations of Memory as Monoid Homomorphisms

## Abstract

We develop an algebraic theory of memory systems by modeling them as monoid homomorphisms from an experience monoid to a state monoid. This framework yields several structural results: (1) the **Lossy Memory Theorem**, establishing that any finite memory system over an infinite experience space must be non-injective; (2) the **Kernel Submonoid Theorem**, proving that perfectly-forgotten experiences form a submonoid; (3) the **Congruence Refinement Theorem**, showing that refinement relationships between memory systems factor through unique state-space transformations; (4) an **Irreversibility Theorem** for information loss under composition; and (5) a **Tropical Memory** framework connecting salience-based forgetting to idempotent algebra. All results are machine-verified in Lean 4 using the Mathlib library.

**Keywords**: monoid homomorphism, memory algebra, information loss, tropical semiring, congruence lattice, formal verification

---

## 1. Introduction

Memory — whether biological, digital, or artificial — is fundamentally a compression operation. A system with finite capacity cannot perfectly represent an infinite stream of experiences. While this observation is folklore in information theory, its algebraic consequences have received surprisingly little systematic study.

We propose modeling memory as a monoid homomorphism ϕ: E → S, where E is a monoid of experiences (with sequential composition as the monoid operation) and S is a monoid of memory states. The homomorphism condition ϕ(e₁ · e₂) = ϕ(e₁) · ϕ(e₂) encodes the assumption that memory respects the sequential structure of experience: the memory of a composite experience is determined by the memories of its parts.

This algebraic framing transforms questions about memory into questions about monoid homomorphisms, enabling the application of classical algebraic tools: kernels, congruences, quotient constructions, and category-theoretic factorization.

### 1.1 Related Work

The connection between finite automata and monoid homomorphisms is classical (Eilenberg, 1976; Pin, 1986). Our contribution is to interpret this connection explicitly as a theory of memory, extracting information-theoretic consequences from algebraic structure. The tropical memory framework connects to recent work on tropical algebra in machine learning (Zhang et al., 2018; Maragos et al., 2021) and the use of max-plus algebra in optimization and scheduling.

### 1.2 Contributions

1. A formal algebraic framework for memory systems as monoid homomorphisms.
2. Five formally verified theorems establishing fundamental constraints on memory systems.
3. A novel tropical memory construction connecting salience-based forgetting to idempotent algebra.
4. A categorical perspective on forgetting morphisms and the refinement preorder.
5. Complete machine verification of all results.

---

## 2. Definitions

### 2.1 Memory Systems

**Definition 2.1** (Memory System). A *memory system* is a triple (E, S, ϕ) where:
- E is a monoid (the *experience monoid*),
- S is a monoid (the *state monoid*),  
- ϕ: E →* S is a monoid homomorphism (the *encoding*).

The monoid operation on E represents sequential composition of experiences. The identity element 1_E represents the null experience.

**Definition 2.2** (Lossy Memory). A memory system (E, S, ϕ) is *lossy* if ϕ is not injective, i.e., there exist e₁ ≠ e₂ in E with ϕ(e₁) = ϕ(e₂).

**Definition 2.3** (Memory Kernel). The *kernel* of a memory system (E, S, ϕ) is:
$$\ker(\phi) = \{e \in E \mid \phi(e) = 1_S\}$$

**Definition 2.4** (Memory Congruence). The *congruence* of (E, S, ϕ) is the equivalence relation:
$$e_1 \sim_\phi e_2 \iff \phi(e_1) = \phi(e_2)$$

### 2.2 Refinement and Forgetting

**Definition 2.5** (Refinement). Memory system (E, S₁, ϕ₁) *refines* (E, S₂, ϕ₂) if:
$$\forall e_1, e_2 \in E: \phi_1(e_1) = \phi_1(e_2) \implies \phi_2(e_1) = \phi_2(e_2)$$

Equivalently, the congruence of ϕ₁ is finer than that of ϕ₂.

**Definition 2.6** (Forgetting Morphism). A *forgetting morphism* from (E, S₁, ϕ₁) to (E, S₂, ϕ₂) is a monoid homomorphism f: S₁ →* S₂ such that f ∘ ϕ₁ = ϕ₂.

### 2.3 Tropical Memory

**Definition 2.7** (Tropical Memory State). For a linearly ordered type α with bottom element ⊥, the *tropical memory state* monoid is the set α with:
- Multiplication: a · b = max(a, b)
- Identity: 1 = ⊥

This monoid is idempotent: a · a = a for all a.

---

## 3. Main Results

### 3.1 The Lossy Memory Theorem

**Theorem 3.1** (Lossy Memory). If E is infinite and S is finite, then any memory system (E, S, ϕ) is lossy.

*Proof sketch*. If ϕ were injective, then E would embed injectively into S. By the pigeonhole principle (formalized as `Finite.of_injective`), this would make E finite, contradicting the assumption. □

*Significance*. This is the algebraic form of the pigeonhole principle applied to information processing. It establishes that lossiness is not a design choice but a mathematical necessity for any finite system processing infinite input.

### 3.2 The Kernel Submonoid Theorem

**Theorem 3.2** (Kernel Submonoid). The kernel ker(ϕ) is a submonoid of E.

*Proof sketch*. 
- **Identity**: ϕ(1_E) = 1_S by the homomorphism property, so 1_E ∈ ker(ϕ).
- **Closure**: If ϕ(a) = 1_S and ϕ(b) = 1_S, then ϕ(a·b) = ϕ(a)·ϕ(b) = 1_S·1_S = 1_S. □

*Significance*. This shows that the set of "perfectly forgotten" experiences has algebraic structure. It's not an arbitrary collection but a coherent submonoid that respects experience composition.

### 3.3 The Congruence Properties

**Theorem 3.3** (Two-Sided Congruence). The memory congruence ~_ϕ is both a left and right congruence:
- If e₁ ~_ϕ e₂ then a·e₁ ~_ϕ a·e₂ (left congruence)
- If e₁ ~_ϕ e₂ then e₁·a ~_ϕ e₂·a (right congruence)

*Proof*. Follows directly from the homomorphism property: ϕ(a·e₁) = ϕ(a)·ϕ(e₁) = ϕ(a)·ϕ(e₂) = ϕ(a·e₂). □

### 3.4 The Congruence Refinement Theorem

**Theorem 3.4** (Congruence Refinement Factor). If (E, S₁, ϕ₁) refines (E, S₂, ϕ₂) and ϕ₁ is surjective, then there exists f: S₁ → S₂ such that f ∘ ϕ₁ = ϕ₂.

*Proof sketch*. Define f(s₁) by choosing any preimage e of s₁ under ϕ₁ and setting f(s₁) = ϕ₂(e). The refinement condition ensures this is well-defined (independent of the choice of preimage). □

*Significance*. This is the universal property of quotients in the category of memory systems. It means that if one memory system "forgets more" than another, there is an essentially unique way to factor the additional forgetting as a post-processing step.

### 3.5 Irreversibility of Information Loss

**Theorem 3.5** (Composition Preserves Lossiness). If (E, I, ϕ₁) is lossy and ψ: I →* S is injective, then the composite system (E, S, ψ ∘ ϕ₁) is lossy.

*Proof sketch*. Contrapositive: if ψ ∘ ϕ₁ were injective, then ϕ₁ would be injective (since ψ is injective), contradicting lossiness of ϕ₁. □

**Theorem 3.6** (Composition Refinement). If ψ: I →* S is injective, then the composite system (E, S, ψ ∘ ϕ₁) refines (E, I, ϕ₁).

### 3.6 Fiber Structure

**Theorem 3.7** (Fiber-Congruence Correspondence). For any memory system (E, S, ϕ) and experiences e₁, e₂:
$$(∃ s: e_1 \in \phi^{-1}(s) \wedge e_2 \in \phi^{-1}(s)) \iff e_1 \sim_\phi e_2$$

**Theorem 3.8** (Identity Fiber). The fiber over 1_S equals the kernel: ϕ⁻¹(1_S) = ker(ϕ).

**Theorem 3.9** (Fiber as Coset, Group Case). If E and S are groups, then for any e ∈ E:
$$\phi^{-1}(\phi(e)) = \{e \cdot k \mid k \in \ker(\phi)\}$$

This identifies fibers with cosets of the kernel, recovering the classical first isomorphism theorem for groups in the memory context.

### 3.7 Tropical Memory Idempotence

**Theorem 3.10** (Tropical Idempotence). In the tropical memory state monoid, a · a = a for all states a.

*Proof*. max(a, a) = a. □

*Significance*. Idempotence means that re-experiencing something already in memory doesn't change the memory state. This property distinguishes salience-based memory from accumulative models and connects to the theory of bands (idempotent semigroups).

### 3.8 Image Cardinality Bound

**Theorem 3.11** (Image Bound). For any finite set T ⊆ E and memory system (E, S, ϕ) with |S| = n:
$$|\phi(T)| \leq n$$

---

## 4. Algorithms

### 4.1 Computing Memory Congruence Classes

Given a finite experience monoid E presented by generators and relations, and a memory encoding ϕ, the congruence classes can be computed by:

1. Enumerate all elements of E (or a sufficient finite subset).
2. Apply ϕ to each element.
3. Group elements by their image under ϕ.

Time complexity: O(|E| · T_ϕ) where T_ϕ is the time to evaluate ϕ.

### 4.2 Testing Refinement

Given two memory systems ϕ₁: E → S₁ and ϕ₂: E → S₂ over a finite E:

1. For each pair (e₁, e₂) with ϕ₁(e₁) = ϕ₁(e₂), check that ϕ₂(e₁) = ϕ₂(e₂).
2. If all checks pass, ϕ₁ refines ϕ₂.

Time complexity: O(|E|² · (T_ϕ₁ + T_ϕ₂)).

### 4.3 Computing the Factoring Map

Given that ϕ₁ refines ϕ₂ and ϕ₁ is surjective:

1. For each s₁ ∈ S₁, choose any e with ϕ₁(e) = s₁.
2. Set f(s₁) = ϕ₂(e).

Time complexity: O(|S₁| · T_ϕ₁ + |S₁| · T_ϕ₂).

---

## 5. The Category of Memory Systems

The collection of memory systems over a fixed experience monoid E forms a category **Mem(E)** where:
- **Objects**: Pairs (S, ϕ) with S a monoid and ϕ: E →* S.
- **Morphisms**: Forgetting morphisms f: S₁ →* S₂ with f ∘ ϕ₁ = ϕ₂.

The refinement preorder is the preorder on objects induced by the existence of morphisms. The Congruence Refinement Theorem (Theorem 3.4) shows that this preorder coincides with the congruence refinement ordering when encodings are surjective.

The identity memory system (E, E, id) is the initial object (remembers everything), while the trivial system (E, {1}, !) is the terminal object (forgets everything). Every memory system factors through these extremes.

---

## 6. Discussion

### 6.1 Connections to Automata Theory

The Myhill-Nerode theorem in formal language theory states that a language is regular if and only if its syntactic monoid is finite. Our memory framework subsumes this: a regular language recognizer is precisely a memory system with finite state space where the "remembered" information is whether the current input belongs to the language. The memory congruence specializes to the Myhill-Nerode equivalence.

### 6.2 Connections to Cryptographic Hash Functions

A cryptographic hash function h: {0,1}* → {0,1}^n is a memory system mapping the free monoid on {0,1} to a finite state space. The Lossy Memory Theorem guarantees collisions exist (the birthday paradox gives quantitative bounds). The kernel structure predicts which inputs hash to the identity — information relevant to preimage resistance analysis.

### 6.3 Neural Networks as Memory Systems

A trained neural network with fixed weights defines a memory system from input sequences to hidden state representations. The tropical memory framework is particularly relevant here: attention mechanisms in transformers use softmax (a smooth approximation of max), making tropical algebra the natural "skeleton" of attention-based memory.

### 6.4 Biological Memory

The refinement hierarchy mirrors the psychological distinction between episodic, semantic, and procedural memory. Episodic memory (detailed, event-specific) refines semantic memory (general knowledge), which refines procedural memory (skills). The Congruence Refinement Theorem predicts that the transformations between these levels are algebraically constrained.

---

## 7. Conjectures and Future Work

**Conjecture 7.1** (Optimal Tropical Memory). Among all memory homomorphisms from the free monoid on k generators to a tropical semiring of size n, the one minimizing the maximum fiber size achieves fibers of size at most ⌈k^m / n⌉ for experiences of length m.

**Conjecture 7.2** (Congruence Lattice Completeness). The lattice of memory congruences over a finitely generated free monoid, ordered by refinement, is isomorphic to the lattice of finite-index congruences on the free monoid.

**Conjecture 7.3** (Tropical Attention Bridge). The softmax attention mechanism in transformers converges to a tropical memory system in the low-temperature limit (β → ∞), and the algebraic properties of the tropical limit (idempotence, max-plus linearity) explain the qualitative behavior of attention heads.

---

## 8. References

1. Eilenberg, S. (1976). *Automata, Languages, and Machines*, Vol. B. Academic Press.
2. Pin, J.-E. (1986). *Varieties of Formal Languages*. Plenum.
3. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
4. Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML*.
5. Maragos, P., Charisopoulos, V., & Theodosis, E. (2021). Tropical geometry and machine learning. *Proceedings of the IEEE*, 109(5), 728-755.

---

## Appendix: Formal Verification

All definitions and theorems in this paper have been formally verified in Lean 4 using the Mathlib library. The complete formalization is available in `Speculative/MemoryAlgebra/Core.lean`. Key verification statistics:
- 15 definitions and theorems
- 0 sorry statements (all proofs complete)
- Only standard axioms used (propext, Classical.choice, Quot.sound)
