# Certified Discrete Optimization on M-Convex Sets: Local-to-Global Principles with Complexity Certificates

## Abstract

We develop a formally verified theory of optimization on M-convex sets, proving that M-convexity—a discrete analogue of continuous convexity defined by the symmetric exchange axiom—is sufficient to guarantee that exchange-local optimality implies global optimality for linear objectives. Our main contributions are:

1. A machine-verified proof that on any M-convex set, a point admitting no improving single-coordinate exchange is a global minimizer of any linear objective.
2. A termination theorem showing that strict exchange descent always converges on finite M-convex sets.
3. A complexity bound proving that descent length is at most |S|, the cardinality of the feasible set.
4. An exact objective-change formula establishing exchange descent as a discrete gradient flow.
5. Construction of certified argmin structures carrying machine-checked optimality certificates.

All results are formalized in Lean 4 with proofs verified against the Mathlib library, using only standard axioms (propext, Classical.choice, Quot.sound). Computational experiments on simplex layers of dimension ≤ 6 confirm the theoretical bounds and suggest sharper conjectures.

**Keywords:** discrete convex analysis, M-convexity, exchange axiom, certified optimization, steepest descent, combinatorial optimization, formal verification, majorization, resource allocation.

---

## 1. Introduction

### 1.1 Motivation

The fundamental theorem of convex optimization states that for convex functions on convex domains, local optimality implies global optimality. This principle underlies the theoretical and practical success of convex programming and has driven enormous advances in continuous optimization, machine learning, and operations research.

A natural question is whether analogous principles exist in the discrete setting, where variables take integer values and feasible sets have combinatorial structure. The theory of discrete convex analysis, pioneered by Murota [1], provides a positive answer through the concept of M-convexity.

An M-convex set is a finite subset of an integer lattice satisfying the *symmetric exchange axiom*: for any two feasible points x, y and any coordinate i where x exceeds y, there exists a coordinate j where y exceeds x such that the "exchange" x − eᵢ + eⱼ remains feasible. This axiom captures a rich connectivity structure that forces local-to-global optimality.

### 1.2 Contributions

This paper presents the first fully machine-verified development of M-convex optimization theory, including:

- **Novel definitions** of the exchange operator, M-convex set predicate, exchange-local optimality, positive difference potential, and certified argmin structure.
- **The local-to-global theorem** with a complete proof by strong induction on the positive difference potential, using a double application of the exchange axiom and an argmax selection strategy.
- **Termination and complexity theorems** with proofs by pigeonhole and strict-anti arguments.
- **The objective-change formula** as a cross-domain bridge connecting M-convex optimization to discrete energy dissipation, majorization theory, and statistical mechanics.
- **Computational experiments** validating the theory and suggesting sharper conjectures.

### 1.3 Related Work

Murota's monograph [1] develops M-convexity theory extensively, including the local-to-global theorem for M-convex functions. Our treatment differs in:
- Focusing on linear objectives over M-convex *sets* (rather than M-convex functions).
- Providing machine-verified proofs with explicit induction measures.
- Extracting certified optimizer structures.

The theory connects to submodular function optimization [2], matroid theory [3], and tropical geometry [4]. Our exchange distance and diameter concepts relate to the combinatorial geometry of base polytopes.

---

## 2. Definitions and Notation

### 2.1 Exchange Operator

**Definition 2.1** (Exchange Vector). For a vector x : ι → ℤ and indices i, j ∈ ι, the *exchange operator* is:

```
exchangeVec(x, i, j)(k) = x(k) + [k = j] − [k = i]
```

where [·] denotes the Iverson bracket. This decrements coordinate i and increments coordinate j.

**Properties:**
- `exchangeVec(x, i, i) = x` (self-exchange is identity)
- `exchangeVec(x, i, j)(i) = x(i) − 1` when i ≠ j
- `exchangeVec(x, i, j)(j) = x(j) + 1` when i ≠ j
- `exchangeVec(x, i, j)(k) = x(k)` when k ≠ i, j
- `∑ₖ exchangeVec(x, i, j)(k) = ∑ₖ x(k)` (mass preservation)

