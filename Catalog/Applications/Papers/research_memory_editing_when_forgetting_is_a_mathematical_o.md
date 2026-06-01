# Memory Algebra: Monoid Homomorphisms, Lossy Compression, and the Category of Forgetting

## Abstract

We formalize memory as a monoid homomorphism from the free monoid of experience streams to a finite monoid of internal states. We prove three main results: (1) the **Memory Compression Theorem**, showing that any such homomorphism over an alphabet with ≥ 2 symbols must be lossy (non-injective), by a pigeonhole argument exploiting the infinitude of the free monoid; (2) the **Oblivion Kernel Theorem**, showing that when the state space is a finite group, the monoid kernel (experiences mapping to the identity) is nontrivial, with an explicit construction via element orders; and (3) the **Forgetting Factorization Theorem**, showing that if one memory system forgets more than another, the additional forgetting factors through a canonical quotient map. We additionally prove monotonicity of information loss under composition, a capacity bound on distinguishable experience classes, and structural results on the lattice of forgetting strategies. All results are formalized and machine-verified.

**Keywords**: monoid homomorphism, free monoid, congruence, quotient, lossy compression, memory algebra, information loss, categorical forgetting

---

## 1. Introduction

### 1.1 Motivation

The mathematical study of memory — as opposed to its engineering, neuroscience, or psychological study — requires identifying the essential algebraic structure that any memory system must satisfy. We propose that this structure is captured by a single algebraic object: a monoid homomorphism from a free monoid (the space of all possible experience sequences) to a finite monoid (the space of internal states).

This abstraction captures three essential properties of memory:
1. **Sequentiality**: experiences arrive in order and are processed compositionally.
2. **Finiteness**: the internal state space has bounded cardinality.
3. **Homomorphism property**: processing two sub-sequences separately and then combining states yields the same result as processing the concatenated sequence directly.

### 1.2 Related Work

The connection between finite automata and monoid homomorphisms dates to the Krohn-Rhodes theorem (1965), which decomposes finite semigroups into iterable components. Our work takes a different perspective: rather than decomposing the state monoid, we study the *congruence induced on the input monoid* by the encoding map, and the *category of such maps* ordered by forgetting.

Information-theoretic approaches to lossy compression (Shannon, 1959) quantify information loss via rate-distortion theory. Our approach is purely algebraic — we characterize the *structure* of information loss (as a congruence and a submonoid) rather than its *magnitude* (in bits).

### 1.3 Contributions

We make the following formally verified contributions:

1. **Memory Compression Theorem**: Any monoid homomorphism from `FreeMonoid α` to a finite monoid, where `|α| ≥ 2`, is non-injective.
2. **Oblivion Kernel Theorem**: When the codomain is a finite group, the monoid kernel contains non-identity elements, constructed explicitly via element orders.
3. **Forgetting Factorization**: The encoding of a "more forgetful" memory system factors through the quotient by the congruence of a "less forgetful" one.
4. **Monotonicity**: Post-processing cannot decrease information loss.
5. **Capacity Bound**: At most `|S|` experience streams can be mutually distinguished by a memory system with state space `S`.
6. **Lattice Structure**: The forgetting strategies form a complete lattice, with perfect memory at the bottom and total amnesia at the top.

---

## 2. Definitions

### 2.1 Experience Streams

Let `α` be a finite alphabet. The **free monoid** `FreeMonoid α` is the set of all finite sequences (lists) over `α`, with concatenation as the monoid operation and the empty sequence as identity.

### 2.2 Memory Systems

**Definition 1** (Memory System). A *memory system* over alphabet `α` with state space `S` is a pair `(S, φ)` where `S` is a finite monoid and `φ : FreeMonoid α →* S` is a monoid homomorphism.

We encode this as:
```
structure MemorySystem (α : Type*) (S : Type*) [Monoid S] [Fintype S] where
  encode : FreeMonoid α →* S
```

### 2.3 Information Loss

**Definition 2** (Information Loss Congruence). The *information loss congruence* of a memory system `(S, φ)` is the congruence `Con.ker φ` on `FreeMonoid α`, defined by:
$$x \sim y \iff \varphi(x) = \varphi(y)$$

**Definition 3** (Oblivion Kernel). The *oblivion kernel* is the monoid kernel `MonoidHom.mker φ = \{x \in \text{FreeMonoid}\ α \mid \varphi(x) = 1\}`, which is a submonoid of `FreeMonoid α`.

### 2.4 Memory Morphisms

**Definition 4** (Memory Morphism). A *memory morphism* from `(S, φ₁)` to `(T, φ₂)` is a monoid homomorphism `f : S →* T` such that `f ∘ φ₁ = φ₂`.

