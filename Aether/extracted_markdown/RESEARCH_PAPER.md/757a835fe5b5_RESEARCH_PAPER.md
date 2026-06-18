# Algebraic Foundations of Memory as a Monoid: Congruences, Lossiness, and the Syntactic Architecture

## Abstract

We develop a rigorous algebraic framework for memory systems, modeling them as monoid homomorphisms from free monoids to state monoids. We prove that finite memory is necessarily lossy (Theorem 3), that the information loss structure forms a monoid congruence (the "confusion congruence"), and that the syntactic congruence provides the unique coarsest recognizing congruence for any language (Theorems 1, 2, 4). We introduce the notion of a *memory architecture* — a congruence-recognition pair — and prove that architectures for a fixed language form a lattice with the syntactic architecture as its maximum (Theorem 5). Additional results establish that post-processing monotonically coarsens confusion (Theorem 6) and that product memories yield the infimum of confusion congruences (Theorem 7). All results are formalized in Lean 4 with full machine-checked proofs.

**Keywords**: monoid homomorphism, free monoid, congruence, syntactic monoid, memory architecture, Myhill-Nerode, lattice theory

---

## 1. Introduction

The theory of finite automata and regular languages is one of the foundational achievements of theoretical computer science. The Myhill-Nerode theorem characterizes regular languages via congruences of finite index on the free monoid, and the syntactic monoid provides a canonical algebraic invariant for each regular language. While these results are classical, the *interpretation* of these structures as theories of memory has received less formal attention.

In this paper, we take the perspective that a memory system is fundamentally an algebraic structure: a monoid homomorphism from the free monoid of experiences to a state monoid. This perspective reveals that:

1. **Forgetting has structure**: The set of input pairs confused by a memory system forms a monoid congruence — not just an equivalence relation but one compatible with the monoid operation.

2. **Finite memory must be lossy**: By the pigeonhole principle, any homomorphism from an infinite free monoid to a finite monoid fails to be injective. This is not an engineering limitation but a mathematical necessity.

3. **Optimal forgetting exists**: For any "pattern" (language) that a memory system aims to recognize, there is a unique coarsest congruence — the syntactic congruence — that still permits recognition. Any recognizing system must refine it.

4. **Memory architectures form a lattice**: The set of congruences recognizing a fixed language, ordered by refinement, has the syntactic congruence as its maximum element.

### 1.1 Related Work

The syntactic monoid was introduced by Rabin and Scott (1959) and is central to the Eilenberg variety theorem connecting varieties of finite monoids to classes of regular languages. Our contribution is to reframe these classical structures explicitly as a theory of memory, proving the relevant results in full generality and formalizing them in a modern proof assistant.

The connection between congruences and automata states goes back to Myhill (1957) and Nerode (1958). Our Theorem 1 (recognition refinement) is the algebraic core of the Myhill-Nerode theorem, while our lattice-theoretic results extend the characterization.

---

## 2. Definitions

### 2.1 Free Monoid and Memory Systems

**Definition 2.1** (Free Monoid). For an alphabet (type) α, the free monoid FreeMonoid(α) is the set of all finite sequences over α with concatenation as the monoid operation and the empty sequence as identity.

**Definition 2.2** (Memory System). A *memory system* over alphabet α with state monoid M consists of a monoid homomorphism:

$$\varphi : \text{FreeMonoid}(\alpha) \to M$$

The map φ encodes sequences of inputs into memory states. The homomorphism condition ensures that processing a composite experience A·B yields the same state whether processed as a unit or sequentially.

### 2.2 Confusion Congruence

**Definition 2.3** (Confusion Congruence). The *confusion congruence* of a memory system (M, φ) is the kernel congruence:

$$\ker(\varphi) = \{(x, y) : \varphi(x) = \varphi(y)\}$$

This is a monoid congruence on FreeMonoid(α): an equivalence relation compatible with concatenation.

### 2.3 Language Recognition

**Definition 2.4** (Recognition). A memory system (M, φ) *recognizes* a language L ⊆ FreeMonoid(α) if:

$$\varphi(x) = \varphi(y) \implies (x \in L \iff y \in L)$$

That is, membership in L is determined by the memory state alone.

### 2.4 Syntactic Congruence

**Definition 2.5** (Syntactic Congruence). The *syntactic congruence* of a language L is:

$$x \equiv_L y \iff \forall u, v \in \text{FreeMonoid}(\alpha),\; (uxv \in L \iff uyv \in L)$$

This is the coarsest congruence compatible with L-membership in all contexts.

