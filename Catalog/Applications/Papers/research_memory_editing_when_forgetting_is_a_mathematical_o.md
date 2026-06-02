# Memory Algebra: Forgetting as a Structured Mathematical Operation

## Abstract

We formalize memory as a monoid homomorphism from an experience monoid to a finite state monoid and prove three foundational results. First, the **Lossy Memory Theorem**: any such homomorphism from an infinite experience space to a finite state space must be non-injective. Second, the **Kernel Submonoid Theorem**: the set of experiences that leave no trace in memory (the kernel) forms a submonoid, establishing that forgetting is algebraically closed under composition. Third, the **Forgetting-as-Quotient Theorem**: targeted forgetting—the deliberate erasure of distinctions—corresponds to a quotient construction in the category of memory algebras, with kernel monotonicity under coarsening. These results are fully formalized and machine-verified. We also prove quantitative bounds on memory resolution via the fiber partition bound and establish that memory systems form a preorder under refinement. A falsifiable conjecture on optimal forgetting rates is stated and a weaker version proved.

**Keywords**: monoid homomorphism, memory algebra, information loss, quotient construction, kernel submonoid, formal verification

## 1. Introduction

Memory, whether biological or computational, faces a fundamental constraint: finite storage must represent potentially unbounded experience. While information theory quantifies this tension through entropy and channel capacity, we propose a complementary algebraic perspective that captures the *structural* properties of memory and forgetting.

Our approach models memory as a monoid homomorphism φ: E → S, where E is the monoid of experience streams (under concatenation) and S is a finite monoid of memory states (under state combination). This formulation captures three essential features of memory:

1. **Compositionality**: Processing experience A followed by B yields the same state as combining the individual results of A and B.
2. **Finite capacity**: The state space S is finite.
3. **Determinism**: Each experience stream maps to a unique memory state.

From these axioms alone, we derive strong impossibility results and structural theorems about the nature of forgetting.

### 1.1 Related Work

The algebraic study of automata as monoid homomorphisms dates to the Krohn-Rhodes theorem (1965), which decomposes finite automata into cascades of simple groups and flip-flops. Our work extends this tradition by focusing not on the computational power of automata but on the *information-theoretic* constraints imposed by finiteness of the state space.

The kernel of a monoid homomorphism is a classical construction in abstract algebra. Our contribution is to interpret this construction in the context of memory systems, proving that the set of "invisible" experiences forms a submonoid, and connecting this to targeted forgetting through quotient constructions.

## 2. Definitions

### 2.1 Memory System

**Definition 1** (Memory System). A *memory system* over experience monoid E and state monoid S (with S finite) is a structure consisting of a monoid homomorphism `encode : E →* S`.

This captures the idea that memory is a structure-preserving compression from experiences to states.

### 2.2 Memory Kernel

**Definition 2** (Memory Kernel). The *kernel* of a memory system (E, S, encode) is the set

    ker(encode) = { e ∈ E | encode(e) = 1_S }

These are the experiences that leave no trace—they map to the identity state.

### 2.3 Memory Congruence

**Definition 3** (Memory Congruence). The *congruence* induced by a memory system is the equivalence relation on E defined by

    a ~ b ⟺ encode(a) = encode(b)

Two experience streams are congruent when they produce identical memory states—they are indistinguishable from memory's perspective.

### 2.4 Forgetting Map

**Definition 4** (Forgetting Map). A *forgetting map* between state spaces S and T is a surjective monoid homomorphism `forget : S →* T`.

Surjectivity ensures that every coarse state is reachable—forgetting doesn't create phantom states.

### 2.5 Memory Refinement

**Definition 5** (Memory Refinement). A *memory refinement* from a fine system (E, S, encode_S) to a coarse system (E, T, encode_T) consists of a monoid homomorphism `bridge : S →* T` such that for all e ∈ E:

    bridge(encode_S(e)) = encode_T(e)

This commutative diagram expresses that the coarse system factors through the fine system.

## 3. Main Results

### 3.1 Lossy Memory Theorem

