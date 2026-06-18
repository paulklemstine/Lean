# Curriculum Complexity Theory: Formal Foundations of Staged Mathematical Discovery

## Abstract

We introduce **curriculum complexity theory**, a formal framework for studying the sequential structure of mathematical knowledge acquisition. Given a finite acyclic dependency system — a finite type equipped with a well-founded dependency relation — we define the *dependency level* of each theorem as the length of the longest dependency chain ending at it, and the *stage knowledge* at step $n$ as the set of theorems whose dependencies are all known by step $n-1$. We prove five main results: (1) every finite acyclic system admits a curriculum ranking (topological ordering); (2) stage knowledge is characterized exactly by the dependency level function; (3) knowledge strictly increases at each stage where new-level theorems exist; (4) knowledge saturates to the full theory at a stage determined by the maximum level; and (5) the minimum number of sequential stages needed to reach any set of frontier theorems equals the maximum dependency level across the frontier. All results are formally verified in Lean 4 with the Mathlib library, yielding machine-checked proofs with no unresolved obligations. We provide algorithms with optimal complexity for computing all invariants, and demonstrate applications to build systems, course planning, and research scheduling.

**Keywords:** curriculum complexity, dependency DAG, topological sorting, well-founded recursion, staged knowledge, proof depth, formal verification

---

## 1. Introduction

### 1.1 Motivation

Mathematical knowledge has an inherent sequential structure: certain theorems must be established before others become provable. This dependency structure constrains the order in which a learner, a research community, or an automated theorem prover can acquire results. Despite the fundamental nature of this constraint, no rigorous theory has characterized the quantitative relationships between dependency structure and acquisition complexity.

We address this gap by formalizing **dependency systems** — finite types with acyclic dependency relations — and studying their **curriculum complexity**: the minimum number of sequential "research cycles" needed to derive target theorems, where each cycle may only use results established in previous cycles.

### 1.2 Contributions

1. **Formal definitions** of dependency systems, dependency level, stage knowledge, and curricula, suitable for machine verification.
2. **Curriculum Existence Theorem**: every finite acyclic system admits an injective ranking function respecting all dependencies.
3. **Level-Stage Equivalence**: a theorem belongs to stage $n$ if and only if its dependency level is at most $n$.
4. **Bootstrapping Strictness**: strict knowledge growth at every stage with new-level content.
5. **Frontier Optimality**: exact characterization of the minimum stages for frontier coverage.
6. **Complete formal verification** in Lean 4 with Mathlib, with zero unresolved `sorry` obligations.
7. **Algorithms** with optimal $O(|V| + |E|)$ complexity for all computations.

### 1.3 Related Work

**Topological sorting** (Kahn 1962, Tarjan 1976) provides algorithms for computing valid linear orderings of DAGs. Our work extends this by proving optimality results about staged acquisition.

**Proof complexity** (Cook & Reckhow 1979, Krajíček 1995) studies the lengths and depths of formal proofs in specific proof systems. Our framework operates at a different level: we study dependency relations between theorems, not the internal structure of individual proofs.

**Curriculum learning** (Bengio et al. 2009, Soviany et al. 2022) uses ordered training examples to improve machine learning. Our theory provides the first rigorous mathematical foundation for understanding why curriculum order matters.

**Order theory and graded posets** (Stanley 1997, Birkhoff 1967) studies ranked partially ordered sets. Our dependency level function is the rank function of the dependency poset, and our stage knowledge is the canonical rank filtration.

---

## 2. Definitions and Notation

### 2.1 Dependency Systems

**Definition 2.1.** A *dependency system* is a triple $(T, \text{dep}, \text{wf})$ where:
- $T$ is a finite type with decidable equality,
- $\text{dep} : T \to T \to \text{Prop}$ is a decidable binary relation ($\text{dep}(a, b)$ means "$a$ depends on $b$"),
- $\text{wf}$ is a proof that $\text{flip}(\text{dep})$ is well-founded.

Well-foundedness of $\text{flip}(\text{dep})$ ensures that following dependency chains downward always terminates — equivalently, the dependency relation is acyclic.

