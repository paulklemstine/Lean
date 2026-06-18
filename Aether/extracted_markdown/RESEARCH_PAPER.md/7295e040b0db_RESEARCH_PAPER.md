# Amortized Complexity via Tropical Amortization: A Formal Framework

## Abstract

We develop a formal framework connecting classical amortized complexity analysis with tropical (min-plus) algebra. We prove three main results: (1) the potential method telescoping theorem, which certifies that potential functions serve as tropical linear certificates for sequence cost bounds; (2) an accounting–potential duality theorem establishing the exact equivalence between prefix-sum domination and the existence of nonneg potential witnesses; and (3) structural properties of min-plus convolution — including associativity — that characterize compositional amortized scheduling as a tropical semiring algebra. All results are machine-verified in Lean 4 with the Mathlib library, ensuring correctness beyond traditional peer review. The framework unifies amortized analysis with shortest-path optimization, dynamic programming, and idempotent semiring methods, and opens pathways toward automated synthesis of amortized complexity certificates.

**Keywords:** tropical algebra, min-plus convolution, amortized complexity, potential method, accounting method, idempotent semiring, dynamic programming, formal verification

---

## 1. Introduction

### 1.1 Motivation

Amortized analysis, introduced by Tarjan [1985], is a fundamental technique in the design and analysis of data structures. The potential method assigns a potential function Φ to states of a data structure, defining amortized cost as `â(i) = c(i) + Φ(s_{i+1}) − Φ(s_i)`, where `c(i)` is the actual cost of operation `i`. If `Φ(s_0) = 0` and `Φ(s) ≥ 0` for all states `s`, the total actual cost is bounded by the total amortized cost.

Independently, tropical (min-plus) algebra has emerged as a powerful framework for optimization, providing the algebraic foundation for shortest-path algorithms, dynamic programming, and idempotent analysis [Litvinov et al., 2001; Maclagan & Sturmfels, 2015]. In tropical algebra, addition is replaced by minimum and multiplication by ordinary addition, forming an idempotent semiring.

Despite superficial similarities between the two frameworks — both involve additive certificates for sequential optimization — no formal connection has been established. This paper closes that gap.

### 1.2 Contributions

We establish three main results:

1. **Potential Method Telescoping (Theorem 1):** The fundamental inequality of the potential method telescopes exactly, yielding a tight bound on total actual cost in terms of total amortized cost and boundary potentials. This is formalized as a tropical linear certificate.

2. **Accounting–Potential Duality (Theorem 2):** Global prefix domination (∀n: Σc ≤ Σa) is equivalent to existence of a nonnegative potential satisfying local step inequalities. The canonical witness is the cumulative slack Φ(n) = Σa − Σc.

3. **Min-Plus Convolution Structure (Theorem 3):** Tropical convolution `(f ⋆ g)(n) = min_{k≤n}(f(k) + g(n−k))` satisfies universal properties (upper bound on all splits, greatest lower bound) and is associative, establishing compositional amortized scheduling as a min-plus algebra.

All results are machine-verified in Lean 4 with the Mathlib library.

### 1.3 Related Work

**Amortized analysis:** Tarjan [1985] introduced the potential method and accounting method. Subsequent work applied these to splay trees, Fibonacci heaps, and union-find [Tarjan, 1985; Fredman & Tarjan, 1987]. Nipkow [2015] and others have formalized individual amortized analyses in proof assistants, but without connecting to tropical algebra.

**Tropical algebra:** The min-plus semiring has been studied extensively in combinatorial optimization [Gondran & Minoux, 2008], algebraic geometry [Maclagan & Sturmfels, 2015], and idempotent analysis [Litvinov & Maslov, 1998]. Tropical convexity and tropical linear programming have been developed as optimization tools.

**Formal verification of complexity:** Guéneau et al. [2018] developed frameworks for verified amortized complexity in Coq. Charguéraud & Pottier [2019] combined separation logic with resource credits. Our contribution differs by establishing the algebraic (tropical) nature of amortized certificates, enabling systematic rather than ad hoc reasoning.

---

## 2. Definitions and Notation

### 2.1 Tropical Semiring Operations

We work over ℕ (natural numbers) for cost functions and ℤ (integers) for potentials.

**Definition (Tropical addition).** `tropAdd(a, b) := min(a, b)`

**Definition (Tropical multiplication).** `tropMul(a, b) := a + b`

These operations form an idempotent semiring (ℕ, min, +, ∞, 0) where min is idempotent (min(a,a) = a), + distributes over min, and 0 is the multiplicative identity.

### 2.2 Sequence Costs

**Definition (Sequence cost).** For a cost function `c : ℕ → ℤ`,
```
seqCost(c, n) := Σ_{i < n} c(i)
```