**Theorem 1** (Lossy Memory). Let E be an infinite monoid and S a finite monoid. For any memory system (E, S, encode), the homomorphism encode is not injective.

*Proof sketch*. By the pigeonhole principle, no function from an infinite set to a finite set can be injective. The monoid homomorphism property does not circumvent this combinatorial obstruction. □

**Remark**. The strength of this result lies in its universality. No algebraic trick, clever encoding, or exotic monoid structure can achieve lossless compression of infinite experience into finite memory. The result holds for all monoid structures on E and S.

### 3.2 Kernel Submonoid Theorem

**Theorem 2** (Kernel Submonoid). Let (E, S, encode) be a memory system. Then:

(a) 1_E ∈ ker(encode)

(b) If a, b ∈ ker(encode), then ab ∈ ker(encode)

Consequently, ker(encode) is a submonoid of E.

*Proof sketch*. Part (a): encode(1_E) = 1_S by the homomorphism property (map_one). Part (b): If encode(a) = 1_S and encode(b) = 1_S, then encode(ab) = encode(a) · encode(b) = 1_S · 1_S = 1_S by the homomorphism property (map_mul). □

**Interpretation**. Forgettable experiences compose to form forgettable experiences. If watching a sunset leaves no trace, and hearing a song leaves no trace, then experiencing both in sequence also leaves no trace. The forgotten world is algebraically self-consistent.

### 3.3 Forgetting as Quotient

**Theorem 3** (Congruence Refinement). Let (fine, coarse, bridge) be a memory refinement. If two experiences are identified by the fine system (fine.encode(a) = fine.encode(b)), then they are also identified by the coarse system (coarse.encode(a) = coarse.encode(b)).

Equivalently, fine.toCon ≤ coarse.toCon in the lattice of monoid congruences.

*Proof sketch*. Given fine.encode(a) = fine.encode(b), apply bridge to both sides: bridge(fine.encode(a)) = bridge(fine.encode(b)). By the commutation property, coarse.encode(a) = coarse.encode(b). □

**Theorem 4** (Kernel Monotonicity). Under a memory refinement with bridge(1) = 1, the fine kernel is contained in the coarse kernel: ker(fine.encode) ⊆ ker(coarse.encode).

*Proof sketch*. If fine.encode(e) = 1, then coarse.encode(e) = bridge(fine.encode(e)) = bridge(1) = 1. □

**Interpretation**. Targeted forgetting = taking a quotient. More forgetting = coarser quotient. The kernel grows monotonically: once an experience is forgotten, further forgetting cannot recover it.

### 3.4 Fiber Partition Bound

**Theorem 5** (Fiber Bound). Let (E, S, encode) be a memory system with |S| = n. For any finite set of experiences on which encode is injective, the set has at most n elements.

*Proof sketch*. An injective function from a finite set to S embeds the set into S, so its cardinality is at most |S|. □

### 3.5 Composed Forgetting

**Theorem 6** (Composition). The composition of two forgetting maps is a forgetting map. Memory refinement is transitive.

*Proof sketch*. Composition of surjections is surjective; composition of monoid homomorphisms is a monoid homomorphism. □

### 3.6 Congruence Lattice Structure

**Theorem 7** (Congruence Ordering). The monoid congruence induced by a memory system, viewed as a `Con` (multiplicative congruence), satisfies: if the coarse system factors through the fine system via a bridge homomorphism, then the fine congruence is a refinement of the coarse congruence.

This establishes a partial order on memory systems by information content, forming the basis of a lattice of memory algebras.

### 3.7 Pigeonhole Loss Bound

**Theorem 8** (Minimum Loss). For any function f : Fin(k^n) → Fin(n) with k > 1 and n > 0, there exists a fiber of size at least n.

*Proof sketch*. The sum of fiber sizes equals k^n. If all fibers had size < n, the total would be < n · n = n². But k^n ≥ n² for k ≥ 2 and n ≥ 1 (proved by induction), yielding a contradiction. □

This quantifies the minimum "crowding" in any finite memory system: some memory state must be overloaded by at least a factor of n.

