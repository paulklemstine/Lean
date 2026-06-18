# Memory Editing: When Forgetting Is a Mathematical Operation

## Abstract

We develop a rigorous algebraic framework for memory systems, formalizing memory as a monoid homomorphism from the free monoid of experience streams to a finite monoid of memory states. We prove the **Finite Memory Lossiness Theorem**: any such homomorphism must be non-injective when the experience alphabet has at least two symbols, establishing that information loss is a mathematical necessity, not merely a practical limitation. We show that the resulting information loss has rich algebraic structure: the "confusion relation" (pairs of experience streams that produce identical memory states) forms a monoid congruence, the "perfectly forgotten" experiences form a submonoid, and targeted forgetting operations correspond precisely to quotient constructions in the lattice of congruences. We prove a **Lossiness Composition Theorem** showing that information loss is monotone and irreversible, and establish a **First Isomorphism Theorem for Memory** that factors every memory system through its confusion congruence into a faithful representation. All results are formalized and verified in Lean 4 with the Mathlib library.

## 1. Introduction

The study of memory — biological, computational, or artificial — has traditionally been approached from empirical and engineering perspectives. Neuroscientists catalog memory types (episodic, semantic, procedural), computer scientists design data structures and caching algorithms, and machine learning researchers build attention mechanisms and memory-augmented networks.

Missing from this landscape is a foundational mathematical theory that captures the *algebraic structure* of memory and forgetting. What does it mean, precisely, for a memory system to "forget"? Is there a canonical decomposition of the forgetting process? What invariants characterize the information that survives?

This paper provides answers by developing memory theory within the framework of abstract algebra, specifically monoid theory and congruence lattices. Our central objects are:

1. **Experience streams**: elements of the free monoid $\text{FreeMonoid}(\alpha)$ over an alphabet $\alpha$ of atomic experiences.
2. **Memory states**: elements of a finite monoid $M$.
3. **Memory systems**: monoid homomorphisms $\phi : \text{FreeMonoid}(\alpha) \to M$.

This apparently simple setup yields surprisingly rich structure and non-trivial theorems.

## 2. Definitions

### 2.1 Memory Systems

**Definition 2.1** (Memory System). A *memory system* over alphabet $\alpha$ with state space $M$ is a pair $(\alpha, \phi)$ where $M$ is a monoid and $\phi : \text{FreeMonoid}(\alpha) \to M$ is a monoid homomorphism.

The free monoid $\text{FreeMonoid}(\alpha)$ consists of finite lists of elements of $\alpha$, with concatenation as the monoid operation and the empty list as the identity. A memory system processes experience streams sequentially: the memory state after observing the stream $[a_1, a_2, \ldots, a_n]$ is $\phi(a_1) \cdot \phi(a_2) \cdots \phi(a_n)$.

### 2.2 Confusion and Lossiness

**Definition 2.2** (Confusion). Two experience streams $x, y \in \text{FreeMonoid}(\alpha)$ are *confused* by a memory system $\phi$ if $\phi(x) = \phi(y)$. We write $x \sim_\phi y$.

**Definition 2.3** (Lossless/Lossy). A memory system $\phi$ is *lossless* if $\phi$ is injective (no two distinct streams are confused). It is *lossy* if $\phi$ is not injective.

### 2.3 The Confusion Congruence

**Definition 2.4** (Confusion Congruence). The confusion relation $\sim_\phi$ is a monoid congruence on $\text{FreeMonoid}(\alpha)$: an equivalence relation that respects multiplication.

*Proof that $\sim_\phi$ is a congruence*: If $w \sim_\phi x$ and $y \sim_\phi z$, then:
$$\phi(w \cdot y) = \phi(w) \cdot \phi(y) = \phi(x) \cdot \phi(z) = \phi(x \cdot z)$$
so $w \cdot y \sim_\phi x \cdot z$. $\square$

### 2.4 The Kernel Submonoid

**Definition 2.5** (Kernel). The *kernel* of a memory system $\phi$ is $\ker(\phi) = \{x \in \text{FreeMonoid}(\alpha) : \phi(x) = 1\}$.

The kernel forms a submonoid: if $\phi(x) = 1$ and $\phi(y) = 1$, then $\phi(x \cdot y) = \phi(x) \cdot \phi(y) = 1 \cdot 1 = 1$, and $\phi(\epsilon) = 1$ by the homomorphism property.

### 2.5 Forgetting Maps