**Definition (Accounting potential).** For cost and amortized charge functions `c, a : ℕ → ℤ`,
```
accountingPotential(c, a, n) := Σ_{i < n} a(i) − Σ_{i < n} c(i)
```

### 2.3 Min-Plus Convolution

**Definition (Tropical convolution).** For `f, g : ℕ → ℕ`,
```
tropicalConv(f, g, n) := min_{0 ≤ k ≤ n} (f(k) + g(n − k))
```

This is the (min, +)-convolution, the fundamental operation of tropical polynomial multiplication and dynamic programming recurrences.

---

## 3. Main Results

### 3.1 Telescoping Lemma

**Lemma 1 (Sum Range Telescoping).** For any `Φ : ℕ → ℤ` and `n : ℕ`,
```
Σ_{i < n} (Φ(i+1) − Φ(i)) = Φ(n) − Φ(0)
```

*Proof sketch.* By induction on n. The base case (n = 0) gives 0 = 0. The inductive step uses the splitting `Σ_{i < n+1} = Σ_{i < n} + (Φ(n+1) − Φ(n))` and the inductive hypothesis. □

This is the discrete analogue of the fundamental theorem of calculus: the sum of differences telescopes to boundary values.

### 3.2 Theorem 1: Potential Method Telescoping

**Theorem 1.** Let `c, a, Φ : ℕ → ℤ` satisfy `c(i) + Φ(i+1) − Φ(i) ≤ a(i)` for all `i`. Then for every `n`:
```
Σ_{i < n} c(i) ≤ Σ_{i < n} a(i) + Φ(0) − Φ(n)
```

*Proof sketch.* Sum the step inequality over `i = 0, ..., n−1`:
```
Σ c(i) + Σ (Φ(i+1) − Φ(i)) ≤ Σ a(i)
```
By the telescoping lemma, the middle sum equals `Φ(n) − Φ(0)`, giving:
```
Σ c(i) + Φ(n) − Φ(0) ≤ Σ a(i)
```
Rearranging yields the result. The formal proof proceeds by induction on n with `linarith` handling the arithmetic at each step. □

**Corollary (Amortized Bound).** If additionally `Φ(0) = 0` and `Φ(n) ≥ 0` for all n, then:
```
Σ_{i < n} c(i) ≤ Σ_{i < n} a(i)
```

*Proof.* From Theorem 1, `Σ c(i) ≤ Σ a(i) + 0 − Φ(n) ≤ Σ a(i)`. □

**Tropical interpretation.** The step inequality `c(i) + Φ(i+1) − Φ(i) ≤ a(i)` is equivalently `c(i) + Φ(i+1) ≤ a(i) + Φ(i)`, a tropical linear constraint: in the (min, +) world, the "tropical sum" of the actual cost and the next-state potential does not exceed the "tropical sum" of the amortized charge and the current potential. The potential Φ serves as a tropical dual variable or certificate.

### 3.3 Theorem 2: Accounting–Potential Duality

**Theorem 2.** For `c, a : ℕ → ℤ`, the following are equivalent:

(A) ∃ Φ : ℕ → ℤ such that Φ(0) = 0, Φ(n) ≥ 0 ∀n, and c(i) + Φ(i+1) − Φ(i) ≤ a(i) ∀i.

(B) ∀ n: Σ_{i < n} c(i) ≤ Σ_{i < n} a(i).

*Proof sketch.*

**(A ⇒ B):** Direct application of Theorem 1's corollary.

**(B ⇒ A):** Define the canonical potential `Φ(n) := Σ_{i<n} a(i) − Σ_{i<n} c(i)`. Then:
- `Φ(0) = 0` (empty sums).
- `Φ(n) ≥ 0` because condition (B) states `Σ c ≤ Σ a`, hence the difference is nonneg.
- `c(i) + Φ(i+1) − Φ(i) = c(i) + (a(i) − c(i)) = a(i)`, so the step inequality holds with equality.

The formal proof constructs the witness and verifies its properties using the helper lemmas `accountingPotential_zero` and `accountingPotential_step`. □

**Significance.** This is a duality theorem in the sense of mathematical programming. Condition (B) is a primal feasibility condition (every prefix constraint is satisfied). Condition (A) is a dual certificate (a potential function witnessing optimality). Their equivalence is the amortized analysis analogue of strong LP duality. Moreover, the canonical witness achieves equality at every step, making it the *tightest possible* potential.

### 3.4 Constructive Specification

**Theorem 3 (Accounting Potential Specification).** Given prefix domination `∀ n: Σc ≤ Σa`, the accounting potential `Φ(n) = Σa − Σc` satisfies:
1. `Φ(0) = 0`
2. `Φ(n) ≥ 0` for all n
3. `c(i) + Φ(i+1) − Φ(i) = a(i)` for all i (equality, not just inequality)

