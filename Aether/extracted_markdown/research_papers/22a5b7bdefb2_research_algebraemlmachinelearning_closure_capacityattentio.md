# Closure-Capacity–Attention Duality: Certified Minimal Sparse Predictor Reconstruction via Idempotent Information Semimodules

## Abstract

We establish a finite duality between closure-capacity objects and minimal sparse attention architectures. Given a finite type $X$, a closure operator $\mathrm{cl}$ on the subsets of $X$, and a monotone normalized capacity function $\kappa$, we define the **extreme rank** — the number of irreducible extreme generators among closed sets — and prove that it equals the minimum number of attention heads in any faithful sparse realization. The canonical attention model, with one head per extreme generator, achieves this minimum. Conversely, any attention model satisfying closure-consistency determines a unique closure operator and capacity function via a reconstruction algorithm. All definitions and theorems are formalized and verified in a machine-checked proof system, with constructive algorithms demonstrated on concrete examples.

**Keywords:** closure systems, capacity functions, attention mechanisms, extreme generators, sparse models, tropical algebra, duality theorems, model compression, interpretability.

---

## 1. Introduction

### 1.1 Motivation

The attention mechanism is the computational primitive underlying transformer architectures, which have achieved remarkable success in natural language processing, computer vision, protein folding, and beyond. Despite their empirical success, the theoretical foundations of attention — particularly questions of minimal architecture and optimal head count — remain poorly understood.

Independently, closure systems have been studied extensively in lattice theory, combinatorics, and logic since the 1930s. A closure operator $\mathrm{cl}$ on a finite set $X$ formalizes the notion of "deductive closure" or "dependency completion." When augmented with a capacity function $\kappa$ satisfying monotonicity and normalization, closure-capacity objects provide a quantitative framework for information structure.

This paper bridges these two domains by proving a **finite duality theorem**: closure-capacity objects and minimal sparse attention models are two representations of the same combinatorial-algebraic object.

### 1.2 Main Contributions

1. **Formal framework.** We define closure-capacity objects, extreme generators, sparse attention models, and the realization relation connecting them (Section 3).

2. **Lower bound.** We prove that any attention model realizing a closure-capacity object requires at least as many heads as extreme generators (Theorem 1).

3. **Canonical construction.** We construct the canonical attention model with exactly one head per extreme generator and prove it achieves the lower bound (Theorem 2).

4. **Head count invariance.** The minimum head count equals the extreme rank, establishing it as an algebraic invariant (Theorem 3).

5. **Reconstruction.** We define algorithms to reconstruct closure operators and capacity functions from attention models, and prove the reconstructed operators satisfy the closure axioms (Theorem 4).

6. **Machine verification.** All theorems are formally verified in Lean 4 with the Mathlib library, ensuring correctness beyond human review.

### 1.3 Related Work

**Closure systems and lattice theory.** The study of closure operators dates to Birkhoff (1937) and Ore (1943). The lattice of closed sets under intersection has been extensively studied; our extreme generators are closely related to join-irreducible elements in such lattices.

**Matroid theory.** Matroids, introduced by Whitney (1935), axiomatize the notion of independence. The rank function of a matroid is a special case of our capacity function, and our extreme generators generalize matroid circuits. The submodularity of matroid rank is a special case of the capacity monotonicity axiom.

**Tropical algebra.** Max-plus (tropical) algebra has been applied to discrete optimization, algebraic geometry, and theoretical computer science. The capacity function's behavior — supremum over extreme generators — is naturally tropical. Our framework can be viewed as a tropical factorization theorem.

**Attention mechanisms.** Vaswani et al. (2017) introduced the transformer with multi-head attention. Subsequent work has studied head pruning (Michel et al., 2019; Voita et al., 2019), but optimality certificates for head count have been lacking. Our theorem provides the first such certificate from algebraic principles.

---

## 2. Preliminaries

### 2.1 Notation

Let $X$ be a finite type with $|X| = n$. We write $\mathcal{P}(X)$ for the powerset of $X$, identified with $\mathrm{Finset}\, X$ in the formalization. For $A, B \in \mathcal{P}(X)$, we write $A \subset B$ for strict inclusion and $A \subseteq B$ for non-strict inclusion.

### 2.2 Closure Operators