**Proof that ≡_L is a congruence**: Reflexivity, symmetry, and transitivity follow immediately from the corresponding properties of ↔. For compatibility with multiplication: given a ≡_L b and c ≡_L d, we need to show ac ≡_L bd. For any context (u, v):

- u(ac)v ∈ L ↔ u(ad)v ∈ L (using c ≡_L d with context (ua, v))
- u(ad)v ∈ L ↔ u(bd)v ∈ L (using a ≡_L b with context (u, dv))

Chaining these gives u(ac)v ∈ L ↔ u(bd)v ∈ L. □

### 2.5 Memory Architecture

**Definition 2.6** (Memory Architecture). A *memory architecture* for language L is a pair (c, h) where c is a monoid congruence on FreeMonoid(α) and h is a proof that c recognizes L (i.e., x ≡_c y implies x ∈ L ↔ y ∈ L).

Memory architectures are ordered by congruence refinement: (c₁, h₁) ≤ (c₂, h₂) iff c₁ ≤ c₂ (i.e., c₁ identifies fewer pairs).

---

## 3. Main Results

### Theorem 1: Recognition Refinement

**Theorem** (Recognition Refinement). If a memory system (M, φ) recognizes L, then ker(φ) ≤ ≡_L.

*Proof sketch*: If φ(x) = φ(y), then for any context (u, v), the homomorphism property gives φ(uxv) = φ(uyv). Since (M, φ) recognizes L, this implies uxv ∈ L ↔ uyv ∈ L, which is exactly x ≡_L y. □

**Significance**: This is the algebraic core of the Myhill-Nerode theorem. It says the syntactic congruence is a *lower bound* on the confusion of any recognizing system — you can never be more forgetful than the syntactic congruence allows.

### Theorem 2: Syntactic Congruence Recognizes

**Theorem**. The syntactic congruence ≡_L recognizes L.

*Proof sketch*: If x ≡_L y, then by definition, for all u, v, uxv ∈ L ↔ uyv ∈ L. Taking u = v = 1 (the empty word), we get x ∈ L ↔ y ∈ L. □

**Significance**: Combined with Theorem 1, this establishes ≡_L as the *optimal* recognition congruence — the unique coarsest congruence that still recognizes L.

### Theorem 3: Finite Memory Lossiness

**Theorem**. For any nonempty alphabet α and finite monoid M, every memory system (M, φ) is lossy (φ is not injective).

*Proof sketch*: FreeMonoid(α) is infinite (it contains words of all lengths when α is nonempty). M is finite. An injective function from an infinite set to a finite set would make FreeMonoid(α) finite, a contradiction. □

**Significance**: This is a *no-go theorem* for lossless finite memory. No amount of clever encoding can avoid losing information when the state space is finite.

### Theorem 4: Syntactic Congruence is Supremum

**Theorem**. For any congruence c recognizing L, c ≤ ≡_L.

*Proof sketch*: If c(x, y), then for any context (u, v), the congruence property gives c(uxv, uyv). Since c recognizes L, this implies uxv ∈ L ↔ uyv ∈ L, which is x ≡_L y. □

**Significance**: The syntactic congruence is the supremum (maximum) of all recognizing congruences. Combined with Theorem 2, the recognizing congruences for L form an interval [⊥, ≡_L] in the congruence lattice.

### Theorem 5: Syntactic Architecture Maximality

**Theorem**. For any memory architecture (c, h) for L, (c, h) ≤ (≡_L, h_L), where h_L is the proof from Theorem 2.

*Proof*: Immediate from Theorem 4. □

### Theorem 6: Composition Monotonicity

**Theorem**. For memory system (M, φ) and monoid homomorphism f : M → N, ker(φ) ≤ ker(f ∘ φ).

*Proof sketch*: If φ(x) = φ(y), then f(φ(x)) = f(φ(y)), i.e., (f ∘ φ)(x) = (f ∘ φ)(y). □

**Significance**: Post-processing can only lose information. Applying any further transformation to memory states can only increase confusion — it can never recover distinctions that were lost.

### Theorem 7: Product Memory Intersection

**Theorem**. For memory systems (M, φ₁) and (N, φ₂), the confusion congruence of the product system (M × N, φ₁ × φ₂) equals ker(φ₁) ⊓ ker(φ₂).

*Proof sketch*: (φ₁ × φ₂)(x) = (φ₁ × φ₂)(y) iff φ₁(x) = φ₁(y) ∧ φ₂(x) = φ₂(y), which is exactly (ker(φ₁) ⊓ ker(φ₂))(x, y). □

**Significance**: Combining two memories is strictly additive — the combined confusion is exactly the intersection of individual confusions. There are no emergent confusions from combination.

### First Isomorphism Theorem for Memory