**Lean 4 formalization:**
```
structure DepSystem (T : Type*) [Fintype T] [DecidableEq T] where
  dep : T → T → Prop
  decDep : DecidableRel dep
  wf : WellFounded (flip dep)
```

### 2.2 Dependency Level

**Definition 2.2.** The *dependency level* of a theorem $t$, denoted $\text{depLevel}(t)$, is defined by well-founded recursion:

$$\text{depLevel}(t) = \sup_{s : T} \begin{cases} \text{depLevel}(s) + 1 & \text{if } \text{dep}(t, s) \\ 0 & \text{otherwise} \end{cases}$$

where the supremum is over $\text{Finset.univ}$ (the finite set of all elements of $T$), using the natural number ordering with $\bot = 0$.

**Lean 4 formalization:**
```
noncomputable def depLevel (S : DepSystem T) : T → ℕ :=
  S.wf.fix fun t ih =>
    Finset.univ.sup (fun s => if h : S.dep t s then ih s h + 1 else 0)
```

The well-foundedness of `flip dep` guarantees termination of the recursion.

### 2.3 Stage Knowledge

**Definition 2.3.** The *stage knowledge* at stage $n$ is defined inductively:

$$\text{stageKnowledge}(0) = \{t \mid \forall s,\, \neg\text{dep}(t, s)\}$$
$$\text{stageKnowledge}(n+1) = \{t \mid \forall s,\, \text{dep}(t, s) \Rightarrow s \in \text{stageKnowledge}(n)\}$$

Stage 0 contains exactly the dependency-free theorems. Each subsequent stage adds theorems whose dependencies were all known at the previous stage.

### 2.4 Curriculum Ranking

**Definition 2.4.** An *injective curriculum ranking* for a dependency relation $\text{dep}$ is a function $\text{rank} : T \to \mathbb{N}$ such that:
1. $\text{dep}(a, b) \Rightarrow \text{rank}(b) < \text{rank}(a)$ (dependencies are ranked lower),
2. $\text{rank}$ is injective,
3. $\text{rank}(a) < |T|$ for all $a$.

### 2.5 Frontier Depth

**Definition 2.5.** The *frontier depth* of a set $F \subseteq T$ is $\sup_{t \in F}(\text{depLevel}(t) + 1)$.

The *maximum level* of the system is $\sup_{t \in T}\text{depLevel}(t)$.

---

## 3. Main Results

### 3.1 Curriculum Existence Theorem

**Theorem 3.1** (Curriculum Existence). *For every finite acyclic dependency system $(T, \text{dep})$, there exists an injective curriculum ranking.*

*Proof sketch.* The dependency level function $\text{depLevel}$ already satisfies the ordering constraint: if $\text{dep}(a, b)$ then $\text{depLevel}(b) < \text{depLevel}(a)$ (Lemma 3.2). However, $\text{depLevel}$ may not be injective (multiple theorems can share the same level).

To obtain injectivity, we use the following construction:
1. Choose any injection $\text{order} : T \hookrightarrow \mathbb{N}$ (exists by countability of finite types).
2. Define $f(t) = \text{depLevel}(t) \cdot (M + 1) + \text{order}(t)$, where $M = \sup_{t} \text{order}(t)$.
3. $f$ is injective: if $f(a) = f(b)$, then $\text{depLevel}(a) = \text{depLevel}(b)$ (by divisibility) and $\text{order}(a) = \text{order}(b)$ (by remainder), hence $a = b$.
4. $f$ respects dependencies: if $\text{dep}(a, b)$, then $\text{depLevel}(b) < \text{depLevel}(a)$, so $f(b) < f(a)$.

Finally, define $\text{rank}(t) = |\{s \mid f(s) < f(t)\}|$. This is injective, bounded by $|T|$, and respects dependencies. ∎

**Lemma 3.2** (Strict Monotonicity). *If $\text{dep}(t, s)$, then $\text{depLevel}(s) < \text{depLevel}(t)$.*

*Proof sketch.* By the unfolding equation, $\text{depLevel}(t) \geq \text{depLevel}(s) + 1$, since the supremum includes the term corresponding to $s$. ∎

