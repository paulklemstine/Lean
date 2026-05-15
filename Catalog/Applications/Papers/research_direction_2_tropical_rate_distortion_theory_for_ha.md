# Tropical Rate-Distortion Theory for Harmonic Variety: A Finite Deterministic Information Theory

## Abstract

We establish a rigorous finite tropical rate-distortion theory for contrapuntal pitch spaces. Given a finite pitch alphabet α, a finite index type ι, a source melodic line u : ι → α, and a cost function cost : α → α → ℕ, we define the *harmonic variety* of a candidate line v as the cardinality of its image (the number of distinct pitches used) and the *rate-distortion function* R(D) as the maximum harmonic variety achievable under a total cost budget D. We prove that R(D) is monotone, takes finitely many values (step-function structure), and that the supremum is attained by a concrete witness whenever the feasible set is nonempty. We establish a primal-dual threshold characterization: for k ≥ 1, k ≤ R(D) if and only if the minimum cost C(k) to achieve variety ≥ k satisfies C(k) ≤ D. We prove that C(k) is monotone. We prove a tropical data-processing inequality: under a cost-increasing transformation T, the rate-distortion function from T∘u is pointwise bounded by the rate-distortion function from u. All results are formalized and machine-verified. This work establishes the first complete framework for *combinatorial information theory without probabilities*, where support geometry replaces measure and tropical optimization replaces expectation.

## 1. Introduction

### 1.1 Motivation

Classical rate-distortion theory (Shannon, 1959) characterizes the minimum description rate for a random source at a given distortion level. The theory is fundamentally probabilistic: entropy is defined via probability distributions, distortion is measured in expectation, and the rate-distortion function is characterized by a variational formula over the space of conditional distributions.

Many natural applications, however, involve deterministic finite objects — DNA sequences, musical scores, pixel arrays, communication codebooks — where the relevant notion of "complexity" is not Shannon entropy but *support cardinality*: how many distinct values does the sequence use? Similarly, the relevant notion of "distortion" is not an expected cost but a *total pointwise cost*: the sum of penalties incurred by editing individual positions.

We develop a self-contained theory for this setting. The central objects are:

- **Harmonic variety**: the number of distinct values in the image of a function (support cardinality).
- **Total cost**: the sum of position-wise penalties for transforming one sequence into another.
- **Rate-distortion function**: the maximum harmonic variety achievable within a total cost budget.
- **Threshold costs**: the minimum total cost needed to achieve a given variety level.

### 1.2 Relationship to Prior Work

The tropical (min-plus/max-plus) semiring has been extensively studied in optimization, algebraic geometry, and combinatorics (Maclagan & Sturmfels, 2015). Tropical convexity and tropical Legendre-Fenchel duality have been explored (Akian et al., 2011), and connections to idempotent analysis and Maslov dequantization are well-established (Litvinov, 2007).

Information-theoretic applications of tropical algebra are more recent. Tropical entropy has been defined as a zero-temperature limit of Shannon entropy (Pachter & Sturmfels, 2004). The existing project files `TropicalRateDistortion.lean` and `TropicalRateDistortionExact.lean` develop a real-valued tropical rate-distortion duality using tropical conjugates and minimax inequalities.

Our work differs fundamentally from these predecessors:
1. We work in the **natural numbers** ℕ rather than ℝ, making all constructions fully constructive and decidable.
2. Our "rate" is **support cardinality** rather than a real-valued tropical entropy.
3. Our main results are **exact combinatorial theorems** about finite sets, not asymptotic or real-analytic statements.
4. We prove a **data-processing inequality** for deterministic support-complexity — an entirely new result.

### 1.3 Summary of Contributions

We prove the following theorems, all formalized and machine-verified:

| Theorem | Statement |
|---------|-----------|
| Monotonicity | R(D₁) ≤ R(D₂) whenever D₁ ≤ D₂ |
| Attainment | If ∃v with totalCost ≤ D, then ∃v achieving R(D) |
| Boundedness | R(D) ≤ min(|α|, |ι|) |
| Finite range | Set.range(R) is finite |
| Variety loss | harmonicVariety(T∘v) ≤ harmonicVariety(v) |
| Data processing | Under cost-increasing T: R_{T∘u}(D) ≤ R_u(D) |
| Primal-dual | For k ≥ 1: k ≤ R(D) ↔ C(k) ≤ D |
| Threshold monotonicity | C(k₁) ≤ C(k₂) whenever k₁ ≤ k₂ |

## 2. Definitions and Notation

### 2.1 Setup

