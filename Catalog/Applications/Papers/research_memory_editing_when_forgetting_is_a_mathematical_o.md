# Memory Editing: When Forgetting Is a Mathematical Operation

## Abstract

We develop an algebraic theory of memory systems, formalizing memory as a monoid homomorphism from the free monoid of experience streams to a finite monoid of compressed representations. We prove three main results: (1) the **Lossy Memory Theorem**, showing that any such homomorphism must be non-injective; (2) the **Information Loss Submonoid Theorem**, showing that the kernel pair of any memory homomorphism forms a submonoid of the product, meaning information loss is algebraically closed under composition; and (3) the **Kernel Monotonicity Theorem**, showing that forgetting maps between memory systems induce a monotone refinement of kernel congruences. We further develop a tropical memory valuation framework where forgetting costs satisfy an additive (min-plus) structure, and prove that forgettability is monotone under stream extension. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: monoid homomorphism, free monoid, kernel congruence, information loss, tropical semiring, memory algebra, formal verification

---

## 1. Introduction

The mathematical study of memory and information compression has a long history, from Shannon's information theory to the theory of finite automata. However, a systematic algebraic treatment of memory as a structured mathematical operation — rather than merely a bound on information — has been lacking.

In this paper, we propose that memory systems be formalized as **monoid homomorphisms** from the free monoid on an experience alphabet to a finite monoid of memory states. This algebraic perspective immediately yields structural results about the nature of information loss that go beyond simple counting arguments.

Our main contributions are:

1. **Lossy Memory Theorem** (Theorem 3.1): Any monoid homomorphism from an infinite free monoid to a finite monoid is non-injective. While this follows from cardinality, the algebraic framing reveals deeper structure.

2. **Information Loss Submonoid** (Theorem 4.1): The kernel pair {(a,b) | φ(a) = φ(b)} forms a submonoid of the product monoid, showing that information loss is closed under the monoid operation.

3. **Kernel Monotonicity** (Theorem 5.1): Forgetting maps between memory systems form a category, and the kernel pair is a monotone functor from this category to the lattice of submonoids.

4. **Tropical Forgetting** (Section 6): A tropical memory valuation assigns additive costs to experiences, with forgettability determined by a threshold. Forgettable streams form an upward-closed ideal.

5. **Product Memory Decomposition** (Theorem 7.1): The kernel of a product memory system equals the intersection of component kernels, establishing a lattice structure on memory systems.

---

## 2. Definitions

### 2.1 Experience Streams and Free Monoids

**Definition 2.1** (Experience Stream). Let α be a finite alphabet of atomic experiences. An *experience stream* is a finite sequence of elements of α, i.e., an element of the free monoid FreeMonoid(α) = (α*, ·, ε).

The free monoid captures the idea that experiences are ordered and composable: today's experiences followed by tomorrow's form a combined experience stream.

### 2.2 Memory Systems

**Definition 2.2** (Memory System). A *memory system* over alphabet α consists of:
- A finite monoid (M, ·, 1) called the *state space*
- A monoid homomorphism φ : FreeMonoid(α) → M called the *encoding*

The homomorphism condition φ(w₁ · w₂) = φ(w₁) · φ(w₂) captures the principle that memory is compositional: the memory of a concatenated stream is determined by the memories of its parts.

### 2.3 Kernel Pair

**Definition 2.3** (Kernel Pair). The *kernel pair* of a memory system (M, φ) is:
ker(φ) = {(a, b) ∈ FreeMonoid(α)² | φ(a) = φ(b)}

This is the set of all pairs of experience streams that produce identical memory states — the formal representation of "confusion" or "information loss."

### 2.4 Forgetting Maps

**Definition 2.4** (Forgetting Map). A *forgetting map* from memory system (M₁, φ₁) to (M₂, φ₂) is a monoid homomorphism ψ : M₁ → M₂ such that ψ ∘ φ₁ = φ₂.

This captures the idea that M₂ "forgets more" than M₁: every distinction M₂ makes, M₁ also makes, but not vice versa.

### 2.5 Tropical Memory Valuation