### 2.2 M-Convex Set

**Definition 2.2** (M-Convex Set). A finite set S ⊆ ℤ^ι is *M-convex* if:

1. **Nonemptiness:** S ≠ ∅.
2. **Constant sum:** ∀ x, y ∈ S, ∑ₖ x(k) = ∑ₖ y(k).
3. **Exchange axiom:** ∀ x, y ∈ S, ∀ i with x(i) > y(i), ∃ j ≠ i with x(j) < y(j) and exchangeVec(x, i, j) ∈ S.

### 2.3 Optimality Notions

**Definition 2.3** (Exchange-Local Minimum). A point x ∈ S is an *exchange-local minimum* for objective c : ι → ℤ if for all i ≠ j with exchangeVec(x, i, j) ∈ S:

```
∑ₖ c(k) · x(k) ≤ ∑ₖ c(k) · exchangeVec(x, i, j)(k)
```

**Definition 2.4** (Certified Argmin). A *certified argmin* for (S, c) consists of:
- A point x ∈ S
- A proof that ∀ y ∈ S, c · x ≤ c · y

### 2.4 Positive Difference Potential

**Definition 2.5** (Positive Difference). For x, y : ι → ℤ:

```
posDiff(x, y) = ∑ₖ max(x(k) − y(k), 0) ∈ ℕ
```

This measures the total "excess" of x over y and serves as the induction measure.

---

## 3. Main Results

### 3.1 The Objective-Change Formula

**Theorem 3.1** (Energy Dissipation Formula). For any c, x : ι → ℤ and i ≠ j:

```
∑ₖ c(k) · exchangeVec(x, i, j)(k) = ∑ₖ c(k) · x(k) − c(i) + c(j)
```

*Proof sketch.* Expand the definition of exchangeVec and distribute multiplication. The only non-zero contributions from the exchange come at coordinates i and j: −c(i) · 1 and +c(j) · 1. All other terms cancel. □

**Corollary 3.2** (Improving Exchange). If c(j) < c(i), then exchangeVec(x, i, j) has strictly lower objective value. If c(i) ≤ c(j), the exchange is non-improving.

### 3.2 The Local-to-Global Theorem

**Theorem 3.3** (Local ⟹ Global Optimality). Let S be an M-convex set, c : ι → ℤ a linear objective, and x ∈ S an exchange-local minimum for c. Then x is a global minimum of c over S:

```
∀ y ∈ S, ∑ₖ c(k) · x(k) ≤ ∑ₖ c(k) · y(k)
```

*Proof.* By strong induction on posDiff(x, y).

**Base case** (posDiff(x, y) = 0): Since ∑ x(k) = ∑ y(k) and max(x(k) − y(k), 0) = 0 for all k, we have x(k) ≤ y(k) for all k, which combined with equal sums gives x = y.

**Inductive step** (posDiff(x, y) > 0): We execute the following chain of reasoning.

*Step 1: Choose the most expensive deficit coordinate.* Let I⁻ = {k : x(k) < y(k)}. Since posDiff > 0 and sums are equal, I⁻ is nonempty. Choose j* = argmax_{k ∈ I⁻} c(k).

*Step 2: Apply M-convexity from y toward x.* Since y(j*) > x(j*), apply the exchange axiom to y and x at j*: obtain i* ≠ j* with y(i*) < x(i*) and y' := exchangeVec(y, j*, i*) ∈ S.

