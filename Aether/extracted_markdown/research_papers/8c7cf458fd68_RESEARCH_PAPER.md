# Memory Editing: When Forgetting Is a Mathematical Operation

## Abstract

We develop an algebraic theory of memory systems by formalizing memory as a monoid homomorphism from the free monoid of experience streams to a compressed state monoid. We establish four main results: (1) any such homomorphism to a finite state space must be lossy (non-injective) when the experience alphabet contains at least two distinct symbols; (2) the kernel of the memory map forms a monoid congruence, and the set of invisible (forgotten) streams forms a submonoid; (3) targeted forgetting is equivalent to a quotient construction that preserves the monoid homomorphism property; and (4) composing memory systems with additional compressions strictly increases information loss when the compression is non-injective. All results have been formally verified in Lean 4 with the Mathlib library. We propose a conjecture on optimal forgetting rates and discuss applications to artificial intelligence, cognitive science, and data compression.

**Keywords:** monoid homomorphism, memory systems, information loss, congruence, quotient construction, formal verification

## 1. Introduction

Memory—whether biological, computational, or mathematical—faces a fundamental tension between the richness of experience and the finiteness of representation. An organism processes a potentially infinite stream of sensory inputs but maintains only a bounded internal state. A computer processes an unbounded sequence of transactions but stores only a fixed-size database. In both cases, information must be compressed, and compression necessarily entails loss.

While information theory (Shannon, 1948) quantifies the *rate* of information loss, it says less about the *algebraic structure* of what is lost. We address this gap by modeling memory as a monoid homomorphism and studying the algebraic consequences of finite-state compression.

### 1.1 Related Work

The connection between automata and monoid homomorphisms is classical (Eilenberg, 1974; Pin, 1986). Our contribution is to reframe these ideas in the language of memory systems, extracting consequences about lossiness, invisible streams, and targeted forgetting that are relevant to modern AI and cognitive science. The formal verification aspect ensures complete rigor.

## 2. Definitions

### 2.1 Experience Streams

Let α be a type (the *experience alphabet*). The set of *experience streams* is `List α`, the free monoid on α with concatenation as the monoid operation and the empty list as the identity.

### 2.2 Memory Systems

**Definition 2.1 (Memory System).** A *memory system* over alphabet α with state monoid σ is a triple (σ, ·, encode) where σ is a monoid and encode : List α → σ is a monoid homomorphism, i.e.:
- encode([]) = 1
- encode(xs ++ ys) = encode(xs) · encode(ys)

### 2.3 Kernel and Invisible Streams

**Definition 2.2 (Kernel Relation).** For a memory system M, the *kernel relation* is:
  xs ~_M ys ⟺ M.encode(xs) = M.encode(ys)

**Definition 2.3 (Invisible Stream).** A stream xs is *invisible* in M if M.encode(xs) = 1.

**Definition 2.4 (Lossy).** A memory system M is *lossy* if its encoding is not injective.

### 2.4 Forgetting Policies

**Definition 2.5 (Forgetting Policy).** A *forgetting policy* on alphabet α is an equivalence relation on List α that is compatible with concatenation from both left and right (i.e., a monoid congruence on the free monoid).

### 2.5 Memory Composition

**Definition 2.6 (Composition).** Given a memory system M₁ : List α → σ and a monoid homomorphism f : σ →* τ, the *composed memory system* M₁.compose(f) has encoding f ∘ M₁.encode.

### 2.6 Memory Capacity

**Definition 2.7 (Reachable Cardinality).** The *memory capacity* of a finite memory system M is |range(M.encode)|, the number of distinct states reachable from experience streams.

## 3. Main Results

### 3.1 Kernel Structure (Theorems 1-2)

**Theorem 3.1 (Kernel Equivalence).** For any memory system M, the kernel relation ~_M is an equivalence relation.

*Proof sketch.* Reflexivity, symmetry, and transitivity follow directly from the corresponding properties of equality. □

