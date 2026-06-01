# Memory Algebra: Forgetting as a Mathematical Operation

## Abstract

We develop a formal algebraic theory of memory systems, modeling memory as a monoid homomorphism from the free monoid of experience streams to a compressed representation monoid. We prove four main results: (1) any memory homomorphism to a finite codomain is necessarily lossy when the alphabet has at least two symbols (Pigeonhole Lossiness Theorem); (2) the kernel of a memory map — the "confusion set" of indistinguishable experience pairs — forms a monoid congruence with rich algebraic structure; (3) the composition of forgetting operations is again a forgetting operation, establishing a category of memory systems; and (4) targeted forgetting corresponds precisely to a quotient construction, with the lattice of valid forgetting congruences closed under meet. All results are formalized and machine-verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

Memory is a fundamental concept across multiple disciplines: neuroscience, computer science, information theory, and philosophy of mind. In all settings, a common pattern emerges: a system receives a stream of inputs, processes them through some finite-state mechanism, and retains a compressed representation. The inevitable loss of information in this compression has been studied empirically, but its algebraic structure has received less attention.

We propose a framework in which memory is modeled as a monoid homomorphism φ: F(Σ) → M, where F(Σ) is the free monoid over an alphabet Σ of experience types, and M is a (typically finite) monoid of memory states. The monoid operation on F(Σ) is concatenation of experience sequences, and φ must respect this structure: the memory state after experiencing sequence s followed by sequence t equals the memory state after s, updated by the contribution of t.

This seemingly simple setup yields surprisingly rich mathematics. The kernel of φ, the set of confused pairs, is not merely an equivalence relation but a monoid congruence — it respects the algebraic structure of experience concatenation. Forgetting operations form a category. The hierarchy of possible forgetting strategies forms a lattice. And fundamental capacity limits emerge from the interaction between the infinity of the free monoid and the finiteness of the memory.

### 1.2 Related Work

Our framework connects to several established areas:
- **Automata theory**: A memory system with finite M is essentially a finite-state automaton. The Myhill-Nerode theorem characterizes the languages recognizable by such automata via congruences of finite index on the free monoid, directly analogous to our kernel congruences.
- **Information theory**: Shannon's source coding theorem gives rate-distortion bounds for lossy compression. Our results are complementary, focusing on algebraic structure rather than probabilistic entropy.
- **Semigroup theory**: The quotient constructions and congruence lattice results are instances of general algebraic theory, specialized to the memory interpretation.
- **Category theory**: Memory systems and forgetting maps form a concrete category, a fact we make precise.

### 1.3 Contributions

1. **MemorySystem**: A novel mathematical structure combining a monoid homomorphism with an interpretation as memory encoding.
2. **Pigeonhole Lossiness Theorem**: Proof that any finite memory system over a non-trivial alphabet must be lossy.
3. **Confusion Set Structure**: The confusion set (kernel) forms a submonoid of the product monoid, and a congruence on the free monoid.
4. **Category of Memory Systems**: Forgetting maps compose and have identities, forming a category.
5. **Quotient Forgetting**: Targeted forgetting corresponds to quotient constructions, with a lattice structure on valid congruences.
6. **Selective Forgetting Congruence**: A concrete construction for forgetting specific experience types, with a monotonicity property.
7. **Memory Capacity Bound**: A quantitative bound relating alphabet size, sequence length, and memory cardinality.
8. **Kernel Quotient Injectivity**: The first isomorphism theorem direction, showing the kernel quotient embeds in M.

## 2. Definitions

### 2.1 Memory System

**Definition 2.1 (Memory System).** A *memory system* over alphabet α with memory M is a pair (α, M, φ) where M is a monoid and φ: FreeMonoid(α) →* M is a monoid homomorphism. We write `ms.encode` for φ.

The free monoid FreeMonoid(α) consists of finite sequences (lists) over α, with concatenation as the monoid operation and the empty list as identity.

**Definition 2.2 (Lossy).** A memory system is *lossy* if its encoding φ is not injective: there exist distinct experience streams s ≠ t with φ(s) = φ(t).

**Definition 2.3 (Confusion Set).** The *confusion set* of a memory system is
C(ms) = { (s, t) ∈ FreeMonoid(α) × FreeMonoid(α) | φ(s) = φ(t) }.