Throughout, let:
- α be a finite type with decidable equality (the *pitch alphabet*)
- ι be a finite type (the *index type* or *time positions*)
- cost : α → α → ℕ be a *contrapuntal cost function*
- u : ι → α be a fixed *source melodic line*

### 2.2 Core Definitions

**Definition 2.1** (Total Cost). The total cost of transforming u to v is:

$$\text{totalCost}(\text{cost}, u, v) = \sum_{i \in \iota} \text{cost}(u(i), v(i))$$

**Definition 2.2** (Harmonic Variety). The harmonic variety of a line v is:

$$\text{harmonicVariety}(v) = |\text{image}(v)| = |\{v(i) : i \in \iota\}|$$

Equivalently, `(Finset.univ.image v).card`.

**Definition 2.3** (Rate-Distortion Function). The tropical rate-distortion function at budget D is:

$$R(D) = \sup\{\text{harmonicVariety}(v) : \text{totalCost}(\text{cost}, u, v) \leq D\}$$

where the supremum is over all v : ι → α. When the feasible set is empty, R(D) = 0 (the bottom element of ℕ).

Formally, this is `Finset.sup` over the filtered set `Finset.univ.filter (fun v => totalCost cost u v ≤ D)`.

**Definition 2.4** (Minimum Cost for Variety). The minimum cost to achieve variety at least k is:

$$C(k) = \inf\{\text{totalCost}(\text{cost}, u, v) : \text{harmonicVariety}(v) \geq k\}$$

Formally, this is `Finset.inf` over `Finset.univ.filter (fun v => k ≤ harmonicVariety v)`, valued in `WithTop ℕ` (returning ⊤ when no such v exists).

## 3. Main Results

### 3.1 Boundedness

**Theorem 3.1** (Variety Bounds). For any v : ι → α:

$$\text{harmonicVariety}(v) \leq \min(|\alpha|, |\iota|)$$

*Proof sketch.* The image `Finset.univ.image v` is a subset of `Finset.univ : Finset α`, giving the α-bound via `Finset.card_le_univ`. The ι-bound follows from `Finset.card_image_le`: the image of a set has cardinality at most the original set. □

**Corollary 3.2** (Rate-Distortion Bound). R(D) ≤ min(|α|, |ι|) for all D.

*Proof.* Apply `Finset.sup_le` with the pointwise bound from Theorem 3.1. □

### 3.2 Monotonicity

**Theorem 3.3** (Monotonicity). The function D ↦ R(D) is monotone: if D₁ ≤ D₂, then R(D₁) ≤ R(D₂).

*Proof sketch.* If D₁ ≤ D₂, then `{v : totalCost(cost, u, v) ≤ D₁} ⊆ {v : totalCost(cost, u, v) ≤ D₂}`, i.e., the feasible set at D₁ is a subset of the feasible set at D₂. The result follows from `Finset.sup_mono`: the supremum over a subset is bounded by the supremum over the superset. □

### 3.3 Attainment

**Theorem 3.4** (Attainment). If there exists v : ι → α with totalCost(cost, u, v) ≤ D, then there exists v₀ with totalCost(cost, u, v₀) ≤ D and harmonicVariety(v₀) = R(D).

*Proof sketch.* The feasible set is a nonempty finite set (by hypothesis and the finiteness of ι → α). By `Finset.exists_max_image`, the maximum of harmonicVariety over this nonempty finite set is attained at some element v₀. Then harmonicVariety(v₀) equals the supremum by `le_antisymm` using `Finset.le_sup` and `Finset.sup_le`. □

### 3.4 Step-Function Structure

**Theorem 3.5** (Finite Range). The set `Set.range(R)` is finite.

*Proof sketch.* By Corollary 3.2, every value R(D) lies in `Set.Iic(min(|α|, |ι|))`, which is a finite set of natural numbers. Since the range is a subset of a finite set, it is finite. □

Combined with monotonicity, this implies R is a non-decreasing step function with finitely many jumps.

### 3.5 Tropical Data-Processing Inequality

**Theorem 3.6** (Variety Loss Under Composition). For any T : α → α and v : ι → α:

$$\text{harmonicVariety}(T \circ v) \leq \text{harmonicVariety}(v)$$

*Proof sketch.* We have `Finset.univ.image (T ∘ v) ⊆ (Finset.univ.image v).image T` by the factorization of image through composition. Then `card((Finset.univ.image v).image T) ≤ card(Finset.univ.image v)` by `Finset.card_image_le`. □

**Theorem 3.7** (Tropical Data-Processing Inequality). Let T : α → α satisfy the cost-increasing condition:

$$\forall a, b \in \alpha,\ \text{cost}(a, b) \leq \text{cost}(T(a), b)$$

Then for all D:

$$R_{T \circ u}(D) \leq R_u(D)$$

*Proof sketch.* Under the hypothesis, for any v:

$$\text{totalCost}(\text{cost}, u, v) = \sum_i \text{cost}(u(i), v(i)) \leq \sum_i \text{cost}(T(u(i)), v(i)) = \text{totalCost}(\text{cost}, T \circ u, v)$$

So if v is feasible for (T∘u, D), then v is also feasible for (u, D). The feasible set for T∘u is contained in the feasible set for u. The result follows from `Finset.sup_mono`. □

**Interpretation.** The cost-increasing condition means T makes every source pitch "farther" from every target. Under this condition, starting from the degraded source T∘u is strictly worse than starting from u: the maximum achievable variety at every budget level can only decrease. This is the deterministic analogue of the classical data-processing inequality: lossy processing cannot increase information capacity.

### 3.6 Primal-Dual Threshold Characterization

**Theorem 3.8** (Threshold Monotonicity). The function k ↦ C(k) is monotone: if k₁ ≤ k₂, then C(k₁) ≤ C(k₂).

*Proof sketch.* If k₁ ≤ k₂, then `{v : harmonicVariety(v) ≥ k₂} ⊆ {v : harmonicVariety(v) ≥ k₁}`. Taking the infimum over a superset gives a smaller-or-equal value. □

**Theorem 3.9** (Primal-Dual Duality). For k ≥ 1:

$$k \leq R(D) \iff C(k) \leq D$$

*Proof sketch.*

(⇒) If k ≤ R(D) and k ≥ 1, then the feasible set at budget D is nonempty (since R(D) ≥ k ≥ 1 > 0 = sup(∅)). Moreover, there exists v in the feasible set with harmonicVariety(v) ≥ k (otherwise sup < k). This v has totalCost ≤ D and variety ≥ k, so C(k) ≤ totalCost(cost, u, v) ≤ D.

(⇐) If C(k) ≤ D, then C(k) < ⊤, so the set of v with variety ≥ k is nonempty. The infimum C(k) ≤ D means there exists v with variety ≥ k and totalCost ≤ D. This v is in the feasible set at budget D, so R(D) ≥ harmonicVariety(v) ≥ k. □

**Remark.** The condition k ≥ 1 is necessary. When k = 0, k ≤ R(D) is always true (since R(D) ≥ 0), but C(0) ≤ D can fail when no line has totalCost ≤ D.

## 4. Algorithms

### 4.1 Exact Computation

**Algorithm 1** (Exhaustive Search).

```
Input: cost, u, α, D_max
Output: R(D) for D = 0, ..., D_max

for each v ∈ α^|ι|:
    compute c = totalCost(cost, u, v)
    compute var = |{v(i) : i ∈ ι}|
    store (c, var)

for D = 0 to D_max:
    R[D] = max{var : (c, var) stored with c ≤ D}
```

**Complexity**: O(|α|^|ι| · |ι|) for preprocessing, O(D_max) for queries.

### 4.2 Threshold-Based Computation

**Algorithm 2** (Threshold Computation).

```
Input: cost, u, α
Output: C(k) for k = 0, ..., min(|α|, |ι|)

Initialize C[k] = ∞ for all k
for each v ∈ α^|ι|:
    c = totalCost(cost, u, v)
    var = |{v(i) : i ∈ ι}|
    for k = 0 to var:
        C[k] = min(C[k], c)

R(D) = max{k : C(k) ≤ D}
```

**Complexity**: Same as Algorithm 1 for preprocessing. After computing C(k), each R(D) query takes O(min(|α|, |ι|)) time.

### 4.3 Greedy Heuristic

For large instances where exhaustive search is impractical, a greedy heuristic starts with v = u (zero cost) and iteratively swaps positions to maximize marginal variety gain within the remaining budget. The heuristic runs in O(|ι| · |α|) time but is not guaranteed optimal.

## 5. Applications

### 5.1 Musical Counterpoint

Consider a pitch alphabet α = {C, D, E, F, G, A, B} (the C major scale), a cantus firmus u = [C, D, E, F], and a contrapuntal cost function based on interval consonance: unisons cost 0, thirds and fifths cost 1, seconds and sevenths cost 2, tritones cost 3.

The rate-distortion curve reveals that:
- At budget D = 0, the only feasible counterpoint is u itself (variety 4).
- As the budget increases, variety may increase as chromatic alterations become affordable.
- Above a threshold D*, maximum variety is achieved and further budget has no effect.