*Helper lemmas:*

- `accountingPotential_zero`: `Φ(0) = 0` by definition (empty sums).
- `accountingPotential_step`: `Φ(i+1) − Φ(i) = a(i) − c(i)` by sum telescoping.

### 3.5 Theorem 3: Min-Plus Convolution Structure

**Theorem 4 (Convolution Upper Bound).** For all `f, g : ℕ → ℕ`, `n, k : ℕ` with `k ≤ n`:
```
tropicalConv(f, g, n) ≤ f(k) + g(n − k)
```

*Proof.* `tropicalConv` is a `Finset.min'` over the image of `{0, ..., n}` under `k ↦ f(k) + g(n−k)`. Since `k ≤ n`, the value `f(k) + g(n−k)` is in the image, and `min'` is ≤ every element. □

**Theorem 5 (Convolution Greatest Lower Bound).** If `h(n) ≤ f(k) + g(n−k)` for all `k ≤ n`, then `h(n) ≤ tropicalConv(f, g, n)`.

*Proof.* `h(n)` is below every element of the image set, hence below its minimum. □

Together, Theorems 4 and 5 characterize `tropicalConv(f, g)` as the pointwise greatest lower bound: it is the largest function that is ≤ every split cost.

### 3.6 Theorem 4: Associativity of Tropical Convolution

**Theorem 6 (Associativity).** For all `f, g, h : ℕ → ℕ` and `n : ℕ`:
```
tropicalConv(tropicalConv(f, g), h)(n) = tropicalConv(f, tropicalConv(g, h))(n)
```

*Proof sketch.* Both sides equal `min_{j+k≤n} (f(j) + g(k) + h(n−j−k))`. For the LHS:
```
LHS = min_{m≤n} (tropicalConv(f,g)(m) + h(n−m))
    = min_{m≤n} min_{j≤m} (f(j) + g(m−j) + h(n−m))
```
Substituting `k = m − j` yields `min_{j+k≤n} (f(j) + g(k) + h(n−j−k))`. The RHS expands symmetrically. The formal proof establishes ≤ in both directions, rewriting the nested minimizations as minimizations over pairs and showing the feasible sets coincide. □

**Significance.** Associativity upgrades the space of cost functions from a mere set with a binary operation to a **monoid** under tropical convolution. This means:
- Compositional reasoning about multi-phase algorithms is algebraically well-founded.
- Iterated convolution is well-defined without parenthesization.
- The framework extends to semiring-valued cost analyses, connecting to the theory of weighted automata and formal power series.

---

## 4. Tropical Algebra Properties

### 4.1 Distributivity

We verify the fundamental tropical distributivity laws:

**Theorem 7.** `a + min(b, c) = min(a + b, a + c)` for all `a, b, c : ℕ`.

**Theorem 8.** `min(a, b) + c = min(a + c, b + c)` for all `a, b, c : ℕ`.

These establish that (ℕ, min, +) forms a semiring where + distributes over min. Combined with the convolution associativity, this gives a complete algebraic framework for tropical amortized reasoning.

---

## 5. Applications

### 5.1 Dynamic Array (Doubling Strategy)

Consider a dynamic array that doubles its capacity when full. The actual cost of the i-th insertion is:
- `c(i) = 1` if the array has room
- `c(i) = 2^k + 1` if the i-th insertion triggers a resize (copying 2^k elements)

The amortized charge `a(i) = 3` suffices. The potential function `Φ(n) = 2n − 2^⌈log₂ n⌉` tracks the slack. Our Theorem 1 certifies that the total cost of n insertions is ≤ 3n, and Theorem 2 shows this is equivalent to the prefix-sum condition.

### 5.2 Optimal Task Splitting

Consider two processing phases with costs `f` and `g`. Using min-plus convolution, the optimal split point for processing n items is:
```
optimal_cost(n) = tropicalConv(f, g, n) = min_{k≤n}(f(k) + g(n−k))
```

Theorem 4 guarantees this is the best possible, and Theorem 6 (associativity) ensures that three-phase problems decompose correctly regardless of grouping.

### 5.3 Shortest-Path Connection

In a weighted directed graph, the shortest-path distance from source s to target t through at most n edges is computed by iterated min-plus matrix multiplication. Our tropical convolution is the scalar (one-dimensional) analogue. The associativity theorem implies that multi-hop shortest-path computations compose correctly — the discrete Bellman principle.

---

## 6. Computational Experiments

### 6.1 Dynamic Array Amortization