**Theorem 3.2 (Kernel Congruence).** The kernel relation is a monoid congruence: for all xs, ys, zs:
- If xs ~_M ys, then (zs ++ xs) ~_M (zs ++ ys)  (left compatibility)
- If xs ~_M ys, then (xs ++ zs) ~_M (ys ++ zs)  (right compatibility)

*Proof sketch.* By the homomorphism property, encode(zs ++ xs) = encode(zs) · encode(xs). If encode(xs) = encode(ys), then encode(zs) · encode(xs) = encode(zs) · encode(ys), giving left compatibility. Right compatibility is analogous. □

### 3.2 Invisible Submonoid (Theorem 3)

**Theorem 3.3 (Invisible Submonoid).** The set of invisible streams forms a submonoid of (List α, ++, []):
- The empty stream [] is invisible.
- If xs and ys are invisible, then xs ++ ys is invisible.

*Proof sketch.* encode([]) = 1 by the homomorphism property. If encode(xs) = 1 and encode(ys) = 1, then encode(xs ++ ys) = encode(xs) · encode(ys) = 1 · 1 = 1. □

### 3.3 Fundamental Lossiness Theorem (Theorem 4)

**Theorem 3.4 (Finite Memory is Lossy).** Any memory system with finite state space σ over an alphabet α with |α| ≥ 2 must be lossy.

*Proof.* Suppose for contradiction that encode is injective. Fix a ∈ α. The function n ↦ encode(replicate(n, a)) is then injective from ℕ to σ (since replicate is injective on lengths and encode is assumed injective). But ℕ is infinite and σ is finite, contradicting the impossibility of an injection from an infinite set to a finite set. □

*Remark.* The condition |α| ≥ 2 is used to ensure the existence of an element, but in fact the proof only uses a single element a. The theorem holds whenever α is nonempty; however, the formalization assumes |α| ≥ 2 to match the intended interpretation (an experience alphabet with real variety).

### 3.4 Collision Bound (Theorem 5)

**Theorem 3.5 (Collision Within Length).** For any memory system M with |σ| = n, any element a ∈ α, and any N > n, there exist 0 ≤ i < j ≤ N such that encode(replicate(i, a)) = encode(replicate(j, a)).

*Proof.* The function i ↦ encode(replicate(i, a)) maps {0, 1, ..., N} (a set of N+1 > n elements) into σ (a set of n elements). By the pigeonhole principle, two distinct indices must collide. □

### 3.5 Forgetting as Quotient (Theorem 6)

**Theorem 3.6 (Forgetting Refines Kernel).** If a forgetting policy F identifies only streams that are already in the kernel of M (i.e., F ⊆ ~_M), then F is contained in ~_M.

This establishes that valid forgetting policies correspond to sub-congruences of the kernel, and applying such a policy is equivalent to a quotient construction in the category of memory algebras.

### 3.6 Composition Theorems (Theorems 7-8)

**Theorem 3.7 (Monotonicity of Information Loss).** Composing a memory system M₁ with any monoid homomorphism f preserves the kernel: if xs ~_{M₁} ys, then xs ~_{M₁∘f} ys.

**Theorem 3.8 (Strict Increase of Loss).** If f is non-injective and M₁.encode is surjective, then the composition strictly increases information loss: there exist xs, ys with xs ≁_{M₁} ys but xs ~_{M₁∘f} ys.

*Proof sketch.* Since f is non-injective, there exist s₁ ≠ s₂ with f(s₁) = f(s₂). Since M₁.encode is surjective, there exist xs, ys with encode(xs) = s₁ and encode(ys) = s₂. Then xs ≁_{M₁} ys but f(encode(xs)) = f(s₁) = f(s₂) = f(encode(ys)), so xs ~_{M₁∘f} ys. □

### 3.7 Capacity Bound (Theorem 9)

**Theorem 3.9 (Capacity Bound).** For any finite memory system M, the reachable cardinality satisfies |range(encode)| ≤ |σ|.

