# Memory Compression Algebra: A Tropical-Algebraic Framework for Information Loss

## Abstract

We develop a rigorous algebraic framework for memory-as-compression, connecting finite semigroup theory, tropical valuations, and lattice-theoretic information ordering. The central object is the *compression rank* of a function — the cardinality of its image — which we show satisfies a bottleneck inequality under composition, stabilizes under iteration on finite types, and induces an ultrametric structure when passed through the logarithm (tropical capacity). We formalize eleven core theorems, including: (1) the Image Monotonicity Theorem showing composition cannot increase compression rank; (2) the Idempotent Stabilization Theorem for finite monoids; (3) the Tropical Bottleneck Inequality; (4) the Information Ordering Theorem relating kernel refinement to rank; (5) the Stabilization Theorem for iterated compression; and (6) the Cascade Product Rank Bound. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: compression rank, tropical capacity, finite semigroup, idempotent stabilization, information ordering, data processing inequality

---

## 1. Introduction

The data processing inequality — the principle that post-processing cannot increase information — is foundational to information theory, machine learning, and signal processing. Classical formulations use Shannon entropy or mutual information, but these require probabilistic assumptions that may not be natural in algebraic or automata-theoretic settings.

We propose an alternative framework based on *compression rank*: the cardinality of the image of a function. This combinatorial measure of information content requires no probability distribution, applies to any function between finite sets, and admits a rich algebraic theory connecting to:

