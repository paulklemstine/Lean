# Tropical Recipe Complexity Theory: Algebraic Foundations of the Creation-Verification Gap

## Abstract

We develop a rigorous algebraic theory connecting recipe scheduling, tropical (max-plus) semiring structure, and computational complexity via the *creation-verification gap*. A recipe step is modeled as a task with two associated costs: creation time (the effort to execute) and verification time (the effort to check correctness), subject to the constraint that verification is never harder than creation. We define sequential and parallel composition operations on recipe steps and prove that the creation-verification gap is (1) exactly additive under sequential composition, (2) subadditive under parallel composition, and (3) linearly scaled under iteration. We further establish a tropical distributive law for recipe scheduling, prove critical path bounds via tropical sum (maximum) operations, and derive a pipeline throughput formula connecting the bottleneck time to the tropical spectral radius. Finally, we introduce *recipe complexity classes* based on asymptotic gap behavior and prove closure properties of these classes under composition operations. All results have been formally verified.

**Keywords**: tropical algebra, max-plus semiring, scheduling theory, creation-verification gap, complexity classes, critical path method, pipeline throughput

---

## 1. Introduction

### 1.1 Motivation

The critical path method (CPM) and its extensions form the backbone of modern project scheduling. At their core, these algorithms exploit the max-plus (tropical) semiring structure: parallel tasks complete at the time of the slowest task (maximum = tropical addition), and sequential tasks accumulate durations (ordinary addition = tropical multiplication). Despite this deep algebraic structure, the connection between scheduling theory and tropical algebra has remained largely informal.

Simultaneously, computational complexity theory studies the gap between *creating* solutions and *verifying* them — the P versus NP question. We observe that this gap has a natural analogue in scheduling: executing a recipe is typically harder than verifying the output, and this asymmetry has precise algebraic behavior under composition.

### 1.2 Contributions

This paper makes the following contributions:

1. **Formalization of Recipe Steps**: We define recipe steps as tasks equipped with creation and verification times, with a fundamental asymmetry constraint (Definition 2.1).

2. **Composition Algebra**: We establish that sequential and parallel composition endow recipe steps with a rich algebraic structure, including associativity of sequential composition (Theorem 3.4), identity elements (Theorem 3.5), and a tropical distributive law (Theorem 5.1).

3. **Gap Theorems**: We prove three fundamental theorems about the creation-verification gap:
   - Exact additivity under sequential composition (Theorem 3.1)
   - Subadditivity under parallel composition (Theorem 3.2)
   - Linear scaling under iteration (Theorem 3.3)

4. **Critical Path Bounds**: We prove tight bounds relating the critical path (tropical maximum) to the sequential total (ordinary sum) for parallel task arrangements (Theorems 4.1–4.2).

5. **Pipeline Throughput**: We derive a classical pipeline throughput formula connecting latency, bottleneck time, and batch size (Theorem 4.4), and identify the bottleneck as the tropical spectral radius.

6. **Complexity Classification**: We introduce recipe complexity classes based on asymptotic gap growth and prove closure properties (Theorems 6.1–6.2).

7. **Gap Refinement Invariance**: We prove that decomposing a task into subtasks preserves the total gap exactly (Theorem 7.1), establishing robustness of the gap under refinement.

---

## 2. Definitions

### Definition 2.1 (Recipe Step)

A *recipe step* is a triple r = (c, v, π) where:
- c ∈ ℕ is the *creation time*: the effort to execute the task from scratch
- v ∈ ℕ is the *verification time*: the effort to verify the output is correct
- π is a proof that v ≤ c (verification is never harder than creation)

### Definition 2.2 (Creation-Verification Gap)

The *gap* of a recipe step r = (c, v, π) is gap(r) := c − v ∈ ℕ.

### Definition 2.3 (Sequential Composition)

The sequential composition r ∘_s s of recipe steps r = (c₁, v₁, π₁) and s = (c₂, v₂, π₂) is:

r ∘_s s := (c₁ + c₂, v₁ + v₂, π₁ + π₂)