**Lemma 3.3** (Cardinal Bound). *For all $t$, $\text{depLevel}(t) < |T|$.*

*Proof sketch.* By induction, construct an injective chain $f : \text{Fin}(\text{depLevel}(t) + 1) \hookrightarrow T$ witnessing the longest dependency path. The chain has $\text{depLevel}(t) + 1$ distinct elements, so $\text{depLevel}(t) + 1 \leq |T|$. ∎

### 3.2 Level-Stage Equivalence

**Theorem 3.4** (Level-Stage Equivalence). *For all $t \in T$ and $n \in \mathbb{N}$:*
$$t \in \text{stageKnowledge}(n) \iff \text{depLevel}(t) \leq n$$

*Proof sketch.* By strong induction on $n$.

**Base case** ($n = 0$): $t \in \text{stageKnowledge}(0)$ iff $t$ has no dependencies iff $\text{depLevel}(t) = 0$ iff $\text{depLevel}(t) \leq 0$.

**Inductive step** ($n \to n+1$): $t \in \text{stageKnowledge}(n+1)$ iff for all $s$ with $\text{dep}(t, s)$, $s \in \text{stageKnowledge}(n)$. By IH, this is iff for all such $s$, $\text{depLevel}(s) \leq n$. By the unfolding equation, this is equivalent to $\text{depLevel}(t) \leq n + 1$. ∎

### 3.3 Monotonicity and Strict Growth

**Theorem 3.5** (Monotonicity). *For all $n$, $\text{stageKnowledge}(n) \subseteq \text{stageKnowledge}(n+1)$.*

*Proof.* Immediate from Theorem 3.4: if $\text{depLevel}(t) \leq n$ then $\text{depLevel}(t) \leq n + 1$. ∎

**Theorem 3.6** (Bootstrapping Strictness). *If there exists $t$ with $\text{depLevel}(t) = n + 1$, then $\text{stageKnowledge}(n) \subsetneq \text{stageKnowledge}(n+1)$.*

*Proof.* By Theorem 3.5, $\subseteq$ holds. For strict containment, the witness $t$ satisfies $t \in \text{stageKnowledge}(n+1)$ (since $\text{depLevel}(t) = n + 1 \leq n + 1$) but $t \notin \text{stageKnowledge}(n)$ (since $\text{depLevel}(t) = n + 1 > n$). ∎

### 3.4 Saturation

**Theorem 3.7** (Saturation). *$\text{stageKnowledge}(\text{maxLevel}) = T$, where $\text{maxLevel} = \sup_t \text{depLevel}(t)$.*

*Proof.* For any $t$, $\text{depLevel}(t) \leq \text{maxLevel}$, so $t \in \text{stageKnowledge}(\text{maxLevel})$ by Theorem 3.4. ∎

**Theorem 3.8** (Eventual Universe). *There exists $N$ such that for all $n \geq N$, $\text{stageKnowledge}(n) = T$.*

*Proof.* Take $N = |T|$. For any $t$ and $n \geq |T|$, $\text{depLevel}(t) < |T| \leq n$. ∎

### 3.5 Frontier Optimality

**Theorem 3.9** (Frontier Optimality). *For any frontier $F \subseteq T$ and any $n \in \mathbb{N}$:*
$$(\forall t \in F,\, t \in \text{stageKnowledge}(n)) \iff \sup_{t \in F} \text{depLevel}(t) \leq n$$

*Proof.* By Theorem 3.4 and the characterization of $\text{Finset.sup}$:
$$\forall t \in F,\, \text{depLevel}(t) \leq n \iff F.\text{sup}(\text{depLevel}) \leq n$$
This is the standard `Finset.sup_le_iff` equivalence. ∎

---

## 4. Algorithms

### 4.1 Computing Dependency Levels

**Algorithm: DepLevel**