### 2.2 Forgetting Maps

**Definition 2.4 (Forgetting Map).** A *forgetting map* from memory system (α, M, φ₁) to (α, N, φ₂) consists of a monoid homomorphism f: M →* N such that f ∘ φ₁ = φ₂.

This is a morphism in the category of memory systems over a fixed alphabet α.

**Definition 2.5 (Kernel Congruence).** The *kernel congruence* of a memory system is the monoid congruence ker(φ) on FreeMonoid(α) defined by s ~ t iff φ(s) = φ(t).

### 2.3 Selective Forgetting

**Definition 2.6 (Selective Forgetting Congruence).** Given a set S ⊆ α of "forgotten" symbols, the *selective forgetting congruence* ~_S is defined by: s ~_S t iff filter(s, α\S) = filter(t, α\S), where filter keeps only symbols not in S.

## 3. Main Results

### 3.1 Pigeonhole Lossiness

**Theorem 3.1 (Finite Memory Is Lossy).** Let (α, M, φ) be a memory system with M finite and |α| ≥ 2. Then φ is not injective.

*Proof sketch.* The free monoid on ≥2 generators is infinite: the elements aⁿ = [a, a, ..., a] (n copies) for n ∈ ℕ are pairwise distinct, since they have different lengths. The function n ↦ aⁿ is an injection ℕ ↪ FreeMonoid(α), proving FreeMonoid(α) is infinite. Since M is finite, no injection from FreeMonoid(α) to M can exist.

*Formal verification.* The Lean proof uses `Infinite.of_injective` with the replicate function and `Finite.of_injective` to derive a contradiction.

### 3.2 Confusion Set Structure

**Theorem 3.2 (Confusion Set Submonoid).** For any memory system, the confusion set C(ms) contains (1, 1) and is closed under componentwise multiplication: if (s₁, t₁) ∈ C(ms) and (s₂, t₂) ∈ C(ms), then (s₁s₂, t₁t₂) ∈ C(ms).

*Proof.* For identity: φ(1) = 1 = φ(1). For closure: if φ(s₁) = φ(t₁) and φ(s₂) = φ(t₂), then φ(s₁s₂) = φ(s₁)φ(s₂) = φ(t₁)φ(t₂) = φ(t₁t₂), using the homomorphism property.

### 3.3 Forgetting Expands Confusion

**Theorem 3.3 (Monotonicity of Confusion).** If there exists a forgetting map from ms₁ to ms₂, then C(ms₁) ⊆ C(ms₂).

*Proof.* Let f be the forgetting map with f ∘ φ₁ = φ₂. If φ₁(s) = φ₁(t), then φ₂(s) = f(φ₁(s)) = f(φ₁(t)) = φ₂(t).

### 3.4 Category Structure

**Theorem 3.4 (Composition of Forgetting Maps).** If f: ms₁ → ms₂ and g: ms₂ → ms₃ are forgetting maps, then g ∘ f: ms₁ → ms₃ is a forgetting map with underlying homomorphism g.forget ∘ f.forget.

**Theorem 3.5 (Identity Forgetting Map).** The identity homomorphism id: M →* M is a forgetting map from ms to ms.

Together with associativity of homomorphism composition (which is automatic), these establish a category.

### 3.5 Quotient Forgetting

**Theorem 3.6 (Quotient Memory System).** Given a congruence c on FreeMonoid(α) that is coarser than ker(φ) (i.e., ker(φ) ≤ c), the quotient projection mk': FreeMonoid(α) →* FreeMonoid(α)/c defines a memory system with memory FreeMonoid(α)/c.

**Theorem 3.7 (Finer Congruence = Less Confusion).** If c₁ ≤ c₂ (c₁ is finer), then C(ms_{c₁}) ⊆ C(ms_{c₂}).

### 3.6 Memory Capacity Bound

**Theorem 3.8 (Capacity Bound).** If all length-k sequences over alphabet α map to distinct memory states, then |α|^k ≤ |M|.

*Proof.* The map s ↦ φ(list_of(s)) from (Fin k → α) to M is injective by hypothesis. By Fintype.card_le_of_injective, |Fin k → α| ≤ |M|. Since |Fin k → α| = |α|^k, the result follows.