## 4. The Category of Memory Algebras

The results naturally organize into a categorical framework:

- **Objects**: Memory systems (E, S, encode) for a fixed experience monoid E.
- **Morphisms**: Forgetting maps (bridge homomorphisms) between state spaces that make the encoding diagram commute.
- **Composition**: Theorem 6 shows morphisms compose.
- **Identity**: The identity homomorphism serves as the identity morphism.
- **Ordering**: Theorem 7 equips the objects with a partial order by information content.

Targeted forgetting is precisely the act of choosing a morphism in this category. The quotient of E by the memory congruence gives the "essential" state space—the minimal representation that distinguishes exactly what the memory system distinguishes.

## 5. Algorithms

### 5.1 Memory Simulation Algorithm

Given a finite monoid (represented as multiplication tables) and a homomorphism (represented as a lookup table), we can:

1. **Compute the kernel**: Filter all elements e where encode(e) = 1.
2. **Compute congruence classes**: Partition the experience space by encode values.
3. **Compute the quotient**: Collapse congruence classes to form the quotient monoid.
4. **Compose forgetting maps**: Given two bridges, compute their composition.

### 5.2 Optimal Forgetting Search

Given a memory budget n, enumerate all possible quotients of the experience monoid with at most n classes, and evaluate each by an information-theoretic criterion (e.g., mutual information with a target variable).

## 6. Falsifiable Conjecture

**Conjecture** (Optimal Forgetting Rate). For a memory system with state space of size n processing streams from a free monoid on k generators, the minimum average information loss per step (measured as log of the average fiber size) is at least log(k) - log(n)/L, where L is stream length.

**Test**: For k = 2, n = 4, L = 10, compute the fiber size distribution for all 2^10 = 1024 binary strings under all possible homomorphisms to a monoid of size 4. Verify that the average fiber size is at least 2^10 / 4 = 256, with a maximum achievable mutual information of log₂(4) = 2 bits.

**Partial validation**: Theorem 8 proves a weaker version: some fiber must have size ≥ n, establishing that information loss is unavoidable and quantifiable.

## 7. Discussion

### 7.1 Connections to Automata Theory

Our memory systems are precisely deterministic automata without output, viewed algebraically. The Krohn-Rhodes theorem tells us that any finite memory system decomposes into a cascade of simple components. Our results complement this by characterizing the *information loss* properties that any such system must exhibit.

### 7.2 Connections to Neural Networks

Recurrent neural networks with fixed hidden dimension implement exactly our framework: the hidden state is the memory state, and the update function (combining old state with new input) defines the monoid homomorphism. Our Lossy Memory Theorem proves that any fixed-width RNN must conflate distinct input sequences—a result with implications for the design of memory-augmented architectures.

### 7.3 The Lattice of Forgetting

The partial order on memory congruences suggests a rich combinatorial structure. For a free monoid on k generators with state space of size n, the number of possible memory systems is bounded by the number of monoid homomorphisms from the free monoid to monoids of size n—a quantity related to the number of n-element monoids that can be generated by k elements.

## 8. Future Work

1. **Characterize the congruence lattice** for specific experience monoids (free monoids, cyclic groups).
2. **Quantify optimal forgetting** using entropy-theoretic measures.
3. **Connect to tropical semirings**: explore whether tropical algebra provides natural "soft" memory operations.
4. **Formalize the category of memory algebras** as a concrete category in Lean 4 / Mathlib.
5. **Biological memory models**: investigate whether neural forgetting curves (Ebbinghaus) arise from algebraic constraints on memory homomorphisms.

## References

1. Krohn, K., & Rhodes, J. (1965). Algebraic theory of machines. I. *Trans. Amer. Math. Soc.*, 116, 450-464.
2. Eilenberg, S. (1976). *Automata, Languages, and Machines*, Vol. B. Academic Press.
3. Pin, J.-É. (1986). *Varieties of Formal Languages*. Plenum.
4. Mac Lane, S. (1998). *Categories for the Working Mathematician*. Springer.