**Definition 2.5** (Tropical Memory Valuation). A *tropical memory valuation* over α consists of:
- A cost function c : α → ℝ≥0 assigning a forgetting cost to each atomic experience
- A threshold θ > 0

The *stream cost* of w = a₁a₂...aₙ is c(w) = Σᵢ c(aᵢ). A stream w is *forgettable* if c(w) ≥ θ.

---

## 3. The Lossy Memory Theorem

**Theorem 3.1** (Lossy Memory). Let α be a nonempty alphabet and (M, φ) a memory system. Then φ is not injective.

*Proof sketch.* Since α is nonempty, FreeMonoid(α) contains words of arbitrary length and is therefore infinite. Since M is finite, the pigeonhole principle (specifically, `not_injective_infinite_finite`) implies φ cannot be injective. □

**Corollary 3.2** (Existence of Collisions). Under the hypotheses of Theorem 3.1, there exist distinct experience streams w₁ ≠ w₂ with φ(w₁) = φ(w₂).

**Theorem 3.3** (Periodicity Collision). For any memory system with n = |M| states, there exist distinct i ≠ j in {0, 1, ..., n} such that φ(aⁱ) = φ(aʲ) for any fixed experience a ∈ α.

*Proof sketch.* The map i ↦ φ(aⁱ) sends Fin(n+1) to M. Since |Fin(n+1)| = n+1 > n = |M|, two indices must collide. The proof uses `Fintype.card_le_of_injective` in the contrapositive. □

This theorem gives an explicit bound on the "memory period" of any repeated experience.

---

## 4. The Information Loss Submonoid

**Theorem 4.1** (Kernel Pair Submonoid). For any monoid homomorphism φ : M → N, the kernel pair ker(φ) = {(a,b) | φ(a) = φ(b)} is a submonoid of M × M.

*Proof.* We verify the submonoid axioms:
- **Identity**: (1, 1) ∈ ker(φ) since φ(1) = 1 = φ(1).
- **Closure**: If (a₁, a₂), (b₁, b₂) ∈ ker(φ), then φ(a₁) = φ(a₂) and φ(b₁) = φ(b₂), so φ(a₁b₁) = φ(a₁)φ(b₁) = φ(a₂)φ(b₂) = φ(a₂b₂).

This means: if experiences A and B are confused, and experiences C and D are confused, then AC and BD are also confused. **Information loss composes.** □

---

## 5. Forgetting as Kernel Refinement

**Theorem 5.1** (Kernel Monotonicity). If ψ : (M₁, φ₁) → (M₂, φ₂) is a forgetting map, then ker(φ₁) ⊆ ker(φ₂).

*Proof.* If φ₁(w₁) = φ₁(w₂), then φ₂(w₁) = ψ(φ₁(w₁)) = ψ(φ₁(w₂)) = φ₂(w₂). □

**Theorem 5.2** (Forgetting Composition). Forgetting maps compose: if f : mem₁ → mem₂ and g : mem₂ → mem₃ are forgetting maps, then g ∘ f : mem₁ → mem₃ is a forgetting map.

**Corollary 5.3** (Transitive Kernel Growth). ker(φ₁) ⊆ ker(φ₂) ⊆ ker(φ₃) whenever there is a chain of forgetting maps.

**Theorem 5.4** (Factorization). If ψ is a forgetting map from (M₁, φ₁) to (M₂, φ₂), then φ₂ = ψ ∘ φ₁ as monoid homomorphisms.

---

## 6. Tropical Forgetting

**Theorem 6.1** (Cost Additivity). The stream cost function is a monoid homomorphism from (FreeMonoid(α), ·, ε) to (ℝ, +, 0): c(w₁ · w₂) = c(w₁) + c(w₂) and c(ε) = 0.

**Theorem 6.2** (Forgettability Monotonicity). If w is forgettable (c(w) ≥ θ), then w · v and v · w are both forgettable for any v.

*Proof.* Since c(v) ≥ 0 and c(w · v) = c(w) + c(v) ≥ c(w) ≥ θ. □