**Definition 2.6** (Forgetting Map). Given memory systems $\phi_1 : \text{FreeMonoid}(\alpha) \to M$ and $\phi_2 : \text{FreeMonoid}(\alpha) \to N$, a *forgetting map* from $\phi_1$ to $\phi_2$ is a monoid homomorphism $f : M \to N$ such that $\phi_2 = f \circ \phi_1$.

A forgetting map represents a further compression of memory: the memory states of $\phi_1$ are post-processed through $f$ to produce the coarser memory states of $\phi_2$.

## 3. Main Results

### 3.1 The Finite Memory Lossiness Theorem

**Theorem 3.1** (Finite Memory Lossiness). Let $|\alpha| \geq 2$ and let $M$ be a finite monoid. Then every memory system $\phi : \text{FreeMonoid}(\alpha) \to M$ is lossy.

*Proof sketch*. The free monoid on $\geq 2$ generators is infinite (the words $a^n$ for $n = 0, 1, 2, \ldots$ are all distinct, having different lengths). Since $M$ is finite, by the pigeonhole principle, $\phi$ cannot be injective. $\square$

This theorem establishes that *any* finite memory system must forget. No encoding scheme, no matter how clever, can compress an infinite stream of diverse experiences into a finite state space without losing information. This is a fundamental impossibility result.

**Remark.** The theorem requires $|\alpha| \geq 2$. For $|\alpha| = 1$, the free monoid is $(\mathbb{N}, +)$, and a monoid homomorphism to a finite monoid is determined by the image of the generator. The image generates a finite cyclic subgroup, so the map is still non-injective. However, our formalization uses the two-generator assumption for technical convenience.

### 3.2 The Forgetting Coarsening Theorem

**Theorem 3.2** (Forgetting Coarsens). If there exists a forgetting map from $\phi_1$ to $\phi_2$, then $\sim_{\phi_2}$ is coarser than $\sim_{\phi_1}$: if $x \sim_{\phi_1} y$, then $x \sim_{\phi_2} y$.

*Proof*. If $\phi_1(x) = \phi_1(y)$ and $\phi_2 = f \circ \phi_1$, then $\phi_2(x) = f(\phi_1(x)) = f(\phi_1(y)) = \phi_2(y)$. $\square$

**Corollary.** In the lattice of congruences on $\text{FreeMonoid}(\alpha)$, a forgetting map from $\phi_1$ to $\phi_2$ implies $\sim_{\phi_1} \leq \sim_{\phi_2}$.

### 3.3 The Lossiness Composition Theorem

**Theorem 3.3** (Lossiness Composition). If $\phi$ is lossy, then $g \circ \phi$ is lossy for any monoid homomorphism $g$.

*Proof*. Since $\phi$ is lossy, there exist $x \neq y$ with $\phi(x) = \phi(y)$. Then $g(\phi(x)) = g(\phi(y))$, so $g \circ \phi$ is also not injective. $\square$

This theorem formalizes the irreversibility of information loss. Once a memory system has confused two experiences, no post-processing can separate them.

### 3.4 The Memory Capacity Bound

**Theorem 3.4** (Memory Capacity Bound). If $M$ is a finite monoid and $S$ is a set of experience streams that are pairwise distinguishable by $\phi$ (i.e., $\phi$ restricted to $S$ is injective), then $|S| \leq |M|$.

*Proof*. The restriction of $\phi$ to $S$ is an injection into $M$, so $|S| \leq |M|$ by the pigeonhole principle. $\square$

### 3.5 The First Isomorphism Theorem for Memory

**Theorem 3.5** (Factorization). Every memory system $\phi : \text{FreeMonoid}(\alpha) \to M$ factors as $\phi = \bar{\phi} \circ \pi$, where $\pi : \text{FreeMonoid}(\alpha) \to \text{FreeMonoid}(\alpha)/\!\sim_\phi$ is the quotient map and $\bar{\phi}$ is an injective monoid homomorphism.

*Proof*. Apply the First Isomorphism Theorem for monoids. The congruence $\sim_\phi$ is exactly the kernel pair of $\phi$, so the induced map on the quotient is well-defined and injective. $\square$

This theorem says that every memory system has a canonical decomposition: first project onto equivalence classes (the forgetting step), then faithfully embed into the state space (the representation step). The confusion congruence completely characterizes the memory system up to isomorphism of state spaces.

### 3.6 Congruence Properties

**Theorem 3.6** (Left and Right Congruence). If $x \sim_\phi y$, then $z \cdot x \sim_\phi z \cdot y$ and $x \cdot z \sim_\phi y \cdot z$ for all $z$.