- **Finite semigroup theory**: The transition functions of any finite-state automaton generate a finite semigroup, whose algebraic structure (idempotent powers, Green's relations, Krohn-Rhodes decomposition) governs the long-term behavior of the system.
- **Tropical geometry**: The logarithm of compression rank defines a *tropical capacity valuation* satisfying the tropical triangle inequality (ultrametric property), placing memory systems in a tropical metric space.
- **Lattice theory**: The kernel congruences of compression functions form a lattice under refinement, with rank providing a monotone invariant.

### 1.1 Contributions

1. **Compression rank algebra** (§2): Definition of compression rank and proof of the two-sided bottleneck inequality: rank(g ∘ f) ≤ min(rank(f), rank(g)).

2. **Idempotent stabilization** (§3): Proof that every element of a finite monoid has a positive idempotent power, with an explicit construction via pigeonhole.

3. **Tropical capacity** (§4): Definition of tropical capacity v(f) = log(rank(f)) and proof of the tropical bottleneck inequality v(g ∘ f) ≤ v(f).

4. **Information ordering** (§5): Proof that kernel refinement implies rank domination, establishing a monotone connection between congruence lattices and the natural numbers.

5. **Iteration stabilization** (§6): Proof that the compression rank sequence of iterates of any endofunction on a finite type is non-increasing and eventually constant.

6. **Cascade product bounds** (§7): Proof that the image cardinality of a product monoid homomorphism is bounded by the product of individual image cardinalities.

7. **Factorization theorems** (§8): Proofs that surjections have maximal rank (equal to codomain cardinality) and injections have maximal rank (equal to domain cardinality).

---

## 2. Compression Rank

**Definition 2.1** (Compression Rank). Let α, β be types with α finite and β having decidable equality. The *compression rank* of f : α → β is:

$$\text{rank}(f) = |\{f(a) \mid a \in \alpha\}| = |\text{image}(f)|$$

This is a purely combinatorial measure — no probability distribution is required.

**Theorem 2.2** (Left Bottleneck). For f : α → β and g : β → γ with appropriate finiteness conditions:

$$\text{rank}(g \circ f) \leq \text{rank}(f)$$

*Proof sketch.* image(g ∘ f) = g(image(f)), so |image(g ∘ f)| = |g(image(f))| ≤ |image(f)| since the image of any function on a set has cardinality at most the cardinality of the set.

**Theorem 2.3** (Right Bottleneck). Under the same conditions:

$$\text{rank}(g \circ f) \leq \text{rank}(g)$$

*Proof sketch.* image(g ∘ f) ⊆ image(g) since for any a, g(f(a)) ∈ image(g).

**Corollary 2.4** (Two-sided Bottleneck).

$$\text{rank}(g \circ f) \leq \min(\text{rank}(f), \text{rank}(g))$$

**Theorem 2.5** (Identity Rank). rank(id : α → α) = |α|.

---

## 3. Idempotent Stabilization

**Theorem 3.1** (Finite Monoid Idempotent Power). For any element a of a finite monoid M, there exists n > 0 such that a^(2n) = a^n.

*Proof sketch.* By the pigeonhole principle, the sequence a⁰, a¹, a², ... must repeat: ∃ m < j, a^m = a^j. Let k = j - m ≥ 1. Then a^m = a^(m+k), which gives periodicity: ∀ n ≥ m, a^n = a^(n+k). Choose n = mk + k². Then:
- a^(2n) = a^(2mk + 2k²) = a^(mk + k²) (by applying periodicity (m+k) times)
- So a^(2n) = a^n with n = mk + k² > 0.

This theorem is the algebraic foundation of memory stabilization: any finite-state system driven by repeated input eventually reaches a state that is unchanged by further repetition.

---

## 4. Tropical Capacity

**Definition 4.1** (Tropical Capacity). The *tropical capacity* of f : α → β is:

$$v(f) = \log(\text{rank}(f))$$

where log denotes the natural logarithm.

**Theorem 4.2** (Tropical Bottleneck Inequality).

$$v(g \circ f) \leq v(f)$$

*Proof.* Since rank(g ∘ f) ≤ rank(f) (Theorem 2.2) and log is monotone on positive reals, the result follows. The case rank(g ∘ f) = 0 (empty domain) is handled separately.

**Remark 4.3.** The tropical bottleneck inequality v(g ∘ f) ≤ min(v(f), v(g)) is precisely the ultrametric (non-Archimedean) triangle inequality in the tropical semiring (ℝ ∪ {-∞}, max, +). This places the space of compression functions in a tropical metric space.

---

## 5. Information Ordering via Kernel Congruences

**Definition 5.1** (Kernel Setoid). The *kernel* of f : α → β is the setoid on α defined by: x ~ y iff f(x) = f(y).

**Definition 5.2** (Kernel Refinement). We say f *kernel-refines* g (written ker(f) ⊆ ker(g)) if f(x) = f(y) implies g(x) = g(y) for all x, y.

Intuitively, kernel refinement means f makes at least as fine distinctions as g.

**Theorem 5.3** (Information Ordering). If ker(f) ⊆ ker(g), then rank(g) ≤ rank(f).

*Proof sketch.* Construct an injection from image(g) to image(f): for each y ∈ image(g), choose a preimage a with g(a) = y and map to f(a). This is well-defined up to the choice of preimage. It is injective because if f(a) = f(b) (where g(a) = y₁ and g(b) = y₂), then by kernel refinement g(a) = g(b), so y₁ = y₂.

---

## 6. Iteration and Stabilization

**Theorem 6.1** (Monotone Decrease). For any f : α → α on a finite type:

$$\text{rank}(f^{n+1}) \leq \text{rank}(f^n)$$

*Proof.* f^(n+1) = f^n ∘ f, so rank(f^(n+1)) ≤ rank(f) by left bottleneck. But actually f^(n+1) = f ∘ f^n, so rank(f^(n+1)) ≤ rank(f^n) by left bottleneck with inner function f^n.

**Theorem 6.2** (Stabilization). There exists N such that for all n ≥ N:

$$\text{rank}(f^n) = \text{rank}(f^N)$$

*Proof sketch.* The sequence rank(f^n) is non-increasing and takes values in ℕ. By the well-ordering principle, it attains a minimum. The monotonicity then forces equality from that point onward.

**Interpretation.** The stabilization index N represents the "memory formation time" — the number of iterations needed for the system to reach its long-term information-retention regime. After N iterations, the system has settled into its permanent memory: all transient information has been discarded, and what remains will persist indefinitely.

---

## 7. Cascade Products

**Definition 7.1** (Memory System). A *memory system* over alphabet α with state monoid S is a monoid homomorphism φ : FreeMonoid(α) →* S.

**Definition 7.2** (Cascade Product). The cascade product of memory systems M₁ = (α, S, φ₁) and M₂ = (α, T, φ₂) is the memory system M₁ × M₂ = (α, S × T, φ₁ × φ₂).

**Theorem 7.3** (Cascade Product Rank Bound).

$$|\text{image}(\varphi_1 \times \varphi_2)| \leq |\text{image}(\varphi_1)| \cdot |\text{image}(\varphi_2)|$$

*Proof.* image(φ₁ × φ₂) ⊆ image(φ₁) × image(φ₂), so the cardinality bound follows.

**Remark 7.4.** In tropical capacity terms, this becomes: v(M₁ × M₂) ≤ v(M₁) + v(M₂). Information from parallel memory systems is at most additive — there is no synergistic information gain from combining independent channels. This is the algebraic analogue of the classical data processing inequality.

---

## 8. Factorization Theorems

**Theorem 8.1.** If f : α → β is surjective, then rank(f) = |β|.

**Theorem 8.2.** If f : α → β is injective, then rank(f) = |α|.

These extremal results characterize the two boundary cases:
- Surjections achieve maximal compression (every output value is used).
- Injections achieve zero compression (every input is distinguishable).

---

## 9. Algorithms

### 9.1 Computing Compression Rank

```
Algorithm CompressionRank(f, domain):
    outputs ← ∅
    for x in domain:
        outputs ← outputs ∪ {f(x)}
    return |outputs|
```

Time complexity: O(n log n) where n = |domain|, using a hash set.

### 9.2 Computing Stabilization Index

```
Algorithm StabilizationIndex(f, domain):
    current_rank ← CompressionRank(f, domain)
    N ← 1
    g ← f
    while true:
        g ← g ∘ f
        new_rank ← CompressionRank(g, domain)
        if new_rank == current_rank:
            return N
        current_rank ← new_rank
        N ← N + 1
```

Time complexity: O(n² log n) in the worst case, since stabilization occurs within n iterations.

### 9.3 Computing Tropical Capacity Profile

```
Algorithm TropicalProfile(f, domain, max_depth):
    profile ← []
    g ← identity
    for i in 0..max_depth:
        g ← g ∘ f  (or identity for i=0)
        profile.append(log(CompressionRank(g, domain)))
    return profile
```

---

## 10. Discussion

### 10.1 Relationship to Information Theory

The compression rank framework provides a *worst-case* analogue to Shannon's *average-case* information measures. Shannon entropy H(X) measures average information content assuming a probability distribution; compression rank measures the combinatorial capacity without distributional assumptions. The two perspectives are complementary:

- rank(f) = |image(f)| corresponds to the Hartley entropy log₂(|image(f)|) = log₂(rank(f))
- The bottleneck inequality rank(g∘f) ≤ rank(f) corresponds to the data processing inequality I(X;Z) ≤ I(X;Y) for the Markov chain X → Y → Z

### 10.2 Connection to Automata Theory

Any deterministic finite automaton (DFA) with state set Q and input alphabet Σ defines a memory system via the transition monoid: the monoid generated by the transition functions δ(·, a) : Q → Q for each a ∈ Σ. The compression rank of the DFA is the cardinality of this transition monoid.

The Krohn-Rhodes theorem decomposes any finite semigroup into a wreath product of simple groups and aperiodic semigroups. This decomposition, applied to the transition monoid of a memory system, yields a *hierarchical factorization of information loss*: each level of the wreath product represents one layer of irreducible compression.

### 10.3 Tropical Geometry Perspective

The tropical capacity v(f) = log(rank(f)) maps the multiplicative structure of compression (cascade products multiply ranks) to additive structure (tropical capacities add). This is precisely the role of the valuation map in tropical geometry, which transforms algebraic varieties into piecewise-linear objects.

The ultrametric inequality v(g ∘ f) ≤ min(v(f), v(g)) places the space of memory systems in a tropical metric space with tree-like geometry. This suggests that the natural topology on memory systems is non-Archimedean, with implications for clustering, classification, and optimization of memory architectures.

---

## 11. Future Work

1. **Krohn-Rhodes decomposition**: Formalize the wreath product decomposition of memory systems and prove that the compression rank factors accordingly.

2. **Entropy comparison**: Establish precise inequalities relating compression rank to Shannon entropy, Rényi entropy, and min-entropy.

3. **Continuous analogues**: Extend the framework to continuous state spaces using measure-theoretic notions of compression (e.g., metric entropy, covering numbers).

4. **Quantum memory systems**: Investigate whether the framework extends to quantum channels, where compression rank generalizes to the rank of the Choi matrix.

5. **Algorithmic applications**: Develop practical algorithms for computing optimal compression hierarchies using the kernel congruence lattice.

---

## References

1. Krohn, K., Rhodes, J. (1965). "Algebraic theory of machines. I. Prime decomposition theorem for finite semigroups and machines." *Transactions of the American Mathematical Society*, 116, 450-464.

2. Eilenberg, S. (1976). *Automata, Languages, and Machines*, Vol. B. Academic Press.

3. Maclagan, D., Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.

4. Cover, T.M., Thomas, J.A. (2006). *Elements of Information Theory*. Wiley.

5. Pin, J.-É. (1986). *Varieties of Formal Languages*. Plenum.