### 3.7 First Isomorphism Direction

**Theorem 3.9 (Kernel Quotient Injectivity).** The induced map FreeMonoid(α)/ker(φ) → M is injective.

This is the "injective direction" of the first isomorphism theorem for monoids.

### 3.8 Selective Forgetting

**Theorem 3.10 (Selective Forgetting Monotonicity).** If S ⊆ T, then ~_S refines ~_T: any two streams identified by forgetting S are also identified by forgetting T.

**Theorem 3.11 (Forgetting Lattice Closure).** The infimum (meet) of two congruences coarser than ker(φ) is itself coarser than ker(φ). The valid forgetting congruences are closed under meet.

## 4. Algorithms

### 4.1 Confusion Detection

Given a concrete finite memory system (represented as a transition function), detecting confused pairs reduces to finding collisions in the encoding map. For streams of bounded length k:

```
Algorithm: DETECT_CONFUSION(φ, k, Σ)
  state_map ← empty dictionary
  for each sequence s of length ≤ k over Σ:
    m ← φ(s)
    if m in state_map:
      return (s, state_map[m])  // confused pair
    state_map[m] ← s
  return None  // no confusion at this length
```

Time complexity: O(|Σ|^k) in the worst case, matching the capacity bound.

### 4.2 Selective Forgetting Computation

Given a stream s and a forgetting set S:

```
Algorithm: SELECTIVE_FORGET(s, S)
  return filter(s, λ x. x ∉ S)
```

Time complexity: O(|s|).

## 5. Discussion

### 5.1 Connections to Automata Theory

Our kernel congruence is precisely the syntactic congruence of the language recognized by the memory system (when viewed as an acceptor with a designated set of "accepting" memory states). The Myhill-Nerode theorem states that a language is regular if and only if its syntactic congruence has finite index. Our capacity bound (Theorem 3.8) is a quantitative refinement: with m memory states, at most m equivalence classes exist, bounding the distinguishing power.

### 5.2 Information-Theoretic Interpretation

The confusion set C(ms) determines the mutual information between the input stream and the memory state. If we place a uniform distribution on length-k sequences, the number of confusion classes equals |α|^k / average_class_size, and the mutual information is log₂ of this ratio. Our capacity bound shows this mutual information is at most log₂(|M|) bits, regardless of the encoding.

### 5.3 Biological Memory

In neuroscience, the concept of "memory engram" — the physical substrate of a memory — corresponds roughly to a memory state in our framework. The hippocampal replay mechanism, which consolidates memories during sleep, can be modeled as a forgetting map: it transforms a detailed, high-capacity short-term memory into a coarser, long-term representation. Our framework predicts that this transformation must expand the confusion set, consistent with the well-documented phenomenon of memory generalization during consolidation.

### 5.4 Limitations

Our framework models memory as a *deterministic* monoid homomorphism. Probabilistic or quantum memory systems, where the encoding may be stochastic, require extensions to probabilistic monoids or quantum channels. The framework also assumes the alphabet is discrete; continuous experience spaces would require topological monoids.

## 6. Future Work

1. **Rate-Distortion Connection**: Relate the algebraic capacity bound to Shannon's rate-distortion function for specific source distributions.
2. **Temporal Discounting**: Model memory systems where recent experiences are weighted more heavily, perhaps via weighted monoids or graded structures.
3. **Composition of Memory Systems**: Study the tensor product of memory systems — how two independent memory channels interact.
4. **Computational Complexity of Forgetting**: Given a memory system, how hard is it to find the optimal forgetting congruence for a given task?
5. **Non-deterministic Memory**: Extend to probabilistic memory maps and prove analogous lossiness results.

## 7. References

1. Eilenberg, S. *Automata, Languages, and Machines*. Academic Press, 1974.
2. Pin, J.-E. "Mathematical Foundations of Automata Theory." 2020.
3. Shannon, C. E. "A Mathematical Theory of Communication." *Bell System Technical Journal*, 1948.
4. Cover, T. M. and Thomas, J. A. *Elements of Information Theory*. Wiley, 2006.
5. Rhodes, J. and Steinberg, B. *The q-theory of Finite Semigroups*. Springer, 2009.