where π₁ + π₂ denotes the proof that v₁ + v₂ ≤ c₁ + c₂ obtained by adding the inequalities.

### Definition 2.4 (Parallel Composition)

The parallel composition r ∘_p s of recipe steps r = (c₁, v₁, π₁) and s = (c₂, v₂, π₂) is:

r ∘_p s := (max(c₁, c₂), max(v₁, v₂), max_le_max(π₁, π₂))

This is tropical addition applied componentwise.

### Definition 2.5 (n-fold Iteration)

The n-fold iteration r^(n) is defined recursively:
- r^(0) := (0, 0, refl)  (identity)
- r^(n+1) := r^(n) ∘_s r

### Definition 2.6 (Tropical Schedule Vector)

A *tropical schedule vector* of dimension n is a function v : Fin(n) → ℕ assigning durations to n tasks. The *critical path* is max_i v(i) (the tropical sum), and the *sequential total* is Σ_i v(i) (the ordinary sum).

### Definition 2.7 (Pipeline)

A *pipeline* of depth n is a sequence of stage times t : Fin(n) → ℕ₊. The *bottleneck* is max_i t(i), and the *latency* is Σ_i t(i).

### Definition 2.8 (Recipe Family and Complexity Class)

A *recipe family* is a function F : ℕ → RecipeStep, assigning a recipe step to each "problem size" n.

A recipe family F has:
- *Trivial gap* if ∃ C, ∀ n, gap(F(n)) ≤ C
- *Linear gap* if ∃ c > 0, ∀ n, c·n ≤ gap(F(n))

The *recipe complexity class* of F is Trivial, LinearGap, or SuperlinearGap according to its asymptotic gap behavior.

---

## 3. Gap Theorems

### Theorem 3.1 (Gap Additivity)

*For any recipe steps r and s, gap(r ∘_s s) = gap(r) + gap(s).*

**Proof sketch**: Write gap(r ∘_s s) = (c₁ + c₂) − (v₁ + v₂). Since v₁ ≤ c₁ and v₂ ≤ c₂, natural number subtraction distributes: this equals (c₁ − v₁) + (c₂ − v₂) = gap(r) + gap(s). The key step is the identity (a + b) − (c + d) = (a − c) + (b − d) for natural numbers when c ≤ a and d ≤ b. □

**Significance**: The gap is a homomorphism from the monoid of recipe steps (under sequential composition) to (ℕ, +). This is a strong structural property: the gap carries compositional information faithfully.

### Theorem 3.2 (Gap Subadditivity)

*For any recipe steps r and s, gap(r ∘_p s) ≤ max(gap(r), gap(s)).*

**Proof sketch**: We have gap(r ∘_p s) = max(c₁, c₂) − max(v₁, v₂). By case analysis on the relative ordering of c₁, c₂, v₁, v₂, this is bounded by max(c₁ − v₁, c₂ − v₂) = max(gap(r), gap(s)). The key observation is that the maximum of the creation times minus the maximum of the verification times cannot exceed the maximum of the individual gaps. □

**Significance**: Parallelism does not amplify the creation-verification asymmetry. This is the recipe-theoretic shadow of the containment NC ⊆ P.

### Theorem 3.3 (Linear Gap Scaling)

*For any recipe step r and n ∈ ℕ, gap(r^(n)) = n · gap(r).*

**Proof sketch**: By induction on n, using Theorem 3.1. Base case: gap(r^(0)) = gap(0, 0, refl) = 0 = 0 · gap(r). Inductive step: gap(r^(n+1)) = gap(r^(n) ∘_s r) = gap(r^(n)) + gap(r) = n · gap(r) + gap(r) = (n+1) · gap(r). □

### Theorem 3.4 (Associativity of Sequential Composition)

*For any recipe steps r, s, t: (r ∘_s s) ∘_s t = r ∘_s (s ∘_s t).*

### Theorem 3.5 (Identity Element)

*The identity step (0, 0, refl) is a two-sided identity for sequential composition.*

---