```
Input: Dependency system (T, dep) with n = |T| nodes, m = |edges|
Output: depLevel(t) for all t ∈ T

1. Compute in-degrees: for each t, count |{s : dep(t, s)}|
2. Initialize queue Q with all t having in-degree 0; set level[t] = 0
3. While Q is non-empty:
   a. Remove t from Q
   b. For each s with dep(s, t):  // s depends on t
      c. level[s] = max(level[s], level[t] + 1)
      d. Decrement in-degree of s
      e. If in-degree of s reaches 0, add s to Q
4. Return level[]
```

**Complexity:** $O(n + m)$ time, $O(n)$ space.

**Correctness:** This is a modified topological sort that computes longest-path distances from sources. By Theorem 3.4, the computed levels exactly equal $\text{depLevel}$.

### 4.2 Computing Stage Knowledge

**Algorithm: StageKnowledge**

```
Input: Dependency system (T, dep), stage number n
Output: stageKnowledge(n)

1. Compute depLevel(t) for all t (Algorithm 4.1)
2. Return {t : depLevel(t) ≤ n}
```

**Complexity:** $O(n + m)$ time.

### 4.3 Generating Optimal Curricula

**Algorithm: OptimalCurriculum**

```
Input: Dependency system (T, dep)
Output: Injective ranking function rank : T → ℕ

1. Compute depLevel(t) for all t
2. Sort T by (depLevel(t), arbitrary tiebreaker)
3. Assign rank(t) = position in sorted order (0-indexed)
```

**Complexity:** $O(n \log n + m)$ time.

### 4.4 Parallel Schedule Generation

**Algorithm: ParallelSchedule**

```
Input: Dependency system (T, dep)
Output: Sequence of sets (R₀, R₁, ..., R_L) where L = maxLevel

1. Compute depLevel(t) for all t
2. For k = 0, ..., L:
   Rₖ = {t : depLevel(t) = k}
3. Return (R₀, ..., R_L)
```

**Complexity:** $O(n + m)$ time. The schedule has $L + 1$ rounds and is provably optimal.

---

## 5. Worked Examples

### 5.1 Three-Theorem Chain

Consider theorems $A, B, C$ with $\text{dep}(B, A)$ and $\text{dep}(C, B)$.

| Theorem | depLevel | stageKnowledge membership |
|---------|----------|--------------------------|
| A       | 0        | Stage 0+                 |
| B       | 1        | Stage 1+                 |
| C       | 2        | Stage 2+                 |

This was formally verified in Lean as the `threeTheorems` example.

### 5.2 Diamond Dependency

Theorems $A, B, C, D$ with $B, C$ depending on $A$, and $D$ depending on both $B, C$.

| Round | Theorems    | Width |
|-------|-------------|-------|
| 0     | {A}         | 1     |
| 1     | {B, C}      | 2     |
| 2     | {D}         | 1     |

Maximum width = 2, depth = 2. Sequential: 4 steps. Parallel: 3 rounds. Speedup: 1.33×.

### 5.3 Linear Algebra Curriculum

A 10-theorem fragment of linear algebra:

| Level | Theorems |
|-------|----------|
| 0     | Vector Space |
| 1     | Linear Map, Dimension |
| 2     | Kernel, Image, Eigenvalue |
| 3     | Rank-Nullity, Characteristic Polynomial |
| 4     | Cayley-Hamilton |
| 5     | Jordan Normal Form |

Critical path: Vector Space → Dimension → Eigenvalue → Char. Poly → Cayley-Hamilton → Jordan Form.
Minimum research cycles for Jordan Form: 6.

---

## 6. Formal Verification

All theorems in this paper have been formally verified in Lean 4 (version 4.28.0) using the Mathlib library. The formalization consists of approximately 370 lines of Lean code in a single file (`Speculative/CurriculumTheory.lean`) containing:

- 5 definitions (DepSystem, depLevel, stageKnowledge, IsCurriculum, frontierDepth, maxLevel)
- 13 theorems, all proved without `sorry`
- 1 concrete example (three-theorem chain with computed levels)

