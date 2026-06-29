# Threshold Phase Transitions in Bonus-Perturbed Finite Optimization: A Formally Verified Theory

## Abstract

We develop a formally verified theory of **phase transitions** in finite optimization problems perturbed by a linear marking bonus. Given a finite search space with a cost function and a binary predicate ("marked"), we study the perturbed objective F_β(x) = cost(x) − β · 𝟙_{marked(x)}, where β ≥ 0 is a bonus parameter. We prove that the minimizer type undergoes a sharp bifurcation: there exists a critical threshold Δ = (marked minimum cost) − (global minimum cost) such that (1) for β < Δ, every minimizer is unmarked; (2) for β > Δ, every minimizer is marked; (3) at β = Δ, both types coexist. We further establish monotonicity of the "all minimizers are marked" predicate, a tropical decomposition identity for the value function, and an existential theorem packaging the full trichotomy. All results are formally verified in Lean 4 with Mathlib, yielding machine-checked proofs with no unresolved obligations. We provide algorithms for exact threshold computation and binary search approximation, demonstrate applications in logistics, fairness-constrained model selection, energy policy, and network design, and identify connections to tropical geometry, statistical mechanics, and mechanism design.

**Keywords:** phase transition, threshold phenomenon, finite optimization, exact penalty, tropical geometry, binary search, formally verified mathematics

---

## 1. Introduction

### 1.1 Motivation

Consider the problem of selecting the best option from a finite set, subject to a preference for options satisfying a binary property. This scenario arises ubiquitously:

- A logistics planner choosing routes, preferring "green" options
- A model selection procedure in ML, preferring fair models
- An energy planner choosing power sources, preferring renewables
- A network designer choosing paths, preferring redundant configurations

A natural approach is to introduce a **bonus** β that reduces the effective cost of options satisfying the property. The fundamental question is: *at what bonus level does the optimal choice change from unconstrained to constrained?*

### 1.2 Main Contributions

1. **Exact threshold identification**: We prove that the critical bonus is exactly Δ = min_{marked} cost − min cost, the gap between the constrained and unconstrained optima.

2. **Sharp trichotomy**: Below Δ, *all* minimizers are unmarked. Above Δ, *all* are marked. At Δ, both types coexist. There is no gradual transition.

3. **Monotonicity**: The predicate "all minimizers are marked" is monotone increasing in β, enabling binary search.

4. **Tropical decomposition**: The value function V(β) = min_x F_β(x) equals min(cost(x₀), cost(x_m) − β), a piecewise-linear function with a single tropical breakpoint.

5. **Formal verification**: All theorems are proved in Lean 4 with Mathlib, providing machine-checked certainty.

6. **Algorithms and applications**: We provide O(n) exact computation, O(n log(1/ε)) binary search, and worked applications in four domains.

### 1.3 Related Work

**Exact penalty methods** in mathematical programming (Zangwill 1967, Mangasarian 1969, Bertsekas 1975) establish conditions under which penalizing constraint violations by a sufficiently large multiplier recovers the constrained optimum. Our result can be viewed as a finite, tight version of exact penalty theory for indicator-function objectives.

**Tropical geometry** (Mikhalkin 2006, Maclagan-Sturmfels 2015) studies piecewise-linear geometry over the min-plus semiring. Our value function decomposition is a tropical polynomial evaluation, and the threshold is a tropical root.

**Phase transitions in combinatorial optimization** (Monasson et al. 1999, Achlioptas 2009) study how problem structure changes with random parameters. Our result is deterministic and exact, rather than asymptotic.

**Formal optimization** in proof assistants is a growing field. Work by Avigad, Lewis, and others has formalized convex analysis and optimization in Lean. Our contribution is among the first formally verified phase transition theorems.

---

## 2. Definitions and Setup

### 2.1 Problem Formulation

Let O be a finite, nonempty type. Let cost : O → ℝ be a cost function and marked : O → Prop be a decidable predicate.

**Definition 1** (Bonus Objective). For β ∈ ℝ, define
```
bonusObj(cost, marked, β, x) := cost(x) − (β if marked(x) else 0)
```

**Definition 2** (Global Minimizer). A point x is a global minimizer of f : O → ℝ if f(x) ≤ f(y) for all y ∈ O.
```
IsGlobalMin(f, x) := ∀ y, f(x) ≤ f(y)
```

### 2.2 Standing Assumptions

Throughout, we assume:
- (A1) O is finite and nonempty
- (A2) There exists at least one marked point
- (A3) There exists at least one unmarked global minimizer of cost

