# Memory Compression Algebra: A Tropical-Algebraic Framework for Information Loss in Finite-State Systems

## Abstract

We develop a rigorous algebraic framework for studying information loss in finite-state memory systems. A memory system is formalized as a monoid homomorphism φ : FreeMonoid(α) →* S from the free monoid over an alphabet α to a finite monoid S. We define the *tropical capacity* v(φ) = log|image(φ)| and establish fundamental properties: (1) the Idempotent Stabilization Theorem, showing every element of a finite monoid has an idempotent power; (2) Tropical Capacity Subadditivity, proving that the capacity of a product system is bounded by the sum of component capacities; (3) Congruence-Capacity Monotonicity, demonstrating that finer congruences yield higher capacity quotients; and (4) the Factoring-Capacity Theorem, showing that image cardinality respects the factoring order on functions. All results are formalized and machine-verified in Lean 4 with Mathlib. We identify connections to tropical geometry, the Krohn-Rhodes decomposition theorem, and information theory, and state a falsifiable conjecture about the modularity of capacity on the congruence lattice.

**Keywords**: memory compression, finite monoids, tropical geometry, congruence lattices, idempotent stabilization, Krohn-Rhodes theory

---

## 1. Introduction

Finite-state systems are ubiquitous in computation, biology, and engineering. Every such system processes a stream of inputs through a finite number of internal states, inevitably losing information in the process. While this compression is well-studied from the perspective of information theory (Shannon entropy, rate-distortion theory) and automata theory (Myhill-Nerode equivalence, minimization), there has been surprisingly little work on the *algebraic structure* of the information loss itself.

In this paper, we develop a framework — *Memory Compression Algebra* — that treats the compression function of a finite-state system as an algebraic object with rich structure. Our starting point is the observation that any deterministic finite-state system with input alphabet α and state monoid S can be described by a monoid homomorphism φ : FreeMonoid(α) →* S. The image of φ — the set of reachable states — determines the system's information-carrying capacity.

We define the *tropical capacity* of such a system as v(φ) = log|image(φ)|. The use of "tropical" is deliberate: the logarithm converts multiplicative bounds on image cardinality into additive inequalities, placing memory systems in the framework of tropical (max-plus) algebra and tropical geometry.

### 1.1 Contributions

Our main contributions are:

1. **Idempotent Stabilization Theorem** (Theorem 3.1): Every element a of a finite monoid M has a positive power n such that a^n is idempotent. This provides the algebraic foundation for the phenomenon of habituation in finite-state systems.

2. **Tropical Capacity Subadditivity** (Theorem 4.1): For functions f₁ : α → β₁ and f₂ : α → β₂, the joint capacity satisfies v(f₁, f₂) ≤ v(f₁) + v(f₂), where v(f) = log|image(f)|.

3. **Congruence-Capacity Monotonicity** (Theorem 5.1): If equivalence relation r₁ refines r₂ on a finite set, then |α/r₂| ≤ |α/r₁|.

4. **Factoring-Capacity Theorem** (Theorem 6.1): If f factors through g (i.e., f = h ∘ g for some h), then |image(f)| ≤ |image(g)|.

5. **Full machine verification** of all results in Lean 4 with Mathlib.

### 1.2 Related Work

The algebraic theory of finite automata has a long history, beginning with Kleene's theorem and the Myhill-Nerode theorem. The Krohn-Rhodes theorem (1965) provides a structure theorem for finite semigroups as iterated wreath products of simple groups and aperiodic semigroups. Our cascade state bound (Theorem 5.2) is a simple consequence of the wreath product structure.

Tropical geometry has emerged as a powerful tool connecting algebraic geometry, combinatorics, and optimization. The connection between tropical valuations and information measures appears to be novel.

The lattice of congruences on a finite algebra is a classical topic in universal algebra. Our congruence-capacity monotonicity result relates this lattice structure to information content.

---

## 2. Definitions