### 2.5 Forgetting Order

**Definition 5** (Forgets More). Memory system `(S, φ₂)` *forgets more than* `(S, φ₁)` if `Con.ker φ₁ ≤ Con.ker φ₂`, i.e., whenever φ₁ identifies two streams, φ₂ also identifies them.

---

## 3. Main Results

### 3.1 Memory Compression Theorem

**Theorem 1** (Memory Compression). *Let `α` be a finite alphabet with `|α| ≥ 2`, and let `(S, φ)` be a memory system. Then `φ` is not injective.*

*Proof sketch.* The free monoid `FreeMonoid α ≅ List α` is infinite when `|α| ≥ 2`: the map `n ↦ [a, a, ..., a]` (n copies of any fixed `a ∈ α`) is an injection from `ℕ` into `List α`, using the fact that lists of different lengths are distinct. Since `S` is a `Fintype`, any injection from an infinite type to a `Finite` type yields a contradiction (by `not_injective_infinite_finite`). □

**Theorem 2** (Nontrivial Congruence). *Under the same hypotheses, there exist distinct streams `x ≠ y` with `φ(x) = φ(y)`.*

This is the existential witness form of Theorem 1.

### 3.2 Oblivion Kernel Theorem

**Theorem 3** (Nontrivial Oblivion Kernel for Groups). *Let `α` be a finite alphabet with `|α| ≥ 2`, and let `(G, φ)` be a memory system where `G` is a finite group. Then there exists `x ∈ \text{FreeMonoid}\ α` with `x ≠ 1` and `φ(x) = 1`.*

*Proof sketch.* Pick any `a ∈ α`. The element `g = φ(\text{of}(a)) ∈ G` has finite order `d = \text{orderOf}(g) ≥ 1` (since `G` is finite). Then:
$$\varphi((\text{of}(a))^d) = g^d = 1$$
The element `(of(a))^d` in `FreeMonoid α` is a list of length `d ≥ 1`, hence non-empty, hence `≠ 1 = []`. □

**Remark.** The group hypothesis is essential. For monoids, the oblivion kernel can be trivial even when the system is lossy. Consider the monoid `({0, 1}, ·)` with multiplication, and the map sending every non-empty stream to 0 and the empty stream to 1. This is lossy but has trivial monoid kernel (only the empty stream maps to 1).

### 3.3 Forgetting Factorization Theorem

**Theorem 4** (Factorization). *If `Con.ker φ₁ ≤ Con.ker φ₂`, then `φ₂` factors through the quotient `FreeMonoid α / Con.ker φ₁`:*
$$\varphi_2 = \tilde{\varphi} \circ \pi$$
*where `π` is the canonical projection and `φ̃` is the lifted map `Con.lift`.*

*Proof.* This is the universal property of quotients applied to `Con.lift`. The hypothesis `Con.ker φ₁ ≤ Con.ker φ₂` is precisely the compatibility condition required for `Con.lift` to be well-defined. □

### 3.4 Monotonicity

**Theorem 5** (Monotonicity of Information Loss). *For any memory system `(S, φ)` and monoid homomorphism `f : S →* T`, we have `Con.ker φ ≤ Con.ker (f ∘ φ)`.*

*Proof.* If `φ(x) = φ(y)`, then `f(φ(x)) = f(φ(y))`, i.e., `(f ∘ φ)(x) = (f ∘ φ)(y)`. □

### 3.5 Capacity Bound

**Theorem 6** (Memory Capacity Bound). *If `xs` is a finite set of experience streams that are mutually distinguished by `φ` (i.e., `φ` is injective on `xs`), then `|xs| ≤ |S|`.*

*Proof.* The restriction of `φ` to `xs` is injective, so `|xs| ≤ |image(φ|_{xs})| ≤ |S|`. □

### 3.6 Lattice of Forgetting Strategies

**Theorem 7** (Perfect Memory). *The bottom congruence `⊥` on `FreeMonoid α` is equality: `⊥(x, y) ↔ x = y`.*

**Theorem 8** (Total Amnesia). *The top congruence `⊤` on `FreeMonoid α` identifies all elements: `⊤(x, y)` for all `x, y`.*

These characterize the extremes of the forgetting lattice.

### 3.7 Categorical Structure

**Theorem 9** (Morphism ⟹ More Forgetting). *If there exists a memory morphism `(f, f ∘ φ₁ = φ₂)` from `(S, φ₁)` to `(T, φ₂)`, then `Con.ker φ₁ ≤ Con.ker φ₂`.*