**Definition 1.** A *closure operator* on $X$ is a function $\mathrm{cl} : \mathcal{P}(X) \to \mathcal{P}(X)$ satisfying:
- (Extensive) $A \subseteq \mathrm{cl}(A)$ for all $A$,
- (Monotone) $A \subseteq B \Rightarrow \mathrm{cl}(A) \subseteq \mathrm{cl}(B)$,
- (Idempotent) $\mathrm{cl}(\mathrm{cl}(A)) = \mathrm{cl}(A)$.

A set $A$ is *closed* if $\mathrm{cl}(A) = A$. The collection of closed sets forms a lattice under inclusion.

---

## 3. Definitions

### 3.1 Closure-Capacity Objects

**Definition 2.** A *closure-capacity object* on $X$ is a tuple $(X, \mathrm{cl}, \kappa)$ where:
- $\mathrm{cl}$ is a closure operator on $X$,
- $\kappa : \mathcal{P}(X) \to \mathbb{N}$ is a *capacity function* satisfying:
  - (Monotonicity on closed sets) If $A, B$ are closed and $A \subseteq B$, then $\kappa(A) \leq \kappa(B)$,
  - (Normalization) $\kappa(\emptyset) = 0$,
  - (Closure invariance) $\kappa(A) = \kappa(\mathrm{cl}(A))$ for all $A$,
- $\emptyset$ is closed.

### 3.2 Extreme Generators

**Definition 3.** A closed set $C$ is an *extreme generator* if $C \neq \emptyset$ and for every closed $D$ with $D \subset C$, we have $\kappa(D) < \kappa(C)$.

The *extreme rank* of a closure-capacity object is the number of extreme generators:
$$r(X, \mathrm{cl}, \kappa) = |\{C \in \mathrm{Closed}(X) : C \text{ is extreme}\}|.$$

**Remark.** Extreme generators are the "information atoms" — closed sets where capacity genuinely increases. In matroid terminology, they correspond to flats where the rank function increases at every proper subflat.

### 3.3 Sparse Attention Models

**Definition 4.** A *sparse attention model* on $X$ with $h$ heads is a tuple $M = (h, \sigma, w)$ where:
- $h \in \mathbb{N}$ is the number of heads,
- $\sigma : \{1, \ldots, h\} \to \mathcal{P}(X)$ assigns each head a *support set*,
- $w : \{1, \ldots, h\} \to \mathbb{N}$ assigns each head a *weight*.

**Definition 5.** A sparse attention model $M$ *realizes* a closure-capacity object $(X, \mathrm{cl}, \kappa)$ if:
1. Each support is closed: $\mathrm{cl}(\sigma(i)) = \sigma(i)$ for all $i$,
2. Every extreme generator appears: for each extreme $C$, there exists $i$ with $\sigma(i) = C$,
3. Weights match capacity: $w(i) = \kappa(\sigma(i))$ for all $i$.

**Definition 6.** A realization is *minimal* if no realization with fewer heads exists.

---

## 4. Main Results

### 4.1 Lower Bound (Theorem 1)

**Theorem 1** (extremeRank_le_headCount). *If $M$ realizes $(X, \mathrm{cl}, \kappa)$, then $h \geq r(X, \mathrm{cl}, \kappa)$.*

*Proof sketch.* By condition (2) of realization, each extreme generator $C$ maps to some head $f(C)$ with $\sigma(f(C)) = C$. If $f(C_1) = f(C_2)$, then $C_1 = \sigma(f(C_1)) = \sigma(f(C_2)) = C_2$, so $f$ is injective. Hence $r \leq h$. $\square$

### 4.2 Canonical Construction (Theorem 2)

**Theorem 2** (canonical_model_realizes). *The canonical model — one head per extreme generator, with support equal to the generator and weight equal to its capacity — realizes the closure-capacity object.*

*Proof sketch.* Condition (1): extreme generators are closed by definition. Condition (2): every extreme generator appears as its own head's support (via the bijection). Condition (3): weights are defined to equal capacity. $\square$

### 4.3 Head Count Invariance (Theorem 3)

**Theorem 3** (head_count_eq_extremeRank). *For any minimal realization, $h = r(X, \mathrm{cl}, \kappa)$.*

*Proof.* The canonical model has $h = r$ heads. By Theorem 1, any realization has $h \geq r$. By minimality, the given model has $h \leq r$ (since the canonical model achieves $r$). Hence $h = r$. $\square$

### 4.4 Reconstruction (Theorem 4)