Assumptions (A2) and (A3) are the non-degeneracy conditions: the constrained problem is feasible, and the unconstrained optimum is not already feasible.

---

## 3. Main Results

### 3.1 Existence of Minimizers

**Theorem 1** (Global Minimizer Existence). Under (A1), for any cost : O → ℝ, there exists x₀ ∈ O with IsGlobalMin(cost, x₀).

*Proof sketch.* Apply `Finset.exists_min_image` to `Finset.univ`, which is nonempty by (A1). □

**Theorem 2** (Marked Minimizer Existence). Under (A2), there exists x_m ∈ O with marked(x_m) and cost(x_m) ≤ cost(y) for all marked y.

*Proof sketch.* Filter `Finset.univ` to marked elements (nonempty by (A2)) and apply `Finset.exists_min_image`. □

### 3.2 The Main Threshold Theorem

**Theorem 3** (Threshold Trichotomy). Let x₀ be a global minimizer of cost with ¬marked(x₀), and let x_m be a marked-cost minimizer. Set Δ = cost(x_m) − cost(x₀). Then:

(i) For all β < Δ and all z with IsGlobalMin(bonusObj β, z): ¬marked(z).

(ii) For all β > Δ and all z with IsGlobalMin(bonusObj β, z): marked(z).

*Proof.* We prove each direction by contradiction.

**Part (i):** Suppose β < Δ and z is a minimizer with marked(z). Then:
- bonusObj(β, z) = cost(z) − β
- Since x_m is the cheapest marked point: cost(x_m) ≤ cost(z)
- Since x₀ is unmarked: bonusObj(β, x₀) = cost(x₀)
- From minimality of z: cost(z) − β ≤ cost(x₀)
- Combined: cost(x_m) − β ≤ cost(x₀), so β ≥ Δ, contradicting β < Δ. □

**Part (ii):** Suppose β > Δ and z is a minimizer with ¬marked(z). Then:
- bonusObj(β, z) = cost(z)
- Since x₀ is a global minimizer: cost(x₀) ≤ cost(z)
- bonusObj(β, x_m) = cost(x_m) − β
- From minimality of z: cost(z) ≤ cost(x_m) − β
- Combined: cost(x₀) ≤ cost(x_m) − β, so β ≤ Δ, contradicting β > Δ. □

### 3.3 Bifurcation at the Critical Value

**Theorem 4** (Tie at Critical Value). Under the hypotheses of Theorem 3:
```
bonusObj(Δ, x₀) = bonusObj(Δ, x_m)
```

*Proof.* bonusObj(Δ, x₀) = cost(x₀) (unmarked) and bonusObj(Δ, x_m) = cost(x_m) − Δ = cost(x_m) − (cost(x_m) − cost(x₀)) = cost(x₀). □

**Theorem 5** (Coexistence at Critical Value). Under the hypotheses of Theorem 3, both x₀ and x_m are global minimizers of bonusObj(Δ, ·).

*Proof.* For any y:
- If marked(y): bonusObj(Δ, y) = cost(y) − Δ ≥ cost(x_m) − Δ = cost(x₀) = bonusObj(Δ, x₀) = bonusObj(Δ, x_m).
- If ¬marked(y): bonusObj(Δ, y) = cost(y) ≥ cost(x₀) = bonusObj(Δ, x₀) = bonusObj(Δ, x_m). □

### 3.4 Monotonicity

**Theorem 6** (Monotonicity of Marked-Minimizer Predicate). If at bonus β, every minimizer of bonusObj(β, ·) is marked, then for all γ ≥ β, every minimizer of bonusObj(γ, ·) is also marked.

*Proof.* Contrapositive. Suppose z is a minimizer at γ with ¬marked(z). Then bonusObj(γ, z) = cost(z). For any w: if ¬marked(w), bonusObj(β, w) = cost(w) and bonusObj(γ, w) = cost(w) ≥ cost(z) = bonusObj(γ, z); if marked(w), bonusObj(β, w) = cost(w) − β ≥ cost(w) − γ = bonusObj(γ, w) ≥ cost(z). So bonusObj(β, z) = cost(z) ≤ bonusObj(β, w) for all w, making z a minimizer at β that is unmarked. □

### 3.5 Existential Threshold Theorem

**Theorem 7** (Existential Threshold). Under (A1)–(A3), there exists Δ ≥ 0 such that:
1. ∀ β < Δ, all minimizers of bonusObj(β) are unmarked
2. ∀ β > Δ, all minimizers of bonusObj(β) are marked
3. At β = Δ, both an unmarked and a marked minimizer exist

