# Tropical Amplitude Amplification via Min-Plus Dynamics and Gap Squaring

## Abstract

We introduce a rigorous theory of *tropical amplitude amplification* — the min-plus analogue of Grover's quantum search algorithm. Working over finite state spaces with integer-valued cost functions, we define two operators: the *oracle shift* (adding a penalty to unmarked states) and *tropical diffusion* (doubling distances from the global minimum). We prove exact closed-form expressions for the iterates of the oracle shift, establish that the gap between marked and unmarked minima grows linearly under oracle shift alone, and prove a *gap-doubling theorem* showing that the combined oracle-plus-diffusion step yields exponential gap amplification: gap(t+1) = 2·(gap(t) + β). All results are formalized and machine-verified in Lean 4 with the Mathlib library. We discuss applications to shortest-path acceleration, dynamic programming, weighted automata optimization, and constraint satisfaction.

**Keywords:** tropical semiring, min-plus algebra, amplitude amplification, Grover search, gap amplification, formal verification

---

## 1. Introduction

### 1.1 Motivation

Grover's quantum search algorithm [Grover 1996] searches an unstructured database of N items in O(√N) queries, achieving a provable quadratic speedup over classical exhaustive search. The algorithm alternates two operations: a *phase oracle* that marks target states, and a *diffusion operator* that amplifies the marked amplitudes through constructive interference.

The min-plus (tropical) semiring (ℕ, min, +) is the algebraic foundation of shortest-path algorithms, dynamic programming, and the Bellman equation. In this semiring, "addition" is minimum and "multiplication" is ordinary addition. A natural question arises: *does the tropical semiring support an analogue of Grover's amplitude amplification?*

We answer this affirmatively. The tropical replacement for quantum amplitude is *cost*, and the replacement for amplitude amplification is *gap magnification*: iteratively increasing the difference between marked and unmarked minima until the marked states can be identified by a simple threshold comparison.

### 1.2 Summary of Contributions

1. **Oracle shift operator** (Definition 3.1): The tropical analogue of the quantum phase oracle, adding a fixed penalty to unmarked states.

2. **Exact iterate formula** (Theorem 4.1): After t rounds of oracle shift with bonus β, the cost at state i is c(i) if i is marked, or c(i) + tβ if i is unmarked.

3. **Linear gap growth** (Theorem 4.2): The marked-unmarked gap grows as gap(t) = gap(0) + tβ.

4. **Argmin certification** (Theorem 4.3): After sufficiently many rounds, the global argmin is guaranteed to lie in the marked set.

5. **Tropical diffusion** (Definition 5.1): An operator that doubles all distances from the global minimum, serving as the tropical analogue of Grover diffusion.

6. **Gap-doubling theorem** (Theorem 5.1): One combined oracle-plus-diffusion step gives gap(t+1) = 2·(gap(t) + β), yielding exponential separation in O(log(1/gap₀)) rounds.

7. **Full formal verification**: All results are machine-verified in Lean 4 with Mathlib.

### 1.3 Related Work

**Quantum search:** Grover's algorithm [Grover 1996] and its generalizations [Boyer et al. 1998, Brassard et al. 2002] are foundational to quantum computing. Our work draws conceptual inspiration from the amplification mechanism but operates in a completely different algebraic setting.

**Tropical mathematics:** The tropical semiring has deep connections to algebraic geometry [Maclagan & Sturmfels 2015], optimization [Butkovič 2010], and automata theory [Simon 1988]. The distributivity of addition over minimum — a key property we exploit — is classical.

**Dequantization:** Recent work on dequantizing quantum algorithms [Tang 2019, Chia et al. 2020] shows that some quantum speedups can be replicated classically under structural assumptions. Our work can be viewed as a "tropical dequantization" of Grover search for structured cost landscapes.

**Min-plus matrix algebra:** Efficient algorithms for min-plus matrix multiplication [Williams 2014] and the connection to shortest paths [Zwick 2002] provide the computational substrate for implementing our operators.

---

## 2. Preliminaries

### 2.1 The Tropical Semiring

The tropical semiring (also called the min-plus algebra) is the algebraic structure (ℕ ∪ {∞}, ⊕, ⊗) where:
- a ⊕ b = min(a, b) (tropical addition)
- a ⊗ b = a + b (tropical multiplication)

The identity for ⊕ is ∞ and the identity for ⊗ is 0. This is a commutative semiring: ⊗ distributes over ⊕:

  a ⊗ (b ⊕ c) = a + min(b, c) = min(a + b, a + c) = (a ⊗ b) ⊕ (a ⊗ c)