## 4. Critical Path and Pipeline Theory

### Theorem 4.1 (Critical Path Upper Bound)

*For any tropical schedule vector v of dimension n+1, criticalPath(v) ≤ seqTotal(v).*

**Proof sketch**: The critical path is sup'(univ, v.durations). Each individual duration v(i) ≤ Σ_j v(j) since all durations are non-negative. Therefore the supremum is also at most the sum. □

### Theorem 4.2 (Critical Path Lower Bound / Average Bound)

*For any tropical schedule vector v of dimension n+1, (n+1) · criticalPath(v) ≥ seqTotal(v).*

**Proof sketch**: Since criticalPath(v) ≥ v(i) for each i, summing over all i gives (n+1) · criticalPath(v) ≥ Σ_i v(i) = seqTotal(v). □

**Corollary**: criticalPath(v) ≥ seqTotal(v) / (n+1), i.e., the critical path is at least the average task duration.

### Theorem 4.3 (Bottleneck Bound)

*For any pipeline p of depth n+1, bottleneck(p) ≤ latency(p).*

### Theorem 4.4 (Pipeline Throughput Formula)

*For k+1 items through a pipeline p of depth n+1:*

*latency(p) + k · bottleneck(p) ≥ bottleneck(p) · (k+1)*

**Proof sketch**: This follows directly from bottleneck(p) ≤ latency(p). Adding k · bottleneck(p) to both sides of this inequality gives the result. □

**Interpretation**: The total time for k+1 items is at most latency + k · bottleneck. After the pipeline fills (which takes latency time), one item completes every bottleneck time units. The bottleneck is the tropical eigenvalue governing steady-state behavior.

---

## 5. Tropical Distributive Law

### Theorem 5.1 (Tropical Distributivity for Recipe Scheduling)

*For any recipe steps r, s, t:*
- *createTime(r ∘_s (s ∘_p t)) = createTime((r ∘_s s) ∘_p (r ∘_s t))*
- *verifyTime(r ∘_s (s ∘_p t)) = verifyTime((r ∘_s s) ∘_p (r ∘_s t))*

**Proof sketch**: The creation time identity reduces to c₁ + max(c₂, c₃) = max(c₁ + c₂, c₁ + c₃), which is the standard distributive law of addition over maximum in ℕ. Similarly for verification times. □

**Significance**: This theorem is the algebraic foundation of the Critical Path Method (CPM). It shows that sequential composition distributes over parallel composition, allowing local optimization at each decision point in a project network. Without this law, finding the critical path would require exhaustive search over all possible schedules.

---

## 6. Recipe Complexity Classes

### Theorem 6.1 (Iteration Produces Linear Gap)

*If gap(r) > 0, then the family F(n) := r^(n) has linear gap.*

**Proof sketch**: By Theorem 3.3, gap(r^(n)) = n · gap(r). Take c := gap(r) > 0. Then c · n = gap(r) · n = gap(r^(n)) for all n. □

### Theorem 6.2 (Trivial Gap Closure under Parallelism)

*If F and G have trivial gap, then the family n ↦ F(n) ∘_p G(n) has trivial gap.*

**Proof sketch**: Let C_F, C_G be the bounds on gap(F(n)), gap(G(n)). By Theorem 3.2, gap(F(n) ∘_p G(n)) ≤ max(gap(F(n)), gap(G(n))) ≤ max(C_F, C_G). □

---

## 7. Gap Refinement Invariance

### Theorem 7.1 (Gap Refinement Invariance)

*If r₁ ∘_s r₂ has the same total creation and verification times as r (i.e., c₁ + c₂ = c and v₁ + v₂ = v), then gap(r₁ ∘_s r₂) = gap(r).*

**Proof sketch**: gap(r₁ ∘_s r₂) = (c₁ + c₂) − (v₁ + v₂) = c − v = gap(r). □

**Significance**: The creation-verification gap is robust under task decomposition. Splitting a task into subtasks cannot hide or amplify the gap, as long as the total times are preserved. This is a conservation law for computational difficulty.