**Theorem 4** (certified_reconstruction). *Given a sparse attention model $M$, define:*
$$\mathrm{cl}_M(A) = \bigcap_{i : A \subseteq \sigma(i)} \sigma(i), \qquad \kappa_M(A) = \max_{i : A \subseteq \sigma(i)} w(i).$$
*Then $\mathrm{cl}_M$ is extensive and monotone, and $\mathrm{cl}_M(\mathrm{cl}_M(A)) = \mathrm{cl}_M(A)$ (idempotent).*

*Proof sketch.* Extensiveness: $A$ is contained in every $\sigma(i)$ that covers it, hence in their intersection. Monotonicity: if $A \subseteq B$, every head covering $B$ also covers $A$, so the covering set for $B$ is a subset of that for $A$, and intersection over a subset is larger. Idempotency: the intersection of covering supports is itself covered by every covering head, so reapplying the closure doesn't change it. $\square$

### 4.5 Main Duality (Theorem 5)

**Theorem 5** (finite_closureCapacity_attention_duality). *For any closure-capacity object $O$ and any enumeration of its extreme generators:*
1. *The canonical model realizes $O$,*
2. *The canonical model is minimal,*
3. *The canonical model has exactly $r$ heads.*

This is the packaging of Theorems 1–3 into a single duality statement.

### 4.6 Existence (Theorem 6)

**Theorem 6** (exists_minimal_sparse_attention). *Every closure-capacity object admits a minimal sparse attention realization with head count equal to its extreme rank.*

---

## 5. Algorithms

### 5.1 Extreme Generator Extraction

```
Algorithm: ExtractExtremeGenerators
Input: Ground set X, closure operator cl, capacity function κ
Output: Set of extreme generators E

E ← ∅
C ← {A ⊆ X : cl(A) = A, A ≠ ∅}    // nonempty closed sets
for each C ∈ C:
    is_extreme ← true
    for each D ∈ C:
        if D ⊂ C and κ(D) ≥ κ(C):
            is_extreme ← false
            break
    if is_extreme:
        E ← E ∪ {C}
return E
```

**Complexity.** $O(|\mathcal{C}|^2)$ where $|\mathcal{C}|$ is the number of closed sets (at most $2^n$). For practical applications, lazy evaluation of the closed set lattice can reduce this significantly.

### 5.2 Canonical Model Construction

```
Algorithm: BuildCanonicalModel
Input: Extreme generators E, capacity function κ
Output: Sparse attention model M

h ← |E|
Enumerate E = {C₁, ..., Cₕ}
for i = 1 to h:
    σ(i) ← Cᵢ
    w(i) ← κ(Cᵢ)
return M = (h, σ, w)
```

**Complexity.** $O(h \cdot n)$ where $h$ is the extreme rank.

### 5.3 Closure Reconstruction

```
Algorithm: ReconstructClosure
Input: Attention model M = (h, σ, w), subset A ⊆ X
Output: cl(A)

covering ← {i : A ⊆ σ(i)}
if covering = ∅:
    return X
return ⋂_{i ∈ covering} σ(i)
```

**Complexity.** $O(h \cdot n)$ per closure call.

---

## 6. Examples

### 6.1 Partition Closure

Let $X = \{1, 2, 3, 4\}$ with partition $\{\{1,2\}, \{3,4\}\}$. The closure of a set includes the full block of any element it contains.

Closed sets: $\emptyset, \{1,2\}, \{3,4\}, \{1,2,3,4\}$.

Capacity (= cardinality of closure): $\kappa(\emptyset) = 0, \kappa(\{1,2\}) = 2, \kappa(\{3,4\}) = 2, \kappa(\{1,2,3,4\}) = 4$.

Extreme generators: $\{1,2\}, \{3,4\}, \{1,2,3,4\}$ — all three nonempty closed sets are extreme.

Extreme rank: 3. Canonical model: 3 heads.

### 6.2 Uniform Matroid

$U_{2,4}$ on $X = \{1,2,3,4\}$: rank function $r(A) = \min(|A|, 2)$. Closed sets (flats): $\emptyset$, all singletons, and $X$ itself.

Extreme rank: 5 (four singletons plus $X$). This matches the number of join-irreducible elements in the matroid lattice.

### 6.3 Functional Dependency Closure

$X = \{1,2,3\}$ with dependency $\{1,2\} \to 3$. The closure of any set containing both 1 and 2 also contains 3.