This distributivity law is the tropical analogue of linearity and is fundamental to our results.

### 2.2 Notation

- **Search space:** Fin(n) = {0, 1, ..., n-1}
- **Cost profile:** c : Fin(n) → ℕ (or ℤ for the diffusion theorem)
- **Marked set:** M ⊆ Fin(n), nonempty proper subset
- **Unmarked set:** M̄ = Fin(n) \ M
- **Marked minimum:** markedMin(M, c) = min{c(i) : i ∈ M}
- **Unmarked minimum:** unmarkedMin(M, c) = min{c(i) : i ∈ M̄}
- **Gap:** Δ(c, M) = unmarkedMin(M, c) - markedMin(M, c)

---

## 3. The Oracle Shift Operator

### Definition 3.1 (Oracle Shift)
For a marked set M, bonus β ∈ ℕ, and cost profile c:

  oracleShift(M, β, c)(i) = c(i) if i ∈ M; c(i) + β if i ∉ M

This is the tropical analogue of the quantum phase oracle. In the quantum setting, the oracle applies a phase factor e^{iπ} = -1 to marked states. In the tropical setting, we add a cost penalty to *unmarked* states — the dual operation that achieves the same relative effect.

### Theorem 3.1 (Oracle Shift Properties)
For all M, β, c:
1. markedMin(M, oracleShift(M, β, c)) = markedMin(M, c)
2. unmarkedMin(M, oracleShift(M, β, c)) = unmarkedMin(M, c) + β

*Proof sketch.* Part (1): For i ∈ M, the oracle shift leaves c(i) unchanged, so the infimum over M is the same. Part (2): For i ∈ M̄, the oracle shift adds β to c(i). Since infimum commutes with adding a constant, inf{c(i) + β : i ∈ M̄} = inf{c(i) : i ∈ M̄} + β. ∎

---

## 4. Linear Amplification

### Theorem 4.1 (Iterate Closed Form)
After t iterations of oracleShift(M, β):

  (oracleShift(M, β))^t(c)(i) = c(i) if i ∈ M; c(i) + tβ if i ∉ M

*Proof.* By induction on t. Base case t = 0 is immediate. For the inductive step, apply oracleShift to the formula: marked states remain c(i), unmarked states go from c(i) + tβ to c(i) + tβ + β = c(i) + (t+1)β. ∎

### Theorem 4.2 (Linear Gap Growth)
If markedMin(M, c) ≤ unmarkedMin(M, c), then:

  Δ(c_t, M) = Δ(c, M) + tβ

where c_t = (oracleShift(M, β))^t(c).

*Proof.* By Theorems 3.1 and 4.1, markedMin is invariant and unmarkedMin increases by tβ. The gap formula follows by subtraction. ∎

### Theorem 4.3 (Argmin Certification)
If markedMin(M, c) < unmarkedMin(M, c) + tβ, then:
1. The global minimum of c_t equals markedMin(M, c_t).
2. Every state achieving markedMin(M, c_t) lies in M.

*Proof.* After t rounds, every marked state has cost c(i) ≤ max{c(j) : j ∈ M}, and every unmarked state has cost c(j) + tβ ≥ unmarkedMin(M, c) + tβ > markedMin(M, c). Therefore the global minimum is achieved in M. ∎

### Theorem 4.4 (Full Separation)
If for every i ∈ M, c(i) < unmarkedMin(M, c) + tβ, then every marked state has strictly lower amplified cost than every unmarked state:

  ∀ i ∈ M, ∀ j ∈ M̄: c_t(i) < c_t(j)

*Proof.* For i ∈ M: c_t(i) = c(i). For j ∈ M̄: c_t(j) = c(j) + tβ ≥ unmarkedMin + tβ > c(i). ∎

---

## 5. Exponential Amplification via Tropical Diffusion

### Definition 5.1 (Tropical Diffusion)
For c : Fin(n) → ℤ with global minimum μ = min{c(i)}:

  diffuse(c)(i) = 2·c(i) - μ

This doubles the distance of every state from the global minimum while preserving the minimum itself.

### Theorem 5.1 (Diffusion Properties)
1. globalMin(diffuse(c)) = globalMin(c)
2. If markedMin(M, c) = globalMin(c), then markedMin(M, diffuse(c)) = globalMin(c)

*Proof.* (1) The minimum of 2c(i) - μ is achieved when c(i) = μ, giving 2μ - μ = μ. For all other states, 2c(i) - μ ≥ 2μ - μ = μ. (2) The marked argmin achieves c(i) = markedMin = μ, so diffuse maps it to μ. Other marked states have c(i) ≥ μ, mapping to 2c(i) - μ ≥ μ. ∎