*Proof.* If `φ₁(x) = φ₁(y)`, then `φ₂(x) = f(φ₁(x)) = f(φ₁(y)) = φ₂(y)`. □

---

## 4. The Memory Algebra Category

Memory systems over a fixed alphabet `α` form a category **Mem(α)** where:
- **Objects**: pairs `(S, φ)` with `S` a finite monoid and `φ : FreeMonoid α →* S`.
- **Morphisms**: monoid homomorphisms `f : S →* T` with `f ∘ φ₁ = φ₂`.
- **Identity**: the identity homomorphism.
- **Composition**: composition of monoid homomorphisms.

We have verified that identity and composition are well-defined memory morphisms. The forgetting order on objects is the preorder induced by the existence of a morphism (Theorem 9 shows this is compatible with the congruence ordering).

---

## 5. Algorithms

### 5.1 Computing the Information Loss Congruence

Given a memory system defined by a monoid homomorphism `φ` (specified by the images of generators), the information loss congruence on streams of length ≤ n can be computed by:

1. Enumerate all streams of length ≤ n.
2. Apply φ to each stream.
3. Group streams by their φ-image.
4. Each group is a congruence class.

**Complexity**: O(k^n · n) where k = |α|, dominated by the enumeration.

### 5.2 Computing the Oblivion Kernel

For a finite group G and generator images g₁, ..., gₖ:
1. Compute dᵢ = orderOf(gᵢ) for each generator.
2. The words `(of aᵢ)^{dᵢ}` are in the oblivion kernel.
3. The oblivion kernel is the normal closure of these words (as a submonoid).

### 5.3 Comparing Forgetting Strategies

Given two memory systems φ₁, φ₂ on the same alphabet:
1. For each pair of streams (x, y) of bounded length, check if φ₁(x) = φ₁(y) implies φ₂(x) = φ₂(y).
2. If this holds for all pairs, conjecture φ₁ ≤ φ₂ in the forgetting order.

---

## 6. Discussion

### 6.1 Connections to Automata Theory

A memory system `(S, φ)` where `S` is a finite monoid and `φ` is specified by its action on generators is precisely the syntactic monoid theory of regular languages. Our results can be seen as giving algebraic characterizations of the limitations of finite automata from the perspective of information preservation.

### 6.2 Connections to Information Theory

The Memory Compression Theorem is the algebraic analogue of the source coding theorem: compression below the source entropy is impossible. The difference is that our version is purely structural (no probability distributions) and applies to worst-case rather than average-case information loss.

### 6.3 Connections to Cognitive Science

The lattice of forgetting strategies provides a mathematical framework for thinking about the space of possible memory organizations. Two memory systems processing the same experiences can be compared by whether one's forgetting subsumes the other's. This may illuminate how different organisms with different state-space budgets can have qualitatively different memory organizations that are nonetheless mathematically related.

---

## 7. Future Work

1. **Quantitative information loss**: Relate the algebraic congruence structure to Shannon entropy, connecting our structural results with information-theoretic bounds.
2. **Topological memory**: Extend the framework to topological monoids, where the state space is not merely finite but has topological structure.
3. **Optimal forgetting**: Given a distribution over experience streams, characterize the memory system that minimizes expected distortion for a given state-space budget (connecting to rate-distortion theory).
4. **Dynamic memory**: Allow the encoding homomorphism to change over time, modeling learning and adaptation.
5. **Krohn-Rhodes decomposition of memory**: Apply the Krohn-Rhodes theorem to decompose memory systems into cascades of simple group and semigroup components.

---

## 8. References

1. Krohn, K. and Rhodes, J. (1965). Algebraic theory of machines. I. Prime decomposition theorem for finite semigroups and machines. *Transactions of the AMS*, 116, 450–464.
2. Shannon, C. E. (1959). Coding theorems for a discrete source with a fidelity criterion. *IRE National Convention Record*, 7(4), 142–163.
3. Eilenberg, S. (1976). *Automata, Languages, and Machines*, Vol. B. Academic Press.
4. Pin, J.-E. (1986). *Varieties of Formal Languages*. Plenum.

---

## Appendix: Formal Verification

All definitions and theorems in this paper have been formalized and verified in Lean 4 with Mathlib. The formalization consists of approximately 250 lines of Lean code, including:
- 1 novel structure (`MemorySystem`)
- 1 novel structure (`MemoryMorphism`)
- 5 definitions (`infoLossCon`, `oblivionKernel`, `IsLossless`, `IsLossy`, `ForgetsMoreThan`, `forgettingMap`)
- 9 verified theorems with no `sorry` and no non-standard axioms

The verified axiom dependencies are limited to `propext`, `Classical.choice`, and `Quot.sound`.