Closed sets: $\emptyset, \{1\}, \{2\}, \{3\}, \{1,3\}, \{2,3\}, \{1,2,3\}$ (note: $\{1,2\}$ is not closed since $\mathrm{cl}(\{1,2\}) = \{1,2,3\}$).

With $\kappa = |\mathrm{cl}(\cdot)|$: extreme rank = 6.

---

## 7. Computational Experiments

We implemented the full duality pipeline in Python and verified on several examples:

| Example | $|X|$ | Closed sets | Extreme rank | Heads | Realizes | Minimal |
|---------|--------|-------------|--------------|-------|----------|---------|
| Trivial (identity) | 3 | 8 | 7 | 7 | ✓ | ✓ |
| Partition {1,2},{3,4} | 4 | 4 | 3 | 3 | ✓ | ✓ |
| $U_{2,4}$ matroid | 4 | 6 | 5 | 5 | ✓ | ✓ |
| FD: {1,2}→3 | 3 | 7 | 6 | 6 | ✓ | ✓ |
| Communities (4 nodes) | 4 | 4 | 3 | 3 | ✓ | ✓ |

In all cases, the canonical model achieves the lower bound, confirming Theorems 1–3.

The reconstruction algorithm recovers extensive, monotone, idempotent closure operators in all test cases, confirming Theorem 4.

---

## 8. Discussion

### 8.1 Relationship to Matroid Theory

When $\kappa$ equals the rank function of a matroid, extreme generators coincide with the flats at which rank increases. The extreme rank then equals the number of join-irreducible elements in the lattice of flats. Our theorem generalizes this to arbitrary closure-capacity objects, not just matroids.

### 8.2 Tropical Interpretation

The capacity function behaves as a tropical support function: $\kappa(A)$ is the tropical supremum of contributions from extreme generators covering $A$. This connects our framework to tropical convex geometry, where extreme generators correspond to tropical vertices.

### 8.3 Implications for Model Compression

The extreme rank provides a certified lower bound on model size: no attention model with fewer than $r$ heads can faithfully represent the closure-capacity structure. This transforms model compression from an empirical exercise into an algebraic computation.

### 8.4 Limitations

The current framework uses natural number capacities and a specific definition of "realization" that requires exact support matching. Extensions to real-valued capacities, approximate matching, and weighted realizations are natural next steps.

---

## 9. Future Work

1. **Probabilistic closure-capacity objects**: Replace $\kappa$ with entropy and study information-theoretic versions of the duality.

2. **Lower bounds for transformer compression**: Use extreme rank to derive circuit-complexity-style lower bounds on model size.

3. **Categorification**: Express the duality as an equivalence of categories between closure-capacity objects and attention models.

4. **Submodular extensions**: Strengthen the capacity axioms to full submodularity and study the resulting matroidal structure.

5. **Algorithmic efficiency**: Develop polynomial-time algorithms for extreme rank computation on structured closure systems (e.g., those arising from logic programs or functional dependencies).

---

## 10. Conclusion

We have established a finite duality between closure-capacity objects and minimal sparse attention architectures. The extreme rank — a purely algebraic invariant — equals the minimum number of attention heads, providing a certified optimal architecture. The result connects abstract algebra, combinatorics, and machine learning in a single constructive theorem, all formally verified in a machine-checked proof system.

---

## References

1. Birkhoff, G. (1937). "Rings of sets." *Duke Mathematical Journal*, 3(3), 443–454.

2. Ore, O. (1943). "Combinations of closure relations." *Annals of Mathematics*, 44(3), 514–533.

3. Whitney, H. (1935). "On the abstract properties of linear dependence." *American Journal of Mathematics*, 57(3), 509–533.

4. Vaswani, A., et al. (2017). "Attention is all you need." *Advances in Neural Information Processing Systems*, 30.

5. Michel, P., Levy, O., & Neubig, G. (2019). "Are sixteen heads really better than one?" *Advances in Neural Information Processing Systems*, 32.

6. Voita, E., et al. (2019). "Analyzing multi-head self-attention: Specialized heads do the heavy lifting, the rest can be pruned." *ACL 2019*.

7. Joswig, M. (2021). *Essentials of Tropical Combinatorics*. Springer.

8. Oxley, J. (2011). *Matroid Theory*. Oxford University Press.