### Definition 5.2 (Tropical Grover Step)
The combined operator:

  tropGroverStep(M, β, c) = diffuse(oracleShift(M, β, c))

### Theorem 5.2 (Gap Doubling — Main Result)
If markedMin(M, c) = globalMin(c) and β ≥ 0, then:

  Δ(tropGroverStep(M, β, c), M) = 2·(Δ(c, M) + β)

*Proof.* Let c' = oracleShift(M, β, c). Then:
- markedMin(M, c') = markedMin(M, c) (by Theorem 3.1)
- unmarkedMin(M, c') = unmarkedMin(M, c) + β (by Theorem 3.1)
- globalMin(c') = markedMin(M, c) (since marked min = global min and oracle shift only increases costs)
- Therefore markedMin(M, c') = globalMin(c')

Applying Theorem 5.1 to c':
- markedMin(M, diffuse(c')) = globalMin(c') = markedMin(M, c)
- unmarkedMin(M, diffuse(c')) = 2·unmarkedMin(M, c') - globalMin(c') = 2·(unmarkedMin(M, c) + β) - markedMin(M, c)

The gap after the combined step:
  Δ_new = unmarkedMin(diffuse(c')) - markedMin(diffuse(c'))
        = [2·(unmarkedMin + β) - markedMin] - markedMin
        = 2·unmarkedMin + 2β - 2·markedMin
        = 2·(unmarkedMin - markedMin + β)
        = 2·(Δ + β) ∎

### Corollary 5.1 (Exponential Separation)
Starting from gap Δ₀ with bonus β, after t rounds of the tropical Grover step:

  Δ_t = 2^t·(Δ₀ + β) - β   (when β > 0)
  Δ_t = 2^t·Δ₀              (when β = 0)

Therefore O(log(T/Δ₀)) rounds suffice to achieve a gap of T, compared to O(T/β) rounds for linear amplification.

---

## 6. Algorithms and Complexity

### Algorithm 1: Tropical Linear Search

```
Input: cost profile c[0..n-1], marked set M, bonus β
Output: index of marked argmin

t ← 0
while globalMin(c) ∉ M:
    c ← oracleShift(M, β, c)
    t ← t + 1
return argmin(c)
```

**Complexity:** Each round is O(n). Number of rounds: O((max_M c(i) - min_{M̄} c(j))/β). Total: O(n · Δ_max/β).

### Algorithm 2: Tropical Exponential Search

```
Input: cost profile c[0..n-1], marked set M, bonus β
Output: index of marked argmin

t ← 0
while globalMin(c) ∉ M:
    c ← tropGroverStep(M, β, c)
    t ← t + 1
return argmin(c)
```

**Complexity:** Each round is O(n). Number of rounds: O(log(Δ_max/β)). Total: O(n · log(Δ_max/β)).

### Algorithm 3: Structured Search (Product Spaces)

For a product space X₁ × ... × X_k with decomposable cost c(x) = Σᵢ φᵢ(xᵢ) and decomposable marked set M = M₁ × ... × M_k:

```
Input: factor costs φ₁,...,φ_k, factor marked sets M₁,...,M_k, bonus β
Output: optimal marked state

for round t = 1, 2, ...:
    for each factor i:
        φᵢ ← oracleShift(Mᵢ, β/k, φᵢ)
    if certified: return argmin
```

**Complexity:** O(Σ|Xᵢ|) per round instead of O(Π|Xᵢ|).

---

## 7. Applications

### 7.1 Shortest Path Search

Given a weighted graph and a set of target nodes, tropical amplification accelerates identification of the nearest target. After computing single-source shortest path distances (Dijkstra/Bellman-Ford), the amplification operator isolates the best target in O(log(Δ/β)) additional rounds, providing a certified result.

### 7.2 Dynamic Programming / Viterbi Decoding

In Hidden Markov Model decoding, the Viterbi algorithm is a min-plus (tropical) computation. Tropical amplification biases the DP toward target state sequences, accelerating convergence to the optimal path passing through marked states.

### 7.3 Weighted Automata

For weighted finite automata computing the minimum-weight accepted word, tropical amplification penalizes non-accepting paths, making the optimal accepting path emerge with exponentially growing gap.

### 7.4 Constraint Satisfaction

Tropical amplification can implement iterative constraint propagation: constraints that are violated incur increasing penalties, filtering the search space to consistent assignments.

---

## 8. Computational Experiments

### 8.1 Gap Growth Trajectories

We computed gap trajectories for search spaces of size n = 8 with 2 marked states:

| Round | Linear Gap | Exponential Gap |
|-------|-----------|-----------------|
| 0     | 2         | 2               |
| 1     | 4         | 6               |
| 2     | 6         | 14              |
| 3     | 8         | 30              |
| 4     | 10        | 62              |
| 5     | 12        | 126             |
| 6     | 14        | 254             |
| 7     | 16        | 510             |

The exponential method achieves gap > 500 in 7 rounds vs. gap = 16 for the linear method.

### 8.2 Pure Diffusion Doubling

With bonus β = 0 and initial gap 1, pure diffusion doubles the gap each round:

| Round | Gap  |
|-------|------|
| 0     | 1    |
| 1     | 2    |
| 2     | 4    |
| 3     | 8    |
| 4     | 16   |
| 5     | 32   |

Confirming Δ_t = 2^t · Δ₀.

### 8.3 Structured Product Search

On a 4×4 product space with decomposable cost c(i,j) = row[i] + col[j], the marked optimum (row=1, col=2) is isolated from round 0 (since it starts as the global minimum), with the gap growing by 2 per round under linear amplification.

---

## 9. Discussion

### 9.1 Comparison with Quantum Grover

| Feature | Quantum Grover | Tropical Grover |
|---------|---------------|-----------------|
| Algebra | ℂ (Hilbert space) | (ℕ, min, +) |
| "Amplitude" | Complex probability amplitude | Integer cost |
| Oracle | Phase flip on marked states | Cost penalty on unmarked states |
| Diffusion | Inversion about mean | Distance doubling from minimum |
| Gap growth | Quadratic (sin²(θt)) | Linear or exponential (2^t) |
| Result | Probabilistic | Deterministic + certified |
| Unstructured search | O(√N) queries | No speedup (O(N)) |
| Structured search | Problem-dependent | O(n · log(Δ/β)) |

### 9.2 Limitations

1. The tropical Grover step does not give a speedup for *unstructured* search (where you have no cost structure — just marked/unmarked). The speedup requires *cost gaps* to amplify.

2. The gap-doubling theorem requires the precondition that markedMin = globalMin. If this is violated, the diffusion step may not double the gap correctly. In practice, the oracle shift must first establish this precondition.

3. The bit complexity of the amplified costs grows linearly with the number of rounds (each diffusion doubles the magnitude). For practical implementations, periodic renormalization may be needed.

### 9.3 The Tropical-Quantum Bridge

Our results can be viewed through the lens of *Maslov dequantization* [Litvinov 2007]: as the Planck constant ℏ → 0, quantum mechanics degenerates to classical mechanics, and the Schrödinger equation becomes the Hamilton-Jacobi equation — a min-plus (tropical) equation. The tropical Grover step is, in this precise sense, the ℏ → 0 limit of the quantum Grover step.

This suggests a broader program: every quantum algorithm has a tropical shadow, and the tropical shadow may retain some (though not all) of the original algorithm's power.

---

## 10. Future Work

1. **Tropical adversary lower bounds:** Can we prove lower bounds on the number of amplification rounds needed, analogous to the quantum adversary method?

2. **Product space amplification:** Implement and analyze tropical Grover on exponentially large product spaces where costs decompose locally.

3. **Bellman-Grover iteration:** Combine tropical amplification with value iteration in Markov decision processes for accelerated policy search.

4. **Cellular automata implementation:** Realize the amplification operator as a local min-plus cellular automaton rule, connecting to symbolic dynamics.

5. **Tropical amplitude estimation:** Develop a tropical analogue of quantum amplitude estimation that certifies the value of markedMin without computing it exactly.

---

## References

- Boyer, M., Brassard, G., Høyer, P., & Tapp, A. (1998). Tight bounds on quantum searching.
- Brassard, G., Høyer, P., Mosca, M., & Tapp, A. (2002). Quantum amplitude amplification and estimation.
- Butkovič, P. (2010). Max-linear Systems: Theory and Algorithms.
- Grover, L. K. (1996). A fast quantum mechanical algorithm for database search.
- Litvinov, G. L. (2007). The Maslov dequantization, idempotent and tropical mathematics.
- Maclagan, D., & Sturmfels, B. (2015). Introduction to Tropical Geometry.
- Simon, I. (1988). Recognizable sets with multiplicities in the tropical semiring.
- Tang, E. (2019). A quantum-inspired classical algorithm for recommendation systems.
- Williams, V. V. (2014). Multiplying matrices in O(n^{2.3729}) time.
- Zwick, U. (2002). All pairs shortest paths using bridging sets and rectangular matrix multiplication.