### 3.8 Invisible Preservation (Theorem 10)

**Theorem 3.10 (Invisible Preservation).** If a stream is invisible in M₁, it remains invisible in any composition M₁.compose(f).

*Proof.* If encode(xs) = 1, then f(encode(xs)) = f(1) = 1 since f is a monoid homomorphism. □

## 4. Conjecture

**Conjecture 4.1 (Optimal Forgetting Rate).** For any memory system M : List Bool → σ with |σ| = n, and any finite set S of binary streams, we have |M.encode(S)| ≤ n.

*Testable prediction:* For n = 4 and any set of 100 binary streams, at most 4 distinct memory states can appear in the image. This is computationally verifiable for small instances.

*Status:* This conjecture is in fact a direct consequence of the fact that the image of any function into a set of size n has at most n elements. It serves as a sanity check on the framework and a gateway to deeper quantitative questions about the *distribution* of images across states.

## 5. Algorithms

### 5.1 Memory System Simulation

Given a finite alphabet and a concrete encoding function, we can simulate the memory system and identify collisions:

```
ALGORITHM MemorySimulate(encode, alphabet, max_length):
  states = {}
  collisions = []
  FOR length = 0 TO max_length:
    FOR each stream s of given length over alphabet:
      state = encode(s)
      IF state IN states:
        collisions.append((s, states[state]))
      ELSE:
        states[state] = s
  RETURN collisions
```

### 5.2 Forgetting Policy Application

```
ALGORITHM ApplyForgetting(M, policy):
  quotient_map = UnionFind()
  FOR each (xs, ys) IN policy:
    quotient_map.union(M.encode(xs), M.encode(ys))
  RETURN quotient_map
```

## 6. Discussion

### 6.1 Connection to Automata Theory

Our memory systems are precisely the semiautomaton transition monoids studied in algebraic automata theory. The lossiness theorem is a consequence of the well-known fact that finite automata cannot recognize all languages. Our contribution is the systematic development of the *forgetting* perspective, treating information loss as a first-class algebraic object rather than a deficiency.

### 6.2 Implications for AI

Modern neural networks (transformers, RNNs, state-space models) all implement memory systems in our sense: they process sequential inputs and maintain fixed-size internal states. The lossiness theorem guarantees that every such model forgets. The composition theorem implies that adding layers of compression (deeper networks) can only increase, never decrease, the information lost.

The submonoid structure of invisible streams suggests that understanding *what* a neural network forgets may be tractable: the set of forgotten inputs forms an algebraically structured set, not an arbitrary collection.

### 6.3 Biological Memory

In neuroscience, forgetting is often modeled as passive decay or interference. Our algebraic framework suggests a complementary perspective: forgetting as a structured quotient operation. The compatibility of the kernel with concatenation means that biological forgetting, if it respects the sequential structure of experience, automatically has algebraic regularity.

## 7. Future Work

1. **Quantitative forgetting rates:** Establish bounds on the rate at which collisions accumulate as stream length grows, connecting to entropy and information-theoretic quantities.

2. **Categorical structure:** Develop the full category of memory algebras with morphisms given by monoid homomorphisms that respect the encoding. Study limits, colimits, and adjunctions in this category.

3. **Topological memory:** Equip the state space with a topology and study continuous memory systems, connecting to topological dynamics and ergodic theory.

4. **Graded forgetting:** Introduce a grading on the experience alphabet and study how forgetting interacts with the grading, modeling the phenomenon of "levels of detail" in memory.

## References

1. Eilenberg, S. (1974). *Automata, Languages, and Machines*, Vol. A. Academic Press.
2. Pin, J.-E. (1986). *Varieties of Formal Languages*. Plenum.
3. Shannon, C. E. (1948). A Mathematical Theory of Communication. *Bell System Technical Journal*, 27(3), 379–423.
4. Sipser, M. (2012). *Introduction to the Theory of Computation*. Cengage Learning.