**Theorem**. FreeMonoid(α) / ker(φ) ≅ im(φ) as monoids.

This is a direct application of the first isomorphism theorem, but in our context it has a vivid interpretation: *the structure of memory is the quotient of experience by confusion*. The effective memory content is completely characterized by the equivalence classes of confused inputs.

---

## 4. Algorithms

### Algorithm 1: Computing the Confusion Congruence

Given a deterministic finite automaton (DFA) with transition function δ and initial state q₀, the confusion congruence can be computed by the standard DFA state-equivalence algorithm:

1. Compute the state reached by each input word: φ(w) = δ*(q₀, w)
2. Two words w₁, w₂ are confused iff δ*(q₀, w₁) = δ*(q₀, w₂)
3. The congruence classes correspond to the reachable states

### Algorithm 2: Computing the Syntactic Congruence

The syntactic monoid of a regular language can be computed from its minimal DFA:

1. Build the minimal DFA for L using Hopcroft's algorithm
2. The transition monoid of the minimal DFA is the syntactic monoid
3. The syntactic congruence classes correspond to the elements of this monoid

### Algorithm 3: Memory Architecture Lattice Exploration

To explore the lattice of memory architectures for a language L:

1. Compute the syntactic monoid M(L) = FreeMonoid(α) / ≡_L
2. Enumerate the congruences on M(L) (finite problem)
3. For each congruence c on M(L), compose with the projection to get a coarser architecture
4. Check recognition: verify c respects L-membership
5. Order the recognizing congruences by refinement

---

## 5. Discussion

### 5.1 Memory as Quotient

The first isomorphism theorem for memory crystallizes an important insight: what a memory system "knows" is not the raw states it uses but the equivalence classes of inputs that lead to each state. Two memory systems with different state sets but the same confusion congruence are, for all practical purposes, the same memory system.

This perspective aligns with the philosophical position that memory is *functional* rather than *representational*: what matters is not how information is stored but what distinctions are preserved.

### 5.2 The Lossiness No-Go Theorem

The finite memory lossiness theorem (Theorem 3) is notable for its generality: it applies to *any* finite state monoid, regardless of structure. Whether the memory is a group, a commutative monoid, or a non-commutative monoid with complex multiplication, the pigeonhole argument applies uniformly. The only escape is infinite state space.

### 5.3 Connections to Information Theory

The confusion congruence provides a combinatorial refinement of Shannon entropy as a measure of information loss. The index of the congruence (number of equivalence classes) determines the "resolution" of the memory system: an index-k congruence can distinguish at most k behaviors. For uniform distributions, the entropy of the memory state approaches log₂(k), establishing a precise bridge between the algebraic and information-theoretic perspectives.

### 5.4 Connections to Automata Theory

The syntactic congruence is the algebraic face of the Myhill-Nerode theorem. Our Theorems 1 and 4 together state that a language is recognizable by a finite memory system iff its syntactic congruence has finite index — which is exactly the Myhill-Nerode characterization of regular languages.

The Eilenberg variety theorem further extends this: varieties of finite monoids correspond to classes of regular languages. Our memory architecture lattice provides a concrete realization of the "variety" concept: different architectures for the same language form a sublattice of the congruence lattice, and the structure of this sublattice characterizes the computational complexity of recognizing L.

---

## 6. Future Work

1. **Weighted memory**: Extend to semiring-weighted memory systems, where the encoding maps to a module rather than a monoid.

2. **Topological memory**: Study the pro-finite completion of the syntactic monoid and its implications for recognition of ω-regular languages (infinite words).

3. **Entropy-congruence duality**: Formalize the relationship between the index of the confusion congruence and the Shannon entropy of the memory state under uniform input distribution.

4. **Tropical memory**: Replace the state monoid with a tropical semiring to model optimization-based memory (shortest-path, minimum-cost computations).

5. **Memory depth**: Characterize the *depth* of a memory architecture — the length of the longest chain in the congruence lattice below it — as a measure of computational complexity.

---

## 7. References

1. Eilenberg, S. (1976). *Automata, Languages, and Machines*, Vol. B. Academic Press.
2. Myhill, J. (1957). "Finite automata and the representation of events." WADD TR-57-624.
3. Nerode, A. (1958). "Linear automaton transformations." *Proceedings of the AMS*, 9(4), 541–544.
4. Pin, J.-É. (1986). *Varieties of Formal Languages*. North Oxford Academic.
5. Rabin, M.O., & Scott, D. (1959). "Finite automata and their decision problems." *IBM J. Research and Development*, 3(2), 114–125.
6. Almeida, J. (1994). *Finite Semigroups and Universal Algebra*. World Scientific.