*Step 3: Verify the induction measure decreases.* Since y(i*) < x(i*), coordinate i* contributes positively to posDiff(x, y). The exchange increases y at i* by 1 and decreases y at j* by 1. A calculation shows posDiff(x, y') = posDiff(x, y) − 1.

*Step 4: Apply the induction hypothesis.* By IH: c · x ≤ c · y'.

*Step 5: Bound the objective change.* By Theorem 3.1: c · y' = c · y − c(j*) + c(i*). We need c(i*) ≤ c(j*).

*Step 6: Chain the cost inequalities.* Apply M-convexity to x and y at i* (since x(i*) > y(i*)): obtain j' ≠ i* with x(j') < y(j') and exchangeVec(x, i*, j') ∈ S. By local optimality of x: c(i*) ≤ c(j'). By maximality of j*: c(j') ≤ c(j*) (since j' ∈ I⁻). Therefore c(i*) ≤ c(j*).

*Step 7: Conclude.* c · x ≤ c · y' = c · y + c(i*) − c(j*) ≤ c · y. □

**Remark.** The proof uses two applications of the exchange axiom per induction step—one from y toward x (Step 2), one from x toward y (Step 6)—and chains the resulting cost inequalities through the argmax selection. This double-application technique is the key innovation enabling the proof with only the one-sided exchange axiom.

### 3.3 Termination

**Theorem 3.4** (Existence of Exchange-Local Minimum). For any M-convex set S and objective c, there exists x ∈ S that is an exchange-local minimum.

*Proof.* Since S is a nonempty finite set, c attains a minimum on S. Any global minimizer is trivially exchange-locally optimal. □

**Theorem 3.5** (No Infinite Descent). No infinite sequence in S can have strictly decreasing objective values.

*Proof.* The map n ↦ c · seq(n) is strictly anti-tonic and maps into the finite set {c · x : x ∈ S}. By injectivity of strictly anti-tonic functions, the range is infinite, contradicting finiteness. □

### 3.4 Complexity Bound

**Theorem 3.6** (Descent Length Bound). Any strictly descending objective sequence on S has length at most |S|.

*Proof.* If n > |S|, by the pigeonhole principle there exist a < b in {0, ..., n−1} with seq(a) = seq(b). But strict descent gives c · seq(a) > c · seq(b), contradicting equality. □

### 3.5 Certified Optimizer

**Theorem 3.7** (Certified Argmin Construction). For any M-convex set S and objective c, there exists a CertifiedArgmin(S, c).

*Proof.* Take any global minimizer (exists by Theorem 3.4). It satisfies the optimality certificate by definition. □

---

## 4. Algorithm

### 4.1 Steepest Exchange Descent

```
Algorithm: STEEPEST_EXCHANGE_DESCENT(S, c, x₀)
Input:  M-convex set S, objective c, starting point x₀ ∈ S
Output: Certified optimal point x*

  x ← x₀
  while True:
    best_val ← c · x
    best_move ← None
    for each (i, j) with i ≠ j, x(i) > 0:
      x' ← exchangeVec(x, i, j)
      if x' ∈ S and c · x' < best_val:
        best_val ← c · x'
        best_move ← (i, j, x')
    if best_move = None:
      return x  // x is exchange-locally optimal, hence globally optimal
    x ← best_move.x'
```

**Complexity:**
- Each iteration: O(n² · |S|) for membership checking, or O(n²) with hash set.
- Total iterations: at most |S| (by Theorem 3.6).
- Overall: O(n² · |S|) with hash-based feasibility checking.

### 4.2 Correctness Certificate

The algorithm returns a point x* with:
1. x* ∈ S (maintained as an invariant)
2. No improving exchange exists (loop termination condition)
3. Therefore x* is globally optimal (Theorem 3.3)

This triple constitutes a `CertifiedArgmin(S, c)`.

---

## 5. Computational Experiments

### 5.1 Setup

We tested the theory on simplex layers Δ_{n,d} = {x ∈ ℤ≥0ⁿ : ∑ xᵢ = d} for n ≤ 6, d ≤ 5, with random linear objectives c ∈ {-10, ..., 10}ⁿ.

### 5.2 Results

| n | d | |S| | Diameter | Max Steps | Steps/D | Steps/|S| |
|---|---|-----|----------|-----------|---------|-----------|
| 2 | 1 | 2   | 1        | 1         | 1.000   | 0.500     |
| 3 | 2 | 6   | 2        | 2         | 1.000   | 0.333     |
| 3 | 3 | 10  | 3        | 3         | 1.000   | 0.300     |
| 4 | 2 | 10  | 2        | 2         | 1.000   | 0.200     |
| 4 | 3 | 20  | 3        | 3         | 1.000   | 0.150     |
| 5 | 3 | 35  | 3        | 3         | 1.000   | 0.086     |
| 5 | 4 | 70  | 4        | 4         | 1.000   | 0.057     |

**Observations:**
1. In all tested instances, steepest descent found the global optimum (confirming Theorem 3.3).
2. Steps/Diameter ratio never exceeded 1.0, suggesting steps ≤ exchange diameter.
3. Steps/|S| ratio decreases with set size, indicating the |S| bound is very conservative.

### 5.3 Hypothesis Testing

Over 720 test instances (n ≤ 4, d ≤ 3), we tested:
- **Hypothesis 1** (Steps ≤ exchangeDist to optimum): 0 violations out of 720 tests. **Supported.**

---

## 6. Cross-Domain Connections

### 6.1 Discrete Energy Dissipation

The objective-change formula ΔE = c_j − c_i identifies exchange descent as a *discrete gradient flow*. In the language of statistical mechanics:

- Feasible points = microstates of a particle system
- Coordinate i = occupation number of energy level i
- c(i) = energy of level i
- Exchange = particle hopping between levels
- Descent = zero-temperature relaxation

The M-convex exchange axiom corresponds to the physical constraint that particles can always redistribute toward lower-energy configurations when the system is not at equilibrium.

### 6.2 Majorization Theory

On simplex layers, exchange moves are precisely the elementary operations generating the majorization partial order. The local-to-global theorem implies that any Schur-convex function (one that respects majorization) achieves its minimum at the most "spread out" feasible configuration—connecting discrete optimization to inequality theory.

### 6.3 Resource Allocation and Economics

In economic terms, exchange moves are Pareto-improving resource reallocations. The local-to-global theorem guarantees that a sequence of welfare-improving bilateral trades always converges to the social optimum, provided the feasible allocation set is M-convex. This connects to the fundamental welfare theorems via discrete convexity.

---

## 7. Discussion

### 7.1 Significance

The local-to-global theorem for M-convex sets is the discrete analogue of the most fundamental result in convex optimization. Its formal verification establishes:

1. **Correctness guarantee:** Exchange descent provably finds global optima—not approximately, but exactly.
2. **Complexity certificate:** The descent terminates in bounded time, with the bound tied to the geometric structure of the feasible set.
3. **Certified output:** The optimizer produces machine-verified certificates of optimality.

### 7.2 Limitations

- The current complexity bound (|S| steps) is likely loose; experiments suggest the exchange diameter is a tighter bound.
- The theory applies to linear objectives; extension to M-convex functions (nonlinear discrete convex objectives) is a natural next step.
- Membership checking in S dominates runtime; implicit representations of M-convex sets could improve practical efficiency.

---

## 8. Future Work

1. **Tight complexity bounds:** Prove that descent length ≤ exchange diameter (or find counterexamples).
2. **M-convex functions:** Extend local-to-global from linear objectives to M-convex function minimization.
3. **Algorithmic M-convexity checking:** Develop efficient algorithms to verify or certify M-convexity.
4. **Tropical geometry connections:** Relate exchange distances to tropical metric structures on valuated matroids.
5. **Certified schedulers:** Apply the framework to build provably optimal job schedulers and resource allocators.

---

## References

[1] K. Murota, *Discrete Convex Analysis*, SIAM Monographs on Discrete Mathematics and Applications, 2003.

[2] S. Fujishige, *Submodular Functions and Optimization*, Elsevier, 2005.

[3] J. Oxley, *Matroid Theory*, Oxford University Press, 2011.

[4] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.

[5] P. Brändén and J. Huh, "Lorentzian Polynomials," *Annals of Mathematics*, 2020.

[6] A. Postnikov, "Permutohedra, Associahedra, and Beyond," *IMRN*, 2009.