The formalization uses well-founded recursion for `depLevel`, induction on natural numbers for stage knowledge properties, and Finset operations for suprema and universal quantification. All proofs use only the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`.

---

## 7. Applications

### 7.1 Build Systems

A software build system with $n$ compilation units and $m$ dependency edges has parallel build time $\Theta(L + 1)$ where $L$ is the longest dependency chain. Our framework provides a certified lower bound: no build scheduler can achieve fewer than $L + 1$ sequential stages, regardless of the number of available processors.

### 7.2 Course Planning

University course prerequisite graphs have typical depths of 4–8 semesters. The framework computes the minimum number of semesters to complete any set of target courses, identifies bottleneck prerequisites, and generates all valid course orderings.

### 7.3 Research Scheduling

Given a dependency graph of open problems and intermediate results, the framework computes:
- The minimum number of research cycles to reach any target
- The optimal allocation of researchers to independent problems at each stage  
- The critical path: the sequence of results whose completion determines the minimum timeline

---

## 8. Discussion

### 8.1 Connections to Existing Theory

**Krull height.** In commutative algebra, the Krull height of a prime ideal $\mathfrak{p}$ in a ring $R$ is the supremum of lengths of chains of prime ideals descending from $\mathfrak{p}$. Our dependency level is the analogous invariant for proof dependencies. The parallel is structural: both measure "how deep" an object sits in a hierarchy defined by containment/dependency chains.

**Circuit depth.** In computational complexity, circuit depth measures the minimum number of sequential computational layers in a Boolean circuit. Our curriculum depth is the proof-theoretic analogue: the minimum number of sequential proof layers needed to establish a theorem.

**Operadic depth.** In algebra, the depth of an operadic composition measures the nesting level of operations. Our dependency level captures a similar phenomenon: the compositional complexity of proof techniques.

### 8.2 Limitations

The current framework assumes:
1. **Finiteness**: the theorem set $T$ must be finite. Extension to infinite sets requires ordinal-valued levels.
2. **Binary dependencies**: a theorem either depends on another or doesn't. A richer framework might incorporate dependency *strength* or *probability*.
3. **Static dependencies**: the dependency graph is fixed. In practice, new proof techniques can shortcut previously long dependency chains.

### 8.3 Open Questions

1. What is the distribution of dependency depths across large proof libraries (e.g., Mathlib's 150,000+ theorems)?
2. Can dependency depth predict the difficulty of formalizing a mathematical theory?
3. Is there a meaningful notion of "curriculum entropy" that measures the diversity of valid learning orders?

---

## 9. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps, including:
1. Extension to infinite curricula via ordinal-valued ranks
2. Categorical structure of theory morphisms
3. Parallel complexity and antichain decompositions
4. Curriculum entropy and information-theoretic bounds
5. Automated curriculum extraction from formal proof libraries

---

## 10. Conclusion

We have established the mathematical foundations of curriculum complexity theory: a formal framework for quantifying the sequential structure of mathematical knowledge. The central result — that dependency depth exactly determines the minimum number of sequential research cycles — provides both a lower bound on discovery timelines and a constructive upper bound via level decomposition. The complete formal verification in Lean 4 ensures the correctness of all results to the highest standard of mathematical rigor.

---

## References

1. Bengio, Y., Louradour, J., Collobert, R., & Weston, J. (2009). Curriculum learning. *ICML*.
2. Birkhoff, G. (1967). *Lattice Theory*. AMS.
3. Cook, S. A., & Reckhow, R. A. (1979). The relative efficiency of propositional proof systems. *Journal of Symbolic Logic*, 44(1), 36–50.
4. Kahn, A. B. (1962). Topological sorting of large networks. *Communications of the ACM*, 5(11), 558–562.
5. Krajíček, J. (1995). *Bounded Arithmetic, Propositional Logic, and Complexity Theory*. Cambridge University Press.
6. Soviany, P., et al. (2022). Curriculum learning: A survey. *International Journal of Computer Vision*, 130, 1526–1565.
7. Stanley, R. P. (1997). *Enumerative Combinatorics*, Vol. 1. Cambridge University Press.
8. Tarjan, R. E. (1976). Edge-disjoint spanning trees and depth-first search. *Acta Informatica*, 6, 171–185.