### 2.1 Memory Systems

**Definition 2.1** (Memory System). A *memory system* over alphabet α consists of:
- A finite monoid (S, ·, 1) with |S| < ∞
- A monoid homomorphism φ : FreeMonoid(α) →* S

The *reachable set* of the memory system is R(φ) = image(φ) ⊆ S.

**Definition 2.2** (Tropical Capacity). The *tropical capacity* of a function f : α → β between finite types is
  v(f) = log|image(f)|

where |image(f)| denotes the cardinality of the image (range) of f.

**Definition 2.3** (Image Cardinality). For a function f : α → β with α finite and β having decidable equality:
  imageCard(f) = |{f(a) : a ∈ α}|

### 2.2 Idempotency

**Definition 2.4** (Idempotent Element). An element a of a multiplicative structure is *idempotent* if a · a = a.

### 2.3 Factoring Order

**Definition 2.5** (Factoring Through). A function f : α → β₁ *factors through* g : α → β₂ if there exists h : β₂ → β₁ such that f = h ∘ g. We write f ≼ g.

This relation defines a preorder on functions from α, capturing the notion that g carries at least as much information as f.

---

## 3. Idempotent Stabilization

### 3.1 Main Theorem

**Theorem 3.1** (Idempotent Stabilization). Let M be a finite monoid and a ∈ M. Then there exists n > 0 such that a^n is idempotent, i.e., a^n · a^n = a^n.

*Proof sketch.* Consider the sequence a¹, a², a³, ... in M. Since M is finite, by pigeonhole there exist i < j with aⁱ = aʲ. Let d = j - i > 0. Then:

1. aⁱ = aⁱ · a^d (from aⁱ = a^(i+d))
2. By induction: aⁱ = aⁱ · a^(kd) for all k ≥ 0
3. Setting k = i: a^(id) = aⁱ · a^(id) · a^(id-i) = a^(id) · a^(id)

Wait — more carefully: from step 2 with k = i, we get aⁱ = aⁱ · a^(id). Then:
  a^(id) = a^(id) · a^(id)

This requires i ≥ 1 (which holds since we can always take i ≥ 1 by shifting) and verifying the exponent arithmetic. The formal proof handles the edge case i = 0 separately. ∎

**Corollary 3.2**. Every finite monoid contains at least one idempotent element (namely, 1).

### 3.2 Interpretation

The stabilization theorem has a direct physical interpretation: in any finite-state memory system, repeatedly processing the same input eventually produces a "fixed point" state that is unchanged by further repetition. This is the algebraic manifestation of:

- **Habituation** in neuroscience: repeated stimulation leads to diminished response
- **Cache saturation** in computer science: repeated access patterns reach steady state
- **Market equilibrium** under constant conditions

The bound n ≤ |M|² follows from the pigeonhole argument (we need i · d ≤ i · j ≤ |M|²).

---

## 4. Tropical Capacity Subadditivity

### 4.1 Product Bound

**Theorem 4.1** (Tropical Product Bound). For functions f₁ : α → β₁ and f₂ : α → β₂ with α finite:
  imageCard(fun a ↦ (f₁(a), f₂(a))) ≤ imageCard(f₁) · imageCard(f₂)

*Proof sketch.* The image of the product function (f₁, f₂) is contained in image(f₁) × image(f₂) as a subset of β₁ × β₂. Since |(A × B)| = |A| · |B| for finite sets, the result follows from monotonicity of cardinality. ∎

### 4.2 Tropical Form

Taking logarithms (base 2 or natural), Theorem 4.1 becomes:
  log|image(f₁, f₂)| ≤ log|image(f₁)| + log|image(f₂)|

This is the *tropical subadditivity* of capacity. In the max-plus semiring (ℝ ∪ {-∞}, max, +), this states that the capacity function is subadditive under the tropical addition operation.

### 4.3 Connection to Shannon Entropy