These properties state that confusion is "contextual": if two experiences are confused, they remain confused in any context. This is a direct consequence of $\sim_\phi$ being a congruence, but it has important cognitive implications: if a memory system can't distinguish between two experiences in isolation, it can't distinguish them in any temporal context.

## 4. Algorithms

### 4.1 Memory System Simulation

Given a finite alphabet $\alpha = \{0, 1, \ldots, k-1\}$ and a finite monoid $M$ defined by its multiplication table, a memory system is completely determined by the images $\phi(a_i)$ for each generator $a_i$.

**Algorithm: Simulate Memory System**
```
Input: generators g[0..k-1] in M, experience stream s[0..n-1]
state ← identity
for i in 0..n-1:
    state ← state * g[s[i]]
return state
```

### 4.2 Confusion Detection

**Algorithm: Detect Confusion**
```
Input: memory system φ, streams x, y
return φ(x) == φ(y)
```

### 4.3 Confusion Congruence Enumeration

For finite-length streams up to length $n$, enumerate all confusion classes:

**Algorithm: Enumerate Confusion Classes**
```
Input: memory system φ, max length n
classes ← empty dict
for each stream s of length ≤ n:
    state ← φ(s)
    add s to classes[state]
return classes
```

## 5. Discussion

### 5.1 Connections to Information Theory

The confusion congruence provides a *combinatorial* counterpart to Shannon's information-theoretic notion of channel capacity. While Shannon measures information in bits, our framework measures it in congruence classes. The two perspectives are complementary: Shannon tells you *how much* information survives; the congruence framework tells you *which* information survives and how it's structured.

### 5.2 Connections to Automata Theory

A memory system with a finite monoid $M$ is closely related to a finite automaton. The Myhill-Nerode theorem states that a language is regular if and only if it has finitely many equivalence classes under a right congruence. Our confusion congruence is a two-sided congruence, which is stronger. The quotient $\text{FreeMonoid}(\alpha)/\!\sim_\phi$ is precisely the *syntactic monoid* of the language recognized by $\phi$.

### 5.3 Implications for AI Memory Design

The lattice of congruences provides a principled design space for AI memory systems. Rather than engineering memory architectures ad hoc, one can:

1. Specify the desired confusion congruence (which experiences should be identified).
2. Construct the quotient monoid.
3. Implement any monoid homomorphism onto that quotient.

This "congruence-first" design methodology ensures that the memory system has exactly the forgetting properties required, no more and no less.

### 5.4 Biological Implications

The framework suggests that biological memory systems can be characterized by their confusion congruences rather than their neural substrates. Two organisms with different neural architectures but the same confusion congruence implement mathematically equivalent memory systems. This provides a substrate-independent notion of "same memory capability."

## 6. Future Work

1. **Probabilistic memory systems**: Extend the framework to stochastic homomorphisms, where the encoding map is a random variable. This would capture noisy biological memories.

2. **Temporal discounting**: Model time-dependent forgetting by allowing the memory homomorphism to vary over time, creating a functor from the time category to the category of memory systems.

3. **Memory composition**: Study the tensor product of memory systems, formalizing how multiple independent memory channels can be combined.

4. **Optimal forgetting**: Given a cost function on confusion classes, find the memory system of a given size that minimizes cost. This is a combinatorial optimization problem on the congruence lattice.

5. **Infinite memory with finite description**: Study memory systems where $M$ is finitely generated but not necessarily finite, capturing systems with unbounded but structured memory.

## 7. Conclusion

We have established that memory, viewed as compression of sequential experience, has a precise algebraic structure. The central objects — the confusion congruence, the kernel submonoid, and the forgetting lattice — provide a complete characterization of what any finite memory system can and cannot distinguish. The Finite Memory Lossiness Theorem shows that forgetting is inevitable; the First Isomorphism Theorem shows that forgetting is structured; and the Lossiness Composition Theorem shows that forgetting is irreversible.

Together, these results transform our understanding of memory from an empirical phenomenon to a mathematical one. Forgetting is not noise — it is a quotient operation.

## References

1. S. Eilenberg, *Automata, Languages, and Machines*, Volume A, Academic Press, 1974.
2. J.-É. Pin, *Varieties of Formal Languages*, Plenum Press, 1986.
3. C. Shannon, "A Mathematical Theory of Communication," *Bell System Technical Journal*, 27(3):379–423, 1948.
4. J. Myhill, "Finite automata and the representation of events," WADD TR-57-624, 1957.
5. A. Nerode, "Linear automaton transformations," *Proceedings of the AMS*, 9(4):541–544, 1958.