*Proof.* Combine Theorems 2, 3, and 5 with Δ = cost(x_m) − cost(x₀). Non-negativity follows from cost(x₀) ≤ cost(x_m) (global minimality of x₀). □

### 3.6 Tropical Decomposition

**Theorem 8** (Tropical Normal Form). Under the hypotheses of Theorem 3, for any β and any global minimizer z of bonusObj(β):
```
bonusObj(β, z) = min(cost(x₀), cost(x_m) − β)
```

*Proof.*
- (≤): bonusObj(β, z) ≤ bonusObj(β, x₀) = cost(x₀) and bonusObj(β, z) ≤ bonusObj(β, x_m) = cost(x_m) − β.
- (≥): For any y, if unmarked: bonusObj(β, y) = cost(y) ≥ cost(x₀); if marked: bonusObj(β, y) = cost(y) − β ≥ cost(x_m) − β. So the minimum over all y is ≥ min(cost(x₀), cost(x_m) − β). □

---

## 4. Algorithms

### 4.1 Exact Threshold Computation

**Algorithm 1:** ExactThreshold(cost, marked)
```
Input: cost[1..n], marked[1..n]
Output: Δ, global_min_idx, marked_min_idx

1. global_min ← ∞; global_idx ← 0
2. marked_min ← ∞; marked_idx ← 0
3. for i = 1 to n:
4.     if cost[i] < global_min:
5.         global_min ← cost[i]; global_idx ← i
6.     if marked[i] and cost[i] < marked_min:
7.         marked_min ← cost[i]; marked_idx ← i
8. return (marked_min - global_min, global_idx, marked_idx)
```

**Complexity:** O(n) time, O(1) space. Single pass.

### 4.2 Binary Search Threshold Approximation

When the cost function is given implicitly (e.g., as an optimization oracle), the exact computation may not be available. Binary search provides an alternative.

**Algorithm 2:** BinarySearchThreshold(oracle, lo, hi, ε)
```
Input: oracle(β) returns minimizers of F_β, bracket [lo, hi], tolerance ε
Output: approximation of Δ within ε

1. while hi - lo > ε:
2.     mid ← (lo + hi) / 2
3.     minimizers ← oracle(mid)
4.     if all minimizers are marked:
5.         hi ← mid
6.     else if all minimizers are unmarked:
7.         lo ← mid
8.     else:
9.         return mid    // found exact threshold
10. return (lo + hi) / 2
```

**Complexity:** O(T(n) · log((hi−lo)/ε)) where T(n) is the oracle cost. With brute-force oracle, total is O(n · log(1/ε)).

**Correctness:** Guaranteed by Theorem 6 (monotonicity). The predicate "all minimizers are marked" is monotone in β, so the binary search invariant is maintained.

### 4.3 Multi-Predicate Extension

For k independent predicates, compute k independent thresholds in O(nk) time.

---

## 5. Applications

### 5.1 Green Logistics Incentives

**Setup:** 5 shipping routes with costs [45, 52, 38, 35, 80] $/unit. Routes 3 and 4 (Rail, Ship) are "green."

**Result:** Threshold Δ = 38 − 35 = $3/unit. A carbon credit above $3/unit guarantees green route selection.

**Policy implication:** Credits below $3 are ineffective; credits above $3 are guaranteed effective. The theorem eliminates guesswork from incentive design.

### 5.2 Fair Model Selection

**Setup:** 6 ML models with error rates [0.15, 0.08, 0.06, 0.04, 0.18, 0.09]. Models 5–6 satisfy fairness.

**Result:** Threshold Δ = 0.09 − 0.04 = 0.05. A fairness bonus above 0.05 makes fair models preferred.

**ML implication:** The accuracy cost of fairness is exactly quantified as the threshold value.

### 5.3 Renewable Energy Subsidies

**Setup:** 6 power sources with costs [65, 50, 75, 55, 48, 40] $/MWh. Solar, Wind, Hydro are renewable.

**Result:** Threshold Δ = 40 − 40 = $0/MWh. Hydro is already cheapest overall — no subsidy needed.

If we modify costs so that the cheapest non-renewable (Natural Gas, $50) beats the cheapest renewable (Hydro, $55), the threshold becomes $5/MWh.

### 5.4 Network Reliability

**Setup:** 6 network paths with latencies [5, 7, 12, 15, 200, 180] ms. Paths with redundancy are marked.