The threshold costs C(k) give the exact dissonance price of each additional level of harmonic diversity.

### 5.2 DNA Sequence Diversity

With alphabet {A, C, G, T}, transition cost 1, transversion cost 2, the rate-distortion curve for a low-diversity source (e.g., AAACCC) quantifies the minimum mutational load for each level of nucleotide diversity.

### 5.3 Text Vocabulary Enrichment

For a vocabulary of words with semantic-distance costs, the theory quantifies the editorial effort needed to increase vocabulary richness from a repetitive source text.

## 6. Computational Experiments

We computed exact rate-distortion curves and threshold costs for several examples using Python implementations.

**Example 1**: α = {0,1,2,3,4}, u = [0,1,2,3], cost = |a-b|.

| D | R(D) | C(k) for k=1..5 |
|---|------|-----------------|
| 0 | 4    | C(1)=0, C(2)=0, C(3)=0, C(4)=0, C(5)=∞ |

In this example, the source already uses 4 distinct values, so R(0) = 4 = |ι|.

**Example 2**: α = {0,1,2,3}, u = [0,0,1,1], cost = |a-b|.

| D | R(D) |
|---|------|
| 0 | 2    |
| 1 | 3    |
| 2 | 3    |
| 3 | 3    |
| 4 | 4    |

Thresholds: C(1)=0, C(2)=0, C(3)=1, C(4)=4. The duality R(D) ≥ k ↔ C(k) ≤ D is verified for all k ≥ 1.

## 7. Discussion

### 7.1 Comparison with Classical Rate-Distortion Theory

| Feature | Classical (Shannon) | Tropical (This Work) |
|---------|--------------------|--------------------|
| Source model | Random variable | Deterministic sequence |
| Complexity measure | Shannon entropy H(X) | Support cardinality |X| |
| Distortion | Expected cost E[d(X,Y)] | Total cost Σ d(u_i, v_i) |
| Rate-distortion function | Convex, continuous | Monotone step function |
| Characterization | Variational (mutual information) | Exact duality with thresholds |
| Data processing | I(X;g(Y)) ≤ I(X;Y) | R_{T∘u}(D) ≤ R_u(D) |
| Asymptotics | Required (block length → ∞) | Not needed (single object) |

### 7.2 The Role of the Cost-Increasing Hypothesis

The data-processing inequality requires ∀ a b, cost(a,b) ≤ cost(T(a),b). This condition means T makes sources "farther" from all targets. It is satisfied when:
- T collapses values and cost is a metric (by the triangle inequality in special cases)
- T is a "lossy embedding" into a subspace with increased boundary distances
- cost(a,b) depends only on a metric and T is a non-expansive map composed with a translation

The condition is *not* the same as T being a contraction (∀ x y, cost(T(x), T(y)) ≤ cost(x,y)), which would give a different (and in general false) inequality direction.

### 7.3 Limitations

The theory is inherently **finite**: both the alphabet and the index type must be finite for the supremum/infimum to be well-defined as max/min. Extension to countable or continuous settings would require topological or measure-theoretic machinery.

The exponential complexity of exact computation (O(|α|^|ι|)) limits practical applications to small instances. Polynomial-time algorithms or approximation schemes would be needed for large-scale applications.

## 8. Future Work

1. **Tropical channel capacity**: Define channels as cost-bounded transformation families and prove a coding theorem.
2. **Multi-voice rate regions**: Generalize to several simultaneous voices with independent budgets.
3. **Tropical mutual information**: Define a support-based mutual information and prove data-processing.
4. **Efficient algorithms**: Develop polynomial-time approximation schemes for R(D).
5. **Group-equivariant rate-distortion**: Prove invariance under pitch-class group actions.

## References

1. Shannon, C. E. (1959). Coding theorems for a discrete source with a fidelity criterion. *IRE National Convention Record*, 7(4), 142–163.
2. Berger, T. (1971). *Rate Distortion Theory*. Prentice-Hall.
3. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.
4. Litvinov, G. L. (2007). The Maslov dequantization, idempotent and tropical mathematics. *Journal of Mathematical Sciences*, 140(3), 349–386.
5. Pachter, L., & Sturmfels, B. (2004). Tropical geometry of statistical models. *Proceedings of the National Academy of Sciences*, 101(46), 16132–16137.
6. Akian, M., Gaubert, S., & Guterman, A. (2011). Tropical polyhedra are equivalent to mean payoff games. *International Journal of Algebra and Computation*, 22(1), 1250001.