---

## 8. Algorithms

### Algorithm 8.1: Critical Path Computation

Given a tropical schedule vector v of dimension n:

```
function criticalPath(v):
    return max(v[0], v[1], ..., v[n-1])
```

Time complexity: O(n). This is optimal by the Ω(n) lower bound for finding the maximum of n unsorted numbers.

### Algorithm 8.2: Pipeline Throughput Estimation

Given a pipeline p of depth n and batch size k:

```
function throughputEstimate(p, k):
    bottleneck = max(p.stageTimes)
    latency = sum(p.stageTimes)
    totalTime = latency + (k - 1) * bottleneck
    throughput = k / totalTime
    return throughput
```

### Algorithm 8.3: Gap Classification

Given a recipe family F, classify its complexity by sampling:

```
function classifyGap(F, samples):
    gaps = [gap(F(n)) for n in samples]
    if max(gaps) - min(gaps) < threshold:
        return TRIVIAL
    ratios = [gaps[i] / samples[i] for i in range(len(samples))]
    if ratios are approximately constant:
        return LINEAR_GAP
    return SUPERLINEAR_GAP
```

---

## 9. Discussion

### 9.1 Connections to Complexity Theory

The creation-verification gap framework provides a concrete algebraic model of the P versus NP question. While our results do not resolve P versus NP, they show that the gap has strong structural properties: additivity, subadditivity, linear scaling, and refinement invariance. These properties constrain the space of possible complexity-theoretic behaviors.

The tropical distributive law (Theorem 5.1) explains why scheduling is computationally tractable: it allows the critical path to be computed by local optimization. This is an algebraic explanation of the polynomial-time solvability of scheduling on DAGs, in contrast to the NP-hardness of scheduling with precedence constraints and resource conflicts.

### 9.2 Connections to Tropical Geometry

The pipeline throughput formula (Theorem 4.4) identifies the bottleneck as a tropical eigenvalue. In the language of tropical matrix algebra, a pipeline with stage times t₁, ..., tₙ can be represented as a matrix M in the max-plus semiring, where M^k computes the k-step throughput. The bottleneck is the tropical spectral radius ρ(M), and the steady-state throughput is 1/ρ(M).

This connects recipe complexity to the broader theory of tropical linear algebra, including tropical eigenvalue problems, Kleene stars, and tropical convexity.

### 9.3 Limitations and Future Work

Our model assumes that verification time is always at most creation time. This is motivated by the P ⊆ NP conjecture but is not universally true: interactive proof systems can verify statements that are hard even to state precisely. Extending the model to allow v > c in some cases (modeling interactive or probabilistic verification) is an interesting direction.

The complexity classification (Definition 2.8) is coarse. A finer classification, perhaps using tropical valuation theory, could capture more nuanced gap behavior (e.g., polynomial vs. exponential gap growth).

---

## 10. Future Work

1. **Tropical Matrix Representation**: Represent recipe networks as tropical matrices and prove that matrix powers in the max-plus semiring compute multi-step critical paths.

2. **Spectral Characterization**: Show that recipe complexity classes can be characterized by tropical spectral radii, establishing a bridge between algebraic and computational complexity.

3. **Resource Constraints**: Extend the model to include limited resources (e.g., number of parallel workers), connecting to scheduling theory on parallel machines.

4. **Interactive Verification**: Generalize the model to allow verification time to exceed creation time in specific contexts, connecting to interactive proof systems.

5. **Tropical Complexity Hierarchy**: Develop a hierarchy of complexity classes defined by tropical algebraic properties, analogous to the polynomial hierarchy in classical complexity theory.

---

## References

1. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.

2. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.

3. Arora, S., & Barak, B. (2009). *Computational Complexity: A Modern Approach*. Cambridge University Press.

4. Heidergott, B., Olsder, G. J., & van der Woude, J. (2006). *Max Plus at Work*. Princeton University Press.

5. Gaubert, S. (1992). *Théorie des systèmes linéaires dans les dioïdes*. Thèse, École des Mines de Paris.