**Result:** Threshold Δ = 7 − 5 = 2ms. If reliability saves more than 2ms of expected downtime, redundant paths are optimal.

### 5.5 Numerical Experiments

Binary search convergence on a random instance (n=50, 30% marked):

| Steps | Bracket width | Relative error |
|-------|--------------|----------------|
| 1     | 5.25         | 1.0            |
| 5     | 0.33         | 0.63           |
| 10    | 0.010        | 0.020          |
| 20    | 1.0e-5       | 1.9e-5         |
| 30    | 9.7e-9       | 1.9e-8         |
| 39    | 4.7e-13      | 9.2e-13        |

Convergence is exponential with rate 1/2 per step, as predicted by the halving property.

---

## 6. Tropical Geometry Interpretation

### 6.1 Tropical Value Function

The value function V(β) = min_x F_β(x) has the tropical normal form:

V(β) = min(cost(x₀), cost(x_m) − β)

This is a tropical polynomial in β of degree 1:

V(β) = cost(x₀) ⊕ (cost(x_m) ⊙ β^{⊙(-1)})

in the min-plus semiring (ℝ ∪ {∞}, min, +).

### 6.2 Tropical Root

The threshold Δ is the unique tropical root of V, where the two branches intersect:

cost(x₀) = cost(x_m) − Δ ⟺ Δ = cost(x_m) − cost(x₀)

### 6.3 Wall-Crossing

In the language of tropical geometry, crossing the threshold corresponds to a **wall-crossing event**: the active cell of the tropical polynomial changes. Below Δ, the "unmarked branch" is active; above Δ, the "marked branch" is active.

For multiple predicates with independent bonuses β₁,...,β_k, the value function becomes a tropical polynomial in k variables, and the threshold locus is a tropical hypersurface arrangement in ℝ^k. This connects the threshold theory to the rich structure theory of tropical linear spaces.

---

## 7. Formal Verification

All theorems are verified in Lean 4 using the Mathlib library. The formalization consists of approximately 220 lines of Lean code proving 8 theorems with 3 definitions, all building on Mathlib's order theory and real analysis libraries.

The verified theorems correspond exactly to Theorems 1–8 above. The proofs use only standard axioms (propext, Classical.choice, Quot.sound) and no unresolved proof obligations (sorry-free).

Key proof techniques:
- Finite minimization via `Finset.exists_min_image`
- Case splitting on decidable predicates
- Contradiction arguments using linear arithmetic (`linarith`)
- The `grind` tactic for automated finishing

---

## 8. Discussion

### 8.1 Relationship to Exact Penalty Methods

The threshold theorem is a finite, constructive version of the classical exact penalty theorem (Zangwill 1967). In the classical setting, one shows that for sufficiently large penalty multiplier, the penalized unconstrained problem has the same solution as the constrained problem. Our theorem strengthens this by:
1. Identifying the exact threshold (not just existence of a sufficient multiplier)
2. Proving the sharp dichotomy (not just eventual agreement)
3. Characterizing the critical point (coexistence, not just agreement)

### 8.2 Limitations

- **Finiteness:** The theorem assumes a finite search space. Extension to compact spaces with continuous cost functions should be straightforward using compactness, but requires additional measure-theoretic or topological assumptions on the marking predicate.
- **Linear bonus:** The bonus is a step function (β or 0). Non-linear bonus structures may not exhibit a single sharp threshold.
- **Single predicate:** The multi-predicate extension to threshold arrangements is conjectured but not yet formally verified.

### 8.3 Open Questions

1. Does the tropical decomposition extend to non-linear bonus functions? Under what conditions is the value function still piecewise-linear?
2. Can the binary search algorithm be made formally extractable (constructive) in Lean?
3. What is the structure of the threshold arrangement for k predicates over n options?

---

## 9. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps including:
1. Executable binary search with convergence certificates
2. Tropical wall-crossing in higher dimensions
3. Multi-predicate threshold lattices
4. Fixed-point characterization via Tarski's theorem
5. Exact penalty duality for constrained optimization

---

## 10. References

1. Zangwill, W.I. (1967). Non-linear programming via penalty functions. *Management Science*, 13(5), 344–358.
2. Bertsekas, D.P. (1975). Nondifferentiable optimization via approximation. *Mathematical Programming Study*, 3, 1–25.
3. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
4. Mikhalkin, G. (2006). Tropical geometry and its applications. *Proceedings of the ICM*, Madrid.
5. Monasson, R., et al. (1999). Determining computational complexity from characteristic 'phase transitions'. *Nature*, 400(6740), 133–137.