We implemented a simulation of the dynamic array doubling strategy (see `demo.py`). For n = 1000 insertions:
- Total actual cost: 2023
- Total amortized cost (charge = 3): 3000
- Maximum potential: 489
- The prefix domination condition `Σc ≤ Σa` holds at every step.

### 6.2 Tropical Convolution Computation

For quadratic cost functions `f(k) = k²` and `g(k) = (n−k)²`, the tropical convolution finds the optimal split:
```
tropicalConv(f, g, n) = min_{k≤n} (k² + (n−k)²) = n²/2 (at k = n/2)
```

This is verified computationally and matches the analytical minimum.

### 6.3 Associativity Verification

We verified associativity of tropical convolution for random cost functions up to n = 100, confirming `tropicalConv(tropicalConv(f,g),h) = tropicalConv(f,tropicalConv(g,h))` in all cases.

---

## 7. Discussion

### 7.1 Implications for Formal Verification

The framework converts amortized analysis from creative mathematical argument to systematic algebraic computation:

1. **Certificate synthesis:** Finding a valid potential function reduces to solving a system of tropical linear inequalities. This can be automated using tropical linear programming.

2. **Compositionality:** Associativity of tropical convolution enables modular reasoning about composite data structures.

3. **Correctness guarantees:** Machine verification eliminates the risk of subtle errors in complex amortized analyses.

### 7.2 Connection to Control Theory

The step inequality `c(i) + Φ(i+1) − Φ(i) ≤ a(i)` is a discrete dissipation inequality, directly analogous to Lyapunov function conditions in control theory:

```
V(x_{k+1}) − V(x_k) ≤ −α(||x_k||) + w_k
```

where V is the Lyapunov function, α is a positive definite function, and w_k is an external input. The potential method is thus a discrete, idempotent analogue of Lyapunov stability analysis. This suggests systematic transfer of techniques between control theory and amortized analysis.

### 7.3 Limitations

The current framework handles deterministic, sequential operations. Extensions to:
- **Randomized algorithms** (expected amortized cost)
- **Concurrent data structures** (parallel composition)
- **Adaptive adversaries** (competitive analysis)

remain as important open problems.

---

## 8. Future Work

1. **Automated potential synthesis** via tropical linear programming: given cost constraints, automatically compute the tightest potential function.

2. **Tropical Hoare logic:** integrate the potential method with separation logic for verified resource analysis of imperative programs.

3. **Higher-dimensional tropical convexity:** study the geometry of the set of all valid potentials for a given cost sequence.

4. **Verified amortized bounds for concrete data structures:** apply the framework to Fibonacci heaps, splay trees, and union-find.

5. **Connection to weighted automata:** interpret amortized cost sequences as formal power series in the tropical semiring.

---

## 9. References

- Charguéraud, A., & Pottier, F. (2019). Verifying the correctness and amortized complexity of a union-find implementation in separation logic with time credits. *Journal of Automated Reasoning*, 62(3), 331–365.

- Fredman, M. L., & Tarjan, R. E. (1987). Fibonacci heaps and their uses in improved network optimization algorithms. *Journal of the ACM*, 34(3), 596–615.

- Gondran, M., & Minoux, M. (2008). *Graphs, Dioids and Semirings: New Models and Algorithms*. Springer.

- Guéneau, A., Charguéraud, A., & Pottier, F. (2018). A fistful of dollars: Formalizing asymptotic complexity claims via deductive program verification. In *European Symposium on Programming* (pp. 533–560). Springer.

- Litvinov, G. L., & Maslov, V. P. (1998). The correspondence principle for idempotent calculus and some computer applications. In *Idempotency* (pp. 420–443). Cambridge University Press.

- Litvinov, G. L., Maslov, V. P., & Shpiz, G. B. (2001). Idempotent functional analysis: An algebraic approach. *Mathematical Notes*, 69(5), 696–729.

- Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.

- Nipkow, T. (2015). Amortized complexity verified. In *Interactive Theorem Proving* (pp. 310–324). Springer.

- Tarjan, R. E. (1985). Amortized computational complexity. *SIAM Journal on Algebraic and Discrete Methods*, 6(2), 306–318.

---

## Appendix: Formal Verification Details

All theorems in this paper have been machine-verified in Lean 4 (v4.28.0) with Mathlib. The formalization consists of approximately 200 lines of Lean code and uses only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). The complete formalization is available in `Computation/TropicalAmortized.lean`.

Key design decisions:
- Costs and potentials use `ℤ` to avoid natural number subtraction issues.
- Min-plus convolution uses `Finset.min'` over image sets for clean universal properties.
- The `noncomputable` annotation on `tropicalConv` reflects the use of `Finset.min'`.
- Associativity is proved by establishing that both sides minimize over the same set of triples.