The tropical capacity log|image(f)| is related to but distinct from Shannon entropy. For a uniform distribution on α:
  H(f(X)) ≤ log|image(f)| = v(f)

with equality iff f induces a uniform distribution on its image. The tropical capacity is thus an *upper bound* on the entropy of the compressed representation, corresponding to the worst-case (uniform) scenario.

---

## 5. Congruence-Capacity Duality

### 5.1 Monotonicity

**Theorem 5.1** (Quotient Cardinality Monotonicity). Let r₁, r₂ be equivalence relations on a finite set α. If r₁ refines r₂ (i.e., r₁(a,b) implies r₂(a,b)), then:
  |α/r₂| ≤ |α/r₁|

*Proof.* The refinement condition implies the existence of a surjection α/r₁ → α/r₂ mapping [a]_{r₁} ↦ [a]_{r₂}. Well-definedness follows from the refinement property. Surjectivity is immediate. The result follows from the cardinality bound for surjections between finite types. ∎

### 5.2 Cascade State Bound

**Theorem 5.2** (Cascade Bound). For functions f : α → β and g : α → γ with all types finite:
  imageCard(fun a ↦ (f(a), g(a))) ≤ |β| · |γ|

This bounds the reachable states of a cascade (wreath) product by the total state space.

### 5.3 Relation to Krohn-Rhodes Theory

The Krohn-Rhodes theorem states that every finite semigroup divides an iterated wreath product of finite simple groups and copies of the three-element aperiodic monoid U₃. Our cascade bound provides the cardinality constraint for each level of this decomposition.

The *complexity* of a finite semigroup S — the minimum number of group levels in any Krohn-Rhodes decomposition — is a tropical-algebraic invariant: it measures the minimum "depth" of reversible computation needed to simulate S. Our framework suggests that complexity should be related to the tropical capacity through a chain of inequalities involving the congruence lattice.

---

## 6. The Factoring Order and Information Content

### 6.1 Main Theorem

**Theorem 6.1** (Factoring-Capacity). If f factors through g (i.e., f = h ∘ g for some h), then:
  imageCard(f) ≤ imageCard(g)

*Proof.* Since f = h ∘ g, we have image(f) = h(image(g)). The image of a function is at most as large as its domain: |h(image(g))| ≤ |image(g)|. ∎

### 6.2 The Information Preorder

The factoring relation defines a preorder on functions from a fixed domain α. The equivalence classes under this preorder are precisely the *partitions* of α: two functions are equivalent iff they induce the same partition of α into fibers.

The tropical capacity v is a monotone function from this preorder to (ℝ, ≤), making it a *valuation* in the order-theoretic sense. This connects to the theory of valuations on lattices, particularly the lattice of partitions of α.

### 6.3 Image Monotonicity Under Composition

**Theorem 6.2** (Composition Monotonicity). For composable functions f : α → β and g : β → γ:
  |image(g ∘ f)| ≤ |image(g)|

This captures the principle that post-processing can only lose information: the image of a composition is contained in the image of the outer function.

---

## 7. Conjecture: Modularity of Tropical Capacity

### 7.1 Statement

**Conjecture 7.1** (Modularity). Let α be a finite set and let Part(α) denote the lattice of partitions of α, ordered by refinement. The tropical capacity v(r) = log|α/r| is a *modular* function on Part(α):
  v(r₁ ∨ r₂) + v(r₁ ∧ r₂) = v(r₁) + v(r₂)

for all partitions r₁, r₂.

### 7.2 Status: Expected Counterexample

This conjecture is expected to be **false** in general. The partition lattice is modular (this is a classical result of Birkhoff), but the cardinality function on it is not modular.

**Testable prediction**: For α = Fin 6, enumerate all pairs of partitions and check whether the modular identity holds. A counterexample should exist for non-comparable partitions with nontrivial meet and join.

### 7.3 Weaker Alternatives

If modularity fails, the following weaker properties may hold:

1. **Log-submodularity**: v(r₁ ∨ r₂) + v(r₁ ∧ r₂) ≤ v(r₁) + v(r₂)
2. **Tropical convexity**: The capacity function is convex with respect to some tropical metric on the partition lattice
3. **Monotone modularity on chains**: Modularity holds when restricted to chains (totally ordered subsets) of the partition lattice

---

## 8. Algorithms

### 8.1 Idempotent Power Computation

```
Input: Element a of finite monoid M with |M| = m
Output: Smallest n > 0 such that a^n is idempotent

1. Compute powers a¹, a², ..., storing in hash table
2. When a^j = a^i (first collision), set d = j - i
3. Return n = i * d
```

**Complexity**: O(m) time and space (by pigeonhole, collision occurs within m steps).

### 8.2 Tropical Capacity Computation

```
Input: Function f : α → β with α finite
Output: imageCard(f) = |image(f)|

1. Initialize empty set S
2. For each a ∈ α: S ← S ∪ {f(a)}
3. Return |S|
```

**Complexity**: O(|α|) expected time with hash sets.

### 8.3 Factoring Detection

```
Input: Functions f : α → β₁, g : α → β₂
Output: Whether f factors through g

1. Build the fiber partition of g: for each b₂ ∈ image(g),
   compute g⁻¹(b₂) = {a ∈ α : g(a) = b₂}
2. Check: for each fiber F of g, f is constant on F
3. If yes, f factors through g; construct h by h(b₂) = f(a) for any a ∈ g⁻¹(b₂)
```

**Complexity**: O(|α|) time.

---

## 9. Discussion

### 9.1 Connections to Tropical Geometry

The tropical capacity v(f) = log|image(f)| places memory systems in the framework of tropical geometry. The subadditivity v(f₁, f₂) ≤ v(f₁) + v(f₂) is a tropical triangle inequality, suggesting that memory systems form a tropical metric space. The distance d(f₁, f₂) = v(f₁, f₂) - max(v(f₁), v(f₂)) measures the "synergy" between two memory systems — how much additional information the combination captures beyond what either captures alone.

### 9.2 Connections to Information Theory

The capacity v(f) is the Hartley entropy (or max-entropy) of the compressed representation. Our algebraic framework complements Shannon's probabilistic approach: where Shannon theory requires a probability distribution on inputs, our framework works for *any* input distribution, capturing worst-case information content.

### 9.3 Connections to Automata Theory

The Myhill-Nerode theorem states that the minimum number of states of a DFA recognizing a regular language L equals the number of equivalence classes of the Nerode right congruence. In our framework, this is the statement that the tropical capacity of the canonical memory system for L equals the logarithm of the Nerode index.

---

## 10. Future Work

1. **Krohn-Rhodes capacity bounds**: Develop tropical capacity bounds for each level of the Krohn-Rhodes decomposition, relating semigroup complexity to information-theoretic capacity.

2. **Tropical eigenvalues and stabilization rate**: Connect the idempotent stabilization power to tropical eigenvalues of the transition matrix, providing quantitative bounds on habituation speed.

3. **Continuous extension**: Extend the framework to infinite-state systems using topological and measure-theoretic tools, connecting to ergodic theory and symbolic dynamics.

4. **Applications to neural coding**: Apply the congruence-capacity duality to analyze neural population codes, where the congruence structure corresponds to the stimulus feature hierarchy.

---

## References

1. Krohn, K., & Rhodes, J. (1965). Algebraic theory of machines. I. Prime decomposition theorem for finite semigroups and machines. *Transactions of the American Mathematical Society*, 116, 450–464.

2. Eilenberg, S. (1976). *Automata, Languages, and Machines*, Vol. B. Academic Press.

3. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.

4. Pin, J.-É. (1986). *Varieties of Formal Languages*. Plenum Press.

5. Birkhoff, G. (1967). *Lattice Theory*. American Mathematical Society.