This establishes that the set of forgettable streams forms an **ideal** in the monoid — it is closed under multiplication by arbitrary elements. In the language of order theory, it is an upward-closed set in the cost ordering.

---

## 7. Product Memory Systems

**Theorem 7.1** (Product Kernel Decomposition). For memory systems (M₁, φ₁) and (M₂, φ₂), the product memory system has kernel:
ker(φ₁ × φ₂) = ker(φ₁) ∩ ker(φ₂)

*Proof.* (w₁, w₂) ∈ ker(φ₁ × φ₂) iff (φ₁(w₁), φ₂(w₁)) = (φ₁(w₂), φ₂(w₂)) iff φ₁(w₁) = φ₁(w₂) and φ₂(w₁) = φ₂(w₂). □

This shows that combining memory systems reduces confusion to their intersection, establishing a lattice structure where the product is the meet operation on kernels.

---

## 8. Capacity Bounds

**Theorem 8.1** (Image Cardinality Bound). For any memory system with state space M and any finite set S of experience streams: |φ(S)| ≤ |M|.

This simple but fundamental bound shows that no matter how large the input set, the number of distinguishable outputs is capped by the memory capacity. Combined with the exponential growth of |α|^L words of length L, this implies that the fraction of distinguishable words approaches 0 exponentially as L → ∞.

---

## 9. The Optimal Forgetting Conjecture

**Conjecture 9.1** (Optimal Forgetting). For any alphabet size k ≥ 1, memory capacity n ≥ 1, and word length L, there exists a memory system with exactly n states that distinguishes exactly min(k^L, n) words of length L.

**Testable prediction**: For k = 2, n = 4, L = 3: a memory system exists distinguishing exactly min(8, 4) = 4 binary words of length 3. For k = 2, n = 4, L = 1: exactly min(2, 4) = 2 words.

The lower bound (k^L ≤ n case) is achieved by any injective-on-short-words system. The upper bound case requires constructing memory systems with maximum discrimination power, likely using modular arithmetic monoids.

---

## 10. Algorithms

### 10.1 Memory System Simulation

Given a memory system specified by a transition function on generators, we can simulate the encoding of any experience stream in O(L) time where L is the stream length. The algorithm processes one experience at a time, updating the memory state via the monoid operation.

### 10.2 Collision Detection

To find collisions, enumerate words of increasing length and track their memory states. By Theorem 3.3, a collision is guaranteed within the first |M|+1 powers of any generator.

### 10.3 Optimal Forgetting Search

For small parameters, exhaustively search over all monoid homomorphisms from the free monoid on k generators to monoids of size n, measuring the discrimination power at each word length L.

---

## 11. Related Work

The connection between finite automata and monoid homomorphisms is classical (Eilenberg, Schützenberger). Our contribution is the explicit algebraic characterization of information loss — the kernel pair as a submonoid — and the connection to tropical valuations for prioritized forgetting. The categorical perspective on forgetting maps appears to be new.

The tropical valuation framework connects to recent work on tropical geometry and min-plus algebras in optimization and machine learning. The connection between memory compression and tropical costs provides a bridge between algebraic coding theory and tropical mathematics.

---

## 12. Discussion and Future Work

The framework developed here opens several directions:

1. **Quantitative forgetting rates**: Can we characterize how fast the kernel grows as a function of stream length? The periodicity collision theorem gives a linear bound, but tighter results should be possible.

2. **Optimal memory design**: Given constraints on |M| and |α|, what monoid structure maximizes discrimination power? This connects to the theory of syntactic monoids in automata theory.

3. **Continuous memory**: Extending from finite to topological or measure-theoretic monoids would capture continuous memory systems (neural networks, analog computers).

4. **Categorical memory**: The category of memory systems with forgetting maps has rich structure (products, coproducts, quotients). Developing this category theory could yield universal constructions for optimal memory.

---

## References

1. Eilenberg, S. *Automata, Languages, and Machines*. Academic Press, 1974.
2. Pin, J.-E. "Mathematical Foundations of Automata Theory." 2020.
3. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
4. Shannon, C.E. "A Mathematical Theory of Communication." Bell System Technical Journal, 1948.
